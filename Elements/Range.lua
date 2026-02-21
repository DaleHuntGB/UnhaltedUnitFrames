local _, UUF = ...
local isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local IsSecretValue = issecretvalue or function() return false end

UUF.RangeEvtFrames = {}

--[[
    Range spell data derived from LibRangeCheck-3.0
    https://www.curseforge.com/wow/addons/librangecheck-3-0

    Copyright (c) 2023 The WoWUIDev Community
    Licensed under the MIT License

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
]]

-- The idea to cache/store spells per class comes from ElvUI: https://github.com/tukui-org/ElvUI/blob/main/ElvUI/Game/Shared/Modules/UnitFrames/Elements/Range.lua#L1
-- However, implementation is slightly different, as ElvUI allows for custom spell configuration, where I do not. I rely on the data below.

local RangeSpells = {
    ENEMY = {
        DEATHKNIGHT = {
            49576, -- Death Grip (30 yards)
            47541, -- Death Coil (Unholy) (40 yards)
        },
        DEMONHUNTER = {
            185123, -- Throw Glaive (Havoc) (30 yards)
            183752, -- Consume Magic (20 yards)
            204021, -- Fiery Brand (Vengeance) (30 yards)
        },
        DRUID = {
            8921,  -- Moonfire (40 yards)
            5176,  -- Wrath (40 yards)
            339,   -- Entangling Roots (35 yards)
            6795,  -- Growl (30 yards)
            33786, -- Cyclone (20 yards)
            22568, -- Ferocious Bite (Melee)
        },
        EVOKER = {
            362969, -- Azure Strike (25 yards)
        },
        HUNTER = {
            75,     -- Auto Shot (40 yards)
            466930, -- Black Arrow (40 yards)
        },
        MAGE = {
            116,   -- Frostbolt (40 yards)
            133,   -- Fireball (40 yards)
            44425, -- Arcane Barrage (40 yards)
            44614, -- Flurry (40 yards)
            118,   -- Polymorph (30 yards)
            5019,  -- Shoot (30 yards)
        },
        MONK = {
            117952, -- Crackling Jade Lightning (40 yards)
            115546, -- Provoke (30 yards)
            115078, -- Paralysis (20 yards)
            100780, -- Tiger Palm (Melee)
        },
        PALADIN = {
            20473, -- Holy Shock (40 yards)
            20271, -- Judgement (30 yards)
            62124, -- Hand of Reckoning (30 yards)
            183218, -- Hand of Hindrance (30 yards)
            853,   -- Hammer of Justice (10 yards)
            35395, -- Crusader Strike (Melee)
        },
        PRIEST = {
            585,  -- Smite (40 yards)
            8092, -- Mind Blast (40 yards)
            589,  -- Shadow Word: Pain (40 yards)
            5019, -- Shoot (30 yards)
        },
        ROGUE = {
            185565, -- Poisoned Knife (Assassination) (30 yards)
            36554,  -- Shadowstep (Assassination, Subtlety) (25 yards)
            185763, -- Pistol Shot (Outlaw) (20 yards)
            2094,   -- Blind (15 yards)
            921,    -- Pick Pocket (10 yards)
        },
        SHAMAN = {
            188196, -- Lightning Bolt (40 yards)
            8042,   -- Earth Shock (40 yards)
            117014, -- Elemental Blast (40 yards)
            370,    -- Purge (30 yards)
            73899,  -- Primal Strike (Melee)
        },
        WARLOCK = {
            686,    -- Shadow Bolt (40 yards)
            232670, -- Shadow Bolt (40 yards)
            234153, -- Drain Life (40 yards)
            198590, -- Drain Soul (40 yards)
            5782,   -- Fear (30 yards)
            5019,   -- Shoot (30 yards)
        },
        WARRIOR = {
            355,  -- Taunt (30 yards)
            100,  -- Charge (8-25 yards)
            5246, -- Intimidating Shout (8 yards)
        },
    },
    FRIENDLY = {
        DEATHKNIGHT = {
            47541, -- Death Coil (40 yards)
        },
        DEMONHUNTER = {},
        DRUID = {
            8936,  -- Regrowth (40 yards)
            774,   -- Rejuvenation (Restoration) (40 yards)
            88423, -- Nature's Cure (Restoration) (40 yards)
            2782,  -- Remove Corruption (Restoration) (40 yards)
        },
        EVOKER = {
            361469, -- Living Flame (25 yards)
            355913, -- Emerald Blossom (25 yards)
            360823, -- Naturalize (Preservation) (30 yards)
        },
        HUNTER = {},
        MAGE = {
            1459, -- Arcane Intellect (40 yards)
            475,  -- Remove Curse (40 yards)
        },
        MONK = {
            116670, -- Vivify (40 yards)
            115450, -- Detox (40 yards)
        },
        PALADIN = {
            19750,  -- Flash of Light (40 yards)
            85673,  -- Word of Glory (40 yards)
            4987,   -- Cleanse (Holy) (40 yards)
            213644, -- Cleanse Toxins (Protection, Retribution) (40 yards)
        },
        PRIEST = {
            2061,  -- Flash Heal (40 yards)
            17,    -- Power Word: Shield (40 yards)
            21562, -- Power Word: Fortitude (40 yards)
            527,   -- Purify / Dispel Magic (40 yards)
        },
        ROGUE = {
            57934, -- Tricks of the Trade (40 yards)
            36554, -- Shadowstep (25 yards)
            921,   -- Pick Pocket (10 yards)
        },
        SHAMAN = {
            8004,   -- Healing Surge (Resto, Elemental) (40 yards)
            188070, -- Healing Surge (Enhancement) (40 yards)
            546,    -- Water Walking (30 yards)
        },
        WARRIOR = {
            3411, -- Intervene (30 yards)
        },
        WARLOCK = {
            20707, -- Soulstone (40 yards)
            5697,  -- Unending Breath (30 yards)
        },
    },
    RESURRECT = {
        DEATHKNIGHT = {
            61999, -- Raise Ally (40 yards)
        },
        DEMONHUNTER = {},
        DRUID = {
            50769, -- Revive (40 yards)
            20484, -- Rebirth (40 yards)
        },
        EVOKER = {
            361227, -- Return (40 yards)
        },
        HUNTER = {},
        MAGE = {},
        MONK = {
            115178, -- Resuscitate (40 yards)
        },
        PALADIN = {
            7328,   -- Redemption (40 yards)
            391054, -- Intercession (40 yards)
        },
        PRIEST = {
            2006,   -- Resurrection (40 yards)
            212036, -- Mass Resurrection (40 yards)
        },
        ROGUE = {},
        SHAMAN = {
            2008, -- Ancestral Spirit (40 yards)
        },
        WARRIOR = {},
        WARLOCK = {
            20707, -- Soulstone (40 yards)
        },
    },
    PET = {
        DEATHKNIGHT = {
            47541, -- Death Coil (40 yards)
        },
        DEMONHUNTER = {},
        DRUID = {},
        EVOKER = {},
        HUNTER = {
            136, -- Mend Pet (45 yards)
        },
        MAGE = {},
        MONK = {},
        PALADIN = {},
        PRIEST = {},
        ROGUE = {},
        SHAMAN = {},
        WARRIOR = {},
        WARLOCK = {
            755, -- Health Funnel (45 yards)
        },
    },
}

local IsSpellInSpellBook = C_SpellBook.IsSpellInSpellBook
local playerClass = select(2, UnitClass("player"))
local activeSpells = {
    enemy = {},
    friendly = {},
    resurrect = {},
    pet = {},
}

local function NotSecretValue(value)
    return IsSecretValue(value) == false
end

local function SafeBool(value)
    if IsSecretValue(value) then
        return nil
    end
    return value
end

local function UpdateActiveSpells()

    local function BuildList(category, spellList)
        wipe(activeSpells[category])
        for _, spellID in ipairs(spellList or {}) do
            if IsSpellInSpellBook(spellID, nil, true) then
                activeSpells[category][spellID] = true
            end
        end
    end

    BuildList("enemy", RangeSpells.ENEMY[playerClass])
    BuildList("friendly", RangeSpells.FRIENDLY[playerClass])
    BuildList("resurrect", RangeSpells.RESURRECT[playerClass])
    BuildList("pet", RangeSpells.PET[playerClass])
end

local spellUpdateFrame = CreateFrame("Frame")
spellUpdateFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
spellUpdateFrame:RegisterEvent("SPELLS_CHANGED")
spellUpdateFrame:SetScript("OnEvent", UpdateActiveSpells)

local RANGE_COALESCE_EVENT = "UUF_RANGE_FRAME_UPDATE"

local function ProcessRangeFrameUpdates()
    for i = #UUF.RangeEvtFrames, 1, -1 do
        local frameData = UUF.RangeEvtFrames[i]
        if not frameData or not frameData.frame then
            table.remove(UUF.RangeEvtFrames, i)
        else
            UUF:UpdateRangeAlpha(frameData.frame, frameData.unit)
        end
    end
end

if UUF.EventCoalescer then
    UUF.EventCoalescer:CoalesceEvent(RANGE_COALESCE_EVENT, 0.05, ProcessRangeFrameUpdates, 3)
end

local RangeEventFrame = CreateFrame("Frame")
RangeEventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
RangeEventFrame:RegisterEvent("UNIT_TARGET")
RangeEventFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
RangeEventFrame:SetScript("OnEvent", function()
    if UUF.EventCoalescer then
        UUF.EventCoalescer:QueueEvent(RANGE_COALESCE_EVENT)
    else
        ProcessRangeFrameUpdates()
    end
end)

-- local function GetGroupUnit(unit)
--     if unit == "player" or unit:match("^party") or unit:match("^raid") then return unit end

--     if UnitInParty(unit) or UnitInRaid(unit) then
--         local isRaid = IsInRaid()
--         for i = 1, GetNumGroupMembers() do
--             local groupUnit = (isRaid and "raid" or "party") .. i
--             if UnitIsUnit(unit, groupUnit) then
--                 return groupUnit
--             end
--         end
--     end
-- end

local function UnitSpellRange(unit, spells)
    local isNotInRange;
    for spellID in pairs(spells) do
        local inRange = C_Spell.IsSpellInRange(spellID, unit)
        if inRange then
            return true
        elseif inRange ~= nil then
            isNotInRange = true
        end
    end
    if isNotInRange then return false end
end

local function UnitInSpellsRange(unit, category)
    local spells = activeSpells[category]
    if not next(spells) then
        if not InCombatLockdown() then return CheckInteractDistance(unit, 4) end
        return nil
    end

    local inRange = UnitSpellRange(unit, spells)
    if issecretvalue(inRange) then
        inRange = nil
    end
    if (inRange == false or inRange == nil or inRange == 1) and not InCombatLockdown() then
        local interactDistance = CheckInteractDistance(unit, 4)
        if NotSecretValue(interactDistance) then
            return interactDistance
        end
        return nil
    else
        if NotSecretValue(inRange) then
            return (inRange == nil and 1) or inRange
        end
        return nil
    end
end

local function FriendlyIsInRange(realUnit)
    local unit = --[[GetGroupUnit(realUnit) or ]]realUnit

    if SafeBool(UnitIsPlayer(unit)) then
        if isRetail then
            local phaseReason = UnitPhaseReason(unit)
            if NotSecretValue(phaseReason) and phaseReason then return false end
        end
    end

    if isRetail then
        local inRange, checkedRange = UnitInRange(unit)
        if NotSecretValue(checkedRange) and checkedRange then
            local safeInRange = SafeBool(inRange)
            if safeInRange == false then
                return false
            end
        end
    end

    return UnitInSpellsRange(unit, "friendly")
end

function UUF:RegisterRangeFrame(frameName, unit)
    if not frameName or not unit then return end

    local frame = type(frameName) == "table" and frameName or _G[frameName]
    if not frame then return end

    -- Remove stale/missing frame entries and avoid duplicate registration.
    for i = #UUF.RangeEvtFrames, 1, -1 do
        local data = UUF.RangeEvtFrames[i]
        if not data or not data.frame or not data.frame.GetObjectType then
            table.remove(UUF.RangeEvtFrames, i)
        elseif data.frame == frame then
            data.unit = unit
            if UUF.db.profile.General.Range.Enabled then
                frame.Range = UUF.db.profile.General.Range
            else
                frame.Range = nil
            end
            UUF:UpdateRangeAlpha(frame, unit)
            return
        end
    end

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
    local unitExists = UnitExists(unit)
    if IsSecretValue(unitExists) then unitExists = true end
    if not frame:IsVisible() or not unit or unitExists == false then return end
    if unit == "player" then frame:SetAlpha(1) return end

    local inAlpha = RangeDB.InRange or 1
    local outAlpha = RangeDB.OutOfRange or 0.5
    local inRange;

    local isDead = SafeBool(UnitIsDeadOrGhost(unit))
    if isDead then
        inRange = UnitInSpellsRange(unit, "resurrect")
    elseif SafeBool(UnitCanAttack("player", unit)) then
        inRange = UnitInSpellsRange(unit, "enemy")
    else
        local isPet = UnitIsUnit(unit, "pet")
        -- What a mess WoW API is.
        if NotSecretValue(isPet) and isPet then
            inRange = UnitInSpellsRange(unit, "pet")
        elseif SafeBool(UnitIsConnected(unit)) then
            inRange = FriendlyIsInRange(unit)
        else
            inRange = false
        end
    end

    if inRange == nil then
        inRange = true
    end

    frame:SetAlphaFromBoolean(inRange, inAlpha, outAlpha)
end
