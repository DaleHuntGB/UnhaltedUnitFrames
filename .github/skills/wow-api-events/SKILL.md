---
name: wow-api-events
description: "Full reference for WoW Retail frame events, payloads, and event handling patterns. Includes setup, registration, and categorized event lists with payloads."
---

# WoW Events (Frame Events)

This skill documents frame events that the WoW client sends to UI code via `OnEvent` handlers. It covers setup, payload handling, and a categorized list of events with their payloads.

> Source of truth: https://warcraft.wiki.gg/wiki/Events
> Event handling: https://warcraft.wiki.gg/wiki/Handling_events
> OnEvent handler: https://warcraft.wiki.gg/wiki/UIHANDLER_OnEvent
> Current as of: Patch 12.0.0 (Retail)

## Scope

- Retail only (ignore Classic-only events).
- Frame events delivered to `OnEvent` handlers.
- Includes payloads where documented.

## When to Use This Skill

Use this skill when you need to:
- Register or handle events (`RegisterEvent`, `RegisterUnitEvent`).
- Understand event payloads and argument order.
- Map events to UI systems (Inventory, Quest, Party, etc.).
- Build event-driven addon logic.

## How to Use This Skill

1. Start with the event handling primer below.
2. Open the reference file that contains the event category you need.
3. Use the event payload list to unpack `...` in your handler.
4. Cross-check unusual events on their wiki pages if a payload is unclear.

## Event Handling Primer

### Core APIs

- `CreateFrame("Frame")` creates an event handler frame.
- `frame:RegisterEvent("EVENT_NAME")` subscribes to a specific event.
- `frame:RegisterUnitEvent("UNIT_EVENT", "unit")` filters to units.
- `frame:SetScript("OnEvent", handler)` assigns the handler.
- `frame:UnregisterEvent("EVENT_NAME")` or `frame:UnregisterAllEvents()` removes subscriptions.

### Handler Signature

An `OnEvent` handler receives:

1. `self` - the frame
2. `event` - event name string
3. `...` - event payload arguments (vary per event)

From the Handling events guide:
- The global `event` and `argX` variables were removed in patch 4.0.1.
- Always unpack payloads from `...`.

### Dispatch Table Pattern

```lua
local f = CreateFrame("Frame")
local handlers = {}

function handlers:PLAYER_LOGIN()
    print("Login")
end

function handlers:BAG_UPDATE(bagID)
    print("Bag updated", bagID)
end

f:SetScript("OnEvent", function(self, event, ...)
  local handler = handlers[event]
  if handler then
    handler(handlers, ...)
  end
end)

for name in pairs(handlers) do
    f:RegisterEvent(name)
end
```

### XML Event Handler

```xml
<Ui>
  <Frame name="MyEventFrame">
    <Scripts>
      <OnLoad>
        self:RegisterEvent("PLAYER_ENTERING_WORLD")
      </OnLoad>
      <OnEvent>
        print("Event:", event)
      </OnEvent>
    </Scripts>
  </Frame>
</Ui>
```

## Debugging Events

Use `/etrace` to open the Event Trace window and inspect event traffic.

## Reference Files

Event lists are grouped by API system, matching the wiki categories:

- [EVENTS-A-F.md](references/EVENTS-A-F.md)
- [EVENTS-G-L.md](references/EVENTS-G-L.md)
- [EVENTS-M-R.md](references/EVENTS-M-R.md)
- [EVENTS-S-Z.md](references/EVENTS-S-Z.md)
- [EVENTS-UNDOCUMENTED.md](references/EVENTS-UNDOCUMENTED.md)

## Sources

- https://warcraft.wiki.gg/wiki/Events
- https://warcraft.wiki.gg/wiki/Handling_events
- https://warcraft.wiki.gg/wiki/UIHANDLER_OnEvent
