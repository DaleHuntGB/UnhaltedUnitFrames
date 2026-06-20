local _, UUF = ...
local LSM = UUF.LSM
local AG = UUF.AG
local GUIWidgets = UUF.GUIWidgets
local UUFGUI = {}
local isGUIOpen = false
-- Stores last selected tabs: [unit] = { mainTab = "CastBar", subTabs = { CastBar = "Bar" } }
local lastSelectedUnitTabs = {}

local function SaveSubTab(unit, tabName, subTabValue)
    if not lastSelectedUnitTabs[unit] then lastSelectedUnitTabs[unit] = {} end
    if not lastSelectedUnitTabs[unit].subTabs then lastSelectedUnitTabs[unit].subTabs = {} end
    lastSelectedUnitTabs[unit].subTabs[tabName] = subTabValue
end

local function GetSavedSubTab(unit, tabName, defaultValue)
    return lastSelectedUnitTabs[unit] and lastSelectedUnitTabs[unit].subTabs and lastSelectedUnitTabs[unit].subTabs[tabName] or defaultValue
end

local function GetSavedMainTab(unit, defaultValue)
    return lastSelectedUnitTabs[unit] and lastSelectedUnitTabs[unit].mainTab or defaultValue
end

local UnitDBToUnitPrettyName = {
    player = "Player",
    target = "Target",
    targettarget = "Target of Target",
    focus = "Focus",
    focustarget = "Focus Target",
    pet = "Pet",
    boss = "Boss",
    party = "Party",
	raid = "Raid",
}

local function UpdateConfiguredUnit(unit, updateFunction, ...)
	if unit == "boss" then
		UUF:UpdateBossFrames()
	elseif unit == "party" then
		UUF:UpdatePartyFrames()
	elseif unit == "raid" then
		UUF:UpdateRaidFrames()
	else
		updateFunction(UUF, UUF[unit:upper()], unit, ...)
	end
end


local CooldownBreakpointStyles = {
    {
        decimalSeconds = "Decimal Seconds (1.1)",
        seconds = "Seconds (10s)",
        secondsOnly = "Seconds (10)",
        clock = "Clock (1:10)",
        minutes = "Minutes (2m)",
        hours = "Hours (1h)",
        days = "Days (1d)",
    },
    {"decimalSeconds", "seconds", "secondsOnly", "clock", "minutes", "hours", "days"},
}

local CooldownBreakpointSettings = {
    decimalSeconds = {step = 0.1, rounding = Enum.NumericRuleFormatRounding.Up, format = "%.1f"},
    seconds = {step = 1, rounding = Enum.NumericRuleFormatRounding.Up, format = "%ds"},
    secondsOnly = {step = 1, rounding = Enum.NumericRuleFormatRounding.Up, format = "%d"},
    clock = {step = 1, rounding = Enum.NumericRuleFormatRounding.Up, format = "%d:%02d"},
    minutes = {step = 1, rounding = Enum.NumericRuleFormatRounding.Up, format = "%dm"},
    hours = {step = 1, rounding = Enum.NumericRuleFormatRounding.Up, format = "%dh"},
    days = {step = 1, rounding = Enum.NumericRuleFormatRounding.Up, format = "%dd"},
}

local AnchorPoints = { { ["TOPLEFT"] = "Top Left", ["TOP"] = "Top", ["TOPRIGHT"] = "Top Right", ["LEFT"] = "Left", ["CENTER"] = "Center", ["RIGHT"] = "Right", ["BOTTOMLEFT"] = "Bottom Left", ["BOTTOM"] = "Bottom", ["BOTTOMRIGHT"] = "Bottom Right" }, { "TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "CENTER", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT", } }
local FrameStrataList = {{ ["BACKGROUND"] = "Background", ["LOW"] = "Low", ["MEDIUM"] = "Medium", ["HIGH"] = "High", ["DIALOG"] = "Dialog", ["FULLSCREEN"] = "Fullscreen", ["FULLSCREEN_DIALOG"] = "Fullscreen Dialog", ["TOOLTIP"] = "Tooltip" }, { "BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "FULLSCREEN", "FULLSCREEN_DIALOG", "TOOLTIP" }}
local TopBottomList = {{ ["TOP"] = "Top", ["BOTTOM"] = "Bottom" }, { "TOP", "BOTTOM" }}

local Power = {
    [0] = "Mana",
    [1] = "Rage",
    [2] = "Focus",
    [3] = "Energy",
    [4] = "Combo Points",
    [5] = "Runes",
    [6] = "Runic Power",
    [7] = "Soul Shards",
    [8] = "Astral Power",
    [9] = "Holy Power",
    [11] = "Maelstrom",
    [12] = "Chi",
    [13] = "Insanity",
    [17] = "Fury",
    [16] = "Arcange Charges",
    [18] = "Pain",
    [19] = "Essences",
}

local Reaction = {
    [1] = "Hated",
    [2] = "Hostile",
    [3] = "Unfriendly",
    [4] = "Neutral",
    [5] = "Friendly",
    [6] = "Honored",
    [7] = "Revered",
    [8] = "Exalted",
}

local StatusTextures = {
    Combat = {
        ["DEFAULT"] = "|TInterface\\CharacterFrame\\UI-StateIcon:20:20:0:0:64:64:32:64:0:31|t",
        ["COMBAT0"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat0.tga:18:18|t",
        ["COMBAT1"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat1.tga:18:18|t",
        ["COMBAT2"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat2.tga:18:18|t",
        ["COMBAT3"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat3.tga:18:18|t",
        ["COMBAT4"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat4.tga:18:18|t",
        ["COMBAT5"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat5.tga:18:18|t",
        ["COMBAT6"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat6.tga:18:18|t",
        ["COMBAT7"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat7.tga:18:18|t",
        ["COMBAT8"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat8.png:18:18|t",
    },

    Resting = {
        ["DEFAULT"] = "|TInterface\\CharacterFrame\\UI-StateIcon:18:18:0:0:64:64:0:32:0:27|t",
        ["RESTING0"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting0.tga:18:18|t",
        ["RESTING1"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting1.tga:18:18|t",
        ["RESTING2"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting2.tga:18:18|t",
        ["RESTING3"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting3.tga:18:18|t",
        ["RESTING4"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting4.tga:18:18|t",
        ["RESTING5"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting5.tga:18:18|t",
        ["RESTING6"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting6.tga:18:18|t",
        ["RESTING7"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting7.tga:18:18|t",
        ["RESTING8"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting8.png:18:18|t",
    }
}

local function EnableAurasTestMode(unit)
    UUF.AURA_TEST_MODE = true
    UUF:CreateTestAuras(UUF[unit:upper()], unit)
end

local function DisableAurasTestMode(unit)
    UUF.AURA_TEST_MODE = false
    UUF:CreateTestAuras(UUF[unit:upper()], unit)
end

local function EnableCastBarTestMode(unit)
    UUF.CASTBAR_TEST_MODE = true
    UUF:CreateTestCastBar(UUF[unit:upper()], unit)
end

local function DisableCastBarTestMode(unit)
    UUF.CASTBAR_TEST_MODE = false
    UUF:CreateTestCastBar(UUF[unit:upper()], unit)
end

local function EnableBossFramesTestMode()
    UUF.BOSS_TEST_MODE = true
    UUF:CreateTestBossFrames()
end

local function DisableBossFramesTestMode()
    UUF.BOSS_TEST_MODE = false
    UUF:CreateTestBossFrames()
end

local function DisableAllTestModes()
    UUF.AURA_TEST_MODE = false
    UUF.CASTBAR_TEST_MODE = false
    UUF.BOSS_TEST_MODE = false
    UUF.MOVERS_UNLOCKED = false
    for unit in pairs(UUF.db.profile.Units) do
        if unit ~= "party" and unit ~= "raid" and UUF[unit:upper()] then
            UUF:CreateTestAuras(UUF[unit:upper()], unit)
            UUF:CreateTestCastBar(UUF[unit:upper()], unit)
        end
    end
    UUF:CreateTestBossFrames()
    for _, frameMover in pairs(UUF.MOVERS or {}) do frameMover:Hide() end
end

local function GenerateSupportText(parentFrame)
    local SupportOptions = {
        -- "Support Me on |TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Support\\Ko-Fi.png:13:18|t |cFF8080FFKo-Fi|r!",
        -- "Support Me on |TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Support\\Patreon.png:14:14|t |cFF8080FFPatreon|r!",
        -- "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Support\\PayPal.png:20:18|t |cFF8080FFPayPal Donations|r are appreciated!",
        "Join the |TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Support\\Discord.png:18:18|t |cFF8080FFDiscord|r Community!",
        "Report Issues / Feedback on |TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Support\\GitHub.png:18:18|t |cFF8080FFGitHub|r!",
        "Follow Me on |TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Support\\Twitch.png:18:14|t |cFF8080FFTwitch|r!",
        "|cFF8080FFSupport|r is truly appreciated |TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Emotes\\peepoLove.png:18:18|t " .. "|cFF8080FFDevelopment|r takes time & effort."
    }
    parentFrame.statustext:SetText(SupportOptions[math.random(1, #SupportOptions)])
end

local function BuildMainNavigationTree()
    return {
        { text = "General", value = "General" },
        { text = "Global", value = "Global" },
        { text = "Cooldown Text", value = "CooldownText" },
        { text = "Player", value = "Player" },
        { text = "Target", value = "Target" },
        { text = "Target of Target", value = "TargetTarget" },
        { text = "Pet", value = "Pet" },
        { text = "Focus", value = "Focus" },
        { text = "Focus Target", value = "FocusTarget" },
        { text = "Boss", value = "Boss" },
        { text = "Party", value = "Party" },
		{ text = "Raid", value = "Raid" },
        { text = "Tags", value = "Tags" },
        { text = "Profiles", value = "Profiles" },
    }
end

local function CreateUIScaleSettings(containerParent)
    local Container = GUIWidgets.CreateInlineGroup(containerParent, "UI Scale")
    GUIWidgets.CreateInformationTag(Container,"These options allow you to adjust the UI Scale beyond the means that |cFF00B0F7Blizzard|r provides. If you encounter issues, please |cFFFF4040disable|r this feature.")

    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel("Enable UI Scale")
    Toggle:SetValue(UUF.db.profile.General.UIScale.Enabled)
    Toggle:SetFullWidth(true)
    Toggle:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.General.UIScale.Enabled = value UUF:SetUIScale() GUIWidgets.DeepDisable(Container, not value, Toggle) end)
    Toggle:SetRelativeWidth(0.5)
    Container:AddChild(Toggle)

    local Slider = AG:Create("Slider")
    Slider:SetLabel("UI Scale")
    Slider:SetValue(UUF.db.profile.General.UIScale.Scale)
    Slider:SetSliderValues(0.3, 1.5, 0.01)
    Slider:SetFullWidth(true)
    Slider:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.General.UIScale.Scale = value UUF:SetUIScale() end)
    Slider:SetRelativeWidth(0.5)
    Container:AddChild(Slider)

    GUIWidgets.CreateHeader(Container, "Presets")

    local PixelPerfectButton = AG:Create("Button")
    PixelPerfectButton:SetText("Pixel Perfect Scale")
    PixelPerfectButton:SetRelativeWidth(0.33)
    PixelPerfectButton:SetCallback("OnClick", function() local pixelScale = UUF:GetPixelPerfectScale() UUF.db.profile.General.UIScale.Scale = pixelScale UUF:SetUIScale() Slider:SetValue(pixelScale) end)
    PixelPerfectButton:SetCallback("OnEnter", function() GameTooltip:SetOwner(PixelPerfectButton.frame, "ANCHOR_CURSOR") GameTooltip:AddLine("Recommended UI Scale: |cFF8080FF" .. UUF:GetPixelPerfectScale() .. "|r", 1, 1, 1, false) GameTooltip:Show() end)
    PixelPerfectButton:SetCallback("OnLeave", function() GameTooltip:Hide() end)
    Container:AddChild(PixelPerfectButton)

    local TenEighytyPButton = AG:Create("Button")
    TenEighytyPButton:SetText("1080p Scale")
    TenEighytyPButton:SetRelativeWidth(0.33)
    TenEighytyPButton:SetCallback("OnClick", function() UUF.db.profile.General.UIScale.Scale = 0.7111111111111 UUF:SetUIScale() Slider:SetValue(0.7111111111111) end)
    TenEighytyPButton:SetCallback("OnEnter", function() GameTooltip:SetOwner(TenEighytyPButton.frame, "ANCHOR_CURSOR") GameTooltip:AddLine("UI Scale: |cFF8080FF0.7111111111111|r", 1, 1, 1, false) GameTooltip:Show() end)
    TenEighytyPButton:SetCallback("OnLeave", function() GameTooltip:Hide() end)
    Container:AddChild(TenEighytyPButton)

    local FourteenFortyPButton = AG:Create("Button")
    FourteenFortyPButton:SetText("1440p Scale")
    FourteenFortyPButton:SetRelativeWidth(0.33)
    FourteenFortyPButton:SetCallback("OnClick", function() UUF.db.profile.General.UIScale.Scale = 0.5333333333333 UUF:SetUIScale() Slider:SetValue(0.5333333333333) end)
    FourteenFortyPButton:SetCallback("OnEnter", function() GameTooltip:SetOwner(FourteenFortyPButton.frame, "ANCHOR_CURSOR") GameTooltip:AddLine("UI Scale: |cFF8080FF0.5333333333333|r", 1, 1, 1, false) GameTooltip:Show() end)
    FourteenFortyPButton:SetCallback("OnLeave", function() GameTooltip:Hide() end)
    Container:AddChild(FourteenFortyPButton)

    GUIWidgets.DeepDisable(Container, not UUF.db.profile.General.UIScale.Enabled, Toggle)
end

local function CreateFontSettings(containerParent)
    local Container = GUIWidgets.CreateInlineGroup(containerParent, "Fonts")

    GUIWidgets.CreateInformationTag(Container,"Fonts are applied to all Unit Frames & Elements where appropriate. More fonts can be added via |cFF8080FFSharedMedia|r.")

    local FontDropdown = AG:Create("LSM30_Font")
    FontDropdown:SetList(LSM:HashTable("font"))
    FontDropdown:SetLabel("Font")
    FontDropdown:SetValue(UUF.db.profile.General.Fonts.Font)
    FontDropdown:SetRelativeWidth(0.5)
    FontDropdown:SetCallback("OnValueChanged", function(widget, _, value) widget:SetValue(value) UUF.db.profile.General.Fonts.Font = value UUF:ResolveLSM() UUF:UpdateAllUnitFrames() end)
    Container:AddChild(FontDropdown)

    local FontFlagDropdown = AG:Create("Dropdown")
    FontFlagDropdown:SetList({[""] = "None", ["OUTLINE"] = "Outline", ["THICKOUTLINE"] = "Thick Outline", ["MONOCHROME"] = "Monochrome", ["MONOCHROMEOUTLINE"] = "Monochrome Outline", ["MONOCHROMETHICKOUTLINE"] = "Monochrome Thick Outline", ["OUTLINE, SLUG"] = "Outline Slug"})
    FontFlagDropdown:SetLabel("Font Flag")
    FontFlagDropdown:SetValue(UUF.db.profile.General.Fonts.FontFlag)
    FontFlagDropdown:SetRelativeWidth(0.5)
    FontFlagDropdown:SetCallback("OnValueChanged", function(widget, _, value) widget:SetValue(value) UUF.db.profile.General.Fonts.FontFlag = value UUF:ResolveLSM() UUF:UpdateAllUnitFrames() end)
    Container:AddChild(FontFlagDropdown)

    local SimpleGroup = AG:Create("SimpleGroup")
    SimpleGroup:SetFullWidth(true)
    SimpleGroup:SetLayout("Flow")
    Container:AddChild(SimpleGroup)

    GUIWidgets.CreateHeader(SimpleGroup, "Font Shadows")

    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel("Enable Font Shadows")
    Toggle:SetValue(UUF.db.profile.General.Fonts.Shadow.Enabled)
    Toggle:SetFullWidth(true)
    Toggle:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.General.Fonts.Shadow.Enabled = value UUF:ResolveLSM() GUIWidgets.DeepDisable(SimpleGroup, not UUF.db.profile.General.Fonts.Shadow.Enabled, Toggle) UUF:UpdateAllUnitFrames() end)
    Toggle:SetRelativeWidth(0.5)
    SimpleGroup:AddChild(Toggle)

    local ColorPicker = AG:Create("ColorPicker")
    ColorPicker:SetLabel("Colour")
    ColorPicker:SetColor(unpack(UUF.db.profile.General.Fonts.Shadow.Colour))
    ColorPicker:SetFullWidth(true)
    ColorPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) UUF.db.profile.General.Fonts.Shadow.Colour = {r, g, b, a} UUF:ResolveLSM() UUF:UpdateAllUnitFrames() end)
    ColorPicker:SetRelativeWidth(0.5)
    SimpleGroup:AddChild(ColorPicker)

    local XSlider = AG:Create("Slider")
    XSlider:SetLabel("Offset X")
    XSlider:SetValue(UUF.db.profile.General.Fonts.Shadow.XPos)
    XSlider:SetSliderValues(-5, 5, 1)
    XSlider:SetFullWidth(true)
    XSlider:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.General.Fonts.Shadow.XPos = value UUF:ResolveLSM() UUF:UpdateAllUnitFrames() end)
    XSlider:SetRelativeWidth(0.5)
    SimpleGroup:AddChild(XSlider)

    local YSlider = AG:Create("Slider")
    YSlider:SetLabel("Offset Y")
    YSlider:SetValue(UUF.db.profile.General.Fonts.Shadow.YPos)
    YSlider:SetSliderValues(-5, 5, 1)
    YSlider:SetFullWidth(true)
    YSlider:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.General.Fonts.Shadow.YPos = value UUF:ResolveLSM() UUF:UpdateAllUnitFrames() end)
    YSlider:SetRelativeWidth(0.5)
    SimpleGroup:AddChild(YSlider)

    GUIWidgets.DeepDisable(SimpleGroup, not UUF.db.profile.General.Fonts.Shadow.Enabled, Toggle)
end

local function CreateTextureSettings(containerParent)
    local Container = GUIWidgets.CreateInlineGroup(containerParent, "Textures")

    GUIWidgets.CreateInformationTag(Container,"Textures are applied to all Unit Frames & Elements where appropriate. More textures can be added via |cFF8080FFSharedMedia|r.")

    local ForegroundTextureDropdown = AG:Create("LSM30_Statusbar")
    ForegroundTextureDropdown:SetList(LSM:HashTable("statusbar"))
    ForegroundTextureDropdown:SetLabel("Foreground Texture")
    ForegroundTextureDropdown:SetValue(UUF.db.profile.General.Textures.Foreground)
    ForegroundTextureDropdown:SetRelativeWidth(0.5)
    ForegroundTextureDropdown:SetCallback("OnValueChanged", function(widget, _, value) widget:SetValue(value) UUF.db.profile.General.Textures.Foreground = value UUF:ResolveLSM() UUF:UpdateAllUnitFrames() end)
    Container:AddChild(ForegroundTextureDropdown)

    local BackgroundTextureDropdown = AG:Create("LSM30_Statusbar")
    BackgroundTextureDropdown:SetList(LSM:HashTable("statusbar"))
    BackgroundTextureDropdown:SetLabel("Background Texture")
    BackgroundTextureDropdown:SetValue(UUF.db.profile.General.Textures.Background)
    BackgroundTextureDropdown:SetRelativeWidth(0.5)
    BackgroundTextureDropdown:SetCallback("OnValueChanged", function(widget, _, value) widget:SetValue(value) UUF.db.profile.General.Textures.Background = value UUF:ResolveLSM() UUF:UpdateAllUnitFrames() end)
    Container:AddChild(BackgroundTextureDropdown)

    local MouseoverStyleDropdown = AG:Create("Dropdown")
    MouseoverStyleDropdown:SetList({["SELECT"] = "Set a Highlight Texture...", ["BORDER"] = "Border", ["OVERLAY"] = "Overlay", ["GRADIENT"] = "Gradient" })
    MouseoverStyleDropdown:SetLabel("Highlight Style")
    MouseoverStyleDropdown:SetValue("SELECT")
    MouseoverStyleDropdown:SetRelativeWidth(0.5)
    MouseoverStyleDropdown:SetCallback("OnValueChanged", function(_, _, value) for _, unitDB in pairs(UUF.db.profile.Units) do if unitDB.Indicators.Mouseover and unitDB.Indicators.Mouseover.Enabled then unitDB.Indicators.Mouseover.Style = value end end UUF:UpdateAllUnitFrames() MouseoverStyleDropdown:SetValue("SELECT") end)
    MouseoverStyleDropdown:SetCallback("OnEnter", function() GameTooltip:SetOwner(MouseoverStyleDropdown.frame, "ANCHOR_BOTTOM") GameTooltip:AddLine("Set |cFF8080FFMouseover Highlight Style|r for all units. |cFF8080FFColour|r & |cFF8080FFAlpha|r can be adjusted per unit.", 1, 1, 1) GameTooltip:Show() end)
    MouseoverStyleDropdown:SetCallback("OnLeave", function() GameTooltip:Hide() end)
    Container:AddChild(MouseoverStyleDropdown)

    local MouseoverHighlightSlider = AG:Create("Slider")
    MouseoverHighlightSlider:SetLabel("Highlight Opacity")
    MouseoverHighlightSlider:SetValue(0.8)
    MouseoverHighlightSlider:SetSliderValues(0.0, 1.0, 0.01)
    MouseoverHighlightSlider:SetRelativeWidth(0.5)
    MouseoverHighlightSlider:SetIsPercent(true)
    MouseoverHighlightSlider:SetCallback("OnValueChanged", function(_, _, value) for _, unitDB in pairs(UUF.db.profile.Units) do if unitDB.Indicators.Mouseover and unitDB.Indicators.Mouseover.Enabled then unitDB.Indicators.Mouseover.HighlightOpacity = value end end UUF:UpdateAllUnitFrames() end)
    Container:AddChild(MouseoverHighlightSlider)

    local ForegroundColourPicker = AG:Create("ColorPicker")
    ForegroundColourPicker:SetLabel("Foreground Colour")
    local R, G, B = 8/255, 8/255, 8/255
    ForegroundColourPicker:SetColor(R, G, B)
    ForegroundColourPicker:SetRelativeWidth(0.5)
    ForegroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) for _, unitDB in pairs(UUF.db.profile.Units) do unitDB.HealthBar.Foreground = {r, g, b} end UUF:UpdateAllUnitFrames() end)
    Container:AddChild(ForegroundColourPicker)

    local ForegroundOpacitySlider = AG:Create("Slider")
    ForegroundOpacitySlider:SetLabel("Foreground Opacity")
    ForegroundOpacitySlider:SetValue(0.8)
    ForegroundOpacitySlider:SetSliderValues(0.0, 1.0, 0.01)
    ForegroundOpacitySlider:SetRelativeWidth(0.5)
    ForegroundOpacitySlider:SetIsPercent(true)
    ForegroundOpacitySlider:SetCallback("OnValueChanged", function(_, _, value) for _, unitDB in pairs(UUF.db.profile.Units) do unitDB.HealthBar.ForegroundOpacity = value end UUF:UpdateAllUnitFrames() end)
    Container:AddChild(ForegroundOpacitySlider)

    local BackgroundColourPicker = AG:Create("ColorPicker")
    BackgroundColourPicker:SetLabel("Background Colour")
    local R2, G2, B2 = 8/255, 8/255, 8/255
    BackgroundColourPicker:SetColor(R2, G2, B2)
    BackgroundColourPicker:SetRelativeWidth(0.5)
    BackgroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) for _, unitDB in pairs(UUF.db.profile.Units) do unitDB.HealthBar.Background = {r, g, b} end UUF:UpdateAllUnitFrames() end)
    Container:AddChild(BackgroundColourPicker)

    local BackgroundOpacitySlider = AG:Create("Slider")
    BackgroundOpacitySlider:SetLabel("Background Opacity")
    BackgroundOpacitySlider:SetValue(0.8)
    BackgroundOpacitySlider:SetSliderValues(0.0, 1.0, 0.01)
    BackgroundOpacitySlider:SetRelativeWidth(0.5)
    BackgroundOpacitySlider:SetIsPercent(true)
    BackgroundOpacitySlider:SetCallback("OnValueChanged", function(_, _, value) for _, unitDB in pairs(UUF.db.profile.Units) do unitDB.HealthBar.BackgroundOpacity = value end UUF:UpdateAllUnitFrames() end)
    Container:AddChild(BackgroundOpacitySlider)

    local CastBarContainer = GUIWidgets.CreateInlineGroup(Container, "Cast Bar")

    local CastBarForegroundColourPicker = AG:Create("ColorPicker")
    CastBarForegroundColourPicker:SetLabel("Foreground Colour")
    local CR, CG, CB = 128/255, 128/255, 255/255
    CastBarForegroundColourPicker:SetColor(CR, CG, CB)
    CastBarForegroundColourPicker:SetRelativeWidth(0.33)
    CastBarForegroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) for _, unitDB in pairs(UUF.db.profile.Units) do if unitDB.CastBar then unitDB.CastBar.Foreground = {r, g, b} end end UUF:UpdateAllUnitFrames() end)
    CastBarContainer:AddChild(CastBarForegroundColourPicker)

    local CastBarBackgroundColourPicker = AG:Create("ColorPicker")
    CastBarBackgroundColourPicker:SetLabel("Background Colour")
    local CR2, CG2, CB2 = 34/255, 34/255, 34/255
    CastBarBackgroundColourPicker:SetColor(CR2, CG2, CB2)
    CastBarBackgroundColourPicker:SetRelativeWidth(0.33)
    CastBarBackgroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) for _, unitDB in pairs(UUF.db.profile.Units) do if unitDB.CastBar then unitDB.CastBar.Background = {r, g, b} end end UUF:UpdateAllUnitFrames() end)
    CastBarContainer:AddChild(CastBarBackgroundColourPicker)

    local CastBarInterruptibleColourPicker = AG:Create("ColorPicker")
    CastBarInterruptibleColourPicker:SetLabel("Interruptible Colour")
    local CR3, CG3, CB3 = 255/255, 64/255, 64/255
    CastBarInterruptibleColourPicker:SetColor(CR3, CG3, CB3)
    CastBarInterruptibleColourPicker:SetRelativeWidth(0.33)
    CastBarInterruptibleColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) for _, unitDB in pairs(UUF.db.profile.Units) do if unitDB.CastBar then unitDB.CastBar.NotInterruptibleColour = {r, g, b} end end UUF:UpdateAllUnitFrames() end)
    CastBarContainer:AddChild(CastBarInterruptibleColourPicker)
end

local function CreateRangeSettings(containerParent)
    local RangeDB = UUF.db.profile.General.Range
    local Container = GUIWidgets.CreateInlineGroup(containerParent, "Range")

    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel("Enable Range Fading")
    Toggle:SetValue(RangeDB.Enabled)
    Toggle:SetFullWidth(true)
    Toggle:SetCallback("OnValueChanged", function(_, _, value) RangeDB.Enabled = value UUF:UpdateAllUnitFrames() GUIWidgets.DeepDisable(Container, not value, Toggle) end)
    Toggle:SetRelativeWidth(0.33)
    Container:AddChild(Toggle)

    local InAlphaSlider = AG:Create("Slider")
    InAlphaSlider:SetLabel("In Range Alpha")
    InAlphaSlider:SetValue(RangeDB.InRange)
    InAlphaSlider:SetSliderValues(0.0, 1.0, 0.01)
    InAlphaSlider:SetFullWidth(true)
    InAlphaSlider:SetCallback("OnValueChanged", function(_, _, value) RangeDB.InRange = value UUF:UpdateAllUnitFrames() end)
    InAlphaSlider:SetRelativeWidth(0.33)
    InAlphaSlider:SetIsPercent(true)
    Container:AddChild(InAlphaSlider)

    local OutAlphaSlider = AG:Create("Slider")
    OutAlphaSlider:SetLabel("Out of Range Alpha")
    OutAlphaSlider:SetValue(RangeDB.OutOfRange)
    OutAlphaSlider:SetSliderValues(0.0, 1.0, 0.01)
    OutAlphaSlider:SetFullWidth(true)
    OutAlphaSlider:SetCallback("OnValueChanged", function(_, _, value) RangeDB.OutOfRange = value UUF:UpdateAllUnitFrames() end)
    OutAlphaSlider:SetRelativeWidth(0.33)
    OutAlphaSlider:SetIsPercent(true)
    Container:AddChild(OutAlphaSlider)

    GUIWidgets.DeepDisable(Container, not RangeDB.Enabled, Toggle)
end

local function CreateColourSettings(containerParent)
    local Container = GUIWidgets.CreateInlineGroup(containerParent, "Colours")

    GUIWidgets.CreateInformationTag(Container,"Buttons below will reset the colours to their default values as defined by " .. UUF.PRETTY_ADDON_NAME .. ".")

    local ResetAllColoursButton = AG:Create("Button")
    ResetAllColoursButton:SetText("All Colours")
    ResetAllColoursButton:SetCallback("OnClick", function() UUF:CopyTable(UUF:GetDefaultDB().profile.General.Colours, UUF.db.profile.General.Colours) Container:ReleaseChildren() CreateColourSettings(containerParent) Container:DoLayout() containerParent:DoLayout() end)
    ResetAllColoursButton:SetRelativeWidth(1)
    Container:AddChild(ResetAllColoursButton)

    local ResetPowerColoursButton = AG:Create("Button")
    ResetPowerColoursButton:SetText("Power Colours")
    ResetPowerColoursButton:SetCallback("OnClick", function() UUF:CopyTable(UUF:GetDefaultDB().profile.General.Colours.Power, UUF.db.profile.General.Colours.Power) Container:ReleaseChildren() CreateColourSettings(containerParent) Container:DoLayout() containerParent:DoLayout() end)
    ResetPowerColoursButton:SetRelativeWidth(0.25)
    Container:AddChild(ResetPowerColoursButton)

    local ResetSecondaryPowerColoursButton = AG:Create("Button")
    ResetSecondaryPowerColoursButton:SetText("Secondary Power Colours")
    ResetSecondaryPowerColoursButton:SetCallback("OnClick", function() UUF:CopyTable(UUF:GetDefaultDB().profile.General.Colours.SecondaryPower, UUF.db.profile.General.Colours.SecondaryPower) Container:ReleaseChildren() CreateColourSettings(containerParent) Container:DoLayout() containerParent:DoLayout() end)
    ResetSecondaryPowerColoursButton:SetRelativeWidth(0.25)
    Container:AddChild(ResetSecondaryPowerColoursButton)

    local ResetReactionColoursButton = AG:Create("Button")
    ResetReactionColoursButton:SetText("Reaction Colours")
    ResetReactionColoursButton:SetCallback("OnClick", function() UUF:CopyTable(UUF:GetDefaultDB().profile.General.Colours.Reaction, UUF.db.profile.General.Colours.Reaction) Container:ReleaseChildren() CreateColourSettings(containerParent) Container:DoLayout() containerParent:DoLayout() end)
    ResetReactionColoursButton:SetRelativeWidth(0.25)
    Container:AddChild(ResetReactionColoursButton)

    local ResetDispelColoursButton = AG:Create("Button")
    ResetDispelColoursButton:SetText("Dispel Colours")
    ResetDispelColoursButton:SetCallback("OnClick", function() UUF:CopyTable(UUF:GetDefaultDB().profile.General.Colours.Dispel, UUF.db.profile.General.Colours.Dispel) Container:ReleaseChildren() CreateColourSettings(containerParent) Container:DoLayout() containerParent:DoLayout() end)
    ResetDispelColoursButton:SetRelativeWidth(0.25)
    Container:AddChild(ResetDispelColoursButton)

	GUIWidgets.CreateHeader(Container, "Status")

	local DisconnectedColourPicker = AG:Create("ColorPicker")
	DisconnectedColourPicker:SetLabel("Offline / Disconnected")
	DisconnectedColourPicker:SetColor(unpack(UUF.db.profile.General.Colours.Disconnected))
	DisconnectedColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b) UUF.db.profile.General.Colours.Disconnected = {r, g, b} UUF:LoadCustomColours() UUF:UpdateAllUnitFrames() end)
	DisconnectedColourPicker:SetHasAlpha(false)
	DisconnectedColourPicker:SetRelativeWidth(0.25)
	Container:AddChild(DisconnectedColourPicker)

    GUIWidgets.CreateHeader(Container, "Power")

    local PowerOrder = {0, 1, 2, 3, 6, 8, 11, 13, 17, 18}

    for _, powerType in ipairs(PowerOrder) do
        local powerColour = UUF.db.profile.General.Colours.Power[powerType]
        local PowerColourPicker = AG:Create("ColorPicker")
        PowerColourPicker:SetLabel(Power[powerType])
        local R, G, B = unpack(powerColour)
        PowerColourPicker:SetColor(R, G, B)
        PowerColourPicker:SetCallback("OnValueChanged", function(widget, _, r, g, b) UUF.db.profile.General.Colours.Power[powerType] = {r, g, b} UUF:LoadCustomColours() UUF:UpdateAllUnitFrames() end)
        PowerColourPicker:SetHasAlpha(false)
        PowerColourPicker:SetRelativeWidth(0.19)
        Container:AddChild(PowerColourPicker)
    end

    GUIWidgets.CreateHeader(Container, "Secondary Power")

    local SecondaryPowerOrder = {4, 7, 9, 12, 16, 19}

    for _, secondaryPowerType in ipairs(SecondaryPowerOrder) do
        local secondaryPowerColour = UUF.db.profile.General.Colours.SecondaryPower[secondaryPowerType]
        if secondaryPowerColour then
            local SecondaryPowerColourPicker = AG:Create("ColorPicker")
            SecondaryPowerColourPicker:SetLabel(Power[secondaryPowerType])
            local R, G, B = unpack(secondaryPowerColour)
            SecondaryPowerColourPicker:SetColor(R, G, B)
            SecondaryPowerColourPicker:SetCallback("OnValueChanged", function(widget, _, r, g, b) UUF.db.profile.General.Colours.SecondaryPower[secondaryPowerType] = {r, g, b} UUF:LoadCustomColours() UUF:UpdateAllUnitFrames() end)
            SecondaryPowerColourPicker:SetHasAlpha(false)
            SecondaryPowerColourPicker:SetRelativeWidth(0.2)
            Container:AddChild(SecondaryPowerColourPicker)
        end
    end

    GUIWidgets.CreateHeader(Container, "Reaction")

    local ReactionOrder = {1, 2, 3, 4, 5, 6, 7, 8}

    for _, reactionType in ipairs(ReactionOrder) do
        local ReactionColourPicker = AG:Create("ColorPicker")
        ReactionColourPicker:SetLabel(Reaction[reactionType])
        local R, G, B = unpack(UUF.db.profile.General.Colours.Reaction[reactionType])
        ReactionColourPicker:SetColor(R, G, B)
        ReactionColourPicker:SetCallback("OnValueChanged", function(widget, _, r, g, b) UUF.db.profile.General.Colours.Reaction[reactionType] = {r, g, b} UUF:LoadCustomColours() UUF:UpdateAllUnitFrames() end)
        ReactionColourPicker:SetHasAlpha(false)
        ReactionColourPicker:SetRelativeWidth(0.25)
        Container:AddChild(ReactionColourPicker)
    end

    GUIWidgets.CreateHeader(Container, "Dispel Types")

    local DispelTypes = {"Magic", "Curse", "Disease", "Poison", "Bleed"}

    for _, dispelType in ipairs(DispelTypes) do
        local DispelColourPicker = AG:Create("ColorPicker")
        DispelColourPicker:SetLabel(dispelType)
        local R, G, B = unpack(UUF.db.profile.General.Colours.Dispel[dispelType])
        DispelColourPicker:SetColor(R, G, B)
        DispelColourPicker:SetCallback("OnValueChanged", function(widget, _, r, g, b) UUF.db.profile.General.Colours.Dispel[dispelType] = {r, g, b} UUF:LoadCustomColours() UUF:UpdateAllUnitFrames() end)
        DispelColourPicker:SetHasAlpha(false)
        DispelColourPicker:SetRelativeWidth(0.2)
        Container:AddChild(DispelColourPicker)
    end
end

local function CreateFrameSettings(containerParent, unit, unitHasParent, updateCallback)
    local FrameDB = UUF.db.profile.Units[unit].Frame
    local HealthBarDB = UUF.db.profile.Units[unit].HealthBar
    local isGroup = unit == "boss" or unit == "party" or unit == "raid"

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Layout & Positioning")

    local WidthSlider = AG:Create("Slider")
    WidthSlider:SetLabel("Width")
    WidthSlider:SetValue(FrameDB.Width)
    WidthSlider:SetSliderValues(1, 3000, 0.1)
    WidthSlider:SetRelativeWidth(0.5)
    WidthSlider:SetCallback("OnValueChanged", function(_, _, value) FrameDB.Width = value updateCallback() end)
    LayoutContainer:AddChild(WidthSlider)

    local HeightSlider = AG:Create("Slider")
    HeightSlider:SetLabel("Height")
    HeightSlider:SetValue(FrameDB.Height)
    HeightSlider:SetSliderValues(1, 3000, 0.1)
    HeightSlider:SetRelativeWidth(0.5)
    HeightSlider:SetCallback("OnValueChanged", function(_, _, value) FrameDB.Height = value updateCallback() end)
    LayoutContainer:AddChild(HeightSlider)

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(FrameDB.Layout[1])
    AnchorFromDropdown:SetRelativeWidth((unitHasParent or isGroup) and 0.33 or 0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) FrameDB.Layout[1] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorFromDropdown)

    if unitHasParent then
        local AnchorParentEditBox = AG:Create("EditBox")
        AnchorParentEditBox:SetLabel("Anchor Parent")
        AnchorParentEditBox:SetText(FrameDB.AnchorParent or "")
        AnchorParentEditBox:SetRelativeWidth(0.33)
        AnchorParentEditBox:DisableButton(true)
        AnchorParentEditBox:SetCallback("OnEnterPressed", function(_, _, value) FrameDB.AnchorParent = value AnchorParentEditBox:SetText(FrameDB.AnchorParent or "") updateCallback() end)
        LayoutContainer:AddChild(AnchorParentEditBox)
    end

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(FrameDB.Layout[2])
    AnchorToDropdown:SetRelativeWidth((unitHasParent or isGroup) and 0.33 or 0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) FrameDB.Layout[2] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorToDropdown)

    if isGroup and unit ~= "raid" then
        local GrowthDirectionDropdown = AG:Create("Dropdown")
        GrowthDirectionDropdown:SetList({["UP"] = "Up", ["DOWN"] = "Down"})
        GrowthDirectionDropdown:SetLabel("Growth Direction")
        GrowthDirectionDropdown:SetValue(FrameDB.GrowthDirection)
        GrowthDirectionDropdown:SetRelativeWidth(0.33)
        GrowthDirectionDropdown:SetCallback("OnValueChanged", function(_, _, value)
			if unit ~= "party" then FrameDB.GrowthDirection = value updateCallback() return end
			if value == FrameDB.GrowthDirection then return end
			StaticPopupDialogs["UUF_RELOAD_UI"] = {
				text = "You must reload to apply this change, do you want to reload now?",
				button1 = "Reload Now",
				button2 = "Later",
				showAlert = true,
				OnAccept = function() FrameDB.GrowthDirection = value C_UI.Reload() end,
				OnCancel = function() GrowthDirectionDropdown:SetValue(FrameDB.GrowthDirection) containerParent:DoLayout() end,
				timeout = 0,
				whileDead = true,
				hideOnEscape = true,
			}
			StaticPopup_Show("UUF_RELOAD_UI")
		end)
        LayoutContainer:AddChild(GrowthDirectionDropdown)
    end

	if unit == "raid" then
		local RowDirectionDropdown = AG:Create("Dropdown")
		RowDirectionDropdown:SetList({LEFT = "Left", RIGHT = "Right"}, {"LEFT", "RIGHT"})
		RowDirectionDropdown:SetLabel("Row Direction")
		RowDirectionDropdown:SetValue(FrameDB.RowDirection)
		RowDirectionDropdown:SetRelativeWidth(0.33)
		RowDirectionDropdown:SetCallback("OnValueChanged", function(_, _, value) FrameDB.RowDirection = value updateCallback() end)
		LayoutContainer:AddChild(RowDirectionDropdown)

		local ColumnDirectionDropdown = AG:Create("Dropdown")
		ColumnDirectionDropdown:SetList({UP = "Up", DOWN = "Down"}, {"UP", "DOWN"})
		ColumnDirectionDropdown:SetLabel("Column Direction")
		ColumnDirectionDropdown:SetValue(FrameDB.ColumnDirection)
		ColumnDirectionDropdown:SetRelativeWidth(0.33)
		ColumnDirectionDropdown:SetCallback("OnValueChanged", function(_, _, value) FrameDB.ColumnDirection = value updateCallback() end)
		LayoutContainer:AddChild(ColumnDirectionDropdown)
	end

    if unit == "party" or unit == "raid" then
		local roleOrderDropdowns = {}
        local SortByDropdown = AG:Create("Dropdown")
		local sortList = unit == "raid" and {INDEX = "Raid Index", GROUP = "Raid Group"} or {INDEX = "Group Index", ROLE = "Assigned Role"}
		local sortOrder = unit == "raid" and {"INDEX", "GROUP"} or {"INDEX", "ROLE"}
        SortByDropdown:SetList(sortList, sortOrder)
		local groupBy = unit == "raid" and FrameDB.GroupBy or FrameDB.SortBy
		if unit == "raid" and groupBy ~= "INDEX" and groupBy ~= "GROUP" then
			groupBy = "GROUP"
			FrameDB.GroupBy = groupBy
		end
        SortByDropdown:SetLabel(unit == "raid" and "Group By" or "Sort By")
		SortByDropdown:SetValue(groupBy)
        SortByDropdown:SetRelativeWidth(unit == "raid" and 0.33 or 0.25)
        SortByDropdown:SetCallback("OnValueChanged", function(_, _, value)
			if unit == "raid" then FrameDB.GroupBy = value else FrameDB.SortBy = value end
			for _, roleOrderDropdown in ipairs(roleOrderDropdowns) do roleOrderDropdown:SetDisabled(value ~= "ROLE") end
			updateCallback()
		end)
        LayoutContainer:AddChild(SortByDropdown)

		if unit == "party" then
			local roleList = {TANK = "Tank", HEALER = "Healer", DAMAGER = "Damage"}
			local roleListOrder = {"TANK", "HEALER", "DAMAGER"}
			local function CreateRoleOrderDropdown(roleIndex, label)
				local RoleOrderDropdown = AG:Create("Dropdown")
				RoleOrderDropdown:SetList(roleList, roleListOrder)
				RoleOrderDropdown:SetLabel(label)
				RoleOrderDropdown:SetValue(FrameDB.RoleOrder[roleIndex])
				RoleOrderDropdown:SetRelativeWidth(0.25)
				RoleOrderDropdown:SetCallback("OnValueChanged", function(_, _, value)
					local previousRole = FrameDB.RoleOrder[roleIndex]
					for existingIndex, existingRole in ipairs(FrameDB.RoleOrder) do
						if existingIndex ~= roleIndex and existingRole == value then
							FrameDB.RoleOrder[existingIndex] = previousRole
							roleOrderDropdowns[existingIndex]:SetValue(previousRole)
							break
						end
					end
					FrameDB.RoleOrder[roleIndex] = value
					updateCallback()
				end)
				roleOrderDropdowns[roleIndex] = RoleOrderDropdown
				LayoutContainer:AddChild(RoleOrderDropdown)
			end

			CreateRoleOrderDropdown(1, "First Role")
			CreateRoleOrderDropdown(2, "Second Role")
			CreateRoleOrderDropdown(3, "Third Role")
			for _, roleOrderDropdown in ipairs(roleOrderDropdowns) do roleOrderDropdown:SetDisabled(groupBy ~= "ROLE") end
		else
			local groupList, groupOrder = {}, {}
			for groupIndex = 1, UUF.MAX_RAID_GROUPS do
				groupList[groupIndex] = "Group " .. groupIndex
				groupOrder[groupIndex] = groupIndex
			end
			local GroupsDropdown = AG:Create("Dropdown")
			GroupsDropdown:SetLabel("Raid Groups")
			GroupsDropdown:SetMultiselect(true)
			GroupsDropdown:SetList(groupList, groupOrder)
			local selectedGroups = {}
			for _, groupIndex in ipairs(FrameDB.GroupingOrder) do
				groupIndex = tonumber(groupIndex)
				if groupIndex and groupIndex >= 1 and groupIndex <= UUF.MAX_RAID_GROUPS then selectedGroups[groupIndex] = true end
			end
			for groupIndex = 1, UUF.MAX_RAID_GROUPS do GroupsDropdown:SetItemValue(groupIndex, selectedGroups[groupIndex] or false) end
			GroupsDropdown:SetFullWidth(true)
			GroupsDropdown:SetCallback("OnValueChanged", function(_, _, groupIndex, value)
				groupIndex = tonumber(groupIndex)
				if not groupIndex then return end
				local groupingOrder = {}
				for _, existingGroup in ipairs(FrameDB.GroupingOrder) do
					existingGroup = tonumber(existingGroup)
					if existingGroup and existingGroup >= 1 and existingGroup <= UUF.MAX_RAID_GROUPS and existingGroup ~= groupIndex then groupingOrder[#groupingOrder + 1] = existingGroup end
				end
				if value then groupingOrder[#groupingOrder + 1] = groupIndex end
				FrameDB.GroupingOrder = groupingOrder
				updateCallback()
			end)
			LayoutContainer:AddChild(GroupsDropdown)
		end
    end

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(FrameDB.Layout[3])
    XPosSlider:SetSliderValues(-3000, 3000, 0.1)
    XPosSlider:SetRelativeWidth(isGroup and 0.25 or 0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) FrameDB.Layout[3] = value updateCallback() end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(FrameDB.Layout[4])
    YPosSlider:SetSliderValues(-3000, 3000, 0.1)
    YPosSlider:SetRelativeWidth(isGroup and 0.25 or 0.33)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) FrameDB.Layout[4] = value updateCallback() end)
    LayoutContainer:AddChild(YPosSlider)

    if isGroup then
        local SpacingSlider = AG:Create("Slider")
        SpacingSlider:SetLabel("Frame Spacing")
        SpacingSlider:SetValue(FrameDB.Layout[5])
        SpacingSlider:SetSliderValues(-1, 100, 0.1)
        SpacingSlider:SetRelativeWidth(0.25)
        SpacingSlider:SetCallback("OnValueChanged", function(_, _, value) FrameDB.Layout[5] = value updateCallback() end)
        LayoutContainer:AddChild(SpacingSlider)
    end

    local FrameStrataDropdown = AG:Create("Dropdown")
    FrameStrataDropdown:SetList(FrameStrataList[1], FrameStrataList[2])
    FrameStrataDropdown:SetLabel("Frame Strata")
    FrameStrataDropdown:SetValue(FrameDB.FrameStrata)
    FrameStrataDropdown:SetRelativeWidth(isGroup and 0.25 or 0.33)
    FrameStrataDropdown:SetCallback("OnValueChanged", function(_, _, value) FrameDB.FrameStrata = value updateCallback() end)
    LayoutContainer:AddChild(FrameStrataDropdown)

    local ColourContainer = GUIWidgets.CreateInlineGroup(containerParent, "Colours & Toggles")

    local SmoothUpdatesToggle = AG:Create("CheckBox")
    SmoothUpdatesToggle:SetLabel("Smooth Updates")
    SmoothUpdatesToggle:SetValue(HealthBarDB.Smooth ~= false)
    SmoothUpdatesToggle:SetCallback("OnValueChanged", function(_, _, value) HealthBarDB.Smooth = value updateCallback() end)
    SmoothUpdatesToggle:SetRelativeWidth(unit == "party" and 0.33 or 0.5)
    ColourContainer:AddChild(SmoothUpdatesToggle)

    local ColourWhenTappedToggle = AG:Create("CheckBox")
    ColourWhenTappedToggle:SetLabel("Colour When Tapped")
    ColourWhenTappedToggle:SetValue(HealthBarDB.ColourWhenTapped)
    ColourWhenTappedToggle:SetCallback("OnValueChanged", function(_, _, value) HealthBarDB.ColourWhenTapped = value updateCallback() end)
    ColourWhenTappedToggle:SetRelativeWidth(unit == "party" and 0.33 or 0.5)
    ColourContainer:AddChild(ColourWhenTappedToggle)

	local ColourWhenDisconnectedToggle = AG:Create("CheckBox")
	ColourWhenDisconnectedToggle:SetLabel("Colour When Disconnected")
	ColourWhenDisconnectedToggle:SetValue(HealthBarDB.ColourWhenDisconnected)
	ColourWhenDisconnectedToggle:SetCallback("OnValueChanged", function(_, _, value) HealthBarDB.ColourWhenDisconnected = value updateCallback() end)
	ColourWhenDisconnectedToggle:SetRelativeWidth(unit == "party" and 0.33 or 0.5)
	ColourContainer:AddChild(ColourWhenDisconnectedToggle)

    local InverseGrowthDirectionToggle = AG:Create("CheckBox")
    InverseGrowthDirectionToggle:SetLabel("Inverse Growth Direction")
    InverseGrowthDirectionToggle:SetValue(HealthBarDB.Inverse)
    InverseGrowthDirectionToggle:SetCallback("OnValueChanged", function(_, _, value) HealthBarDB.Inverse = value updateCallback() end)
    InverseGrowthDirectionToggle:SetRelativeWidth(0.5)
    ColourContainer:AddChild(InverseGrowthDirectionToggle)

    if unit == "party" then
        local ShowPlayerToggle = AG:Create("CheckBox")
        ShowPlayerToggle:SetLabel("Show Player")
        ShowPlayerToggle:SetValue(FrameDB.ShowPlayer)
        ShowPlayerToggle:SetRelativeWidth(0.5)
        ShowPlayerToggle:SetCallback("OnValueChanged", function(_, _, value) FrameDB.ShowPlayer = value updateCallback() end)
        ColourContainer:AddChild(ShowPlayerToggle)
    end

    if unit == "player" or unit == "target" then
        local AnchorToCooldownViewerToggle = AG:Create("CheckBox")
        AnchorToCooldownViewerToggle:SetLabel("Anchor To Cooldown Viewer")
        AnchorToCooldownViewerToggle:SetValue(HealthBarDB.AnchorToCooldownViewer)
        AnchorToCooldownViewerToggle:SetCallback("OnValueChanged",
        function(_, _, value)
            HealthBarDB.AnchorToCooldownViewer = value
            if not value then
                FrameDB.Layout[1] = UUF:GetDefaultDB().profile.Units[unit].Frame.Layout[1]
                FrameDB.Layout[2] = UUF:GetDefaultDB().profile.Units[unit].Frame.Layout[2]
                FrameDB.Layout[3] = UUF:GetDefaultDB().profile.Units[unit].Frame.Layout[3]
                FrameDB.Layout[4] = UUF:GetDefaultDB().profile.Units[unit].Frame.Layout[4]
                AnchorFromDropdown:SetValue(FrameDB.Layout[1])
                AnchorToDropdown:SetValue(FrameDB.Layout[2])
                XPosSlider:SetValue(FrameDB.Layout[3])
                YPosSlider:SetValue(FrameDB.Layout[4])
            else
                if unit == "player" then
                    FrameDB.Layout[1] = "RIGHT"
                    FrameDB.Layout[2] = "LEFT"
                    FrameDB.Layout[3] = 0
                    FrameDB.Layout[4] = 0
                    AnchorFromDropdown:SetValue(FrameDB.Layout[1])
                    AnchorToDropdown:SetValue(FrameDB.Layout[2])
                    XPosSlider:SetValue(FrameDB.Layout[3])
                    YPosSlider:SetValue(FrameDB.Layout[4])
                elseif unit == "target" then
                    FrameDB.Layout[1] = "LEFT"
                    FrameDB.Layout[2] = "RIGHT"
                    FrameDB.Layout[3] = 0
                    FrameDB.Layout[4] = 0
                    AnchorFromDropdown:SetValue(FrameDB.Layout[1])
                    AnchorToDropdown:SetValue(FrameDB.Layout[2])
                    XPosSlider:SetValue(FrameDB.Layout[3])
                    YPosSlider:SetValue(FrameDB.Layout[4])
                end
            end
            updateCallback()
        end)
        AnchorToCooldownViewerToggle:SetCallback("OnEnter", function() GameTooltip:SetOwner(AnchorToCooldownViewerToggle.frame, "ANCHOR_CURSOR") GameTooltip:AddLine("Anchor To |cFF8080FFEssential|r Cooldown Viewer. Toggling this will overwrite existing |cFF8080FFLayout|r Settings.", 1, 1, 1, false) GameTooltip:Show() end)
        AnchorToCooldownViewerToggle:SetCallback("OnLeave", function() GameTooltip:Hide() end)
        AnchorToCooldownViewerToggle:SetRelativeWidth(0.5)
        ColourContainer:AddChild(AnchorToCooldownViewerToggle)
    end

    GUIWidgets.CreateInformationTag(ColourContainer, "Foreground & Background Opacity can be set using the sliders.")

    local ForegroundColourPicker = AG:Create("ColorPicker")
    ForegroundColourPicker:SetLabel("Foreground Colour")
    local R, G, B = unpack(HealthBarDB.Foreground)
    ForegroundColourPicker:SetColor(R, G, B)
    ForegroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b) HealthBarDB.Foreground = {r, g, b} updateCallback() end)
    ForegroundColourPicker:SetHasAlpha(false)
    ForegroundColourPicker:SetRelativeWidth(0.25)
    ForegroundColourPicker:SetDisabled(HealthBarDB.ColourByClass)
    ColourContainer:AddChild(ForegroundColourPicker)
    UUFGUI.FrameFGColourPicker = ForegroundColourPicker

    local ForegroundColourByClassToggle = AG:Create("CheckBox")
    ForegroundColourByClassToggle:SetLabel("Colour by Class / Reaction")
    ForegroundColourByClassToggle:SetValue(HealthBarDB.ColourByClass)
    ForegroundColourByClassToggle:SetCallback("OnValueChanged", function(_, _, value) HealthBarDB.ColourByClass = value UUFGUI.FrameFGColourPicker:SetDisabled(HealthBarDB.ColourByClass) updateCallback() end)
    ForegroundColourByClassToggle:SetRelativeWidth(0.25)
    ColourContainer:AddChild(ForegroundColourByClassToggle)

    local ForegroundOpacitySlider = AG:Create("Slider")
    ForegroundOpacitySlider:SetLabel("Foreground Opacity")
    ForegroundOpacitySlider:SetValue(HealthBarDB.ForegroundOpacity)
    ForegroundOpacitySlider:SetSliderValues(0, 1, 0.01)
    ForegroundOpacitySlider:SetRelativeWidth(0.5)
    ForegroundOpacitySlider:SetCallback("OnValueChanged", function(_, _, value) HealthBarDB.ForegroundOpacity = value updateCallback() end)
    ForegroundOpacitySlider:SetIsPercent(true)
    ColourContainer:AddChild(ForegroundOpacitySlider)

    local BackgroundColourPicker = AG:Create("ColorPicker")
    BackgroundColourPicker:SetLabel("Background Colour")
    local R2, G2, B2 = unpack(HealthBarDB.Background)
    BackgroundColourPicker:SetColor(R2, G2, B2)
    BackgroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b) HealthBarDB.Background = {r, g, b} updateCallback() end)
    BackgroundColourPicker:SetHasAlpha(false)
    BackgroundColourPicker:SetRelativeWidth(0.25)
    BackgroundColourPicker:SetDisabled(HealthBarDB.ColourBackgroundByClass)
    ColourContainer:AddChild(BackgroundColourPicker)
    UUFGUI.FrameBGColourPicker = BackgroundColourPicker

    local BackgroundColourByClassToggle = AG:Create("CheckBox")
    BackgroundColourByClassToggle:SetLabel("Colour by Class / Reaction")
    BackgroundColourByClassToggle:SetValue(HealthBarDB.ColourBackgroundByClass)
    BackgroundColourByClassToggle:SetCallback("OnValueChanged", function(_, _, value) HealthBarDB.ColourBackgroundByClass = value UUFGUI.FrameBGColourPicker:SetDisabled(HealthBarDB.ColourBackgroundByClass) updateCallback() end)
    BackgroundColourByClassToggle:SetRelativeWidth(0.25)
    ColourContainer:AddChild(BackgroundColourByClassToggle)

    local BackgroundOpacitySlider = AG:Create("Slider")
    BackgroundOpacitySlider:SetLabel("Background Opacity")
    BackgroundOpacitySlider:SetValue(HealthBarDB.BackgroundOpacity)
    BackgroundOpacitySlider:SetSliderValues(0, 1, 0.01)
    BackgroundOpacitySlider:SetRelativeWidth(0.5)
    BackgroundOpacitySlider:SetCallback("OnValueChanged", function(_, _, value) HealthBarDB.BackgroundOpacity = value updateCallback() end)
    BackgroundOpacitySlider:SetIsPercent(true)
    ColourContainer:AddChild(BackgroundOpacitySlider)

    if unit == "player" or unit == "target" or unit == "focus" or unit == "party" or unit == "raid" then
        local DispelHighlightContainer = GUIWidgets.CreateInlineGroup(containerParent, "Dispel Highlighting")

        local EnableDispelHighlightingToggle = AG:Create("CheckBox")
        EnableDispelHighlightingToggle:SetLabel("Enable Dispel Highlighting")
        EnableDispelHighlightingToggle:SetValue(HealthBarDB.DispelHighlight.Enabled)
        EnableDispelHighlightingToggle:SetRelativeWidth(0.5)
        EnableDispelHighlightingToggle:SetCallback("OnValueChanged", function(_, _, value) HealthBarDB.DispelHighlight.Enabled = value updateCallback() end)
        DispelHighlightContainer:AddChild(EnableDispelHighlightingToggle)

        local DispelHighlightStyleDropdown = AG:Create("Dropdown")
        DispelHighlightStyleDropdown:SetList({["HEALTHBAR"] = "Health Bar", ["GRADIENT"] = "Gradient" })
        DispelHighlightStyleDropdown:SetLabel("Highlight Style")
        DispelHighlightStyleDropdown:SetValue(HealthBarDB.DispelHighlight.Style)
        DispelHighlightStyleDropdown:SetRelativeWidth(0.5)
        DispelHighlightStyleDropdown:SetCallback("OnValueChanged", function(_, _, value) HealthBarDB.DispelHighlight.Style = value updateCallback() end)
        DispelHighlightContainer:AddChild(DispelHighlightStyleDropdown)
    end
end

local function CreateHealPredictionSettings(containerParent, unit, updateCallback)
    local FrameDB = UUF.db.profile.Units[unit].Frame
    local HealPredictionDB = UUF.db.profile.Units[unit].HealPrediction

    local IncomingHealSettings = GUIWidgets.CreateInlineGroup(containerParent, "Incoming Heal Settings")
    local ShowIncomingHealToggle = AG:Create("CheckBox")
    ShowIncomingHealToggle:SetLabel("Show Incoming Heals")
    ShowIncomingHealToggle:SetValue(HealPredictionDB.IncomingHeal.Enabled)
    ShowIncomingHealToggle:SetCallback("OnValueChanged", function(_, _, value) HealPredictionDB.IncomingHeal.Enabled = value updateCallback() RefreshHealPredictionSettings() end)
    ShowIncomingHealToggle:SetRelativeWidth(0.33)
    IncomingHealSettings:AddChild(ShowIncomingHealToggle)

    local UseStripedTextureIncomingHealToggle = AG:Create("CheckBox")
    UseStripedTextureIncomingHealToggle:SetLabel("Use Striped Texture")
    UseStripedTextureIncomingHealToggle:SetValue(HealPredictionDB.IncomingHeal.UseStripedTexture)
    UseStripedTextureIncomingHealToggle:SetCallback("OnValueChanged", function(_, _, value) HealPredictionDB.IncomingHeal.UseStripedTexture = value updateCallback() end)
    UseStripedTextureIncomingHealToggle:SetRelativeWidth(0.33)
    IncomingHealSettings:AddChild(UseStripedTextureIncomingHealToggle)

    local MatchParentHeightToggle = AG:Create("CheckBox")
    MatchParentHeightToggle:SetLabel("Match Parent Height")
    MatchParentHeightToggle:SetValue(HealPredictionDB.IncomingHeal.MatchParentHeight)
    MatchParentHeightToggle:SetCallback("OnValueChanged", function(_, _, value) HealPredictionDB.IncomingHeal.MatchParentHeight = value updateCallback() RefreshHealPredictionSettings() end)
    MatchParentHeightToggle:SetRelativeWidth(0.33)
    IncomingHealSettings:AddChild(MatchParentHeightToggle)

    local IncomingHealColourPicker = AG:Create("ColorPicker")
    IncomingHealColourPicker:SetLabel("Incoming Heal Colour")
    local R, G, B, A = unpack(HealPredictionDB.IncomingHeal.Colour)
    IncomingHealColourPicker:SetColor(R, G, B, A)
    IncomingHealColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) HealPredictionDB.IncomingHeal.Colour = {r, g, b, a} updateCallback() end)
    IncomingHealColourPicker:SetHasAlpha(true)
    IncomingHealColourPicker:SetRelativeWidth(0.33)
    IncomingHealSettings:AddChild(IncomingHealColourPicker)

    local IncomingHealHeightSlider = AG:Create("Slider")
    IncomingHealHeightSlider:SetLabel("Height")
    IncomingHealHeightSlider:SetValue(HealPredictionDB.IncomingHeal.Height)
    IncomingHealHeightSlider:SetSliderValues(1, FrameDB.Height - 2, 0.1)
    IncomingHealHeightSlider:SetRelativeWidth(0.33)
    IncomingHealHeightSlider:SetCallback("OnValueChanged", function(_, _, value) HealPredictionDB.IncomingHeal.Height = value updateCallback() end)
    IncomingHealHeightSlider:SetDisabled(HealPredictionDB.IncomingHeal.MatchParentHeight or HealPredictionDB.IncomingHeal.Position == "ATTACH")
    IncomingHealSettings:AddChild(IncomingHealHeightSlider)

    local IncomingHealPositionDropdown = AG:Create("Dropdown")
    IncomingHealPositionDropdown:SetList({["TOPLEFT"] = "Top Left", ["TOPRIGHT"] = "Top Right", ["BOTTOMLEFT"] = "Bottom Left", ["BOTTOMRIGHT"] = "Bottom Right", ["LEFT"] = "Left", ["RIGHT"] = "Right", ["ATTACH"] = "Attach To Missing Health"}, {"TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT", "LEFT", "RIGHT", "ATTACH"})
    IncomingHealPositionDropdown:SetLabel("Position")
    IncomingHealPositionDropdown:SetValue(HealPredictionDB.IncomingHeal.Position)
    IncomingHealPositionDropdown:SetRelativeWidth(0.33)
    IncomingHealPositionDropdown:SetCallback("OnValueChanged", function(_, _, value) HealPredictionDB.IncomingHeal.Position = value updateCallback() RefreshHealPredictionSettings() end)
    IncomingHealSettings:AddChild(IncomingHealPositionDropdown)

    local AbsorbSettings = GUIWidgets.CreateInlineGroup(containerParent, "Absorb Settings")

    local ShowAbsorbToggle = AG:Create("CheckBox")
    ShowAbsorbToggle:SetLabel("Show Absorbs")
    ShowAbsorbToggle:SetValue(HealPredictionDB.Absorbs.Enabled)
    ShowAbsorbToggle:SetCallback("OnValueChanged", function(_, _, value) HealPredictionDB.Absorbs.Enabled = value updateCallback() RefreshHealPredictionSettings() end)
    ShowAbsorbToggle:SetRelativeWidth(0.25)
    AbsorbSettings:AddChild(ShowAbsorbToggle)

    local ShowOverAbsorbToggle = AG:Create("CheckBox")
    ShowOverAbsorbToggle:SetLabel("Show Over Absorb")
    ShowOverAbsorbToggle:SetValue(HealPredictionDB.Absorbs.ShowOverAbsorb or false)
    ShowOverAbsorbToggle:SetCallback("OnValueChanged", function(_, _, value) HealPredictionDB.Absorbs.ShowOverAbsorb = HealPredictionDB.Absorbs.Position == "ATTACH" and value or false updateCallback() RefreshHealPredictionSettings() end)
    ShowOverAbsorbToggle:SetCallback("OnEnter", function() GameTooltip:SetOwner(ShowOverAbsorbToggle.frame, "ANCHOR_CURSOR") GameTooltip:AddLine("This will add an overlay of your current absorbs when at maximum health.\nThis will only work when the |cFF8080FFPosition|r is set to |cFF8080FFAttach To Missing Health|r.", 1, 1, 1, false) GameTooltip:Show() end)
    ShowOverAbsorbToggle:SetCallback("OnLeave", function() GameTooltip:Hide() end)
    ShowOverAbsorbToggle:SetRelativeWidth(0.25)
    AbsorbSettings:AddChild(ShowOverAbsorbToggle)

    local UseStripedTextureAbsorbToggle = AG:Create("CheckBox")
    UseStripedTextureAbsorbToggle:SetLabel("Use Striped Texture")
    UseStripedTextureAbsorbToggle:SetValue(HealPredictionDB.Absorbs.UseStripedTexture)
    UseStripedTextureAbsorbToggle:SetCallback("OnValueChanged", function(_, _, value) HealPredictionDB.Absorbs.UseStripedTexture = value updateCallback() end)
    UseStripedTextureAbsorbToggle:SetRelativeWidth(0.25)
    AbsorbSettings:AddChild(UseStripedTextureAbsorbToggle)

    local MatchParentHeightToggle = AG:Create("CheckBox")
    MatchParentHeightToggle:SetLabel("Match Parent Height")
    MatchParentHeightToggle:SetValue(HealPredictionDB.Absorbs.MatchParentHeight)
    MatchParentHeightToggle:SetCallback("OnValueChanged", function(_, _, value) HealPredictionDB.Absorbs.MatchParentHeight = value updateCallback() RefreshHealPredictionSettings() end)
    MatchParentHeightToggle:SetRelativeWidth(0.25)
    AbsorbSettings:AddChild(MatchParentHeightToggle)

    local AbsorbColourPicker = AG:Create("ColorPicker")
    AbsorbColourPicker:SetLabel("Absorb Colour")
    local R, G, B, A = unpack(HealPredictionDB.Absorbs.Colour)
    AbsorbColourPicker:SetColor(R, G, B, A)
    AbsorbColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) HealPredictionDB.Absorbs.Colour = {r, g, b, a} updateCallback() end)
    AbsorbColourPicker:SetHasAlpha(true)
    AbsorbColourPicker:SetRelativeWidth(0.33)
    AbsorbSettings:AddChild(AbsorbColourPicker)

    local AbsorbHeightSlider = AG:Create("Slider")
    AbsorbHeightSlider:SetLabel("Height")
    AbsorbHeightSlider:SetValue(HealPredictionDB.Absorbs.Height)
    AbsorbHeightSlider:SetSliderValues(1, FrameDB.Height - 2, 0.1)
    AbsorbHeightSlider:SetRelativeWidth(0.33)
    AbsorbHeightSlider:SetCallback("OnValueChanged", function(_, _, value) HealPredictionDB.Absorbs.Height = value updateCallback() end)
    AbsorbHeightSlider:SetDisabled(HealPredictionDB.Absorbs.MatchParentHeight or HealPredictionDB.Absorbs.Position == "ATTACH")
    AbsorbSettings:AddChild(AbsorbHeightSlider)

    local AbsorbPositionDropdown = AG:Create("Dropdown")
    AbsorbPositionDropdown:SetList({["TOPLEFT"] = "Top Left", ["TOPRIGHT"] = "Top Right", ["BOTTOMLEFT"] = "Bottom Left", ["BOTTOMRIGHT"] = "Bottom Right", ["LEFT"] = "Left", ["RIGHT"] = "Right", ["ATTACH"] = "Attach To Missing Health"}, {"TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT", "LEFT", "RIGHT", "ATTACH"})
    AbsorbPositionDropdown:SetLabel("Position")
    AbsorbPositionDropdown:SetValue(HealPredictionDB.Absorbs.Position)
    AbsorbPositionDropdown:SetRelativeWidth(0.33)
    AbsorbPositionDropdown:SetCallback("OnValueChanged", function(_, _, value) HealPredictionDB.Absorbs.Position = value if value ~= "ATTACH" then HealPredictionDB.Absorbs.ShowOverAbsorb = false ShowOverAbsorbToggle:SetValue(false) end updateCallback() RefreshHealPredictionSettings() end)
    AbsorbSettings:AddChild(AbsorbPositionDropdown)

    local HealAbsorbSettings = GUIWidgets.CreateInlineGroup(containerParent, "Heal Absorb Settings")
    local ShowHealAbsorbToggle = AG:Create("CheckBox")
    ShowHealAbsorbToggle:SetLabel("Show Heal Absorbs")
    ShowHealAbsorbToggle:SetValue(HealPredictionDB.HealAbsorbs.Enabled)
    ShowHealAbsorbToggle:SetCallback("OnValueChanged", function(_, _, value) HealPredictionDB.HealAbsorbs.Enabled = value updateCallback() RefreshHealPredictionSettings() end)
    ShowHealAbsorbToggle:SetRelativeWidth(0.33)
    HealAbsorbSettings:AddChild(ShowHealAbsorbToggle)

    local UseStripedTextureHealAbsorbToggle = AG:Create("CheckBox")
    UseStripedTextureHealAbsorbToggle:SetLabel("Use Striped Texture")
    UseStripedTextureHealAbsorbToggle:SetValue(HealPredictionDB.HealAbsorbs.UseStripedTexture)
    UseStripedTextureHealAbsorbToggle:SetCallback("OnValueChanged", function(_, _, value) HealPredictionDB.HealAbsorbs.UseStripedTexture = value updateCallback() end)
    UseStripedTextureHealAbsorbToggle:SetRelativeWidth(0.33)
    HealAbsorbSettings:AddChild(UseStripedTextureHealAbsorbToggle)

    local MatchParentHeightHealAbsorbToggle = AG:Create("CheckBox")
    MatchParentHeightHealAbsorbToggle:SetLabel("Match Parent Height")
    MatchParentHeightHealAbsorbToggle:SetValue(HealPredictionDB.HealAbsorbs.MatchParentHeight)
    MatchParentHeightHealAbsorbToggle:SetCallback("OnValueChanged", function(_, _, value) HealPredictionDB.HealAbsorbs.MatchParentHeight = value updateCallback() RefreshHealPredictionSettings() end)
    MatchParentHeightHealAbsorbToggle:SetRelativeWidth(0.33)
    HealAbsorbSettings:AddChild(MatchParentHeightHealAbsorbToggle)

    local HealAbsorbColourPicker = AG:Create("ColorPicker")
    HealAbsorbColourPicker:SetLabel("Heal Absorb Colour")
    local R2, G2, B2, A2 = unpack(HealPredictionDB.HealAbsorbs.Colour)
    HealAbsorbColourPicker:SetColor(R2, G2, B2, A2)
    HealAbsorbColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) HealPredictionDB.HealAbsorbs.Colour = {r, g, b, a} updateCallback() end)
    HealAbsorbColourPicker:SetHasAlpha(true)
    HealAbsorbColourPicker:SetRelativeWidth(0.33)
    HealAbsorbSettings:AddChild(HealAbsorbColourPicker)

    local HealAbsorbHeightSlider = AG:Create("Slider")
    HealAbsorbHeightSlider:SetLabel("Height")
    HealAbsorbHeightSlider:SetValue(HealPredictionDB.HealAbsorbs.Height)
    HealAbsorbHeightSlider:SetSliderValues(1, FrameDB.Height - 2, 0.1)
    HealAbsorbHeightSlider:SetRelativeWidth(0.33)
    HealAbsorbHeightSlider:SetCallback("OnValueChanged", function(_, _, value) HealPredictionDB.HealAbsorbs.Height = value updateCallback() end)
    HealAbsorbHeightSlider:SetDisabled(HealPredictionDB.HealAbsorbs.MatchParentHeight or HealPredictionDB.HealAbsorbs.Position == "ATTACH")
    HealAbsorbSettings:AddChild(HealAbsorbHeightSlider)

    local HealAbsorbPositionDropdown = AG:Create("Dropdown")
    HealAbsorbPositionDropdown:SetList({["TOPLEFT"] = "Top Left", ["TOPRIGHT"] = "Top Right", ["BOTTOMLEFT"] = "Bottom Left", ["BOTTOMRIGHT"] = "Bottom Right", ["LEFT"] = "Left", ["RIGHT"] = "Right", ["ATTACH"] = "Attach To Missing Health"}, {"TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT", "LEFT", "RIGHT", "ATTACH"})
    HealAbsorbPositionDropdown:SetLabel("Position")
    HealAbsorbPositionDropdown:SetValue(HealPredictionDB.HealAbsorbs.Position)
    HealAbsorbPositionDropdown:SetRelativeWidth(0.33)
    HealAbsorbPositionDropdown:SetCallback("OnValueChanged", function(_, _, value) HealPredictionDB.HealAbsorbs.Position = value updateCallback() RefreshHealPredictionSettings() end)
    HealAbsorbSettings:AddChild(HealAbsorbPositionDropdown)

    function RefreshHealPredictionSettings()
        GUIWidgets.DeepDisable(IncomingHealSettings, not HealPredictionDB.IncomingHeal.Enabled, ShowIncomingHealToggle)
        IncomingHealHeightSlider:SetDisabled(HealPredictionDB.IncomingHeal.MatchParentHeight or HealPredictionDB.IncomingHeal.Position == "ATTACH")
        GUIWidgets.DeepDisable(AbsorbSettings, not HealPredictionDB.Absorbs.Enabled, ShowAbsorbToggle)
        GUIWidgets.DeepDisable(HealAbsorbSettings, not HealPredictionDB.HealAbsorbs.Enabled, ShowHealAbsorbToggle)
        AbsorbHeightSlider:SetDisabled(HealPredictionDB.Absorbs.MatchParentHeight or HealPredictionDB.Absorbs.Position == "ATTACH")
        ShowOverAbsorbToggle:SetDisabled(not HealPredictionDB.Absorbs.Enabled or HealPredictionDB.Absorbs.Position ~= "ATTACH")
        HealAbsorbHeightSlider:SetDisabled(HealPredictionDB.HealAbsorbs.MatchParentHeight or HealPredictionDB.HealAbsorbs.Position == "ATTACH")
    end

    RefreshHealPredictionSettings()
end

local function CreateCastBarBarSettings(containerParent, unit, updateCallback)
    local FrameDB = UUF.db.profile.Units[unit].Frame
    local CastBarDB = UUF.db.profile.Units[unit].CastBar
    local isPlayerorPet = unit == "player" or unit == "pet"

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Cast Bar Settings")

    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel("Enable |cFF8080FFCast Bar|r")
    Toggle:SetValue(CastBarDB.Enabled)
    Toggle:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.Enabled = value updateCallback() RefreshCastBarBarSettings() end)
    Toggle:SetRelativeWidth(0.33)
    LayoutContainer:AddChild(Toggle)

    local MatchParentWidthToggle = AG:Create("CheckBox")
    MatchParentWidthToggle:SetLabel("Match Frame Width")
    MatchParentWidthToggle:SetValue(CastBarDB.MatchParentWidth)
    MatchParentWidthToggle:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.MatchParentWidth = value updateCallback() RefreshCastBarBarSettings() end)
    MatchParentWidthToggle:SetRelativeWidth(0.33)
    LayoutContainer:AddChild(MatchParentWidthToggle)

    local InverseGrowthDirectionToggle = AG:Create("CheckBox")
    InverseGrowthDirectionToggle:SetLabel("Inverse Growth Direction")
    InverseGrowthDirectionToggle:SetValue(CastBarDB.Inverse)
    InverseGrowthDirectionToggle:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.Inverse = value updateCallback() end)
    InverseGrowthDirectionToggle:SetRelativeWidth(0.33)
    LayoutContainer:AddChild(InverseGrowthDirectionToggle)

    local WidthSlider = AG:Create("Slider")
    WidthSlider:SetLabel("Width")
    WidthSlider:SetValue(CastBarDB.Width)
    WidthSlider:SetSliderValues(1, 3000, 0.1)
    WidthSlider:SetRelativeWidth(0.5)
    WidthSlider:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.Width = value updateCallback() end)
    LayoutContainer:AddChild(WidthSlider)

    local HeightSlider = AG:Create("Slider")
    HeightSlider:SetLabel("Height")
    HeightSlider:SetValue(CastBarDB.Height)
    HeightSlider:SetSliderValues(1, 3000, 0.1)
    HeightSlider:SetRelativeWidth(0.5)
    HeightSlider:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.Height = value updateCallback() end)
    LayoutContainer:AddChild(HeightSlider)

    local HoldTimeSlider = AG:Create("Slider")
    HoldTimeSlider:SetLabel("Interrupted/Failed Hold Time")
    HoldTimeSlider:SetValue(CastBarDB.HoldTime)
    HoldTimeSlider:SetSliderValues(0, 5, 0.1)
    HoldTimeSlider:SetRelativeWidth(1)
    HoldTimeSlider:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.HoldTime = value updateCallback() end)
    LayoutContainer:AddChild(HoldTimeSlider)

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(CastBarDB.Layout[1])
    AnchorFromDropdown:SetRelativeWidth(0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.Layout[1] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(CastBarDB.Layout[2])
    AnchorToDropdown:SetRelativeWidth(0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.Layout[2] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorToDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(CastBarDB.Layout[3])
    XPosSlider:SetSliderValues(-3000, 3000, 0.1)
    XPosSlider:SetRelativeWidth(0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.Layout[3] = value updateCallback() end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(CastBarDB.Layout[4])
    YPosSlider:SetSliderValues(-3000, 3000, 0.1)
    YPosSlider:SetRelativeWidth(0.33)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.Layout[4] = value updateCallback() end)
    LayoutContainer:AddChild(YPosSlider)

    local FrameStrataDropdown = AG:Create("Dropdown")
    FrameStrataDropdown:SetList(FrameStrataList[1], FrameStrataList[2])
    FrameStrataDropdown:SetLabel("Frame Strata")
    FrameStrataDropdown:SetValue(CastBarDB.FrameStrata)
    FrameStrataDropdown:SetRelativeWidth(0.33)
    FrameStrataDropdown:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.FrameStrata = value updateCallback() end)
    LayoutContainer:AddChild(FrameStrataDropdown)

    local ColourContainer = GUIWidgets.CreateInlineGroup(containerParent, "Colours & Toggles")

    if isPlayerorPet then
        local ClassColourToggle = AG:Create("CheckBox")
        ClassColourToggle:SetLabel("Foreground: Colour by Class")
        ClassColourToggle:SetValue(CastBarDB.ColourByClass)
        ClassColourToggle:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.ColourByClass = value UUFGUI.ForegroundColourPicker:SetDisabled(CastBarDB.ColourByClass) updateCallback() end)
        ClassColourToggle:SetRelativeWidth(0.33)
        ColourContainer:AddChild(ClassColourToggle)
        UUFGUI.ClassColourToggle = ClassColourToggle
    end

    local ForegroundColourPicker = AG:Create("ColorPicker")
    ForegroundColourPicker:SetLabel("Foreground")
    local R, G, B, A = unpack(CastBarDB.Foreground)
    ForegroundColourPicker:SetColor(R, G, B, A)
    ForegroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) CastBarDB.Foreground = {r, g, b, a} updateCallback() end)
    ForegroundColourPicker:SetHasAlpha(true)
    ForegroundColourPicker:SetRelativeWidth(isPlayerorPet and 0.33 or 0.25)
    ColourContainer:AddChild(ForegroundColourPicker)

    UUFGUI.ForegroundColourPicker = ForegroundColourPicker

    local BackgroundColourPicker = AG:Create("ColorPicker")
    BackgroundColourPicker:SetLabel("Background")
    local R2, G2, B2, A2 = unpack(CastBarDB.Background)
    BackgroundColourPicker:SetColor(R2, G2, B2, A2)
    BackgroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) CastBarDB.Background = {r, g, b, a} updateCallback() end)
    BackgroundColourPicker:SetHasAlpha(true)
    BackgroundColourPicker:SetRelativeWidth(isPlayerorPet and 0.33 or 0.25)
    ColourContainer:AddChild(BackgroundColourPicker)

    local NotInterruptibleColourPicker = AG:Create("ColorPicker")
    NotInterruptibleColourPicker:SetLabel("Not Interruptible")
    local R3, G3, B3 = unpack(CastBarDB.NotInterruptibleColour)
    NotInterruptibleColourPicker:SetColor(R3, G3, B3)
    NotInterruptibleColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) CastBarDB.NotInterruptibleColour = {r, g, b, a} updateCallback() end)
    NotInterruptibleColourPicker:SetHasAlpha(true)
    NotInterruptibleColourPicker:SetRelativeWidth(isPlayerorPet and 0.5 or 0.25)
    ColourContainer:AddChild(NotInterruptibleColourPicker)

    local InterruptedFailedColour = AG:Create("ColorPicker")
    InterruptedFailedColour:SetLabel("Interrupted / Failed")
    local R4, G4, B4 = unpack(CastBarDB.InterruptedFailedColour)
    InterruptedFailedColour:SetColor(R4, G4, B4)
    InterruptedFailedColour:SetCallback("OnValueChanged", function(_, _, r, g, b, a) CastBarDB.InterruptedFailedColour = {r, g, b, a} updateCallback() end)
    InterruptedFailedColour:SetHasAlpha(true)
    InterruptedFailedColour:SetRelativeWidth(isPlayerorPet and 0.5 or 0.25)
    ColourContainer:AddChild(InterruptedFailedColour)

    function RefreshCastBarBarSettings()
        if CastBarDB.Enabled then
            MatchParentWidthToggle:SetDisabled(false)
            WidthSlider:SetDisabled(CastBarDB.MatchParentWidth)
            HeightSlider:SetDisabled(false)
            HoldTimeSlider:SetDisabled(false)
            AnchorFromDropdown:SetDisabled(false)
            AnchorToDropdown:SetDisabled(false)
            XPosSlider:SetDisabled(false)
            YPosSlider:SetDisabled(false)
            ForegroundColourPicker:SetDisabled(CastBarDB.ColourByClass)
            BackgroundColourPicker:SetDisabled(false)
            NotInterruptibleColourPicker:SetDisabled(false)
            InterruptedFailedColour:SetDisabled(false)
            if isPlayerorPet then UUFGUI.ClassColourToggle:SetDisabled(false) end
        else
            MatchParentWidthToggle:SetDisabled(true)
            WidthSlider:SetDisabled(true)
            HeightSlider:SetDisabled(true)
            HoldTimeSlider:SetDisabled(true)
            AnchorFromDropdown:SetDisabled(true)
            AnchorToDropdown:SetDisabled(true)
            XPosSlider:SetDisabled(true)
            YPosSlider:SetDisabled(true)
            ForegroundColourPicker:SetDisabled(true)
            BackgroundColourPicker:SetDisabled(true)
            NotInterruptibleColourPicker:SetDisabled(true)
            InterruptedFailedColour:SetDisabled(true)
            if isPlayerorPet then UUFGUI.ClassColourToggle:SetDisabled(true) end
        end
    end

    RefreshCastBarBarSettings()
end

local function CreateCastBarIconSettings(containerParent, unit, updateCallback)
    local CastBarIconDB = UUF.db.profile.Units[unit].CastBar.Icon

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Icon Settings")
    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel("Enable |cFF8080FFCast Bar Icon|r")
    Toggle:SetValue(CastBarIconDB.Enabled)
    Toggle:SetCallback("OnValueChanged", function(_, _, value) CastBarIconDB.Enabled = value updateCallback() RefreshCastBarIconSettings() end)
    Toggle:SetRelativeWidth(0.5)
    LayoutContainer:AddChild(Toggle)

    local PositionDropdown = AG:Create("Dropdown")
    PositionDropdown:SetList({["LEFT"] = "Left", ["RIGHT"] = "Right"})
    PositionDropdown:SetLabel("Position")
    PositionDropdown:SetValue(CastBarIconDB.Position)
    PositionDropdown:SetRelativeWidth(0.5)
    PositionDropdown:SetCallback("OnValueChanged", function(_, _, value) CastBarIconDB.Position = value updateCallback() end)
    LayoutContainer:AddChild(PositionDropdown)

    function RefreshCastBarIconSettings()
        if CastBarIconDB.Enabled then
            PositionDropdown:SetDisabled(false)
        else
            PositionDropdown:SetDisabled(true)
        end
    end

    RefreshCastBarIconSettings()
end

local function CreateCastBarSpellNameTextSettings(containerParent, unit, updateCallback)
    local CastBarDB = UUF.db.profile.Units[unit].CastBar
    local CastBarTextDB = CastBarDB.Text
    local SpellNameTextDB = CastBarTextDB.SpellName

    local SpellNameContainer = GUIWidgets.CreateInlineGroup(containerParent, "Spell Name Settings")

    local SpellNameToggle = AG:Create("CheckBox")
    SpellNameToggle:SetLabel("Enable |cFF8080FFSpell Name Text|r")
    SpellNameToggle:SetValue(SpellNameTextDB.Enabled)
    SpellNameToggle:SetCallback("OnValueChanged", function(_, _, value) SpellNameTextDB.Enabled = value updateCallback() RefreshCastBarSpellNameSettings() end)
    SpellNameToggle:SetRelativeWidth(0.33)
    SpellNameContainer:AddChild(SpellNameToggle)

    local ShowTargetToggle = AG:Create("CheckBox")
    ShowTargetToggle:SetLabel("Show Target")
    ShowTargetToggle:SetValue(CastBarDB.ShowTarget)
    ShowTargetToggle:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.ShowTarget = value updateCallback() end)
    ShowTargetToggle:SetRelativeWidth(0.33)
    SpellNameContainer:AddChild(ShowTargetToggle)

    local SpellNameColourPicker = AG:Create("ColorPicker")
    SpellNameColourPicker:SetLabel("Colour")
    local R, G, B = unpack(SpellNameTextDB.Colour)
    SpellNameColourPicker:SetColor(R, G, B)
    SpellNameColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b) SpellNameTextDB.Colour = {r, g, b} updateCallback() end)
    SpellNameColourPicker:SetHasAlpha(false)
    SpellNameColourPicker:SetRelativeWidth(0.33)
    SpellNameContainer:AddChild(SpellNameColourPicker)

    local SpellNameLayoutContainer = GUIWidgets.CreateInlineGroup(SpellNameContainer, "Layout")
    local SpellNameAnchorFromDropdown = AG:Create("Dropdown")
    SpellNameAnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    SpellNameAnchorFromDropdown:SetLabel("Anchor From")
    SpellNameAnchorFromDropdown:SetValue(SpellNameTextDB.Layout[1])
    SpellNameAnchorFromDropdown:SetRelativeWidth(0.5)
    SpellNameAnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) SpellNameTextDB.Layout[1] = value updateCallback() end)
    SpellNameLayoutContainer:AddChild(SpellNameAnchorFromDropdown)

    local SpellNameAnchorToDropdown = AG:Create("Dropdown")
    SpellNameAnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    SpellNameAnchorToDropdown:SetLabel("Anchor To")
    SpellNameAnchorToDropdown:SetValue(SpellNameTextDB.Layout[2])
    SpellNameAnchorToDropdown:SetRelativeWidth(0.5)
    SpellNameAnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) SpellNameTextDB.Layout[2] = value updateCallback() end)
    SpellNameLayoutContainer:AddChild(SpellNameAnchorToDropdown)

    local SpellNameXPosSlider = AG:Create("Slider")
    SpellNameXPosSlider:SetLabel("X Position")
    SpellNameXPosSlider:SetValue(SpellNameTextDB.Layout[3])
    SpellNameXPosSlider:SetSliderValues(-3000, 3000, 0.1)
    SpellNameXPosSlider:SetRelativeWidth(0.25)
    SpellNameXPosSlider:SetCallback("OnValueChanged", function(_, _, value) SpellNameTextDB.Layout[3] = value updateCallback() end)
    SpellNameLayoutContainer:AddChild(SpellNameXPosSlider)

    local SpellNameYPosSlider = AG:Create("Slider")
    SpellNameYPosSlider:SetLabel("Y Position")
    SpellNameYPosSlider:SetValue(SpellNameTextDB.Layout[4])
    SpellNameYPosSlider:SetSliderValues(-3000, 3000, 0.1)
    SpellNameYPosSlider:SetRelativeWidth(0.25)
    SpellNameYPosSlider:SetCallback("OnValueChanged", function(_, _, value) SpellNameTextDB.Layout[4] = value updateCallback() end)
    SpellNameLayoutContainer:AddChild(SpellNameYPosSlider)

    local SpellNameFontSizeSlider = AG:Create("Slider")
    SpellNameFontSizeSlider:SetLabel("Font Size")
    SpellNameFontSizeSlider:SetValue(SpellNameTextDB.FontSize)
    SpellNameFontSizeSlider:SetSliderValues(8, 64, 1)
    SpellNameFontSizeSlider:SetRelativeWidth(0.25)
    SpellNameFontSizeSlider:SetCallback("OnValueChanged", function(_, _, value) SpellNameTextDB.FontSize = value updateCallback() end)
    SpellNameLayoutContainer:AddChild(SpellNameFontSizeSlider)

    local MaxCharsSlider = AG:Create("Slider")
    MaxCharsSlider:SetLabel("Max Characters")
    MaxCharsSlider:SetValue(SpellNameTextDB.MaxChars)
    MaxCharsSlider:SetSliderValues(1, 64, 1)
    MaxCharsSlider:SetRelativeWidth(0.25)
    MaxCharsSlider:SetCallback("OnValueChanged", function(_, _, value) SpellNameTextDB.MaxChars = value updateCallback() end)
    SpellNameLayoutContainer:AddChild(MaxCharsSlider)

    function RefreshCastBarSpellNameSettings()
        if SpellNameTextDB.Enabled then
            SpellNameAnchorFromDropdown:SetDisabled(false)
            SpellNameAnchorToDropdown:SetDisabled(false)
            SpellNameXPosSlider:SetDisabled(false)
            SpellNameYPosSlider:SetDisabled(false)
            SpellNameFontSizeSlider:SetDisabled(false)
            SpellNameColourPicker:SetDisabled(false)
            ShowTargetToggle:SetDisabled(false)
            MaxCharsSlider:SetDisabled(false)
        else
            SpellNameAnchorFromDropdown:SetDisabled(true)
            SpellNameAnchorToDropdown:SetDisabled(true)
            SpellNameXPosSlider:SetDisabled(true)
            SpellNameYPosSlider:SetDisabled(true)
            SpellNameFontSizeSlider:SetDisabled(true)
            SpellNameColourPicker:SetDisabled(true)
            ShowTargetToggle:SetDisabled(true)
            MaxCharsSlider:SetDisabled(true)
        end
    end

    RefreshCastBarSpellNameSettings()
end

local function CreateCastBarDurationTextSettings(containerParent, unit, updateCallback)
    local CastBarTextDB = UUF.db.profile.Units[unit].CastBar.Text
    local DurationTextDB = CastBarTextDB.Duration

     local DurationContainer = GUIWidgets.CreateInlineGroup(containerParent, "Duration Settings")

    local DurationToggle = AG:Create("CheckBox")
    DurationToggle:SetLabel("Enable |cFF8080FFDuration Text|r")
    DurationToggle:SetValue(DurationTextDB.Enabled)
    DurationToggle:SetCallback("OnValueChanged", function(_, _, value) DurationTextDB.Enabled = value updateCallback() RefreshCastBarDurationSettings() end)
    DurationToggle:SetRelativeWidth(0.5)
    DurationContainer:AddChild(DurationToggle)

    local DurationColourPicker = AG:Create("ColorPicker")
    DurationColourPicker:SetLabel("Colour")
    local R, G, B = unpack(DurationTextDB.Colour)
    DurationColourPicker:SetColor(R, G, B)
    DurationColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b) DurationTextDB.Colour = {r, g, b} updateCallback() end)
    DurationColourPicker:SetHasAlpha(false)
    DurationColourPicker:SetRelativeWidth(0.5)
    DurationContainer:AddChild(DurationColourPicker)

    local DurationLayoutContainer = GUIWidgets.CreateInlineGroup(DurationContainer, "Layout")
    local DurationAnchorFromDropdown = AG:Create("Dropdown")
    DurationAnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    DurationAnchorFromDropdown:SetLabel("Anchor From")
    DurationAnchorFromDropdown:SetValue(DurationTextDB.Layout[1])
    DurationAnchorFromDropdown:SetRelativeWidth(0.5)
    DurationAnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) DurationTextDB.Layout[1] = value updateCallback() end)
    DurationLayoutContainer:AddChild(DurationAnchorFromDropdown)

    local DurationAnchorToDropdown = AG:Create("Dropdown")
    DurationAnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    DurationAnchorToDropdown:SetLabel("Anchor To")
    DurationAnchorToDropdown:SetValue(DurationTextDB.Layout[2])
    DurationAnchorToDropdown:SetRelativeWidth(0.5)
    DurationAnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) DurationTextDB.Layout[2] = value updateCallback() end)
    DurationLayoutContainer:AddChild(DurationAnchorToDropdown)

    local DurationXPosSlider = AG:Create("Slider")
    DurationXPosSlider:SetLabel("X Position")
    DurationXPosSlider:SetValue(DurationTextDB.Layout[3])
    DurationXPosSlider:SetSliderValues(-3000, 3000, 0.1)
    DurationXPosSlider:SetRelativeWidth(0.33)
    DurationXPosSlider:SetCallback("OnValueChanged", function(_, _, value) DurationTextDB.Layout[3] = value updateCallback() end)
    DurationLayoutContainer:AddChild(DurationXPosSlider)

    local DurationYPosSlider = AG:Create("Slider")
    DurationYPosSlider:SetLabel("Y Position")
    DurationYPosSlider:SetValue(DurationTextDB.Layout[4])
    DurationYPosSlider:SetSliderValues(-3000, 3000, 0.1)
    DurationYPosSlider:SetRelativeWidth(0.33)
    DurationYPosSlider:SetCallback("OnValueChanged", function(_, _, value) DurationTextDB.Layout[4] = value updateCallback() end)
    DurationLayoutContainer:AddChild(DurationYPosSlider)

    local DurationFontSizeSlider = AG:Create("Slider")
    DurationFontSizeSlider:SetLabel("Font Size")
    DurationFontSizeSlider:SetValue(DurationTextDB.FontSize)
    DurationFontSizeSlider:SetSliderValues(8, 64, 1)
    DurationFontSizeSlider:SetRelativeWidth(0.33)
    DurationFontSizeSlider:SetCallback("OnValueChanged", function(_, _, value) DurationTextDB.FontSize = value updateCallback() end)
    DurationLayoutContainer:AddChild(DurationFontSizeSlider)

    function RefreshCastBarDurationSettings()
        if DurationTextDB.Enabled then
            DurationAnchorFromDropdown:SetDisabled(false)
            DurationAnchorToDropdown:SetDisabled(false)
            DurationXPosSlider:SetDisabled(false)
            DurationYPosSlider:SetDisabled(false)
            DurationFontSizeSlider:SetDisabled(false)
            DurationColourPicker:SetDisabled(false)
        else
            DurationAnchorFromDropdown:SetDisabled(true)
            DurationAnchorToDropdown:SetDisabled(true)
            DurationXPosSlider:SetDisabled(true)
            DurationYPosSlider:SetDisabled(true)
            DurationFontSizeSlider:SetDisabled(true)
            DurationColourPicker:SetDisabled(true)
        end
    end

    RefreshCastBarDurationSettings()
end

local function CreateCastBarSettings(containerParent, unit)

    local function SelectCastBarTab(CastBarContainer, _, CastBarTab)
        SaveSubTab(unit, "CastBar", CastBarTab)
        CastBarContainer:ReleaseChildren()
        if CastBarTab == "Bar" then
            CreateCastBarBarSettings(CastBarContainer, unit, function() if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitCastBar(UUF[unit:upper()], unit) end end)
        elseif CastBarTab == "Icon" then
            CreateCastBarIconSettings(CastBarContainer, unit, function() if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitCastBar(UUF[unit:upper()], unit) end end)
        elseif CastBarTab == "SpellName" then
            CreateCastBarSpellNameTextSettings(CastBarContainer, unit, function() if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitCastBar(UUF[unit:upper()], unit) end end)
        elseif CastBarTab == "Duration" then
            CreateCastBarDurationTextSettings(CastBarContainer, unit, function() if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitCastBar(UUF[unit:upper()], unit) end end)
        end
    end

    local CastBarTabGroup = AG:Create("TabGroup")
    CastBarTabGroup:SetLayout("Flow")
    CastBarTabGroup:SetFullWidth(true)
    CastBarTabGroup:SetTabs({
        {text = "Bar", value = "Bar"},
        {text = "Icon" , value = "Icon"},
        {text = "Text: |cFFFFFFFFSpell Name|r", value = "SpellName"},
        {text = "Text: |cFFFFFFFFDuration|r", value = "Duration"},
    })
    CastBarTabGroup:SetCallback("OnGroupSelected", SelectCastBarTab)
    CastBarTabGroup:SelectTab(GetSavedSubTab(unit, "CastBar", "Bar"))
    containerParent:AddChild(CastBarTabGroup)
end

local function CreatePowerBarSettings(containerParent, unit, updateCallback)
    local FrameDB = UUF.db.profile.Units[unit].Frame
    local PowerBarDB = UUF.db.profile.Units[unit].PowerBar

    local function UpdatePowerBarSettings()
        updateCallback()
        if unit == "player" and UUF.PLAYER then
            UUF:UpdateUnitSecondaryPowerBar(UUF.PLAYER, unit)
        end
    end

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Power Bar Settings")

    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel("Enable |cFF8080FFPower Bar|r")
    Toggle:SetValue(PowerBarDB.Enabled)
    Toggle:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.Enabled = value UpdatePowerBarSettings() RefreshPowerBarGUI() end)
    Toggle:SetRelativeWidth(0.25)
    LayoutContainer:AddChild(Toggle)

    local InverseGrowthDirectionToggle = AG:Create("CheckBox")
    InverseGrowthDirectionToggle:SetLabel("Inverse Growth Direction")
    InverseGrowthDirectionToggle:SetValue(PowerBarDB.Inverse)
    InverseGrowthDirectionToggle:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.Inverse = value UpdatePowerBarSettings() end)
    InverseGrowthDirectionToggle:SetRelativeWidth(0.25)
    LayoutContainer:AddChild(InverseGrowthDirectionToggle)

    local PositionDropdown = AG:Create("Dropdown")
    PositionDropdown:SetList(TopBottomList[1], TopBottomList[2])
    PositionDropdown:SetLabel("Position")
    PositionDropdown:SetValue(UUF:GetConfiguredPowerBarPosition(unit))
    PositionDropdown:SetRelativeWidth(0.25)
    PositionDropdown:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.Position = value UpdatePowerBarSettings() end)
    LayoutContainer:AddChild(PositionDropdown)

    local HeightSlider = AG:Create("Slider")
    HeightSlider:SetLabel("Height")
    HeightSlider:SetValue(PowerBarDB.Height)
    HeightSlider:SetSliderValues(1, FrameDB.Height - 2, 0.1)
    HeightSlider:SetRelativeWidth(0.25)
    HeightSlider:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.Height = value UpdatePowerBarSettings() end)
    LayoutContainer:AddChild(HeightSlider)

    local ColourContainer = GUIWidgets.CreateInlineGroup(containerParent, "Colours & Toggles")

    local SmoothUpdatesToggle = AG:Create("CheckBox")
    SmoothUpdatesToggle:SetLabel("Smooth Updates")
    SmoothUpdatesToggle:SetValue(PowerBarDB.Smooth)
    SmoothUpdatesToggle:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.Smooth = value UpdatePowerBarSettings() end)
    SmoothUpdatesToggle:SetRelativeWidth(0.25)
    ColourContainer:AddChild(SmoothUpdatesToggle)

    local ColourByTypeToggle = AG:Create("CheckBox")
    ColourByTypeToggle:SetLabel("Colour By Type")
    ColourByTypeToggle:SetValue(PowerBarDB.ColourByType)
    ColourByTypeToggle:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.ColourByType = value UpdatePowerBarSettings() RefreshPowerBarGUI() end)
    ColourByTypeToggle:SetRelativeWidth(0.25)
    ColourContainer:AddChild(ColourByTypeToggle)

    local ColourByClassToggle = AG:Create("CheckBox")
    ColourByClassToggle:SetLabel("Colour By Class")
    ColourByClassToggle:SetValue(PowerBarDB.ColourByClass)
    ColourByClassToggle:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.ColourByClass = value UpdatePowerBarSettings() RefreshPowerBarGUI() end)
    ColourByClassToggle:SetRelativeWidth(0.25)
    ColourContainer:AddChild(ColourByClassToggle)

    local ColourBackgroundByTypeToggle = AG:Create("CheckBox")
    ColourBackgroundByTypeToggle:SetLabel("Colour Background By Power Type")
    ColourBackgroundByTypeToggle:SetValue(PowerBarDB.ColourBackgroundByType)
    ColourBackgroundByTypeToggle:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.ColourBackgroundByType = value UpdatePowerBarSettings() RefreshPowerBarGUI() end)
    ColourBackgroundByTypeToggle:SetRelativeWidth(0.25)
    ColourBackgroundByTypeToggle:SetDisabled(true)
    ColourContainer:AddChild(ColourBackgroundByTypeToggle)

    local ForegroundColourPicker = AG:Create("ColorPicker")
    ForegroundColourPicker:SetLabel("Foreground Colour")
    local R, G, B, A = unpack(PowerBarDB.Foreground)
    ForegroundColourPicker:SetColor(R, G, B, A)
    ForegroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) PowerBarDB.Foreground = {r, g, b, a} UpdatePowerBarSettings() end)
    ForegroundColourPicker:SetHasAlpha(true)
    ForegroundColourPicker:SetRelativeWidth(0.33)
    ForegroundColourPicker:SetDisabled(PowerBarDB.ColourByClass or PowerBarDB.ColourByType)
    ColourContainer:AddChild(ForegroundColourPicker)

    local BackgroundColourPicker = AG:Create("ColorPicker")
    BackgroundColourPicker:SetLabel("Background Colour")
    local R2, G2, B2, A2 = unpack(PowerBarDB.Background)
    BackgroundColourPicker:SetColor(R2, G2, B2, A2)
    BackgroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) PowerBarDB.Background = {r, g, b, a} UpdatePowerBarSettings() end)
    BackgroundColourPicker:SetHasAlpha(true)
    BackgroundColourPicker:SetRelativeWidth(0.33)
    BackgroundColourPicker:SetDisabled(PowerBarDB.ColourBackgroundByType)
    ColourContainer:AddChild(BackgroundColourPicker)

    local BackgroundMultiplierSlider = AG:Create("Slider")
    BackgroundMultiplierSlider:SetLabel("Background Multiplier")
    BackgroundMultiplierSlider:SetValue(PowerBarDB.BackgroundMultiplier)
    BackgroundMultiplierSlider:SetSliderValues(0, 1, 0.01)
    BackgroundMultiplierSlider:SetRelativeWidth(0.33)
    BackgroundMultiplierSlider:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.BackgroundMultiplier = value UpdatePowerBarSettings() end)
    BackgroundMultiplierSlider:SetIsPercent(true)
    BackgroundMultiplierSlider:SetDisabled(not PowerBarDB.ColourBackgroundByType)
    ColourContainer:AddChild(BackgroundMultiplierSlider)

    function RefreshPowerBarGUI()
        if PowerBarDB.Enabled then
            GUIWidgets.DeepDisable(LayoutContainer, false, Toggle)
            GUIWidgets.DeepDisable(ColourContainer, false, Toggle)
            if PowerBarDB.ColourByClass or PowerBarDB.ColourByType then
                ForegroundColourPicker:SetDisabled(true)
            else
                ForegroundColourPicker:SetDisabled(false)
            end
            BackgroundColourPicker:SetDisabled(PowerBarDB.ColourBackgroundByType)
            BackgroundMultiplierSlider:SetDisabled(not PowerBarDB.ColourBackgroundByType)
        else
            GUIWidgets.DeepDisable(LayoutContainer, true, Toggle)
            GUIWidgets.DeepDisable(ColourContainer, true, Toggle)
        end
    end

    RefreshPowerBarGUI()
end

local function CreateSecondaryPowerBarSettings(containerParent, unit, updateCallback)
    local FrameDB = UUF.db.profile.Units[unit].Frame
    local SecondaryPowerBarDB = UUF.db.profile.Units[unit].SecondaryPowerBar

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Power Bar Settings")

    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel("Enable |cFF8080FFSecondary Power Bar|r")
    Toggle:SetValue(SecondaryPowerBarDB.Enabled)
    Toggle:SetCallback("OnValueChanged", function(_, _, value) SecondaryPowerBarDB.Enabled = value updateCallback() RefreshSecondaryPowerBarGUI() end)
    Toggle:SetRelativeWidth(0.33)
    LayoutContainer:AddChild(Toggle)

    local PositionDropdown = AG:Create("Dropdown")
    PositionDropdown:SetList(TopBottomList[1], TopBottomList[2])
    PositionDropdown:SetLabel("Position")
    PositionDropdown:SetValue(UUF:GetConfiguredSecondaryPowerBarPosition(unit))
    PositionDropdown:SetRelativeWidth(0.33)
    PositionDropdown:SetCallback("OnValueChanged", function(_, _, value) SecondaryPowerBarDB.Position = value updateCallback() end)
    LayoutContainer:AddChild(PositionDropdown)

    local HeightSlider = AG:Create("Slider")
    HeightSlider:SetLabel("Height")
    HeightSlider:SetValue(SecondaryPowerBarDB.Height)
    HeightSlider:SetSliderValues(1, FrameDB.Height - 2, 0.1)
    HeightSlider:SetRelativeWidth(0.33)
    HeightSlider:SetCallback("OnValueChanged", function(_, _, value) SecondaryPowerBarDB.Height = value updateCallback() end)
    LayoutContainer:AddChild(HeightSlider)

    local ColourContainer = GUIWidgets.CreateInlineGroup(containerParent, "Colours & Toggles")

    local ColourByTypeToggle = AG:Create("CheckBox")
    ColourByTypeToggle:SetLabel("Colour By Type")
    ColourByTypeToggle:SetValue(SecondaryPowerBarDB.ColourByType)
    ColourByTypeToggle:SetCallback("OnValueChanged", function(_, _, value) SecondaryPowerBarDB.ColourByType = value updateCallback() RefreshSecondaryPowerBarGUI() end)
    ColourByTypeToggle:SetRelativeWidth(1)
    ColourContainer:AddChild(ColourByTypeToggle)

    local ForegroundColourPicker = AG:Create("ColorPicker")
    ForegroundColourPicker:SetLabel("Foreground Colour")
    local R, G, B, A = unpack(SecondaryPowerBarDB.Foreground)
    ForegroundColourPicker:SetColor(R, G, B, A)
    ForegroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) SecondaryPowerBarDB.Foreground = {r, g, b, a} updateCallback() end)
    ForegroundColourPicker:SetHasAlpha(true)
    ForegroundColourPicker:SetRelativeWidth(0.5)
    ForegroundColourPicker:SetDisabled(SecondaryPowerBarDB.ColourByClass or SecondaryPowerBarDB.ColourByType)
    ColourContainer:AddChild(ForegroundColourPicker)

    local BackgroundColourPicker = AG:Create("ColorPicker")
    BackgroundColourPicker:SetLabel("Background Colour")
    local R2, G2, B2, A2 = unpack(SecondaryPowerBarDB.Background)
    BackgroundColourPicker:SetColor(R2, G2, B2, A2)
    BackgroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) SecondaryPowerBarDB.Background = {r, g, b, a} updateCallback() end)
    BackgroundColourPicker:SetHasAlpha(true)
    BackgroundColourPicker:SetRelativeWidth(0.5)
    BackgroundColourPicker:SetDisabled(SecondaryPowerBarDB.ColourBackgroundByType)
    ColourContainer:AddChild(BackgroundColourPicker)

    function RefreshSecondaryPowerBarGUI()
        if SecondaryPowerBarDB.Enabled then
            GUIWidgets.DeepDisable(LayoutContainer, false, Toggle)
            GUIWidgets.DeepDisable(ColourContainer, false, Toggle)
            if SecondaryPowerBarDB.ColourByClass or SecondaryPowerBarDB.ColourByType then
                ForegroundColourPicker:SetDisabled(true)
            else
                ForegroundColourPicker:SetDisabled(false)
            end
        else
            GUIWidgets.DeepDisable(LayoutContainer, true, Toggle)
            GUIWidgets.DeepDisable(ColourContainer, true, Toggle)
        end
    end

    RefreshSecondaryPowerBarGUI()
end

local function CreateAlternativePowerBarSettings(containerParent, unit, updateCallback)
    local AlternativePowerBarDB = UUF.db.profile.Units[unit].AlternativePowerBar

    GUIWidgets.CreateInformationTag(containerParent, "The |cFF8080FFAlternative Power Bar|r will display |cFF4080FFMana|r for classes that have an alternative resource.")

    local AlternativePowerBarSettings = GUIWidgets.CreateInlineGroup(containerParent, "Alternative Power Bar Settings")

    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel("Enable |cFF8080FFAlternative Power Bar|r")
    Toggle:SetValue(AlternativePowerBarDB.Enabled)
    Toggle:SetCallback("OnValueChanged", function(_, _, value) AlternativePowerBarDB.Enabled = value updateCallback() RefreshAlternativePowerBarGUI() end)
    Toggle:SetRelativeWidth(0.5)
    AlternativePowerBarSettings:AddChild(Toggle)

    local InverseGrowthDirectionToggle = AG:Create("CheckBox")
    InverseGrowthDirectionToggle:SetLabel("Inverse Growth Direction")
    InverseGrowthDirectionToggle:SetValue(AlternativePowerBarDB.Inverse)
    InverseGrowthDirectionToggle:SetCallback("OnValueChanged", function(_, _, value) AlternativePowerBarDB.Inverse = value updateCallback() end)
    InverseGrowthDirectionToggle:SetRelativeWidth(0.5)
    AlternativePowerBarSettings:AddChild(InverseGrowthDirectionToggle)

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Layout & Positioning")

    local WidthSlider = AG:Create("Slider")
    WidthSlider:SetLabel("Width")
    WidthSlider:SetValue(AlternativePowerBarDB.Width)
    WidthSlider:SetSliderValues(1, 3000, 0.1)
    WidthSlider:SetRelativeWidth(0.5)
    WidthSlider:SetCallback("OnValueChanged", function(_, _, value) AlternativePowerBarDB.Width = value updateCallback() end)
    LayoutContainer:AddChild(WidthSlider)

    local HeightSlider = AG:Create("Slider")
    HeightSlider:SetLabel("Height")
    HeightSlider:SetValue(AlternativePowerBarDB.Height)
    HeightSlider:SetSliderValues(1, 64, 0.1)
    HeightSlider:SetRelativeWidth(0.5)
    HeightSlider:SetCallback("OnValueChanged", function(_, _, value) AlternativePowerBarDB.Height = value updateCallback() end)
    LayoutContainer:AddChild(HeightSlider)

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(AlternativePowerBarDB.Layout[1])
    AnchorFromDropdown:SetRelativeWidth(0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) AlternativePowerBarDB.Layout[1] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(AlternativePowerBarDB.Layout[2])
    AnchorToDropdown:SetRelativeWidth(0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) AlternativePowerBarDB.Layout[2] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorToDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(AlternativePowerBarDB.Layout[3])
    XPosSlider:SetSliderValues(-3000, 3000, 0.1)
    XPosSlider:SetRelativeWidth(0.5)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) AlternativePowerBarDB.Layout[3] = value updateCallback() end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(AlternativePowerBarDB.Layout[4])
    YPosSlider:SetSliderValues(-3000, 3000, 0.1)
    YPosSlider:SetRelativeWidth(0.5)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) AlternativePowerBarDB.Layout[4] = value updateCallback() end)
    LayoutContainer:AddChild(YPosSlider)

    local ColourContainer = GUIWidgets.CreateInlineGroup(containerParent, "Colours & Toggles")

    local ColourByTypeToggle = AG:Create("CheckBox")
    ColourByTypeToggle:SetLabel("Colour By Type")
    ColourByTypeToggle:SetValue(AlternativePowerBarDB.ColourByType)
    ColourByTypeToggle:SetCallback("OnValueChanged", function(_, _, value) AlternativePowerBarDB.ColourByType = value updateCallback() RefreshAlternativePowerBarGUI() end)
    ColourByTypeToggle:SetRelativeWidth(0.33)
    ColourContainer:AddChild(ColourByTypeToggle)

    local ForegroundColourPicker = AG:Create("ColorPicker")
    ForegroundColourPicker:SetLabel("Foreground Colour")
    local R, G, B, A = unpack(AlternativePowerBarDB.Foreground)
    ForegroundColourPicker:SetColor(R, G, B, A)
    ForegroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) AlternativePowerBarDB.Foreground = {r, g, b, a} updateCallback() end)
    ForegroundColourPicker:SetHasAlpha(true)
    ForegroundColourPicker:SetRelativeWidth(0.33)
    ForegroundColourPicker:SetDisabled(AlternativePowerBarDB.ColourByType)
    ColourContainer:AddChild(ForegroundColourPicker)

    local BackgroundColourPicker = AG:Create("ColorPicker")
    BackgroundColourPicker:SetLabel("Background Colour")
    local R2, G2, B2, A2 = unpack(AlternativePowerBarDB.Background)
    BackgroundColourPicker:SetColor(R2, G2, B2, A2)
    BackgroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) AlternativePowerBarDB.Background = {r, g, b, a} updateCallback() end)
    BackgroundColourPicker:SetHasAlpha(true)
    BackgroundColourPicker:SetRelativeWidth(0.33)
    ColourContainer:AddChild(BackgroundColourPicker)

    function RefreshAlternativePowerBarGUI()
        if AlternativePowerBarDB.Enabled then
            GUIWidgets.DeepDisable(LayoutContainer, false, Toggle)
            GUIWidgets.DeepDisable(ColourContainer, false, Toggle)
            if AlternativePowerBarDB.ColourByType then
                ForegroundColourPicker:SetDisabled(true)
            else
                ForegroundColourPicker:SetDisabled(false)
            end
        else
            GUIWidgets.DeepDisable(LayoutContainer, true, Toggle)
            GUIWidgets.DeepDisable(ColourContainer, true, Toggle)
        end
        InverseGrowthDirectionToggle:SetDisabled(not AlternativePowerBarDB.Enabled)
    end

    RefreshAlternativePowerBarGUI()
end

local function CreatePortraitSettings(containerParent, unit, updateCallback)
    local PortraitDB = UUF.db.profile.Units[unit].Portrait
    PortraitDB.Style = PortraitDB.Style or "2D"

    local ToggleContainer = GUIWidgets.CreateInlineGroup(containerParent, "Portrait Settings")

    GUIWidgets.CreateInformationTag(ToggleContainer, "|cFF8080FF3D Portraits|r will |cFFFF4040NOT|r work in instances, as they are now secret. |cFF8080FF2D Portraits|r will be used as a fallback if this is the case.")

    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel("Enable |cFF8080FFPortrait|r")
    Toggle:SetValue(PortraitDB.Enabled)
    Toggle:SetCallback("OnValueChanged", function(_, _, value) PortraitDB.Enabled = value updateCallback() RefreshPortraitGUI() end)
    Toggle:SetRelativeWidth(0.33)
    ToggleContainer:AddChild(Toggle)

    local UseClassPortraitToggle = AG:Create("CheckBox")
    UseClassPortraitToggle:SetLabel("Use Class Portrait")
    UseClassPortraitToggle:SetValue(PortraitDB.UseClassPortrait)
    UseClassPortraitToggle:SetCallback("OnValueChanged", function(_, _, value) PortraitDB.UseClassPortrait = value updateCallback() end)
    UseClassPortraitToggle:SetRelativeWidth(0.33)
    ToggleContainer:AddChild(UseClassPortraitToggle)

    local PortraitStyleDropdown = AG:Create("Dropdown")
    PortraitStyleDropdown:SetList({["2D"] = "2D", ["3D"] = "3D"})
    PortraitStyleDropdown:SetLabel("Portrait Style")
    PortraitStyleDropdown:SetValue(PortraitDB.Style)
    PortraitStyleDropdown:SetRelativeWidth(0.33)
    PortraitStyleDropdown:SetCallback("OnValueChanged", function(_, _, value) PortraitDB.Style = value updateCallback() RefreshPortraitGUI() end)
    ToggleContainer:AddChild(PortraitStyleDropdown)

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Layout & Positioning")

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(PortraitDB.Layout[1])
    AnchorFromDropdown:SetRelativeWidth(0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) PortraitDB.Layout[1] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(PortraitDB.Layout[2])
    AnchorToDropdown:SetRelativeWidth(0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) PortraitDB.Layout[2] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorToDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(PortraitDB.Layout[3])
    XPosSlider:SetSliderValues(-3000, 3000, 0.1)
    XPosSlider:SetRelativeWidth(0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) PortraitDB.Layout[3] = value updateCallback() end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(PortraitDB.Layout[4])
    YPosSlider:SetSliderValues(-3000, 3000, 0.1)
    YPosSlider:SetRelativeWidth(0.33)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) PortraitDB.Layout[4] = value updateCallback() end)
    LayoutContainer:AddChild(YPosSlider)

    local ZoomSlider = AG:Create("Slider")
    ZoomSlider:SetLabel("Zoom")
    ZoomSlider:SetValue(PortraitDB.Zoom)
    ZoomSlider:SetSliderValues(0, 1, 0.01)
    ZoomSlider:SetRelativeWidth(0.33)
    ZoomSlider:SetCallback("OnValueChanged", function(_, _, value) PortraitDB.Zoom = value updateCallback() end)
    ZoomSlider:SetIsPercent(true)
    LayoutContainer:AddChild(ZoomSlider)

    local WidthSlider = AG:Create("Slider")
    WidthSlider:SetLabel("Width")
    WidthSlider:SetValue(PortraitDB.Width)
    WidthSlider:SetSliderValues(8, 128, 0.1)
    WidthSlider:SetRelativeWidth(0.5)
    WidthSlider:SetCallback("OnValueChanged", function(_, _, value) PortraitDB.Width = value updateCallback() end)
    LayoutContainer:AddChild(WidthSlider)

    local HeightSlider = AG:Create("Slider")
    HeightSlider:SetLabel("Height")
    HeightSlider:SetValue(PortraitDB.Height)
    HeightSlider:SetSliderValues(8, 128, 0.1)
    HeightSlider:SetRelativeWidth(0.5)
    HeightSlider:SetCallback("OnValueChanged", function(_, _, value) PortraitDB.Height = value updateCallback() end)
    LayoutContainer:AddChild(HeightSlider)

    function RefreshPortraitGUI()
        if PortraitDB.Enabled then
            GUIWidgets.DeepDisable(ToggleContainer, false, Toggle)
            GUIWidgets.DeepDisable(LayoutContainer, false, Toggle)
        else
            GUIWidgets.DeepDisable(ToggleContainer, true, Toggle)
            GUIWidgets.DeepDisable(LayoutContainer, true, Toggle)
        end
        UseClassPortraitToggle:SetDisabled(not PortraitDB.Enabled or PortraitDB.Style ~= "2D")
        ZoomSlider:SetDisabled(not PortraitDB.Enabled or PortraitDB.Style ~= "2D")
    end

    RefreshPortraitGUI()
end

local function CreateRaidTargetMarkerSettings(containerParent, unit, updateCallback)
    local RaidTargetMarkerDB = UUF.db.profile.Units[unit].Indicators.RaidTargetMarker

    local ToggleContainer = GUIWidgets.CreateInlineGroup(containerParent, "Raid Target Marker Settings")

    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel("Enable |cFF8080FFRaid Target Marker|r Indicator")
    Toggle:SetValue(RaidTargetMarkerDB.Enabled)
    Toggle:SetCallback("OnValueChanged", function(_, _, value) RaidTargetMarkerDB.Enabled = value updateCallback() RefreshStatusGUI() end)
    Toggle:SetRelativeWidth(1)
    ToggleContainer:AddChild(Toggle)

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Layout & Positioning")

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(RaidTargetMarkerDB.Layout[1])
    AnchorFromDropdown:SetRelativeWidth(0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) RaidTargetMarkerDB.Layout[1] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(RaidTargetMarkerDB.Layout[2])
    AnchorToDropdown:SetRelativeWidth(0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) RaidTargetMarkerDB.Layout[2] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorToDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(RaidTargetMarkerDB.Layout[3])
    XPosSlider:SetSliderValues(-3000, 3000, 0.1)
    XPosSlider:SetRelativeWidth(0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) RaidTargetMarkerDB.Layout[3] = value updateCallback() end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(RaidTargetMarkerDB.Layout[4])
    YPosSlider:SetSliderValues(-3000, 3000, 0.1)
    YPosSlider:SetRelativeWidth(0.33)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) RaidTargetMarkerDB.Layout[4] = value updateCallback() end)
    LayoutContainer:AddChild(YPosSlider)

    local SizeSlider = AG:Create("Slider")
    SizeSlider:SetLabel("Size")
    SizeSlider:SetValue(RaidTargetMarkerDB.Size)
    SizeSlider:SetSliderValues(8, 64, 1)
    SizeSlider:SetRelativeWidth(0.33)
    SizeSlider:SetCallback("OnValueChanged", function(_, _, value) RaidTargetMarkerDB.Size = value updateCallback() end)
    LayoutContainer:AddChild(SizeSlider)

    function RefreshStatusGUI()
        if RaidTargetMarkerDB.Enabled then
            GUIWidgets.DeepDisable(ToggleContainer, false, Toggle)
            GUIWidgets.DeepDisable(LayoutContainer, false, Toggle)
        else
            GUIWidgets.DeepDisable(ToggleContainer, true, Toggle)
            GUIWidgets.DeepDisable(LayoutContainer, true, Toggle)
        end
    end

    RefreshStatusGUI()
end

local function CreateLeaderAssistaintSettings(containerParent, unit, updateCallback)
    local LeaderAssistantDB = UUF.db.profile.Units[unit].Indicators.LeaderAssistantIndicator

    local ToggleContainer = GUIWidgets.CreateInlineGroup(containerParent, "Leader & Assistant Settings")

    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel("Enable |cFF8080FFLeader|r & |cFF8080FFAssistant|r Indicator")
    Toggle:SetValue(LeaderAssistantDB.Enabled)
    Toggle:SetCallback("OnValueChanged", function(_, _, value) LeaderAssistantDB.Enabled = value updateCallback() RefreshStatusGUI() end)
    Toggle:SetRelativeWidth(1)
    ToggleContainer:AddChild(Toggle)

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Layout & Positioning")

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(LeaderAssistantDB.Layout[1])
    AnchorFromDropdown:SetRelativeWidth(0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) LeaderAssistantDB.Layout[1] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(LeaderAssistantDB.Layout[2])
    AnchorToDropdown:SetRelativeWidth(0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) LeaderAssistantDB.Layout[2] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorToDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(LeaderAssistantDB.Layout[3])
    XPosSlider:SetSliderValues(-3000, 3000, 0.1)
    XPosSlider:SetRelativeWidth(0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) LeaderAssistantDB.Layout[3] = value updateCallback() end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(LeaderAssistantDB.Layout[4])
    YPosSlider:SetSliderValues(-3000, 3000, 0.1)
    YPosSlider:SetRelativeWidth(0.33)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) LeaderAssistantDB.Layout[4] = value updateCallback() end)
    LayoutContainer:AddChild(YPosSlider)

    local SizeSlider = AG:Create("Slider")
    SizeSlider:SetLabel("Size")
    SizeSlider:SetValue(LeaderAssistantDB.Size)
    SizeSlider:SetSliderValues(8, 64, 1)
    SizeSlider:SetRelativeWidth(0.33)
    SizeSlider:SetCallback("OnValueChanged", function(_, _, value) LeaderAssistantDB.Size = value updateCallback() end)
    LayoutContainer:AddChild(SizeSlider)

    function RefreshStatusGUI()
        if LeaderAssistantDB.Enabled then
            GUIWidgets.DeepDisable(ToggleContainer, false, Toggle)
            GUIWidgets.DeepDisable(LayoutContainer, false, Toggle)
        else
            GUIWidgets.DeepDisable(ToggleContainer, true, Toggle)
            GUIWidgets.DeepDisable(LayoutContainer, true, Toggle)
        end
    end

    RefreshStatusGUI()
end

local function CreateRoleIndicatorSettings(containerParent, unit, updateCallback)
	local RoleDB = UUF.db.profile.Units[unit].Indicators.Role
	local ToggleContainer = GUIWidgets.CreateInlineGroup(containerParent, "Role Indicator Settings")
	local Toggle = AG:Create("CheckBox")
	Toggle:SetLabel("Enable |cFF8080FFRole|r Indicator")
	Toggle:SetValue(RoleDB.Enabled)
	Toggle:SetCallback("OnValueChanged", function(_, _, value) RoleDB.Enabled = value updateCallback() RefreshStatusGUI() end)
	Toggle:SetRelativeWidth(1)
	ToggleContainer:AddChild(Toggle)

	local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Layout & Positioning")
	local AnchorFromDropdown = AG:Create("Dropdown")
	AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
	AnchorFromDropdown:SetLabel("Anchor From")
	AnchorFromDropdown:SetValue(RoleDB.Layout[1])
	AnchorFromDropdown:SetRelativeWidth(0.5)
	AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) RoleDB.Layout[1] = value updateCallback() end)
	LayoutContainer:AddChild(AnchorFromDropdown)

	local AnchorToDropdown = AG:Create("Dropdown")
	AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
	AnchorToDropdown:SetLabel("Anchor To")
	AnchorToDropdown:SetValue(RoleDB.Layout[2])
	AnchorToDropdown:SetRelativeWidth(0.5)
	AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) RoleDB.Layout[2] = value updateCallback() end)
	LayoutContainer:AddChild(AnchorToDropdown)

	local XPosSlider = AG:Create("Slider")
	XPosSlider:SetLabel("X Position")
	XPosSlider:SetValue(RoleDB.Layout[3])
	XPosSlider:SetSliderValues(-3000, 3000, 0.1)
	XPosSlider:SetRelativeWidth(0.33)
	XPosSlider:SetCallback("OnValueChanged", function(_, _, value) RoleDB.Layout[3] = value updateCallback() end)
	LayoutContainer:AddChild(XPosSlider)

	local YPosSlider = AG:Create("Slider")
	YPosSlider:SetLabel("Y Position")
	YPosSlider:SetValue(RoleDB.Layout[4])
	YPosSlider:SetSliderValues(-3000, 3000, 0.1)
	YPosSlider:SetRelativeWidth(0.33)
	YPosSlider:SetCallback("OnValueChanged", function(_, _, value) RoleDB.Layout[4] = value updateCallback() end)
	LayoutContainer:AddChild(YPosSlider)

	local SizeSlider = AG:Create("Slider")
	SizeSlider:SetLabel("Size")
	SizeSlider:SetValue(RoleDB.Size)
	SizeSlider:SetSliderValues(8, 64, 1)
	SizeSlider:SetRelativeWidth(0.33)
	SizeSlider:SetCallback("OnValueChanged", function(_, _, value) RoleDB.Size = value updateCallback() end)
	LayoutContainer:AddChild(SizeSlider)

	function RefreshStatusGUI()
		GUIWidgets.DeepDisable(ToggleContainer, not RoleDB.Enabled, Toggle)
		GUIWidgets.DeepDisable(LayoutContainer, not RoleDB.Enabled)
	end

	RefreshStatusGUI()
end

local function CreatePvPIndicatorSettings(containerParent, updateCallback)
    local PvPIndicatorDB = UUF.db.profile.Units.player.Indicators.PvP

    local ToggleContainer = GUIWidgets.CreateInlineGroup(containerParent, "PvP Indicator Settings")

    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel("Enable |cFF8080FFPvP|r Indicator")
    Toggle:SetValue(PvPIndicatorDB.Enabled)
    Toggle:SetCallback("OnValueChanged", function(_, _, value) PvPIndicatorDB.Enabled = value updateCallback() RefreshPvPIndicatorGUI() end)
    Toggle:SetRelativeWidth(1)
    ToggleContainer:AddChild(Toggle)

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Layout & Positioning")

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(PvPIndicatorDB.Layout[1])
    AnchorFromDropdown:SetRelativeWidth(0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) PvPIndicatorDB.Layout[1] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(PvPIndicatorDB.Layout[2])
    AnchorToDropdown:SetRelativeWidth(0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) PvPIndicatorDB.Layout[2] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorToDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(PvPIndicatorDB.Layout[3])
    XPosSlider:SetSliderValues(-3000, 3000, 0.1)
    XPosSlider:SetRelativeWidth(0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) PvPIndicatorDB.Layout[3] = value updateCallback() end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(PvPIndicatorDB.Layout[4])
    YPosSlider:SetSliderValues(-3000, 3000, 0.1)
    YPosSlider:SetRelativeWidth(0.33)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) PvPIndicatorDB.Layout[4] = value updateCallback() end)
    LayoutContainer:AddChild(YPosSlider)

    local SizeSlider = AG:Create("Slider")
    SizeSlider:SetLabel("Size")
    SizeSlider:SetValue(PvPIndicatorDB.Size)
    SizeSlider:SetSliderValues(8, 64, 1)
    SizeSlider:SetRelativeWidth(0.33)
    SizeSlider:SetCallback("OnValueChanged", function(_, _, value) PvPIndicatorDB.Size = value updateCallback() end)
    LayoutContainer:AddChild(SizeSlider)

    function RefreshPvPIndicatorGUI()
        if PvPIndicatorDB.Enabled then
            GUIWidgets.DeepDisable(ToggleContainer, false, Toggle)
            GUIWidgets.DeepDisable(LayoutContainer, false, Toggle)
        else
            GUIWidgets.DeepDisable(ToggleContainer, true, Toggle)
            GUIWidgets.DeepDisable(LayoutContainer, true, Toggle)
        end
    end

    RefreshPvPIndicatorGUI()
end

local function CreateQuestIndicatorSettings(containerParent, updateCallback)
    local QuestIndicatorDB = UUF.db.profile.Units.target.Indicators.Quest

    local ToggleContainer = GUIWidgets.CreateInlineGroup(containerParent, "Quest Indicator Settings")

    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel("Enable |cFF8080FFQuest|r Indicator")
    Toggle:SetValue(QuestIndicatorDB.Enabled)
    Toggle:SetCallback("OnValueChanged", function(_, _, value) QuestIndicatorDB.Enabled = value updateCallback() RefreshQuestIndicatorGUI() end)
    Toggle:SetRelativeWidth(0.5)
    ToggleContainer:AddChild(Toggle)

    local TextureDropdown = AG:Create("Dropdown")
    TextureDropdown:SetList({
        DEFAULT = "|TInterface\\TargetingFrame\\PortraitQuestBadge:20:20|t",
        QUEST0 = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Quest\\Quest01.png:20:6|t",
        QUEST1 = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Quest\\Quest02.png:20:20|t",
    }, {"DEFAULT", "QUEST0", "QUEST1"})
    TextureDropdown:SetLabel("Quest Texture")
    TextureDropdown:SetValue(QuestIndicatorDB.Texture or "DEFAULT")
    TextureDropdown:SetRelativeWidth(0.5)
    TextureDropdown:SetCallback("OnValueChanged", function(_, _, value) QuestIndicatorDB.Texture = value updateCallback() end)
    ToggleContainer:AddChild(TextureDropdown)

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Layout & Positioning")

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(QuestIndicatorDB.Layout[1])
    AnchorFromDropdown:SetRelativeWidth(0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) QuestIndicatorDB.Layout[1] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(QuestIndicatorDB.Layout[2])
    AnchorToDropdown:SetRelativeWidth(0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) QuestIndicatorDB.Layout[2] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorToDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(QuestIndicatorDB.Layout[3])
    XPosSlider:SetSliderValues(-3000, 3000, 0.1)
    XPosSlider:SetRelativeWidth(0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) QuestIndicatorDB.Layout[3] = value updateCallback() end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(QuestIndicatorDB.Layout[4])
    YPosSlider:SetSliderValues(-3000, 3000, 0.1)
    YPosSlider:SetRelativeWidth(0.33)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) QuestIndicatorDB.Layout[4] = value updateCallback() end)
    LayoutContainer:AddChild(YPosSlider)

    local SizeSlider = AG:Create("Slider")
    SizeSlider:SetLabel("Size")
    SizeSlider:SetValue(QuestIndicatorDB.Size)
    SizeSlider:SetSliderValues(8, 64, 1)
    SizeSlider:SetRelativeWidth(0.33)
    SizeSlider:SetCallback("OnValueChanged", function(_, _, value) QuestIndicatorDB.Size = value updateCallback() end)
    LayoutContainer:AddChild(SizeSlider)

    function RefreshQuestIndicatorGUI()
        if QuestIndicatorDB.Enabled then
            GUIWidgets.DeepDisable(ToggleContainer, false, Toggle)
            GUIWidgets.DeepDisable(LayoutContainer, false, Toggle)
        else
            GUIWidgets.DeepDisable(ToggleContainer, true, Toggle)
            GUIWidgets.DeepDisable(LayoutContainer, true, Toggle)
        end
    end

    RefreshQuestIndicatorGUI()
end

local function CreateClassificationIndicatorSettings(containerParent, updateCallback)
    local ClassificationIndicatorDB = UUF.db.profile.Units.target.Indicators.Classification

    local ToggleContainer = GUIWidgets.CreateInlineGroup(containerParent, "Classification Indicator Settings")

    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel("Enable |cFF8080FFClassification|r Indicator")
    Toggle:SetValue(ClassificationIndicatorDB.Enabled)
    Toggle:SetCallback("OnValueChanged", function(_, _, value) ClassificationIndicatorDB.Enabled = value updateCallback() RefreshClassificationIndicatorGUI() end)
    Toggle:SetRelativeWidth(0.5)
    ToggleContainer:AddChild(Toggle)

    local TextureDropdown = AG:Create("Dropdown")
    TextureDropdown:SetList({
        CLASSIFICATION0 = "|A:nameplates-icon-elite-gold:20:20|a |A:nameplates-icon-elite-silver:20:20|a |A:nameplates-icon-elite-silver:20:20|a |A:nameplates-icon-elite-gold:20:20|a",
        CLASSIFICATION1 = "|A:VignetteEvent-SuperTracked:20:20|a |A:VignetteEvent:20:20|a |A:VignetteKillElite-SuperTracked:20:20|a |A:vignettekillboss:20:20|a",
        CLASSIFICATION2 = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Classification\\Classic\\Elite.png:20:20|t |TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Classification\\Classic\\Rare.png:20:20|t |TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Classification\\Classic\\RareElite.png:20:20|t |TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Classification\\Classic\\WorldBoss.png:20:20|t",
        CLASSIFICATION3 = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Classification\\Minimalist\\Elite.png:20:20|t |TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Classification\\Minimalist\\Rare.png:20:20|t |TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Classification\\Minimalist\\RareElite.png:20:20|t |TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Classification\\Minimalist\\WorldBoss.png:20:20|t",
    }, {"CLASSIFICATION0", "CLASSIFICATION1", "CLASSIFICATION2", "CLASSIFICATION3"})
    TextureDropdown:SetLabel("Classification Texture")
    TextureDropdown:SetValue(ClassificationIndicatorDB.Texture or "DEFAULT")
    TextureDropdown:SetRelativeWidth(0.5)
    TextureDropdown:SetCallback("OnValueChanged", function(_, _, value) ClassificationIndicatorDB.Texture = value updateCallback() end)
    ToggleContainer:AddChild(TextureDropdown)

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Layout & Positioning")

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(ClassificationIndicatorDB.Layout[1])
    AnchorFromDropdown:SetRelativeWidth(0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) ClassificationIndicatorDB.Layout[1] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(ClassificationIndicatorDB.Layout[2])
    AnchorToDropdown:SetRelativeWidth(0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) ClassificationIndicatorDB.Layout[2] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorToDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(ClassificationIndicatorDB.Layout[3])
    XPosSlider:SetSliderValues(-3000, 3000, 0.1)
    XPosSlider:SetRelativeWidth(0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) ClassificationIndicatorDB.Layout[3] = value updateCallback() end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(ClassificationIndicatorDB.Layout[4])
    YPosSlider:SetSliderValues(-3000, 3000, 0.1)
    YPosSlider:SetRelativeWidth(0.33)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) ClassificationIndicatorDB.Layout[4] = value updateCallback() end)
    LayoutContainer:AddChild(YPosSlider)

    local SizeSlider = AG:Create("Slider")
    SizeSlider:SetLabel("Size")
    SizeSlider:SetValue(ClassificationIndicatorDB.Size)
    SizeSlider:SetSliderValues(8, 64, 1)
    SizeSlider:SetRelativeWidth(0.33)
    SizeSlider:SetCallback("OnValueChanged", function(_, _, value) ClassificationIndicatorDB.Size = value updateCallback() end)
    LayoutContainer:AddChild(SizeSlider)

    function RefreshClassificationIndicatorGUI()
        GUIWidgets.DeepDisable(ToggleContainer, not ClassificationIndicatorDB.Enabled, Toggle)
        GUIWidgets.DeepDisable(LayoutContainer, not ClassificationIndicatorDB.Enabled, Toggle)
    end

    RefreshClassificationIndicatorGUI()
end

local function CreateStatusSettings(containerParent, unit, statusDB, updateCallback)
    local StatusDB = UUF.db.profile.Units[unit].Indicators[statusDB]

    local ToggleContainer = GUIWidgets.CreateInlineGroup(containerParent, statusDB .. " Settings")

    local StatusTextureList = {}
    for key, texture in pairs(StatusTextures[statusDB]) do
        StatusTextureList[key] = texture
    end

    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel("Enable |cFF8080FF"..statusDB.."|r Indicator")
    Toggle:SetValue(StatusDB.Enabled)
    Toggle:SetCallback("OnValueChanged", function(_, _, value) StatusDB.Enabled = value updateCallback() RefreshStatusGUI() end)
    Toggle:SetRelativeWidth(0.5)
    ToggleContainer:AddChild(Toggle)

    local StatusTextureDropdown = AG:Create("Dropdown")
    StatusTextureDropdown:SetList(StatusTextureList)
    StatusTextureDropdown:SetLabel(statusDB .. " Texture")
    StatusTextureDropdown:SetValue(StatusDB.Texture)
    StatusTextureDropdown:SetRelativeWidth(0.5)
    StatusTextureDropdown:SetCallback("OnValueChanged", function(_, _, value) StatusDB.Texture = value updateCallback() end)
    ToggleContainer:AddChild(StatusTextureDropdown)

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Layout & Positioning")

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(StatusDB.Layout[1])
    AnchorFromDropdown:SetRelativeWidth(0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) StatusDB.Layout[1] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(StatusDB.Layout[2])
    AnchorToDropdown:SetRelativeWidth(0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) StatusDB.Layout[2] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorToDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(StatusDB.Layout[3])
    XPosSlider:SetSliderValues(-3000, 3000, 0.1)
    XPosSlider:SetRelativeWidth(0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) StatusDB.Layout[3] = value updateCallback() end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(StatusDB.Layout[4])
    YPosSlider:SetSliderValues(-3000, 3000, 0.1)
    YPosSlider:SetRelativeWidth(0.33)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) StatusDB.Layout[4] = value updateCallback() end)
    LayoutContainer:AddChild(YPosSlider)

    local SizeSlider = AG:Create("Slider")
    SizeSlider:SetLabel("Size")
    SizeSlider:SetValue(StatusDB.Size)
    SizeSlider:SetSliderValues(8, 64, 1)
    SizeSlider:SetRelativeWidth(0.33)
    SizeSlider:SetCallback("OnValueChanged", function(_, _, value) StatusDB.Size = value updateCallback() end)
    LayoutContainer:AddChild(SizeSlider)

    function RefreshStatusGUI()
        if StatusDB.Enabled then
            GUIWidgets.DeepDisable(ToggleContainer, false, Toggle)
            GUIWidgets.DeepDisable(LayoutContainer, false, Toggle)
        else
            GUIWidgets.DeepDisable(ToggleContainer, true, Toggle)
            GUIWidgets.DeepDisable(LayoutContainer, true, Toggle)
        end
    end

    RefreshStatusGUI()
end

local function CreateMouseoverSettings(containerParent, unit, updateCallback)
    local MouseoverDB = UUF.db.profile.Units[unit].Indicators.Mouseover

    local ToggleContainer = GUIWidgets.CreateInlineGroup(containerParent, "Mouseover Settings")

    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel("Enable |cFF8080FFMouseover|r Highlight")
    Toggle:SetValue(MouseoverDB.Enabled)
    Toggle:SetCallback("OnValueChanged", function(_, _, value) MouseoverDB.Enabled = value updateCallback() RefreshMouseoverGUI() end)
    Toggle:SetRelativeWidth(1)
    ToggleContainer:AddChild(Toggle)

    local ColourPicker = AG:Create("ColorPicker")
    ColourPicker:SetLabel("Highlight Colour")
    ColourPicker:SetColor(MouseoverDB.Colour[1], MouseoverDB.Colour[2], MouseoverDB.Colour[3])
    ColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b) MouseoverDB.Colour = {r, g, b} updateCallback() end)
    ColourPicker:SetHasAlpha(false)
    ColourPicker:SetRelativeWidth(0.33)
    ToggleContainer:AddChild(ColourPicker)

    local OpacitySlider = AG:Create("Slider")
    OpacitySlider:SetLabel("Highlight Opacity")
    OpacitySlider:SetValue(MouseoverDB.HighlightOpacity)
    OpacitySlider:SetSliderValues(0, 1, 0.01)
    OpacitySlider:SetRelativeWidth(0.33)
    OpacitySlider:SetCallback("OnValueChanged", function(_, _, value) MouseoverDB.HighlightOpacity = value updateCallback() end)
    OpacitySlider:SetIsPercent(true)
    ToggleContainer:AddChild(OpacitySlider)

    local StyleDropdown = AG:Create("Dropdown")
    StyleDropdown:SetList({["BORDER"] = "Border", ["OVERLAY"] = "Overlay", ["GRADIENT"] = "Gradient" })
    StyleDropdown:SetLabel("Highlight Style")
    StyleDropdown:SetValue(MouseoverDB.Style)
    StyleDropdown:SetRelativeWidth(0.33)
    StyleDropdown:SetCallback("OnValueChanged", function(_, _, value) MouseoverDB.Style = value updateCallback() end)
    ToggleContainer:AddChild(StyleDropdown)

    function RefreshMouseoverGUI()
        if MouseoverDB.Enabled then
            GUIWidgets.DeepDisable(ToggleContainer, false, Toggle)
        else
            GUIWidgets.DeepDisable(ToggleContainer, true, Toggle)
        end
    end

    RefreshMouseoverGUI()
end

local function CreateTargetIndicatorSettings(containerParent, unit, updateCallback)
    local TargetIndicatorDB = UUF.db.profile.Units[unit].Indicators.Target

    local ToggleContainer = GUIWidgets.CreateInlineGroup(containerParent, "Target Indicator Settings")

    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel("Enable |cFF8080FFTarget Indicator|r")
    Toggle:SetValue(TargetIndicatorDB.Enabled)
    Toggle:SetCallback("OnValueChanged", function(_, _, value) TargetIndicatorDB.Enabled = value updateCallback() RefreshTargetIndicatorGUI() end)
    Toggle:SetRelativeWidth(0.5)
    ToggleContainer:AddChild(Toggle)

    local ColourPicker = AG:Create("ColorPicker")
    ColourPicker:SetLabel("Indicator Colour")
    ColourPicker:SetColor(TargetIndicatorDB.Colour[1], TargetIndicatorDB.Colour[2], TargetIndicatorDB.Colour[3])
    ColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b) TargetIndicatorDB.Colour = {r, g, b} updateCallback() end)
    ColourPicker:SetHasAlpha(false)
    ColourPicker:SetRelativeWidth(0.5)
    ToggleContainer:AddChild(ColourPicker)

    function RefreshTargetIndicatorGUI()
        if TargetIndicatorDB.Enabled then
            GUIWidgets.DeepDisable(ToggleContainer, false, Toggle)
        else
            GUIWidgets.DeepDisable(ToggleContainer, true, Toggle)
        end
    end

    RefreshTargetIndicatorGUI()
end

local function CreateTotemsIndicatorSettings(containerParent, unit, updateCallback)
    local TotemsIndicatorDB = UUF.db.profile.Units[unit].Indicators.Totems

    local ToggleContainer = GUIWidgets.CreateInlineGroup(containerParent, "Totems Settings")

    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel("Enable |cFF8080FFTotems|r")
    Toggle:SetValue(TotemsIndicatorDB.Enabled)
    Toggle:SetCallback("OnValueChanged", function(_, _, value) TotemsIndicatorDB.Enabled = value updateCallback() RefreshTotemsIndicatorGUI() end)
    Toggle:SetRelativeWidth(1)
    ToggleContainer:AddChild(Toggle)

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Layout & Positioning")
    local TotemAnchorFromDropdown = AG:Create("Dropdown")
    TotemAnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    TotemAnchorFromDropdown:SetLabel("Anchor From")
    TotemAnchorFromDropdown:SetValue(TotemsIndicatorDB.Layout[1])
    TotemAnchorFromDropdown:SetRelativeWidth(0.33)
    TotemAnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) TotemsIndicatorDB.Layout[1] = value updateCallback() end)
    LayoutContainer:AddChild(TotemAnchorFromDropdown)

    local TotemAnchorToDropdown = AG:Create("Dropdown")
    TotemAnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    TotemAnchorToDropdown:SetLabel("Anchor To")
    TotemAnchorToDropdown:SetValue(TotemsIndicatorDB.Layout[2])
    TotemAnchorToDropdown:SetRelativeWidth(0.33)
    TotemAnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) TotemsIndicatorDB.Layout[2] = value updateCallback() end)
    LayoutContainer:AddChild(TotemAnchorToDropdown)

    local GrowthDirectionDropdown = AG:Create("Dropdown")
    GrowthDirectionDropdown:SetList({["RIGHT"] = "Right", ["LEFT"] = "Left"})
    GrowthDirectionDropdown:SetLabel("Growth Direction")
    GrowthDirectionDropdown:SetValue(TotemsIndicatorDB.GrowthDirection)
    GrowthDirectionDropdown:SetRelativeWidth(0.33)
    GrowthDirectionDropdown:SetCallback("OnValueChanged", function(_, _, value) TotemsIndicatorDB.GrowthDirection = value updateCallback() end)
    LayoutContainer:AddChild(GrowthDirectionDropdown)

    local TotemXPosSlider = AG:Create("Slider")
    TotemXPosSlider:SetLabel("X Position")
    TotemXPosSlider:SetValue(TotemsIndicatorDB.Layout[3])
    TotemXPosSlider:SetSliderValues(-3000, 3000, 0.1)
    TotemXPosSlider:SetRelativeWidth(0.25)
    TotemXPosSlider:SetCallback("OnValueChanged", function(_, _, value) TotemsIndicatorDB.Layout[3] = value updateCallback() end)
    LayoutContainer:AddChild(TotemXPosSlider)

    local TotemYPosSlider = AG:Create("Slider")
    TotemYPosSlider:SetLabel("Y Position")
    TotemYPosSlider:SetValue(TotemsIndicatorDB.Layout[4])
    TotemYPosSlider:SetSliderValues(-3000, 3000, 0.1)
    TotemYPosSlider:SetRelativeWidth(0.25)
    TotemYPosSlider:SetCallback("OnValueChanged", function(_, _, value) TotemsIndicatorDB.Layout[4] = value updateCallback() end)
    LayoutContainer:AddChild(TotemYPosSlider)

    local SpacingSlider = AG:Create("Slider")
    SpacingSlider:SetLabel("Totems Indicator Spacing")
    SpacingSlider:SetValue(TotemsIndicatorDB.Layout[5])
    SpacingSlider:SetSliderValues(0, 100, 1)
    SpacingSlider:SetRelativeWidth(0.25)
    SpacingSlider:SetCallback("OnValueChanged", function(_, _, value) TotemsIndicatorDB.Layout[5] = value updateCallback() end)
    LayoutContainer:AddChild(SpacingSlider)

    local SizeSlider = AG:Create("Slider")
    SizeSlider:SetLabel("Icon Size")
    SizeSlider:SetValue(TotemsIndicatorDB.Size)
    SizeSlider:SetSliderValues(8, 64, 1)
    SizeSlider:SetRelativeWidth(0.25)
    SizeSlider:SetCallback("OnValueChanged", function(_, _, value) TotemsIndicatorDB.Size = value updateCallback() end)
    LayoutContainer:AddChild(SizeSlider)

    function RefreshTotemsIndicatorGUI()
        if TotemsIndicatorDB.Enabled then
            GUIWidgets.DeepDisable(ToggleContainer, false, Toggle)
            GUIWidgets.DeepDisable(LayoutContainer, false)
        else
            GUIWidgets.DeepDisable(ToggleContainer, true, Toggle)
            GUIWidgets.DeepDisable(LayoutContainer, true)
        end
    end

    RefreshTotemsIndicatorGUI()
end

local function CreateIndicatorSettings(containerParent, unit)
    local function SelectIndicatorTab(IndicatorContainer, _, IndicatorTab)
        SaveSubTab(unit, "Indicators", IndicatorTab)
        IndicatorContainer:ReleaseChildren()
        if IndicatorTab == "RaidTargetMarker" then
            CreateRaidTargetMarkerSettings(IndicatorContainer, unit, function() UpdateConfiguredUnit(unit, UUF.UpdateUnitRaidTargetMarker) end)
        elseif IndicatorTab == "LeaderAssistant" then
            CreateLeaderAssistaintSettings(IndicatorContainer, unit, function() UpdateConfiguredUnit(unit, UUF.UpdateUnitLeaderAssistantIndicator) end)
        elseif IndicatorTab == "Role" then
			CreateRoleIndicatorSettings(IndicatorContainer, unit, function() UpdateConfiguredUnit(unit, UUF.UpdateUnitRoleIndicator) end)
        elseif IndicatorTab == "Resting" then
            CreateStatusSettings(IndicatorContainer, unit, "Resting", function() UUF:UpdateUnitRestingIndicator(UUF[unit:upper()], unit) end)
        elseif IndicatorTab == "Combat" then
            CreateStatusSettings(IndicatorContainer, unit, "Combat", function() UUF:UpdateUnitCombatIndicator(UUF[unit:upper()], unit) end)
        elseif IndicatorTab == "PvP" and unit == "player" then
            CreatePvPIndicatorSettings(IndicatorContainer, function() UUF:UpdateUnitPvPIndicator(UUF.PLAYER, "player") end)
        elseif IndicatorTab == "Mouseover" then
            CreateMouseoverSettings(IndicatorContainer, unit, function() UpdateConfiguredUnit(unit, UUF.UpdateUnitMouseoverIndicator) end)
        elseif IndicatorTab == "TargetIndicator" then
            CreateTargetIndicatorSettings(IndicatorContainer, unit, function() UpdateConfiguredUnit(unit, UUF.UpdateUnitTargetGlowIndicator) end)
        elseif IndicatorTab == "Totems" then
            CreateTotemsIndicatorSettings(IndicatorContainer, unit, function() UUF:UpdateUnitTotems(UUF[unit:upper()], unit) end)
        elseif IndicatorTab == "Quest" and unit == "target" then
            CreateQuestIndicatorSettings(IndicatorContainer, function() UUF:UpdateUnitQuestIndicator(UUF.TARGET, "target") end)
        elseif IndicatorTab == "Classification" and unit == "target" then
            CreateClassificationIndicatorSettings(IndicatorContainer, function() UUF:UpdateUnitClassificationIndicator(UUF.TARGET, "target") end)
        end
    end

    local IndicatorContainerTabGroup = AG:Create("TabGroup")
    IndicatorContainerTabGroup:SetLayout("Flow")
    IndicatorContainerTabGroup:SetFullWidth(true)
    if unit == "player" then
        IndicatorContainerTabGroup:SetTabs({
            { text = "Raid Target Marker", value = "RaidTargetMarker" },
            { text = "Leader & Assistant", value = "LeaderAssistant" },
            { text = "Resting", value = "Resting" },
            { text = "Combat", value = "Combat" },
            { text = "PvP", value = "PvP" },
            { text = "Mouseover", value = "Mouseover" },
            { text = "Totems", value = "Totems" },
        })
    elseif unit == "target" then
        IndicatorContainerTabGroup:SetTabs({
            { text = "Raid Target Marker", value = "RaidTargetMarker" },
            { text = "Leader & Assistant", value = "LeaderAssistant" },
            { text = "Combat", value = "Combat" },
            { text = "Mouseover", value = "Mouseover" },
            { text = "Target Indicator", value = "TargetIndicator" },
            { text = "Classification", value = "Classification" },
            { text = "Quest", value = "Quest" },
        })
    elseif unit == "party" or unit == "raid" then
        IndicatorContainerTabGroup:SetTabs({
            { text = "Raid Target Marker", value = "RaidTargetMarker" },
            { text = "Leader & Assistant", value = "LeaderAssistant" },
            { text = "Role", value = "Role" },
            { text = "Mouseover", value = "Mouseover" },
            { text = "Target Indicator", value = "TargetIndicator" },
        })
    elseif unit == "targettarget" or unit == "focus" or unit == "focustarget" or unit == "pet" or unit == "boss" then
        IndicatorContainerTabGroup:SetTabs({
            { text = "Raid Target Marker", value = "RaidTargetMarker" },
            { text = "Mouseover", value = "Mouseover" },
            { text = "Target Indicator", value = "TargetIndicator" },
        })
    end
    IndicatorContainerTabGroup:SetCallback("OnGroupSelected", SelectIndicatorTab)
    IndicatorContainerTabGroup:SelectTab(GetSavedSubTab(unit, "Indicators", "RaidTargetMarker"))
    containerParent:AddChild(IndicatorContainerTabGroup)
end

local function CreateTagSetting(containerParent, unit, tagDB)
    local TagDB = UUF.db.profile.Units[unit].Tags[tagDB]

    local TagContainer = GUIWidgets.CreateInlineGroup(containerParent, "Tag Settings")

    local EditBox = AG:Create("EditBox")
    EditBox:SetLabel("Tag")
    EditBox:SetText(TagDB.Tag)
    EditBox:SetRelativeWidth(0.5)
    EditBox:DisableButton(true)
    EditBox:SetCallback("OnEnterPressed", function(_, _, value) TagDB.Tag = value EditBox:SetText(TagDB.Tag) UpdateConfiguredUnit(unit, UUF.UpdateUnitTag, tagDB) end)
    TagContainer:AddChild(EditBox)

    local ColourPicker = AG:Create("ColorPicker")
    ColourPicker:SetLabel("Colour")
    ColourPicker:SetColor(TagDB.Colour[1], TagDB.Colour[2], TagDB.Colour[3], 1)
    ColourPicker:SetFullWidth(true)
    ColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b) TagDB.Colour = {r, g, b} UpdateConfiguredUnit(unit, UUF.UpdateUnitTag, tagDB) end)
    ColourPicker:SetHasAlpha(false)
    ColourPicker:SetRelativeWidth(0.5)
    TagContainer:AddChild(ColourPicker)

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Layout & Positioning")

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(TagDB.Layout[1])
    AnchorFromDropdown:SetRelativeWidth(0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) TagDB.Layout[1] = value UpdateConfiguredUnit(unit, UUF.UpdateUnitTag, tagDB) end)
    LayoutContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(TagDB.Layout[2])
    AnchorToDropdown:SetRelativeWidth(0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) TagDB.Layout[2] = value UpdateConfiguredUnit(unit, UUF.UpdateUnitTag, tagDB) end)
    LayoutContainer:AddChild(AnchorToDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(TagDB.Layout[3])
    XPosSlider:SetSliderValues(-3000, 3000, 0.1)
    XPosSlider:SetRelativeWidth(0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) TagDB.Layout[3] = value UpdateConfiguredUnit(unit, UUF.UpdateUnitTag, tagDB) end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(TagDB.Layout[4])
    YPosSlider:SetSliderValues(-3000, 3000, 0.1)
    YPosSlider:SetRelativeWidth(0.33)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) TagDB.Layout[4] = value UpdateConfiguredUnit(unit, UUF.UpdateUnitTag, tagDB) end)
    LayoutContainer:AddChild(YPosSlider)

    local FontSizeSlider = AG:Create("Slider")
    FontSizeSlider:SetLabel("Font Size")
    FontSizeSlider:SetValue(TagDB.FontSize)
    FontSizeSlider:SetSliderValues(8, 64, 1)
    FontSizeSlider:SetRelativeWidth(0.33)
    FontSizeSlider:SetCallback("OnValueChanged", function(_, _, value) TagDB.FontSize = value UpdateConfiguredUnit(unit, UUF.UpdateUnitTag, tagDB) end)
    LayoutContainer:AddChild(FontSizeSlider)

    local TagSelectionContainer = GUIWidgets.CreateInlineGroup(containerParent, "Tag Selection")
    GUIWidgets.CreateInformationTag(TagSelectionContainer, "You can use the dropdowns below to quickly add tags.\n|cFF8080FFPrefix|r indicates that this should be added to the start of the tag string.")

    local HealthTagDropdown = AG:Create("Dropdown")
    HealthTagDropdown:SetList(UUF:FetchTagData("Health")[1], UUF:FetchTagData("Health")[2])
    HealthTagDropdown:SetLabel("Health Tags")
    HealthTagDropdown:SetValue(nil)
    HealthTagDropdown:SetRelativeWidth(0.5)
    HealthTagDropdown:SetCallback("OnValueChanged", function(_, _, value) local currentTag = TagDB.Tag if currentTag and currentTag ~= "" then currentTag = currentTag .. "[" .. value .. "]" else currentTag = "[" .. value .. "]" end EditBox:SetText(currentTag) UUF.db.profile.Units[unit].Tags[tagDB].Tag = currentTag UpdateConfiguredUnit(unit, UUF.UpdateUnitTag, tagDB) HealthTagDropdown:SetValue(nil) end)
    TagSelectionContainer:AddChild(HealthTagDropdown)

    local PowerTagDropdown = AG:Create("Dropdown")
    PowerTagDropdown:SetList(UUF:FetchTagData("Power")[1], UUF:FetchTagData("Power")[2])
    PowerTagDropdown:SetLabel("Power Tags")
    PowerTagDropdown:SetValue(nil)
    PowerTagDropdown:SetRelativeWidth(0.5)
    PowerTagDropdown:SetCallback("OnValueChanged", function(_, _, value) local currentTag = TagDB.Tag if currentTag and currentTag ~= "" then currentTag = currentTag .. "[" .. value .. "]" else currentTag = "[" .. value .. "]" end EditBox:SetText(currentTag) UUF.db.profile.Units[unit].Tags[tagDB].Tag = currentTag UpdateConfiguredUnit(unit, UUF.UpdateUnitTag, tagDB) PowerTagDropdown:SetValue(nil) end)
    TagSelectionContainer:AddChild(PowerTagDropdown)

    local NameTagDropdown = AG:Create("Dropdown")
    NameTagDropdown:SetList(UUF:FetchTagData("Name")[1], UUF:FetchTagData("Name")[2])
    NameTagDropdown:SetLabel("Name Tags")
    NameTagDropdown:SetValue(nil)
    NameTagDropdown:SetRelativeWidth(0.5)
    NameTagDropdown:SetCallback("OnValueChanged", function(_, _, value) local currentTag = TagDB.Tag if currentTag and currentTag ~= "" then currentTag = currentTag .. "[" .. value .. "]" else currentTag = "[" .. value .. "]" end EditBox:SetText(currentTag) UUF.db.profile.Units[unit].Tags[tagDB].Tag = currentTag UpdateConfiguredUnit(unit, UUF.UpdateUnitTag, tagDB) NameTagDropdown:SetValue(nil) end)
    TagSelectionContainer:AddChild(NameTagDropdown)

    local MiscTagDropdown = AG:Create("Dropdown")
    MiscTagDropdown:SetList(UUF:FetchTagData("Misc")[1], UUF:FetchTagData("Misc")[2])
    MiscTagDropdown:SetLabel("Misc Tags")
    MiscTagDropdown:SetValue(nil)
    MiscTagDropdown:SetRelativeWidth(0.5)
    MiscTagDropdown:SetCallback("OnValueChanged", function(_, _, value) local currentTag = TagDB.Tag if currentTag and currentTag ~= "" then currentTag = currentTag .. "[" .. value .. "]" else currentTag = "[" .. value .. "]" end EditBox:SetText(currentTag) UUF.db.profile.Units[unit].Tags[tagDB].Tag = currentTag UpdateConfiguredUnit(unit, UUF.UpdateUnitTag, tagDB) MiscTagDropdown:SetValue(nil) end)
    MiscTagDropdown:SetDisabled(#UUF:FetchTagData("Misc") == 0)
    TagSelectionContainer:AddChild(MiscTagDropdown)

    containerParent:DoLayout()
end

local function CreateTagsSettings(containerParent, unit)

    local function SelectTagTab(TagContainer, _, TagTab)
        SaveSubTab(unit, "Tags", TagTab)
        TagContainer:ReleaseChildren()
        CreateTagSetting(TagContainer, unit, TagTab)
        containerParent:DoLayout()
    end

    local TagContainerTabGroup = AG:Create("TabGroup")
    TagContainerTabGroup:SetLayout("Flow")
    TagContainerTabGroup:SetFullWidth(true)
    TagContainerTabGroup:SetTabs({
        { text = "Tag One", value = "TagOne"},
        { text = "Tag Two", value = "TagTwo"},
        { text = "Tag Three", value = "TagThree"},
        { text = "Tag Four", value = "TagFour"},
        { text = "Tag Five", value = "TagFive"},
    })
    TagContainerTabGroup:SetCallback("OnGroupSelected", SelectTagTab)
    TagContainerTabGroup:SelectTab(GetSavedSubTab(unit, "Tags", "TagOne"))
    containerParent:AddChild(TagContainerTabGroup)

    containerParent:DoLayout()
end

local function CreateSpecificAuraSettings(containerParent, unit, auraDB)
    local AuraDB = UUF.db.profile.Units[unit].Auras[auraDB]
    local isCustom = auraDB == "Custom"
    local filterAuraDB = auraDB == "Custom" and (AuraDB.Type == "Debuffs" and "Debuffs" or "Buffs") or auraDB
    local auraTitle = auraDB == "Custom" and filterAuraDB or auraDB

    local AuraContainer = GUIWidgets.CreateInlineGroup(containerParent, auraTitle .. " Settings")

    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel("Enable |cFF8080FF"..auraDB.."|r")
    Toggle:SetValue(AuraDB.Enabled)
    Toggle:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Enabled = value UpdateConfiguredUnit(unit, UUF.UpdateUnitAuras, auraDB) RefreshAuraGUI() end)
    Toggle:SetRelativeWidth(isCustom and 0.5 or 0.33)
    AuraContainer:AddChild(Toggle)

    if auraDB == "Custom" then
        local TypeDropdown = AG:Create("Dropdown")
        TypeDropdown:SetList({["Buffs"] = "Buffs", ["Debuffs"] = "Debuffs"}, {"Buffs", "Debuffs"})
        TypeDropdown:SetLabel("Type")
        TypeDropdown:SetValue(filterAuraDB)
        TypeDropdown:SetRelativeWidth(isCustom and 0.5 or 0.33)
        TypeDropdown:SetCallback("OnValueChanged", function(_, _, value)
            AuraDB.Type = value
            AuraDB.Filter = value == "Buffs" and "HELPFUL" or "HARMFUL"
            UpdateConfiguredUnit(unit, UUF.UpdateUnitAuras, auraDB)
            containerParent:ReleaseChildren()
            CreateSpecificAuraSettings(containerParent, unit, auraDB)
            containerParent:DoLayout()
        end)
        AuraContainer:AddChild(TypeDropdown)
    end

    local OnlyShowPlayerToggle = AG:Create("CheckBox")
    OnlyShowPlayerToggle:SetLabel("Only Show Player " .. auraTitle)
    OnlyShowPlayerToggle:SetValue(AuraDB.OnlyShowPlayer)
    OnlyShowPlayerToggle:SetCallback("OnValueChanged", function(_, _, value) AuraDB.OnlyShowPlayer = value UpdateConfiguredUnit(unit, UUF.UpdateUnitAuras, auraDB) RefreshAuraGUI() end)
    OnlyShowPlayerToggle:SetCallback("OnEnter", function() GameTooltip:SetOwner(OnlyShowPlayerToggle.frame, "ANCHOR_CURSOR") GameTooltip:AddLine("Overrides |cFF8080FF" .. auraTitle:lower() .. "|r advanced filters. If |cFF8080FFBlacklist|r is checked, it will be respected.", 1, 1, 1, true) GameTooltip:Show() end)
    OnlyShowPlayerToggle:SetCallback("OnLeave", function() GameTooltip:Hide() end)
    OnlyShowPlayerToggle:SetRelativeWidth(isCustom and 0.5 or 0.33)
    AuraContainer:AddChild(OnlyShowPlayerToggle)

    local ShowTypeCheckbox = AG:Create("CheckBox")
    ShowTypeCheckbox:SetLabel("Show " .. auraTitle .. " Type Border")
    ShowTypeCheckbox:SetValue(AuraDB.ShowType)
    ShowTypeCheckbox:SetCallback("OnValueChanged", function(_, _, value) AuraDB.ShowType = value UpdateConfiguredUnit(unit, UUF.UpdateUnitAuras, auraDB) end)
    ShowTypeCheckbox:SetRelativeWidth(isCustom and 0.5 or 0.33)
    AuraContainer:AddChild(ShowTypeCheckbox)

    local FilterContainer = GUIWidgets.CreateInlineGroup(containerParent, auraTitle .. " Filters")
    AuraDB.Filters = AuraDB.Filters or {}

    local BlacklistToggle = AG:Create("CheckBox")
    BlacklistToggle:SetLabel("Blacklist")
    BlacklistToggle:SetValue(AuraDB.Blacklist or false)
    BlacklistToggle:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Blacklist = value UpdateConfiguredUnit(unit, UUF.UpdateUnitAuras, auraDB) end)
    BlacklistToggle:SetRelativeWidth(auraDB == "Debuffs" and 0.33 or 0.5)
    FilterContainer:AddChild(BlacklistToggle)

    local FilterDropdowns = {}

    for _, filter in ipairs(UUF.AURA_FILTERS[filterAuraDB]) do
        if filter.Group == "General" then
            local filterKey = filter.Key
            local FilterToggle = AG:Create("CheckBox")
            FilterToggle:SetLabel(filter.Title)
            FilterToggle:SetValue(AuraDB.Filters[filterKey] or false)
            FilterToggle:SetRelativeWidth(0.33)
            FilterToggle:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Filters[filterKey] = value or nil UpdateConfiguredUnit(unit, UUF.UpdateUnitAuras, auraDB) RefreshAuraGUI() end)
            FilterToggle:SetCallback("OnEnter", function() GameTooltip:SetOwner(FilterToggle.frame, "ANCHOR_CURSOR") GameTooltip:AddLine(filter.Desc, 1, 1, 1, true) GameTooltip:Show() end)
            FilterToggle:SetCallback("OnLeave", function() GameTooltip:Hide() end)
            FilterContainer:AddChild(FilterToggle)
        end
    end

    GUIWidgets.CreateInformationTag(FilterContainer, "Dropdowns support |cFF8080FFmultiple selections|r. |cFFFFCC00Player|r is specifically you, where |cFFFFCC00Others|r are all other players/units.")

    for _, filterGroup in ipairs({"Player (You)", "Others (Not You)"}) do
        local filterList = {}
        local filterDesc = {}
        local filterOrder = {}
        local FilterDropdown = AG:Create("Dropdown")
        for _, filter in ipairs(UUF.AURA_FILTERS[filterAuraDB]) do
            if filter.Group == filterGroup then
                filterList[filter.Key] = filter.Title
                filterDesc[filter.Key] = filter.Desc
                filterOrder[#filterOrder + 1] = filter.Key
            end
        end
        FilterDropdown:SetLabel(filterGroup .. " Filters")
        FilterDropdown:SetMultiselect(true)
        FilterDropdown:SetList(filterList, filterOrder)
        for _, dropdownItem in FilterDropdown.pullout:IterateItems() do
            local desc = filterDesc[dropdownItem.userdata and dropdownItem.userdata.value]
            if desc then
                dropdownItem:SetCallback("OnEnter", function() GameTooltip:SetOwner(dropdownItem.frame, "ANCHOR_CURSOR_RIGHT") GameTooltip:SetFrameStrata("TOOLTIP") GameTooltip:SetFrameLevel((FilterDropdown.pullout.frame:GetFrameLevel() or 0) + 100) GameTooltip:SetToplevel(true) GameTooltip:AddLine(desc, 1, 1, 1, false) GameTooltip:Show() GameTooltip:SetFrameLevel((FilterDropdown.pullout.frame:GetFrameLevel() or 0) + 100) end)
                dropdownItem:SetCallback("OnLeave", function() GameTooltip:Hide() end)
            end
        end
        for _, filterKey in ipairs(filterOrder) do FilterDropdown:SetItemValue(filterKey, AuraDB.Filters[filterKey] or false) end
        FilterDropdown:SetRelativeWidth(0.5)
        FilterDropdown:SetCallback("OnValueChanged", function(_, _, filterKey, value) AuraDB.Filters[filterKey] = value or nil UpdateConfiguredUnit(unit, UUF.UpdateUnitAuras, auraDB) end)
        FilterContainer:AddChild(FilterDropdown)
        FilterDropdowns[#FilterDropdowns + 1] = FilterDropdown
    end

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Layout & Positioning")

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(AuraDB.Layout[1])
    AnchorFromDropdown:SetRelativeWidth(0.33)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Layout[1] = value UpdateConfiguredUnit(unit, UUF.UpdateUnitAuras, auraDB) end)
    LayoutContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(AuraDB.Layout[2])
    AnchorToDropdown:SetRelativeWidth(0.33)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Layout[2] = value UpdateConfiguredUnit(unit, UUF.UpdateUnitAuras, auraDB) end)
    LayoutContainer:AddChild(AnchorToDropdown)

    local SortingDropdown = AG:Create("Dropdown")
    SortingDropdown:SetList({
        BLIZZARD = "Blizzard",
        BLIZZARD_REVERSED = "Blizzard Reversed",
        DURATION = "Duration",
        DURATION_REVERSED = "Duration Reversed",
    }, {"BLIZZARD", "BLIZZARD_REVERSED", "DURATION", "DURATION_REVERSED"})
    SortingDropdown:SetLabel("Aura Sorting")
    SortingDropdown:SetValue(AuraDB.Sorting or "BLIZZARD")
    SortingDropdown:SetRelativeWidth(0.33)
    SortingDropdown:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Sorting = value UpdateConfiguredUnit(unit, UUF.UpdateUnitAuras, auraDB) end)
    for _, dropdownItem in SortingDropdown.pullout:IterateItems() do
        local value = dropdownItem.userdata and dropdownItem.userdata.value
        local desc = value == "BLIZZARD" and "|cFF00B4FFBlizzard|r's Default Ordering."
            or value == "BLIZZARD_REVERSED" and "|cFF00B4FFBlizzard|r's Default Ordering in Reverse."
            or value == "DURATION" and "|cFF8080FFDuration-Based|r Ordering.\nAuras with the shortest remaining duration will be displayed first."
            or value == "DURATION_REVERSED" and "|cFF8080FFDuration-Based|r Ordering in Reverse.\nAuras with the longest remaining duration will be displayed first."
        if desc then
            dropdownItem:SetCallback("OnEnter", function() GameTooltip:SetOwner(dropdownItem.frame, "ANCHOR_CURSOR_RIGHT") GameTooltip:SetFrameStrata("TOOLTIP") GameTooltip:SetFrameLevel((SortingDropdown.pullout.frame:GetFrameLevel() or 0) + 100) GameTooltip:SetToplevel(true) GameTooltip:AddLine(desc, 1, 1, 1, false) GameTooltip:Show() GameTooltip:SetFrameLevel((SortingDropdown.pullout.frame:GetFrameLevel() or 0) + 100) end)
            dropdownItem:SetCallback("OnLeave", function() GameTooltip:Hide() end)
        end
    end
    LayoutContainer:AddChild(SortingDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(AuraDB.Layout[3])
    XPosSlider:SetSliderValues(-3000, 3000, 0.1)
    XPosSlider:SetRelativeWidth(0.25)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Layout[3] = value UpdateConfiguredUnit(unit, UUF.UpdateUnitAuras, auraDB) end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(AuraDB.Layout[4])
    YPosSlider:SetSliderValues(-3000, 3000, 0.1)
    YPosSlider:SetRelativeWidth(0.25)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Layout[4] = value UpdateConfiguredUnit(unit, UUF.UpdateUnitAuras, auraDB) end)
    LayoutContainer:AddChild(YPosSlider)

    local SizeSlider = AG:Create("Slider")
    SizeSlider:SetLabel("Size")
    SizeSlider:SetValue(AuraDB.Size)
    SizeSlider:SetSliderValues(8, 64, 1)
    SizeSlider:SetRelativeWidth(0.25)
    SizeSlider:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Size = value UpdateConfiguredUnit(unit, UUF.UpdateUnitAuras, auraDB) end)
    LayoutContainer:AddChild(SizeSlider)

    local SpacingSlider = AG:Create("Slider")
    SpacingSlider:SetLabel("Spacing")
    SpacingSlider:SetValue(AuraDB.Layout[5])
    SpacingSlider:SetSliderValues(-5, 5, 1)
    SpacingSlider:SetRelativeWidth(0.25)
    SpacingSlider:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Layout[5] = value UpdateConfiguredUnit(unit, UUF.UpdateUnitAuras, auraDB) end)
    LayoutContainer:AddChild(SpacingSlider)

    GUIWidgets.CreateHeader(LayoutContainer, "Layout")

    local NumAurasSlider = AG:Create("Slider")
    NumAurasSlider:SetLabel(auraTitle .. " To Display")
    NumAurasSlider:SetValue(AuraDB.Num)
    NumAurasSlider:SetSliderValues(1, 24, 1)
    NumAurasSlider:SetRelativeWidth(0.5)
    NumAurasSlider:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Num = value UpdateConfiguredUnit(unit, UUF.UpdateUnitAuras, auraDB) end)
    LayoutContainer:AddChild(NumAurasSlider)

    local PerRowSlider = AG:Create("Slider")
    PerRowSlider:SetLabel(auraTitle .. " Per Row")
    PerRowSlider:SetValue(AuraDB.Wrap)
    PerRowSlider:SetSliderValues(1, 24, 1)
    PerRowSlider:SetRelativeWidth(0.5)
    PerRowSlider:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Wrap = value UpdateConfiguredUnit(unit, UUF.UpdateUnitAuras, auraDB) end)
    LayoutContainer:AddChild(PerRowSlider)

    local GrowthDirectionDropdown = AG:Create("Dropdown")
    GrowthDirectionDropdown:SetList({ ["LEFT"] = "Left", ["RIGHT"] = "Right"})
    GrowthDirectionDropdown:SetLabel("Growth Direction")
    GrowthDirectionDropdown:SetValue(AuraDB.GrowthDirection)
    GrowthDirectionDropdown:SetRelativeWidth(0.5)
    GrowthDirectionDropdown:SetCallback("OnValueChanged", function(_, _, value) AuraDB.GrowthDirection = value UpdateConfiguredUnit(unit, UUF.UpdateUnitAuras, auraDB) end)
    LayoutContainer:AddChild(GrowthDirectionDropdown)

    local WrapDirectionDropdown = AG:Create("Dropdown")
    WrapDirectionDropdown:SetList({ ["UP"] = "Up", ["DOWN"] = "Down"})
    WrapDirectionDropdown:SetLabel("Wrap Direction")
    WrapDirectionDropdown:SetValue(AuraDB.WrapDirection)
    WrapDirectionDropdown:SetRelativeWidth(0.5)
    WrapDirectionDropdown:SetCallback("OnValueChanged", function(_, _, value) AuraDB.WrapDirection = value UpdateConfiguredUnit(unit, UUF.UpdateUnitAuras, auraDB) end)
    LayoutContainer:AddChild(WrapDirectionDropdown)

    local CountContainer = GUIWidgets.CreateInlineGroup(containerParent, "Count Settings")

    local CountAnchorFromDropdown = AG:Create("Dropdown")
    CountAnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    CountAnchorFromDropdown:SetLabel("Anchor From")
    CountAnchorFromDropdown:SetValue(AuraDB.Count.Layout[1])
    CountAnchorFromDropdown:SetRelativeWidth(0.5)
    CountAnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Count.Layout[1] = value UpdateConfiguredUnit(unit, UUF.UpdateUnitAuras, auraDB) end)
    CountContainer:AddChild(CountAnchorFromDropdown)

    local CountAnchorToDropdown = AG:Create("Dropdown")
    CountAnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    CountAnchorToDropdown:SetLabel("Anchor To")
    CountAnchorToDropdown:SetValue(AuraDB.Count.Layout[2])
    CountAnchorToDropdown:SetRelativeWidth(0.5)
    CountAnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Count.Layout[2] = value UpdateConfiguredUnit(unit, UUF.UpdateUnitAuras, auraDB) end)
    CountContainer:AddChild(CountAnchorToDropdown)

    local CountXPosSlider = AG:Create("Slider")
    CountXPosSlider:SetLabel("X Position")
    CountXPosSlider:SetValue(AuraDB.Count.Layout[3])
    CountXPosSlider:SetSliderValues(-3000, 3000, 0.1)
    CountXPosSlider:SetRelativeWidth(0.25)
    CountXPosSlider:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Count.Layout[3] = value UpdateConfiguredUnit(unit, UUF.UpdateUnitAuras, auraDB) end)
    CountContainer:AddChild(CountXPosSlider)

    local CountYPosSlider = AG:Create("Slider")
    CountYPosSlider:SetLabel("Y Position")
    CountYPosSlider:SetValue(AuraDB.Count.Layout[4])
    CountYPosSlider:SetSliderValues(-3000, 3000, 0.1)
    CountYPosSlider:SetRelativeWidth(0.25)
    CountYPosSlider:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Count.Layout[4] = value UpdateConfiguredUnit(unit, UUF.UpdateUnitAuras, auraDB) end)
    CountContainer:AddChild(CountYPosSlider)

    local FontSizeSlider = AG:Create("Slider")
    FontSizeSlider:SetLabel("Font Size")
    FontSizeSlider:SetValue(AuraDB.Count.FontSize)
    FontSizeSlider:SetSliderValues(8, 64, 1)
    FontSizeSlider:SetRelativeWidth(0.25)
    FontSizeSlider:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Count.FontSize = value UpdateConfiguredUnit(unit, UUF.UpdateUnitAuras, auraDB) end)
    CountContainer:AddChild(FontSizeSlider)

    local ColourPicker = AG:Create("ColorPicker")
    ColourPicker:SetLabel("Colour")
    ColourPicker:SetColor(AuraDB.Count.Colour[1], AuraDB.Count.Colour[2], AuraDB.Count.Colour[3], 1)
    ColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b) AuraDB.Count.Colour = {r, g, b} UpdateConfiguredUnit(unit, UUF.UpdateUnitAuras, auraDB) end)
    ColourPicker:SetHasAlpha(false)
    ColourPicker:SetRelativeWidth(0.25)
    CountContainer:AddChild(ColourPicker)

    function RefreshAuraGUI()
        if AuraDB.Enabled then
            GUIWidgets.DeepDisable(AuraContainer, false, Toggle)
            GUIWidgets.DeepDisable(FilterContainer, AuraDB.OnlyShowPlayer, BlacklistToggle)
            for _, FilterDropdown in ipairs(FilterDropdowns) do FilterDropdown:SetDisabled(AuraDB.OnlyShowPlayer or (filterAuraDB == "Debuffs" and AuraDB.Filters.Typed)) end
            GUIWidgets.DeepDisable(LayoutContainer, false, Toggle)
            GUIWidgets.DeepDisable(CountContainer, false, Toggle)
        else
            GUIWidgets.DeepDisable(AuraContainer, true, Toggle)
            GUIWidgets.DeepDisable(FilterContainer, true, Toggle)
            GUIWidgets.DeepDisable(LayoutContainer, true, Toggle)
            GUIWidgets.DeepDisable(CountContainer, true, Toggle)
        end
    end

    RefreshAuraGUI()

    containerParent:DoLayout()
end

local function CreatePrivateAuraSettings(containerParent, unit)
    local PrivateAurasDB = UUF.db.profile.Units[unit].Auras.PrivateAuras
	local function UpdatePrivateAuras() UpdateConfiguredUnit(unit, UUF.UpdateUnitAuras) end

    local GeneralContainer = GUIWidgets.CreateInlineGroup(containerParent, "Private Aura Settings")
    GUIWidgets.CreateInformationTag(GeneralContainer, "Private Auras are controlled by |cFF00B0F7Blizzard|r. The options below are as far as customization will allow.")

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Layout & Positioning")
    local SizeContainer = GUIWidgets.CreateInlineGroup(containerParent, "Size & Spacing")

    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel("Enable |cFF8080FFPrivate Auras|r")
    Toggle:SetValue(PrivateAurasDB.Enabled)
    Toggle:SetRelativeWidth(0.33)
    Toggle:SetCallback("OnValueChanged", function(_, _, value)
        PrivateAurasDB.Enabled = value
        UpdatePrivateAuras()
        GUIWidgets.DeepDisable(GeneralContainer, not value, Toggle)
        GUIWidgets.DeepDisable(LayoutContainer, not value)
        GUIWidgets.DeepDisable(SizeContainer, not value)
    end)
    GeneralContainer:AddChild(Toggle)

    local DisableCooldownToggle = AG:Create("CheckBox")
    DisableCooldownToggle:SetLabel("Disable Cooldown Spiral")
    DisableCooldownToggle:SetValue(PrivateAurasDB.DisableCooldown)
    DisableCooldownToggle:SetRelativeWidth(0.33)
    DisableCooldownToggle:SetCallback("OnValueChanged", function(_, _, value) PrivateAurasDB.DisableCooldown = value UpdatePrivateAuras() end)
    GeneralContainer:AddChild(DisableCooldownToggle)

    local DisableCooldownTextToggle = AG:Create("CheckBox")
    DisableCooldownTextToggle:SetLabel("Disable Cooldown Text")
    DisableCooldownTextToggle:SetValue(PrivateAurasDB.DisableCooldownText)
    DisableCooldownTextToggle:SetRelativeWidth(0.33)
    DisableCooldownTextToggle:SetCallback("OnValueChanged", function(_, _, value) PrivateAurasDB.DisableCooldownText = value UpdatePrivateAuras() end)
    GeneralContainer:AddChild(DisableCooldownTextToggle)

    local BorderScaleSlider = AG:Create("Slider")
    BorderScaleSlider:SetLabel("Border Scale")
    BorderScaleSlider:SetValue(PrivateAurasDB.BorderScale == -100 and -1 or PrivateAurasDB.BorderScale)
    BorderScaleSlider:SetSliderValues(-1, 3, 0.1)
    BorderScaleSlider:SetRelativeWidth(0.5)
    BorderScaleSlider:SetCallback("OnValueChanged", function(widget, _, value) if value < 0 then value = -1 widget:SetValue(value) end PrivateAurasDB.BorderScale = value UpdatePrivateAuras() end)
    GeneralContainer:AddChild(BorderScaleSlider)

    local FrameStrataDropdown = AG:Create("Dropdown")
    FrameStrataDropdown:SetList(FrameStrataList[1], FrameStrataList[2])
    FrameStrataDropdown:SetLabel("Frame Strata")
    FrameStrataDropdown:SetValue(PrivateAurasDB.FrameStrata)
    FrameStrataDropdown:SetRelativeWidth(0.5)
    FrameStrataDropdown:SetCallback("OnValueChanged", function(_, _, value) PrivateAurasDB.FrameStrata = value UpdatePrivateAuras() end)
    GeneralContainer:AddChild(FrameStrataDropdown)

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(PrivateAurasDB.Layout[1])
    AnchorFromDropdown:SetRelativeWidth(0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) PrivateAurasDB.Layout[1] = value UpdatePrivateAuras() end)
    LayoutContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(PrivateAurasDB.Layout[2])
    AnchorToDropdown:SetRelativeWidth(0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) PrivateAurasDB.Layout[2] = value UpdatePrivateAuras() end)
    LayoutContainer:AddChild(AnchorToDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(PrivateAurasDB.Layout[3])
    XPosSlider:SetSliderValues(-3000, 3000, 0.1)
    XPosSlider:SetRelativeWidth(0.5)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) PrivateAurasDB.Layout[3] = value UpdatePrivateAuras() end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(PrivateAurasDB.Layout[4])
    YPosSlider:SetSliderValues(-3000, 3000, 0.1)
    YPosSlider:SetRelativeWidth(0.5)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) PrivateAurasDB.Layout[4] = value UpdatePrivateAuras() end)
    LayoutContainer:AddChild(YPosSlider)

    local InitialAnchorDropdown = AG:Create("Dropdown")
    InitialAnchorDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    InitialAnchorDropdown:SetLabel("Initial Aura Anchor")
    InitialAnchorDropdown:SetValue(PrivateAurasDB.InitialAnchor)
    InitialAnchorDropdown:SetRelativeWidth(0.33)
    InitialAnchorDropdown:SetCallback("OnValueChanged", function(_, _, value) PrivateAurasDB.InitialAnchor = value UpdatePrivateAuras() end)
    LayoutContainer:AddChild(InitialAnchorDropdown)

    local GrowthXDropdown = AG:Create("Dropdown")
    GrowthXDropdown:SetList({["LEFT"] = "Left", ["RIGHT"] = "Right"}, {"LEFT", "RIGHT"})
    GrowthXDropdown:SetLabel("Horizontal Growth")
    GrowthXDropdown:SetValue(PrivateAurasDB.GrowthX)
    GrowthXDropdown:SetRelativeWidth(0.33)
    GrowthXDropdown:SetCallback("OnValueChanged", function(_, _, value) PrivateAurasDB.GrowthX = value UpdatePrivateAuras() end)
    LayoutContainer:AddChild(GrowthXDropdown)

    local GrowthYDropdown = AG:Create("Dropdown")
    GrowthYDropdown:SetList({["UP"] = "Up", ["DOWN"] = "Down"}, {"UP", "DOWN"})
    GrowthYDropdown:SetLabel("Vertical Growth")
    GrowthYDropdown:SetValue(PrivateAurasDB.GrowthY)
    GrowthYDropdown:SetRelativeWidth(0.33)
    GrowthYDropdown:SetCallback("OnValueChanged", function(_, _, value) PrivateAurasDB.GrowthY = value UpdatePrivateAuras() end)
    LayoutContainer:AddChild(GrowthYDropdown)

    local SizeSlider = AG:Create("Slider")
    SizeSlider:SetLabel("Size")
    SizeSlider:SetValue(PrivateAurasDB.Size)
    SizeSlider:SetSliderValues(8, 128, 1)
    SizeSlider:SetRelativeWidth(0.33)
    SizeSlider:SetCallback("OnValueChanged", function(_, _, value) PrivateAurasDB.Size = value UpdatePrivateAuras() end)
    SizeContainer:AddChild(SizeSlider)

    local SpacingSlider = AG:Create("Slider")
    SpacingSlider:SetLabel("Spacing")
    SpacingSlider:SetValue(PrivateAurasDB.Spacing)
    SpacingSlider:SetSliderValues(-20, 100, 1)
    SpacingSlider:SetRelativeWidth(0.33)
    SpacingSlider:SetCallback("OnValueChanged", function(_, _, value) PrivateAurasDB.Spacing = value UpdatePrivateAuras() end)
    SizeContainer:AddChild(SpacingSlider)

    local NumSlider = AG:Create("Slider")
    NumSlider:SetLabel("Private Auras To Display")
    NumSlider:SetValue(PrivateAurasDB.Num)
    NumSlider:SetSliderValues(1, 12, 1)
    NumSlider:SetRelativeWidth(0.33)
    NumSlider:SetCallback("OnValueChanged", function(_, _, value) PrivateAurasDB.Num = value UpdatePrivateAuras() end)
    SizeContainer:AddChild(NumSlider)

    GUIWidgets.DeepDisable(GeneralContainer, not PrivateAurasDB.Enabled, Toggle)
    GUIWidgets.DeepDisable(LayoutContainer, not PrivateAurasDB.Enabled)
    GUIWidgets.DeepDisable(SizeContainer, not PrivateAurasDB.Enabled)

    containerParent:DoLayout()
end

local function CreateAuraSettings(containerParent, unit)
    local AurasDB = UUF.db.profile.Units[unit].Auras
    local FrameStrataDropdown = AG:Create("Dropdown")
    FrameStrataDropdown:SetList(FrameStrataList[1], FrameStrataList[2])
    FrameStrataDropdown:SetLabel("Frame Strata")
    FrameStrataDropdown:SetValue(AurasDB.FrameStrata)
    FrameStrataDropdown:SetRelativeWidth(1)
    FrameStrataDropdown:SetCallback("OnValueChanged", function(_, _, value) AurasDB.FrameStrata = value UUF:UpdateUnitAurasStrata(unit) end)
    containerParent:AddChild(FrameStrataDropdown)

    local function SelectAuraTab(AuraContainer, _, AuraTab)
        SaveSubTab(unit, "Auras", AuraTab)
        AuraContainer:ReleaseChildren()
        if AuraTab == "Buffs" then
            CreateSpecificAuraSettings(AuraContainer, unit, "Buffs")
        elseif AuraTab == "Debuffs" then
            CreateSpecificAuraSettings(AuraContainer, unit, "Debuffs")
        elseif AuraTab == "Custom" and AurasDB.Custom then
            CreateSpecificAuraSettings(AuraContainer, unit, "Custom")
        elseif AuraTab == "PrivateAuras" and AurasDB.PrivateAuras then
            CreatePrivateAuraSettings(AuraContainer, unit)
        end
        containerParent:DoLayout()
    end

    local AuraContainerTabGroup = AG:Create("TabGroup")
    AuraContainerTabGroup:SetLayout("Flow")
    AuraContainerTabGroup:SetFullWidth(true)
    if AurasDB.PrivateAuras then
        AuraContainerTabGroup:SetTabs({ { text = "Buffs", value = "Buffs"}, { text = "Debuffs", value = "Debuffs"}, { text = "Custom", value = "Custom"}, { text = "Private Auras", value = "PrivateAuras"}, })
    elseif AurasDB.Custom then
        AuraContainerTabGroup:SetTabs({ { text = "Buffs", value = "Buffs"}, { text = "Debuffs", value = "Debuffs"}, { text = "Custom", value = "Custom"}, })
    else
        AuraContainerTabGroup:SetTabs({ { text = "Buffs", value = "Buffs"}, { text = "Debuffs", value = "Debuffs"}, })
    end
    AuraContainerTabGroup:SetCallback("OnGroupSelected", SelectAuraTab)
    AuraContainerTabGroup:SelectTab(GetSavedSubTab(unit, "Auras", "Buffs"))
    containerParent:AddChild(AuraContainerTabGroup)

    containerParent:DoLayout()
end

local function CreateCooldownTextSettings(containerParent)
    local CooldownTextDB = UUF.db.profile.General.CooldownText
    local CooldownTextContainer = GUIWidgets.CreateInlineGroup(containerParent, "Cooldown Text Settings")

    local AdvancedToggle = AG:Create("CheckBox")
    AdvancedToggle:SetLabel("Advanced")
    AdvancedToggle:SetValue(CooldownTextDB.Advanced)
    AdvancedToggle:SetRelativeWidth(CooldownTextDB.Advanced and 1 or 0.5)
    AdvancedToggle:SetCallback("OnValueChanged", function(_, _, value) CooldownTextDB.Advanced = value UUF:UpdateAllUnitFrames() containerParent:ReleaseChildren() CreateCooldownTextSettings(containerParent) containerParent:DoLayout() end)
    AdvancedToggle:SetCallback("OnEnter", function() GameTooltip:SetOwner(AdvancedToggle.frame, "ANCHOR_CURSOR") GameTooltip:AddLine("Advanced Settings will allow you to customize cooldown text for each unit individually.", 1, 1, 1, true) GameTooltip:Show() end)
    AdvancedToggle:SetCallback("OnLeave", function() GameTooltip:Hide() end)
    CooldownTextContainer:AddChild(AdvancedToggle)

    local function CreateCooldownTextStyleSettings(StyleContainerParent, CooldownTextStyleDB)
        local ScaleByIconSizeCheckbox = AG:Create("CheckBox")
        ScaleByIconSizeCheckbox:SetLabel("Scale Cooldown Text By Icon Size")
        ScaleByIconSizeCheckbox:SetValue(CooldownTextStyleDB.ScaleByIconSize)
        ScaleByIconSizeCheckbox:SetRelativeWidth(CooldownTextDB.Advanced and 1 or 0.5)
        StyleContainerParent:AddChild(ScaleByIconSizeCheckbox)

        local AnchorFromDropdown = AG:Create("Dropdown")
        AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
        AnchorFromDropdown:SetLabel("Anchor From")
        AnchorFromDropdown:SetValue(CooldownTextStyleDB.Layout[1])
        AnchorFromDropdown:SetRelativeWidth(0.5)
        AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) CooldownTextStyleDB.Layout[1] = value UUF:UpdateAllUnitFrames() end)
        StyleContainerParent:AddChild(AnchorFromDropdown)

        local AnchorToDropdown = AG:Create("Dropdown")
        AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
        AnchorToDropdown:SetLabel("Anchor To")
        AnchorToDropdown:SetValue(CooldownTextStyleDB.Layout[2])
        AnchorToDropdown:SetRelativeWidth(0.5)
        AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) CooldownTextStyleDB.Layout[2] = value UUF:UpdateAllUnitFrames() end)
        StyleContainerParent:AddChild(AnchorToDropdown)

        local XPosSlider = AG:Create("Slider")
        XPosSlider:SetLabel("X Position")
        XPosSlider:SetValue(CooldownTextStyleDB.Layout[3])
        XPosSlider:SetSliderValues(-3000, 3000, 0.1)
        XPosSlider:SetRelativeWidth(0.33)
        XPosSlider:SetCallback("OnValueChanged", function(_, _, value) CooldownTextStyleDB.Layout[3] = value UUF:UpdateAllUnitFrames() end)
        StyleContainerParent:AddChild(XPosSlider)

        local YPosSlider = AG:Create("Slider")
        YPosSlider:SetLabel("Y Position")
        YPosSlider:SetValue(CooldownTextStyleDB.Layout[4])
        YPosSlider:SetSliderValues(-3000, 3000, 0.1)
        YPosSlider:SetRelativeWidth(0.33)
        YPosSlider:SetCallback("OnValueChanged", function(_, _, value) CooldownTextStyleDB.Layout[4] = value UUF:UpdateAllUnitFrames() end)
        StyleContainerParent:AddChild(YPosSlider)

        local FontSizeSlider = AG:Create("Slider")
        FontSizeSlider:SetLabel("Font Size")
        FontSizeSlider:SetValue(CooldownTextStyleDB.FontSize)
        FontSizeSlider:SetSliderValues(8, 64, 1)
        FontSizeSlider:SetRelativeWidth(0.33)
        FontSizeSlider:SetCallback("OnValueChanged", function(_, _, value) CooldownTextStyleDB.FontSize = value UUF:UpdateAllUnitFrames() end)
        FontSizeSlider:SetDisabled(CooldownTextStyleDB.ScaleByIconSize)
        StyleContainerParent:AddChild(FontSizeSlider)
        ScaleByIconSizeCheckbox:SetCallback("OnValueChanged", function(_, _, value) CooldownTextStyleDB.ScaleByIconSize = value FontSizeSlider:SetDisabled(value) UUF:UpdateAllUnitFrames() end)
    end

    if CooldownTextDB.Advanced then
        local function SelectCooldownTextTab(CooldownTextTabContainer, _, CooldownTextTab)
            CooldownTextTabContainer:ReleaseChildren()
            if CooldownTextTab == "Global" then
                CreateCooldownTextStyleSettings(CooldownTextTabContainer, CooldownTextDB)
            elseif CooldownTextTab == "Auras" then
                local function SelectAuraUnit(AuraUnitContainer, _, unit)
                    AuraUnitContainer:ReleaseChildren()
                    CreateCooldownTextStyleSettings(AuraUnitContainer, UUF.db.profile.Units[unit].Auras.AuraDuration)
                    containerParent:DoLayout()
                end

                local AuraUnitTabs = AG:Create("TabGroup")
                AuraUnitTabs:SetLayout("Flow")
                AuraUnitTabs:SetFullWidth(true)
                AuraUnitTabs:SetTabs({
                    { text = "Player", value = "player" },
                    { text = "Target", value = "target" },
                    { text = "Target of Target", value = "targettarget" },
                    { text = "Focus", value = "focus" },
                    { text = "Focus Target", value = "focustarget" },
                    { text = "Pet", value = "pet" },
                    { text = "Boss", value = "boss" },
                    { text = "Party", value = "party" },
					{ text = "Raid", value = "raid" },
                })
                AuraUnitTabs:SetCallback("OnGroupSelected", SelectAuraUnit)
                AuraUnitTabs:SelectTab("player")
                CooldownTextTabContainer:AddChild(AuraUnitTabs)
            end
            containerParent:DoLayout()
        end

        local CooldownTextTabs = AG:Create("TabGroup")
        CooldownTextTabs:SetLayout("Flow")
        CooldownTextTabs:SetFullWidth(true)
        CooldownTextTabs:SetTabs({
            { text = "Global", value = "Global" },
            { text = "Auras", value = "Auras" },
        })
        CooldownTextTabs:SetCallback("OnGroupSelected", SelectCooldownTextTab)
        CooldownTextTabs:SelectTab("Global")
        CooldownTextContainer:AddChild(CooldownTextTabs)
    else
        CreateCooldownTextStyleSettings(CooldownTextContainer, CooldownTextDB)
    end

    local Breakpoints = CooldownTextDB.CooldownBreakpoints
    local DefaultBreakpoints = UUF:GetDefaultDB().profile.General.CooldownText.CooldownBreakpoints
    for BreakpointIndex = 1, 5 do
        Breakpoints[BreakpointIndex] = Breakpoints[BreakpointIndex] or CopyTable(DefaultBreakpoints[BreakpointIndex])
        Breakpoints[BreakpointIndex].color = Breakpoints[BreakpointIndex].color or CopyTable(DefaultBreakpoints[BreakpointIndex].color)
    end
    while #Breakpoints > 5 do tremove(Breakpoints) end

    local BreakpointContainer = GUIWidgets.CreateInlineGroup(containerParent, "Cooldown Text Breakpoints")

    local function SelectBreakpoint(BreakpointTabContainer, _, BreakpointIndex)
        BreakpointTabContainer:ReleaseChildren()
        local BreakpointDB = Breakpoints[BreakpointIndex]

        local MinimumValue = AG:Create("EditBox")
        MinimumValue:SetLabel("Minimum Value in Seconds")
        MinimumValue:SetText(tostring(BreakpointDB.threshold or 0))
        MinimumValue:SetRelativeWidth(0.33)
        MinimumValue:SetCallback("OnEnterPressed", function(widget, _, value) value = tonumber(value) if not value then widget:SetText(tostring(BreakpointDB.threshold or 0)) return end BreakpointDB.threshold = value BreakpointDB.components = UUF:GetCooldownDurationComponents(BreakpointDB.displayStyle, value) UUF:UpdateAllUnitFrames() end)
        BreakpointTabContainer:AddChild(MinimumValue)

        local DisplayStyle = AG:Create("Dropdown")
        DisplayStyle:SetLabel("Display Style")
        DisplayStyle:SetList(CooldownBreakpointStyles[1], CooldownBreakpointStyles[2])
        DisplayStyle:SetValue(BreakpointDB.displayStyle)
        DisplayStyle:SetRelativeWidth(0.33)
        DisplayStyle:SetCallback("OnValueChanged", function(_, _, value)
            local DisplayStyleDB = CooldownBreakpointSettings[value]
            BreakpointDB.displayStyle = value
            BreakpointDB.step = DisplayStyleDB.step
            BreakpointDB.rounding = DisplayStyleDB.rounding
            BreakpointDB.format = CreateColor(unpack(BreakpointDB.color)):WrapTextInColorCode(DisplayStyleDB.format)
            BreakpointDB.components = UUF:GetCooldownDurationComponents(value, BreakpointDB.threshold or 0)
            UUF:UpdateAllUnitFrames()
        end)
        BreakpointTabContainer:AddChild(DisplayStyle)

        local ColourPicker = AG:Create("ColorPicker")
        ColourPicker:SetLabel("Colour")
        ColourPicker:SetColor(BreakpointDB.color[1], BreakpointDB.color[2], BreakpointDB.color[3], BreakpointDB.color[4] or 1)
        ColourPicker:SetHasAlpha(false)
        ColourPicker:SetRelativeWidth(0.33)
        ColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b) BreakpointDB.color = {r, g, b, 1} BreakpointDB.format = CreateColor(r, g, b, 1):WrapTextInColorCode(CooldownBreakpointSettings[BreakpointDB.displayStyle].format) UUF:UpdateAllUnitFrames() end)
        BreakpointTabContainer:AddChild(ColourPicker)
    end

    local BreakpointTabs = AG:Create("TabGroup")
    BreakpointTabs:SetLayout("Flow")
    BreakpointTabs:SetFullWidth(true)
    BreakpointTabs:SetTabs({
        { text = "Breakpoint 1", value = 1 },
        { text = "Breakpoint 2", value = 2 },
        { text = "Breakpoint 3", value = 3 },
        { text = "Breakpoint 4", value = 4 },
        { text = "Breakpoint 5", value = 5 },
    })
    BreakpointTabs:SetCallback("OnGroupSelected", SelectBreakpoint)
    BreakpointTabs:SelectTab(1)
    BreakpointContainer:AddChild(BreakpointTabs)
end

local function CreateGlobalSettings(containerParent)

    local GlobalContainer = GUIWidgets.CreateInlineGroup(containerParent, "Global Settings")

    local ToggleContainer = GUIWidgets.CreateInlineGroup(GlobalContainer, "Toggles")

    local ApplyColours = AG:Create("Button")
    ApplyColours:SetText("Colour Mode")
    ApplyColours:SetRelativeWidth(0.33)
    ApplyColours:SetCallback("OnClick", function()
        for _, unitDB in pairs(UUF.db.profile.Units) do
            unitDB.HealthBar.ColourByClass = true
            unitDB.HealthBar.ColourWhenTapped = true
			unitDB.HealthBar.ColourWhenDisconnected = true
            unitDB.HealthBar.ColourBackgroundByClass = false
        end
        UUF:UpdateAllUnitFrames()
    end)
    ToggleContainer:AddChild(ApplyColours)

    local RemoveColours = AG:Create("Button")
    RemoveColours:SetText("Dark Mode")
    RemoveColours:SetRelativeWidth(0.33)
    RemoveColours:SetCallback("OnClick", function()
        for _, unitDB in pairs(UUF.db.profile.Units) do
            unitDB.HealthBar.ColourByClass = false
            unitDB.HealthBar.ColourWhenTapped = false
			unitDB.HealthBar.ColourWhenDisconnected = false
            unitDB.HealthBar.ColourBackgroundByClass = false
        end
        UUF:UpdateAllUnitFrames()
    end)
    ToggleContainer:AddChild(RemoveColours)

    local DisplayLoginMessageToggle = AG:Create("CheckBox")
    DisplayLoginMessageToggle:SetLabel("Display Login Message")
    DisplayLoginMessageToggle:SetValue(UUF.db.global.DisplayLoginMessage)
    DisplayLoginMessageToggle:SetCallback("OnValueChanged", function(_, _, value) UUF.db.global.DisplayLoginMessage = value end)
    DisplayLoginMessageToggle:SetRelativeWidth(0.33)
    ToggleContainer:AddChild(DisplayLoginMessageToggle)

    CreateFontSettings(GlobalContainer)
    CreateTextureSettings(GlobalContainer)
    CreateRangeSettings(GlobalContainer)

    local TagContainer = GUIWidgets.CreateInlineGroup(GlobalContainer, "Tag Settings")

    local UseCustomAbbreviationsCheckbox = AG:Create("CheckBox")
    UseCustomAbbreviationsCheckbox:SetLabel("Custom Abbreviations")
    UseCustomAbbreviationsCheckbox:SetValue(UUF.db.profile.General.UseCustomAbbreviations)
    UseCustomAbbreviationsCheckbox:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.General.UseCustomAbbreviations = value UUF:UpdateUnitTags() end)
    UseCustomAbbreviationsCheckbox:SetRelativeWidth(0.25)
    TagContainer:AddChild(UseCustomAbbreviationsCheckbox)

    local TagIntervalSlider = AG:Create("Slider")
    TagIntervalSlider:SetLabel("Tag Updates Per Second")
    TagIntervalSlider:SetValue(1 / UUF.db.profile.General.TagUpdateInterval)
    TagIntervalSlider:SetSliderValues(1, 10, 0.5)
    TagIntervalSlider:SetRelativeWidth(0.25)
    TagIntervalSlider:SetCallback("OnValueChanged", function(_, _, value) UUF.TAG_UPDATE_INTERVAL = 1 / value UUF.db.profile.General.TagUpdateInterval = 1 / value UUF:SetTagUpdateInterval() UUF:UpdateUnitTags() end)
    TagContainer:AddChild(TagIntervalSlider)

    local SeparatorDropdown = AG:Create("Dropdown")
    SeparatorDropdown:SetList(UUF.SEPARATOR_TAGS[1], UUF.SEPARATOR_TAGS[2])
    SeparatorDropdown:SetLabel("Tag Separator")
    SeparatorDropdown:SetValue(UUF.db.profile.General.Separator)
    SeparatorDropdown:SetRelativeWidth(0.25)
    SeparatorDropdown:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.General.Separator = value UUF:UpdateUnitTags() end)
    SeparatorDropdown:SetCallback("OnEnter", function() GameTooltip:SetOwner(SeparatorDropdown.frame, "ANCHOR_BOTTOM") GameTooltip:AddLine("The separator chosen here is only applied to custom tags which are combined. Such as |cFF8080FF[curhpperhp]|r or |cFF8080FF[curhpperhp:abbr]|r", 1, 1, 1) GameTooltip:Show() end)
    SeparatorDropdown:SetCallback("OnLeave", function() GameTooltip:Hide() end)
    TagContainer:AddChild(SeparatorDropdown)

    local ToTSeparatorDropdown = AG:Create("Dropdown")
    ToTSeparatorDropdown:SetList(UUF.TOT_SEPARATOR_TAGS[1], UUF.TOT_SEPARATOR_TAGS[2])
    ToTSeparatorDropdown:SetLabel("ToT Separator")
    ToTSeparatorDropdown:SetValue(UUF.db.profile.General.ToTSeparator)
    ToTSeparatorDropdown:SetRelativeWidth(0.25)
    ToTSeparatorDropdown:SetCallback("OnValueChanged", function(_, _, value)
        UUF.db.profile.General.ToTSeparator = value
        UUF.TOT_SEPARATOR = value
        UUF:UpdateUnitTags()
    end)
    ToTSeparatorDropdown:SetCallback("OnEnter", function()
        GameTooltip:SetOwner(ToTSeparatorDropdown.frame, "ANCHOR_BOTTOM")
        GameTooltip:AddLine("Used as the prefix separator for Target of Target tags like |cFF8080FF[name:target]|r on your target frame.", 1, 1, 1)
        GameTooltip:Show()
    end)
    ToTSeparatorDropdown:SetCallback("OnLeave", function() GameTooltip:Hide() end)
    TagContainer:AddChild(ToTSeparatorDropdown)

    containerParent:DoLayout()
end

local function CreateUnitSettings(containerParent, unit)
    local EnableUnitFrameToggle = AG:Create("CheckBox")
    EnableUnitFrameToggle:SetLabel("Enable |cFF8080FF"..(UnitDBToUnitPrettyName[unit] or unit) .."|r")
    EnableUnitFrameToggle:SetValue(UUF.db.profile.Units[unit].Enabled)
    EnableUnitFrameToggle:SetCallback("OnValueChanged", function(_, _, value)
        StaticPopupDialogs["UUF_RELOAD_UI"] = {
            text = "You must reload to apply this change, do you want to reload now?",
            button1 = "Reload Now",
            button2 = "Later",
            showAlert = true,
            OnAccept = function() UUF.db.profile.Units[unit].Enabled= value C_UI.Reload() end,
            OnCancel = function() EnableUnitFrameToggle:SetValue(UUF.db.profile.Units[unit].Enabled) containerParent:DoLayout() end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
        }
        StaticPopup_Show("UUF_RELOAD_UI")
    end)
	EnableUnitFrameToggle:SetRelativeWidth(0.33)
    containerParent:AddChild(EnableUnitFrameToggle)

    local HideBlizzardToggle = AG:Create("CheckBox")
    HideBlizzardToggle:SetLabel("Hide Blizzard |cFF8080FF"..(UnitDBToUnitPrettyName[unit] or unit) .."|r")
    HideBlizzardToggle:SetValue(UUF.db.profile.Units[unit].ForceHideBlizzard)
    HideBlizzardToggle:SetCallback("OnValueChanged", function(_, _, value)
            StaticPopupDialogs["UUF_RELOAD_UI"] = {
            text = "You must reload to apply this change, do you want to reload now?",
            button1 = "Reload Now",
            button2 = "Later",
            showAlert = true,
            OnAccept = function() UUF.db.profile.Units[unit].ForceHideBlizzard = value C_UI.Reload() end,
            OnCancel = function() HideBlizzardToggle:SetValue(UUF.db.profile.Units[unit].ForceHideBlizzard) containerParent:DoLayout() end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
        }
        StaticPopup_Show("UUF_RELOAD_UI")
    end)
	HideBlizzardToggle:SetRelativeWidth(0.33)
    HideBlizzardToggle:SetDisabled(UUF.db.profile.Units[unit].Enabled)
    containerParent:AddChild(HideBlizzardToggle)

	local ToggleMoversButton = AG:Create("Button")
	ToggleMoversButton:SetText(UUF.MOVERS_UNLOCKED and "Lock Movers" or "Unlock Movers")
	ToggleMoversButton:SetRelativeWidth(0.33)
	ToggleMoversButton:SetCallback("OnClick", function() ToggleMoversButton:SetText(UUF:ToggleMovers() and "Lock Movers" or "Unlock Movers") end)
	containerParent:AddChild(ToggleMoversButton)

    local SettingsContainer = AG:Create("SimpleGroup")
    SettingsContainer:SetFullWidth(true)
    SettingsContainer:SetLayout("Flow")
    containerParent:AddChild(SettingsContainer)

    local playerClass = UnitClassBase("player")
    local playerHasSecondaryPower = playerClass == "DEATHKNIGHT" or UUF:GetSecondaryPowerType() ~= nil

    local function SelectUnitTab(SubContainer, _, UnitTab)
        if not lastSelectedUnitTabs[unit] then lastSelectedUnitTabs[unit] = {} end
        lastSelectedUnitTabs[unit].mainTab = UnitTab
        SubContainer:ReleaseChildren()
        if UnitTab == "Frame" then
            CreateFrameSettings(SubContainer, unit, UUF.db.profile.Units[unit].Frame.AnchorParent and true or false, function() UpdateConfiguredUnit(unit, UUF.UpdateUnitFrame) end)
        elseif UnitTab == "HealPrediction" then
            CreateHealPredictionSettings(SubContainer, unit, function() UpdateConfiguredUnit(unit, UUF.UpdateUnitHealPrediction) end)
        elseif UnitTab == "Auras" then
            CreateAuraSettings(SubContainer, unit)
        elseif UnitTab == "PowerBar" then
            CreatePowerBarSettings(SubContainer, unit, function() UpdateConfiguredUnit(unit, UUF.UpdateUnitPowerBar) end)
        elseif UnitTab == "SecondaryPowerBar" and unit == "player" and playerHasSecondaryPower then
            CreateSecondaryPowerBarSettings(SubContainer, unit, function() UUF:UpdateUnitSecondaryPowerBar(UUF[unit:upper()], unit) end)
        elseif UnitTab == "AlternativePowerBar" then
            CreateAlternativePowerBarSettings(SubContainer, unit, function() if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitAlternativePowerBar(UUF[unit:upper()], unit) end end)
        elseif UnitTab == "CastBar" then
            CreateCastBarSettings(SubContainer, unit)
        elseif UnitTab == "Portrait" then
            CreatePortraitSettings(SubContainer, unit, function() if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitPortrait(UUF[unit:upper()], unit) end end)
        elseif UnitTab == "Indicators" then
            CreateIndicatorSettings(SubContainer, unit)
        elseif UnitTab == "Tags" then
            CreateTagsSettings(SubContainer, unit)
        end
        if unit ~= "party" and unit ~= "raid" then
            if UnitTab == "Auras" then EnableAurasTestMode(unit) else DisableAurasTestMode(unit) end
            if UnitTab == "CastBar" then EnableCastBarTestMode(unit) else DisableCastBarTestMode(unit) end
        end
        containerParent:DoLayout()
    end

    local SubContainerTabGroup = AG:Create("TabGroup")
    SubContainerTabGroup:SetLayout("Flow")
    SubContainerTabGroup:SetFullWidth(true)

    if unit == "player" then
        local playerTabs = {
            { text = "Frame", value = "Frame"},
            { text = "Heal Prediction", value = "HealPrediction"},
            { text = "Auras", value = "Auras"},
            { text = "Power Bar", value = "PowerBar"},
            { text = "Cast Bar", value = "CastBar"},
            { text = "Portrait", value = "Portrait"},
            { text = "Indicators", value = "Indicators"},
            { text = "Tags", value = "Tags"},
        }

        local nextPowerTabIndex = 5
        if playerHasSecondaryPower then
            table.insert(playerTabs, nextPowerTabIndex, { text = "Secondary Power Bar", value = "SecondaryPowerBar"})
            nextPowerTabIndex = nextPowerTabIndex + 1
        end
        if UUF:RequiresAlternativePowerBar() then
            table.insert(playerTabs, nextPowerTabIndex, { text = "Alternative Power Bar", value = "AlternativePowerBar"})
        end

        SubContainerTabGroup:SetTabs(playerTabs)
    elseif unit == "party" or unit == "raid" then
        SubContainerTabGroup:SetTabs({
            { text = "Frame", value = "Frame"},
            { text = "Heal Prediction", value = "HealPrediction"},
            { text = "Auras", value = "Auras"},
            { text = "Power Bar", value = "PowerBar"},
            { text = "Indicators", value = "Indicators"},
            { text = "Tags", value = "Tags"},
        })
    elseif unit ~= "targettarget" and unit ~= "focustarget" then
        SubContainerTabGroup:SetTabs({
            { text = "Frame", value = "Frame"},
            { text = "Heal Prediction", value = "HealPrediction"},
            { text = "Auras", value = "Auras"},
            { text = "Power Bar", value = "PowerBar"},
            { text = "Cast Bar", value = "CastBar"},
            { text = "Portrait", value = "Portrait"},
            { text = "Indicators", value = "Indicators"},
            { text = "Tags", value = "Tags"},
        })
    else
        SubContainerTabGroup:SetTabs({
            { text = "Frame", value = "Frame"},
            { text = "Heal Prediction", value = "HealPrediction"},
            { text = "Auras", value = "Auras"},
            { text = "Power Bar", value = "PowerBar"},
            { text = "Indicators", value = "Indicators"},
            { text = "Tags", value = "Tags"},
        })
    end
    SubContainerTabGroup:SetCallback("OnGroupSelected", SelectUnitTab)
    local selectedTab = GetSavedMainTab(unit, "Frame")
    if selectedTab == "SecondaryPowerBar" and not playerHasSecondaryPower then selectedTab = "Frame" end
    SubContainerTabGroup:SelectTab(selectedTab)
    SettingsContainer:AddChild(SubContainerTabGroup)

    GUIWidgets.DeepDisable(SettingsContainer, not UUF.db.profile.Units[unit].Enabled)

    containerParent:DoLayout()
end

local function CreateTagSettings(containerParent)

    local function DrawTagContainer(TagContainer, TagGroup)
        local TagsList, TagOrder = UUF:FetchTagData(TagGroup)[1], UUF:FetchTagData(TagGroup)[2]

        local SortedTagsList = {}
        for _, tag in ipairs(TagOrder) do
            if TagsList[tag] then
                SortedTagsList[tag] = TagsList[tag]
            end
        end

        for _, Tag in ipairs(TagOrder) do
            local Desc = SortedTagsList[Tag]
            local TagDesc = AG:Create("Label")
            TagDesc:SetText(Desc)
            TagDesc:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
            TagDesc:SetRelativeWidth(0.5)
            TagContainer:AddChild(TagDesc)

            local TagValue = AG:Create("EditBox")
            TagValue:SetText("[" .. Tag .. "]")
            TagValue:SetCallback("OnTextChanged", function(widget, event, value) TagValue:ClearFocus() TagValue:SetText("[" .. Tag .. "]") end)
            TagValue:SetRelativeWidth(0.5)
            TagContainer:AddChild(TagValue)
        end
    end

    local function SelectedGroup(TagContainer, _, TagGroup)
        TagContainer:ReleaseChildren()
        if TagGroup == "Health" then
            DrawTagContainer(TagContainer, "Health")
        elseif TagGroup == "Name" then
            DrawTagContainer(TagContainer, "Name")
        elseif TagGroup == "Power" then
            DrawTagContainer(TagContainer, "Power")
        elseif TagGroup == "Misc" then
            DrawTagContainer(TagContainer, "Misc")
        end
        TagContainer:DoLayout()
    end

    local GUIContainerTabGroup = AG:Create("TabGroup")
    GUIContainerTabGroup:SetLayout("Flow")
    GUIContainerTabGroup:SetTabs({
        { text = "Health", value = "Health" },
        { text = "Name", value = "Name" },
        { text = "Power", value = "Power" },
        { text = "Miscellaneous", value = "Misc" },
    })
    GUIContainerTabGroup:SetCallback("OnGroupSelected", SelectedGroup)
    GUIContainerTabGroup:SelectTab("Health")
    GUIContainerTabGroup:SetFullWidth(true)
    containerParent:AddChild(GUIContainerTabGroup)
    containerParent:DoLayout()
end

local function CreateProfileSettings(containerParent)
    local profileKeys = {}
    local specProfilesList = {}
    local numSpecs = GetNumSpecializations()

    local ProfileContainer = GUIWidgets.CreateInlineGroup(containerParent, "Profile Management")

    local ActiveProfileHeading = AG:Create("Heading")
    ActiveProfileHeading:SetFullWidth(true)
    ProfileContainer:AddChild(ActiveProfileHeading)

    local function RefreshProfiles()
        wipe(profileKeys)
        local tmp = {}
        for _, name in ipairs(UUF.db:GetProfiles(tmp, true)) do profileKeys[name] = name end
        local profilesToDelete = {}
        for k, v in pairs(profileKeys) do profilesToDelete[k] = v end
        profilesToDelete[UUF.db:GetCurrentProfile()] = nil
        SelectProfileDropdown:SetList(profileKeys)
        CopyFromProfileDropdown:SetList(profileKeys)
        GlobalProfileDropdown:SetList(profileKeys)
        DeleteProfileDropdown:SetList(profilesToDelete)
        for i = 1, numSpecs do
            specProfilesList[i]:SetList(profileKeys)
            specProfilesList[i]:SetValue(UUF.db:GetDualSpecProfile(i))
        end
        SelectProfileDropdown:SetValue(UUF.db:GetCurrentProfile())
        GlobalProfileDropdown:SetValue((UUF.db.global.GlobalProfile and UUF.db.global.GlobalProfile ~= "" and UUF.db.global.GlobalProfile) or (UUF.db.global.GlobalProfileName and UUF.db.global.GlobalProfileName ~= "" and UUF.db.global.GlobalProfileName) or "Default")
        CopyFromProfileDropdown:SetValue(nil)
        DeleteProfileDropdown:SetValue(nil)
        if not next(profilesToDelete) then
            DeleteProfileDropdown:SetDisabled(true)
        else
            DeleteProfileDropdown:SetDisabled(false)
        end
        ResetProfileButton:SetText("Reset |cFF8080FF" .. UUF.db:GetCurrentProfile() .. "|r Profile")
        local isUsingGlobal = UUF.db.global.UseGlobalProfile
        ActiveProfileHeading:SetText( "Active Profile: |cFFFFFFFF" .. UUF.db:GetCurrentProfile() .. (isUsingGlobal and " (|cFF8080FFGlobal|r)" or "") .. "|r" )
        if UUF.db:IsDualSpecEnabled() then
            SelectProfileDropdown:SetDisabled(true)
            CopyFromProfileDropdown:SetDisabled(true)
            GlobalProfileDropdown:SetDisabled(true)
            DeleteProfileDropdown:SetDisabled(true)
            UseGlobalProfileToggle:SetDisabled(true)
            GlobalProfileDropdown:SetDisabled(true)
        else
            SelectProfileDropdown:SetDisabled(isUsingGlobal)
            CopyFromProfileDropdown:SetDisabled(isUsingGlobal)
            GlobalProfileDropdown:SetDisabled(not isUsingGlobal)
            DeleteProfileDropdown:SetDisabled(isUsingGlobal or not next(profilesToDelete))
            UseGlobalProfileToggle:SetDisabled(false)
            GlobalProfileDropdown:SetDisabled(not isUsingGlobal)
        end
    end

    UUFG.RefreshProfiles = RefreshProfiles -- Exposed for Share.lua

    SelectProfileDropdown = AG:Create("Dropdown")
    SelectProfileDropdown:SetLabel("Select...")
    SelectProfileDropdown:SetRelativeWidth(0.25)
    SelectProfileDropdown:SetCallback("OnValueChanged", function(_, _, value) UUF.db:SetProfile(value) UUF:SetUIScale() UUF:UpdateAllUnitFrames() RefreshProfiles() end)
    ProfileContainer:AddChild(SelectProfileDropdown)

    CopyFromProfileDropdown = AG:Create("Dropdown")
    CopyFromProfileDropdown:SetLabel("Copy From...")
    CopyFromProfileDropdown:SetRelativeWidth(0.25)
    CopyFromProfileDropdown:SetCallback("OnValueChanged", function(_, _, value) UUF:CreatePrompt("Copy Profile", "Are you sure you want to copy from |cFF8080FF" .. value .. "|r?\nThis will |cFFFF4040overwrite|r your current profile settings.", function() UUF.db:CopyProfile(value) UUF:SetUIScale() UUF:UpdateAllUnitFrames() RefreshProfiles() end) end)
    ProfileContainer:AddChild(CopyFromProfileDropdown)

    DeleteProfileDropdown = AG:Create("Dropdown")
    DeleteProfileDropdown:SetLabel("Delete...")
    DeleteProfileDropdown:SetRelativeWidth(0.25)
    DeleteProfileDropdown:SetCallback("OnValueChanged", function(_, _, value) if value ~= UUF.db:GetCurrentProfile() then UUF:CreatePrompt("Delete Profile", "Are you sure you want to delete |cFF8080FF" .. value .. "|r?", function() UUF.db:DeleteProfile(value) UUF:UpdateAllUnitFrames() RefreshProfiles() end) end end)
    ProfileContainer:AddChild(DeleteProfileDropdown)

    ResetProfileButton = AG:Create("Button")
    ResetProfileButton:SetText("Reset |cFF8080FF" .. UUF.db:GetCurrentProfile() .. "|r Profile")
    ResetProfileButton:SetRelativeWidth(0.25)
    ResetProfileButton:SetCallback("OnClick", function() UUF.db:ResetProfile() UUF:ResolveLSM() UUF:SetUIScale() UUF:UpdateAllUnitFrames() RefreshProfiles() end)
    ProfileContainer:AddChild(ResetProfileButton)

    local CreateProfileEditBox = AG:Create("EditBox")
    CreateProfileEditBox:SetLabel("Profile Name:")
    CreateProfileEditBox:SetText("")
    CreateProfileEditBox:SetRelativeWidth(0.5)
    CreateProfileEditBox:DisableButton(true)
    CreateProfileEditBox:SetCallback("OnEnterPressed", function() CreateProfileEditBox:ClearFocus() end)
    ProfileContainer:AddChild(CreateProfileEditBox)

    local CreateProfileButton = AG:Create("Button")
    CreateProfileButton:SetText("Create Profile")
    CreateProfileButton:SetRelativeWidth(0.5)
    CreateProfileButton:SetCallback("OnClick", function() local profileName = strtrim(CreateProfileEditBox:GetText() or "") if profileName ~= "" then UUF.db:SetProfile(profileName) UUF:SetUIScale() UUF:UpdateAllUnitFrames() RefreshProfiles() CreateProfileEditBox:SetText("") end end)
    ProfileContainer:AddChild(CreateProfileButton)

    local GlobalProfileHeading = AG:Create("Heading")
    GlobalProfileHeading:SetText("Global Profile Settings")
    GlobalProfileHeading:SetFullWidth(true)
    ProfileContainer:AddChild(GlobalProfileHeading)

    GUIWidgets.CreateInformationTag(ProfileContainer, "If |cFF8080FFUse Global Profile Settings|r is enabled, the profile selected below will be used as your active profile.\nThis is useful if you want to use the same profile across multiple characters.")

    UseGlobalProfileToggle = AG:Create("CheckBox")
    UseGlobalProfileToggle:SetLabel("Use Global Profile Settings")
    UseGlobalProfileToggle:SetValue(UUF.db.global.UseGlobalProfile)
    UseGlobalProfileToggle:SetRelativeWidth(0.5)
    UseGlobalProfileToggle:SetCallback("OnValueChanged", function(_, _, value) RefreshProfiles() UUF.db.global.UseGlobalProfile = value UUF.db.global.GlobalProfile = (UUF.db.global.GlobalProfile and UUF.db.global.GlobalProfile ~= "" and UUF.db.global.GlobalProfile) or (UUF.db.global.GlobalProfileName and UUF.db.global.GlobalProfileName ~= "" and UUF.db.global.GlobalProfileName) or "Default" if value then UUF.db:SetProfile(UUF.db.global.GlobalProfile) UUF:SetUIScale() end GlobalProfileDropdown:SetDisabled(not value) for _, child in ipairs(ProfileContainer.children) do if child ~= UseGlobalProfileToggle and child ~= GlobalProfileDropdown then GUIWidgets.DeepDisable(child, value) end end UUF:UpdateAllUnitFrames() RefreshProfiles() end)
    ProfileContainer:AddChild(UseGlobalProfileToggle)

    GlobalProfileDropdown = AG:Create("Dropdown")
    GlobalProfileDropdown:SetLabel("Global Profile...")
    GlobalProfileDropdown:SetRelativeWidth(0.5)
    GlobalProfileDropdown:SetList(profileKeys)
    GlobalProfileDropdown:SetValue((UUF.db.global.GlobalProfile and UUF.db.global.GlobalProfile ~= "" and UUF.db.global.GlobalProfile) or (UUF.db.global.GlobalProfileName and UUF.db.global.GlobalProfileName ~= "" and UUF.db.global.GlobalProfileName) or "Default")
    GlobalProfileDropdown:SetCallback("OnValueChanged", function(_, _, value) UUF.db:SetProfile(value) UUF.db.global.GlobalProfile = value UUF:SetUIScale() UUF:UpdateAllUnitFrames() RefreshProfiles() end)
    ProfileContainer:AddChild(GlobalProfileDropdown)

    local SpecProfileContainer = GUIWidgets.CreateInlineGroup(ProfileContainer, "Specialization Profiles")

    local UseDualSpecializationToggle = AG:Create("CheckBox")
    UseDualSpecializationToggle:SetLabel("Enable Specialization Profiles")
    UseDualSpecializationToggle:SetValue(UUF.db:IsDualSpecEnabled())
    UseDualSpecializationToggle:SetRelativeWidth(1)
    UseDualSpecializationToggle:SetCallback("OnValueChanged", function(_, _, value) UUF.db:SetDualSpecEnabled(value) for i = 1, numSpecs do specProfilesList[i]:SetDisabled(not value) end UUF:UpdateAllUnitFrames() RefreshProfiles() end)
    UseDualSpecializationToggle:SetDisabled(UUF.db.global.UseGlobalProfile)
    SpecProfileContainer:AddChild(UseDualSpecializationToggle)

    for i = 1, numSpecs do
        local _, specName = GetSpecializationInfo(i)
        specProfilesList[i] = AG:Create("Dropdown")
        specProfilesList[i]:SetLabel(string.format("%s", specName or ("Spec %d"):format(i)))
        specProfilesList[i]:SetList(profileKeys)
        specProfilesList[i]:SetCallback("OnValueChanged", function(widget, event, value) UUF.db:SetDualSpecProfile(value, i) end)
        specProfilesList[i]:SetRelativeWidth(numSpecs == 2 and 0.5 or numSpecs == 3 and 0.33 or 0.25)
        specProfilesList[i]:SetDisabled(not UUF.db:IsDualSpecEnabled() or UUF.db.global.UseGlobalProfile)
        SpecProfileContainer:AddChild(specProfilesList[i])
    end

    RefreshProfiles()

    local SharingContainer = GUIWidgets.CreateInlineGroup(containerParent, "Profile Sharing")

    local ExportingHeading = AG:Create("Heading")
    ExportingHeading:SetText("Exporting")
    ExportingHeading:SetFullWidth(true)
    SharingContainer:AddChild(ExportingHeading)

    GUIWidgets.CreateInformationTag(SharingContainer, "You can export your profile by pressing |cFF8080FFExport Profile|r button below & share the string with other |cFF8080FFUnhalted|r Unit Frame users.")

    local ExportingEditBox = AG:Create("EditBox")
    ExportingEditBox:SetLabel("Export String...")
    ExportingEditBox:SetText("")
    ExportingEditBox:SetRelativeWidth(0.7)
    ExportingEditBox:DisableButton(true)
    ExportingEditBox:SetCallback("OnEnterPressed", function() ExportingEditBox:ClearFocus() end)
    ExportingEditBox:SetCallback("OnTextChanged", function() ExportingEditBox:ClearFocus() end)
    SharingContainer:AddChild(ExportingEditBox)

    local ExportProfileButton = AG:Create("Button")
    ExportProfileButton:SetText("Export Profile")
    ExportProfileButton:SetRelativeWidth(0.3)
    ExportProfileButton:SetCallback("OnClick", function() ExportingEditBox:SetText(UUF:ExportSavedVariables()) ExportingEditBox:HighlightText() ExportingEditBox:SetFocus() end)
    SharingContainer:AddChild(ExportProfileButton)

    local ImportingHeading = AG:Create("Heading")
    ImportingHeading:SetText("Importing")
    ImportingHeading:SetFullWidth(true)
    SharingContainer:AddChild(ImportingHeading)

    GUIWidgets.CreateInformationTag(SharingContainer, "If you have an exported string, paste it in the |cFF8080FFImport String|r box below & press |cFF8080FFImport Profile|r.")

    local ImportingEditBox = AG:Create("EditBox")
    ImportingEditBox:SetLabel("Import String...")
    ImportingEditBox:SetText("")
    ImportingEditBox:SetRelativeWidth(0.7)
    ImportingEditBox:DisableButton(true)
    ImportingEditBox:SetCallback("OnEnterPressed", function() ImportingEditBox:ClearFocus() end)
    ImportingEditBox:SetCallback("OnTextChanged", function() ImportingEditBox:ClearFocus() end)
    SharingContainer:AddChild(ImportingEditBox)

    local ImportProfileButton = AG:Create("Button")
    ImportProfileButton:SetText("Import Profile")
    ImportProfileButton:SetRelativeWidth(0.3)
    ImportProfileButton:SetCallback("OnClick", function() if ImportingEditBox:GetText() ~= "" then UUF:ImportSavedVariables(ImportingEditBox:GetText()) ImportingEditBox:SetText("") end end)
    SharingContainer:AddChild(ImportProfileButton)
    GlobalProfileDropdown:SetDisabled(not UUF.db.global.UseGlobalProfile)
    if UUF.db.global.UseGlobalProfile then for _, child in ipairs(ProfileContainer.children) do if child ~= UseGlobalProfileToggle and child ~= GlobalProfileDropdown then GUIWidgets.DeepDisable(child, true) end end end
end

function UUF:CreateGUI()
    if isGUIOpen then return end
    if InCombatLockdown() then return end

    isGUIOpen = true

    Container = AG:Create("Frame")
    Container:SetTitle(UUF.PRETTY_ADDON_NAME)
    Container:SetLayout("Fill")
    Container:SetWidth(1100)
    Container:SetHeight(600)
    Container:EnableResize(false)
    Container:SetCallback("OnClose", function(widget) AG:Release(widget) isGUIOpen = false DisableAllTestModes() end)

    local function SelectTab(GUIContainer, _, MainTab)
        GUIContainer:ReleaseChildren()

        local Wrapper = AG:Create("SimpleGroup")
        Wrapper:SetFullWidth(true)
        Wrapper:SetFullHeight(true)
        Wrapper:SetLayout("Fill")
        GUIContainer:AddChild(Wrapper)

        if MainTab == "General" then
            local ScrollFrame = GUIWidgets.CreateScrollFrame(Wrapper)

            CreateUIScaleSettings(ScrollFrame)
            CreateColourSettings(ScrollFrame)

            local SupportMeContainer = AG:Create("InlineGroup")
            SupportMeContainer:SetTitle("|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Emotes\\peepoLove.png:18:18|t  How To Support " .. UUF.PRETTY_ADDON_NAME .. " Development")
            SupportMeContainer:SetLayout("Flow")
            SupportMeContainer:SetFullWidth(true)
            ScrollFrame:AddChild(SupportMeContainer)

            -- local KoFiInteractive = AG:Create("InteractiveLabel")
            -- KoFiInteractive:SetText("|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Support\\Ko-Fi.png:16:21|t |cFF8080FFKo-Fi|r")
            -- KoFiInteractive:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
            -- KoFiInteractive:SetJustifyV("MIDDLE")
            -- KoFiInteractive:SetRelativeWidth(0.33)
            -- KoFiInteractive:SetCallback("OnClick", function() UUF:OpenURL("Support Me on Ko-Fi", "https://ko-fi.com/unhalted") end)
            -- KoFiInteractive:SetCallback("OnEnter", function() KoFiInteractive:SetText("|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Support\\Ko-Fi.png:16:21|t |cFFFFFFFFKo-Fi|r") end)
            -- KoFiInteractive:SetCallback("OnLeave", function() KoFiInteractive:SetText("|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Support\\Ko-Fi.png:16:21|t |cFF8080FFKo-Fi|r") end)
            -- SupportMeContainer:AddChild(KoFiInteractive)

            -- local PayPalInteractive = AG:Create("InteractiveLabel")
            -- PayPalInteractive:SetText("|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Support\\PayPal.png:23:21|t |cFF8080FFPayPal|r")
            -- PayPalInteractive:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
            -- PayPalInteractive:SetJustifyV("MIDDLE")
            -- PayPalInteractive:SetRelativeWidth(0.33)
            -- PayPalInteractive:SetCallback("OnClick", function() UUF:OpenURL("Support Me on PayPal", "https://www.paypal.com/paypalme/dhunt1911") end)
            -- PayPalInteractive:SetCallback("OnEnter", function() PayPalInteractive:SetText("|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Support\\PayPal.png:23:21|t |cFFFFFFFFPayPal|r") end)
            -- PayPalInteractive:SetCallback("OnLeave", function() PayPalInteractive:SetText("|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Support\\PayPal.png:23:21|t |cFF8080FFPayPal|r") end)
            -- SupportMeContainer:AddChild(PayPalInteractive)

            local TwitchInteractive = AG:Create("InteractiveLabel")
            TwitchInteractive:SetText("|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Support\\Twitch.png:25:21|t |cFF8080FFTwitch|r")
            TwitchInteractive:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
            TwitchInteractive:SetJustifyV("MIDDLE")
            TwitchInteractive:SetRelativeWidth(0.33)
            TwitchInteractive:SetCallback("OnClick", function() UUF:OpenURL("Support Me on Twitch", "https://www.twitch.tv/unhaltedgb") end)
            TwitchInteractive:SetCallback("OnEnter", function() TwitchInteractive:SetText("|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Support\\Twitch.png:25:21|t |cFFFFFFFFTwitch|r") end)
            TwitchInteractive:SetCallback("OnLeave", function() TwitchInteractive:SetText("|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Support\\Twitch.png:25:21|t |cFF8080FFTwitch|r") end)
            SupportMeContainer:AddChild(TwitchInteractive)

            local DiscordInteractive = AG:Create("InteractiveLabel")
            DiscordInteractive:SetText("|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Support\\Discord.png:21:21|t |cFF8080FFDiscord|r")
            DiscordInteractive:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
            DiscordInteractive:SetJustifyV("MIDDLE")
            DiscordInteractive:SetRelativeWidth(0.33)
            DiscordInteractive:SetCallback("OnClick", function() UUF:OpenURL("Support Me on Discord", "https://discord.gg/UZCgWRYvVE") end)
            DiscordInteractive:SetCallback("OnEnter", function() DiscordInteractive:SetText("|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Support\\Discord.png:21:21|t |cFFFFFFFFDiscord|r") end)
            DiscordInteractive:SetCallback("OnLeave", function() DiscordInteractive:SetText("|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Support\\Discord.png:21:21|t |cFF8080FFDiscord|r") end)
            SupportMeContainer:AddChild(DiscordInteractive)

            -- local PatreonInteractive = AG:Create("InteractiveLabel")
            -- PatreonInteractive:SetText("|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Support\\Patreon.png:21:21|t |cFF8080FFPatreon|r")
            -- PatreonInteractive:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
            -- PatreonInteractive:SetJustifyV("MIDDLE")
            -- PatreonInteractive:SetRelativeWidth(0.33)
            -- PatreonInteractive:SetCallback("OnClick", function() UUF:OpenURL("Support Me on Patreon", "https://www.patreon.com/unhalted") end)
            -- PatreonInteractive:SetCallback("OnEnter", function() PatreonInteractive:SetText("|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Support\\Patreon.png:21:21|t |cFFFFFFFFPatreon|r") end)
            -- PatreonInteractive:SetCallback("OnLeave", function() PatreonInteractive:SetText("|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Support\\Patreon.png:21:21|t |cFF8080FFPatreon|r") end)
            -- SupportMeContainer:AddChild(PatreonInteractive)

            local GithubInteractive = AG:Create("InteractiveLabel")
            GithubInteractive:SetText("|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Support\\Github.png:21:21|t |cFF8080FFGithub|r")
            GithubInteractive:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
            GithubInteractive:SetJustifyV("MIDDLE")
            GithubInteractive:SetRelativeWidth(0.33)
            GithubInteractive:SetCallback("OnClick", function() UUF:OpenURL("Support Me on Github", "https://github.com/dalehuntgb/UnhaltedUnitFrames") end)
            GithubInteractive:SetCallback("OnEnter", function() GithubInteractive:SetText("|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Support\\Github.png:21:21|t |cFFFFFFFFGithub|r") end)
            GithubInteractive:SetCallback("OnLeave", function() GithubInteractive:SetText("|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Support\\Github.png:21:21|t |cFF8080FFGithub|r") end)
            SupportMeContainer:AddChild(GithubInteractive)

            ScrollFrame:DoLayout()
        elseif MainTab == "Global" then
            local ScrollFrame = GUIWidgets.CreateScrollFrame(Wrapper)

            CreateGlobalSettings(ScrollFrame)

            ScrollFrame:DoLayout()
        elseif MainTab == "CooldownText" then
            local ScrollFrame = GUIWidgets.CreateScrollFrame(Wrapper)

            CreateCooldownTextSettings(ScrollFrame)

            ScrollFrame:DoLayout()
        elseif MainTab == "Player" then
            local ScrollFrame = GUIWidgets.CreateScrollFrame(Wrapper)

            CreateUnitSettings(ScrollFrame, "player")

            ScrollFrame:DoLayout()
        elseif MainTab == "Target" then
            local ScrollFrame = GUIWidgets.CreateScrollFrame(Wrapper)

            CreateUnitSettings(ScrollFrame, "target")

            ScrollFrame:DoLayout()
        elseif MainTab == "TargetTarget" then
            local ScrollFrame = GUIWidgets.CreateScrollFrame(Wrapper)

            CreateUnitSettings(ScrollFrame, "targettarget")

            ScrollFrame:DoLayout()
        elseif MainTab == "Pet" then
            local ScrollFrame = GUIWidgets.CreateScrollFrame(Wrapper)

            CreateUnitSettings(ScrollFrame, "pet")

            ScrollFrame:DoLayout()
        elseif MainTab == "Focus" then
            local ScrollFrame = GUIWidgets.CreateScrollFrame(Wrapper)

            CreateUnitSettings(ScrollFrame, "focus")

            ScrollFrame:DoLayout()
        elseif MainTab == "FocusTarget" then
            local ScrollFrame = GUIWidgets.CreateScrollFrame(Wrapper)

            CreateUnitSettings(ScrollFrame, "focustarget")

            ScrollFrame:DoLayout()
        elseif MainTab == "Boss" then
            local ScrollFrame = GUIWidgets.CreateScrollFrame(Wrapper)

            CreateUnitSettings(ScrollFrame, "boss")

            ScrollFrame:DoLayout()
        elseif MainTab == "Party" then
            local ScrollFrame = GUIWidgets.CreateScrollFrame(Wrapper)

            CreateUnitSettings(ScrollFrame, "party")

            ScrollFrame:DoLayout()
		elseif MainTab == "Raid" then
			local ScrollFrame = GUIWidgets.CreateScrollFrame(Wrapper)

			CreateUnitSettings(ScrollFrame, "raid")

			ScrollFrame:DoLayout()
        elseif MainTab == "Tags" then
            local ScrollFrame = GUIWidgets.CreateScrollFrame(Wrapper)
            CreateTagSettings(ScrollFrame)
            ScrollFrame:DoLayout()
        elseif MainTab == "Profiles" then
            local ScrollFrame = GUIWidgets.CreateScrollFrame(Wrapper)

            CreateProfileSettings(ScrollFrame)

            ScrollFrame:DoLayout()
        end
		if MainTab == "Boss" then EnableBossFramesTestMode() else DisableBossFramesTestMode() end
        GenerateSupportText(Container)
    end

    local mainNavigationTree = BuildMainNavigationTree()
    local mainNavigationValues = {}
    for _, entry in ipairs(mainNavigationTree) do
        mainNavigationValues[entry.value] = true
    end

    UUFGUI.MainNavigationStatus = UUFGUI.MainNavigationStatus or {}

    local ContainerTreeGroup = AG:Create("TreeGroup")
    ContainerTreeGroup:SetLayout("Fill")
    ContainerTreeGroup:SetFullWidth(true)
    ContainerTreeGroup:SetFullHeight(true)
    ContainerTreeGroup:SetStatusTable(UUFGUI.MainNavigationStatus)
    ContainerTreeGroup:SetTreeWidth(220, false)
    ContainerTreeGroup:SetTree(mainNavigationTree)
    ContainerTreeGroup:SetCallback("OnGroupSelected", SelectTab)
    Container:AddChild(ContainerTreeGroup)
    UUFGUI.MainNavigation = ContainerTreeGroup

    local initialSection = UUFGUI.MainNavigationStatus.selected
    if not initialSection or not mainNavigationValues[initialSection] then
        initialSection = "General"
    end
    ContainerTreeGroup:SelectByValue(initialSection)
end

function UUF:OpenGUIToUnit(unit)
    if InCombatLockdown() then return end
    if not lastSelectedUnitTabs[unit] then lastSelectedUnitTabs[unit] = {} end
    lastSelectedUnitTabs[unit].mainTab = "Frame"
    UUF:CreateGUI()
    if UUFGUI.MainNavigation then UUFGUI.MainNavigation:SelectByValue(unit == "targettarget" and "TargetTarget" or unit == "focustarget" and "FocusTarget" or unit:gsub("^%l", string.upper)) end
end

function UUFG:OpenUUFGUI()
    UUF:CreateGUI()
end

function UUFG:CloseUUFGUI()
    if isGUIOpen and Container then
        Container:Hide()
        DisableAllTestModes()
    end
end
