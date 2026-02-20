local _, UUF = ...
local oUF = UUF.oUF

function UUF:CreateUnitStagger(unitFrame, unit)
    if unit ~= "player" then return end
    
    local StaggerDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Stagger
    if not StaggerDB or not StaggerDB.Enabled then return end
    
    local frameName = unitFrame:GetName() or UUF:FetchFrameName(unit)
    local staggerBar = CreateFrame("StatusBar", frameName .. "_StaggerBar", unitFrame)
    
    staggerBar:SetSize(StaggerDB.Width, StaggerDB.Height)
    UUF:QueueOrRun(function()
        staggerBar:SetPoint(StaggerDB.Layout[1], unitFrame, StaggerDB.Layout[2], StaggerDB.Layout[3], StaggerDB.Layout[4])
    end)
    staggerBar:SetStatusBarTexture(UUF.Media.Foreground)
    staggerBar:SetFrameStrata(StaggerDB.FrameStrata)
    
    staggerBar:SetStatusBarColor(StaggerDB.Foreground[1], StaggerDB.Foreground[2], StaggerDB.Foreground[3], StaggerDB.ForegroundOpacity)
    
    local staggerBackground = staggerBar:CreateTexture(nil, "BACKGROUND")
    staggerBackground:SetAllPoints(staggerBar)
    staggerBackground:SetTexture(UUF.Media.Background)
    staggerBackground:SetVertexColor(StaggerDB.Background[1], StaggerDB.Background[2], StaggerDB.Background[3], StaggerDB.BackgroundOpacity)
    
    unitFrame.Stagger = staggerBar
    
    if unitFrame:IsElementEnabled("Stagger") then
        unitFrame:EnableElement("Stagger")
    end
end

function UUF:UpdateUnitStagger(unitFrame, unit)
    if unit ~= "player" then return end
    if not unitFrame then return end
    
    local StaggerDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Stagger
    if not StaggerDB or not StaggerDB.Enabled then
        if unitFrame.Stagger then
            UUF:QueueOrRun(function()
                unitFrame.Stagger:Hide()
            end)
        end
        return
    end
    
    if not unitFrame.Stagger then
        UUF:CreateUnitStagger(unitFrame, unit)
    end
    
    if unitFrame.Stagger then
        UUF:QueueOrRun(function()
            unitFrame.Stagger:SetSize(StaggerDB.Width, StaggerDB.Height)
            UUF:SetPointIfChanged(unitFrame.Stagger, StaggerDB.Layout[1], unitFrame, StaggerDB.Layout[2], StaggerDB.Layout[3], StaggerDB.Layout[4])
            unitFrame.Stagger:SetStatusBarTexture(UUF.Media.Foreground)
            unitFrame.Stagger:SetFrameStrata(StaggerDB.FrameStrata)
            unitFrame.Stagger:SetStatusBarColor(StaggerDB.Foreground[1], StaggerDB.Foreground[2], StaggerDB.Foreground[3], StaggerDB.ForegroundOpacity)
            unitFrame.Stagger:Show()
        end)
    end
end
