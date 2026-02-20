# Pet Frame Class-Specific Findings Report

## Search Scope
Searched the entire UnhaltedUnitFrames addon codebase (all .lua files) for class-based pet frame visibility conditions, including Hunters, Warlocks, and Demon Hunters.

## Key Findings

### 1. **Pet Frame Spawning Logic**
**Location:** [Core/UnitFrame.lua](Core/UnitFrame.lua#L346)

The pet frame is spawned unconditionally for all classes:
```lua
UUF:SpawnUnitFrame("pet")  -- Called in OnEnable() at line 183 in Core/Core.lua
```

- **Default Enabled:** Pet frame is enabled by default in all profiles (see [Core/Defaults.lua](Core/Defaults.lua#L1254))
- **Storage:** Pet frame stored as `UUF["PET"]` (accessed as `UUF.PET`) via mechanism at [Core/UnitFrame.lua](Core/UnitFrame.lua#L396): `UUF[unit:upper()] = singleFrame`
- **RegisterUnitWatch:** Applied to all pet frames at [Core/UnitFrame.lua](Core/UnitFrame.lua#L435) - **NO class checks**

### 2. **Pet Unit Event Registration**
**Location:** [Core/Core.lua](Core/Core.lua#L225)

Pet frame updates receive events from:
```lua
UnhaltedUnitFrames:RegisterBucketEvent(
    {"PLAYER_CONTROL_LOST", "PLAYER_CONTROL_GAINED", "COMPANION_UPDATE", "UNIT_PET", "UNIT_SPELLCAST_SUCCEEDED"},
    0.25, "OnPetUpdate"
)
```

**Key Events:**
- `COMPANION_UPDATE` - Fired when pet/companion state changes (should work for Warlocks, Hunters, Demon Hunters)
- `UNIT_PET` - Fired when player's pet changes
- **NO class-specific filtering** on these event handlers

### 3. **oUF Library Unit Handling**
**Location:** [Libraries/oUF/ouf.lua](Libraries/oUF/ouf.lua#L31-L40)

The oUF library converts `playerpet` unit reference to `pet`:
```lua
if(realUnit == 'playerpet') then
    realUnit = 'pet'
elseif(realUnit == 'playertarget') then
    realUnit = 'target'
end
```

This means:
- **For Hunters:** `UnitExists("pet")` returns true when hunter has a pet
- **For Warlocks:** Demons are controlled via the `playerpet` unit, oUF converts it to `pet` during active unit evaluation
- **For Demon Hunters:** Should follow same pattern as Hunters if they can summon pets

### 4. **InitialConfigFunction (oUF Group Headers)**
**Location:** [Libraries/oUF/ouf.lua](Libraries/oUF/ouf.lua#L556-L568)

For group headers using pet frames:
```lua
local headerType = header:GetAttribute('oUF-headerType')
local suffix = frame:GetAttribute('unitsuffix')
if(unit and suffix) then
    if(headerType == 'pet' and suffix == 'target') then
        unit = unit .. headerType .. suffix
    else
        unit = unit .. suffix
    end
elseif(unit and headerType == 'pet') then
    unit = unit .. headerType
end
```

**Analysis:** This handles pet unit naming for raid/party pet frames. The single pet frame doesn't use headers, so this doesn't apply directly. **NO class-specific logic detected.**

### 5. **Pet Frame Visibility Mechanism**
**Location:** [Core/UnitFrame.lua](Core/UnitFrame.lua#L405-L414)

Per-frame positioning logic:
```lua
elseif unit == "targettarget" or unit == "focus" or unit == "focustarget" or unit == "pet" then
    local parentFrame = _G[UUF.db.profile.Units[unit].Frame.AnchorParent] or UIParent
    local layout = UUF:GetLayoutForUnit(UUF:GetNormalizedUnit(unit)) or FrameDB.Layout
    UUF:SetPointIfChanged(UUF[unit:upper()], layout[1], parentFrame, layout[2], layout[3], layout[4])
    UUF[unit:upper()]:SetSize(FrameDB.Width, FrameDB.Height)
end
```

**No class-based anchoring, sizing, or visibility logic.**

### 6. **Class-Specific Elements (Not Pet Frame Related)**
Found class-specific logic **only** for:
- **Shaman Totems:** [Libraries/oUF/elements/totems.lua](Libraries/oUF/elements/totems.lua#L48) - Only for Shamans
- **Death Knight Runes:** [Libraries/oUF/elements/runes.lua](Libraries/oUF/elements/runes.lua#L197)
- **Monk Stagger:** [Libraries/oUF/elements/stagger.lua](Libraries/oUF/elements/stagger.lua#L198)
- **Warlock Soul Shards:** [Core/Architecture.lua](Core/Architecture.lua) references suggest secondary power bar system
- **Demon Hunter Soul Fragments:** Similar to warlock implementation

**None of these affect pet frame visibility.**

### 7. **Frame Validation**
**Location:** [Core/Validator.lua](Core/Validator.lua#L114-L143)

Frame validation expects:
- PLAYER frame: MANDATORY (always exists)
- PET frame: Registered with RegisterUnit Watch, conditional visibility
- **No class-specific frame spawning requirements**

### 8. **Range Calculation (Pet Spells)**
**Location:** [Elements/Range.lua](Elements/Range.lua)

Pet range checking is class-specific:
```lua
DEMONHUNTER = { ... }
HUNTER = { ... }
WARLOCK = { ... }
```

But this is for **range calculation only**, not for frame visibility.

### 9. **OnPetUpdate Handler**
**Location:** [Core/Core.lua](Core/Core.lua#L156-L165)

```lua
function UnhaltedUnitFrames:OnPetUpdate()
    if UUF._eventBus then
        UUF._eventBus:Dispatch("PET_UPDATE_BATCH")
    else
        if UUF.PET then
            UUF:UpdateUnitFrame(UUF.PET, "pet")
        end
    end
end
```

**Observations:**
- Updates the pet frame if it exists (`if UUF.PET then...`)
- **No class checks** present
- Called via AceBucket event coalescing on COMPANION_UPDATE

## ✅ CONCLUSION: NO CLASS-SPECIFIC FILTERING FOUND

### Summary
After comprehensive search of all .lua files in the UnhaltedUnitFrames addon:

1. **NO class-based conditions** checking if player is NOT a Hunter before showing pet frame
2. **NO class-based conditions** specifically handling Warlocks differently
3. **NO class-based conditions** for Demon Knights/Demon Hunters
4. **NO hardcoded logic** disabling pet frame based on player class
5. **NO special InitialConfigFunction** that filters by class
6. **NO conditions in oUF configuration** preventing pet frame registration for certain classes

### The Pet Frame Display Should Work For:
- ✅ Hunters (with pet summoned)
- ✅ Warlocks (with demon summoned) - via `playerpet` → `pet` unit conversion
- ✅ Any class with `COMPANION_UPDATE` or `UNIT_PET` events

### Potential Issues (Not Addon Code)
The pet frame visibility is controlled by `RegisterUnitWatch()` which automatically handles:
- Shows frame when `UnitExists("pet")` is true
- Hides frame when `UnitExists("pet")` is false

**Possible causes for Warlock pet frame not showing:**
1. `UnitExists("pet")` returns false when only `UnitExists("playerpet")` works for warlocks
2. Pet frame configuration may have `Enabled = false` in user's SavedVariables
3. WoW API behavior change in 12.0.0 for how warlock demons register with Unit API

## Files Reviewed
- ✅ Core/Core.lua
- ✅ Core/UnitFrame.lua
- ✅ Core/Defaults.lua
- ✅ Core/Globals.lua
- ✅ Core/Validator.lua
- ✅ Elements/Range.lua
- ✅ Libraries/oUF/ouf.lua
- ✅ Libraries/oUF/ouf.lua (InitialConfigFunction)
- ✅ Libraries/oUF/units.lua
- ✅ Libraries/oUF/elements/totems.lua
- ✅ Libraries/oUF/elements/runes.lua
- ✅ Libraries/oUF/elements/stagger.lua
- ✅ Libraries/oUF/elements/classpower.lua
