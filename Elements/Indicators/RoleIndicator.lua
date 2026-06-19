local _, UUF = ...

function UUF:CreateUnitRoleIndicator(unitFrame, unit)
	local RoleDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Role
	local RoleIndicator = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit) .. "_RoleIndicator", "OVERLAY")
	RoleIndicator:SetSize(RoleDB.Size, RoleDB.Size)
	RoleIndicator:SetPoint(RoleDB.Layout[1], unitFrame.HighLevelContainer, RoleDB.Layout[2], RoleDB.Layout[3], RoleDB.Layout[4])
	unitFrame.RoleIndicator = RoleIndicator

	if RoleDB.Enabled then
		unitFrame.GroupRoleIndicator = RoleIndicator
	else
		if unitFrame:IsElementEnabled("GroupRoleIndicator") then unitFrame:DisableElement("GroupRoleIndicator") end
		RoleIndicator:Hide()
	end

	return RoleIndicator
end

function UUF:UpdateUnitRoleIndicator(unitFrame, unit)
	local RoleDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Role
	local RoleIndicator = unitFrame.RoleIndicator or UUF:CreateUnitRoleIndicator(unitFrame, unit)

	if RoleDB.Enabled then
		unitFrame.GroupRoleIndicator = RoleIndicator
		if not unitFrame:IsElementEnabled("GroupRoleIndicator") then unitFrame:EnableElement("GroupRoleIndicator") end
		RoleIndicator:ClearAllPoints()
		RoleIndicator:SetSize(RoleDB.Size, RoleDB.Size)
		RoleIndicator:SetPoint(RoleDB.Layout[1], unitFrame.HighLevelContainer, RoleDB.Layout[2], RoleDB.Layout[3], RoleDB.Layout[4])
		RoleIndicator:Show()
		RoleIndicator:ForceUpdate()
	else
		if unitFrame:IsElementEnabled("GroupRoleIndicator") then unitFrame:DisableElement("GroupRoleIndicator") end
		RoleIndicator:Hide()
		unitFrame.GroupRoleIndicator = nil
	end
end
