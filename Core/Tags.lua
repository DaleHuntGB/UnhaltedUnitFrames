local _, UUF = ...
local UUFTags = {}
function UUF:RegisterTag(name, func)
    UUFTags[name] = func
end

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
UUF:RegisterTag("curhpperhp", function(unit) if UnitIsDeadOrGhost(unit) then return "Dead" end return string.format("%s %s %.0f%%", UnitHealth(unit), UUF.HealthSeparator, UnitHealthPercent(unit, false, true)) end)
UUF:RegisterTag("curhpperhp:abbr", function(unit) if UnitIsDeadOrGhost(unit) then return "Dead" end return string.format("%s %s %.0f%%", AbbreviateLargeNumbers(UnitHealth(unit)), UUF.HealthSeparator, UnitHealthPercent(unit, false, true)) end)
UUF:RegisterTag("curpp", function(unit) return UnitPower(unit) end)
UUF:RegisterTag("curpp:abbr", function(unit) return AbbreviateLargeNumbers(UnitPower(unit)) end)
UUF:RegisterTag("maxpp", function(unit) return UnitPowerMax(unit) end)
UUF:RegisterTag("maxpp:abbr", function(unit) return AbbreviateLargeNumbers(UnitPowerMax(unit)) end)
UUF:RegisterTag("perpp", function(unit) return string.format("%.0f%%", UnitPowerPercent(unit, false, true)) end)
UUF:RegisterTag("name", function(unit) return UnitName(unit) end)
UUF:RegisterTag("name:colour", function(unit) local r, g, b = FetchUnitColour(unit) local unitName = UnitName(unit) or "" return string.format("|cff%02x%02x%02x%s|r", r*255, g*255, b*255, unitName) end)

local HealthTags = {
    ["curhp"] = "Current Health",
    ["curhp:abbr"] = "Current Health (Abbreviated)",
    ["curhpperhp"] = "Current Health and Percentage",
    ["curhpperhp:abbr"] = "Current Health and Percentage (Abbreviated)",
    ["maxhp"] = "Maximum Health",
    ["maxhp:abbr"] = "Maximum Health (Abbreviated)",
    ["perhp"] = "Health Percentage",
}

local function GetHealthTags()
    return HealthTags
end

local PowerTags = {
    ["curpp"] = "Current Power",
    ["curpp:abbr"] = "Current Power (Abbreviated)",
    ["maxpp"] = "Maximum Power",
    ["maxpp:abbr"] = "Maximum Power (Abbreviated)",
    ["perpp"] = "Power Percentage",
}

local function GetPowerTags()
    return PowerTags
end

local NameTags = {
    ["name"] = "Unit Name",
    ["name:colour"] = "Unit Name with Class/Reaction Colour",
}

local function GetNameTags()
    return NameTags
end

function UUF:GetTagsForGroup(tagGroup)
    if tagGroup == "Health" then
        return GetHealthTags()
    elseif tagGroup == "Power" then
        return GetPowerTags()
    elseif tagGroup == "Name" then
        return GetNameTags()
    end
end