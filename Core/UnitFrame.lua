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
    return normalizedUnit == "player" or normalizedUnit == "target" or normalizedUnit == "focus" or normalizedUnit == "party" or normalizedUnit == "raid"
end

local function UsesLeaderAssistantIndicator(unit)
    local normalizedUnit = UUF:GetNormalizedUnit(unit)
    return normalizedUnit == "player" or normalizedUnit == "target" or normalizedUnit == "party" or normalizedUnit == "raid"
end

local function UsesRoleIconIndicator(unit)
    local normalizedUnit = UUF:GetNormalizedUnit(unit)
    return normalizedUnit == "party" or normalizedUnit == "raid"
end

local function UsesResurrectIndicator(unit)
    local normalizedUnit = UUF:GetNormalizedUnit(unit)
    return normalizedUnit == "party" or normalizedUnit == "raid"
end

local function UsesCombatIndicator(unit)
    local normalizedUnit = UUF:GetNormalizedUnit(unit)
    return normalizedUnit == "player" or normalizedUnit == "target"
end

local function UsesTargetIndicator(unit)
    local normalizedUnit = UUF:GetNormalizedUnit(unit)
    return normalizedUnit ~= "party" and normalizedUnit ~= "raid"
end

local DEFAULT_RAID_ROLE_ORDER = {"TANK", "HEALER", "DAMAGER"}
local DEFAULT_RAID_CLASS_ORDER = {"DEATHKNIGHT", "DEMONHUNTER", "DRUID", "EVOKER", "HUNTER", "MAGE", "MONK", "PALADIN", "PRIEST", "ROGUE", "SHAMAN", "WARLOCK", "WARRIOR"}
local RAID_DIRECTION_TO_POINT = {
    DOWN_RIGHT = "TOP",
    DOWN_LEFT = "TOP",
    UP_RIGHT = "BOTTOM",
    UP_LEFT = "BOTTOM",
    RIGHT_DOWN = "LEFT",
    RIGHT_UP = "LEFT",
    LEFT_DOWN = "RIGHT",
    LEFT_UP = "RIGHT",
}
local RAID_DIRECTION_TO_COLUMN_ANCHOR_POINT = {
    DOWN_RIGHT = "LEFT",
    DOWN_LEFT = "RIGHT",
    UP_RIGHT = "LEFT",
    UP_LEFT = "RIGHT",
    RIGHT_DOWN = "TOP",
    RIGHT_UP = "BOTTOM",
    LEFT_DOWN = "TOP",
    LEFT_UP = "BOTTOM",
}
local RAID_DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER = {
    DOWN_RIGHT = 1,
    DOWN_LEFT = -1,
    UP_RIGHT = 1,
    UP_LEFT = -1,
    RIGHT_DOWN = 1,
    RIGHT_UP = 1,
    LEFT_DOWN = -1,
    LEFT_UP = -1,
}
local RAID_DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER = {
    DOWN_RIGHT = -1,
    DOWN_LEFT = -1,
    UP_RIGHT = 1,
    UP_LEFT = 1,
    RIGHT_DOWN = -1,
    RIGHT_UP = 1,
    LEFT_DOWN = -1,
    LEFT_UP = 1,
}
local hiddenBlizzardFrames = {}
local pendingBlizzardReparents = {}
local hiddenBlizzardParent = CreateFrame("Frame", nil, UIParent)
hiddenBlizzardParent:SetAllPoints()
hiddenBlizzardParent:Hide()
local blizzardRaidLoadWatcher = CreateFrame("Frame")
local blizzardReparentWatcher = CreateFrame("Frame")
blizzardReparentWatcher:RegisterEvent("PLAYER_REGEN_ENABLED")
blizzardReparentWatcher:SetScript("OnEvent", function()
    for frame in pairs(pendingBlizzardReparents) do
        if frame and not frame:IsForbidden() then
            frame:SetParent(hiddenBlizzardParent)
        end
        pendingBlizzardReparents[frame] = nil
    end
end)

local function ReparentBlizzardFrame(frame)
    if not frame or frame:IsForbidden() or frame:GetParent() == hiddenBlizzardParent then return end

    if InCombatLockdown() and frame:IsProtected() then
        pendingBlizzardReparents[frame] = true
        return
    end

    frame:SetParent(hiddenBlizzardParent)
end

local function HideBlizzardFrame(frame)
    if not frame or frame:IsForbidden() or hiddenBlizzardFrames[frame] then return end

    hiddenBlizzardFrames[frame] = true

    if frame.UnregisterAllEvents then
        frame:UnregisterAllEvents()
    end

    frame:Hide()
    ReparentBlizzardFrame(frame)

    hooksecurefunc(frame, "Show", function(self)
        if not self:IsForbidden() then
            self:Hide()
        end
    end)
    hooksecurefunc(frame, "SetShown", function(self, shown)
        if shown and not self:IsForbidden() then
            self:Hide()
        end
    end)
    hooksecurefunc(frame, "SetParent", function(self, parent)
        if parent ~= hiddenBlizzardParent and not self:IsForbidden() then
            ReparentBlizzardFrame(self)
        end
    end)
end

local function HideBlizzardRaidFrames()
    if not _G.CompactRaidFrameManager and not _G.CompactRaidFrameContainer then
        blizzardRaidLoadWatcher:RegisterEvent("ADDON_LOADED")
        blizzardRaidLoadWatcher:SetScript("OnEvent", function(_, _, addonName)
            if addonName == "Blizzard_CompactRaidFrames" then
                HideBlizzardRaidFrames()
                blizzardRaidLoadWatcher:UnregisterEvent("ADDON_LOADED")
            end
        end)
        return
    end

    if _G.CompactRaidFrameManager then
        HideBlizzardFrame(_G.CompactRaidFrameManager)
    end

    if _G.CompactRaidFrameContainer then
        HideBlizzardFrame(_G.CompactRaidFrameContainer)
    end
end

local function UseGroupedRaidHeaders()
    local raidDB = UUF.db and UUF.db.profile and UUF.db.profile.Units and UUF.db.profile.Units.raid
    if not (raidDB and raidDB.Frame) then return false end
    if raidDB.Frame.GroupBy == "CLASS" then
        raidDB.Frame.GroupBy = "GROUP"
    end
    return raidDB.Frame.GroupBy == "GROUP"
end

local function GetFilteredRaidGroups(frameDB)
    local groups = {}
    local seen = {}
    local groupFilter = type(frameDB.GroupFilter) == "string" and strtrim(frameDB.GroupFilter) or ""

    if groupFilter ~= "" then
        for groupID in groupFilter:gmatch("%d+") do
            local groupIndex = tonumber(groupID)
            if groupIndex and groupIndex >= 1 and groupIndex <= UUF.MAX_RAID_GROUPS and not seen[groupIndex] then
                groups[#groups + 1] = groupIndex
                seen[groupIndex] = true
            end
        end
    end

    if #groups == 0 then
        for groupIndex = 1, UUF.MAX_RAID_GROUPS do
            groups[#groups + 1] = groupIndex
        end
    end

    return groups
end

local function GetRaidGroupHeaderDimensions(frameDB)
    local direction = frameDB.GrowthDirection or "DOWN_RIGHT"
    local point = RAID_DIRECTION_TO_POINT[direction] or "TOP"
    local horizontalSpacing = frameDB.HorizontalSpacing or 0
    local verticalSpacing = frameDB.VerticalSpacing or 0

    if point == "LEFT" or point == "RIGHT" then
        return (frameDB.Width * 5) + (horizontalSpacing * 4), frameDB.Height
    end

    return frameDB.Width, (frameDB.Height * 5) + (verticalSpacing * 4)
end

local function GetRaidGroupLayoutOffsets(direction, groupWidth, groupHeight, horizontalSpacing, verticalSpacing)
    if direction == "DOWN_RIGHT" then
        return groupWidth + horizontalSpacing, 0, 0, -(groupHeight + verticalSpacing)
    elseif direction == "DOWN_LEFT" then
        return -(groupWidth + horizontalSpacing), 0, 0, -(groupHeight + verticalSpacing)
    elseif direction == "UP_RIGHT" then
        return groupWidth + horizontalSpacing, 0, 0, groupHeight + verticalSpacing
    elseif direction == "UP_LEFT" then
        return -(groupWidth + horizontalSpacing), 0, 0, groupHeight + verticalSpacing
    elseif direction == "RIGHT_DOWN" then
        return 0, -(groupHeight + verticalSpacing), groupWidth + horizontalSpacing, 0
    elseif direction == "RIGHT_UP" then
        return 0, groupHeight + verticalSpacing, groupWidth + horizontalSpacing, 0
    elseif direction == "LEFT_DOWN" then
        return 0, -(groupHeight + verticalSpacing), -(groupWidth + horizontalSpacing), 0
    elseif direction == "LEFT_UP" then
        return 0, groupHeight + verticalSpacing, -(groupWidth + horizontalSpacing), 0
    end

    return groupWidth + horizontalSpacing, 0, 0, -(groupHeight + verticalSpacing)
end

local function ConfigureRaidSubGroupHeader(header, frameDB, groupIndex)
    if not header or not frameDB then return end

    local direction = frameDB.GrowthDirection or "DOWN_RIGHT"
    local point = RAID_DIRECTION_TO_POINT[direction] or "TOP"
    local horizontalSpacing = frameDB.HorizontalSpacing or 0
    local verticalSpacing = frameDB.VerticalSpacing or 0
    local xSpacingMultiplier = RAID_DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER[direction] or 1
    local ySpacingMultiplier = RAID_DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[direction] or -1
    local width, height = GetRaidGroupHeaderDimensions(frameDB)

    header:SetAttribute("groupFilter", tostring(groupIndex))
    header:SetAttribute("groupingOrder", nil)
    header:SetAttribute("groupBy", nil)
    header:SetAttribute("sortMethod", frameDB.SortMethod or "INDEX")
    header:SetAttribute("sortDir", frameDB.SortDirection or "ASC")
    header:SetAttribute("maxColumns", 1)
    header:SetAttribute("unitsPerColumn", 5)
    header:SetAttribute("point", point)

    if point == "LEFT" or point == "RIGHT" then
        header:SetAttribute("xOffset", horizontalSpacing * xSpacingMultiplier)
        header:SetAttribute("yOffset", 0)
        header:SetAttribute("columnSpacing", verticalSpacing)
    else
        header:SetAttribute("xOffset", 0)
        header:SetAttribute("yOffset", verticalSpacing * ySpacingMultiplier)
        header:SetAttribute("columnSpacing", horizontalSpacing)
    end

    header:SetSize(width, height)
end

local function BuildOrderedGroupingString(customOrder, defaultOrder, suffixValue)
    local values = {}
    local seen = {}

    if type(customOrder) == "table" then
        for _, value in ipairs(customOrder) do
            if value and value ~= "" and not seen[value] then
                values[#values + 1] = value
                seen[value] = true
            end
        end
    end

    for _, value in ipairs(defaultOrder) do
        if not seen[value] then
            values[#values + 1] = value
            seen[value] = true
        end
    end

    if suffixValue and not seen[suffixValue] then
        values[#values + 1] = suffixValue
    end

    return table.concat(values, ",")
end

local function ApplyRaidHeaderSortSettings(header, frameDB)
    if not header or not frameDB then return end

    local groupBy = frameDB.GroupBy or "GROUP"
    local groupFilter = type(frameDB.GroupFilter) == "string" and strtrim(frameDB.GroupFilter) or nil

    header:SetAttribute("groupFilter", groupFilter ~= "" and groupFilter or nil)
    header:SetAttribute("sortDir", frameDB.SortDirection or "ASC")

    if groupBy == "CLASS" then
        groupBy = "GROUP"
        frameDB.GroupBy = "GROUP"
    end

    if groupBy == "ROLE" then
        header:SetAttribute("groupingOrder", BuildOrderedGroupingString(frameDB.RoleOrder, DEFAULT_RAID_ROLE_ORDER, "NONE"))
        header:SetAttribute("sortMethod", frameDB.SortMethod or "NAME")
        header:SetAttribute("groupBy", "ASSIGNEDROLE")
    elseif groupBy == "GROUP" then
        header:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
        header:SetAttribute("sortMethod", frameDB.SortMethod or "INDEX")
        header:SetAttribute("groupBy", "GROUP")
    elseif groupBy == "NAME" then
        header:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
        header:SetAttribute("sortMethod", "NAME")
        header:SetAttribute("groupBy", nil)
    else
        header:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
        header:SetAttribute("sortMethod", "INDEX")
        header:SetAttribute("groupBy", nil)
    end
end

local function GetRaidHeaderDimensions(frameDB, unitCount)
    local direction = frameDB.GrowthDirection or "DOWN_RIGHT"
    local point = RAID_DIRECTION_TO_POINT[direction] or "TOP"
    local maxColumns = math.max(1, math.floor(frameDB.MaxColumns or 8))
    local unitsPerColumn = math.max(1, math.floor(frameDB.UnitsPerColumn or 5))
    local horizontalSpacing = frameDB.HorizontalSpacing or 0
    local verticalSpacing = frameDB.VerticalSpacing or 0
    local maxUnits = maxColumns * unitsPerColumn
    local activeUnits = math.max(1, math.min(unitCount or maxUnits, maxUnits))
    local primaryUnits = math.min(activeUnits, unitsPerColumn)
    local secondaryUnits = math.max(1, math.ceil(activeUnits / unitsPerColumn))

    if point == "LEFT" or point == "RIGHT" then
        local width = (frameDB.Width * primaryUnits) + (horizontalSpacing * (primaryUnits - 1))
        local height = (frameDB.Height * secondaryUnits) + (verticalSpacing * (secondaryUnits - 1))
        return math.max(width, frameDB.Width), math.max(height, frameDB.Height)
    end

    local width = (frameDB.Width * secondaryUnits) + (horizontalSpacing * (secondaryUnits - 1))
    local height = (frameDB.Height * primaryUnits) + (verticalSpacing * (primaryUnits - 1))
    return math.max(width, frameDB.Width), math.max(height, frameDB.Height)
end

local function ApplyHeaderVisibility(unit)
    if unit == "party" and UUF.PARTY then
        if UUF.db.profile.Units.party.Enabled then
            UUF.PARTY:SetVisibility("custom [group:party,nogroup:raid] show; hide")
        else
            UUF.PARTY:SetVisibility("hide")
            UUF.PARTY:Hide()
        end
    elseif unit == "raid" and UUF.RAID then
        local useGroupedHeaders = UseGroupedRaidHeaders()
        if UUF.db.profile.Units.raid.Enabled and not useGroupedHeaders then
            UUF.RAID:SetVisibility("custom [group:raid] show; hide")
        else
            UUF.RAID:SetVisibility("hide")
            UUF.RAID:Hide()
        end

        for _, header in ipairs(UUF.RAID_GROUP_HEADERS) do
            if header then
                if UUF.db.profile.Units.raid.Enabled and useGroupedHeaders then
                    header:SetVisibility("custom [group:raid] show; hide")
                else
                    header:SetVisibility("hide")
                    header:Hide()
                end
            end
        end
    end
end

function UUF:RefreshPartyFrames()
    wipe(UUF.PARTY_FRAMES)

    if UUF.PARTY_TEST_MODE and #UUF.PARTY_TEST_FRAMES > 0 then
        for i = 1, UUF.MAX_PARTY_FRAMES do
            local unitFrame = UUF.PARTY_TEST_FRAMES[i]
            if unitFrame then
                UUF.PARTY_FRAMES[i] = unitFrame
            end
        end
        return UUF.PARTY_FRAMES
    end

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

function UUF:RefreshRaidFrames()
    wipe(UUF.RAID_FRAMES)

    if UUF.RAID_TEST_MODE and #UUF.RAID_TEST_FRAMES > 0 then
        for i = 1, UUF.MAX_RAID_FRAMES do
            local unitFrame = UUF.RAID_TEST_FRAMES[i]
            if unitFrame then
                UUF.RAID_FRAMES[i] = unitFrame
            end
        end
        return UUF.RAID_FRAMES
    end

    if UseGroupedRaidHeaders() then
        for _, header in ipairs(UUF.RAID_GROUP_HEADERS) do
            if header then
                for _, child in ipairs({ header:GetChildren() }) do
                    local unit = child.unit or child:GetAttribute("unit")
                    local unitIndex = unit and tonumber(unit:match("^raid(%d+)$"))
                    if unitIndex then
                        UUF.RAID_FRAMES[unitIndex] = child
                    end
                end
            end
        end
        return UUF.RAID_FRAMES
    end

    if not UUF.RAID then return UUF.RAID_FRAMES end

    for _, child in ipairs({ UUF.RAID:GetChildren() }) do
        local unit = child.unit or child:GetAttribute("unit")
        local unitIndex = unit and tonumber(unit:match("^raid(%d+)$"))
        if unitIndex then
            UUF.RAID_FRAMES[unitIndex] = child
        end
    end

    return UUF.RAID_FRAMES
end

function UUF:ForEachRaidFrame(callback)
    if type(callback) ~= "function" then return end

    local raidFrames = UUF:RefreshRaidFrames()
    for index = 1, UUF.MAX_RAID_FRAMES do
        local unitFrame = raidFrames[index]
        if unitFrame then
            local actualUnit = unitFrame.unit or unitFrame:GetAttribute("unit")
            if not actualUnit and UUF.RAID_TEST_MODE then
                actualUnit = "raid" .. index
            end
            if actualUnit then
                callback(unitFrame, actualUnit, index)
            end
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

    if unit == "raid" then
        UUF:ForEachRaidFrame(callback)
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

    if normalizedUnit ~= "player" and not UUF:IsRangeFrameRegistered(unitFrame) then
        UUF:RegisterRangeFrame(unitFrame, unit)
    end

    if UsesDispelHighlight(unit) then
        UUF:RegisterDispelHighlightEvents(unitFrame, unit)
    end
end

function UUF:LayoutPartyFrames()
    local frameDB = UUF.db.profile.Units.party and UUF.db.profile.Units.party.Frame
    if not frameDB then return end

    if UUF.PARTY_TEST_MODE and #UUF.PARTY_TEST_FRAMES > 0 then
        local partyFrames = {}
        for i = 1, UUF.MAX_PARTY_FRAMES do
            if UUF.PARTY_TEST_FRAMES[i] then
                partyFrames[#partyFrames + 1] = UUF.PARTY_TEST_FRAMES[i]
            end
        end
        if #partyFrames == 0 then return end
        if UUF.PARTY then
            UUF.PARTY:Hide()
        end
        if frameDB.GrowthDirection == "UP" then
            local reversedFrames = {}
            for i = #partyFrames, 1, -1 do
                reversedFrames[#reversedFrames + 1] = partyFrames[i]
            end
            partyFrames = reversedFrames
        end
        local layoutConfig = UUF.LayoutConfig[frameDB.Layout[1]]
        local frameHeight = partyFrames[1]:GetHeight()
        local containerHeight = (frameHeight + frameDB.Layout[5]) * #partyFrames - frameDB.Layout[5]
        local offsetY = containerHeight * layoutConfig.offsetMultiplier
        if layoutConfig.isCenter then offsetY = offsetY - (frameHeight / 2) end
        local initialAnchor = AnchorUtil.CreateAnchor(layoutConfig.anchor, UIParent, frameDB.Layout[2], frameDB.Layout[3], frameDB.Layout[4] + offsetY)
        AnchorUtil.VerticalLayout(partyFrames, initialAnchor, frameDB.Layout[5])
        for _, unitFrame in ipairs(partyFrames) do
            unitFrame:SetSize(frameDB.Width, frameDB.Height)
            unitFrame:SetFrameStrata(frameDB.FrameStrata)
            unitFrame:SetShown(UUF.db.profile.Units.party.Enabled)
        end
        return
    end

    if not UUF.PARTY then return end

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

function UUF:LayoutRaidFrames()
    local raidDB = UUF.db.profile.Units.raid
    local frameDB = raidDB and raidDB.Frame
    if not frameDB then return end

    if UUF.RAID_TEST_MODE and #UUF.RAID_TEST_FRAMES > 0 then
        UUF:CreateTestRaidFrames()
        return
    end

    local useGroupedHeaders = UseGroupedRaidHeaders()
    local raidFrames = UUF:RefreshRaidFrames()

    local direction = frameDB.GrowthDirection or "DOWN_RIGHT"
    local point = RAID_DIRECTION_TO_POINT[direction] or "TOP"
    local horizontalSpacing = frameDB.HorizontalSpacing or 0
    local verticalSpacing = frameDB.VerticalSpacing or 0
    local xSpacingMultiplier = RAID_DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER[direction] or 1
    local ySpacingMultiplier = RAID_DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[direction] or -1
    local maxColumns = math.max(1, math.floor(frameDB.MaxColumns or 8))
    local unitsPerColumn = math.max(1, math.floor(frameDB.UnitsPerColumn or 5))
    local visibleUnits = 0
    for _, unitFrame in pairs(raidFrames) do
        if unitFrame and unitFrame:IsShown() then
            visibleUnits = visibleUnits + 1
        end
    end

    if useGroupedHeaders then
        local groupWidth, groupHeight = GetRaidGroupHeaderDimensions(frameDB)
        local lineStepX, lineStepY, wrapStepX, wrapStepY = GetRaidGroupLayoutOffsets(direction, groupWidth, groupHeight, horizontalSpacing, verticalSpacing)
        local visibleHeaderIndex = 0

        if UUF.RAID then
            UUF.RAID:ClearAllPoints()
            UUF.RAID:SetSize(1, 1)
        end

        for _, groupIndex in ipairs(GetFilteredRaidGroups(frameDB)) do
            local header = UUF.RAID_GROUP_HEADERS[groupIndex]
            if header then
                ConfigureRaidSubGroupHeader(header, frameDB, groupIndex)

                header:ClearAllPoints()
                local lineIndex = visibleHeaderIndex % maxColumns
                local wrapIndex = math.floor(visibleHeaderIndex / maxColumns)
                local xPos = frameDB.Layout[3] + (lineStepX * lineIndex) + (wrapStepX * wrapIndex)
                local yPos = frameDB.Layout[4] + (lineStepY * lineIndex) + (wrapStepY * wrapIndex)
                header:SetPoint(frameDB.Layout[1], UIParent, frameDB.Layout[2], xPos, yPos)
                visibleHeaderIndex = visibleHeaderIndex + 1
            end
        end
    else
        if not UUF.RAID then return end

        local width, height = GetRaidHeaderDimensions(frameDB, visibleUnits)

        UUF.RAID:ClearAllPoints()
        UUF.RAID:SetPoint(frameDB.Layout[1], UIParent, frameDB.Layout[2], frameDB.Layout[3], frameDB.Layout[4])
        UUF.RAID:SetAttribute("point", point)
        UUF.RAID:SetAttribute("columnAnchorPoint", RAID_DIRECTION_TO_COLUMN_ANCHOR_POINT[direction] or "LEFT")
        UUF.RAID:SetAttribute("maxColumns", maxColumns)
        UUF.RAID:SetAttribute("unitsPerColumn", unitsPerColumn)

        if point == "LEFT" or point == "RIGHT" then
            UUF.RAID:SetAttribute("xOffset", horizontalSpacing * xSpacingMultiplier)
            UUF.RAID:SetAttribute("yOffset", 0)
            UUF.RAID:SetAttribute("columnSpacing", verticalSpacing)
        else
            UUF.RAID:SetAttribute("xOffset", 0)
            UUF.RAID:SetAttribute("yOffset", verticalSpacing * ySpacingMultiplier)
            UUF.RAID:SetAttribute("columnSpacing", horizontalSpacing)
        end

        ApplyRaidHeaderSortSettings(UUF.RAID, frameDB)
        UUF.RAID:SetSize(width, height)
    end

    UUF:ForEachRaidFrame(function(unitFrame)
        unitFrame:SetSize(frameDB.Width, frameDB.Height)
        unitFrame:SetFrameStrata(frameDB.FrameStrata)
    end)
end

function UUF:CreateUnitFrame(unitFrame, unit)
    if not unit or not unitFrame then return end
    local normalizedUnit = UUF:GetNormalizedUnit(unit)
    local isPlayer = normalizedUnit == "player"
    local isRaid = normalizedUnit == "raid"
    local isTargetTarget = normalizedUnit == "targettarget"
    local isFocusTarget = normalizedUnit == "focustarget"

    UUF:CreateUnitContainer(unitFrame, unit)
    if not isRaid and not isTargetTarget and not isFocusTarget then UUF:CreateUnitCastBar(unitFrame, unit) end
    UUF:CreateUnitHealthBar(unitFrame, unit)
    if UsesDispelHighlight(unit) then UUF:CreateUnitDispelHighlight(unitFrame, unit) end
    UUF:CreateUnitHealPrediction(unitFrame, unit)
    if not isRaid and not isTargetTarget and not isFocusTarget then UUF:CreateUnitPortrait(unitFrame, unit) end
    UUF:CreateUnitPowerBar(unitFrame, unit)
    if isPlayer then UUF:CreateUnitAlternativePowerBar(unitFrame, unit) end
    if isPlayer then UUF:CreateUnitSecondaryPowerBar(unitFrame, unit) end
    UUF:CreateUnitRaidTargetMarker(unitFrame, unit)
    if UsesRoleIconIndicator(unit) then UUF:CreateUnitRoleIconIndicator(unitFrame, unit) end
    if UsesResurrectIndicator(unit) then UUF:CreateUnitResurrectIndicator(unitFrame, unit) end
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
    elseif unit == "raid" then
        if UnitDB.ForceHideBlizzard then
            HideBlizzardRaidFrames()
        end
        UUF[unit:upper()] = oUF:SpawnHeader(
            UUF:FetchFrameName(unit),
            nil,
            "showParty", false,
            "showPlayer", false,
            "showRaid", true,
            "sortMethod", "INDEX",
            "sortDir", "ASC",
            "oUF-onlyProcessChildren", true
        )
        UUF.RAID = UUF[unit:upper()]
        for groupIndex = 1, UUF.MAX_RAID_GROUPS do
            local groupHeaderName = UUF:FetchFrameName(unit) .. "Group" .. groupIndex
            UUF.RAID_GROUP_HEADERS[groupIndex] = oUF:SpawnHeader(
                groupHeaderName,
                nil,
                "showParty", false,
                "showPlayer", false,
                "showRaid", true,
                "groupFilter", tostring(groupIndex),
                "sortMethod", "INDEX",
                "sortDir", "ASC",
                "oUF-onlyProcessChildren", true
            )
        end
        UUF:LayoutRaidFrames()
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

    if unit == "party" or unit == "raid" then
        ApplyHeaderVisibility(unit)
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
    elseif normalizedUnit == "raid" and unit == "raid" then
        UUF:UpdateRaidFrames()
        return
    end

    local UnitDB = UUF.db.profile.Units[normalizedUnit]
    local isPlayer = normalizedUnit == "player"
    local isRaid = normalizedUnit == "raid"
    local isTargetTarget = normalizedUnit == "targettarget"
    local isFocusTarget = normalizedUnit == "focustarget"

    if not isRaid and not isTargetTarget and not isFocusTarget then
        UUF:UpdateUnitCastBar(unitFrame, unit)
    elseif unitFrame.Castbar then
        if unitFrame:IsElementEnabled("Castbar") then unitFrame:DisableElement("Castbar") end
        local castBarContainer = unitFrame.Castbar:GetParent()
        if castBarContainer then castBarContainer:Hide() end
        unitFrame.Castbar:Hide()
        unitFrame.Castbar = nil
    end
    UUF:UpdateUnitHealthBar(unitFrame, unit)
    UUF:UpdateUnitHealPrediction(unitFrame, unit)
    if not isRaid and not isTargetTarget and not isFocusTarget then
        UUF:UpdateUnitPortrait(unitFrame, unit)
    elseif unitFrame.Portrait then
        unitFrame.Portrait:Hide()
        if unitFrame.Portrait.Border then
            unitFrame.Portrait.Border:Hide()
        end
        if unitFrame.Portrait.GetObjectType and unitFrame.Portrait:GetObjectType() == "PlayerModel" then
            unitFrame.Portrait:ClearModel()
        end
        unitFrame.Portrait = nil
    end
    UUF:UpdateUnitPowerBar(unitFrame, unit)
    if isPlayer then UUF:UpdateUnitAlternativePowerBar(unitFrame, unit) end
    if isPlayer then UUF:UpdateUnitSecondaryPowerBar(unitFrame, unit) end
    UUF:UpdateUnitRaidTargetMarker(unitFrame, unit)
    if UsesRoleIconIndicator(unit) then
        UUF:UpdateUnitRoleIconIndicator(unitFrame, unit)
    elseif unitFrame.GroupRoleIndicator then
        if unitFrame:IsElementEnabled("GroupRoleIndicator") then unitFrame:DisableElement("GroupRoleIndicator") end
        unitFrame.GroupRoleIndicator:Hide()
        unitFrame.GroupRoleIndicator = nil
    end
    if UsesResurrectIndicator(unit) then
        UUF:UpdateUnitResurrectIndicator(unitFrame, unit)
    elseif unitFrame.ResurrectIndicator then
        if unitFrame:IsElementEnabled("ResurrectIndicator") then unitFrame:DisableElement("ResurrectIndicator") end
        unitFrame.ResurrectIndicator:Hide()
        unitFrame.ResurrectIndicator = nil
    end
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
    UUF:UpdateUnitFrameTags(unitFrame, unit)
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
    UUF:CreateTestPartyFrames()
    UUF:LayoutPartyFrames()
end

function UUF:UpdateRaidFrames()
    UUF:ForEachRaidFrame(function(unitFrame, actualUnit)
        UUF:UpdateUnitFrame(unitFrame, actualUnit)
    end)
    UUF:CreateTestRaidFrames()
    UUF:LayoutRaidFrames()
end


function UUF:UpdateAllUnitFrames()
    for unit, _ in pairs(UUF.db.profile.Units) do
        if unit == "boss" and #UUF.BOSS_FRAMES > 0 then
            UUF:UpdateBossFrames()
        elseif unit == "raid" and UUF.RAID then
            UUF:UpdateRaidFrames()
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
        elseif unit == "raid" then
            if not UUF["RAID"] then UUF:SpawnUnitFrame(unit) end
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

    if unit == "party" or unit == "raid" then
        if UUF[UnitKey] then
            if unit == "raid" and UnitDB.ForceHideBlizzard then
                HideBlizzardRaidFrames()
            end
            ApplyHeaderVisibility(unit)
            if UnitDB.Enabled then
                if unit == "party" then
                    UUF:LayoutPartyFrames()
                else
                    UUF:LayoutRaidFrames()
                end
            end
        end
        return
    end

    local unitFrame = UUF[UnitKey]
    if not unitFrame then return end
    (UnitDB.Enabled and RegisterUnitWatch or UnregisterUnitWatch)(unitFrame)
    unitFrame:SetShown(UnitDB.Enabled)
end
