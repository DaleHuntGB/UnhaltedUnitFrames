local _, UUF = ...
local oUF = UUF.oUF

local function GetNormalizedUnit(unit, parent)
    if not unit then return nil end

    if unit:match("^boss%d+$") then
        return "boss"
    elseif unit:match("^party%d+$") then
        return "party"
    elseif unit:match("^raid%d+$") then
        return "raid"
    elseif unit == "player" and parent then
        local parentName = type(parent) == "string" and parent or parent:GetName()
        if parentName:find("Party") then
            return "party"
        elseif parentName:find("Raid") then
            return "raid"
        end
    end

    return unit
end

function UUF:FormatLargeNumber(amount)
    local decimalPoint = UUF.DP
    if amount >= 1e9 then
        return string.format("%." .. decimalPoint .. "fB", amount / 1e9)
    elseif amount >= 1e6 then
        return string.format("%." .. decimalPoint .. "fM", amount / 1e6)
    elseif amount >= 1e3 then
        return string.format("%." .. decimalPoint .. "fK", amount / 1e3)
    else
        return tostring(amount)
    end
end

function UUF:FormatPercent(amount)
    local decimalPoint = UUF.DP
    return string.format("%." .. decimalPoint .. "f%%", amount)
end

function UUF:ShortenText(fontString, maxLength)
    if not fontString or not maxLength then return end
    local text = fontString:GetText() or ""
    if text == "" then return end

    if #text > maxLength then
        fontString:SetText(text:sub(1, maxLength) .. "…")
    else
        fontString:SetText(text)
    end
end

function UUF:StyleAuras(_, button, unit, auraType)
    if not button or not unit or not auraType then return end
    local UUFDB = UUF.db.profile
    local General = UUFDB.General
    local normalizedUnit = GetNormalizedUnit(unit)
    local UnitDB = UUFDB[normalizedUnit]
    if not UnitDB then return end
    local Buffs = UnitDB.Buffs
    local Debuffs = UnitDB.Debuffs

    local auraIcon = button.Icon
    if auraIcon then
        auraIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    end

    local buttonBorder = CreateFrame("Frame", nil, button, "BackdropTemplate")
    buttonBorder:SetAllPoints()
    buttonBorder:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1, insets = {left = 0, right = 0, top = 0, bottom = 0} })
    buttonBorder:SetBackdropBorderColor(0, 0, 0, 1)

    local auraCooldown = button.Cooldown
    if auraCooldown then
        auraCooldown:SetDrawEdge(false)
        auraCooldown:SetReverse(true)
    end

    local auraStacks = button.Count
    if auraStacks then
        if auraType == "HELPFUL" then
            auraStacks:ClearAllPoints()
            auraStacks:SetFont(UUF.Media.Font, Buffs.Count.FontSize, General.FontFlag)
            auraStacks:SetPoint(Buffs.Count.AnchorFrom, button, Buffs.Count.AnchorTo, Buffs.Count.OffsetX, Buffs.Count.OffsetY)
            auraStacks:SetTextColor(unpack(Buffs.Count.Colour))
        elseif auraType == "HARMFUL" then
            auraStacks:ClearAllPoints()
            auraStacks:SetFont(UUF.Media.Font, Debuffs.Count.FontSize, General.FontFlag)
            auraStacks:SetPoint(Debuffs.Count.AnchorFrom, button, Debuffs.Count.AnchorTo, Debuffs.Count.OffsetX, Debuffs.Count.OffsetY)
            auraStacks:SetTextColor(unpack(Debuffs.Count.Colour))
        end
    end
end

function UUF:RestyleAuras(_, button, unit, auraType)
    if not button or not unit or not auraType then return end
    local UUFDB = UUF.db.profile
    local General = UUFDB.General
    local normalizedUnit = GetNormalizedUnit(unit)
    local UnitDB = UUFDB[normalizedUnit]
    if not UnitDB then return end
    local Buffs = UnitDB.Buffs
    local Debuffs = UnitDB.Debuffs

    local auraIcon = button.Icon
    if auraIcon then
        auraIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    end

    local auraCooldown = button.Cooldown
    if auraCooldown then
        auraCooldown:SetDrawEdge(false)
        auraCooldown:SetReverse(true)
    end

    local auraStacks = button.Count
    if auraStacks then
        if auraType == "HELPFUL" then
            auraStacks:ClearAllPoints()
            auraStacks:SetFont(UUF.Media.Font, Buffs.Count.FontSize, General.FontFlag)
            auraStacks:SetPoint(Buffs.Count.AnchorFrom, button, Buffs.Count.AnchorTo, Buffs.Count.OffsetX, Buffs.Count.OffsetY)
            auraStacks:SetTextColor(unpack(Buffs.Count.Colour))
        elseif auraType == "HARMFUL" then
            auraStacks:ClearAllPoints()
            auraStacks:SetFont(UUF.Media.Font, Debuffs.Count.FontSize, General.FontFlag)
            auraStacks:SetPoint(Debuffs.Count.AnchorFrom, button, Debuffs.Count.AnchorTo, Debuffs.Count.OffsetX, Debuffs.Count.OffsetY)
            auraStacks:SetTextColor(unpack(Debuffs.Count.Colour))
        end
    end
end

function UUF:FilterAuras(auraType)
	local whitelistCache = UUF.db.profile.Filters.Whitelist[auraType] or {}
	local blacklistCache = UUF.db.profile.Filters.Blacklist[auraType] or {}
	local unitsToFilter = UUF.db.profile.Filters.FilterUnits
	local filterByWhitelist = next(whitelistCache) ~= nil

	return function(element, unit, data)
		-- if element.onlyShowPlayer and not data.isPlayerAura then return false end
		-- if auraType == "Debuffs" and filterByWhitelist and not data.isPlayerAura then return false end
        local normalizedUnit = GetNormalizedUnit(unit, self.Party)
		if not normalizedUnit or not unitsToFilter[normalizedUnit] then return true end
		local auraID = data.spellId
		if filterByWhitelist then return whitelistCache[auraID] == true end

		if blacklistCache[auraID] then return false end
		return true
	end
end

function UUF:WrapTextInColor(unitName, unit)
    if not unitName then return "" end
    if not unit then return unitName end
    local unitColor;
    if UnitIsPlayer(unit) then
        local unitClass = select(2, UnitClass(unit))
        unitColor = RAID_CLASS_COLORS[unitClass]
    else
        local reaction = UnitReaction(unit, "player")
        if reaction then
            local r, g, b = unpack(oUF.colors.reaction[reaction])
            unitColor = { r = r, g = g, b = b }
        end
    end
    if unitColor then
        return string.format("|cff%02x%02x%02x%s|r", unitColor.r * 255, unitColor.g * 255, unitColor.b * 255, unitName)
    else
        return unitName
    end
end

function UUF:SubChar(text, startChar, endChar)
    if not text then return "" end
    local startIndex, endIndex = 1, #text
    local currentIndex, currentChar = 1, 0

    while currentIndex <= #text do
        currentChar = currentChar + 1
        if currentChar == startChar then
            startIndex = currentIndex
        end

        local c = string.byte(text, currentIndex)
        if not c then break end
        local charLen = (c >= 240 and 4) or (c >= 224 and 3) or (c >= 192 and 2) or 1
        currentIndex = currentIndex + charLen

        if currentChar == endChar then
            endIndex = currentIndex - 1
            break
        end
    end

    return string.sub(text, startIndex, endIndex)
end

function UUF:TitleCase(text)
    if type(text) ~= "string" or text == "" then return text end
    local textLength = #text
    local textRepeatPosition = (text..text):find(text, 2, true)
    local didRepeatSplit = false
    if textRepeatPosition and textRepeatPosition <= textLength then
        local textRepeatIndex = textRepeatPosition - 1
        if textRepeatIndex > 0 and textLength / textRepeatIndex == math.floor(textLength / textRepeatIndex) then
            local segment = text:sub(1, textRepeatIndex)
            local repeats = textLength / textRepeatIndex
            local parts = {}
            for i = 1, repeats do parts[i] = segment end
            text = table.concat(parts, " ")
            didRepeatSplit = true
        end
    end
    if not didRepeatSplit then
        local targetCount = 0
        while text:sub(-6) == "target" do
            text = text:sub(1, -7)
            targetCount = targetCount + 1
        end
        if targetCount > 0 then
            local parts = {}
            if text ~= "" then parts[#parts + 1] = text end
            for i = 1, targetCount do parts[#parts + 1] = "target" end
            text = table.concat(parts, " ")
        end
    end
    return (text:gsub("(%S)(%S*)", function(first, rest) return first:upper()..rest:lower() end))
end

function UUF:Print(msg)
    print("|cFF8080FFUnhalted|r Unit Frames" .. ": " .. msg)
end

function UUF:SetTextJustification(AnchorTo)
    if AnchorTo == "TOPLEFT" or AnchorTo == "BOTTOMLEFT" or AnchorTo == "LEFT" then return "LEFT" end
    if AnchorTo == "TOPRIGHT" or AnchorTo == "BOTTOMRIGHT" or AnchorTo == "RIGHT" then return "RIGHT" end
    if AnchorTo == "TOP" or AnchorTo == "BOTTOM" or AnchorTo == "CENTER" then return "CENTER" end
end

function UUF:ResolveMedia()
    local LSM = LibStub("LibSharedMedia-3.0")
    local General = UUF.db.profile.General
    UUF.Media = UUF.Media or {}

    UUF.Media.Font = LSM:Fetch("font", General.Font) or STANDARD_TEXT_FONT
    UUF.Media.ForegroundTexture = LSM:Fetch("statusbar", General.ForegroundTexture) or "Interface\\RaidFrame\\Raid-Bar-Hp-Fill"
    UUF.Media.BackgroundTexture = LSM:Fetch("statusbar", General.BackgroundTexture) or "Interface\\Buttons\\WHITE8X8"
end

function UUF:CreatePrompt(title, text, onAccept, onCancel, acceptText, cancelText)
    StaticPopupDialogs["UUF_PROMPT_DIALOG"] = {
        text = text or "",
        button1 = acceptText or ACCEPT,
        button2 = cancelText or CANCEL,
        OnAccept = function(self, data)
            if data and data.onAccept then
                data.onAccept()
            end
        end,
        OnCancel = function(self, data)
            if data and data.onCancel then
                data.onCancel()
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
        showAlert = true,
    }
    local promptDialog = StaticPopup_Show("UUF_PROMPT_DIALOG", title, text)
    if promptDialog then
        promptDialog.data = { onAccept = onAccept, onCancel = onCancel }
        promptDialog:SetFrameStrata("TOOLTIP")
    end
    return promptDialog
end

local function SetupSlashCommands()
    SLASH_UUF1 = "/uuf"
    SlashCmdList["UUF"] = function(msg)
        UUF:CreateGUI()
    end
end

local function LoadCustomColours()
    local General = UUF.db.profile.General
    local PowerTypesToString = {
        [0] = "MANA",
        [1] = "RAGE",
        [2] = "FOCUS",
        [3] = "ENERGY",
        [6] = "RUNIC_POWER",
        [8] = "LUNAR_POWER",
        [11] = "MAELSTROM",
        [13] = "INSANITY",
        [17] = "FURY",
        [18] = "PAIN"
    }

    for powerType, color in pairs(General.CustomColours.Power) do
        local powerTypeString = PowerTypesToString[powerType]
        if powerTypeString then
            oUF.colors.power[powerTypeString] = color
        end
    end

    for reaction, color in pairs(General.CustomColours.Reaction) do
        oUF.colors.reaction[reaction] = color
    end

    -- oUF.colors.health = { General.ForegroundColour[1], General.ForegroundColour[2], General.ForegroundColour[3] }
    -- oUF.colors.tapped = { General.CustomColours.Status[2][1], General.CustomColours.Status[2][2], General.CustomColours.Status[2][3] }
    -- oUF.colors.disconnected = { General.CustomColours.Status[3][1], General.CustomColours.Status[3][2], General.CustomColours.Status[3][3] }

    for _, obj in next, oUF.objects do
        if obj.UpdateTags then
            obj:UpdateTags()
        end
    end
end

local function SetTagUpdateInterval()
    oUF.Tags:SetEventUpdateTimer(UUF.TagInterval)
end

function UUF:Init()
    SetupSlashCommands()
    LoadCustomColours()
    SetTagUpdateInterval()
end

local ImportantBuffs = {
    -- Defensives
    [403876]  = true,  -- Divine Protection
    [642]     = true,  -- Divine Shield
    [363916]  = true,  -- Obsidian Scales
    [374348]  = true,  -- Renewing Blaze
    [586]     = true,  -- Fade
    [19236]   = true,  -- Desperate Prayer
    [193065]  = true,  -- Protective Light
    [31850]   = true,  -- Ardent Defender
    [86659]   = true,  -- Guardian of Ancient Kings
    [1966]    = true,  -- Feint
    [31224]   = true,  -- Cloak of Shadows
    [196555]  = true,  -- Netherwalk
    [120954]  = true,  -- Fortifying Brew
    [122783]  = true,  -- Diffuse Magic
    [186265]  = true,  -- Aspect of the Turtle
    [264735]  = true,  -- Survival of the Fittest
    [22812]   = true,  -- Barskin
    [61336]   = true,  -- Survival Instincts
    [22842]   = true,  -- Frenzied Regeneration
    [108271]  = true,  -- Astral Shift
    [48792]   = true,  -- Icebound Fortitude
    [49039]   = true,  -- Lichborne
    [55233]   = true,  -- Vampiric Blood
    [104773]  = true,  -- Unending Resolve
    [212800]  = true,  -- Blur
    [23920]   = true,  -- Spell Reflection
    [118038]  = true,  -- Die by the Sword
    [871]     = true,  -- Shield Wall
    [47585]   = true,  -- Dispersion
    [5277]    = true,  -- Evasion
    [472708]  = true,  -- Shell Cover
    [388035]  = true,  -- Fortitude of the Bear
    [184364]  = true,  -- Enraged Regeneration
    [212641]  = true,  -- Guardian of Ancient Kings
    [414658]  = true,  -- Ice Cold
    [113862]  = true,  -- Greater Invisibility
    [194679]  = true,  -- Rune Tap
    [65116]   = true,  -- Stoneform
    [459470]  = true,  -- Ghillie Suit
    [498]     = true,  -- Divine Protection
    [432181]  = true,  -- Dance of the Wind
    [260881]  = true,  -- Spirit Wolf
    [386237]  = true,  -- Fade to Nothing
    [122278]  = true,  -- Dampen Harm
    -- Absorbs
    [184662]  = true,  -- Shield of Vengeance
    [116849]  = true,  -- Life Cocoon
    [235313]  = true,  -- Blazing Barrier
    [11426]   = true,  -- Ice Barrier
    [235450]  = true,  -- Prismatic Barrier
    [370889]  = true,  -- Twin Guardian
    [17]      = true,  -- Power Word: Shield
    [209388]  = true,  -- Premonition of Solace
    [322507]  = true,  -- Bulwark of Order
    [114893]  = true,  -- Celestial Brew
    [462844]  = true,  -- Stone Bulwalk
    [48707]   = true,  -- Stone Bulwalk
    [219809]  = true,  -- Anti-Magic Shell
    [108416]  = true,  -- Tombstone
    [190456]  = true,  -- Dark Pact
    [373862]  = true,  -- Ignore Pain
    [263648]  = true,  -- Temporal Anomaly
    [372505]  = true,  -- Soul Barrier
    [442788]  = true,  -- Ursoc's Fury
    [432607]  = true,  -- Incorruptible Spirit
    [421453]  = true,  -- Holy Bulwark
    [271466]  = true,  -- Ultimate Penitence
    [1236993] = true,  -- Luminous Barrier
    [414663]  = true,  -- Energy Shield
    [414662]  = true,  -- Prismatic Barrier
    [414661]  = true,  -- Blazing Barrier
    [337299]  = true,  -- Ice Barrier
    [77535]   = true,  -- Tempest Barrier
    [391527]  = true,  -- Blood Shield
    [457387]  = true,  -- Umbillicus Eternus
    [443526]  = true,  -- Wind Barrier
    [395180]  = true,  -- Premonition of Solace
    [451447]  = true,  -- Barrier of Faith
    [1239002] = true,  -- Don't Look Back
    [393899]  = true,  -- Lesser Bulwark
    [1217103] = true,  -- Moment of Glory
    [1223453] = true,  -- Ethereal Reconstitution
    [1241059] = true,  -- Celestial Infusion
    [1223612] = true,  -- Ethereal Barrier
    [1223614] = true,  -- Ethereal Barricade
    -- Raid
    [145629]  = true,  -- Anti-Magic Zone
    [325174]  = true,  -- Spirit Link Totem
    [97463]   = true,  -- Rallying Cry
    [196718]  = true,  -- Darkness
    [374227]  = true,  -- Zephyr
    [81782]   = true,  -- Power Word: Barrier
    [209426]  = true,  -- Darkness
    [62618]   = true,  -- Power Word: Barrier
    -- External
    [1022]   = true,  -- Blessing of Protection
    [6940]   = true,  -- Blessing of Sacrifice
    [47788]  = true,  -- Guardian Spirit
    [102342] = true,  -- Ironbark
    [197061] = true,  -- Stonebark
    [392116] = true,  -- Regenerative Heartwood
    [33206]  = true,  -- Pain Suppression
    [440738] = true,  -- Foreseen Circumstances
    [204018] = true,  -- Blessing of Spellwarding
    [357170] = true,  -- Time Dilation
    [1044]   = true,  -- Blessing of Freedom
}

function UUF:FetchImportantBuffs()
    return ImportantBuffs
end

local DebuffBlacklist = {
    [57723]     = true, -- Exhaustion
    [390435]    = true, -- Exhaustion
    [264689]    = true, -- Fatigued
    [57724]     = true, -- Sated
    [95809]     = true, -- Sated
    [206151]    = true, -- Challenger's Burden
    [113942]    = true, -- Demonic Gateway
}

local BuffBlacklist = {
    [440837]    = true, -- Fury of Xuen
    [440839]    = true, -- Kindness of Chi-Ji
    [440836]    = true, -- Essence of Yu'lon
    [440838]    = true, -- Fortitude of Niuzao
    [415603]    = true, -- Encapsulated Destiny
    [404468]    = true, -- Flight Style: Steady
    [404464]    = true, -- Flight Style: Skyriding
    [341770]    = true, -- Accursed
    [245686]    = true, -- Fashionable!
}

function UUF:FetchDebuffBlacklist()
    return DebuffBlacklist
end

function UUF:FetchBuffBlacklist()
    return BuffBlacklist
end