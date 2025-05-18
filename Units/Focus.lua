local _, UUF = ...
local oUF = UUF.oUF

function UUF:SpawnFocusFrame()
    if not UUF.DB.profile.Focus.Frame.Enabled then
        if UUF.DB.profile.Focus.Frame.ForceHideBlizzard then
            UUF:DisableBlizzard("Focus")
        end
        return
    end

    local Frame = UUF.DB.profile.Focus.Frame
    oUF:RegisterStyle("UUF_Focus", function(self) UUF.CreateUnitFrame(self, "Focus") end)
    oUF:SetActiveStyle("UUF_Focus")
    self.FocusFrame = oUF:Spawn("focus", "UUF_Focus")
    local AnchorParent = (_G[Frame.AnchorParent] and _G[Frame.AnchorParent]:IsObjectType("Frame")) and _G[Frame.AnchorParent] or UIParent
    self.FocusFrame:SetPoint(Frame.AnchorFrom, AnchorParent, Frame.AnchorTo, Frame.XPosition, Frame.YPosition)
    UUF:RegisterRangeFrame(self.FocusFrame, "focus")
end
