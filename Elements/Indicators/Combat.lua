local _, UUF = ...

local function SetCombatTexture(combatTexture)
    if not combatTexture then return end
    return UUF.StatusTextures["Combat"][combatTexture]
end

function UUF:CreateUnitCombatIndicator(unitFrame, unit)
    local CombatDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Combat
    local frameName = unitFrame:GetName() or UUF:FetchFrameName(unit)

    local Combat = unitFrame.HighLevelContainer:CreateTexture(frameName..".._CombatIndicator", "OVERLAY")
    Combat:SetSize(CombatDB.Size, CombatDB.Size)
    Combat:SetPoint(CombatDB.Layout[1], unitFrame.HighLevelContainer, CombatDB.Layout[2], CombatDB.Layout[3], CombatDB.Layout[4])

    if CombatDB.Enabled then
        unitFrame.CombatIndicator = Combat
        if CombatDB.Texture == "DEFAULT" then
            Combat:SetTexture([[Interface\CharacterFrame\UI-StateIcon]])
            Combat:SetTexCoord(0.5, 1, 0, 0.49)
        else
            Combat:SetTexture(SetCombatTexture(CombatDB.Texture))
            Combat:SetTexCoord(0, 1, 0, 1)
        end
        if UnitAffectingCombat(unitFrame.unit) then UUF:QueueOrRun(function() Combat:Show() end) end
    end

    return Combat
end

function UUF:UpdateUnitCombatIndicator(unitFrame, unit)
    local CombatDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Combat

    if CombatDB.Enabled then
        unitFrame.CombatIndicator = unitFrame.CombatIndicator or UUF:CreateUnitCombatIndicator(unitFrame, unit)

        if not unitFrame:IsElementEnabled("CombatIndicator") then unitFrame:EnableElement("CombatIndicator") end

        if unitFrame.CombatIndicator then
            UUF:QueueOrRun(function()
                unitFrame.CombatIndicator:ClearAllPoints()
                unitFrame.CombatIndicator:SetSize(CombatDB.Size, CombatDB.Size)
                unitFrame.CombatIndicator:SetPoint(CombatDB.Layout[1], unitFrame.HighLevelContainer, CombatDB.Layout[2], CombatDB.Layout[3], CombatDB.Layout[4])
                if CombatDB.Texture == "DEFAULT" then
                    unitFrame.CombatIndicator:SetTexture([[Interface\CharacterFrame\UI-StateIcon]])
                    unitFrame.CombatIndicator:SetTexCoord(0.5, 1, 0, 0.49)
                else
                    unitFrame.CombatIndicator:SetTexture(SetCombatTexture(CombatDB.Texture))
                    unitFrame.CombatIndicator:SetTexCoord(0, 1, 0, 1)
                end
                if UnitAffectingCombat(unitFrame.unit) then
                    unitFrame.CombatIndicator:Show()
                else
                    unitFrame.CombatIndicator:Hide()
                end
            end)
        end
    else
        if not unitFrame.CombatIndicator then return end
        if unitFrame:IsElementEnabled("CombatIndicator") then unitFrame:DisableElement("CombatIndicator") end
        if unitFrame.CombatIndicator then
            UUF:QueueOrRun(function() unitFrame.CombatIndicator:Hide() end)
            unitFrame.CombatIndicator = nil
        end
    end
end