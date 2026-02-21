# SavedVariables (Retail)

## What SavedVariables are
SavedVariables are Lua tables saved between sessions for AddOns and the default UI. They are persisted to disk on logout or reload and reloaded on the next session.

Typical storage locations:
- Account-wide AddOn data: `WTF/Account/ACCOUNTNAME/SavedVariables/ADDONNAME.lua`
- Per-character AddOn data: `WTF/Account/ACCOUNTNAME/REALMNAME/CHARNAME/SavedVariables/ADDONNAME.lua`

The files are plain Lua. They should be treated as data only and not as code.

## Declaring SavedVariables in the .toc
- `## SavedVariables: MyAddonDB`
- `## SavedVariablesPerCharacter: MyAddonCharDB`

## Load timing
- SavedVariables load after the last .toc file by default.
- Use `LoadSavedVariablesFirst: 1` to load them before files.
- `ADDON_LOADED` is the earliest point you can safely read them.

## Best practices
- Always guard for nil and create defaults when first run.
- Version your data with a schema or revision field.
- Avoid storing functions or userdata; use tables, numbers, strings, and booleans.
- Keep data compact to avoid `SAVED_VARIABLES_TOO_LARGE` errors.

## Examples

Example 1 - Global defaults:
```
MyAddonDB = MyAddonDB or {}
MyAddonDB.enabled = MyAddonDB.enabled ~= false
MyAddonDB.opacity = MyAddonDB.opacity or 0.8
```

Example 2 - Per-character defaults:
```
MyAddonCharDB = MyAddonCharDB or {}
MyAddonCharDB.profile = MyAddonCharDB.profile or {
  showMinimap = true,
  trackedBosses = {},
}
```

Example 3 - Simple schema migration:
```
MyAddonDB = MyAddonDB or { schemaVersion = 1 }
if MyAddonDB.schemaVersion < 2 then
  MyAddonDB.newField = true
  MyAddonDB.schemaVersion = 2
end
```

## Common pitfalls
- A stray `SavedVariables.lua` in the wrong directory can shadow the correct file.
- Large data sets or unbounded logs can cause load failures.

## Sources
- https://warcraft.wiki.gg/wiki/SavedVariables
- https://warcraft.wiki.gg/wiki/TOC_format
- https://warcraft.wiki.gg/wiki/AddOn_loading_process
