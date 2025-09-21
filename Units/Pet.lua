local _, UUF = ...
local oUF = UUF.oUF
local CapitalizedUnits = UUF.CapitalizedUnits

function UUF:SpawnPetFrame()
    local spawningUnit = "pet"
    oUF:RegisterStyle("UUF_" .. CapitalizedUnits[spawningUnit], UUF.CreateUnitFrame)
    oUF:SetActiveStyle("UUF_" .. CapitalizedUnits[spawningUnit])
    self.Pet = oUF:Spawn(spawningUnit, "UUF_" .. CapitalizedUnits[spawningUnit])
    self.Pet:SetPoint(UUF.db.profile[spawningUnit].Frame.AnchorFrom, UUF.db.profile[spawningUnit].Frame.AnchorParent, UUF.db.profile[spawningUnit].Frame.AnchorTo, UUF.db.profile[spawningUnit].Frame.XPosition, UUF.db.profile[spawningUnit].Frame.YPosition)
    self.Pet:SetSize(UUF.db.profile[spawningUnit].Frame.Width, UUF.db.profile[spawningUnit].Frame.Height)
    UUF:RegisterRangeFrame(self.Pet, spawningUnit)

    if UUF.db.profile[spawningUnit].Enabled then
        RegisterUnitWatch(self.Pet)
        self.Pet:Show()
    else
        UnregisterUnitWatch(self.Pet)
        self.Pet:Hide()
    end
end