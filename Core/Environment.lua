local _, UUF = ...
local FakeBossData = {}

local function GetNormalizedUnit(unit)
    local normalizedUnit = unit:match("^boss%d+$") and "boss" or unit
    return normalizedUnit
end

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
    FakeBossData[i] = {
        name      = "Boss " .. i,
        class     = Classes[i],
        reaction  = i % 2 == 0 and 2 or 5,
        health    = 8000000 - (i * 600000),
        maxHealth = 8000000,
        missingHealth = i * 600000,
        absorb    = (i * 300000),
        percent  = (8000000 - (i * 600000)) / 8000000 * 100,
        power     = 100 - (i * 2),
        maxPower  = 100,
        powerType = PowerTypes[i],
    }
end

function UUF:ShowBossFrames()
    UUF.TestMode = true
    local BossDB = UUF.db.profile.boss
    for i = 1, UUF.MaxBossFrames do
        local unitFrame = _G["UUF_Boss"..i]
        if unitFrame then
            UnregisterUnitWatch(unitFrame)

            unitFrame.unit   = "boss"..i
            unitFrame.dbUnit = "boss"

            unitFrame:Show()
            UUF:UpdateUnitFrame("boss"..i)

            -- Handle Fake Health
            if unitFrame.HealthBar then
                local useClassColour    = BossDB.Frame.ClassColour
                local useReactionColour = BossDB.Frame.ReactionColour
                local healthColourR, healthColourG, healthColourB
                local healthColourA = BossDB.Frame.FGColour[4]

                if useClassColour and useReactionColour then
                    if i <= 5 then
                        local fakeClass = FakeBossData[i].class
                        local classColour = RAID_CLASS_COLORS[fakeClass]
                        if classColour then healthColourR, healthColourG, healthColourB, healthColourA = classColour.r, classColour.g, classColour.b else healthColourR, healthColourG, healthColourB, healthColourA = 0.5, 0.5, 0.5, 1 end
                    else
                        local fakeReaction = FakeBossData[i].reaction
                        local reactionColour = FACTION_BAR_COLORS[fakeReaction]
                        if reactionColour then healthColourR, healthColourG, healthColourB, healthColourA = reactionColour.r, reactionColour.g, reactionColour.b else healthColourR, healthColourG, healthColourB, healthColourA = 0.5, 0.5, 0.5, 1 end
                    end

                elseif useClassColour and not useReactionColour then
                    local fakeClass = FakeBossData[i].class
                    local classColour = RAID_CLASS_COLORS[fakeClass]
                    if classColour then healthColourR, healthColourG, healthColourB, healthColourA = classColour.r, classColour.g, classColour.b else healthColourR, healthColourG, healthColourB, healthColourA = 0.5, 0.5, 0.5, 1 end

                elseif useReactionColour and not useClassColour then
                    local fakeReaction = FakeBossData[i].reaction
                    local reactionColour = FACTION_BAR_COLORS[fakeReaction]
                    if reactionColour then healthColourR, healthColourG, healthColourB, healthColourA = reactionColour.r, reactionColour.g, reactionColour.b else healthColourR, healthColourG, healthColourB, healthColourA = 0.5, 0.5, 0.5, 1 end
                else
                    healthColourR, healthColourG, healthColourB, healthColourA = BossDB.Frame.FGColour[1], BossDB.Frame.FGColour[2], BossDB.Frame.FGColour[3]
                end

                unitFrame.HealthBar:SetStatusBarColor(healthColourR, healthColourG, healthColourB, healthColourA)
                unitFrame.HealthBar:SetMinMaxValues(0, FakeBossData[i].maxHealth)
                unitFrame.HealthBar:SetValue(FakeBossData[i].health)
                unitFrame.HealthBG:SetMinMaxValues(0, FakeBossData[i].maxHealth)
                unitFrame.HealthBG:SetValue(FakeBossData[i].missingHealth)
            end

            -- Handle Fake Absorbs
            if unitFrame.AbsorbBar then
                unitFrame.AbsorbBar:SetMinMaxValues(0, FakeBossData[i].maxHealth)
                unitFrame.AbsorbBar:SetValue(FakeBossData[i].absorb)
            end

            -- Handle Target Indicator
            if unitFrame.TargetIndicator then
                if BossDB.Indicators.TargetIndicator.Enabled then
                    unitFrame.TargetIndicator:Show()
                else
                    unitFrame.TargetIndicator:Hide()
                end
            end

            -- Handle Fake Portraits
            if unitFrame.Portrait then
                if unitFrame.Portrait.Texture then
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
                    unitFrame.Portrait.Texture:SetTexture("Interface\\ICONS\\" .. PortraitOptions[i])
                end
            end
        end
    end

    UUF:LayoutBossFrames()
end

function UUF:HideBossFrames()
    if UUF.TestMode == false then return end
    UUF.TestMode = false
    for i = 1, UUF.MaxBossFrames do
        local unitFrame = _G["UUF_Boss"..i]
        if unitFrame then
            unitFrame.unit   = "boss"..i
            unitFrame.dbUnit = "boss"

            unitFrame:Hide()
            RegisterUnitWatch(unitFrame)
            UUF:UpdateUnitFrame("boss"..i)
        end
    end

    UUF:LayoutBossFrames()
end

