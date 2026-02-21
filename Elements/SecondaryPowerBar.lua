local _, UUF = ...

local UpdateSecondaryPowerBarEventFrame = CreateFrame("Frame")
local secondaryPowerRefreshHandle
local secondaryPowerCoalesceRegistered = false
local SECONDARY_POWER_COALESCE_EVENT = "UUF_SECONDARY_POWER_REFRESH"

local function RefreshSecondaryPowerBar()
    if UUF.PLAYER then
        UUF:UpdateUnitSecondaryPowerBar(UUF.PLAYER, "player")
    end
end

local function EnsureSecondaryPowerCoalescer()
    if secondaryPowerCoalesceRegistered or not UUF.EventCoalescer then
        return
    end
    UUF.EventCoalescer:CoalesceEvent(SECONDARY_POWER_COALESCE_EVENT, 0.08, function()
        RefreshSecondaryPowerBar()
    end, 2)
    UUF.EventCoalescer:SetEventDelay(SECONDARY_POWER_COALESCE_EVENT, 0.08)
    secondaryPowerCoalesceRegistered = true
end

local function ScheduleSecondaryPowerRefresh()
    if UUF.EventCoalescer then
        EnsureSecondaryPowerCoalescer()
        local accepted = UUF.EventCoalescer:QueueEvent(SECONDARY_POWER_COALESCE_EVENT)
        if accepted then
            return
        end
    end

    -- Fallback path if coalescer is unavailable.
    if secondaryPowerRefreshHandle then
        UUF:CancelTimer(secondaryPowerRefreshHandle)
        secondaryPowerRefreshHandle = nil
    end
    secondaryPowerRefreshHandle = UUF:ScheduleTimer("SecondaryPowerBar", 0.1, function()
        secondaryPowerRefreshHandle = nil
        RefreshSecondaryPowerBar()
    end)
end

UpdateSecondaryPowerBarEventFrame:RegisterEvent("TRAIT_CONFIG_UPDATED")
UpdateSecondaryPowerBarEventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
UpdateSecondaryPowerBarEventFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
UpdateSecondaryPowerBarEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")  -- Add this
UpdateSecondaryPowerBarEventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_SPECIALIZATION_CHANGED" then
        local unit = ...
        if unit ~= "player" then return end
    end
    ScheduleSecondaryPowerRefresh()
end)

function UUF:IsRunePower()
    local _, class = UnitClass("player")
    return class == "DEATHKNIGHT"
end

function UUF:CreateUnitSecondaryPowerBar(unitFrame, unit)
    local FrameDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Frame
    local DB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].SecondaryPowerBar
    local unitFrameContainer = unitFrame.Container

    if not DB.Enabled then return end

    local powerType = UUF:GetSecondaryPowerType()
    if not powerType and not UUF:IsRunePower() then return end

    local secondaryPowerElement = {}
    secondaryPowerElement.Ticks = {}

    local maxPower = UUF:IsRunePower() and 6 or (UnitPowerMax("player", powerType) or 6)
    local totalWidth = FrameDB.Width - 2
    local unitFrameWidth = totalWidth / maxPower

    secondaryPowerElement.ContainerBackground = unitFrameContainer:CreateTexture(nil, "BACKGROUND")
    secondaryPowerElement.ContainerBackground:SetTexture(UUF.Media.Background)

    for i = 1, maxPower do
        local secondaryPowerBar = CreateFrame("StatusBar", nil, unitFrameContainer)
        secondaryPowerBar:SetStatusBarTexture(UUF.Media.Foreground)
        secondaryPowerBar:SetMinMaxValues(0, 1)
        secondaryPowerBar.frequentUpdates = DB.Smooth
        secondaryPowerBar:Hide()

        secondaryPowerBar.Background = secondaryPowerBar:CreateTexture(nil, "BACKGROUND")
        secondaryPowerBar.Background:SetAllPoints(secondaryPowerBar)
        secondaryPowerBar.Background:SetTexture(UUF.Media.Background)

        secondaryPowerElement[i] = secondaryPowerBar
    end

    secondaryPowerElement.OverlayFrame = CreateFrame("Frame", nil, unitFrameContainer)
    secondaryPowerElement.OverlayFrame:SetFrameLevel(unitFrameContainer:GetFrameLevel() + 10)

    for i = 1, maxPower - 1 do
        local secondaryPowerBarTick = secondaryPowerElement.OverlayFrame:CreateTexture(nil, "OVERLAY")
        secondaryPowerBarTick:SetTexture("Interface\\Buttons\\WHITE8x8")
        secondaryPowerBarTick:SetDrawLayer("OVERLAY", 7)
        secondaryPowerElement.Ticks[i] = secondaryPowerBarTick
    end

    secondaryPowerElement.PowerBarBorder = secondaryPowerElement.OverlayFrame:CreateTexture(nil, "OVERLAY")
    secondaryPowerElement.PowerBarBorder:SetTexture("Interface\\Buttons\\WHITE8x8")
    secondaryPowerElement.PowerBarBorder:SetDrawLayer("OVERLAY", 6)

    secondaryPowerElement.PostUpdateColor = function(self)
        if DB.ColourByType then return end
        for i = 1, #self do
            self[i]:SetStatusBarColor(DB.Foreground[1], DB.Foreground[2], DB.Foreground[3], DB.Foreground[4] or 1)
        end
    end

    if UUF:IsRunePower() then
        secondaryPowerElement.sortOrder = "asc"
        secondaryPowerElement.colorSpec = DB.ColourByType
        unitFrame.Runes = secondaryPowerElement
    else
        unitFrame.ClassPower = secondaryPowerElement
    end

    return secondaryPowerElement
end

function UUF:UpdateUnitSecondaryPowerBar(unitFrame, unit)
    if not unitFrame then return end

    local FrameDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Frame
    local DB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].SecondaryPowerBar
    local isRunes = UUF:IsRunePower()
    local secondaryPowerBarElementName = isRunes and "Runes" or "ClassPower"

    local powerType = UUF:GetSecondaryPowerType()
    if not DB.Enabled or (not powerType and not isRunes) then
        if unitFrame[secondaryPowerBarElementName] then
            if unitFrame:IsElementEnabled(secondaryPowerBarElementName) then
                unitFrame:DisableElement(secondaryPowerBarElementName)
            end
            local secondaryPowerBarElement = unitFrame[secondaryPowerBarElementName]
            for i = 1, #secondaryPowerBarElement do secondaryPowerBarElement[i]:Hide() end
            for i = 1, #secondaryPowerBarElement.Ticks do secondaryPowerBarElement.Ticks[i]:Hide() end
            if secondaryPowerBarElement.ContainerBackground then secondaryPowerBarElement.ContainerBackground:Hide() end
            if secondaryPowerBarElement.PowerBarBorder then secondaryPowerBarElement.PowerBarBorder:Hide() end
            if secondaryPowerBarElement.OverlayFrame then secondaryPowerBarElement.OverlayFrame:Hide() end
            unitFrame[secondaryPowerBarElementName] = nil
        end
        UUF:UpdateHealthBarLayout(unitFrame, unit)
        return
    end

    local currentMaxPower = isRunes and 6 or (UnitPowerMax("player", powerType) or 6)
    local secondaryPowerBarElement = unitFrame[secondaryPowerBarElementName]

    if not secondaryPowerBarElement or #secondaryPowerBarElement ~= currentMaxPower then
        if secondaryPowerBarElement and unitFrame:IsElementEnabled(secondaryPowerBarElementName) then
            unitFrame:DisableElement(secondaryPowerBarElementName)
        end
        unitFrame[secondaryPowerBarElementName] = UUF:CreateUnitSecondaryPowerBar(unitFrame, unit)
        secondaryPowerBarElement = unitFrame[secondaryPowerBarElementName]
        if not secondaryPowerBarElement then return end
        unitFrame:EnableElement(secondaryPowerBarElementName)
    end

    local totalWidth = FrameDB.Width - 2
    local unitFrameWidth = totalWidth / currentMaxPower

    UUF:QueueOrRun(function()
        secondaryPowerBarElement.ContainerBackground:SetSize(totalWidth, DB.Height)
        secondaryPowerBarElement.ContainerBackground:SetVertexColor(DB.Background[1], DB.Background[2], DB.Background[3], DB.Background[4] or 1)
        secondaryPowerBarElement.ContainerBackground:ClearAllPoints()
        UUF:SetPointIfChanged(secondaryPowerBarElement.ContainerBackground, "TOPLEFT", unitFrame.Container, "TOPLEFT", 1, -1)
        secondaryPowerBarElement.ContainerBackground:Show()

        secondaryPowerBarElement.OverlayFrame:SetAllPoints(unitFrame.Container)
        secondaryPowerBarElement.OverlayFrame:SetFrameLevel(unitFrame.Container:GetFrameLevel() + 10)
        secondaryPowerBarElement.OverlayFrame:Show()

        secondaryPowerBarElement.PowerBarBorder:ClearAllPoints()
        secondaryPowerBarElement.PowerBarBorder:SetVertexColor(0, 0, 0, 1)
        UUF:SetPointIfChanged(secondaryPowerBarElement.PowerBarBorder, "TOPLEFT", unitFrame.Container, "TOPLEFT", 1, -1 - DB.Height)
        UUF:SetPointIfChanged(secondaryPowerBarElement.PowerBarBorder, "TOPRIGHT", unitFrame.Container, "TOPLEFT", 1 + totalWidth, -1 - DB.Height)
        secondaryPowerBarElement.PowerBarBorder:SetHeight(1)
        secondaryPowerBarElement.PowerBarBorder:Show()

        for i = 1, currentMaxPower do
            local bar = secondaryPowerBarElement[i]
            bar:ClearAllPoints()
            UUF:SetPointIfChanged(bar, "TOPLEFT", unitFrame.Container, "TOPLEFT", 1 + ((i - 1) * unitFrameWidth), -1)
            bar:SetSize(unitFrameWidth, DB.Height)
            bar.Background:SetVertexColor(DB.Background[1], DB.Background[2], DB.Background[3], DB.Background[4] or 1)
            bar:Show()
        end

        for i = 1, currentMaxPower - 1 do
            local tick = secondaryPowerBarElement.Ticks[i]
            tick:ClearAllPoints()
            tick:SetSize(1, DB.Height)
            tick:SetVertexColor(0, 0, 0, 1)
            UUF:SetPointIfChanged(tick, "TOPLEFT", unitFrame.Container, "TOPLEFT", 1 + (i * unitFrameWidth) - 0.5, -1)
            tick:Show()
        end

        for i = currentMaxPower, #secondaryPowerBarElement.Ticks do
            secondaryPowerBarElement.Ticks[i]:Hide()
        end
    end)

    if isRunes then
        secondaryPowerBarElement.colorSpec = DB.ColourByType
    end

    if secondaryPowerBarElement.PostUpdateColor then
        secondaryPowerBarElement:PostUpdateColor()
    end

    UUF:UpdateHealthBarLayout(unitFrame, unit)
    secondaryPowerBarElement:ForceUpdate()
end
