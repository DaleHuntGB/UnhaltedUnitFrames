local _, UUF = ...

function UUF:CreateUnitReadyCheckIndicator(unitFrame, unit)
	local ReadyCheckDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.ReadyCheckIndicator
	if not ReadyCheckDB then return end

	local ReadyCheckIndicator = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit) .. "_ReadyCheckIndicator", "OVERLAY")
	ReadyCheckIndicator:SetSize(ReadyCheckDB.Size, ReadyCheckDB.Size)
	ReadyCheckIndicator:SetPoint(ReadyCheckDB.Layout[1], unitFrame.HighLevelContainer, ReadyCheckDB.Layout[2], ReadyCheckDB.Layout[3], ReadyCheckDB.Layout[4])
	ReadyCheckIndicator.readyTexture = UUF.ReadyCheckTextures[ReadyCheckDB.Texture] and UUF.ReadyCheckTextures[ReadyCheckDB.Texture]["READY"]
	ReadyCheckIndicator.notReadyTexture = UUF.ReadyCheckTextures[ReadyCheckDB.Texture] and UUF.ReadyCheckTextures[ReadyCheckDB.Texture]["NOTREADY"]
	ReadyCheckIndicator.waitingTexture = UUF.ReadyCheckTextures[ReadyCheckDB.Texture] and UUF.ReadyCheckTextures[ReadyCheckDB.Texture]["WAITING"]

	if ReadyCheckDB.Enabled then
		unitFrame.ReadyCheckIndicator = ReadyCheckIndicator
	else
		ReadyCheckIndicator:Hide()
	end

	return ReadyCheckIndicator
end

function UUF:UpdateUnitReadyCheckIndicator(unitFrame, unit)
	local ReadyCheckDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.ReadyCheckIndicator
	if not ReadyCheckDB then return end

	if ReadyCheckDB.Enabled then
		unitFrame.ReadyCheckIndicator = unitFrame.ReadyCheckIndicator or UUF:CreateUnitReadyCheckIndicator(unitFrame, unit)
		if not unitFrame:IsElementEnabled("ReadyCheckIndicator") then unitFrame:EnableElement("ReadyCheckIndicator", UUF:GetNormalizedUnit(unit)) end

		unitFrame.ReadyCheckIndicator:ClearAllPoints()
		unitFrame.ReadyCheckIndicator:SetSize(ReadyCheckDB.Size, ReadyCheckDB.Size)
		unitFrame.ReadyCheckIndicator:SetPoint(ReadyCheckDB.Layout[1], unitFrame.HighLevelContainer, ReadyCheckDB.Layout[2], ReadyCheckDB.Layout[3], ReadyCheckDB.Layout[4])
		unitFrame.ReadyCheckIndicator.readyTexture = UUF.ReadyCheckTextures[ReadyCheckDB.Texture] and UUF.ReadyCheckTextures[ReadyCheckDB.Texture]["READY"]
		unitFrame.ReadyCheckIndicator.notReadyTexture = UUF.ReadyCheckTextures[ReadyCheckDB.Texture] and UUF.ReadyCheckTextures[ReadyCheckDB.Texture]["NOTREADY"]
		unitFrame.ReadyCheckIndicator.waitingTexture = UUF.ReadyCheckTextures[ReadyCheckDB.Texture] and UUF.ReadyCheckTextures[ReadyCheckDB.Texture]["WAITING"]
		if unitFrame.ReadyCheckIndicator.ForceUpdate then unitFrame.ReadyCheckIndicator:ForceUpdate() end
	elseif unitFrame.ReadyCheckIndicator then
		if unitFrame:IsElementEnabled("ReadyCheckIndicator") then unitFrame:DisableElement("ReadyCheckIndicator") end
		unitFrame.ReadyCheckIndicator:Hide()
		unitFrame.ReadyCheckIndicator = nil
	end
end
