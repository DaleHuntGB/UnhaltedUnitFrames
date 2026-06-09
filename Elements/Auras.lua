local _, UUF = ...
local oUF = UUF.oUF

local function GetAuraConfig(aurasDB, auraType)
    if not aurasDB then return nil end
    if auraType == "HELPFUL" then
        return aurasDB.Buffs
    elseif auraType == "HARMFUL" then
        return aurasDB.Debuffs
    end
end

local function ApplyAuraCountStyle(auraStacks, auraConfig, button, fontsDB)
    if not auraStacks or not auraConfig then return end

    auraStacks:ClearAllPoints()
    auraStacks:SetFont(UUF.Media.Font, auraConfig.Count.FontSize, fontsDB.FontFlag)
    auraStacks:SetPoint(auraConfig.Count.Layout[1], button, auraConfig.Count.Layout[2], auraConfig.Count.Layout[3], auraConfig.Count.Layout[4])
    if fontsDB.Shadow.Enabled then
        auraStacks:SetShadowColor(fontsDB.Shadow.Colour[1], fontsDB.Shadow.Colour[2], fontsDB.Shadow.Colour[3], fontsDB.Shadow.Colour[4])
        auraStacks:SetShadowOffset(fontsDB.Shadow.XPos, fontsDB.Shadow.YPos)
    else
        auraStacks:SetShadowColor(0, 0, 0, 0)
        auraStacks:SetShadowOffset(0, 0)
    end
    auraStacks:SetTextColor(unpack(auraConfig.Count.Colour))
end

local function ApplyAuraOverlay(button)
    local auraOverlay = button.Overlay
    if not auraOverlay then return end
    auraOverlay:SetTexture("Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\AuraOverlay.png")
    auraOverlay:ClearAllPoints()
    auraOverlay:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
    auraOverlay:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
    auraOverlay:SetTexCoord(0, 1, 0, 1)
end

local function ApplyAuraVisuals(button, unit, auraType, applyOverlay)
    if not button or not unit or not auraType then return end
    local fontsDB = UUF.db.profile.General.Fonts
    local aurasDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Auras
    if not aurasDB then return end

    local auraConfig = GetAuraConfig(aurasDB, auraType)
    if not auraConfig then return end

    local auraIcon = button.Icon
    if auraIcon then
        auraIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    end

    local auraCooldown = button.Cooldown
    if auraCooldown then
        auraCooldown:SetDrawEdge(false)
        auraCooldown:SetReverse(true)
        UUF:ApplyAuraDuration(auraCooldown, aurasDB.AuraDuration)
    end

    ApplyAuraCountStyle(button.Count, auraConfig, button, fontsDB)

    if applyOverlay then
        ApplyAuraOverlay(button)
    end
end

local function StyleAuras(_, button, unit, auraType)
    if not button or not unit or not auraType then return end
    local buttonBorder = CreateFrame("Frame", nil, button, "BackdropTemplate")
    buttonBorder:SetAllPoints()
    buttonBorder:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1, insets = {left = 0, right = 0, top = 0, bottom = 0} })
    buttonBorder:SetBackdropBorderColor(0, 0, 0, 1)
    ApplyAuraVisuals(button, unit, auraType, true)
end

local function RestyleAuras(_, button, unit, auraType)
    ApplyAuraVisuals(button, unit, auraType, false)
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
        unitFrame.BuffContainer.onlyShowPlayer = false
        unitFrame.BuffContainer["growthX"] = BuffsDB.GrowthDirection
        unitFrame.BuffContainer["growthY"] = BuffsDB.WrapDirection
        unitFrame.BuffContainer.filter = "HELPFUL"
        unitFrame.BuffContainer.FilterAura = function(_, filterUnit, aura)
            local filters = BuffsDB.Filters
            if not filters or not next(filters) then return true end

            local player = aura.isPlayerAura
            local other = not player
            local cancelable = not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, aura.auraInstanceID, "HELPFUL|CANCELABLE")

            return filters.Player and player
                or filters.RaidPlayerDispellable and not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, aura.auraInstanceID, "HELPFUL|RAID_PLAYER_DISPELLABLE")
                or filters.Important and other and not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, aura.auraInstanceID, "HELPFUL|IMPORTANT")
                or filters.ImportantPlayer and player and not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, aura.auraInstanceID, "HELPFUL|IMPORTANT")
                or filters.CrowdControl and other and not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, aura.auraInstanceID, "HELPFUL|CROWD_CONTROL")
                or filters.CrowdControlPlayer and player and not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, aura.auraInstanceID, "HELPFUL|CROWD_CONTROL")
                or filters.BigDefensive and other and not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, aura.auraInstanceID, "HELPFUL|BIG_DEFENSIVE")
                or filters.BigDefensivePlayer and player and not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, aura.auraInstanceID, "HELPFUL|BIG_DEFENSIVE")
                or filters.ExternalDefensive and other and not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, aura.auraInstanceID, "HELPFUL|EXTERNAL_DEFENSIVE")
                or filters.ExternalDefensivePlayer and player and not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, aura.auraInstanceID, "HELPFUL|EXTERNAL_DEFENSIVE")
                or filters.RaidInCombat and other and not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, aura.auraInstanceID, "HELPFUL|RAID_IN_COMBAT")
                or filters.RaidInCombatPlayer and player and not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, aura.auraInstanceID, "HELPFUL|RAID_IN_COMBAT")
                or filters.Cancelable and other and cancelable
                or filters.CancelablePlayer and player and cancelable
                or filters.NotCancelable and other and not cancelable
                or filters.NotCancelablePlayer and player and not cancelable
                or filters.Raid and other and not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, aura.auraInstanceID, "HELPFUL|RAID")
                or filters.RaidPlayer and player and not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, aura.auraInstanceID, "HELPFUL|RAID")
        end
        unitFrame.BuffContainer.PostCreateButton = function(_, button) StyleAuras(_, button, unit, "HELPFUL") end
        unitFrame.BuffContainer.anchoredButtons = 0
        unitFrame.BuffContainer.createdButtons = 0
        unitFrame.BuffContainer.tooltipAnchor = "ANCHOR_CURSOR"
        unitFrame.BuffContainer.showType = BuffsDB.ShowType
        unitFrame.BuffContainer.showBuffType = BuffsDB.ShowType
        unitFrame.BuffContainer.dispelColorCurve = C_CurveUtil.CreateColorCurve()
        unitFrame.BuffContainer.dispelColorCurve:SetType(Enum.LuaCurveType.Step)
        for _, dispelIndex in next, oUF.Enum.DispelType do
            if(oUF.colors.dispel[dispelIndex]) then
                unitFrame.BuffContainer.dispelColorCurve:AddPoint(dispelIndex, oUF.colors.dispel[dispelIndex])
            end
        end
        if not oUF.colors.dispel[0] then unitFrame.BuffContainer.dispelColorCurve:AddPoint(0, CreateColor(0.8, 0, 0, 1)) end

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
        unitFrame.DebuffContainer.onlyShowPlayer = false
        unitFrame.DebuffContainer["growthX"] = DebuffsDB.GrowthDirection
        unitFrame.DebuffContainer["growthY"] = DebuffsDB.WrapDirection
        unitFrame.DebuffContainer.filter = "HARMFUL"
        unitFrame.DebuffContainer.FilterAura = function(_, filterUnit, aura)
            local filters = DebuffsDB.Filters
            if not filters or not next(filters) then return true end

            local player = aura.isPlayerAura
            local other = not player
            local cancelable = not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, aura.auraInstanceID, "HARMFUL|CANCELABLE")

            return filters.Player and player
                or filters.RaidPlayerDispellable and not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, aura.auraInstanceID, "HARMFUL|RAID_PLAYER_DISPELLABLE")
                or filters.Important and other and not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, aura.auraInstanceID, "HARMFUL|IMPORTANT")
                or filters.ImportantPlayer and player and not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, aura.auraInstanceID, "HARMFUL|IMPORTANT")
                or filters.CrowdControl and other and not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, aura.auraInstanceID, "HARMFUL|CROWD_CONTROL")
                or filters.CrowdControlPlayer and player and not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, aura.auraInstanceID, "HARMFUL|CROWD_CONTROL")
                or filters.BigDefensive and other and not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, aura.auraInstanceID, "HARMFUL|BIG_DEFENSIVE")
                or filters.BigDefensivePlayer and player and not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, aura.auraInstanceID, "HARMFUL|BIG_DEFENSIVE")
                or filters.ExternalDefensive and other and not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, aura.auraInstanceID, "HARMFUL|EXTERNAL_DEFENSIVE")
                or filters.ExternalDefensivePlayer and player and not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, aura.auraInstanceID, "HARMFUL|EXTERNAL_DEFENSIVE")
                or filters.RaidInCombat and other and not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, aura.auraInstanceID, "HARMFUL|RAID_IN_COMBAT")
                or filters.RaidInCombatPlayer and player and not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, aura.auraInstanceID, "HARMFUL|RAID_IN_COMBAT")
                or filters.Cancelable and other and cancelable
                or filters.CancelablePlayer and player and cancelable
                or filters.NotCancelable and other and not cancelable
                or filters.NotCancelablePlayer and player and not cancelable
                or filters.Raid and other and not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, aura.auraInstanceID, "HARMFUL|RAID")
                or filters.RaidPlayer and player and not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, aura.auraInstanceID, "HARMFUL|RAID")
        end
        unitFrame.DebuffContainer.anchoredButtons = 0
        unitFrame.DebuffContainer.createdButtons = 0
        unitFrame.DebuffContainer.PostCreateButton = function(_, button) StyleAuras(_, button, unit, "HARMFUL") end
        unitFrame.DebuffContainer.tooltipAnchor = "ANCHOR_CURSOR"
        unitFrame.DebuffContainer.showType = DebuffsDB.ShowType
        unitFrame.DebuffContainer.showDebuffType = DebuffsDB.ShowType
        unitFrame.DebuffContainer.dispelColorCurve = C_CurveUtil.CreateColorCurve()
        unitFrame.DebuffContainer.dispelColorCurve:SetType(Enum.LuaCurveType.Step)
        for _, dispelIndex in next, oUF.Enum.DispelType do
            if(oUF.colors.dispel[dispelIndex]) then
                unitFrame.DebuffContainer.dispelColorCurve:AddPoint(dispelIndex, oUF.colors.dispel[dispelIndex])
            end
        end
        if not oUF.colors.dispel[0] then unitFrame.DebuffContainer.dispelColorCurve:AddPoint(0, CreateColor(0.8, 0, 0, 1)) end

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

    if unit == "player" then
        AurasDB.PrivateAuras = AurasDB.PrivateAuras or {
            Enabled = true,
            Layout = {"CENTER", "CENTER", 0, 60},
            FrameStrata = "LOW",
            Size = 32,
            Spacing = 2,
            GrowthX = "RIGHT",
            GrowthY = "UP",
            InitialAnchor = "BOTTOMLEFT",
            Num = 6,
            BorderScale = 1,
            DisableCooldown = false,
            DisableCooldownText = false,
        }
        local PrivateAurasDB = AurasDB.PrivateAuras
        local privateAuraContainerWidth = PrivateAurasDB.Size * PrivateAurasDB.Num + PrivateAurasDB.Spacing * (PrivateAurasDB.Num - 1)

        unitFrame.PrivateAuraContainer:ClearAllPoints()
        unitFrame.PrivateAuraContainer:SetPoint(PrivateAurasDB.Layout[1], unitFrame, PrivateAurasDB.Layout[2], PrivateAurasDB.Layout[3], PrivateAurasDB.Layout[4])
        unitFrame.PrivateAuraContainer:SetSize(math.max(privateAuraContainerWidth, 1), PrivateAurasDB.Size)
        unitFrame.PrivateAuraContainer:SetFrameStrata(PrivateAurasDB.FrameStrata)
        unitFrame.PrivateAuraContainer.size = PrivateAurasDB.Size
        unitFrame.PrivateAuraContainer.width = nil
        unitFrame.PrivateAuraContainer.height = nil
        unitFrame.PrivateAuraContainer.spacing = PrivateAurasDB.Spacing
        unitFrame.PrivateAuraContainer.spacingX = nil
        unitFrame.PrivateAuraContainer.spacingY = nil
        unitFrame.PrivateAuraContainer.growthX = PrivateAurasDB.GrowthX
        unitFrame.PrivateAuraContainer.growthY = PrivateAurasDB.GrowthY
        unitFrame.PrivateAuraContainer.initialAnchor = PrivateAurasDB.InitialAnchor
        unitFrame.PrivateAuraContainer.num = PrivateAurasDB.Num
        unitFrame.PrivateAuraContainer.maxCols = PrivateAurasDB.Num
        unitFrame.PrivateAuraContainer.borderScale = PrivateAurasDB.BorderScale == -1 and -100 or PrivateAurasDB.BorderScale
        unitFrame.PrivateAuraContainer.disableCooldown = PrivateAurasDB.DisableCooldown
        unitFrame.PrivateAuraContainer.disableCooldownText = PrivateAurasDB.DisableCooldownText

        if PrivateAurasDB.Enabled then
            unitFrame.PrivateAuras = unitFrame.PrivateAuraContainer
            unitFrame.PrivateAuraContainer:Show()
            if not unitFrame:IsElementEnabled("PrivateAuras") then unitFrame:EnableElement("PrivateAuras") end
            if unitFrame.PrivateAuraContainer.ForceUpdate then unitFrame.PrivateAuraContainer:ForceUpdate() end
        else
            if unitFrame:IsElementEnabled("PrivateAuras") then unitFrame:DisableElement("PrivateAuras") end
            unitFrame.PrivateAuras = nil
            unitFrame.PrivateAuraContainer:Hide()
        end
    end

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
        unitFrame.BuffContainer.onlyShowPlayer = false
        unitFrame.BuffContainer["growthX"] = BuffsDB.GrowthDirection
        unitFrame.BuffContainer["growthY"] = BuffsDB.WrapDirection
        unitFrame.BuffContainer.filter = "HELPFUL"
        unitFrame.BuffContainer.createdButtons = unitFrame.Buffs.createdButtons or 0
        unitFrame.BuffContainer.anchoredButtons = unitFrame.Buffs.anchoredButtons or 0
        unitFrame.BuffContainer.PostCreateButton = function(_, button) StyleAuras(_, button, unit, "HELPFUL") end
        unitFrame.BuffContainer.showType = BuffsDB.ShowType
        unitFrame.BuffContainer.showBuffType = BuffsDB.ShowType
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
        unitFrame.DebuffContainer.onlyShowPlayer = false
        unitFrame.DebuffContainer["growthX"] = DebuffsDB.GrowthDirection
        unitFrame.DebuffContainer["growthY"] = DebuffsDB.WrapDirection
        unitFrame.DebuffContainer.filter = "HARMFUL"
        unitFrame.DebuffContainer.createdButtons = unitFrame.Debuffs.createdButtons or 0
        unitFrame.DebuffContainer.anchoredButtons = unitFrame.Debuffs.anchoredButtons or 0
        unitFrame.DebuffContainer.PostCreateButton = function(_, button) StyleAuras(_, button, unit, "HARMFUL") end
        unitFrame.DebuffContainer.showType = DebuffsDB.ShowType
        unitFrame.DebuffContainer.showDebuffType = DebuffsDB.ShowType
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
            RestyleAuras(nil, button, unit, "HELPFUL")
        end
    end
    for _, button in ipairs(unitFrame.DebuffContainer) do
        if button and button:IsShown() then
            RestyleAuras(nil, button, unit, "HARMFUL")
        end
    end
    if UUF.AURA_TEST_MODE == true then UUF:CreateTestAuras(unitFrame, unit) end
end

function UUF:CreateUnitAuras(unitFrame, unit)
    CreateUnitBuffs(unitFrame, unit)
    CreateUnitDebuffs(unitFrame, unit)

    if unit == "player" then
        local AurasDB = UUF.db.profile.Units.player.Auras
        AurasDB.PrivateAuras = AurasDB.PrivateAuras or {
            Enabled = true,
            Layout = {"CENTER", "CENTER", 0, 60},
            FrameStrata = "LOW",
            Size = 32,
            Spacing = 2,
            GrowthX = "RIGHT",
            GrowthY = "UP",
            InitialAnchor = "BOTTOMLEFT",
            Num = 6,
            BorderScale = 1,
            DisableCooldown = false,
            DisableCooldownText = false,
        }
        local PrivateAurasDB = AurasDB.PrivateAuras
        local privateAuraContainerWidth = PrivateAurasDB.Size * PrivateAurasDB.Num + PrivateAurasDB.Spacing * (PrivateAurasDB.Num - 1)

        unitFrame.PrivateAuraContainer = CreateFrame("Frame", UUF:FetchFrameName(unit) .. "_PrivateAurasContainer", unitFrame)
        unitFrame.PrivateAuraContainer:SetPoint(PrivateAurasDB.Layout[1], unitFrame, PrivateAurasDB.Layout[2], PrivateAurasDB.Layout[3], PrivateAurasDB.Layout[4])
        unitFrame.PrivateAuraContainer:SetSize(math.max(privateAuraContainerWidth, 1), PrivateAurasDB.Size)
        unitFrame.PrivateAuraContainer:SetFrameStrata(PrivateAurasDB.FrameStrata)
        unitFrame.PrivateAuraContainer.size = PrivateAurasDB.Size
        unitFrame.PrivateAuraContainer.width = nil
        unitFrame.PrivateAuraContainer.height = nil
        unitFrame.PrivateAuraContainer.spacing = PrivateAurasDB.Spacing
        unitFrame.PrivateAuraContainer.spacingX = nil
        unitFrame.PrivateAuraContainer.spacingY = nil
        unitFrame.PrivateAuraContainer.growthX = PrivateAurasDB.GrowthX
        unitFrame.PrivateAuraContainer.growthY = PrivateAurasDB.GrowthY
        unitFrame.PrivateAuraContainer.initialAnchor = PrivateAurasDB.InitialAnchor
        unitFrame.PrivateAuraContainer.num = PrivateAurasDB.Num
        unitFrame.PrivateAuraContainer.maxCols = PrivateAurasDB.Num
        unitFrame.PrivateAuraContainer.borderScale = PrivateAurasDB.BorderScale == -1 and -100 or PrivateAurasDB.BorderScale
        unitFrame.PrivateAuraContainer.disableCooldown = PrivateAurasDB.DisableCooldown
        unitFrame.PrivateAuraContainer.disableCooldownText = PrivateAurasDB.DisableCooldownText

        if PrivateAurasDB.Enabled then
            unitFrame.PrivateAuras = unitFrame.PrivateAuraContainer
        else
            unitFrame.PrivateAuraContainer:Hide()
        end
    end
end

function UUF:UpdateUnitAurasStrata(unit)
    if not unit then return end
    local normalizedUnit = UUF:GetNormalizedUnit(unit)
    local unitFrame = UUF[unit:upper()]
    local unitDB = UUF.db.profile.Units[normalizedUnit]
    if not unitFrame or not unitDB or not unitDB.Auras then return end
    if unitFrame.BuffContainer then unitFrame.BuffContainer:SetFrameStrata(unitDB.Auras.FrameStrata) end
    if unitFrame.DebuffContainer then unitFrame.DebuffContainer:SetFrameStrata(unitDB.Auras.FrameStrata) end
    if unit == "player" and unitFrame.PrivateAuraContainer and unitDB.Auras.PrivateAuras then unitFrame.PrivateAuraContainer:SetFrameStrata(unitDB.Auras.PrivateAuras.FrameStrata) end
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
                        button:SetBackdropBorderColor(0, 0, 0, 1)
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
                    UUF:ApplyAuraDuration(button, AuraDurationDB, button.Duration)
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
                        button:SetBackdropBorderColor(0, 0, 0, 1)
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
                    UUF:ApplyAuraDuration(button, AuraDurationDB, button.Duration)
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
