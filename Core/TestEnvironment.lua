local _, UUF = ...
local EnvironmenTestData = {}
local oUF = UUF.oUF

local GroupRoles = {"TANK", "HEALER", "DAMAGER", "DAMAGER", "DAMAGER"}

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

for i = 1, 10 do
    EnvironmenTestData[i] = {
        name      = "Boss " .. i,
        class     = Classes[i],
        reaction  = i % 2 == 0 and 2 or 5,
        health    = 8000000 - (i * 600000),
        maxHealth = 8000000,
        missingHealth = i * 600000,
        absorb    = (i * 300000),
        percent  = (8000000 - (i * 600000)) / 8000000 * 100,
        maxPower  = 100,
        power     = 100 - (i * 7),
        powerType = PowerTypes[i],
    }
end

local function GetTestUnitColour(id, defaultColour, colourByClass, opacity)
    if colourByClass then
        if id <= 5 then
            local temporaryClass = EnvironmenTestData[id].class
            local classColour = RAID_CLASS_COLORS[temporaryClass]
            return classColour.r, classColour.g, classColour.b, opacity
        else
            local temporaryReaction = EnvironmenTestData[id].reaction
            local reactionColour = oUF.colors.reaction[temporaryReaction]
            return reactionColour.r, reactionColour.g, reactionColour.b, opacity
        end
    else
        return defaultColour[1], defaultColour[2], defaultColour[3], opacity
    end
end

function UUF:DisableTestGroupFrameTags(unitFrame)
	for _, fontString in pairs(unitFrame.Tags) do unitFrame:Untag(fontString) end
end

function UUF:CreateTestGroupFrames(unit)
	if unit ~= "party" and unit ~= "raid" then return end
	local isParty = unit == "party"
	local UnitDB = UUF.db.profile.Units[unit]
	local FrameDB = UnitDB.Frame
	local testMode = isParty and UUF.PARTY_TEST_MODE or UUF.RAID_TEST_MODE
	local testFrames = isParty and UUF.PARTY_TEST_FRAMES or UUF.RAID_TEST_FRAMES
	if (isParty and not UUF.PARTY) or (not isParty and #UUF.RAID_HEADERS == 0) then return end

	if not testMode then
		for unitIndex, unitFrame in ipairs(testFrames) do
			UUF:CreateTestAuras(unitFrame, unit .. "test" .. unitIndex, false)
			UUF:DisableTestGroupFrameTags(unitFrame)
			unitFrame:UnregisterAllEvents()
			unitFrame:Hide()
		end
		if isParty then
			UUF.PARTY:SetVisibility(UnitDB.Enabled and unit or "custom hide")
		else
			local _, _, selectedGroups = UUF:GetRaidGroupFilter()
			for groupIndex, raidHeader in ipairs(UUF.RAID_HEADERS) do raidHeader:SetVisibility(UnitDB.Enabled and selectedGroups[groupIndex] and unit or "custom hide") end
		end
		return
	end

	if isParty then
		UUF.PARTY:SetVisibility("custom hide")
	else
		for _, raidHeader in ipairs(UUF.RAID_HEADERS) do raidHeader:SetVisibility("custom hide") end
	end
	local testIndices = {}
	if isParty then
		for unitIndex = 1, FrameDB.ShowPlayer and UUF.MAX_PARTY_FRAMES or UUF.MAX_PARTY_FRAMES - 1 do testIndices[#testIndices + 1] = unitIndex end
	else
		local selectedGroups = {}
		for _, groupIndex in ipairs(FrameDB.GroupingOrder) do
			groupIndex = tonumber(groupIndex)
			if groupIndex and groupIndex >= 1 and groupIndex <= UUF.MAX_RAID_GROUPS then selectedGroups[groupIndex] = true end
		end
		if FrameDB.GroupBy == "GROUP" then
			for _, groupIndex in ipairs(FrameDB.GroupingOrder) do
				groupIndex = tonumber(groupIndex)
				if groupIndex and groupIndex >= 1 and groupIndex <= UUF.MAX_RAID_GROUPS then
					for groupMemberIndex = 1, UUF.RAID_GROUP_SIZE do testIndices[#testIndices + 1] = (groupIndex - 1) * UUF.RAID_GROUP_SIZE + groupMemberIndex end
				end
			end
		else
			for raidIndex = 1, UUF.MAX_RAID_FRAMES do if selectedGroups[math.ceil(raidIndex / UUF.RAID_GROUP_SIZE)] then testIndices[#testIndices + 1] = raidIndex end end
		end
	end

	if isParty and FrameDB.SortBy == "ROLE" then
		local roleOrder = {}
		for roleIndex, role in ipairs(FrameDB.RoleOrder) do roleOrder[role] = roleIndex end
		table.sort(testIndices, function(firstIndex, secondIndex)
			local firstRole = GroupRoles[(firstIndex - 1) % UUF.RAID_GROUP_SIZE + 1]
			local secondRole = GroupRoles[(secondIndex - 1) % UUF.RAID_GROUP_SIZE + 1]
			return roleOrder[firstRole] == roleOrder[secondRole] and firstIndex < secondIndex or roleOrder[firstRole] < roleOrder[secondRole]
		end)
	end

	local testContainer = isParty and UUF.PARTY_TEST_CONTAINER or UUF.RAID_TEST_CONTAINER
	local unitsPerColumn = isParty and #testIndices or UUF.RAID_GROUP_SIZE
	local columnCount = isParty and math.min(#testIndices, 1) or math.ceil(#testIndices / unitsPerColumn)
	local rowCount = math.min(#testIndices, unitsPerColumn)
	local containerWidth = columnCount * FrameDB.Width + math.max(columnCount - 1, 0) * FrameDB.Layout[5]
	local containerHeight = rowCount * FrameDB.Height + math.max(rowCount - 1, 0) * FrameDB.Layout[5]
	testContainer:ClearAllPoints()
	testContainer:SetSize(math.max(containerWidth, 1), math.max(containerHeight, 1))
	testContainer:SetPoint(FrameDB.Layout[1], UIParent, FrameDB.Layout[2], FrameDB.Layout[3], FrameDB.Layout[4])

	for _, unitFrame in ipairs(testFrames) do unitFrame:Hide() end
	for displayIndex, unitIndex in ipairs(testIndices) do
		local unitFrame = testFrames[unitIndex]
		local testData = EnvironmenTestData[(unitIndex - 1) % 10 + 1]
		local role = GroupRoles[(unitIndex - 1) % UUF.RAID_GROUP_SIZE + 1]
		UUF:UpdateUnitFrame(unitFrame, unit .. "test" .. unitIndex)
		UUF:CreateTestAuras(unitFrame, unit .. "test" .. unitIndex, true)
		unitFrame:UnregisterAllEvents()
		unitFrame:ClearAllPoints()
		if not isParty then
			local columnIndex = math.floor((displayIndex - 1) / unitsPerColumn)
			local rowIndex = (displayIndex - 1) % unitsPerColumn
			local offsetX = columnIndex * (FrameDB.Width + FrameDB.Layout[5])
			local offsetY = rowIndex * (FrameDB.Height + FrameDB.Layout[5])
			if FrameDB.RowDirection == "LEFT" then offsetX = -offsetX end
			if FrameDB.ColumnDirection == "DOWN" then offsetY = -offsetY end
			local frameAnchor = FrameDB.ColumnDirection == "UP" and (FrameDB.RowDirection == "LEFT" and "BOTTOMRIGHT" or "BOTTOMLEFT") or FrameDB.RowDirection == "LEFT" and "TOPRIGHT" or "TOPLEFT"
			unitFrame:SetPoint(frameAnchor, testContainer, frameAnchor, offsetX, offsetY)
		else
			local rowIndex = displayIndex - 1
			local offsetY = rowIndex * (FrameDB.Height + FrameDB.Layout[5])
			local frameAnchor = FrameDB.GrowthDirection == "UP" and "BOTTOMLEFT" or "TOPLEFT"
			if FrameDB.GrowthDirection == "DOWN" then offsetY = -offsetY end
			unitFrame:SetPoint(frameAnchor, testContainer, frameAnchor, 0, offsetY)
		end

		if unitFrame.Health then
			local HealthBarDB = UnitDB.HealthBar
			unitFrame.Health:SetMinMaxValues(0, testData.maxHealth)
			unitFrame.Health:SetValue(testData.health)
			unitFrame.HealthBackground:SetMinMaxValues(0, testData.maxHealth)
			unitFrame.HealthBackground:SetValue(testData.missingHealth)
			unitFrame.Health:SetStatusBarColor(GetTestUnitColour((unitIndex - 1) % 10 + 1, HealthBarDB.Foreground, HealthBarDB.ColourByClass, HealthBarDB.ForegroundOpacity))
			unitFrame.HealthBackground:SetStatusBarColor(GetTestUnitColour((unitIndex - 1) % 10 + 1, HealthBarDB.Background, HealthBarDB.ColourBackgroundByClass, HealthBarDB.BackgroundOpacity))
		end
		if unitFrame.Power then
			unitFrame.Power:SetMinMaxValues(0, testData.maxPower)
			unitFrame.Power:SetValue(testData.power)
		end
		if unitFrame.GroupRoleIndicator then
			local roleAtlas = role == "TANK" and "UI-LFG-RoleIcon-Tank-Micro-Raid" or role == "HEALER" and "UI-LFG-RoleIcon-Healer-Micro-Raid" or "UI-LFG-RoleIcon-DPS-Micro-Raid"
			unitFrame.GroupRoleIndicator:SetAtlas(roleAtlas)
			unitFrame.GroupRoleIndicator:SetShown(UnitDB.Indicators.Role.Enabled)
		end
		if unitFrame.LeaderIndicator then unitFrame.LeaderIndicator:SetShown(UnitDB.Indicators.LeaderAssistantIndicator.Enabled and displayIndex == 1) end
		if unitFrame.AssistantIndicator then unitFrame.AssistantIndicator:SetShown(UnitDB.Indicators.LeaderAssistantIndicator.Enabled and displayIndex == 2) end
		if unitFrame.RaidTargetIndicator then
			local markerIndex = (displayIndex - 1) % 8
			local markerX = (markerIndex % 4) * 0.25
			local markerY = math.floor(markerIndex / 4) * 0.25
			unitFrame.RaidTargetIndicator:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
			unitFrame.RaidTargetIndicator:SetTexCoord(markerX, markerX + 0.25, markerY, markerY + 0.25)
			unitFrame.RaidTargetIndicator:SetShown(UnitDB.Indicators.RaidTargetMarker.Enabled)
		end
		if unitFrame.TargetIndicator then unitFrame.TargetIndicator:SetAlphaFromBoolean(displayIndex % 2 == 1 and UnitDB.Indicators.Target.Enabled, 1, 0) end
		if unitFrame.DispelHighlight then unitFrame.DispelHighlight:Hide() end
		if unitFrame.Tags.TagOne then unitFrame.Tags.TagOne:SetText((isParty and "Party " or "Raid ") .. unitIndex) end
		if unitFrame.Tags.TagTwo then unitFrame.Tags.TagTwo:SetText(string.format("%.1f%%", testData.percent)) end
		if unitFrame.Tags.TagThree then unitFrame.Tags.TagThree:SetText(testData.power) end
		if unitFrame.Tags.TagFour then unitFrame.Tags.TagFour:SetText("") end
		if unitFrame.Tags.TagFive then unitFrame.Tags.TagFive:SetText("") end
		UUF:DisableTestGroupFrameTags(unitFrame)
		unitFrame:SetShown(UnitDB.Enabled)
	end
end

function UUF:CreateTestBossFrames()
    local General = UUF.db.profile.General
    local BuffsDB = UUF.db.profile.Units.boss.Auras.Buffs
    local DebuffsDB = UUF.db.profile.Units.boss.Auras.Debuffs
    local CustomDB = UUF.db.profile.Units.boss.Auras.Custom
    local TagsDB = UUF.db.profile.Units.boss.Tags
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

            if BossFrame.Tags.TagOne then
                local TagOneDB = TagsDB.TagOne
                BossFrame.Tags.TagOne:ClearAllPoints()
                BossFrame.Tags.TagOne:SetPoint(TagOneDB.Layout[1], BossFrame, TagOneDB.Layout[2], TagOneDB.Layout[3], TagOneDB.Layout[4])
                BossFrame.Tags.TagOne:SetFont(UUF.Media.Font, TagOneDB.FontSize, General.Fonts.FontFlag)
                if General.Fonts.Shadow.Enabled then
                    BossFrame.Tags.TagOne:SetShadowColor(unpack(General.Fonts.Shadow.Colour))
                    BossFrame.Tags.TagOne:SetShadowOffset(General.Fonts.Shadow.XPos, General.Fonts.Shadow.YPos)
                else
                    BossFrame.Tags.TagOne:SetShadowColor(0, 0, 0, 0)
                    BossFrame.Tags.TagOne:SetShadowOffset(0, 0)
                end
                BossFrame.Tags.TagOne:SetTextColor(unpack(TagOneDB.Colour))
                BossFrame.Tags.TagOne:SetText(EnvironmenTestData[i].name)
            end

            if BossFrame.Tags.TagTwo then
                local TagTwoDB = TagsDB.TagTwo
                BossFrame.Tags.TagTwo:ClearAllPoints()
                BossFrame.Tags.TagTwo:SetPoint(TagTwoDB.Layout[1], BossFrame, TagTwoDB.Layout[2], TagTwoDB.Layout[3], TagTwoDB.Layout[4])
                BossFrame.Tags.TagTwo:SetFont(UUF.Media.Font, TagTwoDB.FontSize, General.Fonts.FontFlag)
                if General.Fonts.Shadow.Enabled then
                    BossFrame.Tags.TagTwo:SetShadowColor(unpack(General.Fonts.Shadow.Colour))
                    BossFrame.Tags.TagTwo:SetShadowOffset(General.Fonts.Shadow.XPos, General.Fonts.Shadow.YPos)
                else
                    BossFrame.Tags.TagTwo:SetShadowColor(0, 0, 0, 0)
                    BossFrame.Tags.TagTwo:SetShadowOffset(0, 0)
                end
                BossFrame.Tags.TagTwo:SetTextColor(unpack(TagTwoDB.Colour))
                BossFrame.Tags.TagTwo:SetText(string.format("%.1f%%", EnvironmenTestData[i].percent))
            end

            if BossFrame.Tags.TagThree then
                local TagThreeDB = TagsDB.TagThree
                BossFrame.Tags.TagThree:ClearAllPoints()
                BossFrame.Tags.TagThree:SetPoint(TagThreeDB.Layout[1], BossFrame, TagThreeDB.Layout[2], TagThreeDB.Layout[3], TagThreeDB.Layout[4])
                BossFrame.Tags.TagThree:SetFont(UUF.Media.Font, TagThreeDB.FontSize, General.Fonts.FontFlag)
                if General.Fonts.Shadow.Enabled then
                    BossFrame.Tags.TagThree:SetShadowColor(unpack(General.Fonts.Shadow.Colour))
                    BossFrame.Tags.TagThree:SetShadowOffset(General.Fonts.Shadow.XPos, General.Fonts.Shadow.YPos)
                else
                    BossFrame.Tags.TagThree:SetShadowColor(0, 0, 0, 0)
                    BossFrame.Tags.TagThree:SetShadowOffset(0, 0)
                end
                BossFrame.Tags.TagThree:SetTextColor(unpack(TagThreeDB.Colour))
                BossFrame.Tags.TagThree:SetText(EnvironmenTestData[i].power)
            end
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
