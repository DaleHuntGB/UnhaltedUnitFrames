local _, UUF = ...
local AG = UUF.AG

--- GUI Comparison Component
--- Provides side-by-side configuration comparison between units

local GUIComparison = {}

--- Build comparison panel
function GUIComparison:CreatePanel(parent, callbacks)
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
    panel:SetSize(500, 450)
    panel:SetPoint("CENTER", parent, "CENTER", 0, 0)

    -- Title
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontBold")
    title:SetPoint("TOP", panel, "TOP", 0, -10)
    title:SetText("Configuration Comparison")

    -- Unit selectors
    local unitALabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    unitALabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -35)
    unitALabel:SetText("Unit A:")

    local unitADropdown = CreateFrame("Frame", nil, panel, "UIDropDownMenuTemplate")
    unitADropdown:SetPoint("LEFT", unitALabel, "RIGHT", 10, 0)
    panel.unitADropdown = unitADropdown

    local unitBLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    unitBLabel:SetPoint("LEFT", unitADropdown, "RIGHT", 20, 0)
    unitBLabel:SetText("Unit B:")

    local unitBDropdown = CreateFrame("Frame", nil, panel, "UIDropDownMenuTemplate")
    unitBDropdown:SetPoint("LEFT", unitBLabel, "RIGHT", 10, 0)
    panel.unitBDropdown = unitBDropdown

    -- Swap button
    local swapBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    swapBtn:SetHeight(20)
    swapBtn:SetWidth(40)
    swapBtn:SetPoint("LEFT", unitBDropdown, "RIGHT", 10, 0)
    swapBtn:SetText("Swap")
    swapBtn:SetScript("OnClick", function()
        local tmpA = panel.selectedUnitA
        panel.selectedUnitA = panel.selectedUnitB
        panel.selectedUnitB = tmpA
        GUIComparison:RefreshComparison(panel)
    end)

    -- Differences list
    local diffTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    diffTitle:SetPoint("TOPLEFT", unitALabel, "BOTTOMLEFT", 0, -15)
    diffTitle:SetText("Differences:")

    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetHeight(350)
    scrollFrame:SetPoint("TOPLEFT", diffTitle, "BOTTOMLEFT", 0, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -25, 30)

    local listContent = CreateFrame("Frame", nil, scrollFrame)
    listContent:SetSize(450, 1)
    scrollFrame:SetScrollChild(listContent)

    panel.scrollFrame = scrollFrame
    panel.listContent = listContent
    panel.maxHeight = 350
    panel.itemHeight = 25

    -- Copy A to B button
    local copyAToBBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    copyAToBBtn:SetHeight(22)
    copyAToBBtn:SetWidth(100)
    copyAToBBtn:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 10, 5)
    copyAToBBtn:SetText("A → B")
    copyAToBBtn:SetScript("OnClick", function()
        if panel.selectedUnitA and panel.selectedUnitB then
            -- Copy Unit A config to Unit B
            UUF:CopyUnitConfig(panel.selectedUnitA)
            UUF:PasteUnitConfig(panel.selectedUnitB)
            GUIComparison:RefreshComparison(panel)
            if callbacks.onCopyConfig then callbacks.onCopyConfig(panel.selectedUnitA, panel.selectedUnitB) end
        end
    end)

    -- Copy B to A button
    local copyBToABtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    copyBToABtn:SetHeight(22)
    copyBToABtn:SetWidth(100)
    copyBToABtn:SetPoint("LEFT", copyAToBBtn, "RIGHT", 5, 0)
    copyBToABtn:SetText("B → A")
    copyBToABtn:SetScript("OnClick", function()
        if panel.selectedUnitA and panel.selectedUnitB then
            -- Copy Unit B config to Unit A
            UUF:CopyUnitConfig(panel.selectedUnitB)
            UUF:PasteUnitConfig(panel.selectedUnitA)
            GUIComparison:RefreshComparison(panel)
            if callbacks.onCopyConfig then callbacks.onCopyConfig(panel.selectedUnitB, panel.selectedUnitA) end
        end
    end)

    -- Close button
    local closeBtn = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -2, -2)

    panel.selectedUnitA = nil
    panel.selectedUnitB = nil

    return panel
end

--- Refresh comparison display
function GUIComparison:RefreshComparison(panel)
    if not panel.selectedUnitA or not panel.selectedUnitB then
        panel.listContent:SetHeight(0)
        return
    end

    -- Get differences
    local differences = UUF:CompareUnitConfigs(panel.selectedUnitA, panel.selectedUnitB)
    
    -- Clear existing items
    for i = 1, panel.listContent:GetNumChildren() do
        panel.listContent:GetChild(i):Destroy()
    end

    if not differences or #differences == 0 then
        local noChange = panel.listContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        noChange:SetText("No differences")
        noChange:SetPoint("TOPLEFT", panel.listContent, "TOPLEFT", 0, 0)
        panel.listContent:SetHeight(20)
        return
    end

    -- Display differences
    local yOffset = 0
    for i, diff in ipairs(differences) do
        local diffItem = CreateFrame("Frame", nil, panel.listContent)
        diffItem:SetHeight(panel.itemHeight)
        diffItem:SetWidth(panel.listContent:GetWidth())
        diffItem:SetPoint("TOPLEFT", panel.listContent, "TOPLEFT", 0, yOffset)

        -- Path
        local pathStr = diffItem:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        pathStr:SetPoint("TOPLEFT", diffItem, "TOPLEFT", 0, 0)
        pathStr:SetText(diff.path)

        -- Values
        local valStr = diffItem:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        valStr:SetPoint("TOPLEFT", pathStr, "BOTTOMLEFT", 0, -2)
        local valA = tostring(diff.valueA):sub(1, 30)
        local valB = tostring(diff.valueB):sub(1, 30)
        valStr:SetText(string.format("|cFF00FF00%s|r vs |cFFFF0000%s|r", valA, valB))

        yOffset = yOffset - panel.itemHeight
    end

    local contentHeight = -yOffset
    if contentHeight > panel.maxHeight then
        contentHeight = panel.maxHeight
    end
    panel.listContent:SetHeight(contentHeight)
    panel.scrollFrame:UpdateScrollChildRect()
end

UUF.GUIComparison = GUIComparison
return GUIComparison
