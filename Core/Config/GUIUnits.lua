local _, UUF = ...
local AG = UUF.AG
local GUIWidgets = UUF.GUIWidgets

local GUIUnits = {}
UUF.GUIUnits = GUIUnits

-- ============================== HELPER TABLES ==============================

-- Anchor points (9 positions)
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

-- Frame strata (8 levels)
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

-- Status textures for indicator indicators (Combat & Resting)
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
    },
}

-- Unit name mapping for UI display
local UnitDBToUnitPrettyName = {
    player = "Player",
    target = "Target",
    targettarget = "Target of Target",
    focus = "Focus",
    focustarget = "Focus Target",
    pet = "Pet",
    party = "Party",
    boss = "Boss",
}

-- Tab state tracking
local lastSelectedUnitTabs = {}

-- ============================== HELPER FUNCTIONS ==============================

-- Save a subtab selection for a unit
local function SaveSubTab(unit, tabName, subTabValue)
    if not lastSelectedUnitTabs[unit] then lastSelectedUnitTabs[unit] = {} end
    if not lastSelectedUnitTabs[unit].subTabs then lastSelectedUnitTabs[unit].subTabs = {} end
    lastSelectedUnitTabs[unit].subTabs[tabName] = subTabValue
end

-- Retrieve a saved subtab selection (with default fallback)
local function GetSavedSubTab(unit, tabName, defaultValue)
    return lastSelectedUnitTabs[unit] and lastSelectedUnitTabs[unit].subTabs and lastSelectedUnitTabs[unit].subTabs[tabName] or defaultValue
end

-- Wrapper for updating unit frames (handles boss/party multi-frame logic)
local function UpdateMultiFrameUnit(unit, updateFunc)
    if unit == "boss" then
        UUF:UpdateBossFrames()
    elseif unit == "party" then
        UUF:UpdatePartyFrames()
    else
        updateFunc()
    end
end

-- Update a specific tag for all frames in a multi-frame unit group
local function UpdateTagForMultiFrameUnit(unit, tagDB)
    if unit == "boss" then
        for i = 1, 5 do
            local bossFrame = UUF["BOSS"..i]
            if bossFrame then
                UUF:UpdateUnitTag(bossFrame, "boss"..i, tagDB)
            end
        end
        UUF:LayoutBossFrames()
    elseif unit == "party" then
        for i in pairs(UUF.PARTY_FRAMES or {}) do
            local partyFrame = UUF["PARTY"..i]
            if partyFrame then
                UUF:UpdateUnitTag(partyFrame, "party"..i, tagDB)
            end
        end
        UUF:LayoutPartyFrames()
    else
        local frame = UUF[unit:upper()]
        if frame then
            UUF:UpdateUnitTag(frame, unit, tagDB)
        end
    end
end

-- ============================== PUBLIC MODULE FUNCTIONS ==============================

-- Main unit settings panel builder (core enable/disable + unit-specific options)
function GUIUnits:BuildUnitSettingsPanel(containerParent, unit)
    local UnitDB = UUF.db.profile.Units[unit]

    -- Enable toggle
    local EnableToggle = AG:Create("CheckBox")
    EnableToggle:SetLabel("Enable |cFFFFCC00" .. (UnitDBToUnitPrettyName[unit] or unit) .. "|r")
    EnableToggle:SetValue(UnitDB.Enabled)
    EnableToggle:SetCallback("OnValueChanged", function(_, _, value)
        StaticPopupDialogs["UUF_RELOAD_UI"] = {
            text = "You must reload UI to apply this change. Reload now?",
            button1 = "Reload",
            button2 = "Later",
            showAlert = true,
            OnAccept = function()
                UnitDB.Enabled = value
                C_UI.Reload()
            end,
            OnCancel = function()
                EnableToggle:SetValue(UnitDB.Enabled)
                containerParent:DoLayout()
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
        }
        StaticPopup_Show("UUF_RELOAD_UI")
    end)
    EnableToggle:SetRelativeWidth(0.5)
    containerParent:AddChild(EnableToggle)

    -- Hide Blizzard frames toggle
    local HideBlizzardToggle = AG:Create("CheckBox")
    HideBlizzardToggle:SetLabel("Hide Blizzard |cFFFFCC00" .. (UnitDBToUnitPrettyName[unit] or unit) .. "|r")
    HideBlizzardToggle:SetValue(UnitDB.ForceHideBlizzard)
    HideBlizzardToggle:SetCallback("OnValueChanged", function(_, _, value)
        StaticPopupDialogs["UUF_RELOAD_UI"] = {
            text = "You must reload UI to apply this change. Reload now?",
            button1 = "Reload",
            button2 = "Later",
            showAlert = true,
            OnAccept = function()
                UnitDB.ForceHideBlizzard = value
                C_UI.Reload()
            end,
            OnCancel = function()
                HideBlizzardToggle:SetValue(UnitDB.ForceHideBlizzard)
                containerParent:DoLayout()
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
        }
        StaticPopup_Show("UUF_RELOAD_UI")
    end)
    HideBlizzardToggle:SetRelativeWidth(0.5)
    HideBlizzardToggle:SetDisabled(not UnitDB.Enabled)
    containerParent:AddChild(HideBlizzardToggle)

    -- Party-specific options
    if unit == "party" then
        local HidePlayerToggle = AG:Create("CheckBox")
        HidePlayerToggle:SetLabel("Hide |cFFFFCC00Player|r in Party Frames")
        HidePlayerToggle:SetValue(UnitDB.HidePlayer)
        HidePlayerToggle:SetCallback("OnValueChanged", function(_, _, value)
            UnitDB.HidePlayer = value
            UUF:LayoutPartyFrames()
        end)
        HidePlayerToggle:SetRelativeWidth(0.5)
        containerParent:AddChild(HidePlayerToggle)

        local SortOrderDropdown = AG:Create("Dropdown")
        SortOrderDropdown:SetLabel("Sort Order")
        SortOrderDropdown:SetList({
            ["DEFAULT"] = "Default",
            ["ROLE"] = "By Role (Tank > Healer > DPS)"
        })
        SortOrderDropdown:SetValue(UnitDB.SortOrder or "DEFAULT")
        SortOrderDropdown:SetCallback("OnValueChanged", function(_, _, value)
            UnitDB.SortOrder = value
            UUF:LayoutPartyFrames()
        end)
        SortOrderDropdown:SetRelativeWidth(0.5)
        containerParent:AddChild(SortOrderDropdown)
    end

    containerParent:DoLayout()
end

-- ============================== STUB FUNCTIONS FOR FUTURE EXTRACTION ==============================
-- These stubs represent the 23 per-unit configuration functions that need extraction from GUI.lua
-- They will be implemented incrementally, pulling functions from GUI.lua with full helper preservation

-- Frame Settings (width, height, anchor, color, dispel highlighting)
function GUIUnits:CreateFrameSettings(containerParent, unit, unitHasParent, updateCallback)
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

    if unit == "party" then
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

    if unit == "boss" or unit == "party" then
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

    local ForegroundColourByClassToggle = AG:Create("CheckBox")
    ForegroundColourByClassToggle:SetLabel("Colour by Class / Reaction")
    ForegroundColourByClassToggle:SetValue(HealthBarDB.ColourByClass)
    ForegroundColourByClassToggle:SetCallback("OnValueChanged", function(_, _, value) HealthBarDB.ColourByClass = value ForegroundColourPicker:SetDisabled(HealthBarDB.ColourByClass) updateCallback() end)
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

    local BackgroundColourByClassToggle = AG:Create("CheckBox")
    BackgroundColourByClassToggle:SetLabel("Colour by Class / Reaction")
    BackgroundColourByClassToggle:SetValue(HealthBarDB.ColourBackgroundByClass)
    BackgroundColourByClassToggle:SetCallback("OnValueChanged", function(_, _, value) HealthBarDB.ColourBackgroundByClass = value BackgroundColourPicker:SetDisabled(HealthBarDB.ColourBackgroundByClass) updateCallback() end)
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
end

-- Heal Prediction Settings (absorbs, heal absorbs)
function GUIUnits:CreateHealPredictionSettings(containerParent, unit, updateCallback)
    local FrameDB = UUF.db.profile.Units[unit].Frame
    local HealPredictionDB = UUF.db.profile.Units[unit].HealPrediction

    HealPredictionDB.Absorbs.ShowGlow = HealPredictionDB.Absorbs.ShowGlow ~= false
    HealPredictionDB.Absorbs.OverlayOpacity = HealPredictionDB.Absorbs.OverlayOpacity or 0.5
    HealPredictionDB.HealAbsorbs.ShowGlow = HealPredictionDB.HealAbsorbs.ShowGlow ~= false
    HealPredictionDB.HealAbsorbs.OverlayOpacity = HealPredictionDB.HealAbsorbs.OverlayOpacity or 0.5

    if not HealPredictionDB.IncomingHeals then
        HealPredictionDB.IncomingHeals = {
            Enabled = true,
            Split = true,
            ColourAll = {0/255, 255/255, 0/255, 0.25},
            ColourPlayer = {0/255, 255/255, 0/255, 0.4},
            ColourOther = {0/255, 179/255, 0/255, 0.3},
            Position = "ATTACH",
            Height = FrameDB.Height - 2,
            Overflow = 1.05,
        }
    end

    local AbsorbSettings = GUIWidgets.CreateInlineGroup(containerParent, "Absorb Settings")

    local ShowAbsorbToggle = AG:Create("CheckBox")
    ShowAbsorbToggle:SetLabel("Show Absorbs")
    ShowAbsorbToggle:SetValue(HealPredictionDB.Absorbs.Enabled)
    ShowAbsorbToggle:SetCallback("OnValueChanged", function(_, _, value) HealPredictionDB.Absorbs.Enabled = value updateCallback() RefreshHealPredictionSettings() end)
    ShowAbsorbToggle:SetRelativeWidth(0.5)
    AbsorbSettings:AddChild(ShowAbsorbToggle)

    local ShowAbsorbGlowToggle = AG:Create("CheckBox")
    ShowAbsorbGlowToggle:SetLabel("Show Over-Absorb Glow")
    ShowAbsorbGlowToggle:SetValue(HealPredictionDB.Absorbs.ShowGlow)
    ShowAbsorbGlowToggle:SetCallback("OnValueChanged", function(_, _, value) HealPredictionDB.Absorbs.ShowGlow = value updateCallback() end)
    ShowAbsorbGlowToggle:SetRelativeWidth(0.5)
    AbsorbSettings:AddChild(ShowAbsorbGlowToggle)

    local AbsorbOverlayOpacitySlider = AG:Create("Slider")
    AbsorbOverlayOpacitySlider:SetLabel("Overlay Opacity")
    AbsorbOverlayOpacitySlider:SetValue(HealPredictionDB.Absorbs.OverlayOpacity)
    AbsorbOverlayOpacitySlider:SetSliderValues(0, 1, 0.01)
    AbsorbOverlayOpacitySlider:SetRelativeWidth(0.5)
    AbsorbOverlayOpacitySlider:SetCallback("OnValueChanged", function(_, _, value) HealPredictionDB.Absorbs.OverlayOpacity = value updateCallback() end)
    AbsorbOverlayOpacitySlider:SetIsPercent(true)
    AbsorbSettings:AddChild(AbsorbOverlayOpacitySlider)

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

    HealPredictionDB.Absorbs.Texture = HealPredictionDB.Absorbs.Texture or "Blizzard"
    local LSM = LibStub("LibSharedMedia-3.0")
    local textureList = LSM:HashTable("statusbar")
    local textureOrder = {}
    for name in pairs(textureList) do
        table.insert(textureOrder, name)
    end
    table.sort(textureOrder)
    local textureMap = {}
    for _, name in ipairs(textureOrder) do
        textureMap[name] = name
    end

    local AbsorbTextureDropdown = AG:Create("Dropdown")
    AbsorbTextureDropdown:SetLabel("Texture")
    AbsorbTextureDropdown:SetList(textureMap, textureOrder)
    AbsorbTextureDropdown:SetValue(HealPredictionDB.Absorbs.Texture)
    AbsorbTextureDropdown:SetRelativeWidth(0.33)
    AbsorbTextureDropdown:SetCallback("OnValueChanged", function(_, _, value) HealPredictionDB.Absorbs.Texture = value updateCallback() end)
    AbsorbSettings:AddChild(AbsorbTextureDropdown)

    local HealAbsorbSettings = GUIWidgets.CreateInlineGroup(containerParent, "Heal Absorb Settings")
    local ShowHealAbsorbToggle = AG:Create("CheckBox")
    ShowHealAbsorbToggle:SetLabel("Show Heal Absorbs")
    ShowHealAbsorbToggle:SetValue(HealPredictionDB.HealAbsorbs.Enabled)
    ShowHealAbsorbToggle:SetCallback("OnValueChanged", function(_, _, value) HealPredictionDB.HealAbsorbs.Enabled = value updateCallback() RefreshHealPredictionSettings() end)
    ShowHealAbsorbToggle:SetRelativeWidth(0.5)
    HealAbsorbSettings:AddChild(ShowHealAbsorbToggle)

    local ShowHealAbsorbGlowToggle = AG:Create("CheckBox")
    ShowHealAbsorbGlowToggle:SetLabel("Show Over-Heal Absorb Glow")
    ShowHealAbsorbGlowToggle:SetValue(HealPredictionDB.HealAbsorbs.ShowGlow)
    ShowHealAbsorbGlowToggle:SetCallback("OnValueChanged", function(_, _, value) HealPredictionDB.HealAbsorbs.ShowGlow = value updateCallback() end)
    ShowHealAbsorbGlowToggle:SetRelativeWidth(0.5)
    HealAbsorbSettings:AddChild(ShowHealAbsorbGlowToggle)

    local HealAbsorbOverlayOpacitySlider = AG:Create("Slider")
    HealAbsorbOverlayOpacitySlider:SetLabel("Overlay Opacity")
    HealAbsorbOverlayOpacitySlider:SetValue(HealPredictionDB.HealAbsorbs.OverlayOpacity)
    HealAbsorbOverlayOpacitySlider:SetSliderValues(0, 1, 0.01)
    HealAbsorbOverlayOpacitySlider:SetRelativeWidth(0.5)
    HealAbsorbOverlayOpacitySlider:SetCallback("OnValueChanged", function(_, _, value) HealPredictionDB.HealAbsorbs.OverlayOpacity = value updateCallback() end)
    HealAbsorbOverlayOpacitySlider:SetIsPercent(true)
    HealAbsorbSettings:AddChild(HealAbsorbOverlayOpacitySlider)

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

    HealPredictionDB.HealAbsorbs.Texture = HealPredictionDB.HealAbsorbs.Texture or "Blizzard"
    local HealAbsorbTextureDropdown = AG:Create("Dropdown")
    HealAbsorbTextureDropdown:SetLabel("Texture")
    HealAbsorbTextureDropdown:SetList(textureMap, textureOrder)
    HealAbsorbTextureDropdown:SetValue(HealPredictionDB.HealAbsorbs.Texture)
    HealAbsorbTextureDropdown:SetRelativeWidth(0.33)
    HealAbsorbTextureDropdown:SetCallback("OnValueChanged", function(_, _, value) HealPredictionDB.HealAbsorbs.Texture = value updateCallback() end)
    HealAbsorbSettings:AddChild(HealAbsorbTextureDropdown)

    local IncomingHealsSettings = GUIWidgets.CreateInlineGroup(containerParent, "Incoming Heals")

    local ShowIncomingHealsToggle = AG:Create("CheckBox")
    ShowIncomingHealsToggle:SetLabel("Show Incoming Heals")
    ShowIncomingHealsToggle:SetValue(HealPredictionDB.IncomingHeals.Enabled)
    ShowIncomingHealsToggle:SetCallback("OnValueChanged", function(_, _, value) HealPredictionDB.IncomingHeals.Enabled = value updateCallback() RefreshHealPredictionSettings() end)
    ShowIncomingHealsToggle:SetRelativeWidth(0.5)
    IncomingHealsSettings:AddChild(ShowIncomingHealsToggle)

    local SplitIncomingHealsToggle = AG:Create("CheckBox")
    SplitIncomingHealsToggle:SetLabel("Split Player/Other")
    SplitIncomingHealsToggle:SetValue(HealPredictionDB.IncomingHeals.Split)
    SplitIncomingHealsToggle:SetCallback("OnValueChanged", function(_, _, value) HealPredictionDB.IncomingHeals.Split = value updateCallback() RefreshHealPredictionSettings() end)
    SplitIncomingHealsToggle:SetRelativeWidth(0.5)
    IncomingHealsSettings:AddChild(SplitIncomingHealsToggle)

    local IncomingAllColourPicker = AG:Create("ColorPicker")
    IncomingAllColourPicker:SetLabel("All Heals Colour")
    local R3, G3, B3, A3 = unpack(HealPredictionDB.IncomingHeals.ColourAll)
    IncomingAllColourPicker:SetColor(R3, G3, B3, A3)
    IncomingAllColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) HealPredictionDB.IncomingHeals.ColourAll = {r, g, b, a} updateCallback() end)
    IncomingAllColourPicker:SetHasAlpha(true)
    IncomingAllColourPicker:SetRelativeWidth(0.33)
    IncomingHealsSettings:AddChild(IncomingAllColourPicker)

    local IncomingPlayerColourPicker = AG:Create("ColorPicker")
    IncomingPlayerColourPicker:SetLabel("Player Heals Colour")
    local R4, G4, B4, A4 = unpack(HealPredictionDB.IncomingHeals.ColourPlayer)
    IncomingPlayerColourPicker:SetColor(R4, G4, B4, A4)
    IncomingPlayerColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) HealPredictionDB.IncomingHeals.ColourPlayer = {r, g, b, a} updateCallback() end)
    IncomingPlayerColourPicker:SetHasAlpha(true)
    IncomingPlayerColourPicker:SetRelativeWidth(0.33)
    IncomingHealsSettings:AddChild(IncomingPlayerColourPicker)

    local IncomingOtherColourPicker = AG:Create("ColorPicker")
    IncomingOtherColourPicker:SetLabel("Other Heals Colour")
    local R5, G5, B5, A5 = unpack(HealPredictionDB.IncomingHeals.ColourOther)
    IncomingOtherColourPicker:SetColor(R5, G5, B5, A5)
    IncomingOtherColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) HealPredictionDB.IncomingHeals.ColourOther = {r, g, b, a} updateCallback() end)
    IncomingOtherColourPicker:SetHasAlpha(true)
    IncomingOtherColourPicker:SetRelativeWidth(0.33)
    IncomingHealsSettings:AddChild(IncomingOtherColourPicker)

    local IncomingHeightSlider = AG:Create("Slider")
    IncomingHeightSlider:SetLabel("Height")
    IncomingHeightSlider:SetValue(HealPredictionDB.IncomingHeals.Height)
    IncomingHeightSlider:SetSliderValues(1, FrameDB.Height - 2, 0.1)
    IncomingHeightSlider:SetRelativeWidth(0.33)
    IncomingHeightSlider:SetCallback("OnValueChanged", function(_, _, value) HealPredictionDB.IncomingHeals.Height = value updateCallback() end)
    IncomingHealsSettings:AddChild(IncomingHeightSlider)

    local IncomingPositionDropdown = AG:Create("Dropdown")
    IncomingPositionDropdown:SetList({["LEFT"] = "Left", ["RIGHT"] = "Right", ["ATTACH"] = "Attach To Missing Health"}, {"LEFT", "RIGHT", "ATTACH"})
    IncomingPositionDropdown:SetLabel("Position")
    IncomingPositionDropdown:SetValue(HealPredictionDB.IncomingHeals.Position)
    IncomingPositionDropdown:SetRelativeWidth(0.33)
    IncomingPositionDropdown:SetCallback("OnValueChanged", function(_, _, value) HealPredictionDB.IncomingHeals.Position = value updateCallback() end)
    IncomingHealsSettings:AddChild(IncomingPositionDropdown)

    local function RefreshHealPredictionSettings()
        GUIWidgets.DeepDisable(AbsorbSettings, not HealPredictionDB.Absorbs.Enabled, ShowAbsorbToggle)
        GUIWidgets.DeepDisable(HealAbsorbSettings, not HealPredictionDB.HealAbsorbs.Enabled, ShowHealAbsorbToggle)
        GUIWidgets.DeepDisable(IncomingHealsSettings, not HealPredictionDB.IncomingHeals.Enabled, ShowIncomingHealsToggle)

        IncomingAllColourPicker:SetDisabled(HealPredictionDB.IncomingHeals.Split)
        IncomingPlayerColourPicker:SetDisabled(not HealPredictionDB.IncomingHeals.Split)
        IncomingOtherColourPicker:SetDisabled(not HealPredictionDB.IncomingHeals.Split)
    end

    RefreshHealPredictionSettings()
end

-- CastBar subpanel: Bar appearance (width, height, colors, interruptible)
function GUIUnits:CreateCastBarBarSettings(containerParent, unit, updateCallback)
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
    NotInterruptibleColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) CastBarDB.NotInterruptibleColour = {r, g, b, a} updateCallback() end)
    NotInterruptibleColourPicker:SetHasAlpha(true)
    NotInterruptibleColourPicker:SetRelativeWidth(0.33)
    ColourContainer:AddChild(NotInterruptibleColourPicker)

    local function RefreshCastBarBarSettings()
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

-- CastBar subpanel: Icon (enable, position)
function GUIUnits:CreateCastBarIconSettings(containerParent, unit, updateCallback)
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

    local function RefreshCastBarIconSettings()
        if CastBarIconDB.Enabled then
            PositionDropdown:SetDisabled(false)
        else
            PositionDropdown:SetDisabled(true)
        end
    end

    RefreshCastBarIconSettings()
end

-- CastBar subpanel: Spell name text (position, font, color, size)
function GUIUnits:CreateCastBarSpellNameTextSettings(containerParent, unit, updateCallback)
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

    local function RefreshCastBarSpellNameSettings()
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

-- CastBar subpanel: Duration text (position, font, color, size)
function GUIUnits:CreateCastBarDurationTextSettings(containerParent, unit, updateCallback)
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

    local function RefreshCastBarDurationSettings()
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

-- CastBar subpanel: Enhancements (Timer Direction, Channel Ticks, Empower Stages, Latency feedback, Performance)
function GUIUnits:CreateCastBarEnhancementsSettings(containerParent, unit, updateCallback)
    local RefreshEnhancementsGUI
    local CastBarDB = UUF.db.profile.Units[unit].CastBar

    local EnhancementsContainer = AG:Create("SimpleGroup")
    EnhancementsContainer:SetLayout("Flow")
    containerParent:AddChild(EnhancementsContainer)

    -- ==== ROW 1: TIMER DIRECTION & CHANNEL TICKS (side by side) ====
    local TimerDirGroup = GUIWidgets.CreateInlineGroup(EnhancementsContainer, "Timer Direction")
    TimerDirGroup:SetRelativeWidth(0.48)
    
    local TimerDirToggle = AG:Create("CheckBox")
    TimerDirToggle:SetLabel("Enable Timer Direction")
    TimerDirToggle:SetValue(CastBarDB.TimerDirection.Enabled)
    TimerDirToggle:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.TimerDirection.Enabled = value updateCallback() RefreshEnhancementsGUI() end)
    TimerDirToggle:SetRelativeWidth(1.0)
    TimerDirGroup:AddChild(TimerDirToggle)
    
    local TimerDirTypeDropdown = AG:Create("Dropdown")
    TimerDirTypeDropdown:SetList({["ARROW"] = "Arrow", ["TEXT"] = "Text", ["BAR"] = "Bar"})
    TimerDirTypeDropdown:SetLabel("Timer Display Type")
    TimerDirTypeDropdown:SetValue(CastBarDB.TimerDirection.Type)
    TimerDirTypeDropdown:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.TimerDirection.Type = value updateCallback() end)
    TimerDirTypeDropdown:SetRelativeWidth(1.0)
    TimerDirGroup:AddChild(TimerDirTypeDropdown)

    local TimerDirColour = CastBarDB.TimerDirection.Colour or {1, 1, 1, 1}
    local TimerDirColourPicker = AG:Create("ColorPicker")
    TimerDirColourPicker:SetLabel("Timer Direction Color")
    TimerDirColourPicker:SetColor(TimerDirColour[1], TimerDirColour[2], TimerDirColour[3], TimerDirColour[4])
    TimerDirColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) CastBarDB.TimerDirection.Colour = {r, g, b, a} updateCallback() end)
    TimerDirColourPicker:SetRelativeWidth(1.0)
    TimerDirGroup:AddChild(TimerDirColourPicker)

    -- ==== CHANNEL TICKS (right of Timer Direction) ====
    local ChannelTicksGroup = GUIWidgets.CreateInlineGroup(EnhancementsContainer, "Channel Ticks")
    ChannelTicksGroup:SetRelativeWidth(0.48)
    
    local ChannelTicksToggle = AG:Create("CheckBox")
    ChannelTicksToggle:SetLabel("Enable Channel Tick Markers")
    ChannelTicksToggle:SetValue(CastBarDB.ChannelTicks.Enabled)
    ChannelTicksToggle:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.ChannelTicks.Enabled = value updateCallback() RefreshEnhancementsGUI() end)
    ChannelTicksToggle:SetRelativeWidth(1.0)
    ChannelTicksGroup:AddChild(ChannelTicksToggle)

    local TickColour = CastBarDB.ChannelTicks.Colour or {0.5, 1, 0.5, 1}
    local ChannelTicksColourPicker = AG:Create("ColorPicker")
    ChannelTicksColourPicker:SetLabel("Tick Color")
    ChannelTicksColourPicker:SetColor(TickColour[1], TickColour[2], TickColour[3], TickColour[4])
    ChannelTicksColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) CastBarDB.ChannelTicks.Colour = {r, g, b, a} updateCallback() end)
    ChannelTicksColourPicker:SetRelativeWidth(0.5)
    ChannelTicksGroup:AddChild(ChannelTicksColourPicker)

    local ChannelTicksOpacitySlider = AG:Create("Slider")
    ChannelTicksOpacitySlider:SetLabel("Tick Opacity")
    ChannelTicksOpacitySlider:SetValue(CastBarDB.ChannelTicks.Opacity or 0.8)
    ChannelTicksOpacitySlider:SetSliderValues(0, 1, 0.05)
    ChannelTicksOpacitySlider:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.ChannelTicks.Opacity = value updateCallback() end)
    ChannelTicksOpacitySlider:SetRelativeWidth(0.5)
    ChannelTicksGroup:AddChild(ChannelTicksOpacitySlider)

    local ChannelTicksWidthSlider = AG:Create("Slider")
    ChannelTicksWidthSlider:SetLabel("Tick Width")
    ChannelTicksWidthSlider:SetValue(CastBarDB.ChannelTicks.Width or 8)
    ChannelTicksWidthSlider:SetSliderValues(2, 20, 1)
    ChannelTicksWidthSlider:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.ChannelTicks.Width = value updateCallback() end)
    ChannelTicksWidthSlider:SetRelativeWidth(0.5)
    ChannelTicksGroup:AddChild(ChannelTicksWidthSlider)

    local ChannelTicksHeightSlider = AG:Create("Slider")
    ChannelTicksHeightSlider:SetLabel("Tick Height")
    ChannelTicksHeightSlider:SetValue(CastBarDB.ChannelTicks.Height or 28)
    ChannelTicksHeightSlider:SetSliderValues(10, 50, 1)
    ChannelTicksHeightSlider:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.ChannelTicks.Height = value updateCallback() end)
    ChannelTicksHeightSlider:SetRelativeWidth(0.5)
    ChannelTicksGroup:AddChild(ChannelTicksHeightSlider)

    -- ==== ROW 2: EMPOWER STAGES & LATENCY INDICATOR (side by side) ====
    local EmpowerGroup = GUIWidgets.CreateInlineGroup(EnhancementsContainer, "Empower Stage Visuals")
    EmpowerGroup:SetRelativeWidth(0.48)
    
    local EmpowerToggle = AG:Create("CheckBox")
    EmpowerToggle:SetLabel("Enable Empower Stage Indicators")
    EmpowerToggle:SetValue(CastBarDB.EmpowerStages.Enabled)
    EmpowerToggle:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.EmpowerStages.Enabled = value updateCallback() RefreshEnhancementsGUI() end)
    EmpowerToggle:SetRelativeWidth(1.0)
    EmpowerGroup:AddChild(EmpowerToggle)

    local EmpowerStyleDropdown = AG:Create("Dropdown")
    EmpowerStyleDropdown:SetList({["LINES"] = "Lines", ["FILLS"] = "Fills", ["BOXES"] = "Boxes"})
    EmpowerStyleDropdown:SetLabel("Stage Display Style")
    EmpowerStyleDropdown:SetValue(CastBarDB.EmpowerStages.Style or "LINES")
    EmpowerStyleDropdown:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.EmpowerStages.Style = value updateCallback() end)
    EmpowerStyleDropdown:SetRelativeWidth(1.0)
    EmpowerGroup:AddChild(EmpowerStyleDropdown)

    local EmpowerColour = CastBarDB.EmpowerStages.Colour or {1, 1, 0, 1}
    local EmpowerColourPicker = AG:Create("ColorPicker")
    EmpowerColourPicker:SetLabel("Stage Marker Color")
    EmpowerColourPicker:SetColor(EmpowerColour[1], EmpowerColour[2], EmpowerColour[3], EmpowerColour[4])
    EmpowerColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) CastBarDB.EmpowerStages.Colour = {r, g, b, a} updateCallback() end)
    EmpowerColourPicker:SetRelativeWidth(1.0)
    EmpowerGroup:AddChild(EmpowerColourPicker)

    local EmpowerWidthSlider = AG:Create("Slider")
    EmpowerWidthSlider:SetLabel("Indicator Width")
    EmpowerWidthSlider:SetValue(CastBarDB.EmpowerStages.Width or 4)
    EmpowerWidthSlider:SetSliderValues(2, 20, 1)
    EmpowerWidthSlider:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.EmpowerStages.Width = value updateCallback() end)
    EmpowerWidthSlider:SetRelativeWidth(0.5)
    EmpowerGroup:AddChild(EmpowerWidthSlider)

    local EmpowerHeightSlider = AG:Create("Slider")
    EmpowerHeightSlider:SetLabel("Indicator Height")
    EmpowerHeightSlider:SetValue(CastBarDB.EmpowerStages.Height or 24)
    EmpowerHeightSlider:SetSliderValues(10, 50, 1)
    EmpowerHeightSlider:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.EmpowerStages.Height = value updateCallback() end)
    EmpowerHeightSlider:SetRelativeWidth(0.5)
    EmpowerGroup:AddChild(EmpowerHeightSlider)

    -- ==== LATENCY INDICATOR (right of Empower) ====
    local LatencyGroup = GUIWidgets.CreateInlineGroup(EnhancementsContainer, "Latency Indicator")
    LatencyGroup:SetRelativeWidth(0.48)
    
    local LatencyToggle = AG:Create("CheckBox")
    LatencyToggle:SetLabel("Enable Latency Display")
    LatencyToggle:SetValue(CastBarDB.LatencyIndicator.Enabled)
    LatencyToggle:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.LatencyIndicator.Enabled = value updateCallback() RefreshEnhancementsGUI() end)
    LatencyToggle:SetRelativeWidth(0.5)
    LatencyGroup:AddChild(LatencyToggle)

    local LatencyShowValueToggle = AG:Create("CheckBox")
    LatencyShowValueToggle:SetLabel("Show Latency Value")
    LatencyShowValueToggle:SetValue(CastBarDB.LatencyIndicator.ShowValue)
    LatencyShowValueToggle:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.LatencyIndicator.ShowValue = value updateCallback() end)
    LatencyShowValueToggle:SetRelativeWidth(0.5)
    LatencyGroup:AddChild(LatencyShowValueToggle)

    local HighLatencyThreshold = AG:Create("Slider")
    HighLatencyThreshold:SetLabel("High Latency Threshold (ms)")
    HighLatencyThreshold:SetValue(CastBarDB.LatencyIndicator.HighLatencyThreshold or 150)
    HighLatencyThreshold:SetSliderValues(50, 500, 10)
    HighLatencyThreshold:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.LatencyIndicator.HighLatencyThreshold = value updateCallback() end)
    HighLatencyThreshold:SetRelativeWidth(1.0)
    LatencyGroup:AddChild(HighLatencyThreshold)

    -- ==== ROW 3: PERFORMANCE SETTINGS (full width) ====
    local PerfGroup = GUIWidgets.CreateInlineGroup(EnhancementsContainer, "Performance Settings")
    PerfGroup:SetRelativeWidth(1.0)
    
    local SimplifyToggle = AG:Create("CheckBox")
    SimplifyToggle:SetLabel("Simplify For Large Groups")
    SimplifyToggle:SetValue(CastBarDB.Performance.SimplifyForLargeGroups)
    SimplifyToggle:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.Performance.SimplifyForLargeGroups = value updateCallback() RefreshEnhancementsGUI() end)
    SimplifyToggle:SetRelativeWidth(0.5)
    PerfGroup:AddChild(SimplifyToggle)

    local GroupSizeThreshold = AG:Create("Slider")
    GroupSizeThreshold:SetLabel("Group Size Threshold")
    GroupSizeThreshold:SetValue(CastBarDB.Performance.GroupSizeThreshold or 15)
    GroupSizeThreshold:SetSliderValues(5, 40, 1)
    GroupSizeThreshold:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.Performance.GroupSizeThreshold = value updateCallback() end)
    GroupSizeThreshold:SetRelativeWidth(0.5)
    PerfGroup:AddChild(GroupSizeThreshold)

    -- Refresh logic
    RefreshEnhancementsGUI = function()
        TimerDirTypeDropdown:SetDisabled(not CastBarDB.TimerDirection.Enabled)
        TimerDirColourPicker:SetDisabled(not CastBarDB.TimerDirection.Enabled)
        
        ChannelTicksColourPicker:SetDisabled(not CastBarDB.ChannelTicks.Enabled)
        ChannelTicksOpacitySlider:SetDisabled(not CastBarDB.ChannelTicks.Enabled)
        ChannelTicksWidthSlider:SetDisabled(not CastBarDB.ChannelTicks.Enabled)
        ChannelTicksHeightSlider:SetDisabled(not CastBarDB.ChannelTicks.Enabled)
        
        EmpowerStyleDropdown:SetDisabled(not CastBarDB.EmpowerStages.Enabled)
        EmpowerColourPicker:SetDisabled(not CastBarDB.EmpowerStages.Enabled)
        EmpowerWidthSlider:SetDisabled(not CastBarDB.EmpowerStages.Enabled)
        EmpowerHeightSlider:SetDisabled(not CastBarDB.EmpowerStages.Enabled)
        
        LatencyShowValueToggle:SetDisabled(not CastBarDB.LatencyIndicator.Enabled)
        HighLatencyThreshold:SetDisabled(not CastBarDB.LatencyIndicator.Enabled)
        
        GroupSizeThreshold:SetDisabled(not CastBarDB.Performance.SimplifyForLargeGroups)
    end

    RefreshEnhancementsGUI()
end

-- CastBar coordinator: TabGroup for Bar/Icon/SpellName/Duration/Enhancements
function GUIUnits:CreateCastBarSettings(containerParent, unit)
    local function SelectCastBarTab(CastBarContainer, _, CastBarTab)
        SaveSubTab(unit, "CastBar", CastBarTab)
        CastBarContainer:ReleaseChildren()
        if CastBarTab == "Bar" then
            GUIUnits:CreateCastBarBarSettings(CastBarContainer, unit, function() UpdateMultiFrameUnit(unit, function() UUF:UpdateUnitCastBar(UUF[unit:upper()], unit) end) end)
        elseif CastBarTab == "Icon" then
            GUIUnits:CreateCastBarIconSettings(CastBarContainer, unit, function() UpdateMultiFrameUnit(unit, function() UUF:UpdateUnitCastBar(UUF[unit:upper()], unit) end) end)
        elseif CastBarTab == "SpellName" then
            GUIUnits:CreateCastBarSpellNameTextSettings(CastBarContainer, unit, function() UpdateMultiFrameUnit(unit, function() UUF:UpdateUnitCastBar(UUF[unit:upper()], unit) end) end)
        elseif CastBarTab == "Duration" then
            GUIUnits:CreateCastBarDurationTextSettings(CastBarContainer, unit, function() UpdateMultiFrameUnit(unit, function() UUF:UpdateUnitCastBar(UUF[unit:upper()], unit) end) end)
        elseif CastBarTab == "Enhancements" then
            GUIUnits:CreateCastBarEnhancementsSettings(CastBarContainer, unit, function() UpdateMultiFrameUnit(unit, function() UUF:UpdateUnitCastBar(UUF[unit:upper()], unit) end) end)
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
        {text = "Enhancements", value = "Enhancements"},
    })
    CastBarTabGroup:SetCallback("OnGroupSelected", SelectCastBarTab)
    CastBarTabGroup:SelectTab(GetSavedSubTab(unit, "CastBar", "Bar"))
    containerParent:AddChild(CastBarTabGroup)
end

-- Power bar settings (height, colors, smooth updates)
function GUIUnits:CreatePowerBarSettings(containerParent, unit, updateCallback)
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

    local function RefreshPowerBarGUI()
        if PowerBarDB.Enabled then
            GUIWidgets.DeepDisable(LayoutContainer, false, Toggle)
            GUIWidgets.DeepDisable(ColourContainer, false, Toggle)
            if PowerBarDB.ColourByClass or PowerBarDB.ColourByType then
                ForegroundColourPicker:SetDisabled(true)
            else
                ForegroundColourPicker:SetDisabled(false)
            end
        else
            GUIWidgets.DeepDisable(LayoutContainer, true, Toggle)
            GUIWidgets.DeepDisable(ColourContainer, true, Toggle)
        end
    end

    RefreshPowerBarGUI()
end

-- Secondary power bar (combo points, insane, etc.)
function GUIUnits:CreateSecondaryPowerBarSettings(containerParent, unit, updateCallback)
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
    ColourContainer:AddChild(BackgroundColourPicker)

    local function RefreshSecondaryPowerBarGUI()
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

-- Alternative power bar (mana for druids, etc.)
function GUIUnits:CreateAlternativePowerBarSettings(containerParent, unit, updateCallback)
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

    local function RefreshAlternativePowerBarGUI()
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

-- Portrait settings (2D/3D, zoom, positioning)
function GUIUnits:CreatePortraitSettings(containerParent, unit, updateCallback)
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

    local function RefreshPortraitGUI()
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

-- Raid target marker indicator settings
function GUIUnits:CreateRaidTargetMarkerSettings(containerParent, unit, updateCallback)
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

    local function RefreshStatusGUI()
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

-- Leader/Assistant indicator settings
function GUIUnits:CreateLeaderAssistantSettings(containerParent, unit, updateCallback)
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

    local function RefreshStatusGUI()
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

-- Group role indicator settings (Tank/Healer/DPS)
function GUIUnits:CreateGroupRoleIndicatorSettings(containerParent, unit, updateCallback)
    local GroupRoleIndicatorDB = UUF.db.profile.Units[unit].Indicators.GroupRole

    local ToggleContainer = GUIWidgets.CreateInlineGroup(containerParent, "Group Role Indicator Settings")

    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel("Enable |cFF8080FFGroup Role|r Indicator")
    Toggle:SetValue(GroupRoleIndicatorDB.Enabled)
    Toggle:SetCallback("OnValueChanged", function(_, _, value) GroupRoleIndicatorDB.Enabled = value updateCallback() RefreshStatusGUI() end)
    Toggle:SetRelativeWidth(1)
    ToggleContainer:AddChild(Toggle)

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Layout & Positioning")

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(GroupRoleIndicatorDB.Layout[1])
    AnchorFromDropdown:SetRelativeWidth(0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) GroupRoleIndicatorDB.Layout[1] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(GroupRoleIndicatorDB.Layout[2])
    AnchorToDropdown:SetRelativeWidth(0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) GroupRoleIndicatorDB.Layout[2] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorToDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(GroupRoleIndicatorDB.Layout[3])
    XPosSlider:SetSliderValues(-1000, 1000, 0.1)
    XPosSlider:SetRelativeWidth(0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) GroupRoleIndicatorDB.Layout[3] = value updateCallback() end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(GroupRoleIndicatorDB.Layout[4])
    YPosSlider:SetSliderValues(-1000, 1000, 0.1)
    YPosSlider:SetRelativeWidth(0.33)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) GroupRoleIndicatorDB.Layout[4] = value updateCallback() end)
    LayoutContainer:AddChild(YPosSlider)

    local SizeSlider = AG:Create("Slider")
    SizeSlider:SetLabel("Size")
    SizeSlider:SetValue(GroupRoleIndicatorDB.Size)
    SizeSlider:SetSliderValues(8, 64, 1)
    SizeSlider:SetRelativeWidth(0.33)
    SizeSlider:SetCallback("OnValueChanged", function(_, _, value) GroupRoleIndicatorDB.Size = value updateCallback() end)
    LayoutContainer:AddChild(SizeSlider)

    local function RefreshStatusGUI()
        if GroupRoleIndicatorDB.Enabled then
            GUIWidgets.DeepDisable(ToggleContainer, false, Toggle)
            GUIWidgets.DeepDisable(LayoutContainer, false, Toggle)
        else
            GUIWidgets.DeepDisable(ToggleContainer, true, Toggle)
            GUIWidgets.DeepDisable(LayoutContainer, true, Toggle)
        end
    end

    RefreshStatusGUI()
end

-- Generic status indicator factory (used by Combat, Resting, etc.)
function GUIUnits:CreateStatusSettings(containerParent, unit, statusDB, statusTitle, updateCallback)
    local StatusDB = UUF.db.profile.Units[unit].Indicators[statusDB]

    local ToggleContainer = GUIWidgets.CreateInlineGroup(containerParent, statusDB .. " Settings")

    local StatusTextureList = {}
    for key, texture in pairs(StatusTextures[statusDB]) do
        StatusTextureList[key] = texture
    end

    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel("Enable |cFF8080FF"..statusTitle.."|r Indicator")
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

    local function RefreshStatusGUI()
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

-- Mouseover highlight settings (color, style, opacity)
function GUIUnits:CreateMouseoverSettings(containerParent, unit, updateCallback)
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

    local function RefreshMouseoverGUI()
        if MouseoverDB.Enabled then
            GUIWidgets.DeepDisable(ToggleContainer, false, Toggle)
        else
            GUIWidgets.DeepDisable(ToggleContainer, true, Toggle)
        end
    end

    RefreshMouseoverGUI()
end

-- Target indicator settings (glow color)
function GUIUnits:CreateTargetIndicatorSettings(containerParent, unit, updateCallback)
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

    local function RefreshTargetIndicatorGUI()
        if TargetIndicatorDB.Enabled then
            GUIWidgets.DeepDisable(ToggleContainer, false, Toggle)
        else
            GUIWidgets.DeepDisable(ToggleContainer, true, Toggle)
        end
    end

    RefreshTargetIndicatorGUI()
end

-- Totems indicator settings (display, duration text)
function GUIUnits:CreateTotemsIndicatorSettings(containerParent, unit, updateCallback)
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

    local function RefreshTotemsIndicatorGUI()
        if TotemsIndicatorDB.Enabled then
            GUIWidgets.DeepDisable(ToggleContainer, false, Toggle)
        else
            GUIWidgets.DeepDisable(ToggleContainer, true, Toggle)
        end
    end

    RefreshTotemsIndicatorGUI()
end

-- Indicator coordinator: TabGroup for all indicator types
function GUIUnits:CreateIndicatorSettings(containerParent, unit, updateCallback)
    local IndicatorDB = UUF.db.profile.Units[unit].Indicators
    
    local function SelectIndicatorTab(IndicatorContainer, _, IndicatorTab)
        SaveSubTab(unit, "Indicators", IndicatorTab)
        IndicatorContainer:ReleaseChildren()
        local updateFunc = updateCallback or function() UpdateMultiFrameUnit(unit, function() end) end
        
        if IndicatorTab == "RaidTargetMarker" then
            GUIUnits:CreateRaidTargetMarkerSettings(IndicatorContainer, unit, updateFunc)
        elseif IndicatorTab == "GroupRole" then
            GUIUnits:CreateStatusSettings(IndicatorContainer, unit, "GroupRole", "Group Role", updateFunc)
        elseif IndicatorTab == "LeaderAssistant" then
            GUIUnits:CreateLeaderAssistantSettings(IndicatorContainer, unit, updateFunc)
        elseif IndicatorTab == "Resting" then
            GUIUnits:CreateStatusSettings(IndicatorContainer, unit, "Resting", "Resting", updateFunc)
        elseif IndicatorTab == "Combat" then
            GUIUnits:CreateStatusSettings(IndicatorContainer, unit, "Combat", "Combat", updateFunc)
        elseif IndicatorTab == "Mouseover" then
            GUIUnits:CreateMouseoverSettings(IndicatorContainer, unit, updateFunc)
        elseif IndicatorTab == "TargetIndicator" then
            GUIUnits:CreateTargetIndicatorSettings(IndicatorContainer, unit, updateFunc)
        elseif IndicatorTab == "Totems" then
            GUIUnits:CreateTotemsIndicatorSettings(IndicatorContainer, unit, updateFunc)
        end
    end

    local IndicatorTabGroup = AG:Create("TabGroup")
    IndicatorTabGroup:SetLayout("Flow")
    IndicatorTabGroup:SetFullWidth(true)
    
    local tabsConfig = {
        player = {
            {text = "Raid Target Marker", value = "RaidTargetMarker"},
            {text = "Leader & Assistant", value = "LeaderAssistant"},
            {text = "Resting", value = "Resting"},
            {text = "Combat", value = "Combat"},
            {text = "Mouseover", value = "Mouseover"},
        },
        target = {
            {text = "Raid Target Marker", value = "RaidTargetMarker"},
            {text = "Leader & Assistant", value = "LeaderAssistant"},
            {text = "Combat", value = "Combat"},
            {text = "Mouseover", value = "Mouseover"},
            {text = "Target Indicator", value = "TargetIndicator"},
        },
        party = {
            {text = "Raid Target Marker", value = "RaidTargetMarker"},
            {text = "Leader & Assistant", value = "LeaderAssistant"},
            {text = "Group Role", value = "GroupRole"},
            {text = "Mouseover", value = "Mouseover"},
            {text = "Target Indicator", value = "TargetIndicator"},
        },
    }
    
    local defaultTabs = {
        {text = "Raid Target Marker", value = "RaidTargetMarker"},
        {text = "Mouseover", value = "Mouseover"},
        {text = "Target Indicator", value = "TargetIndicator"},
    }
    
    IndicatorTabGroup:SetTabs(tabsConfig[unit] or defaultTabs)
    IndicatorTabGroup:SetCallback("OnGroupSelected", SelectIndicatorTab)
    IndicatorTabGroup:SelectTab(GetSavedSubTab(unit, "Indicators", "RaidTargetMarker"))
    containerParent:AddChild(IndicatorTabGroup)
end

-- Single tag editor (position, color, text, tag selection)
function GUIUnits:CreateTagSetting(containerParent, unit, tagDB)
    local TagDB = UUF.db.profile.Units[unit].Tags[tagDB]

    local TagContainer = GUIWidgets.CreateInlineGroup(containerParent, "Tag Settings")

    local EditBox = AG:Create("EditBox")
    EditBox:SetLabel("Tag")
    EditBox:SetText(TagDB.Tag)
    EditBox:SetRelativeWidth(0.5)
    EditBox:DisableButton(true)
    EditBox:SetCallback("OnEnterPressed", function(_, _, value) TagDB.Tag = value EditBox:SetText(TagDB.Tag) UpdateTagForMultiFrameUnit(unit, tagDB) end)
    TagContainer:AddChild(EditBox)

    local ColourPicker = AG:Create("ColorPicker")
    ColourPicker:SetLabel("Colour")
    ColourPicker:SetColor(TagDB.Colour[1], TagDB.Colour[2], TagDB.Colour[3], 1)
    ColourPicker:SetFullWidth(true)
    ColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b) TagDB.Colour = {r, g, b} UpdateTagForMultiFrameUnit(unit, tagDB) end)
    ColourPicker:SetHasAlpha(false)
    ColourPicker:SetRelativeWidth(0.5)
    TagContainer:AddChild(ColourPicker)

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Layout & Positioning")

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(TagDB.Layout[1])
    AnchorFromDropdown:SetRelativeWidth(0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) TagDB.Layout[1] = value UpdateTagForMultiFrameUnit(unit, tagDB) end)
    LayoutContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(TagDB.Layout[2])
    AnchorToDropdown:SetRelativeWidth(0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) TagDB.Layout[2] = value UpdateTagForMultiFrameUnit(unit, tagDB) end)
    LayoutContainer:AddChild(AnchorToDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(TagDB.Layout[3])
    XPosSlider:SetSliderValues(-1000, 1000, 0.1)
    XPosSlider:SetRelativeWidth(0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) TagDB.Layout[3] = value UpdateTagForMultiFrameUnit(unit, tagDB) end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(TagDB.Layout[4])
    YPosSlider:SetSliderValues(-1000, 1000, 0.1)
    YPosSlider:SetRelativeWidth(0.33)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) TagDB.Layout[4] = value UpdateTagForMultiFrameUnit(unit, tagDB) end)
    LayoutContainer:AddChild(YPosSlider)

    local FontSizeSlider = AG:Create("Slider")
    FontSizeSlider:SetLabel("Font Size")
    FontSizeSlider:SetValue(TagDB.FontSize)
    FontSizeSlider:SetSliderValues(8, 64, 1)
    FontSizeSlider:SetRelativeWidth(0.33)
    FontSizeSlider:SetCallback("OnValueChanged", function(_, _, value) TagDB.FontSize = value UpdateTagForMultiFrameUnit(unit, tagDB) end)
    LayoutContainer:AddChild(FontSizeSlider)

    local TagSelectionContainer = GUIWidgets.CreateInlineGroup(containerParent, "Tag Selection")
    GUIWidgets.CreateInformationTag(TagSelectionContainer, "You can use the dropdowns below to quickly add tags.\n|cFF8080FFPrefix|r indicates that this should be added to the start of the tag string.")

    local HealthTagDropdown = AG:Create("Dropdown")
    HealthTagDropdown:SetList(UUF:FetchTagData("Health")[1], UUF:FetchTagData("Health")[2])
    HealthTagDropdown:SetLabel("Health Tags")
    HealthTagDropdown:SetValue(nil)
    HealthTagDropdown:SetRelativeWidth(0.5)
    HealthTagDropdown:SetCallback("OnValueChanged", function(_, _, value) local currentTag = TagDB.Tag if currentTag and currentTag ~= "" then currentTag = currentTag .. "[" .. value .. "]" else currentTag = "[" .. value .. "]" end EditBox:SetText(currentTag) UUF.db.profile.Units[unit].Tags[tagDB].Tag = currentTag UpdateTagForMultiFrameUnit(unit, tagDB) HealthTagDropdown:SetValue(nil) end)
    TagSelectionContainer:AddChild(HealthTagDropdown)

    local PowerTagDropdown = AG:Create("Dropdown")
    PowerTagDropdown:SetList(UUF:FetchTagData("Power")[1], UUF:FetchTagData("Power")[2])
    PowerTagDropdown:SetLabel("Power Tags")
    PowerTagDropdown:SetValue(nil)
    PowerTagDropdown:SetRelativeWidth(0.5)
    PowerTagDropdown:SetCallback("OnValueChanged", function(_, _, value) local currentTag = TagDB.Tag if currentTag and currentTag ~= "" then currentTag = currentTag .. "[" .. value .. "]" else currentTag = "[" .. value .. "]" end EditBox:SetText(currentTag) UUF.db.profile.Units[unit].Tags[tagDB].Tag = currentTag UpdateTagForMultiFrameUnit(unit, tagDB) PowerTagDropdown:SetValue(nil) end)
    TagSelectionContainer:AddChild(PowerTagDropdown)

    local NameTagDropdown = AG:Create("Dropdown")
    NameTagDropdown:SetList(UUF:FetchTagData("Name")[1], UUF:FetchTagData("Name")[2])
    NameTagDropdown:SetLabel("Name Tags")
    NameTagDropdown:SetValue(nil)
    NameTagDropdown:SetRelativeWidth(0.5)
    NameTagDropdown:SetCallback("OnValueChanged", function(_, _, value) local currentTag = TagDB.Tag if currentTag and currentTag ~= "" then currentTag = currentTag .. "[" .. value .. "]" else currentTag = "[" .. value .. "]" end EditBox:SetText(currentTag) UUF.db.profile.Units[unit].Tags[tagDB].Tag = currentTag UpdateTagForMultiFrameUnit(unit, tagDB) NameTagDropdown:SetValue(nil) end)
    TagSelectionContainer:AddChild(NameTagDropdown)

    local MiscTagDropdown = AG:Create("Dropdown")
    MiscTagDropdown:SetList(UUF:FetchTagData("Misc")[1], UUF:FetchTagData("Misc")[2])
    MiscTagDropdown:SetLabel("Misc Tags")
    MiscTagDropdown:SetValue(nil)
    MiscTagDropdown:SetRelativeWidth(0.5)
    MiscTagDropdown:SetCallback("OnValueChanged", function(_, _, value) local currentTag = TagDB.Tag if currentTag and currentTag ~= "" then currentTag = currentTag .. "[" .. value .. "]" else currentTag = "[" .. value .. "]" end EditBox:SetText(currentTag) UUF.db.profile.Units[unit].Tags[tagDB].Tag = currentTag UpdateTagForMultiFrameUnit(unit, tagDB) MiscTagDropdown:SetValue(nil) end)
    MiscTagDropdown:SetDisabled(#UUF:FetchTagData("Misc") == 0)
    TagSelectionContainer:AddChild(MiscTagDropdown)

    containerParent:DoLayout()
end

-- Tag coordinator: TabGroup for TagOne through TagFive
function GUIUnits:CreateTagsSettings(containerParent, unit, updateCallback)
    local TagsDB = UUF.db.profile.Units[unit].Tags
    
    local function SelectTagTab(TagContainer, _, TagTab)
        SaveSubTab(unit, "Tags", TagTab)
        TagContainer:ReleaseChildren()
        GUIUnits:CreateTagSetting(TagContainer, unit, TagTab)
    end

    local TagTabGroup = AG:Create("TabGroup")
    TagTabGroup:SetLayout("Flow")
    TagTabGroup:SetFullWidth(true)
    TagTabGroup:SetTabs({
        {text = "Tag One", value = "TagOne"},
        {text = "Tag Two", value = "TagTwo"},
        {text = "Tag Three", value = "TagThree"},
        {text = "Tag Four", value = "TagFour"},
        {text = "Tag Five", value = "TagFive"},
    })
    TagTabGroup:SetCallback("OnGroupSelected", SelectTagTab)
    TagTabGroup:SelectTab(GetSavedSubTab(unit, "Tags", "TagOne"))
    containerParent:AddChild(TagTabGroup)
end

-- Individual buff/debuff settings (layout, count, filter)
function GUIUnits:CreateSpecificAuraSettings(containerParent, unit, auraDB)
    local AuraDB = UUF.db.profile.Units[unit].Auras[auraDB]

    local AuraContainer = GUIWidgets.CreateInlineGroup(containerParent, auraDB .. " Settings")
    local LayoutContainer  -- Will be defined later
    local CountContainer   -- Will be defined later

    -- Define RefreshAuraGUI early so callbacks can reference it
    local function RefreshAuraGUI()
        if AuraDB.Enabled then
            GUIWidgets.DeepDisable(AuraContainer, false, Toggle)
            if LayoutContainer then GUIWidgets.DeepDisable(LayoutContainer, false, Toggle) end
            if CountContainer then GUIWidgets.DeepDisable(CountContainer, false, Toggle) end
        else
            GUIWidgets.DeepDisable(AuraContainer, true, Toggle)
            if LayoutContainer then GUIWidgets.DeepDisable(LayoutContainer, true, Toggle) end
            if CountContainer then GUIWidgets.DeepDisable(CountContainer, true, Toggle) end
        end
    end

    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel("Enable |cFF8080FF"..auraDB.."|r")
    Toggle:SetValue(AuraDB.Enabled)
    Toggle:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Enabled = value UpdateMultiFrameUnit(unit, function() UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end) RefreshAuraGUI() end)
    Toggle:SetRelativeWidth(0.33)
    AuraContainer:AddChild(Toggle)

    local OnlyShowPlayerToggle = AG:Create("CheckBox")
    OnlyShowPlayerToggle:SetLabel("Only Show Player "..auraDB)
    OnlyShowPlayerToggle:SetValue(AuraDB.OnlyShowPlayer)
    OnlyShowPlayerToggle:SetCallback("OnValueChanged", function(_, _, value) AuraDB.OnlyShowPlayer = value UpdateMultiFrameUnit(unit, function() UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end) end)
    OnlyShowPlayerToggle:SetRelativeWidth(0.33)
    AuraContainer:AddChild(OnlyShowPlayerToggle)

    local ShowTypeCheckbox = AG:Create("CheckBox")
    ShowTypeCheckbox:SetLabel(auraDB .. " Type Border")
    ShowTypeCheckbox:SetValue(AuraDB.ShowType)
    ShowTypeCheckbox:SetCallback("OnValueChanged", function(_, _, value) AuraDB.ShowType = value UpdateMultiFrameUnit(unit, function() UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end) end)
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

    LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Layout & Positioning")

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(AuraDB.Layout[1])
    AnchorFromDropdown:SetRelativeWidth(0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Layout[1] = value UpdateMultiFrameUnit(unit, function() UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end) end)
    LayoutContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(AuraDB.Layout[2])
    AnchorToDropdown:SetRelativeWidth(0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Layout[2] = value UpdateMultiFrameUnit(unit, function() UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end) end)
    LayoutContainer:AddChild(AnchorToDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(AuraDB.Layout[3])
    XPosSlider:SetSliderValues(-1000, 1000, 0.1)
    XPosSlider:SetRelativeWidth(0.25)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Layout[3] = value UpdateMultiFrameUnit(unit, function() UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end) end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(AuraDB.Layout[4])
    YPosSlider:SetSliderValues(-1000, 1000, 0.1)
    YPosSlider:SetRelativeWidth(0.25)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Layout[4] = value UpdateMultiFrameUnit(unit, function() UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end) end)
    LayoutContainer:AddChild(YPosSlider)

    local SizeSlider = AG:Create("Slider")
    SizeSlider:SetLabel("Size")
    SizeSlider:SetValue(AuraDB.Size)
    SizeSlider:SetSliderValues(8, 64, 1)
    SizeSlider:SetRelativeWidth(0.25)
    SizeSlider:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Size = value UpdateMultiFrameUnit(unit, function() UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end) end)
    LayoutContainer:AddChild(SizeSlider)

    local SpacingSlider = AG:Create("Slider")
    SpacingSlider:SetLabel("Spacing")
    SpacingSlider:SetValue(AuraDB.Layout[5])
    SpacingSlider:SetSliderValues(-5, 5, 1)
    SpacingSlider:SetRelativeWidth(0.25)
    SpacingSlider:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Layout[5] = value UpdateMultiFrameUnit(unit, function() UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end) end)
    LayoutContainer:AddChild(SpacingSlider)

    GUIWidgets.CreateHeader(LayoutContainer, "Layout")

    local NumAurasSlider = AG:Create("Slider")
    NumAurasSlider:SetLabel(auraDB .. " To Display")
    NumAurasSlider:SetValue(AuraDB.Num)
    NumAurasSlider:SetSliderValues(1, 24, 1)
    NumAurasSlider:SetRelativeWidth(0.5)
    NumAurasSlider:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Num = value UpdateMultiFrameUnit(unit, function() UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end) end)
    LayoutContainer:AddChild(NumAurasSlider)

    local PerRowSlider = AG:Create("Slider")
    PerRowSlider:SetLabel(auraDB .. " Per Row")
    PerRowSlider:SetValue(AuraDB.Wrap)
    PerRowSlider:SetSliderValues(1, 24, 1)
    PerRowSlider:SetRelativeWidth(0.5)
    PerRowSlider:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Wrap = value UpdateMultiFrameUnit(unit, function() UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end) end)
    LayoutContainer:AddChild(PerRowSlider)

    local GrowthDirectionDropdown = AG:Create("Dropdown")
    GrowthDirectionDropdown:SetList({ ["LEFT"] = "Left", ["RIGHT"] = "Right"})
    GrowthDirectionDropdown:SetLabel("Growth Direction")
    GrowthDirectionDropdown:SetValue(AuraDB.GrowthDirection)
    GrowthDirectionDropdown:SetRelativeWidth(0.5)
    GrowthDirectionDropdown:SetCallback("OnValueChanged", function(_, _, value) AuraDB.GrowthDirection = value UpdateMultiFrameUnit(unit, function() UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end) end)
    LayoutContainer:AddChild(GrowthDirectionDropdown)

    local WrapDirectionDropdown = AG:Create("Dropdown")
    WrapDirectionDropdown:SetList({ ["UP"] = "Up", ["DOWN"] = "Down"})
    WrapDirectionDropdown:SetLabel("Wrap Direction")
    WrapDirectionDropdown:SetValue(AuraDB.WrapDirection)
    WrapDirectionDropdown:SetRelativeWidth(0.5)
    WrapDirectionDropdown:SetCallback("OnValueChanged", function(_, _, value) AuraDB.WrapDirection = value UpdateMultiFrameUnit(unit, function() UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end) end)
    LayoutContainer:AddChild(WrapDirectionDropdown)

    CountContainer = GUIWidgets.CreateInlineGroup(containerParent, "Count Settings")

    local CountAnchorFromDropdown = AG:Create("Dropdown")
    CountAnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    CountAnchorFromDropdown:SetLabel("Anchor From")
    CountAnchorFromDropdown:SetValue(AuraDB.Count.Layout[1])
    CountAnchorFromDropdown:SetRelativeWidth(0.5)
    CountAnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Count.Layout[1] = value UpdateMultiFrameUnit(unit, function() UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end) end)
    CountContainer:AddChild(CountAnchorFromDropdown)

    local CountAnchorToDropdown = AG:Create("Dropdown")
    CountAnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    CountAnchorToDropdown:SetLabel("Anchor To")
    CountAnchorToDropdown:SetValue(AuraDB.Count.Layout[2])
    CountAnchorToDropdown:SetRelativeWidth(0.5)
    CountAnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Count.Layout[2] = value UpdateMultiFrameUnit(unit, function() UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end) end)
    CountContainer:AddChild(CountAnchorToDropdown)

    local CountXPosSlider = AG:Create("Slider")
    CountXPosSlider:SetLabel("X Position")
    CountXPosSlider:SetValue(AuraDB.Count.Layout[3])
    CountXPosSlider:SetSliderValues(-1000, 1000, 0.1)
    CountXPosSlider:SetRelativeWidth(0.25)
    CountXPosSlider:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Count.Layout[3] = value UpdateMultiFrameUnit(unit, function() UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end) end)
    CountContainer:AddChild(CountXPosSlider)

    local CountYPosSlider = AG:Create("Slider")
    CountYPosSlider:SetLabel("Y Position")
    CountYPosSlider:SetValue(AuraDB.Count.Layout[4])
    CountYPosSlider:SetSliderValues(-1000, 1000, 0.1)
    CountYPosSlider:SetRelativeWidth(0.25)
    CountYPosSlider:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Count.Layout[4] = value UpdateMultiFrameUnit(unit, function() UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end) end)
    CountContainer:AddChild(CountYPosSlider)

    local FontSizeSlider = AG:Create("Slider")
    FontSizeSlider:SetLabel("Font Size")
    FontSizeSlider:SetValue(AuraDB.Count.FontSize)
    FontSizeSlider:SetSliderValues(8, 64, 1)
    FontSizeSlider:SetRelativeWidth(0.25)
    FontSizeSlider:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Count.FontSize = value UpdateMultiFrameUnit(unit, function() UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end) end)
    CountContainer:AddChild(FontSizeSlider)

    local ColourPicker = AG:Create("ColorPicker")
    ColourPicker:SetLabel("Colour")
    ColourPicker:SetColor(AuraDB.Count.Colour[1], AuraDB.Count.Colour[2], AuraDB.Count.Colour[3], 1)
    ColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b) AuraDB.Count.Colour = {r, g, b} UpdateMultiFrameUnit(unit, function() UUF:UpdateUnitAuras(UUF[unit:upper()], unit, auraDB) end) end)
    ColourPicker:SetHasAlpha(false)
    ColourPicker:SetRelativeWidth(0.25)
    CountContainer:AddChild(ColourPicker)

    local function RefreshAuraGUI()
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

-- Aura coordinator: TabGroup for Buffs/Debuffs
function GUIUnits:CreateAuraSettings(containerParent, unit, updateCallback)
    local AurasDB = UUF.db.profile.Units[unit].Auras
    local AuraDurationContainer = GUIWidgets.CreateInlineGroup(containerParent, "Aura Duration Settings")

    local ColourPicker = AG:Create("ColorPicker")
    ColourPicker:SetLabel("Cooldown Text Colour")
    ColourPicker:SetColor(UUF.db.profile.Units[unit].Auras.AuraDuration.Colour[1], UUF.db.profile.Units[unit].Auras.AuraDuration.Colour[2], UUF.db.profile.Units[unit].Auras.AuraDuration.Colour[3], 1)
    ColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b) UUF.db.profile.Units[unit].Auras.AuraDuration.Colour = {r, g, b} UpdateMultiFrameUnit(unit, function() UUF:UpdateUnitAuras(UUF[unit:upper()], unit, "AuraDuration") end) end)
    ColourPicker:SetHasAlpha(false)
    ColourPicker:SetRelativeWidth(0.5)
    AuraDurationContainer:AddChild(ColourPicker)

    local ScaleByIconSizeCheckbox = AG:Create("CheckBox")
    ScaleByIconSizeCheckbox:SetLabel("Scale Cooldown Text By Icon Size")
    ScaleByIconSizeCheckbox:SetValue(UUF.db.profile.Units[unit].Auras.AuraDuration.ScaleByIconSize)
    ScaleByIconSizeCheckbox:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.Units[unit].Auras.AuraDuration.ScaleByIconSize = value UpdateMultiFrameUnit(unit, function() UUF:UpdateUnitAuras(UUF[unit:upper()], unit, "AuraDuration") end) RefreshFontSizeSlider() end)
    ScaleByIconSizeCheckbox:SetRelativeWidth(0.5)
    AuraDurationContainer:AddChild(ScaleByIconSizeCheckbox)

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(UUF.db.profile.Units[unit].Auras.AuraDuration.Layout[1])
    AnchorFromDropdown:SetRelativeWidth(0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.Units[unit].Auras.AuraDuration.Layout[1] = value UpdateMultiFrameUnit(unit, function() UUF:UpdateUnitAuras(UUF[unit:upper()], unit, "AuraDuration") end) end)
    AuraDurationContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(UUF.db.profile.Units[unit].Auras.AuraDuration.Layout[2])
    AnchorToDropdown:SetRelativeWidth(0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.Units[unit].Auras.AuraDuration.Layout[2] = value UpdateMultiFrameUnit(unit, function() UUF:UpdateUnitAuras(UUF[unit:upper()], unit, "AuraDuration") end) end)
    AuraDurationContainer:AddChild(AnchorToDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(UUF.db.profile.Units[unit].Auras.AuraDuration.Layout[3])
    XPosSlider:SetSliderValues(-1000, 1000, 0.1)
    XPosSlider:SetRelativeWidth(0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.Units[unit].Auras.AuraDuration.Layout[3] = value UpdateMultiFrameUnit(unit, function() UUF:UpdateUnitAuras(UUF[unit:upper()], unit, "AuraDuration") end) end)
    AuraDurationContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(UUF.db.profile.Units[unit].Auras.AuraDuration.Layout[4])
    YPosSlider:SetSliderValues(-1000, 1000, 0.1)
    YPosSlider:SetRelativeWidth(0.33)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.Units[unit].Auras.AuraDuration.Layout[4] = value UpdateMultiFrameUnit(unit, function() UUF:UpdateUnitAuras(UUF[unit:upper()], unit, "AuraDuration") end) end)
    AuraDurationContainer:AddChild(YPosSlider)

    local FontSizeSlider = AG:Create("Slider")
    FontSizeSlider:SetLabel("Font Size")
    FontSizeSlider:SetValue(UUF.db.profile.Units[unit].Auras.AuraDuration.FontSize)
    FontSizeSlider:SetSliderValues(8, 64, 1)
    FontSizeSlider:SetRelativeWidth(0.33)
    FontSizeSlider:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.Units[unit].Auras.AuraDuration.FontSize = value UpdateMultiFrameUnit(unit, function() UUF:UpdateUnitAuras(UUF[unit:upper()], unit, "AuraDuration") end) end)
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
        GUIUnits:CreateSpecificAuraSettings(AuraContainer, unit, AuraTab)
        UUF:ScheduleTimer("RefreshFontSize", 0.001, RefreshFontSizeSlider)
        containerParent:DoLayout()
    end

    local AuraContainerTabGroup = AG:Create("TabGroup")
    AuraContainerTabGroup:SetTabs({ { text = "Buffs", value = "Buffs"}, { text = "Debuffs", value = "Debuffs"}, })
    AuraContainerTabGroup:SetLayout("Flow")
    AuraContainerTabGroup:SetFullWidth(true)
    AuraContainerTabGroup:SetCallback("OnGroupSelected", SelectAuraTab)
    AuraContainerTabGroup:SelectTab(GetSavedSubTab(unit, "Auras", "Buffs"))
    containerParent:AddChild(AuraContainerTabGroup)

    containerParent:DoLayout()
end

-- Return module
return GUIUnits
