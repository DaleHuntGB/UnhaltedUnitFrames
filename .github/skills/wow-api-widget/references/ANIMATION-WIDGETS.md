# Animation Widget Types (Curated)

Animations are non-visible objects that modify widget properties over time. This reference focuses on the core methods and patterns. For full lists, see the Widget API page.

> Source: https://warcraft.wiki.gg/wiki/Widget_API
> Current as of: Patch 12.0.0 (Retail)

## AnimationGroup

Core methods:

- `Play(reverse, offset)`
- `Stop()` and `Finish()`
- `SetLooping("NONE" | "REPEAT" | "BOUNCE")`
- `CreateAnimation(type, name, templateName)`
- `SetAnimationSpeedMultiplier(multiplier)`
- `SetToFinalAlpha(trueOrFalse)`

## Animation

Core methods:

- `SetDuration(seconds)`
- `SetOrder(order)`
- `SetStartDelay(seconds)` and `SetEndDelay(seconds)`
- `SetSmoothing("NONE" | "IN" | "OUT" | "IN_OUT")`
- `SetTarget(target)`

## Common Animation Types

- Alpha: `SetFromAlpha`, `SetToAlpha`
- Translation: `SetOffset(x, y)`
- Scale: `SetScaleFrom`, `SetScaleTo`
- Rotation: `SetDegrees` or `SetRadians`, `SetOrigin(point, x, y)`
- Path: `CreateControlPoint`, `SetCurveType`

## Examples

### Fade In
```lua
local ag = frame:CreateAnimationGroup()
local fade = ag:CreateAnimation("Alpha")
fade:SetFromAlpha(0)
fade:SetToAlpha(1)
fade:SetDuration(0.25)
ag:Play()
```

### Pulse Scale
```lua
local ag = frame:CreateAnimationGroup()
ag:SetLooping("BOUNCE")
local scale = ag:CreateAnimation("Scale")
scale:SetScaleFrom(1, 1)
scale:SetScaleTo(1.1, 1.1)
scale:SetDuration(0.3)
ag:Play()
```

### Slide In From Left
```lua
local ag = frame:CreateAnimationGroup()
local move = ag:CreateAnimation("Translation")
move:SetOffset(40, 0)
move:SetDuration(0.2)
move:SetSmoothing("OUT")
ag:Play()
```