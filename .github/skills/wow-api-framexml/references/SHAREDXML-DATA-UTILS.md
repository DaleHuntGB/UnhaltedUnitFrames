# SharedXML — Data & Logic Utilities

> **Parent skill:** [wow-api-framexml](../SKILL.md)
> **Source:** [FrameXML functions — SharedXML](https://warcraft.wiki.gg/wiki/FrameXML_functions#SharedXML)
> **FrameXML source:** [SharedXML on GitHub](https://github.com/Gethe/wow-ui-source/tree/live/Interface/SharedXML)

SharedXML modules are shared between the main game UI and the login/character-select screen. This file covers **data, math, table, time, color, formatting, event, function, and link utilities**.

---

## AccountUtil

Source: [AccountUtil (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=GameLimitedMode_IsActive)

### `GameLimitedMode_IsActive()`
Returns whether the account is in Starter Edition (limited/trial) mode.

```lua
isLimited = GameLimitedMode_IsActive()
```

### `GetClampedCurrentExpansionLevel()`
Returns the current expansion level, clamped to what the account owns.

```lua
level = GetClampedCurrentExpansionLevel()
```

---

## AuraUtil

Source: [AuraUtil (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=FindAuraByName)

Utility functions for iterating over and finding auras (buffs/debuffs) on units.

### `AuraUtil.FindAura(predicate, unit, filter, predicateArg1, predicateArg2, predicateArg3)`
Iterates through auras on `unit` matching `filter` and returns the first aura for which `predicate` returns true.

```lua
auraData = AuraUtil.FindAura(predicate, unit, filter, predicateArg1, predicateArg2, predicateArg3)
```

### `AuraUtil.FindAuraByName(auraName, unit, filter)`
Finds the first aura on `unit` matching `auraName`.

```lua
auraData = AuraUtil.FindAuraByName(auraName, unit, filter)
```

**Arguments:**
- `auraName` (string) — Localized aura name to search for.
- `unit` (UnitId) — Unit to check (e.g., `"player"`, `"target"`).
- `filter` (string) — Filter string (e.g., `"HELPFUL"`, `"HARMFUL"`, `"PLAYER"`).

### `AuraUtil.ForEachAura(unit, filter, maxCount, func)`
Iterates over auras on `unit`, calling `func` for each one.

```lua
AuraUtil.ForEachAura(unit, filter, maxCount, func)
```

### `AuraUtil.ShouldSkipAuraUpdate(isFullUpdate, updatedAuraInfos, isRelevantFunc, ...)`
Determines whether an aura update event can be skipped (optimization for UNIT_AURA handling).

```lua
shouldSkip = AuraUtil.ShouldSkipAuraUpdate(isFullUpdate, updatedAuraInfos, isRelevantFunc, ...)
```

---

## ColorUtil

Source: [ColorUtil (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=CreateColorFromHexString)

Functions for creating and comparing colors, and getting class/faction colors.

### `CreateColorFromHexString(hexColor)`
Creates a ColorMixin from an 8-character hex string (AARRGGBB format).

```lua
color = CreateColorFromHexString("FF00FF00")  -- opaque green
```

### `CreateColorFromBytes(r, g, b, a)`
Creates a ColorMixin from byte values (0–255).

```lua
color = CreateColorFromBytes(255, 0, 128, 255)
```

### `AreColorsEqual(left, right)`
Compares two ColorMixin objects for equality.

```lua
isEqual = AreColorsEqual(color1, color2)
```

### `GetClassColor(classFilename)`
Returns r, g, b, hex string for a class.

```lua
r, g, b, hexColor = GetClassColor("WARRIOR")
```

**Arguments:**
- `classFilename` (string) — English class token (e.g., `"WARRIOR"`, `"MAGE"`, `"DRUID"`).

### `GetClassColorObj(classFilename)`
Returns a ColorMixin object for the class.

```lua
color = GetClassColorObj("PALADIN")
```

### `GetClassColoredTextForUnit(unit, text)`
Wraps `text` in the class color escape codes for the given unit.

```lua
coloredText = GetClassColoredTextForUnit("player", "MyName")
```

### `GetFactionColor(factionGroupTag)`
Returns a ColorMixin for a faction (e.g., `"Alliance"`, `"Horde"`).

```lua
color = GetFactionColor("Alliance")
```

---

## CvarUtil

Source: [CvarUtil (FrameXML)](http://townlong-yak.com/framexml/go/RegisterCVar)

Wrappers around the CVar (Console Variable) system.

### `RegisterCVar(name, value)`
Registers a new CVar with a default value.

```lua
RegisterCVar("myAddonCVar", "1")
```

### `ResetTestCvars()`
Resets all test CVars.

### `SetCVar(name, value, eventName)`
Sets a CVar value. Returns success.

```lua
success = SetCVar("nameplateShowFriends", "1")
```

### `GetCVar(name)`
Gets the current string value of a CVar.

```lua
value = GetCVar("nameplateShowFriends")
```

### `GetCVarBool(name)`
Gets the boolean value of a CVar.

```lua
isEnabled = GetCVarBool("nameplateShowFriends")
```

### `GetCVarDefault(name)`
Gets the default value of a CVar.

```lua
defaultValue = GetCVarDefault("nameplateShowFriends")
```

### `SetCVarBitfield(name, index, value, scriptCVar)`
Sets a specific bit in a bitfield CVar.

```lua
success = SetCVarBitfield("closedInfoFrames", 1, true)
```

### `GetCVarBitfield(name, index)`
Gets a specific bit from a bitfield CVar.

```lua
isSet = GetCVarBitfield("closedInfoFrames", 1)
```

### `SetCVarToDefault(name)`
Resets a CVar to its default value.

```lua
SetCVarToDefault("nameplateShowFriends")
```

---

## EasingUtil

Source: [EasingUtil (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=InQuadratic)

Mathematical easing functions for smooth animations. Each takes a `percent` parameter (0–1) and returns the eased value.

| Function | Easing Type |
|----------|-------------|
| `EasingUtil.InQuadratic(p)` | Quadratic ease-in |
| `EasingUtil.OutQuadratic(p)` | Quadratic ease-out |
| `EasingUtil.InOutQuadratic(p)` | Quadratic ease-in-out |
| `EasingUtil.InCubic(p)` | Cubic ease-in |
| `EasingUtil.OutCubic(p)` | Cubic ease-out |
| `EasingUtil.InOutCubic(p)` | Cubic ease-in-out |
| `EasingUtil.InQuartic(p)` | Quartic ease-in |
| `EasingUtil.OutQuartic(p)` | Quartic ease-out |
| `EasingUtil.InOutQuartic(p)` | Quartic ease-in-out |
| `EasingUtil.InQuintic(p)` | Quintic ease-in |
| `EasingUtil.OutQuintic(p)` | Quintic ease-out |
| `EasingUtil.InOutQuintic(p)` | Quintic ease-in-out |

**Syntax:**
```lua
easedValue = EasingUtil.InOutCubic(0.5)  -- returns ~0.5 for midpoint
```

---

## ErrorUtil

Source: [ErrorUtil (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=CallErrorHandler)

### `CallErrorHandler(...)`
Invokes the registered error handler (used by `pcall`/`xpcall` patterns to report errors without crashing).

```lua
CallErrorHandler(errorMessage)
```

---

## EventRegistry

Source: [EventRegistry (Wiki)](https://warcraft.wiki.gg/wiki/EventRegistry)

A global `CallbackRegistryMixin` instance for custom event dispatch (independent of frame-based events).

### `EventRegistry:RegisterCallback(event, func, ...)`
Registers a callback for a custom event name.

```lua
EventRegistry:RegisterCallback("MyAddon.SomethingHappened", function(owner, arg1)
    print("Got it!", arg1)
end, owner)
```

### `EventRegistry:TriggerEvent(event, ...)`
Fires a custom event, invoking all registered callbacks.

```lua
EventRegistry:TriggerEvent("MyAddon.SomethingHappened", someData)
```

### `EventRegistry:RegisterFrameEventAndCallback(event, func, ...)`
Registers for both a WoW frame event AND registers a callback.

---

## EventUtil

Source: [EventUtil (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=ContinueAfterAllEvents)

Convenience functions for event-driven async patterns.

### `EventUtil.ContinueAfterAllEvents(callback, ...)`
Calls `callback` after **all** listed events have fired at least once.

```lua
EventUtil.ContinueAfterAllEvents(function()
    print("Both events fired!")
end, "PLAYER_LOGIN", "ADDON_LOADED")
```

### `EventUtil.ContinueOnVariablesLoaded(callback)`
Calls `callback` after `VARIABLES_LOADED` has fired.

```lua
EventUtil.ContinueOnVariablesLoaded(function()
    -- SavedVariables are available
end)
```

### `EventUtil.ContinueOnAddOnLoaded(addOnName, callback)`
Calls `callback` after the specified addon's `ADDON_LOADED` event fires.

```lua
EventUtil.ContinueOnAddOnLoaded("MyAddon", function()
    -- MyAddon has loaded
end)
```

### `EventUtil.RegisterOnceFrameEventAndCallback(frameEvent, callback, ...)`
Registers for a frame event and fires the callback only once, then unregisters.

```lua
EventUtil.RegisterOnceFrameEventAndCallback("PLAYER_ENTERING_WORLD", function()
    print("First zone entered!")
end)
```

### `EventUtil.CreateCallbackHandleContainer()`
Creates a container for managing multiple callback handles with bulk unregistration.

```lua
local handles = EventUtil.CreateCallbackHandleContainer()
```

---

## Flags

Source: [Flags (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=Flags_CreateMask)

Bitmask utility functions.

### `Flags_CreateMask(...)`
Creates a bitmask from a list of bit indices.

```lua
mask = Flags_CreateMask(0, 2, 5)  -- bits 0, 2, and 5 set
```

### `Flags_CreateMaskFromTable(flagsTable)`
Creates a bitmask from a table of bit indices.

### `FlagsUtil.IsSet(bitMask, flagOrMask)`
Checks if a flag or mask is set within a bitmask.

```lua
isSet = FlagsUtil.IsSet(myMask, 4)  -- checks if bit 2 is set
```

---

## FormattingUtil

Source: [FormattingUtil (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=FormatLargeNumber)

Text and number formatting helpers.

### `FormatLargeNumber(amount)`
Formats a number with locale-appropriate thousands separators (e.g., `1234567` → `"1,234,567"`).

```lua
text = FormatLargeNumber(1234567)
```

### `FormatPercentage(percentage, roundToNearestInteger)`
Formats a decimal as a percentage string (e.g., `0.756` → `"75.6%"`).

```lua
text = FormatPercentage(0.756, false)
```

### `FormatFraction(numerator, denominator)`
Formats two numbers as a fraction string.

```lua
text = FormatFraction(3, 10)  -- "3/10"
```

### `FormatValueWithSign(value)`
Formats a number with a leading `+` or `-` sign.

```lua
text = FormatValueWithSign(15)   -- "+15"
text = FormatValueWithSign(-3)   -- "-3"
```

### `GetMoneyString(money, separateThousands)`
Converts copper amount to a gold/silver/copper display string with icons.

```lua
text = GetMoneyString(12345678, true)
```

### `GetCurrencyString(currencyID, overrideAmount, colorCode, abbreviate)`
Returns a formatted string for a specific currency.

```lua
text = GetCurrencyString(1813, 500)
```

### `GetCurrenciesString(currencies)`
Returns a formatted string for multiple currencies.

### `SplitTextIntoLines(text, delimiter)`
Splits text into separate lines by a delimiter.

### `SplitTextIntoHeaderAndNonHeader(text)`
Splits text into a header line and remaining body.

### `GetHighlightedNumberDifferenceString(baseString, newString)`
Returns a string highlighting the differences between two number strings.

### `FormatUnreadMailTooltip(tooltip, headerText, senders)`
Formats an unread mail tooltip with sender information.

### `ReplaceGenderTokens(string, gender)`
Replaces gendered placeholder tokens in a localized string.

```lua
text = ReplaceGenderTokens("$his:her$ sword", 2)  -- "his sword"
```

---

## FunctionUtil

Source: [FunctionUtil (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=ExecuteFrameScript)

Helpers for function invocation and deferred execution.

### `ExecuteFrameScript(frame, scriptName, ...)`
Manually calls the handler for a named frame script (e.g., "OnClick", "OnEnter").

```lua
ExecuteFrameScript(myButton, "OnClick", "LeftButton")
```

### `CallMethodOnNearestAncestor(self, methodName, ...)`
Walks up the frame parent chain and calls the first ancestor that has `methodName`.

```lua
CallMethodOnNearestAncestor(self, "UpdateLayout")
```

### `GetValueOrCallFunction(tbl, key, ...)`
Returns `tbl[key]` if it's a value, or calls it if it's a function.

```lua
local val = GetValueOrCallFunction(config, "width")
```

### `GenerateClosure(f, ...)`
Creates a closure that calls `f` with pre-bound arguments (partial application / currying).

```lua
local fn = GenerateClosure(print, "Hello")
fn()  -- prints "Hello"
```

### `RunNextFrame(callback)`
Schedules `callback` to execute on the next frame update (using `C_Timer.After(0, ...)`-like behavior).

```lua
RunNextFrame(function()
    print("This runs next frame")
end)
```

---

## InterfaceUtil

Source: [InterfaceUtil (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=ReloadUI)

### `ReloadUI()`
Reloads the entire UI. Equivalent to `/reload`.

```lua
ReloadUI()
```

### `StoreInterfaceUtil.OpenToSubscriptionProduct()`
Opens the in-game store to the subscription product page.

---

## LinkUtil

Source: [LinkUtil (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=ExtractHyperlinkString)

Functions for parsing and extracting data from [hyperlinks](https://warcraft.wiki.gg/wiki/Hyperlinks).

### `ExtractHyperlinkString(linkString)`
Extracts the raw hyperlink content from a formatted link string.

```lua
linkType, linkData = ExtractHyperlinkString("|cff0070dd|Hitem:12345::::::::|h[Cool Item]|h|r")
```

### `ExtractQuestRewardID(linkString)`
Extracts a quest reward ID from a link string.

### `GetItemInfoFromHyperlink(link)`
Parses item info from a hyperlink.

```lua
itemID = GetItemInfoFromHyperlink("|Hitem:12345|h[Item]|h")
```

### `GetAchievementInfoFromHyperlink(link)`
Parses achievement info from a hyperlink.

### `GetURLIndexAndLoadURL(self, link)`
Extracts a URL from a link reference and opens it.

---

## MathUtil

Source: [MathUtil (FrameXML)](http://townlong-yak.com/framexml/go/Lerp)

Mathematical utility functions used throughout the UI.

### `Lerp(startValue, endValue, amount)`
Linearly interpolates between two values. `amount` is in [0, 1].

```lua
val = Lerp(0, 100, 0.5)  -- 50
```

### `Clamp(value, min, max)`
Clamps a value to a range.

```lua
val = Clamp(150, 0, 100)  -- 100
```

### `Saturate(value)`
Clamps a value to [0, 1]. Equivalent to `Clamp(value, 0, 1)`.

```lua
val = Saturate(1.5)  -- 1.0
```

### `Wrap(value, max)`
Wraps a value around a maximum (modular arithmetic).

```lua
val = Wrap(5, 3)  -- 2
```

### `ClampDegrees(value)`
Clamps a degree value to [0, 360).

### `ClampMod(value, mod)`
Clamps a value using modular arithmetic.

### `NegateIf(value, condition)`
Negates `value` if `condition` is true.

```lua
val = NegateIf(5, true)  -- -5
```

### `Round(value)`
Rounds a number to the nearest integer.

```lua
val = Round(3.7)  -- 4
```

### `Square(value)`
Returns `value * value`.

```lua
val = Square(5)  -- 25
```

### `PercentageBetween(value, startValue, endValue)`
Returns the percentage of `value` between `startValue` and `endValue` (inverse lerp).

```lua
pct = PercentageBetween(50, 0, 100)  -- 0.5
```

### `ClampedPercentageBetween(value, startValue, endValue)`
Like `PercentageBetween` but clamped to [0, 1].

### `DeltaLerp(startValue, endValue, amount, timeSec)`
Delta-time aware lerp for frame-rate-independent interpolation.

### `FrameDeltaLerp(startValue, endValue, amount)`
Frame-delta lerp using the current frame's elapsed time.

### `RandomFloatInRange(minValue, maxValue)`
Returns a random float between min and max.

```lua
val = RandomFloatInRange(1.0, 5.0)
```

### `CalculateDistanceSq(x1, y1, x2, y2)`
Squared distance between two 2D points (avoids sqrt for performance).

```lua
distSq = CalculateDistanceSq(0, 0, 3, 4)  -- 25
```

### `CalculateDistance(x1, y1, x2, y2)`
Euclidean distance between two 2D points.

```lua
dist = CalculateDistance(0, 0, 3, 4)  -- 5
```

### `CalculateAngleBetween(x1, y1, x2, y2)`
Returns the angle in radians between two 2D points.

```lua
angle = CalculateAngleBetween(0, 0, 1, 1)
```

---

## RestrictedInfrastructure

Source: [RestrictedInfrastructure (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=tostringall)

Low-level functions for the restricted (secure) execution environment.

### `tostringall(...)`
Converts all arguments to strings (variadic `tostring`).

```lua
a, b, c = tostringall(1, nil, "hi")  -- "1", "nil", "hi"
```

### `IsFrameHandle(handle, protected)`
Checks if a value is a valid frame handle.

### `GetFrameHandleFrame(handle, protected, onlyProtected)`
Gets the actual frame from a frame handle.

### `GetFrameHandle(frame, protected)`
Gets a frame handle for a frame.

---

## TableUtil

Source: [TableUtil (FrameXML)](http://townlong-yak.com/framexml/go/tDeleteItem)

Essential table manipulation functions used pervasively in addon code.

### `ripairs(tbl)`
Reverse-iterates over a sequential table (from last element to first).

```lua
for i, v in ripairs(myTable) do
    print(i, v)
end
```

### `tDeleteItem(tbl, item)`
Removes the first occurrence of `item` from a sequential table (by value, not index).

```lua
local t = {"a", "b", "c"}
tDeleteItem(t, "b")  -- t = {"a", "c"}
```

### `tIndexOf(tbl, item)`
Returns the index of `item` in a sequential table, or `nil` if not found.

```lua
local idx = tIndexOf({"a", "b", "c"}, "b")  -- 2
```

### `tContains(tbl, item)`
Returns `true` if a sequential table contains `item`.

```lua
if tContains(myList, "target") then ... end
```

### `tCompare(lhsTable, rhsTable [, depth])`
Deep-compares two tables. Optional `depth` limits recursion.

```lua
isEqual = tCompare({1, 2}, {1, 2})  -- true
```

### `tInvert(tbl)`
Returns an inverted table where keys become values and values become keys.

```lua
local inv = tInvert({"a", "b", "c"})  -- {a=1, b=2, c=3}
```

### `tFilter(tbl, pred, isIndexTable)`
Filters a table using a predicate function.

```lua
local evens = tFilter({1,2,3,4}, function(v) return v % 2 == 0 end, true)
```

### `tAppendAll(table, addedArray)`
Appends all elements from `addedArray` to the end of `table`.

```lua
local t = {1, 2}
tAppendAll(t, {3, 4})  -- t = {1, 2, 3, 4}
```

### `tUnorderedRemove(tbl, index)`
Removes element at `index` by swapping with the last element (O(1) but doesn't preserve order).

### `CopyTable(settings [, shallow])`
Returns a copy of a table. Deep copy by default; pass `true` for shallow.

```lua
local copy = CopyTable(originalTable)
```

### `AccumulateIf(tbl, pred)`
Counts elements in `tbl` that satisfy `pred`.

```lua
local count = AccumulateIf(items, function(item) return item.active end)
```

### `ContainsIf(tbl, pred)`
Returns `true` if any element satisfies `pred`.

```lua
local hasActive = ContainsIf(items, function(item) return item.active end)
```

### `FindInTableIf(tbl, pred)`
Returns the key and value of the first element satisfying `pred`.

```lua
local key, val = FindInTableIf(items, function(item) return item.name == "Sword" end)
```

### `SafePack(...)`
Like `table.pack(...)` but sets `.n` explicitly for safe iteration over nil values.

```lua
local packed = SafePack(1, nil, 3)  -- {[1]=1, [3]=3, n=3}
```

### `SafeUnpack(tbl)`
Unpacks a table using `.n` to handle embedded nils.

```lua
local a, b, c = SafeUnpack(packed)
```

---

## TimeUtil

Source: [TimeUtil (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=SecondsToTime)

Functions for formatting and converting time values.

### `SecondsToTime(seconds, noSeconds, notAbbreviated, maxCount, roundUp)`
Converts seconds to a localized readable string (e.g., `"3 min 20 sec"`).

```lua
text = SecondsToTime(200)           -- "3 min 20 sec"
text = SecondsToTime(200, true)     -- "3 min"
text = SecondsToTime(200, false, true)  -- "3 Minutes 20 Seconds"
```

**Arguments:**
- `seconds` (number) — Time in seconds.
- `noSeconds` (boolean) — Omit the seconds component.
- `notAbbreviated` (boolean) — Use full words instead of abbreviations.
- `maxCount` (number) — Maximum number of time units to display (default 2).
- `roundUp` (boolean) — Round up the smallest displayed unit.

### `SecondsToTimeAbbrev(seconds)`
Converts seconds to a short abbreviated string (e.g., `"3m"`, `"1h"`, `"2d"`).

```lua
text = SecondsToTimeAbbrev(3600)  -- "1h"
```

### `SecondsToClock(seconds, displayZeroHours)`
Converts seconds to a clock-style format (e.g., `"1:30:00"` or `"30:00"`).

```lua
text = SecondsToClock(5400)  -- "1:30:00"
```

### `SecondsToMinutes(seconds)`
Divides seconds by 60.

```lua
minutes = SecondsToMinutes(120)  -- 2
```

### `MinutesToSeconds(minutes)`
Multiplies minutes by 60.

```lua
seconds = MinutesToSeconds(5)  -- 300
```

### `HasTimePassed(testTime, amountOfTime)`
Checks whether `amountOfTime` seconds have elapsed since `testTime`.

```lua
if HasTimePassed(lastUpdate, 5) then ... end
```

### `FormatShortDate(day, month, year)`
Formats a date in short locale-appropriate format.

```lua
text = FormatShortDate(12, 2, 2026)
```

---

## UnitUtil

Source: [UnitUtil (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=GetPlayerGuid)

### `GetPlayerGuid()`
Returns the player's GUID string.

```lua
guid = GetPlayerGuid()
```

### `IsPlayerGuid(guid)`
Returns true if the given GUID belongs to the current player.

```lua
isMe = IsPlayerGuid(someGuid)
```

### `IsPlayerInitialSpec()`
Returns true if the player is still using their initial (unselected) specialization.

```lua
isInitial = IsPlayerInitialSpec()
```
