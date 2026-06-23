local _, UUF = ...
local oUF = UUF.oUF

local function ApplyScripts(unitFrame)
    unitFrame:RegisterForClicks("AnyUp")
    unitFrame:SetAttribute("*type1", "target")
    unitFrame:SetAttribute("*type2", "togglemenu")
    unitFrame:HookScript("OnEnter", UnitFrame_OnEnter)
    unitFrame:HookScript("OnLeave", UnitFrame_OnLeave)
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

    UUF:CreateUnitContainer(unitFrame, unit)
    if UnitDB.CastBar and not isTargetTarget and not isFocusTarget then UUF:CreateUnitCastBar(unitFrame, unit) end
    UUF:CreateUnitHealthBar(unitFrame, unit)
    if UnitDB.HealthBar.DispelHighlight and (isPlayer or isTarget or isFocus or isParty) then UUF:CreateUnitDispelHighlight(unitFrame, unit) end
    UUF:CreateUnitHealPrediction(unitFrame, unit)
    if UnitDB.Portrait and not isTargetTarget and not isFocusTarget then UUF:CreateUnitPortrait(unitFrame, unit) end
    UUF:CreateUnitPowerBar(unitFrame, unit)
    if isPlayer then UUF:CreateUnitAlternativePowerBar(unitFrame, unit) end
    if isPlayer then UUF:CreateUnitSecondaryPowerBar(unitFrame, unit) end
    UUF:CreateUnitRaidTargetMarker(unitFrame, unit)
    if isPlayer or isTarget or isParty then UUF:CreateUnitLeaderAssistantIndicator(unitFrame, unit) end
    if isParty then UUF:CreateUnitRoleIndicator(unitFrame, unit) end
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
    return unitFrame
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
end

local function GetPartyRoleOrder(role)
	local Frame = UUF.db.profile.Units.party.Frame
	for index, orderedRole in ipairs(Frame.RoleOrder or {}) do
		if role == orderedRole then return index end
	end
	return 99
end

local function SortPartyFrames(leftFrame, rightFrame)
	local Frame = UUF.db.profile.Units.party.Frame
	if Frame.SortBy == "NAME" then
		return (UnitName(leftFrame.unit) or leftFrame.unit or "") < (UnitName(rightFrame.unit) or rightFrame.unit or "")
	elseif Frame.SortBy == "ROLE" then
		local leftRole = GetPartyRoleOrder(UnitGroupRolesAssigned(leftFrame.unit))
		local rightRole = GetPartyRoleOrder(UnitGroupRolesAssigned(rightFrame.unit))
		if leftRole ~= rightRole then return leftRole < rightRole end
	end
	return (leftFrame.partyIndex or 0) < (rightFrame.partyIndex or 0)
end

function UUF:LayoutPartyFrames()
	local Frame = UUF.db.profile.Units.party.Frame
	if not UUF.PARTY_CONTAINER or #UUF.PARTY_FRAMES == 0 then return end
	local partyFrames = {}
	for _, partyFrame in ipairs(UUF.PARTY_FRAMES) do
		if partyFrame ~= UUF.PARTYPLAYER or (Frame.ShowPlayer and IsInGroup() and not IsInRaid()) then partyFrames[#partyFrames + 1] = partyFrame end
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
	if UUF.PARTYPLAYER and not InCombatLockdown() then UUF.PARTYPLAYER:SetShown(Frame.ShowPlayer and IsInGroup() and not IsInRaid()) end
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
        if UnitDB and UnitDB.ForceHideBlizzard then oUF:DisableBlizzard(unit) end
        return
    end
    local FrameDB = UnitDB.Frame

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
        UUF.PARTYPLAYER = oUF:Spawn("player", UUF:FetchFrameName("partyplayer"))
        UnregisterUnitWatch(UUF.PARTYPLAYER)
        UUF.PARTYPLAYER.partyIndex = 1
        UUF.PARTYPLAYER:SetParent(UUF.PARTY_CONTAINER)
        UUF.PARTYPLAYER:SetSize(FrameDB.Width, FrameDB.Height)
        UUF.PARTYPLAYER:SetFrameStrata(FrameDB.FrameStrata)
        UUF.PARTY_FRAMES[#UUF.PARTY_FRAMES + 1] = UUF.PARTYPLAYER
        UUF:RegisterTargetGlowIndicatorFrame(UUF.PARTYPLAYER, "partyplayer")
        UUF:RegisterRangeFrame(UUF.PARTYPLAYER, "player")
        UUF:RegisterDispelHighlightEvents(UUF.PARTYPLAYER, "player")
        UUF:LayoutPartyFrames()
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
    if unit ~= "player" and unit ~= "boss" and unit ~= "party" then UUF:RegisterRangeFrame(UUF:FetchFrameName(unit), unit) end
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

    if UnitDB.CastBar and not isTargetTarget and not isFocusTarget then UUF:UpdateUnitCastBar(unitFrame, unit) end
    UUF:UpdateUnitHealthBar(unitFrame, unit)
    if UnitDB.HealthBar.DispelHighlight and (isPlayer or isTarget or isFocus or isParty) then UUF:UpdateUnitDispelHighlight(unitFrame, unit) end
    UUF:UpdateUnitHealPrediction(unitFrame, unit)
    if UnitDB.Portrait and not isTargetTarget and not isFocusTarget then UUF:UpdateUnitPortrait(unitFrame, unit) end
    UUF:UpdateUnitPowerBar(unitFrame, unit)
    if isPlayer then UUF:UpdateUnitAlternativePowerBar(unitFrame, unit) end
    if isPlayer then UUF:UpdateUnitSecondaryPowerBar(unitFrame, unit) end
    UUF:UpdateUnitRaidTargetMarker(unitFrame, unit)
    if isPlayer or isTarget or isParty then UUF:UpdateUnitLeaderAssistantIndicator(unitFrame, unit) end
    if isParty then UUF:UpdateUnitRoleIndicator(unitFrame, unit) end
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

local PartyRosterEventFrame = CreateFrame("Frame")
PartyRosterEventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
PartyRosterEventFrame:RegisterEvent("PLAYER_ROLES_ASSIGNED")
PartyRosterEventFrame:SetScript("OnEvent", function()
	if InCombatLockdown() or not UUF.db or not UUF.PARTY_CONTAINER then return end
	UUF:UpdatePartyFrames()
end)

function UUF:UpdateAllUnitFrames()
	for _, unit in ipairs({"player", "target", "targettarget", "focus", "focustarget", "pet"}) do
		if UUF[unit:upper()] then UUF:UpdateUnitFrame(UUF[unit:upper()], unit) end
	end
	UUF:UpdateBossFrames()
	UUF:UpdatePartyFrames()
end
