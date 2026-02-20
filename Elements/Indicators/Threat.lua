local _, UUF = ...
local oUF = UUF.oUF

function UUF:CreateUnitThreatIndicator(unitFrame, unit)
    if not unitFrame then return end
    
    local ThreatDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].ThreatIndicator
    if not ThreatDB or not ThreatDB.Enabled then return end
    
    local frameName = unitFrame:GetName() or UUF:FetchFrameName(unit)
    local threatIndicator = CreateFrame("Frame", frameName .. "_ThreatIndicator", unitFrame)
    
    threatIndicator:SetSize(ThreatDB.Size, ThreatDB.Size)
    UUF:QueueOrRun(function()
        threatIndicator:SetPoint(ThreatDB.Layout[1], unitFrame, ThreatDB.Layout[2], ThreatDB.Layout[3], ThreatDB.Layout[4])
    end)
    threatIndicator:SetFrameStrata(ThreatDB.FrameStrata)
    
    local threatTexture = threatIndicator:CreateTexture(nil, "OVERLAY")
    threatTexture:SetAllPoints(threatIndicator)
    threatTexture:SetTexture("Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\GlowEffect")
    threatTexture:SetVertexColor(ThreatDB.Colour[1], ThreatDB.Colour[2], ThreatDB.Colour[3], ThreatDB.Opacity)
    threatTexture:Hide()
    
    unitFrame.ThreatIndicator = threatIndicator
    unitFrame.ThreatIndicator.Texture = threatTexture
    
    if unitFrame:IsElementEnabled("ThreatIndicator") then
        unitFrame:EnableElement("ThreatIndicator")
    end
end

function UUF:UpdateUnitThreatIndicator(unitFrame, unit)
    if not unitFrame then return end
    
    local ThreatDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].ThreatIndicator
    if not ThreatDB or not ThreatDB.Enabled then
        if unitFrame.ThreatIndicator then
            UUF:QueueOrRun(function()
                unitFrame.ThreatIndicator:Hide()
            end)
        end
        return
    end
    
    if not unitFrame.ThreatIndicator then
        UUF:CreateUnitThreatIndicator(unitFrame, unit)
    end
    
    if unitFrame.ThreatIndicator then
        UUF:QueueOrRun(function()
            unitFrame.ThreatIndicator:SetSize(ThreatDB.Size, ThreatDB.Size)
            UUF:SetPointIfChanged(unitFrame.ThreatIndicator, ThreatDB.Layout[1], unitFrame, ThreatDB.Layout[2], ThreatDB.Layout[3], ThreatDB.Layout[4])
            unitFrame.ThreatIndicator:SetFrameStrata(ThreatDB.FrameStrata)
            unitFrame.ThreatIndicator.Texture:SetVertexColor(ThreatDB.Colour[1], ThreatDB.Colour[2], ThreatDB.Colour[3], ThreatDB.Opacity)
            unitFrame.ThreatIndicator:Show()
        end)
    end
end
