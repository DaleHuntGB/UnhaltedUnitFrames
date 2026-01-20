local _, UUF = ...
local oUF = UUF.oUF
oUF.Tags = oUF.Tags or {}

function UUFG:AddTag(tagString, tagEvents, tagMethod, tagType, tagDescription)
    -- tagString: The string used to call the tag, e.g., "curhp:abbr"
    -- tagEvents: A space-separated string of events that will trigger an update of the tag
    -- tagMethod: A function that takes a unit as an argument and returns the tag's value
    -- tagType: "Health", "Power", "Name", "Misc"
    -- tagDescription: A short description of what the tag does.
    -- tagType, tagDescription are used for the configuration UI. Please provide them. Prefix of your AddOn Name is also advised.
    -- EG: UUFG:AddTag("BCDM: Health", "UNIT_HEALTH UNIT_MAXHEALTH", function(unit) return UnitHealth(unit) or 0 end, "Health", "Show Health")

    if not tagString or not tagEvents or not tagMethod or not tagType or not tagDescription then return end

    oUF.Tags.Methods[tagString] = tagMethod
    oUF.Tags.Events[tagString] = (oUF.Tags.Events[tagString] and (oUF.Tags.Events[tagString] .. " ") or "") .. tagEvents

    local tagDatabase = UUF:FetchTagData(tagType)
    if not tagDatabase then return end

    tagDatabase[1][tagString] = tagDescription

    for _, existing in ipairs(tagDatabase[2]) do
        if existing == tagString then return end
    end

    table.insert(tagDatabase[2], tagString)
end

local Tags = {
    ["curhp:abbr"] = "UNIT_HEALTH UNIT_MAXHEALTH",
    ["curhpperhp"] = "UNIT_HEALTH UNIT_MAXHEALTH",
    ["curhpperhp:abbr"] = "UNIT_HEALTH UNIT_MAXHEALTH",
    ["absorbs"] = "UNIT_ABSORB_AMOUNT_CHANGED",
    ["absorbs:abbr"] = "UNIT_ABSORB_AMOUNT_CHANGED",
    ["maxhp:abbr"] = "UNIT_HEALTH UNIT_MAXHEALTH",

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

-- Thank you to m33shoq for this abbreviation function and data!

local abbrevData = {
   breakpointData = {
      {
         breakpoint = 1e12,
         abbreviation = "B",
         significandDivisor = 1e10,
         fractionDivisor = 100,
         abbreviationIsGlobal = false,
      },
      {
         breakpoint = 1e11,
         abbreviation = "B",
         significandDivisor = 1e9,
         fractionDivisor = 1,
         abbreviationIsGlobal = false,
      },
      {
         breakpoint = 1e10,
         abbreviation = "B",
         significandDivisor = 1e8,
         fractionDivisor = 10,
         abbreviationIsGlobal = false,
      },
      {
         breakpoint = 1e9,
         abbreviation = "B",
         significandDivisor = 1e7,
         fractionDivisor = 100,
         abbreviationIsGlobal = false,
      },
      {
         breakpoint = 1e8,
         abbreviation = "M",
         significandDivisor = 1e6,
         fractionDivisor = 1,
         abbreviationIsGlobal = false,
      },
      {
         breakpoint = 1e7,
         abbreviation = "M",
         significandDivisor = 1e5,
         fractionDivisor = 10,
        abbreviationIsGlobal = false,
      },
      {
         breakpoint = 1e6,
         abbreviation = "M",
         significandDivisor = 1e4,
         fractionDivisor = 100,
         abbreviationIsGlobal = false,
      },
      {
         breakpoint = 1e5,
         abbreviation = "K",
         significandDivisor = 1000,
         fractionDivisor = 1,
         abbreviationIsGlobal = false,
      },
      {
         breakpoint = 1e4,
         abbreviation = "K",
         significandDivisor = 100,
         fractionDivisor = 10,
         abbreviationIsGlobal = false,
      },
   },
}

local function AbbreviateValue(value)
    local useCustomAbbreviations = UUF.db.profile.General.UseCustomAbbreviations
    if useCustomAbbreviations then
        return AbbreviateNumbers(value, abbrevData)
    else
        return AbbreviateLargeNumbers(value)
    end
end

for tagString, tagEvents in pairs(Tags) do
    oUF.Tags.Events[tagString] = (oUF.Tags.Events[tagString] and (oUF.Tags.Events[tagString] .. " ") or "") .. tagEvents
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
        return string.format("%s", AbbreviateValue(unitHealth))
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
            return string.format("%s [%.0f%%]", AbbreviateValue(unitHealth), unitHealthPercent)
        elseif UUF.SEPARATOR == "()" then
            return string.format("%s (%.0f%%)", AbbreviateValue(unitHealth), unitHealthPercent)
        elseif UUF.SEPARATOR == " " then
            return string.format("%s %.0f%%", AbbreviateValue(unitHealth), unitHealthPercent)
        else
            return string.format("%s %s %.0f%%", AbbreviateValue(unitHealth), UUF.SEPARATOR, unitHealthPercent)
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
        return string.format("%s", AbbreviateValue(absorbAmount))
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
        return string.format("%s", AbbreviateValue(unitPower))
    end
end

oUF.Tags.Methods["curpp:abbr:colour"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    local powerColourR, powerColourG, powerColourB = FetchUnitPowerColour(unit)
    local unitPower = UnitPower(unit)
    if unitPower then
        return string.format("|cff%02x%02x%02x%s|r", powerColourR * 255, powerColourG * 255, powerColourB * 255, AbbreviateValue(unitPower))
    end
end

oUF.Tags.Methods["maxhp:abbr"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    local unitMaxHealth = UnitHealthMax(unit)
    if unitMaxHealth then
        return string.format("%s", AbbreviateValue(unitMaxHealth))
    end
end

oUF.Tags.Methods["maxhp:abbr:colour"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    local classColourR, classColourG, classColourB = UUF:GetUnitColour(unit)
    local unitMaxHealth = UnitHealthMax(unit)
    if unitMaxHealth then
        return string.format("|cff%02x%02x%02x%s|r", classColourR * 255, classColourG * 255, classColourB * 255, AbbreviateValue(unitMaxHealth))
    end
end

oUF.Tags.Methods["name:colour"] = function(unit)
    local classColourR, classColourG, classColourB = UUF:GetUnitColour(unit)
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

local HealthTags = {
    {
        ["curhp"] = "Current Health",
        ["curhp:abbr"] = "Current Health with Abbreviation",
        ["perhp"] = "Percentage Health",
        ["curhpperhp"] = "Current Health and Percentage",
        ["curhpperhp:abbr"] = "Current Health and Percentage with Abbreviation",
        ["maxhp:abbr"] = "Maximum Health with Abbreviation",
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
        "maxhp:abbr",
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
    },
    {
        "name",
        "name:colour",
        -- "name:tot",
        -- "name:tot:colour",
        -- "name:tot:clean",
        -- "name:tot:colour:clean",
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