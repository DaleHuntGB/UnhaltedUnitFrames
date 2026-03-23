local _, UUF = ...

function UUF:CreateUnitRoleIconIndicator(unitFrame, unit)
    local RoleIconDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.RoleIcon
    if not RoleIconDB then return end

    local RoleIcon = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit) .. "_RoleIconIndicator", "OVERLAY")
    RoleIcon:SetSize(RoleIconDB.Size, RoleIconDB.Size)
    RoleIcon:SetPoint(RoleIconDB.Layout[1], unitFrame.HighLevelContainer, RoleIconDB.Layout[2], RoleIconDB.Layout[3], RoleIconDB.Layout[4])
    RoleIcon.useAtlasSize = false

    if RoleIconDB.Enabled then
        unitFrame.GroupRoleIndicator = RoleIcon
    else
        if unitFrame:IsElementEnabled("GroupRoleIndicator") then
            unitFrame:DisableElement("GroupRoleIndicator")
        end
        RoleIcon:Hide()
    end

    return RoleIcon
end

function UUF:UpdateUnitRoleIconIndicator(unitFrame, unit)
    local RoleIconDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.RoleIcon
    if not RoleIconDB then return end

    if RoleIconDB.Enabled then
        unitFrame.GroupRoleIndicator = unitFrame.GroupRoleIndicator or UUF:CreateUnitRoleIconIndicator(unitFrame, unit)

        if not unitFrame:IsElementEnabled("GroupRoleIndicator") then
            unitFrame:EnableElement("GroupRoleIndicator")
        end

        if unitFrame.GroupRoleIndicator then
            unitFrame.GroupRoleIndicator.useAtlasSize = false
            unitFrame.GroupRoleIndicator:ClearAllPoints()
            unitFrame.GroupRoleIndicator:SetSize(RoleIconDB.Size, RoleIconDB.Size)
            unitFrame.GroupRoleIndicator:SetPoint(RoleIconDB.Layout[1], unitFrame.HighLevelContainer, RoleIconDB.Layout[2], RoleIconDB.Layout[3], RoleIconDB.Layout[4])
            unitFrame.GroupRoleIndicator:Show()
            unitFrame.GroupRoleIndicator:ForceUpdate()
        end
    else
        if not unitFrame.GroupRoleIndicator then return end
        if unitFrame:IsElementEnabled("GroupRoleIndicator") then
            unitFrame:DisableElement("GroupRoleIndicator")
        end
        unitFrame.GroupRoleIndicator:Hide()
        unitFrame.GroupRoleIndicator = nil
    end
end
