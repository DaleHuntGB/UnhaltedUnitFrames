local _, UUF = ...

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
        HealthBar:SetStatusBarColor(HealthBarDB.Foreground[1], HealthBarDB.Foreground[2], HealthBarDB.Foreground[3], HealthBarDB.ForegroundOpacity)
        HealthBar.colorClass = HealthBarDB.ColourByClass
        HealthBar.colorReaction = HealthBarDB.ColourByClass
        HealthBar.colorTapped = HealthBarDB.ColourWhenTapped

        if unit == "pet" and HealthBarDB.ColourByClass then
            HealthBar.colorClass = false
            HealthBar.colorReaction = false
            HealthBar.colorHealth = false
            local unitClass = select(2, UnitClass("player"))
            local unitColor = RAID_CLASS_COLORS[unitClass]
            if unitColor then
                HealthBar:SetStatusBarColor(unitColor.r, unitColor.g, unitColor.b, HealthBarDB.ForegroundOpacity)
            end
        end

        unitFrame.Health = HealthBar

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
    local FrameDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Frame
    local HealthBarDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealthBar
    local DispelHighlightDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealthBar.DispelHighlight

    if unitFrame then
        unitFrame:ClearAllPoints()
        unitFrame:SetSize(FrameDB.Width, FrameDB.Height)
        if unit == "player" or unit == "target" then
            local parentFrame = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealthBar.AnchorToCooldownViewer and _G["UUF_CDMAnchor"] or UIParent
            UUF[unit:upper()]:SetPoint(FrameDB.Layout[1], parentFrame, FrameDB.Layout[2], FrameDB.Layout[3], FrameDB.Layout[4])
            UUF[unit:upper()]:SetSize(FrameDB.Width, FrameDB.Height)
        elseif unit == "targettarget" or unit == "focus" or unit == "focustarget" or unit == "pet" then
            local parentFrame = _G[UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Frame.AnchorParent] or UIParent
            UUF[unit:upper()]:SetPoint(FrameDB.Layout[1], parentFrame, FrameDB.Layout[2], FrameDB.Layout[3], FrameDB.Layout[4])
            UUF[unit:upper()]:SetSize(FrameDB.Width, FrameDB.Height)
        end

        if HealthBarDB.ShowBorder then
            unitFrame.Container:SetBackdropBorderColor(unpack(HealthBarDB.BorderColour))
        else
            unitFrame.Container:SetBackdropBorderColor(0, 0, 0, 0)
        end
    end

    if unitFrame.Health then
        unitFrame.Health:SetSize(FrameDB.Width - 2, FrameDB.Height - 2)
        unitFrame.Health:SetStatusBarColor(HealthBarDB.Foreground[1], HealthBarDB.Foreground[2], HealthBarDB.Foreground[3], HealthBarDB.ForegroundOpacity)
        unitFrame.Health.colorClass = HealthBarDB.ColourByClass
        unitFrame.Health.colorReaction = HealthBarDB.ColourByClass
        unitFrame.Health.colorTapped = HealthBarDB.ColourWhenTapped
        unitFrame.Health:SetStatusBarTexture(UUF.Media.Foreground)
        if unit == "pet" and HealthBarDB.ColourByClass then
            unitFrame.Health.colorClass = false
            unitFrame.Health.colorReaction = false
            unitFrame.Health.colorHealth = false
            local unitClass = select(2, UnitClass("player"))
            local unitColor = RAID_CLASS_COLORS[unitClass]
            if unitColor then
                unitFrame.Health:SetStatusBarColor(unitColor.r, unitColor.g, unitColor.b, HealthBarDB.ForegroundOpacity)
            end
        end
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
