local _, UUF = ...
local oUF = UUF.oUF
local blizzardRaidFramesDisabled = false
local blizzardRaidFrames = {}

local function HideBlizzardRaidFrames()
	for frame in pairs(blizzardRaidFrames) do
		frame:SetAlpha(0)
		frame:UnregisterAllEvents()
		if not InCombatLockdown() then
			frame:SetScale(0.001)
			frame:Hide()
		end
	end
end

function UUF:GetRaidGroupFilter()
	local FrameDB = UUF.db.profile.Units.raid.Frame
	local groupingOrder = {}
	local selectedGroups = {}
	for _, groupIndex in ipairs(FrameDB.GroupingOrder) do
		groupIndex = tonumber(groupIndex)
		if groupIndex and groupIndex >= 1 and groupIndex <= UUF.MAX_RAID_GROUPS and not selectedGroups[groupIndex] then
			groupingOrder[#groupingOrder + 1] = groupIndex
			selectedGroups[groupIndex] = true
		end
	end
	local groupFilter = #groupingOrder > 0 and table.concat(groupingOrder, ",") or "0"
	for groupIndex = #groupingOrder + 1, UUF.MAX_RAID_GROUPS do groupingOrder[groupIndex] = 0 end
	FrameDB.GroupingOrder = groupingOrder
	return groupFilter, groupingOrder, selectedGroups
end

function UUF:SpawnRaidFrames()
	local UnitDB = UUF.db.profile.Units.raid
	if not UnitDB then return end
	if UnitDB.ForceHideBlizzard and not blizzardRaidFramesDisabled then
		if not C_AddOns.IsAddOnLoaded("Blizzard_CompactRaidFrames") then C_AddOns.LoadAddOn("Blizzard_CompactRaidFrames") end
		if CompactRaidFrameContainer then blizzardRaidFrames[CompactRaidFrameContainer] = true end
		if CompactRaidFrameManager then blizzardRaidFrames[CompactRaidFrameManager] = true end
		if CompactRaidFrameManager_UpdateShown then hooksecurefunc("CompactRaidFrameManager_UpdateShown", HideBlizzardRaidFrames) end
		if CompactRaidFrameManager then CompactRaidFrameManager:HookScript("OnShow", HideBlizzardRaidFrames) end
		if CompactRaidFrameContainer then CompactRaidFrameContainer:HookScript("OnShow", HideBlizzardRaidFrames) end
		HideBlizzardRaidFrames()
		blizzardRaidFramesDisabled = true
	end
	local FrameDB = UnitDB.Frame
	if FrameDB.GroupBy ~= "INDEX" and FrameDB.GroupBy ~= "GROUP" then FrameDB.GroupBy = "GROUP" end

	local raidFrameIndex = 0
	oUF:RegisterStyle(UUF:FetchFrameName("raid"), function(unitFrame)
		raidFrameIndex = raidFrameIndex + 1
		local raidUnit = "raid" .. raidFrameIndex
		UUF:CreateUnitFrame(unitFrame, raidUnit)
		UUF.RAID_FRAMES[raidFrameIndex] = unitFrame
		unitFrame:SetFrameStrata(FrameDB.FrameStrata)
		UUF:RegisterDispelHighlightEvents(unitFrame, raidUnit)
		UUF:RegisterTargetGlowIndicatorFrame(unitFrame, raidUnit)
		UUF:RegisterRangeFrame(unitFrame, raidUnit)
	end)
	oUF:SetActiveStyle(UUF:FetchFrameName("raid"))

	for groupIndex = 1, UUF.MAX_RAID_GROUPS do
		local raidHeader = oUF:SpawnHeader(UUF:FetchFrameName("raid") .. "Group" .. groupIndex, nil, {
			showRaid = true,
			showParty = false,
			showPlayer = true,
			showSolo = false,
			groupFilter = tostring(groupIndex),
			sortMethod = "INDEX",
			point = FrameDB.ColumnDirection == "UP" and "BOTTOM" or "TOP",
			xOffset = 0,
			yOffset = FrameDB.ColumnDirection == "UP" and FrameDB.Layout[5] or -FrameDB.Layout[5],
			unitsPerColumn = UUF.RAID_GROUP_SIZE,
			maxColumns = 1,
			["oUF-initialConfigFunction"] = ("self:SetWidth(%s); self:SetHeight(%s)"):format(FrameDB.Width, FrameDB.Height),
		})
		raidHeader:SetAttribute("startingIndex", -(UUF.RAID_GROUP_SIZE - 1))
		raidHeader:Show()
		raidHeader:SetAttribute("startingIndex", 1)
		UUF.RAID_HEADERS[groupIndex] = raidHeader
	end

	UUF.RAID = UUF.RAID_CONTAINER
	UUF:CreateMover("raid")
	UUF:UpdateRaidFrames()
	return UUF.RAID
end

function UUF:UpdateRaidFrames()
	local UnitDB = UUF.db.profile.Units.raid
	if not UnitDB or #UUF.RAID_HEADERS == 0 or InCombatLockdown() then return end
	local FrameDB = UnitDB.Frame
	if FrameDB.GroupBy ~= "INDEX" and FrameDB.GroupBy ~= "GROUP" then FrameDB.GroupBy = "GROUP" end
	for raidIndex, raidFrame in pairs(UUF.RAID_FRAMES) do UUF:UpdateUnitFrame(raidFrame, raidFrame.unit or "raid" .. raidIndex) end

	local _, groupingOrder, selectedGroups = UUF:GetRaidGroupFilter()
	local displayedGroups = {}
	if FrameDB.GroupBy == "GROUP" then
		for _, groupIndex in ipairs(groupingOrder) do
			if groupIndex ~= 0 then displayedGroups[#displayedGroups + 1] = groupIndex end
		end
	else
		for groupIndex = 1, UUF.MAX_RAID_GROUPS do
			if selectedGroups[groupIndex] then displayedGroups[#displayedGroups + 1] = groupIndex end
		end
	end

	local containerWidth = #displayedGroups * FrameDB.Width + math.max(#displayedGroups - 1, 0) * FrameDB.Layout[5]
	local containerHeight = UUF.RAID_GROUP_SIZE * FrameDB.Height + (UUF.RAID_GROUP_SIZE - 1) * FrameDB.Layout[5]
	UUF.RAID_CONTAINER:ClearAllPoints()
	UUF.RAID_CONTAINER:SetSize(math.max(containerWidth, 1), math.max(containerHeight, 1))
	UUF.RAID_CONTAINER:SetPoint(FrameDB.Layout[1], UIParent, FrameDB.Layout[2], FrameDB.Layout[3], FrameDB.Layout[4])

	local point = FrameDB.ColumnDirection == "UP" and "BOTTOM" or "TOP"
	local yOffset = FrameDB.ColumnDirection == "UP" and FrameDB.Layout[5] or -FrameDB.Layout[5]
	local initialConfigFunction = ("self:SetWidth(%s); self:SetHeight(%s)"):format(FrameDB.Width, FrameDB.Height)
	local frameAnchor = FrameDB.ColumnDirection == "UP" and (FrameDB.RowDirection == "LEFT" and "BOTTOMRIGHT" or "BOTTOMLEFT") or FrameDB.RowDirection == "LEFT" and "TOPRIGHT" or "TOPLEFT"
	for displayIndex, groupIndex in ipairs(displayedGroups) do
		local raidHeader = UUF.RAID_HEADERS[groupIndex]
		local offsetX = (displayIndex - 1) * (FrameDB.Width + FrameDB.Layout[5])
		if FrameDB.RowDirection == "LEFT" then offsetX = -offsetX end
		raidHeader:ClearAllPoints()
		raidHeader:SetPoint(frameAnchor, UUF.RAID_CONTAINER, frameAnchor, offsetX, 0)
	end

	for groupIndex, raidHeader in ipairs(UUF.RAID_HEADERS) do
		if raidHeader:GetAttribute("point") ~= point then raidHeader:SetAttribute("point", point) end
		if raidHeader:GetAttribute("yOffset") ~= yOffset then raidHeader:SetAttribute("yOffset", yOffset) end
		if raidHeader:GetAttribute("unitsPerColumn") ~= UUF.RAID_GROUP_SIZE then raidHeader:SetAttribute("unitsPerColumn", UUF.RAID_GROUP_SIZE) end
		if raidHeader:GetAttribute("maxColumns") ~= 1 then raidHeader:SetAttribute("maxColumns", 1) end
		if raidHeader:GetAttribute("oUF-initialConfigFunction") ~= initialConfigFunction then raidHeader:SetAttribute("oUF-initialConfigFunction", initialConfigFunction) end
		if raidHeader:GetAttribute("sortMethod") ~= "INDEX" then raidHeader:SetAttribute("sortMethod", "INDEX") end
		if raidHeader:GetAttribute("groupFilter") ~= tostring(groupIndex) then raidHeader:SetAttribute("groupFilter", tostring(groupIndex)) end
		if raidHeader:GetAttribute("strictFiltering") then raidHeader:SetAttribute("strictFiltering", nil) end
		raidHeader:SetVisibility(UnitDB.Enabled and selectedGroups[groupIndex] and "raid" or "custom hide")
	end
end
