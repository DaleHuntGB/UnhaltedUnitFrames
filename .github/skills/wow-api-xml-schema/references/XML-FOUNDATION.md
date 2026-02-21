# XML Foundation — Root Elements, LayoutFrame, and Common Child Elements

This reference covers the foundational XML elements used in WoW addon XML files: the root `<Ui>` element, file loading tags, the `<LayoutFrame>` abstract base, and all shared child elements (anchors, sizing, key-values, scripts).

> **Source:** [XML schema — Terminology, XML schema instance, UI, LayoutFrame](https://warcraft.wiki.gg/wiki/XML_schema)
> **XSD file:** https://raw.githubusercontent.com/Gethe/wow-ui-source/live/Interface/AddOns/Blizzard_SharedXML/UI.xsd
> **Current as of:** Patch 12.0.0 (Retail only)

---

## Terminology

> **Reference:** https://warcraft.wiki.gg/wiki/XML_schema#Terminology

- **Tag** — Begins with `<` and ends with `>`; for example `<Frame>`.
- **Attribute** — A name-value pair on a tag; for example `name="ShinyRedApple"` in `<Frame name="ShinyRedApple">`.
- **Element** — Consists of a start tag, end tag, and anything in between; for example `<Frame>content</Frame>`.
- **Self-closing tag** — An element with no content; for example `<Size x="64" y="64"/>`.

---

## `<Ui>` — Root Element

> **Reference:** https://warcraft.wiki.gg/wiki/XML/Ui

Every WoW XML file must have a single `<Ui>` element as the root. It encloses all other tags. The `xmlns` and related attributes are optional but essential for XML parsers and schema validation/autocompletion.

### XML Namespace Setup

```xml
<Ui xmlns="http://www.blizzard.com/wow/ui/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.blizzard.com/wow/ui/
                        https://raw.githubusercontent.com/Gethe/wow-ui-source/live/Interface/AddOns/Blizzard_SharedXML/UI.xsd">
    <!-- All widget definitions go here -->
</Ui>
```

**Namespace attributes explained:**

| Attribute | Purpose |
|-----------|---------|
| `xmlns="http://www.blizzard.com/wow/ui/"` | Declares the default namespace, associating the XML file with World of Warcraft. All nested elements are namespaced to this URI. |
| `xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"` | Declares the XML Schema Instance namespace and binds it to the `xsi` prefix. |
| `xsi:schemaLocation="..."` | Whitespace-separated pairs of namespace URI and XSD file URL. The XSD provides validation and editor hinting. |

### Allowed Child Elements

`<Ui>` can contain:
- `<Include />` — Loads another file
- `<Script />` — Executes Lua code
- Any widget element (`<Frame>`, `<Button>`, `<Texture>`, `<Font>`, etc.)

---

## `<Include>` — Load a File

> **Reference:** https://warcraft.wiki.gg/wiki/XML/Include

Loads another `.lua` or `.xml` file from within an XML file. The path is relative to the addon's root directory.

```xml
<Include file="MyModule.xml" />
<Include file="Locales\enUS.lua" />
```

### Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `file` | `xs:string` | Relative path to a `.lua` or `.xml` file to load. |

**Notes:**
- Included files are loaded in the order they appear, just like entries in the `.toc` file.
- XML `<Include>` can load both `.xml` and `.lua` files.
- Paths should use backslashes (`\`) for compatibility within XML `<Include>` tags.

---

## `<Script>` — Execute Lua Code

> **Reference:** https://warcraft.wiki.gg/wiki/XML/Script

Executes Lua code, either inline between the tags or from an external file.

### From a File

```xml
<Script file="Core.lua" />
```

### Inline

```xml
<Script>
    print("Hello from XML!")
</Script>
```

### Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `file` | `xs:string` | No | Relative path to a `.lua` file. If provided, the file's content is executed instead of any inline code. |

---

## `<LayoutFrame>` — Abstract Base Element

> **Reference:** https://warcraft.wiki.gg/wiki/XML/LayoutFrame

`<LayoutFrame>` is the abstract base that provides common tags and attributes shared by most visible widgets (`<Frame>`, `<Texture>`, `<FontString>`, etc.). You never use `<LayoutFrame>` directly — it defines the inherited interface.

### Attributes

| Attribute | Type | Default | Description | Related API |
|-----------|------|---------|-------------|-------------|
| `name` | `xs:string` | — | Adds a reference to `_G`. Supports `$parent` substitution (replaced with the parent frame's name at creation time). | — |
| `parentKey` | `xs:string` | — | Adds a reference to the widget's parent table. E.g., `parentKey="MyTexture"` makes `parentFrame.MyTexture` point to this widget. | `Object:SetParentKey()` |
| `parentArray` | `xs:string` | — | Inserts a reference into an array on the widget's parent. E.g., `parentArray="Buttons"` does `tinsert(parentFrame.Buttons, self)`. | `tinsert()` |
| `inherits` | `xs:string` | — | Comma-separated list of XML virtual template names to inherit from. Copies layout, children, scripts, and attributes from the template(s). | — |
| `virtual` | `xs:boolean` | `false` | If `true`, creates an XML virtual template instead of an actual widget. Requires `name`. Other elements can then `inherits` this template. | — |
| `mixin` | `xs:string` | — | Comma-separated list of Lua mixin table names. Copies functions from the mixin tables onto the widget at creation time. | `Mixin()` |
| `secureMixin` | `xs:string` | — | Like `mixin`, but wraps inherited functions to force secure execution. Used for protected frames. | — |
| `setAllPoints` | `xs:boolean` | `false` | If `true`, sets the top-left and bottom-right anchors to match the parent widget, effectively making this widget fill its parent. | `ScriptRegionResizing:SetAllPoints()` |
| `hidden` | `xs:boolean` | `false` | Controls the frame's initial visibility. If `true`, the widget starts hidden. | `Frame:Hide()` / `Frame:Show()` |

### Child Elements

#### `<Anchors>` — Positioning

> **Reference:** https://warcraft.wiki.gg/wiki/XML/Anchor

Encloses one or more `<Anchor>` tags that define how this widget is positioned relative to another widget (or its parent).

```xml
<Anchors>
    <Anchor point="CENTER"/>
    <Anchor point="TOPLEFT" relativeTo="MyOtherFrame" relativePoint="BOTTOMLEFT" x="0" y="-5"/>
</Anchors>
```

**`<Anchor>` attributes:**

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `point` | `ui:FRAMEPOINT` | — | The point on this widget to anchor. Values: `TOPLEFT`, `TOP`, `TOPRIGHT`, `LEFT`, `CENTER`, `RIGHT`, `BOTTOMLEFT`, `BOTTOM`, `BOTTOMRIGHT`. |
| `relativeTo` | `xs:string` | parent | Name of another widget (in `_G`) to anchor against. |
| `relativeKey` | `xs:string` | — | Another widget to anchor against, accessed as a sibling key (e.g., a `parentKey` on a sibling widget). |
| `relativePoint` | `ui:FRAMEPOINT` | same as `point` | The point on the other widget to align against. Defaults to the same value as `point`. |
| `x` | `xs:float` | `0` | Horizontal offset in pixels. Positive = right, negative = left. |
| `y` | `xs:float` | `0` | Vertical offset in pixels. Positive = up, negative = down. |

#### `<Size>` — Dimensions

> **Reference:** https://warcraft.wiki.gg/wiki/XML/Dimension

Sets the width and height of the widget. Inherits from `<Dimension>`.

```xml
<Size x="200" y="100"/>
```

**`<Dimension>` attributes (used by `<Size>` and other dimension elements):**

| Attribute | Type | Description |
|-----------|------|-------------|
| `x` | `xs:float` | Width in pixels. |
| `y` | `xs:float` | Height in pixels. |

The `<Dimension>` type is also used by `<minResize>`, `<maxResize>`, `<PushedTextOffset>`, and `<Offset>`.

#### `<KeyValues>` — Custom Properties

> **Reference:** https://warcraft.wiki.gg/wiki/XML/KeyValues

Encloses one or more `<KeyValue>` tags that assign custom key/value pairs to the widget's Lua table at creation time.

```xml
<KeyValues>
    <KeyValue key="myFlag" value="true" type="boolean"/>
    <KeyValue key="maxItems" value="10" type="number"/>
    <KeyValue key="label" value="Hello World"/>
</KeyValues>
```

**`<KeyValue>` attributes:**

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `key` | `xs:string` | — | Key name in the widget's Lua table. |
| `value` | `xs:string` | — | Value to assign. |
| `keyType` | `ui:KEYVALUETYPE` | `string` | Type of the key: `nil`, `boolean`, `number`, `string` (default), or `global`. |
| `type` | `ui:KEYVALUETYPE` | `string` | Type of the value: `nil`, `boolean`, `number`, `string` (default), or `global`. When `global`, the value is looked up in `_G`. |

#### `<Animations>` — Animation Groups

Encloses one or more `<AnimationGroup>` tags. See [XML-ANIMATIONS.md](XML-ANIMATIONS.md) for full details.

```xml
<Animations>
    <AnimationGroup parentKey="FadeIn">
        <Alpha fromAlpha="0" toAlpha="1" duration="0.3"/>
    </AnimationGroup>
</Animations>
```

---

## `<Inset>` — Padding/Overflow

> **Reference:** https://warcraft.wiki.gg/wiki/XML/Inset

Used by `<HitRectInsets>`, `<TextInsets>`, and other elements. Defines offsets from edges.

| Attribute | Type | Description |
|-----------|------|-------------|
| `left` | `xs:float` | Left inset. Positive = inward (shrinks), negative = outward (expands). |
| `right` | `xs:float` | Right inset. |
| `top` | `xs:float` | Top inset. |
| `bottom` | `xs:float` | Bottom inset. |

---

## `<ResizeBounds>` — Resize Limits

> **Reference:** https://warcraft.wiki.gg/wiki/XML/ResizeBounds

Limits the minimum and maximum size when `resizable="true"` on a `<Frame>`. Contains `<minResize>` and `<maxResize>` child elements that inherit from `<Dimension>`.

```xml
<ResizeBounds>
    <minResize x="100" y="50"/>
    <maxResize x="800" y="600"/>
</ResizeBounds>
```

---

## Widget Hierarchy Overview

> **Reference:** https://warcraft.wiki.gg/wiki/XML_schema#Widget_hierarchy

| Category | Elements |
|----------|----------|
| **Core tags** | `<Ui>`, `<LayoutFrame>`, `<Frame>`, `<Texture>`, `<MaskTexture>`, `<Line>`, `<FontString>`, `<Font>`, `<FontFamily>`, `<Animation>`, `<AnimationGroup>` |
| **`<Frame>` subtypes** | `<Button>`, `<CheckButton>`, `<ItemButton>`, `<ColorSelect>`, `<Cooldown>`, `<EditBox>`, `<GameTooltip>`, `<MessageFrame>`, `<ScrollFrame>`, `<ScrollingMessageFrame>`, `<SimpleHTML>`, `<Slider>`, `<StatusBar>`, `<Model>`, `<PlayerModel>`, `<CinematicModel>`, `<DressUpModel>`, `<TabardModel>`, `<UiCamera>`, `<ModelScene>`, `<MovieFrame>`, `<ArchaeologyDigSiteFrame>`, `<QuestPOIFrame>`, `<ScenarioPOIFrame>`, and others |
| **`<Animation>` subtypes** | `<Alpha>`, `<Scale>`, `<LineScale>`, `<Translation>`, `<LineTranslation>`, `<Path>`, `<Rotation>`, `<TextureCoordTranslation>` |

### Inheritance

- `<Texture>`, `<FontString>`, `<Line>`, `<MaskTexture>` all inherit from `<LayoutFrame>` (they get name, anchors, size, key-values, animations).
- `<Frame>` inherits from `<LayoutFrame>` and adds event handling, layers, child frames, and scripts.
- All `<Frame>` subtypes (`<Button>`, `<EditBox>`, `<Slider>`, etc.) inherit from `<Frame>`.
- `<Animation>` subtypes (`<Alpha>`, `<Scale>`, etc.) inherit from `<Animation>`.
- `<Font>` and `<FontFamily>` are standalone (not `<LayoutFrame>` subtypes) but share some attribute names.

---

## Common Patterns

### Virtual Templates (Reusable Layouts)

Define a template with `virtual="true"`, then reuse it with `inherits`:

```xml
<!-- Define a template -->
<Frame name="MyButtonTemplate" virtual="true">
    <Size x="100" y="30"/>
    <Layers>
        <Layer level="ARTWORK">
            <FontString parentKey="Text" inherits="GameFontNormal"/>
        </Layer>
    </Layers>
</Frame>

<!-- Use the template -->
<Frame name="MyButton1" inherits="MyButtonTemplate" parent="UIParent">
    <Anchors>
        <Anchor point="CENTER" x="0" y="50"/>
    </Anchors>
</Frame>
```

### `$parent` Name Substitution

When a child widget uses `$parent` in its `name`, WoW replaces it with the parent frame's name:

```xml
<Frame name="MyAddon_MainFrame">
    <Layers>
        <Layer level="ARTWORK">
            <!-- Creates global name "MyAddon_MainFrame_Title" -->
            <FontString name="$parent_Title" inherits="GameFontNormal" text="My Addon"/>
        </Layer>
    </Layers>
</Frame>
```

### `parentKey` vs `name`

- `name` creates a global variable in `_G` — use sparingly to avoid namespace pollution.
- `parentKey` creates a reference on the parent frame's table — preferred for child widgets.

```xml
<Frame name="MyAddon_Frame" parent="UIParent">
    <Layers>
        <Layer level="ARTWORK">
            <!-- Accessible as MyAddon_Frame.Icon (no global) -->
            <Texture parentKey="Icon" file="Interface\Icons\INV_Misc_QuestionMark">
                <Size x="32" y="32"/>
            </Texture>
        </Layer>
    </Layers>
</Frame>
```

### Intrinsic Frames

Setting `intrinsic="true"` on a `<Frame>` creates a reusable frame type (similar to `virtual`, but the template acts as a frame factory you can instantiate with `CreateFrame`):

```xml
<Frame name="MyCustomFrame" intrinsic="true">
    <Size x="200" y="50"/>
    <Scripts>
        <OnLoad method="OnLoad"/>
    </Scripts>
</Frame>
```

```lua
-- In Lua, create instances of the intrinsic frame:
local frame = CreateFrame("MyCustomFrame", nil, UIParent)
```
