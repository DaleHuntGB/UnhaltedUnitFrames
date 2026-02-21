--[[============================================================================
	PerformanceDashboard.lua
	In-game performance monitoring UI for UnhaltedUnitFrames
	
	Shows real-time statistics:
	- FPS and frame time
	- Memory usage
	- Pool statistics (auras, indicators)
	- Event statistics (coalescing, dispatching)
	- Dirty frame counts
	
	Usage:
		/run UUF.PerformanceDashboard:Toggle()
		/run UUF.PerformanceDashboard:Show()
		/run UUF.PerformanceDashboard:Hide()
============================================================================]]--

local UUF = select(2, ...)
local PerformanceDashboard = {}
UUF.PerformanceDashboard = PerformanceDashboard

-- Performance locals
local GetFramerate = GetFramerate
local GetTime = GetTime
local collectgarbage = collectgarbage
local string = string
local math = math
local C_Timer = C_Timer

-- Dashboard frame
local _frame = nil
local _updateInterval = 1.0  -- Update every 1 second
local _lastUpdate = 0
local _isVisible = false

-- Cached values for smoothing
local _fpsSamples = {}
local _maxSamples = 5

--[[----------------------------------------------------------------------------
	Frame Creation
----------------------------------------------------------------------------]]--

local function CreateDashboardFrame()
	if _frame then return _frame end
	
	-- Main container
	local frame = CreateFrame("Frame", "UUFPerformanceDashboard", UIParent, "BackdropTemplate")
	frame:SetSize(300, 400)
	frame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -20, -200)
	frame:SetFrameStrata("DIALOG")
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
	frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
	frame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true,
		tileSize = 32,
		edgeSize = 32,
		insets = { left = 8, right = 8, top = 8, bottom = 8 }
	})
	frame:SetBackdropColor(0, 0, 0, 0.9)
	
	-- Title
	local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("TOP", frame, "TOP", 0, -15)
	title:SetText("|cFF00B0F7UUF Performance|r")
	frame.title = title
	
	-- Close button
	local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
	closeBtn:SetScript("OnClick", function()
		PerformanceDashboard:Hide()
	end)
	frame.closeButton = closeBtn
	
	-- Content container (scrollable)
	local content = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
	content:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -40)
	content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 15)
	frame.content = content
	
	-- Create a child frame to hold the text (ScrollFrame requires a Frame as scroll child, not FontString)
	local textFrame = CreateFrame("Frame", nil, content)
	textFrame:SetSize(250, 1) -- Width fixed, height will grow with content
	
	-- Text display
	local text = textFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	text:SetPoint("TOPLEFT", textFrame, "TOPLEFT", 0, 0)
	text:SetWidth(250)
	text:SetJustifyH("LEFT")
	text:SetJustifyV("TOP")
	text:SetText("Initializing...")
	content.text = text
	content:SetScrollChild(textFrame)
	
	frame:Hide()
	_frame = frame
	return frame
end

--[[----------------------------------------------------------------------------
	Data Collection
----------------------------------------------------------------------------]]--

local function GetFPSSmoothed()
	local fps = GetFramerate()
	table.insert(_fpsSamples, fps)
	
	-- Keep only last N samples
	while #_fpsSamples > _maxSamples do
		table.remove(_fpsSamples, 1)
	end
	
	-- Calculate average
	local sum = 0
	for i = 1, #_fpsSamples do
		sum = sum + _fpsSamples[i]
	end
	
	return sum / #_fpsSamples
end

local function GetMemoryUsage()
	-- collectgarbage("count") returns KB
	return collectgarbage("count")
end

local function GetFrameTime()
	local fps = GetFramerate()
	if fps > 0 then
		return (1000 / fps)  -- milliseconds per frame
	end
	return 0
end

local function GetPoolStats()
	local stats = {
		auras = { active = 0, inactive = 0, total = 0 },
		indicators = { active = 0, inactive = 0, total = 0 },
	}
	
	-- Aura pool stats (FramePoolManager)
	if UUF.FramePoolManager then
		local auraStats = UUF.FramePoolManager:GetAllPoolStats()
		if auraStats and auraStats["AuraButton"] then
			local pool = auraStats["AuraButton"]
			stats.auras.active = pool.active or 0
			stats.auras.inactive = pool.inactive or 0
			stats.auras.total = pool.total or 0
		end
	end
	
	-- Indicator pool stats
	if UUF.IndicatorPooling then
		local indicatorStats = UUF.IndicatorPooling:GetStats()
		if indicatorStats then
			for poolName, poolData in pairs(indicatorStats) do
				if type(poolData) == "table" then
					stats.indicators.active = stats.indicators.active + (poolData.active or 0)
					stats.indicators.inactive = stats.indicators.inactive + (poolData.inactive or 0)
					stats.indicators.total = stats.indicators.total + (poolData.total or 0)
				end
			end
		end
	end
	
	return stats
end

local function GetEventStats()
	local stats = {
		coalesced = 0,
		dispatched = 0,
		savingsPercent = 0,
		avgBatchSize = 0,
		maxBatchSize = 0,
		dispatchRatio = 0,
	}
	
	if UUF.EventCoalescer then
		local coalescerStats = UUF.EventCoalescer:GetStats()
		stats.coalesced = coalescerStats.totalCoalesced or 0
		stats.dispatched = coalescerStats.totalDispatched or 0
		stats.savingsPercent = coalescerStats.savingsPercent or 0
		stats.dispatchRatio = stats.coalesced > 0 and (stats.dispatched / stats.coalesced) or 0

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
		stats.avgBatchSize = batchCount > 0 and (batchTotal / batchCount) or 0
		stats.maxBatchSize = batchMax
	end
	
	return stats
end

local function GetDirtyFlagStats()
	local stats = {
		dirtyCount = 0,
		totalTracked = 0,
		invalidations = 0,
	}
	
	if UUF.DirtyFlagManager then
		local dirtyStats = UUF.DirtyFlagManager:GetStats()
		stats.dirtyCount = dirtyStats.dirtyCount or 0
		stats.totalTracked = dirtyStats.totalTracked or 0
		stats.invalidations = dirtyStats.invalidations or 0
	end
	
	return stats
end

local function GetMLStats()
	local stats = {
		available = false,
		patterns = 0,
		delaysLearned = 0,
		currentSequenceLength = 0,
		context = {
			inCombat = false,
			instanceType = "unknown",
			groupSize = 0,
		},
	}

	if UUF.MLOptimizer and UUF.MLOptimizer.GetStats then
		local ok, mlStats = pcall(UUF.MLOptimizer.GetStats, UUF.MLOptimizer)
		if ok and type(mlStats) == "table" then
			stats.available = true
			stats.patterns = mlStats.patterns or 0
			stats.delaysLearned = mlStats.delaysLearned or 0
			stats.currentSequenceLength = mlStats.currentSequenceLength or 0
			if type(mlStats.context) == "table" then
				stats.context.inCombat = mlStats.context.inCombat == true
				stats.context.instanceType = mlStats.context.instanceType or "unknown"
				stats.context.groupSize = mlStats.context.groupSize or 0
			end
		end
	end

	return stats
end

--[[----------------------------------------------------------------------------
	Display Update
----------------------------------------------------------------------------]]--

local function FormatNumber(num)
	if num >= 1000000 then
		return string.format("%.2fM", num / 1000000)
	elseif num >= 1000 then
		return string.format("%.2fK", num / 1000)
	else
		return string.format("%.0f", num)
	end
end

local function UpdateDisplay()
	if not _frame or not _frame:IsVisible() then return end
	
	local now = GetTime()
	if now - _lastUpdate < _updateInterval then return end
	_lastUpdate = now
	
	-- Collect data
	local fps = GetFPSSmoothed()
	local frameTime = GetFrameTime()
	local memory = GetMemoryUsage()
	local poolStats = GetPoolStats()
	local eventStats = GetEventStats()
	local dirtyStats = GetDirtyFlagStats()
	local mlStats = GetMLStats()
	
	-- Build display text
	local lines = {}
	
	-- Performance section
	table.insert(lines, "|cFFFFD700=== Performance ===|r")
	table.insert(lines, string.format("FPS: |cFF00FF00%.1f|r", fps))
	table.insert(lines, string.format("Frame Time: |cFF00FF00%.2fms|r", frameTime))
	table.insert(lines, string.format("Memory: |cFF00FF00%.2f MB|r", memory / 1024))
	table.insert(lines, "")
	
	-- Pool statistics
	table.insert(lines, "|cFFFFD700=== Frame Pools ===|r")
	table.insert(lines, string.format("Aura Frames:"))
	table.insert(lines, string.format("  Active: |cFF00FF00%d|r", poolStats.auras.active))
	table.insert(lines, string.format("  Pooled: |cFFFFFF00%d|r", poolStats.auras.inactive))
	table.insert(lines, string.format("  Total: |cFFAAAAAA%d|r", poolStats.auras.total))
	table.insert(lines, "")
	table.insert(lines, string.format("Indicator Frames:"))
	table.insert(lines, string.format("  Active: |cFF00FF00%d|r", poolStats.indicators.active))
	table.insert(lines, string.format("  Pooled: |cFFFFFF00%d|r", poolStats.indicators.inactive))
	table.insert(lines, string.format("  Total: |cFFAAAAAA%d|r", poolStats.indicators.total))
	table.insert(lines, "")
	
	-- Event coalescing
	if eventStats.coalesced > 0 then
		table.insert(lines, "|cFFFFD700=== Event Coalescing ===|r")
		table.insert(lines, string.format("Events Coalesced: |cFF00FF00%s|r", FormatNumber(eventStats.coalesced)))
		table.insert(lines, string.format("Batches Dispatched: |cFFFFFF00%s|r", FormatNumber(eventStats.dispatched)))
		table.insert(lines, string.format("CPU Savings: |cFF00FF00%.1f%%|r", eventStats.savingsPercent))
		table.insert(lines, string.format("Avg/Max Batch Size: |cFF00FF00%.2f|r / |cFFFFFF00%d|r", eventStats.avgBatchSize, eventStats.maxBatchSize))
		table.insert(lines, string.format("Dispatch Ratio: |cFFAAAAAA%.3f|r", eventStats.dispatchRatio))
		table.insert(lines, "")
	end
	
	-- Dirty flag tracking
	if dirtyStats.totalTracked > 0 then
		table.insert(lines, "|cFFFFD700=== Dirty Flags ===|r")
		table.insert(lines, string.format("Frames Tracked: |cFFAAAAAA%d|r", dirtyStats.totalTracked))
		table.insert(lines, string.format("Dirty Now: |cFFFFFF00%d|r", dirtyStats.dirtyCount))
		table.insert(lines, string.format("Total Invalidations: |cFF00FF00%s|r", FormatNumber(dirtyStats.invalidations)))
		table.insert(lines, "")
	end

	-- ML optimizer stats (/uufml stats)
	if mlStats.available then
		table.insert(lines, "|cFFFFD700=== ML Optimizer ===|r")
		table.insert(lines, string.format("Patterns Learned: |cFF00FF00%d|r", mlStats.patterns))
		table.insert(lines, string.format("Adaptive Delays: |cFFFFFF00%d|r", mlStats.delaysLearned))
		table.insert(lines, string.format("Current Sequence: |cFFAAAAAA%d|r", mlStats.currentSequenceLength))
		table.insert(lines, string.format(
			"Context: |cFFAAAAAA%s (%s, %d members)|r",
			mlStats.context.inCombat and "In Combat" or "Out of Combat",
			mlStats.context.instanceType,
			mlStats.context.groupSize
		))
		table.insert(lines, "")
	end
	
	-- System status
	table.insert(lines, "|cFFFFD700=== System Status ===|r")
	table.insert(lines, string.format("EventBus: %s", UUF.EventBus and "|cFF00FF00Active|r" or "|cFFFF0000Inactive|r"))
	table.insert(lines, string.format("FramePooling: %s", UUF.FramePoolManager and "|cFF00FF00Active|r" or "|cFFFF0000Inactive|r"))
	table.insert(lines, string.format("IndicatorPooling: %s", UUF.IndicatorPooling and "|cFF00FF00Active|r" or "|cFFFF0000Inactive|r"))
	table.insert(lines, string.format("EventCoalescer: %s", UUF.EventCoalescer and "|cFF00FF00Active|r" or "|cFFFF0000Inactive|r"))
	table.insert(lines, string.format("DirtyFlags: %s", UUF.DirtyFlagManager and "|cFF00FF00Active|r" or "|cFFFF0000Inactive|r"))
	table.insert(lines, string.format("MLOptimizer: %s", UUF.MLOptimizer and "|cFF00FF00Active|r" or "|cFFFF0000Inactive|r"))
	table.insert(lines, string.format("ReactiveConfig: %s", UUF.ReactiveConfig and "|cFF00FF00Active|r" or "|cFFFF0000Inactive|r"))
	table.insert(lines, "")
	
	-- Footer
	table.insert(lines, "|cFFAAAAAA(Drag to move)|r")
	
	-- Update text
	local text = _frame.content.text
	text:SetText(table.concat(lines, "\n"))
	
	-- Update scroll child height to match text content
	local textHeight = text:GetStringHeight()
	text:GetParent():SetHeight(math.max(textHeight + 10, 1))
end

--[[----------------------------------------------------------------------------
	Public API
----------------------------------------------------------------------------]]--

--- Show the performance dashboard
function PerformanceDashboard:Show()
	local frame = CreateDashboardFrame()
	frame:Show()
	_isVisible = true
	
	-- Start update loop
	if not self._updateTimer then
		self._updateTimer = C_Timer.NewTicker(_updateInterval, function()
			UpdateDisplay()
		end)
	end
	
	-- Immediate first update
	UpdateDisplay()
end

--- Hide the performance dashboard
function PerformanceDashboard:Hide()
	if _frame then
		_frame:Hide()
		_isVisible = false
	end
	
	-- Stop update loop
	if self._updateTimer then
		self._updateTimer:Cancel()
		self._updateTimer = nil
	end
end

--- Toggle the performance dashboard
function PerformanceDashboard:Toggle()
	if _isVisible then
		self:Hide()
	else
		self:Show()
	end
end

--- Check if dashboard is visible
-- @return boolean
function PerformanceDashboard:IsVisible()
	return _isVisible
end

--- Set update interval
-- @param interval number - Update interval in seconds (default 1.0)
function PerformanceDashboard:SetUpdateInterval(interval)
	_updateInterval = math.max(0.1, interval or 1.0)
	
	-- Restart timer if running
	if self._updateTimer then
		self._updateTimer:Cancel()
		self._updateTimer = C_Timer.NewTicker(_updateInterval, function()
			UpdateDisplay()
		end)
	end
end

--- Initialize the performance dashboard
function PerformanceDashboard:Init()
	-- Register slash command
	SLASH_UUFPERF1 = "/uufperf"
	SlashCmdList["UUFPERF"] = function(msg)
		if msg == "show" then
			PerformanceDashboard:Show()
		elseif msg == "hide" then
			PerformanceDashboard:Hide()
		else
			PerformanceDashboard:Toggle()
		end
	end
	
	print("|cFF00B0F7UnhaltedUnitFrames: Performance Dashboard initialized. Use /uufperf to toggle.|r")
end

--- Print current performance statistics to chat
function PerformanceDashboard:PrintStats()
	local fps = GetFramerate()
	local _, _, latencyHome, latencyWorld = GetNetStats()
	local memory, gcCount = GetMemoryUsage(true), collectgarbage("count")
	
	print("|cFF00B0F7=== Performance Stats ===|r")
	print(string.format("FPS: |cFF00FF00%.1f|r", fps))
	print(string.format("Latency: Home |cFFFFFF00%d|rms, World |cFFFFFF00%d|rms", latencyHome, latencyWorld))
	print(string.format("Memory: |cFFFFFF00%.2f|r MB", memory / 1024))
	
	-- Pool stats
	if UUF.FramePoolManager then
		local diag = UUF.FramePoolManager:GetDiagnostics()
		print(string.format("Frame Pools: |cFF00FF00%d|r pools, |cFFFFFF00%d|r active, |cFF888888%d|r total", 
			diag.poolCount, diag.totalActive, diag.totalFrames))
	end
	
	-- Event coalescing stats
	if UUF.EventCoalescer then
		local stats = UUF.EventCoalescer:GetStats()
		if (stats.totalCoalesced or 0) > 0 then
			local batchCount = 0
			local batchTotal = 0
			local batchMax = 0
			for _, batch in pairs(stats.batchSizes or {}) do
				local count = batch.count or 0
				local avg = batch.avg or 0
				batchCount = batchCount + count
				batchTotal = batchTotal + (avg * count)
				if (batch.max or 0) > batchMax then
					batchMax = batch.max
				end
			end
			local avgBatchSize = batchCount > 0 and (batchTotal / batchCount) or 0
			print(string.format("Event Coalescing: |cFF00FF00%.1f%%|r saved (%d events, %d batches)",
				stats.savingsPercent or 0, stats.totalCoalesced or 0, stats.totalDispatched or 0))
			print(string.format("Batch Size: avg |cFF00FF00%.2f|r, max |cFFFFFF00%d|r", avgBatchSize, batchMax))
		end
	end
end

--- Validate the performance dashboard
-- @return boolean - Valid
-- @return string - Message
function PerformanceDashboard:Validate()
	if not UUF.PerformanceDashboard then
		return false, "PerformanceDashboard not loaded"
	end
	
	-- Test frame creation
	local frame = CreateDashboardFrame()
	if not frame then
		return false, "Cannot create dashboard frame"
	end
	
	return true, "PerformanceDashboard operational"
end

return PerformanceDashboard
