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
if UUF.LSM then UUF.LSM:Register("border", "WHITE8X8", [[Interface\Buttons\WHITE8X8]]) end
if UUF.LSM then UUF.LSM:Register("statusbar", "Dragonflight", [[Interface\AddOns\UnhaltedUnitFrames\Media\Textures\Dragonflight.tga]]) end
if UUF.LSM then UUF.LSM:Register("background", "Dragonflight", [[Interface\AddOns\UnhaltedUnitFrames\Media\Textures\Dragonflight_BG.tga]]) end
if UUF.LSM then UUF.LSM:Register("statusbar", "Skyline", [[Interface\AddOns\UnhaltedUnitFrames\Media\Textures\Skyline.tga]]) end

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