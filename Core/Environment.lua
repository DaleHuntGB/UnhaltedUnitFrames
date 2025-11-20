local _, UUF = ...
local FakeBossData = {}

local Classes = {
    [1] = "WARRIOR",
    [2] = "PALADIN",
    [3] = "HUNTER",
    [4] = "ROGUE",
    [5] = "PRIEST",
    [6] = "DEATHKNIGHT",
    [7] = "SHAMAN",
    [8] = "MAGE",
    [9] = "WARLOCK",
    [10]= "MONK",
    [11]= "DRUID",
    [12]= "DEMONHUNTER",
    [13]= "EVOKER",
}

local PowerTypes = {
    [1] = 0,
    [2] = 1,
    [3] = 2,
    [4] = 3,
    [5] = 6,
    [6] = 8,
    [7] = 11,
    [8] = 13,
    [9] = 17,
    [10] = 18
}

for i = 1, 10 do
    FakeBossData[i] = {
        name      = "Boss " .. i,
        class     = Classes[i],
        reaction  = i % 2 == 0 and 2 or 5,
        health    = 8000000 - (i * 600000),
        maxHealth = 8000000,
        percent  = (8000000 - (i * 600000)) / 8000000 * 100,
        power     = 100 - (i * 2),
        maxPower  = 100,
        powerType = PowerTypes[i],
    }
end

local UUF_UnitName             = UnitName
local UUF_UnitHealth           = UnitHealth
local UUF_UnitHealthMax        = UnitHealthMax
local UUF_UnitPower            = UnitPower
local UUF_UnitPowerMax         = UnitPowerMax
local UUF_UnitPowerType        = UnitPowerType
local UUF_UnitIsPlayer         = UnitIsPlayer
local UUF_UnitClass            = UnitClass
local UUF_UnitReaction         = UnitReaction
local UUF_UnitHealthPercent    = UnitHealthPercent

local FakeAPI_Active = false

local function EnableFakeUnitAPI()
    if FakeAPI_Active then return end
    FakeAPI_Active = true
    UnitName = function(unit)
        local unitID = unit:match("^boss(%d+)$")
        if unitID then return FakeBossData[tonumber(unitID)].name end
        return UUF_UnitName(unit)
    end
    UnitHealth = function(unit)
        local unitID = unit:match("^boss(%d+)$")
        if unitID then return FakeBossData[tonumber(unitID)].health end
        return UUF_UnitHealth(unit)
    end
    UnitHealthMax = function(unit)
        local unitID = unit:match("^boss(%d+)$")
        if unitID then return FakeBossData[tonumber(unitID)].maxHealth end
        return UUF_UnitHealthMax(unit)
    end
    UnitHealthPercent = function(unit)
        local unitID = unit:match("^boss(%d+)$")
        if unitID then return FakeBossData[tonumber(unitID)].percent end
        return UUF_UnitHealthPercent(unit)
    end
    UnitPower = function(unit)
        local unitID = unit:match("^boss(%d+)$")
        if unitID then return FakeBossData[tonumber(unitID)].power end
        return UUF_UnitPower(unit)
    end
    UnitPowerMax = function(unit)
        local unitID = unit:match("^boss(%d+)$")
        if unitID then return FakeBossData[tonumber(unitID)].maxPower end
        return UUF_UnitPowerMax(unit)
    end
    UnitPowerType = function(unit)
        local unitID = unit:match("^boss(%d+)$")
        if unitID then return FakeBossData[tonumber(unitID)].powerType end
        return UUF_UnitPowerType(unit)
    end
    UnitIsPlayer = function(unit)
        if FakeAPI_Active then
            if unit:match("^boss(%d+)$") then
                return true
            end
        end
        return UUF_UnitIsPlayer(unit)
    end
    UnitClass = function(unit)
    local unitID = unit:match("^boss(%d+)$")
    if unitID then
        unitID = tonumber(unitID)
        if unitID <= 5 then
            local class = FakeBossData[unitID].class
            return class, class
        end
        return nil, nil
    end
        return UUF_UnitClass(unit)
    end
    UnitReaction = function(unit, other)
        local unitID = unit:match("^boss(%d+)$")
        if unitID then return FakeBossData[tonumber(unitID)].reaction end
        return UUF_UnitReaction(unit, other)
    end
end

local function DisableFakeUnitAPI()
    if not FakeAPI_Active then return end
    FakeAPI_Active = false
    UnitName        = UUF_UnitName
    UnitHealth      = UUF_UnitHealth
    UnitHealthMax   = UUF_UnitHealthMax
    UnitPower       = UUF_UnitPower
    UnitPowerMax    = UUF_UnitPowerMax
    UnitPowerType   = UUF_UnitPowerType
    UnitIsPlayer    = UUF_UnitIsPlayer
    UnitClass       = UUF_UnitClass
    UnitReaction    = UUF_UnitReaction
    UnitHealthPercent = UUF_UnitHealthPercent
end

function UUF:TestBossFrames()
    local isTesting = UUF.BossTestMode
    if isTesting then
        EnableFakeUnitAPI()
        if not UUF.BossTestTicker then
            UUF.BossTestTicker = C_Timer.NewTicker(0.1, function()
                if not UUF.BossTestMode then return end

                for i = 1, UUF.MaxBossFrames do
                    UUF:UpdateUnitFrame("boss"..i)
                end
                UUF:LayoutBossFrames()
            end)
        end
    else
        if UUF.BossTestTicker then
            UUF.BossTestTicker:Cancel()
            UUF.BossTestTicker = nil
        end
        DisableFakeUnitAPI()
    end

    for i = 1, UUF.MaxBossFrames do
        local unitFrame = _G["UUF_Boss"..i]
        if isTesting then
            UnregisterUnitWatch(unitFrame)
            unitFrame.unit   = "boss"..i
            unitFrame.dbUnit = "boss"
            unitFrame:Show()
            UUF:UpdateUnitFrame("boss"..i)
        else
            unitFrame.unit   = "boss"..i
            unitFrame.dbUnit = "boss"
            unitFrame:Hide()
            RegisterUnitWatch(unitFrame)
        end
    end
    UUF:LayoutBossFrames()
end
