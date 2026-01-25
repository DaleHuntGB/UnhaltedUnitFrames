local _, UUF = ...

function UUF:CreateUnitPowerBar(unitFrame, unit)
    local FrameDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Frame
    local PowerBarDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].PowerBar
    local unitContainer = unitFrame.Container
    if not PowerBarDB.Attached then unitContainer = unitFrame end

    local PowerBar = CreateFrame("StatusBar", UUF:FetchFrameName(unit) .. "_PowerBar", unitContainer)
    if PowerBarDB.Attached then
        PowerBar:SetPoint("BOTTOMLEFT", unitContainer, "BOTTOMLEFT", 1, 1)
        PowerBar:SetWidth(FrameDB.Width - 2)
        PowerBar:SetFrameLevel(unitContainer:GetFrameLevel() + 2)
    else
        PowerBar:SetPoint(PowerBarDB.Layout[1], unitContainer, PowerBarDB.Layout[2], PowerBarDB.Layout[3], PowerBarDB.Layout[4])
        if PowerBarDB.MatchParentWidth then PowerBar:SetWidth(FrameDB.Width - 2) else PowerBar:SetWidth(PowerBarDB.Width) end
        PowerBar:SetFrameStrata(PowerBarDB.FrameStrata)
    end
    PowerBar:SetHeight(PowerBarDB.Height)
    PowerBar:SetStatusBarTexture(UUF.Media.Foreground)
    PowerBar:SetStatusBarColor(PowerBarDB.Foreground[1], PowerBarDB.Foreground[2], PowerBarDB.Foreground[3], PowerBarDB.Foreground[4] or 1)
    PowerBar.colorPower = PowerBarDB.ColourByType
    PowerBar.colorClass = PowerBarDB.ColourByClass
    PowerBar.frequentUpdates = PowerBarDB.Smooth

    if PowerBarDB.Inverse then
        PowerBar:SetReverseFill(true)
    else
        PowerBar:SetReverseFill(false)
    end

    PowerBar.Background = PowerBar:CreateTexture(UUF:FetchFrameName(unit) .. "_PowerBackground", "BACKGROUND")
    PowerBar.Background:SetPoint("BOTTOMLEFT", PowerBar, "BOTTOMLEFT", 0, 0)
    if PowerBarDB.Attached or PowerBarDB.MatchParentWidth then PowerBar.Background:SetWidth(FrameDB.Width - 2) else PowerBar.Background:SetWidth(PowerBarDB.Width) end
    PowerBar.Background:SetHeight(PowerBarDB.Height)
    PowerBar.Background:SetTexture(UUF.Media.Background)
    PowerBar.Background:SetVertexColor(PowerBarDB.Background[1], PowerBarDB.Background[2], PowerBarDB.Background[3], PowerBarDB.Background[4] or 1)

    if not PowerBar.PowerBarBorder then
        PowerBar.PowerBarBorder = PowerBar:CreateTexture(nil, "OVERLAY")
        PowerBar.PowerBarBorder:SetHeight(1)
        PowerBar.PowerBarBorder:SetTexture("Interface\\Buttons\\WHITE8x8")
        PowerBar.PowerBarBorder:SetVertexColor(0,0,0,1)
        if PowerBarDB.Attached then
            PowerBar.PowerBarBorder:SetPoint("TOPLEFT", PowerBar, "TOPLEFT", 0, 1)
            PowerBar.PowerBarBorder:SetPoint("TOPRIGHT", PowerBar, "TOPRIGHT", 0, 1)
        else
            PowerBar.PowerBarBorder:SetDrawLayer("BACKGROUND")
            PowerBar.PowerBarBorder:SetPoint("TOPLEFT", PowerBar, "TOPLEFT", -1, 1)
            PowerBar.PowerBarBorder:SetPoint("TOPRIGHT", PowerBar, "TOPRIGHT", 1, 1)
            PowerBar.PowerBarBorder:SetPoint("BOTTOMLEFT", PowerBar, "BOTTOMLEFT", 1, -1)
            PowerBar.PowerBarBorder:SetPoint("BOTTOMRIGHT", PowerBar, "BOTTOMRIGHT", -1, -1)
        end
    end

    if PowerBarDB.Enabled then
        unitFrame.Power = PowerBar
        PowerBar:Show()
        if unitFrame.PowerBackground then unitFrame.PowerBackground:Show() end
        if PowerBarDB.Attached then
            unitFrame.HealthBackground:SetHeight(FrameDB.Height - PowerBarDB.Height - 3)
            unitFrame.Health:SetHeight(FrameDB.Height - PowerBarDB.Height - 3)
        else
            unitFrame.HealthBackground:SetHeight(FrameDB.Height - 2)
            unitFrame.Health:SetHeight(FrameDB.Height - 2)
        end
    else
        if unitFrame:IsElementEnabled("Power") then unitFrame:DisableElement("Power") end
        PowerBar:Hide()
        if unitFrame.PowerBackground then unitFrame.PowerBackground:Hide() end
        unitFrame.HealthBackground:SetHeight(FrameDB.Height - 2)
        unitFrame.Health:SetHeight(FrameDB.Height - 2)
    end

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
            if PowerBarDB.Attached then
                unitFrame.Power:SetPoint("BOTTOMLEFT", unitFrame.Container, "BOTTOMLEFT", 1, 1)
                unitFrame.Power:SetSize(unitFrame:GetWidth() - 2, PowerBarDB.Height)
            else
                unitFrame.Power:SetPoint(PowerBarDB.Layout[1], unitFrame, PowerBarDB.Layout[2], PowerBarDB.Layout[3], PowerBarDB.Layout[4])
                if PowerBarDB.MatchParentWidth then unitFrame.Power:SetWidth(unitFrame:GetWidth() - 2) else unitFrame.Power:SetWidth(PowerBarDB.Width) end
                unitFrame.Power:SetHeight(PowerBarDB.Height)
            end
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
            if PowerBarDB.Attached or PowerBarDB.MatchParentWidth then unitFrame.Power.Background:SetWidth(unitFrame:GetWidth() - 2) else unitFrame.Power.Background:SetWidth(PowerBarDB.Width) end
            unitFrame.Power.Background:SetHeight(PowerBarDB.Height)
            unitFrame.Power.Background:SetVertexColor(PowerBarDB.Background[1], PowerBarDB.Background[2], PowerBarDB.Background[3], PowerBarDB.Background[4] or 1)
            unitFrame.Power.Background:SetTexture(UUF.Media.Background)
        end

        if unitFrame.Power.PowerBarBorder then
            unitFrame.Power.PowerBarBorder:ClearAllPoints()
            if PowerBarDB.Attached then
                unitFrame.Power.PowerBarBorder:SetDrawLayer("OVERLAY")
                unitFrame.Power.PowerBarBorder:SetPoint("TOPLEFT", unitFrame.Power, "TOPLEFT", 0, 1)
                unitFrame.Power.PowerBarBorder:SetPoint("TOPRIGHT", unitFrame.Power, "TOPRIGHT", 0, 1)
            else
                unitFrame.Power.PowerBarBorder:SetDrawLayer("BACKGROUND")
                unitFrame.Power.PowerBarBorder:SetPoint("TOPLEFT", unitFrame.Power, "TOPLEFT", -1, 1)
                unitFrame.Power.PowerBarBorder:SetPoint("TOPRIGHT", unitFrame.Power, "TOPRIGHT", 1, 1)
                unitFrame.Power.PowerBarBorder:SetPoint("BOTTOMLEFT", unitFrame.Power, "BOTTOMLEFT", 1, -1)
                unitFrame.Power.PowerBarBorder:SetPoint("BOTTOMRIGHT", unitFrame.Power, "BOTTOMRIGHT", -1, -1)
            end
        end

        if PowerBarDB.Attached then
            unitFrame.HealthBackground:SetHeight(FrameDB.Height - PowerBarDB.Height - 3)
            unitFrame.Health:SetHeight(FrameDB.Height - PowerBarDB.Height - 3)
        else
            unitFrame.HealthBackground:SetHeight(FrameDB.Height - 2)
            unitFrame.Health:SetHeight(FrameDB.Height - 2)
        end

        unitFrame.Power:Show()
        unitFrame.Power:ForceUpdate()
    else
        if not unitFrame.Power then return end
        if unitFrame:IsElementEnabled("Power") then unitFrame:DisableElement("Power") end
        unitFrame.Power:Hide()
        unitFrame.Power = nil
        unitFrame.HealthBackground:SetHeight(FrameDB.Height - 2)
        unitFrame.Health:SetHeight(FrameDB.Height - 2)
    end
end