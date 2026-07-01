local _, UUF = ...

local function RefreshMover(frameMover)
	local unitFrame = frameMover.unit == "boss" and UUF.BOSS1 or frameMover.unit == "party" and UUF.PARTY_CONTAINER or frameMover.unit == "raid" and UUF.RAID_CONTAINER or UUF[frameMover.unit:upper()]
	if not unitFrame then return end
	frameMover:ClearAllPoints()
	if frameMover.unit == "party" or frameMover.unit == "raid" then
		frameMover:SetPoint("TOPLEFT", unitFrame, "TOPLEFT")
		frameMover:SetPoint("BOTTOMRIGHT", unitFrame, "BOTTOMRIGHT")
	elseif frameMover.unit == "boss" then
		local topFrame, bottomFrame = unitFrame, unitFrame
		for _, bossFrame in pairs(UUF.BOSS_FRAMES) do
			if bossFrame:GetTop() > topFrame:GetTop() then topFrame = bossFrame end
			if bossFrame:GetBottom() < bottomFrame:GetBottom() then bottomFrame = bossFrame end
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

	local unitFrame = frameMover.unit == "boss" and UUF.BOSS1 or frameMover.unit == "party" and UUF.PARTY_CONTAINER or frameMover.unit == "raid" and UUF.RAID_CONTAINER or UUF[frameMover.unit:upper()]
	if not unitFrame then return end

	local moverX, moverY = frameMover:GetCenter()
	local FrameDB = UUF.db.profile.Units[frameMover.unit].Frame
	FrameDB.Layout[3] = FrameDB.Layout[3] + moverX - frameMover.startX
	FrameDB.Layout[4] = FrameDB.Layout[4] + moverY - frameMover.startY

	if frameMover.unit == "boss" then UUF:LayoutBossFrames() elseif frameMover.unit == "party" then UUF:LayoutPartyFrames() elseif frameMover.unit == "raid" then UUF:LayoutRaidFrames() else UUF:UpdateUnitFrame(unitFrame, frameMover.unit) end
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
	frameMover:RegisterForClicks("RightButtonUp")
	frameMover:RegisterForDrag("LeftButton")
	frameMover:SetScript("OnClick", function(_, button) if button == "RightButton" then UUF:OpenGUIToUnit(unit) end end)
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
