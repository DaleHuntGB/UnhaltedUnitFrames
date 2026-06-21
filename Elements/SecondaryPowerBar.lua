local _, UUF = ...

local playerClass = UnitClassBase("player")
local isDeathKnight = playerClass == "DEATHKNIGHT"

local secondaryPowerEvents = CreateFrame("Frame")
secondaryPowerEvents:RegisterEvent("TRAIT_CONFIG_UPDATED")
secondaryPowerEvents:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
secondaryPowerEvents:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
secondaryPowerEvents:RegisterEvent("PLAYER_ENTERING_WORLD")
secondaryPowerEvents:SetScript("OnEvent", function(_, event, unit)
    if event == "PLAYER_SPECIALIZATION_CHANGED" and unit ~= "player" then return end

    C_Timer.After(0.1, function()
        if UUF.PLAYER then
            UUF:UpdateUnitSecondaryPowerBar(UUF.PLAYER, "player")
        end
    end)
end)

local function DisableSecondaryPowerElement(unitFrame, elementName, secondaryPower)
    if unitFrame:IsElementEnabled(elementName) then
        unitFrame:DisableElement(elementName)
    end

    for index = 1, #secondaryPower do
        secondaryPower[index]:Hide()
    end

    for index = 1, #secondaryPower.Ticks do
        secondaryPower.Ticks[index]:Hide()
    end

    secondaryPower.ContainerBackground:Hide()
    secondaryPower.PowerBarBorder:Hide()
    secondaryPower.OverlayFrame:Hide()
    unitFrame[elementName] = nil
end

function UUF:CreateUnitSecondaryPowerBar(unitFrame, unit)
    local unitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)]
    local secondaryPowerDB = unitDB.SecondaryPowerBar
    if not secondaryPowerDB.Enabled then return end

    local powerType = UUF:GetSecondaryPowerType()
    if not isDeathKnight and not powerType then return end

    local maxPower = isDeathKnight and 6 or UnitPowerMax("player", powerType)
    if not maxPower or maxPower < 1 then return end

    local secondaryPower = {Ticks = {}}

    secondaryPower.ContainerBackground = unitFrame.Container:CreateTexture(nil, "BACKGROUND")
    secondaryPower.ContainerBackground:SetTexture(UUF.Media.Background)

    for index = 1, maxPower do
        local bar = CreateFrame("StatusBar", nil, unitFrame.Container)
        bar:SetStatusBarTexture(UUF.Media.Foreground)
        bar:SetMinMaxValues(0, 1)
        bar:Hide()

        bar.Background = bar:CreateTexture(nil, "BACKGROUND")
        bar.Background:SetAllPoints(bar)
        bar.Background:SetTexture(UUF.Media.Background)

        secondaryPower[index] = bar
    end

    secondaryPower.OverlayFrame = CreateFrame("Frame", nil, unitFrame.Container)
    secondaryPower.OverlayFrame:SetAllPoints(unitFrame.Container)
    secondaryPower.OverlayFrame:SetFrameLevel(unitFrame.Container:GetFrameLevel() + 10)

    for index = 1, maxPower - 1 do
        local tick = secondaryPower.OverlayFrame:CreateTexture(nil, "OVERLAY")
        tick:SetTexture("Interface\\Buttons\\WHITE8x8")
        tick:SetDrawLayer("OVERLAY", 7)
        tick:SetVertexColor(0, 0, 0, 1)
        secondaryPower.Ticks[index] = tick
    end

    secondaryPower.PowerBarBorder = secondaryPower.OverlayFrame:CreateTexture(nil, "OVERLAY")
    secondaryPower.PowerBarBorder:SetTexture("Interface\\Buttons\\WHITE8x8")
    secondaryPower.PowerBarBorder:SetDrawLayer("OVERLAY", 6)
    secondaryPower.PowerBarBorder:SetVertexColor(0, 0, 0, 1)
    secondaryPower.PowerBarBorder:SetHeight(1)

    secondaryPower.PostUpdateColor = function(element)
        if secondaryPowerDB.ColourByType then return end

        for index = 1, #element do
            element[index]:SetStatusBarColor(
                secondaryPowerDB.Foreground[1],
                secondaryPowerDB.Foreground[2],
                secondaryPowerDB.Foreground[3],
                secondaryPowerDB.Foreground[4] or 1
            )
        end
    end

    if isDeathKnight then
        secondaryPower.sortOrder = "asc"
        secondaryPower.colorSpec = secondaryPowerDB.ColourByType
        unitFrame.Runes = secondaryPower
    else
        unitFrame.ClassPower = secondaryPower
    end

    return secondaryPower
end

function UUF:UpdateUnitSecondaryPowerBar(unitFrame, unit)
    if not unitFrame then return end

    local unitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)]
    local frameDB = unitDB.Frame
    local secondaryPowerDB = unitDB.SecondaryPowerBar
    local powerType = UUF:GetSecondaryPowerType()
    local elementName = isDeathKnight and "Runes" or "ClassPower"

    if not secondaryPowerDB.Enabled or (not isDeathKnight and not powerType) then
        local secondaryPower = unitFrame[elementName]
        if secondaryPower then
            DisableSecondaryPowerElement(unitFrame, elementName, secondaryPower)
        end

        if unitFrame.Power then
            UUF:UpdateUnitPowerBar(unitFrame, unit)
        else
            UUF:UpdateHealthBarLayout(unitFrame, unit)
        end
        return
    end

    local maxPower = isDeathKnight and 6 or UnitPowerMax("player", powerType)
    if not maxPower or maxPower < 1 then return end

    local secondaryPower = unitFrame[elementName]
    if secondaryPower and #secondaryPower ~= maxPower then
        DisableSecondaryPowerElement(unitFrame, elementName, secondaryPower)
        secondaryPower = nil
    end

    if not secondaryPower then
        secondaryPower = UUF:CreateUnitSecondaryPowerBar(unitFrame, unit)
        if not secondaryPower then return end

        if not unitFrame:IsElementEnabled(elementName) then
            unitFrame:EnableElement(elementName)
        end
    end

    local totalWidth = frameDB.Width - 2
    local segmentWidth = totalWidth / maxPower
    local position = UUF:GetConfiguredSecondaryPowerBarPosition(unit)
    local stackOffset = UUF:GetSecondaryPowerBarStackOffset(unitFrame, unit)
    local anchorPoint = position == "TOP" and "TOPLEFT" or "BOTTOMLEFT"
    local anchorY = position == "TOP" and (-1 - stackOffset) or (1 + stackOffset)

    secondaryPower.ContainerBackground:ClearAllPoints()
    secondaryPower.ContainerBackground:SetPoint(anchorPoint, unitFrame.Container, anchorPoint, 1, anchorY)
    secondaryPower.ContainerBackground:SetSize(totalWidth, secondaryPowerDB.Height)
    secondaryPower.ContainerBackground:SetTexture(UUF.Media.Background)
    secondaryPower.ContainerBackground:SetVertexColor(
        secondaryPowerDB.Background[1],
        secondaryPowerDB.Background[2],
        secondaryPowerDB.Background[3],
        secondaryPowerDB.Background[4] or 1
    )
    secondaryPower.ContainerBackground:Show()

    secondaryPower.OverlayFrame:SetAllPoints(unitFrame.Container)
    secondaryPower.OverlayFrame:SetFrameLevel(unitFrame.Container:GetFrameLevel() + 10)
    secondaryPower.OverlayFrame:Show()

    secondaryPower.PowerBarBorder:ClearAllPoints()
    if position == "TOP" then
        secondaryPower.PowerBarBorder:SetPoint("TOPLEFT", unitFrame.Container, "TOPLEFT", 1, anchorY - secondaryPowerDB.Height)
        secondaryPower.PowerBarBorder:SetPoint("TOPRIGHT", unitFrame.Container, "TOPLEFT", 1 + totalWidth, anchorY - secondaryPowerDB.Height)
    else
        secondaryPower.PowerBarBorder:SetPoint("BOTTOMLEFT", unitFrame.Container, "BOTTOMLEFT", 1, anchorY + secondaryPowerDB.Height)
        secondaryPower.PowerBarBorder:SetPoint("BOTTOMRIGHT", unitFrame.Container, "BOTTOMLEFT", 1 + totalWidth, anchorY + secondaryPowerDB.Height)
    end
    secondaryPower.PowerBarBorder:Show()

    for index = 1, maxPower do
        local bar = secondaryPower[index]
        bar:ClearAllPoints()
        bar:SetPoint(anchorPoint, unitFrame.Container, anchorPoint, 1 + ((index - 1) * segmentWidth), anchorY)
        bar:SetSize(segmentWidth, secondaryPowerDB.Height)
        bar:SetStatusBarTexture(UUF.Media.Foreground)
        bar.Background:SetTexture(UUF.Media.Background)
        bar.Background:SetVertexColor(
            secondaryPowerDB.Background[1],
            secondaryPowerDB.Background[2],
            secondaryPowerDB.Background[3],
            secondaryPowerDB.Background[4] or 1
        )
        bar:Show()
    end

    for index = 1, maxPower - 1 do
        local tick = secondaryPower.Ticks[index]
        tick:ClearAllPoints()
        tick:SetPoint(anchorPoint, unitFrame.Container, anchorPoint, 1 + (index * segmentWidth) - 0.5, anchorY)
        tick:SetSize(1, secondaryPowerDB.Height)
        tick:Show()
    end

    if isDeathKnight then
        secondaryPower.colorSpec = secondaryPowerDB.ColourByType
    end

    secondaryPower:PostUpdateColor()
    if secondaryPower.ForceUpdate then
        secondaryPower:ForceUpdate()
    end

    if unitFrame.Power then
        UUF:UpdateUnitPowerBar(unitFrame, unit)
    else
        UUF:UpdateHealthBarLayout(unitFrame, unit)
    end
end
