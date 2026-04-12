local _, UUF = ...

-----------------------------------------------------------------------
-- Raid
-----------------------------------------------------------------------

function UUF:CreateRaidResurrectIndicator(unitFrame, unit)
    local ResurrectDB = UUF.db.profile.Units.raid.Indicators.Resurrection
    if not ResurrectDB then return end
    unitFrame.ResurrectIndicator = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit).."_ResurrectIndicator", "OVERLAY")
    unitFrame.ResurrectIndicator:SetSize(ResurrectDB.Size, ResurrectDB.Size)
    unitFrame.ResurrectIndicator:SetPoint(ResurrectDB.Layout[1], unitFrame.HighLevelContainer, ResurrectDB.Layout[2], ResurrectDB.Layout[3], ResurrectDB.Layout[4])
    unitFrame.ResurrectIndicator:Hide()
    unitFrame.ResurrectIndicator.Override = function(self, event, unit)
        if self.unit ~= unit then return end
        local DB = UUF.db.profile.Units.raid.Indicators.Resurrection
        if not DB or not DB.Enabled then
            self.ResurrectIndicator:Hide()
            return
        end
        if UnitHasIncomingResurrection(unit) then
            self.ResurrectIndicator:Show()
        else
            self.ResurrectIndicator:Hide()
        end
    end
end

function UUF:UpdateRaidResurrectIndicatorSettings(unitFrame, unit)
    local ResurrectDB = UUF.db.profile.Units.raid.Indicators.Resurrection
    if not unitFrame or not unitFrame.ResurrectIndicator or not ResurrectDB then return end
    unitFrame.ResurrectIndicator:SetSize(ResurrectDB.Size, ResurrectDB.Size)
    unitFrame.ResurrectIndicator:ClearAllPoints()
    unitFrame.ResurrectIndicator:SetPoint(ResurrectDB.Layout[1], unitFrame.HighLevelContainer, ResurrectDB.Layout[2], ResurrectDB.Layout[3], ResurrectDB.Layout[4])
    if not ResurrectDB.Enabled then
        unitFrame.ResurrectIndicator:Hide()
    else
        unitFrame.ResurrectIndicator:ForceUpdate()
    end
end

-----------------------------------------------------------------------
-- Party
-----------------------------------------------------------------------

function UUF:CreateUnitResurrectIndicator(unitFrame, unit)
    local ResurrectDB = UUF.db.profile.Units.party.Indicators.Resurrection
    if not ResurrectDB then return end
    unitFrame.ResurrectIndicator = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit).."_ResurrectIndicator", "OVERLAY")
    unitFrame.ResurrectIndicator:SetSize(ResurrectDB.Size, ResurrectDB.Size)
    unitFrame.ResurrectIndicator:SetPoint(ResurrectDB.Layout[1], unitFrame.HighLevelContainer, ResurrectDB.Layout[2], ResurrectDB.Layout[3], ResurrectDB.Layout[4])
    unitFrame.ResurrectIndicator:Hide()
    unitFrame.ResurrectIndicator.Override = function(self, event, unit)
        if self.unit ~= unit then return end
        local DB = UUF.db.profile.Units.party.Indicators.Resurrection
        if not DB or not DB.Enabled then
            self.ResurrectIndicator:Hide()
            return
        end
        if UnitHasIncomingResurrection(unit) then
            self.ResurrectIndicator:Show()
        else
            self.ResurrectIndicator:Hide()
        end
    end
end

function UUF:UpdateUnitResurrectIndicator(unitFrame, unit)
    local ResurrectDB = UUF.db.profile.Units.party.Indicators.Resurrection
    if not unitFrame or not unitFrame.ResurrectIndicator or not ResurrectDB then return end
    unitFrame.ResurrectIndicator:SetSize(ResurrectDB.Size, ResurrectDB.Size)
    unitFrame.ResurrectIndicator:ClearAllPoints()
    unitFrame.ResurrectIndicator:SetPoint(ResurrectDB.Layout[1], unitFrame.HighLevelContainer, ResurrectDB.Layout[2], ResurrectDB.Layout[3], ResurrectDB.Layout[4])
    if not ResurrectDB.Enabled then
        unitFrame.ResurrectIndicator:Hide()
    else
        unitFrame.ResurrectIndicator:ForceUpdate()
    end
end
