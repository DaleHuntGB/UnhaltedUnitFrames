local _, UUF = ...

local function ConfigurePredictionBar(predictionBar, unitFrame, db, attachTexture)
    if not predictionBar or not unitFrame or not unitFrame.Health or not db then return end

    if db.UseStripedTexture then
        predictionBar:SetStatusBarTexture("Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ThinStripes.png")
    else
        predictionBar:SetStatusBarTexture(UUF.Media.Foreground)
    end

    predictionBar:SetStatusBarColor(db.Colour[1], db.Colour[2], db.Colour[3], db.Colour[4])
    predictionBar:ClearAllPoints()

    local position = db.Position
    local height = db.MatchParentHeight and unitFrame.Health:GetHeight() or db.Height
    predictionBar:SetHeight(height)

    if position == "ATTACH" then
        unitFrame.Health:SetClipsChildren(true)
        if unitFrame.Health:GetReverseFill() then
            predictionBar:SetPoint("TOPRIGHT", attachTexture, "TOPLEFT", 0, 0)
            predictionBar:SetReverseFill(true)
        else
            predictionBar:SetPoint("TOPLEFT", attachTexture, "TOPRIGHT", 0, 0)
            predictionBar:SetReverseFill(false)
        end
    elseif position == "ATTACH_OVERLAY" then
        -- Anchors to the leading edge of the health fill and fills in the reverse direction,
        -- overlaying the health bar so the shield is visible without extending outside the frame.
        unitFrame.Health:SetClipsChildren(true)
        if unitFrame.Health:GetReverseFill() then
            -- Health fills right-to-left; overlay fills left-to-right from the fill's left (leading) edge.
            predictionBar:SetPoint("TOPLEFT", attachTexture, "TOPLEFT", 0, 0)
            predictionBar:SetReverseFill(false)
        else
            -- Health fills left-to-right; overlay fills right-to-left from the fill's right (leading) edge.
            predictionBar:SetPoint("TOPRIGHT", attachTexture, "TOPRIGHT", 0, 0)
            predictionBar:SetReverseFill(true)
        end
    elseif position == "TOPLEFT" then
        predictionBar:SetPoint("TOPLEFT", unitFrame.Health, "TOPLEFT", 0, 0)
        predictionBar:SetReverseFill(false)
    elseif position == "TOPRIGHT" then
        predictionBar:SetPoint("TOPRIGHT", unitFrame.Health, "TOPRIGHT", 0, 0)
        predictionBar:SetReverseFill(true)
    elseif position == "BOTTOMLEFT" then
        predictionBar:SetPoint("BOTTOMLEFT", unitFrame.Health, "BOTTOMLEFT", 0, 0)
        predictionBar:SetReverseFill(false)
    elseif position == "BOTTOMRIGHT" then
        predictionBar:SetPoint("BOTTOMRIGHT", unitFrame.Health, "BOTTOMRIGHT", 0, 0)
        predictionBar:SetReverseFill(true)
    elseif position == "LEFT" then
        predictionBar:SetPoint("LEFT", unitFrame.Health, "LEFT", 0, 0)
        predictionBar:SetReverseFill(false)
    elseif position == "RIGHT" then
        predictionBar:SetPoint("RIGHT", unitFrame.Health, "RIGHT", 0, 0)
        predictionBar:SetReverseFill(true)
    else
        predictionBar:SetPoint("TOPLEFT", unitFrame.Health, "TOPLEFT", 0, 0)
        predictionBar:SetReverseFill(false)
    end

    predictionBar:SetFrameLevel(unitFrame.Health:GetFrameLevel() + 1)
end

local function CreateUnitIncomingHeals(unitFrame, unit)
    local IncomingHealDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealPrediction.IncomingHeals
    if not unitFrame.Health then return end

    local IncomingHealBar = CreateFrame("StatusBar", UUF:FetchFrameName(unit) .. "_IncomingHealBar", unitFrame.Health)
    ConfigurePredictionBar(IncomingHealBar, unitFrame, IncomingHealDB, unitFrame.Health:GetStatusBarTexture())
    IncomingHealBar:Show()

    return IncomingHealBar
end

local function CreateUnitAbsorbs(unitFrame, unit)
    local AbsorbDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealPrediction.Absorbs
    if not unitFrame.Health then return end

    local AbsorbBar = CreateFrame("StatusBar", UUF:FetchFrameName(unit) .. "_AbsorbBar", unitFrame.Health)
    local attachTexture = unitFrame.Health:GetStatusBarTexture()
    if unitFrame.HealthPrediction and unitFrame.HealthPrediction.healingAll and AbsorbDB.Position == "ATTACH" then
        attachTexture = unitFrame.HealthPrediction.healingAll:GetStatusBarTexture() or attachTexture
    end

    ConfigurePredictionBar(AbsorbBar, unitFrame, AbsorbDB, attachTexture)
    AbsorbBar:Show()

    return AbsorbBar
end

local function CreateUnitHealAbsorbs(unitFrame, unit)
    local HealAbsorbDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealPrediction.HealAbsorbs
    if not unitFrame.Health then return end

    local HealAbsorbBar = CreateFrame("StatusBar", UUF:FetchFrameName(unit) .. "_HealAbsorbBar", unitFrame.Health)
    ConfigurePredictionBar(HealAbsorbBar, unitFrame, HealAbsorbDB, unitFrame.Health:GetStatusBarTexture())
    HealAbsorbBar:Show()

    return HealAbsorbBar
end

function UUF:CreateUnitHealPrediction(unitFrame, unit)
    local IncomingHealDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealPrediction.IncomingHeals
    local AbsorbDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealPrediction.Absorbs
    local HealAbsorbDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealPrediction.HealAbsorbs

    unitFrame.HealthPrediction = unitFrame.HealthPrediction or {
        damageAbsorbClampMode = 2,
        healAbsorbClampMode = 1,
        healAbsorbMode = 1,
        incomingHealOverflow = 1.05,
    }

    unitFrame.HealthPrediction.healingAll = IncomingHealDB.Enabled and CreateUnitIncomingHeals(unitFrame, unit)
    unitFrame.HealthPrediction.damageAbsorb = AbsorbDB.Enabled and CreateUnitAbsorbs(unitFrame, unit)
    unitFrame.HealthPrediction.healAbsorb = HealAbsorbDB.Enabled and CreateUnitHealAbsorbs(unitFrame, unit)
end

function UUF:UpdateUnitHealPrediction(unitFrame, unit)
    local IncomingHealDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealPrediction.IncomingHeals
    local AbsorbDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealPrediction.Absorbs
    local HealAbsorbDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].HealPrediction.HealAbsorbs

    if not unitFrame.HealthPrediction then
        UUF:CreateUnitHealPrediction(unitFrame, unit)
    end

    if unitFrame.HealthPrediction then
        if IncomingHealDB.Enabled then
            unitFrame.HealthPrediction.healingAll = unitFrame.HealthPrediction.healingAll or CreateUnitIncomingHeals(unitFrame, unit)
            ConfigurePredictionBar(unitFrame.HealthPrediction.healingAll, unitFrame, IncomingHealDB, unitFrame.Health:GetStatusBarTexture())
            unitFrame.HealthPrediction.healingAll:Show()
        elseif unitFrame.HealthPrediction.healingAll then
            unitFrame.HealthPrediction.healingAll:Hide()
        end

        if AbsorbDB.Enabled then
            unitFrame.HealthPrediction.damageAbsorb = unitFrame.HealthPrediction.damageAbsorb or CreateUnitAbsorbs(unitFrame, unit)
            unitFrame.HealthPrediction.damageAbsorbClampMode = 2
            unitFrame.HealthPrediction.damageAbsorb:Show()
            local absorbAttachTexture = unitFrame.Health:GetStatusBarTexture()
            if unitFrame.HealthPrediction.healingAll and IncomingHealDB.Enabled and AbsorbDB.Position == "ATTACH" then
                absorbAttachTexture = unitFrame.HealthPrediction.healingAll:GetStatusBarTexture() or absorbAttachTexture
            end
            ConfigurePredictionBar(unitFrame.HealthPrediction.damageAbsorb, unitFrame, AbsorbDB, absorbAttachTexture)
        else
            if unitFrame.HealthPrediction.damageAbsorb then
                unitFrame.HealthPrediction.damageAbsorb:Hide()
            end
        end

        if HealAbsorbDB.Enabled then
            unitFrame.HealthPrediction.healAbsorb = unitFrame.HealthPrediction.healAbsorb or CreateUnitHealAbsorbs(unitFrame, unit)
            unitFrame.HealthPrediction.healAbsorbClampMode = 1
            unitFrame.HealthPrediction.healAbsorb:Show()
            ConfigurePredictionBar(unitFrame.HealthPrediction.healAbsorb, unitFrame, HealAbsorbDB, unitFrame.Health:GetStatusBarTexture())
        else
            if unitFrame.HealthPrediction.healAbsorb then
                unitFrame.HealthPrediction.healAbsorb:Hide()
            end
        end

        if unitFrame.HealthPrediction.ForceUpdate then
            unitFrame.HealthPrediction:ForceUpdate()
        end
    end
end
