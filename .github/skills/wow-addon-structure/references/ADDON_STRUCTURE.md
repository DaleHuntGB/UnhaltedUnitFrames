# AddOn Folder Structure and Naming

## What this covers
This reference defines how a Retail AddOn should be laid out on disk, how names must match, and how to organize files so the .toc file can load them in a predictable order.

## Required layout rules
- Each AddOn is a folder inside the Retail AddOns directory.
- The folder name and the .toc file name must match exactly.
- The .toc file is mandatory and is the entry point for metadata and file order.

Typical Retail path:
- World of Warcraft\_retail_\Interface\AddOns\AddOnName\AddOnName.toc

## Common layout patterns
A simple layout keeps everything at the root. A modular layout splits features by folder. Use stable, predictable names so both users and tooling can find files quickly.

Recommended subfolders:
- modules - Feature slices loaded in order.
- locale - Localization data and tables.
- media - Textures, sounds, fonts.
- libs - Embedded libraries.

## File types and responsibilities
- .toc: Metadata and file order.
- .lua: All logic and data initialization.
- .xml: Optional UI definitions and includes. XML can load Lua files via <Script> or include other XML files via <Include>.

## Examples

Example 1 - Minimal AddOn layout:
```
MyAddon/
  MyAddon.toc
  MyAddon.lua
```

Example 2 - Modular layout with media and modules:
```
MyAddon/
  MyAddon.toc
  core.lua
  modules/
    bags.lua
    map.lua
  media/
    textures/
    icons.tga
```

Example 3 - Layout with localization and libraries:
```
MyAddon/
  MyAddon.toc
  core.lua
  locale/
    enUS.lua
    frFR.lua
  libs/
    LibStub/LibStub.lua
    CallbackHandler-1.0/CallbackHandler-1.0.lua
```

## Sources
- https://warcraft.wiki.gg/wiki/AddOn
- https://warcraft.wiki.gg/wiki/TOC_format
