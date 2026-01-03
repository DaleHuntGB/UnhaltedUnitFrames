local _, UUF = ...

function UUF:CreateUnitHealthBar(unitFrame, unit)
    local FrameDB = UUF.db.profile.Units[unit].Frame
    local HealthBarDB = UUF.db.profile.Units[unit].HealthBar
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
        HealthBar.colorReaction = HealthBarDB.ColourByReaction
        HealthBar.colorTapped = HealthBarDB.ColourWhenTapped

        unitFrame.Health = HealthBar

        unitFrame.Health.PostUpdate = function(_, _, curHP, maxHP)
            local unitHP = unitFrame.HealthBackground
            maxHP = maxHP or 1
            curHP = curHP or 0
            unitHP:SetMinMaxValues(0, maxHP)
            unitHP:SetValue(UnitHealthMissing(unitFrame.unit, true))
        end

        unitFrame.HealthBackground:SetReverseFill(true)
    end
end

function UUF:UpdateUnitHealthBar(unitFrame, unit)
    local FrameDB = UUF.db.profile.Units[unit].Frame
    local HealthBarDB = UUF.db.profile.Units[unit].HealthBar

    if unitFrame then
        unitFrame:ClearAllPoints()
        unitFrame:SetSize(FrameDB.Width, FrameDB.Height)
        local parentFrame = HealthBarDB.AnchorToCooldownViewer and _G["UUF_CDMAnchor"] or UIParent
        unitFrame:SetPoint(FrameDB.Layout[1], parentFrame, FrameDB.Layout[2], FrameDB.Layout[3], FrameDB.Layout[4])
    end

    if unitFrame.Health then
        unitFrame.Health:SetSize(FrameDB.Width - 2, FrameDB.Height - 2)
        unitFrame.Health.colorClass = HealthBarDB.ColourByClass
        unitFrame.Health.colorReaction = HealthBarDB.ColourByReaction
        unitFrame.Health.colorTapped = HealthBarDB.ColourWhenTapped
        unitFrame.Health:SetStatusBarColor(HealthBarDB.Foreground[1], HealthBarDB.Foreground[2], HealthBarDB.Foreground[3], HealthBarDB.ForegroundOpacity)
    end

    if unitFrame.HealthBackground then
        unitFrame.HealthBackground:SetSize(FrameDB.Width - 2, FrameDB.Height - 2)
        unitFrame.HealthBackground:SetStatusBarColor(HealthBarDB.Background[1], HealthBarDB.Background[2], HealthBarDB.Background[3], HealthBarDB.BackgroundOpacity)
    end
    unitFrame.Health:ForceUpdate()
end