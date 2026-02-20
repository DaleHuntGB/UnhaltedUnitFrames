--[[============================================================================
	DirtyPriorityOptimizer.lua
	Intelligent dirty flag priority optimization based on gameplay data
	
	Learns from actual update patterns to automatically adjust dirty flag
	priorities for optimal frame update ordering.
	
	Features:
	- Tracks update frequency per frame/reason
	- Automatically adjusts priorities based on importance
	- Learns in-combat vs out-of-combat patterns
	- Provides recommendations for manual tuning
	
	Usage:
		-- Automatically integrated with DirtyFlagManager
		UUF.DirtyPriorityOptimizer:GetRecommendations()
============================================================================]]--

local UUF = select(2, ...)
local DirtyPriorityOptimizer = {}
UUF.DirtyPriorityOptimizer = DirtyPriorityOptimizer

-- Performance locals
local GetTime = GetTime
local pairs = pairs
local math = math

-- Learning data
local _learningData = {
	reasonFrequency = {},      -- [reason] = count
	reasonLastSeen = {},       -- [reason] = timestamp
	reasonInCombat = {},       -- [reason] = count in combat
	reasonOutOfCombat = {},    -- [reason] = count out of combat
	totalUpdates = 0,
	inCombatUpdates = 0,
	outOfCombatUpdates = 0,
}

-- Priority recommendations
local _recommendations = {}

-- Configuration
local LEARNING_WINDOW = 300  -- 5 minutes

-- Priority scoring weights
local WEIGHTS = {
	frequency = 0.4,      -- How often it occurs
	recency = 0.2,        -- How recently it occurred
	combatRatio = 0.3,    -- Ratio of combat vs non-combat
	baseImportance = 0.1, -- Base priority from config
}

--[[----------------------------------------------------------------------------
	Public API
----------------------------------------------------------------------------]]--

--- Track a dirty flag event for learning
-- @param reason string - Reason for dirty marking
-- @param inCombat boolean - Whether in combat
function DirtyPriorityOptimizer:TrackEvent(reason, inCombat)
	-- Update frequency
	_learningData.reasonFrequency[reason] = (_learningData.reasonFrequency[reason] or 0) + 1
	_learningData.reasonLastSeen[reason] = GetTime()
	_learningData.totalUpdates = _learningData.totalUpdates + 1
	
	-- Update combat tracking
	if inCombat then
		_learningData.reasonInCombat[reason] = (_learningData.reasonInCombat[reason] or 0) + 1
		_learningData.inCombatUpdates = _learningData.inCombatUpdates + 1
	else
		_learningData.reasonOutOfCombat[reason] = (_learningData.reasonOutOfCombat[reason] or 0) + 1
		_learningData.outOfCombatUpdates = _learningData.outOfCombatUpdates + 1
	end
end

--- Calculate optimal priority for a reason
-- @param reason string
-- @param basePriority number - Base priority (1-5)
-- @return number - Recommended priority (1-5)
function DirtyPriorityOptimizer:CalculateOptimalPriority(reason, basePriority)
	basePriority = basePriority or 3
	
	-- If no learning data, use base
	if not _learningData.reasonFrequency[reason] then
		return basePriority
	end
	
	local frequency = _learningData.reasonFrequency[reason]
	local inCombatCount = _learningData.reasonInCombat[reason] or 0
	local outOfCombatCount = _learningData.reasonOutOfCombat[reason] or 0
	local lastSeen = _learningData.reasonLastSeen[reason] or 0
	local now = GetTime()
	
	-- Calculate scores (0-1 range)
	local frequencyScore = math.min(1, frequency / 100)  -- Normalize to 100 updates
	local recencyScore = math.max(0, 1 - ((now - lastSeen) / LEARNING_WINDOW))
	
	-- Combat ratio score (higher = more important in combat)
	local combatRatio = 0.5
	if (inCombatCount + outOfCombatCount) > 0 then
		combatRatio = inCombatCount / (inCombatCount + outOfCombatCount)
	end
	
	-- Base importance score (normalized)
	local baseScore = basePriority / 5
	
	-- Weighted total
	local totalScore = 
		(frequencyScore * WEIGHTS.frequency) +
		(recencyScore * WEIGHTS.recency) +
		(combatRatio * WEIGHTS.combatRatio) +
		(baseScore * WEIGHTS.baseImportance)
	
	-- Convert to 1-5 priority
	local recommendedPriority = math.floor(totalScore * 5) + 1
	recommendedPriority = math.max(1, math.min(5, recommendedPriority))
	
	return recommendedPriority
end

--- Get priority recommendations for all tracked reasons
-- @return table - { [reason] = { current = number, recommended = number, score = number } }
function DirtyPriorityOptimizer:GetRecommendations()
	local recommendations = {}
	
	for reason, frequency in pairs(_learningData.reasonFrequency) do
		-- Extract base priority from reason if available
		local basePriority = 3  -- Default
		
		-- Try to extract priority from DirtyFlagManager if available
		-- (This is a simplified approach)
		
		local recommended = self:CalculateOptimalPriority(reason, basePriority)
		
		recommendations[reason] = {
			frequency = frequency,
			basePriority = basePriority,
			recommendedPriority = recommended,
			inCombat = _learningData.reasonInCombat[reason] or 0,
			outOfCombat = _learningData.reasonOutOfCombat[reason] or 0,
		}
	end
	
	_recommendations = recommendations
	return recommendations
end

--- Print recommendations
function DirtyPriorityOptimizer:PrintRecommendations()
	local recommendations = self:GetRecommendations()
	
	print("|cFF00B0F7=== Dirty Priority Recommendations ===|r")
	print(string.format("Total Updates Tracked: %d", _learningData.totalUpdates))
	print(string.format("In Combat: %d | Out of Combat: %d", 
		_learningData.inCombatUpdates, 
		_learningData.outOfCombatUpdates))
	print("")
	
	-- Sort by recommended priority (descending)
	local sortedReasons = {}
	for reason, data in pairs(recommendations) do
		table.insert(sortedReasons, {reason = reason, data = data})
	end
	
	table.sort(sortedReasons, function(a, b)
		return a.data.recommendedPriority > b.data.recommendedPriority
	end)
	
	print("|cFFFFD700Top Priority Reasons:|r")
	for i = 1, math.min(10, #sortedReasons) do
		local item = sortedReasons[i]
		local data = item.data
		print(string.format("  [P%d] %s (freq: %d, combat: %d%%)",
			data.recommendedPriority,
			item.reason,
			data.frequency,
			math.floor((data.inCombat / (data.inCombat + data.outOfCombat)) * 100)
		))
	end
end

--- Apply recommendations to DirtyFlagManager
-- @return number - Number of priorities updated
function DirtyPriorityOptimizer:ApplyRecommendations()
	if not UUF.DirtyFlagManager then
		return 0
	end
	
	local recommendations = self:GetRecommendations()
	local appliedCount = 0
	
	-- This would require DirtyFlagManager to support priority overrides
	-- For now, just log the recommendations
	print("|cFF00B0F7DirtyPriorityOptimizer: Recommendations calculated (manual application required)|r")
	
	return appliedCount
end

--- Reset learning data
function DirtyPriorityOptimizer:ResetLearning()
	_learningData = {
		reasonFrequency = {},
		reasonLastSeen = {},
		reasonInCombat = {},
		reasonOutOfCombat = {},
		totalUpdates = 0,
		inCombatUpdates = 0,
		outOfCombatUpdates = 0,
	}
	_recommendations = {}
	print("|cFF00B0F7DirtyPriorityOptimizer: Learning data reset|r")
end

--- Get learning statistics
-- @return table - Statistics
function DirtyPriorityOptimizer:GetStats()
	return {
		totalUpdates = _learningData.totalUpdates,
		inCombatUpdates = _learningData.inCombatUpdates,
		outOfCombatUpdates = _learningData.outOfCombatUpdates,
		reasonsTracked = 0,  -- Count reasons
	}
end

--[[----------------------------------------------------------------------------
	Integration
----------------------------------------------------------------------------]]--

--- Integrate with DirtyFlagManager to track events
function DirtyPriorityOptimizer:IntegrateWithDirtyFlags()
	if not UUF.DirtyFlagManager then
		return false
	end
	
	-- Hook MarkDirty to track events
	local originalMarkDirty = UUF.DirtyFlagManager.MarkDirty
	UUF.DirtyFlagManager.MarkDirty = function(self, frame, reason, priority)
		-- Track for learning
		local inCombat = InCombatLockdown()
		UUF.DirtyPriorityOptimizer:TrackEvent(reason or "unknown", inCombat)
		
		-- Use optimized priority if available
		if priority and UUF.DirtyPriorityOptimizer then
			local optimized = UUF.DirtyPriorityOptimizer:CalculateOptimalPriority(reason, priority)
			priority = optimized
		end
		
		-- Call original
		return originalMarkDirty(self, frame, reason, priority)
	end
	
	print("|cFF00B0F7DirtyPriorityOptimizer: Integrated with DirtyFlagManager|r")
	return true
end

--- Initialize the optimizer
function DirtyPriorityOptimizer:Init()
	-- Integrate with DirtyFlagManager
	if UUF.DirtyFlagManager then
		self:IntegrateWithDirtyFlags()
	end
	
	-- Schedule periodic recommendation updates
	C_Timer.NewTicker(60, function()  -- Every 60 seconds
		self:GetRecommendations()
	end)
	
	print("|cFF00B0F7UnhaltedUnitFrames: DirtyPriorityOptimizer initialized|r")
end

--- Validate the optimizer
-- @return boolean - Valid
-- @return string - Message
function DirtyPriorityOptimizer:Validate()
	if not UUF.DirtyPriorityOptimizer then
		return false, "DirtyPriorityOptimizer not loaded"
	end
	
	return true, "DirtyPriorityOptimizer operational"
end

return DirtyPriorityOptimizer
