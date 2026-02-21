local _, UUF = ...
local oUF = UUF.oUF
local IsSecretValue = issecretvalue or function() return false end

UUF.DispelHighlightEvtFrames = UUF.DispelHighlightEvtFrames or {}

local DISPEL_HIGHLIGHT_COALESCE_EVENT = "UUF_DISPEL_HIGHLIGHT_UPDATE"
local dispelEventFrame

local dispelTypeMap = {
    Magic = oUF.Enum.DispelType.Magic,
    Curse = oUF.Enum.DispelType.Curse,
    Disease = oUF.Enum.DispelType.Disease,
    Poison = oUF.Enum.DispelType.Poison,
    Bleed = oUF.Enum.DispelType.Bleed,
}

local function ProcessDispelHighlightUpdates(event, unit)
    local onlyUnit = (event == "UNIT_AURA") and unit or nil

    for i = #UUF.DispelHighlightEvtFrames, 1, -1 do
        local data = UUF.DispelHighlightEvtFrames[i]
        if not data or not data.frame then
            table.remove(UUF.DispelHighlightEvtFrames, i)
        else
            if not onlyUnit or data.unit == onlyUnit then
                UUF:UpdateUnitDispelState(data.frame, data.unit)
            end
        end
    end
end

local function EnsureDispelHighlightDispatcher()
    if dispelEventFrame then return end

    dispelEventFrame = CreateFrame("Frame")
    dispelEventFrame:RegisterEvent("UNIT_AURA")
    dispelEventFrame:RegisterEvent("SPELLS_CHANGED")
    dispelEventFrame:RegisterEvent("TRAIT_CONFIG_UPDATED")
    dispelEventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    dispelEventFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
    dispelEventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")

    if UUF.EventCoalescer then
        UUF.EventCoalescer:CoalesceEvent(DISPEL_HIGHLIGHT_COALESCE_EVENT, 0.05, ProcessDispelHighlightUpdates, 2)
    end

    dispelEventFrame:SetScript("OnEvent", function(_, event, ...)
        if UUF.EventCoalescer then
            UUF.EventCoalescer:QueueEvent(DISPEL_HIGHLIGHT_COALESCE_EVENT, event, ...)
        else
            ProcessDispelHighlightUpdates(event, ...)
        end
    end)
end

function UUF:UpdateDispelColorCurve(unitFrame)
    if not unitFrame.dispelColorCurve then return end
    unitFrame.dispelColorCurve:ClearPoints()
    for dispelType, index in pairs(dispelTypeMap) do
        local color = oUF.colors.dispel[index]
        if color then
            unitFrame.dispelColorCurve:AddPoint(index, color)
        end
    end
    unitFrame.dispelColorCurveGeneration = UUF.dispelColorGeneration
end

function UUF:CreateUnitDispelHighlight(unitFrame, unit)
    local DispelHighlightDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealthBar.DispelHighlight
    if not unitFrame.DispelHighlight then
        local DispelHighlight = unitFrame.Health:CreateTexture(UUF:FetchFrameName(unit) .. "_DispelHighlight", "OVERLAY")
        DispelHighlight:ClearAllPoints()
        if DispelHighlightDB.Style == "GRADIENT" then
            DispelHighlight:SetPoint("TOPLEFT", unitFrame, "TOPLEFT", 1, -1)
            DispelHighlight:SetPoint("BOTTOMRIGHT", unitFrame, "BOTTOMRIGHT", -1, 1)
            DispelHighlight:SetTexture("Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Gradient.png")
            DispelHighlight:SetAlpha(1)
        else
            local barTexture = unitFrame.Health and unitFrame.Health:GetStatusBarTexture()
            if barTexture then
                DispelHighlight:SetAllPoints(barTexture)
            else
                DispelHighlight:SetAllPoints(unitFrame.Health)
            end
            DispelHighlight:SetTexture("Interface\\Buttons\\WHITE8X8")
            DispelHighlight:SetAlpha(0.75)
        end
        DispelHighlight:SetBlendMode("BLEND")
        DispelHighlight:Hide()

        unitFrame.DispelHighlight = DispelHighlight

        if not unitFrame.dispelColorCurve then
            unitFrame.dispelColorCurve = C_CurveUtil.CreateColorCurve()
            unitFrame.dispelColorCurve:SetType(Enum.LuaCurveType.Step)
            UUF:UpdateDispelColorCurve(unitFrame)
        end
    end

    if DispelHighlightDB.Enabled then
        UUF:QueueOrRun(function() unitFrame.DispelHighlight:Show() end)
    else
        UUF:QueueOrRun(function() unitFrame.DispelHighlight:Hide() end)
    end
end

function UUF:UpdateUnitDispelHighlight(unitFrame, unit)
    if not unitFrame.DispelHighlight then return end
    local DispelHighlightDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealthBar.DispelHighlight
    if unitFrame.DispelHighlight then
        if DispelHighlightDB.Enabled then
            UUF:RegisterDispelHighlightEvents(unitFrame, unit)
            UUF:QueueOrRun(function()
                unitFrame.DispelHighlight:ClearAllPoints()
                if DispelHighlightDB.Style == "GRADIENT" then
                    unitFrame.DispelHighlight:SetPoint("TOPLEFT", unitFrame, "TOPLEFT", 1, -1)
                    unitFrame.DispelHighlight:SetPoint("BOTTOMRIGHT", unitFrame, "BOTTOMRIGHT", -1, 1)
                    unitFrame.DispelHighlight:SetTexture("Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Gradient.png")
                    unitFrame.DispelHighlight:SetAlpha(1)
                else
                    local barTexture = unitFrame.Health and unitFrame.Health:GetStatusBarTexture()
                    if barTexture then
                        unitFrame.DispelHighlight:SetAllPoints(barTexture)
                    else
                        unitFrame.DispelHighlight:SetAllPoints(unitFrame.Health)
                    end
                    unitFrame.DispelHighlight:SetTexture("Interface\\Buttons\\WHITE8X8")
                    unitFrame.DispelHighlight:SetAlpha(0.75)
                end
                unitFrame.DispelHighlight:Show()
            end)
        else
            UUF:UnregisterDispelHighlightEvents(unitFrame)
            UUF:QueueOrRun(function() unitFrame.DispelHighlight:Hide() end)
        end
    end
end

function UUF:UpdateUnitDispelState(unitFrame, unit)
    if not unitFrame.DispelHighlight then return end
    if not UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealthBar.DispelHighlight.Enabled then return end

    local LibDispel = UUF.LD
    if not LibDispel then return end

    if unitFrame.dispelColorCurve and unitFrame.dispelColorCurveGeneration ~= UUF.dispelColorGeneration then
        UUF:UpdateDispelColorCurve(unitFrame)
    end

    if not UnitIsUnit(unit, "player") and not UnitIsFriend("player", unit) then
        unitFrame.DispelHighlight:Hide()
        return
    end

    local dispelList = LibDispel:GetMyDispelTypes()
    -- Safely check if any dispel type is available, guarding against secret values
    local hasDispelType = false
    for _, dispelKey in ipairs({"Magic", "Curse", "Disease", "Poison", "Bleed"}) do
        local value = dispelList[dispelKey]
        if not IsSecretValue(value) and value then
            hasDispelType = true
            break
        end
    end
    if not hasDispelType then
        unitFrame.DispelHighlight:Hide()
        return
    end

    local bestAura = C_UnitAuras.GetAuraDataByIndex(unit, 1, "HARMFUL|RAID")
    local bestAuraInstanceID = bestAura and bestAura.auraInstanceID or nil

    if bestAuraInstanceID then
        local color = C_UnitAuras.GetAuraDispelTypeColor(unit, bestAuraInstanceID, unitFrame.dispelColorCurve)

        if color then
            unitFrame.DispelHighlight:SetVertexColor(color:GetRGBA())
            unitFrame.DispelHighlight:Show()
        else
            unitFrame.DispelHighlight:Hide()
        end
    else
        unitFrame.DispelHighlight:Hide()
    end
end

function UUF:RegisterDispelHighlightEvents(unitFrame, unit)
    if not unitFrame.DispelHighlight then return end
    if not UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealthBar.DispelHighlight.Enabled then return end
    if not unitFrame or not unit then return end

    EnsureDispelHighlightDispatcher()

    for i = #UUF.DispelHighlightEvtFrames, 1, -1 do
        local data = UUF.DispelHighlightEvtFrames[i]
        if not data or not data.frame then
            table.remove(UUF.DispelHighlightEvtFrames, i)
        elseif data.frame == unitFrame then
            data.unit = unit
            UUF:UpdateUnitDispelState(unitFrame, unit)
            return
        end
    end

    table.insert(UUF.DispelHighlightEvtFrames, { frame = unitFrame, unit = unit })
    UUF:UpdateUnitDispelState(unitFrame, unit)
end

function UUF:UnregisterDispelHighlightEvents(unitFrame)
    if not unitFrame then return end

    for i = #UUF.DispelHighlightEvtFrames, 1, -1 do
        local data = UUF.DispelHighlightEvtFrames[i]
        if not data or data.frame == unitFrame then
            table.remove(UUF.DispelHighlightEvtFrames, i)
        end
    end

    -- Backward compatibility cleanup if old per-frame handlers exist.
    if unitFrame.DispelHighlightHandler then
        unitFrame.DispelHighlightHandler:UnregisterAllEvents()
        unitFrame.DispelHighlightHandler:SetScript("OnEvent", nil)
        unitFrame.DispelHighlightHandler = nil
    end
end
