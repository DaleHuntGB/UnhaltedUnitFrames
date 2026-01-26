--[[
    CustomHealthColors.lua
    
    Custom health percentage color system
    This file contains ONLY custom code that is NOT in the original UnhaltedUnitFrames
    
    IMPORTANT: This file is independent from the base addon.
    When you update UnhaltedUnitFrames, this file will NOT be overwritten.
    
    Author: Adan Sanchez Manzano
    Date: 2026-01-22
]]--

local _, UUF = ...

-- Namespace for custom code
UUF.CustomHealthColors = {}
local CustomHealthColors = UUF.CustomHealthColors

-- ============================================
-- CUSTOM DEFAULTS CONFIGURATION
-- ============================================
function CustomHealthColors:GetDefaultColors()
    return {
        {percent = 0,    color = {1, 0, 0},     enabled = true},   -- Red (0%)
        {percent = 0.25, color = {1, 0.5, 0},   enabled = false},  -- Orange (25%)
        {percent = 0.50, color = {1, 1, 0},     enabled = false},  -- Yellow (50%)
        {percent = 0.75, color = {0.5, 1, 0},   enabled = false},  -- Light Green (75%)
        {percent = 1.0,  color = {0, 1, 0},     enabled = true},   -- Green (100%)
    }
end

-- ============================================
-- COLOR APPLICATION LOGIC
-- ============================================

--[[
    Applies the color curve to the unitFrame based on configured points
    This is the MAIN function that connects configuration with oUF
    
    @param unitFrame - The unit frame (UUF_Player, UUF_Target, etc.)
    @param HealthBarDB - The health bar configuration
]]
function CustomHealthColors:ApplyColorCurve(unitFrame, HealthBarDB)
    if not HealthBarDB.ColourByHealthPercent then return end
    
    -- Initialize oUF color system if it doesn't exist
    if not unitFrame.colors then unitFrame.colors = {} end
    if not unitFrame.colors.health then
        unitFrame.colors.health = UUF.oUF:CreateColor(0, 1, 0) -- Base color
    end
    
    -- Initialize table if it doesn't exist
    if not HealthBarDB.HealthPercentColors then
        HealthBarDB.HealthPercentColors = {}
    end
    
    -- Detect if it's new structure (array) or old (table with keys)
    local isNewStructure = HealthBarDB.HealthPercentColors[1] ~= nil
    
    if isNewStructure then
        self:ApplyNewStructureCurve(unitFrame, HealthBarDB)
    else
        self:ApplyOldStructureCurve(unitFrame, HealthBarDB)
    end
end

--[[
    Applies the color curve using the new structure (array of objects)
    This is the custom structure with checkboxes and editable percentages
]]
function CustomHealthColors:ApplyNewStructureCurve(unitFrame, HealthBarDB)
    -- Validate that it has at least 2 points
    if #HealthBarDB.HealthPercentColors < 2 then
        HealthBarDB.HealthPercentColors = {
            {percent = 0,   color = {1, 0, 0}, enabled = true},
            {percent = 1.0, color = {0, 1, 0}, enabled = true},
        }
    end
    
    -- Sort by percentage
    table.sort(HealthBarDB.HealthPercentColors, function(a, b) return a.percent < b.percent end)
    
    -- Create curve points table (only enabled points)
    local curvePoints = {}
    local pointCount = 0
    for _, point in ipairs(HealthBarDB.HealthPercentColors) do
        if point.enabled and point.color and #point.color >= 3 then
            curvePoints[point.percent] = CreateColor(point.color[1], point.color[2], point.color[3], 1)
            pointCount = pointCount + 1
        end
    end
    
    -- Only apply the curve if there are at least 2 enabled points
    if pointCount >= 2 then
        unitFrame.colors.health:SetCurve(curvePoints)
    else
        -- If not enough points, use default gradient
        unitFrame.colors.health:SetCurve({
            [0] = CreateColor(1, 0, 0, 1),
            [1] = CreateColor(0, 1, 0, 1)
        })
    end
end

--[[
    Applies the color curve using the old structure (table with keys)
    This is the original UnhaltedUnitFrames structure for other units
]]
function CustomHealthColors:ApplyOldStructureCurve(unitFrame, HealthBarDB)
    -- Initialize default colors if they don't exist
    if not HealthBarDB.HealthPercentColors[0] then
        HealthBarDB.HealthPercentColors[0] = {1, 0, 0}      -- Red (0%)
        HealthBarDB.HealthPercentColors[0.25] = {1, 0.5, 0} -- Orange (25%)
        HealthBarDB.HealthPercentColors[0.50] = {1, 1, 0}   -- Yellow (50%)
        HealthBarDB.HealthPercentColors[1.0] = {0, 1, 0}    -- Green (100%)
    end
    
    -- Create curve points table
    local curvePoints = {}
    for percent, color in pairs(HealthBarDB.HealthPercentColors) do
        if color and #color >= 3 then
            curvePoints[percent] = CreateColor(color[1], color[2], color[3], 1)
        end
    end
    
    -- Apply the curve
    unitFrame.colors.health:SetCurve(curvePoints)
end

--[[
    Clears the color curve from the unitFrame
    Useful when health percent coloring is disabled
]]
function CustomHealthColors:ClearColorCurve(unitFrame)
    if unitFrame.colors and unitFrame.colors.health then
        unitFrame.colors.health:SetCurve(nil)
    end
end

-- ============================================
-- DATA MIGRATION AND VALIDATION
-- ============================================
function CustomHealthColors:MigrateAndValidate(HealthBarDB)
    if not HealthBarDB then return end
    
    -- Detect if it's old structure (table with keys) or new (array)
    local isOldStructure = HealthBarDB.HealthPercentColors and HealthBarDB.HealthPercentColors[0] ~= nil
    
    if isOldStructure then
        -- Migrate from old structure to new
        local oldColors = HealthBarDB.HealthPercentColors
        HealthBarDB.HealthPercentColors = {
            {percent = 0,    color = oldColors[0] or {1, 0, 0},       enabled = true},
            {percent = 0.25, color = oldColors[0.25] or {1, 0.5, 0},  enabled = false},
            {percent = 0.50, color = oldColors[0.50] or {1, 1, 0},    enabled = false},
            {percent = 0.75, color = {0.5, 1, 0},                     enabled = false},
            {percent = 1.0,  color = oldColors[1.0] or {0, 1, 0},     enabled = true},
        }
    elseif #HealthBarDB.HealthPercentColors ~= 5 then
        -- Migrate from structure with different number of points to 5 fixed points
        local oldPoints = HealthBarDB.HealthPercentColors
        HealthBarDB.HealthPercentColors = self:GetDefaultColors()
        
        -- Copy colors from old points if they exist
        for _, oldPoint in ipairs(oldPoints) do
            for _, newPoint in ipairs(HealthBarDB.HealthPercentColors) do
                if math.abs(oldPoint.percent - newPoint.percent) < 0.05 then
                    newPoint.color = oldPoint.color
                    if oldPoint.enabled ~= nil then
                        newPoint.enabled = oldPoint.enabled
                    else
                        newPoint.enabled = true
                    end
                    break
                end
            end
        end
    end
    
    -- Ensure there are always exactly 5 points
    if #HealthBarDB.HealthPercentColors ~= 5 then
        HealthBarDB.HealthPercentColors = self:GetDefaultColors()
    end
    
    -- Ensure first and last points are always enabled
    HealthBarDB.HealthPercentColors[1].enabled = true
    HealthBarDB.HealthPercentColors[5].enabled = true
    HealthBarDB.HealthPercentColors[1].percent = 0
    HealthBarDB.HealthPercentColors[5].percent = 1.0
    
    -- Ensure all points have color and enabled initialized
    for i = 1, 5 do
        local point = HealthBarDB.HealthPercentColors[i]
        if not point.color or #point.color < 3 then
            point.color = {1, 1, 1}
        end
        if point.enabled == nil then
            point.enabled = (i == 1 or i == 5)
        end
    end
end

-- ============================================
-- GUI WIDGETS CREATION
-- ============================================
function CustomHealthColors:CreateGUIWidgets(HealthPercentGroup, HealthBarDB, unit, updateCallback)
    local AG = UUF.AG
    
    -- Migrate and validate data before creating widgets
    self:MigrateAndValidate(HealthBarDB)
    
    -- Create widgets for the 5 fixed points (all in one row)
    for i = 1, 5 do
        local RowGroup = AG:Create("SimpleGroup")
        RowGroup:SetFullWidth(true)
        RowGroup:SetLayout("Flow")
        HealthPercentGroup:AddChild(RowGroup)
        
        local point = HealthBarDB.HealthPercentColors[i]
        local isFirstOrLast = (i == 1 or i == 5)
        
        -- Checkbox to enable/disable the point
        local Checkbox = AG:Create("CheckBox")
        Checkbox:SetLabel("")
        Checkbox:SetValue(point.enabled)
        Checkbox:SetWidth(40)
        Checkbox:SetDisabled(isFirstOrLast)
        Checkbox:SetCallback("OnValueChanged", function(_, _, value)
            point.enabled = value
            updateCallback()
        end)
        RowGroup:AddChild(Checkbox)
        
        -- EditBox or Label for the percentage
        if isFirstOrLast then
            local PercentLabel = AG:Create("Label")
            PercentLabel:SetText(string.format("%.0f%%", point.percent * 100))
            PercentLabel:SetWidth(60)
            RowGroup:AddChild(PercentLabel)
        else
            local PercentEdit = AG:Create("EditBox")
            PercentEdit:SetLabel("")
            PercentEdit:SetText(string.format("%.0f%%", point.percent * 100))
            PercentEdit:SetWidth(60)
            PercentEdit:SetCallback("OnEnterPressed", function(widget, _, value)
                local numValue = tonumber(value:gsub("%%", ""))
                if numValue and numValue > 0 and numValue < 100 then
                    point.percent = numValue / 100
                    table.sort(HealthBarDB.HealthPercentColors, function(a, b) return a.percent < b.percent end)
                    print("|cff00ff00Percentage updated.|r Close and reopen the " .. unit .. " tab to see the new order.")
                    updateCallback()
                else
                    widget:SetText(string.format("%.0f%%", point.percent * 100))
                end
            end)
            RowGroup:AddChild(PercentEdit)
        end
        
        -- Color Picker (without SetRelativeWidth or SetFullWidth to keep it inline)
        local ColorPicker = AG:Create("ColorPicker")
        ColorPicker:SetLabel("Color")
        if not point.color or #point.color < 3 then
            point.color = {1, 1, 1}
        end
        ColorPicker:SetColor(unpack(point.color))
        ColorPicker:SetHasAlpha(false)
        ColorPicker:SetCallback("OnValueChanged", function(_, _, r, g, b)
            point.color = {r, g, b}
            updateCallback()
        end)
        RowGroup:AddChild(ColorPicker)
    end
    
    -- Reset to Default button
    local ResetButton = AG:Create("Button")
    ResetButton:SetText("Reset to Default")
    ResetButton:SetFullWidth(true)
    ResetButton:SetCallback("OnClick", function()
        HealthBarDB.HealthPercentColors = self:GetDefaultColors()
        print("|cff00ff00Colors reset to default.|r Close and reopen the " .. unit .. " tab to see the changes.")
        updateCallback()
    end)
    HealthPercentGroup:AddChild(ResetButton)
end

-- ============================================
-- HOOK TO INJECT INTO ORIGINAL GUI
-- ============================================
function CustomHealthColors:Initialize()
    -- Module initialized successfully
    -- print("|cff00ff00Custom Health Colors module loaded|r")
end

-- Initialize the module
CustomHealthColors:Initialize()
