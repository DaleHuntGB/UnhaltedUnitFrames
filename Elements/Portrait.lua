local _, UUF = ...

function UUF:CreateUnitPortrait(unitFrame, unit)
    local PortraitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Portrait

    local PortraitTexture = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit) .. "_PortraitTexture", "BACKGROUND")
    PortraitTexture:SetSize(PortraitDB.Size, PortraitDB.Size)
    PortraitTexture:SetPoint(PortraitDB.Layout[1], unitFrame.HighLevelContainer, PortraitDB.Layout[2], PortraitDB.Layout[3], PortraitDB.Layout[4])
    PortraitTexture:SetTexCoord((PortraitDB.Zoom or 0) * 0.5, 1 - (PortraitDB.Zoom or 0) * 0.5, (PortraitDB.Zoom or 0) * 0.5, 1 - (PortraitDB.Zoom or 0) * 0.5)
    PortraitTexture.showClass = PortraitDB.UseClassPortrait

    PortraitTexture.Border = CreateFrame("Frame", UUF:FetchFrameName(unit) .. "_PortraitBorder", unitFrame.HighLevelContainer, "BackdropTemplate")
    PortraitTexture.Border:SetAllPoints(PortraitTexture)
    PortraitTexture.Border:SetBackdrop(UUF.BACKDROP)
    PortraitTexture.Border:SetBackdropColor(0,0,0,0)
    PortraitTexture.Border:SetBackdropBorderColor(0,0,0,1)

    if PortraitDB.Enabled then
        unitFrame.Portrait = PortraitTexture
        unitFrame.Portrait:Show()
    else
        if unitFrame:IsElementEnabled("Portrait") then unitFrame:DisableElement("Portrait") end
        PortraitTexture:Hide()
        PortraitTexture.Border:Hide()
    end

    return PortraitTexture
end

function UUF:UpdateUnitPortrait(unitFrame, unit)
    local PortraitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Portrait

    if PortraitDB.Enabled then
        unitFrame.Portrait = unitFrame.Portrait or UUF:CreateUnitPortrait(unitFrame, unit)

        if not unitFrame:IsElementEnabled("Portrait") then unitFrame:EnableElement("Portrait") end

        if unitFrame.Portrait then
            unitFrame.Portrait:ClearAllPoints()
            unitFrame.Portrait:SetSize(PortraitDB.Size, PortraitDB.Size)
            unitFrame.Portrait:SetPoint(PortraitDB.Layout[1], unitFrame.HighLevelContainer, PortraitDB.Layout[2], PortraitDB.Layout[3], PortraitDB.Layout[4])
            unitFrame.Portrait:SetTexCoord((PortraitDB.Zoom or 0) * 0.5, 1 - (PortraitDB.Zoom or 0) * 0.5, (PortraitDB.Zoom or 0) * 0.5, 1 - (PortraitDB.Zoom or 0) * 0.5)
            unitFrame.Portrait.showClass = PortraitDB.UseClassPortrait
            unitFrame.Portrait:Show()
            unitFrame.Portrait.Border:Show()
            unitFrame.Portrait:ForceUpdate()
        end
    else
        if not unitFrame.Portrait then return end
        if unitFrame:IsElementEnabled("Portrait") then unitFrame:DisableElement("Portrait") end
        if unitFrame.Portrait then
            unitFrame.Portrait:Hide()
            unitFrame.Portrait.Border:Hide()
            unitFrame.Portrait = nil
        end
    end
end
