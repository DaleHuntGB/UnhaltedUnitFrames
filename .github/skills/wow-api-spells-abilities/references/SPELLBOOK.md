# C_SpellBook — Spellbook Navigation Reference

> **Source:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#SpellBook
> **Current as of:** Patch 12.0.0 (Build 65655) — January 28, 2026

The `C_SpellBook` namespace manages the player's spellbook — browsing skill lines (tabs), querying individual spell slots, casting from the spellbook, and managing pet spells.

---

## Spellbook Concepts

### Spell Banks

Functions take a `spellBookItemSpellBank` parameter:
- `Enum.SpellBookSpellBank.Player` — Player spells
- `Enum.SpellBookSpellBank.Pet` — Pet spells

### Spell Slot Indices

Each spellbook tab (skill line) has an offset and count. Slots are numbered globally:

```lua
local numLines = C_SpellBook.GetNumSpellBookSkillLines()
for tab = 1, numLines do
    local info = C_SpellBook.GetSpellBookSkillLineInfo(tab)
    -- Slots: info.itemIndexOffset + 1 through info.itemIndexOffset + info.numSpellBookItems
end
```

### SpellBookItemType

Returned by `GetSpellBookItemType()` and `GetSpellBookItemInfo()`:
- `Enum.SpellBookItemType.Spell` — Normal spell
- `Enum.SpellBookItemType.FutureSpell` — Spell not yet learned (grayed out)
- `Enum.SpellBookItemType.Flyout` — Flyout menu (e.g., Mage portals)
- `Enum.SpellBookItemType.PetAction` — Pet action

---

## Skill Lines (Tabs)

### C_SpellBook.GetNumSpellBookSkillLines() → numSpellBookSkillLines

Returns the number of spellbook tabs (General, Class, Spec, Pet, etc.).

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetNumSpellBookSkillLines

### C_SpellBook.GetSpellBookSkillLineInfo(skillLineIndex) → skillLineInfo

Returns info for a spellbook tab:

```lua
---@class SpellBookSkillLineInfo
---@field name string                -- Tab name (e.g., "Frost", "General")
---@field iconID number              -- Tab icon
---@field itemIndexOffset number     -- Global slot offset (0-based)
---@field numSpellBookItems number   -- Number of spells in this tab
---@field isGuild boolean            -- Guild perk tab?
---@field shouldHide boolean         -- Should this tab be hidden?
---@field specID number              -- Specialization ID (0 for General)
---@field offSpecID number           -- Off-spec ID (if showing off-spec spells)
```

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetSpellBookSkillLineInfo

### C_SpellBook.GetSkillLineIndexByID(skillLineID) → skillIndex

Returns the skill line index for a given skill line ID.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetSkillLineIndexByID

---

## Slot Information

### C_SpellBook.GetSpellBookItemInfo(slot, bank) → spellBookItemInfo

Returns comprehensive information for a spellbook slot:

```lua
---@class SpellBookItemInfo
---@field actionID number            -- Action ID for the item
---@field spellID number             -- Spell ID
---@field itemType SpellBookItemType -- Spell, Flyout, FutureSpell, PetAction
---@field name string                -- Localized name
---@field subName string             -- Subtext (rank, spec name)
---@field iconID number              -- Icon texture
---@field isOffSpec boolean          -- Belongs to inactive spec?
---@field skillLineIndex number      -- Which tab this belongs to
---@field isPassive boolean          -- Passive ability?
```

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetSpellBookItemInfo

### C_SpellBook.GetSpellBookItemType(slot, bank) → itemType, actionID, spellID

Quick type check and ID lookup for a slot.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetSpellBookItemType

### C_SpellBook.GetSpellBookItemName(slot, bank) → name, subName

Returns the localized name and subtext of a spellbook slot.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetSpellBookItemName

### C_SpellBook.GetSpellBookItemTexture(slot, bank) → iconID

Returns the icon texture for a spellbook slot.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetSpellBookItemTexture

### C_SpellBook.GetSpellBookItemDescription(slot, bank) → description

Returns the tooltip description text for a spellbook slot.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetSpellBookItemDescription

### C_SpellBook.GetSpellBookItemLink(slot, bank [, glyphID]) → spellLink

Returns a clickable hyperlink for the spell in the slot.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetSpellBookItemLink

### C_SpellBook.GetSpellBookItemLevelLearned(slot, bank) → levelLearned

Returns the level at which the spell in this slot is learned.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetSpellBookItemLevelLearned

### C_SpellBook.GetSpellBookItemSkillLineIndex(slot, bank) → skillLineIndex

Returns which skill line (tab) this slot belongs to.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetSpellBookItemSkillLineIndex

### C_SpellBook.GetSpellBookItemPowerCost(slot, bank) → powerCosts

Returns the resource cost table for the spell in this slot.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetSpellBookItemPowerCost

### C_SpellBook.GetSpellBookItemTradeSkillLink(slot, bank) → spellLink

Returns a trade skill link for recipe-type spells.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetSpellBookItemTradeSkillLink

---

## Slot Usability & State Checks

### C_SpellBook.IsSpellBookItemUsable(slot, bank) → isUsable, insufficientPower

Returns whether the spell in this slot can be cast. `insufficientPower` indicates the only blocker is missing resources.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.IsSpellBookItemUsable

### C_SpellBook.IsSpellBookItemPassive(slot, bank) → isPassive

Returns `true` if the spellbook item is a passive ability.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.IsSpellBookItemPassive

### C_SpellBook.IsSpellBookItemOffSpec(slot, bank) → isOffSpec

Returns `true` if the spell belongs to an inactive specialization.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.IsSpellBookItemOffSpec

### C_SpellBook.IsSpellBookItemHarmful(slot, bank) → isHarmful

Returns `true` if the spell is harmful (offensive).

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.IsSpellBookItemHarmful

### C_SpellBook.IsSpellBookItemHelpful(slot, bank) → isHelpful

Returns `true` if the spell is helpful (beneficial).

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.IsSpellBookItemHelpful

### C_SpellBook.IsSpellBookItemInRange(slot, bank [, targetUnit]) → inRange

Returns `true` if the target is in range for the spell in this slot.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.IsSpellBookItemInRange

### C_SpellBook.SpellBookItemHasRange(slot, bank) → hasRange

Returns `true` if the spell has a range component.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.SpellBookItemHasRange

### C_SpellBook.IsAutoAttackSpellBookItem(slot, bank) → isAutoAttack

Returns `true` if this is the auto-attack entry.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.IsAutoAttackSpellBookItem

### C_SpellBook.IsRangedAutoAttackSpellBookItem(slot, bank) → isRangedAutoAttack

Returns `true` if this is the ranged auto-attack entry (e.g., Auto Shot).

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.IsRangedAutoAttackSpellBookItem

### C_SpellBook.IsClassTalentSpellBookItem(slot, bank) → isClassTalent

Returns `true` if the spell comes from the class talent tree.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.IsClassTalentSpellBookItem

### C_SpellBook.IsPvPTalentSpellBookItem(slot, bank) → isPvPTalent

Returns `true` if the spell is a PvP talent.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.IsPvPTalentSpellBookItem

---

## Slot Cooldowns & Charges

These mirror `C_Spell` cooldown functions but operate on spellbook slots.

### C_SpellBook.GetSpellBookItemCooldown(slot, bank) → spellCooldownInfo

Returns the same structure as `C_Spell.GetSpellCooldown()`.

**⚠ Patch 12.0.0:** May return secret values when `C_Secrets.ShouldSpellBookItemCooldownBeSecret(slot, bank)` is true.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetSpellBookItemCooldown

### C_SpellBook.GetSpellBookItemCooldownDuration(slot, bank) → duration

Returns remaining cooldown for the slot.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetSpellBookItemCooldownDuration

### C_SpellBook.GetSpellBookItemCharges(slot, bank) → chargeInfo

Returns charge info (same structure as `C_Spell.GetSpellCharges`).

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetSpellBookItemCharges

### C_SpellBook.GetSpellBookItemChargeDuration(slot, bank) → duration

Returns charge recharge duration.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetSpellBookItemChargeDuration

### C_SpellBook.GetSpellBookItemCastCount(slot, bank) → castCount

Returns the number of remaining casts.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetSpellBookItemCastCount

### C_SpellBook.GetSpellBookItemLossOfControlCooldown(slot, bank) → startTime, duration

Returns loss-of-control cooldown for the slot.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetSpellBookItemLossOfControlCooldown

### C_SpellBook.GetSpellBookItemLossOfControlCooldownDuration(slot, bank) → duration

Returns remaining LoC duration for the slot.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetSpellBookItemLossOfControlCooldownDuration

---

## Spell Lookup & Knowledge

### C_SpellBook.FindSpellBookSlotForSpell(spellIdentifier [, includeHidden [, includeFlyouts [, includeFutureSpells [, includeOffSpec]]]]) → slotIndex, bank

Finds the spellbook slot for a given spell. Returns `nil` if not found.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.FindSpellBookSlotForSpell

### C_SpellBook.IsSpellKnown(spellID [, spellBank]) → isKnown

Returns `true` if the player (or pet, if `spellBank` is Pet) knows the spell.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.IsSpellKnown

### C_SpellBook.IsSpellInSpellBook(spellID [, spellBank [, includeOverrides]]) → isInSpellBook

Returns `true` if the spell appears in the spellbook (may differ from `IsSpellKnown` for override spells).

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.IsSpellInSpellBook

### C_SpellBook.IsSpellKnownOrInSpellBook(spellID [, spellBank [, includeOverrides]]) → isKnownOrInSpellBook

Combined check — returns `true` if the spell is known OR appears in the spellbook.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.IsSpellKnownOrInSpellBook

### C_SpellBook.FindBaseSpellByID(spellID) → baseSpellID

Resolves a spell override to its base spell ID.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.FindBaseSpellByID

### C_SpellBook.FindSpellOverrideByID(spellID) → overrideSpellID

Returns the current override for a spell, or the same ID if no override exists.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.FindSpellOverrideByID

### C_SpellBook.GetCurrentLevelSpells(level) → spellIDs

Returns spell IDs that are learned at the specified level.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetCurrentLevelSpells

### C_SpellBook.HasPetSpells() → numPetSpells, petNameToken

Returns the number of pet spells and the pet's name token, or `nil` if the player has no pet with spells.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.HasPetSpells

### C_SpellBook.ContainsAnyDisenchantSpell() → contains

Returns `true` if the spellbook contains any disenchant spell (Enchanting profession).

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.ContainsAnyDisenchantSpell

### C_SpellBook.FindFlyoutSlotBySpellID(spellID) → flyoutSlot

Returns the flyout slot index containing this spell.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.FindFlyoutSlotBySpellID

---

## Slot Operations

### C_SpellBook.CastSpellBookItem(slot, bank [, targetSelf])

Casts the spell in the specified spellbook slot. Set `targetSelf` to `true` to self-cast.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.CastSpellBookItem

### C_SpellBook.PickupSpellBookItem(slot, bank)

Picks up the spell onto the cursor for drag-and-drop.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.PickupSpellBookItem

### C_SpellBook.GetSpellBookItemAutoCast(slot, bank) → autoCastAllowed, autoCastEnabled

Returns the autocast state for a pet spell slot.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetSpellBookItemAutoCast

### C_SpellBook.SetSpellBookItemAutoCastEnabled(slot, bank, enabled)

Sets the autocast state for a pet spell.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.SetSpellBookItemAutoCastEnabled

### C_SpellBook.ToggleSpellBookItemAutoCast(slot, bank)

Toggles the autocast state for a pet spell.

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_SpellBook.ToggleSpellBookItemAutoCast

---

## Common Patterns

### Enumerate All Player Spells

```lua
local bank = Enum.SpellBookSpellBank.Player
local numLines = C_SpellBook.GetNumSpellBookSkillLines()

for skillIndex = 1, numLines do
    local lineInfo = C_SpellBook.GetSpellBookSkillLineInfo(skillIndex)
    print("--- " .. lineInfo.name .. " ---")

    for slot = lineInfo.itemIndexOffset + 1, lineInfo.itemIndexOffset + lineInfo.numSpellBookItems do
        local itemType, actionID, spellID = C_SpellBook.GetSpellBookItemType(slot, bank)
        if itemType == Enum.SpellBookItemType.Spell then
            local name = C_SpellBook.GetSpellBookItemName(slot, bank)
            local isPassive = C_SpellBook.IsSpellBookItemPassive(slot, bank)
            print(string.format("  [%d] %s (ID: %d)%s", slot, name, spellID, isPassive and " (Passive)" or ""))
        elseif itemType == Enum.SpellBookItemType.Flyout then
            local flyoutInfo = GetFlyoutInfo(actionID)
            print(string.format("  [%d] Flyout: %s (%d spells)", slot, flyoutInfo, select(3, GetFlyoutInfo(actionID))))
        end
    end
end
```

### Check If Player Knows a Spell

```lua
local function PlayerKnowsSpell(spellID)
    return C_SpellBook.IsSpellKnown(spellID) or
           C_SpellBook.IsSpellInSpellBook(spellID, nil, true)  -- include overrides
end
```

### Find Spellbook Slot for a Spell ID

```lua
local function GetSpellbookSlot(spellID)
    local slot, bank = C_SpellBook.FindSpellBookSlotForSpell(spellID, false, true, false, false)
    if slot then
        return slot, bank
    end
    return nil
end
```

### List Pet Spells

```lua
local numPetSpells, petName = C_SpellBook.HasPetSpells()
if numPetSpells then
    local petBank = Enum.SpellBookSpellBank.Pet
    for slot = 1, numPetSpells do
        local name = C_SpellBook.GetSpellBookItemName(slot, petBank)
        local autoCastAllowed, autoCastEnabled = C_SpellBook.GetSpellBookItemAutoCast(slot, petBank)
        print(name, autoCastEnabled and "(Autocast ON)" or "")
    end
end
```
