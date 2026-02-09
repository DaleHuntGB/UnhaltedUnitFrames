local _, UUF = ...

function UUF:CreatePositionController()
    local ECDM = _G["EssentialCooldownViewer"]
    if ECDM and ECDM:IsShown() then
        local CDMAnchor = CreateFrame("Frame", "UUF_CDMAnchor", UIParent)
        UUF:QueueOrRun(function()
            CDMAnchor:SetAllPoints(ECDM)
            CDMAnchor:SetSize(ECDM:GetWidth() or 300, ECDM:GetHeight() or 48)
        end)
    else
        UUF:PrettyPrint("|cFFFFCC00Essential Cooldown Viewer|r was not found.")
    end
end

function UUF:IsCDMAnchorActive()
    local ECDM = _G["EssentialCooldownViewer"]
    local CDMAnchor = _G["UUF_CDMAnchor"]
    return  ECDM and ECDM:IsShown() and CDMAnchor and CDMAnchor:IsShown()
end