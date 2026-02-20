local _, UUF = ...
local GUILayout = UUF.GUILayout
local AG = UUF.AG

-- GUI Integration Helper: Demonstrates and provides helper functions for applying
-- GUILayout patterns throughout the configuration system
-- 
-- This module shows best practices for using GUILayout builder pattern
-- and can be included in other config files for consistent layout

local GUIIntegration = {}
UUF.GUIIntegration = GUIIntegration

-- Helper: Create a standard settings panel with GUILayout
function GUIIntegration:CreateSettingsPanel(containerParent, title, settingsList)
    local container = UUF.GUIWidgets.CreateInlineGroup(containerParent, title)
    local builder = GUILayout:CreateStackBuilder(container)
    
    for i, setting in ipairs(settingsList) do
        if setting.type == "header" then
            builder:Header(setting.text)
        elseif setting.type == "checkbox" then
            builder:Add(
                GUILayout:CheckBox(setting.label, setting.value, setting.callback)
            )
        elseif setting.type == "slider" then
            builder:Add(
                GUILayout:Slider(setting.label, setting.value, setting.min, setting.max, setting.step, setting.callback)
            )
        elseif setting.type == "dropdown" then
            builder:Add(
                GUILayout:Dropdown(setting.label, setting.options, setting.optionList, setting.value, setting.callback)
            )
        elseif setting.type == "button" then
            builder:Add(
                GUILayout:Button(setting.label, setting.callback, setting.width)
            )
        elseif setting.type == "space" then
            builder:Spacing(setting.height or 10)
        end
    end
    
    return container
end

-- Helper: Create appearance settings section
function GUIIntegration:CreateAppearanceSection(db)
    return {
        { type = "header", text = "Appearance" },
        { type = "checkbox", label = "Show Element", value = db.Enabled, callback = function(v) db.Enabled = v end },
        { type = "slider", label = "Size", value = db.Size or 25, min = 10, max = 100, step = 1, callback = function(v) db.Size = v end },
        { type = "slider", label = "Opacity", value = db.Opacity or 1, min = 0, max = 1, step = 0.1, callback = function(v) db.Opacity = v end },
        { type = "space", height = 10 },
    }
end

-- Helper: Create positioning settings section
function GUIIntegration:CreatePositioningSection(db)
    return {
        { type = "header", text = "Positioning" },
        { type = "dropdown", label = "Anchor Point", options = {
            ["TOPLEFT"] = "Top Left", ["TOP"] = "Top", ["TOPRIGHT"] = "Top Right",
            ["LEFT"] = "Left", ["CENTER"] = "Center", ["RIGHT"] = "Right",
            ["BOTTOMLEFT"] = "Bottom Left", ["BOTTOM"] = "Bottom", ["BOTTOMRIGHT"] = "Bottom Right"
        }, optionList = { "TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "CENTER", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT" },
            value = (db.Layout and db.Layout[1]) or "CENTER", callback = function(v) if db.Layout then db.Layout[1] = v end end },
        { type = "slider", label = "X Offset", value = (db.Layout and db.Layout[3]) or 0, min = -500, max = 500, step = 1, callback = function(v) if db.Layout then db.Layout[3] = v end end },
        { type = "slider", label = "Y Offset", value = (db.Layout and db.Layout[4]) or 0, min = -500, max = 500, step = 1, callback = function(v) if db.Layout then db.Layout[4] = v end end },
        { type = "space", height = 10 },
    }
end

-- Helper: Create color settings section
function GUIIntegration:CreateColorSection(db, colorLabel)
    colorLabel = colorLabel or "Color"
    return {
        { type = "header", text = colorLabel .. " Settings" },
        { type = "button", label = "Pick Color", callback = function() 
            print("Color picker not yet implemented in this helper")
        end },
        { type = "space", height = 10 },
    }
end

-- Helper: Create a complete indicator panel with all standard sections
function GUIIntegration:CreateIndicatorPanel(containerParent, db, elementName)
    elementName = elementName or "Element"
    
    local sections = {}
    
    -- Combine appearance, positioning, and color sections
    for _, item in ipairs(self:CreateAppearanceSection(db)) do
        table.insert(sections, item)
    end
    
    for _, item in ipairs(self:CreatePositioningSection(db)) do
        table.insert(sections, item)
    end
    
    for _, item in ipairs(self:CreateColorSection(db)) do
        table.insert(sections, item)
    end
    
    table.insert(sections, { type = "header", text = "Actions" })
    table.insert(sections, { type = "button", label = "Reset to Defaults", callback = function()
        print("Reset " .. elementName .. " to defaults (not yet implemented)")
    end })
    
    return self:CreateSettingsPanel(containerParent, elementName, sections)
end

-- Integration example: Apply GUILayout to a config panel
-- Usage:
--[[
local function CreateCustomPanel(containerParent)
    local builder = GUILayout:CreateStackBuilder(containerParent)
    
    builder:Header("Advanced Settings")
    builder:Add(GUILayout:CheckBox("Enable Feature", true, function(v)
        UUF.db.profile.Units.player.Feature = v
        UUF:UpdateAllUnitFrames()
    end))
    builder:Add(GUILayout:Slider("Feature Value", 50, 0, 100, 1, function(v)
        UUF.db.profile.Units.player.FeatureValue = v
        UUF:UpdateAllUnitFrames()
    end))
    builder:Spacing(15)
    builder:Header("Reset")
    builder:Add(GUILayout:Button("Reset All", function()
        print("Resetting...")
    end))
end
]]

-- Refactoring checklist: Which config files benefit from GUILayout
GUIIntegration.REFACTORING_CHECKLIST = {
    GUIGeneral = {
        status = "✅ DEMO",
        lines_before = 559,
        lines_after = 500,  -- estimated with GUILayout
        savings = 59,
        pattern = "Already has example with CreateFrameMoverSettings",
    },
    GUIFrameMover = {
        status = "✅ SIMPLE",
        lines_before = 35,
        lines_after = 25,
        savings = 10,
        pattern = "Already simple, minimal benefit",
    },
    GUIMacros = {
        status = "✅ HELPERS",
        lines_before = 193,
        lines_after = 150,
        savings = 43,
        pattern = "Already has macro helpers, ready for refactoring",
    },
    GUIIndicators = {
        status = "🔲 READY",
        lines_before = 300,  -- estimated
        lines_after = 200,  -- estimated with GUILayout
        savings = 100,
        pattern = "Multiple indicator sections - good candidate",
    },
    GUIUnits = {
        status = "🔲 READY",
        lines_before = 400,  -- estimated
        lines_after = 280,  -- estimated with GUILayout
        savings = 120,
        pattern = "Unit-specific config - needs refactoring",
    },
    GUITabProfiles = {
        status = "🔲 READY",
        lines_before = 250,  -- estimated
        lines_after = 170,  -- estimated with GUILayout
        savings = 80,
        pattern = "Profile management UI",
    },
    GUITabTags = {
        status = "🔲 READY",
        lines_before = 350,  -- estimated
        lines_after = 240,  -- estimated with GUILayout
        savings = 110,
        pattern = "Tag configuration UI",
    },
}

-- Print refactoring guide
function GUIIntegration:PrintRefactoringGuide()
    print("|cFF00B0F7=== GUI Refactoring Guide ===|r")
    print("Apply GUILayout pattern to reduce code duplication and improve maintainability")
    print("")
    
    local totalBefore = 0
    local totalAfter = 0
    local totalSavings = 0
    
    for file, data in pairs(self.REFACTORING_CHECKLIST) do
        print(string.format("%s [%s]:", file, data.status))
        print(string.format("  Lines: %d → %d (%d saved, %.1f%% reduction)", 
            data.lines_before, data.lines_after, data.savings, 
            (data.savings / data.lines_before * 100)))
        print("")
        
        totalBefore = totalBefore + data.lines_before
        totalAfter = totalAfter + data.lines_after
        totalSavings = totalSavings + data.savings
    end
    
    print("|cFF00B0F7Total Impact:|r")
    print(string.format("Before: %d lines", totalBefore))
    print(string.format("After: %d lines", totalAfter))
    print(string.format("Savings: %d lines (%.1f%% reduction)", totalSavings, (totalSavings / totalBefore * 100)))
end

-- Validate that GUILayout is properly loaded
function GUIIntegration:Validate()
    if not UUF.GUILayout then
        print("|cFFFF4040✗|r GUILayout not loaded")
        return false
    end
    
    print("|cFF00FF00✓|r GUILayout integration ready")
    return true
end

return GUIIntegration
