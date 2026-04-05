local _, UUF = ...

function UUF:CreateUnitSummonIndicator(unitFrame, unit)
    local SummonDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Summon
    if not SummonDB then return end
    if unitFrame.__UUFSummonIndicator then return unitFrame.__UUFSummonIndicator end

    local SummonIndicator = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit) .. "_SummonIndicator", "OVERLAY")
    SummonIndicator:SetSize(SummonDB.Size, SummonDB.Size)
    SummonIndicator:SetPoint(SummonDB.Layout[1], unitFrame.HighLevelContainer, SummonDB.Layout[2], SummonDB.Layout[3], SummonDB.Layout[4])
    SummonIndicator.useAtlasSize = false
    SummonIndicator:Hide()
    unitFrame.__UUFSummonIndicator = SummonIndicator

    if SummonDB.Enabled then
        unitFrame.SummonIndicator = SummonIndicator
    else
        if unitFrame:IsElementEnabled("SummonIndicator") then
            unitFrame:DisableElement("SummonIndicator")
        end
        SummonIndicator:Hide()
    end

    return SummonIndicator
end

function UUF:UpdateUnitSummonIndicator(unitFrame, unit)
    local SummonDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Summon
    if not SummonDB then return end

    if SummonDB.Enabled then
        unitFrame.SummonIndicator = unitFrame.SummonIndicator or unitFrame.__UUFSummonIndicator or UUF:CreateUnitSummonIndicator(unitFrame, unit)

        if not unitFrame:IsElementEnabled("SummonIndicator") then
            unitFrame:EnableElement("SummonIndicator")
        end

        if unitFrame.SummonIndicator then
            unitFrame.SummonIndicator:ClearAllPoints()
            unitFrame.SummonIndicator:SetSize(SummonDB.Size, SummonDB.Size)
            unitFrame.SummonIndicator:SetPoint(SummonDB.Layout[1], unitFrame.HighLevelContainer, SummonDB.Layout[2], SummonDB.Layout[3], SummonDB.Layout[4])
            unitFrame.SummonIndicator.useAtlasSize = false
            unitFrame.SummonIndicator:ForceUpdate()
        end
    else
        if not unitFrame.SummonIndicator then return end
        if unitFrame:IsElementEnabled("SummonIndicator") then
            unitFrame:DisableElement("SummonIndicator")
        end
        unitFrame.SummonIndicator:Hide()
        unitFrame.SummonIndicator = nil
    end
end
