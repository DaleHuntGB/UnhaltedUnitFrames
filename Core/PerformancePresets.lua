--[[============================================================================
	PerformancePresets.lua
	Performance presets and auto-optimization system
	
	Features:
	- Pre-configured performance presets (Low, Medium, High, Ultra)
	- Automatic FPS-based optimization
	- Dynamic system recommendations
	- Per-preset configuration profiles
	
	Usage:
		UUF.PerformancePresets:ApplyPreset("High")
		UUF.PerformancePresets:EnableAutoOptimization()
============================================================================]]--

local UUF = select(2, ...)
local PerformancePresets = {}
UUF.PerformancePresets = PerformancePresets

-- Performance locals
local GetFramerate = GetFramerate
local math = math
local pairs = pairs

-- Presets configuration
local PRESETS = {
	Low = {
		name = "Low Performance",
		description = "Maximum performance, minimal features. For low-end systems or large raids.",
		targetFPS = 60,
		settings = {
			-- Event coalescing
			eventCoalesceDelay = 0.1,  -- 100ms (very aggressive)
			
			-- Dirty flags
			dirtyProcessDelay = 0.2,   -- 200ms batching
			dirtyMaxPerBatch = 5,      -- Process fewer per frame
			
			-- Frame pooling
			auraPoolSize = 30,         -- Smaller pool
			indicatorPoolSize = 15,
			
			-- Dashboard
			dashboardUpdateInterval = 2.0,  -- Update less frequently
			
			-- Features
			enableAuraPooling = true,
			enableIndicatorPooling = true,
			enableEventCoalescing = true,
			enableDirtyFlags = true,
			enableReactiveConfig = false,  -- Disable for performance
		},
	},
	
	Medium = {
		name = "Medium Performance",
		description = "Balanced performance and features. Recommended for most users.",
		targetFPS = 60,
		settings = {
			eventCoalesceDelay = 0.05,  -- 50ms (standard)
			dirtyProcessDelay = 0.1,    -- 100ms
			dirtyMaxPerBatch = 10,
			auraPoolSize = 60,
			indicatorPoolSize = 30,
			dashboardUpdateInterval = 1.0,
			enableAuraPooling = true,
			enableIndicatorPooling = true,
			enableEventCoalescing = true,
			enableDirtyFlags = true,
			enableReactiveConfig = true,
		},
	},
	
	High = {
		name = "High Performance",
		description = "Optimized for high-end systems. All features enabled with optimal settings.",
		targetFPS = 144,
		settings = {
			eventCoalesceDelay = 0.033,  -- 33ms (less aggressive)
			dirtyProcessDelay = 0.05,    -- 50ms
			dirtyMaxPerBatch = 15,
			auraPoolSize = 100,
			indicatorPoolSize = 50,
			dashboardUpdateInterval = 0.5,
			enableAuraPooling = true,
			enableIndicatorPooling = true,
			enableEventCoalescing = true,
			enableDirtyFlags = true,
			enableReactiveConfig = true,
		},
	},
	
	Ultra = {
		name = "Ultra Performance",
		description = "Maximum smoothness for high-refresh displays. Requires powerful hardware.",
		targetFPS = 240,
		settings = {
			eventCoalesceDelay = 0.016,  -- 16ms (minimal batching)
			dirtyProcessDelay = 0.016,   -- 16ms
			dirtyMaxPerBatch = 20,
			auraPoolSize = 150,
			indicatorPoolSize = 75,
			dashboardUpdateInterval = 0.25,
			enableAuraPooling = true,
			enableIndicatorPooling = true,
			enableEventCoalescing = true,
			enableDirtyFlags = true,
			enableReactiveConfig = true,
		},
	},
}

-- Current state
local _currentPreset = "Medium"
local _autoOptimizationEnabled = false
local _lastFPSCheck = 0
local _fpsHistory = {}

-- Auto-optimization configuration
local FPS_CHECK_INTERVAL = 5  -- Check FPS every 5 seconds
local FPS_HISTORY_SIZE = 12   -- Store last 12 samples (1 minute)
local AUTO_ADJUST_THRESHOLD = 10  -- FPS difference threshold for preset change

--[[----------------------------------------------------------------------------
	Public API
----------------------------------------------------------------------------]]--

--- Apply a performance preset
-- @param presetName string - "Low", "Medium", "High", or "Ultra"
-- @return boolean - Success
function PerformancePresets:ApplyPreset(presetName)
	local preset = PRESETS[presetName]
	if not preset then
		print("|cFFFF0000PerformancePresets: Unknown preset " .. presetName .. "|r")
		return false
	end
	
	_currentPreset = presetName
	
	-- Apply settings
	local settings = preset.settings
	
	-- EventCoalescer settings
	if UUF.EventCoalescer and settings.enableEventCoalescing then
		-- Would apply coalesce delay settings
	end
	
	-- DirtyFlagManager settings
	if UUF.DirtyFlagManager and settings.enableDirtyFlags then
		UUF.DirtyFlagManager:SetAutoProcessDelay(settings.dirtyProcessDelay)
		UUF.DirtyFlagManager:SetMaxProcessPerFrame(settings.dirtyMaxPerBatch)
	end
	
	-- PerformanceDashboard settings
	if UUF.PerformanceDashboard then
		UUF.PerformanceDashboard:SetUpdateInterval(settings.dashboardUpdateInterval)
	end
	
	-- FramePoolManager settings
	if UUF.FramePoolManager then
		-- Would adjust pool sizes
	end
	
	print(string.format("|cFF00B0F7PerformancePresets: Applied '%s' preset|r", preset.name))
	print(string.format("  Target FPS: %d", preset.targetFPS))
	print(string.format("  Description: %s", preset.description))
	
	return true
end

--- Get current preset name
-- @return string
function PerformancePresets:GetCurrentPreset()
	return _currentPreset
end

--- Get all available presets
-- @return table - { [name] = preset }
function PerformancePresets:GetAvailablePresets()
	return PRESETS
end

--- Enable automatic FPS-based optimization
function PerformancePresets:EnableAutoOptimization()
	if _autoOptimizationEnabled then
		print("|cFFFFFF00PerformancePresets: Auto-optimization already enabled|r")
		return
	end
	
	_autoOptimizationEnabled = true
_fpsHistory = {}
	
	print("|cFF00B0F7PerformancePresets: Auto-optimization enabled|r")
	print("  Will automatically adjust settings based on FPS")
end

--- Disable automatic optimization
function PerformancePresets:DisableAutoOptimization()
	_autoOptimizationEnabled = false
	print("|cFF00B0F7PerformancePresets: Auto-optimization disabled|r")
end

--- Check if auto-optimization is enabled
-- @return boolean
function PerformancePresets:IsAutoOptimizationEnabled()
	return _autoOptimizationEnabled
end

--- Get performance recommendations based on current FPS
-- @return table - Array of recommendations
function PerformancePresets:GetRecommendations()
	local currentFPS = GetFramerate()
	local currentPreset = PRESETS[_currentPreset]
	local recommendations = {}
	
	if not currentPreset then
		return recommendations
	end
	
	local targetFPS = currentPreset.targetFPS
	local fpsDiff = targetFPS - currentFPS
	
	-- Low FPS recommendations
	if currentFPS < 30 then
		table.insert(recommendations, {
			priority = "critical",
			category = "performance",
			message = string.format("FPS is critically low (%.1f). Consider switching to 'Low' preset.", currentFPS),
			action = function() PerformancePresets:ApplyPreset("Low") end,
		})
	elseif currentFPS < 45 and _currentPreset ~= "Low" then
		table.insert(recommendations, {
			priority = "high",
			category = "performance",
			message = string.format("FPS is below target (%.1f vs %d). Consider a lower preset.", 
				currentFPS, targetFPS),
			action = function() 
				if _currentPreset == "Ultra" then
					PerformancePresets:ApplyPreset("High")
				elseif _currentPreset == "High" then
					PerformancePresets:ApplyPreset("Medium")
				elseif _currentPreset == "Medium" then
					PerformancePresets:ApplyPreset("Low")
				end
			end,
		})
	end
	
	-- High FPS - can upgrade preset
	if currentFPS > targetFPS + 30 and _currentPreset ~= "Ultra" then
		table.insert(recommendations, {
			priority = "low",
			category = "features",
			message = string.format("FPS is well above target (%.1f vs %d). Consider a higher preset for more features.", 
				currentFPS, targetFPS),
			action = function()
				if _currentPreset == "Low" then
					PerformancePresets:ApplyPreset("Medium")
				elseif _currentPreset == "Medium" then
					PerformancePresets:ApplyPreset("High")
				elseif _currentPreset == "High" then
					PerformancePresets:ApplyPreset("Ultra")
				end
			end,
		})
	end
	
	-- Event coalescing recommendations
	if UUF.EventCoalescer then
		local coalescerStats = UUF.EventCoalescer:GetStats()
		if coalescerStats.savingsPercent < 20 then
			table.insert(recommendations, {
				priority = "medium",
				category = "optimization",
				message = "Event coalescing savings are low. Consider more aggressive batching.",
			})
		end
	end
	
	-- Pool recommendations
	if UUF.FramePoolManager then
		local poolStats = UUF.FramePoolManager:GetAllPoolStats()
		for poolName, stats in pairs(poolStats) do
			if stats.total > 0 and (stats.active / stats.total) > 0.8 then
				table.insert(recommendations, {
					priority = "medium",
					category = "memory",
					message = string.format("Pool '%s' is above 80%% usage. Consider increasing size.", poolName),
				})
			end
		end
	end
	
	return recommendations
end

--- Print recommendations
function PerformancePresets:PrintRecommendations()
	local recommendations = self:GetRecommendations()
	
	if #recommendations == 0 then
		print("|cFF00FF00PerformancePresets: No recommendations. Performance is optimal!|r")
		return
	end
	
	print("|cFF00B0F7=== Performance Recommendations ===|r")
	for _, rec in ipairs(recommendations) do
		local color = "FFFFFF"
		if rec.priority == "critical" then
			color = "FF0000"
		elseif rec.priority == "high" then
			color = "FFAA00"
		elseif rec.priority == "medium" then
			color = "FFFF00"
		end
		
		print(string.format("|cFF%s[%s] %s|r", color, rec.priority:upper(), rec.message))
	end
end

--- Apply recommended optimizations automatically
-- @return number - Number of recommendations applied
function PerformancePresets:ApplyRecommendations()
	local recommendations = self:GetRecommendations()
	local appliedCount = 0
	
	for _, rec in ipairs(recommendations) do
		if rec.action and rec.priority ~= "low" then
			rec.action()
			appliedCount = appliedCount + 1
		end
	end
	
	if appliedCount > 0 then
		print(string.format("|cFF00B0F7PerformancePresets: Applied %d recommendations|r", appliedCount))
	end
	
	return appliedCount
end

--[[----------------------------------------------------------------------------
	Auto-Optimization Logic
----------------------------------------------------------------------------]]--

function PerformancePresets:_CheckAndOptimize()
	if not _autoOptimizationEnabled then return end
	
	local now = GetTime()
	if now - _lastFPSCheck < FPS_CHECK_INTERVAL then
		return
	end
	
	_lastFPSCheck = now
	local currentFPS = GetFramerate()
	
	-- Store in history
	table.insert(_fpsHistory, currentFPS)
	while #_fpsHistory > FPS_HISTORY_SIZE do
		table.remove(_fpsHistory, 1)
	end
	
	-- Need enough history
	if #_fpsHistory < 3 then
		return
	end
	
	-- Calculate average FPS
	local avgFPS = 0
	for _, fps in ipairs(_fpsHistory) do
		avgFPS = avgFPS + fps
	end
	avgFPS = avgFPS / #_fpsHistory
	
	-- Get current preset target
	local currentPreset = PRESETS[_currentPreset]
	if not currentPreset then return end
	
	local targetFPS = currentPreset.targetFPS
	local fpsDiff = targetFPS - avgFPS
	
	-- Auto-adjust if significantly below target
	if fpsDiff > AUTO_ADJUST_THRESHOLD then
		print(string.format("|cFFFFFF00PerformancePresets: Auto-optimization detected low FPS (%.1f vs %d target)|r", 
			avgFPS, targetFPS))
		
		-- Downgrade preset
		if _currentPreset == "Ultra" then
			self:ApplyPreset("High")
		elseif _currentPreset == "High" then
			self:ApplyPreset("Medium")
		elseif _currentPreset == "Medium" then
			self:ApplyPreset("Low")
		end
	elseif fpsDiff < -30 and _currentPreset ~= "Ultra" then
		-- FPS is well above target, consider upgrading (but be conservative)
		if #_fpsHistory >= FPS_HISTORY_SIZE then  -- Only upgrade if sustained
			print(string.format("|cFF00B0F7PerformancePresets: Performance headroom detected (%.1f vs %d target)|r", 
				avgFPS, targetFPS))
			
			if _currentPreset == "Low" then
				self:ApplyPreset("Medium")
			elseif _currentPreset == "Medium" then
				self:ApplyPreset("High")
			elseif _currentPreset == "High" then
				self:ApplyPreset("Ultra")
			end
		end
	end
end

--[[----------------------------------------------------------------------------
	Initialization
----------------------------------------------------------------------------]]--

function PerformancePresets:Init()
	-- Apply default preset
	self:ApplyPreset(_currentPreset)
	
	-- Start auto-optimization ticker
	C_Timer.NewTicker(FPS_CHECK_INTERVAL, function()
		self:_CheckAndOptimize()
	end)
	
	-- Register slash commands
	SLASH_UUFPRESET1 = "/uufpreset"
	SlashCmdList["UUFPRESET"] = function(msg)
		if msg == "low" or msg == "Low" then
			PerformancePresets:ApplyPreset("Low")
		elseif msg == "medium" or msg == "Medium" or msg == "" then
			PerformancePresets:ApplyPreset("Medium")
		elseif msg == "high" or msg == "High" then
			PerformancePresets:ApplyPreset("High")
		elseif msg == "ultra" or msg == "Ultra" then
			PerformancePresets:ApplyPreset("Ultra")
		elseif msg == "auto on" then
			PerformancePresets:EnableAutoOptimization()
		elseif msg == "auto off" then
			PerformancePresets:DisableAutoOptimization()
		elseif msg == "recommend" then
			PerformancePresets:PrintRecommendations()
		elseif msg == "apply" then
			PerformancePresets:ApplyRecommendations()
		else
			print("|cFF00B0F7PerformancePresets Commands:|r")
			print("  /uufpreset low|medium|high|ultra - Apply preset")
			print("  /uufpreset auto on|off - Toggle auto-optimization")
			print("  /uufpreset recommend - Show recommendations")
			print("  /uufpreset apply - Apply recommendations")
		end
	end
	
	print("|cFF00B0F7UnhaltedUnitFrames: PerformancePresets initialized (Current: " .. _currentPreset .. ")|r")
end

function PerformancePresets:Validate()
	if not UUF.PerformancePresets then
		return false, "PerformancePresets not loaded"
	end
	
	return true, "PerformancePresets operational"
end

return PerformancePresets
