local _, UUF = ...

function UUF:CreateUnitContainer(unitFrame, unit)
    local frameName = unitFrame:GetName() or UUF:FetchFrameName(unit)
    if not unitFrame.Container then
        unitFrame.Container = CreateFrame("Frame", frameName .. "_Container", unitFrame, "BackdropTemplate")
        unitFrame.Container:SetBackdrop(UUF.BACKDROP)
        unitFrame.Container:SetBackdropColor(0, 0, 0, 0)
        unitFrame.Container:SetBackdropBorderColor(0, 0, 0, 1)
        UUF:QueueOrRun(function() unitFrame.Container:SetAllPoints(unitFrame) end)

        if not unitFrame.HighLevelContainer then
            unitFrame.HighLevelContainer = CreateFrame("Frame", frameName .. "_HighLevelContainer", unitFrame)
            UUF:QueueOrRun(function()
                unitFrame.HighLevelContainer:SetPoint("TOPLEFT", unitFrame, "TOPLEFT", 0, 0)
                unitFrame.HighLevelContainer:SetPoint("BOTTOMRIGHT", unitFrame, "BOTTOMRIGHT", 0, 0)
                unitFrame.HighLevelContainer:SetFrameLevel(999)
                unitFrame.HighLevelContainer:SetFrameStrata("MEDIUM")
            end)
        end
    end
end