# Phase 5: Code Review & Advanced Features

**Date:** February 19, 2026  
**Status:** IN PROGRESS  
**Objective:** Optimize existing systems and add advanced performance visualization

---

## 🔍 Part A: Code Review & Optimization

### 1. FrameTimeBudget Optimizations ✅ COMPLETE

**Issues Identified:**
- ✅ Rolling average recalculates 120 samples every frame (O(n) overhead)
- ✅ Missing percentile tracking (P50, P95, P99) for profiler integration
- ✅ No stale callback protection (callbacks may reference deleted frames)
- ✅ Deferred queue could grow unbounded under heavy load

**Optimizations:**
- ✅ Implement incremental average calculation (O(1) per frame)
- ✅ Add percentile tracking with efficient sorted insertion
- ✅ Add callback validation and cleanup
- ✅ Implement max queue size with overflow handling
- ✅ Add frame time histogram for better analysis

**Expected Impact:**  15-20% reduction in frame time budget overhead  
**Actual Result:** Optimizations complete, testing in progress

---

### 2. EventCoalescer Enhancements ✅ COMPLETE

**Issues Identified:**
- ✅ No priority-based event handling (all events treated equally)
- ✅ Fixed delays don't adapt to current frame time
- ✅ Missing emergency flush for critical events
- ✅ No integration with FrameTimeBudget

**Optimizations:**
- ✅ Add priority levels to coalesced events
- ✅ Integrate with FrameTimeBudget for adaptive delays
- ✅ Implement emergency flush for critical updates
- ✅ Add per-event statistics (min/max/avg batch sizes)

**Expected Impact:** 10-15% better event handling efficiency  
**Actual Result:** Priority integration complete with budget awareness

---

### 3. DirtyFlagManager Edge Cases ✅ COMPLETE (Hotfix Applied)

**Issues Identified:**
- ✅ No handling for frames that are destroyed while dirty
- ✅ Could process same frame multiple times if re-marked during processing
- ✅ No priority decay (old high-priority items stay high forever)
- ⚠️ **CRITICAL BUG:** Used `goto continue` (Lua 5.2+) - WoW uses Lua 5.1 (no goto!)

**Optimizations:**
- ✅ Add frame validation before processing
- ✅ Implement processing lock to prevent re-entry
- ✅ Add priority decay over time
- ✅ Add frame reference counting
- ✅ **HOTFIX:** Removed goto syntax, restructured with if/elseif conditionals

**Expected Impact:** Eliminates potential crashes and redundant processing  
**Actual Result:** Frame validation complete + CRITICAL syntax error fixed (system now loads)

---

### 4. CoalescingIntegration Priority Fix ✅ CRITICAL HOTFIX

**Issue Identified:**
- ✅ ALL events using hardcoded MEDIUM priority (causing health bar batching!)
- ✅ Profiler showed 11 HIGH frame spikes due to critical updates being deferred
- ✅ EVENT_COALESCE_CONFIG needed priority assignments per event type

**Fix Applied:**
- ✅ Changed config from flat delays to {delay, priority} structure
- ✅ UNIT_HEALTH/UNIT_POWER_UPDATE = CRITICAL (immediate flush)
- ✅ UNIT_MAXHEALTH/UNIT_MAXPOWER/UNIT_AURA = HIGH
- ✅ UNIT_THREAT/TOTEMS/RUNES = MEDIUM
- ✅ UNIT_PORTRAIT/MODEL = LOW (cosmetic)
- ✅ Updated handler creation to use priorities
- ✅ Updated MarkDirty calls to pass correct priority

**Expected Impact:** 70-80% spike reduction - critical updates now flush immediately  
**Actual Result:** REQUIRES /reload AND TESTING

---

## 🎨 Part B: Advanced Features

### 4. Real-Time FPS Graph Widget

**Description:** Live FPS monitoring with 60-second history graph

**Features:**
- Miniaturized draggable widget (similar to WoW's latency graph)
- Color-coded FPS ranges (green >55, yellow 30-55, red <30)
- Shows current, min, max FPS
- Click to expand for detailed view
- Auto-hides out of combat (configurable)

**Files:**
- NEW: `Core/Widgets/FPSGraph.lua` (~300 lines)
- MOD: `Core/PerformanceDashboard.lua` - Integration

---

### 5. Frame Time Sparkline Visualization

**Description:** Mini frame time graph embedded in dashboard

**Features:**
- Shows last 120 frames (2 seconds)
- Marks budget threshold (16.67ms line)
- Highlights frame spikes in red
- Hover tooltips show exact frame time
- Adaptive Y-axis scaling

**Files:**
- NEW: `Core/Widgets/FrameTimeSparkline.lua` (~250 lines)
- MOD: `Core/FrameTimeBudget.lua` - Data export

---

### 6. Performance Preset UI

**Description:** User-friendly preset selection interface

**Features:**
- Visual preset cards (Low/Medium/High/Ultra)
- Shows what each preset enables/disables
- One-click apply with confirmation dialog
- "Custom" preset for manual tuning
- Import/export preset configurations
- Preset recommendations based on system performance

**Files:**
- NEW: `Core/Config/GUIPerformancePresets.lua` (~400 lines)
- MOD: `Core/PerformancePresets.lua` - UI integration
- MOD: `Core/Config/GUI.lua` - Add "Performance" tab

---

### 7. Auto-Tuning System

**Description:** Automatically adjusts settings based on measured performance

**Features:**
- Hardware detection (CPU/GPU capabilities)
- Automatic threshold adjustment based on measured frame times
- Learning system that adapts over time
- User approval required before applying changes
- Rollback mechanism if performance degrades

**Components:**
- Hardware capability detection
- Adaptive threshold calculator
- Performance regression detection
- Change proposal system

**Files:**
- NEW: `Core/AutoTuner.lua` (~350 lines)
- MOD: `Core/FrameTimeBudget.lua` - Tunable parameters
- MOD: `Core/PerformancePresets.lua` - Preset generation

---

### 8. Performance Comparison Tools

**Description:** Tools for comparing performance across sessions/configs

**Features:**
- Session snapshot export (JSON format)
- Side-by-side comparison view
- Statistical analysis (t-tests, confidence intervals)
- Identifies significant improvements/regressions
- Export comparison reports

**Files:**
- NEW: `Core/PerformanceCompare.lua` (~300 lines)
- MOD: `Core/PerformanceProfiler.lua` - Session export

---

## 📊 Expected Outcomes

### Performance Improvements:
- **5-10% overall CPU reduction** from optimizations
- **<5 frame spikes** per session (down from 145)
- **P99 frame time < 16ms** (down from 24.3ms)
- **Smoother gameplay** with consistent frame times

### User Experience:
- **Visual feedback** of performance via graphs
- **One-click optimization** via presets
- **Intelligent tuning** that adapts to hardware
- **Data-driven decisions** via comparison tools

---

## 🔧 Implementation Order

### Priority 1 (Core Optimizations):
1. FrameTimeBudget incremental averaging
2. EventCoalescer priority integration
3. DirtyFlagManager validation

### Priority 2 (Visualization):
4. FPS Graph Widget
5. Frame Time Sparkline

### Priority 3 (Advanced):
6. Performance Preset UI
7. Auto-Tuning System
8. Comparison Tools

---

## ✅ Success Criteria

- [ ] All optimizations implemented and tested
- [ ] FPS graph shows real-time performance
- [ ] Frame time consistently < 16.67ms
- [ ] Frame spikes reduced by >95%
- [ ] Preset UI is intuitive and functional
- [ ] Auto-tuner provides valid recommendations
- [ ] All systems validated with `/run UUF.Validator:RunFullValidation()`
- [ ] Documentation updated in WORK_SUMMARY.md
- [ ] User guide created for new features

---

## 📝 Next Steps

Beginning implementation with Priority 1 optimizations...
