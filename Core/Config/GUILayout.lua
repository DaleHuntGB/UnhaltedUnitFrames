local _, UUF = ...
local AG = UUF.AG
local Arch = UUF.Architecture

-- GUI-specific LayoutColumn wrapper using Architecture.LayoutColumn
-- Reduces hardcoded positioning and provides consistent layout patterns

local GUILayout = {}
UUF.GUILayout = GUILayout

-- Create a vertical stack builder for GUI panels
function GUILayout:CreateStackBuilder(container)
    local stackState = {
        container = container,
        widgets = {},
        currentY = 0,
        itemHeight = 25,
        padding = 5,
        fullWidth = true
    }
    
    function stackState:Add(widget, height)
        height = height or self.itemHeight
        self.widgets[#self.widgets + 1] = widget
        self.container:AddChild(widget)
        return self
    end
    
    function stackState:Spacing(height)
        height = height or self.padding
        self.currentY = self.currentY + height
        return self
    end
    
    function stackState:Header(text)
        local header = AG:Create("Heading")
        header:SetText(text)
        header:SetRelativeWidth(1.0)
        self:Add(header)
        return self
    end
    
    function stackState:Row(...)
        -- Helper for adding multiple widgets in a single row with relative widths
        local count = select('#', ...)
        local widgets = {...}
        local baseWidth = 1.0 / count
        for i, widget in ipairs(widgets) do
            if i == count then
                widget:SetRelativeWidth(baseWidth)
            else
                widget:SetRelativeWidth(baseWidth)
            end
        end
        for _, widget in ipairs(widgets) do
            self:Add(widget)
        end
        return self
    end
    
    function stackState:ResetLayout()
        self.currentY = 0
        return self
    end
    
    return stackState
end

-- Helper to create checkbox with callback
function GUILayout:CheckBox(label, initialValue, callback)
    local cb = AG:Create("CheckBox")
    cb:SetLabel(label)
    cb:SetValue(initialValue or false)
    cb:SetFullWidth(true)
    if callback then
        cb:SetCallback("OnValueChanged", function(_, _, value)
            callback(value)
        end)
    end
    return cb
end

-- Helper to create slider with callback
function GUILayout:Slider(label, initialValue, minVal, maxVal, step, callback)
    local slider = AG:Create("Slider")
    slider:SetLabel(label)
    slider:SetValue(initialValue or minVal)
    slider:SetSliderValues(minVal, maxVal, step or 0.01)
    slider:SetFullWidth(true)
    if callback then
        slider:SetCallback("OnValueChanged", function(_, _, value)
            callback(value)
        end)
    end
    return slider
end

-- Helper to create dropdown with callback
function GUILayout:Dropdown(label, options, optionList, initialValue, callback)
    local dd = AG:Create("Dropdown")
    dd:SetLabel(label)
    dd:SetList(options, optionList)
    dd:SetValue(initialValue or optionList[1])
    dd:SetFullWidth(true)
    if callback then
        dd:SetCallback("OnValueChanged", function(_, _, value)
            callback(value)
        end)
    end
    return dd
end

-- Helper to create button with callback
function GUILayout:Button(label, callback, width)
    local btn = AG:Create("Button")
    btn:SetText(label)
    if width then
        btn:SetRelativeWidth(width)
    else
        btn:SetFullWidth(true)
    end
    if callback then
        btn:SetCallback("OnClick", callback)
    end
    return btn
end

-- Helper to create a group/container
function GUILayout:Group(title)
    local UUF_GUIWidgets = UUF.GUIWidgets
    return UUF_GUIWidgets.CreateInlineGroup(nil, title)
end

-- Pattern: Use this to build layout more efficiently
-- Example:
--[[
local builder = GUILayout:CreateStackBuilder(container)
builder:Header("Section Title")
builder:Add(GUILayout:CheckBox("Option 1", true, function(val) db.option1 = val end))
builder:Add(GUILayout:Slider("Value", 50, 0, 100, 1, function(val) db.value = val end))
builder:Spacing(10)
builder:Header("Another Section")
builder:Add(GUILayout:Button("Click Me", function() doSomething() end))
]]

-- Helper: Disable/enable all children in a group based on condition
function GUILayout:SetGroupEnabled(group, enabled)
    if not group or not group.children then return end
    for i = 1, #group.children do
        local child = group.children[i]
        if enabled then
            child:SetDisabled(false)
        else
            child:SetDisabled(true)
        end
    end
end

-- Helper: Collect all values from GUI widgets in a group
function GUILayout:CollectGroupValues(group)
    local values = {}
    if not group or not group.children then return values end
    for i = 1, #group.children do
        local child = group.children[i]
        if child.GetValue then
            local label = child.label:GetText() or ("widget_" .. i)
            values[label] = child:GetValue()
        end
    end
    return values
end

-- Helper: Apply values to GUI widgets in a group
function GUILayout:ApplyGroupValues(group, values)
    if not group or not group.children or not values then return end
    for i = 1, #group.children do
        local child = group.children[i]
        if child.SetValue then
            local label = child.label:GetText() or ("widget_" .. i)
            if values[label] ~= nil then
                child:SetValue(values[label])
            end
        end
    end
end

return GUILayout
