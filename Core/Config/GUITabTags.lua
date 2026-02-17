local _, UUF = ...
local AG = UUF.AG

local GUITabTags = {}
UUF.GUITabTags = GUITabTags

function GUITabTags:BuildTagSettings(containerParent)
    local function DrawTagContainer(TagContainer, TagGroup)
        local TagsList, TagOrder = UUF:FetchTagData(TagGroup)[1], UUF:FetchTagData(TagGroup)[2]

        local SortedTagsList = {}
        for _, tag in ipairs(TagOrder) do
            if TagsList[tag] then
                SortedTagsList[tag] = TagsList[tag]
            end
        end

        for _, Tag in ipairs(TagOrder) do
            local Desc = SortedTagsList[Tag]
            local TagDesc = AG:Create("Label")
            TagDesc:SetText(Desc)
            TagDesc:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
            TagDesc:SetRelativeWidth(0.5)
            TagContainer:AddChild(TagDesc)

            local TagValue = AG:Create("EditBox")
            TagValue:SetText("[" .. Tag .. "]")
            TagValue:SetCallback("OnTextChanged", function(widget, event, value) TagValue:ClearFocus() TagValue:SetText("[" .. Tag .. "]") end)
            TagValue:SetRelativeWidth(0.5)
            TagContainer:AddChild(TagValue)
        end
    end

    local function SelectedGroup(TagContainer, _, TagGroup)
        TagContainer:ReleaseChildren()
        if TagGroup == "Health" then
            DrawTagContainer(TagContainer, "Health")
        elseif TagGroup == "Name" then
            DrawTagContainer(TagContainer, "Name")
        elseif TagGroup == "Power" then
            DrawTagContainer(TagContainer, "Power")
        elseif TagGroup == "Misc" then
            DrawTagContainer(TagContainer, "Misc")
        end
        TagContainer:DoLayout()
    end

    local GUIContainerTabGroup = AG:Create("TabGroup")
    GUIContainerTabGroup:SetLayout("Flow")
    GUIContainerTabGroup:SetTabs({
        { text = "Health", value = "Health" },
        { text = "Name", value = "Name" },
        { text = "Power", value = "Power" },
        { text = "Miscellaneous", value = "Misc" },
    })
    GUIContainerTabGroup:SetCallback("OnGroupSelected", SelectedGroup)
    GUIContainerTabGroup:SelectTab("Health")
    GUIContainerTabGroup:SetFullWidth(true)
    containerParent:AddChild(GUIContainerTabGroup)
    containerParent:DoLayout()
end

return GUITabTags
