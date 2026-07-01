local _, UUF = ...

local AuraRefreshEvents = {
	target = {"PLAYER_TARGET_CHANGED"},
	targettarget = {"PLAYER_TARGET_CHANGED", "UNIT_TARGET"},
	focus = {"PLAYER_FOCUS_CHANGED"},
	focustarget = {"PLAYER_FOCUS_CHANGED", "UNIT_TARGET"},
	pet = {"UNIT_PET"},
}

local function GetUnitToken(unit)
	return unit == "partyplayer" and "player" or unit
end

local function GetAuraDB(AurasDB, auraKey)
	if auraKey == "Buffs" then return AurasDB.Buffs, "HELPFUL", 135769 end
	if auraKey == "Debuffs" then return AurasDB.Debuffs, "HARMFUL", 135768 end
	if not AurasDB.Custom then return end
	return AurasDB.Custom, UUF:GetCustomAuraFilter(AurasDB.Custom), AurasDB.Custom.Type == "Debuffs" and 135768 or 135769
end

local function GetContainerSize(AuraDB)
	local perRow = math.max(AuraDB.Wrap or AuraDB.Num, 1)
	local rows = math.ceil(AuraDB.Num / perRow)
	local width = (AuraDB.Size + AuraDB.Layout[5]) * perRow - AuraDB.Layout[5]
	local height = (AuraDB.Size + AuraDB.Layout[5]) * rows - AuraDB.Layout[5]
	return math.max(width, 1), math.max(height, 1)
end

local function PositionAuraButton(auraButton, auraContainer, AuraDB, index)
	local perRow = math.max(AuraDB.Wrap or AuraDB.Num, 1)
	local row = math.floor((index - 1) / perRow)
	local column = (index - 1) % perRow
	local x = column * (AuraDB.Size + AuraDB.Layout[5])
	local y = row * (AuraDB.Size + AuraDB.Layout[5])
	if AuraDB.GrowthDirection == "LEFT" then x = -x end
	if AuraDB.WrapDirection == "DOWN" then y = -y end
	auraButton:ClearAllPoints()
	auraButton:SetPoint(AuraDB.Layout[1], auraContainer, AuraDB.Layout[1], x, y)
end

local function CreateBorder(auraButton)
	local top = auraButton:CreateTexture(nil, "OVERLAY")
	local bottom = auraButton:CreateTexture(nil, "OVERLAY")
	local left = auraButton:CreateTexture(nil, "OVERLAY")
	local right = auraButton:CreateTexture(nil, "OVERLAY")
	top:SetPoint("TOPLEFT") top:SetPoint("TOPRIGHT") top:SetHeight(1)
	bottom:SetPoint("BOTTOMLEFT") bottom:SetPoint("BOTTOMRIGHT") bottom:SetHeight(1)
	left:SetPoint("TOPLEFT") left:SetPoint("BOTTOMLEFT") left:SetWidth(1)
	right:SetPoint("TOPRIGHT") right:SetPoint("BOTTOMRIGHT") right:SetWidth(1)
	top:SetColorTexture(0, 0, 0, 1)
	bottom:SetColorTexture(0, 0, 0, 1)
	left:SetColorTexture(0, 0, 0, 1)
	right:SetColorTexture(0, 0, 0, 1)
end

local function StyleAuraButton(auraButton, AuraDB, unit, auraFilter)
	auraButton:SetSize(AuraDB.Size, AuraDB.Size)
	if auraButton.Icon then
		auraButton.Icon:ClearAllPoints()
		auraButton.Icon:SetPoint("TOPLEFT", auraButton, "TOPLEFT", 1, -1)
		auraButton.Icon:SetPoint("BOTTOMRIGHT", auraButton, "BOTTOMRIGHT", -1, 1)
		auraButton.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	end
	if auraButton.Cooldown then
		auraButton.Cooldown:ClearAllPoints()
		auraButton.Cooldown:SetPoint("TOPLEFT", auraButton, "TOPLEFT", 1, -1)
		auraButton.Cooldown:SetPoint("BOTTOMRIGHT", auraButton, "BOTTOMRIGHT", -1, 1)
		auraButton.Cooldown:SetDrawEdge(false)
		auraButton.Cooldown:SetReverse(true)
		UUF:ApplyCooldownText(auraButton.Cooldown, nil, unit)
	end
	if auraButton.Count then
		if AuraDB.Count.HideStacks then
			auraButton:ClearApplicationCount()
			auraButton.Count:Hide()
		else
			local FontsDB = UUF.db.profile.General.Fonts
			auraButton.Count:ClearAllPoints()
			auraButton.Count:SetPoint(AuraDB.Count.Layout[1], auraButton, AuraDB.Count.Layout[2], AuraDB.Count.Layout[3], AuraDB.Count.Layout[4])
			auraButton.Count:SetFont(UUF.Media.Font, AuraDB.Count.FontSize, FontsDB.FontFlag)
			auraButton.Count:SetTextColor(unpack(AuraDB.Count.Colour))
			if FontsDB.Shadow.Enabled then
				auraButton.Count:SetShadowColor(FontsDB.Shadow.Colour[1], FontsDB.Shadow.Colour[2], FontsDB.Shadow.Colour[3], FontsDB.Shadow.Colour[4])
				auraButton.Count:SetShadowOffset(FontsDB.Shadow.XPos, FontsDB.Shadow.YPos)
			else
				auraButton.Count:SetShadowColor(0, 0, 0, 0)
				auraButton.Count:SetShadowOffset(0, 0)
			end
			auraButton:SetApplicationCount(auraButton.Count, {})
			auraButton.Count:Show()
		end
	end
	if auraButton.TypeBorder then
		if AuraDB.ShowType then
			auraButton:SetAuraBorder(auraButton.TypeBorder, {showIcon = false, showWhenHarmful = auraFilter == "HARMFUL", showWhenHelpful = auraFilter == "HELPFUL", style = AuraButtonBorderStyle.Atlas})
		else
			auraButton:ClearAuraBorder()
			auraButton.TypeBorder:Hide()
		end
	end
end

local function CreateAuraButton(auraContainer, AuraDB, unit, auraFilter, index)
	local auraButton = CreateFrame("AuraButton", nil, auraContainer, "CustomAuraButtonTemplate")
	auraButton.Icon = auraButton:CreateTexture(nil, "BORDER")
	auraButton:SetIcon(auraButton.Icon)
	auraButton.Cooldown = CreateFrame("Cooldown", nil, auraButton, "CooldownFrameTemplate")
	auraButton:SetDurationCooldown(auraButton.Cooldown)
	auraButton.Count = auraButton.Cooldown:CreateFontString(nil, "OVERLAY")
	auraButton.TypeBorder = auraButton:CreateTexture(nil, "OVERLAY")
	auraButton.TypeBorder:SetPoint("TOPLEFT", auraButton, "TOPLEFT", 1, -1)
	auraButton.TypeBorder:SetPoint("BOTTOMRIGHT", auraButton, "BOTTOMRIGHT", -1, 1)
	CreateBorder(auraButton)
	StyleAuraButton(auraButton, AuraDB, unit, auraFilter)
	PositionAuraButton(auraButton, auraContainer, AuraDB, index)
	return auraButton
end

local function ConfigureAuraContainer(auraContainer, unitFrame, unit, AuraDB, auraFilter, frameStrata)
	local width, height = GetContainerSize(AuraDB)
	auraContainer:ClearAllPoints()
	auraContainer:SetPoint(AuraDB.Layout[1], unitFrame, AuraDB.Layout[2], AuraDB.Layout[3], AuraDB.Layout[4])
	auraContainer:SetSize(width, height)
	auraContainer:SetFrameStrata(frameStrata)
	auraContainer:SetUnit(GetUnitToken(unit))
	auraContainer:ClearAuraFilters()
	auraContainer:AddAuraFilter(auraFilter, {maxFrameCount = AuraDB.Num})

	if auraContainer.auraFrameCount ~= AuraDB.Num then
		auraContainer:RemoveAllAuraFrames()
		for i = 1, AuraDB.Num do auraContainer:AddAuraFrame(CreateAuraButton(auraContainer, AuraDB, unit, auraFilter, i)) end
		auraContainer.auraFrameCount = AuraDB.Num
	else
		for i = 1, auraContainer:GetAuraFrameCount() do
			local auraButton = auraContainer:GetAuraFrame(i)
			StyleAuraButton(auraButton, AuraDB, unit, auraFilter)
			PositionAuraButton(auraButton, auraContainer, AuraDB, i)
		end
	end

	auraContainer:SetShown(AuraDB.Enabled)
	auraContainer:SetEnabled(AuraDB.Enabled)
	auraContainer:UpdateAllAuras()
end

local function UpdateAuraContainer(unitFrame, unit, auraKey)
	local AurasDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Auras
	local AuraDB, auraFilter = GetAuraDB(AurasDB, auraKey)
	local auraContainer = unitFrame.AuraContainers and unitFrame.AuraContainers[auraKey]
	if not AuraDB or not auraContainer then return end
	ConfigureAuraContainer(auraContainer, unitFrame, unit, AuraDB, auraFilter, AurasDB.FrameStrata)
end

local function RefreshAuraContainers(unitFrame, unit)
	UpdateAuraContainer(unitFrame, unit, "Buffs")
	UpdateAuraContainer(unitFrame, unit, "Debuffs")
	UpdateAuraContainer(unitFrame, unit, "Custom")
end

local function RegisterAuraRefresh(unitFrame, unit)
	if unitFrame.AuraContainerRefresh then return end
	local events = AuraRefreshEvents[UUF:GetNormalizedUnit(unit)] or AuraRefreshEvents[unit]
	if not events then return end
	unitFrame.AuraContainerRefresh = CreateFrame("Frame", nil, unitFrame)
	for _, event in ipairs(events) do unitFrame.AuraContainerRefresh:RegisterEvent(event) end
	unitFrame.AuraContainerRefresh:SetScript("OnEvent", function(_, event, eventUnit)
		if event == "UNIT_TARGET" and eventUnit ~= unit:gsub("target$", "") then return end
		if event == "UNIT_PET" and eventUnit ~= "player" then return end
		RefreshAuraContainers(unitFrame, unit)
	end)
end

local function CreateAuraContainer(unitFrame, unit, auraKey)
	local AurasDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Auras
	local AuraDB, auraFilter = GetAuraDB(AurasDB, auraKey)
	if not AuraDB then return end
	unitFrame.AuraContainers[auraKey] = unitFrame.AuraContainers[auraKey] or CreateFrame("AuraContainer", UUF:FetchFrameName(unit) .. "_" .. auraKey .. "AuraContainer", unitFrame.AuraContainers, "CustomAuraContainerTemplate")
	ConfigureAuraContainer(unitFrame.AuraContainers[auraKey], unitFrame, unit, AuraDB, auraFilter, AurasDB.FrameStrata)
end

local function UpdatePrivateAuraContainer(unitFrame, unit, enableElement)
	local AurasDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Auras
	local PrivateAurasDB = AurasDB.PrivateAuras
	if not PrivateAurasDB then return end
	local privateAuraContainerWidth = PrivateAurasDB.Size * PrivateAurasDB.Num + PrivateAurasDB.Spacing * (PrivateAurasDB.Num - 1)

	if not unitFrame.PrivateAuraContainer then unitFrame.PrivateAuraContainer = CreateFrame("Frame", UUF:FetchFrameName(unit) .. "_PrivateAurasContainer", unitFrame) end
	unitFrame.PrivateAuraContainer:ClearAllPoints()
	unitFrame.PrivateAuraContainer:SetPoint(PrivateAurasDB.Layout[1], unitFrame, PrivateAurasDB.Layout[2], PrivateAurasDB.Layout[3], PrivateAurasDB.Layout[4])
	unitFrame.PrivateAuraContainer:SetSize(math.max(privateAuraContainerWidth, 1), PrivateAurasDB.Size)
	unitFrame.PrivateAuraContainer:SetFrameStrata(PrivateAurasDB.FrameStrata)
	unitFrame.PrivateAuraContainer.size = PrivateAurasDB.Size
	unitFrame.PrivateAuraContainer.spacing = PrivateAurasDB.Spacing
	unitFrame.PrivateAuraContainer.growthX = PrivateAurasDB.GrowthX
	unitFrame.PrivateAuraContainer.growthY = PrivateAurasDB.GrowthY
	unitFrame.PrivateAuraContainer.initialAnchor = PrivateAurasDB.InitialAnchor
	unitFrame.PrivateAuraContainer.num = PrivateAurasDB.Num
	unitFrame.PrivateAuraContainer.maxCols = PrivateAurasDB.Num
	unitFrame.PrivateAuraContainer.borderScale = PrivateAurasDB.BorderScale == -1 and -100 or PrivateAurasDB.BorderScale
	unitFrame.PrivateAuraContainer.disableCooldown = PrivateAurasDB.DisableCooldown
	unitFrame.PrivateAuraContainer.disableCooldownText = PrivateAurasDB.DisableCooldownText

	if PrivateAurasDB.Enabled then
		unitFrame.PrivateAuras = unitFrame.PrivateAuraContainer
		unitFrame.PrivateAuraContainer:Show()
		if enableElement and not unitFrame:IsElementEnabled("PrivateAuras") then unitFrame:EnableElement("PrivateAuras") end
		if unitFrame.PrivateAuraContainer.ForceUpdate then unitFrame.PrivateAuraContainer:ForceUpdate() end
	else
		if enableElement and unitFrame:IsElementEnabled("PrivateAuras") then unitFrame:DisableElement("PrivateAuras") end
		unitFrame.PrivateAuras = nil
		unitFrame.PrivateAuraContainer:Hide()
	end
end

function UUF:CreateUnitAuraContainers(unitFrame, unit)
	if not unitFrame or not unit then return end
	unitFrame.AuraContainers = unitFrame.AuraContainers or CreateFrame("Frame", nil, unitFrame)
	unitFrame.AuraContainers:Show()
	CreateAuraContainer(unitFrame, unit, "Buffs")
	CreateAuraContainer(unitFrame, unit, "Debuffs")
	CreateAuraContainer(unitFrame, unit, "Custom")
	UpdatePrivateAuraContainer(unitFrame, unit)
	RegisterAuraRefresh(unitFrame, unit)
	if UUF.AURA_TEST_MODE then UUF:CreateTestAuraContainers(unitFrame, unit) end
end

function UUF:UpdateUnitAuraContainers(unitFrame, unit)
	if not unitFrame or not unit then return end
	if not unitFrame.AuraContainers then return UUF:CreateUnitAuraContainers(unitFrame, unit) end
	RefreshAuraContainers(unitFrame, unit)
	UpdatePrivateAuraContainer(unitFrame, unit, true)
	if UUF.AURA_TEST_MODE then UUF:CreateTestAuraContainers(unitFrame, unit) end
end

function UUF:ClearUnitAuraContainers(unitFrame)
	if not unitFrame or not unitFrame.AuraContainers then return end
	for _, auraKey in ipairs({"Buffs", "Debuffs", "Custom"}) do
		local auraContainer = unitFrame.AuraContainers[auraKey]
		if auraContainer then
			auraContainer:SetEnabled(false)
			auraContainer:Hide()
		end
	end
end

local function CreateFakeAuraButton(auraContainer)
	local button = CreateFrame("Button", nil, auraContainer, "BackdropTemplate")
	button:SetBackdrop(UUF.BACKDROP)
	button:SetBackdropColor(0, 0, 0, 0)
	button:SetBackdropBorderColor(0, 0, 0, 1)
	button.Icon = button:CreateTexture(nil, "BORDER")
	button.Icon:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
	button.Icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
	button.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	button.Cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
	button.Cooldown:SetAllPoints(button.Icon)
	button.Count = button.Cooldown:CreateFontString(nil, "OVERLAY")
	function button:SetApplicationCount() end
	function button:ClearApplicationCount() end
	function button:SetAuraBorder() end
	function button:ClearAuraBorder() end
	return button
end

local function UpdateTestAuraContainer(unitFrame, unit, auraKey)
	local AurasDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Auras
	local AuraDB, auraFilter, texture = GetAuraDB(AurasDB, auraKey)
	local auraContainer = unitFrame.AuraContainers and unitFrame.AuraContainers[auraKey]
	if not AuraDB or not auraContainer then return end
	if AuraDB.Enabled then
		auraContainer:SetEnabled(false)
		auraContainer:Show()
		for i = 1, AuraDB.Num do
			local button = auraContainer["fake" .. i]
			if not button then button = CreateFakeAuraButton(auraContainer) auraContainer["fake" .. i] = button end
			button:SetSize(AuraDB.Size, AuraDB.Size)
			button:SetFrameStrata(AurasDB.FrameStrata)
			button.Icon:SetTexture(texture)
			StyleAuraButton(button, AuraDB, unit, auraFilter)
			button.Count:SetText(i)
			PositionAuraButton(button, auraContainer, AuraDB, i)
			button:Show()
		end
		for i = AuraDB.Num + 1, (auraContainer.maxFake or AuraDB.Num) do
			local button = auraContainer["fake" .. i]
			if button then button:Hide() end
		end
		auraContainer.maxFake = AuraDB.Num
	else
		auraContainer:Hide()
	end
end

function UUF:CreateTestAuraContainers(unitFrame, unit)
	if not unitFrame or not unit or not unitFrame.AuraContainers then return end
	if UUF.AURA_TEST_MODE then
		unitFrame.AuraContainers:Show()
		UpdateTestAuraContainer(unitFrame, unit, "Buffs")
		UpdateTestAuraContainer(unitFrame, unit, "Debuffs")
		UpdateTestAuraContainer(unitFrame, unit, "Custom")
	else
		for _, auraKey in ipairs({"Buffs", "Debuffs", "Custom"}) do
			local auraContainer = unitFrame.AuraContainers[auraKey]
			if auraContainer then
				for i = 1, (auraContainer.maxFake or 0) do
					local button = auraContainer["fake" .. i]
					if button then button:Hide() end
				end
			end
		end
		UUF:UpdateUnitAuraContainers(unitFrame, unit)
	end
end
