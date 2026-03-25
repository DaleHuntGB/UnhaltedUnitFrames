local _, UUF = ...

local RUNE_COUNT = 6

local function GetSecondaryPowerBarDB(unit)
    return UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].SecondaryPowerBar
end

local function ApplyRuneColourOverride(element, db)
    element.colorSpec = db.ColourByType

    if db.ColourByType then
        element.UpdateColor = nil
        return
    end

    element.UpdateColor = function(owner)
        local runesElement = owner.Runes
        if not runesElement then return end

        for i = 1, #runesElement do
            runesElement[i]:SetStatusBarColor(db.Foreground[1], db.Foreground[2], db.Foreground[3], db.Foreground[4] or 1)
        end
    end
end

local function RefreshRuneVisibility(element)
    if not element then return end

    local owner = element.__owner
    if not owner then return end

    local unit = owner.unit or "player"
    local isVisible = UUF:IsSecondaryPowerElementVisible(element)

    if isVisible then
        UUF:UpdateSegmentedSecondaryPowerElementStyle(owner, unit, element)
        UUF:LayoutSegmentedSecondaryPowerElement(owner, unit, element, RUNE_COUNT)
    else
        UUF:HideSegmentedSecondaryPowerElement(element)
    end

    if isVisible ~= element.__UUFWasVisible then
        element.__UUFWasVisible = isVisible
        C_Timer.After(0, function()
            if owner and owner:GetParent() then
                UUF:RefreshSecondaryPowerLayout(owner, unit)
            end
        end)
    end
end

function UUF:CreateUnitRunesBar(unitFrame, unit)
    if unitFrame.__UUFRunes then return unitFrame.__UUFRunes end

    local runeElement = UUF:CreateSegmentedSecondaryPowerElement(unitFrame, unit, RUNE_COUNT)
    runeElement.sortOrder = "asc"
    runeElement.PostUpdate = function(element)
        RefreshRuneVisibility(element)
    end

    unitFrame.__UUFRunes = runeElement
    return runeElement
end

function UUF:DisableUnitRunesBar(unitFrame)
    if unitFrame:IsElementEnabled("Runes") then
        unitFrame:DisableElement("Runes")
    end

    if unitFrame.__UUFRunes then
        unitFrame.__UUFRunes.__UUFWasVisible = false
        UUF:HideSegmentedSecondaryPowerElement(unitFrame.__UUFRunes)
    end

    unitFrame.Runes = nil
end

function UUF:UpdateUnitRunesBar(unitFrame, unit)
    local db = GetSecondaryPowerBarDB(unit)
    local runeElement = unitFrame.__UUFRunes or UUF:CreateUnitRunesBar(unitFrame, unit)
    if not runeElement then return end

    if not db or not db.Enabled then
        UUF:DisableUnitRunesBar(unitFrame)
        return
    end

    unitFrame.Runes = runeElement
    UUF:UpdateSegmentedSecondaryPowerElementStyle(unitFrame, unit, runeElement)
    ApplyRuneColourOverride(runeElement, db)

    if not unitFrame:IsElementEnabled("Runes") then
        unitFrame:EnableElement("Runes")
    end

    if runeElement.ForceUpdate then
        runeElement:ForceUpdate()
    else
        RefreshRuneVisibility(runeElement)
    end
end
