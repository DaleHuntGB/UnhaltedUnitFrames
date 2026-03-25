local _, UUF = ...

local function GetSecondaryPowerBarDB(unit)
    return UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].SecondaryPowerBar
end

local function HideStaggerSupport(staggerBar)
    if not staggerBar then return end

    if staggerBar.Background then
        staggerBar.Background:Hide()
    end

    if staggerBar.PowerBarBorder then
        staggerBar.PowerBarBorder:Hide()
    end
end

local function LayoutStaggerBar(unitFrame, unit, staggerBar)
    local db = GetSecondaryPowerBarDB(unit)
    if not db or not staggerBar then return end

    local totalWidth = UUF:GetSecondaryPowerBarWidth(unitFrame, unit)
    local anchorPoint, anchorY, isTopAnchored = UUF:GetSecondaryPowerBarAnchor(unitFrame, unit)

    staggerBar:ClearAllPoints()
    staggerBar:SetPoint(anchorPoint, unitFrame.Container, anchorPoint, 1, anchorY)
    staggerBar:SetSize(totalWidth, db.Height)
    staggerBar:SetStatusBarTexture(UUF.Media.Foreground)

    if staggerBar.Background then
        staggerBar.Background:ClearAllPoints()
        staggerBar.Background:SetPoint(anchorPoint, unitFrame.Container, anchorPoint, 1, anchorY)
        staggerBar.Background:SetSize(totalWidth, db.Height)
        staggerBar.Background:SetTexture(UUF.Media.Background)
        staggerBar.Background:SetVertexColor(db.Background[1], db.Background[2], db.Background[3], db.Background[4] or 1)
        staggerBar.Background:Show()
    end

    if staggerBar.PowerBarBorder then
        staggerBar.PowerBarBorder:ClearAllPoints()
        staggerBar.PowerBarBorder:SetTexture("Interface\\Buttons\\WHITE8x8")
        staggerBar.PowerBarBorder:SetVertexColor(0, 0, 0, 1)
        staggerBar.PowerBarBorder:SetHeight(1)
        if isTopAnchored then
            staggerBar.PowerBarBorder:SetPoint("TOPLEFT", unitFrame.Container, "TOPLEFT", 1, -1 - db.Height)
            staggerBar.PowerBarBorder:SetPoint("TOPRIGHT", unitFrame.Container, "TOPLEFT", 1 + totalWidth, -1 - db.Height)
        else
            staggerBar.PowerBarBorder:SetPoint("BOTTOMLEFT", unitFrame.Container, "BOTTOMLEFT", 1, 1 + db.Height)
            staggerBar.PowerBarBorder:SetPoint("BOTTOMRIGHT", unitFrame.Container, "BOTTOMLEFT", 1 + totalWidth, 1 + db.Height)
        end
        staggerBar.PowerBarBorder:Show()
    end
end

local function ApplyStaggerColourOverride(db, staggerBar)
    if db.ColourByType then
        staggerBar.UpdateColor = nil
        return
    end

    staggerBar.UpdateColor = function(owner)
        local bar = owner.Stagger
        if bar then
            bar:SetStatusBarColor(db.Foreground[1], db.Foreground[2], db.Foreground[3], db.Foreground[4] or 1)
        end
    end
end

function UUF:CreateUnitStaggerBar(unitFrame, unit)
    if unitFrame.__UUFStagger then return unitFrame.__UUFStagger end

    local staggerBar = CreateFrame("StatusBar", nil, unitFrame.Container)
    staggerBar:SetMinMaxValues(0, 1)
    staggerBar:SetFrameLevel(unitFrame.Container:GetFrameLevel() + 2)
    staggerBar:Hide()

    staggerBar.Background = unitFrame.Container:CreateTexture(nil, "BACKGROUND")
    staggerBar.Background:Hide()

    staggerBar.PowerBarBorder = unitFrame.Container:CreateTexture(nil, "OVERLAY")
    staggerBar.PowerBarBorder:Hide()

    staggerBar.PostUpdate = function(element)
        local owner = element.__owner
        if owner and element:IsShown() then
            LayoutStaggerBar(owner, owner.unit or unit, element)
        else
            HideStaggerSupport(element)
        end
    end
    staggerBar.PostVisibility = function(element, isVisible)
        local owner = element.__owner
        if owner and isVisible then
            LayoutStaggerBar(owner, owner.unit or unit, element)
        else
            HideStaggerSupport(element)
        end

        if owner then
            C_Timer.After(0, function()
                if owner and owner:GetParent() then
                    UUF:RefreshSecondaryPowerLayout(owner, owner.unit or unit)
                end
            end)
        end
    end

    unitFrame.__UUFStagger = staggerBar
    return staggerBar
end

function UUF:DisableUnitStaggerBar(unitFrame)
    if unitFrame:IsElementEnabled("Stagger") then
        unitFrame:DisableElement("Stagger")
    end

    if unitFrame.__UUFStagger then
        HideStaggerSupport(unitFrame.__UUFStagger)
        unitFrame.__UUFStagger:Hide()
    end

    unitFrame.Stagger = nil
end

function UUF:UpdateUnitStaggerBar(unitFrame, unit)
    local db = GetSecondaryPowerBarDB(unit)
    local staggerBar = unitFrame.__UUFStagger or UUF:CreateUnitStaggerBar(unitFrame, unit)
    if not staggerBar then return end

    if not db or not db.Enabled then
        UUF:DisableUnitStaggerBar(unitFrame)
        return
    end

    unitFrame.Stagger = staggerBar
    staggerBar:SetStatusBarTexture(UUF.Media.Foreground)
    if staggerBar.Background then
        staggerBar.Background:SetTexture(UUF.Media.Background)
        staggerBar.Background:SetVertexColor(db.Background[1], db.Background[2], db.Background[3], db.Background[4] or 1)
    end
    ApplyStaggerColourOverride(db, staggerBar)

    if not unitFrame:IsElementEnabled("Stagger") then
        unitFrame:EnableElement("Stagger")
    end

    if staggerBar.ForceUpdate then
        staggerBar:ForceUpdate()
    elseif staggerBar:IsShown() then
        LayoutStaggerBar(unitFrame, unit, staggerBar)
    else
        HideStaggerSupport(staggerBar)
    end
end
