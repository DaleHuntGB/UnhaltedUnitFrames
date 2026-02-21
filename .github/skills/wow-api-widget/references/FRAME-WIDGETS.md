# Frame Widget Type (Curated)

Frame is the core interactive widget type. This reference highlights common methods and patterns. For full lists, see the Widget API page.

> Source: https://warcraft.wiki.gg/wiki/Widget_API
> Current as of: Patch 12.0.0 (Retail)

## Creating Child Regions

- `CreateTexture(name, drawLayer, templateName, subLevel)`
- `CreateFontString(name, drawLayer, templateName)`
- `CreateMaskTexture(name, drawLayer, templateName, subLevel)`
- `CreateLine(name, drawLayer, templateName, subLevel)`

## Events and Scripts

- `RegisterEvent(event)`
- `RegisterUnitEvent(event, unit1, ...)`
- `UnregisterEvent(event)` and `UnregisterAllEvents()`
- `IsEventRegistered(event)`
- Use `SetScript("OnEvent", handler)` to handle events

## Layering and Visibility

- `SetFrameStrata(strata)`
- `SetFrameLevel(level)`
- `Raise()` and `Lower()`
- `SetToplevel(trueOrFalse)`

## Movement and Resizing

- `SetMovable(trueOrFalse)`
- `SetResizable(trueOrFalse)`
- `RegisterForDrag("LeftButton")`
- `StartMoving()` and `StopMovingOrSizing()`
- `SetResizeBounds(minW, minH, maxW, maxH)`

## Common Attributes (Secure)

- `SetAttribute(name, value)`
- `GetAttribute(name)`
- `ClearAttribute(name)` and `ClearAttributes()`

## Examples

### Basic Event Frame
```lua
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function(self, event)
    print("Ready", event)
end)
```

### Draggable Panel
```lua
local panel = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
panel:SetSize(240, 120)
panel:SetPoint("CENTER")
panel:EnableMouse(true)
panel:SetMovable(true)
panel:RegisterForDrag("LeftButton")
panel:SetScript("OnDragStart", panel.StartMoving)
panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
```

### Frame With Child Regions
```lua
local panel = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
panel:SetSize(200, 80)
panel:SetPoint("CENTER")

local bg = panel:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints(panel)
bg:SetColorTexture(0, 0, 0, 0.5)

local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", 0, -10)
title:SetText("Panel")
```