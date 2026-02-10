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
}

local AnchorPoints = { { ["TOPLEFT"] = "Top Left", ["TOP"] = "Top", ["TOPRIGHT"] = "Top Right", ["LEFT"] = "Left", ["CENTER"] = "Center", ["RIGHT"] = "Right", ["BOTTOMLEFT"] = "Bottom Left", ["BOTTOM"] = "Bottom", ["BOTTOMRIGHT"] = "Bottom Right" }, { "TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "CENTER", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT", } }
local FrameStrataList = {{ ["BACKGROUND"] = "Background", ["LOW"] = "Low", ["MEDIUM"] = "Medium", ["HIGH"] = "High", ["DIALOG"] = "Dialog", ["FULLSCREEN"] = "Fullscreen", ["FULLSCREEN_DIALOG"] = "Fullscreen Dialog", ["TOOLTIP"] = "Tooltip" }, { "BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "FULLSCREEN", "FULLSCREEN_DIALOG", "TOOLTIP" }}

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
    for unit, _ in pairs(UUF.db.profile.Units) do
        if UUF[unit:upper()] then
            UUF:CreateTestAuras(UUF[unit:upper()], unit)
            UUF:CreateTestCastBar(UUF[unit:upper()], unit)
        end
    end
    UUF:CreateTestBossFrames()
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

    GUIWidgets.CreateInformationTag(Container,"Fonts are applied to all Unit Frames & Elements where appropriate. More fonts can be added via |cFFFFCC00SharedMedia|r.")

    local FontDropdown = AG:Create("LSM30_Font")
    FontDropdown:SetList(LSM:HashTable("font"))
    FontDropdown:SetLabel("Font")
    FontDropdown:SetValue(UUF.db.profile.General.Fonts.Font)
    FontDropdown:SetRelativeWidth(0.5)
    FontDropdown:SetCallback("OnValueChanged", function(widget, _, value) widget:SetValue(value) UUF.db.profile.General.Fonts.Font = value UUF:ResolveLSM() UUF:UpdateAllUnitFrames() end)
    Container:AddChild(FontDropdown)

    local FontFlagDropdown = AG:Create("Dropdown")
    FontFlagDropdown:SetList({["NONE"] = "None", ["OUTLINE"] = "Outline", ["THICKOUTLINE"] = "Thick Outline", ["MONOCHROME"] = "Monochrome", ["MONOCHROMEOUTLINE"] = "Monochrome Outline", ["MONOCHROMETHICKOUTLINE"] = "Monochrome Thick Outline"})
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

    local ColourPicker = AG:Create("ColorPicker")
    ColourPicker:SetLabel("Colour")
    ColourPicker:SetColor(unpack(UUF.db.profile.General.Fonts.Shadow.Colour))
    ColourPicker:SetFullWidth(true)
    ColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) UUF.db.profile.General.Fonts.Shadow.Colour = {r, g, b, a} UUF:ResolveLSM() UUF:UpdateAllUnitFrames() end)
    ColourPicker:SetRelativeWidth(0.5)
    SimpleGroup:AddChild(ColourPicker)

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

    GUIWidgets.CreateInformationTag(Container,"Textures are applied to all Unit Frames & Elements where appropriate. More textures can be added via |cFFFFCC00SharedMedia|r.")

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

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Layout & Positioning")

    local WidthSlider = AG:Create("Slider")
    WidthSlider:SetLabel("Width")
    WidthSlider:SetValue(FrameDB.Width)
    WidthSlider:SetSliderValues(1, 1000, 0.1)
    WidthSlider:SetRelativeWidth(0.5)
    WidthSlider:SetCallback("OnValueChanged", function(_, _, value) FrameDB.Width = value updateCallback() end)
    LayoutContainer:AddChild(WidthSlider)

    local HeightSlider = AG:Create("Slider")
    HeightSlider:SetLabel("Height")
    HeightSlider:SetValue(FrameDB.Height)
    HeightSlider:SetSliderValues(1, 1000, 0.1)
    HeightSlider:SetRelativeWidth(0.5)
    HeightSlider:SetCallback("OnValueChanged", function(_, _, value) FrameDB.Height = value updateCallback() end)
    LayoutContainer:AddChild(HeightSlider)

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(FrameDB.Layout[1])
    AnchorFromDropdown:SetRelativeWidth((unitHasParent or unit == "boss") and 0.33 or 0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) FrameDB.Layout[1] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorFromDropdown)

    if unitHasParent then
        local AnchorParentEditBox = AG:Create("EditBox")
        AnchorParentEditBox:SetLabel("Anchor Parent")
        AnchorParentEditBox:SetText(FrameDB.AnchorParent or "")
        AnchorParentEditBox:SetRelativeWidth(0.33)
        AnchorParentEditBox:DisableButton(true)
        AnchorParentEditBox:SetCallback("OnEnterPressed", function(_, _, value) FrameDB.AnchorParent = value ~= "" and value or nil AnchorParentEditBox:SetText(FrameDB.AnchorParent or "") updateCallback() end)
        LayoutContainer:AddChild(AnchorParentEditBox)
    end

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(FrameDB.Layout[2])
    AnchorToDropdown:SetRelativeWidth((unitHasParent or unit == "boss") and 0.33 or 0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) FrameDB.Layout[2] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorToDropdown)

    if unit == "boss" then
        local GrowthDirectionDropdown = AG:Create("Dropdown")
        GrowthDirectionDropdown:SetList({["UP"] = "Up", ["DOWN"] = "Down"})
        GrowthDirectionDropdown:SetLabel("Growth Direction")
        GrowthDirectionDropdown:SetValue(FrameDB.GrowthDirection)
        GrowthDirectionDropdown:SetRelativeWidth(0.33)
        GrowthDirectionDropdown:SetCallback("OnValueChanged", function(_, _, value) FrameDB.GrowthDirection = value updateCallback() end)
        LayoutContainer:AddChild(GrowthDirectionDropdown)
    end

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(FrameDB.Layout[3])
    XPosSlider:SetSliderValues(-1000, 1000, 0.1)
    XPosSlider:SetRelativeWidth(unit == "boss" and 0.25 or 0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) FrameDB.Layout[3] = value updateCallback() end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(FrameDB.Layout[4])
    YPosSlider:SetSliderValues(-1000, 1000, 0.1)
    YPosSlider:SetRelativeWidth(unit == "boss" and 0.25 or 0.33)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) FrameDB.Layout[4] = value updateCallback() end)
    LayoutContainer:AddChild(YPosSlider)

    if unit == "boss" then
        local SpacingSlider = AG:Create("Slider")
        SpacingSlider:SetLabel("Frame Spacing")
        SpacingSlider:SetValue(FrameDB.Layout[5])
        SpacingSlider:SetSliderValues(-1, 100, 0.1)
        SpacingSlider:SetRelativeWidth(0.33)
        SpacingSlider:SetCallback("OnValueChanged", function(_, _, value) FrameDB.Layout[5] = value updateCallback() end)
        LayoutContainer:AddChild(SpacingSlider)
    end

    local FrameStrataDropdown = AG:Create("Dropdown")
    FrameStrataDropdown:SetList(FrameStrataList[1], FrameStrataList[2])
    FrameStrataDropdown:SetLabel("Frame Strata")
    FrameStrataDropdown:SetValue(FrameDB.FrameStrata)
    FrameStrataDropdown:SetRelativeWidth(unit == "boss" and 0.25 or 0.33)
    FrameStrataDropdown:SetCallback("OnValueChanged", function(_, _, value) FrameDB.FrameStrata = value updateCallback() end)
    LayoutContainer:AddChild(FrameStrataDropdown)

    local ColourContainer = GUIWidgets.CreateInlineGroup(containerParent, "Colours & Toggles")

    local ColourWhenTappedToggle = AG:Create("CheckBox")
    ColourWhenTappedToggle:SetLabel("Colour When Tapped")
    ColourWhenTappedToggle:SetValue(HealthBarDB.ColourWhenTapped)
    ColourWhenTappedToggle:SetCallback("OnValueChanged", function(_, _, value) HealthBarDB.ColourWhenTapped = value updateCallback() end)
    ColourWhenTappedToggle:SetRelativeWidth((unit == "player" or unit == "target") and 0.33 or 0.5)
    ColourContainer:AddChild(ColourWhenTappedToggle)

    local InverseGrowthDirectionToggle = AG:Create("CheckBox")
    InverseGrowthDirectionToggle:SetLabel("Inverse Growth Direction")
    InverseGrowthDirectionToggle:SetValue(HealthBarDB.Inverse)
    InverseGrowthDirectionToggle:SetCallback("OnValueChanged", function(_, _, value) HealthBarDB.Inverse = value updateCallback() end)
    InverseGrowthDirectionToggle:SetRelativeWidth((unit == "player" or unit == "target") and 0.33 or 0.5)
    ColourContainer:AddChild(InverseGrowthDirectionToggle)

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
        AnchorToCooldownViewerToggle:SetRelativeWidth(0.25)
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

    if unit == "player" or unit == "target" or unit == "focus" then
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

    local BorderColourPicker = AG:Create("ColorPicker")
    BorderColourPicker:SetLabel("Border Colour")
    local R3, G3, B3, A3 = unpack(HealthBarDB.BorderColour)
    BorderColourPicker:SetColor(R3, G3, B3, A3)
    BorderColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) HealthBarDB.BorderColour = {r, g, b, a} updateCallback() end)
    BorderColourPicker:SetHasAlpha(true)
    BorderColourPicker:SetRelativeWidth(0.25)
    BorderColourPicker:SetDisabled(not HealthBarDB.ShowBorder)
    ColourContainer:AddChild(BorderColourPicker)
    UUFGUI.FrameBorderColourPicker = BorderColourPicker

    local ShowBorderToggle = AG:Create("CheckBox")
    ShowBorderToggle:SetLabel("Show Border")
    ShowBorderToggle:SetValue(HealthBarDB.ShowBorder)
    ShowBorderToggle:SetCallback("OnValueChanged", function(_, _, value) HealthBarDB.ShowBorder = value UUFGUI.FrameBorderColourPicker:SetDisabled(not HealthBarDB.ShowBorder) updateCallback() end)
    ShowBorderToggle:SetRelativeWidth(0.25)
    ColourContainer:AddChild(ShowBorderToggle)
end

local function CreateHealPredictionSettings(containerParent, unit, updateCallback)
    local FrameDB = UUF.db.profile.Units[unit].Frame
    local HealPredictionDB = UUF.db.profile.Units[unit].HealPrediction

    local AbsorbSettings = GUIWidgets.CreateInlineGroup(containerParent, "Absorb Settings")

    local ShowAbsorbToggle = AG:Create("CheckBox")
    ShowAbsorbToggle:SetLabel("Show Absorbs")
    ShowAbsorbToggle:SetValue(HealPredictionDB.Absorbs.Enabled)
    ShowAbsorbToggle:SetCallback("OnValueChanged", function(_, _, value) HealPredictionDB.Absorbs.Enabled = value updateCallback() RefreshHealPredictionSettings() end)
    ShowAbsorbToggle:SetRelativeWidth(0.5)
    AbsorbSettings:AddChild(ShowAbsorbToggle)

    local UseStripedTextureAbsorbToggle = AG:Create("CheckBox")
    UseStripedTextureAbsorbToggle:SetLabel("Use Striped Texture")
    UseStripedTextureAbsorbToggle:SetValue(HealPredictionDB.Absorbs.UseStripedTexture)
    UseStripedTextureAbsorbToggle:SetCallback("OnValueChanged", function(_, _, value) HealPredictionDB.Absorbs.UseStripedTexture = value updateCallback() end)
    UseStripedTextureAbsorbToggle:SetRelativeWidth(0.5)
    AbsorbSettings:AddChild(UseStripedTextureAbsorbToggle)

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
    AbsorbSettings:AddChild(AbsorbHeightSlider)

    local AbsorbPositionDropdown = AG:Create("Dropdown")
    AbsorbPositionDropdown:SetList({["LEFT"] = "Left", ["RIGHT"] = "Right", ["ATTACH"] = "Attach To Missing Health"}, {"LEFT", "RIGHT", "ATTACH"})
    AbsorbPositionDropdown:SetLabel("Position")
    AbsorbPositionDropdown:SetValue(HealPredictionDB.Absorbs.Position)
    AbsorbPositionDropdown:SetRelativeWidth(0.33)
    AbsorbPositionDropdown:SetCallback("OnValueChanged", function(_, _, value) HealPredictionDB.Absorbs.Position = value updateCallback() end)
    AbsorbSettings:AddChild(AbsorbPositionDropdown)

    local HealAbsorbSettings = GUIWidgets.CreateInlineGroup(containerParent, "Heal Absorb Settings")
    local ShowHealAbsorbToggle = AG:Create("CheckBox")
    ShowHealAbsorbToggle:SetLabel("Show Heal Absorbs")
    ShowHealAbsorbToggle:SetValue(HealPredictionDB.HealAbsorbs.Enabled)
    ShowHealAbsorbToggle:SetCallback("OnValueChanged", function(_, _, value) HealPredictionDB.HealAbsorbs.Enabled = value updateCallback() RefreshHealPredictionSettings() end)
    ShowHealAbsorbToggle:SetRelativeWidth(0.5)
    HealAbsorbSettings:AddChild(ShowHealAbsorbToggle)

    local UseStripedTextureHealAbsorbToggle = AG:Create("CheckBox")
    UseStripedTextureHealAbsorbToggle:SetLabel("Use Striped Texture")
    UseStripedTextureHealAbsorbToggle:SetValue(HealPredictionDB.HealAbsorbs.UseStripedTexture)
    UseStripedTextureHealAbsorbToggle:SetCallback("OnValueChanged", function(_, _, value) HealPredictionDB.HealAbsorbs.UseStripedTexture = value updateCallback() end)
    UseStripedTextureHealAbsorbToggle:SetRelativeWidth(0.5)
    HealAbsorbSettings:AddChild(UseStripedTextureHealAbsorbToggle)

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
    HealAbsorbSettings:AddChild(HealAbsorbHeightSlider)

    local HealAbsorbPositionDropdown = AG:Create("Dropdown")
    HealAbsorbPositionDropdown:SetList({["LEFT"] = "Left", ["RIGHT"] = "Right", ["ATTACH"] = "Attach To Missing Health"}, {"LEFT", "RIGHT", "ATTACH"})
    HealAbsorbPositionDropdown:SetLabel("Position")
    HealAbsorbPositionDropdown:SetValue(HealPredictionDB.HealAbsorbs.Position)
    HealAbsorbPositionDropdown:SetRelativeWidth(0.33)
    HealAbsorbPositionDropdown:SetCallback("OnValueChanged", function(_, _, value) HealPredictionDB.HealAbsorbs.Position = value updateCallback() end)
    HealAbsorbSettings:AddChild(HealAbsorbPositionDropdown)

    function RefreshHealPredictionSettings()
        GUIWidgets.DeepDisable(AbsorbSettings, not HealPredictionDB.Absorbs.Enabled, ShowAbsorbToggle)
        GUIWidgets.DeepDisable(HealAbsorbSettings, not HealPredictionDB.HealAbsorbs.Enabled, ShowHealAbsorbToggle)
    end

    RefreshHealPredictionSettings()
end

local function CreateCastBarBarSettings(containerParent, unit, updateCallback)
    local FrameDB = UUF.db.profile.Units[unit].Frame
    local CastBarDB = UUF.db.profile.Units[unit].CastBar

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
    WidthSlider:SetSliderValues(1, 1000, 0.1)
    WidthSlider:SetRelativeWidth(0.5)
    WidthSlider:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.Width = value updateCallback() end)
    LayoutContainer:AddChild(WidthSlider)

    local HeightSlider = AG:Create("Slider")
    HeightSlider:SetLabel("Height")
    HeightSlider:SetValue(CastBarDB.Height)
    HeightSlider:SetSliderValues(1, 1000, 0.1)
    HeightSlider:SetRelativeWidth(0.5)
    HeightSlider:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.Height = value updateCallback() end)
    LayoutContainer:AddChild(HeightSlider)

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
    XPosSlider:SetSliderValues(-1000, 1000, 0.1)
    XPosSlider:SetRelativeWidth(0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.Layout[3] = value updateCallback() end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(CastBarDB.Layout[4])
    YPosSlider:SetSliderValues(-1000, 1000, 0.1)
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

    local ForegroundColourPicker = AG:Create("ColorPicker")
    ForegroundColourPicker:SetLabel("Foreground")
    local R, G, B, A = unpack(CastBarDB.Foreground)
    ForegroundColourPicker:SetColor(R, G, B, A)
    ForegroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) CastBarDB.Foreground = {r, g, b, a} updateCallback() end)
    ForegroundColourPicker:SetHasAlpha(true)
    ForegroundColourPicker:SetRelativeWidth(0.33)
    ColourContainer:AddChild(ForegroundColourPicker)

    local BackgroundColourPicker = AG:Create("ColorPicker")
    BackgroundColourPicker:SetLabel("Background")
    local R2, G2, B2, A2 = unpack(CastBarDB.Background)
    BackgroundColourPicker:SetColor(R2, G2, B2, A2)
    BackgroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) CastBarDB.Background = {r, g, b, a} updateCallback() end)
    BackgroundColourPicker:SetHasAlpha(true)
    BackgroundColourPicker:SetRelativeWidth(0.33)
    ColourContainer:AddChild(BackgroundColourPicker)

    local NotInterruptibleColourPicker = AG:Create("ColorPicker")
    NotInterruptibleColourPicker:SetLabel("Not Interruptible")
    local R3, G3, B3 = unpack(CastBarDB.NotInterruptibleColour)
    NotInterruptibleColourPicker:SetColor(R3, G3, B3)
    NotInterruptibleColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b) CastBarDB.NotInterruptibleColour = {r, g, b} updateCallback() end)
    NotInterruptibleColourPicker:SetHasAlpha(false)
    NotInterruptibleColourPicker:SetRelativeWidth(0.33)
    ColourContainer:AddChild(NotInterruptibleColourPicker)

    local BorderColourPicker = AG:Create("ColorPicker")
    BorderColourPicker:SetLabel("Border Colour")
    local R4, G4, B4, A4 = unpack(CastBarDB.BorderColour)
    BorderColourPicker:SetColor(R4, G4, B4, A4)
    BorderColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) CastBarDB.BorderColour = {r, g, b, a} updateCallback() end)
    BorderColourPicker:SetHasAlpha(true)
    BorderColourPicker:SetRelativeWidth(0.33)
    BorderColourPicker:SetDisabled(not CastBarDB.ShowBorder)
    ColourContainer:AddChild(BorderColourPicker)
    UUFGUI.FrameBorderColourPicker = BorderColourPicker

    local ShowBorderToggle = AG:Create("CheckBox")
    ShowBorderToggle:SetLabel("Show Border")
    ShowBorderToggle:SetValue(CastBarDB.ShowBorder)
    ShowBorderToggle:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.ShowBorder = value UUFGUI.FrameBorderColourPicker:SetDisabled(not CastBarDB.ShowBorder) updateCallback() end)
    ShowBorderToggle:SetRelativeWidth(0.33)
    ColourContainer:AddChild(ShowBorderToggle)

    function RefreshCastBarBarSettings()
        if CastBarDB.Enabled then
            MatchParentWidthToggle:SetDisabled(false)
            WidthSlider:SetDisabled(CastBarDB.MatchParentWidth)
            HeightSlider:SetDisabled(false)
            AnchorFromDropdown:SetDisabled(false)
            AnchorToDropdown:SetDisabled(false)
            XPosSlider:SetDisabled(false)
            YPosSlider:SetDisabled(false)
            ForegroundColourPicker:SetDisabled(CastBarDB.ColourByClass)
            BackgroundColourPicker:SetDisabled(false)
            NotInterruptibleColourPicker:SetDisabled(false)
        else
            MatchParentWidthToggle:SetDisabled(true)
            WidthSlider:SetDisabled(true)
            HeightSlider:SetDisabled(true)
            AnchorFromDropdown:SetDisabled(true)
            AnchorToDropdown:SetDisabled(true)
            XPosSlider:SetDisabled(true)
            YPosSlider:SetDisabled(true)
            ForegroundColourPicker:SetDisabled(true)
            BackgroundColourPicker:SetDisabled(true)
            NotInterruptibleColourPicker:SetDisabled(true)
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
    local CastBarTextDB = UUF.db.profile.Units[unit].CastBar.Text
    local SpellNameTextDB = CastBarTextDB.SpellName

    local SpellNameContainer = GUIWidgets.CreateInlineGroup(containerParent, "Spell Name Settings")

    local SpellNameToggle = AG:Create("CheckBox")
    SpellNameToggle:SetLabel("Enable |cFF8080FFSpell Name Text|r")
    SpellNameToggle:SetValue(SpellNameTextDB.Enabled)
    SpellNameToggle:SetCallback("OnValueChanged", function(_, _, value) SpellNameTextDB.Enabled = value updateCallback() RefreshCastBarSpellNameSettings() end)
    SpellNameToggle:SetRelativeWidth(0.5)
    SpellNameContainer:AddChild(SpellNameToggle)

    local SpellNameColourPicker = AG:Create("ColorPicker")
    SpellNameColourPicker:SetLabel("Colour")
    local R, G, B = unpack(SpellNameTextDB.Colour)
    SpellNameColourPicker:SetColor(R, G, B)
    SpellNameColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b) SpellNameTextDB.Colour = {r, g, b} updateCallback() end)
    SpellNameColourPicker:SetHasAlpha(false)
    SpellNameColourPicker:SetRelativeWidth(0.5)
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
    SpellNameXPosSlider:SetSliderValues(-1000, 1000, 0.1)
    SpellNameXPosSlider:SetRelativeWidth(0.25)
    SpellNameXPosSlider:SetCallback("OnValueChanged", function(_, _, value) SpellNameTextDB.Layout[3] = value updateCallback() end)
    SpellNameLayoutContainer:AddChild(SpellNameXPosSlider)

    local SpellNameYPosSlider = AG:Create("Slider")
    SpellNameYPosSlider:SetLabel("Y Position")
    SpellNameYPosSlider:SetValue(SpellNameTextDB.Layout[4])
    SpellNameYPosSlider:SetSliderValues(-1000, 1000, 0.1)
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
            MaxCharsSlider:SetDisabled(false)
        else
            SpellNameAnchorFromDropdown:SetDisabled(true)
            SpellNameAnchorToDropdown:SetDisabled(true)
            SpellNameXPosSlider:SetDisabled(true)
            SpellNameYPosSlider:SetDisabled(true)
            SpellNameFontSizeSlider:SetDisabled(true)
            SpellNameColourPicker:SetDisabled(true)
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
    DurationXPosSlider:SetSliderValues(-1000, 1000, 0.1)
    DurationXPosSlider:SetRelativeWidth(0.33)
    DurationXPosSlider:SetCallback("OnValueChanged", function(_, _, value) DurationTextDB.Layout[3] = value updateCallback() end)
    DurationLayoutContainer:AddChild(DurationXPosSlider)

    local DurationYPosSlider = AG:Create("Slider")
    DurationYPosSlider:SetLabel("Y Position")
    DurationYPosSlider:SetValue(DurationTextDB.Layout[4])
    DurationYPosSlider:SetSliderValues(-1000, 1000, 0.1)
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

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Power Bar Settings")

    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel("Enable |cFF8080FFPower Bar|r")
    Toggle:SetValue(PowerBarDB.Enabled)
    Toggle:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.Enabled = value updateCallback() RefreshPowerBarGUI() end)
    Toggle:SetRelativeWidth(0.33)
    LayoutContainer:AddChild(Toggle)

    local InverseGrowthDirectionToggle = AG:Create("CheckBox")
    InverseGrowthDirectionToggle:SetLabel("Inverse Growth Direction")
    InverseGrowthDirectionToggle:SetValue(PowerBarDB.Inverse)
    InverseGrowthDirectionToggle:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.Inverse = value updateCallback() end)
    InverseGrowthDirectionToggle:SetRelativeWidth(0.33)
    LayoutContainer:AddChild(InverseGrowthDirectionToggle)

    local HeightSlider = AG:Create("Slider")
    HeightSlider:SetLabel("Height")
    HeightSlider:SetValue(PowerBarDB.Height)
    HeightSlider:SetSliderValues(1, FrameDB.Height - 2, 0.1)
    HeightSlider:SetRelativeWidth(0.33)
    HeightSlider:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.Height = value updateCallback() end)
    LayoutContainer:AddChild(HeightSlider)

    local ColourContainer = GUIWidgets.CreateInlineGroup(containerParent, "Colours & Toggles")

    local SmoothUpdatesToggle = AG:Create("CheckBox")
    SmoothUpdatesToggle:SetLabel("Smooth Updates")
    SmoothUpdatesToggle:SetValue(PowerBarDB.Smooth)
    SmoothUpdatesToggle:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.Smooth = value updateCallback() end)
    SmoothUpdatesToggle:SetRelativeWidth(0.33)
    ColourContainer:AddChild(SmoothUpdatesToggle)

    local ColourByTypeToggle = AG:Create("CheckBox")
    ColourByTypeToggle:SetLabel("Colour By Type")
    ColourByTypeToggle:SetValue(PowerBarDB.ColourByType)
    ColourByTypeToggle:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.ColourByType = value updateCallback() RefreshPowerBarGUI() end)
    ColourByTypeToggle:SetRelativeWidth(0.33)
    ColourContainer:AddChild(ColourByTypeToggle)

    local ColourByClassToggle = AG:Create("CheckBox")
    ColourByClassToggle:SetLabel("Colour By Class")
    ColourByClassToggle:SetValue(PowerBarDB.ColourByClass)
    ColourByClassToggle:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.ColourByClass = value updateCallback() RefreshPowerBarGUI() end)
    ColourByClassToggle:SetRelativeWidth(0.33)
    ColourContainer:AddChild(ColourByClassToggle)

    -- local ColourBackgroundByTypeToggle = AG:Create("CheckBox")
    -- ColourBackgroundByTypeToggle:SetLabel("Colour Background By Type")
    -- ColourBackgroundByTypeToggle:SetValue(PowerBarDB.ColourBackgroundByType)
    -- ColourBackgroundByTypeToggle:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.ColourBackgroundByType = value updateCallback() RefreshPowerBarGUI() end)
    -- ColourBackgroundByTypeToggle:SetRelativeWidth(0.25)
    -- ColourBackgroundByTypeToggle:SetDisabled(true)
    -- ColourContainer:AddChild(ColourBackgroundByTypeToggle)

    local ForegroundColourPicker = AG:Create("ColorPicker")
    ForegroundColourPicker:SetLabel("Foreground Colour")
    local R, G, B, A = unpack(PowerBarDB.Foreground)
    ForegroundColourPicker:SetColor(R, G, B, A)
    ForegroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) PowerBarDB.Foreground = {r, g, b, a} updateCallback() end)
    ForegroundColourPicker:SetHasAlpha(true)
    ForegroundColourPicker:SetRelativeWidth(0.5)
    ForegroundColourPicker:SetDisabled(PowerBarDB.ColourByClass or PowerBarDB.ColourByType)
    ColourContainer:AddChild(ForegroundColourPicker)

    local BackgroundColourPicker = AG:Create("ColorPicker")
    BackgroundColourPicker:SetLabel("Background Colour")
    local R2, G2, B2, A2 = unpack(PowerBarDB.Background)
    BackgroundColourPicker:SetColor(R2, G2, B2, A2)
    BackgroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) PowerBarDB.Background = {r, g, b, a} updateCallback() end)
    BackgroundColourPicker:SetHasAlpha(true)
    BackgroundColourPicker:SetRelativeWidth(0.5)
    BackgroundColourPicker:SetDisabled(PowerBarDB.ColourBackgroundByType)
    ColourContainer:AddChild(BackgroundColourPicker)

    -- local BackgroundMultiplierSlider = AG:Create("Slider")
    -- BackgroundMultiplierSlider:SetLabel("Background Multiplier")
    -- BackgroundMultiplierSlider:SetValue(PowerBarDB.BackgroundMultiplier)
    -- BackgroundMultiplierSlider:SetSliderValues(0, 1, 0.01)
    -- BackgroundMultiplierSlider:SetRelativeWidth(0.33)
    -- BackgroundMultiplierSlider:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.BackgroundMultiplier = value updateCallback() end)
    -- BackgroundMultiplierSlider:SetIsPercent(true)
    -- BackgroundMultiplierSlider:SetDisabled(true)
    -- ColourContainer:AddChild(BackgroundMultiplierSlider)

    local BorderColourPicker = AG:Create("ColorPicker")
    BorderColourPicker:SetLabel("Divider Colour")
    local R3, G3, B3, A3 = unpack(PowerBarDB.BorderColour)
    BorderColourPicker:SetColor(R3, G3, B3, A3)
    BorderColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) PowerBarDB.BorderColour = {r, g, b, a} updateCallback() end)
    BorderColourPicker:SetHasAlpha(true)
    BorderColourPicker:SetRelativeWidth(0.25)
    BorderColourPicker:SetDisabled(not PowerBarDB.ShowBorder)
    ColourContainer:AddChild(BorderColourPicker)
    UUFGUI.FrameBorderColourPicker = BorderColourPicker

    local ShowBorderToggle = AG:Create("CheckBox")
    ShowBorderToggle:SetLabel("Show Divider")
    ShowBorderToggle:SetValue(PowerBarDB.ShowBorder)
    ShowBorderToggle:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.ShowBorder = value UUFGUI.FrameBorderColourPicker:SetDisabled(not PowerBarDB.ShowBorder) updateCallback() end)
    ShowBorderToggle:SetRelativeWidth(0.25)
    ColourContainer:AddChild(ShowBorderToggle)

    function RefreshPowerBarGUI()
        if PowerBarDB.Enabled then
            GUIWidgets.DeepDisable(LayoutContainer, false, Toggle)
            GUIWidgets.DeepDisable(ColourContainer, false, Toggle)
            if PowerBarDB.ColourByClass or PowerBarDB.ColourByType then
                ForegroundColourPicker:SetDisabled(true)
            else
                ForegroundColourPicker:SetDisabled(false)
            end
            -- BackgroundMultiplierSlider:SetDisabled(true)
            -- ColourBackgroundByTypeToggle:SetDisabled(true)
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
    Toggle:SetRelativeWidth(0.5)
    LayoutContainer:AddChild(Toggle)

    local HeightSlider = AG:Create("Slider")
    HeightSlider:SetLabel("Height")
    HeightSlider:SetValue(SecondaryPowerBarDB.Height)
    HeightSlider:SetSliderValues(1, FrameDB.Height - 2, 0.1)
    HeightSlider:SetRelativeWidth(0.5)
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
    WidthSlider:SetSliderValues(1, 1000, 0.1)
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
    XPosSlider:SetSliderValues(-1000, 1000, 0.1)
    XPosSlider:SetRelativeWidth(0.5)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) AlternativePowerBarDB.Layout[3] = value updateCallback() end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(AlternativePowerBarDB.Layout[4])
    YPosSlider:SetSliderValues(-1000, 1000, 0.1)
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

    local ToggleContainer = GUIWidgets.CreateInlineGroup(containerParent, "Portrait Settings")

    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel("Enable |cFF8080FFPortrait|r")
    Toggle:SetValue(PortraitDB.Enabled)
    Toggle:SetCallback("OnValueChanged", function(_, _, value) PortraitDB.Enabled = value updateCallback() RefreshPortraitGUI() end)
    Toggle:SetRelativeWidth(0.33)
    ToggleContainer:AddChild(Toggle)

    local PortraitStyleDropdown = AG:Create("Dropdown")
    PortraitStyleDropdown:SetList({["2D"] = "2D", ["3D"] = "3D"})
    PortraitStyleDropdown:SetLabel("Portrait Style")
    PortraitStyleDropdown:SetValue(PortraitDB.Style)
    PortraitStyleDropdown:SetRelativeWidth(0.33)
    PortraitStyleDropdown:SetCallback("OnValueChanged", function(_, _, value) PortraitDB.Style = value updateCallback() RefreshPortraitGUI() end)
    ToggleContainer:AddChild(PortraitStyleDropdown)

    local UseClassPortraitToggle = AG:Create("CheckBox")
    UseClassPortraitToggle:SetLabel("Use Class Portrait")
    UseClassPortraitToggle:SetValue(PortraitDB.UseClassPortrait)
    UseClassPortraitToggle:SetCallback("OnValueChanged", function(_, _, value) PortraitDB.UseClassPortrait = value updateCallback() end)
    UseClassPortraitToggle:SetRelativeWidth(0.33)
    UseClassPortraitToggle:SetDisabled(PortraitDB.Style ~= "2D")
    ToggleContainer:AddChild(UseClassPortraitToggle)

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
    XPosSlider:SetSliderValues(-1000, 1000, 0.1)
    XPosSlider:SetRelativeWidth(0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) PortraitDB.Layout[3] = value updateCallback() end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(PortraitDB.Layout[4])
    YPosSlider:SetSliderValues(-1000, 1000, 0.1)
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
    ZoomSlider:SetDisabled(PortraitDB.Style ~= "2D")
    LayoutContainer:AddChild(ZoomSlider)

    local WidthSlider = AG:Create("Slider")
    WidthSlider:SetLabel("Width")
    WidthSlider:SetValue(PortraitDB.Width)
    WidthSlider:SetSliderValues(8, 64, 0.1)
    WidthSlider:SetRelativeWidth(0.5)
    WidthSlider:SetCallback("OnValueChanged", function(_, _, value) PortraitDB.Width = value updateCallback() end)
    LayoutContainer:AddChild(WidthSlider)

    local HeightSlider = AG:Create("Slider")
    HeightSlider:SetLabel("Height")
    HeightSlider:SetValue(PortraitDB.Height)
    HeightSlider:SetSliderValues(8, 64, 0.1)
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
        UseClassPortraitToggle:SetDisabled(PortraitDB.Style ~= "2D")
        ZoomSlider:SetDisabled(PortraitDB.Style ~= "2D")
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
    XPosSlider:SetSliderValues(-1000, 1000, 0.1)
    XPosSlider:SetRelativeWidth(0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) RaidTargetMarkerDB.Layout[3] = value updateCallback() end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(RaidTargetMarkerDB.Layout[4])
    YPosSlider:SetSliderValues(-1000, 1000, 0.1)
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
    XPosSlider:SetSliderValues(-1000, 1000, 0.1)
    XPosSlider:SetRelativeWidth(0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) LeaderAssistantDB.Layout[3] = value updateCallback() end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(LeaderAssistantDB.Layout[4])
    YPosSlider:SetSliderValues(-1000, 1000, 0.1)
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
    XPosSlider:SetSliderValues(-1000, 1000, 0.1)
    XPosSlider:SetRelativeWidth(0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) StatusDB.Layout[3] = value updateCallback() end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(StatusDB.Layout[4])
    YPosSlider:SetSliderValues(-1000, 1000, 0.1)
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

    local TotemDurationContainer = GUIWidgets.CreateInlineGroup(containerParent, "Aura Duration Settings")

    local ColourPicker = AG:Create("ColorPicker")
    ColourPicker:SetLabel("Cooldown Text Colour")
    ColourPicker:SetColor(UUF.db.profile.Units[unit].Indicators.Totems.TotemDuration.Colour[1], UUF.db.profile.Units[unit].Indicators.Totems.TotemDuration.Colour[2], UUF.db.profile.Units[unit].Indicators.Totems.TotemDuration.Colour[3], 1)
    ColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b) UUF.db.profile.Units[unit].Indicators.Totems.TotemDuration.Colour = {r, g, b} UUF:UpdateUnitTotems(UUF[unit:upper()], unit) end)
    ColourPicker:SetHasAlpha(false)
    ColourPicker:SetRelativeWidth(0.5)
    TotemDurationContainer:AddChild(ColourPicker)

    local ScaleByIconSizeCheckbox = AG:Create("CheckBox")
    ScaleByIconSizeCheckbox:SetLabel("Scale Cooldown Text By Icon Size")
    ScaleByIconSizeCheckbox:SetValue(UUF.db.profile.Units[unit].Indicators.Totems.TotemDuration.ScaleByIconSize)
    ScaleByIconSizeCheckbox:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.Units[unit].Indicators.Totems.TotemDuration.ScaleByIconSize = value UUF:UpdateUnitTotems(UUF[unit:upper()], unit) RefreshFontSizeSlider() end)
    ScaleByIconSizeCheckbox:SetRelativeWidth(0.5)
    TotemDurationContainer:AddChild(ScaleByIconSizeCheckbox)

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(UUF.db.profile.Units[unit].Indicators.Totems.TotemDuration.Layout[1])
    AnchorFromDropdown:SetRelativeWidth(0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.Units[unit].Indicators.Totems.TotemDuration.Layout[1] = value UUF:UpdateUnitTotems(UUF[unit:upper()], unit) end)
    TotemDurationContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(UUF.db.profile.Units[unit].Indicators.Totems.TotemDuration.Layout[2])
    AnchorToDropdown:SetRelativeWidth(0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.Units[unit].Indicators.Totems.TotemDuration.Layout[2] = value UUF:UpdateUnitTotems(UUF[unit:upper()], unit) end)
    TotemDurationContainer:AddChild(AnchorToDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(UUF.db.profile.Units[unit].Indicators.Totems.TotemDuration.Layout[3])
    XPosSlider:SetSliderValues(-1000, 1000, 0.1)
    XPosSlider:SetRelativeWidth(0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.Units[unit].Indicators.Totems.TotemDuration.Layout[3] = value UUF:UpdateUnitTotems(UUF[unit:upper()], unit) end)
    TotemDurationContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(UUF.db.profile.Units[unit].Indicators.Totems.TotemDuration.Layout[4])
    YPosSlider:SetSliderValues(-1000, 1000, 0.1)
    YPosSlider:SetRelativeWidth(0.33)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.Units[unit].Indicators.Totems.TotemDuration.Layout[4] = value UUF:UpdateUnitTotems(UUF[unit:upper()], unit) end)
    TotemDurationContainer:AddChild(YPosSlider)

    local FontSizeSlider = AG:Create("Slider")
    FontSizeSlider:SetLabel("Font Size")
    FontSizeSlider:SetValue(UUF.db.profile.Units[unit].Indicators.Totems.TotemDuration.FontSize)
    FontSizeSlider:SetSliderValues(8, 64, 1)
    FontSizeSlider:SetRelativeWidth(0.33)
    FontSizeSlider:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.Units[unit].Indicators.Totems.TotemDuration.FontSize = value UUF:UpdateUnitTotems(UUF[unit:upper()], unit) end)
    FontSizeSlider:SetDisabled(UUF.db.profile.Units[unit].Indicators.Totems.TotemDuration.ScaleByIconSize)
    TotemDurationContainer:AddChild(FontSizeSlider)

    local ToggleContainer = GUIWidgets.CreateInlineGroup(containerParent, "Totems Settings")

    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel("Enable |cFF8080FFTotems|r")
    Toggle:SetValue(TotemsIndicatorDB.Enabled)
    Toggle:SetCallback("OnValueChanged", function(_, _, value) TotemsIndicatorDB.Enabled = value updateCallback() RefreshTotemsIndicatorGUI() end)
    Toggle:SetRelativeWidth(0.5)
    ToggleContainer:AddChild(Toggle)

    local SizeSlider = AG:Create("Slider")
    SizeSlider:SetLabel("Icon Size")
    SizeSlider:SetValue(TotemsIndicatorDB.Size)
    SizeSlider:SetSliderValues(8, 64, 1)
    SizeSlider:SetRelativeWidth(0.5)
    SizeSlider:SetCallback("OnValueChanged", function(_, _, value) TotemsIndicatorDB.Size = value updateCallback() end)
    ToggleContainer:AddChild(SizeSlider)

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Layout & Positioning")
    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(TotemsIndicatorDB.Layout[1])
    AnchorFromDropdown:SetRelativeWidth(0.33)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) TotemsIndicatorDB.Layout[1] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(TotemsIndicatorDB.Layout[2])
    AnchorToDropdown:SetRelativeWidth(0.33)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) TotemsIndicatorDB.Layout[2] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorToDropdown)

    local GrowthDirectionDropdown = AG:Create("Dropdown")
    GrowthDirectionDropdown:SetList({["RIGHT"] = "Right", ["LEFT"] = "Left"})
    GrowthDirectionDropdown:SetLabel("Growth Direction")
    GrowthDirectionDropdown:SetValue(TotemsIndicatorDB.GrowthDirection)
    GrowthDirectionDropdown:SetRelativeWidth(0.33)
    GrowthDirectionDropdown:SetCallback("OnValueChanged", function(_, _, value) TotemsIndicatorDB.GrowthDirection = value updateCallback() end)
    LayoutContainer:AddChild(GrowthDirectionDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(TotemsIndicatorDB.Layout[3])
    XPosSlider:SetSliderValues(-1000, 1000, 0.1)
    XPosSlider:SetRelativeWidth(0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) TotemsIndicatorDB.Layout[3] = value updateCallback() end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(TotemsIndicatorDB.Layout[4])
    YPosSlider:SetSliderValues(-1000, 1000, 0.1)
    YPosSlider:SetRelativeWidth(0.33)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) TotemsIndicatorDB.Layout[4] = value updateCallback() end)
    LayoutContainer:AddChild(YPosSlider)

    local SpacingSlider = AG:Create("Slider")
    SpacingSlider:SetLabel("Totems Indicator Spacing")
    SpacingSlider:SetValue(TotemsIndicatorDB.Layout[5])
    SpacingSlider:SetSliderValues(0, 100, 1)
    SpacingSlider:SetRelativeWidth(0.33)
    SpacingSlider:SetCallback("OnValueChanged", function(_, _, value) TotemsIndicatorDB.Layout[5] = value updateCallback() end)
    LayoutContainer:AddChild(SpacingSlider)

    function RefreshTotemsIndicatorGUI()
        if TotemsIndicatorDB.Enabled then
            GUIWidgets.DeepDisable(ToggleContainer, false, Toggle)
        else
            GUIWidgets.DeepDisable(ToggleContainer, true, Toggle)
        end
    end

    RefreshTotemsIndicatorGUI()
end

local function CreateIndicatorSettings(containerParent, unit)
    local function SelectIndicatorTab(IndicatorContainer, _, IndicatorTab)
        SaveSubTab(unit, "Indicators", IndicatorTab)
        IndicatorContainer:ReleaseChildren()
        if IndicatorTab == "RaidTargetMarker" then
            CreateRaidTargetMarkerSettings(IndicatorContainer, unit, function() if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitRaidTargetMarker(UUF[unit:upper()], unit) end end)
        elseif IndicatorTab == "LeaderAssistant" then
            CreateLeaderAssistaintSettings(IndicatorContainer, unit, function() UUF:UpdateUnitLeaderAssistantIndicator(UUF[unit:upper()], unit) end)
        elseif IndicatorTab == "Resting" then
            CreateStatusSettings(IndicatorContainer, unit, "Resting", function() UUF:UpdateUnitRestingIndicator(UUF[unit:upper()], unit) end)
        elseif IndicatorTab == "Combat" then
            CreateStatusSettings(IndicatorContainer, unit, "Combat", function() UUF:UpdateUnitCombatIndicator(UUF[unit:upper()], unit) end)
        elseif IndicatorTab == "Mouseover" then
            CreateMouseoverSettings(IndicatorContainer, unit, function() if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitMouseoverIndicator(UUF[unit:upper()], unit) end end)
        elseif IndicatorTab == "TargetIndicator" then
            CreateTargetIndicatorSettings(IndicatorContainer, unit, function() if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitTargetGlowIndicator(UUF[unit:upper()], unit) end end)
        elseif IndicatorTab == "Totems" then
            -- CreateTotemsIndicatorSettings(IndicatorContainer, unit, function() UUF:UpdateUnitTotems(UUF[unit:upper()], unit) end)
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
            { text = "Mouseover", value = "Mouseover" },
            -- { text = "Totems", value = "Totems" },
        })
    elseif unit == "target" then
        IndicatorContainerTabGroup:SetTabs({
            { text = "Raid Target Marker", value = "RaidTargetMarker" },
            { text = "Leader & Assistant", value = "LeaderAssistant" },
            { text = "Combat", value = "Combat" },
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
    EditBox:SetCallback("OnEnterPressed", function(_, _, value) TagDB.Tag = value EditBox:SetText(TagDB.Tag) if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitTag(UUF[unit:upper()], unit, tagDB) end end)
    TagContainer:AddChild(EditBox)

    local ColourPicker = AG:Create("ColorPicker")
    ColourPicker:SetLabel("Colour")
    ColourPicker:SetColor(TagDB.Colour[1], TagDB.Colour[2], TagDB.Colour[3], 1)
    ColourPicker:SetFullWidth(true)
    ColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b) TagDB.Colour = {r, g, b} if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitTag(UUF[unit:upper()], unit, tagDB) end end)
    ColourPicker:SetHasAlpha(false)
    ColourPicker:SetRelativeWidth(0.5)
    TagContainer:AddChild(ColourPicker)

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Layout & Positioning")

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(TagDB.Layout[1])
    AnchorFromDropdown:SetRelativeWidth(0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) TagDB.Layout[1] = value if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitTag(UUF[unit:upper()], unit, tagDB) end end)
    LayoutContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(TagDB.Layout[2])
    AnchorToDropdown:SetRelativeWidth(0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) TagDB.Layout[2] = value if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitTag(UUF[unit:upper()], unit, tagDB) end end)
    LayoutContainer:AddChild(AnchorToDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(TagDB.Layout[3])
    XPosSlider:SetSliderValues(-1000, 1000, 0.1)
    XPosSlider:SetRelativeWidth(0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) TagDB.Layout[3] = value if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitTag(UUF[unit:upper()], unit, tagDB) end end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(TagDB.Layout[4])
    YPosSlider:SetSliderValues(-1000, 1000, 0.1)
    YPosSlider:SetRelativeWidth(0.33)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) TagDB.Layout[4] = value if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitTag(UUF[unit:upper()], unit, tagDB) end end)
    LayoutContainer:AddChild(YPosSlider)

    local FontSizeSlider = AG:Create("Slider")
    FontSizeSlider:SetLabel("Font Size")
    FontSizeSlider:SetValue(TagDB.FontSize)
    FontSizeSlider:SetSliderValues(8, 64, 1)
    FontSizeSlider:SetRelativeWidth(0.33)
    FontSizeSlider:SetCallback("OnValueChanged", function(_, _, value) TagDB.FontSize = value if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitTag(UUF[unit:upper()], unit, tagDB) end end)
    LayoutContainer:AddChild(FontSizeSlider)

    local TagSelectionContainer = GUIWidgets.CreateInlineGroup(containerParent, "Tag Selection")
    GUIWidgets.CreateInformationTag(TagSelectionContainer, "You can use the dropdowns below to quickly add tags.\n|cFF8080FFPrefix|r indicates that this should be added to the start of the tag string.")

    local HealthTagDropdown = AG:Create("Dropdown")
    HealthTagDropdown:SetList(UUF:FetchTagData("Health")[1], UUF:FetchTagData("Health")[2])
    HealthTagDropdown:SetLabel("Health Tags")
    HealthTagDropdown:SetValue(nil)
    HealthTagDropdown:SetRelativeWidth(0.5)
    HealthTagDropdown:SetCallback("OnValueChanged", function(_, _, value) local currentTag = TagDB.Tag if currentTag and currentTag ~= "" then currentTag = currentTag .. "[" .. value .. "]" else currentTag = "[" .. value .. "]" end EditBox:SetText(currentTag) UUF.db.profile.Units[unit].Tags[tagDB].Tag = currentTag UUF:UpdateUnitTag(UUF[unit:upper()], unit, tagDB) HealthTagDropdown:SetValue(nil) end)
    TagSelectionContainer:AddChild(HealthTagDropdown)

    local PowerTagDropdown = AG:Create("Dropdown")
    PowerTagDropdown:SetList(UUF:FetchTagData("Power")[1], UUF:FetchTagData("Power")[2])
    PowerTagDropdown:SetLabel("Power Tags")
    PowerTagDropdown:SetValue(nil)
    PowerTagDropdown:SetRelativeWidth(0.5)
    PowerTagDropdown:SetCallback("OnValueChanged", function(_, _, value) local currentTag = TagDB.Tag if currentTag and currentTag ~= "" then currentTag = currentTag .. "[" .. value .. "]" else currentTag = "[" .. value .. "]" end EditBox:SetText(currentTag) UUF.db.profile.Units[unit].Tags[tagDB].Tag = currentTag if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitTag(UUF[unit:upper()], unit, tagDB) end PowerTagDropdown:SetValue(nil) end)
    TagSelectionContainer:AddChild(PowerTagDropdown)

    local NameTagDropdown = AG:Create("Dropdown")
    NameTagDropdown:SetList(UUF:FetchTagData("Name")[1], UUF:FetchTagData("Name")[2])
    NameTagDropdown:SetLabel("Name Tags")
    NameTagDropdown:SetValue(nil)
    NameTagDropdown:SetRelativeWidth(0.5)
    NameTagDropdown:SetCallback("OnValueChanged", function(_, _, value) local currentTag = TagDB.Tag if currentTag and currentTag ~= "" then currentTag = currentTag .. "[" .. value .. "]" else currentTag = "[" .. value .. "]" end EditBox:SetText(currentTag) UUF.db.profile.Units[unit].Tags[tagDB].Tag = currentTag if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitTag(UUF[unit:upper()], unit, tagDB) end NameTagDropdown:SetValue(nil) end)
    TagSelectionContainer:AddChild(NameTagDropdown)

    local MiscTagDropdown = AG:Create("Dropdown")
    MiscTagDropdown:SetList(UUF:FetchTagData("Misc")[1], UUF:FetchTagData("Misc")[2])
    MiscTagDropdown:SetLabel("Misc Tags")
    MiscTagDropdown:SetValue(nil)
    MiscTagDropdown:SetRelativeWidth(0.5)
    MiscTagDropdown:SetCallback("OnValueChanged", function(_, _, value) local currentTag = TagDB.Tag if currentTag and currentTag ~= "" then currentTag = currentTag .. "[" .. value .. "]" else currentTag = "[" .. value .. "]" end EditBox:SetText(currentTag) UUF.db.profile.Units[unit].Tags[tagDB].Tag = currentTag if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitTag(UUF[unit:upper()], unit, tagDB) end MiscTagDropdown:SetValue(nil) end)
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

    local AuraContainer = GUIWidgets.CreateInlineGroup(containerParent, auraDB .. " Settings")

    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel("Enable |cFF8080FF"..auraDB.."|r")
    Toggle:SetValue(AuraDB.Enabled)
    Toggle:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Enabled = value if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end RefreshAuraGUI() end)
    Toggle:SetRelativeWidth(0.33)
    AuraContainer:AddChild(Toggle)

    local OnlyShowPlayerToggle = AG:Create("CheckBox")
    OnlyShowPlayerToggle:SetLabel("Only Show Player "..auraDB)
    OnlyShowPlayerToggle:SetValue(AuraDB.OnlyShowPlayer)
    OnlyShowPlayerToggle:SetCallback("OnValueChanged", function(_, _, value) AuraDB.OnlyShowPlayer = value if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end end)
    OnlyShowPlayerToggle:SetRelativeWidth(0.33)
    AuraContainer:AddChild(OnlyShowPlayerToggle)

    local ShowTypeCheckbox = AG:Create("CheckBox")
    ShowTypeCheckbox:SetLabel(auraDB .. " Type Border")
    ShowTypeCheckbox:SetValue(AuraDB.ShowType)
    ShowTypeCheckbox:SetCallback("OnValueChanged", function(_, _, value) AuraDB.ShowType = value if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end end)
    ShowTypeCheckbox:SetRelativeWidth(0.33)
    AuraContainer:AddChild(ShowTypeCheckbox)

    local FilterDropdown = AG:Create("Dropdown")
    if auraDB == "Buffs" then
        FilterDropdown:SetList({
            ["HELPFUL"] = "All",
            ["HELPFUL|PLAYER"] = "Player",
            ["HELPFUL|RAID"] = "Raid",
            ["INCLUDE_NAME_PLATE_ONLY"] = "Nameplate",
        })
    else
        FilterDropdown:SetList({
            ["HARMFUL"] = "All",
            ["HARMFUL|PLAYER"] = "Player",
            ["HARMFUL|RAID"] = "Raid",
            ["INCLUDE_NAME_PLATE_ONLY"] = "Nameplate",
        })
    end
    FilterDropdown:SetLabel("Aura Filter")
    FilterDropdown:SetValue(AuraDB.Filter or (auraDB == "Buffs" and "HELPFUL" or "HARMFUL"))
    FilterDropdown:SetRelativeWidth(1.0)
    FilterDropdown:SetCallback("OnValueChanged", function(_, _, value)
        AuraDB.Filter = value
        if unit == "boss" then
            UUF:UpdateBossFrames()
        else
            UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB)
        end
    end)
    AuraContainer:AddChild(FilterDropdown)

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Layout & Positioning")

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(AuraDB.Layout[1])
    AnchorFromDropdown:SetRelativeWidth(0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Layout[1] = value if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end end)
    LayoutContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(AuraDB.Layout[2])
    AnchorToDropdown:SetRelativeWidth(0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Layout[2] = value if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end end)
    LayoutContainer:AddChild(AnchorToDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(AuraDB.Layout[3])
    XPosSlider:SetSliderValues(-1000, 1000, 0.1)
    XPosSlider:SetRelativeWidth(0.25)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Layout[3] = value if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(AuraDB.Layout[4])
    YPosSlider:SetSliderValues(-1000, 1000, 0.1)
    YPosSlider:SetRelativeWidth(0.25)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Layout[4] = value if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end end)
    LayoutContainer:AddChild(YPosSlider)

    local SizeSlider = AG:Create("Slider")
    SizeSlider:SetLabel("Size")
    SizeSlider:SetValue(AuraDB.Size)
    SizeSlider:SetSliderValues(8, 64, 1)
    SizeSlider:SetRelativeWidth(0.25)
    SizeSlider:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Size = value if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end end)
    LayoutContainer:AddChild(SizeSlider)

    local SpacingSlider = AG:Create("Slider")
    SpacingSlider:SetLabel("Spacing")
    SpacingSlider:SetValue(AuraDB.Layout[5])
    SpacingSlider:SetSliderValues(-5, 5, 1)
    SpacingSlider:SetRelativeWidth(0.25)
    SpacingSlider:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Layout[5] = value if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end end)
    LayoutContainer:AddChild(SpacingSlider)

    GUIWidgets.CreateHeader(LayoutContainer, "Layout")

    local NumAurasSlider = AG:Create("Slider")
    NumAurasSlider:SetLabel(auraDB .. " To Display")
    NumAurasSlider:SetValue(AuraDB.Num)
    NumAurasSlider:SetSliderValues(1, 24, 1)
    NumAurasSlider:SetRelativeWidth(0.5)
    NumAurasSlider:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Num = value if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end end)
    LayoutContainer:AddChild(NumAurasSlider)

    local PerRowSlider = AG:Create("Slider")
    PerRowSlider:SetLabel(auraDB .. " Per Row")
    PerRowSlider:SetValue(AuraDB.Wrap)
    PerRowSlider:SetSliderValues(1, 24, 1)
    PerRowSlider:SetRelativeWidth(0.5)
    PerRowSlider:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Wrap = value if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end end)
    LayoutContainer:AddChild(PerRowSlider)

    local GrowthDirectionDropdown = AG:Create("Dropdown")
    GrowthDirectionDropdown:SetList({ ["LEFT"] = "Left", ["RIGHT"] = "Right"})
    GrowthDirectionDropdown:SetLabel("Growth Direction")
    GrowthDirectionDropdown:SetValue(AuraDB.GrowthDirection)
    GrowthDirectionDropdown:SetRelativeWidth(0.5)
    GrowthDirectionDropdown:SetCallback("OnValueChanged", function(_, _, value) AuraDB.GrowthDirection = value if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end end)
    LayoutContainer:AddChild(GrowthDirectionDropdown)

    local WrapDirectionDropdown = AG:Create("Dropdown")
    WrapDirectionDropdown:SetList({ ["UP"] = "Up", ["DOWN"] = "Down"})
    WrapDirectionDropdown:SetLabel("Wrap Direction")
    WrapDirectionDropdown:SetValue(AuraDB.WrapDirection)
    WrapDirectionDropdown:SetRelativeWidth(0.5)
    WrapDirectionDropdown:SetCallback("OnValueChanged", function(_, _, value) AuraDB.WrapDirection = value if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end end)
    LayoutContainer:AddChild(WrapDirectionDropdown)

    local ShowBorderToggle = AG:Create("CheckBox")
    ShowBorderToggle:SetLabel("Show Borders")
    ShowBorderToggle:SetValue(AuraDB.ShowBorder)
    ShowBorderToggle:SetCallback("OnValueChanged", function(_, _, value) AuraDB.ShowBorder = value if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end end)
    ShowBorderToggle:SetRelativeWidth(0.25)
    LayoutContainer:AddChild(ShowBorderToggle)

    local CountContainer = GUIWidgets.CreateInlineGroup(containerParent, "Count Settings")

    local CountAnchorFromDropdown = AG:Create("Dropdown")
    CountAnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    CountAnchorFromDropdown:SetLabel("Anchor From")
    CountAnchorFromDropdown:SetValue(AuraDB.Count.Layout[1])
    CountAnchorFromDropdown:SetRelativeWidth(0.5)
    CountAnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Count.Layout[1] = value if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end end)
    CountContainer:AddChild(CountAnchorFromDropdown)

    local CountAnchorToDropdown = AG:Create("Dropdown")
    CountAnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    CountAnchorToDropdown:SetLabel("Anchor To")
    CountAnchorToDropdown:SetValue(AuraDB.Count.Layout[2])
    CountAnchorToDropdown:SetRelativeWidth(0.5)
    CountAnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Count.Layout[2] = value if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end end)
    CountContainer:AddChild(CountAnchorToDropdown)

    local CountXPosSlider = AG:Create("Slider")
    CountXPosSlider:SetLabel("X Position")
    CountXPosSlider:SetValue(AuraDB.Count.Layout[3])
    CountXPosSlider:SetSliderValues(-1000, 1000, 0.1)
    CountXPosSlider:SetRelativeWidth(0.25)
    CountXPosSlider:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Count.Layout[3] = value if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end end)
    CountContainer:AddChild(CountXPosSlider)

    local CountYPosSlider = AG:Create("Slider")
    CountYPosSlider:SetLabel("Y Position")
    CountYPosSlider:SetValue(AuraDB.Count.Layout[4])
    CountYPosSlider:SetSliderValues(-1000, 1000, 0.1)
    CountYPosSlider:SetRelativeWidth(0.25)
    CountYPosSlider:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Count.Layout[4] = value if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end end)
    CountContainer:AddChild(CountYPosSlider)

    local FontSizeSlider = AG:Create("Slider")
    FontSizeSlider:SetLabel("Font Size")
    FontSizeSlider:SetValue(AuraDB.Count.FontSize)
    FontSizeSlider:SetSliderValues(8, 64, 1)
    FontSizeSlider:SetRelativeWidth(0.25)
    FontSizeSlider:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Count.FontSize = value if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end end)
    CountContainer:AddChild(FontSizeSlider)

    local ColourPicker = AG:Create("ColorPicker")
    ColourPicker:SetLabel("Colour")
    ColourPicker:SetColor(AuraDB.Count.Colour[1], AuraDB.Count.Colour[2], AuraDB.Count.Colour[3], 1)
    ColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b) AuraDB.Count.Colour = {r, g, b} if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end end)
    ColourPicker:SetHasAlpha(false)
    ColourPicker:SetRelativeWidth(0.25)
    CountContainer:AddChild(ColourPicker)

    function RefreshAuraGUI()
        if AuraDB.Enabled then
            GUIWidgets.DeepDisable(AuraContainer, false, Toggle)
            GUIWidgets.DeepDisable(LayoutContainer, false, Toggle)
            GUIWidgets.DeepDisable(CountContainer, false, Toggle)
        else
            GUIWidgets.DeepDisable(AuraContainer, true, Toggle)
            GUIWidgets.DeepDisable(LayoutContainer, true, Toggle)
            GUIWidgets.DeepDisable(CountContainer, true, Toggle)
        end
    end

    RefreshAuraGUI()

    containerParent:DoLayout()
end

local function CreateAuraSettings(containerParent, unit)
    local AurasDB = UUF.db.profile.Units[unit].Auras
    local AuraDurationContainer = GUIWidgets.CreateInlineGroup(containerParent, "Aura Duration Settings")

    local ColourPicker = AG:Create("ColorPicker")
    ColourPicker:SetLabel("Cooldown Text Colour")
    ColourPicker:SetColor(UUF.db.profile.Units[unit].Auras.AuraDuration.Colour[1], UUF.db.profile.Units[unit].Auras.AuraDuration.Colour[2], UUF.db.profile.Units[unit].Auras.AuraDuration.Colour[3], 1)
    ColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b) UUF.db.profile.Units[unit].Auras.AuraDuration.Colour = {r, g, b} if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitAuras(UUF[unit:upper()], unit, "AuraDuration") end end)
    ColourPicker:SetHasAlpha(false)
    ColourPicker:SetRelativeWidth(0.5)
    AuraDurationContainer:AddChild(ColourPicker)

    local ScaleByIconSizeCheckbox = AG:Create("CheckBox")
    ScaleByIconSizeCheckbox:SetLabel("Scale Cooldown Text By Icon Size")
    ScaleByIconSizeCheckbox:SetValue(UUF.db.profile.Units[unit].Auras.AuraDuration.ScaleByIconSize)
    ScaleByIconSizeCheckbox:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.Units[unit].Auras.AuraDuration.ScaleByIconSize = value if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitAuras(UUF[unit:upper()], unit, "AuraDuration") end RefreshFontSizeSlider() end)
    ScaleByIconSizeCheckbox:SetRelativeWidth(0.5)
    AuraDurationContainer:AddChild(ScaleByIconSizeCheckbox)

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(UUF.db.profile.Units[unit].Auras.AuraDuration.Layout[1])
    AnchorFromDropdown:SetRelativeWidth(0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.Units[unit].Auras.AuraDuration.Layout[1] = value if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitAuras(UUF[unit:upper()], unit, "AuraDuration") end end)
    AuraDurationContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(UUF.db.profile.Units[unit].Auras.AuraDuration.Layout[2])
    AnchorToDropdown:SetRelativeWidth(0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.Units[unit].Auras.AuraDuration.Layout[2] = value if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitAuras(UUF[unit:upper()], unit, "AuraDuration") end end)
    AuraDurationContainer:AddChild(AnchorToDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(UUF.db.profile.Units[unit].Auras.AuraDuration.Layout[3])
    XPosSlider:SetSliderValues(-1000, 1000, 0.1)
    XPosSlider:SetRelativeWidth(0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.Units[unit].Auras.AuraDuration.Layout[3] = value if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitAuras(UUF[unit:upper()], unit, "AuraDuration") end end)
    AuraDurationContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(UUF.db.profile.Units[unit].Auras.AuraDuration.Layout[4])
    YPosSlider:SetSliderValues(-1000, 1000, 0.1)
    YPosSlider:SetRelativeWidth(0.33)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.Units[unit].Auras.AuraDuration.Layout[4] = value if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitAuras(UUF[unit:upper()], unit, "AuraDuration") end end)
    AuraDurationContainer:AddChild(YPosSlider)

    local FontSizeSlider = AG:Create("Slider")
    FontSizeSlider:SetLabel("Font Size")
    FontSizeSlider:SetValue(UUF.db.profile.Units[unit].Auras.AuraDuration.FontSize)
    FontSizeSlider:SetSliderValues(8, 64, 1)
    FontSizeSlider:SetRelativeWidth(0.33)
    FontSizeSlider:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.Units[unit].Auras.AuraDuration.FontSize = value if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitAuras(UUF[unit:upper()], unit, "AuraDuration") end end)
    FontSizeSlider:SetDisabled(UUF.db.profile.Units[unit].Auras.AuraDuration.ScaleByIconSize)
    AuraDurationContainer:AddChild(FontSizeSlider)

    local FrameStrataDropdown = AG:Create("Dropdown")
    FrameStrataDropdown:SetList(FrameStrataList[1], FrameStrataList[2])
    FrameStrataDropdown:SetLabel("Frame Strata")
    FrameStrataDropdown:SetValue(AurasDB.FrameStrata)
    FrameStrataDropdown:SetRelativeWidth(1)
    FrameStrataDropdown:SetCallback("OnValueChanged", function(_, _, value) AurasDB.FrameStrata = value UUF:UpdateUnitAurasStrata(unit) end)
    containerParent:AddChild(FrameStrataDropdown)

    function RefreshFontSizeSlider()
        if UUF.db.profile.Units[unit].Auras.AuraDuration.ScaleByIconSize then
            FontSizeSlider:SetDisabled(true)
        else
            FontSizeSlider:SetDisabled(false)
        end
    end

    local function SelectAuraTab(AuraContainer, _, AuraTab)
        SaveSubTab(unit, "Auras", AuraTab)
        AuraContainer:ReleaseChildren()
        if AuraTab == "Buffs" then
            CreateSpecificAuraSettings(AuraContainer, unit, "Buffs")
        elseif AuraTab == "Debuffs" then
            CreateSpecificAuraSettings(AuraContainer, unit, "Debuffs")
        end
        C_Timer.After(0.001, RefreshFontSizeSlider)
        containerParent:DoLayout()
    end

    local AuraContainerTabGroup = AG:Create("TabGroup")
    AuraContainerTabGroup:SetLayout("Flow")
    AuraContainerTabGroup:SetFullWidth(true)
    AuraContainerTabGroup:SetTabs({ { text = "Buffs", value = "Buffs"}, { text = "Debuffs", value = "Debuffs"}, })
    AuraContainerTabGroup:SetCallback("OnGroupSelected", SelectAuraTab)
    AuraContainerTabGroup:SelectTab(GetSavedSubTab(unit, "Auras", "Buffs"))
    containerParent:AddChild(AuraContainerTabGroup)

    containerParent:DoLayout()
end

local function CreateAuraDurationSettings(containerParent)
    local AuraDurationContainer = GUIWidgets.CreateInlineGroup(containerParent, "Aura Duration Settings")

    local ColourPicker = AG:Create("ColorPicker")
    ColourPicker:SetLabel("Cooldown Text Colour")
    ColourPicker:SetColor(1, 1, 1, 1)
    ColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b) for _, unitDB in pairs(UUF.db.profile.Units) do unitDB.Auras.AuraDuration.Colour = {r, g, b} end UUF:UpdateAllUnitFrames() end)
    ColourPicker:SetHasAlpha(false)
    ColourPicker:SetRelativeWidth(0.5)
    AuraDurationContainer:AddChild(ColourPicker)

    local ScaleByIconSizeCheckbox = AG:Create("CheckBox")
    ScaleByIconSizeCheckbox:SetLabel("Scale Cooldown Text By Icon Size")
    ScaleByIconSizeCheckbox:SetValue(false)
    ScaleByIconSizeCheckbox:SetCallback("OnValueChanged", function(_, _, value) for _, unitDB in pairs(UUF.db.profile.Units) do unitDB.Auras.AuraDuration.ScaleByIconSize = value end UUF:UpdateAllUnitFrames() end)
    ScaleByIconSizeCheckbox:SetRelativeWidth(0.5)
    AuraDurationContainer:AddChild(ScaleByIconSizeCheckbox)

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue("CENTER")
    AnchorFromDropdown:SetRelativeWidth(0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) for _, unitDB in pairs(UUF.db.profile.Units) do unitDB.Auras.AuraDuration.Layout[1] = value end UUF:UpdateAllUnitFrames() end)
    AuraDurationContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue("CENTER")
    AnchorToDropdown:SetRelativeWidth(0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) for _, unitDB in pairs(UUF.db.profile.Units) do unitDB.Auras.AuraDuration.Layout[2] = value end UUF:UpdateAllUnitFrames() end)
    AuraDurationContainer:AddChild(AnchorToDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(0)
    XPosSlider:SetSliderValues(-1000, 1000, 0.1)
    XPosSlider:SetRelativeWidth(0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) for _, unitDB in pairs(UUF.db.profile.Units) do unitDB.Auras.AuraDuration.Layout[3] = value end UUF:UpdateAllUnitFrames() end)
    AuraDurationContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(0)
    YPosSlider:SetSliderValues(-1000, 1000, 0.1)
    YPosSlider:SetRelativeWidth(0.33)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) for _, unitDB in pairs(UUF.db.profile.Units) do unitDB.Auras.AuraDuration.Layout[4] = value end UUF:UpdateAllUnitFrames() end)
    AuraDurationContainer:AddChild(YPosSlider)

    local FontSizeSlider = AG:Create("Slider")
    FontSizeSlider:SetLabel("Font Size")
    FontSizeSlider:SetValue(12)
    FontSizeSlider:SetSliderValues(8, 64, 1)
    FontSizeSlider:SetRelativeWidth(0.33)
    FontSizeSlider:SetCallback("OnValueChanged", function(_, _, value) for _, unitDB in pairs(UUF.db.profile.Units) do unitDB.Auras.AuraDuration.FontSize = value end UUF:UpdateAllUnitFrames() end)
    FontSizeSlider:SetDisabled(false)
    AuraDurationContainer:AddChild(FontSizeSlider)
end

local function CreateGlobalSettings(containerParent)

    local GlobalContainer = GUIWidgets.CreateInlineGroup(containerParent, "Global Settings")

    GUIWidgets.CreateInformationTag(GlobalContainer, "The settings below will apply to all unit frames within" .. UUF.PRETTY_ADDON_NAME .. ".\nOptions are not dynamic. They are static but will apply to all unit frames when changed.")

    local ToggleContainer = GUIWidgets.CreateInlineGroup(GlobalContainer, "Toggles")

    local ApplyColours = AG:Create("Button")
    ApplyColours:SetText("Colour Mode")
    ApplyColours:SetRelativeWidth(0.5)
    ApplyColours:SetCallback("OnClick", function()
        for _, unitDB in pairs(UUF.db.profile.Units) do
            unitDB.HealthBar.ColourByClass = true
            unitDB.HealthBar.ColourWhenTapped = true
            unitDB.HealthBar.ColourBackgroundByClass = false
        end
        UUF:UpdateAllUnitFrames()
    end)
    ToggleContainer:AddChild(ApplyColours)

    local RemoveColours = AG:Create("Button")
    RemoveColours:SetText("Dark Mode")
    RemoveColours:SetRelativeWidth(0.5)
    RemoveColours:SetCallback("OnClick", function()
        for _, unitDB in pairs(UUF.db.profile.Units) do
            unitDB.HealthBar.ColourByClass = false
            unitDB.HealthBar.ColourWhenTapped = false
            unitDB.HealthBar.ColourBackgroundByClass = false
        end
        UUF:UpdateAllUnitFrames()
    end)
    ToggleContainer:AddChild(RemoveColours)

    CreateFontSettings(GlobalContainer)
    CreateTextureSettings(GlobalContainer)
    CreateRangeSettings(GlobalContainer)
    CreateAuraDurationSettings(GlobalContainer)

    local TagContainer = GUIWidgets.CreateInlineGroup(GlobalContainer, "Tag Settings")

    local UseCustomAbbreviationsCheckbox = AG:Create("CheckBox")
    UseCustomAbbreviationsCheckbox:SetLabel("Custom Abbreviations")
    UseCustomAbbreviationsCheckbox:SetValue(UUF.db.profile.General.UseCustomAbbreviations)
    UseCustomAbbreviationsCheckbox:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.General.UseCustomAbbreviations = value UUF:UpdateUnitTags() end)
    UseCustomAbbreviationsCheckbox:SetRelativeWidth(0.33)
    TagContainer:AddChild(UseCustomAbbreviationsCheckbox)

    local TagIntervalSlider = AG:Create("Slider")
    TagIntervalSlider:SetLabel("Tag Updates Per Second")
    TagIntervalSlider:SetValue(1 / UUF.db.profile.General.TagUpdateInterval)
    TagIntervalSlider:SetSliderValues(1, 10, 0.5)
    TagIntervalSlider:SetRelativeWidth(0.33)
    TagIntervalSlider:SetCallback("OnValueChanged", function(_, _, value) UUF.TAG_UPDATE_INTERVAL = 1 / value UUF.db.profile.General.TagUpdateInterval = 1 / value UUF:SetTagUpdateInterval() UUF:UpdateUnitTags() end)
    TagContainer:AddChild(TagIntervalSlider)

    local SeparatorDropdown = AG:Create("Dropdown")
    SeparatorDropdown:SetList(UUF.SEPARATOR_TAGS[1], UUF.SEPARATOR_TAGS[2])
    SeparatorDropdown:SetLabel("Tag Separator")
    SeparatorDropdown:SetValue(UUF.db.profile.General.Separator)
    SeparatorDropdown:SetRelativeWidth(0.33)
    SeparatorDropdown:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.General.Separator = value UUF:UpdateUnitTags() end)
    SeparatorDropdown:SetCallback("OnEnter", function() GameTooltip:SetOwner(SeparatorDropdown.frame, "ANCHOR_BOTTOM") GameTooltip:AddLine("The separator chosen here is only applied to custom tags which are combined. Such as |cFF8080FF[curhpperhp]|r or |cFF8080FF[curhpperhp:abbr]|r", 1, 1, 1) GameTooltip:Show() end)
    SeparatorDropdown:SetCallback("OnLeave", function() GameTooltip:Hide() end)
    TagContainer:AddChild(SeparatorDropdown)

    containerParent:DoLayout()
end

local function CreateUnitSettings(containerParent, unit)
    EnableUnitFrameToggle = AG:Create("CheckBox")
    EnableUnitFrameToggle:SetLabel("Enable |cFFFFCC00"..(UnitDBToUnitPrettyName[unit] or unit) .."|r")
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
    EnableUnitFrameToggle:SetRelativeWidth(0.5)
    containerParent:AddChild(EnableUnitFrameToggle)

    EnableUnitFrameToggle = AG:Create("CheckBox")
    EnableUnitFrameToggle:SetLabel("Hide Blizzard |cFFFFCC00"..(UnitDBToUnitPrettyName[unit] or unit) .."|r")
    EnableUnitFrameToggle:SetValue(UUF.db.profile.Units[unit].ForceHideBlizzard)
    EnableUnitFrameToggle:SetCallback("OnValueChanged", function(_, _, value)
            StaticPopupDialogs["UUF_RELOAD_UI"] = {
            text = "You must reload to apply this change, do you want to reload now?",
            button1 = "Reload Now",
            button2 = "Later",
            showAlert = true,
            OnAccept = function() UUF.db.profile.Units[unit].ForceHideBlizzard = value C_UI.Reload() end,
            OnCancel = function() EnableUnitFrameToggle:SetValue(UUF.db.profile.Units[unit].ForceHideBlizzard) containerParent:DoLayout() end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
        }
        StaticPopup_Show("UUF_RELOAD_UI")
    end)
    EnableUnitFrameToggle:SetRelativeWidth(0.5)
    EnableUnitFrameToggle:SetDisabled(UUF.db.profile.Units[unit].Enabled)
    containerParent:AddChild(EnableUnitFrameToggle)

    local function SelectUnitTab(SubContainer, _, UnitTab)
        if not lastSelectedUnitTabs[unit] then lastSelectedUnitTabs[unit] = {} end
        lastSelectedUnitTabs[unit].mainTab = UnitTab
        SubContainer:ReleaseChildren()
        if UnitTab == "Frame" then
            CreateFrameSettings(SubContainer, unit, UUF.db.profile.Units[unit].Frame.AnchorParent and true or false, function() if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitFrame(UUF[unit:upper()], unit) end end)
        elseif UnitTab == "HealPrediction" then
            CreateHealPredictionSettings(SubContainer, unit, function() if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitHealPrediction(UUF[unit:upper()], unit) end end)
        elseif UnitTab == "Auras" then
            CreateAuraSettings(SubContainer, unit)
        elseif UnitTab == "PowerBar" then
            CreatePowerBarSettings(SubContainer, unit, function() if unit == "boss" then UUF:UpdateBossFrames() else UUF:UpdateUnitPowerBar(UUF[unit:upper()], unit) end end)
        elseif UnitTab == "SecondaryPowerBar" then
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
        if UnitTab == "Auras" then EnableAurasTestMode(unit) else DisableAurasTestMode(unit) end
        if UnitTab == "CastBar" then EnableCastBarTestMode(unit) else DisableCastBarTestMode(unit) end
        containerParent:DoLayout()
    end

    local SubContainerTabGroup = AG:Create("TabGroup")
    SubContainerTabGroup:SetLayout("Flow")
    SubContainerTabGroup:SetFullWidth(true)
    if unit == "player" and UUF:RequiresAlternativePowerBar() then
        SubContainerTabGroup:SetTabs({
            { text = "Frame", value = "Frame"},
            { text = "Heal Prediction", value = "HealPrediction"},
            { text = "Auras", value = "Auras"},
            { text = "Power Bar", value = "PowerBar"},
            { text = "Secondary Power Bar", value = "SecondaryPowerBar"},
            { text = "Alternative Power Bar", value = "AlternativePowerBar"},
            { text = "Cast Bar", value = "CastBar"},
            { text = "Portrait", value = "Portrait"},
            { text = "Indicators", value = "Indicators"},
            { text = "Tags", value = "Tags"},
        })
    elseif unit == "player" then
        SubContainerTabGroup:SetTabs({
            { text = "Frame", value = "Frame"},
            { text = "Heal Prediction", value = "HealPrediction"},
            { text = "Auras", value = "Auras"},
            { text = "Power Bar", value = "PowerBar"},
            { text = "Secondary Power Bar", value = "SecondaryPowerBar"},
            { text = "Cast Bar", value = "CastBar"},
            { text = "Portrait", value = "Portrait"},
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
    SubContainerTabGroup:SelectTab(GetSavedMainTab(unit, "Frame"))
    containerParent:AddChild(SubContainerTabGroup)

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
        CopyFromProfileDropdown:SetValue(nil)
        DeleteProfileDropdown:SetValue(nil)
        if not next(profilesToDelete) then
            DeleteProfileDropdown:SetDisabled(true)
        else
            DeleteProfileDropdown:SetDisabled(false)
        end
        ResetProfileButton:SetText("Reset |cFF8080FF" .. UUF.db:GetCurrentProfile() .. "|r Profile")
        local isUsingGlobal = UUF.db.global.UseGlobalProfile
        ActiveProfileHeading:SetText( "Active Profile: |cFFFFFFFF" .. UUF.db:GetCurrentProfile() .. (isUsingGlobal and " (|cFFFFCC00Global|r)" or "") .. "|r" )
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
    UseGlobalProfileToggle:SetCallback("OnValueChanged", function(_, _, value) RefreshProfiles() UUF.db.global.UseGlobalProfile = value if value and UUF.db.global.GlobalProfile and UUF.db.global.GlobalProfile ~= "" then UUF.db:SetProfile(UUF.db.global.GlobalProfile) UUF:SetUIScale() end GlobalProfileDropdown:SetDisabled(not value) for _, child in ipairs(ProfileContainer.children) do if child ~= UseGlobalProfileToggle and child ~= GlobalProfileDropdown then GUIWidgets.DeepDisable(child, value) end end UUF:UpdateAllUnitFrames() RefreshProfiles() end)
    ProfileContainer:AddChild(UseGlobalProfileToggle)

    GlobalProfileDropdown = AG:Create("Dropdown")
    GlobalProfileDropdown:SetLabel("Global Profile...")
    GlobalProfileDropdown:SetRelativeWidth(0.5)
    GlobalProfileDropdown:SetList(profileKeys)
    GlobalProfileDropdown:SetValue(UUF.db.global.GlobalProfile)
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
    Container:SetWidth(900)
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

    local ContainerTabGroup = AG:Create("TabGroup")
    ContainerTabGroup:SetLayout("Flow")
    ContainerTabGroup:SetFullWidth(true)
    ContainerTabGroup:SetTabs({
        { text = "General", value = "General"},
        { text = "Global", value = "Global"},
        { text = "Player", value = "Player"},
        { text = "Target", value = "Target"},
        { text = "Target of Target", value = "TargetTarget"},
        { text = "Pet", value = "Pet"},
        { text = "Focus", value = "Focus"},
        { text = "Focus Target", value = "FocusTarget"},
        { text = "Boss", value = "Boss"},
        { text = "Tags", value = "Tags"},
        { text = "Profiles", value = "Profiles"},
    })
    ContainerTabGroup:SetCallback("OnGroupSelected", SelectTab)
    ContainerTabGroup:SelectTab("General")
    Container:AddChild(ContainerTabGroup)
end

function UUFG:OpenUUFGUI()
    UUF:CreateGUI()
end

function UUFG:CloseUUFGUI()
    if isGUIOpen and Container then
        Container:Hide()
    end
end
