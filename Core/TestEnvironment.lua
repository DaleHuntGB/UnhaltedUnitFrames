local _, UUF = ...

function UUF:CreateTestBossFrames()
    UUF:ResolveLSM()
    if UUF.BOSS_TEST_MODE then
        for i, BossFrame in ipairs(UUF.BOSS_FRAMES) do
            BossFrame:SetAttribute("unit", nil)
            UnregisterUnitWatch(BossFrame)
            BossFrame:Show()
        end
    end
end