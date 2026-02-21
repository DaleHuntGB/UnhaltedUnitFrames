---
name: wow-api-guild
description: "Complete reference for WoW Retail Guild Management, Guild Bank, Guild Info, and Guild Event APIs. Covers guild management functions (invite, promote, demote, kick, disband, MOTD, info), guild roster (GetGuildRosterInfo, GuildRoster, sorting), guild bank functions (GetGuildBankItemInfo, deposit, withdraw, tab management, permissions), guild perks/reputation, C_GuildInfo, and the Club API guild integration (guilds are ClubType.Guild in the Club system). Use when working with guild management, guild roster, guild bank, guild chat, guild events, or guild achievements."
---

# Guild API (Retail — Patch 12.0.0)

Comprehensive reference for guild management, guild bank, and guild info APIs.

> **Source:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API
> **Current as of:** Patch 12.0.0 (Build 65655) — January 28, 2026
> **Scope:** Retail only.

---

## Scope

- **Guild Management** — Invite, promote, demote, kick, disband, MOTD
- **Guild Roster** — Member list, info, sorting
- **Guild Bank** — Item management, tabs, permissions
- **C_GuildInfo** — Guild info utilities
- **Club Integration** — Guilds as C_Club entities

---

## Guild Management

### Core Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `IsInGuild()` | `inGuild` | Is player in a guild? |
| `GetGuildInfo(unit)` | `guildName, guildRankName, guildRankIndex, realm` | Guild info for unit |
| `GetGuildFactionGroup()` | `factionGroup` | Guild faction (0=Horde, 1=Alliance) |
| `GuildInvite(name)` | — | Invite player to guild |
| `GuildUninvite(name)` | — | Remove from guild |
| `GuildPromote(name)` | — | Promote one rank |
| `GuildDemote(name)` | — | Demote one rank |
| `GuildSetLeader(name)` | — | Transfer leadership |
| `GuildDisband()` | — | Disband guild |
| `GuildLeave()` | — | Leave guild |
| `GuildSetMOTD(motd)` | — | Set message of the day |
| `GetGuildRosterMOTD()` | `motd` | Get MOTD |
| `GuildRosterSetPublicNote(index, note)` | — | Set public note |
| `GuildRosterSetOfficerNote(index, note)` | — | Set officer note |
| `GuildControlSetRank(rankIndex)` | — | Select rank for editing |
| `GuildControlSetRankFlag(flagIndex, enabled)` | — | Set rank permission |
| `GuildControlGetRankFlags()` | `flags` | Get rank permissions |
| `GuildControlGetNumRanks()` | `numRanks` | Number of ranks |
| `GuildControlGetRankName(rankIndex)` | `name` | Rank name |
| `GuildControlAddRank(name)` | — | Add new rank |
| `GuildControlDelRank(rankIndex)` | — | Delete rank |
| `GuildControlSaveRank(name)` | — | Save rank changes |

### Guild Roster

| Function | Returns | Description |
|----------|---------|-------------|
| `GetNumGuildMembers()` | `totalMembers, numOnline, numOnlineAndMobile` | Member counts |
| `GetGuildRosterInfo(index)` | `name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, class, achievementPoints, achievementRank, isMobile, isSoREligible, standingID` | Member info |
| `GetGuildRosterLastOnline(index)` | `years, months, days, hours` | Last online time |
| `GuildRoster()` | — | Request roster refresh |
| `SortGuildRoster(sortType)` | — | Sort roster |
| `SetGuildRosterShowOffline(showOffline)` | — | Toggle offline display |
| `GetGuildRosterShowOffline()` | `showOffline` | Showing offline? |
| `SetGuildRosterSelection(index)` | — | Select member |
| `GetGuildRosterSelection()` | `index` | Selected member |

---

## C_GuildInfo

| Function | Returns | Description |
|----------|---------|-------------|
| `C_GuildInfo.GetGuildNewsInfo(index)` | `newsInfo` | Guild news item |
| `C_GuildInfo.GetGuildTabardInfo(unit)` | `tabardInfo` | Guild tabard details |
| `C_GuildInfo.GuildRoster()` | — | Request roster update |
| `C_GuildInfo.QueryGuildMemberRecipes(guildMemberGUID, skillLineID)` | — | Query member recipes |
| `C_GuildInfo.QueryGuildMembersForRecipe(skillLineID, spellID [, recipeLevel])` | — | Query who knows recipe |
| `C_GuildInfo.RemoveFromGuild(guid)` | — | Remove by GUID |
| `C_GuildInfo.IsGuildOfficer()` | `isOfficer` | Is player officer? |
| `C_GuildInfo.IsGuildRankAssignmentAllowed(guid, rankOrder)` | `isAllowed` | Can assign rank? |
| `C_GuildInfo.SetGuildRankOrder(guid, rankOrder)` | — | Set member rank |
| `C_GuildInfo.SetNote(guid, note, isPublic)` | — | Set public/officer note |
| `C_GuildInfo.CanEditOfficerNote()` | `canEdit` | Can edit officer notes? |
| `C_GuildInfo.CanSpeakInGuildChat()` | `canSpeak` | Can talk in guild chat? |
| `C_GuildInfo.CanViewOfficerNote()` | `canView` | Can view officer notes? |
| `C_GuildInfo.GetGuildRankOrder(guid)` | `rankOrder` | Member rank order |
| `C_GuildInfo.MemberExistsByName(name)` | `exists` | Member in guild? |

---

## Guild Bank

### Guild Bank Items

| Function | Returns | Description |
|----------|---------|-------------|
| `GetGuildBankNumSlots(tab)` | `numSlots` | Slots in bank tab |
| `GetGuildBankItemInfo(tab, slot)` | `texture, itemCount, locked, isFiltered, quality` | Item info |
| `GetGuildBankItemLink(tab, slot)` | `link` | Item link |
| `GetGuildBankItemValue(tab, slot)` | `value` | Item vendor value |
| `AutoStoreGuildBankItem(tab, slot)` | — | Move to bags |
| `SplitGuildBankItem(tab, slot, amount)` | — | Split stack |
| `PickupGuildBankItem(tab, slot)` | — | Pick up item |
| `QueryGuildBankTab(tab)` | — | Request tab data |
| `QueryGuildBankLog(tab)` | — | Request tab log |
| `QueryGuildBankText(tab)` | — | Request tab info text |

### Guild Bank Tabs

| Function | Returns | Description |
|----------|---------|-------------|
| `GetNumGuildBankTabs()` | `numTabs` | Number of bank tabs |
| `GetGuildBankTabInfo(tab)` | `name, icon, isViewable, canDeposit, numWithdrawals, remainingWithdrawals` | Tab info |
| `SetGuildBankTabInfo(tab, name, icon)` | — | Edit tab name/icon |
| `BuyGuildBankTab()` | — | Purchase new tab |
| `GetGuildBankTabCost()` | `cost` | Next tab cost |
| `GetGuildBankText(tab)` | `text` | Tab info text |
| `SetGuildBankText(tab, text)` | — | Set tab info text |
| `CanGuildBankRepair()` | `canRepair` | Can repair from guild bank? |
| `GetGuildBankWithdrawMoney()` | `amount` | Withdrawal allowance |
| `GetGuildBankMoney()` | `money` | Guild bank gold |
| `DepositGuildBankMoney(amount)` | — | Deposit gold |
| `WithdrawGuildBankMoney(amount)` | — | Withdraw gold |
| `CanWithdrawGuildBankMoney()` | `canWithdraw` | Can withdraw gold? |
| `GetGuildBankMoneyTransaction(index)` | `type, name, amount, years, months, days, hours` | Money log entry |
| `GetNumGuildBankMoneyTransactions()` | `numTransactions` | Money log count |

### Guild Bank Log

| Function | Returns | Description |
|----------|---------|-------------|
| `GetNumGuildBankTransactions(tab)` | `numTransactions` | Tab transaction count |
| `GetGuildBankTransaction(tab, index)` | `type, name, itemLink, count, tab1, tab2, year, month, day, hour` | Transaction entry |

---

## Guild + Club Integration

Guilds are represented as clubs with `Enum.ClubType.Guild` in the C_Club system:

```lua
-- Get guild as a club
local clubs = C_Club.GetSubscribedClubs()
for _, club in ipairs(clubs) do
    if club.clubType == Enum.ClubType.Guild then
        local guildClubId = club.clubId
        -- Use C_Club functions for guild chat streams
        local streams = C_Club.GetStreams(guildClubId)
        break
    end
end
```

---

## Common Patterns

### Iterate Guild Roster

```lua
local function PrintGuildMembers()
    local numMembers = GetNumGuildMembers()
    for i = 1, numMembers do
        local name, rankName, rankIndex, level, classDisplayName, zone,
              publicNote, officerNote, isOnline = GetGuildRosterInfo(i)
        if isOnline then
            print(name, level, classDisplayName, zone)
        end
    end
end

-- Must request roster first
C_GuildInfo.GuildRoster()
```

### Guild Bank Interaction

```lua
-- List items in guild bank tab 1
local function ListGuildBankTab(tab)
    local numSlots = GetGuildBankNumSlots(tab)
    for slot = 1, numSlots do
        local texture, itemCount, locked, isFiltered, quality = GetGuildBankItemInfo(tab, slot)
        if texture then
            local link = GetGuildBankItemLink(tab, slot)
            print(link, "x" .. (itemCount or 1))
        end
    end
end
```

---

## Key Events

| Event | Payload | Description |
|-------|---------|-------------|
| `GUILD_ROSTER_UPDATE` | canRequestRosterUpdate | Roster data refreshed |
| `GUILD_RANKS_UPDATE` | — | Rank structure changed |
| `GUILD_MOTD` | motdText | MOTD received |
| `GUILD_NEWS_UPDATE` | — | Guild news updated |
| `GUILD_INVITE_REQUEST` | inviter, guildName, guildAchievementPoints, oldGuildName, isNewGuild, ... | Guild invite received |
| `GUILD_INVITE_CANCEL` | — | Invite cancelled |
| `PLAYER_GUILD_UPDATE` | unitTarget | Guild status changed |
| `GUILD_TRADESKILL_UPDATE` | — | Guild tradeskill updated |
| `GUILD_RECIPE_KNOWN_BY_MEMBERS` | — | Recipe query result |
| `GUILDBANK_ITEM_LOCK_CHANGED` | — | Bank item lock changed |
| `GUILDBANK_UPDATE_TABS` | — | Bank tabs updated |
| `GUILDBANK_UPDATE_MONEY` | — | Bank money changed |
| `GUILDBANK_UPDATE_TEXT` | tab | Bank info text updated |
| `GUILDBANKBAGSLOTS_CHANGED` | — | Bank slots changed |
| `GUILDBANKFRAME_OPENED` | — | Bank frame opened |
| `GUILDBANKFRAME_CLOSED` | — | Bank frame closed |
| `GUILDBANKLOG_UPDATE` | — | Bank log updated |

---

## Gotchas & Restrictions

1. **Roster request required** — Call `C_GuildInfo.GuildRoster()` before reading roster. Data isn't always current.
2. **Guild bank requires NPC** — Guild bank functions only work when at a guild bank NPC.
3. **Permissions vary by rank** — Check permissions before attempting operations. `CanGuildBankRepair()`, `CanWithdrawGuildBankMoney()`, etc.
4. **QueryGuildBankTab is async** — Must query each tab and wait for `GUILDBANK_UPDATE_TABS` before reading items.
5. **Guild = Club** — Guild chat uses `C_Club` with `Enum.ClubType.Guild`. Use `C_Club.SendMessage()` for guild chat.
6. **Rank indices** — Rank 0 = Guild Master. Higher indices = lower ranks.
7. **GetGuildRosterInfo index** — 1-based index into the roster. Not related to rank or any other ordering.
8. **MOTD event timing** — `GUILD_MOTD` fires during login. Register early to catch it.
