local _, UUF = ...

local totemPriorities = STANDARD_TOTEM_PRIORITIES
if UnitClassBase("player") == "SHAMAN" then totemPriorities = SHAMAN_TOTEM_PRIORITIES end

function UUF:CreateUnitTotems(unitFrame, unit)
    if unit ~= "player" then return end
    local TotemsDB = UUF.db.profile.Units.player.Indicators.Totems
    if not TotemsDB.Enabled then return end

    local Totems = {}
    for index = 1, #totemPriorities do
        local Totem = CreateFrame("Button", UUF:FetchFrameName(unit, unitFrame) .. "_Totem" .. index, unitFrame, "SecureActionButtonTemplate")
        local xOffset = (index - 1) * (TotemsDB.Size + TotemsDB.Layout[5])
        if TotemsDB.GrowthDirection == "LEFT" then xOffset = -xOffset end
        Totem:SetSize(TotemsDB.Size, TotemsDB.Size)
        Totem:SetPoint(TotemsDB.Layout[1], unitFrame.HighLevelContainer, TotemsDB.Layout[2], TotemsDB.Layout[3] + xOffset, TotemsDB.Layout[4])
        Totem:RegisterForClicks("RightButtonUp", "RightButtonDown")
        Totem:SetAttribute("type2", "destroytotem")
        Totem:SetAttribute("typerelease2", "destroytotem")
        Totem:SetAlpha(0)

        Totem.Border = Totem:CreateTexture(nil, "BACKGROUND")
        Totem.Border:SetAllPoints()
        Totem.Border:SetColorTexture(0, 0, 0, 1)

        Totem.Icon = Totem:CreateTexture(nil, "OVERLAY")
        Totem.Icon:SetPoint("TOPLEFT", Totem, "TOPLEFT", 1, -1)
        Totem.Icon:SetPoint("BOTTOMRIGHT", Totem, "BOTTOMRIGHT", -1, 1)
        Totem.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

        Totem.Cooldown = CreateFrame("Cooldown", nil, Totem, "CooldownFrameTemplate")
        Totem.Cooldown:SetPoint("TOPLEFT", Totem, "TOPLEFT", 1, -1)
        Totem.Cooldown:SetPoint("BOTTOMRIGHT", Totem, "BOTTOMRIGHT", -1, 1)
        Totem.Cooldown:SetSwipeColor(0, 0, 0, 0.8)
        Totem.Cooldown:SetDrawEdge(false)
        Totem.Cooldown:SetDrawSwipe(true)
        Totem.Cooldown:SetHideCountdownNumbers(false)
        Totem.Cooldown:SetReverse(true)
        UUF:ApplyAuraDuration(Totem.Cooldown, TotemsDB.TotemDuration)

        Totems[index] = Totem
    end

    for slot = 1, #totemPriorities do
        Totems[totemPriorities[slot]]:SetAttribute("totem-slot2", slot)
        Totems[totemPriorities[slot]]:SetAttribute("totem-slot", slot)
    end

    Totems.PostUpdate = function(self, slot)
        UUF:ApplyAuraDuration(self[totemPriorities[slot]].Cooldown, UUF.db.profile.Units.player.Indicators.Totems.TotemDuration)
    end

    unitFrame.Totems = Totems
    return Totems
end

function UUF:UpdateUnitTotems(unitFrame, unit)
    if unit ~= "player" then return end
    local TotemsDB = UUF.db.profile.Units.player.Indicators.Totems

    if TotemsDB.Enabled then
        unitFrame.Totems = unitFrame.Totems or UUF:CreateUnitTotems(unitFrame, unit)
        if not unitFrame.Totems then return end

        for index = 1, #unitFrame.Totems do
            local Totem = unitFrame.Totems[index]
            local xOffset = (index - 1) * (TotemsDB.Size + TotemsDB.Layout[5])
            if TotemsDB.GrowthDirection == "LEFT" then xOffset = -xOffset end
            Totem:ClearAllPoints()
            Totem:SetSize(TotemsDB.Size, TotemsDB.Size)
            Totem:SetPoint(TotemsDB.Layout[1], unitFrame.HighLevelContainer, TotemsDB.Layout[2], TotemsDB.Layout[3] + xOffset, TotemsDB.Layout[4])
            UUF:ApplyAuraDuration(Totem.Cooldown, TotemsDB.TotemDuration)
            Totem:Show()
        end

        if not unitFrame:IsElementEnabled("Totems") then unitFrame:EnableElement("Totems") end
        if unitFrame.Totems.ForceUpdate then unitFrame.Totems:ForceUpdate() end
    else
        if not unitFrame.Totems then return end
        if unitFrame:IsElementEnabled("Totems") then unitFrame:DisableElement("Totems") end
        for index = 1, #unitFrame.Totems do
            unitFrame.Totems[index]:Hide()
        end
    end
end
