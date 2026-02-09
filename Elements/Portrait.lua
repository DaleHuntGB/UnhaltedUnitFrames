local _, UUF = ...

function UUF:CreateUnitPortrait(unitFrame, unit)
    local PortraitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Portrait
    local frameName = unitFrame:GetName() or UUF:FetchFrameName(unit)

    local unitPortrait
    if PortraitDB.Style == "3D" then
        local backdrop = CreateFrame("Frame", frameName .. "_PortraitBackdrop", unitFrame.HighLevelContainer, "BackdropTemplate")
        backdrop:SetSize(PortraitDB.Width, PortraitDB.Height)
        backdrop:SetPoint(PortraitDB.Layout[1], unitFrame.HighLevelContainer, PortraitDB.Layout[2], PortraitDB.Layout[3], PortraitDB.Layout[4])
        backdrop:SetBackdrop(UUF.BACKDROP)
        backdrop:SetBackdropColor(26/255, 26/255, 26/255, 1)
        backdrop:SetBackdropBorderColor(0, 0, 0, 0)

        unitPortrait = CreateFrame("PlayerModel", frameName .. "_Portrait3D", backdrop)
        unitPortrait:SetAllPoints(backdrop)
        unitPortrait:SetCamDistanceScale(1)
        unitPortrait:SetPortraitZoom(1)
        unitPortrait:SetPosition(0, 0, 0)

        unitPortrait.Backdrop = backdrop
    else
        unitPortrait = unitFrame.HighLevelContainer:CreateTexture(frameName .. "_Portrait2D", "BACKGROUND")
        unitPortrait:SetSize(PortraitDB.Width, PortraitDB.Height)
        unitPortrait:SetPoint(PortraitDB.Layout[1], unitFrame.HighLevelContainer, PortraitDB.Layout[2], PortraitDB.Layout[3], PortraitDB.Layout[4])
        unitPortrait:SetTexCoord((PortraitDB.Zoom or 0) * 0.5, 1 - (PortraitDB.Zoom or 0) * 0.5, (PortraitDB.Zoom or 0) * 0.5, 1 - (PortraitDB.Zoom or 0) * 0.5)
        unitPortrait.showClass = PortraitDB.UseClassPortrait
    end

    local borderParent = unitPortrait.Backdrop or unitFrame.HighLevelContainer
    unitPortrait.Border = CreateFrame("Frame", frameName .. "_PortraitBorder", borderParent, "BackdropTemplate")
    unitPortrait.Border:SetAllPoints(unitPortrait.Backdrop or unitPortrait)
    unitPortrait.Border:SetBackdrop(UUF.BACKDROP)
    unitPortrait.Border:SetBackdropColor(0, 0, 0, 0)
    unitPortrait.Border:SetBackdropBorderColor(0, 0, 0, 1)
    unitPortrait.Border:SetFrameLevel(borderParent:GetFrameLevel() + 10)

    if PortraitDB.Enabled then
        unitFrame.Portrait = unitPortrait
        unitFrame.Portrait:Show()
        if unitFrame.Portrait.Backdrop then
            unitFrame.Portrait.Backdrop:Show()
        end
    else
        if unitFrame:IsElementEnabled("Portrait") then
            unitFrame:DisableElement("Portrait")
        end
        unitPortrait:Hide()
        unitPortrait.Border:Hide()
        if unitPortrait.Backdrop then
            unitPortrait.Backdrop:Hide()
        end
    end

    return unitPortrait
end

function UUF:UpdateUnitPortrait(unitFrame, unit)
    local PortraitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Portrait

    if PortraitDB.Enabled then
        local needsRecreate = false
        if unitFrame.Portrait then
            local is3D = unitFrame.Portrait:IsObjectType("PlayerModel")
            if (PortraitDB.Style == "3D" and not is3D) or (PortraitDB.Style == "2D" and is3D) then
                needsRecreate = true
                if unitFrame:IsElementEnabled("Portrait") then
                    unitFrame:DisableElement("Portrait")
                end
                unitFrame.Portrait.Border:Hide()
                unitFrame.Portrait.Border = nil
                if unitFrame.Portrait.Backdrop then
                    unitFrame.Portrait.Backdrop:Hide()
                    unitFrame.Portrait.Backdrop = nil
                end
                unitFrame.Portrait:Hide()
                unitFrame.Portrait = nil
            end
        end

        if not unitFrame.Portrait or needsRecreate then
            unitFrame.Portrait = UUF:CreateUnitPortrait(unitFrame, unit)
        end

        if not unitFrame:IsElementEnabled("Portrait") then
            unitFrame:EnableElement("Portrait")
        end

        if unitFrame.Portrait then
            if unitFrame.Portrait:IsObjectType("PlayerModel") then
                unitFrame.Portrait.Backdrop:ClearAllPoints()
                unitFrame.Portrait.Backdrop:SetSize(PortraitDB.Width, PortraitDB.Height)
                unitFrame.Portrait.Backdrop:SetPoint(PortraitDB.Layout[1], unitFrame.HighLevelContainer, PortraitDB.Layout[2], PortraitDB.Layout[3], PortraitDB.Layout[4])

                unitFrame.Portrait:SetCamDistanceScale(1)
                unitFrame.Portrait:SetPortraitZoom(1)
                unitFrame.Portrait:SetPosition(0, 0, 0)

                unitFrame.Portrait.Backdrop:Show()
            else
                unitFrame.Portrait:ClearAllPoints()
                unitFrame.Portrait:SetSize(PortraitDB.Width, PortraitDB.Height)
                unitFrame.Portrait:SetPoint(PortraitDB.Layout[1], unitFrame.HighLevelContainer, PortraitDB.Layout[2], PortraitDB.Layout[3], PortraitDB.Layout[4])
                unitFrame.Portrait:SetTexCoord((PortraitDB.Zoom or 0) * 0.5, 1 - (PortraitDB.Zoom or 0) * 0.5, (PortraitDB.Zoom or 0) * 0.5, 1 - (PortraitDB.Zoom or 0) * 0.5)
                unitFrame.Portrait.showClass = PortraitDB.UseClassPortrait
            end

            unitFrame.Portrait:Show()
            unitFrame.Portrait.Border:Show()
            unitFrame.Portrait:ForceUpdate()
        end
    else
        if not unitFrame.Portrait then return end
        if unitFrame:IsElementEnabled("Portrait") then
            unitFrame:DisableElement("Portrait")
        end
        if unitFrame.Portrait then
            unitFrame.Portrait:Hide()
            unitFrame.Portrait.Border:Hide()
            if unitFrame.Portrait.Backdrop then
                unitFrame.Portrait.Backdrop:Hide()
            end
            unitFrame.Portrait = nil
        end
    end
end