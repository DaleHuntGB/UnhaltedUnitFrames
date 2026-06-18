local _, UUF = ...

function UUF:CreateUnitPortrait(unitFrame, unit)
	local PortraitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Portrait
	local portraitStyle = PortraitDB.Style or "2D"

	if portraitStyle == "3D" then
		local portraitBackdrop = CreateFrame("Frame", UUF:FetchFrameName(unit) .. "_PortraitBackdrop", unitFrame.HighLevelContainer, "BackdropTemplate")
		portraitBackdrop:SetSize(PortraitDB.Width, PortraitDB.Height)
		portraitBackdrop:SetPoint(PortraitDB.Layout[1], unitFrame.HighLevelContainer, PortraitDB.Layout[2], PortraitDB.Layout[3], PortraitDB.Layout[4])
		portraitBackdrop:SetBackdrop(UUF.BACKDROP)
		portraitBackdrop:SetBackdropColor(26/255, 26/255, 26/255, 1)
		portraitBackdrop:SetBackdropBorderColor(0, 0, 0, 0)

		local unitPortrait = CreateFrame("PlayerModel", UUF:FetchFrameName(unit) .. "_Portrait3D", portraitBackdrop)
		unitPortrait:SetAllPoints(portraitBackdrop)
		unitPortrait:SetCamDistanceScale(1)
		unitPortrait:SetPortraitZoom(1)
		unitPortrait:SetPosition(0, 0, 0)
		unitPortrait.Backdrop = portraitBackdrop

		unitPortrait.Border = CreateFrame("Frame", UUF:FetchFrameName(unit) .. "_PortraitBorder", portraitBackdrop, "BackdropTemplate")
		unitPortrait.Border:SetAllPoints(portraitBackdrop)
		unitPortrait.Border:SetBackdrop(UUF.BACKDROP)
		unitPortrait.Border:SetBackdropColor(0, 0, 0, 0)
		unitPortrait.Border:SetBackdropBorderColor(0, 0, 0, 1)
		unitPortrait.Border:SetFrameLevel(portraitBackdrop:GetFrameLevel() + 10)

		if PortraitDB.Enabled then
			unitFrame.Portrait = unitPortrait
			unitFrame.Portrait:Show()
			unitFrame.Portrait.Backdrop:Show()
		else
			if unitFrame:IsElementEnabled("Portrait") then unitFrame:DisableElement("Portrait") end
			unitPortrait:Hide()
			unitPortrait.Border:Hide()
			unitPortrait.Backdrop:Hide()
		end

		return unitPortrait
	end

	local unitPortrait = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit) .. "_Portrait2D", "BACKGROUND")
	unitPortrait:SetSize(PortraitDB.Width, PortraitDB.Height)
	unitPortrait:SetPoint(PortraitDB.Layout[1], unitFrame.HighLevelContainer, PortraitDB.Layout[2], PortraitDB.Layout[3], PortraitDB.Layout[4])
	unitPortrait:SetTexCoord((PortraitDB.Zoom or 0) * 0.5, 1 - (PortraitDB.Zoom or 0) * 0.5, (PortraitDB.Zoom or 0) * 0.5, 1 - (PortraitDB.Zoom or 0) * 0.5)
	unitPortrait.showClass = PortraitDB.UseClassPortrait

	unitPortrait.Border = CreateFrame("Frame", UUF:FetchFrameName(unit) .. "_PortraitBorder", unitFrame.HighLevelContainer, "BackdropTemplate")
	unitPortrait.Border:SetAllPoints(unitPortrait)
	unitPortrait.Border:SetBackdrop(UUF.BACKDROP)
	unitPortrait.Border:SetBackdropColor(0, 0, 0, 0)
	unitPortrait.Border:SetBackdropBorderColor(0, 0, 0, 1)
	unitPortrait.Border:SetFrameLevel(unitFrame.HighLevelContainer:GetFrameLevel() + 10)

	if PortraitDB.Enabled then
		unitFrame.Portrait = unitPortrait
		unitFrame.Portrait:Show()
	else
		if unitFrame:IsElementEnabled("Portrait") then unitFrame:DisableElement("Portrait") end
		unitPortrait:Hide()
		unitPortrait.Border:Hide()
	end

	return unitPortrait
end

function UUF:UpdateUnitPortrait(unitFrame, unit)
	local PortraitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Portrait
	local portraitStyle = PortraitDB.Style or "2D"

	if PortraitDB.Enabled then
		local isPlayerModel = unitFrame.Portrait and unitFrame.Portrait:IsObjectType("PlayerModel")
		if unitFrame.Portrait and ((portraitStyle == "3D" and not isPlayerModel) or (portraitStyle ~= "3D" and isPlayerModel)) then
			if unitFrame:IsElementEnabled("Portrait") then unitFrame:DisableElement("Portrait") end
			unitFrame.Portrait.Border:Hide()
			unitFrame.Portrait.Border = nil
			if unitFrame.Portrait.Backdrop then
				unitFrame.Portrait.Backdrop:Hide()
				unitFrame.Portrait.Backdrop = nil
			end
			unitFrame.Portrait:Hide()
			unitFrame.Portrait = nil
		end

		if not unitFrame.Portrait then unitFrame.Portrait = UUF:CreateUnitPortrait(unitFrame, unit) end
		if not unitFrame:IsElementEnabled("Portrait") then unitFrame:EnableElement("Portrait") end

		if unitFrame.Portrait:IsObjectType("PlayerModel") then
			unitFrame.Portrait.Backdrop:ClearAllPoints()
			unitFrame.Portrait.Backdrop:SetSize(PortraitDB.Width, PortraitDB.Height)
			unitFrame.Portrait.Backdrop:SetPoint(PortraitDB.Layout[1], unitFrame.HighLevelContainer, PortraitDB.Layout[2], PortraitDB.Layout[3], PortraitDB.Layout[4])
			unitFrame.Portrait:SetAllPoints(unitFrame.Portrait.Backdrop)
			unitFrame.Portrait:SetCamDistanceScale(1)
			unitFrame.Portrait:SetPortraitZoom(1)
			unitFrame.Portrait:SetPosition(0, 0, 0)
			unitFrame.Portrait.Backdrop:Show()
		else
			unitFrame.Portrait:ClearAllPoints()
			unitFrame.Portrait:SetSize(PortraitDB.Width, PortraitDB.Height)
			unitFrame.Portrait:SetPoint(PortraitDB.Layout[1], unitFrame.HighLevelContainer, PortraitDB.Layout[2], PortraitDB.Layout[3], PortraitDB.Layout[4])
			unitFrame.Portrait:SetTexCoord((PortraitDB.Zoom or 0) * 0.5, 1 - (PortraitDB.Zoom or 0) * 0.5, (PortraitDB.Zoom or 0) * 0.5, 1 - (PortraitDB.Zoom or 0) * 0.5)
			unitFrame.Portrait.showClass = PortraitDB.UseClassPortrait
		end

		unitFrame.Portrait:Show()
		unitFrame.Portrait.Border:Show()
		unitFrame.Portrait:ForceUpdate()
	else
		if not unitFrame.Portrait then return end
		if unitFrame:IsElementEnabled("Portrait") then unitFrame:DisableElement("Portrait") end
		unitFrame.Portrait:Hide()
		unitFrame.Portrait.Border:Hide()
		if unitFrame.Portrait.Backdrop then unitFrame.Portrait.Backdrop:Hide() end
		unitFrame.Portrait = nil
	end
end
