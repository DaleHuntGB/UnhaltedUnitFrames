# C_Spell — Core Spell API Reference

> **Source:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#Spell
> **Current as of:** Patch 12.0.0 (Build 65655) — January 28, 2026

The `C_Spell` namespace is the primary API for querying spell data. All functions accept a `spellIdentifier` which is either a `spellID` (number) or `spellName` (string). Use `C_Spell.GetSpellIDForSpellIdentifier()` to resolve names to IDs.

---

## Spell Information

### C_Spell.GetSpellInfo(spellIdentifier) → spellInfo

Returns a table with core spell data:

```lua
---@class SpellInfo
---@field name string              -- Localized spell name
---@field iconID number            -- Texture file ID
---@field originalIconID number    -- Original icon before overrides
---@field castTime number          -- Cast time in milliseconds (0 = instant)
---@field minRange number          -- Minimum range in yards
---@field maxRange number          -- Maximum range in yards
---@field spellID number           -- Spell ID
```

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellInfo

**Usage:**
```lua
local info = C_Spell.GetSpellInfo(116)  -- Frostbolt
if info then
    print(info.name, info.castTime / 1000 .. "s cast")
end
```

**Notes:**
- Returns `nil` if data is not cached. Call `C_Spell.RequestLoadSpellData()` first for uncached spells, then wait for `SPELL_DATA_LOAD_RESULT`.
- `castTime` is in milliseconds and accounts for haste.
- Use `C_Spell.IsSpellDataCached(spellIdentifier)` to check availability before querying.

### C_Spell.GetSpellName(spellIdentifier) → name

Returns the localized spell name string.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellName

### C_Spell.GetSpellDescription(spellIdentifier) → description

Returns the spell tooltip description text with variables filled in for the current player.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellDescription

### C_Spell.GetSpellTexture(spellIdentifier) → iconID, originalIconID

Returns the spell's icon texture ID. `originalIconID` is the icon before any overrides.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellTexture

### C_Spell.GetSpellSubtext(spellIdentifier) → subtext

Returns the spell's subtext (rank label, specialization, etc.).

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellSubtext

### C_Spell.GetSpellLink(spellIdentifier [, glyphID]) → spellLink

Returns a clickable hyperlink string for the spell. Pass `glyphID` for glyph-modified spells.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellLink

### C_Spell.DoesSpellExist(spellIdentifier) → spellExists

Returns `true` if the spell exists in the game database.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.DoesSpellExist

### C_Spell.GetSpellIDForSpellIdentifier(spellIdentifier) → spellID

Resolves a spell name or ID to the canonical spell ID.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellIDForSpellIdentifier

### C_Spell.GetBaseSpell(spellIdentifier [, spec]) → baseSpellID

Returns the base (un-overridden) spell ID. Pass `spec` to check a specific specialization.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.GetBaseSpell

### C_Spell.GetOverrideSpell(spellIdentifier [, spec [, onlyKnown [, ignoreOverrideSpellID]]]) → overrideSpellID

Returns the current override for a spell (e.g., talent-modified version). Returns the input spell if no override.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.GetOverrideSpell

---

## Cooldowns & Charges

### C_Spell.GetSpellCooldown(spellIdentifier) → spellCooldownInfo

Returns cooldown state:

```lua
---@class SpellCooldownInfo
---@field startTime number     -- GetTime() when cooldown started (0 if not on CD)
---@field duration number      -- Total cooldown duration in seconds
---@field isEnabled boolean    -- false if cooldown is not decreasing (e.g., LoC)
---@field modRate number       -- Cooldown recovery rate modifier (haste)
```

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellCooldown

**⚠ Patch 12.0.0:** `startTime` and `duration` may be **secret values** when `C_Secrets.ShouldSpellCooldownBeSecret(spellIdentifier)` is true. Pass directly to `Cooldown:SetCooldown()` without branching.

### C_Spell.GetSpellCooldownDuration(spellIdentifier) → duration

Returns the remaining cooldown in seconds. Convenience wrapper over `GetSpellCooldown`.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellCooldownDuration

### C_Spell.GetSpellCharges(spellIdentifier) → chargeInfo

Returns charge state for spells with charges:

```lua
---@class SpellChargeInfo
---@field currentCharges number    -- Available charges
---@field maxCharges number        -- Maximum charges
---@field cooldownStartTime number -- GetTime() when current charge started recharging
---@field cooldownDuration number  -- Recharge time per charge
---@field chargeModRate number     -- Haste modifier for recharge
```

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellCharges

Returns `nil` for spells without charges.

### C_Spell.GetSpellChargeDuration(spellIdentifier) → duration

Returns the recharge duration for one charge.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellChargeDuration

### C_Spell.GetSpellLossOfControlCooldown(spellIdentifier) → startTime, duration

Returns cooldown imposed by loss-of-control effects (stuns, silences).

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellLossOfControlCooldown

### C_Spell.GetSpellLossOfControlCooldownDuration(spellIdentifier) → duration

Returns remaining LoC lockout duration.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellLossOfControlCooldownDuration

---

## Usability & Range

### C_Spell.IsSpellUsable(spellIdentifier) → isUsable, insufficientPower

- `isUsable` — Can the spell be cast right now? Accounts for cooldown, resources, target requirements.
- `insufficientPower` — `true` if the only reason it can't be used is insufficient resources (mana/energy/etc.).

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.IsSpellUsable

### C_Spell.IsSpellInRange(spellIdentifier [, targetUnit]) → inRange

Returns `true` if `targetUnit` is within range, `false` if out of range, `nil` if the spell has no range requirement or no valid target. If `targetUnit` is omitted, checks the current target.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.IsSpellInRange

### C_Spell.SpellHasRange(spellIdentifier) → hasRange

Returns `true` if the spell has a range component.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.SpellHasRange

### C_Spell.IsSpellDisabled(spellIdentifier) → disabled

Returns `true` if the spell is currently disabled (e.g., by game rules).

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.IsSpellDisabled

### C_Spell.GetSpellCastCount(spellIdentifier) → castCount

Returns the number of times the spell can currently be cast (e.g., for spells with limited charges or stacks).

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellCastCount

---

## Type Checks

These boolean query functions help categorize spells:

### Offensive / Defensive

| Function | Wiki |
|----------|------|
| `C_Spell.IsSpellHarmful(spellIdentifier)` → `isHarmful` | [API_C_Spell.IsSpellHarmful](https://warcraft.wiki.gg/wiki/API_C_Spell.IsSpellHarmful) |
| `C_Spell.IsSpellHelpful(spellIdentifier)` → `isHelpful` | [API_C_Spell.IsSpellHelpful](https://warcraft.wiki.gg/wiki/API_C_Spell.IsSpellHelpful) |
| `C_Spell.IsExternalDefensive(spellID)` → `isExternalDefensive` | [API_C_Spell.IsExternalDefensive](https://warcraft.wiki.gg/wiki/API_C_Spell.IsExternalDefensive) |
| `C_Spell.IsSelfBuff(spellID)` → `hasSelfEffectsOnly` | [API_C_Spell.IsSelfBuff](https://warcraft.wiki.gg/wiki/API_C_Spell.IsSelfBuff) |
| `C_Spell.IsSpellCrowdControl(spellIdentifier)` → `isCrowdControl` | [API_C_Spell.IsSpellCrowdControl](https://warcraft.wiki.gg/wiki/API_C_Spell.IsSpellCrowdControl) |

### Spell Origin

| Function | Wiki |
|----------|------|
| `C_Spell.IsClassTalentSpell(spellIdentifier)` → `isClassTalent` | [API_C_Spell.IsClassTalentSpell](https://warcraft.wiki.gg/wiki/API_C_Spell.IsClassTalentSpell) |
| `C_Spell.IsPvPTalentSpell(spellIdentifier)` → `isPvPTalent` | [API_C_Spell.IsPvPTalentSpell](https://warcraft.wiki.gg/wiki/API_C_Spell.IsPvPTalentSpell) |
| `C_Spell.IsSpellPassive(spellIdentifier)` → `isPassive` | [API_C_Spell.IsSpellPassive](https://warcraft.wiki.gg/wiki/API_C_Spell.IsSpellPassive) |

### Auto / Repeat

| Function | Wiki |
|----------|------|
| `C_Spell.IsAutoAttackSpell(spellIdentifier)` → `isAutoAttack` | [API_C_Spell.IsAutoAttackSpell](https://warcraft.wiki.gg/wiki/API_C_Spell.IsAutoAttackSpell) |
| `C_Spell.IsAutoRepeatSpell(spellIdentifier)` → `isAutoRepeat` | [API_C_Spell.IsAutoRepeatSpell](https://warcraft.wiki.gg/wiki/API_C_Spell.IsAutoRepeatSpell) |
| `C_Spell.IsRangedAutoAttackSpell(spellIdentifier)` → `isRangedAutoAttack` | [API_C_Spell.IsRangedAutoAttackSpell](https://warcraft.wiki.gg/wiki/API_C_Spell.IsRangedAutoAttackSpell) |

### State & Behavior

| Function | Wiki |
|----------|------|
| `C_Spell.IsCurrentSpell(spellIdentifier)` → `isCurrentSpell` | [API_C_Spell.IsCurrentSpell](https://warcraft.wiki.gg/wiki/API_C_Spell.IsCurrentSpell) |
| `C_Spell.IsConsumableSpell(spellIdentifier)` → `consumable` | [API_C_Spell.IsConsumableSpell](https://warcraft.wiki.gg/wiki/API_C_Spell.IsConsumableSpell) |
| `C_Spell.IsPressHoldReleaseSpell(spellIdentifier)` → `isPressHoldRelease` | [API_C_Spell.IsPressHoldReleaseSpell](https://warcraft.wiki.gg/wiki/API_C_Spell.IsPressHoldReleaseSpell) |
| `C_Spell.IsSpellImportant(spellIdentifier)` → `isImportant` | [API_C_Spell.IsSpellImportant](https://warcraft.wiki.gg/wiki/API_C_Spell.IsSpellImportant) |
| `C_Spell.IsPriorityAura(spellID)` → `isHighPriority` | [API_C_Spell.IsPriorityAura](https://warcraft.wiki.gg/wiki/API_C_Spell.IsPriorityAura) |

---

## Power Cost & Data

### C_Spell.GetSpellPowerCost(spellIdentifier) → powerCosts

Returns an array of tables describing each resource cost:

```lua
---@class SpellPowerCostInfo
---@field type number          -- Enum.PowerType value
---@field name string          -- Localized power type name
---@field cost number          -- Resource cost
---@field minCost number       -- Minimum cost (if variable)
---@field requiredAuraID number -- Aura required for this cost
---@field costPercent number   -- Cost as percentage of max
---@field costPerSec number    -- Cost per second (channeled spells)
---@field hasRequiredAura boolean -- Whether an aura is required
```

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellPowerCost

### C_Spell.GetSpellLevelLearned(spellIdentifier) → levelLearned

Returns the player level at which this spell is learned.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellLevelLearned

### C_Spell.GetSpellSkillLineAbilityRank(spellIdentifier) → rank

For profession recipes, returns the recipe rank.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellSkillLineAbilityRank

### C_Spell.GetSpellMaxCumulativeAuraApplications(spellID) → cumulativeAura

Returns the maximum number of stacks for a stacking aura.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellMaxCumulativeAuraApplications

### C_Spell.GetAuraStatChanges(spellID) → healthChange, powerTypeChanges

Returns the stat modifications an aura provides.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.GetAuraStatChanges

### C_Spell.GetDeadlyDebuffInfo(spellIdentifier) → deadlyDebuffInfo

Returns display info for deadly debuffs (encounter mechanics that need prominent display).

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.GetDeadlyDebuffInfo

### C_Spell.GetSpellQueueWindow() → result

Returns the spell queue window in milliseconds (how early a next cast can be queued).

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellQueueWindow

### C_Spell.GetSchoolString(schoolMask) → result

Returns the localized name of a spell school from a bitmask (e.g., "Fire" for 0x4).

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.GetSchoolString

---

## Spell Manipulation

### C_Spell.CancelSpellByID(spellID)

Cancels a spell currently being cast or channeled by the player.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.CancelSpellByID

### C_Spell.PickupSpell(spellIdentifier)

Attaches a spell to the cursor for drag-and-drop placement.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.PickupSpell

### C_Spell.RequestLoadSpellData(spellIdentifier)

Requests asynchronous loading of spell data. Fires `SPELL_DATA_LOAD_RESULT` when complete.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.RequestLoadSpellData

### C_Spell.IsSpellDataCached(spellIdentifier) → isCached

Returns `true` if spell data is already cached and available for immediate query.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.IsSpellDataCached

### C_Spell.EnableSpellRangeCheck(spellIdentifier, enable)

Enables or disables continuous range checking for a spell (used by action button range coloring).

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.EnableSpellRangeCheck

### C_Spell.SetSpellAutoCastEnabled(spellIdentifier, enabled)

Sets the autocast state for a pet spell.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.SetSpellAutoCastEnabled

### C_Spell.ToggleSpellAutoCast(spellIdentifier)

Toggles the autocast state for a pet spell.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.ToggleSpellAutoCast

### C_Spell.GetSpellAutoCast(spellIdentifier) → autoCastAllowed, autoCastEnabled

Returns whether a pet spell can be auto-cast and whether it's currently set to auto-cast.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellAutoCast

---

## Visibility & Display

### C_Spell.GetVisibilityInfo(spellID, visibilityType) → hasCustom, alwaysShowMine, showForMySpec

Returns aura display visibility rules for buff/debuff frames.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.GetVisibilityInfo

### C_Spell.GetSpellDisplayCount(spellIdentifier [, maxDisplayCount [, replacementString]]) → displayCount

Returns the display count for stacking effects.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellDisplayCount

---

## Targeting & Trade

### C_Spell.TargetSpellIsEnchanting() → isEnchanting

Returns `true` if the spell currently awaiting target selection is an enchanting spell.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.TargetSpellIsEnchanting

### C_Spell.TargetSpellJumpsUpgradeTrack() → jumpsUpgradeTrack

Returns `true` if the target spell will jump the upgrade track.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.TargetSpellJumpsUpgradeTrack

### C_Spell.TargetSpellReplacesBonusTree() → result

Returns `true` if the target spell replaces the bonus loot tree.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.TargetSpellReplacesBonusTree

### C_Spell.GetSpellTradeSkillLink(spellIdentifier) → spellLink

Returns a trade skill recipe link for the spell.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellTradeSkillLink

---

## Miscellaneous

### C_Spell.GetMawPowerBorderAtlasBySpellID(spellID) → rarityBorderAtlas

Returns the Torghast maw power border atlas name.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.GetMawPowerBorderAtlasBySpellID

### C_Spell.GetMawPowerLinkBySpellID(spellID) → link

Returns a hyperlink for a Torghast maw power.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.GetMawPowerLinkBySpellID

### C_Spell.GetItemModifiedAppearancesApplied(spellID) → itemModifiedAppearanceIDs

Returns item appearances applied by the spell.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Spell.GetItemModifiedAppearancesApplied
