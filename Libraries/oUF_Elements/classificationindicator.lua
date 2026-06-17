--[[
# Element: Classification Indicator

Handles the visibility and updating of an indicator based on the unit's classification.

## Widget

ClassificationIndicator - A `Texture` used to display unit classification.

## Notes

This element updates by changing the texture.

## Options

.useAtlasSize - Makes the element use preprogrammed atlas' size instead of its set dimensions (boolean)

## Examples

    -- Position and size
    local ClassificationIndicator = self:CreateTexture(nil, 'OVERLAY')
    ClassificationIndicator:SetSize(24, 24)
    ClassificationIndicator:SetPoint('CENTER')

    -- Register it with oUF
    self.ClassificationIndicator = ClassificationIndicator
--]]

local _, ns = ...
local oUF = ns.oUF

local ICONS = {
	elite = 'nameplates-icon-elite-gold',
	worldboss = 'nameplates-icon-elite-gold',
	rareelite = 'nameplates-icon-elite-silver',
	rare = 'nameplates-icon-elite-silver',
}

local function Update(self, event, unit)
	if(unit ~= self.unit) then return end

	local element = self.ClassificationIndicator

	--[[ Callback: ClassificationIndicator:PreUpdate(unit)
	Called before the element has been updated.

	* self - the ClassificationIndicator element
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PreUpdate) then
		element:PreUpdate(unit)
	end

	local classification = UnitClassification(unit)
	local icon = ICONS[classification]
	if(icon) then
		element:SetAtlas(icon, element.useAtlasSize)
		element:Show()
	else
		element:Hide()
	end

	--[[ Callback: ClassificationIndicator:PostUpdate(unit, classification)
	Called after the element has been updated.

	* self           - the ClassificationIndicator element
	* unit           - the unit for which the update has been triggered (string)
	* classification - the classification of the unit (string)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(unit, classification)
	end
end

local function Path(self, ...)
	--[[ Override: ClassificationIndicator.Override(self, event, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.ClassificationIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.ClassificationIndicator
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_CLASSIFICATION_CHANGED', Path)

		return true
	end
end

local function Disable(self)
	local element = self.ClassificationIndicator
	if(element) then
		element:Hide()

		self:UnregisterEvent('UNIT_CLASSIFICATION_CHANGED', Path)
	end
end

oUF:AddElement('ClassificationIndicator', Path, Enable, Disable)
