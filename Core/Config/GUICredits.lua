local _, UUF = ...
local AG = UUF.AG

--- Credits Display Module
--- Shows proper attribution to addon and library creators

local GUICredits = {}

-- Credits data with authors and their contributions
local CREDITS_DATA = {
    {
        section = "UnhaltedUnitFrames",
        icon = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Logo.tga",
        credits = {
            { name = "Unhalted", role = "Original Creator & Main Developer" },
            { name = "DaleHuntGB", role = "Repository Maintainer & Contributor" },
        }
    },
    {
        section = "AbstractFramework",
        credits = {
            { name = "AbstractFramework Contributors", role = "Framework & UI System" },
        }
    },
    {
        section = "Ace3 Libraries",
        credits = {
            { name = "Ace3 Development Team", role = "Configuration & Database Libraries" },
        }
    },
    {
        section = "LibSharedMedia",
        credits = {
            { name = "LSM Contributors", role = "Media Registration System" },
        }
    },
    {
        section = "LibDualSpec",
        credits = {
            { name = "LibDualSpec Authors", role = "Talent Spec Detection" },
        }
    },
    {
        section = "LibDispel",
        credits = {
            { name = "LibDispel Contributors", role = "Dispel & Clean Filtering" },
        }
    },
    {
        section = "LibDeflate",
        credits = {
            { name = "LibDeflate Authors", role = "Compression Library" },
        }
    },
    {
        section = "oUF",
        credits = {
            { name = "haste & oUF Contributors", role = "Unit Frame Framework" },
        }
    },
}

--- Build credits display UI
function GUICredits:BuildCredits(container)
    -- Add title
    local titleLabel = AG:Create("Label")
    titleLabel:SetFullWidth(true)
    titleLabel:SetText("|cFFFFFFFFCredits & Attribution|r")
    container:AddChild(titleLabel)
    
    -- Add spacing
    local spacer1 = AG:Create("Label")
    spacer1:SetFullWidth(true)
    spacer1:SetText("")
    container:AddChild(spacer1)
    
    -- Display each credit section
    for _, creditBlock in ipairs(CREDITS_DATA) do
        -- Section header
        local sectionLabel = AG:Create("Label")
        sectionLabel:SetFullWidth(true)
        sectionLabel:SetText("|cFFFFCC00" .. creditBlock.section .. "|r")
        container:AddChild(sectionLabel)
        
        -- Credits for this section
        for _, credit in ipairs(creditBlock.credits) do
            local creditText = "|cFF80B0FF" .. credit.name .. "|r - " .. credit.role
            local creditLabel = AG:Create("Label")
            creditLabel:SetFullWidth(true)
            creditLabel:SetText("  " .. creditText)
            container:AddChild(creditLabel)
        end
        
        -- Spacing between sections
        local spacer = AG:Create("Label")
        spacer:SetFullWidth(true)
        spacer:SetText("")
        container:AddChild(spacer)
    end
    
    -- License footer
    local footerLabel = AG:Create("Label")
    footerLabel:SetFullWidth(true)
    footerLabel:SetText("|cFF888888Thank you to all contributors! This addon stands on the shoulders of these wonderful libraries and frameworks.|r")
    container:AddChild(footerLabel)
end

UUF.GUICredits = GUICredits
return GUICredits
