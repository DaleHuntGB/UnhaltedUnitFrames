local _, UUF = ...

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

    local unitTagOne = unitFrame.TagOne
    local T1 = DB.Tags.TagOne
    unitTagOne:SetFont(UUF.Media.Font, T1.FontSize, GeneralDB.FontFlag)
    unitTagOne:ClearAllPoints()
    unitTagOne:SetPoint(T1.AnchorFrom, unitFrame, T1.AnchorTo, T1.OffsetX, T1.OffsetY)
    unitTagOne:SetJustifyH(UUF:SetJustification(T1.AnchorFrom))
    unitTagOne:SetShadowColor(unpack(GeneralDB.FontShadows.Colour))
    unitTagOne:SetShadowOffset(GeneralDB.FontShadows.OffsetX, GeneralDB.FontShadows.OffsetY)

    local unitTagTwo = unitFrame.TagTwo
    local T2  = DB.Tags.TagTwo
    unitTagTwo:SetFont(UUF.Media.Font, T2.FontSize, GeneralDB.FontFlag)
    unitTagTwo:ClearAllPoints()
    unitTagTwo:SetPoint(T2.AnchorFrom, unitFrame, T2.AnchorTo, T2.OffsetX, T2.OffsetY)
    unitTagTwo:SetJustifyH(UUF:SetJustification(T2.AnchorFrom))
    unitTagTwo:SetTextColor(unpack(T2.Colour))
    unitTagTwo:SetShadowColor(unpack(GeneralDB.FontShadows.Colour))
    unitTagTwo:SetShadowOffset(GeneralDB.FontShadows.OffsetX, GeneralDB.FontShadows.OffsetY)

    local unitTagThree = unitFrame.TagThree
    local T3 = DB.Tags.TagThree
    unitTagThree:SetFont(UUF.Media.Font, T3.FontSize, GeneralDB.FontFlag)
    unitTagThree:ClearAllPoints()
    unitTagThree:SetPoint(T3.AnchorFrom, unitFrame, T3.AnchorTo, T3.OffsetX, T3.OffsetY)
    unitTagThree:SetJustifyH(UUF:SetJustification(T3.AnchorFrom))
    unitTagThree:SetTextColor(unpack(T3.Colour))
    unitTagThree:SetShadowColor(unpack(GeneralDB.FontShadows.Colour))
    unitTagThree:SetShadowOffset(GeneralDB.FontShadows.OffsetX, GeneralDB.FontShadows.OffsetY)

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

    if unitFrame.CombatTexture then
        if DB.Indicators.Status.CombatTexture == "DEFAULT" then
            unitFrame.CombatTexture:SetTexture([[Interface\CharacterFrame\UI-StateIcon]])
            unitFrame.CombatTexture:SetTexCoord(0.5, 1, 0, 0.49)
        else
            unitFrame.CombatTexture:SetTexture(UUF.StatusTextureMap[DB.Indicators.Status.CombatTexture])
            unitFrame.CombatTexture:SetTexCoord(0, 1, 0, 1)
        end
        unitFrame.CombatTexture:SetSize(DB.Indicators.Status.Size, DB.Indicators.Status.Size)
        unitFrame.CombatTexture:ClearAllPoints()
        unitFrame.CombatTexture:SetPoint(DB.Indicators.Status.AnchorFrom, unitFrame, DB.Indicators.Status.AnchorTo, DB.Indicators.Status.OffsetX, DB.Indicators.Status.OffsetY)
        unitFrame.CombatTexture:SetDrawLayer("OVERLAY", 7)
        if DB.Indicators.Status.Combat then
            unitFrame.CombatTexture:Show()
        else
            unitFrame.CombatTexture:Hide()
        end
    end

    if unitFrame.RestingTexture then
        if DB.Indicators.Status.RestingTexture == "DEFAULT" then
            unitFrame.RestingTexture:SetTexture([[Interface\CharacterFrame\UI-StateIcon]])
            unitFrame.RestingTexture:SetTexCoord(0, 0.5, 0, 0.421875)
        else
            unitFrame.RestingTexture:SetTexture(UUF.StatusTextureMap[DB.Indicators.Status.RestingTexture])
            unitFrame.RestingTexture:SetTexCoord(0, 1, 0, 1)
        end
        unitFrame.RestingTexture:SetSize(DB.Indicators.Status.Size, DB.Indicators.Status.Size)
        unitFrame.RestingTexture:ClearAllPoints()
        unitFrame.RestingTexture:SetPoint(DB.Indicators.Status.AnchorFrom, unitFrame, DB.Indicators.Status.AnchorTo, DB.Indicators.Status.OffsetX, DB.Indicators.Status.OffsetY)
        unitFrame.RestingTexture:SetDrawLayer("OVERLAY", 7)
        if DB.Indicators.Status.Resting then
            unitFrame.RestingTexture:Show()
        else
            unitFrame.RestingTexture:Hide()
        end
    end
end

local function ApplyFrameColours(unitFrame, unit, DB, GeneralDB)
    local unitHealthBar = unitFrame.healthBar
    local r,g,b,a = FetchUnitColour(unit, DB, GeneralDB)
    unitHealthBar:SetStatusBarColor(r,g,b,a)

    local unitFrameBGR,unitFrameBGG,unitFrameBGB,unitFrameBGA = unpack(DB.Frame.BGColour)
    unitHealthBar.BG:SetVertexColor(unitFrameBGR,unitFrameBGG,unitFrameBGB,unitFrameBGA)

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

    unitFrame.TagOne:SetText(UUF:EvaluateTagString(unit, (DB.Tags.TagOne.Tag or "")))
    unitFrame.TagTwo:SetText(UUF:EvaluateTagString(unit, (DB.Tags.TagTwo.Tag or "")))
    unitFrame.TagThree:SetText(UUF:EvaluateTagString(unit, (DB.Tags.TagThree.Tag or "")))
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

    if unit == "player" then
        local inCombat  = DB.Indicators.Status.Combat  and UnitAffectingCombat("player")
        local isResting = DB.Indicators.Status.Resting and IsResting()

        if unitFrame.CombatTexture then
            if inCombat then
                unitFrame.CombatTexture:Show()
            else
                unitFrame.CombatTexture:Hide()
            end
        end

        if unitFrame.RestingTexture then
            if isResting and not inCombat then
                unitFrame.RestingTexture:Show()
            else
                unitFrame.RestingTexture:Hide()
            end
        end
    end
end

local function RefreshUnitEvents(unitFrame, unit, DB)
    if UUF.BossTestMode then return end
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
    unitFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    unitFrame:RegisterEvent("PLAYER_REGEN_DISABLED")

    if unit == "pet" then unitFrame:RegisterEvent("UNIT_PET") end
    if unit == "focus" then unitFrame:RegisterEvent("PLAYER_FOCUS_CHANGED") end

    unitFrame:SetScript("OnEvent", function(self) if UUF.BossTestMode then UUF:UpdateUnitFrame(self.unit) else if UnitExists(self.unit) then UUF:UpdateUnitFrame(self.unit) end end end)

    if unitFrame.powerBar then
        local powerBar = unitFrame.powerBar
        powerBar:UnregisterAllEvents()
        if DB.PowerBar.Enabled then
            powerBar:RegisterUnitEvent("UNIT_POWER_UPDATE", unit)
            powerBar:RegisterUnitEvent("UNIT_MAXPOWER", unit)
            powerBar:RegisterEvent("PLAYER_TARGET_CHANGED")
            powerBar:SetScript("OnEvent", function(self) if UUF.BossTestMode then UUF:UpdateUnitFrame(self.unit) else if UnitExists(self.unit) then UUF:UpdateUnitFrame(self.unit) end end end)
        else
            powerBar:SetScript("OnEvent", nil)
        end
    end
end

local LayoutConfig = {
    TOPLEFT     = { anchor="TOPLEFT",   offsetMultiplier=0   },
    TOP         = { anchor="TOP",       offsetMultiplier=0   },
    TOPRIGHT    = { anchor="TOPRIGHT",  offsetMultiplier=0   },
    BOTTOMLEFT  = { anchor="TOPLEFT",   offsetMultiplier=1   },
    BOTTOM      = { anchor="TOP",       offsetMultiplier=1   },
    BOTTOMRIGHT = { anchor="TOPRIGHT",  offsetMultiplier=1   },
    CENTER      = { anchor="CENTER",    offsetMultiplier=0.5, isCenter=true },
    LEFT        = { anchor="LEFT",      offsetMultiplier=0.5, isCenter=true },
    RIGHT       = { anchor="RIGHT",     offsetMultiplier=0.5, isCenter=true },
}

function UUF:LayoutBossFrames()
    local Frame = UUF.db.profile.boss.Frame
    if #UUF.BossFrames == 0 then return end
    local bossFrames = UUF.BossFrames
    if Frame.GrowthDirection == "UP" then
        bossFrames = {}
        for i = #UUF.BossFrames, 1, -1 do bossFrames[#bossFrames+1] = UUF.BossFrames[i] end
    end
    local layoutConfig = LayoutConfig[Frame.AnchorFrom]
    local frameHeight = bossFrames[1]:GetHeight()
    local containerHeight = (frameHeight + Frame.Spacing) * #bossFrames - Frame.Spacing
    local offsetY = containerHeight * layoutConfig.offsetMultiplier
    if layoutConfig.isCenter then offsetY = offsetY - (frameHeight / 2) end
    local initialAnchor = AnchorUtil.CreateAnchor(layoutConfig.anchor, UIParent, Frame.AnchorTo, Frame.XPosition, Frame.YPosition + offsetY)
    AnchorUtil.VerticalLayout(bossFrames, initialAnchor, Frame.Spacing)
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
    unitFrame.TagOne = unitFrame.healthBar:CreateFontString(nil, "OVERLAY")
    unitFrame.TagTwo = unitFrame.healthBar:CreateFontString(nil, "OVERLAY")
    unitFrame.TagThree = unitFrame.healthBar:CreateFontString(nil, "OVERLAY")
    unitFrame.MouseoverHighlight = CreateFrame("Frame", nil, unitFrame, "BackdropTemplate")
    unitFrame.MouseoverHighlight:SetAllPoints()
    unitFrame.MouseoverHighlight:SetBackdrop({ bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", edgeSize=1 })
    unitFrame.MouseoverHighlight:SetBackdropColor(0,0,0,0)
    unitFrame.MouseoverHighlight:Hide()
    if unit == "player" then
        unitFrame.CombatTexture  = unitFrame.healthBar:CreateTexture(frameName.."_CombatIndicator", "OVERLAY")
        unitFrame.RestingTexture = unitFrame.healthBar:CreateTexture(frameName.."_RestingIndicator", "OVERLAY")
    end
    unitFrame:SetScript("OnEnter", function(self) local DB = UUF.db.profile[self.dbUnit] if DB.Indicators.MouseoverHighlight.Enabled then self.MouseoverHighlight:Show() end UnitFrame_OnEnter(self) end)
    unitFrame:SetScript("OnLeave", function(self) local DB = UUF.db.profile[self.dbUnit] if DB.Indicators.MouseoverHighlight.Enabled then self.MouseoverHighlight:Hide() end UnitFrame_OnLeave(self) end)
    if unit ~= "pet" and unit ~= "focus" then
        unitFrame.powerBar = CreateFrame("StatusBar", nil, unitFrame)
        unitFrame.powerBar:SetStatusBarTexture(UUF.Media.ForegroundTexture)
        unitFrame.powerBar.Text = unitFrame.powerBar:CreateFontString(nil, "OVERLAY")
        unitFrame.powerBar.unit = unit
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

-- Only update data & colours in combat.
function UUF:UpdateUnitFrame(unit)
    if not unit then return end
    local frameName = ResolveFrameName(unit)
    local unitFrame = _G[frameName]
    if not unitFrame then return end
    local dbUnit = unit:match("^boss%d+$") and "boss" or unit
    local DB = UUF.db.profile[dbUnit]
    local GeneralDB = UUF.db.profile.General
    ApplyFrameColours(unitFrame, unit, DB, GeneralDB)
    UpdateUnitFrameData(unitFrame, unit, DB, GeneralDB)
end

-- Update & assign all events outside of combat.
function UUF:RefreshUnitFrame(unit)
    if not unit then return end
    local frameName = ResolveFrameName(unit)
    local unitFrame = _G[frameName]
    if not unitFrame then return end
    local dbUnit = unit:match("^boss%d+$") and "boss" or unit
    local DB = UUF.db.profile[dbUnit]
    RefreshUnitEvents(unitFrame, unit, DB)
end

-- Full update of layout, colours, data & events outside of combat.
-- Usually called after changing configuration settings.
function UUF:FullFrameUpdate(unit)
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
    RefreshUnitEvents(unitFrame, unit, DB)
end