local _, UUF = ...
local oUF = UUF.oUF
local CapitalizedUnits = UUF.CapitalizedUnits

function UUF:SpawnTargetTargetFrame()
    local spawningUnit = "targettarget"
    oUF:RegisterStyle("UUF_" .. CapitalizedUnits[spawningUnit], function(self) UUF.CreateUnitFrame(self, spawningUnit) end)
    oUF:SetActiveStyle("UUF_" .. CapitalizedUnits[spawningUnit])
    self.TargetTarget = oUF:Spawn(spawningUnit, "UUF_" .. CapitalizedUnits[spawningUnit])
    self.TargetTarget:SetPoint(UUF.db.profile[spawningUnit].Frame.AnchorFrom, UUF.db.profile[spawningUnit].Frame.AnchorParent, UUF.db.profile[spawningUnit].Frame.AnchorTo, UUF.db.profile[spawningUnit].Frame.XPosition, UUF.db.profile[spawningUnit].Frame.YPosition)
    self.TargetTarget:SetSize(UUF.db.profile[spawningUnit].Frame.Width, UUF.db.profile[spawningUnit].Frame.Height)

    if UUF.db.profile[spawningUnit].Enabled then
        RegisterUnitWatch(self.TargetTarget)
        self.TargetTarget:Show()
    else
        UnregisterUnitWatch(self.TargetTarget)
        self.TargetTarget:Hide()
    end
end