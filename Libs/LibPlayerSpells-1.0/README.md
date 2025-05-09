LibPlayerSpells-1.0
===================

[![Build Status](https://travis-ci.org/AdiAddons/LibPlayerSpells-1.0.svg?branch=master)](https://travis-ci.org/AdiAddons/LibPlayerSpells-1.0) [![Gitter chat](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/AdiButtons/LibPlayerSpells-1.0)

LibPlayerSpells-1.0 is a library providing data about the spells of the twelve character classes in World of Warcraft. It also includes additional spells derived from racial traits and other sources. The word "spells" is used here in the general sense; it includes active skills as well as passive spells that are found in the players' spellbook. Buffs and debuffs that are applied by the player from other sources are also covered.

This library is born from the need to centralize similar data used in several addons to reduce the maintenance cost and to have a better consistency across those addons.

##### It provides answers to questions like:

* Does this spell have a cooldown?
* Does this spell apply one or several buff(s) or debuff(s)?
* Is this spell a survival cooldown, or used for DPS?
* Does this spell regenerate mana or some other resource?
* What are the survival buffs of all the classes?
* Which spell interrupt abilities are available?

Each class has his own data file that can be updated separately from the main code.

## Supported classes & specs

Not all classes and specializations are 100% supported yet. However, most interrupts, dispels, and survival cooldowns are complete.

If LibPlayerSpells is missing something specific from your class please file a detailed bug on Github or contribute to the project yourself if you are feeling brave! In the second case, be sure to read the [contribution guidelines](https://github.com/AdiAddons/LibPlayerSpells-1.0/wiki/Contribution-Guidelines).

## Usage

Copy the library files in your addon and list the lib.xml file in the TOC file.

LibPlayerSpells-1.0 uses LibStub:
```
local LibPlayerSpells = LibStub('LibPlayerSpells-1.0')
```
### Querying information from a spell

You can then obtain information about a given spell with GetSpellInfo:
```
local flags, providers, modifiedSpells[, moreFlags] = LibPlayerSpells:GetSpellInfo(spellId)
```
Where:

* `spellId` is the numerical spell identifier.
* `flags` is a bitfield containing data about the spells (see below).
* `providers` is the identifier (or a table of) identifier(s) of the spell(s) to; said otherwise, if the provider is not found in the player's spellbook, the given spell is unavailable. For example, the provider spell can be a passive spell given by a talent.
* `modifiedSpells` is the (or a table of) identifier(s) of the spell(s) affected by the given spells.
* If the given spell is a special case (see below), `moreFlags` contains another bitfield.

### Querying the spell database

You can iterate the database, looking for certain spells, using IterateSpells:
```
for spellId, flags, providers, modifiedSpells, moreFlags in LibPlayerSpells:IterateSpells(oneOfFlags, requiredFlags, rejectedFlags) do
  -- Do something with the loot
end
```
`flags`, `providers`, `modifiedSpells`, `moreFlags` have the same meaning as the values returned by GetSpellinfo. `spellId` is obviously the numerical identifier of the current spell.

The three method arguments are used to build a filter. They are bitmask specifications. They can be passed as an numerical bitmask computed using `bit.bor` and library constants, or a string containing the flags separated by white spaces or commas. For example, `bit.bor(LibPlayerSpells.constants.HUNTER, LibPlayerSpells.constants.BURST)` is the same bitmask as `"HUNTER BURST"`.

IterateSpells lists all spells that:

* has **at least** one of the flags listed by `oneOfFlags`
* and has **all** flags listed by `requiredFlags`,
* and has **none** of the flags in `rejectedFlags`.

If a bitmask is empty or not provided, the corresponding condition is ignored. With no arguments, all spells are listed.

Example:
```
-- Iterate through spells that have a cooldown, are/apply an aura and are either survival or mana-regenerating skills.
for spellId, flags, providers, modifiedSpells, moreFlags in LibPlayerSpells:IterateSpells("SURVIVAL REGEN_MANA", "AURA COOLDOWN") do
  -- Do something with it !
end
```
### Flags

Most spell information is stored in a bitfield to compact storage and easily test or filter spells. The bit value constants are available in the LibPlayerSpells.constants table.

The presence of a specific flag can be tested this way:
```
if bit.band(flags, LibPlayerSpells.constants.AURA) ~= 0 then
  -- This spell is an aura, do something meaningful with it.
end
```

However, the library provides a way to easily build flag tests.

#### Special spell types

These flags indicate special spells, that (will) have additional data.

* `CROWD_CTRL`: this is a crowd-control spell; additional data is a bitfield indicating the diminishing returns category (disorient, taunt, etc.).
* `DISPEL`: this spell can dispel either allies' debuffs or enemies' buffs; no additional data yet.

##### Crowd control flags

These flags are used in the additional data for crowd control spells and indicate the diminishing returns category a spell belongs to. While `INTERRUPT` and `KNOCKBACK` are technically DR categories themselves, they do not always have an associated aura and are not traceable through the UNIT_AURA event. Thus they are just ordinary flags in the spell bitmask.

* `DISORIENT`
* `INCAPACITATE`
* `ROOT`
* `STUN`
* `TAUNT`

#### Spell sources

These flags indicate the source of the spell. The constants are self-explanatory: `DEATHKNIGHT`, `DRUID`, `HUNTER`, `MAGE`, `MONK`, `PALADIN`, `PRIEST`, `ROGUE`, `SHAMAN`, `WARLOCK`, `WARRIOR`, `RACIAL`.

#### Targeting

These flags hints about the targeting mechanism of the spell. They are exclusive most of the time.

* `HELPFUL`: The spell can be cast on any ally, including the player and his pet.
* `HARMFUL`: The spell can be cast on any enemy.
* `PERSONAL`: The spell automatically targets the player.
* `PET`: The spell automatically targets the player's pet.

#### Miscellaneous

* `AURA`: The spell applies (or is) a buff on allies, or a debuff on enemies.
* `UNIQUE_AURA`: A given character can have only one instance of this (de)buff at a time, even if several players cast the same spell on it, e.g. Hunter's Mark.
* `COOLDOWN`: This spell has a meaningful cooldown.
* `SURVIVAL`: This spell is considered a survival skill.
* `BURST`: This spell is considered a burst skill (either damaging or healing).
* `POWER_REGEN`: This spell allows the target to recharge some kind of alternative resource e.g. Energizing Brew
* `IMPORTANT`: An important spell the player should react to.
* `INVERT_AURA`: The aura logic of this spell is inverted. It applies a debuff on allies or a buff on enemies (this case has yet to be found), e.g. the Weakened Soul applied by Power Word: Shield.

## Acknowledgements

Thanks to [ckaotik](https://github.com/ckaotik), [Rainrider](https://github.com/Rainrider), [mjmurray88](https://github.com/mjmurray88), [arcadepro](https://github.com/arcadepro) for their testing and contributions to the class spells.

## License

LibPlayerSpells-1.0 is licensed using GPL v3. This means that any addon using it must have a compatible license (see [there](https://www.gnu.org/licenses/quick-guide-gplv3.html)).
