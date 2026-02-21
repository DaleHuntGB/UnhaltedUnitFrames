# Macro Syntax Reference

Complete reference for WoW macro syntax rules, secure command list, options grammar, and advanced patterns.

> **Source:** https://warcraft.wiki.gg/wiki/Making_a_macro
> **Secure Command Options:** https://warcraft.wiki.gg/wiki/Secure_command_options

---

## Basic Macro Structure

```
/command parameters
/command parameters
...
```

- Each command goes on its own line, preceded by `/`.
- Commands run sequentially in the **same frame** — no delays are possible.
- Macros have a **255 character limit**.
- Command names are **not case-sensitive**.
- `#show` and `#showtooltip` must be **lowercase**.

---

## Conditional Options Syntax

### General Form

```
/command [conditions] parameters; [conditions] parameters; default_parameters
```

- Clauses separated by `;` are evaluated left to right.
- The first clause with all true conditions executes. Remaining clauses are skipped.
- A clause with **no conditions** (empty brackets `[ ]` or no brackets at all) is always true.
- Conditions within `[brackets]` are comma-separated and use AND logic.

### Anatomy

```
/cast [mod:shift, @focus] Polymorph; [harm] Shadow Word: Pain; Heal
       \_____/ \______/                \__/
         |        |                      |
    condition  condition            condition
       \_____________/                 \__/
             |                          |
     condition set (AND)          condition set
       \______________________/ \_______________/ \___/
                  |                     |           |
           clause 1              clause 2       clause 3 (default)
```

### Condition Building Blocks

```
[<no>condition<:parameter</parameter</...>>>]
```

- `no` prefix inverts the condition
- `:parameter` adds specificity
- `/` separates OR'd parameters within a condition
- `,` separates AND'd conditions within a bracket set

**Example:** `[nostance:1/2]` = "NOT in stance 1 and NOT in stance 2"

### EBNF Grammar

```ebnf
command        = "/" command-verb [ { command-object ";" } command-object ]
command-verb   = <any secure command word>
command-object = { condition } parameters
parameters     = <anything passed to the command>
condition      = "[" condition-phrase { "," condition-phrase } "]"
condition-phrase = ( [ "no" ] option-word [ ":" option-argument { "/" option-argument } ]
                   | "@" target )
option-argument  = <one-word option: shift, ctrl, target, 1, 2, etc.>
target           = <a valid unit ID>
```

---

## Secure Commands (Accept Conditionals)

Only these commands support `[conditional]` syntax. Insecure commands (chat, emotes, `/run`) do NOT.

### Casting & Combat
| Command | Notes |
|---------|-------|
| `/cast` | Cast spell or use item |
| `/use` | Same as `/cast` (favors items on name conflict) |
| `/castrandom` | Random from list |
| `/userandom` | Same as `/castrandom` |
| `/castsequence` | Sequential casting |
| `/cancelaura` | Remove a buff |
| `/cancelform` | Leave shapeshift |
| `/startattack` | Begin auto-attack |
| `/stopattack` | Stop auto-attack |
| `/stopcasting` | Cancel current cast |
| `/stopmacro` | Halt macro execution |

### Targeting
| Command | Notes |
|---------|-------|
| `/target` | Target by name |
| `/targetexact` | Target by exact name |
| `/targetenemy` | Cycle hostile units |
| `/targetenemyplayer` | Cycle hostile players |
| `/targetfriend` | Cycle friendly units |
| `/targetfriendplayer` | Cycle friendly players |
| `/targetparty` | Cycle party members |
| `/targetraid` | Cycle raid members |
| `/targetlasttarget` | Previous target |
| `/targetlastfriend` | Previous friendly target |
| `/targetlastenemy` | Previous hostile target |
| `/assist` | Target-of-target |
| `/focus` | Set focus |
| `/clearfocus` | Clear focus |
| `/cleartarget` | Clear target |

### Equipment & UI
| Command | Notes |
|---------|-------|
| `/equip` | Equip item (not technically secure but supports conditionals) |
| `/equipslot` | Equip to specific slot |
| `/equipset` | Use equipment manager set |
| `/changeactionbar` | Switch action bar page |
| `/swapactionbar` | Swap between two pages |
| `/click` | Simulate button click |
| `/dismount` | Dismount |

### Pet
| Command | Notes |
|---------|-------|
| `/petassist` | Pet assist mode |
| `/petattack` | Pet attack |
| `/petautocaston` | Enable pet autocast |
| `/petautocastoff` | Disable pet autocast |
| `/petdefensive` | Pet defensive mode |
| `/petfollow` | Pet follow |
| `/petpassive` | Pet passive mode |
| `/petstay` | Pet stay |

### Metacommands (use `#` not `/`)
| Command | Notes |
|---------|-------|
| `#show` | Control button icon |
| `#showtooltip` | Control button icon and tooltip |

---

## Key Units for [@] Targeting

Some commands have "key units" — when you use that unit in `[@]`, the command can still accept another unit parameter. Without a key unit match, the `@` unit overrides the parameter.

| Command | Key Unit | Default Unit |
|---------|----------|--------------|
| `/target` | target | — |
| `/focus` | focus | target |
| `/startattack` | target | target |
| `/petattack` | pettarget | target |

**Example:**
```
/focus [@focus, dead] [@focus, noharm] target
```
Since the key unit is `focus`, the `/focus` command can still accept `target` as its parameter.

---

## Common Pitfalls

### Extra Semicolon Bug
```
/petattack [@focus, harm];
```
The trailing `;` creates an empty clause that always evaluates true — if focus is not harmful, `/petattack` runs with no target (attacks your current target). Remove the trailing semicolon.

### GCD Blocking
```
/cast Overpower
/cast Execute
/cast Mortal Strike
```
This does NOT work. If `Overpower` fails but would trigger the GCD, all subsequent `/cast` commands are blocked. Only instant, non-GCD spells can chain.

### Conditions Are Case-Sensitive
`[Help]` produces an error. Always use lowercase: `[help]`.

### Toggleable Abilities
```
/cast Stealth
```
Pressing again toggles Stealth OFF. Use `!` to prevent:
```
/cast !Stealth
```

---

## /castsequence Syntax

```
/castsequence [conditionals] reset=conditions Spell 1, Spell 2, Spell 3
```

### Reset Conditions
Placed after conditionals but before the spell list:

| Reset | Meaning |
|-------|---------|
| `reset=N` | Reset after N seconds of **inactivity** (not since first cast). |
| `reset=target` | Reset when you change targets. |
| `reset=combat` | Reset when you leave combat. |
| `reset=shift` | Reset when macro activated with Shift held. |
| `reset=alt` | Reset when macro activated with Alt held. |
| `reset=ctrl` | Reset when macro activated with Ctrl held. |

Combine with `/`: `reset=10/target/combat`

### Behavior
- Advances one step per successful cast.
- If a spell fails, the sequence stays at that position.
- After the last spell, wraps back to the first.
- Multiple `/castsequence` in one macro each track independently.

---

## /click Syntax

```
/click ButtonName [MouseButton]
```

- `ButtonName` — the UI frame name of the button
- `MouseButton` — optional: `LeftButton` (default), `RightButton`, `MiddleButton`, `Button4`, `Button5`

### Standard Action Bar Button Names

| Bar | Button Name Pattern |
|-----|-------------------|
| Main Bar | `ActionButton#` |
| Dynamic Bar (forms/stances) | `BonusActionButton#` |
| Bottom Left Bar | `MultiBarBottomLeftButton#` |
| Bottom Right Bar | `MultiBarBottomRightButton#` |
| Right Bar | `MultiBarRightButton#` |
| Right Bar 2 | `MultiBarLeftButton#` |
| Pet Bar | `PetActionButton#` |
| Stance Bar | `ShapeshiftButton#` |

Replace `#` with button number (1-12).

---

## /script and /run

```
/run lua_code_here
```

- `/run` and `/script` are equivalent; `/run` saves 4 characters.
- The entire script must be one line per `/run` command.
- Multiple `/run` commands can appear in one macro.
- **Cannot** cast spells, use items, change targets, or change action bars from scripts.
- **Can** do: chat messages, UI manipulation, variable checks, addon communication.

---

## Empty Conditions Pattern

Use `[ ]` (space inside brackets) as an "else" / "always true" fallback that preserves normal command behavior (including self-cast settings):

```
/cast [@mouseover, help, nodead] [ ] Flash of Light
```
This casts on mouseover if friendly and alive, otherwise behaves exactly like clicking `/cast Flash of Light` normally.

---

## Macro Chaining with /click

Split long macros across multiple buttons using `/click`:

**Button 1 (your hotkey):**
```
/cast [mod:shift] Spell A
/click MultiBarRightButton1
```

**MultiBarRightButton1:**
```
/cast [mod:ctrl] Spell B; Spell C
```
