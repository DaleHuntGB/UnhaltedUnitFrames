---
name: wow-api-collections
description: "Complete reference for WoW Retail Mount, Pet, Pet Battle, Toy, Stable, and Heirloom Collection APIs. Covers C_MountJournal (mount list, filtering, favorites, summoning, display info), C_PetJournal (pet collection, favorites, summoning, caging, abilities), C_PetBattles (pet battle system, turns, actions, pets, abilities, traps), C_PetInfo, C_ToyBox/C_ToyBoxInfo (toy collection, use, favorites), C_StableInfo (hunter pet stables), C_Heirloom/C_HeirloomInfo (heirloom collection, upgrades). Use when working with mount journal, pet journal, pet battles, toy box, heirloom collection, or hunter stables."
---

# Collections API (Retail — Patch 12.0.0)

Comprehensive reference for mounts, pets, pet battles, toys, stables, and heirlooms.

> **Source:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API
> **Current as of:** Patch 12.0.0 (Build 65655) — January 28, 2026
> **Scope:** Retail only.

---

## Scope

- **C_MountJournal** — Mounts collection and summoning
- **C_PetJournal** — Pet collection management
- **C_PetBattles** — Pet battle system
- **C_PetInfo** — Pet info utilities
- **C_ToyBox / C_ToyBoxInfo** — Toy collection
- **C_StableInfo** — Hunter pet stables
- **C_Heirloom / C_HeirloomInfo** — Heirloom collection

---

## C_MountJournal — Mounts

### Mount List & Info

| Function | Returns | Description |
|----------|---------|-------------|
| `C_MountJournal.GetNumMounts()` | `numMounts` | Total mounts in journal |
| `C_MountJournal.GetNumDisplayedMounts()` | `numDisplayed` | Filtered mount count |
| `C_MountJournal.GetDisplayedMountInfo(displayIndex)` | `name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected, mountID, ...` | Mount display info |
| `C_MountJournal.GetDisplayedMountInfoExtra(displayIndex)` | `creatureDisplayInfoID, description, source, isSelfMount, mountTypeID, uiModelSceneID, animID, spellVisualKitID, disablePlayerMountPreview` | Extra mount display info |
| `C_MountJournal.GetMountInfoByID(mountID)` | `name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected, mountID` | Mount info by ID |
| `C_MountJournal.GetMountInfoExtraByID(mountID)` | `creatureDisplayInfoID, description, source, isSelfMount, mountTypeID, ...` | Extra info by ID |
| `C_MountJournal.GetMountFromItem(itemID)` | `mountID` | Mount from item |
| `C_MountJournal.GetMountFromSpell(spellID)` | `mountID` | Mount from spell |
| `C_MountJournal.GetMountIDs()` | `mountIDs` | All mount IDs |
| `C_MountJournal.GetCollectedFilterSetting(filterIndex)` | `isChecked` | Collection filter |
| `C_MountJournal.SetCollectedFilterSetting(filterIndex, isChecked)` | — | Set collection filter |
| `C_MountJournal.GetMountAllCreatureDisplayInfoByID(mountID)` | `displayInfo` | All creature displays |
| `C_MountJournal.GetMountUsabilityByID(mountID, checkIndoors)` | `isUsable, useError` | Check mount usability |

### Mount Actions

| Function | Returns | Description |
|----------|---------|-------------|
| `C_MountJournal.SummonByID(mountID)` | — | Summon mount |
| `C_MountJournal.Dismiss()` | — | Dismiss mount |
| `C_MountJournal.SetIsFavorite(mountIndex, isFavorite)` | — | Toggle favorite |
| `C_MountJournal.GetIsFavorite(mountIndex)` | `isFavorite, canSetFavorite` | Is favorite? |
| `C_MountJournal.Pickup(displayIndex)` | — | Pick up mount to cursor |
| `C_MountJournal.IsItemMountEquipment(itemID)` | `isMountEquipment` | Is mount equipment? |
| `C_MountJournal.GetAppliedMountEquipmentID()` | `itemID` | Applied mount equipment |
| `C_MountJournal.ApplyMountEquipment(itemID)` | — | Apply mount equipment |
| `C_MountJournal.IsSourceChecked(filterIndex)` | `isChecked` | Source filter checked? |
| `C_MountJournal.SetSourceFilter(filterIndex, isChecked)` | — | Set source filter |
| `C_MountJournal.IsValidSourceFilter(filterIndex)` | `isValid` | Valid source filter? |
| `C_MountJournal.GetNumMountsNeedingFanfare()` | `numMounts` | Mounts needing fanfare |

### Global Mount Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `IsMounted()` | `isMounted` | Is player mounted? |
| `Dismount()` | — | Dismount |
| `GetMountCreatureDisplayInfoByID(mountID, index)` | `displayID, isVisible` | Display info |

---

## C_PetJournal — Pet Collection

### Pet List & Info

| Function | Returns | Description |
|----------|---------|-------------|
| `C_PetJournal.GetNumPets()` | `numPets, numOwned` | Total / owned pet count |
| `C_PetJournal.GetPetInfoByIndex(index)` | `petID, speciesID, owned, customName, level, favorite, isRevoked, speciesName, icon, petType, companionID, tooltip, description, isWild, canBattle, isTradeable, isUnique, obtainable` | Pet info by index |
| `C_PetJournal.GetPetInfoByPetID(petID)` | `speciesID, customName, level, xp, maxXp, displayID, isFavorite, name, icon, petType, creatureID, sourceText, description, isWild, canBattle, isTradeable, isUnique, obtainable, ...` | Pet info by pet ID |
| `C_PetJournal.GetPetInfoBySpeciesID(speciesID)` | `name, icon, petType, companionID, tooltipSource, tooltipDescription, isWild, canBattle, isTradeable, isUnique, obtainable, creatureDisplayID` | Pet species info |
| `C_PetJournal.GetPetInfoByItemID(itemID)` | `speciesID` | Species from item |
| `C_PetJournal.GetNumPetSources()` | `numSources` | Number of sources |
| `C_PetJournal.GetNumPetTypes()` | `numTypes` | Number of types |
| `C_PetJournal.GetOwnedBattlePetString(speciesID)` | `ownedString` | "X/3 owned" text |
| `C_PetJournal.GetBattlePetBreedName(speciesID)` | `breedName` | Breed name |
| `C_PetJournal.GetPetStats(petID)` | `health, maxHealth, power, speed, rarity` | Battle stats |
| `C_PetJournal.GetPetAbilityInfo(abilityID)` | `name, icon, type` | Ability info |
| `C_PetJournal.GetPetAbilityList(speciesID [, idTable [, levelTable]])` | `abilities, levels` | Species abilities |

### Pet Actions

| Function | Returns | Description |
|----------|---------|-------------|
| `C_PetJournal.SummonPetByGUID(petID)` | — | Summon companion pet |
| `C_PetJournal.DismissSummonedPet()` | — | Dismiss summoned pet |
| `C_PetJournal.GetSummonedPetGUID()` | `petID` | Currently summoned pet |
| `C_PetJournal.SetFavorite(petID, favorite)` | — | Toggle favorite |
| `C_PetJournal.SetCustomName(petID, name)` | — | Rename pet |
| `C_PetJournal.ReleasePetByID(petID)` | — | Release (delete) pet |
| `C_PetJournal.CagePetByID(petID)` | — | Cage pet for trading |
| `C_PetJournal.PetIsSummonable(petID)` | `isSummonable, error` | Can summon? |
| `C_PetJournal.FindPetIDByName(name)` | `petID` | Find pet by name |
| `C_PetJournal.PickupPet(petID)` | — | Pick up to cursor |

### Pet Filters

| Function | Returns | Description |
|----------|---------|-------------|
| `C_PetJournal.SetSearchFilter(text)` | — | Filter by name |
| `C_PetJournal.ClearSearchFilter()` | — | Clear search filter |
| `C_PetJournal.IsFilterChecked(filterIndex)` | `isChecked` | Source filter |
| `C_PetJournal.SetFilterChecked(filterIndex, isChecked)` | — | Set source filter |
| `C_PetJournal.IsPetTypeChecked(petType)` | `isChecked` | Type filter |
| `C_PetJournal.SetPetTypeFilter(petType, isChecked)` | — | Set type filter |
| `C_PetJournal.SetPetSortParameter(sortParam)` | — | Set sort parameter |

---

## C_PetBattles — Pet Battle System

### Battle State

| Function | Returns | Description |
|----------|---------|-------------|
| `C_PetBattles.IsInBattle()` | `inBattle` | In pet battle? |
| `C_PetBattles.IsWildBattle()` | `isWild` | Wild pet battle? |
| `C_PetBattles.IsPVPBattle()` | `isPVP` | PvP pet battle? |
| `C_PetBattles.IsPlayerNPC(owner)` | `isNPC` | Is owner NPC? |
| `C_PetBattles.GetActivePet(owner)` | `petIndex` | Active pet index |
| `C_PetBattles.GetNumPets(owner)` | `numPets` | Owner's pet count |
| `C_PetBattles.IsWaitingOnOpponent()` | `isWaiting` | Waiting for opponent? |
| `C_PetBattles.ShouldShowPetSelect()` | `shouldShow` | Show pet select? |

### Battle Pet Info

| Function | Returns | Description |
|----------|---------|-------------|
| `C_PetBattles.GetName(owner, petIndex)` | `name` | Pet name |
| `C_PetBattles.GetDisplayID(owner, petIndex)` | `displayID` | Display model |
| `C_PetBattles.GetLevel(owner, petIndex)` | `level` | Pet level |
| `C_PetBattles.GetHealth(owner, petIndex)` | `health` | Current health |
| `C_PetBattles.GetMaxHealth(owner, petIndex)` | `maxHealth` | Max health |
| `C_PetBattles.GetPower(owner, petIndex)` | `power` | Power stat |
| `C_PetBattles.GetSpeed(owner, petIndex)` | `speed` | Speed stat |
| `C_PetBattles.GetBreedQuality(owner, petIndex)` | `quality` | Quality (1-4) |
| `C_PetBattles.GetPetType(owner, petIndex)` | `type` | Pet type |
| `C_PetBattles.GetIcon(owner, petIndex)` | `icon` | Pet icon |
| `C_PetBattles.GetSpeciesID(owner, petIndex)` | `speciesID` | Species ID |
| `C_PetBattles.IsAlive(owner, petIndex)` | `isAlive` | Is pet alive? |
| `C_PetBattles.IsCapturable(owner, petIndex)` | `canCapture` | Can this pet be captured? |

### Battle Actions

| Function | Returns | Description |
|----------|---------|-------------|
| `C_PetBattles.UseAbility(abilityIndex)` | — | Use ability |
| `C_PetBattles.ChangePet(petIndex)` | — | Switch pet |
| `C_PetBattles.UseTrap()` | — | Use pet trap |
| `C_PetBattles.SkipTurn()` | — | Skip turn |
| `C_PetBattles.ForfeitGame()` | — | Forfeit battle |
| `C_PetBattles.GetAbilityInfo(owner, petIndex, abilityIndex)` | `name, icon, type` | Ability info |
| `C_PetBattles.GetAbilityState(owner, petIndex, abilityIndex)` | `isUsable, currentCooldown, currentLockdown` | Ability state |
| `C_PetBattles.GetTurnTimeInfo()` | `timeRemaining, totalTime` | Turn timer |

### Battle Owner Constants

| Constant | Value | Description |
|----------|-------|-------------|
| `Enum.BattlePetOwner.Ally` | 1 | Player's side |
| `Enum.BattlePetOwner.Enemy` | 2 | Opponent's side |

---

## C_ToyBox / C_ToyBoxInfo — Toys

| Function | Returns | Description |
|----------|---------|-------------|
| `C_ToyBox.GetNumTotalDisplayedToys()` | `numToys` | Displayed toy count |
| `C_ToyBox.GetNumLearnedDisplayedToys()` | `numLearned` | Learned displayed count |
| `C_ToyBox.GetToyFromIndex(index)` | `itemID` | Toy at display index |
| `C_ToyBox.GetToyInfo(itemID)` | `itemID, toyName, icon, isFavorite, hasFanfare, qualityEnum` | Toy details |
| `C_ToyBox.GetToyLink(itemID)` | `link` | Toy item link |
| `C_ToyBox.IsToyUsable(itemID)` | `isUsable` | Can use toy now? |
| `C_ToyBox.HasFavorites()` | `hasFavorites` | Has favorite toys? |
| `C_ToyBox.SetIsFavorite(itemID, isFavorite)` | — | Toggle favorite |
| `C_ToyBox.GetIsFavorite(itemID)` | `isFavorite` | Is toy favorite? |
| `C_ToyBox.ForceToyRefilter()` | — | Refilter toy list |
| `C_ToyBox.SetFilterString(filter)` | — | Set search filter |
| `C_ToyBox.GetFilterString()` | `filter` | Current filter |
| `C_ToyBox.IsExpansionTypeFilterChecked(expansion)` | `isChecked` | Expansion filter |
| `C_ToyBox.SetExpansionTypeFilter(expansion, isChecked)` | — | Set expansion filter |
| `C_ToyBox.IsSourceTypeFilterChecked(sourceType)` | `isChecked` | Source filter |
| `C_ToyBox.SetSourceTypeFilter(sourceType, isChecked)` | — | Set source filter |
| `C_ToyBox.SetAllSourceTypeFilters(isChecked)` | — | Set all source filters |
| `C_ToyBox.PickupToyBoxItem(itemID)` | — | Pick up toy |
| `C_ToyBoxInfo.ClearFanfare(itemID)` | — | Clear fanfare |
| `C_ToyBoxInfo.NeedsFanfare(itemID)` | `needsFanfare` | Needs fanfare? |
| `PlayerHasToy(itemID)` | `hasToy` | Has toy collected? |
| `UseToy(itemID)` | — | Use a toy |

---

## C_StableInfo — Hunter Pet Stables

| Function | Returns | Description |
|----------|---------|-------------|
| `C_StableInfo.GetStablePetInfo(index)` | `info` | Stable pet info |
| `C_StableInfo.GetNumStablePets()` | `numPets` | Pets in stable |
| `C_StableInfo.GetActivePetList()` | `activeList` | Active pet list |
| `C_StableInfo.GetStabledPetList()` | `stabledList` | Stabled pet list |
| `C_StableInfo.IsStabledPet(index)` | `isStabled` | Is pet stabled? |
| `C_StableInfo.SetPetSlot(localIndex, slot)` | — | Set pet to slot |
| `C_StableInfo.PickupStablePet(index)` | — | Pick up pet |

---

## C_Heirloom / C_HeirloomInfo — Heirlooms

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Heirloom.GetNumHeirlooms()` | `numHeirlooms` | Total heirlooms |
| `C_Heirloom.GetNumKnownHeirlooms()` | `numKnown` | Collected count |
| `C_Heirloom.GetHeirloomInfo(itemID)` | `alreadyHas, canUpgrade, ...` | Heirloom info |
| `C_Heirloom.GetHeirloomMaxUpgradeLevel(itemID)` | `maxLevel` | Max upgrade level |
| `C_Heirloom.GetHeirloomLink(itemID)` | `link` | Heirloom item link |
| `C_Heirloom.PlayerHasHeirloom(itemID)` | `hasHeirloom` | Has heirloom? |
| `C_Heirloom.CanHeirloomUpgradeFromPending(itemID)` | `canUpgrade` | Can upgrade? |
| `C_Heirloom.CreateHeirloom(itemID)` | — | Create heirloom |
| `C_Heirloom.UpgradeHeirloom(itemID)` | — | Upgrade heirloom |
| `C_Heirloom.IsMod23ArmorHeirloom(itemID)` | `isMod23` | Is Mod23 armor? |

---

## Key Events

| Event | Payload | Description |
|-------|---------|-------------|
| `MOUNT_JOURNAL_USABILITY_CHANGED` | — | Mount usability changed |
| `MOUNT_JOURNAL_SEARCH_UPDATED` | — | Mount search updated |
| `NEW_MOUNT_ADDED` | mountID | New mount collected |
| `COMPANION_UPDATE` | companionType | Companion updated |
| `NEW_PET_ADDED` | petID | New pet collected |
| `PET_JOURNAL_LIST_UPDATE` | — | Pet list updated |
| `PET_JOURNAL_PET_DELETED` | petID | Pet deleted |
| `PET_BATTLE_OPENING_START` | — | Pet battle starting |
| `PET_BATTLE_OPENING_DONE` | — | Pet battle started |
| `PET_BATTLE_CLOSE` | — | Pet battle ended |
| `PET_BATTLE_TURN_STARTED` | — | Turn started |
| `PET_BATTLE_PET_ROUND_RESULTS` | — | Round results |
| `PET_BATTLE_OVER` | — | Battle over |
| `PET_BATTLE_FINAL_ROUND` | — | Final round |
| `TOYS_UPDATED` | itemID, isNew, hasFanfare | Toy collection updated |
| `NEW_TOY_ADDED` | itemID | New toy collected |
| `HEIRLOOMS_UPDATED` | itemID, updateReason | Heirloom updated |
| `HEIRLOOM_UPGRADE_TARGETING_CHANGED` | pendingHeirloomUpgrade | Upgrade targeting |

---

## Gotchas & Restrictions

1. **Mount IDs vs spell IDs** — Mounts have both a mountID and a spellID. `SummonByID()` takes mountID.
2. **Pet GUIDs are session-specific** — Pet GUIDs (petID returned by journal functions) persist across sessions, but BattlePet GUIDs in combat are different.
3. **Pet battle restrictions** — Pet battle functions only work during active pet battles. Check `C_PetBattles.IsInBattle()` first.
4. **Toy cooldowns** — `UseToy()` respects cooldowns. Check `C_ToyBox.IsToyUsable()` before use.
5. **Display index vs ID** — `GetDisplayedMountInfo()` takes a filtered list index, not a mountID. Index changes with filters.
6. **Summon requires hardware event** — `SummonByID()` and `SummonPetByGUID()` require a hardware event.
7. **Pet battle ownership** — Use `Enum.BattlePetOwner.Ally` (1) and `Enum.BattlePetOwner.Enemy` (2) for owner parameters.
8. **Heirloom creation** — `CreateHeirloom()` requires the appropriate currency/cost. Check `CanHeirloomUpgradeFromPending()`.
