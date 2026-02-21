---
name: wow-api-talents
description: "Complete reference for WoW Retail Class Talents, Hero Talents, Traits system, Specialization, and Profession Specialization APIs. Covers C_ClassTalents (loadouts, config management, talent tree interactions), C_Traits (the underlying trait system — nodes, entries, configs, currencies, conditions), C_SpecializationInfo (spec queries, recommended content), global specialization functions (GetSpecialization, GetSpecializationInfo, SetSpecialization), and profession specialization. Use when working with talent trees, talent loadouts, hero talent selection, trait nodes, specialization switching, or talent import/export."
---

# Talents & Specialization API (Retail — Patch 12.0.0)

Comprehensive reference for class talents, hero talents, the traits system, and specialization APIs.

> **Source:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API
> **Current as of:** Patch 12.0.0 (Build 65655) — January 28, 2026
> **Scope:** Retail only.

---

## Scope

- **C_ClassTalents** — Talent loadouts, config management
- **C_Traits** — Trait system (nodes, entries, configs, currencies)
- **C_SpecializationInfo** — Specialization queries
- **Global Spec Functions** — GetSpecialization, SetSpecialization
- **Profession Specialization** — C_ProfessionSpecUI (cross-ref professions skill)

---

## Architecture Overview

The talent system uses a layered architecture:

1. **Specialization** — Top level: player picks a spec (e.g., Fire Mage)
2. **C_ClassTalents** — Manages loadouts (saved talent builds) and provides high-level talent tree interaction
3. **C_Traits** — Low-level trait system: nodes, entries, definitions, configs, currencies
4. **Hero Talents** — Sub-trees within the talent system, selected as a package

---

## C_ClassTalents — Talent Loadouts & Config

### Loadout Management

| Function | Returns | Description |
|----------|---------|-------------|
| `C_ClassTalents.GetActiveConfigID()` | `configID` | Active talent config |
| `C_ClassTalents.GetConfigIDsBySpecID(specID)` | `configIDs` | Configs for spec |
| `C_ClassTalents.GetStarterBuildActive()` | `isActive` | Using starter build? |
| `C_ClassTalents.GetHasStarterBuild()` | `hasStarterBuild` | Starter build available? |
| `C_ClassTalents.SetStarterBuildActive(active)` | `success` | Toggle starter build |
| `C_ClassTalents.GetTraitTreeForSpec(specID)` | `treeID` | Trait tree for spec |
| `C_ClassTalents.GetHeroTalentSpecsForClassSpec(specID)` | `heroSpecIDs` | Hero talent specs |
| `C_ClassTalents.CanCreateNewConfig()` | `canCreate` | Can create new loadout? |
| `C_ClassTalents.RequestNewConfig(name)` | `success` | Create new loadout |
| `C_ClassTalents.DeleteConfig(configID)` | `success` | Delete loadout |
| `C_ClassTalents.RenameConfig(configID, name)` | `success` | Rename loadout |
| `C_ClassTalents.UpdateLastSelectedSavedConfigID(specID, configID)` | — | Set last selected config |
| `C_ClassTalents.GetLastSelectedSavedConfigID(specID)` | `configID` | Last selected config |

### Talent Import/Export

| Function | Returns | Description |
|----------|---------|-------------|
| `C_ClassTalents.ImportLoadout(importString)` | `success, loadoutEntryInfo` | Import talent string |
| `C_ClassTalents.GetLoadoutExportString()` | `exportString` | Export current build |
| `C_ClassTalents.ViewLoadout(loadoutInfo)` | — | Preview a loadout |

### Talent Commit

| Function | Returns | Description |
|----------|---------|-------------|
| `C_ClassTalents.CommitConfig(configID)` | `success` | Apply talent config |
| `C_ClassTalents.CanChangeTalents()` | `canChange, failureReason` | Can change talents? |
| `C_ClassTalents.HasUnspentTalentPoints()` | `hasUnspent` | Has unspent points? |
| `C_ClassTalents.GetConfigBaseName(configID)` | `baseName` | Config display name |

---

## C_Traits — Core Trait System

### Config Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Traits.GetConfigInfo(configID)` | `configInfo` | Config details |
| `C_Traits.GetConfigsByType(configType)` | `configIDs` | Configs by type |
| `C_Traits.HasValidInspectData()` | `hasData` | Valid inspect data? |

### Tree Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Traits.GetTreeInfo(configID, treeID)` | `treeInfo` | Tree structure |
| `C_Traits.GetTreeNodes(treeID)` | `nodeIDs` | All nodes in tree |
| `C_Traits.GetTreeCurrencyInfo(configID, treeID, traitCurrencyIndex)` | `currencyInfo` | Tree currency info |

### Node Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Traits.GetNodeInfo(configID, nodeID)` | `nodeInfo` | Complete node data |
| `C_Traits.GetNodeCost(configID, nodeID)` | `costs` | Node cost |
| `C_Traits.CanPurchaseRank(configID, nodeID)` | `canPurchase` | Can buy next rank? |
| `C_Traits.CanRefundRank(configID, nodeID)` | `canRefund` | Can refund rank? |
| `C_Traits.PurchaseRank(configID, nodeID)` | `success` | Purchase rank |
| `C_Traits.RefundRank(configID, nodeID)` | `success` | Refund rank |
| `C_Traits.SetSelection(configID, nodeID, entryID)` | `success` | Select choice node |
| `C_Traits.GetNodePositionForTree(treeID, nodeID)` | `posX, posY` | Node visual position |

### Node Info Fields

The `nodeInfo` table from `GetNodeInfo()`:

- `ID` — Node ID
- `posX`, `posY` — Position in tree
- `type` — Node type (Single, Tiered, Selection, SubTreeSelection)
- `maxRanks` — Maximum ranks
- `activeRank` — Current active rank
- `currentRank` — Current rank (may differ from active during editing)
- `entryIDs` — Available entries (for choice nodes)
- `activeEntry` — Currently active entry
- `currentEntry` — Entry during editing
- `canPurchaseRank` — Can purchase next rank
- `canRefundRank` — Can refund a rank
- `isAvailable` — Node unlocked
- `isCascadeRepurchasable` — Can cascade repurchase
- `isVisible` — Visible in UI
- `meetsEdgeRequirements` — Edge requirements met
- `groupIDs` — Associated groups
- `visibleEdges` — Connected edges
- `conditionIDs` — Conditions for availability
- `subTreeID` — Sub-tree ID (hero talents)

### Entry Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Traits.GetEntryInfo(configID, entryID)` | `entryInfo` | Entry details |
| `C_Traits.GetDefinitionInfo(definitionID)` | `definitionInfo` | Spell/ability for entry |
| `C_Traits.GetSubTreeInfo(configID, subTreeID)` | `subTreeInfo` | Sub-tree (hero) details |
| `C_Traits.GetSubTreesForSpecID(specID)` | `subTreeIDs` | Sub-trees for spec |

### Entry Info Fields

- `definitionID` — The talent definition
- `type` — Entry type
- `maxRanks` — Max ranks for this entry
- `isAvailable` — Is this entry available
- `conditionIDs` — Conditions

### Definition Info Fields

- `spellID` — Spell granted by this talent
- `overrideName` — Override display name
- `overrideSubtext` — Override subtext
- `overrideIcon` — Override icon

### Condition Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Traits.GetConditionInfo(configID, conditionID)` | `conditionInfo` | Condition details |

### Currency Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Traits.GetTraitCurrencyInfo(traitCurrencyID)` | `currencyInfo` | Currency info |

---

## Global Specialization Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `GetSpecialization()` | `specIndex` | Current spec index (1-4) |
| `GetSpecializationInfo(specIndex [, isInspect [, isPet [, inspectUnit [, sex]]]])` | `id, name, description, icon, role, primaryStat` | Spec details |
| `GetSpecializationInfoByID(specID)` | `id, name, description, icon, role, primaryStat, ...` | Spec details by ID |
| `GetSpecializationInfoForClassID(classID, specIndex)` | `id, name, description, icon, role, primaryStat` | Spec for class |
| `GetSpecializationInfoForSpecID(specID [, sex])` | `id, name, description, icon, role, primaryStat` | Spec by spec ID |
| `GetSpecializationRole(specIndex)` | `role` | Spec's role type |
| `GetSpecializationRoleByID(specID)` | `role` | Role by spec ID |
| `GetNumSpecializations([isInspect [, isPet]])` | `numSpecs` | Number of specs |
| `GetNumSpecializationsForClassID(classID)` | `numSpecs` | Specs for class |
| `SetSpecialization(specIndex)` | — | Switch spec |
| `GetActiveSpecGroup()` | `specGroup` | Active spec group |
| `GetSpecializationMasterySpells(specIndex [, isInspect [, isPet]])` | `spellIDs` | Mastery spell(s) |
| `GetSpecializationSpells(specIndex [, isInspect [, isPet]])` | `... (spellID, level pairs)` | Spec spells |

---

## C_SpecializationInfo

| Function | Returns | Description |
|----------|---------|-------------|
| `C_SpecializationInfo.CanPlayerUseTalentSpecUI()` | `canUse, failureReason` | Can use talent UI? |
| `C_SpecializationInfo.GetAllSelectedPvpTalentIDs()` | `talentIDs` | Selected PvP talents |
| `C_SpecializationInfo.GetInspectSelectedPvpTalent(inspectUnit, talentIndex)` | `talentID` | Inspected PvP talent |
| `C_SpecializationInfo.GetPvpTalentAlertStatus()` | `hasUnspent` | PvP talent alert? |
| `C_SpecializationInfo.GetPvpTalentSlotInfo(slotIndex)` | `slotInfo` | PvP talent slot |
| `C_SpecializationInfo.GetPvpTalentSlotUnlockLevel(slotIndex)` | `level` | PvP slot unlock level |
| `C_SpecializationInfo.GetPvpTalentUnlockLevel(talentID)` | `level` | PvP talent unlock level |
| `C_SpecializationInfo.GetSpellsDisplay(specID)` | `spellIDs` | Display spells for spec |
| `C_SpecializationInfo.IsInitialized()` | `isInitialized` | Spec system ready? |
| `C_SpecializationInfo.MatchesCurrentSpecSet(setID)` | `matches` | Equipment set matches spec? |
| `C_SpecializationInfo.SetPvpTalentLocked(talentID, locked)` | — | Lock PvP talent |

---

## Common Patterns

### Get Active Spec Info

```lua
local specIndex = GetSpecialization()
if specIndex then
    local specID, specName, specDesc, specIcon, specRole = GetSpecializationInfo(specIndex)
    print("Current Spec:", specName, "Role:", specRole)
end
```

### Iterate Talent Tree Nodes

```lua
local configID = C_ClassTalents.GetActiveConfigID()
if configID then
    local specID = PlayerUtil.GetCurrentSpecID and PlayerUtil.GetCurrentSpecID()
                   or GetSpecializationInfo(GetSpecialization())
    local treeID = C_ClassTalents.GetTraitTreeForSpec(specID)
    if treeID then
        local nodeIDs = C_Traits.GetTreeNodes(treeID)
        for _, nodeID in ipairs(nodeIDs) do
            local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID)
            if nodeInfo and nodeInfo.isVisible and nodeInfo.activeRank > 0 then
                local entryInfo = C_Traits.GetEntryInfo(configID, nodeInfo.activeEntry.entryID)
                if entryInfo then
                    local defInfo = C_Traits.GetDefinitionInfo(entryInfo.definitionID)
                    if defInfo then
                        local spellName = C_Spell.GetSpellName(defInfo.spellID)
                        print(spellName, "Rank:", nodeInfo.activeRank)
                    end
                end
            end
        end
    end
end
```

### Export/Import Talent String

```lua
-- Export current talents
local exportString = C_ClassTalents.GetLoadoutExportString()
print("Talent string:", exportString)

-- Import talents (must be out of combat)
local success, loadoutInfo = C_ClassTalents.ImportLoadout(exportString)
if success then
    C_ClassTalents.ViewLoadout(loadoutInfo)
end
```

### Switch Specialization

```lua
local function SwitchSpec(specIndex)
    if specIndex ~= GetSpecialization() then
        if not InCombatLockdown() then
            SetSpecialization(specIndex)
        else
            print("Cannot change spec in combat")
        end
    end
end
```

---

## Key Events

| Event | Payload | Description |
|-------|---------|-------------|
| `PLAYER_SPECIALIZATION_CHANGED` | unit | Specialization changed |
| `ACTIVE_COMBAT_CONFIG_CHANGED` | configID | Active talent config changed |
| `TRAIT_CONFIG_CREATED` | configInfo | New config created |
| `TRAIT_CONFIG_DELETED` | configID | Config deleted |
| `TRAIT_CONFIG_UPDATED` | configID | Config updated |
| `TRAIT_CONFIG_LIST_UPDATED` | — | Config list changed |
| `TRAIT_NODE_CHANGED` | nodeID | Trait node changed |
| `TRAIT_NODE_ENTRY_UPDATED` | nodeID | Node entry updated |
| `TRAIT_TREE_CHANGED` | treeID | Tree structure changed |
| `TRAIT_TREE_CURRENCY_INFO_UPDATED` | treeID | Currency info changed |
| `SPECIALIZATION_CHANGE_CAST_FAILED` | — | Spec change failed |
| `CONFIRM_TALENT_WIPE` | cost, respecType | Confirm talent wipe |
| `STARTER_BUILD_ACTIVATION_FAILED` | — | Starter build failed |
| `SELECTED_PVP_TALENTS_CHANGED` | — | PvP talents changed |
| `PVP_TALENTS_UPDATE` | — | PvP talents refreshed |
| `HERO_TALENT_SELECTION_CHANGED` | — | Hero talent selection changed |

---

## Gotchas & Restrictions

1. **configID is per-spec** — Each specialization has its own set of configs. Active configID changes on spec switch.
2. **Cannot change talents in combat** — `C_ClassTalents.CommitConfig()` and `SetSpecialization()` fail in combat.
3. **Trait system is generic** — `C_Traits` is the underlying system used for class talents, hero talents, AND profession specializations. The `configType` differentiates them.
4. **Node types matter** — Single nodes have one entry, Selection (choice) nodes have multiple entries you pick between.
5. **Hero talents are sub-trees** — Hero talent selection is a SubTreeSelection node type. Use `C_Traits.GetSubTreeInfo()`.
6. **GetNodeInfo is expensive** — Cache node info when iterating the full tree. Don't call in OnUpdate.
7. **Loadout export is opaque** — The export string format is internal. Use the API functions, don't parse manually.
8. **specIndex vs specID** — `GetSpecialization()` returns an index (1-4), not a specID. Use `GetSpecializationInfo()` to get the specID.
