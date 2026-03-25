local _, UUF = ...

function UUF:CreateUnitPhaseIndicator(unitFrame, unit)
    local PhaseDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Phase
    if not PhaseDB then return end
    if unitFrame.__UUFPhaseIndicator then return unitFrame.__UUFPhaseIndicator end

    local PhaseIndicator = CreateFrame("Frame", UUF:FetchFrameName(unit) .. "_PhaseIndicator", unitFrame.HighLevelContainer)
    PhaseIndicator:SetSize(PhaseDB.Size, PhaseDB.Size)
    PhaseIndicator:SetPoint(PhaseDB.Layout[1], unitFrame.HighLevelContainer, PhaseDB.Layout[2], PhaseDB.Layout[3], PhaseDB.Layout[4])
    PhaseIndicator:EnableMouse(true)
    PhaseIndicator:Hide()

    local Icon = PhaseIndicator:CreateTexture(nil, "OVERLAY")
    Icon:SetAllPoints()
    PhaseIndicator.Icon = Icon
    unitFrame.__UUFPhaseIndicator = PhaseIndicator

    if PhaseDB.Enabled then
        unitFrame.PhaseIndicator = PhaseIndicator
    else
        if unitFrame:IsElementEnabled("PhaseIndicator") then
            unitFrame:DisableElement("PhaseIndicator")
        end
        PhaseIndicator:Hide()
    end

    return PhaseIndicator
end

function UUF:UpdateUnitPhaseIndicator(unitFrame, unit)
    local PhaseDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Phase
    if not PhaseDB then return end

    if PhaseDB.Enabled then
        unitFrame.PhaseIndicator = unitFrame.PhaseIndicator or unitFrame.__UUFPhaseIndicator or UUF:CreateUnitPhaseIndicator(unitFrame, unit)

        if not unitFrame:IsElementEnabled("PhaseIndicator") then
            unitFrame:EnableElement("PhaseIndicator")
        end

        if unitFrame.PhaseIndicator then
            unitFrame.PhaseIndicator:ClearAllPoints()
            unitFrame.PhaseIndicator:SetSize(PhaseDB.Size, PhaseDB.Size)
            unitFrame.PhaseIndicator:SetPoint(PhaseDB.Layout[1], unitFrame.HighLevelContainer, PhaseDB.Layout[2], PhaseDB.Layout[3], PhaseDB.Layout[4])
            unitFrame.PhaseIndicator:ForceUpdate()
        end
    else
        if not unitFrame.PhaseIndicator then return end
        if unitFrame:IsElementEnabled("PhaseIndicator") then
            unitFrame:DisableElement("PhaseIndicator")
        end
        unitFrame.PhaseIndicator:Hide()
        unitFrame.PhaseIndicator = nil
    end
end
