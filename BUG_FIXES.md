# Bug Fixes - UnhaltedUnitFrames

This document tracks bug fixes for errors reported during gameplay, validation testing, or by error-reporting addons.

---

## Session 120-HotFix1 (Phase 5) - Pet & Party Frame Visibility Code Errors Fixed

**[Syntax Error & Nil Reference - UpdatePetFrameVisibility/UpdatePartyFrameVisibility]**  
**File(s):** [Core/UnitFrame.lua](./Core/UnitFrame.lua) (Line: 569), [Core/Core.lua](./Core/Core.lua) (Lines: 188, 203)  
**Change:** Fixed extra `end` statement, added pcall protection to event handlers, added nil checks  
**Explanation:** Issue: (1) Extra `end` statement at line 569 in UnitFrame.lua causing syntax error `'<eof>' expected near 'end'`. (2) OnPetUpdate/OnGroupUpdate calling UpdatePetFrameVisibility and UpdatePartyFrameVisibility before functions were robustly available. (3) OnGroupUpdate accessing UUF.db.profile without safety checks. Fixes: (1) Removed extra `end` statement at line 569. (2) Wrapped function calls with `pcall()` for safety - prevents errors if functions don't exist yet. (3) Added nil checks for UUF.db and UUF.db.profile before accessing nested properties. (4) Ensured all calls are already protected by `if UUF.UpdatePetFrameVisibility then` pattern. These changes prevent addon load failures and runtime errors while maintaining the pet/party frame visibility management system.  
**Date/Time:** 2026-02-19 06:32:00

---

## Session 120-Extended (Phase 5) - Pet & Party Frame Visibility Extended Fix

**[Pet Frame & Party Frame Visibility Issues - Extended Multi-System Fix]**  
**File(s):** [Core/UnitFrame.lua](./Core/UnitFrame.lua) (Lines: 418-468, 500-534, 540-570), [Core/Core.lua](./Core/Core.lua) (Lines: 145-175, 189-203)  
**Change:** Extended pet frame fix to also handle party frame visibility in Delves and other edge cases  
**Explanation:** Extended the pet frame visibility fix to also address party frame issues in Delves where NPC companions (like Bronzebeard) weren't showing. Added comprehensive visibility management for party frames similar to pet frames. (1) **Added UpdatePartyFrameVisibility()** - checks each party frame (party1-party5 or player if HidePlayer enabled) and ensures visibility based on actual UnitExists checks. (2) **Integrated with periodic timer** - both UpdatePetFrameVisibility() and UpdatePartyFrameVisibility() called every 0.5s to catch edge cases. (3) **Event-driven updates** - UpdatePartyFrameVisibility() called from OnGroupUpdate() when group composition changes. (4) **Handles Delves** - specifically addresses NPC companion visibility in Delves by checking if the unit exists and showing the frame regardless of RegisterUnitWatch state. This dual approach ensures both pet frames (Warlock demons, Hunter pets, etc.) and party frames (Delve companions) display correctly even when RegisterUnitWatch or oUF's internal visibility logic fails.  
**Date/Time:** 2026-02-19 06:28:00

---

## Session 120-Revised (Phase 5) - Warlock Pet Frame Not Showing - Root Cause Fix

**[Warlock Pet Frame Not Visible - RegisterUnitWatch Override Issue - CRITICAL]**  
**File(s):** [Core/UnitFrame.lua](./Core/UnitFrame.lua) (Lines: 418-468, 471-493, 598-612), [Core/Core.lua](./Core/Core.lua) (Lines: 145-161)  
**Change:** Removed RegisterUnitWatch from pet frames, added manual visibility management with script hooks and periodic monitoring  
**Explanation:** Initial fix to pet frame visibility was insufficient because RegisterUnitWatch was still being called on the pet frame. When RegisterUnitWatch is active, it creates an internal state driver that controls the frame's visibility based on `UnitExists("pet")`. For Warlocks, `UnitExists("pet")` returns false initially for demon pets, so the state driver kept the frame hidden regardless of manual `:Show()` calls. Root cause: oUF's framework (used by UUF) doesn't properly handle non-standard pet units like Warlock demons. Solution: (1) **Skip RegisterUnitWatch for pet unit** - pet frame is shown without RegisterUnitWatch registration. (2) **Add OnShow/OnHide script hooks** - intercept any attempts to hide the pet frame and immediately re-show it if a pet exists. (3) **Add script hook to OnHide** - uses both `UnitExists("pet")` and `UnitExists("playerpet")` checks to handle all pet types. (4) **Periodic visibility monitoring** - 0.5s ticker continuously checks and corrects pet frame visibility to catch edge cases. (5) **Event-driven updates** - UpdatePetFrameVisibility called from OnPetUpdate (COMPANION_UPDATE/UNIT_PET events) and from ToggleUnitFrameVisibility when user enables/disables pet frame. This multi-layered approach ensures pet frames stay visible for all classes including Warlocks, Hunters, Death Knights, and any class with summonable pets.  
**Date/Time:** 2026-02-19 06:22:00

---

## Session 120 (Phase 5) - Pet Frame Not Showing for Warlock Class

**[Pet Frame Not Visible for Warlocks - Visibility Registration Issue]**  
**File(s):** [Core/UnitFrame.lua](./Core/UnitFrame.lua) (Lines: 471-493, 556-566), [Core/Core.lua](./Core/Core.lua) (Lines: 145-155, 162-167)  
**Change:** Added custom pet frame visibility handler to bypass RegisterUnitWatch limitations for Warlock demon pets  
**Explanation:** Pet frames were not showing for Warlock class even when "Pet Enabled" was toggled on in the GUI. Investigation revealed that oUF's `RegisterUnitWatch()` relies on `UnitExists("pet")` to control frame visibility. For Warlocks, `UnitExists("pet")` returns false initially for demon pets, so the frame would not display. The issue is that while oUF converts `playerpet` → `pet` during active unit evaluation, this conversion doesn't apply to initial visibility registration. Solution: (1) Added `UpdatePetFrameVisibility()` function in UnitFrame.lua that checks both `UnitExists("pet")` and `UnitExists("playerpet")` to handle all pet types including Warlock demons. (2) Called this function from `OnPetUpdate()` whenever COMPANION_UPDATE/UNIT_PET events fire. (3) Called during initialization 0.1s after frame spawn to ensure initial visibility. (4) Called when user toggles Pet frame enabled/disabled in GUI. Now pet frames display correctly for Warlocks, Hunters, Death Knights, and any other class with pets. **(SUPERSEDED BY SESSION 120-REVISED AND EXTENDED)**  
**Date/Time:** 2026-02-19 06:15:00

---

## Session 119 (Phase 5) - DebugPanel UI Issues & Message Routing

**[DebugPanel UI Issues - Duplicate Close Buttons & No Messages]**  
**File(s):** [Core/DebugPanel.lua](./Core/DebugPanel.lua) (Lines: 42-46, 196-200, 95-110), [Core/DebugOutput.lua](./Core/DebugOutput.lua) (Line: 83)  
**Change:** Fixed duplicate close buttons, TIER_INFO message routing, added debug toggle and settings improvements  
**Explanation:** User reported three issues with debug panel: (1) No messages appearing from Validator, (2) Duplicate X close buttons on both main panel and settings panel, (3) Empty settings frame. Investigation revealed: (1) TIER_INFO messages only routed to panel when Debug.enabled=true (line 83), but default is false. Validator uses TIER_INFO so nothing appeared. Fixed by removing enabled check for TIER_INFO - panel should always show INFO messages when open, only gate TIER_DEBUG. (2) Both debug panel (lines 42-46) and settings panel (lines 196-200) manually created close buttons even though "BasicFrameTemplateWithInset" template already provides one at same position. Removed duplicate manual close buttons. (3) Settings frame wasn't empty, but had no controls to enable debug or manage all systems quickly. Added: Enable/Disable debug mode toggle button to main panel, Enable All/Disable All buttons to settings panel, help text explaining DEBUG tier requires system enablement. Now users can see INFO messages immediately when opening panel, toggle debug mode easily, and bulk-enable/disable systems.  
**Date/Time:** 2026-02-19 05:40:00

---

## Session 119 (Phase 5) - DebugOutput API Usage Error

**[DebugOutput API Usage Error - Phase 1 Implementation - CRITICAL]**  
**File(s):** [Core/Validator.lua](./Core/Validator.lua), [Core/ReactiveConfig.lua](./Core/ReactiveConfig.lua), [Core/PerformanceProfiler.lua](./Core/PerformanceProfiler.lua)  
**Change:** Fixed incorrect DebugOutput API calls - replaced non-existent Info/Critical/Debug methods with correct Output(system, message, tier) API  
**Explanation:** Phase 1 code audit implementation used incorrect DebugOutput API. Called UUF.DebugOutput:Info(), :Critical(), and :Debug() methods which don't exist. These were assumed convenience methods based on common patterns, but DebugOutput only exposes UUF.DebugOutput:Output(systemName, message, tier) where tier is TIER_CRITICAL (1), TIER_INFO (2), or TIER_DEBUG (3). This caused addon to fail loading with error "attempt to call method 'Info' (a nil value)" in ReactiveConfig.lua:118 during InitializeConfigWatchers(). Fixed all 50+ incorrect calls: Validator (5 calls), ReactiveConfig (8 calls), PerformanceProfiler (4 status + 30+ PrintAnalysis calls). All now properly specify system name as first parameter, message as second, and tier constant as third. This was a complete API misunderstanding - should have verified actual API in DebugOutput.lua (lines 1-100) before implementation.  
**Date/Time:** 2026-02-19 05:36:00

---

## Session 119 (Phase 5) - DirtyPriorityOptimizer Hook Syntax Error

**[DirtyPriorityOptimizer originalMarkDirty Nil Reference - CRITICAL]**  
**File(s):** [Core/DirtyPriorityOptimizer.lua](./Core/DirtyPriorityOptimizer.lua) (Line: 236)  
**Change:** Fixed syntax error in local variable declaration - removed space between 'original' and 'MarkDirty'  
**Explanation:** EventCoalescer was spamming hundreds of errors: "attempt to call global 'originalMarkDirty' (a nil value)" at line 249. Investigation revealed IntegrateWithDirtyFlags() function (line 236) had syntax error: `local original MarkDirty = UUF.DirtyFlagManager.MarkDirty` with a space between 'original' and 'MarkDirty'. Lua interpreted this as two separate statements, causing originalMarkDirty to be nil. When the hook tried to call originalMarkDirty(self, frame, reason, priority) at line 249, it failed because the variable didn't exist. This broke the entire dirty flag optimization system - every UNIT_HEALTH and UNIT_POWER_UPDATE event triggered an error instead of marking frames dirty. Fixed by removing the space: `local originalMarkDirty = UUF.DirtyFlagManager.MarkDirty`. System now hooks correctly and ML priority optimization works as intended.  
**Date/Time:** 2026-02-19 05:12:00

---

## Session 119 (Phase 5) - UUF.Units Architectural Fix

**[UUF.Units Table Missing - Frame Spawning Issue]**  
**File(s):** [Core/Globals.lua](./Core/Globals.lua) (Line: 16), [Core/UnitFrame.lua](./Core/UnitFrame.lua) (Lines: 351, 371, 389)  
**Change:** Added UUF.Units table initialization and population during frame spawning  
**Explanation:** System diagnostics showed "UUF.Units: Missing" and validator showed only PLAYER frame existed. Investigation revealed architectural mismatch: CoalescingIntegration (line 161) and DirtyFlagManager (lines 474-481) expected UUF.Units["player"] table pattern, but existing frame storage used UUF.PLAYER/UUF.TARGET uppercase property pattern established in UnitFrame.lua. The UUF.Units table was referenced in 9 locations but never initialized anywhere in the codebase. This prevented event coalescing from working - events were properly coalesced but handlers couldn't find frames to mark dirty. Fixed by: (1) Adding `UUF.Units = {}` initialization in Globals.lua alongside other core tables (BOSS_FRAMES, PARTY_FRAMES), (2) Populating table during frame spawning in SpawnUnitFrame: `UUF.Units[unit .. i] = bossFrame` for boss frames, `UUF.Units[spawnUnit] = partyFrame` for party frames, and `UUF.Units[unit] = singleFrame` for single frames. Maintains backward compatibility (UUF.PLAYER still works) while providing modern table-based access for Phase 5 optimization systems.  
**Date/Time:** 2026-02-19 04:52:00

---

## Session 119 (Phase 5) - Lua 5.1 Compatibility Fix

**[DirtyFlagManager Lua 5.1 goto Syntax Error - CRITICAL]**  
**File(s):** [Core/DirtyFlagManager.lua](./Core/DirtyFlagManager.lua) (Lines: 252-302)  
**Change:** Removed `goto continue` statements and restructured with if/elseif conditionals  
**Explanation:** DirtyFlagManager completely failed to load, causing system diagnostics to show "DirtyFlagManager: Missing" and preventing UUF.Units from being populated. Investigation revealed ProcessDirty() function used `goto continue` labels (lines 264, 299) which are Lua 5.2+ syntax. WoW uses Lua 5.1 which does not support goto statements. This caused a parse error that prevented the entire module from loading. Restructured the frame processing loop to use if/elseif conditionals: `local isValid = _ValidateFrame(frame)` followed by `if not isValid then [skip invalid] elseif data and data.dirty then [process valid]`. This maintains identical logic (skip invalid frames, process valid dirty frames) without requiring goto. System now loads properly and all dependent systems (CoalescingIntegration, frame spawning) work correctly.  
**Date/Time:** 2026-02-19 04:38:00

---

## Session 119 - Debug Configuration Path Error & Database Initialization

**[DebugOutput Database Access Before Initialization]**  
**File(s):** [Core/DebugOutput.lua](./Core/DebugOutput.lua) (Lines: 12-16, 29-38, 84-102, 141-165), [Core/DebugPanel.lua](./Core/DebugPanel.lua) (Lines: 27-32, 205-220, 232-244), [Core/Core.lua](./Core/Core.lua) (Line: 84)  
**Change:** Added nil checks for UUF.db.global.Debug throughout debug system  
**Explanation:** After fixing the config path, DebugOutput:Init() was still failing with "attempt to index field 'Debug' (a nil value)" because it tried to access UUF.db.global.Debug.maxMessages before the database was fully initialized. While UUF.db is created in OnInitialize(), the nested global.Debug table may not exist on fresh installs or before AceDB applies defaults. Added comprehensive nil checks in all functions: Init(), Output(), GetColorForTier(), SetEnabled(), ToggleSystem() in DebugOutput; OnDragStop handler, system checkboxes loop, Show(), and Hide() in DebugPanel; and showPanel check in Core.lua. System now gracefully handles missing configuration with safe defaults (500 message buffer, default colors, critical errors still displayed even if DB unavailable).  
**Date/Time:** 2026-02-19 04:05:00

**[DebugOutput Initialization Error: Incorrect Config Path]**  
**File(s):** [Core/DebugOutput.lua](./Core/DebugOutput.lua) (Lines: 14, 30-31, 38, 66-73, 82-84, 141-149), [Core/DebugPanel.lua](./Core/DebugPanel.lua) (Lines: 28, 206, 209, 211, 232, 240), [Core/Core.lua](./Core/Core.lua) (Line: 84)  
**Change:** Changed all references from `UUF.db.debug` to `UUF.db.global.Debug`  
**Explanation:** DebugOutput.lua was attempting to access `UUF.db.debug` on initialization (line 14), causing "attempt to index field 'debug' (a nil value)" error. The Debug configuration is stored in the global section of Defaults.lua as `UUF.db.global.Debug` (with capital D), not in the profile section. Updated all 15+ references across three files to use the correct path: `UUF.db.global.Debug.maxMessages`, `UUF.db.global.Debug.enabled`, `UUF.db.global.Debug.systems`, `UUF.db.global.Debug.colors`, `UUF.db.global.Debug.timestamp`, `UUF.db.global.Debug.showPanel`, and `UUF.db.global.Debug.panel`.  
**Date/Time:** 2026-02-19 03:56:08

---

## Session 118 - PrintStats Method & Level Up Event Handling

**[PrintStats() Method Missing]**  
**File(s):** [Core/PerformanceDashboard.lua](./Core/PerformanceDashboard.lua) (Lines: 384-407)  
**Change:** Added PrintStats() method to PerformanceDashboard  
**Explanation:** User attempted to run `/run UUF.PerformanceDashboard:PrintStats()` but the method didn't exist, causing "attempt to call method 'PrintStats' (a nil value)" error. Added PrintStats() that displays FPS, latency, memory usage, frame pool statistics, and event coalescing stats to chat. This provides a quick way to check performance metrics without opening the full dashboard UI.  
**Date/Time:** 2026-02-19 04:45:00

**[Unit Frames Losing Info on Level Up]**  
**File(s):** [Core/Core.lua](./Core/Core.lua) (Lines: 217-218, 233-245)  
**Change:** Added PLAYER_LEVEL_UP and UNIT_LEVEL event handlers  
**Explanation:** When player leveled up, unit frames lost displayed information (player name, level, etc.) because the addon wasn't listening to level change events. Added PLAYER_LEVEL_UP and UNIT_LEVEL event registration in _SetupEventDispatcher(), with handlers that trigger UpdateAllUnitFrames() on player level up and UpdateUnitFrame() for specific unit level changes. Added 0.1s delay via C_Timer.After to ensure game state is fully updated before refreshing frames.  
**Date/Time:** 2026-02-19 04:45:00

---

## Session 117 - Debug Output System Implementation

**[DEBUG OUTPUT SYSTEM - New Feature]**  
**File(s):** [Core/DebugOutput.lua](./Core/DebugOutput.lua) (NEW), [Core/DebugPanel.lua](./Core/DebugPanel.lua) (NEW)  
**Change:** Implemented comprehensive debug output system to prevent chat spam  
**Explanation:** Addon testing and diagnostic messages were previously spamming the chat frame, making it difficult to read important game/party messages. Implemented a three-tier output system: (1) Critical errors always shown in chat, (2) Info messages optional via debug mode, (3) Debug traces only when system-specific debugging enabled. Created a dedicated non-intrusive scrollable debug panel accessible via `/uufdebug` command with options to toggle systems, clear messages, and export logs.

**Usage:**
- `/uufdebug` - Toggle debug panel visibility
- `/uufdebug on` - Enable debug mode globally
- `/uufdebug off` - Disable debug mode globally
- `/uufdebug clear` - Clear all messages from panel
- `/uufdebug export` - Export messages to clipboard
- `/uufdebug SystemName` - Toggle specific system debugging

**Date/Time:** 2026-02-19 04:15:00

---

## Session 116 - Missing 'end' Statements in Pool Functions

**[Lua Syntax Errors: Missing Loop/Block Closures]**  
**File(s):** [Core/FramePoolManager.lua](./Core/FramePoolManager.lua) (Line: 49-78), [Core/IndicatorPooling.lua](./Core/IndicatorPooling.lua) (Line: 161-172)  
**Change:** Added missing `end` statements to close for loops and if blocks  
**Explanation:** BugGrabber reported two Lua syntax errors: (1) FramePoolManager.lua line 51 had a for loop in GetAllPoolStats() that was never closed, causing parser to expect 'end' at EOF, and (2) IndicatorPooling.lua line 161 had a for loop with nested if statement not properly closed before the return statement was executed. Fixed by adding the missing `end` statements: one to close the if block and another to close the for loop in FramePoolManager, and similar fixes in IndicatorPooling to properly nest the return outside the for loop.  
**Date/Time:** 2026-02-19 03:12:00

---

## Session 111 - Missing Method

**[IndicatorPooling GetStats() Method Missing]**  
**File(s):** [Core/IndicatorPooling.lua](./Core/IndicatorPooling.lua) (Lines: 157-171)  
**Change:** Added GetStats() method to return indicator pool statistics  
**Explanation:** PerformanceDashboard.lua called UUF.IndicatorPooling:GetStats() at line 160 to display indicator pool statistics, but this method didn't exist. Added GetStats() that iterates through POOL_CONFIGS, queries FramePoolManager:GetPoolStats() for each indicator pool (THREAT_INDICATOR, TOTEM_ICONS, etc.), and returns a table with pool names as keys containing active, inactive, total, acquired, released, and maxActive counts. This matches the format returned by FramePoolManager:GetAllPoolStats() for consistency.  
**Date/Time:** 2026-02-19 02:36:00

---

## Session 110 - SetScrollChild API Misuse

**[PerformanceDashboard SetScrollChild API Error]**  
**File(s):** [Core/PerformanceDashboard.lua](./Core/PerformanceDashboard.lua) (Lines: 73-99)  
**Change:** Fixed SetScrollChild() call to use Frame instead of FontString  
**Explanation:** The SetScrollChild() Widget API requires a Frame (Region) as its argument, not a FontString. The code was incorrectly passing a FontString directly to SetScrollChild(). Fixed by creating a child Frame to hold the FontString, then setting that Frame as the scroll child. Also added dynamic height updates to ensure proper scrolling behavior as content grows.  
**Date/Time:** 2026-02-19 02:30:00

---

## Session 108 - Global Namespace & EventBus Cleanup

**[Global UUF Namespace Not Exposed]**  
**File(s):** [Core/Globals.lua](./Core/Globals.lua) (Line: 4)  
**Change:** Added `_G.UUF = UUF` to expose addon namespace globally  
**Explanation:** The UUF namespace was only available within addon files; `/run` commands and macros couldn't access UUF.Validator or other modules. Fixed by explicitly exposing UUF to the global _G table in Globals.lua.  
**Date/Time:** 2026-02-19 02:07:51

**[EventBus Unregister Not Compacting Handlers]**  
**File(s):** [Core/Architecture.lua](./Core/Architecture.lua) (Lines: 91-93)  
**Change:** Added immediate _CompactHandlers() call after marking handler dead  
**Explanation:** EventBus Unregister was marking handlers as dead but not compacting the handler array immediately. This left stale index entries that prevented re-registration with the same key. Fixed by adding immediate compaction after marking handler dead.  
**Date/Time:** 2026-02-19 02:15:00

---

## Session 107 - EventBus Custom Event Registration

**[EventBus Custom Event Registration Errors]**  
**File(s):** [Core/Architecture.lua](./Core/Architecture.lua) (Lines: 42-47)  
**Change:** Wrapped RegisterEvent() call in pcall() for custom events  
**Explanation:** EventBus was attempting to register custom events (non-WoW events) with frame:RegisterEvent(), which caused errors since custom events don't exist in the WoW event system. Fixed by wrapping RegisterEvent in pcall() to silently ignore registration failures for custom events while still allowing them to be dispatched.  
**Date/Time:** 2026-02-19 01:30:00

---

## Session 105 - Tab Character & Singleton Pattern

**[DirtyFlagManager Identifier Broken by Tab Character]**  
**File(s):** [Core/PerformancePresets.lua](./Core/PerformancePresets.lua) (Line: 149)  
**Change:** Replaced tab character with space in DirtyFlagManager identifier  
**Explanation:** A tab character (\t) split the DirtyFlagManager identifier, causing a syntax error. Fixed by replacing the tab with a proper space character.  
**Date/Time:** 2026-02-19 01:15:00

**[EventBus Singleton Misuse]**  
**File(s):** [Core/Core.lua](./Core/Core.lua) (Line: 21)  
**Change:** Changed EventBus:New() to direct EventBus assignment  
**Explanation:** EventBus is a singleton pattern (initialized at module load), but Core.lua was calling :New() on it. Fixed by changing to direct assignment: `UUF._eventBus = UUF.Architecture.EventBus`.  
**Date/Time:** 2026-02-19 01:20:00

---

## Session 104 - Syntax Error Batch

**[Architecture.lua Varargs Error]**  
**File(s):** [Core/Architecture.lua](./Core/Architecture.lua) (Line: 329)  
**Change:** Simplified IsSecretValue() to type checking only  
**Explanation:** Lua 5.1 varargs (...) cannot be used outside vararg functions; issecurevariable(..., val) was invalid. Fixed by removing varargs usage and using simple type checking for userdata/secret values compatible with WoW 12.0.0.  
**Date/Time:** 2026-02-19 01:10:24

**[DirtyPriorityOptimizer Broken Comment]**  
**File(s):** [Core/DirtyPriorityOptimizer.lua](./Core/DirtyPriorityOptimizer.lua) (Line: 50)  
**Change:** Rejoined split inline comment  
**Explanation:** Comment "How recently it occurred" was split across lines, causing syntax error. Fixed by rejoining on single line.  
**Date/Time:** 2026-02-19 01:10:24

**[PerformancePresets Split Table Key]**  
**File(s):** [Core/PerformancePresets.lua](./Core/PerformancePresets.lua) (Line: 30)  
**Change:** Rejoined targetFPS table key split across lines  
**Explanation:** Table key "targetFPS" was split as "target" on one line and "FPS" on next, causing syntax error. Fixed by rejoining on single line.  
**Date/Time:** 2026-02-19 01:10:24

**[Init.xml Load Order]**  
**File(s):** [Core/Init.xml](./Core/Init.xml) (Line: 3-6)  
**Change:** Reordered module load sequence  
**Explanation:** Core.lua was loading before Architecture.lua, causing EventBus to be undefined. Fixed by reordering to: Defaults → Globals → Architecture → Utilities → Core.  
**Date/Time:** 2026-02-19 01:10:24

**[IndicatorPooling API Return Values]**  
**File(s):** [Core/IndicatorPooling.lua](./Core/IndicatorPooling.lua) (Line: 255)  
**Change:** Fixed GetSpecializationInfo() return value capture  
**Explanation:** GetSpecializationInfo() returns multiple values (specID, specName, ...); code was only capturing specID. Fixed by capturing both: `local specID, specName = GetSpecializationInfo(...)`.  
**Date/Time:** 2026-02-19 01:10:24

**[PerformancePresets C-Style Comment]**  
**File(s):** [Core/PerformancePresets.lua](./Core/PerformancePresets.lua) (Line: 97)  
**Change:** Changed C-style comment // to Lua comment --  
**Explanation:** Lua uses -- for comments, not //. Fixed by replacing // with --.  
**Date/Time:** 2026-02-19 01:10:24

---

## Session 121 (Phase 5b) - Runtime Errors & Frame Rendering Issues

**[MLOptimizer Lua 5.1 Closure Context Loss - CRITICAL]**  
**File(s):** [Core/EventCoalescer.lua](./Core/EventCoalescer.lua) (Lines: 255-262), [Core/MLOptimizer.lua](./Core/MLOptimizer.lua) (Lines: 698-738)  
**Change:** Added public API methods to EventCoalescer (GetEventDelay, SetEventDelay) and updated MLOptimizer to use public API instead of accessing private local variable  
**Explanation:** MLOptimizer was causing "attempt to index field '_coalescedEvents' (a nil value)" at line 711 (now 717). Root cause was that EventCoalescer stores coalesced events in a LOCAL variable `_coalescedEvents` (not a property on the object), so MLOptimizer couldn't access it as `eventCoalescer._coalescedEvents`. The previous fix (Session 121) attempted to capture `self` in a closure, but that doesn't help since the real issue was accessing a private local variable that's not exposed. Fixed by: (1) Adding two new public methods to EventCoalescer: `GetEventDelay(eventName)` returns the current delay for an event, `SetEventDelay(eventName, delay)` sets the delay. (2) Updating MLOptimizer's inline closure callback (line 710) to use `UUF.EventCoalescer:GetEventDelay(eventName)` instead of trying to access the private table. (3) Updating the periodic ticker (lines 721-738) to use `GetCoalescedEvents()` to get the list of event names, then use `GetEventDelay()` and `SetEventDelay()` to adjust delays without accessing the private table. This is the proper architectural fix - modules should never access private data from other modules, they should use public APIs instead.  
**Date/Time:** 2026-02-19 16:05:00

**[Portrait SetPointIfChanged Integration Issues - CRITICAL]**  
**File(s):** [Elements/Portrait.lua](./Elements/Portrait.lua) (Lines: 11, 13, 20, 32, 35, 46-47)  
**Change:** Fixed three frame anchor issues in CreateUnitPortrait - added ClearAllPoints() chains and switched to SetPointIfChanged() for cache initialization  
**Explanation:** Player unitframe was distorted with only the 3D model visible and oversized, covering all UI elements (health bar, name, power bar hidden). Root cause: CreateUnitPortrait() used unconditional SetPoint() calls instead of SetPointIfChanged(), causing anchor cache initialization issues. SetPointIfChanged (a Phase 2 optimization) maintains cache on frame objects (_uufLastPoint, _uufLastRel, _uufLastX, _uufLastY). UpdateUnitPortrait() calls SetPointIfChanged(), but CreateUnitPortrait didn't initialize the cache, so later SetPointIfChanged calls had no prior state to compare against. Additionally, three separate anchor operations (backdrop sizing, 3D model positioning, border anchoring) lacked explicit ClearAllPoints() chains, allowing SetAllPoints() to apply undefined prior points, causing distortion. Fixed by: (1) Backdrop (lines 11-13): Added ClearAllPoints() before sizing, changed SetPoint() to SetPointIfChanged() to initialize cache. (2) Model (line 20): Added ClearAllPoints() before SetAllPoints(). (3) Texture (lines 32-35): Added ClearAllPoints() before SetPoint(), changed to SetPointIfChanged(). (4) Border (lines 46-47): Added ClearAllPoints(), changed SetAllPoints() to two explicit SetPointIfChanged() calls with TOPLEFT and BOTTOMRIGHT anchors. Portrait now renders correctly at configured 42x42 size with all UI elements visible.  
**Date/Time:** 2026-02-19 14:15:00

---

**End of Bug Fixes**
