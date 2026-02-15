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
    if UUF.db.global.UseGlobalProfile then UUF.db:SetProfile(UUF.db.global.GlobalProfile or "Default") end
    UUF.db.RegisterCallback(UUF, "OnProfileChanged", function() UUF:UpdateAllUnitFrames() end)
    UUF.db.RegisterCallback(UUF, "OnProfileCopied", function() UUF:UpdateAllUnitFrames() end)
    UUF.db.RegisterCallback(UUF, "OnProfileReset", function() UUF:UpdateAllUnitFrames() end)

    local playerSpecalizationChangedEventFrame = CreateFrame("Frame")
    playerSpecalizationChangedEventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    playerSpecalizationChangedEventFrame:SetScript("OnEvent", function(_, event, ...) if InCombatLockdown() then return end if event == "PLAYER_SPECIALIZATION_CHANGED" then local unit = ... if unit == "player" then UUF:UpdateAllUnitFrames() end end end)
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
end