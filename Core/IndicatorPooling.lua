local _, UUF = ...

-- PERF LOCALS: Localize frequently-called globals for faster access
local type, pairs, ipairs = type, pairs, ipairs

-- Indicator Pooling System: Pre-allocated frames for visual indicators
-- Indicators like threat, totems, power prediction, etc. are high-frequency elements
-- that can benefit from pooling to reduce memory churn and GC pressure

local IndicatorPooling = {}
UUF.IndicatorPooling = IndicatorPooling

-- Pool configuration for each indicator type
local POOL_CONFIGS = {
    -- Threat indicator (one per frame)
    Threat = {
        name = "THREAT_INDICATOR",
        size = 15,
        preAllocate = 30,  -- Player, Target, Party(5), Boss(5), Focus, FocusTarget, Targettarget, Pet, etc.
    },
    
    -- Totems (shaman only, but pre-allocate for all classes)
    Totems = {
        name = "TOTEM_ICONS",
        size = 25,
        preAllocate = 16,  -- 4 totems × 4 possible arrangements
    },
    
    -- PvP indicators
    PvPIndicator = {
        name = "PVP_INDICATOR",
        size = 20,
        preAllocate = 30,
    },
    
    -- Power Prediction bars
    PowerPrediction = {
        name = "POWER_BARS",
        size = 40,
        preAllocate = 20,
    },
    
    -- Aura Highlight (dispel effect)
    DispelHighlight = {
        name = "DISPEL_HIGHLIGHTS",
        size = 30,
        preAllocate = 15,
    },
    
    -- Heal Prediction
    HealPrediction = {
        name = "HEAL_BARS",
        size = 40,
        preAllocate = 15,
    },
    
    -- Portrait indicators
    Portrait = {
        name = "PORT_INDICATORS",
        size = 50,
        preAllocate = 20,
    },
    
    -- Runes (death knight)
    Runes = {
        name = "RUNE_FRAMES",
        size = 30,
        preAllocate = 8,  -- 6 runes
    },
}

-- Initialize all pools
function IndicatorPooling:InitializePools()
    if self._poolsInitialized then return end
    
    print("|cFF00B0F7Initializing indicator pools for performance...|r")
    
    for indicatorType, config in pairs(POOL_CONFIGS) do
        local pool = UUF.FramePoolManager:GetOrCreatePool(
            config.name,
            "Frame",
            UIParent,
            nil,
            config.preAllocate
        )
        
        if pool then
            print("|cFF00FF00✓|r Pool initialized: " .. config.name .. " (" .. config.preAllocate .. " frames)")
        else
            print("|cFFFF4040✗|r Failed to initialize: " .. config.name)
        end
    end
    
    self._poolsInitialized = true
end

-- Acquire frame from specific indicator pool
function IndicatorPooling:AcquireIndicator(indicatorType)
    if not POOL_CONFIGS[indicatorType] then
        print("IndicatorPooling: Unknown indicator type: " .. indicatorType)
        return CreateFrame("Frame")  -- Fallback to normal frame creation
    end
    
    local poolName = POOL_CONFIGS[indicatorType].name
    local frame = UUF.FramePoolManager:Acquire(poolName)
    
    if not frame then
        print("IndicatorPooling: Pool exhausted for " .. indicatorType .. ", creating new frame")
        return CreateFrame("Frame")
    end
    
    return frame
end

-- Release frame back to pool
function IndicatorPooling:ReleaseIndicator(indicatorType, frame)
    if not frame or not POOL_CONFIGS[indicatorType] then return end
    
    frame:ClearAllPoints()
    frame:Hide()
    frame:SetAlpha(1)
    frame:SetScale(1)
    
    local poolName = POOL_CONFIGS[indicatorType].name
    UUF.FramePoolManager:Release(poolName, frame)
end

-- Release all indicators for a frame
function IndicatorPooling:ReleaseAllForFrame(unitFrame)
    if not unitFrame or not unitFrame._indicatorFrames then return end
    
    for indicatorType, frame in pairs(unitFrame._indicatorFrames) do
        self:ReleaseIndicator(indicatorType, frame)
    end
    
    unitFrame._indicatorFrames = {}
end

-- Track indicator frame for cleanup
function IndicatorPooling:TrackIndicator(unitFrame, indicatorType, frame)
    if not unitFrame then return end
    unitFrame._indicatorFrames = unitFrame._indicatorFrames or {}
    unitFrame._indicatorFrames[indicatorType] = frame
end

-- Print pool statistics
function IndicatorPooling:PrintPoolStats()
    print("|cFF00B0F7=== Indicator Pool Statistics ===|r")
    for indicatorType, config in pairs(POOL_CONFIGS) do
        local stats = UUF.FramePoolManager:GetPoolStats(config.name)
        if stats and stats.acquired then
            print(string.format("%s: Acquired=%d, Max Active=%d", config.name, stats.acquired, stats.maxActive or 0))
        else
            print(config.name .. ": Not initialized")
        end
    end
end

-- Get pool statistics (for dashboard/monitoring)
function IndicatorPooling:GetStats()
    local stats = {}
	local allPoolStats = UUF.FramePoolManager:GetAllPoolStats()
	
	for indicatorType, config in pairs(POOL_CONFIGS) do
		if allPoolStats[config.name] then
			stats[config.name] = allPoolStats[config.name]
		else
				stats[config.name] = {
					active = 0,
					inactive = 0,
					total = 0,
					acquired = 0,
					released = 0,
					maxActive = 0,
				}
		end
	end
	return stats
end

-- Get recommended pool sizes
function IndicatorPooling:GetPoolSizeRecommendations()
    local recommendations = {}
    
    -- Calculate based on current frame setup
    local frameCount = 0
    if UUF.PLAYER then frameCount = frameCount + 1 end
    if UUF.TARGET then frameCount = frameCount + 1 end
    if UUF.TARGETTARGET then frameCount = frameCount + 1 end
    if UUF.FOCUS then frameCount = frameCount + 1 end
    if UUF.FOCUSTARGET then frameCount = frameCount + 1 end
    if UUF.PET then frameCount = frameCount + 1 end
    
    -- Party frames
    for i = 1, UUF.MAX_PARTY_MEMBERS or 5 do
        if UUF["PARTY"..i] then frameCount = frameCount + 1 end
    end
    
    -- Boss frames
    for i = 1, UUF.MAX_BOSS_FRAMES or 5 do
        if UUF["BOSS"..i] then frameCount = frameCount + 1 end
    end
    
    -- Threat: 1 per frame
    recommendations.Threat = frameCount
    
    -- Most others: roughly 1.5x frame count for safety margin
    recommendations.PvPIndicator = math.ceil(frameCount * 1.5)
    recommendations.DispelHighlight = math.ceil(frameCount * 1.2)
    recommendations.HealPrediction = math.ceil(frameCount * 1.3)
    recommendations.Portrait = math.ceil(frameCount * 1.2)
    
    -- Totems: 4 + buffer
    recommendations.Totems = 8
    
    -- Death knight runes: 6 + buffer
    recommendations.Runes = 8
    
    -- PowerPrediction and HealPrediction bars
    recommendations.PowerPrediction = math.ceil(frameCount * 1.5)
    
    return recommendations
end

-- Adjust pool sizes based on actual usage
function IndicatorPooling:OptimizePoolSizes()
    local recommendations = self:GetPoolSizeRecommendations()
    
    print("|cFF00B0F7Optimizing indicator pool sizes...|r")
    for indicatorType, recommendedSize in pairs(recommendations) do
        local config = POOL_CONFIGS[indicatorType]
        if config then
            local currentSize = config.preAllocate
            if recommendedSize > currentSize then
                print(string.format("Recommendation: %s increase from %d to %d", indicatorType, currentSize, recommendedSize))
            end
        end
    end
end

-- Event listener for frame cleanup
function IndicatorPooling:RegisterCleanupHooks()
    if self._hooksRegistered then return end
    
    -- Hook frame destruction to release indicator pools
    local originalUpdateAllFrames = UUF.UpdateAllUnitFrames
    UUF.UpdateAllUnitFrames = function()
        -- Cleanup old frames before update
        for unit, frame in pairs(UUF.Frames or {}) do
            if frame and frame._indicatorFrames then
                -- Mark for cleanup if frame is being destroyed
                if not frame:GetParent() then
                    IndicatorPooling:ReleaseAllForFrame(frame)
                end
            end
        end
        
        return originalUpdateAllFrames()
    end
    
    self._hooksRegistered = true
end

-- Smart pre-loading: Pre-allocate pools based on player setup
function IndicatorPooling:SmartPreload()
    print("|cFF00B0F7Smart pool pre-loading...|r")
    
    local isHealer = false
    local isDK = false
    local isShaman = false
    
    local _, class = UnitClass("player")
    if class == "DEATHKNIGHT" then isDK = true end
    if class == "SHAMAN" then isShaman = true end
    
    local spec = GetSpecializationInfo(GetSpecialization() or 1)
    if spec then
        -- Rough check for healing specs (not 100% accurate but good enough)
        local specID, specName = GetSpecializationInfo(GetSpecialization())
        if specName and string.find(specName:lower(), "heal") then
            isHealer = true
        end
    end
    
    -- Increase healing bar pools for healers
    if isHealer then
        POOL_CONFIGS.HealPrediction.preAllocate = 30
        print("|cFFFFCC00Healer detected: Increasing HealPrediction pool size|r")
    end
    
    -- Enable rune pools for death knights
    if isDK then
        POOL_CONFIGS.Runes.preAllocate = 12
        print("|cFFFFCC00Death Knight detected: Enabling Rune pools|r")
    end
    
    -- Enable totem pools for shamans
    if isShaman then
        POOL_CONFIGS.Totems.preAllocate = 16
        print("|cFFFFCC00Shaman detected: Enabling Totem pools|r")
    end
end

-- Debugging: Dump pool state
function IndicatorPooling:DebugPoolState()
    print("|cFF00B0F7=== Indicator Pool Debug State ===|r")
    
    for indicatorType, config in pairs(POOL_CONFIGS) do
        local stats = UUF.FramePoolManager:GetPoolStats(config.name)
        if stats then
            print(string.format("%s (%s):", indicatorType, config.name))
            print(string.format("  Configured: %d frames", config.preAllocate))
            print(string.format("  Acquired: %d", stats.acquired or 0))
            print(string.format("  Released: %d", stats.released or 0))
            print(string.format("  Max Active: %d", stats.maxActive or 0))
        end
    end
end

-- Initialize on module load
function IndicatorPooling:Init()
    self:SmartPreload()
    self:InitializePools()
    self:RegisterCleanupHooks()
    print("|cFF00FF00✓|r Indicator pooling system ready")
end

return IndicatorPooling
