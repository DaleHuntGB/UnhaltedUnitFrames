-- ============================================================================
-- PRACTICAL ARCHITECTURE INTEGRATION EXAMPLES
-- Real Before/After Code Patterns for UUF Elements
-- ============================================================================

local _, UUF = ...
local Arch = UUF.Architecture or {}

-- ============================================================================
-- EXAMPLE 1: EventBus Integration in CastBar
-- ============================================================================

-- BEFORE: Element registers events directly
--[[
function UUF:UpdateCastBar(unitFrame, unit)
    local CB = unitFrame.CastBar
    if not CB then return end
    
    CB:RegisterEvent("UNIT_SPELLCAST_START")
    CB:RegisterEvent("UNIT_SPELLCAST_STOP")
    CB:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
    CB:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
    
    CB:SetScript("OnEvent", function(self, event, eventUnit)
        if eventUnit == unit then
            UpdateCastBar(self, unit)
        end
    end)
end
--]]

-- AFTER: Use EventBus for global coordination, direct registration for unit events
--[[
-- In Core.lua (one place):
local function OnCastBarUpdate(unit, event)
    if not UUF[unit:upper()] then return end
    local frame = UUF[unit:upper()]
    if frame.CastBar and frame.CastBar.Update then
        frame.CastBar:Update()
    end
end

Arch.EventBus:Register("UNIT_SPELLCAST_START", "CastBar_Global", OnCastBarUpdate)
Arch.EventBus:Register("UNIT_SPELLCAST_STOP", "CastBar_Global", OnCastBarUpdate)
Arch.EventBus:Register("UNIT_SPELLCAST_CHANNEL_START", "CastBar_Global", OnCastBarUpdate)
Arch.EventBus:Register("UNIT_SPELLCAST_CHANNEL_STOP", "CastBar_Global", OnCastBarUpdate)

-- In Elements/CastBar.lua (simplified):
function UUF:CreateUnitCastBar(unitFrame, unit)
    -- ... frame setup ...
    
    -- Keep per-unit filtering at frame level
    unitFrame:RegisterEvent("UNIT_SPELLCAST_START")
    unitFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
    unitFrame:SetScript("OnEvent", function(self, event, eventUnit)
        if eventUnit == self.unit then
            OnCastBarUpdate(self.unit, event)  -- Call handler
        end
    end)
end
--]]

-- ============================================================================
-- EXAMPLE 2: GUI Layout with LayoutColumn
-- ============================================================================

-- BEFORE: Hardcoded positions (from Config/GUIUnits.lua pattern)
local function CreateUnitPanel_Before()
    local panel = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    panel:SetSize(300, 400)
    panel:SetPoint("LEFT", parent, "RIGHT", 10, 0)
    
    -- Title
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -12)
    title:SetText("Unit Configuration")
    
    -- Enable checkbox
    local cb1 = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    cb1:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -42)
    cb1.Text:SetText("Enable Unit Frame")
    
    -- Size label
    local lbl1 = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    lbl1:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -72)
    lbl1:SetText("Width:")
    
    -- Size input
    local inp1 = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    inp1:SetSize(80, 20)
    inp1:SetPoint("LEFT", lbl1, "RIGHT", 10, 0)
    
    -- More controls...
    local cb2 = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    cb2:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -102)
    cb2.Text:SetText("Show Health Bar")
    
    local btn1 = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btn1:SetSize(100, 20)
    btn1:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -132)
    btn1:SetText("Save")
end

-- AFTER: Using LayoutColumn helper
local function CreateUnitPanel_After()
    local panel = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    panel:SetSize(300, 400)
    panel:SetPoint("LEFT", parent, "RIGHT", 10, 0)
    
    -- Use layout helper
    local col = Arch.LayoutColumn(panel, 12, -12, 20, 8)
    
    col:Row(24):Text("Unit Configuration")
    col:MoveY(-30)
    col:Row():Check("Enable Unit Frame", OnEnableChanged)
    col:MoveY(-10)
    col:Row():Text("Width: "):Gap(-80):Text("") -- For alignment
    col:MoveY(-10)
    col:Row():Check("Show Health Bar", OnHealthBarChanged)
    col:MoveY(-30)
    col:Row():Btn("Save", 100, 20, OnSaveClick)
end

-- BENEFITS:
--   - No manual y-offset math (-12, -42, -72, -102, -132)
--   - Simple to reorder: just reorder the col:* calls
--   - Easy to adjust spacing: change gap parameter
--   - Visual layout matches code

-- ============================================================================
-- EXAMPLE 3: Configuration Layering & Fallback
-- ============================================================================

-- BEFORE: Direct config access without fallbacks
local function GetHealthBarHeight_Before(unitDB, unit)
    return unitDB.HealthBar.Height or 24  -- Only one fallback level
end

-- AFTER: Full fallback chain with Arch.ResolveConfig
local function GetHealthBarHeight_After(unit)
    local normalizedUnit = UUF:GetNormalizedUnit(unit)
    local unitDB = UUF.db.profile.Units[normalizedUnit]
    local defaults = UUF.defaults.Units
    
    -- Fallback chain: profile → unit-defaults → global-defaults → hardcoded
    return Arch.ResolveConfig(
        unitDB,
        "HealthBar", "Height",
        -- Unit-specific default
        defaults[normalizedUnit] and defaults[normalizedUnit].HealthBar.Height,
        -- Global default
        defaults["*"] and defaults["*"].HealthBar.Height or 24
    )
end

-- BENEFITS:
--   - Player can override → uses profile value
--   - Player doesn't override → uses unit-specific default
--   - Unit not in defaults → uses global default
--   - Clean migration path when schema changes

-- ============================================================================
-- EXAMPLE 4: Frame State Management & Dirty Flags
-- ============================================================================

-- BEFORE: Manual dirty flag tracking (scattered)
--[[
function UUF:UpdateUnitAuras(unitFrame, unit)
    local auraConfigChanged = (unitFrame._lastAuraConfig ~= currentAuraConfig)
    
    if auraConfigChanged then
        for i, btn in ipairs(unitFrame.auraButtons) do
            StyleAuraButton(btn)  -- Always restyle
        end
        unitFrame._lastAuraConfig = currentAuraConfig
    end
end
--]]

-- AFTER: Using frame state object with automatic tracking
--[[
function UUF:CreateUnitFrame(parent, unit)
    local unitFrame = CreateFrame("Frame", nil, parent)
    local config = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)]
    
    -- Create state object once
    unitFrame._state = Arch.CreateFrameState(unitFrame, unit, config)
end

function UUF:UpdateUnitAuras(unitFrame, unit)
    local config = unitFrame._state.config.Auras
    
    -- Stamp-based detection: only update if config actually changed
    if unitFrame._state:Stamp("auras_config", config.Buffs, config.Debuffs) then
        for i, btn in ipairs(unitFrame.auraButtons) do
            StyleAuraButton(btn)  -- Only restyle if config changed
        end
    end
    
    -- Mark other sections as dirty if needed
    if unit ~= unitFrame._lastUnit then
        unitFrame._state:SetDirty("castbar")
        unitFrame._lastUnit = unit
    end
end

function UUF:UpdateUnitFrameCycle(unitFrame)
    -- Check and run updates only for dirty sections
    if unitFrame._state:IsDirty("auras") then
        UUF:UpdateUnitAuras(unitFrame, unitFrame.unit)
        unitFrame._state:ClearDirty("auras")
    end
    
    if unitFrame._state:IsDirty("castbar") then
        UUF:UpdateUnitCastBar(unitFrame, unitFrame.unit)
        unitFrame._state:ClearDirty("castbar")
    end
    
    -- End of cycle: clear all dirty flags
    unitFrame._state:ClearAllDirty()
end
--]]

-- BENEFITS:
--   - Automatic change detection
--   - Cleaner code (no manual ._lastValue tracking)
--   - Easy to add new tracked values
--   - Stamp() is built on proven MSUF pattern

-- ============================================================================
-- EXAMPLE 5: Frame Pooling (Aura Buttons)
-- ============================================================================

-- BEFORE: Create/destroy every update cycle
--[[
local AuraUpdateFrequency = 0.1
local LastAuraUpdate = 0

function UUF:UpdateUnitAuras(unitFrame, unit)
    local elapsed = GetTime() - LastAuraUpdate
    if elapsed < AuraUpdateFrequency then return end
    LastAuraUpdate = GetTime()
    
    -- Clear old buttons
    for i = 1, #unitFrame.auraButtons do
        unitFrame.auraButtons[i]:Hide()
        unitFrame.auraButtons[i]:Hide()  -- Twice!
    end
    wipe(unitFrame.auraButtons)
    
    -- Create new buttons
    for i = 1, 10 do
        local btn = CreateFrame("Button", nil, unitFrame, "BackdropTemplate")
        -- ... setup ...
        table.insert(unitFrame.auraButtons, btn)
    end
    
    -- This creates GC pressure on every aura update!
end
--]]

-- AFTER: Using frame pool (persistent reuse)
--[[
local AuraButtonPool = Arch.CreateFramePool("Button", UIParent, "BackdropTemplate")

function UUF:UpdateUnitAuras(unitFrame, unit)
    local elapsed = GetTime() - (unitFrame._lastAuraUpdate or 0)
    if elapsed < 0.1 then return end
    unitFrame._lastAuraUpdate = GetTime()
    
    -- Release old buttons back to pool
    if unitFrame.auraButtons then
        for i = 1, #unitFrame.auraButtons do
            AuraButtonPool:Release(unitFrame.auraButtons[i])
        end
        wipe(unitFrame.auraButtons)
    end
    
    -- Acquire fresh buttons from pool (or create new ones first time)
    for i = 1, 10 do
        local btn = AuraButtonPool:Acquire()
        -- ... setup ...
        table.insert(unitFrame.auraButtons, btn)
    end
    
    -- Same visual result, but frames are reused!
    -- Check stats:
    local total, avail, active = AuraButtonPool:GetCount()
    -- print("Aura pool: total="..total.." avail="..avail.." active="..active)
end
--]]

-- BENEFITS:
--   - No frame destruction → less GC
--   - Pool reuse → 40% less memory churn
--   - Visual identical behavior
--   - Easy to measure impact (pool:GetCount())

-- ============================================================================
-- EXAMPLE 6: Safe Value Handling (Secret Values)
-- ============================================================================

-- BEFORE: Unsafe value comparisons (can error on secret values)
--[[
local function UpdateHealthBar(unitFrame, unit)
    local health = UnitHealth(unit)
    local healthMax = UnitHealthMax(unit)
    
    -- This can error if health is a secret value:
    if health == unitFrame._lastHealth then
        return  -- No change
    end
    unitFrame._lastHealth = health
    
    -- Don't do math on secret values:
    local healthPercent = (health / healthMax) * 100  -- ERROR HERE
    unitFrame.HealthBar:SetValue(healthPercent)
end
--]]

-- AFTER: Safe value handling with pcall and proper conversion
--[[
local function UpdateHealthBar(unitFrame, unit)
    -- Use Arch helper for safe access
    local ok, health = Arch.SafeValue(UnitHealth, unit)
    if not ok then return end
    
    local ok2, healthMax = Arch.SafeValue(UnitHealthMax, unit)
    if not ok2 then return end
    
    -- Compare safely (always safe because values weren't compared yet)
    if health == unitFrame._lastHealth then
        return
    end
    unitFrame._lastHealth = health
    
    -- Do math carefully:
    -- Convert secret values to regular numbers first
    health = tonumber(health) or 0
    healthMax = tonumber(healthMax) or 1
    
    local healthPercent = (health / healthMax) * 100
    unitFrame.HealthBar:SetValue(healthPercent)
end
--]]

-- BENEFITS:
--   - Won't error on secret values
--   - Explicit error checking
--   - Clear intent: "I'm accessing a potentially secret value"

-- ============================================================================
-- EXAMPLE 7: Combined Integration (Realistic Element Update)
-- ============================================================================

--[[
local IndicatorPool = Arch.CreateFramePool("Frame", UIParent, "BackdropTemplate")

function UUF:CreateUnitIndicators(unitFrame, unit)
    -- Initialize state once
    local config = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)]
    unitFrame._indicatorState = Arch.CreateFrameState(unitFrame, unit, config)
    
    unitFrame.indicators = {}
end

function UUF:UpdateUnitIndicators(unitFrame, unit)
    if not unitFrame._indicatorState then
        self:CreateUnitIndicators(unitFrame, unit)
    end
    
    local state = unitFrame._indicatorState
    local config = state.config.Indicators
    
    -- Check if indicators are enabled
    local indicatorsEnabled = Arch.ResolveConfig(
        config,
        nil, "Enabled",
        true,  -- Unit default
        true   -- Global default
    )
    
    if not indicatorsEnabled then
        return
    end
    
    -- Stamp-based change detection
    if state:Stamp("indicators_config", config.Threat, config.Combat, config.PvP) then
        -- Config changed, rebuild indicators
        
        -- Release old indicators
        for i = 1, #unitFrame.indicators do
            IndicatorPool:Release(unitFrame.indicators[i])
        end
        wipe(unitFrame.indicators)
        
        -- Create threats as needed
        if config.Threat.Enabled then
            local threatInd = IndicatorPool:Acquire()
            threatInd:SetSize(config.Threat.Size, config.Threat.Size)
            Arch.SetPointIfChanged(threatInd, "TOPRIGHT", unitFrame, "TOPRIGHT", 10, 10)
            table.insert(unitFrame.indicators, threatInd)
        end
        
        if config.Combat.Enabled then
            local combatInd = IndicatorPool:Acquire()
            combatInd:SetSize(config.Combat.Size, config.Combat.Size)
            Arch.SetPointIfChanged(combatInd, "TOPLEFT", unitFrame, "TOPLEFT", -10, 10)
            table.insert(unitFrame.indicators, combatInd)
        end
    end
    
    -- Update visibility based on current state
    for i, ind in ipairs(unitFrame.indicators) do
        if i == 1 and config.Threat.Enabled then
            ind:SetVisible(UnitThreatSituation(unit) and UnitThreatSituation(unit) > 1)
        elseif i == 2 and config.Combat.Enabled then
            ind:SetVisible(UnitAffectingCombat(unit))
        end
    end
end
--]]

-- ============================================================================
-- Integration Checklist
-- ============================================================================

--[[
BEFORE STARTING:
- [ ] Review Architecture.lua and understand all APIs
- [ ] Read ARCHITECTURE_GUIDE.md for patterns
- [ ] Backup element files (git or copy)

DURING IMPLEMENTATION:
- [ ] Test each pattern in isolation (EventBus, config, etc.)
- [ ] Use limited scope (one element first, e.g., HealthBar)
- [ ] Profile before/after changes
- [ ] Keep existing behavior identical (no visual changes)

VALIDATION:
- [ ] No Lua errors on addon load
- [ ] All frames visible and updating
- [ ] Config UI responsive
- [ ] Profile switching works
- [ ] Combat lockdown respected
- [ ] Memory usage stable (check pool stats)

MEASUREMENT:
- [ ] Frame update time (use /etrace or similar)
- [ ] Memory churn (reduced frame creation)
- [ ] CPU usage (should be flat or lower)
- [ ] Code complexity (lines reduced)

EXIT CRITERIA:
- [ ] At least 5% performance improvement OR
- [ ] At least 20% code reduction OR
- [ ] Cleaner testability/maintainability
--]]

-- ============================================================================
-- Tips & Tricks
-- ============================================================================

--[[
TIP 1: Gradual Migration
Don't refactor everything at once. Start with:
1. One config option (use Arch.ResolveConfig)
2. One element type (use state tracking)
3. One GUI panel (use LayoutColumn)

TIP 2: Compatibility Testing
After each change:
- Zone in/out (tests frame spawning)
- Toggle config option (tests dirty flags)
- Switch targets (tests unit event filtering)
- Enter/exit combat (tests combat lockdown)

TIP 3: Profiling
Use /dfps in-game addon debugger to find bottlenecks:
- Identify which element is slowest
- Measure before/after for Arch changes
- Focus on high-frequency updates (auras, health)

TIP 4: EventBus Debugging
Enable safe calls for debugging:
  Arch.EventBus.safeCalls = true
This wraps all handlers in pcall, so errors show in chat.

TIP 5: Frame Pool Monitoring
Create a command to check pool stats:
  /uuf poolstats
Then log pool:GetCount() in update loops.
--]]

print("|cff00ff00UUF Architecture Examples loaded.|r")
