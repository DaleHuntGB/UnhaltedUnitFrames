local _, UUF = ...
local oUF = UUF.oUF

function UUF:SpawnPetFrame()
    if not UUF.DB.profile.Pet.Frame.Enabled then
        if UUF.DB.profile.Pet.Frame.ForceHideBlizzard then
            UUF:DisableBlizzard("Pet")
        end
        return
    end
    local Frame = UUF.DB.profile.Pet.Frame
    oUF:RegisterStyle("UUF_Pet", function(self) UUF.CreateUnitFrame(self, "Pet") end)
    oUF:SetActiveStyle("UUF_Pet")
    self.PetFrame = oUF:Spawn("pet", "UUF_Pet")
    local AnchorParent = (_G[Frame.AnchorParent] and _G[Frame.AnchorParent]:IsObjectType("Frame")) and _G[Frame.AnchorParent] or UIParent
    self.PetFrame:SetPoint(Frame.AnchorFrom, AnchorParent, Frame.AnchorTo, Frame.XPosition, Frame.YPosition)
    UUF:RegisterRangeFrame(self.PetFrame, "pet")
end