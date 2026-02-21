# Texture Widget Types (Curated)

Texture regions render images, solid colors, gradients, atlases, and lines. This reference highlights common methods and patterns. For full lists, see the Widget API page.

> Source: https://warcraft.wiki.gg/wiki/Widget_API
> Current as of: Patch 12.0.0 (Retail)

## TextureBase (core)

Common methods you will use most:

- `SetTexture(fileOrFileID, wrapModeH, wrapModeV, filterMode)`
- `SetAtlas(atlasName, useAtlasSize, filterMode, resetTexCoords)`
- `SetColorTexture(r, g, b, a)`
- `SetTexCoord(left, right, top, bottom)`
- `SetRotation(radians, normalizedRotationPoint)`
- `SetBlendMode(blendMode)`
- `SetDesaturated(trueOrFalse)`
- `SetMask(maskTexture)`

Notes:
- `SetAtlas` is preferred for UI textures packaged as atlases.
- `SetTexCoord` can crop or flip textures.

## Texture

Texture-specific helpers:

- `AddMaskTexture(maskTexture)`
- `RemoveMaskTexture(maskTexture)`
- `GetNumMaskTextures()`

## MaskTexture

MaskTexture adds no extra methods beyond TextureBase.

## Line

Common line methods:

- `SetStartPoint(point, relativeTo, offsetX, offsetY)`
- `SetEndPoint(point, relativeTo, offsetX, offsetY)`
- `SetThickness(pixels)`
- `SetHitRectThickness(pixels)`
- `ClearAllPoints()`

## Examples

### Atlas Texture With Cropping
```lua
local tex = frame:CreateTexture(nil, "ARTWORK")
tex:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn")
tex:SetTexCoord(0.1, 0.9, 0.1, 0.9)
tex:SetPoint("CENTER")
tex:SetSize(64, 64)
```

### Solid Color Backdrop
```lua
local bg = frame:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints(frame)
bg:SetColorTexture(0, 0, 0, 0.6)
```

### Line Between Two Frames
```lua
local line = frame:CreateLine(nil, "OVERLAY")
line:SetThickness(2)
line:SetStartPoint("LEFT", leftFrame, 0, 0)
line:SetEndPoint("RIGHT", rightFrame, 0, 0)
```