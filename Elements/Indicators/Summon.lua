local _, UUF = ...
local oUF = UUF.oUF

function UUF:CreateUnitSummonIndicator(unitFrame, unit)
    if not unitFrame then return end
    
    local SummonDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].SummonIndicator
    if not SummonDB or not SummonDB.Enabled then return end
    
    local frameName = unitFrame:GetName() or UUF:FetchFrameName(unit)
    local summonIndicator = CreateFrame("Frame", frameName .. "_SummonIndicator", unitFrame)
    
    summonIndicator:SetSize(SummonDB.Size, SummonDB.Size)
    UUF:QueueOrRun(function()
        summonIndicator:SetPoint(SummonDB.Layout[1], unitFrame, SummonDB.Layout[2], SummonDB.Layout[3], SummonDB.Layout[4])
    end)
    summonIndicator:SetFrameStrata(SummonDB.FrameStrata)
    
    local summonIcon = summonIndicator:CreateTexture(nil, "OVERLAY")
    summonIcon:SetAllPoints(summonIndicator)
    summonIcon:SetTexture("Interface\\Icons\\spell_nature_summonelemental")
    summonIcon:Hide()
    
    unitFrame.SummonIndicator = summonIndicator
    unitFrame.SummonIndicator.Icon = summonIcon
    
    if unitFrame:IsElementEnabled("SummonIndicator") then
        unitFrame:EnableElement("SummonIndicator")
    end
end

function UUF:UpdateUnitSummonIndicator(unitFrame, unit)
    if not unitFrame then return end
    
    local SummonDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].SummonIndicator
    if not SummonDB or not SummonDB.Enabled then
        if unitFrame.SummonIndicator then
            UUF:QueueOrRun(function()
                unitFrame.SummonIndicator:Hide()
            end)
        end
        return
    end
    
    if not unitFrame.SummonIndicator then
        UUF:CreateUnitSummonIndicator(unitFrame, unit)
    end
    
    if unitFrame.SummonIndicator then
        UUF:QueueOrRun(function()
            unitFrame.SummonIndicator:SetSize(SummonDB.Size, SummonDB.Size)
            UUF:SetPointIfChanged(unitFrame.SummonIndicator, SummonDB.Layout[1], unitFrame, SummonDB.Layout[2], SummonDB.Layout[3], SummonDB.Layout[4])
            unitFrame.SummonIndicator:SetFrameStrata(SummonDB.FrameStrata)
            unitFrame.SummonIndicator:Show()
        end)
    end
end
