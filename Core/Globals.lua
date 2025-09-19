local _, UUF = ...

UUF.AddOnName = C_AddOns.GetAddOnMetadata("UnhaltedUnitFrames", "Title")
UUF.Version = C_AddOns.GetAddOnMetadata("UnhaltedUnitFrames", "Version")
UUF.Author = C_AddOns.GetAddOnMetadata("UnhaltedUnitFrames", "Author")

UUFG = UUFG or {}

UUF.BossTestMode = false
UUF.PartyTestMode = false

UUF.InfoButton = "|A:glueannouncementpopup-icon-info:16:16|a "
-- UUF.InfoButton = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Utility\\Information.tga:14:14|t "
-- UUF.InfoButton = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Emotes\\peepoNoted.png:21:21|t "

UUF.BackdropTemplate = {
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
    insets = { left = 0, right = 0, top = 0, bottom = 0 },
}

UUF.UnitFrames = {
    ["UUF_Player"] = "player",
    ["UUF_Target"] = "target",
    ["UUF_TargetTarget"] = "targettarget",
    ["UUF_Focus"] = "focus",
    ["UUF_FocusTarget"] = "focustarget",
    ["UUF_Pet"] = "pet",
    ["UUF_Boss"] = "boss",
    ["UUF_Party"] = "party",
    ["UUF_Raid"] = "raid",
}

UUF.CapitalizedUnits = {
    ["player"] = "Player",
    ["target"] = "Target",
    ["targettarget"] = "TargetTarget",
    ["focus"] = "Focus",
    ["focustarget"] = "FocusTarget",
    ["pet"] = "Pet",
    ["boss"] = "Boss",
    ["party"] = "Party",
    ["raid"] = "Raid",
}

UUF.RoleTextureSets = {
    ["DEFAULT"] = {
        TANK   = "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES",
        HEALER = "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES",
        DAMAGER    = "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES",
    },
    ["ELVUIV1"] = {
        TANK   = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\RoleIcons\\ElvUIV1\\Tank.tga",
        HEALER = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\RoleIcons\\ElvUIV1\\Healer.tga",
        DAMAGER    = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\RoleIcons\\ElvUIV1\\DPS.tga",
    },
    ["ELVUIV2"] = {
        TANK   = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\RoleIcons\\ElvUIV2\\Tank.tga",
        HEALER = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\RoleIcons\\ElvUIV2\\Healer.tga",
        DAMAGER    = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\RoleIcons\\ElvUIV2\\DPS.tga",
    },
    ["UUFLIGHT"] = {
        TANK   = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\RoleIcons\\White\\Tank.tga",
        HEALER = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\RoleIcons\\White\\Healer.tga",
        DAMAGER    = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\RoleIcons\\White\\DPS.tga",
    },
    ["UUFDARK"] = {
        TANK   = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\RoleIcons\\Dark\\Tank.tga",
        HEALER = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\RoleIcons\\Dark\\Healer.tga",
        DAMAGER    = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\RoleIcons\\Dark\\DPS.tga",
    },
    ["UUFCOLOUR"] = {
        TANK   = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\RoleIcons\\Colour\\Tank.tga",
        HEALER = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\RoleIcons\\Colour\\Healer.tga",
        DAMAGER    = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\RoleIcons\\Colour\\DPS.tga",
    },
}

UUF.StatusTextureMap = {
    ["COMBAT0"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat0",
    ["COMBAT1"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat1",
    ["COMBAT2"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat2",
    ["COMBAT3"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat3",
    ["COMBAT4"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat4",
    ["COMBAT5"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat5",
    ["COMBAT6"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat6",
    ["COMBAT7"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat7",
    ["RESTING0"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting0",
    ["RESTING1"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting1",
    ["RESTING2"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting2",
    ["RESTING3"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting3",
    ["RESTING4"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting4",
    ["RESTING5"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting5",
    ["RESTING6"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting6",
    ["RESTING7"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting7",
}

UUF.ReadyCheckTextureMap = {
    ["DEFAULT"] = {
        READY = "Interface\\RaidFrame\\ReadyCheck-Ready",
        NOTREADY = "Interface\\RaidFrame\\ReadyCheck-NotReady",
        WAITING = "Interface\\RaidFrame\\ReadyCheck-Waiting",
    },
    ["UUFLIGHT"] = {
        READY = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ReadyCheck\\White\\Ready",
        NOTREADY = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ReadyCheck\\White\\NotReady",
        WAITING = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ReadyCheck\\White\\Pending",
    },
    ["UUFDARK"] = {
        READY = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ReadyCheck\\Dark\\Ready",
        NOTREADY = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ReadyCheck\\Dark\\NotReady",
        WAITING = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ReadyCheck\\Dark\\Pending",
    },
    ["UUFCOLOUR"] = {
        READY = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ReadyCheck\\Colour\\Ready",
        NOTREADY = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ReadyCheck\\Colour\\NotReady",
        WAITING = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ReadyCheck\\Colour\\Pending",
    },
}


local PlayerClass = select(2, UnitClass("player"))
UUF.PlayerClassColour = RAID_CLASS_COLORS[PlayerClass]
UUF.PlayerClassColourHex = CreateColor(UUF.PlayerClassColour.r, UUF.PlayerClassColour.g, UUF.PlayerClassColour.b):GenerateHexColor()