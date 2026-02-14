local _, UUF = ...

function UUF:CreateUnitPortrait(unitFrame, unit)
    local PortraitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Portrait

    local unitPortrait
    if PortraitDB.Style == "3D" then
        local backdrop = CreateFrame("Frame", UUF:FetchFrameName(unit) .. "_PortraitBackdrop", unitFrame.HighLevelContainer, "BackdropTemplate")
        backdrop:SetSize(PortraitDB.Width, PortraitDB.Height)
        backdrop:SetPoint(PortraitDB.Layout[1], unitFrame.HighLevelContainer, PortraitDB.Layout[2], PortraitDB.Layout[3], PortraitDB.Layout[4])
        backdrop:SetBackdrop(UUF.BACKDROP)
        backdrop:SetBackdropColor(26/255, 26/255, 26/255, 1)
        backdrop:SetBackdropBorderColor(0, 0, 0, 0)

        unitPortrait = CreateFrame("PlayerModel", UUF:FetchFrameName(unit) .. "_Portrait3D", backdrop)
        unitPortrait:SetAllPoints(backdrop)
        unitPortrait:SetCamDistanceScale(1)
        unitPortrait:SetPortraitZoom(1)
        unitPortrait:SetPosition(0, 0, 0)

        unitPortrait.Backdrop = backdrop
    else
        unitPortrait = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit) .. "_Portrait2D", "BACKGROUND")
        unitPortrait:SetSize(PortraitDB.Width, PortraitDB.Height)
        unitPortrait:SetPoint(PortraitDB.Layout[1], unitFrame.HighLevelContainer, PortraitDB.Layout[2], PortraitDB.Layout[3], PortraitDB.Layout[4])
        unitPortrait:SetTexCoord((PortraitDB.Zoom or 0) * 0.5, 1 - (PortraitDB.Zoom or 0) * 0.5, (PortraitDB.Zoom or 0) * 0.5, 1 - (PortraitDB.Zoom or 0) * 0.5)
        unitPortrait.showClass = PortraitDB.UseClassPortrait
    end

    local borderParent = unitPortrait.Backdrop or unitFrame.HighLevelContainer
    unitPortrait.Border = CreateFrame("Frame", UUF:FetchFrameName(unit) .. "_PortraitBorder", borderParent, "BackdropTemplate")
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

        -- Only enable element if the frame is fully initialized (has the element system)
        if unitFrame.EnableElement and not unitFrame:IsElementEnabled("Portrait") then
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
            
            -- Update or create secure button overlay for left-click and/or right-click
            if PortraitDB.LeftClickTargetOnPortrait or PortraitDB.RightClickMenuOnPortrait then
                if not unitFrame.Portrait.PortraitButton then
                    local PortraitButton = CreateFrame("Button", UUF:FetchFrameName(unit) .. "_PortraitButton", unitFrame, "SecureUnitButtonTemplate")
                    PortraitButton:SetSize(PortraitDB.Width, PortraitDB.Height)
                    -- Anchor to unitFrame (secure) using same anchor points as portrait (HighLevelContainer covers unitFrame)
                    PortraitButton:SetPoint(PortraitDB.Layout[1], unitFrame, PortraitDB.Layout[2], PortraitDB.Layout[3], PortraitDB.Layout[4])
                    PortraitButton:RegisterForClicks("AnyUp")
                    PortraitButton:SetAttribute("unit", unitFrame.unit)
                    if PortraitDB.LeftClickTargetOnPortrait then
                        PortraitButton:SetAttribute("*type1", "target")
                    end
                    if PortraitDB.RightClickMenuOnPortrait then
                        PortraitButton:SetAttribute("*type2", "togglemenu")
                    end
                    PortraitButton:SetFrameLevel(unitFrame.HighLevelContainer:GetFrameLevel() + 1)
                    PortraitButton:EnableMouse(true)
                    unitFrame.Portrait.PortraitButton = PortraitButton
                    
                    -- Store reference to unitFrame for tooltip
                    PortraitButton.__owner = unitFrame
                    
                    -- Set up hooks if left-click is enabled
                    if PortraitDB.LeftClickTargetOnPortrait then
                        local MouseoverDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Mouseover
                        if MouseoverDB and MouseoverDB.Enabled then
                            -- Create highlight overlay
                            local PortraitHighlight = CreateFrame("Frame", nil, unitFrame.Portrait.Border, "BackdropTemplate")
                            local portraitHeight = PortraitDB.Height
                            local highlightHeight = portraitHeight * 0.25
                            PortraitHighlight:SetPoint("BOTTOMLEFT", unitFrame.Portrait, "BOTTOMLEFT", 0, 0)
                            PortraitHighlight:SetPoint("BOTTOMRIGHT", unitFrame.Portrait, "BOTTOMRIGHT", 0, 0)
                            PortraitHighlight:SetPoint("TOPLEFT", unitFrame.Portrait, "BOTTOMLEFT", 0, highlightHeight)
                            PortraitHighlight:SetPoint("TOPRIGHT", unitFrame.Portrait, "BOTTOMRIGHT", 0, highlightHeight)
                            
                            if MouseoverDB.Style == "BORDER" then
                                PortraitHighlight:SetBackdrop(UUF.BACKDROP)
                                PortraitHighlight:SetBackdropColor(0,0,0,0)
                                PortraitHighlight:SetBackdropBorderColor(MouseoverDB.Colour[1], MouseoverDB.Colour[2], MouseoverDB.Colour[3], MouseoverDB.HighlightOpacity)
                            elseif MouseoverDB.Style == "GRADIENT" then
                                PortraitHighlight:SetBackdrop({
                                    bgFile = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Gradient.png",
                                    edgeFile = nil,
                                    tile = false, tileSize = 0, edgeSize = 0,
                                    insets = { left = 0, right = 0, top = 0, bottom = 0 },
                                })
                                PortraitHighlight:SetBackdropColor(MouseoverDB.Colour[1], MouseoverDB.Colour[2], MouseoverDB.Colour[3], MouseoverDB.HighlightOpacity)
                                PortraitHighlight:SetBackdropBorderColor(0,0,0,0)
                            else
                                PortraitHighlight:SetBackdrop(UUF.BACKDROP)
                                PortraitHighlight:SetBackdropColor(MouseoverDB.Colour[1], MouseoverDB.Colour[2], MouseoverDB.Colour[3], MouseoverDB.HighlightOpacity)
                                PortraitHighlight:SetBackdropBorderColor(0,0,0,0)
                            end
                            
                            PortraitHighlight:Hide()
                            PortraitHighlight:SetFrameLevel(unitFrame.Portrait.Border:GetFrameLevel() + 1)
                            PortraitButton.PortraitHighlight = PortraitHighlight
                            
                            -- Set OnEnter/OnLeave for tooltip and highlight
                            PortraitButton:SetScript("OnEnter", function()
                                UnitFrame_OnEnter(unitFrame)
                                if PortraitButton.PortraitHighlight then
                                    PortraitButton.PortraitHighlight:Show()
                                end
                            end)
                            PortraitButton:SetScript("OnLeave", function()
                                UnitFrame_OnLeave(unitFrame)
                                if PortraitButton.PortraitHighlight then
                                    PortraitButton.PortraitHighlight:Hide()
                                end
                            end)
                        else
                            -- Set tooltip even if highlight is disabled
                            PortraitButton:SetScript("OnEnter", function() UnitFrame_OnEnter(unitFrame) end)
                            PortraitButton:SetScript("OnLeave", function() UnitFrame_OnLeave(unitFrame) end)
                        end
                    end
                else
                    unitFrame.Portrait.PortraitButton:ClearAllPoints()
                    unitFrame.Portrait.PortraitButton:SetSize(PortraitDB.Width, PortraitDB.Height)
                    -- Anchor to unitFrame (secure) using same anchor points as portrait (HighLevelContainer covers unitFrame)
                    unitFrame.Portrait.PortraitButton:SetPoint(PortraitDB.Layout[1], unitFrame, PortraitDB.Layout[2], PortraitDB.Layout[3], PortraitDB.Layout[4])
                    unitFrame.Portrait.PortraitButton:SetAttribute("unit", unitFrame.unit)
                    -- Update attributes based on current settings
                    if PortraitDB.LeftClickTargetOnPortrait then
                        unitFrame.Portrait.PortraitButton:SetAttribute("*type1", "target")
                        
                        -- Update or create highlight overlay
                        local MouseoverDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Mouseover
                        if MouseoverDB and MouseoverDB.Enabled then
                            if not unitFrame.Portrait.PortraitButton.PortraitHighlight then
                                local PortraitHighlight = CreateFrame("Frame", nil, unitFrame.Portrait.Border, "BackdropTemplate")
                                -- Set highlight to 25% of portrait height (anchored at bottom)
                                local portraitHeight = PortraitDB.Height
                                local highlightHeight = portraitHeight * 0.25
                                PortraitHighlight:SetPoint("BOTTOMLEFT", unitFrame.Portrait, "BOTTOMLEFT", 0, 0)
                                PortraitHighlight:SetPoint("BOTTOMRIGHT", unitFrame.Portrait, "BOTTOMRIGHT", 0, 0)
                                PortraitHighlight:SetPoint("TOPLEFT", unitFrame.Portrait, "BOTTOMLEFT", 0, highlightHeight)
                                PortraitHighlight:SetPoint("TOPRIGHT", unitFrame.Portrait, "BOTTOMRIGHT", 0, highlightHeight)
                                
                                if MouseoverDB.Style == "BORDER" then
                                    PortraitHighlight:SetBackdrop(UUF.BACKDROP)
                                    PortraitHighlight:SetBackdropColor(0,0,0,0)
                                    PortraitHighlight:SetBackdropBorderColor(MouseoverDB.Colour[1], MouseoverDB.Colour[2], MouseoverDB.Colour[3], MouseoverDB.HighlightOpacity)
                                elseif MouseoverDB.Style == "GRADIENT" then
                                    PortraitHighlight:SetBackdrop({
                                        bgFile = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Gradient.png",
                                        edgeFile = nil,
                                        tile = false, tileSize = 0, edgeSize = 0,
                                        insets = { left = 0, right = 0, top = 0, bottom = 0 },
                                    })
                                    PortraitHighlight:SetBackdropColor(MouseoverDB.Colour[1], MouseoverDB.Colour[2], MouseoverDB.Colour[3], MouseoverDB.HighlightOpacity)
                                    PortraitHighlight:SetBackdropBorderColor(0,0,0,0)
                                else
                                    PortraitHighlight:SetBackdrop(UUF.BACKDROP)
                                    PortraitHighlight:SetBackdropColor(MouseoverDB.Colour[1], MouseoverDB.Colour[2], MouseoverDB.Colour[3], MouseoverDB.HighlightOpacity)
                                    PortraitHighlight:SetBackdropBorderColor(0,0,0,0)
                                end
                                
                                PortraitHighlight:Hide()
                                PortraitHighlight:SetFrameLevel(unitFrame.Portrait.Border:GetFrameLevel() + 1)
                                unitFrame.Portrait.PortraitButton.PortraitHighlight = PortraitHighlight
                                
                                -- Store reference to unitFrame for tooltip
                                unitFrame.Portrait.PortraitButton.__owner = unitFrame
                                
                                -- Set OnEnter/OnLeave for tooltip and highlight
                                unitFrame.Portrait.PortraitButton:SetScript("OnEnter", function()
                                    UnitFrame_OnEnter(unitFrame)
                                    if unitFrame.Portrait.PortraitButton.PortraitHighlight then
                                        unitFrame.Portrait.PortraitButton.PortraitHighlight:Show()
                                    end
                                end)
                                unitFrame.Portrait.PortraitButton:SetScript("OnLeave", function()
                                    UnitFrame_OnLeave(unitFrame)
                                    if unitFrame.Portrait.PortraitButton.PortraitHighlight then
                                        unitFrame.Portrait.PortraitButton.PortraitHighlight:Hide()
                                    end
                                end)
                            else
                                -- Update highlight style if it exists
                                -- Set highlight to 25% of portrait height (anchored at bottom)
                                local portraitHeight = PortraitDB.Height
                                local highlightHeight = portraitHeight * 0.25
                                unitFrame.Portrait.PortraitButton.PortraitHighlight:ClearAllPoints()
                                unitFrame.Portrait.PortraitButton.PortraitHighlight:SetPoint("BOTTOMLEFT", unitFrame.Portrait, "BOTTOMLEFT", 0, 0)
                                unitFrame.Portrait.PortraitButton.PortraitHighlight:SetPoint("BOTTOMRIGHT", unitFrame.Portrait, "BOTTOMRIGHT", 0, 0)
                                unitFrame.Portrait.PortraitButton.PortraitHighlight:SetPoint("TOPLEFT", unitFrame.Portrait, "BOTTOMLEFT", 0, highlightHeight)
                                unitFrame.Portrait.PortraitButton.PortraitHighlight:SetPoint("TOPRIGHT", unitFrame.Portrait, "BOTTOMRIGHT", 0, highlightHeight)
                                if MouseoverDB.Style == "BORDER" then
                                    unitFrame.Portrait.PortraitButton.PortraitHighlight:SetBackdrop(UUF.BACKDROP)
                                    unitFrame.Portrait.PortraitButton.PortraitHighlight:SetBackdropColor(0,0,0,0)
                                    unitFrame.Portrait.PortraitButton.PortraitHighlight:SetBackdropBorderColor(MouseoverDB.Colour[1], MouseoverDB.Colour[2], MouseoverDB.Colour[3], MouseoverDB.HighlightOpacity)
                                elseif MouseoverDB.Style == "GRADIENT" then
                                    unitFrame.Portrait.PortraitButton.PortraitHighlight:SetBackdrop({
                                        bgFile = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Gradient.png",
                                        edgeFile = nil,
                                        tile = false, tileSize = 0, edgeSize = 0,
                                        insets = { left = 0, right = 0, top = 0, bottom = 0 },
                                    })
                                    unitFrame.Portrait.PortraitButton.PortraitHighlight:SetBackdropColor(MouseoverDB.Colour[1], MouseoverDB.Colour[2], MouseoverDB.Colour[3], MouseoverDB.HighlightOpacity)
                                    unitFrame.Portrait.PortraitButton.PortraitHighlight:SetBackdropBorderColor(0,0,0,0)
                                else
                                    unitFrame.Portrait.PortraitButton.PortraitHighlight:SetBackdrop(UUF.BACKDROP)
                                    unitFrame.Portrait.PortraitButton.PortraitHighlight:SetBackdropColor(MouseoverDB.Colour[1], MouseoverDB.Colour[2], MouseoverDB.Colour[3], MouseoverDB.HighlightOpacity)
                                    unitFrame.Portrait.PortraitButton.PortraitHighlight:SetBackdropBorderColor(0,0,0,0)
                                end
                            end
                        elseif unitFrame.Portrait.PortraitButton.PortraitHighlight then
                            -- Hide highlight if mouseover indicator is disabled
                            unitFrame.Portrait.PortraitButton.PortraitHighlight:Hide()
                        end
                        -- Always ensure OnEnter/OnLeave hooks are set when left-click is enabled
                        -- (they may have been removed when left-click was previously disabled)
                        unitFrame.Portrait.PortraitButton:SetScript("OnEnter", function()
                            UnitFrame_OnEnter(unitFrame)
                            if unitFrame.Portrait.PortraitButton.PortraitHighlight then
                                unitFrame.Portrait.PortraitButton.PortraitHighlight:Show()
                            end
                        end)
                        unitFrame.Portrait.PortraitButton:SetScript("OnLeave", function()
                            UnitFrame_OnLeave(unitFrame)
                            if unitFrame.Portrait.PortraitButton.PortraitHighlight then
                                unitFrame.Portrait.PortraitButton.PortraitHighlight:Hide()
                            end
                        end)
                    else
                        unitFrame.Portrait.PortraitButton:SetAttribute("*type1", nil)
                        if unitFrame.Portrait.PortraitButton.PortraitHighlight then
                            unitFrame.Portrait.PortraitButton.PortraitHighlight:Hide()
                        end
                        -- Remove OnEnter/OnLeave hooks from portrait button when left-click is disabled
                        unitFrame.Portrait.PortraitButton:SetScript("OnEnter", nil)
                        unitFrame.Portrait.PortraitButton:SetScript("OnLeave", nil)
                        -- Restore OnEnter/OnLeave hooks to main frame
                        -- HookScript is safe to call multiple times - it just adds hooks
                        unitFrame:HookScript("OnEnter", UnitFrame_OnEnter)
                        unitFrame:HookScript("OnLeave", UnitFrame_OnLeave)
                    end
                    if PortraitDB.RightClickMenuOnPortrait then
                        unitFrame.Portrait.PortraitButton:SetAttribute("*type2", "togglemenu")
                    else
                        unitFrame.Portrait.PortraitButton:SetAttribute("*type2", nil)
                    end
                end
                unitFrame.Portrait.PortraitButton:Show()
                -- Remove left-click targeting from main frame if on portrait
                if PortraitDB.LeftClickTargetOnPortrait then
                    unitFrame:SetAttribute("*type1", nil)
                    -- Update mouseover indicator to prevent tooltip (it uses SetScript which will override HookScript hooks)
                    UUF:UpdateUnitMouseoverIndicator(unitFrame, unit)
                else
                    unitFrame:SetAttribute("*type1", "target")
                    -- Update mouseover indicator to restore tooltip
                    UUF:UpdateUnitMouseoverIndicator(unitFrame, unit)
                end
                -- Remove right-click menu from main frame if on portrait
                if PortraitDB.RightClickMenuOnPortrait then
                    unitFrame:SetAttribute("*type2", nil)
                else
                    unitFrame:SetAttribute("*type2", "togglemenu")
                end
            else
                if unitFrame.Portrait.PortraitButton then
                    unitFrame.Portrait.PortraitButton:Hide()
                end
                -- Restore left-click targeting to main frame
                unitFrame:SetAttribute("*type1", "target")
                -- Restore right-click menu to main frame
                unitFrame:SetAttribute("*type2", "togglemenu")
            end
            
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
            if unitFrame.Portrait.PortraitButton then
                unitFrame.Portrait.PortraitButton:Hide()
            end
            -- Restore left-click targeting to main frame when portrait is disabled
            unitFrame:SetAttribute("*type1", "target")
            -- Restore right-click menu to main frame when portrait is disabled
            unitFrame:SetAttribute("*type2", "togglemenu")
            unitFrame.Portrait = nil
        end
    end
end