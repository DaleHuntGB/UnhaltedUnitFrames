local _, UUF = ...
local oUF = UUF.oUF

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
        unitFrame.Tags[tagDB].UUFTagString = TagDB.Tag
    end
end

function UUF:UpdateUnitTag(unitFrame, unit, tagDB)
    local GeneralDB = UUF.db.profile.General
    local TagDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Tags[tagDB]
    local tagFrame = unitFrame.Tags[tagDB]

    if not tagFrame then return end

    tagFrame:SetFont(UUF.Media.Font, TagDB.FontSize, GeneralDB.Fonts.FontFlag)
    tagFrame:SetVertexColor(TagDB.Colour[1], TagDB.Colour[2], TagDB.Colour[3], 1)
    if GeneralDB.Fonts.Shadow.Enabled then
        tagFrame:SetShadowColor(GeneralDB.Fonts.Shadow.Colour[1], GeneralDB.Fonts.Shadow.Colour[2], GeneralDB.Fonts.Shadow.Colour[3], GeneralDB.Fonts.Shadow.Colour[4])
        tagFrame:SetShadowOffset(GeneralDB.Fonts.Shadow.XPos, GeneralDB.Fonts.Shadow.YPos)
    else
        tagFrame:SetShadowColor(0, 0, 0, 0)
        tagFrame:SetShadowOffset(0, 0)
    end
    tagFrame:ClearAllPoints()
    tagFrame:SetPoint(TagDB.Layout[1], unitFrame.HighLevelContainer, TagDB.Layout[2], TagDB.Layout[3], TagDB.Layout[4])
    tagFrame:SetJustifyH(UUF:SetJustification(TagDB.Layout[1]))

    if tagFrame.UUFTagString ~= TagDB.Tag then
        unitFrame:Tag(tagFrame, TagDB.Tag)
        tagFrame.UUFTagString = TagDB.Tag
    end

    tagFrame:UpdateTag()
end

function UUF:UpdateUnitFrameTags(unitFrame, unit)
    if not unitFrame or not unitFrame.Tags or not unit then return end

    local tagsDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Tags
    if not tagsDB then return end

    for tagName in pairs(tagsDB) do
        UUF:UpdateUnitTag(unitFrame, unit, tagName)
    end
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
    for unit in pairs(UUF.db.profile.Units) do
        UUF:ForEachManagedUnitFrame(unit, function(unitFrame, actualUnit)
            UUF:UpdateUnitFrameTags(unitFrame, actualUnit)
        end)
    end
end

function UUF:RefreshLiveUnitTags(unit)
    local normalizedUnit = unit and UUF:GetNormalizedUnit(unit)
    if not normalizedUnit then return end

    for _, obj in next, oUF.objects do
        local actualUnit = obj.unit or (obj.GetAttribute and obj:GetAttribute("unit"))
        if actualUnit and UUF:GetNormalizedUnit(actualUnit) == normalizedUnit then
            UUF:UpdateUnitFrameTags(obj, actualUnit)
        end
    end
end
