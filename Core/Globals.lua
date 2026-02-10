local _, UUF = ...
local oUF = UUF.oUF
UUFG = UUFG or {}
UUF.AURA_TEST_MODE = false
UUF.CASTBAR_TEST_MODE = false
UUF.BOSS_TEST_MODE = false
UUF.BOSS_FRAMES = {}
UUF.MAX_BOSS_FRAMES = 5

UUF.LSM = LibStub("LibSharedMedia-3.0")
UUF.LDS = LibStub("LibDualSpec-1.0")
UUF.AG = LibStub("AceGUI-3.0")
UUF.LD = LibStub("LibDispel-1.0")
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
UUF.LSM:Register("statusbar", "Stripes", "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Stripes.png")
UUF.LSM:Register("statusbar", "Thin Stripes", "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ThinStripes.png")

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
        ["COMBAT8"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat8.png",
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
        ["RESTING8"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting8.png",
    },
}

function UUF:PrettyPrint(MSG) print(UUF.ADDON_NAME .. ":|r " .. MSG) end

function UUF:FetchFrameName(unit)
    local UnitToFrame = {
        ["player"] = "UUF_Player",
        ["target"] = "UUF_Target",
        ["targettarget"] = "UUF_TargetTarget",
        ["focus"] = "UUF_Focus",
        ["focustarget"] = "UUF_FocusTarget",
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

    -- RL command
    SLASH_UUFRELOAD1 = "/rl"
    SlashCmdList["UUFRELOAD"] = function() C_UI.Reload() end
end

function UUF:SetUIScale()
    local GeneralDB = UUF.db.profile.General
    if GeneralDB.UIScale.Enabled then
        UIParent:SetScale(GeneralDB.UIScale.Scale or 0.5333333333333)
    else
        return
    end
end

function UUF:LoadCustomColours()
    local General = UUF.db.profile.General

    -- Map power type enums to their string names
    local PowerTypesToString = {
        [Enum.PowerType.Mana or 0] = "MANA",
        [Enum.PowerType.Rage or 1] = "RAGE",
        [Enum.PowerType.Focus or 2] = "FOCUS",
        [Enum.PowerType.Energy or 3] = "ENERGY",
        [Enum.PowerType.ComboPoints or 4] = "COMBO_POINTS",
        [Enum.PowerType.Runes or 5] = "RUNES",
        [Enum.PowerType.RunicPower or 6] = "RUNIC_POWER",
        [Enum.PowerType.SoulShards or 7] = "SOUL_SHARDS",
        [Enum.PowerType.LunarPower or 8] = "LUNAR_POWER",
        [Enum.PowerType.HolyPower or 9] = "HOLY_POWER",
        [Enum.PowerType.Alternate or 10] = "ALTERNATE",
        [Enum.PowerType.Maelstrom or 11] = "MAELSTROM",
        [Enum.PowerType.Chi or 12] = "CHI",
        [Enum.PowerType.Insanity or 13] = "INSANITY",
        [Enum.PowerType.ArcaneCharges or 16] = "ARCANE_CHARGES",
        [Enum.PowerType.Fury or 17] = "FURY",
        [Enum.PowerType.Pain or 18] = "PAIN",
        [Enum.PowerType.Essence or 19] = "ESSENCE",
    }

    for powerType, color in pairs(General.Colours.Power) do
        local powerTypeString = PowerTypesToString[powerType]
        if powerTypeString then
            oUF.colors.power[powerTypeString] = oUF:CreateColor(color[1], color[2], color[3])
            oUF.colors.power[powerType] = oUF.colors.power[powerTypeString]
        end
    end

    for powerType, color in pairs(General.Colours.SecondaryPower) do
        local powerTypeString = PowerTypesToString[powerType]
        if powerTypeString then
            oUF.colors.power[powerTypeString] = oUF:CreateColor(color[1], color[2], color[3])
            oUF.colors.power[powerType] = oUF.colors.power[powerTypeString]
        end
    end

    for reaction, color in pairs(General.Colours.Reaction) do
        oUF.colors.reaction[reaction] = oUF:CreateColor(color[1], color[2], color[3])
    end

    if General.Colours.Dispel then
        local dispelMap = {
            Magic = oUF.Enum.DispelType.Magic,
            Curse = oUF.Enum.DispelType.Curse,
            Disease = oUF.Enum.DispelType.Disease,
            Poison = oUF.Enum.DispelType.Poison,
            Bleed = oUF.Enum.DispelType.Bleed,
        }
        for dispelType, index in pairs(dispelMap) do
            local color = General.Colours.Dispel[dispelType]
            if color then
                oUF.colors.dispel[index] = oUF:CreateColor(color[1], color[2], color[3])
            end
        end
        UUF.dispelColorGeneration = (UUF.dispelColorGeneration or 0) + 1
    end

    for _, obj in next, oUF.objects do
        if obj.UpdateTags then
            obj:UpdateTags()
        end
    end
end

local function AddAnchorsToBCDM()
    if not C_AddOns.IsAddOnLoaded("BetterCooldownManager") then return end
    local UUF_Anchors = {
        ["UUF_Player"] = "|cFF8080FFUnhalted|rUnitFrames: Player Frame",
        ["UUF_Target"] = "|cFF8080FFUnhalted|rUnitFrames: Target Frame",
        ["UUF_Pet"] = "|cFF8080FFUnhalted|rUnitFrames: Pet Frame",
    }
    BCDMG:AddAnchors("UnhaltedUnitFrames", {"Utility", "Custom", "AdditionalCustom", "Item", "ItemSpell", "Trinket"}, UUF_Anchors)
end

function UUF:Init()
    SetupSlashCommands()
    UUF:SetUIScale()
    UUF:ResolveLSM()
    UUF:LoadCustomColours()
    UUF:SetTagUpdateInterval()
    AddAnchorsToBCDM()
end

function UUF:CopyTable(originalTable, destinationTable)
    for key, value in pairs(originalTable) do
        if type(value) == "table" then
            destinationTable[key] = destinationTable[key] or {}
            UUF:CopyTable(value, destinationTable[key])
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

function UUF:GetUnitColour(unit)
    if UnitIsPlayer(unit) or UnitInPartyIsAI(unit) then
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

function UUF:GetClassColour(unitFrame)
    local _, class = UnitClass(unitFrame.unit)
    local classColour = RAID_CLASS_COLORS[class]
    if classColour then
        return {classColour.r, classColour.g, classColour.b, 1}
    end
end

function UUF:GetReactionColour(reaction)
    local reactionColour = oUF.colors.reaction[reaction]
    if reactionColour then
        return {reactionColour.r, reactionColour.g, reactionColour.b, 1}
    end
end

function UUF:GetNormalizedUnit(unit)
    local normalizedUnit = unit:match("^boss%d+$") and "boss" or unit
    return normalizedUnit
end

function UUF:RequiresAlternativePowerBar()
    local SpecsNeedingAltPower = {
        PRIEST = { 258 },           -- Shadow
        MAGE   = { 62, 63, 64 },        -- Fire, Frost
        PALADIN = { 70 },           -- Ret
        SHAMAN  = { 262, 263 },     -- Ele, Enh
        EVOKER  = { 1467, 1473 },   -- Dev, Aug
        DRUID = { 102, 103, 104 },    -- Balance, Feral, Guardian
    }
    local class = select(2, UnitClass("player"))
    local specIndex = GetSpecialization()
    if not specIndex then return false end
    local specID = GetSpecializationInfo(specIndex)
    local classSpecs = SpecsNeedingAltPower[class]
    if not classSpecs then return false end
    for _, requiredSpec in ipairs(classSpecs) do if specID == requiredSpec then return true end end
    return false
end

UUF.LayoutConfig = {
    TOPLEFT     = { anchor="TOPLEFT",   offsetMultiplier=0   },
    TOP         = { anchor="TOP",       offsetMultiplier=0   },
    TOPRIGHT    = { anchor="TOPRIGHT",  offsetMultiplier=0   },
    BOTTOMLEFT  = { anchor="TOPLEFT",   offsetMultiplier=1   },
    BOTTOM      = { anchor="TOP",       offsetMultiplier=1   },
    BOTTOMRIGHT = { anchor="TOPRIGHT",  offsetMultiplier=1   },
    CENTER      = { anchor="CENTER",    offsetMultiplier=0.5, isCenter=true },
    LEFT        = { anchor="LEFT",      offsetMultiplier=0.5, isCenter=true },
    RIGHT       = { anchor="RIGHT",     offsetMultiplier=0.5, isCenter=true },
}

function UUF:SetTagUpdateInterval()
    oUF.Tags:SetEventUpdateTimer(UUF.TAG_UPDATE_INTERVAL)
end

function UUF:OpenURL(title, urlText)
    StaticPopupDialogs["UUF_URL_POPUP"] = {
        text = title or "",
        button1 = CLOSE,
        hasEditBox = true,
        editBoxWidth = 300,
        OnShow = function(self)
            self.EditBox:SetText(urlText or "")
            self.EditBox:SetFocus()
            self.EditBox:HighlightText()
        end,
        OnAccept = function(self) end,
        EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    local urlDialog = StaticPopup_Show("UUF_URL_POPUP")
    if urlDialog then
        urlDialog:SetFrameStrata("TOOLTIP")
    end
    return urlDialog
end

function UUF:CreatePrompt(title, text, onAccept, onCancel, acceptText, cancelText)
    StaticPopupDialogs["UUF_PROMPT_DIALOG"] = {
        text = text or "",
        button1 = acceptText or ACCEPT,
        button2 = cancelText or CANCEL,
        OnAccept = function(self, data)
            if data and data.onAccept then
                data.onAccept()
            end
        end,
        OnCancel = function(self, data)
            if data and data.onCancel then
                data.onCancel()
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
        showAlert = true,
    }
    local promptDialog = StaticPopup_Show("UUF_PROMPT_DIALOG", title, text)
    if promptDialog then
        promptDialog.data = { onAccept = onAccept, onCancel = onCancel }
        promptDialog:SetFrameStrata("TOOLTIP")
    end
    return promptDialog
end

function UUFG:UpdateAllTags()
    for _, obj in next, oUF.objects do
        if obj.UpdateTags then
            obj:UpdateTags()
        end
    end
end

-- Thanks Details / Plater for this.
function UUF:CleanTruncateUTF8String(text)
    local DetailsFramework = _G.DF
    if DetailsFramework and DetailsFramework.CleanTruncateUTF8String then
        return DetailsFramework:CleanTruncateUTF8String(text)
    end
    return text
end

function UUF:GetSecondaryPowerType()
    local class = select(2, UnitClass("player"))
    local spec = C_SpecializationInfo.GetSpecialization()

    if class == "ROGUE" then
        return Enum.PowerType.ComboPoints
    elseif class == "DRUID" then
        local form = GetShapeshiftFormID()
        if form == 1 then return Enum.PowerType.ComboPoints end
    elseif class == "PALADIN" then
        return Enum.PowerType.HolyPower
    elseif class == "WARLOCK" then
        return Enum.PowerType.SoulShards
    elseif class == "MAGE" then
        if spec == 1 then return Enum.PowerType.ArcaneCharges end
    elseif class == "MONK" then
        if spec == 3 then return Enum.PowerType.Chi end
    elseif class == "EVOKER" then
        return Enum.PowerType.Essence
    end

    return nil
end

function UUF:UpdateHealthBarLayout(unitFrame, unit)
    local PowerBarDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].PowerBar
    local SecondaryPowerBarDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].SecondaryPowerBar

    local topOffset = -1
    local bottomOffset = 1

    local hasSecondaryPower =
        SecondaryPowerBarDB
        and SecondaryPowerBarDB.Enabled
        and (unitFrame.Runes or unitFrame.ClassPower)

    if hasSecondaryPower then
        topOffset = topOffset - SecondaryPowerBarDB.Height - 1
    end

    if PowerBarDB and PowerBarDB.Enabled then
        bottomOffset = bottomOffset + PowerBarDB.Height + (PowerBarDB.ShowBorder and 1 or 0)
    end

    unitFrame.HealthBackground:ClearAllPoints()
    unitFrame.HealthBackground:SetPoint("TOPLEFT", unitFrame.Container, "TOPLEFT", 1, topOffset)
    unitFrame.HealthBackground:SetPoint("BOTTOMRIGHT", unitFrame.Container, "BOTTOMRIGHT", -1, bottomOffset)

    unitFrame.Health:ClearAllPoints()
    unitFrame.Health:SetPoint("TOPLEFT", unitFrame.Container, "TOPLEFT", 1, topOffset)
    unitFrame.Health:SetPoint("BOTTOMRIGHT", unitFrame.Container, "BOTTOMRIGHT", -1, bottomOffset)
end
