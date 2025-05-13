local _, UUF = ...
local oUF = UUF.oUF
UUF.TargetHighlightEvtFrames = {}

UUF.Frames = {
    ["player"] = "Player",
    ["target"] = "Target",
    ["focus"] = "Focus",
    ["focustarget"] = "FocusTarget",
    ["pet"] = "Pet",
    ["targettarget"] = "TargetTarget",
}

UUF.nameBlacklist = {
    ["the"] = true,
    ["of"] = true,
    ["Tentacle"] = true,
    ["Apprentice"] = true,
    ["Denizen"] = true,
    ["Emissary"] = true,
    ["Howlis"] = true,
    ["Terror"] = true,
    ["Totem"] = true,
    ["Waycrest"] = true,
    ["Aspect"] = true
}

function UUFG:UpdateAllTags()
    for FrameName, Frame in pairs(_G) do
        if FrameName:match("^UUF_") and Frame.UpdateTags then
            Frame:UpdateTags()
        end
    end
end

function UUF:FormatLargeNumber(value)
    if value < 999 then
        return value
    elseif value < 999999 then
        return string.format("%.1fk", value / 1000)
    elseif value < 99999999 then
        return string.format("%.2fm", value / 1000000)
    elseif value < 999999999 then
        return string.format("%.1fm", value / 1000000)
    elseif value < 99999999999 then
        return string.format("%.2fb", value / 1000000000)
    end
    return string.format("%db", value / 1000000000)
end

function UUF:WrapTextInColor(unitName, unit)
    if not unitName then return "" end
    if not unit then return unitName end
    local unitColor
    if UnitIsPlayer(unit) then
        local unitClass = select(2, UnitClass(unit))
        unitColor = RAID_CLASS_COLORS[unitClass]
    else
        local reaction = UnitReaction(unit, "player")
        if reaction then
            local r, g, b = unpack(oUF.colors.reaction[reaction])
            unitColor = { r = r, g = g, b = b }
        end
    end
    if unitColor then
        return string.format("|cff%02x%02x%02x%s|r", unitColor.r * 255, unitColor.g * 255, unitColor.b * 255, unitName)
    end
    return unitName
end

function UUF:ShortenName(name, nameBlacklist)
    if not name or name == "" then return nil end
    local words = { strsplit(" ", name) }
    return nameBlacklist[words[2]] and words[1] or words[#words] or name
end

function UUF:AbbreviateName(unitName)
    local unitNameParts = {}
    for word in unitName:gmatch("%S+") do
        table.insert(unitNameParts, word)
    end

    local last = table.remove(unitNameParts)
    for i, word in ipairs(unitNameParts) do
        unitNameParts[i] = (string.utf8sub or string.sub)(word, 1, 1) .. "."
    end

    table.insert(unitNameParts, last)
    return table.concat(unitNameParts, " ")
end

function UUF:ResetDefaultSettings(resetAll)
    if resetAll == nil then resetAll = false end
    if resetAll then
        for k in pairs(UUFDB) do
            UUFDB[k] = nil
        end
        UUF.DB = LibStub("AceDB-3.0"):New("UUFDB", UUF.Defaults, "Global")
    else
        UUF.DB:ResetProfile()
    end
    UUF:CreateReloadPrompt()
end

function UUF:GetFontJustification(AnchorTo)
    if AnchorTo == "TOPLEFT" or AnchorTo == "BOTTOMLEFT" or AnchorTo == "LEFT" then return "LEFT" end
    if AnchorTo == "TOPRIGHT" or AnchorTo == "BOTTOMRIGHT" or AnchorTo == "RIGHT" then return "RIGHT" end
    if AnchorTo == "TOP" or AnchorTo == "BOTTOM" or AnchorTo == "CENTER" then return "CENTER" end
end

function UUF:SetupSlashCommands()
    SLASH_UUF1 = "/uuf"
    SLASH_UUF2 = "/unhalteduf"
    SLASH_UUF3 = "/unhaltedunitframes"
    SlashCmdList["UUF"] = function(msg)
        if msg == "" then
            UUF:CreateGUI()
        elseif msg == "reset" then
            UUF:ResetDefaultSettings()
        elseif msg == "help" then
            print(C_AddOns.GetAddOnMetadata("UnhaltedUF", "Title") .. " Slash Commands.")
            print("|cFF8080FF/uuf|r: Opens the GUI")
            print("|cFF8080FF/uuf reset|r: Resets To Default")
        end
    end
end

function UUF:LoadCustomColours()
    local General = UUF.DB.profile.General
    local PowerTypesToString = {
        [0] = "MANA",
        [1] = "RAGE",
        [2] = "FOCUS",
        [3] = "ENERGY",
        [6] = "RUNIC_POWER",
        [8] = "LUNAR_POWER",
        [11] = "MAELSTROM",
        [13] = "INSANITY",
        [17] = "FURY",
        [18] = "PAIN"
    }

    for powerType, color in pairs(General.CustomColours.Power) do
        local powerTypeString = PowerTypesToString[powerType]
        if powerTypeString then
            oUF.colors.power[powerTypeString] = color
        end
    end

    for reaction, color in pairs(General.CustomColours.Reaction) do
        oUF.colors.reaction[reaction] = color
    end

    oUF.colors.health = { General.ForegroundColour[1], General.ForegroundColour[2], General.ForegroundColour[3] }
    oUF.colors.tapped = { General.CustomColours.Status[2][1], General.CustomColours.Status[2][2], General.CustomColours.Status[2][3] }
    oUF.colors.disconnected = { General.CustomColours.Status[3][1], General.CustomColours.Status[3][2], General.CustomColours.Status[3][3] }
end

function UUF:RegisterTargetHighlightFrame(frame, unit)
    if not frame then return end
    table.insert(UUF.TargetHighlightEvtFrames, { frame = frame, unit = unit })
end

function UUF:UpdateTargetHighlight(frame, unit)
    if frame and frame.unitIsTargetIndicator then
        if UnitIsUnit("target", unit) then
            frame.unitIsTargetIndicator:Show()
        else
            frame.unitIsTargetIndicator:Hide()
        end
    end
end