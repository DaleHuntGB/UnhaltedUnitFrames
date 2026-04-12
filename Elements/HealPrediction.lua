local _, UUF = ...

local function CreateUnitAbsorbs(unitFrame, unit)
    local AbsorbDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealPrediction.Absorbs
    if not unitFrame.Health then return end

    local AbsorbBar = CreateFrame("StatusBar", UUF:FetchFrameName(unit) .. "_AbsorbBar", unitFrame.Health)
    if AbsorbDB.UseStripedTexture then AbsorbBar:SetStatusBarTexture("Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ThinStripes.png") else AbsorbBar:SetStatusBarTexture(UUF.Media.Foreground) end
    AbsorbBar:SetStatusBarColor(AbsorbDB.Colour[1], AbsorbDB.Colour[2], AbsorbDB.Colour[3], AbsorbDB.Colour[4])
    AbsorbBar:ClearAllPoints()
    local position = AbsorbDB.Position
    local height = AbsorbDB.MatchParentHeight and unitFrame.Health:GetHeight() or AbsorbDB.Height
    AbsorbBar:SetHeight(height)

    if position == "ATTACH" then
        unitFrame.Health:SetClipsChildren(true)
        if unitFrame.Health:GetReverseFill() then
            AbsorbBar:SetPoint("TOPRIGHT", unitFrame.Health:GetStatusBarTexture(), "TOPLEFT", 0, 0)
            AbsorbBar:SetReverseFill(true)
        else
            AbsorbBar:SetPoint("TOPLEFT", unitFrame.Health:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
            AbsorbBar:SetReverseFill(false)
        end
    elseif position == "TOPLEFT" then
        AbsorbBar:SetPoint("TOPLEFT", unitFrame.Health, "TOPLEFT", 0, 0)
        AbsorbBar:SetReverseFill(false)
    elseif position == "TOPRIGHT" then
        AbsorbBar:SetPoint("TOPRIGHT", unitFrame.Health, "TOPRIGHT", 0, 0)
        AbsorbBar:SetReverseFill(true)
    elseif position == "BOTTOMLEFT" then
        AbsorbBar:SetPoint("BOTTOMLEFT", unitFrame.Health, "BOTTOMLEFT", 0, 0)
        AbsorbBar:SetReverseFill(false)
    elseif position == "BOTTOMRIGHT" then
        AbsorbBar:SetPoint("BOTTOMRIGHT", unitFrame.Health, "BOTTOMRIGHT", 0, 0)
        AbsorbBar:SetReverseFill(true)
    elseif position == "LEFT" then
        AbsorbBar:SetPoint("LEFT", unitFrame.Health, "LEFT", 0, 0)
        AbsorbBar:SetReverseFill(false)
    elseif position == "RIGHT" then
        AbsorbBar:SetPoint("RIGHT", unitFrame.Health, "RIGHT", 0, 0)
        AbsorbBar:SetReverseFill(true)
    else
        -- Default to TOPLEFT
        AbsorbBar:SetPoint("TOPLEFT", unitFrame.Health, "TOPLEFT", 0, 0)
        AbsorbBar:SetReverseFill(false)
    end
    AbsorbBar:SetFrameLevel(unitFrame.Health:GetFrameLevel() + 1)
    AbsorbBar:SetMinMaxValues(0, 1)
    AbsorbBar:SetValue(0)
    AbsorbBar:Show()

    return AbsorbBar
end

local function CreateUnitOverDamageAbsorbIndicator(unitFrame, unit)
    -- Parented to HighLevelContainer (not Health) so it is never clipped by Health:SetClipsChildren(true).
    -- Anchored just outside the trailing edge of the health bar frame.
    -- oUF's Update calls SetAlphaFromBoolean(damageAbsorbClamped, 1, 0) each event which calls SetAlpha()
    -- only -- it does NOT call Show(). The texture must therefore never be Hide()d; alpha=0 is used
    -- instead so oUF can make it visible by raising the alpha to 1 when clamped.
    local indicator = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit) .. "_OverDamageAbsorbIndicator", "OVERLAY")
    indicator:SetTexture("Interface\\RaidFrame\\Shield-Overshield")
    indicator:SetBlendMode("ADD")
    indicator:SetWidth(8)
    indicator:SetPoint("TOP", unitFrame.Health, "TOP", 0, 0)
    indicator:SetPoint("BOTTOM", unitFrame.Health, "BOTTOM", 0, 0)
    if unitFrame.Health:GetReverseFill() then
        indicator:SetPoint("RIGHT", unitFrame.Health, "LEFT", 0, 0)
    else
        indicator:SetPoint("LEFT", unitFrame.Health, "RIGHT", 0, 0)
    end
    indicator:SetAlpha(0)
    return indicator
end

local function CreateUnitIncomingHeal(unitFrame, unit)
    local IncomingDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealPrediction.Incoming
    if not unitFrame.Health then return end

    local IncomingHealBar = CreateFrame("StatusBar", UUF:FetchFrameName(unit) .. "_IncomingHealBar", unitFrame.Health)
    IncomingHealBar:SetStatusBarTexture(UUF.Media.Foreground)
    IncomingHealBar:SetStatusBarColor(IncomingDB.Colour[1], IncomingDB.Colour[2], IncomingDB.Colour[3], IncomingDB.Colour[4])
    IncomingHealBar:ClearAllPoints()
    local position = IncomingDB.Position
    local height = IncomingDB.MatchParentHeight and unitFrame.Health:GetHeight() or IncomingDB.Height
    IncomingHealBar:SetHeight(height)

    if position == "ATTACH" then
        unitFrame.Health:SetClipsChildren(true)
        if unitFrame.Health:GetReverseFill() then
            IncomingHealBar:SetPoint("TOPRIGHT", unitFrame.Health:GetStatusBarTexture(), "TOPLEFT", 0, 0)
            IncomingHealBar:SetReverseFill(true)
        else
            IncomingHealBar:SetPoint("TOPLEFT", unitFrame.Health:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
            IncomingHealBar:SetReverseFill(false)
        end
    elseif position == "TOPLEFT" then
        IncomingHealBar:SetPoint("TOPLEFT", unitFrame.Health, "TOPLEFT", 0, 0)
        IncomingHealBar:SetReverseFill(false)
    elseif position == "TOPRIGHT" then
        IncomingHealBar:SetPoint("TOPRIGHT", unitFrame.Health, "TOPRIGHT", 0, 0)
        IncomingHealBar:SetReverseFill(true)
    elseif position == "BOTTOMLEFT" then
        IncomingHealBar:SetPoint("BOTTOMLEFT", unitFrame.Health, "BOTTOMLEFT", 0, 0)
        IncomingHealBar:SetReverseFill(false)
    elseif position == "BOTTOMRIGHT" then
        IncomingHealBar:SetPoint("BOTTOMRIGHT", unitFrame.Health, "BOTTOMRIGHT", 0, 0)
        IncomingHealBar:SetReverseFill(true)
    elseif position == "LEFT" then
        IncomingHealBar:SetPoint("LEFT", unitFrame.Health, "LEFT", 0, 0)
        IncomingHealBar:SetReverseFill(false)
    elseif position == "RIGHT" then
        IncomingHealBar:SetPoint("RIGHT", unitFrame.Health, "RIGHT", 0, 0)
        IncomingHealBar:SetReverseFill(true)
    else
        IncomingHealBar:SetPoint("TOPLEFT", unitFrame.Health, "TOPLEFT", 0, 0)
        IncomingHealBar:SetReverseFill(false)
    end
    IncomingHealBar:SetFrameLevel(unitFrame.Health:GetFrameLevel() + 1)
    IncomingHealBar:Show()

    return IncomingHealBar
end

local function CreateUnitHealAbsorbs(unitFrame, unit)
    local HealAbsorbDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealPrediction.HealAbsorbs
    if not unitFrame.Health then return end

    local HealAbsorbBar = CreateFrame("StatusBar", UUF:FetchFrameName(unit) .. "_HealAbsorbBar", unitFrame.Health)
    if HealAbsorbDB.UseStripedTexture then HealAbsorbBar:SetStatusBarTexture("Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ThinStripes.png") else HealAbsorbBar:SetStatusBarTexture(UUF.Media.Foreground) end
    HealAbsorbBar:SetStatusBarColor(HealAbsorbDB.Colour[1], HealAbsorbDB.Colour[2], HealAbsorbDB.Colour[3], HealAbsorbDB.Colour[4])
    HealAbsorbBar:ClearAllPoints()
    local position = HealAbsorbDB.Position
    local height = HealAbsorbDB.MatchParentHeight and unitFrame.Health:GetHeight() or HealAbsorbDB.Height
    HealAbsorbBar:SetHeight(height)

    if position == "ATTACH" then
        unitFrame.Health:SetClipsChildren(true)
        if unitFrame.Health:GetReverseFill() then
            HealAbsorbBar:SetPoint("TOPRIGHT", unitFrame.Health:GetStatusBarTexture(), "TOPLEFT", 0, 0)
            HealAbsorbBar:SetReverseFill(false)
        else
            HealAbsorbBar:SetPoint("TOPLEFT", unitFrame.Health:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
            HealAbsorbBar:SetReverseFill(true)
        end
    elseif position == "TOPLEFT" then
        HealAbsorbBar:SetPoint("TOPLEFT", unitFrame.Health, "TOPLEFT", 0, 0)
        HealAbsorbBar:SetReverseFill(false)
    elseif position == "TOPRIGHT" then
        HealAbsorbBar:SetPoint("TOPRIGHT", unitFrame.Health, "TOPRIGHT", 0, 0)
        HealAbsorbBar:SetReverseFill(true)
    elseif position == "BOTTOMLEFT" then
        HealAbsorbBar:SetPoint("BOTTOMLEFT", unitFrame.Health, "BOTTOMLEFT", 0, 0)
        HealAbsorbBar:SetReverseFill(false)
    elseif position == "BOTTOMRIGHT" then
        HealAbsorbBar:SetPoint("BOTTOMRIGHT", unitFrame.Health, "BOTTOMRIGHT", 0, 0)
        HealAbsorbBar:SetReverseFill(true)
    elseif position == "LEFT" then
        HealAbsorbBar:SetPoint("LEFT", unitFrame.Health, "LEFT", 0, 0)
        HealAbsorbBar:SetReverseFill(false)
    elseif position == "RIGHT" then
        HealAbsorbBar:SetPoint("RIGHT", unitFrame.Health, "RIGHT", 0, 0)
        HealAbsorbBar:SetReverseFill(true)
    else
        -- Default to TOPLEFT
        HealAbsorbBar:SetPoint("TOPLEFT", unitFrame.Health, "TOPLEFT", 0, 0)
        HealAbsorbBar:SetReverseFill(false)
    end
    HealAbsorbBar:SetFrameLevel(unitFrame.Health:GetFrameLevel() + 1)
    HealAbsorbBar:Show()

    return HealAbsorbBar
end

function UUF:CreateUnitHealPrediction(unitFrame, unit)
    local AbsorbDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealPrediction.Absorbs
    local HealAbsorbDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealPrediction.HealAbsorbs
    local IncomingDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealPrediction.Incoming

    unitFrame.HealthPrediction = {
        damageAbsorb = AbsorbDB.Enabled and CreateUnitAbsorbs(unitFrame, unit),
        damageAbsorbClampMode = 2,
        overDamageAbsorbIndicator = AbsorbDB.Enabled and CreateUnitOverDamageAbsorbIndicator(unitFrame, unit),
        healAbsorb = HealAbsorbDB.Enabled and CreateUnitHealAbsorbs(unitFrame, unit),
        healAbsorbClampMode = 1,
        healAbsorbMode = 1,
        healingAll = IncomingDB.Enabled and CreateUnitIncomingHeal(unitFrame, unit),
        incomingHealClampMode = 1,
    }
end

function UUF:UpdateUnitHealPrediction(unitFrame, unit)
    local AbsorbDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealPrediction.Absorbs
    local HealAbsorbDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealPrediction.HealAbsorbs
    local IncomingDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealPrediction.Incoming

    if unitFrame.HealthPrediction then
        if AbsorbDB.Enabled then
            unitFrame.HealthPrediction.damageAbsorb = unitFrame.HealthPrediction.damageAbsorb or CreateUnitAbsorbs(unitFrame, unit)
            unitFrame.HealthPrediction.damageAbsorbClampMode = 2
            unitFrame.HealthPrediction.damageAbsorb:Show()
            if AbsorbDB.UseStripedTexture then unitFrame.HealthPrediction.damageAbsorb:SetStatusBarTexture("Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ThinStripes.png") else unitFrame.HealthPrediction.damageAbsorb:SetStatusBarTexture(UUF.Media.Foreground) end
            unitFrame.HealthPrediction.damageAbsorb:SetStatusBarColor(AbsorbDB.Colour[1], AbsorbDB.Colour[2], AbsorbDB.Colour[3], AbsorbDB.Colour[4])
            unitFrame.HealthPrediction.damageAbsorb:ClearAllPoints()
            local position = AbsorbDB.Position
            local height = AbsorbDB.MatchParentHeight and unitFrame.Health:GetHeight() or AbsorbDB.Height
            unitFrame.HealthPrediction.damageAbsorb:SetHeight(height)

            -- Create the over-absorb indicator lazily if it does not exist yet, then re-anchor it
            -- in case the health bar orientation has changed since the frame was first created.
            unitFrame.HealthPrediction.overDamageAbsorbIndicator = unitFrame.HealthPrediction.overDamageAbsorbIndicator or CreateUnitOverDamageAbsorbIndicator(unitFrame, unit)
            unitFrame.HealthPrediction.overDamageAbsorbIndicator:ClearAllPoints()
            unitFrame.HealthPrediction.overDamageAbsorbIndicator:SetPoint("TOP", unitFrame.Health, "TOP", 0, 0)
            unitFrame.HealthPrediction.overDamageAbsorbIndicator:SetPoint("BOTTOM", unitFrame.Health, "BOTTOM", 0, 0)
            if unitFrame.Health:GetReverseFill() then
                unitFrame.HealthPrediction.overDamageAbsorbIndicator:SetPoint("RIGHT", unitFrame.Health, "LEFT", 0, 0)
            else
                unitFrame.HealthPrediction.overDamageAbsorbIndicator:SetPoint("LEFT", unitFrame.Health, "RIGHT", 0, 0)
            end

            if position == "ATTACH" then
                unitFrame.Health:SetClipsChildren(true)
                unitFrame.HealthPrediction.damageAbsorb:SetPoint("TOP", unitFrame.Health, "TOP", 0, 0)
                unitFrame.HealthPrediction.damageAbsorb:SetPoint("BOTTOM", unitFrame.Health, "BOTTOM", 0, 0)
                if unitFrame.Health:GetReverseFill() then
                    unitFrame.HealthPrediction.damageAbsorb:SetPoint("RIGHT", unitFrame.Health:GetStatusBarTexture(), "LEFT", 0, 0)
                    unitFrame.HealthPrediction.damageAbsorb:SetReverseFill(true)
                else
                    unitFrame.HealthPrediction.damageAbsorb:SetPoint("LEFT", unitFrame.Health:GetStatusBarTexture(), "RIGHT", 0, 0)
                    unitFrame.HealthPrediction.damageAbsorb:SetReverseFill(false)
                end
            elseif position == "TOPLEFT" then
                unitFrame.HealthPrediction.damageAbsorb:SetPoint("TOPLEFT", unitFrame.Health, "TOPLEFT", 0, 0)
                unitFrame.HealthPrediction.damageAbsorb:SetReverseFill(false)
            elseif position == "TOPRIGHT" then
                unitFrame.HealthPrediction.damageAbsorb:SetPoint("TOPRIGHT", unitFrame.Health, "TOPRIGHT", 0, 0)
                unitFrame.HealthPrediction.damageAbsorb:SetReverseFill(true)
            elseif position == "BOTTOMLEFT" then
                unitFrame.HealthPrediction.damageAbsorb:SetPoint("BOTTOMLEFT", unitFrame.Health, "BOTTOMLEFT", 0, 0)
                unitFrame.HealthPrediction.damageAbsorb:SetReverseFill(false)
            elseif position == "BOTTOMRIGHT" then
                unitFrame.HealthPrediction.damageAbsorb:SetPoint("BOTTOMRIGHT", unitFrame.Health, "BOTTOMRIGHT", 0, 0)
                unitFrame.HealthPrediction.damageAbsorb:SetReverseFill(true)
            elseif position == "LEFT" then
                unitFrame.HealthPrediction.damageAbsorb:SetPoint("LEFT", unitFrame.Health, "LEFT", 0, 0)
                unitFrame.HealthPrediction.damageAbsorb:SetReverseFill(false)
            elseif position == "RIGHT" then
                unitFrame.HealthPrediction.damageAbsorb:SetPoint("RIGHT", unitFrame.Health, "RIGHT", 0, 0)
                unitFrame.HealthPrediction.damageAbsorb:SetReverseFill(true)
            else
                unitFrame.HealthPrediction.damageAbsorb:SetPoint("TOPLEFT", unitFrame.Health, "TOPLEFT", 0, 0)
                unitFrame.HealthPrediction.damageAbsorb:SetReverseFill(false)
            end
            unitFrame.HealthPrediction:ForceUpdate()
        else
            if unitFrame.HealthPrediction.damageAbsorb then
                unitFrame.HealthPrediction.damageAbsorb:Hide()
            end
            if unitFrame.HealthPrediction.overDamageAbsorbIndicator then
                unitFrame.HealthPrediction.overDamageAbsorbIndicator:Hide()
            end
        end
        if HealAbsorbDB.Enabled then
            unitFrame.HealthPrediction.healAbsorb = unitFrame.HealthPrediction.healAbsorb or CreateUnitHealAbsorbs(unitFrame, unit)
            unitFrame.HealthPrediction.healAbsorbClampMode = 1
            unitFrame.HealthPrediction.healAbsorb:Show()
            if HealAbsorbDB.UseStripedTexture then unitFrame.HealthPrediction.healAbsorb:SetStatusBarTexture("Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ThinStripes.png") else unitFrame.HealthPrediction.healAbsorb:SetStatusBarTexture(UUF.Media.Foreground) end
            unitFrame.HealthPrediction.healAbsorb:SetStatusBarColor(HealAbsorbDB.Colour[1], HealAbsorbDB.Colour[2], HealAbsorbDB.Colour[3], HealAbsorbDB.Colour[4])
            unitFrame.HealthPrediction.healAbsorb:ClearAllPoints()
            local position = HealAbsorbDB.Position
            local height = HealAbsorbDB.MatchParentHeight and unitFrame.Health:GetHeight() or HealAbsorbDB.Height
            unitFrame.HealthPrediction.healAbsorb:SetHeight(height)

            if position == "ATTACH" then
                unitFrame.Health:SetClipsChildren(true)
                unitFrame.HealthPrediction.healAbsorb:SetPoint("TOP", unitFrame.Health, "TOP", 0, 0)
                unitFrame.HealthPrediction.healAbsorb:SetPoint("BOTTOM", unitFrame.Health, "BOTTOM", 0, 0)
                if unitFrame.Health:GetReverseFill() then
                    unitFrame.HealthPrediction.healAbsorb:SetPoint("RIGHT", unitFrame.Health:GetStatusBarTexture(), "LEFT", 0, 0)
                    unitFrame.HealthPrediction.healAbsorb:SetReverseFill(false)
                else
                    unitFrame.HealthPrediction.healAbsorb:SetPoint("LEFT", unitFrame.Health:GetStatusBarTexture(), "RIGHT", 0, 0)
                    unitFrame.HealthPrediction.healAbsorb:SetReverseFill(true)
                end
            elseif position == "TOPLEFT" then
                unitFrame.HealthPrediction.healAbsorb:SetPoint("TOPLEFT", unitFrame.Health, "TOPLEFT", 0, 0)
                unitFrame.HealthPrediction.healAbsorb:SetReverseFill(false)
            elseif position == "TOPRIGHT" then
                unitFrame.HealthPrediction.healAbsorb:SetPoint("TOPRIGHT", unitFrame.Health, "TOPRIGHT", 0, 0)
                unitFrame.HealthPrediction.healAbsorb:SetReverseFill(true)
            elseif position == "BOTTOMLEFT" then
                unitFrame.HealthPrediction.healAbsorb:SetPoint("BOTTOMLEFT", unitFrame.Health, "BOTTOMLEFT", 0, 0)
                unitFrame.HealthPrediction.healAbsorb:SetReverseFill(false)
            elseif position == "BOTTOMRIGHT" then
                unitFrame.HealthPrediction.healAbsorb:SetPoint("BOTTOMRIGHT", unitFrame.Health, "BOTTOMRIGHT", 0, 0)
                unitFrame.HealthPrediction.healAbsorb:SetReverseFill(true)
            elseif position == "LEFT" then
                unitFrame.HealthPrediction.healAbsorb:SetPoint("LEFT", unitFrame.Health, "LEFT", 0, 0)
                unitFrame.HealthPrediction.healAbsorb:SetReverseFill(false)
            elseif position == "RIGHT" then
                unitFrame.HealthPrediction.healAbsorb:SetPoint("RIGHT", unitFrame.Health, "RIGHT", 0, 0)
                unitFrame.HealthPrediction.healAbsorb:SetReverseFill(true)
            else
                -- Default to TOPLEFT
                unitFrame.HealthPrediction.healAbsorb:SetPoint("TOPLEFT", unitFrame.Health, "TOPLEFT", 0, 0)
                unitFrame.HealthPrediction.healAbsorb:SetReverseFill(false)
            end
            unitFrame.HealthPrediction:ForceUpdate()
        else
            if unitFrame.HealthPrediction.healAbsorb then
                unitFrame.HealthPrediction.healAbsorb:Hide()
            end
        end
        if IncomingDB.Enabled then
            unitFrame.HealthPrediction.healingAll = unitFrame.HealthPrediction.healingAll or CreateUnitIncomingHeal(unitFrame, unit)
            unitFrame.HealthPrediction.incomingHealClampMode = 1
            unitFrame.HealthPrediction.healingAll:Show()
            unitFrame.HealthPrediction.healingAll:SetStatusBarTexture(UUF.Media.Foreground)
            unitFrame.HealthPrediction.healingAll:SetStatusBarColor(IncomingDB.Colour[1], IncomingDB.Colour[2], IncomingDB.Colour[3], IncomingDB.Colour[4])
            unitFrame.HealthPrediction.healingAll:ClearAllPoints()
            local position = IncomingDB.Position
            local height = IncomingDB.MatchParentHeight and unitFrame.Health:GetHeight() or IncomingDB.Height
            unitFrame.HealthPrediction.healingAll:SetHeight(height)

            if position == "ATTACH" then
                unitFrame.Health:SetClipsChildren(true)
                unitFrame.HealthPrediction.healingAll:SetPoint("TOP", unitFrame.Health, "TOP", 0, 0)
                unitFrame.HealthPrediction.healingAll:SetPoint("BOTTOM", unitFrame.Health, "BOTTOM", 0, 0)
                if unitFrame.Health:GetReverseFill() then
                    unitFrame.HealthPrediction.healingAll:SetPoint("RIGHT", unitFrame.Health:GetStatusBarTexture(), "LEFT", 0, 0)
                    unitFrame.HealthPrediction.healingAll:SetReverseFill(true)
                else
                    unitFrame.HealthPrediction.healingAll:SetPoint("LEFT", unitFrame.Health:GetStatusBarTexture(), "RIGHT", 0, 0)
                    unitFrame.HealthPrediction.healingAll:SetReverseFill(false)
                end
            elseif position == "TOPLEFT" then
                unitFrame.HealthPrediction.healingAll:SetPoint("TOPLEFT", unitFrame.Health, "TOPLEFT", 0, 0)
                unitFrame.HealthPrediction.healingAll:SetReverseFill(false)
            elseif position == "TOPRIGHT" then
                unitFrame.HealthPrediction.healingAll:SetPoint("TOPRIGHT", unitFrame.Health, "TOPRIGHT", 0, 0)
                unitFrame.HealthPrediction.healingAll:SetReverseFill(true)
            elseif position == "BOTTOMLEFT" then
                unitFrame.HealthPrediction.healingAll:SetPoint("BOTTOMLEFT", unitFrame.Health, "BOTTOMLEFT", 0, 0)
                unitFrame.HealthPrediction.healingAll:SetReverseFill(false)
            elseif position == "BOTTOMRIGHT" then
                unitFrame.HealthPrediction.healingAll:SetPoint("BOTTOMRIGHT", unitFrame.Health, "BOTTOMRIGHT", 0, 0)
                unitFrame.HealthPrediction.healingAll:SetReverseFill(true)
            elseif position == "LEFT" then
                unitFrame.HealthPrediction.healingAll:SetPoint("LEFT", unitFrame.Health, "LEFT", 0, 0)
                unitFrame.HealthPrediction.healingAll:SetReverseFill(false)
            elseif position == "RIGHT" then
                unitFrame.HealthPrediction.healingAll:SetPoint("RIGHT", unitFrame.Health, "RIGHT", 0, 0)
                unitFrame.HealthPrediction.healingAll:SetReverseFill(true)
            else
                unitFrame.HealthPrediction.healingAll:SetPoint("TOPLEFT", unitFrame.Health, "TOPLEFT", 0, 0)
                unitFrame.HealthPrediction.healingAll:SetReverseFill(false)
            end
            unitFrame.HealthPrediction:ForceUpdate()
        else
            if unitFrame.HealthPrediction.healingAll then
                unitFrame.HealthPrediction.healingAll:Hide()
            end
        end
    else
        UUF:CreateUnitHealPrediction(unitFrame, unit)
    end
end