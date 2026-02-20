local _, UUF = ...

-- PERF LOCALS: Localize frequently-called globals for faster access
local type, pairs, ipairs = type, pairs, ipairs

-- Reactive Configuration System
-- Automatically propagates configuration changes to affected frames without manual updates
-- Uses a change tracking system to identify which frames need re-rendering

local ReactiveConfig = {}
UUF.ReactiveConfig = ReactiveConfig

-- Configuration change listeners
ReactiveConfig._changeListeners = {}
ReactiveConfig._configWatchers = {}
ReactiveConfig._updateScheduled = false

-- Register a listener for specific config paths
function ReactiveConfig:OnConfigChange(configPath, callback, priority)
    priority = priority or 50
    
    self._changeListeners[configPath] = self._changeListeners[configPath] or {}
    
    local listener = {
        callback = callback,
        priority = priority,
    }
    
    table.insert(self._changeListeners[configPath], listener)
    
    -- Sort by priority (higher first)
    table.sort(self._changeListeners[configPath], function(a, b)
        return a.priority > b.priority
    end)
end

-- Unregister a listener
function ReactiveConfig:UnregisterListener(configPath, callbackRef)
    if not self._changeListeners[configPath] then return end
    
    for i, listener in ipairs(self._changeListeners[configPath]) do
        if listener.callback == callbackRef then
            table.remove(self._changeListeners[configPath], i)
            break
        end
    end
end

-- Dispatch config change to all listeners
function ReactiveConfig:_DispatchChange(configPath, oldValue, newValue, context)
    if not self._changeListeners[configPath] then return end
    
    local listeners = self._changeListeners[configPath]
    for i = 1, #listeners do
        local listener = listeners[i]
        local ok, err = pcall(listener.callback, {
            path = configPath,
            oldValue = oldValue,
            newValue = newValue,
            context = context,
        })
        
        if not ok then
            if UUF.DebugOutput then
                UUF.DebugOutput:Output("ReactiveConfig", "Error in listener for " .. configPath .. ": " .. err, UUF.DebugOutput.TIER_CRITICAL)
            end
        end
    end
end

-- Watch a database table for changes
function ReactiveConfig:WatchTable(table, configPath)
    if not table then return end
    
    local mt = getmetatable(table)
    if mt and mt.__isWatching then return end  -- Already watching
    
    local originalNewIndex = mt and mt.__newindex or nil
    
    local watcherMT = {
        __newindex = function(t, k, v)
            local oldValue = rawget(t, k)
            if oldValue ~= v then
                rawset(t, k, v)
                local fullPath = configPath .. "." .. tostring(k)
                ReactiveConfig:_DispatchChange(fullPath, oldValue, v, t)
            end
        end,
        __index = rawget(table, "__index"),
        __isWatching = true,
    }
    
    setmetatable(table, watcherMT)
end

-- Watch all unit configs for changes
function ReactiveConfig:InitializeConfigWatchers()
    if self._watchersInitialized then return end
    
    -- Watch General config
    if UUF.db.profile.General then
        self:WatchTable(UUF.db.profile.General, "profile.General")
    end
    
    -- Watch Units config
    if UUF.db.profile.Units then
        for unitName, unitConfig in pairs(UUF.db.profile.Units) do
            self:WatchTable(unitConfig, "profile.Units." .. unitName)
            
            -- Watch sub-tables
            for section, sectionConfig in pairs(unitConfig) do
                if type(sectionConfig) == "table" then
                    self:WatchTable(sectionConfig, "profile.Units." .. unitName .. "." .. section)
                end
            end
        end
    end
    
    self._watchersInitialized = true
    if UUF.DebugOutput then
        UUF.DebugOutput:Output("ReactiveConfig", "Config watchers initialized", UUF.DebugOutput.TIER_INFO)
    end
end

-- Schedule frame update (batches rapid updates)
function ReactiveConfig:ScheduleUpdate(unitID, delay)
    delay = delay or 0.1
    
    if not self._updateScheduled then
        self._updateScheduled = true
        C_Timer.After(delay, function()
            self:_ProcessScheduledUpdates()
        end)
    end
    
    if unitID then
        self._pendingUpdates = self._pendingUpdates or {}
        self._pendingUpdates[unitID] = true
    end
end

-- Process batched updates
function ReactiveConfig:_ProcessScheduledUpdates()
    if self._pendingUpdates then
        for unitID in pairs(self._pendingUpdates) do
            UUF:UpdateUnitFrame(UUF[unitID:upper()], unitID)
        end
        self._pendingUpdates = nil
    end
    self._updateScheduled = false
end

-- Register reactive behaviors for common config changes

function ReactiveConfig:RegisterDefaultBehaviors()
    -- Health bar color changes
    self:OnConfigChange("profile.General.Colours.Power", function(event)
        if UUF.DebugOutput then
            UUF.DebugOutput:Output("ReactiveConfig", "Power colors changed, updating frames...", UUF.DebugOutput.TIER_DEBUG)
        end
        UUF:UpdateAllUnitFrames()
    end, 100)
    
    -- Font changes
    self:OnConfigChange("profile.General.Fonts", function(event)
        if UUF.DebugOutput then
            UUF.DebugOutput:Output("ReactiveConfig", "Fonts changed, updating all text elements...", UUF.DebugOutput.TIER_DEBUG)
        end
        UUF:UpdateAllUnitFrames()
    end, 100)
    
    -- Per-unit health bar changes
    self:OnConfigChange("profile.Units", function(event)
        if event.path:find("HealthBar") then
            local unit = event.path:match("Units%.([^.]+)")
            if unit then
                if UUF.DebugOutput then
                    UUF.DebugOutput:Output("ReactiveConfig", unit .. " health bar config changed", UUF.DebugOutput.TIER_DEBUG)
                end
                UUF:UpdateUnitFrame(UUF[unit:upper()], unit)
            end
        end
    end, 50)
    
    -- Aura changes
    self:OnConfigChange("profile.Units", function(event)
        if event.path:find("Aura") then
            local unit = event.path:match("Units%.([^.]+)")
            if unit then
                if UUF.DebugOutput then
                    UUF.DebugOutput:Output("ReactiveConfig", unit .. " aura config changed", UUF.DebugOutput.TIER_DEBUG)
                end
                UUF:UpdateUnitFrame(UUF[unit:upper()], unit)
            end
        end
    end, 50)
end

-- Performance: Convert reactive updates to cached checks
function ReactiveConfig:OptimizeForPerformance()
    -- For high-frequency updates, batch them
    self:OnConfigChange("profile.General.Colours", function(event)
        ReactiveConfig:ScheduleUpdate(nil, 0.5)  -- Batch updates at 500ms
    end, 25)
end

-- Validation: Check if reactive config is working
function ReactiveConfig:Validate()
    local ok = true
    
    if not self._changeListeners or not next(self._changeListeners) then
        if UUF.DebugOutput then
            UUF.DebugOutput:Output("ReactiveConfig", "No config listeners registered", UUF.DebugOutput.TIER_CRITICAL)
        end
        ok = false
    else
        if UUF.DebugOutput then
            UUF.DebugOutput:Output("ReactiveConfig", "Config listeners registered: " .. tostring(#self._changeListeners), UUF.DebugOutput.TIER_INFO)
        end
    end
    
    if not self._watchersInitialized then
        if UUF.DebugOutput then
            UUF.DebugOutput:Output("ReactiveConfig", "Config watchers not initialized", UUF.DebugOutput.TIER_CRITICAL)
        end
        ok = false
    else
        if UUF.DebugOutput then
            UUF.DebugOutput:Output("ReactiveConfig", "Config watchers initialized", UUF.DebugOutput.TIER_INFO)
        end
    end
    
    return ok
end

-- Initialize reactive config system
function ReactiveConfig:Init()
    self:InitializeConfigWatchers()
    self:RegisterDefaultBehaviors()
    self:OptimizeForPerformance()
    if UUF.DebugOutput then
        UUF.DebugOutput:Output("ReactiveConfig", "System ready", UUF.DebugOutput.TIER_INFO)
    end
end

-- Usage examples (for reference):
--[[
-- Register a custom listener
UUF.ReactiveConfig:OnConfigChange("profile.Units.player.HealthBar.Height", function(event)
    print("Player health bar height changed from " .. event.oldValue .. " to " .. event.newValue)
    -- Custom update logic here
end, 100)

-- Check status
/run UUF.ReactiveConfig:Validate()
]]

return ReactiveConfig
