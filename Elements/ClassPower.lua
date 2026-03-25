local _, UUF = ...

local MAX_CLASS_POWER_BARS = 10

local function GetSecondaryPowerBarDB(unit)
    return UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].SecondaryPowerBar
end

local function ApplyClassPowerColourOverride(element, db)
    if db.ColourByType then
        element.UpdateColor = nil
        return
    end

    element.UpdateColor = function(classPowerElement)
        for i = 1, #classPowerElement do
            classPowerElement[i]:SetStatusBarColor(db.Foreground[1], db.Foreground[2], db.Foreground[3], db.Foreground[4] or 1)
        end
    end
end

local function RefreshClassPowerVisibility(element)
    if not element then return end

    local owner = element.__owner
    if not owner then return end

    local unit = owner.unit or "player"
    local visibleSegments = element.__max or 0

    if visibleSegments > 0 and UUF:IsSecondaryPowerElementVisible(element) then
        UUF:UpdateSegmentedSecondaryPowerElementStyle(owner, unit, element)
        UUF:LayoutSegmentedSecondaryPowerElement(owner, unit, element, visibleSegments)
    else
        UUF:HideSegmentedSecondaryPowerElement(element)
    end
end

function UUF:CreateUnitClassPowerBar(unitFrame, unit)
    if unitFrame.__UUFClassPower then return unitFrame.__UUFClassPower end

    local classPowerElement = UUF:CreateSegmentedSecondaryPowerElement(unitFrame, unit, MAX_CLASS_POWER_BARS)
    classPowerElement.PostUpdate = function(element)
        RefreshClassPowerVisibility(element)
    end
    classPowerElement.PostVisibility = function(element)
        RefreshClassPowerVisibility(element)

        local owner = element.__owner
        if owner then
            C_Timer.After(0, function()
                if owner and owner:GetParent() then
                    UUF:RefreshSecondaryPowerLayout(owner, owner.unit or "player")
                end
            end)
        end
    end

    unitFrame.__UUFClassPower = classPowerElement
    return classPowerElement
end

function UUF:DisableUnitClassPowerBar(unitFrame)
    if unitFrame:IsElementEnabled("ClassPower") then
        unitFrame:DisableElement("ClassPower")
    end

    if unitFrame.__UUFClassPower then
        UUF:HideSegmentedSecondaryPowerElement(unitFrame.__UUFClassPower)
    end

    unitFrame.ClassPower = nil
end

function UUF:UpdateUnitClassPowerBar(unitFrame, unit)
    local db = GetSecondaryPowerBarDB(unit)
    local classPowerElement = unitFrame.__UUFClassPower or UUF:CreateUnitClassPowerBar(unitFrame, unit)
    if not classPowerElement then return end

    if not db or not db.Enabled then
        UUF:DisableUnitClassPowerBar(unitFrame)
        return
    end

    unitFrame.ClassPower = classPowerElement
    UUF:UpdateSegmentedSecondaryPowerElementStyle(unitFrame, unit, classPowerElement)
    ApplyClassPowerColourOverride(classPowerElement, db)

    if not unitFrame:IsElementEnabled("ClassPower") then
        unitFrame:EnableElement("ClassPower")
    end

    if classPowerElement.ForceUpdate then
        classPowerElement:ForceUpdate()
    else
        RefreshClassPowerVisibility(classPowerElement)
    end
end
