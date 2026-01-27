local _, UUF = ...
local isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE

UUF.RangeEvtFrames = {}

local IsSpellInRange = C_Spell.IsSpellInRange
local UnitPhaseReason = UnitPhaseReason
local CheckInteractDistance = CheckInteractDistance

local RangeEventFrame = CreateFrame("Frame")
RangeEventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
RangeEventFrame:RegisterEvent("UNIT_TARGET")
RangeEventFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
RangeEventFrame:SetScript("OnEvent", function()
    for _, frameData in ipairs(UUF.RangeEvtFrames) do
        UUF:UpdateRangeAlpha(frameData.frame, frameData.unit)
    end
end)

local function GetGroupUnit(unit)
    if unit == "player" or unit:match("^party") or unit:match("^raid") then
        return unit
    end

    if UnitInParty(unit) or UnitInRaid(unit) then
        local isRaid = IsInRaid()
        for i = 1, GetNumGroupMembers() do
            local groupUnit = (isRaid and "raid" or "party") .. i
            if UnitIsUnit(unit, groupUnit) then
                return groupUnit
            end
        end
    end
end

local function IsUnitInRange(unit)
    local spell = UUF.db.profile.General.Range.Spell
    if spell and IsSpellInRange(spell, unit) ~= nil then
        return IsSpellInRange(spell, unit)
    end
    return CheckInteractDistance(unit, 4)
end

local function FriendlyIsInRange(realUnit)
    local unit = GetGroupUnit(realUnit) or realUnit

    if UnitIsPlayer(unit) then
        if isRetail then
            if UnitPhaseReason(unit) then return false end
        end
    end

    return IsUnitInRange(unit)
end

function UUF:RegisterRangeFrame(frameName, unit)
    if not frameName or not unit then return end

    local frame = type(frameName) == "table" and frameName or _G[frameName]
    if not frame then return end

    table.insert(UUF.RangeEvtFrames, { frame = frame, unit = unit })

    if UUF.db.profile.General.Range.Enabled then
        frame.Range = UUF.db.profile.General.Range
    else
        frame.Range = nil
    end

    UUF:UpdateRangeAlpha(frame, unit)
end

function UUF:IsRangeFrameRegistered(unit)
    for _, data in ipairs(UUF.RangeEvtFrames) do
        if data.unit == unit then return true end
    end
end

function UUF:UpdateRangeAlpha(frame, unit)
    local RangeDB = UUF.db.profile.General.Range
    if not RangeDB or not RangeDB.Enabled then frame:SetAlpha(1) return end
    if not frame:IsVisible() or not unit or not UnitExists(unit) then return end
    if unit == "player" then frame:SetAlpha(1) return end

    local inAlpha = RangeDB.InRange or 1
    local outAlpha = RangeDB.OutOfRange or 0.5
    local inRange

    if UnitCanAttack("player", unit) or UnitIsUnit(unit, "pet") then
        inRange = IsUnitInRange(unit)
    else
        inRange = UnitIsConnected(unit) and FriendlyIsInRange(unit)
    end

    frame:SetAlpha(inRange and inAlpha or outAlpha)
end
