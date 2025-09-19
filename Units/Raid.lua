local _, UUF = ...
local oUF = UUF.oUF
local CapitalizedUnits = UUF.CapitalizedUnits

local _, UUF = ...
local oUF = UUF.oUF
local CapitalizedUnits = UUF.CapitalizedUnits

function UUF:SpawnRaidFrames()
    local unit  = "raid"
    local DB    = UUF.db.profile[unit]
    local Frame = DB.Frame

    oUF:RegisterStyle("UUF_" .. CapitalizedUnits[unit], function(self)
        UUF.CreateUnitFrame(self, unit)
    end)
    oUF:SetActiveStyle("UUF_" .. CapitalizedUnits[unit])

    -- build group filter string dynamically
    local groups = {}
    for i = 1, Frame.GroupsToShow do
        groups[#groups+1] = tostring(i)
    end
    local groupString = table.concat(groups, ",")

    -- decide unit growth (rows)
    local point, xOffset, yOffset
    if Frame.RowGrowth == "UP" then
        point, xOffset, yOffset = "BOTTOM", 0, Frame.Spacing
    elseif Frame.RowGrowth == "DOWN" then
        point, xOffset, yOffset = "TOP", 0, -Frame.Spacing
    elseif Frame.RowGrowth == "LEFT" then
        point, xOffset, yOffset = "RIGHT", -Frame.Spacing, 0
    else -- RIGHT
        point, xOffset, yOffset = "LEFT", Frame.Spacing, 0
    end

    -- decide column growth
    local columnAnchorPoint
    if Frame.ColumnGrowth == "LEFT" then
        columnAnchorPoint = "LEFT"
    elseif Frame.ColumnGrowth == "RIGHT" then
        columnAnchorPoint = "RIGHT"
    elseif Frame.ColumnGrowth == "UP" then
        columnAnchorPoint = "TOP"
    else -- DOWN
        columnAnchorPoint = "BOTTOM"
    end

    self.Raid = oUF:SpawnHeader(
        "UUF_Raid", nil, "raid",
        "showRaid", DB.Enabled,
        "showPlayer", Frame.ShowPlayer,
        "groupBy", "GROUP",
        "groupFilter", groupString,
        "groupingOrder", groupString,
        "maxColumns", Frame.GroupsToShow,
        "unitsPerColumn", Frame.UnitsPerColumn,
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