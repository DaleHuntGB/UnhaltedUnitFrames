local _, UUF = ...
local oUF = UUF.oUF

local function EnsureUnitFrameColors(unitFrame)
    if rawget(unitFrame, "colors") then return end

    unitFrame.colors = setmetatable({}, {__index = oUF.colors})
end

local function GetHealthBarFallbackColor(unit, healthBarDB)
    if unit == "pet" and healthBarDB.ColourByClass then
        local unitClass = select(2, UnitClass("player"))
        local unitColor = unitClass and RAID_CLASS_COLORS[unitClass]
        if unitColor then
            return unitColor.r, unitColor.g, unitColor.b, healthBarDB.ForegroundOpacity
        end
    end

    return healthBarDB.Foreground[1], healthBarDB.Foreground[2], healthBarDB.Foreground[3], healthBarDB.ForegroundOpacity
end

local function ApplyHealthBarColors(unitFrame, unit, healthBarDB)
    local healthBar = unitFrame.Health
    if not healthBar then return end

    local useClassReactionColour = unit ~= "pet" and healthBarDB.ColourByClass
    local useReactionColour = useClassReactionColour and healthBarDB.ColourByReaction ~= false
    local r, g, b, a = GetHealthBarFallbackColor(unit, healthBarDB)

    EnsureUnitFrameColors(unitFrame)
    unitFrame.colors.health = oUF:CreateColor(r, g, b, a or 1)

    healthBar:SetStatusBarColor(r, g, b, a or 1)
    healthBar.colorClass = useClassReactionColour
    healthBar.colorReaction = useReactionColour
    healthBar.colorTapped = healthBarDB.ColourWhenTapped
    healthBar.colorDisconnected = true
    healthBar.colorHealth = true
end

function UUF:CreateUnitHealthBar(unitFrame, unit)
    local FrameDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Frame
    local HealthBarDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealthBar
    local unitContainer = unitFrame.Container

    if not unitFrame.HealthBar then
        if not unitFrame.HealthBackground then
            unitFrame.HealthBackground = CreateFrame("StatusBar", UUF:FetchFrameName(unit) .. "_HealthBackground", unitContainer)
            unitFrame.HealthBackground:SetPoint("TOPLEFT", unitContainer, "TOPLEFT", 1, -1)
            unitFrame.HealthBackground:SetSize(FrameDB.Width - 2, FrameDB.Height - 2)
            unitFrame.HealthBackground:SetStatusBarTexture(UUF.Media.Background)
            unitFrame.HealthBackground:SetFrameLevel(unitContainer:GetFrameLevel() + 1)
            unitFrame.HealthBackground:SetStatusBarColor(HealthBarDB.Background[1], HealthBarDB.Background[2], HealthBarDB.Background[3], HealthBarDB.BackgroundOpacity)
        end

        local HealthBar = CreateFrame("StatusBar", UUF:FetchFrameName(unit) .. "_HealthBar", unitContainer)
        HealthBar:SetPoint("TOPLEFT", unitContainer, "TOPLEFT", 1, -1)
        HealthBar:SetSize(FrameDB.Width - 2, FrameDB.Height - 2)
        HealthBar:SetStatusBarTexture(UUF.Media.Foreground)
        HealthBar:SetFrameLevel(unitContainer:GetFrameLevel() + 2)

        unitFrame.Health = HealthBar
        ApplyHealthBarColors(unitFrame, unit, HealthBarDB)

        unitFrame.Health.PostUpdate = function(_, _, curHP, maxHP)
            local unitHP = unitFrame.HealthBackground
            maxHP = maxHP or 1
            curHP = curHP or 0
            unitHP:SetMinMaxValues(0, maxHP)
            unitHP:SetValue(UnitHealthMissing(unitFrame.unit, true))
            if HealthBarDB.ColourBackgroundByClass then
                local unitToColour = unitFrame.unit ~= "pet" and unitFrame.unit or "player"
                local r, g, b = UUF:GetUnitColour(unitToColour)
                unitFrame.HealthBackground:SetStatusBarColor(r, g, b, HealthBarDB.BackgroundOpacity)
            end
        end

        if HealthBarDB.Inverse then
            unitFrame.Health:SetReverseFill(true)
            unitFrame.HealthBackground:SetReverseFill(false)
        else
            unitFrame.Health:SetReverseFill(false)
            unitFrame.HealthBackground:SetReverseFill(true)
        end

    end
end

function UUF:UpdateUnitHealthBar(unitFrame, unit)
    local normalizedUnit = UUF:GetNormalizedUnit(unit)
    local FrameDB = UUF.db.profile.Units[normalizedUnit].Frame
    local HealthBarDB = UUF.db.profile.Units[normalizedUnit].HealthBar
    local DispelHighlightDB = UUF.db.profile.Units[normalizedUnit].HealthBar.DispelHighlight

    if unitFrame then
        unitFrame:SetSize(FrameDB.Width, FrameDB.Height)
        if normalizedUnit == "party" then
            -- Group headers own the child anchors, so only the size can be adjusted here.
        elseif unit == "player" or unit == "target" then
            unitFrame:ClearAllPoints()
            local parentFrame = UUF.db.profile.Units[normalizedUnit].HealthBar.AnchorToCooldownViewer and _G["UUF_CDMAnchor"] or UIParent
            UUF[unit:upper()]:SetPoint(FrameDB.Layout[1], parentFrame, FrameDB.Layout[2], FrameDB.Layout[3], FrameDB.Layout[4])
            UUF[unit:upper()]:SetSize(FrameDB.Width, FrameDB.Height)
        elseif unit == "targettarget" or unit == "focus" or unit == "focustarget" or unit == "pet" then
            unitFrame:ClearAllPoints()
            local parentFrame = _G[UUF.db.profile.Units[normalizedUnit].Frame.AnchorParent] or UIParent
            UUF[unit:upper()]:SetPoint(FrameDB.Layout[1], parentFrame, FrameDB.Layout[2], FrameDB.Layout[3], FrameDB.Layout[4])
            UUF[unit:upper()]:SetSize(FrameDB.Width, FrameDB.Height)
        end
    end

    if unitFrame.Health then
        unitFrame.Health:SetSize(FrameDB.Width - 2, FrameDB.Height - 2)
        unitFrame.Health:SetStatusBarTexture(UUF.Media.Foreground)
        ApplyHealthBarColors(unitFrame, unit, HealthBarDB)
    end

    if unitFrame.HealthBackground then
        unitFrame.HealthBackground:SetSize(FrameDB.Width - 2, FrameDB.Height - 2)
        unitFrame.HealthBackground:SetStatusBarColor(HealthBarDB.Background[1], HealthBarDB.Background[2], HealthBarDB.Background[3], HealthBarDB.BackgroundOpacity)
        unitFrame.HealthBackground:SetStatusBarTexture(UUF.Media.Background)
    end

    if HealthBarDB.Inverse then
        unitFrame.Health:SetReverseFill(true)
        unitFrame.HealthBackground:SetReverseFill(false)
    else
        unitFrame.Health:SetReverseFill(false)
        unitFrame.HealthBackground:SetReverseFill(true)
    end

    if unitFrame.DispelHighlight then
        UUF:UpdateUnitDispelHighlight(unitFrame, unit)
    end

    unitFrame.Health:ForceUpdate()
end
