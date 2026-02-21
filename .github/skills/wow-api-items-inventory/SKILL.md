---
name: wow-api-items-inventory
description: "Complete reference for WoW Retail Item, Container (Bag), Bank, Loot, Equipment, Socket, Upgrade, Merchant, and World Loot Object APIs. Covers C_Item info/count/cooldown/equip/type checks, C_Container bag slots/sort/search/use, C_Bank tabs/deposit/withdraw, C_Loot roll/legacy mode, C_ItemSocketInfo gem sockets, C_ItemInteraction conversion, C_MerchantFrame vendor buy/sell/repair, item location/mixin patterns, and looting functions. Use when working with items, bags, inventory, bank, loot, equipment sets, item sockets, item upgrades, merchants, vendors, item links, or world loot objects."
---

# Item & Inventory API (Retail — Patch 12.0.0)

Comprehensive reference for all Item, Container, Bank, Loot, Equipment, Merchant, Socket, Upgrade, and related APIs. Covers item information, bag management, banking, looting, equipment, gem sockets, item upgrades, merchant interactions, and world loot objects.

> **Source:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API
> **Current as of:** Patch 12.0.0 (Build 65655) — January 28, 2026
> **Scope:** Retail only. No deprecated or removed functions.

## Scope

This skill covers these API systems:

- **C_Item** — Item information, counts, cooldowns, equipping, type checks, transmog info
- **C_Container** — Bag slot management, item queries, sorting, searching, using items
- **C_Bank** — Bank tab management, deposits, withdrawals, account bank
- **C_Loot** — Loot roll duration, legacy loot mode
- **C_ItemSocketInfo** — Gem socket management
- **C_ItemInteraction** — Item conversion/interaction UI
- **C_MerchantFrame** — Vendor buy/sell/repair
- **C_WorldLootObject** — World loot object queries
- **ItemLocation / ItemMixin** — Item location handling patterns
- **Global Inventory Functions** — PickupInventoryItem, EquipItemByName, UseInventoryItem, etc.
- **Looting Functions** — LootSlot, GetNumLootItems, RollOnLoot, ConfirmLootRoll, etc.
- **Equipment Sets** — C_EquipmentSet functions

## When to Use This Skill

Use this skill when you need to:
- Query item info: name, link, icon, quality, type, subtype, level
- Check item counts, cooldowns, or usability
- Equip or use items programmatically
- Manage bag contents: enumerate slots, sort, search, move items
- Interact with the bank: deposit, withdraw, purchase tabs
- Handle loot windows and loot rolls
- Work with gem sockets and item upgrades
- Buy from or sell to merchants
- Check equipment sets
- Handle world loot objects (e.g., loot on the ground)

---

## C_Item — Core Item API

The `C_Item` namespace provides comprehensive item data access. Items are identified by `itemInfo` (itemID, itemName, or itemLink) or `ItemLocation` (bag + slot).

> **Wiki:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#Item

### Item Information

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Item.GetItemInfo(itemInfo)` | `itemName, itemLink, quality, itemLevel, reqLevel, class, subclass, maxStack, equipLoc, icon, vendorPrice, classID, subClassID, bindType, expacID, setID, isCraftingReagent` | Full item data (may require server query) |
| `C_Item.GetItemInfoInstant(itemInfo)` | `itemID, itemType, itemSubType, itemEquipLoc, icon, classID, subClassID` | Instant item data (no server query needed) |
| `C_Item.GetItemName(itemLocation)` | `itemName` | Name from ItemLocation |
| `C_Item.GetItemLink(itemLocation)` | `itemLink` | Hyperlink from ItemLocation |
| `C_Item.GetItemIcon(itemLocation)` | `icon` | Icon texture from ItemLocation |
| `C_Item.GetItemIconByID(itemInfo)` | `icon` | Icon texture by item ID/name/link |
| `C_Item.GetItemQualityByID(itemInfo)` | `quality` | Quality enum value |
| `C_Item.GetItemQualityColor(quality)` | `r, g, b, hex` | Color for item quality |
| `C_Item.GetCurrentItemLevel(itemLocation)` | `currentItemLevel` | Effective item level |
| `C_Item.GetItemClassInfo(itemClassID)` | `result` | Name of item class (Armor, Weapon, etc.) |
| `C_Item.GetItemSubClassInfo(itemClassID, itemSubClassID)` | `subClassName, isArmorType` | Subclass name |
| `C_Item.GetItemFamily(itemInfo)` | `result` | Bag type flags for the item |
| `C_Item.GetItemGUID(itemLocation)` | `itemGUID` | Unique item GUID |
| `C_Item.GetItemCreationContext(itemInfo)` | `itemID, creationContext` | How the item was created |
| `C_Item.GetItemUpgradeInfo(itemInfo)` | `itemUpgradeInfo` | Upgrade track and level |
| `C_Item.GetItemUniqueness(itemInfo)` | `limitCategory, limitMax` | Unique-equip limits |
| `C_Item.GetItemUniquenessByID(itemInfo)` | `isUnique, limitCategoryName, limitCategoryCount, limitCategoryID` | Detailed uniqueness |

### Item Counts & Cooldowns

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Item.GetItemCount(itemInfo [, includeBank [, includeUses [, includeReagentBank [, includeAccountBank]]]])` | `count` | Total item count across inventories |
| `C_Item.GetItemCooldown(itemInfo)` | `startTimeSeconds, durationSeconds, enableCooldownTimer` | Item use cooldown |
| `C_Item.GetStackCount(itemLocation)` | `stackCount` | Stack count at a location |

### Item Type Checks

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Item.DoesItemExist(emptiableItemLocation)` | `itemExists` | Item exists at location? |
| `C_Item.DoesItemExistByID(itemInfo)` | `itemExists` | Item exists by ID? |
| `C_Item.DoesItemContainSpec(itemInfo, classID [, specID])` | `result` | Suitable for spec? |
| `C_Item.IsEquippableItem(itemInfo)` | `result` | Can be equipped? |
| `C_Item.IsEquippedItem(itemInfo)` | `result` | Currently equipped? |
| `C_Item.IsEquippedItemType(type)` | `result` | Item type currently equipped? |
| `C_Item.IsConsumableItem(itemInfo)` | `result` | Is consumable? |
| `C_Item.IsCosmeticItem(itemInfo)` | `result` | Is cosmetic? |
| `C_Item.IsDecorItem(itemInfo)` | `isDecor` | Is housing decoration? |
| `C_Item.IsCurioItem(itemInfo)` | `result` | Is delve curio? |
| `C_Item.IsHelpfulItem(itemInfo)` | `result` | Usable on friendly units? |
| `C_Item.IsHarmfulItem(itemInfo)` | `result` | Usable on hostile units? |
| `C_Item.IsBound(itemLocation)` | `isBound` | Is soulbound? |
| `C_Item.IsBoundToAccountUntilEquip(itemLocation)` | `isBoundToAccountUntilEquip` | Account-bound until equipped? |
| `C_Item.IsItemBindToAccount(itemInfo)` | `isItemBindToAccount` | Account-bound? |
| `C_Item.IsItemKeystoneByID(itemInfo)` | `isKeystone` | Is M+ keystone? |
| `C_Item.IsItemInRange(itemInfo, targetToken)` | `result` | In usable range? `#nocombat` |
| `C_Item.IsItemDataCached(itemLocation)` | `isCached` | Data available locally? |
| `C_Item.IsItemDataCachedByID(itemInfo)` | `isCached` | Data cached by ID? |
| `C_Item.IsCurrentItem(itemInfo)` | `result` | Currently active? |
| `C_Item.IsDressableItemByID(itemInfo)` | `isDressableItem` | Can be previewed? |
| `C_Item.IsAnimaItemByID(itemInfo)` | `isAnimaItem` | Is anima item? |
| `C_Item.IsLocked(itemLocation)` | `isLocked` | Is locked (opening)? |

### Item Actions

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Item.EquipItemByName(itemInfo [, dstSlot])` | — | Equips an item |
| `C_Item.ConfirmOnUse()` | — | Confirms item use |
| `C_Item.ConfirmBindOnUse()` | — | Confirms bind-on-use `#protected` |
| `C_Item.ConfirmNoRefundOnUse()` | — | Confirms no-refund `#protected` |
| `C_Item.EndRefund(type)` | — | Confirms non-refundable |
| `C_Item.RequestLoadItemData(itemLocation)` | — | Requests server item data |
| `C_Item.RequestLoadItemDataByID(itemInfo)` | — | Requests data by ID |

### Item Transmog

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Item.GetAppliedItemTransmogInfo(itemLoc)` | `info` | Applied transmog |
| `C_Item.GetBaseItemTransmogInfo(itemLoc)` | `info` | Base appearance |
| `C_Item.GetCurrentItemTransmogInfo(itemLoc)` | `info` | Current visual |
| `C_Item.GetItemLearnTransmogSet(itemInfo)` | `setID` | Transmog set this teaches |

---

## C_Container — Bag & Container API

Manages bag slots, item queries, sorting, and item operations within bags.

> **Wiki:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#Container

### Bag Constants

| Constant | Value | Description |
|----------|-------|-------------|
| `Enum.BagIndex.Backpack` | 0 | Main backpack |
| `Enum.BagIndex.BagSlot1..4` | 1–4 | Equipped bag slots |
| `Enum.BagIndex.BankBag` | -1 | Main bank |
| `Enum.BagIndex.BankBagSlot1..7` | 5–11 | Bank bag slots |
| `Enum.BagIndex.ReagentBag` | 5 | Reagent bag slot |
| `KEYRING_CONTAINER` | -2 | Keyring (legacy) |
| `Enum.BagIndex.AccountBankTab1..5` | 13–17 | Account bank tabs |

### Container Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Container.GetContainerNumSlots(containerIndex)` | `numSlots` | Number of slots in bag |
| `C_Container.GetContainerNumFreeSlots(bagIndex)` | `numFreeSlots, bagFamily` | Free slots and bag type |
| `C_Container.GetContainerFreeSlots(containerIndex)` | `freeSlots` | Array of free slot indices |
| `C_Container.GetContainerItemInfo(containerIndex, slotIndex)` | `containerInfo` | Full item info at slot |
| `C_Container.GetContainerItemID(containerIndex, slotIndex)` | `containerID` | Item ID at slot |
| `C_Container.GetContainerItemLink(containerIndex, slotIndex)` | `itemLink` | Item hyperlink at slot |
| `C_Container.GetContainerItemQuestInfo(containerIndex, slotIndex)` | `questInfo` | Quest item status |
| `C_Container.GetContainerItemCooldown(containerIndex, slotIndex)` | `startTime, duration, enable` | Item cooldown |
| `C_Container.GetContainerItemDurability(containerIndex, slotIndex)` | `durability, maxDurability` | Durability |
| `C_Container.GetContainerItemEquipmentSetInfo(containerIndex, slotIndex)` | `inSet, setList` | Equipment set membership |
| `C_Container.GetContainerItemPurchaseInfo(containerIndex, slotIndex, isEquipped)` | `info` | Refund info |
| `C_Container.HasContainerItem(containerIndex, slotIndex)` | `hasItem` | Slot occupied? |
| `C_Container.GetBagName(bagIndex)` | `name` | Bag item name |
| `C_Container.GetBagSlotFlag(bagIndex, flag)` | `isSet` | Bag filter flag |
| `C_Container.IsContainerFiltered(containerIndex)` | `isFiltered` | Bag is filtered? |
| `C_Container.IsBattlePayItem(containerIndex, slotIndex)` | `isBattlePayItem` | Store-bought item? |
| `C_Container.ContainerIDToInventoryID(containerID)` | `inventoryID` | Convert bag ID to inventory slot |

### Container Actions

| Function | Description |
|----------|-------------|
| `C_Container.UseContainerItem(containerIndex, slotIndex [, unitToken [, bankType [, reagentBankOpen]]])` | Use/equip item in bag |
| `C_Container.SplitContainerItem(containerIndex, slotIndex, amount)` | Split a stack |
| `C_Container.PickupContainerItem(containerIndex, slotIndex)` | Pick up item to cursor |
| `C_Container.SocketContainerItem(containerIndex, slotIndex)` | Open socket UI for item |
| `C_Container.ShowContainerSellCursor(containerIndex, slotIndex)` | Show sell cursor |
| `C_Container.ContainerRefundItemPurchase(containerIndex, slotIndex [, isEquipped])` | Refund item |
| `C_Container.UseHearthstone()` | Use hearthstone |
| `C_Container.SetItemSearch(searchString)` | Filter bags by search text |

### Sorting & Settings

| Function | Description |
|----------|-------------|
| `C_Container.SortBags()` | Sort all bags |
| `C_Container.SortBankBags()` | Sort bank bags |
| `C_Container.SortAccountBankBags()` | Sort account bank bags |
| `C_Container.SortBank(bankType)` | Sort specific bank type |
| `C_Container.SetBagSlotFlag(bagIndex, flag, isSet)` | Set bag filtering flag |
| `C_Container.SetBackpackAutosortDisabled(disable)` | Disable backpack auto-sort |
| `C_Container.SetBankAutosortDisabled(disable)` | Disable bank auto-sort |
| `C_Container.GetBackpackAutosortDisabled()` | Check backpack auto-sort |
| `C_Container.GetBankAutosortDisabled()` | Check bank auto-sort |
| `C_Container.GetSortBagsRightToLeft()` | Sort direction |
| `C_Container.SetSortBagsRightToLeft(enable)` | Set sort direction |
| `C_Container.GetInsertItemsLeftToRight()` | Insert direction |
| `C_Container.SetInsertItemsLeftToRight(enable)` | Set insert direction |
| `C_Container.GetBackpackSellJunkDisabled()` | Auto-sell junk disabled? |

---

## C_Bank — Bank API

Manages character bank, reagent bank, and account bank (Warband bank) tabs.

> **Wiki:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#Bank

### Bank Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Bank.CanUseBank(bankType)` | `canUseBank` | Bank type accessible? |
| `C_Bank.CanViewBank(bankType)` | `canViewBank` | Can view bank? |
| `C_Bank.AreAnyBankTypesViewable()` | `areAnyBankTypesViewable` | Any bank viewable? |
| `C_Bank.FetchViewableBankTypes()` | `viewableBankTypes` | List of viewable types |
| `C_Bank.FetchNumPurchasedBankTabs(bankType)` | `numPurchasedBankTabs` | Purchased tab count |
| `C_Bank.FetchPurchasedBankTabIDs(bankType)` | `purchasedBankTabIDs` | Purchased tab ID list |
| `C_Bank.FetchPurchasedBankTabData(bankType)` | `purchasedBankTabData` | Tab configuration data |
| `C_Bank.FetchNextPurchasableBankTabData(bankType)` | `nextPurchasableTabData` | Next unlock info |
| `C_Bank.FetchDepositedMoney(bankType)` | `amount` | Money stored in bank |
| `C_Bank.FetchBankLockedReason(bankType)` | `reason` | Why bank is locked |
| `C_Bank.CanPurchaseBankTab(bankType)` | `canPurchaseBankTab` | Can buy another tab? |
| `C_Bank.HasMaxBankTabs(bankType)` | `hasMaxBankTabs` | All tabs purchased? |
| `C_Bank.CanDepositMoney(bankType)` | `canDepositMoney` | Can deposit gold? |
| `C_Bank.CanWithdrawMoney(bankType)` | `canWithdrawMoney` | Can withdraw gold? |
| `C_Bank.IsItemAllowedInBankType(bankType, itemLocation)` | `isItemAllowedInBankType` | Item fits this bank? |
| `C_Bank.DoesBankTypeSupportAutoDeposit(bankType)` | `doesBankTypeSupportAutoDeposit` | Supports auto-deposit? |
| `C_Bank.DoesBankTypeSupportMoneyTransfer(bankType)` | `doesBankTypeSupportMoneyTransfer` | Supports money? |

### Bank Actions

| Function | Description |
|----------|-------------|
| `C_Bank.PurchaseBankTab(bankType)` | Purchase a bank tab |
| `C_Bank.UpdateBankTabSettings(bankType, tabID, tabName, tabIcon, depositFlags)` | Update tab settings |
| `C_Bank.AutoDepositItemsIntoBank(bankType)` | Auto-deposit items |
| `C_Bank.DepositMoney(bankType, amount)` | Deposit money |
| `C_Bank.WithdrawMoney(bankType, amount)` | Withdraw money |
| `C_Bank.CloseBankFrame()` | Close bank |

---

## Loot API

### C_Loot

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Loot.GetLootRollDuration(rollID)` | `duration` | Roll timer duration |
| `C_Loot.IsLegacyLootModeEnabled()` | `isLegacyLootModeEnabled` | Legacy loot active? |

### Global Loot Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `GetNumLootItems()` | `numLootItems` | Items in loot window |
| `GetLootInfo()` | `info` | Loot slot info table |
| `GetLootSlotInfo(lootSlot)` | `icon, name, quantity, currencyID, quality, locked, isQuestItem, questID, isActive` | Slot details |
| `GetLootSlotLink(lootSlot)` | `itemLink` | Item link for loot slot |
| `GetLootSlotType(lootSlot)` | `slotType` | Slot content type |
| `GetLootSourceInfo(lootSlot)` | `guid, quantity` | Source of loot |
| `LootSlot(slot)` | — | Loot the slot |
| `LootSlotHasItem(lootSlot)` | `isLootItem` | Slot has item? |
| `ConfirmLootSlot(slot)` | — | Confirm BoP loot |
| `CloseLoot([errNum])` | — | Close loot window |
| `IsFishingLoot()` | `isFishingLoot` | Loot from fishing? |
| `GetOptOutOfLoot()` | `optedOut` | Auto-passing all loot? |
| `SetOptOutOfLoot(optOut)` | — | Set auto-pass |

### Loot Rolls

| Function | Returns | Description |
|----------|---------|-------------|
| `RollOnLoot(rollID [, rollType])` | — | Roll/pass on loot |
| `ConfirmLootRoll(rollID, roll)` | — | Confirm BoP roll |
| `GetLootRollItemInfo(rollID)` | `texture, name, count, quality, ...` | Roll item details |
| `GetLootRollItemLink(rollID)` | `itemLink` | Roll item link |
| `GetLootRollTimeLeft(rollID)` | `timeLeft` | Roll time remaining |
| `GetActiveLootRollIDs()` | `rollIDs` | Active roll IDs |
| `GetLootThreshold()` | `threshold` | Group loot threshold |

---

## C_ItemSocketInfo — Socket API

| Function | Returns | Description |
|----------|---------|-------------|
| `C_ItemSocketInfo.GetNumSockets()` | `numSockets` | Number of sockets |
| `C_ItemSocketInfo.GetSocketTypes(index)` | `socketType` | Socket color/type |
| `C_ItemSocketInfo.GetExistingSocketInfo(index)` | `name, icon, gemMatchesSocket` | Current gem info |
| `C_ItemSocketInfo.GetExistingSocketLink(index)` | `existingSocketLink` | Current gem link |
| `C_ItemSocketInfo.GetNewSocketInfo(index)` | `name, icon, gemMatchesSocket` | Proposed gem info |
| `C_ItemSocketInfo.GetNewSocketLink(index)` | `newSocketLink` | Proposed gem link |
| `C_ItemSocketInfo.GetSocketItemInfo()` | `name, icon, quality` | Item being socketed |
| `C_ItemSocketInfo.GetSocketItemBoundTradeable()` | `socketItemTradeable` | Still tradeable? |
| `C_ItemSocketInfo.GetSocketItemRefundable()` | `socketItemRefundable` | Still refundable? |
| `C_ItemSocketInfo.HasBoundGemProposed()` | `hasBoundGemProposed` | BoP gem selected? |
| `C_ItemSocketInfo.GetCurrUIType()` | `uiType` | Socket UI type |
| `C_ItemSocketInfo.IsArtifactRelicItem(info)` | `isArtifactRelicItem` | Is relic? (Legacy) |
| `C_ItemSocketInfo.AcceptSockets()` | — | Apply gem changes |
| `C_ItemSocketInfo.ClickSocketButton(index)` | — | Click a socket slot |
| `C_ItemSocketInfo.CloseSocketInfo()` | — | Close socket UI |
| `C_ItemSocketInfo.CompleteSocketing()` | — | Finalize socketing |

---

## C_ItemInteraction — Item Interaction UI

| Function | Returns | Description |
|----------|---------|-------------|
| `C_ItemInteraction.GetItemInteractionInfo()` | `info` | Interaction frame info |
| `C_ItemInteraction.GetItemInteractionSpellId()` | `spellId` | Spell for interaction |
| `C_ItemInteraction.GetChargeInfo()` | `chargeInfo` | Charge tracking |
| `C_ItemInteraction.GetItemConversionCurrencyCost(item)` | `conversionCost` | Currency cost |
| `C_ItemInteraction.InitializeFrame()` | — | Initialize interaction |
| `C_ItemInteraction.PerformItemInteraction()` | — | Execute interaction |
| `C_ItemInteraction.ClearPendingItem()` | — | Clear selected item |
| `C_ItemInteraction.CloseUI()` | — | Close UI |

---

## C_MerchantFrame — Merchant/Vendor API

| Function | Returns | Description |
|----------|---------|-------------|
| `C_MerchantFrame.GetItemInfo(index)` | `itemInfo` | Vendor item info (12.0.0 replacement) |
| `BuyMerchantItem(index [, quantity])` | — | Buy from vendor |
| `BuybackItem(slot)` | — | Buy back sold item |
| `CanMerchantRepair()` | `canRepair` | Vendor can repair? |
| `RepairAllItems([guildBankRepair])` | — | Repair all items |
| `GetRepairAllCost()` | `repairAllCost, canRepair` | Total repair cost |
| `CloseMerchant()` | — | Close vendor window |
| `GetMerchantNumItems()` | `numItems` | Number of vendor items |
| `GetBuybackItemInfo(slotIndex)` | `name, icon, price, ...` | Buyback item info |
| `GetNumBuybackItems()` | `numItems` | Buyback slot count |
| `GetMerchantItemMaxStack(index)` | `maxStack` | Max purchasable stack |

---

## C_WorldLootObject — World Loot Objects

| Function | Returns | Description |
|----------|---------|-------------|
| `C_WorldLootObject.IsWorldLootObject(unitToken)` | `isWorldLootObject` | Is world loot? |
| `C_WorldLootObject.GetWorldLootObjectInfo(unitToken)` | `info` | Loot object details |
| `C_WorldLootObject.GetWorldLootObjectInfoByGUID(objectGUID)` | `info` | Info by GUID |
| `C_WorldLootObject.GetWorldLootObjectDistanceSquared(unitToken)` | `distanceSquared` | Distance to object |
| `C_WorldLootObject.DoesSlotMatchInventoryType(slot, inventoryType)` | `matches` | Slot/type match? |

---

## ItemLocation & ItemMixin Patterns

### ItemLocation

`ItemLocation` is used to reference items by their container position:

```lua
-- Create an ItemLocation for bag 0, slot 1
local itemLoc = ItemLocation:CreateFromBagAndSlot(0, 1)

-- Create for an equipped slot
local itemLoc = ItemLocation:CreateFromEquipmentSlot(INVSLOT_HEAD)

-- Check if it's valid
if itemLoc:IsValid() then
    local name = C_Item.GetItemName(itemLoc)
end
```

### Item Data Loading (ContinuableContainer)

```lua
-- Items may not be cached — use the callback pattern
local item = Item:CreateFromItemID(12345)
item:ContinueOnItemLoad(function()
    local name = item:GetItemName()
    local link = item:GetItemLink()
    local icon = item:GetItemIcon()
    print(name, link)
end)
```

### Batch Loading

```lua
local container = ContinuableContainer:Create()
for _, itemID in ipairs(itemIDs) do
    local item = Item:CreateFromItemID(itemID)
    container:AddContinuable(item)
end
container:ContinueOnLoad(function()
    -- All items are now cached
end)
```

---

## Global Inventory Functions

| Function | Description |
|----------|-------------|
| `PickupInventoryItem(slot)` | Pick up equipped item |
| `UseInventoryItem(slot)` | Use equipped item |
| `GetInventoryItemID(unit, slot)` | Get item ID in equipment slot |
| `GetInventoryItemLink(unit, slot)` | Get item link in equipment slot |
| `GetInventoryItemTexture(unit, slot)` | Get icon for equipment slot |
| `GetInventoryItemQuality(unit, slot)` | Get quality for equipment slot |
| `GetInventoryItemCount(unit, slot)` | Get stack count in equipment slot |
| `GetInventoryItemDurability(slot)` | Get durability of equipped item |
| `GetInventoryItemBroken(slot)` | Check if equipment is broken |
| `GetInventorySlotInfo(slotName)` | Get slot index and texture |
| `AutoEquipCursorItem()` | Auto-equip cursor item |
| `EquipCursorItem(slot)` | Equip cursor item to slot |
| `CancelPendingEquip(index)` | Cancel pending equip confirm |
| `SocketInventoryItem(slot)` | Open socket UI for equipped item |

---

## Equipment Sets (C_EquipmentSet)

| Function | Returns | Description |
|----------|---------|-------------|
| `C_EquipmentSet.GetEquipmentSetIDs()` | `setIDs` | All set IDs |
| `C_EquipmentSet.GetEquipmentSetInfo(setID)` | `info` | Set name, icon, etc. |
| `C_EquipmentSet.GetItemIDs(setID)` | `itemIDs` | Items in set by slot |
| `C_EquipmentSet.GetItemLocations(setID)` | `itemLocations` | Item locations per slot |
| `C_EquipmentSet.EquipmentSetContainsLockedItems(setID)` | `hasLockedItems` | Any items locked? |
| `C_EquipmentSet.CreateEquipmentSet(name, icon)` | — | Create new set |
| `C_EquipmentSet.SaveEquipmentSet(setID [, icon])` | — | Save current gear to set |
| `C_EquipmentSet.UseEquipmentSet(setID)` | `result` | Equip a set |
| `C_EquipmentSet.DeleteEquipmentSet(setID)` | — | Delete a set |
| `C_EquipmentSet.ModifyEquipmentSet(setID, name [, icon])` | — | Rename/re-icon set |
| `C_EquipmentSet.GetNumEquipmentSets()` | `numSets` | Count of sets |
| `C_EquipmentSet.GetEquipmentSetForSlot(slot)` | `setIDs` | Sets using this slot |
| `C_EquipmentSet.CanUseEquipmentSets()` | `canUse` | Equipment sets available? |

---

## Cursor Functions (Item-Related)

| Function | Returns | Description |
|----------|---------|-------------|
| `ClearCursor()` | — | Clear cursor contents |
| `CursorHasItem()` | `result` | Cursor holds item? |
| `CursorHasMoney()` | `result` | Cursor holds money? |
| `CursorHasSpell()` | `result` | Cursor holds spell? |
| `GetCursorInfo()` | `type, ...` | What's on cursor |
| `PickupBagFromSlot(slot)` | — | Pick up a bag |
| `PickupItem(itemInfo)` | — | Pick up by ID/name |
| `PickupMerchantItem(index)` | — | Pick up from merchant |
| `DeleteCursorItem()` | — | Destroy cursor item |

---

## Common Patterns

### Iterate All Bag Items

```lua
for bag = 0, 4 do
    for slot = 1, C_Container.GetContainerNumSlots(bag) do
        local info = C_Container.GetContainerItemInfo(bag, slot)
        if info then
            print(info.hyperlink, info.stackCount, info.quality)
        end
    end
end
```

### Count Free Bag Slots

```lua
local totalFree = 0
for bag = 0, 4 do
    local free = C_Container.GetContainerNumFreeSlots(bag)
    totalFree = totalFree + free
end
print("Free slots:", totalFree)
```

### Check If Player Has Item

```lua
local count = C_Item.GetItemCount(12345, true) -- includeBank
if count > 0 then
    print("You have", count, "of this item")
end
```

### Auto-Sell Junk at Vendor

```lua
-- Register for MERCHANT_SHOW event
for bag = 0, 4 do
    for slot = 1, C_Container.GetContainerNumSlots(bag) do
        local info = C_Container.GetContainerItemInfo(bag, slot)
        if info and info.quality == Enum.ItemQuality.Poor then
            C_Container.UseContainerItem(bag, slot)
        end
    end
end
```

---

## Key Events

| Event | Payload | Description |
|-------|---------|-------------|
| `BAG_UPDATE` | `bagID` | Bag contents changed |
| `BAG_UPDATE_DELAYED` | — | Fires after all BAG_UPDATE |
| `ITEM_LOCK_CHANGED` | `bagOrSlotIndex, slotIndex` | Item lock state changed |
| `ITEM_LOCKED` | `bagID, slotID` | Item became locked |
| `ITEM_UNLOCKED` | `bagID, slotID` | Item unlocked |
| `GET_ITEM_INFO_RECEIVED` | `itemID, success` | Async item data arrived |
| `BANKFRAME_OPENED` | — | Bank window opened |
| `BANKFRAME_CLOSED` | — | Bank window closed |
| `PLAYERBANKSLOTS_CHANGED` | `slot` | Bank slot changed |
| `PLAYERBANKBAGSLOTS_CHANGED` | — | Bank bag slots changed |
| `LOOT_READY` | `autoLoot` | Loot window ready |
| `LOOT_OPENED` | `autoLoot` | Loot window opened |
| `LOOT_CLOSED` | — | Loot window closed |
| `LOOT_SLOT_CLEARED` | `lootSlot` | Loot slot taken |
| `START_LOOT_ROLL` | `rollID, rollTime, lootHandle` | Roll started |
| `CONFIRM_LOOT_ROLL` | `rollID, roll, confirmReason` | Confirm BoP roll |
| `LOOT_ROLL_COMPLETE` | `rollID` | Roll finished |
| `MERCHANT_SHOW` | — | Vendor window opened |
| `MERCHANT_CLOSED` | — | Vendor window closed |
| `MERCHANT_UPDATE` | — | Vendor items updated |
| `EQUIPMENT_SETS_CHANGED` | — | Equipment sets modified |
| `EQUIPMENT_SWAP_FINISHED` | `result, setID` | Set swap done |
| `ITEM_INTERACTION_OPEN` | — | Item interaction opened |
| `ITEM_INTERACTION_CLOSE` | — | Item interaction closed |
| `SOCKET_INFO_UPDATE` | — | Socket UI data updated |
| `SOCKET_INFO_CLOSE` | — | Socket UI closed |
| `ACCOUNT_BANK_TAB_PURCHASE_SUCCEEDED` | — | Account bank tab bought |

---

## Gotchas & Restrictions

1. **Async item data** — `C_Item.GetItemInfo()` may return nil for uncached items. Use `C_Item.RequestLoadItemDataByID()` and listen for `GET_ITEM_INFO_RECEIVED`, or use the `Item:ContinueOnItemLoad()` mixin pattern.
2. **Bag index 5** — In Retail, bag index 5 is the Reagent Bag slot, not a bank bag.
3. **Account Bank** — Account bank tabs (Warband bank) use `Enum.BagIndex.AccountBankTab1..5` (indices 13–17). Check `C_PlayerInfo.IsAccountBankEnabled()`.
4. **GetMerchantItemInfo removed** — Use `C_MerchantFrame.GetItemInfo(index)` in 12.0.0.
5. **Protected functions** — `EquipItemByName`, `UseContainerItem`, and similar functions may be restricted during combat lockdown.
6. **Item secrets** — In 12.0.0 instances, some item-related data may become secret values. Design UIs to pass values directly to widgets.
7. **ContainerInfo structure** — `C_Container.GetContainerItemInfo()` returns a table with fields: `iconFileID`, `stackCount`, `isLocked`, `quality`, `isReadable`, `hasLoot`, `hyperlink`, `isFiltered`, `hasNoValue`, `itemID`, `isBound`.
