local _, UUF = ...

-- GUI Tree Layout Structure
-- Defines the hierarchical organization of settings in the sidebar

-- Ensure GUI namespace exists
UUF.GUI = UUF.GUI or {}

UUF.GUI.TreeLayout = {
    -- Units Section
    {
        id = "player",
        label = "Player",
        icon = "Interface\\Icons\\Achievement_Character_Human_Male",
        children = {
            { id = "player_frame", label = "Frame", element = "frame" },
            { id = "player_healprediction", label = "Heal Prediction", element = "healprediction" },
            { id = "player_auras", label = "Auras", element = "auras" },
            { id = "player_power", label = "Power Bar", element = "powerbar" },
            { id = "player_secondary_power", label = "Secondary Power", element = "secondarypower" },
            { id = "player_castbar", label = "Cast Bar", element = "castbar" },
            { id = "player_portrait", label = "Portrait", element = "portrait" },
            { id = "player_indicators", label = "Indicators", element = "indicators" },
            { id = "player_tags", label = "Tags", element = "tags" },
        }
    },
    {
        id = "target",
        label = "Target",
        icon = "Interface\\Icons\\Ability_Hunter_SniperShot",
        children = {
            { id = "target_frame", label = "Frame", element = "frame" },
            { id = "target_healprediction", label = "Heal Prediction", element = "healprediction" },
            { id = "target_auras", label = "Auras", element = "auras" },
            { id = "target_power", label = "Power Bar", element = "powerbar" },
            { id = "target_castbar", label = "Cast Bar", element = "castbar" },
            { id = "target_portrait", label = "Portrait", element = "portrait" },
            { id = "target_indicators", label = "Indicators", element = "indicators" },
            { id = "target_tags", label = "Tags", element = "tags" },
        }
    },
    {
        id = "targettarget",
        label = "Target of Target",
        icon = "Interface\\Icons\\Ability_Hunter_MasterMarksman",
        children = {
            { id = "targettarget_frame", label = "Frame", element = "frame" },
            { id = "targettarget_power", label = "Power Bar", element = "powerbar" },
            { id = "targettarget_indicators", label = "Indicators", element = "indicators" },
            { id = "targettarget_tags", label = "Tags", element = "tags" },
        }
    },
    {
        id = "focus",
        label = "Focus",
        icon = "Interface\\Icons\\Spell_Shadow_CurseOfTounges",
        children = {
            { id = "focus_frame", label = "Frame", element = "frame" },
            { id = "focus_auras", label = "Auras", element = "auras" },
            { id = "focus_power", label = "Power Bar", element = "powerbar" },
            { id = "focus_castbar", label = "Cast Bar", element = "castbar" },
            { id = "focus_portrait", label = "Portrait", element = "portrait" },
            { id = "focus_indicators", label = "Indicators", element = "indicators" },
            { id = "focus_tags", label = "Tags", element = "tags" },
        }
    },
    {
        id = "focustarget",
        label = "Focus Target",
        icon = "Interface\\Icons\\Spell_Shadow_Shadetruesight",
        children = {
            { id = "focustarget_frame", label = "Frame", element = "frame" },
            { id = "focustarget_power", label = "Power Bar", element = "powerbar" },
            { id = "focustarget_indicators", label = "Indicators", element = "indicators" },
            { id = "focustarget_tags", label = "Tags", element = "tags" },
        }
    },
    {
        id = "pet",
        label = "Pet",
        icon = "Interface\\Icons\\Ability_Hunter_BeastCall",
        children = {
            { id = "pet_frame", label = "Frame", element = "frame" },
            { id = "pet_power", label = "Power Bar", element = "powerbar" },
            { id = "pet_castbar", label = "Cast Bar", element = "castbar" },
            { id = "pet_indicators", label = "Indicators", element = "indicators" },
            { id = "pet_tags", label = "Tags", element = "tags" },
        }
    },
    {
        id = "party",
        label = "Party",
        icon = "Interface\\Icons\\Inv_Helmet_08",
        children = {
            { id = "party_frame", label = "Frame", element = "frame" },
            { id = "party_healprediction", label = "Heal Prediction", element = "healprediction" },
            { id = "party_auras", label = "Auras", element = "auras" },
            { id = "party_power", label = "Power Bar", element = "powerbar" },
            { id = "party_castbar", label = "Cast Bar", element = "castbar" },
            { id = "party_indicators", label = "Indicators", element = "indicators" },
            { id = "party_tags", label = "Tags", element = "tags" },
        }
    },
    {
        id = "boss",
        label = "Boss",
        icon = "Interface\\Icons\\Spell_Shadow_ShadowWordDominate",
        children = {
            { id = "boss_frame", label = "Frame", element = "frame" },
            { id = "boss_auras", label = "Auras", element = "auras" },
            { id = "boss_power", label = "Power Bar", element = "powerbar" },
            { id = "boss_alternativepower", label = "Alternative Power", element = "alternativepower" },
            { id = "boss_castbar", label = "Cast Bar", element = "castbar" },
            { id = "boss_portrait", label = "Portrait", element = "portrait" },
            { id = "boss_indicators", label = "Indicators", element = "indicators" },
            { id = "boss_tags", label = "Tags", element = "tags" },
        }
    },
    -- Separator
    { id = "separator_1", separator = true },
    -- Shared Templates
    {
        id = "templates",
        label = "Templates",
        icon = "Interface\\Icons\\INV_Misc_Book_07",
        children = {
            { id = "template_castbars", label = "All Cast Bars", template = "castbar" },
            { id = "template_powerbars", label = "All Power Bars", template = "powerbar" },
            { id = "template_healthbars", label = "All Health Bars", template = "healthbar" },
            { id = "template_auras", label = "All Auras", template = "auras" },
            { id = "template_portraits", label = "All Portraits", template = "portrait" },
        }
    },
    -- Global Settings
    {
        id = "global",
        label = "Global",
        icon = "Interface\\Icons\\INV_Misc_Gear_01",
        children = {
            { id = "global_fonts", label = "Fonts", element = "fonts" },
            { id = "global_textures", label = "Textures", element = "textures" },
            { id = "global_colors", label = "Colors", element = "colors" },
            { id = "global_range", label = "Range Fading", element = "range" },
        }
    },
    -- Tags
    {
        id = "tags_global",
        label = "Tags",
        icon = "Interface\\Icons\\INV_Inscription_Tarot",
    },
    -- Credits and Attribution
    {
        id = "credits",
        label = "Credits",
        icon = "Interface\\Icons\\Achievement_Inspect_Achievements",
    },
    -- Profiles
    {
        id = "profiles",
        label = "Profiles",
        icon = "Interface\\Icons\\INV_Misc_Note_01",
    },
}

-- Helper: Find node by ID
function UUF.GUI:FindNode(nodeId, tree)
    tree = tree or UUF.GUI.TreeLayout
    for _, node in ipairs(tree) do
        if node.id == nodeId then
            return node
        end
        if node.children then
            local found = UUF.GUI:FindNode(nodeId, node.children)
            if found then return found end
        end
    end
    return nil
end

-- Helper: Get unit from node ID
function UUF.GUI:GetUnitFromNodeId(nodeId)
    -- Collect all unit names and sort by length (longest first)
    -- This ensures "targettarget" is checked before "target"
    local unitNames = {}
    for unit in pairs(UUF.db.profile.Units) do
        table.insert(unitNames, unit)
    end
    table.sort(unitNames, function(a, b) return #a > #b end)
    
    -- Check units in descending length order
    for _, unit in ipairs(unitNames) do
        if nodeId:match("^" .. unit) then
            return unit
        end
    end
    return nil
end

-- Helper: Get element type from node
function UUF.GUI:GetElementFromNode(node)
    return node.element or node.template
end
