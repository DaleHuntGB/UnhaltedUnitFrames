---
name: wow-api-professions
description: "Complete reference for WoW Retail Professions, Tradeskill, Crafting Orders, Recipe, and Profession Specialization APIs. Covers C_TradeSkillUI (recipe list, crafting, reagents, skill lines, categories, recrafting, salvage, enchanting), C_CraftingOrders (customer/crafter order system, public/private/guild orders, order creation, fulfillment, listing), C_ProfessionSpecUI (profession knowledge, specialization trees), global tradeskill functions, and profession-specific patterns. Use when working with professions, recipes, crafting, work orders, crafting orders, profession specialization, or tradeskill UI."
---

# Professions API (Retail — Patch 12.0.0)

Comprehensive reference for professions, crafting, and crafting order APIs.

> **Source:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API
> **Current as of:** Patch 12.0.0 (Build 65655) — January 28, 2026
> **Scope:** Retail only.

---

## Scope

- **C_TradeSkillUI** — Recipe browsing, crafting, reagents, skill info
- **C_CraftingOrders** — Crafting order system (customer & crafter)
- **C_ProfessionSpecUI** — Profession specialization trees
- **Global TradeSKill** — Legacy/global tradeskill functions

---

## C_TradeSkillUI — Tradeskill System

### Opening & State

| Function | Returns | Description |
|----------|---------|-------------|
| `C_TradeSkillUI.OpenTradeSkill(tradeSkillID)` | `success` | Open tradeskill UI |
| `C_TradeSkillUI.CloseTradeSkill()` | — | Close tradeskill UI |
| `C_TradeSkillUI.IsTradeSkillReady()` | `isReady` | Is tradeskill data ready? |
| `C_TradeSkillUI.IsTradeSkillGuild()` | `isGuild` | Viewing guild crafters? |
| `C_TradeSkillUI.IsTradeSkillLinked()` | `isLinked` | Viewing linked tradeskill? |
| `C_TradeSkillUI.IsNPCCrafting()` | `isNPC` | Crafting at NPC? |
| `C_TradeSkillUI.IsRecraftReady()` | `isReady` | Recraft system ready? |
| `C_TradeSkillUI.GetTradeSkillDisplayName(tradeSkillID)` | `name` | Profession name |

### Profession Info

| Function | Returns | Description |
|----------|---------|-------------|
| `C_TradeSkillUI.GetProfessionInfoBySkillLineID(skillLineID)` | `professionInfo` | Profession info |
| `C_TradeSkillUI.GetChildProfessionInfos()` | `infos` | Child profession tiers |
| `C_TradeSkillUI.GetProfessionInfoByRecipeID(recipeID)` | `professionInfo` | Profession for recipe |
| `C_TradeSkillUI.GetBaseProfessionInfo()` | `professionInfo` | Base profession info |
| `C_TradeSkillUI.GetProfessionSlots(profession)` | `slots` | Profession slots |
| `C_TradeSkillUI.GetProfessionChararacterSlotInfo(slot)` | `info` | Character slot info |

### Recipe List & Info

| Function | Returns | Description |
|----------|---------|-------------|
| `C_TradeSkillUI.GetAllRecipeIDs()` | `recipeIDs` | All available recipes |
| `C_TradeSkillUI.GetFilteredRecipeIDs()` | `recipeIDs` | Filtered recipe list |
| `C_TradeSkillUI.GetRecipeInfo(recipeID)` | `recipeInfo` | Recipe details |
| `C_TradeSkillUI.GetRecipeSchematic(recipeID, isRecraft [, recraftItemGUID])` | `schematic` | Recipe schematic |
| `C_TradeSkillUI.GetRecipeDescription(recipeID)` | `description` | Recipe description text |
| `C_TradeSkillUI.GetRecipeNumItemsProduced(recipeID)` | `min, max` | Items produced |
| `C_TradeSkillUI.GetRecipeOutputItemData(recipeID [, reagents [, allocationItemGUID]])` | `outputInfo` | Output item data |
| `C_TradeSkillUI.GetRecipeQualityItemIDs(recipeID)` | `itemIDs` | Quality-tier item IDs |
| `C_TradeSkillUI.GetRecipeQualityReagentItemLink(recipeSpellID, reagentIndex, qualityIndex)` | `itemLink` | Quality reagent link |
| `C_TradeSkillUI.GetRecipeRepeatCount()` | `repeatCount` | Queue repeat count |
| `C_TradeSkillUI.SetRecipeRepeatCount(count)` | — | Set repeat count |

### Reagents

| Function | Returns | Description |
|----------|---------|-------------|
| `C_TradeSkillUI.GetRecipeReagentSlotInfo(recipeID, reagentIndex)` | `slotInfo` | Reagent slot info |
| `C_TradeSkillUI.GetRecipeRequirements(recipeID)` | `requirements` | Recipe requirements |
| `C_TradeSkillUI.GetOptionalReagentInfo(recipeID)` | `optionalReagents` | Optional reagent slots |
| `C_TradeSkillUI.GetRecipeFixedReagentItemLink(recipeID, dataSlotIndex)` | `itemLink` | Fixed reagent link |

### Crafting

| Function | Returns | Description |
|----------|---------|-------------|
| `C_TradeSkillUI.CraftRecipe(recipeID [, count [, craftingReagents [, recipeLevel [, orderID]]]])` | — | Craft items |
| `C_TradeSkillUI.RecraftRecipe(itemGUID, craftingReagents)` | — | Recraft an item |
| `C_TradeSkillUI.CraftSalvage(recipeID, count, itemTarget)` | — | Salvage crafting |
| `C_TradeSkillUI.CraftEnchant(recipeID [, count [, craftingReagents]])` | — | Craft enchant |
| `C_TradeSkillUI.IsRecipeInBaseSkillLine(recipeID)` | `inBase` | Is recipe in base skill? |

### Categories & Filters

| Function | Returns | Description |
|----------|---------|-------------|
| `C_TradeSkillUI.GetCategories()` | `categoryIDs` | All categories |
| `C_TradeSkillUI.GetCategoryInfo(categoryID)` | `categoryInfo` | Category details |
| `C_TradeSkillUI.GetSubCategories(categoryID)` | `subCategoryIDs` | Sub-categories |
| `C_TradeSkillUI.SetRecipeItemNameFilter(text)` | — | Filter by name |
| `C_TradeSkillUI.GetRecipeItemNameFilter()` | `text` | Current name filter |
| `C_TradeSkillUI.SetOnlyShowMakeableRecipes(onlyMakeable)` | — | Filter to makeable |
| `C_TradeSkillUI.GetOnlyShowMakeableRecipes()` | `onlyMakeable` | Showing only makeable? |
| `C_TradeSkillUI.SetOnlyShowSkillUpRecipes(onlySkillUp)` | — | Filter to skill-up |
| `C_TradeSkillUI.GetOnlyShowSkillUpRecipes()` | `onlySkillUp` | Only skill-up? |

---

## C_CraftingOrders — Crafting Orders

### Customer (Placing Orders)

| Function | Returns | Description |
|----------|---------|-------------|
| `C_CraftingOrders.PlaceNewOrder(orderInfo)` | — | Place a crafting order |
| `C_CraftingOrders.GetMyOrders(orderType)` | `orders` | Your placed orders |
| `C_CraftingOrders.GetOrderClaimInfo(orderType, orderID)` | `claimInfo` | Order claim info |
| `C_CraftingOrders.CancelOrder(orderID)` | — | Cancel your order |
| `C_CraftingOrders.GetCustomerOptions(skillLineAbilityID, orderType)` | `options` | Customer options |
| `C_CraftingOrders.GetCraftingOrderCost(recipeID, reagents, orderType)` | `cost` | Order commission cost |
| `C_CraftingOrders.GetDefaultOrdersSkillLine()` | `skillLineID` | Default skill line |
| `C_CraftingOrders.GetPersonalOrdersInfo()` | `info` | Personal orders info |
| `C_CraftingOrders.HasFavoriteCustomerOptions(skillLineAbilityID)` | `hasFavorite` | Has favorited crafter? |
| `C_CraftingOrders.ShouldShowCraftingOrderTab()` | `shouldShow` | Show orders tab? |

### Crafter (Fulfilling Orders)

| Function | Returns | Description |
|----------|---------|-------------|
| `C_CraftingOrders.GetCrafterOrders(request)` | — | Query available orders |
| `C_CraftingOrders.GetCrafterBucketTable(request)` | — | Get order grouped view |
| `C_CraftingOrders.GetClaimedOrder()` | `order` | Currently claimed order |
| `C_CraftingOrders.ClaimOrder(orderID, professionID)` | — | Claim an order |
| `C_CraftingOrders.ReleaseOrder(orderID, professionID)` | — | Release claimed order |
| `C_CraftingOrders.FulfillOrder(orderID, crafterNote, professionID)` | — | Complete the order |
| `C_CraftingOrders.RejectOrder(orderID, rejectionNote, professionID)` | — | Reject the order |
| `C_CraftingOrders.GetNumFavoriteCustomerOptions()` | `numFavorites` | Favorite customers count |
| `C_CraftingOrders.GetCrafterOrderRemainingTime(orderID)` | `timeRemaining` | Time left to fulfill |
| `C_CraftingOrders.OpenCrafterCraftingOrders()` | — | Open crafter orders UI |
| `C_CraftingOrders.CloseCrafterCraftingOrders()` | — | Close crafter orders UI |

### Order Types

| Enum | Description |
|------|-------------|
| `Enum.CraftingOrderType.Public` | Anyone can fulfill |
| `Enum.CraftingOrderType.Guild` | Guild members only |
| `Enum.CraftingOrderType.Personal` | Specific crafter |
| `Enum.CraftingOrderType.Npc` | NPC order |

---

## C_ProfessionSpecUI — Profession Specialization

| Function | Returns | Description |
|----------|---------|-------------|
| `C_ProfessionSpecUI.GetSpecTabInfo()` | `tabInfo` | Spec tab info |
| `C_ProfessionSpecUI.GetSpecTabIDsForSkillLineID(skillLineID)` | `specTabIDs` | Spec tabs for profession |
| `C_ProfessionSpecUI.ShouldShowSpecTab()` | `shouldShow` | Show spec tab? |
| `C_ProfessionSpecUI.GetRootPathForTab(specTabID)` | `rootPath` | Root path for spec tab |
| `C_ProfessionSpecUI.GetStateForPath(specTabID, pathID)` | `state` | Path state (locked, etc.) |
| `C_ProfessionSpecUI.GetStateForPerk(specTabID, perkID)` | `state` | Perk state |
| `C_ProfessionSpecUI.GetDescriptionForPath(pathID)` | `description` | Path description |
| `C_ProfessionSpecUI.GetDescriptionForPerk(perkID)` | `description` | Perk description |
| `C_ProfessionSpecUI.GetPerksForPath(pathID)` | `perkIDs` | Perks in path |
| `C_ProfessionSpecUI.GetChildrenForPath(pathID)` | `childPathIDs` | Child paths |
| `C_ProfessionSpecUI.GetSpendCurrencyForPath(pathID)` | `currencyID, amount` | Currency to spend |
| `C_ProfessionSpecUI.GetUnlockInfoForPath(pathID)` | `unlockInfo` | Unlock requirements |
| `C_ProfessionSpecUI.PurchaseSpecTabPerk(specTabID, perkID)` | — | Purchase a perk |

---

## Global Tradeskill Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `GetProfessions()` | `prof1, prof2, arch, fish, cook` | Character professions (indices) |
| `GetProfessionInfo(profIndex)` | `name, icon, skillLevel, maxSkillLevel, numAbilities, spellOffset, skillLineID, skillModifier, specIndex, specOffset` | Profession details |
| `CastSpell(spellID)` | — | Open profession via spell |

---

## Common Patterns

### List Player's Professions

```lua
local prof1, prof2, archaeology, fishing, cooking = GetProfessions()
local function PrintProf(index)
    if index then
        local name, icon, skillLevel, maxSkillLevel = GetProfessionInfo(index)
        print(name, skillLevel .. "/" .. maxSkillLevel)
    end
end
PrintProf(prof1)
PrintProf(prof2)
PrintProf(cooking)
```

### Search Recipes by Name

```lua
C_TradeSkillUI.SetRecipeItemNameFilter("Enchant")
local recipeIDs = C_TradeSkillUI.GetFilteredRecipeIDs()
for _, recipeID in ipairs(recipeIDs) do
    local info = C_TradeSkillUI.GetRecipeInfo(recipeID)
    if info then
        print(info.name, "Skill:", info.relativeDifficulty)
    end
end
```

### Craft an Item

```lua
-- Craft 5 of a recipe
local recipeID = 12345
C_TradeSkillUI.CraftRecipe(recipeID, 5)
```

---

## Key Events

| Event | Payload | Description |
|-------|---------|-------------|
| `TRADE_SKILL_SHOW` | — | Tradeskill UI opened |
| `TRADE_SKILL_CLOSE` | — | Tradeskill UI closed |
| `TRADE_SKILL_UPDATE` | — | Tradeskill data updated |
| `TRADE_SKILL_LIST_UPDATE` | — | Recipe list changed |
| `TRADE_SKILL_DATA_SOURCE_CHANGED` | — | Data source changed |
| `TRADE_SKILL_DATA_SOURCE_CHANGING` | — | Data source changing |
| `TRADE_SKILL_CRAFT_BEGIN` | — | Started crafting |
| `UPDATE_TRADESKILL_CAST_COMPLETE` | — | Craft cast completed |
| `UPDATE_TRADESKILL_CAST_STOPPED` | — | Craft cast stopped |
| `TRADE_SKILL_ITEM_CRAFTED_RESULT` | resultData | Crafted item result |
| `CRAFTINGORDERS_ORDER_PLACEMENT_RESPONSE` | result | Order placement result |
| `CRAFTINGORDERS_CLAIMED_ORDER_ADDED` | — | Order claimed |
| `CRAFTINGORDERS_CLAIMED_ORDER_REMOVED` | — | Order released |
| `CRAFTINGORDERS_CLAIMED_ORDER_UPDATED` | — | Claimed order updated |
| `CRAFTINGORDERS_FULFILL_ORDER_RESPONSE` | result, orderID | Order fulfilled result |
| `CRAFTINGORDERS_REJECT_ORDER_RESPONSE` | result, orderID | Order rejected result |
| `CRAFTINGORDERS_ORDER_CANCEL_RESPONSE` | result, orderID | Order cancelled result |
| `CRAFTINGORDERS_CUSTOMER_OPTIONS_PARSED` | — | Customer options loaded |
| `CRAFTINGORDERS_CRAFTER_ORDER_LIST_UPDATED` | — | Crafter order list refreshed |
| `CRAFTINGORDERS_CAN_REQUEST` | — | Can request crafter orders |
| `SKILL_LINES_CHANGED` | — | Skill lines changed |
| `LEARNED_SPELL_IN_SKILL_LINE` | spellID, skillLineID, isTrackedAsTradeskill | New recipe learned |

---

## Gotchas & Restrictions

1. **Tradeskill must be open** — Most `C_TradeSkillUI` functions only work when the tradeskill window is open.
2. **CraftRecipe requires hardware event** — Crafting requires a user-initiated action (click/key).
3. **Recipe schematic vs recipe info** — `GetRecipeSchematic()` provides reagent slots and quality data; `GetRecipeInfo()` provides name/icon/difficulty.
4. **Crafting orders are async** — `GetCrafterOrders()` is async. Wait for `CRAFTINGORDERS_CRAFTER_ORDER_LIST_UPDATED`.
5. **Quality tiers** — Dragonflight+ recipes have quality tiers (1-5). Use `GetRecipeQualityItemIDs()` to get items per tier.
6. **Recraft** — Recrafting uses `RecraftRecipe()` with the item's GUID, not `CraftRecipe()`.
7. **Profession specs use C_Traits** — Under the hood, profession specializations use the same `C_Traits` system as class talents with a different config type.
8. **GetProfessions returns indices** — Pass the index to `GetProfessionInfo()`, not a profession ID.
