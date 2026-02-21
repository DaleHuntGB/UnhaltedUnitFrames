---
name: wow-api-housing
description: "Complete reference for WoW Retail Player Housing APIs (new in Patch 12.0.0). Covers HousingUI (core housing system), C_HouseEditorUI (placement/editing modes), C_HousingCatalog (decoration catalog), HousingBasicModeUI, HousingCleanupModeUI, HousingCustomizeModeUI, HousingDecorUI, HousingExpertModeUI, C_HouseExteriorUI (exterior customization), HousingLayoutUI, C_HousingNeighborhood (neighborhoods/visiting), C_NeighborhoodInitiative (community goals), and CatalogShop. Use when working with player housing placement, decoration, editing modes, neighborhoods, housing catalogs, exterior customization, or neighborhood initiatives."
---

# Housing API (Retail — Patch 12.0.0)

Comprehensive reference for the player housing system, brand new in Patch 12.0.0.

> **Source:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API
> **Current as of:** Patch 12.0.0 (Build 65655) — January 28, 2026
> **Scope:** Retail only. This entire system is new in 12.0.0.

---

## Scope

- **HousingUI** — Core housing system frame and state
- **C_HouseEditorUI** — Placement and editing (position, rotate, scale)
- **C_HousingCatalog** — Decoration catalog browsing
- **HousingBasicModeUI** — Simplified placement mode
- **HousingCleanupModeUI** — Bulk cleanup/removal mode
- **HousingCustomizeModeUI** — Customization mode
- **HousingDecorUI** — Decoration management
- **HousingExpertModeUI** — Advanced/expert placement
- **C_HouseExteriorUI** — Exterior appearance customization
- **HousingLayoutUI** — Layout save/load
- **C_HousingNeighborhood** — Neighborhoods and visiting
- **C_NeighborhoodInitiative** — Community initiative goals
- **CatalogShop** — Housing shop/catalog purchase system

---

## HousingUI — Core Housing System

| Function | Returns | Description |
|----------|---------|-------------|
| `HousingUI.IsHousingModeActive()` | `isActive` | Is housing editing active? |
| `HousingUI.EnterHousingMode()` | — | Enter housing edit mode |
| `HousingUI.ExitHousingMode()` | — | Exit housing edit mode |
| `HousingUI.GetCurrentHouseInfo()` | `houseInfo` | Current house data |
| `HousingUI.GetHouseOwner()` | `ownerInfo` | House owner info |
| `HousingUI.IsPlayerInOwnHouse()` | `isOwn` | In own house? |
| `HousingUI.IsPlayerInHouse()` | `inHouse` | In any house? |
| `HousingUI.GetHousingPlotInfo()` | `plotInfo` | Plot/lot info |

---

## C_HouseEditorUI — Placement & Editing

The editor is the core system for placing, moving, rotating, and scaling decorations.

### Object Selection & Manipulation

| Function | Returns | Description |
|----------|---------|-------------|
| `C_HouseEditorUI.SelectObject(objectID)` | — | Select decoration |
| `C_HouseEditorUI.DeselectObject()` | — | Deselect current |
| `C_HouseEditorUI.GetSelectedObject()` | `objectInfo` | Current selection |
| `C_HouseEditorUI.DeleteSelectedObject()` | — | Delete selection |
| `C_HouseEditorUI.MoveObject(objectID, x, y, z)` | — | Move decoration |
| `C_HouseEditorUI.RotateObject(objectID, yaw, pitch, roll)` | — | Rotate decoration |
| `C_HouseEditorUI.ScaleObject(objectID, scale)` | — | Scale decoration |
| `C_HouseEditorUI.GetObjectPosition(objectID)` | `x, y, z` | Object position |
| `C_HouseEditorUI.GetObjectRotation(objectID)` | `yaw, pitch, roll` | Object rotation |
| `C_HouseEditorUI.GetObjectScale(objectID)` | `scale` | Object scale |

### Placement

| Function | Returns | Description |
|----------|---------|-------------|
| `C_HouseEditorUI.PlaceObject(catalogItemID)` | — | Start placing item |
| `C_HouseEditorUI.ConfirmPlacement()` | — | Confirm current placement |
| `C_HouseEditorUI.CancelPlacement()` | — | Cancel placement |
| `C_HouseEditorUI.IsPlacing()` | `isPlacing` | In placement mode? |
| `C_HouseEditorUI.GetPlacedObjects()` | `objects` | All placed objects |
| `C_HouseEditorUI.GetPlacementLimits()` | `current, max` | Decoration limits |

### Undo/Redo

| Function | Returns | Description |
|----------|---------|-------------|
| `C_HouseEditorUI.Undo()` | — | Undo last action |
| `C_HouseEditorUI.Redo()` | — | Redo last undo |
| `C_HouseEditorUI.CanUndo()` | `canUndo` | Has undo? |
| `C_HouseEditorUI.CanRedo()` | `canRedo` | Has redo? |

---

## C_HousingCatalog — Decoration Catalog

| Function | Returns | Description |
|----------|---------|-------------|
| `C_HousingCatalog.GetCategories()` | `categories` | All categories |
| `C_HousingCatalog.GetCategoryInfo(categoryID)` | `categoryInfo` | Category details |
| `C_HousingCatalog.GetItemsInCategory(categoryID)` | `items` | Items in category |
| `C_HousingCatalog.GetItemInfo(catalogItemID)` | `itemInfo` | Catalog item info |
| `C_HousingCatalog.GetOwnedItems()` | `ownedItems` | Player's owned items |
| `C_HousingCatalog.IsItemOwned(catalogItemID)` | `isOwned` | Player owns item? |
| `C_HousingCatalog.GetItemCount(catalogItemID)` | `count` | How many owned |
| `C_HousingCatalog.SearchCatalog(searchText)` | `results` | Search items |
| `C_HousingCatalog.GetFilteredItems(filters)` | `items` | Filter items |

---

## HousingBasicModeUI — Simplified Mode

| Function | Returns | Description |
|----------|---------|-------------|
| `HousingBasicModeUI.EnterBasicMode()` | — | Enter basic edit mode |
| `HousingBasicModeUI.ExitBasicMode()` | — | Exit basic mode |
| `HousingBasicModeUI.IsInBasicMode()` | `isBasic` | In basic mode? |

---

## HousingCleanupModeUI — Cleanup Mode

| Function | Returns | Description |
|----------|---------|-------------|
| `HousingCleanupModeUI.EnterCleanupMode()` | — | Enter cleanup mode |
| `HousingCleanupModeUI.ExitCleanupMode()` | — | Exit cleanup mode |
| `HousingCleanupModeUI.SelectForCleanup(objectID)` | — | Tag for cleanup |
| `HousingCleanupModeUI.ConfirmCleanup()` | — | Execute cleanup |
| `HousingCleanupModeUI.GetCleanupCount()` | `count` | Items tagged |

---

## HousingCustomizeModeUI — Customization

| Function | Returns | Description |
|----------|---------|-------------|
| `HousingCustomizeModeUI.EnterCustomizeMode()` | — | Enter customize mode |
| `HousingCustomizeModeUI.ExitCustomizeMode()` | — | Exit customize mode |
| `HousingCustomizeModeUI.GetCustomizationOptions(objectID)` | `options` | Object options |
| `HousingCustomizeModeUI.ApplyCustomization(objectID, optionID)` | — | Apply option |

---

## HousingDecorUI — Decoration Management

| Function | Returns | Description |
|----------|---------|-------------|
| `HousingDecorUI.GetDecorInventory()` | `inventory` | Stored decorations |
| `HousingDecorUI.GetDecorInfo(decorID)` | `decorInfo` | Decoration details |
| `HousingDecorUI.StoreDecoration(objectID)` | — | Store placed item |
| `HousingDecorUI.GetDecorCategories()` | `categories` | Inventory categories |

---

## HousingExpertModeUI — Expert Placement

| Function | Returns | Description |
|----------|---------|-------------|
| `HousingExpertModeUI.EnterExpertMode()` | — | Enter expert mode |
| `HousingExpertModeUI.ExitExpertMode()` | — | Exit expert mode |
| `HousingExpertModeUI.IsInExpertMode()` | `isExpert` | In expert mode? |
| `HousingExpertModeUI.SetSnapping(enabled)` | — | Toggle grid snap |
| `HousingExpertModeUI.GetSnapping()` | `enabled` | Snap enabled? |
| `HousingExpertModeUI.SetPrecisionMode(enabled)` | — | Toggle precision |
| `HousingExpertModeUI.GetPrecisionMode()` | `enabled` | Precision on? |

---

## C_HouseExteriorUI — Exterior Customization

| Function | Returns | Description |
|----------|---------|-------------|
| `C_HouseExteriorUI.GetExteriorOptions()` | `options` | Available exteriors |
| `C_HouseExteriorUI.GetCurrentExterior()` | `exteriorInfo` | Current exterior |
| `C_HouseExteriorUI.SetExterior(exteriorID)` | — | Change exterior |
| `C_HouseExteriorUI.PreviewExterior(exteriorID)` | — | Preview exterior |
| `C_HouseExteriorUI.GetExteriorCategories()` | `categories` | Exterior categories |

---

## HousingLayoutUI — Layout Save/Load

| Function | Returns | Description |
|----------|---------|-------------|
| `HousingLayoutUI.GetSavedLayouts()` | `layouts` | Saved layouts |
| `HousingLayoutUI.SaveLayout(name)` | — | Save current layout |
| `HousingLayoutUI.LoadLayout(layoutID)` | — | Load layout |
| `HousingLayoutUI.DeleteLayout(layoutID)` | — | Delete layout |
| `HousingLayoutUI.RenameLayout(layoutID, name)` | — | Rename layout |
| `HousingLayoutUI.GetLayoutInfo(layoutID)` | `layoutInfo` | Layout details |

---

## C_HousingNeighborhood — Neighborhoods

| Function | Returns | Description |
|----------|---------|-------------|
| `C_HousingNeighborhood.GetNeighborhoodInfo()` | `neighborhoodInfo` | Current neighborhood |
| `C_HousingNeighborhood.GetNeighbors()` | `neighbors` | Neighbor list |
| `C_HousingNeighborhood.GetNeighborInfo(neighborID)` | `neighborInfo` | Neighbor details |
| `C_HousingNeighborhood.VisitNeighbor(neighborID)` | — | Visit a neighbor |
| `C_HousingNeighborhood.GetVisitableHouses()` | `houses` | Visitable houses |
| `C_HousingNeighborhood.InviteToNeighborhood(playerName)` | — | Invite player |
| `C_HousingNeighborhood.LeaveNeighborhood()` | — | Leave neighborhood |
| `C_HousingNeighborhood.GetNeighborhoodMembers()` | `members` | All members |

---

## C_NeighborhoodInitiative — Community Goals

| Function | Returns | Description |
|----------|---------|-------------|
| `C_NeighborhoodInitiative.GetCurrentInitiative()` | `initiativeInfo` | Active initiative |
| `C_NeighborhoodInitiative.GetInitiativeProgress()` | `progress` | Current progress |
| `C_NeighborhoodInitiative.GetInitiativeRewards()` | `rewards` | Initiative rewards |
| `C_NeighborhoodInitiative.GetPlayerContribution()` | `contribution` | Player's contribution |
| `C_NeighborhoodInitiative.GetInitiativeHistory()` | `history` | Past initiatives |

---

## CatalogShop — Housing Store

| Function | Returns | Description |
|----------|---------|-------------|
| `CatalogShop.GetShopCategories()` | `categories` | Shop categories |
| `CatalogShop.GetShopItems(categoryID)` | `items` | Items for sale |
| `CatalogShop.GetShopItemInfo(shopItemID)` | `itemInfo` | Item details |
| `CatalogShop.PurchaseItem(shopItemID)` | — | Purchase item |
| `CatalogShop.CanPurchase(shopItemID)` | `canBuy, reason` | Can purchase? |
| `CatalogShop.GetBundleInfo(bundleID)` | `bundleInfo` | Bundle details |

---

## Common Patterns

### Check If Player Is Home

```lua
local function CheckHousingState()
    if HousingUI.IsPlayerInOwnHouse() then
        print("Welcome home!")
        local houseInfo = HousingUI.GetCurrentHouseInfo()
        if houseInfo then
            print("House:", houseInfo.name)
        end
    elseif HousingUI.IsPlayerInHouse() then
        local owner = HousingUI.GetHouseOwner()
        if owner then
            print("Visiting", owner.name, "'s house")
        end
    end
end
```

### Place a Decoration

```lua
-- Enter housing edit mode and place an item
local function PlaceDecoration(catalogItemID)
    if not HousingUI.IsHousingModeActive() then
        HousingUI.EnterHousingMode()
    end
    
    local current, max = C_HouseEditorUI.GetPlacementLimits()
    if current >= max then
        print("Decoration limit reached:", current, "/", max)
        return
    end
    
    C_HouseEditorUI.PlaceObject(catalogItemID)
end
```

### Browse Catalog

```lua
local function BrowseCatalog()
    local categories = C_HousingCatalog.GetCategories()
    for _, cat in ipairs(categories) do
        local catInfo = C_HousingCatalog.GetCategoryInfo(cat)
        if catInfo then
            print("Category:", catInfo.name)
            local items = C_HousingCatalog.GetItemsInCategory(cat)
            for _, item in ipairs(items) do
                local info = C_HousingCatalog.GetItemInfo(item)
                if info then
                    local owned = C_HousingCatalog.IsItemOwned(item)
                    print("  -", info.name, owned and "(Owned)" or "")
                end
            end
        end
    end
end
```

### Save and Load Layouts

```lua
-- Save current decoration layout
HousingLayoutUI.SaveLayout("My Living Room v2")

-- List saved layouts
local layouts = HousingLayoutUI.GetSavedLayouts()
for _, layout in ipairs(layouts) do
    local info = HousingLayoutUI.GetLayoutInfo(layout)
    if info then
        print(info.name, "-", info.objectCount, "objects")
    end
end
```

---

## Key Events

| Event | Payload | Description |
|-------|---------|-------------|
| `HOUSING_MODE_ENTERED` | — | Entered housing edit mode |
| `HOUSING_MODE_EXITED` | — | Exited housing edit mode |
| `HOUSING_OBJECT_PLACED` | objectID | Decoration placed |
| `HOUSING_OBJECT_REMOVED` | objectID | Decoration removed |
| `HOUSING_OBJECT_MOVED` | objectID | Decoration moved |
| `HOUSING_OBJECT_SELECTED` | objectID | Object selected |
| `HOUSING_OBJECT_DESELECTED` | — | Object deselected |
| `HOUSING_PLACEMENT_STARTED` | catalogItemID | Placement mode started |
| `HOUSING_PLACEMENT_CONFIRMED` | objectID | Placement confirmed |
| `HOUSING_PLACEMENT_CANCELED` | — | Placement canceled |
| `HOUSING_CATALOG_UPDATED` | — | Catalog data changed |
| `HOUSING_LAYOUT_SAVED` | layoutID | Layout saved |
| `HOUSING_LAYOUT_LOADED` | layoutID | Layout loaded |
| `HOUSING_EXTERIOR_CHANGED` | exteriorID | Exterior changed |
| `HOUSING_LIMIT_UPDATED` | current, max | Limit changed |
| `HOUSING_ENTERED_HOUSE` | houseInfo | Entered a house |
| `HOUSING_LEFT_HOUSE` | — | Left a house |
| `NEIGHBORHOOD_INITIATIVE_UPDATE` | — | Initiative progress changed |
| `NEIGHBORHOOD_MEMBER_JOINED` | memberInfo | New neighbor |

---

## Gotchas & Restrictions

1. **12.0.0 only** — The entire housing system is new in Patch 12.0.0. APIs may evolve in subsequent patches.
2. **Mode requirements** — Must call `HousingUI.EnterHousingMode()` before using editor functions.
3. **Placement limits** — Each house has a decoration cap. Check with `GetPlacementLimits()`.
4. **Expert vs Basic mode** — Expert mode allows full 3D positioning; basic mode uses simplified snapping.
5. **Own house only for editing** — Cannot edit decorations in someone else's house.
6. **Layout compatibility** — Layouts may not load correctly if decorations have been removed from the game.
7. **Neighborhood initiatives** — Shared community goals; progress is collective, not individual.
8. **Hardware events** — Purchasing catalog items requires user interaction (hardware clicks).
