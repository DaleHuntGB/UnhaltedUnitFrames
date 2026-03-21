local _, UUF = ...

local function CreatePowerBarPostUpdateColor(unitFrame, unit)
    local PowerBarDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].PowerBar
    return function(element, _, color, altR, altG, altB)
        if not PowerBarDB.ColourBackgroundByType then return end
        if not element.Background then return end

        local mult = PowerBarDB.BackgroundMultiplier or 0.75
        local r, g, b

        if altR and altG and altB then
            r, g, b = altR, altG, altB
        elseif color then
            r, g, b = color:GetRGB()
        else
            r, g, b = element:GetStatusBarColor()
        end

        if r and g and b then
            element.Background:SetVertexColor(r * mult, g * mult, b * mult, PowerBarDB.Background[4] or 1)
        end
    end
end

local function LayoutUnitPowerBar(unitFrame, unit, width)
    local PowerBarDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].PowerBar
    local powerBar = unitFrame.Power
    if not powerBar then return end

    width = width and width > 0 and width or UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Frame.Width
    local position = UUF:GetConfiguredPowerBarPosition(unit)
    local isTopAnchored = position == "TOP"
    local anchorPoint = isTopAnchored and "TOPLEFT" or "BOTTOMLEFT"
    local anchorY = isTopAnchored and -1 or 1

    powerBar:ClearAllPoints()
    powerBar:SetPoint(anchorPoint, unitFrame.Container, anchorPoint, 1, anchorY)
    powerBar:SetSize(width - 2, PowerBarDB.Height)

    if powerBar.Background then
        powerBar.Background:ClearAllPoints()
        powerBar.Background:SetPoint(anchorPoint, unitFrame.Container, anchorPoint, 1, anchorY)
        powerBar.Background:SetSize(width - 2, PowerBarDB.Height)
    end

    if powerBar.PowerBarBorder then
        powerBar.PowerBarBorder:ClearAllPoints()
        if isTopAnchored then
            powerBar.PowerBarBorder:SetPoint("BOTTOMLEFT", powerBar, "BOTTOMLEFT", 0, -1)
            powerBar.PowerBarBorder:SetPoint("BOTTOMRIGHT", powerBar, "BOTTOMRIGHT", 0, -1)
        else
            powerBar.PowerBarBorder:SetPoint("TOPLEFT", powerBar, "TOPLEFT", 0, 1)
            powerBar.PowerBarBorder:SetPoint("TOPRIGHT", powerBar, "TOPRIGHT", 0, 1)
        end
    end
end

function UUF:CreateUnitPowerBar(unitFrame, unit)
    local FrameDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Frame
    local PowerBarDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].PowerBar
    local unitContainer = unitFrame.Container

    local PowerBar = CreateFrame("StatusBar", UUF:FetchFrameName(unit) .. "_PowerBar", unitContainer)
    PowerBar:SetPoint("BOTTOMLEFT", unitContainer, "BOTTOMLEFT", 1, 1)
    PowerBar:SetSize(FrameDB.Width - 2, PowerBarDB.Height)
    PowerBar:SetStatusBarTexture(UUF.Media.Foreground)
    PowerBar:SetStatusBarColor(PowerBarDB.Foreground[1], PowerBarDB.Foreground[2], PowerBarDB.Foreground[3], PowerBarDB.Foreground[4] or 1)
    PowerBar:SetFrameLevel(unitContainer:GetFrameLevel() + 2)
    PowerBar.colorPower = PowerBarDB.ColourByType
    PowerBar.colorClass = PowerBarDB.ColourByClass
    PowerBar.frequentUpdates = PowerBarDB.Smooth
    PowerBar.PostUpdateColor = CreatePowerBarPostUpdateColor(unitFrame, unit)

    if PowerBarDB.Inverse then
        PowerBar:SetReverseFill(true)
    else
        PowerBar:SetReverseFill(false)
    end

    PowerBar.Background = PowerBar:CreateTexture(UUF:FetchFrameName(unit) .. "_PowerBackground", "BACKGROUND")
    PowerBar.Background:SetPoint("BOTTOMLEFT", unitContainer, "BOTTOMLEFT", 1, 1)
    PowerBar.Background:SetSize(FrameDB.Width - 2, PowerBarDB.Height)
    PowerBar.Background:SetTexture(UUF.Media.Background)
    PowerBar.Background:SetVertexColor(PowerBarDB.Background[1], PowerBarDB.Background[2], PowerBarDB.Background[3], PowerBarDB.Background[4] or 1)

    if not PowerBar.PowerBarBorder then
        PowerBar.PowerBarBorder = PowerBar:CreateTexture(nil, "OVERLAY")
        PowerBar.PowerBarBorder:SetHeight(1)
        PowerBar.PowerBarBorder:SetTexture("Interface\\Buttons\\WHITE8x8")
        PowerBar.PowerBarBorder:SetVertexColor(0, 0, 0, 1)
        PowerBar.PowerBarBorder:SetPoint("TOPLEFT", PowerBar, "TOPLEFT", 0, 1)
        PowerBar.PowerBarBorder:SetPoint("TOPRIGHT", PowerBar, "TOPRIGHT", 0, 1)
    end

    if PowerBarDB.Enabled then
        unitFrame.Power = PowerBar
        PowerBar:Show()
        if unitFrame.PowerBackground then unitFrame.PowerBackground:Show() end
    else
        if unitFrame:IsElementEnabled("Power") then unitFrame:DisableElement("Power") end
        PowerBar:Hide()
        if unitFrame.PowerBackground then unitFrame.PowerBackground:Hide() end
    end

    if unitFrame.Power then
        LayoutUnitPowerBar(unitFrame, unit, FrameDB.Width)
    end
    UUF:UpdateHealthBarLayout(unitFrame, unit)

    return PowerBar
end

function UUF:UpdateUnitPowerBar(unitFrame, unit)
    local FrameDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Frame
    local PowerBarDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].PowerBar

    if PowerBarDB.Enabled then
        unitFrame.Power = unitFrame.Power or UUF:CreateUnitPowerBar(unitFrame, unit)

        if not unitFrame:IsElementEnabled("Power") then unitFrame:EnableElement("Power") end

        if unitFrame.Power then
            LayoutUnitPowerBar(unitFrame, unit, unitFrame:GetWidth())
            unitFrame.Power:SetStatusBarColor(PowerBarDB.Foreground[1], PowerBarDB.Foreground[2], PowerBarDB.Foreground[3], PowerBarDB.Foreground[4] or 1)
            unitFrame.Power:SetStatusBarTexture(UUF.Media.Foreground)
            unitFrame.Power.colorPower = PowerBarDB.ColourByType
            unitFrame.Power.colorClass = PowerBarDB.ColourByClass
            unitFrame.Power.frequentUpdates = PowerBarDB.Smooth
            unitFrame.Power.PostUpdateColor = CreatePowerBarPostUpdateColor(unitFrame, unit)
            if PowerBarDB.Inverse then
                unitFrame.Power:SetReverseFill(true)
            else
                unitFrame.Power:SetReverseFill(false)
            end
        end

        if unitFrame.Power.Background then
            unitFrame.Power.Background:SetVertexColor(PowerBarDB.Background[1], PowerBarDB.Background[2], PowerBarDB.Background[3], PowerBarDB.Background[4] or 1)
            unitFrame.Power.Background:SetTexture(UUF.Media.Background)
        end

        unitFrame.Power:Show()
        unitFrame.Power:ForceUpdate()
    else
        if not unitFrame.Power then return end
        if unitFrame:IsElementEnabled("Power") then unitFrame:DisableElement("Power") end
        unitFrame.Power:Hide()
        unitFrame.Power = nil
    end

    UUF:UpdateHealthBarLayout(unitFrame, unit)
end
