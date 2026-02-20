local _, UUF = ...

function UUF:CreateUnitPortrait(unitFrame, unit)
    local PortraitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Portrait
    local frameName = unitFrame:GetName() or UUF:FetchFrameName(unit)

    local unitPortrait
    if PortraitDB.Style == "3D" then
        local backdrop = CreateFrame("Frame", frameName .. "_PortraitBackdrop", unitFrame.HighLevelContainer, "BackdropTemplate")
        UUF:QueueOrRun(function()
            backdrop:ClearAllPoints()
            backdrop:SetSize(PortraitDB.Width, PortraitDB.Height)
            UUF:SetPointIfChanged(backdrop, PortraitDB.Layout[1], unitFrame.HighLevelContainer, PortraitDB.Layout[2], PortraitDB.Layout[3], PortraitDB.Layout[4])
        end)
        backdrop:SetBackdrop(UUF.BACKDROP)
        backdrop:SetBackdropColor(26/255, 26/255, 26/255, 1)
        backdrop:SetBackdropBorderColor(0, 0, 0, 0)

        unitPortrait = CreateFrame("PlayerModel", frameName .. "_Portrait3D", backdrop)
        UUF:QueueOrRun(function()
            unitPortrait:ClearAllPoints()
            unitPortrait:SetAllPoints(backdrop)
        end)
        unitPortrait:SetCamDistanceScale(1)
        unitPortrait:SetPortraitZoom(1)
        unitPortrait:SetPosition(0, 0, 0)

        unitPortrait.Backdrop = backdrop
    else
        unitPortrait = unitFrame.HighLevelContainer:CreateTexture(frameName .. "_Portrait2D", "BACKGROUND")
        UUF:QueueOrRun(function()
            unitPortrait:ClearAllPoints()
            unitPortrait:SetSize(PortraitDB.Width, PortraitDB.Height)
            UUF:SetPointIfChanged(unitPortrait, PortraitDB.Layout[1], unitFrame.HighLevelContainer, PortraitDB.Layout[2], PortraitDB.Layout[3], PortraitDB.Layout[4])
        end)
        unitPortrait:SetTexCoord((PortraitDB.Zoom or 0) * 0.5, 1 - (PortraitDB.Zoom or 0) * 0.5, (PortraitDB.Zoom or 0) * 0.5, 1 - (PortraitDB.Zoom or 0) * 0.5)
        unitPortrait.showClass = PortraitDB.UseClassPortrait
    end

    local borderParent = unitPortrait.Backdrop or unitFrame.HighLevelContainer
    unitPortrait.Border = CreateFrame("Frame", frameName .. "_PortraitBorder", borderParent, "BackdropTemplate")
    UUF:QueueOrRun(function()
        unitPortrait.Border:ClearAllPoints()
        UUF:SetPointIfChanged(unitPortrait.Border, "TOPLEFT", unitPortrait.Backdrop or unitPortrait, "TOPLEFT", 0, 0)
        UUF:SetPointIfChanged(unitPortrait.Border, "BOTTOMRIGHT", unitPortrait.Backdrop or unitPortrait, "BOTTOMRIGHT", 0, 0)
        unitPortrait.Border:SetFrameLevel(borderParent:GetFrameLevel() + 10)
    end)
    unitPortrait.Border:SetBackdrop(UUF.BACKDROP)
    unitPortrait.Border:SetBackdropColor(0, 0, 0, 0)
    unitPortrait.Border:SetBackdropBorderColor(0, 0, 0, 1)

    if PortraitDB.Enabled then
        unitFrame.Portrait = unitPortrait
        UUF:QueueOrRun(function() unitFrame.Portrait:Show() if unitFrame.Portrait.Backdrop then unitFrame.Portrait.Backdrop:Show() end end)
    else
        if unitFrame:IsElementEnabled("Portrait") then
            unitFrame:DisableElement("Portrait")
        end
        UUF:QueueOrRun(function() unitPortrait:Hide() unitPortrait.Border:Hide() if unitPortrait.Backdrop then unitPortrait.Backdrop:Hide() end end)
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
                UUF:QueueOrRun(function()
                    unitFrame.Portrait.Backdrop:ClearAllPoints()
                    unitFrame.Portrait.Backdrop:SetSize(PortraitDB.Width, PortraitDB.Height)
                    UUF:SetPointIfChanged(unitFrame.Portrait.Backdrop, PortraitDB.Layout[1], unitFrame.HighLevelContainer, PortraitDB.Layout[2], PortraitDB.Layout[3], PortraitDB.Layout[4])
                    unitFrame.Portrait.Backdrop:Show()
                end)
                unitFrame.Portrait:SetCamDistanceScale(1)
                unitFrame.Portrait:SetPortraitZoom(1)
                unitFrame.Portrait:SetPosition(0, 0, 0)
            else
                UUF:QueueOrRun(function()
                    unitFrame.Portrait:ClearAllPoints()
                    unitFrame.Portrait:SetSize(PortraitDB.Width, PortraitDB.Height)
                    UUF:SetPointIfChanged(unitFrame.Portrait, PortraitDB.Layout[1], unitFrame.HighLevelContainer, PortraitDB.Layout[2], PortraitDB.Layout[3], PortraitDB.Layout[4])
                end)
                unitFrame.Portrait:SetTexCoord((PortraitDB.Zoom or 0) * 0.5, 1 - (PortraitDB.Zoom or 0) * 0.5, (PortraitDB.Zoom or 0) * 0.5, 1 - (PortraitDB.Zoom or 0) * 0.5)
                unitFrame.Portrait.showClass = PortraitDB.UseClassPortrait
            end

            UUF:QueueOrRun(function()
                unitFrame.Portrait:Show()
                unitFrame.Portrait.Border:Show()
            end)
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