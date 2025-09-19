local _, UUF = ...
local oUF = UUF.oUF

function UUF:SpawnBossFrames()
    oUF:RegisterStyle("UUF_Boss", function(self)
        UUF.CreateUnitFrame(self, "boss")
    end)
    oUF:SetActiveStyle("UUF_Boss")

    UUF.BossFrames = {}

    for i = 1, 8 do
        local BossFrame = oUF:Spawn("boss" .. i, "UUF_Boss" .. i)
        UUF.BossFrames[i] = BossFrame
        UUF:RegisterRangeFrame(BossFrame, "boss" .. i)
        UUF:RegisterTargetIndicatorFrame(BossFrame, "boss" .. i)

        if UUF.db.profile.boss.Enabled then
            RegisterUnitWatch(BossFrame)
            BossFrame:Show()
        else
            UnregisterUnitWatch(BossFrame)
            BossFrame:Hide()
        end
    end
    UUF:LayoutBossFrames()
end

