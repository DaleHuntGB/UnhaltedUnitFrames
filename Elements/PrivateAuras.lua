local _, UUF = ...

-----------------------------------------------------------------------
-- Party & Raid
-----------------------------------------------------------------------

function UUF:CreateUnitPrivateAuras(unitFrame, unit)
    local normalizedUnit = UUF:GetNormalizedUnit(unit)
    local UnitDB = UUF.db.profile.Units[normalizedUnit]
    if not UnitDB or not UnitDB.Auras or not UnitDB.Auras.PrivateAuras then return end
    local PrivateAurasDB = UnitDB.Auras.PrivateAuras

    if not unitFrame.PrivateAurasContainer then
        unitFrame.PrivateAurasContainer = CreateFrame("Frame", UUF:FetchFrameName(unit) .. "_PrivateAurasContainer", unitFrame.HighLevelContainer)
    end

    local auraWidth = PrivateAurasDB.Width or PrivateAurasDB.Size or 16
    local auraHeight = PrivateAurasDB.Height or PrivateAurasDB.Size or 16
    local spacingX = PrivateAurasDB.SpacingX or PrivateAurasDB.Spacing or 0
    local spacingY = PrivateAurasDB.SpacingY or PrivateAurasDB.Spacing or 0
    local maxCols = PrivateAurasDB.Wrap or 1
    local num = PrivateAurasDB.Num or 1
    if maxCols < 1 then maxCols = 1 end
    if num < 1 then num = 1 end
    local cols = math.min(maxCols, num)
    local rows = math.ceil(num / maxCols)

    unitFrame.PrivateAurasContainer:ClearAllPoints()
    unitFrame.PrivateAurasContainer:SetPoint("CENTER", unitFrame.HighLevelContainer, "CENTER", 0, 0)
    unitFrame.PrivateAurasContainer:SetSize((auraWidth * cols) + (spacingX * (cols - 1)), (auraHeight * rows) + (spacingY * (rows - 1)))
    unitFrame.PrivateAurasContainer:SetFrameStrata(UnitDB.Auras.FrameStrata)
    unitFrame.PrivateAurasContainer.disableCooldown = PrivateAurasDB.DisableCooldownSwipe
    unitFrame.PrivateAurasContainer.disableCooldownText = PrivateAurasDB.DisableCooldownText
    unitFrame.PrivateAurasContainer.size = PrivateAurasDB.Size
    unitFrame.PrivateAurasContainer.width = PrivateAurasDB.Width
    unitFrame.PrivateAurasContainer.height = PrivateAurasDB.Height
    unitFrame.PrivateAurasContainer.spacing = PrivateAurasDB.Spacing
    unitFrame.PrivateAurasContainer.spacingX = PrivateAurasDB.SpacingX
    unitFrame.PrivateAurasContainer.spacingY = PrivateAurasDB.SpacingY
    unitFrame.PrivateAurasContainer.growthX = PrivateAurasDB.GrowthX
    unitFrame.PrivateAurasContainer.growthY = PrivateAurasDB.GrowthY
    unitFrame.PrivateAurasContainer.initialAnchor = PrivateAurasDB.InitialAnchor
    unitFrame.PrivateAurasContainer.num = PrivateAurasDB.Num
    unitFrame.PrivateAurasContainer.maxCols = PrivateAurasDB.Wrap
    unitFrame.PrivateAurasContainer.borderScale = PrivateAurasDB.Border
    if PrivateAurasDB.Enabled then
        unitFrame.PrivateAuras = unitFrame.PrivateAurasContainer
        unitFrame.PrivateAurasContainer:Show()
    else
        unitFrame.PrivateAuras = nil
        unitFrame.PrivateAurasContainer:Hide()
    end
end

function UUF:UpdateUnitPrivateAuras(unitFrame, unit)
    local normalizedUnit = UUF:GetNormalizedUnit(unit)
    local UnitDB = UUF.db.profile.Units[normalizedUnit]
    if not UnitDB or not UnitDB.Auras or not UnitDB.Auras.PrivateAuras or not unitFrame or not unitFrame.PrivateAurasContainer then return end
    local PrivateAurasDB = UnitDB.Auras.PrivateAuras

    local auraWidth = PrivateAurasDB.Width or PrivateAurasDB.Size or 16
    local auraHeight = PrivateAurasDB.Height or PrivateAurasDB.Size or 16
    local spacingX = PrivateAurasDB.SpacingX or PrivateAurasDB.Spacing or 0
    local spacingY = PrivateAurasDB.SpacingY or PrivateAurasDB.Spacing or 0
    local maxCols = PrivateAurasDB.Wrap or 1
    local num = PrivateAurasDB.Num or 1
    if maxCols < 1 then maxCols = 1 end
    if num < 1 then num = 1 end
    local cols = math.min(maxCols, num)
    local rows = math.ceil(num / maxCols)

    unitFrame.PrivateAurasContainer:ClearAllPoints()
    unitFrame.PrivateAurasContainer:SetPoint("CENTER", unitFrame.HighLevelContainer, "CENTER", 0, 0)
    unitFrame.PrivateAurasContainer:SetSize((auraWidth * cols) + (spacingX * (cols - 1)), (auraHeight * rows) + (spacingY * (rows - 1)))
    unitFrame.PrivateAurasContainer:SetFrameStrata(UnitDB.Auras.FrameStrata)
    unitFrame.PrivateAurasContainer.disableCooldown = PrivateAurasDB.DisableCooldownSwipe
    unitFrame.PrivateAurasContainer.disableCooldownText = PrivateAurasDB.DisableCooldownText
    unitFrame.PrivateAurasContainer.size = PrivateAurasDB.Size
    unitFrame.PrivateAurasContainer.width = PrivateAurasDB.Width
    unitFrame.PrivateAurasContainer.height = PrivateAurasDB.Height
    unitFrame.PrivateAurasContainer.spacing = PrivateAurasDB.Spacing
    unitFrame.PrivateAurasContainer.spacingX = PrivateAurasDB.SpacingX
    unitFrame.PrivateAurasContainer.spacingY = PrivateAurasDB.SpacingY
    unitFrame.PrivateAurasContainer.growthX = PrivateAurasDB.GrowthX
    unitFrame.PrivateAurasContainer.growthY = PrivateAurasDB.GrowthY
    unitFrame.PrivateAurasContainer.initialAnchor = PrivateAurasDB.InitialAnchor
    unitFrame.PrivateAurasContainer.num = PrivateAurasDB.Num
    unitFrame.PrivateAurasContainer.maxCols = PrivateAurasDB.Wrap
    unitFrame.PrivateAurasContainer.borderScale = PrivateAurasDB.Border

    if PrivateAurasDB.Enabled then
        if not unitFrame.PrivateAuras then unitFrame.PrivateAuras = unitFrame.PrivateAurasContainer end
        if not unitFrame:IsElementEnabled("PrivateAuras") then unitFrame:EnableElement("PrivateAuras") end
        unitFrame.PrivateAurasContainer:Show()
        if unitFrame.PrivateAurasContainer.ForceUpdate then unitFrame.PrivateAurasContainer:ForceUpdate() end
    else
        if unitFrame:IsElementEnabled("PrivateAuras") then unitFrame:DisableElement("PrivateAuras") end
        unitFrame.PrivateAuras = nil
        unitFrame.PrivateAurasContainer:Hide()
    end
end
