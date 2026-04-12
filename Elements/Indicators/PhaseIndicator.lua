local _, UUF = ...

-----------------------------------------------------------------------
-- Raid
-----------------------------------------------------------------------

function UUF:CreateRaidPhaseIndicator(unitFrame, unit)
    local PhaseDB = UUF.db.profile.Units.raid.Indicators.Phase
    if not PhaseDB then return end
    unitFrame.PhaseIndicator = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit).."_PhaseIndicator", "OVERLAY")
    unitFrame.PhaseIndicator:SetSize(PhaseDB.Size, PhaseDB.Size)
    unitFrame.PhaseIndicator:SetPoint(PhaseDB.Layout[1], unitFrame.HighLevelContainer, PhaseDB.Layout[2], PhaseDB.Layout[3], PhaseDB.Layout[4])
    unitFrame.PhaseIndicator:Hide()
    unitFrame.PhaseIndicator.Override = function(self, event, unit)
        if self.unit ~= unit then return end
        local DB = UUF.db.profile.Units.raid.Indicators.Phase
        if not DB or not DB.Enabled then
            self.PhaseIndicator:Hide()
            return
        end
        if UnitIsConnected(unit) and not UnitIsVisible(unit) then
            self.PhaseIndicator:Show()
        else
            self.PhaseIndicator:Hide()
        end
    end
end

function UUF:UpdateRaidPhaseIndicatorSettings(unitFrame, unit)
    local PhaseDB = UUF.db.profile.Units.raid.Indicators.Phase
    if not unitFrame or not unitFrame.PhaseIndicator or not PhaseDB then return end
    unitFrame.PhaseIndicator:SetSize(PhaseDB.Size, PhaseDB.Size)
    unitFrame.PhaseIndicator:ClearAllPoints()
    unitFrame.PhaseIndicator:SetPoint(PhaseDB.Layout[1], unitFrame.HighLevelContainer, PhaseDB.Layout[2], PhaseDB.Layout[3], PhaseDB.Layout[4])
    if not PhaseDB.Enabled then
        unitFrame.PhaseIndicator:Hide()
    else
        unitFrame.PhaseIndicator:ForceUpdate()
    end
end

-----------------------------------------------------------------------
-- Party
-----------------------------------------------------------------------

function UUF:CreateUnitPhaseIndicator(unitFrame, unit)
    local PhaseDB = UUF.db.profile.Units.party.Indicators.Phase
    if not PhaseDB then return end
    unitFrame.PhaseIndicator = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit).."_PhaseIndicator", "OVERLAY")
    unitFrame.PhaseIndicator:SetSize(PhaseDB.Size, PhaseDB.Size)
    unitFrame.PhaseIndicator:SetPoint(PhaseDB.Layout[1], unitFrame.HighLevelContainer, PhaseDB.Layout[2], PhaseDB.Layout[3], PhaseDB.Layout[4])
    unitFrame.PhaseIndicator:Hide()
    unitFrame.PhaseIndicator.Override = function(self, event, unit)
        if self.unit ~= unit then return end
        local DB = UUF.db.profile.Units.party.Indicators.Phase
        if not DB or not DB.Enabled then
            self.PhaseIndicator:Hide()
            return
        end
        if UnitIsConnected(unit) and not UnitIsVisible(unit) then
            self.PhaseIndicator:Show()
        else
            self.PhaseIndicator:Hide()
        end
    end
end

function UUF:UpdateUnitPhaseIndicator(unitFrame, unit)
    local PhaseDB = UUF.db.profile.Units.party.Indicators.Phase
    if not unitFrame or not unitFrame.PhaseIndicator or not PhaseDB then return end
    unitFrame.PhaseIndicator:SetSize(PhaseDB.Size, PhaseDB.Size)
    unitFrame.PhaseIndicator:ClearAllPoints()
    unitFrame.PhaseIndicator:SetPoint(PhaseDB.Layout[1], unitFrame.HighLevelContainer, PhaseDB.Layout[2], PhaseDB.Layout[3], PhaseDB.Layout[4])
    if not PhaseDB.Enabled then
        unitFrame.PhaseIndicator:Hide()
    else
        unitFrame.PhaseIndicator:ForceUpdate()
    end
end
