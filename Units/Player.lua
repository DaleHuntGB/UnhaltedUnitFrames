local _, UUF = ...
local oUF = UUF.oUF
local CapitalizedUnits = UUF.CapitalizedUnits

function UUF:SpawnPlayerFrame()
    local spawningUnit = "player"
    oUF:RegisterStyle("UUF_" .. CapitalizedUnits[spawningUnit], UUF.CreateUnitFrame)
    oUF:SetActiveStyle("UUF_" .. CapitalizedUnits[spawningUnit])
    self.PlayerFrame = oUF:Spawn(spawningUnit, "UUF_" .. CapitalizedUnits[spawningUnit])
    self.PlayerFrame:SetPoint(UUF.db.profile[spawningUnit].Frame.AnchorFrom, UIParent, UUF.db.profile[spawningUnit].Frame.AnchorTo, UUF.db.profile[spawningUnit].Frame.XPosition, UUF.db.profile[spawningUnit].Frame.YPosition)
    self.PlayerFrame:SetSize(UUF.db.profile[spawningUnit].Frame.Width, UUF.db.profile[spawningUnit].Frame.Height)

    if UUF.db.profile[spawningUnit].Enabled then
        RegisterUnitWatch(self.PlayerFrame)
        self.PlayerFrame:Show()
    else
        UnregisterUnitWatch(self.PlayerFrame)
        self.PlayerFrame:Hide()
    end
end