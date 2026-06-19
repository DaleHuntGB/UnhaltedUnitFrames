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
	local normalizedUnit = UUF:GetNormalizedUnit(unit)
	local isGroup = normalizedUnit == "party" or normalizedUnit == "raid"

	UUF:CreateUnitContainer(unitFrame, unit)
	if not isTargetTarget and not isFocusTarget and not isGroup then UUF:CreateUnitCastBar(unitFrame, unit) end
	UUF:CreateUnitHealthBar(unitFrame, unit)
	if isPlayer or isTarget or isFocus or isGroup then UUF:CreateUnitDispelHighlight(unitFrame, unit) end
	UUF:CreateUnitHealPrediction(unitFrame, unit)
	if not isTargetTarget and not isFocusTarget and not isGroup then UUF:CreateUnitPortrait(unitFrame, unit) end
	UUF:CreateUnitPowerBar(unitFrame, unit)
	if isPlayer then UUF:CreateUnitAlternativePowerBar(unitFrame, unit) end
	if isPlayer then UUF:CreateUnitSecondaryPowerBar(unitFrame, unit) end
	UUF:CreateUnitRaidTargetMarker(unitFrame, unit)
	if isPlayer or isTarget or isGroup then UUF:CreateUnitLeaderAssistantIndicator(unitFrame, unit) end
	if isGroup then UUF:CreateUnitRoleIndicator(unitFrame, unit) end
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

function UUF:SpawnUnitFrame(unit)
	if unit == "party" then return UUF:SpawnPartyFrames() end
	if unit == "raid" then return UUF:SpawnRaidFrames() end
	if unit == "boss" then return UUF:SpawnBossFrames() end

	local UnitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)]
	if not UnitDB or not UnitDB.Enabled then
		if UnitDB and UnitDB.ForceHideBlizzard then oUF:DisableBlizzard(unit) end
		return
	end
	local FrameDB = UnitDB.Frame

	oUF:RegisterStyle(UUF:FetchFrameName(unit), function(unitFrame) UUF:CreateUnitFrame(unitFrame, unit) end)
	oUF:SetActiveStyle(UUF:FetchFrameName(unit))
	UUF[unit:upper()] = oUF:Spawn(unit, UUF:FetchFrameName(unit))
	UUF:RegisterTargetGlowIndicatorFrame(UUF:FetchFrameName(unit), unit)
	UUF[unit:upper()]:SetFrameStrata(FrameDB.FrameStrata)
	if unit == "player" or unit == "target" or unit == "focus" then UUF:RegisterDispelHighlightEvents(UUF[unit:upper()], unit) end

	if unit == "player" or unit == "target" then
		local parentFrame = UUF.db.profile.Units[unit].HealthBar.AnchorToCooldownViewer and _G["UUF_CDMAnchor"] or UIParent
		UUF[unit:upper()]:SetPoint(FrameDB.Layout[1], parentFrame, FrameDB.Layout[2], FrameDB.Layout[3], FrameDB.Layout[4])
		UUF[unit:upper()]:SetSize(FrameDB.Width, FrameDB.Height)
	elseif unit == "targettarget" or unit == "focus" or unit == "focustarget" or unit == "pet" then
		local parentFrame = _G[FrameDB.AnchorParent] or UIParent
		UUF[unit:upper()]:SetPoint(FrameDB.Layout[1], parentFrame, FrameDB.Layout[2], FrameDB.Layout[3], FrameDB.Layout[4])
		UUF[unit:upper()]:SetSize(FrameDB.Width, FrameDB.Height)
	end
	if unit ~= "player" then UUF:RegisterRangeFrame(UUF:FetchFrameName(unit), unit) end
	UUF:CreateMover(unit)
	RegisterUnitWatch(UUF[unit:upper()])
	UUF[unit:upper()]:Show()
	return UUF[unit:upper()]
end

function UUF:UpdateUnitFrame(unitFrame, unit)
	local normalizedUnit = UUF:GetNormalizedUnit(unit)
	local UnitDB = UUF.db.profile.Units[normalizedUnit]
	local isPlayer = unit == "player"
	local isTarget = unit == "target"
	local isTargetTarget = unit == "targettarget"
	local isFocusTarget = unit == "focustarget"
	local isGroup = normalizedUnit == "party" or normalizedUnit == "raid"

	if not isTargetTarget and not isFocusTarget and not isGroup then UUF:UpdateUnitCastBar(unitFrame, unit) end
	UUF:UpdateUnitHealthBar(unitFrame, unit)
	UUF:UpdateUnitHealPrediction(unitFrame, unit)
	if not isTargetTarget and not isFocusTarget and not isGroup then UUF:UpdateUnitPortrait(unitFrame, unit) end
	UUF:UpdateUnitPowerBar(unitFrame, unit)
	if isPlayer then UUF:UpdateUnitAlternativePowerBar(unitFrame, unit) end
	if isPlayer then UUF:UpdateUnitSecondaryPowerBar(unitFrame, unit) end
	UUF:UpdateUnitRaidTargetMarker(unitFrame, unit)
	if isPlayer or isTarget or isGroup then UUF:UpdateUnitLeaderAssistantIndicator(unitFrame, unit) end
	if isGroup then UUF:UpdateUnitRoleIndicator(unitFrame, unit) end
	if isPlayer or isTarget then UUF:UpdateUnitCombatIndicator(unitFrame, unit) end
	if isPlayer then UUF:UpdateUnitRestingIndicator(unitFrame, unit) end
	if isPlayer then UUF:UpdateUnitPvPIndicator(unitFrame, unit) end
	if isPlayer then UUF:UpdateUnitTotems(unitFrame, unit) end
	if isTarget then UUF:UpdateUnitClassificationIndicator(unitFrame, unit) end
	if isTarget then UUF:UpdateUnitQuestIndicator(unitFrame, unit) end
	UUF:UpdateUnitMouseoverIndicator(unitFrame, unit)
	UUF:UpdateUnitTargetGlowIndicator(unitFrame, unit)
	UUF:UpdateUnitAuras(unitFrame, unit)
	for tagName in pairs(UnitDB.Tags) do UUF:UpdateUnitTag(unitFrame, unit, tagName) end
	unitFrame:SetFrameStrata(UnitDB.Frame.FrameStrata)
end

function UUF:UpdateAllUnitFrames()
	UUF.SEPARATOR = UUF.db.profile.General.Separator or "||"
	UUF.TOT_SEPARATOR = UUF.db.profile.General.ToTSeparator or "»"
	for _, unit in ipairs({"player", "target", "targettarget", "focus", "focustarget", "pet"}) do
		if UUF[unit:upper()] then UUF:UpdateUnitFrame(UUF[unit:upper()], unit) end
	end
	UUF:UpdateBossFrames()
	UUF:UpdatePartyFrames()
	UUF:UpdateRaidFrames()
end
