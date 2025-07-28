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
    local success, data = Serialize:Deserialize(DecompressedInfo)
    if not success or type(data) ~= "table" then
        print("Failed to import: invalid or corrupted string.")
        return
    end

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
            if not newProfileName or newProfileName == "" then
                print("Please enter a valid profile name.")
                return
            end

            UUF.DB:SetProfile(newProfileName)
            wipe(UUF.DB.profile)

            -- Handle Legacy Strings
            -- Basically, check for the flatter structure.
            if data.Player or data.Target then
                for key, value in pairs(data) do
                    if key ~= "global" then
                        UUF.DB.profile[key] = value
                    end
                end
                print("|cFF8080FFUnhalted|r Unit Frames: You have imported a legacy profile. Some options may not be configured correctly.")
            elseif type(data.profile) == "table" then
                for key, value in pairs(data.profile) do
                    UUF.DB.profile[key] = value
                end
            end

            if type(data.global) == "table" then
                for key, value in pairs(data.global) do
                    UUF.DB.global[key] = value
                end
            end
        end,
    }

    StaticPopup_Show("UUF_IMPORT_PROFILE_NAME")
end



function UUFG:ExportUUF(profileKey)
    local profile = UUF.DB.profiles[profileKey]
    if not profile then return nil end

    local profileData = {
        profile = profile,
        global = UUF.DB.global,
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

    if not success or type(profileData) ~= "table" then
        print("Failed to import: invalid or corrupted string.")
        return
    end

    -- Handle Legacy Strings
    -- Basically, check for the flatter structure.
    if profileData.Player or profileData.Target then
        UUF.DB.profiles[profileKey] = profileData
        UUF.DB:SetProfile(profileKey)
        print("|cFF8080FFUnhalted|r Unit Frames: You have imported a legacy profile. Some options may not be configured correctly.")
        return
    end


    if type(profileData.profile) == "table" then
        UUF.DB.profiles[profileKey] = profileData.profile
        UUF.DB:SetProfile(profileKey)
    end

    if type(profileData.global) == "table" then
        for key, value in pairs(profileData.global) do
            UUF.DB.global[key] = value
        end
    end
end
