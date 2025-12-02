local _, UUF = ...
local AG = LibStub("AceGUI-3.0")
local GUIFrame;
local OpenedGUI = false
local LSM = UUF.LSM
local UnitToFrameName = UUF.UnitToFrameName
local UUFGUI = {}

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

local ClassificationNames = {
    ["worldboss"] = "World Boss",
    ["rareelite"] = "Rare Elite",
    ["elite"] = "Elite",
    ["rare"] = "Rare",
    ["normal"] = "Normal",
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

local HealthTagLayouts = {
    {
        [""] = "999K 100%",
        ["•"] = "999K • 100%",
        ["-"] = "999K- 100%",
        ["||"] = "999K | 100%",
        ["/"] = "999K / 100%",
        ["»"] = "999K » 100%",
        ["()"] = "999K (100%)",
        ["[]"] = "999K [100%]"
    },
    {
        "",
        "•",
        "-",
        "||",
        "/",
        "»",
        "()",
        "[]"
    }
}

local function GetNormalizedUnit(unit)
    local normalizedUnit = unit:match("^boss%d+$") and "boss" or unit
    return normalizedUnit
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

local function CreateUnitFrameFrameSettings(containerParent, unit)
    local UUFDB = UUF.db.profile
    local GeneralDB = UUFDB.General
    local normalizedUnit = GetNormalizedUnit(unit)
    local FrameDB = UUFDB[normalizedUnit].Frame
    local isPlayerorTarget = (unit == "player" or unit == "target")
    local isBoss = (unit == "boss")

    local TogglesContainer = CreateInlineGroup(containerParent, "Toggles")

    local EnableUnitFrame = AG:Create("CheckBox")
    EnableUnitFrame:SetLabel("Enable")
    EnableUnitFrame:SetValue(UUFDB[normalizedUnit].Enabled)
    EnableUnitFrame:SetRelativeWidth(isPlayerorTarget and 0.25 or 0.33)
    EnableUnitFrame:SetCallback("OnValueChanged", function(_, _, value) UUFDB[normalizedUnit].Enabled = value if unit == "boss" then UUF:UpdateAllBossFrames() else if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end DeepDisable(containerParent, not value, EnableUnitFrame) end)
    TogglesContainer:AddChild(EnableUnitFrame)

    local ClassColourCheckBox = AG:Create("CheckBox")
    ClassColourCheckBox:SetLabel("Class Colour")
    ClassColourCheckBox:SetValue(FrameDB.ClassColour)
    ClassColourCheckBox:SetRelativeWidth(isPlayerorTarget and 0.25 or 0.33)
    ClassColourCheckBox:SetCallback("OnValueChanged", function(_, _, value) FrameDB.ClassColour = value if unit == "boss" then UUF:UpdateAllBossFrames() else if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end  end)
    TogglesContainer:AddChild(ClassColourCheckBox)

    local ReactionColourCheckBox = AG:Create("CheckBox")
    ReactionColourCheckBox:SetLabel("Reaction Colour")
    ReactionColourCheckBox:SetValue(FrameDB.ReactionColour)
    ReactionColourCheckBox:SetRelativeWidth(isPlayerorTarget and 0.25 or 0.33)
    ReactionColourCheckBox:SetCallback("OnValueChanged", function(_, _, value) FrameDB.ReactionColour = value if unit == "boss" then UUF:UpdateAllBossFrames() else if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end  end)
    TogglesContainer:AddChild(ReactionColourCheckBox)

    if isPlayerorTarget then
        local AnchorToEssentialCooldownsCheckBox = AG:Create("CheckBox")
        AnchorToEssentialCooldownsCheckBox:SetLabel("Anchor To Essential Cooldowns")
        AnchorToEssentialCooldownsCheckBox:SetValue(FrameDB.AnchorToEssentialCooldowns)
        AnchorToEssentialCooldownsCheckBox:SetRelativeWidth(0.25)
        AnchorToEssentialCooldownsCheckBox:SetCallback("OnValueChanged", function(_, _, value) FrameDB.AnchorToEssentialCooldowns = value if unit == "boss" then UUF:UpdateAllBossFrames() else if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end  end)
        AnchorToEssentialCooldownsCheckBox:SetCallback("OnEnter", function() GameTooltip:SetOwner(AnchorToEssentialCooldownsCheckBox.frame, "ANCHOR_CURSOR") GameTooltip:AddLine("|cFF8080FFPositions|r / |cFF8080FFAnchors|r can be used to fine tune position", 1, 1, 1) GameTooltip:Show() end)
        AnchorToEssentialCooldownsCheckBox:SetCallback("OnLeave", function() GameTooltip:Hide() end)
        AnchorToEssentialCooldownsCheckBox:SetDisabled(not UUF:IsCDMAnchorActive())
        TogglesContainer:AddChild(AnchorToEssentialCooldownsCheckBox)
    end

    local ColoursContainer = CreateInlineGroup(containerParent, "Colours")
    local FGColourPicker = AG:Create("ColorPicker")
    FGColourPicker:SetLabel("Foreground Colour")
    FGColourPicker:SetColor(unpack(FrameDB.FGColour))
    FGColourPicker:SetHasAlpha(true)
    FGColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) FrameDB.FGColour = {r, g, b, a} if unit == "boss" then UUF:UpdateAllBossFrames() else if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end  end)
    ColoursContainer:AddChild(FGColourPicker)

    local BGColourPicker = AG:Create("ColorPicker")
    BGColourPicker:SetLabel("Background Colour")
    BGColourPicker:SetColor(unpack(FrameDB.BGColour))
    BGColourPicker:SetHasAlpha(true)
    BGColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) FrameDB.BGColour = {r, g, b, a} if unit == "boss" then UUF:UpdateAllBossFrames() else if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end  end)
    ColoursContainer:AddChild(BGColourPicker)

    local FrameContainer = CreateInlineGroup(containerParent, "Frame Settings")

    local hasParent = (FrameDB.AnchorParent and FrameDB.ParentFrame ~= "")

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetValue(FrameDB.AnchorFrom)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) FrameDB.AnchorFrom = value if unit == "boss" then UUF:UpdateAllBossFrames() else if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end  end)
    AnchorFromDropdown:SetRelativeWidth((hasParent or isBoss) and 0.33 or 0.5)
    FrameContainer:AddChild(AnchorFromDropdown)

    if hasParent then
        local ParentFrameEditBox = AG:Create("EditBox")
        ParentFrameEditBox:SetLabel("Parent Frame")
        ParentFrameEditBox:SetText(FrameDB.AnchorParent)
        ParentFrameEditBox:SetCallback("OnEnterPressed", function(_, _, value) if UUF:FrameIsValid(unit, value) then FrameDB.AnchorParent = value if unit == "boss" then UUF:UpdateAllBossFrames() else if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end  else ParentFrameEditBox:SetText(FrameDB.AnchorParent) end end)
        ParentFrameEditBox:SetRelativeWidth(0.33)
        FrameContainer:AddChild(ParentFrameEditBox)
    end

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetValue(FrameDB.AnchorTo)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) FrameDB.AnchorTo = value if unit == "boss" then UUF:UpdateAllBossFrames() else if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end  end)
    AnchorToDropdown:SetRelativeWidth((hasParent or isBoss) and 0.33 or 0.5)
    FrameContainer:AddChild(AnchorToDropdown)

    if isBoss then
        local GrowthDirectionDropdown = AG:Create("Dropdown")
        GrowthDirectionDropdown:SetLabel("Growth Direction")
        GrowthDirectionDropdown:SetList({ ["UP"] = "Up", ["DOWN"] = "Down", })
        GrowthDirectionDropdown:SetValue(FrameDB.GrowthDirection)
        GrowthDirectionDropdown:SetCallback("OnValueChanged", function(_, _, value) FrameDB.GrowthDirection = value if unit == "boss" then UUF:UpdateAllBossFrames() else if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end  UUF:LayoutBossFrames() end)
        GrowthDirectionDropdown:SetRelativeWidth(0.33)
        FrameContainer:AddChild(GrowthDirectionDropdown)
    end

    local WidthSlider = AG:Create("Slider")
    WidthSlider:SetLabel("Width")
    WidthSlider:SetValue(FrameDB.Width)
    WidthSlider:SetSliderValues(1, 3000, 0.1)
    WidthSlider:SetCallback("OnValueChanged", function(_, _, value) FrameDB.Width = value if unit == "boss" then UUF:UpdateAllBossFrames() else if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end  end)
    WidthSlider:SetRelativeWidth(0.5)
    FrameContainer:AddChild(WidthSlider)

    local HeightSlider = AG:Create("Slider")
    HeightSlider:SetLabel("Height")
    HeightSlider:SetValue(FrameDB.Height)
    HeightSlider:SetSliderValues(1, 3000, 0.1)
    HeightSlider:SetCallback("OnValueChanged", function(_, _, value) FrameDB.Height = value if unit == "boss" then UUF:UpdateAllBossFrames() else if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end  end)
    HeightSlider:SetRelativeWidth(0.5)
    FrameContainer:AddChild(HeightSlider)

    local XPositionSlider = AG:Create("Slider")
    XPositionSlider:SetLabel("X Position")
    XPositionSlider:SetValue(FrameDB.XPosition)
    XPositionSlider:SetSliderValues(-3000, 3000, 0.1)
    XPositionSlider:SetCallback("OnValueChanged", function(_, _, value) FrameDB.XPosition = value if unit == "boss" then UUF:UpdateAllBossFrames() else if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end  end)
    XPositionSlider:SetRelativeWidth(isBoss and 0.33 or 0.5)
    FrameContainer:AddChild(XPositionSlider)

    local YPositionSlider = AG:Create("Slider")
    YPositionSlider:SetLabel("Y Position")
    YPositionSlider:SetValue(FrameDB.YPosition)
    YPositionSlider:SetSliderValues(-3000, 3000, 0.1)
    YPositionSlider:SetCallback("OnValueChanged", function(_, _, value) FrameDB.YPosition = value if unit == "boss" then UUF:UpdateAllBossFrames() else if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end  end)
    YPositionSlider:SetRelativeWidth(isBoss and 0.33 or 0.5)
    FrameContainer:AddChild(YPositionSlider)

    if isBoss then
        local SpacingSlider = AG:Create("Slider")
        SpacingSlider:SetLabel("Spacing")
        SpacingSlider:SetValue(FrameDB.Spacing)
        SpacingSlider:SetSliderValues(0, 500, 0.1)
        SpacingSlider:SetCallback("OnValueChanged", function(_, _, value) FrameDB.Spacing = value if unit == "boss" then UUF:UpdateAllBossFrames() else if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end  UUF:LayoutBossFrames() end)
        SpacingSlider:SetRelativeWidth(0.33)
        FrameContainer:AddChild(SpacingSlider)
    end

    DeepDisable(containerParent, not UUFDB[normalizedUnit].Enabled, EnableUnitFrame)

    return FrameContainer
end

local function CreateTagSettings(containerParent, unit, tagDB)
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local TagsDB = UUFDB[normalizedUnit].Tags

    local ColourPicker = AG:Create("ColorPicker")
    ColourPicker:SetLabel("Colour")
    ColourPicker:SetColor(unpack(TagsDB[tagDB].Colour))
    ColourPicker:SetHasAlpha(true)
    ColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) TagsDB[tagDB].Colour = {r, g, b, a} if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    ColourPicker:SetRelativeWidth(1)
    containerParent:AddChild(ColourPicker)

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetValue(TagsDB[tagDB].AnchorFrom)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) TagsDB[tagDB].AnchorFrom = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    AnchorFromDropdown:SetRelativeWidth(0.33)
    containerParent:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetValue(TagsDB[tagDB].AnchorTo)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) TagsDB[tagDB].AnchorTo = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    AnchorToDropdown:SetRelativeWidth(0.33)
    containerParent:AddChild(AnchorToDropdown)

    local TagEditBox = AG:Create("EditBox")
    TagEditBox:SetLabel("Tag")
    TagEditBox:SetText(TagsDB[tagDB].Tag)
    TagEditBox:SetCallback("OnEnterPressed", function(_, _, value) TagsDB[tagDB].Tag = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    TagEditBox:SetRelativeWidth(0.33)
    containerParent:AddChild(TagEditBox)

    local OffsetXSlider = AG:Create("Slider")
    OffsetXSlider:SetLabel("Offset X")
    OffsetXSlider:SetValue(TagsDB[tagDB].OffsetX)
    OffsetXSlider:SetSliderValues(-3000, 3000, 0.1)
    OffsetXSlider:SetCallback("OnValueChanged", function(_, _, value) TagsDB[tagDB].OffsetX = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    OffsetXSlider:SetRelativeWidth(0.33)
    containerParent:AddChild(OffsetXSlider)

    local OffsetYSlider = AG:Create("Slider")
    OffsetYSlider:SetLabel("Offset Y")
    OffsetYSlider:SetValue(TagsDB[tagDB].OffsetY)
    OffsetYSlider:SetSliderValues(-3000, 3000, 0.1)
    OffsetYSlider:SetCallback("OnValueChanged", function(_, _, value) TagsDB[tagDB].OffsetY = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    OffsetYSlider:SetRelativeWidth(0.33)
    containerParent:AddChild(OffsetYSlider)

    local FontSizeSlider = AG:Create("Slider")
    FontSizeSlider:SetLabel("Font Size")
    FontSizeSlider:SetValue(TagsDB[tagDB].FontSize)
    FontSizeSlider:SetSliderValues(1, 100, 1)
    FontSizeSlider:SetCallback("OnValueChanged", function(_, _, value) TagsDB[tagDB].FontSize = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    FontSizeSlider:SetRelativeWidth(0.33)
    containerParent:AddChild(FontSizeSlider)

    local TagSelectContainer = CreateInlineGroup(containerParent, "Select Tag")

    local HealthTagDropdown = AG:Create("Dropdown")
    HealthTagDropdown:SetLabel("Health Tag")
    HealthTagDropdown:SetList(UUF:GetTagsForGroup("Health")[1], UUF:GetTagsForGroup("Health")[2])
    HealthTagDropdown:SetValue(nil)
    HealthTagDropdown:SetCallback("OnValueChanged", function(_, _, value) TagsDB[tagDB].Tag = "[" .. value .. "]" if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  TagEditBox:SetText("[" .. value .. "]") HealthTagDropdown:SetValue(nil) end)
    HealthTagDropdown:SetRelativeWidth(0.5)
    TagSelectContainer:AddChild(HealthTagDropdown)

    local PowerTagDropdown = AG:Create("Dropdown")
    PowerTagDropdown:SetLabel("Power Tag")
    PowerTagDropdown:SetList(UUF:GetTagsForGroup("Power")[1], UUF:GetTagsForGroup("Power")[2])
    PowerTagDropdown:SetValue(nil)
    PowerTagDropdown:SetCallback("OnValueChanged", function(_, _, value) TagsDB[tagDB].Tag = "[" .. value .. "]" if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  TagEditBox:SetText("[" .. value .. "]") PowerTagDropdown:SetValue(nil) end)
    PowerTagDropdown:SetRelativeWidth(0.5)
    TagSelectContainer:AddChild(PowerTagDropdown)

    local NameTagDropdown = AG:Create("Dropdown")
    NameTagDropdown:SetLabel("Name Tag")
    NameTagDropdown:SetList(UUF:GetTagsForGroup("Name")[1], UUF:GetTagsForGroup("Name")[2])
    NameTagDropdown:SetValue(nil)
    NameTagDropdown:SetCallback("OnValueChanged", function(_, _, value) TagsDB[tagDB].Tag = "[" .. value .. "]" if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  TagEditBox:SetText("[" .. value .. "]") NameTagDropdown:SetValue(nil) end)
    NameTagDropdown:SetRelativeWidth(0.5)
    TagSelectContainer:AddChild(NameTagDropdown)

    local MiscTagDropdown = AG:Create("Dropdown")
    MiscTagDropdown:SetLabel("Misc Tag")
    MiscTagDropdown:SetList(UUF:GetTagsForGroup("Misc")[1], UUF:GetTagsForGroup("Misc")[2])
    MiscTagDropdown:SetValue(nil)
    MiscTagDropdown:SetCallback("OnValueChanged", function(_, _, value) TagsDB[tagDB].Tag = "[" .. value .. "]" if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  TagEditBox:SetText("[" .. value .. "]") MiscTagDropdown:SetValue(nil) end)
    MiscTagDropdown:SetRelativeWidth(0.5)
    TagSelectContainer:AddChild(MiscTagDropdown)

    return containerParent
end

local function CreateHealPredictionSettings(containerParent, unit)
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local HealPredictionDB = UUFDB[normalizedUnit].HealPrediction
    local AbsorbsDB = HealPredictionDB.Absorbs

    local AbsorbsContainer = CreateInlineGroup(containerParent, "Absorbs Settings")

    local EnableCheckBox = AG:Create("CheckBox")
    EnableCheckBox:SetLabel("Enable Absorbs")
    EnableCheckBox:SetValue(AbsorbsDB.Enabled)
    EnableCheckBox:SetRelativeWidth(0.33)
    EnableCheckBox:SetCallback("OnValueChanged", function(_, _, value) AbsorbsDB.Enabled = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  DeepDisable(AbsorbsContainer, not value, EnableCheckBox) end)
    AbsorbsContainer:AddChild(EnableCheckBox)

    local ColourPicker = AG:Create("ColorPicker")
    ColourPicker:SetLabel("Colour")
    ColourPicker:SetColor(unpack(AbsorbsDB.Colour))
    ColourPicker:SetHasAlpha(true)
    ColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) AbsorbsDB.Colour = {r, g, b, a} if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    ColourPicker:SetRelativeWidth(0.33)
    AbsorbsContainer:AddChild(ColourPicker)

    local GrowthDirectionDropdown = AG:Create("Dropdown")
    GrowthDirectionDropdown:SetLabel("Growth Direction")
    GrowthDirectionDropdown:SetList({ ["RIGHT"] = "Right", ["LEFT"] = "Left", })
    GrowthDirectionDropdown:SetValue(AbsorbsDB.GrowthDirection)
    GrowthDirectionDropdown:SetCallback("OnValueChanged", function(_, _, value) AbsorbsDB.GrowthDirection = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    GrowthDirectionDropdown:SetRelativeWidth(0.33)
    AbsorbsContainer:AddChild(GrowthDirectionDropdown)

    DeepDisable(AbsorbsContainer, not AbsorbsDB.Enabled, EnableCheckBox)

    return AbsorbsContainer
end

local function CreatePowerBarSettings(containerParent, unit)
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local PowerBarDB = UUFDB[normalizedUnit].PowerBar

    local Wrapper = AG:Create("SimpleGroup")
    Wrapper:SetFullWidth(true)
    Wrapper:SetFullHeight(true)
    Wrapper:SetLayout("Fill")
    containerParent:AddChild(Wrapper)

    local ScrollFrame = CreateScrollFrame(Wrapper)

    local BarContainer = CreateInlineGroup(ScrollFrame, "Bar")

    local TogglesContainer = CreateInlineGroup(BarContainer, "Toggles")

    local function GUIRefresh()
        if not PowerBarDB.Enabled then
            DeepDisable(BarContainer, true, UUFGUI.EnableCheckBox)
            DeepDisable(UUFGUI.TextContainer, true, UUFGUI.EnableTextCheckBox)
            ScrollFrame:DoLayout()
            return
        end
        DeepDisable(BarContainer, false, nil)

        if not PowerBarDB.Text.Enabled then
            DeepDisable(UUFGUI.TextContainer, true, UUFGUI.EnableTextCheckBox)
            ScrollFrame:DoLayout()
            return
        end

        DeepDisable(UUFGUI.TextContainer, false, nil)

        if PowerBarDB.ColourByType then
            TextColourPicker:SetDisabled(true)
        else
            TextColourPicker:SetDisabled(false)
        end

        ScrollFrame:DoLayout()
    end

    local EnableCheckBox = AG:Create("CheckBox")
    EnableCheckBox:SetLabel("Enable Power Bar")
    EnableCheckBox:SetValue(PowerBarDB.Enabled)
    EnableCheckBox:SetRelativeWidth(0.33)
    EnableCheckBox:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.Enabled = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  GUIRefresh() UUFGUI.EnableTextCheckBox:SetDisabled(not value) end)
    UUFGUI.EnableCheckBox = EnableCheckBox
    TogglesContainer:AddChild(EnableCheckBox)

    local ColourByType = AG:Create("CheckBox")
    ColourByType:SetLabel("Colour By Power Type")
    ColourByType:SetValue(PowerBarDB.ColourByType)
    ColourByType:SetRelativeWidth(0.33)
    ColourByType:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.ColourByType = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  UUFGUI.FGColourPicker:SetDisabled(value) end)
    TogglesContainer:AddChild(ColourByType)

    local ColourBackgroundByType = AG:Create("CheckBox")
    ColourBackgroundByType:SetLabel("Colour Background By Power Type")
    ColourBackgroundByType:SetValue(PowerBarDB.ColourBackgroundByType)
    ColourBackgroundByType:SetRelativeWidth(0.33)
    ColourBackgroundByType:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.ColourBackgroundByType = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  UUFGUI.BGColourPicker:SetDisabled(value) UUFGUI.DarkenFactorSlider:SetDisabled(not value) end)
    TogglesContainer:AddChild(ColourBackgroundByType)

    local ColourContainer = CreateInlineGroup(BarContainer, "Colours")
    UUFGUI.ColourContainer = ColourContainer

    local FGColourPicker = AG:Create("ColorPicker")
    FGColourPicker:SetLabel("Foreground Colour")
    FGColourPicker:SetColor(unpack(PowerBarDB.FGColour))
    FGColourPicker:SetHasAlpha(true)
    FGColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) PowerBarDB.FGColour = {r, g, b, a} if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    FGColourPicker:SetRelativeWidth(0.33)
    ColourContainer:AddChild(FGColourPicker)
    UUFGUI.FGColourPicker = FGColourPicker

    local BGColourPicker = AG:Create("ColorPicker")
    BGColourPicker:SetLabel("Background Colour")
    BGColourPicker:SetColor(unpack(PowerBarDB.BGColour))
    BGColourPicker:SetHasAlpha(true)
    BGColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) PowerBarDB.BGColour = {r, g, b, a} if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    BGColourPicker:SetRelativeWidth(0.33)
    ColourContainer:AddChild(BGColourPicker)
    UUFGUI.BGColourPicker = BGColourPicker

    local DarkenFactorSlider = AG:Create("Slider")
    DarkenFactorSlider:SetLabel("Background Darken Factor")
    DarkenFactorSlider:SetValue(PowerBarDB.DarkenFactor)
    DarkenFactorSlider:SetSliderValues(0.1, 1.0, 0.01)
    DarkenFactorSlider:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.DarkenFactor = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    DarkenFactorSlider:SetRelativeWidth(0.33)
    ColourContainer:AddChild(DarkenFactorSlider)
    UUFGUI.DarkenFactorSlider = DarkenFactorSlider

    local LayoutContainer = CreateInlineGroup(BarContainer, "Layout")
    UUFGUI.LayoutContainer = LayoutContainer

    local HeightSlider = AG:Create("Slider")
    HeightSlider:SetLabel("Height")
    HeightSlider:SetValue(PowerBarDB.Height)
    HeightSlider:SetSliderValues(1, 500, 0.1)
    HeightSlider:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.Height = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    HeightSlider:SetRelativeWidth(0.5)
    LayoutContainer:AddChild(HeightSlider)

    local AlignmentDropdown = AG:Create("Dropdown")
    AlignmentDropdown:SetLabel("Alignment")
    AlignmentDropdown:SetList({ ["TOP"] = "Top", ["BOTTOM"] = "Bottom", })
    AlignmentDropdown:SetValue(PowerBarDB.Alignment)
    AlignmentDropdown:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.Alignment = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    AlignmentDropdown:SetRelativeWidth(0.5)
    LayoutContainer:AddChild(AlignmentDropdown)

    local TextContainer = CreateInlineGroup(ScrollFrame, "Text")
    UUFGUI.TextContainer = TextContainer

    local TextToggleContainer = CreateInlineGroup(TextContainer, "Toggles")

    local EnableTextCheckBox = AG:Create("CheckBox")
    EnableTextCheckBox:SetLabel("Enable Power Text")
    EnableTextCheckBox:SetValue(PowerBarDB.Text.Enabled)
    EnableTextCheckBox:SetRelativeWidth(0.5)
    EnableTextCheckBox:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.Text.Enabled = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  DeepDisable(TextContainer, not value, EnableTextCheckBox) GUIRefresh() end)
    UUFGUI.EnableTextCheckBox = EnableTextCheckBox
    TextToggleContainer:AddChild(EnableTextCheckBox)

    local ColourTextByPowerType = AG:Create("CheckBox")
    ColourTextByPowerType:SetLabel("Colour Text By Power Type")
    ColourTextByPowerType:SetValue(PowerBarDB.Text.ColourByType)
    ColourTextByPowerType:SetRelativeWidth(0.5)
    ColourTextByPowerType:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.Text.ColourByType = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  TextColourPicker:SetDisabled(value) end)
    TextToggleContainer:AddChild(ColourTextByPowerType)

    local TextColourContainer = CreateInlineGroup(TextContainer, "Colours")

    TextColourPicker = AG:Create("ColorPicker")
    TextColourPicker:SetLabel("Text Colour")
    TextColourPicker:SetColor(unpack(PowerBarDB.Text.Colour))
    TextColourPicker:SetHasAlpha(true)
    TextColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) PowerBarDB.Text.Colour = {r, g, b, a} if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    TextColourPicker:SetRelativeWidth(0.5)
    TextColourContainer:AddChild(TextColourPicker)

    local TextLayoutContainer = CreateInlineGroup(TextContainer, "Layout")

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetValue(PowerBarDB.Text.AnchorFrom)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.Text.AnchorFrom = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    AnchorFromDropdown:SetRelativeWidth(0.3)
    TextLayoutContainer:AddChild(AnchorFromDropdown)

    local AnchorParentDropdown = AG:Create("Dropdown")
    AnchorParentDropdown:SetLabel("Anchor Parent")
    AnchorParentDropdown:SetList({ ["POWER"] = "Power Bar", ["FRAME"] = "Unit Frame", })
    AnchorParentDropdown:SetValue(PowerBarDB.Text.AnchorParent)
    AnchorParentDropdown:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.Text.AnchorParent = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    AnchorParentDropdown:SetRelativeWidth(0.33)
    TextLayoutContainer:AddChild(AnchorParentDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetValue(PowerBarDB.Text.AnchorTo)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.Text.AnchorTo = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    AnchorToDropdown:SetRelativeWidth(0.33)
    TextLayoutContainer:AddChild(AnchorToDropdown)

    local XPositionSlider = AG:Create("Slider")
    XPositionSlider:SetLabel("X Offset")
    XPositionSlider:SetValue(PowerBarDB.Text.OffsetX)
    XPositionSlider:SetSliderValues(-500, 500, 0.1)
    XPositionSlider:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.Text.OffsetX = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    XPositionSlider:SetRelativeWidth(0.33)
    TextLayoutContainer:AddChild(XPositionSlider)

    local YPositionSlider = AG:Create("Slider")
    YPositionSlider:SetLabel("Y Offset")
    YPositionSlider:SetValue(PowerBarDB.Text.OffsetY)
    YPositionSlider:SetSliderValues(-500, 500, 0.1)
    YPositionSlider:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.Text.OffsetY = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    YPositionSlider:SetRelativeWidth(0.33)
    TextLayoutContainer:AddChild(YPositionSlider)

    local FontSizeSlider = AG:Create("Slider")
    FontSizeSlider:SetLabel("Font Size")
    FontSizeSlider:SetValue(PowerBarDB.Text.FontSize)
    FontSizeSlider:SetSliderValues(6, 72, 1)
    FontSizeSlider:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.Text.FontSize = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    FontSizeSlider:SetRelativeWidth(0.33)
    TextLayoutContainer:AddChild(FontSizeSlider)

    GUIRefresh()

    FGColourPicker:SetDisabled(PowerBarDB.ColourByType)
    BGColourPicker:SetDisabled(PowerBarDB.ColourBackgroundByType)
    DarkenFactorSlider:SetDisabled(not PowerBarDB.ColourBackgroundByType)
    EnableTextCheckBox:SetDisabled(not PowerBarDB.Enabled)

    ScrollFrame:DoLayout()

    return ScrollFrame
end

local function CreateAlternatePowerBarSettings(containerParent, unit)
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local AlternatePowerBarDB = UUFDB[normalizedUnit].AlternatePowerBar

    local Wrapper = AG:Create("SimpleGroup")
    Wrapper:SetFullWidth(true)
    Wrapper:SetFullHeight(true)
    Wrapper:SetLayout("Fill")
    containerParent:AddChild(Wrapper)

    local ScrollFrame = CreateScrollFrame(Wrapper)

    local TogglesContainer = CreateInlineGroup(ScrollFrame, "Toggles")

    local EnableCheckBox = AG:Create("CheckBox")
    EnableCheckBox:SetLabel("Enable Alternate Power Bar")
    EnableCheckBox:SetValue(AlternatePowerBarDB.Enabled)
    EnableCheckBox:SetRelativeWidth(0.5)
    EnableCheckBox:SetCallback("OnValueChanged", function(_, _, value) AlternatePowerBarDB.Enabled = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  DeepDisable(Wrapper, not value, EnableCheckBox) end)
    TogglesContainer:AddChild(EnableCheckBox)

    local ColourByType = AG:Create("CheckBox")
    ColourByType:SetLabel("Colour By Power Type")
    ColourByType:SetValue(AlternatePowerBarDB.ColourByType)
    ColourByType:SetRelativeWidth(0.5)
    ColourByType:SetCallback("OnValueChanged", function(_, _, value) AlternatePowerBarDB.ColourByType = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    TogglesContainer:AddChild(ColourByType)

    local ColoursContainer = CreateInlineGroup(ScrollFrame, "Colours")
    local FGColourPicker = AG:Create("ColorPicker")
    FGColourPicker:SetLabel("Foreground Colour")
    FGColourPicker:SetColor(unpack(AlternatePowerBarDB.FGColour))
    FGColourPicker:SetHasAlpha(true)
    FGColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) AlternatePowerBarDB.FGColour = {r, g, b, a} if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    ColoursContainer:AddChild(FGColourPicker)

    local BGColourPicker = AG:Create("ColorPicker")
    BGColourPicker:SetLabel("Background Colour")
    BGColourPicker:SetColor(unpack(AlternatePowerBarDB.BGColour))
    BGColourPicker:SetHasAlpha(true)
    BGColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) AlternatePowerBarDB.BGColour = {r, g, b, a} if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    ColoursContainer:AddChild(BGColourPicker)

    local LayoutContainer = CreateInlineGroup(ScrollFrame, "Layout")

    local WidthSlider = AG:Create("Slider")
    WidthSlider:SetLabel("Width")
    WidthSlider:SetValue(AlternatePowerBarDB.Width)
    WidthSlider:SetSliderValues(1, 3000, 0.1)
    WidthSlider:SetCallback("OnValueChanged", function(_, _, value) AlternatePowerBarDB.Width = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    WidthSlider:SetRelativeWidth(0.5)
    LayoutContainer:AddChild(WidthSlider)

    local HeightSlider = AG:Create("Slider")
    HeightSlider:SetLabel("Height")
    HeightSlider:SetValue(AlternatePowerBarDB.Height)
    HeightSlider:SetSliderValues(1, 500, 0.1)
    HeightSlider:SetCallback("OnValueChanged", function(_, _, value) AlternatePowerBarDB.Height = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    HeightSlider:SetRelativeWidth(0.5)
    LayoutContainer:AddChild(HeightSlider)

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetValue(AlternatePowerBarDB.AnchorFrom)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) AlternatePowerBarDB.AnchorFrom = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    AnchorFromDropdown:SetRelativeWidth(0.5)
    LayoutContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetValue(AlternatePowerBarDB.AnchorTo)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) AlternatePowerBarDB.AnchorTo = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    AnchorToDropdown:SetRelativeWidth(0.5)
    LayoutContainer:AddChild(AnchorToDropdown)

    local XPositionSlider = AG:Create("Slider")
    XPositionSlider:SetLabel("X Position")
    XPositionSlider:SetValue(AlternatePowerBarDB.XPosition)
    XPositionSlider:SetSliderValues(-3000, 3000, 0.1)
    XPositionSlider:SetCallback("OnValueChanged", function(_, _, value) AlternatePowerBarDB.XPosition = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    XPositionSlider:SetRelativeWidth(0.5)
    LayoutContainer:AddChild(XPositionSlider)

    local YPositionSlider = AG:Create("Slider")
    YPositionSlider:SetLabel("Y Position")
    YPositionSlider:SetValue(AlternatePowerBarDB.YPosition)
    YPositionSlider:SetSliderValues(-3000, 3000, 0.1)
    YPositionSlider:SetCallback("OnValueChanged", function(_, _, value) AlternatePowerBarDB.YPosition = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    YPositionSlider:SetRelativeWidth(0.5)
    LayoutContainer:AddChild(YPositionSlider)

    DeepDisable(Wrapper, not AlternatePowerBarDB.Enabled, EnableCheckBox)

    return ScrollFrame
end

local function CreateIndicatorSettings(containerParent, unit)
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local IndicatorsDB = UUFDB[normalizedUnit].Indicators

    local Wrapper = AG:Create("SimpleGroup")
    Wrapper:SetFullWidth(true)
    Wrapper:SetFullHeight(true)
    Wrapper:SetLayout("Fill")
    containerParent:AddChild(Wrapper)

    local ScrollFrame = CreateScrollFrame(Wrapper)

    local MouseoverHighlightContainer = CreateInlineGroup(ScrollFrame, "Mouseover Highlight")
    local EnableCheckBox = AG:Create("CheckBox")
    EnableCheckBox:SetLabel("Enable Mouseover Highlight")
    EnableCheckBox:SetValue(IndicatorsDB.MouseoverHighlight.Enabled)
    EnableCheckBox:SetRelativeWidth(0.5)
    EnableCheckBox:SetCallback("OnValueChanged", function(_, _, value) IndicatorsDB.MouseoverHighlight.Enabled = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  DeepDisable(MouseoverHighlightContainer, not IndicatorsDB.MouseoverHighlight.Enabled, EnableCheckBox) end)
    MouseoverHighlightContainer:AddChild(EnableCheckBox)

    local ColourPicker = AG:Create("ColorPicker")
    ColourPicker:SetLabel("Highlight Colour")
    ColourPicker:SetColor(unpack(IndicatorsDB.MouseoverHighlight.Colour))
    ColourPicker:SetHasAlpha(true)
    ColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) IndicatorsDB.MouseoverHighlight.Colour = {r, g, b, a} if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    ColourPicker:SetRelativeWidth(0.5)
    MouseoverHighlightContainer:AddChild(ColourPicker)

    local TargetIndicatorContainer = CreateInlineGroup(ScrollFrame, "Target Indicator")
    local EnableTargetCheckBox = AG:Create("CheckBox")
    EnableTargetCheckBox:SetLabel("Enable Target Indicator")
    EnableTargetCheckBox:SetValue(IndicatorsDB.TargetIndicator.Enabled)
    EnableTargetCheckBox:SetRelativeWidth(0.33)
    EnableTargetCheckBox:SetCallback("OnValueChanged", function(_, _, value) IndicatorsDB.TargetIndicator.Enabled = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  DeepDisable(TargetIndicatorContainer, not IndicatorsDB.TargetIndicator.Enabled, EnableTargetCheckBox) end)
    TargetIndicatorContainer:AddChild(EnableTargetCheckBox)

    local ColourPickerTarget = AG:Create("ColorPicker")
    ColourPickerTarget:SetLabel("Indicator Colour")
    ColourPickerTarget:SetColor(unpack(IndicatorsDB.TargetIndicator.Colour))
    ColourPickerTarget:SetHasAlpha(true)
    ColourPickerTarget:SetCallback("OnValueChanged", function(_, _, r, g, b, a) IndicatorsDB.TargetIndicator.Colour = {r, g, b, a} if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    ColourPickerTarget:SetRelativeWidth(0.33)
    TargetIndicatorContainer:AddChild(ColourPickerTarget)

    local IndicatorStyleDropdown = AG:Create("Dropdown")
    IndicatorStyleDropdown:SetLabel("Indicator Style")
    IndicatorStyleDropdown:SetList({ ["BOX"] = "Box", ["GLOW"] = "Glow", })
    IndicatorStyleDropdown:SetValue(IndicatorsDB.TargetIndicator.Style)
    IndicatorStyleDropdown:SetCallback("OnValueChanged", function(_, _, value) IndicatorsDB.TargetIndicator.Style = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    IndicatorStyleDropdown:SetRelativeWidth(0.33)
    TargetIndicatorContainer:AddChild(IndicatorStyleDropdown)

    local RaidTargetMarkerContainer = CreateInlineGroup(ScrollFrame, "Raid Target Marker")
    local EnableRTMCheckBox = AG:Create("CheckBox")
    EnableRTMCheckBox:SetLabel("Enable Raid Target Marker")
    EnableRTMCheckBox:SetValue(IndicatorsDB.RaidTargetMarker.Enabled)
    EnableRTMCheckBox:SetRelativeWidth(1)
    EnableRTMCheckBox:SetCallback("OnValueChanged", function(_, _, value) IndicatorsDB.RaidTargetMarker.Enabled = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  DeepDisable(RaidTargetMarkerContainer, not IndicatorsDB.RaidTargetMarker.Enabled, EnableRTMCheckBox) end)
    RaidTargetMarkerContainer:AddChild(EnableRTMCheckBox)

    local AnchorFromRTMDropdown = AG:Create("Dropdown")
    AnchorFromRTMDropdown:SetLabel("Anchor From")
    AnchorFromRTMDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromRTMDropdown:SetValue(IndicatorsDB.RaidTargetMarker.AnchorFrom)
    AnchorFromRTMDropdown:SetCallback("OnValueChanged", function(_, _, value) IndicatorsDB.RaidTargetMarker.AnchorFrom = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    AnchorFromRTMDropdown:SetRelativeWidth(0.5)
    RaidTargetMarkerContainer:AddChild(AnchorFromRTMDropdown)

    local AnchorToRTMDropdown = AG:Create("Dropdown")
    AnchorToRTMDropdown:SetLabel("Anchor To")
    AnchorToRTMDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToRTMDropdown:SetValue(IndicatorsDB.RaidTargetMarker.AnchorTo)
    AnchorToRTMDropdown:SetCallback("OnValueChanged", function(_, _, value) IndicatorsDB.RaidTargetMarker.AnchorTo = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    AnchorToRTMDropdown:SetRelativeWidth(0.5)
    RaidTargetMarkerContainer:AddChild(AnchorToRTMDropdown)

    local OffsetXRTMSlider = AG:Create("Slider")
    OffsetXRTMSlider:SetLabel("Offset X")
    OffsetXRTMSlider:SetValue(IndicatorsDB.RaidTargetMarker.OffsetX)
    OffsetXRTMSlider:SetSliderValues(-3000, 3000, 0.1)
    OffsetXRTMSlider:SetCallback("OnValueChanged", function(_, _, value) IndicatorsDB.RaidTargetMarker.OffsetX = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    OffsetXRTMSlider:SetRelativeWidth(0.33)
    RaidTargetMarkerContainer:AddChild(OffsetXRTMSlider)

    local OffsetYRTMSlider = AG:Create("Slider")
    OffsetYRTMSlider:SetLabel("Offset Y")
    OffsetYRTMSlider:SetValue(IndicatorsDB.RaidTargetMarker.OffsetY)
    OffsetYRTMSlider:SetSliderValues(-3000, 3000, 0.1)
    OffsetYRTMSlider:SetCallback("OnValueChanged", function(_, _, value) IndicatorsDB.RaidTargetMarker.OffsetY = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    OffsetYRTMSlider:SetRelativeWidth(0.33)
    RaidTargetMarkerContainer:AddChild(OffsetYRTMSlider)

    local SizeRTMSlider = AG:Create("Slider")
    SizeRTMSlider:SetLabel("Size")
    SizeRTMSlider:SetValue(IndicatorsDB.RaidTargetMarker.Size)
    SizeRTMSlider:SetSliderValues(1, 500, 1)
    SizeRTMSlider:SetCallback("OnValueChanged", function(_, _, value) IndicatorsDB.RaidTargetMarker.Size = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    SizeRTMSlider:SetRelativeWidth(0.33)
    RaidTargetMarkerContainer:AddChild(SizeRTMSlider)

    if unit == "player" or unit == "target" then
        local LeaderIndicatorContainer = CreateInlineGroup(ScrollFrame, "Leader Indicator")
        local EnableLeaderCheckBox = AG:Create("CheckBox")
        EnableLeaderCheckBox:SetLabel("Enable Leader Indicator")
        EnableLeaderCheckBox:SetValue(IndicatorsDB.Leader.Enabled)
        EnableLeaderCheckBox:SetRelativeWidth(1)
        EnableLeaderCheckBox:SetCallback("OnValueChanged", function(_, _, value) IndicatorsDB.Leader.Enabled = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  DeepDisable(LeaderIndicatorContainer, not IndicatorsDB.Leader.Enabled, EnableLeaderCheckBox) end)
        LeaderIndicatorContainer:AddChild(EnableLeaderCheckBox)

        local AnchorFromLeaderDropdown = AG:Create("Dropdown")
        AnchorFromLeaderDropdown:SetLabel("Anchor From")
        AnchorFromLeaderDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
        AnchorFromLeaderDropdown:SetValue(IndicatorsDB.Leader.AnchorFrom)
        AnchorFromLeaderDropdown:SetCallback("OnValueChanged", function(_, _, value) IndicatorsDB.Leader.AnchorFrom = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
        AnchorFromLeaderDropdown:SetRelativeWidth(0.5)
        LeaderIndicatorContainer:AddChild(AnchorFromLeaderDropdown)

        local AnchorToLeaderDropdown = AG:Create("Dropdown")
        AnchorToLeaderDropdown:SetLabel("Anchor To")
        AnchorToLeaderDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
        AnchorToLeaderDropdown:SetValue(IndicatorsDB.Leader.AnchorTo)
        AnchorToLeaderDropdown:SetCallback("OnValueChanged", function(_, _, value) IndicatorsDB.Leader.AnchorTo = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
        AnchorToLeaderDropdown:SetRelativeWidth(0.5)
        LeaderIndicatorContainer:AddChild(AnchorToLeaderDropdown)

        local OffsetXLeaderSlider = AG:Create("Slider")
        OffsetXLeaderSlider:SetLabel("Offset X")
        OffsetXLeaderSlider:SetValue(IndicatorsDB.Leader.OffsetX)
        OffsetXLeaderSlider:SetSliderValues(-3000, 3000, 0.1)
        OffsetXLeaderSlider:SetCallback("OnValueChanged", function(_, _, value) IndicatorsDB.Leader.OffsetX = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
        OffsetXLeaderSlider:SetRelativeWidth(0.33)
        LeaderIndicatorContainer:AddChild(OffsetXLeaderSlider)

        local OffsetYLeaderSlider = AG:Create("Slider")
        OffsetYLeaderSlider:SetLabel("Offset Y")
        OffsetYLeaderSlider:SetValue(IndicatorsDB.Leader.OffsetY)
        OffsetYLeaderSlider:SetSliderValues(-3000, 3000, 0.1)
        OffsetYLeaderSlider:SetCallback("OnValueChanged", function(_, _, value) IndicatorsDB.Leader.OffsetY = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
        OffsetYLeaderSlider:SetRelativeWidth(0.33)
        LeaderIndicatorContainer:AddChild(OffsetYLeaderSlider)

        local SizeLeaderSlider = AG:Create("Slider")
        SizeLeaderSlider:SetLabel("Size")
        SizeLeaderSlider:SetValue(IndicatorsDB.Leader.Size)
        SizeLeaderSlider:SetSliderValues(1, 500, 1)
        SizeLeaderSlider:SetCallback("OnValueChanged", function(_, _, value) IndicatorsDB.Leader.Size = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
        SizeLeaderSlider:SetRelativeWidth(0.33)
        LeaderIndicatorContainer:AddChild(SizeLeaderSlider)

        DeepDisable(LeaderIndicatorContainer, not IndicatorsDB.Leader.Enabled, EnableLeaderCheckBox)
    end

    if unit == "player" then

        local Status = IndicatorsDB.Status

        local StatusContainer = CreateInlineGroup(ScrollFrame, "Status Indicator")

        local function GUIRefresh()
            local statusActive = (Status.Combat or Status.Resting)

            for _, child in ipairs(StatusContainer.children) do
                if child ~= UUFGUI.DisplayCombatIndicatorCheckBox
                and child ~= UUFGUI.DisplayRestingIndicatorCheckBox then
                    DeepDisable(child, not statusActive, nil)
                end
            end

            -- These two dropdowns depend on the individual toggle state
            DeepDisable(UUFGUI.CombatTextureIndicatorDropdown, not Status.Combat)
            DeepDisable(UUFGUI.RestingTextureIndicatorDropdown, not Status.Resting)
        end

        local StatusDesc = AG:Create("Label")
        StatusDesc:SetText(UUF.InfoButton .. "|cFF8080FFCombat|r / |cFF8080FFResting|r Indicators share the same position & size settings.")
        StatusDesc:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
        StatusDesc:SetFullWidth(true)
        StatusDesc:SetJustifyH("CENTER")
        StatusContainer:AddChild(StatusDesc)

        local DisplayCombatIndicatorCheckBox = AG:Create("CheckBox")
        DisplayCombatIndicatorCheckBox:SetLabel("Display Combat Indicator")
        DisplayCombatIndicatorCheckBox:SetValue(Status.Combat)
        DisplayCombatIndicatorCheckBox:SetRelativeWidth(0.5)
        DisplayCombatIndicatorCheckBox:SetCallback("OnValueChanged", function(_, _, value) Status.Combat = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  GUIRefresh() end)
        UUFGUI.DisplayCombatIndicatorCheckBox = DisplayCombatIndicatorCheckBox
        StatusContainer:AddChild(DisplayCombatIndicatorCheckBox)

        local DisplayRestingIndicatorCheckBox = AG:Create("CheckBox")
        DisplayRestingIndicatorCheckBox:SetLabel("Display Resting Indicator")
        DisplayRestingIndicatorCheckBox:SetValue(Status.Resting)
        DisplayRestingIndicatorCheckBox:SetRelativeWidth(0.5)
        DisplayRestingIndicatorCheckBox:SetCallback("OnValueChanged", function(_, _, value) Status.Resting = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  GUIRefresh() end)
        UUFGUI.DisplayRestingIndicatorCheckBox = DisplayRestingIndicatorCheckBox
        StatusContainer:AddChild(DisplayRestingIndicatorCheckBox)

        local CombatTextureIndicatorDropdown = AG:Create("Dropdown")
        CombatTextureIndicatorDropdown:SetList(CombatTextures)
        CombatTextureIndicatorDropdown:SetLabel("Combat Indicator Texture")
        CombatTextureIndicatorDropdown:SetValue(Status.CombatTexture)
        CombatTextureIndicatorDropdown:SetRelativeWidth(0.5)
        CombatTextureIndicatorDropdown:SetCallback("OnValueChanged", function(_, _, value) Status.CombatTexture = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
        UUFGUI.CombatTextureIndicatorDropdown = CombatTextureIndicatorDropdown
        StatusContainer:AddChild(CombatTextureIndicatorDropdown)

        local RestingTextureIndicatorDropdown = AG:Create("Dropdown")
        RestingTextureIndicatorDropdown:SetList(RestingTextures)
        RestingTextureIndicatorDropdown:SetLabel("Resting Indicator Texture")
        RestingTextureIndicatorDropdown:SetValue(Status.RestingTexture)
        RestingTextureIndicatorDropdown:SetRelativeWidth(0.5)
        RestingTextureIndicatorDropdown:SetCallback("OnValueChanged", function(_, _, value) Status.RestingTexture = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
        UUFGUI.RestingTextureIndicatorDropdown = RestingTextureIndicatorDropdown
        StatusContainer:AddChild(RestingTextureIndicatorDropdown)

        local StatusAnchorFromDropdown = AG:Create("Dropdown")
        StatusAnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
        StatusAnchorFromDropdown:SetLabel("Anchor From")
        StatusAnchorFromDropdown:SetValue(Status.AnchorFrom)
        StatusAnchorFromDropdown:SetRelativeWidth(0.5)
        StatusAnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) Status.AnchorFrom = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
        StatusContainer:AddChild(StatusAnchorFromDropdown)

        local StatusAnchorToDropdown = AG:Create("Dropdown")
        StatusAnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
        StatusAnchorToDropdown:SetLabel("Anchor To")
        StatusAnchorToDropdown:SetValue(Status.AnchorTo)
        StatusAnchorToDropdown:SetRelativeWidth(0.5)
        StatusAnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) Status.AnchorTo = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
        StatusContainer:AddChild(StatusAnchorToDropdown)

        local StatusOffsetXSlider = AG:Create("Slider")
        StatusOffsetXSlider:SetLabel("Offset X")
        StatusOffsetXSlider:SetValue(Status.OffsetX)
        StatusOffsetXSlider:SetSliderValues(-1000, 1000, 1)
        StatusOffsetXSlider:SetRelativeWidth(0.33)
        StatusOffsetXSlider:SetCallback("OnValueChanged", function(_, _, value) Status.OffsetX = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
        StatusContainer:AddChild(StatusOffsetXSlider)

        local StatusOffsetYSlider = AG:Create("Slider")
        StatusOffsetYSlider:SetLabel("Offset Y")
        StatusOffsetYSlider:SetValue(Status.OffsetY)
        StatusOffsetYSlider:SetSliderValues(-1000, 1000, 1)
        StatusOffsetYSlider:SetRelativeWidth(0.33)
        StatusOffsetYSlider:SetCallback("OnValueChanged", function(_, _, value) Status.OffsetY = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
        StatusContainer:AddChild(StatusOffsetYSlider)

        local StatusSizeSlider = AG:Create("Slider")
        StatusSizeSlider:SetLabel("Size")
        StatusSizeSlider:SetValue(Status.Size)
        StatusSizeSlider:SetSliderValues(8, 128, 1)
        StatusSizeSlider:SetRelativeWidth(0.33)
        StatusSizeSlider:SetCallback("OnValueChanged", function(_, _, value) Status.Size = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
        StatusContainer:AddChild(StatusSizeSlider)

        GUIRefresh()
    end

    DeepDisable(MouseoverHighlightContainer, not IndicatorsDB.MouseoverHighlight.Enabled, EnableCheckBox)
    DeepDisable(RaidTargetMarkerContainer, not IndicatorsDB.RaidTargetMarker.Enabled, EnableRTMCheckBox)
    DeepDisable(TargetIndicatorContainer, not IndicatorsDB.TargetIndicator.Enabled, EnableTargetCheckBox)

    ScrollFrame:DoLayout()

    return ScrollFrame
end

local function CreatePortraitSettings(containerParent, unit)
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local PortraitDB = UUFDB[normalizedUnit].Portrait

    local Wrapper = AG:Create("SimpleGroup")
    Wrapper:SetFullWidth(true)
    Wrapper:SetFullHeight(true)
    Wrapper:SetLayout("Fill")
    containerParent:AddChild(Wrapper)

    local ScrollFrame = CreateScrollFrame(Wrapper)

    local TogglesContainer = CreateInlineGroup(ScrollFrame, "Toggles")

    local EnableCheckBox = AG:Create("CheckBox")
    EnableCheckBox:SetLabel("Enable Portrait")
    EnableCheckBox:SetValue(PortraitDB.Enabled)
    EnableCheckBox:SetRelativeWidth(1)
    EnableCheckBox:SetCallback("OnValueChanged", function(_, _, value) PortraitDB.Enabled = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  DeepDisable(Wrapper, not value, EnableCheckBox) end)
    TogglesContainer:AddChild(EnableCheckBox)

    local LayoutContainer = CreateInlineGroup(ScrollFrame, "Layout")

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetValue(PortraitDB.AnchorFrom)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) PortraitDB.AnchorFrom = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    AnchorFromDropdown:SetRelativeWidth(0.5)
    LayoutContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetValue(PortraitDB.AnchorTo)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) PortraitDB.AnchorTo = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    AnchorToDropdown:SetRelativeWidth(0.5)
    LayoutContainer:AddChild(AnchorToDropdown)

    local XPositionSlider = AG:Create("Slider")
    XPositionSlider:SetLabel("X Position")
    XPositionSlider:SetValue(PortraitDB.OffsetX)
    XPositionSlider:SetSliderValues(-3000, 3000, 0.1)
    XPositionSlider:SetCallback("OnValueChanged", function(_, _, value) PortraitDB.OffsetX = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    XPositionSlider:SetRelativeWidth(0.5)
    LayoutContainer:AddChild(XPositionSlider)

    local YPositionSlider = AG:Create("Slider")
    YPositionSlider:SetLabel("Y Position")
    YPositionSlider:SetValue(PortraitDB.OffsetY)
    YPositionSlider:SetSliderValues(-3000, 3000, 0.1)
    YPositionSlider:SetCallback("OnValueChanged", function(_, _, value) PortraitDB.OffsetY = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    YPositionSlider:SetRelativeWidth(0.5)
    LayoutContainer:AddChild(YPositionSlider)

    local SizeSlider = AG:Create("Slider")
    SizeSlider:SetLabel("Size")
    SizeSlider:SetValue(PortraitDB.Size)
    SizeSlider:SetSliderValues(1, 500, 0.1)
    SizeSlider:SetCallback("OnValueChanged", function(_, _, value) PortraitDB.Size = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    SizeSlider:SetRelativeWidth(0.5)
    LayoutContainer:AddChild(SizeSlider)

    local ZoomSlider = AG:Create("Slider")
    ZoomSlider:SetLabel("Zoom Level")
    ZoomSlider:SetValue(PortraitDB.Zoom)
    ZoomSlider:SetSliderValues(0, 1, 0.1)
    ZoomSlider:SetIsPercent(true)
    ZoomSlider:SetCallback("OnValueChanged", function(_, _, value) PortraitDB.Zoom = value if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end)
    ZoomSlider:SetRelativeWidth(0.5)
    LayoutContainer:AddChild(ZoomSlider)

    DeepDisable(Wrapper, not PortraitDB.Enabled, EnableCheckBox)

    return ScrollFrame
end

local function CreateTagsSettings(containerParent, unit)
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local TagsDB = UUFDB[normalizedUnit].Tags

    local function SelectTagTab(TagContainer, _, TagName)
        TagContainer:ReleaseChildren()
        if TagName == "TagOne" then
            local TagOneContainer = AG:Create("SimpleGroup")
            TagOneContainer:SetLayout("Flow")
            TagOneContainer:SetFullWidth(true)
            TagOneContainer:SetFullHeight(true)
            TagContainer:AddChild(TagOneContainer)
            CreateTagSettings(TagOneContainer, unit, "TagOne")
        elseif TagName == "TagTwo" then
            local TagTwoContainer = AG:Create("SimpleGroup")
            TagTwoContainer:SetLayout("Flow")
            TagTwoContainer:SetFullWidth(true)
            TagTwoContainer:SetFullHeight(true)
            TagContainer:AddChild(TagTwoContainer)
            CreateTagSettings(TagTwoContainer, unit, "TagTwo")
        elseif TagName == "TagThree" then
            local TagThreeContainer = AG:Create("SimpleGroup")
            TagThreeContainer:SetLayout("Flow")
            TagThreeContainer:SetFullWidth(true)
            TagThreeContainer:SetFullHeight(true)
            TagContainer:AddChild(TagThreeContainer)
            CreateTagSettings(TagThreeContainer, unit, "TagThree")
        end
    end

    local TagsTabGroup = AG:Create("TabGroup")
    TagsTabGroup:SetLayout("Fill")
    TagsTabGroup:SetFullWidth(true)
    TagsTabGroup:SetFullHeight(true)
    TagsTabGroup:SetTabs({
        { text = "Tag One", value = "TagOne", },
        { text = "Tag Two", value = "TagTwo", },
        { text = "Tag Three", value = "TagThree", },
    })
    TagsTabGroup:SetCallback("OnGroupSelected", SelectTagTab)
    TagsTabGroup:SelectTab("TagOne")
    containerParent:AddChild(TagsTabGroup)

    return TagsTabGroup
end

function UUF:CreateGUI()
    if OpenedGUI then return end
    if InCombatLockdown() then return end

    OpenedGUI = true
    GUIFrame = AG:Create("Frame")
    GUIFrame:SetTitle(UUF.AddOnName)
    GUIFrame:SetLayout("Fill")
    GUIFrame:SetWidth(900)
    GUIFrame:SetHeight(600)
    GUIFrame:EnableResize(true)
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
        EnableUIScaleCheckBox:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.General.AllowUIScaling = value DeepDisable(UIScaleContainer, not value, EnableUIScaleCheckBox) end)
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
        FontDropdown:SetCallback("OnValueChanged", function(widget, _, value) widget:SetValue(value) UUF.db.profile.General.Font = value UUF:ResolveMedia() for unit in pairs(UnitToFrameName) do if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end end)
        FontsContainer:AddChild(FontDropdown)

        local FontFlagsDropdown = AG:Create("Dropdown")
        FontFlagsDropdown:SetList({ ["OUTLINE"] = "Outline", ["THICKOUTLINE"] = "Thick Outline", ["MONOCHROME"] = "Monochrome", ["NONE"] = "None", })
        FontFlagsDropdown:SetLabel("Font Flags")
        FontFlagsDropdown:SetValue(UUF.db.profile.General.FontFlag)
        FontFlagsDropdown:SetRelativeWidth(0.5)
        FontFlagsDropdown:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.General.FontFlag = value for unit in pairs(UnitToFrameName) do if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end end)
        FontsContainer:AddChild(FontFlagsDropdown)

        local FontShadowsContainer = CreateInlineGroup(FontsContainer, "Font Shadows")

        local FontShadowXOffsetSlider = AG:Create("Slider")
        FontShadowXOffsetSlider:SetLabel("X Offset")
        FontShadowXOffsetSlider:SetValue(UUF.db.profile.General.FontShadows.OffsetX)
        FontShadowXOffsetSlider:SetSliderValues(-10, 10, 1)
        FontShadowXOffsetSlider:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.General.FontShadows.OffsetX = value for unit in pairs(UnitToFrameName) do if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end end)
        FontShadowsContainer:AddChild(FontShadowXOffsetSlider)

        local FontShadowYOffsetSlider = AG:Create("Slider")
        FontShadowYOffsetSlider:SetLabel("Y Offset")
        FontShadowYOffsetSlider:SetValue(UUF.db.profile.General.FontShadows.OffsetY)
        FontShadowYOffsetSlider:SetSliderValues(-10, 10, 1)
        FontShadowYOffsetSlider:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.General.FontShadows.OffsetY = value for unit in pairs(UnitToFrameName) do if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end end)
        FontShadowsContainer:AddChild(FontShadowYOffsetSlider)

        local FontShadowColourPicker = AG:Create("ColorPicker")
        FontShadowColourPicker:SetLabel("Shadow Colour")
        FontShadowColourPicker:SetColor(unpack(UUF.db.profile.General.FontShadows.Colour))
        FontShadowColourPicker:SetHasAlpha(true)
        FontShadowColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) UUF.db.profile.General.FontShadows.Colour = {r, g, b, a} for unit in pairs(UnitToFrameName) do if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end end)
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
        ForegroundTextureDropdown:SetCallback("OnValueChanged", function(widget, _, value) widget:SetValue(value) UUF.db.profile.General.ForegroundTexture = value UUF:ResolveMedia() for unit in pairs(UnitToFrameName) do if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end end)
        TexturesContainer:AddChild(ForegroundTextureDropdown)

        local BackgroundTextureDropdown = AG:Create("LSM30_Statusbar")
        BackgroundTextureDropdown:SetList(LSM:HashTable("statusbar"))
        BackgroundTextureDropdown:SetLabel("Background Texture")
        BackgroundTextureDropdown:SetValue(UUF.db.profile.General.BackgroundTexture)
        BackgroundTextureDropdown:SetRelativeWidth(0.5)
        BackgroundTextureDropdown:SetCallback("OnValueChanged", function(widget, _, value) widget:SetValue(value) UUF.db.profile.General.BackgroundTexture = value UUF:ResolveMedia() for unit in pairs(UnitToFrameName) do if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end end)
        TexturesContainer:AddChild(BackgroundTextureDropdown)

        local ColoursContainer = CreateInlineGroup(TexturesColourContainer, "Colours")

        local GlobalColoursInfo = CreateInfoTag("|cFF8080FFColours|r & |cFF8080FFOpacity|r values are static, but it can be used to change all units at once.")
        GlobalColoursInfo:SetRelativeWidth(1)
        ColoursContainer:AddChild(GlobalColoursInfo)

        local FGColourPicker = AG:Create("ColorPicker")
        FGColourPicker:SetLabel("Foreground Colour (Global)")
        FGColourPicker:SetColor(26/255, 26/255, 26/255, 1)
        FGColourPicker:SetHasAlpha(true)
        FGColourPicker:SetRelativeWidth(0.5)
        FGColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) for unit in pairs(UnitToFrameName) do UUF.db.profile[unit].Frame.FGColour = {r, g, b, a} if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end end)
        ColoursContainer:AddChild(FGColourPicker)

        local ForegroundOpacitySlider = AG:Create("Slider")
        ForegroundOpacitySlider:SetLabel("Foreground Opacity (Global)")
        ForegroundOpacitySlider:SetValue(0.8)
        ForegroundOpacitySlider:SetSliderValues(0, 1, 0.01)
        ForegroundOpacitySlider:SetRelativeWidth(0.5)
        ForegroundOpacitySlider:SetIsPercent(true)
        ForegroundOpacitySlider:SetCallback("OnValueChanged", function(_, _, value) for unit in pairs(UnitToFrameName) do local r, g, b = unpack(UUF.db.profile[unit].Frame.FGColour) UUF.db.profile[unit].Frame.FGColour = {r, g, b, value} if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end end)
        ColoursContainer:AddChild(ForegroundOpacitySlider)

        local BGColourPicker = AG:Create("ColorPicker")
        BGColourPicker:SetLabel("Background Colour (Global)")
        BGColourPicker:SetColor(128/255, 128/255, 128/255, 1)
        BGColourPicker:SetHasAlpha(true)
        BGColourPicker:SetRelativeWidth(0.5)
        BGColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) for unit in pairs(UnitToFrameName) do UUF.db.profile[unit].Frame.BGColour = {r, g, b, a} if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end end)
        ColoursContainer:AddChild(BGColourPicker)

        local BackgroundOpacitySlider = AG:Create("Slider")
        BackgroundOpacitySlider:SetLabel("Background Opacity (Global)")
        BackgroundOpacitySlider:SetValue(1)
        BackgroundOpacitySlider:SetSliderValues(0, 1, 0.01)
        BackgroundOpacitySlider:SetRelativeWidth(0.5)
        BackgroundOpacitySlider:SetIsPercent(true)
        BackgroundOpacitySlider:SetCallback("OnValueChanged", function(_, _, value) for unit in pairs(UnitToFrameName) do local r, g, b = unpack(UUF.db.profile[unit].Frame.BGColour) UUF.db.profile[unit].Frame.BGColour = {r, g, b, value} if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end end)
        ColoursContainer:AddChild(BackgroundOpacitySlider)

        local ColoursInfo = CreateInfoTag("|cFF8080FFButtons|r will allow you to swap between |cFFFFCC00Class / Reaction Mode|r and |cFFFFCC00Dark Mode|r.")
        ColoursInfo:SetRelativeWidth(1)
        ColoursContainer:AddChild(ColoursInfo)

        local ColouredModeButton = AG:Create("Button")
        ColouredModeButton:SetText("Class / Reaction Mode")
        ColouredModeButton:SetRelativeWidth(0.5)
        ColouredModeButton:SetCallback("OnClick", function() for unit in pairs(UnitToFrameName) do UUF.db.profile[unit].Frame.ClassColour = true UUF.db.profile[unit].Frame.ReactionColour = true UUF.db.profile[unit].Frame.BGColour = {26/255, 26/255, 26/255, 1} if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end end)
        ColoursContainer:AddChild(ColouredModeButton)

        local DarkModeButton = AG:Create("Button")
        DarkModeButton:SetText("Dark Mode")
        DarkModeButton:SetRelativeWidth(0.5)
        DarkModeButton:SetCallback("OnClick", function() for unit in pairs(UnitToFrameName) do UUF.db.profile[unit].Frame.ClassColour = false UUF.db.profile[unit].Frame.ReactionColour = false UUF.db.profile[unit].Frame.BGColour = {128/255, 128/255, 128/255, 1} if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end end)
        ColoursContainer:AddChild(DarkModeButton)
        --------------------------------------------------------------
        --- Custom Colours
        --------------------------------------------------------------
        local CustomColoursContainer = CreateInlineGroup(ScrollFrame, "Custom Colours")

        local DefaultColours = {
                Reaction = {
                    [1] = {204/255, 64/255, 64/255},            -- Hated
                    [2] = {204/255, 64/255, 64/255},            -- Hostile
                    [3] = {204/255, 128/255, 64/255},           -- Unfriendly
                    [4] = {204/255, 204/255, 64/255},           -- Neutral
                    [5] = {64/255, 204/255, 64/255},            -- Friendly
                    [6] = {64/255, 204/255, 64/255},            -- Honored
                    [7] = {64/255, 204/255, 64/255},            -- Revered
                    [8] = {64/255, 204/255, 64/255},            -- Exalted
                },
                Power = {
                    [0] = {0, 0, 1},            -- Mana
                    [1] = {1, 0, 0},            -- Rage
                    [2] = {1, 0.5, 0.25},       -- Focus
                    [3] = {1, 1, 0},            -- Energy
                    [6] = {0, 0.82, 1},         -- Runic Power
                    [8] = {0.75, 0.52, 0.9},     -- Lunar Power
                    [11] = {0, 0.5, 1},         -- Maelstrom
                    [13] = {0.4, 0, 0.8},       -- Insanity
                    [17] = {0.79, 0.26, 0.99},  -- Fury
                    [18] = {1, 0.61, 0}         -- Pain
                },
                Classification = {
                    ["worldboss"] = {204/255, 64/255, 64/255},
                    ["rareelite"] = {128/255, 64/255, 204/255},
                    ["elite"] = {255/255, 204/255, 64/255},
                    ["rare"] = {0/255, 112/255, 204/255},
                    ["normal"] = {255/255, 255/255, 255/255}
                }
        }

        local ResetPowerColoursButton = AG:Create("Button")
        ResetPowerColoursButton:SetText("Reset Power Colours")
        ResetPowerColoursButton:SetRelativeWidth(0.33)
        ResetPowerColoursButton:SetCallback("OnClick", function()
            UUF.db.profile.General.CustomColours.Power = UUF:CopyTable(DefaultColours.Power)
            for unit in pairs(UnitToFrameName) do if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end
        end)
        CustomColoursContainer:AddChild(ResetPowerColoursButton)

        local ResetReactionColoursButton = AG:Create("Button")
        ResetReactionColoursButton:SetText("Reset Reaction Colours")
        ResetReactionColoursButton:SetRelativeWidth(0.33)
        ResetReactionColoursButton:SetCallback("OnClick", function()
            UUF.db.profile.General.CustomColours.Reaction = UUF:CopyTable(DefaultColours.Reaction)
            for unit in pairs(UnitToFrameName) do if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end
        end)
        CustomColoursContainer:AddChild(ResetReactionColoursButton)

        local ResetClassificationColoursButton = AG:Create("Button")
        ResetClassificationColoursButton:SetText("Reset Classification Colours")
        ResetClassificationColoursButton:SetRelativeWidth(0.33)
        ResetClassificationColoursButton:SetCallback("OnClick", function()
            UUF.db.profile.General.CustomColours.Classification = UUF:CopyTable(DefaultColours.Classification)
            for unit in pairs(UnitToFrameName) do if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end
        end)
        CustomColoursContainer:AddChild(ResetClassificationColoursButton)

        local PowerColours = CreateInlineGroup(CustomColoursContainer, "Power")
        local PowerOrder = {0, 1, 2, 3, 6, 8, 11, 13, 17, 18}
        for _, powerType in ipairs(PowerOrder) do
            local powerColour = UUF.db.profile.General.CustomColours.Power[powerType]
            local PowerColour = AG:Create("ColorPicker")
            PowerColour:SetLabel(PowerNames[powerType])
            local R, G, B = unpack(powerColour)
            PowerColour:SetColor(R, G, B)
            PowerColour:SetCallback("OnValueChanged", function(widget, _, r, g, b) UUF.db.profile.General.CustomColours.Power[powerType] = {r, g, b} for unit in pairs(UnitToFrameName) do if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end end)
            PowerColour:SetHasAlpha(false)
            PowerColour:SetRelativeWidth(0.19)
            PowerColours:AddChild(PowerColour)
        end

        local ReactionColours = CreateInlineGroup(CustomColoursContainer, "Reaction")
        local ReactionOrder = {1, 2, 3, 4, 5, 6, 7, 8}
        for _, reactionType in ipairs(ReactionOrder) do
            local ReactionColour = AG:Create("ColorPicker")
            ReactionColour:SetLabel(ReactionNames[reactionType])
            local R, G, B = unpack(UUF.db.profile.General.CustomColours.Reaction[reactionType])
            ReactionColour:SetColor(R, G, B)
            ReactionColour:SetCallback("OnValueChanged", function(widget, _, r, g, b) UUF.db.profile.General.CustomColours.Reaction[reactionType] = {r, g, b} for unit in pairs(UnitToFrameName) do if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end end)
            ReactionColour:SetHasAlpha(false)
            ReactionColour:SetRelativeWidth(0.25)
            ReactionColours:AddChild(ReactionColour)
        end

        local ClassificationColours = CreateInlineGroup(CustomColoursContainer, "Classification")
        local ClassificationOrder = {"normal", "rare", "elite", "rareelite", "worldboss"}
        for _, classification in ipairs(ClassificationOrder) do
            local ClassificationColour = AG:Create("ColorPicker")
            ClassificationColour:SetLabel(ClassificationNames[classification])
            local R, G, B = unpack(UUF.db.profile.General.CustomColours.Classification[classification])
            ClassificationColour:SetColor(R, G, B)
            ClassificationColour:SetCallback("OnValueChanged", function(widget, _, r, g, b) UUF.db.profile.General.CustomColours.Classification[classification] = {r, g, b} for unit in pairs(UnitToFrameName) do if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end end)
            ClassificationColour:SetHasAlpha(false)
            ClassificationColour:SetRelativeWidth(0.19)
            ClassificationColours:AddChild(ClassificationColour)
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
        SelectProfileDropdown:SetCallback("OnValueChanged", function(_, _, value) UUF.db:SetProfile(value) UIParent:SetScale(UUF.db.profile.General.UIScale or 1) for unit in pairs(UnitToFrameName) do if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end RefreshProfiles() end)
        ProfileContainer:AddChild(SelectProfileDropdown)

        CopyFromProfileDropdown = AG:Create("Dropdown")
        CopyFromProfileDropdown:SetLabel("Copy From...")
        CopyFromProfileDropdown:SetRelativeWidth(0.25)
        CopyFromProfileDropdown:SetCallback("OnValueChanged", function(_, _, value) UUF:CreatePrompt("Copy Profile", "Are you sure you want to copy from |cFF8080FF" .. value .. "|r?\nThis will |cFFFF4040overwrite|r your current profile settings.", function() UUF.db:CopyProfile(value) UIParent:SetScale(UUF.db.profile.General.UIScale or 1) for unit in pairs(UnitToFrameName) do if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end RefreshProfiles() end) end)
        ProfileContainer:AddChild(CopyFromProfileDropdown)

        DeleteProfileDropdown = AG:Create("Dropdown")
        DeleteProfileDropdown:SetLabel("Delete...")
        DeleteProfileDropdown:SetRelativeWidth(0.25)
        DeleteProfileDropdown:SetCallback("OnValueChanged", function(_, _, value) if value ~= UUF.db:GetCurrentProfile() then UUF:CreatePrompt("Delete Profile", "Are you sure you want to delete |cFF8080FF" .. value .. "|r?", function() UUF.db:DeleteProfile(value) RefreshProfiles() end) end end)
        ProfileContainer:AddChild(DeleteProfileDropdown)

        local ResetProfileButton = AG:Create("Button")
        ResetProfileButton:SetText("Reset |cFF8080FF" .. UUF.db:GetCurrentProfile() .. "|r Profile")
        ResetProfileButton:SetRelativeWidth(0.25)
        ResetProfileButton:SetCallback("OnClick", function() UUF.db:ResetProfile() UUF:ResolveMedia() for unit in pairs(UnitToFrameName) do if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end UIParent:SetScale(UUF.db.profile.General.UIScale or 1) RefreshProfiles() end)
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
        CreateProfileButton:SetCallback("OnClick", function() local profileName = strtrim(CreateProfileEditBox:GetText() or "") if profileName ~= "" then UUF.db:SetProfile(profileName) UIParent:SetScale(UUF.db.profile.General.UIScale or 1) for unit in pairs(UnitToFrameName) do if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end RefreshProfiles() CreateProfileEditBox:SetText("") end end)
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
        UseGlobalProfileToggle:SetCallback("OnValueChanged", function(_, _, value) UUF.db.global.UseGlobalProfile = value if value and UUF.db.global.GlobalProfile and UUF.db.global.GlobalProfile ~= "" then UUF.db:SetProfile(UUF.db.global.GlobalProfile) UIParent:SetScale(UUF.db.profile.General.UIScale or 1) for unit in pairs(UnitToFrameName) do if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end end GlobalProfileDropdown:SetDisabled(not value) for _, child in ipairs(ProfileContainer.children) do if child ~= UseGlobalProfileToggle and child ~= GlobalProfileDropdown then DeepDisable(child, value) end end RefreshProfiles() end)
        ProfileContainer:AddChild(UseGlobalProfileToggle)

        RefreshProfiles()

        GlobalProfileDropdown = AG:Create("Dropdown")
        GlobalProfileDropdown:SetLabel("Global Profile...")
        GlobalProfileDropdown:SetRelativeWidth(0.5)
        GlobalProfileDropdown:SetList(profileKeys)
        GlobalProfileDropdown:SetValue(UUF.db.global.GlobalProfile)
        GlobalProfileDropdown:SetCallback("OnValueChanged", function(_, _, value) UUF.db:SetProfile(value) UUF.db.global.GlobalProfile = value UIParent:SetScale(UUF.db.profile.General.UIScale or 1) for unit in pairs(UnitToFrameName) do if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end RefreshProfiles() end)
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

    local function DrawTagsSettings(GUIContainer)
        local ScrollFrame = CreateScrollFrame(GUIContainer)

        local HealthTagLayout = AG:Create("Dropdown")
        HealthTagLayout:SetLabel("Health Tag Layout")
        HealthTagLayout:SetList(HealthTagLayouts[1], HealthTagLayouts[2])
        HealthTagLayout:SetValue(UUF.db.profile.General.HealthTagLayout)
        HealthTagLayout:SetRelativeWidth(1)
        HealthTagLayout:SetCallback("OnValueChanged", function(_, _, value) UUF.HealthTagLayout = value UUF.db.profile.General.HealthTagLayout = value for unit in pairs(UnitToFrameName) do if unit == "boss" then UUF:UpdateAllBossFrames() else UUF:UpdateUnitFrame(unit) end  end end)
        ScrollFrame:AddChild(HealthTagLayout)

        local function DrawTagContainer(TagContainer, tagGroup)
            local TagsList = UUF:GetTagsForGroup(tagGroup)
            local TagDescriptions = TagsList[1]
            local TagOrder = TagsList[2]

            for _, Tag in ipairs(TagOrder) do
                local Desc = TagDescriptions[Tag] or Tag

                local TagDesc = AG:Create("Label")
                TagDesc:SetText("|cFFFFCC00" .. Desc .. "|r")
                TagDesc:SetRelativeWidth(0.3)
                TagDesc:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
                TagDesc:SetJustifyH("LEFT")
                TagDesc:SetJustifyV("MIDDLE")
                TagContainer:AddChild(TagDesc)

                local TagValue = AG:Create("EditBox")
                TagValue:SetText("[" .. Tag .. "]")
                TagValue:SetCallback("OnTextChanged", function(widget, event, value) TagValue:ClearFocus() TagValue:SetText("[" .. Tag .. "]") end)
                TagValue:SetRelativeWidth(0.7)
                TagContainer:AddChild(TagValue)

                local TagSpacer = AG:Create("Label")
                TagSpacer:SetText(" ")
                TagSpacer:SetRelativeWidth(1)
                TagContainer:AddChild(TagSpacer)
            end
        end

        local function SelectedGroup(TagContainer, _, subGroup)
            TagContainer:ReleaseChildren()
            if subGroup == "Health" then
                DrawTagContainer(TagContainer, "Health")
            elseif subGroup == "Name" then
                DrawTagContainer(TagContainer, "Name")
            elseif subGroup == "Power" then
                DrawTagContainer(TagContainer, "Power")
            elseif subGroup == "Misc" then
                DrawTagContainer(TagContainer, "Misc")
            end
            ScrollFrame:DoLayout()
        end

        local GUIContainerTabGroup = AG:Create("TabGroup")
        GUIContainerTabGroup:SetLayout("Flow")
        GUIContainerTabGroup:SetTabs({
            { text = "Health", value = "Health" },
            { text = "Power", value = "Power" },
            { text = "Name", value = "Name" },
            { text = "Misc", value = "Misc" },
        })
        GUIContainerTabGroup:SetCallback("OnGroupSelected", SelectedGroup)
        GUIContainerTabGroup:SelectTab("Health")
        GUIContainerTabGroup:SetFullWidth(true)
        ScrollFrame:AddChild(GUIContainerTabGroup)
        ScrollFrame:DoLayout()
    end

    local function DrawPlayerSettings(GUIContainer)
        local function UnitFrameSelectedGroup(UnitFrameContainer, _, UnitFrameGroup)
            UnitFrameContainer:ReleaseChildren()
            if UnitFrameGroup == "Frame" then
                CreateUnitFrameFrameSettings(UnitFrameContainer, "player")
            elseif UnitFrameGroup == "HealPrediction" then
                CreateHealPredictionSettings(UnitFrameContainer, "player")
            elseif UnitFrameGroup == "PowerBar" then
                CreatePowerBarSettings(UnitFrameContainer, "player")
            elseif UnitFrameGroup == "AlternatePowerBar" then
                CreateAlternatePowerBarSettings(UnitFrameContainer, "player")
            elseif UnitFrameGroup == "Indicators" then
                CreateIndicatorSettings(UnitFrameContainer, "player")
            elseif UnitFrameGroup == "Portrait" then
                CreatePortraitSettings(UnitFrameContainer, "player")
            elseif UnitFrameGroup == "Tags" then
                CreateTagsSettings(UnitFrameContainer, "player")
            end
        end

        local UnitFrameTabGroup = AG:Create("TabGroup")
        UnitFrameTabGroup:SetLayout("Flow")
        UnitFrameTabGroup:SetFullWidth(true)
        if UUF:RequiresAlternatePowerBar("player") then
            UnitFrameTabGroup:SetTabs({
                { text = "Frame", value = "Frame"},
                { text = "Heal Prediction", value = "HealPrediction"},
                { text = "Power Bar", value = "PowerBar"},
                { text = "Alternate Power Bar", value = "AlternatePowerBar"},
                { text = "Indicators", value = "Indicators"},
                { text = "Portrait", value = "Portrait"},
                { text = "Tags", value = "Tags"},
            })
        else
            UnitFrameTabGroup:SetTabs({
                { text = "Frame", value = "Frame"},
                { text = "Heal Prediction", value = "HealPrediction"},
                { text = "Power Bar", value = "PowerBar"},
                { text = "Indicators", value = "Indicators"},
                { text = "Portrait", value = "Portrait"},
                { text = "Tags", value = "Tags"},
            })
        end
        UnitFrameTabGroup:SetCallback("OnGroupSelected", UnitFrameSelectedGroup)
        UnitFrameTabGroup:SelectTab("Frame")
        GUIContainer:AddChild(UnitFrameTabGroup)
    end

    local function DrawTargetSettings(GUIContainer)
        local function UnitFrameSelectedGroup(UnitFrameContainer, _, UnitFrameGroup)
            UnitFrameContainer:ReleaseChildren()
            if UnitFrameGroup == "Frame" then
                CreateUnitFrameFrameSettings(UnitFrameContainer, "target")
            elseif UnitFrameGroup == "HealPrediction" then
                CreateHealPredictionSettings(UnitFrameContainer, "target")
            elseif UnitFrameGroup == "PowerBar" then
                CreatePowerBarSettings(UnitFrameContainer, "target")
            elseif UnitFrameGroup == "Indicators" then
                CreateIndicatorSettings(UnitFrameContainer, "target")
            elseif UnitFrameGroup == "Portrait" then
                CreatePortraitSettings(UnitFrameContainer, "target")
            elseif UnitFrameGroup == "Tags" then
                CreateTagsSettings(UnitFrameContainer, "target")
            end
        end

        local UnitFrameTabGroup = AG:Create("TabGroup")
        UnitFrameTabGroup:SetLayout("Flow")
        UnitFrameTabGroup:SetFullWidth(true)
        UnitFrameTabGroup:SetTabs({
            { text = "Frame", value = "Frame"},
            { text = "Heal Prediction", value = "HealPrediction"},
            { text = "Power Bar", value = "PowerBar"},
            { text = "Indicators", value = "Indicators"},
            { text = "Portrait", value = "Portrait"},
            { text = "Tags", value = "Tags"},
        })
        UnitFrameTabGroup:SetCallback("OnGroupSelected", UnitFrameSelectedGroup)
        UnitFrameTabGroup:SelectTab("Frame")
        GUIContainer:AddChild(UnitFrameTabGroup)
    end

    local function DrawTargetTargetSettings(GUIContainer)
        local function UnitFrameSelectedGroup(UnitFrameContainer, _, UnitFrameGroup)
            UnitFrameContainer:ReleaseChildren()
            if UnitFrameGroup == "Frame" then
                CreateUnitFrameFrameSettings(UnitFrameContainer, "targettarget")
            elseif UnitFrameGroup == "HealPrediction" then
                CreateHealPredictionSettings(UnitFrameContainer, "targettarget")
            elseif UnitFrameGroup == "PowerBar" then
                CreatePowerBarSettings(UnitFrameContainer, "targettarget")
            elseif UnitFrameGroup == "Indicators" then
                CreateIndicatorSettings(UnitFrameContainer, "targettarget")
            elseif UnitFrameGroup == "Tags" then
                CreateTagsSettings(UnitFrameContainer, "targettarget")
            end
        end

        local UnitFrameTabGroup = AG:Create("TabGroup")
        UnitFrameTabGroup:SetLayout("Flow")
        UnitFrameTabGroup:SetFullWidth(true)
        UnitFrameTabGroup:SetTabs({
            { text = "Frame", value = "Frame"},
            { text = "Heal Prediction", value = "HealPrediction"},
            { text = "Power Bar", value = "PowerBar"},
            { text = "Indicators", value = "Indicators"},
            { text = "Tags", value = "Tags"},
        })
        UnitFrameTabGroup:SetCallback("OnGroupSelected", UnitFrameSelectedGroup)
        UnitFrameTabGroup:SelectTab("Frame")
        GUIContainer:AddChild(UnitFrameTabGroup)
    end

    local function DrawPetSettings(GUIContainer)
        local function UnitFrameSelectedGroup(UnitFrameContainer, _, UnitFrameGroup)
            UnitFrameContainer:ReleaseChildren()
            if UnitFrameGroup == "Frame" then
                CreateUnitFrameFrameSettings(UnitFrameContainer, "pet")
            elseif UnitFrameGroup == "HealPrediction" then
                CreateHealPredictionSettings(UnitFrameContainer, "pet")
            elseif UnitFrameGroup == "Indicators" then
                CreateIndicatorSettings(UnitFrameContainer, "pet")
            elseif UnitFrameGroup == "Tags" then
                CreateTagsSettings(UnitFrameContainer, "pet")
            end
        end

        local UnitFrameTabGroup = AG:Create("TabGroup")
        UnitFrameTabGroup:SetLayout("Flow")
        UnitFrameTabGroup:SetFullWidth(true)
        UnitFrameTabGroup:SetTabs({
            { text = "Frame", value = "Frame"},
            { text = "Heal Prediction", value = "HealPrediction"},
            { text = "Indicators", value = "Indicators"},
            { text = "Tags", value = "Tags"},
        })
        UnitFrameTabGroup:SetCallback("OnGroupSelected", UnitFrameSelectedGroup)
        UnitFrameTabGroup:SelectTab("Frame")
        GUIContainer:AddChild(UnitFrameTabGroup)
    end

    local function DrawFocusSettings(GUIContainer)
        local function UnitFrameSelectedGroup(UnitFrameContainer, _, UnitFrameGroup)
            UnitFrameContainer:ReleaseChildren()
            if UnitFrameGroup == "Frame" then
                CreateUnitFrameFrameSettings(UnitFrameContainer, "focus")
            elseif UnitFrameGroup == "HealPrediction" then
                CreateHealPredictionSettings(UnitFrameContainer, "focus")
            elseif UnitFrameGroup == "Indicators" then
                CreateIndicatorSettings(UnitFrameContainer, "focus")
            elseif UnitFrameGroup == "Tags" then
                CreateTagsSettings(UnitFrameContainer, "focus")
            end
        end

        local UnitFrameTabGroup = AG:Create("TabGroup")
        UnitFrameTabGroup:SetLayout("Flow")
        UnitFrameTabGroup:SetFullWidth(true)
        UnitFrameTabGroup:SetTabs({
            { text = "Frame", value = "Frame"},
            { text = "Heal Prediction", value = "HealPrediction"},
            { text = "Indicators", value = "Indicators"},
            { text = "Tags", value = "Tags"},
        })
        UnitFrameTabGroup:SetCallback("OnGroupSelected", UnitFrameSelectedGroup)
        UnitFrameTabGroup:SelectTab("Frame")
        GUIContainer:AddChild(UnitFrameTabGroup)
    end

    local function DrawBossSettings(GUIContainer)
        local function UnitFrameSelectedGroup(UnitFrameContainer, _, UnitFrameGroup)
            UnitFrameContainer:ReleaseChildren()
            if UnitFrameGroup == "Frame" then
                CreateUnitFrameFrameSettings(UnitFrameContainer, "boss")
            elseif UnitFrameGroup == "HealPrediction" then
                CreateHealPredictionSettings(UnitFrameContainer, "boss")
            elseif UnitFrameGroup == "PowerBar" then
                CreatePowerBarSettings(UnitFrameContainer, "boss")
            elseif UnitFrameGroup == "Indicators" then
                CreateIndicatorSettings(UnitFrameContainer, "boss")
            elseif UnitFrameGroup == "Portrait" then
                CreatePortraitSettings(UnitFrameContainer, "boss")
            elseif UnitFrameGroup == "Tags" then
                CreateTagsSettings(UnitFrameContainer, "boss")
            end
        end

        local UnitFrameTabGroup = AG:Create("TabGroup")
        UnitFrameTabGroup:SetLayout("Flow")
        UnitFrameTabGroup:SetFullWidth(true)
        UnitFrameTabGroup:SetTabs({
            { text = "Frame", value = "Frame"},
            { text = "Heal Prediction", value = "HealPrediction"},
            { text = "Power Bar", value = "PowerBar"},
            { text = "Indicators", value = "Indicators"},
            { text = "Portrait", value = "Portrait"},
            { text = "Tags", value = "Tags"},
        })
        UnitFrameTabGroup:SetCallback("OnGroupSelected", UnitFrameSelectedGroup)
        UnitFrameTabGroup:SelectTab("Frame")
        GUIContainer:AddChild(UnitFrameTabGroup)
    end

    local function SelectedGroup(GUIContainer, _, MainGroup)
        GUIContainer:ReleaseChildren()

        local Wrapper = AG:Create("SimpleGroup")
        Wrapper:SetFullWidth(true)
        Wrapper:SetFullHeight(true)
        Wrapper:SetLayout("Fill")
        GUIContainer:AddChild(Wrapper)

        if MainGroup == "General" then
            DrawGeneralSettings(Wrapper)
        elseif MainGroup == "player" then
            DrawPlayerSettings(Wrapper)
            UUF:HideBossFrames()
        elseif MainGroup == "target" then
            DrawTargetSettings(Wrapper)
            UUF:HideBossFrames()
        elseif MainGroup == "targettarget" then
            DrawTargetTargetSettings(Wrapper)
            UUF:HideBossFrames()
        elseif MainGroup == "pet" then
            DrawPetSettings(Wrapper)
            UUF:HideBossFrames()
        elseif MainGroup == "focus" then
            DrawFocusSettings(Wrapper)
            UUF:HideBossFrames()
        elseif MainGroup == "boss" then
            DrawBossSettings(Wrapper)
            UUF:ShowBossFrames()
        elseif MainGroup == "Tags" then
            DrawTagsSettings(Wrapper)
            UUF:HideBossFrames()
        elseif MainGroup == "Profiles" then
            DrawProfileSettings(Wrapper)
            UUF:HideBossFrames()
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