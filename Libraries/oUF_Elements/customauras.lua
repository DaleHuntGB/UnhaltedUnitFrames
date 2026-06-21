--[[
# Element: Custom Auras

Handles creation and updating of a single additional aura container.

## Widget

CustomAuras - A `Frame` to hold `Button`s representing either buffs or debuffs.

## Notes

This element mirrors oUF's Buffs/Debuffs aura paths, but uses a separate widget so
layouts can display a third aura container.

## Options

.disableMouse             - Disables mouse events (boolean)
.disableCooldown          - Disables the cooldown spiral (boolean)
.size                     - Aura button size. Defaults to 16 (number)
.width                    - Aura button width. Takes priority over `size` (number)
.height                   - Aura button height. Takes priority over `size` (number)
.onlyShowPlayer           - Shows only auras created by player/vehicle (boolean)
.showStealableBuffs       - Displays the stealable texture on buffs that can be stolen (boolean)
.spacing                  - Spacing between each button. Defaults to 0 (number)
.spacingX                 - Horizontal spacing between each button. Takes priority over `spacing` (number)
.spacingY                 - Vertical spacing between each button. Takes priority over `spacing` (number)
.growthX                  - Horizontal growth direction. Defaults to 'RIGHT' (string)
.growthY                  - Vertical growth direction. Defaults to 'UP' (string)
.initialAnchor            - Anchor point for the aura buttons. Defaults to 'BOTTOMLEFT' (string)
.filter                   - Aura filter to display. Defaults to 'HELPFUL' (string)
.tooltipAnchor            - Anchor point for the tooltip. Defaults to 'ANCHOR_BOTTOMRIGHT' (string)
.reanchorIfVisibleChanged - Reanchors aura buttons when the number of visible auras has changed (boolean)
.showType                 - Show Overlay texture colored by oUF.colors.dispel (boolean)
.showDebuffType           - Show Overlay texture colored by oUF.colors.dispel when it's a debuff. Exclusive with .showType (boolean)
.showBuffType             - Show Overlay texture colored by oUF.colors.dispel when it's a buff. Exclusive with .showType (boolean)
.minCount                 - Minimum number of aura applications for the Count text to be visible. Defaults to 2 (number)
.maxCount                 - Maximum number of aura applications for the Count text, anything above renders "*". Defaults to 999 (number)
.maxCols                  - Maximum number of aura button columns before wrapping to a new row (number)
.num                      - Number of auras to display. Defaults to 32 (number)

## Attributes

.dispelColorCurve - Curve object with points defined for each index in oUF.colors.dispel

## Button Attributes

button.auraInstanceID - unique ID for the current aura being tracked by the button (number)
button.isHarmfulAura  - indicates if the button holds a debuff (boolean)

## Examples

    -- Position and size
    local CustomAuras = CreateFrame('Frame', nil, self)
    CustomAuras:SetPoint('RIGHT', self, 'LEFT')
    CustomAuras:SetSize(16 * 3, 16)

    -- Register it with oUF
    self.CustomAuras = CustomAuras
--]]

local _, ns = ...
local oUF = ns.oUF

local function UpdateTooltip(self)
	if(GameTooltip:IsForbidden()) then return end

	GameTooltip:SetUnitAuraByAuraInstanceID(self:GetParent().__owner.unit, self.auraInstanceID)
end

local function onEnter(self)
	if(GameTooltip:IsForbidden() or not self:IsVisible()) then return end

	GameTooltip:SetOwner(self, self:GetParent().__restricted and 'ANCHOR_CURSOR' or self:GetParent().tooltipAnchor)
	self:UpdateTooltip()
end

local function onLeave()
	if(GameTooltip:IsForbidden()) then return end

	GameTooltip:Hide()
end

local function CreateButton(element, index)
	local button = CreateFrame('Button', element:GetDebugName() .. 'Button' .. index, element)

	local cd = CreateFrame('Cooldown', '$parentCooldown', button, 'CooldownFrameTemplate')
	cd:SetAllPoints()
	button.Cooldown = cd

	local icon = button:CreateTexture(nil, 'BORDER')
	icon:SetAllPoints()
	button.Icon = icon

	local countFrame = CreateFrame('Frame', nil, button)
	countFrame:SetAllPoints(button)
	countFrame:SetFrameLevel(cd:GetFrameLevel() + 1)

	local count = countFrame:CreateFontString(nil, 'OVERLAY', 'NumberFontNormal')
	count:SetPoint('BOTTOMRIGHT', countFrame, 'BOTTOMRIGHT', -1, 0)
	button.Count = count

	local overlay = button:CreateTexture(nil, 'OVERLAY')
	overlay:SetTexture([[Interface\Buttons\UI-Debuff-Overlays]])
	overlay:SetAllPoints()
	overlay:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
	button.Overlay = overlay

	local stealable = button:CreateTexture(nil, 'OVERLAY')
	stealable:SetTexture([[Interface\TargetingFrame\UI-TargetingFrame-Stealable]])
	stealable:SetPoint('TOPLEFT', -3, 3)
	stealable:SetPoint('BOTTOMRIGHT', 3, -3)
	stealable:SetBlendMode('ADD')
	button.Stealable = stealable

	button.UpdateTooltip = UpdateTooltip
	button:SetScript('OnEnter', onEnter)
	button:SetScript('OnLeave', onLeave)

	--[[ Callback: CustomAuras:PostCreateButton(button)
	Called after a new aura button has been created.

	* self   - the CustomAuras element
	* button - the newly created aura button (Button)
	--]]
	if(element.PostCreateButton) then element:PostCreateButton(button) end

	return button
end

local function SetPosition(element, from, to)
	local width = element.width or element.size or 16
	local height = element.height or element.size or 16
	local sizeX = width + (element.spacingX or element.spacing or 0)
	local sizeY = height + (element.spacingY or element.spacing or 0)
	local anchor = element.initialAnchor or 'BOTTOMLEFT'
	local growthX = (element.growthX == 'LEFT' and -1) or 1
	local growthY = (element.growthY == 'DOWN' and -1) or 1
	local cols = element.maxCols or math.floor(element:GetWidth() / sizeX + 0.5)

	for i = from, to do
		local button = element[i]
		if(not button) then break end

		local col = (i - 1) % cols
		local row = math.floor((i - 1) / cols)

		button:ClearAllPoints()
		button:SetPoint(anchor, element, anchor, col * sizeX * growthX, row * sizeY * growthY)
	end
end

local function SortAuras(a, b)
	if(a.isPlayerAura ~= b.isPlayerAura) then
		return a.isPlayerAura
	end

	return a.auraInstanceID < b.auraInstanceID
end

local function FilterAura(element, unit, data)
	if((element.onlyShowPlayer and data.isPlayerAura) or not element.onlyShowPlayer) then
		return true
	end
end

local function processData(element, unit, data, filter)
	if(not data) then return end

	data.isPlayerAura = not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, data.auraInstanceID, filter .. '|PLAYER')
	data.isHarmfulAura = filter:find('HARMFUL') and true

	--[[ Callback: CustomAuras:PostProcessAuraData(unit, data, filter)
	Called after the aura data has been processed.

	* self   - the CustomAuras element
	* unit   - the unit for which the update has been triggered (string)
	* data   - AuraData object (table)
	* filter - the aura filter used for this container (string)
	--]]
	if(element.PostProcessAuraData) then
		data = element:PostProcessAuraData(unit, data, filter)
	end

	return data
end

local function updateAura(element, unit, data, position)
	if(not data) then return end

	local button = element[position]
	if(not button) then
		--[[ Override: CustomAuras:CreateButton(position)
		Used to create an aura button at a given position.

		* self     - the CustomAuras element
		* position - the position at which the aura button is to be created (number)

		## Returns

		* button - the button used to represent the aura (Button)
		--]]
		button = (element.CreateButton or CreateButton) (element, position)

		table.insert(element, button)
		element.createdButtons = element.createdButtons + 1
	end

	button.auraInstanceID = data.auraInstanceID

	if(button.Cooldown and not element.disableCooldown) then
		local duration = C_UnitAuras.GetAuraDuration(unit, data.auraInstanceID)
		if duration then
			button.Cooldown:SetCooldownFromDurationObject(duration)
			button.Cooldown:Show()
		else
			button.Cooldown:Hide()
		end
	end

	if(button.Overlay) then
		if(element.showType or (data.isHarmfulAura and element.showDebuffType) or (not data.isHarmfulAura and element.showBuffType)) then
			local color = C_UnitAuras.GetAuraDispelTypeColor(unit, data.auraInstanceID, element.dispelColorCurve)
			if color == nil then
				color = element.dispelColorCurve:Evaluate(0)
			end

			button.Overlay:SetVertexColor(color:GetRGBA())
			button.Overlay:Show()
		else
			button.Overlay:Hide()
		end
	end

	if(button.Stealable) then
		if(element.showStealableBuffs and not UnitCanCooperate('player', unit)) then
			button.Stealable:SetAlphaFromBoolean(data.isStealable, 1, 0)
		else
			button.Stealable:SetAlpha(0)
		end
	end

	if(button.Icon) then button.Icon:SetTexture(data.icon) end
	if(button.Count) then
		button.Count:SetText(C_UnitAuras.GetAuraApplicationDisplayCount(unit, data.auraInstanceID, element.minCount or 2, element.maxCount or 999))
	end

	local width = element.width or element.size or 16
	local height = element.height or element.size or 16
	button:SetSize(width, height)
	button:EnableMouse(not element.disableMouse)
	button:Show()

	--[[ Callback: CustomAuras:PostUpdateButton(unit, button, data, position)
	Called after the aura button has been updated.

	* self     - the CustomAuras element
	* unit     - the unit for which the update has been triggered (string)
	* button   - the updated aura button (Button)
	* data     - AuraData object (table)
	* position - the actual position of the aura button (number)
	--]]
	if(element.PostUpdateButton) then
		element:PostUpdateButton(button, unit, data, position)
	end
end

local function UpdateCustomAuras(self, event, unit, updateInfo)
	if(self.unit ~= unit) then return end

	local element = self.CustomAuras
	if(not element) then return end

	local isFullUpdate = element.needFullUpdate or not updateInfo or updateInfo.isFullUpdate
	element.needFullUpdate = false

	--[[ Callback: CustomAuras:PreUpdate(unit, isFullUpdate)
	Called before the element has been updated.

	* self         - the CustomAuras element
	* unit         - the unit for which the update has been triggered (string)
	* isFullUpdate - indicates whether the element is performing a full update (boolean)
	--]]
	if(element.PreUpdate) then element:PreUpdate(unit, isFullUpdate) end

	local aurasChanged = false
	local numAuras = element.num or 32
	local filter = element.filter or 'HELPFUL'
	if(type(filter) == 'function') then
		filter = filter(element, unit)
	end

	if(isFullUpdate) then
		element.all = table.wipe(element.all or {})
		element.active = table.wipe(element.active or {})
		aurasChanged = true

		local slots = {C_UnitAuras.GetAuraSlots(unit, filter)}
		for i = 2, #slots do
			local data = processData(element, unit, C_UnitAuras.GetAuraDataBySlot(unit, slots[i]), filter)
			if(data) then
				element.all[data.auraInstanceID] = data

				--[[ Override: CustomAuras:FilterAura(unit, data, filter)
				Defines a custom filter that controls if the aura button should be shown.

				* self   - the CustomAuras element
				* unit   - the unit for which the update has been triggered (string)
				* data   - AuraData object (table)
				* filter - the aura filter used for this container (string)

				## Returns

				* show - indicates whether the aura button should be shown (boolean)
				--]]
				if((element.FilterAura or FilterAura) (element, unit, data, filter)) then
					element.active[data.auraInstanceID] = true
				end
			end
		end
	else
		if(updateInfo.addedAuras) then
			for _, data in next, updateInfo.addedAuras do
				if(not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, data.auraInstanceID, filter)) then
					data = processData(element, unit, data, filter)
					if(data) then
						element.all[data.auraInstanceID] = data

						if((element.FilterAura or FilterAura) (element, unit, data, filter)) then
							element.active[data.auraInstanceID] = true
							aurasChanged = true
						end
					end
				end
			end
		end

		if(updateInfo.updatedAuraInstanceIDs) then
			for _, auraInstanceID in next, updateInfo.updatedAuraInstanceIDs do
				if(element.all[auraInstanceID]) then
					element.all[auraInstanceID] = processData(element, unit, C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraInstanceID), filter)

					if(element.active[auraInstanceID]) then
						element.active[auraInstanceID] = true
						aurasChanged = true
					end
				end
			end
		end

		if(updateInfo.removedAuraInstanceIDs) then
			for _, auraInstanceID in next, updateInfo.removedAuraInstanceIDs do
				if(element.all[auraInstanceID]) then
					element.all[auraInstanceID] = nil

					if(element.active[auraInstanceID]) then
						element.active[auraInstanceID] = nil
						aurasChanged = true
					end
				end
			end
		end
	end

	--[[ Callback: CustomAuras:PostUpdateInfo(unit, aurasChanged)
	Called after the aura update info has been updated and filtered, but before sorting.

	* self         - the CustomAuras element
	* unit         - the unit for which the update has been triggered (string)
	* aurasChanged - indicates whether the aura info has changed (boolean)
	--]]
	if(element.PostUpdateInfo) then
		element:PostUpdateInfo(unit, aurasChanged)
	end

	if(aurasChanged) then
		element.sorted = table.wipe(element.sorted or {})

		for auraInstanceID in next, element.active do
			table.insert(element.sorted, element.all[auraInstanceID])
		end

		--[[ Override: CustomAuras:SortAuras(a, b)
		Defines a custom sorting algorithm for ordering the auras.
		--]]
		table.sort(element.sorted, element.SortAuras or SortAuras)

		local numVisible = math.min(numAuras, #element.sorted)

		for i = 1, numVisible do
			updateAura(element, unit, element.sorted[i], i)
		end

		local visibleChanged = false

		if(numVisible ~= element.visibleButtons) then
			element.visibleButtons = numVisible
			visibleChanged = element.reanchorIfVisibleChanged
		end

		for i = numVisible + 1, #element do
			element[i]:Hide()
		end

		if(visibleChanged or element.createdButtons > element.anchoredButtons) then
			if(visibleChanged) then
				(element.SetPosition or SetPosition) (element, 1, numVisible)
			else
				(element.SetPosition or SetPosition) (element, element.anchoredButtons + 1, element.createdButtons)
				element.anchoredButtons = element.createdButtons
			end
		end

		--[[ Callback: CustomAuras:PostUpdate(unit)
		Called after the element has been updated.

		* self - the CustomAuras element
		* unit - the unit for which the update has been triggered (string)
		--]]
		if(element.PostUpdate) then element:PostUpdate(unit) end
	end
end

local function Update(self, event, unit, updateInfo)
	if(self.unit ~= unit) then return end

	UpdateCustomAuras(self, event, unit, updateInfo)

	if(event == 'ForceUpdate' or not event) then
		local element = self.CustomAuras
		if(element) then
			(element.SetPosition or SetPosition) (element, 1, element.createdButtons)
		end
	end
end

local function Path(self, ...)
	--[[ Override: CustomAuras.Override(self, event, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.CustomAuras.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.CustomAuras
	if(element) then
		element.__owner = self
		element.__restricted = not pcall(self.GetCenter, self)
		element.ForceUpdate = ForceUpdate

		element.createdButtons = element.createdButtons or 0
		element.anchoredButtons = 0
		element.visibleButtons = 0
		element.tooltipAnchor = element.tooltipAnchor or 'ANCHOR_BOTTOMRIGHT'
		element.needFullUpdate = true

		if(not element.dispelColorCurve) then
			element.dispelColorCurve = C_CurveUtil.CreateColorCurve()
			element.dispelColorCurve:SetType(Enum.LuaCurveType.Step)
			for _, dispelIndex in next, oUF.Enum.DispelType do
				if(self.colors.dispel[dispelIndex]) then
					element.dispelColorCurve:AddPoint(dispelIndex, self.colors.dispel[dispelIndex])
				end
			end
		end

		self:RegisterEvent('UNIT_AURA', Path)

		element:Show()

		return true
	end
end

local function Disable(self)
	local element = self.CustomAuras
	if(element) then
		element:Hide()

		self:UnregisterEvent('UNIT_AURA', Path)
	end
end

oUF:AddElement('CustomAuras', Path, Enable, Disable)
