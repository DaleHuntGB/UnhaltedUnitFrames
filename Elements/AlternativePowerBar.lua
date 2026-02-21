local _, UUF = ...

local ALTERNATIVE_POWER_BAR_EVENTS = {
    "UNIT_POWER_UPDATE",
    "UNIT_MAXPOWER",
    "UNIT_DISPLAYPOWER",
}
local IsSecretValue = issecretvalue or function() return false end
local ALT_POWER_COALESCE_EVENT = "UUF_ALT_POWER_BAR_UPDATE"
local altPowerCoalesceRegistered = false

local function ResolveSecondaryPowerType(unit)
    if GetUnitSecondaryPowerInfo then
        local powerType = GetUnitSecondaryPowerInfo(unit)
        if powerType ~= nil and not IsSecretValue(powerType) then
            return powerType
        end
    end
    return Enum.PowerType.Mana
end

local function ApplyAlternativePowerBarColor(AlternativePowerBar)
    if not AlternativePowerBar or not AlternativePowerBar.Status or not UUF or not UUF.db then return end
    local unit = AlternativePowerBar.unit
    if not unit then return end
    local UUFDB = UUF.db.profile
    local AlternativePowerBarDB = UUFDB.Units[UUF:GetNormalizedUnit(unit)].AlternativePowerBar
    if not AlternativePowerBarDB then return end

    if AlternativePowerBarDB.ColourByType then
        local powerColour = UUFDB.General.Colours.Power[AlternativePowerBar.powerType or 0]
        if powerColour then
            AlternativePowerBar.Status:SetStatusBarColor(powerColour[1], powerColour[2], powerColour[3], powerColour[4])
        end
    else
        AlternativePowerBar.Status:SetStatusBarColor(
            AlternativePowerBarDB.Foreground[1],
            AlternativePowerBarDB.Foreground[2],
            AlternativePowerBarDB.Foreground[3],
            AlternativePowerBarDB.Foreground[4]
        )
    end
end

local function UpdateUnitPowerBarValues(unitFrame, event, unit)
    if unit and unit ~= unitFrame.unit then return end
    if not UnitExists(unitFrame.unit) then return end

    local powerType = unitFrame.powerType or Enum.PowerType.Mana
    local value = UnitPower(unitFrame.unit, powerType)
    unitFrame.Status:SetMinMaxValues(0, UnitPowerMax(unitFrame.unit, powerType))
    unitFrame.Status:SetValue(value)
end

local function EnsureAltPowerCoalescer()
    if altPowerCoalesceRegistered then return end
    if not UUF.EventCoalescer then return end

    UUF.EventCoalescer:CoalesceEvent(ALT_POWER_COALESCE_EVENT, 0.05, function(frameCastBar, event, unit)
        if not frameCastBar then return end
        if event == "UNIT_DISPLAYPOWER" then
            frameCastBar.powerType = ResolveSecondaryPowerType(frameCastBar.unit)
            ApplyAlternativePowerBarColor(frameCastBar)
        end
        UpdateUnitPowerBarValues(frameCastBar, event, unit)
    end, 2)
    UUF.EventCoalescer:SetEventDelay(ALT_POWER_COALESCE_EVENT, 0.05)

    altPowerCoalesceRegistered = true
end

local function AlternativePowerBarOnEvent(self, event, unit)
    if UUF.EventCoalescer then
        EnsureAltPowerCoalescer()
        local accepted = UUF.EventCoalescer:QueueEvent(ALT_POWER_COALESCE_EVENT, self, event, unit)
        if not accepted then
            if event == "UNIT_DISPLAYPOWER" then
                self.powerType = ResolveSecondaryPowerType(self.unit)
                ApplyAlternativePowerBarColor(self)
            end
            UpdateUnitPowerBarValues(self, event, unit)
        end
    else
        if event == "UNIT_DISPLAYPOWER" then
            self.powerType = ResolveSecondaryPowerType(self.unit)
            ApplyAlternativePowerBarColor(self)
        end
        UpdateUnitPowerBarValues(self, event, unit)
    end
end

local function ConfigureAlternativePowerBarEvents(AlternativePowerBar, enabled, unit)
    if not AlternativePowerBar then return end

    if enabled then
        if AlternativePowerBar._eventsRegistered and AlternativePowerBar.unit == unit then
            return
        end
        AlternativePowerBar:UnregisterAllEvents()
        AlternativePowerBar:RegisterEvent("PLAYER_ENTERING_WORLD")
        for _, event in ipairs(ALTERNATIVE_POWER_BAR_EVENTS) do
            AlternativePowerBar:RegisterUnitEvent(event, unit)
        end
        AlternativePowerBar:SetScript("OnEvent", AlternativePowerBarOnEvent)
        AlternativePowerBar._eventsRegistered = true
    else
        AlternativePowerBar:UnregisterAllEvents()
        AlternativePowerBar:SetScript("OnEvent", nil)
        AlternativePowerBar._eventsRegistered = false
    end
end

function UUF:CreateUnitAlternativePowerBar(unitFrame, unit)
    local UUFDB = UUF.db.profile
    local AlternativePowerBarDB = UUFDB.Units[UUF:GetNormalizedUnit(unit)].AlternativePowerBar
    local unitContainer = unitFrame.Container
    local frameName = unitFrame:GetName() or UUF:FetchFrameName(unit)

    local AlternativePowerBar = CreateFrame("Frame", frameName.."_AlternativePowerBar", unitContainer, "BackdropTemplate")
    UUF:QueueOrRun(function()
        AlternativePowerBar:SetPoint(AlternativePowerBarDB.Layout[1], unitContainer, AlternativePowerBarDB.Layout[2], AlternativePowerBarDB.Layout[3], AlternativePowerBarDB.Layout[4])
        AlternativePowerBar:SetSize(AlternativePowerBarDB.Width, AlternativePowerBarDB.Height)
        AlternativePowerBar:SetBackdrop(UUF.BACKDROP)
        AlternativePowerBar:SetBackdropColor(AlternativePowerBarDB.Background[1], AlternativePowerBarDB.Background[2], AlternativePowerBarDB.Background[3], AlternativePowerBarDB.Background[4])
        AlternativePowerBar:SetBackdropBorderColor(0, 0, 0, 1)
        AlternativePowerBar:SetFrameLevel(unitContainer:GetFrameLevel() + 5)
    end)

    AlternativePowerBar.Status = CreateFrame("StatusBar", frameName.."_AlternativePowerBarStatus", AlternativePowerBar)
    UUF:QueueOrRun(function()
        AlternativePowerBar.Status:SetPoint("TOPLEFT", AlternativePowerBar, "TOPLEFT", 1, -1)
        AlternativePowerBar.Status:SetPoint("BOTTOMRIGHT", AlternativePowerBar, "BOTTOMRIGHT", -1, 1)
        AlternativePowerBar.Status:SetSize(AlternativePowerBarDB.Width, AlternativePowerBarDB.Height)
        AlternativePowerBar.Status:SetStatusBarTexture(UUF.Media.Foreground)
        AlternativePowerBar.Status:SetFrameLevel(AlternativePowerBar:GetFrameLevel() + 1)
    end)
    AlternativePowerBar.unit = unit
    AlternativePowerBar.powerType = ResolveSecondaryPowerType(unit)

    ApplyAlternativePowerBarColor(AlternativePowerBar)

    if AlternativePowerBarDB.Inverse then
        AlternativePowerBar.Status:SetReverseFill(true)
    else
        AlternativePowerBar.Status:SetReverseFill(false)
    end

    if AlternativePowerBarDB.Enabled and UUF:RequiresAlternativePowerBar() then
        UUF:QueueOrRun(function() AlternativePowerBar:Show() end)
        ConfigureAlternativePowerBarEvents(AlternativePowerBar, true, unit)
        UpdateUnitPowerBarValues(AlternativePowerBar)
    else
        UUF:QueueOrRun(function() AlternativePowerBar:Hide() end)
        ConfigureAlternativePowerBarEvents(AlternativePowerBar, false, unit)
    end

    unitFrame.AlternativePowerBar = AlternativePowerBar
    return AlternativePowerBar
end

function UUF:UpdateUnitAlternativePowerBar(unitFrame, unit)
    local UUFDB = UUF.db.profile
    local AlternativePowerBarDB = UUFDB.Units[UUF:GetNormalizedUnit(unit)].AlternativePowerBar
    local AlternativePowerBar = unitFrame.AlternativePowerBar
    if not AlternativePowerBar then return end

    AlternativePowerBar:ClearAllPoints()
    UUF:QueueOrRun(function()
        AlternativePowerBar:SetPoint(AlternativePowerBarDB.Layout[1], unitFrame.Container, AlternativePowerBarDB.Layout[2], AlternativePowerBarDB.Layout[3], AlternativePowerBarDB.Layout[4])
        AlternativePowerBar:SetSize(AlternativePowerBarDB.Width, AlternativePowerBarDB.Height)
        AlternativePowerBar:SetBackdropColor(AlternativePowerBarDB.Background[1], AlternativePowerBarDB.Background[2], AlternativePowerBarDB.Background[3], AlternativePowerBarDB.Background[4])

        AlternativePowerBar.Status:ClearAllPoints()
        AlternativePowerBar.Status:SetPoint("TOPLEFT", AlternativePowerBar, "TOPLEFT", 1, -1)
        AlternativePowerBar.Status:SetPoint("BOTTOMRIGHT", AlternativePowerBar, "BOTTOMRIGHT", -1, 1)
        AlternativePowerBar.Status:SetSize(AlternativePowerBarDB.Width, AlternativePowerBarDB.Height)
    end)
    AlternativePowerBar.powerType = ResolveSecondaryPowerType(unit)

    ApplyAlternativePowerBarColor(AlternativePowerBar)

    if AlternativePowerBarDB.Inverse then
        AlternativePowerBar.Status:SetReverseFill(true)
    else
        AlternativePowerBar.Status:SetReverseFill(false)
    end

    if AlternativePowerBarDB.Enabled and UUF:RequiresAlternativePowerBar() then
        UUF:QueueOrRun(function() AlternativePowerBar:Show() end)
        ConfigureAlternativePowerBarEvents(AlternativePowerBar, true, unit)
        UpdateUnitPowerBarValues(AlternativePowerBar)
    else
        UUF:QueueOrRun(function() AlternativePowerBar:Hide() end)
        ConfigureAlternativePowerBarEvents(AlternativePowerBar, false, unit)
    end
end
