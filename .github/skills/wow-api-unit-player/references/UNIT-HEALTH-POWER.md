# Unit Health, Power & Stats Reference

> **Source:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#Unit
> **Patch:** 12.0.0 (Retail)

## Health Functions

### UnitHealth(unit [, usePredicted]) → health

Returns the current health of a unit.

- **12.0.0:** May return a **secret value** — cannot compare, branch, or do arithmetic. Pass directly to StatusBar widgets.
- `usePredicted` (bool, optional): If true, includes predicted incoming heals/damage.

```lua
local hp = UnitHealth("player")
-- In 12.0: hp may be a secret value
```

### UnitHealthMax(unit) → maxHealth

Returns maximum health. Also a **secret value** in 12.0 when restricted.

### UnitHealthMissing(unit [, usePredicted]) → missing

Returns the missing health (max - current). Also affected by secret values.

### UnitHealthPercent(unit [, usePredicted [, curve]]) → percent

Returns health as a percentage (0-100). Safe to use for threshold checks in 12.0.

```lua
local pct = UnitHealthPercent("target")
if pct and pct < 35 then
    -- Execute range
end
```

### UnitPercentHealthFromGUID(guid) → percent

Returns health percentage from a GUID. Safe percentage value.

### UnitGetIncomingHeals(unit [, healer]) → amount

Predicted incoming heals. If `healer` specified, only heals from that unit.

```lua
local total = UnitGetIncomingHeals("player") or 0
local fromMe = UnitGetIncomingHeals("player", "player") or 0
```

### UnitGetTotalAbsorbs(unit) → amount

Total damage absorb shield value.

### UnitGetTotalHealAbsorbs(unit) → amount

Total heal absorb value (e.g., Necrotic debuff absorbing heals).

### GetUnitHealthModifier(unit) → modifier

### GetUnitMaxHealthModifier(unit) → modifier

Returns health modifiers (multipliers).

### Health Display Pattern (12.0.0 Safe)

```lua
local function UpdateHealthBar(healthBar, unit)
    local hp = UnitHealth(unit)
    local maxHp = UnitHealthMax(unit)
    
    -- SAFE: Pass secret values directly to widgets
    healthBar:SetMinMaxValues(0, maxHp)
    healthBar:SetValue(hp)
    
    -- SAFE: Use percentage for logic
    local pct = UnitHealthPercent(unit)
    if pct then
        if pct < 20 then
            healthBar:SetStatusBarColor(1, 0, 0)  -- Red
        elseif pct < 50 then
            healthBar:SetStatusBarColor(1, 1, 0)  -- Yellow
        else
            healthBar:SetStatusBarColor(0, 1, 0)  -- Green
        end
    end
end
```

---

## Power Functions

### UnitPower(unit [, powerType [, unmodified]]) → power

Returns the current power (mana, rage, energy, etc.).

- `powerType` (number, optional): Power type enum. Defaults to the unit's primary power.
- `unmodified` (bool, optional): If true, returns unmodified raw value.

```lua
local mana = UnitPower("player", Enum.PowerType.Mana)
local rage = UnitPower("player", Enum.PowerType.Rage)
local energy = UnitPower("player", Enum.PowerType.Energy)
```

### UnitPowerMax(unit [, powerType [, unmodified]]) → maxPower

Maximum power value.

### UnitPowerMissing(unit [, powerType [, unmodified]]) → missing

Power deficit (max - current).

### UnitPowerPercent(unit [, powerType [, unmodified [, usePredicted]]]) → percent

Power as percentage (0-100).

### UnitPartialPower(unit [, powerType [, unmodified]]) → partialPower

Fractional power for smooth animation. Returns the fractional part in the range 0-999.

```lua
local wholePower = UnitPower("player")
local fraction = UnitPartialPower("player") / 1000
local smoothPower = wholePower + fraction
```

### UnitPowerType(unit [, index]) → powerType, token, altR, altG, altB

Returns the power type of a unit.

```lua
local powerType, token, r, g, b = UnitPowerType("player")
-- powerType: 0 (Mana)
-- token: "MANA"
-- r, g, b: color for the power bar
```

### UnitPowerDisplayMod(powerType) → mod

Display modifier for power bar scaling.

### GetUnitPowerModifier(unit) → modifier

Power modifier (multiplier).

### Power Type Reference (Enum.PowerType)

| Enum Value | Token | Used By |
|-----------|-------|---------|
| `Enum.PowerType.Mana` (0) | MANA | Healers, Mages, Warlocks |
| `Enum.PowerType.Rage` (1) | RAGE | Warriors, Bear Druids |
| `Enum.PowerType.Focus` (2) | FOCUS | Hunter Pets |
| `Enum.PowerType.Energy` (3) | ENERGY | Rogues, Monks, Cat Druids |
| `Enum.PowerType.ComboPoints` (4) | COMBO_POINTS | Rogues, Cat Druids |
| `Enum.PowerType.Runes` (5) | RUNES | Death Knights |
| `Enum.PowerType.RunicPower` (6) | RUNIC_POWER | Death Knights |
| `Enum.PowerType.SoulShards` (7) | SOUL_SHARDS | Warlocks |
| `Enum.PowerType.LunarPower` (8) | LUNAR_POWER | Balance Druids |
| `Enum.PowerType.HolyPower` (9) | HOLY_POWER | Paladins |
| `Enum.PowerType.Maelstrom` (11) | MAELSTROM | Shamans |
| `Enum.PowerType.Chi` (12) | CHI | Monks |
| `Enum.PowerType.Insanity` (13) | INSANITY | Shadow Priests |
| `Enum.PowerType.ArcaneCharges` (16) | ARCANE_CHARGES | Arcane Mages |
| `Enum.PowerType.Fury` (17) | FURY | Havoc Demon Hunters |
| `Enum.PowerType.Pain` (18) | PAIN | Vengeance DH (legacy) |
| `Enum.PowerType.Essence` (19) | ESSENCE | Evokers |

### Power Bar Pattern

```lua
local function UpdatePowerBar(bar, unit)
    local powerType, token = UnitPowerType(unit)
    local power = UnitPower(unit, powerType)
    local maxPower = UnitPowerMax(unit, powerType)
    
    bar:SetMinMaxValues(0, maxPower)
    bar:SetValue(power)
    
    -- Color by power type
    local info = PowerBarColor[token]
    if info then
        bar:SetStatusBarColor(info.r, info.g, info.b)
    end
end
```

---

## Primary Stats

### UnitStat(unit, index) → stat, effectiveStat, posBuff, negBuff

Returns a primary stat value.

| Index | Stat |
|-------|------|
| 1 | Strength |
| 2 | Agility |
| 3 | Stamina |
| 4 | Intellect |

```lua
-- LE_UNIT_STAT_STRENGTH = 1, etc.
local str, effStr, posStr, negStr = UnitStat("player", 1)
local int, effInt, posInt, negInt = UnitStat("player", 4)
```

### UnitArmor(unit) → base, effectiveArmor, armor, posBuff, negBuff

```lua
local base, effective, _, posBuff, negBuff = UnitArmor("player")
```

---

## Combat Ratings

### GetCombatRating(ratingIndex) → rating

Returns the raw combat rating value. Rating indices are defined as constants:

| Constant | Description |
|----------|-------------|
| `CR_CRIT_MELEE` (9) | Melee crit rating |
| `CR_CRIT_RANGED` (10) | Ranged crit rating |
| `CR_CRIT_SPELL` (11) | Spell crit rating |
| `CR_HASTE_MELEE` (18) | Melee haste rating |
| `CR_HASTE_RANGED` (19) | Ranged haste rating |
| `CR_HASTE_SPELL` (20) | Spell haste rating |
| `CR_AVOIDANCE` (21) | Avoidance rating |
| `CR_LIFESTEAL` (22) | Leech rating |
| `CR_SPEED` (14) | Speed rating |
| `CR_DODGE` (3) | Dodge rating |
| `CR_PARRY` (4) | Parry rating |
| `CR_BLOCK` (5) | Block rating |
| `CR_VERSATILITY_DAMAGE_DONE` (29) | Versatility (damage) |
| `CR_VERSATILITY_DAMAGE_TAKEN` (31) | Versatility (damage reduction) |
| `COMBAT_RATING_RESILIENCE_CRIT_TAKEN` (16) | Resilience |
| `CR_MASTERY` (26) | Mastery rating |

### GetCombatRatingBonus(ratingIndex) → bonus

Returns the percentage bonus provided by the rating.

```lua
local critRating = GetCombatRating(CR_CRIT_MELEE)
local critBonus = GetCombatRatingBonus(CR_CRIT_MELEE)
print("Crit rating:", critRating, "→", critBonus .. "% from gear")
```

---

## Secondary Stats

| Function | Returns | Description |
|----------|---------|-------------|
| `GetCritChance()` | `percent` | Melee crit chance |
| `GetRangedCritChance()` | `percent` | Ranged crit chance |
| `GetSpellCritChance(school)` | `percent` | Spell crit for school |
| `GetHaste()` | `percent` | Haste percentage |
| `GetMeleeHaste()` | `percent` | Melee haste |
| `GetRangedHaste()` | `percent` | Ranged haste |
| `UnitSpellHaste(unit)` | `percent` | Spell haste |
| `GetMastery()` | `percent` | Base mastery |
| `GetMasteryEffect()` | `effect, coeff` | Effective mastery with spec coefficient |
| `GetVersatilityBonus(ratingIndex)` | `bonus` | Versatility bonus % |
| `GetDodgeChance()` | `percent` | Dodge chance |
| `GetParryChance()` | `percent` | Parry chance |
| `GetBlockChance()` | `percent` | Block chance |
| `GetShieldBlock()` | `percent` | Block value |
| `GetLifesteal()` | `percent` | Leech percentage |
| `GetAvoidance()` | `percent` | Avoidance percentage |
| `GetSpeed()` | `percent` | Speed bonus |

### Mastery Example

```lua
local baseMastery = GetMastery()
local effectiveMastery, coefficient = GetMasteryEffect()
print("Base:", baseMastery, "Effective:", effectiveMastery, "Coeff:", coefficient)
```

---

## Attack Power & Damage

### UnitAttackPower(unit) → base, posBuff, negBuff

```lua
local base, pos, neg = UnitAttackPower("player")
local totalAP = base + pos + neg
```

### UnitRangedAttackPower(unit) → base, posBuff, negBuff

### UnitAttackSpeed(unit) → mainSpeed, offSpeed

```lua
local main, off = UnitAttackSpeed("player")
-- off is nil if no offhand weapon
```

### UnitDamage(unit) → lowDmg, hiDmg, ohLow, ohHi, posBuff, negBuff, percentMod

Returns the damage range for auto-attacks.

### UnitRangedDamage(unit) → speed, lowDmg, hiDmg, posBuff, negBuff, percentMod

### Mana Regeneration

```lua
local baseRegen, castingRegen = GetManaRegen()
-- baseRegen: mana per second while not casting
-- castingRegen: mana per second while casting
```

---

## Armor Effectiveness

### C_PaperDollInfo.GetArmorEffectiveness(armor, attackerLevel) → effectiveness

Returns damage reduction percentage for given armor vs attacker level.

```lua
local _, armor = UnitArmor("player")
local dr = C_PaperDollInfo.GetArmorEffectiveness(armor, UnitLevel("player"))
print("Damage reduction:", dr * 100 .. "%")
```

### C_PaperDollInfo.GetArmorEffectivenessAgainstTarget(armor) → effectiveness

Armor DR against the current target.

### C_PaperDollInfo.GetStaggerPercentage(unit) → stagger, staggerVsTarget

Monk Brewmaster stagger percentage.

---

## Related Events

| Event | Payload | Description |
|-------|---------|-------------|
| `UNIT_HEALTH` | `unitTarget` | Health changed |
| `UNIT_MAXHEALTH` | `unitTarget` | Max health changed |
| `UNIT_POWER_UPDATE` | `unitTarget, powerType` | Power changed |
| `UNIT_POWER_FREQUENT` | `unitTarget, powerType` | Power changed (frequent updates) |
| `UNIT_MAXPOWER` | `unitTarget, powerType` | Max power changed |
| `UNIT_STATS` | `unitTarget` | Stats (str/agi/sta/int) changed |
| `UNIT_ATTACK_POWER` | `unitTarget` | Attack power changed |
| `UNIT_DAMAGE` | `unitTarget` | Damage range changed |
| `UNIT_RANGEDDAMAGE` | `unitTarget` | Ranged damage changed |
| `UNIT_ATTACK_SPEED` | `unitTarget` | Attack speed changed |
| `UNIT_SPELL_HASTE` | `unitTarget` | Spell haste changed |
| `UNIT_ABSORB_AMOUNT_CHANGED` | `unitTarget` | Absorb shield changed |
| `UNIT_HEAL_ABSORB_AMOUNT_CHANGED` | `unitTarget` | Heal absorb changed |
| `UNIT_HEAL_PREDICTION` | `unitTarget` | Incoming heals changed |
| `COMBAT_RATING_UPDATE` | — | Combat ratings changed |
| `MASTERY_UPDATE` | — | Mastery changed |
| `PLAYER_DAMAGE_DONE_MODS` | `unitTarget` | Damage modifiers changed |

> **Sources:**
> - https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#Unit
> - https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#PlayerScript
> - https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#PaperDollInfo
