# Widget Script Handlers

Complete reference for all widget script handlers (callbacks) available in the World of Warcraft UI framework. Script handlers allow addons to respond to user interaction and widget lifecycle events such as clicks, mouse movement, keyboard input, animation playback, and frame updates.

> **Source:** https://warcraft.wiki.gg/wiki/Widget_script_handlers
> **Current as of:** Patch 12.0.0 — Retail only.

---

## Overview

Script handlers are callback functions assigned to widgets via `SetScript()` or `HookScript()`. Each widget type supports a specific set of handlers determined by its position in the widget hierarchy. A handler on a parent type is inherited by all child types.

### Setting Handlers

```lua
-- Replace any existing handler
frame:SetScript("OnEvent", function(self, event, ...)
    -- handle event
end)

-- Add behavior without replacing existing handler (post-hook)
frame:HookScript("OnShow", function(self)
    -- runs after the original OnShow handler
end)

-- Remove a handler
frame:SetScript("OnUpdate", nil)

-- Check if a widget supports a handler
if frame:HasScript("OnClick") then
    frame:SetScript("OnClick", myClickHandler)
end
```

### XML Declaration

```xml
<Frame name="MyFrame">
    <Scripts>
        <OnLoad>
            self:RegisterEvent("PLAYER_LOGIN")
        </OnLoad>
        <OnEvent>
            if event == "PLAYER_LOGIN" then
                print("Hello!")
            end
        </OnEvent>
    </Scripts>
</Frame>
```

In XML script bodies, `self` refers to the widget and all handler arguments are available as implicit local variables (e.g., `event`, `button`, `elapsed`).

> **Reference:** https://warcraft.wiki.gg/wiki/Widget_script_handlers
> **SetScript API:** https://warcraft.wiki.gg/wiki/API_ScriptObject_SetScript
> **HookScript API:** https://warcraft.wiki.gg/wiki/API_ScriptObject_HookScript

---

## Handler Inheritance

Handlers are inherited through the widget type hierarchy. Understanding which handlers are available requires knowing the widget's ancestry:

```
AnimationGroup ← OnFinished, OnLoop, OnPause, OnPlay, OnStop, OnUpdate, OnLoad
Animation      ← OnFinished, OnPause, OnPlay, OnStop, OnUpdate, OnLoad
ScriptRegion   ← OnShow, OnHide, OnEnter, OnLeave, OnMouseDown, OnMouseUp, OnMouseWheel, OnLoad
Frame          ← (inherits ScriptRegion) + OnEvent, OnUpdate, OnChar, OnKeyDown, OnKeyUp,
                  OnDragStart, OnDragStop, OnReceiveDrag, OnSizeChanged, OnAttributeChanged,
                  OnHyperlinkClick, OnHyperlinkEnter, OnHyperlinkLeave, OnEnable, OnDisable,
                  OnGamePadButtonDown, OnGamePadButtonUp, OnGamePadStick
Button         ← (inherits Frame) + OnClick, OnDoubleClick, PreClick, PostClick
EditBox        ← (inherits Frame) + OnEnterPressed, OnEscapePressed, OnSpacePressed, OnTabPressed,
                  OnTextChanged, OnTextSet, OnCursorChanged, OnEditFocusGained, OnEditFocusLost,
                  OnCharComposition, OnArrowPressed, OnInputLanguageChanged
```

> **Widget hierarchy diagram:** https://warcraft.wiki.gg/wiki/Widget_API

---

## AnimationGroup Handlers

Handlers for `AnimationGroup` objects. AnimationGroups manage collections of animations and control their playback.

> **Widget reference:** https://warcraft.wiki.gg/wiki/UIOBJECT_AnimationGroup

| Handler | Signature | Description |
|---------|-----------|-------------|
| OnFinished | `OnFinished(self, requested)` | Invoked when the animation group finishes animating. `requested` is true if the stop was explicitly requested via `:Stop()`. |
| OnLoop | `OnLoop(self, loopState)` | Invoked when the animation group's loop state changes. `loopState` is `"NONE"`, `"FORWARD"`, or `"REVERSE"`. |
| OnPause | `OnPause(self)` | Invoked when the animation group is paused via `:Pause()`. |
| OnPlay | `OnPlay(self)` | Invoked when the animation group begins to play via `:Play()`. |
| OnStop | `OnStop(self, requested)` | Invoked when the animation group is stopped. `requested` is true if the stop was explicitly requested via `:Stop()`. |
| OnUpdate | `OnUpdate(self, elapsed)` | Invoked on every frame while the animation group is playing. `elapsed` is the time in seconds since the last frame. |
| OnLoad | `OnLoad(self)` | Invoked when the object is created (from XML only). |

### Individual Handler References
- `OnFinished` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnFinished
- `OnLoop` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnLoop
- `OnUpdate` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnUpdate
- `OnLoad` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnLoad

### Usage Example
```lua
local ag = frame:CreateAnimationGroup()
local anim = ag:CreateAnimation("Alpha")
anim:SetFromAlpha(0)
anim:SetToAlpha(1)
anim:SetDuration(0.3)

ag:SetScript("OnFinished", function(self, requested)
    print("Animation finished, requested:", requested)
end)

ag:SetScript("OnLoop", function(self, loopState)
    print("Loop state:", loopState) -- "NONE", "FORWARD", or "REVERSE"
end)

ag:Play()
```

---

## Animation Handlers

Handlers for individual `Animation` objects within an AnimationGroup. These follow the same lifecycle as their parent group but fire per-animation.

> **Widget reference:** https://warcraft.wiki.gg/wiki/UIOBJECT_Animation

| Handler | Signature | Description |
|---------|-----------|-------------|
| OnFinished | `OnFinished(self, requested)` | Invoked when the animation finishes animating. `requested` is true if the stop was explicitly requested. |
| OnPause | `OnPause(self)` | Invoked when the animation is paused. |
| OnPlay | `OnPlay(self)` | Invoked when the animation begins to play. |
| OnStop | `OnStop(self, requested)` | Invoked when the animation is stopped. `requested` is true if stop was explicitly requested. |
| OnUpdate | `OnUpdate(self, elapsed)` | Invoked on every frame while the animation is playing. `elapsed` is time in seconds since the last frame. |
| OnLoad | `OnLoad(self)` | Invoked when the object is created (from XML only). |

### Individual Handler References
- `OnFinished` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnFinished
- `OnUpdate` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnUpdate
- `OnLoad` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnLoad

---

## ScriptRegion Handlers

Handlers for `ScriptRegion` — the base type for all visible, interactive widgets (frames, textures, font strings). These handlers are inherited by all Frame types and their subtypes.

> **Widget reference:** https://warcraft.wiki.gg/wiki/Widget_API#ScriptRegion

| Handler | Signature | Description |
|---------|-----------|-------------|
| OnShow | `OnShow(self)` | Invoked when the widget is shown (via `:Show()` or a parent becoming visible). Fires even if the widget was already visible. |
| OnHide | `OnHide(self)` | Invoked when the widget is hidden (via `:Hide()` or a parent being hidden). |
| OnEnter | `OnEnter(self, motion)` | Invoked when the cursor enters the widget's interactive area. `motion` is true if the entry was caused by mouse movement (vs. the widget appearing under the cursor). |
| OnLeave | `OnLeave(self, motion)` | Invoked when the cursor leaves the widget's interactive area. `motion` is true if caused by mouse movement. |
| OnMouseDown | `OnMouseDown(self, button)` | Invoked when a mouse button is pressed while the cursor is over the widget. `button` is `"LeftButton"`, `"RightButton"`, `"MiddleButton"`, etc. |
| OnMouseUp | `OnMouseUp(self, button, upInside)` | Invoked when a mouse button is released after a mouse-down on the widget. `upInside` is true if the cursor is still over the widget. |
| OnMouseWheel | `OnMouseWheel(self, delta)` | Invoked when the widget receives a mouse wheel scroll. `delta` is positive for scroll-up, negative for scroll-down. |
| OnLoad | `OnLoad(self)` | Invoked when the widget is created. Only fires for widgets created from XML templates. |

### Important Notes
- `OnEnter`/`OnLeave` require the widget to be mouse-enabled. Call `frame:EnableMouse(true)` for Frame types, or ensure the region is interactive.
- `OnMouseDown`/`OnMouseUp` also require mouse-enabled state.
- `OnMouseWheel` requires `frame:EnableMouseWheel(true)`.
- `OnLoad` only fires for XML-created widgets. For Lua-created widgets, run initialization code immediately after `CreateFrame()`.

### Individual Handler References
- `OnShow` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnShow
- `OnHide` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnHide
- `OnEnter` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnEnter
- `OnLeave` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnLeave
- `OnMouseDown` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnMouseDown
- `OnMouseUp` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnMouseUp
- `OnMouseWheel` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnMouseWheel
- `OnLoad` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnLoad

### Usage Example
```lua
local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
frame:SetSize(200, 100)
frame:SetPoint("CENTER")
frame:EnableMouse(true)
frame:EnableMouseWheel(true)

frame:SetScript("OnEnter", function(self, motion)
    self:SetAlpha(1.0)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine("Hover over me!")
    GameTooltip:Show()
end)

frame:SetScript("OnLeave", function(self, motion)
    self:SetAlpha(0.7)
    GameTooltip:Hide()
end)

frame:SetScript("OnMouseWheel", function(self, delta)
    print("Scrolled:", delta > 0 and "up" or "down")
end)
```

---

## Frame Handlers

Handlers specific to `Frame` objects — the general-purpose container type. Frame inherits all ScriptRegion handlers and adds event dispatching, keyboard input, drag-and-drop, and per-frame updates.

> **Widget reference:** https://warcraft.wiki.gg/wiki/UIOBJECT_Frame

| Handler | Signature | Description |
|---------|-----------|-------------|
| OnEvent | `OnEvent(self, event, ...)` | Invoked whenever a registered event fires. `event` is the event name string; `...` contains the event payload arguments. Requires `Frame:RegisterEvent()` or `Frame:RegisterUnitEvent()`. |
| OnUpdate | `OnUpdate(self, elapsed)` | Invoked on every rendered frame. `elapsed` is the time in seconds since the previous frame. **Warning:** runs every frame — throttle expensive operations. |
| OnChar | `OnChar(self, text)` | Invoked for each text character typed while the frame has keyboard focus. `text` is the UTF-8 character typed. Requires `frame:EnableKeyboard(true)`. |
| OnKeyDown | `OnKeyDown(self, key)` | Invoked when a keyboard key is pressed. `key` is the key name (e.g., `"ESCAPE"`, `"A"`, `"SPACE"`). Requires `frame:EnableKeyboard(true)`. Sets key propagation via return value. |
| OnKeyUp | `OnKeyUp(self, key)` | Invoked when a keyboard key is released. `key` is the key name. Requires `frame:EnableKeyboard(true)`. |
| OnAttributeChanged | `OnAttributeChanged(self, key, value)` | Invoked when a secure frame attribute is changed via `Frame:SetAttribute()`. `key` and `value` are the attribute name and new value. |
| OnDragStart | `OnDragStart(self, button)` | Invoked when the mouse starts dragging from the frame. `button` is the mouse button used. Requires `frame:RegisterForDrag("LeftButton")`. |
| OnDragStop | `OnDragStop(self)` | Invoked when the mouse button is released after a drag started in the frame. |
| OnReceiveDrag | `OnReceiveDrag(self)` | Invoked when the mouse button is released after dragging into the frame (e.g., dropping a cursor item). |
| OnSizeChanged | `OnSizeChanged(self, width, height)` | Invoked when a frame's width or height changes. `width` and `height` are the new dimensions in pixels. |
| OnEnable | `OnEnable(self)` | Invoked when the frame is enabled. |
| OnDisable | `OnDisable(self)` | Invoked when the frame is disabled. |
| OnHyperlinkClick | `OnHyperlinkClick(self, link, text, button, region, left, bottom, width, height)` | Invoked when a hyperlink in a FontString is clicked. `link` is the hyperlink data, `text` is the displayed text, `button` is the mouse button, `region` is the FontString, and `left`/`bottom`/`width`/`height` describe the link's bounding box. |
| OnHyperlinkEnter | `OnHyperlinkEnter(self, link, text, region, left, bottom, width, height)` | Invoked when the mouse enters a hyperlink in a FontString. |
| OnHyperlinkLeave | `OnHyperlinkLeave(self)` | Invoked when the mouse leaves a hyperlink in a FontString. |
| OnGamePadButtonDown | `OnGamePadButtonDown(self, button)` | Invoked when a gamepad button is pressed. `button` is the button identifier. |
| OnGamePadButtonUp | `OnGamePadButtonUp(self, button)` | Invoked when a gamepad button is released. |
| OnGamePadStick | `OnGamePadStick(self, stick, x, y, len)` | Invoked when a gamepad stick is moved. `stick` is the stick identifier, `x`/`y` are direction values (-1 to 1), `len` is the magnitude. |

### Individual Handler References
- `OnEvent` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnEvent
- `OnUpdate` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnUpdate
- `OnChar` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnChar
- `OnKeyDown` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnKeyDown
- `OnKeyUp` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnKeyUp
- `OnAttributeChanged` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnAttributeChanged
- `OnDragStart` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnDragStart
- `OnDragStop` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnDragStop
- `OnReceiveDrag` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnReceiveDrag
- `OnHyperlinkClick` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnHyperlinkClick
- `OnHyperlinkEnter` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnHyperlinkEnter
- `OnHyperlinkLeave` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnHyperlinkLeave
- `OnGamePadButtonDown` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnGamePadButtonDown
- `OnGamePadButtonUp` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnGamePadButtonUp
- `OnGamePadStick` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnGamePadStick

### OnEvent — Detailed Usage

`OnEvent` is the most commonly used handler in WoW addon development. It dispatches registered game events to your handler function.

**Prerequisites:** You must register for events before they fire:
```lua
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterUnitEvent("UNIT_HEALTH", "player") -- filter to specific units
```

**Pattern 1: if/elseif chain**
```lua
local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", function(self, event, arg1, arg2, arg3, arg4)
    if event == "PLAYER_LOGIN" then
        print("Logging on")
    elseif event == "PLAYER_REGEN_DISABLED" then
        print("Entering combat")
    elseif event == "PLAYER_REGEN_ENABLED" then
        print("Leaving combat")
    elseif event == "UNIT_SPELLCAST_SENT" and arg1 == "player" and arg4 == 1459 then
        print("Casting arcane intellect")
    end
end)
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("UNIT_SPELLCAST_SENT")
```

**Pattern 2: Lookup table dispatch (recommended for many events)**
```lua
local frame = CreateFrame("Frame")

function frame:PLAYER_LOGIN()
    print("Logging on")
end

function frame:PLAYER_REGEN_DISABLED()
    print("Entering combat")
end

function frame:PLAYER_REGEN_ENABLED()
    print("Leaving combat")
end

function frame:UNIT_SPELLCAST_SENT(unitID, _, _, spellID)
    if unitID == "player" and spellID == 1459 then
        print("Casting arcane intellect")
    end
end

frame:SetScript("OnEvent", function(self, event, ...)
    self[event](self, ...)
end)

frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("UNIT_SPELLCAST_SENT")
```

> **Source for examples:** https://warcraft.wiki.gg/wiki/UIHANDLER_OnEvent

### OnUpdate — Performance Considerations

`OnUpdate` fires on **every rendered frame** (typically 30–240+ times per second). This makes it powerful but potentially expensive.

**Throttling pattern:**
```lua
local INTERVAL = 0.1 -- update every 0.1 seconds
local timeSinceLastUpdate = 0

frame:SetScript("OnUpdate", function(self, elapsed)
    timeSinceLastUpdate = timeSinceLastUpdate + elapsed
    if timeSinceLastUpdate >= INTERVAL then
        -- Do work here
        timeSinceLastUpdate = 0
    end
end)
```

**Tip:** Remove OnUpdate handlers when not needed to save CPU:
```lua
frame:SetScript("OnUpdate", nil) -- removes the handler
```

> **Source:** https://warcraft.wiki.gg/wiki/UIHANDLER_OnUpdate

### Drag-and-Drop Example
```lua
local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
frame:SetSize(100, 100)
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")

frame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)
```

---

## Button Handlers

Handlers specific to `Button` (and `CheckButton`) widgets. Button inherits all Frame and ScriptRegion handlers.

> **Widget reference:** https://warcraft.wiki.gg/wiki/UIOBJECT_Button

| Handler | Signature | Description |
|---------|-----------|-------------|
| OnClick | `OnClick(self, button, down)` | Invoked when clicking a button. `self` is the button widget, `button` is the mouse button name (e.g., `"LeftButton"`, `"RightButton"`), `down` is true when pressed and false when released. |
| OnDoubleClick | `OnDoubleClick(self, button)` | Invoked when double-clicking a button. `button` is the mouse button name. Blocks the second OnClick "up" event. |
| PreClick | `PreClick(self, button, down)` | Invoked immediately **before** `OnClick`. Useful for secure handlers that need to prepare state. |
| PostClick | `PostClick(self, button, down)` | Invoked immediately **after** `OnClick`. Useful for cleanup after secure button actions. |

### Click Event Order

When a button is clicked, handlers fire in this order:
1. `OnMouseDown` (from ScriptRegion)
2. `OnMouseUp` (from ScriptRegion)
3. `PreClick`
4. `OnClick`
5. `PostClick`

For double-clicks, `OnDoubleClick` replaces the second `OnClick` "up" event.

### Click Registration

By default, buttons only respond to `"LeftButtonUp"`. Use `RegisterForClicks()` to customize:

```lua
-- Respond to left and right clicks, both press and release
button:RegisterForClicks("AnyDown", "AnyUp")

-- Respond to left button press only
button:RegisterForClicks("LeftButtonDown")
```

### Individual Handler References
- `OnClick` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnClick
- `OnDoubleClick` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnDoubleClick
- `PreClick` — https://warcraft.wiki.gg/wiki/UIHANDLER_PreClick
- `PostClick` — https://warcraft.wiki.gg/wiki/UIHANDLER_PostClick

### Usage Example
```lua
local btn = CreateFrame("Button", nil, UIParent, "UIPanelButtonTemplate")
btn:SetSize(200, 24)
btn:SetPoint("CENTER")
btn:SetText("Click me")
btn:RegisterForClicks("AnyUp", "AnyDown")

btn:SetScript("OnClick", function(self, button, down)
    self:SetText((down and "Pressed " or "Released ") .. button)
end)

btn:SetScript("OnDoubleClick", function(self, button)
    print("Double-clicked with", button)
end)
```

> **Source:** https://warcraft.wiki.gg/wiki/UIHANDLER_OnClick

---

## Model Handlers

Handlers for `Model`, `PlayerModel`, and related 3D model widgets.

> **Widget reference:** https://warcraft.wiki.gg/wiki/UIOBJECT_Model

| Handler | Signature | Description |
|---------|-----------|-------------|
| OnAnimFinished | `OnAnimFinished(self)` | Invoked when the model's animation finishes playing. |
| OnAnimStarted | `OnAnimStarted(self)` | Invoked when the model's animation starts playing. |
| OnModelLoaded | `OnModelLoaded(self)` | Invoked when the 3D model resource has been loaded and is ready for display. |

---

## CinematicModel Handlers

Handlers specific to `CinematicModel` widgets (cinematic camera control).

> **Widget reference:** https://warcraft.wiki.gg/wiki/UIOBJECT_CinematicModel

| Handler | Signature | Description |
|---------|-----------|-------------|
| OnPanFinished | `OnPanFinished(self)` | Invoked when the camera has finished panning. |

---

## DressUpModel Handlers

Handlers specific to `DressUpModel` widgets (item preview/try-on).

> **Widget reference:** https://warcraft.wiki.gg/wiki/UIOBJECT_DressUpModel

| Handler | Signature | Description |
|---------|-----------|-------------|
| OnDressModel | `OnDressModel(self, itemModifiedAppearanceID, invSlot, removed)` | Invoked when the dressup model is updated. `itemModifiedAppearanceID` is the appearance being applied, `invSlot` is the inventory slot, `removed` is true if the item was removed. |

### Individual Handler References
- `OnDressModel` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnDressModel

---

## ModelScene Handlers

Handlers specific to `ModelScene` widgets (3D scene containers).

> **Widget reference:** https://warcraft.wiki.gg/wiki/UIOBJECT_ModelScene

| Handler | Signature | Description |
|---------|-----------|-------------|
| OnDressModel | `OnDressModel(self, itemModifiedAppearanceID, invSlot, removed)` | Invoked when the modelscene model is updated with a dress-up item. |

### Individual Handler References
- `OnDressModel` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnDressModel

---

## ModelSceneActor Handlers

Handlers for `ModelSceneActor` widgets. **Important:** Scripts for ModelSceneActor can only be set from XML, not from Lua.

> **Widget reference:** https://warcraft.wiki.gg/wiki/UIOBJECT_ModelSceneActor

| Handler | Signature | Description |
|---------|-----------|-------------|
| OnAnimFinished | `OnAnimFinished(self)` | Invoked when the actor's animation finishes. |
| OnModelCleared | `OnModelCleared(self)` | Invoked when the actor's model is cleared. |
| OnModelLoaded | `OnModelLoaded(self)` | Invoked when the actor's model is loaded. |
| OnModelLoading | `OnModelLoading(self)` | Invoked when the actor's model begins loading. |

### XML-Only Example
```xml
<ModelSceneActor>
    <Scripts>
        <OnModelLoaded>
            print("Model loaded for actor:", self:GetDebugName())
        </OnModelLoaded>
    </Scripts>
</ModelSceneActor>
```

---

## EditBox Handlers

Handlers specific to `EditBox` widgets — text input fields. EditBox inherits all Frame and ScriptRegion handlers.

> **Widget reference:** https://warcraft.wiki.gg/wiki/UIOBJECT_EditBox

| Handler | Signature | Description |
|---------|-----------|-------------|
| OnEnterPressed | `OnEnterPressed(self)` | Invoked when pressing Enter while the edit box has focus. Commonly used to submit input. |
| OnEscapePressed | `OnEscapePressed(self)` | Invoked when pressing Escape while the edit box has focus. Commonly used to cancel/close. |
| OnSpacePressed | `OnSpacePressed(self)` | Invoked when pressing Space while the edit box has focus. |
| OnTabPressed | `OnTabPressed(self)` | Invoked when pressing Tab while the edit box has focus. Commonly used to cycle between input fields. |
| OnTextChanged | `OnTextChanged(self, userInput)` | Invoked when the text value changes. `userInput` is true if the change was caused by user typing (false if set programmatically via `:SetText()`). |
| OnTextSet | `OnTextSet(self)` | Invoked when the text value is set programmatically via `:SetText()`. |
| OnCursorChanged | `OnCursorChanged(self, x, y, w, h)` | Invoked when the text cursor position changes. `x`/`y` are the cursor position, `w`/`h` are the cursor dimensions. |
| OnEditFocusGained | `OnEditFocusGained(self)` | Invoked when the edit box gains input focus (user clicks in it or `:SetFocus()` is called). |
| OnEditFocusLost | `OnEditFocusLost(self)` | Invoked when the edit box loses input focus. |
| OnCharComposition | `OnCharComposition(self, text)` | Invoked for each text character typed while using an input method editor (IME) for CJK languages. |
| OnArrowPressed | `OnArrowPressed(self, key)` | Invoked when an arrow key is pressed while the edit box has focus. `key` is the arrow key name. |
| OnInputLanguageChanged | `OnInputLanguageChanged(self, language)` | Invoked when the input language mode changes. |

### Individual Handler References
- `OnCharComposition` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnCharComposition
- `OnCursorChanged` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnCursorChanged
- `OnEditFocusGained` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnEditFocusGained
- `OnEditFocusLost` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnEditFocusLost
- `OnEnterPressed` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnEnterPressed
- `OnEscapePressed` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnEscapePressed
- `OnSpacePressed` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnSpacePressed
- `OnTabPressed` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnTabPressed
- `OnTextChanged` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnTextChanged
- `OnTextSet` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnTextSet

### Usage Example
```lua
local editBox = CreateFrame("EditBox", nil, UIParent, "InputBoxTemplate")
editBox:SetSize(200, 30)
editBox:SetPoint("CENTER")
editBox:SetAutoFocus(false)

editBox:SetScript("OnEnterPressed", function(self)
    local text = self:GetText()
    print("Submitted:", text)
    self:ClearFocus()
end)

editBox:SetScript("OnEscapePressed", function(self)
    self:SetText("")
    self:ClearFocus()
end)

editBox:SetScript("OnTextChanged", function(self, userInput)
    if userInput then
        print("User typed:", self:GetText())
    end
end)

editBox:SetScript("OnEditFocusGained", function(self)
    self:HighlightText()
end)

editBox:SetScript("OnEditFocusLost", function(self)
    self:HighlightText(0, 0)
end)
```

---

## GameTooltip Handlers

Handlers specific to `GameTooltip` widgets. These fire when tooltip content is populated or cleared.

> **Widget reference:** https://warcraft.wiki.gg/wiki/UIOBJECT_GameTooltip

| Handler | Signature | Description |
|---------|-----------|-------------|
| OnTooltipCleared | `OnTooltipCleared(self)` | Invoked when the tooltip is hidden or its content is cleared. Use this to clean up custom tooltip modifications. |
| OnTooltipSetDefaultAnchor | `OnTooltipSetDefaultAnchor(self)` | Invoked when the tooltip is repositioned to its default anchor location. |
| OnTooltipSetFramestack | `OnTooltipSetFramestack(self, highlightFrame)` | Invoked when the tooltip is filled with a list of frames under the mouse cursor (debug framestack). |

### Classic-Only Handlers

The following tooltip handlers are **only available in Classic** versions of WoW, not in Retail:

| Handler | Signature | Description |
|---------|-----------|-------------|
| OnTooltipAddMoney | `OnTooltipAddMoney(self, cost, maxcost)` | Invoked when a money amount is added to the tooltip. |
| OnTooltipSetAchievement | `OnTooltipSetAchievement(self)` | Invoked when the tooltip is filled with achievement info. |
| OnTooltipSetEquipmentSet | `OnTooltipSetEquipmentSet(self)` | Invoked when the tooltip is filled with equipment set info. |
| OnTooltipSetItem | `OnTooltipSetItem(self)` | Invoked when the tooltip is filled with item info. |
| OnTooltipSetQuest | `OnTooltipSetQuest(self)` | Invoked when the tooltip is filled with quest info. |
| OnTooltipSetSpell | `OnTooltipSetSpell(self)` | Invoked when the tooltip is filled with spell info. |
| OnTooltipSetUnit | `OnTooltipSetUnit(self)` | Invoked when the tooltip is filled with unit info. |

> **Note:** In Retail, use `TooltipDataProcessor.AddTooltipPostCall()` instead of these Classic-only handlers for tooltip content hooks.

### Individual Handler References
- `OnTooltipAddMoney` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnTooltipAddMoney
- `OnTooltipSetItem` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnTooltipSetItem

### Retail Tooltip Example
```lua
-- Retail: Use TooltipDataProcessor for item tooltip modifications
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
    if tooltip == GameTooltip then
        tooltip:AddLine("Custom addon line!", 0, 1, 0)
    end
end)

-- Still works in Retail: OnTooltipCleared for cleanup
GameTooltip:HookScript("OnTooltipCleared", function(self)
    -- Reset any custom state
end)
```

---

## ColorSelect Handlers

Handlers specific to `ColorSelect` widgets (color picker).

> **Widget reference:** https://warcraft.wiki.gg/wiki/UIOBJECT_ColorSelect

| Handler | Signature | Description |
|---------|-----------|-------------|
| OnColorSelect | `OnColorSelect(self, r, g, b)` | Invoked when the color selection changes. `r`, `g`, `b` are values from 0 to 1. |

---

## Cooldown Handlers

Handlers specific to `Cooldown` widgets (cooldown sweep animation).

> **Widget reference:** https://warcraft.wiki.gg/wiki/UIOBJECT_Cooldown

| Handler | Signature | Description |
|---------|-----------|-------------|
| OnCooldownDone | `OnCooldownDone(self)` | Invoked when the cooldown timer finishes (sweep animation completes). |

### Usage Example
```lua
local cooldown = CreateFrame("Cooldown", nil, parentFrame, "CooldownFrameTemplate")
cooldown:SetAllPoints(parentFrame)

cooldown:SetScript("OnCooldownDone", function(self)
    print("Cooldown finished!")
end)

-- Start a 10-second cooldown
cooldown:SetCooldown(GetTime(), 10)
```

---

## MovieFrame Handlers

Handlers specific to `MovieFrame` widgets (in-game movie playback).

> **Widget reference:** https://warcraft.wiki.gg/wiki/UIOBJECT_MovieFrame

| Handler | Signature | Description |
|---------|-----------|-------------|
| OnMovieFinished | `OnMovieFinished(self)` | Invoked when a movie finishes playing. |

---

## ScrollFrame Handlers

Handlers specific to `ScrollFrame` widgets (scrollable content containers).

> **Widget reference:** https://warcraft.wiki.gg/wiki/UIOBJECT_ScrollFrame

| Handler | Signature | Description |
|---------|-----------|-------------|
| OnHorizontalScroll | `OnHorizontalScroll(self, offset)` | Invoked when the horizontal scroll position changes. `offset` is the new horizontal scroll offset in pixels. |
| OnVerticalScroll | `OnVerticalScroll(self, offset)` | Invoked when the vertical scroll position changes. `offset` is the new vertical scroll offset in pixels. |
| OnScrollRangeChanged | `OnScrollRangeChanged(self, xrange, yrange)` | Invoked when the scrollable range changes (e.g., child content resized). `xrange` and `yrange` are the maximum scroll offsets. |

### Usage Example
```lua
local scrollFrame = CreateFrame("ScrollFrame", nil, UIParent, "UIPanelScrollFrameTemplate")
scrollFrame:SetSize(300, 200)
scrollFrame:SetPoint("CENTER")

scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
    print("Scrolled to vertical offset:", offset)
end)

scrollFrame:SetScript("OnScrollRangeChanged", function(self, xrange, yrange)
    -- Update scrollbar range when content size changes
    print("Scroll range changed:", xrange, yrange)
end)
```

---

## Slider Handlers

Handlers specific to `Slider` widgets (draggable value sliders).

> **Widget reference:** https://warcraft.wiki.gg/wiki/UIOBJECT_Slider

| Handler | Signature | Description |
|---------|-----------|-------------|
| OnValueChanged | `OnValueChanged(self, value, userInput)` | Invoked when the slider's value changes. `value` is the new numeric value. `userInput` is true if the change was caused by user dragging (false if set programmatically via `:SetValue()`). |
| OnMinMaxChanged | `OnMinMaxChanged(self, min, max)` | Invoked when the slider's minimum and maximum values change. |

### Individual Handler References
- `OnValueChanged` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnValueChanged

### Usage Example
```lua
local slider = CreateFrame("Slider", nil, UIParent, "OptionsSliderTemplate")
slider:SetSize(200, 20)
slider:SetPoint("CENTER")
slider:SetMinMaxValues(0, 100)
slider:SetValue(50)
slider:SetValueStep(1)

slider:SetScript("OnValueChanged", function(self, value, userInput)
    if userInput then
        print("User changed slider to:", value)
    end
end)
```

---

## StatusBar Handlers

Handlers specific to `StatusBar` widgets (progress/health bars).

> **Widget reference:** https://warcraft.wiki.gg/wiki/UIOBJECT_StatusBar

| Handler | Signature | Description |
|---------|-----------|-------------|
| OnValueChanged | `OnValueChanged(self, value)` | Invoked when the status bar's value changes. `value` is the new numeric value. **Note:** Unlike Slider, StatusBar's `OnValueChanged` does not have a `userInput` parameter. |
| OnMinMaxChanged | `OnMinMaxChanged(self, min, max)` | Invoked when the status bar's minimum and maximum values change. |

### Individual Handler References
- `OnValueChanged` — https://warcraft.wiki.gg/wiki/UIHANDLER_OnValueChanged

### Usage Example
```lua
local bar = CreateFrame("StatusBar", nil, UIParent)
bar:SetSize(200, 20)
bar:SetPoint("CENTER")
bar:SetMinMaxValues(0, 100)
bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
bar:SetStatusBarColor(0, 1, 0)
bar:SetValue(75)

bar:SetScript("OnValueChanged", function(self, value)
    local _, max = self:GetMinMaxValues()
    print(string.format("Health: %d/%d", value, max))
end)
```

---

## FogOfWarFrame Handlers

Handlers specific to `FogOfWarFrame` widgets (map fog of war rendering).

| Handler | Signature | Description |
|---------|-----------|-------------|
| OnUiMapChanged | `OnUiMapChanged(self, uiMapID)` | Invoked when the displayed map changes. `uiMapID` is the numeric map identifier. |

---

## Quick Reference: Handler-to-Widget Mapping

A complete mapping of which handlers are available on which widget types. Handlers marked with `*` are inherited from parent types.

| Handler | AnimGroup | Anim | ScriptRegion | Frame | Button | EditBox | GameTooltip | Model | ScrollFrame | Slider | StatusBar | Cooldown |
|---------|-----------|------|--------------|-------|--------|---------|-------------|-------|-------------|--------|-----------|----------|
| OnLoad | ✓ | ✓ | ✓ | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* |
| OnShow | | | ✓ | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* |
| OnHide | | | ✓ | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* |
| OnEnter | | | ✓ | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* |
| OnLeave | | | ✓ | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* |
| OnMouseDown | | | ✓ | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* |
| OnMouseUp | | | ✓ | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* |
| OnMouseWheel | | | ✓ | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* |
| OnUpdate | ✓ | ✓ | | ✓ | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* |
| OnEvent | | | | ✓ | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* |
| OnSizeChanged | | | | ✓ | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* |
| OnKeyDown | | | | ✓ | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* |
| OnKeyUp | | | | ✓ | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* |
| OnChar | | | | ✓ | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* |
| OnDragStart | | | | ✓ | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* |
| OnDragStop | | | | ✓ | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* |
| OnReceiveDrag | | | | ✓ | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* |
| OnClick | | | | | ✓ | | | | | | | |
| OnDoubleClick | | | | | ✓ | | | | | | | |
| PreClick | | | | | ✓ | | | | | | | |
| PostClick | | | | | ✓ | | | | | | | |
| OnEnterPressed | | | | | | ✓ | | | | | | |
| OnEscapePressed | | | | | | ✓ | | | | | | |
| OnTextChanged | | | | | | ✓ | | | | | | |
| OnTextSet | | | | | | ✓ | | | | | | |
| OnCursorChanged | | | | | | ✓ | | | | | | |
| OnEditFocusGained | | | | | | ✓ | | | | | | |
| OnEditFocusLost | | | | | | ✓ | | | | | | |
| OnValueChanged | | | | | | | | | | ✓ | ✓ | |
| OnMinMaxChanged | | | | | | | | | | ✓ | ✓ | |
| OnCooldownDone | | | | | | | | | | | | ✓ |
| OnFinished | ✓ | ✓ | | | | | | | | | | |
| OnLoop | ✓ | | | | | | | | | | | |
| OnPause | ✓ | ✓ | | | | | | | | | | |
| OnPlay | ✓ | ✓ | | | | | | | | | | |
| OnStop | ✓ | ✓ | | | | | | | | | | |
| OnVerticalScroll | | | | | | | | | ✓ | | | |
| OnHorizontalScroll | | | | | | | | | ✓ | | | |
| OnScrollRangeChanged | | | | | | | | | ✓ | | | |

---

## Common Patterns

### Pattern: Tooltip on Hover

```lua
frame:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine("Title", 1, 1, 1)
    GameTooltip:AddLine("Description", 0.8, 0.8, 0.8, true)
    GameTooltip:Show()
end)

frame:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)
```

### Pattern: Escaping from a Frame

```lua
-- Press escape to hide a frame, integrating with WoW's UI panel system
tinsert(UISpecialFrames, frame:GetName())

-- Or manually:
frame:SetScript("OnKeyDown", function(self, key)
    if key == "ESCAPE" then
        self:SetPropagateKeyboardInput(false)
        self:Hide()
    else
        self:SetPropagateKeyboardInput(true)
    end
end)
frame:EnableKeyboard(true)
```

### Pattern: Movable + Resizable Frame

```lua
local frame = CreateFrame("Frame", "MyMovableFrame", UIParent, "BackdropTemplate")
frame:SetSize(300, 200)
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:SetResizable(true)
frame:SetResizeBounds(150, 100, 600, 400)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")

frame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    -- Save position to SavedVariables
end)
```

### Pattern: Secure Button with Context

```lua
local btn = CreateFrame("Button", "MySecureButton", UIParent, "SecureActionButtonTemplate")
btn:SetAttribute("type", "spell")
btn:SetAttribute("spell", "Arcane Intellect")

btn:SetScript("PreClick", function(self, button, down)
    -- Runs before secure action — can read state but not modify secure attributes in combat
    print("About to cast...")
end)

btn:SetScript("PostClick", function(self, button, down)
    -- Runs after secure action — cleanup
    print("Cast attempted")
end)
```

---

## Sources

- Widget script handlers listing — https://warcraft.wiki.gg/wiki/Widget_script_handlers
- Widget API reference — https://warcraft.wiki.gg/wiki/Widget_API
- OnClick handler — https://warcraft.wiki.gg/wiki/UIHANDLER_OnClick
- OnEvent handler — https://warcraft.wiki.gg/wiki/UIHANDLER_OnEvent
- OnUpdate handler — https://warcraft.wiki.gg/wiki/UIHANDLER_OnUpdate
- OnShow handler — https://warcraft.wiki.gg/wiki/UIHANDLER_OnShow
- OnHide handler — https://warcraft.wiki.gg/wiki/UIHANDLER_OnHide
- OnLoad handler — https://warcraft.wiki.gg/wiki/UIHANDLER_OnLoad
- OnFinished handler — https://warcraft.wiki.gg/wiki/UIHANDLER_OnFinished
- OnValueChanged handler — https://warcraft.wiki.gg/wiki/UIHANDLER_OnValueChanged
- OnDressModel handler — https://warcraft.wiki.gg/wiki/UIHANDLER_OnDressModel
- SetScript API — https://warcraft.wiki.gg/wiki/API_ScriptObject_SetScript
- HookScript API — https://warcraft.wiki.gg/wiki/API_ScriptObject_HookScript
- HasScript API — https://warcraft.wiki.gg/wiki/API_ScriptObject_HasScript
- RegisterForClicks API — https://warcraft.wiki.gg/wiki/API_Button_RegisterForClicks
- RegisterForDrag API — https://warcraft.wiki.gg/wiki/API_Frame_RegisterForDrag
- RegisterEvent API — https://warcraft.wiki.gg/wiki/API_Frame_RegisterEvent
- Events listing — https://warcraft.wiki.gg/wiki/Events
