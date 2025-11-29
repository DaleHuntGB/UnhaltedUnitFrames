local _, UUF = ...
local AG = LibStub("AceGUI-3.0")
local GUIFrame;
local OpenedGUI = false
local LSM = UUF.LSM
local UnitToFrameName = UUF.UnitToFrameName

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
    { "TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "CENTER", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT", }
}

local PowerNames = {
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

local CombatTextures = {
    ["DEFAULT"] = "|TInterface\\CharacterFrame\\UI-StateIcon:20:20:0:0:64:64:32:64:0:31|t",
    ["COMBAT0"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat0.tga:18:18|t",
    ["COMBAT1"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat1.tga:18:18|t",
    ["COMBAT2"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat2.tga:18:18|t",
    ["COMBAT3"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat3.tga:18:18|t",
    ["COMBAT4"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat4.tga:18:18|t",
    ["COMBAT5"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat5.tga:18:18|t",
    ["COMBAT6"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat6.tga:18:18|t",
    ["COMBAT7"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat7.tga:18:18|t",
}

local RestingTextures = {
    ["DEFAULT"] = "|TInterface\\CharacterFrame\\UI-StateIcon:18:18:0:0:64:64:0:32:0:27|t",
    ["RESTING0"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting0.tga:18:18|t",
    ["RESTING1"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting1.tga:18:18|t",
    ["RESTING2"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting2.tga:18:18|t",
    ["RESTING3"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting3.tga:18:18|t",
    ["RESTING4"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting4.tga:18:18|t",
    ["RESTING5"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting5.tga:18:18|t",
    ["RESTING6"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting6.tga:18:18|t",
    ["RESTING7"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting7.tga:18:18|t",
}

local function CreateInfoTag(Description)
    local InfoDesc = AG:Create("Label")
    InfoDesc:SetText(UUF.InfoButton .. Description)
    InfoDesc:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    InfoDesc:SetFullWidth(true)
    InfoDesc:SetJustifyH("CENTER")
    InfoDesc:SetHeight(24)
    InfoDesc:SetJustifyV("MIDDLE")
    return InfoDesc
end

local function CreateScrollFrame(containerParent)
    local scrollFrame = AG:Create("ScrollFrame")
    scrollFrame:SetLayout("Flow")
    scrollFrame:SetFullWidth(true)
    containerParent:AddChild(scrollFrame)
    return scrollFrame
end

local function CreateInlineGroup(containerParent, containerTitle)
    local inlineGroup = AG:Create("InlineGroup")
    inlineGroup:SetTitle("|cFFFFFFFF" .. containerTitle .. "|r")
    inlineGroup:SetFullWidth(true)
    inlineGroup:SetLayout("Flow")
    containerParent:AddChild(inlineGroup)
    return inlineGroup
end

local function DeepDisable(widget, disabled, skipWidget)
    if widget == skipWidget then return end
    if widget.SetDisabled then widget:SetDisabled(disabled) end
    if widget.children then
        for _, child in ipairs(widget.children) do
            DeepDisable(child, disabled, skipWidget)
        end
    end
end

function UUF:CreateGUI()
    if OpenedGUI then return end
    if InCombatLockdown() then return end

    OpenedGUI = true
    GUIFrame = AG:Create("Frame")
    GUIFrame:SetTitle(UUF.AddOnName)
    GUIFrame:SetLayout("Fill")
    GUIFrame:SetWidth(900)
    GUIFrame:SetHeight(550)
    GUIFrame:EnableResize(false)
    GUIFrame:SetCallback("OnClose", function(widget) AG:Release(widget) OpenedGUI = false end)

    local function DrawGeneralSettings(Container)
        local ScrollFrame = CreateScrollFrame(Container)
        --------------------------------------------------------------
        --- UI Scale
        --------------------------------------------------------------
        local UIScaleContainer = CreateInlineGroup(ScrollFrame, "UI Scale")
        local UIScaleInfo = CreateInfoTag("This can force the UI Scale to be lower than |cFF08B6FFBlizzard|r intends which can cause some |cFFFFCC00unexpected effects|r.\nIf you experience issues, please |cFFFF4040disable|r the feature.")
        UIScaleInfo:SetRelativeWidth(1)
        UIScaleContainer:AddChild(UIScaleInfo)

        local EnableUIScaleCheckBox = AG:Create("CheckBox")
        EnableUIScaleCheckBox:SetLabel("Enable UI Scale")
        EnableUIScaleCheckBox:SetValue(UUF.db.profile.General.AllowUIScaling)
        EnableUIScaleCheckBox:SetRelativeWidth(0.5)
        EnableUIScaleCheckBox:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.General.AllowUIScaling = value end)
        UIScaleContainer:AddChild(EnableUIScaleCheckBox)

        local UIScaleSlider = AG:Create("Slider")
        UIScaleSlider:SetLabel("UI Scale")
        UIScaleSlider:SetValue(UUF.db.profile.General.UIScale)
        UIScaleSlider:SetRelativeWidth(0.5)
        UIScaleSlider:SetSliderValues(0.1, 1.0, 0.1)
        UIScaleSlider:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.General.UIScale = value; UUF:SetUIScale() end)
        UIScaleContainer:AddChild(UIScaleSlider)

        local PixelPerfectButton = AG:Create("Button")
        PixelPerfectButton:SetText("Apply Pixel Perfect Scaling")
        PixelPerfectButton:SetRelativeWidth(0.33)
        PixelPerfectButton:SetCallback("OnClick", function() UUF.db.profile.General.UIScale = UUF:GetPixelPerfectScale() UUF:SetUIScale() UIScaleSlider:SetValue(UUF.db.profile.General.UIScale) end)
        PixelPerfectButton:SetCallback("OnEnter", function() GameTooltip:SetOwner(PixelPerfectButton.frame, "ANCHOR_CURSOR") GameTooltip:AddLine("|cFF8080FFUI Scale Detected|r: " .. string.format("%.2f", UUF:GetPixelPerfectScale()), 1, 1, 1) GameTooltip:Show() end)
        PixelPerfectButton:SetCallback("OnLeave", function() GameTooltip:Hide() end)
        UIScaleContainer:AddChild(PixelPerfectButton)

        local Apply1080PScale = AG:Create("Button")
        Apply1080PScale:SetText("Apply 1080p Scaling")
        Apply1080PScale:SetRelativeWidth(0.33)
        Apply1080PScale:SetCallback("OnClick", function() UUF.db.profile.General.UIScale = 0.7111111111111 UUF:SetUIScale() UIScaleSlider:SetValue(UUF.db.profile.General.UIScale) end)
        UIScaleContainer:AddChild(Apply1080PScale)

        local Apply1440PScale = AG:Create("Button")
        Apply1440PScale:SetText("Apply 1440p Scaling")
        Apply1440PScale:SetRelativeWidth(0.33)
        Apply1440PScale:SetCallback("OnClick", function() UUF.db.profile.General.UIScale = 0.5333333333333 UUF:SetUIScale() UIScaleSlider:SetValue(UUF.db.profile.General.UIScale) end)
        UIScaleContainer:AddChild(Apply1440PScale)

        DeepDisable(UIScaleContainer, not UUF.db.profile.General.AllowUIScaling, EnableUIScaleCheckBox)

        --------------------------------------------------------------
        --- Fonts
        --------------------------------------------------------------
        local FontsContainer = CreateInlineGroup(ScrollFrame, "Fonts")

        local FontDropdownInfo = CreateInfoTag("|cFF8080FFFonts|r can be added via |cFFFFCC00Shared Media|r.")
        FontDropdownInfo:SetRelativeWidth(1)
        FontsContainer:AddChild(FontDropdownInfo)

        local FontDropdown = AG:Create("LSM30_Font")
        FontDropdown:SetList(LSM:HashTable("font"))
        FontDropdown:SetLabel("Font")
        FontDropdown:SetValue(UUF.db.profile.General.Font)
        FontDropdown:SetRelativeWidth(0.5)
        FontDropdown:SetCallback("OnValueChanged", function(widget, _, value) widget:SetValue(value) UUF.db.profile.General.Font = value UUF:ResolveMedia() for unit in pairs(UnitToFrameName) do UUF:UpdateUnitFrame(unit) end end)
        FontsContainer:AddChild(FontDropdown)

        local FontFlagsDropdown = AG:Create("Dropdown")
        FontFlagsDropdown:SetList({ ["OUTLINE"] = "Outline", ["THICKOUTLINE"] = "Thick Outline", ["MONOCHROME"] = "Monochrome", ["NONE"] = "None", })
        FontFlagsDropdown:SetLabel("Font Flags")
        FontFlagsDropdown:SetValue(UUF.db.profile.General.FontFlag)
        FontFlagsDropdown:SetRelativeWidth(0.5)
        FontFlagsDropdown:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.General.FontFlag = value for unit in pairs(UnitToFrameName) do UUF:UpdateUnitFrame(unit) end end)
        FontsContainer:AddChild(FontFlagsDropdown)

        local FontShadowsContainer = CreateInlineGroup(FontsContainer, "Font Shadows")

        local FontShadowXOffsetSlider = AG:Create("Slider")
        FontShadowXOffsetSlider:SetLabel("X Offset")
        FontShadowXOffsetSlider:SetValue(UUF.db.profile.General.FontShadows.OffsetX)
        FontShadowXOffsetSlider:SetSliderValues(-10, 10, 1)
        FontShadowXOffsetSlider:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.General.FontShadows.OffsetX = value for unit in pairs(UnitToFrameName) do UUF:UpdateUnitFrame(unit) end end)
        FontShadowsContainer:AddChild(FontShadowXOffsetSlider)

        local FontShadowYOffsetSlider = AG:Create("Slider")
        FontShadowYOffsetSlider:SetLabel("Y Offset")
        FontShadowYOffsetSlider:SetValue(UUF.db.profile.General.FontShadows.OffsetY)
        FontShadowYOffsetSlider:SetSliderValues(-10, 10, 1)
        FontShadowYOffsetSlider:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.General.FontShadows.OffsetY = value for unit in pairs(UnitToFrameName) do UUF:UpdateUnitFrame(unit) end end)
        FontShadowsContainer:AddChild(FontShadowYOffsetSlider)

        local FontShadowColourPicker = AG:Create("ColorPicker")
        FontShadowColourPicker:SetLabel("Shadow Colour")
        FontShadowColourPicker:SetColor(unpack(UUF.db.profile.General.FontShadows.Colour))
        FontShadowColourPicker:SetHasAlpha(true)
        FontShadowColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) UUF.db.profile.General.FontShadows.Colour = {r, g, b, a} for unit in pairs(UnitToFrameName) do UUF:UpdateUnitFrame(unit) end end)
        FontShadowsContainer:AddChild(FontShadowColourPicker)
        --------------------------------------------------------------
        --- Textures & Colours
        --------------------------------------------------------------
        local TexturesColourContainer = CreateInlineGroup(ScrollFrame, "Textures & Colours")

        local TexturesColoursInfo = CreateInfoTag("|cFF8080FFTextures|r and |cFF8080FFColours|r set here will be applied |cFFFFCC00GLOBALLY|r!")
        TexturesColoursInfo:SetRelativeWidth(1)
        TexturesColourContainer:AddChild(TexturesColoursInfo)

        local TexturesContainer = CreateInlineGroup(TexturesColourContainer, "Textures")

        local TexturesInfo = CreateInfoTag("|cFF8080FFTextures|r can be added via |cFFFFCC00Shared Media|r.")
        TexturesInfo:SetRelativeWidth(1)
        TexturesContainer:AddChild(TexturesInfo)

        local ForegroundTextureDropdown = AG:Create("LSM30_Statusbar")
        ForegroundTextureDropdown:SetList(LSM:HashTable("statusbar"))
        ForegroundTextureDropdown:SetLabel("Foreground Texture")
        ForegroundTextureDropdown:SetValue(UUF.db.profile.General.ForegroundTexture)
        ForegroundTextureDropdown:SetRelativeWidth(0.5)
        ForegroundTextureDropdown:SetCallback("OnValueChanged", function(widget, _, value) widget:SetValue(value) UUF.db.profile.General.ForegroundTexture = value UUF:ResolveMedia() for unit in pairs(UnitToFrameName) do UUF:UpdateUnitFrame(unit) end end)
        TexturesContainer:AddChild(ForegroundTextureDropdown)

        local BackgroundTextureDropdown = AG:Create("LSM30_Statusbar")
        BackgroundTextureDropdown:SetList(LSM:HashTable("statusbar"))
        BackgroundTextureDropdown:SetLabel("Background Texture")
        BackgroundTextureDropdown:SetValue(UUF.db.profile.General.BackgroundTexture)
        BackgroundTextureDropdown:SetRelativeWidth(0.5)
        BackgroundTextureDropdown:SetCallback("OnValueChanged", function(widget, _, value) widget:SetValue(value) UUF.db.profile.General.BackgroundTexture = value UUF:ResolveMedia() for unit in pairs(UnitToFrameName) do UUF:UpdateUnitFrame(unit) end end)
        TexturesContainer:AddChild(BackgroundTextureDropdown)

        local ColoursContainer = CreateInlineGroup(TexturesColourContainer, "Colours")

        local ColoursInfo = CreateInfoTag("|cFF8080FFButtons|r will allow you to swap between |cFFFFCC00Class / Reaction Mode|r and |cFFFFCC00Dark Mode|r.")
        ColoursInfo:SetRelativeWidth(1)
        ColoursContainer:AddChild(ColoursInfo)

        local ColouredModeButton = AG:Create("Button")
        ColouredModeButton:SetText("Class / Reaction Mode")
        ColouredModeButton:SetRelativeWidth(0.5)
        ColouredModeButton:SetCallback("OnClick", function() for unit in pairs(UnitToFrameName) do UUF.db.profile[unit].Frame.ClassColour = true UUF.db.profile[unit].Frame.ReactionColour = true UUF.db.profile[unit].Frame.BGColour = {26/255, 26/255, 26/255, 1} UUF:UpdateUnitFrame(unit) end end)
        ColoursContainer:AddChild(ColouredModeButton)

        local DarkModeButton = AG:Create("Button")
        DarkModeButton:SetText("Dark Mode")
        DarkModeButton:SetRelativeWidth(0.5)
        DarkModeButton:SetCallback("OnClick", function() for unit in pairs(UnitToFrameName) do UUF.db.profile[unit].Frame.ClassColour = false UUF.db.profile[unit].Frame.ReactionColour = false UUF.db.profile[unit].Frame.BGColour = {128/255, 128/255, 128/255, 1} UUF:UpdateUnitFrame(unit) end end)
        ColoursContainer:AddChild(DarkModeButton)

        local FGColourPicker = AG:Create("ColorPicker")
        FGColourPicker:SetLabel("Foreground Colour (Global)")
        FGColourPicker:SetColor(26/255, 26/255, 26/255, 1)
        FGColourPicker:SetHasAlpha(true)
        FGColourPicker:SetRelativeWidth(0.5)
        FGColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) for unit in pairs(UnitToFrameName) do UUF.db.profile[unit].Frame.FGColour = {r, g, b, a} UUF:UpdateUnitFrame(unit) end end)
        TexturesContainer:AddChild(FGColourPicker)

        local BGColourPicker = AG:Create("ColorPicker")
        BGColourPicker:SetLabel("Background Colour (Global)")
        BGColourPicker:SetColor(128/255, 128/255, 128/255, 1)
        BGColourPicker:SetHasAlpha(true)
        BGColourPicker:SetRelativeWidth(0.5)
        BGColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) for unit in pairs(UnitToFrameName) do UUF.db.profile[unit].Frame.BGColour = {r, g, b, a} UUF:UpdateUnitFrame(unit) end end)
        TexturesContainer:AddChild(BGColourPicker)

        --------------------------------------------------------------
        --- Custom Colours
        --------------------------------------------------------------
        local CustomColoursContainer = CreateInlineGroup(ScrollFrame, "Custom Colours")

        local PowerColours = CreateInlineGroup(CustomColoursContainer, "Power")
        local PowerOrder = {0, 1, 2, 3, 6, 8, 11, 13, 17, 18}
        for _, powerType in ipairs(PowerOrder) do
            local powerColour = UUF.db.profile.General.CustomColours.Power[powerType]
            local PowerColour = AG:Create("ColorPicker")
            PowerColour:SetLabel(PowerNames[powerType])
            local R, G, B = unpack(powerColour)
            PowerColour:SetColor(R, G, B)
            PowerColour:SetCallback("OnValueChanged", function(widget, _, r, g, b) UUF.db.profile.General.CustomColours.Power[powerType] = {r, g, b} for unit in pairs(UnitToFrameName) do UUF:UpdateUnitFrame(unit) end end)
            PowerColour:SetHasAlpha(false)
            PowerColour:SetRelativeWidth(0.25)
            PowerColours:AddChild(PowerColour)
        end

        local ReactionColours = CreateInlineGroup(CustomColoursContainer, "Reaction")
        for reactionType, reactionColour in pairs(UUF.db.profile.General.CustomColours.Reaction) do
            local ReactionColour = AG:Create("ColorPicker")
            ReactionColour:SetLabel(ReactionNames[reactionType])
            local R, G, B = unpack(reactionColour)
            ReactionColour:SetColor(R, G, B)
            ReactionColour:SetCallback("OnValueChanged", function(widget, _, r, g, b) UUF.db.profile.General.CustomColours.Reaction[reactionType] = {r, g, b} for unit in pairs(UnitToFrameName) do UUF:UpdateUnitFrame(unit) end end)
            ReactionColour:SetHasAlpha(false)
            ReactionColour:SetRelativeWidth(0.25)
            ReactionColours:AddChild(ReactionColour)
        end
        ScrollFrame:DoLayout()
    end

    local function DrawProfileSettings(GUIContainer)
        local profileKeys = {}

        local ScrollFrame = CreateScrollFrame(GUIContainer)

        local ProfileContainer = CreateInlineGroup(ScrollFrame, "Profile Management")

        local ActiveProfileHeading = AG:Create("Heading")
        ActiveProfileHeading:SetFullWidth(true)
        ProfileContainer:AddChild(ActiveProfileHeading)

        local function RefreshProfiles()
            wipe(profileKeys)
            local tmp = {}
            for _, name in ipairs(UUF.db:GetProfiles(tmp, true)) do profileKeys[name] = name end
            SelectProfileDropdown:SetList(profileKeys)
            CopyFromProfileDropdown:SetList(profileKeys)
            DeleteProfileDropdown:SetList(profileKeys)
            SelectProfileDropdown:SetValue(UUF.db:GetCurrentProfile())
            CopyFromProfileDropdown:SetValue(nil)
            DeleteProfileDropdown:SetValue(nil)
            local isUsingGlobal = UUF.db.global.UseGlobalProfile
            ActiveProfileHeading:SetText( "Active Profile: |cFFFFFFFF" .. UUF.db:GetCurrentProfile() .. (isUsingGlobal and " (|cFFFFCC00Global|r)" or "") .. "|r" )
        end

        UUFG.RefreshProfiles = RefreshProfiles -- Exposed for Share.lua

        SelectProfileDropdown = AG:Create("Dropdown")
        SelectProfileDropdown:SetLabel("Select...")
        SelectProfileDropdown:SetRelativeWidth(0.25)
        SelectProfileDropdown:SetCallback("OnValueChanged", function(_, _, value) UUF.db:SetProfile(value) UIParent:SetScale(UUF.db.profile.General.UIScale or 1) for unit in pairs(UnitToFrameName) do UUF:UpdateUnitFrame(unit) end RefreshProfiles() end)
        ProfileContainer:AddChild(SelectProfileDropdown)

        CopyFromProfileDropdown = AG:Create("Dropdown")
        CopyFromProfileDropdown:SetLabel("Copy From...")
        CopyFromProfileDropdown:SetRelativeWidth(0.25)
        CopyFromProfileDropdown:SetCallback("OnValueChanged", function(_, _, value) UUF:CreatePrompt("Copy Profile", "Are you sure you want to copy from |cFF8080FF" .. value .. "|r?\nThis will |cFFFF4040overwrite|r your current profile settings.", function() UUF.db:CopyProfile(value) UIParent:SetScale(UUF.db.profile.General.UIScale or 1) for unit in pairs(UnitToFrameName) do UUF:UpdateUnitFrame(unit) end RefreshProfiles() end) end)
        ProfileContainer:AddChild(CopyFromProfileDropdown)

        DeleteProfileDropdown = AG:Create("Dropdown")
        DeleteProfileDropdown:SetLabel("Delete...")
        DeleteProfileDropdown:SetRelativeWidth(0.25)
        DeleteProfileDropdown:SetCallback("OnValueChanged", function(_, _, value) if value ~= UUF.db:GetCurrentProfile() then UUF:CreatePrompt("Delete Profile", "Are you sure you want to delete |cFF8080FF" .. value .. "|r?", function() UUF.db:DeleteProfile(value) RefreshProfiles() end) end end)
        ProfileContainer:AddChild(DeleteProfileDropdown)

        local ResetProfileButton = AG:Create("Button")
        ResetProfileButton:SetText("Reset |cFF8080FF" .. UUF.db:GetCurrentProfile() .. "|r Profile")
        ResetProfileButton:SetRelativeWidth(0.25)
        ResetProfileButton:SetCallback("OnClick", function() UUF.db:ResetProfile() UUF:ResolveMedia() for unit in pairs(UnitToFrameName) do UUF:UpdateUnitFrame(unit) end UIParent:SetScale(UUF.db.profile.General.UIScale or 1) RefreshProfiles() end)
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
        CreateProfileButton:SetCallback("OnClick", function() local profileName = strtrim(CreateProfileEditBox:GetText() or "") if profileName ~= "" then UUF.db:SetProfile(profileName) UIParent:SetScale(UUF.db.profile.General.UIScale or 1) for unit in pairs(UnitToFrameName) do UUF:FullFrameUpdate(unit) end RefreshProfiles() CreateProfileEditBox:SetText("") end end)
        ProfileContainer:AddChild(CreateProfileButton)

        local GlobalProfileHeading = AG:Create("Heading")
        GlobalProfileHeading:SetText("Global Profile Settings")
        GlobalProfileHeading:SetFullWidth(true)
        ProfileContainer:AddChild(GlobalProfileHeading)

        local GlobalProfileInfoTag = CreateInfoTag("If |cFF8080FFUse Global Profile Settings|r is enabled, the profile selected below will be used as your active profile.\nThis is useful if you want to use the same profile across multiple characters.")
        GlobalProfileInfoTag:SetFullWidth(true)
        ProfileContainer:AddChild(GlobalProfileInfoTag)

        UseGlobalProfileToggle = AG:Create("CheckBox")
        UseGlobalProfileToggle:SetLabel("Use Global Profile Settings")
        UseGlobalProfileToggle:SetValue(UUF.db.global.UseGlobalProfile)
        UseGlobalProfileToggle:SetRelativeWidth(0.5)
        UseGlobalProfileToggle:SetCallback("OnValueChanged", function(_, _, value) UUF.db.global.UseGlobalProfile = value if value and UUF.db.global.GlobalProfile and UUF.db.global.GlobalProfile ~= "" then UUF.db:SetProfile(UUF.db.global.GlobalProfile) UIParent:SetScale(UUF.db.profile.General.UIScale or 1) for unit in pairs(UnitToFrameName) do UUF:FullFrameUpdate(unit) end end GlobalProfileDropdown:SetDisabled(not value) for _, child in ipairs(ProfileContainer.children) do if child ~= UseGlobalProfileToggle and child ~= GlobalProfileDropdown then DeepDisable(child, value) end end RefreshProfiles() end)
        ProfileContainer:AddChild(UseGlobalProfileToggle)

        RefreshProfiles()

        GlobalProfileDropdown = AG:Create("Dropdown")
        GlobalProfileDropdown:SetLabel("Global Profile...")
        GlobalProfileDropdown:SetRelativeWidth(0.5)
        GlobalProfileDropdown:SetList(profileKeys)
        GlobalProfileDropdown:SetValue(UUF.db.global.GlobalProfile)
        GlobalProfileDropdown:SetCallback("OnValueChanged", function(_, _, value) UUF.db:SetProfile(value) UUF.db.global.GlobalProfile = value UIParent:SetScale(UUF.db.profile.General.UIScale or 1) for unit in pairs(UnitToFrameName) do UUF:UpdateUnitFrame(unit) end RefreshProfiles() end)
        ProfileContainer:AddChild(GlobalProfileDropdown)

        local SharingContainer = CreateInlineGroup(ScrollFrame, "Profile Sharing")

        local ExportingHeading = AG:Create("Heading")
        ExportingHeading:SetText("Exporting")
        ExportingHeading:SetFullWidth(true)
        SharingContainer:AddChild(ExportingHeading)

        local ExportingImportingDesc = CreateInfoTag("You can export your profile by pressing |cFF8080FFExport Profile|r button below & share the string with other |cFF8080FFUnhalted|r Unit Frame users.")
        SharingContainer:AddChild(ExportingImportingDesc)

        local ExportingEditBox = AG:Create("EditBox")
        ExportingEditBox:SetLabel("Export String...")
        ExportingEditBox:SetText("")
        ExportingEditBox:SetFullWidth(true)
        ExportingEditBox:DisableButton(true)
        ExportingEditBox:SetCallback("OnEnterPressed", function() ExportingEditBox:ClearFocus() end)
        SharingContainer:AddChild(ExportingEditBox)

        local ExportProfileButton = AG:Create("Button")
        ExportProfileButton:SetText("Export Profile")
        ExportProfileButton:SetFullWidth(true)
        ExportProfileButton:SetCallback("OnClick", function() ExportingEditBox:SetText(UUF:ExportSavedVariables()) ExportingEditBox:HighlightText() ExportingEditBox:SetFocus() end)
        SharingContainer:AddChild(ExportProfileButton)

        local ImportingHeading = AG:Create("Heading")
        ImportingHeading:SetText("Importing")
        ImportingHeading:SetFullWidth(true)
        SharingContainer:AddChild(ImportingHeading)

        local ImportingDesc = CreateInfoTag("If you have an exported string, paste it in the |cFF8080FFImport String|r box below & press |cFF8080FFImport Profile|r.")
        SharingContainer:AddChild(ImportingDesc)

        local ImportingEditBox = AG:Create("EditBox")
        ImportingEditBox:SetLabel("Import String...")
        ImportingEditBox:SetText("")
        ImportingEditBox:SetFullWidth(true)
        ImportingEditBox:DisableButton(true)
        ImportingEditBox:SetCallback("OnEnterPressed", function() ImportingEditBox:ClearFocus() end)
        SharingContainer:AddChild(ImportingEditBox)

        local ImportProfileButton = AG:Create("Button")
        ImportProfileButton:SetText("Import Profile")
        ImportProfileButton:SetFullWidth(true)
        ImportProfileButton:SetCallback("OnClick", function() if ImportingEditBox:GetText() ~= "" then UUF:ImportSavedVariables(ImportingEditBox:GetText()) ImportingEditBox:SetText("") end end)
        SharingContainer:AddChild(ImportProfileButton)
        GlobalProfileDropdown:SetDisabled(not UUF.db.global.UseGlobalProfile)
        if UUF.db.global.UseGlobalProfile then for _, child in ipairs(ProfileContainer.children) do if child ~= UseGlobalProfileToggle and child ~= GlobalProfileDropdown then DeepDisable(child, true) end end end

        ScrollFrame:DoLayout()
    end

    local function SelectedGroup(GUIContainer, _, MainGroup)
        GUIContainer:ReleaseChildren()
        if MainGroup == "General" then
            DrawGeneralSettings(GUIContainer)
        elseif MainGroup == "player" then
        elseif MainGroup == "target" then
        elseif MainGroup == "targettarget" then
        elseif MainGroup == "pet" then
        elseif MainGroup == "focus" then
        elseif MainGroup == "boss" then
        elseif MainGroup == "Tags" then
            DrawTagsContainer(GUIContainer)
        elseif MainGroup == "Profiles" then
            DrawProfileSettings(GUIContainer)
        end
    end

    local GUIContainerTabGroup = AG:Create("TabGroup")
    GUIContainerTabGroup:SetLayout("Flow")
    GUIContainerTabGroup:SetTabs({
        { text = "General", value = "General"},
        { text = "Player", value = "player"},
        { text = "Target", value = "target"},
        { text = "Target of Target", value = "targettarget"},
        { text = "Pet", value = "pet"},
        { text = "Focus", value = "focus"},
        { text = "Boss", value = "boss"},
        { text = "Tags", value = "Tags"},
        { text = "Profiles", value = "Profiles"},
    })
    GUIContainerTabGroup:SetCallback("OnGroupSelected", SelectedGroup)
    GUIContainerTabGroup:SelectTab("General")
    GUIFrame:AddChild(GUIContainerTabGroup)
end