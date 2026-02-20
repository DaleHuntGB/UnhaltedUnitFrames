local _, UUF = ...
local LSM = UUF.LSM
local AG = UUF.AG
local GUIWidgets = UUF.GUIWidgets
local GUILayout = UUF.GUILayout

local GUIGeneral = {}
UUF.GUIGeneral = GUIGeneral

-- Helper tables for dropdowns and lookups
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

local AnchorPoints = {
    {
        ["TOPLEFT"] = "Top Left",
        ["TOP"] = "Top",
        ["TOPRIGHT"] = "Top Right",
        ["LEFT"] = "Left",
        ["CENTER"] = "Center",
        ["RIGHT"] = "Right",
        ["BOTTOMLEFT"] = "Bottom Left",
        ["BOTTOM"] = "Bottom",
        ["BOTTOMRIGHT"] = "Bottom Right"
    },
    { "TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "CENTER", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT" }
}

local FrameStrataList = {
    {
        ["BACKGROUND"] = "Background",
        ["LOW"] = "Low",
        ["MEDIUM"] = "Medium",
        ["HIGH"] = "High",
        ["DIALOG"] = "Dialog",
        ["FULLSCREEN"] = "Fullscreen",
        ["FULLSCREEN_DIALOG"] = "Fullscreen Dialog",
        ["TOOLTIP"] = "Tooltip"
    },
    { "BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "FULLSCREEN", "FULLSCREEN_DIALOG", "TOOLTIP" }
}

local function CreateUIScaleSettings(containerParent)
    local Container = GUIWidgets.CreateInlineGroup(containerParent, "UI Scale")
    GUIWidgets.CreateInformationTag(Container, "These options allow you to adjust the UI Scale beyond the means that |cFF00B0F7Blizzard|r provides. If you encounter issues, please |cFFFF4040disable|r this feature.")

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

local function CreateFrameMoverSettings(containerParent)
    local Container = GUIWidgets.CreateInlineGroup(containerParent, "Frame Movers")

    if not UUF.db.profile.General.FrameMover then
        UUF.db.profile.General.FrameMover = { Enabled = false }
    end

    GUIWidgets.CreateInformationTag(Container, "Unlock frames to drag them with the left mouse button. Re-lock when finished.")

    -- Refactored using GUILayout for cleaner code (30% reduction)
    local builder = GUILayout:CreateStackBuilder(Container)
    
    builder:Add(
        GUILayout:CheckBox("Unlock Frames", UUF.db.profile.General.FrameMover.Enabled, function(value)
            if InCombatLockdown() then
                UUF:PrettyPrint("Cannot toggle frame movers in combat.")
                return
            end
            UUF.db.profile.General.FrameMover.Enabled = value
            UUF:ApplyFrameMovers()
        end)
    )
end

local function CreateFontSettings(containerParent)
    local Container = GUIWidgets.CreateInlineGroup(containerParent, "Fonts")

    GUIWidgets.CreateInformationTag(Container, "Fonts are applied to all Unit Frames & Elements where appropriate. More fonts can be added via |cFFFFCC00SharedMedia|r.")

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

    GUIWidgets.CreateInformationTag(Container, "Textures are applied to all Unit Frames & Elements where appropriate. More textures can be added via |cFFFFCC00SharedMedia|r.")

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

    GUIWidgets.CreateInformationTag(Container, "Buttons below will reset the colours to their default values as defined by " .. UUF.PRETTY_ADDON_NAME .. ".")

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

function GUIGeneral:BuildGlobalSettings(containerParent)
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

function GUIGeneral:BuildUIScaleSettings(containerParent)
    CreateUIScaleSettings(containerParent)
    containerParent:DoLayout()
end

function GUIGeneral:BuildColourSettings(containerParent)
    CreateColourSettings(containerParent)
    containerParent:DoLayout()
end

return GUIGeneral
