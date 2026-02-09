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

function UUF:SaveUnitFramePosition(unitFrame)
    if not unitFrame or InCombatLockdown() then return end
    local unit = unitFrame.unit
    if not unit then return end
    local layoutUnit = unitFrame.UUFLayoutUnit or UUF:GetNormalizedUnit(unit)
    local UnitDB = UUF.db.profile.Units[layoutUnit]
    if not UnitDB or not UnitDB.Frame then return end
    local point, _, relativePoint, xOffset, yOffset = unitFrame:GetPoint(1)
    if not point then return end
    UnitDB.Frame.Layout[1] = point
    UnitDB.Frame.Layout[2] = relativePoint or "CENTER"
    UnitDB.Frame.Layout[3] = xOffset or 0
    UnitDB.Frame.Layout[4] = yOffset or 0
    local layoutDB = UUF:GetEditModeLayoutDB()
    if layoutDB then
        layoutDB.Units[layoutUnit] = layoutDB.Units[layoutUnit] or {}
        layoutDB.Units[layoutUnit].Frame = layoutDB.Units[layoutUnit].Frame or {}
        layoutDB.Units[layoutUnit].Frame.Layout = { point, relativePoint or "CENTER", xOffset or 0, yOffset or 0 }
    end
    if layoutUnit == "party" then UUF:LayoutPartyFrames() end
    if layoutUnit == "boss" then UUF:LayoutBossFrames() end
end

function UUF:GetLayoutForUnit(layoutUnit)
    local unitDB = UUF.db.profile.Units[layoutUnit]
    if not unitDB or not unitDB.Frame then return end
    local defaultLayout = unitDB.Frame.Layout
    local layout = defaultLayout
    local layoutDB = UUF:GetEditModeLayoutDB()
    if layoutDB and layoutDB.Units and layoutDB.Units[layoutUnit] and layoutDB.Units[layoutUnit].Frame and layoutDB.Units[layoutUnit].Frame.Layout then
        layout = layoutDB.Units[layoutUnit].Frame.Layout
        if #layout < #defaultLayout then
            local merged = {}
            for i = 1, #defaultLayout do
                merged[i] = layout[i] ~= nil and layout[i] or defaultLayout[i]
            end
            layout = merged
        end
    end
    return layout
end

function UUF:ApplyEditModeLayout()
    if not UUF:GetEditModeLayoutDB() then return end
    UUF:UpdateAllUnitFrames()
    UUF:LayoutPartyFrames()
    UUF:LayoutBossFrames()
end

function UUF:IsEditModeActive()
    if EditModeManagerFrame and EditModeManagerFrame.IsEditModeActive then
        local ok, active = pcall(EditModeManagerFrame.IsEditModeActive, EditModeManagerFrame)
        if ok then return active == true end
    end
    if C_EditMode and C_EditMode.IsEditModeActive then
        local ok, active = pcall(C_EditMode.IsEditModeActive)
        if ok then return active == true end
    end
    return false
end

function UUF:IsFrameMoverActive()
    if UUF.db.profile.General.FrameMover and UUF.db.profile.General.FrameMover.Enabled then
        return true
    end
    return UUF:IsEditModeActive()
end

function UUF:UpdateFrameMoverGlow(unitFrame, active)
    if not unitFrame then return end
    local anchorTarget = unitFrame.HighLevelContainer or unitFrame
    local layoutUnit = unitFrame.UUFLayoutUnit or (unitFrame.unit and UUF:GetNormalizedUnit(unitFrame.unit))
    local paddingX, paddingY = 16, 16
    if layoutUnit then
        local unitDB = UUF.db.profile.Units[layoutUnit]
        if unitDB and unitDB.Frame then
            paddingX = unitDB.Frame.Width or paddingX
            paddingY = unitDB.Frame.Height or paddingY
        end
    end
    paddingX = math.min(paddingX, 24)
    paddingY = math.min(paddingY, 24)
    paddingX = math.max(paddingX - 15, 0)
    paddingY = math.max(paddingY - 15, 0)
    if not unitFrame.UUFFrameMoverGlowFrame then
        local glowFrame = CreateFrame("Frame", nil, unitFrame, "BackdropTemplate")
        glowFrame:SetAllPoints(anchorTarget)
        glowFrame:SetFrameStrata("TOOLTIP")
        glowFrame:SetFrameLevel((anchorTarget:GetFrameLevel() or unitFrame:GetFrameLevel()) + 20)
        glowFrame:SetBackdrop({
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 2,
        })
        glowFrame:SetBackdropBorderColor(1, 0.82, 0, 0.85)
        unitFrame.UUFFrameMoverGlowFrame = glowFrame
    end
    unitFrame.UUFFrameMoverGlowFrame:SetAllPoints(anchorTarget)
    unitFrame.UUFFrameMoverGlowFrame:SetFrameStrata("TOOLTIP")
    unitFrame.UUFFrameMoverGlowFrame:SetFrameLevel((anchorTarget:GetFrameLevel() or unitFrame:GetFrameLevel()) + 20)
    unitFrame.UUFFrameMoverGlowFrame:ClearAllPoints()
    unitFrame.UUFFrameMoverGlowFrame:SetPoint("TOPLEFT", anchorTarget, "TOPLEFT", -(paddingX + 1), paddingY)
    unitFrame.UUFFrameMoverGlowFrame:SetPoint("BOTTOMRIGHT", anchorTarget, "BOTTOMRIGHT", paddingX - 1, -paddingY)
    unitFrame.UUFFrameMoverGlowFrame:SetShown(active)
end

function UUF:ApplyFrameMover(unitFrame)
    if not unitFrame then return end
    if not UUF.db.profile.General.FrameMover then
        UUF.db.profile.General.FrameMover = { Enabled = false }
    end
    if not unitFrame.UUFFrameMoverSetup then
        unitFrame.UUFFrameMoverSetup = true
        unitFrame:RegisterForDrag("LeftButton")
        unitFrame:SetClampedToScreen(true)
        unitFrame:HookScript("OnDragStart", function(frame)
            if not UUF:IsFrameMoverActive() then return end
            if InCombatLockdown() then return end
            frame:StartMoving()
        end)
        unitFrame:HookScript("OnDragStop", function(frame)
            if not UUF:IsFrameMoverActive() then return end
            frame:StopMovingOrSizing()
            UUF:SaveUnitFramePosition(frame)
        end)
    end

    local enabled = UUF:IsFrameMoverActive() == true
    UUF:QueueOrRun(function()
        unitFrame:SetMovable(enabled)
    end)
    UUF:UpdateFrameMoverGlow(unitFrame, enabled)
end

function UUF:ApplyFrameMovers()
    if not UUF.db.profile.General.FrameMover then
        UUF.db.profile.General.FrameMover = { Enabled = false }
    end
    if InCombatLockdown() then
        UUF:PrettyPrint("Cannot toggle frame movers in combat.")
        return
    end
    for unit in pairs(UUF.db.profile.Units) do
        local unitFrame = UUF[unit:upper()]
        if unitFrame then
            UUF:ApplyFrameMover(unitFrame)
        end
    end
    for i = 1, #UUF.PARTY_FRAMES do
        UUF:ApplyFrameMover(UUF.PARTY_FRAMES[i])
    end
    for i = 1, #UUF.BOSS_FRAMES do
        UUF:ApplyFrameMover(UUF.BOSS_FRAMES[i])
    end
    UUF:ApplyFrameMoverPreview(UUF:IsFrameMoverActive())
end

function UUF:ApplyFrameMoverPreview(active)
    if InCombatLockdown() then return end

    UUF.BOSS_TEST_MODE = active == true
    UUF.PARTY_TEST_MODE = active == true
    UUF:CreateTestBossFrames()
    UUF:CreateTestPartyFrames()

    local previewUnits = { "pet", "targettarget", "focustarget" }
    for i = 1, #previewUnits do
        local unit = previewUnits[i]
        local frame = UUF[unit:upper()]
        if frame then
            if active then
                UnregisterUnitWatch(frame)
                frame:Show()
            else
                RegisterUnitWatch(frame)
            end
        end
    end
end

function UUF:CreateUnitFrame(unitFrame, unit)
    if not unit or not unitFrame then return end
    local normalizedUnit = UUF:GetNormalizedUnit(unit)
    unitFrame.UUFLayoutUnit = unitFrame.UUFLayoutUnit or normalizedUnit
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
    UUF:ApplyFrameMover(unitFrame)
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
    local layout = UUF:GetLayoutForUnit("party") or Frame.Layout
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

    local layoutConfig = UUF.LayoutConfig[layout[1]]
    local frameHeight = partyFrames[1]:GetHeight()
    local containerHeight = (frameHeight + layout[5]) * #partyFrames - layout[5]
    local offsetY = containerHeight * layoutConfig.offsetMultiplier
    if layoutConfig.isCenter then offsetY = offsetY - (frameHeight / 2) end
    local initialAnchor = AnchorUtil.CreateAnchor(layoutConfig.anchor, UIParent, layout[2], layout[3], layout[4] + offsetY)
    AnchorUtil.VerticalLayout(partyFrames, initialAnchor, layout[5])
end

function UUF:LayoutBossFrames()
    if InCombatLockdown() then return end
    
    local Frame = UUF.db.profile.Units.boss.Frame
    local layout = UUF:GetLayoutForUnit("boss") or Frame.Layout
    if #UUF.BOSS_FRAMES == 0 then return end
    local bossFrames = UUF.BOSS_FRAMES
    if Frame.GrowthDirection == "UP" then
        bossFrames = {}
        for i = #UUF.BOSS_FRAMES, 1, -1 do bossFrames[#bossFrames+1] = UUF.BOSS_FRAMES[i] end
    end
    local layoutConfig = UUF.LayoutConfig[layout[1]]
    local frameHeight = bossFrames[1]:GetHeight()
    local containerHeight = (frameHeight + layout[5]) * #bossFrames - layout[5]
    local offsetY = containerHeight * layoutConfig.offsetMultiplier
    if layoutConfig.isCenter then offsetY = offsetY - (frameHeight / 2) end
    local initialAnchor = AnchorUtil.CreateAnchor(layoutConfig.anchor, UIParent, layout[2], layout[3], layout[4] + offsetY)
    AnchorUtil.VerticalLayout(bossFrames, initialAnchor, layout[5])
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
            UUF[unit:upper() .. i].UUFLayoutUnit = "boss"
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
            UUF[unit:upper() .. i].UUFLayoutUnit = "party"
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
        local layout = UUF:GetLayoutForUnit(UUF:GetNormalizedUnit(unit)) or FrameDB.Layout
        UUF[unit:upper()]:SetPoint(layout[1], parentFrame, layout[2], layout[3], layout[4])
        UUF[unit:upper()]:SetSize(FrameDB.Width, FrameDB.Height)
    elseif unit == "targettarget" or unit == "focus" or unit == "focustarget" or unit == "pet" then
        local parentFrame = _G[UUF.db.profile.Units[unit].Frame.AnchorParent] or UIParent
        local layout = UUF:GetLayoutForUnit(UUF:GetNormalizedUnit(unit)) or FrameDB.Layout
        UUF[unit:upper()]:SetPoint(layout[1], parentFrame, layout[2], layout[3], layout[4])
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
