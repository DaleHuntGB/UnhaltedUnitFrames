local _, UUF = ...
local AG = UUF.AG

--- GUI Search Component
--- Provides search box and filtering for tree nodes

local GUISearch = {}

--- Build search UI component
function GUISearch:Create(parent, onSearchChanged)
    local searchContainer = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    searchContainer:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
        insets = {left = 0, right = 0, top = 0, bottom = 0}
    })
    searchContainer:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    searchContainer:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
    searchContainer:SetHeight(32)
    searchContainer:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    searchContainer:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)

    -- Search label
    local label = searchContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("LEFT", searchContainer, "LEFT", 5, 0)
    label:SetText("Search:")

    -- Search input box
    local searchBox = CreateFrame("EditBox", nil, searchContainer, "InputBoxTemplate")
    searchBox:SetHeight(20)
    searchBox:SetWidth(150)
    searchBox:SetPoint("LEFT", label, "RIGHT", 5, 0)
    searchBox:SetAutoFocus(false)
    searchBox:SetMaxLetters(32)
    searchBox:EnableKeyboard(true)  -- Ensure keyboard input works (backspace, delete, etc)

    -- Result count
    local resultCount = searchContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    resultCount:SetPoint("LEFT", searchBox, "RIGHT", 10, 0)
    resultCount:SetText("0 matches")

    -- Clear button
    local clearBtn = CreateFrame("Button", nil, searchContainer, "UIPanelButtonTemplate")
    clearBtn:SetHeight(20)
    clearBtn:SetWidth(60)
    clearBtn:SetPoint("LEFT", resultCount, "RIGHT", 10, 0)
    clearBtn:SetText("Clear")
    clearBtn:SetScript("OnClick", function()
        searchBox:SetText("")
        searchBox:ClearFocus()
        if onSearchChanged then onSearchChanged("") end
    end)

    -- Unlock Frames checkbox (positioned 5px to the right of Clear button)
    local unlockFramesBtn = CreateFrame("CheckButton", nil, searchContainer, "UICheckButtonTemplate")
    unlockFramesBtn:SetHeight(20)
    unlockFramesBtn:SetWidth(20)
    unlockFramesBtn:SetPoint("LEFT", clearBtn, "RIGHT", 5, 0)
    unlockFramesBtn:SetChecked(UUF.db.profile.General.FrameMover.Enabled or false)
    unlockFramesBtn:SetScript("OnClick", function(self)
        if InCombatLockdown() then
            UUF:PrettyPrint("Cannot toggle frame movers in combat.")
            self:SetChecked(UUF.db.profile.General.FrameMover.Enabled)
            return
        end
        UUF.db.profile.General.FrameMover.Enabled = self:GetChecked()
        UUF:ApplyFrameMovers()
    end)
    
    -- Label for unlock frames checkbox
    local unlockLabel = searchContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    unlockLabel:SetPoint("LEFT", unlockFramesBtn, "RIGHT", 2, 0)
    unlockLabel:SetText("Unlock")
    
    unlockFramesBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("Unlock frames to drag them with the left mouse button", 1, 1, 1)
        GameTooltip:AddLine("Re-lock when finished", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    unlockFramesBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Search history tooltip
    searchBox:SetScript("OnEnterPressed", function()
        searchBox:ClearFocus()
    end)

    searchBox:SetScript("OnTextChanged", function(self)
        local text = self:GetText()
        if onSearchChanged then
            local count = onSearchChanged(text)
            resultCount:SetText((count or 0) .. " matches")
        end
    end)
    
    searchBox:SetScript("OnEditFocusLost", function(self)
        local text = self:GetText()
        -- Add to history only when leaving search box with non-empty text
        if text ~= "" then
            UUF:AddSearchToHistory(text)
        end
    end)

    searchContainer.searchBox = searchBox
    searchContainer.resultCount = resultCount
    searchContainer.clearBtn = clearBtn
    searchContainer.unlockFramesBtn = unlockFramesBtn
    searchContainer.unlockLabel = unlockLabel

    return searchContainer
end

UUF.GUISearch = GUISearch
return GUISearch
