local _, UUF = ...

local function RefreshMover(frameMover)
	local unitFrame = frameMover.unit == "boss" and UUF.BOSS1 or frameMover.unit == "party" and UUF.PARTY_FRAMES[1] or UUF[frameMover.unit:upper()]
	if not unitFrame then return end
	frameMover:ClearAllPoints()
	if frameMover.unit == "boss" or frameMover.unit == "party" then
		local topFrame, bottomFrame = unitFrame, unitFrame
		local frames = frameMover.unit == "boss" and UUF.BOSS_FRAMES or UUF.PARTY_FRAMES
		for _, groupFrame in pairs(frames) do
			if groupFrame:GetTop() and topFrame:GetTop() and groupFrame:GetTop() > topFrame:GetTop() then topFrame = groupFrame end
			if groupFrame:GetBottom() and bottomFrame:GetBottom() and groupFrame:GetBottom() < bottomFrame:GetBottom() then bottomFrame = groupFrame end
		end
		frameMover:SetPoint("TOPLEFT", topFrame, "TOPLEFT")
		frameMover:SetPoint("BOTTOMRIGHT", bottomFrame, "BOTTOMRIGHT")
	else
		frameMover:SetPoint("TOPLEFT", unitFrame, "TOPLEFT")
		frameMover:SetPoint("BOTTOMRIGHT", unitFrame, "BOTTOMRIGHT")
	end
end

local function StopMoving(frameMover)
	frameMover:StopMovingOrSizing()

	local unitFrame = frameMover.unit == "boss" and UUF.BOSS1 or frameMover.unit == "party" and UUF.PARTY_FRAMES[1] or UUF[frameMover.unit:upper()]
	if not unitFrame then return end

	local moverX, moverY = frameMover:GetCenter()
	local FrameDB = UUF.db.profile.Units[frameMover.unit].Frame
	FrameDB.Layout[3] = FrameDB.Layout[3] + moverX - frameMover.startX
	FrameDB.Layout[4] = FrameDB.Layout[4] + moverY - frameMover.startY

	if frameMover.unit == "boss" then UUF:LayoutBossFrames() elseif frameMover.unit == "party" then UUF:LayoutPartyFrames() else UUF:UpdateUnitFrame(unitFrame, frameMover.unit) end
	RefreshMover(frameMover)
end

function UUF:CreateMover(unit)
	UUF.MOVERS = UUF.MOVERS or {}
	if UUF.MOVERS[unit] then return end

	local frameMover = CreateFrame("Button", "UUF_" .. unit .. "Mover", UIParent, "BackdropTemplate")
	frameMover.unit = unit
	frameMover:SetBackdrop(UUF.BACKDROP)
	frameMover:SetBackdropColor(81/255, 81/255, 163/255, 0.8)
	frameMover:SetBackdropBorderColor(0, 0, 0, 1)
	frameMover:SetFrameStrata("TOOLTIP")
	frameMover:SetClampedToScreen(true)
	frameMover:SetMovable(true)
	frameMover:RegisterForDrag("LeftButton")
	frameMover:SetScript("OnDragStart", function() if not InCombatLockdown() then frameMover.startX, frameMover.startY = frameMover:GetCenter() frameMover:StartMoving() end end)
	frameMover:SetScript("OnDragStop", function() if InCombatLockdown() then frameMover:StopMovingOrSizing() RefreshMover(frameMover) else StopMoving(frameMover) end end)
	frameMover:SetScript("OnShow", RefreshMover)

	frameMover.Text = frameMover:CreateFontString(nil, "OVERLAY")
	frameMover.Text:SetPoint("CENTER")
	frameMover.Text:SetFont(UUF.Media.Font, 12, "OUTLINE, SLUG")
	frameMover.Text:SetText(unit == "targettarget" and "Target of Target" or unit == "focustarget" and "Focus Target" or unit:gsub("^%l", string.upper))
	frameMover.Text:SetTextColor(255/255, 255/255, 255/255, 1)

	UUF.MOVERS[unit] = frameMover
	frameMover:Hide()
end

function UUF:ToggleMovers()
	if InCombatLockdown() then UUF:PrettyPrint("Movers cannot be toggled while in combat.") return UUF.MOVERS_UNLOCKED end
	UUF.MOVERS_UNLOCKED = not UUF.MOVERS_UNLOCKED
	for _, mover in pairs(UUF.MOVERS or {}) do mover:SetShown(UUF.MOVERS_UNLOCKED) end
	return UUF.MOVERS_UNLOCKED
end

function UUF:CreatePositionController()
    local ECDM = ""

    if C_AddOns.IsAddOnLoaded("SkironCooldownManager") then
        ECDM = _G["SCM_GroupAnchor_1"]
    else
        ECDM = _G["EssentialCooldownViewer"]
    end

    if ECDM and ECDM:IsShown() then
        local CDMAnchor = CreateFrame("Frame", "UUF_CDMAnchor", UIParent)
        CDMAnchor:SetAllPoints(ECDM)
        CDMAnchor:SetSize(ECDM:GetWidth() or 300, ECDM:GetHeight() or 48)
    else
        UUF:PrettyPrint("|cFF8080FFEssential Cooldown Viewer|r was not found.")
    end
end

function UUF:IsCDMAnchorActive()
    local ECDM = ""

    if C_AddOns.IsAddOnLoaded("SkironCooldownManager") then
        ECDM = _G["SCM_GroupAnchor_1"]
    else
        ECDM = _G["EssentialCooldownViewer"]
    end
    local CDMAnchor = _G["UUF_CDMAnchor"]
    return  ECDM and ECDM:IsShown() and CDMAnchor and CDMAnchor:IsShown()
end
