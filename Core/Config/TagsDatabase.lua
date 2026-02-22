local _, UUF = ...
local oUF = UUF.oUF
oUF.Tags = oUF.Tags or {}
local Utilities = UUF.Utilities or {}

local function FallbackIsSecret(value)
    local fn = _G.IsSecretValue or _G.issecretvalue
    return type(fn) == "function" and fn(value) or false
end

local IsSecret = Utilities.IsSecret or FallbackIsSecret
local SafeValue = Utilities.SafeValue or function(value, default)
    if value == nil or IsSecret(value) then
        return default
    end
    return value
end
local SafeNumber = Utilities.SafeNumber or function(value, default)
    local safe = SafeValue(value, nil)
    if safe == nil then return default end
    local n = tonumber(safe)
    if n == nil or IsSecret(n) then
        return default
    end
    return n
end
local SafeString = Utilities.SafeString or function(value, default)
    local safe = SafeValue(value, nil)
    if safe == nil then return default end
    local ok, text = pcall(tostring, safe)
    if not ok or not text or IsSecret(text) then
        return default
    end
    return text
end

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
    ["curhp:abbr"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_ABSORB_AMOUNT_CHANGED",
    ["curhpperhp"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_ABSORB_AMOUNT_CHANGED",
    ["curhpperhp:abbr"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_ABSORB_AMOUNT_CHANGED",
    ["absorbs"] = "UNIT_ABSORB_AMOUNT_CHANGED",
    ["absorbs:abbr"] = "UNIT_ABSORB_AMOUNT_CHANGED",
    ["absorbs:truncate"] = "UNIT_ABSORB_AMOUNT_CHANGED",
    ["maxhp:abbr"] = "UNIT_HEALTH UNIT_MAXHEALTH",

    ["curpp:colour"] = "UNIT_POWER_UPDATE UNIT_MAXPOWER",
    ["curpp:abbr"] = "UNIT_POWER_UPDATE UNIT_MAXPOWER",
    ["curpp:abbr:colour"] = "UNIT_POWER_UPDATE UNIT_MAXPOWER",
    ["curpp:manapercent"] = "UNIT_POWER_UPDATE UNIT_MAXPOWER",
    ["curpp:manapercent:abbr"] = "UNIT_POWER_UPDATE UNIT_MAXPOWER",
    ["curpp:manapercent-with-sign"] = "UNIT_POWER_UPDATE UNIT_MAXPOWER",
    ["curpp:manapercent-with-sign:abbr"] = "UNIT_POWER_UPDATE UNIT_MAXPOWER",

    ["maxpp:abbr"] = "UNIT_POWER_UPDATE UNIT_MAXPOWER",
    ["maxpp:colour"] = "UNIT_POWER_UPDATE UNIT_MAXPOWER",
    ["maxpp:abbr:colour"] = "UNIT_POWER_UPDATE UNIT_MAXPOWER",

    ["name:colour"] = "UNIT_CLASSIFICATION_CHANGED UNIT_FACTION UNIT_NAME_UPDATE",

    -- Status and Threat tags (Patch 12.0.0+ compatible)
    ["status"] = "UNIT_HEALTH UNIT_CONNECTION",
    ["threat"] = "UNIT_THREAT_SITUATION_UPDATE",
    ["threatcolor"] = "UNIT_THREAT_SITUATION_UPDATE",
    ["smartlevel"] = "UNIT_LEVEL UNIT_CLASSIFICATION_CHANGED",
}

for i = 1, 25 do
    Tags["name:short:" .. i] = "UNIT_NAME_UPDATE"
end

for i = 1, 25 do
    Tags["name:short:" .. i .. ":colour"] = "UNIT_NAME_UPDATE"
end

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
    local numericValue = SafeNumber(value, nil)
    if numericValue == nil then return nil end

    local useCustomAbbreviations = UUF.db.profile.General.UseCustomAbbreviations
    local ok, text
    if useCustomAbbreviations then
        ok, text = pcall(AbbreviateNumbers, numericValue, abbrevData)
    else
        ok, text = pcall(AbbreviateLargeNumbers, numericValue)
    end

    if ok and text and not IsSecret(text) then
        return SafeString(text, nil)
    end

    return SafeString(numericValue, nil)
end

local function ResolveUnitStatus(unit)
    if UnitIsDead(unit) then return "Dead" end
    if UnitIsGhost(unit) then return "Ghost" end
    if not UnitIsConnected(unit) then return "Offline" end
    return nil
end

local function FormatHealthPair(healthText, healthPercent)
    if UUF.SEPARATOR == "[]" then
        return string.format("%s [%.0f%%]", healthText, healthPercent)
    elseif UUF.SEPARATOR == "()" then
        return string.format("%s (%.0f%%)", healthText, healthPercent)
    elseif UUF.SEPARATOR == " " then
        return string.format("%s %.0f%%", healthText, healthPercent)
    end

    return string.format("%s %s %.0f%%", healthText, UUF.SEPARATOR, healthPercent)
end

local function FetchAbsorbText(unit, useAbbrev)
    if not unit or not UnitExists(unit) then return nil end
    if type(UnitGetTotalAbsorbs) ~= "function" then return nil end

    local absorbValue = SafeNumber(UnitGetTotalAbsorbs(unit), nil)
    if absorbValue == nil then return nil end

    if C_StringUtil and C_StringUtil.TruncateWhenZero then
        local ok, txt = pcall(C_StringUtil.TruncateWhenZero, absorbValue)
        txt = ok and SafeString(txt, nil) or nil
        if txt and txt ~= "" then
            return txt
        end
    end

    if useAbbrev then
        local ok, txt = pcall(AbbreviateValue, absorbValue)
        txt = ok and SafeString(txt, nil) or nil
        if txt then
            return txt
        end
    end

    local txt = SafeString(absorbValue, nil)
    if txt then
        return txt
    end

    return nil
end

for tagString, tagEvents in pairs(Tags) do
    oUF.Tags.Events[tagString] = (oUF.Tags.Events[tagString] and (oUF.Tags.Events[tagString] .. " ") or "") .. tagEvents
end

local function FetchUnitPowerColour(unit)
    local powerType = SafeNumber(UnitPowerType(unit), nil)
    local powerColour = powerType and UUF.db.profile.General.Colours.Power[powerType]
    if powerColour then
        local powerColourR, powerColourG, powerColourB = unpack(powerColour)
        return powerColourR, powerColourG, powerColourB
    end
    return 1, 1, 1
end

oUF.Tags.Methods["curhp:abbr"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    local unitStatus = ResolveUnitStatus(unit)
    if unitStatus then
        return unitStatus
    end

    local unitHealthText = AbbreviateValue(UnitHealth(unit))
    if not unitHealthText then return "" end

    local absorbText = FetchAbsorbText(unit, true)
    if absorbText then
        return string.format("%s (%s)", unitHealthText, absorbText)
    end

    return unitHealthText
end

oUF.Tags.Methods["curhpperhp"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    local unitStatus = ResolveUnitStatus(unit)
    if unitStatus then
        return unitStatus
    end

    local unitHealth = SafeNumber(UnitHealth(unit), nil)
    local unitHealthPercent = SafeNumber(UnitHealthPercent(unit, false, CurveConstants.ScaleTo100), nil)
    if unitHealth == nil or unitHealthPercent == nil then return "" end

    local baseText = FormatHealthPair(SafeString(unitHealth, "0"), unitHealthPercent)
    local absorbText = FetchAbsorbText(unit, false)
    return absorbText and string.format("%s (%s)", baseText, absorbText) or baseText
end

oUF.Tags.Methods["curhpperhp:abbr"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    local unitStatus = ResolveUnitStatus(unit)
    if unitStatus then
        return unitStatus
    end

    local unitHealthText = AbbreviateValue(UnitHealth(unit))
    local unitHealthPercent = SafeNumber(UnitHealthPercent(unit, false, CurveConstants.ScaleTo100), nil)
    if not unitHealthText or unitHealthPercent == nil then return "" end

    local baseText = FormatHealthPair(unitHealthText, unitHealthPercent)
    local absorbText = FetchAbsorbText(unit, true)
    return absorbText and string.format("%s (%s)", baseText, absorbText) or baseText
end

oUF.Tags.Methods["absorbs"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    return FetchAbsorbText(unit, false) or ""
end

oUF.Tags.Methods["absorbs:abbr"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    return FetchAbsorbText(unit, true) or ""
end

oUF.Tags.Methods["absorbs:truncate"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    local absorbAmount = SafeNumber(UnitGetTotalAbsorbs(unit), nil)
    if absorbAmount == nil then return "" end
    if C_StringUtil and C_StringUtil.TruncateWhenZero then
        local ok, text = pcall(C_StringUtil.TruncateWhenZero, absorbAmount)
        text = ok and SafeString(text, nil) or nil
        return text or ""
    end
    return SafeString(absorbAmount, "")
end

oUF.Tags.Methods["curpp:colour"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    local powerColourR, powerColourG, powerColourB = FetchUnitPowerColour(unit)
    local unitPower = SafeNumber(UnitPower(unit), nil)
    if unitPower == nil then return "" end
    return string.format("|cff%02x%02x%02x%s|r", powerColourR * 255, powerColourG * 255, powerColourB * 255, SafeString(unitPower, "0"))
end

oUF.Tags.Methods["maxpp:colour"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    local powerColourR, powerColourG, powerColourB = FetchUnitPowerColour(unit)
    local unitPowerMax = SafeNumber(UnitPowerMax(unit), nil)
    if unitPowerMax == nil then return "" end
    return string.format("|cff%02x%02x%02x%s|r", powerColourR * 255, powerColourG * 255, powerColourB * 255, SafeString(unitPowerMax, "0"))
end

oUF.Tags.Methods["curpp:abbr"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    return AbbreviateValue(UnitPower(unit)) or ""
end

oUF.Tags.Methods["curpp:manapercent"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    local unitPower = SafeNumber(UnitPower(unit), nil)
    local unitPowerType = SafeNumber(UnitPowerType(unit), nil)
    if unitPowerType == Enum.PowerType.Mana and unitPower ~= nil then
        local powerPercent = SafeNumber(UnitPowerPercent(unit, Enum.PowerType.Mana, true, CurveConstants.ScaleTo100), nil)
        return powerPercent and string.format("%.f", powerPercent) or ""
    end
    return SafeString(unitPower, "")
end

oUF.Tags.Methods["curpp:manapercent-with-sign"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    local unitPower = SafeNumber(UnitPower(unit), nil)
    local unitPowerType = SafeNumber(UnitPowerType(unit), nil)
    if unitPowerType == Enum.PowerType.Mana and unitPower ~= nil then
        local powerPercent = SafeNumber(UnitPowerPercent(unit, Enum.PowerType.Mana, true, CurveConstants.ScaleTo100), nil)
        return powerPercent and string.format("%.f%%", powerPercent) or ""
    end
    return SafeString(unitPower, "")
end

oUF.Tags.Methods["curpp:manapercent:abbr"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    local unitPower = SafeNumber(UnitPower(unit), nil)
    local unitPowerType = SafeNumber(UnitPowerType(unit), nil)
    if unitPowerType == Enum.PowerType.Mana and unitPower ~= nil then
        local powerPercent = SafeNumber(UnitPowerPercent(unit, Enum.PowerType.Mana, true, CurveConstants.ScaleTo100), nil)
        return powerPercent and string.format("%.f", powerPercent) or ""
    end
    return AbbreviateValue(unitPower) or ""
end

oUF.Tags.Methods["curpp:manapercent-with-sign:abbr"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    local unitPower = SafeNumber(UnitPower(unit), nil)
    local unitPowerType = SafeNumber(UnitPowerType(unit), nil)
    if unitPowerType == Enum.PowerType.Mana and unitPower ~= nil then
        local powerPercent = SafeNumber(UnitPowerPercent(unit, Enum.PowerType.Mana, true, CurveConstants.ScaleTo100), nil)
        return powerPercent and string.format("%.f%%", powerPercent) or ""
    end
    return AbbreviateValue(unitPower) or ""
end

oUF.Tags.Methods["maxpp:abbr"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    return AbbreviateValue(UnitPowerMax(unit)) or ""
end

oUF.Tags.Methods["curpp:abbr:colour"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    local powerColourR, powerColourG, powerColourB = FetchUnitPowerColour(unit)
    local unitPowerText = AbbreviateValue(UnitPower(unit))
    if not unitPowerText then return "" end
    return string.format("|cff%02x%02x%02x%s|r", powerColourR * 255, powerColourG * 255, powerColourB * 255, unitPowerText)
end

oUF.Tags.Methods["maxpp:abbr:colour"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    local powerColourR, powerColourG, powerColourB = FetchUnitPowerColour(unit)
    local unitPowerText = AbbreviateValue(UnitPowerMax(unit))
    if not unitPowerText then return "" end
    return string.format("|cff%02x%02x%02x%s|r", powerColourR * 255, powerColourG * 255, powerColourB * 255, unitPowerText)
end

oUF.Tags.Methods["maxhp:abbr"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    return AbbreviateValue(UnitHealthMax(unit)) or ""
end

oUF.Tags.Methods["maxhp:abbr:colour"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    local classColourR, classColourG, classColourB = UUF:GetUnitColour(unit)
    local unitHealthText = AbbreviateValue(UnitHealthMax(unit))
    if not unitHealthText then return "" end
    return string.format("|cff%02x%02x%02x%s|r", classColourR * 255, classColourG * 255, classColourB * 255, unitHealthText)
end

oUF.Tags.Methods["name:colour"] = function(unit)
    local classColourR, classColourG, classColourB = UUF:GetUnitColour(unit)
    local unitName = SafeString(UnitName(unit), "")
    return string.format("|cff%02x%02x%02x%s|r", classColourR * 255, classColourG * 255, classColourB * 255, unitName)
end

oUF.Tags.Methods["resetcolor"] = function(unit)
    return "|r"
end

-- Status and Threat Tags
oUF.Tags.Methods["status"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    if UnitIsDead(unit) then
        return "Dead"
    elseif UnitIsGhost(unit) then
        return "Ghost"
    elseif not UnitIsConnected(unit) then
        return "Offline"
    end
    return ""
end

oUF.Tags.Methods["threat"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    local threatSituation = UnitThreatSituation(unit)
    if threatSituation == 1 then
        return "++"
    elseif threatSituation == 2 then
        return "--"
    elseif threatSituation == 3 then
        return "Aggro"
    end
    return ""
end

oUF.Tags.Methods["threatcolor"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    local threatSituation = UnitThreatSituation(unit)
    if threatSituation == 1 then
        return "|cffff0000"  -- Red for aggro
    elseif threatSituation == 2 then
        return "|cffffff00"  -- Yellow for near aggro
    elseif threatSituation == 3 then
        return "|cff00ff00"  -- Green for losing threat
    end
    return "|r"
end

oUF.Tags.Methods["smartlevel"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    local unitLevel = UnitLevel(unit) or "??"
    local classification = UUF:GetSafeUnitClassification(unit)
    if classification == "elite" then
        return unitLevel .. "*"
    elseif classification == "rareelite" then
        return unitLevel .. "R*"
    elseif classification == "rare" then
        return unitLevel .. "R"
    elseif classification == "worldboss" then
        return "BOSS"
    elseif classification == "minus" then
        return unitLevel .. "-"
    else
        return tostring(unitLevel)
    end
end

local function ShortenUnitName(unit, maxChars)
    if not unit or not UnitExists(unit) then return "" end
    local unitName = SafeString(UnitName(unit), "")
    if maxChars and maxChars > 0 then
        unitName = string.format("%." .. maxChars .. "s", unitName)
    end
    return UUF:CleanTruncateUTF8String(unitName)
end

for i = 1, 25 do
    oUF.Tags.Methods["name:short:" .. i] = function(unit) return ShortenUnitName(unit, i) end
end
for i = 1, 25 do
    oUF.Tags.Methods["name:short:" .. i .. ":colour"] = function(unit)
        local classColourR, classColourG, classColourB = UUF:GetUnitColour(unit)
        local shortenedName = ShortenUnitName(unit, i)
        return string.format("|cff%02x%02x%02x%s|r", classColourR * 255, classColourG * 255, classColourB * 255, shortenedName)
    end
end

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
        ["absorbs:truncate"] = "Total Absorbs but will hide when at zero.",
        ["missinghp"] = "Missing Health",
        ["status"] = "Combined Status (Dead/Ghost/Offline)",
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
        "absorbs:truncate",
        "missinghp",
        "status",
    }

}

local PowerTags = {
    {
        ["perpp"] = "Percentage Power",
        ["curpp"] = "Current Power",
        ["curpp:colour"] = "Current Power with Colour",
        ["curpp:abbr"] = "Current Power with Abbreviation",
        ["curpp:abbr:colour"] = "Current Power with Abbreviation and Colour",
        ["maxpp"] = "Maximum Power",
        ["maxpp:abbr"] = "Maximum Power with Abbreviation",
        ["maxpp:colour"] = "Maximum Power with Colour",
        ["maxpp:abbr:colour"] = "Maximum Power with Abbreviation and Colour",
        ["missingpp"] = "Missing Power",
        ["curpp:manapercent"] = "Current Power but Mana as Percentage",
        ["curpp:manapercent:abbr"] = "Current Power but Mana as Percentage with Abbreviation",
        ["curpp:manapercent-with-sign"] = "Current Power but Mana as Percentage with % Sign",
        ["curpp:manapercent-with-sign:abbr"] = "Current Power but Mana as Percentage with % Sign and Abbreviation",
    },
    {
        "perpp",
        "curpp",
        "curpp:colour",
        "curpp:abbr",
        "curpp:abbr:colour",
        "curpp:manapercent",
        "curpp:manapercent:abbr",
        "maxpp",
        "maxpp:abbr",
        "maxpp:colour",
        "maxpp:abbr:colour",
        "missingpp",
    }
}

local NameTags = {
    {
        ["name"] = "Unit Name",
        ["name:colour"] = "Unit Name with Colour",
        ["name:short:10"] = "Unit Name Shortened (1 - 25 Chars)",
        ["name:short:10:colour"] = "Unit Name Shortened (1 - 25 Chars) with Colour",
    },
    {
        "name",
        "name:colour",
        "name:short:10",
        "name:short:10:colour",
    }
}

local MiscTags = {
    {
        ["classification"] = "Unit Classification",
        ["shortclassification"] = "Unit Classification with Abbreviation",
        ["creature"] = "Creature Type",
        ["group"] = "Group Number",
        ["level"] = "Unit Level",
        ["smartlevel"] = "Unit Level with Elite Indicator",
        ["threat"] = "Unit Threat Status (++/--/Aggro)",
        ["threatcolor"] = "Unit Threat Status with Colour",
        ["powercolor"] = "Unit Power Colour - Prefix",
        ["raidcolor"] = "Unit Class Colour - Prefix",
        ["class"] = "Unit Class",
        ["resetcolor"] = "Resets Colour Prefix",
    },
    {
        "classification",
        "shortclassification",
        "creature",
        "group",
        "level",
        "smartlevel",
        "threat",
        "threatcolor",
        "powercolor",
        "raidcolor",
        "class",
        "resetcolor",
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

function UUFG:GetTags()
    return oUF.Tags
end
