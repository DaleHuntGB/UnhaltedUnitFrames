local _, UUF = ...
local LSM = UUF.LSM
local AG = UUF.AG
local GUIWidgets = UUF.GUIWidgets
local UUFGUI = {}
local isGUIOpen = false
-- Stores last selected tabs: [unit] = { mainTab = "CastBar", subTabs = { CastBar = "Bar" } }
local lastSelectedUnitTabs = {}

local function SaveSubTab(unit, tabName, subTabValue)
    if not lastSelectedUnitTabs[unit] then lastSelectedUnitTabs[unit] = {} end
    if not lastSelectedUnitTabs[unit].subTabs then lastSelectedUnitTabs[unit].subTabs = {} end
    lastSelectedUnitTabs[unit].subTabs[tabName] = subTabValue
end

local function GetSavedSubTab(unit, tabName, defaultValue)
    return lastSelectedUnitTabs[unit] and lastSelectedUnitTabs[unit].subTabs and lastSelectedUnitTabs[unit].subTabs[tabName] or defaultValue
end

local function GetSavedMainTab(unit, defaultValue)
    return lastSelectedUnitTabs[unit] and lastSelectedUnitTabs[unit].mainTab or defaultValue
end

local UnitDBToUnitPrettyName = {
    player = "Player",
    target = "Target",
    targettarget = "Target of Target",
    focus = "Focus",
    focustarget = "Focus Target",
    pet = "Pet",
    party = "Party",
    raid = "Raid",
    boss = "Boss",
}
local MainTabToUnit = {
    Player = "player",
    Target = "target",
    TargetTarget = "targettarget",
    Pet = "pet",
    Party = "party",
    Raid = "raid",
    Focus = "focus",
    FocusTarget = "focustarget",
    Boss = "boss",
}
local OrderedUnitKeys = {
    "player",
    "target",
    "targettarget",
    "focus",
    "focustarget",
    "pet",
    "party",
    "raid",
    "boss",
}

local AnchorPoints = { { ["TOPLEFT"] = "Top Left", ["TOP"] = "Top", ["TOPRIGHT"] = "Top Right", ["LEFT"] = "Left", ["CENTER"] = "Center", ["RIGHT"] = "Right", ["BOTTOMLEFT"] = "Bottom Left", ["BOTTOM"] = "Bottom", ["BOTTOMRIGHT"] = "Bottom Right" }, { "TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "CENTER", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT", } }
local FrameStrataList = {{ ["BACKGROUND"] = "Background", ["LOW"] = "Low", ["MEDIUM"] = "Medium", ["HIGH"] = "High", ["DIALOG"] = "Dialog", ["FULLSCREEN"] = "Fullscreen", ["FULLSCREEN_DIALOG"] = "Fullscreen Dialog", ["TOOLTIP"] = "Tooltip" }, { "BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "FULLSCREEN", "FULLSCREEN_DIALOG", "TOOLTIP" }}
local TopBottomList = {{ ["TOP"] = "Top", ["BOTTOM"] = "Bottom" }, { "TOP", "BOTTOM" }}
local RaidGrowthDirectionList = {
    {
        DOWN_RIGHT = "Down & Right",
        DOWN_LEFT  = "Down & Left",
        UP_RIGHT   = "Up & Right",
        UP_LEFT    = "Up & Left",
        RIGHT_DOWN = "Right & Down",
        RIGHT_UP   = "Right & Up",
        LEFT_DOWN  = "Left & Down",
        LEFT_UP    = "Left & Up",
    },
    { "DOWN_RIGHT", "DOWN_LEFT", "UP_RIGHT", "UP_LEFT", "RIGHT_DOWN", "RIGHT_UP", "LEFT_DOWN", "LEFT_UP" }
}
local RaidGroupByList = {
    {
        ROLE = "Role",
        NAME = "Name",
        GROUP = "Group",
        INDEX = "Index",
    },
    { "ROLE", "NAME", "GROUP", "INDEX" }
}
local RaidSortDirectionList = {
    {
        ASC = "Ascending",
        DESC = "Descending",
    },
    { "ASC", "DESC" }
}
local RaidSortMethodList = {
    {
        NAME = "Name",
        INDEX = "Index",
    },
    { "NAME", "INDEX" }
}
local RaidRoleList = {
    {
        TANK = "Tank",
        HEALER = "Healer",
        DAMAGER = "Damager",
    },
    { "TANK", "HEALER", "DAMAGER" }
}
local RaidGroupFilterList = {
    {
        [1] = "Group 1",
        [2] = "Group 2",
        [3] = "Group 3",
        [4] = "Group 4",
        [5] = "Group 5",
        [6] = "Group 6",
        [7] = "Group 7",
        [8] = "Group 8",
    },
    { 1, 2, 3, 4, 5, 6, 7, 8 }
}

local function RaidLayoutUsesRows(direction)
    return direction == "RIGHT_DOWN"
        or direction == "RIGHT_UP"
        or direction == "LEFT_DOWN"
        or direction == "LEFT_UP"
end

local function GetRaidMaxColumnsLabel(direction)
    return RaidLayoutUsesRows(direction) and "Rows" or "Columns"
end

local function ParseRaidGroupFilter(groupFilter)
    local groups = {}
    local seen = {}
    local filterText = type(groupFilter) == "string" and strtrim(groupFilter) or ""

    if filterText ~= "" then
        for groupID in filterText:gmatch("%d+") do
            local groupIndex = tonumber(groupID)
            if groupIndex and groupIndex >= 1 and groupIndex <= UUF.MAX_RAID_GROUPS and not seen[groupIndex] then
                groups[#groups + 1] = groupIndex
                seen[groupIndex] = true
            end
        end
    end

    return groups
end

local function BuildRaidGroupFilterString(groups)
    if type(groups) ~= "table" then
        return ""
    end

    local filteredGroups = {}
    local seen = {}
    for _, groupIndex in ipairs(groups) do
        if groupIndex and groupIndex >= 1 and groupIndex <= UUF.MAX_RAID_GROUPS and not seen[groupIndex] then
            filteredGroups[#filteredGroups + 1] = groupIndex
            seen[groupIndex] = true
        end
    end

    table.sort(filteredGroups)

    if #filteredGroups == 0 or #filteredGroups == UUF.MAX_RAID_GROUPS then
        return ""
    end

    return table.concat(filteredGroups, ",")
end

local function GetAuraBaseFilter(auraDB)
    return auraDB == "Buffs" and "HELPFUL" or "HARMFUL"
end

local function GetAuraFilterConfig(auraDB)
    if not UUF.AURA_FILTERS or type(UUF.AURA_FILTERS[auraDB]) ~= "table" then
        return { Modifiers = {}, Exclusive = {} }
    end
    return UUF.AURA_FILTERS[auraDB]
end

local function GetAuraModifierOrder(auraDB)
    local config = GetAuraFilterConfig(auraDB)
    local modifiers = {}
    if config.Modifiers then
        for modifier in pairs(config.Modifiers) do
            modifiers[#modifiers + 1] = modifier
        end
        table.sort(modifiers, function(a, b)
            local titleA = config.Modifiers[a] and config.Modifiers[a].Title or a
            local titleB = config.Modifiers[b] and config.Modifiers[b].Title or b
            return titleA < titleB
        end)
    end
    return modifiers
end

local function GetAuraExclusiveOrder(auraDB)
    local config = GetAuraFilterConfig(auraDB)
    local exclusive = {}
    if config.Exclusive then
        for filter in pairs(config.Exclusive) do
            exclusive[#exclusive + 1] = filter
        end
        table.sort(exclusive, function(a, b)
            local titleA = config.Exclusive[a] and config.Exclusive[a].Title or a
            local titleB = config.Exclusive[b] and config.Exclusive[b].Title or b
            return titleA < titleB
        end)
    end
    return exclusive
end

local function ParseAuraFilterState(auraDB, filterString)
    local baseFilter = GetAuraBaseFilter(auraDB)
    local config = GetAuraFilterConfig(auraDB)
    local state = { modifiers = {}, exclusive = nil, }
    if type(filterString) ~= "string" then return state end
    local decoded = filterString:gsub("||", "|")
    for part in decoded:gmatch("[^|]+") do
        if part ~= baseFilter then
            if config.Modifiers and config.Modifiers[part] then
                state.modifiers[part] = true
            elseif config.Exclusive and config.Exclusive[part] then
                state.exclusive = part
            end
        end
    end
    return state
end

local function BuildAuraFilterFromState(auraDB, state)
    local baseFilter = GetAuraBaseFilter(auraDB)
    local parts = { baseFilter }
    local added = { [baseFilter] = true }
    local modifierOrder = GetAuraModifierOrder(auraDB)
    for _, modifier in ipairs(modifierOrder) do
        if state.modifiers[modifier] and not added[modifier] then
            parts[#parts + 1] = modifier
            added[modifier] = true
        end
    end
    if state.exclusive and not added[state.exclusive] then parts[#parts + 1] = state.exclusive end
    return table.concat(parts, "|")
end

local function EncodeAuraFilterStringForStorage(filterString)
    if type(filterString) ~= "string" then return "" end
    local decodedFilterString = filterString:gsub("||", "|")
    return decodedFilterString:gsub("|", "||")
end

local Power = {
    [0] = "Mana",
    [1] = "Rage",
    [2] = "Focus",
    [3] = "Energy",
    [4] = "Combo Points",
    [5] = "Runes",
    [6] = "Runic Power",
    [7] = "Soul Shards",
    [8] = "Astral Power",
    [9] = "Holy Power",
    [11] = "Maelstrom",
    [12] = "Chi",
    [13] = "Insanity",
    [17] = "Fury",
    [16] = "Arcange Charges",
    [18] = "Pain",
    [19] = "Essences",
}

local Reaction = {
    [1] = "Hated",
    [2] = "Hostile",
    [3] = "Unfriendly",
    [4] = "Neutral",
    [5] = "Friendly",
    [6] = "Honored",
    [7] = "Revered",
    [8] = "Exalted",
}

local StatusTextures = {
    Combat = {
        ["DEFAULT"] = "|TInterface\\CharacterFrame\\UI-StateIcon:20:20:0:0:64:64:32:64:0:31|t",
        ["COMBAT0"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat0.tga:18:18|t",
        ["COMBAT1"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat1.tga:18:18|t",
        ["COMBAT2"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat2.tga:18:18|t",
        ["COMBAT3"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat3.tga:18:18|t",
        ["COMBAT4"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat4.tga:18:18|t",
        ["COMBAT5"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat5.tga:18:18|t",
        ["COMBAT6"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat6.tga:18:18|t",
        ["COMBAT7"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat7.tga:18:18|t",
        ["COMBAT8"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat8.png:18:18|t",
    },

    Resting = {
        ["DEFAULT"] = "|TInterface\\CharacterFrame\\UI-StateIcon:18:18:0:0:64:64:0:32:0:27|t",
        ["RESTING0"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting0.tga:18:18|t",
        ["RESTING1"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting1.tga:18:18|t",
        ["RESTING2"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting2.tga:18:18|t",
        ["RESTING3"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting3.tga:18:18|t",
        ["RESTING4"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting4.tga:18:18|t",
        ["RESTING5"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting5.tga:18:18|t",
        ["RESTING6"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting6.tga:18:18|t",
        ["RESTING7"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting7.tga:18:18|t",
        ["RESTING8"] = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting8.png:18:18|t",
    }
}

local function EnableAurasTestMode(unit)
    if UUF.AURA_TEST_MODE then return end
    UUF.AURA_TEST_MODE = true
    UUF:ForEachManagedUnitFrame(unit, function(unitFrame, actualUnit)
        UUF:CreateTestAuras(unitFrame, actualUnit)
    end)
end

local function DisableAurasTestMode(unit)
    if not UUF.AURA_TEST_MODE then return end
    UUF.AURA_TEST_MODE = false
    UUF:ForEachManagedUnitFrame(unit, function(unitFrame, actualUnit)
        UUF:CreateTestAuras(unitFrame, actualUnit)
    end)
end

local function EnableCastBarTestMode(unit)
    if UUF.CASTBAR_TEST_MODE then return end
    UUF.CASTBAR_TEST_MODE = true
    UUF:ForEachManagedUnitFrame(unit, function(unitFrame, actualUnit)
        UUF:CreateTestCastBar(unitFrame, actualUnit)
    end)
end

local function DisableCastBarTestMode(unit)
    if not UUF.CASTBAR_TEST_MODE then return end
    UUF.CASTBAR_TEST_MODE = false
    UUF:ForEachManagedUnitFrame(unit, function(unitFrame, actualUnit)
        UUF:CreateTestCastBar(unitFrame, actualUnit)
    end)
end

local function EnableTotemsTestMode(unit)
    if UUF.TOTEM_TEST_MODE then return end
    UUF.TOTEM_TEST_MODE = true
    UUF:ForEachManagedUnitFrame(unit, function(unitFrame, actualUnit)
        UUF:CreateTestTotems(unitFrame, actualUnit)
    end)
end

local function DisableTotemsTestMode(unit)
    if not UUF.TOTEM_TEST_MODE then return end
    UUF.TOTEM_TEST_MODE = false
    UUF:ForEachManagedUnitFrame(unit, function(unitFrame, actualUnit)
        UUF:CreateTestTotems(unitFrame, actualUnit)
    end)
end

local function EnableBossFramesTestMode()
    if UUF.BOSS_TEST_MODE then return end
    UUF.BOSS_TEST_MODE = true
    UUF:CreateTestBossFrames()
end

local function EnablePartyFramesTestMode()
    if UUF.PARTY_TEST_MODE then return end
    UUF.PARTY_TEST_MODE = true
    UUF:CreateTestPartyFrames()
    UUF:UpdatePartyFrames()
end

local function EnableRaidFramesTestMode()
    if UUF.RAID_TEST_MODE then return end
    UUF.RAID_TEST_MODE = true
    UUF:CreateTestRaidFrames()
    UUF:UpdateRaidFrames()
end

local function DisableBossFramesTestMode()
    if not UUF.BOSS_TEST_MODE then return end
    UUF.BOSS_TEST_MODE = false
    UUF:CreateTestBossFrames()
    UUF:UpdateBossFrames()
    UUF:RefreshLiveUnitTags("boss")
    UUFG:UpdateAllTags()
end

local function DisablePartyFramesTestMode()
    if not UUF.PARTY_TEST_MODE then return end
    UUF.PARTY_TEST_MODE = false
    UUF:CreateTestPartyFrames()
    UUF:UpdatePartyFrames()
    UUF:RefreshLiveUnitTags("party")
    UUFG:UpdateAllTags()
end

local function DisableRaidFramesTestMode()
    if not UUF.RAID_TEST_MODE then return end
    UUF.RAID_TEST_MODE = false
    UUF:CreateTestRaidFrames()
    UUF:UpdateRaidFrames()
    UUF:RefreshLiveUnitTags("raid")
    UUFG:UpdateAllTags()
    if UUF.RAID or #UUF.RAID_GROUP_HEADERS > 0 then
        UUF:ToggleUnitFrameVisibility("raid")
    end
end

local function DisableAllTestModes()
    UUF.AURA_TEST_MODE = false
    UUF.CASTBAR_TEST_MODE = false
    UUF.BOSS_TEST_MODE = false
    UUF.PARTY_TEST_MODE = false
    UUF.RAID_TEST_MODE = false
    UUF.TOTEM_TEST_MODE = false
    for unit, _ in pairs(UUF.db.profile.Units) do
        UUF:ForEachManagedUnitFrame(unit, function(unitFrame, actualUnit)
            UUF:CreateTestAuras(unitFrame, actualUnit)
            UUF:CreateTestCastBar(unitFrame, actualUnit)
            UUF:CreateTestTotems(unitFrame, actualUnit)
        end)
    end
    UUF:CreateTestBossFrames()
    UUF:CreateTestPartyFrames()
    UUF:CreateTestRaidFrames()
    UUF:UpdateBossFrames()
    UUF:UpdatePartyFrames()
    UUF:UpdateRaidFrames()
    UUF:RefreshLiveUnitTags("boss")
    UUF:RefreshLiveUnitTags("party")
    UUF:RefreshLiveUnitTags("raid")
    UUFG:UpdateAllTags()
    if UUF.RAID or #UUF.RAID_GROUP_HEADERS > 0 then
        UUF:ToggleUnitFrameVisibility("raid")
    end
end

local function RefreshGroupedTestFrames(unit)
    if unit == "boss" and UUF.BOSS_TEST_MODE then
        UUF:CreateTestBossFrames()
    elseif unit == "party" and UUF.PARTY_TEST_MODE then
        UUF:CreateTestPartyFrames()
    elseif unit == "raid" and UUF.RAID_TEST_MODE then
        UUF:CreateTestRaidFrames()
    end
end

local function IsGroupedTagTestModeActive(unit)
    return (unit == "boss" and UUF.BOSS_TEST_MODE)
        or (unit == "party" and UUF.PARTY_TEST_MODE)
        or (unit == "raid" and UUF.RAID_TEST_MODE)
end

local function UpdateManagedUnitMethod(unit, methodName, ...)
    if not unit or not methodName then return end
    local method = UUF[methodName]
    local args = { ... }
    if type(method) ~= "function" then return end

    if unit == "party" and methodName == "UpdateUnitFrameTags" then
        UUF:UpdatePartyFrames()
        return
    end

    if unit == "raid" and methodName == "UpdateUnitFrameTags" then
        UUF:UpdateRaidFrames()
        return
    end

    if unit == "boss" and methodName == "UpdateUnitFrame" then
        UUF:UpdateBossFrames()
        return
    end

    if unit == "party" and methodName == "UpdateUnitFrame" then
        UUF:UpdatePartyFrames()
        return
    end

    if unit == "raid" and methodName == "UpdateUnitFrame" then
        UUF:UpdateRaidFrames()
        return
    end

    if unit == "boss" or unit == "party" or unit == "raid" then
        UUF:ForEachManagedUnitFrame(unit, function(unitFrame, actualUnit)
            method(UUF, unitFrame, actualUnit, unpack(args))
        end)
        RefreshGroupedTestFrames(unit)
        return
    end

    local unitFrame = UUF[unit:upper()]
    if unitFrame then
        method(UUF, unitFrame, unit, unpack(args))
    end
end

local function GetActiveMainTabUnit()
    local selectedTab = UUFGUI and UUFGUI.MainNavigationStatus and UUFGUI.MainNavigationStatus.selected
    return selectedTab and MainTabToUnit[selectedTab]
end

local function RefreshConfigPreview()
    local activeUnit = GetActiveMainTabUnit()
    if activeUnit then
        UpdateManagedUnitMethod(activeUnit, "UpdateUnitFrame")
        return
    end

    UUF:UpdateAllUnitFrames()
end

local function GenerateSupportText(parentFrame)
    local SupportOptions = {
        "Join the |TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Support\\Discord.png:18:18|t |cFF8080FFDiscord|r Community!",
        "Report Issues / Feedback on |TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Support\\GitHub.png:18:18|t |cFF8080FFGitHub|r!",
        "Follow Me on |TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Support\\Twitch.png:18:14|t |cFF8080FFTwitch|r!",
        "|cFF8080FFSupport|r is truly appreciated |TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Emotes\\peepoLove.png:18:18|t " .. "|cFF8080FFDevelopment|r takes time & effort."
    }
    parentFrame.statustext:SetText(SupportOptions[math.random(1, #SupportOptions)])
end

local function BuildMainNavigationTree()
    return {
        { text = "General", value = "General" },
        { text = "Global", value = "Global" },
        { text = "Player", value = "Player" },
        { text = "Target", value = "Target" },
        { text = "Target of Target", value = "TargetTarget" },
        { text = "Pet", value = "Pet" },
        { text = "Party", value = "Party" },
        { text = "Raid", value = "Raid" },
        { text = "Focus", value = "Focus" },
        { text = "Focus Target", value = "FocusTarget" },
        { text = "Boss", value = "Boss" },
        { text = "Tags", value = "Tags" },
        { text = "Profiles", value = "Profiles" },
    }
end

local function CreateUIScaleSettings(containerParent)
    local Container = GUIWidgets.CreateInlineGroup(containerParent, "UI Scale")
    GUIWidgets.CreateInformationTag(Container,"These options allow you to adjust the UI Scale beyond the means that |cFF00B0F7Blizzard|r provides. If you encounter issues, please |cFFFF4040disable|r this feature.")

    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel("Enable UI Scale")
    Toggle:SetValue(UUF.db.profile.General.UIScale.Enabled)
    Toggle:SetFullWidth(true)
    Toggle:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.General.UIScale.Enabled = value UUF:SetUIScale() GUIWidgets.DeepDisable(Container, not value, Toggle) end)
    Toggle:SetRelativeWidth(0.5)
    Container:AddChild(Toggle)

    local Slider = AG:Create("Slider")
    Slider:SetLabel("UI Scale")
    Slider:SetValue(UUF.db.profile.General.UIScale.Scale)
    Slider:SetSliderValues(0.3, 1.5, 0.01)
    Slider:SetFullWidth(true)
    Slider:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.General.UIScale.Scale = value UUF:SetUIScale() end)
    Slider:SetRelativeWidth(0.5)
    Container:AddChild(Slider)

    GUIWidgets.CreateHeader(Container, "Presets")

    local PixelPerfectButton = AG:Create("Button")
    PixelPerfectButton:SetText("Pixel Perfect Scale")
    PixelPerfectButton:SetRelativeWidth(0.33)
    PixelPerfectButton:SetCallback("OnClick", function() local pixelScale = UUF:GetPixelPerfectScale() UUF.db.profile.General.UIScale.Scale = pixelScale UUF:SetUIScale() Slider:SetValue(pixelScale) end)
    PixelPerfectButton:SetCallback("OnEnter", function() GameTooltip:SetOwner(PixelPerfectButton.frame, "ANCHOR_CURSOR") GameTooltip:AddLine("Recommended UI Scale: |cFF8080FF" .. UUF:GetPixelPerfectScale() .. "|r", 1, 1, 1, false) GameTooltip:Show() end)
    PixelPerfectButton:SetCallback("OnLeave", function() GameTooltip:Hide() end)
    Container:AddChild(PixelPerfectButton)

    local TenEighytyPButton = AG:Create("Button")
    TenEighytyPButton:SetText("1080p Scale")
    TenEighytyPButton:SetRelativeWidth(0.33)
    TenEighytyPButton:SetCallback("OnClick", function() UUF.db.profile.General.UIScale.Scale = 0.7111111111111 UUF:SetUIScale() Slider:SetValue(0.7111111111111) end)
    TenEighytyPButton:SetCallback("OnEnter", function() GameTooltip:SetOwner(TenEighytyPButton.frame, "ANCHOR_CURSOR") GameTooltip:AddLine("UI Scale: |cFF8080FF0.7111111111111|r", 1, 1, 1, false) GameTooltip:Show() end)
    TenEighytyPButton:SetCallback("OnLeave", function() GameTooltip:Hide() end)
    Container:AddChild(TenEighytyPButton)

    local FourteenFortyPButton = AG:Create("Button")
    FourteenFortyPButton:SetText("1440p Scale")
    FourteenFortyPButton:SetRelativeWidth(0.33)
    FourteenFortyPButton:SetCallback("OnClick", function() UUF.db.profile.General.UIScale.Scale = 0.5333333333333 UUF:SetUIScale() Slider:SetValue(0.5333333333333) end)
    FourteenFortyPButton:SetCallback("OnEnter", function() GameTooltip:SetOwner(FourteenFortyPButton.frame, "ANCHOR_CURSOR") GameTooltip:AddLine("UI Scale: |cFF8080FF0.5333333333333|r", 1, 1, 1, false) GameTooltip:Show() end)
    FourteenFortyPButton:SetCallback("OnLeave", function() GameTooltip:Hide() end)
    Container:AddChild(FourteenFortyPButton)

    GUIWidgets.DeepDisable(Container, not UUF.db.profile.General.UIScale.Enabled, Toggle)
end

local function CreateFontSettings(containerParent)
    local Container = GUIWidgets.CreateInlineGroup(containerParent, "Fonts")

    GUIWidgets.CreateInformationTag(Container,"Fonts are applied to all Unit Frames & Elements where appropriate. More fonts can be added via |cFFFFCC00SharedMedia|r.")

    local FontDropdown = AG:Create("LSM30_Font")
    FontDropdown:SetList(LSM:HashTable("font"))
    FontDropdown:SetLabel("Font")
    FontDropdown:SetValue(UUF.db.profile.General.Fonts.Font)
    FontDropdown:SetRelativeWidth(0.5)
    FontDropdown:SetCallback("OnValueChanged", function(widget, _, value) widget:SetValue(value) UUF.db.profile.General.Fonts.Font = value UUF:ResolveLSM() RefreshConfigPreview() end)
    Container:AddChild(FontDropdown)

    local FontFlagDropdown = AG:Create("Dropdown")
    FontFlagDropdown:SetList({["NONE"] = "None", ["OUTLINE"] = "Outline", ["THICKOUTLINE"] = "Thick Outline", ["MONOCHROME"] = "Monochrome", ["MONOCHROMEOUTLINE"] = "Monochrome Outline", ["MONOCHROMETHICKOUTLINE"] = "Monochrome Thick Outline"})
    FontFlagDropdown:SetLabel("Font Flag")
    FontFlagDropdown:SetValue(UUF.db.profile.General.Fonts.FontFlag)
    FontFlagDropdown:SetRelativeWidth(0.5)
    FontFlagDropdown:SetCallback("OnValueChanged", function(widget, _, value) widget:SetValue(value) UUF.db.profile.General.Fonts.FontFlag = value UUF:ResolveLSM() RefreshConfigPreview() end)
    Container:AddChild(FontFlagDropdown)

    local SimpleGroup = AG:Create("SimpleGroup")
    SimpleGroup:SetFullWidth(true)
    SimpleGroup:SetLayout("Flow")
    Container:AddChild(SimpleGroup)

    GUIWidgets.CreateHeader(SimpleGroup, "Font Shadows")

    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel("Enable Font Shadows")
    Toggle:SetValue(UUF.db.profile.General.Fonts.Shadow.Enabled)
    Toggle:SetFullWidth(true)
    Toggle:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.General.Fonts.Shadow.Enabled = value UUF:ResolveLSM() GUIWidgets.DeepDisable(SimpleGroup, not UUF.db.profile.General.Fonts.Shadow.Enabled, Toggle) RefreshConfigPreview() end)
    Toggle:SetRelativeWidth(0.5)
    SimpleGroup:AddChild(Toggle)

    local ColorPicker = AG:Create("ColorPicker")
    ColorPicker:SetLabel("Colour")
    ColorPicker:SetColor(unpack(UUF.db.profile.General.Fonts.Shadow.Colour))
    ColorPicker:SetFullWidth(true)
    ColorPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) UUF.db.profile.General.Fonts.Shadow.Colour = {r, g, b, a} UUF:ResolveLSM() RefreshConfigPreview() end)
    ColorPicker:SetRelativeWidth(0.5)
    SimpleGroup:AddChild(ColorPicker)

    local XSlider = AG:Create("Slider")
    XSlider:SetLabel("Offset X")
    XSlider:SetValue(UUF.db.profile.General.Fonts.Shadow.XPos)
    XSlider:SetSliderValues(-5, 5, 1)
    XSlider:SetFullWidth(true)
    XSlider:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.General.Fonts.Shadow.XPos = value UUF:ResolveLSM() RefreshConfigPreview() end)
    XSlider:SetRelativeWidth(0.5)
    SimpleGroup:AddChild(XSlider)

    local YSlider = AG:Create("Slider")
    YSlider:SetLabel("Offset Y")
    YSlider:SetValue(UUF.db.profile.General.Fonts.Shadow.YPos)
    YSlider:SetSliderValues(-5, 5, 1)
    YSlider:SetFullWidth(true)
    YSlider:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.General.Fonts.Shadow.YPos = value UUF:ResolveLSM() RefreshConfigPreview() end)
    YSlider:SetRelativeWidth(0.5)
    SimpleGroup:AddChild(YSlider)

    GUIWidgets.DeepDisable(SimpleGroup, not UUF.db.profile.General.Fonts.Shadow.Enabled, Toggle)
end

local function CreateTextureSettings(containerParent)
    local Container = GUIWidgets.CreateInlineGroup(containerParent, "Textures")

    GUIWidgets.CreateInformationTag(Container,"Textures are applied to all Unit Frames & Elements where appropriate. More textures can be added via |cFFFFCC00SharedMedia|r.")

    local ForegroundTextureDropdown = AG:Create("LSM30_Statusbar")
    ForegroundTextureDropdown:SetList(LSM:HashTable("statusbar"))
    ForegroundTextureDropdown:SetLabel("Foreground Texture")
    ForegroundTextureDropdown:SetValue(UUF.db.profile.General.Textures.Foreground)
    ForegroundTextureDropdown:SetRelativeWidth(0.5)
    ForegroundTextureDropdown:SetCallback("OnValueChanged", function(widget, _, value) widget:SetValue(value) UUF.db.profile.General.Textures.Foreground = value UUF:ResolveLSM() RefreshConfigPreview() end)
    Container:AddChild(ForegroundTextureDropdown)

    local BackgroundTextureDropdown = AG:Create("LSM30_Statusbar")
    BackgroundTextureDropdown:SetList(LSM:HashTable("statusbar"))
    BackgroundTextureDropdown:SetLabel("Background Texture")
    BackgroundTextureDropdown:SetValue(UUF.db.profile.General.Textures.Background)
    BackgroundTextureDropdown:SetRelativeWidth(0.5)
    BackgroundTextureDropdown:SetCallback("OnValueChanged", function(widget, _, value) widget:SetValue(value) UUF.db.profile.General.Textures.Background = value UUF:ResolveLSM() RefreshConfigPreview() end)
    Container:AddChild(BackgroundTextureDropdown)

    local MouseoverStyleDropdown = AG:Create("Dropdown")
    MouseoverStyleDropdown:SetList({["SELECT"] = "Set a Highlight Texture...", ["BORDER"] = "Border", ["OVERLAY"] = "Overlay", ["GRADIENT"] = "Gradient" })
    MouseoverStyleDropdown:SetLabel("Highlight Style")
    MouseoverStyleDropdown:SetValue("SELECT")
    MouseoverStyleDropdown:SetRelativeWidth(0.5)
    MouseoverStyleDropdown:SetCallback("OnValueChanged", function(_, _, value) for _, unitDB in pairs(UUF.db.profile.Units) do if unitDB.Indicators.Mouseover and unitDB.Indicators.Mouseover.Enabled then unitDB.Indicators.Mouseover.Style = value end end RefreshConfigPreview() MouseoverStyleDropdown:SetValue("SELECT") end)
    MouseoverStyleDropdown:SetCallback("OnEnter", function() GameTooltip:SetOwner(MouseoverStyleDropdown.frame, "ANCHOR_BOTTOM") GameTooltip:AddLine("Set |cFF8080FFMouseover Highlight Style|r for all units. |cFF8080FFColour|r & |cFF8080FFAlpha|r can be adjusted per unit.", 1, 1, 1) GameTooltip:Show() end)
    MouseoverStyleDropdown:SetCallback("OnLeave", function() GameTooltip:Hide() end)
    Container:AddChild(MouseoverStyleDropdown)

    local MouseoverHighlightSlider = AG:Create("Slider")
    MouseoverHighlightSlider:SetLabel("Highlight Opacity")
    MouseoverHighlightSlider:SetValue(0.8)
    MouseoverHighlightSlider:SetSliderValues(0.0, 1.0, 0.01)
    MouseoverHighlightSlider:SetRelativeWidth(0.5)
    MouseoverHighlightSlider:SetIsPercent(true)
    MouseoverHighlightSlider:SetCallback("OnValueChanged", function(_, _, value) for _, unitDB in pairs(UUF.db.profile.Units) do if unitDB.Indicators.Mouseover and unitDB.Indicators.Mouseover.Enabled then unitDB.Indicators.Mouseover.HighlightOpacity = value end end RefreshConfigPreview() end)
    Container:AddChild(MouseoverHighlightSlider)

    local ForegroundColourPicker = AG:Create("ColorPicker")
    ForegroundColourPicker:SetLabel("Foreground Colour")
    local R, G, B = 8/255, 8/255, 8/255
    ForegroundColourPicker:SetColor(R, G, B)
    ForegroundColourPicker:SetRelativeWidth(0.5)
    ForegroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) for _, unitDB in pairs(UUF.db.profile.Units) do unitDB.HealthBar.Foreground = {r, g, b} end RefreshConfigPreview() end)
    Container:AddChild(ForegroundColourPicker)

    local ForegroundOpacitySlider = AG:Create("Slider")
    ForegroundOpacitySlider:SetLabel("Foreground Opacity")
    ForegroundOpacitySlider:SetValue(0.8)
    ForegroundOpacitySlider:SetSliderValues(0.0, 1.0, 0.01)
    ForegroundOpacitySlider:SetRelativeWidth(0.5)
    ForegroundOpacitySlider:SetIsPercent(true)
    ForegroundOpacitySlider:SetCallback("OnValueChanged", function(_, _, value) for _, unitDB in pairs(UUF.db.profile.Units) do unitDB.HealthBar.ForegroundOpacity = value end RefreshConfigPreview() end)
    Container:AddChild(ForegroundOpacitySlider)

    local BackgroundColourPicker = AG:Create("ColorPicker")
    BackgroundColourPicker:SetLabel("Background Colour")
    local R2, G2, B2 = 8/255, 8/255, 8/255
    BackgroundColourPicker:SetColor(R2, G2, B2)
    BackgroundColourPicker:SetRelativeWidth(0.5)
    BackgroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) for _, unitDB in pairs(UUF.db.profile.Units) do unitDB.HealthBar.Background = {r, g, b} end RefreshConfigPreview() end)
    Container:AddChild(BackgroundColourPicker)

    local BackgroundOpacitySlider = AG:Create("Slider")
    BackgroundOpacitySlider:SetLabel("Background Opacity")
    BackgroundOpacitySlider:SetValue(0.8)
    BackgroundOpacitySlider:SetSliderValues(0.0, 1.0, 0.01)
    BackgroundOpacitySlider:SetRelativeWidth(0.5)
    BackgroundOpacitySlider:SetIsPercent(true)
    BackgroundOpacitySlider:SetCallback("OnValueChanged", function(_, _, value) for _, unitDB in pairs(UUF.db.profile.Units) do unitDB.HealthBar.BackgroundOpacity = value end RefreshConfigPreview() end)
    Container:AddChild(BackgroundOpacitySlider)

    local CastBarContainer = GUIWidgets.CreateInlineGroup(Container, "Cast Bar")

    local CastBarForegroundColourPicker = AG:Create("ColorPicker")
    CastBarForegroundColourPicker:SetLabel("Foreground Colour")
    local CR, CG, CB = 128/255, 128/255, 255/255
    CastBarForegroundColourPicker:SetColor(CR, CG, CB)
    CastBarForegroundColourPicker:SetRelativeWidth(0.33)
    CastBarForegroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) for _, unitDB in pairs(UUF.db.profile.Units) do if unitDB.CastBar then unitDB.CastBar.Foreground = {r, g, b} end end RefreshConfigPreview() end)
    CastBarContainer:AddChild(CastBarForegroundColourPicker)

    local CastBarBackgroundColourPicker = AG:Create("ColorPicker")
    CastBarBackgroundColourPicker:SetLabel("Background Colour")
    local CR2, CG2, CB2 = 34/255, 34/255, 34/255
    CastBarBackgroundColourPicker:SetColor(CR2, CG2, CB2)
    CastBarBackgroundColourPicker:SetRelativeWidth(0.33)
    CastBarBackgroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) for _, unitDB in pairs(UUF.db.profile.Units) do if unitDB.CastBar then unitDB.CastBar.Background = {r, g, b} end end RefreshConfigPreview() end)
    CastBarContainer:AddChild(CastBarBackgroundColourPicker)

    local CastBarInterruptibleColourPicker = AG:Create("ColorPicker")
    CastBarInterruptibleColourPicker:SetLabel("Interruptible Colour")
    local CR3, CG3, CB3 = 255/255, 64/255, 64/255
    CastBarInterruptibleColourPicker:SetColor(CR3, CG3, CB3)
    CastBarInterruptibleColourPicker:SetRelativeWidth(0.33)
    CastBarInterruptibleColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) for _, unitDB in pairs(UUF.db.profile.Units) do if unitDB.CastBar then unitDB.CastBar.NotInterruptibleColour = {r, g, b} end end RefreshConfigPreview() end)
    CastBarContainer:AddChild(CastBarInterruptibleColourPicker)
end

local function CreateRangeSettings(containerParent)
    local RangeDB = UUF.db.profile.General.Range
    local Container = GUIWidgets.CreateInlineGroup(containerParent, "Range")

    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel("Enable Range Fading")
    Toggle:SetValue(RangeDB.Enabled)
    Toggle:SetFullWidth(true)
    Toggle:SetCallback("OnValueChanged", function(_, _, value) RangeDB.Enabled = value RefreshConfigPreview() GUIWidgets.DeepDisable(Container, not value, Toggle) end)
    Toggle:SetRelativeWidth(0.33)
    Container:AddChild(Toggle)

    local InAlphaSlider = AG:Create("Slider")
    InAlphaSlider:SetLabel("In Range Alpha")
    InAlphaSlider:SetValue(RangeDB.InRange)
    InAlphaSlider:SetSliderValues(0.0, 1.0, 0.01)
    InAlphaSlider:SetFullWidth(true)
    InAlphaSlider:SetCallback("OnValueChanged", function(_, _, value) RangeDB.InRange = value RefreshConfigPreview() end)
    InAlphaSlider:SetRelativeWidth(0.33)
    InAlphaSlider:SetIsPercent(true)
    Container:AddChild(InAlphaSlider)

    local OutAlphaSlider = AG:Create("Slider")
    OutAlphaSlider:SetLabel("Out of Range Alpha")
    OutAlphaSlider:SetValue(RangeDB.OutOfRange)
    OutAlphaSlider:SetSliderValues(0.0, 1.0, 0.01)
    OutAlphaSlider:SetFullWidth(true)
    OutAlphaSlider:SetCallback("OnValueChanged", function(_, _, value) RangeDB.OutOfRange = value RefreshConfigPreview() end)
    OutAlphaSlider:SetRelativeWidth(0.33)
    OutAlphaSlider:SetIsPercent(true)
    Container:AddChild(OutAlphaSlider)

    GUIWidgets.DeepDisable(Container, not RangeDB.Enabled, Toggle)
end

local function CreateColourSettings(containerParent)
    local Container = GUIWidgets.CreateInlineGroup(containerParent, "Colours")

    GUIWidgets.CreateInformationTag(Container,"Buttons below will reset the colours to their default values as defined by " .. UUF.PRETTY_ADDON_NAME .. ".")

    local ResetAllColoursButton = AG:Create("Button")
    ResetAllColoursButton:SetText("All Colours")
    ResetAllColoursButton:SetCallback("OnClick", function() UUF:CopyTable(UUF:GetDefaultDB().profile.General.Colours, UUF.db.profile.General.Colours) Container:ReleaseChildren() CreateColourSettings(containerParent) Container:DoLayout() containerParent:DoLayout() end)
    ResetAllColoursButton:SetRelativeWidth(1)
    Container:AddChild(ResetAllColoursButton)

    local ResetPowerColoursButton = AG:Create("Button")
    ResetPowerColoursButton:SetText("Power Colours")
    ResetPowerColoursButton:SetCallback("OnClick", function() UUF:CopyTable(UUF:GetDefaultDB().profile.General.Colours.Power, UUF.db.profile.General.Colours.Power) Container:ReleaseChildren() CreateColourSettings(containerParent) Container:DoLayout() containerParent:DoLayout() end)
    ResetPowerColoursButton:SetRelativeWidth(0.25)
    Container:AddChild(ResetPowerColoursButton)

    local ResetSecondaryPowerColoursButton = AG:Create("Button")
    ResetSecondaryPowerColoursButton:SetText("Secondary Power Colours")
    ResetSecondaryPowerColoursButton:SetCallback("OnClick", function() UUF:CopyTable(UUF:GetDefaultDB().profile.General.Colours.SecondaryPower, UUF.db.profile.General.Colours.SecondaryPower) Container:ReleaseChildren() CreateColourSettings(containerParent) Container:DoLayout() containerParent:DoLayout() end)
    ResetSecondaryPowerColoursButton:SetRelativeWidth(0.25)
    Container:AddChild(ResetSecondaryPowerColoursButton)

    local ResetReactionColoursButton = AG:Create("Button")
    ResetReactionColoursButton:SetText("Reaction Colours")
    ResetReactionColoursButton:SetCallback("OnClick", function() UUF:CopyTable(UUF:GetDefaultDB().profile.General.Colours.Reaction, UUF.db.profile.General.Colours.Reaction) Container:ReleaseChildren() CreateColourSettings(containerParent) Container:DoLayout() containerParent:DoLayout() end)
    ResetReactionColoursButton:SetRelativeWidth(0.25)
    Container:AddChild(ResetReactionColoursButton)

    local ResetDispelColoursButton = AG:Create("Button")
    ResetDispelColoursButton:SetText("Dispel Colours")
    ResetDispelColoursButton:SetCallback("OnClick", function() UUF:CopyTable(UUF:GetDefaultDB().profile.General.Colours.Dispel, UUF.db.profile.General.Colours.Dispel) Container:ReleaseChildren() CreateColourSettings(containerParent) Container:DoLayout() containerParent:DoLayout() end)
    ResetDispelColoursButton:SetRelativeWidth(0.25)
    Container:AddChild(ResetDispelColoursButton)

    GUIWidgets.CreateHeader(Container, "Power")

    local PowerOrder = {0, 1, 2, 3, 6, 8, 11, 13, 17, 18}

    for _, powerType in ipairs(PowerOrder) do
        local powerColour = UUF.db.profile.General.Colours.Power[powerType]
        local PowerColourPicker = AG:Create("ColorPicker")
        PowerColourPicker:SetLabel(Power[powerType])
        local R, G, B = unpack(powerColour)
        PowerColourPicker:SetColor(R, G, B)
        PowerColourPicker:SetCallback("OnValueChanged", function(widget, _, r, g, b) UUF.db.profile.General.Colours.Power[powerType] = {r, g, b} UUF:LoadCustomColours() RefreshConfigPreview() end)
        PowerColourPicker:SetHasAlpha(false)
        PowerColourPicker:SetRelativeWidth(0.19)
        Container:AddChild(PowerColourPicker)
    end

    GUIWidgets.CreateHeader(Container, "Secondary Power")

    local SecondaryPowerOrder = {4, 7, 9, 12, 16, 19}

    for _, secondaryPowerType in ipairs(SecondaryPowerOrder) do
        local secondaryPowerColour = UUF.db.profile.General.Colours.SecondaryPower[secondaryPowerType]
        if secondaryPowerColour then
            local SecondaryPowerColourPicker = AG:Create("ColorPicker")
            SecondaryPowerColourPicker:SetLabel(Power[secondaryPowerType])
            local R, G, B = unpack(secondaryPowerColour)
            SecondaryPowerColourPicker:SetColor(R, G, B)
            SecondaryPowerColourPicker:SetCallback("OnValueChanged", function(widget, _, r, g, b) UUF.db.profile.General.Colours.SecondaryPower[secondaryPowerType] = {r, g, b} UUF:LoadCustomColours() RefreshConfigPreview() end)
            SecondaryPowerColourPicker:SetHasAlpha(false)
            SecondaryPowerColourPicker:SetRelativeWidth(0.2)
            Container:AddChild(SecondaryPowerColourPicker)
        end
    end

    GUIWidgets.CreateHeader(Container, "Reaction")

    local ReactionOrder = {1, 2, 3, 4, 5, 6, 7, 8}

    for _, reactionType in ipairs(ReactionOrder) do
        local ReactionColourPicker = AG:Create("ColorPicker")
        ReactionColourPicker:SetLabel(Reaction[reactionType])
        local R, G, B = unpack(UUF.db.profile.General.Colours.Reaction[reactionType])
        ReactionColourPicker:SetColor(R, G, B)
        ReactionColourPicker:SetCallback("OnValueChanged", function(widget, _, r, g, b) UUF.db.profile.General.Colours.Reaction[reactionType] = {r, g, b} UUF:LoadCustomColours() RefreshConfigPreview() end)
        ReactionColourPicker:SetHasAlpha(false)
        ReactionColourPicker:SetRelativeWidth(0.25)
        Container:AddChild(ReactionColourPicker)
    end

    GUIWidgets.CreateHeader(Container, "Dispel Types")

    local DispelTypes = {"Magic", "Curse", "Disease", "Poison", "Bleed"}

    for _, dispelType in ipairs(DispelTypes) do
        local DispelColourPicker = AG:Create("ColorPicker")
        DispelColourPicker:SetLabel(dispelType)
        local R, G, B = unpack(UUF.db.profile.General.Colours.Dispel[dispelType])
        DispelColourPicker:SetColor(R, G, B)
        DispelColourPicker:SetCallback("OnValueChanged", function(widget, _, r, g, b) UUF.db.profile.General.Colours.Dispel[dispelType] = {r, g, b} UUF:LoadCustomColours() RefreshConfigPreview() end)
        DispelColourPicker:SetHasAlpha(false)
        DispelColourPicker:SetRelativeWidth(0.2)
        Container:AddChild(DispelColourPicker)
    end
end

local function CreateRaidFrameSortingSettings(containerParent, frameDB, updateCallback)
    if frameDB.GroupBy == "CLASS" then
        frameDB.GroupBy = "GROUP"
    end

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Raid Layout")

    local HorizontalSpacingSlider = AG:Create("Slider")
    HorizontalSpacingSlider:SetLabel("Horizontal Spacing")
    HorizontalSpacingSlider:SetValue(frameDB.HorizontalSpacing or 0)
    HorizontalSpacingSlider:SetSliderValues(-20, 100, 0.1)
    HorizontalSpacingSlider:SetRelativeWidth(0.25)
    HorizontalSpacingSlider:SetCallback("OnValueChanged", function(_, _, value) frameDB.HorizontalSpacing = value updateCallback() end)
    LayoutContainer:AddChild(HorizontalSpacingSlider)

    local VerticalSpacingSlider = AG:Create("Slider")
    VerticalSpacingSlider:SetLabel("Vertical Spacing")
    VerticalSpacingSlider:SetValue(frameDB.VerticalSpacing or 0)
    VerticalSpacingSlider:SetSliderValues(-20, 100, 0.1)
    VerticalSpacingSlider:SetRelativeWidth(0.25)
    VerticalSpacingSlider:SetCallback("OnValueChanged", function(_, _, value) frameDB.VerticalSpacing = value updateCallback() end)
    LayoutContainer:AddChild(VerticalSpacingSlider)

    local MaxColumnsSlider = AG:Create("Slider")
    local function UpdateMaxColumnsSliderLabel()
        MaxColumnsSlider:SetLabel(GetRaidMaxColumnsLabel(frameDB.GrowthDirection))
    end

    UpdateMaxColumnsSliderLabel()
    MaxColumnsSlider:SetValue(frameDB.MaxColumns or 8)
    MaxColumnsSlider:SetSliderValues(1, 8, 1)
    MaxColumnsSlider:SetRelativeWidth(0.25)
    MaxColumnsSlider:SetCallback("OnValueChanged", function(_, _, value) frameDB.MaxColumns = value updateCallback() end)
    LayoutContainer:AddChild(MaxColumnsSlider)

    local UnitsPerColumnSlider = AG:Create("Slider")
    UnitsPerColumnSlider:SetLabel("Units Per Column")
    UnitsPerColumnSlider:SetValue(frameDB.UnitsPerColumn or 5)
    UnitsPerColumnSlider:SetSliderValues(1, UUF.MAX_RAID_FRAMES, 1)
    UnitsPerColumnSlider:SetRelativeWidth(0.25)
    UnitsPerColumnSlider:SetCallback("OnValueChanged", function(_, _, value) frameDB.UnitsPerColumn = value updateCallback() end)
    LayoutContainer:AddChild(UnitsPerColumnSlider)

    local SortingContainer = GUIWidgets.CreateInlineGroup(containerParent, "Grouping & Sorting")

    local GroupByDropdown = AG:Create("Dropdown")
    GroupByDropdown:SetList(RaidGroupByList[1], RaidGroupByList[2])
    GroupByDropdown:SetLabel("Group By")
    GroupByDropdown:SetValue(frameDB.GroupBy or "GROUP")
    GroupByDropdown:SetRelativeWidth(0.25)
    GroupByDropdown:SetCallback("OnValueChanged", function(_, _, value) frameDB.GroupBy = value updateCallback() end)
    SortingContainer:AddChild(GroupByDropdown)

    local SortDirectionDropdown = AG:Create("Dropdown")
    SortDirectionDropdown:SetList(RaidSortDirectionList[1], RaidSortDirectionList[2])
    SortDirectionDropdown:SetLabel("Sort Direction")
    SortDirectionDropdown:SetValue(frameDB.SortDirection or "ASC")
    SortDirectionDropdown:SetRelativeWidth(0.25)
    SortDirectionDropdown:SetCallback("OnValueChanged", function(_, _, value) frameDB.SortDirection = value updateCallback() end)
    SortingContainer:AddChild(SortDirectionDropdown)

    local SortMethodDropdown = AG:Create("Dropdown")
    SortMethodDropdown:SetList(RaidSortMethodList[1], RaidSortMethodList[2])
    SortMethodDropdown:SetLabel("Sort Method")
    SortMethodDropdown:SetValue(frameDB.SortMethod or "INDEX")
    SortMethodDropdown:SetRelativeWidth(0.25)
    SortMethodDropdown:SetCallback("OnValueChanged", function(_, _, value) frameDB.SortMethod = value updateCallback() end)
    SortingContainer:AddChild(SortMethodDropdown)

    local GroupFilterDropdown = AG:Create("Dropdown")
    local selectedGroupSet = {}
    local initiallySelectedGroups = ParseRaidGroupFilter(frameDB.GroupFilter)

    if #initiallySelectedGroups == 0 then
        for groupIndex = 1, UUF.MAX_RAID_GROUPS do
            selectedGroupSet[groupIndex] = true
        end
    else
        for _, groupIndex in ipairs(initiallySelectedGroups) do
            selectedGroupSet[groupIndex] = true
        end
    end

    GroupFilterDropdown:SetList(RaidGroupFilterList[1], RaidGroupFilterList[2])
    GroupFilterDropdown:SetLabel("Group Filter")
    GroupFilterDropdown:SetMultiselect(true)
    GroupFilterDropdown:SetPulloutWidth(160)
    GroupFilterDropdown:SetRelativeWidth(0.25)
    for groupIndex = 1, UUF.MAX_RAID_GROUPS do
        GroupFilterDropdown:SetItemValue(groupIndex, selectedGroupSet[groupIndex] or false)
    end
    GroupFilterDropdown:SetCallback("OnValueChanged", function(_, _, groupIndex, checked)
        selectedGroupSet[groupIndex] = checked or nil

        local selectedGroups = {}
        for orderedGroupIndex = 1, UUF.MAX_RAID_GROUPS do
            if selectedGroupSet[orderedGroupIndex] then
                selectedGroups[#selectedGroups + 1] = orderedGroupIndex
            end
        end

        frameDB.GroupFilter = BuildRaidGroupFilterString(selectedGroups)
        updateCallback()
    end)
    SortingContainer:AddChild(GroupFilterDropdown)

    GUIWidgets.CreateInformationTag(SortingContainer, "Select the raid groups to show. Selecting all groups, or clearing every selection, shows every group.")

    local RoleOrderContainer = GUIWidgets.CreateInlineGroup(containerParent, "Role Order")
    for index = 1, 3 do
        local RoleDropdown = AG:Create("Dropdown")
        RoleDropdown:SetList(RaidRoleList[1], RaidRoleList[2])
        RoleDropdown:SetLabel("Role " .. index)
        RoleDropdown:SetValue(frameDB.RoleOrder and frameDB.RoleOrder[index] or RaidRoleList[2][index])
        RoleDropdown:SetRelativeWidth(0.33)
        RoleDropdown:SetCallback("OnValueChanged", function(_, _, value)
            frameDB.RoleOrder = frameDB.RoleOrder or {}
            frameDB.RoleOrder[index] = value
            updateCallback()
        end)
        RoleOrderContainer:AddChild(RoleDropdown)
    end

    return UpdateMaxColumnsSliderLabel
end

local function GetAffectedUnitsText(affectedUnits)
    if type(affectedUnits) ~= "table" or #affectedUnits == 0 then
        return nil
    end

    local prettyNames = {}
    for _, unit in ipairs(affectedUnits) do
        prettyNames[#prettyNames + 1] = UnitDBToUnitPrettyName[unit] or unit
    end

    return "Affects: " .. table.concat(prettyNames, ", ")
end

local function AddAffectsTooltip(widget, affectedUnits)
    local affectedUnitsText = GetAffectedUnitsText(affectedUnits)
    if not affectedUnitsText then return end
    widget:SetCallback("OnEnter", function()
        GameTooltip:SetOwner(widget.frame, "ANCHOR_CURSOR")
        GameTooltip:AddLine(affectedUnitsText, 0.5, 0.7, 1, true)
        GameTooltip:Show()
    end)
    widget:SetCallback("OnLeave", function()
        GameTooltip:Hide()
    end)
end

local function GetUnitsWithSubDatabase(subKey, predicate)
    local units = {}

    for _, unit in ipairs(OrderedUnitKeys) do
        local unitDB = UUF.db.profile.Units[unit]
        if unitDB and unitDB[subKey] and (not predicate or predicate(unit, unitDB[subKey], unitDB)) then
            units[#units + 1] = unit
        end
    end

    return units
end

local function CreateDescribedToggle(containerParent, label, description, value, onValueChanged, relativeWidth, affectedUnits)
    local toggleGroup = AG:Create("SimpleGroup")
    toggleGroup:SetRelativeWidth(relativeWidth or 0.5)
    toggleGroup:SetLayout("Flow")
    containerParent:AddChild(toggleGroup)

    local toggle = AG:Create("CheckBox")
    toggle:SetDescription(description)
    toggle:SetLabel(label)
    toggle:SetValue(value)
    toggle:SetRelativeWidth(1)
    toggle:SetCallback("OnValueChanged", onValueChanged)
    toggleGroup:AddChild(toggle)

    local affectedUnitsText = GetAffectedUnitsText(affectedUnits)
    local descriptionText = "|cFF9A9A9A" .. description .. "|r"
    if affectedUnitsText then
        descriptionText = descriptionText .. "\n|cFF7FB2FF" .. affectedUnitsText .. "|r"

        toggle:SetCallback("OnEnter", function()
            GameTooltip:SetOwner(toggle.frame, "ANCHOR_CURSOR")
            GameTooltip:AddLine(affectedUnitsText, 0.5, 0.7, 1, true)
            GameTooltip:Show()
        end)
        toggle:SetCallback("OnLeave", function()
            GameTooltip:Hide()
        end)
    end

    return toggle
end

local function PromptReload(onAccept, onCancel)
    StaticPopupDialogs["UUF_RELOAD_UI"] = {
        text = "You must reload to apply this change, do you want to reload now?",
        button1 = "Reload Now",
        button2 = "Later",
        showAlert = true,
        OnAccept = function()
            if onAccept then
                onAccept()
            end
            C_UI.Reload()
        end,
        OnCancel = function()
            if onCancel then
                onCancel()
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    StaticPopup_Show("UUF_RELOAD_UI")
end

local function CreateFrameSettings(containerParent, unit, unitHasParent, updateCallback)
    local FrameDB = UUF.db.profile.Units[unit].Frame
    local HealthBarDB = UUF.db.profile.Units[unit].HealthBar
    local isRaidUnit = unit == "raid"
    local isGroupedUnit = unit == "boss" or unit == "party" or isRaidUnit
    local ForegroundColourPicker
    local BackgroundColourPicker
    local UpdateRaidMaxColumnsSliderLabel = function() end

    local MoversToggleButton = AG:Create("Button")
    MoversToggleButton:SetText(UUF:IsMoversUnlocked() and "Lock Movers" or "Unlock Movers")
    MoversToggleButton:SetRelativeWidth(1)
    MoversToggleButton:SetCallback("OnClick", function(widget)
        UUF:ToggleMovers(false)
        widget:SetText(UUF:IsMoversUnlocked() and "Lock Movers" or "Unlock Movers")
    end)
    containerParent:AddChild(MoversToggleButton)

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Layout & Positioning")

    local WidthSlider = AG:Create("Slider")
    WidthSlider:SetLabel("Width")
    WidthSlider:SetValue(FrameDB.Width)
    WidthSlider:SetSliderValues(1, 1000, 0.1)
    WidthSlider:SetRelativeWidth(0.5)
    WidthSlider:SetCallback("OnValueChanged", function(_, _, value) FrameDB.Width = value updateCallback() end)
    LayoutContainer:AddChild(WidthSlider)

    local HeightSlider = AG:Create("Slider")
    HeightSlider:SetLabel("Height")
    HeightSlider:SetValue(FrameDB.Height)
    HeightSlider:SetSliderValues(1, 1000, 0.1)
    HeightSlider:SetRelativeWidth(0.5)
    HeightSlider:SetCallback("OnValueChanged", function(_, _, value) FrameDB.Height = value updateCallback() end)
    LayoutContainer:AddChild(HeightSlider)

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(FrameDB.Layout[1])
    AnchorFromDropdown:SetRelativeWidth((unitHasParent or isGroupedUnit) and 0.33 or 0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) FrameDB.Layout[1] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorFromDropdown)

    if unitHasParent then
        local AnchorParentEditBox = AG:Create("EditBox")
        AnchorParentEditBox:SetLabel("Anchor Parent")
        AnchorParentEditBox:SetText(FrameDB.AnchorParent or "")
        AnchorParentEditBox:SetRelativeWidth(0.33)
        AnchorParentEditBox:DisableButton(true)
        AnchorParentEditBox:SetCallback("OnEnterPressed", function(_, _, value) FrameDB.AnchorParent = value ~= "" and value or nil AnchorParentEditBox:SetText(FrameDB.AnchorParent or "") updateCallback() end)
        LayoutContainer:AddChild(AnchorParentEditBox)
    end

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(FrameDB.Layout[2])
    AnchorToDropdown:SetRelativeWidth((unitHasParent or isGroupedUnit) and 0.33 or 0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) FrameDB.Layout[2] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorToDropdown)

    if unit == "boss" or unit == "party" then
        local GrowthDirectionDropdown = AG:Create("Dropdown")
        GrowthDirectionDropdown:SetList({["UP"] = "Up", ["DOWN"] = "Down"})
        GrowthDirectionDropdown:SetLabel("Growth Direction")
        GrowthDirectionDropdown:SetValue(FrameDB.GrowthDirection)
        GrowthDirectionDropdown:SetRelativeWidth(0.33)
        GrowthDirectionDropdown:SetCallback("OnValueChanged", function(_, _, value) FrameDB.GrowthDirection = value updateCallback() end)
        LayoutContainer:AddChild(GrowthDirectionDropdown)
    elseif isRaidUnit then
        local GrowthDirectionDropdown = AG:Create("Dropdown")
        GrowthDirectionDropdown:SetList(RaidGrowthDirectionList[1], RaidGrowthDirectionList[2])
        GrowthDirectionDropdown:SetLabel("Raid Layout")
        GrowthDirectionDropdown:SetValue(FrameDB.GrowthDirection)
        GrowthDirectionDropdown:SetRelativeWidth(0.33)
        GrowthDirectionDropdown:SetCallback("OnValueChanged", function(_, _, value)
            FrameDB.GrowthDirection = value
            UpdateRaidMaxColumnsSliderLabel()
            updateCallback()
        end)
        LayoutContainer:AddChild(GrowthDirectionDropdown)

        GUIWidgets.CreateInformationTag(LayoutContainer, "The first direction controls how frames fill inside each group. The second direction controls where the next group appears.")
    end

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(FrameDB.Layout[3])
    XPosSlider:SetSliderValues(-1000, 1000, 0.1)
    XPosSlider:SetRelativeWidth((unit == "boss" or unit == "party") and 0.25 or 0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) FrameDB.Layout[3] = value updateCallback() end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(FrameDB.Layout[4])
    YPosSlider:SetSliderValues(-1000, 1000, 0.1)
    YPosSlider:SetRelativeWidth((unit == "boss" or unit == "party") and 0.25 or 0.33)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) FrameDB.Layout[4] = value updateCallback() end)
    LayoutContainer:AddChild(YPosSlider)

    if unit == "boss" or unit == "party" then
        local SpacingSlider = AG:Create("Slider")
        SpacingSlider:SetLabel("Frame Spacing")
        SpacingSlider:SetValue(FrameDB.Layout[5])
        SpacingSlider:SetSliderValues(-1, 100, 0.1)
        SpacingSlider:SetRelativeWidth(0.25)
        SpacingSlider:SetCallback("OnValueChanged", function(_, _, value) FrameDB.Layout[5] = value updateCallback() end)
        LayoutContainer:AddChild(SpacingSlider)
    end

    local FrameStrataDropdown = AG:Create("Dropdown")
    FrameStrataDropdown:SetList(FrameStrataList[1], FrameStrataList[2])
    FrameStrataDropdown:SetLabel("Frame Strata")
    FrameStrataDropdown:SetValue(FrameDB.FrameStrata)
    FrameStrataDropdown:SetRelativeWidth((unit == "boss" or unit == "party") and 0.25 or 0.33)
    FrameStrataDropdown:SetCallback("OnValueChanged", function(_, _, value) FrameDB.FrameStrata = value updateCallback() end)
    LayoutContainer:AddChild(FrameStrataDropdown)

    if isRaidUnit then
        UpdateRaidMaxColumnsSliderLabel = CreateRaidFrameSortingSettings(containerParent, FrameDB, updateCallback)
    end

    local function RefreshFrameColourSettings()
        if ForegroundColourPicker then
            ForegroundColourPicker:SetDisabled(HealthBarDB.ColourByClass)
        end

        if BackgroundColourPicker then
            BackgroundColourPicker:SetDisabled(HealthBarDB.ColourBackgroundByClass)
        end
    end

    local TogglesContainer = GUIWidgets.CreateInlineGroup(containerParent, "Frame Toggles")

    CreateDescribedToggle(
        TogglesContainer,
        "Foreground Colour by Class / Reaction",
        "Automatically colors the main health bar from class or reaction instead of the custom foreground color.",
        HealthBarDB.ColourByClass,
        function(_, _, value)
            HealthBarDB.ColourByClass = value
            RefreshFrameColourSettings()
            updateCallback()
        end
    )

    CreateDescribedToggle(
        TogglesContainer,
        "Background Colour by Class / Reaction",
        "Automatically colors the missing-health background from class or reaction instead of the custom background color.",
        HealthBarDB.ColourBackgroundByClass,
        function(_, _, value)
            HealthBarDB.ColourBackgroundByClass = value
            RefreshFrameColourSettings()
            updateCallback()
        end
    )

    CreateDescribedToggle(
        TogglesContainer,
        "Smoothing",
        "Animates health and missing-health changes instead of snapping instantly.",
        HealthBarDB.Smoothing,
        function(_, _, value)
            HealthBarDB.Smoothing = value
            updateCallback()
        end
    )

    CreateDescribedToggle(
        TogglesContainer,
        "Inverse Growth Direction",
        "Reverses which side of the frame the health fill grows from.",
        HealthBarDB.Inverse,
        function(_, _, value)
            HealthBarDB.Inverse = value
            updateCallback()
        end
    )

    if unit ~= "party" and unit ~= "raid" then
        CreateDescribedToggle(
            TogglesContainer,
            "Colour When Tapped",
            "Uses tapped coloring when a hostile NPC is not tappable by you.",
            HealthBarDB.ColourWhenTapped,
            function(_, _, value)
                HealthBarDB.ColourWhenTapped = value
                updateCallback()
            end
        )
    end

    if unit == "party" then
        local ShowPlayerToggle
        ShowPlayerToggle = CreateDescribedToggle(
            TogglesContainer,
            "Show Player In Party Frames",
            "Adds your player unit to the party header. This requires a reload because the secure party header must be rebuilt.",
            UUF.db.profile.Units.party.ShowPlayer,
            function(_, _, value)
                PromptReload(
                    function()
                        UUF.db.profile.Units.party.ShowPlayer = value
                    end,
                    function()
                        ShowPlayerToggle:SetValue(UUF.db.profile.Units.party.ShowPlayer)
                    end
                )
            end
        )
    end

    if unit == "player" or unit == "target" then
        local AnchorToCooldownViewerToggle = CreateDescribedToggle(
            TogglesContainer,
            "Anchor To Cooldown Viewer",
            "Anchors the frame to Essential Cooldown Viewer and resets this frame's layout while enabled.",
            HealthBarDB.AnchorToCooldownViewer,
            function(_, _, value)
                HealthBarDB.AnchorToCooldownViewer = value
                if not value then
                    FrameDB.Layout[1] = UUF:GetDefaultDB().profile.Units[unit].Frame.Layout[1]
                    FrameDB.Layout[2] = UUF:GetDefaultDB().profile.Units[unit].Frame.Layout[2]
                    FrameDB.Layout[3] = UUF:GetDefaultDB().profile.Units[unit].Frame.Layout[3]
                    FrameDB.Layout[4] = UUF:GetDefaultDB().profile.Units[unit].Frame.Layout[4]
                    AnchorFromDropdown:SetValue(FrameDB.Layout[1])
                    AnchorToDropdown:SetValue(FrameDB.Layout[2])
                    XPosSlider:SetValue(FrameDB.Layout[3])
                    YPosSlider:SetValue(FrameDB.Layout[4])
                else
                    if unit == "player" then
                        FrameDB.Layout[1] = "RIGHT"
                        FrameDB.Layout[2] = "LEFT"
                        FrameDB.Layout[3] = 0
                        FrameDB.Layout[4] = 0
                        AnchorFromDropdown:SetValue(FrameDB.Layout[1])
                        AnchorToDropdown:SetValue(FrameDB.Layout[2])
                        XPosSlider:SetValue(FrameDB.Layout[3])
                        YPosSlider:SetValue(FrameDB.Layout[4])
                    elseif unit == "target" then
                        FrameDB.Layout[1] = "LEFT"
                        FrameDB.Layout[2] = "RIGHT"
                        FrameDB.Layout[3] = 0
                        FrameDB.Layout[4] = 0
                        AnchorFromDropdown:SetValue(FrameDB.Layout[1])
                        AnchorToDropdown:SetValue(FrameDB.Layout[2])
                        XPosSlider:SetValue(FrameDB.Layout[3])
                        YPosSlider:SetValue(FrameDB.Layout[4])
                    end
                end
                updateCallback()
            end
        )
        AnchorToCooldownViewerToggle:SetCallback("OnEnter", function() GameTooltip:SetOwner(AnchorToCooldownViewerToggle.frame, "ANCHOR_CURSOR") GameTooltip:AddLine("Anchor To |cFF8080FFEssential|r Cooldown Viewer. Toggling this will overwrite existing |cFF8080FFLayout|r Settings.", 1, 1, 1, false) GameTooltip:Show() end)
        AnchorToCooldownViewerToggle:SetCallback("OnLeave", function() GameTooltip:Hide() end)
    end

    local ColourContainer = GUIWidgets.CreateInlineGroup(containerParent, "Colours")

    GUIWidgets.CreateInformationTag(ColourContainer, "Foreground and background opacity can be set using the sliders below.")

    local DeadBackgroundColourPicker
    local function RefreshDeadBackgroundSettings()
        if DeadBackgroundColourPicker then
            DeadBackgroundColourPicker:SetDisabled(HealthBarDB.UseDeadBackground == false)
        end
    end

    ForegroundColourPicker = AG:Create("ColorPicker")
    ForegroundColourPicker:SetLabel("Foreground Colour")
    local R, G, B = unpack(HealthBarDB.Foreground)
    ForegroundColourPicker:SetColor(R, G, B)
    ForegroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b) HealthBarDB.Foreground = {r, g, b} updateCallback() end)
    ForegroundColourPicker:SetHasAlpha(false)
    ForegroundColourPicker:SetRelativeWidth(0.25)
    ColourContainer:AddChild(ForegroundColourPicker)

    BackgroundColourPicker = AG:Create("ColorPicker")
    BackgroundColourPicker:SetLabel("Background Colour")
    local R2, G2, B2 = unpack(HealthBarDB.Background)
    BackgroundColourPicker:SetColor(R2, G2, B2)
    BackgroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b) HealthBarDB.Background = {r, g, b} updateCallback() end)
    BackgroundColourPicker:SetHasAlpha(false)
    BackgroundColourPicker:SetRelativeWidth(0.25)
    ColourContainer:AddChild(BackgroundColourPicker)

    CreateDescribedToggle(
        ColourContainer,
        "Use Dead Background",
        "",
        HealthBarDB.UseDeadBackground ~= false,
        function(_, _, value)
            HealthBarDB.UseDeadBackground = value
            RefreshDeadBackgroundSettings()
            updateCallback()
        end,
        0.25
    )

    DeadBackgroundColourPicker = AG:Create("ColorPicker")
    DeadBackgroundColourPicker:SetLabel("Dead Background Colour")
    local DR, DG, DB = unpack(HealthBarDB.DeadBackground or HealthBarDB.Background)
    DeadBackgroundColourPicker:SetColor(DR, DG, DB)
    DeadBackgroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b) HealthBarDB.DeadBackground = {r, g, b} updateCallback() end)
    DeadBackgroundColourPicker:SetHasAlpha(false)
    DeadBackgroundColourPicker:SetRelativeWidth(0.25)
    ColourContainer:AddChild(DeadBackgroundColourPicker)
    RefreshDeadBackgroundSettings()

    local ForegroundOpacitySlider = AG:Create("Slider")
    ForegroundOpacitySlider:SetLabel("Foreground Opacity")
    ForegroundOpacitySlider:SetValue(HealthBarDB.ForegroundOpacity)
    ForegroundOpacitySlider:SetSliderValues(0, 1, 0.01)
    ForegroundOpacitySlider:SetRelativeWidth(0.5)
    ForegroundOpacitySlider:SetCallback("OnValueChanged", function(_, _, value) HealthBarDB.ForegroundOpacity = value updateCallback() end)
    ForegroundOpacitySlider:SetIsPercent(true)
    ColourContainer:AddChild(ForegroundOpacitySlider)

    local BackgroundOpacitySlider = AG:Create("Slider")
    BackgroundOpacitySlider:SetLabel("Background Opacity")
    BackgroundOpacitySlider:SetValue(HealthBarDB.BackgroundOpacity)
    BackgroundOpacitySlider:SetSliderValues(0, 1, 0.01)
    BackgroundOpacitySlider:SetRelativeWidth(0.5)
    BackgroundOpacitySlider:SetCallback("OnValueChanged", function(_, _, value) HealthBarDB.BackgroundOpacity = value updateCallback() end)
    BackgroundOpacitySlider:SetIsPercent(true)
    ColourContainer:AddChild(BackgroundOpacitySlider)

    RefreshFrameColourSettings()

    if HealthBarDB.DispelHighlight then
        local DispelHighlightContainer = GUIWidgets.CreateInlineGroup(containerParent, "Dispel Highlighting")

        local EnableDispelHighlightingToggle = AG:Create("CheckBox")
        EnableDispelHighlightingToggle:SetLabel("Enable Dispel Highlighting")
        EnableDispelHighlightingToggle:SetValue(HealthBarDB.DispelHighlight.Enabled)
        EnableDispelHighlightingToggle:SetRelativeWidth(0.5)
        EnableDispelHighlightingToggle:SetCallback("OnValueChanged", function(_, _, value) HealthBarDB.DispelHighlight.Enabled = value updateCallback() end)
        DispelHighlightContainer:AddChild(EnableDispelHighlightingToggle)

        local DispelHighlightStyleDropdown = AG:Create("Dropdown")
        DispelHighlightStyleDropdown:SetList({["HEALTHBAR"] = "Health Bar", ["GRADIENT"] = "Gradient" })
        DispelHighlightStyleDropdown:SetLabel("Highlight Style")
        DispelHighlightStyleDropdown:SetValue(HealthBarDB.DispelHighlight.Style)
        DispelHighlightStyleDropdown:SetRelativeWidth(0.5)
        DispelHighlightStyleDropdown:SetCallback("OnValueChanged", function(_, _, value) HealthBarDB.DispelHighlight.Style = value updateCallback() end)
        DispelHighlightContainer:AddChild(DispelHighlightStyleDropdown)
    end
end

local function CreateHealPredictionSettings(containerParent, unit, updateCallback)
    local FrameDB = UUF.db.profile.Units[unit].Frame
    local HealPredictionDB = UUF.db.profile.Units[unit].HealPrediction
    local positionLabels = {
        ["TOPLEFT"] = "Top Left",
        ["TOPRIGHT"] = "Top Right",
        ["BOTTOMLEFT"] = "Bottom Left",
        ["BOTTOMRIGHT"] = "Bottom Right",
        ["LEFT"] = "Left",
        ["RIGHT"] = "Right",
        ["ATTACH"] = "Attach To Missing Health",
    }
    local positionOrder = {"TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT", "LEFT", "RIGHT", "ATTACH"}
    local sections = {}

    local function CreatePredictionSection(title, db, showLabel, colourLabel)
        local settings = GUIWidgets.CreateInlineGroup(containerParent, title)

        local showToggle = AG:Create("CheckBox")
        showToggle:SetLabel(showLabel)
        showToggle:SetValue(db.Enabled)
        showToggle:SetCallback("OnValueChanged", function(_, _, value) db.Enabled = value updateCallback() RefreshHealPredictionSettings() end)
        showToggle:SetRelativeWidth(0.33)
        settings:AddChild(showToggle)

        local stripedToggle = AG:Create("CheckBox")
        stripedToggle:SetLabel("Use Striped Texture")
        stripedToggle:SetValue(db.UseStripedTexture)
        stripedToggle:SetCallback("OnValueChanged", function(_, _, value) db.UseStripedTexture = value updateCallback() end)
        stripedToggle:SetRelativeWidth(0.33)
        settings:AddChild(stripedToggle)

        local matchParentHeightToggle = AG:Create("CheckBox")
        matchParentHeightToggle:SetLabel("Match Parent Height")
        matchParentHeightToggle:SetValue(db.MatchParentHeight)
        matchParentHeightToggle:SetCallback("OnValueChanged", function(_, _, value) db.MatchParentHeight = value updateCallback() RefreshHealPredictionSettings() end)
        matchParentHeightToggle:SetRelativeWidth(0.33)
        settings:AddChild(matchParentHeightToggle)

        local colourPicker = AG:Create("ColorPicker")
        colourPicker:SetLabel(colourLabel)
        local r, g, b, a = unpack(db.Colour)
        colourPicker:SetColor(r, g, b, a)
        colourPicker:SetCallback("OnValueChanged", function(_, _, newR, newG, newB, newA) db.Colour = {newR, newG, newB, newA} updateCallback() end)
        colourPicker:SetHasAlpha(true)
        colourPicker:SetRelativeWidth(0.33)
        settings:AddChild(colourPicker)

        local heightSlider = AG:Create("Slider")
        heightSlider:SetLabel("Height")
        heightSlider:SetValue(db.Height)
        heightSlider:SetSliderValues(1, FrameDB.Height - 2, 0.1)
        heightSlider:SetRelativeWidth(0.33)
        heightSlider:SetCallback("OnValueChanged", function(_, _, value) db.Height = value updateCallback() end)
        heightSlider:SetDisabled(db.MatchParentHeight or db.Position == "ATTACH")
        settings:AddChild(heightSlider)

        local positionDropdown = AG:Create("Dropdown")
        positionDropdown:SetList(positionLabels, positionOrder)
        positionDropdown:SetLabel("Position")
        positionDropdown:SetValue(db.Position)
        positionDropdown:SetRelativeWidth(0.33)
        positionDropdown:SetCallback("OnValueChanged", function(_, _, value) db.Position = value updateCallback() RefreshHealPredictionSettings() end)
        settings:AddChild(positionDropdown)

        sections[#sections + 1] = {
            container = settings,
            toggle = showToggle,
            heightSlider = heightSlider,
            db = db,
        }
    end

    CreatePredictionSection("Incoming Heal Settings", HealPredictionDB.IncomingHeals, "Show Incoming Heals", "Incoming Heal Colour")
    CreatePredictionSection("Absorb Settings", HealPredictionDB.Absorbs, "Show Absorbs", "Absorb Colour")
    CreatePredictionSection("Heal Absorb Settings", HealPredictionDB.HealAbsorbs, "Show Heal Absorbs", "Heal Absorb Colour")

    function RefreshHealPredictionSettings()
        for _, section in ipairs(sections) do
            GUIWidgets.DeepDisable(section.container, not section.db.Enabled, section.toggle)
            section.heightSlider:SetDisabled(section.db.MatchParentHeight or section.db.Position == "ATTACH")
        end
    end

    RefreshHealPredictionSettings()
end

local function CreateCastBarBarSettings(containerParent, unit, updateCallback)
    local FrameDB = UUF.db.profile.Units[unit].Frame
    local CastBarDB = UUF.db.profile.Units[unit].CastBar

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Cast Bar Settings")

    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel("Enable |cFF8080FFCast Bar|r")
    Toggle:SetValue(CastBarDB.Enabled)
    Toggle:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.Enabled = value updateCallback() RefreshCastBarBarSettings() end)
    Toggle:SetRelativeWidth(0.33)
    LayoutContainer:AddChild(Toggle)

    local MatchParentWidthToggle = AG:Create("CheckBox")
    MatchParentWidthToggle:SetLabel("Match Frame Width")
    MatchParentWidthToggle:SetValue(CastBarDB.MatchParentWidth)
    MatchParentWidthToggle:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.MatchParentWidth = value updateCallback() RefreshCastBarBarSettings() end)
    MatchParentWidthToggle:SetRelativeWidth(0.33)
    LayoutContainer:AddChild(MatchParentWidthToggle)

    local InverseGrowthDirectionToggle = AG:Create("CheckBox")
    InverseGrowthDirectionToggle:SetLabel("Inverse Growth Direction")
    InverseGrowthDirectionToggle:SetValue(CastBarDB.Inverse)
    InverseGrowthDirectionToggle:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.Inverse = value updateCallback() end)
    InverseGrowthDirectionToggle:SetRelativeWidth(0.33)
    LayoutContainer:AddChild(InverseGrowthDirectionToggle)

    local WidthSlider = AG:Create("Slider")
    WidthSlider:SetLabel("Width")
    WidthSlider:SetValue(CastBarDB.Width)
    WidthSlider:SetSliderValues(1, 1000, 0.1)
    WidthSlider:SetRelativeWidth(0.5)
    WidthSlider:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.Width = value updateCallback() end)
    LayoutContainer:AddChild(WidthSlider)

    local HeightSlider = AG:Create("Slider")
    HeightSlider:SetLabel("Height")
    HeightSlider:SetValue(CastBarDB.Height)
    HeightSlider:SetSliderValues(1, 1000, 0.1)
    HeightSlider:SetRelativeWidth(0.5)
    HeightSlider:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.Height = value updateCallback() end)
    LayoutContainer:AddChild(HeightSlider)

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(CastBarDB.Layout[1])
    AnchorFromDropdown:SetRelativeWidth(0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.Layout[1] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(CastBarDB.Layout[2])
    AnchorToDropdown:SetRelativeWidth(0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.Layout[2] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorToDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(CastBarDB.Layout[3])
    XPosSlider:SetSliderValues(-1000, 1000, 0.1)
    XPosSlider:SetRelativeWidth(0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.Layout[3] = value updateCallback() end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(CastBarDB.Layout[4])
    YPosSlider:SetSliderValues(-1000, 1000, 0.1)
    YPosSlider:SetRelativeWidth(0.33)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.Layout[4] = value updateCallback() end)
    LayoutContainer:AddChild(YPosSlider)

    local FrameStrataDropdown = AG:Create("Dropdown")
    FrameStrataDropdown:SetList(FrameStrataList[1], FrameStrataList[2])
    FrameStrataDropdown:SetLabel("Frame Strata")
    FrameStrataDropdown:SetValue(CastBarDB.FrameStrata)
    FrameStrataDropdown:SetRelativeWidth(0.33)
    FrameStrataDropdown:SetCallback("OnValueChanged", function(_, _, value) CastBarDB.FrameStrata = value updateCallback() end)
    LayoutContainer:AddChild(FrameStrataDropdown)

    local ColourContainer = GUIWidgets.CreateInlineGroup(containerParent, "Colours & Toggles")

    local ForegroundColourPicker = AG:Create("ColorPicker")
    ForegroundColourPicker:SetLabel("Foreground")
    local R, G, B, A = unpack(CastBarDB.Foreground)
    ForegroundColourPicker:SetColor(R, G, B, A)
    ForegroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) CastBarDB.Foreground = {r, g, b, a} updateCallback() end)
    ForegroundColourPicker:SetHasAlpha(true)
    ForegroundColourPicker:SetRelativeWidth(0.33)
    ColourContainer:AddChild(ForegroundColourPicker)

    local BackgroundColourPicker = AG:Create("ColorPicker")
    BackgroundColourPicker:SetLabel("Background")
    local R2, G2, B2, A2 = unpack(CastBarDB.Background)
    BackgroundColourPicker:SetColor(R2, G2, B2, A2)
    BackgroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) CastBarDB.Background = {r, g, b, a} updateCallback() end)
    BackgroundColourPicker:SetHasAlpha(true)
    BackgroundColourPicker:SetRelativeWidth(0.33)
    ColourContainer:AddChild(BackgroundColourPicker)

    local NotInterruptibleColourPicker = AG:Create("ColorPicker")
    NotInterruptibleColourPicker:SetLabel("Not Interruptible")
    local R3, G3, B3 = unpack(CastBarDB.NotInterruptibleColour)
    NotInterruptibleColourPicker:SetColor(R3, G3, B3)
    NotInterruptibleColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) CastBarDB.NotInterruptibleColour = {r, g, b, a} updateCallback() end)
    NotInterruptibleColourPicker:SetHasAlpha(true)
    NotInterruptibleColourPicker:SetRelativeWidth(0.33)
    ColourContainer:AddChild(NotInterruptibleColourPicker)

    function RefreshCastBarBarSettings()
        if CastBarDB.Enabled then
            MatchParentWidthToggle:SetDisabled(false)
            WidthSlider:SetDisabled(CastBarDB.MatchParentWidth)
            HeightSlider:SetDisabled(false)
            AnchorFromDropdown:SetDisabled(false)
            AnchorToDropdown:SetDisabled(false)
            XPosSlider:SetDisabled(false)
            YPosSlider:SetDisabled(false)
            ForegroundColourPicker:SetDisabled(CastBarDB.ColourByClass)
            BackgroundColourPicker:SetDisabled(false)
            NotInterruptibleColourPicker:SetDisabled(false)
        else
            MatchParentWidthToggle:SetDisabled(true)
            WidthSlider:SetDisabled(true)
            HeightSlider:SetDisabled(true)
            AnchorFromDropdown:SetDisabled(true)
            AnchorToDropdown:SetDisabled(true)
            XPosSlider:SetDisabled(true)
            YPosSlider:SetDisabled(true)
            ForegroundColourPicker:SetDisabled(true)
            BackgroundColourPicker:SetDisabled(true)
            NotInterruptibleColourPicker:SetDisabled(true)
        end
    end

    RefreshCastBarBarSettings()
end

local function CreateCastBarIconSettings(containerParent, unit, updateCallback)
    local CastBarIconDB = UUF.db.profile.Units[unit].CastBar.Icon

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Icon Settings")
    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel("Enable |cFF8080FFCast Bar Icon|r")
    Toggle:SetValue(CastBarIconDB.Enabled)
    Toggle:SetCallback("OnValueChanged", function(_, _, value) CastBarIconDB.Enabled = value updateCallback() RefreshCastBarIconSettings() end)
    Toggle:SetRelativeWidth(0.5)
    LayoutContainer:AddChild(Toggle)

    local PositionDropdown = AG:Create("Dropdown")
    PositionDropdown:SetList({["LEFT"] = "Left", ["RIGHT"] = "Right"})
    PositionDropdown:SetLabel("Position")
    PositionDropdown:SetValue(CastBarIconDB.Position)
    PositionDropdown:SetRelativeWidth(0.5)
    PositionDropdown:SetCallback("OnValueChanged", function(_, _, value) CastBarIconDB.Position = value updateCallback() end)
    LayoutContainer:AddChild(PositionDropdown)

    function RefreshCastBarIconSettings()
        if CastBarIconDB.Enabled then
            PositionDropdown:SetDisabled(false)
        else
            PositionDropdown:SetDisabled(true)
        end
    end

    RefreshCastBarIconSettings()
end

local function CreateCastBarSpellNameTextSettings(containerParent, unit, updateCallback)
    local CastBarTextDB = UUF.db.profile.Units[unit].CastBar.Text
    local SpellNameTextDB = CastBarTextDB.SpellName

    local SpellNameContainer = GUIWidgets.CreateInlineGroup(containerParent, "Spell Name Settings")

    local SpellNameToggle = AG:Create("CheckBox")
    SpellNameToggle:SetLabel("Enable |cFF8080FFSpell Name Text|r")
    SpellNameToggle:SetValue(SpellNameTextDB.Enabled)
    SpellNameToggle:SetCallback("OnValueChanged", function(_, _, value) SpellNameTextDB.Enabled = value updateCallback() RefreshCastBarSpellNameSettings() end)
    SpellNameToggle:SetRelativeWidth(0.5)
    SpellNameContainer:AddChild(SpellNameToggle)

    local SpellNameColourPicker = AG:Create("ColorPicker")
    SpellNameColourPicker:SetLabel("Colour")
    local R, G, B = unpack(SpellNameTextDB.Colour)
    SpellNameColourPicker:SetColor(R, G, B)
    SpellNameColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b) SpellNameTextDB.Colour = {r, g, b} updateCallback() end)
    SpellNameColourPicker:SetHasAlpha(false)
    SpellNameColourPicker:SetRelativeWidth(0.5)
    SpellNameContainer:AddChild(SpellNameColourPicker)

    local SpellNameLayoutContainer = GUIWidgets.CreateInlineGroup(SpellNameContainer, "Layout")
    local SpellNameAnchorFromDropdown = AG:Create("Dropdown")
    SpellNameAnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    SpellNameAnchorFromDropdown:SetLabel("Anchor From")
    SpellNameAnchorFromDropdown:SetValue(SpellNameTextDB.Layout[1])
    SpellNameAnchorFromDropdown:SetRelativeWidth(0.5)
    SpellNameAnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) SpellNameTextDB.Layout[1] = value updateCallback() end)
    SpellNameLayoutContainer:AddChild(SpellNameAnchorFromDropdown)

    local SpellNameAnchorToDropdown = AG:Create("Dropdown")
    SpellNameAnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    SpellNameAnchorToDropdown:SetLabel("Anchor To")
    SpellNameAnchorToDropdown:SetValue(SpellNameTextDB.Layout[2])
    SpellNameAnchorToDropdown:SetRelativeWidth(0.5)
    SpellNameAnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) SpellNameTextDB.Layout[2] = value updateCallback() end)
    SpellNameLayoutContainer:AddChild(SpellNameAnchorToDropdown)

    local SpellNameXPosSlider = AG:Create("Slider")
    SpellNameXPosSlider:SetLabel("X Position")
    SpellNameXPosSlider:SetValue(SpellNameTextDB.Layout[3])
    SpellNameXPosSlider:SetSliderValues(-1000, 1000, 0.1)
    SpellNameXPosSlider:SetRelativeWidth(0.25)
    SpellNameXPosSlider:SetCallback("OnValueChanged", function(_, _, value) SpellNameTextDB.Layout[3] = value updateCallback() end)
    SpellNameLayoutContainer:AddChild(SpellNameXPosSlider)

    local SpellNameYPosSlider = AG:Create("Slider")
    SpellNameYPosSlider:SetLabel("Y Position")
    SpellNameYPosSlider:SetValue(SpellNameTextDB.Layout[4])
    SpellNameYPosSlider:SetSliderValues(-1000, 1000, 0.1)
    SpellNameYPosSlider:SetRelativeWidth(0.25)
    SpellNameYPosSlider:SetCallback("OnValueChanged", function(_, _, value) SpellNameTextDB.Layout[4] = value updateCallback() end)
    SpellNameLayoutContainer:AddChild(SpellNameYPosSlider)

    local SpellNameFontSizeSlider = AG:Create("Slider")
    SpellNameFontSizeSlider:SetLabel("Font Size")
    SpellNameFontSizeSlider:SetValue(SpellNameTextDB.FontSize)
    SpellNameFontSizeSlider:SetSliderValues(8, 64, 1)
    SpellNameFontSizeSlider:SetRelativeWidth(0.25)
    SpellNameFontSizeSlider:SetCallback("OnValueChanged", function(_, _, value) SpellNameTextDB.FontSize = value updateCallback() end)
    SpellNameLayoutContainer:AddChild(SpellNameFontSizeSlider)

    local MaxCharsSlider = AG:Create("Slider")
    MaxCharsSlider:SetLabel("Max Characters")
    MaxCharsSlider:SetValue(SpellNameTextDB.MaxChars)
    MaxCharsSlider:SetSliderValues(1, 64, 1)
    MaxCharsSlider:SetRelativeWidth(0.25)
    MaxCharsSlider:SetCallback("OnValueChanged", function(_, _, value) SpellNameTextDB.MaxChars = value updateCallback() end)
    SpellNameLayoutContainer:AddChild(MaxCharsSlider)

    function RefreshCastBarSpellNameSettings()
        if SpellNameTextDB.Enabled then
            SpellNameAnchorFromDropdown:SetDisabled(false)
            SpellNameAnchorToDropdown:SetDisabled(false)
            SpellNameXPosSlider:SetDisabled(false)
            SpellNameYPosSlider:SetDisabled(false)
            SpellNameFontSizeSlider:SetDisabled(false)
            SpellNameColourPicker:SetDisabled(false)
            MaxCharsSlider:SetDisabled(false)
        else
            SpellNameAnchorFromDropdown:SetDisabled(true)
            SpellNameAnchorToDropdown:SetDisabled(true)
            SpellNameXPosSlider:SetDisabled(true)
            SpellNameYPosSlider:SetDisabled(true)
            SpellNameFontSizeSlider:SetDisabled(true)
            SpellNameColourPicker:SetDisabled(true)
            MaxCharsSlider:SetDisabled(true)
        end
    end

    RefreshCastBarSpellNameSettings()
end

local function CreateCastBarDurationTextSettings(containerParent, unit, updateCallback)
    local CastBarTextDB = UUF.db.profile.Units[unit].CastBar.Text
    local DurationTextDB = CastBarTextDB.Duration

     local DurationContainer = GUIWidgets.CreateInlineGroup(containerParent, "Duration Settings")

    local DurationToggle = AG:Create("CheckBox")
    DurationToggle:SetLabel("Enable |cFF8080FFDuration Text|r")
    DurationToggle:SetValue(DurationTextDB.Enabled)
    DurationToggle:SetCallback("OnValueChanged", function(_, _, value) DurationTextDB.Enabled = value updateCallback() RefreshCastBarDurationSettings() end)
    DurationToggle:SetRelativeWidth(0.5)
    DurationContainer:AddChild(DurationToggle)

    local DurationColourPicker = AG:Create("ColorPicker")
    DurationColourPicker:SetLabel("Colour")
    local R, G, B = unpack(DurationTextDB.Colour)
    DurationColourPicker:SetColor(R, G, B)
    DurationColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b) DurationTextDB.Colour = {r, g, b} updateCallback() end)
    DurationColourPicker:SetHasAlpha(false)
    DurationColourPicker:SetRelativeWidth(0.5)
    DurationContainer:AddChild(DurationColourPicker)

    local DurationLayoutContainer = GUIWidgets.CreateInlineGroup(DurationContainer, "Layout")
    local DurationAnchorFromDropdown = AG:Create("Dropdown")
    DurationAnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    DurationAnchorFromDropdown:SetLabel("Anchor From")
    DurationAnchorFromDropdown:SetValue(DurationTextDB.Layout[1])
    DurationAnchorFromDropdown:SetRelativeWidth(0.5)
    DurationAnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) DurationTextDB.Layout[1] = value updateCallback() end)
    DurationLayoutContainer:AddChild(DurationAnchorFromDropdown)

    local DurationAnchorToDropdown = AG:Create("Dropdown")
    DurationAnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    DurationAnchorToDropdown:SetLabel("Anchor To")
    DurationAnchorToDropdown:SetValue(DurationTextDB.Layout[2])
    DurationAnchorToDropdown:SetRelativeWidth(0.5)
    DurationAnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) DurationTextDB.Layout[2] = value updateCallback() end)
    DurationLayoutContainer:AddChild(DurationAnchorToDropdown)

    local DurationXPosSlider = AG:Create("Slider")
    DurationXPosSlider:SetLabel("X Position")
    DurationXPosSlider:SetValue(DurationTextDB.Layout[3])
    DurationXPosSlider:SetSliderValues(-1000, 1000, 0.1)
    DurationXPosSlider:SetRelativeWidth(0.33)
    DurationXPosSlider:SetCallback("OnValueChanged", function(_, _, value) DurationTextDB.Layout[3] = value updateCallback() end)
    DurationLayoutContainer:AddChild(DurationXPosSlider)

    local DurationYPosSlider = AG:Create("Slider")
    DurationYPosSlider:SetLabel("Y Position")
    DurationYPosSlider:SetValue(DurationTextDB.Layout[4])
    DurationYPosSlider:SetSliderValues(-1000, 1000, 0.1)
    DurationYPosSlider:SetRelativeWidth(0.33)
    DurationYPosSlider:SetCallback("OnValueChanged", function(_, _, value) DurationTextDB.Layout[4] = value updateCallback() end)
    DurationLayoutContainer:AddChild(DurationYPosSlider)

    local DurationFontSizeSlider = AG:Create("Slider")
    DurationFontSizeSlider:SetLabel("Font Size")
    DurationFontSizeSlider:SetValue(DurationTextDB.FontSize)
    DurationFontSizeSlider:SetSliderValues(8, 64, 1)
    DurationFontSizeSlider:SetRelativeWidth(0.33)
    DurationFontSizeSlider:SetCallback("OnValueChanged", function(_, _, value) DurationTextDB.FontSize = value updateCallback() end)
    DurationLayoutContainer:AddChild(DurationFontSizeSlider)

    function RefreshCastBarDurationSettings()
        if DurationTextDB.Enabled then
            DurationAnchorFromDropdown:SetDisabled(false)
            DurationAnchorToDropdown:SetDisabled(false)
            DurationXPosSlider:SetDisabled(false)
            DurationYPosSlider:SetDisabled(false)
            DurationFontSizeSlider:SetDisabled(false)
            DurationColourPicker:SetDisabled(false)
        else
            DurationAnchorFromDropdown:SetDisabled(true)
            DurationAnchorToDropdown:SetDisabled(true)
            DurationXPosSlider:SetDisabled(true)
            DurationYPosSlider:SetDisabled(true)
            DurationFontSizeSlider:SetDisabled(true)
            DurationColourPicker:SetDisabled(true)
        end
    end

    RefreshCastBarDurationSettings()
end

local function CreateCastBarSettings(containerParent, unit)

    local function SelectCastBarTab(CastBarContainer, _, CastBarTab)
        SaveSubTab(unit, "CastBar", CastBarTab)
        CastBarContainer:ReleaseChildren()
        if CastBarTab == "Bar" then
            CreateCastBarBarSettings(CastBarContainer, unit, function() UpdateManagedUnitMethod(unit, "UpdateUnitCastBar") end)
        elseif CastBarTab == "Icon" then
            CreateCastBarIconSettings(CastBarContainer, unit, function() UpdateManagedUnitMethod(unit, "UpdateUnitCastBar") end)
        elseif CastBarTab == "SpellName" then
            CreateCastBarSpellNameTextSettings(CastBarContainer, unit, function() UpdateManagedUnitMethod(unit, "UpdateUnitCastBar") end)
        elseif CastBarTab == "Duration" then
            CreateCastBarDurationTextSettings(CastBarContainer, unit, function() UpdateManagedUnitMethod(unit, "UpdateUnitCastBar") end)
        end
    end

    local CastBarTabGroup = AG:Create("TabGroup")
    CastBarTabGroup:SetLayout("Flow")
    CastBarTabGroup:SetFullWidth(true)
    CastBarTabGroup:SetTabs({
        {text = "Bar", value = "Bar"},
        {text = "Icon" , value = "Icon"},
        {text = "Text: |cFFFFFFFFSpell Name|r", value = "SpellName"},
        {text = "Text: |cFFFFFFFFDuration|r", value = "Duration"},
    })
    CastBarTabGroup:SetCallback("OnGroupSelected", SelectCastBarTab)
    CastBarTabGroup:SelectTab(GetSavedSubTab(unit, "CastBar", "Bar"))
    containerParent:AddChild(CastBarTabGroup)
end

local function CreatePowerBarSettings(containerParent, unit, updateCallback)
    local FrameDB = UUF.db.profile.Units[unit].Frame
    local PowerBarDB = UUF.db.profile.Units[unit].PowerBar

    local function ShouldDisablePowerBarBackgroundColourPicker()
        return not PowerBarDB.Enabled or PowerBarDB.ColourBackgroundByType
    end

    local function UpdatePowerBarSettings()
        updateCallback()
        if unit == "player" and UUF.PLAYER then
            UUF:UpdateUnitSecondaryPowerBar(UUF.PLAYER, unit)
        end
        if unit == "party" and UUF.PARTY_TEST_MODE then
            UUF:CreateTestPartyFrames()
        end
    end

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Power Bar Settings")

    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel("Enable |cFF8080FFPower Bar|r")
    Toggle:SetValue(PowerBarDB.Enabled)
    Toggle:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.Enabled = value UpdatePowerBarSettings() RefreshPowerBarGUI() end)
    Toggle:SetRelativeWidth(0.25)
    LayoutContainer:AddChild(Toggle)

    local InverseGrowthDirectionToggle = AG:Create("CheckBox")
    InverseGrowthDirectionToggle:SetLabel("Inverse Growth Direction")
    InverseGrowthDirectionToggle:SetValue(PowerBarDB.Inverse)
    InverseGrowthDirectionToggle:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.Inverse = value UpdatePowerBarSettings() end)
    InverseGrowthDirectionToggle:SetRelativeWidth(0.25)
    LayoutContainer:AddChild(InverseGrowthDirectionToggle)

    local PositionDropdown = AG:Create("Dropdown")
    PositionDropdown:SetList(TopBottomList[1], TopBottomList[2])
    PositionDropdown:SetLabel("Position")
    PositionDropdown:SetValue(UUF:GetConfiguredPowerBarPosition(unit))
    PositionDropdown:SetRelativeWidth(0.25)
    PositionDropdown:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.Position = value UpdatePowerBarSettings() end)
    LayoutContainer:AddChild(PositionDropdown)

    local HeightSlider = AG:Create("Slider")
    HeightSlider:SetLabel("Height")
    HeightSlider:SetValue(PowerBarDB.Height)
    HeightSlider:SetSliderValues(1, FrameDB.Height - 2, 0.1)
    HeightSlider:SetRelativeWidth(0.25)
    HeightSlider:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.Height = value UpdatePowerBarSettings() end)
    LayoutContainer:AddChild(HeightSlider)

    if unit == "party" or unit == "raid" then
        local HealersOnlyToggle = AG:Create("CheckBox")
        HealersOnlyToggle:SetLabel("Show For Healers Only")
        HealersOnlyToggle:SetValue(PowerBarDB.OnlyHealers or false)
        HealersOnlyToggle:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.OnlyHealers = value UpdatePowerBarSettings() end)
        HealersOnlyToggle:SetRelativeWidth(0.25)
        LayoutContainer:AddChild(HealersOnlyToggle)
    end

    local ColourContainer = GUIWidgets.CreateInlineGroup(containerParent, "Colours & Toggles")

    local SmoothUpdatesToggle = AG:Create("CheckBox")
    SmoothUpdatesToggle:SetLabel("Smooth Updates")
    SmoothUpdatesToggle:SetValue(PowerBarDB.Smooth)
    SmoothUpdatesToggle:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.Smooth = value UpdatePowerBarSettings() end)
    SmoothUpdatesToggle:SetRelativeWidth(0.25)
    ColourContainer:AddChild(SmoothUpdatesToggle)

    local ColourByTypeToggle = AG:Create("CheckBox")
    ColourByTypeToggle:SetLabel("Colour By Type")
    ColourByTypeToggle:SetValue(PowerBarDB.ColourByType)
    ColourByTypeToggle:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.ColourByType = value UpdatePowerBarSettings() RefreshPowerBarGUI() end)
    ColourByTypeToggle:SetRelativeWidth(0.25)
    ColourContainer:AddChild(ColourByTypeToggle)

    local ColourByClassToggle = AG:Create("CheckBox")
    ColourByClassToggle:SetLabel("Colour By Class")
    ColourByClassToggle:SetValue(PowerBarDB.ColourByClass)
    ColourByClassToggle:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.ColourByClass = value UpdatePowerBarSettings() RefreshPowerBarGUI() end)
    ColourByClassToggle:SetRelativeWidth(0.25)
    ColourContainer:AddChild(ColourByClassToggle)

    local ColourBackgroundByTypeToggle = AG:Create("CheckBox")
    ColourBackgroundByTypeToggle:SetLabel("Colour Background By Power Type")
    ColourBackgroundByTypeToggle:SetValue(PowerBarDB.ColourBackgroundByType)
    ColourBackgroundByTypeToggle:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.ColourBackgroundByType = value UpdatePowerBarSettings() RefreshPowerBarGUI() end)
    ColourBackgroundByTypeToggle:SetRelativeWidth(0.25)
    ColourBackgroundByTypeToggle:SetDisabled(true)
    ColourContainer:AddChild(ColourBackgroundByTypeToggle)

    local ForegroundColourPicker = AG:Create("ColorPicker")
    ForegroundColourPicker:SetLabel("Foreground Colour")
    local R, G, B, A = unpack(PowerBarDB.Foreground)
    ForegroundColourPicker:SetColor(R, G, B, A)
    ForegroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) PowerBarDB.Foreground = {r, g, b, a} UpdatePowerBarSettings() end)
    ForegroundColourPicker:SetHasAlpha(true)
    ForegroundColourPicker:SetRelativeWidth(0.33)
    ForegroundColourPicker:SetDisabled(PowerBarDB.ColourByClass or PowerBarDB.ColourByType)
    ColourContainer:AddChild(ForegroundColourPicker)

    local BackgroundColourPicker = AG:Create("ColorPicker")
    BackgroundColourPicker:SetLabel("Background Colour")
    local R2, G2, B2, A2 = unpack(PowerBarDB.Background)
    BackgroundColourPicker:SetColor(R2, G2, B2, A2)
    BackgroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) PowerBarDB.Background = {r, g, b, a} UpdatePowerBarSettings() end)
    BackgroundColourPicker:SetHasAlpha(true)
    BackgroundColourPicker:SetRelativeWidth(0.33)
    BackgroundColourPicker:SetDisabled(ShouldDisablePowerBarBackgroundColourPicker())
    ColourContainer:AddChild(BackgroundColourPicker)

    local BackgroundMultiplierSlider = AG:Create("Slider")
    BackgroundMultiplierSlider:SetLabel("Background Multiplier")
    BackgroundMultiplierSlider:SetValue(PowerBarDB.BackgroundMultiplier)
    BackgroundMultiplierSlider:SetSliderValues(0, 1, 0.01)
    BackgroundMultiplierSlider:SetRelativeWidth(0.33)
    BackgroundMultiplierSlider:SetCallback("OnValueChanged", function(_, _, value) PowerBarDB.BackgroundMultiplier = value UpdatePowerBarSettings() end)
    BackgroundMultiplierSlider:SetIsPercent(true)
    BackgroundMultiplierSlider:SetDisabled(not PowerBarDB.ColourBackgroundByType)
    ColourContainer:AddChild(BackgroundMultiplierSlider)

    function RefreshPowerBarGUI()
        if PowerBarDB.Enabled then
            GUIWidgets.DeepDisable(LayoutContainer, false, Toggle)
            GUIWidgets.DeepDisable(ColourContainer, false, Toggle)
            if PowerBarDB.ColourByClass or PowerBarDB.ColourByType then
                ForegroundColourPicker:SetDisabled(true)
            else
                ForegroundColourPicker:SetDisabled(false)
            end
            BackgroundColourPicker:SetDisabled(ShouldDisablePowerBarBackgroundColourPicker())
            BackgroundMultiplierSlider:SetDisabled(not PowerBarDB.ColourBackgroundByType)
        else
            GUIWidgets.DeepDisable(LayoutContainer, true, Toggle)
            GUIWidgets.DeepDisable(ColourContainer, true, Toggle)
        end
    end

    RefreshPowerBarGUI()
end

local function CreateSecondaryPowerBarSettings(containerParent, unit, updateCallback)
    local FrameDB = UUF.db.profile.Units[unit].Frame
    local SecondaryPowerBarDB = UUF.db.profile.Units[unit].SecondaryPowerBar

    local function ShouldDisableSecondaryPowerBarBackgroundColourPicker()
        return not SecondaryPowerBarDB.Enabled or SecondaryPowerBarDB.ColourBackgroundByType
    end

    GUIWidgets.CreateInformationTag(containerParent, "Handles oUF-style player resources like class power, runes, and Brewmaster stagger using the same layout settings.")

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Power Bar Settings")

    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel("Enable |cFF8080FFSecondary Power Bar|r")
    Toggle:SetValue(SecondaryPowerBarDB.Enabled)
    Toggle:SetCallback("OnValueChanged", function(_, _, value) SecondaryPowerBarDB.Enabled = value updateCallback() RefreshSecondaryPowerBarGUI() end)
    Toggle:SetRelativeWidth(0.33)
    LayoutContainer:AddChild(Toggle)

    local PositionDropdown = AG:Create("Dropdown")
    PositionDropdown:SetList(TopBottomList[1], TopBottomList[2])
    PositionDropdown:SetLabel("Position")
    PositionDropdown:SetValue(UUF:GetConfiguredSecondaryPowerBarPosition(unit))
    PositionDropdown:SetRelativeWidth(0.33)
    PositionDropdown:SetCallback("OnValueChanged", function(_, _, value) SecondaryPowerBarDB.Position = value updateCallback() end)
    LayoutContainer:AddChild(PositionDropdown)

    local HeightSlider = AG:Create("Slider")
    HeightSlider:SetLabel("Height")
    HeightSlider:SetValue(SecondaryPowerBarDB.Height)
    HeightSlider:SetSliderValues(1, FrameDB.Height - 2, 0.1)
    HeightSlider:SetRelativeWidth(0.33)
    HeightSlider:SetCallback("OnValueChanged", function(_, _, value) SecondaryPowerBarDB.Height = value updateCallback() end)
    LayoutContainer:AddChild(HeightSlider)

    local ColourContainer = GUIWidgets.CreateInlineGroup(containerParent, "Colours & Toggles")

    local ColourByTypeToggle = AG:Create("CheckBox")
    ColourByTypeToggle:SetLabel("Colour By Type")
    ColourByTypeToggle:SetValue(SecondaryPowerBarDB.ColourByType)
    ColourByTypeToggle:SetCallback("OnValueChanged", function(_, _, value) SecondaryPowerBarDB.ColourByType = value updateCallback() RefreshSecondaryPowerBarGUI() end)
    ColourByTypeToggle:SetRelativeWidth(1)
    ColourContainer:AddChild(ColourByTypeToggle)

    local ForegroundColourPicker = AG:Create("ColorPicker")
    ForegroundColourPicker:SetLabel("Foreground Colour")
    local R, G, B, A = unpack(SecondaryPowerBarDB.Foreground)
    ForegroundColourPicker:SetColor(R, G, B, A)
    ForegroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) SecondaryPowerBarDB.Foreground = {r, g, b, a} updateCallback() end)
    ForegroundColourPicker:SetHasAlpha(true)
    ForegroundColourPicker:SetRelativeWidth(0.5)
    ForegroundColourPicker:SetDisabled(SecondaryPowerBarDB.ColourByClass or SecondaryPowerBarDB.ColourByType)
    ColourContainer:AddChild(ForegroundColourPicker)

    local BackgroundColourPicker = AG:Create("ColorPicker")
    BackgroundColourPicker:SetLabel("Background Colour")
    local R2, G2, B2, A2 = unpack(SecondaryPowerBarDB.Background)
    BackgroundColourPicker:SetColor(R2, G2, B2, A2)
    BackgroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) SecondaryPowerBarDB.Background = {r, g, b, a} updateCallback() end)
    BackgroundColourPicker:SetHasAlpha(true)
    BackgroundColourPicker:SetRelativeWidth(0.5)
    BackgroundColourPicker:SetDisabled(ShouldDisableSecondaryPowerBarBackgroundColourPicker())
    ColourContainer:AddChild(BackgroundColourPicker)

    function RefreshSecondaryPowerBarGUI()
        if SecondaryPowerBarDB.Enabled then
            GUIWidgets.DeepDisable(LayoutContainer, false, Toggle)
            GUIWidgets.DeepDisable(ColourContainer, false, Toggle)
            if SecondaryPowerBarDB.ColourByClass or SecondaryPowerBarDB.ColourByType then
                ForegroundColourPicker:SetDisabled(true)
            else
                ForegroundColourPicker:SetDisabled(false)
            end
            BackgroundColourPicker:SetDisabled(ShouldDisableSecondaryPowerBarBackgroundColourPicker())
        else
            GUIWidgets.DeepDisable(LayoutContainer, true, Toggle)
            GUIWidgets.DeepDisable(ColourContainer, true, Toggle)
        end
    end

    RefreshSecondaryPowerBarGUI()
end

local function CreateAlternativePowerBarSettings(containerParent, unit, updateCallback)
    local AlternativePowerBarDB = UUF.db.profile.Units[unit].AlternativePowerBar

    GUIWidgets.CreateInformationTag(containerParent, "The |cFF8080FFAlternative Power Bar|r will display |cFF4080FFMana|r for classes that have an alternative resource.")

    local AlternativePowerBarSettings = GUIWidgets.CreateInlineGroup(containerParent, "Alternative Power Bar Settings")

    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel("Enable |cFF8080FFAlternative Power Bar|r")
    Toggle:SetValue(AlternativePowerBarDB.Enabled)
    Toggle:SetCallback("OnValueChanged", function(_, _, value) AlternativePowerBarDB.Enabled = value updateCallback() RefreshAlternativePowerBarGUI() end)
    Toggle:SetRelativeWidth(0.5)
    AlternativePowerBarSettings:AddChild(Toggle)

    local InverseGrowthDirectionToggle = AG:Create("CheckBox")
    InverseGrowthDirectionToggle:SetLabel("Inverse Growth Direction")
    InverseGrowthDirectionToggle:SetValue(AlternativePowerBarDB.Inverse)
    InverseGrowthDirectionToggle:SetCallback("OnValueChanged", function(_, _, value) AlternativePowerBarDB.Inverse = value updateCallback() end)
    InverseGrowthDirectionToggle:SetRelativeWidth(0.5)
    AlternativePowerBarSettings:AddChild(InverseGrowthDirectionToggle)

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Layout & Positioning")

    local WidthSlider = AG:Create("Slider")
    WidthSlider:SetLabel("Width")
    WidthSlider:SetValue(AlternativePowerBarDB.Width)
    WidthSlider:SetSliderValues(1, 1000, 0.1)
    WidthSlider:SetRelativeWidth(0.5)
    WidthSlider:SetCallback("OnValueChanged", function(_, _, value) AlternativePowerBarDB.Width = value updateCallback() end)
    LayoutContainer:AddChild(WidthSlider)

    local HeightSlider = AG:Create("Slider")
    HeightSlider:SetLabel("Height")
    HeightSlider:SetValue(AlternativePowerBarDB.Height)
    HeightSlider:SetSliderValues(1, 64, 0.1)
    HeightSlider:SetRelativeWidth(0.5)
    HeightSlider:SetCallback("OnValueChanged", function(_, _, value) AlternativePowerBarDB.Height = value updateCallback() end)
    LayoutContainer:AddChild(HeightSlider)

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(AlternativePowerBarDB.Layout[1])
    AnchorFromDropdown:SetRelativeWidth(0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) AlternativePowerBarDB.Layout[1] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(AlternativePowerBarDB.Layout[2])
    AnchorToDropdown:SetRelativeWidth(0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) AlternativePowerBarDB.Layout[2] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorToDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(AlternativePowerBarDB.Layout[3])
    XPosSlider:SetSliderValues(-1000, 1000, 0.1)
    XPosSlider:SetRelativeWidth(0.5)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) AlternativePowerBarDB.Layout[3] = value updateCallback() end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(AlternativePowerBarDB.Layout[4])
    YPosSlider:SetSliderValues(-1000, 1000, 0.1)
    YPosSlider:SetRelativeWidth(0.5)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) AlternativePowerBarDB.Layout[4] = value updateCallback() end)
    LayoutContainer:AddChild(YPosSlider)

    local ColourContainer = GUIWidgets.CreateInlineGroup(containerParent, "Colours & Toggles")

    local ColourByTypeToggle = AG:Create("CheckBox")
    ColourByTypeToggle:SetLabel("Colour By Type")
    ColourByTypeToggle:SetValue(AlternativePowerBarDB.ColourByType)
    ColourByTypeToggle:SetCallback("OnValueChanged", function(_, _, value) AlternativePowerBarDB.ColourByType = value updateCallback() RefreshAlternativePowerBarGUI() end)
    ColourByTypeToggle:SetRelativeWidth(0.33)
    ColourContainer:AddChild(ColourByTypeToggle)

    local ForegroundColourPicker = AG:Create("ColorPicker")
    ForegroundColourPicker:SetLabel("Foreground Colour")
    local R, G, B, A = unpack(AlternativePowerBarDB.Foreground)
    ForegroundColourPicker:SetColor(R, G, B, A)
    ForegroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) AlternativePowerBarDB.Foreground = {r, g, b, a} updateCallback() end)
    ForegroundColourPicker:SetHasAlpha(true)
    ForegroundColourPicker:SetRelativeWidth(0.33)
    ForegroundColourPicker:SetDisabled(AlternativePowerBarDB.ColourByType)
    ColourContainer:AddChild(ForegroundColourPicker)

    local BackgroundColourPicker = AG:Create("ColorPicker")
    BackgroundColourPicker:SetLabel("Background Colour")
    local R2, G2, B2, A2 = unpack(AlternativePowerBarDB.Background)
    BackgroundColourPicker:SetColor(R2, G2, B2, A2)
    BackgroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a) AlternativePowerBarDB.Background = {r, g, b, a} updateCallback() end)
    BackgroundColourPicker:SetHasAlpha(true)
    BackgroundColourPicker:SetRelativeWidth(0.33)
    ColourContainer:AddChild(BackgroundColourPicker)

    function RefreshAlternativePowerBarGUI()
        if AlternativePowerBarDB.Enabled then
            GUIWidgets.DeepDisable(LayoutContainer, false, Toggle)
            GUIWidgets.DeepDisable(ColourContainer, false, Toggle)
            if AlternativePowerBarDB.ColourByType then
                ForegroundColourPicker:SetDisabled(true)
            else
                ForegroundColourPicker:SetDisabled(false)
            end
        else
            GUIWidgets.DeepDisable(LayoutContainer, true, Toggle)
            GUIWidgets.DeepDisable(ColourContainer, true, Toggle)
        end
        InverseGrowthDirectionToggle:SetDisabled(not AlternativePowerBarDB.Enabled)
    end

    RefreshAlternativePowerBarGUI()
end

local function CreatePortraitSettings(containerParent, unit, updateCallback)
    local PortraitDB = UUF.db.profile.Units[unit].Portrait

    local ToggleContainer = GUIWidgets.CreateInlineGroup(containerParent, "Portrait Settings")

    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel("Enable |cFF8080FFPortrait|r")
    Toggle:SetValue(PortraitDB.Enabled)
    Toggle:SetCallback("OnValueChanged", function(_, _, value) PortraitDB.Enabled = value updateCallback() RefreshPortraitGUI() end)
    Toggle:SetRelativeWidth(0.33)
    ToggleContainer:AddChild(Toggle)

    local PortraitStyleDropdown = AG:Create("Dropdown")
    PortraitStyleDropdown:SetList({["2D"] = "2D", ["3D"] = "3D"})
    PortraitStyleDropdown:SetLabel("Portrait Style")
    PortraitStyleDropdown:SetValue(PortraitDB.Style)
    PortraitStyleDropdown:SetRelativeWidth(0.33)
    PortraitStyleDropdown:SetCallback("OnValueChanged", function(_, _, value) PortraitDB.Style = value updateCallback() RefreshPortraitGUI() end)
    ToggleContainer:AddChild(PortraitStyleDropdown)

    local UseClassPortraitToggle = AG:Create("CheckBox")
    UseClassPortraitToggle:SetLabel("Use Class Portrait")
    UseClassPortraitToggle:SetValue(PortraitDB.UseClassPortrait)
    UseClassPortraitToggle:SetCallback("OnValueChanged", function(_, _, value) PortraitDB.UseClassPortrait = value updateCallback() end)
    UseClassPortraitToggle:SetRelativeWidth(0.33)
    UseClassPortraitToggle:SetDisabled(PortraitDB.Style ~= "2D")
    ToggleContainer:AddChild(UseClassPortraitToggle)

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Layout & Positioning")

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(PortraitDB.Layout[1])
    AnchorFromDropdown:SetRelativeWidth(0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) PortraitDB.Layout[1] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(PortraitDB.Layout[2])
    AnchorToDropdown:SetRelativeWidth(0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) PortraitDB.Layout[2] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorToDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(PortraitDB.Layout[3])
    XPosSlider:SetSliderValues(-1000, 1000, 0.1)
    XPosSlider:SetRelativeWidth(0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) PortraitDB.Layout[3] = value updateCallback() end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(PortraitDB.Layout[4])
    YPosSlider:SetSliderValues(-1000, 1000, 0.1)
    YPosSlider:SetRelativeWidth(0.33)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) PortraitDB.Layout[4] = value updateCallback() end)
    LayoutContainer:AddChild(YPosSlider)

    local ZoomSlider = AG:Create("Slider")
    ZoomSlider:SetLabel("Zoom")
    ZoomSlider:SetValue(PortraitDB.Zoom)
    ZoomSlider:SetSliderValues(0, 1, 0.01)
    ZoomSlider:SetRelativeWidth(0.33)
    ZoomSlider:SetCallback("OnValueChanged", function(_, _, value) PortraitDB.Zoom = value updateCallback() end)
    ZoomSlider:SetIsPercent(true)
    ZoomSlider:SetDisabled(PortraitDB.Style ~= "2D")
    LayoutContainer:AddChild(ZoomSlider)

    local WidthSlider = AG:Create("Slider")
    WidthSlider:SetLabel("Width")
    WidthSlider:SetValue(PortraitDB.Width)
    WidthSlider:SetSliderValues(8, 64, 0.1)
    WidthSlider:SetRelativeWidth(0.5)
    WidthSlider:SetCallback("OnValueChanged", function(_, _, value) PortraitDB.Width = value updateCallback() end)
    LayoutContainer:AddChild(WidthSlider)

    local HeightSlider = AG:Create("Slider")
    HeightSlider:SetLabel("Height")
    HeightSlider:SetValue(PortraitDB.Height)
    HeightSlider:SetSliderValues(8, 64, 0.1)
    HeightSlider:SetRelativeWidth(0.5)
    HeightSlider:SetCallback("OnValueChanged", function(_, _, value) PortraitDB.Height = value updateCallback() end)
    LayoutContainer:AddChild(HeightSlider)

    function RefreshPortraitGUI()
        if PortraitDB.Enabled then
            GUIWidgets.DeepDisable(ToggleContainer, false, Toggle)
            GUIWidgets.DeepDisable(LayoutContainer, false, Toggle)
        else
            GUIWidgets.DeepDisable(ToggleContainer, true, Toggle)
            GUIWidgets.DeepDisable(LayoutContainer, true, Toggle)
        end
        UseClassPortraitToggle:SetDisabled(PortraitDB.Style ~= "2D")
        ZoomSlider:SetDisabled(PortraitDB.Style ~= "2D")
    end

    RefreshPortraitGUI()
end

local function CreateRaidTargetMarkerSettings(containerParent, unit, updateCallback)
    local RaidTargetMarkerDB = UUF.db.profile.Units[unit].Indicators.RaidTargetMarker

    local ToggleContainer = GUIWidgets.CreateInlineGroup(containerParent, "Raid Target Marker Settings")

    local Toggle = CreateDescribedToggle(
        ToggleContainer,
        "Enable |cFF8080FFRaid Target Marker|r Indicator",
        "Displays the raid target icon such as skull, cross, or star on the frame.",
        RaidTargetMarkerDB.Enabled,
        function(_, _, value) RaidTargetMarkerDB.Enabled = value updateCallback() RefreshStatusGUI() end,
        1
    )

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Layout & Positioning")

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(RaidTargetMarkerDB.Layout[1])
    AnchorFromDropdown:SetRelativeWidth(0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) RaidTargetMarkerDB.Layout[1] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(RaidTargetMarkerDB.Layout[2])
    AnchorToDropdown:SetRelativeWidth(0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) RaidTargetMarkerDB.Layout[2] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorToDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(RaidTargetMarkerDB.Layout[3])
    XPosSlider:SetSliderValues(-1000, 1000, 0.1)
    XPosSlider:SetRelativeWidth(0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) RaidTargetMarkerDB.Layout[3] = value updateCallback() end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(RaidTargetMarkerDB.Layout[4])
    YPosSlider:SetSliderValues(-1000, 1000, 0.1)
    YPosSlider:SetRelativeWidth(0.33)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) RaidTargetMarkerDB.Layout[4] = value updateCallback() end)
    LayoutContainer:AddChild(YPosSlider)

    local SizeSlider = AG:Create("Slider")
    SizeSlider:SetLabel("Size")
    SizeSlider:SetValue(RaidTargetMarkerDB.Size)
    SizeSlider:SetSliderValues(8, 64, 1)
    SizeSlider:SetRelativeWidth(0.33)
    SizeSlider:SetCallback("OnValueChanged", function(_, _, value) RaidTargetMarkerDB.Size = value updateCallback() end)
    LayoutContainer:AddChild(SizeSlider)

    function RefreshStatusGUI()
        if RaidTargetMarkerDB.Enabled then
            GUIWidgets.DeepDisable(ToggleContainer, false, Toggle)
            GUIWidgets.DeepDisable(LayoutContainer, false, Toggle)
        else
            GUIWidgets.DeepDisable(ToggleContainer, true, Toggle)
            GUIWidgets.DeepDisable(LayoutContainer, true, Toggle)
        end
    end

    RefreshStatusGUI()
end

local function CreateLeaderAssistaintSettings(containerParent, unit, updateCallback)
    local LeaderAssistantDB = UUF.db.profile.Units[unit].Indicators.LeaderAssistantIndicator

    local ToggleContainer = GUIWidgets.CreateInlineGroup(containerParent, "Leader & Assistant Settings")

    local Toggle = CreateDescribedToggle(
        ToggleContainer,
        "Enable |cFF8080FFLeader|r & |cFF8080FFAssistant|r Indicator",
        "Shows party or raid leader and assistant status on the frame.",
        LeaderAssistantDB.Enabled,
        function(_, _, value) LeaderAssistantDB.Enabled = value updateCallback() RefreshStatusGUI() end,
        1
    )

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Layout & Positioning")

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(LeaderAssistantDB.Layout[1])
    AnchorFromDropdown:SetRelativeWidth(0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) LeaderAssistantDB.Layout[1] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(LeaderAssistantDB.Layout[2])
    AnchorToDropdown:SetRelativeWidth(0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) LeaderAssistantDB.Layout[2] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorToDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(LeaderAssistantDB.Layout[3])
    XPosSlider:SetSliderValues(-1000, 1000, 0.1)
    XPosSlider:SetRelativeWidth(0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) LeaderAssistantDB.Layout[3] = value updateCallback() end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(LeaderAssistantDB.Layout[4])
    YPosSlider:SetSliderValues(-1000, 1000, 0.1)
    YPosSlider:SetRelativeWidth(0.33)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) LeaderAssistantDB.Layout[4] = value updateCallback() end)
    LayoutContainer:AddChild(YPosSlider)

    local SizeSlider = AG:Create("Slider")
    SizeSlider:SetLabel("Size")
    SizeSlider:SetValue(LeaderAssistantDB.Size)
    SizeSlider:SetSliderValues(8, 64, 1)
    SizeSlider:SetRelativeWidth(0.33)
    SizeSlider:SetCallback("OnValueChanged", function(_, _, value) LeaderAssistantDB.Size = value updateCallback() end)
    LayoutContainer:AddChild(SizeSlider)

    function RefreshStatusGUI()
        if LeaderAssistantDB.Enabled then
            GUIWidgets.DeepDisable(ToggleContainer, false, Toggle)
            GUIWidgets.DeepDisable(LayoutContainer, false, Toggle)
        else
            GUIWidgets.DeepDisable(ToggleContainer, true, Toggle)
            GUIWidgets.DeepDisable(LayoutContainer, true, Toggle)
        end
    end

    RefreshStatusGUI()
end

local function CreateRoleIconSettings(containerParent, unit, updateCallback)
    local RoleIconDB = UUF.db.profile.Units[unit].Indicators.RoleIcon

    local ToggleContainer = GUIWidgets.CreateInlineGroup(containerParent, "Role Icon Settings")

    local Toggle = CreateDescribedToggle(
        ToggleContainer,
        "Enable |cFF8080FFRole Icon|r Indicator",
        "Shows the assigned dungeon or raid role for the unit.",
        RoleIconDB.Enabled,
        function(_, _, value) RoleIconDB.Enabled = value updateCallback() RefreshRoleIconGUI() end,
        1
    )

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Layout & Positioning")

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(RoleIconDB.Layout[1])
    AnchorFromDropdown:SetRelativeWidth(0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) RoleIconDB.Layout[1] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(RoleIconDB.Layout[2])
    AnchorToDropdown:SetRelativeWidth(0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) RoleIconDB.Layout[2] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorToDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(RoleIconDB.Layout[3])
    XPosSlider:SetSliderValues(-1000, 1000, 0.1)
    XPosSlider:SetRelativeWidth(0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) RoleIconDB.Layout[3] = value updateCallback() end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(RoleIconDB.Layout[4])
    YPosSlider:SetSliderValues(-1000, 1000, 0.1)
    YPosSlider:SetRelativeWidth(0.33)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) RoleIconDB.Layout[4] = value updateCallback() end)
    LayoutContainer:AddChild(YPosSlider)

    local SizeSlider = AG:Create("Slider")
    SizeSlider:SetLabel("Size")
    SizeSlider:SetValue(RoleIconDB.Size)
    SizeSlider:SetSliderValues(8, 64, 1)
    SizeSlider:SetRelativeWidth(0.33)
    SizeSlider:SetCallback("OnValueChanged", function(_, _, value) RoleIconDB.Size = value updateCallback() end)
    LayoutContainer:AddChild(SizeSlider)

    function RefreshRoleIconGUI()
        if RoleIconDB.Enabled then
            GUIWidgets.DeepDisable(ToggleContainer, false, Toggle)
            GUIWidgets.DeepDisable(LayoutContainer, false, Toggle)
        else
            GUIWidgets.DeepDisable(ToggleContainer, true, Toggle)
            GUIWidgets.DeepDisable(LayoutContainer, true, Toggle)
        end
    end

    RefreshRoleIconGUI()
end

local function CreateReadyCheckSettings(containerParent, unit, updateCallback)
    local ReadyCheckDB = UUF.db.profile.Units[unit].Indicators.ReadyCheck

    local ToggleContainer = GUIWidgets.CreateInlineGroup(containerParent, "Ready Check Settings")

    local Toggle = CreateDescribedToggle(
        ToggleContainer,
        "Enable |cFF8080FFReady Check|r Indicator",
        "",
        ReadyCheckDB.Enabled,
        function(_, _, value) ReadyCheckDB.Enabled = value updateCallback() RefreshReadyCheckGUI() end,
        1
    )

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Layout & Positioning")

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(ReadyCheckDB.Layout[1])
    AnchorFromDropdown:SetRelativeWidth(0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) ReadyCheckDB.Layout[1] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(ReadyCheckDB.Layout[2])
    AnchorToDropdown:SetRelativeWidth(0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) ReadyCheckDB.Layout[2] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorToDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(ReadyCheckDB.Layout[3])
    XPosSlider:SetSliderValues(-1000, 1000, 0.1)
    XPosSlider:SetRelativeWidth(0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) ReadyCheckDB.Layout[3] = value updateCallback() end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(ReadyCheckDB.Layout[4])
    YPosSlider:SetSliderValues(-1000, 1000, 0.1)
    YPosSlider:SetRelativeWidth(0.33)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) ReadyCheckDB.Layout[4] = value updateCallback() end)
    LayoutContainer:AddChild(YPosSlider)

    local SizeSlider = AG:Create("Slider")
    SizeSlider:SetLabel("Size")
    SizeSlider:SetValue(ReadyCheckDB.Size)
    SizeSlider:SetSliderValues(8, 64, 1)
    SizeSlider:SetRelativeWidth(0.33)
    SizeSlider:SetCallback("OnValueChanged", function(_, _, value) ReadyCheckDB.Size = value updateCallback() end)
    LayoutContainer:AddChild(SizeSlider)

    function RefreshReadyCheckGUI()
        local disabled = not ReadyCheckDB.Enabled
        GUIWidgets.DeepDisable(ToggleContainer, disabled, Toggle)
        GUIWidgets.DeepDisable(LayoutContainer, disabled, Toggle)
    end

    RefreshReadyCheckGUI()
end

local function CreatePhaseIndicatorSettings(containerParent, unit, updateCallback)
    local PhaseDB = UUF.db.profile.Units[unit].Indicators.Phase

    local ToggleContainer = GUIWidgets.CreateInlineGroup(containerParent, "Phase Indicator Settings")

    local Toggle = CreateDescribedToggle(
        ToggleContainer,
        "Enable |cFF8080FFPhase|r Indicator",
        "",
        PhaseDB.Enabled,
        function(_, _, value) PhaseDB.Enabled = value updateCallback() RefreshPhaseGUI() end,
        1
    )

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Layout & Positioning")

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(PhaseDB.Layout[1])
    AnchorFromDropdown:SetRelativeWidth(0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) PhaseDB.Layout[1] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(PhaseDB.Layout[2])
    AnchorToDropdown:SetRelativeWidth(0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) PhaseDB.Layout[2] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorToDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(PhaseDB.Layout[3])
    XPosSlider:SetSliderValues(-1000, 1000, 0.1)
    XPosSlider:SetRelativeWidth(0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) PhaseDB.Layout[3] = value updateCallback() end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(PhaseDB.Layout[4])
    YPosSlider:SetSliderValues(-1000, 1000, 0.1)
    YPosSlider:SetRelativeWidth(0.33)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) PhaseDB.Layout[4] = value updateCallback() end)
    LayoutContainer:AddChild(YPosSlider)

    local SizeSlider = AG:Create("Slider")
    SizeSlider:SetLabel("Size")
    SizeSlider:SetValue(PhaseDB.Size)
    SizeSlider:SetSliderValues(8, 64, 1)
    SizeSlider:SetRelativeWidth(0.33)
    SizeSlider:SetCallback("OnValueChanged", function(_, _, value) PhaseDB.Size = value updateCallback() end)
    LayoutContainer:AddChild(SizeSlider)

    function RefreshPhaseGUI()
        if PhaseDB.Enabled then
            GUIWidgets.DeepDisable(ToggleContainer, false, Toggle)
            GUIWidgets.DeepDisable(LayoutContainer, false, Toggle)
        else
            GUIWidgets.DeepDisable(ToggleContainer, true, Toggle)
            GUIWidgets.DeepDisable(LayoutContainer, true, Toggle)
        end
    end

    RefreshPhaseGUI()
end

local function CreateResurrectSettings(containerParent, unit, updateCallback)
    local ResurrectDB = UUF.db.profile.Units[unit].Indicators.Resurrect

    local ToggleContainer = GUIWidgets.CreateInlineGroup(containerParent, "Resurrection Settings")

    local Toggle = CreateDescribedToggle(
        ToggleContainer,
        "Enable |cFF8080FFResurrection|r Indicator",
        "",
        ResurrectDB.Enabled,
        function(_, _, value) ResurrectDB.Enabled = value updateCallback() RefreshResurrectGUI() end,
        1
    )

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Layout & Positioning")

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(ResurrectDB.Layout[1])
    AnchorFromDropdown:SetRelativeWidth(0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) ResurrectDB.Layout[1] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(ResurrectDB.Layout[2])
    AnchorToDropdown:SetRelativeWidth(0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) ResurrectDB.Layout[2] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorToDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(ResurrectDB.Layout[3])
    XPosSlider:SetSliderValues(-1000, 1000, 0.1)
    XPosSlider:SetRelativeWidth(0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) ResurrectDB.Layout[3] = value updateCallback() end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(ResurrectDB.Layout[4])
    YPosSlider:SetSliderValues(-1000, 1000, 0.1)
    YPosSlider:SetRelativeWidth(0.33)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) ResurrectDB.Layout[4] = value updateCallback() end)
    LayoutContainer:AddChild(YPosSlider)

    local SizeSlider = AG:Create("Slider")
    SizeSlider:SetLabel("Size")
    SizeSlider:SetValue(ResurrectDB.Size)
    SizeSlider:SetSliderValues(8, 64, 1)
    SizeSlider:SetRelativeWidth(0.33)
    SizeSlider:SetCallback("OnValueChanged", function(_, _, value) ResurrectDB.Size = value updateCallback() end)
    LayoutContainer:AddChild(SizeSlider)

    function RefreshResurrectGUI()
        if ResurrectDB.Enabled then
            GUIWidgets.DeepDisable(ToggleContainer, false, Toggle)
            GUIWidgets.DeepDisable(LayoutContainer, false, Toggle)
        else
            GUIWidgets.DeepDisable(ToggleContainer, true, Toggle)
            GUIWidgets.DeepDisable(LayoutContainer, true, Toggle)
        end
    end

    RefreshResurrectGUI()
end

local function CreateSummonSettings(containerParent, unit, updateCallback)
    local SummonDB = UUF.db.profile.Units[unit].Indicators.Summon

    local ToggleContainer = GUIWidgets.CreateInlineGroup(containerParent, "Summon Settings")

    local Toggle = CreateDescribedToggle(
        ToggleContainer,
        "Enable |cFF8080FFSummon|r Indicator",
        "Shows pending, accepted, or declined summon status for the unit.",
        SummonDB.Enabled,
        function(_, _, value) SummonDB.Enabled = value updateCallback() RefreshSummonGUI() end,
        1
    )

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Layout & Positioning")

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(SummonDB.Layout[1])
    AnchorFromDropdown:SetRelativeWidth(0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) SummonDB.Layout[1] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(SummonDB.Layout[2])
    AnchorToDropdown:SetRelativeWidth(0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) SummonDB.Layout[2] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorToDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(SummonDB.Layout[3])
    XPosSlider:SetSliderValues(-1000, 1000, 0.1)
    XPosSlider:SetRelativeWidth(0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) SummonDB.Layout[3] = value updateCallback() end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(SummonDB.Layout[4])
    YPosSlider:SetSliderValues(-1000, 1000, 0.1)
    YPosSlider:SetRelativeWidth(0.33)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) SummonDB.Layout[4] = value updateCallback() end)
    LayoutContainer:AddChild(YPosSlider)

    local SizeSlider = AG:Create("Slider")
    SizeSlider:SetLabel("Size")
    SizeSlider:SetValue(SummonDB.Size)
    SizeSlider:SetSliderValues(8, 64, 1)
    SizeSlider:SetRelativeWidth(0.33)
    SizeSlider:SetCallback("OnValueChanged", function(_, _, value) SummonDB.Size = value updateCallback() end)
    LayoutContainer:AddChild(SizeSlider)

    function RefreshSummonGUI()
        local disabled = not SummonDB.Enabled
        GUIWidgets.DeepDisable(ToggleContainer, disabled, Toggle)
        GUIWidgets.DeepDisable(LayoutContainer, disabled, Toggle)
    end

    RefreshSummonGUI()
end

local function CreateStatusSettings(containerParent, unit, statusDB, updateCallback)
    local StatusDB = UUF.db.profile.Units[unit].Indicators[statusDB]

    local ToggleContainer = GUIWidgets.CreateInlineGroup(containerParent, statusDB .. " Settings")

    local StatusTextureList = {}
    for key, texture in pairs(StatusTextures[statusDB]) do
        StatusTextureList[key] = texture
    end

    local Toggle = CreateDescribedToggle(
        ToggleContainer,
        "Enable |cFF8080FF" .. statusDB .. "|r Indicator",
        "Shows the " .. statusDB:lower() .. " status icon when it applies to the unit.",
        StatusDB.Enabled,
        function(_, _, value) StatusDB.Enabled = value updateCallback() RefreshStatusGUI() end
    )

    local StatusTextureDropdown = AG:Create("Dropdown")
    StatusTextureDropdown:SetList(StatusTextureList)
    StatusTextureDropdown:SetLabel(statusDB .. " Texture")
    StatusTextureDropdown:SetValue(StatusDB.Texture)
    StatusTextureDropdown:SetRelativeWidth(0.5)
    StatusTextureDropdown:SetCallback("OnValueChanged", function(_, _, value) StatusDB.Texture = value updateCallback() end)
    ToggleContainer:AddChild(StatusTextureDropdown)

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Layout & Positioning")

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(StatusDB.Layout[1])
    AnchorFromDropdown:SetRelativeWidth(0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) StatusDB.Layout[1] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(StatusDB.Layout[2])
    AnchorToDropdown:SetRelativeWidth(0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) StatusDB.Layout[2] = value updateCallback() end)
    LayoutContainer:AddChild(AnchorToDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(StatusDB.Layout[3])
    XPosSlider:SetSliderValues(-1000, 1000, 0.1)
    XPosSlider:SetRelativeWidth(0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) StatusDB.Layout[3] = value updateCallback() end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(StatusDB.Layout[4])
    YPosSlider:SetSliderValues(-1000, 1000, 0.1)
    YPosSlider:SetRelativeWidth(0.33)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) StatusDB.Layout[4] = value updateCallback() end)
    LayoutContainer:AddChild(YPosSlider)

    local SizeSlider = AG:Create("Slider")
    SizeSlider:SetLabel("Size")
    SizeSlider:SetValue(StatusDB.Size)
    SizeSlider:SetSliderValues(8, 64, 1)
    SizeSlider:SetRelativeWidth(0.33)
    SizeSlider:SetCallback("OnValueChanged", function(_, _, value) StatusDB.Size = value updateCallback() end)
    LayoutContainer:AddChild(SizeSlider)

    function RefreshStatusGUI()
        if StatusDB.Enabled then
            GUIWidgets.DeepDisable(ToggleContainer, false, Toggle)
            GUIWidgets.DeepDisable(LayoutContainer, false, Toggle)
        else
            GUIWidgets.DeepDisable(ToggleContainer, true, Toggle)
            GUIWidgets.DeepDisable(LayoutContainer, true, Toggle)
        end
    end

    RefreshStatusGUI()
end

local function CreateMouseoverSettings(containerParent, unit, updateCallback)
    local MouseoverDB = UUF.db.profile.Units[unit].Indicators.Mouseover

    local ToggleContainer = GUIWidgets.CreateInlineGroup(containerParent, "Mouseover Settings")

    local Toggle = CreateDescribedToggle(
        ToggleContainer,
        "Enable |cFF8080FFMouseover|r Highlight",
        "Highlights the frame when your cursor moves over it.",
        MouseoverDB.Enabled,
        function(_, _, value) MouseoverDB.Enabled = value updateCallback() RefreshMouseoverGUI() end,
        1
    )

    local ColourPicker = AG:Create("ColorPicker")
    ColourPicker:SetLabel("Highlight Colour")
    ColourPicker:SetColor(MouseoverDB.Colour[1], MouseoverDB.Colour[2], MouseoverDB.Colour[3])
    ColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b) MouseoverDB.Colour = {r, g, b} updateCallback() end)
    ColourPicker:SetHasAlpha(false)
    ColourPicker:SetRelativeWidth(0.33)
    ToggleContainer:AddChild(ColourPicker)

    local OpacitySlider = AG:Create("Slider")
    OpacitySlider:SetLabel("Highlight Opacity")
    OpacitySlider:SetValue(MouseoverDB.HighlightOpacity)
    OpacitySlider:SetSliderValues(0, 1, 0.01)
    OpacitySlider:SetRelativeWidth(0.33)
    OpacitySlider:SetCallback("OnValueChanged", function(_, _, value) MouseoverDB.HighlightOpacity = value updateCallback() end)
    OpacitySlider:SetIsPercent(true)
    ToggleContainer:AddChild(OpacitySlider)

    local StyleDropdown = AG:Create("Dropdown")
    StyleDropdown:SetList({["BORDER"] = "Border", ["OVERLAY"] = "Overlay", ["GRADIENT"] = "Gradient" })
    StyleDropdown:SetLabel("Highlight Style")
    StyleDropdown:SetValue(MouseoverDB.Style)
    StyleDropdown:SetRelativeWidth(0.33)
    StyleDropdown:SetCallback("OnValueChanged", function(_, _, value) MouseoverDB.Style = value updateCallback() end)
    ToggleContainer:AddChild(StyleDropdown)

    function RefreshMouseoverGUI()
        if MouseoverDB.Enabled then
            GUIWidgets.DeepDisable(ToggleContainer, false, Toggle)
        else
            GUIWidgets.DeepDisable(ToggleContainer, true, Toggle)
        end
    end

    RefreshMouseoverGUI()
end

local function CreateTargetIndicatorSettings(containerParent, unit, updateCallback)
    local TargetIndicatorDB = UUF.db.profile.Units[unit].Indicators.Target

    local ToggleContainer = GUIWidgets.CreateInlineGroup(containerParent, "Target Indicator Settings")

    local Toggle = CreateDescribedToggle(
        ToggleContainer,
        "Enable |cFF8080FFTarget Indicator|r",
        "Adds a highlight so it is easier to spot the currently targeted unit.",
        TargetIndicatorDB.Enabled,
        function(_, _, value) TargetIndicatorDB.Enabled = value updateCallback() RefreshTargetIndicatorGUI() end
    )

    local ColourPicker = AG:Create("ColorPicker")
    ColourPicker:SetLabel("Indicator Colour")
    ColourPicker:SetColor(TargetIndicatorDB.Colour[1], TargetIndicatorDB.Colour[2], TargetIndicatorDB.Colour[3])
    ColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b) TargetIndicatorDB.Colour = {r, g, b} updateCallback() end)
    ColourPicker:SetHasAlpha(false)
    ColourPicker:SetRelativeWidth(0.5)
    ToggleContainer:AddChild(ColourPicker)

    function RefreshTargetIndicatorGUI()
        if TargetIndicatorDB.Enabled then
            GUIWidgets.DeepDisable(ToggleContainer, false, Toggle)
        else
            GUIWidgets.DeepDisable(ToggleContainer, true, Toggle)
        end
    end

    RefreshTargetIndicatorGUI()
end

local function CreateTotemsIndicatorSettings(containerParent, unit, updateCallback)
    local TotemsIndicatorDB = UUF.db.profile.Units[unit].Indicators.Totems
    local TotemDurationDB = TotemsIndicatorDB.TotemDuration

    local function UpdateTotemSettings()
        updateCallback()
        if UUF.TOTEM_TEST_MODE then
            UUF:ForEachManagedUnitFrame(unit, function(unitFrame, actualUnit)
                UUF:CreateTestTotems(unitFrame, actualUnit)
            end)
        end
    end

    local TotemDurationContainer = GUIWidgets.CreateInlineGroup(containerParent, "Aura Duration Settings")
    GUIWidgets.CreateInformationTag(TotemDurationContainer, "These options control the cooldown text shown on each active totem icon.")

    local ColourPicker = AG:Create("ColorPicker")
    ColourPicker:SetLabel("Cooldown Text Colour")
    ColourPicker:SetColor(TotemDurationDB.Colour[1], TotemDurationDB.Colour[2], TotemDurationDB.Colour[3], 1)
    ColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b) TotemDurationDB.Colour = {r, g, b} UpdateTotemSettings() end)
    ColourPicker:SetHasAlpha(false)
    ColourPicker:SetRelativeWidth(0.5)
    TotemDurationContainer:AddChild(ColourPicker)

    local ScaleByIconSizeCheckbox = CreateDescribedToggle(
        TotemDurationContainer,
        "Scale Cooldown Text By Icon Size",
        "Automatically resizes the cooldown text when you change the icon size.",
        TotemDurationDB.ScaleByIconSize,
        function(_, _, value) TotemDurationDB.ScaleByIconSize = value UpdateTotemSettings() RefreshFontSizeSlider() end
    )

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(TotemDurationDB.Layout[1])
    AnchorFromDropdown:SetRelativeWidth(0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) TotemDurationDB.Layout[1] = value UpdateTotemSettings() end)
    TotemDurationContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(TotemDurationDB.Layout[2])
    AnchorToDropdown:SetRelativeWidth(0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) TotemDurationDB.Layout[2] = value UpdateTotemSettings() end)
    TotemDurationContainer:AddChild(AnchorToDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(TotemDurationDB.Layout[3])
    XPosSlider:SetSliderValues(-1000, 1000, 0.1)
    XPosSlider:SetRelativeWidth(0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) TotemDurationDB.Layout[3] = value UpdateTotemSettings() end)
    TotemDurationContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(TotemDurationDB.Layout[4])
    YPosSlider:SetSliderValues(-1000, 1000, 0.1)
    YPosSlider:SetRelativeWidth(0.33)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) TotemDurationDB.Layout[4] = value UpdateTotemSettings() end)
    TotemDurationContainer:AddChild(YPosSlider)

    local FontSizeSlider = AG:Create("Slider")
    FontSizeSlider:SetLabel("Font Size")
    FontSizeSlider:SetValue(TotemDurationDB.FontSize)
    FontSizeSlider:SetSliderValues(8, 64, 1)
    FontSizeSlider:SetRelativeWidth(0.33)
    FontSizeSlider:SetCallback("OnValueChanged", function(_, _, value) TotemDurationDB.FontSize = value UpdateTotemSettings() end)
    FontSizeSlider:SetDisabled(TotemDurationDB.ScaleByIconSize)
    TotemDurationContainer:AddChild(FontSizeSlider)

    local ToggleContainer = GUIWidgets.CreateInlineGroup(containerParent, "Totems Settings")

    local Toggle = CreateDescribedToggle(
        ToggleContainer,
        "Enable |cFF8080FFTotems|r",
        "Shows active totems using compact icons beside the player frame.",
        TotemsIndicatorDB.Enabled,
        function(_, _, value) TotemsIndicatorDB.Enabled = value UpdateTotemSettings() RefreshTotemsIndicatorGUI() end
    )

    local SizeSlider = AG:Create("Slider")
    SizeSlider:SetLabel("Icon Size")
    SizeSlider:SetValue(TotemsIndicatorDB.Size)
    SizeSlider:SetSliderValues(8, 64, 1)
    SizeSlider:SetRelativeWidth(0.5)
    SizeSlider:SetCallback("OnValueChanged", function(_, _, value) TotemsIndicatorDB.Size = value UpdateTotemSettings() end)
    ToggleContainer:AddChild(SizeSlider)

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Layout & Positioning")
    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(TotemsIndicatorDB.Layout[1])
    AnchorFromDropdown:SetRelativeWidth(0.33)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) TotemsIndicatorDB.Layout[1] = value UpdateTotemSettings() end)
    LayoutContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(TotemsIndicatorDB.Layout[2])
    AnchorToDropdown:SetRelativeWidth(0.33)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) TotemsIndicatorDB.Layout[2] = value UpdateTotemSettings() end)
    LayoutContainer:AddChild(AnchorToDropdown)

    local GrowthDirectionDropdown = AG:Create("Dropdown")
    GrowthDirectionDropdown:SetList({["RIGHT"] = "Right", ["LEFT"] = "Left", ["UP"] = "Up", ["DOWN"] = "Down"})
    GrowthDirectionDropdown:SetLabel("Growth Direction")
    GrowthDirectionDropdown:SetValue(TotemsIndicatorDB.GrowthDirection)
    GrowthDirectionDropdown:SetRelativeWidth(0.33)
    GrowthDirectionDropdown:SetCallback("OnValueChanged", function(_, _, value) TotemsIndicatorDB.GrowthDirection = value UpdateTotemSettings() end)
    LayoutContainer:AddChild(GrowthDirectionDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(TotemsIndicatorDB.Layout[3])
    XPosSlider:SetSliderValues(-1000, 1000, 0.1)
    XPosSlider:SetRelativeWidth(0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) TotemsIndicatorDB.Layout[3] = value UpdateTotemSettings() end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(TotemsIndicatorDB.Layout[4])
    YPosSlider:SetSliderValues(-1000, 1000, 0.1)
    YPosSlider:SetRelativeWidth(0.33)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) TotemsIndicatorDB.Layout[4] = value UpdateTotemSettings() end)
    LayoutContainer:AddChild(YPosSlider)

    local SpacingSlider = AG:Create("Slider")
    SpacingSlider:SetLabel("Totems Indicator Spacing")
    SpacingSlider:SetValue(TotemsIndicatorDB.Layout[5])
    SpacingSlider:SetSliderValues(0, 100, 1)
    SpacingSlider:SetRelativeWidth(0.33)
    SpacingSlider:SetCallback("OnValueChanged", function(_, _, value) TotemsIndicatorDB.Layout[5] = value UpdateTotemSettings() end)
    LayoutContainer:AddChild(SpacingSlider)

    function RefreshFontSizeSlider()
        FontSizeSlider:SetDisabled(TotemDurationDB.ScaleByIconSize or not TotemsIndicatorDB.Enabled)
    end

    function RefreshTotemsIndicatorGUI()
        local disabled = not TotemsIndicatorDB.Enabled
        GUIWidgets.DeepDisable(ToggleContainer, disabled, Toggle)
        GUIWidgets.DeepDisable(LayoutContainer, disabled, Toggle)
        GUIWidgets.DeepDisable(TotemDurationContainer, disabled, Toggle)
        RefreshFontSizeSlider()
    end

    RefreshTotemsIndicatorGUI()
    EnableTotemsTestMode(unit)
end

local function CreateIndicatorSettings(containerParent, unit)
    local function SelectIndicatorTab(IndicatorContainer, _, IndicatorTab)
        SaveSubTab(unit, "Indicators", IndicatorTab)
        IndicatorContainer:ReleaseChildren()
        if IndicatorTab ~= "Totems" then
            DisableTotemsTestMode(unit)
        end
        if IndicatorTab == "RaidTargetMarker" then
            CreateRaidTargetMarkerSettings(IndicatorContainer, unit, function() UpdateManagedUnitMethod(unit, "UpdateUnitRaidTargetMarker") end)
        elseif IndicatorTab == "ReadyCheck" then
            CreateReadyCheckSettings(IndicatorContainer, unit, function() UpdateManagedUnitMethod(unit, "UpdateUnitReadyCheckIndicator") end)
        elseif IndicatorTab == "Phase" then
            CreatePhaseIndicatorSettings(IndicatorContainer, unit, function() UpdateManagedUnitMethod(unit, "UpdateUnitPhaseIndicator") end)
        elseif IndicatorTab == "RoleIcon" then
            CreateRoleIconSettings(IndicatorContainer, unit, function() UpdateManagedUnitMethod(unit, "UpdateUnitRoleIconIndicator") end)
        elseif IndicatorTab == "Resurrect" then
            CreateResurrectSettings(IndicatorContainer, unit, function() UpdateManagedUnitMethod(unit, "UpdateUnitResurrectIndicator") end)
        elseif IndicatorTab == "Summon" then
            CreateSummonSettings(IndicatorContainer, unit, function() UpdateManagedUnitMethod(unit, "UpdateUnitSummonIndicator") end)
        elseif IndicatorTab == "LeaderAssistant" then
            CreateLeaderAssistaintSettings(IndicatorContainer, unit, function() UpdateManagedUnitMethod(unit, "UpdateUnitLeaderAssistantIndicator") end)
        elseif IndicatorTab == "Resting" then
            CreateStatusSettings(IndicatorContainer, unit, "Resting", function() UpdateManagedUnitMethod(unit, "UpdateUnitRestingIndicator") end)
        elseif IndicatorTab == "Combat" then
            CreateStatusSettings(IndicatorContainer, unit, "Combat", function() UpdateManagedUnitMethod(unit, "UpdateUnitCombatIndicator") end)
        elseif IndicatorTab == "Mouseover" then
            CreateMouseoverSettings(IndicatorContainer, unit, function() UpdateManagedUnitMethod(unit, "UpdateUnitMouseoverIndicator") end)
        elseif IndicatorTab == "TargetIndicator" then
            CreateTargetIndicatorSettings(IndicatorContainer, unit, function() UpdateManagedUnitMethod(unit, "UpdateUnitTargetGlowIndicator") end)
        elseif IndicatorTab == "Totems" then
            CreateTotemsIndicatorSettings(IndicatorContainer, unit, function() UpdateManagedUnitMethod(unit, "UpdateUnitTotems") end)
        end

        C_Timer.After(0.001, function()
            local frame = IndicatorContainer
            while frame do
                if frame.DoLayout then frame:DoLayout() end
                frame = frame.parent
            end
        end)
    end

    local IndicatorContainerTabGroup = AG:Create("TabGroup")
    IndicatorContainerTabGroup:SetLayout("Flow")
    IndicatorContainerTabGroup:SetFullWidth(true)
    if unit == "player" then
        IndicatorContainerTabGroup:SetTabs({
            { text = "Raid Target Marker", value = "RaidTargetMarker" },
            { text = "Leader & Assistant", value = "LeaderAssistant" },
            { text = "Resting", value = "Resting" },
            { text = "Combat", value = "Combat" },
            { text = "Mouseover", value = "Mouseover" },
            { text = "Totems", value = "Totems" },
        })
    elseif unit == "target" then
        IndicatorContainerTabGroup:SetTabs({
            { text = "Raid Target Marker", value = "RaidTargetMarker" },
            { text = "Ready Check", value = "ReadyCheck" },
            { text = "Phase", value = "Phase" },
            { text = "Leader & Assistant", value = "LeaderAssistant" },
            { text = "Combat", value = "Combat" },
            { text = "Mouseover", value = "Mouseover" },
            { text = "Target Indicator", value = "TargetIndicator" },
        })
    elseif unit == "party" then
        IndicatorContainerTabGroup:SetTabs({
            { text = "Raid Target Marker", value = "RaidTargetMarker" },
            { text = "Ready Check", value = "ReadyCheck" },
            { text = "Phase", value = "Phase" },
            { text = "Role Icon", value = "RoleIcon" },
            { text = "Resurrection", value = "Resurrect" },
            { text = "Summon", value = "Summon" },
            { text = "Leader & Assistant", value = "LeaderAssistant" },
            { text = "Mouseover", value = "Mouseover" },
        })
    elseif unit == "raid" then
        IndicatorContainerTabGroup:SetTabs({
            { text = "Raid Target Marker", value = "RaidTargetMarker" },
            { text = "Ready Check", value = "ReadyCheck" },
            { text = "Phase", value = "Phase" },
            { text = "Role Icon", value = "RoleIcon" },
            { text = "Resurrection", value = "Resurrect" },
            { text = "Summon", value = "Summon" },
            { text = "Leader & Assistant", value = "LeaderAssistant" },
            { text = "Mouseover", value = "Mouseover" },
        })
    elseif unit == "targettarget" or unit == "focus" or unit == "focustarget" or unit == "pet" or unit == "boss" then
        IndicatorContainerTabGroup:SetTabs({
            { text = "Raid Target Marker", value = "RaidTargetMarker" },
            { text = "Ready Check", value = "ReadyCheck" },
            { text = "Phase", value = "Phase" },
            { text = "Mouseover", value = "Mouseover" },
            { text = "Target Indicator", value = "TargetIndicator" },
        })
    end
    IndicatorContainerTabGroup:SetCallback("OnGroupSelected", SelectIndicatorTab)
    local defaultIndicatorTab = GetSavedSubTab(unit, "Indicators", "RaidTargetMarker")
    if (unit == "party" or unit == "raid") and (defaultIndicatorTab == "Combat" or defaultIndicatorTab == "TargetIndicator") then
        defaultIndicatorTab = "RaidTargetMarker"
    end
    IndicatorContainerTabGroup:SelectTab(defaultIndicatorTab)
    containerParent:AddChild(IndicatorContainerTabGroup)
end

local function CreateTagSetting(containerParent, unit, tagDB)
    local TagDB = UUF.db.profile.Units[unit].Tags[tagDB]
    local function UpdateTagSettings()
        if IsGroupedTagTestModeActive(unit) then
            RefreshGroupedTestFrames(unit)
            return
        end

        UpdateManagedUnitMethod(unit, "UpdateUnitFrame")
        UUF:RefreshLiveUnitTags(unit)
        UUFG:UpdateAllTags()
    end

    local TagContainer = GUIWidgets.CreateInlineGroup(containerParent, "Tag Settings")
    GUIWidgets.CreateInformationTag(TagContainer, "Enter a tag string below and press Enter to apply it. Use the dropdowns further down to insert tags quickly.")

    local EditBox = AG:Create("EditBox")
    EditBox:SetLabel("Tag")
    EditBox:SetText(TagDB.Tag)
    EditBox:SetRelativeWidth(1)
    EditBox:DisableButton(true)
    EditBox:SetCallback("OnEnterPressed", function(_, _, value) TagDB.Tag = value EditBox:SetText(TagDB.Tag) UpdateTagSettings() end)
    TagContainer:AddChild(EditBox)

    local ColourPicker = AG:Create("ColorPicker")
    ColourPicker:SetLabel("Colour")
    ColourPicker:SetColor(TagDB.Colour[1], TagDB.Colour[2], TagDB.Colour[3], 1)
    ColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b) TagDB.Colour = {r, g, b} UpdateTagSettings() end)
    ColourPicker:SetHasAlpha(false)
    ColourPicker:SetRelativeWidth(0.5)
    TagContainer:AddChild(ColourPicker)

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Layout & Positioning")

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(TagDB.Layout[1])
    AnchorFromDropdown:SetRelativeWidth(0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) TagDB.Layout[1] = value UpdateTagSettings() end)
    LayoutContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(TagDB.Layout[2])
    AnchorToDropdown:SetRelativeWidth(0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) TagDB.Layout[2] = value UpdateTagSettings() end)
    LayoutContainer:AddChild(AnchorToDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(TagDB.Layout[3])
    XPosSlider:SetSliderValues(-1000, 1000, 0.1)
    XPosSlider:SetRelativeWidth(0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) TagDB.Layout[3] = value UpdateTagSettings() end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(TagDB.Layout[4])
    YPosSlider:SetSliderValues(-1000, 1000, 0.1)
    YPosSlider:SetRelativeWidth(0.33)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) TagDB.Layout[4] = value UpdateTagSettings() end)
    LayoutContainer:AddChild(YPosSlider)

    local FontSizeSlider = AG:Create("Slider")
    FontSizeSlider:SetLabel("Font Size")
    FontSizeSlider:SetValue(TagDB.FontSize)
    FontSizeSlider:SetSliderValues(8, 64, 1)
    FontSizeSlider:SetRelativeWidth(0.33)
    FontSizeSlider:SetCallback("OnValueChanged", function(_, _, value) TagDB.FontSize = value UpdateTagSettings() end)
    LayoutContainer:AddChild(FontSizeSlider)

    local TagSelectionContainer = GUIWidgets.CreateInlineGroup(containerParent, "Tag Selection")
    GUIWidgets.CreateInformationTag(TagSelectionContainer, "Use these dropdowns to append tags to the current string. |cFF8080FFPrefix|r indicates a tag that belongs at the start of the text.")

    local HealthTagDropdown = AG:Create("Dropdown")
    HealthTagDropdown:SetList(UUF:FetchTagData("Health")[1], UUF:FetchTagData("Health")[2])
    HealthTagDropdown:SetLabel("Health Tags")
    HealthTagDropdown:SetValue(nil)
    HealthTagDropdown:SetRelativeWidth(0.5)
    HealthTagDropdown:SetCallback("OnValueChanged", function(_, _, value) local currentTag = TagDB.Tag if currentTag and currentTag ~= "" then currentTag = currentTag .. "[" .. value .. "]" else currentTag = "[" .. value .. "]" end EditBox:SetText(currentTag) UUF.db.profile.Units[unit].Tags[tagDB].Tag = currentTag UpdateTagSettings() HealthTagDropdown:SetValue(nil) end)
    TagSelectionContainer:AddChild(HealthTagDropdown)

    local PowerTagDropdown = AG:Create("Dropdown")
    PowerTagDropdown:SetList(UUF:FetchTagData("Power")[1], UUF:FetchTagData("Power")[2])
    PowerTagDropdown:SetLabel("Power Tags")
    PowerTagDropdown:SetValue(nil)
    PowerTagDropdown:SetRelativeWidth(0.5)
    PowerTagDropdown:SetCallback("OnValueChanged", function(_, _, value) local currentTag = TagDB.Tag if currentTag and currentTag ~= "" then currentTag = currentTag .. "[" .. value .. "]" else currentTag = "[" .. value .. "]" end EditBox:SetText(currentTag) UUF.db.profile.Units[unit].Tags[tagDB].Tag = currentTag UpdateTagSettings() PowerTagDropdown:SetValue(nil) end)
    TagSelectionContainer:AddChild(PowerTagDropdown)

    local NameTagDropdown = AG:Create("Dropdown")
    NameTagDropdown:SetList(UUF:FetchTagData("Name")[1], UUF:FetchTagData("Name")[2])
    NameTagDropdown:SetLabel("Name Tags")
    NameTagDropdown:SetValue(nil)
    NameTagDropdown:SetRelativeWidth(0.5)
    NameTagDropdown:SetCallback("OnValueChanged", function(_, _, value) local currentTag = TagDB.Tag if currentTag and currentTag ~= "" then currentTag = currentTag .. "[" .. value .. "]" else currentTag = "[" .. value .. "]" end EditBox:SetText(currentTag) UUF.db.profile.Units[unit].Tags[tagDB].Tag = currentTag UpdateTagSettings() NameTagDropdown:SetValue(nil) end)
    TagSelectionContainer:AddChild(NameTagDropdown)

    local MiscTagDropdown = AG:Create("Dropdown")
    MiscTagDropdown:SetList(UUF:FetchTagData("Misc")[1], UUF:FetchTagData("Misc")[2])
    MiscTagDropdown:SetLabel("Misc Tags")
    MiscTagDropdown:SetValue(nil)
    MiscTagDropdown:SetRelativeWidth(0.5)
    MiscTagDropdown:SetCallback("OnValueChanged", function(_, _, value) local currentTag = TagDB.Tag if currentTag and currentTag ~= "" then currentTag = currentTag .. "[" .. value .. "]" else currentTag = "[" .. value .. "]" end EditBox:SetText(currentTag) UUF.db.profile.Units[unit].Tags[tagDB].Tag = currentTag UpdateTagSettings() MiscTagDropdown:SetValue(nil) end)
    MiscTagDropdown:SetDisabled(#UUF:FetchTagData("Misc") == 0)
    TagSelectionContainer:AddChild(MiscTagDropdown)

    containerParent:DoLayout()
end

local function CreateTagsSettings(containerParent, unit)

    local function SelectTagTab(TagContainer, _, TagTab)
        SaveSubTab(unit, "Tags", TagTab)
        TagContainer:ReleaseChildren()
        CreateTagSetting(TagContainer, unit, TagTab)
        containerParent:DoLayout()
    end

    local TagContainerTabGroup = AG:Create("TabGroup")
    TagContainerTabGroup:SetLayout("Flow")
    TagContainerTabGroup:SetFullWidth(true)
    TagContainerTabGroup:SetTabs({
        { text = "Tag One", value = "TagOne"},
        { text = "Tag Two", value = "TagTwo"},
        { text = "Tag Three", value = "TagThree"},
        { text = "Tag Four", value = "TagFour"},
        { text = "Tag Five", value = "TagFive"},
    })
    TagContainerTabGroup:SetCallback("OnGroupSelected", SelectTagTab)
    TagContainerTabGroup:SelectTab(GetSavedSubTab(unit, "Tags", "TagOne"))
    containerParent:AddChild(TagContainerTabGroup)

    containerParent:DoLayout()
end

local function CreateSpecificAuraSettings(containerParent, unit, auraDB)
    local AuraDB = UUF.db.profile.Units[unit].Auras[auraDB]
    local function UpdateAuraSettings()
        UpdateManagedUnitMethod(unit, "UpdateUnitAuras")
    end

    local AuraContainer = GUIWidgets.CreateInlineGroup(containerParent, auraDB .. " Settings")

    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel("Enable |cFF8080FF"..auraDB.."|r")
    Toggle:SetValue(AuraDB.Enabled)
    Toggle:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Enabled = value UpdateAuraSettings() RefreshAuraGUI() end)
    Toggle:SetRelativeWidth(0.33)
    AuraContainer:AddChild(Toggle)

    local ShowTypeCheckbox = AG:Create("CheckBox")
    ShowTypeCheckbox:SetLabel("Show " .. auraDB .. " Type Border")
    ShowTypeCheckbox:SetValue(AuraDB.ShowType)
    ShowTypeCheckbox:SetCallback("OnValueChanged", function(_, _, value) AuraDB.ShowType = value UpdateAuraSettings() end)
    ShowTypeCheckbox:SetRelativeWidth(0.33)
    AuraContainer:AddChild(ShowTypeCheckbox)

    local auraBaseFilter = GetAuraBaseFilter(auraDB)
    local auraFilterConfig = GetAuraFilterConfig(auraDB)
    local filterState = ParseAuraFilterState(auraDB, AuraDB.Filter or auraBaseFilter)
    local modifierToggles = {}
    local exclusiveToggles = {}
    local isUpdatingToggles = false

    local function UpdateAuraFilter()
        local builtFilter = BuildAuraFilterFromState(auraDB, filterState)
        AuraDB.Filter = EncodeAuraFilterStringForStorage(builtFilter)
        UpdateAuraSettings()
    end

    local function RefreshFilterToggles()
        isUpdatingToggles = true
        for modifier, toggle in pairs(modifierToggles) do
            toggle:SetValue(filterState.modifiers[modifier] or false)
        end
        for exclusive, toggle in pairs(exclusiveToggles) do
            toggle:SetValue(filterState.exclusive == exclusive)
        end
        isUpdatingToggles = false
    end
    local modifierOrder = GetAuraModifierOrder(auraDB)
    if #modifierOrder > 0 then
        GUIWidgets.CreateHeader(AuraContainer, "Unexclusive Filters")
        for _, modifier in ipairs(modifierOrder) do
            local modData = auraFilterConfig.Modifiers[modifier]
            local ModToggle = AG:Create("CheckBox")
            ModToggle:SetLabel(modData.Title or modifier)
            ModToggle:SetDescription(modData.Desc or "")
            ModToggle:SetValue(filterState.modifiers[modifier] or false)
            ModToggle:SetRelativeWidth(#modifierOrder > 3 and 0.5 or 0.33)
            ModToggle:SetCallback("OnValueChanged", function(_, _, value)
                if isUpdatingToggles then return end
                filterState.modifiers[modifier] = value or nil
                RefreshFilterToggles()
                UpdateAuraFilter()
            end)
            modifierToggles[modifier] = ModToggle
            AuraContainer:AddChild(ModToggle)
        end
    end

    local exclusiveOrder = GetAuraExclusiveOrder(auraDB)
    if #exclusiveOrder > 0 then
        GUIWidgets.CreateHeader(AuraContainer, "Exclusive Filters")

        for _, exclusive in ipairs(exclusiveOrder) do
            local exclData = auraFilterConfig.Exclusive[exclusive]
            local ExclToggle = AG:Create("CheckBox")
            ExclToggle:SetLabel(exclData.Title or exclusive)
            ExclToggle:SetDescription(exclData.Desc or "")
            ExclToggle:SetValue(filterState.exclusive == exclusive)
            ExclToggle:SetRelativeWidth(0.33)
            ExclToggle:SetCallback("OnValueChanged", function(_, _, value)
                if isUpdatingToggles then return end
                if value then
                    filterState.exclusive = exclusive
                else
                    filterState.exclusive = nil
                end
                RefreshFilterToggles()
                UpdateAuraFilter()
            end)
            exclusiveToggles[exclusive] = ExclToggle
            AuraContainer:AddChild(ExclToggle)
        end
    end

    RefreshFilterToggles()

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Layout & Positioning")

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(AuraDB.Layout[1])
    AnchorFromDropdown:SetRelativeWidth(0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Layout[1] = value UpdateAuraSettings() end)
    LayoutContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(AuraDB.Layout[2])
    AnchorToDropdown:SetRelativeWidth(0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Layout[2] = value UpdateAuraSettings() end)
    LayoutContainer:AddChild(AnchorToDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(AuraDB.Layout[3])
    XPosSlider:SetSliderValues(-1000, 1000, 0.1)
    XPosSlider:SetRelativeWidth(0.25)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Layout[3] = value UpdateAuraSettings() end)
    LayoutContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(AuraDB.Layout[4])
    YPosSlider:SetSliderValues(-1000, 1000, 0.1)
    YPosSlider:SetRelativeWidth(0.25)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Layout[4] = value UpdateAuraSettings() end)
    LayoutContainer:AddChild(YPosSlider)

    local SizeSlider = AG:Create("Slider")
    SizeSlider:SetLabel("Size")
    SizeSlider:SetValue(AuraDB.Size)
    SizeSlider:SetSliderValues(8, 64, 1)
    SizeSlider:SetRelativeWidth(0.25)
    SizeSlider:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Size = value UpdateAuraSettings() end)
    LayoutContainer:AddChild(SizeSlider)

    local SpacingSlider = AG:Create("Slider")
    SpacingSlider:SetLabel("Spacing")
    SpacingSlider:SetValue(AuraDB.Layout[5])
    SpacingSlider:SetSliderValues(-5, 5, 1)
    SpacingSlider:SetRelativeWidth(0.25)
    SpacingSlider:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Layout[5] = value UpdateAuraSettings() end)
    LayoutContainer:AddChild(SpacingSlider)

    GUIWidgets.CreateHeader(LayoutContainer, "Layout")

    local NumAurasSlider = AG:Create("Slider")
    NumAurasSlider:SetLabel(auraDB .. " To Display")
    NumAurasSlider:SetValue(AuraDB.Num)
    NumAurasSlider:SetSliderValues(1, 24, 1)
    NumAurasSlider:SetRelativeWidth(0.5)
    NumAurasSlider:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Num = value UpdateAuraSettings() end)
    LayoutContainer:AddChild(NumAurasSlider)

    local PerRowSlider = AG:Create("Slider")
    PerRowSlider:SetLabel(auraDB .. " Per Row")
    PerRowSlider:SetValue(AuraDB.Wrap)
    PerRowSlider:SetSliderValues(1, 24, 1)
    PerRowSlider:SetRelativeWidth(0.5)
    PerRowSlider:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Wrap = value UpdateAuraSettings() end)
    LayoutContainer:AddChild(PerRowSlider)

    local GrowthDirectionDropdown = AG:Create("Dropdown")
    GrowthDirectionDropdown:SetList({ ["LEFT"] = "Left", ["RIGHT"] = "Right"})
    GrowthDirectionDropdown:SetLabel("Growth Direction")
    GrowthDirectionDropdown:SetValue(AuraDB.GrowthDirection)
    GrowthDirectionDropdown:SetRelativeWidth(0.5)
    GrowthDirectionDropdown:SetCallback("OnValueChanged", function(_, _, value) AuraDB.GrowthDirection = value UpdateAuraSettings() end)
    LayoutContainer:AddChild(GrowthDirectionDropdown)

    local WrapDirectionDropdown = AG:Create("Dropdown")
    WrapDirectionDropdown:SetList({ ["UP"] = "Up", ["DOWN"] = "Down"})
    WrapDirectionDropdown:SetLabel("Wrap Direction")
    WrapDirectionDropdown:SetValue(AuraDB.WrapDirection)
    WrapDirectionDropdown:SetRelativeWidth(0.5)
    WrapDirectionDropdown:SetCallback("OnValueChanged", function(_, _, value) AuraDB.WrapDirection = value UpdateAuraSettings() end)
    LayoutContainer:AddChild(WrapDirectionDropdown)

    local CountContainer = GUIWidgets.CreateInlineGroup(containerParent, "Count Settings")

    local CountAnchorFromDropdown = AG:Create("Dropdown")
    CountAnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    CountAnchorFromDropdown:SetLabel("Anchor From")
    CountAnchorFromDropdown:SetValue(AuraDB.Count.Layout[1])
    CountAnchorFromDropdown:SetRelativeWidth(0.5)
    CountAnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Count.Layout[1] = value UpdateAuraSettings() end)
    CountContainer:AddChild(CountAnchorFromDropdown)

    local CountAnchorToDropdown = AG:Create("Dropdown")
    CountAnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    CountAnchorToDropdown:SetLabel("Anchor To")
    CountAnchorToDropdown:SetValue(AuraDB.Count.Layout[2])
    CountAnchorToDropdown:SetRelativeWidth(0.5)
    CountAnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Count.Layout[2] = value UpdateAuraSettings() end)
    CountContainer:AddChild(CountAnchorToDropdown)

    local CountXPosSlider = AG:Create("Slider")
    CountXPosSlider:SetLabel("X Position")
    CountXPosSlider:SetValue(AuraDB.Count.Layout[3])
    CountXPosSlider:SetSliderValues(-1000, 1000, 0.1)
    CountXPosSlider:SetRelativeWidth(0.25)
    CountXPosSlider:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Count.Layout[3] = value UpdateAuraSettings() end)
    CountContainer:AddChild(CountXPosSlider)

    local CountYPosSlider = AG:Create("Slider")
    CountYPosSlider:SetLabel("Y Position")
    CountYPosSlider:SetValue(AuraDB.Count.Layout[4])
    CountYPosSlider:SetSliderValues(-1000, 1000, 0.1)
    CountYPosSlider:SetRelativeWidth(0.25)
    CountYPosSlider:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Count.Layout[4] = value UpdateAuraSettings() end)
    CountContainer:AddChild(CountYPosSlider)

    local FontSizeSlider = AG:Create("Slider")
    FontSizeSlider:SetLabel("Font Size")
    FontSizeSlider:SetValue(AuraDB.Count.FontSize)
    FontSizeSlider:SetSliderValues(8, 64, 1)
    FontSizeSlider:SetRelativeWidth(0.25)
    FontSizeSlider:SetCallback("OnValueChanged", function(_, _, value) AuraDB.Count.FontSize = value UpdateAuraSettings() end)
    CountContainer:AddChild(FontSizeSlider)

    local ColourPicker = AG:Create("ColorPicker")
    ColourPicker:SetLabel("Colour")
    ColourPicker:SetColor(AuraDB.Count.Colour[1], AuraDB.Count.Colour[2], AuraDB.Count.Colour[3], 1)
    ColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b) AuraDB.Count.Colour = {r, g, b} UpdateAuraSettings() end)
    ColourPicker:SetHasAlpha(false)
    ColourPicker:SetRelativeWidth(0.25)
    CountContainer:AddChild(ColourPicker)

    function RefreshAuraGUI()
        if AuraDB.Enabled then
            GUIWidgets.DeepDisable(AuraContainer, false, Toggle)
            GUIWidgets.DeepDisable(LayoutContainer, false, Toggle)
            GUIWidgets.DeepDisable(CountContainer, false, Toggle)
            RefreshFilterToggles()
        else
            GUIWidgets.DeepDisable(AuraContainer, true, Toggle)
            GUIWidgets.DeepDisable(LayoutContainer, true, Toggle)
            GUIWidgets.DeepDisable(CountContainer, true, Toggle)
        end
    end

    RefreshAuraGUI()

    containerParent:DoLayout()
end

local function CreateAuraSettings(containerParent, unit)
    local AurasDB = UUF.db.profile.Units[unit].Auras
    local function UpdateAuraSettings()
        UpdateManagedUnitMethod(unit, "UpdateUnitAuras")
    end
    local AuraDurationContainer = GUIWidgets.CreateInlineGroup(containerParent, "Aura Duration Settings")

    local ColourPicker = AG:Create("ColorPicker")
    ColourPicker:SetLabel("Cooldown Text Colour")
    ColourPicker:SetColor(UUF.db.profile.Units[unit].Auras.AuraDuration.Colour[1], UUF.db.profile.Units[unit].Auras.AuraDuration.Colour[2], UUF.db.profile.Units[unit].Auras.AuraDuration.Colour[3], 1)
    ColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b) UUF.db.profile.Units[unit].Auras.AuraDuration.Colour = {r, g, b} UpdateAuraSettings() end)
    ColourPicker:SetHasAlpha(false)
    ColourPicker:SetRelativeWidth(0.5)
    AuraDurationContainer:AddChild(ColourPicker)

    local ScaleByIconSizeCheckbox = AG:Create("CheckBox")
    ScaleByIconSizeCheckbox:SetLabel("Scale Cooldown Text By Icon Size")
    ScaleByIconSizeCheckbox:SetValue(UUF.db.profile.Units[unit].Auras.AuraDuration.ScaleByIconSize)
    ScaleByIconSizeCheckbox:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.Units[unit].Auras.AuraDuration.ScaleByIconSize = value UpdateAuraSettings() RefreshFontSizeSlider() end)
    ScaleByIconSizeCheckbox:SetRelativeWidth(0.5)
    AuraDurationContainer:AddChild(ScaleByIconSizeCheckbox)

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue(UUF.db.profile.Units[unit].Auras.AuraDuration.Layout[1])
    AnchorFromDropdown:SetRelativeWidth(0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.Units[unit].Auras.AuraDuration.Layout[1] = value UpdateAuraSettings() end)
    AuraDurationContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue(UUF.db.profile.Units[unit].Auras.AuraDuration.Layout[2])
    AnchorToDropdown:SetRelativeWidth(0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.Units[unit].Auras.AuraDuration.Layout[2] = value UpdateAuraSettings() end)
    AuraDurationContainer:AddChild(AnchorToDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(UUF.db.profile.Units[unit].Auras.AuraDuration.Layout[3])
    XPosSlider:SetSliderValues(-1000, 1000, 0.1)
    XPosSlider:SetRelativeWidth(0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.Units[unit].Auras.AuraDuration.Layout[3] = value UpdateAuraSettings() end)
    AuraDurationContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(UUF.db.profile.Units[unit].Auras.AuraDuration.Layout[4])
    YPosSlider:SetSliderValues(-1000, 1000, 0.1)
    YPosSlider:SetRelativeWidth(0.33)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.Units[unit].Auras.AuraDuration.Layout[4] = value UpdateAuraSettings() end)
    AuraDurationContainer:AddChild(YPosSlider)

    local FontSizeSlider = AG:Create("Slider")
    FontSizeSlider:SetLabel("Font Size")
    FontSizeSlider:SetValue(UUF.db.profile.Units[unit].Auras.AuraDuration.FontSize)
    FontSizeSlider:SetSliderValues(8, 64, 1)
    FontSizeSlider:SetRelativeWidth(0.33)
    FontSizeSlider:SetCallback("OnValueChanged", function(_, _, value) UUF.db.profile.Units[unit].Auras.AuraDuration.FontSize = value UpdateAuraSettings() end)
    FontSizeSlider:SetDisabled(UUF.db.profile.Units[unit].Auras.AuraDuration.ScaleByIconSize)
    AuraDurationContainer:AddChild(FontSizeSlider)

    local FrameStrataDropdown = AG:Create("Dropdown")
    FrameStrataDropdown:SetList(FrameStrataList[1], FrameStrataList[2])
    FrameStrataDropdown:SetLabel("Frame Strata")
    FrameStrataDropdown:SetValue(AurasDB.FrameStrata)
    FrameStrataDropdown:SetRelativeWidth(1)
    FrameStrataDropdown:SetCallback("OnValueChanged", function(_, _, value) AurasDB.FrameStrata = value UUF:UpdateUnitAurasStrata(unit) end)
    containerParent:AddChild(FrameStrataDropdown)

    function RefreshFontSizeSlider()
        if UUF.db.profile.Units[unit].Auras.AuraDuration.ScaleByIconSize then
            FontSizeSlider:SetDisabled(true)
        else
            FontSizeSlider:SetDisabled(false)
        end
    end

    local function SelectAuraTab(AuraContainer, _, AuraTab)
        SaveSubTab(unit, "Auras", AuraTab)
        AuraContainer:ReleaseChildren()
        if AuraTab == "Buffs" then
            CreateSpecificAuraSettings(AuraContainer, unit, "Buffs")
        elseif AuraTab == "Debuffs" then
            CreateSpecificAuraSettings(AuraContainer, unit, "Debuffs")
        end
        C_Timer.After(0.001, RefreshFontSizeSlider)
        containerParent:DoLayout()
    end

    local AuraContainerTabGroup = AG:Create("TabGroup")
    AuraContainerTabGroup:SetLayout("Flow")
    AuraContainerTabGroup:SetFullWidth(true)
    AuraContainerTabGroup:SetTabs({ { text = "Buffs", value = "Buffs"}, { text = "Debuffs", value = "Debuffs"}, })
    AuraContainerTabGroup:SetCallback("OnGroupSelected", SelectAuraTab)
    AuraContainerTabGroup:SelectTab(GetSavedSubTab(unit, "Auras", "Buffs"))
    containerParent:AddChild(AuraContainerTabGroup)

    containerParent:DoLayout()
end

local function CreateAuraDurationSettings(containerParent, affectedUnits)
    local AuraDurationContainer = GUIWidgets.CreateInlineGroup(containerParent, "Aura Duration Settings")

    local ColourPicker = AG:Create("ColorPicker")
    ColourPicker:SetLabel("Cooldown Text Colour")
    ColourPicker:SetColor(1, 1, 1, 1)
    ColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b) for _, unitDB in pairs(UUF.db.profile.Units) do unitDB.Auras.AuraDuration.Colour = {r, g, b} end RefreshConfigPreview() end)
    ColourPicker:SetHasAlpha(false)
    ColourPicker:SetRelativeWidth(0.5)
    AddAffectsTooltip(ColourPicker, affectedUnits)
    AuraDurationContainer:AddChild(ColourPicker)

    local ScaleByIconSizeCheckbox = AG:Create("CheckBox")
    ScaleByIconSizeCheckbox:SetLabel("Scale Cooldown Text By Icon Size")
    ScaleByIconSizeCheckbox:SetValue(false)
    ScaleByIconSizeCheckbox:SetCallback("OnValueChanged", function(_, _, value) for _, unitDB in pairs(UUF.db.profile.Units) do unitDB.Auras.AuraDuration.ScaleByIconSize = value end RefreshConfigPreview() end)
    ScaleByIconSizeCheckbox:SetRelativeWidth(0.5)
    AddAffectsTooltip(ScaleByIconSizeCheckbox, affectedUnits)
    AuraDurationContainer:AddChild(ScaleByIconSizeCheckbox)

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetValue("CENTER")
    AnchorFromDropdown:SetRelativeWidth(0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, value) for _, unitDB in pairs(UUF.db.profile.Units) do unitDB.Auras.AuraDuration.Layout[1] = value end RefreshConfigPreview() end)
    AddAffectsTooltip(AnchorFromDropdown, affectedUnits)
    AuraDurationContainer:AddChild(AnchorFromDropdown)

    local AnchorToDropdown = AG:Create("Dropdown")
    AnchorToDropdown:SetList(AnchorPoints[1], AnchorPoints[2])
    AnchorToDropdown:SetLabel("Anchor To")
    AnchorToDropdown:SetValue("CENTER")
    AnchorToDropdown:SetRelativeWidth(0.5)
    AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, value) for _, unitDB in pairs(UUF.db.profile.Units) do unitDB.Auras.AuraDuration.Layout[2] = value end RefreshConfigPreview() end)
    AddAffectsTooltip(AnchorToDropdown, affectedUnits)
    AuraDurationContainer:AddChild(AnchorToDropdown)

    local XPosSlider = AG:Create("Slider")
    XPosSlider:SetLabel("X Position")
    XPosSlider:SetValue(0)
    XPosSlider:SetSliderValues(-1000, 1000, 0.1)
    XPosSlider:SetRelativeWidth(0.33)
    XPosSlider:SetCallback("OnValueChanged", function(_, _, value) for _, unitDB in pairs(UUF.db.profile.Units) do unitDB.Auras.AuraDuration.Layout[3] = value end RefreshConfigPreview() end)
    AddAffectsTooltip(XPosSlider, affectedUnits)
    AuraDurationContainer:AddChild(XPosSlider)

    local YPosSlider = AG:Create("Slider")
    YPosSlider:SetLabel("Y Position")
    YPosSlider:SetValue(0)
    YPosSlider:SetSliderValues(-1000, 1000, 0.1)
    YPosSlider:SetRelativeWidth(0.33)
    YPosSlider:SetCallback("OnValueChanged", function(_, _, value) for _, unitDB in pairs(UUF.db.profile.Units) do unitDB.Auras.AuraDuration.Layout[4] = value end RefreshConfigPreview() end)
    AddAffectsTooltip(YPosSlider, affectedUnits)
    AuraDurationContainer:AddChild(YPosSlider)

    local FontSizeSlider = AG:Create("Slider")
    FontSizeSlider:SetLabel("Font Size")
    FontSizeSlider:SetValue(12)
    FontSizeSlider:SetSliderValues(8, 64, 1)
    FontSizeSlider:SetRelativeWidth(0.33)
    FontSizeSlider:SetCallback("OnValueChanged", function(_, _, value) for _, unitDB in pairs(UUF.db.profile.Units) do unitDB.Auras.AuraDuration.FontSize = value end RefreshConfigPreview() end)
    FontSizeSlider:SetDisabled(false)
    AddAffectsTooltip(FontSizeSlider, affectedUnits)
    AuraDurationContainer:AddChild(FontSizeSlider)
end

local function ForEachUnitSubDatabase(subKey, callback)
    for unit, unitDB in pairs(UUF.db.profile.Units) do
        if unitDB[subKey] then
            callback(unit, unitDB[subKey], unitDB)
        end
    end
end

local function CreateGlobalOverviewSettings(containerParent)
    local OverviewContainer = GUIWidgets.CreateInlineGroup(containerParent, "Overview")

    GUIWidgets.CreateInformationTag(OverviewContainer, "Use the global tabs to apply the same setting across multiple unit frames at once. Leave unit tabs for layout tweaks and special-case behavior.")

    local PresetContainer = GUIWidgets.CreateInlineGroup(OverviewContainer, "Quick Presets")

    local ApplyColours = AG:Create("Button")
    ApplyColours:SetText("Colour Mode")
    ApplyColours:SetRelativeWidth(0.5)
    ApplyColours:SetCallback("OnClick", function()
        ForEachUnitSubDatabase("HealthBar", function(unit, healthBarDB)
            healthBarDB.ColourByClass = true
            healthBarDB.ColourWhenTapped = unit ~= "party" and unit ~= "raid"
            healthBarDB.ColourBackgroundByClass = false
        end)
        RefreshConfigPreview()
    end)
    PresetContainer:AddChild(ApplyColours)

    local RemoveColours = AG:Create("Button")
    RemoveColours:SetText("Dark Mode")
    RemoveColours:SetRelativeWidth(0.5)
    RemoveColours:SetCallback("OnClick", function()
        ForEachUnitSubDatabase("HealthBar", function(_, healthBarDB)
            healthBarDB.ColourByClass = false
            healthBarDB.ColourWhenTapped = false
            healthBarDB.ColourBackgroundByClass = false
        end)
        RefreshConfigPreview()
    end)
    PresetContainer:AddChild(RemoveColours)

    local GroupedFrameContainer = GUIWidgets.CreateInlineGroup(OverviewContainer, "Grouped Frame Settings")

    local ShowPlayerInPartyToggle
    ShowPlayerInPartyToggle = CreateDescribedToggle(
        GroupedFrameContainer,
        "Show Player In Party Frames",
        "Adds your player unit to the party header. This requires a reload because the secure party header must be rebuilt.",
        UUF.db.profile.Units.party.ShowPlayer,
        function(_, _, value)
            PromptReload(
                function()
                    UUF.db.profile.Units.party.ShowPlayer = value
                end,
                function()
                    ShowPlayerInPartyToggle:SetValue(UUF.db.profile.Units.party.ShowPlayer)
                end
            )
        end,
        1,
        {"party"}
    )

    CreateFontSettings(containerParent)
    CreateTextureSettings(containerParent)
    CreateRangeSettings(containerParent)
end

local function CreateGlobalHealthSettings(containerParent)
    local HealthBarDB = UUF.db.profile.Units.player.HealthBar
    local healthUnits = GetUnitsWithSubDatabase("HealthBar")
    local nonGroupedHealthUnits = GetUnitsWithSubDatabase("HealthBar", function(unit)
        return unit ~= "party" and unit ~= "raid"
    end)
    local DeadBackgroundColourPicker
    local function RefreshDeadBackgroundSettings()
        if DeadBackgroundColourPicker then
            DeadBackgroundColourPicker:SetDisabled(HealthBarDB.UseDeadBackground == false)
        end
    end
    local ToggleContainer = GUIWidgets.CreateInlineGroup(containerParent, "Shared Health Settings")

    GUIWidgets.CreateInformationTag(ToggleContainer, "These options write the same health-bar behavior to every unit frame that has a health bar.")

    CreateDescribedToggle(
        ToggleContainer,
        "Foreground Colour by Class / Reaction",
        "Uses class or reaction colors for the health fill across all frames.",
        HealthBarDB.ColourByClass,
        function(_, _, value)
            ForEachUnitSubDatabase("HealthBar", function(_, db) db.ColourByClass = value end)
            RefreshConfigPreview()
        end,
        nil,
        healthUnits
    )

    CreateDescribedToggle(
        ToggleContainer,
        "Background Colour by Class / Reaction",
        "Uses class or reaction colors for missing-health backgrounds across all frames.",
        HealthBarDB.ColourBackgroundByClass,
        function(_, _, value)
            ForEachUnitSubDatabase("HealthBar", function(_, db) db.ColourBackgroundByClass = value end)
            RefreshConfigPreview()
        end,
        nil,
        healthUnits
    )

    CreateDescribedToggle(
        ToggleContainer,
        "Smoothing",
        "Animates health changes instead of snapping them instantly.",
        HealthBarDB.Smoothing,
        function(_, _, value)
            ForEachUnitSubDatabase("HealthBar", function(_, db) db.Smoothing = value end)
            RefreshConfigPreview()
        end,
        nil,
        healthUnits
    )

    CreateDescribedToggle(
        ToggleContainer,
        "Colour When Tapped",
        "Uses tapped coloring on hostile NPC frames where tap ownership matters. Grouped unit frames ignore this.",
        HealthBarDB.ColourWhenTapped,
        function(_, _, value)
            ForEachUnitSubDatabase("HealthBar", function(unit, db)
                if unit ~= "party" and unit ~= "raid" then
                    db.ColourWhenTapped = value
                end
            end)
            RefreshConfigPreview()
        end,
        nil,
        nonGroupedHealthUnits
    )

    CreateDescribedToggle(
        ToggleContainer,
        "Use Dead Background Colour",
        "When enabled, dead or ghost units use the dedicated dead background colour. When disabled, they keep each frame's normal background colour instead.",
        HealthBarDB.UseDeadBackground ~= false,
        function(_, _, value)
            ForEachUnitSubDatabase("HealthBar", function(_, db) db.UseDeadBackground = value end)
            HealthBarDB.UseDeadBackground = value
            RefreshDeadBackgroundSettings()
            RefreshConfigPreview()
        end,
        nil,
        healthUnits
    )

    local ColourContainer = GUIWidgets.CreateInlineGroup(containerParent, "Shared Health Colours")

    GUIWidgets.CreateInformationTag(ColourContainer, "These colours are only used when the class or reaction colour toggles above are disabled.")

    local ForegroundColourPicker = AG:Create("ColorPicker")
    ForegroundColourPicker:SetLabel("Foreground Colour")
    ForegroundColourPicker:SetColor(unpack(HealthBarDB.Foreground))
    ForegroundColourPicker:SetHasAlpha(false)
    ForegroundColourPicker:SetRelativeWidth(0.33)
    ForegroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b)
        ForEachUnitSubDatabase("HealthBar", function(_, db) db.Foreground = {r, g, b} end)
        RefreshConfigPreview()
    end)
    AddAffectsTooltip(ForegroundColourPicker, healthUnits)
    ColourContainer:AddChild(ForegroundColourPicker)

    local BackgroundColourPicker = AG:Create("ColorPicker")
    BackgroundColourPicker:SetLabel("Background Colour")
    BackgroundColourPicker:SetColor(unpack(HealthBarDB.Background))
    BackgroundColourPicker:SetHasAlpha(false)
    BackgroundColourPicker:SetRelativeWidth(0.33)
    BackgroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b)
        ForEachUnitSubDatabase("HealthBar", function(_, db) db.Background = {r, g, b} end)
        RefreshConfigPreview()
    end)
    AddAffectsTooltip(BackgroundColourPicker, healthUnits)
    ColourContainer:AddChild(BackgroundColourPicker)

    DeadBackgroundColourPicker = AG:Create("ColorPicker")
    DeadBackgroundColourPicker:SetLabel("Dead Background Colour")
    DeadBackgroundColourPicker:SetColor(unpack(HealthBarDB.DeadBackground or HealthBarDB.Background))
    DeadBackgroundColourPicker:SetHasAlpha(false)
    DeadBackgroundColourPicker:SetRelativeWidth(0.33)
    DeadBackgroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b)
        ForEachUnitSubDatabase("HealthBar", function(_, db) db.DeadBackground = {r, g, b} end)
        RefreshConfigPreview()
    end)
    AddAffectsTooltip(DeadBackgroundColourPicker, healthUnits)
    ColourContainer:AddChild(DeadBackgroundColourPicker)
    RefreshDeadBackgroundSettings()

    local ForegroundOpacitySlider = AG:Create("Slider")
    ForegroundOpacitySlider:SetLabel("Foreground Opacity")
    ForegroundOpacitySlider:SetValue(HealthBarDB.ForegroundOpacity)
    ForegroundOpacitySlider:SetSliderValues(0, 1, 0.01)
    ForegroundOpacitySlider:SetRelativeWidth(0.5)
    ForegroundOpacitySlider:SetIsPercent(true)
    ForegroundOpacitySlider:SetCallback("OnValueChanged", function(_, _, value)
        ForEachUnitSubDatabase("HealthBar", function(_, db) db.ForegroundOpacity = value end)
        RefreshConfigPreview()
    end)
    AddAffectsTooltip(ForegroundOpacitySlider, healthUnits)
    ColourContainer:AddChild(ForegroundOpacitySlider)

    local BackgroundOpacitySlider = AG:Create("Slider")
    BackgroundOpacitySlider:SetLabel("Background Opacity")
    BackgroundOpacitySlider:SetValue(HealthBarDB.BackgroundOpacity)
    BackgroundOpacitySlider:SetSliderValues(0, 1, 0.01)
    BackgroundOpacitySlider:SetRelativeWidth(0.5)
    BackgroundOpacitySlider:SetIsPercent(true)
    BackgroundOpacitySlider:SetCallback("OnValueChanged", function(_, _, value)
        ForEachUnitSubDatabase("HealthBar", function(_, db) db.BackgroundOpacity = value end)
        RefreshConfigPreview()
    end)
    AddAffectsTooltip(BackgroundOpacitySlider, healthUnits)
    ColourContainer:AddChild(BackgroundOpacitySlider)
end

local function CreateGlobalPowerSettings(containerParent)
    local PowerBarDB = UUF.db.profile.Units.player.PowerBar
    local powerUnits = GetUnitsWithSubDatabase("PowerBar")
    local healerOnlyUnits = GetUnitsWithSubDatabase("PowerBar", function(unit)
        return unit == "party" or unit == "raid"
    end)
    local ToggleContainer = GUIWidgets.CreateInlineGroup(containerParent, "Shared Power Bar Settings")
    local ForegroundColourPicker
    local BackgroundColourPicker
    local BackgroundMultiplierSlider

    local function RefreshPowerSettings()
        if ForegroundColourPicker then
            ForegroundColourPicker:SetDisabled(PowerBarDB.ColourByType or PowerBarDB.ColourByClass)
        end

        if BackgroundColourPicker then
            BackgroundColourPicker:SetDisabled(PowerBarDB.ColourBackgroundByType)
        end

        if BackgroundMultiplierSlider then
            BackgroundMultiplierSlider:SetDisabled(not PowerBarDB.ColourBackgroundByType)
        end
    end

    GUIWidgets.CreateInformationTag(ToggleContainer, "These settings affect the standard power bar on every unit frame that has one.")

    CreateDescribedToggle(
        ToggleContainer,
        "Smooth Updates",
        "Animates power changes instead of snapping them instantly.",
        PowerBarDB.Smooth,
        function(_, _, value)
            ForEachUnitSubDatabase("PowerBar", function(_, db) db.Smooth = value end)
            RefreshConfigPreview()
        end,
        nil,
        powerUnits
    )

    CreateDescribedToggle(
        ToggleContainer,
        "Inverse Growth Direction",
        "Reverses which side the power fill grows from across all power bars.",
        PowerBarDB.Inverse,
        function(_, _, value)
            ForEachUnitSubDatabase("PowerBar", function(_, db) db.Inverse = value end)
            RefreshConfigPreview()
        end,
        nil,
        powerUnits
    )

    CreateDescribedToggle(
        ToggleContainer,
        "Colour By Type",
        "Uses each resource type's color instead of the custom foreground colour.",
        PowerBarDB.ColourByType,
        function(_, _, value)
            ForEachUnitSubDatabase("PowerBar", function(_, db) db.ColourByType = value end)
            RefreshPowerSettings()
            RefreshConfigPreview()
        end,
        nil,
        powerUnits
    )

    CreateDescribedToggle(
        ToggleContainer,
        "Colour By Class",
        "Uses class color for power bars where that makes sense instead of the custom foreground colour.",
        PowerBarDB.ColourByClass,
        function(_, _, value)
            ForEachUnitSubDatabase("PowerBar", function(_, db) db.ColourByClass = value end)
            RefreshPowerSettings()
            RefreshConfigPreview()
        end,
        nil,
        powerUnits
    )

    CreateDescribedToggle(
        ToggleContainer,
        "Colour Background By Power Type",
        "Builds power-bar backgrounds from the resource type and the multiplier below.",
        PowerBarDB.ColourBackgroundByType,
        function(_, _, value)
            ForEachUnitSubDatabase("PowerBar", function(_, db) db.ColourBackgroundByType = value end)
            RefreshPowerSettings()
            RefreshConfigPreview()
        end,
        nil,
        powerUnits
    )

    CreateDescribedToggle(
        ToggleContainer,
        "Show For Healers Only",
        "Only applies to party and raid power bars. Helpful when grouped frames are mostly used for healing.",
        UUF.db.profile.Units.party.PowerBar.OnlyHealers or false,
        function(_, _, value)
            for _, unit in ipairs({"party", "raid"}) do
                if UUF.db.profile.Units[unit] and UUF.db.profile.Units[unit].PowerBar then
                    UUF.db.profile.Units[unit].PowerBar.OnlyHealers = value
                end
            end
            RefreshConfigPreview()
        end,
        nil,
        healerOnlyUnits
    )

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Shared Power Bar Layout")

    local PositionDropdown = AG:Create("Dropdown")
    PositionDropdown:SetList(TopBottomList[1], TopBottomList[2])
    PositionDropdown:SetLabel("Position")
    PositionDropdown:SetValue(PowerBarDB.Position or "BOTTOM")
    PositionDropdown:SetRelativeWidth(0.5)
    PositionDropdown:SetCallback("OnValueChanged", function(_, _, value)
        ForEachUnitSubDatabase("PowerBar", function(_, db) db.Position = value end)
        RefreshConfigPreview()
    end)
    AddAffectsTooltip(PositionDropdown, powerUnits)
    LayoutContainer:AddChild(PositionDropdown)

    local HeightSlider = AG:Create("Slider")
    HeightSlider:SetLabel("Height")
    HeightSlider:SetValue(PowerBarDB.Height)
    HeightSlider:SetSliderValues(1, 64, 0.1)
    HeightSlider:SetRelativeWidth(0.5)
    HeightSlider:SetCallback("OnValueChanged", function(_, _, value)
        ForEachUnitSubDatabase("PowerBar", function(_, db) db.Height = value end)
        RefreshConfigPreview()
    end)
    AddAffectsTooltip(HeightSlider, powerUnits)
    LayoutContainer:AddChild(HeightSlider)

    local ColourContainer = GUIWidgets.CreateInlineGroup(containerParent, "Shared Power Bar Colours")

    ForegroundColourPicker = AG:Create("ColorPicker")
    ForegroundColourPicker:SetLabel("Foreground Colour")
    ForegroundColourPicker:SetColor(unpack(PowerBarDB.Foreground))
    ForegroundColourPicker:SetHasAlpha(true)
    ForegroundColourPicker:SetRelativeWidth(0.33)
    ForegroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a)
        ForEachUnitSubDatabase("PowerBar", function(_, db) db.Foreground = {r, g, b, a} end)
        RefreshConfigPreview()
    end)
    AddAffectsTooltip(ForegroundColourPicker, powerUnits)
    ColourContainer:AddChild(ForegroundColourPicker)

    BackgroundColourPicker = AG:Create("ColorPicker")
    BackgroundColourPicker:SetLabel("Background Colour")
    BackgroundColourPicker:SetColor(unpack(PowerBarDB.Background))
    BackgroundColourPicker:SetHasAlpha(true)
    BackgroundColourPicker:SetRelativeWidth(0.33)
    BackgroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a)
        ForEachUnitSubDatabase("PowerBar", function(_, db) db.Background = {r, g, b, a} end)
        RefreshConfigPreview()
    end)
    AddAffectsTooltip(BackgroundColourPicker, powerUnits)
    ColourContainer:AddChild(BackgroundColourPicker)

    BackgroundMultiplierSlider = AG:Create("Slider")
    BackgroundMultiplierSlider:SetLabel("Background Multiplier")
    BackgroundMultiplierSlider:SetValue(PowerBarDB.BackgroundMultiplier)
    BackgroundMultiplierSlider:SetSliderValues(0, 1, 0.01)
    BackgroundMultiplierSlider:SetRelativeWidth(0.33)
    BackgroundMultiplierSlider:SetIsPercent(true)
    BackgroundMultiplierSlider:SetCallback("OnValueChanged", function(_, _, value)
        ForEachUnitSubDatabase("PowerBar", function(_, db) db.BackgroundMultiplier = value end)
        RefreshConfigPreview()
    end)
    AddAffectsTooltip(BackgroundMultiplierSlider, powerUnits)
    ColourContainer:AddChild(BackgroundMultiplierSlider)

    RefreshPowerSettings()
end

local function CreateGlobalCastBarSettings(containerParent)
    local CastBarDB = UUF.db.profile.Units.player.CastBar
    local castBarUnits = GetUnitsWithSubDatabase("CastBar")
    local ToggleContainer = GUIWidgets.CreateInlineGroup(containerParent, "Shared Cast Bar Settings")

    GUIWidgets.CreateInformationTag(ToggleContainer, "These controls apply to every unit frame that supports a cast bar.")

    CreateDescribedToggle(
        ToggleContainer,
        "Enable Cast Bars",
        "Turns cast bars on or off for all unit frames that support them.",
        CastBarDB.Enabled,
        function(_, _, value)
            ForEachUnitSubDatabase("CastBar", function(_, db) db.Enabled = value end)
            RefreshConfigPreview()
        end,
        nil,
        castBarUnits
    )

    CreateDescribedToggle(
        ToggleContainer,
        "Match Frame Width",
        "Keeps cast bars the same width as their parent frame.",
        CastBarDB.MatchParentWidth,
        function(_, _, value)
            ForEachUnitSubDatabase("CastBar", function(_, db) db.MatchParentWidth = value end)
            RefreshConfigPreview()
        end,
        nil,
        castBarUnits
    )

    CreateDescribedToggle(
        ToggleContainer,
        "Inverse Growth Direction",
        "Reverses which side cast progress grows from.",
        CastBarDB.Inverse,
        function(_, _, value)
            ForEachUnitSubDatabase("CastBar", function(_, db) db.Inverse = value end)
            RefreshConfigPreview()
        end,
        nil,
        castBarUnits
    )

    CreateDescribedToggle(
        ToggleContainer,
        "Show Cast Bar Icon",
        "Toggles the cast spell icon everywhere it is supported.",
        CastBarDB.Icon.Enabled,
        function(_, _, value)
            ForEachUnitSubDatabase("CastBar", function(_, db)
                if db.Icon then db.Icon.Enabled = value end
            end)
            RefreshConfigPreview()
        end,
        nil,
        castBarUnits
    )

    CreateDescribedToggle(
        ToggleContainer,
        "Show Spell Name",
        "Shows or hides the spell-name text on all cast bars.",
        CastBarDB.Text.SpellName.Enabled,
        function(_, _, value)
            ForEachUnitSubDatabase("CastBar", function(_, db)
                if db.Text and db.Text.SpellName then db.Text.SpellName.Enabled = value end
            end)
            RefreshConfigPreview()
        end,
        nil,
        castBarUnits
    )

    CreateDescribedToggle(
        ToggleContainer,
        "Show Duration Text",
        "Shows or hides the duration text on all cast bars.",
        CastBarDB.Text.Duration.Enabled,
        function(_, _, value)
            ForEachUnitSubDatabase("CastBar", function(_, db)
                if db.Text and db.Text.Duration then db.Text.Duration.Enabled = value end
            end)
            RefreshConfigPreview()
        end,
        nil,
        castBarUnits
    )

    local ColourContainer = GUIWidgets.CreateInlineGroup(containerParent, "Shared Cast Bar Colours")

    local ForegroundColourPicker = AG:Create("ColorPicker")
    ForegroundColourPicker:SetLabel("Foreground Colour")
    ForegroundColourPicker:SetColor(unpack(CastBarDB.Foreground))
    ForegroundColourPicker:SetHasAlpha(true)
    ForegroundColourPicker:SetRelativeWidth(0.33)
    ForegroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a)
        ForEachUnitSubDatabase("CastBar", function(_, db) db.Foreground = {r, g, b, a} end)
        RefreshConfigPreview()
    end)
    AddAffectsTooltip(ForegroundColourPicker, castBarUnits)
    ColourContainer:AddChild(ForegroundColourPicker)

    local BackgroundColourPicker = AG:Create("ColorPicker")
    BackgroundColourPicker:SetLabel("Background Colour")
    BackgroundColourPicker:SetColor(unpack(CastBarDB.Background))
    BackgroundColourPicker:SetHasAlpha(true)
    BackgroundColourPicker:SetRelativeWidth(0.33)
    BackgroundColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a)
        ForEachUnitSubDatabase("CastBar", function(_, db) db.Background = {r, g, b, a} end)
        RefreshConfigPreview()
    end)
    AddAffectsTooltip(BackgroundColourPicker, castBarUnits)
    ColourContainer:AddChild(BackgroundColourPicker)

    local NotInterruptibleColourPicker = AG:Create("ColorPicker")
    NotInterruptibleColourPicker:SetLabel("Not Interruptible Colour")
    NotInterruptibleColourPicker:SetColor(unpack(CastBarDB.NotInterruptibleColour))
    NotInterruptibleColourPicker:SetHasAlpha(true)
    NotInterruptibleColourPicker:SetRelativeWidth(0.33)
    NotInterruptibleColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a)
        ForEachUnitSubDatabase("CastBar", function(_, db) db.NotInterruptibleColour = {r, g, b, a} end)
        RefreshConfigPreview()
    end)
    AddAffectsTooltip(NotInterruptibleColourPicker, castBarUnits)
    ColourContainer:AddChild(NotInterruptibleColourPicker)
end

local function CreateGlobalAurasSettings(containerParent)
    local BuffsDB = UUF.db.profile.Units.player.Auras.Buffs
    local DebuffsDB = UUF.db.profile.Units.player.Auras.Debuffs
    local auraUnits = GetUnitsWithSubDatabase("Auras")
    local SharedContainer = GUIWidgets.CreateInlineGroup(containerParent, "Shared Aura Settings")

    GUIWidgets.CreateInformationTag(SharedContainer, "Use these controls for broad aura behavior. Per-unit positioning and filter tuning still live on each unit tab.")

    CreateDescribedToggle(
        SharedContainer,
        "Enable Buffs",
        "Shows buff icons on every frame that has a buff container.",
        BuffsDB.Enabled,
        function(_, _, value)
            ForEachUnitSubDatabase("Auras", function(_, db)
                if db.Buffs then db.Buffs.Enabled = value end
            end)
            RefreshConfigPreview()
        end,
        nil,
        auraUnits
    )

    CreateDescribedToggle(
        SharedContainer,
        "Enable Debuffs",
        "Shows debuff icons on every frame that has a debuff container.",
        DebuffsDB.Enabled,
        function(_, _, value)
            ForEachUnitSubDatabase("Auras", function(_, db)
                if db.Debuffs then db.Debuffs.Enabled = value end
            end)
            RefreshConfigPreview()
        end,
        nil,
        auraUnits
    )

    CreateDescribedToggle(
        SharedContainer,
        "Show Buff Type Border",
        "Displays aura-type border coloring on buffs where supported.",
        BuffsDB.ShowType,
        function(_, _, value)
            ForEachUnitSubDatabase("Auras", function(_, db)
                if db.Buffs then db.Buffs.ShowType = value end
            end)
            RefreshConfigPreview()
        end,
        nil,
        auraUnits
    )

    CreateDescribedToggle(
        SharedContainer,
        "Show Debuff Type Border",
        "Displays aura-type border coloring on debuffs where supported.",
        DebuffsDB.ShowType,
        function(_, _, value)
            ForEachUnitSubDatabase("Auras", function(_, db)
                if db.Debuffs then db.Debuffs.ShowType = value end
            end)
            RefreshConfigPreview()
        end,
        nil,
        auraUnits
    )

    local LayoutContainer = GUIWidgets.CreateInlineGroup(containerParent, "Shared Aura Layout")

    local BuffSizeSlider = AG:Create("Slider")
    BuffSizeSlider:SetLabel("Buff Icon Size")
    BuffSizeSlider:SetValue(BuffsDB.Size)
    BuffSizeSlider:SetSliderValues(8, 64, 1)
    BuffSizeSlider:SetRelativeWidth(0.25)
    BuffSizeSlider:SetCallback("OnValueChanged", function(_, _, value)
        ForEachUnitSubDatabase("Auras", function(_, db)
            if db.Buffs then db.Buffs.Size = value end
        end)
        RefreshConfigPreview()
    end)
    AddAffectsTooltip(BuffSizeSlider, auraUnits)
    LayoutContainer:AddChild(BuffSizeSlider)

    local BuffNumSlider = AG:Create("Slider")
    BuffNumSlider:SetLabel("Buffs To Display")
    BuffNumSlider:SetValue(BuffsDB.Num)
    BuffNumSlider:SetSliderValues(1, 24, 1)
    BuffNumSlider:SetRelativeWidth(0.25)
    BuffNumSlider:SetCallback("OnValueChanged", function(_, _, value)
        ForEachUnitSubDatabase("Auras", function(_, db)
            if db.Buffs then db.Buffs.Num = value end
        end)
        RefreshConfigPreview()
    end)
    AddAffectsTooltip(BuffNumSlider, auraUnits)
    LayoutContainer:AddChild(BuffNumSlider)

    local DebuffSizeSlider = AG:Create("Slider")
    DebuffSizeSlider:SetLabel("Debuff Icon Size")
    DebuffSizeSlider:SetValue(DebuffsDB.Size)
    DebuffSizeSlider:SetSliderValues(8, 64, 1)
    DebuffSizeSlider:SetRelativeWidth(0.25)
    DebuffSizeSlider:SetCallback("OnValueChanged", function(_, _, value)
        ForEachUnitSubDatabase("Auras", function(_, db)
            if db.Debuffs then db.Debuffs.Size = value end
        end)
        RefreshConfigPreview()
    end)
    AddAffectsTooltip(DebuffSizeSlider, auraUnits)
    LayoutContainer:AddChild(DebuffSizeSlider)

    local DebuffNumSlider = AG:Create("Slider")
    DebuffNumSlider:SetLabel("Debuffs To Display")
    DebuffNumSlider:SetValue(DebuffsDB.Num)
    DebuffNumSlider:SetSliderValues(1, 24, 1)
    DebuffNumSlider:SetRelativeWidth(0.25)
    DebuffNumSlider:SetCallback("OnValueChanged", function(_, _, value)
        ForEachUnitSubDatabase("Auras", function(_, db)
            if db.Debuffs then db.Debuffs.Num = value end
        end)
        RefreshConfigPreview()
    end)
    AddAffectsTooltip(DebuffNumSlider, auraUnits)
    LayoutContainer:AddChild(DebuffNumSlider)

    CreateAuraDurationSettings(containerParent, auraUnits)
end

local function CreateGlobalTagSettings(containerParent)
    local TagContainer = GUIWidgets.CreateInlineGroup(containerParent, "Tag Settings")

    GUIWidgets.CreateInformationTag(TagContainer, "These controls affect shared tag behavior across the profile rather than changing the tag strings on individual unit frames.")

    CreateDescribedToggle(
        TagContainer,
        "Use Custom Abbreviations",
        "Uses Unhalted's abbreviation style in tags that support custom shortened values.",
        UUF.db.profile.General.UseCustomAbbreviations,
        function(_, _, value)
            UUF.db.profile.General.UseCustomAbbreviations = value
            UUF:UpdateUnitTags()
        end,
        1,
        OrderedUnitKeys
    )

    local TagIntervalSlider = AG:Create("Slider")
    TagIntervalSlider:SetLabel("Tag Updates Per Second")
    TagIntervalSlider:SetValue(1 / UUF.db.profile.General.TagUpdateInterval)
    TagIntervalSlider:SetSliderValues(1, 10, 0.5)
    TagIntervalSlider:SetRelativeWidth(0.33)
    TagIntervalSlider:SetCallback("OnValueChanged", function(_, _, value)
        UUF.TAG_UPDATE_INTERVAL = 1 / value
        UUF.db.profile.General.TagUpdateInterval = 1 / value
        UUF:SetTagUpdateInterval()
        UUF:UpdateUnitTags()
    end)
    AddAffectsTooltip(TagIntervalSlider, OrderedUnitKeys)
    TagContainer:AddChild(TagIntervalSlider)

    local SeparatorDropdown = AG:Create("Dropdown")
    SeparatorDropdown:SetList(UUF.SEPARATOR_TAGS[1], UUF.SEPARATOR_TAGS[2])
    SeparatorDropdown:SetLabel("Tag Separator")
    SeparatorDropdown:SetValue(UUF.db.profile.General.Separator)
    SeparatorDropdown:SetRelativeWidth(0.33)
    SeparatorDropdown:SetCallback("OnValueChanged", function(_, _, value)
        UUF.db.profile.General.Separator = value
        UUF.SEPARATOR = value
        UUF:UpdateUnitTags()
    end)
    AddAffectsTooltip(SeparatorDropdown, OrderedUnitKeys)
    TagContainer:AddChild(SeparatorDropdown)

    local ToTSeparatorDropdown = AG:Create("Dropdown")
    ToTSeparatorDropdown:SetList(UUF.TOT_SEPARATOR_TAGS[1], UUF.TOT_SEPARATOR_TAGS[2])
    ToTSeparatorDropdown:SetLabel("ToT Separator")
    ToTSeparatorDropdown:SetValue(UUF.db.profile.General.ToTSeparator)
    ToTSeparatorDropdown:SetRelativeWidth(0.33)
    ToTSeparatorDropdown:SetCallback("OnValueChanged", function(_, _, value)
        UUF.db.profile.General.ToTSeparator = value
        UUF.TOT_SEPARATOR = value
        UUF:UpdateUnitTags()
    end)
    AddAffectsTooltip(ToTSeparatorDropdown, OrderedUnitKeys)
    TagContainer:AddChild(ToTSeparatorDropdown)
end

local function CreateGlobalSettings(containerParent)
    local GlobalContainer = GUIWidgets.CreateInlineGroup(containerParent, "Global Settings")
    GUIWidgets.CreateInformationTag(GlobalContainer, "Global tabs are for shared settings that repeat across multiple frames. Use these first when you want consistency across the whole profile.")

    local function SelectGlobalTab(GlobalTabContainer, _, GlobalTab)
        SaveSubTab("global", "Global", GlobalTab)
        GlobalTabContainer:ReleaseChildren()

        if GlobalTab == "Overview" then
            CreateGlobalOverviewSettings(GlobalTabContainer)
        elseif GlobalTab == "Health" then
            CreateGlobalHealthSettings(GlobalTabContainer)
        elseif GlobalTab == "Power" then
            CreateGlobalPowerSettings(GlobalTabContainer)
        elseif GlobalTab == "CastBar" then
            CreateGlobalCastBarSettings(GlobalTabContainer)
        elseif GlobalTab == "Auras" then
            CreateGlobalAurasSettings(GlobalTabContainer)
        elseif GlobalTab == "Tags" then
            CreateGlobalTagSettings(GlobalTabContainer)
        end

        containerParent:DoLayout()
    end

    local GlobalTabGroup = AG:Create("TabGroup")
    GlobalTabGroup:SetLayout("Flow")
    GlobalTabGroup:SetFullWidth(true)
    GlobalTabGroup:SetTabs({
        { text = "Overview", value = "Overview" },
        { text = "Health", value = "Health" },
        { text = "Power", value = "Power" },
        { text = "Cast Bar", value = "CastBar" },
        { text = "Auras", value = "Auras" },
        { text = "Tags", value = "Tags" },
    })
    GlobalTabGroup:SetCallback("OnGroupSelected", SelectGlobalTab)
    GlobalTabGroup:SelectTab(GetSavedSubTab("global", "Global", "Overview"))
    GlobalContainer:AddChild(GlobalTabGroup)
end

local function CreateUnitSettings(containerParent, unit)
    local EnableUnitFrameToggle = AG:Create("CheckBox")
    EnableUnitFrameToggle:SetLabel("Enable |cFFFFCC00"..(UnitDBToUnitPrettyName[unit] or unit) .."|r")
    EnableUnitFrameToggle:SetValue(UUF.db.profile.Units[unit].Enabled)
    EnableUnitFrameToggle:SetCallback("OnValueChanged", function(_, _, value)
        PromptReload(
            function()
                UUF.db.profile.Units[unit].Enabled = value
            end,
            function()
                EnableUnitFrameToggle:SetValue(UUF.db.profile.Units[unit].Enabled)
                containerParent:DoLayout()
            end
        )
    end)
    EnableUnitFrameToggle:SetRelativeWidth(0.5)
    containerParent:AddChild(EnableUnitFrameToggle)

    local HideBlizzardToggle = AG:Create("CheckBox")
    HideBlizzardToggle:SetLabel("Hide Blizzard |cFFFFCC00"..(UnitDBToUnitPrettyName[unit] or unit) .."|r")
    HideBlizzardToggle:SetValue(UUF.db.profile.Units[unit].ForceHideBlizzard)
    HideBlizzardToggle:SetCallback("OnValueChanged", function(_, _, value)
        PromptReload(
            function()
                UUF.db.profile.Units[unit].ForceHideBlizzard = value
            end,
            function()
                HideBlizzardToggle:SetValue(UUF.db.profile.Units[unit].ForceHideBlizzard)
                containerParent:DoLayout()
            end
        )
    end)
    HideBlizzardToggle:SetRelativeWidth(0.5)
    HideBlizzardToggle:SetDisabled(UUF.db.profile.Units[unit].Enabled)
    containerParent:AddChild(HideBlizzardToggle)

    local SettingsContainer = AG:Create("SimpleGroup")
    SettingsContainer:SetFullWidth(true)
    SettingsContainer:SetLayout("Flow")
    containerParent:AddChild(SettingsContainer)

    local function SelectUnitTab(SubContainer, _, UnitTab)
        if not lastSelectedUnitTabs[unit] then lastSelectedUnitTabs[unit] = {} end
        lastSelectedUnitTabs[unit].mainTab = UnitTab
        SubContainer:ReleaseChildren()
        if UnitTab == "Frame" then
            CreateFrameSettings(SubContainer, unit, UUF.db.profile.Units[unit].Frame.AnchorParent and true or false, function() UpdateManagedUnitMethod(unit, "UpdateUnitFrame") end)
        elseif UnitTab == "HealPrediction" then
            CreateHealPredictionSettings(SubContainer, unit, function() UpdateManagedUnitMethod(unit, "UpdateUnitHealPrediction") end)
        elseif UnitTab == "Auras" then
            CreateAuraSettings(SubContainer, unit)
        elseif UnitTab == "PowerBar" then
            CreatePowerBarSettings(SubContainer, unit, function() UpdateManagedUnitMethod(unit, "UpdateUnitPowerBar") end)
        elseif UnitTab == "SecondaryPowerBar" then
            CreateSecondaryPowerBarSettings(SubContainer, unit, function() UUF:UpdateUnitSecondaryPowerBar(UUF[unit:upper()], unit) end)
        elseif UnitTab == "AlternativePowerBar" then
            CreateAlternativePowerBarSettings(SubContainer, unit, function() UpdateManagedUnitMethod(unit, "UpdateUnitAlternativePowerBar") end)
        elseif UnitTab == "CastBar" then
            CreateCastBarSettings(SubContainer, unit)
        elseif UnitTab == "Portrait" then
            CreatePortraitSettings(SubContainer, unit, function() UpdateManagedUnitMethod(unit, "UpdateUnitPortrait") end)
        elseif UnitTab == "Indicators" then
            CreateIndicatorSettings(SubContainer, unit)
        elseif UnitTab == "Tags" then
            CreateTagsSettings(SubContainer, unit)
        end
        if UnitTab == "Auras" then EnableAurasTestMode(unit) else DisableAurasTestMode(unit) end
        if UnitTab == "CastBar" then EnableCastBarTestMode(unit) else DisableCastBarTestMode(unit) end
        containerParent:DoLayout()
    end

    local SubContainerTabGroup = AG:Create("TabGroup")
    SubContainerTabGroup:SetLayout("Flow")
    SubContainerTabGroup:SetFullWidth(true)
    if unit == "player" and UUF:RequiresAlternativePowerBar() then
        SubContainerTabGroup:SetTabs({
            { text = "Frame", value = "Frame"},
            { text = "Heal Prediction", value = "HealPrediction"},
            { text = "Auras", value = "Auras"},
            { text = "Power Bar", value = "PowerBar"},
            { text = "Secondary Power Bar", value = "SecondaryPowerBar"},
            { text = "Alternative Power Bar", value = "AlternativePowerBar"},
            { text = "Cast Bar", value = "CastBar"},
            { text = "Portrait", value = "Portrait"},
            { text = "Indicators", value = "Indicators"},
            { text = "Tags", value = "Tags"},
        })
    elseif unit == "player" then
        SubContainerTabGroup:SetTabs({
            { text = "Frame", value = "Frame"},
            { text = "Heal Prediction", value = "HealPrediction"},
            { text = "Auras", value = "Auras"},
            { text = "Power Bar", value = "PowerBar"},
            { text = "Secondary Power Bar", value = "SecondaryPowerBar"},
            { text = "Cast Bar", value = "CastBar"},
            { text = "Portrait", value = "Portrait"},
            { text = "Indicators", value = "Indicators"},
            { text = "Tags", value = "Tags"},
        })
    elseif unit == "raid" then
        SubContainerTabGroup:SetTabs({
            { text = "Frame", value = "Frame"},
            { text = "Heal Prediction", value = "HealPrediction"},
            { text = "Auras", value = "Auras"},
            { text = "Power Bar", value = "PowerBar"},
            { text = "Indicators", value = "Indicators"},
            { text = "Tags", value = "Tags"},
        })
    elseif unit ~= "targettarget" and unit ~= "focustarget" then
        SubContainerTabGroup:SetTabs({
            { text = "Frame", value = "Frame"},
            { text = "Heal Prediction", value = "HealPrediction"},
            { text = "Auras", value = "Auras"},
            { text = "Power Bar", value = "PowerBar"},
            { text = "Cast Bar", value = "CastBar"},
            { text = "Portrait", value = "Portrait"},
            { text = "Indicators", value = "Indicators"},
            { text = "Tags", value = "Tags"},
        })
    else
        SubContainerTabGroup:SetTabs({
            { text = "Frame", value = "Frame"},
            { text = "Heal Prediction", value = "HealPrediction"},
            { text = "Auras", value = "Auras"},
            { text = "Power Bar", value = "PowerBar"},
            { text = "Indicators", value = "Indicators"},
            { text = "Tags", value = "Tags"},
        })
    end
    SubContainerTabGroup:SetCallback("OnGroupSelected", SelectUnitTab)
    local defaultMainTab = GetSavedMainTab(unit, "Frame")
    if unit == "raid" and (defaultMainTab == "CastBar" or defaultMainTab == "Portrait") then
        defaultMainTab = "Frame"
    end
    SubContainerTabGroup:SelectTab(defaultMainTab)
    SettingsContainer:AddChild(SubContainerTabGroup)

    GUIWidgets.DeepDisable(SettingsContainer, not UUF.db.profile.Units[unit].Enabled)

    containerParent:DoLayout()
end

local function CreateTagSettings(containerParent)

    local function DrawTagContainer(TagContainer, TagGroup)
        local TagsList, TagOrder = UUF:FetchTagData(TagGroup)[1], UUF:FetchTagData(TagGroup)[2]

        local SortedTagsList = {}
        for _, tag in ipairs(TagOrder) do
            if TagsList[tag] then
                SortedTagsList[tag] = TagsList[tag]
            end
        end

        for _, Tag in ipairs(TagOrder) do
            local Desc = SortedTagsList[Tag]
            local TagDesc = AG:Create("Label")
            TagDesc:SetText(Desc)
            TagDesc:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
            TagDesc:SetRelativeWidth(0.5)
            TagContainer:AddChild(TagDesc)

            local TagValue = AG:Create("EditBox")
            TagValue:SetText("[" .. Tag .. "]")
            TagValue:SetCallback("OnTextChanged", function(widget, event, value) TagValue:ClearFocus() TagValue:SetText("[" .. Tag .. "]") end)
            TagValue:SetRelativeWidth(0.5)
            TagContainer:AddChild(TagValue)
        end
    end

    local function SelectedGroup(TagContainer, _, TagGroup)
        TagContainer:ReleaseChildren()
        if TagGroup == "Health" then
            DrawTagContainer(TagContainer, "Health")
        elseif TagGroup == "Name" then
            DrawTagContainer(TagContainer, "Name")
        elseif TagGroup == "Power" then
            DrawTagContainer(TagContainer, "Power")
        elseif TagGroup == "Misc" then
            DrawTagContainer(TagContainer, "Misc")
        end
        TagContainer:DoLayout()
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
    containerParent:AddChild(GUIContainerTabGroup)
    containerParent:DoLayout()
end

local function CreateProfileSettings(containerParent)
    local profileKeys = {}
    local specProfilesList = {}
    local numSpecs = GetNumSpecializations()

    local ProfileContainer = GUIWidgets.CreateInlineGroup(containerParent, "Profile Management")

    local ActiveProfileHeading = AG:Create("Heading")
    ActiveProfileHeading:SetFullWidth(true)
    ProfileContainer:AddChild(ActiveProfileHeading)

    local function RefreshProfiles()
        wipe(profileKeys)
        local tmp = {}
        for _, name in ipairs(UUF.db:GetProfiles(tmp, true)) do profileKeys[name] = name end
        local profilesToDelete = {}
        for k, v in pairs(profileKeys) do profilesToDelete[k] = v end
        profilesToDelete[UUF.db:GetCurrentProfile()] = nil
        SelectProfileDropdown:SetList(profileKeys)
        CopyFromProfileDropdown:SetList(profileKeys)
        GlobalProfileDropdown:SetList(profileKeys)
        DeleteProfileDropdown:SetList(profilesToDelete)
        for i = 1, numSpecs do
            specProfilesList[i]:SetList(profileKeys)
            specProfilesList[i]:SetValue(UUF.db:GetDualSpecProfile(i))
        end
        SelectProfileDropdown:SetValue(UUF.db:GetCurrentProfile())
        CopyFromProfileDropdown:SetValue(nil)
        DeleteProfileDropdown:SetValue(nil)
        if not next(profilesToDelete) then
            DeleteProfileDropdown:SetDisabled(true)
        else
            DeleteProfileDropdown:SetDisabled(false)
        end
        ResetProfileButton:SetText("Reset |cFF8080FF" .. UUF.db:GetCurrentProfile() .. "|r Profile")
        local isUsingGlobal = UUF.db.global.UseGlobalProfile
        ActiveProfileHeading:SetText( "Active Profile: |cFFFFFFFF" .. UUF.db:GetCurrentProfile() .. (isUsingGlobal and " (|cFFFFCC00Global|r)" or "") .. "|r" )
        if UUF.db:IsDualSpecEnabled() then
            SelectProfileDropdown:SetDisabled(true)
            CopyFromProfileDropdown:SetDisabled(true)
            GlobalProfileDropdown:SetDisabled(true)
            DeleteProfileDropdown:SetDisabled(true)
            UseGlobalProfileToggle:SetDisabled(true)
            GlobalProfileDropdown:SetDisabled(true)
        else
            SelectProfileDropdown:SetDisabled(isUsingGlobal)
            CopyFromProfileDropdown:SetDisabled(isUsingGlobal)
            GlobalProfileDropdown:SetDisabled(not isUsingGlobal)
            DeleteProfileDropdown:SetDisabled(isUsingGlobal or not next(profilesToDelete))
            UseGlobalProfileToggle:SetDisabled(false)
            GlobalProfileDropdown:SetDisabled(not isUsingGlobal)
        end
    end

    UUFG.RefreshProfiles = RefreshProfiles -- Exposed for Share.lua

    SelectProfileDropdown = AG:Create("Dropdown")
    SelectProfileDropdown:SetLabel("Select...")
    SelectProfileDropdown:SetRelativeWidth(0.25)
    SelectProfileDropdown:SetCallback("OnValueChanged", function(_, _, value) UUF.db:SetProfile(value) UUF:SetUIScale() UUF:UpdateAllUnitFrames() RefreshProfiles() end)
    ProfileContainer:AddChild(SelectProfileDropdown)

    CopyFromProfileDropdown = AG:Create("Dropdown")
    CopyFromProfileDropdown:SetLabel("Copy From...")
    CopyFromProfileDropdown:SetRelativeWidth(0.25)
    CopyFromProfileDropdown:SetCallback("OnValueChanged", function(_, _, value) UUF:CreatePrompt("Copy Profile", "Are you sure you want to copy from |cFF8080FF" .. value .. "|r?\nThis will |cFFFF4040overwrite|r your current profile settings.", function() UUF.db:CopyProfile(value) UUF:SetUIScale() UUF:UpdateAllUnitFrames() RefreshProfiles() end) end)
    ProfileContainer:AddChild(CopyFromProfileDropdown)

    DeleteProfileDropdown = AG:Create("Dropdown")
    DeleteProfileDropdown:SetLabel("Delete...")
    DeleteProfileDropdown:SetRelativeWidth(0.25)
    DeleteProfileDropdown:SetCallback("OnValueChanged", function(_, _, value) if value ~= UUF.db:GetCurrentProfile() then UUF:CreatePrompt("Delete Profile", "Are you sure you want to delete |cFF8080FF" .. value .. "|r?", function() UUF.db:DeleteProfile(value) UUF:UpdateAllUnitFrames() RefreshProfiles() end) end end)
    ProfileContainer:AddChild(DeleteProfileDropdown)

    ResetProfileButton = AG:Create("Button")
    ResetProfileButton:SetText("Reset |cFF8080FF" .. UUF.db:GetCurrentProfile() .. "|r Profile")
    ResetProfileButton:SetRelativeWidth(0.25)
    ResetProfileButton:SetCallback("OnClick", function() UUF.db:ResetProfile() UUF:ResolveLSM() UUF:SetUIScale() UUF:UpdateAllUnitFrames() RefreshProfiles() end)
    ProfileContainer:AddChild(ResetProfileButton)

    local CreateProfileEditBox = AG:Create("EditBox")
    CreateProfileEditBox:SetLabel("Profile Name:")
    CreateProfileEditBox:SetText("")
    CreateProfileEditBox:SetRelativeWidth(0.5)
    CreateProfileEditBox:DisableButton(true)
    CreateProfileEditBox:SetCallback("OnEnterPressed", function() CreateProfileEditBox:ClearFocus() end)
    ProfileContainer:AddChild(CreateProfileEditBox)

    local CreateProfileButton = AG:Create("Button")
    CreateProfileButton:SetText("Create Profile")
    CreateProfileButton:SetRelativeWidth(0.5)
    CreateProfileButton:SetCallback("OnClick", function() local profileName = strtrim(CreateProfileEditBox:GetText() or "") if profileName ~= "" then UUF.db:SetProfile(profileName) UUF:SetUIScale() UUF:UpdateAllUnitFrames() RefreshProfiles() CreateProfileEditBox:SetText("") end end)
    ProfileContainer:AddChild(CreateProfileButton)

    local GlobalProfileHeading = AG:Create("Heading")
    GlobalProfileHeading:SetText("Global Profile Settings")
    GlobalProfileHeading:SetFullWidth(true)
    ProfileContainer:AddChild(GlobalProfileHeading)

    GUIWidgets.CreateInformationTag(ProfileContainer, "If |cFF8080FFUse Global Profile Settings|r is enabled, the profile selected below will be used as your active profile.\nThis is useful if you want to use the same profile across multiple characters.")

    UseGlobalProfileToggle = AG:Create("CheckBox")
    UseGlobalProfileToggle:SetLabel("Use Global Profile Settings")
    UseGlobalProfileToggle:SetValue(UUF.db.global.UseGlobalProfile)
    UseGlobalProfileToggle:SetRelativeWidth(0.5)
    UseGlobalProfileToggle:SetCallback("OnValueChanged", function(_, _, value) RefreshProfiles() UUF.db.global.UseGlobalProfile = value if value and UUF.db.global.GlobalProfile and UUF.db.global.GlobalProfile ~= "" then UUF.db:SetProfile(UUF.db.global.GlobalProfile) UUF:SetUIScale() end GlobalProfileDropdown:SetDisabled(not value) for _, child in ipairs(ProfileContainer.children) do if child ~= UseGlobalProfileToggle and child ~= GlobalProfileDropdown then GUIWidgets.DeepDisable(child, value) end end UUF:UpdateAllUnitFrames() RefreshProfiles() end)
    ProfileContainer:AddChild(UseGlobalProfileToggle)

    GlobalProfileDropdown = AG:Create("Dropdown")
    GlobalProfileDropdown:SetLabel("Global Profile...")
    GlobalProfileDropdown:SetRelativeWidth(0.5)
    GlobalProfileDropdown:SetList(profileKeys)
    GlobalProfileDropdown:SetValue(UUF.db.global.GlobalProfile)
    GlobalProfileDropdown:SetCallback("OnValueChanged", function(_, _, value) UUF.db:SetProfile(value) UUF.db.global.GlobalProfile = value UUF:SetUIScale() UUF:UpdateAllUnitFrames() RefreshProfiles() end)
    ProfileContainer:AddChild(GlobalProfileDropdown)

    local SpecProfileContainer = GUIWidgets.CreateInlineGroup(ProfileContainer, "Specialization Profiles")

    local UseDualSpecializationToggle = AG:Create("CheckBox")
    UseDualSpecializationToggle:SetLabel("Enable Specialization Profiles")
    UseDualSpecializationToggle:SetValue(UUF.db:IsDualSpecEnabled())
    UseDualSpecializationToggle:SetRelativeWidth(1)
    UseDualSpecializationToggle:SetCallback("OnValueChanged", function(_, _, value) UUF.db:SetDualSpecEnabled(value) for i = 1, numSpecs do specProfilesList[i]:SetDisabled(not value) end UUF:UpdateAllUnitFrames() RefreshProfiles() end)
    UseDualSpecializationToggle:SetDisabled(UUF.db.global.UseGlobalProfile)
    SpecProfileContainer:AddChild(UseDualSpecializationToggle)

    for i = 1, numSpecs do
        local _, specName = GetSpecializationInfo(i)
        specProfilesList[i] = AG:Create("Dropdown")
        specProfilesList[i]:SetLabel(string.format("%s", specName or ("Spec %d"):format(i)))
        specProfilesList[i]:SetList(profileKeys)
        specProfilesList[i]:SetCallback("OnValueChanged", function(widget, event, value) UUF.db:SetDualSpecProfile(value, i) end)
        specProfilesList[i]:SetRelativeWidth(numSpecs == 2 and 0.5 or numSpecs == 3 and 0.33 or 0.25)
        specProfilesList[i]:SetDisabled(not UUF.db:IsDualSpecEnabled() or UUF.db.global.UseGlobalProfile)
        SpecProfileContainer:AddChild(specProfilesList[i])
    end

    RefreshProfiles()

    local SharingContainer = GUIWidgets.CreateInlineGroup(containerParent, "Profile Sharing")

    local ExportingHeading = AG:Create("Heading")
    ExportingHeading:SetText("Exporting")
    ExportingHeading:SetFullWidth(true)
    SharingContainer:AddChild(ExportingHeading)

    GUIWidgets.CreateInformationTag(SharingContainer, "You can export your profile by pressing |cFF8080FFExport Profile|r button below & share the string with other |cFF8080FFUnhalted|r Unit Frame users.")

    local ExportingEditBox = AG:Create("EditBox")
    ExportingEditBox:SetLabel("Export String...")
    ExportingEditBox:SetText("")
    ExportingEditBox:SetRelativeWidth(0.7)
    ExportingEditBox:DisableButton(true)
    ExportingEditBox:SetCallback("OnEnterPressed", function() ExportingEditBox:ClearFocus() end)
    ExportingEditBox:SetCallback("OnTextChanged", function() ExportingEditBox:ClearFocus() end)
    SharingContainer:AddChild(ExportingEditBox)

    local ExportProfileButton = AG:Create("Button")
    ExportProfileButton:SetText("Export Profile")
    ExportProfileButton:SetRelativeWidth(0.3)
    ExportProfileButton:SetCallback("OnClick", function() ExportingEditBox:SetText(UUF:ExportSavedVariables()) ExportingEditBox:HighlightText() ExportingEditBox:SetFocus() end)
    SharingContainer:AddChild(ExportProfileButton)

    local ImportingHeading = AG:Create("Heading")
    ImportingHeading:SetText("Importing")
    ImportingHeading:SetFullWidth(true)
    SharingContainer:AddChild(ImportingHeading)

    GUIWidgets.CreateInformationTag(SharingContainer, "If you have an exported string, paste it in the |cFF8080FFImport String|r box below & press |cFF8080FFImport Profile|r.")

    local ImportingEditBox = AG:Create("EditBox")
    ImportingEditBox:SetLabel("Import String...")
    ImportingEditBox:SetText("")
    ImportingEditBox:SetRelativeWidth(0.7)
    ImportingEditBox:DisableButton(true)
    ImportingEditBox:SetCallback("OnEnterPressed", function() ImportingEditBox:ClearFocus() end)
    ImportingEditBox:SetCallback("OnTextChanged", function() ImportingEditBox:ClearFocus() end)
    SharingContainer:AddChild(ImportingEditBox)

    local ImportProfileButton = AG:Create("Button")
    ImportProfileButton:SetText("Import Profile")
    ImportProfileButton:SetRelativeWidth(0.3)
    ImportProfileButton:SetCallback("OnClick", function() if ImportingEditBox:GetText() ~= "" then UUF:ImportSavedVariables(ImportingEditBox:GetText()) ImportingEditBox:SetText("") end end)
    SharingContainer:AddChild(ImportProfileButton)
    GlobalProfileDropdown:SetDisabled(not UUF.db.global.UseGlobalProfile)
    if UUF.db.global.UseGlobalProfile then for _, child in ipairs(ProfileContainer.children) do if child ~= UseGlobalProfileToggle and child ~= GlobalProfileDropdown then GUIWidgets.DeepDisable(child, true) end end end
end

function UUF:CreateGUI()
    if isGUIOpen then return end
    if InCombatLockdown() then return end

    isGUIOpen = true

    Container = AG:Create("Frame")
    Container:SetTitle(UUF.PRETTY_ADDON_NAME)
    Container:SetLayout("Fill")
    Container:SetWidth(1100)
    Container:SetHeight(600)
    Container:EnableResize(false)
    Container:SetCallback("OnClose", function(widget)
        AG:Release(widget)
        isGUIOpen = false
        DisableAllTestModes()
    end)

    local function SelectTab(GUIContainer, _, MainTab)
        GUIContainer:ReleaseChildren()

        local Wrapper = AG:Create("SimpleGroup")
        Wrapper:SetFullWidth(true)
        Wrapper:SetFullHeight(true)
        Wrapper:SetLayout("Fill")
        GUIContainer:AddChild(Wrapper)

        if MainTab == "General" then
            local ScrollFrame = GUIWidgets.CreateScrollFrame(Wrapper)

            CreateUIScaleSettings(ScrollFrame)
            CreateColourSettings(ScrollFrame)

            local SupportMeContainer = AG:Create("InlineGroup")
            SupportMeContainer:SetTitle("|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Emotes\\peepoLove.png:18:18|t  How To Support " .. UUF.PRETTY_ADDON_NAME .. " Development")
            SupportMeContainer:SetLayout("Flow")
            SupportMeContainer:SetFullWidth(true)
            ScrollFrame:AddChild(SupportMeContainer)

            local TwitchInteractive = AG:Create("InteractiveLabel")
            TwitchInteractive:SetText("|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Support\\Twitch.png:25:21|t |cFF8080FFTwitch|r")
            TwitchInteractive:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
            TwitchInteractive:SetJustifyV("MIDDLE")
            TwitchInteractive:SetRelativeWidth(0.33)
            TwitchInteractive:SetCallback("OnClick", function() UUF:OpenURL("Support Me on Twitch", "https://www.twitch.tv/unhaltedgb") end)
            TwitchInteractive:SetCallback("OnEnter", function() TwitchInteractive:SetText("|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Support\\Twitch.png:25:21|t |cFFFFFFFFTwitch|r") end)
            TwitchInteractive:SetCallback("OnLeave", function() TwitchInteractive:SetText("|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Support\\Twitch.png:25:21|t |cFF8080FFTwitch|r") end)
            SupportMeContainer:AddChild(TwitchInteractive)

            local DiscordInteractive = AG:Create("InteractiveLabel")
            DiscordInteractive:SetText("|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Support\\Discord.png:21:21|t |cFF8080FFDiscord|r")
            DiscordInteractive:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
            DiscordInteractive:SetJustifyV("MIDDLE")
            DiscordInteractive:SetRelativeWidth(0.33)
            DiscordInteractive:SetCallback("OnClick", function() UUF:OpenURL("Support Me on Discord", "https://discord.gg/UZCgWRYvVE") end)
            DiscordInteractive:SetCallback("OnEnter", function() DiscordInteractive:SetText("|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Support\\Discord.png:21:21|t |cFFFFFFFFDiscord|r") end)
            DiscordInteractive:SetCallback("OnLeave", function() DiscordInteractive:SetText("|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Support\\Discord.png:21:21|t |cFF8080FFDiscord|r") end)
            SupportMeContainer:AddChild(DiscordInteractive)

            local GithubInteractive = AG:Create("InteractiveLabel")
            GithubInteractive:SetText("|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Support\\Github.png:21:21|t |cFF8080FFGithub|r")
            GithubInteractive:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
            GithubInteractive:SetJustifyV("MIDDLE")
            GithubInteractive:SetRelativeWidth(0.33)
            GithubInteractive:SetCallback("OnClick", function() UUF:OpenURL("Support Me on Github", "https://github.com/dalehuntgb/UnhaltedUnitFrames") end)
            GithubInteractive:SetCallback("OnEnter", function() GithubInteractive:SetText("|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Support\\Github.png:21:21|t |cFFFFFFFFGithub|r") end)
            GithubInteractive:SetCallback("OnLeave", function() GithubInteractive:SetText("|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Support\\Github.png:21:21|t |cFF8080FFGithub|r") end)
            SupportMeContainer:AddChild(GithubInteractive)

            ScrollFrame:DoLayout()
        elseif MainTab == "Global" then
            local ScrollFrame = GUIWidgets.CreateScrollFrame(Wrapper)

            CreateGlobalSettings(ScrollFrame)

            ScrollFrame:DoLayout()
        elseif MainTab == "Player" then
            local ScrollFrame = GUIWidgets.CreateScrollFrame(Wrapper)

            CreateUnitSettings(ScrollFrame, "player")

            ScrollFrame:DoLayout()
        elseif MainTab == "Target" then
            local ScrollFrame = GUIWidgets.CreateScrollFrame(Wrapper)

            CreateUnitSettings(ScrollFrame, "target")

            ScrollFrame:DoLayout()
        elseif MainTab == "TargetTarget" then
            local ScrollFrame = GUIWidgets.CreateScrollFrame(Wrapper)

            CreateUnitSettings(ScrollFrame, "targettarget")

            ScrollFrame:DoLayout()
        elseif MainTab == "Pet" then
            local ScrollFrame = GUIWidgets.CreateScrollFrame(Wrapper)

            CreateUnitSettings(ScrollFrame, "pet")

            ScrollFrame:DoLayout()
        elseif MainTab == "Party" then
            local ScrollFrame = GUIWidgets.CreateScrollFrame(Wrapper)

            CreateUnitSettings(ScrollFrame, "party")

            ScrollFrame:DoLayout()
        elseif MainTab == "Raid" then
            local ScrollFrame = GUIWidgets.CreateScrollFrame(Wrapper)

            CreateUnitSettings(ScrollFrame, "raid")

            ScrollFrame:DoLayout()
        elseif MainTab == "Focus" then
            local ScrollFrame = GUIWidgets.CreateScrollFrame(Wrapper)

            CreateUnitSettings(ScrollFrame, "focus")

            ScrollFrame:DoLayout()
        elseif MainTab == "FocusTarget" then
            local ScrollFrame = GUIWidgets.CreateScrollFrame(Wrapper)

            CreateUnitSettings(ScrollFrame, "focustarget")

            ScrollFrame:DoLayout()
        elseif MainTab == "Boss" then
            local ScrollFrame = GUIWidgets.CreateScrollFrame(Wrapper)

            CreateUnitSettings(ScrollFrame, "boss")

            ScrollFrame:DoLayout()
        elseif MainTab == "Tags" then
            local ScrollFrame = GUIWidgets.CreateScrollFrame(Wrapper)
            CreateTagSettings(ScrollFrame)
            ScrollFrame:DoLayout()
        elseif MainTab == "Profiles" then
            local ScrollFrame = GUIWidgets.CreateScrollFrame(Wrapper)

            CreateProfileSettings(ScrollFrame)

            ScrollFrame:DoLayout()
        end
        if MainTab == "Boss" then EnableBossFramesTestMode() else DisableBossFramesTestMode() end
        if MainTab == "Party" then EnablePartyFramesTestMode() else DisablePartyFramesTestMode() end
        if MainTab == "Raid" then EnableRaidFramesTestMode() else DisableRaidFramesTestMode() end
        GenerateSupportText(Container)
    end

    local mainNavigationTree = BuildMainNavigationTree()
    local mainNavigationValues = {}
    for _, entry in ipairs(mainNavigationTree) do
        mainNavigationValues[entry.value] = true
    end

    UUFGUI.MainNavigationStatus = UUFGUI.MainNavigationStatus or {}

    local ContainerTreeGroup = AG:Create("TreeGroup")
    ContainerTreeGroup:SetLayout("Fill")
    ContainerTreeGroup:SetFullWidth(true)
    ContainerTreeGroup:SetFullHeight(true)
    ContainerTreeGroup:SetStatusTable(UUFGUI.MainNavigationStatus)
    ContainerTreeGroup:SetTreeWidth(220, false)
    ContainerTreeGroup:SetTree(mainNavigationTree)
    ContainerTreeGroup:SetCallback("OnGroupSelected", SelectTab)
    Container:AddChild(ContainerTreeGroup)

    local initialSection = UUFGUI.MainNavigationStatus.selected
    if not initialSection or not mainNavigationValues[initialSection] then
        initialSection = "General"
    end
    ContainerTreeGroup:SelectByValue(initialSection)
end

function UUFG:OpenUUFGUI()
    UUF:CreateGUI()
end

function UUFG:CloseUUFGUI()
    if isGUIOpen and Container then
        Container:Hide()
    end
end
