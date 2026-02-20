local _, UUF = ...

function UUF:CreateUnitRaidTargetMarker(unitFrame, unit)
    local RaidTargetMarkerDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.RaidTargetMarker
    local frameName = unitFrame:GetName() or UUF:FetchFrameName(unit)

    local RaidTargetMarker = unitFrame.HighLevelContainer:CreateTexture(frameName .. "_RaidTargetMarkerIndicator", "OVERLAY")
    UUF:QueueOrRun(function()
        RaidTargetMarker:SetSize(RaidTargetMarkerDB.Size, RaidTargetMarkerDB.Size)
        RaidTargetMarker:SetPoint(RaidTargetMarkerDB.Layout[1], unitFrame.HighLevelContainer, RaidTargetMarkerDB.Layout[2], RaidTargetMarkerDB.Layout[3], RaidTargetMarkerDB.Layout[4])
    end)

    if RaidTargetMarkerDB.Enabled then
        unitFrame.RaidTargetIndicator = RaidTargetMarker
        UUF:QueueOrRun(function() unitFrame.RaidTargetIndicator:Show() end)
    else
        if unitFrame:IsElementEnabled("RaidTargetIndicator") then unitFrame:DisableElement("RaidTargetIndicator") end
        UUF:QueueOrRun(function() RaidTargetMarker:Hide() end)
    end

    return RaidTargetMarker
end

function UUF:UpdateUnitRaidTargetMarker(unitFrame, unit)
    local RaidTargetMarkerDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.RaidTargetMarker

    if RaidTargetMarkerDB.Enabled then
        unitFrame.RaidTargetIndicator = unitFrame.RaidTargetIndicator or UUF:CreateUnitRaidTargetMarker(unitFrame, unit)

        if not unitFrame:IsElementEnabled("RaidTargetIndicator") then unitFrame:EnableElement("RaidTargetIndicator") end

        if unitFrame.RaidTargetIndicator then
            UUF:QueueOrRun(function()
                unitFrame.RaidTargetIndicator:ClearAllPoints()
                unitFrame.RaidTargetIndicator:SetSize(RaidTargetMarkerDB.Size, RaidTargetMarkerDB.Size)
                UUF:SetPointIfChanged(unitFrame.RaidTargetIndicator, RaidTargetMarkerDB.Layout[1], unitFrame.HighLevelContainer, RaidTargetMarkerDB.Layout[2], RaidTargetMarkerDB.Layout[3], RaidTargetMarkerDB.Layout[4])
                unitFrame.RaidTargetIndicator:Show()
                unitFrame.RaidTargetIndicator:ForceUpdate()
            end)
        end
    else
        if not unitFrame.RaidTargetIndicator then return end
        if unitFrame:IsElementEnabled("RaidTargetIndicator") then unitFrame:DisableElement("RaidTargetIndicator") end
        if unitFrame.RaidTargetIndicator then
            UUF:QueueOrRun(function() unitFrame.RaidTargetIndicator:Hide() end)
            unitFrame.RaidTargetIndicator = nil
        end
    end
end