local _, UUF = ...

local function CreateIncomingHeal(unitFrame, unit)
    local IncomingHealDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealPrediction.IncomingHeal
    if not unitFrame.Health then return end

    local IncomingHealBar = CreateFrame("StatusBar", UUF:FetchFrameName(unit) .. "_IncomingHealBar", unitFrame.Health)
    if IncomingHealDB.UseStripedTexture then IncomingHealBar:SetStatusBarTexture("Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ThinStripes.png") else IncomingHealBar:SetStatusBarTexture(UUF.Media.Foreground) end
    IncomingHealBar:SetStatusBarColor(IncomingHealDB.Colour[1], IncomingHealDB.Colour[2], IncomingHealDB.Colour[3], IncomingHealDB.Colour[4])
    IncomingHealBar:ClearAllPoints()
    local position = IncomingHealDB.Position
    local height = IncomingHealDB.MatchParentHeight and unitFrame.Health:GetHeight() or IncomingHealDB.Height
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
        AbsorbBar:SetPoint("TOPLEFT", unitFrame.Health, "TOPLEFT", 0, 0)
        AbsorbBar:SetReverseFill(false)
    end
    AbsorbBar:SetFrameLevel(unitFrame.Health:GetFrameLevel() + 1)
    AbsorbBar:Show()

    return AbsorbBar
end

local function CreateUnitOverAbsorbs(unitFrame, unit)
    local AbsorbDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealPrediction.Absorbs
    if not unitFrame.Health then return end

    local OverAbsorbClip = CreateFrame("Frame", UUF:FetchFrameName(unit) .. "_OverAbsorbClip", unitFrame.Health)
    OverAbsorbClip:SetClipsChildren(true)

    local OverAbsorbBar = CreateFrame("StatusBar", UUF:FetchFrameName(unit) .. "_OverAbsorbBar", OverAbsorbClip)
    if AbsorbDB.UseStripedTexture then OverAbsorbBar:SetStatusBarTexture("Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ThinStripes.png") else OverAbsorbBar:SetStatusBarTexture(UUF.Media.Foreground) end
    OverAbsorbBar:SetStatusBarColor(AbsorbDB.Colour[1], AbsorbDB.Colour[2], AbsorbDB.Colour[3], AbsorbDB.Colour[4])
    OverAbsorbBar.Clip = OverAbsorbClip
    OverAbsorbBar:ClearAllPoints()
    local height = AbsorbDB.MatchParentHeight and unitFrame.Health:GetHeight() or AbsorbDB.Height
    OverAbsorbClip:SetHeight(height)
    OverAbsorbBar:SetHeight(height)
    if unitFrame.Health:GetReverseFill() then
        OverAbsorbClip:SetPoint("TOPRIGHT", unitFrame.Health, "TOPRIGHT", 0, 0)
        OverAbsorbClip:SetPoint("BOTTOMLEFT", unitFrame.Health:GetStatusBarTexture(), "BOTTOMLEFT", 0, 0)
        OverAbsorbBar:SetPoint("TOPLEFT", unitFrame.Health, "TOPLEFT", 0, 0)
        OverAbsorbBar:SetPoint("BOTTOMLEFT", unitFrame.Health, "BOTTOMLEFT", 0, 0)
        OverAbsorbBar:SetReverseFill(false)
    else
        OverAbsorbClip:SetPoint("TOPLEFT", unitFrame.Health, "TOPLEFT", 0, 0)
        OverAbsorbClip:SetPoint("BOTTOMRIGHT", unitFrame.Health:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
        OverAbsorbBar:SetPoint("TOPRIGHT", unitFrame.Health, "TOPRIGHT", 0, 0)
        OverAbsorbBar:SetPoint("BOTTOMRIGHT", unitFrame.Health, "BOTTOMRIGHT", 0, 0)
        OverAbsorbBar:SetReverseFill(true)
    end
    OverAbsorbBar:SetFrameLevel(unitFrame.Health:GetFrameLevel() + 1)
    OverAbsorbBar:Hide()
    OverAbsorbClip:Hide()

    return OverAbsorbBar
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
            HealAbsorbBar:SetReverseFill(true)
        else
            HealAbsorbBar:SetPoint("TOPLEFT", unitFrame.Health:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
            HealAbsorbBar:SetReverseFill(false)
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
        HealAbsorbBar:SetPoint("TOPLEFT", unitFrame.Health, "TOPLEFT", 0, 0)
        HealAbsorbBar:SetReverseFill(false)
    end
    HealAbsorbBar:SetFrameLevel(unitFrame.Health:GetFrameLevel() + 1)
    HealAbsorbBar:Show()

    return HealAbsorbBar
end

local function UpdateUnitOverAbsorbs(unitFrame, unit)
    local AbsorbDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealPrediction.Absorbs
    if not unitFrame.HealthPrediction or not unitFrame.HealthPrediction.damageAbsorb then return end

    if not AbsorbDB.Enabled then
        if unitFrame.HealthPrediction.overDamageAbsorb then
            unitFrame.HealthPrediction.overDamageAbsorb:Hide()
            unitFrame.HealthPrediction.overDamageAbsorb.Clip:Hide()
        end
        unitFrame.HealthPrediction.damageAbsorb:Hide()
        return
    end

    if not AbsorbDB.ShowOverAbsorb or AbsorbDB.Position ~= "ATTACH" then
        if unitFrame.HealthPrediction.overDamageAbsorb then
            unitFrame.HealthPrediction.overDamageAbsorb:Hide()
            unitFrame.HealthPrediction.overDamageAbsorb.Clip:Hide()
        end
        unitFrame.HealthPrediction.damageAbsorb:Show()
        return
    end

    unitFrame.HealthPrediction.overDamageAbsorb = unitFrame.HealthPrediction.overDamageAbsorb or CreateUnitOverAbsorbs(unitFrame, unit)
    local OverAbsorbBar = unitFrame.HealthPrediction.overDamageAbsorb
    if not OverAbsorbBar then return end

    OverAbsorbBar:SetMinMaxValues(unitFrame.HealthPrediction.damageAbsorb:GetMinMaxValues())
    OverAbsorbBar:SetValue(unitFrame.HealthPrediction.damageAbsorb:GetValue())
    OverAbsorbBar:SetWidth(unitFrame.Health:GetWidth())
    OverAbsorbBar.Clip:Show()
    OverAbsorbBar:Show()
    unitFrame.HealthPrediction.damageAbsorb:Show()
end

function UUF:CreateUnitHealPrediction(unitFrame, unit)
    local IncomingHealDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealPrediction.IncomingHeal
    local AbsorbDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealPrediction.Absorbs
    local HealAbsorbDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealPrediction.HealAbsorbs

    unitFrame.HealthPrediction = {
        healingPlayer = IncomingHealDB.Enabled and CreateIncomingHeal(unitFrame, unit),
        damageAbsorb = AbsorbDB.Enabled and CreateUnitAbsorbs(unitFrame, unit),
        damageAbsorbClampMode = 2,
        overDamageAbsorb = AbsorbDB.Enabled and AbsorbDB.ShowOverAbsorb and CreateUnitOverAbsorbs(unitFrame, unit),
        healAbsorb = HealAbsorbDB.Enabled and CreateUnitHealAbsorbs(unitFrame, unit),
        healAbsorbClampMode = 1,
        healAbsorbMode = 1,
        PostUpdate = function(_, updateUnit) UpdateUnitOverAbsorbs(unitFrame, updateUnit) end,
    }
end

function UUF:UpdateUnitHealPrediction(unitFrame, unit)
    local IncomingHealDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealPrediction.IncomingHeal
    local AbsorbDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealPrediction.Absorbs
    local HealAbsorbDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealPrediction.HealAbsorbs

    if unitFrame.HealthPrediction then
        if IncomingHealDB.Enabled then
            unitFrame.HealthPrediction.healingPlayer = unitFrame.HealthPrediction.healingPlayer or CreateIncomingHeal(unitFrame, unit)
            unitFrame.HealthPrediction.healingPlayerClampMode = 2
            unitFrame.HealthPrediction.healingPlayer:Show()
            if IncomingHealDB.UseStripedTexture then unitFrame.HealthPrediction.healingPlayer:SetStatusBarTexture("Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ThinStripes.png") else unitFrame.HealthPrediction.healingPlayer:SetStatusBarTexture(UUF.Media.Foreground) end
            unitFrame.HealthPrediction.healingPlayer:SetStatusBarColor(IncomingHealDB.Colour[1], IncomingHealDB.Colour[2], IncomingHealDB.Colour[3], IncomingHealDB.Colour[4])
            unitFrame.HealthPrediction.healingPlayer:ClearAllPoints()
            local position = IncomingHealDB.Position
            local height = IncomingHealDB.MatchParentHeight and unitFrame.Health:GetHeight() or IncomingHealDB.Height
            unitFrame.HealthPrediction.healingPlayer:SetHeight(height)

            if position == "ATTACH" then
                unitFrame.Health:SetClipsChildren(true)
                unitFrame.HealthPrediction.healingPlayer:SetPoint("TOP", unitFrame.Health, "TOP", 0, 0)
                unitFrame.HealthPrediction.healingPlayer:SetPoint("BOTTOM", unitFrame.Health, "BOTTOM", 0, 0)
                if unitFrame.Health:GetReverseFill() then
                    unitFrame.HealthPrediction.healingPlayer:SetPoint("RIGHT", unitFrame.Health:GetStatusBarTexture(), "LEFT", 0, 0)
                    unitFrame.HealthPrediction.healingPlayer:SetReverseFill(true)
                else
                    unitFrame.HealthPrediction.healingPlayer:SetPoint("LEFT", unitFrame.Health:GetStatusBarTexture(), "RIGHT", 0, 0)
                    unitFrame.HealthPrediction.healingPlayer:SetReverseFill(false)
                end
            elseif position == "TOPLEFT" then
                unitFrame.HealthPrediction.healingPlayer:SetPoint("TOPLEFT", unitFrame.Health, "TOPLEFT", 0, 0)
                unitFrame.HealthPrediction.healingPlayer:SetReverseFill(false)
            elseif position == "TOPRIGHT" then
                unitFrame.HealthPrediction.healingPlayer:SetPoint("TOPRIGHT", unitFrame.Health, "TOPRIGHT", 0, 0)
                unitFrame.HealthPrediction.healingPlayer:SetReverseFill(true)
            elseif position == "BOTTOMLEFT" then
                unitFrame.HealthPrediction.healingPlayer:SetPoint("BOTTOMLEFT", unitFrame.Health, "BOTTOMLEFT", 0, 0)
                unitFrame.HealthPrediction.healingPlayer:SetReverseFill(false)
            elseif position == "BOTTOMRIGHT" then
                unitFrame.HealthPrediction.healingPlayer:SetPoint("BOTTOMRIGHT", unitFrame.Health, "BOTTOMRIGHT", 0, 0)
                unitFrame.HealthPrediction.healingPlayer:SetReverseFill(true)
            elseif position == "LEFT" then
                unitFrame.HealthPrediction.healingPlayer:SetPoint("LEFT", unitFrame.Health, "LEFT", 0, 0)
                unitFrame.HealthPrediction.healingPlayer:SetReverseFill(false)
            elseif position == "RIGHT" then
                unitFrame.HealthPrediction.healingPlayer:SetPoint("RIGHT", unitFrame.Health, "RIGHT", 0, 0)
                unitFrame.HealthPrediction.healingPlayer:SetReverseFill(true)
            else
                unitFrame.HealthPrediction.healingPlayer:SetPoint("TOPLEFT", unitFrame.Health, "TOPLEFT", 0, 0)
                unitFrame.HealthPrediction.healingPlayer:SetReverseFill(false)
            end
            unitFrame.HealthPrediction:ForceUpdate()
        else
            if unitFrame.HealthPrediction.healingPlayer then
                unitFrame.HealthPrediction.healingPlayer:Hide()
            end
        end
        if AbsorbDB.Enabled then
            unitFrame.HealthPrediction.damageAbsorb = unitFrame.HealthPrediction.damageAbsorb or CreateUnitAbsorbs(unitFrame, unit)
            unitFrame.HealthPrediction.damageAbsorbClampMode = 2
            unitFrame.HealthPrediction.PostUpdate = function(_, updateUnit) UpdateUnitOverAbsorbs(unitFrame, updateUnit) end
            unitFrame.HealthPrediction.damageAbsorb:Show()
            if AbsorbDB.UseStripedTexture then unitFrame.HealthPrediction.damageAbsorb:SetStatusBarTexture("Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ThinStripes.png") else unitFrame.HealthPrediction.damageAbsorb:SetStatusBarTexture(UUF.Media.Foreground) end
            unitFrame.HealthPrediction.damageAbsorb:SetStatusBarColor(AbsorbDB.Colour[1], AbsorbDB.Colour[2], AbsorbDB.Colour[3], AbsorbDB.Colour[4])
            unitFrame.HealthPrediction.damageAbsorb:ClearAllPoints()
            local position = AbsorbDB.Position
            local height = AbsorbDB.MatchParentHeight and unitFrame.Health:GetHeight() or AbsorbDB.Height
            unitFrame.HealthPrediction.damageAbsorb:SetHeight(height)

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

            if AbsorbDB.ShowOverAbsorb and position == "ATTACH" then
                unitFrame.HealthPrediction.overDamageAbsorb = unitFrame.HealthPrediction.overDamageAbsorb or CreateUnitOverAbsorbs(unitFrame, unit)
                if unitFrame.HealthPrediction.overDamageAbsorb then
                    if AbsorbDB.UseStripedTexture then unitFrame.HealthPrediction.overDamageAbsorb:SetStatusBarTexture("Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ThinStripes.png") else unitFrame.HealthPrediction.overDamageAbsorb:SetStatusBarTexture(UUF.Media.Foreground) end
                    unitFrame.HealthPrediction.overDamageAbsorb:SetStatusBarColor(AbsorbDB.Colour[1], AbsorbDB.Colour[2], AbsorbDB.Colour[3], AbsorbDB.Colour[4])
                    unitFrame.HealthPrediction.overDamageAbsorb.Clip:ClearAllPoints()
                    unitFrame.HealthPrediction.overDamageAbsorb:ClearAllPoints()
                    unitFrame.HealthPrediction.overDamageAbsorb.Clip:SetHeight(height)
                    unitFrame.HealthPrediction.overDamageAbsorb:SetHeight(height)
                    if unitFrame.Health:GetReverseFill() then
                        unitFrame.HealthPrediction.overDamageAbsorb.Clip:SetPoint("TOPRIGHT", unitFrame.Health, "TOPRIGHT", 0, 0)
                        unitFrame.HealthPrediction.overDamageAbsorb.Clip:SetPoint("BOTTOMLEFT", unitFrame.Health:GetStatusBarTexture(), "BOTTOMLEFT", 0, 0)
                        unitFrame.HealthPrediction.overDamageAbsorb:SetPoint("TOPLEFT", unitFrame.Health, "TOPLEFT", 0, 0)
                        unitFrame.HealthPrediction.overDamageAbsorb:SetPoint("BOTTOMLEFT", unitFrame.Health, "BOTTOMLEFT", 0, 0)
                        unitFrame.HealthPrediction.overDamageAbsorb:SetReverseFill(false)
                    else
                        unitFrame.HealthPrediction.overDamageAbsorb.Clip:SetPoint("TOPLEFT", unitFrame.Health, "TOPLEFT", 0, 0)
                        unitFrame.HealthPrediction.overDamageAbsorb.Clip:SetPoint("BOTTOMRIGHT", unitFrame.Health:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
                        unitFrame.HealthPrediction.overDamageAbsorb:SetPoint("TOPRIGHT", unitFrame.Health, "TOPRIGHT", 0, 0)
                        unitFrame.HealthPrediction.overDamageAbsorb:SetPoint("BOTTOMRIGHT", unitFrame.Health, "BOTTOMRIGHT", 0, 0)
                        unitFrame.HealthPrediction.overDamageAbsorb:SetReverseFill(true)
                    end
                end
            elseif unitFrame.HealthPrediction.overDamageAbsorb then
                unitFrame.HealthPrediction.overDamageAbsorb:Hide()
                unitFrame.HealthPrediction.overDamageAbsorb.Clip:Hide()
            end
            unitFrame.HealthPrediction:ForceUpdate()
        else
            if unitFrame.HealthPrediction.damageAbsorb then
                unitFrame.HealthPrediction.damageAbsorb:Hide()
            end
            if unitFrame.HealthPrediction.overDamageAbsorb then
                unitFrame.HealthPrediction.overDamageAbsorb:Hide()
                unitFrame.HealthPrediction.overDamageAbsorb.Clip:Hide()
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
                    unitFrame.HealthPrediction.healAbsorb:SetReverseFill(true)
                else
                    unitFrame.HealthPrediction.healAbsorb:SetPoint("LEFT", unitFrame.Health:GetStatusBarTexture(), "RIGHT", 0, 0)
                    unitFrame.HealthPrediction.healAbsorb:SetReverseFill(false)
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
                unitFrame.HealthPrediction.healAbsorb:SetPoint("TOPLEFT", unitFrame.Health, "TOPLEFT", 0, 0)
                unitFrame.HealthPrediction.healAbsorb:SetReverseFill(false)
            end
            unitFrame.HealthPrediction:ForceUpdate()
        else
            if unitFrame.HealthPrediction.healAbsorb then
                unitFrame.HealthPrediction.healAbsorb:Hide()
            end
        end
    else
        UUF:CreateUnitHealPrediction(unitFrame, unit)
    end
end
