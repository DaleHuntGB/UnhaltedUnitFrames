local _, UUF = ...

-----------------------------------------------------------------------
-- Raid
-----------------------------------------------------------------------

function UUF:CreateRaidSummonIndicator(unitFrame, unit)
    local SummonDB = UUF.db.profile.Units.raid.Indicators.Summon
    if not SummonDB then return end
    if not unitFrame.SummonIndicatorObject then
        unitFrame.SummonIndicatorObject = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit).."_SummonIndicator", "OVERLAY")
    end
    unitFrame.SummonIndicatorObject:SetSize(SummonDB.Size, SummonDB.Size)
    unitFrame.SummonIndicatorObject:SetPoint(SummonDB.Layout[1], unitFrame.HighLevelContainer, SummonDB.Layout[2], SummonDB.Layout[3], SummonDB.Layout[4])
    unitFrame.SummonIndicatorObject.useAtlasSize = SummonDB.UseAtlasSize
    unitFrame.SummonIndicatorObject:Hide()
    if not SummonDB.Enabled then
        unitFrame.SummonIndicatorObject:Hide()
        unitFrame.SummonIndicator = nil
    else
        unitFrame.SummonIndicator = unitFrame.SummonIndicatorObject
    end
end

function UUF:UpdateRaidSummonIndicatorSettings(unitFrame, unit)
    local SummonDB = UUF.db.profile.Units.raid.Indicators.Summon
    if not unitFrame or not SummonDB then return end

    if SummonDB.Enabled then
        if not unitFrame.SummonIndicatorObject then
            unitFrame.SummonIndicatorObject = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit).."_SummonIndicator", "OVERLAY")
        end
        unitFrame.SummonIndicatorObject:SetSize(SummonDB.Size, SummonDB.Size)
        unitFrame.SummonIndicatorObject:ClearAllPoints()
        unitFrame.SummonIndicatorObject:SetPoint(SummonDB.Layout[1], unitFrame.HighLevelContainer, SummonDB.Layout[2], SummonDB.Layout[3], SummonDB.Layout[4])
        unitFrame.SummonIndicatorObject.useAtlasSize = SummonDB.UseAtlasSize
        unitFrame.SummonIndicator = unitFrame.SummonIndicatorObject
        if not unitFrame:IsElementEnabled("SummonIndicator") then unitFrame:EnableElement("SummonIndicator") end
        if unitFrame.SummonIndicatorObject.ForceUpdate then unitFrame.SummonIndicatorObject:ForceUpdate() end
    else
        if unitFrame:IsElementEnabled("SummonIndicator") then unitFrame:DisableElement("SummonIndicator") end
        if unitFrame.SummonIndicatorObject then unitFrame.SummonIndicatorObject:Hide() end
        unitFrame.SummonIndicator = nil
    end
end

-----------------------------------------------------------------------
-- Party
-----------------------------------------------------------------------

function UUF:CreateUnitSummonIndicator(unitFrame, unit)
    local SummonDB = UUF.db.profile.Units.party.Indicators.Summon
    if not SummonDB then return end
    if not unitFrame.SummonIndicatorObject then
        unitFrame.SummonIndicatorObject = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit).."_SummonIndicator", "OVERLAY")
    end
    unitFrame.SummonIndicatorObject:SetSize(SummonDB.Size, SummonDB.Size)
    unitFrame.SummonIndicatorObject:SetPoint(SummonDB.Layout[1], unitFrame.HighLevelContainer, SummonDB.Layout[2], SummonDB.Layout[3], SummonDB.Layout[4])
    unitFrame.SummonIndicatorObject.useAtlasSize = SummonDB.UseAtlasSize
    unitFrame.SummonIndicatorObject:Hide()
    if not SummonDB.Enabled then
        unitFrame.SummonIndicatorObject:Hide()
        unitFrame.SummonIndicator = nil
    else
        unitFrame.SummonIndicator = unitFrame.SummonIndicatorObject
    end
end

function UUF:UpdateUnitSummonIndicator(unitFrame, unit)
    local SummonDB = UUF.db.profile.Units.party.Indicators.Summon
    if not unitFrame or not SummonDB then return end

    if SummonDB.Enabled then
        if not unitFrame.SummonIndicatorObject then
            unitFrame.SummonIndicatorObject = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit).."_SummonIndicator", "OVERLAY")
        end
        unitFrame.SummonIndicatorObject:SetSize(SummonDB.Size, SummonDB.Size)
        unitFrame.SummonIndicatorObject:ClearAllPoints()
        unitFrame.SummonIndicatorObject:SetPoint(SummonDB.Layout[1], unitFrame.HighLevelContainer, SummonDB.Layout[2], SummonDB.Layout[3], SummonDB.Layout[4])
        unitFrame.SummonIndicatorObject.useAtlasSize = SummonDB.UseAtlasSize
        unitFrame.SummonIndicator = unitFrame.SummonIndicatorObject
        if not unitFrame:IsElementEnabled("SummonIndicator") then unitFrame:EnableElement("SummonIndicator") end
        if unitFrame.SummonIndicatorObject.ForceUpdate then unitFrame.SummonIndicatorObject:ForceUpdate() end
    else
        if unitFrame:IsElementEnabled("SummonIndicator") then unitFrame:DisableElement("SummonIndicator") end
        if unitFrame.SummonIndicatorObject then unitFrame.SummonIndicatorObject:Hide() end
        unitFrame.SummonIndicator = nil
    end
end
