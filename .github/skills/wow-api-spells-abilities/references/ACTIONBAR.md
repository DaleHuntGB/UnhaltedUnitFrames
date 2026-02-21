# C_ActionBar — Action Bar & Button Reference

> **Source:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#ActionBar
> **Current as of:** Patch 12.0.0 (Build 65655) — January 28, 2026

The `C_ActionBar` namespace manages action bar slots — querying, placing, and removing actions on bars, handling bar paging and overrides (vehicle, possess, bonus), and converting between spells and slot indices.

---

## Action Bar Slot Layout

Standard action bar slots are numbered 1–180:

| Bar | Slots | Notes |
|-----|-------|-------|
| Main Bar | 1–12 | Primary action bar |
| Bar 2 (Bottom Left) | 13–24 | |
| Bar 3 (Bottom Right) | 25–36 | |
| Bar 4 (Right) | 37–48 | |
| Bar 5 (Right 2) | 49–60 | |
| Bar 6 | 61–72 | |
| Bar 7 | 73–84 | |
| Bar 8 | 85–96 | |
| Bar 9–10 (Main bar pages) | 97–120 | Paging via bar swapping |
| Bonus/Override bars | 121–132 | Vehicle, possess, override |
| Temp Shapeshift Bar | 133–144 | Druid forms, etc. |
| MultiCast Bar | 145–156 | Unused in Retail |
| Pet Bar slots | N/A | Separate system |

**Slot formula:** `(barIndex - 1) * NUM_ACTIONBAR_BUTTONS + buttonIndex` where `NUM_ACTIONBAR_BUTTONS = 12`.

---

## Slot Content Queries

### C_ActionBar.GetActionBarPage() → page

Returns the current main action bar page number.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetActionBarPage

### C_ActionBar.HasAction(slot) → hasAction

Returns `true` if the action bar slot contains an action.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.HasAction

### C_ActionBar.GetActionInfo(slot) → actionType, id, subType

Returns the type and ID of the action in a slot.

**Action types:** `"spell"`, `"item"`, `"macro"`, `"companion"`, `"equipmentset"`, `"flyout"`, `"summonpet"`, `"summonmount"`.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetActionInfo

### C_ActionBar.GetActionTexture(slot) → texture

Returns the icon texture for the action.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetActionTexture

### C_ActionBar.GetActionText(slot) → text

Returns the display text (macros show name).

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetActionText

### C_ActionBar.GetActionCount(slot) → count

Returns the count/stack for the item or reagent spells.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetActionCount

### C_ActionBar.GetActionCharges(slot) → currentCharges, maxCharges, chargeStart, chargeDuration, chargeModRate

Returns charge info for charge-based abilities on the action bar.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetActionCharges

### C_ActionBar.GetActionCooldown(slot) → start, duration, enable, modRate

Returns cooldown info for the action.

**⚠ Patch 12.0.0:** May return secret values when `C_Secrets.ShouldActionCooldownBeSecret(slot)` is true. See wow-api-important instructions.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetActionCooldown

### C_ActionBar.GetActionLossOfControlCooldown(slot) → start, duration

Returns loss-of-control cooldown for the action.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetActionLossOfControlCooldown

---

## Usability & State Checks

### C_ActionBar.IsUsableAction(slot) → isUsable, notEnoughMana

Returns whether the action can be used. `notEnoughMana` indicates insufficient resources.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.IsUsableAction

### C_ActionBar.IsActionInRange(slot [, unit]) → inRange

Returns `true` if the target (or specified unit) is in range. Returns `nil` if the action has no range check.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.IsActionInRange

### C_ActionBar.ActionHasRange(slot) → hasRange

Returns `true` if the action has a range component.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.ActionHasRange

### C_ActionBar.IsCurrentAction(slot) → isCurrent

Returns `true` if the action is currently active (e.g., channeling, toggled on).

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.IsCurrentAction

### C_ActionBar.IsAutoRepeatAction(slot) → isAutoRepeat

Returns `true` if the action is an auto-repeat spell (Auto Shot).

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.IsAutoRepeatAction

### C_ActionBar.IsAttackAction(slot) → isAttack

Returns `true` if the action is the melee auto-attack.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.IsAttackAction

### C_ActionBar.IsEqualAction(slot1, slot2) → isEqual

Returns `true` if both slots contain the same action.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.IsEqualAction

### C_ActionBar.IsConsumableAction(slot) → isConsumable

Returns `true` if the action consumes an item or charge.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.IsConsumableAction

### C_ActionBar.IsStackableAction(slot) → isStackable

Returns `true` if the action's item is stackable.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.IsStackableAction

### C_ActionBar.IsItemAction(slot) → isItem

Returns `true` if the action is an item.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.IsItemAction

### C_ActionBar.IsSpellAction(slot) → isSpell

Returns `true` if the action is a spell.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.IsSpellAction

### C_ActionBar.IsMacroAction(slot) → isMacro

Returns `true` if the action is a macro.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.IsMacroAction

---

## Bar Pages & Overrides

### C_ActionBar.ChangeActionBarPage(page)

Switches the main action bar to the specified page.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.ChangeActionBarPage

### C_ActionBar.GetBonusBarOffset() → offset

Returns the bonus bar offset (vehicle, possess, override). The override bar replaces the main bar using `121 + (offset - 1) * 12` through `120 + offset * 12`.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetBonusBarOffset

### C_ActionBar.HasBonusActionBar() → hasBonusBar

Returns `true` if a bonus/override bar is active.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.HasBonusActionBar

### C_ActionBar.HasOverrideActionBar() → hasOverrideBar

Returns `true` if an override bar is active (e.g., quest vehicle).

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.HasOverrideActionBar

### C_ActionBar.HasVehicleActionBar() → hasVehicleBar

Returns `true` if a vehicle action bar is active.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.HasVehicleActionBar

### C_ActionBar.HasTempShapeshiftActionBar() → hasTempBar

Returns `true` if a temporary shapeshifting action bar is active (Druid forms).

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.HasTempShapeshiftActionBar

### C_ActionBar.GetOverrideBarSkin() → barSkin

Returns the name of the override bar skin texture.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetOverrideBarSkin

---

## Spell ↔ Action Lookups

### C_ActionBar.FindSpellActionButtons(spellID) → slots

Returns a table of all action bar slots containing this spell.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.FindSpellActionButtons

### C_ActionBar.FindFlyoutActionButtons(flyoutID) → slots

Returns a table of all action bar slots containing this flyout.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.FindFlyoutActionButtons

### C_ActionBar.FindItemActionButtons(itemID) → slots

Returns a table of all action bar slots containing this item.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.FindItemActionButtons

### C_ActionBar.FindPetActionButtons(petActionID) → slots

Returns a table of all action bar slots containing this pet action.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.FindPetActionButtons

### C_ActionBar.GetSpellActionBarSlot(spellID) → slot

Returns a single action bar slot containing this spell (first found).

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetSpellActionBarSlot

### C_ActionBar.IsOnBarOrSpecialBar(spellID) → isOnBar

Returns `true` if the spell is anywhere on the main or bonus bars.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.IsOnBarOrSpecialBar

---

## Profession & Gear Actions

### C_ActionBar.GetProfessionQuality(slot) → quality

Returns the quality of a profession recipe action.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetProfessionQuality

### C_ActionBar.ShouldOverrideBarShowHealthBar() → shouldShow

Returns `true` if the override bar should display a health bar.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.ShouldOverrideBarShowHealthBar

### C_ActionBar.ShouldOverrideBarShowExitButton() → shouldShow

Returns `true` if the override bar should show a vehicle exit button.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.ShouldOverrideBarShowExitButton

---

## Slot Management (Pickup / Place / Use)

### C_ActionBar.UseAction(slot [, checkCursor [, onSelf]])

Performs the action in the slot. If `checkCursor` is true, uses whatever is on the cursor. If `onSelf` is true, self-casts.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.UseAction

### C_ActionBar.PickupAction(slot)

Picks up the action from a slot onto the cursor.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.PickupAction

### C_ActionBar.PlaceAction(slot)

Places the cursor action into a slot.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.PlaceAction

### C_ActionBar.GetActionButtonForID(actionID) → buttonName

Returns the global name of the action button widget for an action.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetActionButtonForID

---

## Display & Count Helpers

### C_ActionBar.GetNumActionBarSlots() → numSlots

Returns the total number of action bar slots.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetNumActionBarSlots

### C_ActionBar.IsActionBarDisplayed(barIndex) → isDisplayed

Returns `true` if the specified bar is currently visible.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.IsActionBarDisplayed

### C_ActionBar.SetActionBarDisplayState(barIndex, show)

Shows or hides a specific action bar.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.SetActionBarDisplayState

### C_ActionBar.GetActionBarToggles() → toggles

Returns a table of bar visibility toggle states.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetActionBarToggles

### C_ActionBar.SetActionBarToggles(toggles)

Sets bar visibility toggle states.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_ActionBar.SetActionBarToggles

---

## Common Patterns

### Display an Action Button

```lua
local function UpdateActionButton(button, slot)
    if not C_ActionBar.HasAction(slot) then
        button:Hide()
        return
    end

    local texture = C_ActionBar.GetActionTexture(slot)
    button.icon:SetTexture(texture)

    local isUsable, notEnoughMana = C_ActionBar.IsUsableAction(slot)
    if isUsable then
        button.icon:SetVertexColor(1, 1, 1)
    elseif notEnoughMana then
        button.icon:SetVertexColor(0.5, 0.5, 1)
    else
        button.icon:SetVertexColor(0.4, 0.4, 0.4)
    end

    local count = C_ActionBar.GetActionCount(slot)
    button.count:SetText(count > 1 and count or "")

    local isCurrent = C_ActionBar.IsCurrentAction(slot)
    button:SetChecked(isCurrent)

    button:Show()
end
```

### Update Cooldown Display

```lua
local function UpdateCooldown(cooldownFrame, slot)
    local start, duration, enable, modRate = C_ActionBar.GetActionCooldown(slot)

    -- Patch 12.0.0: Check for secret values
    if C_Secrets and C_Secrets.ShouldActionCooldownBeSecret(slot) then
        cooldownFrame:Hide()
        return
    end

    if start and start > 0 and duration > 0 and enable > 0 then
        CooldownFrame_Set(cooldownFrame, start, duration, enable, false, modRate)
    else
        cooldownFrame:Clear()
    end
end
```

### Find Spell on Action Bars

```lua
local function IsSpellOnActionBar(spellID)
    local slots = C_ActionBar.FindSpellActionButtons(spellID)
    return slots and #slots > 0
end
```

### Detect Override/Vehicle Bar

```lua
local function GetActiveBarContext()
    if C_ActionBar.HasVehicleActionBar() then
        return "vehicle"
    elseif C_ActionBar.HasOverrideActionBar() then
        return "override"
    elseif C_ActionBar.HasTempShapeshiftActionBar() then
        return "shapeshift"
    elseif C_ActionBar.HasBonusActionBar() then
        return "bonus"
    else
        return "normal"
    end
end
```
