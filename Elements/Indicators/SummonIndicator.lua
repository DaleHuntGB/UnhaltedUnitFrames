local _, UUF = ...

local raidSummonEvtFrame = CreateFrame("Frame")
raidSummonEvtFrame:RegisterEvent("INCOMING_SUMMON_CHANGED")
raidSummonEvtFrame:SetScript("OnEvent", function()
    for i = 1, UUF.MAX_RAID_MEMBERS do
        local raidFrame = UUF["RAID"..i]
        if raidFrame and UUF.db.profile.Units.raid.Indicators.Summon.Enabled then
            UUF:UpdateRaidSummonIndicator(raidFrame, "raid"..i)
        end
    end
end)

function UUF:CreateRaidSummonIndicator(unitFrame, unit)
    local SummonDB = UUF.db.profile.Units.raid.Indicators.Summon
    if not SummonDB then return end
    unitFrame.SummonIndicator = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit).."_SummonIndicator", "OVERLAY")
    unitFrame.SummonIndicator:SetSize(SummonDB.Size, SummonDB.Size)
    unitFrame.SummonIndicator:SetAtlas("Summon_Arrow", true)
    unitFrame.SummonIndicator:SetPoint(SummonDB.Layout[1], unitFrame.HighLevelContainer, SummonDB.Layout[2], SummonDB.Layout[3], SummonDB.Layout[4])
    unitFrame.SummonIndicator:Hide()
end

function UUF:UpdateRaidSummonIndicatorSettings(unitFrame, unit)
    local SummonDB = UUF.db.profile.Units.raid.Indicators.Summon
    if not unitFrame or not unitFrame.SummonIndicator or not SummonDB then return end
    unitFrame.SummonIndicator:SetSize(SummonDB.Size, SummonDB.Size)
    unitFrame.SummonIndicator:ClearAllPoints()
    unitFrame.SummonIndicator:SetPoint(SummonDB.Layout[1], unitFrame.HighLevelContainer, SummonDB.Layout[2], SummonDB.Layout[3], SummonDB.Layout[4])
    UUF:UpdateRaidSummonIndicator(unitFrame, unit)
end

function UUF:UpdateRaidSummonIndicator(unitFrame, unit)
    local SummonDB = UUF.db.profile.Units.raid.Indicators.Summon
    if not unitFrame or not unitFrame.SummonIndicator or not SummonDB then return end
    if not SummonDB.Enabled then
        unitFrame.SummonIndicator:Hide()
        return
    end
    if C_IncomingSummon.HasIncomingSummon(unit) then
        unitFrame.SummonIndicator:Show()
    else
        unitFrame.SummonIndicator:Hide()
    end
end

-----------------------------------------------------------------------
-- Party
-----------------------------------------------------------------------

local summonEvtFrame = CreateFrame("Frame")
summonEvtFrame:RegisterEvent("INCOMING_SUMMON_CHANGED")
summonEvtFrame:SetScript("OnEvent", function()
    for i = 1, UUF.MAX_PARTY_MEMBERS do
        local partyFrame = UUF["PARTY"..i]
        if partyFrame and UUF.db.profile.Units.party.Indicators.Summon.Enabled then
            UUF:UpdatePartySummonIndicator(partyFrame, "party"..i)
        end
    end
end)

function UUF:CreateUnitSummonIndicator(unitFrame, unit)
    local SummonDB = UUF.db.profile.Units.party.Indicators.Summon
    if not SummonDB then return end
    unitFrame.SummonIndicator = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit).."_SummonIndicator", "OVERLAY")
    unitFrame.SummonIndicator:SetSize(SummonDB.Size, SummonDB.Size)
    unitFrame.SummonIndicator:SetAtlas("Summon_Arrow", true)
    unitFrame.SummonIndicator:SetPoint(SummonDB.Layout[1], unitFrame.HighLevelContainer, SummonDB.Layout[2], SummonDB.Layout[3], SummonDB.Layout[4])
    unitFrame.SummonIndicator:Hide()
end

function UUF:UpdateUnitSummonIndicator(unitFrame, unit)
    local SummonDB = UUF.db.profile.Units.party.Indicators.Summon
    if not unitFrame or not unitFrame.SummonIndicator or not SummonDB then return end
    unitFrame.SummonIndicator:SetSize(SummonDB.Size, SummonDB.Size)
    unitFrame.SummonIndicator:ClearAllPoints()
    unitFrame.SummonIndicator:SetPoint(SummonDB.Layout[1], unitFrame.HighLevelContainer, SummonDB.Layout[2], SummonDB.Layout[3], SummonDB.Layout[4])
    UUF:UpdatePartySummonIndicator(unitFrame, unit)
end

function UUF:UpdatePartySummonIndicator(unitFrame, unit)
    local SummonDB = UUF.db.profile.Units.party.Indicators.Summon
    if not unitFrame or not unitFrame.SummonIndicator or not SummonDB then return end
    if not SummonDB.Enabled then
        unitFrame.SummonIndicator:Hide()
        return
    end
    if C_IncomingSummon.HasIncomingSummon(unit) then
        unitFrame.SummonIndicator:Show()
    else
        unitFrame.SummonIndicator:Hide()
    end
end
