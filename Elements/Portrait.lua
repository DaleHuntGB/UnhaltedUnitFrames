local _, UUF = ...

function UUF:CreateUnitPortrait(unitFrame, unit)
	local PortraitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Portrait
	PortraitDB.Style = "2D"

	local unitPortrait = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit) .. "_Portrait2D", "BACKGROUND")
	unitPortrait:SetSize(PortraitDB.Width, PortraitDB.Height)
	unitPortrait:SetPoint(PortraitDB.Layout[1], unitFrame.HighLevelContainer, PortraitDB.Layout[2], PortraitDB.Layout[3], PortraitDB.Layout[4])
	unitPortrait:SetTexCoord((PortraitDB.Zoom or 0) * 0.5, 1 - (PortraitDB.Zoom or 0) * 0.5, (PortraitDB.Zoom or 0) * 0.5, 1 - (PortraitDB.Zoom or 0) * 0.5)
	unitPortrait.showClass = PortraitDB.UseClassPortrait

    local borderParent = unitFrame.HighLevelContainer
    unitPortrait.Border = CreateFrame("Frame", UUF:FetchFrameName(unit) .. "_PortraitBorder", borderParent, "BackdropTemplate")
    unitPortrait.Border:SetAllPoints(unitPortrait)
    unitPortrait.Border:SetBackdrop(UUF.BACKDROP)
    unitPortrait.Border:SetBackdropColor(0, 0, 0, 0)
    unitPortrait.Border:SetBackdropBorderColor(0, 0, 0, 1)
    unitPortrait.Border:SetFrameLevel(borderParent:GetFrameLevel() + 10)

    if PortraitDB.Enabled then
        unitFrame.Portrait = unitPortrait
        unitFrame.Portrait:Show()
    else
        if unitFrame:IsElementEnabled("Portrait") then
            unitFrame:DisableElement("Portrait")
        end
        unitPortrait:Hide()
        unitPortrait.Border:Hide()
    end

    return unitPortrait
end

function UUF:UpdateUnitPortrait(unitFrame, unit)
	local PortraitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Portrait
	PortraitDB.Style = "2D"

    if PortraitDB.Enabled then
        if unitFrame.Portrait and unitFrame.Portrait.Backdrop then
            if unitFrame:IsElementEnabled("Portrait") then
                unitFrame:DisableElement("Portrait")
            end
            unitFrame.Portrait.Border:Hide()
            unitFrame.Portrait.Border = nil
            unitFrame.Portrait.Backdrop:Hide()
            unitFrame.Portrait.Backdrop = nil
            unitFrame.Portrait:Hide()
            unitFrame.Portrait = nil
        end

        if not unitFrame.Portrait then
            unitFrame.Portrait = UUF:CreateUnitPortrait(unitFrame, unit)
        end

        if not unitFrame:IsElementEnabled("Portrait") then
            unitFrame:EnableElement("Portrait")
        end

        if unitFrame.Portrait then
            unitFrame.Portrait:ClearAllPoints()
            unitFrame.Portrait:SetSize(PortraitDB.Width, PortraitDB.Height)
            unitFrame.Portrait:SetPoint(PortraitDB.Layout[1], unitFrame.HighLevelContainer, PortraitDB.Layout[2], PortraitDB.Layout[3], PortraitDB.Layout[4])
            unitFrame.Portrait:SetTexCoord((PortraitDB.Zoom or 0) * 0.5, 1 - (PortraitDB.Zoom or 0) * 0.5, (PortraitDB.Zoom or 0) * 0.5, 1 - (PortraitDB.Zoom or 0) * 0.5)
            unitFrame.Portrait.showClass = PortraitDB.UseClassPortrait

            unitFrame.Portrait:Show()
            unitFrame.Portrait.Border:Show()
            unitFrame.Portrait:ForceUpdate()
        end
    else
        if not unitFrame.Portrait then return end
        if unitFrame:IsElementEnabled("Portrait") then
            unitFrame:DisableElement("Portrait")
        end
        if unitFrame.Portrait then
            unitFrame.Portrait:Hide()
            unitFrame.Portrait.Border:Hide()
            if unitFrame.Portrait.Backdrop then
                unitFrame.Portrait.Backdrop:Hide()
            end
            unitFrame.Portrait = nil
        end
    end
end
