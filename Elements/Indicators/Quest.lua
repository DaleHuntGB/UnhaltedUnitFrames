local _, UUF = ...

function UUF:CreateUnitQuestIndicator(unitFrame, unit)
    local QuestIndicatorDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Quest

    local QuestIndicator = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit) .. "_QuestIndicator", "OVERLAY")
    QuestIndicator:SetSize(QuestIndicatorDB.Size, QuestIndicatorDB.Size)
    QuestIndicator:SetPoint(QuestIndicatorDB.Layout[1], unitFrame.HighLevelContainer, QuestIndicatorDB.Layout[2], QuestIndicatorDB.Layout[3], QuestIndicatorDB.Layout[4])

    if QuestIndicatorDB.Enabled then
        unitFrame.QuestUnitIndicator = QuestIndicator
        unitFrame.QuestUnitIndicator:Show()
    else
        if unitFrame:IsElementEnabled("QuestUnitIndicator") then unitFrame:DisableElement("QuestUnitIndicator") end
        QuestIndicator:Hide()
    end

    return QuestIndicator
end

function UUF:UpdateUnitQuestIndicator(unitFrame, unit)
    local QuestIndicatorDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Quest

    if QuestIndicatorDB.Enabled then
        unitFrame.QuestUnitIndicator = unitFrame.QuestUnitIndicator or UUF:CreateUnitQuestIndicator(unitFrame, unit)

        if not unitFrame:IsElementEnabled("QuestUnitIndicator") then unitFrame:EnableElement("QuestUnitIndicator") end

        if unitFrame.QuestUnitIndicator then
            unitFrame.QuestUnitIndicator:ClearAllPoints()
            unitFrame.QuestUnitIndicator:SetSize(QuestIndicatorDB.Size, QuestIndicatorDB.Size)
            unitFrame.QuestUnitIndicator:SetPoint(QuestIndicatorDB.Layout[1], unitFrame.HighLevelContainer, QuestIndicatorDB.Layout[2], QuestIndicatorDB.Layout[3], QuestIndicatorDB.Layout[4])
            unitFrame.QuestUnitIndicator:ForceUpdate()
        end
    else
        if not unitFrame.QuestUnitIndicator then return end
        if unitFrame:IsElementEnabled("QuestUnitIndicator") then unitFrame:DisableElement("QuestUnitIndicator") end
        if unitFrame.QuestUnitIndicator then
            unitFrame.QuestUnitIndicator:Hide()
            unitFrame.QuestUnitIndicator = nil
        end
    end
end
