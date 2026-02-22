local _, UUF = ...

-- =========================================================================
-- Utilities Module: Common Helpers
-- =========================================================================
-- Centralized helpers for config resolution, table operations, formatting,
-- and layout assistance. Reduces code duplication across elements.
-- =========================================================================

local Utilities = {}
local IsSecretValue = _G.IsSecretValue or _G.issecretvalue or function() return false end

-- =========================================================================
-- Configuration Value Helpers (SavedVariables + Global Fallback)
-- =========================================================================

--- Get a config value with fallback to global default
-- Checks profile-specific config first, then global defaults
-- Usage: Utilities.Val(configDB, globalDB, "Enabled", false)
function Utilities.Val(conf, global, key, default)
    local v = conf and conf[key]
    if v == nil and global then v = global[key] end
    if v == nil then v = default end
    return v
end

--- Get a numeric config value with fallback
-- Safely converts to number and returns default if nil
function Utilities.Num(conf, global, key, default)
    local v = tonumber(Utilities.Val(conf, global, key, nil))
    return (v == nil) and default or v
end

--- Get a boolean enabled state (defaults to true if nil)
-- Returns true if value is nil (safe default) or not false
function Utilities.Enabled(conf, global, key, defaultEnabled)
    local v = Utilities.Val(conf, global, key, nil)
    if v == nil then return (defaultEnabled ~= false) end
    return (v ~= false)
end

--- Conditionally show/hide frame
-- Safe wrapper for Show/Hide operations
function Utilities.SetShown(obj, show)
    if not obj then return end
    if show then
        if obj.Show then obj:Show() end
    else
        if obj.Hide then obj:Hide() end
    end
end

--- Offset value with default fallback
-- Returns offset or default if value is nil
function Utilities.Offset(v, default)
    return (v == nil) and default or v
end

-- =========================================================================
-- Table Helpers
-- =========================================================================

--- Hide multiple child objects by key table
-- Usage: Utilities.HideKeys(frame, {"Glow", "Border", "Overlay"}, "CustomKey")
function Utilities.HideKeys(obj, keyTable, extraKey)
    if not obj or not keyTable then return end
    for i = 1, #keyTable do
        local child = obj[keyTable[i]]
        if child and child.Hide then
            child:Hide()
        end
    end
    if extraKey then
        local child = obj[extraKey]
        if child and child.Hide then
            child:Hide()
        end
    end
end

--- Show multiple child objects by key table
-- Usage: Utilities.ShowKeys(frame, {"Glow", "Border"})
function Utilities.ShowKeys(obj, keyTable, extraKey)
    if not obj or not keyTable then return end
    for i = 1, #keyTable do
        local child = obj[keyTable[i]]
        if child and child.Show then
            child:Show()
        end
    end
    if extraKey then
        local child = obj[extraKey]
        if child and child.Show then
            child:Show()
        end
    end
end

-- =========================================================================
-- Safe API Wrappers
-- =========================================================================

--- Returns true when a value is a secret value object.
function Utilities.IsSecret(value)
    return IsSecretValue(value) == true
end

--- Returns non-secret value, otherwise default.
function Utilities.SafeValue(value, default)
    if value == nil or IsSecretValue(value) then
        return default
    end
    return value
end

--- Safe numeric coercion that rejects secret values.
function Utilities.SafeNumber(value, default)
    local safe = Utilities.SafeValue(value, nil)
    if safe == nil then return default end
    local n = tonumber(safe)
    if n == nil or IsSecretValue(n) then
        return default
    end
    return n
end

--- Safe string coercion that rejects secret values.
function Utilities.SafeString(value, default)
    local safe = Utilities.SafeValue(value, nil)
    if safe == nil then return default end
    local ok, str = pcall(tostring, safe)
    if not ok or not str or IsSecretValue(str) then
        return default
    end
    return str
end

--- Get casting info safely (handles secret values)
-- Returns nil if unit doesn't exist or API fails
function Utilities.GetCastingInfoSafe(unit)
    if not unit then return end
    local ok, castName, text, texture, startTime, endTime, isTradeSkill, castID, isInterrupted, spellID
        = pcall(UnitCastingInfo, unit)

    if not ok then return nil end
    if IsSecretValue(castName) then return nil end

    return castName, text, texture, startTime, endTime, isTradeSkill, castID, isInterrupted, spellID
end

--- Get channel info safely (handles secret values)
-- Returns nil if unit doesn't exist or API fails
function Utilities.GetChannelInfoSafe(unit)
    if not unit then return end
    local ok, channelName, text, texture, startTime, endTime, isTradeSkill, notInterruptible
        = pcall(UnitChannelInfo, unit)

    if not ok then return nil end
    if IsSecretValue(channelName) then return nil end

    return channelName, text, texture, startTime, endTime, isTradeSkill, notInterruptible
end

-- =========================================================================
-- Format Helpers
-- =========================================================================

--- Format duration as "1m 23s" or "45s"
-- Returns human-readable duration string
function Utilities.FormatDuration(seconds)
    if not seconds or seconds <= 0 then return "0s" end

    if seconds >= 60 then
        local minutes = math.floor(seconds / 60)
        local secs = math.floor(seconds % 60)
        if secs > 0 then
            return string.format("%dm %ds", minutes, secs)
        else
            return string.format("%dm", minutes)
        end
    else
        return string.format("%ds", math.floor(seconds))
    end
end

--- Format large numbers with K/M suffix
-- 1234567 -> "1.2M", 1234 -> "1.2K", 1 -> "1"
function Utilities.FormatNumber(num)
    if not num then return "0" end
    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fK", num / 1000)
    else
        return tostring(math.floor(num))
    end
end

--- Format percentage with optional decimals
-- 0.7234 -> "72.34%", 0.5 -> "50%"
function Utilities.FormatPercent(value, decimals)
    if not value then return "0%" end
    decimals = decimals or 0
    return string.format("%." .. decimals .. "f%%", value * 100)
end

-- =========================================================================
-- Layout Helpers (for UI construction)
-- =========================================================================

-- Event compatibility aliases for mixed Retail client behavior.
Utilities.EventCompatibility = {
    UUF_SPELLBOOK_STATE_CHANGED = {
        "SPELLS_CHANGED",
        "TRAIT_CONFIG_UPDATED",
        "PLAYER_SPECIALIZATION_CHANGED",
        "PLAYER_TALENT_UPDATE",
        "LEARNED_SPELL_IN_TAB",
        "LEARNED_SPELL_IN_SKILL_LINE",
    },
}

--- Resolve one event or compatibility alias to concrete events.
function Utilities.ResolveEventList(eventOrAlias)
    if type(eventOrAlias) == "table" then
        return eventOrAlias
    end
    if type(eventOrAlias) ~= "string" then
        return {}
    end
    return Utilities.EventCompatibility[eventOrAlias] or { eventOrAlias }
end

--- Register one or more events/aliases on a frame, deduplicated.
function Utilities.RegisterCompatibilityEvents(frame, ...)
    if not frame or not frame.RegisterEvent then return end
    local seen = {}
    for i = 1, select("#", ...) do
        local spec = select(i, ...)
        local resolved = Utilities.ResolveEventList(spec)
        for j = 1, #resolved do
            local eventName = resolved[j]
            if eventName and not seen[eventName] then
                seen[eventName] = true
                frame:RegisterEvent(eventName)
            end
        end
    end
end

--- Column layout helper for UI construction
-- Simplifies coordinate math when building stacked UI elements
-- Usage:
--   local L = Utilities.LayoutColumn(parent, 10, -10, 20, 6)
--   local x, y = L:Row()  -- Get next row coords, moves down
--   local x, y = L:At(5, -10)  -- Get offset from current position
function Utilities.LayoutColumn(parent, startX, startY, defaultRowH, defaultGap)
    local L = {
        parent = parent,
        x = startX or 12,
        y = startY or -12,
        rowH = defaultRowH or 20,
        gap = defaultGap or 6,
    }

    --- Get coordinates for next row and advance Y
    -- h: optional custom row height
    -- gap: optional custom gap after row
    function L:Row(h, gap)
        local x, y = self.x, self.y
        self.y = self.y - (h or self.rowH) - (gap or self.gap)
        return x, y
    end

    --- Move Y coordinate by offset
    -- Used to add sections or blank space
    function L:MoveY(dy)
        self.y = self.y + (dy or 0)
        return self
    end

    --- Get absolute coordinates relative to current position
    -- dx: optional X offset
    -- dy: optional Y offset
    function L:At(dx, dy)
        return self.x + (dx or 0), self.y + (dy or 0)
    end

    --- Reset column to starting position
    function L:Reset()
        self.y = startY or -12
        return self
    end

    return L
end

-- =========================================================================
-- Export Utilities to UUF namespace
-- =========================================================================

UUF.Utilities = Utilities
return Utilities
