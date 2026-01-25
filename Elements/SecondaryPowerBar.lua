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

    local isTop = DB.Position == "TOP"
    local anchorPoint = isTop and "TOPLEFT" or "BOTTOMLEFT"
    local yOffset = isTop and -1 or 1


    if not ClassPower.ContainerBackground then
        ClassPower.ContainerBackground = container:CreateTexture(nil, "BACKGROUND")
        ClassPower.ContainerBackground:SetPoint(anchorPoint, container, anchorPoint, 1, yOffset)
        ClassPower.ContainerBackground:SetSize(totalWidth, DB.Height)
        ClassPower.ContainerBackground:SetTexture(UUF.Media.Background)
        ClassPower.ContainerBackground:SetVertexColor(
            DB.Background[1],
            DB.Background[2],
            DB.Background[3],
            DB.Background[4] or 1
        )
    end

    for i = 1, THEORETICAL_MAX do
        local secondaryPowerBar = CreateFrame("StatusBar", nil, container)
        secondaryPowerBar:SetSize(unitFrameWidth, DB.Height)
        secondaryPowerBar:SetPoint(anchorPoint, container, anchorPoint, 1 + ((i - 1) * unitFrameWidth), yOffset)
        secondaryPowerBar:SetStatusBarTexture(UUF.Media.Foreground)
        secondaryPowerBar:SetStatusBarColor(DB.Foreground[1], DB.Foreground[2], DB.Foreground[3], DB.Foreground[4] or 1)
        secondaryPowerBar:SetMinMaxValues(0, 1)
        secondaryPowerBar.frequentUpdates = DB.Smooth
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
        local tick = ClassPower.OverlayFrame:CreateTexture(nil, "OVERLAY")
        tick:SetTexture("Interface\\Buttons\\WHITE8x8")
        tick:SetVertexColor(0, 0, 0, 1)
        tick:SetDrawLayer("OVERLAY", 7)
        tick:SetSize(1, DB.Height)
        tick:SetPoint(anchorPoint, container, anchorPoint, 1 + (i * unitFrameWidth) - 0.5, yOffset)
        tick:Show()
        ClassPower.Ticks[i] = tick
    end


    if not ClassPower.PowerBarBorder then
        ClassPower.PowerBarBorder = ClassPower.OverlayFrame:CreateTexture(nil, "OVERLAY")
        ClassPower.PowerBarBorder:SetHeight(1)
        ClassPower.PowerBarBorder:SetTexture("Interface\\Buttons\\WHITE8x8")
        ClassPower.PowerBarBorder:SetVertexColor(0, 0, 0, 1)
        ClassPower.PowerBarBorder:SetDrawLayer("OVERLAY", 6)

        if isTop then

            ClassPower.PowerBarBorder:SetPoint("TOPLEFT", container, "TOPLEFT", 1, -1 - DB.Height)
            ClassPower.PowerBarBorder:SetPoint("TOPRIGHT", container, "TOPLEFT", 1 + totalWidth, -1 - DB.Height)
        else

            ClassPower.PowerBarBorder:SetPoint("BOTTOMLEFT", container, "BOTTOMLEFT", 1, 1 + DB.Height)
            ClassPower.PowerBarBorder:SetPoint("BOTTOMRIGHT", container, "BOTTOMLEFT", 1 + totalWidth, 1 + DB.Height)
        end
    end

    ClassPower.colorPower = DB.ColourByType


    ClassPower.PostUpdateColor = function(element, color)
        local DB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].SecondaryPowerBar
        if not DB.ColourByType then
            for i = 1, #element do
                element[i]:SetStatusBarColor( DB.Foreground[1], DB.Foreground[2], DB.Foreground[3], DB.Foreground[4] or 1 )
            end
        end
    end

    unitFrame.ClassPower = ClassPower


    if isTop then

        unitFrame.HealthBackground:ClearAllPoints()
        unitFrame.HealthBackground:SetPoint("BOTTOMLEFT", container, "BOTTOMLEFT", 1, 1)
        unitFrame.HealthBackground:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -1, 1)
        unitFrame.HealthBackground:SetHeight(FrameDB.Height - DB.Height - 3)

        unitFrame.Health:ClearAllPoints()
        unitFrame.Health:SetPoint("BOTTOMLEFT", container, "BOTTOMLEFT", 1, 1)
        unitFrame.Health:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -1, 1)
        unitFrame.Health:SetHeight(FrameDB.Height - DB.Height - 3)
    else

        unitFrame.HealthBackground:ClearAllPoints()
        unitFrame.HealthBackground:SetPoint("TOPLEFT", container, "TOPLEFT", 1, -1)
        unitFrame.HealthBackground:SetPoint("TOPRIGHT", container, "TOPRIGHT", -1, -1)
        unitFrame.HealthBackground:SetHeight(FrameDB.Height - DB.Height - 3)

        unitFrame.Health:ClearAllPoints()
        unitFrame.Health:SetPoint("TOPLEFT", container, "TOPLEFT", 1, -1)
        unitFrame.Health:SetPoint("TOPRIGHT", container, "TOPRIGHT", -1, -1)
        unitFrame.Health:SetHeight(FrameDB.Height - DB.Height - 3)
    end

    return ClassPower
end

function UUF:UpdateUnitSecondaryPowerBar(unitFrame, unit)
    local FrameDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Frame
    local DB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].SecondaryPowerBar

    if not DB.Enabled then
        if unitFrame:IsElementEnabled("ClassPower") then unitFrame:DisableElement("ClassPower") end
        if unitFrame.ClassPower and unitFrame.ClassPower.ContainerBackground then unitFrame.ClassPower.ContainerBackground:Hide() end
        if unitFrame.ClassPower and unitFrame.ClassPower.PowerBarBorder then unitFrame.ClassPower.PowerBarBorder:Hide() end
        if unitFrame.ClassPower and unitFrame.ClassPower.OverlayFrame then unitFrame.ClassPower.OverlayFrame:Hide() end


        unitFrame.HealthBackground:ClearAllPoints()
        unitFrame.HealthBackground:SetPoint("TOPLEFT", unitFrame.Container, "TOPLEFT", 1, -1)
        unitFrame.HealthBackground:SetPoint("BOTTOMRIGHT", unitFrame.Container, "BOTTOMRIGHT", -1, 1)
        unitFrame.HealthBackground:SetHeight(FrameDB.Height - 2)

        unitFrame.Health:ClearAllPoints()
        unitFrame.Health:SetPoint("TOPLEFT", unitFrame.Container, "TOPLEFT", 1, -1)
        unitFrame.Health:SetPoint("BOTTOMRIGHT", unitFrame.Container, "BOTTOMRIGHT", -1, 1)
        unitFrame.Health:SetHeight(FrameDB.Height - 2)
        return
    end

    unitFrame.ClassPower = unitFrame.ClassPower or UUF:CreateUnitSecondaryPowerBar(unitFrame, unit)

    if not unitFrame:IsElementEnabled("ClassPower") then unitFrame:EnableElement("ClassPower") end

    local totalWidth = FrameDB.Width - 2
    local unitFrameWidth = totalWidth / THEORETICAL_MAX

    local isTop = DB.Position == "TOP"
    local anchorPoint = isTop and "TOPLEFT" or "BOTTOMLEFT"
    local yOffset = isTop and -1 or 1

    unitFrame.ClassPower.colorPower = DB.ColourByType

    if unitFrame.ClassPower.OverlayFrame then unitFrame.ClassPower.OverlayFrame:Show() end

    if unitFrame.ClassPower.ContainerBackground then
        unitFrame.ClassPower.ContainerBackground:ClearAllPoints()
        unitFrame.ClassPower.ContainerBackground:SetPoint(anchorPoint, unitFrame.Container, anchorPoint, 1, yOffset)
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

        if isTop then
            unitFrame.ClassPower.PowerBarBorder:SetPoint("TOPLEFT", unitFrame.Container, "TOPLEFT", 1, -1 - DB.Height)
            unitFrame.ClassPower.PowerBarBorder:SetPoint("TOPRIGHT", unitFrame.Container, "TOPLEFT", 1 + totalWidth, -1 - DB.Height)
        else
            unitFrame.ClassPower.PowerBarBorder:SetPoint("BOTTOMLEFT", unitFrame.Container, "BOTTOMLEFT", 1, 1 + DB.Height)
            unitFrame.ClassPower.PowerBarBorder:SetPoint("BOTTOMRIGHT", unitFrame.Container, "BOTTOMLEFT", 1 + totalWidth, 1 + DB.Height)
        end

        unitFrame.ClassPower.PowerBarBorder:Show()
    end

    for i = 1, THEORETICAL_MAX do
        local secondaryPowerBar = unitFrame.ClassPower[i]

        secondaryPowerBar:ClearAllPoints()
        secondaryPowerBar:SetPoint(anchorPoint, unitFrame.Container, anchorPoint, 1 + ((i - 1) * unitFrameWidth), yOffset)
        secondaryPowerBar:SetSize(unitFrameWidth, DB.Height)
        secondaryPowerBar:SetStatusBarTexture(UUF.Media.Foreground)

        if not DB.ColourByType then secondaryPowerBar:SetStatusBarColor(DB.Foreground[1], DB.Foreground[2], DB.Foreground[3], DB.Foreground[4] or 1) end

        secondaryPowerBar.frequentUpdates = DB.Smooth

        secondaryPowerBar.Background:SetAllPoints(secondaryPowerBar)
        secondaryPowerBar.Background:SetTexture(UUF.Media.Background)
        secondaryPowerBar.Background:SetVertexColor(
            DB.Background[1],
            DB.Background[2],
            DB.Background[3],
            DB.Background[4] or 1
        )
    end


    for i = 1, THEORETICAL_MAX - 1 do
        local tick = unitFrame.ClassPower.Ticks[i]
        if tick then
            tick:ClearAllPoints()
            tick:SetSize(1, DB.Height)
            tick:SetDrawLayer("OVERLAY", 7)
            tick:SetPoint(anchorPoint, unitFrame.Container, anchorPoint, 1 + (i * unitFrameWidth) - 0.5, yOffset)
            tick:Show()
        end
    end

    if isTop then
        unitFrame.HealthBackground:ClearAllPoints()
        unitFrame.HealthBackground:SetPoint("BOTTOMLEFT", unitFrame.Container, "BOTTOMLEFT", 1, 1)
        unitFrame.HealthBackground:SetPoint("BOTTOMRIGHT", unitFrame.Container, "BOTTOMRIGHT", -1, 1)
        unitFrame.HealthBackground:SetHeight(FrameDB.Height - DB.Height - 3)

        unitFrame.Health:ClearAllPoints()
        unitFrame.Health:SetPoint("BOTTOMLEFT", unitFrame.Container, "BOTTOMLEFT", 1, 1)
        unitFrame.Health:SetPoint("BOTTOMRIGHT", unitFrame.Container, "BOTTOMRIGHT", -1, 1)
        unitFrame.Health:SetHeight(FrameDB.Height - DB.Height - 3)
    else
        unitFrame.HealthBackground:ClearAllPoints()
        unitFrame.HealthBackground:SetPoint("TOPLEFT", unitFrame.Container, "TOPLEFT", 1, -1)
        unitFrame.HealthBackground:SetPoint("TOPRIGHT", unitFrame.Container, "TOPRIGHT", -1, -1)
        unitFrame.HealthBackground:SetHeight(FrameDB.Height - DB.Height - 3)

        unitFrame.Health:ClearAllPoints()
        unitFrame.Health:SetPoint("TOPLEFT", unitFrame.Container, "TOPLEFT", 1, -1)
        unitFrame.Health:SetPoint("TOPRIGHT", unitFrame.Container, "TOPRIGHT", -1, -1)
        unitFrame.Health:SetHeight(FrameDB.Height - DB.Height - 3)
    end

    unitFrame.ClassPower:ForceUpdate()
end