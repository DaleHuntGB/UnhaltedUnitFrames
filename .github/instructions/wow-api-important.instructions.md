---
name: WoW API 12.0.0 Critical Changes
description: Critical Patch 12.0.0 (Midnight) API changes that override prior WoW API knowledge. Covers Secret Values, combat log removal, instance restrictions, deprecated APIs, and the new addon security model.
applyTo: "**/*.lua,**/*.xml,**/*.toc"
---

# Patch 12.0.0 (Midnight) — Critical API Changes

> **TOC version: `120000`**
> These changes are ACTIVE in pre-patch (12.0.0) and Midnight launch (12.0.1).
> Prior API knowledge from 11.x and earlier **does not apply** for the systems listed below.

---

## 1. Secret Values — The New Security Model

Patch 12.0.0 introduces **Secret Values**, a fundamentally new Lua construct that replaces outright API removal for most combat-related information. Many APIs that previously returned plain numbers/strings now return **secret values** that tainted (addon) code cannot inspect.

### What Are Secret Values?

- Secret values are opaque containers holding a Lua value (number, string, boolean, etc.) that **tainted code cannot read, compare, or do arithmetic on**.
- Untainted (secure) code can operate on them normally — the restrictions only apply to addon (tainted) execution paths.
- Test with `issecretvalue(value)` → returns `true` if the value is secret.
- Test with `canaccessvalue(value)` → returns `true` if the caller can operate on secrets.

### What Tainted Code CAN Do With Secrets

- Store them in variables, upvalues, or as **values** in tables.
- Pass them to Lua functions.
- Pass them to C API functions **explicitly marked** as accepting secrets from tainted callers.
- Concatenate secret strings/numbers (also via `string.format`, `string.join`, `string.concat`).
- Query their type with `type(secret)` — returns the real type (e.g. `"number"`).

### What Tainted Code CANNOT Do With Secrets

- **Compare** or perform **boolean tests** (`if secret then`, `secret == x`): immediate Lua error.
- **Arithmetic** (`secret + 1`, `secret * 2`): immediate Lua error.
- Use the **length operator** (`#secret`): immediate Lua error.
- Use secrets as **table keys** (`t[secret] = x`): immediate Lua error.
- **Indexed access** on a secret value (`secret["foo"]`): immediate Lua error.
- **Call** a secret value as a function: immediate Lua error.

### Secret Tables

- A table can be flagged so that **all indexed access yields secret values**.
- A table can be flagged as **inaccessible** to tainted code entirely (error on index, assign, iterate, or `#`).
- If untainted code stores a secret as a table **key**, the table is **irrevocably** marked with both flags above.
- Use `canaccesstable(table)` to test if tainted code can access a table without erroring.

### CRITICAL: Never Write Code That Branches on Secret Values

```lua
-- WRONG — This will error in 12.0.0:
local hp = UnitHealth("target")
if hp < 0.3 * UnitHealthMax("target") then  -- ERROR: cannot compare secrets
    -- do something
end

-- CORRECT — Pass secrets directly to widget APIs that accept them:
local hp = UnitHealth("target")
myStatusBar:SetValue(hp)  -- StatusBar:SetValue() accepts secrets
```

---

## 2. Secret Aspects (Widget API)

When a secret value is passed into a widget API, the widget may be marked with a **Secret Aspect**, causing related getter APIs on that widget to return secrets.

### How Aspects Work

- APIs are grouped into **aspects** (e.g., `Text`, `Shown`, `Alpha`).
- Passing a secret into any API in an aspect marks the widget with that aspect.
- All APIs in that aspect then return secret values.
- Aspects are **independent** — marking `Shown` does not affect `Alpha`.
- Test with `FrameScriptObject:HasSecretAspect(aspect)`.

### Example

```lua
-- SetText with a secret marks the "Text" aspect
local name = UnitName("target")  -- may be secret in combat
myFontString:SetText(name)       -- marks "Text" aspect
myFontString:GetText()           -- now returns a secret value
```

### Secret Anchors

- A widget marked as having secret values (not just aspects) also marks all **anchor/position** data as secret.
- This **propagates downward** through the anchor chain (if B is anchored to A, and A has secret anchors, B inherits them).
- Does NOT propagate upward.
- Test with `ScriptRegion:IsAnchoringSecret()`.
- Clearing anchor points can reset this state.

### Clearing Secret State

- Call `FrameScriptObject:SetToDefaults()` to remove ALL secret state and aspects, returning the widget to its freshly-created state.
- There is no way to selectively clear individual aspects.

### Preventing Secrets

- `FrameScriptObject:SetPreventSecretValues(true)` — prevents the widget from accepting secret values (will error if you try).
- `FrameScriptObject:IsPreventingSecretValues()` — test if prevention is active.

### Constant Accessors

- Some APIs are marked as **constant secret accessors** (e.g., `ScriptRegion:GetHeight(ignoreRect)`).
- Calling them with a secret argument does NOT mark the widget, but the **return values will be secret** if any input was secret.

---

## 3. Conditional Secrets (Secret Predicates)

Many APIs only return secrets **under certain conditions**. These are documented with **Secret Predicates**:

| Predicate | Meaning |
|-----------|---------|
| `SecretReturns = true` | Always returns secret values |
| `SecretWhenUnitIdentityRestricted` | Returns secrets for non-player/pet units while in combat |
| `ConditionalSecret = true` | Some return values are conditionally secret |
| `SecretWhenInCombat` | Returns secrets during combat |

### Examples of Conditional Behavior

- `UnitName(unit)` — returns secrets for non-player/pet units when unit identity is restricted (combat in instances).
- `UnitClass(unit)` — first return is conditionally secret.
- `UnitHealth(unit)` — returns secret values (health is secret to prevent addon decision-making).
- `UnitCastingInfo(unit)` — `notInterruptible` field is now nilable (`Nilable: false -> true`), and returns a new `castBarID`.

### Checking Restriction State

- Use `C_RestrictedActions` namespace to test current addon restriction states.
- Use `C_Secrets` namespace to evaluate secret predicates directly.

---

## 4. Curves, ColorCurves, and Durations — Working With Secrets

Since addons cannot do math on secrets, Blizzard provides new **ScriptObjects** to process secret values natively:

### CurveObject / ColorCurveObject

- Create with `C_CurveUtil.CreateCurve()` and `C_CurveUtil.CreateColorCurve()`.
- ColorCurves can do operations like mapping health percentage to color (green → red for 100% → 0%) **without the addon seeing the actual value**.
- Pass secret values through curves to produce visual output.

### DurationObject

- Create with `C_DurationUtil.CreateDuration()`.
- Allows performing time-based calculations on potentially secret duration data.
- Can be passed to `StatusBar:SetTimerDuration()`.
- Replaces patterns where addons previously did manual math on cooldown/duration numbers.

---

## 5. Combat Log Events — NO LONGER AVAILABLE TO ADDONS

This is one of the most impactful changes in 12.0.0.

### What Changed

- **`COMBAT_LOG_EVENT_UNFILTERED` (CLEU) is no longer available to addons.**
- The old `COMBAT_LOG_EVENT` event is also unavailable.
- `CombatLogGetCurrentEventInfo()` is no longer usable by tainted code.
- Combat Log chat tab messages are now **KStrings** (unparseable escape sequences) to prevent addons from extracting combat data from chat.
- A new **`COMBAT_LOG_EVENT_INTERNAL_UNFILTERED`** event exists but is restricted.

### New Combat Log Events (Addon-Facing)

- `COMBAT_LOG_MESSAGE` — provides formatted combat log messages as display text only.
- `COMBAT_LOG_ENTRIES_CLEARED` — fires when combat log entries are cleared.
- `COMBAT_LOG_APPLY_FILTER_SETTINGS` — fires when filter settings change.
- `COMBAT_LOG_REFILTER_ENTRIES` — fires when entries need refiltering.
- `COMBAT_LOG_MESSAGE_LIMIT_CHANGED` — fires when message limit changes.

### What This Means for Addons

- **DO NOT** write code that registers for `COMBAT_LOG_EVENT_UNFILTERED` and parses combat data — it will not work.
- **DO NOT** use `CombatLogGetCurrentEventInfo()` — it is unavailable to addon code.
- Addons like damage meters must now use the new `C_DamageMeter` API or the built-in damage meter system.
- Boss mod addons (DBM, BigWigs, etc.) are fundamentally affected and must use new patterns.

### New Encounter Events (Replacement)

- `ENCOUNTER_STATE_CHANGED` — fires when encounter state changes.
- `ENCOUNTER_WARNING` — fires for encounter warnings (replaces addon-generated warnings).
- `ENCOUNTER_TIMELINE_EVENT_*` — a family of new events for encounter timeline tracking.
- `COMMENTATOR_COMBAT_EVENT` — for spectator/commentator use only.

---

## 6. Instance Restrictions — Chat and Addon Communication

When the player is **inside an instance** (dungeon, raid, arena, battleground), additional restrictions apply:

### Nameplate and Unit Info Restrictions

- Nameplates cannot be altered by addons while in an instance. This includes changing number of buffs/debuffs shown, their size, or their position & position of elements within the unit frame.
- Color, size, text font, and other visual aspects of nameplates can still be customized, but not based on unit information that becomes secret.

### Chat Messages Become Secret

- Chat messages received while in an instance are delivered as **secret values**.
- Addons cannot parse or make decisions based on chat content during instanced content.

### Addon Communication Blocked

- **`SendAddonMessage()` is blocked** while inside an instance.
- Addons CANNOT send communications to other players (via addon messages OR regular chat programmatically) while in an instance.
- `Enum.SendAddonMessageResult` now includes `AddOnMessageLockdown` and `TargetOffline` values.
- Club APIs have been patched to prevent workarounds for addon communication.

### CRITICAL: Do Not Rely on Addon Comms in Instances

```lua
-- WRONG — This will fail silently or error in instances:
C_ChatInfo.SendAddonMessage("MyAddon", data, "RAID")

-- Addons must be designed to function WITHOUT inter-player communication
-- during instanced content. Pre-instance data sharing is still possible.
```

---

## 7. Removed APIs (138 Global APIs Removed)

A massive number of APIs were removed in 12.0.0. **Do not use any of these in new code.** Key removals include:

### Combat/Unit Functions Removed or Replaced

- Old spell functions (`GetSpellInfo`, `GetSpellCooldown`, `GetSpellTexture`, `GetSpellCharges`, `GetSpellDescription`, `GetSpellCount`, `IsUsableSpell`, etc.) — replaced by `C_Spell.*` in 11.0.0, now fully removed.
- Old spellbook functions (`GetNumSpellTabs`, `GetSpellTabInfo`, `GetSpellBookItemName`) — replaced by `C_SpellBook.*`.
- `IsSpellOverlayed` → `C_SpellActivationOverlay.IsSpellOverlayed`
- `GetMerchantItemInfo` → `C_MerchantFrame.GetItemInfo`
- `ConsolePrint` → `C_Log.LogMessage`
- `message` → `SetBasicMessageDialogText`

### New Namespaces Added (437 APIs)

Major new API namespaces/functions include:

- `C_ActionBar.*` — New comprehensive action bar API (GetActionCooldown, GetActionTexture, GetActionText, HasAction, etc.)
- `C_DamageMeter.*` — Built-in damage meter system (replacement for combat log parsing)
- `C_CurveUtil.*` — Curve/ColorCurve creation for secret value visualization
- `C_DurationUtil.*` — Duration object creation
- `C_RestrictedActions.*` — Query addon restriction states
- `C_Secrets.*` — Direct secret predicate evaluation
- `AbbreviateLargeNumbers`, `AbbreviateNumbers` — Number formatting utilities

---

## 8. New Widget APIs for Secret Handling

### Secret-Related Widget Methods (All New)

| Method | Purpose |
|--------|---------|
| `FrameScriptObject:HasAnySecretAspect()` | Test if any secret aspect is applied |
| `FrameScriptObject:HasSecretAspect(aspect)` | Test for a specific aspect |
| `FrameScriptObject:HasSecretValues()` | Test if the object has secret values |
| `FrameScriptObject:IsPreventingSecretValues()` | Test if secret prevention is active |
| `FrameScriptObject:SetPreventSecretValues(prevent)` | Enable/disable secret prevention |
| `FrameScriptObject:SetToDefaults()` | Clear all secret state |
| `ScriptRegion:IsAnchoringSecret()` | Test if anchor chain has secrets |

### Other Notable New Widget APIs

| Method | Purpose |
|--------|---------|
| `Region:SetAlphaFromBoolean(bool)` | Set alpha from a boolean (secret-compatible) |
| `Region:SetVertexColorFromBoolean(bool)` | Set vertex color from boolean |
| `Cooldown:SetCooldownFromDurationObject(duration)` | Set cooldown from DurationObject |
| `Cooldown:SetCooldownFromExpirationTime(time)` | Set cooldown from expiration time |
| `Cooldown:SetPaused(paused)` | Pause/unpause cooldown |
| `StatusBar:SetTimerDuration(duration)` | Set timer from DurationObject |
| `StatusBar:SetToTargetValue(value)` | Animate to target value |
| `StatusBar:GetInterpolatedValue()` | Get current interpolated value |
| `Frame:RegisterEventCallback(event, callback)` | New event registration pattern |
| `Frame:RegisterUnitEventCallback(event, unit, callback)` | New unit event registration pattern |

---

## 9. Key Event Changes

### New Events (76 Added)

Notable additions:

- `ADDON_RESTRICTION_STATE_CHANGED` — Fires when addon restriction state changes (e.g., entering/leaving an instance).
- `DAMAGE_METER_*` — Events for the built-in damage meter (`COMBAT_SESSION_UPDATED`, `CURRENT_SESSION_UPDATED`, `RESET`).
- `ENCOUNTER_STATE_CHANGED` — Replaces addon combat log parsing for encounter state.
- `ENCOUNTER_WARNING` — Built-in encounter warnings.
- `ENCOUNTER_TIMELINE_EVENT_*` — Family of encounter timeline events.
- `FACTION_STANDING_CHANGED` — New reputation event.

### Removed Events (8 Removed)

- Several events were consolidated or removed as part of the combat log changes.

### Modified Events

- `UnitCastingInfo` — `notInterruptible` is now nilable (was non-nilable), added `castBarID` return.
- `UnitChannelInfo` — argument renamed `unitToken` → `unit`, `notInterruptible` now nilable.

---

## 10. Deprecated 11.x APIs (Now Fully Removed)

These were deprecated during The War Within (11.x) and are **completely removed** in 12.0.0:

| Removed | Replacement |
|---------|-------------|
| `GetSpellInfo()` | `C_Spell.GetSpellInfo()` |
| `GetSpellCooldown()` | `C_Spell.GetSpellCooldown()` |
| `GetSpellTexture()` | `C_Spell.GetSpellTexture()` |
| `GetSpellCharges()` | `C_Spell.GetSpellCharges()` |
| `GetSpellDescription()` | `C_Spell.GetSpellDescription()` |
| `GetSpellCount()` | `C_Spell.GetSpellCastCount()` |
| `IsUsableSpell()` | `C_Spell.IsSpellUsable()` |
| `IsSpellOverlayed()` | `C_SpellActivationOverlay.IsSpellOverlayed()` |
| `GetNumSpellTabs()` | `C_SpellBook.GetNumSpellBookSkillLines()` |
| `GetSpellTabInfo()` | `C_SpellBook.GetSpellBookSkillLineInfo()` |
| `GetSpellBookItemName()` | `C_SpellBook.GetSpellBookItemName()` |
| `GetMerchantItemInfo()` | `C_MerchantFrame.GetItemInfo()` |
| `C_ChallengeMode.GetCompletionInfo()` | `C_ChallengeMode.GetChallengeCompletionInfo()` |
| `C_TaskQuest.GetQuestsForPlayerByMapID()` | `C_TaskQuest.GetQuestsOnMap()` |
| `C_QuestLog.IsQuestRepeatableType()` | `C_QuestLog.IsRepeatableQuest()` |
| `ConsolePrint()` | `C_Log.LogMessage()` |
| `message()` | `SetBasicMessageDialogText()` |
| `IsArtifactRelicItem()` | `C_ItemSocketInfo.IsArtifactRelicItem()` |

---

## 11. Structure/Enum Changes

### Key Enum Changes

- `Enum.SendAddonMessageResult` — Added `AddOnMessageLockdown`, `TargetOffline`.
- `Enum.TradeskillRecipeType` — Removed `Recraft`.
- `Enum.EditModeSystem` — Added `PersonalResourceDisplay`, `EncounterEvents`, `DamageMeter`.
- `Enum.TooltipDataLineType` — Added `SpellPassive`, `SpellDescription`.

### Key Structure Changes

- `SpellCooldownInfo` — Added `timeUntilEndOfStartRecovery`, `isOnGCD`.
- `CraftingReagentInfo` — Changed `itemID` → `reagent` field name.
- `CraftingOrderReagentInfo` — Changed `reagent` → `reagentInfo` field name.
- `MajorFactionData` — Added `description`, `highlights`, `playerCompanionID`.

---

## 12. Design Philosophy — Why These Changes Exist

Understanding the intent helps write compatible addons:

1. **Addons should NOT provide competitive advantage in combat.** Any time an addon can "solve" encounter mechanics or calculate optimal rotations, it creates an unfair gap between addon users and non-users.

2. **Look-and-feel customization is explicitly allowed.** Addons can still customize UI appearance, size, position, color, and texture of all elements — as long as those changes aren't driven by real-time combat logic.

3. **Three specific capabilities are targeted:**
   - Making encounter decisions for the player (what to dodge, where to stand, who to heal).
   - Creating truly optimal rotation helpers (basic rotation guidance is fine; perfect optimization is not).
   - Simplifying/colorizing enemy names and casts based on priority (e.g., showing "Healer" instead of NPC name, color-coding kick targets).

4. **Built-in replacements exist** for most restricted functionality:
   - Built-in Damage Meter system
   - Built-in Combat Audio Alert (CAA) system for accessibility
   - Improved nameplates
   - Cooldown Manager
   - External Defensives display
   - Encounter Events panel

---

## 13. Practical Patterns for 12.0.0-Compatible Addons

### Pattern: Displaying Health Bars

```lua
-- Use Curves to set color based on health percentage
local colorCurve = C_CurveUtil.CreateColorCurve()
-- Configure green→red gradient for 100%→0% (setup happens once)

local healthBar = CreateFrame("StatusBar", nil, parent)
-- In update:
local hp = UnitHealth(unit)           -- secret value
local maxHp = UnitHealthMax(unit)     -- secret value
healthBar:SetMinMaxValues(0, maxHp)   -- accepts secrets
healthBar:SetValue(hp)                -- accepts secrets
```

### Pattern: Displaying Unit Names

```lua
local name = UnitName(unit)          -- may be secret in combat
myFontString:SetText(name)           -- widget accepts secrets
-- DO NOT try to read name back or compare it
```

### Pattern: Cooldown Display

```lua
local cooldown = CreateFrame("Cooldown", nil, parent, "CooldownFrameTemplate")
local duration = C_DurationUtil.CreateDuration()
-- Use DurationObject-based APIs instead of manual math
cooldown:SetCooldownFromDurationObject(duration)
```

### Pattern: Checking If Restrictions Are Active

```lua
-- Use C_RestrictedActions to check current state
-- Adapt behavior based on whether restrictions are active
-- Design addons to gracefully degrade when restrictions apply
```

---

## 14. Common Mistakes to Avoid

| Mistake | Why It Fails | Fix |
|---------|-------------|-----|
| Using `COMBAT_LOG_EVENT_UNFILTERED` | No longer available to addons | Use `COMBAT_LOG_MESSAGE` or built-in damage meter |
| Comparing `UnitHealth()` return values | Returns secret — comparison errors | Pass directly to `StatusBar:SetValue()` |
| Sending addon messages in instances | Blocked by `AddOnMessageLockdown` | Design to work without in-instance comms |
| Using old `GetSpellInfo()` | Fully removed in 12.0.0 | Use `C_Spell.GetSpellInfo()` |
| Parsing combat log chat text | Messages are now KStrings | Cannot be parsed; use official APIs |
| Doing arithmetic on cooldown durations | May be secret values | Use `DurationObject` APIs |
| Reading widget values after setting secrets | Getters return secrets after aspect is applied | Use `SetToDefaults()` to clear, or design without reading back |
| Branching on `UnitName()` for enemy identification | Secret when unit identity restricted | Cannot identify specific enemies programmatically in combat |
