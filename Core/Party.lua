local _, UUF = ...
local oUF = UUF.oUF

-----------------------------------------------------------------------
-- Role Indicator
-----------------------------------------------------------------------

local roleEvtFrame = CreateFrame("Frame")
roleEvtFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
roleEvtFrame:RegisterEvent("ROLE_CHANGED_INFORM")
roleEvtFrame:RegisterEvent("PLAYER_ROLES_ASSIGNED")
roleEvtFrame:SetScript("OnEvent", function()
    for i = 1, UUF.MAX_PARTY_MEMBERS do
        local partyFrame = UUF["PARTY"..i]
        if partyFrame and UUF.db.profile.Units.party.Indicators.Role.Enabled then
            UUF:UpdatePartyRoleIndicator(partyFrame, "party"..i)
        end
    end
end)

function UUF:CreateUnitRoleIndicator(unitFrame, unit)
    local RoleDB = UUF.db.profile.Units.party.Indicators.Role
    if not RoleDB then return end
    unitFrame.RoleIndicator = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit).."_RoleIndicator", "OVERLAY")
    unitFrame.RoleIndicator:SetSize(RoleDB.Size, RoleDB.Size)
    unitFrame.RoleIndicator:SetPoint(RoleDB.Layout[1], unitFrame.HighLevelContainer, RoleDB.Layout[2], RoleDB.Layout[3], RoleDB.Layout[4])
    unitFrame.RoleIndicator:Hide()
end

function UUF:UpdateUnitRoleIndicator(unitFrame, unit)
    local RoleDB = UUF.db.profile.Units.party.Indicators.Role
    if not unitFrame or not unitFrame.RoleIndicator or not RoleDB then return end
    unitFrame.RoleIndicator:SetSize(RoleDB.Size, RoleDB.Size)
    unitFrame.RoleIndicator:ClearAllPoints()
    unitFrame.RoleIndicator:SetPoint(RoleDB.Layout[1], unitFrame.HighLevelContainer, RoleDB.Layout[2], RoleDB.Layout[3], RoleDB.Layout[4])
    UUF:UpdatePartyRoleIndicator(unitFrame, unit)
end

function UUF:UpdatePartyRoleIndicator(unitFrame, unit)
    local RoleDB = UUF.db.profile.Units.party.Indicators.Role
    if not unitFrame or not unitFrame.RoleIndicator or not RoleDB then return end
    if not RoleDB.Enabled then
        unitFrame.RoleIndicator:Hide()
        return
    end
    local role = UnitGroupRolesAssigned(unit)
    if role == "TANK" then
        unitFrame.RoleIndicator:SetAtlas("roleIcon-tank", true)
        unitFrame.RoleIndicator:Show()
    elseif role == "HEALER" then
        unitFrame.RoleIndicator:SetAtlas("roleIcon-healer", true)
        unitFrame.RoleIndicator:Show()
    elseif role == "DAMAGER" then
        unitFrame.RoleIndicator:SetAtlas("roleIcon-dps", true)
        unitFrame.RoleIndicator:Show()
    else
        unitFrame.RoleIndicator:Hide()
    end
end

-----------------------------------------------------------------------
-- Summon Indicator
-----------------------------------------------------------------------

local summonEvtFrame = CreateFrame("Frame")
summonEvtFrame:RegisterEvent("INCOMING_SUMMON_CHANGED")
summonEvtFrame:SetScript("OnEvent", function()
    for i = 1, UUF.MAX_PARTY_MEMBERS do
        local partyFrame = UUF["PARTY"..i]
        if partyFrame and UUF.db.profile.Units.party.Indicators.Summon.Enabled then
            UUF:UpdatePartySummonIndicator(partyFrame, "party"..i)
        end
    end
end)

function UUF:CreateUnitSummonIndicator(unitFrame, unit)
    local SummonDB = UUF.db.profile.Units.party.Indicators.Summon
    if not SummonDB then return end
    unitFrame.SummonIndicator = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit).."_SummonIndicator", "OVERLAY")
    unitFrame.SummonIndicator:SetSize(SummonDB.Size, SummonDB.Size)
    unitFrame.SummonIndicator:SetAtlas("Summon_Arrow", true)
    unitFrame.SummonIndicator:SetPoint(SummonDB.Layout[1], unitFrame.HighLevelContainer, SummonDB.Layout[2], SummonDB.Layout[3], SummonDB.Layout[4])
    unitFrame.SummonIndicator:Hide()
end

function UUF:UpdateUnitSummonIndicator(unitFrame, unit)
    local SummonDB = UUF.db.profile.Units.party.Indicators.Summon
    if not unitFrame or not unitFrame.SummonIndicator or not SummonDB then return end
    unitFrame.SummonIndicator:SetSize(SummonDB.Size, SummonDB.Size)
    unitFrame.SummonIndicator:ClearAllPoints()
    unitFrame.SummonIndicator:SetPoint(SummonDB.Layout[1], unitFrame.HighLevelContainer, SummonDB.Layout[2], SummonDB.Layout[3], SummonDB.Layout[4])
    UUF:UpdatePartySummonIndicator(unitFrame, unit)
end

function UUF:UpdatePartySummonIndicator(unitFrame, unit)
    local SummonDB = UUF.db.profile.Units.party.Indicators.Summon
    if not unitFrame or not unitFrame.SummonIndicator or not SummonDB then return end
    if not SummonDB.Enabled then
        unitFrame.SummonIndicator:Hide()
        return
    end
    if C_IncomingSummon.HasIncomingSummon(unit) then
        unitFrame.SummonIndicator:Show()
    else
        unitFrame.SummonIndicator:Hide()
    end
end

-----------------------------------------------------------------------
-- Phase Indicator
-----------------------------------------------------------------------

local phaseEvtFrame = CreateFrame("Frame")
phaseEvtFrame:RegisterEvent("UNIT_PHASE")
phaseEvtFrame:SetScript("OnEvent", function(_, _, unit)
    if not unit then return end
    local unitIndex = unit:match("^party(%d+)$")
    if not unitIndex then return end
    local partyFrame = UUF["PARTY"..unitIndex]
    if partyFrame and UUF.db.profile.Units.party.Indicators.Phase.Enabled then
        UUF:UpdatePartyPhaseIndicator(partyFrame, unit)
    end
end)

function UUF:CreateUnitPhaseIndicator(unitFrame, unit)
    local PhaseDB = UUF.db.profile.Units.party.Indicators.Phase
    if not PhaseDB then return end
    unitFrame.PhaseIndicator = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit).."_PhaseIndicator", "OVERLAY")
    unitFrame.PhaseIndicator:SetSize(PhaseDB.Size, PhaseDB.Size)
    unitFrame.PhaseIndicator:SetAtlas("questtracker-eye", true)
    unitFrame.PhaseIndicator:SetPoint(PhaseDB.Layout[1], unitFrame.HighLevelContainer, PhaseDB.Layout[2], PhaseDB.Layout[3], PhaseDB.Layout[4])
    unitFrame.PhaseIndicator:Hide()
end

function UUF:UpdateUnitPhaseIndicator(unitFrame, unit)
    local PhaseDB = UUF.db.profile.Units.party.Indicators.Phase
    if not unitFrame or not unitFrame.PhaseIndicator or not PhaseDB then return end
    unitFrame.PhaseIndicator:SetSize(PhaseDB.Size, PhaseDB.Size)
    unitFrame.PhaseIndicator:ClearAllPoints()
    unitFrame.PhaseIndicator:SetPoint(PhaseDB.Layout[1], unitFrame.HighLevelContainer, PhaseDB.Layout[2], PhaseDB.Layout[3], PhaseDB.Layout[4])
    UUF:UpdatePartyPhaseIndicator(unitFrame, unit)
end

function UUF:UpdatePartyPhaseIndicator(unitFrame, unit)
    local PhaseDB = UUF.db.profile.Units.party.Indicators.Phase
    if not unitFrame or not unitFrame.PhaseIndicator or not PhaseDB then return end
    if not PhaseDB.Enabled then
        unitFrame.PhaseIndicator:Hide()
        return
    end
    if UnitIsConnected(unit) and not UnitIsVisible(unit) then
        unitFrame.PhaseIndicator:Show()
    else
        unitFrame.PhaseIndicator:Hide()
    end
end

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
    UUF:CreateUnitPhaseIndicator(unitFrame, unit)
    UUF:CreateUnitMouseoverIndicator(unitFrame, unit)
    UUF:CreateUnitTargetGlowIndicator(unitFrame, unit)
    UUF:CreateUnitAuras(unitFrame, unit)
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
    UUF:UpdateUnitPhaseIndicator(unitFrame, unit)
    UUF:UpdateUnitMouseoverIndicator(unitFrame, unit)
    UUF:UpdateUnitTargetGlowIndicator(unitFrame, unit)
    UUF:UpdateUnitAuras(unitFrame, unit)
    UUF:UpdateUnitTags()
    unitFrame:SetFrameStrata(UnitDB.Frame.FrameStrata)
end

-----------------------------------------------------------------------
-- Layout Party Frames
-----------------------------------------------------------------------

function UUF:LayoutPartyFrames()
    local Frame = UUF.db.profile.Units.party.Frame
    if #UUF.PARTY_FRAMES == 0 then return end
    local partyFrames = UUF.PARTY_FRAMES
    if Frame.GrowthDirection == "UP" or Frame.GrowthDirection == "LEFT" then
        partyFrames = {}
        for i = #UUF.PARTY_FRAMES, 1, -1 do partyFrames[#partyFrames+1] = UUF.PARTY_FRAMES[i] end
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
        RegisterUnitWatch(UUF["PARTY"..i])
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
    for i = 1, UUF.MAX_PARTY_MEMBERS do
        local unitFrame = UUF["PARTY"..i]
        if unitFrame then (UnitDB.Enabled and RegisterUnitWatch or UnregisterUnitWatch)(unitFrame) unitFrame:SetShown(UnitDB.Enabled) end
    end
end
