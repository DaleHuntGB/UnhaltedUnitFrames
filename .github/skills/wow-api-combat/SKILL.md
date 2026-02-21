---
name: wow-api-combat
description: "Complete reference for WoW Retail Combat, Damage Meter, Threat, Loss of Control, Combat Text, Combat Audio Alert, Secret Values, and Spectator APIs. Covers the 12.0.0 combat log removal (CLEU no longer available to addons), C_DamageMeter built-in damage meter, C_Secrets secret predicates, C_CurveUtil/C_DurationUtil for secret value visualization, C_LossOfControl, C_CombatText, C_CombatAudioAlert, ENCOUNTER_STATE_CHANGED, threat functions, and the new COMBAT_LOG_MESSAGE event. Use when working with combat data, damage meters, threat, loss of control, combat text, encounter events, or any combat-related addon functionality."
---

# Combat API (Retail — Patch 12.0.0)

Comprehensive reference for all combat-related APIs in WoW Retail. **Critical: The combat log system was fundamentally changed in 12.0.0.** `COMBAT_LOG_EVENT_UNFILTERED` is no longer available to addons.

> **Source:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API
> **Current as of:** Patch 12.0.0 (Build 65655) — January 28, 2026
> **Scope:** Retail only.

## CRITICAL: Combat Log Changes in 12.0.0

**`COMBAT_LOG_EVENT_UNFILTERED` (CLEU) is NO LONGER available to addons.**

- `CombatLogGetCurrentEventInfo()` is unavailable to tainted (addon) code
- The old `COMBAT_LOG_EVENT` event is also unavailable
- Combat log chat tab messages are now **KStrings** (unparseable escape sequences)
- Addons like damage meters must use `C_DamageMeter` or the built-in system
- A new `COMBAT_LOG_EVENT_INTERNAL_UNFILTERED` exists but is restricted to Blizzard code

### New Combat Log Events (Addon-Facing)

| Event | Description |
|-------|-------------|
| `COMBAT_LOG_MESSAGE` | Formatted combat log messages (display text only) |
| `COMBAT_LOG_ENTRIES_CLEARED` | Combat log entries cleared |
| `COMBAT_LOG_APPLY_FILTER_SETTINGS` | Filter settings changed |
| `COMBAT_LOG_REFILTER_ENTRIES` | Entries need refiltering |
| `COMBAT_LOG_MESSAGE_LIMIT_CHANGED` | Message limit changed |

---

## Scope

This skill covers:

- **Combat Log** — New 12.0.0 combat log system, COMBAT_LOG_MESSAGE
- **C_DamageMeter** — Built-in damage/healing meter system
- **Threat** — UnitThreatSituation, UnitDetailedThreatSituation
- **C_LossOfControl** — Loss of control tracking
- **C_CombatText** — Floating combat text
- **C_CombatAudioAlert** — Combat audio alert system (accessibility)
- **C_Secrets / C_CurveUtil / C_DurationUtil** — Secret value handling for combat data
- **Encounter Events** — ENCOUNTER_STATE_CHANGED, ENCOUNTER_WARNING, timeline events
- **Spectator/Commentator** — C_Commentator for spectator mode

---

## C_DamageMeter — Built-in Damage Meter

New in 12.0.0. Provides official damage/healing meter data without needing combat log parsing.

### Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `C_DamageMeter.GetCurrentSessionID()` | `sessionID` | Current combat session |
| `C_DamageMeter.GetSessions()` | `sessions` | All available sessions |
| `C_DamageMeter.GetSessionInfo(sessionID)` | `sessionInfo` | Session details |
| `C_DamageMeter.GetPlayerData(sessionID, unitGUID)` | `playerData` | Player's damage/healing |
| `C_DamageMeter.GetPartyData(sessionID)` | `partyData` | All party/raid data |
| `C_DamageMeter.ResetSessions()` | — | Clear all sessions |

### Events

| Event | Description |
|-------|-------------|
| `DAMAGE_METER_COMBAT_SESSION_UPDATED` | Session data updated |
| `DAMAGE_METER_CURRENT_SESSION_UPDATED` | Current session changed |
| `DAMAGE_METER_RESET` | Sessions cleared |

### Pattern: Reading Damage Meter Data

```lua
local frame = CreateFrame("Frame")
frame:RegisterEvent("DAMAGE_METER_COMBAT_SESSION_UPDATED")
frame:SetScript("OnEvent", function(self, event)
    local sessionID = C_DamageMeter.GetCurrentSessionID()
    if sessionID then
        local partyData = C_DamageMeter.GetPartyData(sessionID)
        -- partyData contains per-player damage/healing totals
    end
end)
```

---

## Threat API

### Threat Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `UnitThreatSituation(unit [, target])` | `status` | Threat status (0-3) |
| `UnitDetailedThreatSituation(unit, target)` | `isTanking, status, scaledPercent, rawPercent, threatValue` | Detailed threat info |
| `UnitThreatPercentageOfLead(unit, target)` | `percent` | Threat lead percentage |

### Threat Status Values

| Value | Meaning |
|-------|---------|
| 0 | Not on threat table |
| 1 | On threat table, not tanking, not highest |
| 2 | On threat table, not tanking, highest |
| 3 | Tanking (highest threat with aggro) |
| nil | Unit doesn't exist or has no threat table |

> **Note:** In 12.0.0 instances, threat values for non-player units may be **secret values**. Pass them directly to UI widgets.

---

## C_LossOfControl

Tracks crowd control effects on the player.

| Function | Returns | Description |
|----------|---------|-------------|
| `C_LossOfControl.GetActiveLossOfControlData(index)` | `data` | Active CC effect data |
| `C_LossOfControl.GetActiveLossOfControlDataByUnit(unit, index)` | `data` | CC data for unit |
| `C_LossOfControl.GetActiveLossOfControlDataCount()` | `count` | Number of active CC effects |
| `C_LossOfControl.GetActiveLossOfControlDataCountByUnit(unit)` | `count` | CC count for unit |

### Loss of Control Data Fields

- `locType` — Type of CC (STUN, FEAR, SILENCE, etc.)
- `spellID` — Spell causing the CC
- `displayText` — Localized display text
- `iconTexture` — Spell icon
- `startTime` — When CC started
- `timeRemaining` — Duration remaining (may be DurationObject in 12.0.0)
- `duration` — Total duration
- `lockoutSchool` — School lockout (for SCHOOL_INTERRUPT type)
- `priority` — Display priority

### Events

| Event | Description |
|-------|-------------|
| `LOSS_OF_CONTROL_ADDED` | New CC effect applied |
| `LOSS_OF_CONTROL_UPDATE` | CC effect updated |

---

## C_CombatText — Floating Combat Text

| Function | Returns | Description |
|----------|---------|-------------|
| `C_CombatText.IsCombatTextEnabled()` | `enabled` | FCT enabled? |

### Combat Text CVars

| CVar | Description |
|------|-------------|
| `enableFloatingCombatText` | Enable/disable FCT |
| `floatingCombatTextCombatDamage` | Show damage |
| `floatingCombatTextCombatHealing` | Show healing |
| `floatingCombatTextCombatDamageStyle` | Damage display style |

---

## C_CombatAudioAlert — Combat Audio Alerts

New accessibility system providing audio cues for combat events. Replaces some functionality that previously required combat log parsing.

| Function | Returns | Description |
|----------|---------|-------------|
| `C_CombatAudioAlert.IsEnabled()` | `enabled` | Audio alerts enabled? |
| `C_CombatAudioAlert.SetEnabled(enabled)` | — | Enable/disable |

---

## Secret Value Handling for Combat Data

### C_Secrets — Secret Predicates

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Secrets.ShouldUnitHealthBeSecret(unit)` | `isSecret` | Is health secret for this unit? |
| `C_Secrets.ShouldUnitPowerBeSecret(unit [, powerType])` | `isSecret` | Is power secret? |
| `C_Secrets.ShouldUnitPowerMaxBeSecret(unit [, powerType])` | `isSecret` | Is max power secret? |
| `C_Secrets.ShouldUnitSpellCastBeSecret(unit, spellIdentifier)` | `isSpellCastSecret` | Is spell cast secret? |
| `C_Secrets.ShouldUnitSpellCastingBeSecret(unit)` | `isSpellCastingSecret` | Is all casting secret? |

### C_CurveUtil — Curves for Secret Values

Since addons cannot do math on secret values, Curves allow mapping secret numbers to visual output.

| Function | Returns | Description |
|----------|---------|-------------|
| `C_CurveUtil.CreateCurve()` | `curveObject` | Create a numeric curve |
| `C_CurveUtil.CreateColorCurve()` | `colorCurveObject` | Create a color curve |

### Pattern: Health-to-Color Without Inspecting Value

```lua
-- Create a color curve: green at 100% → red at 0%
local colorCurve = C_CurveUtil.CreateColorCurve()
-- Configure curve points (green → yellow → red)

local healthBar = CreateFrame("StatusBar", nil, parent)
local hp = UnitHealth(unit)         -- SECRET in instances
local maxHp = UnitHealthMax(unit)   -- SECRET in instances
healthBar:SetMinMaxValues(0, maxHp) -- widgets accept secrets
healthBar:SetValue(hp)              -- widgets accept secrets
-- Color is set by curve without addon seeing the actual number
```

### C_DurationUtil — Duration Objects

| Function | Returns | Description |
|----------|---------|-------------|
| `C_DurationUtil.CreateDuration()` | `durationObject` | Create a duration object |

```lua
-- Use DurationObject for cooldown display
local cooldown = CreateFrame("Cooldown", nil, parent, "CooldownFrameTemplate")
local duration = C_DurationUtil.CreateDuration()
cooldown:SetCooldownFromDurationObject(duration)
```

---

## Encounter Events

New in 12.0.0, these replace addon combat log parsing for encounter state tracking.

| Event | Description |
|-------|-------------|
| `ENCOUNTER_STATE_CHANGED` | Encounter state changed (pull, wipe, kill) |
| `ENCOUNTER_WARNING` | Built-in encounter warning system |
| `ENCOUNTER_TIMELINE_EVENT_START` | Timeline event started |
| `ENCOUNTER_TIMELINE_EVENT_UPDATE` | Timeline event updated |
| `ENCOUNTER_TIMELINE_EVENT_END` | Timeline event ended |

### Other Combat Events

| Event | Description |
|-------|-------------|
| `PLAYER_REGEN_DISABLED` | Entering combat |
| `PLAYER_REGEN_ENABLED` | Leaving combat |
| `PLAYER_ENTER_COMBAT` | Player starts auto-attack |
| `PLAYER_LEAVE_COMBAT` | Player stops auto-attack |
| `UNIT_COMBAT` | Unit took/dealt damage or healing |
| `UNIT_THREAT_SITUATION_UPDATE` | Threat status changed |
| `UNIT_THREAT_LIST_UPDATE` | Threat table updated |
| `PLAYER_DEAD` | Player died |
| `PLAYER_ALIVE` | Player released spirit |
| `PLAYER_UNGHOST` | Player resurrected |

---

## Commentator / Spectator API

`C_Commentator` provides spectator mode functionality for esports viewing.

### Key Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Commentator.IsSpectating()` | `isSpectating` | In spectator mode? |
| `C_Commentator.GetAllPlayerData(teamIndex)` | `playerData` | All player data for team |
| `C_Commentator.GetPlayerData(teamIndex, playerIndex)` | `data` | Specific player data |
| `C_Commentator.GetTeamColorAndName(teamIndex)` | `color, name` | Team info |
| `C_Commentator.GetMatchDuration()` | `duration` | Match elapsed time |
| `C_Commentator.StartWargame(...)` | — | Start a wargame |
| `C_Commentator.UpdatePlayerInfo()` | — | Refresh player data |

---

## Common Patterns

### Check Combat State

```lua
local function IsInCombat()
    return UnitAffectingCombat("player")
end

-- Or use the lockdown check for secure frame operations
if InCombatLockdown() then
    print("In combat lockdown — restricted operations blocked")
end
```

### Threat-Based Nameplate Coloring

```lua
-- Note: In 12.0.0 instances, threat values may be secret
local status = UnitThreatSituation("player", "target")
if not issecretvalue(status) then
    if status == 3 then
        -- Tanking — show red
    elseif status == 2 then
        -- Pulling aggro — show orange
    else
        -- Safe — show green
    end
end
```

### Loss of Control Display

```lua
local frame = CreateFrame("Frame")
frame:RegisterEvent("LOSS_OF_CONTROL_ADDED")
frame:RegisterEvent("LOSS_OF_CONTROL_UPDATE")
frame:SetScript("OnEvent", function()
    local count = C_LossOfControl.GetActiveLossOfControlDataCount()
    for i = 1, count do
        local data = C_LossOfControl.GetActiveLossOfControlData(i)
        if data then
            print(data.displayText, data.timeRemaining)
        end
    end
end)
```

---

## Gotchas & Restrictions

1. **CLEU is GONE** — Do NOT register for `COMBAT_LOG_EVENT_UNFILTERED`. It will not fire for addon code in 12.0.0.
2. **No combat log parsing** — `CombatLogGetCurrentEventInfo()` is unavailable to tainted code.
3. **KString chat messages** — Combat log chat tab output is now KStrings that cannot be parsed.
4. **Health is secret** — `UnitHealth()` returns secret values in instances. Pass directly to `StatusBar:SetValue()`.
5. **Use DurationObjects** — Don't do manual cooldown math. Use `C_DurationUtil.CreateDuration()` and `Cooldown:SetCooldownFromDurationObject()`.
6. **Built-in damage meter** — Use `C_DamageMeter` for damage/healing data instead of parsing combat events.
7. **SendAddonMessage blocked** — Cannot send addon messages in instances. Boss mod addons must use new encounter event patterns.
8. **Unit identity restricted** — `UnitName()`, `UnitClass()` may return secrets for enemy units in instances during combat.
9. **Threat in instances** — Threat values may be secret. Pass to widgets directly; don't branch on them.
10. **Design philosophy** — Addons should NOT provide competitive advantage in combat. Blizzard provides built-in replacements for most restricted functionality.
