local _, UUF = ...
local oUF = UUF.oUF
local CapitalizedUnits = UUF.CapitalizedUnits

function UUF:SpawnFocusTargetFrame()
    local spawningUnit = "focustarget"
    oUF:RegisterStyle("UUF_" .. CapitalizedUnits[spawningUnit], UUF.CreateUnitFrame)
    oUF:SetActiveStyle("UUF_" .. CapitalizedUnits[spawningUnit])
    self.FocusTarget = oUF:Spawn(spawningUnit, "UUF_" .. CapitalizedUnits[spawningUnit])
    self.FocusTarget:SetPoint(UUF.db.profile[spawningUnit].Frame.AnchorFrom, UUF.db.profile[spawningUnit].Frame.AnchorParent, UUF.db.profile[spawningUnit].Frame.AnchorTo, UUF.db.profile[spawningUnit].Frame.XPosition, UUF.db.profile[spawningUnit].Frame.YPosition)
    self.FocusTarget:SetSize(UUF.db.profile[spawningUnit].Frame.Width, UUF.db.profile[spawningUnit].Frame.Height)
    UUF:RegisterRangeFrame(self.FocusTarget, spawningUnit)

    if UUF.db.profile[spawningUnit].Enabled then
        RegisterUnitWatch(self.FocusTarget)
        self.FocusTarget:Show()
    else
        UnregisterUnitWatch(self.FocusTarget)
        self.FocusTarget:Hide()
    end
end