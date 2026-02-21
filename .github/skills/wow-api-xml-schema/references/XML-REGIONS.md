# XML Regions — Texture, MaskTexture, Line, FontString, and Shared Elements

This reference covers the visual region elements that are placed inside `<Layer>` tags within a `<Frame>`: `<Texture>`, `<MaskTexture>`, `<Line>`, and `<FontString>`. It also covers shared child elements used across multiple widget types: `<Color>`, `<Gradient>`, `<TexCoords>`, `<Shadow>`, `<Dimension>`, and `<Inset>`.

> **Source:** [XML schema — Texture, FontString](https://warcraft.wiki.gg/wiki/XML_schema)
> **Current as of:** Patch 12.0.0 (Retail only)

---

## `<Texture>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/Texture
> **Inherits from:** `<LayoutFrame>`
> **Creates:** [Texture](https://warcraft.wiki.gg/wiki/UIOBJECT_Texture) widget

Draws an image, solid color, or gradient. Placed inside a `<Layer>` element within `<Layers>`.

### Structure

```xml
<Texture file="" atlas="" alphaMode="" desaturated="" useAtlasSize="">
    <TexCoords />
    <Color />
    <Gradient />
</Texture>
```

### Attributes

| Attribute | Type | Default | Description | Related API |
|-----------|------|---------|-------------|-------------|
| `file` | `xs:string` | — | Path to a BLP, JPEG, or TGA image file. Relative to the game's data directory. | `Texture:SetTexture()` |
| `atlas` | `xs:string` | — | Name of a predefined texture atlas. Loads the atlas file and sets the appropriate texture coordinates automatically. | `Texture:SetAtlas()` |
| `useAtlasSize` | `xs:boolean` | — | If `true`, sizes the texture to match the atlas region's pixel dimensions. | `Texture:SetAtlas()` (second param) |
| `mask` | `xs:string` | — | Path to a mask texture file. White areas of the mask are visible, black areas are transparent. | — |
| `alphaMode` | `ui:ALPHAMODE` | — | Blending mode for overlapping textures. Values: `"DISABLE"`, `"BLEND"`, `"ALPHAKEY"`, `"ADD"`, `"MOD"`. | `Texture:SetBlendMode()` |
| `alpha` | `xs:float` | `1.0` | Opacity from 0.0 (invisible) to 1.0 (fully opaque). | `Region:SetAlpha()` |
| `scale` | `xs:float` | `1.0` | Scale factor for the widget's coordinate system. | `Region:SetScale()` |
| `desaturated` | `xs:boolean` | — | If `true`, removes color (displays in grayscale). | `Texture:SetDesaturated()` |
| `snapToPixelGrid` | `xs:boolean` | — | Snaps the texture position to whole pixel boundaries. | — |
| `texelSnappingBias` | `xs:float` | — | Bias for texel snapping. | — |
| `hWrapMode` | `ui:WRAPMODE` | — | Horizontal texture wrapping: `"CLAMP"`, `"REPEAT"`, `"CLAMPTOBLACK"`, `"CLAMPTOBLACKADDITIVE"`, `"CLAMPTOWHITE"`, `"MIRROR"`. | — |
| `vWrapMode` | `ui:WRAPMODE` | — | Vertical texture wrapping. Same values as `hWrapMode`. | — |
| `ignoreParentAlpha` | `xs:boolean` | — | If `true`, this texture's alpha is independent of its parent frame's alpha. | `Region:SetIgnoreParentAlpha()` |
| `ignoreParentScale` | `xs:boolean` | — | If `true`, this texture's scale is independent of its parent frame's scale. | `Region:SetIgnoreParentScale()` |
| `nonBlocking` | `xs:boolean` | — | If `true`, texture loading does not block the UI thread. | — |
| `horizTile` | `xs:boolean` | — | If `true`, tiles the texture horizontally. | `Texture:SetHorizTile()` |
| `vertTile` | `xs:boolean` | — | If `true`, tiles the texture vertically. | `Texture:SetVertTile()` |

*(Plus all attributes inherited from `<LayoutFrame>`: `name`, `parentKey`, `parentArray`, `inherits`, `virtual`, `mixin`, `secureMixin`, `setAllPoints`, `hidden`)*

### Child Elements

#### `<TexCoords>` — Texture Coordinate Sampling

> **Reference:** https://warcraft.wiki.gg/wiki/XML/TexCoords

Samples a rectangular region from the full image file. Uses normalized coordinates (0.0 to 1.0).

**Simple rectangle form (four edges):**

```xml
<TexCoords left="0" right="0.5" top="0" bottom="0.5"/>
```

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `left` | `xs:float` | `0.0` | Left edge, normalized from left (0) to right (1). |
| `right` | `xs:float` | `1.0` | Right edge, normalized from left (0) to right (1). |
| `top` | `xs:float` | `0.0` | Top edge, normalized from top (0) to bottom (1). |
| `bottom` | `xs:float` | `1.0` | Bottom edge, normalized from top (0) to bottom (1). |

**Arbitrary quadrilateral form (`<Rect>` child element):**

For affine transformations (non-right-angled corners), use the eight-attribute `<Rect>` form:

```xml
<TexCoords>
    <Rect ULx="0" ULy="0" LLx="0" LLy="1" URx="1" URy="0" LRx="1" LRy="1"/>
</TexCoords>
```

| Attribute | Type | Description |
|-----------|------|-------------|
| `ULx` | `xs:float` | Upper-left corner, x coordinate (0 = left, 1 = right). |
| `ULy` | `xs:float` | Upper-left corner, y coordinate (0 = top, 1 = bottom). |
| `LLx` | `xs:float` | Lower-left corner, x coordinate. |
| `LLy` | `xs:float` | Lower-left corner, y coordinate. |
| `URx` | `xs:float` | Upper-right corner, x coordinate. |
| `URy` | `xs:float` | Upper-right corner, y coordinate. |
| `LRx` | `xs:float` | Lower-right corner, x coordinate. |
| `LRy` | `xs:float` | Lower-right corner, y coordinate. |

#### `<Color>` — Solid Color

See the [shared `<Color>` element](#color--solid-color-fill) section below.

#### `<Gradient>` — Color Gradient

See the [shared `<Gradient>` element](#gradient--two-color-gradient) section below.

---

## `<MaskTexture>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/MaskTexture
> **Inherits from:** `<Texture>`
> **Creates:** [MaskTexture](https://warcraft.wiki.gg/wiki/UIOBJECT_MaskTexture) widget

Applies a mask to one or more other textures. White areas of the mask are visible; black areas are clipped.

### Structure

```xml
<MaskTexture file="Interface\Common\circle-mask">
    <MaskedTextures>
        <MaskedTexture childKey="Portrait"/>
    </MaskedTextures>
</MaskTexture>
```

### Child Elements

#### `<MaskedTextures>`

Encloses one or more `<MaskedTexture>` tags identifying which textures this mask applies to.

**`<MaskedTexture>` attributes:**

| Attribute | Type | Description |
|-----------|------|-------------|
| `childKey` | `xs:string` | The `parentKey` of another `<Texture>` in the same `<Frame>` that this mask applies to. |
| `target` | `xs:string` | Alternative target identifier. |

### Example

```xml
<Frame parent="UIParent">
    <Size x="64" y="64"/>
    <Anchors>
        <Anchor point="CENTER"/>
    </Anchors>
    <Layers>
        <Layer level="ARTWORK">
            <Texture parentKey="Portrait" file="Interface\Icons\INV_Misc_QuestionMark" setAllPoints="true"/>
            <MaskTexture file="Interface\Common\common-round-mask" setAllPoints="true">
                <MaskedTextures>
                    <MaskedTexture childKey="Portrait"/>
                </MaskedTextures>
            </MaskTexture>
        </Layer>
    </Layers>
</Frame>
```

---

## `<Line>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/Line
> **Inherits from:** (child of `<Layer>`)
> **Creates:** [Line](https://warcraft.wiki.gg/wiki/UIOBJECT_Line) widget

Draws a line between two anchor points inside a `<Layer>`.

### Structure

```xml
<Line thickness="2">
    <StartAnchor point="TOPLEFT" relativeKey="$parent.Icon" relativePoint="RIGHT" x="5"/>
    <EndAnchor point="BOTTOMRIGHT" relativeKey="$parent.Text" relativePoint="LEFT" x="-5"/>
</Line>
```

### Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `thickness` | `xs:float` | `4.0` | Thickness of the line in pixels. |

### Child Elements

| Element | Description |
|---------|-------------|
| `<StartAnchor>` | Starting point of the line. Inherits `<Anchor>` attributes (`point`, `relativeTo`, `relativeKey`, `relativePoint`, `x`, `y`). |
| `<EndAnchor>` | Ending point of the line. Inherits `<Anchor>` attributes. |

---

## `<FontString>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/FontString
> **Inherits from:** `<LayoutFrame>`
> **Creates:** [FontString](https://warcraft.wiki.gg/wiki/UIOBJECT_FontString) widget

Draws text. Placed inside a `<Layer>` element within `<Layers>`.

### Structure

```xml
<FontString font="" text="" justifyH="CENTER" justifyV="MIDDLE" maxLines="3">
    <FontHeight val="12"/>
    <Color r="1" g="1" b="1"/>
    <Shadow>
        <Offset x="1" y="-1"/>
        <Color r="0" g="0" b="0" a="0.8"/>
    </Shadow>
</FontString>
```

### Attributes

| Attribute | Type | Default | Description | Related API |
|-----------|------|---------|-------------|-------------|
| `font` | `xs:string` | — | Name of a `<Font>` object to inherit properties from. | `FontInstance:SetFontObject()` |
| `text` | `xs:string` | — | The text string to display. Can include escape sequences for colors and hyperlinks. | `FontString:SetText()` |
| `bytes` | `xs:int` | `255` | Maximum number of bytes for the text. | — |
| `spacing` | `xs:float` | — | Line spacing in pixels. | `FontInstance:SetSpacing()` |
| `outline` | `ui:OUTLINETYPE` | — | Text outline style: `"NORMAL"` (thin outline) or `"THICK"` (fat outline). | — |
| `monochrome` | `xs:boolean` | — | If `true`, renders without anti-aliasing (single color per pixel). | — |
| `nonspacewrap` | `xs:boolean` | — | If `true`, allows word-wrapping at non-space characters (e.g., CJK text). | `FontString:SetNonSpaceWrap()` |
| `wordwrap` | `xs:boolean` | — | If `true`, enables word wrapping. | `FontString:SetWordWrap()` |
| `justifyH` | `ui:JUSTIFYHTYPE` | — | Horizontal text alignment: `"LEFT"`, `"CENTER"`, `"RIGHT"`. | `FontInstance:SetJustifyH()` |
| `justifyV` | `ui:JUSTIFYVTYPE` | — | Vertical text alignment: `"TOP"`, `"MIDDLE"`, `"BOTTOM"`. | `FontInstance:SetJustifyV()` |
| `maxLines` | `xs:unsignedInt` | — | Maximum number of lines to display. Text beyond this is truncated. | `FontString:SetMaxLines()` |
| `indented` | `xs:boolean` | — | If `true`, indents the text. | `FontString:SetIndentedWordWrap()` |
| `alpha` | `xs:float` | `1.0` | Opacity of the text. | `Region:SetAlpha()` |
| `ignoreParentAlpha` | `xs:boolean` | — | Controls alpha independently of the parent. | `Region:SetIgnoreParentAlpha()` |
| `ignoreParentScale` | `xs:boolean` | — | Controls scale independently of the parent. | `Region:SetIgnoreParentScale()` |

*(Plus all attributes inherited from `<LayoutFrame>`: `name`, `parentKey`, `parentArray`, `inherits`, `virtual`, `mixin`, `secureMixin`, `setAllPoints`, `hidden`)*

### Child Elements

#### `<FontHeight>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/FontHeight

Sets the font height (size).

| Attribute | Type | Description |
|-----------|------|-------------|
| `val` | `xs:float` | Font height in pixels. The exact on-screen size depends on UI scale. |

#### `<Color>`

Sets the text color. See the [shared `<Color>` element](#color--solid-color-fill) section below.

#### `<Shadow>`

See the [shared `<Shadow>` element](#shadow--text-shadow) section below.

---

## Shared Child Elements

These elements are used as children of multiple widget types throughout the XML schema.

### `<Color>` — Solid Color Fill

> **Reference:** https://warcraft.wiki.gg/wiki/XML/Color

Sets a color using RGB values and optional alpha. Used by `<Texture>`, `<FontString>`, `<Font>`, `<BarColor>`, `<NormalColor>`, `<HighlightColor>`, `<DisabledColor>`, `<FogColor>`, `<Shadow>`, `<Gradient>` children, and others.

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `r` | `xs:float` | `0.0` | Red component, from 0.0 to 1.0. |
| `g` | `xs:float` | `0.0` | Green component, from 0.0 to 1.0. |
| `b` | `xs:float` | `0.0` | Blue component, from 0.0 to 1.0. |
| `a` | `xs:float` | `1.0` | Alpha (opacity), from 0.0 (transparent) to 1.0 (opaque). |
| `name` | `xs:string` | — | Name of a `ColorMixin` created with `CreateColor()`. If provided, uses the named color instead of `r`/`g`/`b`/`a`. |

### Examples

```xml
<!-- Direct RGBA -->
<Color r="1" g="0" b="0" a="0.8"/>

<!-- Named color mixin -->
<Color name="RED_FONT_COLOR"/>

<!-- Solid fill on a texture -->
<Texture setAllPoints="true">
    <Color r="0" g="0" b="0" a="0.5"/>
</Texture>
```

### `<Gradient>` — Two-Color Gradient

> **Reference:** https://warcraft.wiki.gg/wiki/XML/Gradient

Defines a gradient between two solid colors on a `<Texture>`. Contains `<MinColor>` and `<MaxColor>` children, both inheriting from `<Color>`.

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `orientation` | `ui:ORIENTATION` | `HORIZONTAL` | Direction of the gradient: `"HORIZONTAL"` (left to right) or `"VERTICAL"` (top to bottom). |

```xml
<Texture setAllPoints="true">
    <Gradient orientation="HORIZONTAL">
        <MinColor r="0" g="0" b="0" a="1"/>
        <MaxColor r="1" g="1" b="1" a="1"/>
    </Gradient>
</Texture>
```

| Child Element | Description |
|---------------|-------------|
| `<MinColor>` | The starting color of the gradient (left or top). Inherits `<Color>`. |
| `<MaxColor>` | The ending color of the gradient (right or bottom). Inherits `<Color>`. |

### `<Shadow>` — Text Shadow

> **Reference:** https://warcraft.wiki.gg/wiki/XML/Shadow

Places a shadow behind text. Used by `<FontString>` and `<Font>`. Contains a `<Color>` child and an `<Offset>` child.

```xml
<Shadow>
    <Offset x="1" y="-1"/>
    <Color r="0" g="0" b="0" a="1"/>
</Shadow>
```

**`<Shadow>` attributes on the `<Offset>` child:**

| Attribute | Type | Description |
|-----------|------|-------------|
| `x` | `xs:float` | Horizontal offset. Positive = right, negative = left. Scaling dependent. |
| `y` | `xs:float` | Vertical offset. Positive = up, negative = down. Scaling dependent. |

### `<Dimension>` — Width and Height

> **Reference:** https://warcraft.wiki.gg/wiki/XML/Dimension

Used by `<Size>`, `<minResize>`, `<maxResize>`, `<PushedTextOffset>`, `<Offset>`, and similar elements.

| Attribute | Type | Description |
|-----------|------|-------------|
| `x` | `xs:float` | Width or horizontal offset in pixels. |
| `y` | `xs:float` | Height or vertical offset in pixels. |

### `<Inset>` — Edge Padding

> **Reference:** https://warcraft.wiki.gg/wiki/XML/Inset

Used by `<HitRectInsets>`, `<TextInsets>`, and similar elements. Defines offsets from the four edges.

| Attribute | Type | Description |
|-----------|------|-------------|
| `left` | `xs:float` | Left inset. Positive = shrink inward, negative = expand outward. |
| `right` | `xs:float` | Right inset. |
| `top` | `xs:float` | Top inset. |
| `bottom` | `xs:float` | Bottom inset. |
