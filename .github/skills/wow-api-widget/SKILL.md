---
name: wow-api-widget
description: "Curated guide to the WoW Widget API (Retail). Focuses on core widget types, common methods, and patterns for CreateFrame, anchoring, scripts, textures, fonts, animations, and UI controls."
---

# WoW Widget API (Curated)

This skill documents the Widget API for World of Warcraft Retail. It is curated: it highlights the core types, methods, and patterns you use most. For exhaustive lists, follow the source links.

> Source of truth: https://warcraft.wiki.gg/wiki/Widget_API
> Script handlers: https://warcraft.wiki.gg/wiki/Widget_script_handlers
> XML schema: https://warcraft.wiki.gg/wiki/XML_schema
> Current as of: Patch 12.0.0 (Retail)

## When to Use This Skill

Use this skill when you need to:
- Create or manipulate UI frames (`CreateFrame`, `Frame:SetPoint`, `Frame:Show`)
- Work with textures and visual regions (`Texture:SetTexture`, `TextureBase:SetAtlas`)
- Handle font strings and text display (`FontString:SetText`, `FontInstance:SetFont`)
- Build animations (`AnimationGroup:Play`, `Animation:SetDuration`)
- Manage tooltips (`GameTooltip:SetOwner`, `GameTooltip:AddLine`)
- Handle buttons and interactive controls (`Button:SetText`, `EditBox:SetText`, `Slider:SetValue`)
- Work with status bars and cooldowns (`StatusBar:SetValue`, `Cooldown:SetCooldown`)
- Use model frames for 3D displays (`Model:SetModel`, `ModelScene:CreateActor`)
- Anchor, size, show or hide, and parent UI elements
- Register frames for events (`Frame:RegisterEvent`, `Frame:RegisterUnitEvent`)
- Set up script handlers (`ScriptObject:SetScript`, `ScriptObject:HookScript`)

## Widget Hierarchy (Short)

```
FrameScriptObject
  Object
    ScriptObject
      ScriptRegion (+ ScriptRegionResizing + AnimatableObject)
        Region
          TextureBase -> Texture, MaskTexture, Line
          FontString (+ FontInstance)
        Frame (+ FontInstance)
          Button -> CheckButton
          EditBox, MessageFrame, ScrollFrame, Slider, StatusBar, Cooldown
          GameTooltip, SimpleHTML, ColorSelect, MovieFrame
          Model -> PlayerModel -> CinematicModel, DressUpModel -> TabardModel
          ModelScene -> ModelSceneActor

AnimationGroup -> Animation -> Alpha, Rotation, Scale, Translation, Path, FlipBook
Font (FrameScriptObject + FontInstance)
```

## How to Use This Skill

1. Identify the widget type you are working with (for example: `Frame`, `Texture`, `Button`).
2. Check the hierarchy above to find base types it inherits from.
3. Open the relevant reference file for core methods and examples.
4. Use the source links for exhaustive method lists.

## Reference Files

| Reference | Contents |
|-----------|----------|
| [BASE-WIDGETS.md](references/BASE-WIDGETS.md) | Base types, anchoring, input, scripts, visibility |
| [TEXTURE-WIDGETS.md](references/TEXTURE-WIDGETS.md) | TextureBase, Texture, MaskTexture, Line |
| [FONT-WIDGETS.md](references/FONT-WIDGETS.md) | FontInstance, Font, FontString |
| [ANIMATION-WIDGETS.md](references/ANIMATION-WIDGETS.md) | AnimationGroup, Animation, Alpha, Rotation, Scale, Translation, Path |
| [FRAME-WIDGETS.md](references/FRAME-WIDGETS.md) | Frame core behavior, events, layering, movement |
| [FRAME-CONTROLS.md](references/FRAME-CONTROLS.md) | Button, CheckButton, EditBox, ScrollFrame, Slider, StatusBar, Cooldown, MessageFrame, SimpleHTML |
| [ADVANCED-WIDGETS.md](references/ADVANCED-WIDGETS.md) | GameTooltip, Model/PlayerModel, ModelScene, ColorSelect, MovieFrame |

## Core Patterns

### Create and Anchor
```lua
local frame = CreateFrame("Frame", "MyFrame", UIParent, "BackdropTemplate")
frame:SetSize(240, 120)
frame:SetPoint("CENTER")

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", 0, -12)
title:SetText("Hello")
```

### Events and Scripts
```lua
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function(self, event)
    print("Ready", event)
end)
```

### Buttons
```lua
local btn = CreateFrame("Button", nil, UIParent, "UIPanelButtonTemplate")
btn:SetSize(120, 32)
btn:SetPoint("CENTER")
btn:SetText("Click")
btn:RegisterForClicks("AnyUp")
btn:SetScript("OnClick", function(self, button)
    print("Clicked", button)
end)
```

### Animations
```lua
local ag = frame:CreateAnimationGroup()
local fade = ag:CreateAnimation("Alpha")
fade:SetFromAlpha(0)
fade:SetToAlpha(1)
fade:SetDuration(0.25)
ag:Play()
```

## XML Schema Quickstart

```xml
<Ui>
  <Frame name="MyXmlFrame" parent="UIParent" hidden="true">
    <Size x="240" y="120"/>
    <Anchors>
      <Anchor point="CENTER"/>
    </Anchors>
    <Scripts>
      <OnLoad>
        self:RegisterEvent("PLAYER_LOGIN")
      </OnLoad>
      <OnEvent>
        print(event)
      </OnEvent>
    </Scripts>
  </Frame>
</Ui>
```

## Script Handlers Quick Map

- ScriptRegion: `OnShow`, `OnHide`, `OnEnter`, `OnLeave`, `OnMouseDown`, `OnMouseUp`, `OnMouseWheel`
- Frame: `OnEvent`, `OnUpdate`, `OnSizeChanged`, `OnDragStart`, `OnDragStop`, `OnKeyDown`, `OnKeyUp`
- Button: `OnClick`, `OnDoubleClick`, `PreClick`, `PostClick`
- EditBox: `OnTextChanged`, `OnEnterPressed`, `OnEscapePressed`, `OnTabPressed`
- Slider/StatusBar: `OnValueChanged`, `OnMinMaxChanged`
- AnimationGroup/Animation: `OnPlay`, `OnStop`, `OnFinished`, `OnUpdate`

For the full handler list by widget type, see https://warcraft.wiki.gg/wiki/Widget_script_handlers.

## Specialized Widgets (Summary)

For advanced widgets (GameTooltip, Model, ModelScene, ColorSelect, MovieFrame), see [ADVANCED-WIDGETS.md](references/ADVANCED-WIDGETS.md).
Use the Widget API page for full method lists and specialized widget details.

## Security Annotations

Methods tagged in the API reference have usage restrictions:
- `#protected` - Blizzard secure code only.
- `#secureframe` - Not callable on protected frames during combat.
- `#nocombat` - Not callable during combat lockdown.
- `#restrictedframe` - Returns nil for protected frames from insecure code in combat.
- `#anchorfamily` - Anchor family restrictions apply.

## Sources

- https://warcraft.wiki.gg/wiki/Widget_API
- https://warcraft.wiki.gg/wiki/Widget_script_handlers
- https://warcraft.wiki.gg/wiki/XML_schema