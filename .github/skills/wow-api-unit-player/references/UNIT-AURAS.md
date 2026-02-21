# Unit Auras Reference

> **Source:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#UnitAuras
> **Patch:** 12.0.0 (Retail)

## C_UnitAuras Namespace

The `C_UnitAuras` namespace is the primary API for querying buffs and debuffs on units.

---

## Query Functions

### C_UnitAuras.GetAuraDataByIndex(unit, index [, filter]) → AuraData?

Returns aura data by positional index. Index starts at 1.

```lua
local aura = C_UnitAuras.GetAuraDataByIndex("player", 1, "HELPFUL")
if aura then
    print(aura.name, aura.spellId, aura.applications)
end
```

### C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraInstanceID) → AuraData?

Returns aura data by its unique instance ID. Preferred over index-based lookup.

```lua
local aura = C_UnitAuras.GetAuraDataByAuraInstanceID("player", instanceID)
```

### C_UnitAuras.GetAuraDataBySlot(unit, slot) → AuraData?

Returns aura data by slot number. Slots are internal identifiers.

### C_UnitAuras.GetAuraDataBySpellName(unit, spellName [, filter]) → AuraData?

Returns aura data matching a spell name.

```lua
local renew = C_UnitAuras.GetAuraDataBySpellName("player", "Renew", "HELPFUL")
```

### C_UnitAuras.GetBuffDataByIndex(unit, index [, filter]) → AuraData?

Convenience wrapper — filters to `HELPFUL` auras only.

### C_UnitAuras.GetDebuffDataByIndex(unit, index [, filter]) → AuraData?

Convenience wrapper — filters to `HARMFUL` auras only.

### C_UnitAuras.GetPlayerAuraBySpellID(spellID) → AuraData?

Query a specific spell on the player by spell ID. Most efficient for checking a known buff/debuff.

```lua
local berserk = C_UnitAuras.GetPlayerAuraBySpellID(106951)
if berserk then
    print("Berserk active, expires in", berserk.expirationTime - GetTime())
end
```

---

## Batch Query Functions

### C_UnitAuras.GetAuraSlots(unit [, filter [, maxCount [, continuationToken]]]) → continuation, slots...

Returns aura slot IDs for iteration. Use continuation token for pagination.

```lua
local token, slot1, slot2, slot3 = C_UnitAuras.GetAuraSlots("player", "HELPFUL", 3)
while slot1 do
    local aura = C_UnitAuras.GetAuraDataBySlot("player", slot1)
    print(aura.name)
    slot1 = slot2
    slot2 = slot3
    if token then
        token, slot1, slot2, slot3 = C_UnitAuras.GetAuraSlots("player", "HELPFUL", 3, token)
    end
end
```

### C_UnitAuras.GetUnitAuraInstanceIDs(unit, filter [, maxCount [, sortType [, direction]]]) → auraInstanceIDs

Returns all aura instance IDs matching the filter. **Recommended for iteration.**

```lua
local ids = C_UnitAuras.GetUnitAuraInstanceIDs("target", "HARMFUL")
for _, id in ipairs(ids) do
    local aura = C_UnitAuras.GetAuraDataByAuraInstanceID("target", id)
    if aura then
        print(aura.name, aura.spellId)
    end
end
```

### C_UnitAuras.GetUnitAuras(unit, filter [, maxCount [, sortType [, direction]]]) → auras

Returns all AuraData tables matching the filter in one call.

```lua
local allBuffs = C_UnitAuras.GetUnitAuras("player", "HELPFUL")
for _, aura in ipairs(allBuffs) do
    print(aura.name, aura.applications)
end
```

---

## Duration & Expiration

### C_UnitAuras.GetAuraDuration(unit, auraInstanceID) → duration

Remaining duration of an aura in seconds.

### C_UnitAuras.GetAuraBaseDuration(unit, auraID [, spellID]) → duration

Base (unmodified) duration of an aura.

### C_UnitAuras.DoesAuraHaveExpirationTime(unit, auraID) → bool

Whether the aura has a finite duration. Permanent auras (e.g., paladin blessings) return `false`.

---

## Filter Functions

### C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, auraInstanceID, filterString) → bool

Checks if a specific aura would be filtered out by a filter string.

### C_UnitAuras.WantsAlteredForm(unit) → bool

Whether the unit prefers altered form display (e.g., worgen human form).

---

## Filter Strings

Filters are **space-separated** strings passed to query functions:

| Filter | Description |
|--------|-------------|
| `"HELPFUL"` | Buffs only |
| `"HARMFUL"` | Debuffs only |
| `"PLAYER"` | Only auras cast by the player |
| `"RAID"` | Only auras relevant for raid display |
| `"CANCELABLE"` | Only manually cancelable auras |
| `"NOT_CANCELABLE"` | Only non-cancelable auras |
| `"INCLUDE_NAME_PLATE_ONLY"` | Include nameplate-only auras |
| `"MAW"` | Maw-specific auras |

### Combining Filters

```lua
-- Player's own buffs
C_UnitAuras.GetUnitAuras("player", "HELPFUL PLAYER")

-- Player-applied debuffs on target
C_UnitAuras.GetUnitAuras("target", "HARMFUL PLAYER")

-- All non-cancelable buffs
C_UnitAuras.GetUnitAuras("player", "HELPFUL NOT_CANCELABLE")
```

---

## AuraData Table Structure

Every aura query function returns an `AuraData` table with these fields:

| Field | Type | Description |
|-------|------|-------------|
| `name` | `string` | Aura name |
| `icon` | `number` | Texture file data ID |
| `applications` | `number` | Stack count (0 = not stackable) |
| `dispelName` | `string?` | `"Magic"`, `"Curse"`, `"Disease"`, `"Poison"`, or `nil` |
| `duration` | `number` | Total duration in seconds (0 = permanent) |
| `expirationTime` | `number` | `GetTime()` value when aura expires |
| `isFromPlayerOrPlayerPet` | `bool` | Applied by the player or player's pet |
| `isHarmful` | `bool` | Is a debuff |
| `isHelpful` | `bool` | Is a buff |
| `isNameplateOnly` | `bool` | Only displayed on nameplates |
| `isRaid` | `bool` | Displayed in raid frames |
| `isStealable` | `bool` | Can be spellstolen/purged |
| `sourceUnit` | `UnitId?` | Who applied the aura |
| `spellId` | `number` | Spell ID |
| `points` | `table` | Effect values (e.g., absorb amount) |
| `auraInstanceID` | `number` | Unique instance ID for this aura application |
| `timeMod` | `number` | Time modifier (affects duration display) |
| `charges` | `number` | Number of charges remaining |
| `isBossAura` | `bool` | Applied by a boss |
| `nameplateShowAll` | `bool` | Show all stacks on nameplates |
| `nameplateShowPersonal` | `bool` | Show personal aura on nameplate |
| `canApplyAura` | `bool` | Player can apply this aura |
| `isMeOrMyPet` | `bool` | Same as `isFromPlayerOrPlayerPet` |

### Duration Calculations

```lua
local aura = C_UnitAuras.GetPlayerAuraBySpellID(spellID)
if aura then
    local remaining = aura.expirationTime - GetTime()
    local elapsed = aura.duration - remaining
    local progress = elapsed / aura.duration
    print(string.format("%.1fs remaining (%.0f%%)", remaining, (1 - progress) * 100))
end
```

---

## Private Auras

Private auras hide their spell data from addons. Used for encounter mechanics where knowing the aura name would spoil strategy.

### C_UnitAuras.AddPrivateAuraAnchor(args) → anchorID

Anchors a frame to display at the position of a private aura icon.

```lua
local anchorID = C_UnitAuras.AddPrivateAuraAnchor({
    unitToken = "player",
    auraIndex = 1,
    parent = UIParent,
    showCountdownFrame = true,
    showCountdownNumbers = true,
    iconInfo = {
        iconWidth = 32,
        iconHeight = 32,
        iconAnchor = {
            point = "CENTER",
            relativeTo = myFrame,
            relativePoint = "CENTER",
            offsetX = 0,
            offsetY = 0,
        },
    },
})
```

### C_UnitAuras.RemovePrivateAuraAnchor(anchorID)

Removes a previously set private aura anchor.

### C_UnitAuras.AddPrivateAuraAppliedSound(soundArgs) → soundID

Plays a sound when a private aura is applied.

```lua
local soundID = C_UnitAuras.AddPrivateAuraAppliedSound({
    unitToken = "player",
    spellID = 12345,
    soundFileName = "Sound\\Interface\\RaidWarning.ogg",
    outputChannel = "Master",
})
```

### C_UnitAuras.RemovePrivateAuraAppliedSound(soundID)

Removes a private aura sound hook.

### C_UnitAuras.AuraIsPrivate(spellID) → bool

Check if a spell ID is a private aura.

### C_UnitAuras.AuraIsBigDefensive(spellID) → bool

Check if a spell is flagged as a major defensive cooldown.

### C_UnitAuras.SetPrivateWarningTextAnchor(parent [, anchorInfo])

Sets anchor frame for private aura warning text.

### C_UnitAuras.TriggerPrivateAuraShowDispelType(show)

Toggle visibility of dispel type indicators for private auras.

---

## UNIT_AURA Event

The primary event for tracking aura changes.

### Event Signature

```
UNIT_AURA(unitTarget, updateInfo)
```

### UpdateInfo Structure

| Field | Type | Description |
|-------|------|-------------|
| `isFullUpdate` | `bool` | If true, discard cache and re-scan all auras |
| `addedAuras` | `AuraData[]?` | Auras that were newly applied |
| `updatedAuraInstanceIDs` | `number[]?` | Instance IDs of auras that were modified |
| `removedAuraInstanceIDs` | `number[]?` | Instance IDs of auras that were removed |

### Full Tracking Implementation

```lua
local auraCache = {}

local function RefreshAllAuras(unit)
    wipe(auraCache)
    local buffs = C_UnitAuras.GetUnitAuras(unit, "HELPFUL")
    for _, aura in ipairs(buffs) do
        auraCache[aura.auraInstanceID] = aura
    end
    local debuffs = C_UnitAuras.GetUnitAuras(unit, "HARMFUL")
    for _, aura in ipairs(debuffs) do
        auraCache[aura.auraInstanceID] = aura
    end
end

local frame = CreateFrame("Frame")
frame:RegisterUnitEvent("UNIT_AURA", "player")
frame:SetScript("OnEvent", function(self, event, unit, updateInfo)
    if updateInfo.isFullUpdate then
        RefreshAllAuras(unit)
        return
    end
    
    -- Handle added auras
    if updateInfo.addedAuras then
        for _, aura in ipairs(updateInfo.addedAuras) do
            auraCache[aura.auraInstanceID] = aura
        end
    end
    
    -- Handle updated auras
    if updateInfo.updatedAuraInstanceIDs then
        for _, id in ipairs(updateInfo.updatedAuraInstanceIDs) do
            local aura = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, id)
            if aura then
                auraCache[id] = aura
            end
        end
    end
    
    -- Handle removed auras
    if updateInfo.removedAuraInstanceIDs then
        for _, id in ipairs(updateInfo.removedAuraInstanceIDs) do
            auraCache[id] = nil
        end
    end
end)
```

---

## Aura Tooltip Display

```lua
-- Show aura tooltip on hover
local function SetAuraTooltip(button, unit, auraInstanceID)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
        GameTooltip:SetUnitAura(unit, auraInstanceID)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end
```

---

## Common Aura Patterns

### Check for Specific Buff

```lua
local function HasBuff(unit, spellID)
    if UnitIsUnit(unit, "player") then
        return C_UnitAuras.GetPlayerAuraBySpellID(spellID) ~= nil
    end
    local auras = C_UnitAuras.GetUnitAuras(unit, "HELPFUL")
    for _, aura in ipairs(auras) do
        if aura.spellId == spellID then
            return true
        end
    end
    return false
end
```

### Count Debuffs by Dispel Type

```lua
local function CountDispelType(unit, dispelType)
    local count = 0
    local debuffs = C_UnitAuras.GetUnitAuras(unit, "HARMFUL")
    for _, aura in ipairs(debuffs) do
        if aura.dispelName == dispelType then
            count = count + 1
        end
    end
    return count
end

local magicCount = CountDispelType("player", "Magic")
```

### Get Remaining Duration

```lua
local function GetRemainingDuration(unit, spellID)
    local aura = C_UnitAuras.GetPlayerAuraBySpellID(spellID)
    if aura and aura.expirationTime > 0 then
        return aura.expirationTime - GetTime()
    end
    return 0
end
```

---

## Related Events

| Event | Payload | Description |
|-------|---------|-------------|
| `UNIT_AURA` | `unitTarget, updateInfo` | Any aura change on a unit |

> **Source:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#UnitAuras
