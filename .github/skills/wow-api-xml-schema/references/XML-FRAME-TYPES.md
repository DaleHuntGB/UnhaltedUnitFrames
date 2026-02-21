# XML Frame Types — `<Frame>` and All Subtypes

This reference covers the `<Frame>` element and all of its specialized subtypes: Button, CheckButton, ItemButton, ColorSelect, Cooldown, EditBox, GameTooltip, MessageFrame, Model (and subtypes), ScrollFrame, ScrollingMessageFrame, SimpleHTML, Slider, StatusBar, ModelScene, MovieFrame, and POI frames.

> **Source:** [XML schema — Frame](https://warcraft.wiki.gg/wiki/XML_schema#Frame)
> **Current as of:** Patch 12.0.0 (Retail only)

---

## `<Frame>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/Frame
> **Inherits from:** `<LayoutFrame>`
> **Creates:** [Frame](https://warcraft.wiki.gg/wiki/UIOBJECT_Frame) widget

Handles events and user interaction, and may contain other widgets (textures, font strings, child frames).

### Structure

```xml
<Frame>
    <ResizeBounds />
    <HitRectInsets />
    <Layers />
    <Frames />
    <Scripts />
</Frame>
```

### Attributes

| Attribute | Type | Default | Description | Related API |
|-----------|------|---------|-------------|-------------|
| `alpha` | `xs:float` | `1.0` | Sets the frame's opacity (0.0 = invisible, 1.0 = fully opaque). | `Frame:SetAlpha()` |
| `scale` | `xs:float` | `1.0` | Sets the frame's scale factor relative to its parent. | `Frame:SetScale()` |
| `parent` | `xs:string` | — | Name of the parent frame. If omitted, the frame is parented to `UIParent` by default (or the enclosing `<Frames>` parent). | `ScriptRegion:SetParent()` |
| `toplevel` | `xs:boolean` | `false` | If `true`, the frame renders in front of siblings at the same frame level. | `Frame:SetToplevel()` |
| `flattenRenderLayers` | `xs:boolean` | `false` | Flattens child regions into a single render pass. | `Frame:SetFlattensRenderLayers()` |
| `useParentLevel` | `xs:boolean` | `false` | Prevents incrementing the frame level above its parent. | `Frame:SetUsingParentLevel()` |
| `movable` | `xs:boolean` | `false` | Enables the frame to be dragged by the user. Requires `RegisterForDrag` to specify mouse buttons. | `Frame:SetMovable()` |
| `resizable` | `xs:boolean` | `false` | Enables the frame to be resized by the user. Use `<ResizeBounds>` to set limits. | `Frame:SetResizable()` |
| `frameStrata` | `ui:FRAMESTRATA` | `PARENT` | Sequences overlapping frames. Values: `BACKGROUND`, `LOW`, `MEDIUM`, `HIGH`, `DIALOG`, `FULLSCREEN`, `FULLSCREEN_DIALOG`, `TOOLTIP`. | `Frame:SetFrameStrata()` |
| `frameLevel` | `xs:int` | — | Further sequences overlapping frames within the same `frameStrata`. Higher values render on top. | `Frame:SetFrameLevel()` |
| `id` | `xs:int` | `0` | Assigns a numeric identifier to the frame. | `Frame:SetID()` |
| `enableMouse` | `xs:boolean` | `false` | Enables all mouse input (clicks and motion) for this frame. | `ScriptRegion:EnableMouse()` |
| `enableMouseClicks` | `xs:boolean` | `false` | Enables mouse click input only. | `ScriptRegion:SetMouseClickEnabled()` |
| `enableMouseMotion` | `xs:boolean` | `false` | Enables mouse motion (enter/leave) events only. | `ScriptRegion:EnableMouseMotion()` |
| `enableKeyboard` | `xs:boolean` | `false` | Enables keyboard input for this frame. | `Frame:EnableKeyboard()` |
| `clampedToScreen` | `xs:boolean` | `false` | Prevents dragging the frame off the edges of the screen. | `Frame:SetClampedToScreen()` |
| `protected` | `xs:boolean` | `false` | Declares the frame as protected for secure code execution. | — |
| `depth` | `xs:float` | `0.0` | Sets the frame's depth for 3D-like layering. | `Frame:SetDepth()` |
| `dontSavePosition` | `xs:boolean` | `false` | Prevents saving the position of a user-positioned (movable) frame. | `Frame:SetDontSavePosition()` |
| `propagateKeyboardInput` | `xs:boolean` | `false` | Propagates keyboard input to the parent frame. | `Frame:SetPropagateKeyboardInput()` |
| `ignoreParentAlpha` | `xs:boolean` | `false` | Controls alpha independently rather than as a fraction of the parent's alpha. | `Region:SetIgnoreParentAlpha()` |
| `ignoreParentScale` | `xs:boolean` | `false` | Controls scale independently rather than as a fraction of the parent's scale. | `Region:SetIgnoreParentScale()` |
| `intrinsic` | `xs:boolean` | `false` | Creates an intrinsic frame type that can be instantiated with `CreateFrame("FrameName")`. | — |
| `clipChildren` | `xs:boolean` | `false` | Clips (hides) parts of child regions that overflow the frame's boundaries. | `Frame:SetClipsChildren()` |
| `propagateHyperlinksToParent` | `xs:boolean` | `false` | Propagates hyperlink interaction events (`OnHyperlinkClick`, etc.) to the parent frame. | — |
| `hyperlinksEnabled` | `xs:boolean` | `false` | Enables interactive hyperlinks in font strings within this frame. | `Frame:SetHyperlinksEnabled()` |
| `registerForDrag` | `xs:string` | — | Space-separated list of mouse buttons that can drag this frame (e.g., `"LeftButton"`). | `Frame:RegisterForDrag()` |
| `passThroughButtons` | `xs:string` | — | Mouse buttons that pass through this frame to the frame below. | `ScriptRegion:SetPassThroughButtons()` |
| `propagateMouseInput` | `PROPAGATE_MOUSE` | — | Propagates mouse click events to the parent frame. | `ScriptRegion:SetPropagateMouseClicks()` |
| `fixedFrameLevel` | `xs:boolean` | `false` | Prevents the frame level from being adjusted by the system. | `Frame:SetFixedFrameLevel()` |
| `fixedFrameStrata` | `xs:boolean` | `false` | Prevents the frame strata from being adjusted by the system. | `Frame:SetFixedFrameStrata()` |
| `frameBuffer` | `xs:boolean` | `false` | Uses a frame buffer for rendering. | `Frame:SetIsFrameBuffer()` |
| `collapsesLayout` | `xs:boolean` | `false` | When hidden, collapses layout (anchored siblings adjust as if this frame doesn't exist). | `ScriptRegion:SetCollapsesLayout()` |

*(Plus all attributes inherited from `<LayoutFrame>`: `name`, `parentKey`, `parentArray`, `inherits`, `virtual`, `mixin`, `secureMixin`, `setAllPoints`, `hidden`)*

### Child Elements

#### `<HitRectInsets>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/Inset

Inherits from `<Inset>`. Shrinks (positive values) or expands (negative values) the mouse focus area from the frame's edges.

```xml
<HitRectInsets left="5" right="5" top="5" bottom="5"/>
```

#### `<Layers>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/Layer

Encloses `<Layer>` tags to sequence overlapping graphical regions parented by the same frame.

```xml
<Layers>
    <Layer level="BACKGROUND">
        <Texture parentKey="Background" setAllPoints="true">
            <Color r="0" g="0" b="0" a="0.5"/>
        </Texture>
    </Layer>
    <Layer level="ARTWORK">
        <FontString parentKey="Title" inherits="GameFontNormal" text="Hello"/>
    </Layer>
</Layers>
```

**`<Layer>` attributes:**

| Attribute | Type | Description |
|-----------|------|-------------|
| `level` | `ui:DRAWLAYER` | Draw layer: `"BACKGROUND"`, `"BORDER"`, `"ARTWORK"`, `"OVERLAY"`, `"HIGHLIGHT"`. Layers render in this order. |
| `textureSubLevel` | `xs:int` | Further sequences overlapping `<Texture>` widgets within the same `level`. |

A `<Layer>` can contain: `<Texture>`, `<MaskTexture>`, `<Line>`, `<FontString>`.

#### `<Frames>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/Frames

Encloses other `<Frame>` tags (or subtypes) as children of this frame.

```xml
<Frames>
    <Button parentKey="CloseButton" inherits="UIPanelCloseButton">
        <Anchors>
            <Anchor point="TOPRIGHT" x="-5" y="-5"/>
        </Anchors>
    </Button>
</Frames>
```

#### `<Scripts>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/Scripts

Contains widget script handlers such as `<OnLoad>`, `<OnUpdate>`, `<OnShow>`, `<OnHide>`, `<OnEvent>`, `<OnClick>`, etc.

```xml
<Scripts>
    <OnLoad method="OnLoad"/>
    <OnEvent function="MyAddon_OnEvent"/>
    <OnUpdate>
        -- Inline Lua code
        self.elapsed = (self.elapsed or 0) + elapsed
    </OnUpdate>
</Scripts>
```

**Script handler attributes:**

| Attribute | Type | Description |
|-----------|------|-------------|
| `function` | `xs:string` | Name of a global Lua function to call instead of inline Lua code between the XML tags. |
| `method` | `xs:string` | Name of a method on the widget to call (e.g., `method="OnLoad"` calls `self:OnLoad()`). |
| `inherit` | `xs:string` | Hooks inherited scripts: `"prepend"` (run before) or `"append"` (run after) scripts from an XML virtual template. |
| `intrinsicOrder` | `xs:string` | Hooks intrinsic scripts: `"precall"` or `"postcall"` when copied as an intrinsic frame. |
| `autoEnableInput` | `xs:boolean` | — |

---

## `<Button>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/Button
> **Inherits from:** `<Frame>`
> **Creates:** [Button](https://warcraft.wiki.gg/wiki/UIOBJECT_Button) widget

Responds to mouse clicks. Supports normal, pushed, disabled, and highlight visual states.

### Structure

```xml
<Button text="" registerForClicks="" motionScriptsWhileDisabled="">
    <NormalTexture />
    <PushedTexture />
    <DisabledTexture />
    <HighlightTexture />
    <NormalColor />
    <HighlightColor />
    <DisabledColor />
    <ButtonText />
    <PushedTextOffset />
    <NormalFont style="" />
    <HighlightFont style="" />
    <DisabledFont style="" />
</Button>
```

### Attributes

| Attribute | Type | Default | Description | Related API |
|-----------|------|---------|-------------|-------------|
| `text` | `xs:string` | — | Displays a text label on the button. | `Button:SetText()` |
| `registerForClicks` | `xs:string` | — | Controls which mouse buttons trigger `OnClick`. Space-separated values like `"LeftButtonUp"`, `"RightButtonDown"`. | `Button:RegisterForClicks()` |
| `motionScriptsWhileDisabled` | `xs:boolean` | — | If `true`, enables `OnEnter` and `OnLeave` scripts even when the button is disabled. | `Button:SetMotionScriptsWhileDisabled()` |

### Child Elements

| Element | Description |
|---------|-------------|
| `<NormalTexture>` | Texture displayed in the normal (default) state. Inherits `<Texture>`. |
| `<PushedTexture>` | Texture displayed when the button is pressed/pushed. Inherits `<Texture>`. |
| `<DisabledTexture>` | Texture displayed when the button is disabled. Inherits `<Texture>`. |
| `<HighlightTexture>` | Texture displayed when the mouse hovers over the button. Inherits `<Texture>`. |
| `<NormalColor>` | Text label color in normal state. Inherits `<Color>`. |
| `<HighlightColor>` | Text label color on hover. Inherits `<Color>`. |
| `<DisabledColor>` | Text label color when disabled. Inherits `<Color>`. |
| `<ButtonText>` | The text label widget. Inherits `<FontString>`. |
| `<PushedTextOffset>` | Moves the label when the button is pressed. Inherits `<Dimension>`. |
| `<NormalFont>` | Font style for normal state. Attribute: `style` (`xs:string`). |
| `<HighlightFont>` | Font style for hover state. Attribute: `style` (`xs:string`). |
| `<DisabledFont>` | Font style for disabled state. Attribute: `style` (`xs:string`). |

---

## `<CheckButton>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/CheckButton
> **Inherits from:** `<Button>`
> **Creates:** [CheckButton](https://warcraft.wiki.gg/wiki/UIOBJECT_CheckButton) widget

Adds a toggleable checked/unchecked state to a button.

### Structure

```xml
<CheckButton>
    <CheckedTexture />
    <DisabledCheckedTexture />
</CheckButton>
```

### Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `checked` | `xs:boolean` | — | If `true`, the button starts in the checked state (shows the checked texture). |

### Child Elements

| Element | Description |
|---------|-------------|
| `<CheckedTexture>` | Texture displayed when the button is checked. Inherits `<Texture>`. |
| `<DisabledCheckedTexture>` | Texture displayed when the button is both checked and disabled. Inherits `<Texture>`. |

---

## `<ItemButton>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML_schema#ItemButton

An [intrinsic frame](https://warcraft.wiki.gg/wiki/Intrinsic_frame) extending `<Button>`. No additional attributes or child elements beyond those inherited from `<Button>`.

---

## `<ColorSelect>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/ColorSelect
> **Inherits from:** `<Frame>`
> **Creates:** [ColorSelect](https://warcraft.wiki.gg/wiki/UIOBJECT_ColorSelect) widget

Provides a color picker with a hue wheel and a shade/value slider.

### Structure

```xml
<ColorSelect>
    <ColorWheelTexture />
    <ColorWheelThumbTexture />
    <ColorValueTexture />
    <ColorValueThumbTexture />
</ColorSelect>
```

### Child Elements

| Element | Description |
|---------|-------------|
| `<ColorWheelTexture>` | Produces the circular color wheel of hues. Inherits `<Texture>`. |
| `<ColorWheelThumbTexture>` | Marks the current hue selection on the wheel. Inherits `<Texture>`. |
| `<ColorValueTexture>` | Produces the vertical gradient of shades (light to dark). Inherits `<Texture>`. |
| `<ColorValueThumbTexture>` | Marks the current shade selection on the value bar. Inherits `<Texture>`. |

---

## `<Cooldown>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/Cooldown
> **Inherits from:** `<Frame>`
> **Creates:** [Cooldown](https://warcraft.wiki.gg/wiki/UIOBJECT_Cooldown) widget

Overlays another frame with a rotating edge, swipe animation, and bling effect to indicate a cooldown timer.

### Structure

```xml
<Cooldown reverse="" hideCountdownNumbers="" drawEdge="" drawBling="" drawSwipe="" rotation="">
    <EdgeTexture />
    <SwipeTexture />
    <BlingTexture />
</Cooldown>
```

### Attributes

| Attribute | Type | Default | Description | Related API |
|-----------|------|---------|-------------|-------------|
| `reverse` | `xs:boolean` | — | Reverses the cooldown swipe direction. | `Cooldown:SetReverse()` |
| `hideCountdownNumbers` | `xs:boolean` | — | Hides the countdown number text overlay. | `Cooldown:SetHideCountdownNumbers()` |
| `drawEdge` | `xs:boolean` | — | Draws the rotating edge line at the cooldown boundary. | `Cooldown:SetDrawEdge()` |
| `drawSwipe` | `xs:boolean` | — | Draws the darkened swipe area. | `Cooldown:SetDrawSwipe()` |
| `drawBling` | `xs:boolean` | — | Draws the bling flash animation when the cooldown finishes. | `Cooldown:SetDrawBling()` |
| `rotation` | `xs:float` | — | Rotates the origin point of the cooldown animation (in radians). | `Cooldown:SetRotation()` |

### Child Elements

| Element | Description |
|---------|-------------|
| `<EdgeTexture>` | The rotating edge texture at the cooldown boundary. Inherits `<Texture>`. |
| `<SwipeTexture>` | The darkened fill between the origin and edge. Inherits `<Texture>`. |
| `<BlingTexture>` | The brief flash animation when cooldown finishes. Inherits `<Texture>`. |

---

## `<EditBox>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/EditBox
> **Inherits from:** `<Frame>`
> **Creates:** [EditBox](https://warcraft.wiki.gg/wiki/UIOBJECT_EditBox) widget

Receives text input from the user's keyboard.

### Structure

```xml
<EditBox font="" letters="" blinkSpeed="" numeric="" alphabeticOnly=""
         password="" multiLine="" historyLines="" autoFocus="" ignoreArrows=""
         countInvisibleLetters="" invisibleBytes="">
    <FontString />
    <HighlightColor />
    <TextInsets />
</EditBox>
```

### Attributes

| Attribute | Type | Default | Description | Related API |
|-----------|------|---------|-------------|-------------|
| `font` | `xs:string` | — | Name of a `<Font>` object to use for text display. | `FontInstance:SetFontObject()` |
| `letters` | `xs:int` | — | Maximum number of characters allowed. Zero or omitted = no limit. | `EditBox:SetMaxLetters()` |
| `blinkSpeed` | `xs:float` | — | Speed of cursor blinking, in seconds between blinks. | `EditBox:SetBlinkSpeed()` |
| `numeric` | `xs:boolean` | — | If `true`, only digits `0-9` can be entered. | `EditBox:SetNumeric()` |
| `alphabeticOnly` | `xs:boolean` | — | If `true`, only alphabetic characters are accepted. | — |
| `password` | `xs:boolean` | — | If `true`, displays asterisks (`*`) instead of the actual text. | `EditBox:SetPassword()` |
| `multiLine` | `xs:boolean` | — | If `true`, allows multi-line text input. | `EditBox:SetMultiLine()` |
| `historyLines` | `xs:int` | — | Number of history entries to keep. Use arrow keys (or Alt+arrows if `ignoreArrows` is true) to cycle through history. | `EditBox:SetHistoryLines()` |
| `autoFocus` | `xs:boolean` | — | If `true`, the EditBox automatically receives keyboard focus when shown. | `EditBox:SetAutoFocus()` |
| `ignoreArrows` | `xs:boolean` | — | If `true`, arrow keys are ignored by the EditBox (they control the game character instead). Use Alt+arrows to move the cursor. | — |
| `countInvisibleLetters` | `xs:boolean` | — | Whether invisible characters count toward the `letters` limit. | `EditBox:SetCountInvisibleLetters()` |
| `invisibleBytes` | `xs:int` | — | Maximum invisible bytes. | — |

### Child Elements

| Element | Description |
|---------|-------------|
| `<FontString>` | The text display widget. Inherits `<FontString>`. |
| `<HighlightColor>` | Color of selected/highlighted text. Inherits `<Color>`. |
| `<TextInsets>` | Padding (positive) or overflow (negative) of the font string relative to the EditBox edges. Inherits `<Inset>`. |

---

## `<GameTooltip>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/GameTooltip
> **Inherits from:** `<Frame>`
> **Creates:** [GameTooltip](https://warcraft.wiki.gg/wiki/UIOBJECT_GameTooltip) widget

Formats and displays a tooltip. Typically used by inheriting the default `GameTooltip` or creating a custom one.

```xml
<GameTooltip />
```

No additional attributes or child elements beyond those inherited from `<Frame>`.

---

## `<MessageFrame>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/MessageFrame
> **Inherits from:** `<Frame>`
> **Creates:** [MessageFrame](https://warcraft.wiki.gg/wiki/UIOBJECT_MessageFrame) widget

Displays scrolling text messages that appear and optionally fade out over time.

### Structure

```xml
<MessageFrame font="" fade="" fadeDuration="" fadePower="" displayDuration="" insertMode="">
    <FontString />
    <TextInsets />
</MessageFrame>
```

### Attributes

| Attribute | Type | Default | Description | Related API |
|-----------|------|---------|-------------|-------------|
| `font` | `xs:string` | — | Name of a `<Font>` object. | `FontInstance:SetFontObject()` |
| `fade` | `xs:boolean` | — | If `true`, messages fade out gradually; if `false`, they disappear instantly. | `MessageFrame:SetFading()` |
| `fadeDuration` | `xs:float` | `3.0` | Duration of the fade-out in seconds. | `MessageFrame:SetFadeDuration()` |
| `fadePower` | `xs:float` | `1.0` | Controls the fade curve power. | `MessageFrame:SetFadePower()` |
| `displayDuration` | `xs:float` | `10.0` | How long each message is displayed before fading. | `MessageFrame:SetTimeVisible()` |
| `insertMode` | `ui:INSERTMODE` | `BOTTOM` | Where new messages appear: `"TOP"` or `"BOTTOM"`. | `MessageFrame:SetInsertMode()` |

### Child Elements

| Element | Description |
|---------|-------------|
| `<FontString>` | The font string template for messages. Inherits `<FontString>`. |
| `<TextInsets>` | Padding for the text area. Inherits `<Inset>`. |

---

## `<Model>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/Model
> **Inherits from:** `<Frame>`
> **Creates:** [Model](https://warcraft.wiki.gg/wiki/UIOBJECT_Model) widget

Renders a 3D model within the UI.

### Structure

```xml
<Model file="" modelScale="" fogNear="" fogFar="" glow="" drawLayer="">
    <FogColor />
</Model>
```

### Attributes

| Attribute | Type | Default | Description | Related API |
|-----------|------|---------|-------------|-------------|
| `file` | `xs:string` | — | Relative path to the model resource, starting from `Interface/`. | `Model:SetModel()` |
| `modelScale` | `xs:float` | — | Scale of the 3D model. | `Model:SetModelScale()` |
| `fogNear` | `xs:float` | — | Near fog distance. | — |
| `fogFar` | `xs:float` | — | Far fog distance. | — |
| `glow` | `xs:float` | — | Glow intensity. | — |
| `drawLayer` | `ui:DRAWLAYER` | — | Draw layer for the model. | — |

### Child Elements

| Element | Description |
|---------|-------------|
| `<FogColor>` | Sets the fog color. Inherits `<Color>`. |

### `<PlayerModel>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/PlayerModel
> **Inherits from:** `<Model>`
> **Creates:** [PlayerModel](https://warcraft.wiki.gg/wiki/UIOBJECT_PlayerModel) widget

Displays a pose of the player character. No additional attributes beyond `<Model>`.

#### `<DressUpModel>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/DressUpModel
> **Inherits from:** `<PlayerModel>`
> **Creates:** [DressUpModel](https://warcraft.wiki.gg/wiki/UIOBJECT_DressUpModel) widget

Trials equipment appearances on the player character. No additional attributes.

#### `<TabardModel>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/TabardModel
> **Inherits from:** `<PlayerModel>`
> **Creates:** [TabardModel](https://warcraft.wiki.gg/wiki/UIOBJECT_TabardModel) widget

Trials tabard appearances on the player character. No additional attributes.

### `<CinematicModel>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/CinematicModel
> **Inherits from:** `<Model>`
> **Creates:** [CinematicModel](https://warcraft.wiki.gg/wiki/UIOBJECT_CinematicModel) widget

Displays a creature in a cinematic pose.

| Attribute | Type | Description | Related API |
|-----------|------|-------------|-------------|
| `facing` | `xs:boolean` | Whether the model is facing left. | `CinematicModel:SetFacingLeft()` |

### `<UiCamera>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/UiCamera
> **Inherits from:** `<Model>`
> **Creates:** UiCamera widget

A camera widget for model viewing. No additional documented attributes.

---

## `<ModelScene>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML_schema#Widget_hierarchy
> **Inherits from:** `<Frame>`
> **Creates:** [ModelScene](https://warcraft.wiki.gg/wiki/UIOBJECT_ModelScene) widget

Scene-based 3D rendering that can contain multiple actors and a camera. Preferred over `<Model>` for modern addons.

---

## `<ScrollFrame>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/ScrollFrame
> **Inherits from:** `<Frame>`
> **Creates:** [ScrollFrame](https://warcraft.wiki.gg/wiki/UIOBJECT_ScrollFrame) widget

Provides a scrollable viewport for a child `<ScrollChild>` frame.

### Structure

```xml
<ScrollFrame>
    <ScrollChild />
</ScrollFrame>
```

### Child Elements

| Element | Description |
|---------|-------------|
| `<ScrollChild>` | The frame that is scrolled within the viewport. Inherits `<Frame>`. Should be sized larger than the `<ScrollFrame>` to enable scrolling. |

---

## `<ScrollingMessageFrame>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML_schema#ScrollingMessageFrame

An [intrinsic frame](https://warcraft.wiki.gg/wiki/Intrinsic_frame) extending `<Frame>`. Functions as a scrollable message display. No additional XML-specific attributes beyond those from `<Frame>`.

---

## `<SimpleHTML>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/SimpleHTML
> **Inherits from:** `<Frame>`
> **Creates:** [SimpleHTML](https://warcraft.wiki.gg/wiki/UIOBJECT_SimpleHTML) widget

Renders simple HTML content (paragraphs, headers, hyperlinks, images).

### Structure

```xml
<SimpleHTML font="" file="" hyperlinkFormat="" resizeToFitContents="">
    <FontString />
    <FontStringHeader1 />
    <FontStringHeader2 />
    <FontStringHeader3 />
</SimpleHTML>
```

### Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `font` | `xs:string` | — | Name of a `<Font>` object for default body text. |
| `file` | `xs:string` | — | Path to an HTML file to load. |
| `hyperlinkFormat` | `xs:string` | `"\|H%s\|h%s\|h"` | Format string for hyperlinks, using the WoW hyperlink escape sequence pattern. |
| `resizeToFitContents` | `xs:boolean` | — | If `true`, automatically resizes the frame to fit the rendered HTML content. |

### Child Elements

| Element | Description |
|---------|-------------|
| `<FontString>` | Default body text font. Inherits `<FontString>`. |
| `<FontStringHeader1>` | Font for `<H1>` headers. Inherits `<FontString>`. |
| `<FontStringHeader2>` | Font for `<H2>` headers. Inherits `<FontString>`. |
| `<FontStringHeader3>` | Font for `<H3>` headers. Inherits `<FontString>`. |

---

## `<Slider>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/Slider
> **Inherits from:** `<Frame>`
> **Creates:** [Slider](https://warcraft.wiki.gg/wiki/UIOBJECT_Slider) widget

Lets the user select a value within a numeric range by dragging a thumb.

### Structure

```xml
<Slider drawLayer="" minValue="" maxValue="" defaultValue="" valueStep="" orientation="" obeyStepOnDrag="">
    <ThumbTexture />
</Slider>
```

### Attributes

| Attribute | Type | Default | Description | Related API |
|-----------|------|---------|-------------|-------------|
| `drawLayer` | `ui:DRAWLAYER` | — | Draw layer for the slider track. | — |
| `minValue` | `xs:float` | — | Minimum selectable value (left/bottom end). | `Slider:SetMinMaxValues()` |
| `maxValue` | `xs:float` | — | Maximum selectable value (right/top end). | `Slider:SetMinMaxValues()` |
| `defaultValue` | `xs:float` | — | Initial value, normally between `minValue` and `maxValue`. | `Slider:SetValue()` |
| `valueStep` | `xs:float` | — | Increment between selectable values. | `Slider:SetValueStep()` |
| `orientation` | `ui:ORIENTATION` | `VERTICAL` | Slider direction: `"HORIZONTAL"` or `"VERTICAL"`. | `Slider:SetOrientation()` |
| `obeyStepOnDrag` | `xs:boolean` | — | If `true`, snaps to `valueStep` increments while dragging. | `Slider:SetObeyStepOnDrag()` |

### Child Elements

| Element | Description |
|---------|-------------|
| `<ThumbTexture>` | The draggable thumb widget. Inherits `<Texture>`. |

---

## `<StatusBar>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/StatusBar
> **Inherits from:** `<Frame>`
> **Creates:** [StatusBar](https://warcraft.wiki.gg/wiki/UIOBJECT_StatusBar) widget

Displays a fill bar (e.g., health, mana, experience, progress).

### Structure

```xml
<StatusBar drawLayer="" minValue="" maxValue="" defaultValue="" orientation="" rotatesTexture="" reverseFill="">
    <BarTexture />
    <BarColor />
</StatusBar>
```

### Attributes

| Attribute | Type | Default | Description | Related API |
|-----------|------|---------|-------------|-------------|
| `drawLayer` | `ui:DRAWLAYER` | — | Draw layer for the bar. | — |
| `minValue` | `xs:float` | — | Value when the bar is empty (e.g., `0`). | `StatusBar:SetMinMaxValues()` |
| `maxValue` | `xs:float` | — | Value when the bar is full (e.g., `UnitHealthMax("player")`). | `StatusBar:SetMinMaxValues()` |
| `defaultValue` | `xs:float` | — | Initial value, between `minValue` and `maxValue`. | `StatusBar:SetValue()` |
| `orientation` | `ui:ORIENTATION` | `HORIZONTAL` | Fill direction: `"HORIZONTAL"` or `"VERTICAL"`. | `StatusBar:SetOrientation()` |
| `rotatesTexture` | `xs:boolean` | — | If `true`, rotates the bar texture when orientation is vertical. | `StatusBar:SetRotatesTexture()` |
| `reverseFill` | `xs:boolean` | — | If `true`, the bar fills from right-to-left or top-to-bottom. | `StatusBar:SetReverseFill()` |

### Child Elements

| Element | Description |
|---------|-------------|
| `<BarTexture>` | The fill texture of the bar. Inherits `<Texture>`. |
| `<BarColor>` | The fill color of the bar. Inherits `<Color>`. |

---

## `<MovieFrame>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML_schema#Widget_hierarchy
> **Inherits from:** `<Frame>`

Plays back video content. Typically used by Blizzard for cinematics.

---

## `<ArchaeologyDigSiteFrame>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/ArchaeologyDigSiteFrame
> **Inherits from:** `<Frame>`

Marks an archaeology dig site on the map.

```xml
<ArchaeologyDigSiteFrame filltexture="" bordertexture="" />
```

| Attribute | Type | Description |
|-----------|------|-------------|
| `filltexture` | `xs:string` | Path to the fill texture for the dig site area. |
| `bordertexture` | `xs:string` | Path to the border texture for the dig site outline. |

---

## `<QuestPOIFrame>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/QuestPOIFrame
> **Inherits from:** `<Frame>`

Marks a quest location on the map.

```xml
<QuestPOIFrame filltexture="" bordertexture="" />
```

| Attribute | Type | Description |
|-----------|------|-------------|
| `filltexture` | `xs:string` | Path to the fill texture. |
| `bordertexture` | `xs:string` | Path to the border texture. |

---

## `<ScenarioPOIFrame>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/ScenarioPOIFrame
> **Inherits from:** `<Frame>`

Marks a scenario point of interest on the map.

```xml
<ScenarioPOIFrame filltexture="" bordertexture="" />
```

| Attribute | Type | Description |
|-----------|------|-------------|
| `filltexture` | `xs:string` | Path to the fill texture. |
| `bordertexture` | `xs:string` | Path to the border texture. |
