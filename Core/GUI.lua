local _, UUF = ...
local UUFGUI = LibStub("AceGUI-3.0")
local GUI_WIDTH = 920
local GUI_HEIGHT = 720
local GUI_TITLE = C_AddOns.GetAddOnMetadata("UnhaltedUF", "Title")
local LSM = LibStub:GetLibrary("LibSharedMedia-3.0") or LibStub("LibSharedMedia-3.0")
local NSM = C_AddOns.IsAddOnLoaded("NorthernSkyMedia") or C_AddOns.IsAddOnLoaded("NorthernSkyRaidTools")
local LDS = LibStub("LibDualSpec-1.0", true)
if LSM then LSM:Register("border", "WHITE8X8", [[Interface\Buttons\WHITE8X8]]) end
local LSMBorders = {}
local GUIActive = false
local Supporters = {
    [1] = {Supporter = "", Comment = ""},
}

local function GetAuraInfo(auraID, nameOnly)
    local auraData = C_Spell.GetSpellInfo(auraID)
    if nameOnly == nil then nameOnly = true end
    if auraData then
        local auraName = auraData.name
        local auraIcon = auraData.iconID
        if nameOnly then
            return string.format("%s", auraName)
        else
            return string.format("|T%s:22:22|t %s (%d)", auraIcon, auraName, auraID)
        end
    end
end

local function TableToList(data)
    local dataContent = {}
    for auraID in pairs(data) do
        local auraName = GetAuraInfo(auraID, true)
        if auraName then
            -- Add auraName if we can find it.
            table.insert(dataContent, string.format("%s (%s)", auraID, auraName))
        else
            -- Add auraID even if auraName can't be found.
            table.insert(dataContent, string.format("%s", auraID))
            print("Added" .. auraID .. " without a corresponding name, please ensure the auraID is correct!")
        end
    end
    return table.concat(dataContent, "\n")
end

local UUFGUI_Container = nil;

local function GenerateSupportOptions()
    local SupportOptions = {
        [1] = {SupportOption = "Buy Me A Coffee via |cFFFF8040Ko-Fi|r", SupportURL = "ko-fi.com/unhalted"},
        [2] = {SupportOption = "Support Me On |cFFFF8040Patreon|r", SupportURL = "patreon.com/unhalted"},
    }

    local RandomIndex = math.random(1, #SupportOptions)
    local RandomSupportOption = SupportOptions[RandomIndex].SupportOption
    local RandomSupportURL = SupportOptions[RandomIndex].SupportURL

    return "|cFFFFFFFF" .. RandomSupportOption .. "|r" .. " - |cFF8080FF" .. RandomSupportURL .. "|r"
end

local PowerNames = {
    [0] = "Mana",
    [1] = "Rage",
    [2] = "Focus",
    [3] = "Energy",
    [4] = "Combo Points",
    [5] = "Runes",
    [6] = "Runic Power",
    [7] = "Soul Shards",
    [8] = "Lunar Power",
    [9] = "Holy Power",
    [11] = "Maelstrom",
    [13] = "Insanity",
    [17] = "Fury",
    [18] = "Pain"
}

local ReactionNames = {
    [1] = "Hated",
    [2] = "Hostile",
    [3] = "Unfriendly",
    [4] = "Neutral",
    [5] = "Friendly",
    [6] = "Honored",
    [7] = "Revered",
    [8] = "Exalted",
}

local StatusNames = {
    [1] = "Dead - Background Only",
    [2] = "Tapped - Foreground Only",
    [3] = "Disconnected - Foreground Only"
}

local function GenerateFontName(fontPath)
    for key, val in pairs(LSM:HashTable("font")) do
        if val == fontPath then
            return key
        end
    end
    return nil
end

function UUF:GenerateLSMBorders()
    local Borders = LSM:HashTable("border")
    for Path, Border in pairs(Borders) do
        LSMBorders[Border] = Path
    end
    return LSMBorders
end

local function GenerateTextureName(texturePath)
    for key, val in pairs(LSM:HashTable("statusbar")) do
        if val == texturePath then
            return key
        end
    end
    return nil
end

function UUF:UpdateFrames()
    UUF:LoadCustomColours()
    if self.PlayerFrame then
        UUF:UpdateUnitFrame(self.PlayerFrame)
    end
    if self.TargetFrame then
        UUF:UpdateUnitFrame(self.TargetFrame)
    end
    if self.FocusFrame then
        UUF:UpdateUnitFrame(self.FocusFrame)
    end
    if self.FocusTargetFrame then
        UUF:UpdateUnitFrame(self.FocusTargetFrame)
    end
    if self.PetFrame then
        UUF:UpdateUnitFrame(self.PetFrame)
    end
    if self.TargetTargetFrame then
        UUF:UpdateUnitFrame(self.TargetTargetFrame)
    end
    UUF:UpdateBossFrames()
end

function UUF:CreateReloadPrompt()
    StaticPopupDialogs["UUF_RELOAD_PROMPT"] = {
        text = "Reload UI to Apply Changes?",
        button1 = "Reload",
        button2 = "Later",
        OnAccept = function() ReloadUI() end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("UUF_RELOAD_PROMPT")
end

function UUF:ReloadOnProfileSwap()
    StaticPopupDialogs["UUF_PROFILE_SWAP"] = {
        text = "Unit Frame Elements have been changed, please reload for changes to take effect.",
        button1 = "Reload",
        button2 = "Later",
        OnAccept = function() ReloadUI() end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("UUF_PROFILE_SWAP")
end

function UUF:UpdateUIScale()
    if not UUF.DB.global.UIScaleEnabled then return end
    UIParent:SetScale(UUF.DB.global.UIScale)
end

local AnchorPoints = {
    ["TOPLEFT"] = "Top Left",
    ["TOP"] = "Top",
    ["TOPRIGHT"] = "Top Right",
    ["LEFT"] = "Left",
    ["CENTER"] = "Center",
    ["RIGHT"] = "Right",
    ["BOTTOMLEFT"] = "Bottom Left",
    ["BOTTOM"] = "Bottom",
    ["BOTTOMRIGHT"] = "Bottom Right",
}

local GrowthX = {
    ["LEFT"] = "Left",
    ["RIGHT"] = "Right",
}

local GrowthY = {
    ["UP"] = "Up",
    ["DOWN"] = "Down",
}

local CopyFrom = {
    ["Player"] = "Player",
    ["Target"] = "Target",
    ["Focus"] = "Focus",
    ["FocusTarget"] = "Focus Target",
    ["Pet"] = "Pet",
    ["TargetTarget"] = "Target Target",
}

local function GenerateCopyFromList(Unit)
    local CopyFromList = {}
    for k, v in pairs(CopyFrom) do
        if k ~= Unit then
            CopyFromList[k] = v
        end
    end
    return CopyFromList
end

local function CopyUnit(sourceUnit, targetUnit)
    if type(sourceUnit) ~= "table" or type(targetUnit) ~= "table" then return end
    for key, targetValue in pairs(targetUnit) do
        local sourceValue = sourceUnit[key]
        if type(targetValue) == "table" and type(sourceValue) == "table" then
            CopyUnit(sourceValue, targetValue)
        elseif sourceValue ~= nil then
            targetUnit[key] = sourceValue
        end
    end
    UUF:UpdateFrames()
    UUF:CreateReloadPrompt()
end

local function ResetColours()
    local General = UUF.DB.profile.General
    wipe(General.CustomColours)
    General.CustomColours = {
        Reaction = {
            [1] = {255/255, 64/255, 64/255},            -- Hated
            [2] = {255/255, 64/255, 64/255},            -- Hostile
            [3] = {255/255, 128/255, 64/255},           -- Unfriendly
            [4] = {255/255, 255/255, 64/255},           -- Neutral
            [5] = {64/255, 255/255, 64/255},            -- Friendly
            [6] = {64/255, 255/255, 64/255},            -- Honored
            [7] = {64/255, 255/255, 64/255},            -- Revered
            [8] = {64/255, 255/255, 64/255},            -- Exalted
        },
        Power = {
            [0] = {0, 0, 1},            -- Mana
            [1] = {1, 0, 0},            -- Rage
            [2] = {1, 0.5, 0.25},       -- Focus
            [3] = {1, 1, 0},            -- Energy
            [6] = {0, 0.82, 1},         -- Runic Power
            [8] = {0.3, 0.52, 0.9},     -- Lunar Power
            [11] = {0, 0.5, 1},         -- Maelstrom
            [13] = {0.4, 0, 0.8},       -- Insanity
            [17] = {0.79, 0.26, 0.99},  -- Fury
            [18] = {1, 0.61, 0}         -- Pain
        },
        Status = {
            [1] = {255/255, 64/255, 64/255},           -- Dead
            [2] = {153/255, 153/255, 153/255}, -- Tapped 
            [3] = {0.6, 0.6, 0.6}, -- Disconnected
        }
    }
end

function UUF:CreateGUI()
    if GUIActive then return end
    GUIActive = true
    -- UUF:GenerateLSMBorders()
    UUFGUI_Container = UUFGUI:Create("Frame")
    UUFGUI_Container:SetTitle(GUI_TITLE)
    UUFGUI_Container:SetStatusText(GenerateSupportOptions())
    UUFGUI_Container:SetLayout("Fill")
    UUFGUI_Container:SetWidth(GUI_WIDTH)
    UUFGUI_Container:SetHeight(GUI_HEIGHT)
    UUFGUI_Container:EnableResize(true)
    UUFGUI_Container:SetCallback("OnClose", function(widget) UUFGUI:Release(widget) GUIActive = false  end)

    local function DrawGeneralContainer(UUFGUI_Container)
        local ScrollableContainer = UUFGUI:Create("ScrollFrame")
        ScrollableContainer:SetLayout("Flow")
        ScrollableContainer:SetFullWidth(true)
        ScrollableContainer:SetFullHeight(true)
        UUFGUI_Container:AddChild(ScrollableContainer)

        local General = UUF.DB.profile.General
        local UIScaleContainer = UUFGUI:Create("InlineGroup")
        UIScaleContainer:SetTitle("UI Scale")
        UIScaleContainer:SetLayout("Flow")
        UIScaleContainer:SetFullWidth(true)

        local UIScale = UUFGUI:Create("Slider")
        UIScale:SetLabel("UI Scale")
        UIScale:SetSliderValues(0.4, 2, 0.01)
        UIScale:SetValue(UUF.DB.global.UIScale)
        UIScale:SetCallback("OnMouseUp", function(widget, event, value) 
            if value > 2 then value = 1 print("|cFF8080FFUnhalted|rUnitFrames: UIScale reset. Maximum of 2 for UIScale.") end 
            UUF.DB.global.UIScale = value
            UUF:UpdateUIScale() 
            UIScale:SetValue(value)
        end)
        UIScale:SetRelativeWidth(0.25)
        UIScale:SetCallback("OnEnter", function(widget, event) GameTooltip:SetOwner(widget.frame, "ANCHOR_TOPLEFT") GameTooltip:AddLine("Decimals are supported. They will need to be manually typed in.") GameTooltip:Show() end)
        UIScale:SetCallback("OnLeave", function(widget, event) GameTooltip:Hide() end)

        local TenEightyP = UUFGUI:Create("Button")
        TenEightyP:SetText("1080p")
        TenEightyP:SetCallback("OnClick", function(widget, event, value) UUF.DB.global.UIScale = 0.7111111111111 UIScale:SetValue(0.7111111111111) UUF:UpdateUIScale() end)
        TenEightyP:SetRelativeWidth(0.25)

        local FourteenFortyP = UUFGUI:Create("Button")
        FourteenFortyP:SetText("1440p")
        FourteenFortyP:SetCallback("OnClick", function(widget, event, value) UUF.DB.global.UIScale = 0.5333333333333 UIScale:SetValue(0.5333333333333) UUF:UpdateUIScale() end)
        FourteenFortyP:SetRelativeWidth(0.25)

        local ApplyUIScale = UUFGUI:Create("Button")
        ApplyUIScale:SetText("Apply")
        ApplyUIScale:SetCallback("OnClick", function(widget, event, value) UUF:UpdateUIScale() end)
        ApplyUIScale:SetRelativeWidth(0.25)

        local UIScaleToggle = UUFGUI:Create("CheckBox")
        UIScaleToggle:SetLabel("Enable UI Scale")
        UIScaleToggle:SetValue(UUF.DB.global.UIScaleEnabled)
        UIScaleToggle:SetCallback("OnValueChanged", function(widget, event, value) UUF.DB.global.UIScaleEnabled = value ReloadUI() end)
        UIScaleToggle:SetRelativeWidth(1)
        if not UUF.DB.global.UIScaleEnabled then
            UIScale:SetDisabled(true)
            TenEightyP:SetDisabled(true)
            FourteenFortyP:SetDisabled(true)
            ApplyUIScale:SetDisabled(true)
        end

        UIScaleContainer:AddChild(UIScaleToggle)
        UIScaleContainer:AddChild(UIScale)
        UIScaleContainer:AddChild(TenEightyP)
        UIScaleContainer:AddChild(FourteenFortyP)
        UIScaleContainer:AddChild(ApplyUIScale)
        
        ScrollableContainer:AddChild(UIScaleContainer)

        -- Font Options
        local FontOptionsContainer = UUFGUI:Create("InlineGroup")
        FontOptionsContainer:SetTitle("Font Options")
        FontOptionsContainer:SetLayout("Flow")
        FontOptionsContainer:SetFullWidth(true)

        local Font = UUFGUI:Create("LSM30_Font")
        Font:SetLabel("Font")
        Font:SetList(LSM:HashTable("font"))
        Font:SetValue(GenerateFontName(General.Font))
        Font:SetCallback("OnValueChanged", function(widget, event, value) General.Font = value 
            local LSMFont = LSM:Fetch("font", value)
            General.Font = LSMFont
            widget:SetValue(value)
            UUF:UpdateFrames()
        end)
        Font:SetRelativeWidth(0.5)
        FontOptionsContainer:AddChild(Font)
        
        local FontFlag = UUFGUI:Create("Dropdown")
        FontFlag:SetLabel("Font Flag")
        FontFlag:SetList({
            ["NONE"] = "None",
            ["OUTLINE"] = "Outline",
            ["THICKOUTLINE"] = "Thick Outline",
            ["MONOCHROME"] = "Monochrome",
            ["OUTLINE, MONOCHROME"] = "Outline, Monochrome",
            ["THICKOUTLINE, MONOCHROME"] = "Thick Outline, Monochrome",
        })
        FontFlag:SetValue(General.FontFlag)
        FontFlag:SetCallback("OnValueChanged", function(widget, event, value) General.FontFlag = value UUF:UpdateFrames() end)
        FontFlag:SetRelativeWidth(0.5)
        FontOptionsContainer:AddChild(FontFlag)

        local FontShadowContainer = UUFGUI:Create("InlineGroup")
        FontShadowContainer:SetTitle("Font Shadow Options")
        FontShadowContainer:SetLayout("Flow")
        FontShadowContainer:SetFullWidth(true)
        FontOptionsContainer:AddChild(FontShadowContainer)

        local FontShadowColourPicker = UUFGUI:Create("ColorPicker")
        FontShadowColourPicker:SetLabel("Colour")
        local FSR, FSG, FSB, FSA = unpack(General.FontShadowColour)
        FontShadowColourPicker:SetColor(FSR, FSG, FSB, FSA)
        FontShadowColourPicker:SetCallback("OnValueChanged", function(widget, _, r, g, b, a) General.FontShadowColour = {r, g, b, a} UUF:UpdateFrames() end)
        FontShadowColourPicker:SetHasAlpha(true)
        FontShadowColourPicker:SetRelativeWidth(0.33)
        FontShadowContainer:AddChild(FontShadowColourPicker)

        local FontShadowOffsetX = UUFGUI:Create("Slider")
        FontShadowOffsetX:SetLabel("Shadow Offset X")
        FontShadowOffsetX:SetValue(General.FontShadowXOffset)
        FontShadowOffsetX:SetSliderValues(-10, 10, 1)
        FontShadowOffsetX:SetCallback("OnMouseUp", function(_, _, value) General.FontShadowXOffset = value UUF:UpdateFrames() end)
        FontShadowOffsetX:SetRelativeWidth(0.33)
        FontShadowContainer:AddChild(FontShadowOffsetX)
        
        local FontShadowOffsetY = UUFGUI:Create("Slider")
        FontShadowOffsetY:SetLabel("Shadow Offset Y")
        FontShadowOffsetY:SetValue(General.FontShadowYOffset)
        FontShadowOffsetY:SetSliderValues(-10, 10, 1)
        FontShadowOffsetY:SetCallback("OnMouseUp", function(_, _, value) General.FontShadowYOffset = value UUF:UpdateFrames() end)
        FontShadowOffsetY:SetRelativeWidth(0.33)
        FontShadowContainer:AddChild(FontShadowOffsetY)

        ScrollableContainer:AddChild(FontOptionsContainer)

        -- Texture Options
        local TextureOptionsContainer = UUFGUI:Create("InlineGroup")
        TextureOptionsContainer:SetTitle("Texture Options")
        TextureOptionsContainer:SetLayout("Flow")
        TextureOptionsContainer:SetFullWidth(true)

        local ForegroundTexture = UUFGUI:Create("LSM30_Statusbar")
        ForegroundTexture:SetLabel("Foreground Texture")
        ForegroundTexture:SetList(LSM:HashTable("statusbar"))
        ForegroundTexture:SetValue(GenerateTextureName(General.ForegroundTexture))
        ForegroundTexture:SetCallback("OnValueChanged", function(widget, event, value)
            local LSMStatusbar = LSM:Fetch("statusbar", value)
            General.ForegroundTexture = LSMStatusbar
            widget:SetValue(value)
            UUF:UpdateFrames()
        end)
        ForegroundTexture:SetRelativeWidth(0.5)
        TextureOptionsContainer:AddChild(ForegroundTexture)

        local BackgroundTexture = UUFGUI:Create("LSM30_Statusbar")
        BackgroundTexture:SetLabel("Background Texture")
        BackgroundTexture:SetList(LSM:HashTable("statusbar"))
        BackgroundTexture:SetValue(GenerateTextureName(General.BackgroundTexture))
        BackgroundTexture:SetCallback("OnValueChanged", function(widget, event, value)
            local LSMStatusbar = LSM:Fetch("statusbar", value)
            General.BackgroundTexture = LSMStatusbar
            widget:SetValue(value)
            UUF:UpdateFrames()
        end)
        BackgroundTexture:SetRelativeWidth(0.5)
        TextureOptionsContainer:AddChild(BackgroundTexture)

        -- local BorderTexture = UUFGUI:Create("Dropdown")
        -- BorderTexture:SetLabel("Border Texture")
        -- BorderTexture:SetList(LSMBorders)
        -- BorderTexture:SetValue(General.BorderTexture)
        -- BorderTexture:SetCallback("OnValueChanged", function(widget, event, value) General.BorderTexture = value UUF:UpdateFrames() end)
        -- BorderTexture:SetRelativeWidth(0.33)
        -- TextureOptionsContainer:AddChild(BorderTexture)

        -- local BorderSize = UUFGUI:Create("Slider")
        -- BorderSize:SetLabel("Border Size")
        -- BorderSize:SetSliderValues(0, 64, 1)
        -- BorderSize:SetValue(General.BorderSize)
        -- BorderSize:SetCallback("OnValueChanged", function(widget, event, value) General.BorderSize = value UUF:UpdateFrames() end)
        -- BorderSize:SetRelativeWidth(0.5)
        -- TextureOptionsContainer:AddChild(BorderSize)

        -- local BorderInset = UUFGUI:Create("Slider")
        -- BorderInset:SetLabel("Border Inset")
        -- BorderInset:SetSliderValues(-64, 64, 1)
        -- BorderInset:SetValue(General.BorderInset)
        -- BorderInset:SetCallback("OnValueChanged", function(widget, event, value) General.BorderInset = value UUF:UpdateFrames() end)
        -- BorderInset:SetRelativeWidth(0.5)
        -- TextureOptionsContainer:AddChild(BorderInset)
        
        ScrollableContainer:AddChild(TextureOptionsContainer)

        -- Colouring Options
        local ColouringOptionsContainer = UUFGUI:Create("InlineGroup")
        ColouringOptionsContainer:SetTitle("Colour Options")
        ColouringOptionsContainer:SetLayout("Flow")
        ColouringOptionsContainer:SetFullWidth(true)

        local HealthColourOptions = UUFGUI:Create("InlineGroup")
        HealthColourOptions:SetTitle("Health Colour Options")
        HealthColourOptions:SetLayout("Flow")
        HealthColourOptions:SetFullWidth(true)
        ColouringOptionsContainer:AddChild(HealthColourOptions)

        local ForegroundColour = UUFGUI:Create("ColorPicker")
        ForegroundColour:SetLabel("Foreground Colour")
        local FGR, FGG, FGB, FGA = unpack(General.ForegroundColour)
        ForegroundColour:SetColor(FGR, FGG, FGB, FGA)
        ForegroundColour:SetCallback("OnValueChanged", function(widget, _, r, g, b, a) General.ForegroundColour = {r, g, b, a} UUF:UpdateFrames() end)
        ForegroundColour:SetHasAlpha(true)
        ForegroundColour:SetRelativeWidth(0.25)
        HealthColourOptions:AddChild(ForegroundColour)

        local ClassColour = UUFGUI:Create("CheckBox")
        ClassColour:SetLabel("Use Class / Reaction Colour")
        ClassColour:SetValue(General.ColourByClass)
        ClassColour:SetCallback("OnValueChanged", function(widget, event, value) General.ColourByClass = value UUF:UpdateFrames() end)
        ClassColour:SetRelativeWidth(0.25)
        HealthColourOptions:AddChild(ClassColour)

        -- local ReactionColour = UUFGUI:Create("CheckBox")
        -- ReactionColour:SetLabel("Use Reaction Colour")
        -- ReactionColour:SetValue(General.ColourByReaction)
        -- ReactionColour:SetCallback("OnValueChanged", function(widget, event, value) General.ColourByReaction = value UUF:UpdateFrames() end)
        -- ReactionColour:SetRelativeWidth(0.25)
        -- HealthColourOptions:AddChild(ReactionColour)

        local DisconnectedColour = UUFGUI:Create("CheckBox")
        DisconnectedColour:SetLabel("Use Disconnected Colour")
        DisconnectedColour:SetValue(General.ColourIfDisconnected)
        DisconnectedColour:SetCallback("OnValueChanged", function(widget, event, value) General.ColourIfDisconnected = value UUF:UpdateFrames() end)
        DisconnectedColour:SetRelativeWidth(0.25)
        HealthColourOptions:AddChild(DisconnectedColour)

        local TappedColour = UUFGUI:Create("CheckBox")
        TappedColour:SetLabel("Use Tapped Colour")
        TappedColour:SetValue(General.ColourIfTapped)
        TappedColour:SetCallback("OnValueChanged", function(widget, event, value) General.ColourIfTapped = value UUF:UpdateFrames() end)
        TappedColour:SetRelativeWidth(0.25)
        HealthColourOptions:AddChild(TappedColour)

        local BackgroundColourOptions = UUFGUI:Create("InlineGroup")
        BackgroundColourOptions:SetTitle("Background Colour Options")
        BackgroundColourOptions:SetLayout("Flow")
        BackgroundColourOptions:SetFullWidth(true)
        ColouringOptionsContainer:AddChild(BackgroundColourOptions)

        local BackgroundColour = UUFGUI:Create("ColorPicker")
        BackgroundColour:SetLabel("Background Colour")
        local BGR, BGG, BGB, BGA = unpack(General.BackgroundColour)
        BackgroundColour:SetColor(BGR, BGG, BGB, BGA)
        BackgroundColour:SetCallback("OnValueChanged", function(widget, _, r, g, b, a) General.BackgroundColour = {r, g, b, a} UUF:UpdateFrames() end)
        BackgroundColour:SetHasAlpha(true)
        BackgroundColour:SetRelativeWidth(1)
        BackgroundColourOptions:AddChild(BackgroundColour)

        local BackgroundColourMultiplier = UUFGUI:Create("Slider")
        BackgroundColourMultiplier:SetLabel("Multiplier")
        BackgroundColourMultiplier:SetSliderValues(0, 1, 0.01)
        BackgroundColourMultiplier:SetValue(General.BackgroundMultiplier)
        BackgroundColourMultiplier:SetCallback("OnMouseUp", function(widget, event, value) General.BackgroundMultiplier = value UUF:UpdateFrames() end)
        BackgroundColourMultiplier:SetRelativeWidth(0.25)

        local BackgroundColourByForeground = UUFGUI:Create("CheckBox")
        BackgroundColourByForeground:SetLabel("Colour By Foreground")
        BackgroundColourByForeground:SetValue(General.ColourBackgroundByForeground)
        BackgroundColourByForeground:SetCallback("OnValueChanged", function(widget, event, value) General.ColourBackgroundByForeground = value UUF:UpdateFrames() if value then BackgroundColourMultiplier:SetDisabled(false) else BackgroundColourMultiplier:SetDisabled(true) end end)
        BackgroundColourByForeground:SetRelativeWidth(0.25)
        BackgroundColourOptions:AddChild(BackgroundColourByForeground)


        BackgroundColourOptions:AddChild(BackgroundColourMultiplier)

        if General.ColourBackgroundByForeground then
            BackgroundColourMultiplier:SetDisabled(false)
        else
            BackgroundColourMultiplier:SetDisabled(true)
        end

        local BackgroundColourIfDead = UUFGUI:Create("CheckBox")
        BackgroundColourIfDead:SetLabel("Colour If Dead")
        BackgroundColourIfDead:SetValue(General.ColourBackgroundIfDead)
        BackgroundColourIfDead:SetCallback("OnValueChanged", function(widget, event, value) General.ColourBackgroundIfDead = value UUF:UpdateFrames() end)
        BackgroundColourIfDead:SetRelativeWidth(0.25)
        BackgroundColourOptions:AddChild(BackgroundColourIfDead)

        local BackgroundColourByClass = UUFGUI:Create("CheckBox")
        BackgroundColourByClass:SetLabel("Colour By Class / Reaction")
        BackgroundColourByClass:SetValue(General.ColourBackgroundByClass)
        BackgroundColourByClass:SetCallback("OnValueChanged", function(widget, event, value) General.ColourBackgroundByClass = value UUF:UpdateFrames() end)
        BackgroundColourByClass:SetRelativeWidth(0.25)
        BackgroundColourOptions:AddChild(BackgroundColourByClass)

        local BorderColourOptions = UUFGUI:Create("InlineGroup")
        BorderColourOptions:SetTitle("Border Colour Options")
        BorderColourOptions:SetLayout("Flow")
        BorderColourOptions:SetFullWidth(true)
        ColouringOptionsContainer:AddChild(BorderColourOptions)

        local BorderColour = UUFGUI:Create("ColorPicker")
        BorderColour:SetLabel("Border Colour")
        local BR, BG, BB, BA = unpack(General.BorderColour)
        BorderColour:SetColor(BR, BG, BB, BA)
        BorderColour:SetCallback("OnValueChanged", function(widget, _, r, g, b, a) General.BorderColour = {r, g, b, a} UUF:UpdateFrames() end)
        BorderColour:SetHasAlpha(true)
        BorderColour:SetRelativeWidth(0.33)
        BorderColourOptions:AddChild(BorderColour)

        local MouseoverHighlight = UUF.DB.profile.General.MouseoverHighlight
        local MouseoverHighlightOptions = UUFGUI:Create("InlineGroup")
        MouseoverHighlightOptions:SetTitle("Mouseover Highlight Options")
        MouseoverHighlightOptions:SetLayout("Flow")
        MouseoverHighlightOptions:SetFullWidth(true)
        ScrollableContainer:AddChild(MouseoverHighlightOptions)

        local MouseoverHighlightEnabled = UUFGUI:Create("CheckBox")
        MouseoverHighlightEnabled:SetLabel("Enable Mouseover Highlight")
        MouseoverHighlightEnabled:SetValue(MouseoverHighlight.Enabled)
        MouseoverHighlightEnabled:SetCallback("OnValueChanged", function(widget, event, value) MouseoverHighlight.Enabled = value UUF:CreateReloadPrompt() end)
        MouseoverHighlightEnabled:SetRelativeWidth(0.33)
        MouseoverHighlightOptions:AddChild(MouseoverHighlightEnabled)

        local MouseoverHighlightColor = UUFGUI:Create("ColorPicker")
        MouseoverHighlightColor:SetLabel("Color")
        local MHR, MHG, MHB, MHA = unpack(MouseoverHighlight.Colour)
        MouseoverHighlightColor:SetColor(MHR, MHG, MHB, MHA)
        MouseoverHighlightColor:SetCallback("OnValueChanged", function(widget, event, r, g, b, a) MouseoverHighlight.Colour = {r, g, b, a} UUF:UpdateFrames() end)
        MouseoverHighlightColor:SetHasAlpha(true)
        MouseoverHighlightColor:SetRelativeWidth(0.33)
        MouseoverHighlightOptions:AddChild(MouseoverHighlightColor)

        local MouseoverStyle = UUFGUI:Create("Dropdown")
        MouseoverStyle:SetLabel("Style")
        MouseoverStyle:SetList({
            ["BORDER"] = "Border",
            ["HIGHLIGHT"] = "Highlight",
        })
        MouseoverStyle:SetValue(MouseoverHighlight.Style)
        MouseoverStyle:SetCallback("OnValueChanged", function(widget, event, value) MouseoverHighlight.Style = value UUF:UpdateFrames() end)
        MouseoverStyle:SetRelativeWidth(0.33)
        MouseoverHighlightOptions:AddChild(MouseoverStyle)

        local CustomColours = UUFGUI:Create("InlineGroup")
        CustomColours:SetTitle("Custom Colours")
        CustomColours:SetLayout("Flow")
        CustomColours:SetFullWidth(true)
        ColouringOptionsContainer:AddChild(CustomColours)

        local ResetCustomColoursButton = UUFGUI:Create("Button")
        ResetCustomColoursButton:SetText("Reset Custom Colours")
        ResetCustomColoursButton:SetCallback("OnClick", function(widget, event, value) ResetColours() UUF:ReOpenGUI() end)
        ResetCustomColoursButton:SetRelativeWidth(1)
        CustomColours:AddChild(ResetCustomColoursButton)

        local PowerColours = UUFGUI:Create("InlineGroup")
        PowerColours:SetTitle("Power Colours")
        PowerColours:SetLayout("Flow")
        PowerColours:SetFullWidth(true)
        CustomColours:AddChild(PowerColours)

        local PowerOrder = {0, 1, 2, 3, 6, 8, 11, 13, 17, 18}
        for _, powerType in ipairs(PowerOrder) do
            local powerColour = General.CustomColours.Power[powerType]
            local PowerColour = UUFGUI:Create("ColorPicker")
            PowerColour:SetLabel(PowerNames[powerType])
            local R, G, B = unpack(powerColour)
            PowerColour:SetColor(R, G, B)
            PowerColour:SetCallback("OnValueChanged", function(widget, _, r, g, b)
                General.CustomColours.Power[powerType] = {r, g, b}
                UUF:UpdateFrames()
            end)
            PowerColour:SetHasAlpha(false)
            PowerColour:SetRelativeWidth(0.25)
            PowerColours:AddChild(PowerColour)
        end

        local ReactionColours = UUFGUI:Create("InlineGroup")
        ReactionColours:SetTitle("Reaction Colours")
        ReactionColours:SetLayout("Flow")
        ReactionColours:SetFullWidth(true)
        CustomColours:AddChild(ReactionColours)

        for reactionType, reactionColour in pairs(General.CustomColours.Reaction) do
            local ReactionColour = UUFGUI:Create("ColorPicker")
            ReactionColour:SetLabel(ReactionNames[reactionType])
            local R, G, B = unpack(reactionColour)
            ReactionColour:SetColor(R, G, B)
            ReactionColour:SetCallback("OnValueChanged", function(widget, _, r, g, b) General.CustomColours.Reaction[reactionType] = {r, g, b} UUF:UpdateFrames() end)
            ReactionColour:SetHasAlpha(false)
            ReactionColour:SetRelativeWidth(0.25)
            ReactionColours:AddChild(ReactionColour)
        end

        local StatusColours = UUFGUI:Create("InlineGroup")
        StatusColours:SetTitle("Status Colours")
        StatusColours:SetLayout("Flow")
        StatusColours:SetFullWidth(true)
        CustomColours:AddChild(StatusColours)

        for statusType, statusColour in pairs(General.CustomColours.Status) do
            local StatusColour = UUFGUI:Create("ColorPicker")
            StatusColour:SetLabel(StatusNames[statusType])
            local R, G, B = unpack(statusColour)
            StatusColour:SetColor(R, G, B)
            StatusColour:SetCallback("OnValueChanged", function(widget, _, r, g, b) General.CustomColours.Status[statusType] = {r, g, b} UUF:UpdateFrames() end)
            StatusColour:SetHasAlpha(false)
            StatusColour:SetRelativeWidth(0.33)
            StatusColours:AddChild(StatusColour)
        end
        
        ScrollableContainer:AddChild(ColouringOptionsContainer)
    end

    local function DrawFiltersContainer(UUFGUI_Container)
        local ScrollableContainer = UUFGUI:Create("ScrollFrame")
        ScrollableContainer:SetLayout("Flow")
        ScrollableContainer:SetFullWidth(true)
        ScrollableContainer:SetFullHeight(true)
        UUFGUI_Container:AddChild(ScrollableContainer)

        local BuffFilterContainer = UUFGUI:Create("InlineGroup")
        BuffFilterContainer:SetTitle("Buff Filters")
        BuffFilterContainer:SetLayout("Flow")
        BuffFilterContainer:SetFullWidth(true)
        ScrollableContainer:AddChild(BuffFilterContainer)

        local WhitelistBuffsEditBox = UUFGUI:Create("MultiLineEditBox")
        WhitelistBuffsEditBox:SetLabel("Whitelist Buffs")
        WhitelistBuffsEditBox:SetText(TableToList(UUF.DB.profile.WhitelistAuras.Buffs))
        WhitelistBuffsEditBox:SetCallback("OnEnterPressed", function(widget, event, value)
            if not UUF.DB.profile.WhitelistAuras then UUF.DB.profile.WhitelistAuras = { Buffs = {}, Debuffs = {} } end
            if not UUF.DB.profile.WhitelistAuras.Buffs then UUF.DB.profile.WhitelistAuras.Buffs = {} end
            local buffWhitelist = {}
            for id in string.gmatch(value, "[^,%s]+") do
                local spellID = tonumber(id)
                if spellID then
                    buffWhitelist[spellID] = true
                end
            end
            UUF.DB.profile.WhitelistAuras.Buffs = buffWhitelist
            WhitelistBuffsEditBox:SetText(TableToList(UUF.DB.profile.WhitelistAuras.Buffs))
            UUF:UpdateFrames()
        end)
        WhitelistBuffsEditBox:SetRelativeWidth(0.5)
        WhitelistBuffsEditBox:SetNumLines(10)
        BuffFilterContainer:AddChild(WhitelistBuffsEditBox)

        local BlacklistBuffsEditBox = UUFGUI:Create("MultiLineEditBox")
        BlacklistBuffsEditBox:SetLabel("Blacklist Buffs")
        BlacklistBuffsEditBox:SetText(TableToList(UUF.DB.global.BlacklistAuras.Buffs))
        BlacklistBuffsEditBox:SetCallback("OnEnterPressed", function(widget, event, value)
            if not UUF.DB.global.BlacklistAuras then UUF.DB.global.BlacklistAuras = { Buffs = {}, Debuffs = {} } end
            if not UUF.DB.global.BlacklistAuras.Buffs then UUF.DB.global.BlacklistAuras.Buffs = {} end
            local buffBlacklist = {}
            for id in string.gmatch(value, "[^,%s]+") do
                local spellID = tonumber(id)
                if spellID then
                    buffBlacklist[spellID] = true
                end
            end
            UUF.DB.global.BlacklistAuras.Buffs = buffBlacklist
            BlacklistBuffsEditBox:SetText(TableToList(UUF.DB.global.BlacklistAuras.Buffs))
            UUF:UpdateFrames()
        end)
        BlacklistBuffsEditBox:SetRelativeWidth(0.5)
        BlacklistBuffsEditBox:SetNumLines(10)
        BuffFilterContainer:AddChild(BlacklistBuffsEditBox)
        
        local DebuffFilterContainer = UUFGUI:Create("InlineGroup")
        DebuffFilterContainer:SetTitle("Debuff Filters")
        DebuffFilterContainer:SetLayout("Flow")
        DebuffFilterContainer:SetFullWidth(true)
        ScrollableContainer:AddChild(DebuffFilterContainer)

        local WhitelistDebuffsEditBox = UUFGUI:Create("MultiLineEditBox")
        WhitelistDebuffsEditBox:SetLabel("Whitelist Debuffs")
        WhitelistDebuffsEditBox:SetText(TableToList(UUF.DB.profile.WhitelistAuras.Debuffs))
        WhitelistDebuffsEditBox:SetCallback("OnEnterPressed", function(widget, event, value)
            if not UUF.DB.profile.WhitelistAuras then UUF.DB.profile.WhitelistAuras = { Buffs = {}, Debuffs = {} } end
            if not UUF.DB.profile.WhitelistAuras.Debuffs then UUF.DB.profile.WhitelistAuras.Debuffs = {} end
            local debuffWhitelist = {}
            for id in string.gmatch(value, "[^,%s]+") do
                local spellID = tonumber(id)
                if spellID then
                    debuffWhitelist[spellID] = true
                end
            end
            UUF.DB.profile.WhitelistAuras.Debuffs = debuffWhitelist
            WhitelistDebuffsEditBox:SetText(TableToList(UUF.DB.profile.WhitelistAuras.Debuffs))
            UUF:UpdateFrames()
        end)
        WhitelistDebuffsEditBox:SetRelativeWidth(0.5)
        WhitelistDebuffsEditBox:SetNumLines(10)
        DebuffFilterContainer:AddChild(WhitelistDebuffsEditBox)

        local BlacklistDebuffsEditBox = UUFGUI:Create("MultiLineEditBox")
        BlacklistDebuffsEditBox:SetLabel("Blacklist Debuffs")
        BlacklistDebuffsEditBox:SetText(TableToList(UUF.DB.global.BlacklistAuras.Debuffs))
        BlacklistDebuffsEditBox:SetCallback("OnEnterPressed", function(widget, event, value)
            if not UUF.DB.global.BlacklistAuras then UUF.DB.global.BlacklistAuras = { Buffs = {}, Debuffs = {} } end
            if not UUF.DB.global.BlacklistAuras.Debuffs then UUF.DB.global.BlacklistAuras.Debuffs = {} end
            local debuffBlacklist = {}
            for id in string.gmatch(value, "[^,%s]+") do
                local spellID = tonumber(id)
                if spellID then
                    debuffBlacklist[spellID] = true
                end
            end
            UUF.DB.global.BlacklistAuras.Debuffs = debuffBlacklist
            BlacklistDebuffsEditBox:SetText(TableToList(UUF.DB.global.BlacklistAuras.Debuffs))
            UUF:UpdateFrames()
        end)
        BlacklistDebuffsEditBox:SetRelativeWidth(0.5)
        BlacklistDebuffsEditBox:SetNumLines(10)
        DebuffFilterContainer:AddChild(BlacklistDebuffsEditBox)

        local ApplyRecommendedBlacklists = UUFGUI:Create("Button")
        ApplyRecommendedBlacklists:SetText("Apply Recommended Blacklists")
        ApplyRecommendedBlacklists:SetCallback("OnClick", function(widget, event, value)
            local RecommendedBuffBlacklist = UUF:FetchBuffBlacklist()
            for spellID in pairs(RecommendedBuffBlacklist) do
                if not UUF.DB.global.BlacklistAuras.Buffs[spellID] then
                    UUF.DB.global.BlacklistAuras.Buffs[spellID] = true
                end
            end

            local RecommendedDebuffBlacklist = UUF:FetchDebuffBlacklist()
            for spellID in pairs(RecommendedDebuffBlacklist) do
                if not UUF.DB.global.BlacklistAuras.Debuffs[spellID] then
                    UUF.DB.global.BlacklistAuras.Debuffs[spellID] = true
                end
            end
            UUF:UpdateFrames()

            BlacklistBuffsEditBox:SetText(TableToList(UUF.DB.global.BlacklistAuras.Buffs))
            BlacklistDebuffsEditBox:SetText(TableToList(UUF.DB.global.BlacklistAuras.Debuffs))
        end)
        ApplyRecommendedBlacklists:SetRelativeWidth(1)
        ScrollableContainer:AddChild(ApplyRecommendedBlacklists)

        local ResetFiltersButton = UUFGUI:Create("Button")
        ResetFiltersButton:SetText("Reset Filters")
        ResetFiltersButton:SetCallback("OnClick", function(widget, event, value)
            UUF.DB.global.BlacklistAuras = { Buffs = {}, Debuffs = {} }
            UUF.DB.profile.WhitelistAuras = { Buffs = {}, Debuffs = {} }
            UUF:UpdateFrames()
            WhitelistBuffsEditBox:SetText(TableToList(UUF.DB.profile.WhitelistAuras.Buffs))
            BlacklistBuffsEditBox:SetText(TableToList(UUF.DB.global.BlacklistAuras.Buffs))
            WhitelistDebuffsEditBox:SetText(TableToList(UUF.DB.profile.WhitelistAuras.Debuffs))
            BlacklistDebuffsEditBox:SetText(TableToList(UUF.DB.global.BlacklistAuras.Debuffs))
            print("|cFF8080FFUnhalted|rUnitFrames - Filters have been reset.")
        end)
        ResetFiltersButton:SetRelativeWidth(1)
        ScrollableContainer:AddChild(ResetFiltersButton)
    end

    local function DrawUnitContainer(UUFGUI_Container, Unit)
        local ScrollableContainer = UUFGUI:Create("ScrollFrame")
        ScrollableContainer:SetLayout("Flow")
        ScrollableContainer:SetFullWidth(true)
        ScrollableContainer:SetFullHeight(true)
        UUFGUI_Container:AddChild(ScrollableContainer)

        local General = UUF.DB.profile.General
        local Frame = UUF.DB.profile[Unit].Frame
        local Portrait = UUF.DB.profile[Unit].Portrait
        local Health = UUF.DB.profile[Unit].Health
        local HealthPrediction = Health.HealthPrediction
        local Absorbs = HealthPrediction.Absorbs
        local HealAbsorbs = HealthPrediction.HealAbsorbs
        local PowerBar = UUF.DB.profile[Unit].PowerBar
        local Buffs = UUF.DB.profile[Unit].Buffs
        local Debuffs = UUF.DB.profile[Unit].Debuffs
        local TargetMarker = UUF.DB.profile[Unit].TargetMarker
        local CombatIndicator = UUF.DB.profile[Unit].CombatIndicator
        local LeaderIndicator = UUF.DB.profile[Unit].LeaderIndicator
        local TargetIndicator = UUF.DB.profile[Unit].TargetIndicator
        local FirstText = UUF.DB.profile[Unit].Texts.First
        local SecondText = UUF.DB.profile[Unit].Texts.Second
        local ThirdText = UUF.DB.profile[Unit].Texts.Third
        local Range = UUF.DB.profile[Unit].Range

        local function DrawFrameContainer(UUFGUI_Container)
            local Enabled = UUFGUI:Create("CheckBox")
            Enabled:SetLabel("Enable Frame")
            Enabled:SetValue(Frame.Enabled)
            Enabled:SetCallback("OnValueChanged", function(widget, event, value) Frame.Enabled = value UUF:CreateReloadPrompt() end)
            Enabled:SetRelativeWidth(0.5)
            UUFGUI_Container:AddChild(Enabled)

            if Unit == "Player" or Unit == "Target" or Unit == "Focus" or Unit == "FocusTarget" or Unit == "Pet" or Unit == "TargetTarget" then
                local CopyFromDropdown = UUFGUI:Create("Dropdown")
                CopyFromDropdown:SetLabel("Copy From")
                CopyFromDropdown:SetList(GenerateCopyFromList(Unit))
                CopyFromDropdown:SetValue(nil)
                CopyFromDropdown:SetCallback("OnValueChanged", function(widget, event, value)
                    if value == Unit then return end
                    local sourceUnit = UUF.DB.profile[value]
                    local targetUnit = UUF.DB.profile[Unit]
                    if not sourceUnit then print("|cFFFF0000Unhalted|r Error: No settings found for " .. value) return end
                    if not targetUnit then print("|cFFFF0000Unhalted|r Error: No settings found for " .. Unit) return end
                    CopyUnit(sourceUnit, targetUnit)
                    print("|cFF8080FFUnhalted|rUnitFrames: Copied settings from " .. value .. " to " .. Unit .. ".")
                    CopyFromDropdown:SetValue(nil)
                end)
                CopyFromDropdown:SetRelativeWidth(0.5)
                UUFGUI_Container:AddChild(CopyFromDropdown)
                if not Frame.Enabled then CopyFromDropdown:SetDisabled(true) end
            end

            if Unit == "Boss" then
                local DisplayFrames = UUFGUI:Create("Button")
                DisplayFrames:SetText("Display Frames")
                DisplayFrames:SetCallback("OnClick", function(widget, event, value) UUF.DB.profile.TestMode = not UUF.DB.profile.TestMode UUF:DisplayBossFrames() UUF:UpdateFrames() end)
                DisplayFrames:SetRelativeWidth(1)
                UUFGUI_Container:AddChild(DisplayFrames)
                if not Frame.Enabled then DisplayFrames:SetDisabled(true) end
            end

            -- Frame Options
            local FrameOptions = UUFGUI:Create("InlineGroup")
            FrameOptions:SetTitle("Frame Options")
            FrameOptions:SetLayout("Flow")
            FrameOptions:SetFullWidth(true)

            local FrameAnchorFrom = UUFGUI:Create("Dropdown")
            FrameAnchorFrom:SetLabel("Anchor From")
            FrameAnchorFrom:SetList(AnchorPoints)
            FrameAnchorFrom:SetValue(Frame.AnchorFrom)
            FrameAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) Frame.AnchorFrom = value UUF:UpdateFrames() end)
            FrameAnchorFrom:SetRelativeWidth(0.33)
            FrameOptions:AddChild(FrameAnchorFrom)

            local FrameAnchorTo = UUFGUI:Create("Dropdown")
            FrameAnchorTo:SetLabel("Anchor To")
            FrameAnchorTo:SetList(AnchorPoints)
            FrameAnchorTo:SetValue(Frame.AnchorTo)
            FrameAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) Frame.AnchorTo = value UUF:UpdateFrames() end)
            FrameAnchorTo:SetRelativeWidth(0.33)
            FrameOptions:AddChild(FrameAnchorTo)

            local FrameAnchorParent = UUFGUI:Create("EditBox")
            FrameAnchorParent:SetLabel("Anchor Parent")
            FrameAnchorParent:SetText(type(Frame.AnchorParent) == "string" and Frame.AnchorParent or "UIParent")

            FrameAnchorParent:SetCallback("OnEnterPressed", function(widget, event, value)
                local anchor = _G[value]
                if anchor and anchor:IsObjectType("Frame") then
                    Frame.AnchorParent = value
                else
                    Frame.AnchorParent = "UIParent"
                    widget:SetText("UIParent")
                end
                UUF:UpdateFrames()
            end)
            FrameAnchorParent:SetRelativeWidth(0.33)
            FrameOptions:AddChild(FrameAnchorParent)

            local FrameAnchorParentTooltipDesc = "|cFF8080FFPLEASE NOTE|r: This will |cFFFF4040NOT|r work for WeakAuras."
            FrameAnchorParent:SetCallback("OnEnter", function(widget, event) GameTooltip:SetOwner(widget.frame, "ANCHOR_TOPLEFT") GameTooltip:AddLine(FrameAnchorParentTooltipDesc) GameTooltip:Show() end)
            FrameAnchorParent:SetCallback("OnLeave", function(widget, event) GameTooltip:Hide() end)

            local FrameWidth = UUFGUI:Create("Slider")
            FrameWidth:SetLabel("Frame Width")
            FrameWidth:SetSliderValues(1, 999, 0.1)
            FrameWidth:SetValue(Frame.Width)
            FrameWidth:SetCallback("OnMouseUp", function(widget, event, value) Frame.Width = value UUF:UpdateFrames() end)
            FrameWidth:SetRelativeWidth(0.5)
            FrameOptions:AddChild(FrameWidth)

            local FrameHeight = UUFGUI:Create("Slider")
            FrameHeight:SetLabel("Frame Height")
            FrameHeight:SetSliderValues(1, 999, 0.1)
            FrameHeight:SetValue(Frame.Height)
            FrameHeight:SetCallback("OnMouseUp", function(widget, event, value) Frame.Height = value UUF:UpdateFrames() end)
            FrameHeight:SetRelativeWidth(0.5)
            FrameOptions:AddChild(FrameHeight)

            local FrameXPosition = UUFGUI:Create("Slider")
            FrameXPosition:SetLabel("Frame X Position")
            FrameXPosition:SetSliderValues(-999, 999, 0.1)
            FrameXPosition:SetValue(Frame.XPosition)
            FrameXPosition:SetCallback("OnMouseUp", function(widget, event, value) Frame.XPosition = value UUF:UpdateFrames() end)
            FrameXPosition:SetRelativeWidth(0.5)
            FrameOptions:AddChild(FrameXPosition)

            local FrameYPosition = UUFGUI:Create("Slider")
            FrameYPosition:SetLabel("Frame Y Position")
            FrameYPosition:SetSliderValues(-999, 999, 0.1)
            FrameYPosition:SetValue(Frame.YPosition)
            FrameYPosition:SetCallback("OnMouseUp", function(widget, event, value) Frame.YPosition = value UUF:UpdateFrames() end)
            FrameYPosition:SetRelativeWidth(0.5)
            FrameOptions:AddChild(FrameYPosition)

            if Unit == "Boss" then
                local FrameSpacing = UUFGUI:Create("Slider")
                FrameSpacing:SetLabel("Frame Spacing")
                FrameSpacing:SetSliderValues(-999, 999, 0.1)
                FrameSpacing:SetValue(Frame.Spacing)
                FrameSpacing:SetCallback("OnMouseUp", function(widget, event, value) Frame.Spacing = value UUF:UpdateFrames() end)
                FrameXPosition:SetRelativeWidth(0.25)
                FrameYPosition:SetRelativeWidth(0.25)
                FrameSpacing:SetRelativeWidth(0.25)
                FrameOptions:AddChild(FrameSpacing)

                local GrowthDirection = UUFGUI:Create("Dropdown")
                GrowthDirection:SetLabel("Growth Direction")
                GrowthDirection:SetList({
                    ["DOWN"] = "Down",
                    ["UP"] = "Up",
                })
                GrowthDirection:SetValue(Frame.GrowthY)
                GrowthDirection:SetCallback("OnValueChanged", function(widget, event, value) Frame.GrowthY = value UUF:UpdateFrames() end)
                GrowthDirection:SetRelativeWidth(0.25)
                FrameOptions:AddChild(GrowthDirection)
            end

            UUFGUI_Container:AddChild(FrameOptions)

            local PortraitOptions = UUFGUI:Create("InlineGroup")
            PortraitOptions:SetTitle("Portrait Options")
            PortraitOptions:SetLayout("Flow")
            PortraitOptions:SetFullWidth(true)

            local PortraitEnabled = UUFGUI:Create("CheckBox")
            PortraitEnabled:SetLabel("Enable Portrait")
            PortraitEnabled:SetValue(Portrait.Enabled)
            PortraitEnabled:SetCallback("OnValueChanged", function(widget, event, value) Portrait.Enabled = value UUF:CreateReloadPrompt() end)
            PortraitEnabled:SetRelativeWidth(1)
            PortraitOptions:AddChild(PortraitEnabled)

            local PortraitAnchorFrom = UUFGUI:Create("Dropdown")
            PortraitAnchorFrom:SetLabel("Anchor From")
            PortraitAnchorFrom:SetList(AnchorPoints)
            PortraitAnchorFrom:SetValue(Portrait.AnchorFrom)
            PortraitAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) Portrait.AnchorFrom = value UUF:UpdateFrames() end)
            PortraitAnchorFrom:SetRelativeWidth(0.5)
            PortraitOptions:AddChild(PortraitAnchorFrom)

            local PortraitAnchorTo = UUFGUI:Create("Dropdown")
            PortraitAnchorTo:SetLabel("Anchor To")
            PortraitAnchorTo:SetList(AnchorPoints)
            PortraitAnchorTo:SetValue(Portrait.AnchorTo)
            PortraitAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) Portrait.AnchorTo = value UUF:UpdateFrames() end)
            PortraitAnchorTo:SetRelativeWidth(0.5)
            PortraitOptions:AddChild(PortraitAnchorTo)

            local PortraitSize = UUFGUI:Create("Slider")
            PortraitSize:SetLabel("Portrait Size")
            PortraitSize:SetSliderValues(1, 999, 0.1)
            PortraitSize:SetValue(Portrait.Size)
            PortraitSize:SetCallback("OnMouseUp", function(widget, event, value) Portrait.Size = value UUF:UpdateFrames() end)
            PortraitSize:SetRelativeWidth(0.33)
            PortraitOptions:AddChild(PortraitSize)

            local PortraitXOffset = UUFGUI:Create("Slider")
            PortraitXOffset:SetLabel("Portrait X Offset")
            PortraitXOffset:SetSliderValues(-999, 999, 1)
            PortraitXOffset:SetValue(Portrait.XOffset)
            PortraitXOffset:SetCallback("OnMouseUp", function(widget, event, value) Portrait.XOffset = value UUF:UpdateFrames() end)
            PortraitXOffset:SetRelativeWidth(0.33)
            PortraitOptions:AddChild(PortraitXOffset)

            local PortraitYOffset = UUFGUI:Create("Slider")
            PortraitYOffset:SetLabel("Portrait Y Offset")
            PortraitYOffset:SetSliderValues(-999, 999, 1)
            PortraitYOffset:SetValue(Portrait.YOffset)
            PortraitYOffset:SetCallback("OnMouseUp", function(widget, event, value) Portrait.YOffset = value UUF:UpdateFrames() end)
            PortraitYOffset:SetRelativeWidth(0.33)
            PortraitOptions:AddChild(PortraitYOffset)

            UUFGUI_Container:AddChild(PortraitOptions)

            local HealthOptionsContainer = UUFGUI:Create("InlineGroup")
            HealthOptionsContainer:SetTitle("Health Options")
            HealthOptionsContainer:SetLayout("Flow")
            HealthOptionsContainer:SetFullWidth(true)

            if Unit == "Pet" then
                local HealthGrowDirection = UUFGUI:Create("Dropdown")
                HealthGrowDirection:SetLabel("Health Grow Direction")
                HealthGrowDirection:SetList({
                    ["LR"] = "Left To Right",
                    ["RL"] = "Right To Left",
                })
                HealthGrowDirection:SetValue(Health.Direction)
                HealthGrowDirection:SetCallback("OnValueChanged", function(widget, event, value) Health.Direction = value UUF:UpdateFrames() end)
                HealthGrowDirection:SetRelativeWidth(0.5)
                HealthOptionsContainer:AddChild(HealthGrowDirection)

                local ColourHealthByClass = UUFGUI:Create("CheckBox")
                ColourHealthByClass:SetLabel("Colour By Player Class")
                ColourHealthByClass:SetValue(Health.ColourByPlayerClass)
                ColourHealthByClass:SetCallback("OnValueChanged", function(widget, event, value) Health.ColourByPlayerClass = value UUF:UpdateFrames() end)
                ColourHealthByClass:SetRelativeWidth(0.5)
                ColourHealthByClass:SetDisabled(not General.ColourByClass)
                HealthOptionsContainer:AddChild(ColourHealthByClass)
            else
                local HealthGrowDirection = UUFGUI:Create("Dropdown")
                HealthGrowDirection:SetLabel("Health Grow Direction")
                HealthGrowDirection:SetList({
                    ["LR"] = "Left To Right",
                    ["RL"] = "Right To Left",
                })
                HealthGrowDirection:SetValue(Health.Direction)
                HealthGrowDirection:SetCallback("OnValueChanged", function(widget, event, value) Health.Direction = value UUF:UpdateFrames() end)
                HealthGrowDirection:SetFullWidth(true)
                HealthOptionsContainer:AddChild(HealthGrowDirection)
            end
            
            local AbsorbsContainer = UUFGUI:Create("InlineGroup")
            AbsorbsContainer:SetTitle("Health Prediction Options")
            AbsorbsContainer:SetLayout("Flow")
            AbsorbsContainer:SetFullWidth(true)
            HealthOptionsContainer:AddChild(AbsorbsContainer)

            local AbsorbsEnabled = UUFGUI:Create("CheckBox")
            AbsorbsEnabled:SetLabel("Enable Absorbs")
            AbsorbsEnabled:SetValue(Absorbs.Enabled)
            AbsorbsEnabled:SetCallback("OnValueChanged", function(widget, event, value) Absorbs.Enabled = value UUF:CreateReloadPrompt() end)
            AbsorbsEnabled:SetRelativeWidth(0.5)
            AbsorbsContainer:AddChild(AbsorbsEnabled)

            local AbsorbsColourPicker = UUFGUI:Create("ColorPicker")
            AbsorbsColourPicker:SetLabel("Colour")
            local AR, AG, AB, AA = unpack(Absorbs.Colour)
            AbsorbsColourPicker:SetColor(AR, AG, AB, AA)
            AbsorbsColourPicker:SetCallback("OnValueChanged", function(widget, _, r, g, b, a) Absorbs.Colour = {r, g, b, a} UUF:UpdateFrames() end)
            AbsorbsColourPicker:SetHasAlpha(true)
            AbsorbsColourPicker:SetRelativeWidth(0.5)
            AbsorbsContainer:AddChild(AbsorbsColourPicker)

            local HealAbsorbsContainer = UUFGUI:Create("InlineGroup")
            HealAbsorbsContainer:SetTitle("Heal Absorbs")
            HealAbsorbsContainer:SetLayout("Flow")
            HealAbsorbsContainer:SetFullWidth(true)
            HealthOptionsContainer:AddChild(HealAbsorbsContainer)

            local HealAbsorbsEnabled = UUFGUI:Create("CheckBox")
            HealAbsorbsEnabled:SetLabel("Enable Heal Absorbs")
            HealAbsorbsEnabled:SetValue(HealAbsorbs.Enabled)
            HealAbsorbsEnabled:SetCallback("OnValueChanged", function(widget, event, value) HealAbsorbs.Enabled = value UUF:UpdateFrames() end)
            HealAbsorbsEnabled:SetRelativeWidth(0.5)
            HealAbsorbsContainer:AddChild(HealAbsorbsEnabled)

            local HealAbsorbsColourPicker = UUFGUI:Create("ColorPicker")
            HealAbsorbsColourPicker:SetLabel("Colour")
            local HAR, HAG, HAB, HAA = unpack(HealAbsorbs.Colour)
            HealAbsorbsColourPicker:SetColor(HAR, HAG, HAB, HAA)
            HealAbsorbsColourPicker:SetCallback("OnValueChanged", function(widget, _, r, g, b, a) HealAbsorbs.Colour = {r, g, b, a} UUF:UpdateFrames() end)
            HealAbsorbsColourPicker:SetHasAlpha(true)
            HealAbsorbsColourPicker:SetRelativeWidth(0.5)
            HealAbsorbsContainer:AddChild(HealAbsorbsColourPicker)

            UUFGUI_Container:AddChild(HealthOptionsContainer)

            local PowerBarOptionsContainer = UUFGUI:Create("InlineGroup")
            PowerBarOptionsContainer:SetTitle("Power Bar Options")
            PowerBarOptionsContainer:SetLayout("Flow")
            PowerBarOptionsContainer:SetFullWidth(true)
            UUFGUI_Container:AddChild(PowerBarOptionsContainer)

            local PowerBarEnabled = UUFGUI:Create("CheckBox")
            PowerBarEnabled:SetLabel("Enable Power Bar")
            PowerBarEnabled:SetValue(PowerBar.Enabled)
            PowerBarEnabled:SetCallback("OnValueChanged", function(widget, event, value) PowerBar.Enabled = value UUF:CreateReloadPrompt() end)
            PowerBarEnabled:SetRelativeWidth(0.33)
            PowerBarOptionsContainer:AddChild(PowerBarEnabled)

            local PowerBarSmooth = UUFGUI:Create("CheckBox")
            PowerBarSmooth:SetLabel("Smooth")
            PowerBarSmooth:SetValue(PowerBar.Smooth)
            PowerBarSmooth:SetCallback("OnValueChanged", function(widget, event, value) PowerBar.Smooth = value UUF:UpdateFrames() end)
            PowerBarSmooth:SetRelativeWidth(0.33)
            PowerBarOptionsContainer:AddChild(PowerBarSmooth)

            local PowerBarGrowthDirection = UUFGUI:Create("Dropdown")
            PowerBarGrowthDirection:SetLabel("Power Bar Growth Direction")
            PowerBarGrowthDirection:SetList({
                ["LR"] = "Left To Right",
                ["RL"] = "Right To Left",
            })
            PowerBarGrowthDirection:SetValue(PowerBar.Direction)
            PowerBarGrowthDirection:SetCallback("OnValueChanged", function(widget, event, value) PowerBar.Direction = value UUF:UpdateFrames() end)
            PowerBarGrowthDirection:SetRelativeWidth(0.33)
            PowerBarOptionsContainer:AddChild(PowerBarGrowthDirection)

            local PowerBarColourByType = UUFGUI:Create("CheckBox")
            PowerBarColourByType:SetLabel("Colour Bar By Type")
            PowerBarColourByType:SetValue(PowerBar.ColourByType)
            PowerBarColourByType:SetCallback("OnValueChanged", function(widget, event, value) PowerBar.ColourByType = value UUF:UpdateFrames() end)
            PowerBarColourByType:SetRelativeWidth(0.25)
            PowerBarOptionsContainer:AddChild(PowerBarColourByType)

            local BackgroundColourMultiplier = UUFGUI:Create("Slider")
            BackgroundColourMultiplier:SetLabel("Multiplier")
            BackgroundColourMultiplier:SetSliderValues(0, 1, 0.01)
            BackgroundColourMultiplier:SetValue(PowerBar.BackgroundMultiplier)
            BackgroundColourMultiplier:SetCallback("OnMouseUp", function(widget, event, value) PowerBar.BackgroundMultiplier = value UUF:UpdateFrames() end)
            BackgroundColourMultiplier:SetRelativeWidth(0.5)

            local PowerBarBackdropColourByType = UUFGUI:Create("CheckBox")
            PowerBarBackdropColourByType:SetLabel("Colour Background By Type")
            PowerBarBackdropColourByType:SetValue(PowerBar.ColourBackgroundByType)
            PowerBarBackdropColourByType:SetCallback("OnValueChanged", function(widget, event, value) PowerBar.ColourBackgroundByType = value 
            if value then BackgroundColourMultiplier:SetDisabled(false) else BackgroundColourMultiplier:SetDisabled(true) end
            UUF:UpdateFrames() end)
            PowerBarBackdropColourByType:SetRelativeWidth(0.25)
            PowerBarOptionsContainer:AddChild(PowerBarBackdropColourByType)

            local PowerBarColour = UUFGUI:Create("ColorPicker")
            PowerBarColour:SetLabel("Foreground Colour")
            local PBR, PBG, PBB, PBA = unpack(PowerBar.Colour)
            PowerBarColour:SetColor(PBR, PBG, PBB, PBA)
            PowerBarColour:SetCallback("OnValueChanged", function(widget, event, r, g, b, a) PowerBar.Colour = {r, g, b, a} UUF:UpdateFrames() end)
            PowerBarColour:SetHasAlpha(true)
            PowerBarColour:SetRelativeWidth(0.25)
            PowerBarOptionsContainer:AddChild(PowerBarColour)

            local PowerBarBackdropColour = UUFGUI:Create("ColorPicker")
            PowerBarBackdropColour:SetLabel("Background Colour")
            local PBBR, PBBG, PBBB, PBBA = unpack(PowerBar.BackgroundColour)
            PowerBarBackdropColour:SetColor(PBBR, PBBG, PBBB, PBBA)
            PowerBarBackdropColour:SetCallback("OnValueChanged", function(widget, event, r, g, b, a) PowerBar.BackgroundColour = {r, g, b, a} UUF:UpdateFrames() end)
            PowerBarBackdropColour:SetHasAlpha(true)
            PowerBarBackdropColour:SetRelativeWidth(0.25)
            PowerBarOptionsContainer:AddChild(PowerBarBackdropColour)


            PowerBarOptionsContainer:AddChild(BackgroundColourMultiplier)

            local PowerBarHeight = UUFGUI:Create("Slider")
            PowerBarHeight:SetLabel("Height")
            PowerBarHeight:SetSliderValues(1, 64, 1)
            PowerBarHeight:SetValue(PowerBar.Height)
            PowerBarHeight:SetCallback("OnMouseUp", function(widget, event, value) PowerBar.Height = value UUF:UpdateFrames() end)
            PowerBarHeight:SetRelativeWidth(0.5)
            PowerBarOptionsContainer:AddChild(PowerBarHeight)

            if not Frame.Enabled then
                if FrameOptions then
                    for _, child in ipairs(FrameOptions.children) do
                        if child.SetDisabled then
                            child:SetDisabled(true)
                        end
                    end
                end
                if PortraitOptions then
                    for _, child in ipairs(PortraitOptions.children) do
                        if child.SetDisabled then
                            child:SetDisabled(true)
                        end
                    end
                end
                if HealthOptionsContainer then
                    for _, child in ipairs(HealthOptionsContainer.children) do
                        if child.SetDisabled then
                            child:SetDisabled(true)
                        end
                    end
                end
                if AbsorbsContainer then
                    for _, child in ipairs(AbsorbsContainer.children) do
                        if child.SetDisabled then
                            child:SetDisabled(true)
                        end
                    end
                end
                if HealAbsorbsContainer then
                    for _, child in ipairs(HealAbsorbsContainer.children) do
                        if child.SetDisabled then
                            child:SetDisabled(true)
                        end
                    end
                end
                if PowerBarOptionsContainer then
                    for _, child in ipairs(PowerBarOptionsContainer.children) do
                        if child.SetDisabled then
                            child:SetDisabled(true)
                        end
                    end
                end
                return
            end
        end

        local function DrawBuffsContainer(UUFGUI_Container)
            local BuffOptions = UUFGUI:Create("InlineGroup")
            BuffOptions:SetTitle("Buff Options")
            BuffOptions:SetLayout("Flow")
            BuffOptions:SetFullWidth(true)
            UUFGUI_Container:AddChild(BuffOptions)
    
            local BuffsEnabled = UUFGUI:Create("CheckBox")
            BuffsEnabled:SetLabel("Enable Buffs")
            BuffsEnabled:SetValue(Buffs.Enabled)
            BuffsEnabled:SetCallback("OnValueChanged", function(widget, event, value) Buffs.Enabled = value UUF:CreateReloadPrompt() end)
            BuffsEnabled:SetRelativeWidth(0.5)
            BuffOptions:AddChild(BuffsEnabled)

            local OnlyShowPlayerBuffs = UUFGUI:Create("CheckBox")
            OnlyShowPlayerBuffs:SetLabel("Only Show Player Buffs")
            OnlyShowPlayerBuffs:SetValue(Buffs.OnlyShowPlayer)
            OnlyShowPlayerBuffs:SetCallback("OnValueChanged", function(widget, event, value) Buffs.OnlyShowPlayer = value UUF:UpdateFrames() end)
            OnlyShowPlayerBuffs:SetRelativeWidth(0.5)
            BuffOptions:AddChild(OnlyShowPlayerBuffs)

            local BuffAnchorFrom = UUFGUI:Create("Dropdown")
            BuffAnchorFrom:SetLabel("Anchor From")
            BuffAnchorFrom:SetList(AnchorPoints)
            BuffAnchorFrom:SetValue(Buffs.AnchorFrom)
            BuffAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) Buffs.AnchorFrom = value UUF:UpdateFrames() end)
            BuffAnchorFrom:SetRelativeWidth(0.5)
            BuffOptions:AddChild(BuffAnchorFrom)
    
            local BuffAnchorTo = UUFGUI:Create("Dropdown")
            BuffAnchorTo:SetLabel("Anchor To")
            BuffAnchorTo:SetList(AnchorPoints)
            BuffAnchorTo:SetValue(Buffs.AnchorTo)
            BuffAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) Buffs.AnchorTo = value UUF:UpdateFrames() end)
            BuffAnchorTo:SetRelativeWidth(0.5)
            BuffOptions:AddChild(BuffAnchorTo)
    
            local BuffGrowthX = UUFGUI:Create("Dropdown")
            BuffGrowthX:SetLabel("Growth Direction X")
            BuffGrowthX:SetList(GrowthX)
            BuffGrowthX:SetValue(Buffs.GrowthX)
            BuffGrowthX:SetCallback("OnValueChanged", function(widget, event, value) Buffs.GrowthX = value UUF:UpdateFrames() end)
            BuffGrowthX:SetRelativeWidth(0.5)
            BuffOptions:AddChild(BuffGrowthX)
    
            local BuffGrowthY = UUFGUI:Create("Dropdown")
            BuffGrowthY:SetLabel("Growth Direction Y")
            BuffGrowthY:SetList(GrowthY)
            BuffGrowthY:SetValue(Buffs.GrowthY)
            BuffGrowthY:SetCallback("OnValueChanged", function(widget, event, value) Buffs.GrowthY = value UUF:UpdateFrames() end)
            BuffGrowthY:SetRelativeWidth(0.5)
            BuffOptions:AddChild(BuffGrowthY)

            local BuffSize = UUFGUI:Create("Slider")
            BuffSize:SetLabel("Size")
            BuffSize:SetSliderValues(-1, 64, 1)
            BuffSize:SetValue(Buffs.Size)
            BuffSize:SetCallback("OnMouseUp", function(widget, event, value) Buffs.Size = value UUF:UpdateFrames() end)
            BuffSize:SetRelativeWidth(0.33)
            BuffOptions:AddChild(BuffSize)

            local BuffSpacing = UUFGUI:Create("Slider")
            BuffSpacing:SetLabel("Spacing")
            BuffSpacing:SetSliderValues(-1, 64, 1)
            BuffSpacing:SetValue(Buffs.Spacing)
            BuffSpacing:SetCallback("OnMouseUp", function(widget, event, value) Buffs.Spacing = value UUF:UpdateFrames() end)
            BuffSpacing:SetRelativeWidth(0.33)
            BuffOptions:AddChild(BuffSpacing)

            local BuffNum = UUFGUI:Create("Slider")
            BuffNum:SetLabel("Amount To Show")
            BuffNum:SetSliderValues(1, 64, 1)
            BuffNum:SetValue(Buffs.Num)
            BuffNum:SetCallback("OnMouseUp", function(widget, event, value) Buffs.Num = value UUF:UpdateFrames() end)
            BuffNum:SetRelativeWidth(0.33)
            BuffOptions:AddChild(BuffNum)
    
            local BuffXOffset = UUFGUI:Create("Slider")
            BuffXOffset:SetLabel("Buff X Offset")
            BuffXOffset:SetSliderValues(-64, 64, 1)
            BuffXOffset:SetValue(Buffs.XOffset)
            BuffXOffset:SetCallback("OnMouseUp", function(widget, event, value) Buffs.XOffset = value UUF:UpdateFrames() end)
            BuffXOffset:SetRelativeWidth(0.5)
            BuffOptions:AddChild(BuffXOffset)
    
            local BuffYOffset = UUFGUI:Create("Slider")
            BuffYOffset:SetLabel("Buff Y Offset")
            BuffYOffset:SetSliderValues(-64, 64, 1)
            BuffYOffset:SetValue(Buffs.YOffset)
            BuffYOffset:SetCallback("OnMouseUp", function(widget, event, value) Buffs.YOffset = value UUF:UpdateFrames() end)
            BuffYOffset:SetRelativeWidth(0.5)
            BuffOptions:AddChild(BuffYOffset)

            local BuffCountOptions = UUFGUI:Create("InlineGroup")
            BuffCountOptions:SetTitle("Buff Count Options")
            BuffCountOptions:SetLayout("Flow")
            BuffCountOptions:SetFullWidth(true)
            BuffOptions:AddChild(BuffCountOptions)

            local BuffCountAnchorFrom = UUFGUI:Create("Dropdown")
            BuffCountAnchorFrom:SetLabel("Anchor From")
            BuffCountAnchorFrom:SetList(AnchorPoints)
            BuffCountAnchorFrom:SetValue(Buffs.Count.AnchorFrom)
            BuffCountAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) Buffs.Count.AnchorFrom = value UUF:UpdateFrames() end)
            BuffCountAnchorFrom:SetRelativeWidth(0.5)
            BuffCountOptions:AddChild(BuffCountAnchorFrom)

            local BuffCountAnchorTo = UUFGUI:Create("Dropdown")
            BuffCountAnchorTo:SetLabel("Anchor To")
            BuffCountAnchorTo:SetList(AnchorPoints)
            BuffCountAnchorTo:SetValue(Buffs.Count.AnchorTo)
            BuffCountAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) Buffs.Count.AnchorTo = value UUF:UpdateFrames() end)
            BuffCountAnchorTo:SetRelativeWidth(0.5)
            BuffCountOptions:AddChild(BuffCountAnchorTo)

            local BuffCountXOffset = UUFGUI:Create("Slider")
            BuffCountXOffset:SetLabel("Buff Count X Offset")
            BuffCountXOffset:SetSliderValues(-64, 64, 1)
            BuffCountXOffset:SetValue(Buffs.Count.XOffset)
            BuffCountXOffset:SetCallback("OnMouseUp", function(widget, event, value) Buffs.Count.XOffset = value UUF:UpdateFrames() end)
            BuffCountXOffset:SetRelativeWidth(0.25)
            BuffCountOptions:AddChild(BuffCountXOffset)

            local BuffCountYOffset = UUFGUI:Create("Slider")
            BuffCountYOffset:SetLabel("Buff Count Y Offset")
            BuffCountYOffset:SetSliderValues(-64, 64, 1)
            BuffCountYOffset:SetValue(Buffs.Count.YOffset)
            BuffCountYOffset:SetCallback("OnMouseUp", function(widget, event, value) Buffs.Count.YOffset = value UUF:UpdateFrames() end)
            BuffCountYOffset:SetRelativeWidth(0.25)
            BuffCountOptions:AddChild(BuffCountYOffset)

            local BuffCountFontSize = UUFGUI:Create("Slider")
            BuffCountFontSize:SetLabel("Font Size")
            BuffCountFontSize:SetSliderValues(1, 64, 1)
            BuffCountFontSize:SetValue(Buffs.Count.FontSize)
            BuffCountFontSize:SetCallback("OnMouseUp", function(widget, event, value) Buffs.Count.FontSize = value UUF:UpdateFrames() end)
            BuffCountFontSize:SetRelativeWidth(0.25)
            BuffCountOptions:AddChild(BuffCountFontSize)

            local BuffCountColour = UUFGUI:Create("ColorPicker")
            BuffCountColour:SetLabel("Colour")
            local BCR, BCG, BCB, BCA = unpack(Buffs.Count.Colour)
            BuffCountColour:SetColor(BCR, BCG, BCB, BCA)
            BuffCountColour:SetCallback("OnValueChanged", function(widget, _, r, g, b, a) Buffs.Count.Colour = {r, g, b, a} UUF:UpdateFrames() end)
            BuffCountColour:SetHasAlpha(true)
            BuffCountColour:SetRelativeWidth(0.25)
            BuffCountOptions:AddChild(BuffCountColour)
        end

        local function DrawDebuffsContainer(UUFGUI_Container)
            local DebuffOptions = UUFGUI:Create("InlineGroup")
            DebuffOptions:SetTitle("Debuff Options")
            DebuffOptions:SetLayout("Flow")
            DebuffOptions:SetFullWidth(true)
            UUFGUI_Container:AddChild(DebuffOptions)
    
            local DebuffsEnabled = UUFGUI:Create("CheckBox")
            DebuffsEnabled:SetLabel("Enable Debuffs")
            DebuffsEnabled:SetValue(Debuffs.Enabled)
            DebuffsEnabled:SetCallback("OnValueChanged", function(widget, event, value) Debuffs.Enabled = value UUF:CreateReloadPrompt() end)
            DebuffsEnabled:SetRelativeWidth(0.5)
            DebuffOptions:AddChild(DebuffsEnabled)

            local OnlyShowPlayerDebuffs = UUFGUI:Create("CheckBox")
            OnlyShowPlayerDebuffs:SetLabel("Only Show Player Debuffs")
            OnlyShowPlayerDebuffs:SetValue(Debuffs.OnlyShowPlayer)
            OnlyShowPlayerDebuffs:SetCallback("OnValueChanged", function(widget, event, value) Debuffs.OnlyShowPlayer = value UUF:UpdateFrames() end)
            OnlyShowPlayerDebuffs:SetRelativeWidth(0.5)
            DebuffOptions:AddChild(OnlyShowPlayerDebuffs)

            local DebuffAnchorFrom = UUFGUI:Create("Dropdown")
            DebuffAnchorFrom:SetLabel("Anchor From")
            DebuffAnchorFrom:SetList(AnchorPoints)
            DebuffAnchorFrom:SetValue(Debuffs.AnchorFrom)
            DebuffAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) Debuffs.AnchorFrom = value UUF:UpdateFrames() end)
            DebuffAnchorFrom:SetRelativeWidth(0.5)
            DebuffOptions:AddChild(DebuffAnchorFrom)
    
            local DebuffAnchorTo = UUFGUI:Create("Dropdown")
            DebuffAnchorTo:SetLabel("Anchor To")
            DebuffAnchorTo:SetList(AnchorPoints)
            DebuffAnchorTo:SetValue(Debuffs.AnchorTo)
            DebuffAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) Debuffs.AnchorTo = value UUF:UpdateFrames() end)
            DebuffAnchorTo:SetRelativeWidth(0.5)
            DebuffOptions:AddChild(DebuffAnchorTo)
    
            local DebuffGrowthX = UUFGUI:Create("Dropdown")
            DebuffGrowthX:SetLabel("Growth Direction X")
            DebuffGrowthX:SetList(GrowthX)
            DebuffGrowthX:SetValue(Debuffs.GrowthX)
            DebuffGrowthX:SetCallback("OnValueChanged", function(widget, event, value) Debuffs.GrowthX = value UUF:UpdateFrames() end)
            DebuffGrowthX:SetRelativeWidth(0.5)
            DebuffOptions:AddChild(DebuffGrowthX)
    
            local DebuffGrowthY = UUFGUI:Create("Dropdown")
            DebuffGrowthY:SetLabel("Growth Direction Y")
            DebuffGrowthY:SetList(GrowthY)
            DebuffGrowthY:SetValue(Debuffs.GrowthY)
            DebuffGrowthY:SetCallback("OnValueChanged", function(widget, event, value) Debuffs.GrowthY = value UUF:UpdateFrames() end)
            DebuffGrowthY:SetRelativeWidth(0.5)
            DebuffOptions:AddChild(DebuffGrowthY)

            local DebuffSize = UUFGUI:Create("Slider")
            DebuffSize:SetLabel("Size")
            DebuffSize:SetSliderValues(-1, 64, 1)
            DebuffSize:SetValue(Debuffs.Size)
            DebuffSize:SetCallback("OnMouseUp", function(widget, event, value) Debuffs.Size = value UUF:UpdateFrames() end)
            DebuffSize:SetRelativeWidth(0.33)
            DebuffOptions:AddChild(DebuffSize)

            local DebuffSpacing = UUFGUI:Create("Slider")
            DebuffSpacing:SetLabel("Spacing")
            DebuffSpacing:SetSliderValues(-1, 64, 1)
            DebuffSpacing:SetValue(Debuffs.Spacing)
            DebuffSpacing:SetCallback("OnMouseUp", function(widget, event, value) Debuffs.Spacing = value UUF:UpdateFrames() end)
            DebuffSpacing:SetRelativeWidth(0.33)
            DebuffOptions:AddChild(DebuffSpacing)

            local DebuffNum = UUFGUI:Create("Slider")
            DebuffNum:SetLabel("Amount To Show")
            DebuffNum:SetSliderValues(1, 64, 1)
            DebuffNum:SetValue(Debuffs.Num)
            DebuffNum:SetCallback("OnMouseUp", function(widget, event, value) Debuffs.Num = value UUF:UpdateFrames() end)
            DebuffNum:SetRelativeWidth(0.33)
            DebuffOptions:AddChild(DebuffNum)
    
            local DebuffXOffset = UUFGUI:Create("Slider")
            DebuffXOffset:SetLabel("Debuff X Offset")
            DebuffXOffset:SetSliderValues(-64, 64, 1)
            DebuffXOffset:SetValue(Debuffs.XOffset)
            DebuffXOffset:SetCallback("OnMouseUp", function(widget, event, value) Debuffs.XOffset = value UUF:UpdateFrames() end)
            DebuffXOffset:SetRelativeWidth(0.5)
            DebuffOptions:AddChild(DebuffXOffset)
    
            local DebuffYOffset = UUFGUI:Create("Slider")
            DebuffYOffset:SetLabel("Debuff Y Offset")
            DebuffYOffset:SetSliderValues(-64, 64, 1)
            DebuffYOffset:SetValue(Debuffs.YOffset)
            DebuffYOffset:SetCallback("OnMouseUp", function(widget, event, value) Debuffs.YOffset = value UUF:UpdateFrames() end)
            DebuffYOffset:SetRelativeWidth(0.5)
            DebuffOptions:AddChild(DebuffYOffset)

            local DebuffCountOptions = UUFGUI:Create("InlineGroup")
            DebuffCountOptions:SetTitle("Buff Count Options")
            DebuffCountOptions:SetLayout("Flow")
            DebuffCountOptions:SetFullWidth(true)
            DebuffOptions:AddChild(DebuffCountOptions)

            local DebuffCountAnchorFrom = UUFGUI:Create("Dropdown")
            DebuffCountAnchorFrom:SetLabel("Anchor From")
            DebuffCountAnchorFrom:SetList(AnchorPoints)
            DebuffCountAnchorFrom:SetValue(Debuffs.Count.AnchorFrom)
            DebuffCountAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) Debuffs.Count.AnchorFrom = value UUF:UpdateFrames() end)
            DebuffCountAnchorFrom:SetRelativeWidth(0.5)
            DebuffCountOptions:AddChild(DebuffCountAnchorFrom)

            local DebuffCountAnchorTo = UUFGUI:Create("Dropdown")
            DebuffCountAnchorTo:SetLabel("Anchor To")
            DebuffCountAnchorTo:SetList(AnchorPoints)
            DebuffCountAnchorTo:SetValue(Debuffs.Count.AnchorTo)
            DebuffCountAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) Debuffs.Count.AnchorTo = value UUF:UpdateFrames() end)
            DebuffCountAnchorTo:SetRelativeWidth(0.5)
            DebuffCountOptions:AddChild(DebuffCountAnchorTo)

            local DebuffCountXOffset = UUFGUI:Create("Slider")
            DebuffCountXOffset:SetLabel("Buff Count X Offset")
            DebuffCountXOffset:SetSliderValues(-64, 64, 1)
            DebuffCountXOffset:SetValue(Debuffs.Count.XOffset)
            DebuffCountXOffset:SetCallback("OnMouseUp", function(widget, event, value) Debuffs.Count.XOffset = value UUF:UpdateFrames() end)
            DebuffCountXOffset:SetRelativeWidth(0.25)
            DebuffCountOptions:AddChild(DebuffCountXOffset)

            local DebuffCountYOffset = UUFGUI:Create("Slider")
            DebuffCountYOffset:SetLabel("Buff Count Y Offset")
            DebuffCountYOffset:SetSliderValues(-64, 64, 1)
            DebuffCountYOffset:SetValue(Debuffs.Count.YOffset)
            DebuffCountYOffset:SetCallback("OnMouseUp", function(widget, event, value) Debuffs.Count.YOffset = value UUF:UpdateFrames() end)
            DebuffCountYOffset:SetRelativeWidth(0.25)
            DebuffCountOptions:AddChild(DebuffCountYOffset)

            local DebuffCountFontSize = UUFGUI:Create("Slider")
            DebuffCountFontSize:SetLabel("Font Size")
            DebuffCountFontSize:SetSliderValues(1, 64, 1)
            DebuffCountFontSize:SetValue(Debuffs.Count.FontSize)
            DebuffCountFontSize:SetCallback("OnMouseUp", function(widget, event, value) Debuffs.Count.FontSize = value UUF:UpdateFrames() end)
            DebuffCountFontSize:SetRelativeWidth(0.25)
            DebuffCountOptions:AddChild(DebuffCountFontSize)

            local DebuffCountColour = UUFGUI:Create("ColorPicker")
            DebuffCountColour:SetLabel("Colour")
            local DCR, DCG, DCB, DCA = unpack(Debuffs.Count.Colour)
            DebuffCountColour:SetColor(DCR, DCG, DCB, DCA)
            DebuffCountColour:SetCallback("OnValueChanged", function(widget, _, r, g, b, a) Debuffs.Count.Colour = {r, g, b, a} UUF:UpdateFrames() end)
            DebuffCountColour:SetHasAlpha(true)
            DebuffCountColour:SetRelativeWidth(0.25)
            DebuffCountOptions:AddChild(DebuffCountColour)
        end

        local function DrawIndicatorContainer(UUFGUI_Container)
            local IndicatorOptions = UUFGUI:Create("InlineGroup")
            IndicatorOptions:SetTitle("Indicator Options")
            IndicatorOptions:SetLayout("Flow")
            IndicatorOptions:SetFullWidth(true)
            UUFGUI_Container:AddChild(IndicatorOptions)

            local TargetMarkerOptions = UUFGUI:Create("InlineGroup")
            TargetMarkerOptions:SetTitle("Target Marker Options")
            TargetMarkerOptions:SetLayout("Flow")
            TargetMarkerOptions:SetFullWidth(true)
            IndicatorOptions:AddChild(TargetMarkerOptions)

            local TargetMarkerEnabled = UUFGUI:Create("CheckBox")
            TargetMarkerEnabled:SetLabel("Enable Target Marker")
            TargetMarkerEnabled:SetValue(TargetMarker.Enabled)
            TargetMarkerEnabled:SetCallback("OnValueChanged", function(widget, event, value) TargetMarker.Enabled = value UUF:CreateReloadPrompt() end)
            TargetMarkerEnabled:SetFullWidth(true)
            TargetMarkerOptions:AddChild(TargetMarkerEnabled)

            local TargetMarkerAnchorFrom = UUFGUI:Create("Dropdown")
            TargetMarkerAnchorFrom:SetLabel("Anchor From")
            TargetMarkerAnchorFrom:SetList(AnchorPoints)
            TargetMarkerAnchorFrom:SetValue(TargetMarker.AnchorFrom)
            TargetMarkerAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) TargetMarker.AnchorFrom = value UUF:UpdateFrames() end)
            TargetMarkerAnchorFrom:SetRelativeWidth(0.5)
            TargetMarkerOptions:AddChild(TargetMarkerAnchorFrom)

            local TargetMarkerAnchorTo = UUFGUI:Create("Dropdown")
            TargetMarkerAnchorTo:SetLabel("Anchor To")
            TargetMarkerAnchorTo:SetList(AnchorPoints)
            TargetMarkerAnchorTo:SetValue(TargetMarker.AnchorTo)
            TargetMarkerAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) TargetMarker.AnchorTo = value UUF:UpdateFrames() end)
            TargetMarkerAnchorTo:SetRelativeWidth(0.5)
            TargetMarkerOptions:AddChild(TargetMarkerAnchorTo)

            local TargetMarkerSize = UUFGUI:Create("Slider")
            TargetMarkerSize:SetLabel("Size")
            TargetMarkerSize:SetSliderValues(-1, 64, 1)
            TargetMarkerSize:SetValue(TargetMarker.Size)
            TargetMarkerSize:SetCallback("OnMouseUp", function(widget, event, value) TargetMarker.Size = value UUF:UpdateFrames() end)
            TargetMarkerSize:SetRelativeWidth(0.33)
            TargetMarkerOptions:AddChild(TargetMarkerSize)

            local TargetMarkerXOffset = UUFGUI:Create("Slider")
            TargetMarkerXOffset:SetLabel("X Offset")
            TargetMarkerXOffset:SetSliderValues(-64, 64, 1)
            TargetMarkerXOffset:SetValue(TargetMarker.XOffset)
            TargetMarkerXOffset:SetCallback("OnMouseUp", function(widget, event, value) TargetMarker.XOffset = value UUF:UpdateFrames() end)
            TargetMarkerXOffset:SetRelativeWidth(0.33)
            TargetMarkerOptions:AddChild(TargetMarkerXOffset)

            local TargetMarkerYOffset = UUFGUI:Create("Slider")
            TargetMarkerYOffset:SetLabel("Y Offset")
            TargetMarkerYOffset:SetSliderValues(-64, 64, 1)
            TargetMarkerYOffset:SetValue(TargetMarker.YOffset)
            TargetMarkerYOffset:SetCallback("OnMouseUp", function(widget, event, value) TargetMarker.YOffset = value UUF:UpdateFrames() end)
            TargetMarkerYOffset:SetRelativeWidth(0.33)
            TargetMarkerOptions:AddChild(TargetMarkerYOffset)

            if Unit == "Player" then
                local CombatIndicatorOptions = UUFGUI:Create("InlineGroup")
                CombatIndicatorOptions:SetTitle("Combat Indicator Options")
                CombatIndicatorOptions:SetLayout("Flow")
                CombatIndicatorOptions:SetFullWidth(true)
                IndicatorOptions:AddChild(CombatIndicatorOptions)

                local CombatIndicatorEnabled = UUFGUI:Create("CheckBox")
                CombatIndicatorEnabled:SetLabel("Enable Combat Indicator")
                CombatIndicatorEnabled:SetValue(CombatIndicator.Enabled)
                CombatIndicatorEnabled:SetCallback("OnValueChanged", function(widget, event, value) CombatIndicator.Enabled = value UUF:CreateReloadPrompt() end)
                CombatIndicatorEnabled:SetRelativeWidth(1)
                CombatIndicatorOptions:AddChild(CombatIndicatorEnabled)

                local CombatIndicatorAnchorFrom = UUFGUI:Create("Dropdown")
                CombatIndicatorAnchorFrom:SetLabel("Anchor From")
                CombatIndicatorAnchorFrom:SetList(AnchorPoints)
                CombatIndicatorAnchorFrom:SetValue(CombatIndicator.AnchorFrom)
                CombatIndicatorAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) CombatIndicator.AnchorFrom = value UUF:UpdateFrames() end)
                CombatIndicatorAnchorFrom:SetRelativeWidth(0.5)
                CombatIndicatorOptions:AddChild(CombatIndicatorAnchorFrom)

                local CombatIndicatorAnchorTo = UUFGUI:Create("Dropdown")
                CombatIndicatorAnchorTo:SetLabel("Anchor To")
                CombatIndicatorAnchorTo:SetList(AnchorPoints)
                CombatIndicatorAnchorTo:SetValue(CombatIndicator.AnchorTo)
                CombatIndicatorAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) CombatIndicator.AnchorTo = value UUF:UpdateFrames() end)
                CombatIndicatorAnchorTo:SetRelativeWidth(0.5)
                CombatIndicatorOptions:AddChild(CombatIndicatorAnchorTo)

                local CombatIndicatorSize = UUFGUI:Create("Slider")
                CombatIndicatorSize:SetLabel("Size")
                CombatIndicatorSize:SetSliderValues(-1, 64, 1)
                CombatIndicatorSize:SetValue(CombatIndicator.Size)
                CombatIndicatorSize:SetCallback("OnMouseUp", function(widget, event, value) CombatIndicator.Size = value UUF:UpdateFrames() end)
                CombatIndicatorSize:SetRelativeWidth(0.33)
                CombatIndicatorOptions:AddChild(CombatIndicatorSize)

                local CombatIndicatorXOffset = UUFGUI:Create("Slider")
                CombatIndicatorXOffset:SetLabel("X Offset")
                CombatIndicatorXOffset:SetSliderValues(-64, 64, 1)
                CombatIndicatorXOffset:SetValue(CombatIndicator.XOffset)
                CombatIndicatorXOffset:SetCallback("OnMouseUp", function(widget, event, value) CombatIndicator.XOffset = value UUF:UpdateFrames() end)
                CombatIndicatorXOffset:SetRelativeWidth(0.33)
                CombatIndicatorOptions:AddChild(CombatIndicatorXOffset)

                local CombatIndicatorYOffset = UUFGUI:Create("Slider")
                CombatIndicatorYOffset:SetLabel("Y Offset")
                CombatIndicatorYOffset:SetSliderValues(-64, 64, 1)
                CombatIndicatorYOffset:SetValue(CombatIndicator.YOffset)
                CombatIndicatorYOffset:SetCallback("OnMouseUp", function(widget, event, value) CombatIndicator.YOffset = value UUF:UpdateFrames() end)
                CombatIndicatorYOffset:SetRelativeWidth(0.33)
                CombatIndicatorOptions:AddChild(CombatIndicatorYOffset)
                
                -- Leader Indicator
                local LeaderIndicatorOptions = UUFGUI:Create("InlineGroup")
                LeaderIndicatorOptions:SetTitle("Leader Indicator Options")
                LeaderIndicatorOptions:SetLayout("Flow")
                LeaderIndicatorOptions:SetFullWidth(true)
                IndicatorOptions:AddChild(LeaderIndicatorOptions)

                local LeaderIndicatorEnabled = UUFGUI:Create("CheckBox")
                LeaderIndicatorEnabled:SetLabel("Enable Leader Indicator")
                LeaderIndicatorEnabled:SetValue(LeaderIndicator.Enabled)
                LeaderIndicatorEnabled:SetCallback("OnValueChanged", function(widget, event, value) LeaderIndicator.Enabled = value UUF:CreateReloadPrompt() end)
                LeaderIndicatorEnabled:SetRelativeWidth(1)
                LeaderIndicatorOptions:AddChild(LeaderIndicatorEnabled)

                local LeaderIndicatorAnchorFrom = UUFGUI:Create("Dropdown")
                LeaderIndicatorAnchorFrom:SetLabel("Anchor From")
                LeaderIndicatorAnchorFrom:SetList(AnchorPoints)
                LeaderIndicatorAnchorFrom:SetValue(LeaderIndicator.AnchorFrom)
                LeaderIndicatorAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) LeaderIndicator.AnchorFrom = value UUF:UpdateFrames() end)
                LeaderIndicatorAnchorFrom:SetRelativeWidth(0.5)
                LeaderIndicatorOptions:AddChild(LeaderIndicatorAnchorFrom)

                local LeaderIndicatorAnchorTo = UUFGUI:Create("Dropdown")
                LeaderIndicatorAnchorTo:SetLabel("Anchor To")
                LeaderIndicatorAnchorTo:SetList(AnchorPoints)
                LeaderIndicatorAnchorTo:SetValue(LeaderIndicator.AnchorTo)
                LeaderIndicatorAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) LeaderIndicator.AnchorTo = value UUF:UpdateFrames() end)
                LeaderIndicatorAnchorTo:SetRelativeWidth(0.5)
                LeaderIndicatorOptions:AddChild(LeaderIndicatorAnchorTo)

                local LeaderIndicatorSize = UUFGUI:Create("Slider")
                LeaderIndicatorSize:SetLabel("Size")
                LeaderIndicatorSize:SetSliderValues(-1, 64, 1)
                LeaderIndicatorSize:SetValue(LeaderIndicator.Size)
                LeaderIndicatorSize:SetCallback("OnMouseUp", function(widget, event, value) LeaderIndicator.Size = value UUF:UpdateFrames() end)
                LeaderIndicatorSize:SetRelativeWidth(0.33)
                LeaderIndicatorOptions:AddChild(LeaderIndicatorSize)

                local LeaderIndicatorXOffset = UUFGUI:Create("Slider")
                LeaderIndicatorXOffset:SetLabel("X Offset")
                LeaderIndicatorXOffset:SetSliderValues(-64, 64, 1)
                LeaderIndicatorXOffset:SetValue(LeaderIndicator.XOffset)
                LeaderIndicatorXOffset:SetCallback("OnMouseUp", function(widget, event, value) LeaderIndicator.XOffset = value UUF:UpdateFrames() end)
                LeaderIndicatorXOffset:SetRelativeWidth(0.33)
                LeaderIndicatorOptions:AddChild(LeaderIndicatorXOffset)

                local LeaderIndicatorYOffset = UUFGUI:Create("Slider")
                LeaderIndicatorYOffset:SetLabel("Y Offset")
                LeaderIndicatorYOffset:SetSliderValues(-64, 64, 1)
                LeaderIndicatorYOffset:SetValue(LeaderIndicator.YOffset)
                LeaderIndicatorYOffset:SetCallback("OnMouseUp", function(widget, event, value) LeaderIndicator.YOffset = value UUF:UpdateFrames() end)
                LeaderIndicatorYOffset:SetRelativeWidth(0.33)
                LeaderIndicatorOptions:AddChild(LeaderIndicatorYOffset)
            end

            if Unit == "Boss" then
                local TargetIndicatorOptions = UUFGUI:Create("InlineGroup")
                TargetIndicatorOptions:SetTitle("Combat Indicator Options")
                TargetIndicatorOptions:SetLayout("Flow")
                TargetIndicatorOptions:SetFullWidth(true)
                IndicatorOptions:AddChild(TargetIndicatorOptions)

                local TargetIndicatorEnabled = UUFGUI:Create("CheckBox")
                TargetIndicatorEnabled:SetLabel("Enable Target Indicator")
                TargetIndicatorEnabled:SetValue(TargetIndicator.Enabled)
                TargetIndicatorEnabled:SetCallback("OnValueChanged", function(widget, event, value) TargetIndicator.Enabled = value UUF:CreateReloadPrompt() end)
                TargetIndicatorEnabled:SetRelativeWidth(1)
                TargetIndicatorOptions:AddChild(TargetIndicatorEnabled)
            end
        end

        local function DrawTextsContainer(UUFGUI_Container)
            local TextOptions = UUFGUI:Create("InlineGroup")
            TextOptions:SetTitle("Text Options")
            TextOptions:SetLayout("Flow")
            TextOptions:SetFullWidth(true)
            UUFGUI_Container:AddChild(TextOptions)

            local FirstTextOptions = UUFGUI:Create("InlineGroup")
            FirstTextOptions:SetTitle("First Text Options")
            FirstTextOptions:SetLayout("Flow")
            FirstTextOptions:SetFullWidth(true)
            TextOptions:AddChild(FirstTextOptions)

            local FirstTextAnchorTo = UUFGUI:Create("Dropdown")
            FirstTextAnchorTo:SetLabel("Anchor From")
            FirstTextAnchorTo:SetList(AnchorPoints)
            FirstTextAnchorTo:SetValue(FirstText.AnchorFrom)
            FirstTextAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) FirstText.AnchorFrom = value UUF:UpdateFrames() end)
            FirstTextAnchorTo:SetRelativeWidth(0.5)
            FirstTextOptions:AddChild(FirstTextAnchorTo)

            local FirstTextAnchorFrom = UUFGUI:Create("Dropdown")
            FirstTextAnchorFrom:SetLabel("Anchor To")
            FirstTextAnchorFrom:SetList(AnchorPoints)
            FirstTextAnchorFrom:SetValue(FirstText.AnchorTo)
            FirstTextAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) FirstText.AnchorTo = value UUF:UpdateFrames() end)
            FirstTextAnchorFrom:SetRelativeWidth(0.5)
            FirstTextOptions:AddChild(FirstTextAnchorFrom)

            local FirstTextXOffset = UUFGUI:Create("Slider")
            FirstTextXOffset:SetLabel("X Offset")
            FirstTextXOffset:SetSliderValues(-64, 64, 1)
            FirstTextXOffset:SetValue(FirstText.XOffset)
            FirstTextXOffset:SetCallback("OnMouseUp", function(widget, event, value) FirstText.XOffset = value UUF:UpdateFrames() end)
            FirstTextXOffset:SetRelativeWidth(0.25)
            FirstTextOptions:AddChild(FirstTextXOffset)

            local FirstTextYOffset = UUFGUI:Create("Slider")
            FirstTextYOffset:SetLabel("Y Offset")
            FirstTextYOffset:SetSliderValues(-64, 64, 1)
            FirstTextYOffset:SetValue(FirstText.YOffset)
            FirstTextYOffset:SetCallback("OnMouseUp", function(widget, event, value) FirstText.YOffset = value UUF:UpdateFrames() end)
            FirstTextYOffset:SetRelativeWidth(0.25)
            FirstTextOptions:AddChild(FirstTextYOffset)

            local FirstTextFontSize = UUFGUI:Create("Slider")
            FirstTextFontSize:SetLabel("Font Size")
            FirstTextFontSize:SetSliderValues(1, 64, 1)
            FirstTextFontSize:SetValue(FirstText.FontSize)
            FirstTextFontSize:SetCallback("OnMouseUp", function(widget, event, value) FirstText.FontSize = value UUF:UpdateFrames() end)
            FirstTextFontSize:SetRelativeWidth(0.25)
            FirstTextOptions:AddChild(FirstTextFontSize)

            local FirstTextColourPicker = UUFGUI:Create("ColorPicker")
            FirstTextColourPicker:SetLabel("Colour")
            local FTR, FTG, FTB, FTA = unpack(FirstText.Colour)
            FirstTextColourPicker:SetColor(FTR, FTG, FTB, FTA)
            FirstTextColourPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a) FirstText.Colour = {r, g, b, a} UUF:UpdateFrames() end)
            FirstTextColourPicker:SetHasAlpha(true)
            FirstTextColourPicker:SetRelativeWidth(0.25)
            FirstTextOptions:AddChild(FirstTextColourPicker)

            local FirstTextTag = UUFGUI:Create("EditBox")
            FirstTextTag:SetLabel("Tag")
            FirstTextTag:SetText(FirstText.Tag)
            FirstTextTag:SetCallback("OnEnterPressed", function(widget, event, value) FirstText.Tag = value UUF:UpdateFrames() end)
            FirstTextTag:SetRelativeWidth(1)
            FirstTextOptions:AddChild(FirstTextTag)

            local SecondTextOptions = UUFGUI:Create("InlineGroup")
            SecondTextOptions:SetTitle("Second Text Options")
            SecondTextOptions:SetLayout("Flow")
            SecondTextOptions:SetFullWidth(true)
            TextOptions:AddChild(SecondTextOptions)

            local SecondTextAnchorTo = UUFGUI:Create("Dropdown")
            SecondTextAnchorTo:SetLabel("Anchor From")
            SecondTextAnchorTo:SetList(AnchorPoints)
            SecondTextAnchorTo:SetValue(SecondText.AnchorFrom)
            SecondTextAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) SecondText.AnchorFrom = value UUF:UpdateFrames() end)
            SecondTextAnchorTo:SetRelativeWidth(0.5)
            SecondTextOptions:AddChild(SecondTextAnchorTo)

            local SecondTextAnchorFrom = UUFGUI:Create("Dropdown")
            SecondTextAnchorFrom:SetLabel("Anchor To")
            SecondTextAnchorFrom:SetList(AnchorPoints)
            SecondTextAnchorFrom:SetValue(SecondText.AnchorTo)
            SecondTextAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) SecondText.AnchorTo = value UUF:UpdateFrames() end)
            SecondTextAnchorFrom:SetRelativeWidth(0.5)
            SecondTextOptions:AddChild(SecondTextAnchorFrom)

            local SecondTextXOffset = UUFGUI:Create("Slider")
            SecondTextXOffset:SetLabel("X Offset")
            SecondTextXOffset:SetSliderValues(-64, 64, 1)
            SecondTextXOffset:SetValue(SecondText.XOffset)
            SecondTextXOffset:SetCallback("OnMouseUp", function(widget, event, value) SecondText.XOffset = value UUF:UpdateFrames() end)
            SecondTextXOffset:SetRelativeWidth(0.25)
            SecondTextOptions:AddChild(SecondTextXOffset)

            local SecondTextYOffset = UUFGUI:Create("Slider")
            SecondTextYOffset:SetLabel("Y Offset")
            SecondTextYOffset:SetSliderValues(-64, 64, 1)
            SecondTextYOffset:SetValue(SecondText.YOffset)
            SecondTextYOffset:SetCallback("OnMouseUp", function(widget, event, value) SecondText.YOffset = value UUF:UpdateFrames() end)
            SecondTextYOffset:SetRelativeWidth(0.25)
            SecondTextOptions:AddChild(SecondTextYOffset)

            local SecondTextFontSize = UUFGUI:Create("Slider")
            SecondTextFontSize:SetLabel("Font Size")
            SecondTextFontSize:SetSliderValues(1, 64, 1)
            SecondTextFontSize:SetValue(SecondText.FontSize)
            SecondTextFontSize:SetCallback("OnMouseUp", function(widget, event, value) SecondText.FontSize = value UUF:UpdateFrames() end)
            SecondTextFontSize:SetRelativeWidth(0.25)
            SecondTextOptions:AddChild(SecondTextFontSize)

            local SecondTextColourPicker = UUFGUI:Create("ColorPicker")
            SecondTextColourPicker:SetLabel("Colour")
            local STR, STG, STB, STA = unpack(SecondText.Colour)
            SecondTextColourPicker:SetColor(STR, STG, STB, STA)
            SecondTextColourPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a) SecondText.Colour = {r, g, b, a} UUF:UpdateFrames() end)
            SecondTextColourPicker:SetHasAlpha(true)
            SecondTextColourPicker:SetRelativeWidth(0.25)
            SecondTextOptions:AddChild(SecondTextColourPicker)

            local SecondTextTag = UUFGUI:Create("EditBox")
            SecondTextTag:SetLabel("Tag")
            SecondTextTag:SetText(SecondText.Tag)
            SecondTextTag:SetCallback("OnEnterPressed", function(widget, event, value) SecondText.Tag = value UUF:UpdateFrames() end)
            SecondTextTag:SetRelativeWidth(1)
            SecondTextOptions:AddChild(SecondTextTag)

            local ThirdTextOptions = UUFGUI:Create("InlineGroup")
            ThirdTextOptions:SetTitle("Third Text Options")
            ThirdTextOptions:SetLayout("Flow")
            ThirdTextOptions:SetFullWidth(true)
            TextOptions:AddChild(ThirdTextOptions)

            local ThirdTextAnchorTo = UUFGUI:Create("Dropdown")
            ThirdTextAnchorTo:SetLabel("Anchor From")
            ThirdTextAnchorTo:SetList(AnchorPoints)
            ThirdTextAnchorTo:SetValue(ThirdText.AnchorFrom)
            ThirdTextAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) ThirdText.AnchorFrom = value UUF:UpdateFrames() end)
            ThirdTextAnchorTo:SetRelativeWidth(0.5)
            ThirdTextOptions:AddChild(ThirdTextAnchorTo)

            local ThirdTextAnchorFrom = UUFGUI:Create("Dropdown")
            ThirdTextAnchorFrom:SetLabel("Anchor To")
            ThirdTextAnchorFrom:SetList(AnchorPoints)
            ThirdTextAnchorFrom:SetValue(ThirdText.AnchorTo)
            ThirdTextAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) ThirdText.AnchorTo = value UUF:UpdateFrames() end)
            ThirdTextAnchorFrom:SetRelativeWidth(0.5)
            ThirdTextOptions:AddChild(ThirdTextAnchorFrom)

            local ThirdTextXOffset = UUFGUI:Create("Slider")
            ThirdTextXOffset:SetLabel("X Offset")
            ThirdTextXOffset:SetSliderValues(-64, 64, 1)
            ThirdTextXOffset:SetValue(ThirdText.XOffset)
            ThirdTextXOffset:SetCallback("OnMouseUp", function(widget, event, value) ThirdText.XOffset = value UUF:UpdateFrames() end)
            ThirdTextXOffset:SetRelativeWidth(0.25)
            ThirdTextOptions:AddChild(ThirdTextXOffset)

            local ThirdTextYOffset = UUFGUI:Create("Slider")
            ThirdTextYOffset:SetLabel("Y Offset")
            ThirdTextYOffset:SetSliderValues(-64, 64, 1)
            ThirdTextYOffset:SetValue(ThirdText.YOffset)
            ThirdTextYOffset:SetCallback("OnMouseUp", function(widget, event, value) ThirdText.YOffset = value UUF:UpdateFrames() end)
            ThirdTextYOffset:SetRelativeWidth(0.25)
            ThirdTextOptions:AddChild(ThirdTextYOffset)

            local ThirdTextFontSize = UUFGUI:Create("Slider")
            ThirdTextFontSize:SetLabel("Font Size")
            ThirdTextFontSize:SetSliderValues(1, 64, 1)
            ThirdTextFontSize:SetValue(ThirdText.FontSize)
            ThirdTextFontSize:SetCallback("OnMouseUp", function(widget, event, value) ThirdText.FontSize = value UUF:UpdateFrames() end)
            ThirdTextFontSize:SetRelativeWidth(0.25)
            ThirdTextOptions:AddChild(ThirdTextFontSize)

            local ThirdTextColourPicker = UUFGUI:Create("ColorPicker")
            ThirdTextColourPicker:SetLabel("Colour")
            local TRTR, TRTG, TRTB, TRTA = unpack(ThirdText.Colour)
            ThirdTextColourPicker:SetColor(TRTR, TRTG, TRTB, TRTA)
            ThirdTextColourPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a) ThirdText.Colour = {r, g, b, a} UUF:UpdateFrames() end)
            ThirdTextColourPicker:SetHasAlpha(true)
            ThirdTextColourPicker:SetRelativeWidth(0.25)
            ThirdTextOptions:AddChild(ThirdTextColourPicker)

            local ThirdTextTag = UUFGUI:Create("EditBox")
            ThirdTextTag:SetLabel("Tag")
            ThirdTextTag:SetText(ThirdText.Tag)
            ThirdTextTag:SetCallback("OnEnterPressed", function(widget, event, value) ThirdText.Tag = value UUF:UpdateFrames() end)
            ThirdTextTag:SetRelativeWidth(1)
            ThirdTextOptions:AddChild(ThirdTextTag)
            
        end

        local function DrawRangeContainer(UUFGUI_Container)
            local RangeOptions = UUFGUI:Create("InlineGroup")
            RangeOptions:SetTitle("Range Options")
            RangeOptions:SetLayout("Flow")
            RangeOptions:SetFullWidth(true)
            UUFGUI_Container:AddChild(RangeOptions)

            local RangeEnabled = UUFGUI:Create("CheckBox")
            RangeEnabled:SetLabel("Enable Range Indicator")
            RangeEnabled:SetValue(Range.Enable)
            RangeEnabled:SetCallback("OnValueChanged", function(widget, event, value) Range.Enable = value UUF:CreateReloadPrompt() end)
            RangeEnabled:SetFullWidth(true)
            RangeOptions:AddChild(RangeEnabled)

            local OOR = UUFGUI:Create("Slider")
            OOR:SetLabel("Out of Range Alpha")
            OOR:SetSliderValues(0, 1, 0.01)
            OOR:SetValue(Range.OOR)
            OOR:SetCallback("OnMouseUp", function(widget, event, value) Range.OOR = value UUF:UpdateFrames() end)
            OOR:SetRelativeWidth(0.5)
            RangeOptions:AddChild(OOR)

            local IR = UUFGUI:Create("Slider")
            IR:SetLabel("In Range Alpha")
            IR:SetSliderValues(0, 1, 0.01)
            IR:SetValue(Range.IR)
            IR:SetCallback("OnMouseUp", function(widget, event, value) Range.IR = value UUF:UpdateFrames() end)
            IR:SetRelativeWidth(0.5)
            RangeOptions:AddChild(IR)
        end

        local function SelectedGroup(UUFGUI_Container, Event, Group)
            UUFGUI_Container:ReleaseChildren()
            if Group == "Frame" then
                DrawFrameContainer(UUFGUI_Container)
            elseif Group == "Texts" then
                DrawTextsContainer(UUFGUI_Container)
            elseif Group == "Buffs" then
                DrawBuffsContainer(UUFGUI_Container)
            elseif Group == "Debuffs" then
                DrawDebuffsContainer(UUFGUI_Container)
            elseif Group == "Indicators" then
                DrawIndicatorContainer(UUFGUI_Container)
            elseif Unit ~= "player" and Group == "Range" then
                DrawRangeContainer(UUFGUI_Container)
            end
        end

        GUIContainerTabGroup = UUFGUI:Create("TabGroup")
        GUIContainerTabGroup:SetLayout("Flow")
        local ContainerTabs = {
            { text = "Frame",            value = "Frame" },
            { text = "Texts",            value = "Texts" },
            { text = "Buffs",            value = "Buffs" },
            { text = "Debuffs",          value = "Debuffs" },
            { text = "Indicators",       value = "Indicators" },
        }
        if Unit ~= "Player" then
            table.insert(ContainerTabs, { text = "Range", value = "Range" })
        end
        if not Frame.Enabled then
            for i = 1, #ContainerTabs do
                if ContainerTabs[i].value ~= "Frame" then
                    ContainerTabs[i].disabled = true
                end
            end
        end
        GUIContainerTabGroup:SetTabs(ContainerTabs)
        
        GUIContainerTabGroup:SetCallback("OnGroupSelected", SelectedGroup)
        GUIContainerTabGroup:SelectTab("Frame")
        GUIContainerTabGroup:SetFullWidth(true)
        ScrollableContainer:AddChild(GUIContainerTabGroup)
    end

    local function DrawTagsContainer(UUFGUI_Container)
        local ScrollableContainer = UUFGUI:Create("ScrollFrame")
        ScrollableContainer:SetLayout("Flow")
        ScrollableContainer:SetFullWidth(true)
        ScrollableContainer:SetFullHeight(true)
        UUFGUI_Container:AddChild(ScrollableContainer)

        local TagUpdateInterval = UUFGUI:Create("Slider")
        TagUpdateInterval:SetLabel("Tag Update Interval")
        TagUpdateInterval:SetSliderValues(0, 1, 0.1)
        TagUpdateInterval:SetValue(UUF.DB.global.TagUpdateInterval)
        TagUpdateInterval:SetCallback("OnMouseUp", function(widget, event, value) UUF.DB.global.TagUpdateInterval = value UUF:SetTagUpdateInterval() end)
        TagUpdateInterval:SetRelativeWidth(1)
        ScrollableContainer:AddChild(TagUpdateInterval)

        local function DrawHealthTagContainer(UUFGUI_Container)
            local HealthTags = UUF:FetchHealthTagDescriptions()

            local HealthTagOptions = UUFGUI:Create("InlineGroup")
            HealthTagOptions:SetTitle("Health Tags")
            HealthTagOptions:SetLayout("Flow")
            HealthTagOptions:SetFullWidth(true)
            UUFGUI_Container:AddChild(HealthTagOptions)

            for Title, TableData in pairs(HealthTags) do
                local Tag, Desc = TableData.Tag, TableData.Desc
                HealthTagTitle = UUFGUI:Create("Heading")
                HealthTagTitle:SetText(Title)
                HealthTagTitle:SetRelativeWidth(1)
                HealthTagOptions:AddChild(HealthTagTitle)

                local HealthTagTag = UUFGUI:Create("EditBox")
                HealthTagTag:SetText(Tag)
                HealthTagTag:SetCallback("OnEnterPressed", function(widget, event, value) return end)
                HealthTagTag:SetRelativeWidth(0.25)
                HealthTagOptions:AddChild(HealthTagTag)

                HealthTagDescription = UUFGUI:Create("EditBox")
                HealthTagDescription:SetText(Desc)
                HealthTagDescription:SetCallback("OnEnterPressed", function(widget, event, value) return end)
                HealthTagDescription:SetRelativeWidth(0.75)
                HealthTagOptions:AddChild(HealthTagDescription)
            end
        end

        local function DrawPowerTagsContainer(UUFGUI_Container)
            local PowerTags = UUF:FetchPowerTagDescriptions()

            local PowerTagOptions = UUFGUI:Create("InlineGroup")
            PowerTagOptions:SetTitle("Power Tags")
            PowerTagOptions:SetLayout("Flow")
            PowerTagOptions:SetFullWidth(true)
            UUFGUI_Container:AddChild(PowerTagOptions)

            for Title, TableData in pairs(PowerTags) do
                local Tag, Desc = TableData.Tag, TableData.Desc
                PowerTagTitle = UUFGUI:Create("Label")
                PowerTagTitle:SetText(Title)
                PowerTagTitle:SetRelativeWidth(1)
                PowerTagOptions:AddChild(PowerTagTitle)

                local PowerTagTag = UUFGUI:Create("EditBox")
                PowerTagTag:SetText(Tag)
                PowerTagTag:SetCallback("OnEnterPressed", function(widget, event, value) return end)
                PowerTagTag:SetRelativeWidth(0.3)
                PowerTagOptions:AddChild(PowerTagTag)

                PowerTagDescription = UUFGUI:Create("EditBox")
                PowerTagDescription:SetText(Desc)
                PowerTagDescription:SetCallback("OnEnterPressed", function(widget, event, value) return end)
                PowerTagDescription:SetRelativeWidth(0.7)
                PowerTagOptions:AddChild(PowerTagDescription)
            end
        end

        local function DrawNameTagsContainer(UUFGUI_Container)
            local NameTags = UUF:FetchNameTagDescriptions()

            local NameTagOptions = UUFGUI:Create("InlineGroup")
            NameTagOptions:SetTitle("Name Tags")
            NameTagOptions:SetLayout("Flow")
            NameTagOptions:SetFullWidth(true)
            UUFGUI_Container:AddChild(NameTagOptions)

            for Title, TableData in pairs(NameTags) do
                local Tag, Desc = TableData.Tag, TableData.Desc
                NameTagTitle = UUFGUI:Create("Heading")
                NameTagTitle:SetText(Title)
                NameTagTitle:SetRelativeWidth(1)
                NameTagOptions:AddChild(NameTagTitle)

                local NameTagTag = UUFGUI:Create("EditBox")
                NameTagTag:SetText(Tag)
                NameTagTag:SetCallback("OnEnterPressed", function(widget, event, value) return end)
                NameTagTag:SetRelativeWidth(0.3)
                NameTagOptions:AddChild(NameTagTag)

                NameTagDescription = UUFGUI:Create("EditBox")
                NameTagDescription:SetText(Desc)
                NameTagDescription:SetCallback("OnEnterPressed", function(widget, event, value) return end)
                NameTagDescription:SetRelativeWidth(0.7)
                NameTagOptions:AddChild(NameTagDescription)
            end
        end

        local function NSMediaTagsContainer(UUFGUI_Container)
            local NSMediaTags = UUF:FetchNSMediaTagDescriptions()

            local NSMediaTagOptions = UUFGUI:Create("InlineGroup")
            NSMediaTagOptions:SetTitle("Northern Sky Media Tags")
            NSMediaTagOptions:SetLayout("Flow")
            NSMediaTagOptions:SetFullWidth(true)
            UUFGUI_Container:AddChild(NSMediaTagOptions)

            for Title, TableData in pairs(NSMediaTags) do
                local Tag, Desc = TableData.Tag, TableData.Desc
                NSMediaTagTitle = UUFGUI:Create("Heading")
                NSMediaTagTitle:SetText(Title)
                NSMediaTagTitle:SetRelativeWidth(1)
                NSMediaTagOptions:AddChild(NSMediaTagTitle)

                local NSMediaTagTag = UUFGUI:Create("EditBox")
                NSMediaTagTag:SetText(Tag)
                NSMediaTagTag:SetCallback("OnEnterPressed", function(widget, event, value) return end)
                NSMediaTagTag:SetRelativeWidth(0.3)
                NSMediaTagOptions:AddChild(NSMediaTagTag)

                NSMediaTagDescription = UUFGUI:Create("EditBox")
                NSMediaTagDescription:SetText(Desc)
                NSMediaTagDescription:SetCallback("OnEnterPressed", function(widget, event, value) return end)
                NSMediaTagDescription:SetRelativeWidth(0.7)
                NSMediaTagOptions:AddChild(NSMediaTagDescription)
            end
        end

        local function DrawMiscTagsContainer(UUFGUI_Container)
            local MiscTags = UUF:FetchMiscTagDescriptions()

            local MiscTagOptions = UUFGUI:Create("InlineGroup")
            MiscTagOptions:SetTitle("Misc Tags")
            MiscTagOptions:SetLayout("Flow")
            MiscTagOptions:SetFullWidth(true)
            UUFGUI_Container:AddChild(MiscTagOptions)

            for Title, TableData in pairs(MiscTags) do
                local Tag, Desc = TableData.Tag, TableData.Desc
                MiscTagTitle = UUFGUI:Create("Heading")
                MiscTagTitle:SetText(Title)
                MiscTagTitle:SetRelativeWidth(1)
                MiscTagOptions:AddChild(MiscTagTitle)

                local MiscTagTag = UUFGUI:Create("EditBox")
                MiscTagTag:SetText(Tag)
                MiscTagTag:SetCallback("OnEnterPressed", function(widget, event, value) return end)
                MiscTagTag:SetRelativeWidth(0.3)
                MiscTagOptions:AddChild(MiscTagTag)

                MiscTagDescription = UUFGUI:Create("EditBox")
                MiscTagDescription:SetText(Desc)
                MiscTagDescription:SetCallback("OnEnterPressed", function(widget, event, value) return end)
                MiscTagDescription:SetRelativeWidth(0.7)
                MiscTagOptions:AddChild(MiscTagDescription)
            end
        end

        local function SelectedGroup(UUFGUI_Container, Event, Group)
            UUFGUI_Container:ReleaseChildren()
            if Group == "Health" then
                DrawHealthTagContainer(UUFGUI_Container)
            elseif Group == "Power" then
                DrawPowerTagsContainer(UUFGUI_Container)
            elseif Group == "Name" then
                DrawNameTagsContainer(UUFGUI_Container)
            elseif Group == "NSM" and NSM then
                NSMediaTagsContainer(UUFGUI_Container)
            elseif Group == "Misc" then
                DrawMiscTagsContainer(UUFGUI_Container)
            end
        end

        GUIContainerTabGroup = UUFGUI:Create("TabGroup")
        GUIContainerTabGroup:SetLayout("Flow")
        if NSM then
            GUIContainerTabGroup:SetTabs({
                { text = "Health",                              value = "Health"},
                { text = "Power",                               value = "Power" },
                { text = "Name",                                value = "Name" },
                { text = "Misc",                                value = "Misc" },
                { text = "Northern Sky Media",                  value = "NSM" },
            })
        else
            GUIContainerTabGroup:SetTabs({
                { text = "Health",                              value = "Health"},
                { text = "Power",                               value = "Power" },
                { text = "Name",                                value = "Name" },
                { text = "Misc",                                value = "Misc" },
            })
        end
        
        GUIContainerTabGroup:SetCallback("OnGroupSelected", SelectedGroup)
        GUIContainerTabGroup:SelectTab("Health")
        GUIContainerTabGroup:SetFullWidth(true)
        ScrollableContainer:AddChild(GUIContainerTabGroup)
    end

    local function DrawProfileContainer(UUFGUI_Container)
        local ScrollableContainer = UUFGUI:Create("ScrollFrame")
        ScrollableContainer:SetLayout("Flow")
        ScrollableContainer:SetFullWidth(true)
        ScrollableContainer:SetFullHeight(true)
        UUFGUI_Container:AddChild(ScrollableContainer)
    
        -- Profile Options Section
        local ProfileOptions = UUFGUI:Create("InlineGroup")
        ProfileOptions:SetTitle("Profile Options")
        ProfileOptions:SetLayout("Flow")
        ProfileOptions:SetFullWidth(true)
        ScrollableContainer:AddChild(ProfileOptions)
    
        local selectedProfile = nil
        local profileList = {}
        local profileKeys = {}
    
        for _, name in ipairs(UUF.DB:GetProfiles(profileList, true)) do
            profileKeys[name] = name
        end

        local NewProfileBox = UUFGUI:Create("EditBox")
        NewProfileBox:SetLabel("Create New Profile")
        NewProfileBox:SetFullWidth(true)
        NewProfileBox:SetCallback("OnEnterPressed", function(widget, event, text)
            if text ~= "" then
                UUF.DB:SetProfile(text)
                widget:SetText("")
            end
        end)
        ProfileOptions:AddChild(NewProfileBox)
    
        local ActiveProfileDropdown = UUFGUI:Create("Dropdown")
        ActiveProfileDropdown:SetLabel("Active Profile")
        ActiveProfileDropdown:SetList(profileKeys)
        ActiveProfileDropdown:SetValue(UUF.DB:GetCurrentProfile())
        ActiveProfileDropdown:SetCallback("OnValueChanged", function(widget, event, value) selectedProfile = value UUF.DB:SetProfile(value) UUF:UpdateFrames() end)
        ActiveProfileDropdown:SetRelativeWidth(0.33)
        ProfileOptions:AddChild(ActiveProfileDropdown)

        local CopyProfileDropdown = UUFGUI:Create("Dropdown")
        CopyProfileDropdown:SetLabel("Copy From Profile")
        CopyProfileDropdown:SetList(profileKeys)
        CopyProfileDropdown:SetCallback("OnValueChanged", function(widget, event, value) selectedProfile = value UUF.DB:CopyProfile(selectedProfile) end)
        CopyProfileDropdown:SetRelativeWidth(0.33)
        ProfileOptions:AddChild(CopyProfileDropdown)

        local DeleteProfileDropdown = UUFGUI:Create("Dropdown")
        DeleteProfileDropdown:SetLabel("Delete Profile")
        DeleteProfileDropdown:SetList(profileKeys)
        DeleteProfileDropdown:SetCallback("OnValueChanged", function(widget, event, value)
            selectedProfile = value
            if selectedProfile and selectedProfile ~= UUF.DB:GetCurrentProfile() then
                UUF.DB:DeleteProfile(selectedProfile)
                profileKeys = {}
                for _, name in ipairs(UUF.DB:GetProfiles(profileList, true)) do
                    profileKeys[name] = name
                end
                CopyProfileDropdown:SetList(profileKeys)
                DeleteProfileDropdown:SetList(profileKeys)
                ActiveProfileDropdown:SetList(profileKeys)
                DeleteProfileDropdown:SetValue(nil)
            else
                print("|cFF8080FFUnhalted Unit Frames|r: Unable to delete an active profile.")
            end
         end)
        DeleteProfileDropdown:SetRelativeWidth(0.33)
        ProfileOptions:AddChild(DeleteProfileDropdown)

        local SpecProfileContainer = UUFGUI:Create("InlineGroup")
        SpecProfileContainer:SetTitle("Specialization Profiles")
        SpecProfileContainer:SetLayout("Flow")
        SpecProfileContainer:SetFullWidth(true)
        ScrollableContainer:AddChild(SpecProfileContainer)

        local SpecProfileDropdown = {}
        local numSpecs = GetNumSpecializations()
        local SpecToggle = UUFGUI:Create("CheckBox")
        SpecToggle:SetLabel("Enable Specialization Profiles")
        SpecToggle:SetValue(UUF.DB:IsDualSpecEnabled())
        SpecToggle:SetCallback("OnValueChanged", function(widget, event, value)
            UUF.DB:SetDualSpecEnabled(value)
            for i = 1, numSpecs do
                SpecProfileDropdown[i]:SetDisabled(not value)
            end
        end)
        SpecToggle:SetRelativeWidth(1)
        local Disclaimer = "You will need to reload after swapping specializations for the specified profile to take effect.\nThis is specifically due to the way that elements are created."
        SpecToggle:SetCallback("OnEnter", function(widget, event, value) GameTooltip:SetOwner(widget.frame, "ANCHOR_TOPLEFT") GameTooltip:AddLine(Disclaimer) GameTooltip:Show() end)
        SpecToggle:SetCallback("OnLeave", function(widget, event, value) GameTooltip:Hide() end)
        SpecProfileContainer:AddChild(SpecToggle)

        for i = 1, numSpecs do
            local _, specName = GetSpecializationInfo(i)
            SpecProfileDropdown[i] = UUFGUI:Create("Dropdown")
            SpecProfileDropdown[i]:SetLabel(string.format("%s", specName or ("Spec %d"):format(i)))
            SpecProfileDropdown[i]:SetList(profileKeys)
            SpecProfileDropdown[i]:SetValue(UUF.DB:GetDualSpecProfile(i))
            SpecProfileDropdown[i]:SetCallback("OnValueChanged", function(widget, event, value) UUF.DB:SetDualSpecProfile(value, i) end)
            SpecProfileDropdown[i]:SetRelativeWidth(numSpecs == 2 and 0.5 or numSpecs == 3 and 0.33 or 0.25)
            SpecProfileDropdown[i]:SetDisabled(not UUF.DB:IsDualSpecEnabled())
            SpecProfileContainer:AddChild(SpecProfileDropdown[i])
        end

        local ResetToDefault = UUFGUI:Create("Button")
        ResetToDefault:SetText("Reset Settings (" .. UUF.DB:GetCurrentProfile() .. ")")
        ResetToDefault:SetCallback("OnClick", function(widget, event, value)
            StaticPopupDialogs["UUF_PROFILE_RESET"] = {
                text = "Do you want to reset the current profile to default? \nReload will happen automatically.",
                button1 = "Yes",
                button2 = "No",
                OnAccept = function() UUF:ResetDefaultSettings(false) ReloadUI() end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3,
            }
            StaticPopup_Show("UUF_PROFILE_RESET")
        end)
        ResetToDefault:SetRelativeWidth(1)
        ProfileOptions:AddChild(ResetToDefault)

        local ResetToDefaultAll = UUFGUI:Create("Button")
        ResetToDefaultAll:SetText("Reset Unhalted Unit Frames")
        ResetToDefaultAll:SetCallback("OnClick", function(widget, event, value)
            StaticPopupDialogs["UUF_PROFILE_RESET_ALL"] = {
                text = "Do you want to reset Unhalted Unit Frames to Default? \nReload will happen automatically.",
                button1 = "Yes",
                button2 = "No",
                OnAccept = function() UUF:ResetDefaultSettings(true) ReloadUI() end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3,
            }
            StaticPopup_Show("UUF_PROFILE_RESET_ALL")
        end)
        local ProfileDisclaimer = "This will reset all Unhalted Unit Frames settings to default.\nAll Profiles will be deleted\nAll Settings will be set to default."
        ResetToDefaultAll:SetCallback("OnEnter", function(widget, event, value) GameTooltip:SetOwner(widget.frame, "ANCHOR_TOPLEFT") GameTooltip:AddLine(ProfileDisclaimer) GameTooltip:Show() end)
        ResetToDefaultAll:SetCallback("OnLeave", function(widget, event, value) GameTooltip:Hide() end)
        ResetToDefaultAll:SetRelativeWidth(1)
        ProfileOptions:AddChild(ResetToDefaultAll)
    
        -- Sharing Options Section
        local SharingOptionsContainer = UUFGUI:Create("InlineGroup")
        SharingOptionsContainer:SetTitle("Sharing Options")
        SharingOptionsContainer:SetLayout("Flow")
        SharingOptionsContainer:SetFullWidth(true)
        ScrollableContainer:AddChild(SharingOptionsContainer)
    
        -- Import Section
        local ImportOptionsContainer = UUFGUI:Create("InlineGroup")
        ImportOptionsContainer:SetTitle("Import Options")
        ImportOptionsContainer:SetLayout("Flow")
        ImportOptionsContainer:SetFullWidth(true)
        SharingOptionsContainer:AddChild(ImportOptionsContainer)
    
        local ImportEditBox = UUFGUI:Create("MultiLineEditBox")
        ImportEditBox:SetLabel("Import String")
        ImportEditBox:SetNumLines(5)
        ImportEditBox:SetFullWidth(true)
        ImportEditBox:DisableButton(true)
        ImportOptionsContainer:AddChild(ImportEditBox)
    
        local ImportButton = UUFGUI:Create("Button")
        ImportButton:SetText("Import")
        ImportButton:SetCallback("OnClick", function()
            UUF:ImportSavedVariables(ImportEditBox:GetText())
            ImportEditBox:SetText("")
        end)
        ImportButton:SetRelativeWidth(1)
        ImportOptionsContainer:AddChild(ImportButton)
    
        -- Export Section
        local ExportOptionsContainer = UUFGUI:Create("InlineGroup")
        ExportOptionsContainer:SetTitle("Export Options")
        ExportOptionsContainer:SetLayout("Flow")
        ExportOptionsContainer:SetFullWidth(true)
        SharingOptionsContainer:AddChild(ExportOptionsContainer)
    
        local ExportEditBox = UUFGUI:Create("MultiLineEditBox")
        ExportEditBox:SetLabel("Export String")
        ExportEditBox:SetFullWidth(true)
        ExportEditBox:SetNumLines(5)
        ExportEditBox:DisableButton(true)
        ExportOptionsContainer:AddChild(ExportEditBox)
    
        local ExportButton = UUFGUI:Create("Button")
        ExportButton:SetText("Export")
        ExportButton:SetCallback("OnClick", function()
            ExportEditBox:SetText(UUF:ExportSavedVariables())
            ExportEditBox:HighlightText()
            ExportEditBox:SetFocus()
        end)
        ExportButton:SetRelativeWidth(1)
        ExportOptionsContainer:AddChild(ExportButton)
    end

    function SelectedGroup(UUFGUI_Container, Event, Group)
        UUFGUI_Container:ReleaseChildren()
        if Group == "General" then
            DrawGeneralContainer(UUFGUI_Container)
        elseif Group == "Filters" then
            DrawFiltersContainer(UUFGUI_Container)
        elseif Group == "Player" then
            DrawUnitContainer(UUFGUI_Container, Group)
        elseif Group == "Target" then
            DrawUnitContainer(UUFGUI_Container, Group)
        elseif Group == "TargetTarget" then
            DrawUnitContainer(UUFGUI_Container, Group)
        elseif Group == "Focus" then
            DrawUnitContainer(UUFGUI_Container, Group)
        elseif Group == "FocusTarget" then
            DrawUnitContainer(UUFGUI_Container, Group)
        elseif Group == "Pet" then
            DrawUnitContainer(UUFGUI_Container, Group)
        elseif Group == "Boss" then
            DrawUnitContainer(UUFGUI_Container, Group)
        elseif Group == "Tags" then
            DrawTagsContainer(UUFGUI_Container)
        elseif Group == "Profiles" then
            DrawProfileContainer(UUFGUI_Container)
        end
    end

    GUIContainerTabGroup = UUFGUI:Create("TabGroup")
    GUIContainerTabGroup:SetLayout("Flow")
    GUIContainerTabGroup:SetTabs({
        { text = "General",                         value = "General"},
        { text = "Filters",                         value = "Filters"},
        { text = "Player",                          value = "Player" },
        { text = "Target",                          value = "Target" },
        { text = "Boss",                            value = "Boss" },
        { text = "Target of Target",                value = "TargetTarget" },
        { text = "Focus",                           value = "Focus" },
        { text = "Focus Target",                    value = "FocusTarget" },
        { text = "Pet",                             value = "Pet" },
        { text = "Tags",                            value = "Tags" },
        { text = "Profiles",                        value = "Profiles" },
    })
    GUIContainerTabGroup:SetCallback("OnGroupSelected", SelectedGroup)
    GUIContainerTabGroup:SelectTab("General")
    UUFGUI_Container:AddChild(GUIContainerTabGroup)
end

function UUF:ReOpenGUI()
    if GUIActive and UUFGUI_Container then
        UUFGUI_Container:Hide()
        UUFGUI_Container:ReleaseChildren()
        UUF:CreateGUI()
    end
end

function UUFG.OpenUUFGUI()
    if not GUIActive then
        UUF:CreateGUI()
    elseif UUFGUI_Container then
        UUFGUI_Container:Show()
    end
end

function UUFG.CloseUUFGUI()
    if UUFGUI_Container then
        UUFGUI_Container:Hide()
    end
end
