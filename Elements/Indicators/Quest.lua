local _, UUF = ...

function UUF:CreateUnitQuestIndicator(unitFrame, unit)
    local QuestIndicatorDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Quest

    local QuestIndicator = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit) .. "_QuestIndicator", "OVERLAY")
    QuestIndicator:SetSize(QuestIndicatorDB.Size, QuestIndicatorDB.Size)
    QuestIndicator:SetPoint(QuestIndicatorDB.Layout[1], unitFrame.HighLevelContainer, QuestIndicatorDB.Layout[2], QuestIndicatorDB.Layout[3], QuestIndicatorDB.Layout[4])

    if QuestIndicatorDB.Enabled then
        unitFrame.QuestIndicator = QuestIndicator
        unitFrame.QuestIndicator:Show()
    else
        if unitFrame:IsElementEnabled("QuestIndicator") then unitFrame:DisableElement("QuestIndicator") end
        QuestIndicator:Hide()
    end

    return QuestIndicator
end

function UUF:UpdateUnitQuestIndicator(unitFrame, unit)
    local QuestIndicatorDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Quest

    if QuestIndicatorDB.Enabled then
        unitFrame.QuestIndicator = unitFrame.QuestIndicator or UUF:CreateUnitQuestIndicator(unitFrame, unit)

        if not unitFrame:IsElementEnabled("QuestIndicator") then unitFrame:EnableElement("QuestIndicator") end

        if unitFrame.QuestIndicator then
            unitFrame.QuestIndicator:ClearAllPoints()
            unitFrame.QuestIndicator:SetSize(QuestIndicatorDB.Size, QuestIndicatorDB.Size)
            unitFrame.QuestIndicator:SetPoint(QuestIndicatorDB.Layout[1], unitFrame.HighLevelContainer, QuestIndicatorDB.Layout[2], QuestIndicatorDB.Layout[3], QuestIndicatorDB.Layout[4])
            unitFrame.QuestIndicator:Show()
            unitFrame.QuestIndicator:ForceUpdate()
        end
    else
        if not unitFrame.QuestIndicator then return end
        if unitFrame:IsElementEnabled("QuestIndicator") then unitFrame:DisableElement("QuestIndicator") end
        if unitFrame.QuestIndicator then
            unitFrame.QuestIndicator:Hide()
            unitFrame.QuestIndicator = nil
        end
    end
end