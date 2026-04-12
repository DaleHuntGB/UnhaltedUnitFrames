local _, UUF = ...

-----------------------------------------------------------------------
-- Raid
-----------------------------------------------------------------------

function UUF:CreateRaidSummonIndicator(unitFrame, unit)
    local SummonDB = UUF.db.profile.Units.raid.Indicators.Summon
    if not SummonDB then return end
    unitFrame.SummonIndicator = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit).."_SummonIndicator", "OVERLAY")
    unitFrame.SummonIndicator:SetSize(SummonDB.Size, SummonDB.Size)
    unitFrame.SummonIndicator:SetPoint(SummonDB.Layout[1], unitFrame.HighLevelContainer, SummonDB.Layout[2], SummonDB.Layout[3], SummonDB.Layout[4])
    unitFrame.SummonIndicator:Hide()
    unitFrame.SummonIndicator.Override = function(self, event, unit)
        local DB = UUF.db.profile.Units.raid.Indicators.Summon
        if not DB or not DB.Enabled then
            self.SummonIndicator:Hide()
            return
        end
        if C_IncomingSummon.HasIncomingSummon(self.unit) then
            self.SummonIndicator:Show()
        else
            self.SummonIndicator:Hide()
        end
    end
end

function UUF:UpdateRaidSummonIndicatorSettings(unitFrame, unit)
    local SummonDB = UUF.db.profile.Units.raid.Indicators.Summon
    if not unitFrame or not unitFrame.SummonIndicator or not SummonDB then return end
    unitFrame.SummonIndicator:SetSize(SummonDB.Size, SummonDB.Size)
    unitFrame.SummonIndicator:ClearAllPoints()
    unitFrame.SummonIndicator:SetPoint(SummonDB.Layout[1], unitFrame.HighLevelContainer, SummonDB.Layout[2], SummonDB.Layout[3], SummonDB.Layout[4])
    if not SummonDB.Enabled then
        unitFrame.SummonIndicator:Hide()
    else
        unitFrame.SummonIndicator:ForceUpdate()
    end
end

-----------------------------------------------------------------------
-- Party
-----------------------------------------------------------------------

function UUF:CreateUnitSummonIndicator(unitFrame, unit)
    local SummonDB = UUF.db.profile.Units.party.Indicators.Summon
    if not SummonDB then return end
    unitFrame.SummonIndicator = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit).."_SummonIndicator", "OVERLAY")
    unitFrame.SummonIndicator:SetSize(SummonDB.Size, SummonDB.Size)
    unitFrame.SummonIndicator:SetPoint(SummonDB.Layout[1], unitFrame.HighLevelContainer, SummonDB.Layout[2], SummonDB.Layout[3], SummonDB.Layout[4])
    unitFrame.SummonIndicator:Hide()
    unitFrame.SummonIndicator.Override = function(self, event, unit)
        local DB = UUF.db.profile.Units.party.Indicators.Summon
        if not DB or not DB.Enabled then
            self.SummonIndicator:Hide()
            return
        end
        if C_IncomingSummon.HasIncomingSummon(self.unit) then
            self.SummonIndicator:Show()
        else
            self.SummonIndicator:Hide()
        end
    end
end

function UUF:UpdateUnitSummonIndicator(unitFrame, unit)
    local SummonDB = UUF.db.profile.Units.party.Indicators.Summon
    if not unitFrame or not unitFrame.SummonIndicator or not SummonDB then return end
    unitFrame.SummonIndicator:SetSize(SummonDB.Size, SummonDB.Size)
    unitFrame.SummonIndicator:ClearAllPoints()
    unitFrame.SummonIndicator:SetPoint(SummonDB.Layout[1], unitFrame.HighLevelContainer, SummonDB.Layout[2], SummonDB.Layout[3], SummonDB.Layout[4])
    if not SummonDB.Enabled then
        unitFrame.SummonIndicator:Hide()
    else
        unitFrame.SummonIndicator:ForceUpdate()
    end
end
