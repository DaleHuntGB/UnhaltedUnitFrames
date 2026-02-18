# Project Guidelines

## Code Style
- Prefer `UUF:` namespaced functions with locals declared near the top of each file; keep style compact and low-comment like existing code in [Core/UnitFrame.lua](../Core/UnitFrame.lua) and [Elements/CastBar.lua](../Elements/CastBar.lua).
- Configuration UI uses AceGUI widgets and shared helper wrappers in [Core/Config/GUIWidgets.lua](../Core/Config/GUIWidgets.lua); follow patterns in [Core/Config/GUI.lua](../Core/Config/GUI.lua).
- Defaults live in AceDB tables in [Core/Defaults.lua](../Core/Defaults.lua); update defaults whenever adding new settings.

### Patch 12.0.0 Compatibility Patterns
- **Never branch on secret values** (`if UnitHealth() < threshold then`) — use `issecretvalue()` to detect and use appropriate API (e.g., `StatusBar:SetValue()` accepts secrets).
- Pass secret values **directly to widget APIs** that accept them (`StatusBar:SetValue(hp)`, `FancyString:SetText(name)`); do not attempt arithmetic or comparison.
- Use `C_CurveUtil` and `C_DurationUtil` for visualizations instead of manual math: `C_CurveUtil.CreateColorCurve()` maps health → color without addon seeing actual value.
- Query restriction state with `C_RestrictedActions` to gracefully degrade when in restricted instances (no unit info, no addon comms, secret values).
- **Do not use `COMBAT_LOG_EVENT_UNFILTERED`** (no longer available to addons); use `COMBAT_LOG_MESSAGE` or `C_DamageMeter` for damage tracking.
- **Do not send addon messages in instances** (`SendAddonMessage()` blocked during combat lockdown); design frames to function independently without inter-player communication.
- Use `issecretvalue()` to guard safe unit info queries; provide fallbacks (e.g., `if issecretvalue(race) then race = nil end`); see [Core/Helpers.lua](../Core/Helpers.lua) for helper functions.
- Call `SetToDefaults()` on widgets that receive secrets to clear secret state if switching from secret → non-secret data flow.

## Architecture
- AddOn load order is libraries -> elements -> core via [UnhaltedUnitFrames.toc](../UnhaltedUnitFrames.toc), [Elements/Init.xml](../Elements/Init.xml), and [Core/Init.xml](../Core/Init.xml).
- Initialization and event wiring are in [Core/Core.lua](../Core/Core.lua); global utilities, media registration, and `UUF:ResolveLSM()` live in [Core/Globals.lua](../Core/Globals.lua).
- Unit frame creation/update flows through [Core/UnitFrame.lua](../Core/UnitFrame.lua), with element implementations in [Elements/](../Elements/).

## Build and Test
- No build/test commands are documented in this repo.

## Project Conventions
- Use `UUF:QueueOrRun` for protected operations during combat lockdown (see [Core/Core.lua](../Core/Core.lua)).
  - `UUF:QueueOrRun(fn)` checks `InCombatLockdown()` and either executes immediately or queues to `UUF._safeQueue` for deferred execution when combat ends.
  - Safe queue flushes on `PLAYER_REGEN_ENABLED` event; use for frame positioning, anchoring, hide/show, attribute changes.
  - **Never** use outside combat for normal operations (adds unnecessary complexity); reserve only for protected operations.
- Safe unit info checks guard against secret values returned during combat/restricted zones:
  - Use `issecretvalue(value)` check for `UnitRace()`, `UnitClassification()`, `UnitFactionGroup()`, and role queries.
  - Provide fallback values: `if issecretvalue(classification) then return "normal" end` (see [Core/Helpers.lua](../Core/Helpers.lua) for examples).
  - Helper functions `UUF:GetSafeUnitClassification()`, `UUF:GetSafeUnitRace()`, `UUF:GetSafeUnitFactionGroup()` already handle this.
- Batching configuration applies deferred callbacks in single timer tick (e.g., `UUF:BatchConfigureAuraDurations()`) to avoid multiple Layout/Font operations.
- Layout is stored in `UnitDB.Frame.Layout` arrays and applied in [Core/UnitFrame.lua](../Core/UnitFrame.lua); keep layout arrays consistent.
- Media is resolved through `UUF.Media` populated by `UUF:ResolveLSM()` in [Core/Globals.lua](../Core/Globals.lua).

## Integration Points
- oUF for frame spawning and colors (see [Libraries/oUF](../Libraries/oUF) and [Core/UnitFrame.lua](../Core/UnitFrame.lua)).
- Ace3 (AceAddon/AceDB/AceGUI), LibSharedMedia, LibDualSpec, LibDeflate, LibDispel (see [Libraries/](../Libraries/)).

## Security
- Combat lockdown applies to protected operations (frame attribute changes, anchoring, hide/show during combat).
  - CheckInCombatLockdown() throws error if called; use `InCombatLockdown()` to check if combat active.
  - Always defer protected changes using `UUF:QueueOrRun()` — safe queue auto-flushes on `PLAYER_REGEN_ENABLED`.
  - Avoid in-combat layout edits (See [Core/Core.lua](../Core/Core.lua) for queue implementation).
- Secret values: Some unit APIs return secret/redacted values in combat or restricted instances (12.0.0+).
  - Check `issecretvalue(result)` before using unit info in restricted contexts.
  - Common cases: `UnitRace()`, `UnitClassification()`, role queries in PvP/dungeon environments.
  - Always provide sensible fallbacks (e.g., default to "normal" for classification, nil for faction).

## GUI Sidebar Architecture (WoW 12.0.0+)
- Config UI uses dual-mode support: sidebar-based tree navigation (default) with fallback to classic tabs.
- Sidebar tree widget is native WoW frames-based (no external dependencies) - implements TreeNodeMixin for expand/collapse behavior.
- Tree uses parent button references for accurate parent-child visibility (not backwards scanning of buttons).
- Tree layout defined in [Core/Config/GUILayout.lua](../Core/Config/GUILayout.lua); 3-level hierarchy max depth; each node has `id`, `label`, `icon`, optional `children`.
- Gallery stored per profile in [Core/Defaults.lua](../Core/Defaults.lua) under `GUI.ExpandedNodes` (nodeId -> boolean) and `LastSelectedNode` (nodeId string).

## Element Routing Pattern (Sidebar)
- Element nodes route via `tree.OnNodeSelected(nodeId, nodeData)` handler in [Core/Config/GUI.lua](../Core/Config/GUI.lua).
- Node IDs follow pattern: unit_element (e.g., `player_frame`, `party_castbar`, `boss_auras`).
- Routing extracts unit and element, dispatches to appropriate builder in [Core/Config/GUIUnits.lua](../Core/Config/GUIUnits.lua).
- Global settings (fonts, textures, colors, range) route to individual builders in [Core/Config/GUIGeneral.lua](../Core/Config/GUIGeneral.lua).

## Test Frame Pattern
- Test frames display in sidebar when viewing element settings (not when viewing parent unit node).
- Each unit has test mode flag: `UUF.TARGET_TEST_MODE`, `UUF.FOCUS_TEST_MODE`, `UUF.PET_TEST_MODE`, `UUF.BOSS_TEST_MODE`, `UUF.PARTY_TEST_MODE`.
- Test mode functions follow naming convention: `UUF:CreateTest<Unit>Frame()` (see [Core/TestEnvironment.lua](../Core/TestEnvironment.lua)).
- Test frames display unit name (e.g., `TargetFrame.Name:SetText("Target")`), spawn data from `EnvironmenTestData` table.
- Test frames use `SetAttribute("unit", nil)` + `UnregisterUnitWatch()` to detach from real unit data; restore with `SetAttribute("unit", "unit_name")` + `RegisterUnitWatch()`.
- Explicit enable/show check at end ensures frame stays visible when switching between element settings.
- Test castbars implement OnUpdate loop: increment value 0-1000 over N seconds, update duration text with spell casting time.

## Sidebar Tree Widget Implementation
- Tree widget created in [Core/Config/GUITreeFallback.lua](../Core/Config/GUITreeFallback.lua) (used when AbstractFramework unavailable).
- Key methods: `BuildTree(layout, indentLevel, parentBtn)`, `Layout()`, `IsNodeVisible(node)`, `SelectNode(nodeId)`.
- BuildTree stores `button.parentBtn = parentBtn` on each button for accurate ancestry tracking.
- IsNodeVisible walks up parent chain via `parentBtn` references, returns false if any ancestor is collapsed.
- Layout shows/hides buttons based on ancestor visibility; updates expand icon text ("+" or "−").
- Click handlers: expand button calls `ToggleExpanded()`, node label calls `OnNodeSelected()` then expands if parent.

## Optional Framework Integration
- AbstractFramework detection in [Core/Config/GUIBridge.lua](../Core/Config/GUIBridge.lua); feature flag `UUF.GUI.Features.Sidebar = true` always available (fallback tree always works).
- Marked as optional dependency in [UnhaltedUnitFrames.toc](../UnhaltedUnitFrames.toc) with `OptionalDeps: AbstractFramework`.

## Common Issues & Fixes

### Tree Parent Lookup (Critical Bug Fix)
- **Problem**: Earlier implementation used backwards node list scanning to find parent, causing unrelated later nodes to be incorrectly matched as parent. Global node would incorrectly expand all siblings.
- **Root Cause**: `IsNodeVisible()` scanned from end of `nodeButtons` list looking for parent ID match, could find wrong node if multiple nodes had similar data.
- **Fix**: Store direct parent button reference during tree build: `button.parentBtn = parentBtn` in `BuildTree()`.
- **Impact**: `IsNodeVisible()` now walks `parentBtn` chain directly instead of scanning list. Each node expands independently. Global only affects its own children.
- **Code Pattern**: Avoid backwards-scanning node lists; always store parent references during construction.

### Test Frame Persistence (Visibility Workaround)
- **Problem**: When switching between element settings, test frames (Target, Focus, Pet) would disappear.
- **Root Cause**: Test frame creation functions weren't calling Show() at end, frame created but not visible on switch.
- **Fix**: Explicit visibility check at end of test function: `if FrameDB.Enabled then Frame:Show() end`.
- **Pattern**: After SetAttribute changes and configuration, always explicitly Show() test frames to persist visibility across navigate. This ensures test frames remain visible when user clicks between different elements on same unit.
- **Example**: [Core/TestEnvironment.lua](../Core/TestEnvironment.lua) line end comments show `Frame:Show()` pattern.

### Party Frame Menu Item
- Party Cast Bar was not appearing in the sidebar menu options.
- Added `{ id = "party_castbar", label = "Cast Bar", element = "castbar" }` to Party unit children in [Core/Config/GUILayout.lua](../Core/Config/GUILayout.lua).
- Party Cast Bars enabled by default in [Core/Defaults.lua](../Core/Defaults.lua) so test preview works.

### Edit Mode & Frame Mover Integration
- Edit mode hooks registered via `UUF:SetupEditModeHooks()` in [Core/Core.lua](../Core/Core.lua).
- Frame movers positioned when EditModeManagerFrame shows/hides; synced with `ApplyEditModeLayout()`.
- **Pattern**: Use `EditModeManagerFrame:HookScript("OnShow/OnHide", ...)` to sync unit frame visibility with edit mode state.

## Batching & Performance Patterns
- Multiple configuration changes on same frame should be batched into single deferred callback.
- Use `UUF:BatchConfigureAuraDurations(buttons, unit)` pattern: collect work items, schedule single timer, apply all in one callback.
- Benefits: Avoids redundant Layout/Font/Texture updates; reduces frame stuttering during config UI changes.
- **Example**: Aura duration font configuration batches all button cooldown text updates into one 0.01s timer callback (see [Core/Helpers.lua](../Core/Helpers.lua) `BatchConfigureAuraDurations`).

## Party Frame Support Pattern
- Party frames created via `UUF:SpawnUnitFrame("party")` in [Core/Core.lua](../Core/Core.lua).
- Party member updates triggered on `GROUP_ROSTER_UPDATE` and `PLAYER_ROLES_ASSIGNED` events (batched 0.5s threshold).
- Party role sorting (dps/tank/healer) triggers test frame recreation via `UUF:CreateTestPartyFrames()`.
- **Pattern**: Single "party" unit frame dynamically manages N party member sub-frames; config stored per unit in `db.profile.Units.party`.
- Test frames for party accessed via `UUF.PARTY_TEST_MODE` flag and test creation function.

## Edit Mode & Frame Positioning
- Frame positioning is deferred during combat via `UUF:QueueOrRun()` to avoid taint.
- Edit mode layout applied separately from normal layout; frame movers appear/disappear based on edit mode state.
- **Never** apply positioning directly; always use `UUF:QueueOrRun()` for any SetPoint/ClearPoints calls.
- Frame mover functionality hooked on EditModeManagerFrame show/hide events.
## Phase 4: Enhanced GUI Features (Search, Bulk Ops, Presets, Comparison, Keyboard Nav)

### Search & Filtering
- Search box above sidebar tree filters nodes in real-time by label/id (case-insensitive)
- Matching nodes displayed at full alpha, non-matching at 0.4 alpha (dimmed)
- Result count shows number of matches (e.g., "3 matches")
- Clear button resets search and shows all nodes
- Search terms auto-added to history (last 10) on blur if non-empty
- Use `UUF:FilterTreeBySearch(tree, searchText)`, returns match count
- Use `UUF:ClearTreeSearch(tree)` to reset all node visibility

### Bulk Operations Toolbar
- Horizontal toolbar with Copy, Paste, Reset, Presets, Compare buttons
- **Copy (Ctrl+C)**: Copy entire unit config to clipboard → `UUF:CopyUnitConfig(unit)`
- **Paste (Ctrl+V)**: Apply clipboard config to current unit → `UUF:PasteUnitConfig(unit)` (preserves Enabled flag)
- **Reset (Ctrl+R)**: Reset unit to defaults → `UUF:ResetUnitToDefaults(unit)`
- **Presets (Alt+P)**: Open preset management panel
- **Compare**: Open unit comparison panel
- Clipboard stored in `db.profile.GUI.ConfigClipboard` with sourceUnit/timestamp/config
- All tooltips show keyboard shortcuts

### Preset System
- Save current profile as named snapshot: `UUF:SavePreset(name, description, isGlobal)`
- Load preset: `UUF:LoadPreset(name, isGlobal)` applies to current profile
- Delete preset: `UUF:DeletePreset(name, isGlobal)`
- Export as encoded string: `UUF:ExportPreset(name, isGlobal)` for sharing
- Import from string: `UUF:ImportPreset(encodedString, name, isGlobal)`
- Get all presets: `UUF:GetPresetList(isGlobal)` returns sorted list
- Presets include version/timestamp for validation
- Stored in `db.profile.GUI.Presets` (profile-scoped) or `db.global.Presets` (global)
- Preset panel shows save/load/delete/export UI with auto-refresh

### Comparison View
- Compare two units side-by-side via `UUF:CompareUnitConfigs(unitA, unitB)`
- Get all differences: `UUF:GetDifferences(tableA, tableB, path)` (deep recursive diff)
- Differences displayed as path-based list with values (A in green, B in red)
- Swap button exchanges Unit A/B for quick toggling
- A→B button copies Unit A's config to Unit B (overwrites B)
- B→A button copies Unit B's config to Unit A (overwrites A)
- Comparison panel persists until closed, stored in `db.profile.GUI.ComparisonMode/UnitA/UnitB`

### Keyboard Navigation (Tree Widget)
- **Enabled on scroll frame** via `EnableKeyboard(true)` + OnKeyDown handler
- **Arrow Up/Down**: Navigate between visible nodes → `tree:NavigateUp()` / `tree:NavigateDown()`
- **Arrow Left**: Collapse expanded node
- **Arrow Right**: Expand collapsed parent node
- **Enter**: Select focused node (triggers click)
- **Home/End**: Jump to first/last visible node
- **Escape**: Clear search and reset focus (implement in GUI.lua)
- Focused node highlighted at alpha 1.3, auto-scrolls to stay visible
- Use `tree:SetFocusedNode(button)` to set focus, `tree:GetFocusedNode()` to get current
- Use `tree:HandleKeyDown(key)` to process key events (called by scroll frame handler)
- Use `tree:ScrollToNode(button)` to auto-scroll focused node into view

### Implementation Patterns
- **Config Clipboard**: Deep-copy with `UUF:DeepCopyTable(config)`, preserve flags on paste
- **Search History**: Store last 10 searches in `db.profile.GUI.SearchHistory`, append-on-blur
- **Preset Format**: JSON serializable table with name/version/timestamp/description/config
- **Comparison**: Recursive diff walks both tables, returns array of {path, valueA, valueB}
- **Keyboard**: All navigation wrapped in bounds checks for visible nodes only
- **Modal Panels**: Presets and Comparison are popup frames (size ~300x400 and ~500x450)

### File Dependencies
- Core/Config/GUIHelpers.lua - 30+ helper functions for all Phase 4 features
- Core/Config/GUISearch.lua - Search box component with history
- Core/Config/GUIToolbar.lua - Five-button toolbar with callbacks
- Core/Config/GUIPresets.lua - Preset management panel (save/load/delete/export)
- Core/Config/GUIComparison.lua - Unit comparison panel with diff display
- Core/Config/GUITreeFallback.lua - Updated with keyboard navigation support
- Core/Config/GUI.lua - Main integration point (pending: load components, wire callbacks)

## Credits & Attribution System

### Overview
Dedicated Credits panel in sidebar provides proper attribution to library and addon creators.

**Location**: Sidebar → Credits

**Files**:
- [Core/Config/GUICredits.lua](../Core/Config/GUICredits.lua) - Credits display module (NEW)
- [Core/Config/GUILayout.lua](../Core/Config/GUILayout.lua) - Updated with credits node
- [Core/Config/GUI.lua](../Core/Config/GUI.lua) - Routes credits node to builder
- [CREDITS.md](../CREDITS.md) - Full credits documentation

### Features
- **Organized Attribution**: Libraries grouped by type with contributor roles
- **Color-Coded Display**: 
  - Section headers: `|cFFFFCC00` (gold)
  - Author names: `|cFF80B0FF` (light blue)
  - Descriptions: Normal font
  - Footer: `|cFF888888` (gray)
- **Static Display**: Read-only panel, no settings stored
- **Auto-Generated UI**: Rendered from `CREDITS_DATA` table in GUICredits.lua

### Adding Credits
Edit [Core/Config/GUICredits.lua](../Core/Config/GUICredits.lua) `CREDITS_DATA` table:

```lua
CREDITS_DATA = {
    {
        section = "Library Name",
        credits = {
            { name = "Author Name", role = "Contribution" },
        }
    },
}
```

Then call `GUICredits:BuildCredits(scrollFrame)` to render.

### Current Credits Included
- **UnhaltedUnitFrames**: Unhalted (Creator), DaleHuntGB (Maintainer)
- **AbstractFramework**: Framework & UI System
- **Ace3**: AceAddon, AceDB, AceGUI, AceConfig, AceConsole, AceEvent, AceHook, AceTimer
- **LibSharedMedia**: Media registration (fonts, textures, sounds)
- **LibDualSpec**: Talent spec detection
- **LibDispel**: Dispel & clean filtering
- **LibDeflate**: Compression library
- **oUF**: Unit frame framework (haste & contributors)

### AbstractFramework Approach
- Currently **OptionalDeps** in .toc file
- Users with AbstractFramework installed: Uses external version
- Users without it: UUF works with fallback UI
- No duplicate files (keeps addon size smaller)
- Future: Can be fully embedded if needed (see [ABSTRACTFRAMEWORK-EMBEDDING.md](../ABSTRACTFRAMEWORK-EMBEDDING.md))

### Integration Flow
1. User clicks "Credits" in sidebar
2. `tree.OnNodeSelected("credits")` triggered
3. Router calls `GUICredits:BuildCredits(ScrollFrame)`
4. Credits rendered with color formatting
5. Display updated when Credits node selected again