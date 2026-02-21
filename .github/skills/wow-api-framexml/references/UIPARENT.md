# UIParent Functions

> **Parent skill:** [wow-api-framexml](../SKILL.md)
> **Source:** [FrameXML functions — UIParent](https://warcraft.wiki.gg/wiki/FrameXML_functions#UIParent)

These functions toggle standard Interface Panels and provide general UI helpers.

> **Note:** Functions that use `ShowUIPanel()` internally cannot be called in combat due to Blizzard's taint/combat lockdown system.

---

## Panel Toggle Functions

### `ShowUIPanel(frame, force)`
Detailed Reference: [API ShowUIPanel](https://warcraft.wiki.gg/wiki/API_ShowUIPanel)

Displays a standard UI panel using the managed panel layout system. This is the underlying mechanism most `Toggle*` functions use. Cannot be called in combat.

**Syntax:**
```lua
ShowUIPanel(frame [, force])
```

**Arguments:**
- `frame` (Frame) — The panel frame to show.
- `force` (boolean) — If true, forces the panel open even if it would normally be blocked.

---

### `PVEFrame_ToggleFrame()`
Source: [PVEFrame_ToggleFrame (FrameXML)](https://www.townlong-yak.com/framexml/go/PVEFrame_ToggleFrame)

Toggles the **Group Finder** (Dungeon Finder / Raid Finder / Premade Groups) window.

**Syntax:**
```lua
PVEFrame_ToggleFrame()
```

---

### `ToggleAchievementFrame()`
Source: [ToggleAchievementFrame (FrameXML)](https://www.townlong-yak.com/framexml/go/ToggleAchievementFrame)

Shows or hides the **Achievements** frame.

**Syntax:**
```lua
ToggleAchievementFrame()
```

---

### `ToggleCharacter(index)`
Detailed Reference: [API ToggleCharacter](https://warcraft.wiki.gg/wiki/API_ToggleCharacter)

Toggles the **Character** pane to the specified frame (e.g., "PaperDollFrame", "ReputationFrame", "TokenFrame").

**Syntax:**
```lua
ToggleCharacter(index)
```

**Arguments:**
- `index` (string) — The name of the subframe to show. Valid values include:
  - `"PaperDollFrame"` — Character stats/equipment
  - `"ReputationFrame"` — Reputation tab
  - `"TokenFrame"` — Currency tab

---

### `ToggleCollectionsJournal(index)`
Source: [ToggleCollectionsJournal (FrameXML)](https://www.townlong-yak.com/framexml/go/ToggleCollectionsJournal)

Toggles the **Collections** window (Mounts, Pets, Toys, Heirlooms, Appearances).

**Syntax:**
```lua
ToggleCollectionsJournal(index)
```

**Arguments:**
- `index` (number) — Tab index to open. 1 = Mounts, 2 = Pets, 3 = Toys, 4 = Heirlooms, 5 = Appearances.

---

### `ToggleEncounterJournal()`
Source: [ToggleEncounterJournal (FrameXML)](https://www.townlong-yak.com/framexml/go/ToggleEncounterJournal)

Toggles the **Adventure Guide** (Encounter Journal / Dungeon Journal).

**Syntax:**
```lua
ToggleEncounterJournal()
```

---

### `ToggleFriendsFrame([tabNumber])`
Detailed Reference: [API ToggleFriendsFrame](https://warcraft.wiki.gg/wiki/API_ToggleFriendsFrame)

Opens or closes the **Friends** pane, optionally on a specific tab.

**Syntax:**
```lua
ToggleFriendsFrame([tabNumber])
```

**Arguments:**
- `tabNumber` (number) — Optional tab to open. 1 = Friends, 2 = Who, 3 = Guild (Roster), 4 = Chat (Raid).

---

### `ToggleGameMenu()`
Detailed Reference: [API ToggleGameMenu](https://warcraft.wiki.gg/wiki/API_ToggleGameMenu)

Opens or closes the **Game Menu** (the Escape/system menu).

**Syntax:**
```lua
ToggleGameMenu()
```

---

### `ToggleGuildFrame()`
Source: [ToggleGuildFrame (FrameXML)](https://www.townlong-yak.com/framexml/go/ToggleGuildFrame)

Toggles the **Guild & Communities** frame.

**Syntax:**
```lua
ToggleGuildFrame()
```

---

### `ToggleHelpFrame()`
Source: [ToggleHelpFrame (FrameXML)](https://www.townlong-yak.com/framexml/go/ToggleHelpFrame)

Opens the **Help Request** (Customer Support / GM Ticket) frame.

**Syntax:**
```lua
ToggleHelpFrame()
```

---

### `ToggleMinimap()`
Detailed Reference: [API ToggleMinimap](https://warcraft.wiki.gg/wiki/API_ToggleMinimap)

Turns the minimap display on or off.

**Syntax:**
```lua
ToggleMinimap()
```

---

### `TogglePVPUI()`
Detailed Reference: [API TogglePVPUI](https://warcraft.wiki.gg/wiki/API_TogglePVPUI)

Opens or closes the **PvP** frame (Honor / Conquest).

**Syntax:**
```lua
TogglePVPUI()
```

---

### `ToggleSpellBook(bookType)`
Detailed Reference: [API ToggleSpellBook](https://warcraft.wiki.gg/wiki/API_ToggleSpellBook)

Shows the **Spellbook**. Can show your spells or your pet's spells.

**Syntax:**
```lua
ToggleSpellBook(bookType)
```

**Arguments:**
- `bookType` (string) — `"spell"` for the player's spellbook, `"pet"` for the pet's spellbook.

---

### `ToggleTalentFrame()`
Detailed Reference: [API ToggleTalentFrame](https://warcraft.wiki.gg/wiki/API_ToggleTalentFrame)

Opens the **Talent** frame (specialization and talent tree).

**Syntax:**
```lua
ToggleTalentFrame()
```

---

## Number Formatting

### `AbbreviateLargeNumbers(value)`
Source: [AbbreviateLargeNumbers (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=AbbreviateLargeNumbers)

Returns an abbreviated string representation of a large number (e.g., 1500 → "1.5K", 1500000 → "1.5M").

**Syntax:**
```lua
text = AbbreviateLargeNumbers(value)
```

**Arguments:**
- `value` (number) — The number to abbreviate.

**Returns:**
- `text` (string) — Abbreviated string.

---

### `AbbreviateNumbers(value)`
Source: [AbbreviateNumbers (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=AbbreviateNumbers)

Similar to `AbbreviateLargeNumbers` but with slightly different formatting behavior for smaller numbers.

**Syntax:**
```lua
text = AbbreviateNumbers(value)
```

---

## Window Management

### `CloseSpecialWindows()`
Detailed Reference: [API CloseSpecialWindows](https://warcraft.wiki.gg/wiki/API_CloseSpecialWindows)

Closes all standard "special" windows currently open (e.g., Character Info, Spellbook, Bags, Quest Log). Called when pressing Escape or when opening a full-screen interface element.

**Syntax:**
```lua
found = CloseSpecialWindows()
```

**Returns:**
- `found` (boolean) — Returns `true` if any window was closed, `nil` otherwise.

---

### `MouseIsOver(region, topOffset, bottomOffset, leftOffset, rightOffset)`
Detailed Reference: [API MouseIsOver](https://warcraft.wiki.gg/wiki/API_MouseIsOver)

Checks whether the mouse cursor is currently over a frame (or within specified offsets from the frame's edges).

**Syntax:**
```lua
isOver = MouseIsOver(region [, topOffset, bottomOffset, leftOffset, rightOffset])
```

**Arguments:**
- `region` (Region) — The frame/region to check.
- `topOffset` (number) — Optional pixel offset from the top edge.
- `bottomOffset` (number) — Optional pixel offset from the bottom edge.
- `leftOffset` (number) — Optional pixel offset from the left edge.
- `rightOffset` (number) — Optional pixel offset from the right edge.

**Returns:**
- `isOver` (boolean) — True if the mouse is over the region (within offsets).
