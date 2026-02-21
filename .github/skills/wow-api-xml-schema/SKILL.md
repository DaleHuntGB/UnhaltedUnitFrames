---
name: wow-api-xml-schema
description: "Complete reference for the World of Warcraft XML schema — all XML elements, attributes, types, defaults, and inheritance used to define UI frames, textures, fonts, and animations in addon XML files. Covers <Ui>, <LayoutFrame>, <Frame> and all subtypes (Button, EditBox, Slider, StatusBar, Cooldown, etc.), <Texture>, <MaskTexture>, <Line>, <FontString>, <Font>, <FontFamily>, <AnimationGroup>, <Animation> and all subtypes (Alpha, Scale, Translation, Path, Rotation), plus shared elements like <Anchors>, <Layers>, <Scripts>, <KeyValues>, <Color>, <Gradient>, <TexCoords>, and <Shadow>. Use when writing or reading WoW addon XML files, defining frames in XML, setting up XML templates, or understanding XML attribute-to-API mappings."
---

# WoW XML Schema

This skill documents the **XML schema** for World of Warcraft addon development. XML files define User Interface elements declaratively — frames, textures, font strings, fonts, and animations. While most UI functionality is also available in Lua via the Widget API, XML provides a structured way to define layouts, templates, and widget hierarchies.

> **Source of truth:** https://warcraft.wiki.gg/wiki/XML_schema
> **XSD file:** https://raw.githubusercontent.com/Gethe/wow-ui-source/live/Interface/AddOns/Blizzard_SharedXML/UI.xsd
> **Current as of:** Patch 12.0.0 (Retail only)
> **Scope:** All XML elements and attributes used in WoW addon `.xml` files.

## When to Use This Skill

Use this skill when you need to:
- Write or read WoW addon `.xml` UI definition files
- Define frames, textures, font strings, or animations in XML
- Set up XML virtual templates (`virtual="true"`) and inheritance (`inherits=""`)
- Understand which XML attributes map to which Lua API calls
- Configure anchors, layers, scripts, key-values, or resize bounds in XML
- Set up the `<Ui>` root element with proper namespace declarations
- Use `<Include>` and `<Script>` tags to load files from XML
- Define `<Font>` or `<FontFamily>` objects for text styling
- Create animation groups and animations declaratively
- Build intrinsic frames (`intrinsic="true"`)
- Understand XML element inheritance hierarchy (e.g., `Button` inherits from `Frame` inherits from `LayoutFrame`)

## Relationship to Other Skills

| Skill | Relationship |
|-------|-------------|
| `wow-api-widget` | Covers the **Lua-side** Widget API methods called on widgets. This skill covers the **XML-side** declarative definitions. Many XML attributes map directly to Widget API methods. |
| `wow-addon-structure` | Covers `.toc` file format and addon loading. XML files are listed in `.toc` and loaded in order. |
| `wow-api-framexml` | Covers FrameXML helper functions and mixins. XML `mixin` and `secureMixin` attributes reference Lua mixins documented there. |
| `wow-lua-api` | Covers the Lua 5.1 environment. `<Script>` tags execute Lua code within that environment. |

## Widget Hierarchy (XML Elements)

```
<Ui>                          -- Root element; encloses all other tags
├── <Include />               -- Loads another .xml or .lua file
├── <Script />                -- Executes inline or file-based Lua code
├── <Font />                  -- Defines a reusable font object
├── <FontFamily />            -- Defines fonts per alphabet/locale
│
├── <LayoutFrame>             -- Abstract base: name, anchors, size, keyvalues, animations
│   ├── <Texture />           -- Draws an image, solid color, or gradient
│   │   ├── <MaskTexture />   -- Applies a mask to other textures
│   │   └── <Line />          -- Draws a line between two anchors
│   ├── <FontString />        -- Draws text
│   └── <Frame>               -- Handles events, user interaction, contains child widgets
│       ├── <Button>          -- Responds to clicks
│       │   ├── <CheckButton> -- Adds checked/unchecked state
│       │   └── <ItemButton>  -- Intrinsic frame extending Button
│       ├── <ColorSelect>     -- Color wheel + value picker
│       ├── <Cooldown>        -- Rotating edge / swipe overlay
│       ├── <EditBox>         -- Text input field
│       ├── <GameTooltip>     -- Tooltip formatting
│       ├── <MessageFrame>    -- Scrolling message display
│       ├── <Model>           -- 3D model rendering
│       │   ├── <PlayerModel>
│       │   │   ├── <DressUpModel>
│       │   │   └── <TabardModel>
│       │   ├── <CinematicModel>
│       │   └── <UiCamera>
│       ├── <ModelScene>      -- Scene-based 3D rendering
│       ├── <ScrollFrame>     -- Scrollable container
│       ├── <ScrollingMessageFrame> -- Intrinsic scrolling messages
│       ├── <SimpleHTML>      -- Renders HTML content
│       ├── <Slider>          -- Value selector within a range
│       ├── <StatusBar>       -- Fill bar (health, progress, etc.)
│       ├── <MovieFrame>      -- Video playback
│       ├── <ArchaeologyDigSiteFrame>
│       ├── <QuestPOIFrame>
│       └── <ScenarioPOIFrame>
│
└── <AnimationGroup>          -- Contains animations
    └── <Animation>           -- Abstract base for animations
        ├── <Alpha>           -- Fades opacity
        ├── <Scale>           -- Resizes
        │   └── <LineScale>
        ├── <Translation>     -- Moves position
        │   └── <LineTranslation>
        ├── <Path>            -- Moves through control points
        ├── <Rotation>        -- Rotates around an origin
        └── <TextureCoordTranslation> -- Shifts texture coordinates
```

## Reference Files

| Reference | Contents |
|-----------|----------|
| [XML-FOUNDATION.md](references/XML-FOUNDATION.md) | Terminology, XML namespace setup, `<Ui>`, `<Include>`, `<Script>`, `<LayoutFrame>` base element, `<Anchors>`, `<Size>`, `<KeyValues>`, `<Animations>` |
| [XML-FRAME-TYPES.md](references/XML-FRAME-TYPES.md) | `<Frame>` and all subtypes: Button, CheckButton, ItemButton, ColorSelect, Cooldown, EditBox, GameTooltip, MessageFrame, Model (and subtypes), ScrollFrame, ScrollingMessageFrame, SimpleHTML, Slider, StatusBar, POI frames |
| [XML-REGIONS.md](references/XML-REGIONS.md) | `<Texture>`, `<MaskTexture>`, `<Line>`, `<FontString>`, plus shared child elements: `<Color>`, `<Gradient>`, `<TexCoords>`, `<Shadow>`, `<Inset>`, `<Dimension>` |
| [XML-FONTS.md](references/XML-FONTS.md) | `<Font>`, `<FontFamily>`, `<FontHeight>`, `<Member>` |
| [XML-ANIMATIONS.md](references/XML-ANIMATIONS.md) | `<AnimationGroup>`, `<Animation>` base, `<Alpha>`, `<Scale>`, `<LineScale>`, `<Translation>`, `<LineTranslation>`, `<Path>`, `<Rotation>`, `<TextureCoordTranslation>` |

## Quick Example

A minimal XML file that shows a texture centered on screen:

```xml
<Ui xmlns="http://www.blizzard.com/wow/ui/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.blizzard.com/wow/ui/
                        https://raw.githubusercontent.com/Gethe/wow-ui-source/live/Interface/AddOns/Blizzard_SharedXML/UI.xsd">
    <Frame parent="UIParent">
        <Size x="64" y="64"/>
        <Anchors>
            <Anchor point="CENTER"/>
        </Anchors>
        <Layers>
            <Layer level="ARTWORK">
                <Texture file="interface/icons/inv_mushroom_11" setAllPoints="true"/>
            </Layer>
        </Layers>
    </Frame>
</Ui>
```

## Common XML Attribute Types

| XSD Type | Lua Equivalent | Examples |
|----------|---------------|----------|
| `xs:string` | `string` | `"MyFrame"`, `"interface/icons/spell_nature_heal"` |
| `xs:boolean` | `boolean` | `"true"`, `"false"` |
| `xs:int` | `number` (integer) | `"0"`, `"42"` |
| `xs:float` | `number` (float) | `"1.0"`, `"0.5"` |
| `xs:unsignedInt` | `number` (non-negative integer) | `"0"`, `"255"` |
| `ui:FRAMEPOINT` | `string` | `"CENTER"`, `"TOPLEFT"`, `"BOTTOMRIGHT"` |
| `ui:FRAMESTRATA` | `string` | `"BACKGROUND"`, `"LOW"`, `"MEDIUM"`, `"HIGH"`, `"DIALOG"`, `"FULLSCREEN"`, `"FULLSCREEN_DIALOG"`, `"TOOLTIP"` |
| `ui:DRAWLAYER` | `string` | `"BACKGROUND"`, `"BORDER"`, `"ARTWORK"`, `"OVERLAY"`, `"HIGHLIGHT"` |
| `ui:ORIENTATION` | `string` | `"HORIZONTAL"`, `"VERTICAL"` |
| `ui:OUTLINETYPE` | `string` | `"NONE"`, `"NORMAL"`, `"THICK"` |
| `ui:ALPHAMODE` | `string` | `"DISABLE"`, `"BLEND"`, `"ALPHAKEY"`, `"ADD"`, `"MOD"` |
| `ui:INSERTMODE` | `string` | `"TOP"`, `"BOTTOM"` |
| `ui:JUSTIFYHTYPE` | `string` | `"LEFT"`, `"CENTER"`, `"RIGHT"` |
| `ui:JUSTIFYVTYPE` | `string` | `"TOP"`, `"MIDDLE"`, `"BOTTOM"` |
| `ui:ANIMLOOPTYPE` | `string` | `"NONE"`, `"REPEAT"`, `"BOUNCE"` |
| `ui:ANIMSMOOTHTYPE` | `string` | `"NONE"`, `"IN"`, `"OUT"`, `"IN_OUT"`, `"OUT_IN"` |
| `ui:ANIMCURVETYPE` | `string` | `"NONE"`, `"SMOOTH"` |
| `ui:KEYVALUETYPE` | `string` | `"nil"`, `"boolean"`, `"number"`, `"string"`, `"global"` |
| `ui:WRAPMODE` | `string` | `"CLAMP"`, `"REPEAT"`, `"CLAMPTOBLACK"`, `"CLAMPTOBLACKADDITIVE"`, `"CLAMPTOWHITE"`, `"MIRROR"` |

## Editor Setup

Use [VS Code](https://code.visualstudio.com/) with the [Red Hat XML](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-xml) extension for schema validation, autocompletion, and error checking in WoW XML files.
