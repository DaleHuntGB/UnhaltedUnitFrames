local _, UUF = ...
local UnhaltedUnitFrames = LibStub("AceAddon-3.0"):NewAddon("UnhaltedUnitFrames")

function UnhaltedUnitFrames:OnInitialize()
    UUF.db = LibStub("AceDB-3.0"):New("UUFDB", UUF:GetDefaultDB(), true)
    for k, v in pairs(UUF:GetDefaultDB()) do
        if UUF.db.profile[k] == nil then
            UUF.db.profile[k] = v
        end
    end
    UUF.TagUpdateInterval = UUF.db.profile.General.TagUpdateInterval or 0.25
    if UUF.db.global.UseGlobalProfile then UUF.db:SetProfile(UUF.db.global.GlobalProfile or "Default") end
end

function UnhaltedUnitFrames:OnEnable()
    UUF:Init()
    UUF:CreatePositionController()
    UUF:SpawnUnitFrame("player")
    UUF:SpawnUnitFrame("target")
    UUF:SpawnUnitFrame("targettarget")
    UUF:SpawnUnitFrame("focus")
    UUF:SpawnUnitFrame("pet")
    UUF:SpawnUnitFrame("boss")
end