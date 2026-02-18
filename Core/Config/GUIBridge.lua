local _, UUF = ...

-- AbstractFramework Detection & Bridge Layer
-- Provides unified API that works with or without AbstractFramework installed

-- Detect AbstractFramework
UUF.AF = _G.AbstractFramework or _G.AF
UUF.HasAbstractFramework = (UUF.AF ~= nil)

-- Initialize GUI namespace
UUF.GUI = UUF.GUI or {}

-- Feature availability flags
UUF.GUI.Features = {
    Sidebar = true,  -- Always available (uses AF if present, fallback otherwise)
    Search = UUF.HasAbstractFramework,
    Comparison = UUF.HasAbstractFramework,
    Presets = UUF.HasAbstractFramework,
    SmoothAnimations = UUF.HasAbstractFramework,
    -- Features that work without AF
    BasicConfig = true,
    TabGroups = true,
    FrameMover = true,
    Profiles = true,
    Tags = true,
}

-- Bridge API: Create Sidebar
function UUF.GUI:CreateSidebar(parent, width)
    if UUF.HasAbstractFramework then
        -- Use AbstractFramework's scroll frame
        local sidebar = UUF.AF.CreateFrame(parent, nil, width, parent:GetHeight())
        sidebar:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
        sidebar:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 0)
        
        -- Create tree using AF widgets (placeholder - full implementation in future phases)
        local scrollFrame = UUF.AF.CreateScrollFrame(sidebar, width - 10, sidebar:GetHeight() - 10)
        scrollFrame:SetPoint("CENTER")
        
        -- TODO: Implement AF tree nodes in Phase 3
        
        return sidebar, scrollFrame
    else
        -- Fallback: Use native tree widget
        local sidebar = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        sidebar:SetSize(width, parent:GetHeight())
        sidebar:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
        sidebar:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 0)
        sidebar:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            tile = false, edgeSize = 1,
        })
        sidebar:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
        sidebar:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
        
        -- Create fallback tree
        local tree = UUF.GUI:CreateTreeWidget(sidebar, width)
        tree:BuildTree()
        tree:Layout()
        
        return sidebar, tree
    end
end

-- Bridge API: Create Tree Node
function UUF.GUI:CreateTreeNode(parent, text, icon, data)
    if UUF.HasAbstractFramework then
        -- Use AbstractFramework button
        local node = UUF.AF.CreateButton(parent, text, "default", parent:GetWidth() - 20, 20)
        if icon then
            -- Add icon texture
            local iconTex = node:CreateTexture(nil, "ARTWORK")
            iconTex:SetSize(16, 16)
            iconTex:SetPoint("LEFT", node, "LEFT", 5, 0)
            iconTex:SetTexture(icon)
            node.icon = iconTex
        end
        node.data = data
        return node
    else
        -- Fallback: Create basic button
        local node = CreateFrame("Button", nil, parent, "BackdropTemplate")
        node:SetSize(parent:GetWidth() - 20, 20)
        node:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            tile = false,
        })
        node:SetBackdropColor(0.2, 0.2, 0.2, 0.8)
        
        local text = node:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("LEFT", 25, 0)
        text:SetText(text)
        node.text = text
        
        if icon then
            local iconTex = node:CreateTexture(nil, "ARTWORK")
            iconTex:SetSize(16, 16)
            iconTex:SetPoint("LEFT", 5, 0)
            iconTex:SetTexture(icon)
            node.icon = iconTex
        end
        
        node:SetScript("OnEnter", function(self)
            self:SetBackdropColor(0.3, 0.3, 0.3, 1)
        end)
        node:SetScript("OnLeave", function(self)
            self:SetBackdropColor(0.2, 0.2, 0.2, 0.8)
        end)
        
        node.data = data
        return node
    end
end

-- Bridge API: Create Search Box
function UUF.GUI:CreateSearchBox(parent)
    if UUF.HasAbstractFramework then
        -- Use AbstractFramework EditBox
        return UUF.AF.CreateEditBox(parent, nil, parent:GetWidth() - 20, 25)
    else
        -- Fallback: Create basic EditBox
        local editBox = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
        editBox:SetSize(parent:GetWidth() - 20, 25)
        editBox:SetAutoFocus(false)
        editBox:SetFontObject(GameFontNormal)
        return editBox
    end
end

-- Bridge API: Create Compact Button
function UUF.GUI:CreateCompactButton(parent, text, width, height)
    if UUF.HasAbstractFramework then
        return UUF.AF.CreateButton(parent, text, "accent", width, height)
    else
        -- Fallback: Create basic button
        local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
        button:SetSize(width, height)
        button:SetText(text)
        return button
    end
end

-- Bridge API: Show feature unavailable dialog
function UUF.GUI:ShowFeatureUnavailableDialog(featureName)
    StaticPopupDialogs["UUF_ABSTRACTFRAMEWORK_REQUIRED"] = {
        text = string.format("%s requires AbstractFramework.\n\nInstall AbstractFramework for enhanced configuration features including search, comparison view, and presets.\n\nAll core functionality works without it.", featureName),
        button1 = "Learn More",
        button2 = "Maybe Later",
        OnAccept = function()
            print("UnhaltedUnitFrames: Visit CurseForge or Wago.io to download AbstractFramework")
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("UUF_ABSTRACTFRAMEWORK_REQUIRED")
end

-- Utility: Check if feature is available
function UUF.GUI:IsFeatureAvailable(featureName)
    return UUF.GUI.Features[featureName] == true
end
