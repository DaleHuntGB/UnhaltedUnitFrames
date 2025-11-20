local _, UUF = ...

-- Helper Functions
local function ResolveFrameName(unit)
    if unit:match("^boss(%d+)$") then
        local unitID = unit:match("^boss(%d+)$")
        return "UUF_Boss" .. unitID
    end
    return UUF.UnitToFrameName[unit]
end

local function FetchUnitColour(unit, DB, GeneralDB)
    if not DB or not DB.Frame then return 1,1,1,1 end
    -- Pet should take the player colour.
    if DB.Frame.ClassColour then
        if unit == "pet" then
            local _, class = UnitClass("player")
            local classColour = RAID_CLASS_COLORS[class]
            if classColour then return classColour.r, classColour.g, classColour.b, 1 end
        end
        if UnitIsPlayer(unit) then
            local _, class = UnitClass(unit)
            local classColour = RAID_CLASS_COLORS[class]
            if classColour then return classColour.r, classColour.g, classColour.b, 1 end
        end
    end

    if DB.Frame.ReactionColour then
        local reaction = UnitReaction(unit, "player") or 5
        local reactionColour = GeneralDB.CustomColours.Reaction[reaction]
        if reactionColour then return reactionColour[1], reactionColour[2], reactionColour[3], 1 end
    end

    local foregroundColour = DB.Frame.FGColour
    return foregroundColour[1], foregroundColour[2], foregroundColour[3], foregroundColour[4] or 1
end

local function FetchNameTextColour(unit, DB, GeneralDB)
    local NDB = DB.Tags.Name

    if NDB.ColourByStatus then
        if unit == "pet" then
            local _, class = UnitClass("player")
            local classColour = RAID_CLASS_COLORS[class]
            if classColour then return classColour.r, classColour.g, classColour.b end
        end

        if UnitIsPlayer(unit) then
            local _, class = UnitClass(unit)
            local classColour = RAID_CLASS_COLORS[class]
            if classColour then return classColour.r, classColour.g, classColour.b end
        end

        local reaction = UnitReaction(unit, "player") or 5
        local reactionColour = GeneralDB.CustomColours.Reaction[reaction]
        if reactionColour then return reactionColour[1], reactionColour[2], reactionColour[3] end
    end

    local textColour = NDB.Colour
    return textColour[1], textColour[2], textColour[3]
end

local function FetchPowerBarColour(unit, DB, GeneralDB)
    local PDB = DB.PowerBar
    if not PDB then return 1,1,1,1 end

    if PDB.ColourByType then
        local powerType = UnitPowerType(unit)
        local powerColour = GeneralDB.CustomColours.Power[powerType]
        if powerColour then return powerColour[1], powerColour[2], powerColour[3], powerColour[4] or 1 end
    end

    local powerBarForegroundColour = PDB.FGColour
    return powerBarForegroundColour[1], powerBarForegroundColour[2], powerBarForegroundColour[3], powerBarForegroundColour[4] or 1
end

local function FormatHealthText(unit, DB, GeneralDB)
    if UnitIsDeadOrGhost(unit) then return "Dead" end

    local unitHP      = UnitHealth(unit)
    local unitMaxHP   = UnitHealthMax(unit)
    local unitPerHP = UnitHealthPercent(unit, false, true)
    local healthSeparator     = GeneralDB.HealthSeparator or "-"

    local layout = DB.Tags.Health.Layout
    if layout == "CurrPerHP" then
        if healthSeparator == "()" then
            return string.format("%s (%.0f%%)", AbbreviateLargeNumbers(unitHP), unitPerHP)
        else
            return string.format("%s %s %.0f%%", AbbreviateLargeNumbers(unitHP), healthSeparator, unitPerHP)
        end
    elseif layout == "CurrMaxHP" then
        return string.format("%s / %s", AbbreviateLargeNumbers(unitHP), AbbreviateLargeNumbers(unitMaxHP))
    elseif layout == "CurrHP" then
        return AbbreviateLargeNumbers(unitHP)
    elseif layout == "PerHP" then
        return string.format("%.0f%%", unitPerHP)
    end

    return ""
end

local function ApplyFrameLayout(unitFrame, unit, DB, GeneralDB)
    unitFrame:SetSize(DB.Frame.Width, DB.Frame.Height)

    local parent = UIParent
    if DB.Frame.AnchorParent and _G[DB.Frame.AnchorParent] then parent = _G[DB.Frame.AnchorParent] end
    unitFrame:ClearAllPoints()
    unitFrame:SetPoint(DB.Frame.AnchorFrom, parent, DB.Frame.AnchorTo, DB.Frame.XPosition, DB.Frame.YPosition)

    unitFrame:SetBackdrop({bgFile = UUF.Media.BackgroundTexture, edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
    unitFrame:SetBackdropColor(unpack(DB.Frame.BGColour))
    unitFrame:SetBackdropBorderColor(0,0,0,1)

    local unitHealthBar = unitFrame.healthBar
    unitHealthBar:ClearAllPoints()

    if DB.PowerBar and DB.PowerBar.Enabled and unitFrame.powerBar then
        local unitPowerBar = unitFrame.powerBar
        unitPowerBar:Show()
        unitPowerBar:SetHeight(DB.PowerBar.Height)
        unitPowerBar:SetStatusBarTexture(UUF.Media.ForegroundTexture)

        unitPowerBar:ClearAllPoints()
        unitPowerBar:SetPoint("BOTTOMLEFT",  unitFrame, "BOTTOMLEFT", 1, 1)
        unitPowerBar:SetPoint("BOTTOMRIGHT", unitFrame, "BOTTOMRIGHT", -1, 1)

        if not unitPowerBar.BG then unitPowerBar.BG = unitPowerBar:CreateTexture(nil, "BACKGROUND") end
        unitPowerBar.BG:SetAllPoints()
        unitPowerBar.BG:SetTexture(UUF.Media.BackgroundTexture)
        unitPowerBar.BG:SetVertexColor(unpack(DB.PowerBar.BGColour))

        unitHealthBar:SetPoint("TOPLEFT", unitFrame, "TOPLEFT", 1, -1)
        unitHealthBar:SetPoint("BOTTOMLEFT", unitPowerBar, "TOPLEFT", 0, 0)
        unitHealthBar:SetPoint("BOTTOMRIGHT", unitPowerBar, "TOPRIGHT", 0, 0)
    else
        if unitFrame.powerBar then unitFrame.powerBar:Hide() end
        unitHealthBar:SetPoint("TOPLEFT",     unitFrame, "TOPLEFT",     1, -1)
        unitHealthBar:SetPoint("BOTTOMRIGHT", unitFrame, "BOTTOMRIGHT", -1, 1)
    end
    unitHealthBar:SetStatusBarTexture(UUF.Media.ForegroundTexture)

    local unitNameText = unitFrame.NameText
    local NDB = DB.Tags.Name
    unitNameText:SetFont(UUF.Media.Font, NDB.FontSize, GeneralDB.FontFlag)
    unitNameText:ClearAllPoints()
    unitNameText:SetPoint(NDB.AnchorFrom, unitFrame, NDB.AnchorTo, NDB.OffsetX, NDB.OffsetY)
    unitNameText:SetJustifyH(UUF:SetJustification(NDB.AnchorFrom))
    unitNameText:SetShadowColor(unpack(GeneralDB.FontShadows.Colour))
    unitNameText:SetShadowOffset(GeneralDB.FontShadows.OffsetX, GeneralDB.FontShadows.OffsetY)
    if NDB.Enabled then unitNameText:Show() else unitNameText:Hide() end

    local unitHealthText = unitFrame.HealthText
    local HDB  = DB.Tags.Health
    unitHealthText:SetFont(UUF.Media.Font, HDB.FontSize, GeneralDB.FontFlag)
    unitHealthText:ClearAllPoints()
    unitHealthText:SetPoint(HDB.AnchorFrom, unitFrame, HDB.AnchorTo, HDB.OffsetX, HDB.OffsetY)
    unitHealthText:SetJustifyH(UUF:SetJustification(HDB.AnchorFrom))
    unitHealthText:SetTextColor(unpack(HDB.Colour))
    unitHealthText:SetShadowColor(unpack(GeneralDB.FontShadows.Colour))
    unitHealthText:SetShadowOffset(GeneralDB.FontShadows.OffsetX, GeneralDB.FontShadows.OffsetY)
    if HDB.Enabled then unitHealthText:Show() else unitHealthText:Hide() end

    if unitFrame.powerBar and unitFrame.powerBar.Text then
        local unitPowerText = unitFrame.powerBar.Text
        local PTDB = DB.PowerBar.Text

        unitPowerText:ClearAllPoints()
        unitPowerText:SetFont(UUF.Media.Font, PTDB.FontSize, GeneralDB.FontFlag)
        unitPowerText:SetJustifyH(UUF:SetJustification(PTDB.AnchorFrom))
        unitPowerText:SetTextColor(unpack(PTDB.Colour))
        unitPowerText:SetShadowColor(unpack(GeneralDB.FontShadows.Colour))
        unitPowerText:SetShadowOffset(GeneralDB.FontShadows.OffsetX, GeneralDB.FontShadows.OffsetY)

        if PTDB.Enabled then
            unitPowerText:Show()
            if PTDB.AnchorParent == "FRAME" then
                unitPowerText:SetPoint(PTDB.AnchorFrom, unitFrame, PTDB.AnchorTo, PTDB.OffsetX, PTDB.OffsetY)
            else
                unitPowerText:SetPoint(PTDB.AnchorFrom, unitFrame.powerBar, PTDB.AnchorTo, PTDB.OffsetX, PTDB.OffsetY)
            end
        else
            unitPowerText:Hide()
        end
    end

    local unitMouseoverHighlight = unitFrame.MouseoverHighlight
    unitMouseoverHighlight:SetBackdropBorderColor(unpack(DB.Indicators.MouseoverHighlight.Colour))
end

local function ApplyFrameColours(unitFrame, unit, DB, GeneralDB)
    local unitHealthBar = unitFrame.healthBar
    local r,g,b,a = FetchUnitColour(unit, DB, GeneralDB)
    unitHealthBar:SetStatusBarColor(r,g,b,a)

    local unitFrameBGR,unitFrameBGG,unitFrameBGB,unitFrameBGA = unpack(DB.Frame.BGColour)
    unitHealthBar.BG:SetVertexColor(unitFrameBGR,unitFrameBGG,unitFrameBGB,unitFrameBGA)

    local nameTextR,nameTextG,nameTextB = FetchNameTextColour(unit, DB, GeneralDB)
    unitFrame.NameText:SetTextColor(nameTextR,nameTextG,nameTextB)

    if unitFrame.powerBar then
        local powerBarR,powerBarG,powerBarB,powerBarA = FetchPowerBarColour(unit, DB, GeneralDB)
        unitFrame.powerBar:SetStatusBarColor(powerBarR,powerBarG,powerBarB,powerBarA)
        if DB.PowerBar.Text.Enabled then
            if DB.PowerBar.Text.ColourByType then
                unitFrame.powerBar.Text:SetTextColor(powerBarR,powerBarG,powerBarB,powerBarA)
            end
        end
    end
end

local function UpdateUnitFrameData(unitFrame, unit, DB, GeneralDB)
    local unitHP = UnitHealth(unit)
    local unitMaxHP = UnitHealthMax(unit)

    unitFrame.healthBar:SetMinMaxValues(0, unitMaxHP)
    unitFrame.healthBar:SetValue(unitHP)

    unitFrame.HealthText:SetText(FormatHealthText(unit, DB, GeneralDB))
    unitFrame.NameText:SetText(UnitName(unit) or "")

    if unitFrame.powerBar then
        local unitPower = UnitPower(unit)
        unitFrame.powerBar:SetMinMaxValues(0, UnitPowerMax(unit))
        unitFrame.powerBar:SetValue(unitPower)

        if DB.PowerBar.Text.Enabled then
            local powerType = UnitPowerType(unit)
            if powerType == 0 then
                unitFrame.powerBar.Text:SetText(string.format("%.0f%%", UnitPowerPercent(unit, Enum.PowerType.Mana, false, true)))
            else
                unitFrame.powerBar.Text:SetText(AbbreviateLargeNumbers(unitPower))
            end
        end
    end
end

local function RefreshUnitEvents(unitFrame, unit, DB)
    unitFrame:UnregisterAllEvents()

    if not DB.Enabled then
        unitFrame:SetScript("OnEvent", nil)
        unitFrame:Hide()
        UnregisterUnitWatch(unitFrame)
        return
    end

    RegisterUnitWatch(unitFrame)
    unitFrame:Show()

    unitFrame:RegisterUnitEvent("UNIT_HEALTH", unit)
    unitFrame:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
    unitFrame:RegisterUnitEvent("UNIT_NAME_UPDATE", unit)
    unitFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    unitFrame:RegisterEvent("PLAYER_TARGET_CHANGED")

    if unit == "pet" then unitFrame:RegisterEvent("UNIT_PET") end
    if unit == "focus" then unitFrame:RegisterEvent("PLAYER_FOCUS_CHANGED") end

    unitFrame:SetScript("OnEvent", function(self) UUF:UpdateUnitFrame(unit) end)

    if unitFrame.powerBar then
        local powerBar = unitFrame.powerBar
        powerBar:UnregisterAllEvents()
        if DB.PowerBar.Enabled then
            powerBar:RegisterEvent("UNIT_POWER_UPDATE")
            powerBar:RegisterEvent("UNIT_MAXPOWER")
            powerBar:RegisterEvent("PLAYER_TARGET_CHANGED")
            powerBar:SetScript("OnEvent", function(bar) UUF:UpdateUnitFrame(unit) end)
        else
            powerBar:SetScript("OnEvent", nil)
        end
    end
end

local LayoutConfig = {
    TOPLEFT     = { anchor="TOPLEFT",   offsetMultiplier=0   },
    TOP         = { anchor="TOP",       offsetMultiplier=0   },
    TOPRIGHT    = { anchor="TOPRIGHT",  offsetMultiplier=0   },

    BOTTOMLEFT  = { anchor="BOTTOMLEFT",   offsetMultiplier=0   },
    BOTTOM      = { anchor="BOTTOM",       offsetMultiplier=0   },
    BOTTOMRIGHT = { anchor="BOTTOMRIGHT",  offsetMultiplier=0   },

    CENTER      = { anchor="CENTER",    offsetMultiplier=0, isCenter=true },
    LEFT        = { anchor="LEFT",      offsetMultiplier=0, isCenter=true },
    RIGHT       = { anchor="RIGHT",     offsetMultiplier=0, isCenter=true },
}

function UUF:LayoutBossFrames()
    local DB = UUF.db.profile.boss
    if not DB or not DB.Frame or not UUF.BossFrames or #UUF.BossFrames == 0 then return end
    local FrameDB = DB.Frame
    local bossFrames = UUF.BossFrames
    if FrameDB.GrowthDirection == "UP" then
        local reversedLayout = {}
        for i = #bossFrames, 1, -1 do
            reversedLayout[#reversedLayout+1] = bossFrames[i]
        end
        bossFrames = reversedLayout
    end
    local layoutConfig = LayoutConfig[FrameDB.AnchorFrom] or LayoutConfig.CENTER
    local totalHeight = (#bossFrames * (FrameDB.Height or 42)) + ((#bossFrames - 1) * FrameDB.Spacing)
    local offsetY = 0
    if layoutConfig.isCenter then offsetY = -(totalHeight / 2) + ((FrameDB.Height or 42) / 2) end

    local containerParent = UIParent
    local startX = FrameDB.XPosition
    local startY = FrameDB.YPosition + offsetY

    local firstBossFrame = bossFrames[1]
    firstBossFrame:ClearAllPoints()
    firstBossFrame:SetPoint(layoutConfig.anchor, containerParent, FrameDB.AnchorTo, startX, startY)

    for i = 2, #bossFrames do
        bossFrames[i]:ClearAllPoints()
        bossFrames[i]:SetPoint("TOP", bossFrames[i-1], "BOTTOM", 0, -FrameDB.Spacing)
    end
end

function UUF:CreateUnitFrame(unit)
    local dbUnit = unit:match("^boss%d+$") and "boss" or unit
    local DB = UUF.db.profile[dbUnit]
    local GeneralDB = UUF.db.profile.General
    if not DB then return end

    local frameName = ResolveFrameName(unit)
    local unitFrame = CreateFrame("Button", frameName, UIParent, "SecureUnitButtonTemplate,BackdropTemplate,PingableUnitFrameTemplate")
    unitFrame.unit = unit
    unitFrame.dbUnit = dbUnit

    unitFrame.healthBar = CreateFrame("StatusBar", nil, unitFrame)
    unitFrame.healthBar:SetPoint("TOPLEFT", unitFrame, "TOPLEFT", 1, -1)
    unitFrame.healthBar:SetPoint("BOTTOMRIGHT", unitFrame, "BOTTOMRIGHT", -1, 1)
    unitFrame.healthBar:SetStatusBarTexture(UUF.Media.ForegroundTexture)
    unitFrame.healthBar.BG = unitFrame.healthBar:CreateTexture(nil, "BACKGROUND")
    unitFrame.healthBar.BG:SetAllPoints()
    unitFrame.healthBar.BG:SetTexture(UUF.Media.BackgroundTexture)
    unitFrame.NameText = unitFrame.healthBar:CreateFontString(nil, "OVERLAY")
    unitFrame.HealthText = unitFrame.healthBar:CreateFontString(nil, "OVERLAY")
    unitFrame.MouseoverHighlight = CreateFrame("Frame", nil, unitFrame, "BackdropTemplate")
    unitFrame.MouseoverHighlight:SetAllPoints()
    unitFrame.MouseoverHighlight:SetBackdrop({ bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", edgeSize=1 })
    unitFrame.MouseoverHighlight:SetBackdropColor(0,0,0,0)
    unitFrame.MouseoverHighlight:Hide()
    unitFrame:SetScript("OnEnter", function(self) local DB = UUF.db.profile[self.dbUnit] if DB.Indicators.MouseoverHighlight.Enabled then self.MouseoverHighlight:Show() end UnitFrame_OnEnter(self) end)
    unitFrame:SetScript("OnLeave", function(self) local DB = UUF.db.profile[self.dbUnit] if DB.Indicators.MouseoverHighlight.Enabled then self.MouseoverHighlight:Hide() end UnitFrame_OnLeave(self) end)
    if unit ~= "pet" and unit ~= "focus" then
        unitFrame.powerBar = CreateFrame("StatusBar", nil, unitFrame)
        unitFrame.powerBar:SetStatusBarTexture(UUF.Media.ForegroundTexture)
        unitFrame.powerBar.Text = unitFrame.powerBar:CreateFontString(nil, "OVERLAY")
    end

    unitFrame:RegisterForClicks("AnyUp")
    unitFrame:SetAttribute("unit", unit)
    unitFrame:SetAttribute("*type1", "target")
    unitFrame:SetAttribute("*type2", "togglemenu")

    ApplyFrameLayout(unitFrame, unit, DB, GeneralDB)
    ApplyFrameColours(unitFrame, unit, DB, GeneralDB)
    UpdateUnitFrameData(unitFrame, unit, DB, GeneralDB)
    RefreshUnitEvents(unitFrame, unit, DB)

    return unitFrame
end

function UUF:UpdateUnitFrame(unit)
    if not unit then return end

    local frameName = ResolveFrameName(unit)
    local unitFrame = _G[frameName]
    if not unitFrame then return end

    local dbUnit = unit:match("^boss%d+$") and "boss" or unit
    local DB = UUF.db.profile[dbUnit]
    local GeneralDB = UUF.db.profile.General

    ApplyFrameLayout(unitFrame, unit, DB, GeneralDB)
    ApplyFrameColours(unitFrame, unit, DB, GeneralDB)
    UpdateUnitFrameData(unitFrame, unit, DB, GeneralDB)
    if not UUF.BossTestMode then
        RefreshUnitEvents(unitFrame, unit, DB)
    end
end