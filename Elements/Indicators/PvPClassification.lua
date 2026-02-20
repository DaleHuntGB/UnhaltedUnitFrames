local _, UUF = ...
local oUF = UUF.oUF

function UUF:CreateUnitPvPClassificationIndicator(unitFrame, unit)
    if not unitFrame then return end
    
    local PvPDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].PvPClassification
    if not PvPDB or not PvPDB.Enabled then return end
    
    local frameName = unitFrame:GetName() or UUF:FetchFrameName(unit)
    local pvpIndicator = CreateFrame("Frame", frameName .. "_PvPClassification", unitFrame)
    
    pvpIndicator:SetSize(PvPDB.Size, PvPDB.Size)
    UUF:QueueOrRun(function()
        pvpIndicator:SetPoint(PvPDB.Layout[1], unitFrame, PvPDB.Layout[2], PvPDB.Layout[3], PvPDB.Layout[4])
    end)
    pvpIndicator:SetFrameStrata(PvPDB.FrameStrata)
    
    local pvpIcon = pvpIndicator:CreateTexture(nil, "OVERLAY")
    pvpIcon:SetAllPoints(pvpIndicator)
    pvpIcon:SetTexture("Interface\\Icons\\PvPCurrency-Honor-Alliance")
    pvpIcon:Hide()
    
    local pvpBadge = pvpIndicator:CreateTexture(nil, "BORDER")
    pvpBadge:SetAllPoints(pvpIndicator)
    pvpBadge:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
    pvpBadge:Hide()
    
    unitFrame.PvPClassification = pvpIndicator
    unitFrame.PvPClassification.Icon = pvpIcon
    unitFrame.PvPClassification.Badge = pvpBadge
    
    if unitFrame:IsElementEnabled("PvPClassification") then
        unitFrame:EnableElement("PvPClassification")
    end
end

function UUF:UpdateUnitPvPClassificationIndicator(unitFrame, unit)
    if not unitFrame then return end
    
    local PvPDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].PvPClassification
    if not PvPDB or not PvPDB.Enabled then
        if unitFrame.PvPClassification then
            UUF:QueueOrRun(function()
                unitFrame.PvPClassification:Hide()
            end)
        end
        return
    end
    
    if not unitFrame.PvPClassification then
        UUF:CreateUnitPvPClassificationIndicator(unitFrame, unit)
    end
    
    if unitFrame.PvPClassification then
        UUF:QueueOrRun(function()
            unitFrame.PvPClassification:SetSize(PvPDB.Size, PvPDB.Size)
            UUF:SetPointIfChanged(unitFrame.PvPClassification, PvPDB.Layout[1], unitFrame, PvPDB.Layout[2], PvPDB.Layout[3], PvPDB.Layout[4])
            unitFrame.PvPClassification:SetFrameStrata(PvPDB.FrameStrata)
            unitFrame.PvPClassification:Show()
        end)
    end
end
