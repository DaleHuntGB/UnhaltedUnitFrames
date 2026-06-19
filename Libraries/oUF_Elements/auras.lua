local _, UUF = ...

function UUF:ConfigureAuraSorting(auraContainer, sorting)
	sorting = sorting or "BLIZZARD"
	if not auraContainer.UUFAuraSortingPatched then
		auraContainer.UUFOriginalPostUpdateInfo = auraContainer.PostUpdateInfo
		auraContainer.UUFAuraSortingPatched = true
	end

	if sorting == "BLIZZARD" or not C_UnitAuras.GetUnitAuraInstanceIDs then
		auraContainer.PostUpdateInfo = auraContainer.UUFOriginalPostUpdateInfo
		auraContainer.SortAuras = nil
		auraContainer.UUFAuraSortOrder = nil
		return
	end

	auraContainer.UUFAuraSortRule = (sorting == "DURATION" or sorting == "DURATION_REVERSED") and Enum.UnitAuraSortRule.ExpirationOnly or Enum.UnitAuraSortRule.Default
	auraContainer.UUFAuraSortDirection = (sorting == "BLIZZARD_REVERSED" or sorting == "DURATION_REVERSED") and Enum.UnitAuraSortDirection.Reverse or Enum.UnitAuraSortDirection.Normal
	auraContainer.UUFAuraSortOrder = table.wipe(auraContainer.UUFAuraSortOrder or {})

	auraContainer.PostUpdateInfo = function(element, unit, ...)
		if element.UUFOriginalPostUpdateInfo then element:UUFOriginalPostUpdateInfo(unit, ...) end
		local filter = element.filter or "HELPFUL"
		if type(filter) == "function" then filter = filter(element, unit) end
		local auraInstanceIDs = C_UnitAuras.GetUnitAuraInstanceIDs(unit, filter, nil, element.UUFAuraSortRule, element.UUFAuraSortDirection) or {}
		element.UUFAuraSortOrder = table.wipe(element.UUFAuraSortOrder or {})
		for index, auraInstanceID in ipairs(auraInstanceIDs) do element.UUFAuraSortOrder[auraInstanceID] = index end
	end

	auraContainer.SortAuras = function(a, b)
		local order = auraContainer.UUFAuraSortOrder
		local orderA = order and order[a.auraInstanceID] or math.huge
		local orderB = order and order[b.auraInstanceID] or math.huge
		if orderA ~= orderB then return orderA < orderB end
		return a.auraInstanceID < b.auraInstanceID
	end
end
