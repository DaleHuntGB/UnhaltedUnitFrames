local _, UUF = ...

local function CreateUnitAbsorbs(unitFrame, unit)
    local AbsorbDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealPrediction.Absorbs
    if not unitFrame.Health then return end

    local AbsorbBar = CreateFrame("StatusBar", UUF:FetchFrameName(unit) .. "_AbsorbBar", unitFrame.Health)
    if AbsorbDB.UseStripedTexture then AbsorbBar:SetStatusBarTexture("Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ThinStripes.png") else AbsorbBar:SetStatusBarTexture(UUF.Media.Foreground) end
    AbsorbBar:SetStatusBarColor(AbsorbDB.Colour[1], AbsorbDB.Colour[2], AbsorbDB.Colour[3], AbsorbDB.Colour[4])
    AbsorbBar:ClearAllPoints()
    if AbsorbDB.Position == "RIGHT" then
        AbsorbBar:SetPoint("TOPRIGHT", unitFrame.Health, "TOPRIGHT", 0, 0)
        if AbsorbDB.MatchParentHeight then
            AbsorbBar:SetHeight(unitFrame.Health:GetHeight())
        else
            AbsorbBar:SetHeight(AbsorbDB.Height)
        end
        AbsorbBar:SetReverseFill(true)
    elseif AbsorbDB.Position == "ATTACH" then
        unitFrame.Health:SetClipsChildren(true)
        if unitFrame.Health:GetReverseFill() then
            AbsorbBar:SetPoint("TOPRIGHT", unitFrame.Health:GetStatusBarTexture(), "TOPLEFT", 0, 0)
            AbsorbBar:SetReverseFill(true)
        else
            AbsorbBar:SetPoint("TOPLEFT", unitFrame.Health:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
            AbsorbBar:SetReverseFill(false)
        end
        AbsorbBar:SetHeight(AbsorbDB.Height)
    else
        AbsorbBar:SetPoint("TOPLEFT", unitFrame.Health, "TOPLEFT", 0, 0)
        if AbsorbDB.MatchParentHeight then
            AbsorbBar:SetHeight(unitFrame.Health:GetHeight())
        else
            AbsorbBar:SetHeight(AbsorbDB.Height)
        end
        AbsorbBar:SetReverseFill(false)
    end
    AbsorbBar:SetFrameLevel(unitFrame.Health:GetFrameLevel() + 1)
    AbsorbBar:Show()

    return AbsorbBar
end

local function CreateUnitHealAbsorbs(unitFrame, unit)
    local HealAbsorbDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealPrediction.HealAbsorbs
    if not unitFrame.Health then return end

    local HealAbsorbBar = CreateFrame("StatusBar", UUF:FetchFrameName(unit) .. "_HealAbsorbBar", unitFrame.Health)
    if HealAbsorbDB.UseStripedTexture then HealAbsorbBar:SetStatusBarTexture("Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ThinStripes.png") else HealAbsorbBar:SetStatusBarTexture(UUF.Media.Foreground) end
    HealAbsorbBar:SetStatusBarColor(HealAbsorbDB.Colour[1], HealAbsorbDB.Colour[2], HealAbsorbDB.Colour[3], HealAbsorbDB.Colour[4])
    HealAbsorbBar:ClearAllPoints()
    if HealAbsorbDB.Position == "RIGHT" then
        HealAbsorbBar:SetPoint("TOPRIGHT", unitFrame.Health, "TOPRIGHT", 0, 0)
        if HealAbsorbDB.MatchParentHeight then
            HealAbsorbBar:SetHeight(unitFrame.Health:GetHeight())
        else
            HealAbsorbBar:SetHeight(HealAbsorbDB.Height)
        end
        HealAbsorbBar:SetReverseFill(true)
    elseif HealAbsorbDB.Position == "ATTACH" then
        unitFrame.Health:SetClipsChildren(true)
        if unitFrame.Health:GetReverseFill() then
            HealAbsorbBar:SetPoint("TOPRIGHT", unitFrame.Health:GetStatusBarTexture(), "TOPLEFT", 0, 0)
            HealAbsorbBar:SetReverseFill(true)
        else
            HealAbsorbBar:SetPoint("TOPLEFT", unitFrame.Health:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
            HealAbsorbBar:SetReverseFill(false)
        end
        HealAbsorbBar:SetHeight(HealAbsorbDB.Height)
    else
        if HealAbsorbDB.MatchParentHeight then
            HealAbsorbBar:SetHeight(unitFrame.Health:GetHeight())
        else
            HealAbsorbBar:SetHeight(HealAbsorbDB.Height)
        end
        HealAbsorbBar:SetReverseFill(false)
    end
    HealAbsorbBar:SetFrameLevel(unitFrame.Health:GetFrameLevel() + 1)
    HealAbsorbBar:Show()

    return HealAbsorbBar
end

function UUF:CreateUnitHealPrediction(unitFrame, unit)
    local AbsorbDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealPrediction.Absorbs
    local HealAbsorbDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealPrediction.HealAbsorbs

    CreateUnitAbsorbs(unitFrame, unit)
    CreateUnitHealAbsorbs(unitFrame, unit)

    unitFrame.HealthPrediction = {
        damageAbsorb = AbsorbDB.Enabled and CreateUnitAbsorbs(unitFrame, unit),
        damageAbsorbClampMode = 2,
        healAbsorb = HealAbsorbDB.Enabled and CreateUnitHealAbsorbs(unitFrame, unit),
        healAbsorbClampMode = 1,
        healAbsorbMode = 1,
    }
end

function UUF:UpdateUnitHealPrediction(unitFrame, unit)
    local AbsorbDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealPrediction.Absorbs
    local HealAbsorbDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealPrediction.HealAbsorbs

    if unitFrame.HealthPrediction then
        if AbsorbDB.Enabled then
            unitFrame.HealthPrediction.damageAbsorb = unitFrame.HealthPrediction.damageAbsorb or CreateUnitAbsorbs(unitFrame, unit)
            unitFrame.HealthPrediction.damageAbsorbClampMode = 2
            unitFrame.HealthPrediction.damageAbsorb:Show()
            if AbsorbDB.UseStripedTexture then unitFrame.HealthPrediction.damageAbsorb:SetStatusBarTexture("Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ThinStripes.png") else unitFrame.HealthPrediction.damageAbsorb:SetStatusBarTexture(UUF.Media.Foreground) end
            unitFrame.HealthPrediction.damageAbsorb:SetStatusBarColor(AbsorbDB.Colour[1], AbsorbDB.Colour[2], AbsorbDB.Colour[3], AbsorbDB.Colour[4])
            unitFrame.HealthPrediction.damageAbsorb:ClearAllPoints()
            if AbsorbDB.Position == "RIGHT" then
                unitFrame.HealthPrediction.damageAbsorb:SetPoint("TOPRIGHT", unitFrame.Health, "TOPRIGHT", 0, 0)
                if AbsorbDB.MatchParentHeight then
                    unitFrame.HealthPrediction.damageAbsorb:SetHeight(unitFrame.Health:GetHeight())
                else
                    unitFrame.HealthPrediction.damageAbsorb:SetHeight(AbsorbDB.Height)
                end
                unitFrame.HealthPrediction.damageAbsorb:SetReverseFill(true)
            elseif AbsorbDB.Position == "ATTACH" then
                unitFrame.Health:SetClipsChildren(true)

                unitFrame.HealthPrediction.damageAbsorb:ClearAllPoints()
                unitFrame.HealthPrediction.damageAbsorb:SetPoint("TOP", unitFrame.Health, "TOP", 0, 0)
                unitFrame.HealthPrediction.damageAbsorb:SetPoint("BOTTOM", unitFrame.Health, "BOTTOM", 0, 0)

                if unitFrame.Health:GetReverseFill() then
                    unitFrame.HealthPrediction.damageAbsorb:SetPoint("RIGHT", unitFrame.Health:GetStatusBarTexture(), "LEFT", 0, 0)
                    unitFrame.HealthPrediction.damageAbsorb:SetReverseFill(true)
                else
                    unitFrame.HealthPrediction.damageAbsorb:SetPoint("LEFT", unitFrame.Health:GetStatusBarTexture(), "RIGHT", 0, 0)
                    unitFrame.HealthPrediction.damageAbsorb:SetReverseFill(false)
                end
            else
                unitFrame.HealthPrediction.damageAbsorb:SetPoint("TOPLEFT", unitFrame.Health, "TOPLEFT", 0, 0)
                if AbsorbDB.MatchParentHeight then
                    unitFrame.HealthPrediction.damageAbsorb:SetHeight(unitFrame.Health:GetHeight())
                else
                    unitFrame.HealthPrediction.damageAbsorb:SetHeight(AbsorbDB.Height)
                end
                unitFrame.HealthPrediction.damageAbsorb:SetReverseFill(false)
            end
            unitFrame.HealthPrediction:ForceUpdate()
        else
            if unitFrame.HealthPrediction.damageAbsorb then
                unitFrame.HealthPrediction.damageAbsorb:Hide()
            end
        end
        if HealAbsorbDB.Enabled then
            unitFrame.HealthPrediction.healAbsorb = unitFrame.HealthPrediction.healAbsorb or CreateUnitHealAbsorbs(unitFrame, unit)
            unitFrame.HealthPrediction.healAbsorbClampMode = 1
            unitFrame.HealthPrediction.healAbsorb:Show()
            if HealAbsorbDB.UseStripedTexture then unitFrame.HealthPrediction.healAbsorb:SetStatusBarTexture("Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ThinStripes.png") else unitFrame.HealthPrediction.healAbsorb:SetStatusBarTexture(UUF.Media.Foreground) end
            unitFrame.HealthPrediction.healAbsorb:SetStatusBarColor(HealAbsorbDB.Colour[1], HealAbsorbDB.Colour[2], HealAbsorbDB.Colour[3], HealAbsorbDB.Colour[4])
            unitFrame.HealthPrediction.healAbsorb:ClearAllPoints()
            if HealAbsorbDB.Position == "RIGHT" then
                unitFrame.HealthPrediction.healAbsorb:SetPoint("TOPRIGHT", unitFrame.Health, "TOPRIGHT", 0, 0)
                if HealAbsorbDB.MatchParentHeight then
                    unitFrame.HealthPrediction.healAbsorb:SetHeight(unitFrame.Health:GetHeight())
                else
                    unitFrame.HealthPrediction.healAbsorb:SetHeight(HealAbsorbDB.Height)
                end
                unitFrame.HealthPrediction.healAbsorb:SetReverseFill(true)
            elseif HealAbsorbDB.Position == "ATTACH" then
                unitFrame.Health:SetClipsChildren(true)

                unitFrame.HealthPrediction.healAbsorb:ClearAllPoints()
                unitFrame.HealthPrediction.healAbsorb:SetPoint("TOP", unitFrame.Health, "TOP", 0, 0)
                unitFrame.HealthPrediction.healAbsorb:SetPoint("BOTTOM", unitFrame.Health, "BOTTOM", 0, 0)

                if unitFrame.Health:GetReverseFill() then
                    unitFrame.HealthPrediction.healAbsorb:SetPoint("RIGHT", unitFrame.Health:GetStatusBarTexture(), "LEFT", 0, 0)
                    unitFrame.HealthPrediction.healAbsorb:SetReverseFill(true)
                else
                    unitFrame.HealthPrediction.healAbsorb:SetPoint("LEFT", unitFrame.Health:GetStatusBarTexture(), "RIGHT", 0, 0)
                    unitFrame.HealthPrediction.healAbsorb:SetReverseFill(false)
                end
            else
                unitFrame.HealthPrediction.healAbsorb:SetPoint("TOPLEFT", unitFrame.Health, "TOPLEFT", 0, 0)
                if HealAbsorbDB.MatchParentHeight then
                    unitFrame.HealthPrediction.healAbsorb:SetHeight(unitFrame.Health:GetHeight())
                else
                    unitFrame.HealthPrediction.healAbsorb:SetHeight(HealAbsorbDB.Height)
                end
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