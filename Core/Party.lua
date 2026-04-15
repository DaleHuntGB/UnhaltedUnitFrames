local _, UUF = ...
local oUF = UUF.oUF

-----------------------------------------------------------------------
-- Create & Update Party Unit Frame
-----------------------------------------------------------------------

function UUF:CreatePartyUnitFrame(unitFrame, unit)
    UUF:CreateUnitContainer(unitFrame, unit)
    UUF:CreateUnitCastBar(unitFrame, unit)
    UUF:CreateUnitHealthBar(unitFrame, unit)
    UUF:CreateUnitDispelHighlight(unitFrame, unit)
    UUF:CreateUnitHealPrediction(unitFrame, unit)
    UUF:CreateUnitPortrait(unitFrame, unit)
    UUF:CreateUnitPowerBar(unitFrame, unit)
    UUF:CreateUnitRaidTargetMarker(unitFrame, unit)
    UUF:CreateUnitLeaderAssistantIndicator(unitFrame, unit)
    UUF:CreateUnitRoleIndicator(unitFrame, unit)
    UUF:CreateUnitSummonIndicator(unitFrame, unit)
    UUF:CreateUnitReadyCheckIndicator(unitFrame, unit)
    UUF:CreateUnitResurrectIndicator(unitFrame, unit)
    UUF:CreateUnitPhaseIndicator(unitFrame, unit)
    UUF:CreateUnitMouseoverIndicator(unitFrame, unit)
    UUF:CreateUnitTargetGlowIndicator(unitFrame, unit)
    UUF:CreateUnitAuras(unitFrame, unit)
    UUF:CreateUnitPrivateAuras(unitFrame, unit)
    UUF:CreateUnitTags(unitFrame, unit)
    unitFrame:RegisterForClicks("AnyUp")
    unitFrame:SetAttribute("*type1", "target")
    unitFrame:SetAttribute("*type2", "togglemenu")
    unitFrame:HookScript("OnEnter", UnitFrame_OnEnter)
    unitFrame:HookScript("OnLeave", UnitFrame_OnLeave)
    return unitFrame
end

function UUF:UpdatePartyUnitFrame(unitFrame, unit)
    local UnitDB = UUF.db.profile.Units.party
    UUF:UpdateUnitCastBar(unitFrame, unit)
    UUF:UpdateUnitHealthBar(unitFrame, unit)
    UUF:UpdateUnitHealPrediction(unitFrame, unit)
    UUF:UpdateUnitPortrait(unitFrame, unit)
    UUF:UpdateUnitPowerBar(unitFrame, unit)
    UUF:UpdateUnitRaidTargetMarker(unitFrame, unit)
    UUF:UpdateUnitLeaderAssistantIndicator(unitFrame, unit)
    UUF:UpdateUnitRoleIndicator(unitFrame, unit)
    UUF:UpdateUnitSummonIndicator(unitFrame, unit)
    UUF:UpdateUnitReadyCheckIndicator(unitFrame, unit)
    UUF:UpdateUnitResurrectIndicator(unitFrame, unit)
    UUF:UpdateUnitPhaseIndicator(unitFrame, unit)
    UUF:UpdateUnitMouseoverIndicator(unitFrame, unit)
    UUF:UpdateUnitTargetGlowIndicator(unitFrame, unit)
    UUF:UpdateUnitAuras(unitFrame, unit)
    UUF:UpdateUnitPrivateAuras(unitFrame, unit)
    UUF:UpdateUnitTags()
    unitFrame:SetFrameStrata(UnitDB.Frame.FrameStrata)
end

-----------------------------------------------------------------------
-- Layout Party Frames
-----------------------------------------------------------------------

function UUF:LayoutPartyFrames()
    local Frame = UUF.db.profile.Units.party.Frame
    if #UUF.PARTY_FRAMES == 0 then return end

    local partyFrames = {}
    for i = 1, #UUF.PARTY_FRAMES do
        local unitFrame = UUF.PARTY_FRAMES[i]
        if unitFrame and (UUF.PARTY_TEST_MODE or UnitExists(unitFrame.unit)) then
            partyFrames[#partyFrames + 1] = unitFrame
        end
    end
    if #partyFrames == 0 then return end

    if Frame.SortBy == "NAME" then
        table.sort(partyFrames, function(a, b)
            local nameA = UnitName(a.unit) or ""
            local nameB = UnitName(b.unit) or ""
            return nameA < nameB
        end)
    elseif Frame.SortBy == "ROLE" then
        local rolePriority = {}
        for i, role in ipairs(Frame.SortOrder) do rolePriority[role] = i end
        rolePriority["NONE"] = #Frame.SortOrder + 1
        table.sort(partyFrames, function(a, b)
            local roleA = UnitGroupRolesAssigned(a.unit) or "NONE"
            local roleB = UnitGroupRolesAssigned(b.unit) or "NONE"
            local prioA = rolePriority[roleA] or rolePriority["NONE"]
            local prioB = rolePriority[roleB] or rolePriority["NONE"]
            if prioA == prioB then return a.unit < b.unit end
            return prioA < prioB
        end)
    end

    if Frame.GrowthDirection == "UP" or Frame.GrowthDirection == "LEFT" then
        local reversed = {}
        for i = #partyFrames, 1, -1 do reversed[#reversed+1] = partyFrames[i] end
        partyFrames = reversed
    end
    local layoutConfig = UUF.LayoutConfig[Frame.Layout[1]]
    if Frame.GrowthDirection == "LEFT" or Frame.GrowthDirection == "RIGHT" then
        local frameWidth = partyFrames[1]:GetWidth()
        local containerWidth = (frameWidth + Frame.Layout[5]) * #partyFrames - Frame.Layout[5]
        local offsetX = containerWidth * layoutConfig.offsetMultiplier
        if layoutConfig.isCenter then offsetX = offsetX - (frameWidth / 2) end
        local initialAnchor = AnchorUtil.CreateAnchor(layoutConfig.anchor, UIParent, Frame.Layout[2], Frame.Layout[3] + offsetX, Frame.Layout[4])
        AnchorUtil.HorizontalLayout(partyFrames, initialAnchor, Frame.Layout[5])
    else
        local frameHeight = partyFrames[1]:GetHeight()
        local containerHeight = (frameHeight + Frame.Layout[5]) * #partyFrames - Frame.Layout[5]
        local offsetY = containerHeight * layoutConfig.offsetMultiplier
        if layoutConfig.isCenter then offsetY = offsetY - (frameHeight / 2) end
        local initialAnchor = AnchorUtil.CreateAnchor(layoutConfig.anchor, UIParent, Frame.Layout[2], Frame.Layout[3], Frame.Layout[4] + offsetY)
        AnchorUtil.VerticalLayout(partyFrames, initialAnchor, Frame.Layout[5])
    end
end

-----------------------------------------------------------------------
-- Spawn Party Frames
-----------------------------------------------------------------------

function UUF:SpawnPartyFrames()
    local UnitDB = UUF.db.profile.Units.party
    if not UnitDB or not UnitDB.Enabled then
        if UnitDB and UnitDB.ForceHideBlizzard then oUF:DisableBlizzard("party") end
        return
    end
    local FrameDB = UnitDB.Frame
    for i = 1, UUF.MAX_PARTY_MEMBERS do
        local unit = "party"..i
        oUF:RegisterStyle(UUF:FetchFrameName(unit), function(unitFrame) UUF:CreatePartyUnitFrame(unitFrame, unit) end)
        oUF:SetActiveStyle(UUF:FetchFrameName(unit))
        UUF["PARTY"..i] = oUF:Spawn(unit, UUF:FetchFrameName(unit))
        UUF["PARTY"..i]:SetSize(FrameDB.Width, FrameDB.Height)
        UUF["PARTY"..i]:SetFrameStrata(FrameDB.FrameStrata)
        UUF.PARTY_FRAMES[i] = UUF["PARTY"..i]
        UUF:RegisterTargetGlowIndicatorFrame(UUF:FetchFrameName(unit), unit)
        UUF:RegisterRangeFrame(UUF:FetchFrameName(unit), unit)
        UUF:RegisterDispelHighlightEvents(UUF["PARTY"..i], unit)
        -- RegisterUnitWatch is intentionally omitted; GroupTypeEventFrame in Raid.lua
        -- manages party frame visibility based on whether the player is in a party or raid.
    end
    UUF:LayoutPartyFrames()
end

-----------------------------------------------------------------------
-- Update Party Frames
-----------------------------------------------------------------------

function UUF:UpdatePartyFrames()
    for i in pairs(UUF.PARTY_FRAMES) do
        UUF:UpdatePartyUnitFrame(UUF["PARTY"..i], "party"..i)
    end
    UUF:CreateTestPartyFrames()
    UUF:LayoutPartyFrames()
end

-----------------------------------------------------------------------
-- Toggle Party Frame Visibility
-----------------------------------------------------------------------

function UUF:TogglePartyFrameVisibility()
    local UnitDB = UUF.db.profile.Units.party
    if not UnitDB then return end
    local inParty = IsInGroup() and not IsInRaid()
    for i = 1, UUF.MAX_PARTY_MEMBERS do
        local unitFrame = UUF["PARTY"..i]
        if unitFrame then
            if UnitDB.Enabled and inParty then
                RegisterUnitWatch(unitFrame)
            else
                UnregisterUnitWatch(unitFrame)
                unitFrame:Hide()
            end
        end
    end
end
