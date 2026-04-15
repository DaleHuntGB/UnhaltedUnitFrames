local _, UUF = ...

-----------------------------------------------------------------------
-- Raid
-----------------------------------------------------------------------

function UUF:CreateRaidReadyCheckIndicator(unitFrame, unit)
    local ReadyCheckDB = UUF.db.profile.Units.raid.Indicators.ReadyCheck
    if not ReadyCheckDB then return end
    if not unitFrame.ReadyCheckIndicatorObject then
        unitFrame.ReadyCheckIndicatorObject = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit).."_ReadyCheckIndicator", "OVERLAY")
    end
    unitFrame.ReadyCheckIndicatorObject:SetSize(ReadyCheckDB.Size, ReadyCheckDB.Size)
    unitFrame.ReadyCheckIndicatorObject:SetPoint(ReadyCheckDB.Layout[1], unitFrame.HighLevelContainer, ReadyCheckDB.Layout[2], ReadyCheckDB.Layout[3], ReadyCheckDB.Layout[4])
    unitFrame.ReadyCheckIndicatorObject.useAtlasSize = false
    unitFrame.ReadyCheckIndicatorObject:Hide()
    if not ReadyCheckDB.Enabled then
        unitFrame.ReadyCheckIndicatorObject:Hide()
        unitFrame.ReadyCheckIndicator = nil
    else
        unitFrame.ReadyCheckIndicator = unitFrame.ReadyCheckIndicatorObject
    end
end

function UUF:UpdateRaidReadyCheckIndicatorSettings(unitFrame, unit)
    local ReadyCheckDB = UUF.db.profile.Units.raid.Indicators.ReadyCheck
    if not unitFrame or not ReadyCheckDB then return end

    if ReadyCheckDB.Enabled then
        if not unitFrame.ReadyCheckIndicatorObject then
            unitFrame.ReadyCheckIndicatorObject = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit).."_ReadyCheckIndicator", "OVERLAY")
        end
        unitFrame.ReadyCheckIndicatorObject:SetSize(ReadyCheckDB.Size, ReadyCheckDB.Size)
        unitFrame.ReadyCheckIndicatorObject:ClearAllPoints()
        unitFrame.ReadyCheckIndicatorObject:SetPoint(ReadyCheckDB.Layout[1], unitFrame.HighLevelContainer, ReadyCheckDB.Layout[2], ReadyCheckDB.Layout[3], ReadyCheckDB.Layout[4])
        unitFrame.ReadyCheckIndicatorObject.useAtlasSize = false
        unitFrame.ReadyCheckIndicator = unitFrame.ReadyCheckIndicatorObject
        if not unitFrame:IsElementEnabled("ReadyCheckIndicator") then unitFrame:EnableElement("ReadyCheckIndicator") end
        if unitFrame.ReadyCheckIndicatorObject.ForceUpdate then unitFrame.ReadyCheckIndicatorObject:ForceUpdate() end
    else
        if unitFrame:IsElementEnabled("ReadyCheckIndicator") then unitFrame:DisableElement("ReadyCheckIndicator") end
        if unitFrame.ReadyCheckIndicatorObject then unitFrame.ReadyCheckIndicatorObject:Hide() end
        unitFrame.ReadyCheckIndicator = nil
    end
end

-----------------------------------------------------------------------
-- Party
-----------------------------------------------------------------------

function UUF:CreateUnitReadyCheckIndicator(unitFrame, unit)
    local ReadyCheckDB = UUF.db.profile.Units.party.Indicators.ReadyCheck
    if not ReadyCheckDB then return end
    if not unitFrame.ReadyCheckIndicatorObject then
        unitFrame.ReadyCheckIndicatorObject = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit).."_ReadyCheckIndicator", "OVERLAY")
    end
    unitFrame.ReadyCheckIndicatorObject:SetSize(ReadyCheckDB.Size, ReadyCheckDB.Size)
    unitFrame.ReadyCheckIndicatorObject:SetPoint(ReadyCheckDB.Layout[1], unitFrame.HighLevelContainer, ReadyCheckDB.Layout[2], ReadyCheckDB.Layout[3], ReadyCheckDB.Layout[4])
    unitFrame.ReadyCheckIndicatorObject.useAtlasSize = false
    unitFrame.ReadyCheckIndicatorObject:Hide()
    if not ReadyCheckDB.Enabled then
        unitFrame.ReadyCheckIndicatorObject:Hide()
        unitFrame.ReadyCheckIndicator = nil
    else
        unitFrame.ReadyCheckIndicator = unitFrame.ReadyCheckIndicatorObject
    end
end

function UUF:UpdateUnitReadyCheckIndicator(unitFrame, unit)
    local ReadyCheckDB = UUF.db.profile.Units.party.Indicators.ReadyCheck
    if not unitFrame or not ReadyCheckDB then return end

    if ReadyCheckDB.Enabled then
        if not unitFrame.ReadyCheckIndicatorObject then
            unitFrame.ReadyCheckIndicatorObject = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit).."_ReadyCheckIndicator", "OVERLAY")
        end
        unitFrame.ReadyCheckIndicatorObject:SetSize(ReadyCheckDB.Size, ReadyCheckDB.Size)
        unitFrame.ReadyCheckIndicatorObject:ClearAllPoints()
        unitFrame.ReadyCheckIndicatorObject:SetPoint(ReadyCheckDB.Layout[1], unitFrame.HighLevelContainer, ReadyCheckDB.Layout[2], ReadyCheckDB.Layout[3], ReadyCheckDB.Layout[4])
        unitFrame.ReadyCheckIndicatorObject.useAtlasSize = false
        unitFrame.ReadyCheckIndicator = unitFrame.ReadyCheckIndicatorObject
        if not unitFrame:IsElementEnabled("ReadyCheckIndicator") then unitFrame:EnableElement("ReadyCheckIndicator") end
        if unitFrame.ReadyCheckIndicatorObject.ForceUpdate then unitFrame.ReadyCheckIndicatorObject:ForceUpdate() end
    else
        if unitFrame:IsElementEnabled("ReadyCheckIndicator") then unitFrame:DisableElement("ReadyCheckIndicator") end
        if unitFrame.ReadyCheckIndicatorObject then unitFrame.ReadyCheckIndicatorObject:Hide() end
        unitFrame.ReadyCheckIndicator = nil
    end
end
