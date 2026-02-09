local _, UUF = ...

function UUF:CreateUnitPowerBar(unitFrame, unit)
    local FrameDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Frame
    local PowerBarDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].PowerBar
    local unitContainer = unitFrame.Container
    local frameName = unitFrame:GetName() or UUF:FetchFrameName(unit)

    local PowerBar = CreateFrame("StatusBar", frameName .. "_PowerBar", unitContainer)
    UUF:QueueOrRun(function()
        PowerBar:SetPoint("BOTTOMLEFT", unitContainer, "BOTTOMLEFT", 1, 1)
        PowerBar:SetSize(FrameDB.Width - 2, PowerBarDB.Height)
    end)
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

    PowerBar.Background = PowerBar:CreateTexture(frameName .. "_PowerBackground", "BACKGROUND")
    UUF:QueueOrRun(function()
        PowerBar.Background:SetPoint("BOTTOMLEFT", unitContainer, "BOTTOMLEFT", 1, 1)
        PowerBar.Background:SetSize(FrameDB.Width - 2, PowerBarDB.Height)
    end)
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
        UUF:QueueOrRun(function() PowerBar:Show() if unitFrame.PowerBackground then unitFrame.PowerBackground:Show() end end)
    else
        if unitFrame:IsElementEnabled("Power") then unitFrame:DisableElement("Power") end
        UUF:QueueOrRun(function() PowerBar:Hide() if unitFrame.PowerBackground then unitFrame.PowerBackground:Hide() end end)
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
            local pw = unitFrame.Power
            UUF:QueueOrRun(function()
                pw:ClearAllPoints()
                pw:SetPoint("BOTTOMLEFT", unitFrame.Container, "BOTTOMLEFT", 1, 1)
                pw:SetSize(unitFrame:GetWidth() - 2, PowerBarDB.Height)
                if pw.Background then
                    pw.Background:ClearAllPoints()
                    pw.Background:SetPoint("BOTTOMLEFT", unitFrame.Container, "BOTTOMLEFT", 1, 1)
                    pw.Background:SetSize(unitFrame:GetWidth() - 2, PowerBarDB.Height)
                    pw.Background:SetTexture(UUF.Media.Background)
                    pw.Background:SetVertexColor(PowerBarDB.Background[1], PowerBarDB.Background[2], PowerBarDB.Background[3], PowerBarDB.Background[4] or 1)
                end
                if pw.PowerBarBorder then
                    pw.PowerBarBorder:ClearAllPoints()
                    pw.PowerBarBorder:SetPoint("TOPLEFT", pw, "TOPLEFT", 0, 1)
                    pw.PowerBarBorder:SetPoint("TOPRIGHT", pw, "TOPRIGHT", 0, 1)
                end
                pw:SetStatusBarColor(PowerBarDB.Foreground[1], PowerBarDB.Foreground[2], PowerBarDB.Foreground[3], PowerBarDB.Foreground[4] or 1)
                pw:SetStatusBarTexture(UUF.Media.Foreground)
                pw.colorPower = PowerBarDB.ColourByType
                pw.colorClass = PowerBarDB.ColourByClass
                pw.frequentUpdates = PowerBarDB.Smooth
                if PowerBarDB.Inverse then
                    pw:SetReverseFill(true)
                else
                    pw:SetReverseFill(false)
                end
                pw:Show()
                pw:ForceUpdate()
            end)
        end
    else
        if not unitFrame.Power then return end
        if unitFrame:IsElementEnabled("Power") then unitFrame:DisableElement("Power") end
        if unitFrame.Power then UUF:QueueOrRun(function() unitFrame.Power:Hide() end) end
        unitFrame.Power = nil
    end

    UUF:UpdateHealthBarLayout(unitFrame, unit)
end