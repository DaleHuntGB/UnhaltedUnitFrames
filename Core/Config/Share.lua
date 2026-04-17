local _, UUF = ...
local Serialize = LibStub:GetLibrary("AceSerializer-3.0")
local Compress = LibStub:GetLibrary("LibDeflate")
local UUF_IMPORT_PREFIX = "!UUF_"

local function BuildEncodedProfile(profileData)
    local serializedInfo = Serialize:Serialize(profileData)
    local compressedInfo = Compress:CompressDeflate(serializedInfo)
    local encodedInfo = Compress:EncodeForPrint(compressedInfo)
    return UUF_IMPORT_PREFIX .. encodedInfo
end

local function ParseEncodedProfile(encodedInfo)
    if type(encodedInfo) ~= "string" or encodedInfo:sub(1, #UUF_IMPORT_PREFIX) ~= UUF_IMPORT_PREFIX then
        return nil
    end

    local decodedInfo = Compress:DecodeForPrint(encodedInfo:sub(#UUF_IMPORT_PREFIX + 1))
    if not decodedInfo then
        return nil
    end

    local decompressedInfo = Compress:DecompressDeflate(decodedInfo)
    if not decompressedInfo then
        return nil
    end

    local success, data = Serialize:Deserialize(decompressedInfo)
    if not success or type(data) ~= "table" then
        return nil
    end

    return data
end

local function ApplyImportedProfileToCurrent(profile)
    if type(profile) ~= "table" then
        return
    end

    wipe(UUF.db.profile)
    for key, value in pairs(profile) do
        UUF.db.profile[key] = value
    end

    UUFG.RefreshProfiles()
    local general = UUF.db.profile and UUF.db.profile.General
    local uiScale = general and general.UIScale
    UIParent:SetScale((uiScale and uiScale.Scale) or 1)
    UUF:UpdateAllUnitFrames()
end

function UUF:ExportSavedVariables()
    local profileData = { profile = UUF.db.profile, }
    return BuildEncodedProfile(profileData)
end

function UUF:ImportSavedVariables(encodedInfo, profileName)
    local data = ParseEncodedProfile(encodedInfo)
    if not data then
        UUF:PrettyPrint("Invalid Import String.")
        return
    end

    if profileName then
        UUF.db:SetProfile(profileName)
        ApplyImportedProfileToCurrent(data.profile)
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
                if not newProfileName or newProfileName == "" then
                    UUF:PrettyPrint("Please enter a valid profile name.")
                    return
                end

                UUF.db:SetProfile(newProfileName)
                ApplyImportedProfileToCurrent(data.profile)
            end,
        }
        StaticPopup_Show("UUF_IMPORT_NEW_PROFILE")
    end

end

function UUFG:ExportUUF(profileKey)
    local profile = UUF.db.profiles[profileKey]
    if not profile then return nil end

    local profileData = { profile = profile, }
    return BuildEncodedProfile(profileData)
end

function UUFG:ImportUUF(importString, profileKey)
    local profileData = ParseEncodedProfile(importString)
    if not profileData then
        UUF:PrettyPrint("Invalid Import String.")
        return
    end

    if type(profileData.profile) == "table" then
        UUF.db.profiles[profileKey] = profileData.profile
        UUF.db:SetProfile(profileKey)
    end
end
