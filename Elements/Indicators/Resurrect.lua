local _, UUF = ...

function UUF:CreateUnitResurrectIndicator(unitFrame, unit)
    local ResurrectDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Resurrect
    if not ResurrectDB then return end

    local ResurrectIndicator = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit) .. "_ResurrectIndicator", "OVERLAY")
    ResurrectIndicator:SetSize(ResurrectDB.Size, ResurrectDB.Size)
    ResurrectIndicator:SetPoint(ResurrectDB.Layout[1], unitFrame.HighLevelContainer, ResurrectDB.Layout[2], ResurrectDB.Layout[3], ResurrectDB.Layout[4])
    ResurrectIndicator:Hide()

    if ResurrectDB.Enabled then
        unitFrame.ResurrectIndicator = ResurrectIndicator
    else
        if unitFrame:IsElementEnabled("ResurrectIndicator") then
            unitFrame:DisableElement("ResurrectIndicator")
        end
        ResurrectIndicator:Hide()
    end

    return ResurrectIndicator
end

function UUF:UpdateUnitResurrectIndicator(unitFrame, unit)
    local ResurrectDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Resurrect
    if not ResurrectDB then return end

    if ResurrectDB.Enabled then
        unitFrame.ResurrectIndicator = unitFrame.ResurrectIndicator or UUF:CreateUnitResurrectIndicator(unitFrame, unit)

        if not unitFrame:IsElementEnabled("ResurrectIndicator") then
            unitFrame:EnableElement("ResurrectIndicator")
        end

        if unitFrame.ResurrectIndicator then
            unitFrame.ResurrectIndicator:ClearAllPoints()
            unitFrame.ResurrectIndicator:SetSize(ResurrectDB.Size, ResurrectDB.Size)
            unitFrame.ResurrectIndicator:SetPoint(ResurrectDB.Layout[1], unitFrame.HighLevelContainer, ResurrectDB.Layout[2], ResurrectDB.Layout[3], ResurrectDB.Layout[4])
            unitFrame.ResurrectIndicator:ForceUpdate()
        end
    else
        if not unitFrame.ResurrectIndicator then return end
        if unitFrame:IsElementEnabled("ResurrectIndicator") then
            unitFrame:DisableElement("ResurrectIndicator")
        end
        unitFrame.ResurrectIndicator:Hide()
        unitFrame.ResurrectIndicator = nil
    end
end
