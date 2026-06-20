local _, UUF = ...

function UUF:CreatePositionController()
    local ECDM = ""

    if C_AddOns.IsAddOnLoaded("SkironCooldownManager") then
        ECDM = _G["SCM_GroupAnchor_1"]
	elseif C_AddOns.IsAddOnLoaded("Coolinator") then
		ECDM = _G["CoolinatorPrimaryGroupAnchor"]
    else
        ECDM = _G["EssentialCooldownViewer"]
    end

    if ECDM and ECDM:IsShown() then
        local CDMAnchor = CreateFrame("Frame", "UUF_CDMAnchor", UIParent)
        CDMAnchor:SetAllPoints(ECDM)
        CDMAnchor:SetSize(ECDM:GetWidth() or 300, ECDM:GetHeight() or 48)
    else
        UUF:PrettyPrint("|cFF8080FFAnchor Point|r was not found.")
    end
end