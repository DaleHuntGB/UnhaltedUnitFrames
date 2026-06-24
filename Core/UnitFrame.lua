local _, UUF = ...
local oUF = UUF.oUF

local function ApplyScripts(unitFrame)
    unitFrame:RegisterForClicks("AnyUp")
    unitFrame:SetAttribute("*type1", "target")
    unitFrame:SetAttribute("*type2", "togglemenu")
    unitFrame:HookScript("OnEnter", UnitFrame_OnEnter)
    unitFrame:HookScript("OnLeave", UnitFrame_OnLeave)
end

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

function UUF:CreateUnitFrame(unitFrame, unit)
    if not unit or not unitFrame then return end
    local UnitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)]
    local isPlayer = unit == "player"
    local isTarget = unit == "target"
    local isFocus = unit == "focus"
    local isTargetTarget = unit == "targettarget"
    local isFocusTarget = unit == "focustarget"
    local isParty = UUF:GetNormalizedUnit(unit) == "party"
    local isRaid = UUF:GetNormalizedUnit(unit) == "raid"

    UUF:CreateUnitContainer(unitFrame, unit)
    if UnitDB.CastBar and not isTargetTarget and not isFocusTarget then UUF:CreateUnitCastBar(unitFrame, unit) end
    UUF:CreateUnitHealthBar(unitFrame, unit)
    if UnitDB.HealthBar.DispelHighlight and (isPlayer or isTarget or isFocus or isParty or isRaid) then UUF:CreateUnitDispelHighlight(unitFrame, unit) end
    UUF:CreateUnitHealPrediction(unitFrame, unit)
    if UnitDB.Portrait and not isTargetTarget and not isFocusTarget then UUF:CreateUnitPortrait(unitFrame, unit) end
    UUF:CreateUnitPowerBar(unitFrame, unit)
    if isPlayer then UUF:CreateUnitAlternativePowerBar(unitFrame, unit) end
    if isPlayer then UUF:CreateUnitSecondaryPowerBar(unitFrame, unit) end
    UUF:CreateUnitRaidTargetMarker(unitFrame, unit)
    if isPlayer or isTarget or isParty or isRaid then UUF:CreateUnitLeaderAssistantIndicator(unitFrame, unit) end
    if isParty or isRaid then UUF:CreateUnitRoleIndicator(unitFrame, unit) end
    if isPlayer or isTarget then UUF:CreateUnitCombatIndicator(unitFrame, unit) end
    if isPlayer then UUF:CreateUnitRestingIndicator(unitFrame, unit) end
    if isPlayer then UUF:CreateUnitPvPIndicator(unitFrame, unit) end
    if isPlayer then UUF:CreateUnitTotems(unitFrame, unit) end
    if isTarget then UUF:CreateUnitClassificationIndicator(unitFrame, unit) end
    if isTarget then UUF:CreateUnitQuestIndicator(unitFrame, unit) end
    UUF:CreateUnitMouseoverIndicator(unitFrame, unit)
    UUF:CreateUnitTargetGlowIndicator(unitFrame, unit)
    UUF:CreateUnitAuras(unitFrame, unit)
    UUF:CreateUnitTags(unitFrame, unit)
    ApplyScripts(unitFrame)
    if isRaid and not unitFrame.isUUFUnitFrame then
        unitFrame.isUUFUnitFrame = true
        UUF.RAID_FRAMES[#UUF.RAID_FRAMES + 1] = unitFrame
    end
    return unitFrame
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
	RegisterStateDriver(UUF.RAID_CONTAINER, "visibility", "[group:raid] show; hide")
end

function UUF:LayoutRaidFrames()
	local Frame = UUF.db.profile.Units.raid.Frame
	if not UUF.RAID_CONTAINER then return end

	local unitGrowth, groupGrowth = (Frame.GrowthDirection or "RIGHT_DOWN"):match("^(%a+)_(%a+)$")
	unitGrowth = unitGrowth or "RIGHT"
	groupGrowth = groupGrowth or "DOWN"
	local spacing = Frame.Layout[5] or 0
	local headerWidth = (unitGrowth == "UP" or unitGrowth == "DOWN") and Frame.Width or (Frame.Width + spacing) * UUF.MAX_RAID_FRAMES_PER_GROUP - spacing
	local headerHeight = (unitGrowth == "UP" or unitGrowth == "DOWN") and (Frame.Height + spacing) * UUF.MAX_RAID_FRAMES_PER_GROUP - spacing or Frame.Height
	local containerWidth = (groupGrowth == "LEFT" or groupGrowth == "RIGHT") and (headerWidth + spacing) * UUF.MAX_RAID_GROUPS - spacing or headerWidth
	local containerHeight = (groupGrowth == "UP" or groupGrowth == "DOWN") and (headerHeight + spacing) * UUF.MAX_RAID_GROUPS - spacing or headerHeight
	local point = unitGrowth == "RIGHT" and "RIGHT" or unitGrowth == "UP" and "TOP" or unitGrowth == "DOWN" and "BOTTOM" or "LEFT"
	local unitXOffset = unitGrowth == "RIGHT" and -spacing or unitGrowth == "LEFT" and spacing or 0
	local unitYOffset = unitGrowth == "UP" and -spacing or unitGrowth == "DOWN" and spacing or 0

	UUF.RAID_CONTAINER:SetSize(math.max(containerWidth, Frame.Width), math.max(containerHeight, Frame.Height))

	for groupIndex, header in ipairs(UUF.RAID_HEADERS) do
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
		local horizontalOffset = (groupIndex - 1) * (headerWidth + spacing)
		local verticalOffset = (groupIndex - 1) * (headerHeight + spacing)
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
		local firstRole = UnitGroupRolesAssigned(firstFrame.unit)
		local secondRole = UnitGroupRolesAssigned(secondFrame.unit)
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
	local partyFrames = {}
	for _, partyFrame in ipairs(UUF.PARTY_FRAMES) do
		partyFrames[#partyFrames + 1] = partyFrame
	end
	table.sort(partyFrames, SortPartyFrames)
	local frameHeight = Frame.Height
	local spacing = Frame.Layout[5] or 0
	local containerHeight = (frameHeight + spacing) * #partyFrames - spacing
	UUF.PARTY_CONTAINER:SetSize(Frame.Width, math.max(containerHeight, frameHeight))
	for index, partyFrame in ipairs(partyFrames) do
		partyFrame:ClearAllPoints()
		partyFrame:SetSize(Frame.Width, Frame.Height)
		partyFrame:SetFrameStrata(Frame.FrameStrata)
		if Frame.GrowthDirection == "UP" then
			partyFrame:SetPoint("BOTTOMLEFT", UUF.PARTY_CONTAINER, "BOTTOMLEFT", 0, (index - 1) * (frameHeight + spacing))
		else
			partyFrame:SetPoint("TOPLEFT", UUF.PARTY_CONTAINER, "TOPLEFT", 0, -((index - 1) * (frameHeight + spacing)))
		end
	end
end

function UUF:LayoutBossFrames()
    local Frame = UUF.db.profile.Units.boss.Frame
    if #UUF.BOSS_FRAMES == 0 then return end
    local bossFrames = UUF.BOSS_FRAMES
    if Frame.GrowthDirection == "UP" then
        bossFrames = {}
        for i = #UUF.BOSS_FRAMES, 1, -1 do bossFrames[#bossFrames+1] = UUF.BOSS_FRAMES[i] end
    end
    local layoutConfig = UUF.LayoutConfig[Frame.Layout[1]]
    local frameHeight = bossFrames[1]:GetHeight()
    local containerHeight = (frameHeight + Frame.Layout[5]) * #bossFrames - Frame.Layout[5]
    local offsetY = containerHeight * layoutConfig.offsetMultiplier
    if layoutConfig.isCenter then offsetY = offsetY - (frameHeight / 2) end
    local initialAnchor = AnchorUtil.CreateAnchor(layoutConfig.anchor, UIParent, Frame.Layout[2], Frame.Layout[3], Frame.Layout[4] + offsetY)
    AnchorUtil.VerticalLayout(bossFrames, initialAnchor, Frame.Layout[5])
end

function UUF:SpawnUnitFrame(unit)
    local UnitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)]
    if not UnitDB or not UnitDB.Enabled then
        if UnitDB and UnitDB.ForceHideBlizzard then
			if unit == "raid" then UUF:HideBlizzardRaidFrames() else oUF:DisableBlizzard(unit) end
		end
        return
    end
    local FrameDB = UnitDB.Frame
    if unit == "raid" and UnitDB.ForceHideBlizzard then UUF:HideBlizzardRaidFrames() end

    oUF:RegisterStyle(UUF:FetchFrameName(unit), function(unitFrame) UUF:CreateUnitFrame(unitFrame, unit) end)
    oUF:SetActiveStyle(UUF:FetchFrameName(unit))

    if unit == "boss" then
        for i = 1, UUF.MAX_BOSS_FRAMES do
            UUF[unit:upper() .. i] = oUF:Spawn(unit .. i, UUF:FetchFrameName(unit .. i))
            UUF[unit:upper() .. i]:SetSize(FrameDB.Width, FrameDB.Height)
            UUF.BOSS_FRAMES[i] = UUF[unit:upper() .. i]
            UUF[unit:upper() .. i]:SetFrameStrata(FrameDB.FrameStrata)
            UUF:RegisterTargetGlowIndicatorFrame(UUF:FetchFrameName(unit .. i), unit .. i)
            UUF:RegisterRangeFrame(UUF:FetchFrameName(unit .. i), unit .. i)
        end
        UUF:LayoutBossFrames()
    elseif unit == "party" then
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
    elseif unit == "raid" then
		UUF:CreateRaidContainer()
		for groupIndex = 1, UUF.MAX_RAID_GROUPS do
			local headerName = "UUF_RaidHeader" .. groupIndex
			local header = oUF:SpawnHeader(headerName, nil,
				"showRaid", true,
				"showParty", false,
				"showPlayer", true,
				"groupFilter", tostring(groupIndex),
				"groupBy", "GROUP",
				"groupingOrder", tostring(groupIndex),
				"strictFiltering", true
			)
			header:SetParent(UUF.RAID_CONTAINER)
			header:SetVisibility("raid")
			UUF.RAID_HEADERS[groupIndex] = header
		end
		UUF:LayoutRaidFrames()
    else
        UUF[unit:upper()] = oUF:Spawn(unit, UUF:FetchFrameName(unit))
        UUF:RegisterTargetGlowIndicatorFrame(UUF:FetchFrameName(unit), unit)
        UUF[unit:upper()]:SetFrameStrata(FrameDB.FrameStrata)
        if unit == "player" or unit == "target" or unit == "focus" then UUF:RegisterDispelHighlightEvents(UUF[unit:upper()], unit) end
    end

    if unit == "player" or unit == "target" then
        local parentFrame = UUF.db.profile.Units[unit].HealthBar.AnchorToCooldownViewer and _G["UUF_CDMAnchor"] or UIParent
        UUF[unit:upper()]:SetPoint(FrameDB.Layout[1], parentFrame, FrameDB.Layout[2], FrameDB.Layout[3], FrameDB.Layout[4])
        UUF[unit:upper()]:SetSize(FrameDB.Width, FrameDB.Height)
    elseif unit == "targettarget" or unit == "focus" or unit == "focustarget" or unit == "pet" then
        local parentFrame = _G[UUF.db.profile.Units[unit].Frame.AnchorParent] or UIParent
        UUF[unit:upper()]:SetPoint(FrameDB.Layout[1], parentFrame, FrameDB.Layout[2], FrameDB.Layout[3], FrameDB.Layout[4])
        UUF[unit:upper()]:SetSize(FrameDB.Width, FrameDB.Height)
    end
    if unit ~= "player" and unit ~= "boss" and unit ~= "party" and unit ~= "raid" then UUF:RegisterRangeFrame(UUF:FetchFrameName(unit), unit) end
	UUF:CreateMover(unit)

	if UnitDB.Enabled then
        if unit == "boss" then
            for i = 1, UUF.MAX_BOSS_FRAMES do
                RegisterUnitWatch(UUF[unit:upper() .. i])
                UUF[unit:upper() .. i]:Show()
            end
        elseif unit == "party" then
            for i = 1, UUF.MAX_PARTY_FRAMES do RegisterUnitWatch(UUF[unit:upper() .. i]) end
            UUF.PARTY_CONTAINER:Show()
            UUF:LayoutPartyFrames()
        elseif unit == "raid" then
			UUF.RAID_CONTAINER:Show()
			for _, header in ipairs(UUF.RAID_HEADERS) do header:Show() end
			UUF:LayoutRaidFrames()
        else
            RegisterUnitWatch(UUF[unit:upper()])
            UUF[unit:upper()]:Show()
        end
    else
        if unit == "boss" then
            for i = 1, UUF.MAX_BOSS_FRAMES do
                UnregisterUnitWatch(UUF[unit:upper() .. i])
                UUF[unit:upper() .. i]:Hide()
            end
        elseif unit == "party" then
            for i = 1, UUF.MAX_PARTY_FRAMES do UnregisterUnitWatch(UUF[unit:upper() .. i]) UUF[unit:upper() .. i]:Hide() end
            if UUF.PARTYPLAYER then UUF.PARTYPLAYER:Hide() end
            UUF.PARTY_CONTAINER:Hide()
        elseif unit == "raid" then
			for _, header in ipairs(UUF.RAID_HEADERS) do header:Hide() end
			UUF.RAID_CONTAINER:Hide()
        else
            UnregisterUnitWatch(UUF[unit:upper()])
            UUF[unit:upper()]:Hide()
        end
    end

    return UUF[unit:upper()]
end

function UUF:UpdateUnitFrame(unitFrame, unit)
    local UnitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)]
    local isPlayer = unit == "player"
    local isTarget = unit == "target"
    local isFocus = unit == "focus"
    local isTargetTarget = unit == "targettarget"
    local isFocusTarget = unit == "focustarget"
    local isParty = UUF:GetNormalizedUnit(unit) == "party"
    local isRaid = UUF:GetNormalizedUnit(unit) == "raid"

    if UnitDB.CastBar and not isTargetTarget and not isFocusTarget then UUF:UpdateUnitCastBar(unitFrame, unit) end
    UUF:UpdateUnitHealthBar(unitFrame, unit)
    if UnitDB.HealthBar.DispelHighlight and (isPlayer or isTarget or isFocus or isParty or isRaid) then UUF:UpdateUnitDispelHighlight(unitFrame, unit) end
    UUF:UpdateUnitHealPrediction(unitFrame, unit)
    if UnitDB.Portrait and not isTargetTarget and not isFocusTarget then UUF:UpdateUnitPortrait(unitFrame, unit) end
    UUF:UpdateUnitPowerBar(unitFrame, unit)
    if isPlayer then UUF:UpdateUnitAlternativePowerBar(unitFrame, unit) end
    if isPlayer then UUF:UpdateUnitSecondaryPowerBar(unitFrame, unit) end
    UUF:UpdateUnitRaidTargetMarker(unitFrame, unit)
    if isPlayer or isTarget or isParty or isRaid then UUF:UpdateUnitLeaderAssistantIndicator(unitFrame, unit) end
    if isParty or isRaid then UUF:UpdateUnitRoleIndicator(unitFrame, unit) end
    if isPlayer or isTarget then UUF:UpdateUnitCombatIndicator(unitFrame, unit) end
    if isPlayer then UUF:UpdateUnitRestingIndicator(unitFrame, unit) end
    if isPlayer then UUF:UpdateUnitPvPIndicator(unitFrame, unit) end
    if isPlayer then UUF:UpdateUnitTotems(unitFrame, unit) end
    if isTarget then UUF:UpdateUnitClassificationIndicator(unitFrame, unit) end
    if isTarget then UUF:UpdateUnitQuestIndicator(unitFrame, unit) end
    UUF:UpdateUnitMouseoverIndicator(unitFrame, unit)
    UUF:UpdateUnitTargetGlowIndicator(unitFrame, unit)
    UUF:UpdateUnitAuras(unitFrame, unit)
    UUF:UpdateUnitTags()
    unitFrame:SetFrameStrata(UnitDB.Frame.FrameStrata)
end

function UUF:UpdateBossFrames()
    for i in pairs(UUF.BOSS_FRAMES) do
        UUF:UpdateUnitFrame(UUF["BOSS"..i], "boss"..i)
    end
    UUF:CreateTestBossFrames()
    UUF:LayoutBossFrames()
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
end

function UUF:UpdateRaidFrames()
	local UnitDB = UUF.db.profile.Units.raid
	if not UnitDB or not UnitDB.Enabled then
		if UUF.RAID_CONTAINER then UUF.RAID_CONTAINER:Hide() end
		return
	end
	UUF:CreateRaidContainer()
	for i = #(UUF.RangeEvtFrames or {}), 1, -1 do
		if UUF.RangeEvtFrames[i].frame and UUF.RangeEvtFrames[i].frame.isUUFUnitFrame then tremove(UUF.RangeEvtFrames, i) end
	end
	for i = #(UUF.TargetHighlightEvtFrames or {}), 1, -1 do
		if UUF.TargetHighlightEvtFrames[i].frame and UUF.TargetHighlightEvtFrames[i].frame.isUUFUnitFrame then tremove(UUF.TargetHighlightEvtFrames, i) end
	end
	for _, raidFrame in ipairs(UUF.RAID_FRAMES) do
		local unit = raidFrame and (raidFrame.unit or raidFrame:GetAttribute("unit"))
		if unit and unit ~= "raid" then
			raidFrame:SetSize(UnitDB.Frame.Width, UnitDB.Frame.Height)
			raidFrame:SetFrameStrata(UnitDB.Frame.FrameStrata)
			if raidFrame.uufDispelUnit and raidFrame.uufDispelUnit ~= unit then UUF:UnregisterDispelHighlightEvents(raidFrame) end
			UUF:UpdateUnitFrame(raidFrame, unit)
			UUF:RegisterRangeFrame(raidFrame, unit)
			UUF:RegisterTargetGlowIndicatorFrame(raidFrame, unit)
			raidFrame.uufDispelUnit = unit
		elseif raidFrame.uufDispelUnit then
			UUF:UnregisterDispelHighlightEvents(raidFrame)
			raidFrame.uufDispelUnit = nil
		end
	end
	UUF:LayoutRaidFrames()
end

local PartyRosterEventFrame = CreateFrame("Frame")
PartyRosterEventFrame:RegisterEvent("ADDON_LOADED")
PartyRosterEventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
PartyRosterEventFrame:RegisterEvent("PLAYER_ROLES_ASSIGNED")
PartyRosterEventFrame:SetScript("OnEvent", function(_, event, addonName)
	if InCombatLockdown() or not UUF.db then return end
	if event == "ADDON_LOADED" then
		if addonName == "Blizzard_CompactRaidFrames" and UUF.db.profile.Units.raid and UUF.db.profile.Units.raid.ForceHideBlizzard then UUF:HideBlizzardRaidFrames() end
		return
	end
	if event == "GROUP_ROSTER_UPDATE" then
		if UUF.db.profile.Units.raid and UUF.db.profile.Units.raid.ForceHideBlizzard then UUF:HideBlizzardRaidFrames() end
		UUF:UpdatePartyFrames()
		UUF:UpdateRaidFrames()
	elseif event == "PLAYER_ROLES_ASSIGNED" then
		UUF:UpdatePartyFrames()
	end
end)

function UUF:UpdateAllUnitFrames()
	for _, unit in ipairs({"player", "target", "targettarget", "focus", "focustarget", "pet"}) do
		if UUF[unit:upper()] then UUF:UpdateUnitFrame(UUF[unit:upper()], unit) end
	end
	UUF:UpdateBossFrames()
	UUF:UpdatePartyFrames()
	UUF:UpdateRaidFrames()
end
