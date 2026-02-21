---
name: wow-api-pvp
description: "Complete reference for WoW Retail PvP, Battlegrounds, Arenas, Rated PvP, War Mode, Duels, War Games, and Honor/Conquest APIs. Covers C_PvP (PvP info, rated stats, rewards, battlegrounds, arenas, war mode, brawls, special events), duel functions (AcceptDuel, CancelDuel, StartDuel), war game functions, honor/conquest tracking, PvP talent integration, and PvP-related events. Use when working with PvP systems, battlegrounds, arenas, rated PvP, war mode, honor, conquest, duels, or PvP UI."
---

# PvP API (Retail — Patch 12.0.0)

Comprehensive reference for PvP, battlegrounds, arenas, rated PvP, war mode, and duels.

> **Source:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API
> **Current as of:** Patch 12.0.0 (Build 65655) — January 28, 2026
> **Scope:** Retail only.

---

## Scope

- **C_PvP** — PvP info, rated stats, rewards, queuing
- **Battlegrounds** — BG state, score, flags
- **Arenas** — Arena info, teams, ratings
- **War Mode** — War mode toggle, bonuses
- **Duels** — Accept, cancel, start
- **Honor/Conquest** — Currency tracking

---

## C_PvP — Core PvP System

### PvP State & Info

| Function | Returns | Description |
|----------|---------|-------------|
| `C_PvP.IsPVPMap()` | `isPVP` | In a PvP map? |
| `C_PvP.IsInPVPBattleground()` | `inBG` | In a battleground? (deprecated name for `IsInBattleground`) |
| `C_PvP.IsInBattleground()` | `inBG` | In a battleground? |
| `C_PvP.IsBattleground()` | `isBG` | Current zone is BG? |
| `C_PvP.IsArena()` | `isArena` | In an arena? |
| `C_PvP.IsSoloShuffle()` | `isSoloShuffle` | In solo shuffle? |
| `C_PvP.IsBlitz()` | `isBlitz` | In blitz BG? |
| `C_PvP.IsRatedBattleground()` | `isRated` | In rated BG? |
| `C_PvP.IsRatedArena()` | `isRated` | In rated arena? |
| `C_PvP.IsRatedMap()` | `isRated` | In any rated match? |
| `C_PvP.IsWarModeDesired()` | `isDesired` | War mode toggled on? |
| `C_PvP.IsWarModeActive()` | `isActive` | War mode currently active? |
| `C_PvP.IsWarModeFeatureEnabled()` | `isEnabled` | War mode feature available? |
| `C_PvP.CanToggleWarMode(toggle)` | `canToggle` | Can toggle war mode? |
| `C_PvP.ToggleWarMode()` | — | Toggle war mode |
| `C_PvP.GetWarModeRewardBonus()` | `bonusPercent` | War mode XP/resource bonus % |
| `C_PvP.IsPvPTalentsUnlocked()` | `isUnlocked` | PvP talents available? |
| `C_PvP.GetPVPActiveMatchDuration()` | `duration` | Active match duration |
| `C_PvP.GetPVPActiveMatchState()` | `state` | Match state |

### Rated PvP

| Function | Returns | Description |
|----------|---------|-------------|
| `C_PvP.GetRatedBGRewards()` | `rewardInfo` | Rated BG rewards |
| `C_PvP.GetArenaRewards(teamSize)` | `rewardInfo` | Arena rewards |
| `C_PvP.GetSeasonBestInfo()` | `tierID, nextTierID` | Season best tier |
| `C_PvP.GetCurrentSeasonNumber()` | `season` | Current PvP season |
| `C_PvP.GetRankInfo(hk, guid)` | `rankName, rankNumber` | PvP rank info |
| `C_PvP.GetGlobalPvpScalingInfoForSpecID(specID)` | `info` | PvP scaling |
| `C_PvP.GetLevelUpBattlegrounds()` | `bgIDs` | Available BGs for level |
| `C_PvP.GetRandomBGInfo()` | `info` | Random BG info |
| `C_PvP.GetRandomBGRewards()` | `rewardInfo` | Random BG rewards |
| `C_PvP.GetRandomEpicBGInfo()` | `info` | Random epic BG info |
| `C_PvP.GetSkirmishInfo(bracketIndex)` | `info` | Skirmish info |
| `C_PvP.GetPvpTierInfo(tierID)` | `tierInfo` | PvP tier details |
| `C_PvP.GetPvpTierID(bracketIndex, guid)` | `tierID` | Player's tier in bracket |

### Honor & Conquest

| Function | Returns | Description |
|----------|---------|-------------|
| `C_PvP.GetHonorRewardInfo(honorLevel)` | `rewardInfo` | Honor level reward |
| `GetHonorLevel()` | `level` | Current honor level |
| `UnitHonorLevel(unit)` | `level` | Unit's honor level |
| `GetMaxPlayerHonorLevel()` | `maxLevel` | Max honor level |
| `GetPVPLifetimeStats()` | `hk, dk, highestRank` | Lifetime PvP stats |
| `GetPVPSessionStats()` | `hk, dk` | Session PvP stats |
| `GetPVPYesterdayStats()` | `hk, dk, honor` | Yesterday's stats |

### Battleground Score

| Function | Returns | Description |
|----------|---------|-------------|
| `GetNumBattlefieldScores()` | `numScores` | Score entries |
| `GetBattlefieldScore(index)` | `name, killingBlows, honorKills, deaths, honorGained, faction, race, class, classToken, damageDone, healingDone, bgRating, ratingChange, preMatchMMR, mmrChange, talentSpec` | Score info |
| `GetBattlefieldStatData(index, statIndex)` | `value` | BG-specific stat |
| `GetNumBattlefieldStats()` | `numStats` | BG stat columns |
| `GetBattlefieldStatInfo(statIndex)` | `name, icon, tooltip` | Stat column info |

### Battleground/Arena Queue

| Function | Returns | Description |
|----------|---------|-------------|
| `C_PvP.RequestCrowdControlSpell(unitToken)` | — | Request CC info |
| `JoinBattlefield(index [, asGroup [, isRated]])` | — | Join BG queue |
| `LeaveBattlefield()` | — | Leave BG |
| `AcceptBattlefieldPort(index, acceptFlag)` | — | Accept/decline BG port |
| `GetBattlefieldPortExpiration(index)` | `expiration` | Port expiration time |
| `GetBattlefieldStatus(index)` | `status, mapName, teamSize, registeredMatch, suspendedQueue, queueType, gameID, role, asGroup, shortDescription, longDescription` | Queue status |
| `GetMaxBattlefieldID()` | `maxID` | Max battlefield ID |
| `GetBattlefieldInstanceRunTime()` | `runTime` | Instance elapsed ms |
| `GetBattlefieldTimeWaited(index)` | `timeWaited` | Time in queue |
| `GetBattlefieldEstimatedWaitTime(index)` | `waitTime` | Estimated wait |
| `GetBattlefieldWinner()` | `winner` | Winning faction |

---

## Duel Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `AcceptDuel()` | — | Accept duel request |
| `CancelDuel()` | — | Decline/cancel duel |
| `StartDuel(unit)` | — | Request duel |

---

## War Game Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `C_PvP.StartWarGame(targetName, warGameType, ...)` | — | Start war game |
| `C_PvP.IsWarGameByMasterAllowed()` | `allowed` | Can start war games? |

---

## Common Patterns

### Check PvP Context

```lua
local function GetPvPContext()
    if C_PvP.IsArena() then return "arena"
    elseif C_PvP.IsInBattleground() then return "battleground"
    elseif C_PvP.IsWarModeActive() then return "warmode"
    else return "pve" end
end
```

### Display Rated PvP Info

```lua
local function PrintRatedInfo()
    local season = C_PvP.GetCurrentSeasonNumber()
    print("PvP Season:", season)
    
    -- Check bracket ratings
    for bracketIndex = 1, 4 do
        local tierID = C_PvP.GetPvpTierID(bracketIndex, UnitGUID("player"))
        if tierID then
            local tierInfo = C_PvP.GetPvpTierInfo(tierID)
            if tierInfo then
                print("Bracket", bracketIndex, ":", tierInfo.pvpTierEnum, tierInfo.tierName)
            end
        end
    end
end
```

---

## Key Events

| Event | Payload | Description |
|-------|---------|-------------|
| `PVP_MATCH_ACTIVE` | — | PvP match started |
| `PVP_MATCH_COMPLETE` | winner | Match ended |
| `PVP_MATCH_INACTIVE` | — | Match inactive |
| `UPDATE_BATTLEFIELD_STATUS` | battlefieldIndex | Queue status changed |
| `UPDATE_BATTLEFIELD_SCORE` | — | Scoreboard updated |
| `BATTLEFIELD_QUEUE_TIMEOUT` | — | Queue timed out |
| `WARGAME_REQUESTED` | opposingPartyMemberName, bgName, timeout, tournamentRules | War game request |
| `DUEL_REQUESTED` | playerName | Duel request received |
| `DUEL_FINISHED` | — | Duel ended |
| `DUEL_INBOUNDS` | — | Player in duel bounds |
| `DUEL_OUTOFBOUNDS` | — | Player out of bounds |
| `HONOR_LEVEL_UPDATE` | isHigherLevel | Honor level changed |
| `PVP_RATED_STATS_UPDATE` | — | Rated stats updated |
| `PVP_REWARDS_UPDATE` | — | PvP rewards updated |
| `WAR_MODE_STATUS_UPDATE` | isWarModeDesired | War mode toggled |
| `PLAYER_FLAGS_CHANGED` | unitTarget | PvP flag changed |
| `PVP_TIMER_UPDATE` | — | PvP timer updated |
| `PVP_VEHICLE_INFO_UPDATED` | — | PvP vehicle info changed |
| `PVP_WORLDSTATE_UPDATE` | — | World state updated |
| `ARENA_OPPONENT_UPDATE` | unitToken, updateReason | Arena opponent updated |
| `ARENA_PREP_OPPONENT_SPECIALIZATIONS` | — | Arena opponent specs |
| `ARENA_SEASON_WORLD_STATE` | — | Arena season state |

---

## Gotchas & Restrictions

1. **War mode toggle location** — Can only toggle war mode in Stormwind/Orgrimmar (capital cities), not anywhere.
2. **BG score indices** — `GetBattlefieldScore()` indices are 1-based and may not match player order.
3. **Queue index** — `GetBattlefieldStatus()` uses queue index (1-based), not battlefield ID.
4. **PvP talents** — PvP talents are managed through `C_SpecializationInfo`, not `C_PvP`. See the talents skill.
5. **AcceptBattlefieldPort hardware event** — Requires a hardware event to accept.
6. **12.0.0 instance restrictions** — In BGs and arenas, enemy player info (name, class, health) may be secret values.
7. **Honor is a currency** — Honor and conquest are currencies. Use `C_CurrencyInfo` for tracking amounts.
8. **Season resets** — Rated PvP data resets each season. `GetCurrentSeasonNumber()` tracks the season.
