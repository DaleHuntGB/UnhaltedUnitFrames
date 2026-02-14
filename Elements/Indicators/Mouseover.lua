local _, UUF = ...

function UUF:CreateUnitMouseoverIndicator(unitFrame, unit)
    local MouseoverDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Mouseover

    local MouseoverHighlight = CreateFrame("Frame", nil, unitFrame.Health, "BackdropTemplate")
    MouseoverHighlight:SetPoint("TOPLEFT", unitFrame.Health, "TOPLEFT", 0, 0)
    MouseoverHighlight:SetPoint("BOTTOMRIGHT", unitFrame.Health, "BOTTOMRIGHT", 0, 0)

    if MouseoverDB.Style == "BORDER" then
        MouseoverHighlight:SetBackdrop(UUF.BACKDROP)
        MouseoverHighlight:SetBackdropColor(0,0,0,0)
        MouseoverHighlight:SetBackdropBorderColor(MouseoverDB.Colour[1], MouseoverDB.Colour[2], MouseoverDB.Colour[3], MouseoverDB.HighlightOpacity)
    elseif MouseoverDB.Style == "GRADIENT" then
        MouseoverHighlight:SetBackdrop({
            bgFile = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Gradient.png",
            edgeFile = nil,
            tile = false, tileSize = 0, edgeSize = 0,
            insets = { left = 0, right = 0, top = 0, bottom = 0 },
        })
        MouseoverHighlight:SetBackdropColor(MouseoverDB.Colour[1], MouseoverDB.Colour[2], MouseoverDB.Colour[3], MouseoverDB.HighlightOpacity)
        MouseoverHighlight:SetBackdropBorderColor(0,0,0,0)
    else
        MouseoverHighlight:SetBackdrop(UUF.BACKDROP)
        MouseoverHighlight:SetBackdropColor(MouseoverDB.Colour[1], MouseoverDB.Colour[2], MouseoverDB.Colour[3], MouseoverDB.HighlightOpacity)
        MouseoverHighlight:SetBackdropBorderColor(0,0,0,0)
    end

    MouseoverHighlight:Hide()
    MouseoverHighlight:SetFrameLevel(unitFrame.Health:GetFrameLevel() + 3)
    unitFrame:SetScript("OnEnter", function() 
        local DB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Mouseover 
        local PortraitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Portrait
        -- Don't show tooltip or highlight on main frame if left-click targeting is on portrait
        if not (PortraitDB and PortraitDB.Enabled and PortraitDB.LeftClickTargetOnPortrait) then
            -- Only show tooltip if left-click is NOT on portrait
            UnitFrame_OnEnter(unitFrame)
        end
        -- Show highlight only if enabled and left-click is NOT on portrait
        if DB.Enabled and not (PortraitDB and PortraitDB.Enabled and PortraitDB.LeftClickTargetOnPortrait) then 
            MouseoverHighlight:Show() 
        end 
    end)
    unitFrame:SetScript("OnLeave", function() 
        local DB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Mouseover 
        local PortraitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Portrait
        -- Hide tooltip if left-click is NOT on portrait
        if not (PortraitDB and PortraitDB.Enabled and PortraitDB.LeftClickTargetOnPortrait) then
            UnitFrame_OnLeave(unitFrame)
        end
        -- Hide highlight if enabled
        if DB.Enabled then 
            MouseoverHighlight:Hide() 
        end 
    end)

    return MouseoverHighlight
end

function UUF:UpdateUnitMouseoverIndicator(unitFrame, unit)
    local MouseoverDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Mouseover
    local PortraitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Portrait

    if MouseoverDB.Enabled then
        unitFrame.MouseoverHighlight = unitFrame.MouseoverHighlight or UUF:CreateUnitMouseoverIndicator(unitFrame, unit)

        if MouseoverDB.Style == "BORDER" then
            unitFrame.MouseoverHighlight:SetBackdrop(UUF.BACKDROP)
            unitFrame.MouseoverHighlight:SetBackdropColor(0,0,0,0)
            unitFrame.MouseoverHighlight:SetBackdropBorderColor(MouseoverDB.Colour[1], MouseoverDB.Colour[2], MouseoverDB.Colour[3], MouseoverDB.HighlightOpacity)
        elseif MouseoverDB.Style == "GRADIENT" then
            unitFrame.MouseoverHighlight:SetBackdrop({
                bgFile = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Gradient.png",
                edgeFile = nil,
                tile = false, tileSize = 0, edgeSize = 0,
                insets = { left = 0, right = 0, top = 0, bottom = 0 },
            })
            unitFrame.MouseoverHighlight:SetBackdropColor(MouseoverDB.Colour[1], MouseoverDB.Colour[2], MouseoverDB.Colour[3], MouseoverDB.HighlightOpacity)
            unitFrame.MouseoverHighlight:SetBackdropBorderColor(0,0,0,0)
        else
            unitFrame.MouseoverHighlight:SetBackdrop(UUF.BACKDROP)
            unitFrame.MouseoverHighlight:SetBackdropColor(MouseoverDB.Colour[1], MouseoverDB.Colour[2], MouseoverDB.Colour[3], MouseoverDB.HighlightOpacity)
            unitFrame.MouseoverHighlight:SetBackdropBorderColor(0,0,0,0)
        end

        -- Update OnEnter script to check portrait setting
        unitFrame:SetScript("OnEnter", function() 
            local DB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Mouseover 
            local PortraitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Portrait
            -- Don't show highlight or tooltip on main frame if left-click targeting is on portrait
            if not (PortraitDB and PortraitDB.Enabled and PortraitDB.LeftClickTargetOnPortrait) then
                -- Only show tooltip if left-click is NOT on portrait
                UnitFrame_OnEnter(unitFrame)
            end
            -- Show highlight only if enabled and left-click is NOT on portrait
            if DB.Enabled and not (PortraitDB and PortraitDB.Enabled and PortraitDB.LeftClickTargetOnPortrait) then 
                unitFrame.MouseoverHighlight:Show() 
            end 
        end)
        
        -- Update OnLeave script to check portrait setting
        unitFrame:SetScript("OnLeave", function() 
            local DB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Mouseover 
            local PortraitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Portrait
            -- Hide tooltip if left-click is NOT on portrait
            if not (PortraitDB and PortraitDB.Enabled and PortraitDB.LeftClickTargetOnPortrait) then
                UnitFrame_OnLeave(unitFrame)
            end
            -- Hide highlight if enabled
            if DB.Enabled then 
                unitFrame.MouseoverHighlight:Hide() 
            end 
        end)

    else
        if unitFrame.MouseoverHighlight then
            unitFrame.MouseoverHighlight:Hide()
            unitFrame:SetScript("OnEnter", nil)
            unitFrame:SetScript("OnLeave", nil)
            unitFrame.MouseoverHighlight = nil
        end
    end
end