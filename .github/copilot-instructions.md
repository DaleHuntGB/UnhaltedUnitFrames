# Project Guidelines

## API Verification Workflow
**CRITICAL: Always verify WoW APIs against the local wow-ui-source repository before planning or implementing any code changes.**

### Before Any Code Planning or Changes:
1. **Check Local Reference:** Review the latest API implementation in `d:\Games\World of Warcraft\_retail_\Interface\_Working\wow-ui-source`
   - File path: `wow-ui-source/Interface/AddOns/Blizzard_*/` (Blizzard reference UI code)
   - Verify C_* namespace functions, widget types, and event payloads
   - Look for undocumented parameters, return values, or behavioral changes

2. **Update Repository if Outdated:**
   - Run: `/run UUF.DebugOutput:Output("APICheck", "Checking wow-ui-source for updates...", 1)`
   - Navigate to: `d:\Games\World of Warcraft\_retail_\Interface\_Working\wow-ui-source`
   - Check git status: `git status`
   - Get latest: `git fetch origin && git pull` (uses branch: live)
   - Verify update: `git log --oneline -5` (should show current date if updated)

3. **Cross-Reference Before Implementation:**
   - Compare proposed API usage against `wow-ui-source/Interface/AddOns/Blizzard_*/` code
   - Verify parameter order, return value unpacking, availability in current patch
   - Check for secret values (WoW 12.0.0+) that require special handling
   - Note any deprecated or renamed functions

4. **Document API Findings:**
   - Record function signature and parameters from wow-ui-source references
   - Note any version-specific behavior or restrictions
   - Link to specific Blizzard reference UI file and line numbers in code comments
   - Example comment: `-- Per Blizzard_CastingBar line 142: UnitChannelInfo returns 8 values in this order: name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID`

### Why This Matters:
- **Accuracy:** Blizzard reference UI is the source of truth for WoW API behavior
- **Unpacking Errors:** Wrong parameter order causes "attempt to perform arithmetic on boolean" type errors
- **Version Compatibility:** API changes between patches must be caught early
- **Secret Values:** Some return values are secret in 12.0.0+ and need special handling
- **Undocumented Features:** Many Blizzard APIs have quirks only visible in reference code

### Common Pitfalls Fixed by This Workflow:
- ❌ UnitChannelInfo unpacking with wrong underscore count (causes boolean arithmetic error)
- ❌ Using deprecated C_* apis without checking wow-ui-source
- ❌ Assuming parameter order without verifying in Blizzard code
- ❌ Missing return value unpacking (only taking first value when multiple available)
- ❌ Not handling secret values in 12.0.0+ properly

## Code Style
- **Lua 5.1 ONLY:** WoW uses Lua 5.1 - do NOT use Lua 5.2+ syntax (no `goto`, no `\z`, no `0x` hex floats, no `//` comments)
  - ❌ FORBIDDEN: `goto label`, `::label::`, `\z` escape sequences, hexadecimal floats (`0x1.8p3`)
  - ❌ FORBIDDEN: `//` comments (use `--` for single-line, `--[[ ]]` for multi-line)
  - ✅ ALLOWED: Standard Lua 5.1 control flow (`while`, `repeat`, `for`, nested `if/elseif/else`, early `return`, `break` in loops)
  - ✅ Loop control: Use `if not condition then goto skip_iteration end` pattern is INVALID - use `if not condition then [skip code] elseif another then [process] end` instead
  - ✅ Early exit: Use early `return` statements instead of complex nesting or goto patterns
  - Reference: See WoWAddonAPIAgents/.github/skills/wow-lua-api/SKILL.md for complete Lua 5.1 reference
  - Reference: See WoWAddonAPIAgents/.github/skills for available skills and best practices for Lua coding in WoW addons

- Prefer `UUF:` namespaced functions with locals declared near the top of each file; keep style compact and low-comment like existing code in [Core/UnitFrame.lua](../Core/UnitFrame.lua) and [Elements/CastBar.lua](../Elements/CastBar.lua).
- Use **PERF LOCALS** pattern: localize frequently-called globals at module load (e.g., `local GetTime, UnitExists = GetTime, UnitExists`)
- Configuration UI uses AceGUI widgets and shared helper wrappers in [Core/Config/GUIWidgets.lua](../Core/Config/GUIWidgets.lua); follow patterns in [Core/Config/GUI.lua](../Core/Config/GUI.lua).
- Defaults live in AceDB tables in [Core/Defaults.lua](../Core/Defaults.lua); update defaults whenever adding new settings.
- **Change detection patterns:**
  - Use `UUF:StampChanged(obj, key, value)` to avoid redundant updates (see [Core/Helpers.lua](../Core/Helpers.lua))
  - Use `UUF:SetPointIfChanged(frame, ...)` instead of unconditional `SetPoint()` (14+ indicator files use this pattern)
  - Frame config caching: Store `frame.UUFUnitConfig = UnitDB` during creation to avoid repeated lookups
- **Frame storage patterns:**
  - Use dual storage: `UUF[unit:upper()]` (legacy, e.g., UUF.PLAYER) AND `UUF.Units[unit]` (modern, e.g., UUF.Units["player"])
  - UUF.Units table initialized in [Core/Globals.lua](../Core/Globals.lua), populated in [Core/UnitFrame.lua](../Core/UnitFrame.lua)
  - Both patterns maintained for backward compatibility and Phase 5 optimization systems
  - Boss frames: UUF.Units["boss1"] through UUF.Units["boss5"]
  - Party frames: UUF.Units["party1"] through UUF.Units["party5"] (or "player")
  - Single frames: UUF.Units["player"], UUF.Units["target"], UUF.Units["pet"], etc.
- **Utilities module:** Use `UUF.Utilities` helpers for common operations (see [Core/Utilities.lua](../Core/Utilities.lua)):
  - Config: `Val()`, `Num()`, `Enabled()`, `Offset()`, `SetShown()`
  - Tables: `HideKeys()`, `ShowKeys()`
  - Safe API: `GetCastingInfoSafe()`, `GetChannelInfoSafe()`
  - Format: `FormatDuration()`, `FormatNumber()`, `FormatPercent()`
  - Layout: `LayoutColumn()` with chainable Row(), MoveY(), At(), Reset()
  - Channel Ticks: `GetChannelTicks(spellID)` returns tick timings for spell channel visualization
- **Debug output:** Use `UUF.DebugOutput` for all diagnostic messages instead of print() (see [Core/DebugOutput.lua](../Core/DebugOutput.lua)):
  - API: `UUF.DebugOutput:Output(systemName, message, tier)` where tier is TIER_CRITICAL/TIER_INFO/TIER_DEBUG
  - Three tiers: Critical (chat + panel), Info (panel optional), Debug (system-specific)
  - System-specific: Check `UUF.db.global.Debug.systems.SystemName` before debug output
  - Tier constants: `UUF.DebugOutput.TIER_CRITICAL` (1), `UUF.DebugOutput.TIER_INFO` (2), `UUF.DebugOutput.TIER_DEBUG` (3)
  - Example: `UUF.DebugOutput:Output("Validator", "Check passed", UUF.DebugOutput.TIER_INFO)`
  - Access panel: `/uufdebug` command
  - Export logs: Click "Export to Clipboard" in debug panel

## Architecture
- AddOn load order: libraries → elements → core via [UnhaltedUnitFrames.toc](../UnhaltedUnitFrames.toc), [Elements/Init.xml](../Elements/Init.xml), and [Core/Init.xml](../Core/Init.xml).
- **Core load sequence:** Defaults → Globals → Architecture → Utilities → DebugOutput → DebugPanel → ConfigResolver → FramePoolManager → Validator → IndicatorPooling → ReactiveConfig → EventCoalescer → FrameTimeBudget → DirtyFlagManager → Core → remaining modules (see [Core/Init.xml](../Core/Init.xml))
- Initialization and event wiring are in [Core/Core.lua](../Core/Core.lua); global utilities, media registration, and `UUF:ResolveLSM()` live in [Core/Globals.lua](../Core/Globals.lua).
- Unit frame creation/update flows through [Core/UnitFrame.lua](../Core/UnitFrame.lua), with element implementations in [Elements/](../Elements/).
- **Architecture module** ([Core/Architecture.lua](../Core/Architecture.lua)) provides:
  - **EventBus:** Singleton event dispatcher (`UUF.Architecture.EventBus`) with Register/Unregister/Dispatch API
  - **GUI Building:** `Arch.LayoutColumn()` for chainable widget creation (Btn, Text, Check, Gap)
  - **Config System:** `ResolveConfig()`, `CaptureConfigState()`, `RestoreConfigState()`
  - **Frame State:** `CreateFrameState()` with dirty flags and stamp-based change detection
  - **Frame Pooling:** `CreateFramePool()` with Acquire/Release/ReleaseAll
  - **Safe Values:** `SafeValue()`, `SafeCompare()`, `IsSecretValue()` for WoW 12.0.0 secret values
  - **Profile Export:** `EncodeProfile()`, `DecodeProfile()` using Blizzard CBOR
  - **Table Utils:** `DeepCopy()`, `MergeTables()`, `FilterTable()`
- **Performance Systems** (Phase 4a-4c + Phase 5 Priority 1, 45-85% total improvement, ZERO HIGH frame spikes):
  - **ReactiveConfig** ([Core/ReactiveConfig.lua](../Core/ReactiveConfig.lua)): Auto config-to-frame sync with debouncing
  - **ConfigResolver** ([Core/ConfigResolver.lua](../Core/ConfigResolver.lua)): Profile → Unit → Global fallback chain
  - **FramePoolManager** ([Core/FramePoolManager.lua](../Core/FramePoolManager.lua)): Centralized AuraButton/IndicatorIcon pools (60%+ GC reduction)
  - **IndicatorPooling** ([Core/IndicatorPooling.lua](../Core/IndicatorPooling.lua)): Pool-aware indicator lifecycle
  - **EventCoalescer** ([Core/EventCoalescer.lua](../Core/EventCoalescer.lua)): 4-tier priority (CRITICAL=1, HIGH=2, MEDIUM=3, LOW=4), FrameTimeBudget integration, emergency flush for CRITICAL events, batch size tracking (60-70% callback reduction)
  - **FrameTimeBudget** ([Core/FrameTimeBudget.lua](../Core/FrameTimeBudget.lua)): O(1) incremental averaging (runningTotal optimization), P50/P95/P99 percentile tracking with lazy evaluation, overflow protection (200 max deferred, drops LOW priority), 6-bucket histogram (0-5ms, 5-10ms, 10-15ms, 15-20ms, 20-30ms, 30+ms), target 16.67ms for 60 FPS (80-90% spike reduction, achieves P50=16.7ms, P99=24.1ms)
  - **DirtyFlagManager** ([Core/DirtyFlagManager.lua](../Core/DirtyFlagManager.lua)): Frame validation (_ValidateFrame checks type, update methods, GetObjectType), processing lock (_isProcessing prevents re-entry), priority decay (0.1 every 5s), adaptive batch sizing (2-20 frames based on budget), if/elseif patterns (Lua 5.1 compatible)
  - **CoalescingIntegration** ([Core/CoalescingIntegration.lua](../Core/CoalescingIntegration.lua)): Auto-applies coalescing to 13 WoW events with per-event priorities (UNIT_HEALTH/POWER=CRITICAL, UNIT_AURA=HIGH, UNIT_THREAT=MEDIUM, UNIT_PORTRAIT=LOW)
  - **DirtyPriorityOptimizer** ([Core/DirtyPriorityOptimizer.lua](../Core/DirtyPriorityOptimizer.lua)): ML-powered priority learning from 5-minute windows (40% frequency, 30% combat ratio, 20% recency, 10% base importance)
  - **PerformanceProfiler** ([Core/PerformanceProfiler.lua](../Core/PerformanceProfiler.lua)): Timeline recording, bottleneck analysis, coalesced event breakdown (top 10 WoW events), ignores event_coalesced in bottleneck detection (false positive eliminated)
  - **PerformancePresets** ([Core/PerformancePresets.lua](../Core/PerformancePresets.lua)): 4 presets (Low/Medium/High/Ultra) + auto-optimization based on hardware
  - **PerformanceDashboard** ([Core/PerformanceDashboard.lua](../Core/PerformanceDashboard.lua)): Real-time metrics overlay with PrintStats(), FPS/latency/memory tracking
  - **DebugOutput & DebugPanel** ([Core/DebugOutput.lua](../Core/DebugOutput.lua), [Core/DebugPanel.lua](../Core/DebugPanel.lua)): 3-tier output (Critical/Info/Debug), system-specific enable flags, `/uufdebug` command, export to clipboard
  - **Validator** ([Core/Validator.lua](../Core/Validator.lua)): System health validation, conditional frame handling (PLAYER mandatory, TARGET/PET/FOCUS check enabled+spawned but not IsVisible)
- **Reference Documentation:**
  - [ARCHITECTURE_GUIDE.md](../ARCHITECTURE_GUIDE.md): Comprehensive architecture reference with examples
  - [ARCHITECTURE_EXAMPLES.lua](../ARCHITECTURE_EXAMPLES.lua): Before/after integration patterns
  - [ULTIMATE_PERFORMANCE_SYSTEMS.md](../ULTIMATE_PERFORMANCE_SYSTEMS.md): Phase 4c systems reference
- **CastBar Enhancements** ([Elements/CastBarEnhancements.lua](../Elements/CastBarEnhancements.lua)): Visual indicators for casting
  - **Timer Direction:** Arrow/text/bar indicator showing cast progression direction
  - **Channel Ticks:** Visual tick markers for channel ability timing (uses `UUF:GetChannelTicks(spellID)` from ChannelingTicks table)
  - **Empower Stages:** Stage indicators for empowered abilities (lines/fills/boxes)
  - **Latency Indicator:** Shows player latency and interrupt window threshold
  - **Performance Fallback:** Disables expensive features in large groups (threshold configurable)
  - **Initialization:** `UUF:EnhanceCastBar()` creates elements on cast start, `UUF:UpdateCastBarEnhancements()` updates per-frame
  - **ChannelingTicks:** `UUF.ChannelingTicks` table maps spell IDs to tick arrays (milliseconds); `UUF:GetChannelTicks(spellID)` returns ticks with fallback to DEFAULT

## Build and Test
- No build/test commands are documented in this repo.

## Project Conventions
- Use `UUF:QueueOrRun` for protected operations during combat lockdown (see [Core/Core.lua](../Core/Core.lua)).
- Layout is stored in `UnitDB.Frame.Layout` arrays and applied in [Core/UnitFrame.lua](../Core/UnitFrame.lua); keep layout arrays consistent.
- Media is resolved through `UUF.Media` populated by `UUF:ResolveLSM()` in [Core/Globals.lua](../Core/Globals.lua).
- **Heal prediction visuals:** Absorb bars use `Shield-Overlay` texture with class-based coloring (damage absorbs match unit's class colour), optional overshield glows (1.0 default opacity, configurable), and incoming heals support (all/player/other split); configure via [Elements/HealPrediction.lua](../Elements/HealPrediction.lua), GUI in [Core/Config/GUIUnits.lua](../Core/Config/GUIUnits.lua), defaults in [Core/Defaults.lua](../Core/Defaults.lua). Class colours defined in HealPrediction.lua LocalClassColours table (all 12 classes mapped).
- **Change detection best practices:**
  - Always use `StampChanged()` before expensive style operations (buttons, textures, fonts)
  - Always use `SetPointIfChanged()` for frame positioning to avoid redundant API calls
  - Cache frame configs during creation (`frame.UUFUnitConfig = UnitDB`) to avoid repeated DB lookups
- **Event handling patterns:**
  - Use EventCoalescer for high-frequency events with proper priorities:
    - CRITICAL (1): UNIT_HEALTH, UNIT_POWER_UPDATE, PLAYER_REGEN_ENABLED/DISABLED (immediate flush, never defer)
    - HIGH (2): UNIT_MAXHEALTH, UNIT_MAXPOWER, UNIT_AURA (minimal batching)
    - MEDIUM (3): UNIT_THREAT, PLAYER_TOTEM_UPDATE, RUNE_POWER_UPDATE (standard coalescing)
    - LOW (4): UNIT_PORTRAIT_UPDATE, UNIT_MODEL_CHANGED (aggressive batching, cosmetic)
  - Use DirtyFlagManager for batched frame updates (50-60% faster)
  - Integrate with CoalescingIntegration for automatic element coalescing (13 events auto-configured)
  - Register PLAYER_LEVEL_UP and UNIT_LEVEL events for level-up frame updates (0.1s delay recommended)
  - **Frame validation before processing:**
    - Check frame is table type before accessing methods
    - Validate update methods exist (UpdateAll, Update, or element.Update)
    - Use GetObjectType() check for UI widgets
    - Skip invalid/dead frames in processing loops
- **Frame time budgeting patterns:**
  - Use `FrameTimeBudget:CanAfford(priority, estimatedCost)` before expensive operations
  - Defer non-critical updates with `FrameTimeBudget:DeferUpdate(callback, priority, context)`
  - Wrap functions with `FrameTimeBudget:WrapWithBudget(func, priority, estimatedCost)`
  - Batch process with budget awareness using `FrameTimeBudget:BatchProcess(items, processor, priority, maxTime)`
  - Priority levels: PRIORITY_CRITICAL (1, health/power), PRIORITY_HIGH (2, auras/cast), PRIORITY_MEDIUM (3, tags), PRIORITY_LOW (4, cosmetic)
  - Target frame time: 16.67ms for 60 FPS
  - DirtyFlagManager automatically uses adaptive batch sizing when FrameTimeBudget is available
- **Frame pooling patterns:**
  - Use FramePoolManager for aura buttons and indicators (60-75% GC reduction)
  - Always Release() frames when hiding/removing elements
  - Call ReleaseAll() on frame destruction
- **Performance monitoring:**
  - Use `/uufperf` to toggle real-time performance dashboard
  - Use `/uufprofile start|stop|analyze|export` for timeline profiling
  - Use `/uufpreset low|medium|high|ultra` to adjust performance levels
  - Use `/run UUF.Validator:RunFullValidation()` to check system health
  - Use `/run UUF.PerformanceDashboard:PrintStats()` for comprehensive stats to chat
  - Use `/run UUF.FrameTimeBudget:PrintStatistics()` for frame time budget stats
  - Use `/uufdebug` to open debug panel for system-specific diagnostics
  - Check frame spikes: Look for HIGH/MEDIUM severity bottlenecks in profiler output
- **Configuration best practices:**
  - Use ConfigResolver for profile → unit → global fallback
  - Use ReactiveConfig for automatic config-to-frame synchronization
  - Debounce rapid config changes (already handled by ReactiveConfig)
- **Machine Learning Optimization:**
  - DirtyPriorityOptimizer learns from 5-minute windows
  - Auto-adjusts priorities based on frequency (40%), combat ratio (30%), recency (20%), base importance (10%)
  - Check recommendations: `/run UUF.DirtyPriorityOptimizer:PrintRecommendations()`
- **Adaptive batching:**
  - DirtyFlagManager adjusts batch size based on frame time budget
  - Under budget (< 12ms): 2x batch size (up to 20 frames)
  - Near limit (12-14ms): Normal batch size (10 frames)
  - Over budget (> 14ms): 1/2 to 1/4 batch size (2-5 frames)
  - Critical updates (priority 4+) always process, deferred updates queue automatically
  - Batch intervals adapt: faster when under budget, slower when over budget
- **Conditional frame handling:**
  - PLAYER frame: Always exists, always visible (mandatory)
  - TARGET, PET, FOCUS, TARGETTARGET, FOCUSTARGET: Exist via oUF:Spawn but hidden when units not present
  - Use RegisterUnitWatch to auto show/hide conditional frames
  - Validation: Check frame exists (UUF[unit:upper()]) but don't require IsVisible() for conditional frames
  - Both storage patterns available: UUF.PLAYER and UUF.Units["player"]
- **Performance profiling workflow:**
  - Start: `/uufprofile start` (begins timeline recording, max 10000 events)
  - Play: 5-10 minutes of normal gameplay (combat, movement, UI interaction)
  - Stop: `/uufprofile stop` (ends recording)
  - Analyze: `/uufprofile analyze` (shows FPS metrics, frame time percentiles, coalesced event breakdown, bottlenecks)
  - Export: `/uufprofile export` (copies timeline data to clipboard)
  - Expected results: P50=16.7ms (60 FPS), P99<25ms, zero HIGH severity spikes (>33ms)
  - Bottleneck interpretation: HIGH severity = frames >33ms (below 30 FPS), event_coalesced is false positive (optimization working)

## Integration Points
- oUF for frame spawning and colors (see [Libraries/oUF](../Libraries/oUF) and [Core/UnitFrame.lua](../Core/UnitFrame.lua)).
- Ace3 (AceAddon/AceDB/AceGUI), LibSharedMedia, LibDualSpec, LibDeflate, LibDispel (see [Libraries/](../Libraries/)).
- **New Architecture Systems:**
  - EventBus (singleton, use directly without `:New()`)
  - FramePoolManager (centralized pooling for aura buttons, indicators)
  - EventCoalescer (event batching for high-frequency WoW events)
  - FrameTimeBudget (frame time budgeting, adaptive throttling, deferred queue)
  - DirtyFlagManager (centralized dirty flag batching with adaptive sizing)
  - ReactiveConfig (auto config-to-frame sync with ConfigResolver)
  - PerformanceProfiler (timeline recording, bottleneck analysis)
  - PerformancePresets (4 presets: Low/Medium/High/Ultra + auto-optimization)
  - PerformanceDashboard (`/uufperf` for real-time metrics, PrintStats() for chat output)
  - DebugOutput & DebugPanel (non-intrusive debug routing with `/uufdebug` UI)
  - DirtyPriorityOptimizer (ML-based priority learning with 4 weighted factors)
  - **MLOptimizer** ([Core/MLOptimizer.lua](../Core/MLOptimizer.lua)): Advanced ML system (Phase 5b)
    - **Neural Network:** 7 inputs (frequency, recency, combatState, groupSize, contentType, fps, latency) → 5 hidden neurons → 3 outputs (priority, coalesceDelay, preloadLikelihood)
    - **Combat Pattern Recognition:** Tracks event sequences, learns patterns from gameplay ("UNIT_HEALTH → UNIT_POWER_UPDATE" sequences)
    - **Predictive Pre-loading:** Pre-marks frames when prediction confidence >70%, reduces first-event latency
    - **Adaptive Coalescing Delays:** Learns optimal delay per event per content type, auto-adjusts based on success rate (<70% → longer, >95% → shorter)
    - **Training:** Backpropagation with gradient descent (0.01 learning rate), Sigmoid activation
    - **Integration:** Hooks DirtyFlagManager:MarkDirty (pattern tracking) and EventCoalescer:QueueEvent (event tracking)
- **Performance Feature Commands:**
  - `/uufperf` - Toggle performance dashboard (real-time FPS/latency/memory overlay)
  - `/uufprofile start|stop|analyze|export` - Performance profiling (timeline recording, 10000 event max)
    - analyze: Shows FPS metrics (min/avg/max), frame time percentiles (P50/P95/P99), coalesced event breakdown (top 10 WoW events), bottlenecks (ignores event_coalesced false positive)
  - `/uufpreset low|medium|high|ultra` - Change performance preset
  - `/uufpreset auto on|off` - Toggle auto-optimization based on hardware
  - `/uufpreset recommend` - Get preset recommendations based on current performance
  - `/uufml patterns|delays|stats|predict|help` - MLOptimizer commands (Phase 5b)
    - patterns: Show learned combat patterns with prediction probabilities
    - delays: Show adaptive coalescing delays per event/content type
    - stats: Statistics (patterns learned, delays optimized, current sequence, context)
    - predict: Current predictions based on recent event sequence
  - `/run UUF.Validator:RunFullValidation()` - System health check (11 tests: Architecture, EventBus, ConfigResolver, FramePoolManager, GUILayout, MLOptimizer, FramesSpawning, EventBusDispatch, FramePoolAcquisition, ConfigResolution, GuiBuilder)
  - `/run UUF.DirtyPriorityOptimizer:PrintRecommendations()` - ML-based priority recommendations (frequency, combat ratio, recency analysis)
  - `/run UUF.MLOptimizer:GetStats()` - MLOptimizer statistics (patterns, delays, sequence length, context)
  - `/run UUF.PerformanceDashboard:PrintStats()` - Print comprehensive stats to chat (FPS, latency, memory, frame pool stats, event coalescing stats)
  - `/run UUF.FrameTimeBudget:PrintStatistics()` - Frame time budget stats (avg/P50/P95/P99, histogram distribution, deferred queue size, dropped callbacks)
  - `/run UUF.FrameTimeBudget:ResetStatistics()` - Reset frame time tracking (clears percentile history)
  - `/run UUF.EventCoalescer:PrintStats()` - Event coalescing detailed stats (total coalesced/dispatched, CPU savings %, per-event breakdown with batch sizes min/avg/max, budget defers, emergency flushes)
  - `/run UUF.EventCoalescer:ResetStats()` - Reset coalescing statistics
  - `/run UUF.DirtyFlagManager:PrintStats()` - Dirty flag stats (frames processed, batches, invalid frames skipped, priority decays, processing blocks)
  - `/uufdebug` - Toggle debug panel (non-intrusive diagnostic messages, system-specific toggles, export to clipboard)

## Security
- Combat lockdown applies to frame changes; defer protected changes using `UUF:QueueOrRun` and avoid in-combat layout edits (see [Core/Core.lua](../Core/Core.lua)).
- **WoW 12.0.0 Secret Values:** Use `Architecture.SafeValue()`, `SafeCompare()`, and `IsSecretValue()` for protected value handling
- **Event Coalescing Combat Handling:**
  - EventCoalescer automatically flushes CRITICAL priority events (health/power/combat state) immediately
  - PLAYER_REGEN_ENABLED/DISABLED events bypass coalescing for instant combat state updates
  - Emergency flush tracking via _stats.emergencyFlushes counter
- **Dirty Flag Combat Handling:**
  - DirtyFlagManager batches updates but forces flush on combat state change
  - Processing lock (_isProcessing) prevents re-entry during forced flushes
  - Priority decay paused during combat to maintain update urgency
- **Frame Time Budget Safety:**
  - FrameTimeBudget uses pcall() for all deferred callbacks with error logging via DebugOutput
  - Overflow protection: MAX_DEFERRED_QUEUE=200, drops LOW priority callbacks when full
  - No callback starvation: Critical updates always process regardless of budget
- **Frame Validation Safety:**
  - _ValidateFrame() checks frame validity before processing (type, methods, GetObjectType)
  - Invalid frames skipped and cleared from dirty tracking
  - Prevents nil reference errors and access to garbage-collected frames
- **Processing Lock Safety:**
  - _isProcessing flag prevents re-entry into ProcessDirty() (DirtyFlagManager)
  - Blocks nested/recursive processing that could cause infinite loops
  - Tracks blocks via _stats.processingBlocks counter
- **Pool Safety:** FramePoolManager tracks acquired frames and prevents double-release with validation
- **ML Safety:** DirtyPriorityOptimizer learns passively without blocking or interfering with gameplay (5-minute windows, runs on intervals)
- **Debug Output Safety:**
  - All debug output uses pcall() protection to prevent errors from stopping execution
  - System-specific enable flags (UUF.db.global.Debug.systems.SystemName) prevent spam
  - Three tiers: Critical (always chat), Info (optional panel), Debug (system-specific only)
- **Conditional Frame Safety:**
  - Validator distinguishes "frame not spawned" (error) vs "frame hidden because unit absent" (expected)
  - Don't require IsVisible() for TARGET/PET/FOCUS validation
  - RegisterUnitWatch handles visibility automatically based on unit existence

## Change Documentation
After completing any bug fix, feature work, or development change, update project documentation:

### Work Summary Updates ([WORK_SUMMARY.md](../WORK_SUMMARY.md))
- Add a new session section with the date and status
- Document files modified with specific line ranges and descriptions
- Include performance impact estimates where applicable
- List risk level and validation approach
- Summarize overall status of the session (e.g., "All errors resolved ✅")
- For feature additions, include a brief user-facing description of the new functionality unless the feature needs detailed explanation (in which case, add a new section describing the feature in detail)
- Do not include updates if the user supplys a bug report Containing [ERROR] in the message, as those should be reserved for actual bug fixes. Instead, focus on documenting new features, architectural changes, or other development work that does not directly relate to fixing a reported error.

### Self-Updating Documentation Guidelines
When introducing new features, systems, libraries, or architectural changes, **automatically update this copilot-instructions.md file** to reflect the changes:

**Update Code Style section if:**
- New code patterns introduced (e.g., UUF.Units table pattern, frame validation patterns)
- New utility functions added to common use (e.g., new Utilities helpers, new DebugOutput methods)
- New best practices established (e.g., priority constants, frame storage patterns)

**Update Architecture section if:**
- New core systems added (e.g., EventCoalescer, FrameTimeBudget, DirtyFlagManager)
- Existing systems significantly enhanced (e.g., O(1) averaging, percentile tracking, priority levels)
- Load order changes (update Core/Init.xml load sequence)
- New performance metrics achieved (update improvement percentages, benchmarks)

**Update Project Conventions section if:**
- New workflow patterns established (e.g., frame validation before processing, conditional frame handling)
- New commands or slash commands added (e.g., /uufprofile, /uufpreset)
- New monitoring/diagnostic approaches (e.g., performance profiling workflow)
- New integration patterns (e.g., event priority assignment, adaptive batching)

**Update Security section if:**
- New safety mechanisms added (e.g., processing locks, overflow protection, frame validation)
- Combat handling patterns change (e.g., emergency flush for CRITICAL events)
- New error handling approaches (e.g., pcall() wrappers, graceful degradation)

**Update Integration Points section if:**
- New libraries or external systems integrated
- New internal systems with public APIs (e.g., EventCoalescer:PrintStats(), FrameTimeBudget:CanAfford())
- New slash commands or user-facing features
- System APIs change significantly (parameter additions, behavior changes)

**Format for updates:**
- Keep entries concise but complete (1-3 lines per bullet)
- Include relevant file paths with markdown links
- Mention key performance metrics where applicable (e.g., "60%+ GC reduction", "ZERO HIGH frame spikes")
- Reference line numbers for critical code sections
- Use technical accuracy (e.g., "O(1) incremental averaging" not just "faster averaging")
- Update improvement percentages when benchmarks change (e.g., "45-85% total improvement")

**When in doubt:**
- Check ARCHITECTURE_GUIDE.md for detailed system documentation
- Review WORK_SUMMARY.md for recent session changes
- Validate against existing patterns in the codebase

This ensures future AI assistants and developers have accurate, up-to-date guidance reflecting the current state of the addon architecture and best practices.
