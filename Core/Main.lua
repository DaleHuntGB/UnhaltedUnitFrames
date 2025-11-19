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
end

function UnhaltedUF:OnEnable()
    UIParent:SetScale(0.5333333333333)
    UUF:Init()
    UUF:HideDefaultUnitFrames()
    UUF:ResolveMedia()
    UUF:CreateUnitFrame("player")
    UUF:CreateUnitFrame("target")
    UUF:CreateUnitFrame("targettarget")
    UUF:CreateUnitFrame("pet")
    UUF:CreateUnitFrame("focus")
    -- for i = 1, UUF.MaxBossFrames do
    --     local BossFrame = UUF:CreateUnitFrame("boss", i)
    --     UUF.BossFrames[i] = BossFrame
    -- end
    -- UUF:LayoutBossFrames()
end