local _, UUF = ...

local function GetPhaseDB(unit)
	local UnitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)]
	UnitDB.Indicators.Phase = UnitDB.Indicators.Phase or {}
	for key, value in pairs(UUF:GetDefaultDB().profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Phase) do
		if UnitDB.Indicators.Phase[key] == nil then UnitDB.Indicators.Phase[key] = type(value) == "table" and {unpack(value)} or value end
	end
	return UnitDB.Indicators.Phase
end

function UUF:CreateUnitPhaseIndicator(unitFrame, unit)
	local PhaseDB = GetPhaseDB(unit)
	if not PhaseDB then return end

	local PhaseIndicator = CreateFrame("Frame", UUF:FetchFrameName(unit) .. "_PhaseIndicator", unitFrame.HighLevelContainer)
	PhaseIndicator:SetSize(PhaseDB.Size, PhaseDB.Size)
	PhaseIndicator:SetPoint(PhaseDB.Layout[1], unitFrame.HighLevelContainer, PhaseDB.Layout[2], PhaseDB.Layout[3], PhaseDB.Layout[4])
	PhaseIndicator:SetFrameLevel(unitFrame.HighLevelContainer:GetFrameLevel() + 5)
	PhaseIndicator:EnableMouse(true)

	local Icon = PhaseIndicator:CreateTexture(nil, "OVERLAY")
	Icon:SetAllPoints()
	PhaseIndicator.Icon = Icon

	if PhaseDB.Enabled then
		unitFrame.PhaseIndicator = PhaseIndicator
	else
		PhaseIndicator:Hide()
	end

	return PhaseIndicator
end

function UUF:UpdateUnitPhaseIndicator(unitFrame, unit)
	local PhaseDB = GetPhaseDB(unit)
	if not PhaseDB then return end

	if PhaseDB.Enabled then
		unitFrame.PhaseIndicator = unitFrame.PhaseIndicator or UUF:CreateUnitPhaseIndicator(unitFrame, unit)
		if not unitFrame:IsElementEnabled("PhaseIndicator") then unitFrame:EnableElement("PhaseIndicator") end

		unitFrame.PhaseIndicator:ClearAllPoints()
		unitFrame.PhaseIndicator:SetSize(PhaseDB.Size, PhaseDB.Size)
		unitFrame.PhaseIndicator:SetPoint(PhaseDB.Layout[1], unitFrame.HighLevelContainer, PhaseDB.Layout[2], PhaseDB.Layout[3], PhaseDB.Layout[4])
		unitFrame.PhaseIndicator:ForceUpdate()
	elseif unitFrame.PhaseIndicator then
		if unitFrame:IsElementEnabled("PhaseIndicator") then unitFrame:DisableElement("PhaseIndicator") end
		unitFrame.PhaseIndicator:Hide()
		unitFrame.PhaseIndicator = nil
	end
end
