# Project Guidelines

## Code Style
- Prefer `UUF:` namespaced functions with locals declared near the top of each file; keep style compact and low-comment like existing code in [Core/UnitFrame.lua](../Core/UnitFrame.lua) and [Elements/CastBar.lua](../Elements/CastBar.lua).
- Configuration UI uses AceGUI widgets and shared helper wrappers in [Core/Config/GUIWidgets.lua](../Core/Config/GUIWidgets.lua); follow patterns in [Core/Config/GUI.lua](../Core/Config/GUI.lua).
- Defaults live in AceDB tables in [Core/Defaults.lua](../Core/Defaults.lua); update defaults whenever adding new settings.

## Architecture
- AddOn load order is libraries -> elements -> core via [UnhaltedUnitFrames.toc](../UnhaltedUnitFrames.toc), [Elements/Init.xml](../Elements/Init.xml), and [Core/Init.xml](../Core/Init.xml).
- Initialization and event wiring are in [Core/Core.lua](../Core/Core.lua); global utilities, media registration, and `UUF:ResolveLSM()` live in [Core/Globals.lua](../Core/Globals.lua).
- Unit frame creation/update flows through [Core/UnitFrame.lua](../Core/UnitFrame.lua), with element implementations in [Elements/](../Elements/).

## Build and Test
- No build/test commands are documented in this repo.

## Project Conventions
- Use `UUF:QueueOrRun` for protected operations during combat lockdown (see [Core/Core.lua](../Core/Core.lua)).
- Layout is stored in `UnitDB.Frame.Layout` arrays and applied in [Core/UnitFrame.lua](../Core/UnitFrame.lua); keep layout arrays consistent.
- Media is resolved through `UUF.Media` populated by `UUF:ResolveLSM()` in [Core/Globals.lua](../Core/Globals.lua).

## Integration Points
- oUF for frame spawning and colors (see [Libraries/oUF](../Libraries/oUF) and [Core/UnitFrame.lua](../Core/UnitFrame.lua)).
- Ace3 (AceAddon/AceDB/AceGUI), LibSharedMedia, LibDualSpec, LibDeflate, LibDispel (see [Libraries/](../Libraries/)).

## Security
- Combat lockdown applies to frame changes; defer protected changes using `UUF:QueueOrRun` and avoid in-combat layout edits (see [Core/Core.lua](../Core/Core.lua)).
