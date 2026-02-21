# TOC Format (Retail)

## What the .toc file does
The .toc file is required for every AddOn. It declares metadata (title, notes, version, dependencies), SavedVariables, and the order of Lua or XML files to load.

## Syntax rules
- Metadata lines start with `## Directive: Value`.
- Comments use `#`.
- File entries are plain paths like `core.lua` or `frames.xml`.
- Paths should use backslashes for compatibility, especially when XML uses <Include>.
- File entries load in order from top to bottom.

## Required metadata
- `Interface`: The client interface version for this AddOn. If missing, the AddOn is treated as out of date.

## Common metadata
- `Title`: Display name in the AddOns list.
- `Notes`: Tooltip description in the AddOns list.
- `Version`: AddOn version string.
- `Author`: Author string (readable via `GetAddOnMetadata`).
- `X-...`: Custom metadata fields.

## AddOns list formatting
These fields affect how the AddOn appears in the in-game AddOns list.
- `Category`: Adds a category header.
- `Group`: Groups multiple AddOns under a parent entry.
- `IconTexture`: Texture path for an icon.
- `IconAtlas`: Atlas name for an icon.
- `AddonCompartmentFunc`: Registers a click handler for the AddOn compartment.
- `AddonCompartmentFuncOnEnter`: Optional hover handler.
- `AddonCompartmentFuncOnLeave`: Optional hover leave handler.

## Loading conditions
- `LoadOnDemand`: Delays loading until manually loaded. Use `C_AddOns.LoadAddOn` to load.
- `Dependencies`: Required AddOns that must load first.
- `OptionalDeps`: Optional AddOns that should load first if present.
- `LoadWith`: Loads this AddOn when listed AddOns load. Implies LoadOnDemand.
- `LoadManagers`: If present, causes LoadOnDemand behavior (used by loader AddOns).
- `AllowLoadGameType`: Restricts loading to specified game types.
- `OnlyBetaAndPTR`: Restricts loading to Beta or PTR clients.
- `DefaultState: disabled`: Requires the user to enable the AddOn in the AddOns list.

## SavedVariables directives
- `SavedVariables`: Global saved variables stored at the account level.
- `SavedVariablesPerCharacter`: Per-character saved variables.
- `LoadSavedVariablesFirst`: If set to `1`, loads saved variables before other files.

## Per-file conditions and variables
You can add conditions and variables to file entries:
- Conditions: `[AllowLoadGameType ...]`, `[AllowLoadTextLocale ...]`
- Variables: `[Family]`, `[Game]`, `[TextLocale]`

## Client-specific TOC files
AddOns can ship multiple .toc files with suffixes for specific game types. Prefer comma-delimited Interface values or per-file conditions when possible.

## Restricted directives
The following directives are restricted to Blizzard AddOns and should not be used by third-party AddOns:
- `AllowLoad`
- `EscalateErrorDuringLoad`
- `LoadFirst`
- `SavedVariablesMachine`
- `UseSecureEnvironment`

## Examples

Example 1 - Basic .toc:
```
## Interface: 120001
## Title: MyAddon
## Notes: Minimal example
## Version: 1.0.0

core.lua
```

Example 2 - Load on demand with dependencies:
```
## Interface: 120001
## Title: MyAddon
## LoadOnDemand: 1
## Dependencies: SomeRequiredAddon
## OptionalDeps: OptionalSupport

core.lua
modules\extras.lua
```

Example 3 - Per-file conditions and variables:
```
## Interface: 120001
## Title: MyAddon

[Family]\main.lua
localization\[TextLocale].lua [AllowLoadTextLocale enUS, frFR]
```

## Sources
- https://warcraft.wiki.gg/wiki/TOC_format
