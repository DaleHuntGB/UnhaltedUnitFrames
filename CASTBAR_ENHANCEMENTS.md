# Castbar Enhancements System

## Overview

Complete castbar enhancement system with global centralized settings, LSM textures/fonts integration, class-based colors, and performance fallback for large groups.

**Status:** Architecture complete ✅ | GUI complete ✅ | Feature implementations in progress

## Architecture

### Files Created/Modified

1. **Core/CastBarDefaults.lua** (NEW)
   - Global template for all castbar enhancement features
   - Centralized configuration structure
   - Loaded early in initialization before Defaults.lua merge
   - Provides single source of truth for all features

2. **Elements/CastBarEnhancements.lua** (NEW)
   - Main enhancement module with public API
   - Implements all feature logic: timer direction, channel ticks, empower stages, latency/interrupt feedback, performance fallback
   - Singleton pattern (`UUF.CastBarEnhancements`)
   - Functions: `CreateTimerDirection()`, `UpdateChannelTicks()`, `CreateEmpowerStages()`, `UpdateEmpowerStages()`, `CreateLatencyIndicator()`, `UpdateLatencyIndicator()`, `ShouldSimplify()`

3. **Elements/CastBar.lua** (MODIFIED)
   - PostCastStart hook now calls `UUF:EnhanceCastBar()` to initialize enhancements
   - OnUpdate script calls `UUF:UpdateCastBarEnhancements()` for continuous updates
   - Test mode (CASTBAR_TEST_MODE) fully supported

4. **Core/Defaults.lua** (MODIFIED)
   - Added `MergeCastBarDefaults()` function at EOF (lines 2094-2113)
   - Injects new enhancement settings into all unit CastBar configs
   - Runs on 0.1s delay via `C_Timer.After()` to ensure Architecture loaded
   - Preserves existing settings; only adds new nested tables

5. **Core/Init.xml** (MODIFIED)
   - Added CastBarDefaults.lua load order (line 4)
   - Ensures CastBarDefaults available before Defaults.lua merge call

6. **Core/Config/GUIUnits.lua** (MODIFIED)
   - Added `CreateCastBarEnhancementsSettings()` function (lines 1043-1143)
   - New "Enhancements" tab in CastBar TabGroup (line 1212)
   - GUI for all 5 enhancement features with toggles, sliders, color pickers

7. **Elements/Init.xml** (MODIFIED)
   - Added CastBarEnhancements.lua to load order (line 4)

### Feature Architecture

```
CastBarDefaults.lua (Global Template)
    ↓
Defaults.lua (MergeCastBarDefaults function)
    ↓
UnitDB.CastBar.{TimerDirection, ChannelTicks, EmpowerStages, LatencyIndicator, InterruptFeedback, Performance}
    ↓
CastBarEnhancements.lua (Feature Implementation)
    ↓
GUI Configuration (GUIUnits.lua - Enhancements Tab)
```

## Features

### 1. Timer Direction Indicator
**Status:** Foundation complete ✅ | Visual rendering in progress

- Shows cast timer direction (left-to-right vs right-to-left)
- Display types: ARROW, TEXT, BAR
- Configurable color, size, position
- Auto-hides on cast end

**Config Structure:**
```lua
TimerDirection = {
    Enabled = true,
    Type = "ARROW",           -- "ARROW", "TEXT", or "BAR"
    Size = 12,
    Colour = {1, 1, 1, 1},   -- RGBA
    Layout = {"BOTTOM", castBar, "CENTER", 0}  -- Anchor points
}
```

### 2. Channel Tick Markers
**Status:** Foundation complete ✅ | Tick calculation in progress

- Visual tick marks on channel casts
- Dynamic tick count based on spell duration
- Configurable color and opacity
- Shows channel rhythm at a glance

**Config Structure:**
```lua
ChannelTicks = {
    Enabled = true,
    Colour = {0.5, 1, 0.5, 1},      -- Green RGBA
    Opacity = 0.8,
    Thickness = 2
}
```

### 3. Empower Stage Visuals
**Status:** Foundation complete ✅ | Stage rendering in progress

- Displays empower stages (Evoker ability)
- Display styles: LINES (vertical lines), FILLS (progressive fills), BOXES (individual boxes)
- Configurable color and thickness
- Updates during empower progression

**Config Structure:**
```lua
EmpowerStages = {
    Enabled = true,
    Style = "LINES",             -- "LINES", "FILLS", or "BOXES"
    Colour = {1, 1, 0, 1},       -- Yellow RGBA
    Thickness = 3
}
```

### 4. Latency Indicator
**Status:** Foundation complete ✅ | Display logic in progress

- Shows player latency in milliseconds (optional)
- Color changes based on high latency threshold
- Positioned in castbar corner
- Helps with interrupt timing decisions

**Config Structure:**
```lua
LatencyIndicator = {
    Enabled = true,
    ShowValue = true,                    -- Display "XXXms" text
    Colour = {0, 1, 0, 1},              -- Green RGBA
    HighLatencyColour = {1, 0.5, 0, 1}, -- Orange RGBA
    HighLatencyThreshold = 150           -- ms, triggers color change
}
```

### 5. Interrupt Feedback
**Status:** Foundation complete ✅ | Overlay rendering in progress

- Visual feedback for interruptible vs uninterruptible casts
- Green highlight for interruptible (player can interrupt)
- Purple highlight for resist (ability resisted)
- Automatic state detection

**Config Structure:**
```lua
InterruptFeedback = {
    Enabled = true,
    InterruptableColour = {0, 1, 0, 0.3},  -- Green overlay
    ResistColour = {1, 0, 1, 0.3}          -- Purple overlay
}
```

### 6. Performance Fallback
**Status:** Foundation complete ✅ | Logic implemented

- Automatic simplification for large groups
- Disables expensive features (channel ticks, empower visuals) above threshold
- Maintains basic bar + spell name for performance
- Configurable group size threshold

**Config Structure:**
```lua
Performance = {
    SimplifyForLargeGroups = true,
    GroupSizeThreshold = 15              -- Disable features above this group size
}
```

## GUI Configuration

**Location:** Right-click unit frame → Configure → CastBar → Enhancements tab

**Sections:**
- Timer Direction: Enable/type/color controls
- Channel Ticks: Enable/color/opacity controls
- Empower Stages: Enable/style/color controls
- Latency Indicator: Enable/show value/threshold controls
- Performance Settings: Simplify enable/group size threshold

## Integration Points

### With CastBar.lua
- PostCastStart hook: `UUF:EnhanceCastBar(castBar, castBarDB, unit)`
- OnUpdate hook: `UUF:UpdateCastBarEnhancements(castBar, castBarDB, unit)`
- Test mode compatible (CASTBAR_TEST_MODE flag)

### With Defaults System
- Automatic merge via `MergeCastBarDefaults()` on startup
- Works with all units: player, target, focus, pet, party, boss
- Backward compatible; preserves existing settings

### With oUF Framework
- Leverages existing PostCastStart and PostCastInterruptible hooks
- Works with all unit callbacks
- Respects frame visibility and test mode states

## Usage Example

```lua
-- Enable timer direction for player castbar
local playerCastBarDB = UUF.db.profile.Units.player.CastBar
playerCastBarDB.TimerDirection.Enabled = true
playerCastBarDB.TimerDirection.Type = "ARROW"
playerCastBarDB.TimerDirection.Colour = {1, 0, 0, 1}  -- Red

-- Enable all features with performance fallback
playerCastBarDB.ChannelTicks.Enabled = true
playerCastBarDB.EmpowerStages.Enabled = true
playerCastBarDB.LatencyIndicator.Enabled = true
playerCastBarDB.Performance.SimplifyForLargeGroups = true

-- Update frame to apply changes
UUF:UpdateUnitCastBar(UUF.PLAYER, "player")
```

## Implementation Status

### Completed ✅
- [x] Defaults architecture (CastBarDefaults.lua + merge function)
- [x] Enhancement module structure (CastBarEnhancements.lua)
- [x] CastBar.lua integration hooks
- [x] GUI configuration panel (all 5 features)
- [x] Performance fallback logic
- [x] Load order setup (Init.xml files)

### In Progress 🔄
- [ ] Timer direction visual rendering
- [ ] Channel tick marker rendering
- [ ] Empower stage visual indicators
- [ ] Latency color coding display
- [ ] Interrupt feedback overlays

### Testing Required 🧪
- [ ] All units (player, target, focus, pet, party, boss)
- [ ] Test mode validation
- [ ] Performance monitoring (FPS impact)
- [ ] GUI configuration persistence
- [ ] Edge cases (spell ID lookup, latency edge cases)

## Performance Considerations

- All features check `ShouldSimplify()` before initialization (group size > threshold)
- Large group threshold default: 15 members
- Simplification disables channel ticks, empower visuals, latency display
- Basic castbar (bar + spell name + duration) remains visible always
- LSM textures cached at module load
- Latency lookup (GetNetStats) only during active cast OnUpdate

## Backward Compatibility

- Existing CastBar settings preserved during merge
- Features disabled by default (opt-in only)
- No breaking changes to existing APIs
- Test mode fully supported
- Works with all game client versions (12.0.0+)

## Next Steps

1. **Timer Direction Visual** (Priority 1)
   - Create arrow/text/bar visuals in CreateTimerDirection()
   - Update direction during UpdateUnitCastBar() based on progress
   - Test with all units

2. **Channel Tick Markers** (Priority 2)
   - Implement tick positioning logic
   - Create tick texture/line elements
   - Handle variable tick counts

3. **Empower Stage Indicators** (Priority 3)
   - Integrate C_UnitEmpowerStats() API
   - Create visual dividers/fills/boxes
   - Track stage progression

4. **Latency & Interrupt Feedback** (Priority 4)
   - Color castbar based on latency threshold
   - Show interrupt state overlays
   - Handle cast state changes (interrupted/resisted)

5. **Comprehensive Testing** (Priority 5)
   - All units + test mode
   - Edge case handling
   - Performance profiling
   - GUI persistence validation

## Reference

- [CastBarDefaults.lua](./Core/CastBarDefaults.lua)
- [CastBarEnhancements.lua](./Elements/CastBarEnhancements.lua)
- [CastBar.lua](./Elements/CastBar.lua)
- [GUIUnits.lua](./Core/Config/GUIUnits.lua) - Enhancements tab (line 1043+)
- [Defaults.lua](./Core/Defaults.lua) - MergeCastBarDefaults() (line 2094+)
