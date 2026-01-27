local _, UUF = ...

function UUF:CreateUnitContainer(unitFrame, unit)
    if not unitFrame.Container then
        local HealthBarDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealthBar
        unitFrame.Container = CreateFrame("Frame", UUF:FetchFrameName(unit) .. "_Container", unitFrame, "BackdropTemplate")
        unitFrame.Container:SetBackdrop(UUF.BACKDROP)
        unitFrame.Container:SetBackdropColor(0, 0, 0, 0)
        if HealthBarDB.ShowBorder then
            unitFrame.Container:SetBackdropBorderColor(unpack(HealthBarDB.BorderColour))
        else
            unitFrame.Container:SetBackdropBorderColor(0, 0, 0, 0)
        end
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
