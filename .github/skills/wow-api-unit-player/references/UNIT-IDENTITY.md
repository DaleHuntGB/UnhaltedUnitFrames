# Unit Identity Reference

> **Source:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#Unit
> **Patch:** 12.0.0 (Retail)

## UnitId Token System

A **UnitId** (unit token) is a string that identifies a unit by its relationship to the player. UnitIds are case-insensitive and used as the first argument to most unit functions.

### Base Tokens

| Token | Description | Notes |
|-------|-------------|-------|
| `"player"` | The player character | Always valid |
| `"target"` | Player's current target | Invalid if nothing targeted |
| `"focus"` | Player's focus target | Set by `/focus`, cleared by `/clearfocus` |
| `"pet"` | Player's pet | Hunter/Warlock/Mage pets, shaman totems |
| `"vehicle"` | Vehicle the player is controlling | Only valid while in a vehicle |
| `"mouseover"` | Unit under the mouse cursor | Most recently moused-over unit |
| `"none"` | Empty token | Always "does not exist" — use for "no target" defaults |
| `"npc"` | Currently interacting NPC | Quest giver, merchant, gossip NPC |
| `"questnpc"` | Quest giver being interacted with | Subset of "npc" for quest-related |
| `"softinteract"` | Soft-target interact candidate | Patch 10.0+ |
| `"softenemy"` | Soft-target hostile unit | Patch 10.0+ |
| `"softfriend"` | Soft-target friendly unit | Patch 10.0+ |

### Indexed Tokens

| Pattern | Range | Example | Description |
|---------|-------|---------|-------------|
| `"partyN"` | 1–4 | `"party2"` | Nth party member (excludes player) |
| `"raidN"` | 1–40 | `"raid15"` | Nth raid member (includes player) |
| `"partypetN"` | 1–4 | `"partypet1"` | Pet of Nth party member |
| `"raidpetN"` | 1–40 | `"raidpet5"` | Pet of Nth raid member |
| `"bossN"` | 1–8 | `"boss1"` | Nth boss in encounter |
| `"arenaN"` | 1–5 | `"arena3"` | Nth opposing arena team member |
| `"nameplateN"` | 1–40 | `"nameplate7"` | Nth visible nameplate |

### Target Chaining

Append `"target"` to any UnitId to query that unit's target. Can be chained:

```lua
-- Direct
UnitName("target")           -- your target's name
UnitName("targettarget")     -- your target's target's name
UnitName("targettargettarget") -- 3 levels deep

-- Group members
UnitName("party1target")     -- party member 1's target
UnitName("raid10target")     -- raid member 10's target
UnitName("pettarget")        -- your pet's target
UnitName("focustarget")      -- your focus target's target

-- Named player (must be in your group)
UnitName("Arthas-Frostmourne-target") -- named player's target
```

### Soft Targeting (10.0+)

| Token | Priority Rule |
|-------|---------------|
| `"anyenemy"` | Resolves to `"target"` if hostile, else `"softenemy"` |
| `"anyfriend"` | Resolves to `"target"` if friendly, else `"softfriend"` |
| `"anyinteract"` | Resolves to `"target"` if interactable, else `"softinteract"` |

### UnitId Patterns

```lua
-- Check if a UnitId is valid
if UnitExists("target") then
    print(UnitName("target"))
end

-- Iterate party members
for i = 1, 4 do
    local unit = "party" .. i
    if UnitExists(unit) then
        print(UnitName(unit))
    end
end

-- Iterate raid members
for i = 1, 40 do
    local unit = "raid" .. i
    if UnitExists(unit) then
        print(i, UnitName(unit))
    end
end

-- Find player in raid
local function GetPlayerRaidIndex()
    for i = 1, 40 do
        if UnitIsUnit("raid" .. i, "player") then
            return i
        end
    end
end
```

> **Source:** https://warcraft.wiki.gg/wiki/UnitId

---

## GUID (Globally Unique Identifier)

Every interactable entity has a GUID. Obtained via `UnitGUID(unit)`.

### GUID Format by Type

| Type | Format |
|------|--------|
| **Player** | `Player-[serverID]-[playerUID]` |
| **Creature** | `Creature-0-[serverID]-[instanceID]-[zoneUID]-[npcID]-[spawnUID]` |
| **Pet** | `Pet-0-[serverID]-[instanceID]-[zoneUID]-[npcID]-[spawnUID]` |
| **Vehicle** | `Vehicle-0-[serverID]-[instanceID]-[zoneUID]-[npcID]-[spawnUID]` |
| **GameObject** | `GameObject-0-[serverID]-[instanceID]-[zoneUID]-[objectID]-[spawnUID]` |
| **Item** | `Item-[serverID]-0-[spawnUID]` |
| **Vignette** | `Vignette-0-[serverID]-[instanceID]-[zoneUID]-[vignetteID]-[spawnUID]` |
| **BattlePet** | `BattlePet-0-[ID]` |
| **Cast** | `Cast-[type]-[serverID]-[instanceID]-[zoneUID]-[spellID]-[castUID]` |

### GUID Field Descriptions

| Field | Description |
|-------|-------------|
| `serverID` | Realm/server identifier |
| `playerUID` | Permanent per-player hex UID |
| `instanceID` | Current instance/map ID |
| `zoneUID` | Zone sub-identifier |
| `npcID` / `objectID` | Database ID from wowhead |
| `spawnUID` | Unique identifier per spawn cycle |

### GUID Utility Functions

```lua
-- Extract unit type from GUID
local function GetGUIDType(guid)
    return strsplit("-", guid)
end

-- Extract NPC ID
local function GetNPCIDFromGUID(guid)
    local unitType, _, _, _, _, npcID = strsplit("-", guid)
    if unitType == "Creature" or unitType == "Vehicle" then
        return tonumber(npcID)
    end
end

-- Extract Player UID
local function GetPlayerUID(guid)
    local unitType, serverID, playerUID = strsplit("-", guid)
    if unitType == "Player" then
        return serverID, playerUID
    end
end

-- Compare two units by GUID
local function IsSameUnit(guid1, guid2)
    return guid1 and guid2 and guid1 == guid2
end
```

### GUID Lifecycle Rules

- **Player GUIDs** — Permanent; survive logout. Change on faction change or paid transfer.
- **Creature GUIDs** — New GUID each spawn cycle. Recycled on server restart.
- **Pet GUIDs** — New GUID each time summoned.
- **Item GUIDs** — Tied to item instance. Disappear when item is destroyed.

> **Source:** https://warcraft.wiki.gg/wiki/GUID

---

## Name & Identity Functions

### UnitName(unit)

Returns the name and realm of a unit.

```lua
local name, realm = UnitName("target")
-- name: "Thrall"
-- realm: "Nagrand" (nil if same realm)
```

**Gotcha:** In 12.0.0, `UnitName` may return a **secret value** for nameplates and certain non-player units in instances. Check with `C_Secrets.ShouldUnitIdentityBeSecret(unit)`.

### UnitFullName(unit)

Same as `UnitName` but always returns the realm even if same.

### UnitNameUnmodified(unit)

Returns the name without any modifications (e.g., title-less).

### UnitGUID(unit)

```lua
local guid = UnitGUID("target")
-- "Creature-0-1465-0-2105-448-000043F59F"
```

### UnitTokenFromGUID(guid)

Returns the UnitId token for a GUID, if the unit is currently available.

```lua
local token = UnitTokenFromGUID(UnitGUID("target"))
-- "target" or "nameplate5" etc.
```

### UnitClass(unit)

```lua
local className, classFilename, classID = UnitClass("player")
-- "Warrior", "WARRIOR", 1
```

| classID | classFilename | Class |
|---------|--------------|-------|
| 1 | WARRIOR | Warrior |
| 2 | PALADIN | Paladin |
| 3 | HUNTER | Hunter |
| 4 | ROGUE | Rogue |
| 5 | PRIEST | Priest |
| 6 | DEATHKNIGHT | Death Knight |
| 7 | SHAMAN | Shaman |
| 8 | MAGE | Mage |
| 9 | WARLOCK | Warlock |
| 10 | MONK | Monk |
| 11 | DRUID | Druid |
| 12 | DEMONHUNTER | Demon Hunter |
| 13 | EVOKER | Evoker |

### UnitRace(unit)

```lua
local raceName, raceFile, raceID = UnitRace("player")
-- "Human", "Human", 1
```

### UnitLevel(unit)

```lua
local level = UnitLevel("target")
-- -1 for skull (??) units
```

### UnitEffectiveLevel(unit)

Returns the scaled level (chromie time / party sync level).

### UnitSex(unit)

Returns: `1` = unknown/none, `2` = male, `3` = female

### UnitFactionGroup(unit [, checkDisplayRace])

```lua
local faction, localized = UnitFactionGroup("player")
-- "Horde", "Horde" or "Alliance", "Alliance"
```

### UnitClassification(unit)

Returns creature classification string:

| Return | Meaning |
|--------|---------|
| `"normal"` | Normal mob |
| `"elite"` | Elite |
| `"rareelite"` | Rare Elite |
| `"rare"` | Rare |
| `"worldboss"` | World Boss |
| `"trivial"` | Trivial (grey) |
| `"minus"` | Minor mob (no XP/loot) |

### UnitCreatureType(unit)

Returns: `"Beast"`, `"Humanoid"`, `"Undead"`, `"Elemental"`, `"Demon"`, `"Dragonkin"`, `"Mechanical"`, `"Aberration"`, `"Giant"`, etc.

### GetPlayerInfoByGUID(guid)

```lua
local localizedClass, engClass, localizedRace, engRace, sex, name, realm = GetPlayerInfoByGUID(guid)
```

Only works for player GUIDs. Returns nil for non-players.

---

## C_Secrets — Secret Value Predicates (12.0.0)

Functions to check if unit data is currently restricted/secret.

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Secrets.ShouldUnitIdentityBeSecret(unit)` | `bool` | Name/class restricted |
| `C_Secrets.ShouldUnitHealthMaxBeSecret(unit)` | `bool` | Health values restricted |
| `C_Secrets.ShouldUnitPowerBeSecret(unit)` | `bool` | Power values restricted |
| `C_Secrets.ShouldUnitFactionBeSecret(unit)` | `bool` | Faction restricted |
| `C_Secrets.ShouldUnitLevelBeSecret(unit)` | `bool` | Level restricted |
| `C_Secrets.ShouldDispelTypeBeSecret(unit)` | `bool` | Dispel type restricted |
| `C_Secrets.ShouldCastInfoBeSecret(unit)` | `bool` | Cast info restricted |
| `C_Secrets.ShouldUnitAuraBeSecret(unit, auraID)` | `bool` | Specific aura restricted |
| `C_Secrets.ShouldTargetIdentityBeSecret(targetUnit)` | `bool` | Target identity restricted |
| `C_Secrets.ShouldAddonViewBeSecret(guid)` | `bool` | Addon model restricted |
| `C_Secrets.ShouldWidgetBeSecret(unit, widgetID)` | `bool` | Widget restricted |

### Using Secret Predicates

```lua
local function SafeGetUnitName(unit)
    if C_Secrets.ShouldUnitIdentityBeSecret(unit) then
        return "Unknown" -- fallback for UI display
    end
    return UnitName(unit)
end
```

> **Source:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#Secrets
