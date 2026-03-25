local _, UUF = ...

UUF.ReadyCheckIndicatorFrames = UUF.ReadyCheckIndicatorFrames or setmetatable({}, { __mode = "k" })

local READY_CHECK_ATLAS = {
    ready = "UI-LFG-ReadyMark-Raid",
    notready = "UI-LFG-DeclineMark-Raid",
    waiting = "UI-LFG-PendingMark-Raid",
}

local function SetReadyCheckStatusTexture(indicator, status)
    local atlas = READY_CHECK_ATLAS[status]
    if atlas then
        indicator:SetAtlas(atlas, indicator.useAtlasSize)
    end
end

local function OnReadyCheckFadeFinished(animationGroup, requested)
    if requested then return end

    local indicator = animationGroup:GetParent()
    if not indicator then return end

    indicator.status = nil
    indicator:Hide()
end

function UUF:RefreshReadyCheckIndicator(unitFrame, event)
    local indicator = unitFrame and unitFrame.ReadyCheckIndicator
    if not indicator then return end

    local unit = unitFrame.unit or unitFrame.__UUFReadyCheckUnit
    local status = unit and UnitExists(unit) and GetReadyCheckStatus(unit) or nil

    if status then
        if indicator.Animation and indicator.Animation:IsPlaying() then
            indicator.Animation:Stop()
        end

        indicator:SetAlpha(1)
        SetReadyCheckStatusTexture(indicator, status)
        indicator.status = status
        indicator:Show()
    elseif event ~= "READY_CHECK_FINISHED" then
        if indicator.Animation and indicator.Animation:IsPlaying() then
            indicator.Animation:Stop()
        end

        indicator.status = nil
        indicator:Hide()
    end

    if event == "READY_CHECK_FINISHED" and indicator.status then
        if indicator.status == "waiting" then
            SetReadyCheckStatusTexture(indicator, "notready")
        end

        if indicator.FadeAnimation then
            indicator.FadeAnimation:SetDuration(indicator.fadeTime or 1.5)
            indicator.FadeAnimation:SetStartDelay(indicator.finishedTime or 10)
        end

        if indicator.Animation then
            indicator:SetAlpha(1)
            indicator.Animation:Stop()
            indicator.Animation:Play()
        end
    end
end

local ReadyCheckEventFrame = CreateFrame("Frame")
ReadyCheckEventFrame:RegisterEvent("READY_CHECK")
ReadyCheckEventFrame:RegisterEvent("READY_CHECK_CONFIRM")
ReadyCheckEventFrame:RegisterEvent("READY_CHECK_FINISHED")
ReadyCheckEventFrame:SetScript("OnEvent", function(_, event)
    for unitFrame in pairs(UUF.ReadyCheckIndicatorFrames) do
        UUF:RefreshReadyCheckIndicator(unitFrame, event)
    end
end)

function UUF:CreateUnitReadyCheckIndicator(unitFrame, unit)
    local ReadyCheckDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.ReadyCheck
    if not ReadyCheckDB then return end
    if unitFrame.__UUFReadyCheckIndicator then return unitFrame.__UUFReadyCheckIndicator end

    local ReadyCheckIndicator = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit) .. "_ReadyCheckIndicator", "OVERLAY")
    ReadyCheckIndicator:SetSize(ReadyCheckDB.Size, ReadyCheckDB.Size)
    ReadyCheckIndicator:SetPoint(ReadyCheckDB.Layout[1], unitFrame.HighLevelContainer, ReadyCheckDB.Layout[2], ReadyCheckDB.Layout[3], ReadyCheckDB.Layout[4])
    ReadyCheckIndicator.useAtlasSize = ReadyCheckDB.UseAtlasSize
    ReadyCheckIndicator.finishedTime = ReadyCheckDB.FinishedTime
    ReadyCheckIndicator.fadeTime = ReadyCheckDB.FadeTime
    ReadyCheckIndicator:Hide()

    local AnimationGroup = ReadyCheckIndicator:CreateAnimationGroup()
    AnimationGroup:HookScript("OnFinished", OnReadyCheckFadeFinished)
    ReadyCheckIndicator.Animation = AnimationGroup

    local FadeAnimation = AnimationGroup:CreateAnimation("Alpha")
    FadeAnimation:SetFromAlpha(1)
    FadeAnimation:SetToAlpha(0)
    FadeAnimation:SetDuration(ReadyCheckIndicator.fadeTime or 1.5)
    FadeAnimation:SetStartDelay(ReadyCheckIndicator.finishedTime or 10)
    ReadyCheckIndicator.FadeAnimation = FadeAnimation

    unitFrame.__UUFReadyCheckIndicator = ReadyCheckIndicator
    unitFrame.__UUFReadyCheckUnit = unit

    if ReadyCheckDB.Enabled then
        unitFrame.ReadyCheckIndicator = ReadyCheckIndicator
        UUF.ReadyCheckIndicatorFrames[unitFrame] = true
        UUF:RefreshReadyCheckIndicator(unitFrame)
    else
        ReadyCheckIndicator:Hide()
    end

    return ReadyCheckIndicator
end

function UUF:UpdateUnitReadyCheckIndicator(unitFrame, unit)
    local ReadyCheckDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.ReadyCheck
    if not ReadyCheckDB then return end

    unitFrame.__UUFReadyCheckUnit = unit

    if ReadyCheckDB.Enabled then
        unitFrame.ReadyCheckIndicator = unitFrame.ReadyCheckIndicator or unitFrame.__UUFReadyCheckIndicator or UUF:CreateUnitReadyCheckIndicator(unitFrame, unit)
        UUF.ReadyCheckIndicatorFrames[unitFrame] = true

        if unitFrame.ReadyCheckIndicator then
            unitFrame.ReadyCheckIndicator:ClearAllPoints()
            unitFrame.ReadyCheckIndicator:SetSize(ReadyCheckDB.Size, ReadyCheckDB.Size)
            unitFrame.ReadyCheckIndicator:SetPoint(ReadyCheckDB.Layout[1], unitFrame.HighLevelContainer, ReadyCheckDB.Layout[2], ReadyCheckDB.Layout[3], ReadyCheckDB.Layout[4])
            unitFrame.ReadyCheckIndicator.useAtlasSize = ReadyCheckDB.UseAtlasSize
            unitFrame.ReadyCheckIndicator.finishedTime = ReadyCheckDB.FinishedTime
            unitFrame.ReadyCheckIndicator.fadeTime = ReadyCheckDB.FadeTime
            UUF:RefreshReadyCheckIndicator(unitFrame)
        end
    else
        UUF.ReadyCheckIndicatorFrames[unitFrame] = nil

        if not unitFrame.ReadyCheckIndicator then return end
        if unitFrame.ReadyCheckIndicator.Animation and unitFrame.ReadyCheckIndicator.Animation:IsPlaying() then
            unitFrame.ReadyCheckIndicator.Animation:Stop()
        end
        unitFrame.ReadyCheckIndicator.status = nil
        unitFrame.ReadyCheckIndicator:Hide()
        unitFrame.ReadyCheckIndicator = nil
    end
end
