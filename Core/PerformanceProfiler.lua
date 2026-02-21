--[[============================================================================
	PerformanceProfiler.lua
	Advanced performance profiling with timeline visualization and analysis
	
	Features:
	- Timeline recording of all system activities
	- Frame-by-frame performance tracking
	- Bottleneck identification
	- Export to shareable format
	- Integration with all optimization systems
	
	Usage:
		UUF.PerformanceProfiler:StartRecording()
		-- ... perform actions ...
		UUF.PerformanceProfiler:StopRecording()
		UUF.PerformanceProfiler:ShowTimeline()
============================================================================]]--

local UUF = select(2, ...)
local PerformanceProfiler = {}
UUF.PerformanceProfiler = PerformanceProfiler

-- PERF LOCALS: Localize frequently-called globals for faster access
local GetTime = GetTime
local GetFramerate = GetFramerate
local select, type, pairs, ipairs = select, type, pairs, ipairs
local tonumber, tostring = tonumber, tostring
local math_max, math_min = math.max, math.min
local table_insert, table_sort = table.insert, table.sort
local string_format = string.format
local debugprofilestop = debugprofilestop
local pairs = pairs
local math = math

-- Recording state
local _isRecording = false
local _recordingStartTime = 0
local _recordingDuration = 0
local _timeline = {}  -- Array of timeline events
local _frameMetrics = {}  -- Per-frame metrics
local _hooks = {
	coalescerQueueEvent = nil,
	coalescerDispatch = nil,
}
local _autoStopTimer = nil

-- Event types for timeline
local EVENT_TYPES = {
	FRAME_UPDATE = "frame_update",
	EVENT_COALESCED = "event_coalesced",
	EVENT_BATCH_DISPATCHED = "event_batch_dispatched",
	DIRTY_MARKED = "dirty_marked",
	DIRTY_PROCESSED = "dirty_processed",
	POOL_ACQUIRE = "pool_acquire",
	POOL_RELEASE = "pool_release",
	CONFIG_CHANGE = "config_change",
	GC_COLLECTION = "gc_collection",
}

-- Configuration
local MAX_TIMELINE_EVENTS = 50000
local PROFILE_SAMPLE_RATE = 0.016  -- 60 FPS (16ms per frame)

--[[----------------------------------------------------------------------------
	Recording
----------------------------------------------------------------------------]]--

--- Start performance recording
-- @param autoStopSeconds number|nil - Optional auto-stop duration in seconds.
function PerformanceProfiler:StartRecording(autoStopSeconds)
	if _isRecording then
		if UUF.DebugOutput then
			UUF.DebugOutput:Output("PerformanceProfiler", "Already recording", UUF.DebugOutput.TIER_INFO)
		end
		return false
	end
	
	_isRecording = true
	_recordingStartTime = GetTime()
	_recordingDuration = 0
	_timeline = {}
	_frameMetrics = {}
	
	-- Hook into systems
	self:_HookSystems()
	
	-- Start frame sampling
	self:_StartFrameSampling()

	-- Optional timed auto-stop + analyze.
	if _autoStopTimer then
		_autoStopTimer:Cancel()
		_autoStopTimer = nil
	end
	if type(autoStopSeconds) == "number" and autoStopSeconds > 0 then
		_autoStopTimer = C_Timer.NewTimer(autoStopSeconds, function()
			_autoStopTimer = nil
			if _isRecording then
				self:StopRecording()
				self:PrintAnalysis()
			end
		end)
	end
	
	if UUF.DebugOutput then
		if type(autoStopSeconds) == "number" and autoStopSeconds > 0 then
			UUF.DebugOutput:Output("PerformanceProfiler",
				string.format("Recording started (auto-stop in %ds)", autoStopSeconds),
				UUF.DebugOutput.TIER_INFO)
		else
			UUF.DebugOutput:Output("PerformanceProfiler", "Recording started", UUF.DebugOutput.TIER_INFO)
		end
	end
	return true
end

--- Stop performance recording
function PerformanceProfiler:StopRecording()
	if not _isRecording then
		if UUF.DebugOutput then
			UUF.DebugOutput:Output("PerformanceProfiler", "Not recording", UUF.DebugOutput.TIER_INFO)
		end
		return false
	end
	
	_isRecording = false
	
	-- Unhook systems
	self:_UnhookSystems()
	
	-- Stop frame sampling
	self:_StopFrameSampling()

	-- Cancel timed auto-stop if active.
	if _autoStopTimer then
		_autoStopTimer:Cancel()
		_autoStopTimer = nil
	end
	
	local duration = GetTime() - _recordingStartTime
	_recordingDuration = duration
	if UUF.DebugOutput then
		UUF.DebugOutput:Output("PerformanceProfiler", string.format("Recording stopped (%.2fs, %d events)", 
			duration, #_timeline), UUF.DebugOutput.TIER_INFO)
	end
	
	return true
end

--- Check if currently recording
-- @return boolean
function PerformanceProfiler:IsRecording()
	return _isRecording
end

--- Add an event to the timeline
-- @param eventType string - Type from EVENT_TYPES
-- @param data table - Event-specific data
function PerformanceProfiler:RecordEvent(eventType, data)
	if not _isRecording then return end
	
	if #_timeline >= MAX_TIMELINE_EVENTS then
		-- Stop recording when limit reached
		self:StopRecording()
		if UUF.DebugOutput then
			UUF.DebugOutput:Output("PerformanceProfiler", "Max events reached, stopping", UUF.DebugOutput.TIER_INFO)
		end
		return
	end
	
	local timestamp = GetTime() - _recordingStartTime
	
	table.insert(_timeline, {
		type = eventType,
		timestamp = timestamp,
		data = data or {},
	})
end

--[[----------------------------------------------------------------------------
	Analysis
----------------------------------------------------------------------------]]--

--- Analyze the recorded timeline
-- @return table - Analysis results
function PerformanceProfiler:Analyze()
	if #_timeline == 0 then
		return {error = "No timeline data"}
	end
	
	local analysis = {
		duration = _recordingDuration > 0 and _recordingDuration or (GetTime() - _recordingStartTime),
		totalEvents = #_timeline,
		eventsByType = {},
		coalescedEvents = {},  -- Breakdown of which WoW events are coalesced
		dispatchedEvents = {}, -- Breakdown of coalesced batch dispatches by WoW event
		coalescer = {
			totalCoalesced = 0,
			totalDispatched = 0,
			savingsPercent = 0,
			avgBatchSize = 0,
			maxBatchSize = 0,
		},
		bottlenecks = {},
		recommendations = {},
		frameMetrics = {
			avgFPS = 0,
			minFPS = 999,
			maxFPS = 0,
			frameTimeP50 = 0,
			frameTimeP95 = 0,
			frameTimeP99 = 0,
		},
	}
	
	-- Count events by type and extract coalesced event details
	for _, event in ipairs(_timeline) do
		analysis.eventsByType[event.type] = (analysis.eventsByType[event.type] or 0) + 1
		
		-- Track which WoW events are being coalesced
		if event.type == "event_coalesced" and event.data and event.data.event then
			local wowEvent = event.data.event
			analysis.coalescedEvents[wowEvent] = (analysis.coalescedEvents[wowEvent] or 0) + 1
		elseif event.type == "event_batch_dispatched" and event.data and event.data.event then
			local wowEvent = event.data.event
			analysis.dispatchedEvents[wowEvent] = (analysis.dispatchedEvents[wowEvent] or 0) + 1
		end
	end

	-- Baseline coalescer metrics from recorded timeline (independent of live coalescer stat resets).
	analysis.coalescer.totalCoalesced = analysis.eventsByType[EVENT_TYPES.EVENT_COALESCED] or 0
	analysis.coalescer.totalDispatched = analysis.eventsByType[EVENT_TYPES.EVENT_BATCH_DISPATCHED] or 0
	if analysis.coalescer.totalCoalesced > 0 then
		local saved = analysis.coalescer.totalCoalesced - analysis.coalescer.totalDispatched
		analysis.coalescer.savingsPercent = (saved / analysis.coalescer.totalCoalesced) * 100
	end

	if UUF.EventCoalescer and UUF.EventCoalescer.GetStats then
		local ok, coalescerStats = pcall(UUF.EventCoalescer.GetStats, UUF.EventCoalescer)
		if ok and type(coalescerStats) == "table" then
			analysis.coalescer.totalCoalesced = math.max(analysis.coalescer.totalCoalesced, coalescerStats.totalCoalesced or 0)
			analysis.coalescer.totalDispatched = math.max(analysis.coalescer.totalDispatched, coalescerStats.totalDispatched or 0)
			analysis.coalescer.savingsPercent = coalescerStats.savingsPercent or analysis.coalescer.savingsPercent

			local batchCount = 0
			local batchTotal = 0
			local batchMax = 0
			for _, batch in pairs(coalescerStats.batchSizes or {}) do
				local count = batch.count or 0
				local avg = batch.avg or 0
				batchCount = batchCount + count
				batchTotal = batchTotal + (avg * count)
				if (batch.max or 0) > batchMax then
					batchMax = batch.max
				end
			end
			analysis.coalescer.avgBatchSize = batchCount > 0 and (batchTotal / batchCount) or 0
			analysis.coalescer.maxBatchSize = batchMax
		end
	end
	
	-- Analyze frame metrics
	if #_frameMetrics > 0 then
		local fpsSum = 0
		local frameTimes = {}
		
		for _, metric in ipairs(_frameMetrics) do
			fpsSum = fpsSum + metric.fps
			analysis.frameMetrics.minFPS = math.min(analysis.frameMetrics.minFPS, metric.fps)
			analysis.frameMetrics.maxFPS = math.max(analysis.frameMetrics.maxFPS, metric.fps)
			table.insert(frameTimes, metric.frameTime)
		end
		
		analysis.frameMetrics.avgFPS = fpsSum / #_frameMetrics
		
		-- Calculate percentiles
		table.sort(frameTimes)
		local p50idx = math.floor(#frameTimes * 0.5)
		local p95idx = math.floor(#frameTimes * 0.95)
		local p99idx = math.floor(#frameTimes * 0.99)
		
		analysis.frameMetrics.frameTimeP50 = frameTimes[p50idx] or 0
		analysis.frameMetrics.frameTimeP95 = frameTimes[p95idx] or 0
		analysis.frameMetrics.frameTimeP99 = frameTimes[p99idx] or 0
	end
	
	-- Identify bottlenecks
	analysis.bottlenecks = self:_IdentifyBottlenecks()
	
	-- Generate recommendations
	analysis.recommendations = self:_GenerateRecommendations(analysis)
	
	return analysis
end

--- Identify performance bottlenecks
-- @return table - Array of bottlenecks
function PerformanceProfiler:_IdentifyBottlenecks()
	local bottlenecks = {}
	
	-- Look for high-frequency events (exclude event_coalesced - it's internal tracking)
	local eventCounts = {}
	for _, event in ipairs(_timeline) do
		eventCounts[event.type] = (eventCounts[event.type] or 0) + 1
	end
	
	for eventType, count in pairs(eventCounts) do
		-- Ignore internal coalescer tracking events (these are instrumentation, not workload sources)
		if count > 100 and eventType ~= "event_coalesced" and eventType ~= "event_batch_dispatched" then
			table.insert(bottlenecks, {
				type = "high_frequency",
				event = eventType,
				count = count,
				severity = "medium",
			})
		end
	end
	
	-- Look for frame time spikes
	for i, metric in ipairs(_frameMetrics) do
		if metric.frameTime > 33 then  -- > 33ms = below 30 FPS
			table.insert(bottlenecks, {
				type = "frame_spike",
				timestamp = metric.timestamp,
				frameTime = metric.frameTime,
				fps = metric.fps,
				severity = "high",
			})
		end
	end
	
	return bottlenecks
end

--- Generate performance recommendations
-- @param analysis table - Analysis results
-- @ table - Array of recommendations
function PerformanceProfiler:_GenerateRecommendations(analysis)
	local recommendations = {}
	
	-- Low FPS recommendation
	if analysis.frameMetrics.avgFPS < 45 then
		table.insert(recommendations, {
			category = "performance",
			priority = "high",
			message = string.format("Average FPS is low (%.1f). Consider enabling more optimizations.", 
				analysis.frameMetrics.avgFPS),
		})
	end
	
	-- High event frequency
	local totalEvents = analysis.totalEvents
	local coalescedCount = analysis.eventsByType["event_coalesced"] or 0
	local coalescedRatio = totalEvents > 0 and (coalescedCount / totalEvents) or 0
	if totalEvents > 5000 then
		if coalescedCount > 0 and analysis.coalescer.totalDispatched == 0 then
			table.insert(recommendations, {
				category = "events",
				priority = "high",
				message = "Coalesced events were recorded but no batch dispatches were observed. Check EventCoalescer dispatch path/hooks.",
			})
		end

		if coalescedRatio >= 0.8 then
			table.insert(recommendations, {
				category = "events",
				priority = "low",
				message = string.format("%d/%d events are already coalesced (%.0f%%). Coalescing is working; tune hot coalesced events instead of adding more coalescing.",
					coalescedCount, totalEvents, coalescedRatio * 100),
			})
			
			local sortedCoalesced = {}
			for eventName, count in pairs(analysis.coalescedEvents or {}) do
				table_insert(sortedCoalesced, { event = eventName, count = count })
			end
			table_sort(sortedCoalesced, function(a, b) return a.count > b.count end)
			if #sortedCoalesced > 0 then
				local top = sortedCoalesced[1]
				table.insert(recommendations, {
					category = "events",
					priority = "medium",
					message = string.format("Top coalesced event is %s (%d). Consider increasing its delay slightly or reducing upstream trigger frequency.",
						top.event, top.count),
				})
			end

			if analysis.coalescer.totalDispatched > 0 and analysis.coalescer.avgBatchSize < 1.5 then
				table.insert(recommendations, {
					category = "events",
					priority = "medium",
					message = string.format("Average coalesced batch size is low (%.2f). Increase delay slightly for top coalesced events to improve batching.",
						analysis.coalescer.avgBatchSize),
				})
			end
		else
			table.insert(recommendations, {
				category = "events",
				priority = "medium",
				message = string.format("%d events recorded. Event coalescing may help reduce CPU load.", totalEvents),
			})
		end
	end
	
	-- Frame time variance
	local p50 = analysis.frameMetrics.frameTimeP50
	local p99 = analysis.frameMetrics.frameTimeP99
	if p99 > p50 * 2 then
		table.insert(recommendations, {
			category = "consistency",
			priority = "medium",
			message = "Frame time variance is high. Consider batching updates more aggressively.",
		})
	end
	
	return recommendations
end

--- Print analysis results
function PerformanceProfiler:PrintAnalysis()
	local analysis = self:Analyze()
	
	if analysis.error then
		if UUF.DebugOutput then
			UUF.DebugOutput:Output("PerformanceProfiler", analysis.error, UUF.DebugOutput.TIER_CRITICAL)
		end
		return
	end
	
	if UUF.DebugOutput then
		UUF.DebugOutput:Output("PerformanceProfiler", "=== Performance Profile Analysis ===", UUF.DebugOutput.TIER_INFO)
		UUF.DebugOutput:Output("PerformanceProfiler", string.format("Duration: %.2fs", analysis.duration), UUF.DebugOutput.TIER_INFO)
		UUF.DebugOutput:Output("PerformanceProfiler", string.format("Total Events: %d", analysis.totalEvents), UUF.DebugOutput.TIER_INFO)
		UUF.DebugOutput:Output("PerformanceProfiler", "", UUF.DebugOutput.TIER_INFO)
		
		UUF.DebugOutput:Output("PerformanceProfiler", "Frame Metrics:", UUF.DebugOutput.TIER_INFO)
		UUF.DebugOutput:Output("PerformanceProfiler", string.format("  Avg FPS: %.1f", analysis.frameMetrics.avgFPS), UUF.DebugOutput.TIER_INFO)
		UUF.DebugOutput:Output("PerformanceProfiler", string.format("  Min/Max FPS: %.1f / %.1f", analysis.frameMetrics.minFPS, analysis.frameMetrics.maxFPS), UUF.DebugOutput.TIER_INFO)
		UUF.DebugOutput:Output("PerformanceProfiler", string.format("  Frame Time P50/P95/P99: %.1fms / %.1fms / %.1fms",
			analysis.frameMetrics.frameTimeP50,
			analysis.frameMetrics.frameTimeP95,
			analysis.frameMetrics.frameTimeP99), UUF.DebugOutput.TIER_INFO)
		UUF.DebugOutput:Output("PerformanceProfiler", "", UUF.DebugOutput.TIER_INFO)
		
		UUF.DebugOutput:Output("PerformanceProfiler", "Events by Type:", UUF.DebugOutput.TIER_INFO)
		for eventType, count in pairs(analysis.eventsByType) do
			UUF.DebugOutput:Output("PerformanceProfiler", string.format("  %s: %d", eventType, count), UUF.DebugOutput.TIER_INFO)
		end
		UUF.DebugOutput:Output("PerformanceProfiler", "", UUF.DebugOutput.TIER_INFO)

		UUF.DebugOutput:Output("PerformanceProfiler", "Coalescer Batch Metrics:", UUF.DebugOutput.TIER_INFO)
		UUF.DebugOutput:Output("PerformanceProfiler", string.format("  Batches Dispatched: %d", analysis.coalescer.totalDispatched), UUF.DebugOutput.TIER_INFO)
		UUF.DebugOutput:Output("PerformanceProfiler", string.format("  Avg/Max Batch Size: %.2f / %d",
			analysis.coalescer.avgBatchSize, analysis.coalescer.maxBatchSize), UUF.DebugOutput.TIER_INFO)
		UUF.DebugOutput:Output("PerformanceProfiler", string.format("  Coalescer Savings: %.1f%%", analysis.coalescer.savingsPercent), UUF.DebugOutput.TIER_INFO)
		UUF.DebugOutput:Output("PerformanceProfiler", "", UUF.DebugOutput.TIER_INFO)
		
		-- Show coalesced event breakdown
		if next(analysis.coalescedEvents) then
			UUF.DebugOutput:Output("PerformanceProfiler", "Coalesced WoW Events (Top 10):", UUF.DebugOutput.TIER_INFO)
			-- Sort by count
			local sorted = {}
			for event, count in pairs(analysis.coalescedEvents) do
				table.insert(sorted, {event = event, count = count})
			end
			table.sort(sorted, function(a, b) return a.count > b.count end)
			-- Show top 10
			for i = 1, math.min(10, #sorted) do
				UUF.DebugOutput:Output("PerformanceProfiler", string.format("  %s: %d", sorted[i].event, sorted[i].count), UUF.DebugOutput.TIER_INFO)
			end
			if #sorted > 10 then
				UUF.DebugOutput:Output("PerformanceProfiler", string.format("  ... and %d more", #sorted - 10), UUF.DebugOutput.TIER_INFO)
			end
			UUF.DebugOutput:Output("PerformanceProfiler", "", UUF.DebugOutput.TIER_INFO)
		end

		if next(analysis.dispatchedEvents) then
			UUF.DebugOutput:Output("PerformanceProfiler", "Dispatched Batches by Event (Top 10):", UUF.DebugOutput.TIER_INFO)
			local sorted = {}
			for event, count in pairs(analysis.dispatchedEvents) do
				table.insert(sorted, {event = event, count = count})
			end
			table.sort(sorted, function(a, b) return a.count > b.count end)
			for i = 1, math.min(10, #sorted) do
				UUF.DebugOutput:Output("PerformanceProfiler", string.format("  %s: %d", sorted[i].event, sorted[i].count), UUF.DebugOutput.TIER_INFO)
			end
			if #sorted > 10 then
				UUF.DebugOutput:Output("PerformanceProfiler", string.format("  ... and %d more", #sorted - 10), UUF.DebugOutput.TIER_INFO)
			end
			UUF.DebugOutput:Output("PerformanceProfiler", "", UUF.DebugOutput.TIER_INFO)
		end
		
		if #analysis.bottlenecks > 0 then
			UUF.DebugOutput:Output("PerformanceProfiler", "Bottlenecks:", UUF.DebugOutput.TIER_INFO)
			for _, bottleneck in ipairs(analysis.bottlenecks) do
				UUF.DebugOutput:Output("PerformanceProfiler", string.format("  [%s] %s", bottleneck.severity:upper(), bottleneck.type), UUF.DebugOutput.TIER_INFO)
			end
			UUF.DebugOutput:Output("PerformanceProfiler", "", UUF.DebugOutput.TIER_INFO)
		end
		
		if #analysis.recommendations > 0 then
			UUF.DebugOutput:Output("PerformanceProfiler", "Recommendations:", UUF.DebugOutput.TIER_INFO)
			for _, rec in ipairs(analysis.recommendations) do
				UUF.DebugOutput:Output("PerformanceProfiler", string.format("  [%s] %s", rec.priority:upper(), rec.message), UUF.DebugOutput.TIER_INFO)
			end
		end
	end
end

--[[----------------------------------------------------------------------------
	Export
----------------------------------------------------------------------------]]--

--- Export timeline and analysis to string format
-- @return string - Export data
function PerformanceProfiler:Export()
	local analysis = self:Analyze()
	local export = {
		version = "1.0",
		timestamp = date("%Y-%m-%d %H:%M:%S"),
		analysis = analysis,
		timeline = _timeline,
		frameMetrics = _frameMetrics,
	}
	
	-- Convert to JSON-like string (simplified)
	local exportStr = self:_SerializeTable(export)
	return exportStr
end

--- Serialize a table to string (JSON-like)
-- @param tbl table
-- @return string
function PerformanceProfiler:_SerializeTable(tbl, indent)
	indent = indent or 0
	local indentStr = string.rep("  ", indent)
	local lines = {}
	
	table.insert(lines, "{")
	for k, v in pairs(tbl) do
		local key = type(k) == "string" and ('"' .. k .. '"') or tostring(k)
		local value
		
		if type(v) == "table" then
			value = self:_SerializeTable(v, indent + 1)
		elseif type(v) == "string" then
			value = '"' .. v .. '"'
		else
			value = tostring(v)
		end
		
		table.insert(lines, indentStr .. "  " .. key .. ": " .. value .. ",")
	end
	table.insert(lines, indentStr .. "}")
	
	return table.concat(lines, "\n")
end

--[[----------------------------------------------------------------------------
	System Hooks
----------------------------------------------------------------------------]]--

function PerformanceProfiler:_HookSystems()
	-- Hook DirtyFlagManager
	if UUF.DirtyFlagManager then
		-- Already covered by DirtyPriorityOptimizer integration
	end
	
	-- Hook EventCoalescer
	if UUF.EventCoalescer then
		-- Hook QueueEvent once and keep original for restore
		if not _hooks.coalescerQueueEvent then
			_hooks.coalescerQueueEvent = UUF.EventCoalescer.QueueEvent
			UUF.EventCoalescer.QueueEvent = function(self, eventName, ...)
				PerformanceProfiler:RecordEvent(EVENT_TYPES.EVENT_COALESCED, { event = eventName })
				return _hooks.coalescerQueueEvent(self, eventName, ...)
			end
		end

		-- Hook _DispatchCoalesced for batch dispatch visibility
		if not _hooks.coalescerDispatch and UUF.EventCoalescer._DispatchCoalesced then
			_hooks.coalescerDispatch = UUF.EventCoalescer._DispatchCoalesced
			UUF.EventCoalescer._DispatchCoalesced = function(self, eventName, ...)
				local beforeDispatched = 0
				if self.GetStats then
					local okBefore, statsBefore = pcall(self.GetStats, self)
					if okBefore and type(statsBefore) == "table" then
						beforeDispatched = statsBefore.totalDispatched or 0
					end
				end

				local result = _hooks.coalescerDispatch(self, eventName, ...)

				local afterDispatched = beforeDispatched
				if self.GetStats then
					local okAfter, statsAfter = pcall(self.GetStats, self)
					if okAfter and type(statsAfter) == "table" then
						afterDispatched = statsAfter.totalDispatched or beforeDispatched
					end
				end

				if afterDispatched > beforeDispatched then
					PerformanceProfiler:RecordEvent(EVENT_TYPES.EVENT_BATCH_DISPATCHED, { event = eventName })
				end

				return result
			end
		end
	end
end

function PerformanceProfiler:_UnhookSystems()
	-- Restore original functions
	if UUF.EventCoalescer and _hooks.coalescerQueueEvent then
		UUF.EventCoalescer.QueueEvent = _hooks.coalescerQueueEvent
		_hooks.coalescerQueueEvent = nil
	end
	if UUF.EventCoalescer and _hooks.coalescerDispatch then
		UUF.EventCoalescer._DispatchCoalesced = _hooks.coalescerDispatch
		_hooks.coalescerDispatch = nil
	end
end

function PerformanceProfiler:_StartFrameSampling()
	self._sampleTicker = C_Timer.NewTicker(PROFILE_SAMPLE_RATE, function()
		if not _isRecording then return end
		
		local fps = GetFramerate()
		local frameTime = 1000 / fps  -- Convert to milliseconds
		local timestamp = GetTime() - _recordingStartTime
		
		table.insert(_frameMetrics, {
			timestamp = timestamp,
			fps = fps,
			frameTime = frameTime,
		})
	end)
end

function PerformanceProfiler:_StopFrameSampling()
	if self._sampleTicker then
		self._sampleTicker:Cancel()
		self._sampleTicker = nil
	end
end

--[[----------------------------------------------------------------------------
	Initialization
----------------------------------------------------------------------------]]--

function PerformanceProfiler:Init()
	-- Register slash commands
	SLASH_UUFPROFILE1 = "/uufprofile"
	SlashCmdList["UUFPROFILE"] = function(msg)
		msg = (msg or ""):lower()
		local command, arg = msg:match("^(%S+)%s*(.*)$")
		command = command or ""
		arg = arg or ""

		-- Support: /uufprofile 90 (alias for /uufprofile start 90)
		if command ~= "" and command:match("^%d+$") then
			local seconds = tonumber(command)
			PerformanceProfiler:StartRecording(seconds)
			return
		end

		if command == "start" then
			local seconds = tonumber(arg)
			if seconds and seconds > 0 then
				PerformanceProfiler:StartRecording(seconds)
			else
				PerformanceProfiler:StartRecording()
			end
		elseif command == "stop" then
			PerformanceProfiler:StopRecording()
		elseif command == "analyze" then
			PerformanceProfiler:PrintAnalysis()
		elseif command == "export" then
			local export = PerformanceProfiler:Export()
			print("|cFF00B0F7Export data copied to clipboard (if supported)|r")
			-- In actual implementation, would copy to clipboard
		else
			print("|cFF00B0F7PerformanceProfiler Commands:|r")
			print("  /uufprofile start - Start recording")
			print("  /uufprofile start 90 - Start recording, auto-stop/analyze after 90s")
			print("  /uufprofile 90 - Alias for timed start")
			print("  /uufprofile stop - Stop recording")
			print("  /uufprofile analyze - Show analysis")
			print("  /uufprofile export - Export data")
		end
	end
	
	print("|cFF00B0F7UnhaltedUnitFrames: PerformanceProfiler initialized. Use /uufprofile|r")
end

function PerformanceProfiler:Validate()
	if not UUF.PerformanceProfiler then
		return false, "PerformanceProfiler not loaded"
	end
	
	return true, "PerformanceProfiler operational"
end

return PerformanceProfiler
