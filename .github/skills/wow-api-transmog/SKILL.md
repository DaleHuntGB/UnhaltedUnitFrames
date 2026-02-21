---
name: wow-api-transmog
description: "Complete reference for WoW Retail Transmogrification, Appearance Collection, Transmog Sets, Transmog Outfits, Dye Colors, and Barber Shop APIs. Covers C_Transmogrify (applying transmog at NPC), C_TransmogCollection (appearance source info, categories, search, collected status), C_TransmogSets (set collection, set info, base sets, variants), C_TransmogOutfits (outfit management, save/load), C_DyeColor/C_DyeColorInfo (armor dye system new in 12.0.0), and C_BarberShop (customization). Use when working with transmog, appearance collections, wardrobe, transmog sets, outfit management, armor dyes, or character customization."
---

# Transmog API (Retail — Patch 12.0.0)

Comprehensive reference for transmogrification, appearances, sets, outfits, dyes, and barber shop APIs.

> **Source:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API
> **Current as of:** Patch 12.0.0 (Build 65655) — January 28, 2026
> **Scope:** Retail only.

---

## Scope

- **C_Transmogrify** — Applying transmog at NPC
- **C_TransmogCollection** — Appearance sources, categories, collection status
- **C_TransmogSets** — Transmog set management
- **C_TransmogOutfits** — Outfit save/load
- **C_DyeColor / C_DyeColorInfo** — Armor dye system (new in 12.0.0)
- **C_BarberShop** — Character customization

---

## C_Transmogrify — Applying Transmog

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Transmogrify.ApplyAllPending()` | — | Apply all pending transmogs |
| `C_Transmogrify.CanHaveSecondaryAppearanceForSlotID(slotID)` | `canHave` | Has secondary slot? |
| `C_Transmogrify.CanTransmogItem(itemInfo)` | `canTransmog, selfFailure, canTransmogKnownAppearance, canTransmogUncollected` | Can transmog? |
| `C_Transmogrify.CanTransmogItemWithItem(targetItemInfo, sourceItemInfo)` | `canTransmog` | Can transmog source to target? |
| `C_Transmogrify.ClearAllPending()` | — | Clear all pending transmogs |
| `C_Transmogrify.ClearPending(slotID)` | — | Clear pending for slot |
| `C_Transmogrify.Close()` | — | Close transmog window |
| `C_Transmogrify.GetBaseCategory(slotID)` | `category` | Base category for slot |
| `C_Transmogrify.GetCost()` | `cost` | Current transmog cost |
| `C_Transmogrify.GetCreatureDisplayIDForSource(sourceID)` | `displayID` | Creature display for source |
| `C_Transmogrify.GetItemIDForSource(sourceID)` | `itemID` | Item ID for source |
| `C_Transmogrify.GetPending(slotID)` | `pendingInfo` | Pending transmog for slot |
| `C_Transmogrify.GetSlotEffectiveCategory(slotID)` | `category` | Effective category for slot |
| `C_Transmogrify.GetSlotInfo(slotID)` | `isTransmogrified, hasPending, isPendingCollected, canTransmogrify, cannotTransmogrifyReason, hasUndo, isHideVisual, texture` | Slot transmog info |
| `C_Transmogrify.GetSlotUseError(slotID)` | `errorCode, errorString` | Slot error |
| `C_Transmogrify.GetSlotVisualInfo(slotID)` | `baseSourceID, baseVisualID, appliedSourceID, appliedVisualID, pendingSourceID, pendingVisualID, hasPendingUndo, hideVisual, hasActiveSecondaryAppearance` | Slot visual details |
| `C_Transmogrify.SetPending(slotID, transmogType, modification, sourceID)` | — | Set pending transmog |

---

## C_TransmogCollection — Appearance Sources

### Source & Appearance Info

| Function | Returns | Description |
|----------|---------|-------------|
| `C_TransmogCollection.GetSourceInfo(sourceID)` | `sourceInfo` | Source details |
| `C_TransmogCollection.GetAppearanceSourceInfo(sourceID)` | `category, appearanceID, canHaveIllusion, icon, isCollected, itemLink, transmogLink, sourceType, ...` | Appearance source info |
| `C_TransmogCollection.GetSourceItemID(sourceID)` | `itemID` | Item for source |
| `C_TransmogCollection.PlayerHasTransmog(itemID [, itemAppearanceModID])` | `hasTransmog` | Has transmog collected? |
| `C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(itemModifiedAppearanceID)` | `hasAppearance` | Has modified appearance? |
| `C_TransmogCollection.PlayerHasTransmogByItemInfo(itemInfo)` | `hasTransmog` | Has transmog by item info? |
| `C_TransmogCollection.GetItemInfo(itemInfo)` | `appearanceID, sourceID` | Source for item |
| `C_TransmogCollection.GetAllAppearanceSources(appearanceID)` | `sourceIDs` | All sources for appearance |
| `C_TransmogCollection.GetAppearanceSources(appearanceID [, categoryID [, transmogType]])` | `sources` | Sources with info |

### Categories

| Function | Returns | Description |
|----------|---------|-------------|
| `C_TransmogCollection.GetCategoryAppearances(categoryID)` | `appearances` | All appearances in category |
| `C_TransmogCollection.GetCategoryCollectedCount(categoryID)` | `collected` | Collected count |
| `C_TransmogCollection.GetCategoryTotal(categoryID)` | `total` | Total in category |
| `C_TransmogCollection.GetNumTransmogSources()` | `numSources` | Total sources |
| `C_TransmogCollection.IsAppearanceCollected(appearanceID)` | `isCollected` | Is appearance collected? |

### Illusions

| Function | Returns | Description |
|----------|---------|-------------|
| `C_TransmogCollection.GetIllusions()` | `illusions` | All weapon illusions |
| `C_TransmogCollection.GetIllusionSourceInfo(sourceID)` | `name, hyperlink, sourceText` | Illusion source info |
| `C_TransmogCollection.PlayerKnowsSource(sourceID)` | `isKnown` | Knows source? |

### Search & Filtering

| Function | Returns | Description |
|----------|---------|-------------|
| `C_TransmogCollection.SetSearch(searchType, searchText)` | — | Set search filter |
| `C_TransmogCollection.GetSearchResults(searchType)` | `results` | Get search results |
| `C_TransmogCollection.ClearSearch(searchType)` | — | Clear search |
| `C_TransmogCollection.IsSearchInProgress(searchType)` | `inProgress` | Is search running? |
| `C_TransmogCollection.EndSearch()` | — | End search |
| `C_TransmogCollection.GetIsAppearanceFavorite(appearanceID)` | `isFavorite` | Is favorite? |
| `C_TransmogCollection.SetIsAppearanceFavorite(appearanceID, isFavorite)` | — | Set favorite |

---

## C_TransmogSets — Transmog Sets

| Function | Returns | Description |
|----------|---------|-------------|
| `C_TransmogSets.GetAllSets()` | `sets` | All transmog sets |
| `C_TransmogSets.GetBaseSetsCounts()` | `numCollected, numTotal` | base sets progress |
| `C_TransmogSets.GetSetInfo(setID)` | `setInfo` | Set details |
| `C_TransmogSets.GetSetSources(setID)` | `sources` | Sources in set |
| `C_TransmogSets.GetSetPrimaryAppearances(setID)` | `appearances` | Primary appearances |
| `C_TransmogSets.GetBaseSets()` | `baseSets` | All base sets |
| `C_TransmogSets.GetBaseSetID(setID)` | `baseSetID` | Base set for variant |
| `C_TransmogSets.GetVariantSets(baseSetID)` | `variantSets` | Variants of base set |
| `C_TransmogSets.GetUsableSets()` | `usableSets` | Sets usable by class |
| `C_TransmogSets.HasUsableSets()` | `hasUsable` | Has usable sets? |
| `C_TransmogSets.IsSetCollected(setID)` | `isCollected` | Set fully collected? |
| `C_TransmogSets.IsSetUsable(setID)` | `isUsable` | Set usable by player? |
| `C_TransmogSets.IsNewAppearance(appearanceID)` | `isNew` | New since last viewed? |
| `C_TransmogSets.ClearNewAppearance(appearanceID)` | — | Mark as seen |
| `C_TransmogSets.GetNumSetsCollected()` | `numCollected` | Sets collected count |
| `C_TransmogSets.GetNumSetsTotal()` | `numTotal` | Total number of sets |
| `C_TransmogSets.GetSetSourceCounts(setID)` | `numCollected, numTotal` | Sources in set progress |
| `C_TransmogSets.SetHasNewSources(setID)` | `hasNewSources` | New sources in set? |
| `C_TransmogSets.SetIsFavorite(setID, isFavorite)` | — | Toggle favorite |
| `C_TransmogSets.GetIsFavorite(setID)` | `isFavorite` | Is favorite set? |

---

## C_TransmogOutfits — Outfits

| Function | Returns | Description |
|----------|---------|-------------|
| `C_TransmogOutfits.GetOutfits()` | `outfits` | All saved outfits |
| `C_TransmogOutfits.GetOutfitInfo(outfitID)` | `name, icon` | Outfit info |
| `C_TransmogOutfits.NewOutfit(name, icon, sources)` | `outfitID` | Create new outfit |
| `C_TransmogOutfits.DeleteOutfit(outfitID)` | — | Delete outfit |
| `C_TransmogOutfits.RenameOutfit(outfitID, name)` | — | Rename outfit |
| `C_TransmogOutfits.SetOutfitIcon(outfitID, icon)` | — | Set outfit icon |
| `C_TransmogOutfits.SaveOutfit(outfitID, sources)` | — | Update outfit |
| `C_TransmogOutfits.GetOutfitSources(outfitID)` | `sources` | Get all sources in outfit |
| `C_TransmogOutfits.GetSlotSourceID(outfitID, slotID)` | `sourceID` | Source for slot |

---

## C_DyeColor / C_DyeColorInfo — Armor Dyes (12.0.0)

New system for applying dye colors to armor appearances.

| Function | Returns | Description |
|----------|---------|-------------|
| `C_DyeColorInfo.GetDyeColorInfo(dyeColorID)` | `info` | Dye color details |
| `C_DyeColorInfo.GetAvailableDyeColors()` | `dyeColors` | Available dye colors |
| `C_DyeColorInfo.GetDyeColorCategories()` | `categories` | Dye color categories |
| `C_DyeColorInfo.IsDyeColorUnlocked(dyeColorID)` | `isUnlocked` | Is color unlocked? |
| `C_DyeColorInfo.GetNumUnlockedDyeColors()` | `numUnlocked` | Unlocked dye count |

---

## C_BarberShop — Character Customization

| Function | Returns | Description |
|----------|---------|-------------|
| `C_BarberShop.IsViewingAlteredForm()` | `isViewing` | Viewing alt form? |
| `C_BarberShop.SetViewingAlteredForm(isViewing)` | — | Toggle alt form view |
| `C_BarberShop.GetAvailableCustomizations()` | `customizations` | Available customizations |
| `C_BarberShop.GetCurrentCustomizations()` | `customizations` | Current selections |
| `C_BarberShop.SetCustomizationChoice(customizationCategoryID, choiceIndex)` | — | Set a choice |
| `C_BarberShop.PreviewCustomizationChoice(customizationCategoryID, choiceIndex)` | — | Preview a choice |
| `C_BarberShop.GetCustomizationScope()` | `scope` | Customization scope |
| `C_BarberShop.HasAnyChanges()` | `hasChanges` | Has unsaved changes? |
| `C_BarberShop.ApplyCustomizationChoices()` | — | Apply changes |
| `C_BarberShop.Cancel()` | — | Cancel and close |
| `C_BarberShop.ResetCustomizationChoices()` | — | Reset to current |
| `C_BarberShop.GetCurrentCost()` | `cost` | Cost for changes |
| `C_BarberShop.MarkCustomizationChoiceAsSeen(choiceID)` | — | Mark choice seen |
| `C_BarberShop.MarkCustomizationOptionAsSeen(optionID)` | — | Mark option seen |
| `C_BarberShop.SetSelectedSex(sex)` | — | Set selected sex |

---

## Key Events

| Event | Payload | Description |
|-------|---------|-------------|
| `TRANSMOGRIFY_OPEN` | — | Transmog NPC opened |
| `TRANSMOGRIFY_CLOSE` | — | Transmog NPC closed |
| `TRANSMOGRIFY_UPDATE` | slotID | Transmog slot updated |
| `TRANSMOGRIFY_SUCCESS` | slotID | Transmog applied |
| `TRANSMOG_COLLECTION_SOURCE_ADDED` | sourceID | New source collected |
| `TRANSMOG_COLLECTION_SOURCE_REMOVED` | sourceID | Source removed |
| `TRANSMOG_COLLECTION_UPDATED` | — | Collection changed |
| `TRANSMOG_COLLECTION_CAMERA_UPDATE` | — | Camera update |
| `TRANSMOG_SETS_UPDATE_FAVORITE` | — | Set favorite changed |
| `TRANSMOG_SEARCH_UPDATED` | searchType | Search results updated |
| `TRANSMOG_OUTFITS_CHANGED` | — | Outfits changed |
| `BARBER_SHOP_OPEN` | — | Barber shop opened |
| `BARBER_SHOP_CLOSE` | — | Barber shop closed |
| `BARBER_SHOP_COST_UPDATE` | — | Cost updated |
| `BARBER_SHOP_APPEARANCE_APPLIED` | — | Appearance applied |
| `BARBER_SHOP_RESULT` | success | Barber shop result |

---

## Gotchas & Restrictions

1. **Transmog NPC required** — `C_Transmogrify.ApplyAllPending()` and related functions only work at a transmog NPC.
2. **sourceID vs appearanceID** — A sourceID is a specific item drop source. An appearanceID is the visual look (multiple sources can share one appearance).
3. **Category by armor type** — Transmog categories are divided by armor slot and armor type (cloth, leather, mail, plate).
4. **Dye system is new** — The dye color system is new in 12.0.0 and APIs may evolve.
5. **Barber shop requires presence** — `C_BarberShop` functions only work while at the barber shop NPC.
6. **Outfit limit** — There's a maximum number of saved outfits per character.
7. **Set variants** — A base set can have multiple variants (different difficulties, etc.). Use `GetVariantSets()`.
8. **illusion = weapon enchant visual** — Illusions are the weapon glow effects. Separate from armor transmog.
