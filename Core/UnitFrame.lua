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
	if isParty or isRaid then UUF:CreateUnitReadyCheckIndicator(unitFrame, unit) end
	if isParty or isRaid then UUF:CreateUnitResurrectIndicator(unitFrame, unit) end
    if isParty or isRaid then UUF:CreateUnitRoleIndicator(unitFrame, unit) end
    if isParty or isRaid then UUF:CreateUnitPhaseIndicator(unitFrame, unit) end
    if isPlayer or isTarget then UUF:CreateUnitCombatIndicator(unitFrame, unit) end
    if isPlayer then UUF:CreateUnitRestingIndicator(unitFrame, unit) end
    if isPlayer then UUF:CreateUnitPvPIndicator(unitFrame, unit) end
    if isPlayer then UUF:CreateUnitTotems(unitFrame, unit) end
    if isTarget then UUF:CreateUnitClassificationIndicator(unitFrame, unit) end
    if isTarget then UUF:CreateUnitQuestIndicator(unitFrame, unit) end
    UUF:CreateUnitMouseoverIndicator(unitFrame, unit)
    UUF:CreateUnitTargetGlowIndicator(unitFrame, unit)
    UUF:CreateUnitThreatIndicator(unitFrame, unit)
    UUF:CreateUnitAuras(unitFrame, unit)
    UUF:CreateUnitTags(unitFrame, unit)
	if isRaid then
		unitFrame:HookScript("OnAttributeChanged", function(frame, attribute, value)
			if attribute == "unit" and value and UUF.RefreshGroupFrame then UUF:RefreshGroupFrame(frame, value) end
		end)
	end
    ApplyScripts(unitFrame)
    if isRaid then UUF:RegisterRaidFrame(unitFrame) end
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
        if UnitDB and UnitDB.ForceHideBlizzard then
			if unit == "raid" then UUF:HideBlizzardRaidFrames() else oUF:DisableBlizzard(unit) end
		end
        return
    end
    local FrameDB = UnitDB.Frame
    if unit == "raid" and UnitDB.ForceHideBlizzard then UUF:HideBlizzardRaidFrames() end

    if unit == "raid" then
        local raidFrameIndex = 0
        oUF:RegisterStyle(UUF:FetchFrameName(unit), function(unitFrame)
            raidFrameIndex = raidFrameIndex + 1
            UUF:CreateUnitFrame(unitFrame, "raid" .. raidFrameIndex)
        end)
    else
        oUF:RegisterStyle(UUF:FetchFrameName(unit), function(unitFrame) UUF:CreateUnitFrame(unitFrame, unit) end)
    end
    oUF:SetActiveStyle(UUF:FetchFrameName(unit))
	if unit == "party" or unit == "raid" then return UUF:SpawnGroupFrame(unit, FrameDB) end

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
    UUF:UpdateUnitHealPrediction(unitFrame, unit)
    if UnitDB.Portrait and not isTargetTarget and not isFocusTarget then UUF:UpdateUnitPortrait(unitFrame, unit) end
    UUF:UpdateUnitPowerBar(unitFrame, unit)
    if isPlayer then UUF:UpdateUnitAlternativePowerBar(unitFrame, unit) end
    if isPlayer then UUF:UpdateUnitSecondaryPowerBar(unitFrame, unit) end
    UUF:UpdateUnitRaidTargetMarker(unitFrame, unit)
    if isPlayer or isTarget or isParty or isRaid then UUF:UpdateUnitLeaderAssistantIndicator(unitFrame, unit) end
	if isParty or isRaid then UUF:UpdateUnitReadyCheckIndicator(unitFrame, unit) end
	if isParty or isRaid then UUF:UpdateUnitResurrectIndicator(unitFrame, unit) end
    if isParty or isRaid then UUF:UpdateUnitRoleIndicator(unitFrame, unit) end
    if isParty or isRaid then UUF:UpdateUnitPhaseIndicator(unitFrame, unit) end
    if isPlayer or isTarget then UUF:UpdateUnitCombatIndicator(unitFrame, unit) end
    if isPlayer then UUF:UpdateUnitRestingIndicator(unitFrame, unit) end
    if isPlayer then UUF:UpdateUnitPvPIndicator(unitFrame, unit) end
    if isPlayer then UUF:UpdateUnitTotems(unitFrame, unit) end
    if isTarget then UUF:UpdateUnitClassificationIndicator(unitFrame, unit) end
    if isTarget then UUF:UpdateUnitQuestIndicator(unitFrame, unit) end
    UUF:UpdateUnitMouseoverIndicator(unitFrame, unit)
    UUF:UpdateUnitTargetGlowIndicator(unitFrame, unit)
    UUF:UpdateUnitThreatIndicator(unitFrame, unit)
    UUF:UpdateUnitAuras(unitFrame, unit)
	if unit ~= "player" then UUF:RegisterRangeFrame(unitFrame, unit == "partyplayer" and "player" or unit) end
	UUF:RegisterTargetGlowIndicatorFrame(unitFrame, unit)
    unitFrame:SetFrameStrata(UnitDB.Frame.FrameStrata)
end

function UUF:UpdateBossFrames()
    for i in pairs(UUF.BOSS_FRAMES) do
        UUF:UpdateUnitFrame(UUF["BOSS"..i], "boss"..i)
    end
	UUF:UpdateTestEnvironment("boss", "all")
    UUF:LayoutBossFrames()
end

function UUF:UpdateAllUnitFrames()
	for _, unit in ipairs({"player", "target", "targettarget", "focus", "focustarget", "pet"}) do
		if UUF[unit:upper()] then UUF:UpdateUnitFrame(UUF[unit:upper()], unit) end
	end
	UUF:UpdateBossFrames()
	UUF:UpdatePartyFrames()
	UUF:UpdateRaidFrames()
end
