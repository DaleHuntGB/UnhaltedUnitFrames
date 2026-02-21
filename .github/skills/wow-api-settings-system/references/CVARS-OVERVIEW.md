# CVar Overview Notes

This file is a short, curated helper and not a full list of CVars.
For the complete list, see https://warcraft.wiki.gg/wiki/Console_variables

## Quick Workflow

- Prefer `GetCVar` and `SetCVar` in addon code.
- Use `/console` for one-off changes and debugging.
- Edit Config.wtf only while the game is closed.

## Secure CVars

- Secure CVars cannot be changed in combat.
- Secure CVars must be changed with `SetCVar`, not `/console`.
- Use `GetCVarInfo` to check secure status.

## Scope and Sync

- Some CVars are account wide, others are character specific.
- `config-cache.wtf` values can sync to the server when `synchronizeConfig` is enabled.
- Resetting may not clear synced values; use `cvar_default` or set defaults explicitly.

## Resetting

- Reset a single CVar with `SetCVar(name, GetCVarDefault(name))`.
- Use `/console cvar_default` to reset all CVars to defaults.
- Use `/console cvar_reset` to reset to startup values.

## Discovering CVars and Commands

- The wiki list is updated periodically; check the page header for patch versions.
- Console commands like `cvar_default`, `cvar_reset`, and `cvarlist` are documented on the same page.
- API helpers like `C_Console.GetAllCommands` can enumerate console commands.

## Safety Tips for AddOns

- Avoid changing CVars without explicit user opt-in.
- If you modify CVars, store previous values and restore on disable when appropriate.
