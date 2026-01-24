local _, UUF = ...

function UUF:CreateUnitContainer(unitFrame, unit)
    if not unitFrame.Container then
        local HealthBarDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealthBar
        unitFrame.Container = CreateFrame("Frame", UUF:FetchFrameName(unit) .. "_Container", unitFrame, "BackdropTemplate")
        unitFrame.Container:SetBackdrop(UUF.BACKDROP)
        unitFrame.Container:SetBackdropColor(0, 0, 0, 0)
        unitFrame.Container:SetBackdropBorderColor(HealthBarDB.BorderColor[1] or 0, HealthBarDB.BorderColor[2] or 0, HealthBarDB.BorderColor[3] or 0, HealthBarDB.ShowBorder and 1 or 0)
        unitFrame.Container:SetAllPoints(unitFrame)

        if not unitFrame.HighLevelContainer then
            unitFrame.HighLevelContainer = CreateFrame("Frame", UUF:FetchFrameName(unit) .. "_HighLevelContainer", unitFrame)
            unitFrame.HighLevelContainer:SetPoint("TOPLEFT", unitFrame, "TOPLEFT", 0, 0)
            unitFrame.HighLevelContainer:SetPoint("BOTTOMRIGHT", unitFrame, "BOTTOMRIGHT", 0, 0)
            unitFrame.HighLevelContainer:SetFrameLevel(999)
            unitFrame.HighLevelContainer:SetFrameStrata("MEDIUM")
        end
    end
end
