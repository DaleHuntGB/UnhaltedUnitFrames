# UnhaltedUnitFrames Feature Summary

UnhaltedUnitFrames is a performance-focused oUF unit frame replacement with modern optimization systems, advanced castbar visuals, and live profiling tools.

## Highlights
- Full core frame suite: Player, Target, TargetTarget, Focus, FocusTarget, Pet, Party, Boss.
- Highly customizable layout, colors, text tags, and media.
- Combat-safe updates and protected-operation queueing.
- Real-time performance optimization stack with event batching and dirty-flag processing.
- Advanced ML-assisted tuning for event priority and coalescing delay behavior.

## CastBar Enhancements
- Timer Direction indicators.
- Channel Tick markers.
- Empower Stage indicators.
- Latency indicators and large-group performance fallback.

## Performance and Stability Systems
- EventCoalescer with priority-aware batching.
- DirtyFlagManager for batched frame updates.
- FrameTimeBudget for frame spike control.
- FramePoolManager + IndicatorPooling for lower allocation churn.
- CoalescingIntegration for centralized high-frequency event handling.
- Queue acceptance + fallback paths to prevent race-time event loss.

## ML Optimization
- DirtyPriorityOptimizer learns update priority patterns.
- MLOptimizer learns adaptive event delays by context.
- Persisted ML state across relog/reload.
- Safe per-event clamp policy for adaptive delay tuning.

## Diagnostics and Tooling
- `/uufperf` live performance dashboard.
- `/uufprofile` timeline profiler with coalesced/dispatched/rejected metrics.
- Timed profiling support: `/uufprofile start 90` (auto-stop + auto-analyze).
- `/uufdebug` debug console with tiered and per-system output controls.

## Useful Commands
- `/uufperf` - Toggle performance dashboard.
- `/uufprofile start` - Start profiling.
- `/uufprofile start 120` - Timed profiling run.
- `/uufprofile stop` - Stop profiling.
- `/uufprofile analyze` - Print profile analysis.
- `/uufdebug` - Open debug console.
- `/uufml stats` - ML optimizer stats.
- `/uufml save` - Save ML state.
- `/uufml reset` - Reset ML state.

## Current Direction
The addon is now in a strong optimization state: coalescing coverage is broad, batching metrics are visible, queue rejections are tracked, and adaptive ML behavior is bounded for responsiveness.
