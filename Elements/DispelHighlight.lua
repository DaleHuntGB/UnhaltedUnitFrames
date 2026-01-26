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
    if not unitFrame.DispelHighlight then
        local DispelHighlight = unitFrame.Health:CreateTexture(UUF:FetchFrameName(unit) .. "_DispelHighlight", "OVERLAY")
        DispelHighlight:SetAllPoints(unitFrame)
        DispelHighlight:SetTexture("Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Gradient.png")
        DispelHighlight:SetBlendMode("ADD")
        DispelHighlight:SetAlpha(1)
        DispelHighlight:Hide()

        unitFrame.DispelHighlight = DispelHighlight

        if not unitFrame.dispelColorCurve then
            unitFrame.dispelColorCurve = C_CurveUtil.CreateColorCurve()
            unitFrame.dispelColorCurve:SetType(Enum.LuaCurveType.Step)
            UUF:UpdateDispelColorCurve(unitFrame)
        end
    end
end

function UUF:UpdateUnitDispelHighlight(unitFrame, unit)
    if not unitFrame.DispelHighlight then return end

    local LibDispel = UUF.LD
    if not LibDispel then return end

    if unitFrame.dispelColorCurve and unitFrame.dispelColorCurveGeneration ~= UUF.dispelColorGeneration then
        UUF:UpdateDispelColorCurve(unitFrame)
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

    if not unitFrame.DispelHighlightHandler then
        unitFrame.DispelHighlightHandler = CreateFrame("Frame")
        unitFrame.DispelHighlightHandler:SetScript("OnEvent", function(self, event, ...) UUF:UpdateUnitDispelHighlight(unitFrame, unit) end)
    end

    unitFrame.DispelHighlightHandler:RegisterUnitEvent("UNIT_AURA", unit)
    unitFrame.DispelHighlightHandler:RegisterEvent("SPELLS_CHANGED")
    unitFrame.DispelHighlightHandler:RegisterEvent("PLAYER_TALENT_UPDATE")
    unitFrame.DispelHighlightHandler:RegisterEvent("PLAYER_TARGET_CHANGED")
end
