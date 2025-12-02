local _, UUF = ...
local UUFTags = {}
function UUF:RegisterTag(name, func)
    UUFTags[name] = func
end
local hasBrackets = UUF.HealthTagLayout == "()"
local hasSquareBrackets = UUF.HealthTagLayout == "[]"

local Classification = {
    worldboss  = "Boss",
    rareelite  = "Rare Elite",
    elite      = "Elite",
    rare       = "Rare",
}

local ClassificationShort = {
    worldboss  = "B",
    rareelite  = "R+",
    elite      = "+",
    rare       = "R",
}

local function FetchUnitColour(unit)
    if UnitIsPlayer(unit) then
        local _, class = UnitClass(unit)
        local classColour = class and RAID_CLASS_COLORS[class]
        if classColour then return classColour.r, classColour.g, classColour.b end
    end
    local reaction = UnitReaction(unit, "player")
    if reaction and UUF.db.profile.General.CustomColours.Reaction[reaction] then
        local r, g, b = unpack(UUF.db.profile.General.CustomColours.Reaction[reaction])
        return r, g, b
    end
    return 1, 1, 1
end

local function FetchUnitClassificationColour(classification)
    local CustomColoursDB = UUF.db.profile.General.CustomColours
    local classificationColour = CustomColoursDB.Classification[classification]
    if classificationColour then return classificationColour[1], classificationColour[2], classificationColour[3] end
    local normalColour = CustomColoursDB.Classification["normal"]
    if normalColour then return normalColour[1], normalColour[2], normalColour[3] end
    return 1, 1, 1
end

local function FetchUnitColouredLevel(unit)
    local unitLevel = UnitEffectiveLevel(unit)
    local unitDifficulty = GetCreatureDifficultyColor(unitLevel > 0 and unitLevel or 999)
    return unitLevel, unitDifficulty.r, unitDifficulty.g, unitDifficulty.b
end

function UUF:EvaluateTagString(unit, text)
    if not unit or not text then return "" end
    local tag = text:match("^%[(.-)%]$")
    if not tag or tag == "" then return "" end

    if UUF.TestMode and unit:match("^boss%d+$") then
        local fakeTag = UUF:FetchTestTag(tag)
        if fakeTag ~= nil then
            if type(fakeTag) ~= "string" then return tostring(fakeTag) end
            return fakeTag
        end
    end

    local func = UUFTags[tag]
    return tostring(func(unit) or "")
end

UUF:RegisterTag("curhp", function(unit) if UnitIsDeadOrGhost(unit) then return "Dead" end return UnitHealth(unit) end)
UUF:RegisterTag("curhp:abbr", function(unit) if UnitIsDeadOrGhost(unit) then return "Dead" end return AbbreviateLargeNumbers(UnitHealth(unit)) end)
UUF:RegisterTag("maxhp", function(unit) return UnitHealthMax(unit) end)
UUF:RegisterTag("maxhp:abbr", function(unit) return AbbreviateLargeNumbers(UnitHealthMax(unit)) end)
UUF:RegisterTag("perhp", function(unit) return string.format("%.0f%%", UnitHealthPercent(unit, false, true)) end)
UUF:RegisterTag("curhpperhp", function(unit) if UnitIsDeadOrGhost(unit) then return "Dead" end if hasBrackets then return string.format("%s (%.0f%%)", UnitHealth(unit), UnitHealthPercent(unit, false, true)) elseif hasSquareBrackets then return string.format("%s [%.0f%%]", UnitHealth(unit), UnitHealthPercent(unit, false, true)) else return string.format("%s %s %.0f%%", UnitHealth(unit), UUF.HealthTagLayout, UnitHealthPercent(unit, false, true)) end end)
UUF:RegisterTag("curhpperhp:abbr", function(unit) if UnitIsDeadOrGhost(unit) then return "Dead" end if hasBrackets then return string.format("%s (%.0f%%)", AbbreviateLargeNumbers(UnitHealth(unit)), UnitHealthPercent(unit, false, true)) elseif hasSquareBrackets then return string.format("%s [%.0f%%]", AbbreviateLargeNumbers(UnitHealth(unit)), UnitHealthPercent(unit, false, true)) else return string.format("%s %s %.0f%%", AbbreviateLargeNumbers(UnitHealth(unit)), UUF.HealthTagLayout, UnitHealthPercent(unit, false, true)) end end)
UUF:RegisterTag("absorbs", function(unit) local absorbs = AbbreviateLargeNumbers(UnitGetTotalAbsorbs(unit)) return absorbs end)

UUF:RegisterTag("curpp", function(unit) return UnitPower(unit) end)
UUF:RegisterTag("curpp:abbr", function(unit) return AbbreviateLargeNumbers(UnitPower(unit)) end)
UUF:RegisterTag("maxpp", function(unit) return UnitPowerMax(unit) end)
UUF:RegisterTag("maxpp:abbr", function(unit) return AbbreviateLargeNumbers(UnitPowerMax(unit)) end)
UUF:RegisterTag("perpp", function(unit) return string.format("%.0f%%", UnitPowerPercent(unit, UnitPowerType(unit), false, true)) end)

UUF:RegisterTag("name", function(unit) return UnitName(unit) end)
UUF:RegisterTag("name:colour", function(unit) local r, g, b = FetchUnitColour(unit) local unitName = UnitName(unit) or "" return string.format("|cff%02x%02x%02x%s|r", r*255, g*255, b*255, unitName) end)
UUF:RegisterTag("name:targettarget", function(unit) local targetOfTarget = unit.."target" return UnitName(targetOfTarget) or "" end)
UUF:RegisterTag("name:targettarget:colour", function(unit) local targetOfTarget = unit.."target" local r, g, b = FetchUnitColour(targetOfTarget) local unitName = UnitName(targetOfTarget) or "" return string.format("|cff%02x%02x%02x%s|r", r*255, g*255, b*255, unitName) end)
UUF:RegisterTag("name:namewithtargettarget", function(unit) local unitName = UnitName(unit) or "" local unitTarget = unit .. "target" if UnitExists(unitTarget) then return string.format("%s |cFFFFFFFF»|r %s", unitName, UnitName(unitTarget) or "") else return unitName end end)
UUF:RegisterTag("name:namewithtargettarget:colour", function(unit) local unitName = UnitName(unit) or "" local unitNameR, unitNameG, unitNameB = FetchUnitColour(unit) local unitColour = string.format("|cff%02x%02x%02x", unitNameR*255, unitNameG*255, unitNameB*255) local unitTarget = unit .. "target" if not UnitExists(unitTarget) then return unitColour .. unitName .. "|r" end local unitTargetName = UnitName(unitTarget) or "" local unitTargetR, unitTargetG, unitTargetB = FetchUnitColour(unitTarget) local unitTargetColour = string.format("|cff%02x%02x%02x", unitTargetR*255, unitTargetG*255, unitTargetB*255) return string.format("%s%s|r |cFFFFFFFF»|r %s%s|r", unitColour, unitName, unitTargetColour, unitTargetName ) end)
UUF:RegisterTag("name:short", function(unit) local name = UnitName(unit) if not name then return "" end if #name > 10 then return string.sub(name, 1, 7) .. "..." else return name end end)

UUF:RegisterTag("level", function(unit) return tostring(UnitLevel(unit)) end)
UUF:RegisterTag("level:colour", function(unit) local unitLevel = UnitEffectiveLevel(unit) local unitDifficulty = GetCreatureDifficultyColor(unitLevel > 0 and unitLevel or 999) return string.format("|cff%02x%02x%02x%s|r", unitDifficulty.r*255, unitDifficulty.g*255, unitDifficulty.b*255, unitLevel) end)
UUF:RegisterTag("classification", function(unit) return Classification[UnitClassification(unit)] or "" end)
UUF:RegisterTag("classification:colour", function(unit) local unitClassification = UnitClassification(unit) local unitClassificationText = Classification[unitClassification] if not unitClassificationText then return "" end local unitClassificationR, unitClassificationG, unitClassificationB = FetchUnitClassificationColour(unitClassification) return string.format("|cff%02x%02x%02x%s|r", unitClassificationR*255, unitClassificationG*255, unitClassificationB*255, unitClassificationText) end)
UUF:RegisterTag("classification:short", function(unit) return ClassificationShort[UnitClassification(unit)] or "" end)
UUF:RegisterTag("classification:short:colour", function(unit) local unitClassification = UnitClassification(unit) local unitClassificationText = ClassificationShort[unitClassification] if not unitClassificationText then return "" end local unitClassificationR, unitClassificationG, unitClassificationB = FetchUnitClassificationColour(unitClassification) return string.format("|cff%02x%02x%02x%s|r", unitClassificationR*255, unitClassificationG*255, unitClassificationB*255, unitClassificationText) end)
UUF:RegisterTag("levelclassification", function(unit) local unitLevel = UnitLevel(unit) local unitClassificationText = Classification[UnitClassification(unit)] return unitClassificationText and (unitLevel .. " " .. unitClassificationText) or tostring(unitLevel) end)
UUF:RegisterTag("levelclassification:short", function(unit) local unitLevel = UnitLevel(unit) local unitClassificationText = ClassificationShort[UnitClassification(unit)] return unitClassificationText and (unitLevel .. " " .. unitClassificationText) or tostring(unitLevel) end)
UUF:RegisterTag("levelclassification:colour", function(unit) local unitLevel, unitLevelR, unitLevelG, unitLevelB = FetchUnitColouredLevel(unit) local unitClassification = UnitClassification(unit) local unitClassificationText = Classification[unitClassification] if unitClassificationText then local unitClassificationTextR, unitClassificationTextG, unitClassificationTextB = FetchUnitClassificationColour(unitClassification) return string.format( "|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r", unitLevelR*255, unitLevelG*255, unitLevelB*255, unitLevel, unitClassificationTextR*255, unitClassificationTextG*255, unitClassificationTextB*255, unitClassificationText ) end return string.format("|cff%02x%02x%02x%d|r", unitLevelR*255, unitLevelG*255, unitLevelB*255, unitLevel) end)
UUF:RegisterTag("levelclassification:colour:short", function(unit) local unitLevel, unitLevelR, unitLevelG, unitLevelB = FetchUnitColouredLevel(unit) local unitClassification = UnitClassification(unit) local unitClassificationText = ClassificationShort[unitClassification] if unitClassificationText then local unitClassificationTextR, unitClassificationTextG, unitClassificationTextB = FetchUnitClassificationColour(unitClassification) return string.format( "|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r", unitLevelR*255, unitLevelG*255, unitLevelB*255, unitLevel, unitClassificationTextR*255, unitClassificationTextG*255, unitClassificationTextB*255, unitClassificationText ) end return string.format("|cff%02x%02x%02x%d|r", unitLevelR*255, unitLevelG*255, unitLevelB*255, unitLevel) end)
UUF:RegisterTag("group", function(unit) if not unit or not UnitExists(unit) then return "" end if not UnitInRaid(unit) then return "" end local name, server = UnitName(unit) if(server and server ~= '') then name = string.format('%s-%s', name, server) end for i=1, GetNumGroupMembers() do local raidName, _, group = GetRaidRosterInfo(i) if(raidName == name) then return "G" .. group end end end)
UUF:RegisterTag("creature", function(unit) if not unit or not UnitExists(unit) then return "" end return UnitCreatureFamily(unit) or UnitCreatureType(unit) end)

function UUF:FetchTestTag(tag)
    local testTags = {
        -- Health
        ["curhp"] = 7500,
        ["curhp:abbr"] = string.format("%s", AbbreviateLargeNumbers(7500)),
        ["curhpperhp"] = (function() if hasBrackets then return string.format("%s (%.0f%%)", 7500, 75) elseif hasSquareBrackets then return string.format("%s [%.0f%%]", 7500, 75) else return string.format("%s %s %.0f%%", 7500, UUF.HealthTagLayout, 75) end end)(),
        ["curhpperhp:abbr"] = (function() local cur = AbbreviateLargeNumbers(7500) if hasBrackets then return string.format("%s (%.0f%%)", cur, 75) elseif hasSquareBrackets then return string.format("%s [%.0f%%]", cur, 75) else return string.format("%s %s %.0f%%", cur, UUF.HealthTagLayout, 75) end end)(),
        ["maxhp"] = 10000,
        ["maxhp:abbr"] = string.format("%s", AbbreviateLargeNumbers(10000)),
        ["perhp"] = "75%",
        ["absorbs"] = string.format("%s", AbbreviateLargeNumbers(2000)),

        -- Name
        ["name"] = (function() return UnitName("player") end)(),
        ["name:colour"] = (function() local r, g, b = FetchUnitColour("player") local unitName = UnitName("player") or "" return string.format("|cff%02x%02x%02x%s|r", r*255, g*255, b*255, unitName) end)(),
        ["name:targettarget"] = (function() return UnitName("player") end)(),
        ["name:targettarget:colour"] = (function() local r, g, b = FetchUnitColour("player") local unitName = UnitName("player") or "" return string.format("|cff%02x%02x%02x%s|r", r*255, g*255, b*255, unitName) end)(),
        ["name:namewithtargettarget"] = (function() return string.format("%s |cFFFFFFFF»|r %s", UnitName("player"), UnitName("player")) end)(),
        ["name:namewithtargettarget:colour"] = (function() local r1, g1, b1 = FetchUnitColour("player") local r2, g2, b2 = FetchUnitColour("player") local unitName1 = UnitName("player") or "" local unitName2 = UnitName("player") or "" return string.format("|cff%02x%02x%02x%s|r |cFFFFFFFF»|r |cff%02x%02x%02x%s|r", r1*255, g1*255, b1*255, unitName1, r2*255, g2*255, b2*255, unitName2) end)(),

        -- Power
        ["curpp"] = 3000,
        ["curpp:abbr"] = string.format("%s", AbbreviateLargeNumbers(3000)),
        ["maxpp"] = 5000,
        ["maxpp:abbr"] = string.format("%s", AbbreviateLargeNumbers(5000)),
        ["perpp"] = "60%",
    }
    return testTags[tag]
end

local HealthTags = {
    {
        ["curhp"] = "Current Health",
        ["curhp:abbr"] = "Current Health (Abbreviated)",
        ["curhpperhp"] = "Current Health and Percentage",
        ["curhpperhp:abbr"] = "Current Health and Percentage (Abbreviated)",
        ["maxhp"] = "Maximum Health",
        ["maxhp:abbr"] = "Maximum Health (Abbreviated)",
        ["perhp"] = "Health Percentage",
        ["absorbs"] = "Total Absorbs",
    },
    {
        "curhp",
        "curhp:abbr",
        "curhpperhp",
        "curhpperhp:abbr",
        "maxhp",
        "maxhp:abbr",
        "perhp",
        "absorbs",
    }
}

local function GetHealthTags()
    return HealthTags
end

local PowerTags = {
    {
        ["curpp"] = "Current Power",
        ["curpp:abbr"] = "Current Power (Abbreviated)",
        ["maxpp"] = "Maximum Power",
        ["maxpp:abbr"] = "Maximum Power (Abbreviated)",
        ["perpp"] = "Power Percentage",
    },
    {
        "curpp",
        "curpp:abbr",
        "maxpp",
        "maxpp:abbr",
        "perpp",
    }
}

local function GetPowerTags()
    return PowerTags
end

local NameTags = {
    {
        ["name"] = "Unit Name",
        ["name:colour"] = "Unit Name (Coloured)",
        ["name:targettarget"] = "Target of Target Name",
        ["name:targettarget:colour"] = "Target of Target Name (Coloured)",
        ["name:namewithtargettarget"] = "Unit Name with Target of Target",
        ["name:namewithtargettarget:colour"] = "Unit Name with Target of Target (Coloured)",
    },
    {
        "name",
        "name:colour",
        "name:targettarget",
        "name:targettarget:colour",
        "name:namewithtargettarget",
        "name:namewithtargettarget:colour",
    }
}

local function GetNameTags()
    return NameTags
end

local MiscTags = {
    {
        ["level"] = "Unit Level",
        ["level:colour"] = "Unit Level (Coloured)",
        ["classification"] = "Unit Classification",
        ["classification:colour"] = "Unit Classification (Coloured)",
        ["classification:short"] = "Unit Classification (Short)",
        ["classification:short:colour"] = "Unit Classification (Coloured, Short)",
        ["levelclassification"] = "Unit Level with Classification",
        ["levelclassification:short"] = "Unit Level with Classification (Short)",
        ["levelclassification:colour"] = "Unit Level with Classification (Coloured)",
        ["levelclassification:colour:short"] = "Unit Level with Classification (Coloured, Short)",
        ["group"] = "Group Number",
        ["creature"] = "Creature Type/Family",
    },
    {
        "level",
        "level:colour",
        "classification",
        "classification:colour",
        "classification:short",
        "classification:short:colour",
        "levelclassification",
        "levelclassification:short",
        "levelclassification:colour",
        "levelclassification:colour:short",
        "group",
        "creature",
    }
}

local function GetMiscTags()
    return MiscTags
end

function UUF:GetTagsForGroup(tagGroup)
    if tagGroup == "Health" then
        return GetHealthTags()
    elseif tagGroup == "Power" then
        return GetPowerTags()
    elseif tagGroup == "Name" then
        return GetNameTags()
    elseif tagGroup == "Misc" then
        return GetMiscTags()
    end
end