local _, UUF = ...
local oUF = UUF.oUF

function UUF:SpawnTargetFrame()
    if not UUF.DB.profile.Target.Frame.Enabled then return end
    local Frame = UUF.DB.profile.Target.Frame
    oUF:RegisterStyle("UUF_Target", function(self) UUF.CreateUnitFrame(self, "Target") end)
    oUF:SetActiveStyle("UUF_Target")
    self.TargetFrame = oUF:Spawn("target", "UUF_Target")
    local AnchorParent = (_G[Frame.AnchorParent] and _G[Frame.AnchorParent]:IsObjectType("Frame")) and _G[Frame.AnchorParent] or UIParent
    self.TargetFrame:SetPoint(Frame.AnchorFrom, AnchorParent, Frame.AnchorTo, Frame.XPosition, Frame.YPosition)
    UUF:RegisterRangeFrame(self.TargetFrame, "target")
end