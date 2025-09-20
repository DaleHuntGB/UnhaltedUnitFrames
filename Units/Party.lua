local _, UUF = ...
local oUF = UUF.oUF
local CapitalizedUnits = UUF.CapitalizedUnits

function UUF:SpawnPartyFrames()
    local unit = "party"
    local DB = UUF.db.profile[unit]
    local Frame = DB.Frame

    if not DB.Enabled then return end

    oUF:RegisterStyle("UUF_" .. CapitalizedUnits[unit], function(self) UUF.CreateUnitFrame(self, unit) end)
    oUF:SetActiveStyle("UUF_" .. CapitalizedUnits[unit])

    self.Party = oUF:SpawnHeader(
        "UUF_PartyHeader", nil, "party",
        "showParty", DB.Enabled,
        "showPlayer", Frame.ShowPlayer,
        "groupBy", "ASSIGNEDROLE",
        "groupingOrder", table.concat(Frame.SortOrder, ","),
        "point", Frame.Layout == "HORIZONTAL" and "LEFT" or "TOP",
        "xOffset", Frame.Layout == "HORIZONTAL" and Frame.Spacing or 0,
        "yOffset", Frame.Layout == "VERTICAL" and -Frame.Spacing or 0,
        "oUF-initialConfigFunction", string.format([[
            self:SetWidth(%d)
            self:SetHeight(%d)
        ]], Frame.Width, Frame.Height)
    )

    for i = 1, 4 do
        local child = _G["UUF_PartyHeaderUnitButton"..i]
        if child then
            UUF:RegisterRangeFrame(child, "party"..i)
        end
    end

    self.Party:SetPoint(
        Frame.AnchorFrom,
        UIParent,
        Frame.AnchorTo,
        Frame.XPosition,
        Frame.YPosition
    )
end
