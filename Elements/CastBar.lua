local _, UUF = ...

local function ShortenCastName(text, maxChars)
    if not text then return "" end
    if maxChars and maxChars > 0 then
        text = string.format("%." .. maxChars .. "s", text)
    end
    return UUF:CleanTruncateUTF8String(text)
end

function UUF:CreateUnitCastBar(unitFrame, unit)
    local FontDB = UUF.db.profile.General.Fonts
    local GeneralDB = UUF.db.profile.General
    local FrameDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Frame
    local CastBarDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].CastBar
    local SpellNameDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].CastBar.Text.SpellName
    local DurationDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].CastBar.Text.Duration

    local CastBarContainer = CreateFrame("Frame", UUF:FetchFrameName(unit) .. "_CastBarContainer", unitFrame, "BackdropTemplate")
    CastBarContainer:SetBackdrop(UUF.BACKDROP)
    CastBarContainer:SetBackdropColor(0, 0, 0, 0)
    if CastBarDB.ShowBorder then
        CastBarContainer:SetBackdropBorderColor(unpack(CastBarDB.BorderColour))
    else
        CastBarContainer:SetBackdropBorderColor(0, 0, 0, 0)
    end
    CastBarContainer:ClearAllPoints()
    CastBarContainer:SetPoint(CastBarDB.Layout[1], unitFrame, CastBarDB.Layout[2], CastBarDB.Layout[3], CastBarDB.Layout[4])
    if CastBarDB.MatchParentWidth then CastBarContainer:SetWidth(FrameDB.Width) else CastBarContainer:SetWidth(CastBarDB.Width) end
    CastBarContainer:SetHeight(CastBarDB.Height)
    CastBarContainer:SetFrameStrata(CastBarDB.FrameStrata)

    local CastBar = CreateFrame("StatusBar", UUF:FetchFrameName(unit) .. "_CastBar", CastBarContainer)
    CastBar:SetStatusBarTexture(UUF.Media.Foreground)
    CastBar:ClearAllPoints()
    CastBar:SetPoint("TOPLEFT", CastBarContainer, "TOPLEFT", 1, -1)
    CastBar:SetPoint("BOTTOMRIGHT", CastBarContainer, "BOTTOMRIGHT", -1, 1)
    CastBar:SetFrameLevel(CastBarContainer:GetFrameLevel() + 1)
    CastBar:SetStatusBarColor(unpack(CastBarDB.Foreground))

    CastBar.Background = CastBar:CreateTexture(nil, "BACKGROUND")
    CastBar.Background:SetAllPoints(CastBar)
    CastBar.Background:SetTexture(UUF.Media.Background)
    CastBar.Background:SetVertexColor(unpack(CastBarDB.Background))

    CastBar.NotInterruptibleOverlay = CastBar:CreateTexture(nil, "ARTWORK", nil, 1)
    CastBar.NotInterruptibleOverlay:SetPoint("TOPLEFT", CastBar:GetStatusBarTexture(), "TOPLEFT")
    CastBar.NotInterruptibleOverlay:SetPoint("BOTTOMRIGHT", CastBar:GetStatusBarTexture(), "BOTTOMRIGHT")
    CastBar.NotInterruptibleOverlay:SetTexture(UUF.Media.Foreground)
    CastBar.NotInterruptibleOverlay:SetVertexColor(unpack(CastBarDB.NotInterruptibleColour))
    CastBar.NotInterruptibleOverlay:SetAlpha(0) -- Hidden by default

    CastBar.Icon = CastBar:CreateTexture(UUF:FetchFrameName(unit) .. "_CastBarIcon", "ARTWORK")
    CastBar.Icon:SetSize(CastBarDB.Height - 2, CastBarDB.Height - 2)
    CastBar.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    CastBar.Icon:ClearAllPoints()
    if CastBarDB.Icon.Enabled and CastBarDB.Icon.Position == "LEFT" then
        CastBar.Icon:SetPoint("TOPLEFT", CastBarContainer, "TOPLEFT", 1, -1)
        CastBar:ClearAllPoints()
        CastBar:SetPoint("TOPLEFT", CastBarContainer, "TOPLEFT", CastBarDB.Height - 1, -1)
        CastBar:SetPoint("BOTTOMRIGHT", CastBarContainer, "BOTTOMRIGHT", -1, 1)
    elseif CastBarDB.Icon.Enabled and CastBarDB.Icon.Position == "RIGHT" then
        CastBar.Icon:SetPoint("TOPRIGHT", CastBarContainer, "TOPRIGHT", -1, -1)
        CastBar:ClearAllPoints()
        CastBar:SetPoint("TOPLEFT", CastBarContainer, "TOPLEFT", 1, -1)
        CastBar:SetPoint("BOTTOMRIGHT", CastBarContainer, "BOTTOMRIGHT", -(CastBarDB.Height - 1), 1)
    elseif not CastBarDB.Icon.Enabled then
        CastBar.Icon:Hide()
        CastBar:ClearAllPoints()
        CastBar:SetPoint("TOPLEFT", CastBarContainer, "TOPLEFT", 1, -1)
        CastBar:SetPoint("BOTTOMRIGHT", CastBarContainer, "BOTTOMRIGHT", -1, 1)
    end

    local SpellNameText = CastBar:CreateFontString(UUF:FetchFrameName(unit) .. "_CastBarSpellNameText", "OVERLAY")
    SpellNameText:ClearAllPoints()
    SpellNameText:SetPoint(SpellNameDB.Layout[1], CastBar, SpellNameDB.Layout[2], SpellNameDB.Layout[3], SpellNameDB.Layout[4])
    SpellNameText:SetFont(UUF.Media.Font, SpellNameDB.FontSize, GeneralDB.Fonts.FontFlag)
    if GeneralDB.Fonts.Shadow.Enabled then
        SpellNameText:SetShadowColor(GeneralDB.Fonts.Shadow.Colour[1], GeneralDB.Fonts.Shadow.Colour[2], GeneralDB.Fonts.Shadow.Colour[3], GeneralDB.Fonts.Shadow.Colour[4])
        SpellNameText:SetShadowOffset(GeneralDB.Fonts.Shadow.XPos, GeneralDB.Fonts.Shadow.YPos)
    else
        SpellNameText:SetShadowColor(0, 0, 0, 0)
        SpellNameText:SetShadowOffset(0, 0)
    end
    SpellNameText:SetTextColor(unpack(SpellNameDB.Colour))
    if FontDB.Shadow.Enabled then
        SpellNameText:SetShadowColor(FontDB.Shadow.Colour[1], FontDB.Shadow.Colour[2], FontDB.Shadow.Colour[3], FontDB.Shadow.Colour[4])
        SpellNameText:SetShadowOffset(FontDB.Shadow.XPos, FontDB.Shadow.YPos)
    else
        SpellNameText:SetShadowColor(0, 0, 0, 0)
        SpellNameText:SetShadowOffset(0, 0)
    end
    SpellNameText:SetJustifyH(UUF:SetJustification(SpellNameDB.Layout[1]))

    local DurationText = CastBar:CreateFontString(UUF:FetchFrameName(unit) .. "_CastBarDurationText", "OVERLAY")
    DurationText:ClearAllPoints()
    DurationText:SetPoint(DurationDB.Layout[1], CastBar, DurationDB.Layout[2], DurationDB.Layout[3], DurationDB.Layout[4])
    DurationText:SetFont(UUF.Media.Font, DurationDB.FontSize, GeneralDB.Fonts.FontFlag)
    if GeneralDB.Fonts.Shadow.Enabled then
        DurationText:SetShadowColor(GeneralDB.Fonts.Shadow.Colour[1], GeneralDB.Fonts.Shadow.Colour[2], GeneralDB.Fonts.Shadow.Colour[3], GeneralDB.Fonts.Shadow.Colour[4])
        DurationText:SetShadowOffset(GeneralDB.Fonts.Shadow.XPos, GeneralDB.Fonts.Shadow.YPos)
    else
        DurationText:SetShadowColor(0, 0, 0, 0)
        DurationText:SetShadowOffset(0, 0)
    end
    DurationText:SetTextColor(unpack(DurationDB.Colour))
    if FontDB.Shadow.Enabled then
        DurationText:SetShadowColor(FontDB.Shadow.Colour[1], FontDB.Shadow.Colour[2], FontDB.Shadow.Colour[3], FontDB.Shadow.Colour[4])
        DurationText:SetShadowOffset(FontDB.Shadow.XPos, FontDB.Shadow.YPos)
    else
        DurationText:SetShadowColor(0, 0, 0, 0)
        DurationText:SetShadowOffset(0, 0)
    end
    DurationText:SetJustifyH(UUF:SetJustification(DurationDB.Layout[1]))

    if CastBarDB.Inverse then
        CastBar:SetReverseFill(true)
    else
        CastBar:SetReverseFill(false)
    end

    if CastBarDB.Enabled then
        if not unitFrame:IsElementEnabled("Castbar") then unitFrame:EnableElement("Castbar") end
        unitFrame.Castbar = CastBar
        unitFrame.Castbar.Text = SpellNameText
        unitFrame.Castbar.Time = DurationText
        if CastBarDB.Icon.Enabled then unitFrame.Castbar.Icon = CastBar.Icon else unitFrame.Castbar.Icon = nil end
        unitFrame.Castbar:HookScript("OnValueChanged", function(self, value) if self.Castbar then self.Castbar:SetValue(value) end end)
        unitFrame.Castbar:HookScript("OnHide", function() CastBarContainer:Hide() end)

        local function UpdateNotInterruptibleOverlay(frameCastBar)
            if frameCastBar.NotInterruptibleOverlay and frameCastBar.notInterruptible ~= nil then
                frameCastBar.NotInterruptibleOverlay:SetAlphaFromBoolean(frameCastBar.notInterruptible, 1, 0)
            end
        end

        unitFrame.Castbar.PostCastStart = function(frameCastBar)
            local spellInfo = C_Spell.GetSpellInfo(frameCastBar.spellID)
            local spellName = spellInfo and spellInfo.name
            if spellName then
                frameCastBar.Text:SetText(ShortenCastName(spellName, SpellNameDB.MaxChars))
            else
                frameCastBar.Text:SetText("")
            end

            UpdateNotInterruptibleOverlay(frameCastBar)
            CastBarContainer:Show()
        end

        unitFrame.Castbar.PostCastInterruptible = function(frameCastBar)
            UpdateNotInterruptibleOverlay(frameCastBar)
        end
        if SpellNameDB.Enabled then unitFrame.Castbar.Text:SetAlpha(1) else unitFrame.Castbar.Text:SetAlpha(0) end
        if DurationDB.Enabled then unitFrame.Castbar.Time:SetAlpha(1) else unitFrame.Castbar.Time:SetAlpha(0) end
    else
        CastBarContainer:Hide()
        if not unitFrame.Castbar then return end
        if unitFrame:IsElementEnabled("Castbar") then unitFrame:DisableElement("Castbar") end
        unitFrame.Castbar:Hide()
        unitFrame.Castbar = nil
    end

    return CastBar
end

function UUF:UpdateUnitCastBar(unitFrame, unit)
    local GeneralDB = UUF.db.profile.General
    local FrameDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Frame
    local CastBarDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].CastBar

    if CastBarDB.Enabled then
        unitFrame.Castbar = unitFrame.Castbar or UUF:CreateUnitCastBar(unitFrame, unit)

        local CastBarContainer = unitFrame.Castbar and unitFrame.Castbar:GetParent()

        if not unitFrame:IsElementEnabled("Castbar") then unitFrame:EnableElement("Castbar") end

        if unitFrame.Castbar then
            if CastBarContainer then
                CastBarContainer:ClearAllPoints()
                CastBarContainer:SetPoint(CastBarDB.Layout[1], unitFrame, CastBarDB.Layout[2], CastBarDB.Layout[3], CastBarDB.Layout[4])
                CastBarContainer:SetFrameStrata(CastBarDB.FrameStrata)
                if CastBarDB.ShowBorder then
                    CastBarContainer:SetBackdropBorderColor(unpack(CastBarDB.BorderColour))
                else
                    CastBarContainer:SetBackdropBorderColor(0, 0, 0, 0)
                end
            end
            unitFrame.Castbar:ClearAllPoints()
            unitFrame.Castbar:SetPoint("TOPLEFT", CastBarContainer, "TOPLEFT", 1, -1)
            unitFrame.Castbar:SetPoint("BOTTOMRIGHT", CastBarContainer, "BOTTOMRIGHT", -1, 1)
            if CastBarDB.MatchParentWidth then if CastBarContainer then CastBarContainer:SetWidth(FrameDB.Width) end else if CastBarContainer then CastBarContainer:SetWidth(CastBarDB.Width) end end
            if CastBarContainer then CastBarContainer:SetHeight(CastBarDB.Height) end
            unitFrame.Castbar:SetStatusBarTexture(UUF.Media.Foreground)
            unitFrame.Castbar.Background:SetTexture(UUF.Media.Background)
            unitFrame.Castbar:SetStatusBarColor(unpack(CastBarDB.Foreground))
            unitFrame.Castbar.Background:SetVertexColor(unpack(CastBarDB.Background))

            if unitFrame.Castbar.NotInterruptibleOverlay then
                unitFrame.Castbar.NotInterruptibleOverlay:SetTexture(UUF.Media.Foreground)
                unitFrame.Castbar.NotInterruptibleOverlay:SetVertexColor(unpack(CastBarDB.NotInterruptibleColour))
            end

            if CastBarDB.Inverse then
                unitFrame.Castbar:SetReverseFill(true)
            else
                unitFrame.Castbar:SetReverseFill(false)
            end

            if CastBarDB.Icon.Enabled then
                unitFrame.Castbar.Icon = unitFrame.Castbar.Icon or unitFrame.Castbar:CreateTexture(UUF:FetchFrameName(unit) .. "_CastBarIcon", "ARTWORK")
                unitFrame.Castbar.Icon:SetSize(CastBarDB.Height - 2, CastBarDB.Height - 2)
                unitFrame.Castbar.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
                unitFrame.Castbar.Icon:ClearAllPoints()
                if CastBarDB.Icon.Enabled and CastBarDB.Icon.Position == "LEFT" then
                    unitFrame.Castbar.Icon:SetPoint("TOPLEFT", CastBarContainer, "TOPLEFT", 1, -1)
                    unitFrame.Castbar:ClearAllPoints()
                    unitFrame.Castbar:SetPoint("TOPLEFT", CastBarContainer, "TOPLEFT", CastBarDB.Height - 1, -1)
                    unitFrame.Castbar:SetPoint("BOTTOMRIGHT", CastBarContainer, "BOTTOMRIGHT", -1, 1)
                elseif CastBarDB.Icon.Enabled and CastBarDB.Icon.Position == "RIGHT" then
                    unitFrame.Castbar.Icon:SetPoint("TOPRIGHT", CastBarContainer, "TOPRIGHT", -1, -1)
                    unitFrame.Castbar:ClearAllPoints()
                    unitFrame.Castbar:SetPoint("TOPLEFT", CastBarContainer, "TOPLEFT", 1, -1)
                    unitFrame.Castbar:SetPoint("BOTTOMRIGHT", CastBarContainer, "BOTTOMRIGHT", -(CastBarDB.Height - 1), 1)
                elseif not CastBarDB.Icon.Enabled then
                    unitFrame.Castbar.Icon:Hide()
                    unitFrame.Castbar:ClearAllPoints()
                    unitFrame.Castbar:SetPoint("TOPLEFT", CastBarContainer, "TOPLEFT", 1, -1)
                    unitFrame.Castbar:SetPoint("BOTTOMRIGHT", CastBarContainer, "BOTTOMRIGHT", -1, 1)
                end
                unitFrame.Castbar.Icon:Show()
            else
                if unitFrame.Castbar.Icon then unitFrame.Castbar.Icon:Hide() end
                unitFrame.Castbar.Icon = nil
                unitFrame.Castbar:ClearAllPoints()
                unitFrame.Castbar:SetPoint("TOPLEFT", CastBarContainer, "TOPLEFT", 1, -1)
                unitFrame.Castbar:SetPoint("BOTTOMRIGHT", CastBarContainer, "BOTTOMRIGHT", -1, 1)
            end

            if unitFrame.Castbar.Text then
                local SpellNameDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].CastBar.Text.SpellName
                unitFrame.Castbar.Text:ClearAllPoints()
                unitFrame.Castbar.Text:SetPoint(SpellNameDB.Layout[1], unitFrame.Castbar, SpellNameDB.Layout[2], SpellNameDB.Layout[3], SpellNameDB.Layout[4])
                unitFrame.Castbar.Text:SetFont(UUF.Media.Font, SpellNameDB.FontSize, UUF.db.profile.General.Fonts.FontFlag)
                if GeneralDB.Fonts.Shadow.Enabled then
                    unitFrame.Castbar.Text:SetShadowColor(GeneralDB.Fonts.Shadow.Colour[1], GeneralDB.Fonts.Shadow.Colour[2], GeneralDB.Fonts.Shadow.Colour[3], GeneralDB.Fonts.Shadow.Colour[4])
                    unitFrame.Castbar.Text:SetShadowOffset(GeneralDB.Fonts.Shadow.XPos, GeneralDB.Fonts.Shadow.YPos)
                else
                    unitFrame.Castbar.Text:SetShadowColor(0, 0, 0, 0)
                    unitFrame.Castbar.Text:SetShadowOffset(0, 0)
                end
                unitFrame.Castbar.Text:SetTextColor(unpack(SpellNameDB.Colour))
                unitFrame.Castbar.Text:SetJustifyH(UUF:SetJustification(SpellNameDB.Layout[1]))
                if SpellNameDB.Enabled then unitFrame.Castbar.Text:SetAlpha(1) else unitFrame.Castbar.Text:SetAlpha(0) end
            end

            if unitFrame.Castbar.Time then
                local DurationDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].CastBar.Text.Duration
                unitFrame.Castbar.Time:ClearAllPoints()
                unitFrame.Castbar.Time:SetPoint(DurationDB.Layout[1], unitFrame.Castbar, DurationDB.Layout[2], DurationDB.Layout[3], DurationDB.Layout[4])
                unitFrame.Castbar.Time:SetFont(UUF.Media.Font, DurationDB.FontSize, UUF.db.profile.General.Fonts.FontFlag)
                if GeneralDB.Fonts.Shadow.Enabled then
                    unitFrame.Castbar.Time:SetShadowColor(GeneralDB.Fonts.Shadow.Colour[1], GeneralDB.Fonts.Shadow.Colour[2], GeneralDB.Fonts.Shadow.Colour[3], GeneralDB.Fonts.Shadow.Colour[4])
                    unitFrame.Castbar.Time:SetShadowOffset(GeneralDB.Fonts.Shadow.XPos, GeneralDB.Fonts.Shadow.YPos)
                else
                    unitFrame.Castbar.Time:SetShadowColor(0, 0, 0, 0)
                    unitFrame.Castbar.Time:SetShadowOffset(0, 0)
                end
                unitFrame.Castbar.Time:SetTextColor(unpack(DurationDB.Colour))
                unitFrame.Castbar.Time:SetJustifyH(UUF:SetJustification(DurationDB.Layout[1]))
                if DurationDB.Enabled then unitFrame.Castbar.Time:SetAlpha(1) else unitFrame.Castbar.Time:SetAlpha(0) end
            end
        end
    else
        if not unitFrame.Castbar then return end
        if unitFrame:IsElementEnabled("Castbar") then unitFrame:DisableElement("Castbar") end
        unitFrame.Castbar:Hide()
        unitFrame.Castbar = nil
        if CastBarContainer then CastBarContainer:Hide() end
    end
    if UUF.CASTBAR_TEST_MODE then UUF:CreateTestCastBar(unitFrame, unit) end
end

function UUF:CreateTestCastBar(unitFrame, unit)
    if not unit then return end
    if not unitFrame then return end
    local GeneralDB = UUF.db.profile.General
    local CastBarDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].CastBar
    local CastBarContainer = unitFrame.Castbar and unitFrame.Castbar:GetParent()
    if UUF.CASTBAR_TEST_MODE then
        if unitFrame.Castbar and CastBarDB.Enabled then
            unitFrame:DisableElement("Castbar")
            CastBarContainer:Show()
            CastBarContainer:SetFrameStrata(CastBarDB.FrameStrata)
            unitFrame.Castbar:Show()
            unitFrame.Castbar.Background:Show()
            unitFrame.Castbar.Text:SetText(ShortenCastName("Ethereal Portal", UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].CastBar.Text.SpellName.MaxChars))
            unitFrame.Castbar.Time:SetText("0.0")
            unitFrame.Castbar:SetMinMaxValues(0, 1000)
            unitFrame.Castbar.testValue = 0 -- Track value ourselves since GetValue() returns a secret
            unitFrame.Castbar:SetScript("OnUpdate", function(self)
                self.testValue = (self.testValue or 0) + 1
                if self.testValue >= 1000 then self.testValue = 0 end
                self:SetValue(self.testValue)
                unitFrame.Castbar.Time:SetText(string.format("%.1f", (self.testValue / 1000) * 5))
            end)
            unitFrame.Castbar:SetStatusBarColor(unpack(CastBarDB.Foreground))
            if unitFrame.Castbar.NotInterruptibleOverlay then
                unitFrame.Castbar.NotInterruptibleOverlay:SetAlpha(0)
            end
            if CastBarDB.Icon.Enabled and unitFrame.Castbar.Icon then unitFrame.Castbar.Icon:SetTexture("Interface\\Icons\\ability_mage_netherwindpresence") unitFrame.Castbar.Icon:Show() end
        else
            if CastBarContainer then CastBarContainer:Hide() end
            if unitFrame.Castbar and unitFrame.Castbar.Icon then unitFrame.Castbar.Icon:Hide() end
        end
    else
        if unitFrame.Castbar and CastBarDB.Enabled then unitFrame:EnableElement("Castbar") end
    end
end
