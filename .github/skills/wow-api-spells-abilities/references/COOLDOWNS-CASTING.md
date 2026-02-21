# Cooldowns, Casting & Auxiliary Spell Systems Reference

> **Source:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API
> **Current as of:** Patch 12.0.0 (Build 65655) — January 28, 2026

This file covers smaller spell-related namespaces: `C_SpellActivationOverlay`, `C_SpellDiminish`, `C_CooldownViewer`, `C_AssistedCombat`, `C_LevelLink`, and global spell-casting / targeting functions.

---

## C_SpellActivationOverlay

Manages the proc-glow overlay system (e.g., Art of War, Fingers of Frost).

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellActivationOverlay

### C_SpellActivationOverlay.GetSpellActivationOverlay(spellID) → overlayInfo

Returns overlay glow info for an active spell proc, or nil if none.

```lua
---@class SpellActivationOverlayInfo
---@field spellID number
---@field texture string
---@field positions string       -- e.g., "LEFT", "RIGHT", "TOP", "BOTTOM"
---@field scale number
---@field r number
---@field g number
---@field b number
```

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellActivationOverlay.GetSpellActivationOverlay

### Overlay Events

| Event | Payload | Description |
|-------|---------|-------------|
| `SPELL_ACTIVATION_OVERLAY_GLOW_SHOW` | `spellID` | Proc glow should appear |
| `SPELL_ACTIVATION_OVERLAY_GLOW_HIDE` | `spellID` | Proc glow should disappear |
| `SPELL_ACTIVATION_OVERLAY_SHOW` | `spellID, texture, positions, scale, r, g, b` | Full overlay should show |
| `SPELL_ACTIVATION_OVERLAY_HIDE` | `spellID` | Full overlay should hide |

---

## C_SpellDiminish (SpellDiminishUI)

Provides diminishing returns category information for spells. Useful for PvP UI addons.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellDiminish

### C_SpellDiminish.GetDiminishingReturnsInfo(spellID) → info

Returns DR info for a spell.

```lua
---@class DiminishingReturnsInfo
---@field category number          -- DR category
---@field categoryString string    -- Localized category name (e.g., "Stun")
---@field stackCount number        -- Current DR stack
---@field timeRemaining number     -- Seconds until DR resets
---@field limitDuration number     -- Max duration at current stack
```

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellDiminish.GetDiminishingReturnsInfo

### C_SpellDiminish.GetDiminishingReturnsCategoryForSpell(spellID) → category

Returns the DR category for a spell.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellDiminish.GetDiminishingReturnsCategoryForSpell

### C_SpellDiminish.GetDiminishingReturnsCategoryString(category) → categoryString

Converts a DR category number to its localized name.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellDiminish.GetDiminishingReturnsCategoryString

### C_SpellDiminish.IsDiminishingReturnsSpell(spellID) → isDRSpell

Returns `true` if the spell is subject to diminishing returns.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellDiminish.IsDiminishingReturnsSpell

---

## C_CooldownViewer

Provides cooldown tracking across party/raid members for UI addons.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_CooldownViewer

### C_CooldownViewer.GetCooldownViewerSpells() → spells

Returns the list of tracked spells for the cooldown viewer.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_CooldownViewer.GetCooldownViewerSpells

### C_CooldownViewer.GetCooldownViewerSpellInfo(spellID) → info

Returns detailed cooldown viewer info for a tracked spell.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_CooldownViewer.GetCooldownViewerSpellInfo

### C_CooldownViewer.GetUnitCooldownInfo(unit, spellID) → cooldownInfo

Returns the cooldown state for a specific unit's spell.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_CooldownViewer.GetUnitCooldownInfo

### C_CooldownViewer.GetUnitCooldowns(unit) → cooldowns

Returns all tracked cooldowns for a unit.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_CooldownViewer.GetUnitCooldowns

### C_CooldownViewer.IsCooldownViewerReady() → isReady

Returns `true` if cooldown viewer data is available.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_CooldownViewer.IsCooldownViewerReady

### C_CooldownViewer.IsSpellTracked(spellID) → isTracked

Returns `true` if a spell is being tracked in the cooldown viewer.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_CooldownViewer.IsSpellTracked

---

## C_AssistedCombat

Manages the assisted combat (AI rotation helper) system.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_AssistedCombat

### C_AssistedCombat.GetAssistedCombatInfo() → info

Returns current assisted combat state and configuration.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_AssistedCombat.GetAssistedCombatInfo

### C_AssistedCombat.IsAssistedCombatAvailable() → isAvailable

Returns `true` if assisted combat is available for the current class/spec.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_AssistedCombat.IsAssistedCombatAvailable

### C_AssistedCombat.IsAssistedCombatEnabled() → isEnabled

Returns `true` if assisted combat is currently enabled.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_AssistedCombat.IsAssistedCombatEnabled

### C_AssistedCombat.SetAssistedCombatEnabled(enabled)

Enables or disables assisted combat.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_AssistedCombat.SetAssistedCombatEnabled

---

## C_LevelLink

Provides level-up spell unlock previews.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_LevelLink

### C_LevelLink.GetSpellLinkForLevel(level) → spellLink

Returns a spell link for a spell learned at the given level.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_LevelLink.GetSpellLinkForLevel

### C_LevelLink.IsSpellLevelLinkLocked(spellID) → isLocked

Returns `true` if the spell's level-link is locked (spell not yet available at current level).

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_LevelLink.IsSpellLevelLinkLocked

---

## Global Spell Casting Functions

These are global functions for casting spells, managing spell targeting, and spell confirmation.

### Casting

| Function | Description | Wiki |
|----------|-------------|------|
| `CastSpellByName(name [, onSelf])` | Cast a spell by name | https://warcraft.wiki.gg/wiki/API_CastSpellByName |
| `CastSpellByID(spellID [, onSelf])` | Cast a spell by ID | https://warcraft.wiki.gg/wiki/API_CastSpellByID |
| `UseAction(slot [, checkCursor [, onSelf]])` | Use an action bar slot | https://warcraft.wiki.gg/wiki/API_UseAction |
| `StopCasting()` | Stop current spellcast | https://warcraft.wiki.gg/wiki/API_StopCasting |

### Spell Targeting

These functions manage the ground-targeting cursor and spell targeting flow:

| Function | Description | Wiki |
|----------|-------------|------|
| `SpellTargetUnit(unit)` | Target a unit with the pending spell | https://warcraft.wiki.gg/wiki/API_SpellTargetUnit |
| `SpellStopTargeting()` | Cancel the pending spell targeting | https://warcraft.wiki.gg/wiki/API_SpellStopTargeting |
| `SpellIsTargeting()` | Returns `true` if a spell is targeting | https://warcraft.wiki.gg/wiki/API_SpellIsTargeting |
| `SpellCanTargetUnit(unit)` | Can the pending spell target this unit? | https://warcraft.wiki.gg/wiki/API_SpellCanTargetUnit |
| `SpellCanTargetPoint()` | Can the pending spell target the ground? | https://warcraft.wiki.gg/wiki/API_SpellCanTargetPoint |
| `SpellCanTargetGlyphSlot(slot)` | Can the pending spell target a glyph slot? | https://warcraft.wiki.gg/wiki/API_SpellCanTargetGlyphSlot |
| `SpellCanTargetItem()` | Can the pending spell target an item? | https://warcraft.wiki.gg/wiki/API_SpellCanTargetItem |
| `SpellCanTargetItemID(itemID)` | Can the pending spell target a specific item? | https://warcraft.wiki.gg/wiki/API_SpellCanTargetItemID |

### Spell Confirmation

These manage confirmation dialogs for expensive or impactful spell actions:

| Function | Description | Wiki |
|----------|-------------|------|
| `AcceptSpellConfirmationPrompt(spellID)` | Accept the spell confirmation prompt | https://warcraft.wiki.gg/wiki/API_AcceptSpellConfirmationPrompt |
| `DeclineSpellConfirmationPrompt(spellID)` | Decline the spell confirmation prompt | https://warcraft.wiki.gg/wiki/API_DeclineSpellConfirmationPrompt |
| `GetSpellConfirmationPromptsInfo()` | Get pending confirmation prompt info | https://warcraft.wiki.gg/wiki/API_GetSpellConfirmationPromptsInfo |

### Casting State Queries

| Function | Description | Wiki |
|----------|-------------|------|
| `UnitCastingInfo(unit)` | Returns info about unit's current cast | https://warcraft.wiki.gg/wiki/API_UnitCastingInfo |
| `UnitChannelInfo(unit)` | Returns info about unit's current channel | https://warcraft.wiki.gg/wiki/API_UnitChannelInfo |
| `CastingInfo()` | Alias for `UnitCastingInfo("player")` | https://warcraft.wiki.gg/wiki/API_CastingInfo |
| `ChannelInfo()` | Alias for `UnitChannelInfo("player")` | https://warcraft.wiki.gg/wiki/API_ChannelInfo |

---

## Cooldown Patterns

### Standard Cooldown Flow

```lua
-- Querying cooldown for a spell
local cdInfo = C_Spell.GetSpellCooldown(spellID)
if cdInfo then
    if cdInfo.isEnabled and cdInfo.duration > 0 then
        local remaining = cdInfo.startTime + cdInfo.duration - GetTime()
        print("On cooldown: " .. remaining .. "s remaining")
    end
end

-- For charge-based abilities
local chargeInfo = C_Spell.GetSpellCharges(spellID)
if chargeInfo then
    if chargeInfo.currentCharges > 0 then
        print("Ready: " .. chargeInfo.currentCharges .. "/" .. chargeInfo.maxCharges)
    else
        local nextCharge = chargeInfo.cooldownStartTime + chargeInfo.cooldownDuration - GetTime()
        print("Recharging in " .. nextCharge .. "s")
    end
end
```

### Secret Value Pattern (Patch 12.0.0)

```lua
local function SafeGetCooldown(spellID)
    if C_Secrets and C_Secrets.ShouldSpellCooldownBeSecret(spellID) then
        return nil  -- Cooldown is secret, don't display
    end
    return C_Spell.GetSpellCooldown(spellID)
end

local function SafeGetActionCooldown(slot)
    if C_Secrets and C_Secrets.ShouldActionCooldownBeSecret(slot) then
        return nil
    end
    return C_ActionBar.GetActionCooldown(slot)
end
```

---

## Casting Events

Key events for monitoring spell casting:

| Event | Payload | Description |
|-------|---------|-------------|
| `UNIT_SPELLCAST_START` | `unitTarget, castGUID, spellID` | Cast started |
| `UNIT_SPELLCAST_STOP` | `unitTarget, castGUID, spellID` | Cast stopped (any reason) |
| `UNIT_SPELLCAST_SUCCEEDED` | `unitTarget, castGUID, spellID` | Cast completed successfully |
| `UNIT_SPELLCAST_FAILED` | `unitTarget, castGUID, spellID` | Cast failed |
| `UNIT_SPELLCAST_INTERRUPTED` | `unitTarget, castGUID, spellID` | Cast interrupted |
| `UNIT_SPELLCAST_DELAYED` | `unitTarget, castGUID, spellID` | Cast pushback |
| `UNIT_SPELLCAST_CHANNEL_START` | `unitTarget, castGUID, spellID` | Channel started |
| `UNIT_SPELLCAST_CHANNEL_STOP` | `unitTarget, castGUID, spellID` | Channel stopped |
| `UNIT_SPELLCAST_CHANNEL_UPDATE` | `unitTarget, castGUID, spellID` | Channel duration changed |
| `UNIT_SPELLCAST_EMPOWER_START` | `unitTarget, castGUID, spellID` | Empower cast started |
| `UNIT_SPELLCAST_EMPOWER_STOP` | `unitTarget, castGUID, spellID` | Empower cast stopped |
| `UNIT_SPELLCAST_EMPOWER_UPDATE` | `unitTarget, castGUID, spellID` | Empower stage changed |
| `SPELL_UPDATE_COOLDOWN` | — | Any cooldown changed |
| `SPELL_UPDATE_CHARGES` | — | Any charge count changed |
| `SPELL_UPDATE_USABLE` | — | Any spell usability changed |
| `LOSS_OF_CONTROL_ADDED` | — | Loss of control effect applied |
| `LOSS_OF_CONTROL_UPDATE` | — | Loss of control effect updated |
| `SPELL_CONFIRMATION_PROMPT` | `spellID, confirmType, text, duration, currencyID, currencyCost, difficultyID` | Spell confirmation needed |
| `SPELL_CONFIRMATION_TIMEOUT` | `spellID` | Spell confirmation timed out |
