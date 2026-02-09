local _, UUF = ...

local function SetRestingTexture(restingTexture)
    if not restingTexture then return end
    return UUF.StatusTextures["Resting"][restingTexture]
end

function UUF:CreateUnitRestingIndicator(unitFrame, unit)
    local RestingDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Resting
    local frameName = unitFrame:GetName() or UUF:FetchFrameName(unit)

    local Resting = unitFrame.HighLevelContainer:CreateTexture(frameName.."_RestingIndicator", "OVERLAY")
    Resting:SetSize(RestingDB.Size, RestingDB.Size)
    Resting:SetPoint(RestingDB.Layout[1], unitFrame.HighLevelContainer, RestingDB.Layout[2], RestingDB.Layout[3], RestingDB.Layout[4])

    if RestingDB.Enabled then
        unitFrame.RestingIndicator = Resting
        if RestingDB.Texture == "DEFAULT" then
            Resting:SetTexture([[Interface\CharacterFrame\UI-StateIcon]])
            Resting:SetTexCoord(0, 0.5, 0, 0.421875)
        else
            Resting:SetTexture(SetRestingTexture(RestingDB.Texture))
            Resting:SetTexCoord(0, 1, 0, 1)
        end
        if IsResting() then UUF:QueueOrRun(function() Resting:Show() end) end
    end

    return Resting
end

function UUF:UpdateUnitRestingIndicator(unitFrame, unit)
    local RestingDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Resting

    if RestingDB.Enabled then
        unitFrame.RestingIndicator = unitFrame.RestingIndicator or UUF:CreateUnitRestingIndicator(unitFrame, unit)

        if not unitFrame:IsElementEnabled("RestingIndicator") then unitFrame:EnableElement("RestingIndicator") end

        if unitFrame.RestingIndicator then
            UUF:QueueOrRun(function()
                unitFrame.RestingIndicator:ClearAllPoints()
                unitFrame.RestingIndicator:SetSize(RestingDB.Size, RestingDB.Size)
                unitFrame.RestingIndicator:SetPoint(RestingDB.Layout[1], unitFrame.HighLevelContainer, RestingDB.Layout[2], RestingDB.Layout[3], RestingDB.Layout[4])
                if RestingDB.Texture == "DEFAULT" then
                    unitFrame.RestingIndicator:SetTexture([[Interface\CharacterFrame\UI-StateIcon]])
                    unitFrame.RestingIndicator:SetTexCoord(0, 0.5, 0, 0.421875)
                else
                    unitFrame.RestingIndicator:SetTexture(SetRestingTexture(RestingDB.Texture))
                    unitFrame.RestingIndicator:SetTexCoord(0, 1, 0, 1)
                end
                if IsResting() then
                    unitFrame.RestingIndicator:Show()
                else
                    unitFrame.RestingIndicator:Hide()
                end
            end)
        end
    else
        if not unitFrame.RestingIndicator then return end
        if unitFrame:IsElementEnabled("RestingIndicator") then unitFrame:DisableElement("RestingIndicator") end
        if unitFrame.RestingIndicator then
            UUF:QueueOrRun(function() unitFrame.RestingIndicator:Hide() end)
            unitFrame.RestingIndicator = nil
        end
    end
end