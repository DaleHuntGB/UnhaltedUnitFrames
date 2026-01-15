local _, UUF = ...
local AG = UUF.AG
UUF.GUIWidgets = {}

local function DeepDisable(widget, disabled, skipWidget)
    if widget == skipWidget then return end
    if widget.SetDisabled then widget:SetDisabled(disabled) end
    if widget.children then
        for _, child in ipairs(widget.children) do
            DeepDisable(child, disabled, skipWidget)
        end
    end
end

UUF.GUIWidgets.DeepDisable = DeepDisable

local function CreateInformationTag(containerParent, labelDescription, textJustification)
    local informationLabel = AG:Create("Label")
    informationLabel:SetText(UUF.INFOBUTTON .. labelDescription)
    informationLabel:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    informationLabel:SetFullWidth(true)
    informationLabel:SetJustifyH(textJustification or "CENTER")
    informationLabel:SetHeight(24)
    informationLabel:SetJustifyV("MIDDLE")
    containerParent:AddChild(informationLabel)
    return informationLabel
end

UUF.GUIWidgets.CreateInformationTag = CreateInformationTag

local function CreateScrollFrame(containerParent)
    local scrollFrame = AG:Create("ScrollFrame")
    scrollFrame:SetLayout("Flow")
    scrollFrame:SetFullWidth(true)
    containerParent:AddChild(scrollFrame)
    return scrollFrame
end

UUF.GUIWidgets.CreateScrollFrame = CreateScrollFrame

local function CreateInlineGroup(containerParent, containerTitle)
    local inlineGroup = AG:Create("InlineGroup")
    inlineGroup:SetTitle("|cFFFFFFFF" .. containerTitle .. "|r")
    inlineGroup:SetFullWidth(true)
    inlineGroup:SetLayout("Flow")
    containerParent:AddChild(inlineGroup)
    return inlineGroup
end

UUF.GUIWidgets.CreateInlineGroup = CreateInlineGroup

local function CreateHeader(containerParent, headerTitle)
    local headingText = AG:Create("Heading")
    headingText:SetText("|cFFFFCC00" .. headerTitle .. "|r")
    headingText:SetFullWidth(true)
    containerParent:AddChild(headingText)
    return headingText
end

UUF.GUIWidgets.CreateHeader = CreateHeader