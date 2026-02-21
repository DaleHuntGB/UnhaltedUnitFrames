# Base Widget Types (Curated)

Base types underpin all widgets. This reference highlights core methods and patterns. For full lists, see the Widget API page.

> Source: https://warcraft.wiki.gg/wiki/Widget_API
> Script handlers: https://warcraft.wiki.gg/wiki/Widget_script_handlers
> Current as of: Patch 12.0.0 (Retail)

## FrameScriptObject (root)

| Method | Purpose |
| --- | --- |
| `GetName` | Returns the global name (can be nil). |
| `GetObjectType` | Returns the widget type string. |
| `IsObjectType` | Checks inheritance by type name. |
| `IsForbidden` | True if insecure access is blocked. |
| `SetToDefaults` | Resets to default state. |

## Object

| Method | Purpose |
| --- | --- |
| `GetParent` | Returns the parent object. |
| `GetParentKey` | Returns the key used on the parent. |
| `SetParentKey` | Sets a key on the parent to this object. |
| `ClearParentKey` | Clears the parent key. |
| `GetDebugName` | Useful name for debugging and logs. |

## ScriptObject (scripts)

| Method | Purpose |
| --- | --- |
| `SetScript` | Sets a script handler, replacing any existing handler. |
| `HookScript` | Adds a post-hook without replacing the handler. |
| `GetScript` | Returns the current handler. |
| `HasScript` | True if the script type is supported. |

Tip: prefer `HookScript` when extending Blizzard UI frames.

## ScriptRegion (visibility and input)

| Method | Purpose |
| --- | --- |
| `Show`, `Hide`, `SetShown` | Toggle visibility. |
| `IsShown`, `IsVisible` | Query visibility state. |
| `EnableMouse`, `EnableMouseWheel` | Enable mouse input. |
| `IsMouseOver` | Hit test the cursor. |
| `SetParent` | Reparent the region. |
| `IsProtected` | Check protected state. |

## ScriptRegionResizing (anchors and size)

| Method | Purpose |
| --- | --- |
| `SetPoint` | Anchor to another region. |
| `ClearAllPoints` | Remove all anchors. |
| `SetAllPoints` | Match another region. |
| `SetSize`, `SetWidth`, `SetHeight` | Size the region. |
| `GetPoint`, `GetNumPoints` | Inspect anchors. |

Anchor point names: `TOPLEFT`, `TOP`, `TOPRIGHT`, `LEFT`, `CENTER`, `RIGHT`, `BOTTOMLEFT`, `BOTTOM`, `BOTTOMRIGHT`.

## AnimatableObject

| Method | Purpose |
| --- | --- |
| `CreateAnimationGroup` | Create an AnimationGroup on this region. |
| `GetAnimationGroups` | List animation groups. |
| `StopAnimating` | Stops all animations. |

## Region (visual properties)

| Method | Purpose |
| --- | --- |
| `SetAlpha`, `GetAlpha` | Opacity control. |
| `SetDrawLayer` | Choose draw layer. |
| `SetScale` | Scale the region. |
| `SetVertexColor` | Color tint. |
| `SetIgnoreParentAlpha` | Ignore parent alpha. |
| `SetIgnoreParentScale` | Ignore parent scale. |
| `GetEffectiveScale` | Final scale after parenting. |

## Patterns and Examples

### Anchor and Size
```lua
local f = CreateFrame("Frame", nil, UIParent)
f:SetPoint("CENTER")
f:SetSize(200, 120)
```

### Hover Highlight Using Scripts
```lua
local f = CreateFrame("Frame", nil, UIParent)
f:SetSize(160, 40)
f:SetPoint("CENTER")
f:EnableMouse(true)

f:SetScript("OnEnter", function(self)
    self:SetAlpha(1)
end)
f:SetScript("OnLeave", function(self)
    self:SetAlpha(0.7)
end)
```

### Extend an Existing Script Handler
```lua
local f = CreateFrame("Frame", nil, UIParent)
f:HookScript("OnShow", function(self)
    print("Shown", self:GetName())
end)
```