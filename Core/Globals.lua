local _, UUF = ...
UUFG = UUFG or {}
UUF.AURA_TEST_MODE = false
UUF.CASTBAR_TEST_MODE = false

UUF.LSM = LibStub("LibSharedMedia-3.0")
UUF.AG = LibStub("AceGUI-3.0")
UUF.BACKDROP = { bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1, insets = {left = 0, right = 0, top = 0, bottom = 0} }
UUF.INFOBUTTON = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\InfoButton.png:16:16|t "
UUF.ADDON_NAME = C_AddOns.GetAddOnMetadata("UnhaltedUnitFrames", "Title")
UUF.ADDON_VERSION = C_AddOns.GetAddOnMetadata("UnhaltedUnitFrames", "Version")
UUF.ADDON_AUTHOR = C_AddOns.GetAddOnMetadata("UnhaltedUnitFrames", "Author")
UUF.ADDON_LOGO = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Logo:11:12|t"
UUF.PRETTY_ADDON_NAME = UUF.ADDON_LOGO .. " " .. UUF.ADDON_NAME

UUF.LSM:Register("statusbar", "Better Blizzard", "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\BetterBlizzard.blp")
UUF.LSM:Register("statusbar", "Dragonflight", "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Dragonflight.tga")
UUF.LSM:Register("statusbar", "Skyline", "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Skyline.tga")
UUF.LSM:Register("statusbar", "Striped", "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Striped.png")

UUF.LSM:Register("background", "Dragonflight", "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Backgrounds\\Dragonflight_BG.tga")

UUF.LSM:Register("font", "Expressway", "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Fonts\\Expressway.ttf")
UUF.LSM:Register("font", "Avante", "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Fonts\\Avante.ttf")
UUF.LSM:Register("font", "Avantgarde (Book)", "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Fonts\\AvantGarde\\Book.ttf")
UUF.LSM:Register("font", "Avantgarde (Book Oblique)", "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Fonts\\AvantGarde\\BookOblique.ttf")
UUF.LSM:Register("font", "Avantgarde (Demi)", "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Fonts\\AvantGarde\\Demi.ttf")
UUF.LSM:Register("font", "Avantgarde (Regular)", "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Fonts\\AvantGarde\\Regular.ttf")

UUF.StatusTextures = {
    Combat = {
        ["COMBAT0"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat0.tga",
        ["COMBAT1"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat1.tga",
        ["COMBAT2"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat2.tga",
        ["COMBAT3"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat3.tga",
        ["COMBAT4"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat4.tga",
        ["COMBAT5"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat5.tga",
        ["COMBAT6"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat6.tga",
        ["COMBAT7"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat7.tga",
    },
    Resting = {
        ["RESTING0"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting0.tga",
        ["RESTING1"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting1.tga",
        ["RESTING2"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting2.tga",
        ["RESTING3"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting3.tga",
        ["RESTING4"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting4.tga",
        ["RESTING5"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting5.tga",
        ["RESTING6"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting6.tga",
        ["RESTING7"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting7.tga",
    },
}

function UUF:PrettyPrint(MSG) print(UUF.ADDON_NAME .. ":|r " .. MSG) end

function UUF:FetchFrameName(unit)
    local UnitToFrame = {
        ["player"] = "UUF_Player",
        ["target"] = "UUF_Target",
        ["targettarget"] = "UUF_TargetTarget",
        ["focus"] = "UUF_Focus",
        ["pet"] = "UUF_Pet",
        ["boss"] = "UUF_Boss",
    }
    if not unit then return end
    if unit:match("^boss(%d+)$") then local unitID = unit:match("^boss(%d+)$") return "UUF_Boss" .. unitID end
    return UnitToFrame[unit]
end

function UUF:ResolveLSM()
    local LSM = UUF.LSM
    local General = UUF.db.profile.General
    UUF.Media = UUF.Media or {}
    UUF.Media.Font = LSM:Fetch("font", General.Fonts.Font) or STANDARD_TEXT_FONT
    UUF.Media.Foreground = LSM:Fetch("statusbar", General.Textures.Foreground) or "Interface\\RaidFrame\\Raid-Bar-Hp-Fill"
    UUF.Media.Background = LSM:Fetch("statusbar", General.Textures.Background) or "Interface\\Buttons\\WHITE8X8"
end

function UUF:Capitalize(STR)
    return "|cFFFFCC00" .. (STR:gsub("^%l", string.upper)) .. "|r"
end

function UUF:GetPixelPerfectScale()
    local _, screenHeight = GetPhysicalScreenSize()
    local pixelSize = 768 / screenHeight
    return pixelSize
end

local function SetupSlashCommands()
    SLASH_UUF1 = "/uuf"
    SLASH_UUF2 = "/unhaltedunitframes"
    SLASH_UUF3 = "/uf"
    SlashCmdList["UUF"] = function() UUF:CreateGUI() end
    UUF:PrettyPrint("'|cFF8080FF/uuf|r' for in-game configuration.")
end

function UUF:SetUIScale()
    local GeneralDB = UUF.db.profile.General
    if GeneralDB.UIScale.Enabled then
        UIParent:SetScale(GeneralDB.UIScale.Scale or 0.5333333333333)
    else
        UIParent:SetScale(0.64)
    end
end

function UUF:LoadCustomColours()
    local General = UUF.db.profile.General
    local oUF = UUF.oUF

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

    for powerType, color in pairs(General.Colours.Power) do
        local powerTypeString = PowerTypesToString[powerType]
        if powerTypeString then oUF.colors.power[powerTypeString] = oUF:CreateColor(color[1], color[2], color[3]) end
    end

    for reaction, color in pairs(General.Colours.Reaction) do
        oUF.colors.reaction[reaction] = oUF:CreateColor(color[1], color[2], color[3])
    end

    -- oUF.colors.health = { General.ForegroundColour[1], General.ForegroundColour[2], General.ForegroundColour[3] }
    -- oUF.colors.tapped = { General.CustomColours.Status[2][1], General.CustomColours.Status[2][2], General.CustomColours.Status[2][3] }
    -- oUF.colors.disconnected = { General.CustomColours.Status[3][1], General.CustomColours.Status[3][2], General.CustomColours.Status[3][3] }

    for _, obj in next, oUF.objects do
        if obj.UpdateTags then
            obj:UpdateTags()
        end
    end
end

function UUF:Init()
    SetupSlashCommands()
    UUF:SetUIScale()
    UUF:ResolveLSM()
    UUF:LoadCustomColours()
end

function UUF:CopyTabe(originalTable, destinationTable)
    for key, value in pairs(originalTable) do
        if type(value) == "table" then
            destinationTable[key] = destinationTable[key] or {}
            UUF:CopyTabe(value, destinationTable[key])
        else
            destinationTable[key] = value
        end
    end
end

function UUF:SetJustification(anchorFrom)
    if anchorFrom == "TOPLEFT" or anchorFrom == "LEFT" or anchorFrom == "BOTTOMLEFT" then
        return "LEFT"
    elseif anchorFrom == "TOPRIGHT" or anchorFrom == "RIGHT" or anchorFrom == "BOTTOMRIGHT" then
        return "RIGHT"
    else
        return "CENTER"
    end
end

function UUF:GetClassColour(unitFrame)
    local _, class = UnitClass(unitFrame.unit)
    local classColour = RAID_CLASS_COLORS[class]
    if classColour then
        return {classColour.r, classColour.g, classColour.b, 1}
    end
end