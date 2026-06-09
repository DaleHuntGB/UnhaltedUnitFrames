local _, UUF = ...

function UUF:CreateUnitPvPIndicator(unitFrame, unit)
    local PvPIndicatorDB = UUF.db.profile.Units.player.Indicators.PvP

    local PvPIndicator = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit) .. "_PvPIndicator", "OVERLAY", nil, 1)
    PvPIndicator:SetSize(PvPIndicatorDB.Size, PvPIndicatorDB.Size)
    PvPIndicator:SetPoint(PvPIndicatorDB.Layout[1], unitFrame.HighLevelContainer, PvPIndicatorDB.Layout[2], PvPIndicatorDB.Layout[3], PvPIndicatorDB.Layout[4])

    PvPIndicator.Badge = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit) .. "_PvPIndicatorBadge", "OVERLAY")
    PvPIndicator.Badge:SetSize(PvPIndicatorDB.Size * 5 / 3, PvPIndicatorDB.Size * 26 / 15)
    PvPIndicator.Badge:SetPoint("CENTER", PvPIndicator, "CENTER", 0, 0)

    if PvPIndicatorDB.Enabled then
        unitFrame.PvPIndicator = PvPIndicator
    else
        PvPIndicator:Hide()
        PvPIndicator.Badge:Hide()
    end

    return PvPIndicator
end

function UUF:UpdateUnitPvPIndicator(unitFrame, unit)
    local PvPIndicatorDB = UUF.db.profile.Units.player.Indicators.PvP

    if PvPIndicatorDB.Enabled then
        unitFrame.PvPIndicator = unitFrame.PvPIndicator or UUF:CreateUnitPvPIndicator(unitFrame, unit)

        if not unitFrame:IsElementEnabled("PvPIndicator") then unitFrame:EnableElement("PvPIndicator") end

        if unitFrame.PvPIndicator then
            unitFrame.PvPIndicator:ClearAllPoints()
            unitFrame.PvPIndicator:SetSize(PvPIndicatorDB.Size, PvPIndicatorDB.Size)
            unitFrame.PvPIndicator:SetPoint(PvPIndicatorDB.Layout[1], unitFrame.HighLevelContainer, PvPIndicatorDB.Layout[2], PvPIndicatorDB.Layout[3], PvPIndicatorDB.Layout[4])
            unitFrame.PvPIndicator.Badge:ClearAllPoints()
            unitFrame.PvPIndicator.Badge:SetSize(PvPIndicatorDB.Size * 5 / 3, PvPIndicatorDB.Size * 26 / 15)
            unitFrame.PvPIndicator.Badge:SetPoint("CENTER", unitFrame.PvPIndicator, "CENTER", 0, 0)
            unitFrame.PvPIndicator:ForceUpdate()
        end
    else
        if not unitFrame.PvPIndicator then return end
        if unitFrame:IsElementEnabled("PvPIndicator") then unitFrame:DisableElement("PvPIndicator") end
        if unitFrame.PvPIndicator then
            unitFrame.PvPIndicator:Hide()
            unitFrame.PvPIndicator.Badge:Hide()
            unitFrame.PvPIndicator = nil
        end
    end
end
