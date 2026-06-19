local _, UUF = ...
local oUF = UUF.oUF

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
	return groupFilter
end

function UUF:SpawnRaidFrames()
	local UnitDB = UUF.db.profile.Units.raid
	if not UnitDB then return end
	if UnitDB.ForceHideBlizzard then oUF:DisableBlizzard("raid") end
	local FrameDB = UnitDB.Frame
	if FrameDB.GroupBy ~= "INDEX" and FrameDB.GroupBy ~= "GROUP" then FrameDB.GroupBy = "GROUP" end
	local groupFilter = UUF:GetRaidGroupFilter()

	oUF:RegisterStyle(UUF:FetchFrameName("raid"), function(unitFrame)
		local raidIndex = tonumber(unitFrame:GetName():match("UnitButton(%d+)$")) or #UUF.RAID_FRAMES + 1
		local raidUnit = "raid" .. raidIndex
		UUF:CreateUnitFrame(unitFrame, raidUnit)
		UUF.RAID_FRAMES[raidIndex] = unitFrame
		unitFrame:SetFrameStrata(FrameDB.FrameStrata)
		UUF:RegisterDispelHighlightEvents(unitFrame, raidUnit)
		UUF:RegisterTargetGlowIndicatorFrame(unitFrame, raidUnit)
		UUF:RegisterRangeFrame(unitFrame, raidUnit)
	end)
	oUF:SetActiveStyle(UUF:FetchFrameName("raid"))

	local headerAttributes = {
		showRaid = true,
		showParty = false,
		showPlayer = true,
		showSolo = false,
		groupFilter = groupFilter,
		strictFiltering = true,
		sortMethod = "INDEX",
		point = FrameDB.ColumnDirection == "UP" and "BOTTOM" or "TOP",
		xOffset = 0,
		yOffset = FrameDB.ColumnDirection == "UP" and FrameDB.Layout[5] or -FrameDB.Layout[5],
		columnAnchorPoint = FrameDB.RowDirection == "LEFT" and "RIGHT" or "LEFT",
		columnSpacing = FrameDB.Layout[5],
		unitsPerColumn = FrameDB.UnitsPerColumn,
		maxColumns = math.ceil(UUF.MAX_RAID_FRAMES / FrameDB.UnitsPerColumn),
		["oUF-initialConfigFunction"] = ("self:SetWidth(%s); self:SetHeight(%s)"):format(FrameDB.Width, FrameDB.Height),
	}
	if FrameDB.GroupBy == "GROUP" then
		headerAttributes.groupBy = "GROUP"
		headerAttributes.groupingOrder = groupFilter
	end

	UUF.RAID = oUF:SpawnHeader(UUF:FetchFrameName("raid"), nil, headerAttributes)
	UUF.RAID:SetPoint(FrameDB.Layout[1], UIParent, FrameDB.Layout[2], FrameDB.Layout[3], FrameDB.Layout[4])
	UUF.RAID:SetAttribute("startingIndex", -(UUF.MAX_RAID_FRAMES - 1))
	UUF.RAID:Show()
	UUF.RAID:SetAttribute("startingIndex", 1)
	UUF.RAID:SetVisibility(UnitDB.Enabled and groupFilter ~= "0" and "raid" or "custom hide")
	UUF:CreateMover("raid")

	oUF:RegisterStyle(UUF:FetchFrameName("raid") .. "Test", function(unitFrame)
		local raidIndex = tonumber(unitFrame:GetName():match("Test(%d+)$"))
		UUF:CreateUnitFrame(unitFrame, "raidtest" .. raidIndex)
	end)
	oUF:SetActiveStyle(UUF:FetchFrameName("raid") .. "Test")
	local DisableBlizzard = oUF.DisableBlizzard
	oUF.DisableBlizzard = function() end
	for raidIndex = 1, UUF.MAX_RAID_FRAMES do
		local raidFrame = oUF:Spawn("raid" .. raidIndex, UUF:FetchFrameName("raid") .. "Test" .. raidIndex)
		UnregisterUnitWatch(raidFrame)
		raidFrame:SetAttribute("unit", nil)
		raidFrame:SetScript("OnShow", nil)
		raidFrame:EnableMouse(false)
		UUF:CreateTestAuras(raidFrame, "raidtest" .. raidIndex, false)
		UUF:DisableTestGroupFrameTags(raidFrame)
		raidFrame:UnregisterAllEvents()
		raidFrame:Hide()
		UUF.RAID_TEST_FRAMES[raidIndex] = raidFrame
	end
	oUF.DisableBlizzard = DisableBlizzard
	return UUF.RAID
end

function UUF:UpdateRaidFrames()
	local UnitDB = UUF.db.profile.Units.raid
	if not UnitDB or not UUF.RAID or InCombatLockdown() then return end
	local FrameDB = UnitDB.Frame
	if FrameDB.GroupBy ~= "INDEX" and FrameDB.GroupBy ~= "GROUP" then FrameDB.GroupBy = "GROUP" end
	for raidIndex, raidFrame in pairs(UUF.RAID_FRAMES) do UUF:UpdateUnitFrame(raidFrame, raidFrame.unit or "raid" .. raidIndex) end

	UUF.RAID:ClearAllPoints()
	UUF.RAID:SetPoint(FrameDB.Layout[1], UIParent, FrameDB.Layout[2], FrameDB.Layout[3], FrameDB.Layout[4])
	local groupFilter = UUF:GetRaidGroupFilter()
	local point = FrameDB.ColumnDirection == "UP" and "BOTTOM" or "TOP"
	local columnAnchorPoint = FrameDB.RowDirection == "LEFT" and "RIGHT" or "LEFT"
	local yOffset = FrameDB.ColumnDirection == "UP" and FrameDB.Layout[5] or -FrameDB.Layout[5]
	local initialConfigFunction = ("self:SetWidth(%s); self:SetHeight(%s)"):format(FrameDB.Width, FrameDB.Height)
	if UUF.RAID:GetAttribute("point") ~= point then UUF.RAID:SetAttribute("point", point) end
	if UUF.RAID:GetAttribute("yOffset") ~= yOffset then UUF.RAID:SetAttribute("yOffset", yOffset) end
	if UUF.RAID:GetAttribute("columnAnchorPoint") ~= columnAnchorPoint then UUF.RAID:SetAttribute("columnAnchorPoint", columnAnchorPoint) end
	if UUF.RAID:GetAttribute("columnSpacing") ~= FrameDB.Layout[5] then UUF.RAID:SetAttribute("columnSpacing", FrameDB.Layout[5]) end
	if UUF.RAID:GetAttribute("unitsPerColumn") ~= FrameDB.UnitsPerColumn then UUF.RAID:SetAttribute("unitsPerColumn", FrameDB.UnitsPerColumn) end
	local maxColumns = math.ceil(UUF.MAX_RAID_FRAMES / FrameDB.UnitsPerColumn)
	if UUF.RAID:GetAttribute("maxColumns") ~= maxColumns then UUF.RAID:SetAttribute("maxColumns", maxColumns) end
	if UUF.RAID:GetAttribute("oUF-initialConfigFunction") ~= initialConfigFunction then UUF.RAID:SetAttribute("oUF-initialConfigFunction", initialConfigFunction) end
	if UUF.RAID:GetAttribute("sortMethod") ~= "INDEX" then UUF.RAID:SetAttribute("sortMethod", "INDEX") end

	if FrameDB.GroupBy == "GROUP" then
		if UUF.RAID:GetAttribute("groupingOrder") ~= groupFilter then UUF.RAID:SetAttribute("groupingOrder", groupFilter) end
		if UUF.RAID:GetAttribute("groupBy") ~= "GROUP" then UUF.RAID:SetAttribute("groupBy", "GROUP") end
	else
		if UUF.RAID:GetAttribute("groupBy") then UUF.RAID:SetAttribute("groupBy", nil) end
		if UUF.RAID:GetAttribute("groupingOrder") then UUF.RAID:SetAttribute("groupingOrder", nil) end
	end
	if UUF.RAID:GetAttribute("groupFilter") ~= groupFilter then UUF.RAID:SetAttribute("groupFilter", groupFilter) end
	UUF.RAID:SetVisibility(UnitDB.Enabled and groupFilter ~= "0" and "raid" or "custom hide")
	UUF:CreateTestGroupFrames("raid")
end
