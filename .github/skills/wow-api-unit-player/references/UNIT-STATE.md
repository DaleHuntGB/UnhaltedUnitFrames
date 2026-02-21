# Unit State Reference

> **Source:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#Unit
> **Patch:** 12.0.0 (Retail)

## Existence & Visibility

| Function | Returns | Description |
|----------|---------|-------------|
| `UnitExists([unit])` | `bool` | Unit exists and is valid for API calls |
| `UnitIsVisible([unit])` | `bool` | Client can see the unit (loaded model) |
| `UnitIsConnected(unit)` | `bool` | Player is online (not disconnected) |
| `UnitIsUnit(unit1, unit2)` | `bool` | Both tokens refer to same unit |

### UnitExists Notes

- Returns `false` for `"none"`, `nil`, and invalid tokens.
- Returns `true` for offline group members.
- Does NOT check line of sight — only that the unit token resolves to something.

```lua
if UnitExists("target") then
    -- target is valid
end

-- Check if two tokens are the same unit
if UnitIsUnit("target", "focus") then
    print("Target is also focus")
end
```

---

## Life & Death State

| Function | Returns | Description |
|----------|---------|-------------|
| `UnitIsDead(unit)` | `bool` | Dead (true if Feign Death too!) |
| `UnitIsDeadOrGhost(unit)` | `bool` | Dead or in ghost form |
| `UnitIsGhost(unit)` | `bool` | In ghost form (released spirit) |
| `UnitIsFeignDeath(unit)` | `bool` | Feigning death — only for group members |

### Death Check Pattern

```lua
-- Most accurate "is actually dead" check for group members
local function IsActuallyDead(unit)
    return UnitIsDeadOrGhost(unit) and not UnitIsFeignDeath(unit)
end
```

**Gotcha:** `UnitIsDead("target")` returns `true` for Feign Death hunters. Always check `UnitIsFeignDeath` if the unit is in your group to avoid false positives.

---

## Combat State

| Function | Returns | Description |
|----------|---------|-------------|
| `UnitAffectingCombat(unit)` | `bool` | In combat |
| `PlayerIsInCombat()` | `bool` | Player specifically in combat |
| `IsCurrentSpell(spellID)` | `bool` | Spell is currently being cast |
| `InCombatLockdown()` | `bool` | Player in combat (frame API restricted) |

### Combat Event Pattern

```lua
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")  -- Entered combat
frame:RegisterEvent("PLAYER_REGEN_ENABLED")   -- Left combat
frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_REGEN_DISABLED" then
        print("Combat started")
    else
        print("Combat ended")
    end
end)
```

---

## Player Status Flags

| Function | Returns | Description |
|----------|---------|-------------|
| `UnitIsAFK(unit)` | `bool` | AFK status (friendly units only) |
| `UnitIsDND(unit)` | `bool` | Do Not Disturb |
| `UnitIsPVP(unit)` | `bool` | PvP flagged |
| `UnitIsPVPFreeForAll(unit)` | `bool` | In free-for-all PvP zone |
| `UnitIsPlayer([unit])` | `bool` | Is a player character (not NPC) |
| `UnitIsCharmed([unit])` | `bool` | Charmed/mind controlled |
| `UnitIsPossessed(unit)` | `bool` | Possessed by another unit |
| `UnitIsTapDenied(unit)` | `bool` | Tap denied (grey health bar) |
| `UnitIsTrivial(unit)` | `bool` | Grey/trivial to player |
| `UnitIsBossMob(unit)` | `bool` | Boss encounter unit |
| `UnitIsQuestBoss(unit)` | `bool` | Quest-objective boss |
| `UnitIsOtherPlayersBattlePet(unit)` | `bool` | Another player's battle pet |
| `UnitIsWildBattlePet(unit)` | `bool` | Wild battle pet |
| `UnitIsMercenary(unit)` | `bool` | Playing as opposite faction |

---

## Faction & Hostility

| Function | Returns | Description |
|----------|---------|-------------|
| `UnitIsEnemy(unit, target)` | `bool` | Two units are hostile |
| `UnitIsFriend(unit, target)` | `bool` | Two units are friendly |
| `UnitCanAttack(unit, target)` | `bool` | First can attack second |
| `UnitCanAssist(unit, target)` | `bool` | First can assist second |
| `UnitCanCooperate(unit, target)` | `bool` | Units can cooperate |
| `UnitReaction(unit, target)` | `reaction` | Reaction level (1-8) |
| `UnitPlayerControlled(unit)` | `bool` | Controlled by a player |
| `UnitIsOwnerOrControllerOfUnit(controllingUnit, controlledUnit)` | `bool` | Ownership check |

### UnitReaction Values

| Value | Meaning | Color |
|-------|---------|-------|
| 1 | Exceptionally Hostile | |
| 2 | Very Hostile | Red |
| 3 | Hostile | Red |
| 4 | Neutral | Yellow |
| 5 | Friendly | Green |
| 6 | Honored | Green |
| 7 | Revered | Green |
| 8 | Exalted | Green |

```lua
local reaction = UnitReaction("player", "target")
if reaction and reaction <= 4 then
    print("Hostile or neutral")
elseif reaction and reaction >= 5 then
    print("Friendly")
end
```

---

## Casting State

### UnitCastingInfo(unit)

Returns info about the spell currently being cast.

```lua
local name, displayName, texture, startTimeMs, endTimeMs,
      isTradeskill, castID, notInterruptible, spellID, castBarID = UnitCastingInfo("target")
```

| Return | Type | Description |
|--------|------|-------------|
| `name` | string | Spell name |
| `displayName` | string | Display name (may differ from name) |
| `texture` | number | Spell icon texture ID |
| `startTimeMs` | number | Start time in milliseconds (`GetTime() * 1000`) |
| `endTimeMs` | number | End time in milliseconds |
| `isTradeskill` | bool | Is a profession cast |
| `castID` | number | Unique cast instance ID |
| `notInterruptible` | bool? | `true` if cannot be interrupted (nilable in 12.0) |
| `spellID` | number | Spell ID |
| `castBarID` | number | Cast bar identifier (new in 12.0) |

Returns `nil` if not casting.

### UnitChannelInfo(unit)

Returns info about a channeled spell.

```lua
local name, displayName, texture, startTimeMs, endTimeMs,
      isTradeskill, notInterruptible, spellID, isEmpowered,
      numEmpowerStages, castBarID = UnitChannelInfo("target")
```

Additional returns for channels:
- `isEmpowered` (bool): Evoker empowered cast
- `numEmpowerStages` (number): Number of empower stages

### Cast Duration Helpers

| Function | Returns | Description |
|----------|---------|-------------|
| `UnitCastingDuration(unit)` | `duration` | Remaining cast duration (ms) |
| `UnitChannelDuration(unit)` | `duration` | Remaining channel duration (ms) |
| `UnitEmpoweredChannelDuration(unit [, includeHold])` | `duration` | Empower duration |

### Cast Bar Pattern

```lua
local frame = CreateFrame("Frame")
frame:RegisterUnitEvent("UNIT_SPELLCAST_START", "target")
frame:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "target")
frame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "target")
frame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "target")
frame:SetScript("OnEvent", function(self, event, unit, castGUID, spellID)
    if event == "UNIT_SPELLCAST_START" then
        local name = UnitCastingInfo(unit)
        if name then
            print(UnitName(unit), "casting:", name)
        end
    elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
        local name = UnitChannelInfo(unit)
        if name then
            print(UnitName(unit), "channeling:", name)
        end
    end
end)
```

---

## Vehicle State

| Function | Returns | Description |
|----------|---------|-------------|
| `UnitInVehicle(unit)` | `bool` | In a vehicle |
| `UnitHasVehicleUI([unit])` | `bool` | Has vehicle action bar |
| `UnitUsingVehicle([unit])` | `bool` | Using vehicle controls |
| `UnitControllingVehicle(unit)` | `bool` | Controlling the vehicle |
| `UnitVehicleSkin(unit)` | `skin` | Vehicle skin |
| `UnitVehicleSeatCount(unit)` | `count` | Number of seats |
| `UnitVehicleSeatInfo(unit, seat)` | `info` | Seat info |

---

## Movement State

| Function | Returns | Restrictions | Description |
|----------|---------|-------------|-------------|
| `IsFalling([unit])` | `bool` | — | Free-falling |
| `IsFlying([unit])` | `bool` | — | On a flying mount |
| `IsSwimming([unit])` | `bool` | — | In water |
| `IsMounted()` | `bool` | — | On any mount |
| `IsIndoors()` | `bool` | — | Indoors |
| `IsOutdoors()` | `bool` | — | Outdoors |
| `IsStealthed()` | `bool` | — | Player is stealthed |
| `UnitOnTaxi(unit)` | `bool` | — | On flight path |
| `GetUnitSpeed(unit)` | `cur, run, fly, swim` | — | Movement speeds |
| `GetPlayerFacing()` | `radians` | `#noinstance` | Direction facing |
| `UnitPosition(unit)` | `x, y, z, mapID` | `#noinstance` | World coordinates |
| `UnitDistanceSquared(unit)` | `distSq, checked` | `#noinstance` | Distance squared |

### Movement Speed Pattern

```lua
local current, running, flying, swimming = GetUnitSpeed("player")
local baseSpeed = 7 -- yards per second
local speedPercent = (current / baseSpeed) * 100
print("Moving at " .. speedPercent .. "% speed")
```

### Distance Check (Open World Only)

```lua
-- ONLY works outside instances
local function GetDistanceTo(unit)
    local distSq, valid = UnitDistanceSquared(unit)
    if valid then
        return math.sqrt(distSq)
    end
end
```

---

## Group Membership

| Function | Returns | Description |
|----------|---------|-------------|
| `UnitInParty([unit])` | `bool` | In your party |
| `UnitInRaid([unit])` | `index` | In your raid (returns index) |
| `UnitInAnyGroup([unit])` | `bool` | In any group |
| `UnitPlayerOrPetInParty([unit])` | `bool` | Player or their pet in party |
| `UnitPlayerOrPetInRaid([unit])` | `bool` | Player or their pet in raid |
| `UnitIsGroupLeader(unit [, category])` | `bool` | Is group leader |
| `UnitIsGroupAssistant(unit)` | `bool` | Is raid assistant |
| `UnitIsInMyGuild(unit)` | `bool` | Same guild |
| `UnitInRange(unit)` | `inRange, checked` | Within interaction range |
| `UnitPhaseReason(unit)` | `reason` | Phase mismatch reason |

### UnitInRange Notes

- Only works for **group members**.
- Default range: 40 yards (25 for Evoker).
- Returns `inRange` (bool) and `checked` (bool — false if couldn't check).

```lua
local inRange, valid = UnitInRange("party1")
if valid and inRange then
    print("In range for heals")
end
```

### Group Iteration Pattern

```lua
local function IterateGroup(callback)
    local inRaid = IsInRaid()
    local maxMembers = inRaid and 40 or 4
    local prefix = inRaid and "raid" or "party"
    
    for i = 1, maxMembers do
        local unit = prefix .. i
        if UnitExists(unit) then
            callback(unit, i)
        end
    end
    
    -- In party, player is not "partyN"
    if not inRaid then
        callback("player", 0)
    end
end

-- Usage
IterateGroup(function(unit, index)
    print(index, UnitName(unit), UnitGroupRolesAssigned(unit))
end)
```

---

## Pet State

| Function | Returns | Description |
|----------|---------|-------------|
| `UnitIsOwnerOrControllerOfUnit(owner, pet)` | `bool` | Ownership check |
| `HasPetUI()` | `bool` | Pet bar should be shown |
| `PetHasActionBar()` | `bool` | Pet has abilities |
| `GetPetExperience()` | `cur, max` | Pet XP |

---

## Miscellaneous

| Function | Returns | Description |
|----------|---------|-------------|
| `CheckInteractDistance(unit, distIndex)` | `bool` | Interaction distance check (`#nocombat`) |
| `UnitPhaseReason(unit)` | `phaseType` | Different phase reason |
| `UnitWidgetSet(unit)` | `widgetSetID` | Widget set for unit |
| `UnitIsInteractable(unit)` | `bool` | Can interact with |
| `UnitCanPetBattle(unit, target)` | `bool` | Can battle |

### CheckInteractDistance Indices

| Index | Distance | Description |
|-------|----------|-------------|
| 1 | 28 yards | Inspect |
| 2 | 11.11 yards | Trade |
| 3 | 9.9 yards | Duel |
| 4 | 28 yards | Follow |

**Note:** Blocked in combat. Not usable as a general range check.

---

## Related Events

| Event | Payload | Description |
|-------|---------|-------------|
| `UNIT_FLAGS` | `unitTarget` | PvP/AFK/combat flags changed |
| `UNIT_FACTION` | `unitTarget` | Faction changed |
| `UNIT_CONNECTION` | `unitTarget, isConnected` | Online/offline |
| `UNIT_PHASE` | `unitTarget` | Phase changed |
| `PLAYER_FLAGS_CHANGED` | `unitTarget` | Player flags changed |
| `PLAYER_TARGET_CHANGED` | — | Target changed |
| `PLAYER_FOCUS_CHANGED` | — | Focus changed |
| `UPDATE_MOUSEOVER_UNIT` | — | Mouseover changed |
| `NAME_PLATE_UNIT_ADDED` | `unitToken` | Nameplate appeared |
| `NAME_PLATE_UNIT_REMOVED` | `unitToken` | Nameplate removed |
| `UNIT_SPELLCAST_START` | `unitTarget, castGUID, spellID` | Cast started |
| `UNIT_SPELLCAST_STOP` | `unitTarget, castGUID, spellID` | Cast stopped |
| `UNIT_SPELLCAST_SUCCEEDED` | `unitTarget, castGUID, spellID` | Cast succeeded |
| `UNIT_SPELLCAST_FAILED` | `unitTarget, castGUID, spellID` | Cast failed |
| `UNIT_SPELLCAST_INTERRUPTED` | `unitTarget, castGUID, spellID` | Cast interrupted |
| `UNIT_SPELLCAST_CHANNEL_START` | `unitTarget, castGUID, spellID` | Channel started |
| `UNIT_SPELLCAST_CHANNEL_STOP` | `unitTarget, castGUID, spellID` | Channel stopped |
| `UNIT_SPELLCAST_CHANNEL_UPDATE` | `unitTarget, castGUID, spellID` | Channel updated |
| `UNIT_SPELLCAST_EMPOWER_START` | `unitTarget, castGUID, spellID` | Empower started |
| `UNIT_SPELLCAST_EMPOWER_STOP` | `unitTarget, castGUID, spellID, complete` | Empower stopped |
| `UNIT_SPELLCAST_EMPOWER_UPDATE` | `unitTarget, castGUID, spellID` | Empower updated |
| `UNIT_ENTERED_VEHICLE` | `unitTarget` | Entered vehicle |
| `UNIT_EXITED_VEHICLE` | `unitTarget` | Exited vehicle |
| `PLAYER_REGEN_ENABLED` | — | Left combat |
| `PLAYER_REGEN_DISABLED` | — | Entered combat |
| `GROUP_ROSTER_UPDATE` | — | Group changed |

> **Source:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#Unit
