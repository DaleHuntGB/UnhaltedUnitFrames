local _, UUF = ...
UUF.TargetHighlightEvtFrames = {}

local function GetNormalizedUnit(unit)
    local normalizedUnit = unit:match("^boss%d+$") and "boss" or unit
    return normalizedUnit
end

local unitIsTargetEvtFrame = CreateFrame("Frame")
unitIsTargetEvtFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
unitIsTargetEvtFrame:RegisterEvent("UNIT_TARGET")
unitIsTargetEvtFrame:SetScript("OnEvent", function()
    if not UUF.db.profile.boss.Indicators.TargetIndicator.Enabled then return end
    for _, frameData in ipairs(UUF.TargetHighlightEvtFrames) do
        local frame, unit = frameData.frame, frameData.unit
        UUF:UpdateTargetHighlight(frame, unit)
    end
end)

function UUF:UpdateTargetHighlight(frame, unit)
    if frame and frame.TargetIndicator then
        if UnitIsUnit("target", unit) and UUF.db.profile.boss.Indicators.TargetIndicator.Enabled then
            frame.TargetIndicator:Show()
        else
            frame.TargetIndicator:Hide()
        end
    end
end

function UUF:RegisterTargetIndicatorFrame(frameName, unit)
    if not unit then return end
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local unitFrame = type(frameName) == "table" and frameName or _G[frameName]
    local IndicatorsDB = UUFDB[normalizedUnit].Indicators
    table.insert(UUF.TargetHighlightEvtFrames, { frame = unitFrame, unit = unit })
    if IndicatorsDB and IndicatorsDB.TargetIndicator and IndicatorsDB.TargetIndicator.Enabled then
        UUF:UpdateTargetHighlight(unitFrame, unit)
    else
        unitFrame.TargetIndicator:Hide()
    end
end