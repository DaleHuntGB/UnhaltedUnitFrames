local _, UUF = ...
local AceGUI = LibStub("AceGUI-3.0")
local GUIWidgets = UUF.GUIWidgets

-- Reusable widget factory methods and common patterns
-- Reduces code duplication across GUI modules

local GUIMacros = {}

-- Create a labeled slider with min/max values
function GUIMacros:CreateLabeledSlider(parent, label, min, max, currentValue, step, onChange)
    local container = AceGUI:Create("SimpleGroup")
    container:SetLayout("Flow")
    container:SetWidth(parent:GetWidth() or 300)
    
    local labelWidget = AceGUI:Create("Label")
    labelWidget:SetText(label)
    labelWidget:SetWidth(100)
    container:AddChild(labelWidget)
    
    local slider = AceGUI:Create("Slider")
    slider:SetLabel("")
    slider:SetMin(min)
    slider:SetMax(max)
    slider:SetStep(step or 1)
    slider:SetValue(currentValue or min)
    slider:SetWidth(150)
    if onChange then
        slider:SetCallback("OnValueChanged", onChange)
    end
    container:AddChild(slider)
    
    return container, slider
end

-- Create a labeled color picker
function GUIMacros:CreateLabeledColorPicker(parent, label, currentColor, onColorChange)
    local container = AceGUI:Create("SimpleGroup")
    container:SetLayout("Flow")
    container:SetWidth(parent:GetWidth() or 300)
    
    local labelWidget = AceGUI:Create("Label")
    labelWidget:SetText(label)
    labelWidget:SetWidth(100)
    container:AddChild(labelWidget)
    
    local colorPicker = AceGUI:Create("ColorPicker")
    colorPicker:SetLabel("")
    if currentColor then
        colorPicker:SetColor(currentColor[1], currentColor[2], currentColor[3], currentColor[4] or 1)
    end
    colorPicker:SetWidth(120)
    if onColorChange then
        colorPicker:SetCallback("OnValueChanged", onColorChange)
    end
    container:AddChild(colorPicker)
    
    return container, colorPicker
end

-- Create a labeled dropdown
function GUIMacros:CreateLabeledDropdown(parent, label, options, currentValue, onValueChange)
    local container = AceGUI:Create("SimpleGroup")
    container:SetLayout("Flow")
    container:SetWidth(parent:GetWidth() or 300)
    
    local labelWidget = AceGUI:Create("Label")
    labelWidget:SetText(label)
    labelWidget:SetWidth(100)
    container:AddChild(labelWidget)
    
    local dropdown = AceGUI:Create("Dropdown")
    dropdown:SetLabel("")
    dropdown:SetList(options)
    if currentValue then
        dropdown:SetValue(currentValue)
    end
    dropdown:SetWidth(150)
    if onValueChange then
        dropdown:SetCallback("OnValueChanged", onValueChange)
    end
    container:AddChild(dropdown)
    
    return container, dropdown
end

-- Create a labeled checkbox
function GUIMacros:CreateLabeledCheckbox(parent, label, isChecked, onValueChange)
    local container = AceGUI:Create("SimpleGroup")
    container:SetLayout("Flow")
    container:SetWidth(parent:GetWidth() or 300)
    
    local checkbox = AceGUI:Create("CheckBox")
    checkbox:SetLabel(label)
    checkbox:SetValue(isChecked or false)
    checkbox:SetWidth(250)
    if onValueChange then
        checkbox:SetCallback("OnValueChanged", onValueChange)
    end
    container:AddChild(checkbox)
    
    return container, checkbox
end

-- Create a labeled edit box
function GUIMacros:CreateLabeledEditBox(parent, label, currentValue, onTextChanged)
    local container = AceGUI:Create("SimpleGroup")
    container:SetLayout("Flow")
    container:SetWidth(parent:GetWidth() or 300)
    
    local labelWidget = AceGUI:Create("Label")
    labelWidget:SetText(label)
    labelWidget:SetWidth(100)
    container:AddChild(labelWidget)
    
    local editBox = AceGUI:Create("EditBox")
    editBox:SetLabel("")
    if currentValue then
        editBox:SetText(currentValue)
    end
    editBox:SetWidth(150)
    if onTextChanged then
        editBox:SetCallback("OnTextChanged", onTextChanged)
    end
    container:AddChild(editBox)
    
    return container, editBox
end

-- Create a simple section header
function GUIMacros:CreateSectionHeader(parent, title)
    local header = AceGUI:Create("Heading")
    header:SetText(title)
    header:SetFullWidth(true)
    return header
end

-- Create a heading with description
function GUIMacros:CreateHeadingWithDescription(parent, title, description)
    local container = AceGUI:Create("SimpleGroup")
    container:SetLayout("Flow")
    container:SetFullWidth(true)
    
    local heading = AceGUI:Create("Heading")
    heading:SetText(title)
    heading:SetFullWidth(true)
    container:AddChild(heading)
    
    if description then
        local desc = AceGUI:Create("Label")
        desc:SetText(description)
        desc:SetFullWidth(true)
        container:AddChild(desc)
    end
    
    return container
end

-- Create a layout selector group with position controls
function GUIMacros:CreateLayoutGroup(parent, layoutData, onAnchorChange, onOffsetXChange, onOffsetYChange)
    local container = AceGUI:Create("SimpleGroup")
    container:SetLayout("Flow")
    container:SetFullWidth(true)
    
    -- Anchor point dropdown
    local anchorPoints = {
        ["TOPLEFT"] = "Top Left",
        ["TOP"] = "Top",
        ["TOPRIGHT"] = "Top Right",
        ["LEFT"] = "Left",
        ["CENTER"] = "Center",
        ["RIGHT"] = "Right",
        ["BOTTOMLEFT"] = "Bottom Left",
        ["BOTTOM"] = "Bottom",
        ["BOTTOMRIGHT"] = "Bottom Right",
    }
    
    local _, anchorDropdown = self:CreateLabeledDropdown(parent, "Anchor:", anchorPoints, layoutData[1], onAnchorChange)
    container:AddChild(_)
    
    -- Offset X
    local _, offsetXSlider = self:CreateLabeledSlider(parent, "Offset X:", -500, 500, layoutData[3], 1, onOffsetXChange)
    container:AddChild(_)
    
    -- Offset Y
    local _, offsetYSlider = self:CreateLabeledSlider(parent, "Offset Y:", -500, 500, layoutData[4], 1, onOffsetYChange)
    container:AddChild(_)
    
    return container
end

UUF.GUIMacros = GUIMacros
return GUIMacros