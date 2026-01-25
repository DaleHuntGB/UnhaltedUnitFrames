local _, UUF = ...

local THEORETICAL_MAX = 6

function UUF:CreateUnitSecondaryPowerBar(unitFrame, unit)
    local FrameDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Frame
    local DB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].SecondaryPowerBar
    local container = unitFrame.Container

    local ClassPower = {}
    ClassPower.Ticks = {}

    local totalWidth = FrameDB.Width - 2
    local unitFrameWidth = totalWidth / THEORETICAL_MAX

    if not ClassPower.ContainerBackground then
        ClassPower.ContainerBackground = container:CreateTexture(nil, "BACKGROUND")
        ClassPower.ContainerBackground:SetPoint("TOPLEFT", container, "TOPLEFT", 1, -1)
        ClassPower.ContainerBackground:SetSize(totalWidth, DB.Height)
        ClassPower.ContainerBackground:SetTexture(UUF.Media.Background)
        ClassPower.ContainerBackground:SetVertexColor( DB.Background[1], DB.Background[2], DB.Background[3], DB.Background[4] or 1 )
    end

    for i = 1, THEORETICAL_MAX do
        local secondaryPowerBar = CreateFrame("StatusBar", nil, container)
        secondaryPowerBar:SetSize(unitFrameWidth, DB.Height)
        secondaryPowerBar:SetPoint("TOPLEFT", container, "TOPLEFT", 1 + ((i - 1) * unitFrameWidth), -1)
        secondaryPowerBar:SetStatusBarTexture(UUF.Media.Foreground)
        secondaryPowerBar:SetStatusBarColor(DB.Foreground[1], DB.Foreground[2], DB.Foreground[3], DB.Foreground[4] or 1)
        secondaryPowerBar:SetMinMaxValues(0, 1)
        secondaryPowerBar:Hide()

        secondaryPowerBar.Background = secondaryPowerBar:CreateTexture(nil, "BACKGROUND")
        secondaryPowerBar.Background:SetAllPoints(secondaryPowerBar)
        secondaryPowerBar.Background:SetTexture(UUF.Media.Background)
        secondaryPowerBar.Background:SetVertexColor( DB.Background[1], DB.Background[2], DB.Background[3], DB.Background[4] or 1 )

        ClassPower[i] = secondaryPowerBar
    end

    ClassPower.OverlayFrame = CreateFrame("Frame", nil, container)
    ClassPower.OverlayFrame:SetAllPoints(container)
    ClassPower.OverlayFrame:SetFrameLevel(container:GetFrameLevel() + 10)

    for i = 1, THEORETICAL_MAX - 1 do
        local secondaryPowerTick = ClassPower.OverlayFrame:CreateTexture(nil, "OVERLAY")
        secondaryPowerTick:SetTexture("Interface\\Buttons\\WHITE8x8")
        secondaryPowerTick:SetVertexColor(0, 0, 0, 1)
        secondaryPowerTick:SetDrawLayer("OVERLAY", 7)
        secondaryPowerTick:SetSize(1, DB.Height)
        secondaryPowerTick:SetPoint("TOPLEFT", container, "TOPLEFT", 1 + (i * unitFrameWidth) - 0.5, -1)
        secondaryPowerTick:Show()
        ClassPower.Ticks[i] = secondaryPowerTick
    end

    if not ClassPower.PowerBarBorder then
        ClassPower.PowerBarBorder = ClassPower.OverlayFrame:CreateTexture(nil, "OVERLAY")
        ClassPower.PowerBarBorder:SetHeight(1)
        ClassPower.PowerBarBorder:SetTexture("Interface\\Buttons\\WHITE8x8")
        ClassPower.PowerBarBorder:SetVertexColor(0, 0, 0, 1)
        ClassPower.PowerBarBorder:SetDrawLayer("OVERLAY", 6)
        ClassPower.PowerBarBorder:SetPoint("TOPLEFT", container, "TOPLEFT", 1, -1 - DB.Height)
        ClassPower.PowerBarBorder:SetPoint("TOPRIGHT", container, "TOPLEFT", 1 + totalWidth, -1 - DB.Height)
    end

    ClassPower.PostUpdateColor = function(element, color)
        if not DB.ColourByType then
            for i = 1, #element do
                element[i]:SetStatusBarColor( DB.Foreground[1], DB.Foreground[2], DB.Foreground[3], DB.Foreground[4] or 1 )
            end
        end
    end

    if DB.Enabled then
        unitFrame.ClassPower = ClassPower
        ClassPower.ContainerBackground:Show()
        ClassPower.PowerBarBorder:Show()
        ClassPower.OverlayFrame:Show()
    else
        if unitFrame:IsElementEnabled("ClassPower") then
            unitFrame:DisableElement("ClassPower")
        end
        ClassPower.ContainerBackground:Hide()
        ClassPower.PowerBarBorder:Hide()
        ClassPower.OverlayFrame:Hide()
    end

    UUF:UpdateHealthBarLayout(unitFrame, unit)

    return ClassPower
end

function UUF:UpdateUnitSecondaryPowerBar(unitFrame, unit)
    local FrameDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Frame
    local DB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].SecondaryPowerBar

    if DB.Enabled then
        unitFrame.ClassPower = unitFrame.ClassPower or UUF:CreateUnitSecondaryPowerBar(unitFrame, unit)

        if not unitFrame:IsElementEnabled("ClassPower") then
            unitFrame:EnableElement("ClassPower")
        end

        local totalWidth = FrameDB.Width - 2
        local unitFrameWidth = totalWidth / THEORETICAL_MAX

        unitFrame.ClassPower.colorPower = DB.ColourByType

        if unitFrame.ClassPower.OverlayFrame then
            unitFrame.ClassPower.OverlayFrame:Show()
        end

        if unitFrame.ClassPower.ContainerBackground then
            unitFrame.ClassPower.ContainerBackground:ClearAllPoints()
            unitFrame.ClassPower.ContainerBackground:SetPoint("TOPLEFT", unitFrame.Container, "TOPLEFT", 1, -1)
            unitFrame.ClassPower.ContainerBackground:SetSize(totalWidth, DB.Height)
            unitFrame.ClassPower.ContainerBackground:SetTexture(UUF.Media.Background)
            unitFrame.ClassPower.ContainerBackground:SetVertexColor( DB.Background[1], DB.Background[2], DB.Background[3], DB.Background[4] or 1 )
            unitFrame.ClassPower.ContainerBackground:Show()
        end

        if unitFrame.ClassPower.PowerBarBorder then
            unitFrame.ClassPower.PowerBarBorder:ClearAllPoints()
            unitFrame.ClassPower.PowerBarBorder:SetHeight(1)
            unitFrame.ClassPower.PowerBarBorder:SetTexture("Interface\\Buttons\\WHITE8x8")
            unitFrame.ClassPower.PowerBarBorder:SetVertexColor(0, 0, 0, 1)
            unitFrame.ClassPower.PowerBarBorder:SetDrawLayer("OVERLAY", 6)
            unitFrame.ClassPower.PowerBarBorder:SetPoint("TOPLEFT", unitFrame.Container, "TOPLEFT", 1, -1 - DB.Height)
            unitFrame.ClassPower.PowerBarBorder:SetPoint("TOPRIGHT", unitFrame.Container, "TOPLEFT", 1 + totalWidth, -1 - DB.Height)
            unitFrame.ClassPower.PowerBarBorder:Show()
        end

        for i = 1, THEORETICAL_MAX do
            local secondaryPowerBar = unitFrame.ClassPower[i]

            secondaryPowerBar:ClearAllPoints()
            secondaryPowerBar:SetPoint("TOPLEFT", unitFrame.Container, "TOPLEFT", 1 + ((i - 1) * unitFrameWidth), -1)
            secondaryPowerBar:SetSize(unitFrameWidth, DB.Height)
            secondaryPowerBar:SetStatusBarTexture(UUF.Media.Foreground)

            if not DB.ColourByType then
                secondaryPowerBar:SetStatusBarColor(DB.Foreground[1], DB.Foreground[2], DB.Foreground[3], DB.Foreground[4] or 1)
            end

            secondaryPowerBar.Background:SetAllPoints(secondaryPowerBar)
            secondaryPowerBar.Background:SetTexture(UUF.Media.Background)
            secondaryPowerBar.Background:SetVertexColor( DB.Background[1], DB.Background[2], DB.Background[3], DB.Background[4] or 1 )
        end

        for i = 1, THEORETICAL_MAX - 1 do
            local secondaryPowerBarTick = unitFrame.ClassPower.Ticks[i]
            if secondaryPowerBarTick then
                secondaryPowerBarTick:ClearAllPoints()
                secondaryPowerBarTick:SetSize(1, DB.Height)
                secondaryPowerBarTick:SetDrawLayer("OVERLAY", 7)
                secondaryPowerBarTick:SetPoint("TOPLEFT", unitFrame.Container, "TOPLEFT", 1 + (i * unitFrameWidth) - 0.5, -1)
                secondaryPowerBarTick:Show()
            end
        end

        unitFrame.ClassPower:ForceUpdate()
    else
        if not unitFrame.ClassPower then return end

        if unitFrame:IsElementEnabled("ClassPower") then
            unitFrame:DisableElement("ClassPower")
        end

        unitFrame.ClassPower.ContainerBackground:Hide()
        unitFrame.ClassPower.PowerBarBorder:Hide()
        unitFrame.ClassPower.OverlayFrame:Hide()

        unitFrame.ClassPower = nil
    end

    UUF:UpdateHealthBarLayout(unitFrame, unit)
end