local _, UUF = ...

local raidPhaseEvtFrame = CreateFrame("Frame")
raidPhaseEvtFrame:RegisterEvent("UNIT_PHASE")
raidPhaseEvtFrame:SetScript("OnEvent", function(_, _, unit)
    if not unit then return end
    local unitIndex = unit:match("^raid(%d+)$")
    if not unitIndex then return end
    local raidFrame = UUF["RAID"..unitIndex]
    if raidFrame and UUF.db.profile.Units.raid.Indicators.Phase.Enabled then
        UUF:UpdateRaidPhaseIndicator(raidFrame, unit)
    end
end)

function UUF:CreateRaidPhaseIndicator(unitFrame, unit)
    local PhaseDB = UUF.db.profile.Units.raid.Indicators.Phase
    if not PhaseDB then return end
    unitFrame.PhaseIndicator = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit).."_PhaseIndicator", "OVERLAY")
    unitFrame.PhaseIndicator:SetSize(PhaseDB.Size, PhaseDB.Size)
    unitFrame.PhaseIndicator:SetAtlas("questtracker-eye", true)
    unitFrame.PhaseIndicator:SetPoint(PhaseDB.Layout[1], unitFrame.HighLevelContainer, PhaseDB.Layout[2], PhaseDB.Layout[3], PhaseDB.Layout[4])
    unitFrame.PhaseIndicator:Hide()
end

function UUF:UpdateRaidPhaseIndicatorSettings(unitFrame, unit)
    local PhaseDB = UUF.db.profile.Units.raid.Indicators.Phase
    if not unitFrame or not unitFrame.PhaseIndicator or not PhaseDB then return end
    unitFrame.PhaseIndicator:SetSize(PhaseDB.Size, PhaseDB.Size)
    unitFrame.PhaseIndicator:ClearAllPoints()
    unitFrame.PhaseIndicator:SetPoint(PhaseDB.Layout[1], unitFrame.HighLevelContainer, PhaseDB.Layout[2], PhaseDB.Layout[3], PhaseDB.Layout[4])
    UUF:UpdateRaidPhaseIndicator(unitFrame, unit)
end

function UUF:UpdateRaidPhaseIndicator(unitFrame, unit)
    local PhaseDB = UUF.db.profile.Units.raid.Indicators.Phase
    if not unitFrame or not unitFrame.PhaseIndicator or not PhaseDB then return end
    if not PhaseDB.Enabled then
        unitFrame.PhaseIndicator:Hide()
        return
    end
    if UnitIsConnected(unit) and not UnitIsVisible(unit) then
        unitFrame.PhaseIndicator:Show()
    else
        unitFrame.PhaseIndicator:Hide()
    end
end

-----------------------------------------------------------------------
-- Party
-----------------------------------------------------------------------

local phaseEvtFrame = CreateFrame("Frame")
phaseEvtFrame:RegisterEvent("UNIT_PHASE")
phaseEvtFrame:SetScript("OnEvent", function(_, _, unit)
    if not unit then return end
    local unitIndex = unit:match("^party(%d+)$")
    if not unitIndex then return end
    local partyFrame = UUF["PARTY"..unitIndex]
    if partyFrame and UUF.db.profile.Units.party.Indicators.Phase.Enabled then
        UUF:UpdatePartyPhaseIndicator(partyFrame, unit)
    end
end)

function UUF:CreateUnitPhaseIndicator(unitFrame, unit)
    local PhaseDB = UUF.db.profile.Units.party.Indicators.Phase
    if not PhaseDB then return end
    unitFrame.PhaseIndicator = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit).."_PhaseIndicator", "OVERLAY")
    unitFrame.PhaseIndicator:SetSize(PhaseDB.Size, PhaseDB.Size)
    unitFrame.PhaseIndicator:SetAtlas("questtracker-eye", true)
    unitFrame.PhaseIndicator:SetPoint(PhaseDB.Layout[1], unitFrame.HighLevelContainer, PhaseDB.Layout[2], PhaseDB.Layout[3], PhaseDB.Layout[4])
    unitFrame.PhaseIndicator:Hide()
end

function UUF:UpdateUnitPhaseIndicator(unitFrame, unit)
    local PhaseDB = UUF.db.profile.Units.party.Indicators.Phase
    if not unitFrame or not unitFrame.PhaseIndicator or not PhaseDB then return end
    unitFrame.PhaseIndicator:SetSize(PhaseDB.Size, PhaseDB.Size)
    unitFrame.PhaseIndicator:ClearAllPoints()
    unitFrame.PhaseIndicator:SetPoint(PhaseDB.Layout[1], unitFrame.HighLevelContainer, PhaseDB.Layout[2], PhaseDB.Layout[3], PhaseDB.Layout[4])
    UUF:UpdatePartyPhaseIndicator(unitFrame, unit)
end

function UUF:UpdatePartyPhaseIndicator(unitFrame, unit)
    local PhaseDB = UUF.db.profile.Units.party.Indicators.Phase
    if not unitFrame or not unitFrame.PhaseIndicator or not PhaseDB then return end
    if not PhaseDB.Enabled then
        unitFrame.PhaseIndicator:Hide()
        return
    end
    if UnitIsConnected(unit) and not UnitIsVisible(unit) then
        unitFrame.PhaseIndicator:Show()
    else
        unitFrame.PhaseIndicator:Hide()
    end
end
