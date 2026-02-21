# Totems, Shapeshifting, Flyouts & Pet Actions Reference

> **Source:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API
> **Current as of:** Patch 12.0.0 (Build 65655) — January 28, 2026

This file covers totem management, shapeshifting / stances / forms, flyout menus, pet action buttons, and multi-cast systems.

---

## Totem Functions

Totems occupy numbered slots. Constants:

| Constant | Value | Element |
|----------|-------|---------|
| `FIRE_TOTEM_SLOT` | 1 | Fire |
| `EARTH_TOTEM_SLOT` | 2 | Earth |
| `WATER_TOTEM_SLOT` | 3 | Water |
| `AIR_TOTEM_SLOT` | 4 | Air |
| `MAX_TOTEMS` | 4 | Maximum active totems |

### GetTotemInfo(slot) → haveTotem, totemName, startTime, duration, icon

Returns totem info for a given slot.

| Return | Type | Description |
|--------|------|-------------|
| `haveTotem` | boolean | `true` if a totem exists in this slot |
| `totemName` | string | Localized name of the totem |
| `startTime` | number | `GetTime()` when the totem was placed |
| `duration` | number | Total duration in seconds |
| `icon` | number | Icon texture ID |

> **Wiki:** https://warcraft.wiki.gg/wiki/API_GetTotemInfo

### GetTotemTimeLeft(slot) → timeLeft

Returns seconds remaining for the totem in the slot.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_GetTotemTimeLeft

### DestroyTotem(slot)

Destroys the totem in the given slot.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_DestroyTotem

### GetMultiCastTotemSpells(slot) → spellID1, spellID2, ...

Returns the spell IDs available for a multi-cast totem slot.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_GetMultiCastTotemSpells

### SetMultiCastSpell(totemSlot, spellID)

Sets the spell for a multi-cast totem slot.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_SetMultiCastSpell

### Totem Monitoring Pattern

```lua
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_TOTEM_UPDATE")
f:SetScript("OnEvent", function(self, event, slot)
    for i = 1, MAX_TOTEMS do
        local haveTotem, name, startTime, duration, icon = GetTotemInfo(i)
        if haveTotem then
            local remaining = (startTime + duration) - GetTime()
            print(string.format("Slot %d: %s (%.0fs remaining)", i, name, remaining))
        else
            print(string.format("Slot %d: empty", i))
        end
    end
end)
```

### Totem Events

| Event | Payload | Description |
|-------|---------|-------------|
| `PLAYER_TOTEM_UPDATE` | `slot` | Totem placed, replaced, or destroyed |

---

## Shapeshifting / Stances / Forms

These functions manage Druid forms, Warrior stances, Rogue Stealth, and similar form changes.

### GetNumShapeshiftForms() → numForms

Returns the number of available forms/stances.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_GetNumShapeshiftForms

### GetShapeshiftForm() → index

Returns the index of the currently active form (0 = no form, caster form).

> **Wiki:** https://warcraft.wiki.gg/wiki/API_GetShapeshiftForm

### GetShapeshiftFormID() → formID

Returns the form ID of the currently active form (not the same as index).

> **Wiki:** https://warcraft.wiki.gg/wiki/API_GetShapeshiftFormID

### GetShapeshiftFormInfo(index) → icon, isActive, isCastable, spellID

Returns information about a specific form.

| Return | Type | Description |
|--------|------|-------------|
| `icon` | number | Icon texture |
| `isActive` | boolean | Is this form currently active? |
| `isCastable` | boolean | Can the player switch to this form? |
| `spellID` | number | Spell ID for the form |

> **Wiki:** https://warcraft.wiki.gg/wiki/API_GetShapeshiftFormInfo

### GetShapeshiftFormCooldown(index) → start, duration, isEnabled

Returns cooldown info for switching to a form.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_GetShapeshiftFormCooldown

### CastShapeshiftForm(index)

Switches to the specified form. If already in that form, cancels it.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_CastShapeshiftForm

### CancelShapeshiftForm()

Cancels the current shapeshift form, returning to caster form.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_CancelShapeshiftForm

### Form Tracking Pattern

```lua
local f = CreateFrame("Frame")
f:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
f:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
f:RegisterEvent("UPDATE_SHAPESHIFT_USABLE")
f:SetScript("OnEvent", function(self, event)
    local currentForm = GetShapeshiftForm()
    local numForms = GetNumShapeshiftForms()

    for i = 1, numForms do
        local icon, isActive, isCastable, spellID = GetShapeshiftFormInfo(i)
        local name = C_Spell.GetSpellName(spellID)
        print(string.format("%s%s: %s", isActive and ">> " or "   ", name, isCastable and "Ready" or "Locked"))
    end
end)
```

### Shapeshift Events

| Event | Payload | Description |
|-------|---------|-------------|
| `UPDATE_SHAPESHIFT_FORM` | — | Current form changed |
| `UPDATE_SHAPESHIFT_FORMS` | — | Available forms changed (talent/level change) |
| `UPDATE_SHAPESHIFT_USABLE` | — | Form usability changed |
| `UPDATE_SHAPESHIFT_COOLDOWN` | — | Form cooldown changed |

---

## Flyout Menus

Flyouts are expandable spell menus on the action bar (e.g., Mage Portals, Warlock Demons, Shaman Totems).

### GetFlyoutInfo(flyoutID) → flyoutName, description, numSlots, isKnown

Returns info about a flyout.

| Return | Type | Description |
|--------|------|-------------|
| `flyoutName` | string | Localized name |
| `description` | string | Localized description |
| `numSlots` | number | Number of spells in the flyout |
| `isKnown` | boolean | Does the player know this flyout? |

> **Wiki:** https://warcraft.wiki.gg/wiki/API_GetFlyoutInfo

### GetFlyoutSlotInfo(flyoutID, slotIndex) → spellID, overrideSpellID, isKnown, spellName, slotSpecID

Returns info about a specific spell slot within a flyout.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_GetFlyoutSlotInfo

### GetFlyoutID(index) → flyoutID

Returns the flyout ID at the given index in the global flyout list.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_GetFlyoutID

### GetNumFlyouts() → numFlyouts

Returns the total number of flyouts.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_GetNumFlyouts

### Flyout Enumeration Pattern

```lua
local function ListFlyoutSpells(flyoutID)
    local name, desc, numSlots, isKnown = GetFlyoutInfo(flyoutID)
    if not isKnown then return end

    print("Flyout: " .. name)
    for i = 1, numSlots do
        local spellID, overrideSpellID, isKnown, spellName = GetFlyoutSlotInfo(flyoutID, i)
        if isKnown then
            print("  " .. spellName .. " (" .. spellID .. ")")
        end
    end
end
```

---

## Pet Action Bar

Pet actions use a separate bar from the player's action bar.

### GetPetActionInfo(index) → name, texture, isToken, isActive, autoCastAllowed, autoCastEnabled, spellID

Returns info about a pet action button (1–10).

| Return | Type | Description |
|--------|------|-------------|
| `name` | string | Action name |
| `texture` | number or string | Icon texture |
| `isToken` | boolean | If `true`, `name` is a global string token |
| `isActive` | boolean | Is the action currently active? |
| `autoCastAllowed` | boolean | Can autocast be toggled? |
| `autoCastEnabled` | boolean | Is autocast currently on? |
| `spellID` | number | Spell ID (if applicable) |

> **Wiki:** https://warcraft.wiki.gg/wiki/API_GetPetActionInfo

### GetPetActionCooldown(index) → start, duration, isEnabled

Returns cooldown for a pet action button.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_GetPetActionCooldown

### GetPetActionSlotUsable(index) → isUsable, notEnoughPower

Returns usability for a pet action.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_GetPetActionSlotUsable

### CastPetAction(index [, target])

Activates a pet action button.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_CastPetAction

### TogglePetAutocast(index)

Toggles autocast for a pet action.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_TogglePetAutocast

### PickupPetAction(index)

Picks up a pet action for drag-and-drop.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_PickupPetAction

### IsPetAttackAction(index) → isAttack

Returns `true` if the pet action is the attack command.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_IsPetAttackAction

### Other Pet Action Functions

| Function | Description | Wiki |
|----------|-------------|------|
| `PetHasActionBar()` | Returns `true` if the pet has an action bar | https://warcraft.wiki.gg/wiki/API_PetHasActionBar |
| `PetHasSpellbook()` | Returns `true` if the pet has a spellbook | https://warcraft.wiki.gg/wiki/API_PetHasSpellbook |
| `GetPetActionsUsable()` | Returns `true` if pet actions can be used | https://warcraft.wiki.gg/wiki/API_GetPetActionsUsable |
| `HasPetUI()` | Returns `hasPetUI, isHunterPet` | https://warcraft.wiki.gg/wiki/API_HasPetUI |
| `PetCanBeAbandoned()` | Returns `true` if the pet can be abandoned | https://warcraft.wiki.gg/wiki/API_PetCanBeAbandoned |
| `PetCanBeDismissed()` | Returns `true` if the pet can be dismissed | https://warcraft.wiki.gg/wiki/API_PetCanBeDismissed |
| `PetCanBeRenamed()` | Returns `true` if the pet can be renamed | https://warcraft.wiki.gg/wiki/API_PetCanBeRenamed |

---

## Action Button Slot Functions

Convenience functions that wrap action bar slot operations. Used by the default UI action buttons:

| Function | Description | Wiki |
|----------|-------------|------|
| `PickupAction(slot)` | Pick up an action for drag-and-drop | https://warcraft.wiki.gg/wiki/API_PickupAction |
| `PlaceAction(slot)` | Place the cursor action into a slot | https://warcraft.wiki.gg/wiki/API_PlaceAction |
| `PickupSpell(spellID)` | Pick up a spell onto the cursor | https://warcraft.wiki.gg/wiki/API_PickupSpell |
| `PickupSpellBookItem(slot, bank)` | Pick up a spellbook item | https://warcraft.wiki.gg/wiki/API_PickupSpellBookItem |
| `PickupMacro(index)` | Pick up a macro | https://warcraft.wiki.gg/wiki/API_PickupMacro |
| `PickupCompanion(type, index)` | Pick up a companion | https://warcraft.wiki.gg/wiki/API_PickupCompanion |
| `GetCursorInfo()` | Returns what's on the cursor | https://warcraft.wiki.gg/wiki/API_GetCursorInfo |
| `ClearCursor()` | Clear the cursor | https://warcraft.wiki.gg/wiki/API_ClearCursor |

---

## Misc Global Spell Helpers

| Function | Description | Wiki |
|----------|-------------|------|
| `GetSpellAutocast(spellName)` | Get autocast state by name | https://warcraft.wiki.gg/wiki/API_GetSpellAutocast |
| `EnableSpellAutocast(spellName)` | Enable autocast by name | https://warcraft.wiki.gg/wiki/API_EnableSpellAutocast |
| `DisableSpellAutocast(spellName)` | Disable autocast by name | https://warcraft.wiki.gg/wiki/API_DisableSpellAutocast |
| `IsSelectedSpellBookItem(slot, bank)` | Is this slot selected? | https://warcraft.wiki.gg/wiki/API_IsSelectedSpellBookItem |
| `UpdateSpells()` | Force spellbook data refresh | https://warcraft.wiki.gg/wiki/API_UpdateSpells |
| `SpellGetVisibilityInfo(spellID, context)` | Get visibility for spell | https://warcraft.wiki.gg/wiki/API_SpellGetVisibilityInfo |
| `SpellIsSelfBuff(spellID)` | Returns `true` if spell is a self-buff | https://warcraft.wiki.gg/wiki/API_SpellIsSelfBuff |
