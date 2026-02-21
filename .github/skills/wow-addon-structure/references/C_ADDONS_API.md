# C_AddOns API (Retail)

## Purpose
`C_AddOns` provides metadata, enable state, and load state APIs for AddOns. Use these functions to query the AddOn list, read .toc metadata, and load LoadOnDemand AddOns.

## Core query functions
- `C_AddOns.GetNumAddOns()` - Number of AddOns installed.
- `C_AddOns.GetAddOnName(index)` - Name from index.
- `C_AddOns.GetAddOnInfo(name)` - Basic info including title, notes, loadable, reason, security.
- `C_AddOns.GetAddOnTitle(name)` - Title from .toc.
- `C_AddOns.GetAddOnNotes(name)` - Notes from .toc.
- `C_AddOns.GetAddOnInterfaceVersion(name)` - Interface version from .toc.
- `C_AddOns.GetAddOnMetadata(name, key)` - Metadata values (Title, Notes, Author, Version, X-...).
- `C_AddOns.GetAddOnDependencies(name)` - Dependencies list.
- `C_AddOns.GetAddOnOptionalDependencies(name)` - Optional dependencies list.

## Load state functions
- `C_AddOns.IsAddOnLoaded(name)` - Returns whether the AddOn is loaded.
- `C_AddOns.IsAddOnLoadable(name[, character[, demandLoaded]])` - Returns whether an AddOn can be loaded.
- `C_AddOns.IsAddOnLoadOnDemand(name)` - Returns if LoadOnDemand is enabled.
- `C_AddOns.LoadAddOn(name)` - Loads a LoadOnDemand AddOn.

## Enable or disable functions
- `C_AddOns.EnableAddOn(name[, character])`
- `C_AddOns.DisableAddOn(name[, character])`
- `C_AddOns.EnableAllAddOns([character])`
- `C_AddOns.DisableAllAddOns([character])`
- `C_AddOns.SaveAddOns()` - Persists enable state.
- `C_AddOns.ResetAddOns()` and `C_AddOns.ResetDisabledAddOns()` - Resets enable state.

## Namespace table access
- `C_AddOns.GetAddOnLocalTable(name)` - Returns the AddOn namespace table when `AllowAddOnTableAccess` is set in the .toc.

## Notes
- `UIParentLoadAddOn` is a FrameXML helper, not a public AddOn API. Prefer `C_AddOns.LoadAddOn`.
- Avoid deprecated global APIs when a `C_AddOns` function exists.

## Examples

Example 1 - Load a LOD AddOn if possible:
```
local name = "MyAddon_Extras"
local loadable = select(1, C_AddOns.IsAddOnLoadable(name))
if loadable and not C_AddOns.IsAddOnLoaded(name) then
  C_AddOns.LoadAddOn(name)
end
```

Example 2 - Read metadata safely:
```
local title = C_AddOns.GetAddOnMetadata("MyAddon", "Title")
local version = C_AddOns.GetAddOnMetadata("MyAddon", "Version")
```

Example 3 - Disable an AddOn and persist the state:
```
C_AddOns.DisableAddOn("MyAddon")
C_AddOns.SaveAddOns()
```

## Sources
- https://warcraft.wiki.gg/wiki/World_of_Warcraft_API
- https://github.com/Gethe/wow-ui-source/tree/live/Interface/AddOns/Blizzard_APIDocumentationGenerated
