local _, UUF = ...

-- Helper function to create a portrait highlight frame
local function CreatePortraitHighlight(portraitButton, unitFrame, PortraitDB, MouseoverDB)
    local PortraitHighlight = CreateFrame("Frame", nil, unitFrame.Portrait.Border, "BackdropTemplate")
    local portraitHeight = PortraitDB.Height
    local highlightHeight = portraitHeight * 0.25
    
    PortraitHighlight:SetPoint("BOTTOMLEFT", unitFrame.Portrait, "BOTTOMLEFT", 0, 0)
    PortraitHighlight:SetPoint("BOTTOMRIGHT", unitFrame.Portrait, "BOTTOMRIGHT", 0, 0)
    PortraitHighlight:SetPoint("TOPLEFT", unitFrame.Portrait, "BOTTOMLEFT", 0, highlightHeight)
    PortraitHighlight:SetPoint("TOPRIGHT", unitFrame.Portrait, "BOTTOMRIGHT", 0, highlightHeight)
    
    PortraitHighlight:Hide()
    PortraitHighlight:SetFrameLevel(unitFrame.Portrait.Border:GetFrameLevel() + 1)
    portraitButton.PortraitHighlight = PortraitHighlight
    
    return PortraitHighlight
end

-- Helper function to set up highlight backdrop style
local function SetupPortraitHighlightStyle(highlight, MouseoverDB)
    if MouseoverDB.Style == "BORDER" then
        highlight:SetBackdrop(UUF.BACKDROP)
        highlight:SetBackdropColor(0, 0, 0, 0)
        highlight:SetBackdropBorderColor(MouseoverDB.Colour[1], MouseoverDB.Colour[2], MouseoverDB.Colour[3], MouseoverDB.HighlightOpacity)
    elseif MouseoverDB.Style == "GRADIENT" then
        highlight:SetBackdrop({
            bgFile = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Gradient.png",
            edgeFile = nil,
            tile = false, tileSize = 0, edgeSize = 0,
            insets = { left = 0, right = 0, top = 0, bottom = 0 },
        })
        highlight:SetBackdropColor(MouseoverDB.Colour[1], MouseoverDB.Colour[2], MouseoverDB.Colour[3], MouseoverDB.HighlightOpacity)
        highlight:SetBackdropBorderColor(0, 0, 0, 0)
    else
        highlight:SetBackdrop(UUF.BACKDROP)
        highlight:SetBackdropColor(MouseoverDB.Colour[1], MouseoverDB.Colour[2], MouseoverDB.Colour[3], MouseoverDB.HighlightOpacity)
        highlight:SetBackdropBorderColor(0, 0, 0, 0)
    end
end

-- Helper function to update highlight position
local function UpdatePortraitHighlightPosition(highlight, portrait, PortraitDB)
    local portraitHeight = PortraitDB.Height
    local highlightHeight = portraitHeight * 0.25
    highlight:ClearAllPoints()
    highlight:SetPoint("BOTTOMLEFT", portrait, "BOTTOMLEFT", 0, 0)
    highlight:SetPoint("BOTTOMRIGHT", portrait, "BOTTOMRIGHT", 0, 0)
    highlight:SetPoint("TOPLEFT", portrait, "BOTTOMLEFT", 0, highlightHeight)
    highlight:SetPoint("TOPRIGHT", portrait, "BOTTOMRIGHT", 0, highlightHeight)
end

-- Helper function to set up portrait button OnEnter/OnLeave scripts
local function SetupPortraitButtonScripts(portraitButton, unitFrame, hasHighlight)
    if hasHighlight then
        portraitButton:SetScript("OnEnter", function()
            UnitFrame_OnEnter(unitFrame)
            if portraitButton.PortraitHighlight then
                portraitButton.PortraitHighlight:Show()
            end
        end)
        portraitButton:SetScript("OnLeave", function()
            UnitFrame_OnLeave(unitFrame)
            if portraitButton.PortraitHighlight then
                portraitButton.PortraitHighlight:Hide()
            end
        end)
    else
        portraitButton:SetScript("OnEnter", function() UnitFrame_OnEnter(unitFrame) end)
        portraitButton:SetScript("OnLeave", function() UnitFrame_OnLeave(unitFrame) end)
    end
end

-- Helper function to create or update portrait highlight
local function CreateOrUpdatePortraitHighlight(portraitButton, unitFrame, unit, PortraitDB, MouseoverDB)
    if not MouseoverDB or not MouseoverDB.Enabled then
        if portraitButton.PortraitHighlight then
            portraitButton.PortraitHighlight:Hide()
        end
        return
    end
    
    local highlight = portraitButton.PortraitHighlight
    if not highlight then
        highlight = CreatePortraitHighlight(portraitButton, unitFrame, PortraitDB, MouseoverDB)
        SetupPortraitHighlightStyle(highlight, MouseoverDB)
        portraitButton.__owner = unitFrame
    else
        UpdatePortraitHighlightPosition(highlight, unitFrame.Portrait, PortraitDB)
        SetupPortraitHighlightStyle(highlight, MouseoverDB)
    end
end

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
                local PortraitButton = unitFrame.Portrait.PortraitButton
                
                if not PortraitButton then
                    -- Create new portrait button
                    PortraitButton = CreateFrame("Button", UUF:FetchFrameName(unit) .. "_PortraitButton", unitFrame, "SecureUnitButtonTemplate")
                    PortraitButton:SetSize(PortraitDB.Width, PortraitDB.Height)
                    PortraitButton:SetPoint(PortraitDB.Layout[1], unitFrame, PortraitDB.Layout[2], PortraitDB.Layout[3], PortraitDB.Layout[4])
                    PortraitButton:RegisterForClicks("AnyUp")
                    PortraitButton:SetAttribute("unit", unitFrame.unit)
                    PortraitButton:SetFrameLevel(unitFrame.HighLevelContainer:GetFrameLevel() + 1)
                    PortraitButton:EnableMouse(true)
                    PortraitButton.__owner = unitFrame
                    unitFrame.Portrait.PortraitButton = PortraitButton
                else
                    -- Update existing button position and size
                    PortraitButton:ClearAllPoints()
                    PortraitButton:SetSize(PortraitDB.Width, PortraitDB.Height)
                    PortraitButton:SetPoint(PortraitDB.Layout[1], unitFrame, PortraitDB.Layout[2], PortraitDB.Layout[3], PortraitDB.Layout[4])
                    PortraitButton:SetAttribute("unit", unitFrame.unit)
                end
                
                -- Update click attributes
                if PortraitDB.LeftClickTargetOnPortrait then
                    PortraitButton:SetAttribute("*type1", "target")
                else
                    PortraitButton:SetAttribute("*type1", nil)
                end
                
                if PortraitDB.RightClickMenuOnPortrait then
                    PortraitButton:SetAttribute("*type2", "togglemenu")
                else
                    PortraitButton:SetAttribute("*type2", nil)
                end
                
                -- Handle left-click specific features (highlight and tooltip)
                if PortraitDB.LeftClickTargetOnPortrait then
                    local MouseoverDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Mouseover
                    CreateOrUpdatePortraitHighlight(PortraitButton, unitFrame, unit, PortraitDB, MouseoverDB)
                    SetupPortraitButtonScripts(PortraitButton, unitFrame, MouseoverDB and MouseoverDB.Enabled and PortraitButton.PortraitHighlight ~= nil)
                else
                    -- Disable left-click features
                    if PortraitButton.PortraitHighlight then
                        PortraitButton.PortraitHighlight:Hide()
                    end
                    PortraitButton:SetScript("OnEnter", nil)
                    PortraitButton:SetScript("OnLeave", nil)
                    -- Restore hooks to main frame
                    unitFrame:HookScript("OnEnter", UnitFrame_OnEnter)
                    unitFrame:HookScript("OnLeave", UnitFrame_OnLeave)
                end
                
                PortraitButton:Show()
                
                -- Update main frame attributes based on portrait settings
                if PortraitDB.LeftClickTargetOnPortrait then
                    unitFrame:SetAttribute("*type1", nil)
                else
                    unitFrame:SetAttribute("*type1", "target")
                end
                
                if PortraitDB.RightClickMenuOnPortrait then
                    unitFrame:SetAttribute("*type2", nil)
                else
                    unitFrame:SetAttribute("*type2", "togglemenu")
                end
                
                -- Update mouseover indicator to sync tooltip behavior
                UUF:UpdateUnitMouseoverIndicator(unitFrame, unit)
            else
                -- Hide portrait button and restore main frame attributes
                if unitFrame.Portrait.PortraitButton then
                    unitFrame.Portrait.PortraitButton:Hide()
                end
                unitFrame:SetAttribute("*type1", "target")
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