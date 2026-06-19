local _, UUF = ...
local oUF = UUF.oUF

function UUF:LayoutBossFrames()
	local Frame = UUF.db.profile.Units.boss.Frame
	if #UUF.BOSS_FRAMES == 0 then return end
	local bossFrames = UUF.BOSS_FRAMES
	if Frame.GrowthDirection == "UP" then
		bossFrames = {}
		for i = #UUF.BOSS_FRAMES, 1, -1 do bossFrames[#bossFrames+1] = UUF.BOSS_FRAMES[i] end
	end
	local layoutConfig = UUF.LayoutConfig[Frame.Layout[1]]
	local frameHeight = bossFrames[1]:GetHeight()
	local containerHeight = (frameHeight + Frame.Layout[5]) * #bossFrames - Frame.Layout[5]
	local offsetY = containerHeight * layoutConfig.offsetMultiplier
	if layoutConfig.isCenter then offsetY = offsetY - (frameHeight / 2) end
	local initialAnchor = AnchorUtil.CreateAnchor(layoutConfig.anchor, UIParent, Frame.Layout[2], Frame.Layout[3], Frame.Layout[4] + offsetY)
	AnchorUtil.VerticalLayout(bossFrames, initialAnchor, Frame.Layout[5])
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
	for i = 1, UUF.MAX_BOSS_FRAMES do
		UUF["BOSS" .. i] = oUF:Spawn("boss" .. i, UUF:FetchFrameName("boss" .. i))
		UUF["BOSS" .. i]:SetSize(FrameDB.Width, FrameDB.Height)
		UUF.BOSS_FRAMES[i] = UUF["BOSS" .. i]
		UUF["BOSS" .. i]:SetFrameStrata(FrameDB.FrameStrata)
		UUF:RegisterTargetGlowIndicatorFrame(UUF:FetchFrameName("boss" .. i), "boss" .. i)
		UUF:RegisterRangeFrame(UUF:FetchFrameName("boss" .. i), "boss" .. i)
		UUF["BOSS" .. i]:Show()
	end
	UUF:LayoutBossFrames()
	UUF:CreateMover("boss")
end

function UUF:UpdateBossFrames()
	for i in pairs(UUF.BOSS_FRAMES) do UUF:UpdateUnitFrame(UUF["BOSS" .. i], "boss" .. i) end
	UUF:CreateTestBossFrames()
	UUF:LayoutBossFrames()
end
