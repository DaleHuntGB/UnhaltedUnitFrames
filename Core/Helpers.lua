local _, UUF = ...

--- Get unit classification safely, guarding against secret values during combat
function UUF:GetSafeUnitClassification(unit)
    local classification = UnitClassification(unit)
    if issecretvalue(classification) then return "normal" end
    return classification or "normal"
end

--- Get unit race safely, guarding against secret values in restricted combat zones
function UUF:GetSafeUnitRace(unit)
    local race, raceEn = UnitRace(unit)
    if issecretvalue(race) then return nil, nil end
    return race, raceEn
end

--- Get unit faction safely, guarding against secret values in restricted instances
function UUF:GetSafeUnitFactionGroup(unit)
    local faction = UnitFactionGroup(unit)
    if issecretvalue(faction) then return nil end
    return faction
end

--- Apply class color to a status bar, with secret-value safety and fallback.
-- Safe for use on any unit, including those with restricted identity.
function UUF:ApplyClassColor(statusBar, unitForClass, opacity, fallbackColor)
    if not statusBar or not unitForClass then return end
    local classToken = select(2, UnitClass(unitForClass))
    if issecretvalue(classToken) then
        if fallbackColor then statusBar:SetStatusBarColor(unpack(fallbackColor)) end
        return
    end
    local unitColor = classToken and RAID_CLASS_COLORS[classToken]
    if unitColor then
        statusBar:SetStatusBarColor(unitColor.r, unitColor.g, unitColor.b, opacity)
    elseif fallbackColor then
        statusBar:SetStatusBarColor(unpack(fallbackColor))
    end
end

--- Apply font and shadow settings to a FontString from config.
-- Safely applies shadow color/offset or clears if shadow is disabled.
function UUF:ApplyFontShadow(fontString, fontDB, shadowDB)
    if not fontString or not fontDB or not shadowDB then return end
    if shadowDB.Enabled then
        fontString:SetShadowColor(shadowDB.Colour[1], shadowDB.Colour[2], shadowDB.Colour[3], shadowDB.Colour[4])
        fontString:SetShadowOffset(shadowDB.XPos, shadowDB.YPos)
    else
        fontString:SetShadowColor(0, 0, 0, 0)
        fontString:SetShadowOffset(0, 0)
    end
end

--- Batch configure duration text for multiple aura buttons with a single deferred callback.
-- Collects buttons needing duration configuration and applies settings in one timer callback.
function UUF:BatchConfigureAuraDurations(buttons, unit)
    if not buttons or #buttons == 0 or not unit then return end
    
    local toConfigureCount = 0
    for _, button in ipairs(buttons) do
        if button and button.Cooldown then
            toConfigureCount = toConfigureCount + 1
        end
    end
    
    if toConfigureCount == 0 then return end
    
    UUF:ScheduleTimer("ConfigureAuraDuration", 0.01, function()
        for _, button in ipairs(buttons) do
            if button and button.Cooldown then
                UUF:ConfigureAuraDuration(button.Cooldown, unit)
            end
        end
    end)
end

--- Configure duration display on an aura cooldown frame.
function UUF:ConfigureAuraDuration(cooldown, unit)
    if not cooldown then return end
    for _, region in ipairs({ cooldown:GetRegions() }) do
        if region:GetObjectType() == "FontString" then
            local UUFDB = UUF.db.profile
            local FontsDB = UUFDB.General.Fonts
            local AurasDB = UUFDB.Units[UUF:GetNormalizedUnit(unit)].Auras
            local AuraDurationDB = AurasDB.AuraDuration
            
            if AuraDurationDB.ScaleByIconSize then
                local iconWidth = cooldown:GetParent():GetWidth()
                local scaleFactor = iconWidth > 0 and iconWidth / 36 or 1
                local fontSize = AuraDurationDB.FontSize * scaleFactor
                if fontSize < 1 then fontSize = 12 end
                region:SetFont(UUF.Media.Font, fontSize, FontsDB.FontFlag)
            else
                region:SetFont(UUF.Media.Font, AuraDurationDB.FontSize, FontsDB.FontFlag)
            end
            
            region:SetTextColor(AuraDurationDB.Colour[1], AuraDurationDB.Colour[2], AuraDurationDB.Colour[3], 1)
            
            UUF:QueueOrRun(function()
                region:ClearAllPoints()
                region:SetPoint(AuraDurationDB.Layout[1], cooldown:GetParent(), AuraDurationDB.Layout[2], AuraDurationDB.Layout[3], AuraDurationDB.Layout[4])
            end)
            
            UUF:ApplyFontShadow(region, FontsDB, FontsDB.Shadow)
            return region
        end
    end
end

--- Style an aura button (buffs or debuffs) with icon, cooldown, stacks, and overlay.
-- If isInitialStyle is true, also creates the border frame.
function UUF:StyleAuraButton(button, unit, auraType, isInitialStyle)
    if not button or not unit or not auraType then return end
    
    local GeneralDB = UUF.db.profile.General
    local AurasDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Auras
    if not AurasDB then return end
    
    local Buffs = AurasDB.Buffs
    local Debuffs = AurasDB.Debuffs
    local configDB = (auraType == "HELPFUL") and Buffs or Debuffs

    -- Icon texcoord
    local auraIcon = button.Icon
    if auraIcon then
        auraIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    end

    -- Border (only on initial style)
    if isInitialStyle then
        local buttonBorder = CreateFrame("Frame", nil, button, "BackdropTemplate")
        UUF:QueueOrRun(function()
            buttonBorder:SetAllPoints()
            buttonBorder:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1, insets = {left = 0, right = 0, top = 0, bottom = 0} })
            buttonBorder:SetBackdropBorderColor(0, 0, 0, 1)
        end)
    end

    -- Cooldown
    local auraCooldown = button.Cooldown
    if auraCooldown then
        auraCooldown:SetDrawEdge(false)
        auraCooldown:SetReverse(true)
        UUF:ConfigureAuraDuration(auraCooldown, unit)
    end

    -- Stacks
    local auraStacks = button.Count
    if auraStacks then
        UUF:QueueOrRun(function()
            auraStacks:ClearAllPoints()
            auraStacks:SetPoint(configDB.Count.Layout[1], button, configDB.Count.Layout[2], configDB.Count.Layout[3], configDB.Count.Layout[4])
        end)
        auraStacks:SetFont(UUF.Media.Font, configDB.Count.FontSize, GeneralDB.Fonts.FontFlag)
        UUF:ApplyFontShadow(auraStacks, GeneralDB.Fonts, GeneralDB.Fonts.Shadow)
        auraStacks:SetTextColor(unpack(configDB.Count.Colour))
    end

    -- Overlay
    local auraOverlay = button.Overlay
    if auraOverlay then
        auraOverlay:SetTexture("Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\AuraOverlay.png")
        UUF:QueueOrRun(function()
            auraOverlay:ClearAllPoints()
            auraOverlay:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
            auraOverlay:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
            auraOverlay:SetTexCoord(0, 1, 0, 1)
        end)
    end
end
