# XML Animations — `<AnimationGroup>`, `<Animation>`, and All Subtypes

This reference covers the XML animation system: `<AnimationGroup>` containers and all `<Animation>` subtypes (`<Alpha>`, `<Scale>`, `<LineScale>`, `<Translation>`, `<LineTranslation>`, `<Path>`, `<Rotation>`, `<TextureCoordTranslation>`). Animations are defined inside `<Animations>` sections on a `<LayoutFrame>` or directly inside `<AnimationGroup>` elements.

> **Source:** [XML schema — AnimationGroup, Animation](https://warcraft.wiki.gg/wiki/XML_schema#AnimationGroup)
> **Current as of:** Patch 12.0.0 (Retail only)

---

## `<AnimationGroup>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/AnimationGroup
> **Creates:** [AnimationGroup](https://warcraft.wiki.gg/wiki/UIOBJECT_AnimationGroup) widget

Container for one or more `<Animation>` elements. An animation group plays its animations in sequence based on their `order` attribute, or simultaneously if they share the same `order`.

### Structure

```xml
<AnimationGroup parentKey="FadeIn" looping="NONE" setToFinalAlpha="true">
    <Alpha fromAlpha="0" toAlpha="1" duration="0.3" order="1"/>
    <Translation offsetX="0" offsetY="10" duration="0.3" order="1"/>
    <Scripts>
        <OnFinished>
            self:GetParent():SetAlpha(1)
        </OnFinished>
    </Scripts>
</AnimationGroup>
```

### Attributes

| Attribute | Type | Default | Description | Related API |
|-----------|------|---------|-------------|-------------|
| `name` | `xs:string` | — | Optional global name. Supports `$parent` substitution. | — |
| `inherits` | `xs:string` | — | Comma-separated list of virtual template names to inherit from. | — |
| `virtual` | `xs:boolean` | — | If `true`, creates a virtual template. | — |
| `parentKey` | `xs:string` | — | Adds a reference on the parent widget's table. | `Object:SetParentKey()` |
| `parentArray` | `xs:string` | — | Inserts into an array on the parent widget. | `tinsert()` |
| `looping` | `ui:ANIMLOOPTYPE` | `NONE` | Looping behavior: `"NONE"` (plays once), `"REPEAT"` (loops forever), `"BOUNCE"` (plays forward then backward). | `AnimationGroup:SetLooping()` |
| `setToFinalAlpha` | `xs:boolean` | — | If `true`, the widget retains the final alpha value after the animation ends. | `AnimationGroup:SetToFinalAlpha()` |

### Child Elements

| Element | Description |
|---------|-------------|
| Any `<Animation>` subtype | `<Alpha>`, `<Scale>`, `<Translation>`, `<Path>`, `<Rotation>`, etc. |
| `<Scripts>` | Widget script handlers. Commonly used scripts: `<OnPlay>`, `<OnPause>`, `<OnStop>`, `<OnFinished>`, `<OnLoop>`. |

**`<Scripts>` attributes** (same as on `<Frame>`):

| Attribute | Type | Description |
|-----------|------|-------------|
| `function` | `xs:string` | Global function name to call. |
| `method` | `xs:string` | Method name on the widget to call. |
| `inherit` | `xs:string` | `"prepend"` or `"append"` hook for inherited scripts. |
| `intrinsicOrder` | `xs:string` | `"precall"` or `"postcall"` for intrinsic frame scripts. |
| `autoEnableInput` | `xs:boolean` | — |

---

## `<Animation>` — Abstract Base

> **Reference:** https://warcraft.wiki.gg/wiki/XML/Animation
> **Creates:** [Animation](https://warcraft.wiki.gg/wiki/UIOBJECT_Animation) (abstract)

Abstracts tags and attributes common to all animation types. You don't use `<Animation>` directly — use the specific subtypes below.

### Structure

```xml
<Animation>
    <Scripts />
</Animation>
```

### Attributes (Inherited by All Subtypes)

| Attribute | Type | Default | Description | Related API |
|-----------|------|---------|-------------|-------------|
| `name` | `xs:string` | — | Optional global name. | — |
| `inherits` | `xs:string` | — | Virtual template(s) to inherit from. | — |
| `virtual` | `xs:boolean` | — | Creates a virtual template. | — |
| `target` | `xs:string` | — | Name of the target widget to animate (if different from parent). | `Animation:SetTarget()` |
| `targetKey` | `xs:string` | — | Target widget by parent key path. | `Animation:SetTargetKey()` |
| `parentKey` | `xs:string` | — | Adds a reference on the parent's table. | — |
| `childKey` | `xs:string` | — | Target by child key. | — |
| `startDelay` | `xs:float` | — | Delay in seconds before the animation starts playing. | `Animation:SetStartDelay()` |
| `endDelay` | `xs:float` | — | Delay in seconds after the animation finishes before the group continues. | `Animation:SetEndDelay()` |
| `duration` | `xs:float` | — | Duration of the animation in seconds. | `Animation:SetDuration()` |
| `order` | `ui:AnimOrderType` | `1` | Sequence order within the group. Whole number from 1 (default) to 100. Animations with the same `order` play simultaneously; higher orders play after lower ones finish. | `Animation:SetOrder()` |
| `smoothing` | `ui:ANIMSMOOTHTYPE` | `NONE` | Easing function: `"NONE"` (linear), `"IN"` (ease in), `"OUT"` (ease out), `"IN_OUT"` (ease both), `"OUT_IN"`. | `Animation:SetSmoothing()` |

### Child Elements

| Element | Description |
|---------|-------------|
| `<Scripts>` | Script handlers for the animation. Common: `<OnPlay>`, `<OnPause>`, `<OnStop>`, `<OnFinished>`, `<OnUpdate>`. |

---

## `<Alpha>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/Alpha
> **Inherits from:** `<Animation>`
> **Creates:** [Alpha](https://warcraft.wiki.gg/wiki/UIOBJECT_Alpha) animation

Animates a region's alpha (opacity) over time.

```xml
<Alpha fromAlpha="0" toAlpha="1" duration="0.5" smoothing="IN"/>
```

### Attributes

| Attribute | Type | Default | Description | Related API |
|-----------|------|---------|-------------|-------------|
| `fromAlpha` | `xs:float` | — | Starting alpha value (0.0 = invisible, 1.0 = fully opaque). | `Alpha:SetFromAlpha()` |
| `toAlpha` | `xs:float` | — | Ending alpha value. | `Alpha:SetToAlpha()` |

*(Plus all attributes inherited from `<Animation>`: `duration`, `order`, `smoothing`, `startDelay`, `endDelay`, etc.)*

### Example: Fade-In Effect

```xml
<AnimationGroup parentKey="FadeIn">
    <Alpha fromAlpha="0" toAlpha="1" duration="0.3" order="1"/>
</AnimationGroup>
```

---

## `<Scale>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/Scale
> **Inherits from:** `<Animation>`
> **Creates:** [Scale](https://warcraft.wiki.gg/wiki/UIOBJECT_Scale) animation

Animates a region's size by scaling it.

```xml
<Scale fromScaleX="0.5" fromScaleY="0.5" toScaleX="1.0" toScaleY="1.0" duration="0.3"/>
```

### Attributes

| Attribute | Type | Default | Description | Related API |
|-----------|------|---------|-------------|-------------|
| `scaleX` | `xs:float` | `1.0` | Horizontal scale factor (used when `from`/`to` variants are not specified). | `Scale:SetScale()` |
| `scaleY` | `xs:float` | `1.0` | Vertical scale factor. | `Scale:SetScale()` |
| `fromScaleX` | `xs:float` | `1.0` | Starting horizontal scale. | `Scale:SetFromScale()` |
| `fromScaleY` | `xs:float` | `1.0` | Starting vertical scale. | `Scale:SetFromScale()` |
| `toScaleX` | `xs:float` | `1.0` | Ending horizontal scale. | `Scale:SetToScale()` |
| `toScaleY` | `xs:float` | `1.0` | Ending vertical scale. | `Scale:SetToScale()` |

*(Plus all attributes inherited from `<Animation>`.)*

### `<LineScale>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML_schema#LineScale

Inherits from `<Scale>`. Creates a LineScale animation. Same attributes as `<Scale>`, specialized for `<Line>` widgets.

---

## `<Translation>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/Translation
> **Inherits from:** `<Animation>`
> **Creates:** [Translation](https://warcraft.wiki.gg/wiki/UIOBJECT_Translation) animation

Animates a region's position by moving it.

```xml
<Translation offsetX="0" offsetY="20" duration="0.5" smoothing="OUT"/>
```

### Attributes

| Attribute | Type | Default | Description | Related API |
|-----------|------|---------|-------------|-------------|
| `offsetX` | `xs:float` | `0.0` | Horizontal movement offset in pixels. Positive = right. | `Translation:SetOffset()` |
| `offsetY` | `xs:float` | `0.0` | Vertical movement offset in pixels. Positive = up. | `Translation:SetOffset()` |

*(Plus all attributes inherited from `<Animation>`.)*

### `<LineTranslation>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML_schema#LineTranslation

Inherits from `<Translation>`. Creates a LineTranslation animation. Same attributes as `<Translation>`, specialized for `<Line>` widgets.

---

## `<Path>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/Path
> **Inherits from:** `<Animation>`
> **Creates:** [Path](https://warcraft.wiki.gg/wiki/UIOBJECT_Path) animation

Moves a region along a path defined by control points.

### Structure

```xml
<Path curve="SMOOTH" duration="1.0">
    <ControlPoints>
        <ControlPoint name="cp1" offsetX="50" offsetY="0"/>
        <ControlPoint name="cp2" offsetX="100" offsetY="50"/>
        <ControlPoint name="cp3" offsetX="50" offsetY="100"/>
    </ControlPoints>
</Path>
```

### Attributes

| Attribute | Type | Default | Description | Related API |
|-----------|------|---------|-------------|-------------|
| `curve` | `ui:ANIMCURVETYPE` | `NONE` | Curve type: `"NONE"` (linear between points) or `"SMOOTH"` (smooth Bezier curve). | `Path:SetCurveType()` |

*(Plus all attributes inherited from `<Animation>`.)*

### Child Elements

#### `<ControlPoints>`

Encloses one or more `<ControlPoint>` tags that define the waypoints of the path.

**`<ControlPoint>` attributes:**

| Attribute | Type | Description |
|-----------|------|-------------|
| `name` | `xs:string` | Optional name for the control point. |
| `offsetX` | `xs:float` | Horizontal offset from the region's original position. |
| `offsetY` | `xs:float` | Vertical offset from the region's original position. |

---

## `<Rotation>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML/Rotation
> **Inherits from:** `<Animation>`
> **Creates:** [Rotation](https://warcraft.wiki.gg/wiki/UIOBJECT_Rotation) animation

Rotates a region around an origin point.

### Structure

```xml
<Rotation degrees="360" duration="2.0">
    <Origin point="CENTER">
        <Offset x="0" y="0"/>
    </Origin>
</Rotation>
```

### Attributes

| Attribute | Type | Default | Description | Related API |
|-----------|------|---------|-------------|-------------|
| `degrees` | `xs:float` | — | Rotation amount in degrees. Positive = counterclockwise. | `Rotation:SetDegrees()` |
| `radians` | `xs:float` | — | Rotation amount in radians. Alternative to `degrees`. | `Rotation:SetRadians()` |

*(Plus all attributes inherited from `<Animation>`.)*

### Child Elements

#### `<Origin>`

Defines the point around which the region rotates.

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `point` | `ui:FRAMEPOINT` | `CENTER` | Anchor point on the region to use as the rotation center. Values: `TOPLEFT`, `TOP`, `TOPRIGHT`, `LEFT`, `CENTER`, `RIGHT`, `BOTTOMLEFT`, `BOTTOM`, `BOTTOMRIGHT`. |

**`<Offset>` child (inside `<Origin>`):**

Offsets the rotation origin from the anchor point. Inherits from `<Dimension>`.

| Attribute | Type | Description |
|-----------|------|-------------|
| `x` | `xs:float` | Horizontal offset from the anchor point. |
| `y` | `xs:float` | Vertical offset from the anchor point. |

### Example: Spinning Icon

```xml
<Texture parentKey="Spinner" atlas="ui-loadingicon">
    <Size x="32" y="32"/>
    <Anchors>
        <Anchor point="CENTER"/>
    </Anchors>
    <Animations>
        <AnimationGroup looping="REPEAT">
            <Rotation degrees="-360" duration="1.0" smoothing="NONE"/>
        </AnimationGroup>
    </Animations>
</Texture>
```

---

## `<TextureCoordTranslation>`

> **Reference:** https://warcraft.wiki.gg/wiki/XML_schema#TextureCoordTranslation

Animates the texture coordinates of a `<Texture>`, effectively scrolling the texture image across the widget's surface. Useful for scrolling backgrounds or flowing effects.

Inherits from `<Animation>`. Specific attributes are not fully documented on the wiki.

---

## Animation Sequencing and Timing

### Order-Based Sequencing

Animations within an `<AnimationGroup>` are sequenced by their `order` attribute:

1. All animations with `order="1"` play simultaneously first.
2. When all `order="1"` animations finish, all `order="2"` animations begin simultaneously.
3. This continues through all order values up to 100.

```xml
<AnimationGroup>
    <!-- Phase 1: Fade in and slide up simultaneously -->
    <Alpha fromAlpha="0" toAlpha="1" duration="0.3" order="1"/>
    <Translation offsetX="0" offsetY="20" duration="0.3" order="1"/>

    <!-- Phase 2: Scale up after fade/slide completes -->
    <Scale fromScaleX="0.8" fromScaleY="0.8" toScaleX="1.0" toScaleY="1.0" duration="0.2" order="2"/>
</AnimationGroup>
```

### Delays

- `startDelay` — Adds a pause before the animation begins (within its order group).
- `endDelay` — Adds a pause after the animation finishes before the next order group starts.

### Looping

| Mode | Behavior |
|------|----------|
| `NONE` | Plays once and stops. |
| `REPEAT` | Plays forward continuously. Fires `OnLoop` at each restart. |
| `BOUNCE` | Plays forward, then backward, then forward again. |

### Playing Animations from Lua

```lua
-- Start
frame.FadeIn:Play()

-- Stop
frame.FadeIn:Stop()

-- Check if playing
if frame.FadeIn:IsPlaying() then ... end
```

---

## Complete Example: Animated Frame Entrance

```xml
<Frame name="MyAddon_AnimatedFrame" parent="UIParent" hidden="true">
    <Size x="200" y="100"/>
    <Anchors>
        <Anchor point="CENTER"/>
    </Anchors>
    <Layers>
        <Layer level="BACKGROUND">
            <Texture setAllPoints="true">
                <Color r="0" g="0" b="0" a="0.8"/>
            </Texture>
        </Layer>
        <Layer level="ARTWORK">
            <FontString parentKey="Title" inherits="GameFontNormalLarge" text="Hello!">
                <Anchors>
                    <Anchor point="CENTER"/>
                </Anchors>
            </FontString>
        </Layer>
    </Layers>
    <Animations>
        <AnimationGroup parentKey="ShowAnim" setToFinalAlpha="true">
            <!-- Fade in -->
            <Alpha fromAlpha="0" toAlpha="1" duration="0.3" order="1" smoothing="OUT"/>
            <!-- Slide down from above -->
            <Translation offsetX="0" offsetY="30" duration="0.3" order="1" smoothing="OUT"/>
            <Scripts>
                <OnPlay>
                    self:GetParent():Show()
                </OnPlay>
            </Scripts>
        </AnimationGroup>
        <AnimationGroup parentKey="HideAnim" setToFinalAlpha="true">
            <!-- Fade out -->
            <Alpha fromAlpha="1" toAlpha="0" duration="0.2" order="1" smoothing="IN"/>
            <Scripts>
                <OnFinished>
                    self:GetParent():Hide()
                </OnFinished>
            </Scripts>
        </AnimationGroup>
    </Animations>
</Frame>
```

```lua
-- Show with animation
MyAddon_AnimatedFrame.ShowAnim:Play()

-- Hide with animation
MyAddon_AnimatedFrame.HideAnim:Play()
```
