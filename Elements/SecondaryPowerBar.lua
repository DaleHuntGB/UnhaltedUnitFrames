local _, UUF = ...
local oUF = UUF.oUF

local SECONDARY_POWER_BAR_EVENTS = {
    "PLAYER_ENTERING_WORLD",
    "PLAYER_LEVEL_UP",
    "PLAYER_SPECIALIZATION_CHANGED",
    "SPELLS_CHANGED",
    "TRAIT_CONFIG_UPDATED",
    "UNIT_DISPLAYPOWER",
    "UNIT_ENTERED_VEHICLE",
    "UNIT_EXITED_VEHICLE",
    "UPDATE_SHAPESHIFT_FORM",
    "UPDATE_VEHICLE_ACTIONBAR",
}

local secondaryPowerUpdatePending = false

local function QueueSecondaryPowerBarUpdate()
    if secondaryPowerUpdatePending then return end

    secondaryPowerUpdatePending = true
    C_Timer.After(0.1, function()
        secondaryPowerUpdatePending = false

        if UUF.PLAYER then
            UUF:UpdateUnitSecondaryPowerBar(UUF.PLAYER, "player")
        end
    end)
end

local UpdateSecondaryPowerBarEventFrame = CreateFrame("Frame")
for _, event in ipairs(SECONDARY_POWER_BAR_EVENTS) do
    UpdateSecondaryPowerBarEventFrame:RegisterEvent(event)
end
UpdateSecondaryPowerBarEventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_SPECIALIZATION_CHANGED" then
        local unit = ...
        if unit ~= "player" then return end
    elseif event == "UNIT_DISPLAYPOWER" or event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE" then
        local unit = ...
        if unit ~= "player" then return end
    end

    QueueSecondaryPowerBarUpdate()
end)

local function GetSecondaryPowerBarDB(unit)
    return UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].SecondaryPowerBar
end

function UUF:IsSecondaryPowerElementVisible(element)
    if not element then return false end

    if element.GetObjectType then
        return element:IsShown()
    end

    for i = 1, #element do
        local bar = element[i]
        if bar and bar:IsShown() then
            return true
        end
    end

    return false
end

function UUF:GetSecondaryPowerBarAnchor(unitFrame, unit)
    local position = UUF:GetConfiguredSecondaryPowerBarPosition(unit)
    local isTopAnchored = position == "TOP"
    local stackOffset = UUF:GetSecondaryPowerBarStackOffset(unitFrame, unit, true)

    return isTopAnchored and "TOPLEFT" or "BOTTOMLEFT", isTopAnchored and (-1 - stackOffset) or (1 + stackOffset), isTopAnchored
end

function UUF:GetSecondaryPowerBarWidth(unitFrame, unit)
    local frameDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Frame
    local frameWidth = unitFrame.GetWidth and unitFrame:GetWidth() or 0

    if not frameWidth or frameWidth <= 0 then
        frameWidth = frameDB.Width
    end

    return math.max(frameWidth - 2, 1)
end

function UUF:HideSegmentedSecondaryPowerElement(element)
    if not element then return end

    if element.ContainerBackground then
        element.ContainerBackground:Hide()
    end

    if element.PowerBarBorder then
        element.PowerBarBorder:Hide()
    end

    if element.OverlayFrame then
        element.OverlayFrame:Hide()
    end

    if element.Ticks then
        for i = 1, #element.Ticks do
            element.Ticks[i]:Hide()
        end
    end
end

function UUF:CreateSegmentedSecondaryPowerElement(unitFrame, unit, segmentCount)
    local db = GetSecondaryPowerBarDB(unit)
    local unitFrameContainer = unitFrame.Container
    local element = {}
    element.Ticks = {}

    element.ContainerBackground = unitFrameContainer:CreateTexture(nil, "BACKGROUND")
    element.ContainerBackground:SetTexture(UUF.Media.Background)
    element.ContainerBackground:Hide()

    element.OverlayFrame = CreateFrame("Frame", nil, unitFrameContainer)
    element.OverlayFrame:SetFrameLevel(unitFrameContainer:GetFrameLevel() + 10)
    element.OverlayFrame:Hide()

    for i = 1, segmentCount do
        local secondaryPowerBar = CreateFrame("StatusBar", nil, unitFrameContainer)
        secondaryPowerBar:SetStatusBarTexture(UUF.Media.Foreground)
        secondaryPowerBar:SetMinMaxValues(0, 1)
        secondaryPowerBar:SetFrameLevel(unitFrameContainer:GetFrameLevel() + 2)
        secondaryPowerBar:Hide()

        secondaryPowerBar.Background = secondaryPowerBar:CreateTexture(nil, "BACKGROUND")
        secondaryPowerBar.Background:SetAllPoints(secondaryPowerBar)
        secondaryPowerBar.Background:SetTexture(UUF.Media.Background)
        secondaryPowerBar.Background:SetVertexColor(db.Background[1], db.Background[2], db.Background[3], db.Background[4] or 1)

        element[i] = secondaryPowerBar
    end

    for i = 1, segmentCount - 1 do
        local secondaryPowerBarTick = element.OverlayFrame:CreateTexture(nil, "OVERLAY")
        secondaryPowerBarTick:SetTexture("Interface\\Buttons\\WHITE8x8")
        secondaryPowerBarTick:SetDrawLayer("OVERLAY", 7)
        secondaryPowerBarTick:Hide()
        element.Ticks[i] = secondaryPowerBarTick
    end

    element.PowerBarBorder = element.OverlayFrame:CreateTexture(nil, "OVERLAY")
    element.PowerBarBorder:SetTexture("Interface\\Buttons\\WHITE8x8")
    element.PowerBarBorder:SetDrawLayer("OVERLAY", 6)
    element.PowerBarBorder:Hide()

    return element
end

function UUF:UpdateSegmentedSecondaryPowerElementStyle(unitFrame, unit, element)
    local db = GetSecondaryPowerBarDB(unit)
    if not db or not element then return end

    if element.ContainerBackground then
        element.ContainerBackground:SetTexture(UUF.Media.Background)
        element.ContainerBackground:SetVertexColor(db.Background[1], db.Background[2], db.Background[3], db.Background[4] or 1)
    end

    if element.OverlayFrame then
        element.OverlayFrame:SetAllPoints(unitFrame.Container)
        element.OverlayFrame:SetFrameLevel(unitFrame.Container:GetFrameLevel() + 10)
    end

    if element.PowerBarBorder then
        element.PowerBarBorder:SetVertexColor(0, 0, 0, 1)
        element.PowerBarBorder:SetHeight(1)
    end

    for i = 1, #element do
        local bar = element[i]
        bar:SetStatusBarTexture(UUF.Media.Foreground)
        bar.Background:SetTexture(UUF.Media.Background)
        bar.Background:SetVertexColor(db.Background[1], db.Background[2], db.Background[3], db.Background[4] or 1)
    end
end

function UUF:LayoutSegmentedSecondaryPowerElement(unitFrame, unit, element, visibleSegments)
    if not element or not visibleSegments or visibleSegments <= 0 then
        UUF:HideSegmentedSecondaryPowerElement(element)
        return
    end

    local db = GetSecondaryPowerBarDB(unit)
    local totalWidth = UUF:GetSecondaryPowerBarWidth(unitFrame, unit)
    local segmentWidth = totalWidth / visibleSegments
    local anchorPoint, anchorY, isTopAnchored = UUF:GetSecondaryPowerBarAnchor(unitFrame, unit)

    element.ContainerBackground:SetSize(totalWidth, db.Height)
    element.ContainerBackground:ClearAllPoints()
    element.ContainerBackground:SetPoint(anchorPoint, unitFrame.Container, anchorPoint, 1, anchorY)
    element.ContainerBackground:Show()

    element.OverlayFrame:Show()
    element.PowerBarBorder:ClearAllPoints()
    if isTopAnchored then
        element.PowerBarBorder:SetPoint("TOPLEFT", unitFrame.Container, "TOPLEFT", 1, -1 - db.Height)
        element.PowerBarBorder:SetPoint("TOPRIGHT", unitFrame.Container, "TOPLEFT", 1 + totalWidth, -1 - db.Height)
    else
        element.PowerBarBorder:SetPoint("BOTTOMLEFT", unitFrame.Container, "BOTTOMLEFT", 1, 1 + db.Height)
        element.PowerBarBorder:SetPoint("BOTTOMRIGHT", unitFrame.Container, "BOTTOMLEFT", 1 + totalWidth, 1 + db.Height)
    end
    element.PowerBarBorder:Show()

    for i = 1, #element do
        local bar = element[i]
        if i <= visibleSegments then
            bar:ClearAllPoints()
            bar:SetPoint(anchorPoint, unitFrame.Container, anchorPoint, 1 + ((i - 1) * segmentWidth), anchorY)
            bar:SetSize(segmentWidth, db.Height)
        end
    end

    for i = 1, #element.Ticks do
        local tick = element.Ticks[i]
        if i < visibleSegments then
            tick:ClearAllPoints()
            tick:SetSize(1, db.Height)
            tick:SetVertexColor(0, 0, 0, 1)
            tick:SetPoint(anchorPoint, unitFrame.Container, anchorPoint, 1 + (i * segmentWidth) - 0.5, anchorY)
            tick:Show()
        else
            tick:Hide()
        end
    end
end

function UUF:CreateUnitSecondaryPowerBar(unitFrame, unit)
    if UUF:GetNormalizedUnit(unit) ~= "player" then return end

    UUF:CreateUnitClassPowerBar(unitFrame, unit)
    UUF:CreateUnitRunesBar(unitFrame, unit)
    UUF:CreateUnitStaggerBar(unitFrame, unit)
end

function UUF:RefreshSecondaryPowerLayout(unitFrame, unit)
    if not unitFrame then return end

    if unitFrame.Power then
        UUF:UpdateUnitPowerBar(unitFrame, unit)
    else
        UUF:UpdateHealthBarLayout(unitFrame, unit)
    end
end

function UUF:UpdateUnitSecondaryPowerBar(unitFrame, unit)
    if not unitFrame or UUF:GetNormalizedUnit(unit) ~= "player" then return end

    local db = GetSecondaryPowerBarDB(unit)
    UUF:CreateUnitSecondaryPowerBar(unitFrame, unit)

    if db and db.Enabled then
        UUF:UpdateUnitClassPowerBar(unitFrame, unit)
        UUF:UpdateUnitRunesBar(unitFrame, unit)
        UUF:UpdateUnitStaggerBar(unitFrame, unit)
    else
        UUF:DisableUnitClassPowerBar(unitFrame)
        UUF:DisableUnitRunesBar(unitFrame)
        UUF:DisableUnitStaggerBar(unitFrame)
    end

    UUF:RefreshSecondaryPowerLayout(unitFrame, unit)
end

oUF:RegisterInitCallback(function(unitFrame)
    if not unitFrame then return end

    local unit = unitFrame.unit or unitFrame:GetAttribute("unit")
    if unit and UUF:GetNormalizedUnit(unit) == "player" then
        UUF:UpdateUnitSecondaryPowerBar(unitFrame, unit)
    end
end)
