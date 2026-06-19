local _, UUF = ...
local oUF = UUF.oUF

function UUF:SpawnPartyFrames()
	local UnitDB = UUF.db.profile.Units.party
	if not UnitDB or not UnitDB.Enabled then
		if UnitDB and UnitDB.ForceHideBlizzard then oUF:DisableBlizzard("party") end
		return
	end
	local FrameDB = UnitDB.Frame

	oUF:RegisterStyle(UUF:FetchFrameName("party"), function(unitFrame)
		local partyIndex = tonumber(unitFrame:GetName():match("UnitButton(%d+)$")) or #UUF.PARTY_FRAMES + 1
		local partyUnit = "party" .. partyIndex
		UUF:CreateUnitFrame(unitFrame, partyUnit)
		UUF.PARTY_FRAMES[partyIndex] = unitFrame
		unitFrame:SetFrameStrata(FrameDB.FrameStrata)
		UUF:RegisterDispelHighlightEvents(unitFrame, partyUnit)
		UUF:RegisterTargetGlowIndicatorFrame(unitFrame, partyUnit)
		UUF:RegisterRangeFrame(unitFrame, partyUnit)
	end)
	oUF:SetActiveStyle(UUF:FetchFrameName("party"))

	local point = FrameDB.GrowthDirection == "UP" and "BOTTOM" or "TOP"
	local offset = FrameDB.GrowthDirection == "UP" and FrameDB.Layout[5] or -FrameDB.Layout[5]
	local headerAttributes = {
		showParty = true,
		showPlayer = FrameDB.ShowPlayer,
		showSolo = false,
		sortMethod = "INDEX",
		point = point,
		xOffset = 0,
		yOffset = offset,
		["oUF-initialConfigFunction"] = ("self:SetWidth(%s); self:SetHeight(%s)"):format(FrameDB.Width, FrameDB.Height),
	}
	if FrameDB.SortBy == "ROLE" then headerAttributes.groupingOrder = table.concat(FrameDB.RoleOrder, ",") .. ",NONE" end
	UUF.PARTY = oUF:SpawnHeader(UUF:FetchFrameName("party"), nil, headerAttributes)
	if FrameDB.SortBy == "ROLE" then UUF.PARTY:SetAttribute("groupBy", "ASSIGNEDROLE") end
	UUF.PARTY:SetPoint(FrameDB.Layout[1], UIParent, FrameDB.Layout[2], FrameDB.Layout[3], FrameDB.Layout[4])
	UUF.PARTY:SetVisibility("party")
	UUF:CreateMover("party")
	UUF.PARTY:Show()
	return UUF.PARTY
end

function UUF:UpdatePartyFrames()
	local FrameDB = UUF.db.profile.Units.party.Frame
	if UUF.PARTY and InCombatLockdown() then return end
	for partyIndex, partyFrame in pairs(UUF.PARTY_FRAMES) do UUF:UpdateUnitFrame(partyFrame, "party" .. partyIndex) end
	if not UUF.PARTY then return end
	UUF.PARTY:ClearAllPoints()
	UUF.PARTY:SetPoint(FrameDB.Layout[1], UIParent, FrameDB.Layout[2], FrameDB.Layout[3], FrameDB.Layout[4])
	local yOffset = FrameDB.GrowthDirection == "UP" and FrameDB.Layout[5] or -FrameDB.Layout[5]
	if UUF.PARTY:GetAttribute("yOffset") ~= yOffset then UUF.PARTY:SetAttribute("yOffset", yOffset) end
	if UUF.PARTY:GetAttribute("showPlayer") ~= FrameDB.ShowPlayer then UUF.PARTY:SetAttribute("showPlayer", FrameDB.ShowPlayer) end
	if FrameDB.SortBy == "ROLE" then
		local groupingOrder = table.concat(FrameDB.RoleOrder, ",") .. ",NONE"
		if UUF.PARTY:GetAttribute("groupingOrder") ~= groupingOrder then UUF.PARTY:SetAttribute("groupingOrder", groupingOrder) end
		if UUF.PARTY:GetAttribute("groupBy") ~= "ASSIGNEDROLE" then UUF.PARTY:SetAttribute("groupBy", "ASSIGNEDROLE") end
	else
		if UUF.PARTY:GetAttribute("groupBy") then UUF.PARTY:SetAttribute("groupBy", nil) end
		if UUF.PARTY:GetAttribute("groupingOrder") then UUF.PARTY:SetAttribute("groupingOrder", nil) end
	end
end
