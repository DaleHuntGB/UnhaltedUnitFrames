local _, UUF = ...
local oUF = UUF.oUF

local function ApplyScripts(unitFrame)
    unitFrame:RegisterForClicks("AnyUp")
    unitFrame:SetAttribute("*type1", "target")
    unitFrame:SetAttribute("*type2", "togglemenu")
    unitFrame:SetScript("OnEnter", UnitFrame_OnEnter)
    unitFrame:SetScript("OnLeave", UnitFrame_OnLeave)
end

local function EnablePings(unitFrame)
    unitFrame:SetAttribute("ping-receiver", true)
    unitFrame.IsPingable = true
    Mixin(unitFrame, PingableType_UnitFrameMixin)
end

function UUF:CreateUnitFrame(unitFrame, unit)
    if not unit or not unitFrame then return end
    local normalizedUnit = UUF:GetNormalizedUnit(unit)
    UUF:CreateUnitContainer(unitFrame, unit)
    if normalizedUnit ~= "targettarget" and normalizedUnit ~= "focustarget" then UUF:CreateUnitCastBar(unitFrame, unit) end
    UUF:CreateUnitHealthBar(unitFrame, unit)
    if unit == "player" or unit == "target" or unit == "focus" then UUF:CreateUnitDispelHighlight(unitFrame, unit) end
    UUF:CreateUnitHealPrediction(unitFrame, unit)
    if normalizedUnit ~= "targettarget" and normalizedUnit ~= "focustarget" then UUF:CreateUnitPortrait(unitFrame, unit) end
    UUF:CreateUnitPowerBar(unitFrame, unit)
    if unit == "player" then UUF:CreateUnitAlternativePowerBar(unitFrame, unit) end
    if unit == "player" then UUF:CreateUnitSecondaryPowerBar(unitFrame, unit) end
    UUF:CreateUnitRaidTargetMarker(unitFrame, unit)
    if (unit == "player" or unit == "target" or normalizedUnit == "party") and UUF.CreateUnitLeaderAssistantIndicator then
        UUF:CreateUnitLeaderAssistantIndicator(unitFrame, unit)
    end
    if normalizedUnit == "party" then UUF:CreateUnitGroupRoleIndicator(unitFrame, unit) end
    if unit == "player" or unit == "target" then UUF:CreateUnitCombatIndicator(unitFrame, unit) end
    if unit == "player" then UUF:CreateUnitRestingIndicator(unitFrame, unit) end
    -- if unit == "player" then UUF:CreateUnitTotems(unitFrame, unit) end
    UUF:CreateUnitTargetGlowIndicator(unitFrame, unit)
    UUF:CreateUnitAuras(unitFrame, unit)
    UUF:CreateUnitTags(unitFrame, unit)
    ApplyScripts(unitFrame)
    EnablePings(unitFrame)
    UUF:CreateUnitMouseoverIndicator(unitFrame, unit)
    return unitFrame
end

local RoleSortOrder = { TANK = 1, HEALER = 2, DAMAGER = 3, NONE = 4 }

local function SortPartyFramesByRole(a, b)
    local roleA = UnitGroupRolesAssigned(a.unit) or "NONE"
    local roleB = UnitGroupRolesAssigned(b.unit) or "NONE"
    return RoleSortOrder[roleA] < RoleSortOrder[roleB]
end

function UUF:LayoutPartyFrames()
    if InCombatLockdown() then return end
    
    local PartyDB = UUF.db.profile.Units.party
    local Frame = PartyDB.Frame
    if #UUF.PARTY_FRAMES == 0 then return end

    local partyFrames = {}
    for i = 1, #UUF.PARTY_FRAMES do
        partyFrames[i] = UUF.PARTY_FRAMES[i]
    end

    if Frame.GrowthDirection == "UP" then
        local reversed = {}
        for i = #partyFrames, 1, -1 do reversed[#reversed+1] = partyFrames[i] end
        partyFrames = reversed
    end

    local sortOrder = PartyDB.SortOrder or "DEFAULT"
    if sortOrder == "ROLE" then
        table.sort(partyFrames, SortPartyFramesByRole)
    end

    local layoutConfig = UUF.LayoutConfig[Frame.Layout[1]]
    local frameHeight = partyFrames[1]:GetHeight()
    local containerHeight = (frameHeight + Frame.Layout[5]) * #partyFrames - Frame.Layout[5]
    local offsetY = containerHeight * layoutConfig.offsetMultiplier
    if layoutConfig.isCenter then offsetY = offsetY - (frameHeight / 2) end
    local initialAnchor = AnchorUtil.CreateAnchor(layoutConfig.anchor, UIParent, Frame.Layout[2], Frame.Layout[3], Frame.Layout[4] + offsetY)
    AnchorUtil.VerticalLayout(partyFrames, initialAnchor, Frame.Layout[5])
end

function UUF:LayoutBossFrames()
    if InCombatLockdown() then return end
    
    local Frame = UUF.db.profile.Units.boss.Frame
    if #UUF.BOSS_FRAMES == 0 then return end
    local bossFrames = UUF.BOSS_FRAMES
    if Frame.GrowthDirection == "UP" then
        bossFrames = {}
        for i = #UUF.BOSS_FRAMES, 1, -1 do bossFrames[#bossFrames+1] = UUF.BOSS_FRAMES[i] end
    end
    local layoutConfig = UUF.LayoutConfig[Frame.Layout[1]]
    local frameHeight = bossFrames[1]:GetHeight()
    local containerHeight = (frameHeight + Frame.Layout[5]) * #bossFrames - Frame.Layout[5]
    local offsetY = containerHeight * layoutConfig.offsetMultiplier
    if layoutConfig.isCenter then offsetY = offsetY - (frameHeight / 2) end
    local initialAnchor = AnchorUtil.CreateAnchor(layoutConfig.anchor, UIParent, Frame.Layout[2], Frame.Layout[3], Frame.Layout[4] + offsetY)
    AnchorUtil.VerticalLayout(bossFrames, initialAnchor, Frame.Layout[5])
end

function UUF:SpawnUnitFrame(unit)
    local UnitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)]
    if not UnitDB or not UnitDB.Enabled then
        if UnitDB and UnitDB.ForceHideBlizzard then oUF:DisableBlizzard(unit) end
        return
    end
    local FrameDB = UnitDB.Frame

    oUF:RegisterStyle(UUF:FetchFrameName(unit), function(unitFrame) UUF:CreateUnitFrame(unitFrame, unit) end)
    oUF:SetActiveStyle(UUF:FetchFrameName(unit))

    if unit == "boss" then
        for i = 1, UUF.MAX_BOSS_FRAMES do
            UUF[unit:upper() .. i] = oUF:Spawn(unit .. i, UUF:FetchFrameName(unit .. i))
            UUF[unit:upper() .. i]:SetSize(FrameDB.Width, FrameDB.Height)
            UUF.BOSS_FRAMES[i] = UUF[unit:upper() .. i]
            UUF[unit:upper() .. i]:SetFrameStrata(FrameDB.FrameStrata)
            UUF:RegisterTargetGlowIndicatorFrame(UUF:FetchFrameName(unit .. i), unit .. i)
            UUF:RegisterRangeFrame(UUF:FetchFrameName(unit .. i), unit .. i)
        end
        UUF:LayoutBossFrames()
    elseif unit == "party" then
        local HidePlayer = UnitDB.HidePlayer
        for i = 1, UUF.MAX_PARTY_MEMBERS do
            local spawnUnit
            if not HidePlayer and i == 1 then
                spawnUnit = "player"
            else
                local partyIndex = HidePlayer and i or (i - 1)
                spawnUnit = partyIndex > 0 and ("party" .. partyIndex) or "player"
            end
            UUF[unit:upper() .. i] = oUF:Spawn(spawnUnit, UUF:FetchFrameName(unit .. i))
            UUF[unit:upper() .. i]:SetSize(FrameDB.Width, FrameDB.Height)
            UUF.PARTY_FRAMES[i] = UUF[unit:upper() .. i]
            UUF:RegisterTargetGlowIndicatorFrame(UUF:FetchFrameName(unit .. i), unit .. i)
            UUF[unit:upper() .. i]:SetFrameStrata(FrameDB.FrameStrata)
            if spawnUnit == "player" then UUF:RegisterDispelHighlightEvents(UUF[unit:upper() .. i], spawnUnit)
            else UUF:RegisterDispelHighlightEvents(UUF[unit:upper() .. i], "party" .. (i - 1)) end
        end
        UUF:LayoutPartyFrames()
    else
        UUF[unit:upper()] = oUF:Spawn(unit, UUF:FetchFrameName(unit))
        UUF:RegisterTargetGlowIndicatorFrame(UUF:FetchFrameName(unit), unit)
        UUF[unit:upper()]:SetFrameStrata(FrameDB.FrameStrata)
        if unit == "player" or unit == "target" or unit == "focus" then UUF:RegisterDispelHighlightEvents(UUF[unit:upper()], unit) end
    end

    if unit == "player" or unit == "target" then
        local parentFrame = UUF.db.profile.Units[unit].HealthBar.AnchorToCooldownViewer and _G["UUF_CDMAnchor"] or UIParent
        UUF[unit:upper()]:SetPoint(FrameDB.Layout[1], parentFrame, FrameDB.Layout[2], FrameDB.Layout[3], FrameDB.Layout[4])
        UUF[unit:upper()]:SetSize(FrameDB.Width, FrameDB.Height)
    elseif unit == "targettarget" or unit == "focus" or unit == "focustarget" or unit == "pet" then
        local parentFrame = _G[UUF.db.profile.Units[unit].Frame.AnchorParent] or UIParent
        UUF[unit:upper()]:SetPoint(FrameDB.Layout[1], parentFrame, FrameDB.Layout[2], FrameDB.Layout[3], FrameDB.Layout[4])
        UUF[unit:upper()]:SetSize(FrameDB.Width, FrameDB.Height)
    end
    if unit ~= "player" then UUF:RegisterRangeFrame(UUF:FetchFrameName(unit), unit) end

    if UnitDB.Enabled then
        if unit == "boss" then
            for i = 1, UUF.MAX_BOSS_FRAMES do
                UUF:QueueOrRun(function()
                    RegisterUnitWatch(UUF[unit:upper() .. i])
                    UUF[unit:upper() .. i]:Show()
                end)
            end
        elseif unit == "party" then
            for i = 1, UUF.MAX_PARTY_MEMBERS do
                UUF:QueueOrRun(function()
                    RegisterUnitWatch(UUF[unit:upper() .. i])
                    UUF[unit:upper() .. i]:Show()
                end)
            end
        else
            UUF:QueueOrRun(function()
                RegisterUnitWatch(UUF[unit:upper()])
                UUF[unit:upper()]:Show()
            end)
        end
    else
        if unit == "boss" then
            for i = 1, UUF.MAX_BOSS_FRAMES do
                UUF:QueueOrRun(function()
                    UnregisterUnitWatch(UUF[unit:upper() .. i])
                    UUF[unit:upper() .. i]:Hide()
                end)
            end
        elseif unit == "party" then
            for i = 1, UUF.MAX_PARTY_MEMBERS do
                UUF:QueueOrRun(function()
                    UnregisterUnitWatch(UUF[unit:upper() .. i])
                    UUF[unit:upper() .. i]:Hide()
                end)
            end
        else
            UUF:QueueOrRun(function()
                UnregisterUnitWatch(UUF[unit:upper()])
                UUF[unit:upper()]:Hide()
            end)
        end
    end

    return UUF[unit:upper()]
end

function UUF:UpdateUnitFrame(unitFrame, unit)
    if not unitFrame or not unit then return end
    local normalizedUnit = UUF:GetNormalizedUnit(unit)
    local UnitDB = UUF.db.profile.Units[normalizedUnit]
    if normalizedUnit ~= "targettarget" and normalizedUnit ~= "focustarget" then UUF:UpdateUnitCastBar(unitFrame, unit) end
    UUF:UpdateUnitHealthBar(unitFrame, unit)
    UUF:UpdateUnitHealPrediction(unitFrame, unit)
    if unit ~= "targettarget" and unit ~= "focustarget" then UUF:UpdateUnitPortrait(unitFrame, unit) end
    UUF:UpdateUnitPowerBar(unitFrame, unit)
    if unit == "player" then UUF:UpdateUnitAlternativePowerBar(unitFrame, unit) end
    if unit == "player" then UUF:UpdateUnitSecondaryPowerBar(unitFrame, unit) end
    UUF:UpdateUnitRaidTargetMarker(unitFrame, unit)
    if (unit == "player" or unit == "target" or normalizedUnit == "party") and UUF.UpdateUnitLeaderAssistantIndicator then
        UUF:UpdateUnitLeaderAssistantIndicator(unitFrame, unit)
    end
    if normalizedUnit == "party" then UUF:UpdateUnitGroupRoleIndicator(unitFrame, unit) end
    if unit == "player" or unit == "target" then UUF:UpdateUnitCombatIndicator(unitFrame, unit) end
    if unit == "player" then UUF:UpdateUnitRestingIndicator(unitFrame, unit) end
    -- if unit == "player" then UUF:UpdateUnitTotems(unitFrame, unit) end
    UUF:UpdateUnitMouseoverIndicator(unitFrame, unit)
    UUF:UpdateUnitTargetGlowIndicator(unitFrame, unit)
    UUF:UpdateUnitAuras(unitFrame, unit)
    UUF:UpdateUnitTags()
    UUF:QueueOrRun(function()
        unitFrame:SetFrameStrata(UnitDB.Frame.FrameStrata)
    end)
end

function UUF:UpdateBossFrames()
    for i in pairs(UUF.BOSS_FRAMES) do
        UUF:UpdateUnitFrame(UUF["BOSS"..i], "boss"..i)
    end
    UUF:CreateTestBossFrames()
    UUF:LayoutBossFrames()
end

function UUF:UpdatePartyFrames()
    for i in pairs(UUF.PARTY_FRAMES) do
        UUF:UpdateUnitFrame(UUF["PARTY"..i], "party"..i)
    end
    UUF:CreateTestPartyFrames()
    UUF:LayoutPartyFrames()
end


function UUF:UpdateAllUnitFrames()
    for unit, _ in pairs(UUF.db.profile.Units) do
        if UUF[unit:upper()] then
            UUF:UpdateUnitFrame(UUF[unit:upper()], unit)
        end
    end
end

function UUF:ToggleUnitFrameVisibility(unit)
    if not unit then return end
    local UnitKey = unit:upper()
    local UnitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)]
    if not UnitDB then return end
    if UnitDB.Enabled then
        if unit == "boss" then
            if not UUF["BOSS1"] then UUF:SpawnUnitFrame(unit) end
        elseif unit == "party" then
            if not UUF["PARTY1"] then UUF:SpawnUnitFrame(unit) end
        elseif not UUF[UnitKey] then
            UUF:SpawnUnitFrame(unit)
        end
    elseif UnitDB.ForceHideBlizzard then
        oUF:DisableBlizzard(unit)
    end

    if unit == "boss" then
        for i = 1, UUF.MAX_BOSS_FRAMES do
            local unitFrame = UUF["BOSS"..i]
            if unitFrame then
                local enabled = UnitDB.Enabled
                UUF:QueueOrRun(function() (enabled and RegisterUnitWatch or UnregisterUnitWatch)(unitFrame) unitFrame:SetShown(enabled) end)
            end
        end
        return
    elseif unit == "party" then
        for i = 1, UUF.MAX_PARTY_MEMBERS do
            local unitFrame = UUF["PARTY"..i]
            if unitFrame then
                local enabled = UnitDB.Enabled
                UUF:QueueOrRun(function() (enabled and RegisterUnitWatch or UnregisterUnitWatch)(unitFrame) unitFrame:SetShown(enabled) end)
            end
        end
        return
    end

    local unitFrame = UUF[UnitKey]
    if not unitFrame then return end
    local enabled = UnitDB.Enabled
    UUF:QueueOrRun(function() (enabled and RegisterUnitWatch or UnregisterUnitWatch)(unitFrame) unitFrame:SetShown(enabled) end)
end
