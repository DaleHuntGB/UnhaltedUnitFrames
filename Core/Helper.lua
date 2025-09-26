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
    local dp = UUF.DP or 1
    if value < 1e3 then
        return tostring(value)
    elseif value < 1e6 then
        return string.format("%." .. dp .. "fk", value / 1e3)
    elseif value < 1e9 then
        return string.format("%." .. dp .. "fm", value / 1e6)
    else
        return string.format("%." .. dp .. "fb", value / 1e9)
    end
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

function UUF:ResetAnchors()
    if not UUFDB.profileKeys then return end

    local currentCharacter = UnitName("player") .. " - " .. GetRealmName()
    local profileName = UUFDB.profileKeys[currentCharacter]
    if not profileName then print("No profile assigned for current character.") return end

    local profile = UUFDB.profiles[profileName]
    if not profile then print("Profile not found: " .. profileName) return end

    for unit, config in pairs(profile) do
        if type(config) == "table" and config.Frame and config.Frame.AnchorParent then
            if UUF.Defaults.profile[unit] and UUF.Defaults.profile[unit].Frame then
                local defaultParent = UUF.Defaults.profile[unit].Frame.AnchorParent
                if config.Frame.AnchorParent ~= defaultParent then
                    config.Frame.AnchorParent = defaultParent
                end
            end
        end
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
        elseif msg:lower() == "reset" then
            if UUF.DB.global.UIScaleEnabled then
                UUF.DB.global.UIScale = 0.76
                UIParent:SetScale(0.76)
            end
            UUF:ResetDefaultSettings()
        elseif msg == "resetanchors" then
            UUF:ResetAnchors()
        elseif msg == "help" then
            print(C_AddOns.GetAddOnMetadata("UnhaltedUF", "Title") .. " Slash Commands.")
            print("|cFF8080FF/uuf|r: Opens the GUI")
            print("|cFF8080FF/uuf reset|r: Resets To Default")
            print("|cFF8080FF/uuf resetanchors|r: Resets All Unit Anchors")
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

function UUF:DisableBlizzard(unit)
    local lowerUnit = unit:lower()
    if oUF and oUF.DisableBlizzard then
        oUF:DisableBlizzard(lowerUnit)
    end
end