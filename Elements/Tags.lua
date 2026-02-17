local _, UUF = ...

local function CreateUnitTag(unitFrame, unit, tagDB)
    local GeneralDB = UUF.db.profile.General
    local TagDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Tags[tagDB]
    local frameName = unitFrame:GetName() or UUF:FetchFrameName(unit)

    if not unitFrame.Tags[tagDB] then
        unitFrame.Tags[tagDB] = unitFrame.HighLevelContainer:CreateFontString(frameName .. "_" .. tagDB, "ARTWORK")
        unitFrame.Tags[tagDB]:SetFont(UUF.Media.Font, TagDB.FontSize, GeneralDB.Fonts.FontFlag)
        unitFrame.Tags[tagDB]:SetVertexColor(TagDB.Colour[1], TagDB.Colour[2], TagDB.Colour[3], 1)
        if GeneralDB.Fonts.Shadow.Enabled then
            unitFrame.Tags[tagDB]:SetShadowColor(GeneralDB.Fonts.Shadow.Colour[1], GeneralDB.Fonts.Shadow.Colour[2], GeneralDB.Fonts.Shadow.Colour[3], GeneralDB.Fonts.Shadow.Colour[4])
            unitFrame.Tags[tagDB]:SetShadowOffset(GeneralDB.Fonts.Shadow.XPos, GeneralDB.Fonts.Shadow.YPos)
        else
            unitFrame.Tags[tagDB]:SetShadowColor(0, 0, 0, 0)
            unitFrame.Tags[tagDB]:SetShadowOffset(0, 0)
        end
        UUF:QueueOrRun(function() unitFrame.Tags[tagDB]:SetPoint(TagDB.Layout[1], unitFrame.HighLevelContainer, TagDB.Layout[2], TagDB.Layout[3], TagDB.Layout[4]) end)
        unitFrame.Tags[tagDB]:SetJustifyH(UUF:SetJustification(TagDB.Layout[1]))
        unitFrame:Tag(unitFrame.Tags[tagDB], TagDB.Tag)
    end
end

function UUF:UpdateUnitTag(unitFrame, unit, tagDB)
    local GeneralDB = UUF.db.profile.General
    local normalizedUnit = UUF:GetNormalizedUnit(unit)
    local TagDB = UUF.db.profile.Units[normalizedUnit].Tags[tagDB]

    -- Skip oUF tag updates when in test mode for multi-frame units showing fake data
    -- For party frames, only skip if we're NOT in a party (showing fake data)
    local inTestMode = (normalizedUnit == "boss" and UUF.BOSS_TEST_MODE) or 
                       (normalizedUnit == "party" and UUF.PARTY_TEST_MODE and not (IsInGroup() and not IsInRaid()))

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
        UUF:QueueOrRun(function()
            unitFrame.Tags[tagDB]:ClearAllPoints()
            unitFrame.Tags[tagDB]:SetPoint(TagDB.Layout[1], unitFrame.HighLevelContainer, TagDB.Layout[2], TagDB.Layout[3], TagDB.Layout[4])
        end)
        unitFrame.Tags[tagDB]:SetJustifyH(UUF:SetJustification(TagDB.Layout[1]))
        if not inTestMode then
            unitFrame:Tag(unitFrame.Tags[tagDB], TagDB.Tag)
            unitFrame.Tags[tagDB]:UpdateTag()
        end
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
        local UnitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)]
        if unit == "boss" then
            for i = 1, UUF.MAX_BOSS_FRAMES do
                local bossFrame = UUF["BOSS"..i]
                if bossFrame then
                    for tagName in pairs(UnitDB.Tags) do
                        UUF:UpdateUnitTag(bossFrame, "boss"..i, tagName)
                    end
                end
            end
        elseif unit == "party" then
            for i = 1, UUF.MAX_PARTY_MEMBERS do
                local partyFrame = UUF["PARTY"..i]
                if partyFrame then
                    for tagName in pairs(UnitDB.Tags) do
                        UUF:UpdateUnitTag(partyFrame, "party"..i, tagName)
                    end
                end
            end
        else
            local frame = UUF[unit:upper()]
            if frame then
                for tagName in pairs(UnitDB.Tags) do
                    UUF:UpdateUnitTag(frame, unit, tagName)
                end
            end
        end
    end
end

function UUF:UpdateUnitTagsForUnit(unit)
    if not unit then return end
    UUF.SEPARATOR = UUF.db.profile.General.Separator or "||"
    UUF.TOT_SEPARATOR = UUF.db.profile.General.ToTSeparator or "»"

    local normalizedUnit = UUF:GetNormalizedUnit(unit)
    local unitDB = UUF.db.profile.Units[normalizedUnit]
    if not unitDB then return end

    local frame = UUF[unit:upper()]
    if not frame then return end

    for tagName in pairs(unitDB.Tags) do
        UUF:UpdateUnitTag(frame, unit, tagName)
    end
end


