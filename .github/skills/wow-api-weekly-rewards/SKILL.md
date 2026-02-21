---
name: wow-api-weekly-rewards
description: "Complete reference for WoW Retail Weekly Rewards (Great Vault) API. Covers C_WeeklyRewards — vault activities (M+, raids, PvP, world), reward selection, item preview, canEquip checks, vault UI state, and related events. Use when working with the Great Vault, weekly reward choices, vault activity tracking, or end-of-week item selection."
---

# Weekly Rewards API (Retail — Patch 12.0.0)

Comprehensive reference for the Great Vault / weekly rewards system.

> **Source:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API
> **Current as of:** Patch 12.0.0 (Build 65655) — January 28, 2026
> **Scope:** Retail only.

---

## Scope

- **C_WeeklyRewards** — Great Vault UI, activities, rewards, item selection

---

## C_WeeklyRewards — Great Vault System

### Activity Tracking

| Function | Returns | Description |
|----------|---------|-------------|
| `C_WeeklyRewards.GetActivities(type)` | `activities` | Activities for type |
| `C_WeeklyRewards.HasAvailableRewards()` | `hasRewards` | Rewards available? |
| `C_WeeklyRewards.CanClaimRewards()` | `canClaim` | Can claim now? |
| `C_WeeklyRewards.HasGeneratedRewards()` | `hasGenerated` | Rewards generated? |
| `C_WeeklyRewards.GetNumCompletedDungeonRuns(level)` | `numCompleted` | M+ runs at level+ |

### Activity Types

| Enum | Value | Description |
|------|-------|-------------|
| `Enum.WeeklyRewardChestThresholdType.Activities` | 0 | World activities |
| `Enum.WeeklyRewardChestThresholdType.RankedPvP` | 1 | Rated PvP |
| `Enum.WeeklyRewardChestThresholdType.MythicPlus` | 2 | Mythic+ dungeons |
| `Enum.WeeklyRewardChestThresholdType.Raid` | 3 | Raid bosses |
| `Enum.WeeklyRewardChestThresholdType.World` | 4 | World content |

### Activity Data Fields

Each activity entry contains:
- `type` — Activity type enum
- `index` — Slot index (1, 2, 3)
- `threshold` — Completions needed
- `progress` — Current completions
- `id` — Activity ID
- `level` — Key level / difficulty / rating tier
- `rewards` — Available rewards table
- `rewardOptions` — Reward item options

### Reward Selection

| Function | Returns | Description |
|----------|---------|-------------|
| `C_WeeklyRewards.ClaimReward(id)` | — | Claim specific reward |
| `C_WeeklyRewards.GetItemHyperlink(rewardInfo)` | `hyperlink` | Item link for reward |
| `C_WeeklyRewards.GetExampleRewardItemHyperlinks(id)` | `hyperlinks` | Example rewards |
| `C_WeeklyRewards.AreRewardsForCurrentRewardPeriod()` | `isCurrent` | Current week's rewards? |

### Item Preview & Equip

| Function | Returns | Description |
|----------|---------|-------------|
| `C_WeeklyRewards.CanClaimRewards()` | `canClaim` | Can claim? |
| `C_WeeklyRewards.HasAvailableRewards()` | `hasAvailable` | Has unclaimed? |

### Concurrency Info

| Function | Returns | Description |
|----------|---------|-------------|
| `C_WeeklyRewards.GetConquestWeeklyProgress()` | `progress` | Conquest earned |

---

## Common Patterns

### Display Great Vault Status

```lua
local function ShowVaultStatus()
    local activityTypes = {
        {type = Enum.WeeklyRewardChestThresholdType.MythicPlus, name = "Mythic+"},
        {type = Enum.WeeklyRewardChestThresholdType.Raid, name = "Raid"},
        {type = Enum.WeeklyRewardChestThresholdType.RankedPvP, name = "PvP"},
        {type = Enum.WeeklyRewardChestThresholdType.World, name = "World"},
    }
    
    for _, actType in ipairs(activityTypes) do
        local activities = C_WeeklyRewards.GetActivities(actType.type)
        if activities then
            print(actType.name .. ":")
            for _, activity in ipairs(activities) do
                local status = activity.progress >= activity.threshold and "COMPLETE" or 
                    (activity.progress .. "/" .. activity.threshold)
                local levelInfo = activity.level > 0 and (" (Level " .. activity.level .. ")") or ""
                print("  Slot " .. activity.index .. ": " .. status .. levelInfo)
            end
        end
    end
end
```

### Check for Available Rewards

```lua
local f = CreateFrame("Frame")
f:RegisterEvent("WEEKLY_REWARDS_UPDATE")
f:SetScript("OnEvent", function()
    if C_WeeklyRewards.HasAvailableRewards() then
        print("You have Great Vault rewards to claim!")
    end
end)
```

### Preview Vault Rewards

```lua
local function PreviewVaultRewards()
    local allActivities = {
        C_WeeklyRewards.GetActivities(Enum.WeeklyRewardChestThresholdType.MythicPlus),
        C_WeeklyRewards.GetActivities(Enum.WeeklyRewardChestThresholdType.Raid),
        C_WeeklyRewards.GetActivities(Enum.WeeklyRewardChestThresholdType.RankedPvP),
    }
    
    for _, activities in ipairs(allActivities) do
        if activities then
            for _, activity in ipairs(activities) do
                if activity.progress >= activity.threshold then
                    local links = C_WeeklyRewards.GetExampleRewardItemHyperlinks(activity.id)
                    if links then
                        for _, link in ipairs(links) do
                            print("  Possible:", link)
                        end
                    end
                end
            end
        end
    end
end
```

---

## Key Events

| Event | Payload | Description |
|-------|---------|-------------|
| `WEEKLY_REWARDS_UPDATE` | — | Vault data changed |
| `WEEKLY_REWARDS_SHOW` | — | Vault UI opened |
| `WEEKLY_REWARDS_HIDE` | — | Vault UI closed |
| `WEEKLY_REWARDS_ITEM_CHANGED` | — | Reward item changed |

---

## Gotchas & Restrictions

1. **Weekly reset timing** — Rewards are generated at weekly reset; APIs return no data before Tuesday/Wednesday reset.
2. **Claim requires hardware** — `ClaimReward()` requires user interaction.
3. **Activity types vary by season** — Not all activity types are active every season.
4. **Three slots per type** — Each type has 3 reward slots with increasing thresholds.
5. **Level field meaning changes** — For M+ it's key level, for raids it's difficulty, for PvP it's rating bracket.
6. **Example rewards are estimates** — `GetExampleRewardItemHyperlinks()` shows possible rewards, not guaranteed ones.
7. **Rewards expire** — Unclaimed vault rewards from a previous week may be forfeited.
8. **HasAvailableRewards() vs HasGeneratedRewards()** — Generated means the vault has rolled items; Available means the player can claim them now.
