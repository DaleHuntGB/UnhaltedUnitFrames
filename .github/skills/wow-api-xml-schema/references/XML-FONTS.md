# XML Fonts — `<Font>`, `<FontFamily>`, and Related Elements

This reference covers the `<Font>` and `<FontFamily>` XML elements used to define reusable font objects in WoW addon XML files. Fonts defined in XML can be referenced by `<FontString>`, `<EditBox>`, `<MessageFrame>`, and other text-displaying widgets.

> **Source:** [XML schema — Font, FontFamily](https://warcraft.wiki.gg/wiki/XML_schema#Font)
> **Current as of:** Patch 12.0.0 (Retail only)

---

## `<Font>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/Font
> **Creates:** [Font](https://warcraft.wiki.gg/wiki/UIOBJECT_Font) object

Defines a reusable font object that specifies typeface, size, color, shadow, and text styling. Font objects are referenced by name from `<FontString>`, `<EditBox>`, `<MessageFrame>`, and other elements via their `font` attribute.

**Note:** `<Font>` is **not** a `<LayoutFrame>` subtype — it doesn't have anchors, size, or visibility. However, it shares some attribute names (`name`, `inherits`, `virtual`) that behave similarly to `<LayoutFrame>`.

### Structure

```xml
<Font name="MyAddon_Font" font="Fonts\\FRIZQT__.TTF" outline="NORMAL">
    <FontHeight val="12"/>
    <Color r="1" g="0.82" b="0"/>
    <Shadow>
        <Offset x="1" y="-1"/>
        <Color r="0" g="0" b="0" a="1"/>
    </Shadow>
</Font>
```

### Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `name` | `xs:string` | — | Global name of the font object (added to `_G`). Normally required — other widgets reference fonts by this name. May be omitted when the `<Font>` is inside a `<FontFamily>` `<Member>`. |
| `inherits` | `xs:string` | — | Comma-separated list of font object names to inherit properties from. Similar to `<LayoutFrame>`. |
| `virtual` | `xs:boolean` | — | If `true`, creates a virtual font template. Similar to `<LayoutFrame>`. |
| `font` | `xs:string` | — | Path to the font file (`.TTF` or `.OTF`), relative to the game's data directory. E.g., `"Fonts\\FRIZQT__.TTF"`. |
| `spacing` | `xs:float` | — | Line spacing in pixels. |
| `outline` | `ui:OUTLINETYPE` | `NONE` | Text outline: `"NONE"` (default), `"NORMAL"` (thin), `"THICK"` (fat). |
| `monochrome` | `xs:boolean` | — | If `true`, renders without anti-aliasing. |
| `justifyH` | `ui:JUSTIFYHTYPE` | `CENTER` | Horizontal alignment: `"LEFT"`, `"CENTER"` (default), `"RIGHT"`. |
| `justifyV` | `ui:JUSTIFYVTYPE` | `MIDDLE` | Vertical alignment: `"TOP"`, `"MIDDLE"` (default), `"BOTTOM"`. |
| `height` | `xs:float` | — | Font height in pixels. Alternative to using a `<FontHeight>` child element. |
| `fixedSize` | `xs:boolean` | — | If `true`, prevents scaling with UI scale changes. |
| `filter` | `xs:boolean` | — | Texture filtering. |

### Child Elements

#### `<FontHeight>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/FontHeight

Sets the font height (size in pixels).

| Attribute | Type | Description |
|-----------|------|-------------|
| `val` | `xs:float` | Font height. The exact on-screen size depends on UI scale. |

#### `<Color>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/Color

Sets the default text color for this font.

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `r` | `xs:float` | `0.0` | Red component (0.0 to 1.0). |
| `g` | `xs:float` | `0.0` | Green component (0.0 to 1.0). |
| `b` | `xs:float` | `0.0` | Blue component (0.0 to 1.0). |
| `a` | `xs:float` | `1.0` | Alpha / opacity (0.0 to 1.0). |
| `name` | `xs:string` | — | Name of a `ColorMixin` made with `CreateColor()`. |

#### `<Shadow>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/Shadow

Places a drop shadow behind text rendered with this font.

```xml
<Shadow>
    <Offset x="1" y="-1"/>
    <Color r="0" g="0" b="0" a="1"/>
</Shadow>
```

| Child Element | Description |
|---------------|-------------|
| `<Offset>` | Shadow offset. `x` = horizontal (positive = right), `y` = vertical (positive = up). Both are scaling dependent. Inherits `<Dimension>`. |
| `<Color>` | Shadow color. Inherits `<Color>`. |

### Common Font Paths

These are standard font files shipped with the WoW client:

| Font File | Typical Use |
|-----------|------------|
| `Fonts\\FRIZQT__.TTF` | Default UI font (Friz Quadrata) |
| `Fonts\\ARIALN.TTF` | Small/condensed text (Arial Narrow) |
| `Fonts\\MORPHEUS.TTF` | Decorative/quest text (Morpheus) |
| `Fonts\\SKURRI.TTF` | Damage numbers, combat text (Skurri) |

### Example: Complete Font Definition

```xml
<Ui xmlns="http://www.blizzard.com/wow/ui/">
    <!-- Define a custom font -->
    <Font name="MyAddon_TitleFont" font="Fonts\\FRIZQT__.TTF" outline="NORMAL">
        <FontHeight val="16"/>
        <Color r="1" g="0.82" b="0"/>
        <Shadow>
            <Offset x="1" y="-1"/>
            <Color r="0" g="0" b="0" a="0.8"/>
        </Shadow>
    </Font>

    <!-- Use the font in a frame -->
    <Frame parent="UIParent">
        <Size x="200" y="30"/>
        <Anchors>
            <Anchor point="CENTER"/>
        </Anchors>
        <Layers>
            <Layer level="ARTWORK">
                <FontString font="MyAddon_TitleFont" text="Custom Font!"/>
            </Layer>
        </Layers>
    </Frame>
</Ui>
```

---

## `<FontFamily>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/FontFamily
> **Creates:** [Font](https://warcraft.wiki.gg/wiki/UIOBJECT_Font) object

Defines a font family with different `<Font>` definitions per alphabet (character set / locale). The game chooses the appropriate `<Member>` at load time based on the client's locale.

### Structure

```xml
<FontFamily name="MyAddon_LocalizedFont" virtual="true">
    <Member alphabet="roman">
        <Font font="Fonts\\FRIZQT__.TTF">
            <FontHeight val="12"/>
        </Font>
    </Member>
    <Member alphabet="korean">
        <Font font="Fonts\\2002.TTF">
            <FontHeight val="14"/>
        </Font>
    </Member>
    <Member alphabet="simplifiedchinese">
        <Font font="Fonts\\ARKai_T.TTF">
            <FontHeight val="14"/>
        </Font>
    </Member>
</FontFamily>
```

### Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `name` | `xs:string` | — | Global name of the font family object. Required. |
| `virtual` | `xs:boolean` | — | If `true`, creates a virtual template. Similar to `<LayoutFrame>`. |

### `<Member>` — Locale-Specific Font

Each `<Member>` encloses a single `<Font>` tag. At load time, the game picks the `<Member>` matching the client's active alphabet/locale.

| Attribute | Type | Description |
|-----------|------|-------------|
| `alphabet` | `xs:string` | The character set this member provides a font for. Values: `"roman"`, `"korean"`, `"simplifiedchinese"`, `"traditionalchinese"`, `"russian"`. |

Only one `<Member>` is selected per `<FontFamily>` at runtime. The `<Font>` inside a `<Member>` follows the same structure as a standalone `<Font>` element, but the `name` attribute is optional (the family name is used instead).

---

## Blizzard Built-In Font Objects

WoW ships with many predefined font objects that can be used with `inherits` or referenced by name. Some commonly used ones:

| Font Object Name | Typical Use |
|-----------------|------------|
| `GameFontNormal` | Default UI text |
| `GameFontHighlight` | Highlighted/hovered text |
| `GameFontDisable` | Disabled/grayed text |
| `GameFontNormalSmall` | Small default text |
| `GameFontNormalLarge` | Large default text |
| `GameFontNormalHuge` | Very large header text |
| `GameTooltipText` | Tooltip body text |
| `GameTooltipHeaderText` | Tooltip header text |
| `NumberFontNormal` | Standard numbers |
| `ChatFontNormal` | Chat text |
| `SystemFont_OutlineThick_Huge2` | Combat damage numbers |

> **Full list:** See Blizzard's `SharedXML/SharedFontStyles.xml` in the [wow-ui-source](https://github.com/Gethe/wow-ui-source/tree/live/Interface/SharedXML/SharedFontStyles.xml).
