local _, UUF = ...
local Serialize = LibStub:GetLibrary("AceSerializer-3.0")
local Compress = LibStub:GetLibrary("LibDeflate")

function UUF:ExportSavedVariables()
    local profileData = {
        global = UUF.DB.global,
        profile = UUF.DB.profile,
    }
    local SerializedInfo = Serialize:Serialize(profileData)
    local CompressedInfo = Compress:CompressDeflate(SerializedInfo)
    local EncodedInfo = Compress:EncodeForPrint(CompressedInfo)
    return EncodedInfo
end

function UUF:ImportSavedVariables(EncodedInfo)
    local DecodedInfo = Compress:DecodeForPrint(EncodedInfo)
    local DecompressedInfo = Compress:DecompressDeflate(DecodedInfo)
    local InformationDecoded, InformationTable = Serialize:Deserialize(DecompressedInfo)

    if not InformationDecoded then print("Failed to import: invalid or corrupted string.") return end

    StaticPopupDialogs["UUF_IMPORT_PROFILE_NAME"] = {
        text = "Enter A Profile Name:",
        button1 = "Import",
        button2 = "Cancel",
        hasEditBox = true,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
        OnAccept = function(self)
            local newProfileName = self.EditBox:GetText() or self.editBox:GetText()
            if newProfileName and newProfileName ~= "" then
                UUF.DB:SetProfile(newProfileName)

                wipe(UUF.DB.profile)
                for key, value in pairs(InformationTable.profile) do
                    UUF.DB.profile[key] = value
                end
                for key, value in pairs(InformationTable.global) do
                    UUF.DB.global[key] = value
                end
            else
                print("Please enter a valid profile name.")
            end
        end,
    }

    StaticPopup_Show("UUF_IMPORT_PROFILE_NAME")
end

function UUFG:ExportUUF(profileKey)
    local profile = UUF.DB.profiles[profileKey]
    if not profile then return nil end

    local profileData = {
        global = profile.global,
        profile = profile.profile,
    }

    local SerializedInfo = Serialize:Serialize(profileData)
    local CompressedInfo = Compress:CompressDeflate(SerializedInfo)
    local EncodedInfo = Compress:EncodeForPrint(CompressedInfo)
    return EncodedInfo
end

function UUFG:ImportUUF(importString, profileKey)
    local DecodedInfo = Compress:DecodeForPrint(importString)
    local DecompressedInfo = Compress:DecompressDeflate(DecodedInfo)
    local success, profileData = Serialize:Deserialize(DecompressedInfo)

    if success and type(profileData.profile) == "table" then
        UUF.DB.profiles[profileKey] = profileData.profile
        UUF.DB:SetProfile(profileKey)
    end

    if type(profileData.global) == "table" then
        for key, value in pairs(profileData.global) do
            UUF.DB.global[key] = value
        end
    end
end