local _, UUF = ...
local UnhaltedUnitFrames = LibStub("AceAddon-3.0"):NewAddon("UnhaltedUnitFrames")

function UnhaltedUnitFrames:OnInitialize()
    UUF.db = LibStub("AceDB-3.0"):New("UUFDB", UUF:GetDefaultDB(), true)
    UUF.LDS:EnhanceDatabase(UUF.db, "UnhaltedUnitFrames")
    for k, v in pairs(UUF:GetDefaultDB()) do
        if UUF.db.profile[k] == nil then
            UUF.db.profile[k] = v
        end
    end
    UUF.TAG_UPDATE_INTERVAL = UUF.db.profile.General.TagUpdateInterval or 0.25
    UUF.SEPARATOR = UUF.db.profile.General.Separator or "||"
    UUF.TOT_SEPARATOR = UUF.db.profile.General.ToTSeparator or "»"
    if UUF.db.global.UseGlobalProfile then
        local globalProfile = UUF.db.global.GlobalProfile or UUF.db.global.GlobalProfileName or "Default"
        UUF.db:SetProfile(globalProfile)
    end

    local function HandleProfileChange()
        UUF:UpdateAllUnitFrames()
    end

    UUF.db.RegisterCallback(UUF, "OnProfileChanged", HandleProfileChange)
    UUF.db.RegisterCallback(UUF, "OnProfileCopied", HandleProfileChange)
    UUF.db.RegisterCallback(UUF, "OnProfileReset", HandleProfileChange)

    local playerSpecializationChangedEventFrame = CreateFrame("Frame")
    playerSpecializationChangedEventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    playerSpecializationChangedEventFrame:SetScript("OnEvent", function(_, event, ...)
        if InCombatLockdown() then return end
        if event ~= "PLAYER_SPECIALIZATION_CHANGED" then return end

        local unit = ...
        if unit == "player" then
            UUF:UpdateAllUnitFrames()
        end
    end)
end

function UnhaltedUnitFrames:OnEnable()
    UUF:Init()
    UUF:CreatePositionController()
    UUF:SpawnUnitFrame("player")
    UUF:SpawnUnitFrame("target")
    UUF:SpawnUnitFrame("targettarget")
    UUF:SpawnUnitFrame("focus")
    UUF:SpawnUnitFrame("focustarget")
    UUF:SpawnUnitFrame("pet")
    UUF:SpawnUnitFrame("boss")
    UUF:UpdateOutOfCombatFade()
    
end
