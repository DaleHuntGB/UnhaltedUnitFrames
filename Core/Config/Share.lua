local _, UUF = ...
local Serialize = LibStub:GetLibrary("AceSerializer-3.0")
local Compress = LibStub:GetLibrary("LibDeflate")

function UUF:ExportSavedVariables()
    local profileData = { profile = UUF.db.profile, }
    local SerializedInfo = Serialize:Serialize(profileData)
    local CompressedInfo = Compress:CompressDeflate(SerializedInfo)
    local EncodedInfo = Compress:EncodeForPrint(CompressedInfo)
    EncodedInfo = "!UUF_"..EncodedInfo
    return EncodedInfo
end

function UUF:ImportSavedVariables(EncodedInfo, profileName)
    local DecodedInfo = Compress:DecodeForPrint(EncodedInfo:sub(6))
    local DecompressedInfo = Compress:DecompressDeflate(DecodedInfo)
    local success, data = Serialize:Deserialize(DecompressedInfo)
    if not success or type(data) ~= "table" or EncodedInfo:sub(1, 5) ~= "!UUF_" then UUF:PrettyPrint("Invalid Import String.") return end

    if profileName then
        UUF.db:SetProfile(profileName)
        wipe(UUF.db.profile)

        if type(data.profile) == "table" then
            for key, value in pairs(data.profile) do
                UUF.db.profile[key] = value
            end
        end

        UUFG.RefreshProfiles()

        UIParent:SetScale(UUF.db.profile.General.UIScale or 1)
    else
        StaticPopupDialogs["UUF_IMPORT_NEW_PROFILE"] = {
            text = UUF.ADDON_NAME.." - ".."Profile Name?",
            button1 = "Import",
            button2 = "Cancel",
            hasEditBox = true,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
            OnAccept = function(self)
                local editBox = self.EditBox
                local newProfileName = editBox:GetText() or string.format("Imported_%s-%s-%s", date("%d"), date("%m"), date("%Y"))
                if not newProfileName or newProfileName == "" then UUF:PrettyPrint("Please enter a valid profile name.") return end

                UUF.db:SetProfile(newProfileName)
                wipe(UUF.db.profile)

                if type(data.profile) == "table" then
                    for key, value in pairs(data.profile) do
                        UUF.db.profile[key] = value
                    end
                end

                UUFG.RefreshProfiles()

                UIParent:SetScale(UUF.db.profile.General.UIScale.Scale or 1)

            end,
        }
        StaticPopup_Show("UUF_IMPORT_NEW_PROFILE")
    end

end

function UUFG:ExportUUF(profileKey)
    local profile = UUF.db.profiles[profileKey]
    if not profile then return nil end

    local profileData = { profile = profile, }

    local SerializedInfo = Serialize:Serialize(profileData)
    local CompressedInfo = Compress:CompressDeflate(SerializedInfo)
    local EncodedInfo = Compress:EncodeForPrint(CompressedInfo)
    EncodedInfo = "!UUF_" .. EncodedInfo
    return EncodedInfo
end

function UUFG:ImportUUF(importString, profileKey)
    local DecodedInfo = Compress:DecodeForPrint(importString:sub(6))
    local DecompressedInfo = Compress:DecompressDeflate(DecodedInfo)
    local success, profileData = Serialize:Deserialize(DecompressedInfo)

    if not success or type(profileData) ~= "table" then print("|cFF8080FFUnhalted|r Unit Frames: Invalid Import String.") return end

    if type(profileData.profile) == "table" then
        UUF.db.profiles[profileKey] = profileData.profile
        UUF.db:SetProfile(profileKey)
    end
end