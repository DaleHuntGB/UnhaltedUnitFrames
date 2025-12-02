local _, UUF = ...
--------------------------------------------------------------
--- Helper Functions
--------------------------------------------------------------

local function ResolveFrameName(unit)
    if not unit then return end
    if unit:match("^boss(%d+)$") then
        local unitID = unit:match("^boss(%d+)$")
        return "UUF_Boss" .. unitID
    end
    return UUF.UnitToFrameName[unit]
end

local function GetNormalizedUnit(unit)
    local normalizedUnit = unit:match("^boss%d+$") and "boss" or unit
    return normalizedUnit
end

local function FetchUnitColour(unit)
    local UUFDB = UUF.db.profile
    local GeneralDB = UUFDB.General
    local normalizedUnit = GetNormalizedUnit(unit)
    local FrameDB = UUFDB[normalizedUnit].Frame
    if FrameDB.ClassColour then
        if unit == "pet" then
            local _, class = UnitClass("player")
            local classColour = RAID_CLASS_COLORS[class]
            if classColour then return classColour.r, classColour.g, classColour.b, FrameDB.FGColour[4] end
        end
        if UnitIsPlayer(unit) then
            local _, class = UnitClass(unit)
            local classColour = RAID_CLASS_COLORS[class]
            if classColour then return classColour.r, classColour.g, classColour.b, FrameDB.FGColour[4] end
        end
    end
    if FrameDB.ReactionColour then
        local reaction = UnitReaction(unit, "player") or 5
        local reactionColour = GeneralDB.CustomColours.Reaction[reaction]
        if reactionColour then return reactionColour[1], reactionColour[2], reactionColour[3], FrameDB.FGColour[4] end
    end
    return FrameDB.FGColour[1], FrameDB.FGColour[2], FrameDB.FGColour[3], FrameDB.FGColour[4]
end

local function FetchPowerBarColour(unit)
    local UUFDB = UUF.db.profile
    local GeneralDB = UUFDB.General
    local normalizedUnit = GetNormalizedUnit(unit)
    local PowerBarDB = UUFDB[normalizedUnit].PowerBar
    if PowerBarDB then
        if PowerBarDB.ColourByType then
            local powerType = UnitPowerType(unit)
            local powerColour = GeneralDB.CustomColours.Power[powerType]
            if powerColour then return GeneralDB.CustomColours.Power[powerType][1], GeneralDB.CustomColours.Power[powerType][2], GeneralDB.CustomColours.Power[powerType][3], GeneralDB.CustomColours.Power[powerType][4] or 1 end
        end
        return PowerBarDB.FGColour[1], PowerBarDB.FGColour[2], PowerBarDB.FGColour[3], PowerBarDB.FGColour[4]
    end
end

local function FetchPowerBarBackgroundColour(unit)
    local UUFDB = UUF.db.profile
    local GeneralDB = UUFDB.General
    local normalizedUnit = GetNormalizedUnit(unit)
    local PowerBarDB = UUFDB[normalizedUnit].PowerBar
    if PowerBarDB then
        if PowerBarDB.ColourBackgroundByType then
            local DarkenFactor = PowerBarDB.DarkenFactor
            local powerType = UnitPowerType(unit)
            local powerColour = GeneralDB.CustomColours.Power[powerType]
            if powerColour then return (GeneralDB.CustomColours.Power[powerType][1] * (1 - DarkenFactor)), (GeneralDB.CustomColours.Power[powerType][2] * (1 - DarkenFactor)), (GeneralDB.CustomColours.Power[powerType][3] * (1 - DarkenFactor)), GeneralDB.CustomColours.Power[powerType][4] end
        end
        return PowerBarDB.BGColour[1], PowerBarDB.BGColour[2], PowerBarDB.BGColour[3], PowerBarDB.BGColour[4]
    end
end

local function ToggleUnitWatch(unitFrame)
    if not UUF.TestMode then
        if UUF.db.profile[GetNormalizedUnit(unitFrame.unit)].Enabled then
            RegisterUnitWatch(unitFrame)
            unitFrame:Show()
        else
            UnregisterUnitWatch(unitFrame)
            unitFrame:Hide()
            return
        end
    end
end

local function UnitIsReal(unit)
    local realUnits = {
        ["player"] = true,
        ["target"] = true,
        ["focus"] = true,
        ["pet"] = true,
        ["boss6"] = true,
        ["boss7"] = true,
        ["boss8"] = true,
        ["boss9"] = true,
        ["boss10"] = true,
    }
    return realUnits[unit] or false
end

--------------------------------------------------------------
--- Event Functions
--------------------------------------------------------------

local function UpdateTags(self, _, unit)
    if unit and unit ~= self.unit then return end
    if not UnitExists(self.unit) then return end

    if self.TagOne then
        self.TagOne:SetText(UUF:EvaluateTagString(self.unit, UUF.db.profile[GetNormalizedUnit(self.unit)].Tags.TagOne.Tag or ""))
    end
    if self.TagTwo then
        self.TagTwo:SetText(UUF:EvaluateTagString(self.unit, UUF.db.profile[GetNormalizedUnit(self.unit)].Tags.TagTwo.Tag or ""))
    end
    if self.TagThree then
        self.TagThree:SetText(UUF:EvaluateTagString(self.unit, UUF.db.profile[GetNormalizedUnit(self.unit)].Tags.TagThree.Tag or ""))
    end
end

local function UpdateUnitHealthBar(self, event, unit)
    if unit and unit ~= self.unit then return end
    if not UnitExists(self.unit) then return end

    local unitHP  = UnitHealth(self.unit)
    local unitMaxHP  = UnitHealthMax(self.unit)
    local unitHPMissing = UnitHealthMissing(self.unit, true)

    -- Update Health Bar Values
    self.HealthBar:SetMinMaxValues(0, unitMaxHP)
    self.HealthBar:SetValue(unitHP)
    self.HealthBG:SetMinMaxValues(0, unitMaxHP)
    self.HealthBG:SetValue(unitHPMissing)
end

local function UpdateUnitPowerBar(self, event, unit)
    if unit and unit ~= self.unit then return end
    if not UnitExists(self.unit) then return end

    local unitPower  = UnitPower(self.unit)
    local unitMaxPower  = UnitPowerMax(self.unit)
    local alternatePower = UnitPower("player", Enum.PowerType.Mana)

    -- Update Power Bar Values
    if self.PowerBar then
        self.PowerBar:SetMinMaxValues(0, unitMaxPower)
        self.PowerBar:SetValue(unitPower)
    end

    if self.PowerBarText then
        local PowerBarDB = UUF.db.profile[GetNormalizedUnit(self.unit)].PowerBar
        if PowerBarDB.Text.ColourByType then
            local r, g, b, a = FetchPowerBarColour(self.unit)
            self.PowerBarText:SetTextColor(r, g, b, a)
        else
            self.PowerBarText:SetTextColor(PowerBarDB.Text.Colour[1], PowerBarDB.Text.Colour[2], PowerBarDB.Text.Colour[3], PowerBarDB.Text.Colour[4])
        end
        self.PowerBarText:SetText(unitPower)
    end

    if self.AlternatePowerBar and unit == "player" then
        self.AlternatePowerBar:SetMinMaxValues(0, UnitPowerMax("player", Enum.PowerType.Mana))
        self.AlternatePowerBar:SetValue(alternatePower)
    end
end

local function UpdateUnitFrameData(self, event, unit)
    if unit and unit ~= self.unit then return end
    if not UnitExists(self.unit) then return end

    local unitMaxHP  = UnitHealthMax(self.unit)
    local absorbAmount = UnitGetTotalAbsorbs(self.unit)

    UpdateUnitHealthBar(self, event, self.unit)
    UpdateUnitPowerBar(self, event, self.unit)

    if event == "PLAYER_SPECIALIZATION_CHANGED" then
        UUF:UpdateUnitFrame(self.unit)
    end

    if event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_FOCUS_CHANGED" then
        -- Update Health Bar Colour
        local r, g, b, a = FetchUnitColour(self.unit)
        self.HealthBar:SetStatusBarColor(r, g, b, a)
    end

    if self.AbsorbBar then
        -- Update Absorbs
        self.AbsorbBar:SetMinMaxValues(0, unitMaxHP)
        self.AbsorbBar:SetValue(absorbAmount)
    end

    -- Update Power Bar Colour
    if self.PowerBar then
        local r, g, b, a = FetchPowerBarColour(self.unit)
        self.PowerBar:SetStatusBarColor(r, g, b, a)
        local rBG, gBG, bBG, aBG = FetchPowerBarBackgroundColour(self.unit)
        self.PowerBarBG:SetStatusBarColor(rBG, gBG, bBG, aBG)
    end

    if event == "RAID_TARGET_UPDATE" or event == "PLAYER_TARGET_CHANGED" then
        if self.RaidTargetMarker and UUF.db.profile[GetNormalizedUnit(self.unit)].Indicators.RaidTargetMarker.Enabled then
            local raidTargetIndex = GetRaidTargetIndex(self.unit)
            if raidTargetIndex then
                self.RaidTargetMarker:SetTexture(UUF:FetchRaidTargetMarkerTexture(raidTargetIndex))
                self.RaidTargetMarker:Show()
            else
                self.RaidTargetMarker:Hide()
            end
        end
    end

    if (event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_ENTERING_WORLD") then
        local inCombat  = UUF.db.profile[GetNormalizedUnit("player")].Indicators.Status.Combat  and UnitAffectingCombat("player")
        local isResting = UUF.db.profile[GetNormalizedUnit("player")].Indicators.Status.Resting and IsResting()
        if self.CombatIndicator then if inCombat then self.CombatIndicator:Show() else self.CombatIndicator:Hide() end end
        if self.RestingIndicator then if isResting and not inCombat then self.RestingIndicator:Show() else self.RestingIndicator:Hide() end end
    end

    if (event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_TARGET_CHANGED") then
        if self.LeaderIndicator then
            local IndicatorsDB = UUF.db.profile[GetNormalizedUnit(self.unit)].Indicators
            if (UnitIsGroupLeader(self.unit) or UnitIsGroupAssistant(self.unit)) and IndicatorsDB.Leader.Enabled then
                self.LeaderIndicator:Show()
            else
                self.LeaderIndicator:Hide()
            end
        end
    end

    -- Update Tags
    UpdateTags(self, nil, self.unit)
end

--------------------------------------------------------------
--- Unit Frame Functions
--------------------------------------------------------------

local function CreateContainer(self, unit)
    if not self.Container then
        self.Container = CreateFrame("Frame", ResolveFrameName(unit) .. "_Container", self, "BackdropTemplate")
        self.Container:SetBackdrop(UUF.BackdropTemplate)
        self.Container:SetBackdropColor(0, 0, 0, 0)
        self.Container:SetBackdropBorderColor(0, 0, 0, 1)
        self.Container:SetAllPoints(self)
        self.Container:SetFrameLevel(self:GetFrameLevel() + 1)
    end
end

local function CreateHealthBar(self, unit)
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local FrameDB = UUFDB[normalizedUnit].Frame
    local unitContainer = self.Container

    if not self.HealthBG then
        self.HealthBG = CreateFrame("StatusBar", ResolveFrameName(unit).."_HealthBG", self.Container)
        self.HealthBG:SetPoint("TOPLEFT", unitContainer, "TOPLEFT", 1, -1)
        self.HealthBG:SetSize(FrameDB.Width - 2, FrameDB.Height - 2)
        self.HealthBG:SetStatusBarTexture(UUF.Media.BackgroundTexture)
        self.HealthBG:SetStatusBarColor(unpack(FrameDB.BGColour))
        if FrameDB.InverseHealthBar then
            self.HealthBG:SetReverseFill(false)
        else
            self.HealthBG:SetReverseFill(true)
        end
    end

    if not self.HealthBar then
        self.HealthBar = CreateFrame("StatusBar", ResolveFrameName(unit).."_HealthBar", self.Container)
        self.HealthBar:SetPoint("TOPLEFT", unitContainer, "TOPLEFT", 1, -1)
        self.HealthBar:SetSize(FrameDB.Width - 2, FrameDB.Height - 2)
        self.HealthBar:SetStatusBarTexture(UUF.Media.ForegroundTexture)
        self.HealthBar:SetStatusBarColor(FetchUnitColour(unit))
        self.HealthBar.unit = unit
        if FrameDB.InverseHealthBar then
            self.HealthBar:SetReverseFill(true)
        else
            self.HealthBar:SetReverseFill(false)
        end
    end

    if not self.HighLevelContainer then
        self.HighLevelContainer = CreateFrame("Frame", ResolveFrameName(unit) .. "_HighLevelContainer", unitContainer)
        self.HighLevelContainer:SetSize(self:GetWidth(), self:GetHeight())
        self.HighLevelContainer:SetAllPoints(self)
        self.HighLevelContainer:SetFrameLevel(999)
    end

    -- Global Events
    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
    self:RegisterEvent("PLAYER_FOCUS_CHANGED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    self:RegisterEvent("RAID_TARGET_UPDATE")
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    -- Unit Events
    self:RegisterUnitEvent("UNIT_HEALTH", UnitIsReal(unit) and unit)
    self:RegisterUnitEvent("UNIT_MAXHEALTH", UnitIsReal(unit) and unit)
    self:RegisterUnitEvent("UNIT_NAME_UPDATE", UnitIsReal(unit) and unit)
    -- Update
    self:SetScript("OnEvent", UpdateUnitFrameData)
end

local function UpdateHealthBar(self, unit)
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local FrameDB = UUFDB[normalizedUnit].Frame
    local unitContainer = self.Container

    if self.HealthBG then
        self.HealthBG:ClearAllPoints()
        self.HealthBG:SetPoint("TOPLEFT", unitContainer, "TOPLEFT", 1, -1)
        self.HealthBG:SetStatusBarColor(FrameDB.BGColour[1], FrameDB.BGColour[2], FrameDB.BGColour[3], FrameDB.BGColour[4])
        self.HealthBG:SetStatusBarTexture(UUF.Media.BackgroundTexture)
        self.HealthBG:SetSize(FrameDB.Width - 2, FrameDB.Height - 2)
        if FrameDB.InverseHealthBar then
            self.HealthBG:SetReverseFill(false)
        else
            self.HealthBG:SetReverseFill(true)
        end
    end

    if self.HealthBar then
        local r, g, b, a = FetchUnitColour(unit)
        self.HealthBar:ClearAllPoints()
        self.HealthBar:SetPoint("TOPLEFT", unitContainer, "TOPLEFT", 1, -1)
        self.HealthBar:SetStatusBarColor(r, g, b, a)
        self.HealthBar:SetStatusBarTexture(UUF.Media.ForegroundTexture)
        self.HealthBar:SetSize(FrameDB.Width - 2, FrameDB.Height - 2)
        if FrameDB.InverseHealthBar then
            self.HealthBar:SetReverseFill(true)
        else
            self.HealthBar:SetReverseFill(false)
        end
    end

    if self.HighLevelContainer then
        self.HighLevelContainer:ClearAllPoints()
        self.HighLevelContainer:SetAllPoints(self)
        self.HighLevelContainer:SetSize(self:GetWidth(), self:GetHeight())
    end

    if UUFDB[normalizedUnit].Enabled then
        -- Global Events
        self:RegisterEvent("PLAYER_LOGIN")
        self:RegisterEvent("PLAYER_ENTERING_WORLD")
        self:RegisterEvent("PLAYER_TARGET_CHANGED")
        -- Unit Events
        self:RegisterUnitEvent("UNIT_HEALTH", UnitIsReal(unit) and unit)
        self:RegisterUnitEvent("UNIT_MAXHEALTH", UnitIsReal(unit) and unit)
    else
        -- Global Events
        self:UnregisterEvent("PLAYER_LOGIN")
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        self:UnregisterEvent("PLAYER_TARGET_CHANGED")
        -- Unit Events
        self:UnregisterEvent("UNIT_HEALTH", UnitIsReal(unit) and unit)
        self:UnregisterEvent("UNIT_MAXHEALTH", UnitIsReal(unit) and unit)
    end
end

local function CreateAbsorbBar(self, unit)
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local HealPredictionDB = UUFDB[normalizedUnit].HealPrediction
    local unitContainer = self.Container

    if not self.AbsorbBar then
        self.AbsorbBar = CreateFrame("StatusBar", ResolveFrameName(unit).."_AbsorbBar", unitContainer)
        self.AbsorbBar:SetFrameLevel(self.HealthBar:GetFrameLevel() + 1)
        local isRight = HealPredictionDB.Absorbs.GrowthDirection == "RIGHT"
        self.AbsorbBar:SetReverseFill(not isRight)
        if HealPredictionDB.Absorbs.GrowthDirection == "RIGHT" then
            self.AbsorbBar:SetPoint("TOPLEFT", self.HealthBar, "TOPLEFT", 0, 0)
            self.AbsorbBar:SetPoint("BOTTOMRIGHT", self.HealthBar, "BOTTOMRIGHT", 0, 0)
        else
            self.AbsorbBar:SetPoint("TOPRIGHT", self.HealthBar, "TOPRIGHT", 0, 0)
            self.AbsorbBar:SetPoint("BOTTOMLEFT", self.HealthBar, "BOTTOMLEFT", 0, 0)
        end
        self.AbsorbBar:SetStatusBarTexture(UUF.Media.ForegroundTexture)
        self.AbsorbBar:SetStatusBarColor(HealPredictionDB.Absorbs.Colour[1], HealPredictionDB.Absorbs.Colour[2], HealPredictionDB.Absorbs.Colour[3], HealPredictionDB.Absorbs.Colour[4])
        self.AbsorbBar.unit = unit
    end
    if HealPredictionDB.Absorbs.Enabled then
        self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
    end
end

local function UpdateAbsorbBar(self, unit)
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local HealPredictionDB = UUFDB[normalizedUnit].HealPrediction

    if self.AbsorbBar then
        local isRight = HealPredictionDB.Absorbs.GrowthDirection == "RIGHT"
        self.AbsorbBar:SetReverseFill(not isRight)
        if HealPredictionDB.Absorbs.GrowthDirection == "RIGHT" then
            self.AbsorbBar:ClearAllPoints()
            self.AbsorbBar:SetPoint("TOPLEFT", self.HealthBar, "TOPLEFT", 0, 0)
            self.AbsorbBar:SetPoint("BOTTOMRIGHT", self.HealthBar, "BOTTOMRIGHT", 0, 0)
        else
            self.AbsorbBar:ClearAllPoints()
            self.AbsorbBar:SetPoint("TOPRIGHT", self.HealthBar, "TOPRIGHT", 0, 0)
            self.AbsorbBar:SetPoint("BOTTOMLEFT", self.HealthBar, "BOTTOMLEFT", 0, 0)
        end
        self.AbsorbBar:SetStatusBarTexture(UUF.Media.ForegroundTexture)
        self.AbsorbBar:SetStatusBarColor(HealPredictionDB.Absorbs.Colour[1], HealPredictionDB.Absorbs.Colour[2], HealPredictionDB.Absorbs.Colour[3], HealPredictionDB.Absorbs.Colour[4])
    end
    if HealPredictionDB.Absorbs.Enabled then
        self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
    else
        self:UnregisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
        self.AbsorbBar:Hide()
    end
end

local function CreatePowerBar(self, unit)
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local FrameDB = UUFDB[normalizedUnit].Frame
    local PowerBarDB = UUFDB[normalizedUnit].PowerBar
    local unitContainer = self.Container

    if PowerBarDB then
        if not self.PowerBarBG then
            self.PowerBarBG = CreateFrame("StatusBar", ResolveFrameName(unit).."_PowerBarBG", unitContainer)
            if PowerBarDB.Alignment == "TOP" then
                self.PowerBarBG:SetPoint("TOPLEFT", unitContainer, "TOPLEFT", 1, -1)
            else
                self.PowerBarBG:SetPoint("BOTTOMLEFT", unitContainer, "BOTTOMLEFT", 1, 1)
            end
            self.PowerBarBG:SetSize(FrameDB.Width - 2, PowerBarDB.Height)
            self.PowerBarBG:SetStatusBarTexture(UUF.Media.BackgroundTexture)
            self.PowerBarBG:SetStatusBarColor(PowerBarDB.BGColour[1], PowerBarDB.BGColour[2], PowerBarDB.BGColour[3], PowerBarDB.BGColour[4])
        end

        if not self.PowerBar then
            self.PowerBar = CreateFrame("StatusBar", ResolveFrameName(unit).."_PowerBar", unitContainer)
            if PowerBarDB.Alignment == "TOP" then
                self.PowerBar:SetPoint("TOPLEFT", unitContainer, "TOPLEFT", 1, -1)
            else
                self.PowerBar:SetPoint("BOTTOMLEFT", unitContainer, "BOTTOMLEFT", 1, 1)
            end
            self.PowerBar:SetSize(FrameDB.Width - 2, PowerBarDB.Height)
            self.PowerBar:SetStatusBarTexture(UUF.Media.ForegroundTexture)
            self.PowerBar:SetStatusBarColor(PowerBarDB.FGColour[1], PowerBarDB.FGColour[2], PowerBarDB.FGColour[3], PowerBarDB.FGColour[4])
            self.PowerBar:SetFrameLevel(unitContainer:GetFrameLevel() + 2)
            if PowerBarDB.InverseGrowth then
                self.PowerBar:SetReverseFill(true)
            else
                self.PowerBar:SetReverseFill(false)
            end
            self.PowerBar.unit = unit
        end

        if not self.PowerBarBorder then
            self.PowerBarBorder = self.PowerBar:CreateTexture(nil, "OVERLAY")
            self.PowerBarBorder:SetHeight(1)
            self.PowerBarBorder:SetTexture("Interface\\Buttons\\WHITE8x8")
            self.PowerBarBorder:SetVertexColor(0,0,0,1)
        end

        if not self.PowerBarText then
            self.PowerBarText = self.PowerBar:CreateFontString(ResolveFrameName(unit).."_".."PowerBarText", "OVERLAY")
            self.PowerBarText:SetFont(UUF.Media.Font, PowerBarDB.Text.FontSize, UUFDB.General.FontFlag)
            local anchorParent = PowerBarDB.Text.AnchorParent == "POWER" and self.PowerBar or self.Container
            self.PowerBarText:SetPoint(PowerBarDB.Text.AnchorFrom, anchorParent, PowerBarDB.Text.AnchorTo, PowerBarDB.Text.OffsetX, PowerBarDB.Text.OffsetY)
            if PowerBarDB.Text.ColourByType then
                local r, g, b, a = FetchPowerBarColour(unit)
                self.PowerBarText:SetTextColor(r, g, b, a)
            else
                self.PowerBarText:SetTextColor(PowerBarDB.Text.Colour[1], PowerBarDB.Text.Colour[2], PowerBarDB.Text.Colour[3], PowerBarDB.Text.Colour[4])
            end
            self.PowerBarText:SetJustifyH(UUF:SetJustification(PowerBarDB.Text.AnchorFrom))
            self.PowerBarText:SetShadowOffset(UUFDB.General.FontShadows.OffsetX, UUFDB.General.FontShadows.OffsetY)
            self.PowerBarText:SetShadowColor(UUFDB.General.FontShadows.Colour[1], UUFDB.General.FontShadows.Colour[2], UUFDB.General.FontShadows.Colour[3], UUFDB.General.FontShadows.Colour[4])
        end

        if PowerBarDB.Enabled then
            self:RegisterUnitEvent("UNIT_POWER_UPDATE", UnitIsReal(unit) and unit)
            self:RegisterUnitEvent("UNIT_MAXPOWER", UnitIsReal(unit) and unit)
            if PowerBarDB.Alignment == "TOP" then
                self.HealthBar:ClearAllPoints()
                self.HealthBG:ClearAllPoints()
                self.HealthBar:SetPoint("BOTTOMLEFT", self.Container, "BOTTOMLEFT", 1, 1)
                self.HealthBG:SetPoint("BOTTOMLEFT", self.Container, "BOTTOMLEFT", 1, 1)
                self.HealthBG:SetHeight(UUFDB[normalizedUnit].Frame.Height - (self.PowerBar:GetHeight() + 3))
                self.HealthBar:SetHeight(UUFDB[normalizedUnit].Frame.Height - (self.PowerBar:GetHeight() + 3))
                self.PowerBarBorder:ClearAllPoints()
                self.PowerBarBorder:SetPoint("BOTTOMLEFT", self.PowerBar, "BOTTOMLEFT", 0, -1)
                self.PowerBarBorder:SetPoint("BOTTOMRIGHT", self.PowerBar, "BOTTOMRIGHT", 0, -1)
            else
                self.HealthBar:ClearAllPoints()
                self.HealthBG:ClearAllPoints()
                self.HealthBar:SetPoint("TOPLEFT", self.Container, "TOPLEFT", 1, -1)
                self.HealthBG:SetPoint("TOPLEFT", self.Container, "TOPLEFT", 1, -1)
                self.HealthBG:SetHeight(UUFDB[normalizedUnit].Frame.Height - (self.PowerBar:GetHeight() + 3))
                self.HealthBar:SetHeight(UUFDB[normalizedUnit].Frame.Height - (self.PowerBar:GetHeight() + 3))
                self.PowerBarBorder:ClearAllPoints()
                self.PowerBarBorder:SetPoint("TOPLEFT", self.PowerBar, "TOPLEFT", 0, 1)
                self.PowerBarBorder:SetPoint("TOPRIGHT", self.PowerBar, "TOPRIGHT", 0, 1)
            end
            self.PowerBar:Show()
            self.PowerBarBG:Show()
            self.PowerBarBorder:Show()
            self.PowerBarText:Show()
        else
            self.PowerBar:Hide()
            self.PowerBarBG:Hide()
            self.PowerBarBorder:Hide()
            self.PowerBarText:Hide()
        end
        if PowerBarDB.Text.Enabled then
            self.PowerBarText:Show()
        else
            self.PowerBarText:Hide()
        end
    end
end

local function UpdatePowerBar(self, unit)
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local FrameDB = UUFDB[normalizedUnit].Frame
    local PowerBarDB = UUFDB[normalizedUnit].PowerBar
    local unitContainer = self.Container

    if PowerBarDB then
        if self.PowerBarBG then
            self.PowerBarBG:ClearAllPoints()
            if PowerBarDB.Alignment == "TOP" then
                self.PowerBarBG:SetPoint("TOPLEFT", unitContainer, "TOPLEFT", 1, -1)
            else
                self.PowerBarBG:SetPoint("BOTTOMLEFT", unitContainer, "BOTTOMLEFT", 1, 1)
            end
            self.PowerBarBG:SetSize(FrameDB.Width - 2, PowerBarDB.Height)
            self.PowerBarBG:SetStatusBarTexture(UUF.Media.BackgroundTexture)
            self.PowerBarBG:SetStatusBarColor(PowerBarDB.BGColour[1], PowerBarDB.BGColour[2], PowerBarDB.BGColour[3], PowerBarDB.BGColour[4])
        end

        if self.PowerBar then
            self.PowerBar:ClearAllPoints()
            if PowerBarDB.Alignment == "TOP" then
                self.PowerBar:SetPoint("TOPLEFT", unitContainer, "TOPLEFT", 1, -1)
            else
                self.PowerBar:SetPoint("BOTTOMLEFT", unitContainer, "BOTTOMLEFT", 1, 1)
            end
            self.PowerBar:SetSize(FrameDB.Width - 2, PowerBarDB.Height)
            self.PowerBar:SetStatusBarTexture(UUF.Media.ForegroundTexture)
            self.PowerBar:SetStatusBarColor(PowerBarDB.FGColour[1], PowerBarDB.FGColour[2], PowerBarDB.FGColour[3], PowerBarDB.FGColour[4])
            self.PowerBar:SetFrameLevel(unitContainer:GetFrameLevel() + 2)
            if PowerBarDB.InverseGrowth then
                self.PowerBar:SetReverseFill(true)
            else
                self.PowerBar:SetReverseFill(false)
            end
            self.PowerBar.unit = unit
        end

        if self.PowerBarText then
            local anchorParent = PowerBarDB.Text.AnchorParent == "POWER" and self.PowerBar or self.Container
            self.PowerBarText:ClearAllPoints()
            self.PowerBarText:SetFont(UUF.Media.Font, PowerBarDB.Text.FontSize, UUFDB.General.FontFlag)
            self.PowerBarText:SetPoint(PowerBarDB.Text.AnchorFrom, anchorParent, PowerBarDB.Text.AnchorTo, PowerBarDB.Text.OffsetX, PowerBarDB.Text.OffsetY)
            if PowerBarDB.Text.ColourByType then
                local r, g, b, a = FetchPowerBarColour(unit)
                self.PowerBarText:SetTextColor(r, g, b, a)
            else
                self.PowerBarText:SetTextColor(PowerBarDB.Text.Colour[1], PowerBarDB.Text.Colour[2], PowerBarDB.Text.Colour[3], PowerBarDB.Text.Colour[4])
            end
            self.PowerBarText:SetJustifyH(UUF:SetJustification(PowerBarDB.Text.AnchorFrom))
        end

        if PowerBarDB.Enabled then
            self:RegisterUnitEvent("UNIT_POWER_UPDATE", UnitIsReal(unit) and unit)
            self:RegisterUnitEvent("UNIT_MAXPOWER", UnitIsReal(unit) and unit)
            if PowerBarDB.Alignment == "TOP" then
                self.HealthBar:ClearAllPoints()
                self.HealthBG:ClearAllPoints()
                self.HealthBar:SetPoint("BOTTOMLEFT", self.Container, "BOTTOMLEFT", 1, 1)
                self.HealthBG:SetPoint("BOTTOMLEFT", self.Container, "BOTTOMLEFT", 1, 1)
                self.HealthBG:SetHeight(UUFDB[normalizedUnit].Frame.Height - (self.PowerBar:GetHeight() + 3))
                self.HealthBar:SetHeight(UUFDB[normalizedUnit].Frame.Height - (self.PowerBar:GetHeight() + 3))
                self.PowerBarBorder:ClearAllPoints()
                self.PowerBarBorder:SetPoint("BOTTOMLEFT", self.PowerBar, "BOTTOMLEFT", 0, -1)
                self.PowerBarBorder:SetPoint("BOTTOMRIGHT", self.PowerBar, "BOTTOMRIGHT", 0, -1)
            else
                self.HealthBar:ClearAllPoints()
                self.HealthBG:ClearAllPoints()
                self.HealthBar:SetPoint("TOPLEFT", self.Container, "TOPLEFT", 1, -1)
                self.HealthBG:SetPoint("TOPLEFT", self.Container, "TOPLEFT", 1, -1)
                self.HealthBG:SetHeight(UUFDB[normalizedUnit].Frame.Height - (self.PowerBar:GetHeight() + 3))
                self.HealthBar:SetHeight(UUFDB[normalizedUnit].Frame.Height - (self.PowerBar:GetHeight() + 3))
                self.PowerBarBorder:ClearAllPoints()
                self.PowerBarBorder:SetPoint("TOPLEFT", self.PowerBar, "TOPLEFT", 0, 1)
                self.PowerBarBorder:SetPoint("TOPRIGHT", self.PowerBar, "TOPRIGHT", 0, 1)
            end
            self.PowerBar:Show()
            self.PowerBarBG:Show()
            self.PowerBarBorder:Show()
        else
            self.HealthBar:ClearAllPoints()
            self.HealthBG:ClearAllPoints()
            self.HealthBar:SetPoint("TOPLEFT", self.Container, "TOPLEFT", 1, -1)
            self.HealthBG:SetPoint("TOPLEFT", self.Container, "TOPLEFT", 1, -1)
            self.HealthBG:SetHeight(UUFDB[normalizedUnit].Frame.Height - 2)
            self.HealthBar:SetHeight(UUFDB[normalizedUnit].Frame.Height - 2)
            self.PowerBar:Hide()
            self.PowerBarBG:Hide()
            self.PowerBarBorder:Hide()
        end
        if PowerBarDB.Text.Enabled then
            self.PowerBarText:Show()
        else
            self.PowerBarText:Hide()
        end
    end
end

local function CreateAlternatePowerBar(self, unit)
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local AlternatePowerBarDB = UUFDB[normalizedUnit].AlternatePowerBar
    local unitContainer = self.Container

    if not self.AlternatePowerBarBG then
        self.AlternatePowerBarBG = CreateFrame("Frame", ResolveFrameName(unit).."_AlternatePowerBarBG", unitContainer, "BackdropTemplate")
        self.AlternatePowerBarBG:SetPoint(AlternatePowerBarDB.AnchorFrom, unitContainer, AlternatePowerBarDB.AnchorTo, AlternatePowerBarDB.XPosition, AlternatePowerBarDB.YPosition)
        self.AlternatePowerBarBG:SetSize(AlternatePowerBarDB.Width, AlternatePowerBarDB.Height)
        self.AlternatePowerBarBG:SetBackdrop(UUF.BackdropTemplate)
        self.AlternatePowerBarBG:SetBackdropColor(AlternatePowerBarDB.BGColour[1], AlternatePowerBarDB.BGColour[2], AlternatePowerBarDB.BGColour[3], AlternatePowerBarDB.BGColour[4])
        self.AlternatePowerBarBG:SetBackdropBorderColor(0, 0, 0, 1)
        self.AlternatePowerBarBG:SetFrameLevel(unitContainer:GetFrameLevel() + 5)
    end

    if not self.AlternatePowerBar then
        self.AlternatePowerBar = CreateFrame("StatusBar", ResolveFrameName(unit).."_AlternatePowerBar", unitContainer)
        self.AlternatePowerBar:SetPoint("TOPLEFT", self.AlternatePowerBarBG, "TOPLEFT", 1, -1)
        self.AlternatePowerBar:SetPoint("BOTTOMRIGHT", self.AlternatePowerBarBG, "BOTTOMRIGHT", -1, 1)
        self.AlternatePowerBar:SetSize(AlternatePowerBarDB.Width, AlternatePowerBarDB.Height)
        self.AlternatePowerBar:SetStatusBarTexture(UUF.Media.ForegroundTexture)
        self.AlternatePowerBar:SetFrameLevel(self.AlternatePowerBarBG:GetFrameLevel() + 1)
        if AlternatePowerBarDB.InverseGrowth then
            self.AlternatePowerBar:SetReverseFill(true)
        else
            self.AlternatePowerBar:SetReverseFill(false)
        end
        if AlternatePowerBarDB.ColourByType then
            local powerColour = UUFDB.General.CustomColours.Power[0]
            if powerColour then self.AlternatePowerBar:SetStatusBarColor(powerColour[1], powerColour[2], powerColour[3], powerColour[4]) end
        else
            self.AlternatePowerBar:SetStatusBarColor(AlternatePowerBarDB.FGColour[1], AlternatePowerBarDB.FGColour[2], AlternatePowerBarDB.FGColour[3], AlternatePowerBarDB.FGColour[4])
        end
        self.AlternatePowerBar.unit = unit
    end

    if AlternatePowerBarDB.Enabled and UUF:RequiresAlternatePowerBar() then
        self:RegisterUnitEvent("UNIT_POWER_UPDATE", UnitIsReal(unit) and unit)
        self:RegisterUnitEvent("UNIT_MAXPOWER", UnitIsReal(unit) and unit)
        self.AlternatePowerBarBG:Show()
        self.AlternatePowerBar:Show()
    else
        self.AlternatePowerBarBG:Hide()
        self.AlternatePowerBar:Hide()
    end
end

local function UpdateAlternatePowerBar(self, unit)
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local AlternatePowerBarDB = UUFDB[normalizedUnit].AlternatePowerBar
    local unitContainer = self.Container

    if self.AlternatePowerBarBG then
        self.AlternatePowerBarBG:ClearAllPoints()
        self.AlternatePowerBarBG:SetPoint(AlternatePowerBarDB.AnchorFrom, unitContainer, AlternatePowerBarDB.AnchorTo, AlternatePowerBarDB.XPosition, AlternatePowerBarDB.YPosition)
        self.AlternatePowerBarBG:SetSize(AlternatePowerBarDB.Width, AlternatePowerBarDB.Height)
        self.AlternatePowerBarBG:SetBackdropColor(AlternatePowerBarDB.BGColour[1], AlternatePowerBarDB.BGColour[2], AlternatePowerBarDB.BGColour[3], AlternatePowerBarDB.BGColour[4])
    end

    if self.AlternatePowerBar then
        self.AlternatePowerBar:ClearAllPoints()
        self.AlternatePowerBar:SetPoint("TOPLEFT", self.AlternatePowerBarBG, "TOPLEFT", 1, -1)
        self.AlternatePowerBar:SetPoint("BOTTOMRIGHT", self.AlternatePowerBarBG, "BOTTOMRIGHT", -1, 1)
        self.AlternatePowerBar:SetSize(AlternatePowerBarDB.Width, AlternatePowerBarDB.Height)
        self.AlternatePowerBar:SetStatusBarTexture(UUF.Media.ForegroundTexture)
        if AlternatePowerBarDB.InverseGrowth then
            self.AlternatePowerBar:SetReverseFill(true)
        else
            self.AlternatePowerBar:SetReverseFill(false)
        end
        if AlternatePowerBarDB.ColourByType then
            local powerColour = UUFDB.General.CustomColours.Power[0]
            if powerColour then self.AlternatePowerBar:SetStatusBarColor(powerColour[1], powerColour[2], powerColour[3], powerColour[4] or 1) end
        else
            self.AlternatePowerBar:SetStatusBarColor(AlternatePowerBarDB.FGColour[1], AlternatePowerBarDB.FGColour[2], AlternatePowerBarDB.FGColour[3], AlternatePowerBarDB.FGColour[4])
        end
    end

    if AlternatePowerBarDB.Enabled and UUF:RequiresAlternatePowerBar() then
        self.AlternatePowerBarBG:Show()
        self.AlternatePowerBar:Show()
    else
        self.AlternatePowerBarBG:Hide()
        self.AlternatePowerBar:Hide()
    end
end

local function CreateMouseoverHighlight(self, unit)
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local MouseoverHighlightDB = UUFDB[normalizedUnit].Indicators.MouseoverHighlight
    if not self.MouseoverHighlight then
        self.MouseoverHighlight = CreateFrame("Frame", nil, self.Container, "BackdropTemplate")
        self.MouseoverHighlight:SetAllPoints()
        self.MouseoverHighlight:SetBackdrop({ bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", edgeSize=1 })
        self.MouseoverHighlight:SetBackdropColor(0,0,0,0)
        self.MouseoverHighlight:SetBackdropBorderColor(MouseoverHighlightDB.Colour[1], MouseoverHighlightDB.Colour[2], MouseoverHighlightDB.Colour[3], MouseoverHighlightDB.Colour[4])
        self.MouseoverHighlight:Hide()
        self.MouseoverHighlight:SetFrameLevel(self.Container:GetFrameLevel() + 3)
        self:SetScript("OnEnter", function(self) local DB = UUF.db.profile[GetNormalizedUnit(unit)] if DB.Indicators.MouseoverHighlight.Enabled then self.MouseoverHighlight:Show() end end)
        self:SetScript("OnLeave", function(self) local DB = UUF.db.profile[GetNormalizedUnit(unit)] if DB.Indicators.MouseoverHighlight.Enabled then self.MouseoverHighlight:Hide() end end)
    end
end

local function UpdateMouseoverHighlight(self, unit)
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local MouseoverHighlightDB = UUFDB[normalizedUnit].Indicators.MouseoverHighlight

    if self.MouseoverHighlight then
        if MouseoverHighlightDB.Enabled then
            self.MouseoverHighlight:SetBackdropBorderColor(MouseoverHighlightDB.Colour[1], MouseoverHighlightDB.Colour[2], MouseoverHighlightDB.Colour[3], MouseoverHighlightDB.Colour[4])
            self:SetScript("OnEnter", function(self) self.MouseoverHighlight:Show() end)
            self:SetScript("OnLeave", function(self) self.MouseoverHighlight:Hide() end)
        else
            self:SetScript("OnEnter", function(self) end)
            self:SetScript("OnLeave", function(self) end)
            self.MouseoverHighlight:Hide()
        end
    end
end

local function CreateRaidTargetMarker(self, unit)
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local RaidTargetMarkerDB = UUFDB[normalizedUnit].Indicators.RaidTargetMarker
    if not self.RaidTargetMarker then
        self.RaidTargetMarker = self.HighLevelContainer:CreateTexture(ResolveFrameName(unit).."_".."RaidTargetMarker", "OVERLAY")
        self.RaidTargetMarker:SetSize(RaidTargetMarkerDB.Size, RaidTargetMarkerDB.Size)
        self.RaidTargetMarker:SetPoint(RaidTargetMarkerDB.AnchorFrom, self.HighLevelContainer, RaidTargetMarkerDB.AnchorTo, RaidTargetMarkerDB.OffsetX, RaidTargetMarkerDB.OffsetY)
        self.RaidTargetMarker.unit = unit
    end
    if RaidTargetMarkerDB.Enabled then
        self.RaidTargetMarker:Show()
    else
        self.RaidTargetMarker:Hide()
    end
end

local function UpdateRaidTargetMarker(self, unit)
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local RaidTargetMarkerDB = UUFDB[normalizedUnit].Indicators.RaidTargetMarker

    if self.RaidTargetMarker then
        self.RaidTargetMarker:ClearAllPoints()
        self.RaidTargetMarker:SetSize(RaidTargetMarkerDB.Size, RaidTargetMarkerDB.Size)
        self.RaidTargetMarker:SetPoint(RaidTargetMarkerDB.AnchorFrom, self.HighLevelContainer, RaidTargetMarkerDB.AnchorTo, RaidTargetMarkerDB.OffsetX, RaidTargetMarkerDB.OffsetY)
    end
    if RaidTargetMarkerDB.Enabled then
        self.RaidTargetMarker:Show()
    else
        self.RaidTargetMarker:Hide()
    end
end

local function CreateCombatIndicator(self, unit)
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local StatusDB = UUFDB[normalizedUnit].Indicators.Status

    if not self.CombatIndicator then
        self.CombatIndicator = self.HighLevelContainer:CreateTexture(ResolveFrameName(unit).."_".."CombatIndicator", "OVERLAY")
        self.CombatIndicator:SetSize(StatusDB.Size, StatusDB.Size)
        self.CombatIndicator:SetPoint(StatusDB.AnchorFrom, self.HighLevelContainer, StatusDB.AnchorTo, StatusDB.OffsetX, StatusDB.OffsetY)
        if StatusDB.CombatTexture == "DEFAULT" then
            self.CombatIndicator:SetTexture([[Interface\CharacterFrame\UI-StateIcon]])
            self.CombatIndicator:SetTexCoord(0.5, 1, 0, 0.49)
        else
            self.CombatIndicator:SetTexture(UUF.StatusTextureMap[StatusDB.CombatTexture])
            self.CombatIndicator:SetTexCoord(0, 1, 0, 1)
        end
        self.CombatIndicator.unit = unit
        if UnitAffectingCombat(unit) and StatusDB.Combat then
            self.CombatIndicator:Show()
        else
            self.CombatIndicator:Hide()
        end
    end
end

local function CreateRestingIndicator(self, unit)
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local StatusDB = UUFDB[normalizedUnit].Indicators.Status

    if not self.RestingIndicator then
        self.RestingIndicator = self.HighLevelContainer:CreateTexture(ResolveFrameName(unit).."_".."RestingIndicator", "OVERLAY")
        self.RestingIndicator:SetSize(StatusDB.Size, StatusDB.Size)
        self.RestingIndicator:SetPoint(StatusDB.AnchorFrom, self.HighLevelContainer, StatusDB.AnchorTo, StatusDB.OffsetX, StatusDB.OffsetY)
        if StatusDB.RestingTexture == "DEFAULT" then
            self.RestingIndicator:SetTexture([[Interface\CharacterFrame\UI-StateIcon]])
            self.RestingIndicator:SetTexCoord(0, 0.5, 0, 0.421875)
        else
            self.RestingIndicator:SetTexture(UUF.StatusTextureMap[StatusDB.RestingTexture])
            self.RestingIndicator:SetTexCoord(0, 1, 0, 1)
        end
        self.RestingIndicator.unit = unit
        if (IsResting() and unit == "player") and StatusDB.Resting then
            self.RestingIndicator:Show()
        else
            self.RestingIndicator:Hide()
        end
    end
end

local function UpdateCombatIndicator(self, unit)
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local StatusDB = UUFDB[normalizedUnit].Indicators.Status

    if self.CombatIndicator then
        self.CombatIndicator:ClearAllPoints()
        self.CombatIndicator:SetSize(StatusDB.Size, StatusDB.Size)
        self.CombatIndicator:SetPoint(StatusDB.AnchorFrom, self.HighLevelContainer, StatusDB.AnchorTo, StatusDB.OffsetX, StatusDB.OffsetY)
        if StatusDB.CombatTexture == "DEFAULT" then
            self.CombatIndicator:SetTexture([[Interface\CharacterFrame\UI-StateIcon]])
            self.CombatIndicator:SetTexCoord(0.5, 1, 0, 0.49)
        else
            self.CombatIndicator:SetTexture(UUF.StatusTextureMap[StatusDB.CombatTexture])
            self.CombatIndicator:SetTexCoord(0, 1, 0, 1)
        end
    end
    if UnitAffectingCombat(unit) and StatusDB.Combat then
        self.CombatIndicator:Show()
    else
        self.CombatIndicator:Hide()
    end
end

local function UpdateRestingIndicator(self, unit)
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local StatusDB = UUFDB[normalizedUnit].Indicators.Status

    if self.RestingIndicator then
        self.RestingIndicator:ClearAllPoints()
        self.RestingIndicator:SetSize(StatusDB.Size, StatusDB.Size)
        self.RestingIndicator:SetPoint(StatusDB.AnchorFrom, self.HighLevelContainer, StatusDB.AnchorTo, StatusDB.OffsetX, StatusDB.OffsetY)
        if StatusDB.RestingTexture == "DEFAULT" then
            self.RestingIndicator:SetTexture([[Interface\CharacterFrame\UI-StateIcon]])
            self.RestingIndicator:SetTexCoord(0, 0.5, 0, 0.421875)
        else
            self.RestingIndicator:SetTexture(UUF.StatusTextureMap[StatusDB.RestingTexture])
            self.RestingIndicator:SetTexCoord(0, 1, 0, 1)
        end
    end
    if (IsResting() and unit == "player") and StatusDB.Resting then
        self.RestingIndicator:Show()
    else
        self.RestingIndicator:Hide()
    end
end

local function CreateLeaderIndicator(self, unit)
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local IndicatorsDB = UUFDB[normalizedUnit].Indicators

    if not self.LeaderIndicator then
        self.LeaderIndicator = self.HighLevelContainer:CreateTexture(ResolveFrameName(unit).."_".."LeaderIndicator", "OVERLAY")
        self.LeaderIndicator:SetSize(IndicatorsDB.Leader.Size, IndicatorsDB.Leader.Size)
        self.LeaderIndicator:SetPoint(IndicatorsDB.Leader.AnchorFrom, self.HighLevelContainer, IndicatorsDB.Leader.AnchorTo, IndicatorsDB.Leader.OffsetX, IndicatorsDB.Leader.OffsetY)
        self.LeaderIndicator:SetTexture([[Interface\GroupFrame\UI-Group-LeaderIcon]])
        self.LeaderIndicator.unit = unit
        if (UnitIsGroupLeader(unit) or UnitIsGroupAssistant(unit)) and IndicatorsDB.Leader.Enabled then
            self.LeaderIndicator:Show()
        else
            self.LeaderIndicator:Hide()
        end
    end
end

local function UpdateLeaderIndicator(self, unit)
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local IndicatorsDB = UUFDB[normalizedUnit].Indicators

    if self.LeaderIndicator then
        self.LeaderIndicator:ClearAllPoints()
        self.LeaderIndicator:SetSize(IndicatorsDB.Leader.Size, IndicatorsDB.Leader.Size)
        self.LeaderIndicator:SetPoint(IndicatorsDB.Leader.AnchorFrom, self.HighLevelContainer, IndicatorsDB.Leader.AnchorTo, IndicatorsDB.Leader.OffsetX, IndicatorsDB.Leader.OffsetY)
    end
    if (UnitIsGroupLeader(unit) or UnitIsGroupAssistant(unit)) and IndicatorsDB.Leader.Enabled then
        self.LeaderIndicator:Show()
    else
        self.LeaderIndicator:Hide()
    end
end

local function CreateTargetIndicator(self, unit)
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local IndicatorsDB = UUFDB[normalizedUnit].Indicators

    if not self.TargetIndicator then
        self.TargetIndicator = CreateFrame("Frame", ResolveFrameName(unit).."_TargetIndicator", self.Container, "BackdropTemplate")
        self.TargetIndicator:SetFrameLevel(self.Container:GetFrameLevel() + 3)
        if IndicatorsDB.TargetIndicator.Style == "GLOW" then
            self.TargetIndicator:SetBackdrop({ edgeFile = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Glow.tga", edgeSize = 3, insets = {left = -6, right = -6, top = -6, bottom = -6} })
            self.TargetIndicator:SetPoint("TOPLEFT", self.Container, "TOPLEFT", -3, 3)
            self.TargetIndicator:SetPoint("BOTTOMRIGHT", self.Container, "BOTTOMRIGHT", 3, -3)
        else
            self.TargetIndicator:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left = -1, right = -1, top = -1, bottom = -1} })
            self.TargetIndicator:SetPoint("TOPLEFT", self.Container, "TOPLEFT", -1, 1)
            self.TargetIndicator:SetPoint("BOTTOMRIGHT", self.Container, "BOTTOMRIGHT", 1, -1)
        end
        self.TargetIndicator:SetBackdropColor(0, 0, 0, 0)
        self.TargetIndicator:SetBackdropBorderColor(IndicatorsDB.TargetIndicator.Colour[1], IndicatorsDB.TargetIndicator.Colour[2], IndicatorsDB.TargetIndicator.Colour[3], IndicatorsDB.TargetIndicator.Colour[4])
        self.TargetIndicator:Hide()
        if IndicatorsDB.TargetIndicator.Enabled then
            UUF:RegisterTargetIndicatorFrame(self, unit)
        else
            self.TargetIndicator:Hide()
        end
    end
end

local function UpdateTargetIndicator(self, unit)
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local IndicatorsDB = UUFDB[normalizedUnit].Indicators

    if self.TargetIndicator then
        self.TargetIndicator:ClearAllPoints()
        if IndicatorsDB.TargetIndicator.Style == "GLOW" then
            self.TargetIndicator:SetBackdrop({ edgeFile = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Glow.tga", edgeSize = 3, insets = {left = -6, right = -6, top = -6, bottom = -6} })
            self.TargetIndicator:SetPoint("TOPLEFT", self.Container, "TOPLEFT", -3, 3)
            self.TargetIndicator:SetPoint("BOTTOMRIGHT", self.Container, "BOTTOMRIGHT", 3, -3)
        else
            self.TargetIndicator:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left = -1, right = -1, top = -1, bottom = -1} })
            self.TargetIndicator:SetPoint("TOPLEFT", self.Container, "TOPLEFT", -1, 1)
            self.TargetIndicator:SetPoint("BOTTOMRIGHT", self.Container, "BOTTOMRIGHT", 1, -1)
        end
        self.TargetIndicator:SetBackdropBorderColor(IndicatorsDB.TargetIndicator.Colour[1], IndicatorsDB.TargetIndicator.Colour[2], IndicatorsDB.TargetIndicator.Colour[3], IndicatorsDB.TargetIndicator.Colour[4])
    end
    if IndicatorsDB.TargetIndicator.Enabled then
        UUF:RegisterTargetIndicatorFrame(self, unit)
    else
        self.TargetIndicator:Hide()
    end
end

local function CreatePortrait(self, unit)
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local PortraitDB = UUFDB[normalizedUnit].Portrait
    local unitContainer = self.Container

    if PortraitDB then
        if not self.Portrait then
            self.Portrait = CreateFrame("Frame", ResolveFrameName(unit).."_Portrait", unitContainer, "BackdropTemplate")
            self.Portrait:SetBackdrop(UUF.BackdropTemplate)
            self.Portrait:SetBackdropColor(26/255, 26/255, 26/255, 1)
            self.Portrait:SetBackdropBorderColor(0, 0, 0, 1)
            if PortraitDB.MatchFrameHeight then
                PortraitDB.Size = UUFDB[normalizedUnit].Frame.Height
            else
                PortraitDB.Size = PortraitDB.Size
            end
            self.Portrait:SetSize(PortraitDB.Size, PortraitDB.Size)
            self.Portrait:SetPoint(PortraitDB.AnchorFrom, unitContainer, PortraitDB.AnchorTo, PortraitDB.OffsetX, PortraitDB.OffsetY)
            self.Portrait.Texture = self.Portrait:CreateTexture(nil, "ARTWORK")
            self.Portrait.Texture:SetPoint("TOPLEFT", self.Portrait, "TOPLEFT", 1, -1)
            self.Portrait.Texture:SetPoint("BOTTOMRIGHT", self.Portrait, "BOTTOMRIGHT", -1, 1)
            self.Portrait.Texture:SetTexCoord((PortraitDB.Zoom or 0)*0.5, 1-(PortraitDB.Zoom or 0)*0.5, (PortraitDB.Zoom or 0)*0.5, 1-(PortraitDB.Zoom or 0)*0.5)
            self.Portrait.unit = unit

            if PortraitDB.Enabled then
                self.Portrait:RegisterUnitEvent("UNIT_PORTRAIT_UPDATE", unit)
                self.Portrait:RegisterEvent("PLAYER_TARGET_CHANGED")
                self.Portrait:SetScript("OnEvent", function(self) SetPortraitTexture(self.Texture, self.unit, true) end)
                SetPortraitTexture(self.Portrait.Texture, unit, true)
                if self.Portrait then self.Portrait:Show() end
            else
                if self.Portrait then self.Portrait:Hide() end
                self.Portrait:UnregisterAllEvents()
                self.Portrait:SetScript("OnEvent", nil)
            end
        end
    end
end

local function UpdatePortrait(self, unit)
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local PortraitDB = UUFDB[normalizedUnit].Portrait
    local unitContainer = self.Container

    if PortraitDB then
        if self.Portrait then
            self.Portrait:ClearAllPoints()
            if PortraitDB.MatchFrameHeight then
                PortraitDB.Size = UUFDB[normalizedUnit].Frame.Height
            else
                PortraitDB.Size = PortraitDB.Size
            end
            self.Portrait:SetSize(PortraitDB.Size, PortraitDB.Size)
            self.Portrait:SetPoint(PortraitDB.AnchorFrom, unitContainer, PortraitDB.AnchorTo, PortraitDB.OffsetX, PortraitDB.OffsetY)
            self.Portrait.Texture:ClearAllPoints()
            self.Portrait.Texture:SetPoint("TOPLEFT", self.Portrait, "TOPLEFT", 1, -1)
            self.Portrait.Texture:SetPoint("BOTTOMRIGHT", self.Portrait, "BOTTOMRIGHT", -1, 1)
            self.Portrait.Texture:SetTexCoord((PortraitDB.Zoom or 0)*0.5, 1-(PortraitDB.Zoom or 0)*0.5, (PortraitDB.Zoom or 0)*0.5, 1-(PortraitDB.Zoom or 0)*0.5)
            SetPortraitTexture(self.Portrait.Texture, unit, true)
        end
        if PortraitDB.Enabled then
            self.Portrait:RegisterUnitEvent("UNIT_PORTRAIT_UPDATE", unit)
            self.Portrait:RegisterEvent("PLAYER_TARGET_CHANGED")
            if self.Portrait then self.Portrait:Show() end
        else
            if self.Portrait then self.Portrait:Hide() end
            self.Portrait:UnregisterAllEvents()
            self.Portrait:SetScript("OnEvent", nil)
        end
    end
end

local function CreateTag(self, unit, tag)
    if not unit or not tag then return end
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local Tags = UUFDB[normalizedUnit].Tags
    local highLevelContainer = self.HighLevelContainer
    local GeneralDB = UUFDB.General
    local TagDB = Tags[tag]
    if not TagDB then return end
    if not self[tag] then
        self[tag] = highLevelContainer:CreateFontString(ResolveFrameName(unit).."_"..tag, "OVERLAY")
        self[tag]:SetFont(UUF.Media.Font, TagDB.FontSize, GeneralDB.FontFlag)
        self[tag]:SetPoint(TagDB.AnchorFrom, highLevelContainer, TagDB.AnchorTo, TagDB.OffsetX, TagDB.OffsetY)
        self[tag]:SetTextColor(TagDB.Colour[1], TagDB.Colour[2], TagDB.Colour[3], TagDB.Colour[4])
        self[tag]:SetText(UUF:EvaluateTagString(unit, (TagDB.Tag or "")))
        self[tag]:SetJustifyH(UUF:SetJustification(TagDB.AnchorFrom))
        self[tag]:SetShadowOffset(GeneralDB.FontShadows.OffsetX, GeneralDB.FontShadows.OffsetY)
        self[tag]:SetShadowColor(GeneralDB.FontShadows.Colour[1], GeneralDB.FontShadows.Colour[2], GeneralDB.FontShadows.Colour[3], GeneralDB.FontShadows.Colour[4])
    end
    self[tag].unit = unit
end

local function UpdateTag(self, unit, tag)
    if not unit or not tag then return end
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local Tags = UUFDB[normalizedUnit].Tags
    local TagDB = Tags[tag]
    if not TagDB then return end
    if self[tag] then
        self[tag]:ClearAllPoints()
        self[tag]:SetFont(UUF.Media.Font, TagDB.FontSize, UUFDB.General.FontFlag)
        self[tag]:SetPoint(TagDB.AnchorFrom, self.HighLevelContainer, TagDB.AnchorTo, TagDB.OffsetX, TagDB.OffsetY)
        self[tag]:SetTextColor(TagDB.Colour[1], TagDB.Colour[2], TagDB.Colour[3], TagDB.Colour[4])
        self[tag]:SetText(UUF:EvaluateTagString(unit, (TagDB.Tag or "")))
        self[tag]:SetJustifyH(UUF:SetJustification(TagDB.AnchorFrom))
    end
end

--------------------------------------------------------------
--- Factory Functions
--------------------------------------------------------------

function UUF:CreateUnitFrame(unit)
    local frameName = ResolveFrameName(unit)
    if not frameName then return end
    local normalizedUnit = GetNormalizedUnit(unit)
    local unitDB = UUF.db.profile[normalizedUnit]

    local unitFrame = CreateFrame("Button", frameName, UIParent, "SecureUnitButtonTemplate,BackdropTemplate,PingableUnitFrameTemplate")
    unitFrame.unit = unit
    unitFrame:RegisterForClicks("AnyUp")
    unitFrame:SetAttribute("unit", unit)
    unitFrame:SetAttribute("*type1", "target")
    unitFrame:SetAttribute("*type2", "togglemenu")

    -- Enable Clique Support (Thanks @Mapko)
    if ClickCastFrames then
        ClickCastFrames[unitFrame] = true
    end

    unitFrame:SetSize(unitDB.Frame.Width, unitDB.Frame.Height)
    if unitDB.Frame.AnchorToEssentialCooldowns then
        local anchorParent = _G["UUF_CDMAnchor"] or "UIParent"
        unitFrame:SetPoint(unitDB.Frame.AnchorFrom, anchorParent, unitDB.Frame.AnchorTo, unitDB.Frame.XPosition, unitDB.Frame.YPosition)
    else
        local anchorParent = unitDB.Frame.AnchorParent or "UIParent"
        unitFrame:SetPoint(unitDB.Frame.AnchorFrom, anchorParent, unitDB.Frame.AnchorTo, unitDB.Frame.XPosition, unitDB.Frame.YPosition)
    end

    ToggleUnitWatch(unitFrame)

    CreateContainer(unitFrame, unit)
    CreateHealthBar(unitFrame, unit)
    CreateAbsorbBar(unitFrame, unit)
    CreatePowerBar(unitFrame, unit)
    if unit == "player" then CreateAlternatePowerBar(unitFrame, "player") end
    CreateMouseoverHighlight(unitFrame, unit)
    CreateRaidTargetMarker(unitFrame, unit)
    if unit == "player" then CreateCombatIndicator(unitFrame, unit) CreateRestingIndicator(unitFrame, unit) end
    if unit == "player" or unit == "target" then CreateLeaderIndicator(unitFrame, unit) end
    CreateTargetIndicator(unitFrame, unit)
    CreatePortrait(unitFrame, unit)
    CreateTag(unitFrame, unit, "TagOne")
    CreateTag(unitFrame, unit, "TagTwo")
    CreateTag(unitFrame, unit, "TagThree")

    _G[frameName] = unitFrame
    return unitFrame
end

function UUF:UpdateUnitFrame(unit)
    local frameName = ResolveFrameName(unit)
    if not frameName then return end
    local unitFrame = _G[frameName]
    if not unitFrame then return end
    local normalizedUnit = GetNormalizedUnit(unit)
    local unitDB = UUF.db.profile[normalizedUnit]

    ToggleUnitWatch(unitFrame)

    unitFrame:ClearAllPoints()
    unitFrame:SetSize(unitDB.Frame.Width, unitDB.Frame.Height)
    if unitDB.Frame.AnchorToEssentialCooldowns then
        local anchorParent = _G["UUF_CDMAnchor"] or "UIParent"
        unitFrame:SetPoint(unitDB.Frame.AnchorFrom, anchorParent, unitDB.Frame.AnchorTo, unitDB.Frame.XPosition, unitDB.Frame.YPosition)
    else
        local anchorParent = unitDB.Frame.AnchorParent or "UIParent"
        unitFrame:SetPoint(unitDB.Frame.AnchorFrom, anchorParent, unitDB.Frame.AnchorTo, unitDB.Frame.XPosition, unitDB.Frame.YPosition)
    end
    UpdateHealthBar(unitFrame, unit)
    UpdateAbsorbBar(unitFrame, unit)
    UpdatePowerBar(unitFrame, unit)
    if unit == "player" then UpdateAlternatePowerBar(unitFrame, "player") end
    UpdateMouseoverHighlight(unitFrame, unit)
    UpdateRaidTargetMarker(unitFrame, unit)
    if unit == "player" then UpdateCombatIndicator(unitFrame, unit) UpdateRestingIndicator(unitFrame, unit) end
    if unit == "player" or unit == "target" then UpdateLeaderIndicator(unitFrame, unit) end
    UpdateTargetIndicator(unitFrame, unit)
    UpdatePortrait(unitFrame, unit)
    UpdateTag(unitFrame, unit, "TagOne")
    UpdateTag(unitFrame, unit, "TagTwo")
    UpdateTag(unitFrame, unit, "TagThree")
    UpdateUnitFrameData(unitFrame, nil, unit)
end

function UUF:LayoutBossFrames()
    local Frame = UUF.db.profile.boss.Frame
    if #UUF.BossFrames == 0 then return end
    local bossFrames = UUF.BossFrames
    if Frame.GrowthDirection == "UP" then
        bossFrames = {}
        for i = #UUF.BossFrames, 1, -1 do bossFrames[#bossFrames+1] = UUF.BossFrames[i] end
    end
    local layoutConfig = UUF.LayoutConfig[Frame.AnchorFrom]
    local frameHeight = bossFrames[1]:GetHeight()
    local containerHeight = (frameHeight + Frame.Spacing) * #bossFrames - Frame.Spacing
    local offsetY = containerHeight * layoutConfig.offsetMultiplier
    if layoutConfig.isCenter then offsetY = offsetY - (frameHeight / 2) end
    local initialAnchor = AnchorUtil.CreateAnchor(layoutConfig.anchor, UIParent, Frame.AnchorTo, Frame.XPosition, Frame.YPosition + offsetY)
    AnchorUtil.VerticalLayout(bossFrames, initialAnchor, Frame.Spacing)
end

function UUF:UpdateAllBossFrames()
    for i = 1, UUF.MaxBossFrames do
        local unitFrame = _G["UUF_Boss"..i]
        if unitFrame then
            UUF:UpdateUnitFrame("boss"..i)
        end
    end
    UUF:LayoutBossFrames()
    if UUF.TestMode then UUF:ShowBossFrames() end
end