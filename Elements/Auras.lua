local _, UUF = ...

local function StyleAuras(_, button, unit, auraType)
    if not button or not unit or not auraType then return end
    local GeneralDB = UUF.db.profile.General
    local AurasDB = UUF.db.profile.Units[unit].Auras
    if not AurasDB then return end
    local Buffs = AurasDB.Buffs
    local Debuffs = AurasDB.Debuffs

    local auraIcon = button.Icon
    if auraIcon then
        auraIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    end

    local buttonBorder = CreateFrame("Frame", nil, button, "BackdropTemplate")
    buttonBorder:SetAllPoints()
    buttonBorder:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1, insets = {left = 0, right = 0, top = 0, bottom = 0} })
    buttonBorder:SetBackdropBorderColor(0, 0, 0, 1)

    local auraCooldown = button.Cooldown
    if auraCooldown then
        auraCooldown:SetDrawEdge(false)
        auraCooldown:SetReverse(true)
    end

    local auraStacks = button.Count
    if auraStacks then
        if auraType == "HELPFUL" then
            auraStacks:ClearAllPoints()
            auraStacks:SetFont(UUF.Media.Font, Buffs.Count.FontSize, GeneralDB.Fonts.FontFlag)
            auraStacks:SetPoint(Buffs.Count.Layout[1], button, Buffs.Count.Layout[2], Buffs.Count.Layout[3], Buffs.Count.Layout[4])
            if GeneralDB.Fonts.Shadow.Enabled then
                auraStacks:SetShadowColor(GeneralDB.Fonts.Shadow.Colour[1], GeneralDB.Fonts.Shadow.Colour[2], GeneralDB.Fonts.Shadow.Colour[3], GeneralDB.Fonts.Shadow.Colour[4])
                auraStacks:SetShadowOffset(GeneralDB.Fonts.Shadow.XPos, GeneralDB.Fonts.Shadow.YPos)
            else
                auraStacks:SetShadowColor(0, 0, 0, 0)
                auraStacks:SetShadowOffset(0, 0)
            end
            auraStacks:SetTextColor(unpack(Buffs.Count.Colour))
        elseif auraType == "HARMFUL" then
            auraStacks:ClearAllPoints()
            auraStacks:SetFont(UUF.Media.Font, Debuffs.Count.FontSize, GeneralDB.Fonts.FontFlag)
            auraStacks:SetPoint(Debuffs.Count.Layout[1], button, Debuffs.Count.Layout[2], Debuffs.Count.Layout[3], Debuffs.Count.Layout[4])
            if GeneralDB.Fonts.Shadow.Enabled then
                auraStacks:SetShadowColor(GeneralDB.Fonts.Shadow.Colour[1], GeneralDB.Fonts.Shadow.Colour[2], GeneralDB.Fonts.Shadow.Colour[3], GeneralDB.Fonts.Shadow.Colour[4])
                auraStacks:SetShadowOffset(GeneralDB.Fonts.Shadow.XPos, GeneralDB.Fonts.Shadow.YPos)
            else
                auraStacks:SetShadowColor(0, 0, 0, 0)
                auraStacks:SetShadowOffset(0, 0)
            end
            auraStacks:SetTextColor(unpack(Debuffs.Count.Colour))
        end
    end
end

local function RestyleAuras(_, button, unit, auraType)
    if not button or not unit or not auraType then return end
    local GeneralDB = UUF.db.profile.General
    local AurasDB = UUF.db.profile.Units[unit].Auras
    if not AurasDB then return end
    local Buffs = AurasDB.Buffs
    local Debuffs = AurasDB.Debuffs

    local auraIcon = button.Icon
    if auraIcon then
        auraIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    end

    local auraCooldown = button.Cooldown
    if auraCooldown then
        auraCooldown:SetDrawEdge(false)
        auraCooldown:SetReverse(true)
    end

    local auraStacks = button.Count
    if auraStacks then
        if auraType == "HELPFUL" then
            auraStacks:ClearAllPoints()
            auraStacks:SetFont(UUF.Media.Font, Buffs.Count.FontSize, GeneralDB.Fonts.FontFlag)
            auraStacks:SetPoint(Buffs.Count.Layout[1], button, Buffs.Count.Layout[2], Buffs.Count.Layout[3], Buffs.Count.Layout[4])
            if GeneralDB.Fonts.Shadow.Enabled then
                auraStacks:SetShadowColor(GeneralDB.Fonts.Shadow.Colour[1], GeneralDB.Fonts.Shadow.Colour[2], GeneralDB.Fonts.Shadow.Colour[3], GeneralDB.Fonts.Shadow.Colour[4])
                auraStacks:SetShadowOffset(GeneralDB.Fonts.Shadow.XPos, GeneralDB.Fonts.Shadow.YPos)
            else
                auraStacks:SetShadowColor(0, 0, 0, 0)
                auraStacks:SetShadowOffset(0, 0)
            end
            auraStacks:SetTextColor(unpack(Buffs.Count.Colour))
        elseif auraType == "HARMFUL" then
            auraStacks:ClearAllPoints()
            auraStacks:SetFont(UUF.Media.Font, Debuffs.Count.FontSize, GeneralDB.Fonts.FontFlag)
            auraStacks:SetPoint(Debuffs.Count.Layout[1], button, Debuffs.Count.Layout[2], Debuffs.Count.Layout[3], Debuffs.Count.Layout[4])
            if GeneralDB.Fonts.Shadow.Enabled then
                auraStacks:SetShadowColor(GeneralDB.Fonts.Shadow.Colour[1], GeneralDB.Fonts.Shadow.Colour[2], GeneralDB.Fonts.Shadow.Colour[3], GeneralDB.Fonts.Shadow.Colour[4])
                auraStacks:SetShadowOffset(GeneralDB.Fonts.Shadow.XPos, GeneralDB.Fonts.Shadow.YPos)
            else
                auraStacks:SetShadowColor(0, 0, 0, 0)
                auraStacks:SetShadowOffset(0, 0)
            end
            auraStacks:SetTextColor(unpack(Debuffs.Count.Colour))
        end
    end
end

local function CreateUnitBuffs(unitFrame, unit)
    local BuffsDB = UUF.db.profile.Units[unit].Auras.Buffs
    if not unitFrame.BuffContainer then
        unitFrame.BuffContainer = CreateFrame("Frame", UUF:FetchFrameName(unit) .. "_BuffsContainer", unitFrame)
        local buffPerRow = BuffsDB.Wrap or 4
        local buffRows = math.ceil(BuffsDB.Num / buffPerRow)
        local buffContainerWidth = (BuffsDB.Size + BuffsDB.Layout[5]) * buffPerRow - BuffsDB.Layout[5]
        local buffContainerHeight = (BuffsDB.Size + BuffsDB.Layout[5]) * buffRows - BuffsDB.Layout[5]
        unitFrame.BuffContainer:SetSize(buffContainerWidth, buffContainerHeight)
        unitFrame.BuffContainer:SetPoint(BuffsDB.Layout[1], unitFrame, BuffsDB.Layout[2], BuffsDB.Layout[3], BuffsDB.Layout[4])
        unitFrame.BuffContainer.size = BuffsDB.Size
        unitFrame.BuffContainer.spacing = BuffsDB.Layout[5]
        unitFrame.BuffContainer.num = BuffsDB.Num
        unitFrame.BuffContainer.initialAnchor = BuffsDB.Layout[1]
        unitFrame.BuffContainer.onlyShowPlayer = false
        unitFrame.BuffContainer["growth-x"] = BuffsDB.GrowthDirection
        unitFrame.BuffContainer["growth-y"] = BuffsDB.WrapDirection
        unitFrame.BuffContainer.filter = "HELPFUL"
        unitFrame.BuffContainer.PostCreateButton = function(_, button) StyleAuras(_, button, unit, "HELPFUL") end
        unitFrame.BuffContainer.anchoredButtons = 0
        unitFrame.BuffContainer.createdButtons = 0

        if BuffsDB.Enabled then
            unitFrame.Buffs = unitFrame.BuffContainer
        else
            unitFrame.Buffs = nil
        end
    end
end

local function CreateUnitDebuffs(unitFrame, unit)
    local DebuffsDB = UUF.db.profile.Units[unit].Auras.Debuffs
    if not unitFrame.DebuffContainer then
        unitFrame.DebuffContainer = CreateFrame("Frame", UUF:FetchFrameName(unit) .. "_DebuffsContainer", unitFrame)
        local debuffPerRow = DebuffsDB.Wrap or 3
        local debuffRows = math.ceil(DebuffsDB.Num / debuffPerRow)
        local debuffContainerWidth = (DebuffsDB.Size + DebuffsDB.Layout[5]) * debuffPerRow - DebuffsDB.Layout[5]
        local debuffContainerHeight = (DebuffsDB.Size + DebuffsDB.Layout[5]) * debuffRows - DebuffsDB.Layout[5]
        unitFrame.DebuffContainer:SetSize(debuffContainerWidth, debuffContainerHeight)
        unitFrame.DebuffContainer:SetPoint(DebuffsDB.Layout[1], unitFrame, DebuffsDB.Layout[2], DebuffsDB.Layout[3], DebuffsDB.Layout[4])
        unitFrame.DebuffContainer.size = DebuffsDB.Size
        unitFrame.DebuffContainer.spacing = DebuffsDB.Layout[5]
        unitFrame.DebuffContainer.num = DebuffsDB.Num
        unitFrame.DebuffContainer.initialAnchor = DebuffsDB.Layout[1]
        unitFrame.DebuffContainer.onlyShowPlayer = false
        unitFrame.DebuffContainer["growth-x"] = DebuffsDB.GrowthDirection
        unitFrame.DebuffContainer["growth-y"] = DebuffsDB.WrapDirection
        unitFrame.DebuffContainer.filter = "HARMFUL"
        unitFrame.DebuffContainer.anchoredButtons = 0
        unitFrame.DebuffContainer.createdButtons = 0
        unitFrame.DebuffContainer.PostCreateButton = function(_, button) StyleAuras(_, button, unit, "HARMFUL") end

        if DebuffsDB.Enabled then
            unitFrame.Debuffs = unitFrame.DebuffContainer
        else
            unitFrame.Debuffs = nil
        end
    end
end

function UUF:UpdateUnitAuras(unitFrame, unit)
    if not unit or not unitFrame then return end
    local AurasDB = UUF.db.profile.Units[unit].Auras
    if not AurasDB then return end
    local BuffsDB = AurasDB.Buffs
    local DebuffsDB = AurasDB.Debuffs

    if BuffsDB.Enabled then
        unitFrame.Buffs = unitFrame.BuffContainer
        if not unitFrame:IsElementEnabled("Auras") then unitFrame:EnableElement("Auras") end
        local buffPerRow = BuffsDB.Wrap or 4
        local buffRows = math.ceil(BuffsDB.Num / buffPerRow)
        local buffContainerWidth = (BuffsDB.Size + BuffsDB.Layout[5]) * buffPerRow - BuffsDB.Layout[5]
        local buffContainerHeight = (BuffsDB.Size + BuffsDB.Layout[5]) * buffRows - BuffsDB.Layout[5]
        unitFrame.BuffContainer:ClearAllPoints()
        unitFrame.BuffContainer:SetSize(buffContainerWidth, buffContainerHeight)
        unitFrame.BuffContainer:SetPoint(BuffsDB.Layout[1], unitFrame, BuffsDB.Layout[2], BuffsDB.Layout[3], BuffsDB.Layout[4])
        unitFrame.BuffContainer.size = BuffsDB.Size
        unitFrame.BuffContainer.spacing = BuffsDB.Layout[5]
        unitFrame.BuffContainer.num = BuffsDB.Num
        unitFrame.BuffContainer.initialAnchor = BuffsDB.Layout[1]
        unitFrame.BuffContainer.onlyShowPlayer = false
        unitFrame.BuffContainer["growth-x"] = BuffsDB.GrowthDirection
        unitFrame.BuffContainer["growth-y"] = BuffsDB.WrapDirection
        unitFrame.BuffContainer.filter = "HELPFUL"
        unitFrame.BuffContainer.createdButtons = unitFrame.Buffs.createdButtons or 0
        unitFrame.BuffContainer.anchoredButtons = unitFrame.Buffs.anchoredButtons or 0
        unitFrame.BuffContainer.PostCreateButton = function(_, button) StyleAuras(_, button, unit, "HELPFUL") end
        unitFrame.BuffContainer:Show()
        if unitFrame.BuffContainer and unitFrame.BuffContainer.ForceUpdate then unitFrame.BuffContainer:ForceUpdate() end
    else
        if unitFrame:IsElementEnabled("Auras") then unitFrame:DisableElement("Auras") end
        unitFrame.BuffContainer:Hide()
        unitFrame.Buffs = nil
    end

    if DebuffsDB.Enabled then
        unitFrame.Debuffs = unitFrame.DebuffContainer
        if not unitFrame:IsElementEnabled("Auras") then unitFrame:EnableElement("Auras") end
        local debuffPerRow = DebuffsDB.Wrap or 4
        local debuffRows = math.ceil(DebuffsDB.Num / debuffPerRow)
        local debuffContainerWidth = (DebuffsDB.Size + DebuffsDB.Layout[5]) * debuffPerRow - DebuffsDB.Layout[5]
        local debuffContainerHeight = (DebuffsDB.Size + DebuffsDB.Layout[5]) * debuffRows - DebuffsDB.Layout[5]
        unitFrame.DebuffContainer:ClearAllPoints()
        unitFrame.DebuffContainer:SetSize(debuffContainerWidth, debuffContainerHeight)
        unitFrame.DebuffContainer:SetPoint(DebuffsDB.Layout[1], unitFrame, DebuffsDB.Layout[2], DebuffsDB.Layout[3], DebuffsDB.Layout[4])
        unitFrame.DebuffContainer.size = DebuffsDB.Size
        unitFrame.DebuffContainer.spacing = DebuffsDB.Layout[5]
        unitFrame.DebuffContainer.num = DebuffsDB.Num
        unitFrame.DebuffContainer.initialAnchor = DebuffsDB.Layout[1]
        unitFrame.DebuffContainer.onlyShowPlayer = false
        unitFrame.DebuffContainer["growth-x"] = DebuffsDB.GrowthDirection
        unitFrame.DebuffContainer["growth-y"] = DebuffsDB.WrapDirection
        unitFrame.DebuffContainer.filter = "HARMFUL"
        unitFrame.DebuffContainer.createdButtons = unitFrame.Debuffs.createdButtons or 0
        unitFrame.DebuffContainer.anchoredButtons = unitFrame.Debuffs.anchoredButtons or 0
        unitFrame.DebuffContainer.PostCreateButton = function(_, button) StyleAuras(_, button, unit, "HARMFUL") end
        unitFrame.DebuffContainer:Show()
        if unitFrame.DebuffContainer and unitFrame.DebuffContainer.ForceUpdate then unitFrame.DebuffContainer:ForceUpdate() end
    else
        if unitFrame:IsElementEnabled("Auras") then unitFrame:DisableElement("Auras") end
        unitFrame.DebuffContainer:Hide()
        unitFrame.Debuffs = nil
    end

    if BuffsDB.Enabled or DebuffsDB.Enabled then
        if not unitFrame:IsElementEnabled("Auras") then unitFrame:EnableElement("Auras") end
    else
        if unitFrame:IsElementEnabled("Auras") then unitFrame:DisableElement("Auras") end
    end

    for _, button in ipairs(unitFrame.BuffContainer) do
        if button and button:IsShown() then
            RestyleAuras(_, button, unit, "HELPFUL")
        end
    end
    for _, button in ipairs(unitFrame.DebuffContainer) do
        if button and button:IsShown() then
            RestyleAuras(_, button, unit, "HARMFUL")
        end
    end
    if UUF.AURA_TEST_MODE == true then UUF:CreateTestAuras(unitFrame, unit) end
end

function UUF:CreateUnitAuras(unitFrame, unit)
    CreateUnitBuffs(unitFrame, unit)
    CreateUnitDebuffs(unitFrame, unit)
end

function UUF:CreateTestAuras(unitFrame, unit)
    if not unit then return end
    if not unitFrame then return end
    local General = UUF.db.profile.General
    local BuffsDB = UUF.db.profile.Units[unit].Auras.Buffs
    local DebuffsDB = UUF.db.profile.Units[unit].Auras.Debuffs
    if UUF.AURA_TEST_MODE then
        if unitFrame.BuffContainer then
            if BuffsDB.Enabled then
                unitFrame.BuffContainer:ClearAllPoints()
                unitFrame.BuffContainer:SetPoint(BuffsDB.Layout[1], unitFrame, BuffsDB.Layout[2], BuffsDB.Layout[3], BuffsDB.Layout[4])
                unitFrame.BuffContainer:Show()

                for j = 1, BuffsDB.Num do
                    local button = unitFrame.BuffContainer["fake" .. j]
                    if not button then
                        button = CreateFrame("Button", nil, unitFrame.BuffContainer, "BackdropTemplate")
                        button:SetBackdrop(UUF.BACKDROP)
                        button:SetBackdropColor(0, 0, 0, 0)
                        button:SetBackdropBorderColor(0, 0, 0, 1)
                        button:SetFrameStrata("MEDIUM")

                        button.Icon = button:CreateTexture(nil, "BORDER")
                        button.Icon:SetAllPoints()

                        button.Count = button:CreateFontString(nil, "OVERLAY")
                        unitFrame.BuffContainer["fake" .. j] = button
                    end

                    button:SetSize(BuffsDB.Size, BuffsDB.Size)
                    button.Count:ClearAllPoints()
                    button.Count:SetPoint(BuffsDB.Count.Layout[1], button, BuffsDB.Count.Layout[2], BuffsDB.Count.Layout[3], BuffsDB.Count.Layout[4])
                    button.Count:SetFont(UUF.Media.Font, BuffsDB.Count.FontSize, General.Fonts.FontFlag)
                    if General.Fonts.Shadow.Enabled then
                        button.Count:SetShadowColor(unpack(General.Fonts.Shadow.Colour))
                        button.Count:SetShadowOffset(General.Fonts.Shadow.XPos, General.Fonts.Shadow.YPos)
                    else
                        button.Count:SetShadowColor(0, 0, 0, 0)
                        button.Count:SetShadowOffset(0, 0)
                    end
                    button.Count:SetTextColor(unpack(BuffsDB.Count.Colour))

                    local row = math.floor((j - 1) / BuffsDB.Wrap)
                    local col = (j - 1) % BuffsDB.Wrap
                    local x = col * (BuffsDB.Size + BuffsDB.Layout[5])
                    local y = row * (BuffsDB.Size + BuffsDB.Layout[5])
                    if BuffsDB.GrowthDirection == "LEFT" then x = -x end
                    if BuffsDB.WrapDirection == "DOWN" then y = -y end

                    button:ClearAllPoints()
                    button:SetPoint(BuffsDB.Layout[1], unitFrame.BuffContainer, BuffsDB.Layout[1], x, y)

                    button.Icon:SetTexture(135769)
                    button.Icon:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
                    button.Icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
                    button.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
                    button.Count:SetText(j)
                    button:Show()
                end

                local maxFake = BuffsDB.Num
                for j = maxFake + 1, (unitFrame.BuffContainer.maxFake or maxFake) do
                    local button = unitFrame.BuffContainer["fake" .. j]
                    if button then button:Hide() end
                end
                unitFrame.BuffContainer.maxFake = BuffsDB.Num
            else
                unitFrame.BuffContainer:Hide()
            end
        end

        if unitFrame.DebuffContainer then
            if DebuffsDB.Enabled then
                unitFrame.DebuffContainer:ClearAllPoints()
                unitFrame.DebuffContainer:SetPoint(DebuffsDB.Layout[1], unitFrame, DebuffsDB.Layout[2], DebuffsDB.Layout[3], DebuffsDB.Layout[4])
                unitFrame.DebuffContainer:Show()

                for j = 1, DebuffsDB.Num do
                    local button = unitFrame.DebuffContainer["fake" .. j]
                    if not button then
                        button = CreateFrame("Button", nil, unitFrame.DebuffContainer, "BackdropTemplate")
                        button:SetBackdrop(UUF.BACKDROP)
                        button:SetBackdropColor(0, 0, 0, 0)
                        button:SetBackdropBorderColor(0, 0, 0, 1)
                        button:SetFrameStrata("MEDIUM")

                        button.Icon = button:CreateTexture(nil, "BORDER")
                        button.Icon:SetAllPoints()

                        button.Count = button:CreateFontString(nil, "OVERLAY")
                        unitFrame.DebuffContainer["fake" .. j] = button
                    end

                    button:SetSize(DebuffsDB.Size, DebuffsDB.Size)
                    button.Count:ClearAllPoints()
                    button.Count:SetPoint(DebuffsDB.Count.Layout[1], button, DebuffsDB.Count.Layout[2], DebuffsDB.Count.Layout[3], DebuffsDB.Count.Layout[4])
                    button.Count:SetFont(UUF.Media.Font, DebuffsDB.Count.FontSize, General.Fonts.FontFlag)
                    if General.Fonts.Shadow.Enabled then
                        button.Count:SetShadowColor(unpack(General.Fonts.Shadow.Colour))
                        button.Count:SetShadowOffset(General.Fonts.Shadow.XPos, General.Fonts.Shadow.YPos)
                    else
                        button.Count:SetShadowColor(0, 0, 0, 0)
                        button.Count:SetShadowOffset(0, 0)
                    end
                    button.Count:SetTextColor(unpack(DebuffsDB.Count.Colour))

                    local row = math.floor((j - 1) / DebuffsDB.Wrap)
                    local col = (j - 1) % DebuffsDB.Wrap
                    local x = col * (DebuffsDB.Size + DebuffsDB.Layout[5])
                    local y = row * (DebuffsDB.Size + DebuffsDB.Layout[5])
                    if DebuffsDB.GrowthDirection == "LEFT" then x = -x end
                    if DebuffsDB.WrapDirection == "DOWN" then y = -y end

                    button:ClearAllPoints()
                    button:SetPoint(DebuffsDB.Layout[1], unitFrame.DebuffContainer, DebuffsDB.Layout[1], x, y)
                    button.Icon:SetTexture(135768)
                    button.Icon:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
                    button.Icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
                    button.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
                    button.Count:SetText(j)
                    button:Show()
                end

                local maxFake = DebuffsDB.Num
                for j = maxFake + 1, (unitFrame.DebuffContainer.maxFake or maxFake) do
                    local button = unitFrame.DebuffContainer["fake" .. j]
                    if button then button:Hide() end
                end
                unitFrame.DebuffContainer.maxFake = DebuffsDB.Num
            else
                unitFrame.DebuffContainer:Hide()
            end
        end
    else
        if unitFrame.BuffContainer then
            for j = 1, (unitFrame.BuffContainer.maxFake or 0) do
                local button = unitFrame.BuffContainer["fake" .. j]
                if button then button:Hide() end
            end
        end
        if unitFrame.DebuffContainer then
            for j = 1, (unitFrame.DebuffContainer.maxFake or 0) do
                local button = unitFrame.DebuffContainer["fake" .. j]
                if button then button:Hide() end
            end
        end
    end
end