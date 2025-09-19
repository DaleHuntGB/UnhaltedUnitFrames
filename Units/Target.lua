local _, UUF = ...
local oUF = UUF.oUF
local CapitalizedUnits = UUF.CapitalizedUnits

function UUF:SpawnTargetFrame()
    local spawningUnit = "target"
    oUF:RegisterStyle("UUF_" .. CapitalizedUnits[spawningUnit], function(self) UUF.CreateUnitFrame(self, spawningUnit) end)
    oUF:SetActiveStyle("UUF_" .. CapitalizedUnits[spawningUnit])
    self.TargetFrame = oUF:Spawn(spawningUnit, "UUF_" .. CapitalizedUnits[spawningUnit])
    self.TargetFrame:SetPoint(UUF.db.profile[spawningUnit].Frame.AnchorFrom, UIParent, UUF.db.profile[spawningUnit].Frame.AnchorTo, UUF.db.profile[spawningUnit].Frame.XPosition, UUF.db.profile[spawningUnit].Frame.YPosition)
    self.TargetFrame:SetSize(UUF.db.profile[spawningUnit].Frame.Width, UUF.db.profile[spawningUnit].Frame.Height)
    UUF:RegisterRangeFrame(self.TargetFrame, spawningUnit)

    if UUF.db.profile[spawningUnit].Enabled then
        RegisterUnitWatch(self.TargetFrame)
        self.TargetFrame:Show()
    else
        UnregisterUnitWatch(self.TargetFrame)
        self.TargetFrame:Hide()
    end
end