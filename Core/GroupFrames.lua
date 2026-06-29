local _, UUF = ...
local oUF = UUF.oUF

local BlizzardRaidHiddenParent = CreateFrame("Frame", "UUF_BlizzardRaidHiddenParent", UIParent)
BlizzardRaidHiddenParent:Hide()

local function HideBlizzardRaidFrame(raidFrame)
	if not raidFrame then return end
	raidFrame:UnregisterAllEvents()
	raidFrame:Hide()
	if not InCombatLockdown() or not raidFrame:IsProtected() then raidFrame:SetParent(BlizzardRaidHiddenParent) end
end

function UUF:HideBlizzardRaidFrames()
	HideBlizzardRaidFrame(_G.CompactRaidFrameManager)
	HideBlizzardRaidFrame(_G.CompactRaidFrameContainer)
	for i = 1, UUF.MAX_RAID_GROUPS do HideBlizzardRaidFrame(_G["CompactRaidGroup" .. i]) end
	for i = 1, UUF.MAX_RAID_FRAMES do HideBlizzardRaidFrame(_G["CompactRaidFrame" .. i]) end
end

function UUF:RegisterRaidFrame(unitFrame)
	if not unitFrame or unitFrame.isUUFUnitFrame then return end
	unitFrame.isUUFUnitFrame = true
	UUF.RAID_FRAMES[#UUF.RAID_FRAMES + 1] = unitFrame
end

function UUF:CreateRaidContainer()
	local Frame = UUF.db.profile.Units.raid.Frame
	if not UUF.RAID_CONTAINER then
		UUF.RAID_CONTAINER = CreateFrame("Frame", "UUF_RaidContainer", UIParent, "BackdropTemplate")
		UUF.RAID_CONTAINER:SetBackdrop(UUF.BACKDROP)
		UUF.RAID_CONTAINER:SetBackdropColor(0, 0, 0, 0)
		UUF.RAID_CONTAINER:SetBackdropBorderColor(0, 0, 0, 0)
	end
	UUF.RAID_CONTAINER:ClearAllPoints()
	UUF.RAID_CONTAINER:SetPoint(Frame.Layout[1], UIParent, Frame.Layout[2], Frame.Layout[3], Frame.Layout[4])
	UUF.RAID_CONTAINER:SetFrameStrata(Frame.FrameStrata)
	RegisterStateDriver(UUF.RAID_CONTAINER, "visibility", "show")
end

function UUF:LayoutRaidFrames()
	local Frame = UUF.db.profile.Units.raid.Frame
	if not UUF.RAID_CONTAINER then return end
	local _, _, difficultyID = GetInstanceInfo()
	local autoGroupCount = Frame.AutoAdjustGroups and ((difficultyID == 14 or difficultyID == 15) and 6 or difficultyID == 16 and 4 or difficultyID == 233 and 5 or 8)
	UUF.RAID_CONTAINER:ClearAllPoints()
	UUF.RAID_CONTAINER:SetPoint(Frame.Layout[1], UIParent, Frame.Layout[2], Frame.Layout[3], Frame.Layout[4])
	UUF.RAID_CONTAINER:SetFrameStrata(Frame.FrameStrata)

	local shownGroups = 0
	for groupIndex = 1, UUF.MAX_RAID_GROUPS do
		if autoGroupCount and groupIndex <= autoGroupCount or not autoGroupCount and (not Frame.Groups or Frame.Groups[groupIndex]) then shownGroups = shownGroups + 1 end
	end

	local unitGrowth, groupGrowth = (Frame.GrowthDirection or "RIGHT_DOWN"):match("^(%a+)_(%a+)$")
	unitGrowth = unitGrowth or "RIGHT"
	groupGrowth = groupGrowth or "DOWN"
	local spacing = Frame.Layout[5] or 0
	local headerWidth = (unitGrowth == "UP" or unitGrowth == "DOWN") and Frame.Width or (Frame.Width + spacing) * UUF.MAX_RAID_FRAMES_PER_GROUP - spacing
	local headerHeight = (unitGrowth == "UP" or unitGrowth == "DOWN") and (Frame.Height + spacing) * UUF.MAX_RAID_FRAMES_PER_GROUP - spacing or Frame.Height
	local containerWidth = (groupGrowth == "LEFT" or groupGrowth == "RIGHT") and (headerWidth + spacing) * shownGroups - spacing or headerWidth
	local containerHeight = (groupGrowth == "UP" or groupGrowth == "DOWN") and (headerHeight + spacing) * shownGroups - spacing or headerHeight
	local point = unitGrowth == "RIGHT" and "RIGHT" or unitGrowth == "UP" and "TOP" or unitGrowth == "DOWN" and "BOTTOM" or "LEFT"
	local unitXOffset = unitGrowth == "RIGHT" and -spacing or unitGrowth == "LEFT" and spacing or 0
	local unitYOffset = unitGrowth == "UP" and -spacing or unitGrowth == "DOWN" and spacing or 0

	UUF.RAID_CONTAINER:SetSize(math.max(containerWidth, Frame.Width), math.max(containerHeight, Frame.Height))

	local shownGroupIndex = 0
	for groupIndex, header in ipairs(UUF.RAID_HEADERS) do
		local showGroup = autoGroupCount and groupIndex <= autoGroupCount or not autoGroupCount and (not Frame.Groups or Frame.Groups[groupIndex])
		header:SetAttribute("groupFilter", showGroup and tostring(groupIndex) or "0")
		if showGroup then
			shownGroupIndex = shownGroupIndex + 1
			header:Show()
		else
			header:Hide()
		end
		header:SetAttribute("initial-width", Frame.Width)
		header:SetAttribute("initial-height", Frame.Height)
		header:SetAttribute("point", point)
		header:SetAttribute("xOffset", unitXOffset)
		header:SetAttribute("yOffset", unitYOffset)
		header:SetAttribute("unitsPerColumn", UUF.MAX_RAID_FRAMES_PER_GROUP)
		header:SetAttribute("maxColumns", 1)
		header:SetAttribute("sortMethod", Frame.SortBy == "INDEX" and "INDEX" or nil)
		header:SetFrameStrata(Frame.FrameStrata)
		header:SetSize(headerWidth, headerHeight)
		header:ClearAllPoints()
		local horizontalOffset = (shownGroupIndex - 1) * (headerWidth + spacing)
		local verticalOffset = (shownGroupIndex - 1) * (headerHeight + spacing)
		local horizontalAnchor = groupGrowth == "LEFT" and "RIGHT" or groupGrowth == "RIGHT" and "LEFT" or unitGrowth == "RIGHT" and "RIGHT" or "LEFT"
		local verticalAnchor = groupGrowth == "UP" and "BOTTOM" or groupGrowth == "DOWN" and "TOP" or unitGrowth == "DOWN" and "BOTTOM" or "TOP"
		local anchor = verticalAnchor .. horizontalAnchor
		local xOffset = groupGrowth == "RIGHT" and horizontalOffset or groupGrowth == "LEFT" and -horizontalOffset or 0
		local yOffset = groupGrowth == "UP" and verticalOffset or groupGrowth == "DOWN" and -verticalOffset or 0

		header:SetPoint(anchor, UUF.RAID_CONTAINER, anchor, xOffset, yOffset)
	end

end

function UUF:CreatePartyContainer()
	local Frame = UUF.db.profile.Units.party.Frame
	if not UUF.PARTY_CONTAINER then
		UUF.PARTY_CONTAINER = CreateFrame("Frame", "UUF_PartyContainer", UIParent, "BackdropTemplate")
		UUF.PARTY_CONTAINER:SetBackdrop(UUF.BACKDROP)
		UUF.PARTY_CONTAINER:SetBackdropColor(0, 0, 0, 0)
		UUF.PARTY_CONTAINER:SetBackdropBorderColor(0, 0, 0, 0)
	end
	UUF.PARTY_CONTAINER:ClearAllPoints()
	UUF.PARTY_CONTAINER:SetPoint(Frame.Layout[1], UIParent, Frame.Layout[2], Frame.Layout[3], Frame.Layout[4])
	UUF.PARTY_CONTAINER:SetFrameStrata(Frame.FrameStrata)
	RegisterStateDriver(UUF.PARTY_CONTAINER, "visibility", "[group:party,nogroup:raid] show; hide")
end

local function SortPartyFrames(firstFrame, secondFrame)
	local Frame = UUF.db.profile.Units.party.Frame
	if Frame.SortBy == "NAME" then
		return (UnitName(firstFrame.unit) or firstFrame.unit or "") < (UnitName(secondFrame.unit) or secondFrame.unit or "")
	elseif Frame.SortBy == "ROLE" then
		local firstRole = UUF.PARTY_TEST_MODE and firstFrame.testRole or UnitGroupRolesAssigned(firstFrame.unit)
		local secondRole = UUF.PARTY_TEST_MODE and secondFrame.testRole or UnitGroupRolesAssigned(secondFrame.unit)
		local firstRoleOrder = 99
		local secondRoleOrder = 99
		for index, orderedRole in ipairs(Frame.RoleOrder or {}) do
			if firstRole == orderedRole then firstRoleOrder = index end
			if secondRole == orderedRole then secondRoleOrder = index end
		end
		if firstRoleOrder ~= secondRoleOrder then return firstRoleOrder < secondRoleOrder end
	end
	return (firstFrame.partyIndex or 0) < (secondFrame.partyIndex or 0)
end

function UUF:LayoutPartyFrames()
	local Frame = UUF.db.profile.Units.party.Frame
	if not UUF.PARTY_CONTAINER or #UUF.PARTY_FRAMES == 0 then return end
	UUF.PARTY_CONTAINER:ClearAllPoints()
	UUF.PARTY_CONTAINER:SetPoint(Frame.Layout[1], UIParent, Frame.Layout[2], Frame.Layout[3], Frame.Layout[4])
	UUF.PARTY_CONTAINER:SetFrameStrata(Frame.FrameStrata)
	local partyFrames = {}
	for _, partyFrame in ipairs(UUF.PARTY_FRAMES) do
		partyFrames[#partyFrames + 1] = partyFrame
	end
	table.sort(partyFrames, SortPartyFrames)
	local frameWidth = Frame.Width
	local frameHeight = Frame.Height
	local spacing = Frame.Layout[5] or 0
	local horizontal = Frame.GrowthDirection == "LEFT" or Frame.GrowthDirection == "RIGHT"
	local containerWidth = horizontal and (frameWidth + spacing) * #partyFrames - spacing or frameWidth
	local containerHeight = horizontal and frameHeight or (frameHeight + spacing) * #partyFrames - spacing
	UUF.PARTY_CONTAINER:SetSize(math.max(containerWidth, frameWidth), math.max(containerHeight, frameHeight))
	for index, partyFrame in ipairs(partyFrames) do
		partyFrame:ClearAllPoints()
		partyFrame:SetSize(frameWidth, frameHeight)
		partyFrame:SetFrameStrata(Frame.FrameStrata)
		if Frame.GrowthDirection == "UP" then
			partyFrame:SetPoint("BOTTOMLEFT", UUF.PARTY_CONTAINER, "BOTTOMLEFT", 0, (index - 1) * (frameHeight + spacing))
		elseif Frame.GrowthDirection == "LEFT" then
			partyFrame:SetPoint("TOPRIGHT", UUF.PARTY_CONTAINER, "TOPRIGHT", -((index - 1) * (frameWidth + spacing)), 0)
		elseif Frame.GrowthDirection == "RIGHT" then
			partyFrame:SetPoint("TOPLEFT", UUF.PARTY_CONTAINER, "TOPLEFT", (index - 1) * (frameWidth + spacing), 0)
		else
			partyFrame:SetPoint("TOPLEFT", UUF.PARTY_CONTAINER, "TOPLEFT", 0, -((index - 1) * (frameHeight + spacing)))
		end
	end
end

function UUF:SpawnGroupFrame(unit, FrameDB)
	if unit == "party" then
		UUF:CreatePartyContainer()
		for i = 1, UUF.MAX_PARTY_FRAMES do
			UUF[unit:upper() .. i] = oUF:Spawn(unit .. i, UUF:FetchFrameName(unit .. i))
			UUF[unit:upper() .. i].partyIndex = i + 1
			UUF[unit:upper() .. i]:SetParent(UUF.PARTY_CONTAINER)
			UUF[unit:upper() .. i]:SetSize(FrameDB.Width, FrameDB.Height)
			UUF[unit:upper() .. i]:SetFrameStrata(FrameDB.FrameStrata)
			UUF.PARTY_FRAMES[i] = UUF[unit:upper() .. i]
			UUF:RegisterTargetGlowIndicatorFrame(UUF:FetchFrameName(unit .. i), unit .. i)
			UUF:RegisterRangeFrame(UUF:FetchFrameName(unit .. i), unit .. i)
			UUF:RegisterDispelHighlightEvents(UUF[unit:upper() .. i], unit .. i)
		end
		if FrameDB.ShowPlayer then
			UUF.PARTYPLAYER = oUF:Spawn("player", UUF:FetchFrameName("partyplayer"))
			UUF.PARTYPLAYER.partyIndex = 1
			UUF.PARTYPLAYER:SetParent(UUF.PARTY_CONTAINER)
			UUF.PARTYPLAYER:SetSize(FrameDB.Width, FrameDB.Height)
			UUF.PARTYPLAYER:SetFrameStrata(FrameDB.FrameStrata)
			UUF.PARTY_FRAMES[#UUF.PARTY_FRAMES + 1] = UUF.PARTYPLAYER
			UUF:RegisterTargetGlowIndicatorFrame(UUF.PARTYPLAYER, "partyplayer")
			UUF:RegisterRangeFrame(UUF.PARTYPLAYER, "player")
			UUF:RegisterDispelHighlightEvents(UUF.PARTYPLAYER, "player")
		end
		UUF:LayoutPartyFrames()
		UUF:CreateMover(unit)
		for i = 1, UUF.MAX_PARTY_FRAMES do RegisterUnitWatch(UUF[unit:upper() .. i]) end
		UUF.PARTY_CONTAINER:Show()
		UUF:LayoutPartyFrames()
	elseif unit == "raid" then
		UUF:CreateRaidContainer()
		local unitGrowth = (FrameDB.GrowthDirection or "RIGHT_DOWN"):match("^(%a+)_")
		local spacing = FrameDB.Layout[5] or 0
		local point = unitGrowth == "RIGHT" and "RIGHT" or unitGrowth == "UP" and "TOP" or unitGrowth == "DOWN" and "BOTTOM" or "LEFT"
		local unitXOffset = unitGrowth == "RIGHT" and -spacing or unitGrowth == "LEFT" and spacing or 0
		local unitYOffset = unitGrowth == "UP" and -spacing or unitGrowth == "DOWN" and spacing or 0

		for groupIndex = 1, UUF.MAX_RAID_GROUPS do
			local headerName = "UUF_RaidHeader" .. groupIndex
			local header = oUF:SpawnHeader(headerName, nil,
				"showRaid", true,
				"showParty", false,
				"showPlayer", true,
				"showSolo", false,
				"groupFilter", (not FrameDB.Groups or FrameDB.Groups[groupIndex]) and tostring(groupIndex) or "0",
				"initial-width", FrameDB.Width,
				"initial-height", FrameDB.Height,
				"oUF-initialConfigFunction", ("self:SetWidth(%s); self:SetHeight(%s)"):format(FrameDB.Width, FrameDB.Height),
				"point", point,
				"xOffset", unitXOffset,
				"yOffset", unitYOffset,
				"unitsPerColumn", UUF.MAX_RAID_FRAMES_PER_GROUP,
				"maxColumns", 1,
				"sortMethod", FrameDB.SortBy == "INDEX" and "INDEX" or nil
			)
			header:SetSize(FrameDB.Width, FrameDB.Height)
			header:SetParent(UUF.RAID_CONTAINER)
			header:SetVisibility("raid")
			header:SetAttribute("startingIndex", -(UUF.MAX_RAID_FRAMES_PER_GROUP - 1))
			header:Show()
			header:SetAttribute("startingIndex", 1)
			UUF.RAID_HEADERS[groupIndex] = header
		end
		UUF:LayoutRaidFrames()
		UUF:CreateMover(unit)
		UUF.RAID_CONTAINER:Show()
		for _, header in ipairs(UUF.RAID_HEADERS) do header:Show() end
		UUF:LayoutRaidFrames()
	end
end

function UUF:UpdatePartyFrames()
	local UnitDB = UUF.db.profile.Units.party
	if not UnitDB or not UnitDB.Enabled then
		if UUF.PARTY_CONTAINER then UUF.PARTY_CONTAINER:Hide() end
		return
	end
	UUF:CreatePartyContainer()
	for i = 1, UUF.MAX_PARTY_FRAMES do
		if UUF["PARTY"..i] then UUF:UpdateUnitFrame(UUF["PARTY"..i], "party"..i) end
	end
	if UUF.PARTYPLAYER then UUF:UpdateUnitFrame(UUF.PARTYPLAYER, "partyplayer") end
	UUF:LayoutPartyFrames()
	if UUF.PARTY_TEST_MODE then UUF:UpdateTestEnvironment("party", "all") end
end

function UUF:RefreshGroupFrame(unitFrame, unit)
	if not unitFrame or not unit then return end
	if unitFrame.DispelHighlightUnit and unitFrame.DispelHighlightUnit ~= unit then UUF:UnregisterDispelHighlightEvents(unitFrame) end
	UUF:RegisterRangeFrame(unitFrame, unit == "partyplayer" and "player" or unit)
	UUF:RegisterTargetGlowIndicatorFrame(unitFrame, unit)
	if unitFrame.UUFGroupUnit ~= unit then
		unitFrame.UUFGroupUnit = unit
		if unitFrame.DispelHighlight then UUF:UpdateUnitDispelHighlight(unitFrame, unit) end
	end
	UUF:UpdateUnitPowerBar(unitFrame, unit)
	UUF:UpdateUnitRoleIndicator(unitFrame, unit)
end

function UUF:RefreshPartyFrames()
	if not UUF.db.profile.Units.party.Enabled then return end
	for i = 1, UUF.MAX_PARTY_FRAMES do UUF:RefreshGroupFrame(UUF["PARTY" .. i], "party" .. i) end
	if UUF.PARTYPLAYER then UUF:RefreshGroupFrame(UUF.PARTYPLAYER, "partyplayer") end
	UUF:LayoutPartyFrames()
end

function UUF:RefreshRaidFrames()
	if not UUF.db.profile.Units.raid.Enabled then return end
	for _, raidFrame in ipairs(UUF.RAID_FRAMES) do
		local useFrame = raidFrame and (not raidFrame.isTestFrame or UUF.RAID_TEST_MODE)
		local unit = useFrame and raidFrame:GetAttribute("unit")
		if unit and unit ~= "raid" then
			UUF:RefreshGroupFrame(raidFrame, unit)
		elseif raidFrame then
			UUF:UnregisterRangeFrame(raidFrame)
			UUF:UnregisterTargetGlowIndicatorFrame(raidFrame)
			if raidFrame.DispelHighlightUnit then UUF:UnregisterDispelHighlightEvents(raidFrame) end
			raidFrame.UUFGroupUnit = nil
		end
	end
	UUF:LayoutRaidFrames()
end

function UUF:RefreshGroupRoles()
	UUF:RefreshPartyFrames()
	if UUF.db.profile.Units.raid.Enabled then
		for _, raidFrame in ipairs(UUF.RAID_FRAMES) do
			local unit = raidFrame and not raidFrame.isTestFrame and raidFrame:GetAttribute("unit")
			if unit and unit ~= "raid" then UUF:RefreshGroupFrame(raidFrame, unit) end
		end
	end
end

function UUF:UpdateRaidFrames()
	local UnitDB = UUF.db.profile.Units.raid
	if not UnitDB or not UnitDB.Enabled then
		if UUF.RAID_CONTAINER then UUF.RAID_CONTAINER:Hide() end
		return
	end
	UUF:CreateRaidContainer()

	for _, raidFrame in ipairs(UUF.RAID_FRAMES) do
		local useFrame = raidFrame and (not raidFrame.isTestFrame or UUF.RAID_TEST_MODE)
		local unit = useFrame and (raidFrame:GetAttribute("unit") or (raidFrame.isTestFrame and "raid" .. raidFrame.testIndex))
		if unit and unit ~= "raid" then
			raidFrame:SetSize(UnitDB.Frame.Width, UnitDB.Frame.Height)
			raidFrame:SetFrameStrata(UnitDB.Frame.FrameStrata)
			if raidFrame.DispelHighlightUnit and raidFrame.DispelHighlightUnit ~= unit then UUF:UnregisterDispelHighlightEvents(raidFrame) end
			UUF:UpdateUnitFrame(raidFrame, unit)
			raidFrame.UUFGroupUnit = unit
		elseif raidFrame then
			UUF:UnregisterRangeFrame(raidFrame)
			UUF:UnregisterTargetGlowIndicatorFrame(raidFrame)
			if raidFrame.DispelHighlightUnit then UUF:UnregisterDispelHighlightEvents(raidFrame) end
			raidFrame.UUFGroupUnit = nil
		end
	end

	UUF:LayoutRaidFrames()
	if UUF.RAID_TEST_MODE then UUF:UpdateTestEnvironment("raid", "all") end
end

local PartyRosterEventFrame = CreateFrame("Frame")
PartyRosterEventFrame:RegisterEvent("ADDON_LOADED")
PartyRosterEventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
PartyRosterEventFrame:RegisterEvent("PLAYER_ROLES_ASSIGNED")
PartyRosterEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
PartyRosterEventFrame:RegisterEvent("PLAYER_DIFFICULTY_CHANGED")
PartyRosterEventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
PartyRosterEventFrame:SetScript("OnEvent", function(_, event, addonName)
	if not UUF.db then return end
	if event == "ADDON_LOADED" then
		if addonName == "Blizzard_CompactRaidFrames" and UUF.db.profile.Units.raid and UUF.db.profile.Units.raid.ForceHideBlizzard then UUF:HideBlizzardRaidFrames() end
		return
	end
	if InCombatLockdown() then PartyRosterEventFrame:RegisterEvent("PLAYER_REGEN_ENABLED") return end
	if event == "PLAYER_REGEN_ENABLED" then PartyRosterEventFrame:UnregisterEvent("PLAYER_REGEN_ENABLED") end
	if event == "GROUP_ROSTER_UPDATE" then
		if UUF.db.profile.Units.raid and UUF.db.profile.Units.raid.ForceHideBlizzard then UUF:HideBlizzardRaidFrames() end
		UUF:RefreshPartyFrames()
		UUF:RefreshRaidFrames()
	elseif event == "PLAYER_ROLES_ASSIGNED" then
		UUF:RefreshGroupRoles()
	elseif event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_DIFFICULTY_CHANGED" or event == "ZONE_CHANGED_NEW_AREA" then
		if UUF.db.profile.Units.raid.Frame.AutoAdjustGroups then UUF:LayoutRaidFrames() end
	elseif event == "PLAYER_REGEN_ENABLED" then
		if UUF.db.profile.Units.raid and UUF.db.profile.Units.raid.ForceHideBlizzard then UUF:HideBlizzardRaidFrames() end
		UUF:RefreshPartyFrames()
		UUF:RefreshRaidFrames()
	end
end)
