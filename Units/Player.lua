local _, UUF = ...
local oUF = UUF.oUF

function UUF:SpawnPlayerFrame()
    if not UUF.DB.profile.Player.Frame.Enabled then return end
    local Frame = UUF.DB.profile.Player.Frame
    oUF:RegisterStyle("UUF_Player", function(self) UUF.CreateUnitFrame(self, "Player") end)
    oUF:SetActiveStyle("UUF_Player")
    self.PlayerFrame = oUF:Spawn("player", "UUF_Player")
    local AnchorParent = (_G[Frame.AnchorParent] and _G[Frame.AnchorParent]:IsObjectType("Frame")) and _G[Frame.AnchorParent] or UIParent
    self.PlayerFrame:SetPoint(Frame.AnchorFrom, AnchorParent, Frame.AnchorTo, Frame.XPosition, Frame.YPosition)
end