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
    ["BOTTOMRIGHT"] = "Bottom Right"
}

local AnchorOrder = { "TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "CENTER", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT", }

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

local SLIDER_STEP, SLIDER_MIN, SLIDER_MAX = 0.1, -3000, 3000

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

    local function DrawGeneralContainer(Container)
        local General = UUF.db.profile.General
        local ScrollFrame = AG:Create("ScrollFrame")
        ScrollFrame:SetLayout("Flow")
        ScrollFrame:SetFullWidth(true)
        ScrollFrame:SetFullHeight(true)
        Container:AddChild(ScrollFrame)

        local UIScaleContainer = AG:Create("InlineGroup")
        UIScaleContainer:SetTitle("UI Scale")
        UIScaleContainer:SetLayout("Flow")
        UIScaleContainer:SetFullWidth(true)
        ScrollFrame:AddChild(UIScaleContainer)

        local UIScaleInfo = CreateInfoTag("This can force the UI Scale to be lower than |cFF08B6FFBlizzard|r intends which can cause some |cFFFFCC00unexpected effects|r.\nIf you experience issues, please |cFFFF4040disable|r the feature.")
        UIScaleInfo:SetRelativeWidth(1)

        local UIScaleSlider = AG:Create("Slider")
        UIScaleSlider:SetLabel("UI Scale")
        UIScaleSlider:SetValue(UUF.db.profile.General.UIScale or 1)
        UIScaleSlider:SetSliderValues(0.3, 1.5, 0.01)
        UIScaleSlider:SetRelativeWidth(0.33)
        UIScaleSlider:SetCallback("OnMouseUp", function(_, _, value)
            if not UUF.db.global.ApplyUIScale then return end
            if value > 0.8 then
                UUF:CreatePrompt(
                "UI Scale Warning",
                "Setting the UI Scale to |cFF8080FF" .. value .. "|r\nThis may cause UI Elements to appear very large.\nAre you sure you want to continue?",
                function() UUF.db.profile.General.UIScale = value UIParent:SetScale(value) end,
                function() UIParent:SetScale(UUF.db.profile.General.UIScale) UIScaleSlider:SetValue(UUF.db.profile.General.UIScale) UIScaleSlider:SetLabel("UI Scale") end,
                "Set |cFF8080FF" .. value .. "|r UI Scale"
            )
            else
                UUF.db.profile.General.UIScale = value
                UIParent:SetScale(value)
            end
        end)
        UIScaleSlider:SetCallback("OnValueChanged", function(_, _, value)
            if value > 0.8 then
                UIScaleSlider:SetLabel("UI Scale |cFFFF4040(Warning)|r")
            else
                UIScaleSlider:SetLabel("UI Scale")
            end
        end)

        local TenEightyUIScaleButton = AG:Create("Button")
        TenEightyUIScaleButton:SetText("1080p")
        TenEightyUIScaleButton:SetRelativeWidth(0.33)
        TenEightyUIScaleButton:SetCallback("OnClick", function()
            if not UUF.db.profile.General.AllowUIScaling then return end
            UUF.db.profile.General.UIScale = 0.7111111111111
            UIParent:SetScale(0.7111111111111)
            UIScaleSlider:SetValue(0.7111111111111)
        end)
        TenEightyUIScaleButton:SetCallback("OnEnter", function()
            GameTooltip:SetOwner(TenEightyUIScaleButton.frame, "ANCHOR_TOP")
            GameTooltip:AddLine("UI Scale is set to |cFF8080FF0.7111111111111|r", 1, 1, 1)
            GameTooltip:Show()
        end)
        TenEightyUIScaleButton:SetCallback("OnLeave", function() GameTooltip:Hide() end)

        local FourteenFortyUIScaleButton = AG:Create("Button")
        FourteenFortyUIScaleButton:SetText("1440p")
        FourteenFortyUIScaleButton:SetRelativeWidth(0.33)
        FourteenFortyUIScaleButton:SetCallback("OnClick", function()
            if not UUF.db.profile.General.AllowUIScaling then return end
            UUF.db.profile.General.UIScale = 0.5333333333333
            UIParent:SetScale(0.5333333333333)
            UIScaleSlider:SetValue(0.5333333333333)
        end)
        FourteenFortyUIScaleButton:SetCallback("OnEnter", function()
            GameTooltip:SetOwner(FourteenFortyUIScaleButton.frame, "ANCHOR_TOP")
            GameTooltip:AddLine("UI Scale is set to |cFF8080FF0.5333333333333|r", 1, 1, 1)
            GameTooltip:Show()
        end)
        FourteenFortyUIScaleButton:SetCallback("OnLeave", function() GameTooltip:Hide() end)

        local EnableUIScaleToggle = AG:Create("CheckBox")
        EnableUIScaleToggle:SetLabel("Enable UI Scale")
        EnableUIScaleToggle:SetValue(UUF.db.profile.General.AllowUIScaling)
        EnableUIScaleToggle:SetRelativeWidth(1)
        EnableUIScaleToggle:SetCallback("OnValueChanged", function(_, _, value)
            UUF.db.profile.General.AllowUIScaling = value
            if not value then
                UUF.db.profile.General.UIScale = 1
                UIParent:SetScale(1)
                UIScaleSlider:SetValue(1)
            else
                UIParent:SetScale(UUF.db.profile.General.UIScale)
                UIScaleSlider:SetValue(UUF.db.profile.General.UIScale)
            end
            if not UUF.db.global.ApplyUIScale then
                UIScaleSlider:SetDisabled(true)
                TenEightyUIScaleButton:SetDisabled(true)
                FourteenFortyUIScaleButton:SetDisabled(true)
                UIScaleContainer:DoLayout()
            else
                UIScaleSlider:SetDisabled(false)
                TenEightyUIScaleButton:SetDisabled(false)
                FourteenFortyUIScaleButton:SetDisabled(false)
                UIScaleContainer:DoLayout()
            end
            DeepDisable(UIScaleContainer, not value, EnableUIScaleToggle)
        end)

        UIScaleContainer:AddChild(UIScaleInfo)
        UIScaleContainer:AddChild(EnableUIScaleToggle)
        UIScaleContainer:AddChild(UIScaleSlider)
        UIScaleContainer:AddChild(TenEightyUIScaleButton)
        UIScaleContainer:AddChild(FourteenFortyUIScaleButton)

        DeepDisable(UIScaleContainer, not UUF.db.profile.General.AllowUIScaling, EnableUIScaleToggle)

        local TexturesContainer = AG:Create("InlineGroup")
        TexturesContainer:SetTitle("Textures")
        TexturesContainer:SetLayout("Flow")
        TexturesContainer:SetFullWidth(true)
        ScrollFrame:AddChild(TexturesContainer)

        local TexturesInfoTag = CreateInfoTag("|cFF8080FFTextures|r are applied globally to all elements & unit frames, where appropriate.")
        TexturesInfoTag:SetRelativeWidth(1)
        TexturesContainer:AddChild(TexturesInfoTag)

        local ForegroundTextureDropdown = AG:Create("LSM30_Statusbar")
        ForegroundTextureDropdown:SetList(LSM:HashTable("statusbar"))
        ForegroundTextureDropdown:SetLabel("Foreground Texture")
        ForegroundTextureDropdown:SetValue(UUF.db.profile.General.ForegroundTexture)
        ForegroundTextureDropdown:SetRelativeWidth(0.5)
        ForegroundTextureDropdown:SetCallback("OnValueChanged", function(widget, _, value)
            widget:SetValue(value)
            UUF.db.profile.General.ForegroundTexture = value
            UUF:ResolveMedia()
            for unit in pairs(UnitToFrameName) do
                UUF:UpdateUnitFrame(unit)
            end
        end)
        TexturesContainer:AddChild(ForegroundTextureDropdown)

        local BackgroundTextureDropdown = AG:Create("LSM30_Statusbar")
        BackgroundTextureDropdown:SetList(LSM:HashTable("statusbar"))
        BackgroundTextureDropdown:SetLabel("Background Texture")
        BackgroundTextureDropdown:SetValue(UUF.db.profile.General.BackgroundTexture)
        BackgroundTextureDropdown:SetRelativeWidth(0.5)
        BackgroundTextureDropdown:SetCallback("OnValueChanged", function(widget, _, value)
            widget:SetValue(value)
            UUF.db.profile.General.BackgroundTexture = value
            UUF:ResolveMedia()
            for unit in pairs(UnitToFrameName) do
                UUF:UpdateUnitFrame(unit)
            end
        end)
        TexturesContainer:AddChild(BackgroundTextureDropdown)

        local ColourPickerInfoTag = CreateInfoTag("|cFF8080FFForeground|r & |cFF8080FFBackground|r Colours are applied to all frames. This will override individual unit frame settings.")
        ColourPickerInfoTag:SetRelativeWidth(1)
        TexturesContainer:AddChild(ColourPickerInfoTag)

        local FGColourPicker = AG:Create("ColorPicker")
        FGColourPicker:SetLabel("Foreground Colour (Global)")
        FGColourPicker:SetColor(26/255, 26/255, 26/255, 1)
        FGColourPicker:SetHasAlpha(true)
        FGColourPicker:SetRelativeWidth(0.5)
        FGColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a)
            for unit in pairs(UnitToFrameName) do
                UUF.db.profile[unit].Frame.FGColour = {r, g, b, a}
                UUF:UpdateUnitFrame(unit)
            end
        end)
        TexturesContainer:AddChild(FGColourPicker)

        local BGColourPicker = AG:Create("ColorPicker")
        BGColourPicker:SetLabel("Background Colour (Global)")
        BGColourPicker:SetColor(128/255, 128/255, 128/255, 1)
        BGColourPicker:SetHasAlpha(true)
        BGColourPicker:SetRelativeWidth(0.5)
        BGColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a)
            for unit in pairs(UnitToFrameName) do
                UUF.db.profile[unit].Frame.BGColour = {r, g, b, a}
                UUF:UpdateUnitFrame(unit)
            end
        end)
        TexturesContainer:AddChild(BGColourPicker)

        local FontsContainer = AG:Create("InlineGroup")
        FontsContainer:SetTitle("Fonts")
        FontsContainer:SetLayout("Flow")
        FontsContainer:SetFullWidth(true)
        ScrollFrame:AddChild(FontsContainer)

        local FontDropdown = AG:Create("LSM30_Font")
        FontDropdown:SetList(LSM:HashTable("font"))
        FontDropdown:SetLabel("Font")
        FontDropdown:SetValue(UUF.db.profile.General.Font)
        FontDropdown:SetRelativeWidth(0.5)
        FontDropdown:SetCallback("OnValueChanged", function(widget, _, value)
            widget:SetValue(value)
            UUF.db.profile.General.Font = value
            UUF:ResolveMedia()
            for unit in pairs(UnitToFrameName) do
                UUF:UpdateUnitFrame(unit)
            end
        end)
        FontsContainer:AddChild(FontDropdown)

        local FontFlagsDropdown = AG:Create("Dropdown")
        FontFlagsDropdown:SetList({
            ["OUTLINE"] = "Outline",
            ["THICKOUTLINE"] = "Thick Outline",
            ["MONOCHROME"] = "Monochrome",
            ["NONE"] = "None",
        })
        FontFlagsDropdown:SetLabel("Font Flags")
        FontFlagsDropdown:SetValue(UUF.db.profile.General.FontFlag)
        FontFlagsDropdown:SetRelativeWidth(0.5)
        FontFlagsDropdown:SetCallback("OnValueChanged", function(_, _, value)
            UUF.db.profile.General.FontFlag = value
            for unit in pairs(UnitToFrameName) do
                UUF:UpdateUnitFrame(unit)
            end
        end)
        FontsContainer:AddChild(FontFlagsDropdown)

        local FontShadowsContainer = AG:Create("InlineGroup")
        FontShadowsContainer:SetTitle("Shadow")
        FontShadowsContainer:SetLayout("Flow")
        FontShadowsContainer:SetFullWidth(true)
        FontsContainer:AddChild(FontShadowsContainer)

        local FontShadowXOffsetSlider = AG:Create("Slider")
        FontShadowXOffsetSlider:SetLabel("X Offset")
        FontShadowXOffsetSlider:SetValue(UUF.db.profile.General.FontShadows.OffsetX)
        FontShadowXOffsetSlider:SetSliderValues(-10, 10, 1)
        FontShadowXOffsetSlider:SetCallback("OnValueChanged", function(_, _, value)
            UUF.db.profile.General.FontShadows.OffsetX = value
            for unit in pairs(UnitToFrameName) do
                UUF:UpdateUnitFrame(unit)
            end
        end)
        FontShadowsContainer:AddChild(FontShadowXOffsetSlider)

        local FontShadowYOffsetSlider = AG:Create("Slider")
        FontShadowYOffsetSlider:SetLabel("Y Offset")
        FontShadowYOffsetSlider:SetValue(UUF.db.profile.General.FontShadows.OffsetY)
        FontShadowYOffsetSlider:SetSliderValues(-10, 10, 1)
        FontShadowYOffsetSlider:SetCallback("OnValueChanged", function(_, _, value)
            UUF.db.profile.General.FontShadows.OffsetY = value
            for unit in pairs(UnitToFrameName) do
                UUF:UpdateUnitFrame(unit)
            end
        end)
        FontShadowsContainer:AddChild(FontShadowYOffsetSlider)

        local FontShadowColourPicker = AG:Create("ColorPicker")
        FontShadowColourPicker:SetLabel("Shadow Colour")
        FontShadowColourPicker:SetColor(unpack(UUF.db.profile.General.FontShadows.Colour))
        FontShadowColourPicker:SetHasAlpha(true)
        FontShadowColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a)
            UUF.db.profile.General.FontShadows.Colour = {r, g, b, a}
            for unit in pairs(UnitToFrameName) do
                UUF:UpdateUnitFrame(unit)
            end
        end)
        FontShadowsContainer:AddChild(FontShadowColourPicker)

        local CustomColoursContainer = AG:Create("InlineGroup")
        CustomColoursContainer:SetTitle("Custom Colours")
        CustomColoursContainer:SetLayout("Flow")
        CustomColoursContainer:SetFullWidth(true)
        ScrollFrame:AddChild(CustomColoursContainer)

        local PowerColours = AG:Create("InlineGroup")
        PowerColours:SetTitle("Power Colours")
        PowerColours:SetLayout("Flow")
        PowerColours:SetFullWidth(true)
        CustomColoursContainer:AddChild(PowerColours)

        local PowerOrder = {0, 1, 2, 3, 6, 8, 11, 13, 17, 18}
        for _, powerType in ipairs(PowerOrder) do
            local powerColour = General.CustomColours.Power[powerType]
            local PowerColour = AG:Create("ColorPicker")
            PowerColour:SetLabel(PowerNames[powerType])
            local R, G, B = unpack(powerColour)
            PowerColour:SetColor(R, G, B)
            PowerColour:SetCallback("OnValueChanged", function(widget, _, r, g, b) General.CustomColours.Power[powerType] = {r, g, b} for unit in pairs(UnitToFrameName) do UUF:UpdateUnitFrame(unit) end end)
            PowerColour:SetHasAlpha(false)
            PowerColour:SetRelativeWidth(0.25)
            PowerColours:AddChild(PowerColour)
        end

        local ReactionColours = AG:Create("InlineGroup")
        ReactionColours:SetTitle("Reaction Colours")
        ReactionColours:SetLayout("Flow")
        ReactionColours:SetFullWidth(true)
        CustomColoursContainer:AddChild(ReactionColours)

        for reactionType, reactionColour in pairs(General.CustomColours.Reaction) do
            local ReactionColour = AG:Create("ColorPicker")
            ReactionColour:SetLabel(ReactionNames[reactionType])
            local R, G, B = unpack(reactionColour)
            ReactionColour:SetColor(R, G, B)
            ReactionColour:SetCallback("OnValueChanged", function(widget, _, r, g, b) General.CustomColours.Reaction[reactionType] = {r, g, b} for unit in pairs(UnitToFrameName) do UUF:UpdateUnitFrame(unit) end end)
            ReactionColour:SetHasAlpha(false)
            ReactionColour:SetRelativeWidth(0.25)
            ReactionColours:AddChild(ReactionColour)
        end

        ScrollFrame:DoLayout()
    end

    local function DrawUnitFrameContainer(Container, Unit)
        local dbUnit = Unit
        if Unit:match("^boss%d+$") then dbUnit = "boss" end
        local DB = UUF.db.profile[dbUnit]
        local ScrollFrame = AG:Create("ScrollFrame")
        local isBoss = Unit == "boss"
        ScrollFrame:SetLayout("Flow")
        ScrollFrame:SetFullWidth(true)
        ScrollFrame:SetFullHeight(true)
        Container:AddChild(ScrollFrame)

        local EnableCheckBox = AG:Create("CheckBox")
        EnableCheckBox:SetLabel("Enable")
        EnableCheckBox:SetValue(DB.Enabled)
        EnableCheckBox:SetFullWidth(true)
        EnableCheckBox:SetCallback("OnValueChanged", function(_, _, value)
            DB.Enabled = value
            UUF:UpdateUnitFrame(Unit)
        end)
        ScrollFrame:AddChild(EnableCheckBox)

        if Unit == "boss" then
            local TestBossFrames = AG:Create("Button")
            TestBossFrames:SetText("Test Boss Frames")
            TestBossFrames:SetRelativeWidth(0.5)
            TestBossFrames:SetCallback("OnClick", function()
                UUF.BossTestMode = not UUF.BossTestMode
                UUF:TestBossFrames()
            end)
            ScrollFrame:AddChild(TestBossFrames)
            EnableCheckBox:SetRelativeWidth(0.5)
        end

        local function SelectedModuleGroup(UnitFrameContainer, _, ModuleGroup)
            UnitFrameContainer:ReleaseChildren()
            local function DrawColourContainer()
                local UseClassColourCheckBox = AG:Create("CheckBox")
                UseClassColourCheckBox:SetLabel("Use Class Colour")
                UseClassColourCheckBox:SetValue(DB.Frame.ClassColour)
                UseClassColourCheckBox:SetRelativeWidth(0.5)
                UseClassColourCheckBox:SetCallback("OnValueChanged", function(_, _, value)
                    DB.Frame.ClassColour = value
                    UUF:UpdateUnitFrame(Unit)
                end)
                UnitFrameContainer:AddChild(UseClassColourCheckBox)

                local FGColourPicker = AG:Create("ColorPicker")
                FGColourPicker:SetLabel("Foreground Colour")
                FGColourPicker:SetColor(unpack(DB.Frame.FGColour))
                FGColourPicker:SetHasAlpha(true)
                FGColourPicker:SetRelativeWidth(0.5)
                FGColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a)
                    DB.Frame.FGColour = {r, g, b, a}
                    UUF:UpdateUnitFrame(Unit)
                end)
                UnitFrameContainer:AddChild(FGColourPicker)

                local UseReactionColourCheckBox = AG:Create("CheckBox")
                UseReactionColourCheckBox:SetLabel("Use Reaction Colour")
                UseReactionColourCheckBox:SetValue(DB.Frame.ReactionColour)
                UseReactionColourCheckBox:SetRelativeWidth(0.5)
                UseReactionColourCheckBox:SetCallback("OnValueChanged", function(_, _, value)
                    DB.Frame.ReactionColour = value
                    UUF:UpdateUnitFrame(Unit)
                end)
                UnitFrameContainer:AddChild(UseReactionColourCheckBox)

                local BGColourPicker = AG:Create("ColorPicker")
                BGColourPicker:SetLabel("Background Colour")
                BGColourPicker:SetColor(unpack(DB.Frame.BGColour))
                BGColourPicker:SetHasAlpha(true)
                BGColourPicker:SetRelativeWidth(0.5)
                BGColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a)
                    DB.Frame.BGColour = {r, g, b, a}
                    UUF:UpdateUnitFrame(Unit)
                end)
                UnitFrameContainer:AddChild(BGColourPicker)
            end

            local function DrawFrameContainer()
                local WidthSlider = AG:Create("Slider")
                WidthSlider:SetLabel("Width")
                WidthSlider:SetValue(DB.Frame.Width)
                WidthSlider:SetSliderValues(50, 1000, 1)
                WidthSlider:SetRelativeWidth(isBoss and 0.33 or 0.5)
                WidthSlider:SetCallback("OnValueChanged", function(_, _, value)
                    DB.Frame.Width = value
                    if isBoss then
                        for i=1, 10 do
                            UUF:UpdateUnitFrame(Unit .. i)
                        end
                        UUF:LayoutBossFrames()
                    else
                        UUF:UpdateUnitFrame(Unit)
                    end
                end)
                UnitFrameContainer:AddChild(WidthSlider)

                local HeightSlider = AG:Create("Slider")
                HeightSlider:SetLabel("Height")
                HeightSlider:SetValue(DB.Frame.Height)
                HeightSlider:SetSliderValues(20, 500, 1)
                HeightSlider:SetRelativeWidth(isBoss and 0.33 or 0.5)
                HeightSlider:SetCallback("OnValueChanged", function(_, _, value)
                    DB.Frame.Height = value
                    if isBoss then
                        for i=1, 10 do
                            UUF:UpdateUnitFrame(Unit .. i)
                        end
                        UUF:LayoutBossFrames()
                    else
                        UUF:UpdateUnitFrame(Unit)
                    end
                end)
                UnitFrameContainer:AddChild(HeightSlider)

                if isBoss then
                    local SpacingSlider = AG:Create("Slider")
                    SpacingSlider:SetLabel("Spacing")
                    SpacingSlider:SetValue(DB.Frame.Spacing)
                    SpacingSlider:SetSliderValues(0, 100, 1)
                    SpacingSlider:SetRelativeWidth(0.33)
                    SpacingSlider:SetCallback("OnValueChanged", function(_, _, value)
                        DB.Frame.Spacing = value
                        UUF:LayoutBossFrames()
                    end)
                    UnitFrameContainer:AddChild(SpacingSlider)
                end

                local AnchorFromDropdown = AG:Create("Dropdown")
                AnchorFromDropdown:SetList(AnchorPoints)
                AnchorFromDropdown:SetLabel("Anchor From")
                AnchorFromDropdown:SetValue(DB.Frame.AnchorFrom)
                AnchorFromDropdown:SetRelativeWidth(isBoss and 0.33 or 0.5)
                AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value)
                    DB.Frame.AnchorFrom = value
                    if isBoss then
                        UUF:LayoutBossFrames()
                    else
                        UUF:UpdateUnitFrame(Unit)
                    end
                end)
                UnitFrameContainer:AddChild(AnchorFromDropdown)

                local AnchorToDropdown = AG:Create("Dropdown")
                AnchorToDropdown:SetList(AnchorPoints)
                AnchorToDropdown:SetLabel("Anchor To")
                AnchorToDropdown:SetValue(DB.Frame.AnchorTo)
                AnchorToDropdown:SetRelativeWidth(isBoss and 0.33 or 0.5)
                AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value)
                    DB.Frame.AnchorTo = value
                    if isBoss then
                        UUF:LayoutBossFrames()
                    else
                        UUF:UpdateUnitFrame(Unit)
                    end
                end)
                UnitFrameContainer:AddChild(AnchorToDropdown)

                if isBoss then
                    local GrowthDirectionDropdown = AG:Create("Dropdown")
                    GrowthDirectionDropdown:SetList({
                        ["UP"] = "Up",
                        ["DOWN"] = "Down",
                    })
                    GrowthDirectionDropdown:SetLabel("Growth Direction")
                    GrowthDirectionDropdown:SetValue(DB.Frame.GrowthDirection)
                    GrowthDirectionDropdown:SetRelativeWidth(0.33)
                    GrowthDirectionDropdown:SetCallback("OnValueChanged", function(_, _, value)
                        DB.Frame.GrowthDirection = value
                        UUF:LayoutBossFrames()
                    end)
                    UnitFrameContainer:AddChild(GrowthDirectionDropdown)
                end

                local XPositionSlider = AG:Create("Slider")
                XPositionSlider:SetLabel("X Position")
                XPositionSlider:SetValue(DB.Frame.XPosition)
                XPositionSlider:SetSliderValues(SLIDER_MIN, SLIDER_MAX, SLIDER_STEP)
                XPositionSlider:SetRelativeWidth(0.5)
                XPositionSlider:SetCallback("OnValueChanged", function(_, _, value)
                    DB.Frame.XPosition = value
                    if isBoss then
                        UUF:LayoutBossFrames()
                    else
                        UUF:UpdateUnitFrame(Unit)
                    end
                end)
                UnitFrameContainer:AddChild(XPositionSlider)

                local YPositionSlider = AG:Create("Slider")
                YPositionSlider:SetLabel("Y Position")
                YPositionSlider:SetValue(DB.Frame.YPosition)
                YPositionSlider:SetSliderValues(SLIDER_MIN, SLIDER_MAX, SLIDER_STEP)
                YPositionSlider:SetRelativeWidth(0.5)
                YPositionSlider:SetCallback("OnValueChanged", function(_, _, value)
                    DB.Frame.YPosition = value
                    if isBoss then
                        UUF:LayoutBossFrames()
                    else
                        UUF:UpdateUnitFrame(Unit)
                    end
                end)
                UnitFrameContainer:AddChild(YPositionSlider)
            end

            local function DrawPowerBarContainer()
                local PowerBarDB = DB.PowerBar

                local PowerBarEnabledCheckBox = AG:Create("CheckBox")
                PowerBarEnabledCheckBox:SetLabel("Enable Power Bar")
                PowerBarEnabledCheckBox:SetValue(PowerBarDB.Enabled)
                PowerBarEnabledCheckBox:SetRelativeWidth(0.5)
                PowerBarEnabledCheckBox:SetCallback("OnValueChanged", function(_, _, value)
                    PowerBarDB.Enabled = value
                    UUF:UpdateUnitFrame(Unit)
                    DeepDisable(UnitFrameContainer, not value, PowerBarEnabledCheckBox)
                end)
                UnitFrameContainer:AddChild(PowerBarEnabledCheckBox)

                local PowerBarHeightSlider = AG:Create("Slider")
                PowerBarHeightSlider:SetLabel("Power Bar Height")
                PowerBarHeightSlider:SetValue(PowerBarDB.Height)
                PowerBarHeightSlider:SetSliderValues(1, 100, 1)
                PowerBarHeightSlider:SetRelativeWidth(0.5)
                PowerBarHeightSlider:SetCallback("OnValueChanged", function(_, _, value)
                    PowerBarDB.Height = value
                    UUF:UpdateUnitFrame(Unit)
                end)
                UnitFrameContainer:AddChild(PowerBarHeightSlider)

                local ColourContainer = AG:Create("InlineGroup")
                ColourContainer:SetTitle("Colours")
                ColourContainer:SetLayout("Flow")
                ColourContainer:SetFullWidth(true)
                UnitFrameContainer:AddChild(ColourContainer)

                local ColourByTypeCheckBox = AG:Create("CheckBox")
                ColourByTypeCheckBox:SetLabel("Colour By Power Type")
                ColourByTypeCheckBox:SetValue(PowerBarDB.ColourByType)
                ColourByTypeCheckBox:SetRelativeWidth(0.5)
                ColourByTypeCheckBox:SetCallback("OnValueChanged", function(_, _, value)
                    PowerBarDB.ColourByType = value
                    UUF:UpdateUnitFrame(Unit)
                end)
                ColourContainer:AddChild(ColourByTypeCheckBox)

                local PowerBarFGColourPicker = AG:Create("ColorPicker")
                PowerBarFGColourPicker:SetLabel("Foreground Colour")
                PowerBarFGColourPicker:SetColor(unpack(PowerBarDB.FGColour))
                PowerBarFGColourPicker:SetHasAlpha(true)
                PowerBarFGColourPicker:SetRelativeWidth(0.5)
                PowerBarFGColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a)
                    PowerBarDB.FGColour = {r, g, b, a}
                    UUF:UpdateUnitFrame(Unit)
                end)
                ColourContainer:AddChild(PowerBarFGColourPicker)

                local ColourByBackgroundTypeCheckBox = AG:Create("CheckBox")
                ColourByBackgroundTypeCheckBox:SetLabel("Colour Background By Power Type")
                ColourByBackgroundTypeCheckBox:SetValue(PowerBarDB.ColourBackgroundByType)
                ColourByBackgroundTypeCheckBox:SetRelativeWidth(0.5)
                ColourByBackgroundTypeCheckBox:SetCallback("OnValueChanged", function(_, _, value)
                    PowerBarDB.ColourBackgroundByType = value
                    UUF:UpdateUnitFrame(Unit)
                end)
                ColourContainer:AddChild(ColourByBackgroundTypeCheckBox)

                local PowerBarBGColourPicker = AG:Create("ColorPicker")
                PowerBarBGColourPicker:SetLabel("Background Colour")
                PowerBarBGColourPicker:SetColor(unpack(PowerBarDB.BGColour))
                PowerBarBGColourPicker:SetHasAlpha(true)
                PowerBarBGColourPicker:SetRelativeWidth(0.5)
                PowerBarBGColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a)
                    PowerBarDB.BGColour = {r, g, b, a}
                    UUF:UpdateUnitFrame(Unit)
                end)
                ColourContainer:AddChild(PowerBarBGColourPicker)

                local PowerBarTextContainer = AG:Create("InlineGroup")
                PowerBarTextContainer:SetTitle("Text")
                PowerBarTextContainer:SetLayout("Flow")
                PowerBarTextContainer:SetFullWidth(true)
                UnitFrameContainer:AddChild(PowerBarTextContainer)

                local PowerBarTextEnabledCheckBox = AG:Create("CheckBox")
                PowerBarTextEnabledCheckBox:SetLabel("Enable Power Text")
                PowerBarTextEnabledCheckBox:SetValue(PowerBarDB.Text.Enabled)
                PowerBarTextEnabledCheckBox:SetRelativeWidth(1)
                PowerBarTextEnabledCheckBox:SetCallback("OnValueChanged", function(_, _, value)
                    PowerBarDB.Text.Enabled = value
                    UUF:UpdateUnitFrame(Unit)
                    DeepDisable(PowerBarTextContainer, not value, PowerBarTextEnabledCheckBox)
                end)
                PowerBarTextContainer:AddChild(PowerBarTextEnabledCheckBox)

                local PowerBarTextColourByTypeCheckBox = AG:Create("CheckBox")
                PowerBarTextColourByTypeCheckBox:SetLabel("Colour Text By Power Type")
                PowerBarTextColourByTypeCheckBox:SetValue(PowerBarDB.Text.ColourByType)
                PowerBarTextColourByTypeCheckBox:SetRelativeWidth(0.33)
                PowerBarTextColourByTypeCheckBox:SetCallback("OnValueChanged", function(_, _, value)
                    PowerBarDB.Text.ColourByType = value
                    UUF:UpdateUnitFrame(Unit)
                end)
                PowerBarTextContainer:AddChild(PowerBarTextColourByTypeCheckBox)

                local PowerBarTextColourColourPicker = AG:Create("ColorPicker")
                PowerBarTextColourColourPicker:SetLabel("Text Colour")
                PowerBarTextColourColourPicker:SetColor(unpack(PowerBarDB.Text.Colour))
                PowerBarTextColourColourPicker:SetHasAlpha(true)
                PowerBarTextColourColourPicker:SetRelativeWidth(0.33)
                PowerBarTextColourColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a)
                    PowerBarDB.Text.Colour = {r, g, b, a}
                    UUF:UpdateUnitFrame(Unit)
                end)
                PowerBarTextContainer:AddChild(PowerBarTextColourColourPicker)

                local PowerBarTextAnchorParentDropdown = AG:Create("Dropdown")
                PowerBarTextAnchorParentDropdown:SetList({
                    ["POWER"] = "Power Bar",
                    ["FRAME"] = "Unit Frame",
                })
                PowerBarTextAnchorParentDropdown:SetLabel("Anchor Parent")
                PowerBarTextAnchorParentDropdown:SetValue(PowerBarDB.Text.AnchorParent)
                PowerBarTextAnchorParentDropdown:SetRelativeWidth(0.33)
                PowerBarTextAnchorParentDropdown:SetCallback("OnValueChanged", function(_, _, value)
                    PowerBarDB.Text.AnchorParent = value
                    UUF:UpdateUnitFrame(Unit)
                end)
                PowerBarTextContainer:AddChild(PowerBarTextAnchorParentDropdown)

                local PowerBarTextAnchorFromDropdown = AG:Create("Dropdown")
                PowerBarTextAnchorFromDropdown:SetList(AnchorPoints)
                PowerBarTextAnchorFromDropdown:SetLabel("Anchor From")
                PowerBarTextAnchorFromDropdown:SetValue(PowerBarDB.Text.AnchorFrom)
                PowerBarTextAnchorFromDropdown:SetRelativeWidth(0.5)
                PowerBarTextAnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value)
                    PowerBarDB.Text.AnchorFrom = value
                    UUF:UpdateUnitFrame(Unit)
                end)
                PowerBarTextContainer:AddChild(PowerBarTextAnchorFromDropdown)

                local PowerBarTextAnchorToDropdown = AG:Create("Dropdown")
                PowerBarTextAnchorToDropdown:SetList(AnchorPoints)
                PowerBarTextAnchorToDropdown:SetLabel("Anchor To")
                PowerBarTextAnchorToDropdown:SetValue(PowerBarDB.Text.AnchorTo)
                PowerBarTextAnchorToDropdown:SetRelativeWidth(0.5)
                PowerBarTextAnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value)
                    PowerBarDB.Text.AnchorTo = value
                    UUF:UpdateUnitFrame(Unit)
                end)
                PowerBarTextContainer:AddChild(PowerBarTextAnchorToDropdown)

                local PowerBarTextOffsetXSlider = AG:Create("Slider")
                PowerBarTextOffsetXSlider:SetLabel("Offset X")
                PowerBarTextOffsetXSlider:SetValue(PowerBarDB.Text.OffsetX)
                PowerBarTextOffsetXSlider:SetSliderValues(SLIDER_MIN, SLIDER_MAX, SLIDER_STEP)
                PowerBarTextOffsetXSlider:SetRelativeWidth(0.33)
                PowerBarTextOffsetXSlider:SetCallback("OnValueChanged", function(_, _, value)
                    PowerBarDB.Text.OffsetX = value
                    UUF:UpdateUnitFrame(Unit)
                end)
                PowerBarTextContainer:AddChild(PowerBarTextOffsetXSlider)

                local PowerBarTextOffsetYSlider = AG:Create("Slider")
                PowerBarTextOffsetYSlider:SetLabel("Offset Y")
                PowerBarTextOffsetYSlider:SetValue(PowerBarDB.Text.OffsetY)
                PowerBarTextOffsetYSlider:SetSliderValues(SLIDER_MIN, SLIDER_MAX, SLIDER_STEP)
                PowerBarTextOffsetYSlider:SetRelativeWidth(0.33)
                PowerBarTextOffsetYSlider:SetCallback("OnValueChanged", function(_, _, value)
                    PowerBarDB.Text.OffsetY = value
                    UUF:UpdateUnitFrame(Unit)
                end)
                PowerBarTextContainer:AddChild(PowerBarTextOffsetYSlider)

                local PowerBarTextFontSizeSlider = AG:Create("Slider")
                PowerBarTextFontSizeSlider:SetLabel("Font Size")
                PowerBarTextFontSizeSlider:SetValue(PowerBarDB.Text.FontSize)
                PowerBarTextFontSizeSlider:SetSliderValues(6, 40, 1)
                PowerBarTextFontSizeSlider:SetRelativeWidth(0.33)
                PowerBarTextFontSizeSlider:SetCallback("OnValueChanged", function(_, _, value)
                    PowerBarDB.Text.FontSize = value
                    UUF:UpdateUnitFrame(Unit)
                end)
                PowerBarTextContainer:AddChild(PowerBarTextFontSizeSlider)

                DeepDisable(UnitFrameContainer, not PowerBarDB.Enabled, PowerBarEnabledCheckBox)
                DeepDisable(PowerBarTextContainer, not PowerBarDB.Text.Enabled, PowerBarTextEnabledCheckBox)
            end

            local function DrawTextsContainer()
                local TagsDB = DB.Tags
                local TagOneDB = TagsDB.TagOne
                local TagTwoDB = TagsDB.TagTwo
                local TagThreeDB = TagsDB.TagThree

                local TagInfoTag = CreateInfoTag("Tags are limited to one per field.")
                TagInfoTag:SetRelativeWidth(1)
                UnitFrameContainer:AddChild(TagInfoTag)

                local function TagOptions(parentContainer, TagDB, TagName)
                    local TagEditBox = AG:Create("EditBox")
                    TagEditBox:SetLabel("Tag")
                    TagEditBox:SetText(TagDB.Tag)
                    TagEditBox:SetRelativeWidth(0.5)
                    TagEditBox:SetCallback("OnEnterPressed", function(_, _, value) TagDB.Tag = value UUF:UpdateUnitFrame(Unit) end)
                    parentContainer:AddChild(TagEditBox)

                    local ColourPicker = AG:Create("ColorPicker")
                    ColourPicker:SetLabel("Colour")
                    ColourPicker:SetColor(unpack(TagDB.Colour))
                    ColourPicker:SetHasAlpha(true)
                    ColourPicker:SetRelativeWidth(0.5)
                    ColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) TagDB.Colour = {r, g, b, a} UUF:UpdateUnitFrame(Unit) end)
                    parentContainer:AddChild(ColourPicker)

                    local AnchorFromDropdown = AG:Create("Dropdown")
                    AnchorFromDropdown:SetList(AnchorPoints)
                    AnchorFromDropdown:SetLabel("Anchor From")
                    AnchorFromDropdown:SetValue(TagDB.AnchorFrom)
                    AnchorFromDropdown:SetRelativeWidth(0.5)
                    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) TagDB.AnchorFrom = value UUF:UpdateUnitFrame(Unit) end)
                    parentContainer:AddChild(AnchorFromDropdown)

                    local AnchorToDropdown = AG:Create("Dropdown")
                    AnchorToDropdown:SetList(AnchorPoints)
                    AnchorToDropdown:SetLabel("Anchor To")
                    AnchorToDropdown:SetValue(TagDB.AnchorTo)
                    AnchorToDropdown:SetRelativeWidth(0.5)
                    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) TagDB.AnchorTo = value UUF:UpdateUnitFrame(Unit) end)
                    parentContainer:AddChild(AnchorToDropdown)

                    local OffsetXSlider = AG:Create("Slider")
                    OffsetXSlider:SetLabel("Offset X")
                    OffsetXSlider:SetValue(TagDB.OffsetX)
                    OffsetXSlider:SetSliderValues(SLIDER_MIN, SLIDER_MAX, SLIDER_STEP)
                    OffsetXSlider:SetRelativeWidth(0.33)
                    OffsetXSlider:SetCallback("OnValueChanged", function(_, _, value) TagDB.OffsetX = value UUF:UpdateUnitFrame(Unit) end)
                    parentContainer:AddChild(OffsetXSlider)

                    local OffsetYSlider = AG:Create("Slider")
                    OffsetYSlider:SetLabel("Offset Y")
                    OffsetYSlider:SetValue(TagDB.OffsetY)
                    OffsetYSlider:SetSliderValues(SLIDER_MIN, SLIDER_MAX, SLIDER_STEP)
                    OffsetYSlider:SetRelativeWidth(0.33)
                    OffsetYSlider:SetCallback("OnValueChanged", function(_, _, value) TagDB.OffsetY = value UUF:UpdateUnitFrame(Unit) end)
                    parentContainer:AddChild(OffsetYSlider)

                    local FontSizeSlider = AG:Create("Slider")
                    FontSizeSlider:SetLabel("Font Size")
                    FontSizeSlider:SetValue(TagDB.FontSize)
                    FontSizeSlider:SetSliderValues(6, 72, 1)
                    FontSizeSlider:SetRelativeWidth(0.33)
                    FontSizeSlider:SetCallback("OnValueChanged", function(_, _, value) TagDB.FontSize = value UUF:UpdateUnitFrame(Unit) end)
                    parentContainer:AddChild(FontSizeSlider)
                end

                local TagOneContainer = AG:Create("InlineGroup")
                TagOneContainer:SetTitle("Tag One")
                TagOneContainer:SetLayout("Flow")
                TagOneContainer:SetFullWidth(true)
                UnitFrameContainer:AddChild(TagOneContainer)
                TagOptions(TagOneContainer, TagOneDB, "TagOne")

                local TagTwoContainer = AG:Create("InlineGroup")
                TagTwoContainer:SetTitle("Tag Two")
                TagTwoContainer:SetLayout("Flow")
                TagTwoContainer:SetFullWidth(true)
                UnitFrameContainer:AddChild(TagTwoContainer)
                TagOptions(TagTwoContainer, TagTwoDB, "TagTwo")

                local TagThreeContainer = AG:Create("InlineGroup")
                TagThreeContainer:SetTitle("Tag Three")
                TagThreeContainer:SetLayout("Flow")
                TagThreeContainer:SetFullWidth(true)
                UnitFrameContainer:AddChild(TagThreeContainer)
                TagOptions(TagThreeContainer, TagThreeDB, "TagThree")

                ScrollFrame:DoLayout()
            end

            local function DrawIndicatorsContainer()
                local IndicatorsDB = DB.Indicators

                local MouseoverHighlightContainer = AG:Create("InlineGroup")
                MouseoverHighlightContainer:SetTitle("Mouseover Highlight")
                MouseoverHighlightContainer:SetLayout("Flow")
                MouseoverHighlightContainer:SetFullWidth(true)
                UnitFrameContainer:AddChild(MouseoverHighlightContainer)

                local MouseoverHighlightEnabledCheckBox = AG:Create("CheckBox")
                MouseoverHighlightEnabledCheckBox:SetLabel("Enable Mouseover Highlight")
                MouseoverHighlightEnabledCheckBox:SetValue(IndicatorsDB.MouseoverHighlight.Enabled)
                MouseoverHighlightEnabledCheckBox:SetRelativeWidth(0.5)
                MouseoverHighlightEnabledCheckBox:SetCallback("OnValueChanged", function(_, _, value)
                    IndicatorsDB.MouseoverHighlight.Enabled = value
                    UUF:UpdateUnitFrame(Unit)
                    DeepDisable(MouseoverHighlightContainer, not value, MouseoverHighlightEnabledCheckBox)
                end)
                MouseoverHighlightContainer:AddChild(MouseoverHighlightEnabledCheckBox)

                local MouseoverHighlightColourPicker = AG:Create("ColorPicker")
                MouseoverHighlightColourPicker:SetLabel("Highlight Colour")
                MouseoverHighlightColourPicker:SetColor(unpack(IndicatorsDB.MouseoverHighlight.Colour))
                MouseoverHighlightColourPicker:SetHasAlpha(true)
                MouseoverHighlightColourPicker:SetRelativeWidth(0.5)
                MouseoverHighlightColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a)
                    IndicatorsDB.MouseoverHighlight.Colour = {r, g, b, a}
                    UUF:UpdateUnitFrame(Unit)
                end)
                MouseoverHighlightContainer:AddChild(MouseoverHighlightColourPicker)
            end

            if ModuleGroup == "Colours" then
                DrawColourContainer()
            elseif ModuleGroup == "Frame" then
                DrawFrameContainer()
            elseif ModuleGroup == "PowerBar" then
                if Unit ~= "pet" and Unit ~= "focus" then
                    DrawPowerBarContainer()
                end
            elseif ModuleGroup == "Texts" then
                DrawTextsContainer()
            elseif ModuleGroup == "Indicators" then
                DrawIndicatorsContainer()
            end
        end

        local ModuleTabGroup = AG:Create("TabGroup")
        ModuleTabGroup:SetLayout("Flow")
        ModuleTabGroup:SetFullWidth(true)
        if Unit ~= "pet" and Unit ~= "focus" then
            ModuleTabGroup:SetTabs({
                { text = "Colours", value = "Colours"},
                { text = "Frame", value = "Frame"},
                { text = "Power Bar", value = "PowerBar"},
                { text = "Texts", value = "Texts"},
                { text = "Indicators", value = "Indicators"},
            })
        else
            ModuleTabGroup:SetTabs({
                { text = "Colours", value = "Colours"},
                { text = "Frame", value = "Frame"},
                { text = "Texts", value = "Texts"},
                { text = "Indicators", value = "Indicators"},
            })
        end
        ModuleTabGroup:SetCallback("OnGroupSelected", SelectedModuleGroup)
        ModuleTabGroup:SelectTab("Colours")
        ScrollFrame:AddChild(ModuleTabGroup)

    end

        local function DrawTagsContainer(Container)
            local ScrollFrame = AG:Create("ScrollFrame")
            ScrollFrame:SetLayout("Flow")
            ScrollFrame:SetFullWidth(true)
            ScrollFrame:SetFullHeight(true)
            Container:AddChild(ScrollFrame)

            local HealthSeparatorDropdown = AG:Create("Dropdown")
            HealthSeparatorDropdown:SetList({
                ["-"] = "-",
                ["||"] = "|",
                ["/"] = "/",
            })
            HealthSeparatorDropdown:SetLabel("Health Separator")
            HealthSeparatorDropdown:SetValue(UUF.db.profile.General.HealthSeparator)
            HealthSeparatorDropdown:SetRelativeWidth(1)
            HealthSeparatorDropdown:SetCallback("OnValueChanged", function(_, _, value) UUF.HealthSeparator = value UUF.db.profile.General.HealthSeparator = value for unit in pairs(UnitToFrameName) do UUF:UpdateUnitFrame(unit) end end)
            ScrollFrame:AddChild(HealthSeparatorDropdown)

            local function DrawTagContainer(TagContainer, tagGroup)
                local TagsList = UUF:GetTagsForGroup(tagGroup)
                for Tag, Desc in pairs(TagsList) do
                    local TagDesc = AG:Create("Heading")
                    TagDesc:SetText(Desc)
                    TagDesc:SetFullWidth(true)
                    TagContainer:AddChild(TagDesc)

                    local TagValue = AG:Create("EditBox")
                    TagValue:SetText("[" .. Tag .. "]")
                    TagValue:SetCallback("OnTextChanged", function(widget, event, value)
                        TagValue:ClearFocus()
                        TagValue:SetText("[" .. Tag .. "]")
                    end)
                    TagValue:SetRelativeWidth(1)
                    TagContainer:AddChild(TagValue)

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
                end
                ScrollFrame:DoLayout()
            end

            local GUIContainerTabGroup = AG:Create("TabGroup")
            GUIContainerTabGroup:SetLayout("Flow")
            GUIContainerTabGroup:SetTabs({
                { text = "Health", value = "Health" },
                { text = "Name", value = "Name" },
                { text = "Power", value = "Power" },
            })
            GUIContainerTabGroup:SetCallback("OnGroupSelected", SelectedGroup)
            GUIContainerTabGroup:SelectTab("Health")
            GUIContainerTabGroup:SetFullWidth(true)
            ScrollFrame:AddChild(GUIContainerTabGroup)
            ScrollFrame:DoLayout()
        end

    local function DrawProfilesContainer(Container)
        local ScrollFrame = AG:Create("ScrollFrame")
        ScrollFrame:SetLayout("Flow")
        ScrollFrame:SetFullWidth(true)
        ScrollFrame:SetFullHeight(true)
        Container:AddChild(ScrollFrame)

        local ProfileContainer = AG:Create("InlineGroup")
        ProfileContainer:SetTitle("Profiles")
        ProfileContainer:SetLayout("Flow")
        ProfileContainer:SetFullWidth(true)
        ScrollFrame:AddChild(ProfileContainer)

        local ActiveProfileHeading = AG:Create("Heading")
        ActiveProfileHeading:SetFullWidth(true)
        ProfileContainer:AddChild(ActiveProfileHeading)

        local profileKeys = {}
        local function RefreshProfiles()
            wipe(profileKeys)
            local tmp = {}
            for _, name in ipairs(UUF.db:GetProfiles(tmp, true)) do
                profileKeys[name] = name
            end
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
        SelectProfileDropdown:SetCallback("OnValueChanged", function(_, _, value)
            UUF.db:SetProfile(value)
            UIParent:SetScale(UUF.db.profile.General.UIScale or 1)
            for unit in pairs(UnitToFrameName) do
                UUF:UpdateUnitFrame(unit)
            end
            RefreshProfiles()
        end)
        ProfileContainer:AddChild(SelectProfileDropdown)

        CopyFromProfileDropdown = AG:Create("Dropdown")
        CopyFromProfileDropdown:SetLabel("Copy From...")
        CopyFromProfileDropdown:SetRelativeWidth(0.25)
        CopyFromProfileDropdown:SetCallback("OnValueChanged", function(_, _, value)
            UUF:CreatePrompt("Copy Profile", "Are you sure you want to copy from |cFF8080FF" .. value .. "|r?\nThis will |cFFFF4040overwrite|r your current profile settings.", function()
                UUF.db:CopyProfile(value)
                UIParent:SetScale(UUF.db.profile.General.UIScale or 1)
                for unit in pairs(UnitToFrameName) do
                    UUF:UpdateUnitFrame(unit)
                end
                RefreshProfiles()
            end)
        end)
        ProfileContainer:AddChild(CopyFromProfileDropdown)

        DeleteProfileDropdown = AG:Create("Dropdown")
        DeleteProfileDropdown:SetLabel("Delete...")
        DeleteProfileDropdown:SetRelativeWidth(0.25)
        DeleteProfileDropdown:SetCallback("OnValueChanged", function(_, _, value)
            if value ~= UUF.db:GetCurrentProfile() then
                UUF:CreatePrompt("Delete Profile", "Are you sure you want to delete |cFF8080FF" .. value .. "|r?", function()
                    UUF.db:DeleteProfile(value)
                    RefreshProfiles()
                end)
            end
        end)
        ProfileContainer:AddChild(DeleteProfileDropdown)

        local ResetProfileButton = AG:Create("Button")
        ResetProfileButton:SetText("Reset Current Profile")
        ResetProfileButton:SetRelativeWidth(0.25)
        ResetProfileButton:SetCallback("OnClick", function()
            UUF.db:ResetProfile()
            UUF:ResolveMedia()
            for unit in pairs(UnitToFrameName) do
                UUF:UpdateUnitFrame(unit)
            end
            UIParent:SetScale(UUF.db.profile.General.UIScale or 1)
            RefreshProfiles()
        end)
        ProfileContainer:AddChild(ResetProfileButton)

        local CreateProfileEditBox = AG:Create("EditBox")
        CreateProfileEditBox:SetLabel("Create Profile...")
        CreateProfileEditBox:SetText("")
        CreateProfileEditBox:SetRelativeWidth(0.5)
        CreateProfileEditBox:DisableButton(true)
        CreateProfileEditBox:SetCallback("OnEnterPressed", function() CreateProfileEditBox:ClearFocus() end)
        ProfileContainer:AddChild(CreateProfileEditBox)

        local CreateProfileButton = AG:Create("Button")
        CreateProfileButton:SetText("Create Profile")
        CreateProfileButton:SetRelativeWidth(0.5)
        CreateProfileButton:SetCallback("OnClick", function()
            local profileName = strtrim(CreateProfileEditBox:GetText() or "")
            if profileName ~= "" then
                UUF.db:SetProfile(profileName)
                UIParent:SetScale(UUF.db.profile.General.UIScale or 1)
                for unit in pairs(UnitToFrameName) do
                    UUF:UpdateUnitFrame(unit)
                end
                RefreshProfiles()
                CreateProfileEditBox:SetText("")
            end
        end)
        ProfileContainer:AddChild(CreateProfileButton)

        local GlobalProfileHeading = AG:Create("Heading")
        GlobalProfileHeading:SetText("Global Profile Settings")
        GlobalProfileHeading:SetFullWidth(true)
        ProfileContainer:AddChild(GlobalProfileHeading)

        local GlobalProfileInfoTag = CreateInfoTag("If |cFF8080FFUse Global Profile Settings|r is enabled, the profile selected below will be used as your active profile.\nThis is useful if you want to use the same profile across multiple characters.")
        GlobalProfileInfoTag:SetFullWidth(true)
        ProfileContainer:AddChild(GlobalProfileInfoTag)

        local UseGlobalProfileToggle = AG:Create("CheckBox")
        local GlobalProfileDropdown = AG:Create("Dropdown")
        UseGlobalProfileToggle:SetLabel("Use Global Profile Settings")
        UseGlobalProfileToggle:SetValue(UUF.db.global.UseGlobalProfile)
        UseGlobalProfileToggle:SetRelativeWidth(0.5)
        UseGlobalProfileToggle:SetCallback("OnValueChanged", function(_, _, value)
            UUF.db.global.UseGlobalProfile = value

            if value and UUF.db.global.GlobalProfile and UUF.db.global.GlobalProfile ~= "" then
                UUF.db:SetProfile(UUF.db.global.GlobalProfile)
                UIParent:SetScale(UUF.db.profile.General.UIScale or 1)
                for unit in pairs(UnitToFrameName) do
                    UUF:UpdateUnitFrame(unit)
                end
            end

            GlobalProfileDropdown:SetDisabled(not value)

            for _, child in ipairs(ProfileContainer.children) do
                if child ~= UseGlobalProfileToggle and child ~= GlobalProfileDropdown then
                    DeepDisable(child, value)
                end
            end

            RefreshProfiles()
        end)
        ProfileContainer:AddChild(UseGlobalProfileToggle)

        RefreshProfiles()

        GlobalProfileDropdown:SetLabel("Global Profile...")
        GlobalProfileDropdown:SetRelativeWidth(0.5)
        GlobalProfileDropdown:SetList(profileKeys)
        GlobalProfileDropdown:SetValue(UUF.db.global.GlobalProfile)
        GlobalProfileDropdown:SetCallback("OnValueChanged", function(_, _, value)
            UUF.db:SetProfile(value)
            UUF.db.global.GlobalProfile = value
            UIParent:SetScale(UUF.db.profile.General.UIScale or 1)
            for unit in pairs(UnitToFrameName) do
                UUF:UpdateUnitFrame(unit)
            end
            RefreshProfiles()
        end)
        ProfileContainer:AddChild(GlobalProfileDropdown)

        ProfileContainer:DoLayout()

        local SharingContainer = AG:Create("InlineGroup")
        SharingContainer:SetTitle("Sharing")
        SharingContainer:SetLayout("Flow")
        SharingContainer:SetFullWidth(true)
        ScrollFrame:AddChild(SharingContainer)

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
        ImportProfileButton:SetCallback("OnClick", function() UUF:ImportSavedVariables(ImportingEditBox:GetText()) ImportingEditBox:SetText("") end)
        SharingContainer:AddChild(ImportProfileButton)

        GlobalProfileDropdown:SetDisabled(not UUF.db.global.UseGlobalProfile)

        if UUF.db.global.UseGlobalProfile then
            for _, child in ipairs(ProfileContainer.children) do
                if child ~= UseGlobalProfileToggle and child ~= GlobalProfileDropdown then
                    DeepDisable(child, true)
                end
            end
        end
        SharingContainer:DoLayout()
        ScrollFrame:DoLayout()
    end

    local function SelectedGroup(GUIContainer, _, MainGroup)
        GUIContainer:ReleaseChildren()
        if MainGroup == "General" then
            DrawGeneralContainer(GUIContainer)
        elseif MainGroup == "player" then
            DrawUnitFrameContainer(GUIContainer, "player")
        elseif MainGroup == "target" then
            DrawUnitFrameContainer(GUIContainer, "target")
        elseif MainGroup == "targettarget" then
            DrawUnitFrameContainer(GUIContainer, "targettarget")
        elseif MainGroup == "pet" then
            DrawUnitFrameContainer(GUIContainer, "pet")
        elseif MainGroup == "focus" then
            DrawUnitFrameContainer(GUIContainer, "focus")
        elseif MainGroup == "boss" then
            DrawUnitFrameContainer(GUIContainer, "boss")
        elseif MainGroup == "Tags" then
            DrawTagsContainer(GUIContainer)
        elseif MainGroup == "Profiles" then
            DrawProfilesContainer(GUIContainer)
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