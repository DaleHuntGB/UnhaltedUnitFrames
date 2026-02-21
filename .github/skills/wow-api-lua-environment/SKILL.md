---
name: wow-api-lua-environment
description: "Complete reference for the WoW Lua 5.1 runtime environment, restrictions, secure execution, taint system, addon security model, timers, hooks, frame scripting, logging, and restricted actions. Covers hooksecurefunc, C_Timer, securecallfunction, issecurevariable, taint propagation, combat lockdown, protected frames, InCombatLockdown, C_RestrictedActions, C_Log, and the FrameScript sandbox. Use when working with Lua restrictions, secure code, taint, timers, hooks, addon security, debugging, or the WoW Lua sandbox."
---

# Lua Environment & Security (Retail — Patch 12.0.0)

Comprehensive reference for the WoW Lua sandbox, security model, taint system, secure execution, timers, hooks, logging, and restricted actions.

> **Source:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API
> **Secure Execution:** https://warcraft.wiki.gg/wiki/Secure_Execution_and_Tainting
> **Lua Functions:** https://warcraft.wiki.gg/wiki/Lua_functions
> **Current as of:** Patch 12.0.0 (Build 65655) — January 28, 2026
> **Scope:** Retail only.

## Scope

This skill covers:

- **Lua Sandbox** — WoW's Lua 5.1 environment, restricted standard library, blocked functions
- **Taint System** — How addon code becomes tainted and what tainted code cannot do
- **Secure Execution** — Protected functions, secure frames, secure handlers
- **Combat Lockdown** — What addons can and cannot do during combat
- **C_Timer** — Timer functions (After, NewTicker, NewTimer)
- **Hooks** — hooksecurefunc, securecallfunction, securecallmethod
- **C_RestrictedActions** — Addon restriction state queries
- **C_Log** — Logging utilities
- **FrameScript** — Frame script environment, secret values, scrubbing
- **Debugging** — Error handling, stack traces, debugging utilities

## When to Use This Skill

Use this skill when you need to:
- Understand what Lua functions are available vs blocked in WoW
- Work with or debug taint issues
- Write code that interacts with secure/protected frames
- Use timers, delayed execution, or ticker patterns
- Hook existing functions safely
- Understand combat lockdown restrictions
- Handle addon restriction states (12.0.0 instance restrictions)
- Log messages for debugging
- Work with secret values and the FrameScript sandbox

---

## WoW Lua 5.1 Sandbox

WoW runs **Lua 5.1.4** with significant modifications. The following standard library functions are **blocked or removed**:

### Blocked Standard Functions

| Blocked | Reason |
|---------|--------|
| `loadfile()` | No filesystem access |
| `dofile()` | No filesystem access |
| `io.*` | No filesystem access |
| `os.execute()` | No shell access |
| `os.exit()` | Cannot close client |
| `os.remove()` | No filesystem |
| `os.rename()` | No filesystem |
| `os.tmpname()` | No filesystem |
| `os.getenv()` | No environment access |
| `package.*` | No package system |
| `require()` | No module loading |
| `module()` | No module system |
| `newproxy()` | Removed |
| `getfenv()` | Limited — returns read-only |
| `setfenv()` | Very restricted |
| `collectgarbage()` | Limited modes |

### Available Standard Functions

Most core Lua functions work normally:
- All `string.*`, `table.*`, `math.*` functions
- `type()`, `tostring()`, `tonumber()`, `rawget()`, `rawset()`, `rawequal()`, `rawlen()`
- `pairs()`, `ipairs()`, `next()`, `select()`, `unpack()`
- `pcall()`, `xpcall()`, `error()`, `assert()`
- `setmetatable()`, `getmetatable()`
- `coroutine.*` (full coroutine support)
- `os.time()`, `os.date()`, `os.clock()`, `os.difftime()`
- `print()` — outputs to default chat frame

### WoW-Added Global Functions

| Function | Description |
|----------|-------------|
| `strsplit(delimiter, str [, pieces])` | Split string by delimiter |
| `strsplittable(delimiter, str [, pieces])` | Split to table |
| `strjoin(delimiter, ...)` | Join strings |
| `strtrim(str [, chars])` | Trim whitespace |
| `tContains(table, value)` | Table contains value? |
| `tInsert(table, value)` | Insert into table (alias) |
| `tDeleteItem(table, value)` | Remove first occurrence of value |
| `tInvert(table)` | Invert key/value pairs |
| `wipe(table)` | Clear table (preserving reference) |
| `CopyTable(table [, shallow])` | Deep or shallow copy |
| `MergeTable(dest, source)` | Merge source into dest |
| `Mixin(object, ...)` | Copy mixin methods to object |
| `CreateFromMixins(...)` | Create new object from mixins |
| `CreateAndInitFromMixin(mixin, ...)` | Create + call Init |
| `format(formatString, ...)` | Alias for string.format |
| `tostringall(...)` | Convert all args to strings |
| `DevTools_Dump(value, startKey)` | Dump value for debugging |

---

## Taint System

All addon code runs as **"tainted"** (insecure). Blizzard UI code runs as **"secure"** (untainted). The taint system prevents addons from calling protected functions or modifying secure frames.

### How Taint Works

1. Any variable set by addon code becomes **tainted**
2. Tainted values **propagate** — if tainted data flows into Blizzard code, it taints that path
3. Protected functions check taint before executing — they fail if execution path is tainted
4. Secure frames inherit security from their creation context

### Checking Taint

```lua
-- Check if a global variable is tainted
local isTainted, source = issecurevariable("SomeGlobalVar")
-- isTainted: false = secure, true = tainted
-- source: string name of the addon that tainted it (or nil if secure)

-- Check table field
local isTainted, source = issecurevariable(someTable, "someKey")
```

### Common Taint Pitfalls

```lua
-- WRONG — This taints the Blizzard settings table
Settings.RegisterAddOnCategory = myFunc  -- TAINT!

-- WRONG — Modifying secure frame in insecure context
local btn = PlayerFrame  -- This is a secure Blizzard frame
btn:SetAttribute("type", "spell")  -- TAINT — can cause action blocked errors

-- RIGHT — Use hooksecurefunc for observation without tainting
hooksecurefunc("SomeBlizzardFunction", function(...)
    -- Your code runs AFTER the original — doesn't taint
end)
```

---

## Secure Execution & Protected Functions

### Protected Function Restrictions

Functions marked `#protected` can only be called from:
- Secure (Blizzard) code
- Secure click handlers triggered by hardware events
- Inside `SecureActionButtonTemplate` handlers

Protected functions include:
- All combat-related casting: `CastSpellByName()`, `CastSpellByID()`, `UseAction()`
- Item use: `UseItemByName()`, `UseContainerItem()` (in combat)
- Target changes: `TargetUnit()`, `AssistUnit()`, `FocusUnit()`
- Movement: `MoveForwardStart()`, `JumpOrAscendStart()`
- UI state: `SetAttribute()` on secure frames (in combat)

### Combat Lockdown

```lua
-- Check if in combat lockdown
if InCombatLockdown() then
    -- Cannot: create/destroy secure frames, change secure attributes
    -- Cannot: set points on secure frames, change parent/visibility of secure frames
    -- Can: read attributes, modify non-secure frames, queue changes for later
    return
end

-- Queue changes for after combat
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:SetScript("OnEvent", function()
    -- Combat ended — safe to modify secure frames now
    DoSecureFrameChanges()
end)
```

### Secure Handlers & Templates

```lua
-- SecureActionButtonTemplate — allows protected actions via user clicks
local btn = CreateFrame("Button", "MySecureBtn", UIParent, "SecureActionButtonTemplate")
btn:SetAttribute("type", "spell")
btn:SetAttribute("spell", "Fireball")
-- When clicked by hardware event, this will cast Fireball

-- SecureHandlerBaseTemplate — run secure snippets
local frame = CreateFrame("Frame", nil, UIParent, "SecureHandlerBaseTemplate")
frame:SetAttribute("_onstate-combat", [[
    -- This snippet runs in the secure environment
    if newstate == "combat" then
        self:Hide()
    else
        self:Show()
    end
]])
RegisterStateDriver(frame, "combat", "[combat] combat; nocombat")
```

### State Drivers

```lua
-- Register a state driver for automatic secure attribute updates
RegisterStateDriver(frame, "stateName", "conditionalString")
-- e.g., RegisterStateDriver(frame, "visibility", "[combat] hide; show")

UnregisterStateDriver(frame, "stateName")
```

---

## C_Timer — Timer API

> **Wiki:** https://warcraft.wiki.gg/wiki/API_C_Timer.After

### Timer Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Timer.After(seconds, callback)` | — | One-shot timer |
| `C_Timer.NewTimer(seconds, callback)` | `timer` | Cancellable one-shot timer |
| `C_Timer.NewTicker(seconds, callback [, iterations])` | `ticker` | Repeating timer |

### Timer Object Methods

```lua
local timer = C_Timer.NewTimer(5, function()
    print("5 seconds elapsed")
end)
timer:Cancel()  -- Cancel before it fires

local ticker = C_Timer.NewTicker(1, function()
    print("Every second")
end, 10)  -- Stop after 10 iterations
ticker:Cancel()  -- Or cancel early

-- Simple delay (non-cancellable)
C_Timer.After(2, function()
    print("2 seconds later")
end)
```

---

## Hooks — Function Hooking

### hooksecurefunc

The primary safe hooking mechanism. Your hook runs **after** the original function, without tainting it.

```lua
-- Hook a global function
hooksecurefunc("UseAction", function(slot, checkCursor, onSelf)
    print("Action used:", slot)
end)

-- Hook a method on an object
hooksecurefunc(GameTooltip, "SetUnitAura", function(self, ...)
    -- Runs after GameTooltip:SetUnitAura
end)

-- IMPORTANT: You CANNOT prevent the original from executing
-- IMPORTANT: You CANNOT modify the return values
-- IMPORTANT: Your hook does NOT taint the original function
```

### securecallfunction / securecallmethod

```lua
-- Call a function in secure context (if possible)
securecallfunction(func, arg1, arg2)

-- Call a method in secure context
securecallmethod(object, "MethodName", arg1, arg2)
```

---

## C_RestrictedActions — Addon Restriction State

New in 12.0.0. Tracks when addon restrictions are active (e.g., inside instances).

| Function | Returns | Description |
|----------|---------|-------------|
| `C_RestrictedActions.GetAddOnRestrictionState(type)` | `state` | Current restriction state |
| `C_RestrictedActions.IsAddOnRestrictionActive(type)` | `active` | Is restriction currently active? |
| `C_RestrictedActions.CheckAllowProtectedFunctions(object [, silent])` | `protectedFunctionsAllowed` | Can object call protected funcs? |
| `InCombatLockdown()` | `inCombatLockdown` | Combat lockdown active? |

### Restriction Events

| Event | Description |
|-------|-------------|
| `ADDON_RESTRICTION_STATE_CHANGED` | Restriction state changed (entering/leaving instance) |
| `PLAYER_REGEN_DISABLED` | Entering combat |
| `PLAYER_REGEN_ENABLED` | Leaving combat |

---

## C_Log — Logging

| Function | Description |
|----------|-------------|
| `C_Log.LogMessage(message)` | Log info message |
| `C_Log.LogWarningMessage(message)` | Log warning |
| `C_Log.LogErrorMessage(message)` | Log error |
| `C_Log.LogMessageWithPriority(priority, message)` | Log with specific priority |

> **Note:** `ConsolePrint()` was removed in 12.0.0. Use `C_Log.LogMessage()` instead.

---

## FrameScript Functions

WoW provides special FrameScript functions for working with the secure/secret value system:

| Function | Returns | Description |
|----------|---------|-------------|
| `issecurevariable([table,] name)` | `isSecure, taintSource` | Check taint status |
| `issecretvalue(value)` | `isSecret` | Is value a secret? |
| `issecrettable(table)` | `isSecretOrContentsSecret` | Is table or contents secret? |
| `canaccessvalue(value)` | `isAccessible` | Can addon access this value? |
| `hasanysecretvalues(values)` | `isAnyValueSecret` | Any arg secret? |
| `scrubsecretvalues(values)` | `scrubbed` | Replace secrets with nil |
| `secretwrap(values)` | `wrapped` | Wrap values as secrets |
| `mapvalues(func, values)` | `mapped` | Map function over values (secret-safe) |
| `securecallfunction(func, ...)` | `results` | Call in secure context |
| `securecallmethod(obj, method, ...)` | `results` | Call method in secure context |
| `forceinsecure()` | — | Force insecure execution |
| `seterrorhandler(handler)` | — | Set global error handler |
| `geterrorhandler()` | `handler` | Get current error handler |

---

## Debugging Utilities

### Error Handling

```lua
-- Set a custom error handler
seterrorhandler(function(msg)
    -- msg is the error string
    print("ERROR:", msg)
end)

-- Protected call with error handling
local success, err = pcall(function()
    -- Code that might error
end)
if not success then
    print("Error:", err)
end

-- xpcall with message handler
local success, err = xpcall(function()
    error("something broke")
end, function(msg)
    return msg .. "\n" .. debugstack(2)
end)
```

### Debug Stack & Info

```lua
-- Get a stack trace
local stack = debugstack([thread,] [start [, count1 [, count2]]])

-- Get debug info
local info = debuglocals([thread,] [level])

-- Profile timing
debugprofilestart()
-- ... code to measure ...
local elapsed = debugprofilestop()  -- microseconds
```

### Slash Commands for Debugging

```lua
-- /dump expression — evaluates and prints
-- /run code — executes Lua code
-- /script code — same as /run
-- /console cvarName [value] — get/set console variables
```

---

## Common Patterns

### Deferred Initialization (Wait for Login)

```lua
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event)
    -- Safe to initialize — player is logged in
    self:UnregisterEvent(event)
    InitializeAddon()
end)
```

### Safe OnUpdate Throttle

```lua
local elapsed = 0
local THROTTLE = 0.1  -- 100ms
frame:SetScript("OnUpdate", function(self, dt)
    elapsed = elapsed + dt
    if elapsed < THROTTLE then return end
    elapsed = 0
    -- Do periodic work
end)
```

### Post-Combat Action Queue

```lua
local pendingActions = {}

local function QueueAction(action)
    if InCombatLockdown() then
        tinsert(pendingActions, action)
    else
        action()
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:SetScript("OnEvent", function()
    for _, action in ipairs(pendingActions) do
        action()
    end
    wipe(pendingActions)
end)
```

### Graceful Secret Value Handling (12.0.0)

```lua
-- When values might be secret, pass them directly to widgets
local name = UnitName(unit)  -- may be secret
myFontString:SetText(name)   -- widgets accept secrets

-- Check if a value is secret before trying operations
if not issecretvalue(someValue) then
    -- Safe to compare, do arithmetic, etc.
    if someValue == "expected" then ... end
else
    -- Cannot inspect — pass to UI widget directly
    myWidget:SetText(someValue)
end
```

---

## Gotchas & Restrictions

1. **No `require()`** — WoW has no module system. Use the TOC file to control load order. Libraries are embedded directly.
2. **`setfenv()` / `getfenv()`** — Severely restricted. Do not rely on environment manipulation.
3. **`collectgarbage()`** — Only `"count"` mode works. Cannot force GC collection.
4. **Taint is sticky** — Once a variable is tainted, it stays tainted. Even if you set it back to the original value, the taint remains.
5. **`print()` goes to chat** — Unlike standard Lua, `print()` outputs to the default chat frame, not stdout.
6. **String library additions** — WoW adds `strsplit`, `strjoin`, `strtrim`, and `strmatch` as globals (in addition to `string.match`).
7. **No `os.exit()`** — Cannot terminate the client programmatically.
8. **Coroutines work** — Full coroutine support is available and commonly used for async patterns.
9. **Secret values (12.0.0)** — Some API returns are now opaque "secret" values that cannot be inspected, compared, or used in arithmetic. See the `wow-api-important` instructions for full details.
10. **Instance restrictions (12.0.0)** — `SendAddonMessage()` is blocked in instances. Design addons to work without inter-player communication during instanced content.
