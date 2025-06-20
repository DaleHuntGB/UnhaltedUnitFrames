local _, UUF = ...
local Serialize = LibStub:GetLibrary("AceSerializer-3.0")
local Compress = LibStub:GetLibrary("LibDeflate")

function UUF:ExportSavedVariables()
    local SerializedInfo = Serialize:Serialize(UUF.DB.profile)
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
            local newProfileName = self.EditBox:GetText()
            if newProfileName and newProfileName ~= "" then
                UUF.DB:SetProfile(newProfileName)
                for k in pairs(UUF.DB.profile) do
                    UUF.DB.profile[k] = nil
                end
                for k, v in pairs(InformationTable) do
                    UUF.DB.profile[k] = v
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
    local SerializedInfo = Serialize:Serialize(profile)
    local CompressedInfo = Compress:CompressDeflate(SerializedInfo)
    local EncodedInfo = Compress:EncodeForPrint(CompressedInfo)
    return EncodedInfo
end

function UUFG:ImportUUF(importString, profileKey)
    local DecodedInfo = Compress:DecodeForPrint(importString)
    local DecompressedInfo = Compress:DecompressDeflate(DecodedInfo)
    local success, profileData = Serialize:Deserialize(DecompressedInfo)
    if success and type(profileData) == "table" then
        UUF.DB.profiles[profileKey] = profileData
        UUF.DB:SetProfile(profileKey)
    end
end