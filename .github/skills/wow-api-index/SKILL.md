---
name: wow-api-index
description: "Master index and glossary for all WoW API skills. Maps every C_ namespace, API system, and category to the skill that documents it. Use this skill FIRST when looking up any WoW API function to find which domain skill contains the full documentation. Current as of Patch 12.0.0 (Retail only)."
---

# WoW API Skill Index

This is the master glossary for all WoW Addon API skills. Use this index to find
which skill documents a specific API system, C_ namespace, or function category.

> **Source of truth:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API
> **Current as of:** Patch 12.0.0 (Build 65655) — January 28, 2026
> **Scope:** Retail only. No deprecated or removed functions.

## How to Use This Index

1. Find the **API system name** (e.g., `C_Item`, `C_QuestLog`, `UnitHealth`)
2. Look it up in the reference tables below to find the **skill name**
3. Read that skill for full function signatures, parameters, return values, and examples
4. If the skill doesn't exist yet, fetch the wiki page directly: `https://warcraft.wiki.gg/wiki/API_<FunctionName>`

## Reference Files

| Reference | Contents |
|-----------|----------|
| [DOMAIN-SKILLS.md](references/DOMAIN-SKILLS.md) | Detailed per-domain tables with API systems and key functions |
| [NAMESPACE-LOOKUP.md](references/NAMESPACE-LOOKUP.md) | `C_` namespace → skill quick lookup (~90 entries) |
| [CATEGORY-LOOKUP.md](references/CATEGORY-LOOKUP.md) | Wiki category → skill quick lookup (~45 entries) |
| [MAINTENANCE.md](references/MAINTENANCE.md) | How to update this index when skills or patches change |

---

## Domain Skills Summary

| Skill | Scope | Status |
|-------|-------|--------|
| wow-addon-structure | Addon files, TOC, SavedVariables, loading lifecycle | :white_check_mark: |
| wow-api-widget | Widget API, widget hierarchy, all frame/region/texture/font/animation types | :white_check_mark: |
| wow-api-xml-schema | XML schema, XML elements, attributes, templates, UI definitions in XML | :white_check_mark: |
| wow-api-framexml | FrameXML functions, mixins, pools, SharedXML & game utils | :white_check_mark: || wow-api-unit-player | Unit functions, player info, auras, roles, death | :white_check_mark: |
| wow-api-spells-abilities | Spells, spellbook, action bars, cooldowns, casting | :white_check_mark: |
| wow-api-items-inventory | Items, bags, bank, loot, equipment | :white_check_mark: |
| wow-api-combat | Combat log, threat, damage meters, loss of control | :white_check_mark: |
| wow-api-quests | Quest log, quest info, quest offers, content tracking | :white_check_mark: |
| wow-api-map-navigation | Maps, area POIs, taxi, waypoints, vignettes | :white_check_mark: |
| wow-api-social-chat | Chat, clubs/communities, friends, voice, BattleNet | :white_check_mark: |
| wow-api-guild | Guild management, guild bank | :white_check_mark: |
| wow-api-group-lfg | Party, dungeon finder, premade groups, social queue | :white_check_mark: |
| wow-api-pvp | PvP, battlegrounds, arenas, war mode | :white_check_mark: |
| wow-api-professions | Tradeskill UI, crafting orders, recipes | :white_check_mark: |
| wow-api-collections | Mounts, pets, pet battles, toys | :white_check_mark: |
| wow-api-transmog | Transmog, appearances, sets, outfits, dye colors | :white_check_mark: |
| wow-api-achievements | Achievements, statistics | :white_check_mark: |
| wow-api-calendar-events | Calendar, event scheduler | :white_check_mark: |
| wow-api-encounters | Encounter journal, timeline, M+, instances | :white_check_mark: |
| wow-api-reputation | Reputation, major factions | :white_check_mark: |
| wow-api-currency-economy | Currency, auction house, tokens, stores | :white_check_mark: |
| wow-api-talents | Class talents, hero talents, traits, specialization | :white_check_mark: |
| wow-api-settings-system | CVars, console, settings, sound, video, build info | :white_check_mark: |
| wow-macro-commands | Macro slash commands, conditionals, syntax, /cast, /use, #showtooltip | :white_check_mark: |
| wow-api-housing | Player housing (new Patch 12.0) | :white_check_mark: |
| wow-api-events | Game events reference and payloads | :white_check_mark: |
| wow-lua-api | Lua 5.1 base functions, libraries, and WoW-only additions | :white_check_mark: |
| wow-api-lua-environment | WoW Lua specifics, restrictions, taint system | :white_check_mark: |
| wow-api-escape-sequences | UI escape sequences: color codes, inline textures, atlas markup, grammar, Kstrings | :white_check_mark: |
| wow-api-weekly-rewards | Great Vault / weekly rewards | :white_check_mark: |
| wow-api-misc-systems | Miscellaneous smaller API systems | :white_check_mark: |

### Status Legend

| Status | Meaning |
|--------|---------|
| :white_check_mark: | Skill exists and is documented |
| :construction: | Skill planned but not yet created |
