local _, UUF = ...

local UpdateSecondaryPowerBarEventFrame = CreateFrame("Frame")
UpdateSecondaryPowerBarEventFrame:RegisterEvent("TRAIT_CONFIG_UPDATED")
UpdateSecondaryPowerBarEventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
UpdateSecondaryPowerBarEventFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
UpdateSecondaryPowerBarEventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_SPECIALIZATION_CHANGED" then local unit = ... if unit ~= "player" then return end end
    C_Timer.After(0.1, function()
        if UUF["PLAYER"] then
            UUF:UpdateUnitSecondaryPowerBar(UUF["PLAYER"], "player")
        end
    end)
end)

function UUF:CreateUnitSecondaryPowerBar(unitFrame, unit)
    local FrameDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Frame
    local DB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].SecondaryPowerBar
    local container = unitFrame.Container

    if not DB.Enabled then return nil end

    local powerType = UUF:GetSecondaryPowerType()
    if not powerType then return nil end

    local ClassPower = {}
    ClassPower.Ticks = {}

    local maxPower = UnitPowerMax("player", powerType) or 6
    local totalWidth = FrameDB.Width - 2
    local unitFrameWidth = totalWidth / maxPower

    ClassPower.ContainerBackground = container:CreateTexture(nil, "BACKGROUND")
    ClassPower.ContainerBackground:SetPoint("TOPLEFT", container, "TOPLEFT", 1, -1)
    ClassPower.ContainerBackground:SetSize(totalWidth, DB.Height)
    ClassPower.ContainerBackground:SetTexture(UUF.Media.Background)
    ClassPower.ContainerBackground:SetVertexColor( DB.Background[1], DB.Background[2], DB.Background[3], DB.Background[4] or 1 )

    for i = 1, maxPower do
        local secondaryPowerBar = CreateFrame("StatusBar", nil, container)
        secondaryPowerBar:SetSize(unitFrameWidth, DB.Height)
        secondaryPowerBar:SetPoint("TOPLEFT", container, "TOPLEFT", 1 + ((i - 1) * unitFrameWidth), -1)
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

    for i = 1, maxPower - 1 do
        local secondaryPowerTick = ClassPower.OverlayFrame:CreateTexture(nil, "OVERLAY")
        secondaryPowerTick:SetTexture("Interface\\Buttons\\WHITE8x8")
        secondaryPowerTick:SetVertexColor(0, 0, 0, 1)
        secondaryPowerTick:SetDrawLayer("OVERLAY", 7)
        secondaryPowerTick:SetSize(1, DB.Height)
        secondaryPowerTick:SetPoint("TOPLEFT", container, "TOPLEFT", 1 + (i * unitFrameWidth) - 0.5, -1)
        secondaryPowerTick:Show()
        ClassPower.Ticks[i] = secondaryPowerTick
    end

    ClassPower.PowerBarBorder = ClassPower.OverlayFrame:CreateTexture(nil, "OVERLAY")
    ClassPower.PowerBarBorder:SetHeight(1)
    ClassPower.PowerBarBorder:SetTexture("Interface\\Buttons\\WHITE8x8")
    ClassPower.PowerBarBorder:SetVertexColor(0, 0, 0, 1)
    ClassPower.PowerBarBorder:SetDrawLayer("OVERLAY", 6)
    ClassPower.PowerBarBorder:SetPoint("TOPLEFT", container, "TOPLEFT", 1, -1 - DB.Height)
    ClassPower.PowerBarBorder:SetPoint("TOPRIGHT", container, "TOPLEFT", 1 + totalWidth, -1 - DB.Height)

    ClassPower.PostUpdateColor = function(element, color)
        local DB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].SecondaryPowerBar
        if not DB.ColourByType then
            for i = 1, #element do
                if element[i] then
                    element[i]:SetStatusBarColor( DB.Foreground[1], DB.Foreground[2], DB.Foreground[3], DB.Foreground[4] or 1 )
                end
            end
        end
    end

    unitFrame.ClassPower = ClassPower
    ClassPower.ContainerBackground:Show()
    ClassPower.PowerBarBorder:Show()
    ClassPower.OverlayFrame:Show()

    UUF:UpdateHealthBarLayout(unitFrame, unit)

    return ClassPower
end

function UUF:UpdateUnitSecondaryPowerBar(unitFrame, unit)
    if not unitFrame then return end

    local FrameDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Frame
    local DB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].SecondaryPowerBar

    local powerType = UUF:GetSecondaryPowerType()

    if not DB.Enabled or not powerType then
        if unitFrame.ClassPower then
            if unitFrame:IsElementEnabled("ClassPower") then
                unitFrame:DisableElement("ClassPower")
            end

            for i = 1, #unitFrame.ClassPower do
                if unitFrame.ClassPower[i] then
                    unitFrame.ClassPower[i]:Hide()
                    unitFrame.ClassPower[i]:SetParent(nil)
                    unitFrame.ClassPower[i] = nil
                end
            end

            if unitFrame.ClassPower.Ticks then
                for i = 1, #unitFrame.ClassPower.Ticks do
                    if unitFrame.ClassPower.Ticks[i] then
                        unitFrame.ClassPower.Ticks[i]:Hide()
                        unitFrame.ClassPower.Ticks[i]:SetParent(nil)
                        unitFrame.ClassPower.Ticks[i] = nil
                    end
                end
            end

            if unitFrame.ClassPower.ContainerBackground then
                unitFrame.ClassPower.ContainerBackground:Hide()
                unitFrame.ClassPower.ContainerBackground:SetParent(nil)
            end
            if unitFrame.ClassPower.PowerBarBorder then
                unitFrame.ClassPower.PowerBarBorder:Hide()
                unitFrame.ClassPower.PowerBarBorder:SetParent(nil)
            end
            if unitFrame.ClassPower.OverlayFrame then
                unitFrame.ClassPower.OverlayFrame:Hide()
                unitFrame.ClassPower.OverlayFrame:SetParent(nil)
            end

            unitFrame.ClassPower = nil
        end

        UUF:UpdateHealthBarLayout(unitFrame, unit)
        return
    end

    local currentMaxPower = UnitPowerMax("player", powerType) or 6
    local existingMaxPower = unitFrame.ClassPower and #unitFrame.ClassPower or 0

    if not unitFrame.ClassPower or currentMaxPower ~= existingMaxPower then
        local wasEnabled = unitFrame.ClassPower and unitFrame:IsElementEnabled("ClassPower")

        if unitFrame.ClassPower then
            if wasEnabled then
                unitFrame:DisableElement("ClassPower")
            end

            for i = 1, #unitFrame.ClassPower do
                if unitFrame.ClassPower[i] then
                    unitFrame.ClassPower[i]:Hide()
                    unitFrame.ClassPower[i]:SetParent(nil)
                    unitFrame.ClassPower[i] = nil
                end
            end

            if unitFrame.ClassPower.Ticks then
                for i = 1, #unitFrame.ClassPower.Ticks do
                    if unitFrame.ClassPower.Ticks[i] then
                        unitFrame.ClassPower.Ticks[i]:Hide()
                        unitFrame.ClassPower.Ticks[i]:SetParent(nil)
                        unitFrame.ClassPower.Ticks[i] = nil
                    end
                end
            end

            if unitFrame.ClassPower.ContainerBackground then
                unitFrame.ClassPower.ContainerBackground:Hide()
                unitFrame.ClassPower.ContainerBackground:SetParent(nil)
            end
            if unitFrame.ClassPower.PowerBarBorder then
                unitFrame.ClassPower.PowerBarBorder:Hide()
                unitFrame.ClassPower.PowerBarBorder:SetParent(nil)
            end
            if unitFrame.ClassPower.OverlayFrame then
                unitFrame.ClassPower.OverlayFrame:Hide()
                unitFrame.ClassPower.OverlayFrame:SetParent(nil)
            end
        end

        unitFrame.ClassPower = UUF:CreateUnitSecondaryPowerBar(unitFrame, unit)

        if unitFrame.ClassPower then
            unitFrame:EnableElement("ClassPower")
            UUF:UpdateHealthBarLayout(unitFrame, unit)
            unitFrame.ClassPower:ForceUpdate()
        end
        return
    end

    if not unitFrame:IsElementEnabled("ClassPower") then
        unitFrame:EnableElement("ClassPower")
    end

    local totalWidth = FrameDB.Width - 2
    local unitFrameWidth = totalWidth / currentMaxPower

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

    for i = 1, currentMaxPower do
        local secondaryPowerBar = unitFrame.ClassPower[i]
        if secondaryPowerBar then
            secondaryPowerBar:ClearAllPoints()
            secondaryPowerBar:SetPoint("TOPLEFT", unitFrame.Container, "TOPLEFT", 1 + ((i - 1) * unitFrameWidth), -1)
            secondaryPowerBar:SetSize(unitFrameWidth, DB.Height)
            secondaryPowerBar:SetStatusBarTexture(UUF.Media.Foreground)

            if not DB.ColourByType then
                secondaryPowerBar:SetStatusBarColor(DB.Foreground[1], DB.Foreground[2], DB.Foreground[3], DB.Foreground[4] or 1)
            end

            secondaryPowerBar.frequentUpdates = DB.Smooth

            secondaryPowerBar.Background:SetAllPoints(secondaryPowerBar)
            secondaryPowerBar.Background:SetTexture(UUF.Media.Background)
            secondaryPowerBar.Background:SetVertexColor( DB.Background[1], DB.Background[2], DB.Background[3], DB.Background[4] or 1 )
        end
    end

    for i = 1, currentMaxPower - 1 do
        local secondaryPowerBarTick = unitFrame.ClassPower.Ticks[i]
        if secondaryPowerBarTick then
            secondaryPowerBarTick:ClearAllPoints()
            secondaryPowerBarTick:SetSize(1, DB.Height)
            secondaryPowerBarTick:SetDrawLayer("OVERLAY", 7)
            secondaryPowerBarTick:SetPoint("TOPLEFT", unitFrame.Container, "TOPLEFT", 1 + (i * unitFrameWidth) - 0.5, -1)
            secondaryPowerBarTick:Show()
        end
    end

    UUF:UpdateHealthBarLayout(unitFrame, unit)

    if unitFrame.ClassPower then
        unitFrame.ClassPower:ForceUpdate()
    end
end