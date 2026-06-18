local _, UUF = ...

function UUF:ConfigureAuraSorting(container, sorting)
	sorting = sorting or "BLIZZARD"
	if not container.UUFAuraSortingPatched then
		container.UUFOriginalPostUpdateInfo = container.PostUpdateInfo
		container.UUFAuraSortingPatched = true
	end

	if sorting == "BLIZZARD" or not C_UnitAuras.GetUnitAuraInstanceIDs then
		container.PostUpdateInfo = container.UUFOriginalPostUpdateInfo
		container.SortAuras = nil
		container.UUFAuraSortOrder = nil
		return
	end

	container.UUFAuraSortRule = (sorting == "DURATION" or sorting == "DURATION_REVERSED") and Enum.UnitAuraSortRule.ExpirationOnly or Enum.UnitAuraSortRule.Default
	container.UUFAuraSortDirection = (sorting == "BLIZZARD_REVERSED" or sorting == "DURATION_REVERSED") and Enum.UnitAuraSortDirection.Reverse or Enum.UnitAuraSortDirection.Normal
	container.UUFAuraSortOrder = table.wipe(container.UUFAuraSortOrder or {})
	container.PostUpdateInfo = function(element, unit, ...)
		if element.UUFOriginalPostUpdateInfo then element:UUFOriginalPostUpdateInfo(unit, ...) end
		local filter = element.filter or "HELPFUL"
		if type(filter) == "function" then filter = filter(element, unit) end
		local auraInstanceIDs = C_UnitAuras.GetUnitAuraInstanceIDs(unit, filter, nil, element.UUFAuraSortRule, element.UUFAuraSortDirection) or {}
		element.UUFAuraSortOrder = table.wipe(element.UUFAuraSortOrder or {})
		for index, auraInstanceID in ipairs(auraInstanceIDs) do element.UUFAuraSortOrder[auraInstanceID] = index end
	end
	container.SortAuras = function(a, b)
		local order = container.UUFAuraSortOrder
		local orderA = order and order[a.auraInstanceID] or math.huge
		local orderB = order and order[b.auraInstanceID] or math.huge
		if orderA ~= orderB then return orderA < orderB end
		return a.auraInstanceID < b.auraInstanceID
	end
end
