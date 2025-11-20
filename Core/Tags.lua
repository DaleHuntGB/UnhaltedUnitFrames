local _, UUF = ...
local UUFTags = {}

function UUF:RegisterTag(name, func)
    UUFTags[name] = func
end


local function FetchNameTextColour(unit, DB, GeneralDB)
    local NDB = DB.Tags.Name

    if NDB.ColourByStatus then
        if unit == "pet" then
            local _, class = UnitClass("player")
            local classColour = RAID_CLASS_COLORS[class]
            if classColour then return classColour.r, classColour.g, classColour.b end
        end

        if UnitIsPlayer(unit) then
            local _, class = UnitClass(unit)
            local classColour = RAID_CLASS_COLORS[class]
            if classColour then return classColour.r, classColour.g, classColour.b end
        end

        local reaction = UnitReaction(unit, "player") or 5
        local reactionColour = GeneralDB.CustomColours.Reaction[reaction]
        if reactionColour then return reactionColour[1], reactionColour[2], reactionColour[3] end
    end

    local textColour = NDB.Colour
    return textColour[1], textColour[2], textColour[3]
end

local function EvaluateTag(unit, tag)
    tag = tag:sub(2)
    local method = UUFTags[tag]
    if not method then return "?" end
    return method(unit) or ""
end

function UUF:EvaluateTagString(unit, text)
    if not text or not unit then return "" end
    local tag = text:match("%[(.-)%]")
    if not tag then return "" end
    local func = UUFTags[tag]
    if not func then return "" end
    local ok, result = pcall(func, unit)
    if not ok then return "" end
    if result == nil then return "" end
    return tostring(result)
end


UUF:RegisterTag("curhp", function(unit) return UnitHealth(unit) end)
UUF:RegisterTag("curhp:abbr" , function(unit) return AbbreviateLargeNumbers(UnitHealth(unit)) end)
UUF:RegisterTag("maxhp", function(unit) return UnitHealthMax(unit) end)
UUF:RegisterTag("maxhp:abbr", function(unit) return AbbreviateLargeNumbers(UnitHealthMax(unit)) end)
UUF:RegisterTag("perhp", function(unit) return string.format("%.0f%%", UnitHealthPercent(unit, false, true)) end)
UUF:RegisterTag("curpp", function(unit) return UnitPower(unit) end)
UUF:RegisterTag("curpp:abbr", function(unit) return AbbreviateLargeNumbers(UnitPower(unit)) end)
UUF:RegisterTag("maxpp", function(unit) return UnitPowerMax(unit) end)
UUF:RegisterTag("maxpp:abbr", function(unit) return AbbreviateLargeNumbers(UnitPowerMax(unit)) end)
UUF:RegisterTag("perpp", function(unit) return string.format("%.0f%%", UnitPowerPercent(unit, false, true)) end)
UUF:RegisterTag("name", function(unit) return UnitName(unit) end)
