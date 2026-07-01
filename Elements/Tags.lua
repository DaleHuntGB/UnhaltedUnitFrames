local _, UUF = ...

local function CreateUnitTag(unitFrame, unit, tagDB)
    local GeneralDB = UUF.db.profile.General
    local TagDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Tags[tagDB]

    if not unitFrame.Tags[tagDB] then
        unitFrame.Tags[tagDB] = unitFrame.HighLevelContainer:CreateFontString(UUF:FetchFrameName(unit) .. "_" .. tagDB, "ARTWORK")
        unitFrame.Tags[tagDB]:SetFont(UUF.Media.Font, TagDB.FontSize, GeneralDB.Fonts.FontFlag)
        unitFrame.Tags[tagDB]:SetVertexColor(TagDB.Colour[1], TagDB.Colour[2], TagDB.Colour[3], 1)
        if GeneralDB.Fonts.Shadow.Enabled then
            unitFrame.Tags[tagDB]:SetShadowColor(GeneralDB.Fonts.Shadow.Colour[1], GeneralDB.Fonts.Shadow.Colour[2], GeneralDB.Fonts.Shadow.Colour[3], GeneralDB.Fonts.Shadow.Colour[4])
            unitFrame.Tags[tagDB]:SetShadowOffset(GeneralDB.Fonts.Shadow.XPos, GeneralDB.Fonts.Shadow.YPos)
        else
            unitFrame.Tags[tagDB]:SetShadowColor(0, 0, 0, 0)
            unitFrame.Tags[tagDB]:SetShadowOffset(0, 0)
        end
        unitFrame.Tags[tagDB]:SetPoint(TagDB.Layout[1], unitFrame.HighLevelContainer, TagDB.Layout[2], TagDB.Layout[3], TagDB.Layout[4])
        unitFrame.Tags[tagDB]:SetJustifyH(UUF:SetJustification(TagDB.Layout[1]))
        if TagDB.Layout[1] == "TOPLEFT" or TagDB.Layout[1] == "TOP" or TagDB.Layout[1] == "TOPRIGHT" then
            unitFrame.Tags[tagDB]:SetJustifyV("TOP")
        elseif TagDB.Layout[1] == "BOTTOMLEFT" or TagDB.Layout[1] == "BOTTOM" or TagDB.Layout[1] == "BOTTOMRIGHT" then
            unitFrame.Tags[tagDB]:SetJustifyV("BOTTOM")
        else
            unitFrame.Tags[tagDB]:SetJustifyV("MIDDLE")
        end
        unitFrame:Tag(unitFrame.Tags[tagDB], TagDB.Tag)
    end
end

function UUF:UpdateUnitTag(unitFrame, unit, tagDB)
    local GeneralDB = UUF.db.profile.General
    local TagDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Tags[tagDB]

    if unitFrame.Tags[tagDB] then
        unitFrame.Tags[tagDB]:SetFont(UUF.Media.Font, TagDB.FontSize, GeneralDB.Fonts.FontFlag)
        unitFrame.Tags[tagDB]:SetVertexColor(TagDB.Colour[1], TagDB.Colour[2], TagDB.Colour[3], 1)
        if GeneralDB.Fonts.Shadow.Enabled then
            unitFrame.Tags[tagDB]:SetShadowColor(GeneralDB.Fonts.Shadow.Colour[1], GeneralDB.Fonts.Shadow.Colour[2], GeneralDB.Fonts.Shadow.Colour[3], GeneralDB.Fonts.Shadow.Colour[4])
            unitFrame.Tags[tagDB]:SetShadowOffset(GeneralDB.Fonts.Shadow.XPos, GeneralDB.Fonts.Shadow.YPos)
        else
            unitFrame.Tags[tagDB]:SetShadowColor(0, 0, 0, 0)
            unitFrame.Tags[tagDB]:SetShadowOffset(0, 0)
        end
        unitFrame.Tags[tagDB]:ClearAllPoints()
        unitFrame.Tags[tagDB]:SetPoint(TagDB.Layout[1], unitFrame.HighLevelContainer, TagDB.Layout[2], TagDB.Layout[3], TagDB.Layout[4])
        unitFrame.Tags[tagDB]:SetJustifyH(UUF:SetJustification(TagDB.Layout[1]))
        if TagDB.Layout[1] == "TOPLEFT" or TagDB.Layout[1] == "TOP" or TagDB.Layout[1] == "TOPRIGHT" then
            unitFrame.Tags[tagDB]:SetJustifyV("TOP")
        elseif TagDB.Layout[1] == "BOTTOMLEFT" or TagDB.Layout[1] == "BOTTOM" or TagDB.Layout[1] == "BOTTOMRIGHT" then
            unitFrame.Tags[tagDB]:SetJustifyV("BOTTOM")
        else
            unitFrame.Tags[tagDB]:SetJustifyV("MIDDLE")
        end
        unitFrame:Tag(unitFrame.Tags[tagDB], TagDB.Tag)
    end
    unitFrame.Tags[tagDB]:UpdateTag()
    local tagText = unitFrame.Tags[tagDB]:GetText()
    unitFrame.Tags[tagDB]:SetText("")
    unitFrame.Tags[tagDB]:SetText(tagText or "")
end

function UUF:CreateUnitTags(unitFrame, unit)
    unitFrame.Tags = unitFrame.Tags or {}
    for tagName, _ in pairs(UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Tags) do
        CreateUnitTag(unitFrame, unit, tagName)
    end
end

function UUF:UpdateUnitTags(unit, tagName)
	if not unit then return end
	local UnitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)]
	if not UnitDB or not UnitDB.Tags then return end
	UUF.SEPARATOR = UUF.db.profile.General.Separator or "||"
	UUF.TOT_SEPARATOR = UUF.db.profile.General.ToTSeparator or "»"

	local function UpdateFrameTags(unitFrame, frameUnit)
		if not unitFrame then return end
		if tagName then
			UUF:UpdateUnitTag(unitFrame, frameUnit, tagName)
		else
			for configuredTag in pairs(UnitDB.Tags) do UUF:UpdateUnitTag(unitFrame, frameUnit, configuredTag) end
		end
	end

	if unit == "boss" then
		for i = 1, UUF.MAX_BOSS_FRAMES do UpdateFrameTags(UUF["BOSS" .. i], "boss" .. i) end
	elseif unit == "party" then
		for i = 1, UUF.MAX_PARTY_FRAMES do UpdateFrameTags(UUF["PARTY" .. i], "party" .. i) end
		UpdateFrameTags(UUF.PARTYPLAYER, "partyplayer")
	elseif unit == "raid" then
		UUF:ForEachRaidFrame(UpdateFrameTags, true, UUF.RAID_TEST_MODE)
	else
		UpdateFrameTags(UUF[unit:upper()], unit)
	end
end
