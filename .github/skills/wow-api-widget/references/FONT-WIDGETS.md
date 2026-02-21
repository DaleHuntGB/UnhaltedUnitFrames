# Font Widget Types (Curated)

Font widgets handle text rendering and measurement. This reference focuses on common methods and patterns. For full lists, see the Widget API page.

> Source: https://warcraft.wiki.gg/wiki/Widget_API
> Current as of: Patch 12.0.0 (Retail)

## FontInstance (mixin)

Core methods for any FontInstance user (FontString, Frame, EditBox, SimpleHTML):

- `SetFont(fontFile, height, flags)`
- `SetFontObject(fontObject)`
- `SetTextColor(r, g, b, a)`
- `SetJustifyH("LEFT" | "CENTER" | "RIGHT")`
- `SetJustifyV("TOP" | "MIDDLE" | "BOTTOM")`
- `SetShadowColor(r, g, b, a)`
- `SetShadowOffset(x, y)`
- `SetSpacing(pixels)`

## Font

Fonts are reusable definitions you can share across FontStrings:

- `CopyFontObject(sourceFont)`
- `SetFontHeight(height)`
- `GetFontHeight()`
- `SetAlpha(alpha)`

## FontString

Most common text operations:

- `SetText(text)` and `SetFormattedText(format, ...)`
- `SetTextToFit(text)`
- `SetWordWrap(trueOrFalse)`
- `SetMaxLines(maxLines)`
- `IsTruncated()`
- `GetStringWidth()` and `GetStringHeight()`

## Examples

### Basic FontString
```lua
local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
label:SetPoint("TOPLEFT", 12, -12)
label:SetText("Options")
label:SetTextColor(1, 0.82, 0)
```

### Truncated Text With Max Lines
```lua
local desc = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
desc:SetPoint("TOPLEFT", 12, -36)
desc:SetWidth(220)
desc:SetWordWrap(true)
desc:SetMaxLines(2)
desc:SetText("This is a long description that should wrap and truncate.")
if desc:IsTruncated() then
    -- optionally show a tooltip with full text
end
```

### Resize To Fit Text
```lua
local value = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
value:SetText("12345")
local w = value:GetStringWidth() + 12
frame:SetWidth(w)
```