local _, UUF = ...

local function UpdateClassificationTexture(ClassificationIndicator, _, classification)
	local ClassificationIndicatorDB = UUF.db.profile.Units.target.Indicators.Classification
	local ClassificationTextures = UUF.ClassificationTextures[ClassificationIndicatorDB.Texture] or UUF.ClassificationTextures.DEFAULT
	if ClassificationTextures[classification] then ClassificationIndicator:SetAtlas(ClassificationTextures[classification], false) end
end

function UUF:CreateUnitClassificationIndicator(unitFrame, unit)
	local ClassificationIndicatorDB = UUF.db.profile.Units.target.Indicators.Classification
	local ClassificationIndicator = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit) .. "_ClassificationIndicator", "OVERLAY")
	ClassificationIndicator:SetSize(ClassificationIndicatorDB.Size, ClassificationIndicatorDB.Size)
	ClassificationIndicator:SetPoint(ClassificationIndicatorDB.Layout[1], unitFrame.HighLevelContainer, ClassificationIndicatorDB.Layout[2], ClassificationIndicatorDB.Layout[3], ClassificationIndicatorDB.Layout[4])
	ClassificationIndicator.PostUpdate = UpdateClassificationTexture

	if ClassificationIndicatorDB.Enabled then
		unitFrame.ClassificationIndicator = ClassificationIndicator
	else
		ClassificationIndicator:Hide()
	end

	return ClassificationIndicator
end

function UUF:UpdateUnitClassificationIndicator(unitFrame, unit)
	local ClassificationIndicatorDB = UUF.db.profile.Units.target.Indicators.Classification

	if ClassificationIndicatorDB.Enabled then
		unitFrame.ClassificationIndicator = unitFrame.ClassificationIndicator or UUF:CreateUnitClassificationIndicator(unitFrame, unit)
		if not unitFrame:IsElementEnabled("ClassificationIndicator") then unitFrame:EnableElement("ClassificationIndicator") end

		unitFrame.ClassificationIndicator:ClearAllPoints()
		unitFrame.ClassificationIndicator:SetSize(ClassificationIndicatorDB.Size, ClassificationIndicatorDB.Size)
		unitFrame.ClassificationIndicator:SetPoint(ClassificationIndicatorDB.Layout[1], unitFrame.HighLevelContainer, ClassificationIndicatorDB.Layout[2], ClassificationIndicatorDB.Layout[3], ClassificationIndicatorDB.Layout[4])
		unitFrame.ClassificationIndicator:ForceUpdate()
	elseif unitFrame.ClassificationIndicator then
		if unitFrame:IsElementEnabled("ClassificationIndicator") then unitFrame:DisableElement("ClassificationIndicator") end
		unitFrame.ClassificationIndicator:Hide()
		unitFrame.ClassificationIndicator = nil
	end
end
