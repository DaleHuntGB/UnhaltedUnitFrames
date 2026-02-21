---
name: wow-api-quests
description: "Complete reference for WoW Retail Quest, Quest Log, Quest Info, Quest Offer, Quest Session, Quest Task, Campaign, Content Tracking, Quest Hub, and Quest Line APIs. Covers C_QuestLog (70+ functions for quest state, objectives, tracking, completion), C_QuestInfoSystem (quest type/tag info), C_QuestOffer (quest accept/decline), C_QuestSession (party sync quests), C_QuestTaskInfo (bonus objectives/world quests), C_ContentTracking, C_CampaignInfo, C_QuestHubUI, C_QuestLineUI, C_QuestItemUse, C_WarCampaign (legacy), quest POI functions, and quest gossip patterns. Use when working with quest tracking, quest log display, quest objectives, quest accept/complete flows, world quests, campaign progress, bonus objectives, or content tracking systems."
---

# Quest API (Retail — Patch 12.0.0)

Comprehensive reference for all quest-related APIs in WoW Retail.

> **Source:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API
> **Current as of:** Patch 12.0.0 (Build 65655) — January 28, 2026
> **Scope:** Retail only.

---

## Scope

- **C_QuestLog** — Quest log management, tracking, completion, objectives
- **C_QuestInfoSystem** — Quest type/tag info, quest classification
- **C_QuestOffer** — Quest accept/decline/complete flows
- **C_QuestSession** — Party sync quest sessions
- **C_QuestTaskInfo** — Bonus objectives, world quests
- **C_ContentTracking** — Content tracking system
- **C_CampaignInfo** — Campaign (story chapter) tracking
- **C_QuestHubUI** — Quest hub display
- **C_QuestLineUI** — Quest line (chain) info
- **C_QuestItemUse** — Quest item use tracking
- **Quest POI** — POI data for quest objectives
- **Quest Gossip** — NPC gossip quest interaction

---

## C_QuestLog — Quest Log

### Quest State & Info

| Function | Returns | Description |
|----------|---------|-------------|
| `C_QuestLog.GetNumQuestLogEntries()` | `numEntries, numQuests` | Number of quest log entries |
| `C_QuestLog.GetInfo(questLogIndex)` | `info` | Quest info at log index |
| `C_QuestLog.GetQuestIDForLogIndex(questLogIndex)` | `questID` | Quest ID at index |
| `C_QuestLog.GetLogIndexForQuestID(questID)` | `questLogIndex` | Log index for quest |
| `C_QuestLog.GetTitleForQuestID(questID)` | `title` | Quest title |
| `C_QuestLog.GetQuestTagInfo(questID)` | `tagInfo` | Quality, frequency, tag |
| `C_QuestLog.GetQuestType(questID)` | `questType` | Quest type enum |
| `C_QuestLog.GetQuestDifficultyLevel(questID)` | `level` | Suggested level |
| `C_QuestLog.GetRequiredMoney(questID)` | `money` | Money required |
| `C_QuestLog.GetSuggestedGroupSize(questID)` | `groupSize` | Suggested group size |
| `C_QuestLog.GetTimeAllowed(questID)` | `totalTime, elapsedTime` | Timed quest info |
| `C_QuestLog.GetZoneStoryInfo(uiMapID)` | `storyInfo` | Zone story progress |
| `C_QuestLog.GetMapForQuestPOIs()` | `uiMapID` | Map with quest POIs |
| `C_QuestLog.GetQuestAdditionalHighlights(questID)` | `highlights` | Additional highlight info |

### Quest Completion & Tracking

| Function | Returns | Description |
|----------|---------|-------------|
| `C_QuestLog.IsComplete(questID)` | `isComplete` | Is quest complete? |
| `C_QuestLog.IsFailed(questID)` | `isFailed` | Has quest failed? |
| `C_QuestLog.IsOnQuest(questID)` | `isOnQuest` | Is quest in log? |
| `C_QuestLog.IsQuestCalling(questID)` | `isCalling` | Is it a calling? |
| `C_QuestLog.IsQuestDisabledForSession(questID)` | `isDisabled` | Disabled for session? |
| `C_QuestLog.IsQuestFlaggedCompleted(questID)` | `isCompleted` | Flagged completed (ever)? |
| `C_QuestLog.IsQuestReplayable(questID)` | `isReplayable` | Can be replayed? |
| `C_QuestLog.IsQuestReplayedRecently(questID)` | `isRecent` | Replayed recently? |
| `C_QuestLog.IsQuestTrivial(questID)` | `isTrivial` | Below player level? |
| `C_QuestLog.IsRepeatableQuest(questID)` | `isRepeatable` | Is repeatable? |
| `C_QuestLog.IsWorldQuest(questID)` | `isWorldQuest` | Is a world quest? |
| `C_QuestLog.IsQuestBounty(questID)` | `isBounty` | Is an emissary/bounty? |
| `C_QuestLog.IsImportantQuest(questID)` | `isImportant` | Is important (landmark)? |
| `C_QuestLog.IsLegendaryQuest(questID)` | `isLegendary` | Is legendary? |
| `C_QuestLog.ReadyForTurnIn(questID)` | `ready` | Ready to turn in? |

### Quest Tracking

| Function | Returns | Description |
|----------|---------|-------------|
| `C_QuestLog.GetNumQuestWatches()` | `numWatches` | Number of tracked quests |
| `C_QuestLog.GetQuestWatchType(questID)` | `watchType` | How quest is tracked |
| `C_QuestLog.AddQuestWatch(questID [, watchType])` | `wasWatched` | Track a quest |
| `C_QuestLog.RemoveQuestWatch(questID)` | `wasRemoved` | Untrack a quest |
| `C_QuestLog.IsQuestWatched(questID)` | `isWatched` | Is quest tracked? |
| `C_QuestLog.GetQuestIDForQuestWatchIndex(watchIndex)` | `questID` | Quest at watch index |

### Quest Objectives

| Function | Returns | Description |
|----------|---------|-------------|
| `C_QuestLog.GetNumQuestObjectives(questID)` | `numObjectives` | Number of objectives |
| `C_QuestLog.GetQuestObjectives(questID)` | `objectives` | All objectives data |
| `C_QuestLog.GetQuestProgressBarPercent(questID)` | `percent` | Progress bar % |

### Quest Actions

| Function | Returns | Description |
|----------|---------|-------------|
| `C_QuestLog.AbandonQuest()` | — | Abandon selected quest |
| `C_QuestLog.SetSelectedQuest(questID)` | — | Select quest in log |
| `C_QuestLog.GetSelectedQuest()` | `questID` | Currently selected quest |
| `C_QuestLog.SetAbandonQuest(questID)` | — | Prepare to abandon |
| `C_QuestLog.RequestLoadQuestByID(questID)` | — | Request quest data load |
| `C_QuestLog.ShouldShowQuestRewards(questID)` | `shouldShow` | Show rewards? |
| `C_QuestLog.GetNextWaypoint(questID)` | `mapID, x, y` | Next waypoint |
| `C_QuestLog.GetNextWaypointForMap(questID, uiMapID)` | `x, y` | Waypoint on map |
| `C_QuestLog.GetNextWaypointText(questID)` | `waypointText` | Waypoint text |

### Quest Rewards (from quest log)

| Function | Returns | Description |
|----------|---------|-------------|
| `GetNumQuestLogRewards(questID)` | `numRewards` | Number of item rewards |
| `GetQuestLogRewardInfo(rewardIndex, questID)` | `name, texture, count, quality, isUsable, itemID, itemLevel` | Reward item info |
| `GetQuestLogRewardMoney(questID)` | `money` | Money reward |
| `GetQuestLogRewardXP(questID)` | `xp` | XP reward |
| `GetQuestLogRewardCurrencies(questID)` | `currencies` | Currency rewards |
| `GetQuestLogRewardSpell(rewardIndex, questID)` | `texture, name, isTradeskillSpell, isSpellLearned, hideSpellLearnText, isBoostSpell, garrFollowerID, genericUnlock, spellID` | Spell reward |
| `GetNumQuestLogRewardSpells(questID)` | `numSpells` | Number of spell rewards |

---

## C_QuestInfoSystem

| Function | Returns | Description |
|----------|---------|-------------|
| `C_QuestInfoSystem.GetQuestRewardCurrencies(questID)` | `currencies` | Quest reward currencies |
| `C_QuestInfoSystem.GetQuestRewardSpells(questID)` | `spellRewards` | Quest reward spells |
| `C_QuestInfoSystem.GetQuestShouldToastCompletion(questID)` | `shouldToast` | Show completion toast? |
| `C_QuestInfoSystem.HasQuestRewardCurrencies(questID)` | `hasCurrencies` | Has currency rewards? |
| `C_QuestInfoSystem.HasQuestRewardSpells(questID)` | `hasSpells` | Has spell rewards? |

---

## C_QuestOffer — Quest Accept/Decline

| Function | Returns | Description |
|----------|---------|-------------|
| `AcceptQuest()` | — | Accept the offered quest |
| `DeclineQuest()` | — | Decline the offered quest |
| `CompleteQuest()` | — | Complete quest at NPC |
| `GetQuestReward(rewardIndex)` | — | Choose reward item |
| `GetGreetingText()` | `text` | NPC greeting text |
| `GetObjectiveText()` | `text` | Quest objective text |
| `GetQuestText()` | `text` | Quest description text |
| `GetRewardText()` | `text` | Reward text |
| `GetProgressText()` | `text` | Turn-in progress text |
| `GetTitleText()` | `title` | Quest title |
| `GetNumQuestChoices()` | `numChoices` | Reward choices count |
| `GetNumQuestRewards()` | `numRewards` | Fixed rewards count |
| `GetQuestItemInfo(itemType, index)` | `name, texture, count, quality, isUsable, itemID` | Quest item info |
| `GetQuestItemLink(itemType, index)` | `link` | Item link |
| `GetNumQuestItems()` | `numItems` | Required items count |
| `IsQuestCompletable()` | `isCompletable` | Can turn in? |
| `QuestGetAutoAccept()` | `isAutoAccept` | Auto-accepted quest? |

---

## C_QuestSession — Party Sync

| Function | Returns | Description |
|----------|---------|-------------|
| `C_QuestSession.Exists()` | `exists` | In a quest session? |
| `C_QuestSession.GetAvailableSessionCommand()` | `command` | Available session command |
| `C_QuestSession.GetSessionBeginDetails()` | `details` | Session begin details |
| `C_QuestSession.GetSuperTrackedQuest()` | `questID` | Super tracked quest |
| `C_QuestSession.HasJoined()` | `hasJoined` | Has joined session? |
| `C_QuestSession.RequestSessionStart()` | — | Start quest session |
| `C_QuestSession.RequestSessionStop()` | — | Stop quest session |
| `C_QuestSession.SendSessionBeginResponse(accept)` | — | Respond to session invite |

---

## C_QuestTaskInfo — Bonus Objectives / World Quests

| Function | Returns | Description |
|----------|---------|-------------|
| `C_TaskQuest.GetQuestsForPlayerByMapID(uiMapID)` | `quests` | World quests on map |
| `C_TaskQuest.GetQuestInfoByQuestID(questID)` | `title, factionID, capped, displayAsObjective` | Task quest info |
| `C_TaskQuest.GetQuestProgressBarInfo(questID)` | `progress` | Progress bar data |
| `C_TaskQuest.GetQuestTimeLeftMinutes(questID)` | `minutesLeft` | Time remaining |
| `C_TaskQuest.GetQuestTimeLeftSeconds(questID)` | `secondsLeft` | Time remaining (seconds) |
| `C_TaskQuest.GetQuestZoneID(questID)` | `zoneID` | Zone for task quest |
| `C_TaskQuest.IsActive(questID)` | `isActive` | Is task quest active? |
| `C_TaskQuest.DoesMapShowTaskQuestObjectives(uiMapID)` | `showsObjectives` | Does map show objectives? |

---

## C_CampaignInfo — Campaigns

| Function | Returns | Description |
|----------|---------|-------------|
| `C_CampaignInfo.GetAvailableCampaigns()` | `campaignIDs` | Available campaigns |
| `C_CampaignInfo.GetCampaignID(questID)` | `campaignID` | Campaign for quest |
| `C_CampaignInfo.GetCampaignInfo(campaignID)` | `info` | Campaign info |
| `C_CampaignInfo.GetChapterIDs(campaignID)` | `chapterIDs` | Campaign chapters |
| `C_CampaignInfo.GetChapterInfo(chapterID)` | `info` | Chapter info |
| `C_CampaignInfo.GetCurrentChapterID(campaignID)` | `chapterID` | Current chapter |
| `C_CampaignInfo.GetState(campaignID)` | `state` | Campaign state |
| `C_CampaignInfo.IsCampaignQuest(questID)` | `isCampaign` | Is quest a campaign quest? |
| `C_CampaignInfo.UsesNormalQuestIcons(campaignID)` | `usesNormal` | Uses normal icons? |

---

## C_QuestLineUI — Quest Lines

| Function | Returns | Description |
|----------|---------|-------------|
| `C_QuestLineUI.GetAvailableQuestLineQuests(textFilter, uiMapID)` | `quests` | Available quest line quests |
| `C_QuestLineUI.GetQuestLineInfo(questID, uiMapID)` | `questLineInfo` | Quest line info |
| `C_QuestLineUI.GetQuestLineQuests(questLineID)` | `questIDs` | All quests in line |
| `C_QuestLineUI.IsComplete(questLineID)` | `isComplete` | Is quest line done? |
| `C_QuestLineUI.RequestQuestLinesForMap(uiMapID)` | — | Request quest line data |

---

## C_ContentTracking

| Function | Returns | Description |
|----------|---------|-------------|
| `C_ContentTracking.GetCurrentTrackingTarget(trackableType)` | `targetType, targetID` | Current tracked target |
| `C_ContentTracking.GetObjectiveText(trackableType, trackableID)` | `text` | Objective text |
| `C_ContentTracking.GetTitle(trackableType, trackableID)` | `title` | Tracking title |
| `C_ContentTracking.GetTrackedIDs(trackableType)` | `trackableIDs` | All tracked IDs |
| `C_ContentTracking.IsTracking(trackableType, trackableID)` | `isTracking` | Is it tracked? |
| `C_ContentTracking.SetTracked(trackableType, trackableID, tracked)` | — | Set tracking |
| `C_ContentTracking.StopTracking(trackableType, trackableID)` | — | Stop tracking |

---

## Quest POI Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `C_QuestLog.GetQuestPOIs()` | — | Request quest POI data |
| `QuestPOIGetIconInfo(questID)` | `completed, posX, posY, objective` | POI icon position |
| `QuestPOI_FindButton(parent, questID)` | `button` | Find POI button |

---

## Common Patterns

### Iterate Quest Log

```lua
local numEntries, numQuests = C_QuestLog.GetNumQuestLogEntries()
for i = 1, numEntries do
    local info = C_QuestLog.GetInfo(i)
    if info and not info.isHeader then
        local questID = info.questID
        local title = info.title
        local isComplete = C_QuestLog.IsComplete(questID)
        print(title, isComplete and "(Complete)" or "")
    end
end
```

### Track/Untrack Quest

```lua
local function ToggleQuestWatch(questID)
    if C_QuestLog.IsQuestWatched(questID) then
        C_QuestLog.RemoveQuestWatch(questID)
    else
        C_QuestLog.AddQuestWatch(questID, Enum.QuestWatchType.Automatic)
    end
end
```

### World Quests on Map

```lua
local function GetWorldQuestsOnMap(uiMapID)
    local quests = C_TaskQuest.GetQuestsForPlayerByMapID(uiMapID)
    if quests then
        for _, quest in ipairs(quests) do
            local title = C_TaskQuest.GetQuestInfoByQuestID(quest.questId)
            local timeLeft = C_TaskQuest.GetQuestTimeLeftMinutes(quest.questId)
            print(title, timeLeft and (timeLeft .. " min left") or "")
        end
    end
end
```

### Quest Completion Event Handling

```lua
local frame = CreateFrame("Frame")
frame:RegisterEvent("QUEST_TURNED_IN")
frame:RegisterEvent("QUEST_ACCEPTED")
frame:RegisterEvent("QUEST_REMOVED")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "QUEST_TURNED_IN" then
        local questID, xpReward, moneyReward = ...
        print("Completed quest:", C_QuestLog.GetTitleForQuestID(questID))
    elseif event == "QUEST_ACCEPTED" then
        local questID = ...
        print("Accepted quest:", C_QuestLog.GetTitleForQuestID(questID))
    elseif event == "QUEST_REMOVED" then
        local questID, wasReplayQuest = ...
        print("Quest removed:", questID)
    end
end)
```

---

## Key Events

| Event | Payload | Description |
|-------|---------|-------------|
| `QUEST_ACCEPTED` | questID | Quest accepted |
| `QUEST_TURNED_IN` | questID, xpReward, moneyReward | Quest turned in |
| `QUEST_REMOVED` | questID, wasReplayQuest | Quest removed from log |
| `QUEST_LOG_UPDATE` | — | Quest log changed |
| `QUEST_WATCH_LIST_CHANGED` | questID, added | Tracking changed |
| `QUEST_AUTOCOMPLETE` | questID | Quest auto-completed |
| `QUEST_COMPLETE` | — | At NPC to complete quest |
| `QUEST_DETAIL` | questStartItemID | Quest detail shown |
| `QUEST_FINISHED` | — | Quest dialog closed |
| `QUEST_GREETING` | — | NPC greeting with quests |
| `QUEST_PROGRESS` | — | Quest turn-in progress |
| `QUEST_SESSION_CREATED` | — | Quest session created |
| `QUEST_SESSION_DESTROYED` | — | Quest session ended |
| `QUEST_SESSION_JOINED` | — | Joined quest session |
| `QUEST_SESSION_LEFT` | — | Left quest session |
| `QUEST_SESSION_MEMBER_CONFIRM` | — | Member confirmed session |
| `QUEST_POI_UPDATE` | — | Quest POI data changed |
| `TASK_PROGRESS_UPDATE` | — | Bonus objective/WQ progress |
| `WORLD_QUEST_COMPLETED_BY_SPELL` | questID | WQ completed by spell |
| `QUEST_DATA_LOAD_RESULT` | questID, success | RequestLoadQuestByID result |

---

## Gotchas & Restrictions

1. **Quest data may not be loaded** — Call `C_QuestLog.RequestLoadQuestByID(questID)` and wait for `QUEST_DATA_LOAD_RESULT` before accessing quest info for quests not in the log.
2. **GetInfo returns headers** — Quest log entries include headers (zones). Check `info.isHeader` to filter.
3. **Quest watch limit** — There's a maximum number of tracked quests. `AddQuestWatch()` returns false if at limit.
4. **Auto-accept quests** — Some quests auto-accept. Check `QuestGetAutoAccept()` to handle gracefully.
5. **World quest vs regular** — World quests use `C_TaskQuest` functions, not `C_QuestLog` for map display.
6. **Quest gossip flow** — Quest accept flow: `QUEST_GREETING` → `QUEST_DETAIL` → `AcceptQuest()` → `QUEST_ACCEPTED`.
7. **Campaign quests** — Use `C_CampaignInfo.IsCampaignQuest()` to identify story quests.
8. **Objective data** — `GetQuestObjectives()` returns a table with `text`, `type`, `finished`, `numFulfilled`, `numRequired` per objective.
