local _, UUF = ...
UUF.AddOnName = C_AddOns.GetAddOnMetadata("UnhaltedUnitFrames", "Title")
UUF.Version = C_AddOns.GetAddOnMetadata("UnhaltedUnitFrames", "Version")
UUF.Author = C_AddOns.GetAddOnMetadata("UnhaltedUnitFrames", "Author")
UUF.InfoButton = "|A:glueannouncementpopup-icon-info:16:16|a "
UUF.LSM = LibStub("LibSharedMedia-3.0")
UUF.BossFrames = {}
UUF.MaxBossFrames = 10

if UUF.LSM then UUF.LSM:Register("border", "WHITE8X8", [[Interface\Buttons\WHITE8X8]]) end
if UUF.LSM then UUF.LSM:Register("statusbar", "Dragonflight", [[Interface\AddOns\UnhaltedUnitFrames\Media\Textures\Dragonflight.tga]]) end
if UUF.LSM then UUF.LSM:Register("background", "Dragonflight", [[Interface\AddOns\UnhaltedUnitFrames\Media\Textures\Dragonflight_BG.tga]]) end
if UUF.LSM then UUF.LSM:Register("statusbar", "Skyline", [[Interface\AddOns\UnhaltedUnitFrames\Media\Textures\Skyline.tga]]) end

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
    unitFrame:Hide()
    unitFrame:SetScript("OnShow", unitFrame.Hide)
end

function UUF:HideDefaultUnitFrames()
    KillFrame(PlayerFrame)
    KillFrame(TargetFrame)
    KillFrame(FocusFrame)
    KillFrame(TargetFrameToT)
    KillFrame(PetFrame)
end