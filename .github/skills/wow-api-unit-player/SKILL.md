```skill
---
name: wow-api-unit-player
description: "Complete reference for WoW Retail Unit and Player APIs — UnitId tokens, GUIDs, health/power/stats, auras, roles, casting, threat, inspection, paper doll, death/resurrection, and player-specific functions. Use when querying unit identity, health, power, auras, stats, combat state, group membership, casting info, threat, or player character details."
---

# Unit & Player API (Retail — Patch 12.0.0)

Comprehensive reference for all Unit, Player, UnitAuras, UnitRole, PaperDollInfo, and PlayerInfo APIs. Covers unit identification (UnitId tokens, GUIDs), health, power, stats, auras, casting, threat, group membership, inspection, and player-specific character functions.

> **Source of truth:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#Unit
> **UnitId reference:** https://warcraft.wiki.gg/wiki/UnitId
> **GUID reference:** https://warcraft.wiki.gg/wiki/GUID
> **Current as of:** Patch 12.0.0 (Build 65655) — January 28, 2026
> **Scope:** Retail only. No deprecated or removed functions.

## Scope

This skill covers these API systems:
- **Unit** — Core unit query functions (`UnitName`, `UnitHealth`, `UnitClass`, etc.)
- **UnitAuras** — Aura/buff/debuff system (`C_UnitAuras`)
- **UnitRole** — Group role assignment and queries
- **PlayerInfo** — Player-specific info (`C_PlayerInfo`)
- **PaperDollInfo** — Equipment, stats, inspection (`C_PaperDollInfo`)
- **PlayerScript** — Global player functions (stats, combat ratings, PvP, death, movement)
- **DeathInfo / IncomingSummon** — Death, resurrection, summoning
- **CreatureInfo** — Creature data helpers

## When to Use This Skill

Use this skill when you need to:
- Query unit identity: name, class, race, level, faction, GUID
- Read or display health, power (mana/rage/energy), or stats
- Work with auras (buffs, debuffs, private auras)
- Check unit state: alive, dead, ghost, combat, AFK, stealthed, flying
- Determine group membership, roles, or raid position
- Inspect other players (item level, spec, PvP data)
- Get player character stats: crit, haste, mastery, armor, attack power
- Handle casting info (what a unit is casting/channeling)
- Query threat situation
- Work with UnitId tokens or GUIDs

## Reference Files

| Reference | Contents |
|-----------|----------|
| [UNIT-IDENTITY.md](references/UNIT-IDENTITY.md) | UnitId tokens, GUIDs, name/class/race/level/faction |
| [UNIT-HEALTH-POWER.md](references/UNIT-HEALTH-POWER.md) | Health, power, stats, armor, combat ratings |
| [UNIT-STATE.md](references/UNIT-STATE.md) | Combat, dead/ghost, casting, vehicle, movement, group state |
| [UNIT-AURAS.md](references/UNIT-AURAS.md) | C_UnitAuras — buffs, debuffs, private auras |
| [UNIT-THREAT-COMBAT.md](references/UNIT-THREAT-COMBAT.md) | Threat, targeting, selection, inspection |
| [PLAYER-FUNCTIONS.md](references/PLAYER-FUNCTIONS.md) | Player-specific: XP, money, PvP, death, resurrection, stats |

---

## UnitId Tokens — Quick Reference

A UnitId (unit token) identifies a unit by relationship to the player. Case insensitive.

### Base Tokens

| Token | Description |
|-------|-------------|
| `"player"` | The current player |
| `"target"` | The current player's target |
| `"focus"` | The player's focus target (set by `/focus`) |
| `"pet"` | The player's pet |
| `"vehicle"` | The player's vehicle |
| `"mouseover"` | Unit currently (or most recently) moused over |
| `"none"` | Valid token that always refers to no unit |
| `"npc"` | NPC the player is interacting with (merchant/quest/gossip frame open) |
| `"questnpc"` | Quest giver NPC being interacted with |

### Indexed Tokens

| Pattern | Range | Description |
|---------|-------|-------------|
| `"partyN"` | 1–4 | Nth party member (excluding player) |
| `"raidN"` | 1–40 | Nth raid member |
| `"partypetN"` | 1–4 | Pet of Nth party member |
| `"raidpetN"` | 1–40 | Pet of Nth raid member |
| `"bossN"` | 1–8 | Active boss in current encounter |
| `"arenaN"` | 1–5 | Opposing arena member |
| `"nameplateN"` | 1–40 | Nth nameplate (cannot be targeted) |

### Soft Targeting (Patch 10.0+)

| Token | Description |
|-------|-------------|
| `"softenemy"` | Current soft target that is hostile |
| `"softfriend"` | Current soft target that is friendly |
| `"softinteract"` | Current soft target that can be interacted with |
| `"anyenemy"` | Resolves to `"target"` or `"softenemy"` (target priority) |
| `"anyfriend"` | Resolves to `"target"` or `"softfriend"` (target priority) |
| `"anyinteract"` | Resolves to `"target"` or `"softinteract"` (target priority) |

### Target Chaining

Append `target` to any UnitId to refer to its target. Can be repeated:
- `"targettarget"` — your target's target
- `"raid7target"` — 7th raid member's target
- `"pettarget"` — your pet's target
- `"Cogwheel-target"` — named player's target (if in group)

> **Source:** https://warcraft.wiki.gg/wiki/UnitId

---

## GUID (Globally Unique Identifier) — Quick Reference

GUIDs uniquely identify everything the player can interact with. Returned by `UnitGUID(unit)`.

### GUID Formats

| Type | Format | Example |
|------|--------|---------|
| Player | `Player-[serverID]-[playerUID]` | `Player-970-0002FD64` |
| Creature | `Creature-0-[serverID]-[instanceID]-[zoneUID]-[npcID]-[spawnUID]` | `Creature-0-1465-0-2105-448-000043F59F` |
| Pet | `Pet-0-[serverID]-[instanceID]-[zoneUID]-[npcID]-[spawnUID]` | `Pet-0-4234-0-6610-165189-0202F859E9` |
| Vehicle | `Vehicle-0-[serverID]-[instanceID]-[zoneUID]-[npcID]-[spawnUID]` | Same format as Creature |
| GameObject | `GameObject-0-[serverID]-[instanceID]-[zoneUID]-[objectID]-[spawnUID]` | Same format as Creature |
| Item | `Item-[serverID]-0-[spawnUID]` | `Item-1598-0-4000000A369860E1` |
| Vignette | `Vignette-0-[serverID]-[instanceID]-[zoneUID]-[vignetteID]-[spawnUID]` | — |
| BattlePet | `BattlePet-0-[ID]` | `BattlePet-0-00000338F951` |
| Cast | `Cast-[type]-[serverID]-[instanceID]-[zoneUID]-[spellID]-[castUID]` | — |

### Extracting NPC ID from GUID

```lua
local npcID = select(6, strsplit("-", UnitGUID("target")))
print(tonumber(npcID)) -- e.g., 448 for Hogger
```

### Key Rules

- Players keep their GUID forever (unless faction change/transfer)
- Creatures get a new GUID each spawn cycle
- Pets get a new GUID each time summoned
- GUIDs are recycled after server/instance restart

> **Source:** https://warcraft.wiki.gg/wiki/GUID

---

## Core Unit Functions — Overview

### Identity

| Function | Returns | Description |
|----------|---------|-------------|
| `UnitName(unit)` | `unitName, unitServer` | Unit's name and realm |
| `UnitFullName(unit)` | `unitName, unitServer` | Full name with server |
| `UnitNameUnmodified(unit)` | `unitName, unitServer` | Name without modifications |
| `UnitNameFromGUID(guid)` | `unitName, unitServer` | Name from GUID |
| `UnitGUID(unit)` | `guid` | GUID string |
| `UnitTokenFromGUID(guid)` | `unitToken` | UnitId from GUID |
| `UnitClass(unit)` | `className, classFilename, classID` | Class info |
| `UnitClassBase(unit)` | `classFilename, classID` | Non-localized class |
| `UnitClassFromGUID(guid)` | `className, classFilename, classID` | Class from GUID |
| `UnitRace(unit)` | `localizedRace, englishRace, raceID` | Race info |
| `UnitSex(unit)` | `sex` | Gender (1=unknown, 2=male, 3=female) |
| `UnitLevel(unit)` | `level` | Unit level |
| `UnitEffectiveLevel(unit)` | `level` | Scaled level |
| `UnitFactionGroup(unit [, checkDisplayRace])` | `factionTag, localized` | Horde/Alliance |
| `UnitClassification(unit)` | `class` | "normal", "elite", "worldboss", etc. |
| `UnitCreatureType(unit)` | `name, id` | Beast, Humanoid, Undead, etc. |
| `UnitCreatureFamily(unit)` | `name, id` | Creature family (e.g., Crab) |
| `UnitCreatureID(unit)` | `creatureID` | NPC ID |
| `UnitPVPName(unit)` | `name` | Name with title |
| `GetPlayerInfoByGUID(guid)` | `class, engClass, race, engRace, sex, name, realm` | Info from GUID |

### Health

| Function | Returns | Notes |
|----------|---------|-------|
| `UnitHealth(unit [, usePredicted])` | `health` | **Returns secret value in 12.0** — pass directly to widgets |
| `UnitHealthMax(unit)` | `maxHealth` | **Returns secret value in 12.0** |
| `UnitHealthMissing(unit [, usePredicted])` | `missing` | Health deficit |
| `UnitHealthPercent(unit [, usePredicted [, curve]])` | `percent` | Health percentage |
| `UnitPercentHealthFromGUID(guid)` | `percent` | Health % from GUID |
| `UnitGetIncomingHeals(unit [, healer])` | `amount` | Predicted heals |
| `UnitGetTotalAbsorbs(unit)` | `amount` | Damage absorb shield |
| `UnitGetTotalHealAbsorbs(unit)` | `amount` | Healing absorb shield |
| `GetUnitHealthModifier(unit)` | `modifier` | Health modifier |
| `GetUnitMaxHealthModifier(unit)` | `modifier` | Max health modifier |

### Power (Mana/Rage/Energy/etc.)

| Function | Returns | Notes |
|----------|---------|-------|
| `UnitPower(unit [, powerType [, unmodified]])` | `power` | Current power |
| `UnitPowerMax(unit [, powerType [, unmodified]])` | `maxPower` | Maximum power |
| `UnitPowerMissing(unit [, powerType [, unmodified]])` | `missing` | Power deficit |
| `UnitPowerPercent(unit [, powerType [, ...]])` | `percent` | Power percentage |
| `UnitPartialPower(unit [, powerType [, unmodified]])` | `partialPower` | Fractional power |
| `UnitPowerType(unit [, index])` | `powerType, token, r, g, b` | e.g., 0=Mana, 1=Rage |
| `UnitPowerDisplayMod(powerType)` | `mod` | Display modifier |
| `GetUnitPowerModifier(unit)` | `modifier` | Power modifier |

### Power Types (Enum.PowerType)

| Value | Token | Description |
|-------|-------|-------------|
| 0 | Mana | Mana |
| 1 | Rage | Rage |
| 2 | Focus | Focus (Hunter pets) |
| 3 | Energy | Energy (Rogues, Monks, etc.) |
| 4 | ComboPoints | Combo Points |
| 5 | Runes | Death Knight Runes |
| 6 | RunicPower | Runic Power |
| 7 | SoulShards | Warlock Soul Shards |
| 8 | LunarPower | Balance Druid |
| 9 | HolyPower | Paladin Holy Power |
| 11 | Maelstrom | Shaman Maelstrom |
| 12 | Chi | Monk Chi |
| 13 | Insanity | Shadow Priest |
| 16 | ArcaneCharges | Arcane Mage |
| 17 | Fury | Demon Hunter Fury |
| 18 | Pain | Vengeance DH (legacy) |
| 19 | Essence | Evoker Essence |

### State Checks

| Function | Returns | Description |
|----------|---------|-------------|
| `UnitExists([unit])` | `bool` | Unit exists and can be targeted |
| `UnitIsVisible([unit])` | `bool` | Visible to client (not necessarily line of sight) |
| `UnitIsConnected(unit)` | `bool` | Not offline |
| `UnitIsDead(unit)` | `bool` | Dead |
| `UnitIsDeadOrGhost(unit)` | `bool` | Dead or ghost form |
| `UnitIsGhost(unit)` | `bool` | Ghost form |
| `UnitAffectingCombat(unit)` | `bool` | In combat |
| `UnitIsAFK(unit)` | `bool` | AFK (friendly only) |
| `UnitIsDND(unit)` | `bool` | Do Not Disturb |
| `UnitIsPlayer([unit])` | `bool` | Is a player character |
| `UnitIsEnemy(unit, target)` | `bool` | Units are hostile |
| `UnitIsFriend(unit, target)` | `bool` | Units are friendly |
| `UnitCanAttack(unit, target)` | `bool` | First can attack second |
| `UnitCanAssist(unit, target)` | `bool` | First can assist second |
| `UnitCanCooperate(unit, target)` | `bool` | Can cooperate |
| `UnitIsUnit(unit1, unit2)` | `bool` | Same unit |
| `UnitIsPVP(unit)` | `bool` | PvP flagged |
| `UnitIsCharmed([unit])` | `bool` | Charmed / mind controlled |
| `UnitIsFeignDeath(unit)` | `bool` | Feigning death (group only) |
| `UnitIsTapDenied(unit)` | `bool` | Tap denied (grey health bar) |
| `UnitIsTrivial(unit)` | `bool` | Grey to player |
| `UnitIsBossMob(unit)` | `bool` | Boss unit |
| `IsFalling([unit])` | `bool` | Currently falling |
| `IsFlying([unit])` | `bool` | On flying mount |
| `IsSwimming([unit])` | `bool` | Swimming |
| `IsStealthed()` | `bool` | Player is stealthed |
| `PlayerIsInCombat()` | `bool` | Player in combat |

### Group Membership

| Function | Returns | Description |
|----------|---------|-------------|
| `UnitInParty([unit])` | `bool` | In your party |
| `UnitInRaid([unit])` | `index` | In your raid (returns index) |
| `UnitInAnyGroup([unit])` | `bool` | In any group |
| `UnitPlayerOrPetInParty([unit])` | `bool` | Player or pet in party |
| `UnitPlayerOrPetInRaid([unit])` | `bool` | Player or pet in raid |
| `UnitInRange(unit)` | `inRange, checked` | Within 40yd (25yd Evoker) `#grouponly` |
| `UnitIsGroupLeader(unit [, cat])` | `bool` | Is group leader |
| `UnitIsGroupAssistant(unit)` | `bool` | Is assist |
| `UnitGroupRolesAssigned([unit])` | `role` | "TANK", "HEALER", "DAMAGER", "NONE" |
| `UnitIsInMyGuild(unit)` | `bool` | Same guild |

### Casting Info

| Function | Returns | Description |
|----------|---------|-------------|
| `UnitCastingInfo(unit)` | `name, displayName, textureID, startTimeMs, endTimeMs, isTradeskill, castID, notInterruptible, castingSpellID, castBarID` | Current cast info |
| `UnitChannelInfo(unit)` | `name, displayName, textureID, startTimeMs, endTimeMs, isTradeskill, notInterruptible, spellID, isEmpowered, numEmpowerStages, castBarID` | Channel info |
| `UnitCastingDuration(unit)` | `duration` | Cast duration |
| `UnitChannelDuration(unit)` | `duration` | Channel duration |
| `UnitEmpoweredChannelDuration(unit [, includeHold])` | `duration` | Empower duration |

> **12.0.0 Change:** `notInterruptible` in `UnitCastingInfo` is now nilable. New `castBarID` return added.

### Threat

| Function | Returns | Description |
|----------|---------|-------------|
| `UnitThreatSituation(unit [, mob])` | `status` | 0=low, 1=close, 2=unsafe, 3=tanking |
| `UnitDetailedThreatSituation(unit, mob)` | `isTanking, status, scaledPct, rawPct, rawThreat` | Detailed threat |
| `UnitThreatPercentageOfLead(unit, mob)` | `percent` | % of lead |
| `UnitThreatLeadSituation(unit, mob)` | `status` | Lead situation |

---

## C_UnitAuras — Aura System

The aura API provides buff/debuff data for units. Returns `AuraData` tables.

### Key Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `C_UnitAuras.GetAuraDataByIndex(unit, index [, filter])` | `aura` | Aura by index |
| `C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraInstanceID)` | `aura` | Aura by instance ID |
| `C_UnitAuras.GetAuraDataBySlot(unit, slot)` | `aura` | Aura by slot |
| `C_UnitAuras.GetAuraDataBySpellName(unit, spellName [, filter])` | `aura` | Aura by spell name |
| `C_UnitAuras.GetBuffDataByIndex(unit, index [, filter])` | `aura` | Buff specifically |
| `C_UnitAuras.GetDebuffDataByIndex(unit, index [, filter])` | `aura` | Debuff specifically |
| `C_UnitAuras.GetPlayerAuraBySpellID(spellID)` | `aura` | Player aura by spell ID |
| `C_UnitAuras.GetAuraSlots(unit [, filter [, max [, token]]])` | `continuation, slots...` | Iterate aura slots |
| `C_UnitAuras.GetUnitAuraInstanceIDs(unit, filter [, max [, sort [, dir]]])` | `auraInstanceIDs` | All aura instance IDs |
| `C_UnitAuras.GetUnitAuras(unit, filter [, max [, sort [, dir]]])` | `auras` | All aura data |
| `C_UnitAuras.GetAuraDuration(unit, auraInstanceID)` | `duration` | Remaining duration |
| `C_UnitAuras.GetAuraBaseDuration(unit, auraID [, spellID])` | `duration` | Base duration |
| `C_UnitAuras.DoesAuraHaveExpirationTime(unit, auraID)` | `bool` | Has timer |
| `C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, auraID, filter)` | `bool` | Filtered by current filter |
| `C_UnitAuras.WantsAlteredForm(unit)` | `bool` | Wants altered form |

### Aura Filter Strings

Filters are space-separated strings passed to aura query functions:

| Filter | Description |
|--------|-------------|
| `"HELPFUL"` | Buffs only |
| `"HARMFUL"` | Debuffs only |
| `"PLAYER"` | Only auras cast by the player |
| `"RAID"` | Only auras relevant to the raid |
| `"CANCELABLE"` | Only cancelable auras |
| `"NOT_CANCELABLE"` | Only non-cancelable auras |
| `"INCLUDE_NAME_PLATE_ONLY"` | Include nameplate-only auras |
| `"MAW"` | Maw-specific auras |

Combine with spaces: `"HELPFUL PLAYER"` = buffs cast by player.

### AuraData Structure

Fields returned in an AuraData table:

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Aura name |
| `icon` | number | Texture file ID |
| `applications` | number | Stack count |
| `dispelName` | string? | Dispel type: "Magic", "Curse", "Disease", "Poison" |
| `duration` | number | Total duration (0 = indefinite) |
| `expirationTime` | number | `GetTime()` when it expires |
| `isFromPlayerOrPlayerPet` | bool | Cast by player or player's pet |
| `isHarmful` | bool | Is a debuff |
| `isHelpful` | bool | Is a buff |
| `isNameplateOnly` | bool | Only shows on nameplates |
| `isRaid` | bool | Shows in raid frames |
| `isStealable` | bool | Can be spellstolen |
| `sourceUnit` | UnitId? | Caster |
| `spellId` | number | Spell ID |
| `points` | table | Aura effect values |
| `auraInstanceID` | number | Unique instance ID for this application |
| `timeMod` | number | Time modifier |
| `charges` | number | Number of charges |
| `isBossAura` | bool | Boss aura |
| `nameplateShowAll` | bool | Show all stacks on nameplate |
| `nameplateShowPersonal` | bool | Show personal on nameplate |

### Private Auras

Private auras are auras where the spell data is hidden from addons. Used for encounter mechanics.

| Function | Description |
|----------|-------------|
| `C_UnitAuras.AddPrivateAuraAnchor(args)` | Anchor a frame to a private aura's display position → `anchorID` |
| `C_UnitAuras.RemovePrivateAuraAnchor(anchorID)` | Remove private aura anchor |
| `C_UnitAuras.AddPrivateAuraAppliedSound(sound)` | Play sound when private aura applied → `soundID` |
| `C_UnitAuras.RemovePrivateAuraAppliedSound(soundID)` | Remove private aura sound |
| `C_UnitAuras.AuraIsPrivate(spellID)` | Check if spell is private |
| `C_UnitAuras.AuraIsBigDefensive(spellID)` | Check if big defensive CD |
| `C_UnitAuras.SetPrivateWarningTextAnchor(parent [, anchor])` | Set warning text anchor |
| `C_UnitAuras.TriggerPrivateAuraShowDispelType(show)` | Toggle dispel type display |

### Aura Iteration Pattern

```lua
-- Modern pattern: iterate by aura instance IDs
local function GetAllAuras(unit, filter)
    local auras = {}
    local ids = C_UnitAuras.GetUnitAuraInstanceIDs(unit, filter)
    for _, id in ipairs(ids) do
        local aura = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, id)
        if aura then
            table.insert(auras, aura)
        end
    end
    return auras
end

-- Get all player debuffs
local debuffs = GetAllAuras("player", "HARMFUL")
```

### UNIT_AURA Event

```lua
-- UNIT_AURA fires when any aura changes on a unit
-- Payload: unitTarget, updateInfo
-- updateInfo contains: addedAuras, updatedAuraInstanceIDs, removedAuraInstanceIDs
-- isFullUpdate (bool) — if true, full refresh is needed

local frame = CreateFrame("Frame")
frame:RegisterUnitEvent("UNIT_AURA", "player")
frame:SetScript("OnEvent", function(self, event, unit, updateInfo)
    if updateInfo.isFullUpdate then
        -- re-scan all auras
        return
    end
    if updateInfo.addedAuras then
        for _, aura in ipairs(updateInfo.addedAuras) do
            print("Added:", aura.name, aura.spellId)
        end
    end
    if updateInfo.removedAuraInstanceIDs then
        for _, id in ipairs(updateInfo.removedAuraInstanceIDs) do
            print("Removed aura instance:", id)
        end
    end
end)
```

---

## C_PlayerInfo — Player Information

| Function | Returns | Description |
|----------|---------|-------------|
| `C_PlayerInfo.GUIDIsPlayer(guid)` | `bool` | GUID belongs to a player |
| `C_PlayerInfo.GetClass(playerLocation)` | `className, classFilename, classID` | Player class |
| `C_PlayerInfo.GetName(playerLocation)` | `name` | Player name |
| `C_PlayerInfo.GetRace(playerLocation)` | `raceID` | Player race |
| `C_PlayerInfo.GetSex(playerLocation)` | `sex` | Player sex |
| `C_PlayerInfo.GetContentDifficultyCreatureForPlayer(unit)` | `difficulty` | Content difficulty |
| `C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unit)` | `ratingSummary` | M+ rating |

> **Source:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#PlayerLocationInfo

---

## C_PaperDollInfo — Equipment & Inspection

| Function | Returns | Description |
|----------|---------|-------------|
| `C_PaperDollInfo.GetInspectItemLevel(unit)` | `itemLevel` | Inspected unit's avg ilvl |
| `C_PaperDollInfo.GetInspectGuildInfo(unit)` | `achPoints, numMembers, guildName, realm` | Guild info for inspected |
| `C_PaperDollInfo.GetArmorEffectiveness(armor, attackerLvl)` | `effectiveness` | Armor DR % |
| `C_PaperDollInfo.GetArmorEffectivenessAgainstTarget(armor)` | `effectiveness` | Armor DR vs target |
| `C_PaperDollInfo.GetStaggerPercentage(unit)` | `stagger, staggerVsTarget` | Monk stagger % |
| `C_PaperDollInfo.GetMinItemLevel()` | `minItemLevel` | Minimum ilvl |
| `C_PaperDollInfo.CanAutoEquipCursorItem()` | `bool` | Can auto-equip |
| `C_PaperDollInfo.CanCursorCanGoInSlot(slot)` | `bool` | Cursor item fits slot |
| `C_PaperDollInfo.IsInventorySlotEnabled(slotName)` | `bool` | Slot enabled |
| `C_PaperDollInfo.GetInspectRatedBGData()` | `data` | Inspected rated BG info |
| `C_PaperDollInfo.GetInspectRatedSoloShuffleData()` | `data` | Inspected solo shuffle info |

### Inspection Flow

```lua
-- 1. Request inspection data
NotifyInspect("target")

-- 2. Wait for INSPECT_READY event
local frame = CreateFrame("Frame")
frame:RegisterEvent("INSPECT_READY")
frame:SetScript("OnEvent", function(self, event, inspecteeGUID)
    local spec = GetInspectSpecialization("target")
    local ilvl = C_PaperDollInfo.GetInspectItemLevel("target")
    print("Spec:", spec, "iLvl:", ilvl)
    ClearInspectPlayer() -- Clean up
    self:UnregisterEvent("INSPECT_READY")
end)
```

---

## UnitRole — Group Roles

| Function | Returns | Description |
|----------|---------|-------------|
| `UnitGroupRolesAssigned([unit])` | `"TANK"/"HEALER"/"DAMAGER"/"NONE"` | Assigned role |
| `UnitGroupRolesAssignedEnum([unit])` | `enum` | Role as enum value |
| `UnitGetAvailableRoles(unit)` | `tank, healer, dps` | Available roles (booleans) |
| `UnitSetRole(unit [, roleStr])` | `success` | Set role |
| `UnitSetRoleEnum(unit [, role])` | `success` | Set role by enum |
| `CanShowSetRoleButton()` | `bool` | Role button available |
| `InitiateRolePoll()` | `success` | Start role poll |
| `AreClassRolesSoftSuggestions()` | `bool` | Roles are soft suggestions |

---

## Player Character Stats

These global functions query the player's character stats.

### Combat Ratings & Stats

| Function | Returns | Description |
|----------|---------|-------------|
| `GetCritChance()` | `percent` | Melee crit % |
| `GetRangedCritChance()` | `percent` | Ranged crit % |
| `GetHaste()` | `percent` | Haste % |
| `GetMeleeHaste()` | `percent` | Melee haste % |
| `GetRangedHaste()` | `percent` | Ranged haste % |
| `UnitSpellHaste(unit)` | `percent` | Spell haste % |
| `GetMastery()` | `percent` | Base mastery % |
| `GetMasteryEffect()` | `effect, coefficient` | Effective mastery |
| `GetDodgeChance()` | `percent` | Dodge % |
| `GetParryChance()` | `percent` | Parry % |
| `GetBlockChance()` | `percent` | Block % |
| `GetLifesteal()` | `percent` | Leech % |
| `GetAvoidance()` | `percent` | Avoidance % |
| `GetCombatRating(ratingIndex)` | `rating` | Raw combat rating value |
| `GetCombatRatingBonus(ratingIndex)` | `bonus` | Bonus % from rating |
| `UnitStat(unit, index)` | `cur, eff, posBuff, negBuff` | Primary stat (1=Str, 2=Agi, 3=Sta, 4=Int) |
| `UnitArmor(unit)` | `base, effective, real, bonus` | Armor values |
| `UnitAttackPower(unit)` | `ap, posBuff, negBuff` | Melee attack power |
| `UnitAttackSpeed(unit)` | `mainhand, offhand` | Attack speed |
| `UnitDamage(unit)` | `min, max, ohMin, ohMax, posBuff, negBuff, pct` | Damage range |
| `UnitRangedAttackPower(unit)` | `ap, posBuff, negBuff` | Ranged AP |
| `UnitRangedDamage(unit)` | `speed, min, max, posBuff, negBuff, pct` | Ranged damage |
| `GetManaRegen()` | `base, casting` | Mana regen/sec |
| `GetPowerRegen()` | `base, casting` | Power regen/sec |

### Player XP & Level

| Function | Returns | Description |
|----------|---------|-------------|
| `UnitXP("player")` | `xp` | Current XP |
| `UnitXPMax("player")` | `maxXP` | XP to next level |
| `GetMaxPlayerLevel()` | `level` | Level cap |
| `GetRestState()` | `exhaustionID, name, factor` | Rested state |
| `IsXPUserDisabled()` | `bool` | XP frozen |

### Money & Economy

| Function | Returns | Description |
|----------|---------|-------------|
| `GetMoney()` | `copper` | Total money in copper |

### Movement

| Function | Returns | Description |
|----------|---------|-------------|
| `GetUnitSpeed(unit)` | `current, run, flight, swim` | Movement speeds |
| `GetPlayerFacing()` | `radians` | Direction facing `#noinstance` |
| `UnitPosition(unit)` | `x, y, z, mapID` | World position `#noinstance` |
| `UnitDistanceSquared(unit)` | `distSq, checked` | Squared distance `#noinstance` |
| `UnitOnTaxi(unit)` | `bool` | On flight path |

### Death & Resurrection

| Function | Returns | Description |
|----------|---------|-------------|
| `RepopMe()` | — | Release spirit |
| `RetrieveCorpse()` | — | Resurrect at corpse |
| `AcceptResurrect()` | — | Accept rez offer |
| `DeclineResurrect()` | — | Decline rez offer |
| `ResurrectGetOfferer()` | `name` | Who is offering rez |
| `ResurrectHasSickness()` | `bool` | Rez will give sickness |
| `ResurrectHasTimer()` | `bool` | Must wait before accepting |
| `GetCorpseRecoveryDelay()` | `seconds` | Delay before rez |
| `GetReleaseTimeRemaining()` | `seconds` | Time until forced release |
| `C_IncomingSummon.HasIncomingSummon(unit)` | `bool` | Has pending summon |
| `C_IncomingSummon.IncomingSummonStatus(unit)` | `status` | Summon status |
| `UnitHasIncomingResurrection(unit)` | `bool` | Being resurrected |

---

## Secret Values — 12.0.0 Impact on Unit APIs

Many unit functions now return **secret values** under certain conditions. See the `wow-api-important` instructions for full details.

### Functions Returning Secrets

| Function | When Secret |
|----------|-------------|
| `UnitHealth(unit)` | When health is restricted |
| `UnitHealthMax(unit)` | When health is restricted |
| `UnitName(unit)` | When unit identity restricted in combat (non-player units in instances) |
| `UnitClass(unit)` | First return conditionally secret |
| `UnitPower(unit)` | When power is restricted |

### Safe Pattern: Display Health

```lua
-- CORRECT: Pass secret values directly to widgets
local hp = UnitHealth("target")
local maxHp = UnitHealthMax("target")
myStatusBar:SetMinMaxValues(0, maxHp) -- accepts secrets
myStatusBar:SetValue(hp)              -- accepts secrets

-- WRONG: Do NOT compare or do math
-- if hp < maxHp * 0.3 then -- ERROR: cannot compare secrets
```

### Checking Restrictions

```lua
-- Check if unit identity is restricted
local isSecret = C_Secrets.ShouldUnitIdentityBeSecret("target")
local isHealthSecret = C_Secrets.ShouldUnitHealthMaxBeSecret("target")
local isPowerSecret = C_Secrets.ShouldUnitPowerBeSecret("target")
```

---

## Common Patterns

### Unit Frame Health Bar

```lua
local frame = CreateFrame("Frame", nil, UIParent)
local healthBar = CreateFrame("StatusBar", nil, frame)
healthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
healthBar:SetMinMaxValues(0, 1)

local function UpdateHealth(unit)
    local hp = UnitHealth(unit)
    local maxHp = UnitHealthMax(unit)
    healthBar:SetMinMaxValues(0, maxHp)
    healthBar:SetValue(hp)
end

frame:RegisterUnitEvent("UNIT_HEALTH", "target")
frame:RegisterUnitEvent("UNIT_MAXHEALTH", "target")
frame:SetScript("OnEvent", function(self, event, unit)
    UpdateHealth(unit)
end)
```

### Check if Unit is a Healable Friendly

```lua
local function IsHealableUnit(unit)
    return UnitExists(unit)
        and UnitCanAssist("player", unit)
        and not UnitIsDeadOrGhost(unit)
        and UnitIsConnected(unit)
end
```

### Get NPC ID from Target

```lua
local function GetNPCID(unit)
    local guid = UnitGUID(unit)
    if not guid then return nil end
    local unitType, _, _, _, _, npcID = strsplit("-", guid)
    if unitType == "Creature" or unitType == "Vehicle" then
        return tonumber(npcID)
    end
end
```

---

## Related Events

| Event | Payload | Description |
|-------|---------|-------------|
| `UNIT_HEALTH` | `unitTarget` | Health changed |
| `UNIT_MAXHEALTH` | `unitTarget` | Max health changed |
| `UNIT_POWER_UPDATE` | `unitTarget, powerType` | Power changed |
| `UNIT_POWER_FREQUENT` | `unitTarget, powerType` | Power changed (frequent) |
| `UNIT_MAXPOWER` | `unitTarget, powerType` | Max power changed |
| `UNIT_AURA` | `unitTarget, updateInfo` | Auras changed |
| `UNIT_TARGET` | `unitTarget` | Target changed |
| `UNIT_LEVEL` | `unitTarget` | Level changed |
| `UNIT_NAME_UPDATE` | `unitTarget` | Name updated |
| `UNIT_FACTION` | `unitTarget` | Faction changed |
| `UNIT_FLAGS` | `unitTarget` | Flags changed (PvP, AFK, etc.) |
| `UNIT_SPELLCAST_START` | `unitTarget, castGUID, spellID` | Cast started |
| `UNIT_SPELLCAST_STOP` | `unitTarget, castGUID, spellID` | Cast stopped |
| `UNIT_SPELLCAST_SUCCEEDED` | `unitTarget, castGUID, spellID` | Cast succeeded |
| `UNIT_SPELLCAST_CHANNEL_START` | `unitTarget, castGUID, spellID` | Channel started |
| `UNIT_SPELLCAST_CHANNEL_STOP` | `unitTarget, castGUID, spellID` | Channel stopped |
| `UNIT_SPELLCAST_EMPOWER_START` | `unitTarget, castGUID, spellID` | Empower started |
| `UNIT_SPELLCAST_EMPOWER_STOP` | `unitTarget, castGUID, spellID, complete` | Empower stopped |
| `UNIT_THREAT_SITUATION_UPDATE` | `unitTarget` | Threat changed |
| `UNIT_THREAT_LIST_UPDATE` | `unitTarget` | Threat list changed |
| `UNIT_CONNECTION` | `unitTarget, isConnected` | Online/offline |
| `UNIT_STATS` | `unitTarget` | Stats changed |
| `UNIT_ATTACK_POWER` | `unitTarget` | AP changed |
| `UNIT_SPELL_HASTE` | `unitTarget` | Spell haste changed |
| `UNIT_COMBAT` | `unitTarget, event, flagText, amount, schoolMask` | Combat text event |
| `UNIT_INVENTORY_CHANGED` | `unitTarget` | Equipped items changed |
| `PLAYER_TARGET_CHANGED` | — | Player target changed |
| `PLAYER_FOCUS_CHANGED` | — | Focus target changed |
| `PLAYER_ENTERING_WORLD` | `isInitialLogin, isReloadingUi` | Zone/instance load |
| `PLAYER_DEAD` | — | Player died |
| `PLAYER_ALIVE` | — | Player alive (accept rez) |
| `PLAYER_UNGHOST` | — | Player no longer ghost |
| `PLAYER_REGEN_ENABLED` | — | Left combat |
| `PLAYER_REGEN_DISABLED` | — | Entered combat |
| `INSPECT_READY` | `inspecteeGUID` | Inspection data available |
| `GROUP_ROSTER_UPDATE` | — | Group composition changed |
| `ROLE_CHANGED_INFORM` | `changedName, from, oldRole, newRole` | Role changed |

---

## Restrictions & Gotchas

| Restriction | Details |
|-------------|---------|
| `#noinstance` | `UnitPosition`, `UnitDistanceSquared`, `GetPlayerFacing` blocked in instances |
| `#grouponly` | `UnitInRange` only works for group members |
| `#nocombat` | `CheckInteractDistance` blocked in combat |
| Secret values (12.0) | Health, name, power may be secret — cannot compare/branch, only pass to widgets |
| `NotifyInspect` throttle | Inspecting too fast will be throttled by the server |
| `UnitIsPlayer` | Charmed players may return false for some APIs |

> **Sources:**
> - https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#Unit
> - https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#UnitAuras
> - https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#UnitRole
> - https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#PlayerScript
> - https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#PaperDollInfo
> - https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#PlayerLocationInfo
> - https://warcraft.wiki.gg/wiki/UnitId
> - https://warcraft.wiki.gg/wiki/GUID
```
