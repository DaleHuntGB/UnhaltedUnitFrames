# Viewing Blizzard UI Source (Retail)

## Why this matters
Blizzard UI source is the best reference for patterns, event usage, and XML layouts. Use it to understand how Blizzard frames are built and how built-in AddOns structure their files.

## Exporting interface files from the client
Use the console at the login or character selection screen:
- `ExportInterfaceFiles code`
- `ExportInterfaceFiles art`

The client writes output to:
- BlizzardInterfaceCode
- BlizzardInterfaceArt

Important restriction: Export commands only work in the console at login or character select. They do not work via the `/console` slash command in-game.

## Viewing interface data on the web
- https://github.com/Gethe/wow-ui-source
- https://www.townlong-yak.com/framexml

## Examples

Example 1 - Extract and browse locally:
1. Start the client with the console enabled.
2. Run `ExportInterfaceFiles code` at the login screen.
3. Open BlizzardInterfaceCode and search for your target frame name.

Example 2 - Use the GitHub source to locate a file:
1. Open the wow-ui-source repo.
2. Search for a frame name or XML template.
3. Follow references to see how it is instantiated.

Example 3 - Use Townlong Yak for quick browsing:
1. Open the FrameXML browser.
2. Navigate to the AddOn or XML file.
3. Review the Lua event handlers that back the UI.

## Sources
- https://warcraft.wiki.gg/wiki/Viewing_Blizzard%27s_interface_code
