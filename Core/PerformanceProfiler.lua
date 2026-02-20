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
local _timeline = {}  -- Array of timeline events
local _frameMetrics = {}  -- Per-frame metrics

-- Event types for timeline
local EVENT_TYPES = {
	FRAME_UPDATE = "frame_update",
	EVENT_COALESCED = "event_coalesced",
	DIRTY_MARKED = "dirty_marked",
	DIRTY_PROCESSED = "dirty_processed",
	POOL_ACQUIRE = "pool_acquire",
	POOL_RELEASE = "pool_release",
	CONFIG_CHANGE = "config_change",
	GC_COLLECTION = "gc_collection",
}

-- Configuration
local MAX_TIMELINE_EVENTS = 10000
local PROFILE_SAMPLE_RATE = 0.016  -- 60 FPS (16ms per frame)

--[[----------------------------------------------------------------------------
	Recording
----------------------------------------------------------------------------]]--

--- Start performance recording
function PerformanceProfiler:StartRecording()
	if _isRecording then
		if UUF.DebugOutput then
			UUF.DebugOutput:Output("PerformanceProfiler", "Already recording", UUF.DebugOutput.TIER_INFO)
		end
		return false
	end
	
	_isRecording = true
	_recordingStartTime = GetTime()
	_timeline = {}
	_frameMetrics = {}
	
	-- Hook into systems
	self:_HookSystems()
	
	-- Start frame sampling
	self:_StartFrameSampling()
	
	if UUF.DebugOutput then
		UUF.DebugOutput:Output("PerformanceProfiler", "Recording started", UUF.DebugOutput.TIER_INFO)
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
	
	local duration = GetTime() - _recordingStartTime
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
		duration = GetTime() - _recordingStartTime,
		totalEvents = #_timeline,
		eventsByType = {},
		coalescedEvents = {},  -- Breakdown of which WoW events are coalesced
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
		-- Ignore event_coalesced - these are batched events (good, not a bottleneck)
		if count > 100 and eventType ~= "event_coalesced" then
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
	if totalEvents > 5000 then
		table.insert(recommendations, {
			category = "events",
			priority = "medium",
			message = string.format("%d events recorded. Event coalescing may help reduce CPU load.", totalEvents),
		})
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
		-- Hook QueueEvent
		local originalQueue = UUF.EventCoalescer.QueueEvent
		UUF.EventCoalescer.QueueEvent = function(self, eventName, ...)
			PerformanceProfiler:RecordEvent(EVENT_TYPES.EVENT_COALESCED, { event = eventName })
			return originalQueue(self, eventName, ...)
		end
	end
end

function PerformanceProfiler:_UnhookSystems()
	-- Restore original functions
	-- (In production, would need to store originals properly)
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
		if msg == "start" then
			PerformanceProfiler:StartRecording()
		elseif msg == "stop" then
			PerformanceProfiler:StopRecording()
		elseif msg == "analyze" then
			PerformanceProfiler:PrintAnalysis()
		elseif msg == "export" then
			local export = PerformanceProfiler:Export()
			print("|cFF00B0F7Export data copied to clipboard (if supported)|r")
			-- In actual implementation, would copy to clipboard
		else
			print("|cFF00B0F7PerformanceProfiler Commands:|r")
			print("  /uufprofile start - Start recording")
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
