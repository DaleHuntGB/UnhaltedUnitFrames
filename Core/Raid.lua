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

    -- placements: array of { frame, col, row } to be positioned after sorting
    local placements = {}

    if sortBy == "GROUP" and IsInRaid() then
        -- Each frame is placed at a fixed column determined by its actual subgroup from
        -- GetRaidRosterInfo. Empty subgroups leave a visible gap in the layout because the
        -- next occupied group's column is offset by the correct amount. Within a subgroup,
        -- frames are ordered by ascending raid index.
        local groupSlots = {}
        for g = 1, 8 do groupSlots[g] = {} end

        for i = 1, UUF.MAX_RAID_MEMBERS do
            if UUF.RAID_FRAMES[i] then
                local _, _, subgroup = GetRaidRosterInfo(i)
                if subgroup and subgroup >= 1 and subgroup <= 8 then
                    groupSlots[subgroup][#groupSlots[subgroup] + 1] = i
                end
            end
        end

        for g = 1, 8 do
            table.sort(groupSlots[g], function(a, b) return a < b end)
        end

        for g = 1, 8 do
            for slotIdx, raidIndex in ipairs(groupSlots[g]) do
                placements[#placements + 1] = { UUF.RAID_FRAMES[raidIndex], g - 1, slotIdx - 1 }
            end
        end

    elseif sortBy == "ROLE" and IsInRaid() then
        -- Consecutive layout sorted by role priority; no fixed-position gaps.
        local rolePriority = { TANK = 1, HEALER = 2, DAMAGER = 3, NONE = 4 }
        local orderedFrames = {}
        for i = 1, UUF.MAX_RAID_MEMBERS do
            if UUF.RAID_FRAMES[i] then
                orderedFrames[#orderedFrames + 1] = UUF.RAID_FRAMES[i]
            end
        end
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
        for idx, raidFrame in ipairs(orderedFrames) do
            local i = idx - 1
            placements[#placements + 1] = { raidFrame, math.floor(i / framesPerGroup), i % framesPerGroup }
        end

    else
        -- INDEX sort, or not in raid (test mode / preview): fixed positions directly from
        -- raid slot index so that raid1-5 are always col 0, raid6-10 col 1, raid11-15 col 2,
        -- etc. Hidden frames (empty slots) create natural visual gaps.
        for i = 1, UUF.MAX_RAID_MEMBERS do
            if UUF.RAID_FRAMES[i] then
                placements[#placements + 1] = { UUF.RAID_FRAMES[i], math.floor((i - 1) / framesPerGroup), (i - 1) % framesPerGroup }
            end
        end
    end

    for _, p in ipairs(placements) do
        local raidFrame, col, row = p[1], p[2], p[3]
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

    -- The GroupTypeEventFrame enforces party/raid mutual exclusivity and keeps the raid
    -- layout in sync whenever the group roster changes. It is created once regardless of
    -- whether raid frames are Enabled so that party visibility is always managed.
    if not UUF.GroupTypeEventFrame then
        UUF.GroupTypeEventFrame = CreateFrame("Frame")
        UUF.GroupTypeEventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
        UUF.GroupTypeEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        UUF.GroupTypeEventFrame:SetScript("OnEvent", function(self, event)
            if InCombatLockdown() then return end
            local inRaid  = IsInRaid()
            local inParty = IsInGroup() and not inRaid

            -- Raid frames: visible only when the player is in a raid and the slot's actual
            -- subgroup (from GetRaidRosterInfo) is within the configured GroupsToShow limit.
            local raidDB       = UUF.db.profile.Units.raid
            local groupsToShow = tonumber(raidDB.Frame.GroupsToShow) or 8
            for i = 1, UUF.MAX_RAID_MEMBERS do
                local raidFrame = UUF["RAID"..i]
                if raidFrame then
                    local _, _, subgroup = GetRaidRosterInfo(i)
                    if raidDB.Enabled and inRaid and subgroup and subgroup <= groupsToShow then
                        RegisterUnitWatch(raidFrame)
                    else
                        UnregisterUnitWatch(raidFrame)
                        raidFrame:Hide()
                    end
                end
            end

            -- Party frames: visible only when the player is in a party that is NOT a raid.
            local partyDB = UUF.db.profile.Units.party
            for i = 1, UUF.MAX_PARTY_MEMBERS do
                local partyFrame = UUF["PARTY"..i]
                if partyFrame then
                    if partyDB and partyDB.Enabled and inParty then
                        RegisterUnitWatch(partyFrame)
                    else
                        UnregisterUnitWatch(partyFrame)
                        partyFrame:Hide()
                    end
                end
            end

            -- Re-layout raid frames so any subgroup changes are reflected immediately.
            if inRaid then
                UUF:LayoutRaidFrames()
            end
        end)
    end

    if not UnitDB.Enabled then return end

    local FrameDB = UnitDB.Frame

    -- All 40 frames are created on load. RegisterUnitWatch is intentionally omitted here;
    -- the GroupTypeEventFrame handles visibility for all raid frames on PLAYER_ENTERING_WORLD
    -- and every subsequent GROUP_ROSTER_UPDATE.
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
    end

    UUF:LayoutRaidFrames()
end

-----------------------------------------------------------------------
-- Update Raid Frames
-----------------------------------------------------------------------

function UUF:UpdateRaidFrames()
    local UnitDB       = UUF.db.profile.Units.raid
    local FrameDB      = UnitDB.Frame
    local groupsToShow = tonumber(FrameDB.GroupsToShow) or 8
    local inRaid       = IsInRaid()

    for i = 1, UUF.MAX_RAID_MEMBERS do
        local raidFrame = UUF["RAID"..i]
        if raidFrame then
            UUF:UpdateRaidUnitFrame(raidFrame, "raid"..i)
            raidFrame:SetSize(FrameDB.Width, FrameDB.Height)

            local _, _, subgroup = GetRaidRosterInfo(i)
            if UnitDB.Enabled and inRaid and subgroup and subgroup <= groupsToShow then
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
    local UnitDB       = UUF.db.profile.Units.raid
    if not UnitDB then return end
    local groupsToShow = tonumber(UnitDB.Frame.GroupsToShow) or 8
    local inRaid       = IsInRaid()

    for i = 1, UUF.MAX_RAID_MEMBERS do
        local raidFrame = UUF["RAID"..i]
        if raidFrame then
            local _, _, subgroup = GetRaidRosterInfo(i)
            if UnitDB.Enabled and inRaid and subgroup and subgroup <= groupsToShow then
                RegisterUnitWatch(raidFrame)
            else
                UnregisterUnitWatch(raidFrame)
                raidFrame:Hide()
            end
        end
    end
end
