local _, UUF = ...
local oUF = UUF.oUF

local dispelTypeMap = {
    Magic = oUF.Enum.DispelType.Magic,
    Curse = oUF.Enum.DispelType.Curse,
    Disease = oUF.Enum.DispelType.Disease,
    Poison = oUF.Enum.DispelType.Poison,
    Bleed = oUF.Enum.DispelType.Bleed,
}

function UUF:UpdateDispelColorCurve(unitFrame)
    if not unitFrame.dispelColorCurve then return end
    unitFrame.dispelColorCurve:ClearPoints()
    for dispelType, index in pairs(dispelTypeMap) do
        local color = oUF.colors.dispel[index]
        if color then
            unitFrame.dispelColorCurve:AddPoint(index, color)
        end
    end
    unitFrame.dispelColorCurveGeneration = UUF.dispelColorGeneration
end

function UUF:CreateUnitDispelHighlight(unitFrame, unit)
    local DispelHighlightDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealthBar.DispelHighlight
    if not unitFrame.DispelHighlight then
        local DispelHighlight = unitFrame.Health:CreateTexture(UUF:FetchFrameName(unit) .. "_DispelHighlight", "OVERLAY")
        DispelHighlight:ClearAllPoints()
        if DispelHighlightDB.Style == "GRADIENT" then
            DispelHighlight:SetPoint("TOPLEFT", unitFrame, "TOPLEFT", 1, -1)
            DispelHighlight:SetPoint("BOTTOMRIGHT", unitFrame, "BOTTOMRIGHT", -1, 1)
            DispelHighlight:SetTexture("Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Gradient.png")
            DispelHighlight:SetAlpha(1)
        else
            local barTexture = unitFrame.Health and unitFrame.Health:GetStatusBarTexture()
            if barTexture then
                DispelHighlight:SetAllPoints(barTexture)
            else
                DispelHighlight:SetAllPoints(unitFrame.Health)
            end
            DispelHighlight:SetTexture("Interface\\Buttons\\WHITE8X8")
            DispelHighlight:SetAlpha(0.75)
        end
        DispelHighlight:SetBlendMode("BLEND")
        DispelHighlight:Hide()

        unitFrame.DispelHighlight = DispelHighlight

        if not unitFrame.dispelColorCurve then
            unitFrame.dispelColorCurve = C_CurveUtil.CreateColorCurve()
            unitFrame.dispelColorCurve:SetType(Enum.LuaCurveType.Step)
            UUF:UpdateDispelColorCurve(unitFrame)
        end
    end

    if DispelHighlightDB.Enabled then
        unitFrame.DispelHighlight:Show()
    else
        unitFrame.DispelHighlight:Hide()
    end
end

function UUF:UpdateUnitDispelHighlight(unitFrame, unit)
    if not unitFrame.DispelHighlight then return end
    local DispelHighlightDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealthBar.DispelHighlight
	if unit:find("test", 1, true) then UUF:UnregisterDispelHighlightEvents(unitFrame) unitFrame.DispelHighlight:Hide() return end
    if unitFrame.DispelHighlight then
        if DispelHighlightDB.Enabled then
            UUF:RegisterDispelHighlightEvents(unitFrame, unit)
            unitFrame.DispelHighlight:ClearAllPoints()
            if DispelHighlightDB.Style == "GRADIENT" then
                unitFrame.DispelHighlight:SetPoint("TOPLEFT", unitFrame, "TOPLEFT", 1, -1)
                unitFrame.DispelHighlight:SetPoint("BOTTOMRIGHT", unitFrame, "BOTTOMRIGHT", -1, 1)
                unitFrame.DispelHighlight:SetTexture("Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Gradient.png")
                unitFrame.DispelHighlight:SetAlpha(1)
            else
                local barTexture = unitFrame.Health and unitFrame.Health:GetStatusBarTexture()
                if barTexture then
                    unitFrame.DispelHighlight:SetAllPoints(barTexture)
                else
                    unitFrame.DispelHighlight:SetAllPoints(unitFrame.Health)
                end
                unitFrame.DispelHighlight:SetTexture("Interface\\Buttons\\WHITE8X8")
                unitFrame.DispelHighlight:SetAlpha(0.75)
            end
            unitFrame.DispelHighlight:Show()
        else
            UUF:UnregisterDispelHighlightEvents(unitFrame)
            unitFrame.DispelHighlight:Hide()
        end
    end
end

function UUF:UpdateUnitDispelState(unitFrame, unit, databaseUnit)
    if not unitFrame.DispelHighlight then return end
    if not UUF.db.profile.Units[UUF:GetNormalizedUnit(databaseUnit or unit)].HealthBar.DispelHighlight.Enabled then return end
	if not unit or not UnitExists(unit) then unitFrame.DispelHighlight:Hide() return end

    local LibDispel = UUF.LD
    if not LibDispel then return end

    if unitFrame.dispelColorCurve and unitFrame.dispelColorCurveGeneration ~= UUF.dispelColorGeneration then
        UUF:UpdateDispelColorCurve(unitFrame)
    end

    if not UnitIsUnit(unit, "player") and not UnitIsFriend("player", unit) then
        unitFrame.DispelHighlight:Hide()
        return
    end

    local dispelList = LibDispel:GetMyDispelTypes()
    if not (dispelList.Magic or dispelList.Curse or dispelList.Disease or dispelList.Poison or dispelList.Bleed) then
        unitFrame.DispelHighlight:Hide()
        return
    end

    local bestAura = C_UnitAuras.GetAuraDataByIndex(unit, 1, "HARMFUL|RAID")
    local bestAuraInstanceID = bestAura and bestAura.auraInstanceID or nil

    if bestAuraInstanceID then
        local color = C_UnitAuras.GetAuraDispelTypeColor(unit, bestAuraInstanceID, unitFrame.dispelColorCurve)

        if color then
            unitFrame.DispelHighlight:SetVertexColor(color:GetRGBA())
            unitFrame.DispelHighlight:Show()
        else
            unitFrame.DispelHighlight:Hide()
        end
    else
        unitFrame.DispelHighlight:Hide()
    end
end

function UUF:RegisterDispelHighlightEvents(unitFrame, unit)
    if not unitFrame.DispelHighlight then return end
    if not UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealthBar.DispelHighlight.Enabled then return end

    if not unitFrame.DispelHighlightHandler then
        unitFrame.DispelHighlightHandler = CreateFrame("Frame")
        unitFrame.DispelHighlightHandler:SetScript("OnEvent", function()
            local currentUnit = unitFrame.unit or unitFrame.DispelHighlightUnit
			UUF:UpdateUnitDispelState(unitFrame, currentUnit, unitFrame.DispelHighlightUnit)
        end)
    end

    unitFrame.DispelHighlightUnit = unit
    unitFrame.DispelHighlightHandler:UnregisterAllEvents()
	local normalizedUnit = UUF:GetNormalizedUnit(unit)
    if normalizedUnit == "party" or normalizedUnit == "raid" then
        if not unitFrame.DispelHighlightUnitHooked then
            unitFrame:HookScript("OnAttributeChanged", function(_, attribute, value)
				if attribute ~= "unit" then return end
				unitFrame.DispelHighlightHandler:UnregisterEvent("UNIT_AURA")
				if value then unitFrame.DispelHighlightHandler:RegisterUnitEvent("UNIT_AURA", value) end
				UUF:UpdateUnitDispelState(unitFrame, value, unitFrame.DispelHighlightUnit)
            end)
            unitFrame:HookScript("OnShow", function() UUF:UpdateUnitDispelState(unitFrame, unitFrame.unit, unitFrame.DispelHighlightUnit) end)
            unitFrame.DispelHighlightUnitHooked = true
        end
    end
	local currentUnit = (normalizedUnit == "party" or normalizedUnit == "raid") and (unitFrame.unit or unit) or unit
	if currentUnit then unitFrame.DispelHighlightHandler:RegisterUnitEvent("UNIT_AURA", currentUnit) end
    unitFrame.DispelHighlightHandler:RegisterEvent("SPELLS_CHANGED")
    unitFrame.DispelHighlightHandler:RegisterEvent("PLAYER_TALENT_UPDATE")
    unitFrame.DispelHighlightHandler:RegisterEvent("PLAYER_TARGET_CHANGED")
    UUF:UpdateUnitDispelState(unitFrame, unitFrame.unit or unit, unit)
end

function UUF:UnregisterDispelHighlightEvents(unitFrame)
    if not unitFrame.DispelHighlightHandler then return end

    unitFrame.DispelHighlightHandler:UnregisterAllEvents()
end
