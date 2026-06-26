local _, UUF = ...
local EnvironmenTestData = {}
local oUF = UUF.oUF

local Classes = {
    [1] = "WARRIOR",
    [2] = "PALADIN",
    [3] = "HUNTER",
    [4] = "ROGUE",
    [5] = "PRIEST",
    [6] = "DEATHKNIGHT",
    [7] = "SHAMAN",
    [8] = "MAGE",
    [9] = "WARLOCK",
    [10]= "MONK",
    [11]= "DRUID",
    [12]= "DEMONHUNTER",
    [13]= "EVOKER",
}

local PowerTypes = {
    [1] = 0,
    [2] = 1,
    [3] = 2,
    [4] = 3,
    [5] = 6,
    [6] = 8,
    [7] = 11,
    [8] = 13,
    [9] = 17,
    [10] = 18
}

for i = 1, UUF.MAX_RAID_FRAMES do
    EnvironmenTestData[i] = {
        name      = "Unit " .. i,
        class     = Classes[((i - 1) % #Classes) + 1],
        reaction  = i % 2 == 0 and 2 or 5,
        health    = 8000000 - (((i - 1) % 10 + 1) * 600000),
        maxHealth = 8000000,
        missingHealth = ((i - 1) % 10 + 1) * 600000,
        absorb    = (((i - 1) % 10 + 1) * 300000),
        healAbsorb = (((i - 1) % 10 + 1) * 150000),
        incomingHeal = (((i - 1) % 10 + 1) * 200000),
        percent  = (8000000 - (((i - 1) % 10 + 1) * 600000)) / 8000000 * 100,
        maxPower  = 100,
        power     = 100 - (((i - 1) % 10 + 1) * 7),
        powerType = PowerTypes[((i - 1) % #PowerTypes) + 1],
    }
end

for i = 1, UUF.MAX_BOSS_FRAMES do EnvironmenTestData[i].name = "Boss " .. i end

local TestRoles = {"TANK", "HEALER", "DAMAGER", "DAMAGER", "DAMAGER"}
local TestTagOrder = {"TagOne", "TagTwo", "TagThree"}
local TestRoleAtlas = {
	TANK = "UI-LFG-RoleIcon-Tank-Micro-Raid",
	HEALER = "UI-LFG-RoleIcon-Healer-Micro-Raid",
	DAMAGER = "UI-LFG-RoleIcon-DPS-Micro-Raid",
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
        local temporaryClass = EnvironmenTestData[id].class
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

local function ApplyGroupTestFrame(unitFrame, unit, index)
	if not unitFrame or not unit then return end
	local normalizedUnit = UUF:GetNormalizedUnit(unit)
	local UnitDB = UUF.db.profile.Units[normalizedUnit]
	local FrameDB = UnitDB.Frame
	local HealthBarDB = UnitDB.HealthBar
	local HealPredictionDB = UnitDB.HealPrediction
	local PowerBarDB = UnitDB.PowerBar
	local IndicatorDB = UnitDB.Indicators
	local TagsDB = UnitDB.Tags
	local testData = EnvironmenTestData[index]
	local role = TestRoles[((index - 1) % #TestRoles) + 1]

	unitFrame:SetAttribute("unit", nil)
	unitFrame:SetSize(FrameDB.Width, FrameDB.Height)
	unitFrame:SetFrameStrata(FrameDB.FrameStrata)
	UnregisterUnitWatch(unitFrame)
	if unitFrame:IsElementEnabled("Auras") then unitFrame:DisableElement("Auras") end
	if unitFrame:IsElementEnabled("CustomAuras") then unitFrame:DisableElement("CustomAuras") end
	unitFrame:Show()

	if unitFrame.Health then
		unitFrame.Health:SetMinMaxValues(0, testData.maxHealth)
		unitFrame.Health:SetValue(testData.health)
		unitFrame.Health:SetStatusBarColor(GetTestUnitColour(index, HealthBarDB.Foreground, HealthBarDB.ColourByClass, HealthBarDB.ForegroundOpacity))
		if unitFrame.HealthBackground then
			unitFrame.HealthBackground:SetMinMaxValues(0, testData.maxHealth)
			unitFrame.HealthBackground:SetValue(testData.missingHealth)
			unitFrame.HealthBackground:SetStatusBarColor(GetTestUnitColour(index, HealthBarDB.Background, HealthBarDB.ColourBackgroundByClass, HealthBarDB.BackgroundOpacity))
		end
	end

	if unitFrame.HealthPrediction then
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

	if unitFrame.Power then
		unitFrame.Power:SetMinMaxValues(0, testData.maxPower)
		unitFrame.Power:SetValue(testData.power)
		if PowerBarDB.ColourByType and oUF.colors.power[testData.powerType] then
			local colour = oUF.colors.power[testData.powerType]
			unitFrame.Power:SetStatusBarColor(colour.r, colour.g, colour.b)
		else
			unitFrame.Power:SetStatusBarColor(unpack(PowerBarDB.Foreground))
		end
	end

	if unitFrame.GroupRoleIndicator and IndicatorDB.Role then
		local roleTexture = UUF.RoleTextures[IndicatorDB.Role.Texture] and UUF.RoleTextures[IndicatorDB.Role.Texture][role]
		if IndicatorDB.Role.Enabled and IndicatorDB.Role.Texture == "Default" and TestRoleAtlas[role] then
			unitFrame.GroupRoleIndicator:SetAtlas(TestRoleAtlas[role])
			unitFrame.GroupRoleIndicator:SetTexCoord(0, 1, 0, 1)
			unitFrame.GroupRoleIndicator:Show()
		else
			SetTestTexture(unitFrame.GroupRoleIndicator, IndicatorDB.Role.Enabled and roleTexture, roleTexture)
		end
	end

	if unitFrame.LeaderIndicator and IndicatorDB.LeaderAssistantIndicator then SetTestTexture(unitFrame.LeaderIndicator, IndicatorDB.LeaderAssistantIndicator.Enabled and index == 1, "Interface\\GroupFrame\\UI-Group-LeaderIcon") end
	if unitFrame.AssistantIndicator and IndicatorDB.LeaderAssistantIndicator then SetTestTexture(unitFrame.AssistantIndicator, IndicatorDB.LeaderAssistantIndicator.Enabled and index == 2, "Interface\\GroupFrame\\UI-Group-AssistantIcon") end

	if unitFrame.PhaseIndicator and IndicatorDB.Phase then
		if IndicatorDB.Phase.Enabled and index % 7 == 0 then
			unitFrame.PhaseIndicator.Icon:SetAtlas("groupfinder-icon-phased")
			unitFrame.PhaseIndicator:Show()
		else
			unitFrame.PhaseIndicator:Hide()
		end
	end

	if unitFrame.RaidTargetIndicator and IndicatorDB.RaidTargetMarker and TestRaidTargetCoords[((index - 1) % #TestRaidTargetCoords) + 1] then
		local coords = TestRaidTargetCoords[((index - 1) % #TestRaidTargetCoords) + 1]
		SetTestTexture(unitFrame.RaidTargetIndicator, IndicatorDB.RaidTargetMarker.Enabled and index <= #TestRaidTargetCoords, "Interface\\TargetingFrame\\UI-RaidTargetingIcons", unpack(coords))
	end

	if unitFrame.TargetIndicator and IndicatorDB.Target then unitFrame.TargetIndicator:SetAlpha(IndicatorDB.Target.Enabled and index == 1 and 1 or 0) end
	if unitFrame.ThreatIndicator and IndicatorDB.Threat then
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

	local auraTestMode = UUF.AURA_TEST_MODE
	UUF.AURA_TEST_MODE = true
	UUF:CreateTestAuras(unitFrame, unit)
	UUF.AURA_TEST_MODE = auraTestMode
	for tagIndex, tagName in ipairs(TestTagOrder) do
		ApplyTestTag(unitFrame.Tags and unitFrame.Tags[tagName], unitFrame, TagsDB[tagName], "Tag " .. tagIndex)
	end
end

local function RestoreGroupFrame(unitFrame, unit)
	if not unitFrame or not unit then return end
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
			raidFrame.isUUFTestFrame = true
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
					local xOffset = headerXOffset + (unitGrowth == "RIGHT" and unitOffset or unitGrowth == "LEFT" and -unitOffset or 0)
					local yOffset = headerYOffset + (unitGrowth == "UP" and unitOffset or unitGrowth == "DOWN" and -unitOffset or 0)
					local point = (groupGrowth == "UP" or unitGrowth == "UP") and "BOTTOMLEFT" or "TOPLEFT"
					raidFrame:SetPoint(point, UUF.RAID_CONTAINER, point, xOffset, yOffset)
					raidFrame:Show()
				else
					raidFrame:Hide()
				end
			end
		end
	end
end

function UUF:CreateTestGroupFrames(unit)
	if unit == "party" then
		local UnitDB = UUF.db.profile.Units.party
		if not UnitDB or not UnitDB.Enabled then if UUF.PARTY_CONTAINER then UUF.PARTY_CONTAINER:Hide() end return end
		UUF:CreatePartyContainer()
		UnregisterStateDriver(UUF.PARTY_CONTAINER, "visibility")
		UUF.PARTY_CONTAINER:Show()
		for i = 1, UUF.MAX_PARTY_FRAMES do
			if UUF["PARTY" .. i] then ApplyGroupTestFrame(UUF["PARTY" .. i], "party" .. i, i + (UnitDB.Frame.ShowPlayer and 1 or 0)) end
		end
		if UUF.PARTYPLAYER then ApplyGroupTestFrame(UUF.PARTYPLAYER, "partyplayer", 1) end
		UUF:LayoutPartyFrames()
	elseif unit == "raid" then
		local UnitDB = UUF.db.profile.Units.raid
		if not UnitDB or not UnitDB.Enabled then if UUF.RAID_CONTAINER then UUF.RAID_CONTAINER:Hide() end return end
		UUF:CreateRaidContainer()
		UUF:CreateRaidTestFrames()
		for _, header in ipairs(UUF.RAID_HEADERS) do header:Hide() end
		for i, raidFrame in ipairs(UUF.RAID_TEST_FRAMES) do ApplyGroupTestFrame(raidFrame, "raid" .. i, i) end
		UUF:LayoutRaidTestFrames()
		UUF.RAID_CONTAINER:Show()
	end
end

function UUF:RestoreTestGroupFrames(unit)
	if unit == "party" then
		for i = 1, UUF.MAX_PARTY_FRAMES do if UUF["PARTY" .. i] then RestoreGroupFrame(UUF["PARTY" .. i], "party" .. i) end end
		if UUF.PARTYPLAYER then RestoreGroupFrame(UUF.PARTYPLAYER, "partyplayer") end
		UUF:UpdatePartyFrames()
	elseif unit == "raid" then
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
	end
end

function UUF:CreateTestBossFrames()
    local General = UUF.db.profile.General
    local BuffsDB = UUF.db.profile.Units.boss.Auras.Buffs
    local DebuffsDB = UUF.db.profile.Units.boss.Auras.Debuffs
    local CustomDB = UUF.db.profile.Units.boss.Auras.Custom
    local TagsDB = UUF.db.profile.Units.boss.Tags
    local HealPredictionDB = UUF.db.profile.Units.boss.HealPrediction
    UUF:ResolveLSM()
    local BossDB = UUF.db.profile.Units.boss
    if UUF.BOSS_TEST_MODE then
        for i, BossFrame in ipairs(UUF.BOSS_FRAMES) do
            BossFrame:SetAttribute("unit", nil)
            UnregisterUnitWatch(BossFrame)
            if BossFrame:IsElementEnabled("Auras") then BossFrame:DisableElement("Auras") end
            if BossFrame:IsElementEnabled("CustomAuras") then BossFrame:DisableElement("CustomAuras") end
            if BossDB.Enabled then BossFrame:Show() else BossFrame:Hide() end

            BossFrame:SetFrameStrata(BossDB.Frame.FrameStrata)

            if BossFrame.Health then
                local HealthBarDB = UUF.db.profile.Units.boss.HealthBar
                BossFrame.Health:SetMinMaxValues(0, EnvironmenTestData[i].maxHealth)
                BossFrame.Health:SetValue(EnvironmenTestData[i].health)
                BossFrame.HealthBackground:SetMinMaxValues(0, EnvironmenTestData[i].maxHealth)
                BossFrame.HealthBackground:SetValue(EnvironmenTestData[i].missingHealth)
                BossFrame.HealthBackground:SetStatusBarColor(GetTestUnitColour(i, HealthBarDB.Background, HealthBarDB.ColourBackgroundByClass, HealthBarDB.BackgroundOpacity))
                BossFrame.Health:SetStatusBarColor(GetTestUnitColour(i, HealthBarDB.Foreground, HealthBarDB.ColourByClass, HealthBarDB.ForegroundOpacity))
            end

            if BossFrame.HealthPrediction then
                UUF:UpdateUnitHealPrediction(BossFrame, "boss" .. i)
                local maxHealth = EnvironmenTestData[i].maxHealth
                SetTestPredictionBar(BossFrame.HealthPrediction.damageAbsorb, EnvironmenTestData[i].absorb, maxHealth, HealPredictionDB.Absorbs.Enabled)
                SetTestPredictionBar(BossFrame.HealthPrediction.healAbsorb, EnvironmenTestData[i].healAbsorb, maxHealth, HealPredictionDB.HealAbsorbs.Enabled)
                SetTestPredictionBar(BossFrame.HealthPrediction.healingPlayer, EnvironmenTestData[i].incomingHeal, maxHealth, HealPredictionDB.IncomingHeal.Enabled)
                if BossFrame.HealthPrediction.overDamageAbsorb then
                    local showOverAbsorb = HealPredictionDB.Absorbs.Enabled and HealPredictionDB.Absorbs.ShowOverAbsorb and HealPredictionDB.Absorbs.Position == "ATTACH"
                    SetTestPredictionBar(BossFrame.HealthPrediction.overDamageAbsorb, EnvironmenTestData[i].absorb, maxHealth, showOverAbsorb)
                    if BossFrame.HealthPrediction.overDamageAbsorb.Clip then
                        if showOverAbsorb then BossFrame.HealthPrediction.overDamageAbsorb.Clip:Show() else BossFrame.HealthPrediction.overDamageAbsorb.Clip:Hide() end
                    end
                end
            end

            if BossFrame.Portrait then
                local PortraitOptions = {
                    [1] = "achievement_character_human_female",
                    [2] = "achievement_character_human_male",
                    [3] = "achievement_character_dwarf_male",
                    [4] = "achievement_character_dwarf_female",
                    [5] = "achievement_character_nightelf_female",
                    [6] = "achievement_character_nightelf_male",
                    [7] = "achievement_character_undead_male",
                    [8] = "achievement_character_undead_female",
                    [9] = "achievement_character_orc_male",
                    [10]= "achievement_character_orc_female"
                }
                if BossFrame.Portrait:IsObjectType("PlayerModel") then
                    BossFrame.Portrait:ClearModel()
                    BossFrame.Portrait:SetUnit("player")
                else
                    BossFrame.Portrait:SetTexture("Interface\\ICONS\\" .. PortraitOptions[i])
                end
            end

            if BossFrame.Power then
                BossFrame.Power:SetMinMaxValues(0, EnvironmenTestData[i].maxPower)
                BossFrame.Power:SetValue(EnvironmenTestData[i].power)
            end

            local raidTargetMarkerCoords={{0,0.25,0,0.25},{0.25,0.5,0,0.25},{0.5,0.75,0,0.25},{0.75,1,0,0.25},{0,0.25,0.25,0.5},{0.25,0.5,0.25,0.5},{0.5,0.75,0.25,0.5},{0.75,1,0.25,0.5},{0,0.25,0,0.25},{0.25,0.5,0,0.25}}
            if BossFrame.RaidTargetIndicator and i and raidTargetMarkerCoords[i] then
                BossFrame.RaidTargetIndicator:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
                BossFrame.RaidTargetIndicator:SetTexCoord(unpack(raidTargetMarkerCoords[i]))
                BossFrame.RaidTargetIndicator:Show()
            end

            if BossFrame.Castbar then
                local CastBarDB = UUF.db.profile.Units.boss.CastBar
                local CastBarContainer = BossFrame.Castbar and BossFrame.Castbar:GetParent()
                if BossFrame.Castbar and CastBarDB.Enabled then
                    BossFrame:DisableElement("Castbar")
                    CastBarContainer:Show()
                    BossFrame.Castbar:Show()
                    BossFrame.Castbar.Background:Show()
                    BossFrame.Castbar.Text:SetText(CastBarDB.ShowTarget and "Ethereal Portal » Target" or "Ethereal Portal")
                    BossFrame.Castbar.Time:SetText("0.0")
                    BossFrame.Castbar:SetMinMaxValues(0, 1000)
                    BossFrame.Castbar.testValue = 0
                    BossFrame.Castbar:SetScript("OnUpdate", function(self, elapsed) self.testValue = ((self.testValue or 0) + elapsed) % 5 self:SetValue((self.testValue / 5) * 1000) self.Time:SetText(string.format("%.1f", self.testValue)) end)
                    local castBarColour = (false and CastBarDB.NotInterruptibleColour) or (CastBarDB.ColourByClass and UUF:GetClassColour(BossFrame)) or CastBarDB.Foreground
                    BossFrame.Castbar:SetStatusBarColor(castBarColour[1], castBarColour[2], castBarColour[3], castBarColour[4])
                    if CastBarDB.Icon.Enabled and BossFrame.Castbar.Icon then BossFrame.Castbar.Icon:SetTexture("Interface\\Icons\\ability_mage_netherwindpresence") BossFrame.Castbar.Icon:Show() end
                else
                    if CastBarContainer then CastBarContainer:Hide() end
                    if BossFrame.Castbar and BossFrame.Castbar.Icon then BossFrame.Castbar.Icon:Hide() end
                end
            end

            if BossFrame.BuffContainer then
                if BuffsDB.Enabled then
                    BossFrame.BuffContainer:ClearAllPoints()
                    BossFrame.BuffContainer:SetPoint(BuffsDB.Layout[1], BossFrame, BuffsDB.Layout[2], BuffsDB.Layout[3], BuffsDB.Layout[4])
                    BossFrame.BuffContainer:Show()
                    for _, button in ipairs(BossFrame.BuffContainer) do
                        if button then button:Hide() end
                    end

                    for j = 1, BuffsDB.Num do
                        local button = BossFrame.BuffContainer["fake" .. j]
                        if not button then
                            button = CreateFrame("Button", nil, BossFrame.BuffContainer, "BackdropTemplate")
                            button:SetBackdrop(UUF.BACKDROP)
                            button:SetBackdropColor(0, 0, 0, 0)
                            button:SetBackdropBorderColor(0, 0, 0, 1)
                            button:SetFrameStrata("MEDIUM")

                            button.Icon = button:CreateTexture(nil, "BORDER")
                            button.Icon:SetAllPoints()

                            button.Count = button:CreateFontString(nil, "OVERLAY")
                            BossFrame.BuffContainer["fake" .. j] = button
                        end

                        button:SetSize(BuffsDB.Size, BuffsDB.Size)
                        button.Count:ClearAllPoints()
                        button.Count:SetPoint(BuffsDB.Count.Layout[1], button, BuffsDB.Count.Layout[2], BuffsDB.Count.Layout[3], BuffsDB.Count.Layout[4])
                        button.Count:SetFont(UUF.Media.Font, BuffsDB.Count.FontSize, General.Fonts.FontFlag)
                        if General.Fonts.Shadow.Enabled then
                            button.Count:SetShadowColor(unpack(General.Fonts.Shadow.Colour))
                            button.Count:SetShadowOffset(General.Fonts.Shadow.XPos, General.Fonts.Shadow.YPos)
                        else
                            button.Count:SetShadowColor(0, 0, 0, 0)
                            button.Count:SetShadowOffset(0, 0)
                        end
                        button.Count:SetTextColor(unpack(BuffsDB.Count.Colour))

                        local row = math.floor((j - 1) / BuffsDB.Wrap)
                        local col = (j - 1) % BuffsDB.Wrap
                        local x = col * (BuffsDB.Size + BuffsDB.Layout[5])
                        local y = row * (BuffsDB.Size + BuffsDB.Layout[5])
                        if BuffsDB.GrowthDirection == "LEFT" then x = -x end
                        if BuffsDB.WrapDirection == "DOWN" then y = -y end

                        button:ClearAllPoints()
                        button:SetPoint(BuffsDB.Layout[1], BossFrame.BuffContainer, BuffsDB.Layout[1], x, y)

                        button.Icon:SetTexture(135769)
                        button.Icon:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
                        button.Icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
                        button.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
                        button.Count:SetText(j)
                        button.Duration = button.Duration or button:CreateFontString(nil, "OVERLAY")
                        UUF:ApplyCooldownText(button, button.Duration, "boss")
                        button.Duration:SetText("10m")
                        button:Show()
                    end

                    local maxFake = BuffsDB.Num
                    for j = maxFake + 1, (BossFrame.BuffContainer.maxFake or maxFake) do
                        local button = BossFrame.BuffContainer["fake" .. j]
                        if button then button:Hide() end
                    end
                    BossFrame.BuffContainer.maxFake = BuffsDB.Num
                else
                    BossFrame.BuffContainer:Hide()
                end
            end

            if BossFrame.DebuffContainer then
                if DebuffsDB.Enabled then
                    BossFrame.DebuffContainer:ClearAllPoints()
                    BossFrame.DebuffContainer:SetPoint(DebuffsDB.Layout[1], BossFrame, DebuffsDB.Layout[2], DebuffsDB.Layout[3], DebuffsDB.Layout[4])
                    BossFrame.DebuffContainer:Show()
                    for _, button in ipairs(BossFrame.DebuffContainer) do
                        if button then button:Hide() end
                    end

                    for j = 1, DebuffsDB.Num do
                        local button = BossFrame.DebuffContainer["fake" .. j]
                        if not button then
                            button = CreateFrame("Button", nil, BossFrame.DebuffContainer, "BackdropTemplate")
                            button:SetBackdrop(UUF.BACKDROP)
                            button:SetBackdropColor(0, 0, 0, 0)
                            button:SetBackdropBorderColor(0, 0, 0, 1)
                            button:SetFrameStrata("MEDIUM")

                            button.Icon = button:CreateTexture(nil, "BORDER")
                            button.Icon:SetAllPoints()

                            button.Count = button:CreateFontString(nil, "OVERLAY")
                            BossFrame.DebuffContainer["fake" .. j] = button
                        end

                        button:SetSize(DebuffsDB.Size, DebuffsDB.Size)
                        button.Count:ClearAllPoints()
                        button.Count:SetPoint(DebuffsDB.Count.Layout[1], button, DebuffsDB.Count.Layout[2], DebuffsDB.Count.Layout[3], DebuffsDB.Count.Layout[4])
                        button.Count:SetFont(UUF.Media.Font, DebuffsDB.Count.FontSize, General.Fonts.FontFlag)
                        if General.Fonts.Shadow.Enabled then
                            button.Count:SetShadowColor(unpack(General.Fonts.Shadow.Colour))
                            button.Count:SetShadowOffset(General.Fonts.Shadow.XPos, General.Fonts.Shadow.YPos)
                        else
                            button.Count:SetShadowColor(0, 0, 0, 0)
                            button.Count:SetShadowOffset(0, 0)
                        end
                        button.Count:SetTextColor(unpack(DebuffsDB.Count.Colour))

                        local row = math.floor((j - 1) / DebuffsDB.Wrap)
                        local col = (j - 1) % DebuffsDB.Wrap
                        local x = col * (DebuffsDB.Size + DebuffsDB.Layout[5])
                        local y = row * (DebuffsDB.Size + DebuffsDB.Layout[5])
                        if DebuffsDB.GrowthDirection == "LEFT" then x = -x end
                        if DebuffsDB.WrapDirection == "DOWN" then y = -y end

                        button:ClearAllPoints()
                        button:SetPoint(DebuffsDB.Layout[1], BossFrame.DebuffContainer, DebuffsDB.Layout[1], x, y)
                        button.Icon:SetTexture(135768)
                        button.Icon:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
                        button.Icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
                        button.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
                        button.Count:SetText(j)
                        button.Duration = button.Duration or button:CreateFontString(nil, "OVERLAY")
                        UUF:ApplyCooldownText(button, button.Duration, "boss")
                        button.Duration:SetText("10m")
                        button:Show()
                    end

                    local maxFake = DebuffsDB.Num
                    for j = maxFake + 1, (BossFrame.DebuffContainer.maxFake or maxFake) do
                        local button = BossFrame.DebuffContainer["fake" .. j]
                        if button then button:Hide() end
                    end
                    BossFrame.DebuffContainer.maxFake = DebuffsDB.Num
                else
                    BossFrame.DebuffContainer:Hide()
                end
            end

            if BossFrame.TargetIndicator then
                local TargetIndicatorDB = UUF.db.profile.Units.boss.Indicators.Target
                if TargetIndicatorDB.Enabled and i % 2 == 1 then
                    BossFrame.TargetIndicator:Show()
                else
                    BossFrame.TargetIndicator:Hide()
                end
            end

            ApplyTestTag(BossFrame.Tags.TagOne, BossFrame, TagsDB.TagOne, "Tag 1")
            ApplyTestTag(BossFrame.Tags.TagTwo, BossFrame, TagsDB.TagTwo, "Tag 2")
            ApplyTestTag(BossFrame.Tags.TagThree, BossFrame, TagsDB.TagThree, "Tag 3")
        end
    else
        for i, BossFrame in ipairs(UUF.BOSS_FRAMES) do
            BossFrame:SetAttribute("unit", "boss" .. i)
            RegisterUnitWatch(BossFrame)
            if BossFrame.Castbar then
                BossFrame.Castbar:SetScript("OnUpdate", nil)
                BossFrame.Castbar:Hide()
                BossFrame.Castbar:GetParent():Hide()
                if UUF.db.profile.Units.boss.CastBar.Enabled then
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
