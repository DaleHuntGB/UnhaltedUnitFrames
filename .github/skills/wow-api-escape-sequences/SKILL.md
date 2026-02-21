---
name: wow-api-escape-sequences
description: "Complete reference for World of Warcraft UI escape sequences — pipe-character sequences embedded in text strings to produce colors, inline textures, atlas icons, grammar inflections, word-wrap hints, Kstrings, and other special rendering. Use when formatting chat output, tooltip text, FontString content, or any UI text that needs color codes, inline icons, named colors, item-quality colors, texture markup, atlas markup, localized grammar forms, or escape-sequence utilities like WrapTextInColorCode, CreateTextureMarkup, CreateSimpleTextureMarkup, and CreateAtlasMarkup."
---

# WoW UI Escape Sequences

This skill documents the **UI escape sequences** available in World of Warcraft addon development. Many UI elements that display text on screen support special sequences starting with the `|` (pipe) character. These sequences enable inline coloring, texture/atlas rendering, grammar inflection, word-wrapping hints, and more — all within ordinary Lua strings.

> **Source of truth:** https://warcraft.wiki.gg/wiki/UI_escape_sequences
> **Current as of:** Patch 12.0.0 (Retail only)
> **Scope:** All `|` escape sequences recognized by the WoW UI text renderer.

## When to Use This Skill

Use this skill when you need to:
- Embed color codes in chat messages, tooltips, or FontStrings
- Use named global colors (`|cn`) or item-quality colors (`|cnIQ`)
- Insert inline textures or atlas icons into text
- Apply localized grammar rules (Korean, French, Russian, plurals, articles)
- Understand word-wrap hints (`|W`) or Kstring obfuscation (`|K`)
- Use helper functions like `WrapTextInColorCode()`, `CreateTextureMarkup()`, `CreateSimpleTextureMarkup()`, or `CreateAtlasMarkup()`

## Relationship to Other Skills

| Skill | Relationship |
|-------|-------------|
| `wow-api-framexml` | Covers utility functions (`WrapTextInColorCode`, `CreateTextureMarkup`, `CreateSimpleTextureMarkup`, `CreateAtlasMarkup`) that generate escape-sequence markup from Lua. |
| `wow-api-widget` | `FontString`, `EditBox`, `SimpleHTML`, `GameTooltip` and other text-displaying widgets render these sequences. |
| `wow-lua-api` | Lua `string.format`, `print()`, and chat functions emit strings that can contain these sequences. |

---

## Important: The Pipe Character

In Lua source code you can use `|` directly:

```lua
print("|cFFFF0000Red text|r normal")
```

In the **chat window** or in-game text editors, the literal `|` is escaped. Use `\124` (the ASCII code for pipe) instead:

```
/run print("\124cFFFF0000Red text\124r normal")
```

---

## Coloring

### ARGB Hex Color

```
|cAARRGGBBtext|r
```

- `AA` — Alpha (currently ignored; always use `FF`).
- `RR` `GG` `BB` — Red, green, blue channels as two hex digits each.
- `|r` — Pops the most recent color, restoring the previous one (since Patch 9.0.1). Previously it reset to the default color entirely.

**Nesting example:**

```lua
print("white |cFFFF0000red |cFF00FF00green|r back to red|r back to white")
```

### Global Named Colors (`|cn`)

```
|cnCOLOR_NAME:text|r
```

Renders `text` using a named [GlobalColor](https://wago.tools/db2/GlobalColor). The color name comes from the `GlobalColor` database table.

```lua
print("|cnPURE_GREEN_COLOR:Green text|r normal")
```

### Item Quality Colors (`|cnIQ`)

```
|cnIQn:text|r
```

Renders `text` using the color for item quality `n`, where `n` is a numeric `Enum.ItemQuality` value (0 = Poor/gray, 1 = Common/white, 2 = Uncommon/green, 3 = Rare/blue, 4 = Epic/purple, 5 = Legendary/orange, …). The color updates to match the user's color-override settings.

```lua
print("|cnIQ4:Epic quality text|r")
```

> Added in Patch 11.1.5. Named colors (`|cn`) added in Patch 10.0.0.

---

## Textures

### Inline Texture

```
|Tpath:height[:width[:offsetX:offsetY[:textureWidth:textureHeight:leftTexel:rightTexel:topTexel:bottomTexel[:rVertexColor:gVertexColor:bVertexColor]]]]|t
```

Inserts an image into a FontString. `path` may be a file path (with `/` or `\\` separators) or a numeric **FileDataID**.

#### Size Rules

| `height` | `width` | Result |
|-----------|---------|--------|
| `0` | omitted | Square icon at text line height (`TextHeight × TextHeight`) |
| `> 0` | omitted | Square icon (`height × height`) |
| `0` | `0` | Square at `TextHeight` |
| `> 0` | `0` | `TextHeight` wide, `height` tall |
| `0` | `> 0` | `width` is treated as an **aspect ratio**: `Width = width × TextHeight`, `Height = TextHeight` |
| `> 0` | `> 0` | Explicit `width × height` |

#### Optional Parameters

| Parameter | Purpose |
|-----------|---------|
| `offsetX`, `offsetY` | Pixel offset from the natural position |
| `textureWidth`, `textureHeight` | Source image dimensions in pixels |
| `leftTexel`, `rightTexel`, `topTexel`, `bottomTexel` | Crop coordinates in pixels (non-normalized `x1 x2 y1 y2`; see `Texture:SetTexCoord`) |
| `rVertexColor`, `gVertexColor`, `bVertexColor` | RGB tint values, each 0–255 |

#### Common Patterns

```lua
-- Square icon at text size (most common for spell/item icons)
"|T133784:0|t"
"|TInterface/Icons/INV_Misc_Coin_01:0|t"

-- Explicit 16×16 icon
"|TInterface/Icons/INV_Misc_Coin_01:16|t"

-- Rectangular image with aspect ratio
"|TInterface/Glues/LoadingBar/Loading-BarFill:0:2|t"

-- Cropped texture (4px border removed from a 64×64 source)
"|TInterface/Icons/INV_Misc_Coin_01:16:16:0:0:64:64:4:60:4:60|t"

-- Tinted texture (green tint: 73,177,73)
"|TInterface/ChatFrame/UI-ChatIcon-ArmoryChat:14:14:0:0:16:16:0:16:0:16:73:177:73|t"
```

### Texture Atlas

```
|A:atlas:height:width[:offsetX:offsetY[:rVertexColor:gVertexColor:bVertexColor]]|a
```

Inserts a texture atlas region. The `atlas` may be a name string or a numeric atlas ID. Note the `:` after `|A`.

```lua
-- Atlas by name
"|A:groupfinder-icon-role-large-tank:19:19|a Tank"

-- Atlas by numeric ID
"|A:4259:19:19|a Tank"
```

> See also: [AtlasID](https://warcraft.wiki.gg/wiki/AtlasID)

---

## Kstrings

```
|Kq1|k
```

Kstrings are opaque string placeholders that prevent addon parsing of confidential or protected text. They are rendered by the client as the actual display string but cannot be read as plaintext by addons.

| Prefix | Usage |
|--------|-------|
| `q` | Battle.net account names (`C_BattleNet.GetFriendAccountInfo`) |
| `r` | Group finder listing names/comments (`C_LFGList.GetSearchResultInfo`, `C_LFGList.GetActiveEntryInfo`) |
| `u` | Communities message content (`C_Club.GetMessageInfo`, `C_Club.GetMessagesInRange`) |
| `v` | Communities channel chat (`CHAT_MSG_COMMUNITIES_CHANNEL` event) |

> Added in Patch 4.0.1.

---

## Grammar / Localization Sequences

These sequences handle language-specific inflection so that a single localization string can produce grammatically correct output.

### `|1` — Korean Postpositions

```
text|1A;B;
```

Selects postposition `A` (after consonant) or `B` (after vowel).

```lua
print("라면|1을;를;")  -- 라면을 (ramyeoneul)
print("나무|1을;를;")  -- 나무를 (namureul)
```

### `|2` — French Prepositions

```
|2 text
```

Outputs `de text` before a consonant, `d'text` before a vowel. Trailing spaces after `|2` are ignored.

```lua
print("|2 fraise") -- de fraise
print("|2 avion")  -- d'avion
```

### `|3` — Russian Noun Declension

```
|3-id(text)
```

Declines a Russian noun into one of 5 cases (id = 1–5).

```lua
print("|3-1(Кролик)") -- Кролика   (Genitive)
print("|3-2(Кролик)") -- Кролику   (Dative)
print("|3-3(Кролик)") -- Кролика   (Accusative)
print("|3-4(Кролик)") -- Кроликом  (Instrumental)
print("|3-5(Кролик)") -- Кролике   (Prepositional)
```

> See also: `DeclineName()` API.

### `|4` — Plural Forms

```
number |4singular:plural;
number |4singular:plural1:plural2;   -- ruRU has three forms
```

Selects singular or plural based on the preceding number.

```lua
print("1 |4car:cars;")      -- 1 car
print("2 |4car:cars;")      -- 2 cars
print("3 blue |4car:cars;") -- 3 blue cars
```

### `|7` — Plural (Large Numbers / Non-English)

Same behavior as `|4` but used specifically with large numbers on certain non-English locales.

```lua
print("1 |7Million:Millionen;") -- 1 Million
print("2 |7Million:Millionen;") -- 2 Millionen
```

### `|5` — Indefinite Article (a / an)

```
|5 text
|5^ text   -- uppercase article
```

Inserts `a` before consonant sounds, `an` before vowel sounds.

```lua
print("|5 banana")  -- a banana
print("|5 apple")   -- an apple
print("|5^ apple")  -- An apple
```

### `|6` — Lowercase

```
|6 TEXT
|6(TEXT MORE)
```

Converts the next word (or parenthesized group) to lowercase.

```lua
print("|6 HELLO WORLD")  -- hello WORLD
print("|6(HELLO WORLD)") -- hello world
```

---

## Word Wrapping

```
|Wtext|w
```

Hints that the enclosed `text` should not be broken across lines. If the text would require wrapping, the client prefers to wrap *before* the `|W` start instead of splitting inside it. If the text is still too wide, the hint may be ignored.

> Added in Patch 5.4.1.

---

## Other Sequences

| Sequence | Effect |
|----------|--------|
| `\|n` | Newline (if the widget supports it). Equivalent to `\n` or `\r`. |
| `\|\|` | Literal pipe character `\|`. |
| Any invalid `\|X` | Displayed as-is (undefined behavior). |

---

## Utility Functions (FrameXML)

These FrameXML helper functions generate escape-sequence markup:

| Function | Output |
|----------|--------|
| `WrapTextInColorCode(text, colorHexString)` | `\|cFFRRGGBBtext\|r` |
| `CreateTextureMarkup(file, fileW, fileH, width, height, left, right, top, bottom)` | `\|T...\|t` with tex coords |
| `CreateSimpleTextureMarkup(file, width, height)` | `\|Tfile:height:width\|t` |
| `CreateAtlasMarkup(atlasName, height, width, offsetX, offsetY)` | `\|A:atlas:height:width:...\|a` |

```lua
-- Color a string red
WrapTextInColorCode("Critical!", "FFFF0000")
-- "|cFFFF0000Critical!|r"

-- Inline 16×16 coin icon
CreateSimpleTextureMarkup("Interface/Icons/INV_Misc_Coin_01", 16, 16)
-- "|TInterface/Icons/INV_Misc_Coin_01:16:16|t"

-- Atlas tank icon
CreateAtlasMarkup("groupfinder-icon-role-large-tank", 16, 16)
-- "|A:groupfinder-icon-role-large-tank:16:16|a"
```

---

## Patch History

| Patch | Change |
|-------|--------|
| 11.1.5 | Added `\|cnIQ` item quality color sequences. |
| 10.0.0 | Added `\|cn` named color sequences. |
| 9.0.1 | `\|r` now pops nested colors in-order instead of resetting to default. |
| 5.4.1 | Added `\|W` word-wrapping hint. |
| 4.0.1 | Added `\|K` Kstrings. |

---

## See Also

- [Hyperlinks](https://warcraft.wiki.gg/wiki/Hyperlinks) — related pipe-delimited link sequences (`|H...|h...|h`).
- `wow-api-framexml` skill — covers `WrapTextInColorCode`, `CreateTextureMarkup`, `CreateSimpleTextureMarkup`, `CreateAtlasMarkup` in detail.
- `wow-api-widget` skill — covers FontString, GameTooltip, and other widgets that render these sequences.
