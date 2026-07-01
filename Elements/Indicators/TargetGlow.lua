local _, UUF = ...
UUF.TargetHighlightEvtFrames = {}

local unitIsTargetEvtFrame = CreateFrame("Frame")
unitIsTargetEvtFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
unitIsTargetEvtFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
unitIsTargetEvtFrame:RegisterEvent("UNIT_TARGET")
unitIsTargetEvtFrame:SetScript("OnEvent", function(_, event, eventUnit)
	local changedUnit = eventUnit and eventUnit .. "target"
	for frame, unit in pairs(UUF.TargetHighlightEvtFrames) do
		local unitChanged = event == "PLAYER_TARGET_CHANGED" or (event == "PLAYER_FOCUS_CHANGED" and (unit == "focus" or unit == "focustarget")) or unit == changedUnit
		if unitChanged and UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Target.Enabled then UUF:UpdateTargetGlowIndicator(frame, unit) end
	end
end)

function UUF:CreateUnitTargetGlowIndicator(unitFrame, unit)
    local TargetIndicatorDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Target
    if TargetIndicatorDB then
        unitFrame.TargetIndicator = CreateFrame("Frame", UUF:FetchFrameName(unit).."_TargetIndicator", unitFrame.Container, "BackdropTemplate")
        unitFrame.TargetIndicator:SetFrameLevel(unitFrame.Container:GetFrameLevel() + 3)
        unitFrame.TargetIndicator:SetBackdrop({ edgeFile = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Glow.tga", edgeSize = 3, insets = {left = -3, right = -3, top = -3, bottom = -3} })
        unitFrame.TargetIndicator:SetBackdropColor(0, 0, 0, 0)
        unitFrame.TargetIndicator:SetBackdropBorderColor(TargetIndicatorDB.Colour[1], TargetIndicatorDB.Colour[2], TargetIndicatorDB.Colour[3], TargetIndicatorDB.Colour[4])
        unitFrame.TargetIndicator:SetPoint("TOPLEFT", unitFrame.Container, "TOPLEFT", -3, 3)
        unitFrame.TargetIndicator:SetPoint("BOTTOMRIGHT", unitFrame.Container, "BOTTOMRIGHT", 3, -3)
        unitFrame.TargetIndicator:SetAlpha(0)
    end
end

function UUF:UpdateUnitTargetGlowIndicator(unitFrame, unit)
    local TargetIndicatorDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Target
    if unitFrame and unitFrame.TargetIndicator and TargetIndicatorDB then
        unitFrame.TargetIndicator:SetBackdropBorderColor(TargetIndicatorDB.Colour[1], TargetIndicatorDB.Colour[2], TargetIndicatorDB.Colour[3], TargetIndicatorDB.Colour[4])
        UUF:UpdateTargetGlowIndicator(unitFrame, unit)
    end
end

function UUF:UpdateTargetGlowIndicator(unitFrame, unit)
    if unitFrame and unitFrame.TargetIndicator then
        if UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Target.Enabled then
            unitFrame.TargetIndicator:SetAlphaFromBoolean(UnitIsUnit("target", unit == "partyplayer" and "player" or unit), 1, 0)
        else
            unitFrame.TargetIndicator:SetAlpha(0)
        end
    end
end

function UUF:RegisterTargetGlowIndicatorFrame(frameName, unit)
	if not unit or not frameName then return end
	local unitFrame = type(frameName) == "table" and frameName or _G[frameName]
	local DB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)]
	if not unitFrame or not DB or not DB.Indicators.Target then return end
	if DB.Indicators.Target.Enabled then
		UUF.TargetHighlightEvtFrames[unitFrame] = unit
		UUF:UpdateTargetGlowIndicator(unitFrame, unit)
	else
		UUF.TargetHighlightEvtFrames[unitFrame] = nil
		unitFrame.TargetIndicator:SetAlpha(0)
	end
end

function UUF:UnregisterTargetGlowIndicatorFrame(unitFrame)
	if unitFrame then UUF.TargetHighlightEvtFrames[unitFrame] = nil end
end
