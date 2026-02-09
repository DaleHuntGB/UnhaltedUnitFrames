local _, UUF = ...

local ALTERNATIVE_POWER_BAR_EVENTS = {
    "UNIT_POWER_UPDATE",
    "UNIT_MAXPOWER",
    "UNIT_DISPLAYPOWER",
}

local function UpdateUnitPowerBarValues(unitFrame, event, unit)
    if unit and unit ~= unitFrame.unit then return end
    if not UnitExists(unitFrame.unit) then return end

    local value = UnitPower(unitFrame.unit, Enum.PowerType.Mana)
    unitFrame.Status:SetMinMaxValues(0, UnitPowerMax(unitFrame.unit, Enum.PowerType.Mana))
    unitFrame.Status:SetValue(value)
end


function UUF:CreateUnitAlternativePowerBar(unitFrame, unit)
    local UUFDB = UUF.db.profile
    local AlternativePowerBarDB = UUFDB.Units["player"].AlternativePowerBar
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
    if AlternativePowerBarDB.ColourByType then
        local powerColour = UUFDB.General.Colours.Power[0]
        if powerColour then AlternativePowerBar.Status:SetStatusBarColor(powerColour[1], powerColour[2], powerColour[3], powerColour[4]) end
    else
        AlternativePowerBar.Status:SetStatusBarColor(AlternativePowerBarDB.Foreground[1], AlternativePowerBarDB.Foreground[2], AlternativePowerBarDB.Foreground[3], AlternativePowerBarDB.Foreground[4])
    end
    AlternativePowerBar.unit = unit

    if AlternativePowerBarDB.Inverse then
        AlternativePowerBar.Status:SetReverseFill(true)
    else
        AlternativePowerBar.Status:SetReverseFill(false)
    end

    if AlternativePowerBarDB.Enabled and UUF:RequiresAlternativePowerBar() then
        UUF:QueueOrRun(function() AlternativePowerBar:Show() end)
        AlternativePowerBar:RegisterEvent("PLAYER_ENTERING_WORLD")
        for _, event in ipairs(ALTERNATIVE_POWER_BAR_EVENTS) do
            AlternativePowerBar:RegisterUnitEvent(event, unit)
        end
        AlternativePowerBar:SetScript("OnEvent", UpdateUnitPowerBarValues)
    else
        UUF:QueueOrRun(function() AlternativePowerBar:Hide() end)
        AlternativePowerBar:UnregisterAllEvents()
        AlternativePowerBar:SetScript("OnEvent", nil)
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
    if AlternativePowerBarDB.ColourByType then
        local powerColour = UUFDB.General.Colours.Power[0]
        if powerColour then AlternativePowerBar.Status:SetStatusBarColor(powerColour[1], powerColour[2], powerColour[3], powerColour[4]) end
    else
        AlternativePowerBar.Status:SetStatusBarColor(AlternativePowerBarDB.Foreground[1], AlternativePowerBarDB.Foreground[2], AlternativePowerBarDB.Foreground[3], AlternativePowerBarDB.Foreground[4])
    end

    if AlternativePowerBarDB.Inverse then
        AlternativePowerBar.Status:SetReverseFill(true)
    else
        AlternativePowerBar.Status:SetReverseFill(false)
    end

    if AlternativePowerBarDB.Enabled and UUF:RequiresAlternativePowerBar() then
        UUF:QueueOrRun(function() AlternativePowerBar:Show() end)
        AlternativePowerBar:Show()
        AlternativePowerBar:RegisterEvent("PLAYER_ENTERING_WORLD")
        for _, event in ipairs(ALTERNATIVE_POWER_BAR_EVENTS) do
            AlternativePowerBar:RegisterUnitEvent(event, unit)
        end
        AlternativePowerBar:SetScript("OnEvent", UpdateUnitPowerBarValues)
    else
        UUF:QueueOrRun(function() AlternativePowerBar:Hide() end)
        AlternativePowerBar:UnregisterAllEvents()
        AlternativePowerBar:SetScript("OnEvent", nil)
    end
end