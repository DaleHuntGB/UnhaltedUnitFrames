local _, UUF = ...
local oUF = UUF.oUF

local function ApplyScripts(unitFrame)
    unitFrame:RegisterForClicks("AnyUp")
    unitFrame:SetAttribute("*type1", "target")
    unitFrame:SetAttribute("*type2", "togglemenu")
    unitFrame:HookScript("OnEnter", UnitFrame_OnEnter)
    unitFrame:HookScript("OnLeave", UnitFrame_OnLeave)
end

local function UsesDispelHighlight(unit)
    local normalizedUnit = UUF:GetNormalizedUnit(unit)
    return normalizedUnit == "player" or normalizedUnit == "target" or normalizedUnit == "focus" or normalizedUnit == "party"
end

local function UsesLeaderAssistantIndicator(unit)
    local normalizedUnit = UUF:GetNormalizedUnit(unit)
    return normalizedUnit == "player" or normalizedUnit == "target" or normalizedUnit == "party"
end

local function UsesCombatIndicator(unit)
    local normalizedUnit = UUF:GetNormalizedUnit(unit)
    return normalizedUnit == "player" or normalizedUnit == "target"
end

local function UsesTargetIndicator(unit)
    local normalizedUnit = UUF:GetNormalizedUnit(unit)
    return normalizedUnit ~= "party"
end

function UUF:RefreshPartyFrames()
    wipe(UUF.PARTY_FRAMES)
    if not UUF.PARTY then return UUF.PARTY_FRAMES end

    for _, child in ipairs({ UUF.PARTY:GetChildren() }) do
        local unit = child.unit or child:GetAttribute("unit")
        local unitIndex = unit and tonumber(unit:match("^party(%d+)$"))
        if unitIndex then
            UUF.PARTY_FRAMES[unitIndex] = child
        end
    end

    return UUF.PARTY_FRAMES
end

function UUF:ForEachPartyFrame(callback)
    if type(callback) ~= "function" then return end
    local partyFrames = UUF:RefreshPartyFrames()
    for i = 1, UUF.MAX_PARTY_FRAMES do
        local unitFrame = partyFrames[i]
        if unitFrame then
            callback(unitFrame, "party" .. i, i)
        end
    end
end

function UUF:ForEachManagedUnitFrame(unit, callback)
    if type(callback) ~= "function" or not unit then return end

    if unit == "boss" then
        for i = 1, UUF.MAX_BOSS_FRAMES do
            local unitFrame = UUF["BOSS" .. i]
            if unitFrame then
                callback(unitFrame, "boss" .. i, i)
            end
        end
        return
    end

    if unit == "party" then
        UUF:ForEachPartyFrame(callback)
        return
    end

    local unitFrame = UUF[unit:upper()]
    if unitFrame then
        callback(unitFrame, unit, 1)
    end
end

local function FinalizeSpawnedUnitFrame(unitFrame, unit)
    if not unitFrame or not unit then return end

    local normalizedUnit = UUF:GetNormalizedUnit(unit)
    local frameDB = UUF.db.profile.Units[normalizedUnit] and UUF.db.profile.Units[normalizedUnit].Frame
    if not frameDB then return end

    unitFrame:SetSize(frameDB.Width, frameDB.Height)
    unitFrame:SetFrameStrata(frameDB.FrameStrata)
    if UsesTargetIndicator(unit) then
        UUF:RegisterTargetGlowIndicatorFrame(unitFrame, unit)
    end

    if normalizedUnit ~= "player" and not UUF:IsRangeFrameRegistered(unit) then
        UUF:RegisterRangeFrame(unitFrame, unit)
    end

    if UsesDispelHighlight(unit) then
        UUF:RegisterDispelHighlightEvents(unitFrame, unit)
    end
end

function UUF:LayoutPartyFrames()
    local frameDB = UUF.db.profile.Units.party and UUF.db.profile.Units.party.Frame
    if not UUF.PARTY or not frameDB then return end

    local spacing = frameDB.Layout[5] or 0
    local growthDirection = frameDB.GrowthDirection or "DOWN"
    local growthConfig = growthDirection == "UP" and {
        point = "BOTTOM",
        xOffset = 0,
        yOffset = spacing,
        width = frameDB.Width,
        height = (frameDB.Height + spacing) * UUF.MAX_PARTY_FRAMES - spacing,
    } or {
        point = "TOP",
        xOffset = 0,
        yOffset = -spacing,
        width = frameDB.Width,
        height = (frameDB.Height + spacing) * UUF.MAX_PARTY_FRAMES - spacing,
    }

    UUF.PARTY:ClearAllPoints()
    UUF.PARTY:SetPoint(frameDB.Layout[1], UIParent, frameDB.Layout[2], frameDB.Layout[3], frameDB.Layout[4])
    UUF.PARTY:SetAttribute("point", growthConfig.point)
    UUF.PARTY:SetAttribute("xOffset", growthConfig.xOffset)
    UUF.PARTY:SetAttribute("yOffset", growthConfig.yOffset)
    UUF.PARTY:SetSize(growthConfig.width, growthConfig.height)

    UUF:ForEachPartyFrame(function(unitFrame)
        unitFrame:SetSize(frameDB.Width, frameDB.Height)
        unitFrame:SetFrameStrata(frameDB.FrameStrata)
    end)
end

function UUF:CreateUnitFrame(unitFrame, unit)
    if not unit or not unitFrame then return end
    local normalizedUnit = UUF:GetNormalizedUnit(unit)
    local isPlayer = normalizedUnit == "player"
    local isTargetTarget = normalizedUnit == "targettarget"
    local isFocusTarget = normalizedUnit == "focustarget"

    UUF:CreateUnitContainer(unitFrame, unit)
    if not isTargetTarget and not isFocusTarget then UUF:CreateUnitCastBar(unitFrame, unit) end
    UUF:CreateUnitHealthBar(unitFrame, unit)
    if UsesDispelHighlight(unit) then UUF:CreateUnitDispelHighlight(unitFrame, unit) end
    UUF:CreateUnitHealPrediction(unitFrame, unit)
    if not isTargetTarget and not isFocusTarget then UUF:CreateUnitPortrait(unitFrame, unit) end
    UUF:CreateUnitPowerBar(unitFrame, unit)
    if isPlayer then UUF:CreateUnitAlternativePowerBar(unitFrame, unit) end
    if isPlayer then UUF:CreateUnitSecondaryPowerBar(unitFrame, unit) end
    UUF:CreateUnitRaidTargetMarker(unitFrame, unit)
    if UsesLeaderAssistantIndicator(unit) then UUF:CreateUnitLeaderAssistantIndicator(unitFrame, unit) end
    if UsesCombatIndicator(unit) then UUF:CreateUnitCombatIndicator(unitFrame, unit) end
    if isPlayer then UUF:CreateUnitRestingIndicator(unitFrame, unit) end
    -- if isPlayer then UUF:CreateUnitTotems(unitFrame, unit) end
    UUF:CreateUnitMouseoverIndicator(unitFrame, unit)
    if UsesTargetIndicator(unit) then UUF:CreateUnitTargetGlowIndicator(unitFrame, unit) end
    UUF:CreateUnitAuras(unitFrame, unit)
    UUF:CreateUnitTags(unitFrame, unit)
    ApplyScripts(unitFrame)
    return unitFrame
end

function UUF:LayoutBossFrames()
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

    oUF:RegisterStyle(UUF:FetchFrameName(unit), function(unitFrame, objectUnit)
        local actualUnit = objectUnit or unit
        UUF:CreateUnitFrame(unitFrame, actualUnit)
        FinalizeSpawnedUnitFrame(unitFrame, actualUnit)
    end)
    oUF:SetActiveStyle(UUF:FetchFrameName(unit))

    if unit == "boss" then
        for i = 1, UUF.MAX_BOSS_FRAMES do
            UUF[unit:upper() .. i] = oUF:Spawn(unit .. i, UUF:FetchFrameName(unit .. i))
            UUF.BOSS_FRAMES[i] = UUF[unit:upper() .. i]
        end
        UUF:LayoutBossFrames()
    elseif unit == "party" then
        UUF[unit:upper()] = oUF:SpawnHeader(
            UUF:FetchFrameName(unit),
            nil,
            "showParty", true,
            "showPlayer", false,
            "showRaid", false,
            "sortMethod", "INDEX",
            "oUF-onlyProcessChildren", true
        )
        UUF.PARTY = UUF[unit:upper()]
        UUF:LayoutPartyFrames()
    else
        UUF[unit:upper()] = oUF:Spawn(unit, UUF:FetchFrameName(unit))
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

    if unit == "party" then
        UUF[unit:upper()]:SetShown(UnitDB.Enabled)
    elseif unit == "boss" then
        for i = 1, UUF.MAX_BOSS_FRAMES do
            local bossFrame = UUF[unit:upper() .. i]
            if bossFrame then
                (UnitDB.Enabled and RegisterUnitWatch or UnregisterUnitWatch)(bossFrame)
                bossFrame:SetShown(UnitDB.Enabled)
            end
        end
    elseif UnitDB.Enabled then
        RegisterUnitWatch(UUF[unit:upper()])
        UUF[unit:upper()]:Show()
    else
        UnregisterUnitWatch(UUF[unit:upper()])
        UUF[unit:upper()]:Hide()
    end

    return UUF[unit:upper()]
end

function UUF:UpdateUnitFrame(unitFrame, unit)
    local normalizedUnit = UUF:GetNormalizedUnit(unit)
    if normalizedUnit == "party" and unit == "party" then
        UUF:UpdatePartyFrames()
        return
    end

    local UnitDB = UUF.db.profile.Units[normalizedUnit]
    local isPlayer = normalizedUnit == "player"
    local isTarget = normalizedUnit == "target"
    local isTargetTarget = normalizedUnit == "targettarget"
    local isFocusTarget = normalizedUnit == "focustarget"

    if not isTargetTarget and not isFocusTarget then UUF:UpdateUnitCastBar(unitFrame, unit) end
    UUF:UpdateUnitHealthBar(unitFrame, unit)
    UUF:UpdateUnitHealPrediction(unitFrame, unit)
    if not isTargetTarget and not isFocusTarget then UUF:UpdateUnitPortrait(unitFrame, unit) end
    UUF:UpdateUnitPowerBar(unitFrame, unit)
    if isPlayer then UUF:UpdateUnitAlternativePowerBar(unitFrame, unit) end
    if isPlayer then UUF:UpdateUnitSecondaryPowerBar(unitFrame, unit) end
    UUF:UpdateUnitRaidTargetMarker(unitFrame, unit)
    if UsesLeaderAssistantIndicator(unit) then UUF:UpdateUnitLeaderAssistantIndicator(unitFrame, unit) end
    if UsesCombatIndicator(unit) then
        UUF:UpdateUnitCombatIndicator(unitFrame, unit)
    elseif unitFrame.CombatIndicator then
        if unitFrame:IsElementEnabled("CombatIndicator") then unitFrame:DisableElement("CombatIndicator") end
        unitFrame.CombatIndicator:Hide()
        unitFrame.CombatIndicator = nil
    end
    if isPlayer then UUF:UpdateUnitRestingIndicator(unitFrame, unit) end
    -- if isPlayer then UUF:UpdateUnitTotems(unitFrame, unit) end
    UUF:UpdateUnitMouseoverIndicator(unitFrame, unit)
    if UsesTargetIndicator(unit) then
        UUF:UpdateUnitTargetGlowIndicator(unitFrame, unit)
    elseif unitFrame.TargetIndicator then
        unitFrame.TargetIndicator:SetAlpha(0)
    end
    UUF:UpdateUnitAuras(unitFrame, unit)
    UUF:UpdateUnitTags()
    unitFrame:SetFrameStrata(UnitDB.Frame.FrameStrata)
end

function UUF:UpdateBossFrames()
    for i in pairs(UUF.BOSS_FRAMES) do
        UUF:UpdateUnitFrame(UUF["BOSS"..i], "boss"..i)
    end
    UUF:CreateTestBossFrames()
    UUF:LayoutBossFrames()
end

function UUF:UpdatePartyFrames()
    UUF:ForEachPartyFrame(function(unitFrame, actualUnit)
        UUF:UpdateUnitFrame(unitFrame, actualUnit)
    end)
    UUF:LayoutPartyFrames()
end


function UUF:UpdateAllUnitFrames()
    for unit, _ in pairs(UUF.db.profile.Units) do
        if unit == "boss" and #UUF.BOSS_FRAMES > 0 then
            UUF:UpdateBossFrames()
        elseif unit == "party" and UUF.PARTY then
            UUF:UpdatePartyFrames()
        elseif UUF[unit:upper()] then
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
            if not UUF["PARTY"] then UUF:SpawnUnitFrame(unit) end
        elseif not UUF[UnitKey] then
            UUF:SpawnUnitFrame(unit)
        end
    elseif UnitDB.ForceHideBlizzard then
        oUF:DisableBlizzard(unit)
    end

    if unit == "boss" then
        for i = 1, UUF.MAX_BOSS_FRAMES do
            local unitFrame = UUF["BOSS"..i]
            if unitFrame then (UnitDB.Enabled and RegisterUnitWatch or UnregisterUnitWatch)(unitFrame) unitFrame:SetShown(UnitDB.Enabled) end
        end
        return
    end

    if unit == "party" then
        if UUF[UnitKey] then
            UUF[UnitKey]:SetShown(UnitDB.Enabled)
            if UnitDB.Enabled then
                UUF:LayoutPartyFrames()
            end
        end
        return
    end

    local unitFrame = UUF[UnitKey]
    if not unitFrame then return end
    (UnitDB.Enabled and RegisterUnitWatch or UnregisterUnitWatch)(unitFrame)
    unitFrame:SetShown(UnitDB.Enabled)
end
