local _, UUF = ...
local MAX_TOTEM_SLOTS = _G.MAX_TOTEMS or 4

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

local function RefreshTotemDisplay(unitFrame)
    if not unitFrame or not unitFrame.Totems then return end

    for slot = 1, MAX_TOTEM_SLOTS do
        local totem = unitFrame.Totems[slot]
        if totem then
            local _, _, _, _, icon = GetTotemInfo(slot)
            local durationObj = GetTotemDuration(slot)

            if durationObj then
                if totem.Icon then
                    totem.Icon:SetTexture(icon)
                end

                if totem.Cooldown then
                    if totem.Cooldown.SetCooldownFromDurationObject then
                        totem.Cooldown:SetCooldownFromDurationObject(durationObj)
                    end
                end

                totem:SetAlpha(1)
            else
                totem:SetAlpha(0)
            end
        end
    end
end

local function UpdateTotemBySlot(self)
    RefreshTotemDisplay(self)
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

function UUF:CreateUnitTotems(unitFrame, unit)
    local TotemsDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Totems

    if not TotemsDB.Enabled then return end

    local anchorFrame = unitFrame.HighLevelContainer or unitFrame
    local Totems = {}

    for index = 1, MAX_TOTEM_SLOTS do
        local Totem = CreateFrame('Button', nil, anchorFrame, 'SecureActionButtonTemplate')
        Totem:SetSize(TotemsDB.Size, TotemsDB.Size)
        Totem:RegisterForClicks("RightButtonUp", "RightButtonDown")
        Totem:SetAttribute("type2", "destroytotem")
        Totem:SetAttribute("totem-slot2", index)
        Totem:SetID(index)
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
    local TotemsDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Totems
    local anchorFrame = unitFrame.HighLevelContainer or unitFrame

    if TotemsDB.Enabled then
        if not unitFrame.Totems then
            UUF:CreateUnitTotems(unitFrame, unit)
        end

        if unitFrame.Totems then
            for index = 1, MAX_TOTEM_SLOTS do
                local Totem = unitFrame.Totems[index]
                if Totem then
                    Totem:SetSize(TotemsDB.Size, TotemsDB.Size)
                    Totem:SetAttribute("totem-slot2", index)
                    Totem:SetID(index)
                    ApplyAuraDuration(Totem.Cooldown, unit)
                end
            end

            if not unitFrame:IsElementEnabled("Totems") then
                unitFrame:EnableElement("Totems")
            end

            unitFrame.Totems:ForceUpdate()
        end
    else
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
