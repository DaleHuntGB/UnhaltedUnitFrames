local _, UUF = ...
UUF.TargetHighlightEvtFrames = {}
local TARGET_GLOW_COALESCE_EVENT = "UUF_TARGET_GLOW_UPDATE"

local function ProcessTargetGlowUpdates()
    for i = #UUF.TargetHighlightEvtFrames, 1, -1 do
        local frameData = UUF.TargetHighlightEvtFrames[i]
        if not frameData or not frameData.frame then
            table.remove(UUF.TargetHighlightEvtFrames, i)
        else
            local frame, unit = frameData.frame, frameData.unit
            if UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Target.Enabled then
                UUF:UpdateTargetGlowIndicator(frame, unit)
            end
        end
    end
end

if UUF.EventCoalescer then
    -- Keep target feedback responsive while avoiding UNIT_TARGET burst spam.
    UUF.EventCoalescer:CoalesceEvent(TARGET_GLOW_COALESCE_EVENT, 0.05, ProcessTargetGlowUpdates, 2)
end

local unitIsTargetEvtFrame = CreateFrame("Frame")
unitIsTargetEvtFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
unitIsTargetEvtFrame:RegisterEvent("UNIT_TARGET")
unitIsTargetEvtFrame:SetScript("OnEvent", function()
    if UUF.EventCoalescer then
        UUF.EventCoalescer:QueueEvent(TARGET_GLOW_COALESCE_EVENT)
    else
        ProcessTargetGlowUpdates()
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

            for i = #UUF.TargetHighlightEvtFrames, 1, -1 do
                local data = UUF.TargetHighlightEvtFrames[i]
                if not data or not data.frame then
                    table.remove(UUF.TargetHighlightEvtFrames, i)
                elseif data.frame == unitFrame then
                    data.unit = unit
                    if DB and DB.Indicators.Target and DB.Indicators.Target.Enabled then
                        UUF:UpdateTargetGlowIndicator(unitFrame, unit)
                    else
                        unitFrame.TargetIndicator:SetAlpha(0)
                    end
                    return
                end
            end

            table.insert(UUF.TargetHighlightEvtFrames, { frame = unitFrame, unit = unit })
            if DB and DB.Indicators.Target and DB.Indicators.Target.Enabled then
                UUF:UpdateTargetGlowIndicator(unitFrame, unit)
            else
                unitFrame.TargetIndicator:SetAlpha(0)
            end
    end
end
