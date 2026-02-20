# UUF Architecture Integration Guide

**Comprehensive Guide to MSUF-Proven Architectural Patterns in UnhaltedUnitFrames**

Updated: Phase 2 Complete + Architecture.lua integration  
Status: Ready for Phase 3 Implementation

---

## 1. EventBus Architecture

### Overview

MSUF uses an EventBus pattern to drastically reduce complexity and prevent
event handler explosion. Instead of every element registering for the same
global events, there's a single central dispatcher that manages handlers.

**Benefits:**
- Single event routing point (easier to debug)
- Handlers stored in dense arrays (avoid table walking)
- Supports safe calls with protected invocation
- Clean separation: global events ≠ unit-specific events

### API

```lua
-- Register a global event handler
Arch.EventBus:Register(event, key, fn, once)
  -- event: "PLAYER_LOGIN", "UNIT_HEALTH", etc.
  -- key: unique identifier (module name recommended)
  -- fn: function(...)
  -- once: if true, automatically unregister after first dispatch

-- Dispatch an event manually
Arch.EventBus:Dispatch(event, ...)

-- Unregister a handler
Arch.EventBus:Unregister(event, key)

-- Enable safe calls (all handlers wrapped in pcall)
Arch.EventBus.safeCalls = true
```

### Usage Pattern

**Before (Element Registration - scattered):**
```lua
-- In CastBar.lua
Frame:RegisterEvent("UNIT_SPELLCAST_START")
Frame:RegisterEvent("UNIT_SPELLCAST_STOP")

-- In HealthBar.lua
Frame:RegisterEvent("UNIT_HEALTH")

-- In Auras.lua
Frame:RegisterEvent("UNIT_AURA")
```

**After (Centralized EventBus):**
```lua
-- In Core.lua (one place)
Arch.EventBus:Register("UNIT_SPELLCAST_START", "CastBar", CastBarHandler)
Arch.EventBus:Register("UNIT_SPELLCAST_STOP", "CastBar", CastBarHandler)
Arch.EventBus:Register("UNIT_HEALTH", "HealthBar", HealthBarHandler)
Arch.EventBus:Register("UNIT_AURA", "Auras", AuraHandler)

-- For unit-specific updates (not through EventBus):
unitFrame:RegisterEvent("UNIT_SPELLCAST_START")
unitFrame:SetScript("OnEvent", function(self, event, unit)
    if unit == self.unit then
        -- Handle unit event
    end
end)
```

### Event Handler Optimization

**Dense Array vs Table Walking:**
```lua
-- MSUF approach: Dense arrays avoid pairs() iteration
handlers.list = {
    { key="CastBar", fn=castFn, once=false, dead=false },
    { key="HealthBar", fn=healthFn, once=false, dead=false },
}
handlers.index = { CastBar=1, HealthBar=2 }

-- Fast dispatch: iterate list[i] directly
for i = 1, #handlers.list do
    local h = handlers.list[i]
    if h and h.fn and not h.dead then
        h.fn(...)
    end
end

-- NO pairs() = faster iteration
-- NO garbage created = less GC pressure
```

### When to Use EventBus

✅ **DO use for:**
- Global events (PLAYER_LOGIN, PLAYER_ENTERING_WORLD, etc.)
- Combat state changes
- Player talent/spec changes
- Raid/group composition changes
- Custom events between modules

❌ **DON'T use for:**
- UNIT_* events (register directly on frame, filter by unit)
- Per-frame events (use frame:RegisterEvent directly)
- High-frequency updates tied to specific units

---

## 2. GUI Widget Primitives & Layout Helpers

### Overview

MSUF builds UI using data-driven primitives instead of hardcoding frame
creation calls. This reduces boilerplate and makes UI easier to modify.

### Primitives

```lua
-- Simple button
local btn = Arch.LayoutColumn()
    :Row(20):Btn("Click Me", 100, 20, onClickFn)

-- Checkbox with label
local col = Arch.LayoutColumn(parent, 12, -12, 20, 6)
col:Row():Check("Enable Feature", onChangeFn)

-- Label text
col:Row():Text("Configuration Label")

-- Multiple controls on same row
col:Row(25)
    :Btn("Save", 60, 20, onSaveFn)
    :Gap(10)
    :Btn("Cancel", 60, 20, onCancelFn)
```

### Layout Column Helper

Returns a layout object with chainable methods:

```lua
local col = Arch.LayoutColumn(parent, startX, startY, rowHeight, gap)

col:Row(h)              -- Start new row, optional custom height
   :Btn(text, w, h, fn)   -- Add button
   :Text(text)            -- Add label
   :Check(label, fn)      -- Add checkbox
   :Gap(w)                -- Add horizontal spacing

col:MoveY(dy)           -- Move down by dy pixels (default rowHeight + gap)
col:At(x, y)            -- Jump to absolute position
col:Reset()             -- Reset to initial state for rebuild

-- Chainable returns 'col' so you can do:
col:Row():Btn("A", 60, 20, fn)
   :MoveY(-40)
   :Row():Check("Option", fn)
   :MoveY(-30)
   :Row():Text("Status")
```

### Converting Existing UI Code

**Before (hardcoded positioning):**
```lua
local btn1 = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
btn1:SetSize(100, 20)
btn1:SetPoint("TOPLEFT", parent, "TOPLEFT", 12, -12)
btn1:SetText("Button 1")

local btn2 = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
btn2:SetSize(100, 20)
btn2:SetPoint("TOPLEFT", parent, "TOPLEFT", 12, -42)
btn2:SetText("Button 2")

local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
cb:SetPoint("TOPLEFT", parent, "TOPLEFT", 12, -72)
cb.Text:SetText("Option")
```

**After (layout column):**
```lua
local col = Arch.LayoutColumn(parent, 12, -12, 20, 10)
col:Row():Btn("Button 1", 100, 20, onBtn1Click)
col:MoveY(-30):Row():Btn("Button 2", 100, 20, onBtn2Click)
col:MoveY(-30):Row():Check("Option", onOptionChange)
```

### Benefits

1. **Less Math:** No hardcoded y-offsets
2. **Maintainability:** Changing layout means changing column call
3. **Consistency:** All controls have uniform spacing
4. **Readability:** You can see the visual layout in the code

---

## 3. Configuration Layering & Fallbacks

### Overview

Configuration should have a clear fallback chain:

```
Profile Config (user-specific) 
→ Unit Defaults (e.g., boss frame vs party frame)
→ Global Defaults (addon defaults)
→ Hard-Coded Values
```

### API

```lua
-- Resolve a config value through the fallback chain
local value = Arch.ResolveConfig(
    unitDB,              -- User profile for this unit
    "HealthBar",         -- Section name
    "Height",            -- Config key
    unitDefault.Height,  -- Unit-specific fallback
    globalDefault.Height -- Global fallback
)

-- Capture current config state (snapshot)
local snap = Arch.CaptureConfigState(db, {"Key1", "Key2", "Key3"})

-- Restore from snapshot
Arch.RestoreConfigState(db, snap)
```

### Implementation Pattern

**In Core/Defaults.lua:**
```lua
UUF.defaults = {
    Units = {
        player = {
            HealthBar = {
                Enabled = true,
                Height = 24,
                Width = 200,
            }
        },
        target = {
            HealthBar = {
                Enabled = true,
                Height = 20,
                Width = 150,
            }
        },
        -- Global fallback for any unit not specified
        ["*"] = {
            HealthBar = {
                Enabled = true,
                Height = 16,
                Width = 100,
            }
        }
    }
}
```

**In Elements/HealthBar.lua:**
```lua
function UUF:UpdateUnitHealthBar(unitFrame, unit)
    local normalizedUnit = UUF:GetNormalizedUnit(unit)
    local unitDB = UUF.db.profile.Units[normalizedUnit]
    local defaults = UUF.defaults.Units
    
    -- Resolve with fallback chain
    local height = Arch.ResolveConfig(
        unitDB,
        "HealthBar", "Height",
        defaults[normalizedUnit] and defaults[normalizedUnit].HealthBar.Height,
        defaults["*"].HealthBar.Height
    )
    
    local width = Arch.ResolveConfig(
        unitDB,
        "HealthBar", "Width",
        defaults[normalizedUnit] and defaults[normalizedUnit].HealthBar.Width,
        defaults["*"].HealthBar.Width
    )
    
    unitFrame.HealthBar:SetSize(width, height)
end
```

### Version Handling Pattern

```lua
-- When changing config schema version
function UUF:MigrateProfileVersion()
    local db = UUF.db.profile
    
    if db.version < 2 then
        -- Migrate from v1 to v2
        for unit, config in pairs(db.Units) do
            if config.OldKey then
                config.NewKey = config.OldKey
                config.OldKey = nil
            end
        end
        db.version = 2
    end
    
    if db.version < 3 then
        -- Migrate from v2 to v3
        -- ... more migrations
        db.version = 3
    end
end
```

---

## 4. Frame Pooling & State Management

### Overview

Instead of creating/destroying frames constantly, maintain a pool of
reusable frames to reduce GC pressure.

### Frame Pool API

```lua
-- Create a reusable pool
local pool = Arch.CreateFramePool("Button", containerFrame, "UIPanelButtonTemplate")

-- Acquire a frame from pool
local btn = pool:Acquire()
btn:SetText("Hello")
btn:Show()

-- Release back to pool
pool:Release(btn)

-- Release all active frames at once
pool:ReleaseAll()

-- Check pool stats
local total, available, active = pool:GetCount()
print(string.format("Total: %d, Available: %d, Active: %d", total, available, active))
```

### Frame State Management

```lua
-- Create state object for a frame
local state = Arch.CreateFrameState(frame, unitID, unitConfig)

-- Mark sections as needing update
state:SetDirty("auras")
state:SetDirty("indicators")

-- Check if section needs update
if state:IsDirty("auras") then
    UpdateAuras(frame)
    state:ClearDirty("auras")
end

-- Stamp-based change detection (built-in)
if state:Stamp("castbar", castingUnit, spellID) then
    -- Values changed, update castbar
    UpdateCastbar(frame)
end

-- Clear all dirty flags (end of frame update cycle)
state:ClearAllDirty()
```

### Practical Example: Aura Button Pool

**Before (create/destroy every update):**
```lua
function UpdateAuras(unitFrame, unit)
    -- Clear old buttons
    for i = 1, #unitFrame.auraButtons do
        unitFrame.auraButtons[i]:Hide()
    end
    unitFrame.auraButtons = {}
    
    -- Create new buttons
    local auras = UnitAura(unit, "HELPFUL", 5)
    if auras then
        for i = 1, #auras do
            local btn = CreateFrame("Button", nil, unitFrame, "BackdropTemplate")
            -- ... setup button ...
            table.insert(unitFrame.auraButtons, btn)
        end
    end
end
```

**After (with pooling):**
```lua
local auraPool = Arch.CreateFramePool("Button", UIParent, "BackdropTemplate")

function UpdateAuras(unitFrame, unit)
    -- Release all buttons back to pool
    if unitFrame.auraButtons then
        for i = 1, #unitFrame.auraButtons do
            auraPool:Release(unitFrame.auraButtons[i])
        end
    end
    unitFrame.auraButtons = {}
    
    -- Acquire buttons from pool
    local auras = UnitAura(unit, "HELPFUL", 5)
    if auras then
        for i = 1, #auras do
            local btn = auraPool:Acquire()
            -- ... setup button ...
            table.insert(unitFrame.auraButtons, btn)
        end
    end
end
```

---

## 5. Safe Value Handling

### Overview

WoW 12.0.0+ introduced "secret values" for security. These can error on
equality checks or arithmetic. Safe handling is critical.

### Patterns

```lua
-- Safe comparison (always safe)
if Arch.SafeCompare(val1, val2) then
    -- Values are equal
end

-- Safe function call
local ok, result = Arch.SafeValue(UnitHealth, "player")
if ok then
    print("Health:", result)
end

-- Check if value is secret (userdata without access)
if Arch.IsSecretValue(val) then
    print("Cannot compare or manipulate this value!")
end

-- Safe text formatting (never compare secret values in format args)
local health = UnitHealth("player")
local healthStr = tostring(health)  -- Safe: converts to string without comparison
```

### Secret Value Best Practices

✅ **DO:**
- Use `pcall()` for value access
- Pass secret values directly to SetText (API handles it)
- Format strings using C-side formatters when available
- Type-check before arithmetic

❌ **DON'T:**
- Compare secret values with `==`
- Do arithmetic on secret values
- Store secret values in tables as keys
- Try to convert to string for comparison

---

## 6. Integration Roadmap: Phase 3 & Beyond

### Recommended Implementation Order

#### Phase 3a: EventBus Integration (2 hours)
1. Create global event handler in Core.lua using EventBus
2. Move common UNIT_* event registrations into element code
3. Test event dispatch without breaking existing handlers
4. Measure: Should have single event routing point

#### Phase 3b: GUI Modernization (2 hours)
1. Refactor Config/GUI.lua to use Arch.LayoutColumn
2. Replace hardcoded button/checkbox positions
3. Add layout adjustment callbacks (scale, spacing)
4. Measure: ~50 lines of code reduction in GUI.lua

#### Phase 3c: Config Layering (1 hour)
1. Update Defaults.lua to include unit-specific defaults
2. Refactor element code to use Arch.ResolveConfig
3. Add config migration for future schema changes
4. Test: Profile switching, unit-specific config

#### Phase 3d: Frame Pooling (1-2 hours)
1. Add pooling to high-frequency frames (aura buttons, indicators)
2. Implement frame state tracking
3. Profile memory usage before/after
4. Measure: Should reduce GC pressure 20-40%

#### Phase 3e: Architecture Testing (1 hour)
1. Validate all pattern implementations
2. Performance benchmarking
3. Edge case testing (profile switches, combat lockdown)
4. Documentation review

### Estimated Total Effort
- **Phase 3a-e:** ~7-8 hours
- **Expected Impact:** 10-20% performance gain, significantly cleaner codebase
- **Risk Level:** Low (changes are additive, can be adopted incrementally)

---

## 7. Comparison: Current vs. After Architecture Integration

| Metric | Current | After Arch | Improvement |
|--------|---------|------------|------------|
| Event routing points | Many (scattered) | 1 (EventBus) | -90% complexity |
| GUI hardcoding | Yes (every frame) | No (layout helpers) | -50% code |
| Config fallback chain | Limited | Full (profile→unit→global) | +50% flexibility |
| Frame create/destroy GC | High | Low (pooling) | -40% GC |
| Dirty flag tracking | Manual | Automatic (state) | +productivity |
| Safe value handling | Partial | Full (Arch helpers) | +security |

---

## 8. Reference: API Quick Reference

### EventBus
```lua
Arch.EventBus:Register(event, key, fn, once)
Arch.EventBus:Unregister(event, key)
Arch.EventBus:Dispatch(event, ...)
Arch.EventBus.safeCalls = bool
```

### GUI Layout
```lua
local col = Arch.LayoutColumn(parent, x, y, rowH, gap)
col:Row(h):Btn(text, w, h, fn):Gap(10):Text(label)
col:MoveY(dy):At(x, y):Reset()
```

### Config
```lua
Arch.ResolveConfig(unitDB, section, key, unitDefault, globalDefault)
Arch.CaptureConfigState(db, keys)
Arch.RestoreConfigState(db, snapshot)
```

### Frame State
```lua
local state = Arch.CreateFrameState(frame, unitID, config)
state:SetDirty(key) / state:IsDirty(key) / state:ClearDirty(key)
if state:Stamp(key, ...) then -- changed end
```

### Frame Pool
```lua
local pool = Arch.CreateFramePool(frameType, parent, template)
local frame = pool:Acquire()
pool:Release(frame)
pool:ReleaseAll()
```

### Safe Values
```lua
Arch.SafeValue(fn, ...)  -- Returns (ok, result)
Arch.SafeCompare(val1, val2)
Arch.IsSecretValue(val)
```

---

## 9. Next Steps

1. **Review Architecture.lua** - Ensure all APIs meet your needs
2. **Test EventBus** - Try with a non-critical event first
3. **GUI prototype** - Create one config panel using LayoutColumn
4. **Frame pooling POC** - Add pooling to aura buttons
5. **Measure impact** - Profile before/after each change
6. **Document patterns** - Create style guide for team

---

## 10. Troubleshooting

**EventBus handlers not firing?**
- Check: Is event registered? Use `Arch.EventBus._frame:IsEventRegistered(event)`
- Check: Is handler key unique? Duplicates are rejected silently
- Enable safeCalls: `Arch.EventBus.safeCalls = true` for error info

**Config fallback not resolving?**
- Check: Are tables empty? Use explicit `nil` checks
- Check: Is unit normalized? Use `UUF:GetNormalizedUnit(unit)`
- Test: Call each fallback level independently

**Frame pool memory not reducing?**
- Check: Are frames being released? Log `pool:GetCount()`
- Check: Are old frames still referenced elsewhere?
- Use `pool:ReleaseAll()` to force cleanup

**GUI layout jumping?**
- Check: Row heights consistent?
- Check: All elements properly anchored?
- Use `:Reset()` before rebuild if reusing layout object

---

**Document Version:** 2.0  
**Last Updated:** Phase 2 Complete  
**Status:** Ready for Phase 3 Implementation  
**Author:** UUF Development Team
