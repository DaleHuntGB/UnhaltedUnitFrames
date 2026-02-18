## Phase 4: Credits & Attribution Feature

### Overview
The new **Credits** sidebar button provides proper attribution to all libraries and frameworks used by UnhaltedUnitFrames.

### Features
- **Dedicated Credits Panel**: Accessible from the main sidebar under "Credits" button
- **Organized Attribution**: Credits organized by library/framework with contributor information
- **Color-Coded Display**: 
  - Section headers in gold (`|cFFFFCC00`)
  - Author names in light blue (`|cFF80B0FF`)
  - Descriptions in normal font
  - Footer in gray (`|cFF888888`)

### Credits Included

#### UnhaltedUnitFrames
- **Unhalted** - Original Creator & Main Developer
- **DaleHuntGB** - Repository Maintainer & Contributor

#### AbstractFramework
- AbstractFramework Contributors - Framework & UI System
- *Dependency: OptionalDeps - enhances sidebar functionality*

#### Ace3 Libraries
- Ace3 Development Team - Configuration & Database Libraries
- Includes: AceAddon, AceDB, AceGUI, AceConfig, AceConsole, AceEvent, AceHook, AceTimer

#### LibSharedMedia (LSM)
- LSM Contributors - Media Registration System
- Provides: Font, texture, and sound management

#### LibDualSpec
- LibDualSpec Authors - Talent Spec Detection
- Enables: Dual-spec profile switching

#### LibDispel
- LibDispel Contributors - Dispel & Clean Filtering
- Provides: Advanced spell filtering for auras

#### LibDeflate
- LibDeflate Authors - Compression Library
- Used for: Preset export compression

#### oUF (Unit Frames Framework)
- **haste** & oUF Contributors - Unit Frame Foundation
- Core framework for all frame rendering and updates

### Integration

**Location**: Sidebar → Credits

**File Structure**:
```
Core/Config/
├── GUICredits.lua          (New - Credits display module)
├── GUILayout.lua           (Updated - Added credits node)
├── GUI.lua                 (Updated - Routes credits node)
└── Init.xml                (Updated - Loads GUICredits)
```

### Implementation Details

**GUICredits.lua** contains:
- `CREDITS_DATA` table with all library/addon information
- `BuildCredits()` function for UI rendering
- Color-coded text formatting
- Organized section display

The Credits module integrates seamlessly into the existing sidebar tree system:
1. User clicks "Credits" in sidebar
2. `tree.OnNodeSelected` routes to `GUICredits:BuildCredits()`
3. Credits panel displays with proper formatting and organization

### AbstractFramework Dependency

AbstractFramework is included as an `OptionalDeps` in the .toc file. This means:
- ✅ If user has AbstractFramework addon: UUF uses it
- ✅ If user doesn't have it: UUF still loads but with fallback UI
- ✅ No duplicate files in disk
- ✅ Proper credit given in Credits panel

For future full embedding (if desired), copy `/Interface/AddOns/AbstractFramework/*` to `/UnhaltedUnitFrames/Libraries/AbstractFramework/` and update `.toc` dependency.

### How Users Access Credits

1. Open UnhaltedUnitFrames Config (Type `/uuf` or access from AddOns menu)
2. Sidebar displays tree on left side
3. Click **"Credits"** button in sidebar
4. Credits panel appears showing all contributors and libraries

### How to Add More Credits

Edit `Core/Config/GUICredits.lua`:

```lua
CREDITS_DATA = {
    {
        section = "Your Library Name",
        credits = {
            { name = "Author Name", role = "Contribution" },
            { name = "Author 2", role = "Contribution 2" },
        }
    },
    -- ...more entries
}
```

Then update the `BuildCredits()` function rendering if needed.

### Technical Notes

- Credits display is read-only (display only, no settings)
- Text is word-wrapped to fit content area
- Color codes follow UUF's standard color scheme
- Module follows same initialization pattern as other GUI modules
- No database storage required (static data)
- Performance impact: Negligible (only loaded when Credit panel accessed)

---

*Last Updated: February 17, 2026*
