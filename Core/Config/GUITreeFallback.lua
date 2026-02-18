local _, UUF = ...

-- Fallback Tree Widget (used when AbstractFramework is not installed)
-- Simple collapsible tree implementation using native WoW frames

-- Ensure GUI namespace exists
UUF.GUI = UUF.GUI or {}

local TreeNodeMixin = {}

function TreeNodeMixin:SetExpanded(expanded)
    self.expanded = expanded
    if self.expandIcon then
        self.expandIcon:SetText(expanded and "−" or "+")
    end
    -- Let Layout() handle visibility
    if self.tree and self.tree.Layout then
        self.tree:Layout()
    end
end

function TreeNodeMixin:ToggleExpanded()
    self:SetExpanded(not self.expanded)
    if UUF.db and UUF.db.profile.GUI then
        UUF.db.profile.GUI.ExpandedNodes[self.nodeId] = self.expanded
    end
end

function TreeNodeMixin:SetSelected(selected)
    self.selected = selected
    if selected then
        self:SetBackdropColor(0.4, 0.4, 0.6, 1)
    else
        self:SetBackdropColor(0.2, 0.2, 0.2, 0.8)
    end
end

-- Create Tree Widget
function UUF.GUI:CreateTreeWidget(parent, width)
    local tree = CreateFrame("Frame", nil, parent)
    tree:SetSize(width, parent:GetHeight())
    tree:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    tree:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 0)
    tree.nodes = {}
    tree.nodeButtons = {}
    
    local scrollFrame = CreateFrame("ScrollFrame", nil, tree, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 5, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", -25, 5)
    
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(width - 35, 1)
    scrollFrame:SetScrollChild(scrollChild)
    tree.scrollFrame = scrollFrame  -- Expose scrollFrame
    tree.scrollChild = scrollChild
    
    -- Build tree from layout
    function tree:BuildTree(layout, indentLevel, parentBtn)
        layout = layout or UUF.GUI.TreeLayout
        indentLevel = indentLevel or 0
        parentBtn = parentBtn or nil  -- Store parent button reference
        
        for _, nodeData in ipairs(layout) do
            if nodeData.separator then
                -- Add visual separator
                local sep = scrollChild:CreateTexture(nil, "ARTWORK")
                sep:SetHeight(1)
                sep:SetColorTexture(0.5, 0.5, 0.5, 0.5)
                sep.isSeparator = true
                table.insert(self.nodeButtons, sep)
            else
                local button = CreateFrame("Button", nil, scrollChild, "BackdropTemplate")
                Mixin(button, TreeNodeMixin)
                button.tree = self
                button.nodeId = nodeData.id
                button.nodeData = nodeData
                button.indentLevel = indentLevel
                button.parentBtn = parentBtn  -- Store reference to parent button
                
                -- Full width button for even backgrounds
                button:SetSize(width - 35, 22)
                button:SetBackdrop({
                    bgFile = "Interface\\Buttons\\WHITE8X8",
                    tile = false,
                })
                button:SetBackdropColor(0.2, 0.2, 0.2, 0.8)
                
                -- Icon
                if nodeData.icon then
                    local icon = button:CreateTexture(nil, "ARTWORK")
                    icon:SetSize(16, 16)
                    icon:SetPoint("LEFT", (nodeData.children and 20 or 5) + (indentLevel * 15), 0)
                    icon:SetTexture(nodeData.icon)
                    button.icon = icon
                end
                
                -- Label
                local label = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                local labelOffset = 5 + (indentLevel * 15)
                if nodeData.children then
                    labelOffset = labelOffset + 15  -- space for expand icon
                end
                if nodeData.icon then
                    labelOffset = labelOffset + 20  -- space for icon (16px + 4px padding)
                end
                label:SetPoint("LEFT", labelOffset, 0)
                label:SetPoint("RIGHT", -5, 0)  -- Allow truncation if too long
                label:SetJustifyH("LEFT")
                label:SetWordWrap(false)
                label:SetText(nodeData.label)
                button.label = label
                
                button:SetScript("OnEnter", function(self)
                    if not self.selected then
                        self:SetBackdropColor(0.3, 0.3, 0.3, 1)
                    end
                end)
                button:SetScript("OnLeave", function(self)
                    if not self.selected then
                        self:SetBackdropColor(0.2, 0.2, 0.2, 0.8)
                    end
                end)
                button:SetScript("OnClick", function(self, btn)
                    if btn == "LeftButton" then
                        -- Always load content when clicking node label
                        if tree.OnNodeSelected then
                            tree:OnNodeSelected(self.nodeId, self.nodeData)
                        end
                        
                        -- For parent nodes, auto-expand if not already expanded
                        if self.hasChildren and not self.expanded then
                            self:SetExpanded(true)
                        end
                    end
                end)
                
                -- Check saved expanded state
                local savedExpanded = UUF.db and UUF.db.profile.GUI and UUF.db.profile.GUI.ExpandedNodes[nodeData.id]
                button.expanded = savedExpanded or false
                
                table.insert(self.nodeButtons, button)
                
                -- Create expand/collapse button LAST as child so it's on top in Z-order
                if nodeData.children then
                    local expandBtn = CreateFrame("Button", nil, button)
                    expandBtn:SetSize(14, 14)
                    expandBtn:SetPoint("LEFT", 5 + (indentLevel * 15), 0)
                    expandBtn:Show()
                    
                    local expandIcon = expandBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                    expandIcon:SetAllPoints()
                    expandIcon:SetText("+")
                    expandIcon:SetJustifyH("CENTER")
                    expandIcon:SetJustifyV("MIDDLE")
                    
                    button.expandIcon = expandIcon
                    button.expandBtn = expandBtn
                    button.hasChildren = true
                    
                    -- Click expand button to toggle expansion only (don't load content)
                    expandBtn:SetScript("OnClick", function(self, btn)
                        if btn == "LeftButton" then
                            button:ToggleExpanded()
                        end
                    end)
                    expandBtn:SetScript("OnEnter", function(self)
                        expandIcon:SetTextColor(1, 1, 0.5)
                    end)
                    expandBtn:SetScript("OnLeave", function(self)
                        expandIcon:SetTextColor(1, 1, 1)
                    end)
                else
                    button.hasChildren = false
                end
                
                -- Build children
                if nodeData.children then
                    button.children = {}
                    local childButtons = self:BuildTree(nodeData.children, indentLevel + 1, button)
                    for _, child in ipairs(childButtons) do
                        table.insert(button.children, child)
                    end
                end
            end
        end
        
        return self.nodeButtons
    end
    
    -- Layout nodes
    function tree:Layout()
        local yOffset = -5
        local visibleCount = 0
        for _, node in ipairs(self.nodeButtons) do
            if node.isSeparator then
                if node:IsShown() then
                    node:SetPoint("TOPLEFT", 5, yOffset)
                    node:SetPoint("TOPRIGHT", -5, yOffset)
                    yOffset = yOffset - 10
                end
            else
                -- Check if parent is collapsed
                local visible = true
                if node.indentLevel > 0 then
                    -- Find parent and check if expanded
                    visible = self:IsNodeVisible(node)
                end
                
                node:SetShown(visible)
                if visible then
                    visibleCount = visibleCount + 1
                    node:ClearAllPoints()
                    node:SetPoint("TOPLEFT", 5, yOffset)
                    yOffset = yOffset - 24
                    
                    -- Update expand icon text
                    if node.expandIcon then
                        node.expandIcon:SetText(node.expanded and "−" or "+")
                    end
                end
            end
        end
        
        scrollChild:SetHeight(math.abs(yOffset) + 10)
    end
    
    -- Check if node should be visible
    function tree:IsNodeVisible(node)
        if node.indentLevel == 0 then return true end
        
        -- Walk up the parent chain using stored parentBtn reference
        local currentBtn = node.parentBtn
        while currentBtn do
            if not currentBtn.expanded then
                return false
            end
            currentBtn = currentBtn.parentBtn
        end
        
        return true
    end
    
    -- Select node
    function tree:SelectNode(nodeId)
        for _, node in ipairs(self.nodeButtons) do
            if not node.isSeparator then
                node:SetSelected(node.nodeId == nodeId)
            end
        end
        if UUF.db and UUF.db.profile.GUI then
            UUF.db.profile.GUI.LastSelectedNode = nodeId
        end
    end
    
    -- Keyboard Navigation Support (Phase 4)
    function tree:SetFocusedNode(button)
        if self.focusedNode then
            self.focusedNode:SetAlpha(1.0)
        end
        self.focusedNode = button
        if button then
            button:SetAlpha(1.3)  -- Brighten focused node
            self:ScrollToNode(button)
        end
    end
    
    function tree:GetFocusedNode()
        return self.focusedNode
    end
    
    function tree:ScrollToNode(button)
        if not button or not button:IsShown() then return end
        
        local scrollFrame = scrollFrame
        local topOffset = button:GetTop()
        local bottomOffset = button:GetBottom()
        
        if not topOffset or not bottomOffset then return end
        
        -- Auto-scroll to keep focused node visible
        local scroll = scrollFrame:GetVerticalScroll()
        local maxScroll = scrollFrame:GetVerticalScrollRange()
        
        if topOffset > scrollFrame:GetTop() then
            -- Node is above visible area
            scrollFrame:SetVerticalScroll(scroll - (scrollFrame:GetTop() - topOffset) - 10)
        elseif bottomOffset < scrollFrame:GetBottom() then
            -- Node is below visible area
            scrollFrame:SetVerticalScroll(scroll + (bottomOffset - scrollFrame:GetBottom()) + 10)
        end
    end
    
    function tree:NavigateUp()
        if not self.focusedNode then
            -- Start from first visible node
            for _, node in ipairs(self.nodeButtons) do
                if not node.isSeparator and node:IsShown() then
                    self:SetFocusedNode(node)
                    return
                end
            end
        else
            -- Find previous visible node
            local currentIndex = nil
            for i, node in ipairs(self.nodeButtons) do
                if node == self.focusedNode then
                    currentIndex = i
                    break
                end
            end
            
            if currentIndex then
                for i = currentIndex - 1, 1, -1 do
                    local node = self.nodeButtons[i]
                    if not node.isSeparator and node:IsShown() then
                        self:SetFocusedNode(node)
                        return
                    end
                end
            end
        end
    end
    
    function tree:NavigateDown()
        if not self.focusedNode then
            -- Start from first visible node
            for _, node in ipairs(self.nodeButtons) do
                if not node.isSeparator and node:IsShown() then
                    self:SetFocusedNode(node)
                    return
                end
            end
        else
            -- Find next visible node
            local currentIndex = nil
            for i, node in ipairs(self.nodeButtons) do
                if node == self.focusedNode then
                    currentIndex = i
                    break
                end
            end
            
            if currentIndex then
                for i = currentIndex + 1, #self.nodeButtons do
                    local node = self.nodeButtons[i]
                    if not node.isSeparator and node:IsShown() then
                        self:SetFocusedNode(node)
                        return
                    end
                end
            end
        end
    end
    
    function tree:HandleKeyDown(key)
        if key == "UP" then
            self:NavigateUp()
        elseif key == "DOWN" then
            self:NavigateDown()
        elseif key == "LEFT" then
            if self.focusedNode and self.focusedNode.expanded then
                self.focusedNode:SetExpanded(false)
            end
        elseif key == "RIGHT" then
            if self.focusedNode and self.focusedNode.hasChildren and not self.focusedNode.expanded then
                self.focusedNode:SetExpanded(true)
            end
        elseif key == "RETURN" then
            if self.focusedNode then
                self.focusedNode:Click()
            end
        elseif key == "HOME" then
            for _, node in ipairs(self.nodeButtons) do
                if not node.isSeparator and node:IsShown() then
                    self:SetFocusedNode(node)
                    return
                end
            end
        elseif key == "END" then
            for i = #self.nodeButtons, 1, -1 do
                local node = self.nodeButtons[i]
                if not node.isSeparator and node:IsShown() then
                    self:SetFocusedNode(node)
                    return
                end
            end
        end
    end
    
    -- Clear search filtering - reset all node alpha values
    function tree:ClearSearch()
        for _, node in ipairs(self.nodeButtons) do
            if not node.isSeparator then
                node:SetAlpha(1.0)
            end
        end
    end
    
    -- Release tree and all child frames
    function tree:Release()
        -- Clear all node buttons and their scripts
        if self.nodeButtons then
            for _, node in ipairs(self.nodeButtons) do
                if node then
                    if node:GetObjectType() == "Button" then
                        -- Clear child frames (expand buttons, textures, font strings)
                        if node.expandBtn then
                            node.expandBtn:ClearAllPoints()
                            node.expandBtn:Hide()
                        end
                        -- Clear all points and hide
                        node:ClearAllPoints()
                        node:Hide()
                    elseif node:GetObjectType() == "Texture" then
                        node:ClearAllPoints()
                        node:Hide()
                    end
                end
            end
            self.nodeButtons = {}
        end
        
        -- Clear scroll child
        if scrollChild then
            scrollChild:ClearAllPoints()
            scrollChild:Hide()
            scrollChild = nil
        end
        
        -- Clear scroll frame
        if scrollFrame then
            scrollFrame:ClearAllPoints()
            scrollFrame:Hide()
            scrollFrame = nil
        end
        
        -- Clear tree frame itself
        if self then
            self:ClearAllPoints()
            self:Hide()
        end
        
        -- Clean up references
        self.focusedNode = nil
        self.selectedUnit = nil
    end
    
    -- Set up scroll frame key handler
    scrollFrame:EnableKeyboard(true)
    scrollFrame:SetScript("OnKeyDown", function(self, key)
        tree:HandleKeyDown(key)
    end)
    
    tree:Show()
    scrollFrame:Show()
    scrollChild:Show()
    
    return tree
end
