local _, UUF = ...
local oUF = UUF.oUF

function UUF:SpawnTargetTargetFrame()
    if not UUF.DB.profile.TargetTarget.Frame.Enabled then return end
    local Frame = UUF.DB.profile.TargetTarget.Frame
    oUF:RegisterStyle("UUF_TargetTarget", function(self) UUF.CreateUnitFrame(self, "TargetTarget") end)
    oUF:SetActiveStyle("UUF_TargetTarget")
    self.TargetTargetFrame = oUF:Spawn("targettarget", "UUF_TargetTarget")
    local AnchorParent = (_G[Frame.AnchorParent] and _G[Frame.AnchorParent]:IsObjectType("Frame")) and _G[Frame.AnchorParent] or UIParent
    self.TargetTargetFrame:SetPoint(Frame.AnchorFrom, AnchorParent, Frame.AnchorTo, Frame.XPosition, Frame.YPosition)
    UUF:RegisterRangeFrame(self.TargetTargetFrame, "targettarget")
end