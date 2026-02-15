local _, UUF = ...

-- Helper function to check if left-click targeting is on portrait
local function IsLeftClickOnPortrait(unit)
    local PortraitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Portrait
    return PortraitDB and PortraitDB.Enabled and PortraitDB.LeftClickTargetOnPortrait
end

-- Helper function to set up highlight backdrop style
local function SetupMouseoverHighlightStyle(highlight, MouseoverDB)
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

-- Helper function to set up OnEnter/OnLeave scripts for mouseover indicator
local function SetupMouseoverScripts(unitFrame, unit, highlight)
    unitFrame:SetScript("OnEnter", function()
        local DB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Mouseover
        -- Don't show tooltip or highlight on main frame if left-click targeting is on portrait
        if not IsLeftClickOnPortrait(unit) then
            UnitFrame_OnEnter(unitFrame)
        end
        -- Show highlight only if enabled and left-click is NOT on portrait
        if DB.Enabled and not IsLeftClickOnPortrait(unit) then
            highlight:Show()
        end
    end)
    
    unitFrame:SetScript("OnLeave", function()
        local DB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Mouseover
        -- Hide tooltip if left-click is NOT on portrait
        if not IsLeftClickOnPortrait(unit) then
            UnitFrame_OnLeave(unitFrame)
        end
        -- Hide highlight if enabled
        if DB.Enabled then
            highlight:Hide()
        end
    end)
end

function UUF:CreateUnitMouseoverIndicator(unitFrame, unit)
    local MouseoverDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Mouseover

    local MouseoverHighlight = CreateFrame("Frame", nil, unitFrame.Health, "BackdropTemplate")
    MouseoverHighlight:SetPoint("TOPLEFT", unitFrame.Health, "TOPLEFT", 0, 0)
    MouseoverHighlight:SetPoint("BOTTOMRIGHT", unitFrame.Health, "BOTTOMRIGHT", 0, 0)

    SetupMouseoverHighlightStyle(MouseoverHighlight, MouseoverDB)

    MouseoverHighlight:Hide()
    MouseoverHighlight:SetFrameLevel(unitFrame.Health:GetFrameLevel() + 3)
    SetupMouseoverScripts(unitFrame, unit, MouseoverHighlight)

    return MouseoverHighlight
end

function UUF:UpdateUnitMouseoverIndicator(unitFrame, unit)
    local MouseoverDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Mouseover

    if MouseoverDB.Enabled then
        unitFrame.MouseoverHighlight = unitFrame.MouseoverHighlight or UUF:CreateUnitMouseoverIndicator(unitFrame, unit)

        SetupMouseoverHighlightStyle(unitFrame.MouseoverHighlight, MouseoverDB)
        SetupMouseoverScripts(unitFrame, unit, unitFrame.MouseoverHighlight)

    else
        if unitFrame.MouseoverHighlight then
            unitFrame.MouseoverHighlight:Hide()
            unitFrame:SetScript("OnEnter", nil)
            unitFrame:SetScript("OnLeave", nil)
            unitFrame.MouseoverHighlight = nil
        end
    end
end