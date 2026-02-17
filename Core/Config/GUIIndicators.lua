local _, UUF = ...
local AceGUI = LibStub("AceGUI-3.0")
local GUIWidgets = UUF.GUIWidgets
local GUIMacros = UUF.GUIMacros

-- GUI module for configuring all indicators (new and existing)
-- Handles: Runes, Stagger, Threat, Resurrect, Summon, Quest, PvPClassification, PowerPrediction

local GUIIndicators = {}

-- Build the indicator configuration section for a unit
function GUIIndicators:BuildIndicatorsPanel(unit)
    local container = AceGUI:Create("SimpleGroup")
    container:SetLayout("List")
    container:SetFullWidth(true)
    
    local unitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)]
    if not unitDB or not unitDB.Indicators then
        return container
    end
    
    local IndicatorConfigs = self:GetIndicatorConfigs(unit)
    
    for indicatorName, config in pairs(IndicatorConfigs) do
        if config.enabled ~= false then -- Only show if not explicitly disabled for this unit
            local indicatorGroup = self:BuildIndicatorGroup(unit, indicatorName, config)
            if indicatorGroup then
                container:AddChild(indicatorGroup)
            end
        end
    end
    
    return container
end

-- Get indicator-specific configurations for a unit
function GUIIndicators:GetIndicatorConfigs(unit)
    return {
        Runes = {
            label = "Runes",
            description = "Death Knight rune display",
            settings = { "Enabled", "Size", "Layout", "FrameStrata" },
        },
        Stagger = {
            label = "Stagger",
            description = "Monk stagger meter",
            settings = { "Enabled", "Width", "Height", "Foreground", "Background", "ForegroundOpacity", "BackgroundOpacity", "FrameStrata" },
        },
        ThreatIndicator = {
            label = "Threat",
            description = "Threat level indicator glow",
            settings = { "Enabled", "Size", "Colour", "Opacity", "FrameStrata" },
        },
        ResurrectIndicator = {
            label = "Resurrect",
            description = "Resurrection status indicator",
            settings = { "Enabled", "Size", "Layout", "FrameStrata" },
        },
        SummonIndicator = {
            label = "Summon",
            description = "Summon status indicator",
            settings = { "Enabled", "Size", "Layout", "FrameStrata" },
        },
        QuestIndicator = {
            label = "Quest",
            description = "Quest objective indicator",
            settings = { "Enabled", "Size", "Layout", "FrameStrata" },
        },
        PvPClassification = {
            label = "PvP Classification",
            description = "PvP status and rank display",
            settings = { "Enabled", "Size", "Layout", "FrameStrata" },
        },
        PowerPrediction = {
            label = "Power Prediction",
            description = "Predicted power bar",
            settings = { "Enabled", "Width", "Height", "Colour", "Opacity", "BackgroundOpacity", "FrameStrata" },
        },
    }
end

-- Build a single indicator configuration group
function GUIIndicators:BuildIndicatorGroup(unit, indicatorKey, indicatorInfo)
    if not indicatorInfo then return nil end
    
    local container = AceGUI:Create("SimpleGroup")
    container:SetLayout("List")
    container:SetFullWidth(true)
    
    local unitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)]
    local indicatorDB = unitDB.Indicators[indicatorKey]
    
    if not indicatorDB then return nil end
    
    -- Header
    local header = GUIMacros:CreateHeadingWithDescription(nil, indicatorInfo.label, indicatorInfo.description)
    container:AddChild(header)
    
    -- Enabled toggle
    local _, enableCheckbox = GUIMacros:CreateLabeledCheckbox(
        nil,
        "Enabled",
        indicatorDB.Enabled,
        function(widget, event, value)
            indicatorDB.Enabled = value
            UUF:UpdateAllUnitFrames()
        end
    )
    container:AddChild(_)
    
    -- Size (for most indicators)
    if indicatorDB.Size then
        local _, sizeSlider = GUIMacros:CreateLabeledSlider(
            nil,
            "Size:",
            1,
            100,
            indicatorDB.Size,
            1,
            function(widget, event, value)
                indicatorDB.Size = value
                UUF:UpdateAllUnitFrames()
            end
        )
        container:AddChild(_)
    end
    
    -- Width/Height (for bar-type indicators)
    if indicatorDB.Width then
        local _, widthSlider = GUIMacros:CreateLabeledSlider(
            nil,
            "Width:",
            10,
            500,
            indicatorDB.Width,
            1,
            function(widget, event, value)
                indicatorDB.Width = value
                UUF:UpdateAllUnitFrames()
            end
        )
        container:AddChild(_)
    end
    
    if indicatorDB.Height then
        local _, heightSlider = GUIMacros:CreateLabeledSlider(
            nil,
            "Height:",
            1,
            50,
            indicatorDB.Height,
            1,
            function(widget, event, value)
                indicatorDB.Height = value
                UUF:UpdateAllUnitFrames()
            end
        )
        container:AddChild(_)
    end
    
    -- Colour
    if indicatorDB.Colour then
        local _, colorPicker = GUIMacros:CreateLabeledColorPicker(
            nil,
            "Colour:",
            indicatorDB.Colour,
            function(widget, event, r, g, b)
                indicatorDB.Colour = {r, g, b}
                UUF:UpdateAllUnitFrames()
            end
        )
        container:AddChild(_)
    end
    
    -- Opacity controls
    if indicatorDB.Opacity then
        local _, opacitySlider = GUIMacros:CreateLabeledSlider(
            nil,
            "Opacity:",
            0,
            1,
            indicatorDB.Opacity,
            0.05,
            function(widget, event, value)
                indicatorDB.Opacity = value
                UUF:UpdateAllUnitFrames()
            end
        )
        container:AddChild(_)
    end
    
    if indicatorDB.ForegroundOpacity then
        local _, fgOpacitySlider = GUIMacros:CreateLabeledSlider(
            nil,
            "Foreground Opacity:",
            0,
            1,
            indicatorDB.ForegroundOpacity,
            0.05,
            function(widget, event, value)
                indicatorDB.ForegroundOpacity = value
                UUF:UpdateAllUnitFrames()
            end
        )
        container:AddChild(_)
    end
    
    if indicatorDB.BackgroundOpacity then
        local _, bgOpacitySlider = GUIMacros:CreateLabeledSlider(
            nil,
            "Background Opacity:",
            0,
            1,
            indicatorDB.BackgroundOpacity,
            0.05,
            function(widget, event, value)
                indicatorDB.BackgroundOpacity = value
                UUF:UpdateAllUnitFrames()
            end
        )
        container:AddChild(_)
    end
    
    -- FrameStrata
    if indicatorDB.FrameStrata then
        local strataOptions = {
            "BACKGROUND",
            "LOW",
            "MEDIUM",
            "HIGH",
            "DIALOG",
            "FULLSCREEN",
            "FULLSCREEN_DIALOG",
            "TOOLTIP",
        }
        local strataMap = {
            BACKGROUND = "Background",
            LOW = "Low",
            MEDIUM = "Medium",
            HIGH = "High",
            DIALOG = "Dialog",
            FULLSCREEN = "Fullscreen",
            FULLSCREEN_DIALOG = "Fullscreen Dialog",
            TOOLTIP = "Tooltip",
        }
        local _, strataDropdown = GUIMacros:CreateLabeledDropdown(
            nil,
            "Frame Strata:",
            strataMap,
            indicatorDB.FrameStrata,
            function(widget, event, value)
                indicatorDB.FrameStrata = value
                UUF:UpdateAllUnitFrames()
            end
        )
        container:AddChild(_)
    end
    
    -- Layout (position controls)
    if indicatorDB.Layout then
        local _, layoutGroup = GUIMacros:CreateLayoutGroup(
            nil,
            indicatorDB.Layout,
            function(widget, event, value)
                if indicatorDB.Layout then indicatorDB.Layout[1] = value end
                UUF:UpdateAllUnitFrames()
            end,
            function(widget, event, value)
                if indicatorDB.Layout then indicatorDB.Layout[3] = value end
                UUF:UpdateAllUnitFrames()
            end,
            function(widget, event, value)
                if indicatorDB.Layout then indicatorDB.Layout[4] = value end
                UUF:UpdateAllUnitFrames()
            end
        )
        container:AddChild(_)
    end
    
    return container
end

UUF.GUIIndicators = GUIIndicators
return GUIIndicators