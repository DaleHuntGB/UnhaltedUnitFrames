local _, UUF = ...

local function GetTextureData(textureKey)
    if not textureKey then return nil end
    return UUF.StatusTextures["GroupRole"] and UUF.StatusTextures["GroupRole"][textureKey]
end

local function GroupRoleOverride(self, event)
    local element = self.GroupRoleIndicator
    local unit = UUF:GetNormalizedUnit(self.unit)
    
    local configUnit = unit
    if unit == "player" and UUF.db.profile.Units["party"] and UUF.db.profile.Units["party"].Indicators.GroupRole then
        configUnit = "party"
    end
    
    local unitConfig = UUF.db.profile.Units[configUnit]
    if not unitConfig then
        if element then UUF:QueueOrRun(function() element:Hide() end) end
        return
    end
    
    local GroupRoleDB = unitConfig.Indicators.GroupRole
    local texData = GetTextureData(GroupRoleDB and GroupRoleDB.Texture)
    
    local role = UnitGroupRolesAssigned(self.unit)
    if role == "TANK" or role == "HEALER" or role == "DAMAGER" then
        if texData and texData.coords and texData.coords[role] then
            element:SetTexCoord(unpack(texData.coords[role]))
        end
        UUF:QueueOrRun(function() element:Show() end)
    else
        UUF:QueueOrRun(function() element:Hide() end)
    end
end

function UUF:CreateUnitGroupRoleIndicator(unitFrame, unit)
    local GroupRoleDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.GroupRole
    local frameName = unitFrame:GetName() or UUF:FetchFrameName(unit)

    if GroupRoleDB then
        local Role = unitFrame.HighLevelContainer:CreateTexture(frameName .. "_GroupRoleIndicator", "OVERLAY")
        UUF:QueueOrRun(function()
            Role:SetSize(GroupRoleDB.Size, GroupRoleDB.Size)
            Role:SetPoint(GroupRoleDB.Layout[1], unitFrame.HighLevelContainer, GroupRoleDB.Layout[2], GroupRoleDB.Layout[3], GroupRoleDB.Layout[4])
        end)

        if GroupRoleDB.Enabled then
            unitFrame.GroupRoleIndicator = Role
            local texData = GetTextureData(GroupRoleDB.Texture)
            if texData and texData.path then
                Role:SetTexture(texData.path)
                Role.Override = GroupRoleOverride
            else
                Role.Override = nil
            end
        else
            unitFrame.GroupRoleIndicator = nil
        end
        return Role
    end
end

function UUF:UpdateUnitGroupRoleIndicator(unitFrame, unit)
    local GroupRoleDB = UUF:GetUnitIndicatorConfig(unit, "GroupRole")
    
    if not GroupRoleDB then
        if unitFrame.GroupRoleIndicator then
            unitFrame:DisableElement("GroupRoleIndicator")
        end
        return
    end

    if GroupRoleDB.Enabled then
        unitFrame.GroupRoleIndicator = unitFrame.GroupRoleIndicator or UUF:CreateUnitGroupRoleIndicator(unitFrame, unit)
        if not unitFrame:IsElementEnabled("GroupRoleIndicator") then unitFrame:EnableElement("GroupRoleIndicator") end

            if unitFrame.GroupRoleIndicator then
                local indicator = unitFrame.GroupRoleIndicator
                local texData = GetTextureData(GroupRoleDB.Texture)
                UUF:QueueOrRun(function()
                    indicator:ClearAllPoints()
                    indicator:SetSize(GroupRoleDB.Size, GroupRoleDB.Size)
                    indicator:SetPoint(GroupRoleDB.Layout[1], unitFrame.HighLevelContainer, GroupRoleDB.Layout[2], GroupRoleDB.Layout[3], GroupRoleDB.Layout[4])
                    if texData and texData.path then
                        indicator:SetTexture(texData.path)
                        indicator.Override = GroupRoleOverride
                    else
                        indicator:SetTexture(nil)
                        indicator.Override = nil
                    end
                    indicator:Show()
                    indicator:ForceUpdate()
                end)
            end
    else
        if not unitFrame.GroupRoleIndicator then return end
        if unitFrame:IsElementEnabled("GroupRoleIndicator") then unitFrame:DisableElement("GroupRoleIndicator") end
        if unitFrame.GroupRoleIndicator then
            local ind = unitFrame.GroupRoleIndicator
            UUF:QueueOrRun(function() ind:Hide() end)
            unitFrame.GroupRoleIndicator = nil
        end
    end
end