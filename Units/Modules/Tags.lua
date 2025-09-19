local _, UUF = ...
local oUF = UUF.oUF
oUF.Tags = oUF.Tags or {}

local TagEvents = {
    ["health:curhp"]                            = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED",
    ["health:perhp"]                            = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED",
    ["health:curhp-perhp"]                      = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED",
    ["health:curhp-perhp-with-absorb"]          = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED UNIT_ABSORB_AMOUNT_CHANGED",
    ["health:absorb"]                           = "UNIT_ABSORB_AMOUNT_CHANGED UNIT_CONNECTION PLAYER_FLAGS_CHANGED",
    ["health:missinghp"]                        = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED",
    ["health:perhp-healermana"]                 = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_POWER_UPDATE UNIT_MAXPOWER UNIT_CONNECTION PLAYER_FLAGS_CHANGED",
    ["health:perhp-healermana:colour"]          = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_POWER_UPDATE UNIT_MAXPOWER UNIT_CONNECTION PLAYER_FLAGS_CHANGED",
    ["power:curpp"]                             = "UNIT_POWER_UPDATE UNIT_MAXPOWER UNIT_CONNECTION PLAYER_FLAGS_CHANGED",
    ["power:perpp"]                             = "UNIT_POWER_UPDATE UNIT_MAXPOWER",
    ["power:healer-perpp"]                      = "UNIT_POWER_UPDATE UNIT_MAXPOWER GROUP_ROSTER_UPDATE",
    ["name:veryshort"]                          = "UNIT_NAME_UPDATE",
    ["name:short"]                              = "UNIT_NAME_UPDATE",
    ["name:medium"]                             = "UNIT_NAME_UPDATE",
    ["name:abbreviated"]                        = "UNIT_NAME_UPDATE",
    ["name:last"]                               = "UNIT_NAME_UPDATE",
    ["name:targettarget"]                       = "UNIT_NAME_UPDATE",
    ["name:targettarget:veryshort"]             = "UNIT_NAME_UPDATE",
    ["name:targettarget:short"]                 = "UNIT_NAME_UPDATE",
    ["name:targettarget:medium"]                = "UNIT_NAME_UPDATE",
    ["name:targettarget:last"]                  = "UNIT_NAME_UPDATE",
    ["name:targettarget:colour"]                = "UNIT_NAME_UPDATE UNIT_FACTION UNIT_TARGET PLAYER_FOCUS_CHANGED",
    ["name:targettarget:veryshort:colour"]      = "UNIT_NAME_UPDATE UNIT_FACTION UNIT_TARGET PLAYER_FOCUS_CHANGED",
    ["name:targettarget:short:colour"]          = "UNIT_NAME_UPDATE UNIT_FACTION UNIT_TARGET PLAYER_FOCUS_CHANGED",
    ["name:targettarget:medium:colour"]         = "UNIT_NAME_UPDATE UNIT_FACTION UNIT_TARGET PLAYER_FOCUS_CHANGED",
    ["name:targettarget:last:colour"]           = "UNIT_NAME_UPDATE UNIT_FACTION UNIT_TARGET PLAYER_FOCUS_CHANGED",
    ["classcolour"]                             = "UNIT_CONNECTION PLAYER_FLAGS_CHANGED",
    ["reactioncolour"]                          = "UNIT_FACTION",
    ["colour"]                                  = "UNIT_FACTION UNIT_CONNECTION PLAYER_FLAGS_CHANGED",
    ["powercolour"]                             = "UNIT_DISPLAYPOWER UNIT_POWER_UPDATE UNIT_MAXPOWER",
    ["status"]                                  = "UNIT_HEALTH PLAYER_UPDATE_RESTING UNIT_CONNECTION",
    ["threatcolour"]                            = "UNIT_THREAT_SITUATION_UPDATE",
}

for tag, events in pairs(TagEvents) do
    oUF.Tags.Events[tag] = (oUF.Tags.Events[tag] and (oUF.Tags.Events[tag] .. " ") or "") .. events
end

oUF.Tags.Methods["health:curhp"] = function(unit)
    if UUF.BossTestMode and unit and unit:match("^boss%d+$") then return UUF:FetchTestTags("health:curhp") end
    if not unit or not UnitExists(unit) then return "" end
    local uHealth = UnitHealth(unit)
    local uStatus = UnitIsDead(unit) and "Dead" or UnitIsGhost(unit) and "Ghost" or not UnitIsConnected(unit) and "Offline"
    if uStatus then
        return uStatus
    else
        return string.format("%s", UUF:FormatLargeNumber(uHealth))
    end
end

oUF.Tags.Methods["health:perhp"] = function(unit)
    if UUF.BossTestMode and unit and unit:match("^boss%d+$") then return UUF:FetchTestTags("health:perhp") end
    if not unit or not UnitExists(unit) then return "" end
    local uHealth = UnitHealth(unit)
    local uMaxHealth = UnitHealthMax(unit)
    local uHealthPercent = (uMaxHealth > 0) and (uHealth / uMaxHealth * 100) or 0
    local uStatus = UnitIsDead(unit) and "Dead" or UnitIsGhost(unit) and "Ghost" or not UnitIsConnected(unit) and "Offline"
    if uStatus then
        return uStatus
    else
        return string.format("%s", UUF:FormatPercent(uHealthPercent))
    end
end

oUF.Tags.Methods["health:curhp-perhp"] = function(unit)
    if UUF.BossTestMode and unit and unit:match("^boss%d+$") then return UUF:FetchTestTags("health:curhp-perhp") end
    local HealthSeparator = UUF.HealthSeparator
    if not unit or not UnitExists(unit) then return "" end
    local uHealth = UnitHealth(unit)
    local uMaxHealth = UnitHealthMax(unit)
    local uHealthPercent = (uMaxHealth > 0) and (uHealth / uMaxHealth * 100) or 0
    local uStatus = UnitIsDead(unit) and "Dead" or UnitIsGhost(unit) and "Ghost" or not UnitIsConnected(unit) and "Offline"
    if uStatus then
        return uStatus
    else
        return string.format("%s %s %s", UUF:FormatLargeNumber(uHealth), HealthSeparator, UUF:FormatPercent(uHealthPercent))
    end
end

oUF.Tags.Methods["health:curhp-perhp-with-absorb"] = function(unit)
    local HealthSeparator = UUF.HealthSeparator
    if UUF.BossTestMode and unit and unit:match("^boss%d+$") then return UUF:FetchTestTags("health:curhp-perhp-with-absorb") end
    if not unit or not UnitExists(unit) then return "" end
    local uHealth = UnitHealth(unit)
    local uMaxHealth = UnitHealthMax(unit)
    local uAbsorb = UnitGetTotalAbsorbs(unit) or 0
    local uEffectiveHealth = uHealth + uAbsorb
    local uHealthPercent = (uMaxHealth > 0) and (uEffectiveHealth / uMaxHealth * 100) or 0
    local uStatus = UnitIsDead(unit) and "Dead" or UnitIsGhost(unit) and "Ghost" or not UnitIsConnected(unit) and "Offline"
    if uStatus then
        return uStatus
    else
        return string.format("%s %s %s", UUF:FormatLargeNumber(uHealth), HealthSeparator, UUF:FormatPercent(uHealthPercent))
    end
end

oUF.Tags.Methods["health:absorb"] = function(unit)
    if UUF.BossTestMode and unit and unit:match("^boss%d+$") then return UUF:FetchTestTags("health:absorb") end
    if not unit or not UnitExists(unit) then return "" end
    local uAbsorb = UnitGetTotalAbsorbs(unit) or 0
    if uAbsorb > 0 then
        return string.format("%s", UUF:FormatLargeNumber(uAbsorb))
    end
end

oUF.Tags.Methods["health:missinghp"] = function(unit)
    if UUF.BossTestMode and unit and unit:match("^boss%d+$") then return UUF:FetchTestTags("health:missinghp") end
    if not unit or not UnitExists(unit) then return "" end
    local uHealth = UnitHealth(unit)
    local uMaxHealth = UnitHealthMax(unit)
    local uMissingHealth = (uMaxHealth > 0) and (uMaxHealth - uHealth) or 0
    if uMissingHealth > 0 then
        return string.format("%s", UUF:FormatLargeNumber(uMissingHealth))
    end
end

oUF.Tags.Methods["health:perhp-healermana"] = function(unit)
    if UUF.BossTestMode and unit and unit:match("^boss%d+$") then return UUF:FetchTestTags("health:perhp-healermana") end
    local HealthSeparator = UUF.HealthSeparator
    if not unit or not UnitExists(unit) then return "" end
    local uHealth = UnitHealth(unit)
    local uMaxHealth = UnitHealthMax(unit)
    local uHealthPercent = (uMaxHealth > 0) and (uHealth / uMaxHealth * 100) or 0
    local powerType = UnitPowerType(unit)
    local uPower = UnitPower(unit)
    local uMaxPower = UnitPowerMax(unit)
    local uPowerPercent = (uMaxPower > 0) and (uPower / uMaxPower * 100) or 0
    local isHealer = UnitGroupRolesAssigned(unit) == "HEALER"
    if isHealer and powerType == 0 then
        return string.format("%s %s %s", UUF:FormatPercent(uHealthPercent), HealthSeparator, UUF:FormatPercent(uPowerPercent))
    elseif isHealer then
        return string.format("%s %s %s", UUF:FormatPercent(uHealthPercent), HealthSeparator, UUF:FormatPercent(uPowerPercent))
    else
        return string.format("%s", UUF:FormatPercent(uHealthPercent))
    end
end

oUF.Tags.Methods["health:perhp-healermana:colour"] = function(unit)
    if UUF.BossTestMode and unit and unit:match("^boss%d+$") then return UUF:FetchTestTags("health:perhp-healermana") end
    local HealthSeparator = UUF.HealthSeparator
    if not unit or not UnitExists(unit) then return "" end
    local uHealth = UnitHealth(unit)
    local uMaxHealth = UnitHealthMax(unit)
    local uHealthPercent = (uMaxHealth > 0) and (uHealth / uMaxHealth * 100) or 0
    local uPower = UnitPower(unit)
    local uMaxPower = UnitPowerMax(unit)
    local uPowerPercent = (uMaxPower > 0) and (uPower / uMaxPower * 100) or 0
    local isHealer = UnitGroupRolesAssigned(unit) == "HEALER"
    local powerType, powerToken = UnitPowerType(unit)
    local powerColour = oUF.colors.power[powerToken] or oUF.colors.power[powerType]
    if powerColour then
        powerColour = CreateColor(powerColour[1], powerColour[2], powerColour[3]):GenerateHexColor()
    end
    if isHealer and powerType == 0 then
        return string.format("%s %s |c%s%s|r", UUF:FormatPercent(uHealthPercent), HealthSeparator, powerColour, UUF:FormatPercent(uPowerPercent))
    elseif isHealer then
        return string.format("%s %s |c%s%s|r", UUF:FormatPercent(uHealthPercent), HealthSeparator, powerColour, UUF:FormatPercent(uPowerPercent))
    else
        return string.format("%s", UUF:FormatPercent(uHealthPercent))
    end
end

oUF.Tags.Methods["power:curpp"] = function(unit)
    if UUF.BossTestMode and unit and unit:match("^boss%d+$") then return UUF:FetchTestTags("power:curpp") end
    if not unit or not UnitExists(unit) then return "" end
    local uPower = UnitPower(unit)
    local uMaxPower = UnitPowerMax(unit)
    local powerType = UnitPowerType(unit)
    local uPowerPercent = (uMaxPower > 0) and (uPower / uMaxPower * 100) or 0
    if powerType == 0 then
        return string.format("%s", UUF:FormatPercent(uPowerPercent))
    else
        return string.format("%s", uPower)
    end
end

oUF.Tags.Methods["power:perpp"] = function(unit)
    if UUF.BossTestMode and unit and unit:match("^boss%d+$") then return UUF:FetchTestTags("power:perpp") end
    if not unit or not UnitExists(unit) then return "" end
    local uPower = UnitPower(unit)
    local uMaxPower = UnitPowerMax(unit)
    local uPowerPercent = (uMaxPower > 0) and (uPower / uMaxPower * 100) or 0
    return string.format("%s", UUF:FormatPercent(uPowerPercent))
end

oUF.Tags.Methods["power:healer-perpp"] = function(unit)
    if UUF.BossTestMode and unit and unit:match("^boss%d+$") then return UUF:FetchTestTags("power:healer-perpp") end
    if not unit or not UnitExists(unit) then return "" end
    local uPower = UnitPower(unit)
    local uMaxPower = UnitPowerMax(unit)
    local uPowerPercent = (uMaxPower > 0) and (uPower / uMaxPower * 100) or 0
    local isHealer = UnitGroupRolesAssigned(unit) == "HEALER"
    if isHealer then
        return string.format("%s", UUF:FormatPercent(uPowerPercent))
    end
end

oUF.Tags.Methods["name:veryshort"] = function(unit)
    if UUF.BossTestMode and unit and unit:match("^boss%d+$") then return UUF:FetchTestTags("name:veryshort") end
    if not unit or not UnitExists(unit) then return "" end
    local uName = UnitName(unit)
    if #uName > 5 then
        return string.sub(uName, 1, 5)
    else
        return uName
    end
end

oUF.Tags.Methods["name:short"] = function(unit)
    if UUF.BossTestMode and unit and unit:match("^boss%d+$") then return UUF:FetchTestTags("name:short") end
    if not unit or not UnitExists(unit) then return "" end
    local uName = UnitName(unit)
    if #uName > 8 then
        return string.sub(uName, 1, 8)
    else
        return uName
    end
end

oUF.Tags.Methods["name:medium"] = function(unit)
    if UUF.BossTestMode and unit and unit:match("^boss%d+$") then return UUF:FetchTestTags("name:medium") end
    if not unit or not UnitExists(unit) then return "" end
    local uName = UnitName(unit)
    if #uName > 12 then
        return string.sub(uName, 1, 12)
    else
        return uName
    end
end

oUF.Tags.Methods["name:abbreviated"] = function(unit)
    if UUF.BossTestMode and unit and unit:match("^boss%d+$") then return UUF:FetchTestTags("name:abbreviated") end
    if not unit or not UnitExists(unit) then return "" end
    local uName = UnitName(unit)
    local nameParts = {}
    for part in string.gmatch(uName, "%S+") do
        table.insert(nameParts, part)
    end
    for i = 1, #nameParts - 1 do
        nameParts[i] = string.sub(nameParts[i], 1, 1) .. "."
    end
    return table.concat(nameParts, " ")
end

oUF.Tags.Methods["name:last"] = function(unit)
    if UUF.BossTestMode and unit and unit:match("^boss%d+$") then return UUF:FetchTestTags("name:last") end
    if not unit or not UnitExists(unit) then return "" end
    local uName = UnitName(unit)
    local nameParts = {}
    if uName then
        for part in string.gmatch(uName, "%S+") do
            table.insert(nameParts, part)
        end
    end
    return nameParts[#nameParts]
end

oUF.Tags.Methods["name:targettarget"] = function(unit)
    local TargetTargetSeparator = UUF.TargetTargetSeparator
    if UUF.BossTestMode and unit and unit:match("^boss%d+$") then return UUF:FetchTestTags("name:targettarget") end
    if not unit or not UnitExists(unit) then return "" end
    local unitToken = unit.."target"
    local unitName = UnitName(unitToken)
    if not unitName or unitName == "" then return "" end
    return " |cFFFFFFFF" .. TargetTargetSeparator .. "|r " .. unitName
end

oUF.Tags.Methods["name:targettarget:veryshort"] = function(unit)
    local TargetTargetSeparator = UUF.TargetTargetSeparator
    if UUF.BossTestMode and unit and unit:match("^boss%d+$") then return UUF:FetchTestTags("name:targettarget:veryshort") end
    if not unit or not UnitExists(unit) then return "" end
    local unitToken = unit.."target"
    local unitName = UnitName(unitToken)
    if not unitName or unitName == "" then return "" end
    local unitNameShortened = (#unitName > 5) and unitName:sub(1, 5) or unitName
    return " |cFFFFFFFF" .. TargetTargetSeparator .. "|r " .. unitNameShortened
end

oUF.Tags.Methods["name:targettarget:short"] = function(unit)
    local TargetTargetSeparator = UUF.TargetTargetSeparator
    if UUF.BossTestMode and unit and unit:match("^boss%d+$") then return UUF:FetchTestTags("name:targettarget:short") end
    if not unit or not UnitExists(unit) then return "" end
    local unitToken = unit.."target"
    local unitName = UnitName(unitToken)
    if not unitName or unitName == "" then return "" end
    local unitNameShortened = (#unitName > 8) and unitName:sub(1, 8) or unitName
    return " |cFFFFFFFF" .. TargetTargetSeparator .. "|r " .. unitNameShortened
end

oUF.Tags.Methods["name:targettarget:medium"] = function(unit)
    local TargetTargetSeparator = UUF.TargetTargetSeparator
    if UUF.BossTestMode and unit and unit:match("^boss%d+$") then return UUF:FetchTestTags("name:targettarget:medium") end
    if not unit or not UnitExists(unit) then return "" end
    local unitToken = unit.."target"
    local unitName = UnitName(unitToken)
    if not unitName or unitName == "" then return "" end
    local unitNameShortened = (#unitName > 12) and unitName:sub(1, 12) or unitName
    return " |cFFFFFFFF" .. TargetTargetSeparator .. "|r " .. unitNameShortened
end

oUF.Tags.Methods["name:targettarget:last"] = function(unit)
    local TargetTargetSeparator = UUF.TargetTargetSeparator
    if UUF.BossTestMode and unit and unit:match("^boss%d+$") then return UUF:FetchTestTags("name:targettarget:last") end
    if not unit or not UnitExists(unit) then return "" end
    local unitToken = unit.."target"
    local unitName = UnitName(unitToken)
    if not unitName or unitName == "" then return "" end
    local last = unitName:match("([^%s]+)$") or unitName
    return " |cFFFFFFFF" .. TargetTargetSeparator .. "|r " .. last
end

oUF.Tags.Methods["name:targettarget:colour"] = function(unit)
    local TargetTargetSeparator = UUF.TargetTargetSeparator
    if UUF.BossTestMode and unit and unit:match("^boss%d+$") then return UUF:FetchTestTags("name:targettarget:colour") end
    if not unit or not UnitExists(unit) then return "" end
    local unitToken = unit.."target"
    local unitName = UnitName(unitToken)
    if not unitName or unitName == "" then return "" end
    return " |cFFFFFFFF" .. TargetTargetSeparator .. "|r " .. UUF:WrapTextInColor(unitName, unitToken)
end


oUF.Tags.Methods["name:targettarget:veryshort:colour"] = function(unit)
    local TargetTargetSeparator = UUF.TargetTargetSeparator
    if UUF.BossTestMode and unit and unit:match("^boss%d+$") then return UUF:FetchTestTags("name:targettarget:veryshort:colour") end
    if not unit or not UnitExists(unit) then return "" end
    local unitToken = unit.."target"
    local unitName = UnitName(unitToken)
    if not unitName or unitName == "" then return "" end
    local unitNameShortened = (#unitName > 5) and unitName:sub(1, 5) or unitName
    return " |cFFFFFFFF" .. TargetTargetSeparator .. "|r " .. UUF:WrapTextInColor(unitNameShortened, unitToken)
end

oUF.Tags.Methods["name:targettarget:short:colour"] = function(unit)
    local TargetTargetSeparator = UUF.TargetTargetSeparator
    if UUF.BossTestMode and unit and unit:match("^boss%d+$") then return UUF:FetchTestTags("name:targettarget:short:colour") end
    if not unit or not UnitExists(unit) then return "" end
    local unitToken = unit.."target"
    local unitName = UnitName(unitToken)
    if not unitName or unitName == "" then return "" end
    local unitNameShortened = (#unitName > 8) and unitName:sub(1, 8) or unitName
    return " |cFFFFFFFF" .. TargetTargetSeparator .. "|r " .. UUF:WrapTextInColor(unitNameShortened, unitToken)
end

oUF.Tags.Methods["name:targettarget:medium:colour"] = function(unit)
    local TargetTargetSeparator = UUF.TargetTargetSeparator
    if UUF.BossTestMode and unit and unit:match("^boss%d+$") then return UUF:FetchTestTags("name:targettarget:medium:colour") end
    if not unit or not UnitExists(unit) then return "" end
    local unitToken = unit.."target"
    local unitName = UnitName(unitToken)
    if not unitName or unitName == "" then return "" end
    local unitNameShortened = (#unitName > 12) and unitName:sub(1, 12) or unitName
    return " |cFFFFFFFF" .. TargetTargetSeparator .. "|r " .. UUF:WrapTextInColor(unitNameShortened, unitToken)
end

oUF.Tags.Methods["name:targettarget:last:colour"] = function(unit)
    local TargetTargetSeparator = UUF.TargetTargetSeparator
    if UUF.BossTestMode and unit and unit:match("^boss%d+$") then return UUF:FetchTestTags("name:targettarget:last:colour") end
    if not unit or not UnitExists(unit) then return "" end
    local unitToken = unit.."target"
    local unitName = UnitName(unitToken)
    if not unitName or unitName == "" then return "" end
    local unitNameShortened = unitName:match("([^%s]+)$") or unitName
    return " |cFFFFFFFF" .. TargetTargetSeparator .. "|r " .. UUF:WrapTextInColor(unitNameShortened, unitToken)
end


oUF.Tags.Methods["classcolour"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    local _, class = UnitClass(unit)
    if class then
        local colour = RAID_CLASS_COLORS[class]
        return string.format("|c%s", colour.colorStr)
    end
end

oUF.Tags.Methods["reactioncolour"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    local reaction = UnitReaction(unit, "player")
    if reaction then
        local r, g, b = unpack(oUF.colors.reaction[reaction])
        return string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
    end
end

oUF.Tags.Methods["colour"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end

    if UnitIsPlayer(unit) or UnitInParty(unit) or UnitInRaid(unit) then
        local _, class = UnitClass(unit)
        if class then
            local colour = RAID_CLASS_COLORS[class]
            if colour then
                return string.format("|cff%02x%02x%02x", colour.r * 255, colour.g * 255, colour.b * 255)
            end
        end
    end

    local reaction = UnitReaction(unit, "player")
    if reaction then
        local r, g, b = unpack(oUF.colors.reaction[reaction])
        return string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
    end

    return ""
end

oUF.Tags.Methods["powercolour"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    local powerType, powerToken = UnitPowerType(unit)
    local colour = oUF.colors.power[powerToken] or oUF.colors.power[powerType]
    if colour then
        return string.format("|cff%02x%02x%02x", colour[1] * 255, colour[2] * 255, colour[3] * 255)
    end
end

oUF.Tags.Methods["status"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    if UnitIsDead(unit) then
        return "Dead"
    elseif UnitIsGhost(unit) then
        return "Ghost"
    elseif not UnitIsConnected(unit) then
        return "Offline"
    elseif unit == "player" and IsResting() then
        return "Resting"
    end
end

oUF.Tags.Methods["threatcolour"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    local r, g, b = GetThreatStatusColor(UnitThreatSituation(unit) or 0)
    if r and g and b then
        return string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
    end
end

oUF.Tags.Methods["group"] = function(unit)
    if not unit or not UnitExists(unit) then return "" end
    if not UnitInRaid(unit) then return "" end
    local name, server = UnitName(unit)
    if(server and server ~= '') then
        name = string.format('%s-%s', name, server)
    end

    for i=1, GetNumGroupMembers() do
        local raidName, _, group = GetRaidRosterInfo(i)
        if(raidName == name) then
            return "G" .. group
        end
    end
end

function UUF:FetchTestTags(tag)
    local HealthSeparator = UUF.HealthSeparator or "||"
    local TargetTargetSeparator = UUF.TargetTargetSeparator or "»"
    local testValues = {
        ["health:curhp"] = UUF:FormatLargeNumber(0.25 * 15e6),
        ["health:perhp"] = UUF:FormatPercent(25),
        ["health:curhp-perhp"] = UUF:FormatLargeNumber(0.25 * 15e6) .. " " .. HealthSeparator .. " " .. UUF:FormatPercent(25),
        ["health:curhp-perhp-with-absorb"] = UUF:FormatLargeNumber(0.25 * 15e6) .. " " .. HealthSeparator .. " " .. UUF:FormatPercent(25),
        ["health:absorb"] = UUF:FormatLargeNumber(0.25 * 15e6),
        ["health:missinghp"] = UUF:FormatLargeNumber(0.75 * 15e6),
        ["health:perhp-healermana"] = UUF:FormatPercent(25) .. " " .. HealthSeparator .. " " .. UUF:FormatPercent(75),


        ["power:curpp"] = UUF:FormatLargeNumber(0.25 * 15e6),
        ["power:perpp"] = UUF:FormatPercent(25),
        ["power:healer-perpp"] = UUF:FormatPercent(25),

        ["name:veryshort"] = string.sub(UnitName("player") or "Player", 1, 5),
        ["name:short"] = string.sub(UnitName("player") or "Player", 1, 8),
        ["name:medium"] = string.sub(UnitName("player") or "Player", 1, 12),
        ["name:abbreviated"] = "D. Stormrage",
        ["name:last"] = "Stormrage",

        ["name:targettarget"] = " |cFFFFFFFF" .. TargetTargetSeparator .. "|r Jaina",
        ["name:targettarget:veryshort"] = " |cFFFFFFFF" .. TargetTargetSeparator .. "|r Jain",
        ["name:targettarget:short"] = " |cFFFFFFFF" .. TargetTargetSeparator .. "|r Jaina",
        ["name:targettarget:medium"] = " |cFFFFFFFF" .. TargetTargetSeparator .. "|r Jaina Proudmoore",
        ["name:targettarget:last"] = " |cFFFFFFFF" .. TargetTargetSeparator .. "|r Proudmoore",

        ["name:targettarget:colour"] = " |cFFFFFFFF" .. TargetTargetSeparator .. "|r |cff0070DEJaina|r",
        ["name:targettarget:veryshort:colour"] = " |cFFFFFFFF" .. TargetTargetSeparator .. "|r |cff0070DEJain|r",
        ["name:targettarget:short:colour"] = " |cFFFFFFFF" .. TargetTargetSeparator .. "|r |cff0070DEJaina|r",
        ["name:targettarget:medium:colour"] = " |cFFFFFFFF" .. TargetTargetSeparator .. "|r |cff0070DEJaina Proudmoore|r",
        ["name:targettarget:last:colour"] = " |cFFFFFFFF" .. TargetTargetSeparator .. "|r |cff0070DEProudmoore|r",
    }
    return testValues[tag]
end



function UUF:GetHealthTags()
    local healthTags = {
        ["health:curhp"] = "Current Health",
        ["health:perhp"] = "Percent Health",
        ["health:curhp-perhp"] = "Current Health with Percent Health",
        ["health:curhp-perhp-with-absorb"] = "Current Health with Percent Health (Absorbs)",
        ["health:absorb"] = "Current Absorb",
        ["health:missinghp"] = "Missing Health",
        ["health:perhp-healermana"] = "Percent Health / Healer Mana Percent",
        ["health:perhp-healermana:colour"] = "Percent Health / Healer Mana Percent (Mana Colour)",
    }

    local healthTagsOrdered = {
        "health:curhp",
        "health:perhp",
        "health:curhp-perhp",
        "health:curhp-perhp-with-absorb",
        "health:absorb",
        "health:missinghp",
        "health:perhp-healermana",
        "health:perhp-healermana:colour",
    }
    return healthTags, healthTagsOrdered
end

function UUF:GetPowerTags()
    local powerTags = {
        ["power:curpp"] = "Current Power",
        ["power:perpp"] = "Percent Power",
        ["power:healer-perpp"] = "Percent Power (Healers Only)",
    }

    local powerTagsOrdered = {
        "power:curpp",
        "power:perpp",
        "power:healer-perpp",
    }
    return powerTags, powerTagsOrdered
end

function UUF:GetNameTags()
    local nameTags = {
        ["name"] = "Full",
        ["name:veryshort"] = "Very Short - 5 Characters",
        ["name:short"] = "Short - 8 Characters",
        ["name:medium"] = "Medium - 12 Characters",
        ["name:abbreviated"] = "Abbreviated - First Initials",
        ["name:last"] = "Last",
        ["name:targettarget"] = "Target of Target",
        ["name:targettarget:veryshort"] = "Target of Target - 5 Characters",
        ["name:targettarget:short"] = "Target of Target - 8 Characters",
        ["name:targettarget:medium"] = "Target of Target - 12 Characters",
        ["name:targettarget:last"] = "Target of Target - Last",
        ["name:targettarget:colour"] = "Target of Target - Class/Reaction Colour",
        ["name:targettarget:veryshort:colour"] = "Target of Target - 5 Characters - Class/Reaction Colour",
        ["name:targettarget:short:colour"] = "Target of Target - 8 Characters - Class/Reaction Colour",
        ["name:targettarget:medium:colour"] = "Target of Target - 12 Characters - Class/Reaction Colour",
        ["name:targettarget:last:colour"] = "Target of Target - Last - Class/Reaction Colour",
    }

    local nameTagsOrdered = {
        "name",
        "name:veryshort",
        "name:short",
        "name:medium",
        "name:abbreviated",
        "name:last",
        "name:targettarget",
        "name:targettarget:veryshort",
        "name:targettarget:short",
        "name:targettarget:medium",
        "name:targettarget:last",
        "name:targettarget:colour",
        "name:targettarget:veryshort:colour",
        "name:targettarget:short:colour",
        "name:targettarget:medium:colour",
        "name:targettarget:last:colour",
    }
    return nameTags, nameTagsOrdered
end

function UUF:GetMiscTags()
    local miscTags = {
        ["colour"] = "Class & Reaction Colour",
        ["classcolour"] = "Class Colour",
        ["reactioncolour"] = "Reaction Colour",
        ["powercolour"] = "Power Colour",
        ["threatcolour"] = "Threat Colour",
        ["classification"] = "Classification",
        ["shortclassification"] = "Short Classification (R, R+, +, B, -)",
        ["level"] = "Level",
        ["threat"] = "Threat (++, --, Aggro)",
        ["status"] = "Status (Dead, Ghost, Resting)",
        ["creature"] = "Creature Type",
        ["group"] = "Group Number (Raid Only)",
    }

    local miscTagsOrdered = {
        "colour",
        "classcolour",
        "reactioncolour",
        "powercolour",
        "threatcolour",
        "classification",
        "shortclassification",
        "status",
        "level",
        "threat",
        "creature",
        "group",
    }
    return miscTags, miscTagsOrdered
end

function UUF:GetTagsForGroup(tagGroup)
    if tagGroup == "Health" then
        return UUF:GetHealthTags()
    elseif tagGroup == "Power" then
        return UUF:GetPowerTags()
    elseif tagGroup == "Name" then
        return UUF:GetNameTags()
    elseif tagGroup == "Misc" then
        return UUF:GetMiscTags()
    end
end