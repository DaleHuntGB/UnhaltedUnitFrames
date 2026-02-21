---
name: wow-api-social-chat
description: "Complete reference for WoW Retail Chat, Social, Club/Community, Friend List, Voice Chat, BattleNet, Ping, Social Queue, and Addon Messaging APIs. Covers C_ChatInfo, C_Club, C_ClubFinder, C_FriendList, C_BattleNet, C_VoiceChat, C_SocialRestrictions, C_SocialQueue, C_RecentAllies, C_PingManager, C_TTSSettings, ChatFrame functions, chat filters, addon message system, and 12.0.0 instance restrictions (SendAddonMessage blocked, chat messages may be secret). Use when working with chat output, chat channels, communities, friend lists, voice chat, BattleNet friends, addon communication, social features, or ping system."
---

# Social & Chat API (Retail — Patch 12.0.0)

Comprehensive reference for chat, social, clubs/communities, friends, voice, BattleNet, and related APIs.

> **Source:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API
> **Current as of:** Patch 12.0.0 (Build 65655) — January 28, 2026
> **Scope:** Retail only.

## CRITICAL: 12.0.0 Instance Restrictions

- **`SendAddonMessage()` is BLOCKED inside instances** (dungeons, raids, BGs, arenas)
- Chat messages in instances may be **secret values** (KStrings)
- Addon communication must use alternative patterns outside instances
- `C_ChatInfo.SendAddonMessage()` and `C_ChatInfo.SendAddonMessageLogged()` throw errors in instances

---

## Scope

- **C_ChatInfo** — Chat system, channels, addon messages
- **Chat Frame Functions** — SendChatMessage, chat filters, chat bubbles
- **C_Club** — Communities / clubs system
- **C_ClubFinder** — Club finder / recruitment
- **C_FriendList** — Friends list management
- **C_BattleNet** — BattleNet friends, presence, game accounts
- **C_VoiceChat** — Voice chat system
- **C_SocialRestrictions** — Social restriction checks
- **C_SocialQueue** — Social queue system
- **C_RecentAllies** — Recent allies tracking
- **C_PingManager** — In-world ping system
- **C_TTSSettings** — Text-to-speech settings

---

## C_ChatInfo — Chat System

### Key Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `C_ChatInfo.SendAddonMessage(prefix, message, chatType [, target])` | `success` | Send addon message (BLOCKED in instances) |
| `C_ChatInfo.SendAddonMessageLogged(prefix, message, chatType [, target])` | `success` | Send logged addon message (BLOCKED in instances) |
| `C_ChatInfo.RegisterAddonMessagePrefix(prefix)` | `success` | Register prefix for CHAT_MSG_ADDON |
| `C_ChatInfo.IsAddonMessagePrefixRegistered(prefix)` | `isRegistered` | Check if prefix registered |
| `C_ChatInfo.GetRegisteredAddonMessagePrefixes()` | `prefixes` | All registered prefixes |
| `C_ChatInfo.GetChannelInfoFromIdentifier(identifier)` | `info` | Channel info by identifier |
| `C_ChatInfo.GetChannelRuleset(channelIndex)` | `rulesetID` | Channel ruleset |
| `C_ChatInfo.GetChannelRulesetForChannelID(channelID)` | `rulesetID` | Ruleset by channel ID |
| `C_ChatInfo.GetChannelShortcut(channelIndex)` | `shortcut` | Channel shortcut |
| `C_ChatInfo.GetChannelShortcutForChannelID(channelID)` | `shortcut` | Shortcut by channel ID |
| `C_ChatInfo.GetChatLineSenderGUID(lineID)` | `guid` | GUID of message sender |
| `C_ChatInfo.GetChatLineSenderName(lineID)` | `name` | Name of message sender |
| `C_ChatInfo.GetChatLineText(lineID)` | `text` | Message text |
| `C_ChatInfo.GetChatTypeByID(chatTypeID)` | `chatType` | Chat type string from ID |
| `C_ChatInfo.GetColorForChatType(chatType)` | `r, g, b` | Default color for chat type |
| `C_ChatInfo.GetNumActiveChannels()` | `numChannels` | Number of active channels |
| `C_ChatInfo.GetActiveChannelList()` | `channels` | Active channel list |
| `C_ChatInfo.IsChannelRegional(chatType)` | `isRegional` | Is channel regional? |
| `C_ChatInfo.IsChatLineCensored(lineID)` | `isCensored` | Is message censored? |
| `C_ChatInfo.IsPartyPositionCategory(category)` | `isPartyPosition` | Is party position category? |
| `C_ChatInfo.IsRegionalServiceAvailable()` | `isAvailable` | Regional service available? |
| `C_ChatInfo.IsValidChatLine(lineID)` | `isValid` | Is line valid? |
| `C_ChatInfo.ReplaceIconAndGroupExpressions(message)` | `text` | Expand {rt1}, {skull}, etc. |
| `C_ChatInfo.ResetDefaultZoneChannels()` | — | Reset zone channels |
| `C_ChatInfo.SwapChatChannelsByChannelIndex(i1, i2)` | — | Swap channel order |

### Global Chat Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `SendChatMessage(msg [, chatType [, languageID [, target]]])` | — | Send chat message |
| `GetNumDisplayChannels()` | `numChannels` | Number of displayed channels |
| `GetChannelDisplayInfo(index)` | `name, header, collapsed, channelNumber, count, active, category, voiceEnabled, voiceActive` | Channel display info |
| `GetChannelName(idOrName)` | `id, name, instanceID, isCommChannel` | Channel name/ID lookup |
| `JoinChannelByName(name [, password [, frameID]])` | `type, name` | Join a channel |
| `LeaveChannelByName(name)` | — | Leave a channel |
| `ListChannelByName(name)` | — | List channel members |
| `GetChatWindowInfo(frameIndex)` | `name, fontSize, r, g, b, alpha, shown, locked, docked, uninteractable` | Chat window info |
| `SetChatWindowName(frameIndex, name)` | — | Set chat window name |
| `LoggingChat(enable)` | — | Toggle chat logging |
| `LoggingCombat(enable)` | — | Toggle combat logging |

---

## C_Club — Communities / Clubs

### Club Management

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Club.GetSubscribedClubs()` | `clubs` | All joined clubs |
| `C_Club.GetClubInfo(clubId)` | `info` | Club info |
| `C_Club.GetClubMembers(clubId [, streamId])` | `members` | Club member list |
| `C_Club.GetMemberInfo(clubId, memberId)` | `info` | Member info |
| `C_Club.GetClubStreamNotificationSettings(clubId)` | `settings` | Stream notification settings |
| `C_Club.CreateClub(name, shortName, description, clubType, avatarId)` | — | Create new club |
| `C_Club.DestroyClub(clubId)` | — | Destroy a club |
| `C_Club.EditClub(clubId, name, shortName, description, avatarId, bgColorIndex)` | — | Edit club |
| `C_Club.LeaveClub(clubId)` | — | Leave a club |
| `C_Club.AcceptInvitation(clubId)` | — | Accept club invitation |
| `C_Club.DeclineInvitation(clubId)` | — | Decline club invitation |
| `C_Club.GetInvitationsForSelf()` | `invitations` | Pending invitations |
| `C_Club.SendInvitation(clubId, memberId)` | — | Invite to club |

### Club Streams (Chat Channels within Clubs)

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Club.GetStreams(clubId)` | `streams` | All streams for club |
| `C_Club.GetStreamInfo(clubId, streamId)` | `info` | Stream info |
| `C_Club.CreateStream(clubId, name, subject, leadersAndModeratorsOnly)` | — | Create stream |
| `C_Club.DestroyStream(clubId, streamId)` | — | Remove stream |
| `C_Club.EditStream(clubId, streamId, name, subject, leadersAndModeratorsOnly)` | — | Edit stream |
| `C_Club.GetMessagesBefore(clubId, streamId, messageId, count)` | `messages` | Fetch messages before ID |
| `C_Club.GetMessagesAfter(clubId, streamId, messageId, count)` | `messages` | Fetch messages after ID |
| `C_Club.GetMessagesInRange(clubId, streamId, oldest, newest)` | `messages` | Messages in range |
| `C_Club.SendMessage(clubId, streamId, message)` | — | Send message to stream |
| `C_Club.FocusStream(clubId, streamId)` | — | Focus a stream |
| `C_Club.UnfocusStream(clubId, streamId)` | — | Unfocus a stream |
| `C_Club.SetAutoAdvanceStreamViewMarker(clubId, streamId)` | — | Auto-advance view marker |

### Club Types

| Enum | Value | Description |
|------|-------|-------------|
| `Enum.ClubType.BattleNet` | 0 | BattleNet community |
| `Enum.ClubType.Character` | 1 | Character community |
| `Enum.ClubType.Guild` | 2 | Guild (treated as club) |
| `Enum.ClubType.Other` | 3 | Other |

---

## C_ClubFinder — Club Finder / Recruitment

| Function | Returns | Description |
|----------|---------|-------------|
| `C_ClubFinder.RequestClubsList(type, isLinkedSearch, searchText, specIDs)` | — | Search for clubs |
| `C_ClubFinder.GetRecruitingClubInfoFromClubID(clubId)` | `recruitInfo` | Recruitment info for club |
| `C_ClubFinder.GetTotalMatchingCommunityListSize()` | `size` | Total matching communities |
| `C_ClubFinder.GetTotalMatchingGuildListSize()` | `size` | Total matching guilds |
| `C_ClubFinder.RequestPostingInformationFromClubId(clubId)` | — | Request posting info |
| `C_ClubFinder.PostClub(clubId, minIlvl, minLevel, ...)` | — | Post club listing |
| `C_ClubFinder.RequestApplicantList(type)` | — | Request applicant list |
| `C_ClubFinder.GetApplicantInfoList()` | `applicants` | Get applicants |
| `C_ClubFinder.RespondToApplicant(clubFinderGUID, playerGUID, accepted, ...)` | — | Respond to applicant |

---

## C_FriendList — Friends

| Function | Returns | Description |
|----------|---------|-------------|
| `C_FriendList.GetNumFriends()` | `numFriends` | Character friends count |
| `C_FriendList.GetNumOnlineFriends()` | `numOnline` | Online friends count |
| `C_FriendList.GetFriendInfoByIndex(index)` | `info` | Friend info by index |
| `C_FriendList.GetFriendInfoByName(name)` | `info` | Friend info by name |
| `C_FriendList.GetFriendInfoByGUID(guid)` | `info` | Friend info by GUID |
| `C_FriendList.AddFriend(name [, notes])` | — | Add friend |
| `C_FriendList.RemoveFriend(name)` | — | Remove friend |
| `C_FriendList.SetFriendNotes(name, notes)` | — | Set friend notes |
| `C_FriendList.AddOrRemoveFriend(name, notes)` | — | Toggle friend |
| `C_FriendList.IsFriend(guid)` | `isFriend` | Is GUID a friend? |
| `C_FriendList.AddIgnore(name)` | — | Add to ignore list |
| `C_FriendList.DelIgnore(name)` | — | Remove from ignore list |
| `C_FriendList.GetNumIgnores()` | `numIgnores` | Ignore list count |
| `C_FriendList.GetIgnoreName(index)` | `name` | Ignored player name |
| `C_FriendList.IsIgnored(name)` | `isIgnored` | Is player ignored? |
| `C_FriendList.IsIgnoredByGUID(guid)` | `isIgnored` | Is GUID ignored? |
| `C_FriendList.ShowFriends()` | — | Refresh friends list |
| `C_FriendList.GetSelectedFriend()` | `index` | Selected friend index |
| `C_FriendList.SetSelectedFriend(index)` | — | Select friend |

---

## C_BattleNet — BattleNet Friends

| Function | Returns | Description |
|----------|---------|-------------|
| `C_BattleNet.GetFriendAccountInfo(index)` | `accountInfo` | BNet friend account info |
| `C_BattleNet.GetFriendGameAccountInfo(index, gameAccountIndex)` | `gameAccountInfo` | Game account info |
| `C_BattleNet.GetFriendNumGameAccounts(index)` | `numGameAccounts` | Game accounts for friend |
| `C_BattleNet.GetAccountInfoByID(bnetAccountID)` | `accountInfo` | Account info by ID |
| `C_BattleNet.GetAccountInfoByGUID(guid)` | `accountInfo` | Account info by GUID |
| `C_BattleNet.GetGameAccountInfoByID(gameAccountID)` | `gameAccountInfo` | Game account info |
| `C_BattleNet.GetGameAccountInfoByGUID(guid)` | `gameAccountInfo` | Game account by GUID |
| `BNGetNumFriends()` | `numFriends, numOnline` | BNet friend count |
| `BNGetNumFriendInvites()` | `numInvites` | Pending BNet invites |
| `BNSendWhisper(bnetAccountID, message)` | — | Send BNet whisper |
| `BNInviteFriend(bnetAccountID)` | — | Invite to group |
| `BNRequestInviteFriend(presenceID)` | — | Request BNet friend add |
| `BNRemoveFriend(bnetAccountID)` | — | Remove BNet friend |
| `BNSetFriendNote(bnetAccountID, note)` | — | Set friend note |
| `BNSetCustomMessage(message)` | — | Set BNet status message |
| `BNConnected()` | `isConnected` | Connected to BNet? |

---

## C_VoiceChat — Voice Chat

| Function | Returns | Description |
|----------|---------|-------------|
| `C_VoiceChat.GetActiveChannelID()` | `channelID` | Active voice channel |
| `C_VoiceChat.GetChannel(channelID)` | `channel` | Channel info |
| `C_VoiceChat.GetChannelForChannelType(channelType)` | `channel` | Channel by type |
| `C_VoiceChat.GetChannelForCommunityStream(clubId, streamId)` | `channel` | Club voice channel |
| `C_VoiceChat.GetMasterVolumeScale()` | `scale` | Master volume |
| `C_VoiceChat.SetMasterVolumeScale(scale)` | — | Set master volume |
| `C_VoiceChat.GetInputVolume()` | `volume` | Mic volume |
| `C_VoiceChat.SetInputVolume(volume)` | — | Set mic volume |
| `C_VoiceChat.GetOutputVolume()` | `volume` | Speaker volume |
| `C_VoiceChat.SetOutputVolume(volume)` | — | Set speaker volume |
| `C_VoiceChat.IsMuted()` | `isMuted` | Is muted? |
| `C_VoiceChat.SetMuted(muted)` | — | Set mute |
| `C_VoiceChat.IsDeafened()` | `isDeafened` | Is deafened? |
| `C_VoiceChat.SetDeafened(deafened)` | — | Set deafen |
| `C_VoiceChat.IsSilenced()` | `isSilenced` | Is silenced (by Blizzard)? |
| `C_VoiceChat.ActivateChannel(channelID)` | — | Activate voice channel |
| `C_VoiceChat.DeactivateChannel(channelID)` | — | Deactivate voice channel |
| `C_VoiceChat.IsLoggedIn()` | `isLoggedIn` | Voice chat logged in? |
| `C_VoiceChat.Login()` | — | Log in to voice chat |
| `C_VoiceChat.Logout()` | — | Log out of voice chat |
| `C_VoiceChat.GetMemberName(memberID, channelID)` | `name` | Voice member name |
| `C_VoiceChat.GetMemberVolume(memberID, channelID)` | `volume` | Member volume |
| `C_VoiceChat.SetMemberVolume(memberID, channelID, volume)` | — | Set member volume |
| `C_VoiceChat.IsMemberMuted(memberID, channelID)` | `isMuted` | Is member muted? |
| `C_VoiceChat.SetMemberMuted(memberID, channelID, muted)` | — | Mute member |

---

## C_SocialRestrictions

| Function | Returns | Description |
|----------|---------|-------------|
| `C_SocialRestrictions.IsChatDisabled()` | `isDisabled` | Is chat restricted? |
| `C_SocialRestrictions.IsMuted()` | `isMuted` | Is player muted? |
| `C_SocialRestrictions.IsSilenced()` | `isSilenced` | Is player silenced? |
| `C_SocialRestrictions.IsSquelched()` | `isSquelched` | Is player squelched? |

---

## C_SocialQueue — Social Queue

| Function | Returns | Description |
|----------|---------|-------------|
| `C_SocialQueue.GetAllGroups()` | `groups` | All social queue groups |
| `C_SocialQueue.GetGroupInfo(guid)` | `info` | Group queue info |
| `C_SocialQueue.GetGroupMembers(guid)` | `members` | Group member list |
| `C_SocialQueue.GetGroupQueues(guid)` | `queues` | Group queues |

---

## C_RecentAllies

| Function | Returns | Description |
|----------|---------|-------------|
| `C_RecentAllies.GetRecentAllies()` | `allies` | Recent group allies |

---

## C_PingManager — Ping System

| Function | Returns | Description |
|----------|---------|-------------|
| `C_PingManager.GetPingTypeFromUIMouseButton(button)` | `pingType` | Ping type from mouse button |
| `C_PingManager.TogglePingListener(enabled)` | — | Toggle ping listening |

---

## C_TTSSettings — Text-to-Speech

| Function | Returns | Description |
|----------|---------|-------------|
| `C_TTSSettings.GetChatTypeEnabled(chatType)` | `enabled` | Is TTS enabled for chat type? |
| `C_TTSSettings.SetChatTypeEnabled(chatType, enabled)` | — | Toggle TTS for chat type |
| `C_TTSSettings.GetSetting(setting)` | `value` | Get TTS setting |
| `C_TTSSettings.SetSetting(setting, value)` | — | Set TTS setting |
| `C_TTSSettings.GetVoiceOptionID(voiceType)` | `optionID` | Get voice option |

---

## Common Patterns

### Register and Handle Addon Messages

```lua
local ADDON_PREFIX = "MyAddon"
C_ChatInfo.RegisterAddonMessagePrefix(ADDON_PREFIX)

local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_ADDON")
frame:SetScript("OnEvent", function(self, event, prefix, message, channel, sender)
    if prefix == ADDON_PREFIX then
        -- Process addon message
        print("Got message from", sender, ":", message)
    end
end)

-- Send message (FAILS in instances in 12.0.0!)
local function SendMessage(msg, target)
    if not IsInInstance() then
        C_ChatInfo.SendAddonMessage(ADDON_PREFIX, msg, "PARTY")
    else
        -- In-instance: cannot send addon messages
        -- Consider using encounter events or built-in APIs instead
    end
end
```

### Chat Message Filter

```lua
-- Filter chat messages to modify or suppress them
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", function(self, event, msg, author, ...)
    if msg:find("badword") then
        return true -- suppress the message
    end
    -- Modify the message
    local newMsg = msg:gsub("hello", "|cff00ff00hello|r")
    return false, newMsg, author, ...
end)
```

### Enumerate Friends

```lua
local function GetOnlineFriends()
    local friends = {}
    local numFriends = C_FriendList.GetNumFriends()
    for i = 1, numFriends do
        local info = C_FriendList.GetFriendInfoByIndex(i)
        if info and info.connected then
            table.insert(friends, info)
        end
    end
    -- Also check BNet friends
    local numBNet, numOnlineBNet = BNGetNumFriends()
    for i = 1, numBNet do
        local acctInfo = C_BattleNet.GetFriendAccountInfo(i)
        if acctInfo and acctInfo.gameAccountInfo and acctInfo.gameAccountInfo.isOnline then
            table.insert(friends, acctInfo)
        end
    end
    return friends
end
```

---

## Key Events

| Event | Payload | Description |
|-------|---------|-------------|
| `CHAT_MSG_SAY` | msg, author, language, channelString, target, flags, ... | /say message |
| `CHAT_MSG_YELL` | msg, author, ... | /yell message |
| `CHAT_MSG_PARTY` | msg, author, ... | Party message |
| `CHAT_MSG_PARTY_LEADER` | msg, author, ... | Party leader message |
| `CHAT_MSG_RAID` | msg, author, ... | Raid message |
| `CHAT_MSG_RAID_LEADER` | msg, author, ... | Raid leader message |
| `CHAT_MSG_GUILD` | msg, author, ... | Guild message |
| `CHAT_MSG_OFFICER` | msg, author, ... | Guild officer message |
| `CHAT_MSG_WHISPER` | msg, author, ... | Incoming whisper |
| `CHAT_MSG_WHISPER_INFORM` | msg, target, ... | Outgoing whisper |
| `CHAT_MSG_BN_WHISPER` | msg, author, ... | BNet whisper received |
| `CHAT_MSG_BN_WHISPER_INFORM` | msg, target, ... | BNet whisper sent |
| `CHAT_MSG_CHANNEL` | msg, author, language, channelString, target, flags, zoneChannelID, channelIndex, channelBaseName, ... | Channel message |
| `CHAT_MSG_ADDON` | prefix, message, channel, sender | Addon message received |
| `CHAT_MSG_ADDON_LOGGED` | prefix, message, channel, sender | Logged addon message |
| `CHAT_MSG_SYSTEM` | msg | System message |
| `CHAT_MSG_EMOTE` | msg, author, ... | Emote message |
| `CHAT_MSG_TEXT_EMOTE` | msg, author, ... | /emote text |
| `FRIENDLIST_UPDATE` | — | Friends list changed |
| `BN_FRIEND_LIST_SIZE_CHANGED` | — | BNet list changed |
| `BN_FRIEND_INFO_CHANGED` | bnetAccountID | BNet friend updated |
| `BN_CONNECTED` | — | Connected to BNet |
| `BN_DISCONNECTED` | — | Disconnected from BNet |
| `CLUB_ADDED` | clubId | Joined a club |
| `CLUB_REMOVED` | clubId | Left a club |
| `CLUB_UPDATED` | clubId | Club info updated |
| `CLUB_MESSAGE_ADDED` | clubId, streamId, messageId | New club message |
| `CLUB_MEMBER_ADDED` | clubId, memberId | Member joined club |
| `CLUB_MEMBER_REMOVED` | clubId, memberId | Member left club |
| `CLUB_MEMBER_UPDATED` | clubId, memberId | Member info updated |
| `VOICE_CHAT_CHANNEL_ACTIVATED` | channelID | Voice channel activated |
| `VOICE_CHAT_CHANNEL_DEACTIVATED` | channelID | Voice channel deactivated |
| `VOICE_CHAT_CHANNEL_MEMBER_ADDED` | memberID, channelID | Member joined voice |
| `VOICE_CHAT_CHANNEL_MEMBER_REMOVED` | memberID, channelID | Left voice channel |

---

## Gotchas & Restrictions

1. **SendAddonMessage BLOCKED in instances** — `C_ChatInfo.SendAddonMessage()` and `SendAddonMessageLogged()` throw errors inside dungeons, raids, BGs, and arenas in 12.0.0.
2. **Chat messages may be secret** — In instances, chat message content from other players may be KStrings / secret values.
3. **Addon prefix limit** — Maximum 16 characters for addon message prefixes.
4. **Addon message size limit** — Maximum 255 characters per addon message.
5. **Chat throttle** — `SendChatMessage()` is throttled. Sending too fast will disconnect you.
6. **Hardware event required** — Some chat functions require a hardware event (mouse click/key press) to execute.
7. **BNet friend list** — `BNGetFriendInfo()` is deprecated. Use `C_BattleNet.GetFriendAccountInfo()`.
8. **Club type Guild** — Guilds are treated as clubs with `Enum.ClubType.Guild`. Use `C_Club` to interact with guild chat streams.
9. **Voice chat login** — Voice chat requires explicit login. Check `C_VoiceChat.IsLoggedIn()` before operations.
10. **Chat filters** — `ChatFrame_AddMessageEventFilter` filters operate on ALL instances of the event across all chat frames.
