local _, UUF = ...
local oUF = UUF.oUF
oUF.Tags = oUF.Tags or {}
-- AddOn Developers: You can push into this table to add your own custom tags.
-- Example:
-- UUFG.Tags.Methods["mytag"] = function(unit) return "myvalue" end
-- UUFG.Tags.Events["mytag"] = "UNIT_HEALTH"
UUFG.Tags = oUF.Tags

local Tags = {
    ["curhp:abbr"] = "UNIT_HEALTH UNIT_MAXHEALTH",
    ["curhpperhp"] = "UNIT_HEALTH UNIT_MAXHEALTH",
    ["absorbs"] = "UNIT_ABSORB_AMOUNT_CHANGED",
    ["absorbs:abbr"] = "UNIT_ABSORB_AMOUNT_CHANGED",

    ["curpp:colour"] = "UNIT_POWER_UPDATE UNIT_MAXPOWER",
    ["curpp:abbr"] = "UNIT_POWER_UPDATE UNIT_MAXPOWER",
    ["curpp:abbr:colour"] = "UNIT_POWER_UPDATE UNIT_MAXPOWER",

    ["name:colour"] = "UNIT_CLASSIFICATION_CHANGED UNIT_FACTION UNIT_NAME_UPDATE",
    -- ["name:tot"] = "UNIT_NAME_UPDATE",
    -- ["name:tot:colour"] = "UNIT_NAME_UPDATE",
    -- ["name:tot:clean"] = "UNIT_NAME_UPDATE",
    -- ["name:tot:colour:clean"] = "UNIT_NAME_UPDATE",
    ["name:short:10"] = "UNIT_NAME_UPDATE",
    ["name:short:5"] = "UNIT_NAME_UPDATE",
    ["name:short:3"] = "UNIT_NAME_UPDATE",
}

UUF.SEPARATOR_TAGS = {
{
    ["||"] = "|",
    ["-"] = "-",
    ["/"] = "/",
    [" "] = "Space",
    ["[]"] = "[]",
    ["()"] = "()",
},
{
    "||",
    "-",
    "/",
    "[]",
    "()",
    " "
}
}

UUF.TOT_SEPARATOR_TAGS = {
{
    ["»"] = "»",
    ["-"] = "-",
    [">"] = ">",
},
{
    "»",
    "-",
    ">",
}
}

for tagString, tagEvents in pairs(Tags) do
    oUF.Tags.Events[tagString] = (oUF.Tags.Events[tagString] and (oUF.Tags.Events[tagString] .. " ") or "") .. tagEvents
end

local function FetchUnitColour(unit)
    if UnitIsPlayer(unit) then
        local _, class = UnitClass(unit)
        local classColour = class and RAID_CLASS_COLORS[class]
        if classColour then return classColour.r, classColour.g, classColour.b end
    end
    local reaction = UnitReaction(unit, "player")
    if reaction and UUF.db.profile.General.Colours.Reaction[reaction] then
        local r, g, b = unpack(UUF.db.profile.General.Colours.Reaction[reaction])
        return r, g, b
    end
    return 1, 1, 1
end

local function FetchUnitPowerColour(unit)
    local powerType = UnitPowerType(unit)
    local powerColour = powerType and UUF.db.profile.General.Colours.Power[powerType]
    if powerColour then
        local powerColourR, powerColourG, powerColourB = unpack(powerColour)
        return powerColourR, powerColourG, powerColourB
    end
    return 1, 1, 1
end

oUF.Tags.Methods["curhp:abbr"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    local unitHealth = UnitHealth(unit)
    local unitStatus = UnitIsDead(unit) and "Dead" or UnitIsGhost(unit) and "Ghost" or not UnitIsConnected(unit) and "Offline"
    if unitStatus then
        return unitStatus
    else
        return string.format("%s", AbbreviateLargeNumbers(unitHealth))
    end
end

oUF.Tags.Methods["curhpperhp"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    local unitHealth = UnitHealth(unit)
    local unitMaxHealth = UnitHealthMax(unit)
    local unitHealthPercent = UnitHealthPercent(unit, false, CurveConstants.ScaleTo100)
    local unitStatus = UnitIsDead(unit) and "Dead" or UnitIsGhost(unit) and "Ghost" or not UnitIsConnected(unit) and "Offline"
    if unitStatus then
        return unitStatus
    else
        if UUF.SEPARATOR == "[]" then
            return string.format("%s [%.0f%%]", unitHealth, unitHealthPercent)
        elseif UUF.SEPARATOR == "()" then
            return string.format("%s (%.0f%%)", unitHealth, unitHealthPercent)
        elseif UUF.SEPARATOR == " " then
            return string.format("%s %.0f%%", unitHealth, unitHealthPercent)
        else
            return string.format("%s %s %.0f%%", unitHealth, UUF.SEPARATOR, unitHealthPercent)
        end
    end
end

oUF.Tags.Methods["curhpperhp:abbr"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    local unitHealth = UnitHealth(unit)
    local unitMaxHealth = UnitHealthMax(unit)
    local unitHealthPercent = UnitHealthPercent(unit, false, CurveConstants.ScaleTo100)
    local unitStatus = UnitIsDead(unit) and "Dead" or UnitIsGhost(unit) and "Ghost" or not UnitIsConnected(unit) and "Offline"
    if unitStatus then
        return unitStatus
    else
        if UUF.SEPARATOR == "[]" then
            return string.format("%s [%.0f%%]", AbbreviateLargeNumbers(unitHealth), unitHealthPercent)
        elseif UUF.SEPARATOR == "()" then
            return string.format("%s (%.0f%%)", AbbreviateLargeNumbers(unitHealth), unitHealthPercent)
        elseif UUF.SEPARATOR == " " then
            return string.format("%s %.0f%%", AbbreviateLargeNumbers(unitHealth), unitHealthPercent)
        else
            return string.format("%s %s %.0f%%", AbbreviateLargeNumbers(unitHealth), UUF.SEPARATOR, unitHealthPercent)
        end
    end
end

oUF.Tags.Methods["absorbs"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    local absorbAmount = UnitGetTotalAbsorbs(unit) or 0
    if absorbAmount then
        return string.format("%s", absorbAmount)
    end
end

oUF.Tags.Methods["absorbs:abbr"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    local absorbAmount = UnitGetTotalAbsorbs(unit) or 0
    if absorbAmount then
        return string.format("%s", AbbreviateLargeNumbers(absorbAmount))
    end
end

oUF.Tags.Methods["curpp:colour"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    local powerColourR, powerColourG, powerColourB = FetchUnitPowerColour(unit)
    local unitPower = UnitPower(unit)
    if unitPower then
        return string.format("|cff%02x%02x%02x%s|r", powerColourR * 255, powerColourG * 255, powerColourB * 255, unitPower)
    end
end

oUF.Tags.Methods["curpp:abbr"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    local unitPower = UnitPower(unit)
    if unitPower then
        return string.format("%s", AbbreviateLargeNumbers(unitPower))
    end
end

oUF.Tags.Methods["curpp:abbr:colour"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    local powerColourR, powerColourG, powerColourB = FetchUnitPowerColour(unit)
    local unitPower = UnitPower(unit)
    if unitPower then
        return string.format("|cff%02x%02x%02x%s|r", powerColourR * 255, powerColourG * 255, powerColourB * 255, AbbreviateLargeNumbers(unitPower))
    end
end

oUF.Tags.Methods["name:colour"] = function(unit)
    local classColourR, classColourG, classColourB = FetchUnitColour(unit)
    local unitName = UnitName(unit) or ""
    return string.format("|cff%02x%02x%02x%s|r", classColourR * 255, classColourG * 255, classColourB * 255, unitName)
end

-- oUF.Tags.Methods["name:tot"] = function(unit)
--     if not unit or not UnitExists(unit) then return "" end
--     local targetOfTarget = unit .. "target"
--     local targetOfTargetName = UnitName(targetOfTarget) or ""
--     if not targetOfTargetName or targetOfTargetName == "" then return "" end
--     return string.format(" %s %s", UUF.TOT_SEPARATOR, targetOfTargetName)
-- end

-- oUF.Tags.Methods["name:tot:colour"] = function(unit)
--     if not unit or not UnitExists(unit) then return "" end
--     local targetOfTarget = unit .. "target"
--     local classColourR, classColourG, classColourB = FetchUnitColour(targetOfTarget)
--     local targetOfTargetName = UnitName(targetOfTarget) or ""
--     if not targetOfTargetName or targetOfTargetName == "" then return "" end
--     return string.format(" %s |cff%02x%02x%02x%s|r", UUF.TOT_SEPARATOR, classColourR * 255, classColourG * 255, classColourB * 255, targetOfTargetName)
-- end

-- oUF.Tags.Methods["name:tot:clean"] = function(unit)
--     if not unit or not UnitExists(unit) then return "" end
--     local targetOfTarget = unit .. "target"
--     local targetOfTargetName = UnitName(targetOfTarget) or ""
--     if not targetOfTargetName or targetOfTargetName == "" then return "" end
--     return string.format("%s", targetOfTargetName)
-- end

-- oUF.Tags.Methods["name:tot:colour:clean"] = function(unit)
--     if not unit or not UnitExists(unit) then return "" end
--     local targetOfTarget = unit .. "target"
--     local classColourR, classColourG, classColourB = FetchUnitColour(targetOfTarget)
--     local targetOfTargetName = UnitName(targetOfTarget) or ""
--     if not targetOfTargetName or targetOfTargetName == "" then return "" end
--     return string.format("|cff%02x%02x%02x%s|r", classColourR * 255, classColourG * 255, classColourB * 255, targetOfTargetName)
-- end

oUF.Tags.Methods["name:short:10"] = function(unit)
    local unitName = UnitName(unit) or ""
    return string.sub(unitName, 1, 10)
end

oUF.Tags.Methods["name:short:5"] = function(unit)
    local unitName = UnitName(unit) or ""
    return string.sub(unitName, 1, 5)
end

oUF.Tags.Methods["name:short:3"] = function(unit)
    local unitName = UnitName(unit) or ""
    return string.sub(unitName, 1, 3)
end

local HealthTags = {
    {
        ["curhp"] = "Current Health",
        ["curhp:abbr"] = "Current Health with Abbreviation",
        ["perhp"] = "Percentage Health",
        ["curhpperhp"] = "Current Health and Percentage",
        ["curhpperhp:abbr"] = "Current Health and Percentage with Abbreviation",
        ["absorbs"] = "Total Absorbs",
        ["absorbs:abbr"] = "Total Absorbs with Abbreviation",
        ["missinghp"] = "Missing Health",
    },
    {
        "curhp",
        "curhp:abbr",
        "perhp",
        "curhpperhp",
        "curhpperhp:abbr",
        "absorbs",
        "absorbs:abbr",
        "missinghp",
    }

}

local PowerTags = {
    {
        ["perpp"] = "Percentage Power",
        ["curpp"] = "Current Power",
        ["curpp:colour"] = "Current Power with Colour",
        ["curpp:abbr"] = "Current Power with Abbreviation",
        ["curpp:abbr:colour"] = "Current Power with Abbreviation and Colour",
        ["missingpp"] = "Missing Power",
    },
    {
        "perpp",
        "curpp",
        "curpp:colour",
        "curpp:abbr",
        "curpp:abbr:colour",
        "missingpp",
    }
}

local NameTags = {
    {
        ["name"] = "Unit Name",
        ["name:colour"] = "Unit Name with Colour",
        -- ["name:tot"] = "Target of Target Name",
        -- ["name:tot:colour"] = "Target of Target Name with Colour",
        -- ["name:tot:clean"] = "Target of Target Name without Arrow Separator",
        -- ["name:tot:colour:clean"] = "Target of Target Name with Colour without Arrow Separator",
        ["name:short:10"] = "Unit Name Shortened to 10 Characters",
        ["name:short:5"] = "Unit Name Shortened to 5 Characters",
        ["name:short:3"] = "Unit Name Shortened to 3 Characters",
    },
    {
        "name",
        "name:colour",
        -- "name:tot",
        -- "name:tot:colour",
        -- "name:tot:clean",
        -- "name:tot:colour:clean",
        "name:short:10",
        "name:short:5",
        "name:short:3",
    }
}

local MiscTags = {
    {
        ["classification"] = "Unit Classification",
        ["shortclassification"] = "Unit Classification with Abbreviation",
        ["creature"] = "Creature Type",
        ["group"] = "Group Number",
        ["level"] = "Unit Level",
        ["powercolor"] = "Unit Power Colour",
    },
    {
        "classification",
        "shortclassification",
        "creature",
        "group",
        "level",
        "powercolor",
    }
}

function UUF:FetchTagData(queriedDB)
    if queriedDB == "Health" then
        return HealthTags
    elseif queriedDB == "Power" then
        return PowerTags
    elseif queriedDB == "Name" then
        return NameTags
    elseif queriedDB == "Misc" then
        return MiscTags
    end
end