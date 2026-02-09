local _, UUF = ...

local function FetchAuraDurationRegion(cooldown)
    if not cooldown then return end
    for _, region in ipairs({ cooldown:GetRegions() }) do
        if region:GetObjectType() == "FontString" then return region end
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

function UUF:CreateUnitTotems(unitFrame, unit)
    local TotemsDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Totems

    if not TotemsDB.Enabled then return end

    local Totems = {}
    local anchorFrom = TotemsDB.Layout[1]
    local anchorTo = TotemsDB.Layout[2]
    local xOffset = TotemsDB.Layout[3]
    local yOffset = TotemsDB.Layout[4]

    -- Create 4 totems but stack them all in the same position
    for index = 1, 4 do
        local Totem = CreateFrame('Button', nil, unitFrame, 'SecureActionButtonTemplate')
        UUF:QueueOrRun(function()
            Totem:SetSize(TotemsDB.Size, TotemsDB.Size)
            Totem:SetPoint(anchorFrom, unitFrame, anchorTo, xOffset, yOffset)
            Totem:SetAttribute("type2", "destroytotem")
            Totem:SetAttribute("totem-slot2", index)
        end)

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

        Totems[index] = Totem
    end

    unitFrame.Totems = Totems
end

function UUF:UpdateUnitTotems(unitFrame, unit)
    local TotemsDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Totems

    if TotemsDB.Enabled then
        if not unitFrame.Totems then
            UUF:CreateUnitTotems(unitFrame, unit)
        else
            local anchorFrom = TotemsDB.Layout[1]
            local anchorTo = TotemsDB.Layout[2]
            local xOffset = TotemsDB.Layout[3]
            local yOffset = TotemsDB.Layout[4]

            for index = 1, 4 do
                local Totem = unitFrame.Totems[index]
                UUF:QueueOrRun(function()
                    Totem:SetSize(TotemsDB.Size, TotemsDB.Size)
                    Totem:ClearAllPoints()
                    Totem:SetPoint(anchorFrom, unitFrame, anchorTo, xOffset, yOffset)
                end)
                ApplyAuraDuration(Totem.Cooldown, unit)
            end
        end

        if unitFrame.Totems then
            unitFrame:EnableElement("Totems")
            unitFrame.Totems:ForceUpdate()
        end
    else
        if unitFrame.Totems then
            unitFrame:DisableElement("Totems")
        end
    end
end