local _, UUF = ...
local oUF = UUF.oUF

function UUF:LayoutBossFrames()
	local FrameDB = UUF.db.profile.Units.boss.Frame
	if #UUF.BOSS_FRAMES == 0 then return end
	local bossFrames = UUF.BOSS_FRAMES
	if FrameDB.GrowthDirection == "UP" then
		bossFrames = {}
		for bossIndex = #UUF.BOSS_FRAMES, 1, -1 do bossFrames[#bossFrames + 1] = UUF.BOSS_FRAMES[bossIndex] end
	end
	local layoutConfig = UUF.LayoutConfig[FrameDB.Layout[1]]
	local frameHeight = bossFrames[1]:GetHeight()
	local containerHeight = (frameHeight + FrameDB.Layout[5]) * #bossFrames - FrameDB.Layout[5]
	local offsetY = containerHeight * layoutConfig.offsetMultiplier
	if layoutConfig.isCenter then offsetY = offsetY - (frameHeight / 2) end
	local initialAnchor = AnchorUtil.CreateAnchor(layoutConfig.anchor, UIParent, FrameDB.Layout[2], FrameDB.Layout[3], FrameDB.Layout[4] + offsetY)
	AnchorUtil.VerticalLayout(bossFrames, initialAnchor, FrameDB.Layout[5])
end

function UUF:SpawnBossFrames()
	local UnitDB = UUF.db.profile.Units.boss
	if not UnitDB or not UnitDB.Enabled then
		if UnitDB and UnitDB.ForceHideBlizzard then oUF:DisableBlizzard("boss") end
		return
	end
	local FrameDB = UnitDB.Frame

	oUF:RegisterStyle(UUF:FetchFrameName("boss"), function(unitFrame) UUF:CreateUnitFrame(unitFrame, "boss") end)
	oUF:SetActiveStyle(UUF:FetchFrameName("boss"))
	for bossIndex = 1, UUF.MAX_BOSS_FRAMES do
		local bossUnit = "boss" .. bossIndex
		local bossFrame = oUF:Spawn(bossUnit, UUF:FetchFrameName(bossUnit))
		bossFrame:SetSize(FrameDB.Width, FrameDB.Height)
		bossFrame:SetFrameStrata(FrameDB.FrameStrata)
		bossFrame:Show()
		UUF["BOSS" .. bossIndex] = bossFrame
		UUF.BOSS_FRAMES[bossIndex] = bossFrame
		UUF:RegisterTargetGlowIndicatorFrame(bossFrame, bossUnit)
		UUF:RegisterRangeFrame(bossFrame, bossUnit)
	end
	UUF:LayoutBossFrames()
	UUF:CreateMover("boss")
end

function UUF:UpdateBossFrames()
	for bossIndex, bossFrame in pairs(UUF.BOSS_FRAMES) do UUF:UpdateUnitFrame(bossFrame, "boss" .. bossIndex) end
	UUF:CreateTestBossFrames()
	UUF:LayoutBossFrames()
end
