local _, UUF = ...

local raidRoleEvtFrame = CreateFrame("Frame")
raidRoleEvtFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
raidRoleEvtFrame:RegisterEvent("ROLE_CHANGED_INFORM")
raidRoleEvtFrame:RegisterEvent("PLAYER_ROLES_ASSIGNED")
raidRoleEvtFrame:SetScript("OnEvent", function()
    for i = 1, UUF.MAX_RAID_MEMBERS do
        local raidFrame = UUF["RAID"..i]
        if raidFrame and UUF.db.profile.Units.raid.Indicators.Role.Enabled then
            UUF:UpdateRaidRoleIndicator(raidFrame, "raid"..i)
        end
    end
end)

function UUF:CreateRaidRoleIndicator(unitFrame, unit)
    local RoleDB = UUF.db.profile.Units.raid.Indicators.Role
    if not RoleDB then return end
    unitFrame.RoleIndicator = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit).."_RoleIndicator", "OVERLAY")
    unitFrame.RoleIndicator:SetSize(RoleDB.Size, RoleDB.Size)
    unitFrame.RoleIndicator:SetPoint(RoleDB.Layout[1], unitFrame.HighLevelContainer, RoleDB.Layout[2], RoleDB.Layout[3], RoleDB.Layout[4])
    unitFrame.RoleIndicator:Hide()
end

function UUF:UpdateRaidRoleIndicatorSettings(unitFrame, unit)
    local RoleDB = UUF.db.profile.Units.raid.Indicators.Role
    if not unitFrame or not unitFrame.RoleIndicator or not RoleDB then return end
    unitFrame.RoleIndicator:SetSize(RoleDB.Size, RoleDB.Size)
    unitFrame.RoleIndicator:ClearAllPoints()
    unitFrame.RoleIndicator:SetPoint(RoleDB.Layout[1], unitFrame.HighLevelContainer, RoleDB.Layout[2], RoleDB.Layout[3], RoleDB.Layout[4])
    UUF:UpdateRaidRoleIndicator(unitFrame, unit)
end

function UUF:UpdateRaidRoleIndicator(unitFrame, unit)
    local RoleDB = UUF.db.profile.Units.raid.Indicators.Role
    if not unitFrame or not unitFrame.RoleIndicator or not RoleDB then return end
    if not RoleDB.Enabled then
        unitFrame.RoleIndicator:Hide()
        return
    end
    local role = UnitGroupRolesAssigned(unit)
    if role == "TANK" then
        unitFrame.RoleIndicator:SetAtlas("roleIcon-tank", true)
        unitFrame.RoleIndicator:Show()
    elseif role == "HEALER" then
        unitFrame.RoleIndicator:SetAtlas("roleIcon-healer", true)
        unitFrame.RoleIndicator:Show()
    elseif role == "DAMAGER" then
        unitFrame.RoleIndicator:SetAtlas("roleIcon-dps", true)
        unitFrame.RoleIndicator:Show()
    else
        unitFrame.RoleIndicator:Hide()
    end
end

-----------------------------------------------------------------------
-- Party
-----------------------------------------------------------------------

local roleEvtFrame = CreateFrame("Frame")
roleEvtFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
roleEvtFrame:RegisterEvent("ROLE_CHANGED_INFORM")
roleEvtFrame:RegisterEvent("PLAYER_ROLES_ASSIGNED")
roleEvtFrame:SetScript("OnEvent", function()
    for i = 1, UUF.MAX_PARTY_MEMBERS do
        local partyFrame = UUF["PARTY"..i]
        if partyFrame and UUF.db.profile.Units.party.Indicators.Role.Enabled then
            UUF:UpdatePartyRoleIndicator(partyFrame, "party"..i)
        end
    end
end)

function UUF:CreateUnitRoleIndicator(unitFrame, unit)
    local RoleDB = UUF.db.profile.Units.party.Indicators.Role
    if not RoleDB then return end
    unitFrame.RoleIndicator = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit).."_RoleIndicator", "OVERLAY")
    unitFrame.RoleIndicator:SetSize(RoleDB.Size, RoleDB.Size)
    unitFrame.RoleIndicator:SetPoint(RoleDB.Layout[1], unitFrame.HighLevelContainer, RoleDB.Layout[2], RoleDB.Layout[3], RoleDB.Layout[4])
    unitFrame.RoleIndicator:Hide()
end

function UUF:UpdateUnitRoleIndicator(unitFrame, unit)
    local RoleDB = UUF.db.profile.Units.party.Indicators.Role
    if not unitFrame or not unitFrame.RoleIndicator or not RoleDB then return end
    unitFrame.RoleIndicator:SetSize(RoleDB.Size, RoleDB.Size)
    unitFrame.RoleIndicator:ClearAllPoints()
    unitFrame.RoleIndicator:SetPoint(RoleDB.Layout[1], unitFrame.HighLevelContainer, RoleDB.Layout[2], RoleDB.Layout[3], RoleDB.Layout[4])
    UUF:UpdatePartyRoleIndicator(unitFrame, unit)
end

function UUF:UpdatePartyRoleIndicator(unitFrame, unit)
    local RoleDB = UUF.db.profile.Units.party.Indicators.Role
    if not unitFrame or not unitFrame.RoleIndicator or not RoleDB then return end
    if not RoleDB.Enabled then
        unitFrame.RoleIndicator:Hide()
        return
    end
    local role = UnitGroupRolesAssigned(unit)
    if role == "TANK" then
        unitFrame.RoleIndicator:SetAtlas("roleIcon-tank", true)
        unitFrame.RoleIndicator:Show()
    elseif role == "HEALER" then
        unitFrame.RoleIndicator:SetAtlas("roleIcon-healer", true)
        unitFrame.RoleIndicator:Show()
    elseif role == "DAMAGER" then
        unitFrame.RoleIndicator:SetAtlas("roleIcon-dps", true)
        unitFrame.RoleIndicator:Show()
    else
        unitFrame.RoleIndicator:Hide()
    end
end
