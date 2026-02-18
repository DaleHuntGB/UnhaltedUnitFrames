local _, UUF = ...
local AG = UUF.AG

--- GUI Toolbar Component
--- Provides bulk operations: Copy, Paste, Reset, Apply, Presets, Comparison

local GUIToolbar = {}

local BUTTON_WIDTH = 70
local BUTTON_HEIGHT = 20
local BUTTON_SPACING = 2

--- Build toolbar UI component
function GUIToolbar:Create(parent, callbacks)
    callbacks = callbacks or {}
    
    local toolbar = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    toolbar:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
        insets = {left = 0, right = 0, top = 0, bottom = 0}
    })
    toolbar:SetBackdropColor(0.12, 0.12, 0.12, 0.9)
    toolbar:SetBackdropBorderColor(0.2, 0.2, 0.2, 0.8)
    toolbar:SetHeight(28)
    toolbar:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -32)
    toolbar:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, -32)

    -- Buttons: Copy, Paste, Reset, Apply
    local buttons = {}
    local currentX = 5

    -- Copy button
    buttons.copy = CreateFrame("Button", nil, toolbar, "UIPanelButtonTemplate")
    buttons.copy:SetHeight(BUTTON_HEIGHT)
    buttons.copy:SetWidth(BUTTON_WIDTH)
    buttons.copy:SetPoint("LEFT", toolbar, "LEFT", currentX, 0)
    buttons.copy:SetText("Copy")
    buttons.copy:SetScript("OnClick", function()
        if callbacks.onCopy then callbacks.onCopy() end
    end)
    buttons.copy:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("Copy current unit config", 1, 1, 1)
        GameTooltip:AddLine("Ctrl+C", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    buttons.copy:SetScript("OnLeave", function() GameTooltip:Hide() end)
    currentX = currentX + BUTTON_WIDTH + BUTTON_SPACING

    -- Paste button
    buttons.paste = CreateFrame("Button", nil, toolbar, "UIPanelButtonTemplate")
    buttons.paste:SetHeight(BUTTON_HEIGHT)
    buttons.paste:SetWidth(BUTTON_WIDTH)
    buttons.paste:SetPoint("LEFT", toolbar, "LEFT", currentX, 0)
    buttons.paste:SetText("Paste")
    buttons.paste:SetScript("OnClick", function()
        if callbacks.onPaste then callbacks.onPaste() end
    end)
    buttons.paste:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("Paste config from clipboard", 1, 1, 1)
        GameTooltip:AddLine("Ctrl+V", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    buttons.paste:SetScript("OnLeave", function() GameTooltip:Hide() end)
    currentX = currentX + BUTTON_WIDTH + BUTTON_SPACING

    -- Reset button
    buttons.reset = CreateFrame("Button", nil, toolbar, "UIPanelButtonTemplate")
    buttons.reset:SetHeight(BUTTON_HEIGHT)
    buttons.reset:SetWidth(BUTTON_WIDTH)
    buttons.reset:SetPoint("LEFT", toolbar, "LEFT", currentX, 0)
    buttons.reset:SetText("Reset")
    buttons.reset:SetScript("OnClick", function()
        if callbacks.onReset then callbacks.onReset() end
    end)
    buttons.reset:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("Reset unit to defaults", 1, 1, 1)
        GameTooltip:AddLine("Ctrl+R", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    buttons.reset:SetScript("OnLeave", function() GameTooltip:Hide() end)
    currentX = currentX + BUTTON_WIDTH + BUTTON_SPACING

    -- Presets dropdown
    buttons.presets = CreateFrame("Button", nil, toolbar, "UIPanelButtonTemplate")
    buttons.presets:SetHeight(BUTTON_HEIGHT)
    buttons.presets:SetWidth(BUTTON_WIDTH)
    buttons.presets:SetPoint("LEFT", toolbar, "LEFT", currentX, 0)
    buttons.presets:SetText("Presets")
    buttons.presets:SetScript("OnClick", function()
        if callbacks.onPresetsClick then callbacks.onPresetsClick() end
    end)
    buttons.presets:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("Save/Load presets", 1, 1, 1)
        GameTooltip:AddLine("Alt+P", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    buttons.presets:SetScript("OnLeave", function() GameTooltip:Hide() end)
    currentX = currentX + BUTTON_WIDTH + BUTTON_SPACING

    -- Comparison toggle
    buttons.compare = CreateFrame("Button", nil, toolbar, "UIPanelButtonTemplate")
    buttons.compare:SetHeight(BUTTON_HEIGHT)
    buttons.compare:SetWidth(BUTTON_WIDTH)
    buttons.compare:SetPoint("LEFT", toolbar, "LEFT", currentX, 0)
    buttons.compare:SetText("Compare")
    buttons.compare:SetScript("OnClick", function()
        if callbacks.onCompareClick then callbacks.onCompareClick() end
    end)
    buttons.compare:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("Compare unit configs", 1, 1, 1)
        GameTooltip:Show()
    end)
    buttons.compare:SetScript("OnLeave", function() GameTooltip:Hide() end)

    toolbar.buttons = buttons
    return toolbar
end

UUF.GUIToolbar = GUIToolbar
return GUIToolbar
