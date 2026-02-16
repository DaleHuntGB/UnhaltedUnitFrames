local _, UUF = ...
local oUF = UUF.oUF

local function FetchAuraDurationRegion(cooldown)
    if not cooldown then return end
    for _, region in ipairs({ cooldown:GetRegions() }) do
        if region:GetObjectType() == "FontString" then return region end
    end
end

local function ApplyAuraDuration(icon, unit)
    local UUFDB = UUF.db.profile
    local FontsDB = UUFDB.General.Fonts
    local AurasDB = UUFDB.Units[UUF:GetNormalizedUnit(unit)].Auras
    local AuraDurationDB = AurasDB.AuraDuration
    if not icon then return end
    C_Timer.After(0.01, function()
        local textRegion = FetchAuraDurationRegion(icon)
        if textRegion then
            if AuraDurationDB.ScaleByIconSize then
                local iconWidth = icon:GetWidth()
                local scaleFactor = iconWidth > 0 and iconWidth / 36 or 1
                local fontSize = AuraDurationDB.FontSize * scaleFactor
                if fontSize < 1 then fontSize = 12 end
                textRegion:SetFont(UUF.Media.Font, fontSize, FontsDB.FontFlag)
            else
                textRegion:SetFont(UUF.Media.Font, AuraDurationDB.FontSize, FontsDB.FontFlag)
            end
            textRegion:SetTextColor(AuraDurationDB.Colour[1], AuraDurationDB.Colour[2], AuraDurationDB.Colour[3], 1)
            textRegion:ClearAllPoints()
            textRegion:SetPoint(AuraDurationDB.Layout[1], icon, AuraDurationDB.Layout[2], AuraDurationDB.Layout[3], AuraDurationDB.Layout[4])
            if UUF.db.profile.General.Fonts.Shadow.Enabled then
                textRegion:SetShadowColor(FontsDB.Shadow.Colour[1], FontsDB.Shadow.Colour[2], FontsDB.Shadow.Colour[3], FontsDB.Shadow.Colour[4])
                textRegion:SetShadowOffset(FontsDB.Shadow.XPos, FontsDB.Shadow.YPos)
            else
                textRegion:SetShadowColor(0, 0, 0, 0)
                textRegion:SetShadowOffset(0, 0)
            end
        end
    end)
end

local function DecodeAuraFilterString(filterString)
    if type(filterString) ~= "string" then return nil end
    return filterString:gsub("||", "|")
end

local function EncodeAuraFilterStringForStorage(filterString)
    if type(filterString) ~= "string" then return "" end
    local decodedFilterString = DecodeAuraFilterString(filterString) or ""
    return decodedFilterString:gsub("|", "||")
end

local function NormalizeAuraFilter(filterString, baseFilter, auraFilterConfig)
    local decodedFilterString = DecodeAuraFilterString(filterString)
    if type(decodedFilterString) ~= "string" then return baseFilter end

    if auraFilterConfig and decodedFilterString ~= baseFilter and auraFilterConfig[decodedFilterString] then
        return decodedFilterString
    end

    for filterType in decodedFilterString:gmatch("[^|]+") do
        if filterType ~= baseFilter and auraFilterConfig then
            if auraFilterConfig[filterType] then
                return filterType
            end

            local baseQualifiedFilter = baseFilter .. "|" .. filterType
            if auraFilterConfig[baseQualifiedFilter] then
                return baseQualifiedFilter
            end
        end
    end

    return baseFilter
end

local function StyleAuras(_, button, unit, auraType)
    if not button or not unit or not auraType then return end
    local GeneralDB = UUF.db.profile.General
    local AurasDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Auras
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
    if auraType == "HELPFUL" then
        buttonBorder:SetBackdropBorderColor(0, 0, 0, Buffs.ShowBorder and 1 or 0)
    elseif auraType == "HARMFUL" then
        buttonBorder:SetBackdropBorderColor(0, 0, 0, Debuffs.ShowBorder and 1 or 0)
    end
    button.Border = buttonBorder

    local auraCooldown = button.Cooldown
    if auraCooldown then
        auraCooldown:SetDrawEdge(false)
        auraCooldown:SetReverse(true)
        ApplyAuraDuration(auraCooldown, unit)
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

    local auraOverlay = button.Overlay
    if auraOverlay then
        auraOverlay:SetTexture("Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\AuraOverlay.png")
        auraOverlay:ClearAllPoints()
        auraOverlay:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
        auraOverlay:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
        auraOverlay:SetTexCoord(0, 1, 0, 1)
    end
end

local function RestyleAuras(_, button, unit, auraType)
    if not button or not unit or not auraType then return end
    local GeneralDB = UUF.db.profile.General
    local AurasDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Auras
    if not AurasDB then return end
    local Buffs = AurasDB.Buffs
    local Debuffs = AurasDB.Debuffs

    local auraIcon = button.Icon
    if auraIcon then
        auraIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    end

    if button.Border then
        if auraType == "HELPFUL" then
            button.Border:SetBackdropBorderColor(0, 0, 0, Buffs.ShowBorder and 1 or 0)
        elseif auraType == "HARMFUL" then
            button.Border:SetBackdropBorderColor(0, 0, 0, Debuffs.ShowBorder and 1 or 0)
        end
    end

    local auraCooldown = button.Cooldown
    if auraCooldown then
        auraCooldown:SetDrawEdge(false)
        auraCooldown:SetReverse(true)
        ApplyAuraDuration(auraCooldown, unit)
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
    local BuffsDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Auras.Buffs
    if not unitFrame.BuffContainer then
        unitFrame.BuffContainer = CreateFrame("Frame", UUF:FetchFrameName(unit) .. "_BuffsContainer", unitFrame)
        unitFrame.BuffContainer:SetFrameStrata(UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Auras.FrameStrata)
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
        unitFrame.BuffContainer.onlyShowPlayer = BuffsDB.OnlyShowPlayer
        unitFrame.BuffContainer["growthX"] = BuffsDB.GrowthDirection
        unitFrame.BuffContainer["growthY"] = BuffsDB.WrapDirection
        local buffFilter = NormalizeAuraFilter(BuffsDB.Filter, "HELPFUL", UUF.AURA_FILTERS and UUF.AURA_FILTERS.Buffs)
        BuffsDB.Filter = EncodeAuraFilterStringForStorage(buffFilter)
        unitFrame.BuffContainer.filter = buffFilter
        unitFrame.BuffContainer.PostCreateButton = function(_, button) StyleAuras(_, button, unit, "HELPFUL") end
        unitFrame.BuffContainer.anchoredButtons = 0
        unitFrame.BuffContainer.createdButtons = 0
        unitFrame.BuffContainer.tooltipAnchor = "ANCHOR_CURSOR"
        unitFrame.BuffContainer.showType = false
        unitFrame.BuffContainer.showBuffType = false
        unitFrame.BuffContainer.dispelColorCurve = C_CurveUtil.CreateColorCurve()
        unitFrame.BuffContainer.dispelColorCurve:SetType(Enum.LuaCurveType.Step)
        for _, dispelIndex in next, oUF.Enum.DispelType do
            if(oUF.colors.dispel[dispelIndex]) then
                unitFrame.BuffContainer.dispelColorCurve:AddPoint(dispelIndex, oUF.colors.dispel[dispelIndex])
            end
        end

        if BuffsDB.Enabled then
            unitFrame.Buffs = unitFrame.BuffContainer
        else
            unitFrame.Buffs = nil
        end
    end
end

local function CreateUnitDebuffs(unitFrame, unit)
    local DebuffsDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Auras.Debuffs
    if not unitFrame.DebuffContainer then
        unitFrame.DebuffContainer = CreateFrame("Frame", UUF:FetchFrameName(unit) .. "_DebuffsContainer", unitFrame)
        unitFrame.DebuffContainer:SetFrameStrata(UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Auras.FrameStrata)
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
        unitFrame.DebuffContainer.onlyShowPlayer = DebuffsDB.OnlyShowPlayer
        unitFrame.DebuffContainer["growthX"] = DebuffsDB.GrowthDirection
        unitFrame.DebuffContainer["growthY"] = DebuffsDB.WrapDirection
        local debuffFilter = NormalizeAuraFilter(DebuffsDB.Filter, "HARMFUL", UUF.AURA_FILTERS and UUF.AURA_FILTERS.Debuffs)
        DebuffsDB.Filter = EncodeAuraFilterStringForStorage(debuffFilter)
        unitFrame.DebuffContainer.filter = debuffFilter
        unitFrame.DebuffContainer.anchoredButtons = 0
        unitFrame.DebuffContainer.createdButtons = 0
        unitFrame.DebuffContainer.PostCreateButton = function(_, button) StyleAuras(_, button, unit, "HARMFUL") end
        unitFrame.DebuffContainer.tooltipAnchor = "ANCHOR_CURSOR"
        unitFrame.DebuffContainer.showType = false
        unitFrame.DebuffContainer.showDebuffType = false
        unitFrame.DebuffContainer.dispelColorCurve = C_CurveUtil.CreateColorCurve()
        unitFrame.DebuffContainer.dispelColorCurve:SetType(Enum.LuaCurveType.Step)
        for _, dispelIndex in next, oUF.Enum.DispelType do
            if(oUF.colors.dispel[dispelIndex]) then
                unitFrame.DebuffContainer.dispelColorCurve:AddPoint(dispelIndex, oUF.colors.dispel[dispelIndex])
            end
        end

        if DebuffsDB.Enabled then
            unitFrame.Debuffs = unitFrame.DebuffContainer
        else
            unitFrame.Debuffs = nil
        end
    end
end

function UUF:UpdateUnitAuras(unitFrame, unit)
    if not unit or not unitFrame then return end
    local AurasDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Auras
    if not AurasDB then return end
    local BuffsDB = AurasDB.Buffs
    local DebuffsDB = AurasDB.Debuffs

    local shouldEnableAuras = BuffsDB.Enabled or DebuffsDB.Enabled

    if BuffsDB.Enabled then
        unitFrame.Buffs = unitFrame.BuffContainer
        local buffPerRow = BuffsDB.Wrap or 4
        local buffRows = math.ceil(BuffsDB.Num / buffPerRow)
        local buffContainerWidth = (BuffsDB.Size + BuffsDB.Layout[5]) * buffPerRow - BuffsDB.Layout[5]
        local buffContainerHeight = (BuffsDB.Size + BuffsDB.Layout[5]) * buffRows - BuffsDB.Layout[5]
        unitFrame.BuffContainer:ClearAllPoints()
        unitFrame.BuffContainer:SetSize(buffContainerWidth, buffContainerHeight)
        unitFrame.BuffContainer:SetPoint(BuffsDB.Layout[1], unitFrame, BuffsDB.Layout[2], BuffsDB.Layout[3], BuffsDB.Layout[4])
        unitFrame.BuffContainer:SetFrameStrata(UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Auras.FrameStrata)
        unitFrame.BuffContainer.size = BuffsDB.Size
        unitFrame.BuffContainer.spacing = BuffsDB.Layout[5]
        unitFrame.BuffContainer.num = BuffsDB.Num
        unitFrame.BuffContainer.initialAnchor = BuffsDB.Layout[1]
        unitFrame.BuffContainer.onlyShowPlayer = BuffsDB.OnlyShowPlayer
        unitFrame.BuffContainer["growthX"] = BuffsDB.GrowthDirection
        unitFrame.BuffContainer["growthY"] = BuffsDB.WrapDirection
        local buffFilter = NormalizeAuraFilter(BuffsDB.Filter, "HELPFUL", UUF.AURA_FILTERS and UUF.AURA_FILTERS.Buffs)
        BuffsDB.Filter = EncodeAuraFilterStringForStorage(buffFilter)
        unitFrame.BuffContainer.filter = buffFilter
        unitFrame.BuffContainer.createdButtons = unitFrame.Buffs.createdButtons or 0
        unitFrame.BuffContainer.anchoredButtons = unitFrame.Buffs.anchoredButtons or 0
        unitFrame.BuffContainer.PostCreateButton = function(_, button) StyleAuras(_, button, unit, "HELPFUL") end
        unitFrame.BuffContainer.showType = false
        unitFrame.BuffContainer.showBuffType = false
        unitFrame.BuffContainer:Show()
    else
        unitFrame.BuffContainer:Hide()
        unitFrame.Buffs = nil
    end

    if DebuffsDB.Enabled then
        unitFrame.Debuffs = unitFrame.DebuffContainer
        local debuffPerRow = DebuffsDB.Wrap or 4
        local debuffRows = math.ceil(DebuffsDB.Num / debuffPerRow)
        local debuffContainerWidth = (DebuffsDB.Size + DebuffsDB.Layout[5]) * debuffPerRow - DebuffsDB.Layout[5]
        local debuffContainerHeight = (DebuffsDB.Size + DebuffsDB.Layout[5]) * debuffRows - DebuffsDB.Layout[5]
        unitFrame.DebuffContainer:ClearAllPoints()
        unitFrame.DebuffContainer:SetSize(debuffContainerWidth, debuffContainerHeight)
        unitFrame.DebuffContainer:SetFrameStrata(UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Auras.FrameStrata)
        unitFrame.DebuffContainer:SetPoint(DebuffsDB.Layout[1], unitFrame, DebuffsDB.Layout[2], DebuffsDB.Layout[3], DebuffsDB.Layout[4])
        unitFrame.DebuffContainer.size = DebuffsDB.Size
        unitFrame.DebuffContainer.spacing = DebuffsDB.Layout[5]
        unitFrame.DebuffContainer.num = DebuffsDB.Num
        unitFrame.DebuffContainer.initialAnchor = DebuffsDB.Layout[1]
        unitFrame.DebuffContainer.onlyShowPlayer = DebuffsDB.OnlyShowPlayer
        unitFrame.DebuffContainer["growthX"] = DebuffsDB.GrowthDirection
        unitFrame.DebuffContainer["growthY"] = DebuffsDB.WrapDirection
        local debuffFilter = NormalizeAuraFilter(DebuffsDB.Filter, "HARMFUL", UUF.AURA_FILTERS and UUF.AURA_FILTERS.Debuffs)
        DebuffsDB.Filter = EncodeAuraFilterStringForStorage(debuffFilter)
        unitFrame.DebuffContainer.filter = debuffFilter
        unitFrame.DebuffContainer.createdButtons = unitFrame.Debuffs.createdButtons or 0
        unitFrame.DebuffContainer.anchoredButtons = unitFrame.Debuffs.anchoredButtons or 0
        unitFrame.DebuffContainer.PostCreateButton = function(_, button) StyleAuras(_, button, unit, "HARMFUL") end
        unitFrame.DebuffContainer.showType = false
        unitFrame.DebuffContainer.showDebuffType = false
        unitFrame.DebuffContainer:Show()
    else
        unitFrame.DebuffContainer:Hide()
        unitFrame.Debuffs = nil
    end

    if shouldEnableAuras then
        if not unitFrame:IsElementEnabled("Auras") then unitFrame:EnableElement("Auras") end
        if unitFrame.BuffContainer and unitFrame.BuffContainer.ForceUpdate then unitFrame.BuffContainer:ForceUpdate() end
        if unitFrame.DebuffContainer and unitFrame.DebuffContainer.ForceUpdate then unitFrame.DebuffContainer:ForceUpdate() end
    else
        if unitFrame:IsElementEnabled("Auras") then
            unitFrame:DisableElement("Auras")
        end
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

function UUF:UpdateUnitAurasStrata(unit)
    if not unit then return end
    local normalizedUnit = UUF:GetNormalizedUnit(unit)
    local unitFrame = UUF[unit:upper()]
    local unitDB = UUF.db.profile.Units[normalizedUnit]
    if not unitFrame or not unitDB or not unitDB.Auras then return end
    if unitFrame.BuffContainer then unitFrame.BuffContainer:SetFrameStrata(unitDB.Auras.FrameStrata) end
    if unitFrame.DebuffContainer then unitFrame.DebuffContainer:SetFrameStrata(unitDB.Auras.FrameStrata) end
end


function UUF:CreateTestAuras(unitFrame, unit)
    if not unit then return end
    if not unitFrame then return end
    local General = UUF.db.profile.General
    local AuraDurationDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Auras.AuraDuration
    local BuffsDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Auras.Buffs
    local DebuffsDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Auras.Debuffs
    if UUF.AURA_TEST_MODE then
        if unitFrame.BuffContainer then
            if BuffsDB.Enabled then
                unitFrame.BuffContainer:ClearAllPoints()
                unitFrame.BuffContainer:SetPoint(BuffsDB.Layout[1], unitFrame, BuffsDB.Layout[2], BuffsDB.Layout[3], BuffsDB.Layout[4])
                unitFrame.BuffContainer:SetFrameStrata(UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Auras.FrameStrata)
                unitFrame.BuffContainer:Show()

                for j = 1, BuffsDB.Num do
                    local button = unitFrame.BuffContainer["fake" .. j]
                    if not button then
                        button = CreateFrame("Button", nil, unitFrame.BuffContainer, "BackdropTemplate")
                        button:SetBackdrop(UUF.BACKDROP)
                        button:SetBackdropColor(0, 0, 0, 0)
                        button:SetBackdropBorderColor(0, 0, 0, BuffsDB.ShowBorder and 1 or 0)
                        button:SetFrameStrata(UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Auras.FrameStrata)

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
                    button.Duration = button.Duration or button:CreateFontString(nil, "OVERLAY")
                    button.Duration:ClearAllPoints()
                    button.Duration:SetPoint(AuraDurationDB.Layout[1], button, AuraDurationDB.Layout[2], AuraDurationDB.Layout[3], AuraDurationDB.Layout[4])
                    if AuraDurationDB.ScaleByIconSize then
                        local iconWidth = button:GetWidth()
                        local scaleFactor = iconWidth / 36
                        button.Duration:SetFont(UUF.Media.Font, AuraDurationDB.FontSize * scaleFactor, General.Fonts.FontFlag)
                    else
                        button.Duration:SetFont(UUF.Media.Font, AuraDurationDB.FontSize, General.Fonts.FontFlag)
                    end
                    if General.Fonts.Shadow.Enabled then
                        button.Duration:SetShadowColor(unpack(General.Fonts.Shadow.Colour))
                        button.Duration:SetShadowOffset(General.Fonts.Shadow.XPos, General.Fonts.Shadow.YPos)
                    else
                        button.Duration:SetShadowColor(0, 0, 0, 0)
                        button.Duration:SetShadowOffset(0, 0)
                    end
                    button.Duration:SetTextColor(AuraDurationDB.Colour[1], AuraDurationDB.Colour[2], AuraDurationDB.Colour[3], 1)
                    button.Duration:SetText("10m")
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
                unitFrame.DebuffContainer:SetFrameStrata(UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Auras.FrameStrata)
                unitFrame.DebuffContainer:Show()

                for j = 1, DebuffsDB.Num do
                    local button = unitFrame.DebuffContainer["fake" .. j]
                    if not button then
                        button = CreateFrame("Button", nil, unitFrame.DebuffContainer, "BackdropTemplate")
                        button:SetBackdrop(UUF.BACKDROP)
                        button:SetBackdropColor(0, 0, 0, 0)
                        button:SetBackdropBorderColor(0, 0, 0, DebuffsDB.ShowBorder and 1 or 0)
                        button:SetFrameStrata(UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Auras.FrameStrata)
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
                    button.Duration = button.Duration or button:CreateFontString(nil, "OVERLAY")
                    button.Duration:ClearAllPoints()
                    button.Duration:SetPoint(AuraDurationDB.Layout[1], button, AuraDurationDB.Layout[2], AuraDurationDB.Layout[3], AuraDurationDB.Layout[4])
                    if AuraDurationDB.ScaleByIconSize then
                        local iconWidth = button:GetWidth()
                        local scaleFactor = iconWidth / 36
                        button.Duration:SetFont(UUF.Media.Font, AuraDurationDB.FontSize * scaleFactor, General.Fonts.FontFlag)
                    else
                        button.Duration:SetFont(UUF.Media.Font, AuraDurationDB.FontSize, General.Fonts.FontFlag)
                    end
                    if General.Fonts.Shadow.Enabled then
                        button.Duration:SetShadowColor(unpack(General.Fonts.Shadow.Colour))
                        button.Duration:SetShadowOffset(General.Fonts.Shadow.XPos, General.Fonts.Shadow.YPos)
                    else
                        button.Duration:SetShadowColor(0, 0, 0, 0)
                        button.Duration:SetShadowOffset(0, 0)
                    end
                    button.Duration:SetTextColor(AuraDurationDB.Colour[1], AuraDurationDB.Colour[2], AuraDurationDB.Colour[3], 1)
                    button.Duration:SetText("10m")
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
