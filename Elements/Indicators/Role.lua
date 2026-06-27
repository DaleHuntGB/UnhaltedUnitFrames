local _, UUF = ...

function UUF:CreateUnitRoleIndicator(unitFrame, unit)
	local RoleDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Role
	if not RoleDB then return end

	local RoleIndicator = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit) .. "_RoleIndicator", "OVERLAY")
	RoleIndicator:SetSize(RoleDB.Size, RoleDB.Size)
	RoleIndicator:SetPoint(RoleDB.Layout[1], unitFrame.HighLevelContainer, RoleDB.Layout[2], RoleDB.Layout[3], RoleDB.Layout[4])
	RoleIndicator.PostUpdate = function(textureElement, role)
		local showRole = (role == "TANK" and RoleDB.ShowTank ~= false) or (role == "HEALER" and RoleDB.ShowHealer ~= false) or (role == "DAMAGER" and RoleDB.ShowDamager ~= false)
		if not showRole then textureElement:Hide() return end
		local roleTexture = UUF.RoleTextures[RoleDB.Texture] and UUF.RoleTextures[RoleDB.Texture][role]
		if roleTexture then
			textureElement:SetTexture(roleTexture)
			textureElement:SetTexCoord(0, 1, 0, 1)
		end
		textureElement:Show()
	end

	if RoleDB.Enabled then
		unitFrame.GroupRoleIndicator = RoleIndicator
	else
		RoleIndicator:Hide()
	end

	return RoleIndicator
end

function UUF:UpdateUnitRoleIndicator(unitFrame, unit)
	local RoleDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Role
	if not RoleDB then return end

	if RoleDB.Enabled then
		unitFrame.GroupRoleIndicator = unitFrame.GroupRoleIndicator or UUF:CreateUnitRoleIndicator(unitFrame, unit)
		if not unitFrame:IsElementEnabled("GroupRoleIndicator") then unitFrame:EnableElement("GroupRoleIndicator") end

		unitFrame.GroupRoleIndicator:ClearAllPoints()
		unitFrame.GroupRoleIndicator:SetSize(RoleDB.Size, RoleDB.Size)
		unitFrame.GroupRoleIndicator:SetPoint(RoleDB.Layout[1], unitFrame.HighLevelContainer, RoleDB.Layout[2], RoleDB.Layout[3], RoleDB.Layout[4])
		unitFrame.GroupRoleIndicator:ForceUpdate()
	elseif unitFrame.GroupRoleIndicator then
		if unitFrame:IsElementEnabled("GroupRoleIndicator") then unitFrame:DisableElement("GroupRoleIndicator") end
		unitFrame.GroupRoleIndicator:Hide()
		unitFrame.GroupRoleIndicator = nil
	end
end
