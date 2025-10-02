local _, UUF = ...
local UnhaltedUF = LibStub("AceAddon-3.0"):NewAddon("UnhaltedUnitFrames")
local LSM = LibStub("LibSharedMedia-3.0")

function UnhaltedUF:OnInitialize()
    UUF.db = LibStub("AceDB-3.0"):New("UnhaltedUFDB", UUF.Defaults, "Default")
        for k, v in pairs(UUF.Defaults) do
        if UUF.db.profile[k] == nil then
            UUF.db.profile[k] = v
        end
    end
    UUF.DP = UUF.db.profile.General.DecimalPlaces or 1
    UUF.TagInterval = UUF.db.profile.General.TagUpdateInterval or 0.25
    UUF.HealthSeparator = UUF.db.profile.General.HealthSeparator or "-"
    UUF.TargetTargetSeparator = UUF.db.profile.General.TargetTargetSeparator or "»"
    if UUF.db.global.UseGlobalProfile then UUF.db:SetProfile(UUF.db.global.GlobalProfile or "Default") end
end

function UnhaltedUF:OnEnable()
    UIParent:SetScale(UUF.db.profile.General.UIScale or 1)
    UUF:ResolveMedia()
    LSM.RegisterCallback(UUF, "LibSharedMedia_Registered", "ResolveMedia")
    LSM.RegisterCallback(UUF, "LibSharedMedia_SetGlobal", "ResolveMedia")
    UUF:Print("'|cFF8080FF/uuf|r' to open the configuration window.")
    UUF:Init()
    UUF:SetupGameMenu()
    UUF:SpawnPlayerFrame()
    UUF:SpawnTargetFrame()
    UUF:SpawnTargetTargetFrame()
    UUF:SpawnFocusFrame()
    UUF:SpawnFocusTargetFrame()
    UUF:SpawnPetFrame()
    UUF:SpawnBossFrames()
    UUF:SpawnPartyFrames()
    UUF:SpawnRaidFrames()
end