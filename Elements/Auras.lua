local _, UUF = ...
local oUF = UUF.oUF

local function StyleAuras(_, button, unit, auraType, restyle, auraDB)
	if not button or not unit or not auraType then return end
	local AurasDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Auras
	if not AurasDB then return end
	local AuraDB = auraDB and AurasDB[auraDB] or auraType == "HELPFUL" and AurasDB.Buffs or AurasDB.Debuffs
	if not AuraDB then return end

	if not restyle then
		local buttonBorder = CreateFrame("Frame", nil, button, "BackdropTemplate")
		buttonBorder:SetAllPoints()
		buttonBorder:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1, insets = {left = 0, right = 0, top = 0, bottom = 0} })
		buttonBorder:SetBackdropBorderColor(0, 0, 0, 1)
	end

	if button.Icon then button.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93) end
	if button.Cooldown then
		button.Cooldown:SetDrawEdge(false)
		button.Cooldown:SetReverse(true)
		UUF:ApplyCooldownText(button.Cooldown, nil, unit)
	end
	if button.Count then
		local FontsDB = UUF.db.profile.General.Fonts
		button.Count:ClearAllPoints()
		button.Count:SetFont(UUF.Media.Font, AuraDB.Count.FontSize, FontsDB.FontFlag)
		button.Count:SetPoint(AuraDB.Count.Layout[1], button, AuraDB.Count.Layout[2], AuraDB.Count.Layout[3], AuraDB.Count.Layout[4])
		if FontsDB.Shadow.Enabled then
			button.Count:SetShadowColor(FontsDB.Shadow.Colour[1], FontsDB.Shadow.Colour[2], FontsDB.Shadow.Colour[3], FontsDB.Shadow.Colour[4])
			button.Count:SetShadowOffset(FontsDB.Shadow.XPos, FontsDB.Shadow.YPos)
		else
			button.Count:SetShadowColor(0, 0, 0, 0)
			button.Count:SetShadowOffset(0, 0)
		end
		button.Count:SetTextColor(unpack(AuraDB.Count.Colour))
	end
	if not restyle and button.Overlay then
		button.Overlay:SetTexture("Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\AuraOverlay.png")
		button.Overlay:ClearAllPoints()
		button.Overlay:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
		button.Overlay:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
		button.Overlay:SetTexCoord(0, 1, 0, 1)
	end
end

local function FilterAura(AuraDB, filterUnit, aura, auraType)
	if AuraDB.Blacklist then
		local spellId = not UUF:IsSecretValue(aura.spellId) and aura.spellId
		local name = not UUF:IsSecretValue(aura.name) and aura.name
		if (spellId and UUF.AURA_BLACKLIST[spellId]) or (name and UUF.AURA_BLACKLIST[name]) then return false end
	end
	if AuraDB.OnlyShowPlayer then return aura.isPlayerAura end
	local setFilters = AuraDB.Filters
	if not setFilters or not next(setFilters) then return true end

	local auraInstanceID = aura.auraInstanceID
	local isPlayer = aura.isPlayerAura
	local cancelFilter = isPlayer and "CancelablePlayer" or "Cancelable"
	local noCancelFilter = isPlayer and "NotCancelablePlayer" or "NotCancelable"

	if setFilters.Player and isPlayer then return true end
	if setFilters.RaidPlayerDispellable and not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, auraInstanceID, auraType .. "|RAID_PLAYER_DISPELLABLE") then return true end

	if (setFilters[cancelFilter] or setFilters[noCancelFilter]) then
		local isCancellable = not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, auraInstanceID, auraType .. "|CANCELABLE")
		if setFilters[cancelFilter] and isCancellable then return true end
		if setFilters[noCancelFilter] and not isCancellable then return true end
	end

	if isPlayer then
		if setFilters.CrowdControlPlayer and not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, auraInstanceID, auraType .. "|CROWD_CONTROL") then return true end
		if setFilters.BigDefensivePlayer and not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, auraInstanceID, auraType .. "|BIG_DEFENSIVE") then return true end
		if setFilters.ExternalDefensivePlayer and not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, auraInstanceID, auraType .. "|EXTERNAL_DEFENSIVE") then return true end
		if setFilters.RaidInCombatPlayer and not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, auraInstanceID, auraType .. "|RAID_IN_COMBAT") then return true end
		if setFilters.RaidPlayer and not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, auraInstanceID, auraType .. "|RAID") then return true end
	else
		if setFilters.CrowdControl and not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, auraInstanceID, auraType .. "|CROWD_CONTROL") then return true end
		if setFilters.BigDefensive and not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, auraInstanceID, auraType .. "|BIG_DEFENSIVE") then return true end
		if setFilters.ExternalDefensive and not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, auraInstanceID, auraType .. "|EXTERNAL_DEFENSIVE") then return true end
		if setFilters.RaidInCombat and not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, auraInstanceID, auraType .. "|RAID_IN_COMBAT") then return true end
		if setFilters.Raid and not C_UnitAuras.IsAuraFilteredOutByInstanceID(filterUnit, auraInstanceID, auraType .. "|RAID") then return true end
	end
end

UUF.StyleAuras = StyleAuras
UUF.FilterAura = FilterAura

local function GetCustomAuraType(CustomDB)
	return CustomDB and CustomDB.Type == "Debuffs" and "Debuffs" or "Buffs"
end

local function GetCustomAuraFilter(CustomDB)
	return GetCustomAuraType(CustomDB) == "Buffs" and "HELPFUL" or "HARMFUL"
end

function UUF:GetCustomAuraFilter(CustomDB)
	return GetCustomAuraFilter(CustomDB)
end

function UUF:UpdateUnitAuras(unitFrame, unit)
    if not unit or not unitFrame then return end
    local AurasDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Auras
    if not AurasDB then return end
    local BuffsDB = AurasDB.Buffs
    local DebuffsDB = AurasDB.Debuffs
    local CustomDB = AurasDB.Custom
    BuffsDB.Filter = "HELPFUL"
    DebuffsDB.Filter = "HARMFUL"
    if CustomDB then CustomDB.Filter = GetCustomAuraFilter(CustomDB) end

    if unit == "player" then
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
        unitFrame.BuffContainer.onlyShowPlayer = BuffsDB.OnlyShowPlayer
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
        unitFrame.DebuffContainer.onlyShowPlayer = DebuffsDB.OnlyShowPlayer
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

    if unitFrame.CustomAuraContainer and CustomDB then
        local customAuraType = GetCustomAuraType(CustomDB)
        local customAuraFilter = GetCustomAuraFilter(CustomDB)
        if CustomDB.Enabled then
            unitFrame.CustomAuras = unitFrame.CustomAuraContainer
            local customPerRow = CustomDB.Wrap or 3
            local customRows = math.ceil(CustomDB.Num / customPerRow)
            local customContainerWidth = (CustomDB.Size + CustomDB.Layout[5]) * customPerRow - CustomDB.Layout[5]
            local customContainerHeight = (CustomDB.Size + CustomDB.Layout[5]) * customRows - CustomDB.Layout[5]
            unitFrame.CustomAuraContainer:ClearAllPoints()
            unitFrame.CustomAuraContainer:SetSize(customContainerWidth, customContainerHeight)
            unitFrame.CustomAuraContainer:SetFrameStrata(AurasDB.FrameStrata)
            unitFrame.CustomAuraContainer:SetPoint(CustomDB.Layout[1], unitFrame, CustomDB.Layout[2], CustomDB.Layout[3], CustomDB.Layout[4])
            unitFrame.CustomAuraContainer.size = CustomDB.Size
            unitFrame.CustomAuraContainer.spacing = CustomDB.Layout[5]
            unitFrame.CustomAuraContainer.num = CustomDB.Num
            unitFrame.CustomAuraContainer.initialAnchor = CustomDB.Layout[1]
            unitFrame.CustomAuraContainer.onlyShowPlayer = CustomDB.OnlyShowPlayer
            unitFrame.CustomAuraContainer.growthX = CustomDB.GrowthDirection
            unitFrame.CustomAuraContainer.growthY = CustomDB.WrapDirection
            unitFrame.CustomAuraContainer.filter = customAuraFilter
            unitFrame.CustomAuraContainer.FilterAura = function(_, filterUnit, aura, auraType)
                return FilterAura(CustomDB, filterUnit, aura, auraType)
            end
            unitFrame.CustomAuraContainer.createdButtons = unitFrame.CustomAuras.createdButtons or 0
            unitFrame.CustomAuraContainer.anchoredButtons = unitFrame.CustomAuras.anchoredButtons or 0
            unitFrame.CustomAuraContainer.PostCreateButton = function(_, button) StyleAuras(_, button, unit, customAuraFilter, nil, "Custom") end
            unitFrame.CustomAuraContainer.showType = CustomDB.ShowType
            unitFrame.CustomAuraContainer.showBuffType = customAuraType == "Buffs" and CustomDB.ShowType
            unitFrame.CustomAuraContainer.showDebuffType = customAuraType == "Debuffs" and CustomDB.ShowType
            unitFrame.CustomAuraContainer:Show()
            if not unitFrame:IsElementEnabled("CustomAuras") then unitFrame:EnableElement("CustomAuras") end
            if unitFrame.CustomAuraContainer.ForceUpdate then unitFrame.CustomAuraContainer:ForceUpdate() end
        else
            if unitFrame:IsElementEnabled("CustomAuras") then unitFrame:DisableElement("CustomAuras") end
            unitFrame.CustomAuraContainer:Hide()
            unitFrame.CustomAuras = nil
        end
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
            StyleAuras(nil, button, unit, "HELPFUL", true)
        end
    end
    for _, button in ipairs(unitFrame.DebuffContainer) do
        if button and button:IsShown() then
            StyleAuras(nil, button, unit, "HARMFUL", true)
        end
    end
    if unitFrame.CustomAuraContainer and CustomDB then
        local customAuraFilter = GetCustomAuraFilter(CustomDB)
        for _, button in ipairs(unitFrame.CustomAuraContainer) do
            if button and button:IsShown() then
                StyleAuras(nil, button, unit, customAuraFilter, true, "Custom")
            end
        end
    end
    if UUF.AURA_TEST_MODE == true then UUF:CreateTestAuras(unitFrame, unit) end
end

function UUF:CreateUnitAuras(unitFrame, unit)
	local AurasDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Auras
	local BuffsDB = AurasDB.Buffs
	local DebuffsDB = AurasDB.Debuffs
	local CustomDB = AurasDB.Custom
	BuffsDB.Filter = "HELPFUL"
	DebuffsDB.Filter = "HARMFUL"
	if CustomDB then CustomDB.Filter = GetCustomAuraFilter(CustomDB) end

	if not unitFrame.BuffContainer then
		unitFrame.BuffContainer = CreateFrame("Frame", UUF:FetchFrameName(unit) .. "_BuffsContainer", unitFrame)
		unitFrame.BuffContainer:SetFrameStrata(AurasDB.FrameStrata)
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
		unitFrame.BuffContainer.filter = "HELPFUL"
		unitFrame.BuffContainer.FilterAura = function(_, filterUnit, aura)
			return FilterAura(BuffsDB, filterUnit, aura, "HELPFUL")
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

	if not unitFrame.DebuffContainer then
		unitFrame.DebuffContainer = CreateFrame("Frame", UUF:FetchFrameName(unit) .. "_DebuffsContainer", unitFrame)
		unitFrame.DebuffContainer:SetFrameStrata(AurasDB.FrameStrata)
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
		unitFrame.DebuffContainer.filter = "HARMFUL"
		unitFrame.DebuffContainer.FilterAura = function(_, filterUnit, aura)
			return FilterAura(DebuffsDB, filterUnit, aura, "HARMFUL")
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

	if CustomDB and not unitFrame.CustomAuraContainer then
		local customAuraType = GetCustomAuraType(CustomDB)
		local customAuraFilter = GetCustomAuraFilter(CustomDB)
		unitFrame.CustomAuraContainer = CreateFrame("Frame", UUF:FetchFrameName(unit) .. "_CustomAurasContainer", unitFrame)
		unitFrame.CustomAuraContainer:SetFrameStrata(AurasDB.FrameStrata)
		local customPerRow = CustomDB.Wrap or 3
		local customRows = math.ceil(CustomDB.Num / customPerRow)
		local customContainerWidth = (CustomDB.Size + CustomDB.Layout[5]) * customPerRow - CustomDB.Layout[5]
		local customContainerHeight = (CustomDB.Size + CustomDB.Layout[5]) * customRows - CustomDB.Layout[5]
		unitFrame.CustomAuraContainer:SetSize(customContainerWidth, customContainerHeight)
		unitFrame.CustomAuraContainer:SetPoint(CustomDB.Layout[1], unitFrame, CustomDB.Layout[2], CustomDB.Layout[3], CustomDB.Layout[4])
		unitFrame.CustomAuraContainer.size = CustomDB.Size
		unitFrame.CustomAuraContainer.spacing = CustomDB.Layout[5]
		unitFrame.CustomAuraContainer.num = CustomDB.Num
		unitFrame.CustomAuraContainer.initialAnchor = CustomDB.Layout[1]
		unitFrame.CustomAuraContainer.onlyShowPlayer = CustomDB.OnlyShowPlayer
		unitFrame.CustomAuraContainer.growthX = CustomDB.GrowthDirection
		unitFrame.CustomAuraContainer.growthY = CustomDB.WrapDirection
		unitFrame.CustomAuraContainer.filter = customAuraFilter
		unitFrame.CustomAuraContainer.FilterAura = function(_, filterUnit, aura, auraType)
			return FilterAura(CustomDB, filterUnit, aura, auraType)
		end
		unitFrame.CustomAuraContainer.anchoredButtons = 0
		unitFrame.CustomAuraContainer.createdButtons = 0
		unitFrame.CustomAuraContainer.PostCreateButton = function(_, button) StyleAuras(_, button, unit, customAuraFilter, nil, "Custom") end
		unitFrame.CustomAuraContainer.tooltipAnchor = "ANCHOR_CURSOR"
		unitFrame.CustomAuraContainer.showType = CustomDB.ShowType
		unitFrame.CustomAuraContainer.showBuffType = customAuraType == "Buffs" and CustomDB.ShowType
		unitFrame.CustomAuraContainer.showDebuffType = customAuraType == "Debuffs" and CustomDB.ShowType
		unitFrame.CustomAuraContainer.dispelColorCurve = C_CurveUtil.CreateColorCurve()
		unitFrame.CustomAuraContainer.dispelColorCurve:SetType(Enum.LuaCurveType.Step)

		for _, dispelIndex in next, oUF.Enum.DispelType do
			if(oUF.colors.dispel[dispelIndex]) then
				unitFrame.CustomAuraContainer.dispelColorCurve:AddPoint(dispelIndex, oUF.colors.dispel[dispelIndex])
			end
		end

		if not oUF.colors.dispel[0] then unitFrame.CustomAuraContainer.dispelColorCurve:AddPoint(0, CreateColor(0.8, 0, 0, 1)) end

		if CustomDB.Enabled then
			unitFrame.CustomAuras = unitFrame.CustomAuraContainer
		else
			unitFrame.CustomAuraContainer:Hide()
		end
	end

    if unit == "player" then
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
    if unitFrame.CustomAuraContainer then unitFrame.CustomAuraContainer:SetFrameStrata(unitDB.Auras.FrameStrata) end
    if unit == "player" and unitFrame.PrivateAuraContainer and unitDB.Auras.PrivateAuras then unitFrame.PrivateAuraContainer:SetFrameStrata(unitDB.Auras.PrivateAuras.FrameStrata) end
end

function UUF:CreateTestAuras(unitFrame, unit)
    if not unit then return end
    if not unitFrame then return end
    local General = UUF.db.profile.General
    local AurasDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Auras
    local BuffsDB = AurasDB.Buffs
    local DebuffsDB = AurasDB.Debuffs
    local CustomDB = AurasDB.Custom
    if UUF.AURA_TEST_MODE then
		if unit == "player" and unitFrame.PrivateAuraContainer then
			local PrivateAurasDB = UUF.db.profile.Units.player.Auras.PrivateAuras
			if PrivateAurasDB.Enabled then
				unitFrame.PrivateAuraContainer:Show()

				for j = 1, PrivateAurasDB.Num do
					local button = unitFrame.PrivateAuraContainer["fake" .. j]
					if not button then
						button = CreateFrame("Frame", nil, unitFrame.PrivateAuraContainer, "BackdropTemplate")
						button:SetBackdrop(UUF.BACKDROP)
						button:SetBackdropColor(0, 0, 0, 0)
						button:SetBackdropBorderColor(0, 0, 0, 1)

						button.Icon = button:CreateTexture(nil, "BORDER")
						button.Icon:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
						button.Icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
						button.Icon:SetTexture(135768)
						button.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

						button.Cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
						button.Cooldown:SetAllPoints()
						button.Cooldown:SetDrawEdge(false)
						button.Cooldown:SetReverse(true)
						button.Cooldown:SetCooldown(GetTime(), 600)
						unitFrame.PrivateAuraContainer["fake" .. j] = button
					end

					local column = (j - 1) % PrivateAurasDB.Num
					local row = math.floor((j - 1) / PrivateAurasDB.Num)
					local x = column * (PrivateAurasDB.Size + PrivateAurasDB.Spacing)
					local y = row * (PrivateAurasDB.Size + PrivateAurasDB.Spacing)
					if PrivateAurasDB.GrowthX == "LEFT" then x = -x end
					if PrivateAurasDB.GrowthY == "DOWN" then y = -y end

					button:SetSize(PrivateAurasDB.Size, PrivateAurasDB.Size)
					button:SetFrameStrata(PrivateAurasDB.FrameStrata)
					button:ClearAllPoints()
					button:SetPoint(PrivateAurasDB.InitialAnchor, unitFrame.PrivateAuraContainer, PrivateAurasDB.InitialAnchor, x, y)
					button.Cooldown:SetDrawSwipe(not PrivateAurasDB.DisableCooldown)
					button.Cooldown:SetHideCountdownNumbers(PrivateAurasDB.DisableCooldownText)
					button.Cooldown:SetShown(not PrivateAurasDB.DisableCooldown or not PrivateAurasDB.DisableCooldownText)
					button:Show()
				end

				local maxFake = PrivateAurasDB.Num
				for j = maxFake + 1, (unitFrame.PrivateAuraContainer.maxFake or maxFake) do
					local button = unitFrame.PrivateAuraContainer["fake" .. j]
					if button then button:Hide() end
				end
				unitFrame.PrivateAuraContainer.maxFake = PrivateAurasDB.Num
			else
				for j = 1, (unitFrame.PrivateAuraContainer.maxFake or 0) do
					local button = unitFrame.PrivateAuraContainer["fake" .. j]
					if button then button:Hide() end
				end
			end
		end

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
                    UUF:ApplyCooldownText(button, button.Duration, unit)
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
                    UUF:ApplyCooldownText(button, button.Duration, unit)
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

        if unitFrame.CustomAuraContainer and CustomDB then
            if CustomDB.Enabled then
                unitFrame.CustomAuraContainer:ClearAllPoints()
                unitFrame.CustomAuraContainer:SetPoint(CustomDB.Layout[1], unitFrame, CustomDB.Layout[2], CustomDB.Layout[3], CustomDB.Layout[4])
                unitFrame.CustomAuraContainer:SetFrameStrata(AurasDB.FrameStrata)
                unitFrame.CustomAuraContainer:Show()

                for j = 1, CustomDB.Num do
                    local button = unitFrame.CustomAuraContainer["fake" .. j]
                    if not button then
                        button = CreateFrame("Button", nil, unitFrame.CustomAuraContainer, "BackdropTemplate")
                        button:SetBackdrop(UUF.BACKDROP)
                        button:SetBackdropColor(0, 0, 0, 0)
                        button:SetBackdropBorderColor(0, 0, 0, 1)
                        button:SetFrameStrata(AurasDB.FrameStrata)
                        button.Icon = button:CreateTexture(nil, "BORDER")
                        button.Icon:SetAllPoints()

                        button.Count = button:CreateFontString(nil, "OVERLAY")
                        unitFrame.CustomAuraContainer["fake" .. j] = button
                    end

                    button:SetSize(CustomDB.Size, CustomDB.Size)
                    button.Count:ClearAllPoints()
                    button.Count:SetPoint(CustomDB.Count.Layout[1], button, CustomDB.Count.Layout[2], CustomDB.Count.Layout[3], CustomDB.Count.Layout[4])
                    button.Count:SetFont(UUF.Media.Font, CustomDB.Count.FontSize, General.Fonts.FontFlag)
                    if General.Fonts.Shadow.Enabled then
                        button.Count:SetShadowColor(unpack(General.Fonts.Shadow.Colour))
                        button.Count:SetShadowOffset(General.Fonts.Shadow.XPos, General.Fonts.Shadow.YPos)
                    else
                        button.Count:SetShadowColor(0, 0, 0, 0)
                        button.Count:SetShadowOffset(0, 0)
                    end
                    button.Count:SetTextColor(unpack(CustomDB.Count.Colour))

                    local row = math.floor((j - 1) / CustomDB.Wrap)
                    local col = (j - 1) % CustomDB.Wrap
                    local x = col * (CustomDB.Size + CustomDB.Layout[5])
                    local y = row * (CustomDB.Size + CustomDB.Layout[5])
                    if CustomDB.GrowthDirection == "LEFT" then x = -x end
                    if CustomDB.WrapDirection == "DOWN" then y = -y end

                    button:ClearAllPoints()
                    button:SetPoint(CustomDB.Layout[1], unitFrame.CustomAuraContainer, CustomDB.Layout[1], x, y)
                    button.Icon:SetTexture(CustomDB.Type == "Debuffs" and 135768 or 135769)
                    button.Icon:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
                    button.Icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
                    button.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
                    button.Count:SetText(j)
                    button.Duration = button.Duration or button:CreateFontString(nil, "OVERLAY")
                    UUF:ApplyCooldownText(button, button.Duration, unit)
                    button.Duration:SetText("10m")
                    button:Show()
                end

                local maxFake = CustomDB.Num
                for j = maxFake + 1, (unitFrame.CustomAuraContainer.maxFake or maxFake) do
                    local button = unitFrame.CustomAuraContainer["fake" .. j]
                    if button then button:Hide() end
                end
                unitFrame.CustomAuraContainer.maxFake = CustomDB.Num
            else
                unitFrame.CustomAuraContainer:Hide()
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
        if unitFrame.CustomAuraContainer then
            for j = 1, (unitFrame.CustomAuraContainer.maxFake or 0) do
                local button = unitFrame.CustomAuraContainer["fake" .. j]
                if button then button:Hide() end
            end
        end
		if unit == "player" and unitFrame.PrivateAuraContainer then
			for j = 1, (unitFrame.PrivateAuraContainer.maxFake or 0) do
				local button = unitFrame.PrivateAuraContainer["fake" .. j]
				if button then button:Hide() end
			end
		end
    end
end
