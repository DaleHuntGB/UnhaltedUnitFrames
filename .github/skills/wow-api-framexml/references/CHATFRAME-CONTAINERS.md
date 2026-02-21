# ChatFrame, Containers & Dressing Room

> **Parent skill:** [wow-api-framexml](../SKILL.md)
> **Source:** [FrameXML functions — ChatFrameBase](https://warcraft.wiki.gg/wiki/FrameXML_functions#ChatFrameBase)
> **Source:** [FrameXML functions — UIPanels_Game](https://warcraft.wiki.gg/wiki/FrameXML_functions#UIPanels_Game)

---

## ChatFrame

Source: [FrameXML functions — ChatFrame](https://warcraft.wiki.gg/wiki/FrameXML_functions#ChatFrame)

### `ChatFrame_AddChannel(chatFrame, channelName)`
Detailed Reference: [API ChatFrame_AddChannel](https://warcraft.wiki.gg/wiki/API_ChatFrame_AddChannel)

Activates a chat channel in a specific chat frame so messages from that channel appear in it.

```lua
ChatFrame_AddChannel(ChatFrame1, "Trade")
```

**Arguments:**
- `chatFrame` (Frame) — The chat frame object (e.g., `ChatFrame1`).
- `channelName` (string) — The name of the channel to add.

---

### `ChatFrame_AddMessageEventFilter(event, filterFunc)`
Detailed Reference: [API ChatFrame_AddMessageEventFilter](https://warcraft.wiki.gg/wiki/API_ChatFrame_AddMessageEventFilter)

Adds a filtering function for a specific chat message event. The filter can suppress or modify messages before they are displayed.

```lua
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", function(self, event, msg, sender, ...)
    if msg:find("spam") then
        return true  -- suppress the message
    end
    return false, msg, sender, ...
end)
```

**Arguments:**
- `event` (string) — The chat event to filter (e.g., `"CHAT_MSG_SAY"`, `"CHAT_MSG_WHISPER"`).
- `filterFunc` (function) — Filter function. Return `true` to suppress the message, or `false` followed by modified arguments to alter it.

---

### `ChatFrame_GetMessageEventFilters(event)`
Detailed Reference: [API ChatFrame_GetMessageEventFilters](https://warcraft.wiki.gg/wiki/API_ChatFrame_GetMessageEventFilters)

Returns the list of filter functions registered for a specific chat event.

```lua
local filters = ChatFrame_GetMessageEventFilters("CHAT_MSG_SAY")
```

---

### `ChatFrame_OnHyperlinkShow(reference, link, button)`
Detailed Reference: [API ChatFrame_OnHyperlinkShow](https://warcraft.wiki.gg/wiki/API_ChatFrame_OnHyperlinkShow)

Called when the user clicks on a hyperlink in chat. Handles item tooltips, player links, achievements, etc.

```lua
ChatFrame_OnHyperlinkShow(chatFrame, "item:12345", "LeftButton")
```

---

### `ChatFrame_RemoveMessageEventFilter(event, filterFunc)`
Detailed Reference: [API ChatFrame_RemoveMessageEventFilter](https://warcraft.wiki.gg/wiki/API_ChatFrame_RemoveMessageEventFilter)

Unregisters a previously registered chat message filter function.

```lua
ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SAY", myFilterFunc)
```

---

## ContainerFrame (Bags)

Source: [FrameXML functions — ContainerFrame](https://warcraft.wiki.gg/wiki/FrameXML_functions#ContainerFrame)

Functions for opening, closing, and querying bag states.

### `OpenAllBags(callingFrame, forceUpdate)`
Detailed Reference: [API OpenAllBags](https://warcraft.wiki.gg/wiki/API_OpenAllBags)

Opens all bags. If already open, may close them depending on context.

```lua
OpenAllBags(myFrame)
```

### `CloseAllBags(callingFrame, forceUpdate)`
Detailed Reference: [API CloseAllBags](https://warcraft.wiki.gg/wiki/API_CloseAllBags)

Closes all open bags.

```lua
CloseAllBags()
```

### `ToggleAllBags()`
Detailed Reference: [API ToggleAllBags](https://warcraft.wiki.gg/wiki/API_ToggleAllBags)

Toggles all bags open or closed.

```lua
ToggleAllBags()
```

### `OpenBag(bagID, force)`
Detailed Reference: [API OpenBag](https://warcraft.wiki.gg/wiki/API_OpenBag)

Opens a specific bag by its ID.

```lua
OpenBag(0)  -- Open backpack
```

**Arguments:**
- `bagID` (number) — 0 = Backpack, 1–4 = equipped bags, 5+ = bank bags.
- `force` (boolean) — Force open even if toggle behavior would close it.

### `CloseBag(bagID)`
Detailed Reference: [API CloseBag](https://warcraft.wiki.gg/wiki/API_CloseBag)

Closes a specific bag.

```lua
CloseBag(0)
```

### `ToggleBag(bagID)`
Detailed Reference: [API ToggleBag](https://warcraft.wiki.gg/wiki/API_ToggleBag)

Opens the specified bag if closed, closes it if open.

```lua
ToggleBag(1)
```

### `OpenBackpack()`
Detailed Reference: [API OpenBackpack](https://warcraft.wiki.gg/wiki/API_OpenBackpack)

Opens the backpack (bag 0).

### `CloseBackpack()`
Detailed Reference: [API CloseBackpack](https://warcraft.wiki.gg/wiki/API_CloseBackpack)

Closes the backpack.

### `ToggleBackpack()`
Detailed Reference: [API ToggleBackpack](https://warcraft.wiki.gg/wiki/API_ToggleBackpack)

Toggles the backpack open or closed.

### `IsBagOpen(bagID)`
Detailed Reference: [API IsBagOpen](https://warcraft.wiki.gg/wiki/API_IsBagOpen)

Returns true if the specified bag is currently open.

```lua
if IsBagOpen(0) then
    print("Backpack is open")
end
```

---

## DressUpFrames (Dressing Room)

Source: [FrameXML functions — DressUpFrames](https://warcraft.wiki.gg/wiki/FrameXML_functions#DressUpFrames)

The [Dressing Room](https://warcraft.wiki.gg/wiki/Dressing_room) was added in [Patch 1.7.0](https://warcraft.wiki.gg/wiki/Patch_1.7.0).

### `DressUpItemLink(itemLink)`
Source: [DressUpItemLink (FrameXML)](https://www.townlong-yak.com/framexml/go/DressUpItemLink)

Opens the Dressing Room and previews the given item on the player's character model.

```lua
DressUpItemLink("|cff0070dd|Hitem:12345:::::::::|h[Cool Item]|h|r")
```

**Arguments:**
- `itemLink` (string) — A valid item hyperlink string.

### `DressUpMountLink(itemLink | spellLink)`
Source: [DressUpMountLink (FrameXML)](https://www.townlong-yak.com/framexml/go/DressUpMountLink)

Opens the Dressing Room to preview a mount.

```lua
DressUpMountLink(mountSpellLink)
```

### `DressUpTransmogLink(transmogLink)`
Source: [DressUpTransmogLink (FrameXML)](https://www.townlong-yak.com/framexml/go/DressUpTransmogLink)

Opens the Dressing Room to preview a transmog appearance or illusion.

```lua
DressUpTransmogLink("|Htransmogappearance:12345|h[Appearance]|h")
```

### `SetDressUpBackground(frame, fileName, atlasPostfix)`
Source: [SetDressUpBackground (FrameXML)](https://www.townlong-yak.com/framexml/go/SetDressUpBackground)

Sets the background of the dressing room to a specific race/class/style.

---

## StaticPopup (Dialogs)

Source: [FrameXML functions — UIParent](https://warcraft.wiki.gg/wiki/FrameXML_functions#UIParent)

### `StaticPopup_Show(which [, text_arg1, text_arg2, data])`
Detailed Reference: [API StaticPopup_Show](https://warcraft.wiki.gg/wiki/API_StaticPopup_Show)

Displays a standard dialog box defined in the `StaticPopupDialogs` table.

```lua
-- Simple confirmation
StaticPopup_Show("CONFIRM_DELETE_ITEM", itemName)

-- Custom dialog
StaticPopupDialogs["MY_ADDON_DIALOG"] = {
    text = "Are you sure you want to do %s?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function(self, data)
        DoSomething(data)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}
StaticPopup_Show("MY_ADDON_DIALOG", "this action", nil, myData)
```

**Arguments:**
- `which` (string) — Key in the `StaticPopupDialogs` table.
- `text_arg1` (string) — Fills the first `%s` in the dialog's `text` field.
- `text_arg2` (string) — Fills the second `%s`.
- `data` (any) — Arbitrary data accessible as `dialog.data` in callbacks.

**Returns:**
- `dialog` (Frame) — The dialog frame, or nil if it couldn't be shown.

---

## EasyMenu (Dropdown Menus)

Source: [FrameXML functions — UIParent](https://warcraft.wiki.gg/wiki/FrameXML_functions#UIParent)

### `EasyMenu(menuList, menuFrame, anchor, x, y, displayMode, autoHideDelay)`
Detailed Reference: [API EasyMenu](https://warcraft.wiki.gg/wiki/API_EasyMenu)

A simplified wrapper for creating dropdown context menus without manually setting up `UIDropDownMenu`.

```lua
local menuFrame = CreateFrame("Frame", "MyContextMenu", UIParent, "UIDropDownMenuTemplate")

local menuList = {
    { text = "Option 1", func = function() print("Selected 1") end },
    { text = "Option 2", func = function() print("Selected 2") end },
    { text = "---", notClickable = true, notCheckable = true },  -- separator
    { text = "Cancel", notCheckable = true },
}

EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU")
```

**Arguments:**
- `menuList` (table) — Array of menu item tables. Each entry can contain:
  - `text` (string) — Display text.
  - `func` (function) — Callback when clicked.
  - `checked` (boolean|function) — Whether the item shows a checkmark.
  - `isTitle` (boolean) — If true, acts as a non-clickable header.
  - `notClickable` (boolean) — Makes the item non-interactive.
  - `notCheckable` (boolean) — Hides the checkbox.
  - `hasArrow` (boolean) — Shows a submenu arrow.
  - `menuList` (table) — Submenu items (when `hasArrow` is true).
  - `disabled` (boolean) — Grays out the item.
  - `tooltipTitle`, `tooltipText` — Tooltip for the item.
- `menuFrame` (Frame) — A frame created with `UIDropDownMenuTemplate`.
- `anchor` (string|Frame) — Anchor point. Use `"cursor"` for the mouse position.
- `x` (number) — X offset.
- `y` (number) — Y offset.
- `displayMode` (string) — Usually `"MENU"`.
- `autoHideDelay` (number) — Seconds before auto-hide (optional).
