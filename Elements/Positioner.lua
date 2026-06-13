local _, UUF = ...

local function RefreshMover(mover)
	local unitFrame = mover.unit == "boss" and UUF.BOSS1 or UUF[mover.unit:upper()]
	if not unitFrame then return end
	mover:ClearAllPoints()
	if mover.unit == "boss" then
		local topFrame, bottomFrame = unitFrame, unitFrame
		for _, bossFrame in pairs(UUF.BOSS_FRAMES) do
			if bossFrame:GetTop() > topFrame:GetTop() then topFrame = bossFrame end
			if bossFrame:GetBottom() < bottomFrame:GetBottom() then bottomFrame = bossFrame end
		end
		mover:SetPoint("TOPLEFT", topFrame, "TOPLEFT")
		mover:SetPoint("BOTTOMRIGHT", bottomFrame, "BOTTOMRIGHT")
	else
		mover:SetPoint("TOPLEFT", unitFrame, "TOPLEFT")
		mover:SetPoint("BOTTOMRIGHT", unitFrame, "BOTTOMRIGHT")
	end
end

local function StopMoving(mover)
	mover:StopMovingOrSizing()

	local unitFrame = mover.unit == "boss" and UUF.BOSS1 or UUF[mover.unit:upper()]
	if not unitFrame then return end

	local moverX, moverY = mover:GetCenter()
	local FrameDB = UUF.db.profile.Units[mover.unit].Frame
	FrameDB.Layout[3] = FrameDB.Layout[3] + moverX - mover.startX
	FrameDB.Layout[4] = FrameDB.Layout[4] + moverY - mover.startY

	if mover.unit == "boss" then UUF:LayoutBossFrames() else UUF:UpdateUnitFrame(unitFrame, mover.unit) end
	RefreshMover(mover)
end

function UUF:CreateMover(unit)
	UUF.MOVERS = UUF.MOVERS or {}
	if UUF.MOVERS[unit] then return end

	local mover = CreateFrame("Button", "UUF_" .. unit .. "Mover", UIParent, "BackdropTemplate")
	mover.unit = unit
	mover:SetBackdrop(UUF.BACKDROP)
	mover:SetBackdropColor(128/255, 128/255, 255/255, 0.75)
	mover:SetBackdropBorderColor(0, 0, 0, 1)
	mover:SetFrameStrata("TOOLTIP")
	mover:SetClampedToScreen(true)
	mover:SetMovable(true)
	mover:RegisterForDrag("LeftButton")
	mover:SetScript("OnDragStart", function(self) if not InCombatLockdown() then self.startX, self.startY = self:GetCenter() self:StartMoving() end end)
	mover:SetScript("OnDragStop", function(self) if InCombatLockdown() then self:StopMovingOrSizing() RefreshMover(self) else StopMoving(self) end end)
	mover:SetScript("OnShow", RefreshMover)

	local text = mover:CreateFontString(nil, "OVERLAY")
	text:SetPoint("CENTER")
	text:SetFont(UUF.Media.Font, 12, "OUTLINE")
	text:SetText(UUF:Capitalize(unit == "targettarget" and "Target of Target" or unit == "focustarget" and "Focus Target" or unit))

	UUF.MOVERS[unit] = mover
	mover:Hide()
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
        UUF:PrettyPrint("|cFFFFCC00Essential Cooldown Viewer|r was not found.")
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
