local _, UUF = ...
local oUF = UUF.oUF

function UUF:SpawnPartyFrames()
    local unit = "party"
    local DB = UUF.db.profile[unit]
    local Frame = DB.Frame

    if not DB.Enabled then return end

    oUF:RegisterStyle("UUF_Party", UUF.CreateUnitFrame)
    oUF:SetActiveStyle("UUF_Party")

    self.Party = oUF:SpawnHeader(
        "UUF_Party", nil, "party",
        "showParty", true,
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

    self.Party:SetPoint(
        Frame.AnchorFrom,
        UIParent,
        Frame.AnchorTo,
        Frame.XPosition,
        Frame.YPosition
    )

    self.Party:HookScript("OnEvent", function(header, event)
        if event ~= "GROUP_ROSTER_UPDATE" and event ~= "PLAYER_ENTERING_WORLD" and event ~= "GROUP_JOINED" then return end
        for i = 1, header:GetNumChildren() do
            local child = select(i, header:GetChildren())
            if child and not child.__RangeHooked then
                child.__RangeHooked = true
                child:HookScript("OnAttributeChanged", function(frame, name, value)
                    if name ~= "unit" or not value then return end

                    local guid = UnitGUID(value)
                    if frame.__LastGUID == guid then return end
                    frame.__LastGUID = guid

                    if value ~= "player" and UnitExists(value) then
                        UUF:RegisterRangeFrame(frame, value)
                    else
                        frame:SetAlpha(1.0)
                    end
                end)
            end
        end
    end)
    self.Party:RegisterEvent("GROUP_ROSTER_UPDATE")
    self.Party:RegisterEvent("GROUP_JOINED")
    self.Party:RegisterEvent("PLAYER_ENTERING_WORLD")
end