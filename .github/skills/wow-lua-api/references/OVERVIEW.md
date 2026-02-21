# Overview

## What this covers
- Lua 5.1 base functions and standard libraries exposed in the WoW client.
- Blizzard-specific adjustments and WoW-only helpers called out on the Lua functions page.

## Key environment notes
- The WoW API does not expose the `os` or `io` libraries, so addons cannot use OS or file system APIs.
- The Lua functions page documents small differences from stock Lua where Blizzard changed behavior.
- For debugging helpers, use the Debugging section of the WoW API page.

## How to navigate
- Use BASIC_FUNCTIONS for global base functions.
- Use the library files for math, string, table, bit, and coroutine helpers.
- Check the detail files for method-call syntax and table method caveats.

## Sources
- https://warcraft.wiki.gg/wiki/Lua_functions
- https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#Debugging
- http://www.lua.org/manual/5.1/manual.html
