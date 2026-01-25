local _, UUF = ...

local THEORETICAL_MAX = 6

function UUF:CreateUnitSecondaryPowerBar(unitFrame, unit)
    local FrameDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Frame
    local DB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].SecondaryPowerBar
    local container = unitFrame.Container

    local ClassPower = {}
    ClassPower.Ticks = {}

    local totalWidth = FrameDB.Width - 2
    local barWidth = totalWidth / THEORETICAL_MAX

    local isTop = DB.Position == "TOP"
    local anchorPoint = isTop and "TOPLEFT" or "BOTTOMLEFT"
    local yOffset = isTop and -1 or 1

    -- Create container background
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
        local bar = CreateFrame("StatusBar", nil, container)
        bar:SetSize(barWidth, DB.Height)
        bar:SetPoint(anchorPoint, container, anchorPoint, 1 + ((i - 1) * barWidth), yOffset)
        bar:SetStatusBarTexture(UUF.Media.Foreground)
        bar:SetStatusBarColor(DB.Foreground[1], DB.Foreground[2], DB.Foreground[3], DB.Foreground[4] or 1)
        bar:SetMinMaxValues(0, 1)
        bar.frequentUpdates = DB.Smooth
        bar:Hide()

        bar.Background = bar:CreateTexture(nil, "BACKGROUND")
        bar.Background:SetAllPoints(bar)
        bar.Background:SetTexture(UUF.Media.Background)
        bar.Background:SetVertexColor(
            DB.Background[1],
            DB.Background[2],
            DB.Background[3],
            DB.Background[4] or 1
        )

        ClassPower[i] = bar
    end

    -- Create overlay frame for ticks (sits above all bars)
    ClassPower.OverlayFrame = CreateFrame("Frame", nil, container)
    ClassPower.OverlayFrame:SetAllPoints(container)
    ClassPower.OverlayFrame:SetFrameLevel(container:GetFrameLevel() + 10)

    -- Create all ticks on the overlay frame (always visible, always above bars)
    for i = 1, THEORETICAL_MAX - 1 do
        local tick = ClassPower.OverlayFrame:CreateTexture(nil, "OVERLAY")
        tick:SetTexture("Interface\\Buttons\\WHITE8x8")
        tick:SetVertexColor(0, 0, 0, 1)
        tick:SetDrawLayer("OVERLAY", 7)
        tick:SetSize(1, DB.Height)
        tick:SetPoint(anchorPoint, container, anchorPoint, 1 + (i * barWidth) - 0.5, yOffset)
        tick:Show()
        ClassPower.Ticks[i] = tick
    end

    -- Create border (top or bottom depending on position)
    if not ClassPower.PowerBarBorder then
        ClassPower.PowerBarBorder = ClassPower.OverlayFrame:CreateTexture(nil, "OVERLAY")
        ClassPower.PowerBarBorder:SetHeight(1)
        ClassPower.PowerBarBorder:SetTexture("Interface\\Buttons\\WHITE8x8")
        ClassPower.PowerBarBorder:SetVertexColor(0, 0, 0, 1)
        ClassPower.PowerBarBorder:SetDrawLayer("OVERLAY", 6)

        if isTop then
            -- Border on bottom of power bar (between power bar and health)
            ClassPower.PowerBarBorder:SetPoint("TOPLEFT", container, "TOPLEFT", 1, -1 - DB.Height)
            ClassPower.PowerBarBorder:SetPoint("TOPRIGHT", container, "TOPLEFT", 1 + totalWidth, -1 - DB.Height)
        else
            -- Border on top of power bar (between power bar and health)
            ClassPower.PowerBarBorder:SetPoint("BOTTOMLEFT", container, "BOTTOMLEFT", 1, 1 + DB.Height)
            ClassPower.PowerBarBorder:SetPoint("BOTTOMRIGHT", container, "BOTTOMLEFT", 1 + totalWidth, 1 + DB.Height)
        end
    end

    ClassPower.colorPower = DB.ColourByType

    -- Add PostUpdateColor callback
    ClassPower.PostUpdateColor = function(element, color)
        local DB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].SecondaryPowerBar

        if not DB.ColourByType then
            -- Use foreground color from settings
            for i = 1, #element do
                element[i]:SetStatusBarColor(
                    DB.Foreground[1],
                    DB.Foreground[2],
                    DB.Foreground[3],
                    DB.Foreground[4] or 1
                )
            end
        end
    end

    unitFrame.ClassPower = ClassPower

    -- Adjust health bar based on position
    if isTop then
        -- Health bar anchored to bottom, reduce height
        unitFrame.HealthBackground:ClearAllPoints()
        unitFrame.HealthBackground:SetPoint("BOTTOMLEFT", container, "BOTTOMLEFT", 1, 1)
        unitFrame.HealthBackground:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -1, 1)
        unitFrame.HealthBackground:SetHeight(FrameDB.Height - DB.Height - 3)

        unitFrame.Health:ClearAllPoints()
        unitFrame.Health:SetPoint("BOTTOMLEFT", container, "BOTTOMLEFT", 1, 1)
        unitFrame.Health:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -1, 1)
        unitFrame.Health:SetHeight(FrameDB.Height - DB.Height - 3)
    else
        -- Health bar anchored to top, reduce height
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
        if unitFrame:IsElementEnabled("ClassPower") then
            unitFrame:DisableElement("ClassPower")
        end
        if unitFrame.ClassPower and unitFrame.ClassPower.ContainerBackground then
            unitFrame.ClassPower.ContainerBackground:Hide()
        end
        if unitFrame.ClassPower and unitFrame.ClassPower.PowerBarBorder then
            unitFrame.ClassPower.PowerBarBorder:Hide()
        end
        if unitFrame.ClassPower and unitFrame.ClassPower.OverlayFrame then
            unitFrame.ClassPower.OverlayFrame:Hide()
        end

        -- Reset health bar to full height
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

    if not unitFrame:IsElementEnabled("ClassPower") then
        unitFrame:EnableElement("ClassPower")
    end

    local totalWidth = FrameDB.Width - 2
    local barWidth = totalWidth / THEORETICAL_MAX

    local isTop = DB.Position == "TOP"
    local anchorPoint = isTop and "TOPLEFT" or "BOTTOMLEFT"
    local yOffset = isTop and -1 or 1

    -- Update colorPower flag
    unitFrame.ClassPower.colorPower = DB.ColourByType

    -- Show overlay frame
    if unitFrame.ClassPower.OverlayFrame then
        unitFrame.ClassPower.OverlayFrame:Show()
    end

    -- Update container background
    if unitFrame.ClassPower.ContainerBackground then
        unitFrame.ClassPower.ContainerBackground:ClearAllPoints()
        unitFrame.ClassPower.ContainerBackground:SetPoint(anchorPoint, unitFrame.Container, anchorPoint, 1, yOffset)
        unitFrame.ClassPower.ContainerBackground:SetSize(totalWidth, DB.Height)
        unitFrame.ClassPower.ContainerBackground:SetTexture(UUF.Media.Background)
        unitFrame.ClassPower.ContainerBackground:SetVertexColor(
            DB.Background[1],
            DB.Background[2],
            DB.Background[3],
            DB.Background[4] or 1
        )
        unitFrame.ClassPower.ContainerBackground:Show()
    end

    -- Update border
    if unitFrame.ClassPower.PowerBarBorder then
        unitFrame.ClassPower.PowerBarBorder:ClearAllPoints()
        unitFrame.ClassPower.PowerBarBorder:SetHeight(1)
        unitFrame.ClassPower.PowerBarBorder:SetTexture("Interface\\Buttons\\WHITE8x8")
        unitFrame.ClassPower.PowerBarBorder:SetVertexColor(0, 0, 0, 1)
        unitFrame.ClassPower.PowerBarBorder:SetDrawLayer("OVERLAY", 6)

        if isTop then
            -- Border on bottom of power bar (between power bar and health)
            unitFrame.ClassPower.PowerBarBorder:SetPoint("TOPLEFT", unitFrame.Container, "TOPLEFT", 1, -1 - DB.Height)
            unitFrame.ClassPower.PowerBarBorder:SetPoint("TOPRIGHT", unitFrame.Container, "TOPLEFT", 1 + totalWidth, -1 - DB.Height)
        else
            -- Border on top of power bar (between power bar and health)
            unitFrame.ClassPower.PowerBarBorder:SetPoint("BOTTOMLEFT", unitFrame.Container, "BOTTOMLEFT", 1, 1 + DB.Height)
            unitFrame.ClassPower.PowerBarBorder:SetPoint("BOTTOMRIGHT", unitFrame.Container, "BOTTOMLEFT", 1 + totalWidth, 1 + DB.Height)
        end

        unitFrame.ClassPower.PowerBarBorder:Show()
    end

    for i = 1, THEORETICAL_MAX do
        local bar = unitFrame.ClassPower[i]

        bar:ClearAllPoints()
        bar:SetPoint(anchorPoint, unitFrame.Container, anchorPoint, 1 + ((i - 1) * barWidth), yOffset)
        bar:SetSize(barWidth, DB.Height)
        bar:SetStatusBarTexture(UUF.Media.Foreground)

        -- Set initial color based on toggle
        if not DB.ColourByType then
            bar:SetStatusBarColor(DB.Foreground[1], DB.Foreground[2], DB.Foreground[3], DB.Foreground[4] or 1)
        end

        bar.frequentUpdates = DB.Smooth

        bar.Background:SetAllPoints(bar)
        bar.Background:SetTexture(UUF.Media.Background)
        bar.Background:SetVertexColor(
            DB.Background[1],
            DB.Background[2],
            DB.Background[3],
            DB.Background[4] or 1
        )
    end

    -- Update all ticks
    for i = 1, THEORETICAL_MAX - 1 do
        local tick = unitFrame.ClassPower.Ticks[i]
        if tick then
            tick:ClearAllPoints()
            tick:SetSize(1, DB.Height)
            tick:SetDrawLayer("OVERLAY", 7)
            tick:SetPoint(anchorPoint, unitFrame.Container, anchorPoint, 1 + (i * barWidth) - 0.5, yOffset)
            tick:Show()
        end
    end

    -- Adjust health bar based on position
    if isTop then
        -- Health bar anchored to bottom, reduce height
        unitFrame.HealthBackground:ClearAllPoints()
        unitFrame.HealthBackground:SetPoint("BOTTOMLEFT", unitFrame.Container, "BOTTOMLEFT", 1, 1)
        unitFrame.HealthBackground:SetPoint("BOTTOMRIGHT", unitFrame.Container, "BOTTOMRIGHT", -1, 1)
        unitFrame.HealthBackground:SetHeight(FrameDB.Height - DB.Height - 3)

        unitFrame.Health:ClearAllPoints()
        unitFrame.Health:SetPoint("BOTTOMLEFT", unitFrame.Container, "BOTTOMLEFT", 1, 1)
        unitFrame.Health:SetPoint("BOTTOMRIGHT", unitFrame.Container, "BOTTOMRIGHT", -1, 1)
        unitFrame.Health:SetHeight(FrameDB.Height - DB.Height - 3)
    else
        -- Health bar anchored to top, reduce height
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