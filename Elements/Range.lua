local _, UUF = ...
local isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local LRC = LibStub("LibRangeCheck-3.0")
UUF.RangeEvtFrames = {}

local RangeEventFrame = CreateFrame("Frame")
RangeEventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
RangeEventFrame:RegisterEvent("UNIT_TARGET")
RangeEventFrame:RegisterEvent("UNIT_AURA")
RangeEventFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
RangeEventFrame:SetScript("OnEvent", function()
    for _, frameData in ipairs(UUF.RangeEvtFrames) do
        local frame, unit = frameData.frame, frameData.unit
        UUF:UpdateRangeAlpha(frame, unit)
    end
end)

function GetGroupUnit(unit)
    if strfind(unit, "party") or strfind(unit, "raid") or unit == "player" then
        return unit
    end
    if UnitInParty(unit) or UnitInRaid(unit) then
        local isInRaid = IsInRaid()
        for i = 1, GetNumGroupMembers() do
            local groupUnit = (isInRaid and "raid" or "party")..i
            if UnitIsUnit(unit, groupUnit) then
                return groupUnit
            end
        end
        if not isInRaid and UnitIsUnit(unit, "player") then
            return "player"
        end
    end
end

local function IsUnitInRange(unit)
    local minRange, maxRange = LRC:GetRange(unit, true, true)
    return (not minRange) or maxRange
end

local function FriendlyIsInRange(realUnit)
    local unit = GetGroupUnit(realUnit) or realUnit
    if UnitIsPlayer(unit) and (isRetail and UnitPhaseReason(unit) or not isRetail) then
        return false
    end
    local inRange, checkedRange = UnitInRange(unit)
    if checkedRange and not inRange then
        return false
    end
    return IsUnitInRange(unit)
end

function UUF:RegisterRangeFrame(frameName, unit)
    if not unit or not frameName then return end
    local unitFrame = type(frameName) == "table" and frameName or _G[frameName]
    local UnitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)]
    table.insert(UUF.RangeEvtFrames, { frame = unitFrame, unit = unit })
    if UnitDB and UnitDB.Range and UnitDB.Range.Enabled then
        unitFrame.Range = UnitDB.Range
    else
        unitFrame.Range = nil
    end
    UUF:UpdateRangeAlpha(unitFrame, unit)
end

function UUF:IsRangeFrameRegistered(unit)
    for _, frameData in ipairs(UUF.RangeEvtFrames) do
        if frameData.unit == unit then
            return true
        end
    end
    return false
end

function UUF:UpdateRangeAlpha(unitFrame, unit)
    if not unitFrame:IsVisible() then return end
    if not unit or not UnitExists(unit) then return end
    if unit == "player" then unitFrame:SetAlpha(1.0) return end
    local UnitDB = unitFrame.Range
    if not UnitDB then unitFrame:SetAlpha(1.0) return end
    local inAlpha = UnitDB.InRange or 1.0
    local outAlpha = UnitDB.OutOfRange or 0.5
    local unitFrameAlpha
    if UnitCanAttack('player', unit) or UnitIsUnit(unit, 'pet') then
        unitFrameAlpha = (IsUnitInRange(unit) and inAlpha) or outAlpha
    else
        unitFrameAlpha = (UnitIsConnected(unit) and FriendlyIsInRange(unit) and inAlpha) or outAlpha
    end
    unitFrame:SetAlpha(unitFrameAlpha)
end