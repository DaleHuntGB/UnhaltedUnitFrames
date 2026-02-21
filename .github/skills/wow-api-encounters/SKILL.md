---
name: wow-api-encounters
description: "Complete reference for WoW Retail Encounter Journal, Mythic+/Challenge Mode, Instance, Scenario, Raid Lock, and Season APIs. Covers EncounterJournal (dungeon/raid boss database, loot tables, section navigation), C_ChallengeMode (M+ keystones, affixes, timers, best times), C_MythicPlus (weekly runs, seasonal data, rating), ScenarioInfo (delves/scenarios objectives and stages), InstanceLeaverInfo (deserter), RaidLocks (saved instances), C_SeasonInfo (seasonal info), and related events. Use when working with dungeon/raid encounter data, M+ keystones, mythic plus scores, scenario stages, raid lockouts, or seasonal content."
---

# Encounters API (Retail — Patch 12.0.0)

Comprehensive reference for encounter journal, mythic+, instances, scenarios, raid locks, and seasons.

> **Source:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API
> **Current as of:** Patch 12.0.0 (Build 65655) — January 28, 2026
> **Scope:** Retail only.

---

## Scope

- **Encounter Journal** — Boss database, loot tables, abilities
- **C_ChallengeMode** — M+ keystones, affixes, timers
- **C_MythicPlus** — Weekly M+ runs, rating, seasonal
- **ScenarioInfo** — Scenarios, delves, stages
- **InstanceLeaverInfo** — Deserter/leaver info
- **Raid Locks** — Saved instance lockouts
- **C_SeasonInfo** — Seasonal content

---

## Encounter Journal

### Instance Navigation

| Function | Returns | Description |
|----------|---------|-------------|
| `EJ_GetNumTiers()` | `numTiers` | Number of expansion tiers |
| `EJ_GetTierInfo(tierIndex)` | `name, link` | Tier name and link |
| `EJ_SelectTier(tierIndex)` | — | Select expansion tier |
| `EJ_GetCurrentTier()` | `tierIndex` | Current selected tier |
| `EJ_GetInstanceByIndex(index, isRaid)` | `instanceID, name, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID, link, shouldDisplayDifficulty` | Instance at index |
| `EJ_GetNumInstances()` | — | Not a function; iterate `EJ_GetInstanceByIndex` until nil |
| `EJ_SelectInstance(instanceID)` | — | Select instance |
| `EJ_GetInstanceInfo(instanceID)` | `name, description, bgImage, ...` | Instance info |
| `EJ_InstanceIsRaid()` | `isRaid` | Selected is raid? |

### Encounter (Boss) Data

| Function | Returns | Description |
|----------|---------|-------------|
| `EJ_GetEncounterInfoByIndex(index)` | `name, description, journalEncounterID, rootSectionID, link, journalInstanceID, dungeonEncounterID, instanceID` | Boss at index |
| `EJ_GetEncounterInfo(encounterID)` | `name, description, journalEncounterID, rootSectionID, link, journalInstanceID, dungeonEncounterID, instanceID` | Boss info |
| `EJ_SelectEncounter(encounterID)` | — | Select encounter |
| `EJ_GetNumEncountersForLootByIndex(index)` | `numEncounters` | Bosses with loot |
| `EJ_GetCreatureInfo(index, encounterID)` | `id, name, description, displayInfo, iconImage, ...` | Creature info |

### Section (Ability) Data

| Function | Returns | Description |
|----------|---------|-------------|
| `EJ_GetSectionInfo(sectionID)` | `info` | Section/ability info |
| `EJ_GetNumSectionsForEncounter(encounterID)` | `numSections` | Number of sections |

### Section Info Fields

- `title` — Section title
- `description` — Section text
- `headerType` — Header type enum
- `abilityIcon` — Icon texture
- `creatureDisplayID` — Display ID
- `siblingSectionID` — Next sibling
- `firstChildSectionID` — First child
- `filteredByDifficulty` — Hidden by difficulty filter?
- `link` — Journal link
- `startsOpen` — Default expanded?

### Loot

| Function | Returns | Description |
|----------|---------|-------------|
| `EJ_GetLootInfoByIndex(index)` | `name, icon, slotFilter, armorType, itemID, link, encounterID` | Loot at index |
| `EJ_GetNumLoot()` | `numLoot` | Number of loot items |
| `EJ_SetLootFilter(classID, specID)` | — | Filter by class/spec |
| `EJ_GetLootFilter()` | `classID, specID` | Current filter |
| `EJ_SetSlotFilter(slotFilter)` | — | Filter by slot |
| `EJ_GetSlotFilter()` | `slotFilter` | Current slot filter |
| `EJ_ResetLootFilter()` | — | Clear all filters |
| `EJ_IsLootListOutOfDate()` | `isOutOfDate` | Needs refresh? |

### Difficulty

| Function | Returns | Description |
|----------|---------|-------------|
| `EJ_SetDifficulty(difficultyID)` | — | Set EJ difficulty |
| `EJ_GetDifficulty()` | `difficultyID` | Current EJ difficulty |
| `EJ_GetNumEncountersByDifficulty(difficultyID)` | `numEncounters` | Bosses at difficulty |

### Search

| Function | Returns | Description |
|----------|---------|-------------|
| `EJ_SetSearch(text)` | — | Set search text |
| `EJ_GetSearchResult(index)` | `resultInfo` | Search result |
| `EJ_GetNumSearchResults()` | `numResults` | Num results |
| `EJ_IsSearchFinished()` | `isFinished` | Search done? |
| `EJ_ClearSearch()` | — | Clear search |

---

## C_ChallengeMode — Mythic+ Keystones

### Keystone Info

| Function | Returns | Description |
|----------|---------|-------------|
| `C_ChallengeMode.GetActiveKeystoneInfo()` | `activeKeystoneLevel, activeAffixIDs, wasActiveKeystoneCharged` | Active keystone |
| `C_ChallengeMode.GetActiveChallengeMapID()` | `mapID` | Active M+ map |
| `C_ChallengeMode.GetActiveKeystoneLink()` | `link` | Keystone hyperlink |
| `C_ChallengeMode.GetSlottedKeystoneInfo()` | `mapID, affixIDs, keystoneLevel` | Slotted keystone |
| `C_ChallengeMode.HasSlottedKeystone()` | `hasKeystone` | Keystone slotted? |
| `C_ChallengeMode.SlotKeystone()` | `slotted` | Slot keystone |
| `C_ChallengeMode.RemoveKeystone()` | `removed` | Remove keystone |

### Map & Affix Data

| Function | Returns | Description |
|----------|---------|-------------|
| `C_ChallengeMode.GetMapTable()` | `mapIDs` | All M+ maps |
| `C_ChallengeMode.GetMapUIInfo(mapID)` | `name, id, timeLimit, texture, backgroundTexture` | Map info |
| `C_ChallengeMode.GetAffixInfo(affixID)` | `name, description, filedataid` | Affix info |
| `C_ChallengeMode.GetCurrentAffixes()` | `affixes` | This week's affixes |

### Completion & Records

| Function | Returns | Description |
|----------|---------|-------------|
| `C_ChallengeMode.GetMapPlayerStats(mapID)` | `durationSec, ...` | Personal best |
| `C_ChallengeMode.GetGuildLeaders()` | `guildLeaders` | Guild best runs |
| `C_ChallengeMode.GetCompletionInfo()` | `mapID, level, time, onTime, keystoneUpgradeLevels, practiceRun, oldOverallDungeonScore, newOverallDungeonScore, IsMapRecord, IsAffixRecord, PrimaryAffix, isEligibleForScore, members` | Run completion data |
| `C_ChallengeMode.IsChallengeModeActive()` | `isActive` | In active M+? |
| `C_ChallengeMode.GetDeathCount()` | `numDeaths, timeLost` | Deaths and penalty |
| `C_ChallengeMode.GetActiveChallengeModeLevel()` | `level` | Current key level |

### Rewards

| Function | Returns | Description |
|----------|---------|-------------|
| `C_ChallengeMode.GetChallengeMapInfo(mapID, keystoneLevel)` | `rewardInfo` | Rewards for key level |

---

## C_MythicPlus — Seasonal M+ Data

| Function | Returns | Description |
|----------|---------|-------------|
| `C_MythicPlus.GetCurrentSeason()` | `seasonID` | Current season |
| `C_MythicPlus.GetRunHistory(includePreviousWeeks, includeIncompleteRuns)` | `runs` | Run history |
| `C_MythicPlus.GetRewardLevelFromKeystoneLevel(keystoneLevel)` | `rewardLevel` | Reward item level |
| `C_MythicPlus.GetOwnedKeystoneLevel()` | `level` | Owned key level |
| `C_MythicPlus.GetOwnedKeystoneChallengeMapID()` | `mapID` | Owned key dungeon |
| `C_MythicPlus.GetOwnedKeystoneMapID()` | `mapID` | Owned key map |
| `C_MythicPlus.GetCurrentAffixes()` | `affixIDs` | Current affixes |
| `C_MythicPlus.GetWeeklyChestRewardLevel()` | `rewardLevel` | Vault reward level |
| `C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(mapID)` | `bestScoreInfo` | Best scores by affix |
| `C_MythicPlus.GetSeasonBestForMap(mapID)` | `intimeInfo, overtimeInfo` | Season best runs |
| `C_MythicPlus.GetOverallDungeonScore()` | `score` | Overall M+ rating |
| `C_MythicPlus.RequestCurrentAffixes()` | — | Request affix data |
| `C_MythicPlus.RequestMapInfo()` | — | Request map data |
| `C_MythicPlus.RequestRewards()` | — | Request reward data |
| `C_MythicPlus.IsDungeonScorable(mapID)` | `isScorable` | Awards score? |

---

## ScenarioInfo — Scenarios & Delves

| Function | Returns | Description |
|----------|---------|-------------|
| `C_ScenarioInfo.GetScenarioInfo()` | `scenarioInfo` | Current scenario |
| `C_ScenarioInfo.GetScenarioStepInfo()` | `stepInfo` | Current step |
| `C_ScenarioInfo.GetCriteriaInfo(criteriaIndex)` | `criteriaInfo` | Criteria at index |
| `C_ScenarioInfo.GetCriteriaInfoByStep(stepIndex, criteriaIndex)` | `criteriaInfo` | Step criteria |
| `C_ScenarioInfo.GetScenarioStepByIndex(index)` | `stepInfo` | Step at index |

### Scenario Info Fields

- `name` — Scenario name
- `currentStage` — Current stage
- `numStages` — Total stages
- `flags` — Scenario flags
- `isComplete` — Completed?
- `xp` — XP reward
- `money` — Gold reward
- `type` — Scenario type
- `area` — Area name
- `uiTextureKit` — UI texture kit

### Step Info Fields

- `title` — Step title
- `description` — Step description
- `numCriteria` — Criteria count
- `isComplete` — Step complete?
- `isBonusObjective` — Bonus objective?
- `isFinal` — Final step?
- `weightedProgress` — Progress percentage

---

## Raid Locks (Saved Instances)

| Function | Returns | Description |
|----------|---------|-------------|
| `GetNumSavedInstances()` | `numInstances` | Saved instance count |
| `GetSavedInstanceInfo(index)` | `name, id, reset, difficulty, locked, extended, instanceIDMostSig, isRaid, maxPlayers, difficultyName, numEncounters, encounterProgress, extendDisabled` | Saved instance info |
| `GetSavedInstanceEncounterInfo(index, encounterIndex)` | `bossName, fileDataID, isKilled, isIneligible` | Boss kill status |
| `SetSavedInstanceExtend(index, extend)` | — | Extend lockout |
| `GetNumSavedWorldBosses()` | `count` | World boss locks |
| `GetSavedWorldBossInfo(index)` | `name, id, reset` | World boss info |
| `RequestRaidInfo()` | — | Request lock data |

---

## InstanceLeaverInfo — Deserter

| Function | Returns | Description |
|----------|---------|-------------|
| `C_InstanceLeaverInfo.GetLeaverInfo()` | `leaverInfo` | Leaver/deserter info |
| `C_InstanceLeaverInfo.HasLeaverPenalty()` | `hasPenalty` | Has deserter? |
| `C_InstanceLeaverInfo.GetLeaverPenaltyTimeRemaining()` | `seconds` | Time remaining |

---

## C_SeasonInfo — Seasonal Content

| Function | Returns | Description |
|----------|---------|-------------|
| `C_SeasonInfo.GetCurrentDisplaySeasonID()` | `seasonID` | Current display season |
| `C_SeasonInfo.GetCurrentSeason()` | `seasonID` | Current season |
| `C_SeasonInfo.GetSeasonInfo(seasonID)` | `seasonInfo` | Season data |

---

## Common Patterns

### List Encounter Journal Bosses

```lua
-- Select an instance and list its bosses
EJ_SelectTier(EJ_GetCurrentTier())
EJ_SelectInstance(instanceID)

local index = 1
while true do
    local name, description, encounterID, rootSectionID = EJ_GetEncounterInfoByIndex(index)
    if not name then break end
    print(index, name, "- EncounterID:", encounterID)
    index = index + 1
end
```

### Show M+ Keystone Info

```lua
local function ShowKeystoneInfo()
    local level = C_MythicPlus.GetOwnedKeystoneLevel()
    local mapID = C_MythicPlus.GetOwnedKeystoneChallengeMapID()
    if level and mapID then
        local name = C_ChallengeMode.GetMapUIInfo(mapID)
        print("Keystone:", name, "+", level)
    else
        print("No keystone")
    end
    
    local score = C_MythicPlus.GetOverallDungeonScore()
    print("M+ Rating:", score or 0)
end
```

### Check Active M+ Progress

```lua
local function ShowMythicPlusProgress()
    if not C_ChallengeMode.IsChallengeModeActive() then
        print("Not in an active M+")
        return
    end
    
    local level = C_ChallengeMode.GetActiveChallengeModeLevel()
    local mapID = C_ChallengeMode.GetActiveChallengeMapID()
    local name = C_ChallengeMode.GetMapUIInfo(mapID)
    local deaths, timeLost = C_ChallengeMode.GetDeathCount()
    
    print(name, "+", level)
    print("Deaths:", deaths, "Time lost:", timeLost, "sec")
end
```

### List Saved Instances

```lua
RequestRaidInfo()
-- Wait for UPDATE_INSTANCE_INFO event, then:
local numSaved = GetNumSavedInstances()
for i = 1, numSaved do
    local name, id, reset, difficulty, locked, extended, 
          _, isRaid, maxPlayers, diffName, numEncounters, progress = 
          GetSavedInstanceInfo(i)
    if locked then
        print(name, diffName, progress .. "/" .. numEncounters, 
              "Reset:", SecondsToTime(reset))
    end
end
```

---

## Key Events

| Event | Payload | Description |
|-------|---------|-------------|
| `EJ_LOOT_DATA_RECIEVED` | itemID | Loot data loaded |
| `EJ_DIFFICULTY_UPDATE` | difficultyID | EJ difficulty changed |
| `CHALLENGE_MODE_START` | mapID | M+ started |
| `CHALLENGE_MODE_COMPLETED` | mapID | M+ completed |
| `CHALLENGE_MODE_RESET` | mapID | M+ reset |
| `CHALLENGE_MODE_DEATH_COUNT_UPDATED` | — | Death count changed |
| `CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN` | — | Font of Power opened |
| `CHALLENGE_MODE_KEYSTONE_SLOTTED` | — | Keystone slotted |
| `MYTHIC_PLUS_CURRENT_AFFIX_UPDATE` | — | Affixes updated |
| `MYTHIC_PLUS_NEW_WEEKLY_RECORD` | mapID | New weekly best |
| `MYTHIC_PLUS_NEW_SEASON_RECORD` | mapID | New season best |
| `SCENARIO_UPDATE` | — | Scenario state changed |
| `SCENARIO_CRITERIA_UPDATE` | — | Criteria updated |
| `SCENARIO_COMPLETED` | — | Scenario completed |
| `UPDATE_INSTANCE_INFO` | — | Saved instance data |
| `INSTANCE_LOCK_START` | — | Lockout acquired |
| `INSTANCE_LOCK_STOP` | — | Lockout released |
| `INSTANCE_LOCK_WARNING` | — | Lockout warning |

---

## Gotchas & Restrictions

1. **EJ data is async** — Loot data loads asynchronously. Wait for `EJ_LOOT_DATA_RECIEVED` before reading loot.
2. **Tier selection matters** — EJ functions operate on the currently selected tier. Always set tier first.
3. **M+ completion data is temporary** — `GetCompletionInfo()` only returns data immediately after a run.
4. **Keystone slotting requires hardware event** — Players must manually interact with the Font of Power.
5. **Raid lock extensions** — `SetSavedInstanceExtend()` must be called during the lock's active period.
6. **Scenario types vary** — Delves, island expeditions, and scenarios all use ScenarioInfo with different type flags.
7. **M+ rating is per-season** — `GetOverallDungeonScore()` resets each season.
8. **RequestRaidInfo() is async** — Wait for `UPDATE_INSTANCE_INFO` before reading saved instances.
