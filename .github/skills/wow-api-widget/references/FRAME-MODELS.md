# Frame Models — 3D Model Widget Types

These Frame subtypes handle 3D model rendering: displaying creatures, players, items, tabards, and full 3D scenes with actors.

> **Source:** https://warcraft.wiki.gg/wiki/Widget_API#Frames
> **Current as of:** Patch 11.2.7 (Build 64743) — December 3, 2025

---

## Model

Inherits from **Frame**. Displays a 3D model with camera, lighting, fog, and animation controls. Created via `CreateFrame("Model", ...)`.

> **Reference:** https://warcraft.wiki.gg/wiki/UIOBJECT_Model
> **Widget API:** https://warcraft.wiki.gg/wiki/Widget_API#Model

### Model Loading

| Method | Signature | Description |
|--------|-----------|-------------|
| SetModel | `Model:SetModel(asset [, noMip])` | Sets the model to display a certain mesh. |
| ClearModel | `Model:ClearModel()` | Clears the currently displayed model. |
| GetModelFileID | `Model:GetModelFileID() : modelFileID` | Returns the file ID associated with the currently displayed model. |
| ReplaceIconTexture | `Model:ReplaceIconTexture(asset)` | Replaces the icon texture. |
| HasAttachmentPoints | `Model:HasAttachmentPoints() : hasAttachmentPoints` | Returns whether the model has attachment points. |

### Camera

| Method | Signature | Description |
|--------|-----------|-------------|
| SetCamera | `Model:SetCamera(cameraIndex)` | Selects a predefined camera. |
| SetCustomCamera | `Model:SetCustomCamera(cameraIndex)` | Sets a custom camera index. |
| MakeCurrentCameraCustom | `Model:MakeCurrentCameraCustom()` | Converts the current camera to a custom camera. |
| HasCustomCamera | `Model:HasCustomCamera() : hasCustomCamera` | Returns whether a custom camera is set. |
| SetCameraPosition | `Model:SetCameraPosition(positionX, positionY, positionZ)` | Sets the camera position. |
| GetCameraPosition | `Model:GetCameraPosition() : positionX, positionY, positionZ` | Returns the camera position. |
| SetCameraTarget | `Model:SetCameraTarget(targetX, targetY, targetZ)` | Sets the camera look-at target. |
| GetCameraTarget | `Model:GetCameraTarget() : targetX, targetY, targetZ` | Returns the camera target. |
| SetCameraDistance | `Model:SetCameraDistance(distance)` | Sets the camera distance. |
| GetCameraDistance | `Model:GetCameraDistance() : distance` | Returns the camera distance. |
| SetCameraFacing | `Model:SetCameraFacing(radians)` | Sets the camera facing angle. |
| GetCameraFacing | `Model:GetCameraFacing() : radians` | Returns the camera facing angle. |
| SetCameraRoll | `Model:SetCameraRoll(radians)` | Sets the camera roll. |
| GetCameraRoll | `Model:GetCameraRoll() : radians` | Returns the camera roll. |

### Position and Orientation

| Method | Signature | Description |
|--------|-----------|-------------|
| SetPosition | `Model:SetPosition(positionX, positionY, positionZ)` | Positions a model relative to the bottom-left corner. |
| GetPosition | `Model:GetPosition() : positionX, positionY, positionZ` | Returns the model position. |
| SetFacing | `Model:SetFacing(facing)` | Rotates the displayed model counter-clockwise. |
| GetFacing | `Model:GetFacing() : facing` | Returns the rotation angle offset. |
| SetPitch | `Model:SetPitch(pitch)` | Sets the model pitch. |
| GetPitch | `Model:GetPitch() : pitch` | Returns the pitch. |
| SetRoll | `Model:SetRoll(roll)` | Sets the model roll. |
| GetRoll | `Model:GetRoll() : roll` | Returns the roll. |
| SetModelScale | `Model:SetModelScale(scale)` | Sets the model scale. |
| GetModelScale | `Model:GetModelScale() : scale` | Returns the model scale. |
| GetWorldScale | `Model:GetWorldScale() : worldScale` | Returns the world scale. |
| SetTransform | `Model:SetTransform([translation, rotation, scale])` | Sets a combined transform. |
| ClearTransform | `Model:ClearTransform()` | Clears the transform. |
| UseModelCenterToTransform | `Model:UseModelCenterToTransform(useCenter)` | Sets whether the model center is used for transforms. |
| IsUsingModelCenterToTransform | `Model:IsUsingModelCenterToTransform() : useCenter` | Returns whether model center is used. |
| TransformCameraSpaceToModelSpace | `Model:TransformCameraSpaceToModelSpace(cameraPosition) : modelPosition` | Converts camera-space to model-space coordinates. |

### Appearance

| Method | Signature | Description |
|--------|-----------|-------------|
| SetModelAlpha | `Model:SetModelAlpha(alpha)` | Sets the model alpha. |
| GetModelAlpha | `Model:GetModelAlpha() : alpha` | Returns the model alpha. |
| SetModelDrawLayer | `Model:SetModelDrawLayer(layer)` | Sets the model draw layer. |
| GetModelDrawLayer | `Model:GetModelDrawLayer() : layer, sublayer` | Returns the model draw layer. |
| SetDesaturation | `Model:SetDesaturation(strength)` | Sets desaturation. |
| GetDesaturation | `Model:GetDesaturation() : strength` | Returns desaturation. |
| SetShadowEffect | `Model:SetShadowEffect(strength)` | Sets shadow effect strength. |
| GetShadowEffect | `Model:GetShadowEffect() : strength` | Returns shadow effect strength. |
| SetGlow | `Model:SetGlow(glow)` | Sets the glow factor. |
| SetGradientMask | `Model:SetGradientMask(grad0, grad1, grad2, grad3)` | Sets a gradient mask. |
| SetParticlesEnabled | `Model:SetParticlesEnabled(enabled)` | Enables or disables particles. |

### Fog

| Method | Signature | Description |
|--------|-----------|-------------|
| SetFogColor | `Model:SetFogColor(colorR, colorG, colorB [, a])` | Sets the fog color. |
| GetFogColor | `Model:GetFogColor() : colorR, colorG, colorB, colorA` | Returns the fog color. |
| SetFogNear | `Model:SetFogNear(fogNear)` | Sets the fog near clipping plane. |
| GetFogNear | `Model:GetFogNear() : fogNear` | Returns the fog near value. |
| SetFogFar | `Model:SetFogFar(fogFar)` | Sets the fog far clipping plane. |
| GetFogFar | `Model:GetFogFar() : fogFar` | Returns the fog far value. |
| ClearFog | `Model:ClearFog()` | Clears all fog settings. |

### Lighting

| Method | Signature | Description |
|--------|-----------|-------------|
| SetLight | `Model:SetLight(enabled, light)` | Specifies model lighting. |
| GetLight | `Model:GetLight() : enabled, light` | Returns the light settings. |

### Animation and Playback

| Method | Signature | Description |
|--------|-----------|-------------|
| SetSequence | `Model:SetSequence(sequence)` | Sets the animation sequence to play. |
| SetSequenceTime | `Model:SetSequenceTime(sequence, timeOffset)` | Sets a specific time in an animation. |
| AdvanceTime | `Model:AdvanceTime()` | Advances the animation time. |
| SetPaused | `Model:SetPaused(paused)` | Pauses or resumes the model animation. |
| GetPaused | `Model:GetPaused() : paused` | Returns whether paused. |

### View

| Method | Signature | Description |
|--------|-----------|-------------|
| SetViewTranslation | `Model:SetViewTranslation(x, y)` | Sets the view translation offset. |
| GetViewTranslation | `Model:GetViewTranslation() : x, y` | Returns the view translation. |
| SetViewInsets | `Model:SetViewInsets(left, right, top, bottom)` | Sets the view insets. |
| GetViewInsets | `Model:GetViewInsets() : left, right, top, bottom` | Returns the view insets. |

### Individual Method References
- `SetModel` — https://warcraft.wiki.gg/wiki/API_Model_SetModel
- `ClearModel` — https://warcraft.wiki.gg/wiki/API_Model_ClearModel
- `GetModelFileID` — https://warcraft.wiki.gg/wiki/API_Model_GetModelFileID
- `SetCamera` — https://warcraft.wiki.gg/wiki/API_Model_SetCamera
- `SetCameraPosition` — https://warcraft.wiki.gg/wiki/API_Model_SetCameraPosition
- `GetCameraPosition` — https://warcraft.wiki.gg/wiki/API_Model_GetCameraPosition
- `SetCameraTarget` — https://warcraft.wiki.gg/wiki/API_Model_SetCameraTarget
- `GetCameraTarget` — https://warcraft.wiki.gg/wiki/API_Model_GetCameraTarget
- `SetCameraDistance` — https://warcraft.wiki.gg/wiki/API_Model_SetCameraDistance
- `SetCameraFacing` — https://warcraft.wiki.gg/wiki/API_Model_SetCameraFacing
- `SetCameraRoll` — https://warcraft.wiki.gg/wiki/API_Model_SetCameraRoll
- `SetPosition` — https://warcraft.wiki.gg/wiki/API_Model_SetPosition
- `GetPosition` — https://warcraft.wiki.gg/wiki/API_Model_GetPosition
- `SetFacing` — https://warcraft.wiki.gg/wiki/API_Model_SetFacing
- `GetFacing` — https://warcraft.wiki.gg/wiki/API_Model_GetFacing
- `SetModelScale` — https://warcraft.wiki.gg/wiki/API_Model_SetModelScale
- `SetModelAlpha` — https://warcraft.wiki.gg/wiki/API_Model_SetModelAlpha
- `SetLight` — https://warcraft.wiki.gg/wiki/API_Model_SetLight
- `GetLight` — https://warcraft.wiki.gg/wiki/API_Model_GetLight
- `SetFogColor` — https://warcraft.wiki.gg/wiki/API_Model_SetFogColor
- `SetFogNear` — https://warcraft.wiki.gg/wiki/API_Model_SetFogNear
- `SetFogFar` — https://warcraft.wiki.gg/wiki/API_Model_SetFogFar
- `ClearFog` — https://warcraft.wiki.gg/wiki/API_Model_ClearFog
- `SetSequence` — https://warcraft.wiki.gg/wiki/API_Model_SetSequence
- `SetSequenceTime` — https://warcraft.wiki.gg/wiki/API_Model_SetSequenceTime
- `AdvanceTime` — https://warcraft.wiki.gg/wiki/API_Model_AdvanceTime
- `SetTransform` — https://warcraft.wiki.gg/wiki/API_Model_SetTransform
- `TransformCameraSpaceToModelSpace` — https://warcraft.wiki.gg/wiki/API_Model_TransformCameraSpaceToModelSpace

---

## PlayerModel

Inherits from **Model**. Extends Model with unit/creature/item display capabilities including animations, display info, and portrait zooming. Created via `CreateFrame("PlayerModel", ...)`.

> **Reference:** https://warcraft.wiki.gg/wiki/UIOBJECT_PlayerModel
> **Widget API:** https://warcraft.wiki.gg/wiki/Widget_API#PlayerModel

### Unit and Model Display

| Method | Signature | Description |
|--------|-----------|-------------|
| SetUnit | `PlayerModel:SetUnit(unit [, blend, useNativeForm]) : success` | Sets the model to display the specified unit. |
| CanSetUnit | `PlayerModel:CanSetUnit(unit)` | Returns whether the unit can be set. |
| RefreshUnit | `PlayerModel:RefreshUnit()` | Refreshes the displayed unit model. |
| SetCreature | `PlayerModel:SetCreature(creatureID [, displayID])` | Sets the model to a creature. |
| SetDisplayInfo | `PlayerModel:SetDisplayInfo(displayID [, mountDisplayID])` | Sets the display by display ID. |
| GetDisplayInfo | `PlayerModel:GetDisplayInfo() : displayID` | Returns the current display ID. |
| SetItem | `PlayerModel:SetItem(itemID [, appearanceModID, itemVisualID])` | Sets the model to display an item. |
| SetItemAppearance | `PlayerModel:SetItemAppearance(itemAppearanceID [, itemVisualID, itemSubclass])` | Sets a specific item appearance. |

### Animation

| Method | Signature | Description |
|--------|-----------|-------------|
| SetAnimation | `PlayerModel:SetAnimation(anim [, variation])` | Sets the animation to be played by the model. |
| FreezeAnimation | `PlayerModel:FreezeAnimation(anim, variation, frame)` | Freezes an animation at a specific frame. |
| HasAnimation | `PlayerModel:HasAnimation(anim) : hasAnimation` | Returns true if the model supports the given animation ID. |
| ApplySpellVisualKit | `PlayerModel:ApplySpellVisualKit(spellVisualKitID [, oneShot])` | Applies a spell visual kit to the model. |
| PlayAnimKit | `PlayerModel:PlayAnimKit(animKit [, loop])` | Plays an animation kit. |
| StopAnimKit | `PlayerModel:StopAnimKit()` | Stops the current animation kit. |

### Camera and Appearance

| Method | Signature | Description |
|--------|-----------|-------------|
| RefreshCamera | `PlayerModel:RefreshCamera()` | Refreshes the camera settings. |
| SetCamDistanceScale | `PlayerModel:SetCamDistanceScale(scale)` | Sets the camera distance scale. |
| SetPortraitZoom | `PlayerModel:SetPortraitZoom(zoom)` | Sets the portrait zoom level. |
| SetRotation | `PlayerModel:SetRotation(radians [, animate])` | Rotates the model. |
| SetBarberShopAlternateForm | `PlayerModel:SetBarberShopAlternateForm()` | Sets the alternate barber shop form. |

### Behavior

| Method | Signature | Description |
|--------|-----------|-------------|
| SetDoBlend | `PlayerModel:SetDoBlend([doBlend])` | Sets whether to blend between animations. |
| GetDoBlend | `PlayerModel:GetDoBlend() : doBlend` | Returns the blend setting. |
| SetKeepModelOnHide | `PlayerModel:SetKeepModelOnHide(keepModelOnHide)` | Sets whether to keep the model loaded when hidden. |
| GetKeepModelOnHide | `PlayerModel:GetKeepModelOnHide() : keepModelOnHide` | Returns the keep-on-hide setting. |
| ZeroCachedCenterXY | `PlayerModel:ZeroCachedCenterXY()` | Zeroes the cached center XY. |

### Individual Method References
- `SetUnit` — https://warcraft.wiki.gg/wiki/API_PlayerModel_SetUnit
- `CanSetUnit` — https://warcraft.wiki.gg/wiki/API_PlayerModel_CanSetUnit
- `RefreshUnit` — https://warcraft.wiki.gg/wiki/API_PlayerModel_RefreshUnit
- `SetCreature` — https://warcraft.wiki.gg/wiki/API_PlayerModel_SetCreature
- `SetDisplayInfo` — https://warcraft.wiki.gg/wiki/API_PlayerModel_SetDisplayInfo
- `GetDisplayInfo` — https://warcraft.wiki.gg/wiki/API_PlayerModel_GetDisplayInfo
- `SetItem` — https://warcraft.wiki.gg/wiki/API_PlayerModel_SetItem
- `SetItemAppearance` — https://warcraft.wiki.gg/wiki/API_PlayerModel_SetItemAppearance
- `SetAnimation` — https://warcraft.wiki.gg/wiki/API_PlayerModel_SetAnimation
- `FreezeAnimation` — https://warcraft.wiki.gg/wiki/API_PlayerModel_FreezeAnimation
- `HasAnimation` — https://warcraft.wiki.gg/wiki/API_PlayerModel_HasAnimation
- `ApplySpellVisualKit` — https://warcraft.wiki.gg/wiki/API_PlayerModel_ApplySpellVisualKit
- `PlayAnimKit` — https://warcraft.wiki.gg/wiki/API_PlayerModel_PlayAnimKit
- `SetPortraitZoom` — https://warcraft.wiki.gg/wiki/API_PlayerModel_SetPortraitZoom
- `SetRotation` — https://warcraft.wiki.gg/wiki/API_PlayerModel_SetRotation
- `SetCamDistanceScale` — https://warcraft.wiki.gg/wiki/API_PlayerModel_SetCamDistanceScale

---

## CinematicModel

Inherits from **PlayerModel**. Adds cinematic camera panning and animation overlays. Created via `CreateFrame("CinematicModel", ...)`.

> **Reference:** https://warcraft.wiki.gg/wiki/UIOBJECT_CinematicModel
> **Widget API:** https://warcraft.wiki.gg/wiki/Widget_API#CinematicModel

| Method | Signature | Description |
|--------|-----------|-------------|
| InitializeCamera | `CinematicModel:InitializeCamera([scaleFactor])` | Initializes the standard camera. |
| InitializePanCamera | `CinematicModel:InitializePanCamera([scaleFactor])` | Initializes the pan camera. |
| RefreshCamera | `CinematicModel:RefreshCamera()` | Refreshes the camera. |
| SetCameraPosition | `CinematicModel:SetCameraPosition(positionX, positionY, positionZ)` | Sets the camera position (overrides Model). |
| SetCameraTarget | `CinematicModel:SetCameraTarget(positionX, positionY, positionZ)` | Sets the camera target. |
| SetTargetDistance | `CinematicModel:SetTargetDistance(scale)` | Sets the target distance scale. |
| SetPanDistance | `CinematicModel:SetPanDistance(scale)` | Sets the pan distance scale. |
| StartPan | `CinematicModel:StartPan(panType, durationSeconds [, doFade, visKitID, startPositionScale, speedMultiplier])` | Starts a pan animation. |
| StopPan | `CinematicModel:StopPan()` | Stops the pan. |
| SetAnimOffset | `CinematicModel:SetAnimOffset(offset)` | Sets an animation offset. |
| SetHeightFactor | `CinematicModel:SetHeightFactor(factor)` | Sets the height factor. |
| SetFacingLeft | `CinematicModel:SetFacingLeft([isFacingLeft])` | Sets whether the model faces left. |
| SetFadeTimes | `CinematicModel:SetFadeTimes(fadeInSeconds, fadeOutSeconds)` | Sets fade-in and fade-out times. |
| SetJumpInfo | `CinematicModel:SetJumpInfo(jumpLength, jumpHeight)` | Sets jump animation parameters. |
| EquipItem | `CinematicModel:EquipItem(itemID)` | Equips an item on the model. |
| UnequipItems | `CinematicModel:UnequipItems()` | Removes all equipped items. |
| SetCreatureData | `CinematicModel:SetCreatureData(creatureID)` | Sets creature data for the model. |
| SetSpellVisualKit | `CinematicModel:SetSpellVisualKit(visualKitID)` | Sets a spell visual kit. |

### Individual Method References
- `InitializeCamera` — https://warcraft.wiki.gg/wiki/API_CinematicModel_InitializeCamera
- `InitializePanCamera` — https://warcraft.wiki.gg/wiki/API_CinematicModel_InitializePanCamera
- `RefreshCamera` — https://warcraft.wiki.gg/wiki/API_CinematicModel_RefreshCamera
- `SetCameraPosition` — https://warcraft.wiki.gg/wiki/API_CinematicModel_SetCameraPosition
- `SetCameraTarget` — https://warcraft.wiki.gg/wiki/API_CinematicModel_SetCameraTarget
- `StartPan` — https://warcraft.wiki.gg/wiki/API_CinematicModel_StartPan
- `StopPan` — https://warcraft.wiki.gg/wiki/API_CinematicModel_StopPan
- `EquipItem` — https://warcraft.wiki.gg/wiki/API_CinematicModel_EquipItem
- `UnequipItems` — https://warcraft.wiki.gg/wiki/API_CinematicModel_UnequipItems
- `SetCreatureData` — https://warcraft.wiki.gg/wiki/API_CinematicModel_SetCreatureData
- `SetFacingLeft` — https://warcraft.wiki.gg/wiki/API_CinematicModel_SetFacingLeft
- `SetHeightFactor` — https://warcraft.wiki.gg/wiki/API_CinematicModel_SetHeightFactor
- `SetPanDistance` — https://warcraft.wiki.gg/wiki/API_CinematicModel_SetPanDistance
- `SetTargetDistance` — https://warcraft.wiki.gg/wiki/API_CinematicModel_SetTargetDistance

---

## DressUpModel

Inherits from **PlayerModel**. Adds try-on (transmogrification preview), dress/undress, and transmog info capabilities. Created via `CreateFrame("DressUpModel", ...)`.

> **Reference:** https://warcraft.wiki.gg/wiki/UIOBJECT_DressUpModel
> **Widget API:** https://warcraft.wiki.gg/wiki/Widget_API#DressUpModel

| Method | Signature | Description |
|--------|-----------|-------------|
| TryOn | `DressUpModel:TryOn(linkOrItemModifiedAppearanceID [, handSlotName, spellEnchantID]) : result` | Previews an item on the model. |
| Dress | `DressUpModel:Dress()` | Dresses the model in the player's current gear. |
| Undress | `DressUpModel:Undress()` | Removes all items from the model. |
| UndressSlot | `DressUpModel:UndressSlot(inventorySlot)` | Removes the item in a specific slot. |
| SetAutoDress | `DressUpModel:SetAutoDress([enabled])` | Sets whether the model auto-dresses. |
| GetAutoDress | `DressUpModel:GetAutoDress() : enabled` | Returns whether auto-dress is enabled. |
| SetItemTransmogInfo | `DressUpModel:SetItemTransmogInfo(itemTransmogInfo [, inventorySlot, ignoreChildItems]) : result` | Sets transmog info for a slot. |
| GetItemTransmogInfo | `DressUpModel:GetItemTransmogInfo(inventorySlot) : itemTransmogInfo` | Returns transmog info for a slot. |
| GetItemTransmogInfoList | `DressUpModel:GetItemTransmogInfoList() : infoList` | Returns all transmog info. |
| SetObeyHideInTransmogFlag | `DressUpModel:SetObeyHideInTransmogFlag([enabled])` | Sets whether to obey transmog hide flags. |
| GetObeyHideInTransmogFlag | `DressUpModel:GetObeyHideInTransmogFlag() : enabled` | Returns the setting. |
| SetUseTransmogChoices | `DressUpModel:SetUseTransmogChoices([enabled])` | Sets whether to use transmog choices. |
| GetUseTransmogChoices | `DressUpModel:GetUseTransmogChoices() : enabled` | Returns the setting. |
| SetUseTransmogSkin | `DressUpModel:SetUseTransmogSkin([enabled])` | Sets whether to use the transmog skin appearance. |
| GetUseTransmogSkin | `DressUpModel:GetUseTransmogSkin() : enabled` | Returns the setting. |
| SetSheathed | `DressUpModel:SetSheathed([sheathed, hideWeapons])` | Sets the sheathed state. |
| GetSheathed | `DressUpModel:GetSheathed() : sheathed` | Returns the sheathed state. |
| IsGeoReady | `DressUpModel:IsGeoReady() : ready` | Returns whether the geometry is loaded. |
| IsSlotAllowed | `DressUpModel:IsSlotAllowed(slot) : allowed` | Returns whether a slot can be modified. |
| IsSlotVisible | `DressUpModel:IsSlotVisible(slot) : visible` | Returns whether a slot's item is visible. |

### Individual Method References
- `TryOn` — https://warcraft.wiki.gg/wiki/API_DressUpModel_TryOn
- `Dress` — https://warcraft.wiki.gg/wiki/API_DressUpModel_Dress
- `Undress` — https://warcraft.wiki.gg/wiki/API_DressUpModel_Undress
- `UndressSlot` — https://warcraft.wiki.gg/wiki/API_DressUpModel_UndressSlot
- `SetAutoDress` — https://warcraft.wiki.gg/wiki/API_DressUpModel_SetAutoDress
- `GetAutoDress` — https://warcraft.wiki.gg/wiki/API_DressUpModel_GetAutoDress
- `SetItemTransmogInfo` — https://warcraft.wiki.gg/wiki/API_DressUpModel_SetItemTransmogInfo
- `GetItemTransmogInfo` — https://warcraft.wiki.gg/wiki/API_DressUpModel_GetItemTransmogInfo
- `GetItemTransmogInfoList` — https://warcraft.wiki.gg/wiki/API_DressUpModel_GetItemTransmogInfoList
- `SetSheathed` — https://warcraft.wiki.gg/wiki/API_DressUpModel_SetSheathed
- `GetSheathed` — https://warcraft.wiki.gg/wiki/API_DressUpModel_GetSheathed
- `IsGeoReady` — https://warcraft.wiki.gg/wiki/API_DressUpModel_IsGeoReady
- `IsSlotAllowed` — https://warcraft.wiki.gg/wiki/API_DressUpModel_IsSlotAllowed
- `IsSlotVisible` — https://warcraft.wiki.gg/wiki/API_DressUpModel_IsSlotVisible

---

## TabardModel

Inherits from **PlayerModel**. Displays a guild tabard model with customization options. Created via `CreateFrame("TabardModel", ...)`.

> **Reference:** https://warcraft.wiki.gg/wiki/UIOBJECT_TabardModel
> **Widget API:** https://warcraft.wiki.gg/wiki/Widget_API#TabardModel

### TabardModel Methods

| Method | Signature | Description |
|--------|-----------|-------------|
| GetLowerBackgroundFileName | `TabardModel:GetLowerBackgroundFileName() : file` | Returns the lower background file path. |
| GetLowerBorderFile | `TabardModel:GetLowerBorderFile() : file` | Returns the lower border file path. |
| GetLowerEmblemFile | `TabardModel:GetLowerEmblemFile() : file` | Returns the lower emblem file path. |
| GetUpperBackgroundFileName | `TabardModel:GetUpperBackgroundFileName() : file` | Returns the upper background file path. |
| GetUpperBorderFile | `TabardModel:GetUpperBorderFile() : file` | Returns the upper border file path. |
| GetUpperEmblemFile | `TabardModel:GetUpperEmblemFile() : file` | Returns the upper emblem file path. |

### TabardModelBase Methods

These methods come from the `TabardModelBase` mixin:

| Method | Signature | Description |
|--------|-----------|-------------|
| CanSaveTabardNow | `TabardModelBase:CanSaveTabardNow() : canSave` | Returns whether the tabard can be saved. |
| CycleVariation | `TabardModelBase:CycleVariation(variationIndex, delta)` | Cycles through design variations. |
| GetLowerEmblemTexture | `TabardModelBase:GetLowerEmblemTexture(texture)` | Returns the lower emblem texture. |
| GetUpperEmblemTexture | `TabardModelBase:GetUpperEmblemTexture(texture)` | Returns the upper emblem texture. |
| InitializeTabardColors | `TabardModelBase:InitializeTabardColors()` | Initializes the tabard color options. |
| IsGuildTabard | `TabardModelBase:IsGuildTabard() : isGuildTabard` | Returns whether this is a guild tabard. |
| Save | `TabardModelBase:Save()` | Saves the tabard design. |

### Individual Method References
- `GetLowerBackgroundFileName` — https://warcraft.wiki.gg/wiki/API_TabardModel_GetLowerBackgroundFileName
- `GetUpperBackgroundFileName` — https://warcraft.wiki.gg/wiki/API_TabardModel_GetUpperBackgroundFileName
- `GetLowerBorderFile` — https://warcraft.wiki.gg/wiki/API_TabardModel_GetLowerBorderFile
- `GetUpperBorderFile` — https://warcraft.wiki.gg/wiki/API_TabardModel_GetUpperBorderFile
- `GetLowerEmblemFile` — https://warcraft.wiki.gg/wiki/API_TabardModel_GetLowerEmblemFile
- `GetUpperEmblemFile` — https://warcraft.wiki.gg/wiki/API_TabardModel_GetUpperEmblemFile
- `CanSaveTabardNow` — https://warcraft.wiki.gg/wiki/API_TabardModelBase_CanSaveTabardNow
- `CycleVariation` — https://warcraft.wiki.gg/wiki/API_TabardModelBase_CycleVariation
- `InitializeTabardColors` — https://warcraft.wiki.gg/wiki/API_TabardModelBase_InitializeTabardColors
- `IsGuildTabard` — https://warcraft.wiki.gg/wiki/API_TabardModelBase_IsGuildTabard
- `Save` — https://warcraft.wiki.gg/wiki/API_TabardModelBase_Save

---

## ModelScene

Inherits from **Frame**. A modern 3D scene frame with camera controls, lighting, and support for multiple actors. Preferred over Model for new development. Created via `CreateFrame("ModelScene", ...)`.

> **Reference:** https://warcraft.wiki.gg/wiki/UIOBJECT_ModelScene
> **Widget API:** https://warcraft.wiki.gg/wiki/Widget_API#ModelScene

### Actors

| Method | Signature | Description |
|--------|-----------|-------------|
| CreateActor | `ModelScene:CreateActor([name, template]) : actor` | Creates a new ModelSceneActor in this scene. |
| GetActorAtIndex | `ModelScene:GetActorAtIndex(index) : actor` | Returns the actor at the given index. |
| GetNumActors | `ModelScene:GetNumActors() : numActors` | Returns the number of actors. |
| TakeActor | `ModelScene:TakeActor()` | Takes an actor from the pool. |

### Camera

| Method | Signature | Description |
|--------|-----------|-------------|
| SetCameraFieldOfView | `ModelScene:SetCameraFieldOfView(fov)` | Sets the camera field of view. |
| GetCameraFieldOfView | `ModelScene:GetCameraFieldOfView() : fov` | Returns the camera FOV. |
| SetCameraNearClip | `ModelScene:SetCameraNearClip(nearClip)` | Sets the near clipping plane. |
| GetCameraNearClip | `ModelScene:GetCameraNearClip() : nearClip` | Returns the near clip distance. |
| SetCameraFarClip | `ModelScene:SetCameraFarClip(farClip)` | Sets the far clipping plane. |
| GetCameraFarClip | `ModelScene:GetCameraFarClip() : farClip` | Returns the far clip distance. |
| SetCameraOrientationByYawPitchRoll | `ModelScene:SetCameraOrientationByYawPitchRoll(yaw, pitch, roll)` | Sets camera orientation via yaw/pitch/roll. |
| SetCameraOrientationByAxisVectors | `ModelScene:SetCameraOrientationByAxisVectors(forwardX, forwardY, forwardZ, rightX, rightY, rightZ, upX, upY, upZ)` | Sets camera orientation via axis vectors. |
| GetCameraForward | `ModelScene:GetCameraForward() : forwardX, forwardY, forwardZ` | Returns the camera forward vector. |
| GetCameraRight | `ModelScene:GetCameraRight() : rightX, rightY, rightZ` | Returns the camera right vector. |
| GetCameraUp | `ModelScene:GetCameraUp() : upX, upY, upZ` | Returns the camera up vector. |

### Lighting

| Method | Signature | Description |
|--------|-----------|-------------|
| SetLightType | `ModelScene:SetLightType(lightType)` | Sets the light type. |
| GetLightType | `ModelScene:GetLightType() : lightType` | Returns the light type. |
| SetLightVisible | `ModelScene:SetLightVisible([visible])` | Sets whether the light is visible. |
| IsLightVisible | `ModelScene:IsLightVisible() : isVisible` | Returns whether the light is visible. |
| SetLightPosition | `ModelScene:SetLightPosition(positionX, positionY, positionZ)` | Sets the light position. |
| GetLightPosition | `ModelScene:GetLightPosition() : positionX, positionY, positionZ` | Returns the light position. |
| SetLightDirection | `ModelScene:SetLightDirection(directionX, directionY, directionZ)` | Sets the light direction. |
| GetLightDirection | `ModelScene:GetLightDirection() : directionX, directionY, directionZ` | Returns the light direction. |
| SetLightAmbientColor | `ModelScene:SetLightAmbientColor(colorR, colorG, colorB)` | Sets the ambient light color. |
| GetLightAmbientColor | `ModelScene:GetLightAmbientColor() : colorR, colorG, colorB` | Returns the ambient light color. |
| SetLightDiffuseColor | `ModelScene:SetLightDiffuseColor(colorR, colorG, colorB)` | Sets the diffuse light color. |
| GetLightDiffuseColor | `ModelScene:GetLightDiffuseColor() : colorR, colorG, colorB` | Returns the diffuse light color. |

### Other

| Method | Signature | Description |
|--------|-----------|-------------|
| Project3DPointTo2D | `ModelScene:Project3DPointTo2D(pointX, pointY, pointZ) : point2DX, point2DY, depth` | Converts a 3D point to 2D clip-space using the scene camera. |
| SetDrawLayer | `ModelScene:SetDrawLayer(layer)` | Sets the draw layer for the scene. |
| GetDrawLayer | `ModelScene:GetDrawLayer() : layer, sublevel` | Returns the draw layer. |
| SetPaused | `ModelScene:SetPaused(paused [, affectsGlobalPause])` | Pauses or resumes the scene. |
| SetAllowOverlappedModels | `ModelScene:SetAllowOverlappedModels(allowOverlappedModels)` | Sets whether models can overlap. |
| GetAllowOverlappedModels | `ModelScene:GetAllowOverlappedModels() : allowOverlappedModels` | Returns the overlap setting. |

### Individual Method References
- `CreateActor` — https://warcraft.wiki.gg/wiki/API_ModelScene_CreateActor
- `GetActorAtIndex` — https://warcraft.wiki.gg/wiki/API_ModelScene_GetActorAtIndex
- `GetNumActors` — https://warcraft.wiki.gg/wiki/API_ModelScene_GetNumActors
- `TakeActor` — https://warcraft.wiki.gg/wiki/API_ModelScene_TakeActor
- `SetCameraFieldOfView` — https://warcraft.wiki.gg/wiki/API_ModelScene_SetCameraFieldOfView
- `GetCameraFieldOfView` — https://warcraft.wiki.gg/wiki/API_ModelScene_GetCameraFieldOfView
- `SetCameraNearClip` — https://warcraft.wiki.gg/wiki/API_ModelScene_SetCameraNearClip
- `SetCameraFarClip` — https://warcraft.wiki.gg/wiki/API_ModelScene_SetCameraFarClip
- `SetCameraOrientationByYawPitchRoll` — https://warcraft.wiki.gg/wiki/API_ModelScene_SetCameraOrientationByYawPitchRoll
- `SetCameraOrientationByAxisVectors` — https://warcraft.wiki.gg/wiki/API_ModelScene_SetCameraOrientationByAxisVectors
- `Project3DPointTo2D` — https://warcraft.wiki.gg/wiki/API_ModelScene_Project3DPointTo2D
- `SetLightAmbientColor` — https://warcraft.wiki.gg/wiki/API_ModelScene_SetLightAmbientColor
- `SetLightDiffuseColor` — https://warcraft.wiki.gg/wiki/API_ModelScene_SetLightDiffuseColor
- `SetLightDirection` — https://warcraft.wiki.gg/wiki/API_ModelScene_SetLightDirection
- `SetLightPosition` — https://warcraft.wiki.gg/wiki/API_ModelScene_SetLightPosition
- `SetPaused` — https://warcraft.wiki.gg/wiki/API_ModelScene_SetPaused

---

## ModelSceneActor / ModelSceneActorBase

`ModelSceneActor` inherits from `ModelSceneActorBase`. Actors live inside a **ModelScene** and represent individual 3D models within the scene.

> **Reference:** https://warcraft.wiki.gg/wiki/UIOBJECT_ModelSceneActor
> **Widget API:** https://warcraft.wiki.gg/wiki/Widget_API#ModelSceneActor

### ModelSceneActor Methods

| Method | Signature | Description |
|--------|-----------|-------------|
| AttachToMount | `ModelSceneActor:AttachToMount(rider, animation [, spellKitVisualID]) : success` | Attaches this actor (mount) to a rider actor. |
| CalculateMountScale | `ModelSceneActor:CalculateMountScale(rider) : scale` | Calculates the appropriate mount scale. |
| DetachFromMount | `ModelSceneActor:DetachFromMount(rider) : success` | Detaches from a mount. |
| DressPlayerSlot | `ModelSceneActor:DressPlayerSlot(invSlot)` | Dresses the actor in the player's item for that slot. |
| GetPaused | `ModelSceneActor:GetPaused() : paused, globalPaused` | Returns the paused state. |
| SetPaused | `ModelSceneActor:SetPaused(paused [, affectsGlobalPause])` | Sets the paused state. |
| ReleaseFrontEndCharacterDisplays | `ModelSceneActor:ReleaseFrontEndCharacterDisplays() : success` | Releases front-end character displays. |
| ResetNextHandSlot | `ModelSceneActor:ResetNextHandSlot()` | Resets the next hand slot. |
| SetFrontEndLobbyModelFromDefaultCharacterDisplay | `ModelSceneActor:SetFrontEndLobbyModelFromDefaultCharacterDisplay(characterIndex) : success` | Sets the login screen model. |
| SetModelByHyperlink | `ModelSceneActor:SetModelByHyperlink(link) : success` | Sets the model from a hyperlink. |

### ModelSceneActorBase Methods

| Method | Signature | Description |
|--------|-----------|-------------|
| SetModelByUnit | `ModelSceneActorBase:SetModelByUnit(unit [, sheatheWeapons [, autoDress [, hideWeapons [, usePlayerNativeForm [, holdBowString [, customRaceID]]]]]]) : success` | Sets the actor model to a unit. |
| SetModelByCreatureDisplayID | `ModelSceneActorBase:SetModelByCreatureDisplayID(creatureDisplayID [, useActivePlayerCustomizations]) : success` | Sets model by creature display ID. |
| SetModelByFileID | `ModelSceneActorBase:SetModelByFileID(asset [, useMips]) : success` | Sets model by file ID. |
| SetModelByPath | `ModelSceneActorBase:SetModelByPath(asset [, useMips]) : success` | Sets model by asset path. |
| SetPlayerModelFromGlues | `ModelSceneActorBase:SetPlayerModelFromGlues([characterIndex [, sheatheWeapons [, autoDress [, hideWeapons [, usePlayerNativeForm [, customRaceID]]]]]]) : success` | Sets the player model from the glue screens. |
| GetModelPath | `ModelSceneActorBase:GetModelPath() : path` | Returns the model path. |
| GetModelUnitGUID | `ModelSceneActorBase:GetModelUnitGUID() : guid` | Returns the unit GUID. |
| IsLoaded | `ModelSceneActorBase:IsLoaded() : isLoaded` | Returns whether the model is loaded. |
| SetAnimation | `ModelSceneActorBase:SetAnimation(animation [, variation, animSpeed, animOffsetSeconds])` | Sets the animation. |
| GetAnimation | `ModelSceneActorBase:GetAnimation() : animation` | Returns the current animation. |
| GetAnimationVariation | `ModelSceneActorBase:GetAnimationVariation() : variation` | Returns the animation variation. |
| SetAnimationBlendOperation | `ModelSceneActorBase:SetAnimationBlendOperation(blendOp)` | Sets the animation blend operation. |
| GetAnimationBlendOperation | `ModelSceneActorBase:GetAnimationBlendOperation() : blendOp` | Returns the blend operation. |
| PlayAnimationKit | `ModelSceneActorBase:PlayAnimationKit(animationKit [, isLooping])` | Plays an animation kit. |
| StopAnimationKit | `ModelSceneActorBase:StopAnimationKit()` | Stops the current animation kit. |
| SetYaw | `ModelSceneActorBase:SetYaw(yaw)` | Sets the actor's yaw rotation. |
| GetYaw | `ModelSceneActorBase:GetYaw() : yaw` | Returns the yaw. |
| GetActiveBoundingBox | `ModelSceneActorBase:GetActiveBoundingBox() : boxBottom, boxTop` | Returns the active bounding box. |
| GetMaxBoundingBox | `ModelSceneActorBase:GetMaxBoundingBox() : boxBottom, boxTop` | Returns the maximum bounding box. |
| SetSpellVisualKit | `ModelSceneActorBase:SetSpellVisualKit([spellVisualKitID, oneShot])` | Sets a spell visual kit on the actor. |
| GetSpellVisualKit | `ModelSceneActorBase:GetSpellVisualKit() : spellVisualKitID` | Returns the current spell visual kit ID. |
| SetParticleOverrideScale | `ModelSceneActorBase:SetParticleOverrideScale([scale])` | Sets the particle override scale. |
| GetParticleOverrideScale | `ModelSceneActorBase:GetParticleOverrideScale() : scale` | Returns the particle scale. |
| SetUseCenterForOrigin | `ModelSceneActorBase:SetUseCenterForOrigin([x, y, z])` | Sets whether to use center for origin. |
| IsUsingCenterForOrigin | `ModelSceneActorBase:IsUsingCenterForOrigin() : x, y, z` | Returns the center-for-origin setting. |
| SetPreferModelCollisionBounds | `ModelSceneActorBase:SetPreferModelCollisionBounds(preferCollisionBounds)` | Sets whether to prefer collision bounds. |
| IsPreferringModelCollisionBounds | `ModelSceneActorBase:IsPreferringModelCollisionBounds() : preferringCollisionBounds` | Returns the collision bounds preference. |
| SetGradientMask | `ModelSceneActorBase:SetGradientMask(gradientIndex0, gradientIndex1, gradientIndex2, gradientIndex3)` | Sets a gradient mask on the actor. |

### Individual Method References
- `AttachToMount` — https://warcraft.wiki.gg/wiki/API_ModelSceneActor_AttachToMount
- `CalculateMountScale` — https://warcraft.wiki.gg/wiki/API_ModelSceneActor_CalculateMountScale
- `DetachFromMount` — https://warcraft.wiki.gg/wiki/API_ModelSceneActor_DetachFromMount
- `DressPlayerSlot` — https://warcraft.wiki.gg/wiki/API_ModelSceneActor_DressPlayerSlot
- `SetModelByHyperlink` — https://warcraft.wiki.gg/wiki/API_ModelSceneActor_SetModelByHyperlink
- `SetModelByUnit` — https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_SetModelByUnit
- `SetModelByCreatureDisplayID` — https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_SetModelByCreatureDisplayID
- `SetModelByFileID` — https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_SetModelByFileID
- `SetModelByPath` — https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_SetModelByPath
- `SetPlayerModelFromGlues` — https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_SetPlayerModelFromGlues
- `GetModelPath` — https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_GetModelPath
- `GetModelUnitGUID` — https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_GetModelUnitGUID
- `IsLoaded` — https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_IsLoaded
- `SetAnimation` — https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_SetAnimation
- `GetAnimation` — https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_GetAnimation
- `PlayAnimationKit` — https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_PlayAnimationKit
- `StopAnimationKit` — https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_StopAnimationKit
- `SetYaw` — https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_SetYaw
- `GetYaw` — https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_GetYaw
- `GetActiveBoundingBox` — https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_GetActiveBoundingBox
- `GetMaxBoundingBox` — https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_GetMaxBoundingBox
- `SetSpellVisualKit` — https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_SetSpellVisualKit
- `SetUseCenterForOrigin` — https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_SetUseCenterForOrigin
