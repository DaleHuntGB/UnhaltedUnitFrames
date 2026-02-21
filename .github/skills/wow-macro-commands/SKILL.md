```skill
---
name: wow-macro-commands
description: "Complete reference for WoW Retail macro commands (slash commands), macro conditionals, macro syntax and options, secure command rules, castsequence, #show/#showtooltip, and conditional targeting. Use when writing macros, explaining /cast, /use, /castsequence, conditionals like [mod], [harm], [help], [@unit], or any slash command behavior."
---

# WoW Macro Commands

Use this skill when writing, explaining, or debugging World of Warcraft macros (slash commands).

> **Source of truth:** https://warcraft.wiki.gg/wiki/Macro_commands
> **Conditionals:** https://warcraft.wiki.gg/wiki/Macro_conditionals
> **Making a Macro:** https://warcraft.wiki.gg/wiki/Making_a_macro
> **Scope:** Retail only.

## What Macros Are

A macro is a list of slash commands executed sequentially from an action bar button. Each command goes on its own line, preceded by `/`. Macros have a **255 character limit**. Commands are **not** case-sensitive. Multiple commands run in a single frame — there is no way to wait or delay between lines.

```
/y Everybody, dance now!
/dance
```

## Key Concepts

### Macro Execution Rules
- All commands in a macro execute in the **same frame** — no delays.
- You generally cannot cast more than one GCD-triggering spell per macro click.
- Instant spells that do NOT trigger the GCD can chain (e.g., trinket + cooldown + cast).
- If a `/cast` fails, subsequent `/cast` commands in the same macro are blocked.

### Secure vs. Insecure Commands
Only **secure commands** support macro conditionals (`[conditions]`). Insecure commands (chat, emotes) do not. See [references/SYNTAX.md](references/SYNTAX.md) for the full list of secure commands accepted by conditionals.

### The `!` Prefix (Toggle Prevention)
Toggleable abilities (Stealth, Shoot, Mass Dispel ground target) toggle off if `/cast` is pressed again. Prefix with `!` to prevent toggling off:
```
/cast !Stealth
```

## Core Commands Quick Reference

| Command | Purpose |
|---------|---------|
| `/cast` (or `/use`) | Cast a spell or use an item by name |
| `/castsequence` | Cast spells in order, advancing each click |
| `/castrandom` (or `/userandom`) | Cast a random spell/item from a list |
| `/stopcasting` | Stop current cast or channel |
| `/cancelaura` | Remove a buff by name |
| `/cancelform` | Leave current shapeshift form |
| `/cancelqueuedspell` | Cancel queued spell |
| `/stopmacro` | Stop processing the current macro (used with conditionals) |
| `/startattack` / `/stopattack` | Toggle auto-attack |
| `/target` | Target a unit by name (closest match) |
| `/targetexact` | Target by exact name match |
| `/focus` / `/clearfocus` | Set or clear focus target |
| `/click` | Simulate a mouse click on a UI button |
| `/equip` / `/equipslot` / `/equipset` | Equip items |
| `/dismount` | Dismount |
| `/script` (or `/run`) | Execute Lua code (insecure — cannot cast spells) |
| `#show` / `#showtooltip` | Control action bar icon and tooltip display |

## Macro Conditionals Overview

Conditionals let you choose parameters based on game state. They only work with secure commands.

**Basic syntax:**
```
/command [conditions] parameters; [conditions] parameters; ...
```

Clauses are evaluated left to right. The first true set of conditions executes. A clause with no conditions is always true (acts as "else").

```
/cast [help] Renew; [harm] Shadow Word: Pain
```

### Targeting Options (`@unit`)
Temporarily target a unit for this command only — does NOT change your selected target:
- `@player`, `@target`, `@focus`, `@mouseover`, `@party1`, `@raid5`, etc.
- `@cursor` — immediately targets ground under cursor
- `@none` — interrupts auto self-cast, requires targeting cursor

### Common Boolean Conditionals

| Conditional | Description |
|-------------|-------------|
| `exists` | Unit exists |
| `help` / `harm` | Unit can receive helpful/harmful spells |
| `dead` / `nodead` | Unit is dead / alive |
| `combat` / `nocombat` | Player in/out of combat |
| `stealth` / `nostealth` | Player stealthed |
| `mounted` / `nomounted` | Player mounted |
| `swimming` | Player swimming |
| `flying` | Player airborne (mounted/flight form) |
| `flyable` / `advflyable` | Area supports flying / Skyriding |
| `indoors` / `outdoors` | Player location |
| `mod:shift` / `mod:ctrl` / `mod:alt` | Modifier key held |
| `button:1` / `button:2` | Mouse button used (left/right) |
| `group` / `group:raid` / `group:party` | Player in group |
| `spec:1` / `spec:2` | Active spec number |
| `stance:n` / `form:n` | Current stance/form number |
| `known:spell` | Spell is known |
| `equipped:type` | Item type equipped (e.g., `equipped:Shields`) |
| `channeling` / `channeling:spell` | Currently channeling |
| `pet:name` / `pet:family` | Hunter pet by name/family |
| `pvpcombat` | PvP talents are usable |
| `resting` | In rested zone |
| `house:inside` / `house:plot` / `house:editor` / `house:neighborhood` | Housing states (Patch 11.2.7+) |

The `no` prefix inverts any condition: `[nomod]`, `[nodead]`, `[nostealth]`, etc.

See [references/CONDITIONALS.md](references/CONDITIONALS.md) for the complete conditionals reference.

## Castsequence

`/castsequence` advances through a spell list one per click:
```
/castsequence Immolate, Corruption, Curse of Agony
```

**Reset conditions** (placed before the spell list):
```
/castsequence reset=10/target/combat/shift Spell 1, Spell 2, Spell 3
```
- `reset=N` — reset after N seconds of inactivity
- `reset=target` — reset on target change
- `reset=combat` — reset on leaving combat
- `reset=shift/alt/ctrl` — reset when modifier held

## #show and #showtooltip

Control the action bar button's icon and tooltip. Must be on the first line, lowercase only:
```
#showtooltip [modifier:shift] Conjure Food; Conjure Water
```
- `#show` — controls icon only
- `#showtooltip` — controls icon AND tooltip
- Without parameters, uses the first spell WoW auto-detects
- Cannot use both `#show` and `#showtooltip` in the same macro

## Reference Files

| Reference | Contents |
|-----------|----------|
| [SLASH-COMMANDS.md](references/SLASH-COMMANDS.md) | Complete slash command reference organized by category |
| [CONDITIONALS.md](references/CONDITIONALS.md) | Full macro conditionals reference with API equivalents |
| [SYNTAX.md](references/SYNTAX.md) | Macro syntax rules, secure commands list, EBNF grammar |

## Common Macro Patterns

### Mouseover healing with fallback
```
#showtooltip
/cast [@mouseover, help, nodead] [ ] Flash of Light
```

### Focus crowd control
```
#showtooltip Polymorph
/focus [@focus, noharm] [@focus, dead] [modifier]
/stopmacro [@focus, noexists]
/cast [@focus] Polymorph
```

### Modifier-based spell selection
```
#showtooltip
/cast [mod:shift] Healing Word; [mod:ctrl] Power Word: Shield; Heal
```

### Trinket + cooldown + cast
```
#showtooltip Pyroblast
/use 13
/cast Arcane Power
/cast Presence of Mind
/cast Pyroblast
```

### Cancelaura + cast
```
/cancelaura Ice Block
/cast Ice Block
```

### Equip set swap
```
/equipset [equipped:Shields] DPS; Tank
```

## When to Use This Skill

- Writing or debugging WoW macros
- Explaining slash command behavior or syntax
- Working with macro conditionals and targeting
- Understanding secure vs. insecure command restrictions
- Implementing `/castsequence`, `/castrandom`, `#showtooltip`
- Helping with focus, mouseover, or conditional targeting macros
```
