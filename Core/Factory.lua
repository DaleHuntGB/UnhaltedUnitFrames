local _, UUF = ...
UnitToFrameName = UUF.UnitToFrameName

local function ResolveFrameName(unit)
    if unit:match("^boss(%d+)$") then
        local unitID = unit:match("^boss(%d+)$")
        return "UUF_Boss" .. unitID
    end
    return UnitToFrameName[unit]
end

local function FetchUnitColor(unit, DB, GeneralDB)
    if DB.Frame.ClassColour then
        if unit == "pet" then
            local _, playerClass = UnitClass("player")
            local playerClassColour = playerClass and RAID_CLASS_COLORS[playerClass]
            if playerClassColour then
                return playerClassColour.r, playerClassColour.g, playerClassColour.b
            end
        end

        if UnitIsPlayer(unit) then
            local _, class = UnitClass(unit)
            local unitClassColour = class and RAID_CLASS_COLORS[class]
            if unitClassColour then
                return unitClassColour.r, unitClassColour.g, unitClassColour.b
            end
        end
    end

    if DB.Frame.ReactionColour then
        local reaction = UnitReaction(unit, "player") or 5
        local reactionColours = GeneralDB.CustomColours.Reaction
        local reactionColour = reactionColours and reactionColours[reaction]
        if reactionColour then
            return reactionColour[1], reactionColour[2], reactionColour[3]
        end
    end

    return DB.Frame.FGColour[1], DB.Frame.FGColour[2], DB.Frame.FGColour[3], DB.Frame.FGColour[4]
end

local function FetchNameTextColour(unit, DB, GeneralDB)
    if DB.Tags.Name.ColourByStatus then

        if unit == "pet" then
            local _, playerClass = UnitClass("player")
            local playerClassColour = playerClass and RAID_CLASS_COLORS[playerClass]
            if playerClassColour then
                return playerClassColour.r, playerClassColour.g, playerClassColour.b
            end
        end

        if UnitIsPlayer(unit) then
            local _, class = UnitClass(unit)
            local classColour = class and RAID_CLASS_COLORS[class]
            if classColour then
                return classColour.r, classColour.g, classColour.b
            end
        end

        local reaction = UnitReaction(unit, "player") or 5
        local reactionColours = GeneralDB.CustomColours.Reaction
        local reactionColour = reactionColours and reactionColours[reaction]
        if reactionColour then
            return reactionColour[1], reactionColour[2], reactionColour[3]
        end
    end

    local unitTextColour = DB.Tags.Name.Colour
    return unitTextColour[1], unitTextColour[2], unitTextColour[3]
end

local function FetchPowerBarColour(unit)
    local DB = UUF.db.profile[unit]
    local GeneralDB = UUF.db.profile.General
    local PowerBarDB = DB and DB.PowerBar
    if not DB then return 1, 1, 1, 1 end

    if DB.PowerBar.ColourByType then
        local powerToken = UnitPowerType(unit)
        if powerToken then
            local colour = GeneralDB.CustomColours.Power[powerToken]
            if colour then
                return colour[1], colour[2], colour[3], colour[4] or 1
            end
        end
    end

    local powerBarFG = PowerBarDB.FGColour
    return powerBarFG[1], powerBarFG[2], powerBarFG[3], powerBarFG[4] or 1
end

local function UpdateUnitFrame(self)
    local unit = self.unit
    if not unit then return end

    local unitHealth = UnitHealth(unit)
    local unitMaxHealth = UnitHealthMax(unit)
    local unitColourR, unitColourG, unitColourB = FetchUnitColor(unit, UUF.db.profile[unit], UUF.db.profile.General)

    self.healthBar:SetMinMaxValues(0, unitMaxHealth)
    self.healthBar:SetValue(unitHealth)
    self.healthBar:SetStatusBarColor(unitColourR, unitColourG, unitColourB)
    local isUnitDead = UnitIsDeadOrGhost(unit)
    local unitHealthPercent = UnitHealthPercent(unit, false, true)
    local CurrHP         = UUF.db.profile[unit].Tags.Health.Layout == "CurrHP"
    local CurrMaxHP      = UUF.db.profile[unit].Tags.Health.Layout == "CurrMaxHP"
    local PerHP             = UUF.db.profile[unit].Tags.Health.Layout == "PerHP"
    local CurrPerHP  = UUF.db.profile[unit].Tags.Health.Layout == "CurrPerHP"
    local HealthSeparator = UUF.db.profile.General.HealthSeparator or "-"
    local healthText = ""
    if isUnitDead then
        healthText = "Dead"
    else
        if CurrPerHP then
            if HealthSeparator == "()" then
                healthText = string.format("%s (%.0f%%)", AbbreviateLargeNumbers(unitHealth), unitHealthPercent)
            else
                healthText = string.format("%s %s %.0f%%", AbbreviateLargeNumbers(unitHealth), HealthSeparator, unitHealthPercent)
            end
        elseif CurrMaxHP then
            healthText = string.format("%s / %s", AbbreviateLargeNumbers(unitHealth), AbbreviateLargeNumbers(unitMaxHealth))
        elseif CurrHP then
            healthText = AbbreviateLargeNumbers(unitHealth)
        elseif PerHP then
            healthText = string.format("%.0f%%", unitHealthPercent)
        else
            healthText = ""
        end
    end
    self.HealthText:SetText(healthText)
    local statusColourR, statusColourG, statusColourB = FetchNameTextColour(unit, UUF.db.profile[unit], UUF.db.profile.General)
    self.NameText:SetTextColor(statusColourR, statusColourG, statusColourB)
    self.NameText:SetText(UnitName(unit))
end

local function UpdateUnitFramePowerBar(self)
    local unit = self.unit
    if not unit then return end
    self:Show()
    local db = UUF.db.profile[unit].PowerBar
    local textDB = db.Text
    local unitPower = UnitPower(unit)
    local r, g, b, a = FetchPowerBarColour(unit)
    self:SetMinMaxValues(0, 100)
    self:SetValue(unitPower)
    self:SetStatusBarColor(r, g, b, a)
    if self.Text then
        if textDB.Enabled then
            self.Text:Show()
            if textDB.ColourByType then
                self.Text:SetTextColor(r, g, b, a)
            else
                local textDBR, textDBG, textDBB, textDBA = unpack(textDB.Colour)
                self.Text:SetTextColor(textDBR, textDBG, textDBB, textDBA or 1)
            end
            local powerType = UnitPowerType(unit)
            if powerType and powerType == 0 then
                self.Text:SetText(string.format("%.0f%%", UnitPowerPercent(unit, Enum.PowerType.Mana, false, true)))
            else
                self.Text:SetText(AbbreviateLargeNumbers(unitPower))
            end
        else
            self.Text:Hide()
        end
    end
end

function UUF:CreateUnitFrame(unit)
    local dbUnit = unit
    if unit:match("^boss%d+$") then dbUnit = "boss" end
    local DB = UUF.db.profile[dbUnit]
    local GeneralDB = UUF.db.profile.General
    local TagsDB = DB and DB.Tags
    local NameDB = TagsDB and TagsDB.Name
    local HealthDB = TagsDB and TagsDB.Health
    local IndicatorsDB = DB and DB.Indicators
    local requiresParentFrame = (unit == "targettarget" or unit == "pet" or unit == "focus")
    local unitParent = requiresParentFrame and _G[DB.Frame.AnchorParent] or UIParent
    if not unit or not DB then return end

    local frameName = ResolveFrameName(unit)
    local unitFrame = CreateFrame("Button", frameName, UIParent, "SecureUnitButtonTemplate,BackdropTemplate, PingableUnitFrameTemplate")

    unitFrame:SetSize(DB.Frame.Width, DB.Frame.Height)
    unitFrame:SetPoint(DB.Frame.AnchorFrom, unitParent, DB.Frame.AnchorTo, DB.Frame.XPosition, DB.Frame.YPosition)

    unitFrame:SetBackdrop({ bgFile = UUF.Media.BackgroundTexture, edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
    unitFrame:SetBackdropColor(unpack(DB.Frame.BGColour))
    unitFrame:SetBackdropBorderColor(0, 0, 0, 1)

    unitFrame.healthBar = CreateFrame("StatusBar", nil, unitFrame)
    unitFrame.healthBar:SetPoint("TOPLEFT", unitFrame, "TOPLEFT", 1, -1)
    unitFrame.healthBar:SetPoint("BOTTOMRIGHT", unitFrame, "BOTTOMRIGHT", -1, 1)
    unitFrame.healthBar:SetStatusBarTexture(UUF.Media.ForegroundTexture)
    if not unitFrame.healthBar.BG then
        unitFrame.healthBar.BG = unitFrame.healthBar:CreateTexture(nil, "BACKGROUND")
        unitFrame.healthBar.BG:SetAllPoints()
        unitFrame.healthBar.BG:SetTexture(UUF.Media.BackgroundTexture)
    end

    local bgR, bgG, bgB, bgA = unpack(DB.Frame.BGColour)
    unitFrame.healthBar.BG:SetVertexColor(bgR, bgG, bgB, bgA)

    unitFrame.NameText = unitFrame.healthBar:CreateFontString(nil, "OVERLAY")
    unitFrame.NameText:SetFont(UUF.Media.Font, DB.Tags.Name.FontSize, GeneralDB.FontFlag)
    unitFrame.NameText:SetPoint(DB.Tags.Name.AnchorFrom, unitFrame, DB.Tags.Name.AnchorTo, DB.Tags.Name.OffsetX, DB.Tags.Name.OffsetY)
    unitFrame.NameText:SetJustifyH(UUF:SetJustification(DB.Tags.Name.AnchorFrom))
    local statusColourR, statusColourG, statusColourB = FetchNameTextColour(unit, DB, GeneralDB)
    unitFrame.NameText:SetTextColor(statusColourR, statusColourG, statusColourB)
    unitFrame.NameText:SetShadowColor(unpack(GeneralDB.FontShadows.Colour))
    unitFrame.NameText:SetShadowOffset(GeneralDB.FontShadows.OffsetX, GeneralDB.FontShadows.OffsetY)
    if NameDB.Enabled then
        unitFrame.NameText:Show()
    else
        unitFrame.NameText:Hide()
    end

    unitFrame.HealthText = unitFrame.healthBar:CreateFontString(nil, "OVERLAY")
    unitFrame.HealthText:SetFont(UUF.Media.Font, DB.Tags.Health.FontSize, GeneralDB.FontFlag)
    unitFrame.HealthText:SetPoint(DB.Tags.Health.AnchorFrom, unitFrame, DB.Tags.Health.AnchorTo, DB.Tags.Health.OffsetX, DB.Tags.Health.OffsetY)
    unitFrame.HealthText:SetJustifyH(UUF:SetJustification(DB.Tags.Health.AnchorFrom))
    unitFrame.HealthText:SetTextColor(unpack(DB.Tags.Health.Colour))
    unitFrame.HealthText:SetShadowColor(unpack(GeneralDB.FontShadows.Colour))
    unitFrame.HealthText:SetShadowOffset(GeneralDB.FontShadows.OffsetX, GeneralDB.FontShadows.OffsetY)
    if HealthDB.Enabled then
        unitFrame.HealthText:Show()
    else
        unitFrame.HealthText:Hide()
    end

    unitFrame.MouseoverHighlight = CreateFrame("Frame", nil, unitFrame, "BackdropTemplate")
    unitFrame.MouseoverHighlight:SetAllPoints()
    unitFrame.MouseoverHighlight:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
    unitFrame.MouseoverHighlight:SetBackdropColor(0,0,0,0)
    unitFrame.MouseoverHighlight:SetBackdropBorderColor(unpack(DB.Indicators.MouseoverHighlight.Colour))
    unitFrame.MouseoverHighlight:Hide()

    if unit ~= "targettarget" and unit ~= "pet" and unit ~= "focus" then
        local unitFramePowerBar = CreateFrame("StatusBar", nil, unitFrame)
        unitFrame.powerBar = unitFramePowerBar

        unitFramePowerBar.Text = unitFramePowerBar:CreateFontString(nil, "OVERLAY")
        unitFramePowerBar.Text:SetFont(UUF.Media.Font, DB.PowerBar.Text.FontSize, GeneralDB.FontFlag)
        if DB.PowerBar.Text.AnchorParent == "FRAME" then
            unitFramePowerBar.Text:SetPoint(DB.PowerBar.Text.AnchorFrom, unitFrame, DB.PowerBar.Text.AnchorTo, DB.PowerBar.Text.OffsetX, DB.PowerBar.Text.OffsetY)
        else
            unitFramePowerBar.Text:SetPoint(DB.PowerBar.Text.AnchorFrom, unitFramePowerBar, DB.PowerBar.Text.AnchorTo, DB.PowerBar.Text.OffsetX, DB.PowerBar.Text.OffsetY)
        end
        unitFramePowerBar.Text:SetJustifyH(UUF:SetJustification(DB.PowerBar.Text.AnchorFrom))
        unitFramePowerBar.Text:SetTextColor(unpack(DB.PowerBar.Text.Colour))
        unitFramePowerBar.Text:SetShadowColor(unpack(GeneralDB.FontShadows.Colour))
        unitFramePowerBar.Text:SetShadowOffset(GeneralDB.FontShadows.OffsetX, GeneralDB.FontShadows.OffsetY)
        if DB.PowerBar.Enabled then
            local barHeight = DB.PowerBar.Height

            unitFramePowerBar:SetStatusBarTexture(UUF.Media.ForegroundTexture)
            unitFramePowerBar:SetHeight(barHeight)
            unitFramePowerBar:SetPoint("BOTTOMLEFT", unitFrame, "BOTTOMLEFT", 1, 1)
            unitFramePowerBar:SetPoint("BOTTOMRIGHT", unitFrame, "BOTTOMRIGHT", -1, 1)
            unitFramePowerBar:Show()

            if not unitFramePowerBar.bg then
                unitFramePowerBar.bg = unitFramePowerBar:CreateTexture(nil, "BACKGROUND")
            end

            unitFramePowerBar.bg:SetAllPoints()
            unitFramePowerBar.bg:SetTexture(UUF.Media.BackgroundTexture)

            local r, g, b, a = unpack(DB.PowerBar.BGColour or {0.1, 0.1, 0.1, 0.7})
            unitFramePowerBar.bg:SetVertexColor(r, g, b, a)

            unitFrame.healthBar:ClearAllPoints()
            unitFrame.healthBar:SetPoint("TOPLEFT", unitFrame, "TOPLEFT", 1, -1)
            unitFrame.healthBar:SetPoint("BOTTOMLEFT", unitFramePowerBar, "TOPLEFT", 0, 0)
            unitFrame.healthBar:SetPoint("BOTTOMRIGHT", unitFramePowerBar, "TOPRIGHT", 0, 0)
        else
            unitFramePowerBar:Hide()
            unitFrame.healthBar:ClearAllPoints()
            unitFrame.healthBar:SetPoint("TOPLEFT", unitFrame, "TOPLEFT", 1, -1)
            unitFrame.healthBar:SetPoint("BOTTOMRIGHT", unitFrame, "BOTTOMRIGHT", -1, 1)
        end

        unitFramePowerBar.unit = unit
        unitFramePowerBar:RegisterEvent("UNIT_POWER_UPDATE")
        unitFramePowerBar:RegisterEvent("UNIT_MAXPOWER")
        unitFramePowerBar:RegisterEvent("PLAYER_TARGET_CHANGED")
        unitFramePowerBar:SetScript("OnEvent", UpdateUnitFramePowerBar)
        UpdateUnitFramePowerBar(unitFramePowerBar)
    end

    unitFrame.unit = unit
    unitFrame:RegisterForClicks("AnyUp")
    unitFrame:SetAttribute("unit", unit)
    unitFrame:SetAttribute("*type1", "target")
    unitFrame:SetAttribute("*type2", "togglemenu")

    unitFrame:RegisterEvent("UNIT_HEALTH")
    unitFrame:RegisterEvent("UNIT_NAME_UPDATE")
    unitFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    unitFrame:RegisterEvent("PLAYER_TARGET_CHANGED")

    RegisterUnitWatch(unitFrame, false)

    unitFrame:SetScript("OnEnter", UnitFrame_OnEnter)
    unitFrame:SetScript("OnLeave", UnitFrame_OnLeave)
    unitFrame:HookScript("OnEnter", function(self) DB = UUF.db.profile[unit] if DB.Indicators.MouseoverHighlight.Enabled then self.MouseoverHighlight:Show() end end)
    unitFrame:HookScript("OnLeave", function(self) DB = UUF.db.profile[unit] if DB.Indicators.MouseoverHighlight.Enabled then self.MouseoverHighlight:Hide() end end)

    if unit == "pet" then unitFrame:RegisterEvent("UNIT_PET") end
    if unit == "focus" then unitFrame:RegisterEvent("PLAYER_FOCUS_CHANGED") end

    unitFrame:SetScript("OnEvent", UpdateUnitFrame)

    UpdateUnitFrame(unitFrame)
end

function UUF:UpdateUnitFrame(unit)
    if not unit then return end
    local dbUnit = unit
    if unit:match("^boss%d+$") then dbUnit = "boss" end
    local DB = UUF.db.profile[dbUnit]
    local GeneralDB = UUF.db.profile.General
    if not DB then return end

    local frameName = ResolveFrameName(unit)
    local unitFrame = _G[frameName]
    if not unitFrame then return end

    if not DB.Enabled then
        unitFrame:Hide()
        unitFrame:UnregisterAllEvents()
        return
    else
        unitFrame:Show()
    end

    unitFrame:SetSize(DB.Frame.Width, DB.Frame.Height)
    unitFrame:ClearAllPoints()
    local requiresParent = (unit == "targettarget" or unit == "pet" or unit == "focus")
    local parent = requiresParent and _G[DB.Frame.AnchorParent] or UIParent
    unitFrame:SetPoint(DB.Frame.AnchorFrom, parent or UIParent, DB.Frame.AnchorTo, DB.Frame.XPosition, DB.Frame.YPosition)
    unitFrame:SetBackdrop({bgFile = UUF.Media.BackgroundTexture, edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
    unitFrame:SetBackdropColor(unpack(DB.Frame.BGColour))
    unitFrame:SetBackdropBorderColor(0, 0, 0, 1)

    local unitHealthBar = unitFrame.healthBar
    local unitHealthBG = unitHealthBar.BG
    unitHealthBar:ClearAllPoints()
    unitHealthBar:SetPoint("TOPLEFT", unitFrame, "TOPLEFT", 1, -1)
    unitHealthBar:SetPoint("BOTTOMRIGHT", unitFrame, "BOTTOMRIGHT", -1, 1)
    unitFrame.healthBar:SetStatusBarTexture(UUF.Media.ForegroundTexture)

    local bgR, bgG, bgB, bgA = unpack(DB.Frame.BGColour)
    unitHealthBG:SetVertexColor(bgR, bgG, bgB, bgA)

    if unitFrame.NameText then
        local unitNameText = unitFrame.NameText
        local NameDB = DB.Tags.Name
        unitNameText:SetFont(UUF.Media.Font, NameDB.FontSize, GeneralDB.FontFlag)
        unitNameText:ClearAllPoints()
        unitNameText:SetPoint(NameDB.AnchorFrom, unitFrame, NameDB.AnchorTo, NameDB.OffsetX, NameDB.OffsetY)
        unitNameText:SetJustifyH(UUF:SetJustification(NameDB.AnchorFrom))
        unitNameText:SetShadowColor(unpack(GeneralDB.FontShadows.Colour))
        unitNameText:SetShadowOffset(GeneralDB.FontShadows.OffsetX, GeneralDB.FontShadows.OffsetY)

        if NameDB.Enabled then unitNameText:Show() else unitNameText:Hide() end
    end

    if unitFrame.HealthText then
        local unitHealthText = unitFrame.HealthText
        local HDB = DB.Tags.Health

        unitHealthText:SetFont(UUF.Media.Font, HDB.FontSize, GeneralDB.FontFlag)
        unitHealthText:ClearAllPoints()
        unitHealthText:SetPoint(HDB.AnchorFrom, unitFrame, HDB.AnchorTo, HDB.OffsetX, HDB.OffsetY)
        unitHealthText:SetJustifyH(UUF:SetJustification(HDB.AnchorFrom))
        unitHealthText:SetTextColor(unpack(HDB.Colour))
        unitHealthText:SetShadowColor(unpack(GeneralDB.FontShadows.Colour))
        unitHealthText:SetShadowOffset(GeneralDB.FontShadows.OffsetX, GeneralDB.FontShadows.OffsetY)

        if HDB.Enabled then unitHealthText:Show() else unitHealthText:Hide() end
    end

    local unitPowerBar = unitFrame.powerBar
    local unitPowerBarText = unitPowerBar and unitPowerBar.Text


    if not unitPowerBar then return end
    if DB.PowerBar.Enabled then
        unitPowerBar:SetHeight(DB.PowerBar.Height)
        unitPowerBar:SetStatusBarTexture(UUF.Media.ForegroundTexture)
        unitPowerBar:Show()

        unitPowerBar:ClearAllPoints()
        unitPowerBar:SetPoint("BOTTOMLEFT",  unitFrame, "BOTTOMLEFT",  1,  1)
        unitPowerBar:SetPoint("BOTTOMRIGHT", unitFrame, "BOTTOMRIGHT", -1,  1)
        if not unitPowerBar.bg then unitPowerBar.bg = unitPowerBar:CreateTexture(nil, "BACKGROUND") end
        unitPowerBar.bg:SetAllPoints()
        unitPowerBar.bg:SetTexture(UUF.Media.BackgroundTexture)
        unitPowerBar.bg:SetVertexColor(unpack(DB.PowerBar.BGColour or {0.1, 0.1, 0.1, 0.7}))
        unitHealthBar:ClearAllPoints()
        unitHealthBar:SetPoint("TOPLEFT",     unitFrame,    "TOPLEFT",  1, -1)
        unitHealthBar:SetPoint("BOTTOMLEFT",  unitPowerBar, "TOPLEFT",  0,  0)
        unitHealthBar:SetPoint("BOTTOMRIGHT", unitPowerBar, "TOPRIGHT", 0,  0)
    else
        unitPowerBar:Hide()
        unitHealthBar:ClearAllPoints()
        unitHealthBar:SetPoint("TOPLEFT",     unitFrame, "TOPLEFT",     1, -1)
        unitHealthBar:SetPoint("BOTTOMRIGHT", unitFrame, "BOTTOMRIGHT", -1, 1)
        if unitPowerBarText then unitPowerBarText:Hide() end
        return
    end
    if unitPowerBarText then
        local PBTextDB = DB.PowerBar.Text
        if not PBTextDB.Enabled then unitPowerBarText:Hide() return end
        unitPowerBarText:Show()
        unitPowerBarText:ClearAllPoints()
        if PBTextDB.AnchorParent == "FRAME" then
            unitPowerBarText:SetPoint(PBTextDB.AnchorFrom, unitFrame, PBTextDB.AnchorTo, PBTextDB.OffsetX, PBTextDB.OffsetY)
        else
            unitPowerBarText:SetPoint(PBTextDB.AnchorFrom, unitPowerBar, PBTextDB.AnchorTo, PBTextDB.OffsetX, PBTextDB.OffsetY)
        end
        unitPowerBarText:SetFont(UUF.Media.Font, PBTextDB.FontSize, GeneralDB.FontFlag)
        unitPowerBarText:SetJustifyH(UUF:SetJustification(PBTextDB.AnchorFrom))
        unitPowerBarText:SetTextColor(unpack(PBTextDB.Colour))
        unitPowerBarText:SetShadowColor(unpack(GeneralDB.FontShadows.Colour))
        unitPowerBarText:SetShadowOffset(GeneralDB.FontShadows.OffsetX, GeneralDB.FontShadows.OffsetY)
    end

    local unitMouseoverHighlight = unitFrame.MouseoverHighlight
    if unitMouseoverHighlight then
        unitFrame.MouseoverHighlight:SetBackdropColor(0,0,0,0)
        unitFrame.MouseoverHighlight:SetBackdropBorderColor(unpack(DB.Indicators.MouseoverHighlight.Colour))
    end

    unitFrame:UnregisterAllEvents()
    if DB.Enabled then
        unitFrame:RegisterEvent("UNIT_HEALTH")
        unitFrame:RegisterEvent("UNIT_MAXHEALTH")
        unitFrame:RegisterEvent("UNIT_NAME_UPDATE")
        unitFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        unitFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
        if unit == "pet" then unitFrame:RegisterEvent("UNIT_PET") end
        if unit == "focus" then unitFrame:RegisterEvent("PLAYER_FOCUS_CHANGED") end
        unitFrame:HookScript("OnEnter", function(self) DB = UUF.db.profile[unit] if DB.Indicators.MouseoverHighlight.Enabled then self.MouseoverHighlight:Show() end end)
        unitFrame:HookScript("OnLeave", function(self) DB = UUF.db.profile[unit] if DB.Indicators.MouseoverHighlight.Enabled then self.MouseoverHighlight:Hide() end end)
        unitFrame:SetScript("OnEvent", UpdateUnitFrame)
    else
        unitFrame:SetScript("OnEvent", nil)
        unitFrame:SetScript("OnEnter", nil)
        unitFrame:SetScript("OnLeave", nil)
    end

    if unitPowerBar then
        unitPowerBar:UnregisterAllEvents()
        if DB.PowerBar.Enabled then
            unitPowerBar:RegisterEvent("UNIT_POWER_UPDATE")
            unitPowerBar:RegisterEvent("UNIT_MAXPOWER")
            unitPowerBar:RegisterEvent("PLAYER_TARGET_CHANGED")
            unitPowerBar:SetScript("OnEvent", UpdateUnitFramePowerBar)
        else
            unitPowerBar:SetScript("OnEvent", nil)
        end
    end

    UpdateUnitFrame(unitFrame)
    if unitPowerBar then
        UpdateUnitFramePowerBar(unitPowerBar)
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
            BossFrame:SetPoint(adjustedAnchorFrom, UIParent, Frame.AnchorTo, Frame.XPosition, Frame.YPosition + offsetY)
        else
            local anchor = GrowDown and "TOPLEFT" or "BOTTOMLEFT"
            local relativeAnchor = GrowDown and "BOTTOMLEFT" or "TOPLEFT"
            local offsetY = GrowDown and -BossSpacing or BossSpacing
            BossFrame:SetPoint(anchor, _G["UUF_Boss" .. (i - 1)], relativeAnchor, 0, offsetY)
        end
    end
end