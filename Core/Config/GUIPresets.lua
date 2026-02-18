local _, UUF = ...
local AG = UUF.AG

--- GUI Presets Component
--- Provides preset management UI: Save, Load, Delete, Export, Import

local GUIPresets = {}

--- Build presets panel
function GUIPresets:CreatePanel(parent, callbacks)
    callbacks = callbacks or {}
    
    local panel = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    panel:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
        insets = {left = 2, right = 2, top = 2, bottom = 2}
    })
    panel:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
    panel:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.9)
    panel:SetSize(300, 400)
    panel:SetPoint("CENTER", parent, "CENTER", 0, 0)

    -- Title
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontBold")
    title:SetPoint("TOP", panel, "TOP", 0, -10)
    title:SetText("Configuration Presets")

    -- Preset name input
    local nameLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nameLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -35)
    nameLabel:SetText("Preset Name:")

    local nameInput = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    nameInput:SetHeight(20)
    nameInput:SetWidth(260)
    nameInput:SetPoint("TOPLEFT", nameLabel, "BOTTOMLEFT", 0, -2)
    nameInput:SetAutoFocus(false)
    nameInput:SetMaxLetters(32)

    -- Description input
    local descLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    descLabel:SetPoint("TOPLEFT", nameInput, "BOTTOMLEFT", 0, -10)
    descLabel:SetText("Description:")

    local descInput = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    descInput:SetHeight(40)
    descInput:SetWidth(260)
    descInput:SetPoint("TOPLEFT", descLabel, "BOTTOMLEFT", 0, -2)
    descInput:SetAutoFocus(false)
    descInput:SetMaxLetters(128)
    descInput:SetMultiLine(true)

    -- Save button
    local saveBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    saveBtn:SetHeight(22)
    saveBtn:SetWidth(80)
    saveBtn:SetPoint("TOPLEFT", descInput, "BOTTOMLEFT", 0, -10)
    saveBtn:SetText("Save")
    saveBtn:SetScript("OnClick", function()
        local name = nameInput:GetText()
        local desc = descInput:GetText()
        if name ~= "" then
            UUF:SavePreset(name, desc, false)
            if callbacks.onSave then callbacks.onSave(name) end
            nameInput:SetText("")
            descInput:SetText("")
            GUIPresets:RefreshList(panel)
        end
    end)

    -- Preset list scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetHeight(150)
    scrollFrame:SetPoint("TOPLEFT", saveBtn, "BOTTOMLEFT", 0, -10)
    scrollFrame:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -25, -130)

    local listContent = CreateFrame("Frame", nil, scrollFrame)
    listContent:SetSize(250, 1)
    scrollFrame:SetScrollChild(listContent)

    panel.presetList = {}
    panel.scrollFrame = scrollFrame
    panel.listContent = listContent
    panel.nameInput = nameInput
    panel.descInput = descInput

    -- Load/Delete section
    local actionLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    actionLabel:SetPoint("TOPLEFT", scrollFrame, "BOTTOMLEFT", 0, -10)
    actionLabel:SetText("Selected:")

    local selectedPreset = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    selectedPreset:SetPoint("LEFT", actionLabel, "RIGHT", 5, 0)
    selectedPreset:SetText("(None)")
    panel.selectedPreset = selectedPreset

    -- Action buttons
    local loadBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    loadBtn:SetHeight(22)
    loadBtn:SetWidth(60)
    loadBtn:SetPoint("TOPLEFT", actionLabel, "BOTTOMLEFT", 0, -5)
    loadBtn:SetText("Load")
    loadBtn:SetScript("OnClick", function()
        local presetName = panel.selectedPresetName
        if presetName then
            UUF:LoadPreset(presetName, false)
            if callbacks.onLoad then callbacks.onLoad(presetName) end
        end
    end)
    panel.loadBtn = loadBtn

    local deleteBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    deleteBtn:SetHeight(22)
    deleteBtn:SetWidth(60)
    deleteBtn:SetPoint("LEFT", loadBtn, "RIGHT", 5, 0)
    deleteBtn:SetText("Delete")
    deleteBtn:SetScript("OnClick", function()
        local presetName = panel.selectedPresetName
        if presetName then
            UUF:DeletePreset(presetName, false)
            if callbacks.onDelete then callbacks.onDelete(presetName) end
            panel.selectedPresetName = nil
            selectedPreset:SetText("(None)")
            GUIPresets:RefreshList(panel)
        end
    end)
    panel.deleteBtn = deleteBtn

    local exportBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    exportBtn:SetHeight(22)
    exportBtn:SetWidth(60)
    exportBtn:SetPoint("LEFT", deleteBtn, "RIGHT", 5, 0)
    exportBtn:SetText("Export")
    exportBtn:SetScript("OnClick", function()
        local presetName = panel.selectedPresetName
        if presetName then
            local exportStr = UUF:ExportPreset(presetName, false)
            if callbacks.onExport then callbacks.onExport(presetName, exportStr) end
        end
    end)
    panel.exportBtn = exportBtn

    -- Close button
    local closeBtn = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -2, -2)

    GUIPresets:RefreshList(panel)
    
    return panel
end

--- Refresh preset list display
function GUIPresets:RefreshList(panel)
    if not panel or not panel.listContent then return end
    
    local presets = UUF:GetPresetList(false)
    panel.presetList = presets

    -- Clear existing list items
    for i = 1, panel.listContent:GetNumChildren() do
        panel.listContent:GetChild(i):Destroy()
    end

    -- Add preset buttons
    local yOffset = 0
    for i, preset in ipairs(presets) do
        local btn = CreateFrame("Button", nil, panel.listContent, "UIPanelButtonTemplate")
        btn:SetHeight(20)
        btn:SetWidth(240)
        btn:SetPoint("TOPLEFT", panel.listContent, "TOPLEFT", 0, yOffset)
        btn:SetText(preset.name)
        btn.presetName = preset.name

        btn:SetScript("OnClick", function(self)
            panel.selectedPresetName = preset.name
            panel.selectedPreset:SetText(preset.name)
            if panel.selectedBtn then
                panel.selectedBtn:SetNormalTexture("")
            end
            panel.selectedBtn = self
            self:SetNormalTexture("Interface\\Buttons\\UI-Highlight-RoundCorners")
        end)

        yOffset = yOffset - 25
    end

    if yOffset == 0 then
        panel.selectedPreset:SetText("(No presets)")
    end

    -- Update scroll area
    panel.listContent:SetHeight(-yOffset)
    panel.scrollFrame:UpdateScrollChildRect()
end

UUF.GUIPresets = GUIPresets
return GUIPresets
