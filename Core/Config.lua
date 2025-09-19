local _, UUF = ...
local AG = LibStub("AceGUI-3.0")
local GUIContainer;
local OpenedGUI = false
local LSM = LibStub:GetLibrary("LibSharedMedia-3.0") or LibStub("LibSharedMedia-3.0")
local EMOTE_PATH = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Emotes\\"
local CapitalizedUnits = UUF.CapitalizedUnits
local UnitFrames = UUF.UnitFrames

local function GetNormalizedUnit(unit)
    local normalizedUnit = unit:match("^boss%d+$") and "boss" or unit:match("^party%d+$") and "party" or unit:match("^raid%d+$") and "raid" or unit
    return normalizedUnit
end

local AnchorPoints = {
    ["TOPLEFT"] = "Top Left",
    ["TOP"] = "Top",
    ["TOPRIGHT"] = "Top Right",
    ["LEFT"] = "Left",
    ["CENTER"] = "Center",
    ["RIGHT"] = "Right",
    ["BOTTOMLEFT"] = "Bottom Left",
    ["BOTTOM"] = "Bottom",
    ["BOTTOMRIGHT"] = "Bottom Right"
}

local AnchorOrder = { "TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "CENTER", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT", }

local unitToUnitFrame = {
    ["player"]      = "UUF_Player",
    ["target"]      = "UUF_Target",
    ["targettarget"]= "UUF_TargetTarget",
    ["focus"]       = "UUF_Focus",
    ["focustarget"] = "UUF_FocusTarget",
    ["pet"]         = "UUF_Pet",
}

for i = 1, 8 do
    unitToUnitFrame["boss"..i] = "UUF_Boss"..i
end

local PowerNames = {
    [0] = "Mana",
    [1] = "Rage",
    [2] = "Focus",
    [3] = "Energy",
    [4] = "Combo Points",
    [5] = "Runes",
    [6] = "Runic Power",
    [7] = "Soul Shards",
    [8] = "Lunar Power",
    [9] = "Holy Power",
    [11] = "Maelstrom",
    [13] = "Insanity",
    [17] = "Fury",
    [18] = "Pain"
}

local ReactionNames = {
    [1] = "Hated",
    [2] = "Hostile",
    [3] = "Unfriendly",
    [4] = "Neutral",
    [5] = "Friendly",
    [6] = "Honored",
    [7] = "Revered",
    [8] = "Exalted",
}

local CombatTextures = {
    ["DEFAULT"] = "|TInterface\\CharacterFrame\\UI-StateIcon:20:20:0:0:64:64:32:64:0:31|t",
    ["COMBAT0"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat0.tga:18:18|t",
    ["COMBAT1"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat1.tga:18:18|t",
    ["COMBAT2"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat2.tga:18:18|t",
    ["COMBAT3"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat3.tga:18:18|t",
    ["COMBAT4"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat4.tga:18:18|t",
    ["COMBAT5"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat5.tga:18:18|t",
    ["COMBAT6"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat6.tga:18:18|t",
    ["COMBAT7"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat7.tga:18:18|t",
}

local RestingTextures = {
    ["DEFAULT"] = "|TInterface\\CharacterFrame\\UI-StateIcon:18:18:0:0:64:64:0:32:0:27|t",
    ["RESTING0"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting0.tga:18:18|t",
    ["RESTING1"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting1.tga:18:18|t",
    ["RESTING2"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting2.tga:18:18|t",
    ["RESTING3"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting3.tga:18:18|t",
    ["RESTING4"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting4.tga:18:18|t",
    ["RESTING5"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting5.tga:18:18|t",
    ["RESTING6"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting6.tga:18:18|t",
    ["RESTING7"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting7.tga:18:18|t",
}

local RoleTextures = {
    ["DEFAULT"] = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:18:18:0:0:64:64:0:19:22:41|t|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:18:18:0:0:64:64:18:39:1:18|t|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:18:18:0:0:64:64:18:39:22:41|t |cFF08B6FFBlizzard|r",
    ["ELVUIV1"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\RoleIcons\\ElvUIV1\\Tank.tga:18:18|t|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\RoleIcons\\ElvUIV1\\Healer.tga:18:18|t|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\RoleIcons\\ElvUIV1\\DPS.tga:18:18|t |cff1784d1ElvUI|r - V1",
    ["ELVUIV2"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\RoleIcons\\ElvUIV2\\Tank.tga:18:18|t|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\RoleIcons\\ElvUIV2\\Healer.tga:18:18|t|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\RoleIcons\\ElvUIV2\\DPS.tga:18:18|t |cff1784d1ElvUI|r - V2",
    ["UUFLIGHT"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\RoleIcons\\White\\Tank.tga:18:18|t|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\RoleIcons\\White\\Healer.tga:18:18|t|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\RoleIcons\\White\\DPS.tga:18:18|t |cFF8080FFUnhalted|r Unit Frames - Light",
    ["UUFDARK"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\RoleIcons\\Dark\\Tank.tga:18:18|t|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\RoleIcons\\Dark\\Healer.tga:18:18|t|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\RoleIcons\\Dark\\DPS.tga:18:18|t |cFF8080FFUnhalted|r Unit Frames - Dark",
    ["UUFCOLOUR"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\RoleIcons\\Colour\\Tank.tga:18:18|t|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\RoleIcons\\Colour\\Healer.tga:18:18|t|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\RoleIcons\\Colour\\DPS.tga:18:18|t |cFF8080FFUnhalted|r Unit Frames - Colour",
}

local ReadyCheckTextures = {
    ["DEFAULT"] = "|TInterface\\RaidFrame\\ReadyCheck-Ready:14:14|t|TInterface\\RaidFrame\\ReadyCheck-NotReady:14:14|t|TInterface\\RaidFrame\\ReadyCheck-Waiting:14:14|t |cFF08B6FFBlizzard|r",
    ["UUFLIGHT"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ReadyCheck\\White\\Ready.tga:14:14|t|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ReadyCheck\\White\\NotReady.tga:14:14|t|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ReadyCheck\\White\\Pending.tga:14:14|t |cFF8080FFUnhalted|r Unit Frames - Light",
    ["UUFDARK"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ReadyCheck\\Dark\\Ready.tga:14:14|t|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ReadyCheck\\Dark\\NotReady.tga:14:14|t|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ReadyCheck\\Dark\\Pending.tga:14:14|t |cFF8080FFUnhalted|r Unit Frames - Dark",
    ["UUFCOLOUR"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ReadyCheck\\Colour\\Ready.tga:14:14|t|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ReadyCheck\\Colour\\NotReady.tga:14:14|t|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ReadyCheck\\Colour\\Pending.tga:14:14|t |cFF8080FFUnhalted|r Unit Frames - Colour",
}

local SLIDER_STEP, SLIDER_MIN, SLIDER_MAX = 0.1, -1000, 1000

local function GenerateFontList()
    local LSMFonts = LSM:HashTable("font")
    local FontList = {}
    for name in pairs(LSMFonts) do
        FontList[name] = name
    end
    return FontList
end

local function GenerateTextureList()
    local LSMTextures = LSM:HashTable("statusbar")
    local TextureList = {}
    for name in pairs(LSMTextures) do
        TextureList[name] = name
    end
    return TextureList
end

local function DeepDisable(widget, disabled)
    if widget.SetDisabled then
        widget:SetDisabled(disabled)
    end
    if widget.children then
        for _, child in ipairs(widget.children) do
            DeepDisable(child, disabled)
        end
    end
end

local function CreateSlider(sliderTitle, sliderValue, unit, table, subTable, subSubTable, svValue)
    local Slider = AG:Create("Slider")
    Slider:SetLabel(sliderTitle)
    Slider:SetValue(sliderValue)
    Slider:SetRelativeWidth(0.5)
    Slider:SetSliderValues(SLIDER_MIN, SLIDER_MAX, SLIDER_STEP)
    if svValue == "Spacing" then
        Slider:SetSliderValues(-10, 10, 0.1)
    elseif svValue == "Size" then
        Slider:SetSliderValues(10, 64, 0.1)
    elseif svValue == "Height" or svValue == "Width" then
        Slider:SetSliderValues(1, 512, 0.1)
    elseif svValue == "Num" or svValue == "Wrap" then
        Slider:SetSliderValues(1, 24, 1)
    elseif svValue == "FontSize" then
        Slider:SetSliderValues(6, 32, 1)
    else
        Slider:SetSliderValues(SLIDER_MIN, SLIDER_MAX, SLIDER_STEP)
    end
    if subSubTable then
        Slider:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile[unit][table][subTable][subSubTable][svValue] = value UUF:UpdateFrame(unitToUnitFrame[unit], unit) end)
    elseif subTable then
        Slider:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile[unit][table][subTable][svValue] = value UUF:UpdateFrame(unitToUnitFrame[unit], unit) end)
    else
        Slider:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile[unit][table][svValue] = value UUF:UpdateFrame(unitToUnitFrame[unit], unit) end)
    end
    return Slider
end

local function CreateToggle(toggleTitle, toggleValue, unit, table, subTable, svValue)
    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel(toggleTitle)
    Toggle:SetValue(toggleValue)
    Toggle:SetRelativeWidth(0.5)

    local function SaveAndUpdate(value)
        if subTable then
            UUF.db.profile[unit][table][subTable][svValue] = value
        elseif table then
            UUF.db.profile[unit][table][svValue] = value
        else
            UUF.db.profile[unit][svValue] = value
        end
        UUF:UpdateFrame(unitToUnitFrame[unit], unit)

        if svValue == "Enabled" then
            local parent = Toggle.parent
            if parent and parent.children then
                for i, child in ipairs(parent.children) do
                    if child ~= Toggle then
                        DeepDisable(child, not value)
                    end
                end
            end
        end
    end

    Toggle:SetCallback("OnValueChanged", function(_, _, value) SaveAndUpdate(value) end)

    return Toggle
end

local function CreateColourPicker(colourTitle, colourValue, unit, table, subTable, subSubTable, svValue)
    local ColourPicker = AG:Create("ColorPicker")
    ColourPicker:SetLabel(colourTitle)
    ColourPicker:SetColor(unpack(colourValue))
    if table == "Tags" then
        ColourPicker:SetRelativeWidth(0.25)
    else
        ColourPicker:SetRelativeWidth(0.5)
    end
    ColourPicker:SetHasAlpha(true)
    ColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a)
        if subSubTable then
            UUF.db.profile[unit][table][subTable][subSubTable][svValue] = {r, g, b, a}
        elseif subTable then
            UUF.db.profile[unit][table][subTable][svValue] = {r, g, b, a}
        else
            UUF.db.profile[unit][table][svValue] = {r, g, b, a}
        end
        UUF:UpdateFrame(unitToUnitFrame[unit], unit)
    end)

    return ColourPicker
end

local function CreateDropdown(dropdownTitle, dropdownValue, unit, table, subTable, subSubTable, svValue)
    local Dropdown = AG:Create("Dropdown")
    Dropdown:SetLabel(dropdownTitle)
    if svValue == "WrapDirection" then
        Dropdown:SetList( { ["UP"] = "Up", ["DOWN"] = "Down", }, { "UP", "DOWN" } )
    elseif svValue == "Growth" then
        Dropdown:SetList({ ["RIGHT"] = "Right", ["LEFT"] = "Left", }, { "LEFT", "RIGHT" })
    elseif svValue == "GrowthDirection" then
        Dropdown:SetList({ ["DOWN"] = "Down", ["UP"] = "Up", }, { "DOWN", "UP" })
    elseif svValue == "Type" then
        Dropdown:SetList( { ["BORDER"] = "Border", ["BACKGROUND"] = "Background", }, { "BORDER", "BACKGROUND" } )
    elseif svValue == "Style" then
        Dropdown:SetList( { ["MODEL"] = "Model", ["CLASS"] = "Class" }, { "MODEL", "CLASS" } )
    elseif svValue == "RestingTexture" then
        Dropdown:SetList(RestingTextures)
    elseif svValue == "CombatTexture" then
        Dropdown:SetList(CombatTextures)
    elseif svValue == "RoleTextures" then
        Dropdown:SetList(RoleTextures)
    elseif svValue == "ReadyCheckTextures" then
        Dropdown:SetList(ReadyCheckTextures)
    elseif svValue == "RowGrowth" then
        Dropdown:SetList( { ["UP"] = "Up", ["DOWN"] = "Down", ["RIGHT"] = "Right", ["LEFT"] = "Left", }, { "UP", "DOWN", "RIGHT", "LEFT" } )
    elseif svValue == "ColumnGrowth" then
        Dropdown:SetList( { ["UP"] = "Up", ["DOWN"] = "Down", ["RIGHT"] = "Right", ["LEFT"] = "Left", }, { "UP", "DOWN", "RIGHT", "LEFT" } )
    elseif svValue == "Layout" then
        Dropdown:SetList( { ["VERTICAL"] = "Vertical", ["HORIZONTAL"] = "Horizontal", }, { "VERTICAL", "HORIZONTAL" } )
    else
        Dropdown:SetList(AnchorPoints, AnchorOrder)
    end
    Dropdown:SetValue(dropdownValue)
    Dropdown:SetRelativeWidth(0.5)
    if subSubTable then
        Dropdown:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile[unit][table][subTable][subSubTable][svValue] = value UUF:UpdateFrame(unitToUnitFrame[unit], unit) end)
    elseif subTable then
        Dropdown:SetCallback("OnValueChanged", function(_, _, value)
            UUF.db.profile[unit][table][subTable][svValue] = value
            UUF:UpdateFrame(unitToUnitFrame[unit], unit)
            if subTable == "Status" and (svValue == "CombatTexture") then
                if _G[unitToUnitFrame[unit]].RestingIndicator and _G[unitToUnitFrame[unit]].RestingIndicator:IsShown() then
                    _G[unitToUnitFrame[unit]].RestingIndicator:Hide()
                    C_Timer.After(1, function() _G[unitToUnitFrame[unit]].RestingIndicator:Show() end)
                end
                _G[unitToUnitFrame[unit]].CombatIndicator:Show()
                C_Timer.After(1, function() _G[unitToUnitFrame[unit]].CombatIndicator:Hide() end)
            elseif subTable == "Status" and (svValue == "RestingTexture") then
                if _G[unitToUnitFrame[unit]].CombatIndicator and _G[unitToUnitFrame[unit]].CombatIndicator:IsShown() then
                    _G[unitToUnitFrame[unit]].CombatIndicator:Hide()
                    C_Timer.After(1, function() _G[unitToUnitFrame[unit]].CombatIndicator:Show() end)
                end
                if not IsResting() then
                    _G[unitToUnitFrame[unit]].RestingIndicator:Show()
                    C_Timer.After(1, function() _G[unitToUnitFrame[unit]].RestingIndicator:Hide() end)
                end
            end
        end)
    else
        Dropdown:SetCallback("OnValueChanged", function(_, _, value)
            if svValue ~= "Layout" then
                UUF.db.profile[unit][table][svValue] = value
                UUF:UpdateFrame(unitToUnitFrame[unit], unit)
            else
                if svValue == "Layout" then
                    UUF:CreatePrompt("Reload To Apply Changes", "Change from |cFF8080FF" .. UUF.db.profile[unit][table][svValue] .. "|r to |cFF8080FF" .. value .. "|r\nDo you want to reload to apply changes?", function() UUF.db.profile[unit][table][svValue] = value ReloadUI() end, function() end, "Yes", "No")
                end
            end
        end)
    end
    return Dropdown
end

local function CreateTag(tagTitle, tagValue, unit, table, subTable, svValue)
    local Tag = AG:Create("EditBox")
    Tag:SetLabel(tagTitle)
    Tag:SetText(tagValue)
    Tag:SetRelativeWidth(0.75)
    Tag:SetCallback("OnEnterPressed",
    function(_, _, value)
        UUF.db.profile[unit][table][subTable][svValue] = value
        UUF:UpdateFrame(unitToUnitFrame[unit], unit)
        Tag:ClearFocus()
    end)
    return Tag
end

local function CreateAnchor(anchorTitle, anchorValue, unit, table, subTable, svValue)
    local AnchorEditBox = AG:Create("EditBox")
    AnchorEditBox:SetLabel(anchorTitle)
    AnchorEditBox:SetText(anchorValue)
    AnchorEditBox:SetRelativeWidth(1)
    if subTable then
        AnchorEditBox:SetCallback("OnEnterPressed", function(_, _, value) UUF.db.profile[unit][table][subTable][svValue] = value AnchorEditBox:ClearFocus() UUF:UpdateFrame(unitToUnitFrame[unit], unit) end)
    else
        AnchorEditBox:SetCallback("OnEnterPressed", function(_, _, value) UUF.db.profile[unit][table][svValue] = value AnchorEditBox:ClearFocus() UUF:UpdateFrame(unitToUnitFrame[unit], unit) end)
    end
    return AnchorEditBox
end

local function CreateInfoTag(Description)
    local InfoDesc = AG:Create("Label")
    InfoDesc:SetText(UUF.InfoButton .. Description)
    InfoDesc:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    InfoDesc:SetFullWidth(true)
    InfoDesc:SetJustifyH("CENTER")
    InfoDesc:SetHeight(24)
    InfoDesc:SetJustifyV("MIDDLE")
    return InfoDesc
end

local function RandomizeStatusText()
    local SupportOptions = {
        "Support Me on |cFF8080FFKo-Fi|r!",
        "Support Me on |cFF8080FFPatreon|r!",
        "|cFF8080FFPayPal Donations|r are appreciated!",
        "Join the |cFF8080FFDiscord|r!",
        "Report Issues / Feedback on |cFF8080FFGitHub|r!",
        "Follow Me on |cFF8080FFTwitch|r!",
        "|cFF8080FFSupport|r is truly appreciated. |cFF8080FFDevelopment|r takes time & effort."
    }
    return SupportOptions[math.random(1, #SupportOptions)]
end

local function GetAuraInfo(auraID, nameOnly)
    local auraData = C_Spell.GetSpellInfo(auraID)
    if nameOnly == nil then nameOnly = true end
    if auraData then
        local auraName = auraData.name
        local auraIcon = auraData.iconID
        if nameOnly then
            return string.format("%s", auraName)
        else
            return string.format("|T%s:12:12|t %s", auraIcon, auraName)
        end
    end
end

local function TableToList(data)
    local dataContent = {}
    for auraID in pairs(data) do
        local auraName = GetAuraInfo(auraID, false)
        if auraName then
            table.insert(dataContent, string.format("%s (%s)", auraName, auraID))
        else
            table.insert(dataContent, string.format("%s", auraID))
            print("Added" .. auraID .. " without a corresponding name, please ensure the auraID is correct!")
        end
    end
    return table.concat(dataContent, "\n")
end

function UUF:CreateGUI()
    if OpenedGUI then return end
    if InCombatLockdown() then return end
    OpenedGUI = true

    GUIContainer = AG:Create("Frame")
    GUIContainer:SetTitle(UUF.AddOnName)
    GUIContainer:SetStatusText(RandomizeStatusText())
    GUIContainer:SetLayout("Fill")
    GUIContainer:SetWidth(800)
    GUIContainer:SetHeight(600)
    GUIContainer:EnableResize(false)
    GUIContainer:SetCallback("OnClose", function(widget) AG:Release(widget) OpenedGUI = false end)

    function SelectedGroup(GUIContainer, _, mainGroup)
        GUIContainer:ReleaseChildren()
        local function DrawGeneralContainer(GUIContainer)
            local General = UUF.db.profile.General
            local ScrollFrame = AG:Create("ScrollFrame")
            ScrollFrame:SetLayout("Flow")
            ScrollFrame:SetFullWidth(true)
            ScrollFrame:SetFullHeight(true)
            GUIContainer:AddChild(ScrollFrame)

            local TagsContainer = AG:Create("InlineGroup")
            TagsContainer:SetTitle("Tag Formatting")
            TagsContainer:SetLayout("Flow")
            TagsContainer:SetFullWidth(true)
            ScrollFrame:AddChild(TagsContainer)

            local DecimalPointsSlider = AG:Create("Slider")
            DecimalPointsSlider:SetLabel("Decimal Points")
            DecimalPointsSlider:SetValue(UUF.DP)
            DecimalPointsSlider:SetSliderValues(0, 3, 1)
            DecimalPointsSlider:SetRelativeWidth(0.25)
            DecimalPointsSlider:SetCallback("OnValueChanged", function(_, _, value)
                UUF.db.profile.General.DecimalPlaces = value
                UUF.DP = value
                for unitFrameName, unit in pairs(UnitFrames) do
                    UUF:UpdateFrame(unitFrameName, unit)
                end
            end)
            TagsContainer:AddChild(DecimalPointsSlider)

            local TagUpdateIntervalSlider = AG:Create("Slider")
            TagUpdateIntervalSlider:SetLabel("Tag Update Interval")
            TagUpdateIntervalSlider:SetValue(UUF.TagInterval)
            TagUpdateIntervalSlider:SetSliderValues(0, 1, 0.25)
            TagUpdateIntervalSlider:SetRelativeWidth(0.25)
            TagUpdateIntervalSlider:SetCallback("OnValueChanged", function(_, _, value)
                UUF.db.profile.General.TagUpdateInterval = value
                UUF.TagInterval = value
                for unitFrameName, unit in pairs(UnitFrames) do
                    UUF:UpdateFrame(unitFrameName, unit)
                end
            end)
            TagsContainer:AddChild(TagUpdateIntervalSlider)

            local TargetTargetSeparatorDropdown = AG:Create("Dropdown")
            TargetTargetSeparatorDropdown:SetLabel("Target of Target Separator")
            TargetTargetSeparatorDropdown:SetList( { ["»"] = "»", [">"] = ">", ["-"] = "-", ["||"] = "|", [""] = "Space" }, { "»", ">", "-", "||", "" } )
            TargetTargetSeparatorDropdown:SetValue(General.TargetTargetSeparator or "»")
            TargetTargetSeparatorDropdown:SetRelativeWidth(0.25)
            TargetTargetSeparatorDropdown:SetCallback("OnValueChanged", function(_, _, value)
                UUF.db.profile.General.TargetTargetSeparator = value
                UUF.TargetTargetSeparator = value
                for unitFrameName, unit in pairs(UnitFrames) do
                    UUF:UpdateFrame(unitFrameName, unit)
                end
            end)
            TargetTargetSeparatorDropdown:SetCallback("OnEnter", function()
                GameTooltip:SetOwner(TargetTargetSeparatorDropdown.frame, "ANCHOR_TOP")
                GameTooltip:AddLine("Separator shown before |cFF8080FFTarget Target's Name|r, space is automatically applied.", 1, 1, 1)
                GameTooltip:Show()
            end)
            TargetTargetSeparatorDropdown:SetCallback("OnLeave", function() GameTooltip:Hide() end)
            TagsContainer:AddChild(TargetTargetSeparatorDropdown)

            local HealthSeperatorDropdown = AG:Create("Dropdown")
            HealthSeperatorDropdown:SetLabel("Health Separator")
            HealthSeperatorDropdown:SetList( { ["-"] = "-", ["||"] = "|", ["/"] = "/", [""] = "Space" }, { "-", "||", "/", "" } )
            HealthSeperatorDropdown:SetValue(General.HealthSeparator or ",")
            HealthSeperatorDropdown:SetRelativeWidth(0.25)
            HealthSeperatorDropdown:SetCallback("OnValueChanged", function(_, _, value)
                UUF.db.profile.General.HealthSeparator = value
                UUF.HealthSeparator = value
                for unitFrameName, unit in pairs(UnitFrames) do
                    UUF:UpdateFrame(unitFrameName, unit)
                end
            end)
            HealthSeperatorDropdown:SetCallback("OnEnter", function()
                GameTooltip:SetOwner(HealthSeperatorDropdown.frame, "ANCHOR_TOP")
                GameTooltip:AddLine("Separator shown between |cFF8080FFHealth|r and |cFF8080FFPercent|r Values.", 1, 1, 1)
                GameTooltip:Show()
            end)
            HealthSeperatorDropdown:SetCallback("OnLeave", function() GameTooltip:Hide() end)
            TagsContainer:AddChild(HealthSeperatorDropdown)

            local CustomColoursContainer = AG:Create("InlineGroup")
            CustomColoursContainer:SetTitle("Custom Colours")
            CustomColoursContainer:SetLayout("Flow")
            CustomColoursContainer:SetFullWidth(true)
            ScrollFrame:AddChild(CustomColoursContainer)

            local ResetColoursButton = AG:Create("Button")
            ResetColoursButton:SetText("Reset All Colours")
            ResetColoursButton:SetRelativeWidth(0.33)
            ResetColoursButton:SetCallback("OnClick", function()
                UUF.db.profile.General.CustomColours = CopyTable(UUF.Defaults.profile.General.CustomColours)
                for unitFrameName, unit in pairs(UnitFrames) do
                    UUF:UpdateFrame(unitFrameName, unit)
                end
            end)
            CustomColoursContainer:AddChild(ResetColoursButton)

            local ResetPowerColoursButton = AG:Create("Button")
            ResetPowerColoursButton:SetText("Reset Power Colours")
            ResetPowerColoursButton:SetRelativeWidth(0.33)
            ResetPowerColoursButton:SetCallback("OnClick", function()
                UUF.db.profile.General.CustomColours.Power = CopyTable(UUF.Defaults.profile.General.CustomColours.Power)
                for unitFrameName, unit in pairs(UnitFrames) do
                    UUF:UpdateFrame(unitFrameName, unit)
                end
            end)
            CustomColoursContainer:AddChild(ResetPowerColoursButton)

            local ResetReactionColoursButton = AG:Create("Button")
            ResetReactionColoursButton:SetText("Reset Reaction Colours")
            ResetReactionColoursButton:SetRelativeWidth(0.33)
            ResetReactionColoursButton:SetCallback("OnClick", function()
                UUF.db.profile.General.CustomColours.Reaction = CopyTable(UUF.Defaults.profile.General.CustomColours.Reaction)
                for unitFrameName, unit in pairs(UnitFrames) do
                    UUF:UpdateFrame(unitFrameName, unit)
                end
            end)
            CustomColoursContainer:AddChild(ResetReactionColoursButton)

            local PowerColours = AG:Create("InlineGroup")
            PowerColours:SetTitle("Power Colours")
            PowerColours:SetLayout("Flow")
            PowerColours:SetFullWidth(true)
            CustomColoursContainer:AddChild(PowerColours)

            local PowerOrder = {0, 1, 2, 3, 6, 8, 11, 13, 17, 18}
            for _, powerType in ipairs(PowerOrder) do
                local powerColour = General.CustomColours.Power[powerType]
                local PowerColour = AG:Create("ColorPicker")
                PowerColour:SetLabel(PowerNames[powerType])
                local R, G, B = unpack(powerColour)
                PowerColour:SetColor(R, G, B)
                PowerColour:SetCallback("OnValueChanged", function(widget, _, r, g, b)
                    General.CustomColours.Power[powerType] = {r, g, b}
                    for unitFrameName, unit in pairs(UnitFrames) do
                        UUF:UpdateFrame(unitFrameName, unit)
                    end
                end)
                PowerColour:SetHasAlpha(false)
                PowerColour:SetRelativeWidth(0.25)
                PowerColours:AddChild(PowerColour)
            end

            local ReactionColours = AG:Create("InlineGroup")
            ReactionColours:SetTitle("Reaction Colours")
            ReactionColours:SetLayout("Flow")
            ReactionColours:SetFullWidth(true)
            CustomColoursContainer:AddChild(ReactionColours)

            for reactionType, reactionColour in pairs(General.CustomColours.Reaction) do
                local ReactionColour = AG:Create("ColorPicker")
                ReactionColour:SetLabel(ReactionNames[reactionType])
                local R, G, B = unpack(reactionColour)
                ReactionColour:SetColor(R, G, B)
                ReactionColour:SetCallback("OnValueChanged", function(widget, _, r, g, b)
                    General.CustomColours.Reaction[reactionType] = {r, g, b}
                    for unitFrameName, unit in pairs(UnitFrames) do
                        UUF:UpdateFrame(unitFrameName, unit)
                    end
                end)
                ReactionColour:SetHasAlpha(false)
                ReactionColour:SetRelativeWidth(0.25)
                ReactionColours:AddChild(ReactionColour)
            end

            local SupportMeContainer = AG:Create("InlineGroup")
            SupportMeContainer:SetTitle("|T" .. EMOTE_PATH .. "peepoLove.png:18:18|t  How To Support " .. UUF.AddOnName .. " Development")
            SupportMeContainer:SetLayout("Flow")
            SupportMeContainer:SetFullWidth(true)
            CustomColoursContainer:AddChild(SupportMeContainer)
        end

        local function DrawGlobalContainer(GUIContainer)
            local ScrollFrame = AG:Create("ScrollFrame")
            ScrollFrame:SetLayout("Flow")
            ScrollFrame:SetFullWidth(true)
            ScrollFrame:SetFullHeight(true)
            GUIContainer:AddChild(ScrollFrame)

            local UIScaleContainer = AG:Create("InlineGroup")
            UIScaleContainer:SetTitle("UI Scale")
            UIScaleContainer:SetLayout("Flow")
            UIScaleContainer:SetFullWidth(true)
            ScrollFrame:AddChild(UIScaleContainer)

            local UIScaleInfo = CreateInfoTag("This can force the UI Scale to be lower than |cFF08B6FFBlizzard|r intends which can cause some |cFFFFCC00unexpected effects|r.\nIf you experience issues, please |cFFFF4040disable|r the feature.")
            UIScaleInfo:SetRelativeWidth(0.8)

            local UIScaleSlider = AG:Create("Slider")
            UIScaleSlider:SetLabel("UI Scale")
            UIScaleSlider:SetValue(UUF.db.profile.General.UIScale or 1)
            UIScaleSlider:SetSliderValues(0.3, 1.5, 0.01)
            UIScaleSlider:SetRelativeWidth(0.33)
            UIScaleSlider:SetCallback("OnMouseUp", function(_, _, value)
                if not UUF.db.profile.General.AllowUIScaling then return end
                if value > 0.8 then
                    UUF:CreatePrompt(
                    "UI Scale Warning",
                    "Setting the UI Scale to |cFF8080FF" .. value .. "|r\nThis may cause UI Elements to appear very large.\nAre you sure you want to continue?",
                    function() UUF.db.profile.General.UIScale = value UIParent:SetScale(value) end,
                    function() UIParent:SetScale(UUF.db.profile.General.UIScale) UIScaleSlider:SetValue(UUF.db.profile.General.UIScale) end,
                    "Set |cFF8080FF" .. value .. "|r UI Scale"
                )
                else
                    UUF.db.profile.General.UIScale = value
                    UIParent:SetScale(value)
                end
            end)
            UIScaleSlider:SetCallback("OnValueChanged", function(_, _, value)
                if value > 0.8 then
                    UIScaleSlider:SetLabel("UI Scale |cFFFF4040(Warning)|r")
                else
                    UIScaleSlider:SetLabel("UI Scale")
                end
            end)

            local TenEightyUIScaleButton = AG:Create("Button")
            TenEightyUIScaleButton:SetText("1080p")
            TenEightyUIScaleButton:SetRelativeWidth(0.33)
            TenEightyUIScaleButton:SetCallback("OnClick", function()
                if not UUF.db.profile.General.AllowUIScaling then return end
                UUF.db.profile.General.UIScale = 0.7111111111111
                UIParent:SetScale(0.7111111111111)
                UIScaleSlider:SetValue(0.7111111111111)
            end)
            TenEightyUIScaleButton:SetCallback("OnEnter", function()
                GameTooltip:SetOwner(TenEightyUIScaleButton.frame, "ANCHOR_TOP")
                GameTooltip:AddLine("UI Scale is set to |cFF8080FF0.7111111111111|r", 1, 1, 1)
                GameTooltip:Show()
            end)
            TenEightyUIScaleButton:SetCallback("OnLeave", function() GameTooltip:Hide() end)

            local FourteenFortyUIScaleButton = AG:Create("Button")
            FourteenFortyUIScaleButton:SetText("1440p")
            FourteenFortyUIScaleButton:SetRelativeWidth(0.33)
            FourteenFortyUIScaleButton:SetCallback("OnClick", function()
                if not UUF.db.profile.General.AllowUIScaling then return end
                UUF.db.profile.General.UIScale = 0.5333333333333
                UIParent:SetScale(0.5333333333333)
                UIScaleSlider:SetValue(0.5333333333333)
            end)
            FourteenFortyUIScaleButton:SetCallback("OnEnter", function()
                GameTooltip:SetOwner(FourteenFortyUIScaleButton.frame, "ANCHOR_TOP")
                GameTooltip:AddLine("UI Scale is set to |cFF8080FF0.5333333333333|r", 1, 1, 1)
                GameTooltip:Show()
            end)
            FourteenFortyUIScaleButton:SetCallback("OnLeave", function() GameTooltip:Hide() end)

            local EnableUIScaleToggle = AG:Create("CheckBox")
            EnableUIScaleToggle:SetLabel("Enable UI Scale")
            EnableUIScaleToggle:SetValue(UUF.db.profile.General.AllowUIScaling)
            EnableUIScaleToggle:SetRelativeWidth(0.2)
            EnableUIScaleToggle:SetCallback("OnValueChanged", function(_, _, value)
                UUF.db.profile.General.AllowUIScaling = value
                if not value then
                    UUF.db.profile.General.UIScale = 1
                    UIParent:SetScale(1)
                    UIScaleSlider:SetValue(1)
                end
                if not UUF.db.profile.General.AllowUIScaling then
                    UIScaleSlider:SetDisabled(true)
                    TenEightyUIScaleButton:SetDisabled(true)
                    FourteenFortyUIScaleButton:SetDisabled(true)
                    UIScaleContainer:DoLayout()
                else
                    UIScaleSlider:SetDisabled(false)
                    TenEightyUIScaleButton:SetDisabled(false)
                    FourteenFortyUIScaleButton:SetDisabled(false)
                    UIScaleContainer:DoLayout()
                end
            end)

            UIScaleContainer:AddChild(EnableUIScaleToggle)
            UIScaleContainer:AddChild(UIScaleInfo)
            UIScaleContainer:AddChild(UIScaleSlider)
            UIScaleContainer:AddChild(TenEightyUIScaleButton)
            UIScaleContainer:AddChild(FourteenFortyUIScaleButton)

            local ColourContainer = AG:Create("InlineGroup")
            ColourContainer:SetTitle("Colours")
            ColourContainer:SetLayout("Flow")
            ColourContainer:SetFullWidth(true)
            ScrollFrame:AddChild(ColourContainer)

            local GlobalApplyClassColourButton = AG:Create("Button")
            GlobalApplyClassColourButton:SetText("Apply Class Colours")
            GlobalApplyClassColourButton:SetRelativeWidth(0.25)
            GlobalApplyClassColourButton:SetCallback("OnClick", function()
                for unitFrameName, unit in pairs(UnitFrames) do
                    UUF.db.profile[unit].Frame.ClassColour = true
                    UUF:UpdateFrame(unitFrameName, unit)
                end
            end)
            ColourContainer:AddChild(GlobalApplyClassColourButton)

            local GlobalRemoveClassColourButton = AG:Create("Button")
            GlobalRemoveClassColourButton:SetText("Remove Class Colours")
            GlobalRemoveClassColourButton:SetRelativeWidth(0.25)
            GlobalRemoveClassColourButton:SetCallback("OnClick", function()
                for unitFrameName, unit in pairs(UnitFrames) do
                    UUF.db.profile[unit].Frame.ClassColour = false
                    UUF:UpdateFrame(unitFrameName, unit)
                end
            end)
            ColourContainer:AddChild(GlobalRemoveClassColourButton)

            local GlobalApplyReactionColourButton = AG:Create("Button")
            GlobalApplyReactionColourButton:SetText("Apply Reaction Colours")
            GlobalApplyReactionColourButton:SetRelativeWidth(0.25)
            GlobalApplyReactionColourButton:SetCallback("OnClick", function()
                for unitFrameName, unit in pairs(UnitFrames) do
                    UUF.db.profile[unit].Frame.ReactionColour = true
                    UUF:UpdateFrame(unitFrameName, unit)
                end
            end)
            ColourContainer:AddChild(GlobalApplyReactionColourButton)

            local GlobalRemoveReactionColourButton = AG:Create("Button")
            GlobalRemoveReactionColourButton:SetText("Remove Reaction Colours")
            GlobalRemoveReactionColourButton:SetRelativeWidth(0.25)
            GlobalRemoveReactionColourButton:SetCallback("OnClick", function()
                for unitFrameName, unit in pairs(UnitFrames) do
                    UUF.db.profile[unit].Frame.ReactionColour = false
                    UUF:UpdateFrame(unitFrameName, unit)
                end
            end)
            ColourContainer:AddChild(GlobalRemoveReactionColourButton)

            local GlobalForegroundColourPicker = AG:Create("ColorPicker")
            GlobalForegroundColourPicker:SetLabel("Foreground Colour")
            GlobalForegroundColourPicker:SetHasAlpha(true)
            GlobalForegroundColourPicker:SetColor(0.03, 0.03, 0.03, 0.8)
            GlobalForegroundColourPicker:SetRelativeWidth(0.25)
            GlobalForegroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a)
                for unitFrameName, unit in pairs(UnitFrames) do
                    UUF.db.profile[unit].Frame.FGColour = {r, g, b, a}
                    UUF:UpdateFrame(unitFrameName, unit)
                end
            end)
            ColourContainer:AddChild(GlobalForegroundColourPicker)

            local GlobalBackgroundColourPicker = AG:Create("ColorPicker")
            GlobalBackgroundColourPicker:SetLabel("Background Colour")
            GlobalBackgroundColourPicker:SetHasAlpha(true)
            GlobalBackgroundColourPicker:SetColor(0.8, 0.8, 0.8, 1)
            GlobalBackgroundColourPicker:SetRelativeWidth(0.25)
            GlobalBackgroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a)
                for unitFrameName, unit in pairs(UnitFrames) do
                    UUF.db.profile[unit].Frame.BGColour = {r, g, b, a}
                    UUF:UpdateFrame(unitFrameName, unit)
                end
            end)
            ColourContainer:AddChild(GlobalBackgroundColourPicker)

            local GlobalForegroundAlphaSlider = AG:Create("Slider")
            GlobalForegroundAlphaSlider:SetLabel("Foreground Alpha")
            GlobalForegroundAlphaSlider:SetValue(80)
            GlobalForegroundAlphaSlider:SetSliderValues(0, 100, 1)
            GlobalForegroundAlphaSlider:SetRelativeWidth(0.25)
            GlobalForegroundAlphaSlider:SetCallback("OnValueChanged", function(_, _, value)
                for unitFrameName, unit in pairs(UnitFrames) do
                    UUF.db.profile[unit].Frame.FGColour[4] = value / 100
                    UUF:UpdateFrame(unitFrameName, unit)
                end
            end)
            ColourContainer:AddChild(GlobalForegroundAlphaSlider)

            local GlobalBackgroundAlphaSlider = AG:Create("Slider")
            GlobalBackgroundAlphaSlider:SetLabel("Background Alpha")
            GlobalBackgroundAlphaSlider:SetValue(100)
            GlobalBackgroundAlphaSlider:SetSliderValues(0, 100, 1)
            GlobalBackgroundAlphaSlider:SetRelativeWidth(0.25)
            GlobalBackgroundAlphaSlider:SetCallback("OnValueChanged", function(_, _, value)
                for unitFrameName, unit in pairs(UnitFrames) do
                    UUF.db.profile[unit].Frame.BGColour[4] = value / 100
                    UUF:UpdateFrame(unitFrameName, unit)
                end
            end)
            ColourContainer:AddChild(GlobalBackgroundAlphaSlider)

            local TexturesContainer = AG:Create("InlineGroup")
            TexturesContainer:SetTitle("Textures")
            TexturesContainer:SetLayout("Flow")
            TexturesContainer:SetFullWidth(true)
            ScrollFrame:AddChild(TexturesContainer)

            local TexturesInfoTag = CreateInfoTag("|cFF8080FFTextures|r are applied globally to all elements & unit frames, where appropriate.")
            TexturesInfoTag:SetRelativeWidth(1)
            TexturesContainer:AddChild(TexturesInfoTag)

            local ForegroundTextureDropdown = AG:Create("Dropdown")
            ForegroundTextureDropdown:SetList(GenerateTextureList())
            ForegroundTextureDropdown:SetLabel("Foreground Texture")
            ForegroundTextureDropdown:SetValue(UUF.db.profile.General.ForegroundTexture)
            ForegroundTextureDropdown:SetRelativeWidth(0.5)
            ForegroundTextureDropdown:SetCallback("OnValueChanged", function(_, _, value)
                UUF.db.profile.General.ForegroundTexture = value
                UUF:ResolveMedia()
                for unitFrameName, unit in pairs(UnitFrames) do
                    UUF:UpdateFrame(unitFrameName, unit)
                end
            end)
            TexturesContainer:AddChild(ForegroundTextureDropdown)

            local BackgroundTextureDropdown = AG:Create("Dropdown")
            BackgroundTextureDropdown:SetList(GenerateTextureList())
            BackgroundTextureDropdown:SetLabel("Background Texture")
            BackgroundTextureDropdown:SetValue(UUF.db.profile.General.BackgroundTexture)
            BackgroundTextureDropdown:SetRelativeWidth(0.5)
            BackgroundTextureDropdown:SetCallback("OnValueChanged", function(_, _, value)
                UUF.db.profile.General.BackgroundTexture = value
                UUF:ResolveMedia()
                for unitFrameName, unit in pairs(UnitFrames) do
                    UUF:UpdateFrame(unitFrameName, unit)
                end
            end)
            TexturesContainer:AddChild(BackgroundTextureDropdown)

            local FontsContainer = AG:Create("InlineGroup")
            FontsContainer:SetTitle("Fonts")
            FontsContainer:SetLayout("Flow")
            FontsContainer:SetFullWidth(true)
            ScrollFrame:AddChild(FontsContainer)

            local FontDropdown = AG:Create("Dropdown")
            FontDropdown:SetList(GenerateFontList())
            FontDropdown:SetLabel("Font")
            FontDropdown:SetValue(UUF.db.profile.General.Font)
            FontDropdown:SetRelativeWidth(0.5)
            FontDropdown:SetCallback("OnValueChanged", function(_, _, value)
                UUF.db.profile.General.Font = value
                UUF:ResolveMedia()
                for unitFrameName, unit in pairs(UnitFrames) do
                    UUF:UpdateFrame(unitFrameName, unit)
                end
            end)
            FontsContainer:AddChild(FontDropdown)

            local FontFlagsDropdown = AG:Create("Dropdown")
            FontFlagsDropdown:SetList({
                ["OUTLINE"] = "Outline",
                ["THICKOUTLINE"] = "Thick Outline",
                ["MONOCHROME"] = "Monochrome",
                ["NONE"] = "None",
            })
            FontFlagsDropdown:SetLabel("Font Flags")
            FontFlagsDropdown:SetValue(UUF.db.profile.General.FontFlag)
            FontFlagsDropdown:SetRelativeWidth(0.5)
            FontFlagsDropdown:SetCallback("OnValueChanged", function(_, _, value)
                UUF.db.profile.General.FontFlag = value
                for unitFrameName, unit in pairs(UnitFrames) do
                    UUF:UpdateFrame(unitFrameName, unit)
                end
            end)
            FontsContainer:AddChild(FontFlagsDropdown)

            local FontShadowsContainer = AG:Create("InlineGroup")
            FontShadowsContainer:SetTitle("Shadow")
            FontShadowsContainer:SetLayout("Flow")
            FontShadowsContainer:SetFullWidth(true)
            FontsContainer:AddChild(FontShadowsContainer)

            local FontShadowXOffsetSlider = AG:Create("Slider")
            FontShadowXOffsetSlider:SetLabel("X Offset")
            FontShadowXOffsetSlider:SetValue(UUF.db.profile.General.FontShadows.OffsetX)
            FontShadowXOffsetSlider:SetSliderValues(-10, 10, 1)
            FontShadowXOffsetSlider:SetCallback("OnValueChanged", function(_, _, value)
                UUF.db.profile.General.FontShadows.OffsetX = value
                for unitFrameName, unit in pairs(UnitFrames) do
                    UUF:UpdateFrame(unitFrameName, unit)
                end
            end)
            FontShadowsContainer:AddChild(FontShadowXOffsetSlider)

            local FontShadowYOffsetSlider = AG:Create("Slider")
            FontShadowYOffsetSlider:SetLabel("Y Offset")
            FontShadowYOffsetSlider:SetValue(UUF.db.profile.General.FontShadows.OffsetY)
            FontShadowYOffsetSlider:SetSliderValues(-10, 10, 1)
            FontShadowYOffsetSlider:SetCallback("OnValueChanged", function(_, _, value)
                UUF.db.profile.General.FontShadows.OffsetY = value
                for unitFrameName, unit in pairs(UnitFrames) do
                    UUF:UpdateFrame(unitFrameName, unit)
                end
            end)
            FontShadowsContainer:AddChild(FontShadowYOffsetSlider)

            local FontShadowColourPicker = AG:Create("ColorPicker")
            FontShadowColourPicker:SetLabel("Shadow Colour")
            FontShadowColourPicker:SetColor(unpack(UUF.db.profile.General.FontShadows.SColour))
            FontShadowColourPicker:SetHasAlpha(true)
            FontShadowColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a)
                UUF.db.profile.General.FontShadows.SColour = {r, g, b, a}
                for unitFrameName, unit in pairs(UnitFrames) do
                    UUF:UpdateFrame(unitFrameName, unit)
                end
            end)
            FontShadowsContainer:AddChild(FontShadowColourPicker)

            -- local ElementsContainer = AG:Create("InlineGroup")
            -- ElementsContainer:SetTitle("Elements")
            -- ElementsContainer:SetLayout("Flow")
            -- ElementsContainer:SetFullWidth(true)
            -- ScrollFrame:AddChild(ElementsContainer)

            -- local PortraitContainer = AG:Create("InlineGroup")
            -- PortraitContainer:SetTitle("Portraits")
            -- PortraitContainer:SetLayout("Flow")
            -- PortraitContainer:SetFullWidth(true)
            -- ElementsContainer:AddChild(PortraitContainer)

            -- local GlobalActivatePortraitsButton = AG:Create("Button")
            -- GlobalActivatePortraitsButton:SetText("Activate Portraits")
            -- GlobalActivatePortraitsButton:SetRelativeWidth(0.25)
            -- GlobalActivatePortraitsButton:SetCallback("OnClick", function()
            --     for unitFrameName, unit in pairs(UnitFrames) do
            --         if UUF.db.profile[unit].Portrait then
            --             UUF.db.profile[unit].Portrait.Enabled = true
            --             UUF:UpdateFrame(unitFrameName, unit)
            --         end
            --     end
            -- end)
            -- PortraitContainer:AddChild(GlobalActivatePortraitsButton)

            -- local GlobalDeactivatePortraitsButton = AG:Create("Button")
            -- GlobalDeactivatePortraitsButton:SetText("Deactivate Portraits")
            -- GlobalDeactivatePortraitsButton:SetRelativeWidth(0.25)
            -- GlobalDeactivatePortraitsButton:SetCallback("OnClick", function()
            --     for unitFrameName, unit in pairs(UnitFrames) do
            --         if UUF.db.profile[unit].Portrait then
            --             UUF.db.profile[unit].Portrait.Enabled = false
            --             UUF:UpdateFrame(unitFrameName, unit)
            --         end
            --     end
            -- end)
            -- PortraitContainer:AddChild(GlobalDeactivatePortraitsButton)

            -- local GlobalPortraitStyleDropdown = AG:Create("Dropdown")
            -- GlobalPortraitStyleDropdown:SetList({
            --     ["MODEL"] = "Model",
            --     ["CLASS"] = "Class"
            -- })
            -- GlobalPortraitStyleDropdown:SetLabel("Portrait Style")
            -- GlobalPortraitStyleDropdown:SetValue("MODEL")
            -- GlobalPortraitStyleDropdown:SetRelativeWidth(0.25)
            -- GlobalPortraitStyleDropdown:SetCallback("OnValueChanged", function(_, _, value)
            --     for unitFrameName, unit in pairs(UnitFrames) do
            --         if UUF.db.profile[unit].Portrait then
            --             UUF.db.profile[unit].Portrait.Style = value
            --             UUF:UpdateFrame(unitFrameName, unit)
            --         end
            --     end
            -- end)
            -- PortraitContainer:AddChild(GlobalPortraitStyleDropdown)

            -- local GlobalPortraitZoomSlider = AG:Create("Slider")
            -- GlobalPortraitZoomSlider:SetLabel("Portrait Zoom")
            -- GlobalPortraitZoomSlider:SetValue(0.3)
            -- GlobalPortraitZoomSlider:SetIsPercent(true)
            -- GlobalPortraitZoomSlider:SetSliderValues(0, 1, 0.01)
            -- GlobalPortraitZoomSlider:SetRelativeWidth(0.25)
            -- GlobalPortraitZoomSlider:SetCallback("OnValueChanged", function(_, _, value)
            --     for unitFrameName, unit in pairs(UnitFrames) do
            --         if UUF.db.profile[unit].Portrait then
            --             UUF.db.profile[unit].Portrait.Zoom = value
            --             UUF:UpdateFrame(unitFrameName, unit)
            --         end
            --     end
            -- end)
            -- PortraitContainer:AddChild(GlobalPortraitZoomSlider)

            -- local RangeContainer = AG:Create("InlineGroup")
            -- RangeContainer:SetTitle("Range Fading")
            -- RangeContainer:SetLayout("Flow")
            -- RangeContainer:SetFullWidth(true)
            -- ElementsContainer:AddChild(RangeContainer)

            -- local GlobalInRangeAlphaSlider = AG:Create("Slider")
            -- GlobalInRangeAlphaSlider:SetLabel("In Range Alpha")
            -- GlobalInRangeAlphaSlider:SetValue(1.0)
            -- GlobalInRangeAlphaSlider:SetIsPercent(true)
            -- GlobalInRangeAlphaSlider:SetSliderValues(0, 1, 0.01)
            -- GlobalInRangeAlphaSlider:SetRelativeWidth(0.5)
            -- GlobalInRangeAlphaSlider:SetCallback("OnValueChanged", function(_, _, value)
            --     for unitFrameName, unit in pairs(UnitFrames) do
            --         if unit ~= "player" then
            --             UUF.db.profile[unit].Range.InRange = value
            --             UUF:UpdateFrame(unitFrameName, unit)
            --         end
            --     end
            -- end)
            -- RangeContainer:AddChild(GlobalInRangeAlphaSlider)

            -- local GlobalOutOfRangeAlphaSlider = AG:Create("Slider")
            -- GlobalOutOfRangeAlphaSlider:SetLabel("Out Of Range Alpha")
            -- GlobalOutOfRangeAlphaSlider:SetValue(0.5)
            -- GlobalOutOfRangeAlphaSlider:SetIsPercent(true)
            -- GlobalOutOfRangeAlphaSlider:SetSliderValues(0, 1, 0.01)
            -- GlobalOutOfRangeAlphaSlider:SetRelativeWidth(0.5)
            -- GlobalOutOfRangeAlphaSlider:SetCallback("OnValueChanged", function(_, _, value)
            --     for unitFrameName, unit in pairs(UnitFrames) do
            --         if unit ~= "player" then
            --             UUF.db.profile[unit].Range.OutOfRange = value
            --             UUF:UpdateFrame(unitFrameName, unit)
            --         end
            --     end
            -- end)
            -- RangeContainer:AddChild(GlobalOutOfRangeAlphaSlider)
            UIScaleContainer:DoLayout()
            ColourContainer:DoLayout()
            TexturesContainer:DoLayout()
            FontsContainer:DoLayout()
            -- ElementsContainer:DoLayout()
            ScrollFrame:DoLayout()
        end

        local function DrawFiltersContainer(GUIContainer)
            local ScrollFrame = AG:Create("ScrollFrame")
            ScrollFrame:SetLayout("Flow")
            ScrollFrame:SetFullWidth(true)
            ScrollFrame:SetFullHeight(true)
            GUIContainer:AddChild(ScrollFrame)

            local UnitsToFilterContainer = AG:Create("InlineGroup")
            UnitsToFilterContainer:SetTitle("Units To Filter")
            UnitsToFilterContainer:SetLayout("Flow")
            UnitsToFilterContainer:SetFullWidth(true)
            ScrollFrame:AddChild(UnitsToFilterContainer)

            local UnitsToFilterInfo = CreateInfoTag("Select the |cFF8080FFUnits|r you want to filter. Both |cFF8080FFWhitelist|r and |cFF8080FFBlacklist|r will be filtered for the selected units.")
            UnitsToFilterInfo:SetRelativeWidth(1)
            UnitsToFilterContainer:AddChild(UnitsToFilterInfo)

            local orderedUnitsToFilter = { "player", "target", "targettarget", "focus", "pet", "boss", "party", "raid" }

            for _, unit in ipairs(orderedUnitsToFilter) do
                for unitFrameName, unitToken in pairs(UnitFrames) do
                    if unitToken == unit then
                        local normalizedUnit = GetNormalizedUnit(unit)
                        local unitProfile = UUF.db.profile[normalizedUnit]
                        if unitProfile and (unitProfile.Buffs or unitProfile.Debuffs) then
                            local UnitFilterToggle = AG:Create("CheckBox")
                            UnitFilterToggle:SetLabel(CapitalizedUnits[normalizedUnit] or unit)
                            UnitFilterToggle:SetValue(UUF.db.profile.Filters.FilterUnits[normalizedUnit] or false)
                            UnitFilterToggle:SetRelativeWidth(0.25)
                            UnitFilterToggle:SetCallback("OnValueChanged", function(_, _, value)
                                UUF.db.profile.Filters.FilterUnits[normalizedUnit] = value
                                UUF:UpdateFrame(unitFrameName, unit)
                            end)
                            UnitsToFilterContainer:AddChild(UnitFilterToggle)
                        end
                    end
                end
            end

            local WhitelistContainer = AG:Create("InlineGroup")
            WhitelistContainer:SetTitle("Whitelist")
            WhitelistContainer:SetLayout("Flow")
            WhitelistContainer:SetFullWidth(true)
            ScrollFrame:AddChild(WhitelistContainer)

            local WhitelistInfo = CreateInfoTag("Add Spell IDs to the |cFF8080FFWhitelist|r to only show those auras on the selected units.")
            WhitelistInfo:SetRelativeWidth(1)
            WhitelistContainer:AddChild(WhitelistInfo)

            local WhitelistBuffsContainer = AG:Create("InlineGroup")
            WhitelistBuffsContainer:SetTitle("Buffs")
            WhitelistBuffsContainer:SetLayout("Flow")
            WhitelistBuffsContainer:SetRelativeWidth(0.5)
            WhitelistContainer:AddChild(WhitelistBuffsContainer)

            local WhitelistBuffsEditBox = AG:Create("MultiLineEditBox")
            WhitelistBuffsEditBox:SetLabel("Whitelist Buffs")
            WhitelistBuffsEditBox:SetText(TableToList(UUF.db.profile.Filters.Whitelist.Buffs))
            WhitelistBuffsEditBox:SetCallback("OnEnterPressed", function(widget, event, value)
                if not value or value == "" then WhitelistBuffsEditBox:SetText(TableToList(UUF.db.profile.Filters.Whitelist.Buffs or {})) return end
                if not UUF.db.profile.Filters.Whitelist then UUF.db.profile.Filters.Whitelist = { Buffs = {}, Debuffs = {} } end
                if not UUF.db.profile.Filters.Whitelist.Buffs then UUF.db.profile.Filters.Whitelist.Buffs = {} end
                local buffWhitelist = UUF.db.profile.Filters.Whitelist.Buffs
                for id in string.gmatch(value, "[^,%s]+") do
                    local spellID = tonumber(id)
                    if spellID then
                        buffWhitelist[spellID] = true
                    end
                end
                WhitelistBuffsEditBox:SetText(TableToList(buffWhitelist))
                for unitFrameName, unit in pairs(UnitFrames) do UUF:UpdateFrame(unitFrameName, unit) end
            end)
            WhitelistBuffsEditBox:SetRelativeWidth(1)
            WhitelistBuffsEditBox:SetNumLines(10)
            WhitelistBuffsContainer:AddChild(WhitelistBuffsEditBox)

            local WhitelistDebuffsContainer = AG:Create("InlineGroup")
            WhitelistDebuffsContainer:SetTitle("Debuffs")
            WhitelistDebuffsContainer:SetLayout("Flow")
            WhitelistDebuffsContainer:SetRelativeWidth(0.5)
            WhitelistContainer:AddChild(WhitelistDebuffsContainer)

            local WhitelistDebuffsEditBox = AG:Create("MultiLineEditBox")
            WhitelistDebuffsEditBox:SetLabel("Whitelist Debuffs")
            WhitelistDebuffsEditBox:SetText(TableToList(UUF.db.profile.Filters.Whitelist.Debuffs))
            WhitelistDebuffsEditBox:SetCallback("OnEnterPressed", function(widget, event, value)
                if not value or value == "" then WhitelistDebuffsEditBox:SetText(TableToList(UUF.db.profile.Filters.Whitelist and UUF.db.profile.Filters.Whitelist.Debuffs or {})) return end
                if not UUF.db.profile.Filters.Whitelist then UUF.db.profile.Filters.Whitelist = { Buffs = {}, Debuffs = {} } end
                if not UUF.db.profile.Filters.Whitelist.Debuffs then UUF.db.profile.Filters.Whitelist.Debuffs = {} end
                local debuffWhitelist = UUF.db.profile.Filters.Whitelist.Debuffs
                for id in string.gmatch(value, "[^,%s]+") do
                    local spellID = tonumber(id)
                    if spellID then
                        debuffWhitelist[spellID] = true
                    end
                end
                WhitelistDebuffsEditBox:SetText(TableToList(debuffWhitelist))
                for unitFrameName, unit in pairs(UnitFrames) do UUF:UpdateFrame(unitFrameName, unit) end
            end)

            WhitelistDebuffsEditBox:SetRelativeWidth(1)
            WhitelistDebuffsEditBox:SetNumLines(10)
            WhitelistDebuffsContainer:AddChild(WhitelistDebuffsEditBox)

            local AddImportantBuffsButton = AG:Create("Button")
            AddImportantBuffsButton:SetText("Add Important Buffs to Whitelist")
            AddImportantBuffsButton:SetFullWidth(true)
            AddImportantBuffsButton:SetCallback("OnClick", function()
                if not UUF.db.profile.Filters.Whitelist then UUF.db.profile.Filters.Whitelist = { Buffs = {}, Debuffs = {} } end
                if not UUF.db.profile.Filters.Whitelist.Buffs then UUF.db.profile.Filters.Whitelist.Buffs = {} end
                local ImportantBuffs = UUF:FetchImportantBuffs()
                for spellID in pairs(ImportantBuffs) do
                    UUF.db.profile.Filters.Whitelist.Buffs[spellID] = true
                end
                WhitelistBuffsEditBox:SetText(TableToList(UUF.db.profile.Filters.Whitelist.Buffs))
                for unitFrameName, unit in pairs(UnitFrames) do UUF:UpdateFrame(unitFrameName, unit) end
            end)
            AddImportantBuffsButton:SetCallback("OnLeave", function() GameTooltip:Hide() end)
            WhitelistContainer:AddChild(AddImportantBuffsButton)

            local ClearWhitelistBuffsButton = AG:Create("Button")
            ClearWhitelistBuffsButton:SetText("Clear Whitelist Buffs")
            ClearWhitelistBuffsButton:SetRelativeWidth(1)
            ClearWhitelistBuffsButton:SetCallback("OnClick", function()
                if not UUF.db.profile.Filters.Whitelist then
                    UUF.db.profile.Filters.Whitelist = { Buffs = {}, Debuffs = {} }
                end
                UUF.db.profile.Filters.Whitelist.Buffs = {}
                WhitelistBuffsEditBox:SetText(TableToList(UUF.db.profile.Filters.Whitelist.Buffs))
                for unitFrameName, unit in pairs(UnitFrames) do UUF:UpdateFrame(unitFrameName, unit) end
            end)
            WhitelistBuffsContainer:AddChild(ClearWhitelistBuffsButton)

            local ClearWhitelistDebuffsButton = AG:Create("Button")
            ClearWhitelistDebuffsButton:SetText("Clear Whitelist Debuffs")
            ClearWhitelistDebuffsButton:SetRelativeWidth(1)
            ClearWhitelistDebuffsButton:SetCallback("OnClick", function()
                if not UUF.db.profile.Filters.Whitelist then
                    UUF.db.profile.Filters.Whitelist = { Buffs = {}, Debuffs = {} }
                end
                UUF.db.profile.Filters.Whitelist.Debuffs = {}
                WhitelistDebuffsEditBox:SetText(TableToList(UUF.db.profile.Filters.Whitelist.Debuffs))
                for unitFrameName, unit in pairs(UnitFrames) do UUF:UpdateFrame(unitFrameName, unit) end
            end)
            WhitelistDebuffsContainer:AddChild(ClearWhitelistDebuffsButton)

            local BlacklistContainer = AG:Create("InlineGroup")
            BlacklistContainer:SetTitle("Blacklist")
            BlacklistContainer:SetLayout("Flow")
            BlacklistContainer:SetFullWidth(true)
            ScrollFrame:AddChild(BlacklistContainer)

            local BlacklistInfo = CreateInfoTag("Add Spell IDs to the |cFF8080FFBlacklist|r to only show those auras on the selected units.")
            BlacklistInfo:SetRelativeWidth(1)
            BlacklistContainer:AddChild(BlacklistInfo)

            local BlacklistBuffsContainer = AG:Create("InlineGroup")
            BlacklistBuffsContainer:SetTitle("Buffs")
            BlacklistBuffsContainer:SetLayout("Flow")
            BlacklistBuffsContainer:SetRelativeWidth(0.5)
            BlacklistContainer:AddChild(BlacklistBuffsContainer)

            local BlacklistBuffsEditBox = AG:Create("MultiLineEditBox")
            BlacklistBuffsEditBox:SetLabel("Blacklist Buffs")
            BlacklistBuffsEditBox:SetText(TableToList(UUF.db.profile.Filters.Blacklist.Buffs))
            BlacklistBuffsEditBox:SetCallback("OnEnterPressed", function(widget, event, value)
                if not value or value == "" then BlacklistBuffsEditBox:SetText(TableToList(UUF.db.profile.Filters.Blacklist and UUF.db.profile.Filters.Blacklist.Buffs or {})) return end
                if not UUF.db.profile.Filters.Blacklist then UUF.db.profile.Filters.Blacklist = { Buffs = {}, Debuffs = {} } end
                if not UUF.db.profile.Filters.Blacklist.Buffs then UUF.db.profile.Filters.Blacklist.Buffs = {} end
                local buffBlacklist = UUF.db.profile.Filters.Blacklist.Buffs
                for id in string.gmatch(value, "[^,%s]+") do
                    local spellID = tonumber(id)
                    if spellID then
                        buffBlacklist[spellID] = true
                    end
                end
                BlacklistBuffsEditBox:SetText(TableToList(buffBlacklist))
                for unitFrameName, unit in pairs(UnitFrames) do UUF:UpdateFrame(unitFrameName, unit) end
            end)
            BlacklistBuffsEditBox:SetRelativeWidth(1)
            BlacklistBuffsEditBox:SetNumLines(10)
            BlacklistBuffsContainer:AddChild(BlacklistBuffsEditBox)

            local BlacklistDebuffsContainer = AG:Create("InlineGroup")
            BlacklistDebuffsContainer:SetTitle("Debuffs")
            BlacklistDebuffsContainer:SetLayout("Flow")
            BlacklistDebuffsContainer:SetRelativeWidth(0.5)
            BlacklistContainer:AddChild(BlacklistDebuffsContainer)

            local BlacklistDebuffsEditBox = AG:Create("MultiLineEditBox")
            BlacklistDebuffsEditBox:SetLabel("Blacklist Debuffs")
            BlacklistDebuffsEditBox:SetText(TableToList(UUF.db.profile.Filters.Blacklist.Debuffs or {}))
            BlacklistDebuffsEditBox:SetCallback("OnEnterPressed", function(widget, event, value)
                if not value or value == "" then BlacklistDebuffsEditBox:SetText(TableToList(UUF.db.profile.Filters.Blacklist and UUF.db.profile.Filters.Blacklist.Debuffs or {})) return end
                if not UUF.db.profile.Filters.Blacklist then UUF.db.profile.Filters.Blacklist = { Buffs = {}, Debuffs = {} } end
                if not UUF.db.profile.Filters.Blacklist.Debuffs then UUF.db.profile.Filters.Blacklist.Debuffs = {} end
                local debuffBlacklist = UUF.db.profile.Filters.Blacklist.Debuffs
                for id in string.gmatch(value, "[^,%s]+") do
                    local spellID = tonumber(id)
                    if spellID then
                        debuffBlacklist[spellID] = true
                    end
                end
                BlacklistDebuffsEditBox:SetText(TableToList(debuffBlacklist))
                for unitFrameName, unit in pairs(UnitFrames) do UUF:UpdateFrame(unitFrameName, unit) end
            end)
            BlacklistDebuffsEditBox:SetRelativeWidth(1)
            BlacklistDebuffsEditBox:SetNumLines(10)
            BlacklistDebuffsContainer:AddChild(BlacklistDebuffsEditBox)

            local AddImportantBlacklistBuffsDebuffsButton = AG:Create("Button")
            AddImportantBlacklistBuffsDebuffsButton:SetText("Add Important Buffs/Debuffs to Blacklist")
            AddImportantBlacklistBuffsDebuffsButton:SetFullWidth(true)
            AddImportantBlacklistBuffsDebuffsButton:SetCallback("OnClick", function()
                if not UUF.db.profile.Filters.Blacklist then UUF.db.profile.Filters.Blacklist = { Buffs = {}, Debuffs = {} } end
                if not UUF.db.profile.Filters.Blacklist.Buffs then UUF.db.profile.Filters.Blacklist.Buffs = {} end
                if not UUF.db.profile.Filters.Blacklist.Debuffs then UUF.db.profile.Filters.Blacklist.Debuffs = {} end
                local ImportantBuffs = UUF:FetchBuffBlacklist()
                for spellID in pairs(ImportantBuffs) do UUF.db.profile.Filters.Blacklist.Buffs[spellID] = true end
                local ImportantDebuffs = UUF:FetchDebuffBlacklist()
                for spellID in pairs(ImportantDebuffs) do UUF.db.profile.Filters.Blacklist.Debuffs[spellID] = true end
                BlacklistBuffsEditBox:SetText(TableToList(UUF.db.profile.Filters.Blacklist.Buffs))
                BlacklistDebuffsEditBox:SetText(TableToList(UUF.db.profile.Filters.Blacklist.Debuffs))
                for unitFrameName, unit in pairs(UnitFrames) do UUF:UpdateFrame(unitFrameName, unit) end
            end)
            BlacklistContainer:AddChild(AddImportantBlacklistBuffsDebuffsButton)
            local ClearBlacklistBuffsButton = AG:Create("Button")
            ClearBlacklistBuffsButton:SetText("Clear Blacklist Buffs")
            ClearBlacklistBuffsButton:SetRelativeWidth(1)
            ClearBlacklistBuffsButton:SetCallback("OnClick", function()
                if not UUF.db.profile.Filters.Blacklist then
                    UUF.db.profile.Filters.Blacklist = { Buffs = {}, Debuffs = {} }
                end
                UUF.db.profile.Filters.Blacklist.Buffs = {}
                BlacklistBuffsEditBox:SetText(TableToList(UUF.db.profile.Filters.Blacklist.Buffs))
                for unitFrameName, unit in pairs(UnitFrames) do UUF:UpdateFrame(unitFrameName, unit) end
            end)
            BlacklistBuffsContainer:AddChild(ClearBlacklistBuffsButton)
            local ClearBlacklistDebuffsButton = AG:Create("Button")
            ClearBlacklistDebuffsButton:SetText("Clear Blacklist Debuffs")
            ClearBlacklistDebuffsButton:SetRelativeWidth(1)
            ClearBlacklistDebuffsButton:SetCallback("OnClick", function()
                if not UUF.db.profile.Filters.Blacklist then
                    UUF.db.profile.Filters.Blacklist = { Buffs = {}, Debuffs = {} }
                end
                UUF.db.profile.Filters.Blacklist.Debuffs = {}
                BlacklistDebuffsEditBox:SetText(TableToList(UUF.db.profile.Filters.Blacklist.Debuffs))
                for unitFrameName, unit in pairs(UnitFrames) do UUF:UpdateFrame(unitFrameName, unit) end
            end)
            BlacklistDebuffsContainer:AddChild(ClearBlacklistDebuffsButton)


            ScrollFrame:DoLayout()
            WhitelistContainer:DoLayout()
            WhitelistBuffsContainer:DoLayout()
            WhitelistDebuffsContainer:DoLayout()
            BlacklistContainer:DoLayout()
            BlacklistBuffsContainer:DoLayout()
            BlacklistDebuffsContainer:DoLayout()

        end

        local function DrawUnitContainer(GUIContainer, unit)
            local ScrollFrame = AG:Create("ScrollFrame")
            ScrollFrame:SetLayout("Flow")
            ScrollFrame:SetFullWidth(true)
            ScrollFrame:SetFullHeight(true)
            GUIContainer:AddChild(ScrollFrame)

            local UUFDB = UUF.db.profile[unit]
            local Frame = UUFDB.Frame
            local PowerBar = UUFDB.PowerBar
            local Tags = UUFDB.Tags
            local Buffs = UUFDB.Buffs
            local Debuffs = UUFDB.Debuffs
            local Portrait = UUFDB.Portrait
            local Indicators = UUFDB.Indicators
            local RaidMarker = Indicators.RaidMarker
            local MouseoverHighlight = Indicators.MouseoverHighlight

            local isPlayer = unit == "player"
            local isTarget = unit == "target"

            local EnabledToggle = AG:Create("CheckBox")
            EnabledToggle:SetLabel("Enable |cFF8080FF" .. UUF:TitleCase(unit) .. "|r Frame")
            EnabledToggle:SetValue(UUFDB.Enabled)
            EnabledToggle:SetFullWidth(true)
            EnabledToggle:SetCallback("OnValueChanged", function(_, _, value)
                UUF.db.profile[unit].Enabled = value
                UUF:UpdateFrame(unitToUnitFrame[unit], unit)
                for i, child in ipairs(ScrollFrame.children) do
                    if i > 1 then
                        DeepDisable(child, not value)
                    end
                end
                ScrollFrame:DoLayout()
            end)
            ScrollFrame:AddChild(EnabledToggle)

            if unit == "boss" then
                local TestFrameButton = AG:Create("Button")
                TestFrameButton:SetText("Display Frames")
                TestFrameButton:SetCallback("OnClick", function()
                    if unit == "boss" then
                        UUF.BossTestMode = not UUF.BossTestMode
                        UUF:CreateTestBossFrames()
                    end

                    if unit == "party" then
                        UUF.PartyTestMode = not UUF.PartyTestMode
                        UUF:CreateTestPartyFrames()
                    end

                    if UUF.BossTestMode or UUF.PartyTestMode then
                        TestFrameButton:SetText("Hide Frames")
                    else
                        TestFrameButton:SetText("Display Frames")
                        UUF:Print("Advised to reload your UI (|cFF8080FF/reload|r) to save changes!")
                    end
                end)
                TestFrameButton:SetRelativeWidth(0.5)
                ScrollFrame:AddChild(TestFrameButton)
                EnabledToggle:SetRelativeWidth(0.5)
            end

            local function DrawFrameContainer(GUIContainer)
                local FrameToggleContainer = AG:Create("InlineGroup")
                FrameToggleContainer:SetTitle("Toggles")
                FrameToggleContainer:SetLayout("Flow")
                FrameToggleContainer:SetFullWidth(true)
                GUIContainer:AddChild(FrameToggleContainer)

                local FrameClassColourToggle = CreateToggle("Class Colour", Frame.ClassColour, unit, "Frame", nil, "ClassColour")
                local FrameReactionColourToggle = CreateToggle("Reaction Colour", Frame.ReactionColour, unit, "Frame", nil, "ReactionColour")
                FrameToggleContainer:AddChild(FrameClassColourToggle)
                FrameToggleContainer:AddChild(FrameReactionColourToggle)

                local ShowPlayerToggle = CreateToggle("Show Player", Frame.ShowPlayer, unit, "Frame", nil, "ShowPlayer")
                if unit == "party" then
                    FrameToggleContainer:AddChild(ShowPlayerToggle)
                    FrameClassColourToggle:SetRelativeWidth(0.33)
                    FrameReactionColourToggle:SetRelativeWidth(0.33)
                    ShowPlayerToggle:SetRelativeWidth(0.33)
                end

                local FrameColourPickerContainer = AG:Create("InlineGroup")
                FrameColourPickerContainer:SetTitle("Colours")
                FrameColourPickerContainer:SetLayout("Flow")
                FrameColourPickerContainer:SetFullWidth(true)
                GUIContainer:AddChild(FrameColourPickerContainer)

                local FrameForegroundColourPicker = CreateColourPicker("Foreground Colour", Frame.FGColour, unit, "Frame", nil, nil, "FGColour")
                local FrameBackgroundColourPicker = CreateColourPicker("Background Colour", Frame.BGColour, unit, "Frame", nil, nil,"BGColour")
                FrameColourPickerContainer:AddChild(FrameForegroundColourPicker)
                FrameColourPickerContainer:AddChild(FrameBackgroundColourPicker)

                local FramePositionContainer = AG:Create("InlineGroup")
                FramePositionContainer:SetTitle("Position")
                FramePositionContainer:SetLayout("Flow")
                FramePositionContainer:SetFullWidth(true)
                GUIContainer:AddChild(FramePositionContainer)

                local FrameWidthSlider = CreateSlider("Width", Frame.Width, unit, "Frame", nil, nil, "Width")
                local FrameHeightSlider = CreateSlider("Height", Frame.Height, unit, "Frame", nil, nil, "Height")
                local FrameXPosition = CreateSlider("X Position", Frame.XPosition, unit, "Frame", nil, nil, "XPosition")
                local FrameYPosition = CreateSlider("Y Position", Frame.YPosition, unit, "Frame", nil, nil, "YPosition")

                local FrameAnchorFromDropdown = CreateDropdown("Anchor From", Frame.AnchorFrom, unit, "Frame", nil, nil, "AnchorFrom")
                local FrameAnchorToDropdown = CreateDropdown("Anchor To", Frame.AnchorTo, unit, "Frame", nil, nil, "AnchorTo")
                local FrameGrowthDirectionDropdown;
                if Frame.GrowthDirection then
                    FrameGrowthDirectionDropdown = CreateDropdown("Growth Direction", Frame.GrowthDirection, unit, "Frame", nil, nil, "GrowthDirection")
                    FrameGrowthDirectionDropdown:SetList({
                        ["UP"] = "Up",
                        ["DOWN"] = "Down",
                    }, {"UP", "DOWN"})
                    FrameGrowthDirectionDropdown:SetRelativeWidth(0.33)
                    FrameAnchorFromDropdown:SetRelativeWidth(0.33)
                    FrameAnchorToDropdown:SetRelativeWidth(0.33)
                end
                local FrameLayoutDropdown;
                if Frame.Layout then
                    FrameLayoutDropdown = CreateDropdown("Layout", Frame.Layout, unit, "Frame", nil, nil, "Layout")
                    FrameLayoutDropdown:SetCallback("OnEnter", function()
                        GameTooltip:SetOwner(FrameLayoutDropdown.frame, "ANCHOR_TOPLEFT")
                        GameTooltip:AddLine("|cFF8080FFReload|r is required for changes to take effect.", 1, 1, 1)
                        GameTooltip:Show()
                    end)
                    FrameLayoutDropdown:SetCallback("OnLeave", function() GameTooltip:Hide() end)
                    FrameLayoutDropdown:SetRelativeWidth(0.33)
                    FrameAnchorFromDropdown:SetRelativeWidth(0.33)
                    FrameAnchorToDropdown:SetRelativeWidth(0.33)
                end
                local FrameSpacingSlider;
                if Frame.Spacing then
                    FrameSpacingSlider = CreateSlider("Spacing", Frame.Spacing, unit, "Frame", nil, nil, "Spacing")
                    FrameSpacingSlider:SetSliderValues(-1, 100, 1)
                    FrameSpacingSlider:SetRelativeWidth(0.33)
                    FrameXPosition:SetRelativeWidth(0.33)
                    FrameYPosition:SetRelativeWidth(0.33)
                end
                local FrameAnchorParent;
                if Frame.AnchorParent then
                    FrameAnchorParent = CreateAnchor("Anchor Parent", Frame.AnchorParent, unit, "Frame", nil, "AnchorParent")
                    FrameAnchorFromDropdown:SetRelativeWidth(0.33)
                    FrameAnchorToDropdown:SetRelativeWidth(0.33)
                    FrameAnchorParent:SetRelativeWidth(0.33)
                end

                FramePositionContainer:AddChild(FrameWidthSlider)
                FramePositionContainer:AddChild(FrameHeightSlider)
                FramePositionContainer:AddChild(FrameAnchorFromDropdown)
                FramePositionContainer:AddChild(FrameAnchorToDropdown)
                if Frame.AnchorParent then FramePositionContainer:AddChild(FrameAnchorParent) end
                if Frame.GrowthDirection then FramePositionContainer:AddChild(FrameGrowthDirectionDropdown) end
                if Frame.Layout then FramePositionContainer:AddChild(FrameLayoutDropdown) end
                FramePositionContainer:AddChild(FrameXPosition)
                FramePositionContainer:AddChild(FrameYPosition)
                if Frame.Spacing then FramePositionContainer:AddChild(FrameSpacingSlider) end

                if unit == "party" then
                    local SortOrderContainer = AG:Create("InlineGroup")
                    SortOrderContainer:SetTitle("Sort Order")
                    SortOrderContainer:SetLayout("Flow")
                    SortOrderContainer:SetFullWidth(true)
                    GUIContainer:AddChild(SortOrderContainer)

                    local roleList = {
                        ["TANK"]   = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\RoleIcons\\ElvUIV2\\Tank:18:18|t Tank",
                        ["HEALER"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\RoleIcons\\ElvUIV2\\Healer:18:18|t Healer",
                        ["DAMAGER"]= "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\RoleIcons\\ElvUIV2\\DPS:18:18|t DPS",
                    }
                    local roleOrder = { "TANK", "HEALER", "DAMAGER" }

                    for i = 1, 3 do
                        local Dropdown = AG:Create("Dropdown")
                        Dropdown:SetLabel("Position " .. i)
                        Dropdown:SetList(roleList, roleOrder)
                        Dropdown:SetValue(Frame.SortOrder[i])
                        Dropdown:SetRelativeWidth(0.33)

                        Dropdown:SetCallback("OnValueChanged", function(_, _, value)
                            Frame.SortOrder[i] = value
                            UUF:UpdateFrame(unitToUnitFrame[unit], unit)
                        end)

                        SortOrderContainer:AddChild(Dropdown)
                    end
                end

                if unit == "raid" then
                    local LayoutContainer = AG:Create("InlineGroup")
                    LayoutContainer:SetTitle("Layout")
                    LayoutContainer:SetLayout("Flow")
                    LayoutContainer:SetFullWidth(true)
                    GUIContainer:AddChild(LayoutContainer)

                    local GroupsToShowSlider = CreateSlider("Groups to Show", Frame.GroupsToShow, unit, "Frame", nil, nil, "GroupsToShow")
                    GroupsToShowSlider:SetSliderValues(1, 8, 1)
                    LayoutContainer:AddChild(GroupsToShowSlider)

                    local UnitsPerColumnSlider = CreateSlider("Units per Column", Frame.UnitsPerColumn, unit, "Frame", nil, nil, "UnitsPerColumn")
                    UnitsPerColumnSlider:SetSliderValues(1, 40, 1)
                    LayoutContainer:AddChild(UnitsPerColumnSlider)

                    local RowGrowthDropdown = CreateDropdown("Row Growth", Frame.RowGrowth, unit, "Frame", nil, nil, "RowGrowth")
                    LayoutContainer:AddChild(RowGrowthDropdown)

                    local ColumnGrowthDropdown = CreateDropdown("Column Growth", Frame.ColumnGrowth, unit, "Frame", nil, nil, "ColumnGrowth")
                    LayoutContainer:AddChild(ColumnGrowthDropdown)

                    LayoutContainer:DoLayout()
                end

                if unit ~= "player" then
                    local Range = UUFDB.Range

                    local RangeContainer = AG:Create("InlineGroup")
                    RangeContainer:SetTitle("Range Fading")
                    RangeContainer:SetLayout("Flow")
                    RangeContainer:SetFullWidth(true)
                    GUIContainer:AddChild(RangeContainer)

                    local RangeEnabledToggle = CreateToggle("Enable", Range.Enabled, unit, "Range", nil, "Enabled")
                    RangeEnabledToggle:SetRelativeWidth(1)
                    RangeContainer:AddChild(RangeEnabledToggle)

                    local InRangeAlphaSlider = CreateSlider("In Range Alpha", Range.InRange, unit, "Range", nil, nil, "InRange")
                    InRangeAlphaSlider:SetSliderValues(0, 1, 0.01)
                    InRangeAlphaSlider:SetIsPercent(true)
                    RangeContainer:AddChild(InRangeAlphaSlider)

                    local OutOfRangeAlphaSlider = CreateSlider("Out of Range Alpha", Range.OutOfRange, unit, "Range", nil, nil, "OutOfRange")
                    OutOfRangeAlphaSlider:SetSliderValues(0, 1, 0.01)
                    OutOfRangeAlphaSlider:SetIsPercent(true)
                    RangeContainer:AddChild(OutOfRangeAlphaSlider)

                    if not Range.Enabled then
                        for _, child in ipairs(RangeContainer.children) do
                            if child ~= RangeEnabledToggle then
                                DeepDisable(child, true)
                            end
                        end
                    end
                end
            end

            local function DrawHealPredictionContainer(GUIContainer)
                local HealPrediction = UUFDB.HealPrediction
                local Absorb = HealPrediction.Absorb
                local HealAbsorb = HealPrediction.HealAbsorb

                local HealPredictionAbsorbContainer = AG:Create("InlineGroup")
                HealPredictionAbsorbContainer:SetTitle("Absorbs")
                HealPredictionAbsorbContainer:SetLayout("Flow")
                HealPredictionAbsorbContainer:SetFullWidth(true)
                GUIContainer:AddChild(HealPredictionAbsorbContainer)

                local HealPredictionAbsorbInfoTag = CreateInfoTag("|cFF8080FFAbsorbs|r are displayed independently of the health bar.\nYou can adjust the |cFF8080FFheight|r / |cFF8080FFanchor point|r to suit your layout.")
                HealPredictionAbsorbContainer:AddChild(HealPredictionAbsorbInfoTag)

                local AbsorbEnabledToggle = CreateToggle("Enable Absorbs", Absorb.Enabled, unit, "HealPrediction", "Absorb", "Enabled")
                AbsorbEnabledToggle:SetRelativeWidth(0.5)
                HealPredictionAbsorbContainer:AddChild(AbsorbEnabledToggle)

                local AbsorbColourPicker = CreateColourPicker("Colour", Absorb.Colour, unit, "HealPrediction", "Absorb", nil, "Colour")
                AbsorbColourPicker:SetRelativeWidth(0.5)
                HealPredictionAbsorbContainer:AddChild(AbsorbColourPicker)

                local AbsorbHeightSlider = CreateSlider("Height", Absorb.Height, unit, "HealPrediction", "Absorb", nil, "Height")
                AbsorbHeightSlider:SetSliderValues(1, Frame.Height - (PowerBar.Enabled and (PowerBar.Height + 3) or 2), 1)
                AbsorbHeightSlider:SetRelativeWidth(0.5)
                HealPredictionAbsorbContainer:AddChild(AbsorbHeightSlider)

                local AbsorbAnchorPoint = CreateDropdown("Anchor Point", Absorb.AnchorPoint, unit, "HealPrediction", "Absorb", nil, "AnchorPoint")
                AbsorbAnchorPoint:SetList({ ["TOPLEFT"] = "Top Left", ["TOPRIGHT"] = "Top Right", ["BOTTOMLEFT"] = "Bottom Left", ["BOTTOMRIGHT"] = "Bottom Right", }, {"TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT"})
                AbsorbAnchorPoint:SetRelativeWidth(0.5)
                HealPredictionAbsorbContainer:AddChild(AbsorbAnchorPoint)

                local HealPredictionHealAbsorbContainer = AG:Create("InlineGroup")
                HealPredictionHealAbsorbContainer:SetTitle("Heal Absorbs")
                HealPredictionHealAbsorbContainer:SetLayout("Flow")
                HealPredictionHealAbsorbContainer:SetFullWidth(true)
                GUIContainer:AddChild(HealPredictionHealAbsorbContainer)

                local HealAbsorbEnabledToggle = CreateToggle("Enable Heal Absorbs", HealAbsorb.Enabled, unit, "HealPrediction", "HealAbsorb", "Enabled")
                HealAbsorbEnabledToggle:SetRelativeWidth(0.5)
                HealPredictionHealAbsorbContainer:AddChild(HealAbsorbEnabledToggle)

                local HealAbsorbColourPicker = CreateColourPicker("Colour", HealAbsorb.Colour, unit, "HealPrediction", "HealAbsorb", nil, "Colour")
                HealAbsorbColourPicker:SetRelativeWidth(0.5)
                HealPredictionHealAbsorbContainer:AddChild(HealAbsorbColourPicker)
            end

            local function DrawPowerBarContainer(GUIContainer)
                local PowerBarToggleContainer = AG:Create("InlineGroup")
                PowerBarToggleContainer:SetTitle("Power Bar")
                PowerBarToggleContainer:SetLayout("Flow")
                PowerBarToggleContainer:SetFullWidth(true)
                GUIContainer:AddChild(PowerBarToggleContainer)

                local PowerBarEnabledToggle = CreateToggle("Enable Power Bar", PowerBar.Enabled, unit, "PowerBar", nil, "Enabled")
                PowerBarToggleContainer:AddChild(PowerBarEnabledToggle)

                local PowerBarColourByTypeToggle = CreateToggle("Colour by Power Type", PowerBar.ColourByType, unit, "PowerBar", nil, "ColourByType")
                PowerBarToggleContainer:AddChild(PowerBarColourByTypeToggle)

                local PowerBarColourPickerContainer = AG:Create("InlineGroup")
                PowerBarColourPickerContainer:SetTitle("Colour")
                PowerBarColourPickerContainer:SetLayout("Flow")
                PowerBarColourPickerContainer:SetFullWidth(true)
                PowerBarToggleContainer:AddChild(PowerBarColourPickerContainer)

                local PowerBarFGColourPicker = CreateColourPicker("Foreground Colour", PowerBar.FGColour, unit, "PowerBar", nil, nil, "FGColour")
                PowerBarFGColourPicker:SetCallback("OnEnter", function()
                    local Desc = "|cFFFFCC00Colour by Power Type|r will override this."
                    GameTooltip:SetOwner(PowerBarFGColourPicker.frame, "ANCHOR_TOPLEFT")
                    GameTooltip:SetText(Desc, 1, 1, 1, 1, false)
                    GameTooltip:Show()
                end)
                PowerBarFGColourPicker:SetCallback("OnLeave", function() GameTooltip:Hide() end)
                PowerBarColourPickerContainer:AddChild(PowerBarFGColourPicker)

                local PowerBarBGColourPicker = CreateColourPicker("Background Colour", PowerBar.BGColour, unit, "PowerBar", nil, nil, "BGColour")
                PowerBarColourPickerContainer:AddChild(PowerBarBGColourPicker)

                local PowerBarPositionContainer = AG:Create("InlineGroup")
                PowerBarPositionContainer:SetTitle("Position")
                PowerBarPositionContainer:SetLayout("Flow")
                PowerBarPositionContainer:SetFullWidth(true)
                PowerBarToggleContainer:AddChild(PowerBarPositionContainer)

                local PowerBarHeightInfoTag = CreateInfoTag("This is limited by the overall height of the frame.")
                PowerBarPositionContainer:AddChild(PowerBarHeightInfoTag)

                local PowerBarHeightSlider = CreateSlider("Height", PowerBar.Height, unit, "PowerBar", nil, nil, "Height")
                PowerBarHeightSlider:SetSliderValues(1, Frame.Height, 1)
                PowerBarHeightSlider:SetRelativeWidth(1)
                PowerBarPositionContainer:AddChild(PowerBarHeightSlider)

                if not PowerBar.Enabled then
                    for _, child in ipairs(PowerBarToggleContainer.children) do
                        if child ~= PowerBarEnabledToggle then
                            DeepDisable(child, true)
                        end
                    end
                end
            end

            local function DrawCastBarContainer(GUIContainer)
                local CastBar = UUF.db.profile[unit].CastBar
                local CastBarEnableToggle = CreateToggle("Enable Cast Bar", CastBar.Enabled, unit, "CastBar", nil, "Enabled")
                GUIContainer:AddChild(CastBarEnableToggle)

                local CastBarFrameContainer = AG:Create("InlineGroup")
                CastBarFrameContainer:SetTitle("Frame")
                CastBarFrameContainer:SetLayout("Flow")
                CastBarFrameContainer:SetFullWidth(true)
                GUIContainer:AddChild(CastBarFrameContainer)

                local CastBarWidthSlider = CreateSlider("Width", CastBar.Width, unit, "CastBar", nil, nil, "Width")
                CastBarWidthSlider:SetRelativeWidth(0.33)
                CastBarFrameContainer:AddChild(CastBarWidthSlider)

                local CastBarHeightSlider = CreateSlider("Height", CastBar.Height, unit, "CastBar", nil, nil, "Height")
                CastBarHeightSlider:SetRelativeWidth(0.33)
                CastBarFrameContainer:AddChild(CastBarHeightSlider)

                local CastBarAutoSizeWidth = AG:Create("Button")
                CastBarAutoSizeWidth:SetText("Auto Size Width")
                CastBarAutoSizeWidth:SetCallback("OnClick", function()
                    UUF.db.profile[unit].CastBar.Width = UUF.db.profile[unit].Frame.Width
                    CastBarWidthSlider:SetValue(UUF.db.profile[unit].CastBar.Width)
                    UUF:UpdateFrame(unitToUnitFrame[unit], unit)
                end)
                CastBarAutoSizeWidth:SetCallback("OnEnter", function()
                    local Desc = "Match |cFFFFCC00Width|r of the "..UUF:TitleCase(unit)
                    GameTooltip:SetOwner(CastBarAutoSizeWidth.frame, "ANCHOR_TOPLEFT")
                    GameTooltip:SetText(Desc, 1, 1, 1, 1, false)
                    GameTooltip:Show()
                end)
                CastBarAutoSizeWidth:SetCallback("OnLeave", function()
                    GameTooltip:Hide()
                end)
                CastBarFrameContainer:AddChild(CastBarAutoSizeWidth)

                local CastBarAnchorInfoTag = CreateInfoTag("|cFF8080FFPosition|r / |cFF8080FFAnchors|r are relative to the " .. UUF:TitleCase(unit) .. " Frame.")
                CastBarFrameContainer:AddChild(CastBarAnchorInfoTag)

                local CastBarAnchorFrom = CreateDropdown("Anchor From", CastBar.AnchorFrom, unit, "CastBar", nil, nil, "AnchorFrom")
                CastBarFrameContainer:AddChild(CastBarAnchorFrom)

                local CastBarAnchorTo = CreateDropdown("Anchor To", CastBar.AnchorTo, unit, "CastBar", nil, nil, "AnchorTo")
                CastBarFrameContainer:AddChild(CastBarAnchorTo)

                local CastBarOffsetX = CreateSlider("Offset X", CastBar.OffsetX, unit, "CastBar", nil, nil, "OffsetX")
                CastBarFrameContainer:AddChild(CastBarOffsetX)

                local CastBarOffsetY = CreateSlider("Offset Y", CastBar.OffsetY, unit, "CastBar", nil, nil, "OffsetY")
                CastBarFrameContainer:AddChild(CastBarOffsetY)

                local CastBarColourContainer = AG:Create("InlineGroup")
                CastBarColourContainer:SetTitle("Colour")
                CastBarColourContainer:SetLayout("Flow")
                CastBarColourContainer:SetFullWidth(true)
                CastBarFrameContainer:AddChild(CastBarColourContainer)

                local CastBarFGColourPicker = CreateColourPicker("Foreground Colour", CastBar.FGColour, unit, "CastBar", nil, nil, "FGColour")
                CastBarFGColourPicker:SetRelativeWidth(0.33)
                CastBarColourContainer:AddChild(CastBarFGColourPicker)

                local CastBarBGColourPicker = CreateColourPicker("Background Colour", CastBar.BGColour, unit, "CastBar", nil, nil, "BGColour")
                CastBarBGColourPicker:SetRelativeWidth(0.33)
                CastBarColourContainer:AddChild(CastBarBGColourPicker)

                local CastBarNotInterruptibleColourPicker = CreateColourPicker("Not Interruptible Colour", CastBar.NotInterruptibleColour, unit, "CastBar", nil, nil, "NotInterruptibleColour")
                CastBarNotInterruptibleColourPicker:SetRelativeWidth(0.33)
                CastBarColourContainer:AddChild(CastBarNotInterruptibleColourPicker)

                local CastBarIconContainer = AG:Create("InlineGroup")
                CastBarIconContainer:SetTitle("Icon")
                CastBarIconContainer:SetLayout("Flow")
                CastBarIconContainer:SetFullWidth(true)
                GUIContainer:AddChild(CastBarIconContainer)

                local CastBarIconToggle = CreateToggle("Show Icon", CastBar.Icon.Enabled, unit, "CastBar", "Icon", "Enabled")
                CastBarIconContainer:AddChild(CastBarIconToggle)

                local CastBarSideDropdown = CreateDropdown("Icon Position", CastBar.Icon.Side, unit, "CastBar", "Icon", nil, "Side")
                CastBarSideDropdown:SetList({ ["LEFT"] = "Left", ["RIGHT"] = "Right", }, {"LEFT", "RIGHT"})
                CastBarIconContainer:AddChild(CastBarSideDropdown)

                local CastBarTextContainer = AG:Create("InlineGroup")
                CastBarTextContainer:SetTitle("Text")
                CastBarTextContainer:SetLayout("Flow")
                CastBarTextContainer:SetFullWidth(true)
                GUIContainer:AddChild(CastBarTextContainer)

                local CastBarTextsInfoTag = CreateInfoTag("|cFF8080FFPosition|r / |cFF8080FFAnchors|r are relative to the |cFF8080FF" .. UUF:TitleCase(unit) .. "|r's Cast Bar Frame.")
                CastBarTextContainer:AddChild(CastBarTextsInfoTag)

                local CastBarSpellNameTextContainer = AG:Create("InlineGroup")
                CastBarSpellNameTextContainer:SetTitle("Spell Name")
                CastBarSpellNameTextContainer:SetLayout("Flow")
                CastBarSpellNameTextContainer:SetFullWidth(true)
                CastBarTextContainer:AddChild(CastBarSpellNameTextContainer)

                local CastBarSpellNameTextColour = CreateColourPicker("Colour", CastBar.Texts.SpellName.Colour, unit, "CastBar", "Texts", "SpellName", "Colour")
                CastBarSpellNameTextColour:SetRelativeWidth(0.33)
                CastBarSpellNameTextContainer:AddChild(CastBarSpellNameTextColour)

                local CastBarSpellNameTextAnchorFrom = CreateDropdown("Anchor From", CastBar.Texts.SpellName.AnchorFrom, unit, "CastBar", "Texts", "SpellName", "AnchorFrom")
                CastBarSpellNameTextAnchorFrom:SetRelativeWidth(0.33)
                CastBarSpellNameTextContainer:AddChild(CastBarSpellNameTextAnchorFrom)

                local CastBarSpellNameTextAnchorTo = CreateDropdown("Anchor To", CastBar.Texts.SpellName.AnchorTo, unit, "CastBar", "Texts", "SpellName", "AnchorTo")
                CastBarSpellNameTextAnchorTo:SetRelativeWidth(0.33)
                CastBarSpellNameTextContainer:AddChild(CastBarSpellNameTextAnchorTo)

                local CastBarSpellNameTextOffsetX = CreateSlider("Offset X", CastBar.Texts.SpellName.OffsetX, unit, "CastBar", "Texts", "SpellName", "OffsetX")
                CastBarSpellNameTextOffsetX:SetRelativeWidth(0.25)
                CastBarSpellNameTextContainer:AddChild(CastBarSpellNameTextOffsetX)

                local CastBarSpellNameTextOffsetY = CreateSlider("Offset Y", CastBar.Texts.SpellName.OffsetY, unit, "CastBar", "Texts", "SpellName", "OffsetY")
                CastBarSpellNameTextOffsetY:SetRelativeWidth(0.25)
                CastBarSpellNameTextContainer:AddChild(CastBarSpellNameTextOffsetY)

                local CastBarSpellNameTextFontSize = CreateSlider("Font Size", CastBar.Texts.SpellName.FontSize, unit, "CastBar", "Texts", "SpellName", "FontSize")
                CastBarSpellNameTextFontSize:SetRelativeWidth(0.25)
                CastBarSpellNameTextContainer:AddChild(CastBarSpellNameTextFontSize)

                local CastBarSpellNameTextMaxChars = CreateSlider("Max Characters", CastBar.Texts.SpellName.MaxChars, unit, "CastBar", "Texts", "SpellName", "MaxChars")
                CastBarSpellNameTextMaxChars:SetSliderValues(1, 32, 1)
                CastBarSpellNameTextMaxChars:SetRelativeWidth(0.25)
                CastBarSpellNameTextMaxChars:SetCallback("OnEnter", function()
                    local Desc = "|cFF8080FFMax Characters|r to display of the spell name.\nSet to |cFFFF404032|r to show full name."
                    GameTooltip:SetOwner(CastBarSpellNameTextMaxChars.frame, "ANCHOR_TOPLEFT")
                    GameTooltip:SetText(Desc, 1, 1, 1, 1, false)
                    GameTooltip:Show()
                end)
                CastBarSpellNameTextMaxChars:SetCallback("OnLeave", function() GameTooltip:Hide() end)
                CastBarSpellNameTextContainer:AddChild(CastBarSpellNameTextMaxChars)

                local CastBarCastTimeTextContainer = AG:Create("InlineGroup")
                CastBarCastTimeTextContainer:SetTitle("Cast Time")
                CastBarCastTimeTextContainer:SetLayout("Flow")
                CastBarCastTimeTextContainer:SetFullWidth(true)
                CastBarTextContainer:AddChild(CastBarCastTimeTextContainer)

                local CastBarCastTimeTextColour = CreateColourPicker("Colour", CastBar.Texts.CastTime.Colour, unit, "CastBar", "Texts", "CastTime", "Colour")
                CastBarCastTimeTextColour:SetRelativeWidth(0.33)
                CastBarCastTimeTextContainer:AddChild(CastBarCastTimeTextColour)

                local CastBarCastTimeTextAnchorFrom = CreateDropdown("Anchor From", CastBar.Texts.CastTime.AnchorFrom, unit, "CastBar", "Texts", "CastTime", "AnchorFrom")
                CastBarCastTimeTextAnchorFrom:SetRelativeWidth(0.33)
                CastBarCastTimeTextContainer:AddChild(CastBarCastTimeTextAnchorFrom)

                local CastBarCastTimeTextAnchorTo = CreateDropdown("Anchor To", CastBar.Texts.CastTime.AnchorTo, unit, "CastBar", "Texts", "CastTime", "AnchorTo")
                CastBarCastTimeTextAnchorTo:SetRelativeWidth(0.33)
                CastBarCastTimeTextContainer:AddChild(CastBarCastTimeTextAnchorTo)

                local CastBarCastTimeTextOffsetX = CreateSlider("Offset X", CastBar.Texts.CastTime.OffsetX, unit, "CastBar", "Texts", "CastTime", "OffsetX")
                CastBarCastTimeTextOffsetX:SetRelativeWidth(0.25)
                CastBarCastTimeTextContainer:AddChild(CastBarCastTimeTextOffsetX)

                local CastBarCastTimeTextOffsetY = CreateSlider("Offset Y", CastBar.Texts.CastTime.OffsetY, unit, "CastBar", "Texts", "CastTime", "OffsetY")
                CastBarCastTimeTextOffsetY:SetRelativeWidth(0.25)
                CastBarCastTimeTextContainer:AddChild(CastBarCastTimeTextOffsetY)

                local CastBarCastTimeTextFontSize = CreateSlider("Font Size", CastBar.Texts.CastTime.FontSize, unit, "CastBar", "Texts", "CastTime", "FontSize")
                CastBarCastTimeTextFontSize:SetRelativeWidth(0.25)
                CastBarCastTimeTextContainer:AddChild(CastBarCastTimeTextFontSize)

                local CastBarCastTimeTextCriticalTime = CreateSlider("Critical Time", CastBar.Texts.CastTime.CriticalTime, unit, "CastBar", "Texts", "CastTime", "CriticalTime")
                CastBarCastTimeTextCriticalTime:SetSliderValues(0, 10, 1)
                CastBarCastTimeTextCriticalTime:SetRelativeWidth(0.25)
                CastBarCastTimeTextCriticalTime:SetCallback("OnEnter", function()
                    local Desc = "Duration remaining (|cFF8080FFin seconds|r) at which the text\nwill start using decimals. Set to |cFFFF40400|r to disable."
                    GameTooltip:SetOwner(CastBarCastTimeTextCriticalTime.frame, "ANCHOR_TOPLEFT")
                    GameTooltip:SetText(Desc, 1, 1, 1, 1, false)
                    GameTooltip:Show()
                end)
                CastBarCastTimeTextCriticalTime:SetCallback("OnLeave", function() GameTooltip:Hide() end)
                CastBarCastTimeTextContainer:AddChild(CastBarCastTimeTextCriticalTime)

                if not CastBar.Enabled then
                    for _, child in ipairs(GUIContainer.children) do
                        if child ~= CastBarEnableToggle then
                            DeepDisable(child, true)
                        end
                    end
                end

            end

            local function DrawTagsContainer(GUIContainer)
                local AnchorParentDropdown = AG:Create("Dropdown")
                AnchorParentDropdown:SetList({
                    ["FRAME"] = "Frame",
                    ["HEALTH"] = "Health Bar",
                }, {"FRAME", "HEALTH"})
                AnchorParentDropdown:SetLabel("Anchor Parent")
                AnchorParentDropdown:SetValue(Tags.AnchorParent)
                AnchorParentDropdown:SetRelativeWidth(0.3)
                AnchorParentDropdown:SetCallback("OnValueChanged", function(_, _, value)
                    UUF.db.profile[unit].Tags.AnchorParent = value
                    UUF:UpdateFrame(unitToUnitFrame[unit], unit)
                end)
                GUIContainer:AddChild(AnchorParentDropdown)

                local AnchorParentInfoTag = CreateInfoTag("|cFF8080FFAnchor Parent|r is the frame that all tags are anchored to.\nThis can be the |cFF8080FFFrame|r itself or the |cFF8080FFHealth Bar|r.")
                AnchorParentInfoTag:SetRelativeWidth(0.7)
                GUIContainer:AddChild(AnchorParentInfoTag)

                local function SelectedTagGroup(GUIContainer, _, tagGroup)
                    GUIContainer:ReleaseChildren()
                    local function DrawFirstTagContainer()
                        local FirstTagContainer = AG:Create("InlineGroup")
                        FirstTagContainer:SetTitle("Tag One")
                        FirstTagContainer:SetLayout("Flow")
                        FirstTagContainer:SetFullWidth(true)
                        GUIContainer:AddChild(FirstTagContainer)

                        local FirstTagAnchorFrom = CreateDropdown("Anchor From", Tags.First.AnchorFrom, unit, "Tags", "First", nil, "AnchorFrom")
                        FirstTagContainer:AddChild(FirstTagAnchorFrom)

                        local FirstTagAnchorTo = CreateDropdown("Anchor To", Tags.First.AnchorTo, unit, "Tags", "First", nil, "AnchorTo")
                        FirstTagContainer:AddChild(FirstTagAnchorTo)

                        local FirstTagOffsetX = CreateSlider("Offset X", Tags.First.OffsetX, unit, "Tags", "First", nil, "OffsetX")
                        FirstTagOffsetX:SetRelativeWidth(0.33)
                        FirstTagContainer:AddChild(FirstTagOffsetX)

                        local FirstTagOffsetY = CreateSlider("Offset Y", Tags.First.OffsetY, unit, "Tags", "First", nil, "OffsetY")
                        FirstTagOffsetY:SetRelativeWidth(0.33)
                        FirstTagContainer:AddChild(FirstTagOffsetY)

                        local FirstTagFontSize = CreateSlider("Font Size", Tags.First.FontSize, unit, "Tags", "First", nil, "FontSize")
                        FirstTagFontSize:SetRelativeWidth(0.33)
                        FirstTagContainer:AddChild(FirstTagFontSize)

                        local FirstTagColour = CreateColourPicker("Colour", Tags.First.Colour, unit, "Tags", "First", nil, "Colour")
                        FirstTagColour:SetCallback("OnEnter", function()
                            local Desc = "Changes the colour of the tag\n|cFFFF4040Overwritten|r by |cFFFFCC00[classcolour]|r / |cFFFFCC00[reactioncolour]|r / |cFFFFCC00[colour]|r tags."
                            GameTooltip:SetOwner(FirstTagColour.frame, "ANCHOR_TOPLEFT")
                            GameTooltip:SetText(Desc, 1, 1, 1, 1, false)
                            GameTooltip:Show()
                        end)
                        FirstTagColour:SetCallback("OnLeave", function() GameTooltip:Hide() end)
                        FirstTagContainer:AddChild(FirstTagColour)

                        local FirstTagText = CreateTag("Tag", Tags.First.Tag, unit, "Tags", "First", "Tag")
                        FirstTagContainer:AddChild(FirstTagText)

                        local FirstTagDropdownInfoTag = CreateInfoTag("|cFF8080FFTags|r can be added from the dropdowns below. Click on a tag to add it to the end of the current tag text.")
                        FirstTagContainer:AddChild(FirstTagDropdownInfoTag)

                        local FirstTagHealthDropdown = AG:Create("Dropdown")
                        FirstTagHealthDropdown:SetLabel("Health Tags")
                        FirstTagHealthDropdown:SetList(UUF:GetHealthTags())
                        FirstTagHealthDropdown:SetValue(nil)
                        FirstTagHealthDropdown:SetRelativeWidth(0.5)
                        FirstTagHealthDropdown:SetCallback("OnValueChanged", function(_, _, value)
                            local current = FirstTagText:GetText()
                            if current and current ~= "" then
                                current = current .. "[" .. value .. "]"
                            else
                                current = "[" .. value .. "]"
                            end
                            FirstTagText:SetText(current)
                            UUF.db.profile[unit].Tags.First.Tag = current
                            UUF:UpdateFrame(unitToUnitFrame[unit], unit)
                            FirstTagHealthDropdown:SetValue(nil)
                        end)
                        FirstTagContainer:AddChild(FirstTagHealthDropdown)

                        local FirstTagPowerDropdown = AG:Create("Dropdown")
                        FirstTagPowerDropdown:SetLabel("Power Tags")
                        FirstTagPowerDropdown:SetList(UUF:GetPowerTags())
                        FirstTagPowerDropdown:SetValue(nil)
                        FirstTagPowerDropdown:SetRelativeWidth(0.5)
                        FirstTagPowerDropdown:SetCallback("OnValueChanged", function(_, _, value)
                            local current = FirstTagText:GetText()
                            if current and current ~= "" then
                                current = current .. "[" .. value .. "]"
                            else
                                current = "[" .. value .. "]"
                            end
                            FirstTagText:SetText(current)
                            UUF.db.profile[unit].Tags.First.Tag = current
                            UUF:UpdateFrame(unitToUnitFrame[unit], unit)
                            FirstTagPowerDropdown:SetValue(nil)
                        end)
                        FirstTagContainer:AddChild(FirstTagPowerDropdown)

                        local FirstTagNameDropdown = AG:Create("Dropdown")
                        FirstTagNameDropdown:SetLabel("Name Tags")
                        FirstTagNameDropdown:SetList(UUF:GetNameTags())
                        FirstTagNameDropdown:SetValue(nil)
                        FirstTagNameDropdown:SetRelativeWidth(0.5)
                        FirstTagNameDropdown:SetCallback("OnValueChanged", function(_, _, value)
                            local current = FirstTagText:GetText()
                            if current and current ~= "" then
                                current = current .. "[" .. value .. "]"
                            else
                                current = "[" .. value .. "]"
                            end
                            FirstTagText:SetText(current)
                            UUF.db.profile[unit].Tags.First.Tag = current
                            UUF:UpdateFrame(unitToUnitFrame[unit], unit)
                            FirstTagNameDropdown:SetValue(nil)
                        end)
                        FirstTagContainer:AddChild(FirstTagNameDropdown)

                        local FirstTagMiscDropdown = AG:Create("Dropdown")
                        FirstTagMiscDropdown:SetLabel("Miscellaneous Tags")
                        FirstTagMiscDropdown:SetList(UUF:GetMiscTags())
                        FirstTagMiscDropdown:SetValue(nil)
                        FirstTagMiscDropdown:SetRelativeWidth(0.5)
                        FirstTagMiscDropdown:SetCallback("OnValueChanged", function(_, _, value)
                            local current = FirstTagText:GetText()
                            if current and current ~= "" then
                                current = current .. "[" .. value .. "]"
                            else
                                current = "[" .. value .. "]"
                            end
                            FirstTagText:SetText(current)
                            UUF.db.profile[unit].Tags.First.Tag = current
                            UUF:UpdateFrame(unitToUnitFrame[unit], unit)
                            FirstTagMiscDropdown:SetValue(nil)
                        end)
                        FirstTagContainer:AddChild(FirstTagMiscDropdown)
                        FirstTagContainer:DoLayout()
                    end
                    local function DrawSecondTagContainer()
                        local SecondTagContainer = AG:Create("InlineGroup")
                        SecondTagContainer:SetTitle("Tag Two")
                        SecondTagContainer:SetLayout("Flow")
                        SecondTagContainer:SetFullWidth(true)
                        GUIContainer:AddChild(SecondTagContainer)

                        local SecondTagAnchorFrom = CreateDropdown("Anchor From", Tags.Second.AnchorFrom, unit, "Tags", "Second", nil, "AnchorFrom")
                        SecondTagContainer:AddChild(SecondTagAnchorFrom)

                        local SecondTagAnchorTo = CreateDropdown("Anchor To", Tags.Second.AnchorTo, unit, "Tags", "Second", nil, "AnchorTo")
                        SecondTagContainer:AddChild(SecondTagAnchorTo)

                        local SecondTagOffsetX = CreateSlider("Offset X", Tags.Second.OffsetX, unit, "Tags", "Second", nil, "OffsetX")
                        SecondTagOffsetX:SetRelativeWidth(0.33)
                        SecondTagContainer:AddChild(SecondTagOffsetX)

                        local SecondTagOffsetY = CreateSlider("Offset Y", Tags.Second.OffsetY, unit, "Tags", "Second", nil, "OffsetY")
                        SecondTagOffsetY:SetRelativeWidth(0.33)
                        SecondTagContainer:AddChild(SecondTagOffsetY)

                        local SecondTagFontSize = CreateSlider("Font Size", Tags.Second.FontSize, unit, "Tags", "Second", nil, "FontSize")
                        SecondTagFontSize:SetRelativeWidth(0.33)
                        SecondTagContainer:AddChild(SecondTagFontSize)

                        local SecondTagColour = CreateColourPicker("Colour", Tags.Second.Colour, unit, "Tags", "Second", nil, "Colour")
                        SecondTagColour:SetCallback("OnEnter", function()
                            local Desc = "Changes the colour of the tag\n|cFFFF4040Overwritten|r by |cFFFFCC00[classcolour]|r / |cFFFFCC00[reactioncolour]|r / |cFFFFCC00[colour]|r tags."
                            GameTooltip:SetOwner(SecondTagColour.frame, "ANCHOR_TOPLEFT")
                            GameTooltip:SetText(Desc, 1, 1, 1, 1, false)
                            GameTooltip:Show()
                        end)
                        SecondTagColour:SetCallback("OnLeave", function() GameTooltip:Hide() end)
                        SecondTagContainer:AddChild(SecondTagColour)

                        local SecondTagText = CreateTag("Tag", Tags.Second.Tag, unit, "Tags", "Second", "Tag")
                        SecondTagContainer:AddChild(SecondTagText)

                        local SecondTagDropdownInfoTag = CreateInfoTag("|cFF8080FFTags|r can be added from the dropdowns below. Click on a tag to add it to the end of the current tag text.")
                        SecondTagContainer:AddChild(SecondTagDropdownInfoTag)

                        local SecondTagHealthDropdown = AG:Create("Dropdown")
                        SecondTagHealthDropdown:SetLabel("Health Tags")
                        SecondTagHealthDropdown:SetList(UUF:GetHealthTags())
                        SecondTagHealthDropdown:SetValue(nil)
                        SecondTagHealthDropdown:SetRelativeWidth(0.5)
                        SecondTagHealthDropdown:SetCallback("OnValueChanged", function(_, _, value)
                            local current = SecondTagText:GetText()
                            if current and current ~= "" then
                                current = current .. "[" .. value .. "]"
                            else
                                current = "[" .. value .. "]"
                            end
                            SecondTagText:SetText(current)
                            UUF.db.profile[unit].Tags.Second.Tag = current
                            UUF:UpdateFrame(unitToUnitFrame[unit], unit)
                            SecondTagHealthDropdown:SetValue(nil)
                        end)
                        SecondTagContainer:AddChild(SecondTagHealthDropdown)

                        local SecondTagPowerDropdown = AG:Create("Dropdown")
                        SecondTagPowerDropdown:SetLabel("Power Tags")
                        SecondTagPowerDropdown:SetList(UUF:GetPowerTags())
                        SecondTagPowerDropdown:SetValue(nil)
                        SecondTagPowerDropdown:SetRelativeWidth(0.5)
                        SecondTagPowerDropdown:SetCallback("OnValueChanged", function(_, _, value)
                            local current = SecondTagText:GetText()
                            if current and current ~= "" then
                                current = current .. "[" .. value .. "]"
                            else
                                current = "[" .. value .. "]"
                            end
                            SecondTagText:SetText(current)
                            UUF.db.profile[unit].Tags.Second.Tag = current
                            UUF:UpdateFrame(unitToUnitFrame[unit], unit)
                            SecondTagPowerDropdown:SetValue(nil)
                        end)
                        SecondTagContainer:AddChild(SecondTagPowerDropdown)

                        local SecondTagNameDropdown = AG:Create("Dropdown")
                        SecondTagNameDropdown:SetLabel("Name Tags")
                        SecondTagNameDropdown:SetList(UUF:GetNameTags())
                        SecondTagNameDropdown:SetValue(nil)
                        SecondTagNameDropdown:SetRelativeWidth(0.5)
                        SecondTagNameDropdown:SetCallback("OnValueChanged", function(_, _, value)
                            local current = SecondTagText:GetText()
                            if current and current ~= "" then
                                current = current .. "[" .. value .. "]"
                            else
                                current = "[" .. value .. "]"
                            end
                            SecondTagText:SetText(current)
                            UUF.db.profile[unit].Tags.Second.Tag = current
                            UUF:UpdateFrame(unitToUnitFrame[unit], unit)
                            SecondTagNameDropdown:SetValue(nil)
                        end)
                        SecondTagContainer:AddChild(SecondTagNameDropdown)

                        local SecondTagMiscDropdown = AG:Create("Dropdown")
                        SecondTagMiscDropdown:SetLabel("Miscellaneous Tags")
                        SecondTagMiscDropdown:SetList(UUF:GetMiscTags())
                        SecondTagMiscDropdown:SetValue(nil)
                        SecondTagMiscDropdown:SetRelativeWidth(0.5)
                        SecondTagMiscDropdown:SetCallback("OnValueChanged", function(_, _, value)
                            local current = SecondTagText:GetText()
                            if current and current ~= "" then
                                current = current .. "[" .. value .. "]"
                            else
                                current = "[" .. value .. "]"
                            end
                            SecondTagText:SetText(current)
                            UUF.db.profile[unit].Tags.Second.Tag = current
                            UUF:UpdateFrame(unitToUnitFrame[unit], unit)
                            SecondTagMiscDropdown:SetValue(nil)
                        end)
                        SecondTagContainer:AddChild(SecondTagMiscDropdown)
                        SecondTagContainer:DoLayout()
                    end
                    local function DrawThirdTagContainer()
                        local ThirdTagContainer = AG:Create("InlineGroup")
                        ThirdTagContainer:SetTitle("Tag Three")
                        ThirdTagContainer:SetLayout("Flow")
                        ThirdTagContainer:SetFullWidth(true)
                        GUIContainer:AddChild(ThirdTagContainer)

                        local ThirdTagAnchorFrom = CreateDropdown("Anchor From", Tags.Third.AnchorFrom, unit, "Tags", "Third", nil, "AnchorFrom")
                        ThirdTagContainer:AddChild(ThirdTagAnchorFrom)

                        local ThirdTagAnchorTo = CreateDropdown("Anchor To", Tags.Third.AnchorTo, unit, "Tags", "Third", nil, "AnchorTo")
                        ThirdTagContainer:AddChild(ThirdTagAnchorTo)

                        local ThirdTagOffsetX = CreateSlider("Offset X", Tags.Third.OffsetX, unit, "Tags", "Third", nil, "OffsetX")
                        ThirdTagOffsetX:SetRelativeWidth(0.33)
                        ThirdTagContainer:AddChild(ThirdTagOffsetX)

                        local ThirdTagOffsetY = CreateSlider("Offset Y", Tags.Third.OffsetY, unit, "Tags", "Third", nil, "OffsetY")
                        ThirdTagOffsetY:SetRelativeWidth(0.33)
                        ThirdTagContainer:AddChild(ThirdTagOffsetY)

                        local ThirdTagFontSize = CreateSlider("Font Size", Tags.Third.FontSize, unit, "Tags", "Third", nil, "FontSize")
                        ThirdTagFontSize:SetRelativeWidth(0.33)
                        ThirdTagContainer:AddChild(ThirdTagFontSize)

                        local ThirdTagColour = CreateColourPicker("Colour", Tags.Third.Colour, unit, "Tags", "Third", nil, "Colour")
                        ThirdTagColour:SetCallback("OnEnter", function()
                            local Desc = "Changes the colour of the tag\n|cFFFF4040Overwritten|r by |cFFFFCC00[classcolour]|r / |cFFFFCC00[reactioncolour]|r / |cFFFFCC00[colour]|r tags."
                            GameTooltip:SetOwner(ThirdTagColour.frame, "ANCHOR_TOPLEFT")
                            GameTooltip:SetText(Desc, 1, 1, 1, 1, false)
                            GameTooltip:Show()
                        end)
                        ThirdTagColour:SetCallback("OnLeave", function() GameTooltip:Hide() end)
                        ThirdTagContainer:AddChild(ThirdTagColour)

                        local ThirdTagText = CreateTag("Tag", Tags.Third.Tag, unit, "Tags", "Third", "Tag")
                        ThirdTagContainer:AddChild(ThirdTagText)

                        local ThirdTagDropdownInfoTag = CreateInfoTag("|cFF8080FFTags|r can be added from the dropdowns below. Click on a tag to add it to the end of the current tag text.")
                        ThirdTagContainer:AddChild(ThirdTagDropdownInfoTag)

                        local ThirdTagHealthDropdown = AG:Create("Dropdown")
                        ThirdTagHealthDropdown:SetLabel("Health Tags")
                        ThirdTagHealthDropdown:SetList(UUF:GetHealthTags())
                        ThirdTagHealthDropdown:SetValue(nil)
                        ThirdTagHealthDropdown:SetRelativeWidth(0.5)
                        ThirdTagHealthDropdown:SetCallback("OnValueChanged", function(_, _, value)
                            local current = ThirdTagText:GetText()
                            if current and current ~= "" then
                                current = current .. "[" .. value .. "]"
                            else
                                current = "[" .. value .. "]"
                            end
                            ThirdTagText:SetText(current)
                            UUF.db.profile[unit].Tags.Third.Tag = current
                            UUF:UpdateFrame(unitToUnitFrame[unit], unit)
                            ThirdTagHealthDropdown:SetValue(nil)
                        end)
                        ThirdTagContainer:AddChild(ThirdTagHealthDropdown)

                        local ThirdTagPowerDropdown = AG:Create("Dropdown")
                        ThirdTagPowerDropdown:SetLabel("Power Tags")
                        ThirdTagPowerDropdown:SetList(UUF:GetPowerTags())
                        ThirdTagPowerDropdown:SetValue(nil)
                        ThirdTagPowerDropdown:SetRelativeWidth(0.5)
                        ThirdTagPowerDropdown:SetCallback("OnValueChanged", function(_, _, value)
                            local current = ThirdTagText:GetText()
                            if current and current ~= "" then
                                current = current .. "[" .. value .. "]"
                            else
                                current = "[" .. value .. "]"
                            end
                            ThirdTagText:SetText(current)
                            UUF.db.profile[unit].Tags.Third.Tag = current
                            UUF:UpdateFrame(unitToUnitFrame[unit], unit)
                            ThirdTagPowerDropdown:SetValue(nil)
                        end)
                        ThirdTagContainer:AddChild(ThirdTagPowerDropdown)

                        local ThirdTagNameDropdown = AG:Create("Dropdown")
                        ThirdTagNameDropdown:SetLabel("Name Tags")
                        ThirdTagNameDropdown:SetList(UUF:GetNameTags())
                        ThirdTagNameDropdown:SetValue(nil)
                        ThirdTagNameDropdown:SetRelativeWidth(0.5)
                        ThirdTagNameDropdown:SetCallback("OnValueChanged", function(_, _, value)
                            local current = ThirdTagText:GetText()
                            if current and current ~= "" then
                                current = current .. "[" .. value .. "]"
                            else
                                current = "[" .. value .. "]"
                            end
                            ThirdTagText:SetText(current)
                            UUF.db.profile[unit].Tags.Third.Tag = current
                            UUF:UpdateFrame(unitToUnitFrame[unit], unit)
                            ThirdTagNameDropdown:SetValue(nil)
                        end)
                        ThirdTagContainer:AddChild(ThirdTagNameDropdown)

                        local ThirdTagMiscDropdown = AG:Create("Dropdown")
                        ThirdTagMiscDropdown:SetLabel("Miscellaneous Tags")
                        ThirdTagMiscDropdown:SetList(UUF:GetMiscTags())
                        ThirdTagMiscDropdown:SetValue(nil)
                        ThirdTagMiscDropdown:SetRelativeWidth(0.5)
                        ThirdTagMiscDropdown:SetCallback("OnValueChanged", function(_, _, value)
                            local current = ThirdTagText:GetText()
                            if current and current ~= "" then
                                current = current .. "[" .. value .. "]"
                            else
                                current = "[" .. value .. "]"
                            end
                            ThirdTagText:SetText(current)
                            UUF.db.profile[unit].Tags.Third.Tag = current
                            UUF:UpdateFrame(unitToUnitFrame[unit], unit)
                            ThirdTagMiscDropdown:SetValue(nil)
                        end)
                        ThirdTagContainer:AddChild(ThirdTagMiscDropdown)
                        ThirdTagContainer:DoLayout()
                    end
                    local function DrawFourthTagContainer()
                        local FourthTagContainer = AG:Create("InlineGroup")
                        FourthTagContainer:SetTitle("Tag Four")
                        FourthTagContainer:SetLayout("Flow")
                        FourthTagContainer:SetFullWidth(true)
                        GUIContainer:AddChild(FourthTagContainer)

                        local FourthTagAnchorFrom = CreateDropdown("Anchor From", Tags.Fourth.AnchorFrom, unit, "Tags", "Fourth", nil, "AnchorFrom")
                        FourthTagContainer:AddChild(FourthTagAnchorFrom)

                        local FourthTagAnchorTo = CreateDropdown("Anchor To", Tags.Fourth.AnchorTo, unit, "Tags", "Fourth", nil, "AnchorTo")
                        FourthTagContainer:AddChild(FourthTagAnchorTo)

                        local FourthTagOffsetX = CreateSlider("Offset X", Tags.Fourth.OffsetX, unit, "Tags", "Fourth", nil, "OffsetX")
                        FourthTagOffsetX:SetRelativeWidth(0.33)
                        FourthTagContainer:AddChild(FourthTagOffsetX)

                        local FourthTagOffsetY = CreateSlider("Offset Y", Tags.Fourth.OffsetY, unit, "Tags", "Fourth", nil, "OffsetY")
                        FourthTagOffsetY:SetRelativeWidth(0.33)
                        FourthTagContainer:AddChild(FourthTagOffsetY)

                        local FourthTagFontSize = CreateSlider("Font Size", Tags.Fourth.FontSize, unit, "Tags", "Fourth", nil, "FontSize")
                        FourthTagFontSize:SetRelativeWidth(0.33)
                        FourthTagContainer:AddChild(FourthTagFontSize)

                        local FourthTagColour = CreateColourPicker("Colour", Tags.Fourth.Colour, unit, "Tags", "Fourth", nil, "Colour")
                        FourthTagColour:SetCallback("OnEnter", function()
                            local Desc = "Changes the colour of the tag\n|cFFFF4040Overwritten|r by |cFFFFCC00[classcolour]|r / |cFFFFCC00[reactioncolour]|r / |cFFFFCC00[colour]|r tags."
                            GameTooltip:SetOwner(FourthTagColour.frame, "ANCHOR_TOPLEFT")
                            GameTooltip:SetText(Desc, 1, 1, 1, 1, false)
                            GameTooltip:Show()
                        end)
                        FourthTagColour:SetCallback("OnLeave", function() GameTooltip:Hide() end)
                        FourthTagContainer:AddChild(FourthTagColour)

                        local FourthTagText = CreateTag("Tag", Tags.Fourth.Tag, unit, "Tags", "Fourth", "Tag")
                        FourthTagContainer:AddChild(FourthTagText)

                        local FourthTagDropdownInfoTag = CreateInfoTag("|cFF8080FFTags|r can be added from the dropdowns below. Click on a tag to add it to the end of the current tag text.")
                        FourthTagContainer:AddChild(FourthTagDropdownInfoTag)

                        local FourthTagHealthDropdown = AG:Create("Dropdown")
                        FourthTagHealthDropdown:SetLabel("Health Tags")
                        FourthTagHealthDropdown:SetList(UUF:GetHealthTags())
                        FourthTagHealthDropdown:SetValue(nil)
                        FourthTagHealthDropdown:SetRelativeWidth(0.5)
                        FourthTagHealthDropdown:SetCallback("OnValueChanged", function(_, _, value)
                            local current = FourthTagText:GetText()
                            if current and current ~= "" then
                                current = current .. "[" .. value .. "]"
                            else
                                current = "[" .. value .. "]"
                            end
                            FourthTagText:SetText(current)
                            UUF.db.profile[unit].Tags.Fourth.Tag = current
                            UUF:UpdateFrame(unitToUnitFrame[unit], unit)
                            FourthTagHealthDropdown:SetValue(nil)
                        end)
                        FourthTagContainer:AddChild(FourthTagHealthDropdown)

                        local FourthTagPowerDropdown = AG:Create("Dropdown")
                        FourthTagPowerDropdown:SetLabel("Power Tags")
                        FourthTagPowerDropdown:SetList(UUF:GetPowerTags())
                        FourthTagPowerDropdown:SetValue(nil)
                        FourthTagPowerDropdown:SetRelativeWidth(0.5)
                        FourthTagPowerDropdown:SetCallback("OnValueChanged", function(_, _, value)
                            local current = FourthTagText:GetText()
                            if current and current ~= "" then
                                current = current .. "[" .. value .. "]"
                            else
                                current = "[" .. value .. "]"
                            end
                            FourthTagText:SetText(current)
                            UUF.db.profile[unit].Tags.Fourth.Tag = current
                            UUF:UpdateFrame(unitToUnitFrame[unit], unit)
                            FourthTagPowerDropdown:SetValue(nil)
                        end)
                        FourthTagContainer:AddChild(FourthTagPowerDropdown)

                        local FourthTagNameDropdown = AG:Create("Dropdown")
                        FourthTagNameDropdown:SetLabel("Name Tags")
                        FourthTagNameDropdown:SetList(UUF:GetNameTags())
                        FourthTagNameDropdown:SetValue(nil)
                        FourthTagNameDropdown:SetRelativeWidth(0.5)
                        FourthTagNameDropdown:SetCallback("OnValueChanged", function(_, _, value)
                            local current = FourthTagText:GetText()
                            if current and current ~= "" then
                                current = current .. "[" .. value .. "]"
                            else
                                current = "[" .. value .. "]"
                            end
                            FourthTagText:SetText(current)
                            UUF.db.profile[unit].Tags.Fourth.Tag = current
                            UUF:UpdateFrame(unitToUnitFrame[unit], unit)
                            FourthTagNameDropdown:SetValue(nil)
                        end)
                        FourthTagContainer:AddChild(FourthTagNameDropdown)

                        local FourthTagMiscDropdown = AG:Create("Dropdown")
                        FourthTagMiscDropdown:SetLabel("Miscellaneous Tags")
                        FourthTagMiscDropdown:SetList(UUF:GetMiscTags())
                        FourthTagMiscDropdown:SetValue(nil)
                        FourthTagMiscDropdown:SetRelativeWidth(0.5)
                        FourthTagMiscDropdown:SetCallback("OnValueChanged", function(_, _, value)
                            local current = FourthTagText:GetText()
                            if current and current ~= "" then
                                current = current .. "[" .. value .. "]"
                            else
                                current = "[" .. value .. "]"
                            end
                            FourthTagText:SetText(current)
                            UUF.db.profile[unit].Tags.Fourth.Tag = current
                            UUF:UpdateFrame(unitToUnitFrame[unit], unit)
                            FourthTagMiscDropdown:SetValue(nil)
                        end)
                        FourthTagContainer:AddChild(FourthTagMiscDropdown)
                        FourthTagContainer:DoLayout()
                    end
                    if tagGroup == "First" then
                        DrawFirstTagContainer()
                    elseif tagGroup == "Second" then
                        DrawSecondTagContainer()
                    elseif tagGroup == "Third" then
                        DrawThirdTagContainer()
                    elseif tagGroup == "Fourth" then
                        DrawFourthTagContainer()
                    end
                    if not UUF.db.profile[unit].Enabled then
                        for i, child in ipairs(ScrollFrame.children) do
                            if i > 1 then
                                DeepDisable(child, true)
                            end
                        end
                    end
                    ScrollFrame:DoLayout()
                end

                local TagsContainerTabGroup = AG:Create("TabGroup")
                TagsContainerTabGroup:SetLayout("Flow")
                TagsContainerTabGroup:SetFullWidth(true)
                TagsContainerTabGroup:SetTabs({
                    { text = "Tag One", value = "First"},
                    { text = "Tag Two", value = "Second"},
                    { text = "Tag Three", value = "Third"},
                    { text = "Tag Four", value = "Fourth"},
                })
                TagsContainerTabGroup:SetCallback("OnGroupSelected", SelectedTagGroup)
                TagsContainerTabGroup:SelectTab("First")
                GUIContainer:AddChild(TagsContainerTabGroup)
            end

            local function DrawBuffsContainer(GUIContainer)

                local BuffsEnabledToggle = CreateToggle("Enable", Buffs.Enabled, unit, "Buffs", nil, "Enabled")
                GUIContainer:AddChild(BuffsEnabledToggle)

                local BuffsPositionContainer = AG:Create("InlineGroup")
                BuffsPositionContainer:SetTitle("Position")
                BuffsPositionContainer:SetLayout("Flow")
                BuffsPositionContainer:SetFullWidth(true)
                GUIContainer:AddChild(BuffsPositionContainer)

                local BuffsAnchorInfoTag = CreateInfoTag("|cFF8080FFPosition|r / |cFF8080FFAnchors|r are relative to the " .. UUF:TitleCase(unit) .. " Frame.")
                BuffsPositionContainer:AddChild(BuffsAnchorInfoTag)

                local BuffsAnchorFromDropdown = CreateDropdown("Anchor From", Buffs.AnchorFrom, unit, "Buffs", nil, nil, "AnchorFrom")
                BuffsPositionContainer:AddChild(BuffsAnchorFromDropdown)

                local BuffsAnchorToDropdown = CreateDropdown("Anchor To", Buffs.AnchorTo, unit, "Buffs", nil, nil, "AnchorTo")
                BuffsPositionContainer:AddChild(BuffsAnchorToDropdown)

                local BuffsOffsetXSlider = CreateSlider("Offset X", Buffs.OffsetX, unit, "Buffs", nil, nil, "OffsetX")
                BuffsPositionContainer:AddChild(BuffsOffsetXSlider)

                local BuffsOffsetYSlider = CreateSlider("Offset Y", Buffs.OffsetY, unit, "Buffs", nil, nil, "OffsetY")
                BuffsPositionContainer:AddChild(BuffsOffsetYSlider)

                local BuffsSizeSlider = CreateSlider("Size", Buffs.Size, unit, "Buffs", nil, nil, "Size")
                BuffsPositionContainer:AddChild(BuffsSizeSlider)

                local BuffsSpacingSlider = CreateSlider("Spacing", Buffs.Spacing, unit, "Buffs", nil, nil, "Spacing")
                BuffsPositionContainer:AddChild(BuffsSpacingSlider)

                local BuffsLayoutContainer = AG:Create("InlineGroup")
                BuffsLayoutContainer:SetTitle("Layout")
                BuffsLayoutContainer:SetLayout("Flow")
                BuffsLayoutContainer:SetFullWidth(true)
                GUIContainer:AddChild(BuffsLayoutContainer)

                local BuffsNumSlider = CreateSlider("Number of Buffs", Buffs.Num, unit, "Buffs", nil, nil, "Num")
                BuffsLayoutContainer:AddChild(BuffsNumSlider)

                local BuffsWrapSlider = CreateSlider("Wrap After", Buffs.Wrap, unit, "Buffs", nil, nil, "Wrap")
                BuffsLayoutContainer:AddChild(BuffsWrapSlider)

                local BuffsGrowthDropdown = CreateDropdown("Growth Direction", Buffs.Growth, unit, "Buffs", nil, nil, "Growth")
                BuffsLayoutContainer:AddChild(BuffsGrowthDropdown)

                local BuffsWrapDirectionDropdown = CreateDropdown("Wrap Direction", Buffs.WrapDirection, unit, "Buffs", nil, nil, "WrapDirection")
                BuffsLayoutContainer:AddChild(BuffsWrapDirectionDropdown)

                local BuffsCountContainer = AG:Create("InlineGroup")
                BuffsCountContainer:SetTitle("Count / Stacks")
                BuffsCountContainer:SetLayout("Flow")
                BuffsCountContainer:SetFullWidth(true)
                GUIContainer:AddChild(BuffsCountContainer)

                local BuffsCountAnchorInfoTag = CreateInfoTag("|cFF8080FFPosition|r / |cFF8080FFAnchors|r are relative to the Aura Frame.")
                BuffsCountContainer:AddChild(BuffsCountAnchorInfoTag)

                local BuffCountColourPicker = CreateColourPicker("Colour", Buffs.Count.Colour, unit, "Buffs", "Count", nil, "Colour")
                BuffCountColourPicker:SetCallback("OnEnter", function()
                    local Desc = "Changes the colour of the buff count / stacks."
                    GameTooltip:SetOwner(BuffCountColourPicker.frame, "ANCHOR_TOPLEFT")
                    GameTooltip:SetText(Desc, 1, 1, 1, 1, false)
                    GameTooltip:Show()
                end)
                BuffCountColourPicker:SetCallback("OnLeave", function() GameTooltip:Hide() end)
                BuffCountColourPicker:SetRelativeWidth(0.33)
                BuffsCountContainer:AddChild(BuffCountColourPicker)

                local BuffCountAnchorFrom = CreateDropdown("Anchor From", Buffs.Count.AnchorFrom, unit, "Buffs", "Count", nil, "AnchorFrom")
                BuffCountAnchorFrom:SetRelativeWidth(0.33)
                BuffsCountContainer:AddChild(BuffCountAnchorFrom)

                local BuffCountAnchorTo = CreateDropdown("Anchor To", Buffs.Count.AnchorTo, unit, "Buffs", "Count", nil, "AnchorTo")
                BuffCountAnchorTo:SetRelativeWidth(0.33)
                BuffsCountContainer:AddChild(BuffCountAnchorTo)

                local BuffCountOffsetXSlider = CreateSlider("Offset X", Buffs.Count.OffsetX, unit, "Buffs", "Count", nil, "OffsetX")
                BuffCountOffsetXSlider:SetRelativeWidth(0.33)
                BuffsCountContainer:AddChild(BuffCountOffsetXSlider)

                local BuffCountOffsetYSlider = CreateSlider("Offset Y", Buffs.Count.OffsetY, unit, "Buffs", "Count", nil, "OffsetY")
                BuffCountOffsetYSlider:SetRelativeWidth(0.33)
                BuffsCountContainer:AddChild(BuffCountOffsetYSlider)

                local BuffCountSizeSlider = CreateSlider("Size", Buffs.Count.FontSize, unit, "Buffs", "Count", nil, "FontSize")
                BuffCountSizeSlider:SetRelativeWidth(0.33)
                BuffsCountContainer:AddChild(BuffCountSizeSlider)

                BuffsPositionContainer:DoLayout()
                BuffsLayoutContainer:DoLayout()
                BuffsCountContainer:DoLayout()

                if not Buffs.Enabled then
                    for _, child in ipairs(GUIContainer.children) do
                        if child ~= BuffsEnabledToggle then
                            DeepDisable(child, true)
                        end
                    end
                end
            end

            local function DrawDebuffsContainer(GUIContainer)
               local DebuffsEnabledToggle = CreateToggle("Enable", Debuffs.Enabled, unit, "Debuffs", nil, "Enabled")
                GUIContainer:AddChild(DebuffsEnabledToggle)

                local DebuffsPositionContainer = AG:Create("InlineGroup")
                DebuffsPositionContainer:SetTitle("Position")
                DebuffsPositionContainer:SetLayout("Flow")
                DebuffsPositionContainer:SetFullWidth(true)
                GUIContainer:AddChild(DebuffsPositionContainer)

                local DebuffsAnchorInfoTag = CreateInfoTag("|cFF8080FFPosition|r / |cFF8080FFAnchors|r are relative to the " .. UUF:TitleCase(unit) .. " Frame.")
                DebuffsPositionContainer:AddChild(DebuffsAnchorInfoTag)

                local DebuffsAnchorFromDropdown = CreateDropdown("Anchor From", Debuffs.AnchorFrom, unit, "Debuffs", nil, nil, "AnchorFrom")
                DebuffsPositionContainer:AddChild(DebuffsAnchorFromDropdown)

                local DebuffsAnchorToDropdown = CreateDropdown("Anchor To", Debuffs.AnchorTo, unit, "Debuffs", nil, nil, "AnchorTo")
                DebuffsPositionContainer:AddChild(DebuffsAnchorToDropdown)

                local DebuffsOffsetXSlider = CreateSlider("Offset X", Debuffs.OffsetX, unit, "Debuffs", nil, nil, "OffsetX")
                DebuffsPositionContainer:AddChild(DebuffsOffsetXSlider)

                local DebuffsOffsetYSlider = CreateSlider("Offset Y", Debuffs.OffsetY, unit, "Debuffs", nil, nil, "OffsetY")
                DebuffsPositionContainer:AddChild(DebuffsOffsetYSlider)

                local DebuffsSizeSlider = CreateSlider("Size", Debuffs.Size, unit, "Debuffs", nil, nil, "Size")
                DebuffsPositionContainer:AddChild(DebuffsSizeSlider)

                local DebuffsSpacingSlider = CreateSlider("Spacing", Debuffs.Spacing, unit, "Debuffs", nil, nil, "Spacing")
                DebuffsPositionContainer:AddChild(DebuffsSpacingSlider)

                local DebuffsLayoutContainer = AG:Create("InlineGroup")
                DebuffsLayoutContainer:SetTitle("Layout")
                DebuffsLayoutContainer:SetLayout("Flow")
                DebuffsLayoutContainer:SetFullWidth(true)
                GUIContainer:AddChild(DebuffsLayoutContainer)

                local DebuffsNumSlider = CreateSlider("Number of Debuffs", Debuffs.Num, unit, "Debuffs", nil, nil, "Num")
                DebuffsLayoutContainer:AddChild(DebuffsNumSlider)

                local DebuffsWrapSlider = CreateSlider("Wrap After", Debuffs.Wrap, unit, "Debuffs", nil, nil, "Wrap")
                DebuffsLayoutContainer:AddChild(DebuffsWrapSlider)

                local DebuffsGrowthDropdown = CreateDropdown("Growth Direction", Debuffs.Growth, unit, "Debuffs", nil, nil, "Growth")
                DebuffsLayoutContainer:AddChild(DebuffsGrowthDropdown)

                local DebuffsWrapDirectionDropdown = CreateDropdown("Wrap Direction", Debuffs.WrapDirection, unit, "Debuffs", nil, nil, "WrapDirection")
                DebuffsLayoutContainer:AddChild(DebuffsWrapDirectionDropdown)

                local DebuffsCountContainer = AG:Create("InlineGroup")
                DebuffsCountContainer:SetTitle("Count / Stacks")
                DebuffsCountContainer:SetLayout("Flow")
                DebuffsCountContainer:SetFullWidth(true)
                GUIContainer:AddChild(DebuffsCountContainer)

                local DebuffsCountAnchorInfoTag = CreateInfoTag("|cFF8080FFPosition|r / |cFF8080FFAnchors|r are relative to the Aura Frame.")
                DebuffsCountContainer:AddChild(DebuffsCountAnchorInfoTag)

                local DebuffCountColourPicker = CreateColourPicker("Colour", Debuffs.Count.Colour, unit, "Debuffs", "Count", nil, "Colour")
                DebuffCountColourPicker:SetCallback("OnEnter", function()
                    local Desc = "Changes the colour of the debuff count / stacks."
                    GameTooltip:SetOwner(DebuffCountColourPicker.frame, "ANCHOR_TOPLEFT")
                    GameTooltip:SetText(Desc, 1, 1, 1, 1, false)
                    GameTooltip:Show()
                end)
                DebuffCountColourPicker:SetCallback("OnLeave", function() GameTooltip:Hide() end)
                DebuffCountColourPicker:SetRelativeWidth(0.33)
                DebuffsCountContainer:AddChild(DebuffCountColourPicker)

                local DebuffCountAnchorFrom = CreateDropdown("Anchor From", Debuffs.Count.AnchorFrom, unit, "Debuffs", "Count", nil, "AnchorFrom")
                DebuffCountAnchorFrom:SetRelativeWidth(0.33)
                DebuffsCountContainer:AddChild(DebuffCountAnchorFrom)

                local DebuffCountAnchorTo = CreateDropdown("Anchor To", Debuffs.Count.AnchorTo, unit, "Debuffs", "Count", nil, "AnchorTo")
                DebuffCountAnchorTo:SetRelativeWidth(0.33)
                DebuffsCountContainer:AddChild(DebuffCountAnchorTo)

                local DebuffCountOffsetXSlider = CreateSlider("Offset X", Debuffs.Count.OffsetX, unit, "Debuffs", "Count", nil, "OffsetX")
                DebuffCountOffsetXSlider:SetRelativeWidth(0.33)
                DebuffsCountContainer:AddChild(DebuffCountOffsetXSlider)

                local DebuffCountOffsetYSlider = CreateSlider("Offset Y", Debuffs.Count.OffsetY, unit, "Debuffs", "Count", nil, "OffsetY")
                DebuffCountOffsetYSlider:SetRelativeWidth(0.33)
                DebuffsCountContainer:AddChild(DebuffCountOffsetYSlider)

                local DebuffCountSizeSlider = CreateSlider("Size", Debuffs.Count.FontSize, unit, "Debuffs", "Count", nil, "FontSize")
                DebuffCountSizeSlider:SetRelativeWidth(0.33)
                DebuffsCountContainer:AddChild(DebuffCountSizeSlider)

                DebuffsPositionContainer:DoLayout()
                DebuffsLayoutContainer:DoLayout()
                DebuffsCountContainer:DoLayout()

                if not Debuffs.Enabled then
                    for _, child in ipairs(GUIContainer.children) do
                        if child ~= DebuffsEnabledToggle then
                            DeepDisable(child, true)
                        end
                    end
                end

            end

            local function DrawIndicatorsContainer(GUIContainer)
                local RaidMarkerContainer = AG:Create("InlineGroup")
                RaidMarkerContainer:SetTitle("Raid Marker")
                RaidMarkerContainer:SetLayout("Flow")
                RaidMarkerContainer:SetFullWidth(true)
                GUIContainer:AddChild(RaidMarkerContainer)

                local RaidMarkerEnabledToggle = CreateToggle("Enabled", RaidMarker.Enabled, unit, "Indicators", "RaidMarker", "Enabled")
                RaidMarkerEnabledToggle:SetRelativeWidth(1)
                RaidMarkerContainer:AddChild(RaidMarkerEnabledToggle)

                local RaidMarkerAnchorFrom = CreateDropdown("Anchor From", RaidMarker.AnchorFrom, unit, "Indicators", "RaidMarker", nil, "AnchorFrom")
                RaidMarkerContainer:AddChild(RaidMarkerAnchorFrom)

                local RaidMarkerAnchorTo = CreateDropdown("Anchor To", RaidMarker.AnchorTo, unit, "Indicators", "RaidMarker", nil, "AnchorTo")
                RaidMarkerContainer:AddChild(RaidMarkerAnchorTo)

                local RaidMarkerSizeSlider = CreateSlider("Size", RaidMarker.Size, unit, "Indicators", "RaidMarker", nil, "Size")
                RaidMarkerSizeSlider:SetRelativeWidth(0.25)
                RaidMarkerContainer:AddChild(RaidMarkerSizeSlider)

                local RaidMarkerOffsetXSlider = CreateSlider("Offset X", RaidMarker.OffsetX, unit, "Indicators", "RaidMarker", nil, "OffsetX")
                RaidMarkerOffsetXSlider:SetRelativeWidth(0.25)
                RaidMarkerContainer:AddChild(RaidMarkerOffsetXSlider)

                local RaidMarkerOffsetYSlider = CreateSlider("Offset Y", RaidMarker.OffsetY, unit, "Indicators", "RaidMarker", nil, "OffsetY")
                RaidMarkerOffsetYSlider:SetRelativeWidth(0.25)
                RaidMarkerContainer:AddChild(RaidMarkerOffsetYSlider)

                local RaidMarkerAutoSizeButton = AG:Create("Button")
                RaidMarkerAutoSizeButton:SetText("Auto Size")
                RaidMarkerAutoSizeButton:SetRelativeWidth(0.25)
                RaidMarkerAutoSizeButton:SetCallback("OnClick", function()
                    local unitFrame = unitToUnitFrame[unit]
                    local autoScale = math.floor(UUF.db.profile[unit].Frame.Height * 0.75)
                    UUF.db.profile[unit].Indicators.RaidMarker.Size = autoScale
                    RaidMarkerSizeSlider:SetValue(autoScale)
                    UUF:UpdateFrame(unitFrame, unit)
                end)
                RaidMarkerAutoSizeButton:SetCallback("OnEnter", function()
                    local Desc = "Size to |cFFFFCC0075%|r of the "..UUF:TitleCase(unit).."'s Height."
                    GameTooltip:SetOwner(RaidMarkerAutoSizeButton.frame, "ANCHOR_TOPLEFT")
                    GameTooltip:SetText(Desc, 1, 1, 1, 1, false)
                    GameTooltip:Show()
                end)
                RaidMarkerAutoSizeButton:SetCallback("OnLeave", function()
                    GameTooltip:Hide()
                end)
                RaidMarkerContainer:AddChild(RaidMarkerAutoSizeButton)
                RaidMarkerContainer:DoLayout()


                local MouseoverHighlightContainer = AG:Create("InlineGroup")
                MouseoverHighlightContainer:SetTitle("Mouseover Highlight")
                MouseoverHighlightContainer:SetLayout("Flow")
                MouseoverHighlightContainer:SetFullWidth(true)
                GUIContainer:AddChild(MouseoverHighlightContainer)

                local MouseoverHighlightEnabledToggle = CreateToggle("Enabled", Indicators.MouseoverHighlight.Enabled, unit, "Indicators", "MouseoverHighlight", "Enabled")
                MouseoverHighlightEnabledToggle:SetRelativeWidth(0.3)
                MouseoverHighlightContainer:AddChild(MouseoverHighlightEnabledToggle)

                local MouseoverHighlightInfoTag = CreateInfoTag("|cFF8080FFAlpha|r can be adjusted via the |cFF8080FFHighlight Colour|r Colour Picker.")
                MouseoverHighlightInfoTag:SetRelativeWidth(0.7)
                MouseoverHighlightInfoTag:SetJustifyH("RIGHT")
                MouseoverHighlightContainer:AddChild(MouseoverHighlightInfoTag)

                local MouseoverHighlightColourPicker = CreateColourPicker("Highlight Colour", Indicators.MouseoverHighlight.Colour, unit, "Indicators", "MouseoverHighlight", nil, "Colour")
                MouseoverHighlightColourPicker:SetRelativeWidth(0.5)
                MouseoverHighlightContainer:AddChild(MouseoverHighlightColourPicker)

                local MouseoverHighlightTypeDropdown = CreateDropdown("Highlight Type", Indicators.MouseoverHighlight.Type, unit, "Indicators", "MouseoverHighlight", nil, "Type")
                MouseoverHighlightTypeDropdown:SetRelativeWidth(0.5)
                MouseoverHighlightContainer:AddChild(MouseoverHighlightTypeDropdown)
                MouseoverHighlightContainer:DoLayout()

                if not RaidMarker.Enabled then
                    for _, child in ipairs(GUIContainer.children) do
                        if child ~= RaidMarkerEnabledToggle then
                            DeepDisable(child, true)
                        end
                    end
                end

                if not MouseoverHighlight.Enabled then
                    for _, child in ipairs(GUIContainer.children) do
                        if child ~= MouseoverHighlightEnabledToggle then
                            DeepDisable(child, true)
                        end
                    end
                end

                if Indicators.Leader then
                    local Leader = Indicators.Leader
                    local LeaderContainer = AG:Create("InlineGroup")
                    LeaderContainer:SetTitle("Leader / Assistant")
                    LeaderContainer:SetLayout("Flow")
                    LeaderContainer:SetFullWidth(true)
                    GUIContainer:AddChild(LeaderContainer)

                    local LeaderAssistantDesc = AG:Create("Label")
                    LeaderAssistantDesc:SetText(UUF.InfoButton .. "|cFF8080FFLeader|r / |cFF8080FFAssistant|r Indicators share the same position & size settings.")
                    LeaderAssistantDesc:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
                    LeaderAssistantDesc:SetFullWidth(true)
                    LeaderAssistantDesc:SetJustifyH("CENTER")
                    LeaderContainer:AddChild(LeaderAssistantDesc)

                    local LeaderEnabledToggle = CreateToggle("Enabled", Leader.Enabled, unit, "Indicators", "Leader", "Enabled")
                    LeaderEnabledToggle:SetRelativeWidth(1)
                    LeaderContainer:AddChild(LeaderEnabledToggle)

                    local LeaderAnchorFrom = CreateDropdown("Anchor From", Leader.AnchorFrom, unit, "Indicators", "Leader", nil, "AnchorFrom")
                    LeaderContainer:AddChild(LeaderAnchorFrom)

                    local LeaderAnchorTo = CreateDropdown("Anchor To", Leader.AnchorTo, unit, "Indicators", "Leader", nil, "AnchorTo")
                    LeaderContainer:AddChild(LeaderAnchorTo)

                    local LeaderSizeSlider = CreateSlider("Size", Leader.Size, unit, "Indicators", "Leader", nil, "Size")
                    LeaderSizeSlider:SetRelativeWidth(0.25)
                    LeaderContainer:AddChild(LeaderSizeSlider)

                    local LeaderOffsetXSlider = CreateSlider("Offset X", Leader.OffsetX, unit, "Indicators", "Leader", nil, "OffsetX")
                    LeaderOffsetXSlider:SetRelativeWidth(0.25)
                    LeaderContainer:AddChild(LeaderOffsetXSlider)

                    local LeaderOffsetYSlider = CreateSlider("Offset Y", Leader.OffsetY, unit, "Indicators", "Leader", nil, "OffsetY")
                    LeaderOffsetYSlider:SetRelativeWidth(0.25)
                    LeaderContainer:AddChild(LeaderOffsetYSlider)

                    local LeaderAutoSizeButton = AG:Create("Button")
                    LeaderAutoSizeButton:SetText("Auto Size")
                    LeaderAutoSizeButton:SetRelativeWidth(0.25)
                    LeaderAutoSizeButton:SetCallback("OnClick", function()
                        local unitFrame = unitToUnitFrame[unit]
                        local autoScale = math.floor(UUF.db.profile[unit].Frame.Height * 0.75)
                        UUF.db.profile[unit].Indicators.Leader.Size = autoScale
                        LeaderSizeSlider:SetValue(autoScale)
                        UUF:UpdateFrame(unitFrame, unit)
                    end)
                    LeaderAutoSizeButton:SetCallback("OnEnter", function()
                        local Desc = "Size to |cFFFFCC0075%|r of the "..UUF:TitleCase(unit).."'s Height."
                        GameTooltip:SetOwner(LeaderAutoSizeButton.frame, "ANCHOR_TOPLEFT")
                        GameTooltip:SetText(Desc, 1, 1, 1, 1, false)
                        GameTooltip:Show()
                    end)
                    LeaderAutoSizeButton:SetCallback("OnLeave", function()
                        GameTooltip:Hide()
                    end)
                    LeaderContainer:AddChild(LeaderAutoSizeButton)
                    LeaderContainer:DoLayout()

                    if not Leader.Enabled then
                        for _, child in ipairs(LeaderContainer.children) do
                            if child ~= LeaderEnabledToggle then
                                DeepDisable(child, true)
                            end
                        end
                    end
                end

                if isPlayer then
                    local Status = Indicators.Status
                    local StatusContainer = AG:Create("InlineGroup")
                    StatusContainer:SetTitle("Combat / Resting")
                    StatusContainer:SetLayout("Flow")
                    StatusContainer:SetFullWidth(true)
                    GUIContainer:AddChild(StatusContainer)

                    local StatusDesc = AG:Create("Label")
                    StatusDesc:SetText(UUF.InfoButton .. "|cFF8080FFCombat|r / |cFF8080FFResting|r Indicators share the same position & size settings.")
                    StatusDesc:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
                    StatusDesc:SetFullWidth(true)
                    StatusDesc:SetJustifyH("CENTER")
                    StatusContainer:AddChild(StatusDesc)

                    local CombatEnabledToggle = AG:Create("CheckBox")

                    local RestingTextureDropdown = CreateDropdown("Resting Texture", Status.RestingTexture, unit, "Indicators", "Status", nil, "RestingTexture")
                    RestingTextureDropdown:SetRelativeWidth(0.5)

                    local CombatTextureDropdown = CreateDropdown("Combat Texture", Status.CombatTexture, unit, "Indicators", "Status", nil, "CombatTexture")
                    CombatTextureDropdown:SetRelativeWidth(0.5)

                    local RestingEnabledToggle = AG:Create("CheckBox")
                    RestingEnabledToggle:SetLabel("Enable Resting Indicator")
                    RestingEnabledToggle:SetValue(Status.Resting)
                    RestingEnabledToggle:SetRelativeWidth(0.5)
                    RestingEnabledToggle:SetCallback("OnValueChanged", function(_, _, value)
                        Status.Resting = value
                        UUF:UpdateFrame(unitToUnitFrame[unit], unit)
                        for _, child in ipairs(StatusContainer.children) do
                            if child ~= CombatEnabledToggle and child ~= RestingEnabledToggle then
                                DeepDisable(child, not (Status.Combat or Status.Resting))
                            end
                        end
                        DeepDisable(RestingTextureDropdown, not Status.Resting)
                        DeepDisable(CombatTextureDropdown, not Status.Combat)
                    end)

                    CombatEnabledToggle:SetLabel("Enable Combat Indicator")
                    CombatEnabledToggle:SetValue(Status.Combat)
                    CombatEnabledToggle:SetRelativeWidth(0.5)
                    CombatEnabledToggle:SetCallback("OnValueChanged", function(_, _, value)
                        Status.Combat = value
                        UUF:UpdateFrame(unitToUnitFrame[unit], unit)
                        for _, child in ipairs(StatusContainer.children) do
                            if child ~= CombatEnabledToggle and child ~= RestingEnabledToggle then
                                DeepDisable(child, not (Status.Combat or Status.Resting))
                            end
                        end
                        DeepDisable(CombatTextureDropdown, not Status.Combat)
                        DeepDisable(RestingTextureDropdown, not Status.Resting)
                    end)


                    StatusContainer:AddChild(CombatEnabledToggle)
                    StatusContainer:AddChild(RestingEnabledToggle)
                    StatusContainer:AddChild(CombatTextureDropdown)
                    StatusContainer:AddChild(RestingTextureDropdown)

                    local StatusAnchorFrom = CreateDropdown("Anchor From", Status.AnchorFrom, unit, "Indicators", "Status", nil, "AnchorFrom")
                    StatusContainer:AddChild(StatusAnchorFrom)

                    local StatusAnchorTo = CreateDropdown("Anchor To", Status.AnchorTo, unit, "Indicators", "Status", nil, "AnchorTo")
                    StatusContainer:AddChild(StatusAnchorTo)

                    local StatusSizeSlider = CreateSlider("Size", Status.Size, unit, "Indicators", "Status", nil, "Size")
                    StatusSizeSlider:SetRelativeWidth(0.25)
                    StatusContainer:AddChild(StatusSizeSlider)

                    local StatusOffsetXSlider = CreateSlider("Offset X", Status.OffsetX, unit, "Indicators", "Status", nil, "OffsetX")
                    StatusOffsetXSlider:SetRelativeWidth(0.25)
                    StatusContainer:AddChild(StatusOffsetXSlider)

                    local StatusOffsetYSlider = CreateSlider("Offset Y", Status.OffsetY, unit, "Indicators", "Status", nil, "OffsetY")
                    StatusOffsetYSlider:SetRelativeWidth(0.25)
                    StatusContainer:AddChild(StatusOffsetYSlider)

                    local StatusAutoSizeButton = AG:Create("Button")
                    StatusAutoSizeButton:SetText("Auto Size")
                    StatusAutoSizeButton:SetRelativeWidth(0.25)
                    StatusAutoSizeButton:SetCallback("OnClick", function()
                        local unitFrame = unitToUnitFrame[unit]
                        local autoScale = math.floor(UUF.db.profile[unit].Frame.Height * 0.75)
                        UUF.db.profile[unit].Indicators.Status.Size = autoScale
                        StatusSizeSlider:SetValue(autoScale)
                        UUF:UpdateFrame(unitFrame, unit)
                    end)
                    StatusAutoSizeButton:SetCallback("OnEnter", function()
                        local Desc = "Size to |cFFFFCC0075%|r of the "..UUF:TitleCase(unit).."'s Height."
                        GameTooltip:SetOwner(StatusAutoSizeButton.frame, "ANCHOR_TOPLEFT")
                        GameTooltip:SetText(Desc, 1, 1, 1, 1, false)
                        GameTooltip:Show()
                    end)
                    StatusAutoSizeButton:SetCallback("OnLeave", function()
                        GameTooltip:Hide()
                    end)
                    StatusContainer:AddChild(StatusAutoSizeButton)

                    for _, child in ipairs(StatusContainer.children) do
                        if child ~= CombatEnabledToggle and child ~= RestingEnabledToggle then
                            DeepDisable(child, not (Status.Combat or Status.Resting))
                        end
                    end
                    DeepDisable(RestingTextureDropdown, not Status.Resting)
                    DeepDisable(CombatTextureDropdown, not Status.Combat)
                    StatusContainer:DoLayout()
                end

                if isTarget then
                    local Quest = Indicators.Quest
                    local QuestContainer = AG:Create("InlineGroup")
                    QuestContainer:SetTitle("Quest")
                    QuestContainer:SetLayout("Flow")
                    QuestContainer:SetFullWidth(true)
                    GUIContainer:AddChild(QuestContainer)

                    local QuestEnabledToggle = CreateToggle("Enabled", Quest.Enabled, unit, "Indicators", "Quest", "Enabled")
                    QuestEnabledToggle:SetRelativeWidth(1)
                    QuestContainer:AddChild(QuestEnabledToggle)

                    local QuestAnchorFrom = CreateDropdown("Anchor From", Quest.AnchorFrom, unit, "Indicators", "Quest", nil, "AnchorFrom")
                    QuestContainer:AddChild(QuestAnchorFrom)
                    local QuestAnchorTo = CreateDropdown("Anchor To", Quest.AnchorTo, unit, "Indicators", "Quest", nil, "AnchorTo")
                    QuestContainer:AddChild(QuestAnchorTo)
                    local QuestSizeSlider = CreateSlider("Size", Quest.Size, unit, "Indicators", "Quest", nil, "Size")
                    QuestSizeSlider:SetRelativeWidth(0.25)
                    QuestContainer:AddChild(QuestSizeSlider)
                    local QuestOffsetXSlider = CreateSlider("Offset X", Quest.OffsetX, unit, "Indicators", "Quest", nil, "OffsetX")
                    QuestOffsetXSlider:SetRelativeWidth(0.25)
                    QuestContainer:AddChild(QuestOffsetXSlider)
                    local QuestOffsetYSlider = CreateSlider("Offset Y", Quest.OffsetY, unit, "Indicators", "Quest", nil, "OffsetY")
                    QuestOffsetYSlider:SetRelativeWidth(0.25)
                    QuestContainer:AddChild(QuestOffsetYSlider)
                    local QuestAutoSizeButton = AG:Create("Button")
                    QuestAutoSizeButton:SetText("Auto Size")
                    QuestAutoSizeButton:SetRelativeWidth(0.25)
                    QuestAutoSizeButton:SetCallback("OnClick", function()
                        local unitFrame = unitToUnitFrame[unit]
                        local autoScale = math.floor(UUF.db.profile[unit].Frame.Height * 0.75)
                        UUF.db.profile[unit].Indicators.Quest.Size = autoScale
                        QuestSizeSlider:SetValue(autoScale)
                        UUF:UpdateFrame(unitFrame, unit)
                    end)
                    QuestAutoSizeButton:SetCallback("OnEnter", function()
                        local Desc = "Size to |cFFFFCC0075%|r of the "..UUF:TitleCase(unit).."'s Height."
                        GameTooltip:SetOwner(QuestAutoSizeButton.frame, "ANCHOR_TOPLEFT")
                        GameTooltip:SetText(Desc, 1, 1, 1, 1, false)
                        GameTooltip:Show()
                    end)
                    QuestAutoSizeButton:SetCallback("OnLeave", function()
                        GameTooltip:Hide()
                    end)
                    QuestContainer:AddChild(QuestAutoSizeButton)
                    QuestContainer:DoLayout()
                    if not Quest.Enabled then
                        for _, child in ipairs(QuestContainer.children) do
                            if child ~= QuestEnabledToggle then
                                DeepDisable(child, true)
                            end
                        end
                    end
                end

                if unit == "party" or unit == "raid" then
                    local RoleIcons = Indicators.RoleIcons

                    local RoleIconsContainer = AG:Create("InlineGroup")
                    RoleIconsContainer:SetTitle("Role Icons")
                    RoleIconsContainer:SetLayout("Flow")
                    RoleIconsContainer:SetFullWidth(true)
                    GUIContainer:AddChild(RoleIconsContainer)

                    local RoleIconsEnabledToggle = CreateToggle("Enabled", RoleIcons.Enabled, unit, "Indicators", "RoleIcons", "Enabled")
                    RoleIconsEnabledToggle:SetRelativeWidth(0.5)
                    RoleIconsContainer:AddChild(RoleIconsEnabledToggle)

                    local RoleIconsDropdown = CreateDropdown("Role Icons", RoleIcons.RoleTextures, unit, "Indicators", "RoleIcons", nil, "RoleTextures")
                    RoleIconsDropdown:SetRelativeWidth(0.5)
                    RoleIconsContainer:AddChild(RoleIconsDropdown)
                    local RoleIconsAnchorFrom = CreateDropdown("Anchor From", RoleIcons.AnchorFrom, unit, "Indicators", "RoleIcons", nil, "AnchorFrom")
                    RoleIconsContainer:AddChild(RoleIconsAnchorFrom)
                    local RoleIconsAnchorTo = CreateDropdown("Anchor To", RoleIcons.AnchorTo, unit, "Indicators", "RoleIcons", nil, "AnchorTo")
                    RoleIconsContainer:AddChild(RoleIconsAnchorTo)
                    local RoleIconsSizeSlider = CreateSlider("Size", RoleIcons.Size, unit, "Indicators", "RoleIcons", nil, "Size")
                    RoleIconsSizeSlider:SetRelativeWidth(0.33)
                    RoleIconsContainer:AddChild(RoleIconsSizeSlider)
                    local RoleIconsOffsetXSlider = CreateSlider("Offset X", RoleIcons.OffsetX, unit, "Indicators", "RoleIcons", nil, "OffsetX")
                    RoleIconsOffsetXSlider:SetRelativeWidth(0.33)
                    RoleIconsContainer:AddChild(RoleIconsOffsetXSlider)
                    local RoleIconsOffsetYSlider = CreateSlider("Offset Y", RoleIcons.OffsetY, unit, "Indicators", "RoleIcons", nil, "OffsetY")
                    RoleIconsOffsetYSlider:SetRelativeWidth(0.33)
                    RoleIconsContainer:AddChild(RoleIconsOffsetYSlider)
                    RoleIconsContainer:DoLayout()

                    local ReadyCheckContainer = AG:Create("InlineGroup")
                    ReadyCheckContainer:SetTitle("Ready Check")
                    ReadyCheckContainer:SetLayout("Flow")
                    ReadyCheckContainer:SetFullWidth(true)
                    GUIContainer:AddChild(ReadyCheckContainer)

                    local ReadyCheckEnabledToggle = CreateToggle("Enabled", Indicators.ReadyCheck.Enabled, unit, "Indicators", "ReadyCheck", "Enabled")
                    ReadyCheckEnabledToggle:SetRelativeWidth(0.5)
                    ReadyCheckContainer:AddChild(ReadyCheckEnabledToggle)
                    local ReadyCheckDropdown = CreateDropdown("Ready Check Textures", Indicators.ReadyCheck.ReadyCheckTextures, unit, "Indicators", "ReadyCheck", nil, "ReadyCheckTextures")
                    ReadyCheckDropdown:SetRelativeWidth(0.5)
                    ReadyCheckContainer:AddChild(ReadyCheckDropdown)
                    local ReadyCheckAnchorFrom = CreateDropdown("Anchor From", Indicators.ReadyCheck.AnchorFrom, unit, "Indicators", "ReadyCheck", nil, "AnchorFrom")
                    ReadyCheckContainer:AddChild(ReadyCheckAnchorFrom)
                    local ReadyCheckAnchorTo = CreateDropdown("Anchor To", Indicators.ReadyCheck.AnchorTo, unit, "Indicators", "ReadyCheck", nil, "AnchorTo")
                    ReadyCheckContainer:AddChild(ReadyCheckAnchorTo)
                    local ReadyCheckSizeSlider = CreateSlider("Size", Indicators.ReadyCheck.Size, unit, "Indicators", "ReadyCheck", nil, "Size")
                    ReadyCheckSizeSlider:SetRelativeWidth(0.33)
                    ReadyCheckContainer:AddChild(ReadyCheckSizeSlider)
                    local ReadyCheckOffsetXSlider = CreateSlider("Offset X", Indicators.ReadyCheck.OffsetX, unit, "Indicators", "ReadyCheck", nil, "OffsetX")
                    ReadyCheckOffsetXSlider:SetRelativeWidth(0.33)
                    ReadyCheckContainer:AddChild(ReadyCheckOffsetXSlider)
                    local ReadyCheckOffsetYSlider = CreateSlider("Offset Y", Indicators.ReadyCheck.OffsetY, unit, "Indicators", "ReadyCheck", nil, "OffsetY")
                    ReadyCheckOffsetYSlider:SetRelativeWidth(0.33)
                    ReadyCheckContainer:AddChild(ReadyCheckOffsetYSlider)

                    ReadyCheckContainer:DoLayout()

                end

                if Indicators.TargetIndicator then
                    local TargetIndicator = Indicators.TargetIndicator
                    local TargetIndicatorContainer = AG:Create("InlineGroup")
                    TargetIndicatorContainer:SetTitle("Target Indicator")
                    TargetIndicatorContainer:SetLayout("Flow")
                    TargetIndicatorContainer:SetFullWidth(true)
                    GUIContainer:AddChild(TargetIndicatorContainer)

                    local TargetIndicatorInfoTag = CreateInfoTag("|cFF8080FFTarget Indicator|r shows a glowing border around the frame when it is your current target.")
                    TargetIndicatorInfoTag:SetFullWidth(true)
                    TargetIndicatorContainer:AddChild(TargetIndicatorInfoTag)

                    local TargetIndicatorEnabledToggle = CreateToggle("Enabled", TargetIndicator.Enabled, unit, "Indicators", "TargetIndicator", "Enabled")
                    TargetIndicatorEnabledToggle:SetRelativeWidth(0.5)
                    TargetIndicatorContainer:AddChild(TargetIndicatorEnabledToggle)

                    local TargetIndicatorColourPicker = CreateColourPicker("Indicator Colour", TargetIndicator.Colour, unit, "Indicators", "TargetIndicator", nil, "Colour")
                    TargetIndicatorColourPicker:SetRelativeWidth(0.5)
                    TargetIndicatorContainer:AddChild(TargetIndicatorColourPicker)
                end
            end

            local function DrawPortraitContainer(GUIContainer)
                local PortraitEnabledToggle = CreateToggle("Enable", Portrait.Enabled, unit, "Portrait", nil, "Enabled")
                PortraitEnabledToggle:SetRelativeWidth(0.5)
                GUIContainer:AddChild(PortraitEnabledToggle)

                local PortraitStyleDropdown = CreateDropdown("Style", Portrait.Style, unit, "Portrait", nil, nil, "Style")
                PortraitStyleDropdown:SetRelativeWidth(0.5)
                GUIContainer:AddChild(PortraitStyleDropdown)

                local PortraitPositionContainer = AG:Create("InlineGroup")
                PortraitPositionContainer:SetTitle("Position")
                PortraitPositionContainer:SetLayout("Flow")
                PortraitPositionContainer:SetFullWidth(true)
                GUIContainer:AddChild(PortraitPositionContainer)

                local PortraitAnchorInfoTag = CreateInfoTag("|cFF8080FFPosition|r / |cFF8080FFAnchors|r are relative to the " .. UUF:TitleCase(unit) .. " Frame.")
                PortraitPositionContainer:AddChild(PortraitAnchorInfoTag)

                local PortraitAnchorFromDropdown = CreateDropdown("Anchor From", Portrait.AnchorFrom, unit, "Portrait", nil, nil, "AnchorFrom")
                PortraitPositionContainer:AddChild(PortraitAnchorFromDropdown)

                local PortraitAnchorToDropdown = CreateDropdown("Anchor To", Portrait.AnchorTo, unit, "Portrait", nil, nil, "AnchorTo")
                PortraitPositionContainer:AddChild(PortraitAnchorToDropdown)

                local PortraitOffsetXSlider = CreateSlider("Offset X", Portrait.OffsetX, unit, "Portrait", nil, nil, "OffsetX")
                PortraitOffsetXSlider:SetRelativeWidth(0.25)
                PortraitPositionContainer:AddChild(PortraitOffsetXSlider)

                local PortraitOffsetYSlider = CreateSlider("Offset Y", Portrait.OffsetY, unit, "Portrait", nil, nil, "OffsetY")
                PortraitOffsetYSlider:SetRelativeWidth(0.25)
                PortraitPositionContainer:AddChild(PortraitOffsetYSlider)

                local PortraitSizeSlider = CreateSlider("Size", Portrait.Size, unit, "Portrait", nil, nil, "Size")
                PortraitSizeSlider:SetRelativeWidth(0.25)
                PortraitPositionContainer:AddChild(PortraitSizeSlider)

                local PortraitZoom = CreateSlider("Zoom", Portrait.Zoom, unit, "Portrait", nil, nil, "Zoom")
                PortraitZoom:SetSliderValues(0, 1, 0.01)
                PortraitZoom:SetIsPercent(true)
                PortraitZoom:SetRelativeWidth(0.25)
                PortraitPositionContainer:AddChild(PortraitZoom)
                PortraitPositionContainer:DoLayout()

                if not Portrait.Enabled then
                    for _, child in ipairs(GUIContainer.children) do
                        if child ~= PortraitEnabledToggle then
                            DeepDisable(child, true)
                        end
                    end
                end
            end

            local function SelectedGroup(GUIContainer, _, subGroup)
                GUIContainer:ReleaseChildren()
                if subGroup == "Frame" then
                    DrawFrameContainer(GUIContainer)
                elseif subGroup == "HealPrediction" then
                    DrawHealPredictionContainer(GUIContainer)
                elseif subGroup == "PowerBar" then
                    DrawPowerBarContainer(GUIContainer)
                elseif subGroup == "CastBar" then
                    DrawCastBarContainer(GUIContainer)
                elseif subGroup == "Tags" then
                    DrawTagsContainer(GUIContainer)
                elseif subGroup == "Buffs" then
                    DrawBuffsContainer(GUIContainer)
                elseif subGroup == "Debuffs" then
                    DrawDebuffsContainer(GUIContainer)
                elseif subGroup == "Portrait" then
                    DrawPortraitContainer(GUIContainer)
                elseif subGroup == "Indicators" then
                    DrawIndicatorsContainer(GUIContainer)
                end
                if not UUF.db.profile[unit].Enabled then
                    for i, child in ipairs(ScrollFrame.children) do
                        if i > 1 then
                            DeepDisable(child, true)
                        end
                    end
                end
                ScrollFrame:DoLayout()
            end

            local GUIContainerTabGroup = AG:Create("TabGroup")
            GUIContainerTabGroup:SetLayout("Flow")
            local function CreateUnitTabs(unit, tabGroup)
                local DefaultDB = (UUF and UUF.db and UUF.db.profile and UUF.db.profile[unit]) or (UUF and UUF.Defaults and UUF.Defaults.profile and UUF.Defaults.profile[unit]) or {}
                local tabLabels = {
                    Frame = "Frame",
                    HealPrediction = "Health Prediction",
                    PowerBar = "Power Bar",
                    CastBar = "Cast Bar",
                    Tags = "Tags",
                    Buffs = "Buffs",
                    Debuffs = "Debuffs",
                    Portrait = "Portrait",
                    Indicators = "Indicators",
                }
                local tabOrder = { "Frame", "HealPrediction", "PowerBar", "CastBar", "Tags", "Buffs", "Debuffs", "Portrait", "Indicators" }
                local unitTabs = {}
                for _, key in ipairs(tabOrder) do
                    if type(DefaultDB[key]) == "table" then
                        table.insert(unitTabs, { text = tabLabels[key], value = key })
                    end
                end
                tabGroup:SetTabs(unitTabs)
                return unitTabs
            end
            CreateUnitTabs(unit, GUIContainerTabGroup)
            GUIContainerTabGroup:SetCallback("OnGroupSelected", SelectedGroup)
            GUIContainerTabGroup:SelectTab("Frame")
            GUIContainerTabGroup:SetFullWidth(true)
            ScrollFrame:AddChild(GUIContainerTabGroup)
            if not UUF.db.profile[unit] or UUF.db.profile[unit].Enabled then return end
            for i, child in ipairs(ScrollFrame.children) do
                if i > 1 then
                    DeepDisable(child, true)
                end
            end
            ScrollFrame:DoLayout()
        end

        local function DrawTagsContainer(GUIContainer)
            local ScrollFrame = AG:Create("ScrollFrame")
            ScrollFrame:SetLayout("Flow")
            ScrollFrame:SetFullWidth(true)
            ScrollFrame:SetFullHeight(true)
            GUIContainer:AddChild(ScrollFrame)

            local function DrawTagContainer(GUIContainer, tagGroup)
                local TagsList = UUF:GetTagsForGroup(tagGroup)
                for Tag, Desc in pairs(TagsList) do
                    local TagDesc = AG:Create("Heading")
                    TagDesc:SetText(Desc)
                    TagDesc:SetFullWidth(true)
                    GUIContainer:AddChild(TagDesc)

                    local TagValue = AG:Create("EditBox")
                    TagValue:SetText("[" .. Tag .. "]")
                    TagValue:SetCallback("OnTextChanged", function(widget, event, value)
                        TagValue:ClearFocus()
                        TagValue:SetText("[" .. Tag .. "]")
                    end)
                    TagValue:SetRelativeWidth(1)
                    GUIContainer:AddChild(TagValue)

                end
            end

            local function SelectedGroup(GUIContainer, _, subGroup)
                GUIContainer:ReleaseChildren()
                if subGroup == "Health" then
                    DrawTagContainer(GUIContainer, "Health")
                elseif subGroup == "Name" then
                    DrawTagContainer(GUIContainer, "Name")
                elseif subGroup == "Power" then
                    DrawTagContainer(GUIContainer, "Power")
                elseif subGroup == "Misc" then
                    DrawTagContainer(GUIContainer, "Misc")
                end
                ScrollFrame:DoLayout()
            end

            local GUIContainerTabGroup = AG:Create("TabGroup")
            GUIContainerTabGroup:SetLayout("Flow")
            GUIContainerTabGroup:SetTabs({
                { text = "Health", value = "Health" },
                { text = "Name", value = "Name" },
                { text = "Power", value = "Power" },
                { text = "Miscellaneous", value = "Misc" },
            })
            GUIContainerTabGroup:SetCallback("OnGroupSelected", SelectedGroup)
            GUIContainerTabGroup:SelectTab("Health")
            GUIContainerTabGroup:SetFullWidth(true)
            ScrollFrame:AddChild(GUIContainerTabGroup)
            ScrollFrame:DoLayout()
        end

        local function DrawProfilesContainer(GUIContainer)
            local ScrollFrame = AG:Create("ScrollFrame")
            ScrollFrame:SetLayout("Flow")
            ScrollFrame:SetFullWidth(true)
            ScrollFrame:SetFullHeight(true)
            GUIContainer:AddChild(ScrollFrame)

            local ProfileContainer = AG:Create("InlineGroup")
            ProfileContainer:SetTitle("Profiles")
            ProfileContainer:SetLayout("Flow")
            ProfileContainer:SetFullWidth(true)
            ScrollFrame:AddChild(ProfileContainer)

            local ActiveProfileHeading = AG:Create("Heading")
            ActiveProfileHeading:SetText("Active Profile: |cFFFFFFFF" .. UUF.db:GetCurrentProfile() .. "|r")
            ActiveProfileHeading:SetFullWidth(true)
            ProfileContainer:AddChild(ActiveProfileHeading)

            local profileKeys = {}
            local function RefreshProfiles()
                wipe(profileKeys)
                local tmp = {}
                for _, name in ipairs(UUF.db:GetProfiles(tmp, true)) do
                    profileKeys[name] = name
                end
                SelectProfileDropdown:SetList(profileKeys)
                CopyFromProfileDropdown:SetList(profileKeys)
                DeleteProfileDropdown:SetList(profileKeys)

                SelectProfileDropdown:SetValue(UUF.db:GetCurrentProfile())
                CopyFromProfileDropdown:SetValue(nil)
                DeleteProfileDropdown:SetValue(nil)

                ActiveProfileHeading:SetText("Active Profile: |cFFFFFFFF" .. UUF.db:GetCurrentProfile() .. "|r")
            end

            UUFG.RefreshProfiles = RefreshProfiles

            SelectProfileDropdown = AG:Create("Dropdown")
            SelectProfileDropdown:SetLabel("Select...")
            SelectProfileDropdown:SetRelativeWidth(0.25)
            SelectProfileDropdown:SetCallback("OnValueChanged", function(_, _, value)
                UUF.db:SetProfile(value)
                UIParent:SetScale(UUF.db.profile.General.UIScale or 1)
                for unitFrameName, unit in pairs(UnitFrames) do
                    UUF:UpdateFrame(unitFrameName, unit)
                end
                RefreshProfiles()
            end)
            ProfileContainer:AddChild(SelectProfileDropdown)

            CopyFromProfileDropdown = AG:Create("Dropdown")
            CopyFromProfileDropdown:SetLabel("Copy From...")
            CopyFromProfileDropdown:SetRelativeWidth(0.25)
            CopyFromProfileDropdown:SetCallback("OnValueChanged", function(_, _, value)
                UUF:CreatePrompt("Copy Profile", "Are you sure you want to copy from |cFF8080FF" .. value .. "|r?\nThis will |cFFFF4040overwrite|r your current profile settings.", function()
                    UUF.db:CopyProfile(value)
                    UIParent:SetScale(UUF.db.profile.General.UIScale or 1)
                    for unitFrameName, unit in pairs(UnitFrames) do
                        UUF:UpdateFrame(unitFrameName, unit)
                    end
                    RefreshProfiles()
                end)
            end)
            ProfileContainer:AddChild(CopyFromProfileDropdown)

            DeleteProfileDropdown = AG:Create("Dropdown")
            DeleteProfileDropdown:SetLabel("Delete...")
            DeleteProfileDropdown:SetRelativeWidth(0.25)
            DeleteProfileDropdown:SetCallback("OnValueChanged", function(_, _, value)
                if value ~= UUF.db:GetCurrentProfile() then
                    UUF:CreatePrompt("Delete Profile", "Are you sure you want to delete |cFF8080FF" .. value .. "|r?", function()
                        UUF.db:DeleteProfile(value)
                        RefreshProfiles()
                    end)
                end
            end)
            ProfileContainer:AddChild(DeleteProfileDropdown)

            local ResetProfileButton = AG:Create("Button")
            ResetProfileButton:SetText("Reset Current Profile")
            ResetProfileButton:SetRelativeWidth(0.25)
            ResetProfileButton:SetCallback("OnClick", function()
                UUF.db:ResetProfile()
                UUF:ResolveMedia()
                for unitFrameName, unit in pairs(UnitFrames) do
                    UUF:UpdateFrame(unitFrameName, unit)
                end
                UIParent:SetScale(UUF.db.profile.General.UIScale or 1)
                RefreshProfiles()
            end)
            ProfileContainer:AddChild(ResetProfileButton)

            local CreateProfileEditBox = AG:Create("EditBox")
            CreateProfileEditBox:SetLabel("Create Profile...")
            CreateProfileEditBox:SetText("")
            CreateProfileEditBox:SetRelativeWidth(0.5)
            CreateProfileEditBox:DisableButton(true)
            CreateProfileEditBox:SetCallback("OnEnterPressed", function() CreateProfileEditBox:ClearFocus() end)
            ProfileContainer:AddChild(CreateProfileEditBox)

            local CreateProfileButton = AG:Create("Button")
            CreateProfileButton:SetText("Create Profile")
            CreateProfileButton:SetRelativeWidth(0.5)
            CreateProfileButton:SetCallback("OnClick", function()
                local profileName = strtrim(CreateProfileEditBox:GetText() or "")
                if profileName ~= "" then
                    UUF.db:SetProfile(profileName)
                    UIParent:SetScale(UUF.db.profile.General.UIScale or 1)
                    for unitFrameName, unit in pairs(UnitFrames) do
                        UUF:UpdateFrame(unitFrameName, unit)
                    end
                    RefreshProfiles()
                    CreateProfileEditBox:SetText("")
                end
            end)
            ProfileContainer:AddChild(CreateProfileButton)

            local GlobalProfileHeading = AG:Create("Heading")
            GlobalProfileHeading:SetText("Global Profile Settings")
            GlobalProfileHeading:SetFullWidth(true)
            ProfileContainer:AddChild(GlobalProfileHeading)

            local GlobalProfileInfoTag = CreateInfoTag("If |cFF8080FFUse Global Profile Settings|r is enabled, the profile selected below will be used as your active profile.\nThis is useful if you want to use the same profile across multiple characters.")
            GlobalProfileInfoTag:SetFullWidth(true)
            ProfileContainer:AddChild(GlobalProfileInfoTag)

            local UseGlobalProfileToggle = AG:Create("CheckBox")
            local GlobalProfileDropdown = AG:Create("Dropdown")
            UseGlobalProfileToggle:SetLabel("Use Global Profile Settings")
            UseGlobalProfileToggle:SetValue(UUF.db.global.UseGlobalProfile)
            UseGlobalProfileToggle:SetRelativeWidth(0.5)
            UseGlobalProfileToggle:SetCallback("OnValueChanged", function(_, _, value)
                UUF.db.global.UseGlobalProfile = value

                if value and UUF.db.global.GlobalProfile and UUF.db.global.GlobalProfile ~= "" then
                    UUF.db:SetProfile(UUF.db.global.GlobalProfile)
                    UIParent:SetScale(UUF.db.profile.General.UIScale or 1)
                    for unitFrameName, unit in pairs(UnitFrames) do
                        UUF:UpdateFrame(unitFrameName, unit)
                    end
                end

                GlobalProfileDropdown:SetDisabled(not value)

                for _, child in ipairs(ProfileContainer.children) do
                    if child ~= UseGlobalProfileToggle and child ~= GlobalProfileDropdown then
                        DeepDisable(child, value)
                    end
                end

                RefreshProfiles()
            end)
            ProfileContainer:AddChild(UseGlobalProfileToggle)

            GlobalProfileDropdown:SetLabel("Global Profile...")
            GlobalProfileDropdown:SetRelativeWidth(0.5)
            GlobalProfileDropdown:SetList(profileKeys)
            GlobalProfileDropdown:SetValue(UUF.db.global.GlobalProfile)
            GlobalProfileDropdown:SetCallback("OnValueChanged", function(_, _, value)
                UUF.db:SetProfile(value)
                UUF.db.global.GlobalProfile = value
                UIParent:SetScale(UUF.db.profile.General.UIScale or 1)
                for unitFrameName, unit in pairs(UnitFrames) do
                    UUF:UpdateFrame(unitFrameName, unit)
                end
                RefreshProfiles()
            end)
            ProfileContainer:AddChild(GlobalProfileDropdown)
            RefreshProfiles()
            ProfileContainer:DoLayout()

            local SharingContainer = AG:Create("InlineGroup")
            SharingContainer:SetTitle("Sharing")
            SharingContainer:SetLayout("Flow")
            SharingContainer:SetFullWidth(true)
            ScrollFrame:AddChild(SharingContainer)

            local ExportingHeading = AG:Create("Heading")
            ExportingHeading:SetText("Exporting")
            ExportingHeading:SetFullWidth(true)
            SharingContainer:AddChild(ExportingHeading)

            local ExportingImportingDesc = CreateInfoTag("You can export your profile by pressing |cFF8080FFExport Profile|r button below & share the string with other |cFF8080FFUnhalted|r Unit Frame users.")
            SharingContainer:AddChild(ExportingImportingDesc)

            local ExportingEditBox = AG:Create("EditBox")
            ExportingEditBox:SetLabel("Export String...")
            ExportingEditBox:SetText("")
            ExportingEditBox:SetFullWidth(true)
            ExportingEditBox:DisableButton(true)
            ExportingEditBox:SetCallback("OnEnterPressed", function() ExportingEditBox:ClearFocus() end)
            SharingContainer:AddChild(ExportingEditBox)

            local ExportProfileButton = AG:Create("Button")
            ExportProfileButton:SetText("Export Profile")
            ExportProfileButton:SetFullWidth(true)
            ExportProfileButton:SetCallback("OnClick", function() ExportingEditBox:SetText(UUF:ExportSavedVariables()) ExportingEditBox:HighlightText() ExportingEditBox:SetFocus() end)
            SharingContainer:AddChild(ExportProfileButton)

            local ImportingHeading = AG:Create("Heading")
            ImportingHeading:SetText("Importing")
            ImportingHeading:SetFullWidth(true)
            SharingContainer:AddChild(ImportingHeading)

            local ImportingDesc = CreateInfoTag("If you have an exported string, paste it in the |cFF8080FFImport String|r box below & press |cFF8080FFImport Profile|r.")
            SharingContainer:AddChild(ImportingDesc)

            local ImportingEditBox = AG:Create("EditBox")
            ImportingEditBox:SetLabel("Import String...")
            ImportingEditBox:SetText("")
            ImportingEditBox:SetFullWidth(true)
            ImportingEditBox:DisableButton(true)
            ImportingEditBox:SetCallback("OnEnterPressed", function() ImportingEditBox:ClearFocus() end)
            SharingContainer:AddChild(ImportingEditBox)

            local ImportProfileButton = AG:Create("Button")
            ImportProfileButton:SetText("Import Profile")
            ImportProfileButton:SetFullWidth(true)
            ImportProfileButton:SetCallback("OnClick", function() UUF:ImportSavedVariables(ImportingEditBox:GetText()) ImportingEditBox:SetText("") end)
            SharingContainer:AddChild(ImportProfileButton)

            GlobalProfileDropdown:SetDisabled(not UUF.db.global.UseGlobalProfile)

            if UUF.db.global.UseGlobalProfile then
                for _, child in ipairs(ProfileContainer.children) do
                    if child ~= UseGlobalProfileToggle and child ~= GlobalProfileDropdown then
                        DeepDisable(child, true)
                    end
                end
            end
            SharingContainer:DoLayout()
            ScrollFrame:DoLayout()
        end

        if mainGroup == "General" then
            DrawGeneralContainer(GUIContainer)
        elseif mainGroup == "Global" then
            DrawGlobalContainer(GUIContainer)
        elseif mainGroup == "Filters" then
            DrawFiltersContainer(GUIContainer)
        elseif mainGroup == "Player" then
            DrawUnitContainer(GUIContainer, "player")
        elseif mainGroup == "Target" then
            DrawUnitContainer(GUIContainer, "target")
        elseif mainGroup == "TargetTarget" then
            DrawUnitContainer(GUIContainer, "targettarget")
        elseif mainGroup == "Focus" then
            DrawUnitContainer(GUIContainer, "focus")
        elseif mainGroup == "FocusTarget" then
            DrawUnitContainer(GUIContainer, "focustarget")
        elseif mainGroup == "Pet" then
            DrawUnitContainer(GUIContainer, "pet")
        elseif mainGroup == "Boss" then
            DrawUnitContainer(GUIContainer, "boss")
        elseif mainGroup == "Party" then
            DrawUnitContainer(GUIContainer, "party")
        elseif mainGroup == "Raid" then
            DrawUnitContainer(GUIContainer, "raid")
        elseif mainGroup == "Tags" then
            DrawTagsContainer(GUIContainer)
        elseif mainGroup == "Profiles" then
            DrawProfilesContainer(GUIContainer)
        end
    end

    local GUIContainerTabGroup = AG:Create("TabGroup")
    GUIContainerTabGroup:SetLayout("Flow")
    GUIContainerTabGroup:SetTabs({
        { text = "General", value = "General"},
        { text = "Global", value = "Global"},
        { text = "Filters", value = "Filters"},
        { text = "Player", value = "Player"},
        { text = "Target", value = "Target"},
        { text = "Target Target", value = "TargetTarget"},
        { text = "Focus", value = "Focus"},
        { text = "Focus Target", value = "FocusTarget"},
        { text = "Pet", value = "Pet"},
        { text = "Boss", value = "Boss"},
        { text = "Party", value = "Party"},
        { text = "Raid", value = "Raid"},
        { text = "Tags", value = "Tags"},
        { text = "Profiles", value = "Profiles"},
    })
    GUIContainerTabGroup:SetCallback("OnGroupSelected", SelectedGroup)
    GUIContainerTabGroup:SelectTab("General")
    GUIContainer:AddChild(GUIContainerTabGroup)
end

UUF.Defaults = {
    global = {
        UseGlobalProfile = false,
        GlobalProfile = "Default",
    },
    profile = {
        General = {
            AllowUIScaling = true,
            UIScale = 1,
            Font = "Friz Quadrata TT",
            FontFlag = "OUTLINE",
            FontShadows = {
                SColour = {0, 0, 0, 0},
                OffsetX = 0,
                OffsetY = 0
            },
            ForegroundTexture = "Blizzard Raid Bar",
            BackgroundTexture = "Solid",
            CustomColours = {
                Reaction = {
                    [1] = {204/255, 64/255, 64/255},            -- Hated
                    [2] = {204/255, 64/255, 64/255},            -- Hostile
                    [3] = {204/255, 128/255, 64/255},           -- Unfriendly
                    [4] = {204/255, 204/255, 64/255},           -- Neutral
                    [5] = {64/255, 204/255, 64/255},            -- Friendly
                    [6] = {64/255, 204/255, 64/255},            -- Honored
                    [7] = {64/255, 204/255, 64/255},            -- Revered
                    [8] = {64/255, 204/255, 64/255},            -- Exalted
                },
                Power = {
                    [0] = {0, 0, 1},            -- Mana
                    [1] = {1, 0, 0},            -- Rage
                    [2] = {1, 0.5, 0.25},       -- Focus
                    [3] = {1, 1, 0},            -- Energy
                    [6] = {0, 0.82, 1},         -- Runic Power
                    [8] = {0.3, 0.52, 0.9},     -- Lunar Power
                    [11] = {0, 0.5, 1},         -- Maelstrom
                    [13] = {0.4, 0, 0.8},       -- Insanity
                    [17] = {0.79, 0.26, 0.99},  -- Fury
                    [18] = {1, 0.61, 0}         -- Pain
                },
            },
            DecimalPlaces = 1,
            TagUpdateInterval = 0.25,
            HealthSeparator = "||",
            TargetTargetSeparator = "»",
        },
        Filters = {
            Whitelist = {
                Buffs = {},
                Debuffs = {},
            },
            Blacklist = {
                Buffs = {},
                Debuffs = {},
            },
            FilterUnits = {
                ["player"] = false,
                ["target"] = false,
                ["targettarget"] = false,
                ["focus"] = false,
                ["pet"] = false,
                ["boss"] = false,
                ["party"] = false,
            }
        },
        player = {
            Enabled = true,
            Frame = {
                Width = 244,
                Height = 42,
                XPosition = -425.1,
                YPosition = -275.1,
                AnchorFrom = "CENTER",
                AnchorTo = "CENTER",
                ClassColour = false,
                ReactionColour = false,
                FGColour = {8/255, 8/255, 8/255, 0.8},
                BGColour = {204/255, 204/255, 204/255, 1.0},
            },
            HealPrediction = {
                Absorb = {
                    Enabled = true,
                    AnchorPoint = "BOTTOMLEFT",
                    Height = 3,
                    Colour = {255/255, 204/255, 0/255, 1},
                },
                HealAbsorb = {
                    Enabled = true,
                    Colour = {128/255, 64/255, 255/255, 1},
                }
            },
            PowerBar = {
                Enabled = false,
                Height = 3,
                ColourByType = true,
                FGColour = {8/255, 8/255, 8/255, 0.8},
                BGColour = {204/255, 204/255, 204/255, 1},
            },
            CastBar = {
                Enabled = true,
                Width = 244,
                Height = 24,
                AnchorFrom = "TOPLEFT",
                AnchorTo = "BOTTOMLEFT",
                OffsetX = 0,
                OffsetY = -1,
                FGColour = {8/255, 8/255, 8/255, 0.8},
                BGColour = {204/255, 204/255, 204/255, 1},
                NotInterruptibleColour = {255/255, 64/255, 64/255, 1},
                Icon = {
                    Enabled = true,
                    Side = "LEFT",
                },
                Texts = {
                    SpellName = {
                        AnchorFrom = "LEFT",
                        AnchorTo = "LEFT",
                        OffsetX = 3,
                        OffsetY = 0,
                        FontSize = 12,
                        Colour = {1, 1, 1, 1},
                        MaxChars = 32,
                    },
                    CastTime = {
                        AnchorFrom = "RIGHT",
                        AnchorTo = "RIGHT",
                        OffsetX = -3,
                        OffsetY = 0,
                        FontSize = 12,
                        Colour = {1, 1, 1, 1},
                        CriticalTime = 3,
                    },
                }
            },
            Buffs = {
                Enabled = false,
                Size = 34,
                AnchorFrom = "BOTTOMRIGHT",
                AnchorTo = "TOPRIGHT",
                OffsetX = 0,
                OffsetY = 1,
                Spacing = 1,
                Num = 4,
                Wrap = 4,
                Growth = "LEFT",
                WrapDirection = "UP",
                Count = {
                    AnchorFrom = "BOTTOMRIGHT",
                    AnchorTo = "BOTTOMRIGHT",
                    OffsetX = 0,
                    OffsetY = 2,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                }
            },
            Debuffs = {
                Enabled = false,
                Size = 34,
                AnchorFrom = "BOTTOMLEFT",
                AnchorTo = "TOPLEFT",
                OffsetX = 0,
                OffsetY = 1,
                Spacing = 1,
                Num = 3,
                Wrap = 3,
                Growth = "RIGHT",
                WrapDirection = "UP",
                Count = {
                    AnchorFrom = "BOTTOMRIGHT",
                    AnchorTo = "BOTTOMRIGHT",
                    OffsetX = 0,
                    OffsetY = 2,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                }
            },
            Indicators = {
                RaidMarker = {
                    Enabled = true,
                    Size = 18,
                    AnchorFrom = "LEFT",
                    AnchorTo = "TOPLEFT",
                    OffsetX = 3,
                    OffsetY = 0,
                },
                Leader = {
                    Enabled = true,
                    Size = 15,
                    AnchorFrom = "LEFT",
                    AnchorTo = "TOPLEFT",
                    OffsetX = 3,
                    OffsetY = 0,
                },
                Status = {
                    Combat = false,
                    Resting = false,
                    Size = 16,
                    AnchorFrom = "TOPLEFT",
                    AnchorTo = "TOPLEFT",
                    OffsetX = 3,
                    OffsetY = -3,
                    RestingTexture = "RESTING5",
                    CombatTexture = "COMBAT1",
                },
                MouseoverHighlight = {
                    Enabled = true,
                    Colour = {1, 1, 1, 0.1},
                    Type = "BACKGROUND",
                }
            },
            Portrait = {
                Enabled = true,
                AnchorFrom = "TOPRIGHT",
                AnchorTo = "TOPLEFT",
                OffsetX = -1,
                OffsetY = 0,
                Size = 42,
                Style = "MODEL",
                Zoom = 0.3,
            },
            Tags = {
                AnchorParent = "FRAME",
                First = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                    Tag = "",
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                },
                Second = {
                    AnchorFrom = "RIGHT",
                    AnchorTo = "RIGHT",
                    OffsetX = -3,
                    OffsetY = 0,
                    Tag = "[health:curhp-perhp-with-absorb]",
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                },
                Third = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                    Tag = "",
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                },
                Fourth = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                    Tag = "",
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                }
            },
        },
        target = {
            Enabled = true,
            Frame = {
                Width = 244,
                Height = 42,
                XPosition = 425.1,
                YPosition = -275.1,
                AnchorFrom = "CENTER",
                AnchorTo = "CENTER",
                ClassColour = false,
                ReactionColour = false,
                FGColour = {8/255, 8/255, 8/255, 0.8},
                BGColour = {204/255, 204/255, 204/255, 1.0},
            },
            HealPrediction = {
                Absorb = {
                    Enabled = true,
                    AnchorPoint = "BOTTOMLEFT",
                    Height = 3,
                    Colour = {255/255, 204/255, 0/255, 1},
                },
                HealAbsorb = {
                    Enabled = true,
                    Colour = {128/255, 64/255, 255/255, 1},
                }
            },
            PowerBar = {
                Enabled = true,
                Height = 1,
                ColourByType = true,
                FGColour = {8/255, 8/255, 8/255, 0.8},
                BGColour = {204/255, 204/255, 204/255, 1},
            },
            CastBar = {
                Enabled = true,
                Width = 244,
                Height = 24,
                AnchorFrom = "TOPLEFT",
                AnchorTo = "BOTTOMLEFT",
                OffsetX = 0,
                OffsetY = -1,
                FGColour = {8/255, 8/255, 8/255, 0.8},
                BGColour = {204/255, 204/255, 204/255, 1},
                NotInterruptibleColour = {255/255, 64/255, 64/255, 1},
                Icon = {
                    Enabled = true,
                    Side = "RIGHT",
                },
                Texts = {
                    SpellName = {
                        AnchorFrom = "LEFT",
                        AnchorTo = "LEFT",
                        OffsetX = 3,
                        OffsetY = 0,
                        FontSize = 12,
                        Colour = {1, 1, 1, 1},
                        MaxChars = 32,
                    },
                    CastTime = {
                        AnchorFrom = "RIGHT",
                        AnchorTo = "RIGHT",
                        OffsetX = -3,
                        OffsetY = 0,
                        FontSize = 12,
                        Colour = {1, 1, 1, 1},
                        CriticalTime = 3,
                    },
                }
            },
            Buffs = {
                Enabled = true,
                Size = 34,
                AnchorFrom = "BOTTOMLEFT",
                AnchorTo = "TOPLEFT",
                OffsetX = 0,
                OffsetY = 1,
                Spacing = 1,
                Num = 4,
                Wrap = 4,
                Growth = "RIGHT",
                WrapDirection = "UP",
                Count = {
                    AnchorFrom = "BOTTOMRIGHT",
                    AnchorTo = "BOTTOMRIGHT",
                    OffsetX = 0,
                    OffsetY = 2,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                }
            },
            Debuffs = {
                Enabled = true,
                Size = 34,
                AnchorFrom = "BOTTOMRIGHT",
                AnchorTo = "TOPRIGHT",
                OffsetX = 0,
                OffsetY = 1,
                Spacing = 1,
                Num = 3,
                Wrap = 3,
                Growth = "LEFT",
                WrapDirection = "UP",
                Count = {
                    AnchorFrom = "BOTTOMRIGHT",
                    AnchorTo = "BOTTOMRIGHT",
                    OffsetX = 0,
                    OffsetY = 2,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                }
            },
            Indicators = {
                RaidMarker = {
                    Enabled = true,
                    Size = 18,
                    AnchorFrom = "RIGHT",
                    AnchorTo = "TOPRIGHT",
                    OffsetX = -3,
                    OffsetY = 0,
                },
                Leader = {
                    Enabled = false,
                    Size = 15,
                    AnchorFrom = "RIGHT",
                    AnchorTo = "TOPRIGHT",
                    OffsetX = -3,
                    OffsetY = 0,
                },
                MouseoverHighlight = {
                    Enabled = true,
                    Colour = {1, 1, 1, 0.1},
                    Type = "BACKGROUND",
                },
                Quest = {
                    Enabled = true,
                    Size = 15,
                    AnchorFrom = "RIGHT",
                    AnchorTo = "TOPRIGHT",
                    OffsetX = -3,
                    OffsetY = 0,
                }
            },
            Portrait = {
                Enabled = true,
                AnchorFrom = "TOPLEFT",
                AnchorTo = "TOPRIGHT",
                OffsetX = 1,
                OffsetY = 0,
                Size = 42,
                Style = "MODEL",
                Zoom = 0.3
            },
            Range = {
                Enabled = true,
                InRange = 1.0,
                OutOfRange = 0.5,
            },
            Tags = {
                AnchorParent = "FRAME",
                First = {
                    AnchorFrom = "LEFT",
                    AnchorTo = "LEFT",
                    OffsetX = 3,
                    OffsetY = 0,
                    Tag = "[colour][name:last][name:targettarget:colour]",
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                },
                Second = {
                    AnchorFrom = "RIGHT",
                    AnchorTo = "RIGHT",
                    OffsetX = -3,
                    OffsetY = 0,
                    Tag = "[health:curhp-perhp-with-absorb]",
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                },
                Third = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                    Tag = "",
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                },
                Fourth = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                    Tag = "",
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                }
            },
        },
        targettarget = {
            Enabled = true,
            Frame = {
                Width = 122,
                Height = 26,
                XPosition = 0,
                YPosition = -26,
                AnchorFrom = "TOPRIGHT",
                AnchorParent = "UUF_Target",
                AnchorTo = "BOTTOMRIGHT",
                ClassColour = false,
                ReactionColour = false,
                FGColour = {8/255, 8/255, 8/255, 0.8},
                BGColour = {204/255, 204/255, 204/255, 1.0},
            },
            PowerBar = {
                Enabled = false,
                Height = 3,
                ColourByType = true,
                FGColour = {8/255, 8/255, 8/255, 0.8},
                BGColour = {204/255, 204/255, 204/255, 1},
            },
            Buffs = {
                Enabled = false,
                Size = 26,
                AnchorFrom = "LEFT",
                AnchorTo = "RIGHT",
                OffsetX = 1,
                OffsetY = 0,
                Spacing = 1,
                Num = 1,
                Wrap = 1,
                Growth = "RIGHT",
                WrapDirection = "UP",
                Count = {
                    AnchorFrom = "BOTTOMRIGHT",
                    AnchorTo = "BOTTOMRIGHT",
                    OffsetX = 0,
                    OffsetY = 2,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                }
            },
            Debuffs = {
                Enabled = false,
                Size = 26,
                AnchorFrom = "RIGHT",
                AnchorTo = "LEFT",
                OffsetX = -1,
                OffsetY = 0,
                Spacing = 1,
                Num = 1,
                Wrap = 1,
                Growth = "LEFT",
                WrapDirection = "UP",
                Count = {
                    AnchorFrom = "BOTTOMRIGHT",
                    AnchorTo = "BOTTOMRIGHT",
                    OffsetX = 0,
                    OffsetY = 2,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                }
            },
            Indicators = {
                RaidMarker = {
                    Enabled = true,
                    Size = 18,
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                },
                MouseoverHighlight = {
                    Enabled = true,
                    Colour = {1, 1, 1, 0.1},
                    Type = "BACKGROUND",
                }
            },
            Portrait = {
                Enabled = false,
                AnchorFrom = "TOPLEFT",
                AnchorTo = "TOPRIGHT",
                OffsetX = 1,
                OffsetY = 0,
                Size = 26,
                Style = "MODEL",
                Zoom = 0.3
            },
            Range = {
                Enabled = true,
                InRange = 1.0,
                OutOfRange = 0.5,
            },
            Tags = {
                AnchorParent = "FRAME",
                First = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                    Tag = "[colour][name:last]",
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                },
                Second = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                    Tag = "",
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                },
                Third = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                    Tag = "",
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                },
                Fourth = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                    Tag = "",
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                }
            },
        },
        focus = {
            Enabled = true,
            Frame = {
                Width = 122,
                Height = 26,
                XPosition = 0,
                YPosition = 36,
                AnchorFrom = "BOTTOMLEFT",
                AnchorParent = "UUF_Player",
                AnchorTo = "TOPLEFT",
                ClassColour = false,
                ReactionColour = false,
                FGColour = {8/255, 8/255, 8/255, 0.8},
                BGColour = {204/255, 204/255, 204/255, 1.0},
            },
            HealPrediction = {
                Absorb = {
                    Enabled = true,
                    AnchorPoint = "BOTTOMLEFT",
                    Height = 3,
                    Colour = {255/255, 204/255, 0/255, 1},
                },
                HealAbsorb = {
                    Enabled = true,
                    Colour = {128/255, 64/255, 255/255, 1},
                }
            },
            PowerBar = {
                Enabled = false,
                Height = 3,
                ColourByType = true,
                FGColour = {8/255, 8/255, 8/255, 0.8},
                BGColour = {204/255, 204/255, 204/255, 1},
            },
            CastBar = {
                Enabled = true,
                Width = 122,
                Height = 28,
                AnchorFrom = "BOTTOMLEFT",
                AnchorTo = "TOPLEFT",
                OffsetX = 0,
                OffsetY = 1,
                FGColour = {8/255, 8/255, 8/255, 0.8},
                BGColour = {204/255, 204/255, 204/255, 1},
                NotInterruptibleColour = {255/255, 64/255, 64/255, 1},
                Icon = {
                    Enabled = false,
                    Side = "RIGHT",
                },
                Texts = {
                    SpellName = {
                        AnchorFrom = "LEFT",
                        AnchorTo = "LEFT",
                        OffsetX = 3,
                        OffsetY = 0,
                        FontSize = 12,
                        Colour = {1, 1, 1, 1},
                        MaxChars = 10,
                    },
                    CastTime = {
                        AnchorFrom = "RIGHT",
                        AnchorTo = "RIGHT",
                        OffsetX = -3,
                        OffsetY = 0,
                        FontSize = 12,
                        Colour = {1, 1, 1, 1},
                        CriticalTime = 3,
                    },
                }
            },
            Buffs = {
                Enabled = false,
                Size = 26,
                AnchorFrom = "RIGHT",
                AnchorTo = "LEFT",
                OffsetX = -1,
                OffsetY = 0,
                Spacing = 1,
                Num = 1,
                Wrap = 1,
                Growth = "LEFT",
                WrapDirection = "UP",
                Count = {
                    AnchorFrom = "BOTTOMRIGHT",
                    AnchorTo = "BOTTOMRIGHT",
                    OffsetX = 0,
                    OffsetY = 2,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                }
            },
            Debuffs = {
                Enabled = false,
                Size = 26,
                AnchorFrom = "LEFT",
                AnchorTo = "RIGHT",
                OffsetX = 1,
                OffsetY = 0,
                Spacing = 1,
                Num = 1,
                Wrap = 1,
                Growth = "RIGHT",
                WrapDirection = "UP",
                Count = {
                    AnchorFrom = "BOTTOMRIGHT",
                    AnchorTo = "BOTTOMRIGHT",
                    OffsetX = 0,
                    OffsetY = 2,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                }
            },
            Indicators = {
                RaidMarker = {
                    Enabled = true,
                    Size = 18,
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = -3,
                    OffsetY = 0,
                },
                MouseoverHighlight = {
                    Enabled = true,
                    Colour = {1, 1, 1, 0.1},
                    Type = "BACKGROUND",
                }
            },
            Portrait = {
                Enabled = false,
                AnchorFrom = "TOPRIGHT",
                AnchorTo = "TOPLEFT",
                OffsetX = -1,
                OffsetY = 0,
                Size = 26,
                Style = "MODEL",
                Zoom = 0.3
            },
            Range = {
                Enabled = true,
                InRange = 1.0,
                OutOfRange = 0.5,
            },
            Tags = {
                AnchorParent = "FRAME",
                First = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                    Tag = "[colour][name:last]",
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                },
                Second = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                    Tag = "",
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                },
                Third = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                    Tag = "",
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                },
                Fourth = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                    Tag = "",
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                }
            },
        },
        focustarget = {
            Enabled = false,
            Frame = {
                Width = 121,
                Height = 26,
                XPosition = 1.1,
                YPosition = 0,
                AnchorFrom = "LEFT",
                AnchorParent = "UUF_Focus",
                AnchorTo = "RIGHT",
                ClassColour = false,
                ReactionColour = false,
                FGColour = {8/255, 8/255, 8/255, 0.8},
                BGColour = {204/255, 204/255, 204/255, 1.0},
            },
            PowerBar = {
                Enabled = false,
                Height = 3,
                ColourByType = true,
                FGColour = {8/255, 8/255, 8/255, 0.8},
                BGColour = {204/255, 204/255, 204/255, 1},
            },
            Indicators = {
                RaidMarker = {
                    Enabled = false,
                    Size = 18,
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                },
                MouseoverHighlight = {
                    Enabled = true,
                    Colour = {1, 1, 1, 0.1},
                    Type = "BACKGROUND",
                }
            },
            Range = {
                Enabled = true,
                InRange = 1.0,
                OutOfRange = 0.5,
            },
            Tags = {
                AnchorParent = "FRAME",
                First = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                    Tag = "[colour][name:last]",
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                },
                Second = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                    Tag = "",
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                },
                Third = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                    Tag = "",
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                },
                Fourth = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                    Tag = "",
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                }
            },
        },
        pet = {
            Enabled = true,
            Frame = {
                Width = 122,
                Height = 26,
                XPosition = 0,
                YPosition = -26,
                AnchorFrom = "TOPLEFT",
                AnchorParent = "UUF_Player",
                AnchorTo = "BOTTOMLEFT",
                ClassColour = false,
                ReactionColour = false,
                FGColour = {8/255, 8/255, 8/255, 0.8},
                BGColour = {204/255, 204/255, 204/255, 1.0},
            },
            HealPrediction = {
                Absorb = {
                    Enabled = false,
                    AnchorPoint = "BOTTOMLEFT",
                    Height = 3,
                    Colour = {255/255, 204/255, 0/255, 1},
                },
                HealAbsorb = {
                    Enabled = false,
                    Colour = {128/255, 64/255, 255/255, 1},
                }
            },
            PowerBar = {
                Enabled = false,
                Height = 3,
                ColourByType = true,
                FGColour = {8/255, 8/255, 8/255, 0.8},
                BGColour = {204/255, 204/255, 204/255, 1},
            },
            CastBar = {
                Enabled = false,
                Width = 122,
                Height = 24,
                AnchorFrom = "TOPLEFT",
                AnchorTo = "BOTTOMLEFT",
                OffsetX = 0,
                OffsetY = -1,
                FGColour = {8/255, 8/255, 8/255, 0.8},
                BGColour = {204/255, 204/255, 204/255, 1},
                NotInterruptibleColour = {255/255, 64/255, 64/255, 1},
                Icon = {
                    Enabled = false,
                    Side = "LEFT",
                },
                Texts = {
                    SpellName = {
                        AnchorFrom = "LEFT",
                        AnchorTo = "LEFT",
                        OffsetX = 3,
                        OffsetY = 0,
                        FontSize = 12,
                        Colour = {1, 1, 1, 1},
                        MaxChars = 10,
                    },
                    CastTime = {
                        AnchorFrom = "RIGHT",
                        AnchorTo = "RIGHT",
                        OffsetX = -3,
                        OffsetY = 0,
                        FontSize = 12,
                        Colour = {1, 1, 1, 1},
                        CriticalTime = 3,
                    },
                }
            },
            Buffs = {
                Enabled = false,
                Size = 26,
                AnchorFrom = "RIGHT",
                AnchorTo = "LEFT",
                OffsetX = -1,
                OffsetY = 0,
                Spacing = 1,
                Num = 1,
                Wrap = 1,
                Growth = "LEFT",
                WrapDirection = "UP",
                Count = {
                    AnchorFrom = "BOTTOMRIGHT",
                    AnchorTo = "BOTTOMRIGHT",
                    OffsetX = 0,
                    OffsetY = 2,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                }
            },
            Debuffs = {
                Enabled = false,
                Size = 26,
                AnchorFrom = "LEFT",
                AnchorTo = "RIGHT",
                OffsetX = 1,
                OffsetY = 0,
                Spacing = 1,
                Num = 1,
                Wrap = 1,
                Growth = "RIGHT",
                WrapDirection = "UP",
                Count = {
                    AnchorFrom = "BOTTOMRIGHT",
                    AnchorTo = "BOTTOMRIGHT",
                    OffsetX = 0,
                    OffsetY = 2,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                }
            },
            Indicators = {
                RaidMarker = {
                    Enabled = false,
                    Size = 18,
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = -3,
                    OffsetY = 0,
                },
                MouseoverHighlight = {
                    Enabled = true,
                    Colour = {1, 1, 1, 0.1},
                    Type = "BACKGROUND",
                }
            },
            Portrait = {
                Enabled = false,
                AnchorFrom = "TOPRIGHT",
                AnchorTo = "TOPLEFT",
                OffsetX = -1,
                OffsetY = 0,
                Size = 10,
                Style = "MODEL",
                Zoom = 0.3,
            },
            Range = {
                Enabled = true,
                InRange = 1.0,
                OutOfRange = 0.5,
            },
            Tags = {
                AnchorParent = "FRAME",
                First = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                    Tag = "[colour][name:veryshort]",
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                },
                Second = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                    Tag = "",
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                },
                Third = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                    Tag = "",
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                },
                Fourth = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                    Tag = "",
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                }
            },
        },
        boss = {
            Enabled = true,
            Frame = {
                Width = 250,
                Height = 48,
                XPosition = -250.1,
                YPosition = 0.1,
                AnchorFrom = "RIGHT",
                AnchorTo = "RIGHT",
                ClassColour = false,
                ReactionColour = false,
                FGColour = {8/255, 8/255, 8/255, 0.8},
                BGColour = {204/255, 204/255, 204/255, 1.0},
                GrowthDirection = "DOWN",
                Spacing = 28,
            },
            HealPrediction = {
                Absorb = {
                    Enabled = true,
                    AnchorPoint = "BOTTOMLEFT",
                    Height = 3,
                    Colour = {255/255, 204/255, 0/255, 1},
                },
                HealAbsorb = {
                    Enabled = true,
                    Colour = {128/255, 64/255, 255/255, 1},
                }
            },
            PowerBar = {
                Enabled = true,
                Height = 1,
                ColourByType = true,
                FGColour = {8/255, 8/255, 8/255, 0.8},
                BGColour = {204/255, 204/255, 204/255, 1},
            },
            CastBar = {
                Enabled = true,
                Width = 250,
                Height = 26,
                AnchorFrom = "TOPLEFT",
                AnchorTo = "BOTTOMLEFT",
                OffsetX = 0,
                OffsetY = -1,
                FGColour = {8/255, 8/255, 8/255, 0.8},
                BGColour = {204/255, 204/255, 204/255, 1},
                NotInterruptibleColour = {255/255, 64/255, 64/255, 1},
                Icon = {
                    Enabled = true,
                    Side = "RIGHT",
                },
                Texts = {
                    SpellName = {
                        AnchorFrom = "LEFT",
                        AnchorTo = "LEFT",
                        OffsetX = 3,
                        OffsetY = 0,
                        FontSize = 12,
                        Colour = {1, 1, 1, 1},
                        MaxChars = 32,
                    },
                    CastTime = {
                        AnchorFrom = "RIGHT",
                        AnchorTo = "RIGHT",
                        OffsetX = -3,
                        OffsetY = 0,
                        FontSize = 12,
                        Colour = {1, 1, 1, 1},
                        CriticalTime = 3,
                    },
                }
            },
            Buffs = {
                Enabled = true,
                Size = 48,
                AnchorFrom = "LEFT",
                AnchorTo = "RIGHT",
                OffsetX = 1,
                OffsetY = 0,
                Spacing = 1,
                Num = 1,
                Wrap = 3,
                Growth = "RIGHT",
                WrapDirection = "UP",
                Count = {
                    AnchorFrom = "BOTTOMRIGHT",
                    AnchorTo = "BOTTOMRIGHT",
                    OffsetX = 0,
                    OffsetY = 2,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                }
            },
            Debuffs = {
                Enabled = true,
                Size = 48,
                AnchorFrom = "RIGHT",
                AnchorTo = "LEFT",
                OffsetX = -50,
                OffsetY = 0,
                Spacing = 1,
                Num = 3,
                Wrap = 3,
                Growth = "LEFT",
                WrapDirection = "UP",
                Count = {
                    AnchorFrom = "BOTTOMRIGHT",
                    AnchorTo = "BOTTOMRIGHT",
                    OffsetX = 0,
                    OffsetY = 2,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                }
            },
            Indicators = {
                RaidMarker = {
                    Enabled = true,
                    Size = 24,
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                },
                MouseoverHighlight = {
                    Enabled = true,
                    Colour = {1, 1, 1, 0.1},
                    Type = "BACKGROUND",
                },
                TargetIndicator = {
                    Enabled = true,
                    Colour = {1, 1, 1, 1},
                }
            },
            Portrait = {
                Enabled = true,
                AnchorFrom = "TOPRIGHT",
                AnchorTo = "TOPLEFT",
                OffsetX = -1,
                OffsetY = 0,
                Size = 48,
                Style = "MODEL",
                Zoom = 0.3,
            },
            Range = {
                Enabled = true,
                InRange = 1.0,
                OutOfRange = 0.5,
            },
            Tags = {
                AnchorParent = "FRAME",
                First = {
                    AnchorFrom = "LEFT",
                    AnchorTo = "LEFT",
                    OffsetX = 3,
                    OffsetY = 0,
                    Tag = "[colour][name:last]",
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                },
                Second = {
                    AnchorFrom = "TOPRIGHT",
                    AnchorTo = "TOPRIGHT",
                    OffsetX = -3,
                    OffsetY = -3,
                    Tag = "[health:curhp-perhp-with-absorb]",
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                },
                Third = {
                    AnchorFrom = "BOTTOMRIGHT",
                    AnchorTo = "BOTTOMRIGHT",
                    OffsetX = -3,
                    OffsetY = 6,
                    Tag = "[powercolour][power:curpp]",
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                },
                Fourth = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                    Tag = "",
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                }
            },
        },
        party = {
            Enabled = true,
            Frame = {
                Width = 250,
                Height = 48,
                XPosition = 250.1,
                YPosition = 0.1,
                AnchorFrom = "LEFT",
                AnchorTo = "LEFT",
                ClassColour = false,
                ReactionColour = false,
                FGColour = {8/255, 8/255, 8/255, 0.8},
                BGColour = {204/255, 204/255, 204/255, 1.0},
                Spacing = 1,
                ShowPlayer = false,
                SortOrder = {"TANK", "HEALER", "DAMAGER"},
                Layout = "VERTICAL"
            },
            HealPrediction = {
                Absorb = {
                    Enabled = true,
                    AnchorPoint = "BOTTOMRIGHT",
                    Height = 46,
                    Colour = {255/255, 204/255, 0/255, 1},
                },
                HealAbsorb = {
                    Enabled = true,
                    Colour = {128/255, 64/255, 255/255, 1},
                }
            },
            PowerBar = {
                Enabled = false,
                Height = 1,
                ColourByType = true,
                FGColour = {8/255, 8/255, 8/255, 0.8},
                BGColour = {204/255, 204/255, 204/255, 1},
            },
            Buffs = {
                Enabled = true,
                Size = 25,
                AnchorFrom = "BOTTOMRIGHT",
                AnchorTo = "BOTTOMRIGHT",
                OffsetX = -2,
                OffsetY = 2,
                Spacing = 1,
                Num = 3,
                Wrap = 3,
                Growth = "LEFT",
                WrapDirection = "UP",
                Count = {
                    AnchorFrom = "BOTTOMRIGHT",
                    AnchorTo = "BOTTOMRIGHT",
                    OffsetX = 0,
                    OffsetY = 2,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                }
            },
            Debuffs = {
                Enabled = true,
                Size = 48,
                AnchorFrom = "LEFT",
                AnchorTo = "RIGHT",
                OffsetX = 1,
                OffsetY = 0,
                Spacing = 1,
                Num = 3,
                Wrap = 3,
                Growth = "RIGHT",
                WrapDirection = "UP",
                Count = {
                    AnchorFrom = "BOTTOMRIGHT",
                    AnchorTo = "BOTTOMRIGHT",
                    OffsetX = 0,
                    OffsetY = 2,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                }
            },
            Indicators = {
                RaidMarker = {
                    Enabled = true,
                    Size = 16,
                    AnchorFrom = "RIGHT",
                    AnchorTo = "TOPRIGHT",
                    OffsetX = -3,
                    OffsetY = 0,
                },
                Leader = {
                    Enabled = true,
                    Size = 15,
                    AnchorFrom = "LEFT",
                    AnchorTo = "TOPLEFT",
                    OffsetX = 3,
                    OffsetY = 0,
                },
                MouseoverHighlight = {
                    Enabled = true,
                    Colour = {1, 1, 1, 0.1},
                    Type = "BACKGROUND",
                },
                RoleIcons = {
                    Enabled = true,
                    Size = 16,
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                    RoleTextures = "UUFLIGHT",
                },
                ReadyCheck = {
                    Enabled = true,
                    Size = 24,
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                    ReadyCheckTextures = "UUFLIGHT",
                }
            },
            Portrait = {
                Enabled = false,
                AnchorFrom = "TOPRIGHT",
                AnchorTo = "TOPLEFT",
                OffsetX = -1,
                OffsetY = 0,
                Size = 48,
                Style = "MODEL",
                Zoom = 0.3,
            },
            Range = {
                Enabled = true,
                InRange = 1.0,
                OutOfRange = 0.5,
            },
            Tags = {
                AnchorParent = "FRAME",
                First = {
                    AnchorFrom = "TOPLEFT",
                    AnchorTo = "TOPLEFT",
                    OffsetX = 3,
                    OffsetY = -3,
                    Tag = "[colour][name:last]",
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                },
                Second = {
                    AnchorFrom = "TOPRIGHT",
                    AnchorTo = "TOPRIGHT",
                    OffsetX = -3,
                    OffsetY = -3,
                    Tag = "[health:perhp-healermana:colour]",
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                },
                Third = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                    Tag = "",
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                },
                Fourth = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                    Tag = "",
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                }
            },
        },
        raid = {
            Enabled = true,
            Frame = {
                Width = 90,
                Height = 64,
                XPosition = 1.1,
                YPosition = 250.1,
                AnchorFrom = "BOTTOMLEFT",
                AnchorTo = "BOTTOMLEFT",
                ClassColour = false,
                ReactionColour = false,
                FGColour = {8/255, 8/255, 8/255, 0.8},
                BGColour = {204/255, 204/255, 204/255, 1.0},
                Spacing = 1,
                GroupsToShow = 8,
                UnitsPerColumn = 5,
                RowGrowth = "UP",
                ColumnGrowth = "RIGHT",
            },
            HealPrediction = {
                Absorb = {
                    Enabled = true,
                    AnchorPoint = "BOTTOMRIGHT",
                    Height = 46,
                    Colour = {255/255, 204/255, 0/255, 1},
                },
                HealAbsorb = {
                    Enabled = true,
                    Colour = {128/255, 64/255, 255/255, 1},
                }
            },
            PowerBar = {
                Enabled = false,
                Height = 1,
                ColourByType = true,
                FGColour = {8/255, 8/255, 8/255, 0.8},
                BGColour = {204/255, 204/255, 204/255, 1},
            },
            Buffs = {
                Enabled = true,
                Size = 25,
                AnchorFrom = "BOTTOMLEFT",
                AnchorTo = "BOTTOMLEFT",
                OffsetX = 2,
                OffsetY = 2,
                Spacing = 1,
                Num = 1,
                Wrap = 1,
                Growth = "RIGHT",
                WrapDirection = "UP",
                Count = {
                    AnchorFrom = "BOTTOMRIGHT",
                    AnchorTo = "BOTTOMRIGHT",
                    OffsetX = 0,
                    OffsetY = 2,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                }
            },
            Debuffs = {
                Enabled = true,
                Size = 25,
                AnchorFrom = "BOTTOMRIGHT",
                AnchorTo = "BOTTOMRIGHT",
                OffsetX = -2,
                OffsetY = 2,
                Spacing = 1,
                Num = 1,
                Wrap = 1,
                Growth = "LEFT",
                WrapDirection = "UP",
                Count = {
                    AnchorFrom = "BOTTOMRIGHT",
                    AnchorTo = "BOTTOMRIGHT",
                    OffsetX = 0,
                    OffsetY = 2,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                }
            },
            Indicators = {
                RaidMarker = {
                    Enabled = true,
                    Size = 16,
                    AnchorFrom = "RIGHT",
                    AnchorTo = "TOPRIGHT",
                    OffsetX = -3,
                    OffsetY = 0,
                },
                Leader = {
                    Enabled = true,
                    Size = 15,
                    AnchorFrom = "TOPLEFT",
                    AnchorTo = "TOPLEFT",
                    OffsetX = 3,
                    OffsetY = -3,
                },
                MouseoverHighlight = {
                    Enabled = true,
                    Colour = {1, 1, 1, 0.1},
                    Type = "BACKGROUND",
                },
                RoleIcons = {
                    Enabled = true,
                    Size = 15,
                    AnchorFrom = "TOPRIGHT",
                    AnchorTo = "TOPRIGHT",
                    OffsetX = -3,
                    OffsetY = -3,
                    RoleTextures = "UUFLIGHT",
                },
                ReadyCheck = {
                    Enabled = true,
                    Size = 18,
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                    ReadyCheckTextures = "UUFLIGHT",
                }
            },
            Range = {
                Enabled = true,
                InRange = 1.0,
                OutOfRange = 0.5,
            },
            Tags = {
                AnchorParent = "FRAME",
                First = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                    Tag = "[colour][name:last]",
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                },
                Second = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                    Tag = "",
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                },
                Third = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                    Tag = "",
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                },
                Fourth = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                    Tag = "",
                    FontSize = 12,
                    Colour = {1, 1, 1, 1}
                }
            },
        },
    }
}