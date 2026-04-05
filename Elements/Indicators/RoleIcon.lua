local _, UUF = ...

local ROLE_ICON_TEXTURE_ROOT = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\RoleIcons\\"
local DEFAULT_ROLE_ICON_STYLE = "Default"
local DEFAULT_ROLE_ICON_ATLASES = {
    TANK = "UI-LFG-RoleIcon-Tank-Micro-Raid",
    HEALER = "UI-LFG-RoleIcon-Healer-Micro-Raid",
    DAMAGER = "UI-LFG-RoleIcon-DPS-Micro-Raid",
}
local ROLE_ICON_FILE_NAMES = {
    TANK = "Tank",
    HEALER = "Healer",
    DAMAGER = "DPS",
}
local CUSTOM_ROLE_ICON_STYLES = {
    "Coloured",
    "Coloured_Outline",
    "White",
    "White_Outline",
}
local CUSTOM_ROLE_ICON_TEXTURES = {}
local ROLE_ICON_PREVIEW_SIZE = 16
local ROLE_ICON_PREVIEW_ORDER = {
    "TANK",
    "HEALER",
    "DAMAGER",
}

local function BuildDefaultRoleIconMarkup(role)
    local atlas = DEFAULT_ROLE_ICON_ATLASES[role]
    if not atlas then return "" end

    return ("|A:%s:%d:%d|a"):format(atlas, ROLE_ICON_PREVIEW_SIZE, ROLE_ICON_PREVIEW_SIZE)
end

local function BuildCustomRoleIconMarkup(style, role)
    local texture = CUSTOM_ROLE_ICON_TEXTURES[style] and CUSTOM_ROLE_ICON_TEXTURES[style][role]
    if not texture then return "" end

    return ("|T%s:%d:%d:0:0|t"):format(texture, ROLE_ICON_PREVIEW_SIZE, ROLE_ICON_PREVIEW_SIZE)
end

local function BuildRoleIconStylePreview(style)
    local previewIcons = {}
    local styleLabel = style:gsub("_", " ")

    for _, role in ipairs(ROLE_ICON_PREVIEW_ORDER) do
        local previewIcon
        if style == DEFAULT_ROLE_ICON_STYLE then
            previewIcon = BuildDefaultRoleIconMarkup(role)
        else
            previewIcon = BuildCustomRoleIconMarkup(style, role)
        end

        if previewIcon ~= "" then
            previewIcons[#previewIcons + 1] = previewIcon
        end
    end

    if #previewIcons == 0 then
        return styleLabel
    end

    return ("%s  %s"):format(styleLabel, table.concat(previewIcons, " "))
end

UUF.RoleIconStyleList = UUF.RoleIconStyleList or {
    [DEFAULT_ROLE_ICON_STYLE] = BuildRoleIconStylePreview(DEFAULT_ROLE_ICON_STYLE),
}
UUF.RoleIconStyleOrder = UUF.RoleIconStyleOrder or {
    DEFAULT_ROLE_ICON_STYLE,
}

for _, style in ipairs(CUSTOM_ROLE_ICON_STYLES) do
    local styleTextures = {}
    for role, fileName in pairs(ROLE_ICON_FILE_NAMES) do
        styleTextures[role] = ROLE_ICON_TEXTURE_ROOT .. style .. "\\" .. fileName .. ".tga"
    end
    CUSTOM_ROLE_ICON_TEXTURES[style] = styleTextures
    UUF.RoleIconStyleList[style] = BuildRoleIconStylePreview(style)
    UUF.RoleIconStyleOrder[#UUF.RoleIconStyleOrder + 1] = style
end

local function SetDefaultRoleIcon(indicator, role)
    local atlas = DEFAULT_ROLE_ICON_ATLASES[role]
    if atlas then
        indicator:SetAtlas(atlas, indicator.useAtlasSize)
        indicator:Show()
    else
        indicator:Hide()
    end
end

local function SetCustomRoleIcon(indicator, style, role)
    local texture = CUSTOM_ROLE_ICON_TEXTURES[style] and CUSTOM_ROLE_ICON_TEXTURES[style][role]
    if not texture then return false end

    indicator:SetTexture(texture)
    indicator:SetTexCoord(0, 1, 0, 1)
    indicator:Show()
    return true
end

local function NormalizeRoleIconStyle(style)
    if style == DEFAULT_ROLE_ICON_STYLE or CUSTOM_ROLE_ICON_TEXTURES[style] then
        return style
    end

    return DEFAULT_ROLE_ICON_STYLE
end

local function UpdateCustomRoleIcon(self)
    local indicator = self.GroupRoleIndicator
    if not indicator then return end

    if indicator.PreUpdate then
        indicator:PreUpdate()
    end

    local role = UnitGroupRolesAssigned(self.unit)
    if role == "TANK" or role == "HEALER" or role == "DAMAGER" then
        local style = NormalizeRoleIconStyle(indicator.UUFRoleIconStyle)
        if style == DEFAULT_ROLE_ICON_STYLE or not SetCustomRoleIcon(indicator, style, role) then
            SetDefaultRoleIcon(indicator, role)
        end
    else
        indicator:Hide()
    end

    if indicator.PostUpdate then
        return indicator:PostUpdate(role)
    end
end

local function ApplyRoleIconSettings(roleIcon, roleIconDB, unitFrame)
    roleIcon.useAtlasSize = false
    roleIcon:ClearAllPoints()
    roleIcon:SetSize(roleIconDB.Size, roleIconDB.Size)
    roleIcon:SetPoint(roleIconDB.Layout[1], unitFrame.HighLevelContainer, roleIconDB.Layout[2], roleIconDB.Layout[3], roleIconDB.Layout[4])
    roleIcon.UUFRoleIconStyle = NormalizeRoleIconStyle(roleIconDB.Style)
    roleIcon.Override = roleIcon.UUFRoleIconStyle ~= DEFAULT_ROLE_ICON_STYLE and UpdateCustomRoleIcon or nil
end

function UUF:CreateUnitRoleIconIndicator(unitFrame, unit)
    local RoleIconDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.RoleIcon
    if not RoleIconDB then return end

    local RoleIcon = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit) .. "_RoleIconIndicator", "OVERLAY")
    ApplyRoleIconSettings(RoleIcon, RoleIconDB, unitFrame)

    if RoleIconDB.Enabled then
        unitFrame.GroupRoleIndicator = RoleIcon
    else
        if unitFrame:IsElementEnabled("GroupRoleIndicator") then
            unitFrame:DisableElement("GroupRoleIndicator")
        end
        RoleIcon:Hide()
    end

    return RoleIcon
end

function UUF:UpdateUnitRoleIconIndicator(unitFrame, unit)
    local RoleIconDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.RoleIcon
    if not RoleIconDB then return end

    if RoleIconDB.Enabled then
        unitFrame.GroupRoleIndicator = unitFrame.GroupRoleIndicator or UUF:CreateUnitRoleIconIndicator(unitFrame, unit)

        if not unitFrame:IsElementEnabled("GroupRoleIndicator") then
            unitFrame:EnableElement("GroupRoleIndicator")
        end

        if unitFrame.GroupRoleIndicator then
            ApplyRoleIconSettings(unitFrame.GroupRoleIndicator, RoleIconDB, unitFrame)
            unitFrame.GroupRoleIndicator:Show()
            unitFrame.GroupRoleIndicator:ForceUpdate()
        end
    else
        if not unitFrame.GroupRoleIndicator then return end
        if unitFrame:IsElementEnabled("GroupRoleIndicator") then
            unitFrame:DisableElement("GroupRoleIndicator")
        end
        unitFrame.GroupRoleIndicator:Hide()
        unitFrame.GroupRoleIndicator = nil
    end
end
