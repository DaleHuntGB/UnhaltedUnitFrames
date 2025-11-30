local _, UUF = ...
UUF.AddOnName = C_AddOns.GetAddOnMetadata("UnhaltedUnitFrames", "Title")
UUF.Version = C_AddOns.GetAddOnMetadata("UnhaltedUnitFrames", "Version")
UUF.Author = C_AddOns.GetAddOnMetadata("UnhaltedUnitFrames", "Author")
UUF.InfoButton = "|A:glueannouncementpopup-icon-info:16:16|a "
UUF.LSM = LibStub("LibSharedMedia-3.0")
UUF.BossFrames = {}
UUF.TargetHighlightEvtFrames = {}
UUF.MaxBossFrames = 10
UUFG = UUFG or {}
UUF.BossTestMode = false
UUF.BackdropTemplate = { bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1, insets = { left = 0, right = 0, top = 0, bottom = 0 }, }
if UUF.LSM then UUF.LSM:Register("border", "WHITE8X8", [[Interface\Buttons\WHITE8X8]]) end
if UUF.LSM then UUF.LSM:Register("statusbar", "Dragonflight", [[Interface\AddOns\UnhaltedUnitFrames\Media\Textures\Dragonflight.tga]]) end
if UUF.LSM then UUF.LSM:Register("background", "Dragonflight", [[Interface\AddOns\UnhaltedUnitFrames\Media\Textures\Dragonflight_BG.tga]]) end
if UUF.LSM then UUF.LSM:Register("statusbar", "Skyline", [[Interface\AddOns\UnhaltedUnitFrames\Media\Textures\Skyline.tga]]) end
if UUF.LSM then UUF.LSM:Register("font", "Avantgarde - Book", [[Interface\AddOns\UnhaltedUnitFrames\Media\Fonts\AvantGarde\Book.ttf]]) end
if UUF.LSM then UUF.LSM:Register("font", "Avantgarde - Book (Oblique)", [[Interface\AddOns\UnhaltedUnitFrames\Media\Fonts\AvantGarde\BookOblique.ttf]]) end
if UUF.LSM then UUF.LSM:Register("font", "Avantgarde - Demi", [[Interface\AddOns\UnhaltedUnitFrames\Media\Fonts\AvantGarde\Demi.ttf]]) end
if UUF.LSM then UUF.LSM:Register("font", "Avantgarde - Regular", [[Interface\AddOns\UnhaltedUnitFrames\Media\Fonts\AvantGarde\Regular.ttf]]) end
if UUF.LSM then UUF.LSM:Register("font", "Expressway - Regular", [[Interface\AddOns\UnhaltedUnitFrames\Media\Fonts\Expressway.ttf]]) end
if UUF.LSM then UUF.LSM:Register("font", "Avante", [[Interface\AddOns\UnhaltedUnitFrames\Media\Fonts\Avante.ttf]]) end

UUF.UnitToFrameName = {
    ["player"] = "UUF_Player",
    ["target"] = "UUF_Target",
    ["targettarget"] = "UUF_TargetTarget",
    ["pet"] = "UUF_Pet",
    ["focus"] = "UUF_Focus",
}

UUF.UnitFrames = {
    ["UUF_Player"] = "player",
    ["UUF_Target"] = "target",
    ["UUF_TargetTarget"] = "targettarget",
    ["UUF_Pet"] = "pet",
    ["UUF_Focus"] = "focus",
    ["UUF_Boss"] = "boss",
}

UUF.StatusTextureMap = {
    ["COMBAT0"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat0.tga",
    ["COMBAT1"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat1.tga",
    ["COMBAT2"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat2.tga",
    ["COMBAT3"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat3.tga",
    ["COMBAT4"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat4.tga",
    ["COMBAT5"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat5.tga",
    ["COMBAT6"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat6.tga",
    ["COMBAT7"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat7.tga",
    ["RESTING0"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting0.tga",
    ["RESTING1"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting1.tga",
    ["RESTING2"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting2.tga",
    ["RESTING3"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting3.tga",
    ["RESTING4"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting4.tga",
    ["RESTING5"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting5.tga",
    ["RESTING6"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting6.tga",
    ["RESTING7"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting7.tga",
}

UUF.LayoutConfig = {
    TOPLEFT     = { anchor="TOPLEFT",   offsetMultiplier=0   },
    TOP         = { anchor="TOP",       offsetMultiplier=0   },
    TOPRIGHT    = { anchor="TOPRIGHT",  offsetMultiplier=0   },
    BOTTOMLEFT  = { anchor="TOPLEFT",   offsetMultiplier=1   },
    BOTTOM      = { anchor="TOP",       offsetMultiplier=1   },
    BOTTOMRIGHT = { anchor="TOPRIGHT",  offsetMultiplier=1   },
    CENTER      = { anchor="CENTER",    offsetMultiplier=0.5, isCenter=true },
    LEFT        = { anchor="LEFT",      offsetMultiplier=0.5, isCenter=true },
    RIGHT       = { anchor="RIGHT",     offsetMultiplier=0.5, isCenter=true },
}

function UUF:Print(MSG)
    print(UUF.AddOnName .. ":|r " .. MSG)
end

function UUF:ResolveMedia()
    local LSM = UUF.LSM
    local General = UUF.db.profile.General
    UUF.Media = UUF.Media or {}
    UUF.Media.Font = LSM:Fetch("font", General.Font) or STANDARD_TEXT_FONT
    UUF.Media.ForegroundTexture = LSM:Fetch("statusbar", General.ForegroundTexture) or "Interface\\RaidFrame\\Raid-Bar-Hp-Fill"
    UUF.Media.BackgroundTexture = LSM:Fetch("background", General.BackgroundTexture) or "Interface\\Buttons\\WHITE8X8"
end

function UUF:SetJustification(anchorFrom)
    if anchorFrom == "TOPLEFT" or anchorFrom == "LEFT" or anchorFrom == "BOTTOMLEFT" then
        return "LEFT"
    elseif anchorFrom == "TOPRIGHT" or anchorFrom == "RIGHT" or anchorFrom == "BOTTOMRIGHT" then
        return "RIGHT"
    else
        return "CENTER"
    end
end

local function SetupSlashCommands()
    SLASH_UUF1 = "/uuf"
    SlashCmdList["UUF"] = function(msg)
        UUF:CreateGUI()
    end
    UUF:Print("'|cFF8080FF/uuf|r' for in-game configuration.")
end

function UUF:Init()
    SetupSlashCommands()
end

local function KillFrame(unitFrame)
    if not unitFrame then return end
    unitFrame:UnregisterAllEvents()
    if unitFrame == PlayerFrame then
        unitFrame:SetAlpha(0)
        unitFrame:SetScale(0.00000001)
        unitFrame:EnableMouse(false)
    else
        unitFrame:Hide()
        unitFrame:SetScript("OnShow", unitFrame.Hide)
    end
end

function UUF:HideDefaultUnitFrames()
    KillFrame(PlayerFrame)
    KillFrame(TargetFrame)
    KillFrame(FocusFrame)
    KillFrame(TargetFrameToT)
    KillFrame(PetFrame)
    KillFrame(Boss1TargetFrame)
    KillFrame(Boss2TargetFrame)
    KillFrame(Boss3TargetFrame)
    KillFrame(Boss4TargetFrame)
    KillFrame(Boss5TargetFrame)
end

function UUF:CreatePrompt(title, text, onAccept, onCancel, acceptText, cancelText)
    StaticPopupDialogs["UUF_PROMPT_DIALOG"] = {
        text = text or "",
        button1 = acceptText or ACCEPT,
        button2 = cancelText or CANCEL,
        OnAccept = function(self, data)
            if data and data.onAccept then
                data.onAccept()
            end
        end,
        OnCancel = function(self, data)
            if data and data.onCancel then
                data.onCancel()
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
        showAlert = true,
    }
    local promptDialog = StaticPopup_Show("UUF_PROMPT_DIALOG", title, text)
    if promptDialog then
        promptDialog.data = { onAccept = onAccept, onCancel = onCancel }
        promptDialog:SetFrameStrata("TOOLTIP")
    end
    return promptDialog
end

function UUF:OpenURL(title, urlText)
    StaticPopupDialogs["UUF_URL_POPUP"] = {
        text = title or "",
        button1 = CLOSE,
        hasEditBox = true,
        editBoxWidth = 300,
        OnShow = function(self)
            self.EditBox:SetText(urlText or "")
            self.EditBox:SetFocus()
            self.EditBox:HighlightText()
        end,
        OnAccept = function(self) end,
        EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    local urlDialog = StaticPopup_Show("UUF_URL_POPUP")
    if urlDialog then
        urlDialog:SetFrameStrata("TOOLTIP")
    end
    return urlDialog
end

function UUF:SetUIScale()
    if UUF.db.profile.General.AllowUIScaling then
        UIParent:SetScale(UUF.db.profile.General.UIScale)
    end
end

function UUF:GetPixelPerfectScale()
    local _, screenHeight = GetPhysicalScreenSize()
    local pixelSize = 768 / screenHeight
    return pixelSize
end

function UUF:RequiresAlternatePowerBar()
    local SpecsNeedingAltPower = {
        PRIEST = { 258 },           -- Shadow
        MAGE   = { 62, 63, 64 },    -- Arcane, Fire, Frost
        PALADIN = { 70 },           -- Ret
        SHAMAN  = { 262, 263 },     -- Ele, Enh
        EVOKER  = { 1467, 1473 },   -- Dev, Aug
        DRUID = { 102, 103, 104 },    -- Balance, Feral, Guardian
    }
    local class = select(2, UnitClass("player"))
    local specIndex = GetSpecialization()
    if not specIndex then return false end
    local specID = GetSpecializationInfo(specIndex)
    local classSpecs = SpecsNeedingAltPower[class]
    if not classSpecs then return false end
    for _, requiredSpec in ipairs(classSpecs) do if specID == requiredSpec then return true end end
    return false
end