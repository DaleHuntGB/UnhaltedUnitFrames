local _, UUF = ...

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
        PowerBar.PowerBarBorder:SetPoint("TOPLEFT", PowerBar, "TOPLEFT", 0, 1)
        PowerBar.PowerBarBorder:SetPoint("TOPRIGHT", PowerBar, "TOPRIGHT", 0, 1)
        if PowerBarDB.ShowBorder then
            PowerBar.PowerBarBorder:SetVertexColor(unpack(PowerBarDB.BorderColour))
        else
            PowerBar.PowerBarBorder:SetVertexColor(0, 0, 0, 0)
        end
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
            unitFrame.Power:ClearAllPoints()
            unitFrame.Power:SetPoint("BOTTOMLEFT", unitFrame.Container, "BOTTOMLEFT", 1, 1)
            unitFrame.Power:SetSize(unitFrame:GetWidth() - 2, PowerBarDB.Height)
            unitFrame.Power:SetStatusBarColor(PowerBarDB.Foreground[1], PowerBarDB.Foreground[2], PowerBarDB.Foreground[3], PowerBarDB.Foreground[4] or 1)
            unitFrame.Power:SetStatusBarTexture(UUF.Media.Foreground)
            unitFrame.Power.colorPower = PowerBarDB.ColourByType
            unitFrame.Power.colorClass = PowerBarDB.ColourByClass
            unitFrame.Power.frequentUpdates = PowerBarDB.Smooth
            if PowerBarDB.Inverse then
                unitFrame.Power:SetReverseFill(true)
            else
                unitFrame.Power:SetReverseFill(false)
            end
        end

        if unitFrame.Power.Background then
            unitFrame.Power.Background:ClearAllPoints()
            unitFrame.Power.Background:SetPoint("BOTTOMLEFT", unitFrame.Container, "BOTTOMLEFT", 1, 1)
            unitFrame.Power.Background:SetSize(unitFrame:GetWidth() - 2, PowerBarDB.Height)
            unitFrame.Power.Background:SetVertexColor(PowerBarDB.Background[1], PowerBarDB.Background[2], PowerBarDB.Background[3], PowerBarDB.Background[4] or 1)
            unitFrame.Power.Background:SetTexture(UUF.Media.Background)
        end

        if unitFrame.Power.PowerBarBorder then
            unitFrame.Power.PowerBarBorder:ClearAllPoints()
            unitFrame.Power.PowerBarBorder:SetPoint("TOPLEFT", unitFrame.Power, "TOPLEFT", 0, 1)
            unitFrame.Power.PowerBarBorder:SetPoint("TOPRIGHT", unitFrame.Power, "TOPRIGHT", 0, 1)
            if PowerBarDB.ShowBorder then
                unitFrame.Power.PowerBarBorder:SetVertexColor(unpack(PowerBarDB.BorderColour))
            else
                unitFrame.Power.PowerBarBorder:SetVertexColor(0, 0, 0, 0)
            end
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
