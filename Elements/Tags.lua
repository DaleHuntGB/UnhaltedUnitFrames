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
        unitFrame:Tag(unitFrame.Tags[tagDB], TagDB.Tag)
    end
    unitFrame.Tags[tagDB]:UpdateTag()
end

function UUF:CreateUnitTags(unitFrame, unit)
    unitFrame.Tags = unitFrame.Tags or {}
    for tagName, _ in pairs(UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Tags) do
        CreateUnitTag(unitFrame, unit, tagName)
    end
end

function UUF:UpdateUnitTags()
    UUF.SEPARATOR = UUF.db.profile.General.Separator or "||"
    UUF.TOT_SEPARATOR = UUF.db.profile.General.ToTSeparator or "»"
    for unit, _ in pairs(UUF.db.profile.Units) do
        for tagName, _ in pairs(UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Tags) do
            if UUF[unit:upper()] then
                UUF:UpdateUnitTag(UUF[unit:upper()], unit, tagName)
            end
        end
    end
end

