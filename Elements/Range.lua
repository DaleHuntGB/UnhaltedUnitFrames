local _, UUF = ...
local isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE

UUF.RangeEvtFrames = {}

local rangeTicker = false

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

local function UnitSpellRange(unit, spells)
	local isNotInRange = false
	for spellID in pairs(spells) do
		local inRange = C_Spell.IsSpellInRange(spellID, unit)
		if UUF:IsSecretValue(inRange) then
			return inRange
		elseif inRange then
			return true
		elseif inRange ~= nil then
			isNotInRange = true
		end
	end
	if isNotInRange then return false end
end

local function UnitInSpellsRange(unit, category)
	local spells = activeSpells[category]
	local inRange = not next(spells) and 1 or UnitSpellRange(unit, spells)
	if UUF:IsSecretValue(inRange) then return inRange end

	if (not inRange or inRange == 1) and not InCombatLockdown() then
		return CheckInteractDistance(unit, 4)
	end
	return (inRange == nil and 1) or inRange
end

local function FriendlyIsInRange(unit, frame)
	if UnitIsPlayer(unit) then
		if isRetail then
			if UnitPhaseReason(unit) then return false end
		end
	end

	local inRange, wasChecked = UnitInRange(unit)
	if UUF:IsSecretValue(wasChecked) then
		if UnitInParty(unit) or UnitInRaid(unit) then
			frame.RangeIsInRange = inRange
			frame.RangeWasChecked = wasChecked
			return
		end
	elseif wasChecked and not inRange then
		return false
	end

	return UnitInSpellsRange(unit, "friendly")
end

local function UpdateRangeFrames()
	for unit, unitFrames in pairs(UUF.RangeEvtFrames) do
		for frame in pairs(unitFrames) do
			if frame:IsVisible() then UUF:UpdateRangeAlpha(frame, unit) end
		end
	end
end

local function UpdateRangeTicker()
	local shouldRun = UUF.db.profile.General.Range.Enabled and next(UUF.RangeEvtFrames)
	if shouldRun and not rangeTicker then
		rangeTicker = C_Timer.NewTicker(0.2, UpdateRangeFrames)
	elseif not shouldRun and rangeTicker then
		rangeTicker:Cancel()
		rangeTicker = false
	end
end

function UUF:RegisterRangeFrame(frameName, unit)
	if not frameName or not unit then return end
	local frame = type(frameName) == "table" and frameName or _G[frameName]
	if not frame then return end

	local previousUnit = frame.UUFRangeUnit
	if previousUnit and previousUnit ~= unit then
		local previousFrames = UUF.RangeEvtFrames[previousUnit]
		if previousFrames then
			previousFrames[frame] = nil
			if not next(previousFrames) then UUF.RangeEvtFrames[previousUnit] = nil end
		end
	end

	local unitFrames = UUF.RangeEvtFrames[unit]
	if not unitFrames then
		unitFrames = {}
		UUF.RangeEvtFrames[unit] = unitFrames
	end
	unitFrames[frame] = true
	frame.UUFRangeUnit = unit

	UpdateRangeTicker()
	UUF:UpdateRangeAlpha(frame, unit)
end

function UUF:UnregisterRangeFrame(frame)
	if not frame or not frame.UUFRangeUnit then return end
	local unit = frame.UUFRangeUnit
	local unitFrames = UUF.RangeEvtFrames[unit]
	if unitFrames then
		unitFrames[frame] = nil
		if not next(unitFrames) then UUF.RangeEvtFrames[unit] = nil end
	end
	frame.UUFRangeUnit = nil
	UpdateRangeTicker()
end

function UUF:IsRangeFrameRegistered(unit) return UUF.RangeEvtFrames[unit] ~= nil end

function UUF:UpdateAllRangeFrames()
	for unit, unitFrames in pairs(UUF.RangeEvtFrames) do
		for frame in pairs(unitFrames) do
			UUF:UpdateRangeAlpha(frame, unit)
		end
	end
	UpdateRangeTicker()
end

function UUF:UpdateRangeAlpha(frame, unit)
	local RangeDB = UUF.db.profile.General.Range
	if not RangeDB or not RangeDB.Enabled then frame:SetAlpha(1) return end
	frame.RangeIsInRange = nil
	frame.RangeWasChecked = nil
	if not unit or not UnitExists(unit) or unit == "player" then frame:SetAlpha(1) return end

	local inAlpha = RangeDB.InRange or 1
	local outAlpha = RangeDB.OutOfRange or 0.5
	local inRange = false

	if UnitIsDeadOrGhost(unit) then
		inRange = UnitInSpellsRange(unit, "resurrect")
	elseif UnitCanAttack("player", unit) then
		inRange = UnitInSpellsRange(unit, "enemy")
	else
		local isPet = UnitIsUnit(unit, "pet")
		if not UUF:IsSecretValue(isPet) and isPet then
			inRange = UnitInSpellsRange(unit, "pet")
		elseif UnitIsConnected(unit) then
			inRange = FriendlyIsInRange(unit, frame)
		else
			inRange = false
		end
	end

	if UUF:IsSecretValue(frame.RangeIsInRange) then
		frame:SetAlphaFromBoolean(frame.RangeIsInRange, inAlpha, outAlpha)
		return
	elseif UUF:IsSecretValue(inRange) then
		frame:SetAlphaFromBoolean(inRange, inAlpha, outAlpha)
		return
	end
	frame:SetAlpha(inRange and inAlpha or outAlpha)
end

local RangeEventFrame = CreateFrame("Frame")
RangeEventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
RangeEventFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
RangeEventFrame:RegisterEvent("UNIT_TARGET")
RangeEventFrame:RegisterEvent("UNIT_IN_RANGE_UPDATE")
RangeEventFrame:RegisterEvent("UNIT_CONNECTION")
RangeEventFrame:RegisterEvent("UNIT_PHASE")
local function UpdateRangeUnit(rangeUnit)
	local unitFrames = UUF.RangeEvtFrames[rangeUnit]
	if not unitFrames then return end
	for frame in pairs(unitFrames) do UUF:UpdateRangeAlpha(frame, rangeUnit) end
end

RangeEventFrame:SetScript("OnEvent", function(_, event, unit)
	if event == "PLAYER_TARGET_CHANGED" then
		UpdateRangeUnit("target")
		UpdateRangeUnit("targettarget")
		return
	elseif event == "PLAYER_FOCUS_CHANGED" then
		UpdateRangeUnit("focus")
		UpdateRangeUnit("focustarget")
		return
	elseif event == "UNIT_TARGET" then
		UpdateRangeUnit(unit .. "target")
		return
	end
	UpdateRangeUnit(unit)
end)
