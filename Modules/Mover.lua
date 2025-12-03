local _, UUF = ...
UUF.MoversAreShown = false
local UnitToFrameName = UUF.UnitToFrameName

local unitFrameToRealName = {
    ["UUF_Player"] = "Player",
    ["UUF_Target"] = "Target",
    ["UUF_Pet"] = "Pet",
    ["UUF_Focus"] = "Focus",
    ["UUF_TargetTarget"] = "Target of Target",
    ["UUF_Boss1"] = "Boss 1",
    ["UUF_Boss2"] = "Boss 2",
    ["UUF_Boss3"] = "Boss 3",
    ["UUF_Boss4"] = "Boss 4",
    ["UUF_Boss5"] = "Boss 5",
    ["UUF_Boss6"] = "Boss 6",
    ["UUF_Boss7"] = "Boss 7",
    ["UUF_Boss8"] = "Boss 8",
    ["UUF_Boss9"] = "Boss 9",
    ["UUF_Boss10"] = "Boss 10",
}

function UUF:CreateMover(unitFrame)
    if not unitFrame or unitFrame.isMoverCreated then return end

    local unitFrameMover = CreateFrame("Frame", unitFrame:GetName() .. "_Mover", UIParent, "BackdropTemplate")
    unitFrameMover:SetSize(unitFrame:GetWidth(), unitFrame:GetHeight())
    unitFrameMover:SetPoint("CENTER", UIParent, "CENTER")
    unitFrameMover:EnableMouse(true)
    unitFrameMover:SetMovable(true)
    unitFrameMover:RegisterForDrag("LeftButton")

    unitFrameMover:SetScript("OnDragStart", function(self) self:StartMoving() end)

    unitFrameMover:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
        unitFrame:ClearAllPoints()
        unitFrame:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs)
        UUF.db.profile[unitFrame.unit].Frame.AnchorFrom = point
        UUF.db.profile[unitFrame.unit].Frame.AnchorTo = relativePoint
        UUF.db.profile[unitFrame.unit].Frame.XPosition = xOfs
        UUF.db.profile[unitFrame.unit].Frame.YPosition = yOfs
    end)

    unitFrameMover:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1, insets = {left = 1, right = 1, top = 1, bottom = 1} })
    unitFrameMover:SetBackdropColor(0, 0, 0, 0.8)
    unitFrameMover:SetBackdropBorderColor(128/255, 128/255, 255/255, 1)
    unitFrameMover:SetPoint("CENTER", unitFrame, "CENTER")
    unitFrameMover:SetFrameStrata("DIALOG")

    unitFrameMover:SetScript("OnEnter", function(self) unitFrameMover:SetBackdropBorderColor(1, 1, 1, 1) end)
    unitFrameMover:SetScript("OnLeave", function(self) unitFrameMover:SetBackdropBorderColor(128/255, 128/255, 255/255, 1) end)


    local unitFrameMoverTitle = unitFrameMover:CreateFontString(nil, "OVERLAY")
    unitFrameMoverTitle:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
    unitFrameMoverTitle:SetPoint("CENTER")
    unitFrameMoverTitle:SetText("|cFF8080FF" .. unitFrameToRealName[unitFrame:GetName()] .. "|r")

    unitFrame.unitFrameMover = unitFrameMover
    unitFrame.isMoverCreated = true

    unitFrame.unitFrameMover:Hide()
end

function UUF:ToggleMovers(isShown)
    UUF.MoversAreShown = isShown
    for unit in pairs(UnitToFrameName) do
        local frameName = UnitToFrameName[unit]
        local unitFrame = _G[frameName]
        if unitFrame and unitFrame.unitFrameMover then
            if isShown then
                unitFrame.unitFrameMover:ClearAllPoints()
                unitFrame.unitFrameMover:SetSize(unitFrame:GetWidth(), unitFrame:GetHeight())
                unitFrame.unitFrameMover:SetPoint("CENTER", unitFrame, "CENTER")
                unitFrame.unitFrameMover:Show()
            else
                unitFrame.unitFrameMover:Hide()
            end
        end
    end
end