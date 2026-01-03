local _, UUF = ...
local oUF = UUF.oUF

local function ApplyScripts(unitFrame)
    unitFrame:RegisterForClicks("AnyUp")
    unitFrame:SetAttribute("*type1", "target")
    unitFrame:SetAttribute("*type2", "togglemenu")
end

function UUF:CreateUnitFrame(unitFrame, unit)
    if not unit or not unitFrame then return end
    UUF:CreateUnitContainer(unitFrame, unit)
    UUF:CreateUnitCastBar(unitFrame, unit)
    UUF:CreateUnitHealthBar(unitFrame, unit)
    UUF:CreateUnitHealPrediction(unitFrame, unit)
    UUF:CreateUnitPortrait(unitFrame, unit)
    UUF:CreateUnitPowerBar(unitFrame, unit)
    UUF:CreateUnitRaidTargetMarker(unitFrame, unit)
    UUF:CreateUnitLeaderAssistantIndicator(unitFrame, unit)
    if unit == "player" then UUF:CreateUnitCombatIndicator(unitFrame, unit) end
    if unit == "player" then UUF:CreateUnitRestingIndicator(unitFrame, unit) end
    UUF:CreateUnitMouseoverIndicator(unitFrame, unit)
    UUF:CreateUnitAuras(unitFrame, unit)
    UUF:CreateUnitTags(unitFrame, unit)
    ApplyScripts(unitFrame)
end

function UUF:SpawnUnitFrame(unit)
    local FrameDB = UUF.db.profile.Units[unit].Frame

    oUF:RegisterStyle(UUF:FetchFrameName(unit), function(unitFrame) UUF:CreateUnitFrame(unitFrame, unit) end)
    oUF:SetActiveStyle(UUF:FetchFrameName(unit))
    UUF[unit:upper()] = oUF:Spawn(unit, UUF:FetchFrameName(unit))
    local parentFrame = UUF.db.profile.Units[unit].HealthBar.AnchorToCooldownViewer and _G["UUF_CDMAnchor"] or UIParent
    UUF[unit:upper()]:SetPoint(FrameDB.Layout[1], parentFrame, FrameDB.Layout[2], FrameDB.Layout[3], FrameDB.Layout[4])
    UUF[unit:upper()]:SetSize(FrameDB.Width, FrameDB.Height)
    UUF:PrettyPrint("Spawned " .. UUF:Capitalize(unit) .. ".")
end

function UUF:UpdateUnitFrame(unitFrame, unit)
    UUF:UpdateUnitCastBar(unitFrame, unit)
    UUF:UpdateUnitHealthBar(unitFrame, unit)
    UUF:UpdateUnitHealPrediction(unitFrame, unit)
    UUF:UpdateUnitPortrait(unitFrame, unit)
    UUF:UpdateUnitPowerBar(unitFrame, unit)
    UUF:UpdateUnitRaidTargetMarker(unitFrame, unit)
    UUF:UpdateUnitLeaderAssistantIndicator(unitFrame, unit)
    if unit == "player" then UUF:UpdateUnitCombatIndicator(unitFrame, unit) end
    if unit == "player" then UUF:UpdateUnitRestingIndicator(unitFrame, unit) end
    UUF:UpdateUnitMouseoverIndicator(unitFrame, unit)
    UUF:UpdateUnitAuras(unitFrame, unit)
    UUF:UpdateUnitTags()
end

function UUF:UpdateAllUnitFrames()
    for unit, _ in pairs(UUF.db.profile.Units) do
        if UUF[unit:upper()] then
            UUF:UpdateUnitFrame(UUF[unit:upper()], unit)
        end
    end
end