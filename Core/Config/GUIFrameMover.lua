local _, UUF = ...
local AG = UUF.AG
local GUIWidgets = UUF.GUIWidgets

local GUIFrameMover = {}
UUF.GUIFrameMover = GUIFrameMover

function GUIFrameMover:BuildFrameMoverSettings(containerParent)
    local Container = GUIWidgets.CreateInlineGroup(containerParent, "Frame Movers")

    if not UUF.db.profile.General.FrameMover then
        UUF.db.profile.General.FrameMover = { Enabled = false }
    end

    GUIWidgets.CreateInformationTag(Container, "Unlock frames to drag them with the left mouse button. Re-lock when finished.")

    local Toggle = AG:Create("CheckBox")
    Toggle:SetLabel("Unlock Frames")
    Toggle:SetValue(UUF.db.profile.General.FrameMover.Enabled)
    Toggle:SetFullWidth(true)
    Toggle:SetCallback("OnValueChanged", function(_, _, value)
        if InCombatLockdown() then
            UUF:PrettyPrint("Cannot toggle frame movers in combat.")
            Toggle:SetValue(UUF.db.profile.General.FrameMover.Enabled)
            return
        end
        UUF.db.profile.General.FrameMover.Enabled = value
        UUF:ApplyFrameMovers()
    end)
    Container:AddChild(Toggle)

    containerParent:DoLayout()
end

return GUIFrameMover
