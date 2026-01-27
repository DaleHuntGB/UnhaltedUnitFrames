local _, UUF = ...

local UpdateSecondaryPowerBarEventFrame = CreateFrame("Frame")
UpdateSecondaryPowerBarEventFrame:RegisterEvent("TRAIT_CONFIG_UPDATED")
UpdateSecondaryPowerBarEventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
UpdateSecondaryPowerBarEventFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
UpdateSecondaryPowerBarEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")  -- Add this
UpdateSecondaryPowerBarEventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_SPECIALIZATION_CHANGED" then
        local unit = ...
        if unit ~= "player" then return end
    end
    C_Timer.After(0.1, function()
        if UUF.PLAYER then
            UUF:UpdateUnitSecondaryPowerBar(UUF.PLAYER, "player")
        end
    end)
end)

function UUF:IsRunePower()
    local _, class = UnitClass("player")
    return class == "DEATHKNIGHT"
end

function UUF:CreateUnitSecondaryPowerBar(unitFrame, unit)
    local FrameDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Frame
    local DB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].SecondaryPowerBar
    local container = unitFrame.Container

    if not DB.Enabled then return end

    local powerType = UUF:GetSecondaryPowerType()
    if not powerType and not UUF:IsRunePower() then return end

    local element = {}
    element.Ticks = {}

    local maxPower = UUF:IsRunePower() and 6 or (UnitPowerMax("player", powerType) or 6)
    local totalWidth = FrameDB.Width - 2
    local unitFrameWidth = totalWidth / maxPower

    element.ContainerBackground = container:CreateTexture(nil, "BACKGROUND")
    element.ContainerBackground:SetTexture(UUF.Media.Background)

    for i = 1, maxPower do
        local bar = CreateFrame("StatusBar", nil, container)
        bar:SetStatusBarTexture(UUF.Media.Foreground)
        bar:SetMinMaxValues(0, 1)
        bar.frequentUpdates = DB.Smooth
        bar:Hide()

        bar.Background = bar:CreateTexture(nil, "BACKGROUND")
        bar.Background:SetAllPoints(bar)
        bar.Background:SetTexture(UUF.Media.Background)

        element[i] = bar
    end

    element.OverlayFrame = CreateFrame("Frame", nil, container)
    element.OverlayFrame:SetFrameLevel(container:GetFrameLevel() + 10)

    for i = 1, maxPower - 1 do
        local tick = element.OverlayFrame:CreateTexture(nil, "OVERLAY")
        tick:SetTexture("Interface\\Buttons\\WHITE8x8")
        tick:SetDrawLayer("OVERLAY", 7)
        element.Ticks[i] = tick
    end

    element.PowerBarBorder = element.OverlayFrame:CreateTexture(nil, "OVERLAY")
    element.PowerBarBorder:SetTexture("Interface\\Buttons\\WHITE8x8")
    element.PowerBarBorder:SetDrawLayer("OVERLAY", 6)

    element.PostUpdateColor = function(self)
        if DB.ColourByType then return end
        for i = 1, #self do
            self[i]:SetStatusBarColor(DB.Foreground[1], DB.Foreground[2], DB.Foreground[3], DB.Foreground[4] or 1)
        end
    end

    if UUF:IsRunePower() then
        element.sortOrder = "asc"
        element.colorSpec = DB.ColourByType
        unitFrame.Runes = element
    else
        unitFrame.ClassPower = element
    end

    return element
end

function UUF:UpdateUnitSecondaryPowerBar(unitFrame, unit)
    if not unitFrame then return end

    local FrameDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Frame
    local DB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].SecondaryPowerBar
    local isRunes = UUF:IsRunePower()
    local elementName = isRunes and "Runes" or "ClassPower"

    local powerType = UUF:GetSecondaryPowerType()
    if not DB.Enabled or (not powerType and not isRunes) then
        if unitFrame[elementName] then
            if unitFrame:IsElementEnabled(elementName) then
                unitFrame:DisableElement(elementName)
            end
            local element = unitFrame[elementName]
            for i = 1, #element do element[i]:Hide() end
            for i = 1, #element.Ticks do element.Ticks[i]:Hide() end
            if element.ContainerBackground then element.ContainerBackground:Hide() end
            if element.PowerBarBorder then element.PowerBarBorder:Hide() end
            if element.OverlayFrame then element.OverlayFrame:Hide() end
            unitFrame[elementName] = nil
        end
        UUF:UpdateHealthBarLayout(unitFrame, unit)
        return
    end

    local currentMaxPower = isRunes and 6 or (UnitPowerMax("player", powerType) or 6)
    local element = unitFrame[elementName]

    if not element or #element ~= currentMaxPower then
        if element and unitFrame:IsElementEnabled(elementName) then
            unitFrame:DisableElement(elementName)
        end
        unitFrame[elementName] = UUF:CreateUnitSecondaryPowerBar(unitFrame, unit)
        element = unitFrame[elementName]
        if not element then return end
        unitFrame:EnableElement(elementName)
    end

    local totalWidth = FrameDB.Width - 2
    local unitFrameWidth = totalWidth / currentMaxPower

    element.ContainerBackground:SetSize(totalWidth, DB.Height)
    element.ContainerBackground:SetVertexColor(DB.Background[1], DB.Background[2], DB.Background[3], DB.Background[4] or 1)
    element.ContainerBackground:ClearAllPoints()
    element.ContainerBackground:SetPoint("TOPLEFT", unitFrame.Container, "TOPLEFT", 1, -1)
    element.ContainerBackground:Show()

    element.OverlayFrame:SetAllPoints(unitFrame.Container)
    element.OverlayFrame:SetFrameLevel(unitFrame.Container:GetFrameLevel() + 10)
    element.OverlayFrame:Show()

    element.PowerBarBorder:ClearAllPoints()
    element.PowerBarBorder:SetVertexColor(0, 0, 0, 1)
    element.PowerBarBorder:SetPoint("TOPLEFT", unitFrame.Container, "TOPLEFT", 1, -1 - DB.Height)
    element.PowerBarBorder:SetPoint("TOPRIGHT", unitFrame.Container, "TOPLEFT", 1 + totalWidth, -1 - DB.Height)
    element.PowerBarBorder:SetHeight(1)
    element.PowerBarBorder:Show()

    for i = 1, currentMaxPower do
        local bar = element[i]
        bar:ClearAllPoints()
        bar:SetPoint("TOPLEFT", unitFrame.Container, "TOPLEFT", 1 + ((i - 1) * unitFrameWidth), -1)
        bar:SetSize(unitFrameWidth, DB.Height)
        bar.Background:SetVertexColor(DB.Background[1], DB.Background[2], DB.Background[3], DB.Background[4] or 1)
        bar:Show()
    end

    for i = 1, currentMaxPower - 1 do
        local tick = element.Ticks[i]
        tick:ClearAllPoints()
        tick:SetSize(1, DB.Height)
        tick:SetVertexColor(0, 0, 0, 1)
        tick:SetPoint("TOPLEFT", unitFrame.Container, "TOPLEFT", 1 + (i * unitFrameWidth) - 0.5, -1)
        tick:Show()
    end

    for i = currentMaxPower, #element.Ticks do
        element.Ticks[i]:Hide()
    end

    if isRunes then
        element.colorSpec = DB.ColourByType
    end

    if element.PostUpdateColor then
        element:PostUpdateColor()
    end

    UUF:UpdateHealthBarLayout(unitFrame, unit)
    element:ForceUpdate()
end
