# Frame Specialized — Tooltips, Minimap, Movies, Map Overlays & Intrinsics

These Frame subtypes provide specialized UI functionality: tooltips, the minimap, movie playback, fog of war, unit positions on maps, blob overlays, and intrinsic frame types.

> **Source:** https://warcraft.wiki.gg/wiki/Widget_API#Frames
> **Current as of:** Patch 11.2.7 (Build 64743) — December 3, 2025

---

## GameTooltip

Inherits from **Frame**. The primary tooltip widget. Since Patch 10.0.2, addons creating GameTooltip frames should inherit `GameTooltipTemplate` for automatic `TOOLTIP_DATA_UPDATE` event handling and `C_TooltipInfo` integration.

> **Reference:** https://warcraft.wiki.gg/wiki/UIOBJECT_GameTooltip
> **Widget API:** https://warcraft.wiki.gg/wiki/Widget_API#GameTooltip
> **Important:** See also [C_TooltipInfo](https://warcraft.wiki.gg/wiki/Category:API_systems/TooltipInfo) and [GameTooltipTemplate](https://warcraft.wiki.gg/wiki/GameTooltipTemplate).

### Content Management

| Method | Signature | Description |
|--------|-----------|-------------|
| AddLine | `GameTooltip:AddLine(tooltipText [, r, g, b, wrapText])` | Adds a line of text to the tooltip. |
| AddDoubleLine | `GameTooltip:AddDoubleLine(leftText, rightText [, leftR, leftG, leftB [, rightR, rightG, rightB]])` | Adds a double-columned line. |
| AddTexture | `GameTooltip:AddTexture(texture)` | Adds a texture to the tooltip. |
| AddAtlas | `GameTooltip:AddAtlas(atlas)` | Adds an atlas texture. |
| AppendText | `GameTooltip:AppendText(text)` | Appends text to the last line. |
| SetText | `GameTooltip:SetText(text [, r, g, b, alpha, textWrap])` | Sets the tooltip text (replaces all lines). |
| ClearLines | `GameTooltip:ClearLines()` | Removes all lines from the tooltip. |
| NumLines | `GameTooltip:NumLines() : lines` | Returns the number of lines. |

### Owner and Positioning

| Method | Signature | Description |
|--------|-----------|-------------|
| SetOwner | `GameTooltip:SetOwner(owner, anchor [, ofsX, ofsY])` | Sets the tooltip owner and anchor point. |
| GetOwner | `GameTooltip:GetOwner() : owner` | Returns the tooltip's owner frame. |
| FadeOut | `GameTooltip:FadeOut()` | Fades the tooltip out. |
| SetPadding | `GameTooltip:SetPadding(right, bottom [, left, top])` | Sets padding around the tooltip content. |
| GetPadding | `GameTooltip:GetPadding() : right, bottom, left, top` | Returns the padding. |

### Debug

| Method | Signature | Description |
|--------|-----------|-------------|
| SetFrameStack | `GameTooltip:SetFrameStack([showHidden, showRegion, highlightIndexChanged])` | Displays the frame stack in the tooltip. |

### Data Setter Methods (via GameTooltipDataMixin / C_TooltipInfo)

When inheriting `GameTooltipTemplate`, these data setters populate the tooltip from game data. They dispatch through `C_TooltipInfo` internally.

| Method | Signature | Description |
|--------|-----------|-------------|
| SetAction | `GameTooltip:SetAction(actionID)` | Shows tooltip for an action bar slot. |
| SetBagItem | `GameTooltip:SetBagItem(bagIndex, slotIndex)` | Shows tooltip for a bag item. |
| SetCurrencyToken | `GameTooltip:SetCurrencyToken(tokenIndex)` | Shows tooltip for a currency. |
| SetHyperlink | `GameTooltip:SetHyperlink(hyperlink [, optionalArg1, optionalArg2, hideVendorPrice])` | Shows tooltip for a hyperlink. |
| SetInboxItem | `GameTooltip:SetInboxItem(messageIndex [, attachmentIndex])` | Shows tooltip for a mail item. |
| SetInventoryItem | `GameTooltip:SetInventoryItem(unit, slot [, hideUselessStats])` | Shows tooltip for an equipped item. |
| SetItemKey | `GameTooltip:SetItemKey(itemID, itemLevel, itemSuffix [, requiredLevel])` | Shows tooltip for an item key. |
| SetLootItem | `GameTooltip:SetLootItem(slot)` | Shows tooltip for a loot item. |
| SetSpellBookItem | `GameTooltip:SetSpellBookItem(index, spellBank)` | Shows tooltip for a spell book entry. |
| SetTalent | `GameTooltip:SetTalent(talentID [, isInspect, groupIndex])` | Shows tooltip for a talent. |
| SetUnit | `GameTooltip:SetUnit(unit [, hideStatus])` | Shows tooltip for a unit. |
| SetUnitAura | `GameTooltip:SetUnitAura(unitToken, index [, filter])` | Shows tooltip for a unit's aura. |
| SetUnitBuff | `GameTooltip:SetUnitBuff(unitToken, index [, filter])` | Shows tooltip for a unit's buff. |
| SetUnitDebuff | `GameTooltip:SetUnitDebuff(unitToken, index [, filter])` | Shows tooltip for a unit's debuff. |
| SetTransmogrifyItem | `GameTooltip:SetTransmogrifyItem(transmogLocation)` | Shows tooltip for a transmogrification item. |
| SetUpgradeItem | `GameTooltip:SetUpgradeItem()` | Shows tooltip for an upgrade item. |

> **Note:** Many additional `Set*` methods exist for specialized tooltip data (achievements, azerite, companions, conduits, currencies, equipment sets, guild bank items, heirlooms, mounts, pet actions, pvp talents, recipes, rune forging, toys, traits, etc.). See the full list at https://warcraft.wiki.gg/wiki/Widget_API#GameTooltip.

### Individual Method References
- `AddLine` — https://warcraft.wiki.gg/wiki/API_GameTooltip_AddLine
- `AddDoubleLine` — https://warcraft.wiki.gg/wiki/API_GameTooltip_AddDoubleLine
- `AddTexture` — https://warcraft.wiki.gg/wiki/API_GameTooltip_AddTexture
- `AddAtlas` — https://warcraft.wiki.gg/wiki/API_GameTooltip_AddAtlas
- `AppendText` — https://warcraft.wiki.gg/wiki/API_GameTooltip_AppendText
- `SetText` — https://warcraft.wiki.gg/wiki/API_GameTooltip_SetText
- `ClearLines` — https://warcraft.wiki.gg/wiki/API_GameTooltip_ClearLines
- `NumLines` — https://warcraft.wiki.gg/wiki/API_GameTooltip_NumLines
- `SetOwner` — https://warcraft.wiki.gg/wiki/API_GameTooltip_SetOwner
- `GetOwner` — https://warcraft.wiki.gg/wiki/API_GameTooltip_GetOwner
- `FadeOut` — https://warcraft.wiki.gg/wiki/API_GameTooltip_FadeOut
- `SetPadding` — https://warcraft.wiki.gg/wiki/API_GameTooltip_SetPadding
- `GetPadding` — https://warcraft.wiki.gg/wiki/API_GameTooltip_GetPadding
- `SetFrameStack` — https://warcraft.wiki.gg/wiki/API_GameTooltip_SetFrameStack
- `SetAction` — https://warcraft.wiki.gg/wiki/API_GameTooltip_SetAction
- `SetBagItem` — https://warcraft.wiki.gg/wiki/API_GameTooltip_SetBagItem
- `SetHyperlink` — https://warcraft.wiki.gg/wiki/API_GameTooltip_SetHyperlink
- `SetInventoryItem` — https://warcraft.wiki.gg/wiki/API_GameTooltip_SetInventoryItem
- `SetUnit` — https://warcraft.wiki.gg/wiki/API_GameTooltip_SetUnit
- `SetUnitAura` — https://warcraft.wiki.gg/wiki/API_GameTooltip_SetUnitAura
- `SetUnitBuff` — https://warcraft.wiki.gg/wiki/API_GameTooltip_SetUnitBuff
- `SetUnitDebuff` — https://warcraft.wiki.gg/wiki/API_GameTooltip_SetUnitDebuff
- `SetSpellBookItem` — https://warcraft.wiki.gg/wiki/API_GameTooltip_SetSpellBookItem

---

## Minimap

Inherits from **Frame**. The in-game minimap widget. There is only one Minimap object — it cannot be created by addons.

> **Reference:** https://warcraft.wiki.gg/wiki/UIOBJECT_Minimap
> **Widget API:** https://warcraft.wiki.gg/wiki/Widget_API#Minimap

### Zoom

| Method | Signature | Description |
|--------|-----------|-------------|
| SetZoom | `Minimap:SetZoom(zoomFactor)` | Sets the current zoom level. |
| GetZoom | `Minimap:GetZoom() : zoomFactor` | Returns the current zoom level. |
| GetZoomLevels | `Minimap:GetZoomLevels() : zoomLevels` | Returns the maximum zoom level. |

### Ping

| Method | Signature | Description |
|--------|-----------|-------------|
| PingLocation | `Minimap:PingLocation([locationX, locationY])` | Performs a ping at the specified location. |
| GetPingPosition | `Minimap:GetPingPosition() : positionX, positionY` | Returns the last ping position. |

### Textures

| Method | Signature | Description |
|--------|-----------|-------------|
| SetBlipTexture | `Minimap:SetBlipTexture(asset)` | Sets the file used for blips (ObjectIcons). |
| SetIconTexture | `Minimap:SetIconTexture(asset)` | Sets the icon texture. |
| SetMaskTexture | `Minimap:SetMaskTexture(asset)` | Sets the mask texture. |
| SetPlayerTexture | `Minimap:SetPlayerTexture(asset)` | Sets the player arrow texture. |
| SetCorpsePOIArrowTexture | `Minimap:SetCorpsePOIArrowTexture(asset)` | Sets the corpse POI arrow texture. |
| SetPOIArrowTexture | `Minimap:SetPOIArrowTexture(asset)` | Sets the POI arrow texture. |
| SetStaticPOIArrowTexture | `Minimap:SetStaticPOIArrowTexture(asset)` | Sets the static POI arrow texture. |
| UpdateBlips | `Minimap:UpdateBlips()` | Updates the minimap blips. |

### Quest Blob Textures

| Method | Signature | Description |
|--------|-----------|-------------|
| SetQuestBlobInsideTexture | `Minimap:SetQuestBlobInsideTexture(asset)` | Sets the inside texture for quest blobs. |
| SetQuestBlobInsideAlpha | `Minimap:SetQuestBlobInsideAlpha(alpha)` | Sets the inside alpha. |
| SetQuestBlobOutsideTexture | `Minimap:SetQuestBlobOutsideTexture(asset)` | Sets the outside texture. |
| SetQuestBlobOutsideAlpha | `Minimap:SetQuestBlobOutsideAlpha(alpha)` | Sets the outside alpha. |
| SetQuestBlobRingTexture | `Minimap:SetQuestBlobRingTexture(asset)` | Sets the ring texture. |
| SetQuestBlobRingAlpha | `Minimap:SetQuestBlobRingAlpha(alpha)` | Sets the ring alpha. |
| SetQuestBlobRingScalar | `Minimap:SetQuestBlobRingScalar(scalar)` | Sets the ring scalar. |

### Task Blob Textures

| Method | Signature | Description |
|--------|-----------|-------------|
| SetTaskBlobInsideTexture | `Minimap:SetTaskBlobInsideTexture(asset)` | Sets the inside texture for task blobs. |
| SetTaskBlobInsideAlpha | `Minimap:SetTaskBlobInsideAlpha(alpha)` | Sets the inside alpha. |
| SetTaskBlobOutsideTexture | `Minimap:SetTaskBlobOutsideTexture(asset)` | Sets the outside texture. |
| SetTaskBlobOutsideAlpha | `Minimap:SetTaskBlobOutsideAlpha(alpha)` | Sets the outside alpha. |
| SetTaskBlobRingTexture | `Minimap:SetTaskBlobRingTexture(asset)` | Sets the ring texture. |
| SetTaskBlobRingAlpha | `Minimap:SetTaskBlobRingAlpha(alpha)` | Sets the ring alpha. |
| SetTaskBlobRingScalar | `Minimap:SetTaskBlobRingScalar(scalar)` | Sets the ring scalar. |

### Archaeology Blob Textures

| Method | Signature | Description |
|--------|-----------|-------------|
| SetArchBlobInsideTexture | `Minimap:SetArchBlobInsideTexture(asset)` | Sets the inside texture for archaeology blobs. |
| SetArchBlobInsideAlpha | `Minimap:SetArchBlobInsideAlpha(alpha)` | Sets the inside alpha. |
| SetArchBlobOutsideTexture | `Minimap:SetArchBlobOutsideTexture(asset)` | Sets the outside texture. |
| SetArchBlobOutsideAlpha | `Minimap:SetArchBlobOutsideAlpha(alpha)` | Sets the outside alpha. |
| SetArchBlobRingTexture | `Minimap:SetArchBlobRingTexture(asset)` | Sets the ring texture. |
| SetArchBlobRingAlpha | `Minimap:SetArchBlobRingAlpha(alpha)` | Sets the ring alpha. |
| SetArchBlobRingScalar | `Minimap:SetArchBlobRingScalar(scalar)` | Sets the ring scalar. |

### Individual Method References
- `SetZoom` — https://warcraft.wiki.gg/wiki/API_Minimap_SetZoom
- `GetZoom` — https://warcraft.wiki.gg/wiki/API_Minimap_GetZoom
- `GetZoomLevels` — https://warcraft.wiki.gg/wiki/API_Minimap_GetZoomLevels
- `PingLocation` — https://warcraft.wiki.gg/wiki/API_Minimap_PingLocation
- `GetPingPosition` — https://warcraft.wiki.gg/wiki/API_Minimap_GetPingPosition
- `SetBlipTexture` — https://warcraft.wiki.gg/wiki/API_Minimap_SetBlipTexture
- `SetPlayerTexture` — https://warcraft.wiki.gg/wiki/API_Minimap_SetPlayerTexture
- `SetMaskTexture` — https://warcraft.wiki.gg/wiki/API_Minimap_SetMaskTexture
- `SetIconTexture` — https://warcraft.wiki.gg/wiki/API_Minimap_SetIconTexture
- `UpdateBlips` — https://warcraft.wiki.gg/wiki/API_Minimap_UpdateBlips

---

## MovieFrame

Inherits from **Frame**. Plays in-game cinematic movies. Created via `CreateFrame("MovieFrame", ...)`.

> **Reference:** https://warcraft.wiki.gg/wiki/UIOBJECT_MovieFrame
> **Widget API:** https://warcraft.wiki.gg/wiki/Widget_API#MovieFrame

| Method | Signature | Description |
|--------|-----------|-------------|
| StartMovie | `MovieFrame:StartMovie(movieID [, looping]) : success, returnCode` | Starts playing a movie by ID. |
| StartMovieByName | `MovieFrame:StartMovieByName(movieName [, looping, resolution]) : success, returnCode` | **Deprecated.** Does nothing. |
| StopMovie | `MovieFrame:StopMovie()` | Stops the currently playing movie. |
| EnableSubtitles | `MovieFrame:EnableSubtitles(enable)` | Enables or disables subtitles. |

### Individual Method References
- `StartMovie` — https://warcraft.wiki.gg/wiki/API_MovieFrame_StartMovie
- `StartMovieByName` — https://warcraft.wiki.gg/wiki/API_MovieFrame_StartMovieByName
- `StopMovie` — https://warcraft.wiki.gg/wiki/API_MovieFrame_StopMovie
- `EnableSubtitles` — https://warcraft.wiki.gg/wiki/API_MovieFrame_EnableSubtitles

---

## FogOfWarFrame

Inherits from **Frame**. Renders a fog of war overlay on a map. Not created by addons — used internally by the world map.

> **Widget API:** https://warcraft.wiki.gg/wiki/Widget_API#FogOfWarFrame

| Method | Signature | Description |
|--------|-----------|-------------|
| SetUiMapID | `FogOfWarFrame:SetUiMapID(uiMapID)` | Sets the map ID. |
| GetUiMapID | `FogOfWarFrame:GetUiMapID() : uiMapID` | Returns the map ID. |
| SetFogOfWarBackgroundTexture | `FogOfWarFrame:SetFogOfWarBackgroundTexture(asset, horizontalTile, verticalTile)` | Sets the fog background texture. |
| GetFogOfWarBackgroundTexture | `FogOfWarFrame:GetFogOfWarBackgroundTexture() : asset` | Returns the background texture. |
| SetFogOfWarBackgroundAtlas | `FogOfWarFrame:SetFogOfWarBackgroundAtlas(atlas)` | Sets the fog background atlas. |
| GetFogOfWarBackgroundAtlas | `FogOfWarFrame:GetFogOfWarBackgroundAtlas() : atlas` | Returns the background atlas. |
| SetFogOfWarMaskTexture | `FogOfWarFrame:SetFogOfWarMaskTexture(asset)` | Sets the fog mask texture. |
| GetFogOfWarMaskTexture | `FogOfWarFrame:GetFogOfWarMaskTexture() : asset` | Returns the mask texture. |
| SetFogOfWarMaskAtlas | `FogOfWarFrame:SetFogOfWarMaskAtlas(atlas)` | Sets the fog mask atlas. |
| GetFogOfWarMaskAtlas | `FogOfWarFrame:GetFogOfWarMaskAtlas() : atlas` | Returns the mask atlas. |
| SetMaskScalar | `FogOfWarFrame:SetMaskScalar(scalar)` | Sets the mask scalar. |
| GetMaskScalar | `FogOfWarFrame:GetMaskScalar() : scalar` | Returns the mask scalar. |

### Individual Method References
- `SetUiMapID` — https://warcraft.wiki.gg/wiki/API_FogOfWarFrame_SetUiMapID
- `GetUiMapID` — https://warcraft.wiki.gg/wiki/API_FogOfWarFrame_GetUiMapID
- `SetFogOfWarBackgroundTexture` — https://warcraft.wiki.gg/wiki/API_FogOfWarFrame_SetFogOfWarBackgroundTexture
- `GetFogOfWarBackgroundTexture` — https://warcraft.wiki.gg/wiki/API_FogOfWarFrame_GetFogOfWarBackgroundTexture
- `SetFogOfWarBackgroundAtlas` — https://warcraft.wiki.gg/wiki/API_FogOfWarFrame_SetFogOfWarBackgroundAtlas
- `SetFogOfWarMaskTexture` — https://warcraft.wiki.gg/wiki/API_FogOfWarFrame_SetFogOfWarMaskTexture
- `SetFogOfWarMaskAtlas` — https://warcraft.wiki.gg/wiki/API_FogOfWarFrame_SetFogOfWarMaskAtlas
- `SetMaskScalar` — https://warcraft.wiki.gg/wiki/API_FogOfWarFrame_SetMaskScalar

---

## UnitPositionFrame

Inherits from **Frame**. Displays unit positions on a map. Used internally by the world map.

> **Widget API:** https://warcraft.wiki.gg/wiki/Widget_API#UnitPositionFrame

| Method | Signature | Description |
|--------|-----------|-------------|
| AddUnit | `UnitPositionFrame:AddUnit(unitTokenString, asset [, width, height, r, g, b, a, sublayer, showFacing])` | Adds a unit to the frame. |
| ClearUnits | `UnitPositionFrame:ClearUnits()` | Removes all units. |
| FinalizeUnits | `UnitPositionFrame:FinalizeUnits()` | Finalizes the unit list. |
| SetUiMapID | `UnitPositionFrame:SetUiMapID(mapID)` | Sets the map ID. |
| GetUiMapID | `UnitPositionFrame:GetUiMapID() : mapID` | Returns the map ID. |
| SetUnitColor | `UnitPositionFrame:SetUnitColor(unit, colorR, colorG, colorB, colorA)` | Sets a unit's display color. |
| GetMouseOverUnits | `UnitPositionFrame:GetMouseOverUnits() : units, ...` | Returns units under the mouse. |
| SetPlayerPingTexture | `UnitPositionFrame:SetPlayerPingTexture(textureType, asset [, width, height])` | Sets the player ping texture. |
| SetPlayerPingScale | `UnitPositionFrame:SetPlayerPingScale(scale)` | Sets the player ping scale. |
| GetPlayerPingScale | `UnitPositionFrame:GetPlayerPingScale() : scale` | Returns the ping scale. |
| StartPlayerPing | `UnitPositionFrame:StartPlayerPing([duration, fadeDuration])` | Starts a player ping animation. |
| StopPlayerPing | `UnitPositionFrame:StopPlayerPing()` | Stops the player ping. |

### Individual Method References
- `AddUnit` — https://warcraft.wiki.gg/wiki/API_UnitPositionFrame_AddUnit
- `ClearUnits` — https://warcraft.wiki.gg/wiki/API_UnitPositionFrame_ClearUnits
- `FinalizeUnits` — https://warcraft.wiki.gg/wiki/API_UnitPositionFrame_FinalizeUnits
- `SetUiMapID` — https://warcraft.wiki.gg/wiki/API_UnitPositionFrame_SetUiMapID
- `GetUiMapID` — https://warcraft.wiki.gg/wiki/API_UnitPositionFrame_GetUiMapID
- `SetUnitColor` — https://warcraft.wiki.gg/wiki/API_UnitPositionFrame_SetUnitColor
- `GetMouseOverUnits` — https://warcraft.wiki.gg/wiki/API_UnitPositionFrame_GetMouseOverUnits
- `SetPlayerPingTexture` — https://warcraft.wiki.gg/wiki/API_UnitPositionFrame_SetPlayerPingTexture
- `StartPlayerPing` — https://warcraft.wiki.gg/wiki/API_UnitPositionFrame_StartPlayerPing
- `StopPlayerPing` — https://warcraft.wiki.gg/wiki/API_UnitPositionFrame_StopPlayerPing

---

## Blob

Inherits from **Frame**. Renders colored blob overlays on a map (quest areas, archaeology dig sites, etc.). Base type for `ArchaeologyDigSiteFrame`, `QuestPOIFrame`, and `ScenarioPOIFrame`.

> **Widget API:** https://warcraft.wiki.gg/wiki/Widget_API#Blob

| Method | Signature | Description |
|--------|-----------|-------------|
| DrawBlob | `Blob:DrawBlob(questID [, draw])` | Draws or hides a blob for a specific quest. |
| DrawAll | `Blob:DrawAll()` | Draws all blobs. |
| DrawNone | `Blob:DrawNone()` | Hides all blobs. |
| EnableMerging | `Blob:EnableMerging([enable])` | Enables or disables blob merging. |
| EnableSmoothing | `Blob:EnableSmoothing([enable])` | Enables or disables edge smoothing. |
| SetMapID | `Blob:SetMapID(uiMapID)` | Sets the map ID. |
| GetMapID | `Blob:GetMapID() : uiMapID` | Returns the map ID. |
| SetBorderTexture | `Blob:SetBorderTexture(asset)` | Sets the border texture. |
| SetBorderAlpha | `Blob:SetBorderAlpha(alpha)` | Sets the border alpha. |
| SetBorderScalar | `Blob:SetBorderScalar(scalar)` | Sets the border scalar. |
| SetFillTexture | `Blob:SetFillTexture(asset)` | Sets the fill texture. |
| SetFillAlpha | `Blob:SetFillAlpha(alpha)` | Sets the fill alpha. |
| SetMergeThreshold | `Blob:SetMergeThreshold(threshold)` | Sets the merge threshold. |
| SetNumSplinePoints | `Blob:SetNumSplinePoints(numSplinePoints)` | Sets the number of spline points. |

### Individual Method References
- `DrawBlob` — https://warcraft.wiki.gg/wiki/API_Blob_DrawBlob
- `DrawAll` — https://warcraft.wiki.gg/wiki/API_Blob_DrawAll
- `DrawNone` — https://warcraft.wiki.gg/wiki/API_Blob_DrawNone
- `EnableMerging` — https://warcraft.wiki.gg/wiki/API_Blob_EnableMerging
- `EnableSmoothing` — https://warcraft.wiki.gg/wiki/API_Blob_EnableSmoothing
- `SetMapID` — https://warcraft.wiki.gg/wiki/API_Blob_SetMapID
- `GetMapID` — https://warcraft.wiki.gg/wiki/API_Blob_GetMapID
- `SetBorderTexture` — https://warcraft.wiki.gg/wiki/API_Blob_SetBorderTexture
- `SetFillTexture` — https://warcraft.wiki.gg/wiki/API_Blob_SetFillTexture

---

## ArchaeologyDigSiteFrame

Inherits all methods from **Blob**. No additional methods. Used to display archaeology dig site areas on the map.

> **Widget API:** https://warcraft.wiki.gg/wiki/Widget_API#ArchaeologyDigSiteFrame

---

## QuestPOIFrame

Inherits from **Blob**. Adds quest-specific tooltip methods for points of interest on the map.

> **Widget API:** https://warcraft.wiki.gg/wiki/Widget_API#QuestPOIFrame

| Method | Signature | Description |
|--------|-----------|-------------|
| GetNumTooltips | `QuestPOIFrame:GetNumTooltips() : numObjectives` | Returns the number of tooltip objectives. |
| GetTooltipIndex | `QuestPOIFrame:GetTooltipIndex(index) : objectiveIndex` | Returns the objective index for a tooltip entry. |
| UpdateMouseOverTooltip | `QuestPOIFrame:UpdateMouseOverTooltip(x, y) : questID, numObjectives` | Updates the tooltip based on mouse position. |

### Individual Method References
- `GetNumTooltips` — https://warcraft.wiki.gg/wiki/API_QuestPOIFrame_GetNumTooltips
- `GetTooltipIndex` — https://warcraft.wiki.gg/wiki/API_QuestPOIFrame_GetTooltipIndex
- `UpdateMouseOverTooltip` — https://warcraft.wiki.gg/wiki/API_QuestPOIFrame_UpdateMouseOverTooltip

---

## ScenarioPOIFrame

Inherits from **Blob**. Adds scenario-specific tooltip methods.

> **Widget API:** https://warcraft.wiki.gg/wiki/Widget_API#ScenarioPOIFrame

| Method | Signature | Description |
|--------|-----------|-------------|
| GetScenarioTooltipText | `ScenarioPOIFrame:GetScenarioTooltipText() : tooltipText` | Returns the scenario tooltip text. |
| UpdateMouseOverTooltip | `ScenarioPOIFrame:UpdateMouseOverTooltip(x, y) : hasTooltip` | Updates the tooltip based on mouse position. |

### Individual Method References
- `GetScenarioTooltipText` — https://warcraft.wiki.gg/wiki/API_ScenarioPOIFrame_GetScenarioTooltipText
- `UpdateMouseOverTooltip` — https://warcraft.wiki.gg/wiki/API_ScenarioPOIFrame_UpdateMouseOverTooltip

---

## Intrinsics

Intrinsic frames are special widget types that combine a core frame type with a mixin, providing extended functionality through both widget methods and mixin methods.

> **Reference:** https://warcraft.wiki.gg/wiki/Intrinsic_frame
> **Widget API:** https://warcraft.wiki.gg/wiki/Widget_API#Intrinsics

### ItemButton

An [intrinsic frame](https://warcraft.wiki.gg/wiki/Intrinsic_frame) that combines **Button** with [ItemButtonMixin](https://www.townlong-yak.com/framexml/go/ItemButtonMixin). Provides all Button methods plus the mixin's item management functionality.

> No additional widget methods — all extended behavior comes from `ItemButtonMixin`.

### ScrollingMessageFrame

An [intrinsic frame](https://warcraft.wiki.gg/wiki/Intrinsic_frame) that combines **Frame** + **FontInstance** with [ScrollingMessageFrameMixin](https://www.townlong-yak.com/framexml/go/ScrollingMessageFrameMixin). Provides a scrollable chat-like message display with message history, scrolling controls, and message filtering — used by the chat frames.

> No additional widget methods — all extended behavior comes from `ScrollingMessageFrameMixin`.
