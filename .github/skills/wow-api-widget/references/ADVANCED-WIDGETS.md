# Advanced Widgets (Curated)

This reference covers advanced or specialized widgets that come up less often, but need extra context. For full lists, use the linked source pages.

> Source: https://warcraft.wiki.gg/wiki/Widget_API
> Script handlers: https://warcraft.wiki.gg/wiki/Widget_script_handlers
> Current as of: Patch 12.0.0 (Retail)

## GameTooltip

Core methods:

- `SetOwner(owner, anchor)`
- `SetText(text)`
- `AddLine(text, r, g, b)`
- `AddDoubleLine(leftText, rightText, r, g, b, r2, g2, b2)`
- `SetHyperlink(link)`
- `Show()` and `Hide()`

Example: show a tooltip on hover.

```lua
local btn = CreateFrame("Button", nil, UIParent, "UIPanelButtonTemplate")
btn:SetPoint("CENTER")
btn:SetSize(120, 32)
btn:SetText("Hover me")

btn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Example tooltip")
    GameTooltip:AddLine("More details", 1, 1, 1)
    GameTooltip:Show()
end)
btn:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)
```

## Model and PlayerModel

Model renders a 3D file. PlayerModel extends Model with unit-based setup.

Common patterns:

- `Model:SetModel(fileOrFileID)`
- `Model:ClearModel()`
- `PlayerModel:SetUnit(unitToken)`

Example: show the player model.

```lua
local model = CreateFrame("PlayerModel", nil, UIParent)
model:SetPoint("CENTER")
model:SetSize(200, 300)
model:SetUnit("player")
```

## ModelScene and ModelSceneActor

ModelScene manages actors and camera settings for complex 3D setups.

Confirmed methods (see source for full list):

- `ModelScene:CreateActor(name, template)`
- `ModelScene:GetNumActors()`
- `ModelScene:SetCameraPosition(x, y, z)`

Example: create a scene and actor shell.

```lua
local scene = CreateFrame("ModelScene", nil, UIParent)
scene:SetPoint("CENTER")
scene:SetSize(300, 300)

local actor = scene:CreateActor()
-- Set model and animation on the actor (see UIOBJECT_ModelSceneActor for methods).
```

## ColorSelect

ColorSelect is the widget behind ColorPickerFrame and similar controls.

Common methods:

- `SetColorRGB(r, g, b)` and `GetColorRGB()`
- `SetColorHSV(h, s, v)` and `GetColorHSV()`
- `SetColorAlpha(alpha)` and `GetColorAlpha()`
- `SetColorWheelTexture(texture)`
- `SetColorWheelThumbTexture(texture)`
- `SetColorValueTexture(texture)`
- `SetColorValueThumbTexture(texture)`

Example: basic ColorSelect usage.

```lua
local cs = CreateFrame("ColorSelect", nil, UIParent)
cs:SetPoint("CENTER")
cs:SetSize(255, 152)
cs:SetColorRGB(1, 0, 0)
cs:SetScript("OnColorSelect", function(self, r, g, b)
    print(r, g, b)
end)
```

## MovieFrame

MovieFrame plays in-game movie assets.

Methods:

- `StartMovie(movieID, looping)`
- `StopMovie()`
- `EnableSubtitles(enable)`

Example: play a movie.

```lua
local f = CreateFrame("MovieFrame")
f:SetAllPoints(UIParent)
f:SetScript("OnUpdate", function() end) -- required to play
f:StartMovie(2)
```

## Sources

- https://warcraft.wiki.gg/wiki/UIOBJECT_GameTooltip
- https://warcraft.wiki.gg/wiki/UIOBJECT_Model
- https://warcraft.wiki.gg/wiki/UIOBJECT_PlayerModel
- https://warcraft.wiki.gg/wiki/UIOBJECT_ModelScene
- https://warcraft.wiki.gg/wiki/UIOBJECT_ModelSceneActor
- https://warcraft.wiki.gg/wiki/UIOBJECT_ColorSelect
- https://warcraft.wiki.gg/wiki/UIOBJECT_MovieFrame