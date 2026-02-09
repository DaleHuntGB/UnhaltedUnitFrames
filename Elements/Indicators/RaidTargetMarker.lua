local _, UUF = ...

function UUF:CreateUnitRaidTargetMarker(unitFrame, unit)
    local RaidTargetMarkerDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.RaidTargetMarker
    local frameName = unitFrame:GetName() or UUF:FetchFrameName(unit)

    local RaidTargetMarker = unitFrame.HighLevelContainer:CreateTexture(frameName .. "_RaidTargetMarkerIndicator", "OVERLAY")
    RaidTargetMarker:SetSize(RaidTargetMarkerDB.Size, RaidTargetMarkerDB.Size)
    RaidTargetMarker:SetPoint(RaidTargetMarkerDB.Layout[1], unitFrame.HighLevelContainer, RaidTargetMarkerDB.Layout[2], RaidTargetMarkerDB.Layout[3], RaidTargetMarkerDB.Layout[4])

    if RaidTargetMarkerDB.Enabled then
        unitFrame.RaidTargetIndicator = RaidTargetMarker
        unitFrame.RaidTargetIndicator:Show()
    else
        if unitFrame:IsElementEnabled("RaidTargetIndicator") then unitFrame:DisableElement("RaidTargetIndicator") end
        RaidTargetMarker:Hide()
    end

    return RaidTargetMarker
end

function UUF:UpdateUnitRaidTargetMarker(unitFrame, unit)
    local RaidTargetMarkerDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.RaidTargetMarker

    if RaidTargetMarkerDB.Enabled then
        unitFrame.RaidTargetIndicator = unitFrame.RaidTargetIndicator or UUF:CreateUnitRaidTargetMarker(unitFrame, unit)

        if not unitFrame:IsElementEnabled("RaidTargetIndicator") then unitFrame:EnableElement("RaidTargetIndicator") end

        if unitFrame.RaidTargetIndicator then
            unitFrame.RaidTargetIndicator:ClearAllPoints()
            unitFrame.RaidTargetIndicator:SetSize(RaidTargetMarkerDB.Size, RaidTargetMarkerDB.Size)
            unitFrame.RaidTargetIndicator:SetPoint(RaidTargetMarkerDB.Layout[1], unitFrame.HighLevelContainer, RaidTargetMarkerDB.Layout[2], RaidTargetMarkerDB.Layout[3], RaidTargetMarkerDB.Layout[4])
            unitFrame.RaidTargetIndicator:Show()
            unitFrame.RaidTargetIndicator:ForceUpdate()
        end
    else
        if not unitFrame.RaidTargetIndicator then return end
        if unitFrame:IsElementEnabled("RaidTargetIndicator") then unitFrame:DisableElement("RaidTargetIndicator") end
        if unitFrame.RaidTargetIndicator then
            unitFrame.RaidTargetIndicator:Hide()
            unitFrame.RaidTargetIndicator = nil
        end
    end
end