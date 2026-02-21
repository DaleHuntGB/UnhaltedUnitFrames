# Player-Specific Functions Reference

> **Source:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#PlayerScript
> **Patch:** 12.0.0 (Retail)

## Experience & Leveling

| Function | Returns | Description |
|----------|---------|-------------|
| `UnitXP("player")` | `xp` | Current XP |
| `UnitXPMax("player")` | `maxXP` | XP for next level |
| `GetMaxPlayerLevel()` | `level` | Current expansion level cap |
| `GetRestState()` | `exhaustionID, name, factor` | Rested state info |
| `GetXPExhaustion()` | `exhaustion` | Rested XP remaining |
| `IsXPUserDisabled()` | `bool` | XP gains frozen |
| `IsLevelAtEffectiveMaxLevel()` | `bool` | At effective max level |

### XP Bar Pattern

```lua
local function UpdateXPBar(bar)
    local xp = UnitXP("player")
    local maxXP = UnitXPMax("player")
    bar:SetMinMaxValues(0, maxXP)
    bar:SetValue(xp)
    
    local rested = GetXPExhaustion() or 0
    local pct = (xp / maxXP) * 100
    print(string.format("%.1f%% — %d/%d (Rested: %d)", pct, xp, maxXP, rested))
end
```

### Rest State Values

| exhaustionID | name | factor | Meaning |
|-------------|------|--------|---------|
| 1 | "Rested" | 2.0 | Double XP from kills |
| 2 | "Normal" | 1.0 | Normal XP |

---

## Money

### GetMoney() → copper

Returns total money in copper (1g = 10000c, 1s = 100c).

```lua
local copper = GetMoney()
local gold = math.floor(copper / 10000)
local silver = math.floor((copper % 10000) / 100)
local copperRem = copper % 100
print(string.format("%dg %ds %dc", gold, silver, copperRem))
```

### Money Display Pattern

```lua
-- Use the built-in formatter
local text = GetCoinTextureString(GetMoney())
-- Returns formatted string with gold/silver/copper icons
```

---

## PvP Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `UnitIsPVP(unit)` | `bool` | PvP flagged |
| `UnitIsPVPFreeForAll(unit)` | `bool` | In FFA PvP zone |
| `GetPVPTimer()` | `ms` | Time remaining on PvP flag (ms) |
| `IsPVPTimerRunning()` | `bool` | PvP timer counting down |
| `GetPVPDesired()` | `bool` | Voluntarily PvP flagged |
| `SetPVP([enable])` | — | Toggle PvP flag |
| `TogglePVP()` | — | Toggle PvP flag |
| `IsInActiveWorldPVP()` | `bool` | In active world PvP zone |
| `IsWargame()` | `bool` | In a war game |
| `GetMaxBattlefieldID()` | `count` | Number of PvP queue slots |
| `GetBattlefieldStatus(index)` | `status, mapName, teamSize, registeredMatch, suspendedQueue, queueType, gameType, role, asGroup` | Queue status |
| `UnitPVPRank(unit)` | `rank` | Honor rank (legacy, returns 0) |

### Honor & Conquest

| Function | Returns | Description |
|----------|---------|-------------|
| `UnitHonor("player")` | `honor` | Current honor |
| `UnitHonorMax("player")` | `maxHonor` | Honor to next level |
| `UnitHonorLevel("player")` | `level` | Honor level |
| `GetPrestigeLevel("player")` | `prestige` | Prestige level (legacy) |

---

## Death & Resurrection

### Death Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `UnitIsDead(unit)` | `bool` | Unit is dead (includes feign death!) |
| `UnitIsDeadOrGhost(unit)` | `bool` | Dead or ghost form |
| `UnitIsGhost(unit)` | `bool` | In ghost form (released spirit) |
| `RepopMe()` | — | Release spirit (become ghost) |
| `RetrieveCorpse()` | — | Resurrect at corpse |
| `HasSoulstone()` | `text` | Soulstone/Ankh available |

### Resurrection Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `AcceptResurrect()` | — | Accept a resurrection offer |
| `DeclineResurrect()` | — | Decline a resurrection offer |
| `ResurrectGetOfferer()` | `name` | Who is offering resurrection |
| `ResurrectHasSickness()` | `bool` | Will get resurrection sickness |
| `ResurrectHasTimer()` | `bool` | Must wait before accepting |
| `GetCorpseRecoveryDelay()` | `seconds` | Delay before corpse resurrection |
| `GetReleaseTimeRemaining()` | `seconds` | Time until forced spirit release |
| `UnitHasIncomingResurrection(unit)` | `bool` | Being resurrected |

### Resurrection Event Pattern

```lua
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_DEAD")
frame:RegisterEvent("PLAYER_ALIVE")
frame:RegisterEvent("PLAYER_UNGHOST")
frame:RegisterEvent("RESURRECT_REQUEST")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_DEAD" then
        print("You died!")
        if HasSoulstone() then
            print("You can use:", HasSoulstone())
        end
    elseif event == "RESURRECT_REQUEST" then
        local offerer = ResurrectGetOfferer()
        print(offerer, "wants to resurrect you")
        if ResurrectHasSickness() then
            print("Warning: You will get resurrection sickness!")
        end
    elseif event == "PLAYER_ALIVE" then
        print("You accepted a res")
    elseif event == "PLAYER_UNGHOST" then
        print("No longer a ghost")
    end
end)
```

---

## Incoming Summon (C_IncomingSummon)

| Function | Returns | Description |
|----------|---------|-------------|
| `C_IncomingSummon.HasIncomingSummon(unit)` | `bool` | Has pending summon |
| `C_IncomingSummon.IncomingSummonStatus(unit)` | `status` | Summon status enum |

### Summon Status Values

| Status | Meaning |
|--------|---------|
| `Enum.SummonStatus.None` | No summon |
| `Enum.SummonStatus.Pending` | Summon offered, waiting for acceptance |
| `Enum.SummonStatus.Accepted` | Summon accepted |
| `Enum.SummonStatus.Declined` | Summon declined |

```lua
-- Check if a group member has a pending summon
if C_IncomingSummon.HasIncomingSummon("party1") then
    local status = C_IncomingSummon.IncomingSummonStatus("party1")
    if status == Enum.SummonStatus.Pending then
        print(UnitName("party1"), "has a pending summon")
    end
end
```

---

## Movement & Position

### GetUnitSpeed(unit) → currentSpeed, runSpeed, flightSpeed, swimSpeed

```lua
local current, run, flight, swim = GetUnitSpeed("player")
-- Base run speed is 7.0 yards/second
local percentOfBase = (current / 7.0) * 100
```

### GetPlayerFacing() → radians `#noinstance`

Returns facing direction in radians (0 = north, π/2 = west, π = south, 3π/2 = east).

### UnitPosition(unit) → x, y, z, mapID `#noinstance`

Returns world coordinates. Not available in instances.

```lua
-- OPEN WORLD ONLY
local px, py, _, _ = UnitPosition("player")
local tx, ty, _, _ = UnitPosition("target")
if px and tx then
    local dist = math.sqrt((px - tx)^2 + (py - ty)^2)
    print("Distance:", dist, "yards")
end
```

### UnitDistanceSquared(unit) → distanceSquared, isValid `#noinstance`

Returns squared distance to a group member. More efficient than `UnitPosition`.

```lua
local distSq, valid = UnitDistanceSquared("party1")
if valid then
    print("Distance:", math.sqrt(distSq), "yards")
end
```

### Movement State Checks

| Function | Returns | Description |
|----------|---------|-------------|
| `IsFalling([unit])` | `bool` | Currently falling |
| `IsFlying([unit])` | `bool` | On a flying mount |
| `IsSwimming([unit])` | `bool` | Swimming |
| `IsMounted()` | `bool` | On any mount |
| `IsIndoors()` | `bool` | Indoors |
| `IsOutdoors()` | `bool` | Outdoors |
| `IsStealthed()` | `bool` | Stealthed |
| `UnitOnTaxi(unit)` | `bool` | On flight path |

---

## Character Stats (Paper Doll)

### C_PaperDollInfo Slot Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `C_PaperDollInfo.GetMinItemLevel()` | `minIlvl` | Minimum item level for current content |
| `C_PaperDollInfo.CanAutoEquipCursorItem()` | `bool` | Can auto-equip cursor item |
| `C_PaperDollInfo.CanCursorCanGoInSlot(slotID)` | `bool` | Cursor item fits in slot |
| `C_PaperDollInfo.IsInventorySlotEnabled(slotName)` | `bool` | Equipment slot is enabled |

### Equipment Slot IDs

| Slot | ID | Constant |
|------|------|----------|
| Head | 1 | `INVSLOT_HEAD` |
| Neck | 2 | `INVSLOT_NECK` |
| Shoulder | 3 | `INVSLOT_SHOULDER` |
| Shirt | 4 | `INVSLOT_BODY` |
| Chest | 5 | `INVSLOT_CHEST` |
| Waist | 6 | `INVSLOT_WAIST` |
| Legs | 7 | `INVSLOT_LEGS` |
| Feet | 8 | `INVSLOT_FEET` |
| Wrist | 9 | `INVSLOT_WRIST` |
| Hands | 10 | `INVSLOT_HAND` |
| Finger 1 | 11 | `INVSLOT_FINGER1` |
| Finger 2 | 12 | `INVSLOT_FINGER2` |
| Trinket 1 | 13 | `INVSLOT_TRINKET1` |
| Trinket 2 | 14 | `INVSLOT_TRINKET2` |
| Back | 15 | `INVSLOT_BACK` |
| Main Hand | 16 | `INVSLOT_MAINHAND` |
| Off Hand | 17 | `INVSLOT_OFFHAND` |
| Ranged/Relic | 18 | `INVSLOT_RANGED` |
| Tabard | 19 | `INVSLOT_TABARD` |

### Get Player Item Level

```lua
local function GetPlayerItemLevel()
    local total = 0
    local count = 0
    for slot = 1, 17 do
        if slot ~= 4 then -- skip shirt
            local itemLink = GetInventoryItemLink("player", slot)
            if itemLink then
                local ilvl = GetDetailedItemLevelInfo(itemLink)
                if ilvl then
                    total = total + ilvl
                    count = count + 1
                end
            end
        end
    end
    return count > 0 and (total / count) or 0
end
```

---

## Specialization

| Function | Returns | Description |
|----------|---------|-------------|
| `GetSpecialization()` | `specIndex` | Current spec index (1-4) |
| `GetSpecializationInfo(specIndex)` | `specID, name, description, icon, role, primaryStat` | Spec details |
| `GetNumSpecializations()` | `numSpecs` | Number of available specs |
| `GetInspectSpecialization("target")` | `specID` | Inspected player's spec ID |

```lua
local specIndex = GetSpecialization()
if specIndex then
    local id, name, desc, icon, role = GetSpecializationInfo(specIndex)
    print("Current spec:", name, "Role:", role)
end
```

---

## Guild

| Function | Returns | Description |
|----------|---------|-------------|
| `UnitIsInMyGuild(unit)` | `bool` | Same guild as player |
| `IsInGuild()` | `bool` | Player is in a guild |
| `GetGuildInfo("player")` | `guildName, guildRankName, guildRankIndex, realm` | Guild info |

---

## Miscellaneous Player Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `GetRealmName()` | `name` | Current realm name |
| `GetNormalizedRealmName()` | `name` | Realm name without spaces |
| `UnitRace("player")` | `race, raceFile, raceID` | Player race |
| `UnitSex("player")` | `sex` | Player gender |
| `GetBindLocation()` | `location` | Hearthstone location name |
| `GetInstanceInfo()` | `name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize, LfgDungeonID` | Current instance info |
| `IsInInstance()` | `inInstance, instanceType` | In an instance |
| `IsInGroup([category])` | `bool` | In a group |
| `IsInRaid([category])` | `bool` | In a raid |
| `GetNumGroupMembers([category])` | `count` | Number of group members |
| `GetNumSubgroupMembers([category])` | `count` | Number of party members |

---

## Related Events

| Event | Payload | Description |
|-------|---------|-------------|
| `PLAYER_DEAD` | — | Player died |
| `PLAYER_ALIVE` | — | Accepted resurrection |
| `PLAYER_UNGHOST` | — | No longer ghost |
| `RESURRECT_REQUEST` | `inviter` | Resurrection offered |
| `PLAYER_XP_UPDATE` | `unitTarget` | XP gained |
| `PLAYER_LEVEL_UP` | `level, ...` | Level gained |
| `PLAYER_MONEY` | — | Money changed |
| `PLAYER_FLAGS_CHANGED` | `unitTarget` | Flags changed |
| `PLAYER_ENTERING_WORLD` | `isInitialLogin, isReloadingUi` | Zone load |
| `PLAYER_LEAVING_WORLD` | — | Leaving zone |
| `PLAYER_REGEN_ENABLED` | — | Left combat |
| `PLAYER_REGEN_DISABLED` | — | Entered combat |
| `ACTIVE_TALENT_GROUP_CHANGED` | `specGroup, isPending` | Spec changed |
| `PLAYER_SPECIALIZATION_CHANGED` | `unitTarget` | Spec changed |
| `UPDATE_EXHAUSTION` | — | Rested state changed |
| `PLAYER_UPDATE_RESTING` | — | Entered/left rest area |
| `PVP_TIMER_UPDATE` | — | PvP timer updated |
| `PLAYER_PVP_KILLS_CHANGED` | — | PvP kills changed |
| `HONOR_XP_UPDATE` | — | Honor updated |
| `INCOMING_SUMMON_CHANGED` | — | Summon status changed |
| `INCOMING_RESURRECT_CHANGED` | `unitTarget` | Res status changed |
| `CORPSE_IN_RANGE` | — | Corpse is nearby |
| `CORPSE_OUT_OF_RANGE` | — | Corpse is far away |
| `AREA_SPIRIT_HEALER_IN_RANGE` | — | Near spirit healer |
| `AREA_SPIRIT_HEALER_OUT_OF_RANGE` | — | Left spirit healer |
| `UNIT_INVENTORY_CHANGED` | `unitTarget` | Equipment changed |

> **Sources:**
> - https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#PlayerScript
> - https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#PaperDollInfo
> - https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#PlayerLocationInfo
> - https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#DeathInfo
> - https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#IncomingSummon
