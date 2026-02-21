---
name: wow-api-spells-abilities
description: "Complete reference for WoW Retail Spell, SpellBook, ActionBar, Cooldown, Totem, and Shapeshifting APIs. Covers C_Spell info/cooldown/usability/range, C_SpellBook navigation/slot queries, C_ActionBar slot management/state/overrides, C_SpellActivationOverlay procs, C_SpellDiminish DR tracking, C_CooldownViewer, C_AssistedCombat rotation helpers, totem queries, shapeshift forms, casting/channeling functions, flyouts, spell confirmation, and global spell category functions. Use when working with spells, abilities, action bars, cooldowns, casting, totems, shapeshift forms, spell procs, or diminishing returns."
---

# Spell & Ability API (Retail — Patch 12.0.0)

Comprehensive reference for all Spell, SpellBook, ActionBar, Cooldown, Totem, Shapeshifting, and related APIs. Covers spell information, cooldowns, usability, range checking, spellbook navigation, action bar slot management, spell procs, diminishing returns, assisted combat, and global spell functions.

> **Source of truth:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#Spell
> **SpellBook:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#SpellBook
> **ActionBar:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#ActionBar
> **Current as of:** Patch 12.0.0 (Build 65655) — January 28, 2026
> **Scope:** Retail only. No deprecated or removed functions.

## Scope

This skill covers these API systems:

- **C_Spell** — Core spell information, cooldowns, charges, usability, range, type checks
- **C_SpellBook** — Spellbook navigation, skill lines, slot queries, spell lookup
- **C_ActionBar** — Action bar slot management, state queries, bar pages, overrides
- **C_SpellActivationOverlay** — Spell proc/activation glow detection
- **C_SpellDiminish** — Diminishing returns tracking for crowd control
- **C_CooldownViewer** — Cooldown viewer categories and layout
- **C_AssistedCombat** — Assisted combat (rotation helper) integration
- **Totem** — Totem query functions (GetTotemInfo, DestroyTotem)
- **Shapeshifting** — Form/stance functions (GetShapeshiftForm, GetShapeshiftFormInfo)
- **Global Spell Functions** — CastSpellByName, CastSpellByID, SpellIsTargeting, etc.

## When to Use This Skill

Use this skill when you need to:
- Query spell info: name, description, icon, subtext, link, power cost
- Check spell cooldowns, charges, or GCD state
- Determine if a spell is usable, in range, or on cooldown
- Navigate the spellbook: enumerate skill lines, find spell slots, check known spells
- Manage action bars: query action type, usability, cooldown, texture for a slot
- Detect action bar pages, bonus bars, override bars, vehicle bars
- Check for spell procs / activation overlays (glowing buttons)
- Track diminishing returns on crowd control effects
- Query totem state, duration, or destroy totems
- Check or cast shapeshift forms and stances
- Cast spells programmatically (protected functions)
- Handle spell targeting (SpellIsTargeting, SpellTargetUnit, SpellStopCasting)
- Use the assisted combat (rotation helper) system
- Work with flyout menus and multi-cast totem spells

## Reference Files

| Reference | Contents |
|-----------|----------|
| [SPELLS-CORE.md](references/SPELLS-CORE.md) | C_Spell — spell info, cooldowns, charges, usability, range, type checks |
| [SPELLBOOK.md](references/SPELLBOOK.md) | C_SpellBook — spellbook navigation, skill lines, slot queries |
| [ACTIONBAR.md](references/ACTIONBAR.md) | C_ActionBar — action bar slots, state, pages, overrides, pet/vehicle bars |
| [COOLDOWNS-CASTING.md](references/COOLDOWNS-CASTING.md) | Cooldowns, casting functions, spell targeting, procs, DR, assisted combat |
| [TOTEM-SHAPESHIFT.md](references/TOTEM-SHAPESHIFT.md) | Totem functions, shapeshifting/stances, global spell casting functions |

---

## C_Spell — Core Spell API (Quick Reference)

The `C_Spell` namespace provides direct access to spell data by `spellIdentifier` — which can be a `spellID` (number) or `spellName` (string).

> **Wiki:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#Spell

### Key Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Spell.GetSpellInfo(spellIdentifier)` | `spellInfo` table | Primary spell data (name, icon, castTime, etc.) |
| `C_Spell.GetSpellName(spellIdentifier)` | `name` | Localized spell name |
| `C_Spell.GetSpellDescription(spellIdentifier)` | `description` | Tooltip description text |
| `C_Spell.GetSpellTexture(spellIdentifier)` | `iconID, originalIconID` | Spell icon texture |
| `C_Spell.GetSpellSubtext(spellIdentifier)` | `subtext` | Rank or specialization label |
| `C_Spell.GetSpellLink(spellIdentifier [, glyphID])` | `spellLink` | Clickable hyperlink |
| `C_Spell.DoesSpellExist(spellIdentifier)` | `spellExists` | Validates a spell ID/name |
| `C_Spell.GetSpellIDForSpellIdentifier(spellIdentifier)` | `spellID` | Resolves spell name → ID |
| `C_Spell.GetBaseSpell(spellIdentifier [, spec])` | `baseSpellID` | Unwraps overrides to base spell |
| `C_Spell.GetOverrideSpell(spellIdentifier [, spec [, onlyKnown [, ignoreOverrideID]]])` | `overrideSpellID` | Gets current override for a spell |

### Cooldowns & Charges

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Spell.GetSpellCooldown(spellIdentifier)` | `spellCooldownInfo` | Start time, duration, enabled, modRate |
| `C_Spell.GetSpellCooldownDuration(spellIdentifier)` | `duration` | Remaining cooldown in seconds |
| `C_Spell.GetSpellCharges(spellIdentifier)` | `chargeInfo` | Charges, maxCharges, start, duration |
| `C_Spell.GetSpellChargeDuration(spellIdentifier)` | `duration` | Charge recharge duration |
| `C_Spell.GetSpellLossOfControlCooldown(spellIdentifier)` | `startTime, duration` | LoC lockout timing |
| `C_Spell.GetSpellLossOfControlCooldownDuration(spellIdentifier)` | `duration` | Remaining LoC duration |

### Usability & Range

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Spell.IsSpellUsable(spellIdentifier)` | `isUsable, insufficientPower` | Can be cast now? |
| `C_Spell.IsSpellInRange(spellIdentifier [, targetUnit])` | `inRange` | Target in range? |
| `C_Spell.SpellHasRange(spellIdentifier)` | `hasRange` | Does the spell have range? |
| `C_Spell.IsSpellDisabled(spellIdentifier)` | `disabled` | Is spell disabled? |
| `C_Spell.GetSpellCastCount(spellIdentifier)` | `castCount` | Number of available casts |

### Type Checks

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Spell.IsSpellPassive(spellIdentifier)` | `isPassive` | Passive ability? |
| `C_Spell.IsSpellHarmful(spellIdentifier)` | `isHarmful` | Offensive spell? |
| `C_Spell.IsSpellHelpful(spellIdentifier)` | `isHelpful` | Beneficial spell? |
| `C_Spell.IsAutoAttackSpell(spellIdentifier)` | `isAutoAttack` | Auto-attack? |
| `C_Spell.IsAutoRepeatSpell(spellIdentifier)` | `isAutoRepeat` | Auto-repeat (e.g., Auto Shot)? |
| `C_Spell.IsRangedAutoAttackSpell(spellIdentifier)` | `isRangedAutoAttack` | Ranged auto-attack? |
| `C_Spell.IsCurrentSpell(spellIdentifier)` | `isCurrentSpell` | Currently being cast? |
| `C_Spell.IsConsumableSpell(spellIdentifier)` | `consumable` | Consumes a resource on use? |
| `C_Spell.IsPressHoldReleaseSpell(spellIdentifier)` | `isPressHoldRelease` | Empowered spell? |
| `C_Spell.IsClassTalentSpell(spellIdentifier)` | `isClassTalent` | From the talent tree? |
| `C_Spell.IsPvPTalentSpell(spellIdentifier)` | `isPvPTalent` | PvP talent? |
| `C_Spell.IsSpellCrowdControl(spellIdentifier)` | `isCrowdControl` | CC effect? |
| `C_Spell.IsSpellImportant(spellIdentifier)` | `isImportant` | Marked as important? |
| `C_Spell.IsPriorityAura(spellID)` | `isHighPriority` | High-priority display aura? |
| `C_Spell.IsSelfBuff(spellID)` | `hasSelfEffectsOnly` | Only affects self? |
| `C_Spell.IsExternalDefensive(spellID)` | `isExternalDefensive` | External defensive? |

### Power Cost & Data

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Spell.GetSpellPowerCost(spellIdentifier)` | `powerCosts` table | Resources required to cast |
| `C_Spell.GetSpellLevelLearned(spellIdentifier)` | `levelLearned` | Level at which spell is learned |
| `C_Spell.GetSpellSkillLineAbilityRank(spellIdentifier)` | `rank` | Rank for profession recipes |
| `C_Spell.GetSpellMaxCumulativeAuraApplications(spellID)` | `cumulativeAura` | Max stacks |
| `C_Spell.GetAuraStatChanges(spellID)` | `healthChange, powerTypeChanges` | Stat effects of an aura |
| `C_Spell.GetDeadlyDebuffInfo(spellIdentifier)` | `deadlyDebuffInfo` | Deadly debuff display data |
| `C_Spell.GetSpellQueueWindow()` | `result` | Spell queue window (ms) |

### Spell Manipulation

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Spell.CancelSpellByID(spellID)` | — | Cancel a channeled/cast spell |
| `C_Spell.PickupSpell(spellIdentifier)` | — | Attach spell to cursor |
| `C_Spell.RequestLoadSpellData(spellIdentifier)` | — | Request async spell data load |
| `C_Spell.IsSpellDataCached(spellIdentifier)` | `isCached` | Is data ready for query? |
| `C_Spell.EnableSpellRangeCheck(spellIdentifier, enable)` | — | Enable/disable range checking |
| `C_Spell.SetSpellAutoCastEnabled(spellIdentifier, enabled)` | — | Toggle pet spell autocast |
| `C_Spell.ToggleSpellAutoCast(spellIdentifier)` | — | Toggle pet spell autocast |
| `C_Spell.GetSpellAutoCast(spellIdentifier)` | `autoCastAllowed, autoCastEnabled` | Autocast state |

### Visibility & Display

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Spell.GetVisibilityInfo(spellID, visibilityType)` | `hasCustom, alwaysShowMine, showForMySpec` | Aura display visibility rules |
| `C_Spell.GetSpellDisplayCount(spellIdentifier [, maxDisplayCount [, replacementString]])` | `displayCount` | Display count for stacking |

### Targeting & Trade

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Spell.TargetSpellIsEnchanting()` | `isEnchanting` | Current targeting spell is enchant? |
| `C_Spell.TargetSpellJumpsUpgradeTrack()` | `jumpsUpgradeTrack` | Upgrade track jump? |
| `C_Spell.TargetSpellReplacesBonusTree()` | `result` | Replaces bonus loot tree? |
| `C_Spell.GetSpellTradeSkillLink(spellIdentifier)` | `spellLink` | Trade skill recipe link |

---

## C_SpellBook — Spellbook Navigation (Quick Reference)

The `C_SpellBook` namespace manages the spellbook UI, skill lines, and per-slot queries. Functions take `(spellBookItemSlotIndex, spellBookItemSpellBank)` where `spellBank` is `Enum.SpellBookSpellBank.Player` or `Enum.SpellBookSpellBank.Pet`.

> **Wiki:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#SpellBook

### Key Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `C_SpellBook.GetNumSpellBookSkillLines()` | `numSkillLines` | Number of spellbook tabs |
| `C_SpellBook.GetSpellBookSkillLineInfo(skillLineIndex)` | `skillLineInfo` | Tab name, icon, offset, count |
| `C_SpellBook.GetSpellBookItemInfo(slot, bank)` | `spellBookItemInfo` | Detailed spell/flyout info for a slot |
| `C_SpellBook.GetSpellBookItemType(slot, bank)` | `itemType, actionID, spellID` | Type: SPELL, FLYOUT, FUTURESPELL, PETACTION |
| `C_SpellBook.GetSpellBookItemName(slot, bank)` | `name, subName` | Localized name of slot |
| `C_SpellBook.GetSpellBookItemTexture(slot, bank)` | `iconID` | Icon for slot |
| `C_SpellBook.GetSpellBookItemDescription(slot, bank)` | `description` | Tooltip text |
| `C_SpellBook.GetSpellBookItemLink(slot, bank [, glyphID])` | `spellLink` | Hyperlink |
| `C_SpellBook.GetSpellBookItemLevelLearned(slot, bank)` | `levelLearned` | Level learned |
| `C_SpellBook.FindSpellBookSlotForSpell(spellIdentifier [, includeHidden [, includeFlyouts [, includeFutureSpells [, includeOffSpec]]]])` | `slotIndex, bank` | Find slot for a spell |
| `C_SpellBook.IsSpellKnown(spellID [, spellBank])` | `isKnown` | Does the player know the spell? |
| `C_SpellBook.IsSpellInSpellBook(spellID [, spellBank [, includeOverrides]])` | `isInSpellBook` | Is it in the spellbook? |
| `C_SpellBook.IsSpellKnownOrInSpellBook(spellID [, spellBank [, includeOverrides]])` | `isKnownOrInSpellBook` | Known OR in spellbook? |

### Slot Usability & State

| Function | Returns | Description |
|----------|---------|-------------|
| `C_SpellBook.IsSpellBookItemUsable(slot, bank)` | `isUsable, insufficientPower` | Can cast from this slot? |
| `C_SpellBook.IsSpellBookItemPassive(slot, bank)` | `isPassive` | Passive ability? |
| `C_SpellBook.IsSpellBookItemOffSpec(slot, bank)` | `isOffSpec` | Belongs to inactive spec? |
| `C_SpellBook.IsSpellBookItemHarmful(slot, bank)` | `isHarmful` | Harmful to targets? |
| `C_SpellBook.IsSpellBookItemHelpful(slot, bank)` | `isHelpful` | Helpful to targets? |
| `C_SpellBook.IsSpellBookItemInRange(slot, bank [, targetUnit])` | `inRange` | In range of target? |
| `C_SpellBook.SpellBookItemHasRange(slot, bank)` | `hasRange` | Has range requirement? |
| `C_SpellBook.IsAutoAttackSpellBookItem(slot, bank)` | `isAutoAttack` | Auto-attack entry? |
| `C_SpellBook.IsRangedAutoAttackSpellBookItem(slot, bank)` | `isRangedAutoAttack` | Ranged auto-attack? |
| `C_SpellBook.IsClassTalentSpellBookItem(slot, bank)` | `isClassTalent` | Class talent? |
| `C_SpellBook.IsPvPTalentSpellBookItem(slot, bank)` | `isPvPTalent` | PvP talent? |

### Slot Cooldowns & Charges

| Function | Returns | Description |
|----------|---------|-------------|
| `C_SpellBook.GetSpellBookItemCooldown(slot, bank)` | `spellCooldownInfo` | Cooldown for slot |
| `C_SpellBook.GetSpellBookItemCooldownDuration(slot, bank)` | `duration` | Remaining cooldown |
| `C_SpellBook.GetSpellBookItemCharges(slot, bank)` | `chargeInfo` | Charge info |
| `C_SpellBook.GetSpellBookItemChargeDuration(slot, bank)` | `duration` | Charge recharge time |
| `C_SpellBook.GetSpellBookItemCastCount(slot, bank)` | `castCount` | Available casts |
| `C_SpellBook.GetSpellBookItemLossOfControlCooldown(slot, bank)` | `startTime, duration` | LoC lockout |
| `C_SpellBook.GetSpellBookItemLossOfControlCooldownDuration(slot, bank)` | `duration` | Remaining LoC |

### Spell Lookup

| Function | Returns | Description |
|----------|---------|-------------|
| `C_SpellBook.FindBaseSpellByID(spellID)` | `baseSpellID` | Resolve to base spell |
| `C_SpellBook.FindSpellOverrideByID(spellID)` | `overrideSpellID` | Get current override |
| `C_SpellBook.GetCurrentLevelSpells(level)` | `spellIDs` | Spells learned at a level |
| `C_SpellBook.GetSkillLineIndexByID(skillLineID)` | `skillIndex` | Skill line index by ID |
| `C_SpellBook.HasPetSpells()` | `numPetSpells, petNameToken` | Does the pet have spells? |
| `C_SpellBook.ContainsAnyDisenchantSpell()` | `contains` | Has disenchant? |
| `C_SpellBook.FindFlyoutSlotBySpellID(spellID)` | `flyoutSlot` | Find flyout containing spell |

### Other Slot Operations

| Function | Returns | Description |
|----------|---------|-------------|
| `C_SpellBook.CastSpellBookItem(slot, bank [, targetSelf])` | — | Cast from spellbook slot |
| `C_SpellBook.PickupSpellBookItem(slot, bank)` | — | Pick up spell to cursor |
| `C_SpellBook.GetSpellBookItemAutoCast(slot, bank)` | `autoCastAllowed, autoCastEnabled` | Autocast state |
| `C_SpellBook.SetSpellBookItemAutoCastEnabled(slot, bank, enabled)` | — | Set autocast |
| `C_SpellBook.ToggleSpellBookItemAutoCast(slot, bank)` | — | Toggle autocast |
| `C_SpellBook.GetSpellBookItemPowerCost(slot, bank)` | `powerCosts` | Resource cost |
| `C_SpellBook.GetSpellBookItemTradeSkillLink(slot, bank)` | `spellLink` | Trade skill link |
| `C_SpellBook.GetSpellBookItemSkillLineIndex(slot, bank)` | `skillLineIndex` | Which skill line tab |

---

## C_ActionBar — Action Bar Slot Management (Quick Reference)

The `C_ActionBar` namespace manages the 120+ action bar slots. Actions are referenced by `actionID` (1–180) or `slotID`.

> **Wiki:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#ActionBar

### Action Slot Layout

| Bar | Slots | Notes |
|-----|-------|-------|
| Main bar | 1–12 | Always visible |
| Bar 2 (Bottom Left) | 13–24 | Toggled via settings |
| Bar 3 (Bottom Right) | 25–36 | Toggled via settings |
| Bar 4 (Right) | 37–48 | Toggled via settings |
| Bar 5 (Right 2) | 49–60 | Toggled via settings |
| Bars 6–10 | 61–120 | Additional bars |
| StanceBar pages | 121–180 | Stance-specific bars |

### Core Queries

| Function | Returns | Description |
|----------|---------|-------------|
| `C_ActionBar.HasAction(actionID)` | `hasAction` | Is something in this slot? |
| `C_ActionBar.GetSpell(actionID)` | `spellID` | Spell in slot (nil if not a spell) |
| `C_ActionBar.GetActionTexture(actionID)` | `textureFileID` | Icon for the action |
| `C_ActionBar.GetActionText(actionID)` | `text` | Display text (macros) |
| `C_ActionBar.GetActionCooldown(actionID)` | `cooldownInfo` | Cooldown data |
| `C_ActionBar.GetActionCooldownDuration(actionID)` | `duration` | Remaining cooldown |
| `C_ActionBar.GetActionChargeDuration(actionID)` | `duration` | Charge recharge time |
| `C_ActionBar.GetActionCharges(actionID)` | `chargeInfo` | Charge state |
| `C_ActionBar.IsUsableAction(actionID)` | `isUsable, isLackingResources` | Can use? |
| `C_ActionBar.IsActionInRange(actionID [, target])` | `isInRange` | Target in range? |

### Action State Checks

| Function | Returns | Description |
|----------|---------|-------------|
| `C_ActionBar.IsCurrentAction(actionID)` | `isCurrentAction` | Being cast now? |
| `C_ActionBar.IsAttackAction(actionID)` | `isAttackAction` | Auto-attack? |
| `C_ActionBar.IsAutoRepeatAction(actionID)` | `isAutoRepeatAction` | Auto-repeat? |
| `C_ActionBar.IsConsumableAction(actionID)` | `isConsumableAction` | Consumable? |
| `C_ActionBar.IsEquippedAction(actionID)` | `isEquippedAction` | Equipped item? |
| `C_ActionBar.IsStackableAction(actionID)` | `isStackableAction` | Stackable item? |
| `C_ActionBar.IsItemAction(actionID)` | `isItemAction` | Item action? |
| `C_ActionBar.IsHarmfulAction(actionID, useNeutral)` | `isHarmful` | Harmful? |
| `C_ActionBar.IsHelpfulAction(actionID, useNeutral)` | `isHelpful` | Helpful? |
| `C_ActionBar.IsInterruptAction(slotID)` | `isInterruptAction` | Interrupt? |
| `C_ActionBar.IsAssistedCombatAction(slotID)` | `isAssistedCombat` | Assisted combat action? |
| `C_ActionBar.HasRangeRequirements(actionID)` | `hasRangeRequirements` | Has range? |

### Bar Pages & Overrides

| Function | Returns | Description |
|----------|---------|-------------|
| `C_ActionBar.GetActionBarPage()` | `currentPage` | Current page (1–6) |
| `C_ActionBar.SetActionBarPage(pageIndex)` | — | Switch page |
| `C_ActionBar.GetBonusBarIndex()` | `bonusBarIndex` | Class-specific bonus bar |
| `C_ActionBar.GetBonusBarOffset()` | `bonusBarOffset` | Offset for bonus bar |
| `C_ActionBar.HasBonusActionBar()` | `hasBonusActionBar` | Has bonus bar? |
| `C_ActionBar.GetOverrideBarIndex()` | `overrideBarIndex` | Override bar index |
| `C_ActionBar.GetOverrideBarSkin()` | `textureFileID` | Override bar texture |
| `C_ActionBar.HasOverrideActionBar()` | `hasOverrideActionBar` | Override active? |
| `C_ActionBar.GetExtraBarIndex()` | `extraBarIndex` | Extra action button bar |
| `C_ActionBar.HasExtraActionBar()` | `hasExtraActionBar` | Extra bar active? |
| `C_ActionBar.GetVehicleBarIndex()` | `vehicleBarIndex` | Vehicle bar index |
| `C_ActionBar.HasVehicleActionBar()` | `hasVehicleActionBar` | In vehicle? |
| `C_ActionBar.GetTempShapeshiftBarIndex()` | `tempShapeshiftBarIndex` | Temp shapeshift bar |
| `C_ActionBar.HasTempShapeshiftActionBar()` | `hasTempShapeshiftActionBar` | Has temp form bar? |
| `C_ActionBar.GetMultiCastBarIndex()` | `multiCastBarIndex` | Multi-cast bar (totem) |
| `C_ActionBar.ShouldOverrideBarShowHealthBar()` | `showHealthBar` | Show health bar? |
| `C_ActionBar.ShouldOverrideBarShowManaBar()` | `showManaBar` | Show mana bar? |
| `C_ActionBar.IsPossessBarVisible()` | `isPossessBarVisible` | Possess bar visible? |

### Display & Count

| Function | Returns | Description |
|----------|---------|-------------|
| `C_ActionBar.GetActionDisplayCount(actionID [, maxDisplayCount [, replacementString]])` | `displayCount` | Display count for stacking |
| `C_ActionBar.GetActionUseCount(actionID)` | `count` | Remaining uses |
| `C_ActionBar.GetActionAutocast(actionID)` | `autoCastAllowed, autoCastEnabled` | Autocast state |
| `C_ActionBar.GetActionLossOfControlCooldown(actionID)` | `startTime, duration` | LoC cooldown |
| `C_ActionBar.GetActionLossOfControlCooldownDuration(actionID)` | `duration` | Remaining LoC |

### Spell ↔ Action Lookups

| Function | Returns | Description |
|----------|---------|-------------|
| `C_ActionBar.FindSpellActionButtons(spellID)` | `slots` | Find all slots containing a spell |
| `C_ActionBar.HasSpellActionButtons(spellID)` | `hasButtons` | Is spell on any bar? |
| `C_ActionBar.IsOnBarOrSpecialBar(spellID)` | `isOnBar` | On any bar or special bar? |
| `C_ActionBar.FindFlyoutActionButtons(flyoutID)` | `slots` | Find flyout button slots |
| `C_ActionBar.HasFlyoutActionButtons(flyoutID)` | `hasFlyoutButtons` | Flyout on bar? |
| `C_ActionBar.FindPetActionButtons(petActionID)` | `slots` | Pet action on bar? |
| `C_ActionBar.HasPetActionButtons(petActionID)` | `hasPetButtons` | Pet action exists? |
| `C_ActionBar.FindAssistedCombatActionButtons()` | `slots` | Assisted combat slots |
| `C_ActionBar.HasAssistedCombatActionButtons()` | `hasButtons` | Has assisted combat? |
| `C_ActionBar.GetPetActionPetBarIndices(petActionID)` | `slots` | Pet bar indices |
| `C_ActionBar.HasPetActionPetBarIndices(petActionID)` | `hasIndices` | Has pet bar indices? |

### Profession & Gear

| Function | Returns | Description |
|----------|---------|-------------|
| `C_ActionBar.GetProfessionQuality(actionID)` | `quality` | Crafting result quality |
| `C_ActionBar.GetProfessionQualityInfo(actionID)` | `info` | Quality info table |
| `C_ActionBar.GetItemActionOnEquipSpellID(actionID)` | `onEquipSpellID` | On-equip spell ID |
| `C_ActionBar.IsEquippedGearOutfitAction(slotID)` | `isEquipped` | Gear outfit equipped? |
| `C_ActionBar.GetBonusBarIndexForSlot(slotID)` | `bonusBarIndex` | Bonus bar for slot |

### Slot Management

| Function | Returns | Description |
|----------|---------|-------------|
| `C_ActionBar.PutActionInSlot(slotID)` | — | Place cursor action into slot |
| `C_ActionBar.RegisterActionUIButton(checkboxFrame, actionID, cooldownFrame)` | — | Register frame for updates |
| `C_ActionBar.UnregisterActionUIButton(checkboxFrame)` | — | Unregister frame |
| `C_ActionBar.ForceUpdateAction(slotID)` | — | Force action update |
| `C_ActionBar.EnableActionRangeCheck(actionID, enable)` | — | Enable/disable range check |
| `C_ActionBar.ToggleAutoCastPetAction(slotID)` | — | Toggle pet autocast |
| `C_ActionBar.IsAutoCastPetAction(slotID)` | `isAutoCastPetAction` | Pet autocast? |
| `C_ActionBar.IsEnabledAutoCastPetAction(slotID)` | `isEnabled` | Pet autocast enabled? |

---

## Auxiliary Namespaces (Quick Reference)

### C_SpellActivationOverlay — Spell Procs

Detects when a spell has a visual activation overlay (glowing border / proc alert).

| Function | Returns | Description |
|----------|---------|-------------|
| `C_SpellActivationOverlay.IsSpellOverlayed(spellID)` | `isOverlayed` | Spell has active proc glow? |

> **Wiki:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#SpellActivationOverlay

### C_SpellDiminish — Diminishing Returns

Tracks diminishing returns (DR) categories for crowd control and interrupt tracking.

| Function | Returns | Description |
|----------|---------|-------------|
| `C_SpellDiminish.GetAllSpellDiminishCategories([ruleset])` | `categories` | All DR categories |
| `C_SpellDiminish.GetSpellDiminishCategoryInfo(category)` | `categoryInfo` | Info for a DR category |
| `C_SpellDiminish.IsSystemSupported()` | `isSupported` | Is DR tracking available? |
| `C_SpellDiminish.ShouldTrackSpellDiminishCategory(category, ruleset)` | `isTracked` | Should this category be tracked? |

> **Wiki:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#SpellDiminishUI

### C_CooldownViewer — Cooldown Display

Provides categorized cooldown data for the cooldown viewer UI.

| Function | Returns | Description |
|----------|---------|-------------|
| `C_CooldownViewer.GetCooldownViewerCategorySet(category [, allowUnlearned])` | `cooldownIDs` | Cooldowns in a category |
| `C_CooldownViewer.GetCooldownViewerCooldownInfo(cooldownID)` | `cooldownInfo` | Cooldown details |
| `C_CooldownViewer.GetLayoutData()` | `data` | Viewer layout state |
| `C_CooldownViewer.GetValidAlertTypes(cooldownID)` | `validAlertTypes` | Valid alert types for cooldown |
| `C_CooldownViewer.IsCooldownViewerAvailable()` | `isAvailable, failureReason` | Is viewer available? |
| `C_CooldownViewer.SetLayoutData(data)` | — | Save layout state |

> **Wiki:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#CooldownViewer

### C_AssistedCombat — Rotation Helper

The Assisted Combat system (new in 12.0) provides suggested spell rotations.

| Function | Returns | Description |
|----------|---------|-------------|
| `C_AssistedCombat.GetActionSpell()` | `spellID` | Current action spell suggestion |
| `C_AssistedCombat.GetNextCastSpell([checkForVisibleButton])` | `spellID` | Next suggested cast |
| `C_AssistedCombat.GetRotationSpells()` | `spellIDs` | All rotation spells |
| `C_AssistedCombat.IsAvailable()` | `isAvailable, failureReason` | Is system available? |

> **Wiki:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#AssistedCombat

### C_LevelLink — Spell Level Lock

Checks if spells or actions are level-locked for scaling content.

| Function | Returns | Description |
|----------|---------|-------------|
| `C_LevelLink.IsActionLocked(actionID)` | `isLocked` | Action locked by level? |
| `C_LevelLink.IsSpellLocked(spellID)` | `isLocked` | Spell locked by level? |

---

## Totem Functions

Totem functions query and manage totem/minion slots. Shamans have 4 totem slots; other classes may have totem-style minions (e.g., Death Knight ghouls, mushrooms).

> **Wiki:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#Totem

| Function | Returns | Description |
|----------|---------|-------------|
| `GetTotemInfo(slot)` | `haveTotem, totemName, startTime, duration, icon, modRate, spellID` | Complete totem info |
| `GetTotemTimeLeft(slot)` | `timeLeft` | Remaining duration (seconds) |
| `GetTotemCannotDismiss(slot)` | `cannotDismiss` | Can this totem be dismissed? |
| `DestroyTotem(slot)` | — | Destroy totem/minion `#protected` |
| `TargetTotem(slot)` | — | Target the totem |

### totem Slot Constants

```lua
EARTH_TOTEM_SLOT  = 2
FIRE_TOTEM_SLOT   = 1
WATER_TOTEM_SLOT  = 3
AIR_TOTEM_SLOT    = 4
```

---

## Shapeshifting / Stances

Manages shapeshift forms (Druid forms, Warrior stances, Rogue stealth, Paladin auras, etc.).

> **Wiki:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#Shapeshifting  
> **Category:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API (Shapeshifting section)

| Function | Returns | Description |
|----------|---------|-------------|
| `GetNumShapeshiftForms()` | `numForms` | Number of available forms |
| `GetShapeshiftForm([flag])` | `index` | Current form (0 = none) |
| `GetShapeshiftFormID()` | `index` | Form ID of current form |
| `GetShapeshiftFormInfo(index)` | `icon, active, castable, spellID` | Info for a form |
| `GetShapeshiftFormCooldown(index)` | `startTime, duration, isActive` | Cooldown for a form |
| `CancelShapeshiftForm()` | — | Leave current form `#protected` |
| `CastShapeshiftForm(index)` | — | Enter a form `#protected` |

---

## Global Spell Casting Functions

These are category-level functions (not namespaced) for casting, targeting, and confirming spells.

> **Wiki:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API (Spells category)

### Casting (Protected)

| Function | Description |
|----------|-------------|
| `CastSpell(spellIndex, spellbookType)` | Cast from spellbook by index `#protected` |
| `CastSpellByID(spellID [, target])` | Cast by spell ID `#protected` |
| `CastSpellByName(name [, target])` | Cast by name `#protected` |
| `UseAction(slot [, checkCursor [, onSelf]])` | Use action bar slot `#protected` |
| `SpellStopCasting()` | Stop current cast `#protected` |

### Targeting (Protected)

| Function | Description |
|----------|-------------|
| `SpellIsTargeting()` | Is a spell waiting for target selection? |
| `SpellCanTargetUnit(unit)` | Can the pending spell target this unit? |
| `SpellTargetUnit(unit)` | Cast pending spell on unit `#protected` |
| `SpellStopTargeting()` | Cancel pending spell targeting `#protected` |
| `SpellTargetItem(item)` | Cast pending spell on item `#protected` |
| `SpellCanTargetItem()` | Can pending spell target an item? |
| `SpellCanTargetItemID()` | Can pending spell target an item ID? |
| `SpellCanTargetQuest()` | Can pending spell target a quest? |
| `SpellCancelQueuedSpell()` | Cancel queued spell |
| `CancelSpellByName(name)` | Cancel channeling by name `#nocombat` |

### Spell Confirmation

| Function | Description |
|----------|-------------|
| `AcceptSpellConfirmationPrompt(spellID)` | Accept a spell confirmation dialog |
| `DeclineSpellConfirmationPrompt(spellID)` | Decline a spell confirmation dialog |
| `GetSpellConfirmationPromptsInfo()` | Get pending confirmations |

### Action Button Helpers

| Function | Returns | Description |
|----------|---------|-------------|
| `GetActionInfo(slot)` | `actionType, id, subType` | What's in this action slot? |
| `GetActionBarToggles()` | `bar1..bar7` | Which extra bars are visible |
| `SetActionBarToggles(bar1..bar7, alwaysShow)` | — | Set visibility of extra bars |
| `PetHasActionBar()` | `hasActionBar` | Does pet have an action bar? |
| `GetPossessInfo(index)` | `texture, spellID, enabled` | Possession bar info |

### Flyouts

| Function | Returns | Description |
|----------|---------|-------------|
| `GetFlyoutInfo(flyoutID)` | `name, description, numSlots, isKnown` | Flyout menu info |
| `GetFlyoutSlotInfo(flyoutID, slot)` | `flyoutSpellID, overrideSpellID, isKnown, spellName, slotSpecID` | Individual flyout slot |
| `FlyoutHasSpell(flyoutID, spellID)` | `hasSpell` | Does flyout contain spell? |
| `GetNumFlyouts()` | count | Total flyout count |
| `FindSpellBookSlotBySpellID(spellID [, isPet])` | slot | Legacy slot lookup |

### Combat Pet Actions

| Function | Returns | Description |
|----------|---------|-------------|
| `CastPetAction(index [, target])` | — | Cast pet action `#protected` |
| `GetPetActionCooldown(index)` | `startTime, duration, enable` | Pet action cooldown |
| `GetPetActionInfo(index)` | `name, texture, isToken, isActive, autoCastAllowed, autoCastEnabled, spellID, checksRange, inRange` | Full pet action info |
| `GetPetActionSlotUsable(index)` | `isUsable` | Can use this pet action? |

### Multi-Cast / Totem Bar

| Function | Returns | Description |
|----------|---------|-------------|
| `GetMultiCastTotemSpells(slot)` | `totem1..totem7` | Valid spells for a totem slot |
| `SetMultiCastSpell(actionID, spellID)` | — | Set totem bar spell `#protected` |

### Misc Spell Helpers

| Function | Returns | Description |
|----------|---------|-------------|
| `GetSpellBaseCooldown(spellID)` | `cooldownMS, gcdMS` | Base cooldown in milliseconds |
| `IsSelectedSpellBookItem(spellSlot)` | bool | Is this slot selected? |
| `CancelUnitBuff(unit, buffIndex [, filter])` | — | Remove a buff `#nocombat` |
| `QueryCastSequence(sequence)` | index, item, spell | Preview next step in /castsequence |

---

## Patch 12.0.0 — Secret Values Impact

Spell-related APIs are significantly affected by Secret Values in Patch 12.0.0:

### C_Secrets Predicates for Spells

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Secrets.GetSpellCastSecrecy(spellIdentifier)` | `secrecy` | Cast info secret level |
| `C_Secrets.GetSpellCooldownSecrecy(spellIdentifier)` | `secrecy` | Cooldown data secret level |
| `C_Secrets.GetSpellAuraSecrecy(spellIdentifier)` | `secrecy` | Aura data secret level |
| `C_Secrets.ShouldCooldownsBeSecret()` | `hasSecretCooldowns` | Any cooldowns secret? |
| `C_Secrets.ShouldSpellCooldownBeSecret(spellIdentifier)` | `isCooldownSecret` | This spell's CD secret? |
| `C_Secrets.ShouldSpellAuraBeSecret(spellIdentifier)` | `isAuraSecret` | This spell's aura secret? |
| `C_Secrets.ShouldSpellBookItemCooldownBeSecret(slot, bank)` | `isCooldownSecret` | Spellbook slot CD secret? |
| `C_Secrets.ShouldActionCooldownBeSecret(actionID)` | `isCooldownSecret` | Action slot CD secret? |
| `C_Secrets.ShouldTotemSlotBeSecret(slot)` | `isTotemSecret` | Totem info secret? |
| `C_Secrets.ShouldTotemSpellBeSecret(spellID)` | `isTotemSecret` | Specific totem spell secret? |
| `C_Secrets.ShouldUnitSpellCastBeSecret(unit, spellIdentifier)` | `isSpellCastSecret` | Cast info secret? |
| `C_Secrets.ShouldUnitSpellCastingBeSecret(unit)` | `isSpellCastingSecret` | All cast info for unit secret? |

### What Returns Secrets

- **Cooldown times** — `C_Spell.GetSpellCooldown()` may return secret `start`/`duration` when `C_Secrets.ShouldSpellCooldownBeSecret()` is true
- **Spell cast info** — `UnitCastingInfo()` / `UnitChannelInfo()` return secret fields when unit identity is restricted
- **Totem info** — `GetTotemInfo()` may return secret `startTime`/`duration` when the totem spell is secret

### Safe Patterns

```lua
-- Safe: Pass cooldown secrets directly to Cooldown widget
local cdInfo = C_Spell.GetSpellCooldown(spellID)
myCooldownFrame:SetCooldown(cdInfo.startTime, cdInfo.duration)

-- Safe: Display spell name (concatenation works with secrets)
local name = C_Spell.GetSpellName(spellID)
myFontString:SetText(name)

-- UNSAFE: Cannot branch on cooldown values
local cdInfo = C_Spell.GetSpellCooldown(spellID)
if cdInfo.duration > 0 then end  -- ERROR if duration is secret
```

---

## Common Patterns

### Iterate All Spellbook Entries

```lua
local numLines = C_SpellBook.GetNumSpellBookSkillLines()
for skillIndex = 1, numLines do
    local info = C_SpellBook.GetSpellBookSkillLineInfo(skillIndex)
    for slotIndex = info.itemIndexOffset + 1, info.itemIndexOffset + info.numSpellBookItems do
        local itemInfo = C_SpellBook.GetSpellBookItemInfo(slotIndex, Enum.SpellBookSpellBank.Player)
        if itemInfo and itemInfo.itemType == Enum.SpellBookItemType.Spell then
            print(itemInfo.name, itemInfo.spellID)
        end
    end
end
```

### Check If Spell Is Usable and in Range

```lua
local function CanCastOnTarget(spellID, unit)
    local isUsable, insufficientPower = C_Spell.IsSpellUsable(spellID)
    if not isUsable then return false, insufficientPower end

    if C_Spell.SpellHasRange(spellID) then
        local inRange = C_Spell.IsSpellInRange(spellID, unit)
        if inRange == false then return false end
    end

    local cdInfo = C_Spell.GetSpellCooldown(spellID)
    -- Note: cdInfo.duration may be a secret value in 12.0
    -- Cannot branch on it — pass to Cooldown widget instead
    return true
end
```

### Display Action Button State

```lua
local function UpdateActionButton(button, actionID)
    if not C_ActionBar.HasAction(actionID) then
        button:Hide()
        return
    end

    button.icon:SetTexture(C_ActionBar.GetActionTexture(actionID))

    local isUsable, noMana = C_ActionBar.IsUsableAction(actionID)
    if isUsable then
        button.icon:SetVertexColor(1, 1, 1)
    elseif noMana then
        button.icon:SetVertexColor(0.5, 0.5, 1)
    else
        button.icon:SetVertexColor(0.4, 0.4, 0.4)
    end

    -- Use activation overlay for proc detection
    if C_SpellActivationOverlay.IsSpellOverlayed(C_ActionBar.GetSpell(actionID)) then
        button.overlay:Show()
    else
        button.overlay:Hide()
    end
end
```

### Monitor Totem State

```lua
local function UpdateTotemFrame(slot)
    local haveTotem, name, startTime, duration, icon, modRate, spellID = GetTotemInfo(slot)
    if haveTotem then
        -- startTime/duration may be secret in 12.0
        myTotemIcon:SetTexture(icon)
        myTotemCooldown:SetCooldown(startTime, duration)  -- Widget accepts secrets
        myTotemName:SetText(name)
    end
end
```

### Query Shapeshift Forms

```lua
local function ShowAvailableForms()
    local numForms = GetNumShapeshiftForms()
    for i = 1, numForms do
        local icon, active, castable, spellID = GetShapeshiftFormInfo(i)
        print(C_Spell.GetSpellName(spellID), active and "(Active)" or "")
    end
end
```

---

## Related Events

| Event | Payload | When |
|-------|---------|------|
| `SPELL_DATA_LOAD_RESULT` | `spellID, success` | Async spell data load complete |
| `ACTIONBAR_SLOT_CHANGED` | `slot` | Action placed/removed from slot |
| `ACTIONBAR_PAGE_CHANGED` | — | Action bar page changed |
| `ACTIONBAR_UPDATE_COOLDOWN` | — | Action cooldown updated |
| `ACTIONBAR_UPDATE_USABLE` | — | Action usability changed |
| `ACTIONBAR_UPDATE_STATE` | — | Action state changed |
| `UPDATE_BONUS_ACTIONBAR` | — | Bonus bar changed (stance/form) |
| `UPDATE_EXTRA_ACTIONBAR` | — | Extra action button changed |
| `UPDATE_OVERRIDE_ACTIONBAR` | — | Override bar state changed |
| `UPDATE_VEHICLE_ACTIONBAR` | — | Vehicle bar changed |
| `UPDATE_POSSESS_BAR` | — | Possession bar changed |
| `SPELL_ACTIVATION_OVERLAY_SHOW` | `spellID, ...` | Proc overlay should show |
| `SPELL_ACTIVATION_OVERLAY_HIDE` | `spellID` | Proc overlay should hide |
| `SPELL_UPDATE_COOLDOWN` | — | Spell cooldowns changed |
| `SPELL_UPDATE_USABLE` | — | Spell usability changed |
| `SPELL_UPDATE_CHARGES` | — | Spell charges changed |
| `CURRENT_SPELL_CAST_CHANGED` | — | Current cast changed |
| `SPELLS_CHANGED` | — | Spellbook contents changed |
| `LEARNED_SPELL_IN_SKILL_LINE` | `spellID, skillLineIndex, isGuildPerkSpell` | New spell learned |
| `PLAYER_TOTEM_UPDATE` | `slot` | Totem state changed |
| `UPDATE_SHAPESHIFT_FORM` | — | Shapeshift form changed |
| `UPDATE_SHAPESHIFT_FORMS` | — | Available forms changed |
| `UPDATE_SHAPESHIFT_COOLDOWN` | — | Form cooldown changed |
| `SPELL_CONFIRMATION_PROMPT` | `spellID, confirmType, text, duration, currencyID, currencyCost, difficultyID` | Spell confirmation needed |
| `SPELL_CONFIRMATION_TIMEOUT` | `spellID` | Confirmation timed out |
| `PET_BAR_UPDATE` | — | Pet bar updated |
| `PET_BAR_UPDATE_COOLDOWN` | — | Pet action cooldown changed |
| `PET_BAR_UPDATE_USABLE` | — | Pet action usability changed |
| `ASSISTED_COMBAT_UPDATE` | — | Rotation helper suggestion changed |
| `COOLDOWN_VIEWER_UPDATE` | — | Cooldown viewer data changed |
| `SPELL_FLYOUT_UPDATE` | `flyoutID, spellID, isLearned` | Flyout spell learned/changed |
