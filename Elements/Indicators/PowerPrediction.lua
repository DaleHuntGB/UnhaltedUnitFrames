local _, UUF = ...
local oUF = UUF.oUF

function UUF:CreateUnitPowerPrediction(unitFrame, unit)
    if not unitFrame then return end
    
    local PowerPredDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].PowerPrediction
    if not PowerPredDB or not PowerPredDB.Enabled then return end
    
    local frameName = unitFrame:GetName() or UUF:FetchFrameName(unit)
    local powerPrediction = CreateFrame("StatusBar", frameName .. "_PowerPrediction", unitFrame)
    
    powerPrediction:SetSize(PowerPredDB.Width, PowerPredDB.Height)
    UUF:QueueOrRun(function()
        powerPrediction:SetPoint(PowerPredDB.Layout[1], unitFrame, PowerPredDB.Layout[2], PowerPredDB.Layout[3], PowerPredDB.Layout[4])
    end)
    powerPrediction:SetFrameStrata(PowerPredDB.FrameStrata)
    
    local texture = UUF.Media.PowerPrediction or "Interface\\TargetingFrame\\UI-StatusBar"
    powerPrediction:SetStatusBarTexture(texture)
    
    local bg = powerPrediction:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(powerPrediction)
    bg:SetTexture(UUF.Media.Background or "Interface\\ChatFrame\\ChatFrameBackground")
    bg:SetVertexColor(0.1, 0.1, 0.1, PowerPredDB.BackgroundOpacity or 0.5)
    
    powerPrediction:SetMinMaxValues(0, 100)
    powerPrediction:SetValue(0)
    
    local color = PowerPredDB.Colour or {1, 1, 0}
    powerPrediction:SetStatusBarColor(color[1], color[2], color[3], PowerPredDB.Opacity or 0.7)
    
    unitFrame.PowerPrediction = powerPrediction
    unitFrame.PowerPrediction.Background = bg
    
    if unitFrame:IsElementEnabled("PowerPrediction") then
        unitFrame:EnableElement("PowerPrediction")
    end
end

function UUF:UpdateUnitPowerPrediction(unitFrame, unit)
    if not unitFrame then return end
    
    local PowerPredDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].PowerPrediction
    if not PowerPredDB or not PowerPredDB.Enabled then
        if unitFrame.PowerPrediction then
            UUF:QueueOrRun(function()
                unitFrame.PowerPrediction:Hide()
            end)
        end
        return
    end
    
    if not unitFrame.PowerPrediction then
        UUF:CreateUnitPowerPrediction(unitFrame, unit)
    end
    
    if unitFrame.PowerPrediction then
        UUF:QueueOrRun(function()
            unitFrame.PowerPrediction:SetSize(PowerPredDB.Width, PowerPredDB.Height)
            UUF:SetPointIfChanged(unitFrame.PowerPrediction, PowerPredDB.Layout[1], unitFrame, PowerPredDB.Layout[2], PowerPredDB.Layout[3], PowerPredDB.Layout[4])
            unitFrame.PowerPrediction:SetFrameStrata(PowerPredDB.FrameStrata)
            
            local color = PowerPredDB.Colour or {1, 1, 0}
            unitFrame.PowerPrediction:SetStatusBarColor(color[1], color[2], color[3], PowerPredDB.Opacity or 0.7)
            unitFrame.PowerPrediction.Background:SetVertexColor(0.1, 0.1, 0.1, PowerPredDB.BackgroundOpacity or 0.5)
            
            unitFrame.PowerPrediction:Show()
        end)
    end
end
