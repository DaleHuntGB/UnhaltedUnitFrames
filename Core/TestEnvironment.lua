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
        incomingHeal = i * 180000,
        absorb    = (i * 300000),
        healAbsorb = i * 120000,
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

local function UntagFrameTags(unitFrame)
    if not unitFrame or not unitFrame.Tags then return end
    for _, fs in pairs(unitFrame.Tags) do
        if fs then
            unitFrame:Untag(fs)
            fs.UUFTagString = nil
        end
    end
end

local function ApplyTestTag(fontString, ownerFrame, tagDB, generalDB, text)
    if not fontString or not tagDB then return end
    local anchorFrame = ownerFrame.HighLevelContainer or ownerFrame
    local xOffset, yOffset = UUF:GetPixelSnappedOffsets(anchorFrame, tagDB.Layout[2], tagDB.Layout[3], tagDB.Layout[4])
    fontString:ClearAllPoints()
    fontString:SetPoint(tagDB.Layout[1], anchorFrame, tagDB.Layout[2], xOffset, yOffset)
    fontString:SetJustifyH(UUF:SetJustification(tagDB.Layout[1]))
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
    fontString:Show()
end

local function GetTestTagPreview(tagDB, label, index)
    if not tagDB or not tagDB.Tag or tagDB.Tag == "" then
        return ""
    end

    local tagText = strtrim(tagDB.Tag)
    if tagText == "[name]" then
        return string.format("%s %d", label, index)
    end

    return tagText
end

local function GetTestUnitLabel(label, index)
    return string.format("%s %d", label, index)
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
        incomingHeal = baseData.incomingHeal,
        absorb = baseData.absorb,
        healAbsorb = baseData.healAbsorb,
        percent = baseData.percent,
        maxPower = baseData.maxPower,
        power = baseData.power,
        powerType = baseData.powerType,
    }
end

local function UseGroupedRaidHeadersForTestEnvironment()
    local raidDB = UUF.db and UUF.db.profile and UUF.db.profile.Units and UUF.db.profile.Units.raid
    if not (raidDB and raidDB.Frame) then return false end
    if raidDB.Frame.GroupBy == "CLASS" then
        raidDB.Frame.GroupBy = "GROUP"
    end
    return raidDB.Frame.GroupBy == "GROUP"
end

local function UpdateLiveGroupedFrameVisibility()
    local hideLiveGroupedFrames = UUF.PARTY_TEST_MODE or UUF.RAID_TEST_MODE
    local partyDB = UUF.db.profile.Units.party
    local raidDB = UUF.db.profile.Units.raid
    local useGroupedRaidHeaders = UseGroupedRaidHeadersForTestEnvironment()

    if UUF.PARTY then
        if hideLiveGroupedFrames then
            UUF.PARTY:SetVisibility("hide")
            UUF.PARTY:Hide()
        elseif partyDB.Enabled then
            UUF.PARTY:SetVisibility("custom [group:party,nogroup:raid] show; hide")
        else
            UUF.PARTY:SetVisibility("hide")
            UUF.PARTY:Hide()
        end
    end

    if UUF.RAID then
        if hideLiveGroupedFrames then
            UUF.RAID:SetVisibility("hide")
            UUF.RAID:Hide()
        elseif raidDB.Enabled and not useGroupedRaidHeaders then
            UUF.RAID:SetVisibility("custom [group:raid] show; hide")
        else
            UUF.RAID:SetVisibility("hide")
            UUF.RAID:Hide()
        end
    end

    for _, header in ipairs(UUF.RAID_GROUP_HEADERS) do
        if header then
            if hideLiveGroupedFrames then
                header:SetVisibility("hide")
                header:Hide()
            elseif raidDB.Enabled and useGroupedRaidHeaders then
                header:SetVisibility("custom [group:raid] show; hide")
            else
                header:SetVisibility("hide")
                header:Hide()
            end
        end
    end
end

local function ApplyTestHealPredictionState(unitFrame, unitToken, testData)
    if not unitFrame or not unitFrame.Health or not testData then return end

    UUF:UpdateUnitHealPrediction(unitFrame, unitToken)

    local healthPrediction = unitFrame.HealthPrediction
    if not healthPrediction then return end

    if healthPrediction.healingAll then
        healthPrediction.healingAll:SetMinMaxValues(0, testData.maxHealth)
        healthPrediction.healingAll:SetValue(testData.incomingHeal or 0)
        healthPrediction.healingAll:Show()
    end

    if healthPrediction.damageAbsorb then
        healthPrediction.damageAbsorb:SetMinMaxValues(0, testData.maxHealth)
        healthPrediction.damageAbsorb:SetValue(testData.absorb or 0)
        healthPrediction.damageAbsorb:Show()
    end

    if healthPrediction.healAbsorb then
        healthPrediction.healAbsorb:SetMinMaxValues(0, testData.maxHealth)
        healthPrediction.healAbsorb:SetValue(testData.healAbsorb or 0)
        healthPrediction.healAbsorb:Show()
    end
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
    unitFrame:SetAlpha(1)

    if unitFrame.Container then
        unitFrame.Container:Show()
    end

    if unitFrame.HighLevelContainer then
        unitFrame.HighLevelContainer:Show()
    end

    if unitFrame.Health then
        unitFrame.Health:Show()
        unitFrame.Health:SetStatusBarTexture(UUF.Media.Foreground)
        unitFrame.Health:SetMinMaxValues(0, testData.maxHealth)
        unitFrame.Health:SetValue(testData.health)
    end

    if unitFrame.HealthBackground then
        unitFrame.HealthBackground:Show()
        unitFrame.HealthBackground:SetStatusBarTexture(UUF.Media.Background)
        unitFrame.HealthBackground:SetMinMaxValues(0, testData.maxHealth)
        unitFrame.HealthBackground:SetValue(testData.missingHealth)
        unitFrame.HealthBackground:SetStatusBarColor(GetTestUnitColour(index, healthBarDB.Background, healthBarDB.ColourBackgroundByClass, healthBarDB.BackgroundOpacity))
    end

    if unitFrame.Health then
        unitFrame.Health:SetStatusBarColor(GetTestUnitColour(index, healthBarDB.Foreground, healthBarDB.ColourByClass, healthBarDB.ForegroundOpacity))
    end

    ApplyTestHealPredictionState(unitFrame, unitToken, testData)

    if unitFrame.Power then
        unitFrame.Power:SetStatusBarTexture(UUF.Media.Foreground)
        unitFrame.Power:SetMinMaxValues(0, testData.maxPower)
        unitFrame.Power:SetValue(testData.power)
        if unitFrame.Power.Background then
            unitFrame.Power.Background:SetTexture(UUF.Media.Background)
        end
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

    if tagsDB then
        if not unitFrame.Tags then
            UUF:CreateUnitTags(unitFrame, unitToken)
        end

        UntagFrameTags(unitFrame)

        ApplyTestTag(unitFrame.Tags.TagOne, unitFrame, tagsDB.TagOne, generalDB, GetTestUnitLabel(label, index))
        ApplyTestTag(unitFrame.Tags.TagTwo, unitFrame, tagsDB.TagTwo, generalDB, GetTestTagPreview(tagsDB.TagTwo, label, index))
        ApplyTestTag(unitFrame.Tags.TagThree, unitFrame, tagsDB.TagThree, generalDB, GetTestTagPreview(tagsDB.TagThree, label, index))
        ApplyTestTag(unitFrame.Tags.TagFour, unitFrame, tagsDB.TagFour, generalDB, GetTestTagPreview(tagsDB.TagFour, label, index))
        ApplyTestTag(unitFrame.Tags.TagFive, unitFrame, tagsDB.TagFive, generalDB, GetTestTagPreview(tagsDB.TagFive, label, index))
    end
end

local function RefreshTestRaidFrameTags(unitFrame, tagsDB, index)
    if not unitFrame or not unitFrame.Tags or not tagsDB then return end

    local generalDB = UUF.db.profile.General
    ApplyTestTag(unitFrame.Tags.TagOne, unitFrame, tagsDB.TagOne, generalDB, GetTestUnitLabel("Raid", index))
    ApplyTestTag(unitFrame.Tags.TagTwo, unitFrame, tagsDB.TagTwo, generalDB, GetTestTagPreview(tagsDB.TagTwo, "Raid", index))
    ApplyTestTag(unitFrame.Tags.TagThree, unitFrame, tagsDB.TagThree, generalDB, GetTestTagPreview(tagsDB.TagThree, "Raid", index))
    ApplyTestTag(unitFrame.Tags.TagFour, unitFrame, tagsDB.TagFour, generalDB, GetTestTagPreview(tagsDB.TagFour, "Raid", index))
    ApplyTestTag(unitFrame.Tags.TagFive, unitFrame, tagsDB.TagFive, generalDB, GetTestTagPreview(tagsDB.TagFive, "Raid", index))
end

function UUF:ReleasePartyTestFrames()
    local pool = UUF.TEST_FRAME_POOL.party
    for i, frame in ipairs(UUF.PARTY_TEST_FRAMES) do
        pool[i] = frame
    end
    wipe(UUF.PARTY_TEST_FRAMES)
end

function UUF:ReleaseRaidTestFrames()
    local pool = UUF.TEST_FRAME_POOL.raid
    for i, frame in ipairs(UUF.RAID_TEST_FRAMES) do
        pool[i] = frame
    end
    wipe(UUF.RAID_TEST_FRAMES)
end

function UUF:AcquirePartyTestFrames()
    if #UUF.PARTY_TEST_FRAMES > 0 then return end
    if not UUF.PARTY_TEST_MODE then return end

    local pool = UUF.TEST_FRAME_POOL.party
    if #pool >= UUF.MAX_PARTY_FRAMES then
        for i = 1, UUF.MAX_PARTY_FRAMES do
            UUF.PARTY_TEST_FRAMES[i] = pool[i]
        end
        wipe(pool)
        return
    end

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

function UUF:AcquireRaidTestFrames()
    if #UUF.RAID_TEST_FRAMES > 0 then return end
    if not UUF.RAID_TEST_MODE then return end

    local pool = UUF.TEST_FRAME_POOL.raid
    if #pool >= UUF.MAX_RAID_FRAMES then
        for i = 1, UUF.MAX_RAID_FRAMES do
            UUF.RAID_TEST_FRAMES[i] = pool[i]
        end
        wipe(pool)
        return
    end

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

    UUF:AcquirePartyTestFrames()
    UUF:ResolveLSM()
    UpdateLiveGroupedFrameVisibility()

    if UUF.PARTY_TEST_MODE then
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
        UUF:ReleasePartyTestFrames()

    end

    UpdateLiveGroupedFrameVisibility()
    UUF.AURA_TEST_MODE = previousAuraTestMode
    UUF.CASTBAR_TEST_MODE = previousCastBarTestMode
end

function UUF:CreateTestRaidFrames()
    local raidDB = UUF.db.profile.Units.raid
    local tagsDB = raidDB.Tags
    local frameDB = raidDB.Frame
    local previousAuraTestMode = UUF.AURA_TEST_MODE

    UUF:AcquireRaidTestFrames()
    UUF:ResolveLSM()
    UpdateLiveGroupedFrameVisibility()

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

                RefreshTestRaidFrameTags(raidFrame, tagsDB, index)
            end
        end
    else
        UUF.AURA_TEST_MODE = false

        for index, raidFrame in ipairs(UUF.RAID_TEST_FRAMES) do
            UUF:CreateTestAuras(raidFrame, "raid" .. index)
            raidFrame:Hide()
        end
        UUF:ReleaseRaidTestFrames()

    end

    UpdateLiveGroupedFrameVisibility()
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
            local testData = EnvironmenTestData[i]
            BossFrame:SetAttribute("unit", nil)
            UnregisterUnitWatch(BossFrame)
            if BossDB.Enabled then BossFrame:Show() else BossFrame:Hide() end

            BossFrame:SetFrameStrata(BossDB.Frame.FrameStrata)

            if BossFrame.Health and testData then
                local HealthBarDB = UUF.db.profile.Units.boss.HealthBar
                BossFrame.Health:SetMinMaxValues(0, testData.maxHealth)
                BossFrame.Health:SetValue(testData.health)
                BossFrame.HealthBackground:SetMinMaxValues(0, testData.maxHealth)
                BossFrame.HealthBackground:SetValue(testData.missingHealth)
                BossFrame.HealthBackground:SetStatusBarColor(GetTestUnitColour(i, HealthBarDB.Background, HealthBarDB.ColourBackgroundByClass, HealthBarDB.BackgroundOpacity))
                BossFrame.Health:SetStatusBarColor(GetTestUnitColour(i, HealthBarDB.Foreground, HealthBarDB.ColourByClass, HealthBarDB.ForegroundOpacity))
                ApplyTestHealPredictionState(BossFrame, "boss" .. i, testData)
            end

            if BossFrame.Portrait then
                BossFrame.Portrait:SetTexture("Interface\\ICONS\\" .. PortraitOptions[i])
            end

            if BossFrame.Power and testData then
                BossFrame.Power:SetMinMaxValues(0, testData.maxPower)
                BossFrame.Power:SetValue(testData.power)
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
                    BossFrame.Castbar.testValue = 0
                    BossFrame.Castbar:SetScript("OnUpdate", function(self)
                        self.testValue = (self.testValue or 0) + 1
                        if self.testValue >= 1000 then self.testValue = 0 end
                        self:SetValue(self.testValue)
                        self.Time:SetText(string.format("%.1f", (self.testValue / 1000) * 5))
                    end)
                    local castBarColour = (false and CastBarDB.NotInterruptibleColour) or (CastBarDB.ColourByClass and UUF:GetClassColour(BossFrame)) or CastBarDB.Foreground
                    BossFrame.Castbar:SetStatusBarColor(castBarColour[1], castBarColour[2], castBarColour[3], castBarColour[4])
                    if BossFrame.Castbar.NotInterruptibleOverlay then
                        BossFrame.Castbar.NotInterruptibleOverlay:SetAlpha(0)
                    end
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

            if BossFrame.Tags then
                UntagFrameTags(BossFrame)
                ApplyTestTag(BossFrame.Tags.TagOne, BossFrame, TagsDB.TagOne, General, GetTestUnitLabel("Boss", i))
                ApplyTestTag(BossFrame.Tags.TagTwo, BossFrame, TagsDB.TagTwo, General, GetTestTagPreview(TagsDB.TagTwo, "Boss", i))
                ApplyTestTag(BossFrame.Tags.TagThree, BossFrame, TagsDB.TagThree, General, GetTestTagPreview(TagsDB.TagThree, "Boss", i))
                ApplyTestTag(BossFrame.Tags.TagFour, BossFrame, TagsDB.TagFour, General, GetTestTagPreview(TagsDB.TagFour, "Boss", i))
                ApplyTestTag(BossFrame.Tags.TagFive, BossFrame, TagsDB.TagFive, General, GetTestTagPreview(TagsDB.TagFive, "Boss", i))
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
