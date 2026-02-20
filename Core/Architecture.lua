-- ============================================================================
-- Core/Architecture.lua
-- UnhaltedUnitFrames Architecture Layer
-- 
-- Combines MSUF-proven architectural patterns:
-- - EventBus for global event separation
-- - GUI widget primitives and layout helpers
-- - Configuration layering with fallbacks
-- - Safe value handling for secret values
-- - Stamp-based change detection
--
-- Design goals:
-- - Keep UUF modular without replacing Ace3 or oUF
-- - Provide clean abstractions for common patterns
-- - Enable frame pooling and state management
-- - Support GUI building without boilerplate
--
-- ============================================================================

local _, UUF = ...
UUF.Architecture = UUF.Architecture or {}
local Arch = UUF.Architecture

-- =========================================================================
-- Event Bus: Separate global events from unit-specific events
-- 
-- Usage:
--   Arch.EventBus:Register("PLAYER_LOGIN", "mymodule", myHandler, true)  -- once
--   Arch.EventBus:Unregister("PLAYER_LOGIN", "mymodule")
--   Arch.EventBus:Dispatch("CUSTOM_EVENT", eventData)
--
-- Design: Handlers stored in dense numeric arrays, supports safe calls,
--         handlers marked dead during dispatch and compacted after.
-- =========================================================================

Arch.EventBus = {
    handlers = {},
    safeCalls = false,
    _frame = CreateFrame("Frame"),
}

local function EnsureEventRegistered(event)
    if not Arch.EventBus._frame:IsEventRegistered(event) then
        -- Use pcall to safely register - custom/synthetic events will fail but that's OK
        -- They can still be dispatched manually via Dispatch()
        pcall(function() Arch.EventBus._frame:RegisterEvent(event) end)
    end
end

function Arch.EventBus:Register(event, key, fn, once)
    if type(event) ~= "string" or type(key) ~= "string" or type(fn) ~= "function" then
        return false
    end
    
    -- Initialize event entry
    if not self.handlers[event] then
        self.handlers[event] = { list = {}, index = {} }
    end
    
    local entry = self.handlers[event]
    
    -- Prevent duplicate registrations
    if entry.index[key] then
        return false
    end
    
    -- Add handler to dense array
    local handler = { key = key, fn = fn, once = once or false, dead = false }
    local pos = #entry.list + 1
    entry.list[pos] = handler
    entry.index[key] = pos
    
    EnsureEventRegistered(event)
    return true
end

function Arch.EventBus:Unregister(event, key)
    if type(event) ~= "string" or type(key) ~= "string" then
        return false
    end
    
    local entry = self.handlers[event]
    if not entry or not entry.index[key] then
        return false
    end
    
    local pos = entry.index[key]
    local handler = entry.list[pos]
    
    if handler then
        handler.dead = true
        entry.dirty = true
        -- Compact immediately to ensure clean state for re-registration
        self:_CompactHandlers(event)
    end
    
    return true
end

function Arch.EventBus:Dispatch(event, ...)
    local entry = self.handlers[event]
    if not entry then return end
    
    local list = entry.list
    entry.dispatchDepth = (entry.dispatchDepth or 0) + 1
    
    for i = 1, #list do
        local handler = list[i]
        if handler and handler.fn and not handler.dead then
            if self.safeCalls then
                pcall(handler.fn, ...)
            else
                handler.fn(...)
            end
            
            if handler.once then
                handler.dead = true
                entry.dirty = true
            end
        end
    end
    
    entry.dispatchDepth = entry.dispatchDepth - 1
    
    -- Compact after dispatch if not nested and marked dirty
    if entry.dispatchDepth == 0 and entry.dirty then
        self:_CompactHandlers(event)
    end
end

function Arch.EventBus:_CompactHandlers(event)
    if not event or not self.handlers[event] then return end
    
    local entry = self.handlers[event]
    local list, idx = entry.list, entry.index
    
    -- Clear index
    for k in pairs(idx) do
        idx[k] = nil
    end
    
    -- Compact live handlers
    local write = 0
    for i = 1, #list do
        local h = list[i]
        if h and h.fn and not h.dead then
            write = write + 1
            if write ~= i then list[write] = h end
            idx[h.key] = write
        end
    end
    
    -- Clear remaining slots
    for i = write + 1, #list do
        list[i] = nil
    end
    
    entry.dirty = false
end

-- Wire EventBus to WoW's event frame
Arch.EventBus._frame:SetScript("OnEvent", function(self, event, ...)
    Arch.EventBus:Dispatch(event, ...)
end)

-- =========================================================================
-- GUI Building: Widget primitives and layout helpers
-- 
-- Usage:
--   local col = Arch.LayoutColumn(panel, 12, -12, 20, 6)
--   col:Row(20):Btn("button_label", 100, 20, onClickFn):Gap(10):Text("Label")
--   col:MoveY(-40):Row(20):Check("checkbox_label", onClickFn)
-- =========================================================================

function Arch.LayoutColumn(parent, startX, startY, rowH, gap)
    local layout = {
        parent = parent,
        x = startX or 12,
        y = startY or -12,
        rowH = rowH or 20,
        gap = gap or 6,
        _row = nil,
        _rowX = 0,
    }
    
    function layout:Row(h, g)
        local h = h or self.rowH
        local g = g or self.gap
        self._row = { widgets = {}, x = self.x, y = self.y, h = h }
        return self
    end
    
    function layout:Btn(text, w, h, onClick, template)
        if not self._row then self:Row() end
        local btn = CreateFrame("Button", nil, self.parent, template or "UIPanelButtonTemplate")
        if w and h then btn:SetSize(w, h) end
        if text then btn:SetText(text) end
        if type(onClick) == "function" then btn:SetScript("OnClick", onClick) end
        
        btn:SetPoint("TOPLEFT", self.parent, "TOPLEFT", self._row.x + self._rowX, self._row.y)
        self._rowX = self._rowX + (w or 80) + self.gap
        
        table.insert(self._row.widgets, btn)
        return self
    end
    
    function layout:Text(text, font, skinFn)
        if not self._row then self:Row() end
        local fs = self.parent:CreateFontString(nil, "OVERLAY", font or "GameFontHighlight")
        if text then fs:SetText(text) end
        if skinFn then skinFn(fs) end
        
        fs:SetPoint("TOPLEFT", self.parent, "TOPLEFT", self._row.x + self._rowX, self._row.y)
        self._rowX = self._rowX + 100 + self.gap
        
        table.insert(self._row.widgets, fs)
        return self
    end
    
    function layout:Check(label, onClick, template)
        if not self._row then self:Row() end
        local cb = CreateFrame("CheckButton", nil, self.parent, template or "UICheckButtonTemplate")
        if cb.Text and label then cb.Text:SetText(label) end
        if type(onClick) == "function" then cb:SetScript("OnClick", onClick) end
        
        cb:SetPoint("TOPLEFT", self.parent, "TOPLEFT", self._row.x + self._rowX, self._row.y)
        self._rowX = self._rowX + 200 + self.gap
        
        table.insert(self._row.widgets, cb)
        return self
    end
    
    function layout:Gap(w)
        if not self._row then self:Row() end
        self._rowX = self._rowX + (w or self.gap)
        return self
    end
    
    function layout:MoveY(dy)
        if self._row then
            self.y = self.y + (self._row.h or self.rowH) + (self.gap or 0)
        end
        if dy then self.y = self.y + dy end
        self._rowX = 0
        self._row = nil
        return self
    end
    
    function layout:At(x, y)
        self.x = x or self.x
        self.y = y or self.y
        self._rowX = 0
        self._row = nil
        return self
    end
    
    function layout:Reset()
        -- Reset to initial state for rebuild
        self.x = startX or 12
        self.y = startY or -12
        self._rowX = 0
        self._row = nil
        return self
    end
    
    return layout
end

-- =========================================================================
-- Configuration Layering: Profile > unit > global fallback
-- 
-- Usage:
--   local value = Arch.ResolveConfig(unitDB, "HealthBar", "Height", unitDefaults.HealthBar.Height, globalDefaults.HealthBar.Height)
-- =========================================================================

function Arch.ResolveConfig(unitDB, section, key, unitDefault, globalDefault)
    if type(unitDB) == "table" and type(unitDB[section]) == "table" then
        local val = unitDB[section][key]
        if val ~= nil then return val end
    end
    
    if unitDefault ~= nil then return unitDefault end
    if globalDefault ~= nil then return globalDefault end
    
    return nil
end

function Arch.CaptureConfigState(db, keys)
    if type(db) ~= "table" or type(keys) ~= "table" then
        return {}
    end
    
    local snap = {}
    for i = 1, #keys do
        local k = keys[i]
        snap[k] = db[k]
    end
    return snap
end

function Arch.RestoreConfigState(db, snapshot)
    if type(db) ~= "table" or type(snapshot) ~= "table" then
        return
    end
    
    for k, v in pairs(snapshot) do
        db[k] = v
    end
end

-- =========================================================================
-- Safe Value Handling: Secret value protection
-- 
-- Usage:
--   local ok, health = Arch.SafeGetUnitHealth("player")
--   if ok then print(health) end
-- =========================================================================

function Arch.SafeValue(fn, ...)
    if type(fn) ~= "function" then return false end
    local ok, res = pcall(fn, ...)
    return ok, res
end

function Arch.SafeCompare(val1, val2)
    if val1 == val2 then return true end
    if type(val1) ~= type(val2) then return false end
    return false
end

function Arch.IsSecretValue(val)
    if type(val) ~= "userdata" then return false end
    -- Secret values are sentinel userdata objects in WoW 12.0.0+
    -- Check by type; if it's userdata and not a standard frame/object, it may be a secret
    return true
end

-- =========================================================================
-- State Management: Frame state pooling and lifecycle
-- 
-- Usage:
--   local state = Arch.CreateFrameState(frame, unitID, unitConfig)
--   state:SetDirty("auras")
--   if state:IsDirty("auras") then ... end
-- =========================================================================

function Arch.CreateFrameState(frame, unitID, unitConfig)
    local state = {
        frame = frame,
        unitID = unitID,
        config = unitConfig,
        _dirty = {},
        _stamps = {},
        _lastValues = {},
    }
    
    function state:SetDirty(key)
        self._dirty[key] = true
    end
    
    function state:IsDirty(key)
        return self._dirty[key] or false
    end
    
    function state:ClearDirty(key)
        self._dirty[key] = nil
    end
    
    function state:ClearAllDirty()
        for k in pairs(self._dirty) do
            self._dirty[k] = nil
        end
    end
    
    function state:Stamp(key, ...)
        local n = select("#", ...)
        local current = { n = n }
        for i = 1, n do
            current[i] = select(i, ...)
        end
        
        local last = self._stamps[key]
        if not last or last.n ~= n then
            self._stamps[key] = current
            return true
        end
        
        for i = 1, n do
            if last[i] ~= current[i] then
                self._stamps[key] = current
                return true
            end
        end
        
        return false
    end
    
    return state
end

-- =========================================================================
-- Frame Pooling: Reusable frame cache to reduce GC pressure
-- 
-- Usage:
--   local pool = Arch.CreateFramePool("Button", parent, "UIPanelButtonTemplate")
--   local frame = pool:Acquire()
--   -- do stuff with frame
--   pool:Release(frame)
-- =========================================================================

function Arch.CreateFramePool(frameType, parent, template)
    local pool = {
        frameType = frameType,
        parent = parent,
        template = template,
        available = {},
        active = {},
        count = 0,
    }
    
    function pool:Acquire()
        local frame
        if #self.available > 0 then
            frame = table.remove(self.available)
        else
            frame = CreateFrame(self.frameType, nil, self.parent, self.template)
            self.count = self.count + 1
        end
        self.active[frame] = true
        return frame
    end
    
    function pool:Release(frame)
        if not frame then return end
        if self.active[frame] then
            self.active[frame] = nil
            frame:Hide()
            frame:ClearAllPoints()
            table.insert(self.available, frame)
        end
    end
    
    function pool:ReleaseAll()
        for frame in pairs(self.active) do
            self:Release(frame)
        end
    end
    
    function pool:GetCount()
        return self.count, #self.available, self.count - #self.available
    end
    
    return pool
end

-- =========================================================================
-- Compression/Decompression: Profile export with safety
-- 
-- Compatible with MSUF's CBOR encoding
-- =========================================================================

function Arch.EncodeProfile(profileData)
    if type(profileData) ~= "table" then
        return nil
    end
    
    local E = C_EncodingUtil
    if not E or type(E.SerializeCBOR) ~= "function" or type(E.EncodeBase64) ~= "function" then
        return nil
    end
    
    local ok, cbor = pcall(E.SerializeCBOR, profileData)
    if not ok or type(cbor) ~= "string" then
        return nil
    end
    
    local ok2, b64 = pcall(E.EncodeBase64, cbor)
    if not ok2 or type(b64) ~= "string" then
        return nil
    end
    
    return "UUF1:" .. b64
end

function Arch.DecodeProfile(encoded)
    if type(encoded) ~= "string" then
        return nil
    end
    
    local E = C_EncodingUtil
    if not E or type(E.DeserializeCBOR) ~= "function" or type(E.DecodeBase64) ~= "function" then
        return nil
    end
    
    local b64 = encoded:match("^UUF1:(.+)$")
    if not b64 then
        return nil
    end
    
    local ok, cbor = pcall(E.DecodeBase64, b64)
    if not ok or type(cbor) ~= "string" then
        return nil
    end
    
    local ok2, tbl = pcall(E.DeserializeCBOR, cbor)
    if not ok2 or type(tbl) ~= "table" then
        return nil
    end
    
    return tbl
end

-- =========================================================================
-- Table Utilities: Deep copy, merge, filter
-- =========================================================================

function Arch.DeepCopy(src, seen)
    if type(src) ~= "table" then
        return src
    end
    
    seen = seen or {}
    if seen[src] then
        return seen[src]
    end
    
    local copy = {}
    seen[src] = copy
    
    for k, v in pairs(src) do
        copy[Arch.DeepCopy(k, seen)] = Arch.DeepCopy(v, seen)
    end
    
    return copy
end

function Arch.MergeTables(dst, src, overwrite)
    if type(dst) ~= "table" or type(src) ~= "table" then
        return dst
    end
    
    for k, v in pairs(src) do
        if overwrite or dst[k] == nil then
            if type(v) == "table" and type(dst[k]) == "table" then
                Arch.MergeTables(dst[k], v, overwrite)
            else
                dst[k] = v
            end
        end
    end
    
    return dst
end

function Arch.FilterTable(src, predicate)
    if type(src) ~= "table" or type(predicate) ~= "function" then
        return {}
    end
    
    local result = {}
    for k, v in pairs(src) do
        if predicate(k, v) then
            result[k] = v
        end
    end
    
    return result
end

-- =========================================================================
-- Export API
-- =========================================================================

UUF.Architecture = Arch
_G.UUF_Architecture = Arch

return Arch
