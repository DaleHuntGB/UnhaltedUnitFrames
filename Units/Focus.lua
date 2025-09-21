local _, UUF = ...
local oUF = UUF.oUF
local CapitalizedUnits = UUF.CapitalizedUnits

function UUF:SpawnFocusFrame()
    local spawningUnit = "focus"
    oUF:RegisterStyle("UUF_" .. CapitalizedUnits[spawningUnit], UUF.CreateUnitFrame)
    oUF:SetActiveStyle("UUF_" .. CapitalizedUnits[spawningUnit])
    self.Focus = oUF:Spawn(spawningUnit, "UUF_" .. CapitalizedUnits[spawningUnit])
    self.Focus:SetPoint(UUF.db.profile[spawningUnit].Frame.AnchorFrom, UUF.db.profile[spawningUnit].Frame.AnchorParent, UUF.db.profile[spawningUnit].Frame.AnchorTo, UUF.db.profile[spawningUnit].Frame.XPosition, UUF.db.profile[spawningUnit].Frame.YPosition)
    self.Focus:SetSize(UUF.db.profile[spawningUnit].Frame.Width, UUF.db.profile[spawningUnit].Frame.Height)
    UUF:RegisterRangeFrame(self.Focus, spawningUnit)

    if UUF.db.profile[spawningUnit].Enabled then
        RegisterUnitWatch(self.Focus)
        self.Focus:Show()
    else
        UnregisterUnitWatch(self.Focus)
        self.Focus:Hide()
    end
end