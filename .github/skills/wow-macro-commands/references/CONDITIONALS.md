# Macro Conditionals Reference

Complete reference for all WoW Retail macro conditionals — the keywords used inside `[brackets]` with secure macro commands to add conditional logic.

> **Source:** https://warcraft.wiki.gg/wiki/Macro_conditionals
> **Syntax Guide:** https://warcraft.wiki.gg/wiki/Secure_command_options

---

## Syntax

Conditionals are placed in square brackets before the command's parameters. Multiple conditions in one bracket set are comma-separated (AND logic). Multiple bracket sets separated by semicolons are OR logic (first true set wins).

```
/command [condition1, condition2] parameters; [condition3] parameters; fallback_parameters
```

- Prefix any condition with `no` to negate it: `[nodead]`, `[nomod]`, `[nostealth]`
- Conditions with parameters use `:` separator: `[mod:shift]`, `[spec:1]`
- Multiple parameters use `/` separator (OR): `[stance:1/2]`, `[mod:shift/ctrl]`

---

## Temporary Targeting Conditionals

These temporarily assign a target for this one macro command. They do NOT change the player's selected target.

| Conditional | Description |
|-------------|-------------|
| `@unitId` | Target any valid UnitId — `@player`, `@target`, `@focus`, `@mouseover`, `@party1`, `@raid5`, `@arena1`, etc. |
| `@cursor` | Immediately target the ground under the cursor (for AoE/ground-targeted spells). |
| `@none` | Interrupts auto self-cast, requires a manual targeting cursor. |

`target=` is an alias for `@`. Example: `[target=focus]` is the same as `[@focus]`.

**Important:** `@unit` only affects a single macro command — it does NOT change your actual selected target.

---

## Boolean Conditionals — Target State

These evaluate properties of the target (or the `@unit` if specified). The `no` prefix inverts them.

| Conditional | Similar API | Description |
|-------------|-------------|-------------|
| `exists` | `UnitExists()` | The unit exists. |
| `help` | `UnitCanAssist()` | The unit exists and can be targeted by helpful spells. |
| `harm` | `UnitCanAttack()` | The unit exists and can be targeted by harmful spells. |
| `dead` | `UnitIsDeadOrGhost()` | The unit exists and is dead. |
| `party` | `UnitInParty()` | The unit exists and is in your party (excludes self). |
| `raid` | `UnitInRaid()` | The unit exists and is in your raid. |
| `unithasvehicleui` | `UnitInVehicle()` | The unit exists and is in a vehicle. |

**Note:** `[nohelp]` is NOT the same as `[harm]`. Both `help` and `harm` require the target to exist. Some targets can be neither helped nor harmed (unflagged opposite-faction players, non-combat pets, escort NPCs, etc.).

---

## Boolean Conditionals — Player State

These evaluate the player's own state.

| Conditional | Similar API | Description |
|-------------|-------------|-------------|
| `combat` | `InCombatLockdown()` / `UnitAffectingCombat("player")` | Player is in combat. |
| `stealth` | `IsStealthed()` | Player is stealthed. |
| `mounted` | `IsMounted()` | Player is mounted. |
| `swimming` | `IsSubmerged()` | Player is swimming. |
| `flying` | `IsFlying()` | Player is airborne (mounted or flight form). |
| `flyable` | `IsFlyableArea()` | Area supports flying (unreliable in Wintergrasp). |
| `advflyable` | `IsAdvancedFlyableArea()` | Area supports advanced flying (Skyriding). Added Patch 10.0.7. |
| `indoors` | `IsIndoors()` | Player is indoors. |
| `outdoors` | `IsOutdoors()` | Player is outdoors. |
| `resting` | `IsResting()` | Player is in a rested zone. |
| `canexitvehicle` | `CanExitVehicle()` | Player is in a vehicle and can exit. |
| `channeling` | `UnitChannelInfo("player")` | Player is channeling any spell. |
| `channeling:spellName` | `UnitChannelInfo("player")` | Player is channeling a specific spell. |
| `equipped:type` / `worn:type` | `IsEquippedItemType(type)` | Player has item type equipped (e.g., `equipped:Shields`, `equipped:Swords`). Uses itemType/subtype names. |
| `form:n` / `stance:n` | `GetShapeshiftForm()` | Player is in the specified stance/form number. Use `form:0` for no form. Slash-separated for OR: `stance:1/2`. |
| `spec:n` | `GetSpecialization()` | Player has the n-th spec active. Slash-separated for OR: `spec:1/2`. |
| `known:name` / `known:spellID` | `IsPlayerSpell(spellID)` | Player knows the spell. Also works with `#showtooltip`. Added Patch 10.0.2. |
| `pet:name` / `pet:family` | `UnitCreatureFamily("pet")` | Player has a hunter pet by name or family. |
| `petbattle` | `C_PetBattles.IsInBattle()` | Player is in a pet battle. |
| `pvpcombat` | — | PvP talents are usable. Added Patch 7.3.0. |
| `group` / `group:party` / `group:raid` | `IsInGroup()` / `IsInRaid()` | Player is in a group (party or raid). |

---

## Boolean Conditionals — UI State

These evaluate the state of the user interface.

| Conditional | Similar API | Description |
|-------------|-------------|-------------|
| `actionbar:n` / `bar:n` | `GetActionBarPage()` | The n-th action bar page is showing. Slash-separated for OR: `bar:1/2`. |
| `bonusbar` / `bonusbar:n` | `HasBonusActionBar()` | Bonus action bar is visible (optionally specific one). |
| `button:n` / `btn:n` | — | Mouse button used: `1` (left), `2` (right), `3` (middle), `4`/`5` (extra). Also accepts virtual click names. |
| `cursor` | `GetCursorInfo()` | Player is dragging an action (item, spell, macro) on the cursor. |
| `extrabar` | `HasExtraActionBar()` | Extra action bar/button is visible. |
| `modifier` / `mod` / `mod:key` | `IsModifierKeyDown()` | Modifier key is held. Accepts: `shift`, `ctrl`, `alt`, `lshift`, `rshift`, `lctrl`, `rctrl`, `lalt`, `ralt`. |
| `mod:action` | `IsModifiedClick(action)` | Modified click action binding (e.g., `SELFCAST`, `FOCUSCAST`). |
| `overridebar` | `HasOverrideActionBar()` | Override bar is replacing the main action bar. |
| `possessbar` | `IsPossessBarVisible()` | Possess bar is visible. |
| `shapeshift` | `HasTempShapeshiftActionBar()` | Temporary shapeshift action bar is active. |
| `vehicleui` | `HasVehicleActionBar()` | Vehicle UI is active. |

---

## Housing Conditionals (Patch 11.2.7+)

| Conditional | Similar API | Description |
|-------------|-------------|-------------|
| `house:inside` | `C_Housing.IsInsideHouse()` | Player is inside a house. |
| `house:plot` | `C_Housing.IsInsidePlot()` | Player is inside their housing plot. |
| `house:editor` | `C_HouseEditor.IsHouseEditorActive()` | House editor is active. |
| `house:neighborhood` | `C_Housing.IsOnNeighborhoodMap()` | Player is on a neighborhood map. |

`[house]` alone is equivalent to `[house:inside/plot]`.

---

## Condition Negation Reference

Every boolean conditional can be negated with `no`:

| Positive | Negated | Meaning |
|----------|---------|---------|
| `[combat]` | `[nocombat]` | In combat / not in combat |
| `[dead]` | `[nodead]` | Dead / alive |
| `[help]` | `[nohelp]` | Can help / cannot help |
| `[mod:shift]` | `[nomod:shift]` | Shift held / shift not held |
| `[stance:1/2]` | `[nostance:1/2]` | In stance 1 or 2 / not in stance 1 or 2 |
| `[exists]` | `[noexists]` | Target exists / no target |

**`no` applies to the entire condition including all its parameters.** So `[nostance:1/2]` means "anything but stance 1 or 2."

---

## Patch History

| Patch | Change |
|-------|--------|
| 11.2.7 | `house` conditional added. |
| 10.0.7 | `advflyable` conditional added. |
| 10.0.2 | `known` conditional added. |
| 10.0.0 | `talent` conditional removed. |
| 7.3.0 | `pvpcombat` conditional added. |
| 7.1.0 | `@cursor` added. |
| 2.3.0 | Several conditions and shorthand alternatives added. |
| 2.0.1 | Macro conditionals system added. |
