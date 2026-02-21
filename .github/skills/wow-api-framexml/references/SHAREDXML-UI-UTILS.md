# SharedXML — UI & Frame Utilities

> **Parent skill:** [wow-api-framexml](../SKILL.md)
> **Source:** [FrameXML functions — SharedXML](https://warcraft.wiki.gg/wiki/FrameXML_functions#SharedXML)
> **Source:** [FrameXML functions — SharedXMLBase](https://warcraft.wiki.gg/wiki/FrameXML_functions#SharedXMLBase)
> **Source:** [FrameXML functions — SharedXMLGame](https://warcraft.wiki.gg/wiki/FrameXML_functions#SharedXMLGame)
> **FrameXML source:** [SharedXML on GitHub](https://github.com/Gethe/wow-ui-source/tree/live/Interface/SharedXML)

This file covers SharedXML modules related to **frames, anchors, textures, animations, tooltips, pixels, layout, and regions**.

---

## AnchorUtil

Source: [AnchorUtil (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=CreateAnchor)

Functions for creating anchor points and performing grid layouts.

### `AnchorUtil.CreateAnchor(point, relativeTo, relativePoint, x, y)`
Creates an AnchorMixin describing a single anchor point.

```lua
local anchor = AnchorUtil.CreateAnchor("TOPLEFT", UIParent, "TOPLEFT", 10, -10)
```

### `AnchorUtil.CreateGridLayout(direction, rowSize, spacingX, spacingY)`
Creates a grid layout descriptor used by `GridLayout`.

```lua
local layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRight, 4, 5, 5)
```

**Arguments:**
- `direction` (number) — Layout direction constant from `GridLayoutMixin.Direction`.
- `rowSize` (number) — Number of items per row.
- `spacingX` (number) — Horizontal spacing between items.
- `spacingY` (number) — Vertical spacing between items.

### `AnchorUtil.CreateAnchorFromPoint(region, pointIndex)`
Creates an AnchorMixin from an existing region's anchor point.

### `AnchorUtil.GridLayout(frames, initialAnchor, layout)`
Arranges an array of frames in a grid using the specified anchor and layout.

```lua
AnchorUtil.GridLayout(myFrames, initialAnchor, gridLayout)
```

### `AnchorUtil.GridLayoutFactoryByCount(factoryFunction, count, initialAnchor, layout)`
Creates `count` frames via `factoryFunction` and arranges them in a grid.

### `AnchorUtil.GridLayoutFactory(factoryFunction, initialAnchor, totalWidth, totalHeight, overrideDirection, overridePaddingX, overridePaddingY)`
Creates frames via factory until the total size is filled.

### `AnchorUtil.MirrorRegionsAlongVerticalAxis(mirrorDescriptions)`
Mirrors a set of regions along the vertical axis.

### `AnchorUtil.MirrorRegionsAlongHorizontalAxis(mirrorDescriptions)`
Mirrors a set of regions along the horizontal axis.

---

## FrameUtil (SharedXMLBase)

Source: [FrameXML functions — SharedXMLBase FrameUtil](https://warcraft.wiki.gg/wiki/FrameXML_functions#FrameUtil)

### `UIFrameFadeIn(frame, timeToFade, startAlpha, endAlpha)`
Detailed Reference: [API UIFrameFadeIn](https://warcraft.wiki.gg/wiki/API_UIFrameFadeIn)

Fades a frame in over time.

```lua
UIFrameFadeIn(myFrame, 0.5, 0, 1)  -- fade from invisible to fully opaque in 0.5s
```

**Arguments:**
- `frame` (Frame) — The frame to fade.
- `timeToFade` (number) — Duration in seconds.
- `startAlpha` (number) — Starting alpha (0–1).
- `endAlpha` (number) — Ending alpha (0–1).

### `UIFrameFadeOut(frame, timeToFade, startAlpha, endAlpha)`
Detailed Reference: [API UIFrameFadeOut](https://warcraft.wiki.gg/wiki/API_UIFrameFadeOut)

Fades a frame out over time. The frame is typically hidden when alpha reaches 0.

```lua
UIFrameFadeOut(myFrame, 0.3, 1, 0)
```

---

## FrameUtil (SharedXML)

Source: [FrameUtil (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=RegisterFrameForEvents)

### `FrameUtil.RegisterFrameForEvents(frame, events)`
Registers a frame for multiple events at once from a table.

```lua
FrameUtil.RegisterFrameForEvents(myFrame, {"PLAYER_LOGIN", "PLAYER_LOGOUT", "ZONE_CHANGED"})
```

### `FrameUtil.UnregisterFrameForEvents(frame, events)`
Unregisters a frame from multiple events at once.

```lua
FrameUtil.UnregisterFrameForEvents(myFrame, {"PLAYER_LOGIN", "PLAYER_LOGOUT"})
```

### `FrameUtil.RegisterFrameForUnitEvents(frame, events, ...)`
Registers a frame for unit-specific events.

```lua
FrameUtil.RegisterFrameForUnitEvents(myFrame, {"UNIT_HEALTH", "UNIT_AURA"}, "player", "target")
```

### `DoesAncestryInclude(ancestry, frame)`
Checks if `frame` is a descendant of `ancestry`.

```lua
isChild = DoesAncestryInclude(UIParent, myFrame)
```

### `GetUnscaledFrameRect(frame, scale)`
Returns the frame's rect without UI scaling applied.

### `ApplyDefaultScale(frame, minScale, maxScale)`
Applies the default UI scale to a frame, clamped to min/max.

### `UpdateScaleForFit(frame)`
Updates a frame's scale so it fits within the screen.

---

## GameTooltipTemplate

Source: [GameTooltipTemplate (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=GameTooltip_AddBlankLineToTooltip)

Helper functions for building tooltip content. These wrap `tooltip:AddLine()` with consistent formatting.

### `GameTooltip_SetTitle(tooltip, text, overrideColor, wrap)`
Sets the tooltip's title line (first line, usually larger font).

```lua
GameTooltip_SetTitle(GameTooltip, "My Item")
```

### `GameTooltip_AddNormalLine(tooltip, text, wrap, leftOffset)`
Adds a line in normal (white) text.

```lua
GameTooltip_AddNormalLine(GameTooltip, "This is a normal line.")
```

### `GameTooltip_AddHighlightLine(tooltip, text, wrap, leftOffset)`
Adds a line in highlight (yellow) text.

### `GameTooltip_AddColoredLine(tooltip, text, color, wrap, leftOffset)`
Adds a line with a custom ColorMixin color.

```lua
GameTooltip_AddColoredLine(GameTooltip, "Green text!", CreateColor(0, 1, 0))
```

### `GameTooltip_AddColoredDoubleLine(tooltip, leftText, rightText, leftColor, rightColor, wrap, leftOffset)`
Adds a double-column line with independent colors for left and right text.

### `GameTooltip_AddErrorLine(tooltip, text, wrap, leftOffset)`
Adds a line in error (red) text.

### `GameTooltip_AddDisabledLine(tooltip, text, wrap, leftOffset)`
Adds a line in disabled (gray) text.

### `GameTooltip_AddInstructionLine(tooltip, text, wrap, leftOffset)`
Adds a line in instruction (green) text.

### `GameTooltip_AddBodyLine(tooltip, ...)`
Adds a body line (standard formatting).

### `GameTooltip_AddBlankLineToTooltip(tooltip)`
Adds a single blank line to the tooltip.

### `GameTooltip_AddBlankLinesToTooltip(tooltip, numLines)`
Adds multiple blank lines.

### `GameTooltip_AddNewbieTip(frame, normalText, r, g, b, newbieText, noNormalText)`
Adds a "newbie tip" (tutorial/help tooltip) to a frame.

### `GameTooltip_InsertFrame(tooltipFrame, frame, verticalPadding)`
Inserts an embedded frame into a tooltip (e.g., for inline icons or bars).

### `GameTooltip_ShowDisabledTooltip(tooltip, owner, text, tooltipAnchor)`
Shows a tooltip indicating why something is disabled.

### `GameTooltip_ShowSimpleTooltip(tooltip, text, overrideColor, wrap, owner, point, offsetX, offsetY)`
Shows a minimal tooltip with just text.

---

## NineSlice

Source: [NineSlice (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=ApplyUniqueCornersLayout)

Nine-slice texture layout system for scalable bordered frames.

### `NineSliceUtil.ApplyLayout(container, userLayout, textureKit)`
Applies a nine-slice layout to a container frame.

```lua
NineSliceUtil.ApplyLayout(myFrame, nineSliceLayout, "Oribos")
```

### `NineSliceUtil.ApplyLayoutByName(container, userLayoutName, textureKit)`
Like `ApplyLayout` but looks up the layout by name from a registry.

### `NineSliceUtil.ApplyUniqueCornersLayout(self, textureKit)`
Applies a layout where each corner has a unique texture.

### `NineSliceUtil.ApplyIdenticalCornersLayout(self, textureKit)`
Applies a layout where all corners use the same texture.

### `NineSliceUtil.GetLayout(layoutName)`
Returns a registered nine-slice layout by name.

### `NineSliceUtil.AddLayout(layoutName, layout)`
Registers a new nine-slice layout.

### `NineSliceUtil.DisableSharpening(container)`
Disables texture sharpening on all nine-slice pieces.

---

## PixelUtil

Source: [PixelUtil (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=GetPixelToUIUnitFactor)

Functions for pixel-perfect UI rendering that accounts for UI scale.

### `PixelUtil.GetPixelToUIUnitFactor()`
Returns the conversion factor from physical pixels to UI units.

```lua
factor = PixelUtil.GetPixelToUIUnitFactor()
```

### `PixelUtil.GetNearestPixelSize(uiUnitSize, layoutScale, minPixels)`
Snaps a UI size to the nearest physical pixel boundary.

```lua
size = PixelUtil.GetNearestPixelSize(1, myFrame:GetEffectiveScale(), 1)
```

### `PixelUtil.SetWidth(region, width, minPixels)`
Sets pixel-perfect width.

```lua
PixelUtil.SetWidth(myFrame, 200)
```

### `PixelUtil.SetHeight(region, height, minPixels)`
Sets pixel-perfect height.

### `PixelUtil.SetSize(region, width, height, minWidthPixels, minHeightPixels)`
Sets pixel-perfect width and height.

### `PixelUtil.SetPoint(region, point, relativeTo, relativePoint, offsetX, offsetY, minOffsetXPixels, minOffsetYPixels)`
Sets a pixel-perfect anchor point.

### `PixelUtil.SetStatusBarValue(statusBar, value)`
Sets a pixel-perfect status bar value.

---

## RegionUtil

Source: [RegionUtil (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=IsDescendantOf)

Functions for querying relationships and distances between UI regions.

### `RegionUtil.IsDescendantOf(potentialDescendant, potentialAncestor)`
Returns true if the first region is a descendant of the second.

```lua
isChild = RegionUtil.IsDescendantOf(myButton, myParentFrame)
```

### `RegionUtil.IsDescendantOfOrSame(potentialDescendant, potentialAncestorOrSame)`
Like `IsDescendantOf` but also returns true if both are the same region.

### `RegionUtil.CalculateDistanceSqBetween(region1, region2)`
Returns the squared distance between two regions' centers.

### `RegionUtil.CalculateDistanceBetween(region1, region2)`
Returns the Euclidean distance between two regions' centers.

### `RegionUtil.CalculateAngleBetween(region1, region2)`
Returns the angle in radians between two regions' centers.

---

## ScriptAnimationUtil

Source: [ScriptAnimationUtil (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=ShakeFrameRandom)

Lua-driven animation system (alternative to XML `AnimationGroup`).

### `ScriptAnimationUtil.ShakeFrameRandom(region, magnitude, duration, frequency)`
Applies a random shake effect to a frame (e.g., for damage feedback).

```lua
ScriptAnimationUtil.ShakeFrameRandom(myFrame, 5, 0.5, 0.05)
```

**Arguments:**
- `region` (Region) — The frame to shake.
- `magnitude` (number) — Maximum pixel displacement.
- `duration` (number) — How long the shake lasts in seconds.
- `frequency` (number) — Time between shake updates in seconds.

### `ScriptAnimationUtil.ShakeFrame(region, shake, maximumDuration, frequency)`
Applies a deterministic shake pattern.

### `ScriptAnimationUtil.GetScriptAnimationLock(region)`
Acquires an animation lock on a region (prevents other script animations from running).

### `ScriptAnimationUtil.ReleaseScriptAnimationLock(region)`
Releases the animation lock.

### `ScriptAnimationUtil.IsScriptAnimationLockActive(region)`
Checks if a region has an active animation lock.

### `ScriptAnimationUtil.GenerateEasedVariationCallback(easingFunction, distanceX, distanceY, alpha, scale)`
Generates a variation callback with easing for use with `StartScriptAnimation`.

### `ScriptAnimationUtil.StartScriptAnimation(region, variationCallback, duration, onFinish)`
Starts a custom script-driven animation on a region.

```lua
local variationCB = ScriptAnimationUtil.GenerateEasedVariationCallback(
    EasingUtil.InOutCubic, 50, 0, nil, nil
)
ScriptAnimationUtil.StartScriptAnimation(myFrame, variationCB, 1.0, function()
    print("Animation done!")
end)
```

---

## ScriptedAnimationEffects

Source: [ScriptedAnimationEffects (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=GetEffectByID)

### `ScriptedAnimationEffectsUtil.GetEffectByID(effectID)`
Returns the effect data table for a scripted animation effect by its ID.

### `ScriptedAnimationEffectsUtil.ReloadDB()`
Reloads the scripted animation effects database.

---

## TextureUtil

Source: [TextureUtil (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=CreateAtlasMarkup)

Functions for creating texture markup strings and manipulating textures.

### `CreateAtlasMarkup(atlasName [, height, width, offsetX, offsetY])`
Returns a texture escape sequence string for an atlas, suitable for embedding in FontStrings.

```lua
local markup = CreateAtlasMarkup("services-icon-warning", 16, 16)
-- Result: "|A:services-icon-warning:16:16|a"
```

### `CreateTextureMarkup(file, fileWidth, fileHeight, width, height, left, right, top, bottom [, xOffset, yOffset])`
Returns a texture escape sequence string for a specific texture file with tex coords.

```lua
local markup = CreateTextureMarkup("Interface\\Icons\\INV_Misc_QuestionMark", 64, 64, 16, 16, 0, 1, 0, 1)
```

### `CreateSimpleTextureMarkup(file, width, height, xOffset, yOffset)`
Simplified version of `CreateTextureMarkup` without tex coord parameters.

### `GetTextureInfo(obj)`
Returns type and info of a texture object.

### `SetClampedTextureRotation(texture, rotationDegrees)`
Rotates a texture (only supports 0, 90, 180, 270 degree rotations).

### `ClearClampedTextureRotation(texture)`
Resets a clamped texture rotation to 0.

### `GetTexCoordsByGrid(xOffset, yOffset, textureWidth, textureHeight, gridWidth, gridHeight)`
Calculates tex coords for a specific cell in a grid-based texture atlas.

```lua
local left, right, top, bottom = GetTexCoordsByGrid(2, 3, 256, 256, 64, 64)
```

### `GetTexCoordsForRole(role)`
Returns tex coords for role icons (TANK, HEALER, DAMAGER).

```lua
local left, right, top, bottom = GetTexCoordsForRole("TANK")
```

### `SetupAtlasesOnRegions(frame, regionsToAtlases, useAtlasSize)`
Applies atlas textures to multiple regions on a frame from a lookup table.

### `GetFinalNameFromTextureKit(fmt, textureKits)`
Resolves a texture kit format string.

### `SetupTextureKitOnFrame(textureKit, frame, fmt, setVisibility, useAtlasSize)`
Applies a texture kit's atlas to a single frame.

### `SetupTextureKitOnFrames(textureKit, frames, setVisibilityOfRegions, useAtlasSize)`
Applies a texture kit to multiple frames.

### `SetupTextureKitOnRegions(textureKit, frame, regions, setVisibilityOfRegions, useAtlasSize)`
Applies a texture kit to named child regions of a frame.

### `SetupTextureKitsFromRegionInfo(textureKit, frame, regionInfoList)`
Applies texture kits using a detailed region info list.

---

## TooltipUtil

Source: [TooltipUtil (FrameXML)](https://www.townlong-yak.com/framexml/go/TooltipUtil.ShouldDoItemComparison)

Utility functions for tooltip data extraction and comparison.

### `TooltipUtil.ShouldDoItemComparison()`
Returns whether item comparison tooltips should be shown (based on modifier keys and settings).

### `TooltipUtil.GetDisplayedItem(tooltip)`
Returns the item link and count currently displayed in a tooltip.

```lua
local itemLink, count = TooltipUtil.GetDisplayedItem(GameTooltip)
```

### `TooltipUtil.GetDisplayedSpell(tooltip)`
Returns the spell ID currently displayed in a tooltip.

### `TooltipUtil.GetDisplayedUnit(tooltip)`
Returns the unit displayed in a tooltip.

### `TooltipUtil.FindLinesFromGetter(lineTypeTable, getterName, ...)`
Searches tooltip lines using a getter function.

### `TooltipUtil.FindLinesFromData(lineTypeTable, tooltipData)`
Searches tooltip lines from raw tooltip data.

### `TooltipUtil.DebugCopyGameTooltip()`
Debug function that copies the current GameTooltip contents to clipboard.
