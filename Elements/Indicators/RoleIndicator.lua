local _, UUF = ...

-----------------------------------------------------------------------
-- Raid
-----------------------------------------------------------------------

function UUF:CreateRaidRoleIndicator(unitFrame, unit)
    local RoleDB = UUF.db.profile.Units.raid.Indicators.Role
    if not RoleDB then return end
    unitFrame.GroupRoleIndicator = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit).."_RoleIndicator", "OVERLAY")
    unitFrame.GroupRoleIndicator:SetSize(RoleDB.Size, RoleDB.Size)
    unitFrame.GroupRoleIndicator:SetPoint(RoleDB.Layout[1], unitFrame.HighLevelContainer, RoleDB.Layout[2], RoleDB.Layout[3], RoleDB.Layout[4])
    unitFrame.GroupRoleIndicator:Hide()
    unitFrame.GroupRoleIndicator.Override = function(self, event, unit)
        local DB = UUF.db.profile.Units.raid.Indicators.Role
        if not DB or not DB.Enabled then
            self.GroupRoleIndicator:Hide()
            return
        end
        local role = UnitGroupRolesAssigned(self.unit)
        if role == "TANK" then
            self.GroupRoleIndicator:SetAtlas("roleIcon-tank", true)
            self.GroupRoleIndicator:Show()
        elseif role == "HEALER" then
            self.GroupRoleIndicator:SetAtlas("roleIcon-healer", true)
            self.GroupRoleIndicator:Show()
        elseif role == "DAMAGER" then
            self.GroupRoleIndicator:SetAtlas("roleIcon-dps", true)
            self.GroupRoleIndicator:Show()
        else
            self.GroupRoleIndicator:Hide()
        end
    end
end

function UUF:UpdateRaidRoleIndicatorSettings(unitFrame, unit)
    local RoleDB = UUF.db.profile.Units.raid.Indicators.Role
    if not unitFrame or not unitFrame.GroupRoleIndicator or not RoleDB then return end
    unitFrame.GroupRoleIndicator:SetSize(RoleDB.Size, RoleDB.Size)
    unitFrame.GroupRoleIndicator:ClearAllPoints()
    unitFrame.GroupRoleIndicator:SetPoint(RoleDB.Layout[1], unitFrame.HighLevelContainer, RoleDB.Layout[2], RoleDB.Layout[3], RoleDB.Layout[4])
    if not RoleDB.Enabled then
        unitFrame.GroupRoleIndicator:Hide()
    else
        unitFrame.GroupRoleIndicator:ForceUpdate()
    end
end

-----------------------------------------------------------------------
-- Party
-----------------------------------------------------------------------

function UUF:CreateUnitRoleIndicator(unitFrame, unit)
    local RoleDB = UUF.db.profile.Units.party.Indicators.Role
    if not RoleDB then return end
    unitFrame.GroupRoleIndicator = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit).."_RoleIndicator", "OVERLAY")
    unitFrame.GroupRoleIndicator:SetSize(RoleDB.Size, RoleDB.Size)
    unitFrame.GroupRoleIndicator:SetPoint(RoleDB.Layout[1], unitFrame.HighLevelContainer, RoleDB.Layout[2], RoleDB.Layout[3], RoleDB.Layout[4])
    unitFrame.GroupRoleIndicator:Hide()
    unitFrame.GroupRoleIndicator.Override = function(self, event, unit)
        local DB = UUF.db.profile.Units.party.Indicators.Role
        if not DB or not DB.Enabled then
            self.GroupRoleIndicator:Hide()
            return
        end
        local role = UnitGroupRolesAssigned(self.unit)
        if role == "TANK" then
            self.GroupRoleIndicator:SetAtlas("roleIcon-tank", true)
            self.GroupRoleIndicator:Show()
        elseif role == "HEALER" then
            self.GroupRoleIndicator:SetAtlas("roleIcon-healer", true)
            self.GroupRoleIndicator:Show()
        elseif role == "DAMAGER" then
            self.GroupRoleIndicator:SetAtlas("roleIcon-dps", true)
            self.GroupRoleIndicator:Show()
        else
            self.GroupRoleIndicator:Hide()
        end
    end
end

function UUF:UpdateUnitRoleIndicator(unitFrame, unit)
    local RoleDB = UUF.db.profile.Units.party.Indicators.Role
    if not unitFrame or not unitFrame.GroupRoleIndicator or not RoleDB then return end
    unitFrame.GroupRoleIndicator:SetSize(RoleDB.Size, RoleDB.Size)
    unitFrame.GroupRoleIndicator:ClearAllPoints()
    unitFrame.GroupRoleIndicator:SetPoint(RoleDB.Layout[1], unitFrame.HighLevelContainer, RoleDB.Layout[2], RoleDB.Layout[3], RoleDB.Layout[4])
    if not RoleDB.Enabled then
        unitFrame.GroupRoleIndicator:Hide()
    else
        unitFrame.GroupRoleIndicator:ForceUpdate()
    end
end
