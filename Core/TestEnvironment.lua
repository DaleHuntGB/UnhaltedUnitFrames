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
            if BossFrame:IsElementEnabled("Auras") then BossFrame:DisableElement("Auras") end
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
                BossFrame.Portrait:SetTexture("Interface\\ICONS\\" .. PortraitOptions[i])
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
            if not BossFrame:IsElementEnabled("Auras") then BossFrame:EnableElement("Auras") end
            BossFrame:Hide()
        end
    end
end

local PartyTestData = {}
for i = 1, 4 do
    PartyTestData[i] = {
        name      = "Party " .. i,
        class     = EnvironmenTestData[i].class,
        reaction  = 5,
        health    = 150000 - (i * 20000),
        maxHealth = 150000,
        missingHealth = i * 20000,
        absorb    = (i * 10000),
        percent  = (150000 - (i * 20000)) / 150000 * 100,
        maxPower  = 100,
        power     = 100 - (i * 15),
        powerType = EnvironmenTestData[i].powerType,
    }
end

function UUF:CreateTestPartyFrames()
    local General = UUF.db.profile.General
    local AuraDurationDB = UUF.db.profile.Units.party.Auras.AuraDuration
    local BuffsDB = UUF.db.profile.Units.party.Auras.Buffs
    local DebuffsDB = UUF.db.profile.Units.party.Auras.Debuffs
    local TagsDB = UUF.db.profile.Units.party.Tags
    UUF:ResolveLSM()
    local PartyDB = UUF.db.profile.Units.party
    if UUF.PARTY_TEST_MODE then
        for i, PartyFrame in ipairs(UUF.PARTY_FRAMES) do
            PartyFrame:SetAttribute("unit", nil)
            UnregisterUnitWatch(PartyFrame)
            if PartyFrame:IsElementEnabled("Auras") then PartyFrame:DisableElement("Auras") end
            if PartyDB.Enabled then PartyFrame:Show() else PartyFrame:Hide() end

            PartyFrame:SetFrameStrata(PartyDB.Frame.FrameStrata)

            if PartyFrame.Health then
                local HealthBarDB = UUF.db.profile.Units.party.HealthBar
                PartyFrame.Health:SetMinMaxValues(0, PartyTestData[i].maxHealth)
                PartyFrame.Health:SetValue(PartyTestData[i].health)
                PartyFrame.HealthBackground:SetMinMaxValues(0, PartyTestData[i].maxHealth)
                PartyFrame.HealthBackground:SetValue(PartyTestData[i].missingHealth)
                PartyFrame.HealthBackground:SetStatusBarColor(GetTestUnitColour(i, HealthBarDB.Background, HealthBarDB.ColourBackgroundByClass, HealthBarDB.BackgroundOpacity))
                PartyFrame.Health:SetStatusBarColor(GetTestUnitColour(i, HealthBarDB.Foreground, HealthBarDB.ColourByClass, HealthBarDB.ForegroundOpacity))
            end

            if PartyFrame.Portrait then
                local PortraitOptions = {
                    [1] = "achievement_character_human_female",
                    [2] = "achievement_character_human_male",
                    [3] = "achievement_character_dwarf_male",
                    [4] = "achievement_character_dwarf_female",
                }
                PartyFrame.Portrait:SetTexture("Interface\\ICONS\\" .. PortraitOptions[i])
            end

            if PartyFrame.Power then
                PartyFrame.Power:SetMinMaxValues(0, PartyTestData[i].maxPower)
                PartyFrame.Power:SetValue(PartyTestData[i].power)
            end

            local raidTargetMarkerCoords = {{0,0.25,0,0.25},{0.25,0.5,0,0.25},{0.5,0.75,0,0.25},{0.75,1,0,0.25}}
            if PartyFrame.RaidTargetIndicator and i and raidTargetMarkerCoords[i] then
                PartyFrame.RaidTargetIndicator:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
                PartyFrame.RaidTargetIndicator:SetTexCoord(unpack(raidTargetMarkerCoords[i]))
                PartyFrame.RaidTargetIndicator:Show()
            end

            if PartyFrame.Castbar then
                local CastBarDB = UUF.db.profile.Units.party.CastBar
                local CastBarContainer = PartyFrame.Castbar and PartyFrame.Castbar:GetParent()
                if PartyFrame.Castbar and CastBarDB.Enabled then
                    PartyFrame:DisableElement("Castbar")
                    CastBarContainer:Show()
                    PartyFrame.Castbar:Show()
                    PartyFrame.Castbar.Background:Show()
                    PartyFrame.Castbar.Text:SetText("Ethereal Portal")
                    PartyFrame.Castbar.Time:SetText("0.0")
                    PartyFrame.Castbar:SetMinMaxValues(0, 1000)
                    PartyFrame.Castbar:SetScript("OnUpdate", function() local currentValue = PartyFrame.Castbar:GetValue() currentValue = currentValue + 1 if currentValue >= 1000 then currentValue = 0 end PartyFrame.Castbar:SetValue(currentValue) PartyFrame.Castbar.Time:SetText(string.format("%.1f", (currentValue / 1000) * 5)) end)
                    local castBarColour = (false and CastBarDB.NotInterruptibleColour) or (CastBarDB.ColourByClass and UUF:GetClassColour(PartyFrame)) or CastBarDB.Foreground
                    PartyFrame.Castbar:SetStatusBarColor(castBarColour[1], castBarColour[2], castBarColour[3], castBarColour[4])
                    if CastBarDB.Icon.Enabled and PartyFrame.Castbar.Icon then PartyFrame.Castbar.Icon:SetTexture("Interface\\Icons\\ability_mage_netherwindpresence") PartyFrame.Castbar.Icon:Show() end
                else
                    if CastBarContainer then CastBarContainer:Hide() end
                    if PartyFrame.Castbar and PartyFrame.Castbar.Icon then PartyFrame.Castbar.Icon:Hide() end
                end
            end

            if PartyFrame.BuffContainer then
                if BuffsDB.Enabled then
                    PartyFrame.BuffContainer:ClearAllPoints()
                    PartyFrame.BuffContainer:SetPoint(BuffsDB.Layout[1], PartyFrame, BuffsDB.Layout[2], BuffsDB.Layout[3], BuffsDB.Layout[4])
                    PartyFrame.BuffContainer:Show()

                    for j = 1, BuffsDB.Num do
                        local button = PartyFrame.BuffContainer["fake" .. j]
                        if not button then
                            button = CreateFrame("Button", nil, PartyFrame.BuffContainer, "BackdropTemplate")
                            button:SetBackdrop(UUF.BACKDROP)
                            button:SetBackdropColor(0, 0, 0, 0)
                            button:SetBackdropBorderColor(0, 0, 0, 1)
                            button:SetFrameStrata("MEDIUM")

                            button.Icon = button:CreateTexture(nil, "BORDER")
                            button.Icon:SetAllPoints()

                            button.Count = button:CreateFontString(nil, "OVERLAY")
                            PartyFrame.BuffContainer["fake" .. j] = button
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
                        button:SetPoint(BuffsDB.Layout[1], PartyFrame.BuffContainer, BuffsDB.Layout[1], x, y)

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
                    for j = maxFake + 1, (PartyFrame.BuffContainer.maxFake or maxFake) do
                        local button = PartyFrame.BuffContainer["fake" .. j]
                        if button then button:Hide() end
                    end
                    PartyFrame.BuffContainer.maxFake = BuffsDB.Num
                else
                    PartyFrame.BuffContainer:Hide()
                end
            end

            if PartyFrame.DebuffContainer then
                if DebuffsDB.Enabled then
                    PartyFrame.DebuffContainer:ClearAllPoints()
                    PartyFrame.DebuffContainer:SetPoint(DebuffsDB.Layout[1], PartyFrame, DebuffsDB.Layout[2], DebuffsDB.Layout[3], DebuffsDB.Layout[4])
                    PartyFrame.DebuffContainer:Show()

                    for j = 1, DebuffsDB.Num do
                        local button = PartyFrame.DebuffContainer["fake" .. j]
                        if not button then
                            button = CreateFrame("Button", nil, PartyFrame.DebuffContainer, "BackdropTemplate")
                            button:SetBackdrop(UUF.BACKDROP)
                            button:SetBackdropColor(0, 0, 0, 0)
                            button:SetBackdropBorderColor(0, 0, 0, 1)
                            button:SetFrameStrata("MEDIUM")

                            button.Icon = button:CreateTexture(nil, "BORDER")
                            button.Icon:SetAllPoints()

                            button.Count = button:CreateFontString(nil, "OVERLAY")
                            PartyFrame.DebuffContainer["fake" .. j] = button
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
                        button:SetPoint(DebuffsDB.Layout[1], PartyFrame.DebuffContainer, DebuffsDB.Layout[1], x, y)

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

                    local maxFake = DebuffsDB.Num
                    for j = maxFake + 1, (PartyFrame.DebuffContainer.maxFake or maxFake) do
                        local button = PartyFrame.DebuffContainer["fake" .. j]
                        if button then button:Hide() end
                    end
                    PartyFrame.DebuffContainer.maxFake = DebuffsDB.Num
                else
                    PartyFrame.DebuffContainer:Hide()
                end
            end

            if PartyFrame.TargetIndicator then
                local TargetIndicatorDB = UUF.db.profile.Units.party.Indicators.Target
                if TargetIndicatorDB.Enabled and i % 2 == 1 then
                    PartyFrame.TargetIndicator:Show()
                else
                    PartyFrame.TargetIndicator:Hide()
                end
            end

            if PartyFrame.LeaderIndicator then
                local LeaderAssistantDB = UUF.db.profile.Units.party.Indicators.LeaderAssistantIndicator
                if LeaderAssistantDB.Enabled then
                    PartyFrame.LeaderIndicator:SetSize(LeaderAssistantDB.Size, LeaderAssistantDB.Size)
                    PartyFrame.LeaderIndicator:ClearAllPoints()
                    PartyFrame.LeaderIndicator:SetPoint(LeaderAssistantDB.Layout[1], PartyFrame.HighLevelContainer, LeaderAssistantDB.Layout[2], LeaderAssistantDB.Layout[3], LeaderAssistantDB.Layout[4])
                    if i == 1 then PartyFrame.LeaderIndicator:Show() else PartyFrame.LeaderIndicator:Hide() end
                else
                    PartyFrame.LeaderIndicator:Hide()
                end
            end

            if PartyFrame.AssistantIndicator then
                local LeaderAssistantDB = UUF.db.profile.Units.party.Indicators.LeaderAssistantIndicator
                if LeaderAssistantDB.Enabled then
                    PartyFrame.AssistantIndicator:SetSize(LeaderAssistantDB.Size, LeaderAssistantDB.Size)
                    PartyFrame.AssistantIndicator:ClearAllPoints()
                    PartyFrame.AssistantIndicator:SetPoint(LeaderAssistantDB.Layout[1], PartyFrame.HighLevelContainer, LeaderAssistantDB.Layout[2], LeaderAssistantDB.Layout[3], LeaderAssistantDB.Layout[4])
                    if i == 2 then PartyFrame.AssistantIndicator:Show() else PartyFrame.AssistantIndicator:Hide() end
                else
                    PartyFrame.AssistantIndicator:Hide()
                end
            end

            if PartyFrame.RoleIndicator then
                local RoleDB = UUF.db.profile.Units.party.Indicators.Role
                if RoleDB.Enabled then
                    PartyFrame.RoleIndicator:SetSize(RoleDB.Size, RoleDB.Size)
                    PartyFrame.RoleIndicator:ClearAllPoints()
                    PartyFrame.RoleIndicator:SetPoint(RoleDB.Layout[1], PartyFrame.HighLevelContainer, RoleDB.Layout[2], RoleDB.Layout[3], RoleDB.Layout[4])
                    local roles = { "roleIcon-tank", "roleIcon-healer", "roleIcon-dps", "roleIcon-dps" }
                    PartyFrame.RoleIndicator:SetAtlas(roles[i] or "roleIcon-dps", true)
                    PartyFrame.RoleIndicator:Show()
                else
                    PartyFrame.RoleIndicator:Hide()
                end
            end

            if PartyFrame.SummonIndicator then
                local SummonDB = UUF.db.profile.Units.party.Indicators.Summon
                if SummonDB.Enabled then
                    PartyFrame.SummonIndicator:SetSize(SummonDB.Size, SummonDB.Size)
                    PartyFrame.SummonIndicator:ClearAllPoints()
                    PartyFrame.SummonIndicator:SetPoint(SummonDB.Layout[1], PartyFrame.HighLevelContainer, SummonDB.Layout[2], SummonDB.Layout[3], SummonDB.Layout[4])
                    if i == 3 then PartyFrame.SummonIndicator:Show() else PartyFrame.SummonIndicator:Hide() end
                else
                    PartyFrame.SummonIndicator:Hide()
                end
            end

            if PartyFrame.ResurrectIndicator then
                local ResurrectDB = UUF.db.profile.Units.party.Indicators.Resurrection
                if ResurrectDB.Enabled then
                    PartyFrame.ResurrectIndicator:SetSize(ResurrectDB.Size, ResurrectDB.Size)
                    PartyFrame.ResurrectIndicator:ClearAllPoints()
                    PartyFrame.ResurrectIndicator:SetPoint(ResurrectDB.Layout[1], PartyFrame.HighLevelContainer, ResurrectDB.Layout[2], ResurrectDB.Layout[3], ResurrectDB.Layout[4])
                    if i == 2 then PartyFrame.ResurrectIndicator:Show() else PartyFrame.ResurrectIndicator:Hide() end
                else
                    PartyFrame.ResurrectIndicator:Hide()
                end
            end

            if PartyFrame.PhaseIndicator then
                local PhaseDB = UUF.db.profile.Units.party.Indicators.Phase
                if PhaseDB.Enabled then
                    PartyFrame.PhaseIndicator:SetSize(PhaseDB.Size, PhaseDB.Size)
                    PartyFrame.PhaseIndicator:ClearAllPoints()
                    PartyFrame.PhaseIndicator:SetPoint(PhaseDB.Layout[1], PartyFrame.HighLevelContainer, PhaseDB.Layout[2], PhaseDB.Layout[3], PhaseDB.Layout[4])
                    if i == 4 then PartyFrame.PhaseIndicator:Show() else PartyFrame.PhaseIndicator:Hide() end
                else
                    PartyFrame.PhaseIndicator:Hide()
                end
            end

            if PartyFrame.Tags.TagOne then
                local TagOneDB = TagsDB.TagOne
                PartyFrame.Tags.TagOne:ClearAllPoints()
                PartyFrame.Tags.TagOne:SetPoint(TagOneDB.Layout[1], PartyFrame, TagOneDB.Layout[2], TagOneDB.Layout[3], TagOneDB.Layout[4])
                PartyFrame.Tags.TagOne:SetFont(UUF.Media.Font, TagOneDB.FontSize, General.Fonts.FontFlag)
                if General.Fonts.Shadow.Enabled then
                    PartyFrame.Tags.TagOne:SetShadowColor(unpack(General.Fonts.Shadow.Colour))
                    PartyFrame.Tags.TagOne:SetShadowOffset(General.Fonts.Shadow.XPos, General.Fonts.Shadow.YPos)
                else
                    PartyFrame.Tags.TagOne:SetShadowColor(0, 0, 0, 0)
                    PartyFrame.Tags.TagOne:SetShadowOffset(0, 0)
                end
                PartyFrame.Tags.TagOne:SetTextColor(unpack(TagOneDB.Colour))
                PartyFrame.Tags.TagOne:SetText(PartyTestData[i].name)
            end

            if PartyFrame.Tags.TagTwo then
                local TagTwoDB = TagsDB.TagTwo
                PartyFrame.Tags.TagTwo:ClearAllPoints()
                PartyFrame.Tags.TagTwo:SetPoint(TagTwoDB.Layout[1], PartyFrame, TagTwoDB.Layout[2], TagTwoDB.Layout[3], TagTwoDB.Layout[4])
                PartyFrame.Tags.TagTwo:SetFont(UUF.Media.Font, TagTwoDB.FontSize, General.Fonts.FontFlag)
                if General.Fonts.Shadow.Enabled then
                    PartyFrame.Tags.TagTwo:SetShadowColor(unpack(General.Fonts.Shadow.Colour))
                    PartyFrame.Tags.TagTwo:SetShadowOffset(General.Fonts.Shadow.XPos, General.Fonts.Shadow.YPos)
                else
                    PartyFrame.Tags.TagTwo:SetShadowColor(0, 0, 0, 0)
                    PartyFrame.Tags.TagTwo:SetShadowOffset(0, 0)
                end
                PartyFrame.Tags.TagTwo:SetTextColor(unpack(TagTwoDB.Colour))
                PartyFrame.Tags.TagTwo:SetText(string.format("%.1f%%", PartyTestData[i].percent))
            end

            if PartyFrame.Tags.TagThree then
                local TagThreeDB = TagsDB.TagThree
                PartyFrame.Tags.TagThree:ClearAllPoints()
                PartyFrame.Tags.TagThree:SetPoint(TagThreeDB.Layout[1], PartyFrame, TagThreeDB.Layout[2], TagThreeDB.Layout[3], TagThreeDB.Layout[4])
                PartyFrame.Tags.TagThree:SetFont(UUF.Media.Font, TagThreeDB.FontSize, General.Fonts.FontFlag)
                if General.Fonts.Shadow.Enabled then
                    PartyFrame.Tags.TagThree:SetShadowColor(unpack(General.Fonts.Shadow.Colour))
                    PartyFrame.Tags.TagThree:SetShadowOffset(General.Fonts.Shadow.XPos, General.Fonts.Shadow.YPos)
                else
                    PartyFrame.Tags.TagThree:SetShadowColor(0, 0, 0, 0)
                    PartyFrame.Tags.TagThree:SetShadowOffset(0, 0)
                end
                PartyFrame.Tags.TagThree:SetTextColor(unpack(TagThreeDB.Colour))
                PartyFrame.Tags.TagThree:SetText(PartyTestData[i].power)
            end
        end
    else
        for i, PartyFrame in ipairs(UUF.PARTY_FRAMES) do
            PartyFrame:SetAttribute("unit", "party" .. i)
            RegisterUnitWatch(PartyFrame)
            for j = 1, (PartyFrame.BuffContainer and PartyFrame.BuffContainer.maxFake or 0) do
                local button = PartyFrame.BuffContainer["fake" .. j]
                if button then button:Hide() end
            end
            for j = 1, (PartyFrame.DebuffContainer and PartyFrame.DebuffContainer.maxFake or 0) do
                local button = PartyFrame.DebuffContainer["fake" .. j]
                if button then button:Hide() end
            end
            if not PartyFrame:IsElementEnabled("Auras") then PartyFrame:EnableElement("Auras") end
            PartyFrame:Hide()
        end
    end
end

-----------------------------------------------------------------------
-- Raid Test Data
-- 40 entries cycling through the available class / power data so the
-- full grid is populated when test mode is active.
-----------------------------------------------------------------------

local RaidTestData = {}
for i = 1, 40 do
    local dataIndex = ((i - 1) % 10) + 1
    RaidTestData[i] = {
        name         = "Raid " .. i,
        class        = EnvironmenTestData[dataIndex].class,
        reaction     = 5,
        health       = 150000 - (((i - 1) % 10) * 12000),
        maxHealth    = 150000,
        missingHealth = ((i - 1) % 10) * 12000,
        absorb       = (((i - 1) % 10) + 1) * 5000,
        percent      = (150000 - (((i - 1) % 10) * 12000)) / 150000 * 100,
        maxPower     = 100,
        power        = 100 - (((i - 1) % 10) * 8),
        powerType    = EnvironmenTestData[dataIndex].powerType,
    }
end

function UUF:CreateTestRaidFrames()
    local General        = UUF.db.profile.General
    local AuraDurationDB = UUF.db.profile.Units.raid.Auras.AuraDuration
    local BuffsDB        = UUF.db.profile.Units.raid.Auras.Buffs
    local DebuffsDB      = UUF.db.profile.Units.raid.Auras.Debuffs
    local TagsDB         = UUF.db.profile.Units.raid.Tags
    local RaidDB         = UUF.db.profile.Units.raid
    UUF:ResolveLSM()

    if UUF.RAID_TEST_MODE then
        local groupsToShow   = tonumber(RaidDB.Frame.GroupsToShow) or 8
        local framesPerGroup = 5

        for i, RaidFrame in ipairs(UUF.RAID_FRAMES) do
            local groupIndex = math.ceil(i / framesPerGroup)
            if groupIndex > groupsToShow then
                RaidFrame:Hide()
            else
                RaidFrame:SetAttribute("unit", nil)
                UnregisterUnitWatch(RaidFrame)
                if RaidFrame:IsElementEnabled("Auras") then RaidFrame:DisableElement("Auras") end
                if RaidDB.Enabled then RaidFrame:Show() else RaidFrame:Hide() end

                RaidFrame:SetFrameStrata(RaidDB.Frame.FrameStrata)

                if RaidFrame.Health then
                    local HealthBarDB = UUF.db.profile.Units.raid.HealthBar
                    RaidFrame.Health:SetMinMaxValues(0, RaidTestData[i].maxHealth)
                    RaidFrame.Health:SetValue(RaidTestData[i].health)
                    RaidFrame.HealthBackground:SetMinMaxValues(0, RaidTestData[i].maxHealth)
                    RaidFrame.HealthBackground:SetValue(RaidTestData[i].missingHealth)
                    RaidFrame.HealthBackground:SetStatusBarColor(GetTestUnitColour(((i - 1) % 10) + 1, HealthBarDB.Background, HealthBarDB.ColourBackgroundByClass, HealthBarDB.BackgroundOpacity))
                    RaidFrame.Health:SetStatusBarColor(GetTestUnitColour(((i - 1) % 10) + 1, HealthBarDB.Foreground, HealthBarDB.ColourByClass, HealthBarDB.ForegroundOpacity))
                end

                if RaidFrame.Power then
                    RaidFrame.Power:SetMinMaxValues(0, RaidTestData[i].maxPower)
                    RaidFrame.Power:SetValue(RaidTestData[i].power)
                end

                local raidTargetMarkerCoords = {
                    {0,0.25,0,0.25},{0.25,0.5,0,0.25},{0.5,0.75,0,0.25},{0.75,1,0,0.25},
                    {0,0.25,0.25,0.5},{0.25,0.5,0.25,0.5},{0.5,0.75,0.25,0.5},{0.75,1,0.25,0.5},
                }
                local coordIndex = ((i - 1) % 8) + 1
                if RaidFrame.RaidTargetIndicator and raidTargetMarkerCoords[coordIndex] then
                    RaidFrame.RaidTargetIndicator:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
                    RaidFrame.RaidTargetIndicator:SetTexCoord(unpack(raidTargetMarkerCoords[coordIndex]))
                    if i % 5 == 1 then
                        RaidFrame.RaidTargetIndicator:Show()
                    else
                        RaidFrame.RaidTargetIndicator:Hide()
                    end
                end

                if RaidFrame.BuffContainer then
                    if BuffsDB.Enabled then
                        RaidFrame.BuffContainer:ClearAllPoints()
                        RaidFrame.BuffContainer:SetPoint(BuffsDB.Layout[1], RaidFrame, BuffsDB.Layout[2], BuffsDB.Layout[3], BuffsDB.Layout[4])
                        RaidFrame.BuffContainer:Show()

                        for j = 1, BuffsDB.Num do
                            local button = RaidFrame.BuffContainer["fake" .. j]
                            if not button then
                                button = CreateFrame("Button", nil, RaidFrame.BuffContainer, "BackdropTemplate")
                                button:SetBackdrop(UUF.BACKDROP)
                                button:SetBackdropColor(0, 0, 0, 0)
                                button:SetBackdropBorderColor(0, 0, 0, 1)
                                button:SetFrameStrata("MEDIUM")

                                button.Icon = button:CreateTexture(nil, "BORDER")
                                button.Icon:SetAllPoints()

                                button.Count = button:CreateFontString(nil, "OVERLAY")
                                RaidFrame.BuffContainer["fake" .. j] = button
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

                            local bRow = math.floor((j - 1) / BuffsDB.Wrap)
                            local bCol = (j - 1) % BuffsDB.Wrap
                            local bx   = bCol * (BuffsDB.Size + BuffsDB.Layout[5])
                            local by   = bRow * (BuffsDB.Size + BuffsDB.Layout[5])
                            if BuffsDB.GrowthDirection == "LEFT" then bx = -bx end
                            if BuffsDB.WrapDirection == "DOWN" then by = -by end

                            button:ClearAllPoints()
                            button:SetPoint(BuffsDB.Layout[1], RaidFrame.BuffContainer, BuffsDB.Layout[1], bx, by)

                            button.Icon:SetTexture(135769)
                            button.Icon:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
                            button.Icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
                            button.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
                            button.Count:SetText(j)
                            button.Duration = button.Duration or button:CreateFontString(nil, "OVERLAY")
                            button.Duration:ClearAllPoints()
                            button.Duration:SetPoint(AuraDurationDB.Layout[1], button, AuraDurationDB.Layout[2], AuraDurationDB.Layout[3], AuraDurationDB.Layout[4])
                            if AuraDurationDB.ScaleByIconSize then
                                local iconWidth  = button:GetWidth()
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
                        for j = maxFake + 1, (RaidFrame.BuffContainer.maxFake or maxFake) do
                            local button = RaidFrame.BuffContainer["fake" .. j]
                            if button then button:Hide() end
                        end
                        RaidFrame.BuffContainer.maxFake = BuffsDB.Num
                    else
                        RaidFrame.BuffContainer:Hide()
                    end
                end

                if RaidFrame.DebuffContainer then
                    if DebuffsDB.Enabled then
                        RaidFrame.DebuffContainer:ClearAllPoints()
                        RaidFrame.DebuffContainer:SetPoint(DebuffsDB.Layout[1], RaidFrame, DebuffsDB.Layout[2], DebuffsDB.Layout[3], DebuffsDB.Layout[4])
                        RaidFrame.DebuffContainer:Show()

                        for j = 1, DebuffsDB.Num do
                            local button = RaidFrame.DebuffContainer["fake" .. j]
                            if not button then
                                button = CreateFrame("Button", nil, RaidFrame.DebuffContainer, "BackdropTemplate")
                                button:SetBackdrop(UUF.BACKDROP)
                                button:SetBackdropColor(0, 0, 0, 0)
                                button:SetBackdropBorderColor(0, 0, 0, 1)
                                button:SetFrameStrata("MEDIUM")

                                button.Icon = button:CreateTexture(nil, "BORDER")
                                button.Icon:SetAllPoints()

                                button.Count = button:CreateFontString(nil, "OVERLAY")
                                RaidFrame.DebuffContainer["fake" .. j] = button
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

                            local bRow = math.floor((j - 1) / DebuffsDB.Wrap)
                            local bCol = (j - 1) % DebuffsDB.Wrap
                            local bx   = bCol * (DebuffsDB.Size + DebuffsDB.Layout[5])
                            local by   = bRow * (DebuffsDB.Size + DebuffsDB.Layout[5])
                            if DebuffsDB.GrowthDirection == "LEFT" then bx = -bx end
                            if DebuffsDB.WrapDirection == "DOWN" then by = -by end

                            button:ClearAllPoints()
                            button:SetPoint(DebuffsDB.Layout[1], RaidFrame.DebuffContainer, DebuffsDB.Layout[1], bx, by)
                            button.Icon:SetTexture(135768)
                            button.Icon:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
                            button.Icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
                            button.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
                            button.Count:SetText(j)
                            button.Duration = button.Duration or button:CreateFontString(nil, "OVERLAY")
                            button.Duration:ClearAllPoints()
                            button.Duration:SetPoint(AuraDurationDB.Layout[1], button, AuraDurationDB.Layout[2], AuraDurationDB.Layout[3], AuraDurationDB.Layout[4])
                            if AuraDurationDB.ScaleByIconSize then
                                local iconWidth   = button:GetWidth()
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
                        for j = maxFake + 1, (RaidFrame.DebuffContainer.maxFake or maxFake) do
                            local button = RaidFrame.DebuffContainer["fake" .. j]
                            if button then button:Hide() end
                        end
                        RaidFrame.DebuffContainer.maxFake = DebuffsDB.Num
                    else
                        RaidFrame.DebuffContainer:Hide()
                    end
                end

                if RaidFrame.TargetIndicator then
                    local TargetIndicatorDB = UUF.db.profile.Units.raid.Indicators.Target
                    if TargetIndicatorDB.Enabled and i % 5 == 1 then
                        RaidFrame.TargetIndicator:Show()
                    else
                        RaidFrame.TargetIndicator:Hide()
                    end
                end

                if RaidFrame.LeaderIndicator then
                    local LeaderAssistantDB = UUF.db.profile.Units.raid.Indicators.LeaderAssistantIndicator
                    if LeaderAssistantDB.Enabled then
                        RaidFrame.LeaderIndicator:SetSize(LeaderAssistantDB.Size, LeaderAssistantDB.Size)
                        RaidFrame.LeaderIndicator:ClearAllPoints()
                        RaidFrame.LeaderIndicator:SetPoint(LeaderAssistantDB.Layout[1], RaidFrame.HighLevelContainer, LeaderAssistantDB.Layout[2], LeaderAssistantDB.Layout[3], LeaderAssistantDB.Layout[4])
                        if i % 5 == 1 then RaidFrame.LeaderIndicator:Show() else RaidFrame.LeaderIndicator:Hide() end
                    else
                        RaidFrame.LeaderIndicator:Hide()
                    end
                end

                if RaidFrame.AssistantIndicator then
                    local LeaderAssistantDB = UUF.db.profile.Units.raid.Indicators.LeaderAssistantIndicator
                    if LeaderAssistantDB.Enabled then
                        RaidFrame.AssistantIndicator:SetSize(LeaderAssistantDB.Size, LeaderAssistantDB.Size)
                        RaidFrame.AssistantIndicator:ClearAllPoints()
                        RaidFrame.AssistantIndicator:SetPoint(LeaderAssistantDB.Layout[1], RaidFrame.HighLevelContainer, LeaderAssistantDB.Layout[2], LeaderAssistantDB.Layout[3], LeaderAssistantDB.Layout[4])
                        if i % 5 == 2 then RaidFrame.AssistantIndicator:Show() else RaidFrame.AssistantIndicator:Hide() end
                    else
                        RaidFrame.AssistantIndicator:Hide()
                    end
                end

                if RaidFrame.RoleIndicator then
                    local RoleDB = UUF.db.profile.Units.raid.Indicators.Role
                    if RoleDB.Enabled then
                        RaidFrame.RoleIndicator:SetSize(RoleDB.Size, RoleDB.Size)
                        RaidFrame.RoleIndicator:ClearAllPoints()
                        RaidFrame.RoleIndicator:SetPoint(RoleDB.Layout[1], RaidFrame.HighLevelContainer, RoleDB.Layout[2], RoleDB.Layout[3], RoleDB.Layout[4])
                        local roleSlot = (i - 1) % 5
                        local roles = { "roleIcon-tank", "roleIcon-healer", "roleIcon-dps", "roleIcon-dps", "roleIcon-dps" }
                        RaidFrame.RoleIndicator:SetAtlas(roles[roleSlot + 1] or "roleIcon-dps", true)
                        RaidFrame.RoleIndicator:Show()
                    else
                        RaidFrame.RoleIndicator:Hide()
                    end
                end

                if RaidFrame.SummonIndicator then
                    local SummonDB = UUF.db.profile.Units.raid.Indicators.Summon
                    if SummonDB.Enabled then
                        RaidFrame.SummonIndicator:SetSize(SummonDB.Size, SummonDB.Size)
                        RaidFrame.SummonIndicator:ClearAllPoints()
                        RaidFrame.SummonIndicator:SetPoint(SummonDB.Layout[1], RaidFrame.HighLevelContainer, SummonDB.Layout[2], SummonDB.Layout[3], SummonDB.Layout[4])
                        if i % 5 == 3 then RaidFrame.SummonIndicator:Show() else RaidFrame.SummonIndicator:Hide() end
                    else
                        RaidFrame.SummonIndicator:Hide()
                    end
                end

                if RaidFrame.ResurrectIndicator then
                    local ResurrectDB = UUF.db.profile.Units.raid.Indicators.Resurrection
                    if ResurrectDB.Enabled then
                        RaidFrame.ResurrectIndicator:SetSize(ResurrectDB.Size, ResurrectDB.Size)
                        RaidFrame.ResurrectIndicator:ClearAllPoints()
                        RaidFrame.ResurrectIndicator:SetPoint(ResurrectDB.Layout[1], RaidFrame.HighLevelContainer, ResurrectDB.Layout[2], ResurrectDB.Layout[3], ResurrectDB.Layout[4])
                        if i % 5 == 2 then RaidFrame.ResurrectIndicator:Show() else RaidFrame.ResurrectIndicator:Hide() end
                    else
                        RaidFrame.ResurrectIndicator:Hide()
                    end
                end

                if RaidFrame.PhaseIndicator then
                    local PhaseDB = UUF.db.profile.Units.raid.Indicators.Phase
                    if PhaseDB.Enabled then
                        RaidFrame.PhaseIndicator:SetSize(PhaseDB.Size, PhaseDB.Size)
                        RaidFrame.PhaseIndicator:ClearAllPoints()
                        RaidFrame.PhaseIndicator:SetPoint(PhaseDB.Layout[1], RaidFrame.HighLevelContainer, PhaseDB.Layout[2], PhaseDB.Layout[3], PhaseDB.Layout[4])
                        if i % 5 == 4 then RaidFrame.PhaseIndicator:Show() else RaidFrame.PhaseIndicator:Hide() end
                    else
                        RaidFrame.PhaseIndicator:Hide()
                    end
                end

                if RaidFrame.Tags.TagOne then
                    local TagOneDB = TagsDB.TagOne
                    RaidFrame.Tags.TagOne:ClearAllPoints()
                    RaidFrame.Tags.TagOne:SetPoint(TagOneDB.Layout[1], RaidFrame, TagOneDB.Layout[2], TagOneDB.Layout[3], TagOneDB.Layout[4])
                    RaidFrame.Tags.TagOne:SetFont(UUF.Media.Font, TagOneDB.FontSize, General.Fonts.FontFlag)
                    if General.Fonts.Shadow.Enabled then
                        RaidFrame.Tags.TagOne:SetShadowColor(unpack(General.Fonts.Shadow.Colour))
                        RaidFrame.Tags.TagOne:SetShadowOffset(General.Fonts.Shadow.XPos, General.Fonts.Shadow.YPos)
                    else
                        RaidFrame.Tags.TagOne:SetShadowColor(0, 0, 0, 0)
                        RaidFrame.Tags.TagOne:SetShadowOffset(0, 0)
                    end
                    RaidFrame.Tags.TagOne:SetTextColor(unpack(TagOneDB.Colour))
                    RaidFrame.Tags.TagOne:SetText(RaidTestData[i].name)
                end

                if RaidFrame.Tags.TagTwo then
                    local TagTwoDB = TagsDB.TagTwo
                    RaidFrame.Tags.TagTwo:ClearAllPoints()
                    RaidFrame.Tags.TagTwo:SetPoint(TagTwoDB.Layout[1], RaidFrame, TagTwoDB.Layout[2], TagTwoDB.Layout[3], TagTwoDB.Layout[4])
                    RaidFrame.Tags.TagTwo:SetFont(UUF.Media.Font, TagTwoDB.FontSize, General.Fonts.FontFlag)
                    if General.Fonts.Shadow.Enabled then
                        RaidFrame.Tags.TagTwo:SetShadowColor(unpack(General.Fonts.Shadow.Colour))
                        RaidFrame.Tags.TagTwo:SetShadowOffset(General.Fonts.Shadow.XPos, General.Fonts.Shadow.YPos)
                    else
                        RaidFrame.Tags.TagTwo:SetShadowColor(0, 0, 0, 0)
                        RaidFrame.Tags.TagTwo:SetShadowOffset(0, 0)
                    end
                    RaidFrame.Tags.TagTwo:SetTextColor(unpack(TagTwoDB.Colour))
                    RaidFrame.Tags.TagTwo:SetText(string.format("%.1f%%", RaidTestData[i].percent))
                end

                if RaidFrame.Tags.TagThree then
                    local TagThreeDB = TagsDB.TagThree
                    RaidFrame.Tags.TagThree:ClearAllPoints()
                    RaidFrame.Tags.TagThree:SetPoint(TagThreeDB.Layout[1], RaidFrame, TagThreeDB.Layout[2], TagThreeDB.Layout[3], TagThreeDB.Layout[4])
                    RaidFrame.Tags.TagThree:SetFont(UUF.Media.Font, TagThreeDB.FontSize, General.Fonts.FontFlag)
                    if General.Fonts.Shadow.Enabled then
                        RaidFrame.Tags.TagThree:SetShadowColor(unpack(General.Fonts.Shadow.Colour))
                        RaidFrame.Tags.TagThree:SetShadowOffset(General.Fonts.Shadow.XPos, General.Fonts.Shadow.YPos)
                    else
                        RaidFrame.Tags.TagThree:SetShadowColor(0, 0, 0, 0)
                        RaidFrame.Tags.TagThree:SetShadowOffset(0, 0)
                    end
                    RaidFrame.Tags.TagThree:SetTextColor(unpack(TagThreeDB.Colour))
                    RaidFrame.Tags.TagThree:SetText(RaidTestData[i].power)
                end
            end
        end
    else
        for i, RaidFrame in ipairs(UUF.RAID_FRAMES) do
            RaidFrame:SetAttribute("unit", "raid" .. i)
            local groupsToShow   = tonumber(UUF.db.profile.Units.raid.Frame.GroupsToShow) or 8
            local groupIndex     = math.ceil(i / 5)
            if groupIndex <= groupsToShow then
                RegisterUnitWatch(RaidFrame)
            end
            for j = 1, (RaidFrame.BuffContainer and RaidFrame.BuffContainer.maxFake or 0) do
                local button = RaidFrame.BuffContainer["fake" .. j]
                if button then button:Hide() end
            end
            for j = 1, (RaidFrame.DebuffContainer and RaidFrame.DebuffContainer.maxFake or 0) do
                local button = RaidFrame.DebuffContainer["fake" .. j]
                if button then button:Hide() end
            end
            if not RaidFrame:IsElementEnabled("Auras") then RaidFrame:EnableElement("Auras") end
            RaidFrame:Hide()
        end
    end
end