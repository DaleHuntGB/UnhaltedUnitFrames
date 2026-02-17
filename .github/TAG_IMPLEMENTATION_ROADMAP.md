# oUF Tags Implementation Roadmap

## Quick Reference: All Available oUF Tags vs. Current Usage

### Health & Absorption (5 tags)

| Tag | Event(s) | Current Status | Priority | Notes |
|-----|----------|------------------|----------|-------|
| `[curhp]` | UNIT_HEALTH, UNIT_MAXHEALTH | ✅ Used | - | Via `curhp:abbr` variants |
| `[maxhp]` | UNIT_MAXHEALTH | ✅ Used | - | Via `maxhp:abbr` variants |
| `[perhp]` | UNIT_HEALTH, UNIT_MAXHEALTH | ✅ Used | - | Direct usage + `curhpperhp` |
| `[missinghp]` | UNIT_HEALTH, UNIT_MAXHEALTH | ✅ Used | - | Direct usage |
| Custom `[absorbs]` | UNIT_ABSORB_AMOUNT_CHANGED | ✅ Implemented | - | Custom UUF extension |

**Status:** ✅ COMPLETE - No action needed

---

### Power Types (7 tags)

| Tag | Event(s) | Current Status | Priority | Recommendation |
|-----|----------|------------------|----------|-----------------|
| `[curpp]` | UNIT_POWER_UPDATE, UNIT_MAXPOWER | ✅ Used | - | Via color/abbr variants |
| `[maxpp]` | UNIT_MAXPOWER | ✅ Used | - | Via color/abbr variants |
| `[perpp]` | UNIT_MAXPOWER, UNIT_POWER_UPDATE | ✅ Used | - | Direct usage |
| `[missingpp]` | UNIT_MAXPOWER, UNIT_POWER_UPDATE | ✅ Used | - | Direct usage |
| `[curmana]` | UNIT_POWER_UPDATE, UNIT_MAXPOWER | ❌ Not exposed | MEDIUM | Add variant `[curmana:abbr]` for Mana-only display |
| `[maxmana]` | UNIT_POWER_UPDATE, UNIT_MAXPOWER | ❌ Not exposed | LOW | Rarely needed |
| `[powercolor]` | UNIT_DISPLAYPOWER | ✅ Used | - | Used as color prefix in tags |

**Recommendation:** Add `[curmana]` and `[curmana:abbr]` variants for priest/shaman/mage mana-specific displays.

**Status:** ✅ MOSTLY COMPLETE

---

### Class & Character Information (10 tags)

| Tag | Event(s) | Current Status | Priority | Recommendation |
|-----|----------|------------------|----------|-----------------|
| `[class]` | N/A (unit info) | ✅ Used | - | Working correctly |
| `[race]` | N/A (unit info) | ❌ Not exposed | LOW | Add to Name tags section for RP/social addons |
| `[sex]` | N/A (unit info) | ❌ Not exposed | LOW | Niche use (pronouns, etc.) |
| `[creature]` | N/A (unit info) | ❌ Not exposed | MEDIUM | **RECOMMEND:** Add for NPC identification |
| `[faction]` | NEUTRAL_FACTION_SELECT_RESULT | ❌ Not exposed | LOW | Alliance/Horde indicator |
| `[smartclass]` | N/A | ❌ Not exposed | MEDIUM | **RECOMMEND:** Valuable for mixed frames |
| `[level]` | UNIT_LEVEL, PLAYER_LEVEL_UP | ❌ Not exposed | **HIGH** | **MUST ADD:** Essential for target/focus frames |
| `[smartlevel]` | UNIT_LEVEL, PLAYER_LEVEL_UP, UNIT_CLASSIFICATION_CHANGED | ❌ Not exposed | **HIGH** | **MUST ADD:** Level + elite indicator |
| `[name]` | UNIT_NAME_UPDATE | ✅ Used | - | Via `name:colour` and `name:short:*` |

**Key Recommendations:**
1. **`[level]`** - CRITICAL for target frames (shows player/NPC level)
2. **`[smartlevel]`** - CRITICAL for threat assessment (level + elite status combined)
3. **`[creature]`** - RECOMMENDED for NPC frames
4. **`[smartclass]`** - RECOMMENDED for player/NPC distinction

**Status:** ⚠️ INCOMPLETE - 3 essential tags missing

---

### Status & Connectivity (7 tags) - **RECOMMENDED TIER 1**

| Tag | Event(s) | Current Status | Priority | Implementation |
|-----|----------|------------------|----------|-----------------|
| `[dead]` | UNIT_HEALTH | ❌ Not exposed | **HIGH** | Dead/Ghost status display |
| `[offline]` | UNIT_HEALTH, UNIT_CONNECTION | ❌ Not exposed | **HIGH** | Connection status for party |
| `[status]` | UNIT_HEALTH, PLAYER_UPDATE_RESTING, UNIT_CONNECTION | **CRITICAL** | **HIGH** | **RECOMMENDED:** Combined dead/offline/resting |
| `[resting]` | PLAYER_UPDATE_RESTING | ❌ Not exposed | LOW | Only for player unit |
| `[pvp]` | UNIT_FACTION | ❌ Not exposed | MEDIUM | **RECOMMEND:** Show PvP flag in arenas |
| `[leader]` | PARTY_LEADER_CHANGED | ❌ Not exposed | MEDIUM | Show group leader |
| `[leaderlong]` | PARTY_LEADER_CHANGED | ❌ Not exposed | LOW | Verbose version of above |

**Tier 1 Implementation (add immediately):**
```
Health Tags category - ADD:
  [status] = "Combined Status (Dead/Offline/Resting)"
  [offline] = "Offline Status"
  [dead] = "Dead/Ghost Status"
```

**Status:** ❌ INCOMPLETE - **PRIORITY: Add all TAG 1 items**

---

### Classification & Difficulty (6 tags) - **RECOMMENDED TIER 1**

| Tag | Event(s) | Current Status | Priority | Implementation |
|-----|----------|------------------|----------|-----------------|
| `[classification]` | UNIT_CLASSIFICATION_CHANGED | ❌ Not exposed | **HIGH** | **MUST ADD:** Elite/Rare/Boss status |
| `[shortclassification]` | UNIT_CLASSIFICATION_CHANGED | ❌ Not exposed | **HIGH** | **MUST ADD:** E/R/B abbreviation |
| `[plus]` | UNIT_CLASSIFICATION_CHANGED | ❌ Not exposed | MEDIUM | Solo `+` indicator for elite |
| `[rare]` | UNIT_CLASSIFICATION_CHANGED | ❌ Not exposed | MEDIUM | Rare flag only |
| `[affix]` | UNIT_CLASSIFICATION_CHANGED | ❌ Not exposed | LOW | Affix (multiplier) indicator |
| `[difficulty]` | UNIT_FACTION | ❌ Not exposed | MEDIUM | Color difficulty indicator |

**Tier 1 Implementation (add immediately):**
```
Misc Tags category - ADD:
  [classification] = "Unit Classification (Elite/Rare/Boss/Affix)"
  [shortclassification] = "Unit Classification Abbreviated"
```

**Status:** ❌ INCOMPLETE - **PRIORITY: Add classification tags**

---

### Threat & Combat (5 tags) - **RECOMMENDED TIER 1**

| Tag | Event(s) | Current Status | Priority | Implementation |
|-----|----------|------------------|----------|-----------------|
| `[threat]` | UNIT_THREAT_SITUATION_UPDATE | ❌ Not exposed | **HIGH** | **MUST ADD:** Threat status (++/--/Aggro) |
| `[threatcolor]` | UNIT_THREAT_SITUATION_UPDATE | ❌ Not exposed | **HIGH** | **MUST ADD:** Threat color prefix |
| `[raidcolor]` | N/A (unit info) | ✅ Used | - | Class color for raid |
| `[powercolor]` | UNIT_DISPLAYPOWER | ✅ Used | - | Power color prefix |

**Tier 1 Implementation (add to Misc or new Combat category):**
```
Combat Tags category - ADD:
  [threat] = "Threat Status (++/--/Aggro)"
  [threatcolor] = "Threat Colour - Prefix"
```

**Use Case:** Essential for tanks (own threat), healers (party threat), and threat-aware DPS.

**Status:** ❌ INCOMPLETE - **PRIORITY: Add threat tags**

---

### Group & Raid (3 tags)

| Tag | Event(s) | Current Status | Priority | Implementation |
|-----|----------|------------------|----------|-----------------|
| `[group]` | GROUP_ROSTER_UPDATE | ❌ Not exposed | MEDIUM | Raid group number (1-8) |
| `[leader]` | PARTY_LEADER_CHANGED | ❌ Not exposed | MEDIUM | Group leader status |
| `[leaderlong]` | PARTY_LEADER_CHANGED | ❌ Not exposed | LOW | Verbose leader indicator |

**Status:** ⚠️ INCOMPLETE - Optional but useful for raid/group frames

---

### Class-Specific Power (6 tags) - **RECOMMENDED TIER 2**

| Tag | Event(s) | Current Status | Priority | Recommendation |
|-----|----------|------------------|----------|-----------------|
| `[cpoints]` | UNIT_POWER_FREQUENT, PLAYER_TARGET_CHANGED | ❌ Not exposed | MEDIUM | Combo point display (Rogue/Druid/Demon Hunter) |
| `[chi]` | UNIT_POWER_UPDATE, PLAYER_TALENT_UPDATE | ❌ Not exposed | LOW | Chi display (Monk Windwalker) |
| `[soulshards]` | UNIT_POWER_UPDATE | ❌ Not exposed | LOW | Soul shard display (Warlock) |
| `[holypower]` | UNIT_POWER_UPDATE, PLAYER_TALENT_UPDATE | ❌ Not exposed | LOW | Holy power display (Paladin Retribution) |
| `[runes]` | RUNE_POWER_UPDATE | ❌ Not exposed | LOW | Rune availability display (Death Knight) |
| `[arcanecharges]` | UNIT_POWER_UPDATE, PLAYER_TALENT_UPDATE | ❌ Not exposed | LOW | Arcane charges (Mage Arcane) |

**Recommendation:** 
- `[cpoints]` - Consider adding if player base has many melee DPS
- Others - Low priority, niche use cases

**Status:** ⚠️ INCOMPLETE - Spec-specific, lower priority

---

### Arena & PvP (1 tag)

| Tag | Event(s) | Current Status | Priority | Recommendation |
|-----|----------|------------------|----------|-----------------|
| `[arenaspec]` | ARENA_PREP_OPPONENT_SPECIALIZATIONS | ❌ Not exposed | LOW | Arena opponent spec indicator |

**Status:** ⚠️ INCOMPLETE - PvP-only, niche

---

## Implementation Plan

### Phase 1: Tier 1 - Essential Tags (2-3 hours)

**CRITICAL PATH - Add immediately:**

```lua
-- In Core/Config/TagsDatabase.lua, add to Health Tags:
oUF.Tags.Methods["status"] = function(unit)
    if(UnitIsDead(unit)) then
        return "Dead"
    elseif(UnitIsGhost(unit)) then
        return "Ghost"
    elseif(not UnitIsConnected(unit)) then
        return "Offline"
    else
        return _TAGS['resting'](unit)
    end
end

oUF.Tags.Methods["dead"] = function(u)
    if(UnitIsDead(u)) then
        return "Dead"
    elseif(UnitIsGhost(u)) then
        return "Ghost"
    end
end

oUF.Tags.Methods["offline"] = function(u)
    if(not UnitIsConnected(u)) then
        return "Offline"
    end
end

-- For classification:
oUF.Tags.Methods["classification"] = function(u)
    local c = UnitClassification(u)
    if(c == 'rare') then
        return 'Rare'
    elseif(c == 'rareelite') then
        return 'Rare Elite'
    elseif(c == 'elite') then
        return 'Elite'
    elseif(c == 'worldboss') then
        return 'Boss'
    elseif(c == 'minus') then
        return 'Affix'
    end
end

-- For threat:
oUF.Tags.Methods["threat"] = function(u)
    local s = UnitThreatSituation(u)
    if(s == 1) then
        return '++'
    elseif(s == 2) then
        return '--'
    elseif(s == 3) then
        return 'Aggro'
    end
end
```

**Add to TagsDatabase categories:**
- **Health Tags:** Add `[status]`, `[dead]`, `[offline]`
- **Misc Tags:** Add `[classification]`, `[shortclassification]`, `[threat]`, `[threatcolor]`, `[level]`, `[smartlevel]`

**Expected benefit:** Massive UX improvement for all playstyles

### Phase 2: Tier 2 - Optional Spec Tags (4+ hours)

**After Phase 1, if player demand warrants:**
- Add `[cpoints]` for melee DPS
- Add `[chi]` for Monks
- Add spec-specific power indicators
- Create "Class-Specific Power" tag category in config UI

### Phase 3: Performance Optimization (3-4 hours)

**Parallel with Phase 1-2:**
- Implement AceBucket event batching
- Centralize timer management
- Add LDB minimap icon

---

## Tag Categories - Current vs. Proposed

### Current Categories (4 total)
1. Health Tags (9 tags)
2. Power Tags (13 tags)
3. Name Tags (4 tags)
4. Misc Tags (9 tags)

### Proposed New Structure (6+ categories)
1. **Health Tags** (9 + 3 new = 12 tags)
   - Add: `[status]`, `[dead]`, `[offline]`

2. **Power Tags** (13 + 1 new = 14 tags)
   - Add: `[curmana:abbr]` variant

3. **Name Tags** (4 tags) - NO CHANGE

4. **Status Tags** (new category - 4 tags)
   - `[status]` (combined)
   - `[dead]`
   - `[offline]`
   - `[pvp]`

5. **Threat Tags** (new category - 2 tags)
   - `[threat]`
   - `[threatcolor]`

6. **Classification Tags** (new category - 4 tags)
   - `[classification]`
   - `[shortclassification]`
   - `[level]`
   - `[smartlevel]`

7. **Misc Tags** (9 + 4 reorg = 9 tags)
   - Rearranged from current

8. **Class-Specific Power** (optional - 6 tags)
   - `[cpoints]`
   - `[chi]`
   - `[soulshards]`
   - `[holypower]`
   - `[runes]`
   - `[arcanecharges]`

---

## Event Reference

**Events for Tier 1 Tags:**

| Event | Tags Updated | Frequency |
|-------|--------------|-----------|
| UNIT_HEALTH | `[status]`, `[dead]`, `[offline]` | Frequent during combat |
| UNIT_CONNECTION | `[offline]`, `[status]` | Rare (login/logout) |
| UNIT_CLASSIFICATION_CHANGED | `[classification]`, `[shortclassification]` | Low (target change) |
| UNIT_THREAT_SITUATION_UPDATE | `[threat]`, `[threatcolor]` | Frequent during combat |
| UNIT_LEVEL | `[level]`, `[smartlevel]` | Low (target change) |

**Integration:** All already handled by oUF tag system - no new event infrastructure needed.

---

## Summary: Top 10 Tags to Add

**Ranked by Impact:**

1. ✅ **`[threat]`** - Tank/healer essential
2. ✅ **`[threatcolor]`** - Tank/healer essential  
3. ✅ **`[status]`** - Party/raid essential
4. ✅ **`[classification]`** - Pulls/target awareness
5. ✅ **`[level]`** - Party/raid essential
6. ✅ **`[smartlevel]`** - Elite detection
7. ✅ **`[shortclassification]`** - Space-efficient classification
8. ⚠️ **`[dead]`** - Niche (can use `[status]`)
9. ⚠️ **`[offline]`** - Niche (can use `[status]`)
10. ⚠️ **`[cpoints]`** - Class-specific, optional

**Minimum add (1 hour):** `[threat]`, `[threatcolor]`, `[status]`, `[classification]`, `[smartlevel]`

**Recommended add (2 hours):** Above + `[level]`, `[dead]`, `[offline]`, `[shortclassification]`

---

**Last Updated:** February 17, 2026  
**Scope:** oUF tag implementation roadmap for UnhaltedUnitFrames  
**Level of Detail:** Implementation-ready
