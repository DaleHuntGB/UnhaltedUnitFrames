local _, UUF = ...
local TestData = {}
local oUF = UUF.oUF

local TestClasses = {
	"WARRIOR",
	"PALADIN",
	"HUNTER",
	"ROGUE",
	"PRIEST",
	"DEATHKNIGHT",
	"SHAMAN",
	"MAGE",
	"WARLOCK",
	"MONK",
	"DRUID",
	"DEMONHUNTER",
	"EVOKER",
}

local TestPowerTypes = {0, 1, 2, 3, 6, 8, 11, 13, 17, 18}

for i = 1, UUF.MAX_RAID_FRAMES do
	TestData[i] = {
		class     = TestClasses[((i - 1) % #TestClasses) + 1],
		health    = 8000000 - (((i - 1) % 10 + 1) * 600000),
		maxHealth = 8000000,
		missingHealth = ((i - 1) % 10 + 1) * 600000,
		absorb    = (((i - 1) % 10 + 1) * 300000),
		healAbsorb = (((i - 1) % 10 + 1) * 150000),
		incomingHeal = (((i - 1) % 10 + 1) * 200000),
		maxPower  = 100,
		power     = 100 - (((i - 1) % 10 + 1) * 7),
		powerType = TestPowerTypes[((i - 1) % #TestPowerTypes) + 1],
	}
end

local TestRoles = {"TANK", "HEALER", "DAMAGER", "DAMAGER", "DAMAGER"}
local TestTagOrder = {"TagOne", "TagTwo", "TagThree", "TagFour", "TagFive"}
local TestRoleAtlas = {
	TANK = "UI-LFG-RoleIcon-Tank-Micro-Raid",
	HEALER = "UI-LFG-RoleIcon-Healer-Micro-Raid",
	DAMAGER = "UI-LFG-RoleIcon-DPS-Micro-Raid",
}
local TestPortraits = {
	"achievement_character_human_female",
	"achievement_character_human_male",
	"achievement_character_dwarf_male",
	"achievement_character_dwarf_female",
	"achievement_character_nightelf_female",
}
local TestRaidTargetCoords = {
	{0, 0.25, 0, 0.25},
	{0.25, 0.5, 0, 0.25},
	{0.5, 0.75, 0, 0.25},
	{0.75, 1, 0, 0.25},
	{0, 0.25, 0.25, 0.5},
	{0.25, 0.5, 0.25, 0.5},
	{0.5, 0.75, 0.25, 0.5},
	{0.75, 1, 0.25, 0.5},
}
local function GetTestUnitColour(id, defaultColour, colourByClass, opacity)
	if colourByClass then
		local temporaryClass = TestData[id].class
		local classColour = RAID_CLASS_COLORS[temporaryClass]
		return classColour.r, classColour.g, classColour.b, opacity
	else
		return defaultColour[1], defaultColour[2], defaultColour[3], opacity
	end
end

local function SetTestPredictionBar(bar, value, maxValue, enabled)
	if not bar then return end
	if not enabled then bar:Hide() return end
	bar:SetMinMaxValues(0, maxValue)
	bar:SetValue(value)
	bar:Show()
end

local function ApplyTestTag(fontString, frame, tagDB, text)
	if not fontString or not tagDB then return end
	if tagDB.Tag == "" then fontString:Hide() return end

	local General = UUF.db.profile.General
	fontString:ClearAllPoints()
	fontString:SetPoint(tagDB.Layout[1], frame, tagDB.Layout[2], tagDB.Layout[3], tagDB.Layout[4])
	fontString:SetFont(UUF.Media.Font, tagDB.FontSize, General.Fonts.FontFlag)
	if General.Fonts.Shadow.Enabled then
		fontString:SetShadowColor(unpack(General.Fonts.Shadow.Colour))
		fontString:SetShadowOffset(General.Fonts.Shadow.XPos, General.Fonts.Shadow.YPos)
	else
		fontString:SetShadowColor(0, 0, 0, 0)
		fontString:SetShadowOffset(0, 0)
	end
	fontString:SetTextColor(unpack(tagDB.Colour))
	fontString:SetText(text)
	fontString:Show()
end

local function SetTestTexture(texture, enabled, texturePath, ...)
	if not texture then return end
	if not enabled then texture:Hide() return end
	texture:SetTexture(texturePath)
	if select("#", ...) > 0 then texture:SetTexCoord(...) else texture:SetTexCoord(0, 1, 0, 1) end
	texture:Show()
end

local function ApplyTestGroupFrame(unitFrame, unit, index, displayName, element)
	if not unitFrame or not unit then return end
	if InCombatLockdown() then return end
	local updateAll = not element or element == "all"
	local UnitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)]
	local FrameDB = UnitDB.Frame
	local HealthBarDB = UnitDB.HealthBar
	local HealPredictionDB = UnitDB.HealPrediction
	local PowerBarDB = UnitDB.PowerBar
	local IndicatorDB = UnitDB.Indicators
	local TagsDB = UnitDB.Tags
	local testData = TestData[index]
	local role = TestRoles[((index - 1) % #TestRoles) + 1]
	unitFrame.testRole = role
	if element == "Indicators" then
		UUF:UpdateUnitRaidTargetMarker(unitFrame, unit)
		UUF:UpdateUnitLeaderAssistantIndicator(unitFrame, unit)
		UUF:UpdateUnitReadyCheckIndicator(unitFrame, unit)
		UUF:UpdateUnitResurrectIndicator(unitFrame, unit)
		UUF:UpdateUnitRoleIndicator(unitFrame, unit)
		UUF:UpdateUnitPhaseIndicator(unitFrame, unit)
		UUF:UpdateUnitMouseoverIndicator(unitFrame, unit)
		UUF:UpdateUnitTargetGlowIndicator(unitFrame, unit)
		UUF:UpdateUnitThreatIndicator(unitFrame, unit)
	end

	if updateAll then
		unitFrame:SetAttribute("unit", nil)
		UnregisterUnitWatch(unitFrame)
		if unitFrame:IsElementEnabled("Auras") then unitFrame:DisableElement("Auras") end
		if unitFrame:IsElementEnabled("CustomAuras") then unitFrame:DisableElement("CustomAuras") end
		unitFrame:Show()
	end
	if updateAll or element == "Frame" then
		unitFrame:SetSize(FrameDB.Width, FrameDB.Height)
		unitFrame:SetFrameStrata(FrameDB.FrameStrata)
	end

	if (updateAll or element == "Frame" or element == "HealthBar") and unitFrame.Health then
		if not updateAll then UUF:UpdateUnitHealthBar(unitFrame, unit) end
		unitFrame.Health:SetMinMaxValues(0, testData.maxHealth)
		unitFrame.Health:SetValue(testData.health)
		unitFrame.Health:SetStatusBarColor(GetTestUnitColour(index, HealthBarDB.Foreground, HealthBarDB.ColourByClass, HealthBarDB.ForegroundOpacity))
		if unitFrame.HealthBackground then
			unitFrame.HealthBackground:SetMinMaxValues(0, testData.maxHealth)
			unitFrame.HealthBackground:SetValue(testData.missingHealth)
			unitFrame.HealthBackground:SetStatusBarColor(GetTestUnitColour(index, HealthBarDB.Background, HealthBarDB.ColourBackgroundByClass, HealthBarDB.BackgroundOpacity))
		end
	end

	if (updateAll or element == "Frame" or element == "HealPrediction") and unitFrame.HealthPrediction then
		UUF:UpdateUnitHealPrediction(unitFrame, unit)
		SetTestPredictionBar(unitFrame.HealthPrediction.damageAbsorb, testData.absorb, testData.maxHealth, HealPredictionDB.Absorbs.Enabled)
		SetTestPredictionBar(unitFrame.HealthPrediction.healAbsorb, testData.healAbsorb, testData.maxHealth, HealPredictionDB.HealAbsorbs.Enabled)
		SetTestPredictionBar(unitFrame.HealthPrediction.healingPlayer, testData.incomingHeal, testData.maxHealth, HealPredictionDB.IncomingHeal.Enabled)
		if unitFrame.HealthPrediction.overDamageAbsorb then
			local showOverAbsorb = HealPredictionDB.Absorbs.Enabled and HealPredictionDB.Absorbs.ShowOverAbsorb and HealPredictionDB.Absorbs.Position == "ATTACH"
			SetTestPredictionBar(unitFrame.HealthPrediction.overDamageAbsorb, testData.absorb, testData.maxHealth, showOverAbsorb)
			if unitFrame.HealthPrediction.overDamageAbsorb.Clip then
				if showOverAbsorb then unitFrame.HealthPrediction.overDamageAbsorb.Clip:Show() else unitFrame.HealthPrediction.overDamageAbsorb.Clip:Hide() end
			end
		end
	end

	if updateAll or element == "Frame" or element == "PowerBar" then
		if not updateAll then UUF:UpdateUnitPowerBar(unitFrame, unit) end
		if unitFrame.Power then
			if PowerBarDB.OnlyShowHealers and role ~= "HEALER" then
				unitFrame.Power:Hide()
				if unitFrame.Power.Background then unitFrame.Power.Background:Hide() end
			else
				unitFrame.Power:SetMinMaxValues(0, testData.maxPower)
				unitFrame.Power:SetValue(testData.power)
				if PowerBarDB.ColourByType and oUF.colors.power[testData.powerType] then
					local colour = oUF.colors.power[testData.powerType]
					unitFrame.Power:SetStatusBarColor(colour.r, colour.g, colour.b)
				else
					unitFrame.Power:SetStatusBarColor(unpack(PowerBarDB.Foreground))
				end
				unitFrame.Power:Show()
				if unitFrame.Power.Background then unitFrame.Power.Background:Show() end
			end
		end
	end

	if (updateAll or element == "Indicators") and unitFrame.GroupRoleIndicator and IndicatorDB.Role then
		local roleTexture = UUF.RoleTextures[IndicatorDB.Role.Texture] and UUF.RoleTextures[IndicatorDB.Role.Texture][role]
		local showRole = (role == "TANK" and IndicatorDB.Role.ShowTank ~= false) or (role == "HEALER" and IndicatorDB.Role.ShowHealer ~= false) or (role == "DAMAGER" and IndicatorDB.Role.ShowDamager ~= false)
		if IndicatorDB.Role.Enabled and showRole and IndicatorDB.Role.Texture == "Default" and TestRoleAtlas[role] then
			unitFrame.GroupRoleIndicator:SetAtlas(TestRoleAtlas[role])
			unitFrame.GroupRoleIndicator:SetTexCoord(0, 1, 0, 1)
			unitFrame.GroupRoleIndicator:Show()
		else
			SetTestTexture(unitFrame.GroupRoleIndicator, IndicatorDB.Role.Enabled and showRole and roleTexture, roleTexture)
		end
	end

	if (updateAll or element == "Indicators") and unitFrame.LeaderIndicator and IndicatorDB.LeaderAssistantIndicator then
		if IndicatorDB.LeaderAssistantIndicator.Enabled then
			unitFrame.LeaderIndicator:SetAtlas("UI-HUD-UnitFrame-Player-Group-LeaderIcon")
			unitFrame.LeaderIndicator:SetTexCoord(0, 1, 0, 1)
			unitFrame.LeaderIndicator:Show()
		else
			unitFrame.LeaderIndicator:Hide()
		end
	end
	if (updateAll or element == "Indicators") and unitFrame.AssistantIndicator and IndicatorDB.LeaderAssistantIndicator then SetTestTexture(unitFrame.AssistantIndicator, IndicatorDB.LeaderAssistantIndicator.Enabled and index == 2, "Interface\\GroupFrame\\UI-Group-AssistantIcon") end

	if (updateAll or element == "Indicators") and unitFrame.PhaseIndicator and IndicatorDB.Phase then
		if IndicatorDB.Phase.Enabled then
			unitFrame.PhaseIndicator.Icon:SetAtlas("groupfinder-icon-phased")
			unitFrame.PhaseIndicator:Show()
		else
			unitFrame.PhaseIndicator:Hide()
		end
	end
	if (updateAll or element == "Indicators") and unitFrame.ReadyCheckIndicator and IndicatorDB.ReadyCheckIndicator then
		if IndicatorDB.ReadyCheckIndicator.Enabled and index % 2 == 1 then
			local readyCheckStatus = index % 3 == 0 and "NOTREADY" or index % 3 == 1 and "READY" or "WAITING"
			local readyCheckTexture = UUF.ReadyCheckTextures[IndicatorDB.ReadyCheckIndicator.Texture] and UUF.ReadyCheckTextures[IndicatorDB.ReadyCheckIndicator.Texture][readyCheckStatus]
			if readyCheckTexture then
				unitFrame.ReadyCheckIndicator:SetTexture(readyCheckTexture)
			else
				unitFrame.ReadyCheckIndicator:SetAtlas(readyCheckStatus == "NOTREADY" and "UI-LFG-DeclineMark-Raid" or readyCheckStatus == "READY" and "UI-LFG-ReadyMark-Raid" or "UI-LFG-PendingMark-Raid")
			end
			unitFrame.ReadyCheckIndicator:Show()
		else
			unitFrame.ReadyCheckIndicator:Hide()
		end
	end
	if (updateAll or element == "Indicators") and unitFrame.ResurrectIndicator and IndicatorDB.ResurrectIndicator then
		if IndicatorDB.ResurrectIndicator.Enabled and index % 2 == 0 then
			unitFrame.ResurrectIndicator:SetAtlas("RaidFrame-Icon-Rez")
			unitFrame.ResurrectIndicator:Show()
		else
			unitFrame.ResurrectIndicator:Hide()
		end
	end

	if (updateAll or element == "Indicators") and unitFrame.RaidTargetIndicator and IndicatorDB.RaidTargetMarker and TestRaidTargetCoords[((index - 1) % #TestRaidTargetCoords) + 1] then
		local coords = TestRaidTargetCoords[((index - 1) % #TestRaidTargetCoords) + 1]
		SetTestTexture(unitFrame.RaidTargetIndicator, IndicatorDB.RaidTargetMarker.Enabled, "Interface\\TargetingFrame\\UI-RaidTargetingIcons", unpack(coords))
	end

	if (updateAll or element == "Indicators") and unitFrame.TargetIndicator and IndicatorDB.Target then
		unitFrame.TargetIndicator:SetAlpha(IndicatorDB.Target.Enabled and index == 1 and 1 or 0)
	end
	if (updateAll or element == "Indicators") and unitFrame.ThreatIndicator and IndicatorDB.Threat then
		local threatColour = UUF.db.profile.General.Colours.Threat[((index - 1) % 3) + 1]
		if IndicatorDB.Threat.Enabled and index % 5 == 0 then
			unitFrame.ThreatIndicator:SetBackdropBorderColor(threatColour[1], threatColour[2], threatColour[3], threatColour[4] or 1)
			unitFrame.ThreatIndicator:SetAlpha(1)
			unitFrame.ThreatIndicator:Show()
		else
			unitFrame.ThreatIndicator:SetAlpha(0)
			unitFrame.ThreatIndicator:Hide()
		end
	end

	if updateAll or element == "Auras" then
		local auraTestMode = UUF.AURA_TEST_MODE
		if not updateAll then
			UUF.AURA_TEST_MODE = false
			UUF:UpdateUnitAuras(unitFrame, unit)
		end
		UUF.AURA_TEST_MODE = auraTestMode
		UUF:CreateTestAuras(unitFrame, unit)
	end
	if updateAll or element == "Tags" then
		for tagIndex, tagName in ipairs(TestTagOrder) do ApplyTestTag(unitFrame.Tags and unitFrame.Tags[tagName], unitFrame, TagsDB[tagName], tagIndex == 1 and displayName or "Tag " .. tagIndex) end
	end
end

local function RestoreGroupFrame(unitFrame, unit)
	if not unitFrame or not unit then return end
	if InCombatLockdown() then return end
	unitFrame:SetAttribute("unit", unit == "partyplayer" and "player" or unit)
	RegisterUnitWatch(unitFrame)
	local auraTestMode = UUF.AURA_TEST_MODE
	UUF.AURA_TEST_MODE = false
	UUF:CreateTestAuras(unitFrame, unit)
	UUF.AURA_TEST_MODE = auraTestMode
	UUF:UpdateUnitFrame(unitFrame, unit)
end

function UUF:CreateRaidTestFrames()
	if #UUF.RAID_TEST_FRAMES == UUF.MAX_RAID_FRAMES then return end
	local activeStyle = oUF:GetActiveStyle()
	oUF:SetActiveStyle(UUF:FetchFrameName("raid"))
	for i = 1, UUF.MAX_RAID_FRAMES do
		if not UUF.RAID_TEST_FRAMES[i] then
			local raidFrame = oUF:Spawn("raid" .. i, "UUF_RaidTest" .. i)
			raidFrame.isTestFrame = true
			raidFrame.testIndex = i
			raidFrame:SetParent(UUF.RAID_CONTAINER)
			UUF.RAID_TEST_FRAMES[i] = raidFrame
		end
	end
	if activeStyle then oUF:SetActiveStyle(activeStyle) end
end

function UUF:LayoutRaidTestFrames()
	local Frame = UUF.db.profile.Units.raid.Frame
	if not UUF.RAID_CONTAINER then return end
	UUF.RAID_CONTAINER:ClearAllPoints()
	UUF.RAID_CONTAINER:SetPoint(Frame.Layout[1], UIParent, Frame.Layout[2], Frame.Layout[3], Frame.Layout[4])
	UUF.RAID_CONTAINER:SetFrameStrata(Frame.FrameStrata)

	local unitGrowth, groupGrowth = (Frame.GrowthDirection or "RIGHT_DOWN"):match("^(%a+)_(%a+)$")
	unitGrowth = unitGrowth or "RIGHT"
	groupGrowth = groupGrowth or "DOWN"
	local spacing = Frame.Layout[5] or 0
	local headerWidth = (unitGrowth == "UP" or unitGrowth == "DOWN") and Frame.Width or (Frame.Width + spacing) * UUF.MAX_RAID_FRAMES_PER_GROUP - spacing
	local headerHeight = (unitGrowth == "UP" or unitGrowth == "DOWN") and (Frame.Height + spacing) * UUF.MAX_RAID_FRAMES_PER_GROUP - spacing or Frame.Height
	local shownGroups = 0
	for groupIndex = 1, UUF.MAX_RAID_GROUPS do if not Frame.Groups or Frame.Groups[groupIndex] then shownGroups = shownGroups + 1 end end
	local containerWidth = (groupGrowth == "LEFT" or groupGrowth == "RIGHT") and (headerWidth + spacing) * shownGroups - spacing or headerWidth
	local containerHeight = (groupGrowth == "UP" or groupGrowth == "DOWN") and (headerHeight + spacing) * shownGroups - spacing or headerHeight
	UUF.RAID_CONTAINER:SetSize(math.max(containerWidth, Frame.Width), math.max(containerHeight, Frame.Height))
	local horizontalAnchor = groupGrowth == "LEFT" and "RIGHT" or groupGrowth == "RIGHT" and "LEFT" or unitGrowth == "RIGHT" and "RIGHT" or "LEFT"
	local verticalAnchor = groupGrowth == "UP" and "BOTTOM" or groupGrowth == "DOWN" and "TOP" or unitGrowth == "DOWN" and "BOTTOM" or "TOP"
	local anchor = verticalAnchor .. horizontalAnchor

	local shownGroupIndex = 0
	for groupIndex = 1, UUF.MAX_RAID_GROUPS do
		local showGroup = not Frame.Groups or Frame.Groups[groupIndex]
		if showGroup then shownGroupIndex = shownGroupIndex + 1 end
		local horizontalOffset = (shownGroupIndex - 1) * (headerWidth + spacing)
		local verticalOffset = (shownGroupIndex - 1) * (headerHeight + spacing)
		local headerXOffset = groupGrowth == "RIGHT" and horizontalOffset or groupGrowth == "LEFT" and -horizontalOffset or 0
		local headerYOffset = groupGrowth == "UP" and verticalOffset or groupGrowth == "DOWN" and -verticalOffset or 0

		for unitIndex = 1, UUF.MAX_RAID_FRAMES_PER_GROUP do
			local raidIndex = ((groupIndex - 1) * UUF.MAX_RAID_FRAMES_PER_GROUP) + unitIndex
			local raidFrame = UUF.RAID_TEST_FRAMES[raidIndex]
			if raidFrame then
				raidFrame:ClearAllPoints()
				raidFrame:SetSize(Frame.Width, Frame.Height)
				if showGroup then
					local unitOffset = (unitIndex - 1) * (Frame[(unitGrowth == "UP" or unitGrowth == "DOWN") and "Height" or "Width"] + spacing)
					local xOffset = headerXOffset + (unitGrowth == "RIGHT" and -unitOffset or unitGrowth == "LEFT" and unitOffset or 0)
					local yOffset = headerYOffset + (unitGrowth == "UP" and -unitOffset or unitGrowth == "DOWN" and unitOffset or 0)
					raidFrame:SetPoint(anchor, UUF.RAID_CONTAINER, anchor, xOffset, yOffset)
					raidFrame:Show()
				else
					raidFrame:Hide()
				end
			end
		end
	end
end

function UUF:EnableTestGroupFrames(unit)
	if InCombatLockdown() then return end
	if unit == "party" then
		local UnitDB = UUF.db.profile.Units.party
		if not UnitDB or not UnitDB.Enabled then if UUF.PARTY_CONTAINER then UUF.PARTY_CONTAINER:Hide() end return end
		UUF:CreatePartyContainer()
		UnregisterStateDriver(UUF.PARTY_CONTAINER, "visibility")
		UUF.PARTY_CONTAINER:Show()
		UUF:UpdateTestEnvironment("party", "all")
	elseif unit == "raid" then
		local UnitDB = UUF.db.profile.Units.raid
		if not UnitDB or not UnitDB.Enabled then if UUF.RAID_CONTAINER then UUF.RAID_CONTAINER:Hide() end return end
		UUF:CreateRaidContainer()
		UUF:CreateRaidTestFrames()
		for _, header in ipairs(UUF.RAID_HEADERS) do header:Hide() end
		UUF:UpdateTestEnvironment("raid", "all")
		UUF.RAID_CONTAINER:Show()
	end
end

local function UpdatePartyTestEnvironment(element)
	if InCombatLockdown() then return end
	if not UUF.PARTY_TEST_MODE then
		if element ~= "all" then return end
		for i = 1, UUF.MAX_PARTY_FRAMES do if UUF["PARTY" .. i] then RestoreGroupFrame(UUF["PARTY" .. i], "party" .. i) end end
		if UUF.PARTYPLAYER then RestoreGroupFrame(UUF.PARTYPLAYER, "partyplayer") end
		UUF:UpdatePartyFrames()
		UUF:UpdateUnitTags("party")
		return
	end
	local UnitDB = UUF.db.profile.Units.party
	for i = 1, UUF.MAX_PARTY_FRAMES do
		if UUF["PARTY" .. i] then ApplyTestGroupFrame(UUF["PARTY" .. i], "party" .. i, i + (UnitDB.Frame.ShowPlayer and 1 or 0), "Party" .. (i + (UnitDB.Frame.ShowPlayer and 1 or 0)), element) end
	end
	if UUF.PARTYPLAYER then ApplyTestGroupFrame(UUF.PARTYPLAYER, "partyplayer", 1, "Party1", element) end
	if element == "all" or element == "Frame" or element == "HealthBar" then UUF:LayoutPartyFrames() end
end

local function UpdateRaidTestEnvironment(element)
	if InCombatLockdown() then return end
	if not UUF.RAID_TEST_MODE then
		if element ~= "all" then return end
		for i, raidFrame in ipairs(UUF.RAID_TEST_FRAMES) do
			raidFrame:SetAttribute("unit", "raid" .. i)
			UnregisterUnitWatch(raidFrame)
			local auraTestMode = UUF.AURA_TEST_MODE
			UUF.AURA_TEST_MODE = false
			UUF:CreateTestAuras(raidFrame, "raid" .. i)
			UUF.AURA_TEST_MODE = auraTestMode
			raidFrame:Hide()
		end
		for _, header in ipairs(UUF.RAID_HEADERS) do header:Show() end
		UUF:UpdateRaidFrames()
		UUF:UpdateUnitTags("raid")
		return
	end
	for i, raidFrame in ipairs(UUF.RAID_TEST_FRAMES) do ApplyTestGroupFrame(raidFrame, "raid" .. i, i, "Raid " .. i, element) end
	if element == "all" or element == "Frame" or element == "HealthBar" then UUF:LayoutRaidTestFrames() end
end

local function UpdateBossTestEnvironment(element)
	if InCombatLockdown() then return end
	local updateAll = not element or element == "all"
	local BossDB = UUF.db.profile.Units.boss
	local BuffsDB = BossDB.Auras.Buffs
	local DebuffsDB = BossDB.Auras.Debuffs
	local CustomDB = BossDB.Auras.Custom
	local TagsDB = BossDB.Tags
	local HealPredictionDB = BossDB.HealPrediction
	if UUF.BOSS_TEST_MODE then
		for i, BossFrame in ipairs(UUF.BOSS_FRAMES) do
			if element == "Portrait" then UUF:UpdateUnitPortrait(BossFrame, "boss" .. i) end
			if element == "Frame" or element == "CastBar" then UUF:UpdateUnitCastBar(BossFrame, "boss" .. i) end
			if element == "Indicators" then
				UUF:UpdateUnitRaidTargetMarker(BossFrame, "boss" .. i)
				UUF:UpdateUnitMouseoverIndicator(BossFrame, "boss" .. i)
				UUF:UpdateUnitTargetGlowIndicator(BossFrame, "boss" .. i)
			end
			if updateAll then
				BossFrame:SetAttribute("unit", nil)
				UnregisterUnitWatch(BossFrame)
				if BossFrame:IsElementEnabled("Auras") then BossFrame:DisableElement("Auras") end
				if BossFrame:IsElementEnabled("CustomAuras") then BossFrame:DisableElement("CustomAuras") end
				if BossDB.Enabled then BossFrame:Show() else BossFrame:Hide() end
			end
			if updateAll or element == "Frame" then BossFrame:SetFrameStrata(BossDB.Frame.FrameStrata) end

			if (updateAll or element == "Frame" or element == "HealthBar") and BossFrame.Health then
				if not updateAll then UUF:UpdateUnitHealthBar(BossFrame, "boss" .. i) end
				local HealthBarDB = BossDB.HealthBar
				BossFrame.Health:SetMinMaxValues(0, TestData[i].maxHealth)
				BossFrame.Health:SetValue(TestData[i].health)
				BossFrame.HealthBackground:SetMinMaxValues(0, TestData[i].maxHealth)
				BossFrame.HealthBackground:SetValue(TestData[i].missingHealth)
				BossFrame.HealthBackground:SetStatusBarColor(GetTestUnitColour(i, HealthBarDB.Background, HealthBarDB.ColourBackgroundByClass, HealthBarDB.BackgroundOpacity))
				BossFrame.Health:SetStatusBarColor(GetTestUnitColour(i, HealthBarDB.Foreground, HealthBarDB.ColourByClass, HealthBarDB.ForegroundOpacity))
			end

			if (updateAll or element == "Frame" or element == "HealPrediction") and BossFrame.HealthPrediction then
				UUF:UpdateUnitHealPrediction(BossFrame, "boss" .. i)
				local maxHealth = TestData[i].maxHealth
				SetTestPredictionBar(BossFrame.HealthPrediction.damageAbsorb, TestData[i].absorb, maxHealth, HealPredictionDB.Absorbs.Enabled)
				SetTestPredictionBar(BossFrame.HealthPrediction.healAbsorb, TestData[i].healAbsorb, maxHealth, HealPredictionDB.HealAbsorbs.Enabled)
				SetTestPredictionBar(BossFrame.HealthPrediction.healingPlayer, TestData[i].incomingHeal, maxHealth, HealPredictionDB.IncomingHeal.Enabled)
				if BossFrame.HealthPrediction.overDamageAbsorb then
					local showOverAbsorb = HealPredictionDB.Absorbs.Enabled and HealPredictionDB.Absorbs.ShowOverAbsorb and HealPredictionDB.Absorbs.Position == "ATTACH"
					SetTestPredictionBar(BossFrame.HealthPrediction.overDamageAbsorb, TestData[i].absorb, maxHealth, showOverAbsorb)
					if BossFrame.HealthPrediction.overDamageAbsorb.Clip then
						if showOverAbsorb then BossFrame.HealthPrediction.overDamageAbsorb.Clip:Show() else BossFrame.HealthPrediction.overDamageAbsorb.Clip:Hide() end
					end
				end
			end

			if (updateAll or element == "Portrait") and BossFrame.Portrait then
				if BossFrame.Portrait:IsObjectType("PlayerModel") then
					BossFrame.Portrait:ClearModel()
					BossFrame.Portrait:SetUnit("player")
				else
					BossFrame.Portrait:SetTexture("Interface\\ICONS\\" .. TestPortraits[i])
				end
			end

			if updateAll or element == "Frame" or element == "PowerBar" then
				if not updateAll then UUF:UpdateUnitPowerBar(BossFrame, "boss" .. i) end
				if BossFrame.Power then
					BossFrame.Power:SetMinMaxValues(0, TestData[i].maxPower)
					BossFrame.Power:SetValue(TestData[i].power)
				end
			end

			if (updateAll or element == "Indicators") and BossFrame.RaidTargetIndicator and TestRaidTargetCoords[((i - 1) % #TestRaidTargetCoords) + 1] then
				local coords = TestRaidTargetCoords[((i - 1) % #TestRaidTargetCoords) + 1]
				BossFrame.RaidTargetIndicator:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
				BossFrame.RaidTargetIndicator:SetTexCoord(unpack(coords))
				BossFrame.RaidTargetIndicator:Show()
			end

			if (updateAll or element == "Frame" or element == "CastBar") and BossFrame.Castbar then
				local CastBarDB = BossDB.CastBar
				local CastBarContainer = BossFrame.Castbar and BossFrame.Castbar:GetParent()
				if BossFrame.Castbar and CastBarDB.Enabled then
					BossFrame:DisableElement("Castbar")
					CastBarContainer:Show()
					BossFrame.Castbar:Show()
					BossFrame.Castbar.Background:Show()
					BossFrame.Castbar.Text:SetText(CastBarDB.ShowTarget and "Ethereal Portal » Target" or "Ethereal Portal")
					BossFrame.Castbar.Time:SetText("2.5")
					BossFrame.Castbar:SetMinMaxValues(0, 1000)
					BossFrame.Castbar:SetValue(500)
					local castBarColour = (false and CastBarDB.NotInterruptibleColour) or (CastBarDB.ColourByClass and UUF:GetClassColour(BossFrame)) or CastBarDB.Foreground
					BossFrame.Castbar:SetStatusBarColor(castBarColour[1], castBarColour[2], castBarColour[3], castBarColour[4])
					if CastBarDB.Icon.Enabled and BossFrame.Castbar.Icon then BossFrame.Castbar.Icon:SetTexture("Interface\\Icons\\ability_mage_netherwindpresence") BossFrame.Castbar.Icon:Show() end
				else
					if CastBarContainer then CastBarContainer:Hide() end
					if BossFrame.Castbar and BossFrame.Castbar.Icon then BossFrame.Castbar.Icon:Hide() end
				end
			end

			if updateAll or element == "Auras" then
				local auraTestMode = UUF.AURA_TEST_MODE
				if not updateAll then
					UUF.AURA_TEST_MODE = false
					UUF:UpdateUnitAuras(BossFrame, "boss" .. i)
				end
				UUF.AURA_TEST_MODE = auraTestMode
				UUF:CreateTestAuras(BossFrame, "boss" .. i)
			end

			if (updateAll or element == "Indicators") and BossFrame.TargetIndicator then
				local TargetIndicatorDB = BossDB.Indicators.Target
				if TargetIndicatorDB.Enabled and i % 2 == 1 then
					BossFrame.TargetIndicator:Show()
				else
					BossFrame.TargetIndicator:Hide()
				end
			end

			if updateAll or element == "Tags" then
				for tagIndex, tagName in ipairs(TestTagOrder) do ApplyTestTag(BossFrame.Tags[tagName], BossFrame, TagsDB[tagName], tagIndex == 1 and "Boss" .. i or "Tag " .. tagIndex) end
			end
		end
		if updateAll or element == "Frame" or element == "HealthBar" then UUF:LayoutBossFrames() end
	else
		for i, BossFrame in ipairs(UUF.BOSS_FRAMES) do
			BossFrame:SetAttribute("unit", "boss" .. i)
			RegisterUnitWatch(BossFrame)
			if BossFrame.Castbar then
				BossFrame.Castbar:Hide()
				BossFrame.Castbar:GetParent():Hide()
				if BossDB.CastBar.Enabled then
					if BossFrame:IsElementEnabled("Castbar") then BossFrame:DisableElement("Castbar") end
					BossFrame:EnableElement("Castbar")
				end
			end
			for j = 1, (BossFrame.BuffContainer and BossFrame.BuffContainer.maxFake or 0) do
				local button = BossFrame.BuffContainer["fake" .. j]
				if button then button:Hide() end
			end
			for j = 1, (BossFrame.DebuffContainer and BossFrame.DebuffContainer.maxFake or 0) do
				local button = BossFrame.DebuffContainer["fake" .. j]
				if button then button:Hide() end
			end
			for j = 1, (BossFrame.CustomAuraContainer and BossFrame.CustomAuraContainer.maxFake or 0) do
				local button = BossFrame.CustomAuraContainer["fake" .. j]
				if button then button:Hide() end
			end
			if BuffsDB.Enabled or DebuffsDB.Enabled then
				if not BossFrame:IsElementEnabled("Auras") then BossFrame:EnableElement("Auras") end
				if BossFrame.BuffContainer and BossFrame.BuffContainer.ForceUpdate then BossFrame.BuffContainer:ForceUpdate() end
				if BossFrame.DebuffContainer and BossFrame.DebuffContainer.ForceUpdate then BossFrame.DebuffContainer:ForceUpdate() end
			end
			if CustomDB and CustomDB.Enabled then
				BossFrame.CustomAuras = BossFrame.CustomAuraContainer
				if not BossFrame:IsElementEnabled("CustomAuras") then BossFrame:EnableElement("CustomAuras") end
				if BossFrame.CustomAuraContainer and BossFrame.CustomAuraContainer.ForceUpdate then BossFrame.CustomAuraContainer:ForceUpdate() end
			end
			BossFrame:Hide()
		end
	end
end

function UUF:UpdateTestEnvironment(unit, element)
	if unit == "party" then
		UpdatePartyTestEnvironment(element)
	elseif unit == "raid" then
		UpdateRaidTestEnvironment(element)
	elseif unit == "boss" then
		UpdateBossTestEnvironment(element)
	end
end
