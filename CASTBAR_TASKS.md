# Castbar Enhancements: Remaining Tasks

## Current Status
✅ **Architecture:** Complete  
✅ **Defaults System:** Complete  
✅ **GUI Configuration:** Complete  
✅ **CastBar Integration:** Complete  
✅ **Feature Frameworks:** Complete  
🔄 **Feature Rendering:** In Progress  
🧪 **Testing:** Awaiting Testing  

---

## Remaining Implementation Work

### Priority 1: Timer Direction Visual (READY FOR TESTING)
**Status:** ✅ Implementation complete  
**Lines of Code:** ~40 (in CastBarEnhancements.lua)  
**Testing Needed:**
- [ ] Test ARROW mode
  - [ ] Player castbar
  - [ ] Target castbar (test mode + real)
  - [ ] Check arrow direction updates with progress
  - [ ] Test RIGHT anchor positioning
- [ ] Test TEXT mode
  - [ ] Verify ► symbol shows (RTL)
  - [ ] Verify ◄ symbol shows (LTR)
  - [ ] Font size scales with castbar height
  - [ ] Text color precedent
- [ ] Test BAR mode
  - [ ] Vertical line renders centered
  - [ ] Thickness/position correct
  - [ ] Color applied correctly

**Edge Cases to Test:**
- [ ] Instant casts (0ms duration)
- [ ] Very fast casts (0.5s)
- [ ] Very slow casts (10s)
- [ ] ReverseFill castbars
- [ ] Small/large castbars (various sizes)

---

### Priority 2: Channel Tick Markers (FRAMEWORK READY)
**Status:** 🔄 Rendering needed  
**Current Code:** ~30 lines (tick detection framework)  
**Work Needed:**
1. Expand `UpdateChannelTicks()` to render tick lines/dividers
2. Implement tick positioning calculation
3. Add opacity/color application
4. Handle variable tick counts (2-5 most common)

**Testing Needed:**
- [ ] Test LINES style (vertical dividers)
- [ ] Test channel visual feedback
- [ ] Verify tick count accuracy per spell
- [ ] Test color override functionality
- [ ] Test opacity slider effect

**Edge Cases:**
- [ ] Instant channel spells
- [ ] Channel interruption mid-ticks
- [ ] Multiple tick counts (determine pattern)
- [ ] Castbar resizing during channel

---

### Priority 3: Empower Stage Visuals (FRAMEWORK READY)
**Status:** 🔄 Rendering needs refinement  
**Current Code:** ~45 lines (stage detection + positioning)  
**Work Needed:**
1. Refine LINES vs FILLS vs BOXES visual styles
2. Ensure proper stage count detection
3. Test with Evoker class abilities
4. Verify color/thickness application

**Testing Needed:**
- [ ] Test LINES style (vertical dividers)
  - [ ] 2-stage empower
  - [ ] 3-stage empower
  - [ ] 4-stage empower
- [ ] Test FILLS style (progressive coloring)
- [ ] Test BOXES style (individual boxes)
- [ ] Verify stage count accuracy
- [ ] Test color application

**Edge Cases:**
- [ ] Empower interruption mid-stage
- [ ] Maximum stage count (5+)
- [ ] Castbar resizing during empower
- [ ] Player vs target empower tracking

---

### Priority 4: Latency Indicator (READY FOR TESTING)
**Status:** ✅ Display logic complete  
**Lines of Code:** ~25 lines  
**Testing Needed:**
- [ ] Test latency display text
  - [ ] Verify "XXXms" format
  - [ ] Test ShowValue toggle
  - [ ] Font size scaling
  - [ ] Position anchor (bottom-right)
- [ ] Test latency coloring
  - [ ] Low latency: green color shows
  - [ ] High latency: threshold trigger (150ms default)
  - [ ] Threshold slider adjusts behavior
  - [ ] Color transitions smooth

**Edge Cases:**
- [ ] Zero latency display
- [ ] Very high latency (500+ms)
- [ ] Latency threshold boundary (149/150/151ms)
- [ ] Disable text but keep coloring
- [ ] Font clarity at different sizes

---

### Priority 5: Interrupt Feedback (FRAMEWORK READY)
**Status:** ✅ Uses existing NotInterruptibleOverlay  
**Lines of Code:** Integrated with CastBar.lua existing code  
**Testing Needed:**
- [ ] Verify green overlay on interruptible casts
- [ ] Verify purple overlay on resisted casts
- [ ] Check overlay opacity (30% default)
- [ ] Test color customization
- [ ] Verify state transitions

**Edge Cases:**
- [ ] Non-interruptible spell (uninterruptibleOverlay active)
- [ ] Spell becomes interruptible mid-cast
- [ ] Spell resisted feedback
- [ ] Multiple casts rapid succession

---

### Priority 6: Performance Fallback (LOGIC COMPLETE)
**Status:** ✅ ShouldSimplify() logic complete  
**Lines of Code:** ~15 lines  
**Testing Needed:**
- [ ] Test group size detection
- [ ] Verify threshold comparison
- [ ] Test simplification/complexity toggle
  - [ ] Below 15: All features enabled
  - [ ] Exactly 15: Features still enabled
  - [ ] Above 15: Features disabled
  - [ ] Back below threshold: Features re-enabled
- [ ] Verify threshold slider in GUI
- [ ] Test threshold boundary conditions (14/15/16)

**Edge Cases:**
- [ ] Solo player (group size = 1)
- [ ] Raid tier changes (5 → 10 → team)
- [ ] Dynamic group resize mid-cast
- [ ] Threshold slider edge values (5, 40)

---

## GUI Testing Checklist

### Enhancements Tab Navigation
- [ ] Tab appears in CastBar configuration
- [ ] Tab accessible for all 8 unit types
- [ ] Tab selection persists between UI reloads
- [ ] Tab content clears properly on tab switch

### Timer Direction Controls
- [ ] Toggle enable/disable works
- [ ] Type dropdown changes (ARROW ↔ TEXT ↔ BAR)
- [ ] Color picker updates color
- [ ] Disabled controls when toggled off
- [ ] Settings persist
- [ ] Apply to target: `UpdateUnitCastBar()` called

### Channel Ticks Controls
- [ ] Toggle enable/disable works
- [ ] Color picker updates color
- [ ] Opacity slider (0.0-1.0) works
- [ ] Disabled controls when toggled off
- [ ] Settings persist

### Empower Stages Controls
- [ ] Toggle enable/disable works
- [ ] Style dropdown (LINES ↔ FILLS ↔ BOXES)
- [ ] Color picker updates color
- [ ] Thickness slider works (1-5)
- [ ] Disabled controls when toggled off

### Latency Indicator Controls
- [ ] Toggle enable/disable works
- [ ] "Show Value" toggle works
- [ ] Threshold slider range (50-500ms)
- [ ] Color picker for normal state
- [ ] Separate color picker for high latency
- [ ] All disabled controls properly gated

### Performance Settings Controls
- [ ] Simplify toggle enable/disable
- [ ] Group size threshold slider (5-40)
- [ ] Threshold disabled when simplify is off
- [ ] Settings persist

---

## Comprehensive Test Scenarios

### Scenario 1: Solo Player Castbar
**Setup:** Player alone, all features enabled  
**Test:**
- [ ] Timer direction shows cast direction
- [ ] Channel ticks visible on channel spells
- [ ] Empower stages visible on Evoker spells
- [ ] Latency display shows network ms
- [ ] All features work without lag

### Scenario 2: Target/Focus Castbar
**Setup:** Test with target/focus units  
**Test:**
- [ ] Features work on target castbar
- [ ] Features work on focus castbar
- [ ] Conditional unit spawning (show/hide based on selection)
- [ ] Features persist when unit changes

### Scenario 3: Small Group
**Setup:** Party of 5 players, all features enabled  
**Test:**
- [ ] All party castbars show enhancements
- [ ] Performance threshold = 15 (should NOT simplify)
- [ ] All features visible and functional
- [ ] FPS impact acceptable (<5% increase)

### Scenario 4: Large Raid (Performance Fallback)
**Setup:** Raid of 20+ players, all features enabled  
**Test:**
- [ ] Threshold triggers (>15 automatically simplifies)
- [ ] Channel ticks disabled for raid members
- [ ] Empower stages disabled
- [ ] Latency display disabled
- [ ] Basic bar + spell name remains
- [ ] FPS impact minimal

### Scenario 5: Test Mode Validation
**Setup:** CASTBAR_TEST_MODE flag enabled  
**Test:**
- [ ] Timer direction updates with fake timer
- [ ] All enhancements work in test mode
- [ ] Test cast completes without errors
- [ ] UI state correct after test ends

### Scenario 6: Edge Cases
**Setup:** Various edge case scenarios  
**Test:**
- [ ] Instant cast (0ms): No visual errors
- [ ] Very fast cast (0.5s): Rendering correct
- [ ] Very slow cast (30s): Features update smoothly
- [ ] Spell interruption: Visual feedback shows
- [ ] Rapid sequential casts: No memory leaks
- [ ] Latency spike: Coloring updates immediately

---

## Performance Profiling

### Metrics to Track
- [ ] FPS impact with all features enabled (solo)
- [ ] FPS impact with simplification active (raid)
- [ ] Memory overhead per castbar
- [ ] OnUpdate call frequency
- [ ] Texture creation/destruction frequency

### Benchmarks to Hit
- [ ] Solo: >95% FPS retention (0-5% overhead)
- [ ] Raid (simplified): >98% FPS retention (<2% overhead)
- [ ] Memory: <1MB per 8 unit castbars
- [ ] OnUpdate: <1ms average execution

---

## Bug Tracking Template

```lua
-- BUG: [Description]
-- Reproduction Steps:
--   1. [Step 1]
--   2. [Step 2]
--   3. [Step 3]
-- Expected: [What should happen]
-- Actual: [What happens instead]
-- Severity: [CRITICAL|HIGH|MEDIUM|LOW]
-- File: [CastBarEnhancements.lua|CastBar.lua|GUIUnits.lua]
-- Line: [Line number]
-- Fix: [Required fix]
```

---

## Testing Timeline

**Phase 1: Feature Validation (Week 1)**
- Task: Test all 5 features individually
- Owner: QA
- Duration: 2-3 hours
- Output: Bug list, verification checklist

**Phase 2: Integration Testing (Week 2)**
- Task: Test all units + interactions
- Owner: QA
- Duration: 4-5 hours
- Output: Performance metrics, edge case report

**Phase 3: Performance Optimization (Week 2-3)**
- Task: Profile and optimize bottlenecks
- Owner: Developer
- Duration: 3-5 hours
- Output: Optimized code, benchmarks

**Phase 4: User Testing (Week 3)**
- Task: Real-world gameplay testing
- Owner: Beta testers
- Duration: Variable
- Output: User feedback, final tweaks

---

## Future Enhancement Ideas

### Short-term (High Priority)
- [ ] Add sound effects on cast/interrupt events
- [ ] Implement keybind for faster feature toggling
- [ ] Add presets for common playstyles (PvE, PvP, Raid)

### Medium-term (Nice-to-have)
- [ ] Spell rotation preview (show next cast)
- [ ] GCD lockout indicator
- [ ] Precision latency prediction
- [ ] Custom preset save/load

### Long-term (Consider Future)
- [ ] ML-based cast prediction timing
- [ ] Interrupt priority visualization
- [ ] Raid-wide cast tracking helper
- [ ] Advanced analytics per spell type

---

## Success Criteria

- ✅ All 5 features fully functional
- ✅ No crashes or memory leaks
- ✅ <2% performance impact in raids (with simplification)
- ✅ GUI fully responsive and persistent
- ✅ All 8 unit types supported
- ✅ Backward compatible with existing castbars
- ✅ Comprehensive user documentation
- ✅ Ready for production release

---

**Last Updated:** End of Session  
**Current Phase:** Feature rendering + testing  
**Estimated Completion:** 1-2 weeks with dedicated testing
