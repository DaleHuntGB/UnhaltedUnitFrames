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
    local dataIndex = ((id - 1) % #EnvironmenTestData) + 1
    local testData = EnvironmenTestData[dataIndex]
    if not testData then
        return defaultColour[1], defaultColour[2], defaultColour[3], opacity
    end

    if colourByClass then
        if dataIndex <= 5 then
            local temporaryClass = testData.class
            local classColour = RAID_CLASS_COLORS[temporaryClass]
            return classColour.r, classColour.g, classColour.b, opacity
        else
            local temporaryReaction = testData.reaction
            local reactionColour = oUF.colors.reaction[temporaryReaction]
            return reactionColour.r, reactionColour.g, reactionColour.b, opacity
        end
    else
        return defaultColour[1], defaultColour[2], defaultColour[3], opacity
    end
end

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

local raidTargetMarkerCoords = {
    {0,0.25,0,0.25},
    {0.25,0.5,0,0.25},
    {0.5,0.75,0,0.25},
    {0.75,1,0,0.25},
    {0,0.25,0.25,0.5},
    {0.25,0.5,0.25,0.5},
    {0.5,0.75,0.25,0.5},
    {0.75,1,0.25,0.5},
    {0,0.25,0,0.25},
    {0.25,0.5,0,0.25}
}

local RAID_DIRECTION_TO_POINT = {
    DOWN_RIGHT = "TOP",
    DOWN_LEFT = "TOP",
    UP_RIGHT = "BOTTOM",
    UP_LEFT = "BOTTOM",
    RIGHT_DOWN = "LEFT",
    RIGHT_UP = "LEFT",
    LEFT_DOWN = "RIGHT",
    LEFT_UP = "RIGHT",
}

local function GetTestRaidGroupHeaderDimensions(frameDB)
    local direction = frameDB.GrowthDirection or "DOWN_RIGHT"
    local point = RAID_DIRECTION_TO_POINT[direction] or "TOP"
    local horizontalSpacing = frameDB.HorizontalSpacing or 0
    local verticalSpacing = frameDB.VerticalSpacing or 0

    if point == "LEFT" or point == "RIGHT" then
        return (frameDB.Width * 5) + (horizontalSpacing * 4), frameDB.Height
    end

    return frameDB.Width, (frameDB.Height * 5) + (verticalSpacing * 4)
end

local function GetTestRaidGroupLayoutOffsets(direction, groupWidth, groupHeight, horizontalSpacing, verticalSpacing)
    if direction == "DOWN_RIGHT" then
        return groupWidth + horizontalSpacing, 0, 0, -(groupHeight + verticalSpacing)
    elseif direction == "DOWN_LEFT" then
        return -(groupWidth + horizontalSpacing), 0, 0, -(groupHeight + verticalSpacing)
    elseif direction == "UP_RIGHT" then
        return groupWidth + horizontalSpacing, 0, 0, groupHeight + verticalSpacing
    elseif direction == "UP_LEFT" then
        return -(groupWidth + horizontalSpacing), 0, 0, groupHeight + verticalSpacing
    elseif direction == "RIGHT_DOWN" then
        return 0, -(groupHeight + verticalSpacing), groupWidth + horizontalSpacing, 0
    elseif direction == "RIGHT_UP" then
        return 0, groupHeight + verticalSpacing, groupWidth + horizontalSpacing, 0
    elseif direction == "LEFT_DOWN" then
        return 0, -(groupHeight + verticalSpacing), -(groupWidth + horizontalSpacing), 0
    elseif direction == "LEFT_UP" then
        return 0, groupHeight + verticalSpacing, -(groupWidth + horizontalSpacing), 0
    end

    return groupWidth + horizontalSpacing, 0, 0, -(groupHeight + verticalSpacing)
end

local function ApplyTestTag(fontString, ownerFrame, tagDB, generalDB, text)
    if not fontString or not tagDB then return end
    fontString:ClearAllPoints()
    fontString:SetPoint(tagDB.Layout[1], ownerFrame, tagDB.Layout[2], tagDB.Layout[3], tagDB.Layout[4])
    fontString:SetFont(UUF.Media.Font, tagDB.FontSize, generalDB.Fonts.FontFlag)
    if generalDB.Fonts.Shadow.Enabled then
        fontString:SetShadowColor(unpack(generalDB.Fonts.Shadow.Colour))
        fontString:SetShadowOffset(generalDB.Fonts.Shadow.XPos, generalDB.Fonts.Shadow.YPos)
    else
        fontString:SetShadowColor(0, 0, 0, 0)
        fontString:SetShadowOffset(0, 0)
    end
    fontString:SetTextColor(unpack(tagDB.Colour))
    fontString:SetText(text or "")
end

local function GetTestData(index, label)
    local dataIndex = ((index - 1) % #EnvironmenTestData) + 1
    local baseData = EnvironmenTestData[dataIndex]
    if not baseData then return end

    return {
        name = string.format("%s %d", label, index),
        class = baseData.class,
        reaction = baseData.reaction,
        health = baseData.health,
        maxHealth = baseData.maxHealth,
        missingHealth = baseData.missingHealth,
        absorb = baseData.absorb,
        percent = baseData.percent,
        maxPower = baseData.maxPower,
        power = baseData.power,
        powerType = baseData.powerType,
    }
end

local function ApplySharedTestFrameState(unitFrame, unitToken, unitDB, tagsDB, label, index, includeCastBar)
    local generalDB = UUF.db.profile.General
    local healthBarDB = unitDB.HealthBar
    local testData = GetTestData(index, label)
    if not testData then return end

    unitFrame:SetAttribute("unit", nil)
    UnregisterUnitWatch(unitFrame)
    unitFrame:SetFrameStrata(unitDB.Frame.FrameStrata)
    unitFrame:SetShown(unitDB.Enabled)

    if unitFrame.Health then
        unitFrame.Health:SetMinMaxValues(0, testData.maxHealth)
        unitFrame.Health:SetValue(testData.health)
        unitFrame.HealthBackground:SetMinMaxValues(0, testData.maxHealth)
        unitFrame.HealthBackground:SetValue(testData.missingHealth)
        unitFrame.HealthBackground:SetStatusBarColor(GetTestUnitColour(index, healthBarDB.Background, healthBarDB.ColourBackgroundByClass, healthBarDB.BackgroundOpacity))
        unitFrame.Health:SetStatusBarColor(GetTestUnitColour(index, healthBarDB.Foreground, healthBarDB.ColourByClass, healthBarDB.ForegroundOpacity))
    end

    if unitFrame.Power then
        unitFrame.Power:SetMinMaxValues(0, testData.maxPower)
        unitFrame.Power:SetValue(testData.power)
    end

    if unitFrame.RaidTargetIndicator and raidTargetMarkerCoords[((index - 1) % #raidTargetMarkerCoords) + 1] then
        unitFrame.RaidTargetIndicator:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
        unitFrame.RaidTargetIndicator:SetTexCoord(unpack(raidTargetMarkerCoords[((index - 1) % #raidTargetMarkerCoords) + 1]))
        unitFrame.RaidTargetIndicator:Show()
    end

    UUF:CreateTestAuras(unitFrame, unitToken)
    if includeCastBar then
        UUF:CreateTestCastBar(unitFrame, unitToken)
    end

    if unitFrame.Tags and tagsDB then
        ApplyTestTag(unitFrame.Tags.TagOne, unitFrame, tagsDB.TagOne, generalDB, testData.name)
        ApplyTestTag(unitFrame.Tags.TagTwo, unitFrame, tagsDB.TagTwo, generalDB, string.format("%.1f%%", testData.percent))
        ApplyTestTag(unitFrame.Tags.TagThree, unitFrame, tagsDB.TagThree, generalDB, tostring(testData.power))
        ApplyTestTag(unitFrame.Tags.TagFour, unitFrame, tagsDB.TagFour, generalDB, "")
        ApplyTestTag(unitFrame.Tags.TagFive, unitFrame, tagsDB.TagFive, generalDB, "")
    end
end

function UUF:EnsurePartyTestFrames()
    if #UUF.PARTY_TEST_FRAMES > 0 then return end

    oUF:SetActiveStyle(UUF:FetchFrameName("party"))

    for i = 1, UUF.MAX_PARTY_FRAMES do
        local frameName = "UUF_PartyTest" .. i
        local unitFrame = _G[frameName] or oUF:Spawn("party" .. i, frameName)
        unitFrame:SetAttribute("unit", nil)
        UnregisterUnitWatch(unitFrame)
        unitFrame:Hide()
        UUF.PARTY_TEST_FRAMES[i] = unitFrame
    end
end

function UUF:EnsureRaidTestFrames()
    if #UUF.RAID_TEST_FRAMES > 0 then return end

    oUF:SetActiveStyle(UUF:FetchFrameName("raid"))

    for i = 1, UUF.MAX_RAID_FRAMES do
        local frameName = "UUF_RaidTest" .. i
        local unitFrame = _G[frameName] or oUF:Spawn("raid" .. i, frameName)
        unitFrame:SetAttribute("unit", nil)
        UnregisterUnitWatch(unitFrame)
        unitFrame:Hide()
        UUF.RAID_TEST_FRAMES[i] = unitFrame
    end
end

function UUF:CreateTestPartyFrames()
    local partyDB = UUF.db.profile.Units.party
    local tagsDB = partyDB.Tags
    local previousAuraTestMode = UUF.AURA_TEST_MODE
    local previousCastBarTestMode = UUF.CASTBAR_TEST_MODE

    UUF:EnsurePartyTestFrames()
    UUF:ResolveLSM()

    if UUF.PARTY_TEST_MODE then
        if UUF.PARTY then
            UUF.PARTY:Hide()
        end

        UUF.AURA_TEST_MODE = true
        UUF.CASTBAR_TEST_MODE = true

        for i, partyFrame in ipairs(UUF.PARTY_TEST_FRAMES) do
            ApplySharedTestFrameState(partyFrame, "party" .. i, partyDB, tagsDB, "Party", i, true)

            if partyFrame.Portrait and PortraitOptions[((i - 1) % #PortraitOptions) + 1] then
                partyFrame.Portrait:SetTexture("Interface\\ICONS\\" .. PortraitOptions[((i - 1) % #PortraitOptions) + 1])
            end
        end
    else
        UUF.AURA_TEST_MODE = false
        UUF.CASTBAR_TEST_MODE = false

        for i, partyFrame in ipairs(UUF.PARTY_TEST_FRAMES) do
            UUF:CreateTestAuras(partyFrame, "party" .. i)
            UUF:CreateTestCastBar(partyFrame, "party" .. i)
            partyFrame:Hide()
        end

        if UUF.PARTY then
            UUF.PARTY:SetShown(partyDB.Enabled)
        end
    end

    UUF.AURA_TEST_MODE = previousAuraTestMode
    UUF.CASTBAR_TEST_MODE = previousCastBarTestMode
end

function UUF:CreateTestRaidFrames()
    local raidDB = UUF.db.profile.Units.raid
    local tagsDB = raidDB.Tags
    local frameDB = raidDB.Frame
    local previousAuraTestMode = UUF.AURA_TEST_MODE

    UUF:EnsureRaidTestFrames()
    UUF:ResolveLSM()

    if UUF.RAID_TEST_MODE then
        local direction = frameDB.GrowthDirection or "DOWN_RIGHT"
        local point = RAID_DIRECTION_TO_POINT[direction] or "TOP"
        local xSpacingMultiplier = ({
            DOWN_RIGHT = 1,
            DOWN_LEFT = -1,
            UP_RIGHT = 1,
            UP_LEFT = -1,
            RIGHT_DOWN = 1,
            RIGHT_UP = 1,
            LEFT_DOWN = -1,
            LEFT_UP = -1,
        })[direction] or 1
        local ySpacingMultiplier = ({
            DOWN_RIGHT = -1,
            DOWN_LEFT = -1,
            UP_RIGHT = 1,
            UP_LEFT = 1,
            RIGHT_DOWN = -1,
            RIGHT_UP = 1,
            LEFT_DOWN = -1,
            LEFT_UP = 1,
        })[direction] or -1
        local horizontalSpacing = frameDB.HorizontalSpacing or 0
        local verticalSpacing = frameDB.VerticalSpacing or 0
        local maxColumns = math.max(1, math.floor(frameDB.MaxColumns or 8))
        local unitsPerColumn = math.max(1, math.floor(frameDB.UnitsPerColumn or 5))
        local groupByGroup = frameDB.GroupBy == "GROUP"
        local groupWidth, groupHeight = GetTestRaidGroupHeaderDimensions(frameDB)
        local lineStepX, lineStepY, wrapStepX, wrapStepY = GetTestRaidGroupLayoutOffsets(direction, groupWidth, groupHeight, horizontalSpacing, verticalSpacing)
        local filteredGroups = {}
        local hasFilteredGroups = false
        local visibleGroupIndices = {}
        local visibleFrameIndex = 0

        if type(frameDB.GroupFilter) == "string" and strtrim(frameDB.GroupFilter) ~= "" then
            for groupID in frameDB.GroupFilter:gmatch("%d+") do
                local groupIndex = tonumber(groupID)
                if groupIndex and groupIndex >= 1 and groupIndex <= UUF.MAX_RAID_GROUPS then
                    filteredGroups[groupIndex] = true
                    hasFilteredGroups = true
                end
            end
        end

        if groupByGroup then
            local visibleGroupCount = 0
            for groupIndex = 1, UUF.MAX_RAID_GROUPS do
                if not hasFilteredGroups or filteredGroups[groupIndex] then
                    visibleGroupCount = visibleGroupCount + 1
                    visibleGroupIndices[groupIndex] = visibleGroupCount
                end
            end
        end

        if UUF.RAID then
            UUF.RAID:Hide()
        end

        for _, header in ipairs(UUF.RAID_GROUP_HEADERS) do
            if header then
                header:Hide()
            end
        end

        UUF.AURA_TEST_MODE = true

        for index, raidFrame in ipairs(UUF.RAID_TEST_FRAMES) do
            local groupIndex = math.floor((index - 1) / 5) + 1
            if hasFilteredGroups and not filteredGroups[groupIndex] then
                raidFrame:Hide()
            else
                visibleFrameIndex = visibleFrameIndex + 1
                ApplySharedTestFrameState(raidFrame, "raid" .. index, raidDB, tagsDB, "Raid", index, false)
                raidFrame:SetSize(frameDB.Width, frameDB.Height)
                raidFrame:ClearAllPoints()

                if groupByGroup then
                    local groupedIndex = (visibleGroupIndices[groupIndex] or groupIndex) - 1
                    local indexInGroup = (index - 1) % 5
                    local lineIndex = groupedIndex % maxColumns
                    local wrapIndex = math.floor(groupedIndex / maxColumns)
                    local groupBaseX = frameDB.Layout[3] + (lineStepX * lineIndex) + (wrapStepX * wrapIndex)
                    local groupBaseY = frameDB.Layout[4] + (lineStepY * lineIndex) + (wrapStepY * wrapIndex)

                    local offsetX = 0
                    local offsetY = 0
                    if point == "LEFT" or point == "RIGHT" then
                        offsetX = (frameDB.Width + horizontalSpacing) * indexInGroup * xSpacingMultiplier
                    else
                        offsetY = (frameDB.Height + verticalSpacing) * indexInGroup * ySpacingMultiplier
                    end

                    raidFrame:SetPoint(frameDB.Layout[1], UIParent, frameDB.Layout[2], groupBaseX + offsetX, groupBaseY + offsetY)
                else
                    local lineIndex = (visibleFrameIndex - 1) % unitsPerColumn
                    local wrapIndex = math.floor((visibleFrameIndex - 1) / unitsPerColumn)
                    local offsetX = 0
                    local offsetY = 0

                    if point == "LEFT" or point == "RIGHT" then
                        offsetX = (frameDB.Width + horizontalSpacing) * lineIndex * xSpacingMultiplier
                        offsetY = (frameDB.Height + verticalSpacing) * wrapIndex * ySpacingMultiplier
                    else
                        offsetX = (frameDB.Width + horizontalSpacing) * wrapIndex * xSpacingMultiplier
                        offsetY = (frameDB.Height + verticalSpacing) * lineIndex * ySpacingMultiplier
                    end

                    raidFrame:SetPoint(frameDB.Layout[1], UIParent, frameDB.Layout[2], frameDB.Layout[3] + offsetX, frameDB.Layout[4] + offsetY)
                end
            end
        end
    else
        UUF.AURA_TEST_MODE = false

        for index, raidFrame in ipairs(UUF.RAID_TEST_FRAMES) do
            UUF:CreateTestAuras(raidFrame, "raid" .. index)
            raidFrame:Hide()
        end

        if UUF.RAID then
            UUF.RAID:SetShown(raidDB.Enabled and frameDB.GroupBy ~= "GROUP")
        end
    end

    UUF.AURA_TEST_MODE = previousAuraTestMode
end

function UUF:CreateTestBossFrames()
    local General = UUF.db.profile.General
    local AuraDurationDB = UUF.db.profile.Units.boss.Auras.AuraDuration
    local BuffsDB = UUF.db.profile.Units.boss.Auras.Buffs
    local DebuffsDB = UUF.db.profile.Units.boss.Auras.Debuffs
    local TagsDB = UUF.db.profile.Units.boss.Tags
    UUF:ResolveLSM()
    local BossDB = UUF.db.profile.Units.boss
    if UUF.BOSS_TEST_MODE then
        for i, BossFrame in ipairs(UUF.BOSS_FRAMES) do
            BossFrame:SetAttribute("unit", nil)
            UnregisterUnitWatch(BossFrame)
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
                BossFrame.Portrait:SetTexture("Interface\\ICONS\\" .. PortraitOptions[i])
            end

            if BossFrame.Power then
                BossFrame.Power:SetMinMaxValues(0, EnvironmenTestData[i].maxPower)
                BossFrame.Power:SetValue(EnvironmenTestData[i].power)
            end

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
                    BossFrame.Castbar.Text:SetText("Ethereal Portal")
                    BossFrame.Castbar.Time:SetText("0.0")
                    BossFrame.Castbar:SetMinMaxValues(0, 1000)
                    BossFrame.Castbar:SetScript("OnUpdate", function() local currentValue = BossFrame.Castbar:GetValue() currentValue = currentValue + 1 if currentValue >= 1000 then currentValue = 0 end BossFrame.Castbar:SetValue(currentValue) BossFrame.Castbar.Time:SetText(string.format("%.1f", (currentValue / 1000) * 5)) end)
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
                        button.Duration:ClearAllPoints()
                        button.Duration:SetPoint(AuraDurationDB.Layout[1], button, AuraDurationDB.Layout[2], AuraDurationDB.Layout[3], AuraDurationDB.Layout[4])
                        if AuraDurationDB.ScaleByIconSize then
                            local iconWidth = button:GetWidth()
                            local scaleFactor = iconWidth / 36
                            button.Duration:SetFont(UUF.Media.Font, AuraDurationDB.FontSize * scaleFactor, General.Fonts.FontFlag)
                        else
                            button.Duration:SetFont(UUF.Media.Font, AuraDurationDB.FontSize, General.Fonts.FontFlag)
                        end
                        if General.Fonts.Shadow.Enabled then
                            button.Duration:SetShadowColor(unpack(General.Fonts.Shadow.Colour))
                            button.Duration:SetShadowOffset(General.Fonts.Shadow.XPos, General.Fonts.Shadow.YPos)
                        else
                            button.Duration:SetShadowColor(0, 0, 0, 0)
                            button.Duration:SetShadowOffset(0, 0)
                        end
                        button.Duration:SetTextColor(AuraDurationDB.Colour[1], AuraDurationDB.Colour[2], AuraDurationDB.Colour[3], 1)
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
                        button.Duration:ClearAllPoints()
                        button.Duration:SetPoint(AuraDurationDB.Layout[1], button, AuraDurationDB.Layout[2], AuraDurationDB.Layout[3], AuraDurationDB.Layout[4])
                        if AuraDurationDB.ScaleByIconSize then
                            local iconWidth = button:GetWidth()
                            local scaleFactor = iconWidth / 36
                            button.Duration:SetFont(UUF.Media.Font, AuraDurationDB.FontSize * scaleFactor, General.Fonts.FontFlag)
                        else
                            button.Duration:SetFont(UUF.Media.Font, AuraDurationDB.FontSize, General.Fonts.FontFlag)
                        end
                        if General.Fonts.Shadow.Enabled then
                            button.Duration:SetShadowColor(unpack(General.Fonts.Shadow.Colour))
                            button.Duration:SetShadowOffset(General.Fonts.Shadow.XPos, General.Fonts.Shadow.YPos)
                        else
                            button.Duration:SetShadowColor(0, 0, 0, 0)
                            button.Duration:SetShadowOffset(0, 0)
                        end
                        button.Duration:SetTextColor(AuraDurationDB.Colour[1], AuraDurationDB.Colour[2], AuraDurationDB.Colour[3], 1)
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
            for j = 1, (BossFrame.BuffContainer and BossFrame.BuffContainer.maxFake or 0) do
                local button = BossFrame.BuffContainer["fake" .. j]
                if button then button:Hide() end
            end
            for j = 1, (BossFrame.DebuffContainer and BossFrame.DebuffContainer.maxFake or 0) do
                local button = BossFrame.DebuffContainer["fake" .. j]
                if button then button:Hide() end
            end
            BossFrame:Hide()
        end
    end
end
