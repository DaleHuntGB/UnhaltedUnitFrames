# ACE3 & oUF: Visual Comparison Charts

## ACE3 Module Status at a Glance

### Loaded vs. Available

```
█████████████ LOADED (7 modules)
████████████████████████ AVAILABLE IN LIBRARY (15 total)

┌─────────────────────────────────────────┐
│ LOADED MODULES                          │
├─────────────────────────────────────────┤
│ ✅ AceAddon-3.0        │ Core framework  │
│ ✅ AceDB-3.0           │ Profiles        │
│ ✅ AceConsole-3.0      │ Chat commands   │
│ ✅ AceGUI-3.0          │ Config UI       │
│ ✅ AceGUI-SharedMedia  │ Media picker    │
│ ✅ AceSerializer-3.0   │ Data export     │
│ ✅ AceDBOptions-3.0    │ Profile UI      │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ NOT LOADED (Available: 8 modules)                       │
├──────────────────────────┬──────────────┬───────────────┤
│ Module                   │ Priority     │ Use Case      │
├──────────────────────────┼──────────────┼───────────────┤
│ ⭐ AceBucket-3.0        │ HIGH         │ Event batch   │
│ ⭐ AceTimer-3.0         │ MEDIUM       │ Timer mgmt    │
│ AceEvent-3.0            │ LOW          │ Event wrap    │
│ AceHook-3.0             │ LOW          │ Secure hook   │
│ AceComm-3.0             │ VERY LOW     │ Raids only    │
│ AceLocale-3.0           │ VERY LOW     │ i18n         │
│ AceTab-3.0              │ VERY LOW     │ Tab complete  │
│ AceConfig-3.0           │ LOW          │ Config reg    │
└──────────────────────────┴──────────────┴───────────────┘
```

---

## oUF Tags Coverage Analysis

### By Category: Complete Breakdown

```
HEALTH TAGS (5 total)
┌──────────────┬────────┬───────────────────────┐
│ Tag          │ Status │ Notes                 │
├──────────────┼────────┼───────────────────────┤
│ [curhp]      │ ✅     │ Exposed via variants  │
│ [maxhp]      │ ✅     │ Exposed via variants  │
│ [perhp]      │ ✅     │ Direct usage          │
│ [missinghp]  │ ✅     │ Direct usage          │
│ [absorbs]    │ ✅ UUF │ Custom extension      │
└──────────────┴────────┴───────────────────────┘

POWER TAGS (7 total)
┌──────────────┬────────┬───────────────────────┐
│ [curpp]      │ ✅     │ Via color variants    │
│ [maxpp]      │ ✅     │ Via color variants    │
│ [perpp]      │ ✅     │ Direct usage          │
│ [missingpp]  │ ✅     │ Direct usage          │
│ [powercolor] │ ✅     │ Color prefix only     │
│ [curmana]    │ ❌     │ EASY ADD              │
│ [maxmana]    │ ❌     │ Rarely needed        │
└──────────────┴────────┴───────────────────────┘

CLASS TAGS (10 total)
┌──────────────────┬────────┬────────────────────┐
│ [class]          │ ✅     │ Working             │
│ [name]           │ ✅     │ Via variants        │
│ [level]          │ ❌ ⭐  │ **MUST ADD**        │
│ [smartlevel]     │ ❌ ⭐  │ **MUST ADD**        │
│ [creature]       │ ❌     │ Nice to have        │
│ [smartclass]     │ ❌     │ Useful addition     │
│ [race]           │ ❌     │ Low priority        │
│ [sex]            │ ❌     │ Niche use           │
│ [faction]        │ ❌     │ Low priority        │
└──────────────────┴────────┴────────────────────┘

STATUS TAGS (7 total) ⭐⭐⭐
┌──────────────────┬────────┬────────────────────┐
│ [status]         │ ❌ ⭐  │ **MUST ADD**        │
│ [dead]           │ ❌     │ Part of status      │
│ [offline]        │ ❌     │ Part of status      │
│ [resting]        │ ❌     │ Part of status      │
│ [pvp]            │ ❌     │ Arena useful        │
│ [leader]         │ ❌     │ Group indicator     │
│ [leaderlong]     │ ❌     │ Verbose version     │
└──────────────────┴────────┴────────────────────┘

CLASSIFICATION TAGS (6 total) ⭐⭐⭐
┌──────────────────────┬────────┬────────────────────┐
│ [classification]     │ ❌ ⭐  │ **MUST ADD**        │
│ [shortclassif.]      │ ❌ ⭐  │ **MUST ADD**        │
│ [plus]               │ ❌     │ Standalone +        │
│ [rare]               │ ❌     │ Rare only           │
│ [affix]              │ ❌     │ Affix indicator     │
│ [difficulty]         │ ❌     │ Color coded         │
└──────────────────────┴────────┴────────────────────┘

THREAT TAGS (3 total) ⭐⭐⭐
┌──────────────────┬────────┬────────────────────┐
│ [threat]         │ ❌ ⭐  │ **MUST ADD**        │
│ [threatcolor]    │ ❌ ⭐  │ **MUST ADD**        │
│ [raidcolor]      │ ✅     │ Working             │
└──────────────────┴────────┴────────────────────┘

POWER TYPE TAGS (6 total)
┌──────────────────┬────────┬────────────────────┐
│ [cpoints]        │ ❌     │ Class-specific      │
│ [chi]            │ ❌     │ Monk only           │
│ [soulshards]     │ ❌     │ Warlock only        │
│ [holypower]      │ ❌     │ Paladin only        │
│ [runes]          │ ❌     │ DK only             │
│ [arcanecharges]  │ ❌     │ Mage only           │
└──────────────────┴────────┴────────────────────┘

MISC TAGS (8 total)
┌──────────────────┬────────┬────────────────────┐
│ [arenaspec]      │ ❌     │ Arena only          │
│ [group]          │ ❌     │ Raid group #        │
└──────────────────┴────────┴────────────────────┘
```

---

## Quick Implementation Impact Chart

```
IMPACT vs. EFFORT: See Where the Value Is

HIGH IMPACT, LOW EFFORT (DO FIRST):
╔════════════════════════════════════════════════════════╗
║ ⭐ Add [threat] tag                    ~5 lines    1 min║
║ ⭐ Add [status] tag                   ~10 lines    2 min║
║ ⭐ Add [level] tag                     ~3 lines    1 min║
║ ⭐ Add [classification] tag            ~10 lines   2 min║
║ ⭐ Add [smartlevel] tag                ~12 lines   2 min║
║ ⭐ Add LDB minimap icon               ~80 lines   60 min║
║ ⭐ Centralize timers                 ~100 lines   30 min║
╚════════════════════════════════════════════════════════╝

HIGH IMPACT, MEDIUM EFFORT:
╔════════════════════════════════════════════════════════╗
║ ⭐ Event batching (AceBucket)        ~200 lines   180 min║
║ · Trace all RegisterEvent calls       analysis    30 min║
║ · Consolidate into buckets           refactor    100 min║
║ · Test & verify behavior             testing     50 min║
╚════════════════════════════════════════════════════════╝

MEDIUM IMPACT, HIGH EFFORT (DEFER):
╔════════════════════════════════════════════════════════╗
║ · Add spec-specific tags              ~50 lines   120 min║
║ · Advanced hooking system            ~100 lines   150 min║
║ · Localization framework             ~200 lines   180 min║
╚════════════════════════════════════════════════════════╝

LOW IMPACT, ANY EFFORT (SKIP):
├─ Addon messaging (no use case)
├─ Tab completion (rare feature)
└─ Chinese/French localization (single dev)
```

---

## Event System Consolidation Map

### Current State: Scattered

```
┌───────────────────────────────────────────────────────────┐
│ Core/Core.lua                                             │
├─────────────────────────────────────────────────────────┬─┤
│ Frame 1: playerSpec    → PLAYER_SPECIALIZATION_CHANGED  │ │
│ Frame 2: groupUpdate   → GROUP_ROSTER_UPDATE            │ │
│                           PLAYER_ROLES_ASSIGNED         │ │
│ Frame 3: tempGuardian  → PLAYER_CONTROL_LOST/GAINED     │ │
│                           COMPANION_UPDATE              │ │
│                           UNIT_PET                      │ │
│                           UNIT_SPELLCAST_SUCCEEDED      │ │
│ Frame 4: safeQueue     → PLAYER_REGEN_ENABLED           │ │
├─────────────────────────────────────────────────────────┤ │
│ Elements/Range.lua                                      │ │
├─────────────────────────────────────────────────────────┤ │
│ Frame 5: spellUpdate   → PLAYER_ENTERING_WORLD          │ │
│                           SPELLS_CHANGED                │ │
│ Frame 6: rangeEvents   → PLAYER_TARGET_CHANGED, etc.    │ │
├─────────────────────────────────────────────────────────┤ │
│ Elements/SecondaryPowerBar.lua                          │ │
├─────────────────────────────────────────────────────────┤ │
│ Frame 7: powerUpdate   → TRAIT_CONFIG_UPDATED, etc.     │ │
├─────────────────────────────────────────────────────────┤ │
│ + 3 more scattered frames throughout Elements/          │ │
├─────────────────────────────────────────────────────────┤ │
│ TOTAL: ~10-12 discrete event frame objects              │ │
└─────────────────────────────────────────────────────────┴─┘

EFFICIENCY: ⚠️ Moderate (works, but scattered)
```

### Proposed State: Consolidated

```
┌───────────────────────────────────────────────────────────┐
│ Core/EventManager.lua (NEW)                              │
├─────────────────────────────────────────────────────────┬─┤
│ AceBucket Bucket 1: Unit Changes                        │ │
│  ├─ PLAYER_SPECIALIZATION_CHANGED                      │ │
│  ├─ GROUP_ROSTER_UPDATE                               │ │
│  ├─ PLAYER_ROLES_ASSIGNED                             │ │
│  └─ UNIT_PET, etc.                  → Batch 0.1s     │ │
│                                                        │ │
│ AceBucket Bucket 2: Range & Spells                    │ │
│  ├─ PLAYER_TARGET_CHANGED                            │ │
│  ├─ SPELL_UPDATE_COOLDOWN                            │ │
│  ├─ SPELLS_CHANGED                                   │ │
│  └─ others                         → Batch 0.05s     │ │
│                                                        │ │
│ Standard Events: Queued Operations                     │ │
│  └─ PLAYER_REGEN_ENABLED           → Safe queue      │ │
├─────────────────────────────────────────────────────────┤ │
│ TOTAL: ~4-5 event subscriptions (3-4 AceBuckets)     │ │
└─────────────────────────────────────────────────────────┴─┘

EFFICIENCY: ✅ Good (consolidated + batched)
PERFORMANCE: ✅ ~25% reduction in OnEvent calls
CODE CLARITY: ✅ All events in single location
```

---

## Tag Recommendation Tiers

### TIER 1: CRITICAL (Add in Phase 1)

```
Priority:  ████████████████████ 100/100
Effort:    ██░░░░░░░░░░░░░░░░░░ 10/100
Value:     ████████████████████ 95/100

Tags:      [threat] [threatcolor] [status] [level]
           [classification] [smartlevel]

Implementation Time: 30-60 minutes
Config UI Impact: +6 new dropdown options
Player Benefit: Immediate (tanks/healers benefit most)

Code Sample Location: Core/Config/TagsDatabase.lua
Events Required: New event integration
```

### TIER 2: RECOMMENDED (Phase 2+)

```
Priority:  ██████████░░░░░░░░░░ 50/100
Effort:    ██░░░░░░░░░░░░░░░░░░ 10/100
Value:     ████████░░░░░░░░░░░░ 65/100

Tags:      [dead] [offline] [shortclassification]
           [curmana] [pvp] [leader]

Context: Less critical than Tier 1, but easy additions
Players benefit: Situational (depends on playstyle)
```

### TIER 3: OPTIONAL (Class-Specific)

```
Priority:  ███░░░░░░░░░░░░░░░░░ 30/100
Effort:    ████░░░░░░░░░░░░░░░░ 20/100
Value:     ██████░░░░░░░░░░░░░░ 40/100

Tags:      [cpoints] [chi] [soulshards] [holypower]
           [runes] [arcanecharges]

Context: Niche, class-specific power displays
Players benefit: Specific specs only (~20% playerbase)
Recommendation: Add UI to enable/disable by class
```

---

## File Change Summary

### Files to Modify (Tier 1 Implementation)

```
PRIORITY ORDER:

1. Core/Config/TagsDatabase.lua
   ├─ Add 6 tag method implementations          ~40 lines added
   ├─ Register tags in tag database             ~10 lines added
   ├─ Add new tag categories in UI              ~15 lines added
   └─ Add event registrations                    ~5 lines added
   TOTAL: ~70 lines | Effort: LOW

2. Core/Globals.lua (optional)
   └─ Add LDB registration                      ~15 lines added
   TOTAL: ~15 lines | Effort: LOW (if doing LDB)

3. Elements/Tags.lua
   └─ No changes needed                         Updates automatic
   TOTAL: ~0 lines | Effort: NONE

4. Core/Init.xml (optional - for LDB)
   └─ Include LDB module                        1 line
   TOTAL: ~1 line | Effort: TRIVIAL
```

### Files to Create (Optional)

```
Core/LDB.lua (Optional - for minimap icon)
├─ LibDataBroker registration                   ~80 lines
├─ Tooltip handling                            ~10 lines
└─ Click-to-config callback                    ~5 lines
TOTAL: ~100 lines | Effort: MEDIUM
```

---

## Before/After Comparison

### User Experience (UI/UX)

```
BEFORE:
┌────────────────────────────────────────────┐
│ Target Frame Tags Available:               │
│ ├─ Name/Class combinations       (6 opts) │
│ ├─ Health/Absorb combinations    (8 opts) │
│ ├─ Power combinations             (10 opts)│
│ └─ Misc (classification, level)   (5 opts) │
│    TOTAL: 29 tag options                   │
└────────────────────────────────────────────┘

Config Icons: None (command only: /uuf)

AFTER (Tier 1):
┌────────────────────────────────────────────┐
│ Target Frame Tags Available:               │
│ ├─ Name/Class combinations       (6 opts) │
│ ├─ Health/Absorb combinations    (8 opts) │
│ ├─ Power combinations            (10 opts) │
│ ├─ Status (ADDED)                (4 opts) │ ← NEW
│ ├─ Threat (ADDED)               (2 opts) │ ← NEW
│ ├─ Classification (ADDED)        (3 opts) │ ← NEW
│ └─ Level (ADDED)                (2 opts) │ ← NEW
│    TOTAL: 35+ tag options                  │
└────────────────────────────────────────────┘

Config Icons: /uuf + Minimap click
```

### Performance (Backend)

```
BEFORE:
Event Processing:
├─ ~10-12 discrete event frames
├─ Multiple rapid updates per frame
├─ 5x scattered C_Timer calls
└─ Manual event wire-up
Overhead: Baseline

AFTER (Full implementation):
Event Processing:
├─ ~4-5 event frames (consolidated)
├─ Batched updates (0.05s-0.1s)
├─ 1x centralized timer system
└─ AceBucket-managed events
Overhead: -25% reduction in OnEvent calls
```

---

## Decision Matrix

### Should We Implement These?

| Enhancement | Value | Risk | Effort | Recommend |
|-------------|-------|------|--------|-----------|
| **Tier 1 Tags** | ⭐⭐⭐⭐⭐ | 🟢 Low | 1h | **YES** |
| **LDB Icon** | ⭐⭐⭐⭐ | 🟢 Low | 1h | **YES** |
| **Timer Mgmt** | ⭐⭐⭐ | 🟢 Low | 1h | **YES** |
| **Event Batch** | ⭐⭐⭐ | 🟡 Med | 3h | **MAYBE** |
| **Spec Tags** | ⭐⭐ | 🟢 Low | 2h | **LATER** |
| **Localization** | ⭐⭐ | 🟢 Low | 8h | **NO** |
| **AceComm** | ⭐ | 🟡 Med | 6h | **NO** |

**Recommendation:** Implement Tier 1 (3 hours), consider event batching if performance is priority.

---

**Generated:** February 17, 2026  
**Purpose:** Visual reference for research findings  
**Status:** Ready for decision-making
