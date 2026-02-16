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
    unitFrame:HookScript("OnEnter", function() local DB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Mouseover if DB.Enabled then MouseoverHighlight:Show() end end)
    unitFrame:HookScript("OnLeave", function() local DB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Mouseover if DB.Enabled then MouseoverHighlight:Hide() end end)

    return MouseoverHighlight
end

function UUF:UpdateUnitMouseoverIndicator(unitFrame, unit)
    local MouseoverDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Mouseover

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

    else
        if unitFrame.MouseoverHighlight then
            unitFrame.MouseoverHighlight:Hide()
            unitFrame.MouseoverHighlight = nil
        end
    end
end