# AddOn Loading Lifecycle (Retail)

## Load order overview
- Blizzard AddOns load first.
- Custom AddOns load next in alphabetical order.
- .toc directives like `LoadOnDemand`, `Dependencies`, and `LoadWith` can override that default behavior.
- Within a single AddOn, files load in the order listed in the .toc. XML <Include> and <Script> tags load content as they are encountered.

## SavedVariables timing
- By default, saved variables load after the last file in the .toc list.
- `LoadSavedVariablesFirst: 1` loads SavedVariables before all files.
- `ADDON_LOADED` fires when the AddOn has finished loading files and saved variables. This is the earliest safe point to read SavedVariables.

## Login event timeline
A typical login or reload flow:
1. `ADDON_LOADED` - per AddOn; saved variables are available.
2. `PLAYER_LOGIN` - most game data is available; finish one-time setup.
3. `PLAYER_ENTERING_WORLD` - fires for login, reload, and zone transitions.
4. `PLAYER_REGEN_DISABLED` - combat lockdown begins; avoid secure frame changes after this.
5. `SPELLS_CHANGED` - spellbook data is available.

LoadOnDemand AddOns can load at any point and will emit their own `ADDON_LOADED` event when they do.

## Logout sequence
- `PLAYER_LEAVING_WORLD` - not strictly logout; also fires for zone changes.
- `PLAYER_LOGOUT` - last reliable point to update SavedVariables.
- `ADDONS_UNLOADING` - AddOns commit SavedVariables before the UI unloads.

## Error condition
- `SAVED_VARIABLES_TOO_LARGE` may fire if SavedVariables fail to load due to memory limits.

## Examples

Example 1 - Basic event bootstrap:
```
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(_, event, arg1)
  if event == "ADDON_LOADED" and arg1 == "MyAddon" then
    -- Safe to read SavedVariables
  elseif event == "PLAYER_LOGIN" then
    -- Safe to touch most game data
  end
end)
```

Example 2 - Load a module on demand:
```
local function EnsureModule()
  if not C_AddOns.IsAddOnLoaded("MyAddon_Extras") then
    C_AddOns.LoadAddOn("MyAddon_Extras")
  end
end
```

Example 3 - Save on logout:
```
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGOUT")

frame:SetScript("OnEvent", function()
  -- Update SavedVariables before logout
  MyAddonDB.lastLogout = time()
end)
```

## Sources
- https://warcraft.wiki.gg/wiki/AddOn_loading_process
- https://warcraft.wiki.gg/wiki/TOC_format
