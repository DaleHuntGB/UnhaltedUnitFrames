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

function UUF:CreateTestBossFrames()
    UUF:ResolveLSM()
    if UUF.BOSS_TEST_MODE then
        for i, BossFrame in ipairs(UUF.BOSS_FRAMES) do
            BossFrame:SetAttribute("unit", nil)
            UnregisterUnitWatch(BossFrame)
            BossFrame:Show()

            if BossFrame.Health then
                local HealthBarDB = UUF.db.profile.Units.boss.HealthBar
                BossFrame.Health:SetMinMaxValues(0, EnvironmenTestData[i].maxHealth)
                BossFrame.Health:SetValue(EnvironmenTestData[i].health)
                BossFrame.HealthBackground:SetMinMaxValues(0, EnvironmenTestData[i].maxHealth)
                BossFrame.HealthBackground:SetValue(EnvironmenTestData[i].missingHealth)
                BossFrame.HealthBackground:SetStatusBarColor(HealthBarDB.Background[1], HealthBarDB.Background[2], HealthBarDB.Background[3], HealthBarDB.BackgroundOpacity)
                if HealthBarDB.ColourByClass and HealthBarDB.ColourByReaction then
                    if i <= 5 then
                        local temporaryClass = EnvironmenTestData[i].class
                        local classColour = RAID_CLASS_COLORS[temporaryClass]
                        BossFrame.Health:SetStatusBarColor(classColour.r, classColour.g, classColour.b, HealthBarDB.ForegroundOpacity)
                    else
                        local temporaryReaction = EnvironmenTestData[i].reaction
                        local reactionColour = oUF.colors.reaction[temporaryReaction]
                        BossFrame.Health:SetStatusBarColor(reactionColour.r, reactionColour.g, reactionColour.b, HealthBarDB.ForegroundOpacity)
                    end
                elseif HealthBarDB.ColourByReaction then
                    local temporaryReaction = EnvironmenTestData[i].reaction
                    local reactionColour = oUF.colors.reaction[temporaryReaction]
                    BossFrame.Health:SetStatusBarColor(reactionColour.r, reactionColour.g, reactionColour.b, HealthBarDB.ForegroundOpacity)
                elseif HealthBarDB.ColourByClass then
                    local temporaryClass = EnvironmenTestData[i].class
                    local classColour = RAID_CLASS_COLORS[temporaryClass]
                    BossFrame.Health:SetStatusBarColor(classColour.r, classColour.g, classColour.b, HealthBarDB.ForegroundOpacity)
                else
                    local healthColour = HealthBarDB.Foreground
                    BossFrame.Health:SetStatusBarColor(healthColour[1], healthColour[2], healthColour[3], HealthBarDB.ForegroundOpacity)
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
        end
    end
end