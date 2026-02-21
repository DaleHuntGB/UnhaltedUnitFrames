# Frame Controls (Curated)

Frame subtypes handle interaction: buttons, text input, scrolling, sliders, progress bars, cooldowns, and specialized text controls. This reference highlights common methods and patterns. For full lists, see the Widget API page.

> Source: https://warcraft.wiki.gg/wiki/Widget_API
> Current as of: Patch 12.0.0 (Retail)

## Button

Common methods:

- `SetText(text)`
- `RegisterForClicks("AnyUp" | "AnyDown" | ...)`
- `SetEnabled(trueOrFalse)`
- `SetNormalTexture(asset)` and `SetHighlightTexture(asset)`
- `SetNormalAtlas(atlas)` and `SetHighlightAtlas(atlas)`

## CheckButton

Common methods:

- `SetChecked(trueOrFalse)`
- `GetChecked()`
- `SetCheckedTexture(asset)`

## EditBox

Common methods:

- `SetText(text)` and `GetText()`
- `SetFocus()` and `ClearFocus()`
- `SetNumeric(trueOrFalse)`
- `SetMaxLetters(count)`
- `HighlightText(start, stop)`

## ScrollFrame

Common methods:

- `SetScrollChild(frame)`
- `SetVerticalScroll(offset)` and `GetVerticalScroll()`
- `GetVerticalScrollRange()`
- `UpdateScrollChildRect()`

## Slider

Common methods:

- `SetMinMaxValues(minValue, maxValue)`
- `SetValue(value)` and `GetValue()`
- `SetValueStep(step)`
- `SetOrientation("HORIZONTAL" | "VERTICAL")`
- `SetThumbTexture(asset)`

## StatusBar

Common methods:

- `SetMinMaxValues(minValue, maxValue)`
- `SetValue(value)` and `GetValue()`
- `SetStatusBarTexture(asset)`
- `SetStatusBarColor(r, g, b, a)`
- `SetOrientation("HORIZONTAL" | "VERTICAL")`

## Cooldown

Common method:

- `SetCooldown(startTime, duration)`

## MessageFrame and SimpleHTML

Common patterns:

- MessageFrame: `AddMessage(text)` and `Clear()`
- SimpleHTML: `SetText(text)`

## Examples

### Button With Click Handler
```lua
local btn = CreateFrame("Button", nil, UIParent, "UIPanelButtonTemplate")
btn:SetSize(120, 30)
btn:SetPoint("CENTER")
btn:SetText("Save")
btn:RegisterForClicks("AnyUp")
btn:SetScript("OnClick", function(self)
    print("Saved")
end)
```

### EditBox Submit On Enter
```lua
local edit = CreateFrame("EditBox", nil, UIParent, "InputBoxTemplate")
edit:SetSize(200, 24)
edit:SetPoint("CENTER", 0, -40)
edit:SetAutoFocus(false)
edit:SetScript("OnEnterPressed", function(self)
    print("Input:", self:GetText())
    self:ClearFocus()
end)
```

### ScrollFrame With Child
```lua
local scroll = CreateFrame("ScrollFrame", nil, UIParent)
scroll:SetSize(240, 120)
scroll:SetPoint("CENTER")

local child = CreateFrame("Frame", nil, scroll)
child:SetSize(240, 300)
scroll:SetScrollChild(child)
```

### Slider Driving a StatusBar
```lua
local bar = CreateFrame("StatusBar", nil, UIParent)
bar:SetSize(200, 16)
bar:SetPoint("CENTER", 0, 40)
bar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
bar:SetMinMaxValues(0, 100)

local slider = CreateFrame("Slider", nil, UIParent, "OptionsSliderTemplate")
slider:SetSize(200, 20)
slider:SetPoint("CENTER", 0, 10)
slider:SetMinMaxValues(0, 100)
slider:SetValueStep(1)
slider:SetScript("OnValueChanged", function(self, value)
    bar:SetValue(value)
end)
```