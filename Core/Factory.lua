local _, UUF = ...
local oUF = UUF.oUF
local CapitalizedUnit = UUF.CapitalizedUnits

local function GetNormalizedUnit(unit)
    local normalizedUnit = unit:match("^boss%d+$") and "boss" or unit:match("^party%d+$") and "party" or unit:match("^raid%d+$") and "raid" or unit
    return normalizedUnit
end

local function CreateContainer(self, unit)
    if not self.Container then
        self.Container = CreateFrame("Frame", CapitalizedUnit[unit] .. "_Container", self, "BackdropTemplate")
        self.Container:SetBackdrop(UUF.BackdropTemplate)
        self.Container:SetBackdropColor(0, 0, 0, 0)
        self.Container:SetBackdropBorderColor(0, 0, 0, 1)
        self.Container:SetAllPoints(self)
        self.Container:SetFrameLevel(1)
    end
end

local function CreateHealthBar(self, unit)
    local UUFDB = UUF.db.profile
    local General = UUFDB.General
    local normalizedUnit = GetNormalizedUnit(unit)
    local Frame = UUFDB[normalizedUnit].Frame
    local unitContainer = self.Container

    if not self.HealthBar then
        if not self.HealthBG then
            self.HealthBG = CreateFrame("StatusBar", CapitalizedUnit[unit] .. "_HealthBG", unitContainer)
            self.HealthBG:SetPoint("TOPLEFT", unitContainer, "TOPLEFT", 1, -1)
            self.HealthBG:SetSize(Frame.Width - 2, Frame.Height - 2)
            self.HealthBG:SetStatusBarTexture(UUF.Media.BackgroundTexture)
            self.HealthBG:SetFrameLevel(unitContainer:GetFrameLevel() + 1)
            self.HealthBG:SetStatusBarColor(Frame.BGColour[1], Frame.BGColour[2], Frame.BGColour[3], Frame.BGColour[4])
        end

        self.HealthBar = CreateFrame("StatusBar", CapitalizedUnit[unit] .. "_HealthBar", unitContainer)
        self.HealthBar:SetPoint("TOPLEFT", unitContainer, "TOPLEFT", 1, -1)
        self.HealthBar:SetSize(Frame.Width - 2, Frame.Height - 2)
        self.HealthBar:SetStatusBarTexture(UUF.Media.ForegroundTexture)
        self.HealthBar:SetFrameLevel(unitContainer:GetFrameLevel() + 2)
        self.HealthBar:SetStatusBarColor(Frame.FGColour[1], Frame.FGColour[2], Frame.FGColour[3], Frame.FGColour[4])
        self.HealthBar.colorClass = Frame.ClassColour
        self.HealthBar.colorReaction = Frame.ReactionColour

        self.Health = self.HealthBar
        -- Reverse Fill Health Bar Background
        -- This will simulate Transparent FG, Opaque BG.
        self.Health.PostUpdate = function(_, _, curHP, maxHP)
            local unitHP = self.HealthBG
            maxHP = maxHP or 1
            curHP = curHP or 0
            unitHP:SetMinMaxValues(0, maxHP)
            unitHP:SetValue(maxHP - curHP)
        end

        -- Add a UNIT_AURA Hook to Update Health Colour based on Debuff Type
        self:RegisterEvent("UNIT_AURA", function(_, _, u)
            if u == unit and Frame.ColourHealthByDispel then
                UUF:ColourOnDispel(self, u)
            end
        end, true)
        self.HealthBG:SetReverseFill(true)
    end

    if not self.HighLevelContainer then
        self.HighLevelContainer = CreateFrame("Frame", CapitalizedUnit[unit] .. "_HighLevelContainer", unitContainer)
        self.HighLevelContainer:SetSize(self:GetWidth(), self:GetHeight())
        self.HighLevelContainer:SetPoint("CENTER", 0, 0)
        self.HighLevelContainer:SetFrameLevel(999)
    end
end

local function CreateHealthPrediction(self, unit)
    local UUFDB = UUF.db.profile
    local General = UUFDB.General
    local normalizedUnit = GetNormalizedUnit(unit)
    local Absorb = UUFDB[normalizedUnit].HealPrediction.Absorb
    local HealAbsorb = UUFDB[normalizedUnit].HealPrediction.HealAbsorb
    local Frame = UUFDB[normalizedUnit].Frame
    local PowerBar = UUFDB[normalizedUnit].PowerBar
    local hasPowerBar = PowerBar and PowerBar.Enabled
    if not self.Health then return end

    if not self.AbsorbBar then
        self.AbsorbBar = CreateFrame("StatusBar", CapitalizedUnit[unit] .. "_AbsorbBar", self.HealthBar)
        self.AbsorbBar:SetStatusBarTexture(UUF.Media.ForegroundTexture)
        self.AbsorbBar:SetStatusBarColor(Absorb.Colour[1], Absorb.Colour[2], Absorb.Colour[3], Absorb.Colour[4])
        self.AbsorbBar:SetFrameLevel(self.HealthBar:GetFrameLevel() + 1)
        self.AbsorbBar:SetOrientation(self.HealthBar:GetOrientation() or "HORIZONTAL")
        self.AbsorbBar:ClearAllPoints()
        local yOffset = 0
        if hasPowerBar and PowerBar.Height then
            if Absorb.AnchorPoint == "BOTTOMLEFT" or Absorb.AnchorPoint == "BOTTOMRIGHT" then
                yOffset = 1
            elseif Absorb.AnchorPoint == "TOPLEFT" or Absorb.AnchorPoint == "TOPRIGHT" then
                yOffset = 0
            end
        end
        self.AbsorbBar:SetPoint( Absorb.AnchorPoint, self.HealthBar, Absorb.AnchorPoint, 0, yOffset )
        self.AbsorbBar:SetReverseFill((Absorb.AnchorPoint == "BOTTOMRIGHT" or Absorb.AnchorPoint == "TOPRIGHT") and true or false)
        local maxHeight = Frame.Height - (hasPowerBar and (PowerBar.Height + 3) or 2)
        local newHeight = math.min(Absorb.Height, maxHeight)
        self.AbsorbBar:SetHeight(newHeight)
    end
    if not self.HealAbsorbBar then
        self.HealAbsorbBar = CreateFrame("StatusBar", CapitalizedUnit[unit] .. "_HealAbsorbBar", self.HealthBar)
        self.HealAbsorbBar:SetStatusBarTexture(UUF.Media.ForegroundTexture)
        self.HealAbsorbBar:SetStatusBarColor(unpack(HealAbsorb.Colour))
        self.HealAbsorbBar:SetFrameLevel(self.HealthBar:GetFrameLevel() + 1)
        self.HealAbsorbBar:SetOrientation("HORIZONTAL")
        self.HealAbsorbBar:ClearAllPoints()
        self.HealAbsorbBar:SetPoint("TOPRIGHT", self.HealthBar:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
        self.HealAbsorbBar:SetPoint("BOTTOMRIGHT", self.HealthBar:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
        self.HealAbsorbBar:SetWidth(self.HealthBar:GetWidth())
        self.HealAbsorbBar:SetReverseFill(true)
    end

    self.HealthPrediction = {
        myBar = nil,
        otherBar = nil,
        absorbBar = Absorb.Enabled and self.AbsorbBar or nil,
        healAbsorbBar = HealAbsorb.Enabled and self.HealAbsorbBar or nil,
        maxOverflow = 1.00,
        showRawAbsorb = true
    }
    if not Absorb.Enabled then
        self.AbsorbBar:Hide()
    end
    if not HealAbsorb.Enabled then
        self.HealAbsorbBar:Hide()
    end
end

local function CreatePowerBar(self, unit)
    local UUFDB = UUF.db.profile
    local General = UUFDB.General
    local normalizedUnit = GetNormalizedUnit(unit)
    local Frame = UUFDB[normalizedUnit].Frame
    local PowerBar = UUFDB[normalizedUnit].PowerBar
    local unitContainer = self.Container

    if not self.PowerBarBG then
        self.PowerBarBG = CreateFrame("StatusBar", nil, unitContainer)
        self.PowerBarBG:SetPoint("BOTTOMLEFT", unitContainer, "BOTTOMLEFT", 1, 1)
        self.PowerBarBG:SetSize(Frame.Width - 2, PowerBar.Height)
        self.PowerBarBG:SetStatusBarTexture(UUF.Media.BackgroundTexture)
        self.PowerBarBG:SetFrameLevel(unitContainer:GetFrameLevel() + 1)
        local BGColour = PowerBar.BGColour
        self.PowerBarBG:SetStatusBarColor(BGColour[1], BGColour[2], BGColour[3], BGColour[4])
    end

    if not self.PowerBar then
        self.PowerBar = CreateFrame("StatusBar", nil, unitContainer)
        self.PowerBar:SetPoint("BOTTOMLEFT", unitContainer, "BOTTOMLEFT", 1, 1)
        self.PowerBar:SetSize(Frame.Width - 2, PowerBar.Height)
        self.PowerBar:SetStatusBarTexture(UUF.Media.ForegroundTexture)
        self.PowerBar:SetFrameLevel(unitContainer:GetFrameLevel() + 2)
        local FGColour = PowerBar.FGColour
        self.PowerBar:SetStatusBarColor(FGColour[1], FGColour[2], FGColour[3], FGColour[4])
        self.PowerBar.colorPower = PowerBar.ColourByType
    end

    if not self.PowerBarBorder then
        self.PowerBarBorder = CreateFrame("Frame", CapitalizedUnit[unit] .. "_PowerBarBorder", self.PowerBar, "BackdropTemplate")
        self.PowerBarBorder:SetBackdrop(UUF.BackdropTemplate)
        self.PowerBarBorder:SetBackdropColor(0, 0, 0, 0)
        self.PowerBarBorder:SetBackdropBorderColor(0, 0, 0, 1)
        self.PowerBarBorder:SetSize(Frame.Width, PowerBar.Height + 2)
        self.PowerBarBorder:SetPoint("BOTTOMLEFT", self.PowerBar, "BOTTOMLEFT", -1, -1)
    end

    if PowerBar.Enabled then
        self.Power = self.PowerBar
        self.PowerBar:Show()
        if self.PowerBarBG then self.PowerBarBG:Show() end
        self.HealthBG:SetHeight(Frame.Height - (self.PowerBar:GetHeight() + 2))
        self.HealthBar:SetHeight(Frame.Height - (self.PowerBar:GetHeight() + 2))
    else
        self.Power = nil
        self.PowerBar:Hide()
        if self.PowerBarBG then self.PowerBarBG:Hide() end
        self.HealthBG:SetHeight(Frame.Height - 2)
        self.HealthBar:SetHeight(Frame.Height - 2)
    end
end

-- TODO:
-- Alternative Power.
-- Class Power.

local function CreateCastbar(self, unit)
    local UUFDB = UUF.db.profile
    local General = UUFDB.General
    local normalizedUnit = GetNormalizedUnit(unit)
    local CastBar = UUFDB[normalizedUnit].CastBar
    local SpellName = CastBar.Texts.SpellName
    local CastTime = CastBar.Texts.CastTime

    if not self.CastBarContainer then
        self.CastBarContainer = CreateFrame("Frame", CapitalizedUnit[unit] .. "_CastBarContainer", self, "BackdropTemplate")
        self.CastBarContainer:SetBackdrop(UUF.BackdropTemplate)
        self.CastBarContainer:SetBackdropColor(0, 0, 0, 0)
        self.CastBarContainer:SetBackdropBorderColor(0, 0, 0, 1)
        self.CastBarContainer:SetSize(CastBar.Width, CastBar.Height)
        self.CastBarContainer:ClearAllPoints()
        self.CastBarContainer:SetPoint(CastBar.AnchorFrom, self, CastBar.AnchorTo, CastBar.OffsetX, CastBar.OffsetY)
        self.CastBarContainer:Hide()
    end

    if not self.CastBar then
        if not self.CastBG then
            self.CastBG = CreateFrame("StatusBar", CapitalizedUnit[unit] .. "_CastBarBG", self.CastBarContainer)
            self.CastBG:SetPoint("TOPLEFT", self.CastBarContainer, "TOPLEFT", 1, -1)
            self.CastBG:SetSize(CastBar.Width - 2, CastBar.Height - 2)
            self.CastBG:SetStatusBarTexture(UUF.Media.BackgroundTexture)
            self.CastBG:SetFrameLevel(self.CastBarContainer:GetFrameLevel() + 1)
            self.CastBG:SetStatusBarColor(CastBar.BGColour[1], CastBar.BGColour[2], CastBar.BGColour[3], CastBar.BGColour[4])
            self.CastBG:SetReverseFill(true)
            self.CastBG:Show()
        end
        self.CastBar = CreateFrame("StatusBar", CapitalizedUnit[unit] .. "_CastBar", self.CastBarContainer, "BackdropTemplate")
        self.CastBar:SetStatusBarTexture(UUF.Media.ForegroundTexture)
        self.CastBar:ClearAllPoints()
        self.CastBar:SetPoint("TOPLEFT", self.CastBarContainer, "TOPLEFT", 1, -1)
        self.CastBar:SetSize(CastBar.Width - 2, CastBar.Height - 2)
        self.CastBar:SetStatusBarColor(CastBar.FGColour[1], CastBar.FGColour[2], CastBar.FGColour[3], CastBar.FGColour[4])
    end

    if not self.CastBarIcon then
        self.CastBarIcon = self.CastBar:CreateTexture(CapitalizedUnit[unit] .. "_CastBarIcon", "OVERLAY")
        self.CastBarIcon:SetSize(CastBar.Height - 2, CastBar.Height - 2)
        self.CastBarIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    end

    if not self.CastBarSpellName then
        self.CastBarSpellName = self.CastBar:CreateFontString(CapitalizedUnit[unit] .. "_CastBarSpellName", "OVERLAY")
        self.CastBarSpellName:ClearAllPoints()
        self.CastBarSpellName:SetPoint(SpellName.AnchorFrom, self.CastBar, SpellName.AnchorTo, SpellName.OffsetX, SpellName.OffsetY)
        self.CastBarSpellName:SetFont(UUF.Media.Font, SpellName.FontSize, General.FontFlag)
        self.CastBarSpellName:SetShadowColor(General.FontShadows.SColour[1], General.FontShadows.SColour[2], General.FontShadows.SColour[3], General.FontShadows.SColour[4])
        self.CastBarSpellName:SetShadowOffset(General.FontShadows.OffsetX, General.FontShadows.OffsetY)
        self.CastBarSpellName:SetTextColor(SpellName.Colour[1], SpellName.Colour[2], SpellName.Colour[3], SpellName.Colour[4])
    end

    if not self.CastBarCastTime then
        self.CastBarCastTime = self.CastBar:CreateFontString(CapitalizedUnit[unit] .. "_CastBarCastTime", "OVERLAY")
        self.CastBarCastTime:ClearAllPoints()
        self.CastBarCastTime:SetPoint(CastTime.AnchorFrom, self.CastBar, CastTime.AnchorTo, CastTime.OffsetX, CastTime.OffsetY)
        self.CastBarCastTime:SetFont(UUF.Media.Font, CastTime.FontSize, General.FontFlag)
        self.CastBarCastTime:SetShadowColor(General.FontShadows.SColour[1], General.FontShadows.SColour[2], General.FontShadows.SColour[3], General.FontShadows.SColour[4])
        self.CastBarCastTime:SetShadowOffset(General.FontShadows.OffsetX, General.FontShadows.OffsetY)
        self.CastBarCastTime:SetTextColor(CastTime.Colour[1], CastTime.Colour[2], CastTime.Colour[3], CastTime.Colour[4])
    end

    if CastBar.Enabled then
        if not self:IsElementEnabled("Castbar") then self:EnableElement("Castbar") end
        self.Castbar = self.CastBar
        if CastBar.Icon.Enabled then
            self.Castbar.Icon = self.CastBarIcon
            if CastBar.Icon.Side == "LEFT" then
                self.CastBarIcon:SetPoint("LEFT", self.CastBarContainer, "LEFT", 1, 0)
                self.CastBG:ClearAllPoints()
                self.CastBG:SetPoint("LEFT", self.CastBarIcon, "RIGHT", 0, 0)
                self.CastBG:SetWidth(CastBar.Width - (self.CastBarIcon:GetWidth() + 2))
                self.CastBar:ClearAllPoints()
                self.CastBar:SetPoint("LEFT", self.CastBG, "LEFT", 0, 0)
                self.CastBar:SetWidth(CastBar.Width - (self.CastBarIcon:GetWidth() + 2))
            else
                self.CastBarIcon:SetPoint("RIGHT", self.CastBarContainer, "RIGHT", -1, 0)
                self.CastBG:ClearAllPoints()
                self.CastBG:SetPoint("RIGHT", self.CastBarIcon, "LEFT", 0, 0)
                self.CastBG:SetWidth(CastBar.Width - (self.CastBarIcon:GetWidth() + 2))
                self.CastBar:ClearAllPoints()
                self.CastBar:SetPoint("RIGHT", self.CastBG, "RIGHT", 0, 0)
                self.CastBar:SetWidth(CastBar.Width - (self.CastBarIcon:GetWidth() + 2))
            end
            self.CastBarIcon:Show()
        else
            self.Castbar.Icon = nil
            self.CastBarIcon:Hide()
            self.CastBG:ClearAllPoints()
            self.CastBG:SetPoint("TOPLEFT", self.CastBarContainer, "TOPLEFT", 1, -1)
            self.CastBG:SetSize(CastBar.Width - 2, CastBar.Height - 2)
            self.CastBar:ClearAllPoints()
            self.CastBar:SetPoint("TOPLEFT", self.CastBarContainer, "TOPLEFT", 1, -1)
        end
        self.Castbar.Text = self.CastBarSpellName
        self.Castbar.Time = self.CastBarCastTime
        if not self.CastBar.HookedCasts then
            self.Castbar:HookScript("OnValueChanged", function(castBar, value)
                local maxValue = castBar.max or select(2, castBar:GetMinMaxValues()) or 1
                self.CastBG:SetMinMaxValues(0, maxValue)
                self.CastBG:SetValue(maxValue - (value or 0))
            end)
            self.Castbar:HookScript("OnHide", function() self.CastBarContainer:Hide() end)
            self.Castbar.PostCastStart = function(castBar, unit)
                local spell = C_Spell.GetSpellInfo(castBar.spellID)
                if spell then
                    castBar.Text:SetText(spell.name)
                    UUF:ShortenText(castBar.Text, CastBar.Texts.SpellName.MaxChars)
                end

                local barColour = castBar.notInterruptible and CastBar.NotInterruptibleColour or CastBar.FGColour
                castBar:SetStatusBarColor(barColour[1], barColour[2], barColour[3], barColour[4])

                self.CastBarContainer:Show()
            end
            self.Castbar.CustomTimeText = function(bar, duration)
                if bar.channeling then
                    if duration < CastBar.Texts.CastTime.CriticalTime then
                        bar.Time:SetFormattedText("%.1f", duration)
                    else
                        bar.Time:SetFormattedText("%.0f", duration)
                    end
                else
                    if (bar.max - duration) < CastBar.Texts.CastTime.CriticalTime then
                        bar.Time:SetFormattedText("%.1f", bar.max - duration)
                    else
                        bar.Time:SetFormattedText("%.0f", bar.max - duration)
                    end
                end
            end
            self.CastBar.HookedCasts = true
        end
    else
        if self:IsElementEnabled("Castbar") then self:DisableElement("Castbar") end
        self.Castbar = nil
    end
end

local function CreateBuffs(self, unit)
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local Buffs = UUFDB[normalizedUnit].Buffs
    if not self.BuffContainer then
        self.BuffContainer = CreateFrame("Frame", CapitalizedUnit[unit] .. "_BuffsContainer", self)
        local buffPerRow = Buffs.Wrap or 4
        local buffRows = math.ceil(Buffs.Num / buffPerRow)
        local buffContainerWidth = (Buffs.Size + Buffs.Spacing) * buffPerRow - Buffs.Spacing
        local buffContainerHeight = (Buffs.Size + Buffs.Spacing) * buffRows - Buffs.Spacing
        self.BuffContainer:SetSize(buffContainerWidth, buffContainerHeight)
        self.BuffContainer:SetPoint(Buffs.AnchorFrom, self, Buffs.AnchorTo, Buffs.OffsetX, Buffs.OffsetY)
        self.BuffContainer.size = Buffs.Size
        self.BuffContainer.spacing = Buffs.Spacing
        self.BuffContainer.num = Buffs.Num
        self.BuffContainer.initialAnchor = Buffs.AnchorFrom
        self.BuffContainer.onlyShowPlayer = false
        self.BuffContainer["growth-x"] = Buffs.Growth
        self.BuffContainer["growth-y"] = Buffs.WrapDirection
        self.BuffContainer.filter = "HELPFUL"
        self.BuffContainer.PostCreateButton = function(_, button) UUF:StyleAuras(_, button, unit, "HELPFUL") end
        self.BuffContainer.FilterAura = UUF:FilterAuras("Buffs")
        self.BuffContainer.anchoredButtons = 0
        self.BuffContainer.createdButtons = 0

        if Buffs.Enabled then
            self.Buffs = self.BuffContainer
        else
            self.Buffs = nil
        end
    end
end

local function CreateDebuffs(self, unit)
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local Debuffs = UUFDB[normalizedUnit].Debuffs
    if not self.DebuffContainer then
        self.DebuffContainer = CreateFrame("Frame", CapitalizedUnit[unit] .. "_DebuffsContainer", self)
        local debuffPerRow = Debuffs.Wrap or 3
        local debuffRows = math.ceil(Debuffs.Num / debuffPerRow)
        local debuffContainerWidth = (Debuffs.Size + Debuffs.Spacing) * debuffPerRow - Debuffs.Spacing
        local debuffContainerHeight = (Debuffs.Size + Debuffs.Spacing) * debuffRows - Debuffs.Spacing
        self.DebuffContainer:SetSize(debuffContainerWidth, debuffContainerHeight)
        self.DebuffContainer:SetPoint(Debuffs.AnchorFrom, self, Debuffs.AnchorTo, Debuffs.OffsetX, Debuffs.OffsetY)
        self.DebuffContainer.size = Debuffs.Size
        self.DebuffContainer.spacing = Debuffs.Spacing
        self.DebuffContainer.num = Debuffs.Num
        self.DebuffContainer.initialAnchor = Debuffs.AnchorFrom
        self.DebuffContainer.onlyShowPlayer = false
        self.DebuffContainer["growth-x"] = Debuffs.Growth
        self.DebuffContainer["growth-y"] = Debuffs.WrapDirection
        self.DebuffContainer.filter = "HARMFUL"
        self.DebuffContainer.anchoredButtons = 0
        self.DebuffContainer.createdButtons = 0

        self.DebuffContainer.PostCreateButton = function(_, button) UUF:StyleAuras(_, button, unit, "HARMFUL") end
        if Debuffs.Enabled then
            self.Debuffs = self.DebuffContainer
            self.Debuffs.FilterAura = UUF:FilterAuras("Debuffs")
        else
            self.Debuffs = nil
        end
    end
end

local function CreateIndicators(self, unit)
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local Indicators = UUFDB[normalizedUnit].Indicators
    local RaidMarker = Indicators.RaidMarker
    local Leader = Indicators.Leader
    local Status = Indicators.Status
    local MouseoverHighlight = Indicators.MouseoverHighlight

    if not self.RaidMarker then
        self.RaidMarker = self.HighLevelContainer:CreateTexture(CapitalizedUnit[unit] .. "_RaidMarkerIndicator", "OVERLAY", nil, 7)
        self.RaidMarker:SetSize(RaidMarker.Size, RaidMarker.Size)
        self.RaidMarker:SetPoint(RaidMarker.AnchorFrom, self.HighLevelContainer, RaidMarker.AnchorTo, RaidMarker.OffsetX, RaidMarker.OffsetY)
    end

    if RaidMarker.Enabled then
        self.RaidTargetIndicator = self.RaidMarker
    else
        self.RaidTargetIndicator = nil
    end

    if Indicators.Leader then
        if not self.Leader then
            self.Leader = self.HighLevelContainer:CreateTexture(CapitalizedUnit[unit] .. "_LeaderIndicator", "OVERLAY")
            self.Leader:SetSize(Leader.Size, Leader.Size)
            self.Leader:SetPoint(Leader.AnchorFrom, self.HighLevelContainer, Leader.AnchorTo, Leader.OffsetX, Leader.OffsetY)
        end

        if not self.Assistant then
            self.Assistant = self.HighLevelContainer:CreateTexture(CapitalizedUnit[unit] .. "_AssistantIndicator", "OVERLAY")
            self.Assistant:SetSize(Leader.Size, Leader.Size)
            self.Assistant:SetPoint(Leader.AnchorFrom, self.HighLevelContainer, Leader.AnchorTo, Leader.OffsetX, Leader.OffsetY)
        end

        if Leader.Enabled then
            self.LeaderIndicator = self.Leader
            self.AssistantIndicator = self.Assistant
        else
            self.LeaderIndicator = nil
            self.AssistantIndicator = nil
        end
    end

    if Indicators.Status and (Indicators.Status.Combat or Indicators.Status.Resting) then
        if not self.Combat then
            self.Combat = self.HighLevelContainer:CreateTexture(CapitalizedUnit[unit].."_CombatIndicator", "OVERLAY")
            self.Combat:SetSize(Status.Size, Status.Size)
            self.Combat:SetPoint(Status.AnchorFrom, self.HighLevelContainer, Status.AnchorTo, Status.OffsetX, Status.OffsetY)
            self.Combat:Hide()
        end

        if not self.Resting then
            self.Resting = self.HighLevelContainer:CreateTexture(CapitalizedUnit[unit].."_RestingIndicator", "OVERLAY")
            self.Resting:SetSize(Status.Size, Status.Size)
            self.Resting:SetPoint(Status.AnchorFrom, self.HighLevelContainer, Status.AnchorTo, Status.OffsetX, Status.OffsetY)
            self.Resting:Hide()
        end

        if Status.Combat then
            self.CombatIndicator = self.Combat
            if Status.CombatTexture == "DEFAULT" then
                self.Combat:SetTexture([[Interface\CharacterFrame\UI-StateIcon]])
                self.Combat:SetTexCoord(0.5, 1, 0, 0.49)
            else
                self.Combat:SetTexture(UUF.StatusTextureMap[Status.CombatTexture])
                self.Combat:SetTexCoord(0, 1, 0, 1)
            end
            self.Combat:Show()
        end
        if Status.Resting then
            self.RestingIndicator = self.Resting
            if Status.RestingTexture == "DEFAULT" then
                self.Resting:SetTexture([[Interface\CharacterFrame\UI-StateIcon]])
                self.Resting:SetTexCoord(0, 0.5, 0, 0.421875)
            else
                self.Resting:SetTexture(UUF.StatusTextureMap[Status.RestingTexture])
                self.Resting:SetTexCoord(0, 1, 0, 1)
            end
            self.Resting:Show()
        end
    end

    if Indicators.Quest then
        local Quest = Indicators.Quest
        if not self.QuestIndicatorTexture then
            self.QuestIndicatorTexture = self.HighLevelContainer:CreateTexture(CapitalizedUnit[unit].."_QuestIndicator", "OVERLAY")
            self.QuestIndicatorTexture:SetSize(Quest.Size, Quest.Size)
            self.QuestIndicatorTexture:SetPoint(Quest.AnchorFrom, self.HighLevelContainer, Quest.AnchorTo, Quest.OffsetX, Quest.OffsetY)
        end
        if Quest.Enabled then
            self.QuestIndicator = self.QuestIndicatorTexture
        else
            self.QuestIndicator = nil
        end
    end

    if Indicators.TargetIndicator then
        local TargetIndicator = Indicators.TargetIndicator
        self.TargetIndicator = CreateFrame("Frame", CapitalizedUnit[unit].."_TargetIndicator", self.Container, "BackdropTemplate")
        self.TargetIndicator:SetFrameLevel(self.Container:GetFrameLevel() + 3)
        -- self.TargetIndicator:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1, insets = {left = 0, right = 0, top = 0, bottom = 0} })
        self.TargetIndicator:SetBackdrop({ edgeFile = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Glow.tga", edgeSize = 3, insets = {left = -6, right = -6, top = -6, bottom = -6} })
        self.TargetIndicator:SetBackdropColor(0, 0, 0, 0)
        self.TargetIndicator:SetBackdropBorderColor(TargetIndicator.Colour[1], TargetIndicator.Colour[2], TargetIndicator.Colour[3], TargetIndicator.Colour[4])
        self.TargetIndicator:SetPoint("TOPLEFT", self.Container, "TOPLEFT", -3, 3)
        self.TargetIndicator:SetPoint("BOTTOMRIGHT", self.Container, "BOTTOMRIGHT", 3, -3)
        self.TargetIndicator:Hide()
    end

    -- TODO:
    -- Resurrection.
    -- Phase.

    if not self.MouseoverHighlight then
        self.MouseoverHighlight = CreateFrame("Frame", CapitalizedUnit[unit].."_MouseoverHighlight", self.Container, "BackdropTemplate")
        self.MouseoverHighlight:SetFrameLevel(self.Container:GetFrameLevel() + 3)
        if MouseoverHighlight.Type == "BORDER" then
            self.MouseoverHighlight:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1, insets = {left = 0, right = 0, top = 0, bottom = 0} })
            self.MouseoverHighlight:SetBackdropColor(0, 0, 0, 0)
            self.MouseoverHighlight:SetBackdropBorderColor(MouseoverHighlight.Colour[1], MouseoverHighlight.Colour[2], MouseoverHighlight.Colour[3], MouseoverHighlight.Colour[4])
            self.MouseoverHighlight:SetPoint("TOPLEFT", self.Container, "TOPLEFT", 0, -0)
            self.MouseoverHighlight:SetPoint("BOTTOMRIGHT", self.Container, "BOTTOMRIGHT", -0, 0)
        elseif MouseoverHighlight.Type == "BACKGROUND" then
            self.MouseoverHighlight:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = nil, edgeSize = 0, insets = {left = 0, right = 0, top = 0, bottom = 0} })
            self.MouseoverHighlight:SetBackdropColor(MouseoverHighlight.Colour[1], MouseoverHighlight.Colour[2], MouseoverHighlight.Colour[3], MouseoverHighlight.Colour[4])
            self.MouseoverHighlight:SetBackdropBorderColor(0, 0, 0, 0)
            self.MouseoverHighlight:SetPoint("TOPLEFT", self.Container, "TOPLEFT", 1, -1)
            self.MouseoverHighlight:SetPoint("BOTTOMRIGHT", self.Container, "BOTTOMRIGHT", -1, 1)
        end
        self.MouseoverHighlight:Hide()
    end

    if Indicators.RoleIcons then
        if not self.RoleIcon then
            self.RoleIcon = self.HighLevelContainer:CreateTexture(CapitalizedUnit[unit] .. "_RoleIcon", "OVERLAY", nil, 6)
            self.RoleIcon:SetSize(Indicators.RoleIcons.Size, Indicators.RoleIcons.Size)
            self.RoleIcon:SetPoint(
                Indicators.RoleIcons.AnchorFrom,
                self.HighLevelContainer,
                Indicators.RoleIcons.AnchorTo,
                Indicators.RoleIcons.OffsetX,
                Indicators.RoleIcons.OffsetY
            )

            self.GroupRoleIndicator = self.RoleIcon

            self.GroupRoleIndicator.PostUpdate = function(_, role)
                if not Indicators.RoleIcons.Enabled then
                    self.RoleIcon:Hide()
                    return
                end

                local set = UUF.RoleTextureSets[Indicators.RoleIcons.RoleTextures]
                if role and role ~= "NONE" and set and set[role] then
                    self.RoleIcon:SetTexture(set[role])
                    if Indicators.RoleIcons.RoleTextures == "DEFAULT" then
                        if role == "TANK" then
                            self.RoleIcon:SetTexCoord(0, 19 / 64, 22 / 64, 41 / 64)
                        elseif role == "HEALER" then
                            self.RoleIcon:SetTexCoord(20 / 64, 39 / 64, 1 / 64, 20 / 64)
                        elseif role == "DAMAGER" then
                            self.RoleIcon:SetTexCoord(20 / 64, 39 / 64, 22 / 64, 41 / 64)
                        end
                    else
                        self.RoleIcon:SetTexCoord(0, 1, 0, 1)
                        self.RoleIcon:Show()
                    end
                else
                    self.RoleIcon:Hide()
                end
            end
        end
    end

    if Indicators.ReadyCheck then
        if not self.ReadyCheck then
            self.ReadyCheck = self.HighLevelContainer:CreateTexture(CapitalizedUnit[unit].."_ReadyCheckIndicator", "OVERLAY", nil, 7)
            self.ReadyCheck:SetSize(Indicators.ReadyCheck.Size, Indicators.ReadyCheck.Size)
            self.ReadyCheck:SetPoint(
                Indicators.ReadyCheck.AnchorFrom,
                self.HighLevelContainer,
                Indicators.ReadyCheck.AnchorTo,
                Indicators.ReadyCheck.OffsetX,
                Indicators.ReadyCheck.OffsetY
            )
            if UUF.db.profile[unit].Indicators.ReadyCheck.ReadyCheckTextures == "DEFAULT" then
                self.ReadyCheck.readyTexture = UUF.ReadyCheckTextureMap[UUF.db.profile[unit].Indicators.ReadyCheck.ReadyCheckTextures]["READY"]
                self.ReadyCheck.notReadyTexture = UUF.ReadyCheckTextureMap[UUF.db.profile[unit].Indicators.ReadyCheck.ReadyCheckTextures]["NOTREADY"]
                self.ReadyCheck.waitingTexture = UUF.ReadyCheckTextureMap[UUF.db.profile[unit].Indicators.ReadyCheck.ReadyCheckTextures]["WAITING"]
            else
                self.ReadyCheck.readyTexture = UUF.ReadyCheckTextureMap[UUF.db.profile[unit].Indicators.ReadyCheck.ReadyCheckTextures]["READY"]
                self.ReadyCheck.notReadyTexture = UUF.ReadyCheckTextureMap[UUF.db.profile[unit].Indicators.ReadyCheck.ReadyCheckTextures]["NOTREADY"]
                self.ReadyCheck.waitingTexture = UUF.ReadyCheckTextureMap[UUF.db.profile[unit].Indicators.ReadyCheck.ReadyCheckTextures]["WAITING"]
            end
        end
        if Indicators.ReadyCheck.Enabled then
            self.ReadyCheckIndicator = self.ReadyCheck
        else
            self.ReadyCheckIndicator = nil
        end
    end

    if Indicators.SummonIndicator then
        if not self.SummonIndicatorTexture then
            self.SummonIndicatorTexture = self.HighLevelContainer:CreateTexture(CapitalizedUnit[unit].."_SummonIndicator", "OVERLAY", nil, 7)
            self.SummonIndicatorTexture:SetSize(Indicators.SummonIndicator.Size, Indicators.SummonIndicator.Size)
            self.SummonIndicatorTexture:SetPoint(
                Indicators.SummonIndicator.AnchorFrom,
                self.HighLevelContainer,
                Indicators.SummonIndicator.AnchorTo,
                Indicators.SummonIndicator.OffsetX,
                Indicators.SummonIndicator.OffsetY
            )
        end
        if Indicators.SummonIndicator.Enabled then
            self.SummonIndicator = self.SummonIndicatorTexture
        else
            self.SummonIndicator = nil
        end
    end
end

local function CreatePortrait(self, unit)
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local Portrait = UUFDB[normalizedUnit].Portrait
    local AnchorParent = self.HighLevelContainer
    if not self.PortraitContainer then
        self.PortraitContainer = CreateFrame("Frame", CapitalizedUnit[unit] .. "_PortraitContainer", AnchorParent, "BackdropTemplate")
        self.PortraitContainer:SetBackdrop(UUF.BackdropTemplate)
        self.PortraitContainer:SetBackdropColor(0, 0, 0, 0)
        self.PortraitContainer:SetBackdropBorderColor(0, 0, 0, 1)
        self.PortraitContainer:SetSize(Portrait.Size, Portrait.Size)
        self.PortraitContainer:ClearAllPoints()
        self.PortraitContainer:SetPoint(Portrait.AnchorFrom, AnchorParent, Portrait.AnchorTo, Portrait.OffsetX, Portrait.OffsetY)
        if not self.PortraitTexture then
            self.PortraitTexture = self.PortraitContainer:CreateTexture(CapitalizedUnit[unit] .. "_PortraitTexture", "BACKGROUND")
            self.PortraitTexture:SetSize(self.PortraitContainer:GetHeight() - 2, self.PortraitContainer:GetHeight() - 2)
            self.PortraitTexture:SetPoint("CENTER", self.PortraitContainer, "CENTER", 0, 0)
            self.PortraitTexture:SetTexCoord((Portrait.Zoom or 0)*0.5, 1-(Portrait.Zoom or 0)*0.5, (Portrait.Zoom or 0)*0.5, 1-(Portrait.Zoom or 0)*0.5)
            if Portrait.Style == "CLASS" then
                self.PortraitTexture.showClass = true
            else
                self.PortraitTexture.showClass = false
            end
            self.Portrait = self.PortraitTexture
        end
    end

    if Portrait.Enabled then
        self.PortraitContainer:Show()
        self.Portrait = self.PortraitTexture
    else
        self.PortraitContainer:Hide()
        self.Portrait = nil
    end
end

local function CreateTags(self, unit)
    local UUFDB = UUF.db.profile
    local General = UUFDB.General
    local normalizedUnit = GetNormalizedUnit(unit)
    local Tags = UUFDB[normalizedUnit].Tags
    local AnchorParent = Tags.AnchorParent == "FRAME" and self.HighLevelContainer or self.HealthBar
    if not self.FirstTag then
        self.FirstTag = self.HighLevelContainer:CreateFontString(CapitalizedUnit[unit] .. "_FirstTag", "ARTWORK")
        self.FirstTag:SetFont(UUF.Media.Font, Tags["First"].FontSize, General.FontFlag)
        self.FirstTag:SetVertexColor(unpack(Tags["First"].Colour))
        self.FirstTag:SetShadowColor(General.FontShadows.SColour[1], General.FontShadows.SColour[2], General.FontShadows.SColour[3], General.FontShadows.SColour[4])
        self.FirstTag:SetShadowOffset(General.FontShadows.OffsetX, General.FontShadows.OffsetY)
        self.FirstTag:SetPoint(Tags["First"].AnchorFrom, AnchorParent, Tags["First"].AnchorTo, Tags["First"].OffsetX, Tags["First"].OffsetY)
        self.FirstTag:SetJustifyH(UUF:SetTextJustification(Tags["First"].AnchorTo))
        self:Tag(self.FirstTag, Tags["First"].Tag)
    end
    if not self.SecondTag then
        self.SecondTag = self.HighLevelContainer:CreateFontString(CapitalizedUnit[unit] .. "_SecondTag", "ARTWORK")
        self.SecondTag:SetFont(UUF.Media.Font, Tags["Second"].FontSize, General.FontFlag)
        self.SecondTag:SetVertexColor(unpack(Tags["Second"].Colour))
        self.SecondTag:SetShadowColor(General.FontShadows.SColour[1], General.FontShadows.SColour[2], General.FontShadows.SColour[3], General.FontShadows.SColour[4])
        self.SecondTag:SetShadowOffset(General.FontShadows.OffsetX, General.FontShadows.OffsetY)
        self.SecondTag:SetPoint(Tags["Second"].AnchorFrom, AnchorParent, Tags["Second"].AnchorTo, Tags["Second"].OffsetX, Tags["Second"].OffsetY)
        self.SecondTag:SetJustifyH(UUF:SetTextJustification(Tags["Second"].AnchorTo))
        self:Tag(self.SecondTag, Tags["Second"].Tag)
    end
    if not self.ThirdTag then
        self.ThirdTag = self.HighLevelContainer:CreateFontString(CapitalizedUnit[unit] .. "_ThirdTag", "ARTWORK")
        self.ThirdTag:SetFont(UUF.Media.Font, Tags["Third"].FontSize, General.FontFlag)
        self.ThirdTag:SetVertexColor(unpack(Tags["Third"].Colour))
        self.ThirdTag:SetShadowColor(General.FontShadows.SColour[1], General.FontShadows.SColour[2], General.FontShadows.SColour[3], General.FontShadows.SColour[4])
        self.ThirdTag:SetShadowOffset(General.FontShadows.OffsetX, General.FontShadows.OffsetY)
        self.ThirdTag:SetPoint(Tags["Third"].AnchorFrom, AnchorParent, Tags["Third"].AnchorTo, Tags["Third"].OffsetX, Tags["Third"].OffsetY)
        self.ThirdTag:SetJustifyH(UUF:SetTextJustification(Tags["Third"].AnchorTo))
        self:Tag(self.ThirdTag, Tags["Third"].Tag)
    end
    if not self.FourthTag then
        self.FourthTag = self.HighLevelContainer:CreateFontString(CapitalizedUnit[unit] .. "_FourthTag", "ARTWORK")
        self.FourthTag:SetFont(UUF.Media.Font, Tags["Fourth"].FontSize, General.FontFlag)
        self.FourthTag:SetVertexColor(unpack(Tags["Fourth"].Colour))
        self.FourthTag:SetShadowColor(General.FontShadows.SColour[1], General.FontShadows.SColour[2], General.FontShadows.SColour[3], General.FontShadows.SColour[4])
        self.FourthTag:SetShadowOffset(General.FontShadows.OffsetX, General.FontShadows.OffsetY)
        self.FourthTag:SetPoint(Tags["Fourth"].AnchorFrom, AnchorParent, Tags["Fourth"].AnchorTo, Tags["Fourth"].OffsetX, Tags["Fourth"].OffsetY)
        self.FourthTag:SetJustifyH(UUF:SetTextJustification(Tags["Fourth"].AnchorTo))
        self:Tag(self.FourthTag, Tags["Fourth"].Tag)
    end
end

local function ApplyScripts(self, unit)
    self:RegisterForClicks("AnyUp")
    self:SetAttribute("*type1", "target")
    self:SetAttribute("*type2", "togglemenu")
    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)
    self:HookScript("OnEnter", function()
        local isMouseoverEnabled = UUF.db.profile[unit].Indicators.MouseoverHighlight.Enabled
        if isMouseoverEnabled then self.MouseoverHighlight:Show() end
    end)
    self:HookScript("OnLeave", function()
        local isMouseoverEnabled = UUF.db.profile[unit].Indicators.MouseoverHighlight.Enabled
        if isMouseoverEnabled then self.MouseoverHighlight:Hide() end
    end)
end

local function UpdateTransparency(frameName, unit)
    if not unit or not frameName then return end
    local unitFrame = type(frameName) == "table" and frameName or _G[frameName]
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local Frame = UUFDB[normalizedUnit].Frame

    if unitFrame.HealthBG then
        local HBBG_R, HBBG_G, HBBG_B = unitFrame.HealthBG:GetStatusBarColor()
        unitFrame.HealthBG:SetStatusBarColor(HBBG_R, HBBG_G, HBBG_B, Frame.BGColour[4])
    end

    if unitFrame.HealthBar then
        local HB_R, HB_G, HB_B = unitFrame.HealthBar:GetStatusBarColor()
        unitFrame.HealthBar:SetStatusBarColor(HB_R, HB_G, HB_B, Frame.FGColour[4])
    end
end

local function UpdateColours(frameName, unit)
    if not unit or not frameName then return end
    local unitFrame = type(frameName) == "table" and frameName or _G[frameName]
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local Frame = UUFDB[normalizedUnit].Frame

    if unitFrame.HealthBG then
        unitFrame.HealthBG:SetStatusBarColor(Frame.BGColour[1], Frame.BGColour[2], Frame.BGColour[3], Frame.BGColour[4])
    end

    if unitFrame.HealthBar then
        unitFrame.HealthBar:SetStatusBarColor(Frame.FGColour[1], Frame.FGColour[2], Frame.FGColour[3], Frame.FGColour[4])
    end
end

local function UpdateHealthBar(frameName, unit)
    if not unit or not frameName then return end
    local unitFrame = type(frameName) == "table" and frameName or _G[frameName]
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local Frame = UUFDB[normalizedUnit].Frame
    local General = UUFDB.General
    if unitFrame.HealthBar then
        if unitFrame.HealthBG then
            unitFrame.HealthBG:SetSize(Frame.Width - 2, Frame.Height - 2)
            unitFrame.HealthBG:SetStatusBarTexture(UUF.Media.BackgroundTexture)
            unitFrame.HealthBG:SetStatusBarColor(Frame.BGColour[1], Frame.BGColour[2], Frame.BGColour[3], Frame.BGColour[4])
        end

        if unitFrame.HighLevelContainer then
            unitFrame.HighLevelContainer:ClearAllPoints()
            unitFrame.HighLevelContainer:SetSize(unitFrame:GetWidth(), unitFrame:GetHeight())
            unitFrame.HighLevelContainer:SetPoint("CENTER", 0, 0)
            unitFrame.HighLevelContainer:SetFrameLevel(999)
        end

        unitFrame.HealthBar:SetSize(Frame.Width - 2, Frame.Height - 2)
        unitFrame.HealthBar:SetStatusBarTexture(UUF.Media.ForegroundTexture)
        unitFrame.HealthBar:SetStatusBarColor(Frame.FGColour[1], Frame.FGColour[2], Frame.FGColour[3], Frame.FGColour[4])
        if unit == "pet" and Frame.ClassColour then
            local UnitClass = select(2, UnitClass("player"))
            local ClassColor = RAID_CLASS_COLORS[UnitClass]
            unitFrame.HealthBar:SetStatusBarColor(ClassColor.r, ClassColor.g, ClassColor.b)
        end
        unitFrame.HealthBar.colorClass = Frame.ClassColour
        unitFrame.HealthBar.colorReaction = Frame.ReactionColour
    end
end

local function UpdateHealthPrediction(frameName, unit)
    if not unit or not frameName then return end
    local unitFrame = type(frameName) == "table" and frameName or _G[frameName]
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local Absorb = UUFDB[normalizedUnit].HealPrediction.Absorb
    local HealAbsorb = UUFDB[normalizedUnit].HealPrediction.HealAbsorb
    local Frame = UUFDB[normalizedUnit].Frame
    local PowerBar = UUFDB[normalizedUnit].PowerBar
    local hasPowerBar = PowerBar and PowerBar.Enabled

    if unitFrame.AbsorbBar then
        unitFrame.AbsorbBar:SetStatusBarTexture(UUF.Media.ForegroundTexture)
        unitFrame.AbsorbBar:SetStatusBarColor(Absorb.Colour[1], Absorb.Colour[2], Absorb.Colour[3], Absorb.Colour[4])
        unitFrame.AbsorbBar:SetFrameLevel(unitFrame.Health:GetFrameLevel() + 1)
        unitFrame.AbsorbBar:SetOrientation(unitFrame.Health:GetOrientation() or "HORIZONTAL")
        unitFrame.AbsorbBar:SetWidth(unitFrame.HealthBar:GetWidth())
        unitFrame.AbsorbBar:ClearAllPoints()
        local yOffset = 0
        if hasPowerBar and PowerBar.Height then
            if Absorb.AnchorPoint == "BOTTOMLEFT" or Absorb.AnchorPoint == "BOTTOMRIGHT" then
                yOffset = 1
            elseif Absorb.AnchorPoint == "TOPLEFT" or Absorb.AnchorPoint == "TOPRIGHT" then
                yOffset = 0
            end
        end
        unitFrame.AbsorbBar:SetPoint(Absorb.AnchorPoint, unitFrame.HealthBar, Absorb.AnchorPoint, 0, yOffset)
        unitFrame.AbsorbBar:SetReverseFill((Absorb.AnchorPoint == "BOTTOMRIGHT" or Absorb.AnchorPoint == "TOPRIGHT") and true or false)
        local maxHeight = Frame.Height - (hasPowerBar and (PowerBar.Height + 3) or 2)
        local newHeight = math.min(Absorb.Height, maxHeight)
        unitFrame.AbsorbBar:SetHeight(newHeight)
    end

    if unitFrame.HealAbsorbBar then
        unitFrame.HealAbsorbBar:SetStatusBarTexture(UUF.Media.ForegroundTexture)
        unitFrame.HealAbsorbBar:SetStatusBarColor(unpack(HealAbsorb.Colour))
        unitFrame.HealAbsorbBar:SetFrameLevel(unitFrame.HealthBar:GetFrameLevel() + 1)
        unitFrame.HealAbsorbBar:SetOrientation("HORIZONTAL")
        unitFrame.HealAbsorbBar:ClearAllPoints()
        unitFrame.HealAbsorbBar:SetPoint("TOPRIGHT", unitFrame.HealthBar:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
        unitFrame.HealAbsorbBar:SetPoint("BOTTOMRIGHT", unitFrame.HealthBar:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
        unitFrame.HealAbsorbBar:SetWidth(unitFrame.HealthBar:GetWidth())
        unitFrame.HealAbsorbBar:SetReverseFill(true)
    end

    if Absorb.Enabled then
        unitFrame.HealthPrediction.absorbBar = unitFrame.AbsorbBar
        unitFrame.AbsorbBar:Show()
    else
        unitFrame.HealthPrediction.absorbBar = nil
        unitFrame.AbsorbBar:Hide()
    end

    if HealAbsorb.Enabled then
        unitFrame.HealAbsorbBar:SetStatusBarColor(
            HealAbsorb.Colour[1], HealAbsorb.Colour[2], HealAbsorb.Colour[3], HealAbsorb.Colour[4]
        )
        unitFrame.HealAbsorbBar:SetFrameLevel(unitFrame.Health:GetFrameLevel() + 1)
        unitFrame.HealthPrediction.healAbsorbBar = unitFrame.HealAbsorbBar
        unitFrame.HealAbsorbBar:Show()
    else
        unitFrame.HealthPrediction.healAbsorbBar = nil
        unitFrame.HealAbsorbBar:Hide()
    end

    if Absorb.Enabled or HealAbsorb.Enabled then
        if not unitFrame:IsElementEnabled("HealthPrediction") then
            unitFrame:EnableElement("HealthPrediction")
        end
    else
        if unitFrame:IsElementEnabled("HealthPrediction") then
            unitFrame:DisableElement("HealthPrediction")
        end
    end
    unitFrame.HealthPrediction:ForceUpdate()
end

local function UpdatePowerBar(frameName, unit)
    if not unit or not frameName then return end
    local unitFrame = type(frameName) == "table" and frameName or _G[frameName]
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local Frame = UUFDB[normalizedUnit].Frame
    local General = UUFDB.General

    if unitFrame.PowerBar then
        local PowerBar = UUFDB[normalizedUnit].PowerBar
        if unitFrame.PowerBarBG then
            unitFrame.PowerBarBG:SetSize(Frame.Width - 2, PowerBar.Height)
            unitFrame.PowerBarBG:SetStatusBarTexture(UUF.Media.BackgroundTexture)
            local BGColour = PowerBar.BGColour
            unitFrame.PowerBarBG:SetStatusBarColor(BGColour[1], BGColour[2], BGColour[3], BGColour[4])
        end

        unitFrame.PowerBar:SetSize(Frame.Width - 2, PowerBar.Height)
        unitFrame.PowerBar:SetStatusBarTexture(UUF.Media.ForegroundTexture)
        local FGColour = PowerBar.FGColour
        unitFrame.PowerBar:SetStatusBarColor(FGColour[1], FGColour[2], FGColour[3], FGColour[4])
        unitFrame.PowerBar.colorPower = PowerBar.ColourByType

        unitFrame.PowerBarBorder:ClearAllPoints()
        unitFrame.PowerBarBorder:SetSize(Frame.Width, PowerBar.Height + 2)
        unitFrame.PowerBarBorder:SetPoint("BOTTOMLEFT", unitFrame.PowerBar, "BOTTOMLEFT", -1, -1)
        unitFrame.PowerBarBorder:SetBackdrop(UUF.BackdropTemplate)
        unitFrame.PowerBarBorder:SetBackdropColor(0, 0, 0, 0)
        unitFrame.PowerBarBorder:SetBackdropBorderColor(0, 0, 0, 1)

        if PowerBar.Enabled then
            unitFrame.Power = unitFrame.PowerBar
            if not unitFrame:IsElementEnabled("Power") then unitFrame:EnableElement("Power") end
            unitFrame.HealthBG:SetHeight(Frame.Height - (unitFrame.PowerBar:GetHeight() + 2))
            unitFrame.HealthBar:SetHeight(Frame.Height - (unitFrame.PowerBar:GetHeight() + 2))
            unitFrame.PowerBar:Show()
            if unitFrame.PowerBarBG then unitFrame.PowerBarBG:Show() end
            if unitFrame.Power and unitFrame.Power.ForceUpdate then unitFrame.Power:ForceUpdate() end
        else
            if unitFrame:IsElementEnabled("Power") then unitFrame:DisableElement("Power") end
            unitFrame.HealthBG:SetHeight(Frame.Height - 2)
            unitFrame.HealthBar:SetHeight(Frame.Height - 2)
            unitFrame.PowerBar:Hide()
            if unitFrame.PowerBarBG then unitFrame.PowerBarBG:Hide() end
            unitFrame.Power = nil
        end
    end
end

local function UpdateCastBar(frameName, unit)
    if not unit or not frameName then return end
    local unitFrame = type(frameName) == "table" and frameName or _G[frameName]
    local UUFDB = UUF.db.profile
    local General = UUFDB.General
    local normalizedUnit = GetNormalizedUnit(unit)
    local CastBar = UUFDB[normalizedUnit].CastBar
    local SpellName = CastBar.Texts.SpellName
    local CastTime = CastBar.Texts.CastTime

    if unitFrame.CastBarContainer then
        unitFrame.CastBarContainer:ClearAllPoints()
        unitFrame.CastBarContainer:SetSize(CastBar.Width, CastBar.Height)
        unitFrame.CastBarContainer:SetPoint(CastBar.AnchorFrom, unitFrame, CastBar.AnchorTo, CastBar.OffsetX, CastBar.OffsetY)
        unitFrame.CastBarContainer:Hide()
    end

    if unitFrame.CastBar then
        if unitFrame.CastBG then
            unitFrame.CastBG:ClearAllPoints()
            unitFrame.CastBG:SetPoint("TOPLEFT", unitFrame.CastBarContainer, "TOPLEFT", 1, -1)
            unitFrame.CastBG:SetSize(CastBar.Width - 2, CastBar.Height - 2)
            unitFrame.CastBG:SetStatusBarTexture(UUF.Media.BackgroundTexture)
            unitFrame.CastBG:SetFrameLevel(unitFrame.CastBarContainer:GetFrameLevel() + 1)
            unitFrame.CastBG:SetStatusBarColor(CastBar.BGColour[1], CastBar.BGColour[2], CastBar.BGColour[3], CastBar.BGColour[4])
            unitFrame.CastBG:SetReverseFill(true)
            unitFrame.CastBG:Show()
        end
        unitFrame.CastBar:SetStatusBarTexture(UUF.Media.ForegroundTexture)
        unitFrame.CastBar:ClearAllPoints()
        unitFrame.CastBar:SetPoint("TOPLEFT", unitFrame.CastBarContainer, "TOPLEFT", 1, -1)
        unitFrame.CastBar:SetSize(CastBar.Width - 2, CastBar.Height - 2)
        unitFrame.CastBar:SetStatusBarColor(CastBar.FGColour[1], CastBar.FGColour[2], CastBar.FGColour[3], CastBar.FGColour[4])
    end

    if unitFrame.CastBarSpellName then
        unitFrame.CastBarSpellName:ClearAllPoints()
        unitFrame.CastBarSpellName:SetPoint(SpellName.AnchorFrom, unitFrame.CastBar, SpellName.AnchorTo, SpellName.OffsetX, SpellName.OffsetY)
        unitFrame.CastBarSpellName:SetFont(UUF.Media.Font, SpellName.FontSize, General.FontFlag)
        unitFrame.CastBarSpellName:SetShadowColor(General.FontShadows.SColour[1], General.FontShadows.SColour[2], General.FontShadows.SColour[3], General.FontShadows.SColour[4])
        unitFrame.CastBarSpellName:SetShadowOffset(General.FontShadows.OffsetX, General.FontShadows.OffsetY)
        unitFrame.CastBarSpellName:SetTextColor(SpellName.Colour[1], SpellName.Colour[2], SpellName.Colour[3], SpellName.Colour[4])
    end

    if unitFrame.CastBarCastTime then
        unitFrame.CastBarCastTime:ClearAllPoints()
        unitFrame.CastBarCastTime:SetPoint(CastTime.AnchorFrom, unitFrame.CastBar, CastTime.AnchorTo, CastTime.OffsetX, CastTime.OffsetY)
        unitFrame.CastBarCastTime:SetFont(UUF.Media.Font, CastTime.FontSize, General.FontFlag)
        unitFrame.CastBarCastTime:SetShadowColor(General.FontShadows.SColour[1], General.FontShadows.SColour[2], General.FontShadows.SColour[3], General.FontShadows.SColour[4])
        unitFrame.CastBarCastTime:SetShadowOffset(General.FontShadows.OffsetX, General.FontShadows.OffsetY)
        unitFrame.CastBarCastTime:SetTextColor(CastTime.Colour[1], CastTime.Colour[2], CastTime.Colour[3], CastTime.Colour[4])

    end

    if CastBar.Enabled then
        unitFrame.Castbar = unitFrame.CastBar
        if not unitFrame:IsElementEnabled("Castbar") then unitFrame:EnableElement("Castbar") end
        if CastBar.Icon.Enabled then
            unitFrame.Castbar.Icon = unitFrame.CastBarIcon
            if CastBar.Icon.Side == "LEFT" then
                unitFrame.CastBarIcon:ClearAllPoints()
                unitFrame.CastBarIcon:SetPoint("LEFT", unitFrame.CastBarContainer, "LEFT", 1, 0)
                unitFrame.CastBarIcon:SetSize(CastBar.Height - 2, CastBar.Height - 2)
                unitFrame.CastBG:ClearAllPoints()
                unitFrame.CastBG:SetPoint("LEFT", unitFrame.CastBarIcon, "RIGHT", 0, 0)
                unitFrame.CastBG:SetWidth(CastBar.Width - (unitFrame.CastBarIcon:GetWidth() + 2))
                unitFrame.CastBar:ClearAllPoints()
                unitFrame.CastBar:SetPoint("LEFT", unitFrame.CastBG, "LEFT", 0, 0)
                unitFrame.CastBar:SetWidth(CastBar.Width - (unitFrame.CastBarIcon:GetWidth() + 2))
            else
                unitFrame.CastBarIcon:ClearAllPoints()
                unitFrame.CastBarIcon:SetPoint("RIGHT", unitFrame.CastBarContainer, "RIGHT", -1, 0)
                unitFrame.CastBarIcon:SetSize(CastBar.Height - 2, CastBar.Height - 2)
                unitFrame.CastBG:ClearAllPoints()
                unitFrame.CastBG:SetPoint("RIGHT", unitFrame.CastBarIcon, "LEFT", 0, 0)
                unitFrame.CastBG:SetWidth(CastBar.Width - (unitFrame.CastBarIcon:GetWidth() + 2))
                unitFrame.CastBar:ClearAllPoints()
                unitFrame.CastBar:SetPoint("RIGHT", unitFrame.CastBG, "RIGHT", 0, 0)
                unitFrame.CastBar:SetWidth(CastBar.Width - (unitFrame.CastBarIcon:GetWidth() + 2))
            end
            unitFrame.CastBarIcon:Show()
        else
            unitFrame.Castbar.Icon = nil
            unitFrame.CastBarIcon:Hide()
            unitFrame.CastBG:ClearAllPoints()
            unitFrame.CastBG:SetPoint("TOPLEFT", unitFrame.CastBarContainer, "TOPLEFT", 1, -1)
            unitFrame.CastBG:SetSize(CastBar.Width - 2, CastBar.Height - 2)
            unitFrame.CastBar:ClearAllPoints()
            unitFrame.CastBar:SetPoint("TOPLEFT", unitFrame.CastBarContainer, "TOPLEFT", 1, -1)
        end
        unitFrame.Castbar.Text = unitFrame.CastBarSpellName
        unitFrame.Castbar.Time = unitFrame.CastBarCastTime
        if not unitFrame.CastBar.HookedCasts then
            unitFrame.Castbar:HookScript("OnValueChanged", function(castBar, value)
                local maxValue = castBar.max or select(2, castBar:GetMinMaxValues()) or 1
                unitFrame.CastBG:SetMinMaxValues(0, maxValue)
                unitFrame.CastBG:SetValue(maxValue - (value or 0))
            end)
            unitFrame.Castbar:HookScript("OnHide", function() unitFrame.CastBarContainer:Hide() end)
            unitFrame.Castbar.PostCastStart = function(castBar, unit)
                local spell = C_Spell.GetSpellInfo(castBar.spellID)
                if spell then
                    castBar.Text:SetText(spell.name)
                    UUF:ShortenText(castBar.Text, CastBar.Texts.SpellName.MaxChars)
                end

                local barColour = castBar.notInterruptible and CastBar.NotInterruptibleColour or CastBar.FGColour
                castBar:SetStatusBarColor(barColour[1], barColour[2], barColour[3], barColour[4])

                unitFrame.CastBarContainer:Show()
            end
            unitFrame.Castbar.CustomTimeText = function(bar, duration)
                if bar.channeling then
                    if duration < CastBar.Texts.CastTime.CriticalTime then
                        bar.Time:SetFormattedText("%.1f", duration)
                    else
                        bar.Time:SetFormattedText("%.0f", duration)
                    end
                else
                    if (bar.max - duration) < CastBar.Texts.CastTime.CriticalTime then
                        bar.Time:SetFormattedText("%.1f", bar.max - duration)
                    else
                        bar.Time:SetFormattedText("%.0f", bar.max - duration)
                    end
                end
            end
            unitFrame.CastBar.HookedCasts = true
        end
    else
        if unitFrame:IsElementEnabled("Castbar") then unitFrame:DisableElement("Castbar") end
        unitFrame.Castbar = nil
    end
end

local function UpdateAuras(frameName, unit)
    if not unit or not frameName then return end
    local unitFrame = type(frameName) == "table" and frameName or _G[frameName]
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local Buffs = UUFDB[normalizedUnit].Buffs
    local Debuffs = UUFDB[normalizedUnit].Debuffs

    if Buffs.Enabled then
        unitFrame.Buffs = unitFrame.BuffContainer
        if not unitFrame:IsElementEnabled("Auras") then unitFrame:EnableElement("Auras") end
        local buffPerRow = Buffs.Wrap or 4
        local buffRows = math.ceil(Buffs.Num / buffPerRow)
        local buffContainerWidth = (Buffs.Size + Buffs.Spacing) * buffPerRow - Buffs.Spacing
        local buffContainerHeight = (Buffs.Size + Buffs.Spacing) * buffRows - Buffs.Spacing
        unitFrame.BuffContainer:ClearAllPoints()
        unitFrame.BuffContainer:SetSize(buffContainerWidth, buffContainerHeight)
        unitFrame.BuffContainer:SetPoint(Buffs.AnchorFrom, unitFrame, Buffs.AnchorTo, Buffs.OffsetX, Buffs.OffsetY)
        unitFrame.BuffContainer.size = Buffs.Size
        unitFrame.BuffContainer.spacing = Buffs.Spacing
        unitFrame.BuffContainer.num = Buffs.Num
        unitFrame.BuffContainer.initialAnchor = Buffs.AnchorFrom
        unitFrame.BuffContainer.onlyShowPlayer = false
        unitFrame.BuffContainer["growth-x"] = Buffs.Growth
        unitFrame.BuffContainer["growth-y"] = Buffs.WrapDirection
        unitFrame.BuffContainer.filter = "HELPFUL"
        unitFrame.BuffContainer.createdButtons = unitFrame.Buffs.createdButtons or 0
        unitFrame.BuffContainer.anchoredButtons = unitFrame.Buffs.anchoredButtons or 0
        unitFrame.BuffContainer.PostCreateButton = function(_, button) UUF:StyleAuras(_, button, unit, "HELPFUL") end
        unitFrame.Buffs.FilterAura = UUF:FilterAuras("Buffs")
        unitFrame.BuffContainer:Show()
        if unitFrame.BuffContainer and unitFrame.BuffContainer.ForceUpdate then unitFrame.BuffContainer:ForceUpdate() end
    else
        if unitFrame:IsElementEnabled("Auras") then unitFrame:DisableElement("Auras") end
        unitFrame.BuffContainer:Hide()
        unitFrame.Buffs = nil
    end

    if Debuffs.Enabled then
        unitFrame.Debuffs = unitFrame.DebuffContainer
        if not unitFrame:IsElementEnabled("Auras") then unitFrame:EnableElement("Auras") end
        local debuffPerRow = Debuffs.Wrap or 4
        local debuffRows = math.ceil(Debuffs.Num / debuffPerRow)
        local debuffContainerWidth = (Debuffs.Size + Debuffs.Spacing) * debuffPerRow - Debuffs.Spacing
        local debuffContainerHeight = (Debuffs.Size + Debuffs.Spacing) * debuffRows - Debuffs.Spacing
        unitFrame.DebuffContainer:ClearAllPoints()
        unitFrame.DebuffContainer:SetSize(debuffContainerWidth, debuffContainerHeight)
        unitFrame.DebuffContainer:SetPoint(Debuffs.AnchorFrom, unitFrame, Debuffs.AnchorTo, Debuffs.OffsetX, Debuffs.OffsetY)
        unitFrame.DebuffContainer.size = Debuffs.Size
        unitFrame.DebuffContainer.spacing = Debuffs.Spacing
        unitFrame.DebuffContainer.num = Debuffs.Num
        unitFrame.DebuffContainer.initialAnchor = Debuffs.AnchorFrom
        unitFrame.DebuffContainer.onlyShowPlayer = false
        unitFrame.DebuffContainer["growth-x"] = Debuffs.Growth
        unitFrame.DebuffContainer["growth-y"] = Debuffs.WrapDirection
        unitFrame.DebuffContainer.filter = "HARMFUL"
        unitFrame.DebuffContainer.createdButtons = unitFrame.Debuffs.createdButtons or 0
        unitFrame.DebuffContainer.anchoredButtons = unitFrame.Debuffs.anchoredButtons or 0
        unitFrame.DebuffContainer.PostCreateButton = function(_, button) UUF:StyleAuras(_, button, unit, "HARMFUL") end
        unitFrame.Debuffs.FilterAura = UUF:FilterAuras("Debuffs")
        unitFrame.DebuffContainer:Show()
        if unitFrame.DebuffContainer and unitFrame.DebuffContainer.ForceUpdate then unitFrame.DebuffContainer:ForceUpdate() end
    else
        if unitFrame:IsElementEnabled("Auras") then unitFrame:DisableElement("Auras") end
        unitFrame.DebuffContainer:Hide()
        unitFrame.Debuffs = nil
    end

    if Buffs.Enabled or Debuffs.Enabled then
        if not unitFrame:IsElementEnabled("Auras") then unitFrame:EnableElement("Auras") end
    else
        if unitFrame:IsElementEnabled("Auras") then unitFrame:DisableElement("Auras") end
    end

    for _, button in ipairs(unitFrame.BuffContainer) do
        if button and button:IsShown() then
            UUF:RestyleAuras(_, button, normalizedUnit, "HELPFUL")
        end
    end
    for _, button in ipairs(unitFrame.DebuffContainer) do
        if button and button:IsShown() then
            UUF:RestyleAuras(_, button, normalizedUnit, "HARMFUL")
        end
    end
end

local function UpdateIndicators(frameName, unit)
    if not unit or not frameName then return end
    local unitFrame = type(frameName) == "table" and frameName or _G[frameName]
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local Indicators = UUFDB[normalizedUnit].Indicators
    local RaidMarker = Indicators.RaidMarker
    local Leader = Indicators.Leader
    local Status = Indicators.Status
    local Quest = Indicators.Quest
    local MouseoverHighlight = Indicators.MouseoverHighlight

    if unitFrame.RaidMarker then
        unitFrame.RaidMarker:ClearAllPoints()
        unitFrame.RaidMarker:SetSize(RaidMarker.Size, RaidMarker.Size)
        unitFrame.RaidMarker:SetPoint(RaidMarker.AnchorFrom, unitFrame.HighLevelContainer, RaidMarker.AnchorTo, RaidMarker.OffsetX, RaidMarker.OffsetY)
        if RaidMarker.Enabled then
            unitFrame.RaidTargetIndicator = unitFrame.RaidMarker
            if not unitFrame:IsElementEnabled("RaidTargetIndicator") then
                unitFrame:EnableElement("RaidTargetIndicator")
            end
        else
            if unitFrame:IsElementEnabled("RaidTargetIndicator") then
                unitFrame:DisableElement("RaidTargetIndicator")
            end
            unitFrame.RaidMarker:Hide()
            unitFrame.RaidTargetIndicator = nil
        end
    end

    if unitFrame.Leader then
        unitFrame.Leader:ClearAllPoints()
        unitFrame.Leader:SetSize(Leader.Size, Leader.Size)
        unitFrame.Leader:SetPoint(Leader.AnchorFrom, unitFrame.HighLevelContainer, Leader.AnchorTo, Leader.OffsetX, Leader.OffsetY)
        if Leader.Enabled then
            unitFrame.LeaderIndicator = unitFrame.Leader
            if not unitFrame:IsElementEnabled("LeaderIndicator") then
                unitFrame:EnableElement("LeaderIndicator")
            end
        else
            if unitFrame:IsElementEnabled("LeaderIndicator") then
                unitFrame:DisableElement("LeaderIndicator")
            end
            unitFrame.Leader:Hide()
            unitFrame.LeaderIndicator = nil
        end
    end

    if unitFrame.Assistant then
        unitFrame.Assistant:ClearAllPoints()
        unitFrame.Assistant:SetSize(Leader.Size, Leader.Size)
        unitFrame.Assistant:SetPoint(Leader.AnchorFrom, unitFrame.HighLevelContainer, Leader.AnchorTo, Leader.OffsetX, Leader.OffsetY)
        if Leader.Enabled then
            unitFrame.AssistantIndicator = unitFrame.Assistant
            if not unitFrame:IsElementEnabled("AssistantIndicator") then
                unitFrame:EnableElement("AssistantIndicator")
            end
        else
            if unitFrame:IsElementEnabled("AssistantIndicator") then
                unitFrame:DisableElement("AssistantIndicator")
            end
            unitFrame.Assistant:Hide()
            unitFrame.AssistantIndicator = nil
        end
    end

    if unitFrame.Combat then
        unitFrame.Combat:ClearAllPoints()
        unitFrame.Combat:SetSize(Status.Size, Status.Size)
        unitFrame.Combat:SetPoint(Status.AnchorFrom, unitFrame.HighLevelContainer, Status.AnchorTo, Status.OffsetX, Status.OffsetY)
        if Status.Combat then
            if Status.CombatTexture == "DEFAULT" then
                unitFrame.Combat:SetTexture([[Interface\CharacterFrame\UI-StateIcon]])
                unitFrame.Combat:SetTexCoord(0.5, 1, 0, 0.49)
            else
                unitFrame.Combat:SetTexture(UUF.StatusTextureMap[Status.CombatTexture])
                unitFrame.Combat:SetTexCoord(0, 1, 0, 1)
            end
            unitFrame.CombatIndicator = Status.Combat and unitFrame.Combat or nil
            if not unitFrame:IsElementEnabled("CombatIndicator") then
                unitFrame:EnableElement("CombatIndicator")
            end
        else
            if unitFrame:IsElementEnabled("CombatIndicator") then
                unitFrame:DisableElement("CombatIndicator")
            end
            unitFrame.Combat:Hide()
            unitFrame.CombatIndicator = nil
        end
    end

    if unitFrame.Resting then
        unitFrame.Resting:ClearAllPoints()
        unitFrame.Resting:SetSize(Status.Size, Status.Size)
        unitFrame.Resting:SetPoint(Status.AnchorFrom, unitFrame.HighLevelContainer, Status.AnchorTo, Status.OffsetX, Status.OffsetY)
        if Status.Resting then
            if Status.RestingTexture == "DEFAULT" then
                unitFrame.Resting:SetTexture([[Interface\CharacterFrame\UI-StateIcon]])
                unitFrame.Resting:SetTexCoord(0, 0.5, 0, 0.421875)
            else
                unitFrame.Resting:SetTexture(UUF.StatusTextureMap[Status.RestingTexture])
                unitFrame.Resting:SetTexCoord(0, 1, 0, 1)
            end
            unitFrame.RestingIndicator = Status.Resting and unitFrame.Resting or nil
            if not unitFrame:IsElementEnabled("RestingIndicator") then
                unitFrame:EnableElement("RestingIndicator")
            end
        else
            if unitFrame:IsElementEnabled("RestingIndicator") then
                unitFrame:DisableElement("RestingIndicator")
            end
            unitFrame.Resting:Hide()
            unitFrame.RestingIndicator = nil
        end
    end

    if unitFrame.MouseoverHighlight then
        unitFrame.MouseoverHighlight:ClearAllPoints()
        if MouseoverHighlight.Type == "BORDER" then
            unitFrame.MouseoverHighlight:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1, insets = {left = 0, right = 0, top = 0, bottom = 0} })
            unitFrame.MouseoverHighlight:SetBackdropColor(0, 0, 0, 0)
            unitFrame.MouseoverHighlight:SetBackdropBorderColor(MouseoverHighlight.Colour[1], MouseoverHighlight.Colour[2], MouseoverHighlight.Colour[3], MouseoverHighlight.Colour[4])
            unitFrame.MouseoverHighlight:SetPoint("TOPLEFT", unitFrame.Container, "TOPLEFT", 0, -0)
            unitFrame.MouseoverHighlight:SetPoint("BOTTOMRIGHT", unitFrame.Container, "BOTTOMRIGHT", -0, 0)
        elseif MouseoverHighlight.Type == "BACKGROUND" then
            unitFrame.MouseoverHighlight:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = nil, edgeSize = 0, insets = {left = 0, right = 0, top = 0, bottom = 0} })
            unitFrame.MouseoverHighlight:SetBackdropColor(MouseoverHighlight.Colour[1], MouseoverHighlight.Colour[2], MouseoverHighlight.Colour[3], MouseoverHighlight.Colour[4])
            unitFrame.MouseoverHighlight:SetBackdropBorderColor(0, 0, 0, 0)
            unitFrame.MouseoverHighlight:SetPoint("TOPLEFT", unitFrame.Container, "TOPLEFT", 1, -1)
            unitFrame.MouseoverHighlight:SetPoint("BOTTOMRIGHT", unitFrame.Container, "BOTTOMRIGHT", -1, 1)
        end
    end

    if unitFrame.QuestIndicatorTexture then
        unitFrame.QuestIndicatorTexture:ClearAllPoints()
        unitFrame.QuestIndicatorTexture:SetSize(Quest.Size, Quest.Size)
        unitFrame.QuestIndicatorTexture:SetPoint(Quest.AnchorFrom, unitFrame.HighLevelContainer, Quest.AnchorTo, Quest.OffsetX, Quest.OffsetY)
        if Quest.Enabled then
            unitFrame.QuestIndicator = unitFrame.QuestIndicatorTexture
            if not unitFrame:IsElementEnabled("QuestIndicator") then
                unitFrame:EnableElement("QuestIndicator")
            end
        else
            if unitFrame:IsElementEnabled("QuestIndicator") then
                unitFrame:DisableElement("QuestIndicator")
            end
            unitFrame.QuestIndicatorTexture:Hide()
            unitFrame.QuestIndicator = nil
        end
    end

    if unitFrame.RoleIcon then
        local RoleIcons = Indicators.RoleIcons
        unitFrame.RoleIcon:ClearAllPoints()
        unitFrame.RoleIcon:SetSize(RoleIcons.Size, RoleIcons.Size)
        unitFrame.RoleIcon:SetPoint(
            RoleIcons.AnchorFrom,
            unitFrame.HighLevelContainer,
            RoleIcons.AnchorTo,
            RoleIcons.OffsetX,
            RoleIcons.OffsetY
        )

        if RoleIcons.Enabled then
            local set = UUF.RoleTextureSets[RoleIcons.RoleTextures]
            local role = UnitGroupRolesAssigned(unit)
            if role and role ~= "NONE" and set and set[role] then
                unitFrame.RoleIcon:SetTexture(set[role])
                if RoleIcons.RoleTextures == "DEFAULT" then
                    if role == "TANK" then
                        unitFrame.RoleIcon:SetTexCoord(0, 19 / 64, 22 / 64, 41 / 64)
                    elseif role == "HEALER" then
                        unitFrame.RoleIcon:SetTexCoord(20 / 64, 39 / 64, 1 / 64, 20 / 64)
                    elseif role == "DAMAGER" then
                        unitFrame.RoleIcon:SetTexCoord(20 / 64, 39 / 64, 22 / 64, 41 / 64)
                    end
                else
                    unitFrame.RoleIcon:SetTexCoord(0, 1, 0, 1)
                end
                unitFrame.RoleIcon:Show()
            else
                unitFrame.RoleIcon:Hide()
            end
        else
            unitFrame.RoleIcon:Hide()
        end
    end

    if unitFrame.ReadyCheck then
        local ReadyCheck = Indicators.ReadyCheck
        unitFrame.ReadyCheck:ClearAllPoints()
        unitFrame.ReadyCheck:SetSize(ReadyCheck.Size, ReadyCheck.Size)
        unitFrame.ReadyCheck:SetPoint(ReadyCheck.AnchorFrom, unitFrame.HighLevelContainer, ReadyCheck.AnchorTo, ReadyCheck.OffsetX, ReadyCheck.OffsetY)
        if UUF.db.profile[normalizedUnit].Indicators.ReadyCheck.ReadyCheckTextures == "DEFAULT" then
            unitFrame.ReadyCheck.readyTexture = UUF.ReadyCheckTextureMap[UUF.db.profile[normalizedUnit].Indicators.ReadyCheck.ReadyCheckTextures]["READY"]
            unitFrame.ReadyCheck.notReadyTexture = UUF.ReadyCheckTextureMap[UUF.db.profile[normalizedUnit].Indicators.ReadyCheck.ReadyCheckTextures]["NOTREADY"]
            unitFrame.ReadyCheck.waitingTexture = UUF.ReadyCheckTextureMap[UUF.db.profile[normalizedUnit].Indicators.ReadyCheck.ReadyCheckTextures]["WAITING"]
        else
            unitFrame.ReadyCheck.readyTexture = UUF.ReadyCheckTextureMap[UUF.db.profile[normalizedUnit].Indicators.ReadyCheck.ReadyCheckTextures]["READY"]
            unitFrame.ReadyCheck.notReadyTexture = UUF.ReadyCheckTextureMap[UUF.db.profile[normalizedUnit].Indicators.ReadyCheck.ReadyCheckTextures]["NOTREADY"]
            unitFrame.ReadyCheck.waitingTexture = UUF.ReadyCheckTextureMap[UUF.db.profile[normalizedUnit].Indicators.ReadyCheck.ReadyCheckTextures]["WAITING"]
        end
        if ReadyCheck.Enabled then
            unitFrame.ReadyCheckIndicator = unitFrame.ReadyCheck
            if not unitFrame:IsElementEnabled("ReadyCheckIndicator") then
                unitFrame:EnableElement("ReadyCheckIndicator")
            end
        else
            if unitFrame:IsElementEnabled("ReadyCheckIndicator") then
                unitFrame:DisableElement("ReadyCheckIndicator")
            end
            unitFrame.ReadyCheck:Hide()
            unitFrame.ReadyCheckIndicator = nil
        end
    end

    if unitFrame.TargetIndicator then
        local TargetIndicator = Indicators.TargetIndicator
        unitFrame.TargetIndicator:SetBackdropColor(0, 0, 0, 0)
        unitFrame.TargetIndicator:SetBackdropBorderColor(TargetIndicator.Colour[1], TargetIndicator.Colour[2], TargetIndicator.Colour[3], TargetIndicator.Colour[4])
        if not TargetIndicator.Enabled then
            unitFrame.TargetIndicator:Hide()
        end
    end

    if unitFrame.SummonIndicatorTexture then
        local SummonIndicator = Indicators.SummonIndicator
        unitFrame.SummonIndicatorTexture:ClearAllPoints()
        unitFrame.SummonIndicatorTexture:SetSize(SummonIndicator.Size, SummonIndicator.Size)
        unitFrame.SummonIndicatorTexture:SetPoint(SummonIndicator.AnchorFrom, unitFrame.HighLevelContainer, SummonIndicator.AnchorTo, SummonIndicator.OffsetX, SummonIndicator.OffsetY)
        if SummonIndicator.Enabled then
            unitFrame.SummonIndicator = unitFrame.SummonIndicatorTexture
            if not unitFrame:IsElementEnabled("SummonIndicator") then
                unitFrame:EnableElement("SummonIndicator")
            end
        else
            if unitFrame:IsElementEnabled("SummonIndicator") then
                unitFrame:DisableElement("SummonIndicator")
            end
            unitFrame.Summon:Hide()
            unitFrame.SummonIndicator = nil
        end
    end
end

local function UpdatePortrait(frameName, unit)
    if not unit or not frameName then return end
    local unitFrame = type(frameName) == "table" and frameName or _G[frameName]
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local Portrait = UUFDB[normalizedUnit].Portrait
    if unitFrame.PortraitContainer then
        unitFrame.PortraitContainer:ClearAllPoints()
        unitFrame.PortraitContainer:SetSize(Portrait.Size, Portrait.Size)
        unitFrame.PortraitContainer:SetPoint(Portrait.AnchorFrom, unitFrame, Portrait.AnchorTo, Portrait.OffsetX, Portrait.OffsetY)
        if unitFrame.PortraitTexture then
            unitFrame.PortraitTexture:ClearAllPoints()
            unitFrame.PortraitTexture:SetSize(unitFrame.PortraitContainer:GetHeight() - 2, unitFrame.PortraitContainer:GetHeight() - 2)
            unitFrame.PortraitTexture:SetPoint("CENTER", unitFrame.PortraitContainer, "CENTER", 0, 0)
            unitFrame.PortraitTexture:SetTexCoord((Portrait.Zoom or 0)*0.5, 1-(Portrait.Zoom or 0)*0.5, (Portrait.Zoom or 0)*0.5, 1-(Portrait.Zoom or 0)*0.5)
            if Portrait.Style == "CLASS" then
                unitFrame.PortraitTexture.showClass = true
            else
                unitFrame.PortraitTexture.showClass = false
            end
            unitFrame.Portrait = unitFrame.PortraitTexture
        end
    end

    if Portrait.Enabled then
        unitFrame.Portrait = unitFrame.PortraitTexture
        if not unitFrame:IsElementEnabled("Portrait") then unitFrame:EnableElement("Portrait") end
        unitFrame.PortraitContainer:Show()
    else
        if unitFrame:IsElementEnabled("Portrait") then unitFrame:DisableElement("Portrait") end
        unitFrame.PortraitContainer:Hide()
        unitFrame.Portrait = nil
    end
end

local function UpdateRange(frameName, unit)
    if not unit or not frameName then return end
    local unitFrame = type(frameName) == "table" and frameName or _G[frameName]
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    if UUFDB[normalizedUnit].Range and UUFDB[normalizedUnit].Range.Enabled then
        unitFrame.__RangeAlphaSettings = UUFDB[normalizedUnit].Range
    else
        unitFrame.__RangeAlphaSettings = nil
    end
    UUF:UpdateRangeAlpha(unitFrame, unit)
end

local function UpdateTags(frameName, unit)
    if not unit or not frameName then return end
    local unitFrame = type(frameName) == "table" and frameName or _G[frameName]
    local UUFDB = UUF.db.profile
    local General = UUFDB.General
    local normalizedUnit = GetNormalizedUnit(unit)
    local Tags = UUFDB[normalizedUnit].Tags
    local HighLevelContainer = unitFrame.HighLevelContainer
    local AnchorParent = Tags.AnchorParent == "FRAME" and HighLevelContainer or unitFrame.HealthBar

    local function NudgeFont(fontString)
        if not fontString or fontString:GetNumPoints() == 0 then return end
        local point, relativeTo, relPoint, xPos, yPos = fontString:GetPoint(1)
        local sx, sy = fontString:GetShadowOffset()
        fontString:ClearAllPoints()
        fontString:SetPoint(point, relativeTo, relPoint, xPos + 0.5, yPos - 0.5)
        fontString:SetPoint(point, relativeTo, relPoint, xPos, yPos)
        fontString:SetShadowOffset(sx + 0.01, sy + 0.01)
        fontString:SetShadowOffset(sx, sy)
    end

    local function UpdateTag(dbKey, unitKey)
        local keyValue = Tags[dbKey]
        local fontString = unitFrame[unitKey] or _G[(CapitalizedUnit[unit] or "") .. "_" .. unitKey]
        if not fontString then return end
        fontString:ClearAllPoints()
        fontString:SetFont(UUF.Media.Font, keyValue.FontSize, General.FontFlag)
        fontString:SetShadowColor(General.FontShadows.SColour[1], General.FontShadows.SColour[2], General.FontShadows.SColour[3], General.FontShadows.SColour[4])
        fontString:SetShadowOffset(General.FontShadows.OffsetX, General.FontShadows.OffsetY)
        fontString:SetPoint(keyValue.AnchorFrom, AnchorParent, keyValue.AnchorTo, keyValue.OffsetX, keyValue.OffsetY)
        fontString:SetJustifyH(UUF:SetTextJustification(keyValue.AnchorTo))
        fontString:SetTextColor(unpack(keyValue.Colour))
        C_Timer.After(0, function() NudgeFont(fontString) end)
        local tagstr = keyValue.Tag or ""
        if tagstr == "" then
            if unitFrame.Untag then unitFrame:Untag(fontString) end
            fontString:SetText("")
            fontString:Hide()
        else
            fontString:Show()
            if unitFrame.Untag then unitFrame:Untag(fontString) end
            unitFrame:Tag(fontString, tagstr)
            if fontString.UpdateTag then fontString:UpdateTag() end
        end
    end

    if HighLevelContainer then
        UpdateTag("First", "FirstTag")
        UpdateTag("Second", "SecondTag")
        UpdateTag("Third", "ThirdTag")
        UpdateTag("Fourth", "FourthTag")
    end
end

function UUF:LayoutBossFrames()
    local Frame = UUF.db.profile.boss.Frame
    local BossSpacing = Frame.Spacing
    local GrowDown = Frame.GrowthDirection == "DOWN"

    for i, BossFrame in ipairs(UUF.BossFrames) do
        BossFrame:ClearAllPoints()
        if i == 1 then
            local BossContainerHeight = (BossFrame:GetHeight() + BossSpacing) * #UUF.BossFrames - BossSpacing
            local offsetY = 0
            if (Frame.AnchorFrom == "TOPLEFT" or Frame.AnchorFrom == "TOPRIGHT" or Frame.AnchorFrom == "TOP") and not GrowDown then
                offsetY = -BossContainerHeight
            elseif (Frame.AnchorFrom == "BOTTOMLEFT" or Frame.AnchorFrom == "BOTTOMRIGHT" or Frame.AnchorFrom == "BOTTOM") and GrowDown then
                offsetY = BossContainerHeight
            elseif (Frame.AnchorFrom == "CENTER" or Frame.AnchorFrom == "LEFT" or Frame.AnchorFrom == "RIGHT") then
                if GrowDown then
                    offsetY = (BossContainerHeight - BossFrame:GetHeight()) / 2
                else
                    offsetY = -(BossContainerHeight - BossFrame:GetHeight()) / 2
                end
            end
            local adjustedAnchorFrom = Frame.AnchorFrom
            if Frame.AnchorFrom == "TOPLEFT" and not GrowDown then
                adjustedAnchorFrom = "BOTTOMLEFT"
            elseif Frame.AnchorFrom == "TOP" and not GrowDown then
                adjustedAnchorFrom = "BOTTOM"
            elseif Frame.AnchorFrom == "TOPRIGHT" and not GrowDown then
                adjustedAnchorFrom = "BOTTOMRIGHT"
            elseif Frame.AnchorFrom == "BOTTOMLEFT" and GrowDown then
                adjustedAnchorFrom = "TOPLEFT"
            elseif Frame.AnchorFrom == "BOTTOM" and GrowDown then
                adjustedAnchorFrom = "TOP"
            elseif Frame.AnchorFrom == "BOTTOMRIGHT" and GrowDown then
                adjustedAnchorFrom = "TOPRIGHT"
            end
            BossFrame:SetPoint(adjustedAnchorFrom, Frame.AnchorParent, Frame.AnchorTo, Frame.XPosition, Frame.YPosition + offsetY)
        else
            local anchor = GrowDown and "TOPLEFT" or "BOTTOMLEFT"
            local relativeAnchor = GrowDown and "BOTTOMLEFT" or "TOPLEFT"
            local offsetY = GrowDown and -BossSpacing or BossSpacing
            BossFrame:SetPoint(anchor, _G["UUF_Boss" .. (i - 1)], relativeAnchor, 0, offsetY)
        end
    end
end

local function UpdatePartyFrames(self)
    local Party = UUF.db.profile.party
    local Frame = UUF.db.profile.party.Frame
    if not self.Party then return end
    self.Party:SetAttribute("showParty", Party.Enabled)
    self.Party:SetAttribute("point", Frame.Layout == "HORIZONTAL" and "LEFT" or "TOP")
    self.Party:SetAttribute("xOffset", Frame.Layout == "HORIZONTAL" and Frame.Spacing or 0)
    self.Party:SetAttribute("yOffset", Frame.Layout == "VERTICAL" and -Frame.Spacing or 0)
    self.Party:SetAttribute("showPlayer", Frame.ShowPlayer)
    self.Party:SetAttribute("groupingOrder", table.concat(Frame.SortOrder, ","))

    for i = 1, self.Party:GetNumChildren() do
        local child = select(i, self.Party:GetChildren())
        if child then
            local unit = (i == 5) and "player" or ("party" .. i)
            local dbUnit = (unit == "player") and "party" or unit
            child:SetSize(Frame.Width, Frame.Height)
            UpdateColours(child, dbUnit)
            UpdateTransparency(child, dbUnit)
            UpdateHealthBar(child, dbUnit)
            UpdatePowerBar(child, dbUnit)
            UpdateHealthPrediction(child, dbUnit)
            UpdateAuras(child, dbUnit)
            UpdateIndicators(child, dbUnit)
            UpdatePortrait(child, dbUnit)
            UpdateRange(child, dbUnit)
            UpdateTags(child, dbUnit)
            child:UpdateAllElements("UUF_UPDATE")
        end
    end

    self.Party:ClearAllPoints()
    self.Party:SetPoint(
        Frame.AnchorFrom,
        UIParent,
        Frame.AnchorTo,
        Frame.XPosition,
        Frame.YPosition
    )

    if Party.Enabled then
        self.Party:SetAttribute("showParty", false)
        self.Party:SetAttribute("showParty", true)
    end
end

local function UpdateRaidFrames(self)
    local Frame = UUF.db.profile.raid.Frame
    if not self.Raid then return end

    local groups = {}
    for i = 1, Frame.GroupsToShow do
        groups[#groups + 1] = tostring(i)
    end
    local groupString = table.concat(groups, ",")

    local point, xOffset, yOffset, columnAnchorPoint, colSpacing
    if Frame.Layout == "RIGHT_UP" then
        point, xOffset, yOffset = "TOP", 0, -Frame.Spacing
        columnAnchorPoint = "LEFT"
    elseif Frame.Layout == "RIGHT_DOWN" then
        point, xOffset, yOffset = "BOTTOM", 0, Frame.Spacing
        columnAnchorPoint = "LEFT"
    elseif Frame.Layout == "UP_RIGHT" then
        point, xOffset, yOffset = "RIGHT", Frame.Spacing, 0
        columnAnchorPoint = "BOTTOM"
    elseif Frame.Layout == "UP_LEFT" then
        point, xOffset, yOffset = "LEFT", -Frame.Spacing, 0
        columnAnchorPoint = "BOTTOM"
    else
        point, xOffset, yOffset = "TOP", 0, -Frame.Spacing
        columnAnchorPoint = "LEFT"
    end

    self.Raid:SetAttribute("showRaid", Frame.Enabled)
    self.Raid:SetAttribute("groupBy", "GROUP")
    self.Raid:SetAttribute("groupFilter", groupString)
    self.Raid:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
    self.Raid:SetAttribute("maxColumns", Frame.GroupsToShow)
    self.Raid:SetAttribute("unitsPerColumn", 5)
    self.Raid:SetAttribute("point", point)
    self.Raid:SetAttribute("xOffset", xOffset)
    self.Raid:SetAttribute("yOffset", yOffset)
    self.Raid:SetAttribute("columnSpacing", Frame.Spacing)
    self.Raid:SetAttribute("columnAnchorPoint", columnAnchorPoint)

    for i = 1, self.Raid:GetNumChildren() do
        local child = select(i, self.Raid:GetChildren())
        local unitToken = "raid" .. i
        if child and UnitExists(unitToken) then
            child:SetSize(Frame.Width, Frame.Height)
            UpdateColours(child, unitToken)
            UpdateTransparency(child, unitToken)
            UpdateHealthBar(child, unitToken)
            UpdatePowerBar(child, unitToken)
            UpdateHealthPrediction(child, unitToken)
            UpdateAuras(child, unitToken)
            UpdateIndicators(child, unitToken)
            UpdateRange(child, unitToken)
            UpdateTags(child, unitToken)
            child:UpdateAllElements("UUF_UPDATE")
        end
    end

    self.Raid:ClearAllPoints()
    self.Raid:SetPoint(
        Frame.AnchorFrom,
        UIParent,
        Frame.AnchorTo,
        Frame.XPosition,
        Frame.YPosition
    )

    self.Raid:SetAttribute("showRaid", false)
    self.Raid:SetAttribute("showRaid", true)
end


function UUF:UpdateFrame(frameName, unit)
    if not unit then return end

    local normalizedUnit = GetNormalizedUnit(unit)
    local dbUnit = UUF.db.profile[normalizedUnit]
    if not dbUnit then return end
    local Frame = dbUnit.Frame

    UUF:Init()
    UUF:ResolveMedia()

    if normalizedUnit == "boss" then
        if dbUnit.Enabled then
            for _, BossFrame in ipairs(UUF.BossFrames) do
                if not UUF.BossTestMode then
                    BossFrame:Enable(false)
                end
                BossFrame:SetSize(Frame.Width, Frame.Height)
            end
        else
            for _, BossFrame in ipairs(UUF.BossFrames) do
                BossFrame:Disable()
                BossFrame:Hide()
            end
            return
        end

        UUF:LayoutBossFrames()

        for i, BossFrame in ipairs(UUF.BossFrames) do
            UpdateColours(BossFrame, "boss" .. i)
            UpdateTransparency(BossFrame, "boss" .. i)
            UpdateHealthBar(BossFrame, "boss" .. i)
            UpdatePowerBar(BossFrame, "boss" .. i)
            UpdateHealthPrediction(BossFrame, "boss" .. i)
            UpdateCastBar(BossFrame, "boss" .. i)
            UpdateAuras(BossFrame, "boss" .. i)
            UpdateIndicators(BossFrame, "boss" .. i)
            UpdatePortrait(BossFrame, "boss" .. i)
            UpdateRange(BossFrame, "boss" .. i)
            UpdateTags(BossFrame, "boss" .. i)
            if not UUF.BossTestMode then
                BossFrame:UpdateAllElements("UUF_UPDATE")
            else
                UUF:CreateTestBossFrames()
            end
        end
        return
    end

    if normalizedUnit == "party" then
        if not self.Party then return end
        UpdatePartyFrames(self)
        return
    end

    if normalizedUnit == "raid" then
        if not self.Raid then return end
        UpdateRaidFrames(self)
        return
    end

    local unitFrame = type(frameName) == "table" and frameName or _G[frameName]
    if not unitFrame then return end
    if dbUnit.Enabled and not unitFrame:IsEnabled() then
        unitFrame:Enable(false)
    elseif not dbUnit.Enabled and unitFrame:IsEnabled() then
        unitFrame:Disable()
        return
    end

    unitFrame:ClearAllPoints()
    if Frame.AnchorParent then
        unitFrame:SetPoint(Frame.AnchorFrom, Frame.AnchorParent, Frame.AnchorTo, Frame.XPosition, Frame.YPosition)
    else
        unitFrame:SetPoint(Frame.AnchorFrom, UIParent, Frame.AnchorTo, Frame.XPosition, Frame.YPosition)
    end

    unitFrame:SetSize(Frame.Width, Frame.Height)
    UpdateColours(unitFrame, unit)
    UpdateTransparency(unitFrame, unit)
    UpdateHealthBar(unitFrame, unit)

    if dbUnit.PowerBar then
        UpdatePowerBar(unitFrame, unit)
    end

    if dbUnit.HealPrediction then
        UpdateHealthPrediction(unitFrame, unit)
    end

    if dbUnit.CastBar then
        UpdateCastBar(unitFrame, unit)
    end

    if dbUnit.Buffs or dbUnit.Debuffs then
        UpdateAuras(unitFrame, unit)
    end

    if dbUnit.Portrait then
        UpdatePortrait(unitFrame, unit)
    end

    if dbUnit.Indicators then
        UpdateIndicators(unitFrame, unit)
    end

    if dbUnit.Range then
        UpdateRange(unitFrame, unit)
    end

    if dbUnit.Tags then
        UpdateTags(unitFrame, unit)
    end

    unitFrame:UpdateAllElements("UUF_UPDATE")
end

function UUF:CreateUnitFrame(unit)
    local DB = UUF.db.profile[unit]
    self:SetSize(UUF.db.profile[unit].Frame.Width, UUF.db.profile[unit].Frame.Height)

    CreateContainer(self, unit)
    CreateHealthBar(self, unit)

    if DB.PowerBar then
        CreatePowerBar(self, unit)
    end
    if DB.HealPrediction then
        CreateHealthPrediction(self, unit)
    end
    if DB.CastBar then
        CreateCastbar(self, unit)
    end
    if DB.Buffs then
        CreateBuffs(self, unit)
    end
    if DB.Debuffs then
        CreateDebuffs(self, unit)
    end
    if DB.Portrait then
        CreatePortrait(self, unit)
    end
    if DB.Indicators then
        CreateIndicators(self, unit)
    end
    if DB.Tags then
        CreateTags(self, unit)
    end
    ApplyScripts(self, unit)
end

function UUF:CreateTestBossFrames()
    UUF:ResolveMedia()
    local UUFDB = UUF.db.profile
    local General = UUFDB.General
    local Frame = UUFDB.boss.Frame
    local PowerBar = UUFDB.boss.PowerBar
    local CastBar = UUFDB.boss.CastBar
    local Buffs = UUFDB.boss.Buffs
    local Debuffs = UUFDB.boss.Debuffs
    local Portrait = UUFDB.boss.Portrait
    local Indicators = UUFDB.boss.Indicators
    local Tags = UUFDB.boss.Tags
    local HealAbsorb = UUFDB.boss.HealPrediction.HealAbsorb
    local Absorb = UUFDB.boss.HealPrediction.Absorb

    if UUF.BossTestMode then
        for i, BossFrame in ipairs(UUF.BossFrames) do
            BossFrame:SetAttribute("unit", nil)
            UnregisterUnitWatch(BossFrame)
            BossFrame:Show()

            BossFrame.Power = BossFrame.PowerBar
            BossFrame.Castbar = BossFrame.CastBar
            if BossFrame.CastBarIcon then
                BossFrame.Castbar.Icon = BossFrame.CastBarIcon
            end
            BossFrame.Buffs = BossFrame.BuffContainer
            BossFrame.Debuffs = BossFrame.DebuffContainer
            BossFrame.RaidTargetIndicator = BossFrame.RaidMarker
            BossFrame.LeaderIndicator = BossFrame.Leader
            BossFrame.AssistantIndicator = BossFrame.Assistant
            BossFrame.CombatIndicator = BossFrame.Combat
            BossFrame.RestingIndicator = BossFrame.Resting

            if BossFrame.HealthBar then
                BossFrame.HealthBar:SetMinMaxValues(0, 100)
                BossFrame.HealthBar:SetValue(25)
                if Frame.ClassColour then
                    local _, class = UnitClass("player")
                    local color = RAID_CLASS_COLORS[class]
                    if color then
                        BossFrame.HealthBar:SetStatusBarColor(color.r, color.g, color.b,
                            UUF.db.profile.boss.Frame.FGColour[4])
                    end
                elseif Frame.ReactionColour then
                    local reaction = math.random(1, 8)
                    local color = oUF.colors.reaction[reaction]
                    if color then
                        BossFrame.HealthBar:SetStatusBarColor(color[1], color[2], color[3],
                            UUF.db.profile.boss.Frame.FGColour[4])
                    end
                else
                    BossFrame.HealthBar:SetStatusBarColor(
                        UUF.db.profile.boss.Frame.FGColour[1],
                        UUF.db.profile.boss.Frame.FGColour[2],
                        UUF.db.profile.boss.Frame.FGColour[3],
                        UUF.db.profile.boss.Frame.FGColour[4]
                    )
                end
                BossFrame.HealthBar:Show()
                BossFrame.HealthBG:SetMinMaxValues(0, 100)
                BossFrame.HealthBG:SetValue(75)
            end

            if BossFrame.PowerBar then
                local PowerColours = {
                    [0] = { 0, 0, 1 },
                    [1] = { 1, 0, 0 },
                    [2] = { 1, 0.5, 0.25 },
                    [3] = { 1, 1, 0 },
                    [4] = { 0, 0.82, 1 },
                    [5] = { 0.3, 0.52, 0.9 },
                    [6] = { 0, 0.5, 1 },
                    [7] = { 0.4, 0, 0.8 },
                    [8] = { 0.79, 0.26, 0.99 },
                    [9] = { 1, 0.61, 0 }
                }

                BossFrame.PowerBar:SetMinMaxValues(0, 100)
                BossFrame.PowerBar:SetValue(75)
                if PowerBar.ColourByType then
                    BossFrame.PowerBar:SetStatusBarColor(unpack(PowerColours[math.random(0, #PowerColours)]))
                else
                    BossFrame.PowerBar:SetStatusBarColor(
                        UUF.db.profile.boss.PowerBar.FGColour[1],
                        UUF.db.profile.boss.PowerBar.FGColour[2],
                        UUF.db.profile.boss.PowerBar.FGColour[3],
                        UUF.db.profile.boss.PowerBar.FGColour[4]
                    )
                end
                if PowerBar.Enabled then
                    BossFrame.PowerBar:Show()
                else
                    BossFrame.PowerBar:Hide()
                end
            end

            if BossFrame.HealthPrediction then
                if HealAbsorb.Enabled and BossFrame.HealAbsorbBar then
                    BossFrame.HealAbsorbBar:SetMinMaxValues(0, 100)
                    BossFrame.HealAbsorbBar:SetWidth(BossFrame.HealthBar:GetWidth())
                    BossFrame.HealAbsorbBar:SetValue(5)
                    BossFrame.HealAbsorbBar:Show()
                    BossFrame.HealthPrediction.healAbsorbBar = BossFrame.HealAbsorbBar
                elseif BossFrame.HealAbsorbBar then
                    BossFrame.HealAbsorbBar:Hide()
                    BossFrame.HealthPrediction.healAbsorbBar = nil
                end

                if Absorb.Enabled and BossFrame.AbsorbBar then
                    BossFrame.AbsorbBar:SetMinMaxValues(0, 100)
                    BossFrame.AbsorbBar:SetWidth(BossFrame.HealthBar:GetWidth())
                    BossFrame.AbsorbBar:SetValue(10)
                    BossFrame.AbsorbBar:Show()
                    BossFrame.HealthPrediction.absorbBar = BossFrame.AbsorbBar
                elseif BossFrame.AbsorbBar then
                    BossFrame.AbsorbBar:Hide()
                    BossFrame.HealthPrediction.absorbBar = nil
                end
            end

            if BossFrame.CastBar and CastBar.Enabled then
                BossFrame:DisableElement("Castbar")
                BossFrame.CastBarContainer:Show()
                BossFrame.CastBar:Show()
                BossFrame.CastBar.Text:SetText("Ethereal Portal")
                BossFrame.CastBar.Time:SetText("10")
                BossFrame.CastBar:SetMinMaxValues(0, 100)
                BossFrame.CastBar:SetValue(50)
                if CastBar.Icon.Enabled and BossFrame.Castbar.Icon then
                    BossFrame.Castbar.Icon:SetTexture("Interface\\Icons\\ability_mage_netherwindpresence")
                    BossFrame.Castbar.Icon:Show()
                end
            else
                if BossFrame.CastBarContainer then
                    BossFrame.CastBarContainer:Hide()
                end
                if BossFrame.Castbar and BossFrame.Castbar.Icon then
                    BossFrame.Castbar.Icon:Hide()
                end
            end

            if BossFrame.BuffContainer then
                if Buffs.Enabled then
                    BossFrame.BuffContainer:ClearAllPoints()
                    BossFrame.BuffContainer:SetPoint(Buffs.AnchorFrom, BossFrame, Buffs.AnchorTo, Buffs.OffsetX,
                        Buffs.OffsetY)
                    BossFrame.BuffContainer:Show()

                    for j = 1, Buffs.Num do
                        local button = BossFrame.BuffContainer["fake" .. j]
                        if not button then
                            button = CreateFrame("Button", nil, BossFrame.BuffContainer)

                            button.Icon = button:CreateTexture(nil, "BORDER")
                            button.Icon:SetAllPoints()

                            button.Count = button:CreateFontString(nil, "OVERLAY")
                            BossFrame.BuffContainer["fake" .. j] = button
                        end

                        button:SetSize(Buffs.Size, Buffs.Size)
                        button.Count:ClearAllPoints()
                        button.Count:SetPoint(Buffs.Count.AnchorFrom, button, Buffs.Count.AnchorTo, Buffs.Count.OffsetX,
                            Buffs.Count.OffsetY)
                        button.Count:SetFont(UUF.Media.Font, Buffs.Count.FontSize, General.FontFlag)
                        button.Count:SetTextColor(unpack(Buffs.Count.Colour))

                        local row = math.floor((j - 1) / Buffs.Wrap)
                        local col = (j - 1) % Buffs.Wrap
                        local x = col * (Buffs.Size + Buffs.Spacing)
                        local y = row * (Buffs.Size + Buffs.Spacing)
                        if Buffs.Growth == "LEFT" then x = -x end
                        if Buffs.WrapDirection == "DOWN" then y = -y end

                        button:ClearAllPoints()
                        button:SetPoint(Buffs.AnchorFrom, BossFrame.BuffContainer, Buffs.AnchorFrom, x, y)

                        button.Icon:SetTexture(135940)
                        button.Icon:SetTexCoord(0.01, 0.99, 0.01, 0.99)
                        button.Count:SetText(j)
                        button:Show()
                    end

                    local maxFake = Buffs.Num
                    for j = maxFake + 1, (BossFrame.BuffContainer.maxFake or maxFake) do
                        local button = BossFrame.BuffContainer["fake" .. j]
                        if button then button:Hide() end
                    end
                    BossFrame.BuffContainer.maxFake = Buffs.Num
                else
                    BossFrame.BuffContainer:Hide()
                end
            end

            if BossFrame.DebuffContainer then
                if Debuffs.Enabled then
                    BossFrame.DebuffContainer:ClearAllPoints()
                    BossFrame.DebuffContainer:SetPoint(Debuffs.AnchorFrom, BossFrame, Debuffs.AnchorTo, Debuffs.OffsetX,
                        Debuffs.OffsetY)
                    BossFrame.DebuffContainer:Show()

                    for j = 1, Debuffs.Num do
                        local button = BossFrame.DebuffContainer["fake" .. j]
                        if not button then
                            button = CreateFrame("Button", nil, BossFrame.DebuffContainer)

                            button.Icon = button:CreateTexture(nil, "BORDER")
                            button.Icon:SetAllPoints()

                            button.Count = button:CreateFontString(nil, "OVERLAY")
                            BossFrame.DebuffContainer["fake" .. j] = button
                        end

                        button:SetSize(Debuffs.Size, Debuffs.Size)
                        button.Count:ClearAllPoints()
                        button.Count:SetPoint(Debuffs.Count.AnchorFrom, button, Debuffs.Count.AnchorTo,
                            Debuffs.Count.OffsetX, Debuffs.Count.OffsetY)
                        button.Count:SetFont(UUF.Media.Font, Debuffs.Count.FontSize, General.FontFlag)
                        button.Count:SetTextColor(unpack(Debuffs.Count.Colour))

                        local row = math.floor((j - 1) / Debuffs.Wrap)
                        local col = (j - 1) % Debuffs.Wrap
                        local x = col * (Debuffs.Size + Debuffs.Spacing)
                        local y = row * (Debuffs.Size + Debuffs.Spacing)
                        if Debuffs.Growth == "LEFT" then x = -x end
                        if Debuffs.WrapDirection == "DOWN" then y = -y end

                        button:ClearAllPoints()
                        button:SetPoint(Debuffs.AnchorFrom, BossFrame.DebuffContainer, Debuffs.AnchorFrom, x, y)

                        button.Icon:SetTexture(252997)
                        button.Icon:SetTexCoord(0.01, 0.99, 0.01, 0.99)
                        button.Count:SetText(j)
                        button:Show()
                    end

                    local maxFake = Debuffs.Num
                    for j = maxFake + 1, (BossFrame.DebuffContainer.maxFake or maxFake) do
                        local button = BossFrame.DebuffContainer["fake" .. j]
                        if button then button:Hide() end
                    end
                    BossFrame.DebuffContainer.maxFake = Debuffs.Num
                else
                    BossFrame.DebuffContainer:Hide()
                end
            end

            if BossFrame.PortraitContainer then
                if UUFDB.boss.Portrait.Enabled then
                    BossFrame.PortraitContainer:Show()
                    local PortraitOptions = {
                        [1] = "achievement_character_human_female",
                        [2] = "achievement_character_human_male",
                        [3] = "achievement_character_dwarf_male",
                        [4] = "achievement_character_dwarf_female",
                        [5] = "achievement_character_nightelf_female",
                        [6] = "achievement_character_nightelf_male",
                        [7] = "achievement_character_undead_male",
                        [8] = "achievement_character_undead_female"
                    }
                    BossFrame.PortraitTexture:SetTexture("Interface\\ICONS\\" .. PortraitOptions[i])
                    BossFrame.PortraitTexture:SetTexCoord((Portrait.Zoom or 0) * 0.5, 1 - (Portrait.Zoom or 0) * 0.5,
                        (Portrait.Zoom or 0) * 0.5, 1 - (Portrait.Zoom or 0) * 0.5)
                else
                    BossFrame.PortraitContainer:Hide()
                end
            end

            if BossFrame.RaidMarker then
                BossFrame.RaidMarker:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. i)
                if Indicators.RaidMarker.Enabled then
                    BossFrame.RaidMarker:Show()
                else
                    BossFrame.RaidMarker:Hide()
                end
            end

            if BossFrame.FirstTag then
                BossFrame:Tag(BossFrame.FirstTag, Tags["First"].Tag)
            end
            if BossFrame.SecondTag then
                BossFrame:Tag(BossFrame.SecondTag, Tags["Second"].Tag)
            end
            if BossFrame.ThirdTag then
                BossFrame:Tag(BossFrame.ThirdTag, Tags["Third"].Tag)
            end
            if BossFrame.FourthTag then
                BossFrame:Tag(BossFrame.FourthTag, Tags["Fourth"].Tag)
            end
            BossFrame:UpdateTags()
        end
    else
        for i, BossFrame in ipairs(UUF.BossFrames) do
            BossFrame:SetAttribute("unit", "boss" .. i)
            RegisterUnitWatch(BossFrame)
            BossFrame:Hide()
            for j = 1, (BossFrame.BuffContainer and BossFrame.BuffContainer.maxFake) or 0 do
                local button = BossFrame.BuffContainer["fake" .. j]
                if button then button:Hide() end
            end
            for j = 1, (BossFrame.DebuffContainer and BossFrame.DebuffContainer.maxFake) or 0 do
                local button = BossFrame.DebuffContainer["fake" .. j]
                if button then button:Hide() end
            end
            if CastBar.Enabled then
                BossFrame:EnableElement("Castbar")
            end
        end
        UUF:LayoutBossFrames()
    end
end
