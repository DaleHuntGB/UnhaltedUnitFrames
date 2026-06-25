local _, UUF = ...

function UUF:CreateThreatIndicatorOverlay(unitFrame, unit)
	local ThreatIndicator = CreateFrame("Frame", UUF:FetchFrameName(unit) .. "_ThreatIndicator", unitFrame.Container, "BackdropTemplate")
	ThreatIndicator:SetFrameLevel(unitFrame.Container:GetFrameLevel() + 4)
	ThreatIndicator:SetBackdrop({ edgeFile = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Glow.tga", edgeSize = 3, insets = {left = -3, right = -3, top = -3, bottom = -3} })
	ThreatIndicator:SetBackdropColor(0, 0, 0, 0)
	ThreatIndicator:SetBackdropBorderColor(1, 1, 1, 1)
	ThreatIndicator:SetPoint("TOPLEFT", unitFrame.Container, "TOPLEFT", -3, 3)
	ThreatIndicator:SetPoint("BOTTOMRIGHT", unitFrame.Container, "BOTTOMRIGHT", 3, -3)
	ThreatIndicator:SetAlpha(0)
	ThreatIndicator:Hide()
	ThreatIndicator.PostUpdate = function(element, _, status, color)
		if status and status > 0 and color then
			element:SetBackdropBorderColor(color:GetRGB())
			element:SetAlpha(1)
		else
			element:SetAlpha(0)
		end
	end

	return ThreatIndicator
end

local function GetThreatDB(unit)
	local normalizedUnit = UUF:GetNormalizedUnit(unit)
	local UnitDB = UUF.db.profile.Units[normalizedUnit]
	local DefaultThreatDB = UUF:GetDefaultDB().profile.Units[normalizedUnit].Indicators.Threat
	if not DefaultThreatDB then return end

	UnitDB.Indicators.Threat = UnitDB.Indicators.Threat or {}
	for key, value in pairs(DefaultThreatDB) do
		if UnitDB.Indicators.Threat[key] == nil then UnitDB.Indicators.Threat[key] = type(value) == "table" and {unpack(value)} or value end
	end
	return UnitDB.Indicators.Threat
end

function UUF:CreateUnitThreatIndicator(unitFrame, unit)
	local ThreatDB = GetThreatDB(unit)
	if not ThreatDB then return end

	local ThreatIndicator = UUF:CreateThreatIndicatorOverlay(unitFrame, unit)
	if ThreatDB.Enabled then
		unitFrame.ThreatIndicator = ThreatIndicator
	else
		if ThreatIndicator then ThreatIndicator:Hide() end
	end

	return ThreatIndicator
end

function UUF:UpdateUnitThreatIndicator(unitFrame, unit)
	local ThreatDB = GetThreatDB(unit)
	if not ThreatDB then return end

	if ThreatDB.Enabled then
		unitFrame.ThreatIndicator = unitFrame.ThreatIndicator or UUF:CreateUnitThreatIndicator(unitFrame, unit)
		if not unitFrame:IsElementEnabled("ThreatIndicator") then unitFrame:EnableElement("ThreatIndicator") end
		if unitFrame.ThreatIndicator then unitFrame.ThreatIndicator:ForceUpdate() end
	elseif unitFrame.ThreatIndicator then
		if unitFrame:IsElementEnabled("ThreatIndicator") then unitFrame:DisableElement("ThreatIndicator") end
		unitFrame.ThreatIndicator:SetAlpha(0)
		unitFrame.ThreatIndicator:Hide()
		unitFrame.ThreatIndicator = nil
	end
end
