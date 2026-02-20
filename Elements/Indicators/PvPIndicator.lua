local _, UUF = ...

function UUF:CreateUnitPvPIndicator(unitFrame, unit)
    local PvPDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.PvPIndicator
    local frameName = unitFrame:GetName() or UUF:FetchFrameName(unit)

    local PvPIndicator = unitFrame.HighLevelContainer:CreateTexture(frameName .. "_PvPIndicator", "OVERLAY")
    UUF:QueueOrRun(function()
        PvPIndicator:SetSize(PvPDB.Size, PvPDB.Size)
        PvPIndicator:SetPoint(PvPDB.Layout[1], unitFrame.HighLevelContainer, PvPDB.Layout[2], PvPDB.Layout[3], PvPDB.Layout[4])
    end)

    if PvPDB.Enabled then
        unitFrame.PvPIndicator = PvPIndicator
    else
        unitFrame.PvPIndicator = nil
    end

    return PvPIndicator
end

function UUF:UpdateUnitPvPIndicator(unitFrame, unit)
    local PvPDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.PvPIndicator

    if PvPDB.Enabled then
        unitFrame.PvPIndicator = unitFrame.PvPIndicator or UUF:CreateUnitPvPIndicator(unitFrame, unit)

        if not unitFrame:IsElementEnabled("PvPIndicator") then unitFrame:EnableElement("PvPIndicator") end

        if unitFrame.PvPIndicator then
            UUF:QueueOrRun(function()
                unitFrame.PvPIndicator:ClearAllPoints()
                unitFrame.PvPIndicator:SetSize(PvPDB.Size, PvPDB.Size)
                UUF:SetPointIfChanged(unitFrame.PvPIndicator, PvPDB.Layout[1], unitFrame.HighLevelContainer, PvPDB.Layout[2], PvPDB.Layout[3], PvPDB.Layout[4])
                unitFrame.PvPIndicator:Show()
                unitFrame.PvPIndicator:ForceUpdate()
            end)
        end
    else
        if not unitFrame.PvPIndicator then return end
        if unitFrame:IsElementEnabled("PvPIndicator") then unitFrame:DisableElement("PvPIndicator") end
        if unitFrame.PvPIndicator then
            UUF:QueueOrRun(function() unitFrame.PvPIndicator:Hide() end)
            unitFrame.PvPIndicator = nil
        end
    end
end
