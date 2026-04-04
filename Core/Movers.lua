local _, UUF = ...

local movers = {}
local moverEventFrame = CreateFrame("Frame")
local CreateMover

local MOVABLE_UNITS = {
    "player",
    "target",
    "targettarget",
    "focus",
    "focustarget",
    "pet",
    "party",
    "raid",
    "boss",
}

local UNIT_LABELS = {
    player = "Player",
    target = "Target",
    targettarget = "Target of Target",
    focus = "Focus",
    focustarget = "Focus Target",
    pet = "Pet",
    party = "Party Frames",
    raid = "Raid Frames",
    boss = "Boss Frames",
}

local RAID_DIRECTION_TO_POINT = {
    DOWN_RIGHT = "TOP",
    DOWN_LEFT = "TOP",
    UP_RIGHT = "BOTTOM",
    UP_LEFT = "BOTTOM",
    RIGHT_DOWN = "LEFT",
    RIGHT_UP = "LEFT",
    LEFT_DOWN = "RIGHT",
    LEFT_UP = "RIGHT",
}

local function RoundToTenth(value)
    return math.floor((value * 10) + 0.5) / 10
end

local function IsGroupedRaidHeadersEnabled()
    local raidDB = UUF.db and UUF.db.profile and UUF.db.profile.Units and UUF.db.profile.Units.raid
    local frameDB = raidDB and raidDB.Frame
    if not frameDB then return false end
    if frameDB.GroupBy == "CLASS" then
        frameDB.GroupBy = "GROUP"
    end
    return frameDB.GroupBy == "GROUP"
end

local function GetFilteredRaidGroupCount(frameDB)
    local seen = {}
    local count = 0
    local groupFilter = type(frameDB.GroupFilter) == "string" and strtrim(frameDB.GroupFilter) or ""

    if groupFilter ~= "" then
        for groupID in groupFilter:gmatch("%d+") do
            local groupIndex = tonumber(groupID)
            if groupIndex and groupIndex >= 1 and groupIndex <= UUF.MAX_RAID_GROUPS and not seen[groupIndex] then
                seen[groupIndex] = true
                count = count + 1
            end
        end
    end

    if count == 0 then
        count = UUF.MAX_RAID_GROUPS
    end

    return count
end

local function GetRaidGroupHeaderDimensions(frameDB)
    local direction = frameDB.GrowthDirection or "DOWN_RIGHT"
    local point = RAID_DIRECTION_TO_POINT[direction] or "TOP"
    local horizontalSpacing = frameDB.HorizontalSpacing or 0
    local verticalSpacing = frameDB.VerticalSpacing or 0

    if point == "LEFT" or point == "RIGHT" then
        return (frameDB.Width * 5) + (horizontalSpacing * 4), frameDB.Height
    end

    return frameDB.Width, (frameDB.Height * 5) + (verticalSpacing * 4)
end

local function GetBoundsFromFrames(frames)
    local left, right, top, bottom

    for _, frame in ipairs(frames) do
        if frame and frame:IsShown() then
            local frameLeft, frameRight = frame:GetLeft(), frame:GetRight()
            local frameTop, frameBottom = frame:GetTop(), frame:GetBottom()
            if frameLeft and frameRight and frameTop and frameBottom then
                left = left and math.min(left, frameLeft) or frameLeft
                right = right and math.max(right, frameRight) or frameRight
                top = top and math.max(top, frameTop) or frameTop
                bottom = bottom and math.min(bottom, frameBottom) or frameBottom
            end
        end
    end

    if not left or not right or not top or not bottom then
        return
    end

    return right - left, top - bottom
end

local function GetMoverParent(unit, unitDB)
    if unit == "player" or unit == "target" then
        return unitDB.HealthBar and unitDB.HealthBar.AnchorToCooldownViewer and _G["UUF_CDMAnchor"] or UIParent
    end

    if unit == "targettarget" or unit == "focus" or unit == "focustarget" or unit == "pet" then
        return _G[unitDB.Frame.AnchorParent] or UIParent
    end

    return UIParent
end

local function GetMoverSize(unit, unitDB)
    local frameDB = unitDB.Frame

    if unit == "party" then
        -- Always use theoretical max size so the mover covers all party slots,
        -- regardless of how many members are currently in the group.
        local spacing = frameDB.Layout[5] or 0
        return frameDB.Width, (frameDB.Height + spacing) * UUF:GetPartyFrameCount() - spacing
    end

    if unit == "boss" then
        local width, height = GetBoundsFromFrames(UUF.BOSS_FRAMES)
        if width and height then
            return width, height
        end

        local spacing = frameDB.Layout[5] or 0
        return frameDB.Width, (frameDB.Height + spacing) * UUF.MAX_BOSS_FRAMES - spacing
    end

    if unit == "raid" then
        if IsGroupedRaidHeadersEnabled() then
            -- Always use the theoretical full size (all groups × 5 members).
            -- GetBoundsFromFrames is unreliable here because SecureGroupHeaders shrinks
            -- empty group headers to near-zero, so bounds would only cover groups with members.
            local direction = frameDB.GrowthDirection or "DOWN_RIGHT"
            local maxColumns = math.max(1, math.floor(frameDB.MaxColumns or 8))
            local groupCount = GetFilteredRaidGroupCount(frameDB)
            local lineCount = math.min(groupCount, maxColumns)
            local wrapCount = math.max(1, math.ceil(groupCount / maxColumns))
            local groupWidth, groupHeight = GetRaidGroupHeaderDimensions(frameDB)
            local horizontalSpacing = frameDB.HorizontalSpacing or 0
            local verticalSpacing = frameDB.VerticalSpacing or 0

            if direction == "RIGHT_DOWN" or direction == "RIGHT_UP" or direction == "LEFT_DOWN" or direction == "LEFT_UP" then
                return (groupWidth + horizontalSpacing) * wrapCount - horizontalSpacing, (groupHeight + verticalSpacing) * lineCount - verticalSpacing
            end

            return (groupWidth + horizontalSpacing) * lineCount - horizontalSpacing, (groupHeight + verticalSpacing) * wrapCount - verticalSpacing
        end

        -- Non-grouped: calculate from the configured maxColumns × unitsPerColumn.
        local direction = frameDB.GrowthDirection or "DOWN_RIGHT"
        local point = RAID_DIRECTION_TO_POINT[direction] or "TOP"
        local maxColumns = math.max(1, math.floor(frameDB.MaxColumns or 8))
        local unitsPerColumn = math.max(1, math.floor(frameDB.UnitsPerColumn or 5))
        local horizontalSpacing = frameDB.HorizontalSpacing or 0
        local verticalSpacing = frameDB.VerticalSpacing or 0

        if point == "LEFT" or point == "RIGHT" then
            return (frameDB.Width * unitsPerColumn) + (horizontalSpacing * (unitsPerColumn - 1)),
                   (frameDB.Height * maxColumns) + (verticalSpacing * (maxColumns - 1))
        end

        return (frameDB.Width * maxColumns) + (horizontalSpacing * (maxColumns - 1)),
               (frameDB.Height * unitsPerColumn) + (verticalSpacing * (unitsPerColumn - 1))
    end

    local frame = UUF[unit:upper()]
    if frame then
        return math.max(frame:GetWidth(), frameDB.Width), math.max(frame:GetHeight(), frameDB.Height)
    end

    return frameDB.Width, frameDB.Height
end

local function ApplyUnitPosition(unit)
    if unit == "party" then
        UUF:LayoutPartyFrames()
        return
    end

    if unit == "raid" then
        UUF:LayoutRaidFrames()
        return
    end

    if unit == "boss" then
        UUF:LayoutBossFrames()
        return
    end

    local frame = UUF[unit:upper()]
    if frame then
        UUF:UpdateUnitFrame(frame, unit)
    end
end

local function RefreshMover(unit)
    local mover = movers[unit] or CreateMover(unit)
    local unitDB = UUF.db.profile.Units[unit]
    if not mover or not unitDB or not unitDB.Enabled then
        if mover then mover:Hide() end
        return
    end

    local parent = GetMoverParent(unit, unitDB)
    local frameDB = unitDB.Frame
    local width, height = GetMoverSize(unit, unitDB)

    mover:SetParent(parent)
    mover:ClearAllPoints()
    mover:SetPoint(frameDB.Layout[1], parent, frameDB.Layout[2], frameDB.Layout[3], frameDB.Layout[4])
    mover:SetSize(math.max(width or 0, 110), math.max(height or 0, 28))
    mover.Label:SetText(UNIT_LABELS[unit] or unit)
    mover:Show()
end

local function GetAnchorCoords(frame, anchorPoint)
    local left   = frame:GetLeft()   or 0
    local right  = frame:GetRight()  or GetScreenWidth()
    local top    = frame:GetTop()    or GetScreenHeight()
    local bottom = frame:GetBottom() or 0
    local cx = (left + right) / 2
    local cy = (top + bottom) / 2

    if     anchorPoint == "TOPLEFT"     then return left, top
    elseif anchorPoint == "TOP"         then return cx,   top
    elseif anchorPoint == "TOPRIGHT"    then return right, top
    elseif anchorPoint == "LEFT"        then return left, cy
    elseif anchorPoint == "CENTER"      then return cx,   cy
    elseif anchorPoint == "RIGHT"       then return right, cy
    elseif anchorPoint == "BOTTOMLEFT"  then return left, bottom
    elseif anchorPoint == "BOTTOM"      then return cx,   bottom
    elseif anchorPoint == "BOTTOMRIGHT" then return right, bottom
    end
    return left, top
end

local function SaveMoverPosition(mover, applyChanges)
    if not mover or not mover.unit then return end

    local frameDB = UUF.db.profile.Units[mover.unit] and UUF.db.profile.Units[mover.unit].Frame
    if not frameDB then return end

    -- After StopMovingOrSizing(), WoW re-anchors the frame to BOTTOMLEFT of UIParent,
    -- so GetPoint(1) no longer reflects the original Layout anchor/point. Instead we
    -- derive the offset from the mover's actual screen position.
    local moverX, moverY = GetAnchorCoords(mover, frameDB.Layout[1])
    local parent = mover:GetParent()
    local parentX, parentY = GetAnchorCoords(parent, frameDB.Layout[2])

    if not moverX then return end

    frameDB.Layout[3] = RoundToTenth(moverX - parentX)
    frameDB.Layout[4] = RoundToTenth(moverY - parentY)

    if applyChanges then
        ApplyUnitPosition(mover.unit)
    end
end

CreateMover = function(unit)
    local mover = CreateFrame("Frame", "UUF_" .. unit .. "_Mover", UIParent, "BackdropTemplate")
    mover.unit = unit
    mover:SetMovable(true)
    mover:EnableMouse(true)
    mover:RegisterForDrag("LeftButton")
    mover:SetClampedToScreen(true)
    mover:SetFrameStrata("DIALOG")
    mover:SetBackdrop(UUF.BACKDROP)
    mover:SetBackdropColor(0, 0, 0, 0.8)
    mover:SetBackdropBorderColor(128/255, 128/255, 255/255, 1.0)

    local label = mover:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetPoint("CENTER")
    label:SetJustifyH("CENTER")
    label:SetTextColor(1, 1, 1)
    mover.Label = label

    mover:SetScript("OnDragStart", function(self)
        if InCombatLockdown() then return end
        self.elapsed = 0
        self.isMoving = true
        self:StartMoving()
    end)

    mover:SetScript("OnDragStop", function(self)
        if not self.isMoving then return end
        self:StopMovingOrSizing()
        self.isMoving = nil
        SaveMoverPosition(self, true)
        RefreshMover(self.unit)
    end)

    mover:SetScript("OnHide", function(self)
        if self.isMoving then
            self:StopMovingOrSizing()
            self.isMoving = nil
        end
    end)

    mover:SetScript("OnUpdate", function(self, elapsed)
        if not self.isMoving then return end

        self.elapsed = (self.elapsed or 0) + elapsed
        if self.elapsed < 0.05 then return end

        self.elapsed = 0
        SaveMoverPosition(self, true)
    end)

    mover:Hide()
    movers[unit] = mover
    return mover
end

local function EnsureFrameExists(unit)
    local unitDB = UUF.db.profile.Units[unit]
    if not unitDB or not unitDB.Enabled then return end

    if unit == "boss" then
        if #UUF.BOSS_FRAMES == 0 then
            UUF:SpawnUnitFrame(unit)
        end
        return
    end

    if unit == "party" then
        if not UUF.PARTY then
            UUF:SpawnUnitFrame(unit)
        end
        return
    end

    if unit == "raid" then
        if not UUF.RAID and #UUF.RAID_GROUP_HEADERS == 0 then
            UUF:SpawnUnitFrame(unit)
        end
        return
    end

    if not UUF[unit:upper()] then
        UUF:SpawnUnitFrame(unit)
    end
end

local function RefreshAllMovers()
    for _, unit in ipairs(MOVABLE_UNITS) do
        EnsureFrameExists(unit)
        RefreshMover(unit)
    end
end

local function SetMoversVisible(visible)
    for _, mover in pairs(movers) do
        if visible then
            RefreshMover(mover.unit)
        else
            mover:Hide()
        end
    end
end

moverEventFrame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_REGEN_DISABLED" and UUF.MoversUnlocked then
        UUF:LockMovers(false)
    end
end)

function UUF:IsMoversUnlocked()
    return UUF.MoversUnlocked == true
end

function UUF:UnlockMovers(reopenGUIOnLock)
    if InCombatLockdown() then return end

    UUF.MoversUnlocked = true
    UUF.MoversReopenGUI = reopenGUIOnLock == true
    RefreshAllMovers()
    SetMoversVisible(true)
    moverEventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
end

function UUF:LockMovers(reopenGUI)
    if not UUF.MoversUnlocked then return end

    UUF.MoversUnlocked = false
    moverEventFrame:UnregisterEvent("PLAYER_REGEN_DISABLED")

    for _, mover in pairs(movers) do
        if mover.isMoving then
            mover:StopMovingOrSizing()
            mover.isMoving = nil
        end
        SaveMoverPosition(mover, false)
    end

    SetMoversVisible(false)
    if not InCombatLockdown() then
        UUF:UpdateAllUnitFrames()
    end

    local shouldReopenGUI = reopenGUI
    if shouldReopenGUI == nil then
        shouldReopenGUI = UUF.MoversReopenGUI
    end
    UUF.MoversReopenGUI = false

    if shouldReopenGUI and not InCombatLockdown() then
        UUF:CreateGUI()
    end
end

function UUF:ToggleMovers(reopenGUIOnLock)
    if UUF:IsMoversUnlocked() then
        UUF:LockMovers()
    else
        UUF:UnlockMovers(reopenGUIOnLock)
    end
end
