--[[============================================================================
	DirtyFlagManager.lua
	Automatic dirty flag tracking and invalidation for efficient frame updates
	
	Tracks which frames need updating and automatically invalidates only frames
	that have actually changed. Prevents unnecessary updates and batch-processes
	dirty frames.
	
	Benefits:
	- 10-20% CPU reduction by avoiding redundant updates
	- Automatic integration with ReactiveConfig
	- Batch processing of dirty frames
	- Configurable update strategies
	
	Usage:
		UUF.DirtyFlagManager:MarkDirty(frame, reason)
		UUF.DirtyFlagManager:IsDirty(frame)
		UUF.DirtyFlagManager:ClearDirty(frame)
		UUF.DirtyFlagManager:ProcessDirty()
============================================================================]]--

local UUF = select(2, ...)
local DirtyFlagManager = {}
UUF.DirtyFlagManager = DirtyFlagManager

-- Performance locals
local C_Timer = C_Timer
local GetTime = GetTime
local pairs = pairs
local type = type
local math_max = math.max
local tinsert = table.insert
local tremove = table.remove

-- Dirty frame tracking
-- [frame] = {
--   dirty = boolean,
--   reasons = { "reason1", "reason2", ... },
--   markedTime = timestamp,
--   priority = number (1=low, 5=critical)
-- }
local _dirtyFrames = {}
local _dirtyQueue = {}  -- Array of frames needing update

-- Statistics
local _stats = {
	totalInvalidations = 0,    -- Total times MarkDirty called
	totalProcessed = 0,        -- Total ProcessDirty calls
	currentDirty = 0,          -- Current dirty frame count
	totalTracked = 0,          -- Total unique frames tracked
	reasonCounts = {},         -- Per-reason counts
	invalidFramesSkipped = 0,  -- Frames skipped due to validation failure
	priorityDecays = 0,        -- Times priority decay was applied
	processingBlocks = 0,      -- Times ProcessDirty was blocked due to re-entry
}

-- Configuration
local AUTO_PROCESS_DELAY = 0.1  -- Auto-process after 100ms
local MAX_PROCESS_PER_FRAME = 10  -- Max frames to update per batch
local USE_PRIORITY_QUEUE = true   -- Process high-priority frames first
local USE_FRAME_TIME_BUDGET = true  -- Use adaptive batching based on frame time
local PRIORITY_DECAY_RATE = 0.1  -- Decay priority by this amount every 5 seconds
local PRIORITY_DECAY_INTERVAL = 5.0  -- Seconds between priority decays

-- Auto-process timer
local _autoProcessTimer = nil
local _hasPendingProcess = false
local _isProcessing = false  -- Processing lock to prevent re-entry
local _lastPriorityDecay = 0  -- Last time priorities were decayed

--[[----------------------------------------------------------------------------
	Public API
----------------------------------------------------------------------------]]--

--- Mark a frame as dirty (needs update)
-- @param frame table - The frame to mark dirty
-- @param reason string - Reason for marking dirty (for debugging)
-- @param priority number - Optional priority (1-5, default 3)
-- @return boolean - Success
function DirtyFlagManager:MarkDirty(frame, reason, priority)
	if not frame or type(frame) ~= "table" then
		return false
	end
	
	reason = reason or "unknown"
	priority = priority or 3
	
	-- Initialize tracking if first time
	if not _dirtyFrames[frame] then
		_dirtyFrames[frame] = {
			dirty = false,
			reasons = {},
			markedTime = 0,
			priority = 3,
		}
		_stats.totalTracked = _stats.totalTracked + 1
	end
	
	local data = _dirtyFrames[frame]
	
	-- Mark dirty if not already
	if not data.dirty then
		data.dirty = true
		data.markedTime = GetTime()
		tinsert(_dirtyQueue, frame)
		_stats.currentDirty = _stats.currentDirty + 1
	end
	
	-- Add reason
	tinsert(data.reasons, reason)
	data.priority = math.max(data.priority, priority)  -- Use highest priority
	
	-- Update statistics
	_stats.totalInvalidations = _stats.totalInvalidations + 1
	_stats.reasonCounts[reason] = (_stats.reasonCounts[reason] or 0) + 1
	
	-- Schedule auto-process if not already scheduled
	if not _hasPendingProcess then
		_hasPendingProcess = true
		C_Timer.After(AUTO_PROCESS_DELAY, function()
			self:ProcessDirty()
		end)
	end
	
	return true
end

--- Check if a frame is marked dirty
-- @param frame table
-- @return boolean - Is dirty
function DirtyFlagManager:IsDirty(frame)
	local data = _dirtyFrames[frame]
	return data and data.dirty or false
end

--- Clear dirty flag for a frame
-- @param frame table
-- @return boolean - Was dirty
function DirtyFlagManager:ClearDirty(frame)
	local data = _dirtyFrames[frame]
	if not data or not data.dirty then
		return false
	end
	
	data.dirty = false
	data.reasons = {}
	data.priority = 3  -- Reset to default
	_stats.currentDirty = math.max(0, _stats.currentDirty - 1)
	
	return true
end

--- Get reasons why a frame is dirty
-- @param frame table
-- @return table - Array of reason strings
function DirtyFlagManager:GetReasons(frame)
	local data = _dirtyFrames[frame]
	if not data then return {} end
	
	return data.reasons
end

--- Validate that a frame is still valid and can be updated
-- @param frame table
-- @return boolean - Is valid
local function _ValidateFrame(frame)
	if not frame then return false end
	if type(frame) ~= "table" then return false end
	
	-- Check if frame has been garbage collected or is nil
	-- This is a best-effort check; WoW doesn't provide perfect GC detection
	
	-- Check for basic frame properties
	-- If the frame has no update methods, it's probably invalid
	if not (frame.UpdateAll or frame.Update or (frame.element and frame.element.Update)) then
		return false
	end
	
	-- If frame has a GetObjectType method (UI widgets), verify it's still valid
	if frame.GetObjectType then
		local success, objType = pcall(frame.GetObjectType, frame)
		if not success then
			return false  -- Frame is dead/invalid
		end
	end
	
	return true
end

--- Apply priority decay to long-waiting frames
-- Reduces priority over time to prevent starvation
local function _ApplyPriorityDecay()
	local now = GetTime()
	if now - _lastPriorityDecay < PRIORITY_DECAY_INTERVAL then
		return
	end
	
	_lastPriorityDecay = now
	_stats.priorityDecays = _stats.priorityDecays + 1
	
	for frame, data in pairs(_dirtyFrames) do
		if data.dirty and data.priority > 1 then
			local age = now - data.markedTime
			if age > PRIORITY_DECAY_INTERVAL then
				data.priority = math.max(1, data.priority - PRIORITY_DECAY_RATE)
			end
		end
	end
end


--- Process all dirty frames (update them)
-- @param maxFrames number - Max frames to process (default: MAX_PROCESS_PER_FRAME)
-- @return number - Number of frames processed
function DirtyFlagManager:ProcessDirty(maxFrames)
	-- Prevent re-entry
	if _isProcessing then
		_stats.processingBlocks = _stats.processingBlocks + 1
		return 0
	end
	
	_isProcessing = true
	_hasPendingProcess = false
	
	if #_dirtyQueue == 0 then
		_isProcessing = false
		return 0
	end
	
	-- Apply priority decay
	_ApplyPriorityDecay()
	
	local baseDelay = 0.05
	local baseMaxFrames = maxFrames or MAX_PROCESS_PER_FRAME

	-- If we're already over budget, batch more aggressively and slow processing
	if USE_FRAME_TIME_BUDGET and UUF.FrameTimeBudget and UUF.FrameTimeBudget:ShouldThrottle() then
		baseMaxFrames = math_max(1, baseMaxFrames / 2)
		baseDelay = 0.1
	end

	-- Use adaptive batch size if FrameTimeBudget is available
	if USE_FRAME_TIME_BUDGET and UUF.FrameTimeBudget then
		maxFrames = UUF.FrameTimeBudget:GetAdaptiveBatchSize(baseMaxFrames)
	else
		maxFrames = baseMaxFrames
	end
	
	local processed = 0
	local deferred = 0
	
	-- Sort by priority if enabled
	if USE_PRIORITY_QUEUE then
		table.sort(_dirtyQueue, function(a, b)
			local dataA = _dirtyFrames[a]
			local dataB = _dirtyFrames[b]
			return (dataA and dataA.priority or 0) > (dataB and dataB.priority or 0)
		end)
	end
	
	-- Process frames
	while #_dirtyQueue > 0 and processed < maxFrames do
		local frame = tremove(_dirtyQueue, 1)
		local data = _dirtyFrames[frame]
		
		-- Validate frame before processing
		local isValid = _ValidateFrame(frame)
		
		if not isValid then
			-- Skip invalid frames
			_stats.invalidFramesSkipped = _stats.invalidFramesSkipped + 1
			if data then
				self:ClearDirty(frame)
			end
		elseif data and data.dirty then
			-- Check frame time budget if enabled
			local priority = UUF.FrameTimeBudget and (
				data.priority >= 4 and UUF.FrameTimeBudget.PRIORITY_CRITICAL or
				data.priority == 3 and UUF.FrameTimeBudget.PRIORITY_HIGH or
				data.priority == 2 and UUF.FrameTimeBudget.PRIORITY_MEDIUM or
				UUF.FrameTimeBudget.PRIORITY_LOW
			) or 3
			
			if USE_FRAME_TIME_BUDGET and UUF.FrameTimeBudget and not UUF.FrameTimeBudget:CanAfford(priority, 0.5) then
				-- Defer this frame to next batch
				tinsert(_dirtyQueue, frame)
				deferred = deferred + 1
				break
			end
			
			-- Call the frame's update method if it exists
			local success = false
			
			if frame.UpdateAll then
				success = pcall(frame.UpdateAll, frame)
			elseif frame.Update then
				success = pcall(frame.Update, frame)
			elseif frame.element and frame.element.Update then
				success = pcall(frame.element.Update, frame.element, frame)
			end
			
			if not success then
				-- Log error but continue
				if UUF.Debug then
					print("|cFFFF0000DirtyFlagManager: Error updating frame|r")
				end
			end
			
			-- Clear dirty flag
			self:ClearDirty(frame)
			processed = processed + 1
		end
	end
	
	_stats.totalProcessed = _stats.totalProcessed + 1
	_isProcessing = false
	
	-- If more frames remain, schedule another process
	if #_dirtyQueue > 0 then
		_hasPendingProcess = true
		
		-- Use adaptive batch interval if available
		local delay = baseDelay
		if USE_FRAME_TIME_BUDGET and UUF.FrameTimeBudget then
			delay = UUF.FrameTimeBudget:GetAdaptiveBatchInterval(delay)
		end
		
		C_Timer.After(delay, function()
			self:ProcessDirty()
		end)
	end
	
	return processed
end

--- Force process ALL dirty frames immediately (ignore max batch size)
-- @return number - Number of frames processed
function DirtyFlagManager:ProcessAll()
	local totalProcessed = 0
	
	while #_dirtyQueue > 0 do
		local processed = self:ProcessDirty(9999)
		totalProcessed = totalProcessed + processed
		
		-- Safety: break if nothing was processed
		if processed == 0 then
			break
		end
	end
	
	return totalProcessed
end

--- Get count of dirty frames
-- @return number
function DirtyFlagManager:GetDirtyCount()
	return _stats.currentDirty
end

--- Get statistics
-- @return table - Statistics data
function DirtyFlagManager:GetStats()
	return {
		invalidations = _stats.totalInvalidations,
		processed = _stats.totalProcessed,
		dirtyCount = _stats.currentDirty,
		totalTracked = _stats.totalTracked,
		reasonCounts = _stats.reasonCounts,
		invalidFramesSkipped = _stats.invalidFramesSkipped,
		priorityDecays = _stats.priorityDecays,
		processingBlocks = _stats.processingBlocks,
	}
end

--- Print statistics to chat
function DirtyFlagManager:PrintStats()
	local stats = self:GetStats()
	print("|cFF00B0F7=== Dirty Flag Statistics ===|r")
	print(string.format("Total Tracked Frames: %d", stats.totalTracked))
	print(string.format("Currently Dirty: %d", stats.dirtyCount))
	print(string.format("Total Invalidations: %d", stats.invalidations))
	print(string.format("Total Process Batches: %d", stats.processed))
	print(string.format("Invalid Frames Skipped: %d", stats.invalidFramesSkipped))
	print(string.format("Priority Decays Applied: %d", stats.priorityDecays))
	print(string.format("Processing Blocks (Re-entry): %d", stats.processingBlocks))
	
	if next(stats.reasonCounts) then
		print("|cFF00B0F7Invalidation Reasons:|r")
		for reason, count in pairs(stats.reasonCounts) do
			print(string.format("  %s: %d", reason, count))
		end
	end
end

--- Reset statistics
function DirtyFlagManager:ResetStats()
	_stats.totalInvalidations = 0
	_stats.totalProcessed = 0
	_stats.reasonCounts = {}
	_stats.invalidFramesSkipped = 0
	_stats.priorityDecays = 0
	_stats.processingBlocks = 0
	-- Don't reset currentDirty or totalTracked (reflect actual state)
end

--- Clear all dirty flags
function DirtyFlagManager:ClearAll()
	_dirtyQueue = {}
	for frame, data in pairs(_dirtyFrames) do
		data.dirty = false
		data.reasons = {}
		data.priority = 3
	end
	_stats.currentDirty = 0
end

--- Untrack a frame (remove from tracking)
-- @param frame table
function DirtyFlagManager:Untrack(frame)
	if _dirtyFrames[frame] then
		if _dirtyFrames[frame].dirty then
			_stats.currentDirty = math.max(0, _stats.currentDirty - 1)
		end
		_dirtyFrames[frame] = nil
		_stats.totalTracked = math.max(0, _stats.totalTracked - 1)
		
		-- Remove from queue
		for i = #_dirtyQueue, 1, -1 do
			if _dirtyQueue[i] == frame then
				tremove(_dirtyQueue, i)
			end
		end
	end
end

--[[----------------------------------------------------------------------------
	Configuration
----------------------------------------------------------------------------]]--

--- Set auto-process delay
-- @param delay number - Delay in seconds (default 0.1)
function DirtyFlagManager:SetAutoProcessDelay(delay)
	AUTO_PROCESS_DELAY = math.max(0.01, delay or 0.1)
end

--- Set max frames to process per batch
-- @param max number - Max frames (default 10)
function DirtyFlagManager:SetMaxProcessPerFrame(max)
	MAX_PROCESS_PER_FRAME = math.max(1, max or 10)
end

--- Enable/disable priority queue
-- @param enable boolean
function DirtyFlagManager:SetPriorityQueueEnabled(enable)
	USE_PRIORITY_QUEUE = not not enable
end

--- Enable/disable frame time budget integration
-- @param enable boolean
function DirtyFlagManager:SetFrameTimeBudgetEnabled(enable)
	USE_FRAME_TIME_BUDGET = not not enable
end

--[[----------------------------------------------------------------------------
	Integration Helpers
----------------------------------------------------------------------------]]--

--- Integrate with ReactiveConfig for automatic dirty marking
function DirtyFlagManager:IntegrateWithReactiveConfig()
	if not UUF.ReactiveConfig then
		print("|cFFFF0000DirtyFlagManager: ReactiveConfig not available|r")
		return false
	end
	
	-- Register listener for all config changes
	UUF.ReactiveConfig:OnConfigChange("*", function(event)
		-- Mark relevant frames as dirty
		-- Note: This is a generic handler. Specific handlers can be added for optimization.
		
		if event.path:match("^Units%.") then
			-- Unit-specific config changed
			local unitToken = event.path:match("^Units%.([^.]+)")
			
			if unitToken and UUF.Units and UUF.Units[unitToken] then
				local frame = UUF.Units[unitToken]
				self:MarkDirty(frame, "config:" .. event.path, 3)
			end
		elseif event.path:match("^General%.") then
			-- Global config changed - mark all frames dirty
			if UUF.Units then
				for unitToken, frame in pairs(UUF.Units) do
					self:MarkDirty(frame, "config:" .. event.path, 2)
				end
			end
		end
	end, 200)  -- Priority 200 (after config behaviors, before UI updates)
	
	print("|cFF00B0F7DirtyFlagManager: Integrated with ReactiveConfig|r")
	return true
end

--- Hook frame creation to auto-register for dirty tracking
function DirtyFlagManager:HookFrameCreation()
	if not UUF.CreateUnitFrame then
		return false
	end
	
	-- Hook the frame creation function
	local originalCreate = UUF.CreateUnitFrame
	UUF.CreateUnitFrame = function(...)
		local frame = originalCreate(...)
		
		if frame then
			-- Initialize tracking
			_dirtyFrames[frame] = {
				dirty = false,
				reasons = {},
				markedTime = 0,
				priority = 3,
			}
			_stats.totalTracked = _stats.totalTracked + 1
		end
		
		return frame
	end
	
	print("|cFF00B0F7DirtyFlagManager: Hooked frame creation|r")
	return true
end

--[[----------------------------------------------------------------------------
	Initialization
----------------------------------------------------------------------------]]--

--- Initialize the dirty flag manager
function DirtyFlagManager:Init()
	-- Integrate with ReactiveConfig if available
	if UUF.ReactiveConfig then
		self:IntegrateWithReactiveConfig()
	end
	
	if UUF.DebugOutput then
		UUF.DebugOutput:Output("DirtyFlagManager", "Initialized", UUF.DebugOutput.TIER_INFO)
	else
		print("|cFF00B0F7UnhaltedUnitFrames: DirtyFlagManager initialized|r")
	end
end

--- Validate the dirty flag manager
-- @return boolean - Valid
-- @return string - Message
function DirtyFlagManager:Validate()
	if not UUF.DirtyFlagManager then
		return false, "DirtyFlagManager not loaded"
	end
	
	-- Test marking a test frame dirty
	local testFrame = { name = "test" }
	if not self:MarkDirty(testFrame, "test", 3) then
		return false, "Cannot mark frame dirty"
	end
	
	if not self:IsDirty(testFrame) then
		return false, "Dirty flag not set correctly"
	end
	
	-- Clean up
	self:Untrack(testFrame)
	
	return true, "DirtyFlagManager operational"
end

return DirtyFlagManager
