local _, UUF = ...

local function ResolveFrameName(unit)
    if not unit then return end
    if unit:match("^boss(%d+)$") then
        local unitID = unit:match("^boss(%d+)$")
        return "UUF_Boss" .. unitID
    end
    return UUF.UnitToFrameName[unit]
end

local function GetNormalizedUnit(unit)
    local normalizedUnit = unit:match("^boss%d+$") and "boss" or unit
    return normalizedUnit
end

function UUF:LayoutBossFrames()
end

local function CreateContainer(self, unit)
    if not self.Container then
        self.Container = CreateFrame("Frame", ResolveFrameName(unit) .. "_Container", self, "BackdropTemplate")
        local Container = self.Container
        Container:SetBackdrop(UUF.BackdropTemplate)
        Container:SetBackdropColor(0, 0, 0, 0)
        Container:SetBackdropBorderColor(0, 0, 0, 1)
        Container:SetAllPoints(self)
        Container:SetFrameLevel(self:GetFrameLevel() + 1)
    end
end

local function UpdateTags(self, _, unit)
    local unitToken = unit or self.unit
    if not unitToken or not UnitExists(unitToken) then return end
    if not self.TagOne or not self.TagTwo or not self.TagThree then return end
    self.TagOne:SetText(UUF:EvaluateTagString(unitToken, (UUF.db.profile[GetNormalizedUnit(unitToken)].Tags.TagOne.Tag or "")))
    self.TagTwo:SetText(UUF:EvaluateTagString(unitToken, (UUF.db.profile[GetNormalizedUnit(unitToken)].Tags.TagTwo.Tag or "")))
    self.TagThree:SetText(UUF:EvaluateTagString(unitToken, (UUF.db.profile[GetNormalizedUnit(unitToken)].Tags.TagThree.Tag or "")))
end

local function UpdateUnitHealth(self, _, unit)
    local unitToken = unit or self.unit
    if not unitToken or not UnitExists(unitToken) then return end

    local unitHP  = UnitHealth(unitToken)
    local unitMaxHP  = UnitHealthMax(unitToken)
    local unitHPMissing = UnitHealthMissing(unitToken, true)

    self.HealthBar:SetMinMaxValues(0, unitMaxHP)
    self.HealthBar:SetValue(unitHP)

    self.HealthBG:SetMinMaxValues(0, unitMaxHP)
    self.HealthBG:SetValue(unitHPMissing)
    UpdateTags(self, nil, unitToken)
end

local function CreateHealthBar(self, unit)
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local FrameDB = UUFDB[normalizedUnit].Frame
    local unitContainer = self.Container

    if not self.HealthBG then
        self.HealthBG = CreateFrame("StatusBar", ResolveFrameName(unit).."_HealthBG", self.Container)
        self.HealthBG:SetPoint("TOPLEFT", self.Container, "TOPLEFT", 1, -1)
        self.HealthBG:SetPoint("BOTTOMRIGHT", self.Container, "BOTTOMRIGHT", -1, 1)
        self.HealthBG:SetStatusBarTexture(UUF.Media.BackgroundTexture)
        self.HealthBG:SetStatusBarColor(FrameDB.BGColour[1], FrameDB.BGColour[2], FrameDB.BGColour[3], FrameDB.BGColour[4])
        self.HealthBG:SetReverseFill(true)
    end

    if not self.HealthBar then
        self.HealthBar = CreateFrame("StatusBar", ResolveFrameName(unit).."_HealthBar", self.Container)
        self.HealthBar:SetPoint("TOPLEFT", self.Container, "TOPLEFT", 1, -1)
        self.HealthBar:SetPoint("BOTTOMRIGHT", self.Container, "BOTTOMRIGHT", -1, 1)
        self.HealthBar:SetStatusBarTexture(UUF.Media.ForegroundTexture)
        self.HealthBar:SetStatusBarColor(FrameDB.FGColour[1], FrameDB.FGColour[2], FrameDB.FGColour[3], FrameDB.FGColour[4])
        self.HealthBar.unit = unit
    end

    -- Global Events
    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
    -- Unit Events
    self:RegisterUnitEvent("UNIT_HEALTH", unit)
    self:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
    -- Update
    self:SetScript("OnEvent", UpdateUnitHealth)

    if not self.HighLevelContainer then
        self.HighLevelContainer = CreateFrame("Frame", ResolveFrameName(unit) .. "_HighLevelContainer", unitContainer)
        self.HighLevelContainer:SetSize(self:GetWidth(), self:GetHeight())
        self.HighLevelContainer:SetPoint("CENTER", 0, 0)
        self.HighLevelContainer:SetFrameLevel(999)
    end
end

local function CreateTag(self, unit, tag)
    if not unit or not tag then return end
    local UUFDB = UUF.db.profile
    local normalizedUnit = GetNormalizedUnit(unit)
    local Tags = UUFDB[normalizedUnit].Tags
    local highLevelContainer = self.HighLevelContainer
    local GeneralDB = UUFDB.General
    local TagDB = Tags[tag]
    if not TagDB then return end
    if not self[tag] then
        self[tag] = highLevelContainer:CreateFontString(ResolveFrameName(unit).."_"..tag, "OVERLAY")
        self[tag]:SetFont(UUF.Media.Font, TagDB.FontSize, GeneralDB.FontFlag)
        self[tag]:SetPoint(TagDB.AnchorFrom, highLevelContainer, TagDB.AnchorTo, TagDB.OffsetX, TagDB.OffsetY)
        self[tag]:SetTextColor(TagDB.Colour[1], TagDB.Colour[2], TagDB.Colour[3], TagDB.Colour[4])
        self[tag]:SetText(UUF:EvaluateTagString(unit, (TagDB.Tag or "")))
        self[tag]:SetJustifyH(UUF:SetJustification(TagDB.AnchorFrom))
        self[tag]:SetShadowOffset(GeneralDB.FontShadows.OffsetX, GeneralDB.FontShadows.OffsetY)
        self[tag]:SetShadowColor(GeneralDB.FontShadows.Colour[1], GeneralDB.FontShadows.Colour[2], GeneralDB.FontShadows.Colour[3], GeneralDB.FontShadows.Colour[4])
    end
    self[tag].unit = unit
end

function UUF:CreateUnitFrame(unit)
    local frameName = ResolveFrameName(unit)
    if not frameName then return end
    local normalizedUnit = GetNormalizedUnit(unit)
    local unitDB = UUF.db.profile[normalizedUnit]
    local unitFrame = CreateFrame("Button", frameName, UIParent, "SecureUnitButtonTemplate,BackdropTemplate,PingableUnitFrameTemplate")

    unitFrame.unit = unit
    unitFrame:RegisterForClicks("AnyUp")
    unitFrame:SetAttribute("unit", unit)
    unitFrame:SetAttribute("*type1", "target")
    unitFrame:SetAttribute("*type2", "togglemenu")

    unitFrame:SetSize(unitDB.Frame.Width, unitDB.Frame.Height)
    unitFrame:SetPoint(unitDB.Frame.AnchorFrom, UIParent, unitDB.Frame.AnchorTo, unitDB.Frame.XOffset, unitDB.Frame.YOffset)

    RegisterUnitWatch(unitFrame)

    CreateContainer(unitFrame, unit)
    CreateHealthBar(unitFrame, unit)
    CreateTag(unitFrame, unit, "TagOne")
    CreateTag(unitFrame, unit, "TagTwo")
    CreateTag(unitFrame, unit, "TagThree")

    _G[frameName] = unitFrame
    return unitFrame
end


function UUF:UpdateUnitFrame(unit)
end

function UUF:RefreshUnitFrame(unit)
end

function UUF:FullFrameUpdate(unit)
end