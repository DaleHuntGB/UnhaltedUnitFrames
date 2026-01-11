local _, UUF = ...
local oUF = UUF.oUF

local function ApplyScripts(unitFrame)
    unitFrame:RegisterForClicks("AnyUp")
    unitFrame:SetAttribute("*type1", "target")
    unitFrame:SetAttribute("*type2", "togglemenu")
end

function UUF:CreateUnitFrame(unitFrame, unit)
    if not unit or not unitFrame then return end
    UUF:CreateUnitContainer(unitFrame, unit)
    if unit ~= "targettarget" and unit ~= "focustarget" then UUF:CreateUnitCastBar(unitFrame, unit) end
    UUF:CreateUnitHealthBar(unitFrame, unit)
    UUF:CreateUnitHealPrediction(unitFrame, unit)
    UUF:CreateUnitPortrait(unitFrame, unit)
    UUF:CreateUnitPowerBar(unitFrame, unit)
    if unit == "player" and UUF:RequiresAlternativePowerBar() then UUF:CreateUnitAlternativePowerBar(unitFrame, unit) end
    UUF:CreateUnitRaidTargetMarker(unitFrame, unit)
    if unit == "player" or unit == "target" then UUF:CreateUnitLeaderAssistantIndicator(unitFrame, unit) end
    if unit == "player" then UUF:CreateUnitCombatIndicator(unitFrame, unit) end
    if unit == "player" then UUF:CreateUnitRestingIndicator(unitFrame, unit) end
    UUF:CreateUnitMouseoverIndicator(unitFrame, unit)
    UUF:CreateUnitTargetGlowIndicator(unitFrame, unit)
    UUF:CreateUnitAuras(unitFrame, unit)
    UUF:CreateUnitTags(unitFrame, unit)
    ApplyScripts(unitFrame)
    return unitFrame
end

function UUF:LayoutBossFrames()
    local Frame = UUF.db.profile.Units.boss.Frame
    if #UUF.BOSS_FRAMES == 0 then return end
    local bossFrames = UUF.BOSS_FRAMES
    if Frame.GrowthDirection == "UP" then
        bossFrames = {}
        for i = #UUF.BOSS_FRAMES, 1, -1 do bossFrames[#bossFrames+1] = UUF.BOSS_FRAMES[i] end
    end
    local layoutConfig = UUF.LayoutConfig[Frame.Layout[1]]
    local frameHeight = bossFrames[1]:GetHeight()
    local containerHeight = (frameHeight + Frame.Layout[5]) * #bossFrames - Frame.Layout[5]
    local offsetY = containerHeight * layoutConfig.offsetMultiplier
    if layoutConfig.isCenter then offsetY = offsetY - (frameHeight / 2) end
    local initialAnchor = AnchorUtil.CreateAnchor(layoutConfig.anchor, UIParent, Frame.Layout[2], Frame.Layout[3], Frame.Layout[4] + offsetY)
    AnchorUtil.VerticalLayout(bossFrames, initialAnchor, Frame.Layout[5])
end

local function SpawnBossUnitFrames()
    for i = 1, UUF.MAX_BOSS_FRAMES do
        local BossFrame = oUF:Spawn("boss" .. i, UUF:FetchFrameName("boss" .. i))
        BossFrame:SetSize(UUF.db.profile.Units.boss.Frame.Width, UUF.db.profile.Units.boss.Frame.Height)
        UUF.BOSS_FRAMES[i] = BossFrame
        UUF["BOSS" .. i] = BossFrame
        UUF:RegisterRangeFrame(UUF:FetchFrameName("boss" .. i), "boss" .. i)
    end
    UUF:LayoutBossFrames()
end

function UUF:SpawnUnitFrame(unit)
    local UnitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)]
    local FrameDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Frame

    oUF:RegisterStyle(UUF:FetchFrameName(unit), function(unitFrame) UUF:CreateUnitFrame(unitFrame, unit) end)
    oUF:SetActiveStyle(UUF:FetchFrameName(unit))

    UUF[unit:upper()] = oUF:Spawn(unit, UUF:FetchFrameName(unit))

    if unit == "player" or unit == "target" then
        local parentFrame = UUF.db.profile.Units[unit].HealthBar.AnchorToCooldownViewer and _G["UUF_CDMAnchor"] or UIParent
        UUF[unit:upper()]:SetPoint(FrameDB.Layout[1], parentFrame, FrameDB.Layout[2], FrameDB.Layout[3], FrameDB.Layout[4])
        UUF[unit:upper()]:SetSize(FrameDB.Width, FrameDB.Height)
    elseif unit == "targettarget" or unit == "focus" or unit == "focustarget" or unit == "pet" then
        local parentFrame = _G[UUF.db.profile.Units[unit].Frame.AnchorParent] or UIParent
        UUF[unit:upper()]:SetPoint(FrameDB.Layout[1], parentFrame, FrameDB.Layout[2], FrameDB.Layout[3], FrameDB.Layout[4])
        UUF[unit:upper()]:SetSize(FrameDB.Width, FrameDB.Height)
    elseif unit == "boss" then
        SpawnBossUnitFrames()
    end

    UUF:RegisterTargetGlowIndicatorFrame(UUF:FetchFrameName(unit), unit)
    UUF:RegisterRangeFrame(UUF:FetchFrameName(unit), unit)

    if UnitDB.Enabled then
        RegisterUnitWatch(UUF[unit:upper()])
        UUF[unit:upper()]:Show()
    else
        UnregisterUnitWatch(UUF[unit:upper()])
        UUF[unit:upper()]:Hide()
    end

    return UUF[unit:upper()]
end

function UUF:UpdateUnitFrame(unitFrame, unit)
    local UnitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)]
    if unit ~= "targettarget" and unit ~= "focustarget" then UUF:UpdateUnitCastBar(unitFrame, unit) end
    UUF:UpdateUnitHealthBar(unitFrame, unit)
    UUF:UpdateUnitHealPrediction(unitFrame, unit)
    UUF:UpdateUnitPortrait(unitFrame, unit)
    UUF:UpdateUnitPowerBar(unitFrame, unit)
    if unit == "player" and UUF:RequiresAlternativePowerBar() then UUF:UpdateUnitAlternativePowerBar(unitFrame, unit) end
    UUF:UpdateUnitRaidTargetMarker(unitFrame, unit)
    if unit == "player" or unit == "target" then UUF:UpdateUnitLeaderAssistantIndicator(unitFrame, unit) end
    if unit == "player" then UUF:UpdateUnitCombatIndicator(unitFrame, unit) end
    if unit == "player" then UUF:UpdateUnitRestingIndicator(unitFrame, unit) end
    UUF:UpdateUnitMouseoverIndicator(unitFrame, unit)
    UUF:UpdateUnitAuras(unitFrame, unit)
    UUF:UpdateUnitTags()
    if UnitDB.Enabled then
        RegisterUnitWatch(unitFrame)
        unitFrame:Show()
    else
        UnregisterUnitWatch(unitFrame)
        unitFrame:Hide()
    end
end

function UUF:UpdateBossFrames()
    for i in pairs(UUF.BOSS_FRAMES) do
        UUF:UpdateUnitFrame(UUF["BOSS"..i], "boss"..i)
    end
    UUF:CreateTestBossFrames()
    UUF:LayoutBossFrames()
end


function UUF:UpdateAllUnitFrames()
    for unit, _ in pairs(UUF.db.profile.Units) do
        if UUF[unit:upper()] then
            UUF:UpdateUnitFrame(UUF[unit:upper()], unit)
        end
    end
end