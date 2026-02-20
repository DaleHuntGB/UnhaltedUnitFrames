local _, UUF = ...
local oUF = UUF.oUF

function UUF:CreateUnitQuestIndicator(unitFrame, unit)
    if not unitFrame then return end
    
    local QuestDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].QuestIndicator
    if not QuestDB or not QuestDB.Enabled then return end
    
    local frameName = unitFrame:GetName() or UUF:FetchFrameName(unit)
    local questIndicator = CreateFrame("Frame", frameName .. "_QuestIndicator", unitFrame)
    
    questIndicator:SetSize(QuestDB.Size, QuestDB.Size)
    UUF:QueueOrRun(function()
        questIndicator:SetPoint(QuestDB.Layout[1], unitFrame, QuestDB.Layout[2], QuestDB.Layout[3], QuestDB.Layout[4])
    end)
    questIndicator:SetFrameStrata(QuestDB.FrameStrata)
    
    local questIcon = questIndicator:CreateTexture(nil, "OVERLAY")
    questIcon:SetAllPoints(questIndicator)
    questIcon:SetTexture("Interface\\Icons\\Quest")
    questIcon:Hide()
    
    local questBorder = questIndicator:CreateTexture(nil, "BORDER")
    questBorder:SetAllPoints(questIndicator)
    questBorder:SetTexture("Interface\\Icons\\UI-QuestFrame-Border")
    questBorder:Hide()
    
    unitFrame.QuestIndicator = questIndicator
    unitFrame.QuestIndicator.Icon = questIcon
    unitFrame.QuestIndicator.Border = questBorder
    
    if unitFrame:IsElementEnabled("QuestIndicator") then
        unitFrame:EnableElement("QuestIndicator")
    end
end

function UUF:UpdateUnitQuestIndicator(unitFrame, unit)
    if not unitFrame then return end
    
    local QuestDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].QuestIndicator
    if not QuestDB or not QuestDB.Enabled then
        if unitFrame.QuestIndicator then
            UUF:QueueOrRun(function()
                unitFrame.QuestIndicator:Hide()
            end)
        end
        return
    end
    
    if not unitFrame.QuestIndicator then
        UUF:CreateUnitQuestIndicator(unitFrame, unit)
    end
    
    if unitFrame.QuestIndicator then
        UUF:QueueOrRun(function()
            unitFrame.QuestIndicator:SetSize(QuestDB.Size, QuestDB.Size)
            UUF:SetPointIfChanged(unitFrame.QuestIndicator, QuestDB.Layout[1], unitFrame, QuestDB.Layout[2], QuestDB.Layout[3], QuestDB.Layout[4])
            unitFrame.QuestIndicator:SetFrameStrata(QuestDB.FrameStrata)
            unitFrame.QuestIndicator:Show()
        end)
    end
end
