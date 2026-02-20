local _, UUF = ...
local Arch = UUF.Architecture

-- Config Layering System: Profile → Unit → Global → Hardcoded defaults
-- Provides flexible configuration with automatic fallback chain

local ConfigResolver = {}
UUF.ConfigResolver = ConfigResolver

-- Layer priorities (higher number = higher priority)
ConfigResolver.LAYERS = {
    HARDCODED = 1,    -- Default hardcoded values
    GLOBAL = 2,       -- Global configuration (applies to all units)
    UNIT = 3,         -- Unit-specific configuration
    PROFILE = 4,      -- Profile-specific overrides
}

-- Initialize the resolver with cached paths for performance
function ConfigResolver:Initialize()
    self._resolveCache = {}
    self._cacheVersion = 0
end

-- Invalidate cache when config changes
function ConfigResolver:InvalidateCache()
    self._cacheVersion = self._cacheVersion + 1
end

-- Resolve a config value using the layering system
-- path: dotted path like "HealthBar.Height" or "Auras.MaxCount"
-- Returns: (value, layer) where layer indicates which layer provided the value
function ConfigResolver:Resolve(path, unit, defaultValue)
    if not UUF.db then return defaultValue, "HARDCODED" end
    
    local unit = unit or "player"
    local cacheKey = path .. ":" .. unit
    local cached = self._resolveCache[cacheKey]
    if cached and cached.version == self._cacheVersion then
        return cached.value, cached.layer
    end
    
    local value = nil
    local sourceLayer = nil
    
    -- Split path into parts
    local parts = {}
    for part in path:gmatch("([^.]+)") do
        table.insert(parts, part)
    end
    
    -- Layer 4: Profile-specific (highest priority)
    if UUF.db.profile.Units and UUF.db.profile.Units[unit] then
        value = self:_getNestedValue(UUF.db.profile.Units[unit], parts)
        if value ~= nil then
            sourceLayer = "PROFILE"
        end
    end
    
    -- Layer 3: Unit-specific (if not found in profile)
    if sourceLayer == nil and UUF.db.global and UUF.db.global.UnitDefaults and UUF.db.global.UnitDefaults[unit] then
        value = self:_getNestedValue(UUF.db.global.UnitDefaults[unit], parts)
        if value ~= nil then
            sourceLayer = "UNIT"
        end
    end
    
    -- Layer 2: Global (if not found in unit)
    if sourceLayer == nil and UUF.db.global and UUF.db.global.GlobalDefaults then
        value = self:_getNestedValue(UUF.db.global.GlobalDefaults, parts)
        if value ~= nil then
            sourceLayer = "GLOBAL"
        end
    end
    
    -- Layer 1: Hardcoded (fallback)
    if sourceLayer == nil then
        value = defaultValue
        sourceLayer = "HARDCODED"
    end
    
    -- Cache result
    self._resolveCache[cacheKey] = {
        value = value,
        layer = sourceLayer,
        version = self._cacheVersion
    }
    
    return value, sourceLayer
end

-- Helper: Get nested value from table by path
function ConfigResolver:_getNestedValue(tbl, parts)
    local current = tbl
    for _, part in ipairs(parts) do
        if type(current) == "table" then
            current = current[part]
        else
            return nil
        end
    end
    return current
end

-- Helper: Set nested value in table by path
function ConfigResolver:_setNestedValue(tbl, parts, value)
    local current = tbl
    for i = 1, #parts - 1 do
        local part = parts[i]
        if not current[part] then
            current[part] = {}
        end
        current = current[part]
    end
    current[parts[#parts]] = value
    self:InvalidateCache()
end

-- Batch resolve multiple paths at once
function ConfigResolver:ResolveBatch(paths, unit)
    local results = {}
    for path, defaultValue in pairs(paths) do
        results[path] = self:Resolve(path, unit, defaultValue)
    end
    return results
end

-- Get all unit-specific defaults or create them
function ConfigResolver:GetUnitDefaults(unit)
    if not UUF.db.global.UnitDefaults then
        UUF.db.global.UnitDefaults = {}
    end
    if not UUF.db.global.UnitDefaults[unit] then
        UUF.db.global.UnitDefaults[unit] = {}
    end
    return UUF.db.global.UnitDefaults[unit]
end

-- Get global defaults or create them
function ConfigResolver:GetGlobalDefaults()
    if not UUF.db.global.GlobalDefaults then
        UUF.db.global.GlobalDefaults = {}
    end
    return UUF.db.global.GlobalDefaults
end

-- Set a unit-specific default
function ConfigResolver:SetUnitDefault(unit, path, value)
    local unitDefaults = self:GetUnitDefaults(unit)
    local parts = {}
    for part in path:gmatch("([^.]+)") do
        table.insert(parts, part)
    end
    self:_setNestedValue(unitDefaults, parts, value)
end

-- Set a global default
function ConfigResolver:SetGlobalDefault(path, value)
    local globalDefaults = self:GetGlobalDefaults()
    local parts = {}
    for part in path:gmatch("([^.]+)") do
        table.insert(parts, part)
    end
    self:_setNestedValue(globalDefaults, parts, value)
end

-- Override from profile (highest priority after profile itself)
function ConfigResolver:SetProfileDefault(path, value)
    if not UUF.db.profile then return end
    local parts = {}
    for part in path:gmatch("([^.]+)") do
        table.insert(parts, part)
    end
    local current = UUF.db.profile
    for i = 1, #parts - 1 do
        local part = parts[i]
        if not current[part] then
            current[part] = {}
        end
        current = current[part]
    end
    current[parts[#parts]] = value
    self:InvalidateCache()
end

-- Check if a value exists at a specific layer (for detecting overrides)
function ConfigResolver:ExistsAt(path, layer, unit)
    unit = unit or "player"
    local parts = {}
    for part in path:gmatch("([^.]+)") do
        table.insert(parts, part)
    end
    
    if layer == "PROFILE" and UUF.db.profile and UUF.db.profile.Units and UUF.db.profile.Units[unit] then
        return self:_getNestedValue(UUF.db.profile.Units[unit], parts) ~= nil
    elseif layer == "UNIT" and UUF.db.global and UUF.db.global.UnitDefaults and UUF.db.global.UnitDefaults[unit] then
        return self:_getNestedValue(UUF.db.global.UnitDefaults[unit], parts) ~= nil
    elseif layer == "GLOBAL" and UUF.db.global and UUF.db.global.GlobalDefaults then
        return self:_getNestedValue(UUF.db.global.GlobalDefaults, parts) ~= nil
    end
    return false
end

-- Get statistics on config distribution (for admin/debug)
function ConfigResolver:GetStats()
    local stats = {
        profileOverrides = 0,
        unitDefaults = 0,
        globalDefaults = 0,
        cacheHits = 0,
        cacheMisses = 0,
    }
    
    -- Count profile overrides
    for unit, unitConfig in pairs(UUF.db.profile.Units or {}) do
        stats.profileOverrides = stats.profileOverrides + self:_countTableKeys(unitConfig)
    end
    
    -- Count unit defaults
    for unit, unitConfig in pairs(UUF.db.global.UnitDefaults or {}) do
        stats.unitDefaults = stats.unitDefaults + self:_countTableKeys(unitConfig)
    end
    
    -- Count global defaults
    stats.globalDefaults = self:_countTableKeys(UUF.db.global.GlobalDefaults or {})
    
    -- Count cache status
    stats.cacheSize = self:_countTableKeys(self._resolveCache)
    
    return stats
end

-- Helper: Count keys in table recursively
function ConfigResolver:_countTableKeys(tbl)
    if type(tbl) ~= "table" then return 0 end
    local count = 0
    for k, v in pairs(tbl) do
        count = count + 1
        if type(v) == "table" and k ~= "version" then
            count = count + self:_countTableKeys(v)
        end
    end
    return count
end

-- Performance: Pre-load common paths for faster access
function ConfigResolver:PreloadPaths(paths, unit)
    for _, path in ipairs(paths) do
        self:Resolve(path, unit)
    end
end

ConfigResolver:Initialize()

return ConfigResolver
