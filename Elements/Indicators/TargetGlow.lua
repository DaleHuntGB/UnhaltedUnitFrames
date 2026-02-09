local _, UUF = ...
UUF.TargetHighlightEvtFrames = {}

local unitIsTargetEvtFrame = CreateFrame("Frame")
unitIsTargetEvtFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
unitIsTargetEvtFrame:RegisterEvent("UNIT_TARGET")
unitIsTargetEvtFrame:SetScript("OnEvent", function()
    for _, frameData in ipairs(UUF.TargetHighlightEvtFrames) do
        local frame, unit = frameData.frame, frameData.unit
        if UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Target.Enabled then
            UUF:UpdateTargetGlowIndicator(frame, unit)
        end
    end
end)

function UUF:CreateUnitTargetGlowIndicator(unitFrame, unit)
    local TargetIndicatorDB = UUF.db.profile.Units[unit].Indicators.Target
    local frameName = unitFrame:GetName() or UUF:FetchFrameName(unit)
    if TargetIndicatorDB then
        unitFrame.TargetIndicator = CreateFrame("Frame", frameName.."_TargetIndicator", unitFrame.Container, "BackdropTemplate")
        UUF:QueueOrRun(function()
            unitFrame.TargetIndicator:SetFrameLevel(unitFrame.Container:GetFrameLevel() + 3)
            unitFrame.TargetIndicator:SetBackdrop({ edgeFile = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Glow.tga", edgeSize = 3, insets = {left = -3, right = -3, top = -3, bottom = -3} })
            unitFrame.TargetIndicator:SetBackdropColor(0, 0, 0, 0)
            unitFrame.TargetIndicator:SetBackdropBorderColor(TargetIndicatorDB.Colour[1], TargetIndicatorDB.Colour[2], TargetIndicatorDB.Colour[3], TargetIndicatorDB.Colour[4])
            unitFrame.TargetIndicator:SetPoint("TOPLEFT", unitFrame.Container, "TOPLEFT", -3, 3)
            unitFrame.TargetIndicator:SetPoint("BOTTOMRIGHT", unitFrame.Container, "BOTTOMRIGHT", 3, -3)
            unitFrame.TargetIndicator:SetAlpha(0)
        end)
    end
end

function UUF:UpdateUnitTargetGlowIndicator(unitFrame, unit)
    local TargetIndicatorDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Target
    if unitFrame and unitFrame.TargetIndicator and TargetIndicatorDB then
        if TargetIndicatorDB.Enabled then unitFrame.TargetIndicator:SetAlpha(1) else unitFrame.TargetIndicator:SetAlpha(0) end
        unitFrame.TargetIndicator:SetBackdropBorderColor(TargetIndicatorDB.Colour[1], TargetIndicatorDB.Colour[2], TargetIndicatorDB.Colour[3], TargetIndicatorDB.Colour[4])
    end
end

function UUF:UpdateTargetGlowIndicator(unitFrame, unit)
    if unitFrame and unitFrame.TargetIndicator then
        if UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Target.Enabled then
            local actualUnit = unitFrame:GetAttribute("unit") or unit
            unitFrame.TargetIndicator:SetAlphaFromBoolean(UnitIsUnit("target", actualUnit), 1, 0)
        else
            unitFrame.TargetIndicator:SetAlpha(0)
        end
    end
end

function UUF:RegisterTargetGlowIndicatorFrame(frameName, unit)
    if not unit or not frameName then return end
        if UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Target then
            local unitFrame = type(frameName) == "table" and frameName or _G[frameName]
            local DB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)]
            table.insert(UUF.TargetHighlightEvtFrames, { frame = unitFrame, unit = unit })
            if DB and DB.Indicators.Target and DB.Indicators.Target.Enabled then
                UUF:UpdateTargetGlowIndicator(unitFrame, unit)
            else
                unitFrame.TargetIndicator:SetAlpha(0)
            end
    end
end