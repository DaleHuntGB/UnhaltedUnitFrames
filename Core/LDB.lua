local _, UUF = ...

-- LibDataBroker support for minimap icon
local ldb = LibStub:GetLibrary("LibDataBroker-1.1", true)
if not ldb then return end

local menuFrame
local fallbackMenuFrame
local fallbackMenuButtons = {}
local fallbackMenuTitle
local fallbackNoticeLogged = false

local function ShowDropdownMenu(menu)
    local easyMenu = EasyMenu or _G.EasyMenu

    if type(easyMenu) == "function" then
        easyMenu(menu, menuFrame, "cursor", 0, 0, "MENU")
        return true
    end

    if not fallbackNoticeLogged and UUF.DebugOutput then
        fallbackNoticeLogged = true
        UUF.DebugOutput:Output(
            "LDB",
            "EasyMenu unavailable; using internal minimap context menu fallback.",
            UUF.DebugOutput.TIER_INFO
        )
    end

    -- Fallback: in-client custom context menu when EasyMenu is unavailable.
    if not fallbackMenuFrame then
        fallbackMenuFrame = CreateFrame("Frame", "UUF_MinimapContextMenuFallback", UIParent, "BackdropTemplate")
        fallbackMenuFrame:SetFrameStrata("DIALOG")
        fallbackMenuFrame:SetClampedToScreen(true)
        fallbackMenuFrame:EnableMouse(true)
        fallbackMenuFrame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 },
        })
        fallbackMenuFrame:SetBackdropColor(0, 0, 0, 0.95)

        fallbackMenuTitle = fallbackMenuFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        fallbackMenuTitle:SetPoint("TOPLEFT", fallbackMenuFrame, "TOPLEFT", 10, -8)
        fallbackMenuTitle:SetJustifyH("LEFT")
    end

    for i = 1, #fallbackMenuButtons do
        fallbackMenuButtons[i]:Hide()
    end

    local row = 0
    local width = 190
    local function AcquireButton(index)
        if fallbackMenuButtons[index] then
            return fallbackMenuButtons[index]
        end
        local btn = CreateFrame("Button", nil, fallbackMenuFrame, "UIPanelButtonTemplate")
        btn:SetSize(width - 20, 20)
        fallbackMenuButtons[index] = btn
        return btn
    end

    local titleText = "UnhaltedUnitFrames"
    if type(menu) == "table" and type(menu[1]) == "table" and menu[1].isTitle then
        titleText = menu[1].text or titleText
    end
    fallbackMenuTitle:SetText(titleText)

    for i = 1, #menu do
        local item = menu[i]
        if item and not item.isTitle then
            row = row + 1
            local btn = AcquireButton(row)
            btn:ClearAllPoints()
            btn:SetPoint("TOPLEFT", fallbackMenuFrame, "TOPLEFT", 10, -10 - (row * 22))
            btn:SetText(item.text or "")
            btn:SetScript("OnClick", function()
                fallbackMenuFrame:Hide()
                if type(item.func) == "function" then
                    item.func()
                end
            end)
            btn:Show()
        end
    end

    local height = 16 + (row * 22) + 12
    fallbackMenuFrame:SetSize(width, height)

    local cursorX, cursorY = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    fallbackMenuFrame:ClearAllPoints()
    fallbackMenuFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", (cursorX / scale) + 8, (cursorY / scale) - 8)
    fallbackMenuFrame:Show()
    return true
end

local function ToggleConfig()
    if UUF.ConfigWindow and UUF.ConfigWindow:IsVisible() then
        UUF.ConfigWindow:Hide()
    else
        UUF:CreateGUI()
    end
end

local function TogglePerformanceDashboard()
    if UUF.PerformanceDashboard then
        UUF.PerformanceDashboard:Toggle()
    end
end

local function ToggleDebugConsole()
    if UUF.DebugPanel then
        UUF.DebugPanel:Toggle()
    elseif SlashCmdList and SlashCmdList["UUFDEBUG"] then
        SlashCmdList["UUFDEBUG"]("")
    end
end

local function ToggleFrameLock()
    if UUF.ToggleFrameMover then
        UUF:ToggleFrameMover()
    end
end

local function ShowMinimapContextMenu(anchorFrame)
    if not menuFrame then
        menuFrame = CreateFrame("Frame", "UUF_MinimapContextMenu", UIParent, "UIDropDownMenuTemplate")
    end

    local frameMoverLabel = (UUF.GetFrameMoverLabel and UUF:GetFrameMoverLabel()) or "Unlock Frames"
    local menu = {
        { text = UUF.PRETTY_ADDON_NAME or "UnhaltedUnitFrames", isTitle = true, notCheckable = true },
        { text = "Open Config", notCheckable = true, func = ToggleConfig },
        { text = "Toggle UUFPerf", notCheckable = true, func = TogglePerformanceDashboard },
        { text = "Toggle UUFDebug", notCheckable = true, func = ToggleDebugConsole },
        { text = frameMoverLabel, notCheckable = true, func = ToggleFrameLock },
    }

    ShowDropdownMenu(menu)
end

local dataObject = ldb:NewDataObject(
    "UnhaltedUnitFrames",
    {
        type = "data source",
        text = "UUF",
        icon = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Logo.tga",
        OnClick = function(frame, button)
            if button == "LeftButton" then
                ToggleConfig()
            elseif button == "RightButton" then
                ShowMinimapContextMenu(frame)
            end
        end,
        OnTooltipShow = function(tooltip)
            if not tooltip then return end
            tooltip:AddLine(UUF.PRETTY_ADDON_NAME)
            tooltip:AddLine("Version " .. UUF.ADDON_VERSION, 0.7, 0.7, 0.7)
            tooltip:AddLine(" ")
            
            -- Count active frames
            local frameCount = 0
            if UUF.PLAYER then frameCount = frameCount + 1 end
            if UUF.TARGET then frameCount = frameCount + 1 end
            if UUF.TARGETTARGET then frameCount = frameCount + 1 end
            if UUF.FOCUS then frameCount = frameCount + 1 end
            if UUF.FOCUSTARGET then frameCount = frameCount + 1 end
            if UUF.PET then frameCount = frameCount + 1 end
            
            for i = 1, UUF.MAX_PARTY_MEMBERS do
                if UUF["PARTY" .. i] then frameCount = frameCount + 1 end
            end
            
            for i = 1, UUF.MAX_BOSS_FRAMES do
                if UUF["BOSS" .. i] then frameCount = frameCount + 1 end
            end
            
            tooltip:AddLine("Frames: " .. frameCount, 1, 1, 1)
            tooltip:AddLine("Left Click: Toggle Config", 0.7, 0.7, 0.7)
            tooltip:AddLine("Right Click: Context Menu", 0.7, 0.7, 0.7)
        end,
    }
)

-- Register with broker plugins if available
local LDB_Icon = LibStub:GetLibrary("DBIcon-1.0", true)
if LDB_Icon then
    LDB_Icon:Register("UnhaltedUnitFrames", dataObject, UUF.db.profile.General.LDB or {})
end
