local _, UUF = ...
local oUF = UUF.oUF
local CapitalizedUnits = UUF.CapitalizedUnits

function UUF:SpawnRaidFrames()
    local unit  = "raid"
    local DB    = UUF.db.profile[unit]
    local Frame = DB.Frame

    if not DB.Enabled then return end

    if CompactRaidFrameManager then
        CompactRaidFrameManager:UnregisterAllEvents()
        CompactRaidFrameManager:Hide()
        CompactRaidFrameManager.Show = function() end
    end

    if CompactRaidFrameContainer then
        CompactRaidFrameContainer:UnregisterAllEvents()
        CompactRaidFrameContainer:Hide()
        CompactRaidFrameContainer.Show = function() end
    end

    oUF:RegisterStyle("UUF_" .. CapitalizedUnits[unit], function(self)
        UUF.CreateUnitFrame(self, unit)
    end)
    oUF:SetActiveStyle("UUF_" .. CapitalizedUnits[unit])

    local groups = {}
    for i = 1, Frame.GroupsToShow do
        groups[#groups+1] = tostring(i)
    end
    local groupString = table.concat(groups, ",")

    local point, xOffset, yOffset, columnAnchorPoint
    if Frame.GrowthDirection == "RIGHT_UP" then
        point, xOffset, yOffset = "TOP", 0, -Frame.Spacing
        columnAnchorPoint = "RIGHT"
    elseif Frame.GrowthDirection == "RIGHT_DOWN" then
        point, xOffset, yOffset = "BOTTOM", 0, Frame.Spacing
        columnAnchorPoint = "RIGHT"
    elseif Frame.GrowthDirection == "UP_RIGHT" then
        point, xOffset, yOffset = "RIGHT", Frame.Spacing, 0
        columnAnchorPoint = "TOP"
    elseif Frame.GrowthDirection == "UP_LEFT" then
        point, xOffset, yOffset = "LEFT", -Frame.Spacing, 0
        columnAnchorPoint = "TOP"
    else
        point, xOffset, yOffset = "BOTTOM", 0, Frame.Spacing
        columnAnchorPoint = "RIGHT"
    end

    self.Raid = oUF:SpawnHeader(
        "UUF_Raid", nil, "raid",
        "showRaid", DB.Enabled,
        "showPlayer", Frame.ShowPlayer,
        "groupBy", "GROUP",
        "groupFilter", groupString,
        "groupingOrder", "1,2,3,4,5,6,7,8",
        "maxColumns", Frame.GroupsToShow,
        "unitsPerColumn", 5,
        "point", point,
        "xOffset", xOffset,
        "yOffset", yOffset,
        "columnSpacing", Frame.Spacing,
        "columnAnchorPoint", columnAnchorPoint,
        "oUF-initialConfigFunction", string.format([[
            self:SetWidth(%d)
            self:SetHeight(%d)
        ]], Frame.Width, Frame.Height)
    )

    self.Raid:SetPoint(
        Frame.AnchorFrom,
        UIParent,
        Frame.AnchorTo,
        Frame.XPosition,
        Frame.YPosition
    )
end
