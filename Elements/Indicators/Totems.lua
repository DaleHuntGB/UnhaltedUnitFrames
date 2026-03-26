local _, UUF = ...
local MAX_TOTEM_SLOTS = _G.MAX_TOTEMS or 4
local DEFAULT_TOTEM_PRIORITIES = {}

for slot = 1, MAX_TOTEM_SLOTS do
    DEFAULT_TOTEM_PRIORITIES[slot] = slot
end

local TOTEM_PRIORITIES = _G.STANDARD_TOTEM_PRIORITIES or DEFAULT_TOTEM_PRIORITIES
if UnitClassBase and UnitClassBase("player") == "SHAMAN" and _G.SHAMAN_TOTEM_PRIORITIES then
    TOTEM_PRIORITIES = _G.SHAMAN_TOTEM_PRIORITIES
end

local DISPLAY_SLOT_MAP = {}
for slot = 1, MAX_TOTEM_SLOTS do
    DISPLAY_SLOT_MAP[TOTEM_PRIORITIES[slot] or slot] = slot
end

local PendingTotemUpdates = {}
local TotemCombatWatcher = CreateFrame("Frame")

local function FetchAuraDurationRegion(cooldown)
    if not cooldown then return end
    for _, region in ipairs({ cooldown:GetRegions() }) do
        if region:GetObjectType() == "FontString" then return region end
    end
end

local function PositionTotem(totem, anchorFrame, TotemsDB, displayIndex)
    if not totem or not anchorFrame or not TotemsDB then return end

    local anchorFrom = TotemsDB.Layout[1]
    local anchorTo = TotemsDB.Layout[2]
    local baseXOffset = TotemsDB.Layout[3]
    local baseYOffset = TotemsDB.Layout[4]
    local spacing = TotemsDB.Layout[5] or 0
    local size = TotemsDB.Size or 0
    local growthDirection = TotemsDB.GrowthDirection or "LEFT"
    local slotOffset = ((displayIndex or 1) - 1) * (size + spacing)

    local xOffset = baseXOffset
    local yOffset = baseYOffset

    if growthDirection == "RIGHT" then
        xOffset = xOffset + slotOffset
    elseif growthDirection == "UP" then
        yOffset = yOffset + slotOffset
    elseif growthDirection == "DOWN" then
        yOffset = yOffset - slotOffset
    else
        xOffset = xOffset - slotOffset
    end

    totem:ClearAllPoints()
    totem:SetPoint(anchorFrom, anchorFrame, anchorTo, xOffset, yOffset)
end

local function GetTotemSlotForDisplayIndex(displayIndex)
    return DISPLAY_SLOT_MAP[displayIndex] or displayIndex
end

local function QueueTotemUpdate(unitFrame, unit)
    if not unitFrame then return end

    PendingTotemUpdates[unitFrame] = unit or unitFrame.unit
    TotemCombatWatcher:RegisterEvent("PLAYER_REGEN_ENABLED")
end

local function ApplyTotemLayout(unitFrame, TotemsDB)
    if not unitFrame or not unitFrame.Totems or not TotemsDB then return end

    local anchorFrame = unitFrame.HighLevelContainer or unitFrame
    if not anchorFrame then return end

    for displayIndex = 1, MAX_TOTEM_SLOTS do
        local Totem = unitFrame.Totems[displayIndex]
        if Totem then
            local actualSlot = GetTotemSlotForDisplayIndex(displayIndex)
            Totem:SetSize(TotemsDB.Size, TotemsDB.Size)
            Totem:SetAttribute("totem-slot2", actualSlot)
            Totem:SetID(actualSlot)
            PositionTotem(Totem, anchorFrame, TotemsDB, displayIndex)
        end
    end
end

local function UpdateTotemCooldown(cooldown, durationObj)
    if not cooldown then return end

    if durationObj and cooldown.SetCooldownFromDurationObject then
        cooldown:SetCooldownFromDurationObject(durationObj)
        cooldown:Show()
    elseif durationObj and cooldown.SetCooldownFromDuration then
        cooldown:SetCooldownFromDuration(durationObj)
        cooldown:Show()
    else
        if cooldown.Clear then
            cooldown:Clear()
        end
        cooldown:Hide()
    end
end

local function UpdateTotemBySlot(unitFrame, event, slot)
    local Totems = unitFrame and unitFrame.Totems
    if not Totems or slot > #Totems then return end

    if Totems.PreUpdate then
        Totems:PreUpdate(slot)
    end

    local displayIndex = TOTEM_PRIORITIES[slot] or slot
    local Totem = Totems[displayIndex]
    if not Totem then return end

    local haveTotem, name, start, duration, icon = GetTotemInfo(slot)
    local durationObj = GetTotemDuration(slot)

    if Totem.Icon then
        Totem.Icon:SetTexture(icon)
    end

    UpdateTotemCooldown(Totem.Cooldown, durationObj)
    Totem:SetAlphaFromBoolean(haveTotem, 1, 0)

    if Totems.PostUpdate then
        return Totems:PostUpdate(slot, haveTotem, name, start, duration, icon, durationObj)
    end
end

local function ApplyAuraDuration(icon, unit)
    local UUFDB = UUF.db.profile
    local FontsDB = UUFDB.General.Fonts
    local TotemsDB = UUFDB.Units[UUF:GetNormalizedUnit(unit)].Indicators.Totems
    local TotemsDurationDB = TotemsDB.TotemDuration
    if not icon then return end
    C_Timer.After(0.01, function()
        local textRegion = FetchAuraDurationRegion(icon)
        if textRegion then
            if TotemsDurationDB.ScaleByIconSize then
                local iconWidth = icon:GetWidth()
                local scaleFactor = iconWidth > 0 and iconWidth / 36 or 1
                local fontSize = TotemsDurationDB.FontSize * scaleFactor
                if fontSize < 1 then fontSize = 12 end
                textRegion:SetFont(UUF.Media.Font, fontSize, FontsDB.FontFlag)
            else
                textRegion:SetFont(UUF.Media.Font, TotemsDurationDB.FontSize, FontsDB.FontFlag)
            end
            textRegion:SetTextColor(TotemsDurationDB.Colour[1], TotemsDurationDB.Colour[2], TotemsDurationDB.Colour[3], 1)
            textRegion:ClearAllPoints()
            textRegion:SetPoint(TotemsDurationDB.Layout[1], icon, TotemsDurationDB.Layout[2], TotemsDurationDB.Layout[3], TotemsDurationDB.Layout[4])
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

TotemCombatWatcher:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")

    for unitFrame, unit in pairs(PendingTotemUpdates) do
        PendingTotemUpdates[unitFrame] = nil
        if unitFrame then
            UUF:UpdateUnitTotems(unitFrame, unit)
        end
    end
end)

function UUF:CreateUnitTotems(unitFrame, unit)
    local TotemsDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Totems

    if not TotemsDB.Enabled then return end

    local anchorFrame = unitFrame.HighLevelContainer or unitFrame
    local Totems = {}

    for index = 1, MAX_TOTEM_SLOTS do
        local actualSlot = GetTotemSlotForDisplayIndex(index)
        local Totem = CreateFrame('Button', nil, anchorFrame, 'SecureActionButtonTemplate')
        Totem:SetSize(TotemsDB.Size, TotemsDB.Size)
        Totem:RegisterForClicks("RightButtonUp", "RightButtonDown")
        Totem:SetAttribute("type2", "destroytotem")
        Totem:SetAttribute("totem-slot2", actualSlot)
        Totem:SetID(actualSlot)
        PositionTotem(Totem, anchorFrame, TotemsDB, index)

        local Border = Totem:CreateTexture(nil, 'BACKGROUND')
        Border:SetAllPoints()
        Border:SetColorTexture(0, 0, 0, 1)

        local Icon = Totem:CreateTexture(nil, 'OVERLAY')
        Icon:SetPoint("TOPLEFT", Totem, "TOPLEFT", 1, -1)
        Icon:SetPoint("BOTTOMRIGHT", Totem, "BOTTOMRIGHT", -1, 1)
        Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

        local Cooldown = CreateFrame('Cooldown', nil, Totem, 'CooldownFrameTemplate')
        Cooldown:SetPoint("TOPLEFT", Totem, "TOPLEFT", 1, -1)
        Cooldown:SetPoint("BOTTOMRIGHT", Totem, "BOTTOMRIGHT", -1, 1)
        Cooldown:SetSwipeColor(0, 0, 0, 0.8)
        Cooldown:SetDrawEdge(false)
        Cooldown:SetDrawSwipe(true)
        Cooldown:SetReverse(true)

        ApplyAuraDuration(Cooldown, unit)

        Totem.Border = Border
        Totem.Icon = Icon
        Totem.Cooldown = Cooldown
        Totem:SetAlpha(0)

        Totems[index] = Totem
    end

    Totems.Override = UpdateTotemBySlot
    unitFrame.Totems = Totems
end

function UUF:UpdateUnitTotems(unitFrame, unit)
    if not unitFrame or not unit then return end

    local TotemsDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Totems
    if not TotemsDB then return end

    if InCombatLockdown() then
        QueueTotemUpdate(unitFrame, unit)
        return
    end

    if TotemsDB.Enabled then
        if not unitFrame.Totems then
            UUF:CreateUnitTotems(unitFrame, unit)
        end

        if unitFrame.Totems then
            unitFrame.Totems.Override = UpdateTotemBySlot
            ApplyTotemLayout(unitFrame, TotemsDB)
            for index = 1, MAX_TOTEM_SLOTS do
                local Totem = unitFrame.Totems[index]
                if Totem then
                    ApplyAuraDuration(Totem.Cooldown, unit)
                end
            end

            if not unitFrame:IsElementEnabled("Totems") then
                unitFrame:EnableElement("Totems")
            end

            unitFrame.Totems:ForceUpdate()
        end
    else
        PendingTotemUpdates[unitFrame] = nil
        if unitFrame.Totems then
            if unitFrame:IsElementEnabled("Totems") then
                unitFrame:DisableElement("Totems")
            end

            for index = 1, MAX_TOTEM_SLOTS do
                if unitFrame.Totems[index] then
                    unitFrame.Totems[index]:Hide()
                end
            end
        end
    end
end

local TestTotemIcons = {
    135770, -- spell_nature_strength
    135790, -- spell_nature_tranquility
    136052, -- spell_nature_windfury
    135730, -- spell_nature_groundingtotem
}

local TotemTestPool = {}

function UUF:CreateTestTotems(unitFrame, unit)
    if not unitFrame or not unit then return end

    local normalizedUnit = UUF:GetNormalizedUnit(unit)
    local unitProfile = UUF.db.profile.Units[normalizedUnit]
    if not unitProfile or not unitProfile.Indicators or not unitProfile.Indicators.Totems then return end
    local TotemsDB = unitProfile.Indicators.Totems

    if not TotemsDB.Enabled then return end

    local anchorFrame = unitFrame.HighLevelContainer or unitFrame

    -- Acquire or create pool for this frame
    if not TotemTestPool[unitFrame] then
        TotemTestPool[unitFrame] = {}
    end
    local pool = TotemTestPool[unitFrame]

    if UUF.TOTEM_TEST_MODE then
        for index = 1, MAX_TOTEM_SLOTS do
            local totem = pool[index]
            if not totem then
                totem = CreateFrame("Button", nil, anchorFrame, "BackdropTemplate")
                totem:SetBackdrop(UUF.BACKDROP)
                totem:SetBackdropColor(0, 0, 0, 1)
                totem:SetBackdropBorderColor(0, 0, 0, 1)

                local Icon = totem:CreateTexture(nil, "OVERLAY")
                Icon:SetPoint("TOPLEFT", totem, "TOPLEFT", 1, -1)
                Icon:SetPoint("BOTTOMRIGHT", totem, "BOTTOMRIGHT", -1, 1)
                Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
                totem.Icon = Icon

                local Duration = totem:CreateFontString(nil, "OVERLAY")
                totem.Duration = Duration

                pool[index] = totem
            end

            totem:SetSize(TotemsDB.Size, TotemsDB.Size)
            PositionTotem(totem, anchorFrame, TotemsDB, index)

            totem.Icon:SetTexture(TestTotemIcons[index] or 134400)

            local FontsDB = UUF.db.profile.General.Fonts
            local DurationDB = TotemsDB.TotemDuration
            totem.Duration:ClearAllPoints()
            totem.Duration:SetPoint(DurationDB.Layout[1], totem, DurationDB.Layout[2], DurationDB.Layout[3], DurationDB.Layout[4])
            if DurationDB.ScaleByIconSize then
                local scaleFactor = TotemsDB.Size > 0 and TotemsDB.Size / 36 or 1
                totem.Duration:SetFont(UUF.Media.Font, DurationDB.FontSize * scaleFactor, FontsDB.FontFlag)
            else
                totem.Duration:SetFont(UUF.Media.Font, DurationDB.FontSize, FontsDB.FontFlag)
            end
            totem.Duration:SetTextColor(DurationDB.Colour[1], DurationDB.Colour[2], DurationDB.Colour[3], 1)
            if FontsDB.Shadow.Enabled then
                totem.Duration:SetShadowColor(FontsDB.Shadow.Colour[1], FontsDB.Shadow.Colour[2], FontsDB.Shadow.Colour[3], FontsDB.Shadow.Colour[4])
                totem.Duration:SetShadowOffset(FontsDB.Shadow.XPos, FontsDB.Shadow.YPos)
            else
                totem.Duration:SetShadowColor(0, 0, 0, 0)
                totem.Duration:SetShadowOffset(0, 0)
            end
            totem.Duration:SetText(string.format("%dm", index * 4))

            totem:Show()
        end
    else
        for index = 1, MAX_TOTEM_SLOTS do
            local totem = pool[index]
            if totem then totem:Hide() end
        end
    end
end
