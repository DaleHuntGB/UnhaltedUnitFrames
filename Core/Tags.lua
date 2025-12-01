local _, UUF = ...
local UUFTags = {}
function UUF:RegisterTag(name, func)
    UUFTags[name] = func
end
local hasBrackets = UUF.HealthTagLayout == "()"
local hasSquareBrackets = UUF.HealthTagLayout == "[]"

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

function UUF:EvaluateTagString(unit, text)
    if not unit or not text then return "" end
    local tag = text:match("^%[(.-)%]$")
    if not tag then return "" end
    local func = UUFTags[tag]
    if not func then return "" end
    return tostring(func(unit) or "")
end

UUF:RegisterTag("curhp", function(unit) if UnitIsDeadOrGhost(unit) then return "Dead" end return UnitHealth(unit) end)
UUF:RegisterTag("curhp:abbr", function(unit) if UnitIsDeadOrGhost(unit) then return "Dead" end return AbbreviateLargeNumbers(UnitHealth(unit)) end)
UUF:RegisterTag("maxhp", function(unit) return UnitHealthMax(unit) end)
UUF:RegisterTag("maxhp:abbr", function(unit) return AbbreviateLargeNumbers(UnitHealthMax(unit)) end)
UUF:RegisterTag("perhp", function(unit) return string.format("%.0f%%", UnitHealthPercent(unit, false, true)) end)
UUF:RegisterTag("curhpperhp", function(unit)
    if UnitIsDeadOrGhost(unit) then return "Dead" end
    if hasBrackets then
        return string.format("%s (%.0f%%)", UnitHealth(unit), UnitHealthPercent(unit, false, true))
    elseif hasSquareBrackets then
        return string.format("%s [%.0f%%]", UnitHealth(unit), UnitHealthPercent(unit, false, true))
    else
        return string.format("%s %s %.0f%%", UnitHealth(unit), UUF.HealthTagLayout, UnitHealthPercent(unit, false, true))
    end
end)
UUF:RegisterTag("curhpperhp:abbr", function(unit)
    if UnitIsDeadOrGhost(unit) then return "Dead" end
    if hasBrackets then
        return string.format("%s (%.0f%%)", AbbreviateLargeNumbers(UnitHealth(unit)), UnitHealthPercent(unit, false, true))
    elseif hasSquareBrackets then
        return string.format("%s [%.0f%%]", AbbreviateLargeNumbers(UnitHealth(unit)), UnitHealthPercent(unit, false, true))
    else
        return string.format("%s %s %.0f%%", AbbreviateLargeNumbers(UnitHealth(unit)), UUF.HealthTagLayout, UnitHealthPercent(unit, false, true))
    end
end)
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

UUF:RegisterTag("level", function(unit) return UnitLevel(unit) end)
UUF:RegisterTag("level:colour", function(unit) if UnitCanAttack("player", unit) then local unitLevel = UnitEffectiveLevel(unit) local difficultyColour = GetCreatureDifficultyColor((unitLevel > 0) and unitLevel or 999) return string.format("|cff%02x%02x%02x%d|r", difficultyColour.r*255, difficultyColour.g*255, difficultyColour.b*255, unitLevel) end end)
UUF:RegisterTag("classification", function(unit) local classif = UnitClassification(unit) if classif == "worldboss" then return "Boss" elseif classif == "rareelite" then return "Rare Elite" elseif classif == "elite" then return "Elite" elseif classif == "rare" then return "Rare" else return "" end end)
UUF:RegisterTag("classification:short", function(unit) local classif = UnitClassification(unit) if classif == "worldboss" then return "B" elseif classif == "rareelite" then return "R+" elseif classif == "elite" then return "+" elseif classif == "rare" then return "R" else return "" end end)
UUF:RegisterTag("group", function(unit) if not unit or not UnitExists(unit) then return "" end if not UnitInRaid(unit) then return "" end local name, server = UnitName(unit) if(server and server ~= '') then name = string.format('%s-%s', name, server) end for i=1, GetNumGroupMembers() do local raidName, _, group = GetRaidRosterInfo(i) if(raidName == name) then return "G" .. group end end end)
UUF:RegisterTag("creature", function(unit) if not unit or not UnitExists(unit) then return "" end return UnitCreatureFamily(unit) or UnitCreatureType(unit) end)
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
        ["classification:short"] = "Unit Classification (Short)",
        ["group"] = "Group Number",
    },
    {
        "level",
        "level:colour",
        "classification",
        "classification:short",
        "group",
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