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
    local isPlayer = unit == "player"
    local isTarget = unit == "target"
    local isFocus = unit == "focus"
    local isTargetTarget = unit == "targettarget"
    local isFocusTarget = unit == "focustarget"
    local isParty = UUF:GetNormalizedUnit(unit) == "party"

    UUF:CreateUnitContainer(unitFrame, unit)
    if not isTargetTarget and not isFocusTarget and not isParty then UUF:CreateUnitCastBar(unitFrame, unit) end
    UUF:CreateUnitHealthBar(unitFrame, unit)
    if isPlayer or isTarget or isFocus or isParty then UUF:CreateUnitDispelHighlight(unitFrame, unit) end
    UUF:CreateUnitHealPrediction(unitFrame, unit)
    if not isTargetTarget and not isFocusTarget and not isParty then UUF:CreateUnitPortrait(unitFrame, unit) end
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

    if unit == "party" then
        oUF:RegisterStyle(UUF:FetchFrameName(unit), function(unitFrame)
            local partyIndex = tonumber(unitFrame:GetName():match("UnitButton(%d+)$")) or #UUF.PARTY_FRAMES + 1
            local partyUnit = "party" .. partyIndex
            UUF:CreateUnitFrame(unitFrame, partyUnit)
            UUF.PARTY_FRAMES[partyIndex] = unitFrame
            unitFrame:SetFrameStrata(FrameDB.FrameStrata)
            UUF:RegisterDispelHighlightEvents(unitFrame, partyUnit)
            UUF:RegisterTargetGlowIndicatorFrame(unitFrame, partyUnit)
            UUF:RegisterRangeFrame(unitFrame, partyUnit)
        end)
    else
        oUF:RegisterStyle(UUF:FetchFrameName(unit), function(unitFrame) UUF:CreateUnitFrame(unitFrame, unit) end)
    end
    oUF:SetActiveStyle(UUF:FetchFrameName(unit))

    if unit == "party" then
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
        if FrameDB.SortBy == "ROLE" then
            headerAttributes.groupingOrder = table.concat(FrameDB.RoleOrder, ",") .. ",NONE"
        end
        UUF.PARTY = oUF:SpawnHeader(UUF:FetchFrameName(unit), nil, headerAttributes)
        if FrameDB.SortBy == "ROLE" then UUF.PARTY:SetAttribute("groupBy", "ASSIGNEDROLE") end
        UUF.PARTY:SetPoint(FrameDB.Layout[1], UIParent, FrameDB.Layout[2], FrameDB.Layout[3], FrameDB.Layout[4])
        UUF.PARTY:SetVisibility("party")
    elseif unit == "boss" then
        for i = 1, UUF.MAX_BOSS_FRAMES do
            UUF[unit:upper() .. i] = oUF:Spawn(unit .. i, UUF:FetchFrameName(unit .. i))
            UUF[unit:upper() .. i]:SetSize(FrameDB.Width, FrameDB.Height)
            UUF.BOSS_FRAMES[i] = UUF[unit:upper() .. i]
            UUF[unit:upper() .. i]:SetFrameStrata(FrameDB.FrameStrata)
            UUF:RegisterTargetGlowIndicatorFrame(UUF:FetchFrameName(unit .. i), unit .. i)
            UUF:RegisterRangeFrame(UUF:FetchFrameName(unit .. i), unit .. i)
        end
        UUF:LayoutBossFrames()
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
    if unit ~= "player" and unit ~= "party" then UUF:RegisterRangeFrame(UUF:FetchFrameName(unit), unit) end
	UUF:CreateMover(unit)

    if UnitDB.Enabled then
        if unit ~= "party" then RegisterUnitWatch(UUF[unit:upper()]) end
        if unit == "party" then
            UUF.PARTY:Show()
        elseif unit == "boss" then
            for i = 1, UUF.MAX_BOSS_FRAMES do
                UUF[unit:upper() .. i]:Show()
            end
        else
            UUF[unit:upper()]:Show()
        end
    else
        if unit ~= "party" then UnregisterUnitWatch(UUF[unit:upper()]) end
        if unit == "party" then
            UUF.PARTY:Hide()
        elseif unit == "boss" then
            for i = 1, UUF.MAX_BOSS_FRAMES do
                UUF[unit:upper() .. i]:Hide()
            end
        else
            UUF[unit:upper()]:Hide()
        end
    end

    return UUF[unit:upper()]
end

function UUF:UpdateUnitFrame(unitFrame, unit)
    local UnitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)]
    local isPlayer = unit == "player"
    local isTarget = unit == "target"
    local isTargetTarget = unit == "targettarget"
    local isFocusTarget = unit == "focustarget"
    local isParty = UUF:GetNormalizedUnit(unit) == "party"

    if not isTargetTarget and not isFocusTarget and not isParty then UUF:UpdateUnitCastBar(unitFrame, unit) end
    UUF:UpdateUnitHealthBar(unitFrame, unit)
    UUF:UpdateUnitHealPrediction(unitFrame, unit)
    if not isTargetTarget and not isFocusTarget and not isParty then UUF:UpdateUnitPortrait(unitFrame, unit) end
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
	local FrameDB = UUF.db.profile.Units.party.Frame
	if UUF.PARTY and InCombatLockdown() then return end
	for partyIndex, partyFrame in pairs(UUF.PARTY_FRAMES) do UUF:UpdateUnitFrame(partyFrame, "party" .. partyIndex) end
	if UUF.PARTY then
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
end

function UUF:UpdateAllUnitFrames()
	for _, unit in ipairs({"player", "target", "targettarget", "focus", "focustarget", "pet"}) do
		if UUF[unit:upper()] then UUF:UpdateUnitFrame(UUF[unit:upper()], unit) end
	end
	UUF:UpdateBossFrames()
	UUF:UpdatePartyFrames()
end
