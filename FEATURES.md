# UnhaltedUnitFrames Features

This document summarizes the current addon features and architecture systems implemented in the codebase.

## Core Unit Frames
- Player
- Target
- TargetTarget
- Focus
- FocusTarget
- Pet
- Party (with role sorting/layout support)
- Boss (multi-frame spawn/layout)

## Configuration and Profile Systems
- AceDB-backed configuration (`UUFDB`) with profile support.
- Global + profile layers with resolver/fallback support.
- Edit Mode layout persistence per layout key.
- Castbar defaults merge system for consistent enhancement settings.
- Reactive config propagation for runtime config-to-frame synchronization.

## Rendering and UI Systems
- oUF-based frame spawning and element lifecycle.
- Shared media resolution via LibSharedMedia.
- Frame mover + edit-mode compatible drag/position persistence.
- Protected-operation queueing (`QueueOrRun`) for combat-lockdown-safe updates.
- Stamp/change detection helpers to avoid redundant visual API calls.

## CastBar Systems
- Standard cast/channel support with cancel/interrupt handling.
- CastBar enhancement suite:
  - Timer Direction indicators
  - Channel Tick markers
  - Empower Stage indicators
  - Latency indicators
  - Performance fallback for larger groups
- Configurable castbar debug routing through debug panel settings.

## Performance Systems
- EventCoalescer:
  - Priority-based coalescing (CRITICAL/HIGH/MEDIUM/LOW)
  - Batch size metrics (`min/avg/max`)
  - Budget deferral tracking and emergency behavior
  - Queue rejection tracking (`totalRejected`, per-event rejected counts)
- CoalescingIntegration:
  - Centralized registration of hot WoW events
  - DirtyFlag batching integration
  - Unit-scoped event filtering to avoid irrelevant queueing
  - Queue-accepted fallback path to prevent race-time drops
- DirtyFlagManager:
  - Priority-aware dirty updates
  - Adaptive processing behavior
  - Safety checks for invalid frames
- FrameTimeBudget:
  - Frame-budget-aware dispatch/defer behavior
  - Deferred processing controls
- FramePoolManager + IndicatorPooling:
  - Reuse of frame resources to reduce churn/GC pressure

## ML and Adaptive Optimization
- DirtyPriorityOptimizer:
  - Learns event/update priority weighting from runtime behavior.
- MLOptimizer:
  - Pattern tracking and prediction over coalesced event flow.
  - Adaptive coalesce-delay learning by event/context.
  - Persistence across reload/login using `UUF.db.global.MLOptimizer`.
  - Save/load/reset lifecycle and periodic save support.
  - Event-specific adaptive delay clamp policy to keep learned delays in safe ranges.

## Profiling, Diagnostics, and Debug
- PerformanceProfiler (`/uufprofile`):
  - Timeline capture with frame metrics
  - Coalesced vs dispatched analysis
  - Coalescer batch metrics and queue rejection metrics
  - Top coalesced/dispatched WoW event breakdowns
  - Timed capture support with auto-stop + auto-analyze
- PerformanceDashboard (`/uufperf`):
  - Live FPS/memory/frame data
  - Coalescing metrics (queued/dispatched/rejected)
  - Batch quality metrics (avg/max batch size, dispatch/reject ratios)
  - Dirty flag, pool, and ML stats visibility
- DebugOutput + DebugPanel (`/uufdebug`):
  - Tiered debug routing (critical/info/debug)
  - Per-system toggles
  - Scrollable message view + export

## Custom Coalesced Event Coverage
Current custom coalesced events include:
- `UUF_RANGE_FRAME_UPDATE`
- `UUF_DISPEL_HIGHLIGHT_UPDATE`
- `UUF_TARGET_GLOW_UPDATE`
- `UUF_ALT_POWER_BAR_UPDATE`
- `UUF_SECONDARY_POWER_REFRESH`

All major custom event paths now use queue acceptance checks with safe fallback behavior.

## Commands
- `/uufperf`
  - Toggle performance dashboard.
- `/uufprofile start`
  - Start profiler capture.
- `/uufprofile start 90`
  - Timed capture (auto-stop + auto-analyze after 90s).
- `/uufprofile 90`
  - Timed capture alias.
- `/uufprofile stop`
  - Stop capture.
- `/uufprofile analyze`
  - Print analysis.
- `/uufdebug`
  - Toggle debug console.
- `/uufml help`
  - Show ML optimizer commands.
- `/uufml stats`
  - Show ML stats.
- `/uufml save`
  - Force-save ML state.
- `/uufml reset`
  - Reset ML state (memory + persisted).

## Notes
- API usage should continue to be validated against local `wow-ui-source` references.
- Lua 5.1 compatibility patterns are preserved.
- Systems are designed to fail safe (accepted/fallback patterns, guarded initialization, bounded adaptive behavior).
