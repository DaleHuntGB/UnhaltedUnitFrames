local _, UUF = ...
local oUF = UUF.oUF

function UUF:CreateUnitResurrectIndicator(unitFrame, unit)
    if not unitFrame then return end
    
    local ResurrectDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].ResurrectIndicator
    if not ResurrectDB or not ResurrectDB.Enabled then return end
    
    local frameName = unitFrame:GetName() or UUF:FetchFrameName(unit)
    local resurrectIndicator = CreateFrame("Frame", frameName .. "_ResurrectIndicator", unitFrame)
    
    resurrectIndicator:SetSize(ResurrectDB.Size, ResurrectDB.Size)
    UUF:QueueOrRun(function()
        resurrectIndicator:SetPoint(ResurrectDB.Layout[1], unitFrame, ResurrectDB.Layout[2], ResurrectDB.Layout[3], ResurrectDB.Layout[4])
    end)
    resurrectIndicator:SetFrameStrata(ResurrectDB.FrameStrata)
    
    local resurrectIcon = resurrectIndicator:CreateTexture(nil, "OVERLAY")
    resurrectIcon:SetAllPoints(resurrectIndicator)
    resurrectIcon:SetTexture("Interface\\Icons\\spell_nature_reincarnation")
    resurrectIcon:Hide()
    
    unitFrame.ResurrectIndicator = resurrectIndicator
    unitFrame.ResurrectIndicator.Icon = resurrectIcon
    
    if unitFrame:IsElementEnabled("ResurrectIndicator") then
        unitFrame:EnableElement("ResurrectIndicator")
    end
end

function UUF:UpdateUnitResurrectIndicator(unitFrame, unit)
    if not unitFrame then return end
    
    local ResurrectDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].ResurrectIndicator
    if not ResurrectDB or not ResurrectDB.Enabled then
        if unitFrame.ResurrectIndicator then
            UUF:QueueOrRun(function()
                unitFrame.ResurrectIndicator:Hide()
            end)
        end
        return
    end
    
    if not unitFrame.ResurrectIndicator then
        UUF:CreateUnitResurrectIndicator(unitFrame, unit)
    end
    
    if unitFrame.ResurrectIndicator then
        UUF:QueueOrRun(function()
            unitFrame.ResurrectIndicator:SetSize(ResurrectDB.Size, ResurrectDB.Size)
            UUF:SetPointIfChanged(unitFrame.ResurrectIndicator, ResurrectDB.Layout[1], unitFrame, ResurrectDB.Layout[2], ResurrectDB.Layout[3], ResurrectDB.Layout[4])
            unitFrame.ResurrectIndicator:SetFrameStrata(ResurrectDB.FrameStrata)
            unitFrame.ResurrectIndicator:Show()
        end)
    end
end
