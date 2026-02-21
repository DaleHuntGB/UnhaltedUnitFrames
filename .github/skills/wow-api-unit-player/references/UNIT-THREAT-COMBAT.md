# Unit Threat & Combat Reference

> **Source:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#Unit
> **Patch:** 12.0.0 (Retail)

## Threat Functions

### UnitThreatSituation(unit [, mob]) → status

Returns the threat status of `unit` toward `mob`. If `mob` is omitted, returns the highest threat status across all mobs.

| Status | Meaning | Typical Color |
|--------|---------|---------------|
| `0` | Low threat, not tanking | Grey |
| `1` | High threat, close to pulling | Yellow |
| `2` | Tanking but not highest threat | Orange |
| `3` | Tanking and highest threat | Red |
| `nil` | Not on threat table | — |

```lua
local status = UnitThreatSituation("player", "target")
if status == 3 then
    print("You are tanking!")
elseif status == 1 then
    print("Watch your threat!")
end
```

### UnitDetailedThreatSituation(unit, mob) → isTanking, status, scaledPct, rawPct, rawThreat

Returns detailed threat information.

| Return | Type | Description |
|--------|------|-------------|
| `isTanking` | `bool` | Whether the unit is the current tank target |
| `status` | `number` | Same as `UnitThreatSituation` (0-3) |
| `scaledPct` | `number` | Threat as % of the top player (0-100) |
| `rawPct` | `number` | Raw threat as % of the current tank's threat |
| `rawThreat` | `number` | Absolute threat value |

```lua
local isTanking, status, scaled, raw, threat = UnitDetailedThreatSituation("player", "target")
if threat then
    print(string.format("Threat: %d (%.1f%% of tank)", threat, raw))
end
```

### UnitThreatPercentageOfLead(unit, mob) → percent

Returns how far ahead (or behind) `unit` is from the next closest threat target.

### UnitThreatLeadSituation(unit, mob) → status

Returns threat lead status.

### Threat Coloring Pattern

```lua
local THREAT_COLORS = {
    [0] = { 0.69, 0.69, 0.69 },  -- Low
    [1] = { 1.00, 1.00, 0.47 },  -- Close
    [2] = { 1.00, 0.60, 0.00 },  -- Unsafe
    [3] = { 1.00, 0.00, 0.00 },  -- Tanking
}

local function UpdateThreatColor(frame, unit)
    local status = UnitThreatSituation(unit)
    if status then
        local color = THREAT_COLORS[status]
        frame:SetBackdropBorderColor(color[1], color[2], color[3])
    end
end
```

---

## Targeting Functions

### Player Targeting

| Function | Description |
|----------|-------------|
| `TargetUnit(unit [, exactMatch])` | Target a unit `#hardwareonly` |
| `ClearTarget()` | Clear current target |
| `TargetNearestEnemy([reverse])` | Target nearest enemy `#hardwareonly` |
| `TargetNearestFriend([reverse])` | Target nearest friendly `#hardwareonly` |
| `TargetNearestPartyMember([reverse])` | Target nearest party member `#hardwareonly` |
| `TargetNearestRaidMember([reverse])` | Target nearest raid member `#hardwareonly` |
| `AssistUnit(unit)` | Target unit's target `#hardwareonly` |

### Focus Targeting

| Function | Description |
|----------|-------------|
| `FocusUnit([unit])` | Set focus target |
| `ClearFocus()` | Clear focus target |

### Target Queries

| Function | Returns | Description |
|----------|---------|-------------|
| `UnitIsUnit(unit1, unit2)` | `bool` | Same unit |
| `UnitTarget(unit)` | `targetToken` | What the unit is targeting |

> **Note:** Most targeting functions require hardware input (`#hardwareonly`) — they must be called from a key binding, button click, or macro, not from automated addon code.

---

## Soft Targeting API

Added in Patch 10.0 for controller/accessibility support.

| Function | Returns | Description |
|----------|---------|-------------|
| `GetSoftEnemyUnit()` | `unit` | Current soft enemy target |
| `GetSoftFriendUnit()` | `unit` | Current soft friendly target |
| `GetSoftInteractUnit()` | `unit` | Current soft interact target |

### Soft Target Events

| Event | Payload | Description |
|-------|---------|-------------|
| `PLAYER_SOFT_ENEMY_CHANGED` | `unitToken` | Soft enemy changed |
| `PLAYER_SOFT_FRIEND_CHANGED` | `unitToken` | Soft friend changed |
| `PLAYER_SOFT_INTERACT_CHANGED` | `unitToken` | Soft interact changed |

---

## Inspection

### NotifyInspect(unit)

Requests inspection data for a unit. Fires `INSPECT_READY` when data is available.

**Rules:**
- Can only inspect player characters within range
- Throttled by the server — wait between requests
- Must call `ClearInspectPlayer()` when done

### ClearInspectPlayer()

Clears cached inspection data. Always call after processing `INSPECT_READY`.

### GetInspectSpecialization(unit) → specID

Returns the specialization ID of the inspected unit.

```lua
local specID = GetInspectSpecialization("target")
-- e.g., 250 = Blood DK, 251 = Frost DK, 252 = Unholy DK
```

### Full Inspection Pattern

```lua
local inspectFrame = CreateFrame("Frame")
local pendingInspect = nil

local function InspectUnit(unit)
    if not UnitExists(unit) or not UnitIsPlayer(unit) then return end
    if not CanInspect(unit) then return end
    
    pendingInspect = UnitGUID(unit)
    NotifyInspect(unit)
    inspectFrame:RegisterEvent("INSPECT_READY")
end

inspectFrame:SetScript("OnEvent", function(self, event, guid)
    if event == "INSPECT_READY" and guid == pendingInspect then
        local specID = GetInspectSpecialization("target")
        local ilvl = C_PaperDollInfo.GetInspectItemLevel("target")
        
        print("Spec:", specID, "Item Level:", ilvl)
        
        -- Check equipped items
        for slot = 1, 19 do
            local itemLink = GetInventoryItemLink("target", slot)
            if itemLink then
                print("Slot", slot, ":", itemLink)
            end
        end
        
        ClearInspectPlayer()
        self:UnregisterEvent("INSPECT_READY")
        pendingInspect = nil
    end
end)
```

### C_PaperDollInfo Inspection Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `C_PaperDollInfo.GetInspectItemLevel(unit)` | `ilvl` | Average item level |
| `C_PaperDollInfo.GetInspectGuildInfo(unit)` | `achPoints, members, name, realm` | Guild info |
| `C_PaperDollInfo.GetInspectRatedBGData()` | `data` | Rated BG stats |
| `C_PaperDollInfo.GetInspectRatedSoloShuffleData()` | `data` | Solo shuffle stats |

---

## Nameplate Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `C_NamePlate.GetNamePlateForUnit(unit)` | `nameplate` | Get nameplate frame for unit |
| `C_NamePlate.GetNamePlates()` | `nameplates` | All visible nameplates |
| `C_NamePlate.GetNumNamePlates()` | `count` | Number of visible nameplates |

### Nameplate Events

| Event | Payload | Description |
|-------|---------|-------------|
| `NAME_PLATE_UNIT_ADDED` | `unitToken` | Nameplate appeared (e.g., `"nameplate3"`) |
| `NAME_PLATE_UNIT_REMOVED` | `unitToken` | Nameplate removed |

### Nameplate Pattern

```lua
local frame = CreateFrame("Frame")
frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
frame:SetScript("OnEvent", function(self, event, unit)
    if event == "NAME_PLATE_UNIT_ADDED" then
        local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
        local name = UnitName(unit)
        print("Nameplate added:", name, "→", unit)
    end
end)
```

---

## Selection & Interaction

| Function | Returns | Description |
|----------|---------|-------------|
| `CanInspect(unit [, showError])` | `bool` | Can inspect the unit |
| `CheckInteractDistance(unit, index)` | `bool` | Within distance (`#nocombat`) |
| `UnitIsInteractable(unit)` | `bool` | Can interact with |
| `UnitHasSoulstone([unit])` | `bool` | Has soulstone rez available |
| `UnitHasLFGDeserter(unit)` | `bool` | Has LFG deserter debuff |
| `UnitHasLFGRandomCooldown(unit)` | `bool` | Has random LFG cooldown |

---

## Related Events

| Event | Payload | Description |
|-------|---------|-------------|
| `UNIT_THREAT_SITUATION_UPDATE` | `unitTarget` | Threat situation changed |
| `UNIT_THREAT_LIST_UPDATE` | `unitTarget` | Threat list updated |
| `PLAYER_TARGET_CHANGED` | — | Player target changed |
| `PLAYER_FOCUS_CHANGED` | — | Focus target changed |
| `UPDATE_MOUSEOVER_UNIT` | — | Mouseover unit changed |
| `PLAYER_SOFT_ENEMY_CHANGED` | `unitToken` | Soft enemy changed |
| `PLAYER_SOFT_FRIEND_CHANGED` | `unitToken` | Soft friend changed |
| `PLAYER_SOFT_INTERACT_CHANGED` | `unitToken` | Soft interact changed |
| `INSPECT_READY` | `inspecteeGUID` | Inspection data ready |
| `NAME_PLATE_UNIT_ADDED` | `unitToken` | Nameplate appeared |
| `NAME_PLATE_UNIT_REMOVED` | `unitToken` | Nameplate removed |
| `UNIT_COMBAT` | `unitTarget, event, flagText, amount, schoolMask` | Combat text event |

> **Source:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#Unit
