local _, UUF = ...
local oUF = UUF.oUF

-----------------------------------------------------------------------
-- Create & Update Raid Unit Frame
-----------------------------------------------------------------------

function UUF:CreateRaidUnitFrame(unitFrame, unit)
    UUF:CreateUnitContainer(unitFrame, unit)
    UUF:CreateUnitHealthBar(unitFrame, unit)
    UUF:CreateUnitDispelHighlight(unitFrame, unit)
    UUF:CreateUnitHealPrediction(unitFrame, unit)
    UUF:CreateUnitPowerBar(unitFrame, unit)
    UUF:CreateUnitRaidTargetMarker(unitFrame, unit)
    UUF:CreateUnitLeaderAssistantIndicator(unitFrame, unit)
    UUF:CreateRaidRoleIndicator(unitFrame, unit)
    UUF:CreateRaidSummonIndicator(unitFrame, unit)
    UUF:CreateRaidPhaseIndicator(unitFrame, unit)
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

function UUF:UpdateRaidUnitFrame(unitFrame, unit)
    local UnitDB = UUF.db.profile.Units.raid
    UUF:UpdateUnitHealthBar(unitFrame, unit)
    UUF:UpdateUnitHealPrediction(unitFrame, unit)
    UUF:UpdateUnitPowerBar(unitFrame, unit)
    UUF:UpdateUnitRaidTargetMarker(unitFrame, unit)
    UUF:UpdateUnitLeaderAssistantIndicator(unitFrame, unit)
    UUF:UpdateRaidRoleIndicatorSettings(unitFrame, unit)
    UUF:UpdateRaidSummonIndicatorSettings(unitFrame, unit)
    UUF:UpdateRaidPhaseIndicatorSettings(unitFrame, unit)
    UUF:UpdateUnitMouseoverIndicator(unitFrame, unit)
    UUF:UpdateUnitTargetGlowIndicator(unitFrame, unit)
    UUF:UpdateUnitAuras(unitFrame, unit)
    UUF:UpdateUnitTags()
    unitFrame:SetFrameStrata(UnitDB.Frame.FrameStrata)
end

-----------------------------------------------------------------------
-- Layout Raid Frames
-- Layout[1] = AnchorFrom, Layout[2] = AnchorTo
-- Layout[3] = X, Layout[4] = Y
-- Layout[5] = Vertical Spacing, Layout[6] = Horizontal Spacing
-- GrowthDirection: down/up is the within-group (slot) direction
-- left/right is the between-group (column) direction
-- e.g. DOWN_RIGHT = slots go downward, groups go rightward
-----------------------------------------------------------------------

function UUF:LayoutRaidFrames()
    local Frame = UUF.db.profile.Units.raid.Frame
    if #UUF.RAID_FRAMES == 0 then return end

    local frameWidth     = Frame.Width
    local frameHeight    = Frame.Height
    local vSpacing       = Frame.Layout[5]
    local hSpacing       = Frame.Layout[6]
    local growDir        = Frame.GrowthDirection
    local framesPerGroup = 5
    local sortBy         = Frame.SortBy or "GROUP"

    local orderedFrames = {}
    for i = 1, UUF.MAX_RAID_MEMBERS do
        if UUF.RAID_FRAMES[i] then
            orderedFrames[#orderedFrames + 1] = UUF.RAID_FRAMES[i]
        end
    end

    if sortBy == "GROUP" then
        table.sort(orderedFrames, function(a, b)
            local idxA = tonumber(a.unit:match("^raid(%d+)$")) or 0
            local idxB = tonumber(b.unit:match("^raid(%d+)$")) or 0
            local _, _, subgroupA = GetRaidRosterInfo(idxA)
            local _, _, subgroupB = GetRaidRosterInfo(idxB)
            subgroupA = subgroupA or 9
            subgroupB = subgroupB or 9
            if subgroupA == subgroupB then return idxA < idxB end
            return subgroupA < subgroupB
        end)
    elseif sortBy == "ROLE" then
        local rolePriority = { TANK = 1, HEALER = 2, DAMAGER = 3, NONE = 4 }
        table.sort(orderedFrames, function(a, b)
            local roleA = UnitGroupRolesAssigned(a.unit) or "NONE"
            local roleB = UnitGroupRolesAssigned(b.unit) or "NONE"
            local prioA = rolePriority[roleA] or 4
            local prioB = rolePriority[roleB] or 4
            if prioA == prioB then
                return (tonumber(a.unit:match("^raid(%d+)$")) or 0) < (tonumber(b.unit:match("^raid(%d+)$")) or 0)
            end
            return prioA < prioB
        end)
    end
    -- SortBy == "INDEX": orderedFrames already in raid1..raid40 order; no sort needed

    for idx, raidFrame in ipairs(orderedFrames) do
        local i          = idx - 1
        local col        = math.floor(i / framesPerGroup)
        local row        = i % framesPerGroup

        local xOff, yOff

        if growDir == "DOWN_RIGHT" then
            xOff =  col * (frameWidth  + hSpacing)
            yOff = -row * (frameHeight + vSpacing)
        elseif growDir == "DOWN_LEFT" then
            xOff = -col * (frameWidth  + hSpacing)
            yOff = -row * (frameHeight + vSpacing)
        elseif growDir == "UP_RIGHT" then
            xOff =  col * (frameWidth  + hSpacing)
            yOff =  row * (frameHeight + vSpacing)
        elseif growDir == "UP_LEFT" then
            xOff = -col * (frameWidth  + hSpacing)
            yOff =  row * (frameHeight + vSpacing)
        elseif growDir == "RIGHT_DOWN" then
            xOff =  row * (frameWidth  + hSpacing)
            yOff = -col * (frameHeight + vSpacing)
        elseif growDir == "RIGHT_UP" then
            xOff =  row * (frameWidth  + hSpacing)
            yOff =  col * (frameHeight + vSpacing)
        elseif growDir == "LEFT_DOWN" then
            xOff = -row * (frameWidth  + hSpacing)
            yOff = -col * (frameHeight + vSpacing)
        elseif growDir == "LEFT_UP" then
            xOff = -row * (frameWidth  + hSpacing)
            yOff =  col * (frameHeight + vSpacing)
        else
            xOff =  col * (frameWidth  + hSpacing)
            yOff = -row * (frameHeight + vSpacing)
        end

        raidFrame:ClearAllPoints()
        raidFrame:SetPoint(Frame.Layout[1], UIParent, Frame.Layout[2], Frame.Layout[3] + xOff, Frame.Layout[4] + yOff)
    end
end

-----------------------------------------------------------------------
-- Spawn Raid Frames
-- All 40 frames are created on load. RegisterUnitWatch / UnregisterUnitWatch
-- handles visibility based on whether the unit is in the group.
-- Frames whose group index exceeds GroupsToShow are never registered.
-----------------------------------------------------------------------

function UUF:SpawnRaidFrames()
    local UnitDB = UUF.db.profile.Units.raid
    if not UnitDB then return end
    if UnitDB.ForceHideBlizzard then oUF:DisableBlizzard("raid") end
    if not UnitDB.Enabled then return end

    local FrameDB     = UnitDB.Frame
    local groupsToShow = tonumber(FrameDB.GroupsToShow) or 8
    local framesPerGroup = 5

    for i = 1, UUF.MAX_RAID_MEMBERS do
        local unit = "raid"..i
        oUF:RegisterStyle(UUF:FetchFrameName(unit), function(unitFrame) UUF:CreateRaidUnitFrame(unitFrame, unit) end)
        oUF:SetActiveStyle(UUF:FetchFrameName(unit))
        UUF["RAID"..i] = oUF:Spawn(unit, UUF:FetchFrameName(unit))
        UUF["RAID"..i]:SetSize(FrameDB.Width, FrameDB.Height)
        UUF["RAID"..i]:SetFrameStrata(FrameDB.FrameStrata)
        UUF.RAID_FRAMES[i] = UUF["RAID"..i]
        UUF:RegisterTargetGlowIndicatorFrame(UUF:FetchFrameName(unit), unit)
        UUF:RegisterRangeFrame(UUF:FetchFrameName(unit), unit)
        UUF:RegisterDispelHighlightEvents(UUF["RAID"..i], unit)

        local groupIndex = math.ceil(i / framesPerGroup)
        if groupIndex <= groupsToShow then
            RegisterUnitWatch(UUF["RAID"..i])
        end
    end

    UUF:LayoutRaidFrames()
end

-----------------------------------------------------------------------
-- Update Raid Frames
-----------------------------------------------------------------------

function UUF:UpdateRaidFrames()
    local UnitDB  = UUF.db.profile.Units.raid
    local FrameDB = UnitDB.Frame
    local groupsToShow   = tonumber(FrameDB.GroupsToShow) or 8
    local framesPerGroup = 5

    for i = 1, UUF.MAX_RAID_MEMBERS do
        local raidFrame = UUF["RAID"..i]
        if raidFrame then
            UUF:UpdateRaidUnitFrame(raidFrame, "raid"..i)
            raidFrame:SetSize(FrameDB.Width, FrameDB.Height)

            local groupIndex = math.ceil(i / framesPerGroup)
            if UnitDB.Enabled and groupIndex <= groupsToShow then
                RegisterUnitWatch(raidFrame)
            else
                UnregisterUnitWatch(raidFrame)
                raidFrame:Hide()
            end
        end
    end

    UUF:CreateTestRaidFrames()
    UUF:LayoutRaidFrames()
end

-----------------------------------------------------------------------
-- Toggle Raid Frame Visibility
-----------------------------------------------------------------------

function UUF:ToggleRaidFrameVisibility()
    local UnitDB         = UUF.db.profile.Units.raid
    if not UnitDB then return end
    local groupsToShow   = tonumber(UnitDB.Frame.GroupsToShow) or 8
    local framesPerGroup = 5

    for i = 1, UUF.MAX_RAID_MEMBERS do
        local raidFrame = UUF["RAID"..i]
        if raidFrame then
            local groupIndex = math.ceil(i / framesPerGroup)
            if UnitDB.Enabled and groupIndex <= groupsToShow then
                RegisterUnitWatch(raidFrame)
            else
                UnregisterUnitWatch(raidFrame)
                raidFrame:Hide()
            end
        end
    end
end
