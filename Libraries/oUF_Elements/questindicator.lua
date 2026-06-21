local _, ns = ...
local oUF = ns.oUF

local function Update(self, event, unit)
	if unit and unit ~= self.unit then return end

	local element = self.QuestUnitIndicator
	if element.PreUpdate then element:PreUpdate() end

	local isQuestUnit = UnitIsQuestBoss(self.unit) or C_QuestLog.UnitIsRelatedToActiveQuest(self.unit)
	element:SetShown(isQuestUnit)

	if element.PostUpdate then return element:PostUpdate(isQuestUnit) end
end

local function Path(self, ...)
	return (self.QuestUnitIndicator.Override or Update)(self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function Enable(self)
	local element = self.QuestUnitIndicator
	if element then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent("QUEST_LOG_UPDATE", Path, true)
		self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED", Path)

		if element:IsObjectType("Texture") and not element:GetTexture() then
			element:SetTexture([[Interface\TargetingFrame\PortraitQuestBadge]])
		end

		return true
	end
end

local function Disable(self)
	local element = self.QuestUnitIndicator
	if element then
		element:Hide()

		self:UnregisterEvent("QUEST_LOG_UPDATE", Path)
		self:UnregisterEvent("UNIT_CLASSIFICATION_CHANGED", Path)
	end
end

oUF:AddElement("QuestUnitIndicator", Path, Enable, Disable)
