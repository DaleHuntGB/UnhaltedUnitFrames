# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

UnhaltedUnitFrames is a World of Warcraft addon that replaces default unit frames. Built on the oUF framework with Ace3 libraries for configuration. No build system - WoW loads Lua files directly via the .toc manifest.

## Architecture

### Load Order (UnhaltedUnitFrames.toc)

1. **Libraries/** - Dependencies loaded via Init.xml: LibStub → CallbackHandler → LibSharedMedia → Ace3 (AceAddon, AceDB, AceGUI) → LibDualSpec → LibDispel → oUF → TaintLess
2. **Elements/** - UI components (HealthBar, PowerBar, CastBar, Auras, Indicators, etc.)
3. **Core/** - Main addon logic (Core.lua → Defaults.lua → Globals.lua → UnitFrame.lua → Config/)

### Key Files

- `Core/Core.lua` - Ace3 addon lifecycle (OnInitialize, OnEnable), database setup, slash commands (`/uuf`, `/uf`)
- `Core/Defaults.lua` - Complete default configuration schema for all units
- `Core/Globals.lua` - Helper functions, media registration, event handlers
- `Core/UnitFrame.lua` - Frame spawning via `UUF:SpawnUnitFrame(unit)` and updates via `UUF:UpdateAllUnitFrames()`
- `Core/Config/GUI.lua` - Configuration UI (large file, ~180KB)

### Element Pattern

Every element follows Create/Update convention:
```lua
function UUF:CreateUnitHealthBar(unitFrame, unit)  -- Called once at frame creation
function UUF:UpdateUnitHealthBar(unitFrame, unit)  -- Called when settings change
```

### Database Structure

Configuration stored in `UUF.db.profile` via AceDB:
- `General` - Global settings (fonts, textures, colors)
- `Units.player`, `Units.target`, `Units.boss`, etc. - Per-unit config with Frame, HealthBar, PowerBar, CastBar, Auras, Tags, Indicators sections

### Important Globals

- `UUF.db` - AceDB database instance
- `UUF.LSM` - LibSharedMedia-3.0
- `UUF.oUF` - oUF framework
- `UUF.BOSS_FRAMES[]` - Array of boss frame instances (1-10)

### Unit Naming

`UUF:GetNormalizedUnit(unit)` converts boss1-boss10 → "boss" for config lookup. Frame names use `UUF:FetchFrameName(unit)` (e.g., "player" → "UUF_Player").

## Testing

Test boss frames without an encounter:
```lua
/run UUF.BOSS_TEST_MODE = true; UUF:UpdateBossFrames()
```

Test auras:
```lua
/run UUF.AURA_TEST_MODE = not UUF.AURA_TEST_MODE
```

## Adding a New Element

1. Create `Elements/NewElement.lua` with `UUF:CreateUnitNewElement()` and `UUF:UpdateUnitNewElement()` functions
2. Add to `Elements/Init.xml`
3. Call Create in `UnitFrame.lua:UUF:CreateUnitFrame()`
4. Call Update in `UnitFrame.lua:UUF:UpdateUnitFrame()`
5. Add defaults to `Defaults.lua` under each unit
6. Add GUI panels in `Config/GUI.lua`

## Layout Arrays

Position data uses format: `{AnchorPoint, RelativeTo, OffsetX, OffsetY}` (e.g., `{"CENTER", "CENTER", 0, 0}`)

## Disabled Features

Range.lua and Totems.lua are commented out in Elements/Init.xml.
