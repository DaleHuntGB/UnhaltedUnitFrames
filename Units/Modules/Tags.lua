local _, UUF = ...
local oUF = UUF.oUF
local NSM = C_AddOns.IsAddOnLoaded("NorthernSkyMedia") or C_AddOns.IsAddOnLoaded("NorthernSkyRaidTools")

function UUF:SetTagUpdateInterval()
    oUF.Tags:SetEventUpdateTimer(UUF.DB.global.TagUpdateInterval or 0.5)
end
oUF.Tags.Methods["Health:CurHPwithPerHP"] = function(unit)
    local unitHealth = UnitHealth(unit)
    local unitMaxHealth = UnitHealthMax(unit)
    local unitAbsorb = UnitGetTotalAbsorbs(unit) or 0
    local effectiveHealth = unitHealth + unitAbsorb
    local unitHealthPercent = (unitMaxHealth > 0) and (effectiveHealth / unitMaxHealth * 100) or 0
    local unitStatus = UnitIsDead(unit) and "Dead" or UnitIsGhost(unit) and "Ghost" or not UnitIsConnected(unit) and "Offline"
    if unitStatus then
        return unitStatus
    else
        return string.format("%s - %.1f%%", UUF:FormatLargeNumber(unitHealth), unitHealthPercent)
    end
end

oUF.Tags.Methods["Health:CurHPwithPerHP:Clean"] = function(unit)
    local unitHealth = UnitHealth(unit)
    local unitMaxHealth = UnitHealthMax(unit)
    local unitAbsorb = UnitGetTotalAbsorbs(unit) or 0
    local effectiveHealth = unitHealth + unitAbsorb
    local unitHealthPercent = (unitMaxHealth > 0) and (effectiveHealth / unitMaxHealth * 100) or 0
    local unitStatus = UnitIsDead(unit) and "Dead" or UnitIsGhost(unit) and "Ghost" or not UnitIsConnected(unit) and "Offline"
    if unitStatus then
        return unitStatus
    else
        return string.format("%s - %.1f", UUF:FormatLargeNumber(unitHealth), unitHealthPercent)
    end
end

oUF.Tags.Methods["Health:PerHPwithAbsorbs"] = function(unit)
    local unitHealth = UnitHealth(unit)
    local unitMaxHealth = UnitHealthMax(unit)
    local unitAbsorb = UnitGetTotalAbsorbs(unit) or 0
    if unitAbsorb and unitAbsorb > 0 then unitHealth = unitHealth + unitAbsorb end
    local unitHealthPercent = (unitMaxHealth > 0) and (unitHealth / unitMaxHealth * 100) or 0
    return string.format("%.1f%%", unitHealthPercent)
end

oUF.Tags.Methods["Health:PerHPwithAbsorbs:Clean"] = function(unit)
    local unitHealth = UnitHealth(unit)
    local unitMaxHealth = UnitHealthMax(unit)
    local unitAbsorb = UnitGetTotalAbsorbs(unit) or 0
    if unitAbsorb and unitAbsorb > 0 then unitHealth = unitHealth + unitAbsorb end
    local unitHealthPercent = (unitMaxHealth > 0) and (unitHealth / unitMaxHealth * 100) or 0
    return string.format("%.1f", unitHealthPercent)
end

oUF.Tags.Methods["Health:PerHP"] = function(unit)
    local unitHealth = UnitHealth(unit)
    local unitMaxHealth = UnitHealthMax(unit)
    local unitHealthPercent = (unitMaxHealth > 0) and (unitHealth / unitMaxHealth * 100) or 0
    return string.format("%.1f%%", unitHealthPercent)
end

oUF.Tags.Methods["Health:PerHP:Clean"] = function(unit)
    local unitHealth = UnitHealth(unit)
    local unitMaxHealth = UnitHealthMax(unit)
    local unitHealthPercent = (unitMaxHealth > 0) and (unitHealth / unitMaxHealth * 100) or 0
    return string.format("%.1f", unitHealthPercent)
end

oUF.Tags.Methods["Health:CurHP"] = function(unit)
    local unitHealth = UnitHealth(unit)
    local unitStatus = UnitIsDead(unit) and "Dead" or UnitIsGhost(unit) and "Ghost" or not UnitIsConnected(unit) and "Offline"
    if unitStatus then
        return unitStatus
    else
        return string.format("%s", UUF:FormatLargeNumber(unitHealth))
    end
end

oUF.Tags.Methods["Health:CurHPwithAbsorbs"] = function(unit)
    local unitHealth = UnitHealth(unit)
    local unitMaxHealth = UnitHealthMax(unit)
    local unitAbsorb = UnitGetTotalAbsorbs(unit) or 0
    if unitAbsorb and unitAbsorb > 0 then unitHealth = unitHealth + unitAbsorb end
    return string.format("%s", UUF:FormatLargeNumber(unitHealth))
end

oUF.Tags.Methods["Health:CurAbsorbs"] = function(unit)
    local unitAbsorb = UnitGetTotalAbsorbs(unit) or 0
    if unitAbsorb > 0 then 
        return UUF:FormatLargeNumber(unitAbsorb)
    end
end

oUF.Tags.Methods["Name:NamewithTargetTarget"] = function(unit)
    local unitName = UnitName(unit)
    local unitTarget = UnitName(unit .. "target")
    if unitTarget and unitTarget ~= "" then
        return string.format("%s » %s", unitName, unitTarget)
    else
        return unitName
    end
end

oUF.Tags.Methods["Name:TargetTarget"] = function(unit)
    local unitTarget = UnitName(unit .. "target")
    if unitTarget and unitTarget ~= "" then
        return string.format(" » %s", unitTarget)
    end
end

oUF.Tags.Methods["Name:TargetTarget:Clean"] = function(unit)
    local unitTarget = UnitName(unit .. "target")
    if unitTarget and unitTarget ~= "" then
        return string.format("%s", unitTarget)
    end
end

oUF.Tags.Methods["Name:NamewithTargetTarget:Coloured"] = function(unit)
    local unitName = UnitName(unit)
    local unitTarget = UnitName(unit .. "target")
    local colouredUnitName = UUF:WrapTextInColor(unitName, unit)
    if unitTarget and unitTarget ~= "" then
        return string.format("%s » %s", colouredUnitName, unitTarget)
    else
        return colouredUnitName
    end
end

oUF.Tags.Methods["Name:TargetTarget:Coloured"] = function(unit)
    local unitTarget = UnitName(unit .. "target")
    if unitTarget and unitTarget ~= "" then
        return string.format(" » %s", UUF:WrapTextInColor(unitTarget, unit .. "target"))
    end
end

oUF.Tags.Methods["Name:TargetTarget:Coloured:Clean"] = function(unit)
    local unitTarget = UnitName(unit .. "target")
    if unitTarget and unitTarget ~= "" then
        return string.format("%s", UUF:WrapTextInColor(unitTarget, unit .. "target"))
    end
end

oUF.Tags.Methods["Name:NamewithTargetTarget:LastNameOnly"] = function(unit)
    local unitName = UnitName(unit)
    local unitTarget = UnitName(unit .. "target")
    local unitLastName = UUF:ShortenName(unitName, UUF.nameBlacklist)
    if unitTarget and unitTarget ~= "" then
        return string.format("%s » %s", unitLastName, UUF:ShortenName(unitTarget, UUF.nameBlacklist))
    else
        return unitLastName
    end
end

oUF.Tags.Methods["Name:NamewithTargetTarget:LastNameOnly:Coloured"] = function(unit)
    local unitName = UnitName(unit)
    local unitTarget = UnitName(unit .. "target")
    local colouredUnitName = UUF:WrapTextInColor(UUF:ShortenName(unitName, UUF.nameBlacklist), unit)
    if unitTarget and unitTarget ~= "" then
        return string.format("%s » %s", colouredUnitName, UUF:WrapTextInColor(UUF:ShortenName(unitTarget, UUF.nameBlacklist), unit .. "target"))
    else
        return colouredUnitName
    end
end

oUF.Tags.Methods["Name:LastNameOnly"] = function(unit)
    local unitName = UnitName(unit)
    return UUF:ShortenName(unitName, UUF.nameBlacklist)
end

oUF.Tags.Methods["Name:LastNameOnly:Coloured"] = function(unit)
    local unitName = UnitName(unit)
    return UUF:WrapTextInColor(UUF:ShortenName(unitName, UUF.nameBlacklist), unit)
end

oUF.Tags.Methods["Name:TargetTarget:LastNameOnly"] = function(unit)
    local unitTarget = UnitName(unit .. "target")
    if unitTarget and unitTarget ~= "" then
        return string.format(" » %s", UUF:ShortenName(unitTarget, UUF.nameBlacklist))
    end
end

oUF.Tags.Methods["Name:TargetTarget:LastNameOnly:Clean"] = function(unit)
    local unitTarget = UnitName(unit .. "target")
    if unitTarget and unitTarget ~= "" then
        return string.format("%s", UUF:ShortenName(unitTarget, UUF.nameBlacklist))
    end
end

oUF.Tags.Methods["Name:TargetTarget:LastNameOnly:Coloured"] = function(unit)
    local unitTarget = UnitName(unit .. "target")
    if unitTarget and unitTarget ~= "" then
        return string.format(" » %s", UUF:WrapTextInColor(UUF:ShortenName(unitTarget, UUF.nameBlacklist), unit .. "target"))
    end
end

oUF.Tags.Methods["Name:TargetTarget:LastNameOnly:Coloured:Clean"] = function(unit)
    local unitTarget = UnitName(unit .. "target")
    if unitTarget and unitTarget ~= "" then
        return string.format("%s", UUF:WrapTextInColor(UUF:ShortenName(unitTarget, UUF.nameBlacklist), unit .. "target"))
    end
end

oUF.Tags.Methods["Name:VeryShort"] = function(unit)
    local name = UnitName(unit)
    if name then 
        return string.sub(name, 1, 5)
    end
end

oUF.Tags.Methods["Name:Short"] = function(unit)
    local name = UnitName(unit)
    if name then 
        return string.sub(name, 1, 8)
    end
end

oUF.Tags.Methods["Name:Medium"] = function(unit)
    local name = UnitName(unit)
    if name then 
        return string.sub(name, 1, 10)
    end
end

oUF.Tags.Methods["Name:Abbreviated"] = function(unit)
    local name = UnitName(unit)
    if name then 
        return UUF:AbbreviateName(name)
    end
end

oUF.Tags.Methods["Name:Abbreviated:Coloured"] = function(unit)
    local name = UnitName(unit)
    if name then
        return UUF:WrapTextInColor(UUF:AbbreviateName(name), unit)
    end
end

if NSM then
	oUF.Tags.Methods['NSNickName'] = function(unit)
		local name = UnitName(unit)
		return name and NSAPI and NSAPI:GetName(name, "Unhalted") or name
	end

	oUF.Tags.Methods['NSNickName:veryshort'] = function(unit)
		local name = UnitName(unit)
		name = name and NSAPI and NSAPI:GetName(name, "Unhalted") or name
		return string.sub(name, 1, 5)
	end

	oUF.Tags.Methods['NSNickName:short'] = function(unit)
		local name = UnitName(unit)
		name = name and NSAPI and NSAPI:GetName(name, "Unhalted") or name
		return string.sub(name, 1, 8)
	end

	oUF.Tags.Methods['NSNickName:medium'] = function(unit)
		local name = UnitName(unit)
		name = name and NSAPI and NSAPI:GetName(name, "Unhalted") or name
		return string.sub(name, 1, 10)
	end

    for i = 1, 12 do
        oUF.Tags.Methods['NSNickName:' .. i] = function(unit)
            if i == 0 then return end
            local name = UnitName(unit)
            name = name and NSAPI and NSAPI:GetName(name, "Unhalted") or name
            if name and unit then
                return string.sub(name, 1, i)
            end
        end
    end

    oUF.Tags.Events['NSNickName'] = 'UNIT_NAME_UPDATE'
	oUF.Tags.Events['NSNickName:veryshort'] = 'UNIT_NAME_UPDATE'
	oUF.Tags.Events['NSNickName:short'] = 'UNIT_NAME_UPDATE'
	oUF.Tags.Events['NSNickName:medium'] = 'UNIT_NAME_UPDATE'
    for i = 1, 12 do
        oUF.Tags.Events['NSNickName:' .. i] = 'UNIT_NAME_UPDATE'
    end
end

oUF.Tags.Methods["ClassColour"] = function(unit)
    local _, class = UnitClass(unit)
    if class then
        local colour = RAID_CLASS_COLORS[class]
        return string.format("|c%s", colour.colorStr)
    end
end

oUF.Tags.Methods["ReactionColour"] = function(unit)
    local reaction = UnitReaction(unit, "player")
    if reaction then
        local r, g, b = unpack(oUF.colors.reaction[reaction])
        return string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
    end
end

oUF.Tags.Methods["Coloured"] = function(unit)
    local _, class = UnitClass(unit)
    if class and UnitIsPlayer(unit) then
        local colour = RAID_CLASS_COLORS[class]
        return string.format("|cff%02x%02x%02x", colour.r * 255, colour.g * 255, colour.b * 255)
    else
        local reaction = UnitReaction(unit, "player")
        if reaction then
            local r, g, b = unpack(oUF.colors.reaction[reaction])
            return string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
        end
    end
end

oUF.Tags.Methods["Group"] = function(unit)
    if not IsInRaid() then return end
    local name = GetUnitName(unit, true)
    for i = 1, GetNumGroupMembers() do
        local raidName, _, group = GetRaidRosterInfo(i)
        if raidName == name then
            return tostring(group)
        end
    end
end



oUF.Tags.Methods["Power:CurPP"] = function(unit)
    local unitPower = UnitPower(unit)
    if unitPower <= 0 then return end
    return UUF:FormatLargeNumber(unitPower)
end

oUF.Tags.Methods["Power:PerPP"] = function(unit)
    local unitPower = UnitPower(unit)
    local unitMaxPower = UnitPowerMax(unit)
    local unitPowerPercent = (unitMaxPower > 0) and (unitPower / unitMaxPower * 100) or 0
    if unitPower <= 0 then return end
    return string.format("%.1f%%", unitPowerPercent)
end

oUF.Tags.Methods["Power:PerPP:Clean"] = function(unit)
    local unitPower = UnitPower(unit)
    local unitMaxPower = UnitPowerMax(unit)
    local unitPowerPercent = (unitMaxPower > 0) and (unitPower / unitMaxPower * 100) or 0
    if unitPower <= 0 then return end
    return string.format("%.1f", unitPowerPercent)
end

oUF.Tags.Events["Name:NamewithTargetTarget"] = "UNIT_NAME_UPDATE UNIT_TARGET"
oUF.Tags.Events["Name:NamewithTargetTarget:Coloured"] = "UNIT_NAME_UPDATE UNIT_TARGET"
oUF.Tags.Events["Name:TargetTarget"] = "UNIT_TARGET"
oUF.Tags.Events["Name:TargetTarget:Coloured"] = "UNIT_TARGET"
oUF.Tags.Events["Name:LastNameOnly"] = "UNIT_NAME_UPDATE"
oUF.Tags.Events["Name:LastNameOnly:Coloured"] = "UNIT_NAME_UPDATE"
oUF.Tags.Events["Name:TargetTarget:LastNameOnly"] = "UNIT_TARGET"
oUF.Tags.Events["Name:TargetTarget:LastNameOnly:Coloured"] = "UNIT_TARGET"
oUF.Tags.Events["Name:NamewithTargetTarget:LastNameOnly"] = "UNIT_NAME_UPDATE UNIT_TARGET"
oUF.Tags.Events["Name:NamewithTargetTarget:LastNameOnly:Coloured"] = "UNIT_NAME_UPDATE UNIT_TARGET"
oUF.Tags.Events["Name:VeryShort"] = "UNIT_NAME_UPDATE"
oUF.Tags.Events["Name:Short"] = "UNIT_NAME_UPDATE"
oUF.Tags.Events["Name:Medium"] = "UNIT_NAME_UPDATE"
oUF.Tags.Events["Name:Abbreviated"] = "UNIT_NAME_UPDATE"
oUF.Tags.Events["Name:Abbreviated:Coloured"] = "UNIT_NAME_UPDATE"
oUF.Tags.Events["ClassColour"] = "UNIT_CLASSIFICATION_CHANGED UNIT_NAME_UPDATE"
oUF.Tags.Events["ReactionColour"] = "UNIT_NAME_UPDATE"
oUF.Tags.Events["Coloured"] = "UNIT_CLASSIFICATION_CHANGED UNIT_NAME_UPDATE"

oUF.Tags.Events["Health:CurHPwithPerHP"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION UNIT_ABSORB_AMOUNT_CHANGED"
oUF.Tags.Events["Health:CurHPwithPerHP:Clean"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION UNIT_ABSORB_AMOUNT_CHANGED"
oUF.Tags.Events["Health:PerHPwithAbsorbs"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_ABSORB_AMOUNT_CHANGED"
oUF.Tags.Events["Health:PerHPwithAbsorbs:Clean"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_ABSORB_AMOUNT_CHANGED"
oUF.Tags.Events["Health:CurHP"] = "UNIT_HEALTH UNIT_CONNECTION"
oUF.Tags.Events["Health:CurAbsorbs"] = "UNIT_ABSORB_AMOUNT_CHANGED"
oUF.Tags.Events["Health:CurHPwithAbsorbs"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_ABSORB_AMOUNT_CHANGED"
oUF.Tags.Events["Health:PerHP"] = "UNIT_HEALTH UNIT_MAXHEALTH"
oUF.Tags.Events["Health:PerHP:Clean"] = "UNIT_HEALTH UNIT_MAXHEALTH"

oUF.Tags.Events["Power:CurPP"] = "UNIT_POWER_UPDATE UNIT_MAXPOWER"
oUF.Tags.Events["Power:PerPP"] = "UNIT_POWER_UPDATE UNIT_MAXPOWER"
oUF.Tags.Events["Power:PerPP:Clean"] = "UNIT_POWER_UPDATE UNIT_MAXPOWER"

oUF.Tags.Events["Group"] = "GROUP_ROSTER_UPDATE"

local HealthTagsDescription = {
    ["Current Health with Percent Health"] = {Tag = "[Health:CurHPwithPerHP]", Desc = "Displays Current Health with Percent Health (Absorbs Included)"},
    ["Percent Health with Absorbs"] = {Tag = "[Health:PerHPwithAbsorbs]", Desc = "Displays Percent Health with Absorbs"},
    ["Current Health"] = {Tag = "[Health:CurHP]", Desc = "Displays Current Health"},
    ["Current Absorbs"] = {Tag = "[Health:CurAbsorbs]", Desc = "Displays Current Absorbs"},
    ["Current Health with Absorbs"] = {Tag = "[Health:CurHPwithAbsorbs]", Desc = "Displays Current Health with Absorbs"},
    ["Percent Health"] = {Tag = "[Health:PerHP]", Desc = "Displays Percent Health"},
}

local AvailableHealthTags = {
    ["[Health:CurHPwithPerHP]"] = "Current Health with Percent Health (Absorbs Included)",
    ["[Health:CurHPwithPerHP:Clean]"] = "Current Health with Percent Health (Absorbs Included) - No `%`Sign",
    ["[Health:PerHPwithAbsorbs]"] = "Percent Health with Absorbs",
    ["[Health:PerHPwithAbsorbs:Clean]"] = "Percent Health with Absorbs - No `%`Sign",
    ["[Health:CurHP]"] = "Current Health",
    ["[Health:CurAbsorbs]"] = "Current Absorbs",
    ["[Health:CurHPwithAbsorbs]"] = "Current Health with Absorbs",
    ["[Health:PerHP]"] = "Percent Health",
    ["[Health:PerHP:Clean]"] = "Percent Health - No `%`Sign"
}

function UUF:FetchHealthTagDescriptions()
    return HealthTagsDescription
end

function UUF:FetchAvailableHealthTags()
    return AvailableHealthTags
end

local NameTagsDescription = {
    ["Name with Target's Target"] = {Tag = "[Name:NamewithTargetTarget]", Desc = "Displays Name with Target's Target"},
    ["Target's Target"] = {Tag = "[Name:TargetTarget]", Desc = "Displays Target's Target"},
    ["Name with Target's Target (Coloured)"] = {Tag = "[Name:NamewithTargetTarget:Coloured]", Desc = "Displays Name with Target's Target (Reaction / Class Coloured)"},
    ["Target's Target (Coloured)"] = {Tag = "[Name:TargetTarget:Coloured]", Desc = "Displays Target's Target (Reaction / Class Coloured)"},
    ["Last Name Only"] = {Tag = "[Name:LastNameOnly]", Desc = "Displays Last Name Only"},
    ["Last Name Only (Coloured)"] = {Tag = "[Name:LastNameOnly:Coloured]", Desc = "Displays Last Name Only (Reaction / Class Coloured)"},
    ["Target's Target Last Name Only"] = {Tag = "[Name:TargetTarget:LastNameOnly]", Desc = "Displays Target's Target Last Name Only"},
    ["Target's Target Last Name Only (Coloured)"] = {Tag = "[Name:TargetTarget:LastNameOnly:Coloured]", Desc = "Displays Target's Target Last Name Only (Reaction / Class Coloured)"},
    ["Name with Target's Target Last Name Only"] = {Tag = "[Name:NamewithTargetTarget:LastNameOnly]", Desc = "Displays Name with Target's Target Last Name Only"},
    ["Name with Target's Target Last Name Only (Coloured)"] = {Tag = "[Name:NamewithTargetTarget:LastNameOnly:Coloured]", Desc = "Displays Name with Target's Target Last Name Only (Reaction / Class Coloured)"},
    ["Very Short Name"] = {Tag = "[Name:VeryShort]", Desc = "Displays Very Short Name (5 Characters)"},
    ["Short Name"] = {Tag = "[Name:Short]", Desc = "Displays Short Name (8 Characters)"},
    ["Medium Name"] = {Tag = "[Name:Medium]", Desc = "Displays Medium Name (10 Characters)"},
    ["Name"] = {Tag = "[name]", Desc = "Displays Name"},
    ["Abbreviated Name"] = {Tag = "[Name:Abbreviated]", Desc = "Displays Abbreviated Name"},
    ["Abbreviated Name (Coloured)"] = {Tag = "[Name:Abbreviated:Coloured]", Desc = "Displays Abbreviated Name (Reaction / Class Coloured)"},
}

local AvailableNameTags = {
    ["[Name:NamewithTargetTarget]"] = "Name with Target's Target",
    ["[Name:TargetTarget]"] = "Target's Target",
    ["[Name:NamewithTargetTarget:Coloured]"] = "Name with Target's Target (Coloured)",
    ["[Name:TargetTarget:Coloured]"] = "Target's Target (Coloured)",
    ["[Name:LastNameOnly]"] = "Last Name Only",
    ["[Name:LastNameOnly:Coloured]"] = "Last Name Only (Coloured)",
    ["[Name:TargetTarget:LastNameOnly]"] = "Target's Target Last Name Only",
    ["[Name:TargetTarget:LastNameOnly:Coloured]"] = "Target's Target Last Name Only (Coloured)",
    ["[Name:NamewithTargetTarget:LastNameOnly]"] = "Name with Target's Target Last Name Only",
    ["[Name:NamewithTargetTarget:LastNameOnly:Coloured]"] = "Name with Target's Target Last Name Only (Coloured)",
    ["[name]"] = "Full Name",
    ["[Name:VeryShort]"] = "Very Short Name (5 Characters)",
    ["[Name:Short]"] = "Short Name (8 Characters)",
    ["[Name:Medium]"] = "Medium Name (10 Characters)",
    ["[Name:Abbreviated]"] = "Abbreviated Name",
    ["[Name:Abbreviated:Coloured]"] = "Abbreviated Name (Coloured)",
    ["[Name:TargetTarget:LastNameOnly:Clean]"] = "Target's Target Last Name Only - No `»` Sign",
    ["[Name:TargetTarget:LastNameOnly:Coloured:Clean]"] = "Target's Target Last Name Only (Coloured) - No `»` Sign",

}

if NSM then
    AvailableNameTags["[NSNickName]"] = "Nickname"
    AvailableNameTags["[NSNickName:veryshort]"] = "Nickname Very Short (5 Characters)"
    AvailableNameTags["[NSNickName:short]"] = "Nickname Short (8 Characters)"
    AvailableNameTags["[NSNickName:medium]"] = "Nickname Medium (10 Characters)"
    for i = 1, 12 do
        AvailableNameTags["[NSNickName:" .. i .. "]"] = "Nickname Length (" .. i .. " Characters)"
    end
end

function UUF:FetchNameTagDescriptions()
    return NameTagsDescription
end

function UUF:FetchAvailableNameTags()
    return AvailableNameTags
end

local PowerTagsDescription = {
    ["Current Power"] = {Tag = "[Power:CurPP]", Desc = "Displays Current Power"},
    ["Percent Power"] = {Tag = "[Power:PerPP]", Desc = "Displays Percent Power"},
    ["Colour Power"] = {Tag = "[powercolor]", Desc = "Colour Power. Put infront of Power Tag to colour it."},
}

local AvailablePowerTags = {
    ["[Power:CurPP]"] = "Current Power",
    ["[Power:PerPP]"] = "Percent Power",
    ["[powercolor]"] = "Colour Power - Prefix Tag to Colour by Power"
}

function UUF:FetchPowerTagDescriptions()
    return PowerTagsDescription
end

function UUF:FetchAvailablePowerTags()
    return AvailablePowerTags
end

local MiscTagsDescription = {
    ["Classification"] = {Tag = "[classification]", Desc = "Returns the current classification (Elite, Rare, Rare Elite) of the unit."},
    ["Short Classification"] = {Tag = "[shortclassification]", Desc = "Returns the current classification (Elite, Rare, Rare Elite) of the unit, shortened."},
    ["Group"] = {Tag = "[Group]", Desc = "Returns the current group number of the unit."},
    ["Level"] = {Tag = "[level]", Desc = "Returns the current level of the unit."},
    ["Status"] = {Tag = "[status]", Desc = "Return the current status (Dead, Offline) of the unit."}
}

local AvailableMiscTags = {
    ["[classification]"] = "Classification",
    ["[shortclassification]"] = "Short Classification",
    ["[Group]"] = "Group",
    ["[level]"] = "Level",
    ["[status]"] = "Status",
    ["[ClassColour]"] = "Prefix Tag to Colour by Class",
    ["[ReactionColour]"] = "Prefix Tag to Colour by Reaction",
    ["[Coloured]"] = "Prefix Tag to Colour by Class / Reaction"
}

function UUF:FetchMiscTagDescriptions()
    return MiscTagsDescription
end

function UUF:FetchAvailableMiscTags()
    return AvailableMiscTags
end

local NSMediaTags = {
    ["NSNickName"] = {Tag = "[NSNickName]", Desc = "Returns the nickname of the unit."},
    ["NSNickName:veryshort"] = {Tag = "[NSNickName:veryshort]", Desc = "Returns the nickname of the unit, very short (5 Characters)."},
    ["NSNickName:short"] = {Tag = "[NSNickName:short]", Desc = "Returns the nickname of the unit, short (8 Characters)."},
    ["NSNickName:medium"] = {Tag = "[NSNickName:medium]", Desc = "Returns the nickname of the unit, medium (10 Characters)."},
    ["NSNickName:X"] = {Tag = "[NSNickName:X]", Desc = "Format Name Length where X is the limiting number (1 - 12)."},
}

function UUF:FetchNSMediaTagDescriptions()
    return NSMediaTags
end
