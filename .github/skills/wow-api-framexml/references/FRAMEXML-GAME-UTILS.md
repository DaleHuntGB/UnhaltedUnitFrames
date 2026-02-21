# FrameXML — Game Utility Modules

> **Parent skill:** [wow-api-framexml](../SKILL.md)
> **Source:** [FrameXML functions — FrameXML](https://warcraft.wiki.gg/wiki/FrameXML_functions#FrameXML_2)
> **FrameXML source:** [FrameXML on GitHub](https://github.com/Gethe/wow-ui-source/tree/live/Interface/FrameXML)

These utility modules provide helper functions for specific game systems. They wrap or extend the underlying C API (`C_*` namespaces) with higher-level convenience logic.

---

## AchievementUtil

Source: [AchievementUtil (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=IsCriteriaAchievementEarned)

### `AchievementUtil.IsCriteriaAchievementEarned(achievementID, criteriaIndex)`
Returns whether a specific achievement criteria has been completed.

### `AchievementUtil.IsCriteriaReputationGained(achievementID, criteriaIndex, checkCriteriaAchievement, countHiddenCriteria)`
Returns whether a reputation-based achievement criteria has been fulfilled.

### `AchievementUtil.IsCategoryFeatOfStrength(category)`
Returns true if the achievement category is "Feats of Strength".

### `AchievementUtil.IsFeatOfStrength(achievementID)`
Returns true if a specific achievement is a Feat of Strength.

---

## ActionButtonUtil

Source: [ActionButtonUtil (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=ShowAllActionButtonGrids)

### `ActionButtonUtil.ShowAllActionButtonGrids()`
Shows the grid overlay on all action buttons (displays empty slots).

### `ActionButtonUtil.HideAllActionButtonGrids()`
Hides the grid overlay on all action buttons.

### `ActionButtonUtil.SetAllQuickKeybindButtonHighlights(show)`
Sets the quick keybind highlight state on all action buttons.

### `ActionButtonUtil.ShowAllQuickKeybindButtonHighlights()`
Shows quick keybind highlights on all action buttons.

### `ActionButtonUtil.HideAllQuickKeybindButtonHighlights()`
Hides quick keybind highlights on all action buttons.

---

## AzeriteEssenceUtil

Source: [AzeriteEssenceUtil (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=HasAnyUnlockableMilestones)

### `AzeriteEssenceUtil.HasAnyUnlockableMilestones()`
Returns true if the player has any azerite essence milestones available to unlock.

### `AzeriteEssenceUtil.GetMilestoneAtPowerLevel(powerLevel)`
Returns the milestone data for a given azerite power level.

### `AzeriteEssenceUtil.GetMilestoneSpellInfo(milestoneID)`
Returns spell information for a specific milestone.

---

## AzeriteUtil

Source: [AzeriteUtil (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=EnumerateEquipedAzeriteEmpoweredItems)

### `AzeriteUtil.EnumerateEquipedAzeriteEmpoweredItems()`
Returns an iterator over all currently equipped Azerite empowered items.

### `AzeriteUtil.AreAnyAzeriteEmpoweredItemsEquipped()`
Returns true if any Azerite empowered items are equipped.

### `AzeriteUtil.DoEquippedItemsHaveUnselectedPowers()`
Returns true if any equipped Azerite items have unselected trait powers.

### `AzeriteUtil.GetEquippedItemsUnselectedPowersCount()`
Returns the total number of unselected powers across all equipped Azerite items.

### `AzeriteUtil.GenerateRequiredSpecTooltipLine(powerID)`
Generates a tooltip line showing which spec is required for an Azerite power.

### `AzeriteUtil.FindAzeritePowerTier(azeriteEmpoweredItemSource, powerID)`
Finds the tier index of a specific Azerite power.

### `AzeriteUtil.GetSelectedAzeritePowerInTier(azeriteEmpoweredItemSource, tierIndex)`
Returns the selected power in a specific Azerite tier.

### `AzeriteUtil.HasSelectedAnyAzeritePower(azeriteEmpoweredItemSource)`
Returns true if the player has selected any Azerite power on the item.

### `AzeriteUtil.DoesBagContainAnyAzeriteEmpoweredItems(bagID)`
Returns true if a bag contains any Azerite empowered items.

### `AzeriteUtil.IsAzeriteItemLocationBankBag(azeriteItemLocation)`
Returns true if the Azerite item is in a bank bag.

---

## CalendarUtil

Source: [CalendarUtil (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=GetCalendarInviteStatusInfo)

### `CalendarUtil.GetCalendarInviteStatusInfo(inviteStatus)`
Returns display info (text, color) for a calendar invite status.

### `CalendarUtil.GetEventBroadcastText(event)`
Returns a formatted broadcast string for a calendar event.

### `CalendarUtil.GetOngoingEventBroadcastText(event)`
Returns a broadcast string for an ongoing calendar event.

### `CalendarUtil.FormatCalendarTimeWeekday(messageDate)`
Formats a calendar date into a weekday string.

### `CalendarUtil.AreDatesEqual(firstCalendarTime, secondCalendarTime)`
Compares two calendar time tables for equality.

---

## CampaignUtil

Source: [CampaignUtil (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=BuildChapterProgressText)

### `CampaignUtil.BuildChapterProgressText(campaign, formatString)`
Builds a progress text string for campaign chapters.

### `CampaignUtil.GetSingleChapterText(chapterID, lineSpacing)`
Returns formatted text for a single campaign chapter.

### `CampaignUtil.BuildAllChaptersText(campaign, lineSpacing)`
Returns formatted text for all chapters in a campaign.

---

## CommunitiesUtil

Source: [CommunitiesUtil (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=GetMemberRGB)

Extensive utilities for the Guild & Communities system.

### `CommunitiesUtil.GetMemberRGB(memberInfo)`
Returns r, g, b color values for a community member (based on class).

### `CommunitiesUtil.SortClubs(clubs)`
Sorts a list of clubs by type and name.

### `CommunitiesUtil.SortStreams(streams)`
Sorts a list of community streams.

### `CommunitiesUtil.SortMemberInfo(clubId, memberInfoArray)`
Sorts member info by name/role/status.

### `CommunitiesUtil.GetMemberIdsSortedByName(clubId, streamId)`
Returns member IDs sorted alphabetically.

### `CommunitiesUtil.GetMemberInfo(clubId, memberIds)`
Returns member info for a list of member IDs.

### `CommunitiesUtil.GetMemberInfoLookup(memberInfoArray)`
Creates a lookup table from member info array.

### `CommunitiesUtil.GetOnlineMembers(memberInfoArray)`
Filters member info to only online members.

### `CommunitiesUtil.SortMembersByList(memberInfoLookup, memberIds)`
Sorts members using a pre-existing ordering.

### `CommunitiesUtil.GetAndSortMemberInfo(clubId, streamId, filterOffline)`
Gets and sorts member info, optionally filtering offline members.

### `CommunitiesUtil.DoesAnyCommunityHaveUnreadMessages()`
Returns true if any community has unread messages.

### `CommunitiesUtil.DoesOtherCommunityHaveUnreadMessages(ignoreClubId)`
Returns true if any community other than `ignoreClubId` has unread messages.

### `CommunitiesUtil.DoesCommunityHaveUnreadMessages(clubId)`
Returns true if the specified community has unread messages.

### `CommunitiesUtil.DoesCommunityHaveOtherUnreadMessages(clubId, ignoreStreamId)`
Returns true if the community has unread messages in streams other than `ignoreStreamId`.

### `CommunitiesUtil.GetStreamNotificationSettingsLookup(clubId)`
Returns notification settings lookup table for a club's streams.

### `CommunitiesUtil.DoesCommunityStreamHaveUnreadMessages(clubId, streamId)`
Returns true if a specific stream has unread messages.

### `CommunitiesUtil.CanKickClubMember(clubPrivileges, memberInfo)`
Returns true if the current player can kick the specified member.

### `CommunitiesUtil.ClearAllUnreadNotifications(clubId)`
Marks all notifications in a club as read.

### `CommunitiesUtil.OpenInviteDialog(clubId, streamId)`
Opens the invite dialog for a community.

### `CommunitiesUtil.FindCommunityAndStreamByName(communityName, streamName)`
Finds a community and stream by their localized names.

### `CommunitiesUtil.FindGuildStreamByType(clubStreamType)`
Finds a guild stream by its type.

### `CommunitiesUtil.GetRoleSpecClassLine(classID, specID)`
Returns a formatted role/spec/class description line.

### `CommunitiesUtil.AddLookingForLines(tooltip, recruitingSpecIds, recruitingSpecIdMap, playerSpecs)`
Adds "Looking For" spec requirement lines to a tooltip.

---

## CovenantUtil

Source: [CovenantUtil (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=GetRenownRewardDisplayData)

### `CovenantUtil.GetRenownRewardDisplayData(rewardInfo, onItemUpdateCallback)`
Returns display data (name, icon, etc.) for a renown reward.

### `CovenantUtil.GetUnformattedRenownRewardInfo(rewardInfo, onItemUpdateCallback)`
Returns raw unformatted info for a renown reward.

### `CovenantUtil.GetRenownRewardInfo(rewardInfo, onItemUpdateCallback)`
Returns formatted renown reward info.

---

## CurrencyContainerUtil

Source: [CurrencyContainerUtil (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=GetCurrencyContainerInfo)

### `CurrencyContainerUtil.GetCurrencyContainerInfo(currencyID, numItems, name, texture, quality)`
Returns container display info for a currency at a specific quantity.

### `CurrencyContainerUtil.GetCurrencyContainerInfoForAlert(currencyID, quantity, name, texture, quality)`
Returns container display info for currency alerts.

---

## DifficultyUtil

Source: [DifficultyUtil (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=GetDifficultyName)

### `DifficultyUtil.GetDifficultyName(difficultyID)`
Returns the localized name of a dungeon/raid difficulty.

```lua
local name = DifficultyUtil.GetDifficultyName(16)  -- "Mythic"
```

### `DifficultyUtil.IsPrimaryRaid(difficultyID)`
Returns true if the difficulty is a primary raid difficulty (Normal, Heroic, Mythic).

### `DifficultyUtil.GetNextPrimaryRaidDifficultyID(difficultyID)`
Returns the next higher raid difficulty ID.

### `DifficultyUtil.GetMaxPlayers(difficultyID)`
Returns the max player count for a difficulty.

---

## ItemRef

Source: [ItemRef (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=SetItemRef)

Functions for handling hyperlink clicks and generating link strings.

### `SetItemRef(link, text, button, chatFrame)`
Handles item/spell/achievement link tooltip display when a hyperlink is clicked in chat.

```lua
SetItemRef("item:12345", "|cff0070dd[Cool Item]|r", "LeftButton")
```

### `GetFixedLink(text, quality)`
Returns a properly formatted hyperlink string.

### `GetBattlePetAbilityHyperlink(abilityID, maxHealth, power, speed)`
Generates a hyperlink for a battle pet ability.

### `GetPlayerLink(characterName, linkDisplayText, lineID, chatType, chatTarget)`
Generates a player name hyperlink.

### `GetBNPlayerLink(name, linkDisplayText, bnetIDAccount, lineID, chatType, chatTarget)`
Generates a Battle.net player hyperlink.

### `GetGMLink(gmName, linkDisplayText, lineID)`
Generates a GM (Game Master) name hyperlink.

### `GetBNPlayerCommunityLink(playerName, linkDisplayText, bnetIDAccount, clubId, streamId, epoch, position)`
Generates a Battle.net player community hyperlink.

### `GetPlayerCommunityLink(playerName, linkDisplayText, clubId, streamId, epoch, position)`
Generates a player community hyperlink.

### `GetClubTicketLink(ticketId, clubName, clubType)`
Generates a community invite ticket hyperlink.

### `GetClubFinderLink(clubFinderId, clubName)`
Generates a club finder hyperlink.

### `GetCalendarEventLink(monthOffset, monthDay, index)`
Generates a calendar event hyperlink.

### `GetCommunityLink(clubId)`
Generates a community hyperlink.

### `LinkUtil.SplitLink(link)`
Splits a hyperlink into its component parts.

### `LinkUtil.ExtractLink(text)`
Extracts the hyperlink portion from a text string.

### `LinkUtil.IsLinkType(link, matchLinkType)`
Checks if a link is of a specific type (e.g., "item", "spell", "achievement").

```lua
if LinkUtil.IsLinkType(link, "item") then ... end
```

---

## ItemUtil

Source: [ItemUtil (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=GetItemDetails)

### `ItemUtil.GetItemDetails(itemLink, quantity, isCurrency, lootSource)`
Returns comprehensive item details for display.

### `ItemUtil.PickupBagItem(itemLocation)`
Picks up an item from a bag using an ItemLocationMixin.

### `ItemUtil.GetOptionalReagentCount(itemID)`
Returns the count of optional reagents for a recipe item.

### `ItemButtonUtil.GetItemContext()`
Returns the current item context for item button highlighting.

### `ItemButtonUtil.HasItemContext()`
Returns true if an item context is currently active.

### `ItemButtonUtil.GetItemContextMatchResultForItem(itemLocation)`
Returns whether an item matches the current item context.

### `ItemButtonUtil.GetItemContextMatchResultForContainer(bagID)`
Returns whether a container matches the current item context.

### `ItemButtonUtil.RegisterCallback(...)`
Registers a callback for item button events.

### `ItemButtonUtil.UnregisterCallback(...)`
Unregisters an item button callback.

### `ItemButtonUtil.TriggerEvent(...)`
Triggers an item button event.

---

## MapUtil

Source: [MapUtil (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=IsMapTypeZone)

### `MapUtil.IsMapTypeZone(mapID)`
Returns true if the map type is a zone.

### `MapUtil.GetMapParentInfo(mapID, mapType, topMost)`
Returns parent map info for a given map, optionally filtering by type.

### `MapUtil.ShouldMapTypeShowQuests(mapType)`
Returns true if quests should be shown on this map type.

### `MapUtil.ShouldShowTask(mapID, info)`
Returns true if a world quest/task should be shown on the given map.

### `MapUtil.MapHasUnlockedBounties(mapID)`
Returns true if the map has any unlocked bounties (emissary quests).

### `MapUtil.MapHasEmissaries(mapID)`
Returns true if the map has active emissary quests.

### `MapUtil.FindBestAreaNameAtMouse(mapID, normalizedCursorX, normalizedCursorY)`
Returns the best matching area name at the mouse cursor position on the world map.

### `MapUtil.GetDisplayableMapForPlayer()`
Returns the most appropriate map ID to display for the player's current location.

### `MapUtil.GetBountySetMaps(bountySetID)`
Returns maps associated with a bounty set.

### `MapUtil.GetMapCenterOnMap(mapID, topMapID)`
Returns the center coordinates of a child map relative to a parent map.

### `MapUtil.IsChildMap(mapID, ancestorMapID)`
Returns true if `mapID` is a child of `ancestorMapID`.

### `MapUtil.IsOribosMap(mapID)`
Returns true if the map is Oribos.

### `MapUtil.IsShadowlandsZoneMap(mapID)`
Returns true if the map is a Shadowlands zone.

### `MapUtil.MapShouldShowWorldQuestFilters(mapID)`
Returns true if world quest filters should be shown on this map.

---

## PartyUtil

Source: [PartyUtil (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=GetMinLevel)

### `PartyUtil.GetMinLevel()`
Returns the minimum level player in the party/raid.

### `PartyUtil.GetPhasedReasonString(phaseReason, unitToken)`
Returns a localized string explaining why a party member is phased.

### `GetGroupMemberCountsForDisplay()`
Returns formatted group member counts for UI display.

---

## PlayerUtil

Source: [PlayerUtil (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=GetCurrentSpecID)

### `PlayerUtil.GetCurrentSpecID()`
Returns the player's current specialization ID.

```lua
local specID = PlayerUtil.GetCurrentSpecID()
```

### `PlayerUtil.GetSpecName()`
Returns the localized name of the player's current specialization.

### `PlayerUtil.GetSpecNameBySpecID(specID)`
Returns the localized name for a given specialization ID.

### `PlayerUtil.GetSpecIconBySpecID(specID)`
Returns the icon texture for a given specialization ID.

### `PlayerUtil.ShouldUseNativeFormInModelScene()`
Returns true if the player should use their native form in model scenes (Druid, etc.).

### `PlayerUtil.GetClassID()`
Returns the player's class ID.

### `PlayerUtil.GetClassName()`
Returns the localized class name.

### `PlayerUtil.GetClassInfo()`
Returns class info table for the player.

### `PlayerUtil.GetClassFile()`
Returns the class file token (e.g., `"WARRIOR"`).

### `PlayerUtil.GetClassColor()`
Returns the player's class color as a ColorMixin.

### `PlayerUtil.CanUseClassTalents()`
Returns true if the player can access the talent system.

### `PlayerUtil.HasFriendlyReaction()`
Returns true if the player has a friendly reaction (useful for faction-specific logic).

---

## PVPUtil

Source: [PVPUtil (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=GetTierName)

### `PVPUtil.GetTierName(tierEnum)`
Returns the localized name of a PvP tier (e.g., "Combatant", "Rival", "Duelist", "Gladiator").

### `PVPUtil.ShouldShowLegacyRewards()`
Returns true if legacy PvP rewards should be displayed.

---

## QuestUtils

Source: [QuestUtils (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=GetWorldQuestAtlasInfo)

### `QuestUtil.GetWorldQuestAtlasInfo(worldQuestType, inProgress, tradeskillLineID)`
Returns atlas info for a world quest icon.

### `QuestUtil.GetQuestIconOffer(isLegendary, frequency, isRepeatable, isCampaign, isCovenantCalling)`
Returns the appropriate quest offer icon based on quest properties.

### `QuestUtil.ApplyQuestIconOfferToTexture(texture, ...)`
Applies a quest offer icon to a texture region.

### `QuestUtil.GetQuestIconActive(isComplete, isLegendary, frequency, isRepeatable, isCampaign, isCovenantCalling)`
Returns the appropriate active quest icon.

### `QuestUtil.ApplyQuestIconActiveToTexture(texture, ...)`
Applies an active quest icon to a texture region.

### `QuestUtil.ShouldQuestIconsUseCampaignAppearance(questID)`
Returns true if quest icons should use campaign styling.

### `QuestUtil.GetQuestIconOfferForQuestID(questID)`
Returns the offer icon for a specific quest.

### `QuestUtil.ApplyQuestIconOfferToTextureForQuestID(texture, ...)`
Applies the offer icon for a specific quest to a texture.

### `QuestUtil.GetQuestIconActiveForQuestID(questID)`
Returns the active icon for a specific quest.

### `QuestUtil.ApplyQuestIconActiveToTextureForQuestID(texture, ...)`
Applies the active icon for a specific quest to a texture.

### `QuestUtil.SetupWorldQuestButton(button, info, inProgress, selected, isCriteria, isSpellTarget, isEffectivelyTracked)`
Configures a world quest button with appropriate icon, border, and state.

---

## RuneforgeUtil

Source: [RuneforgeUtil (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=GetCostsString)

### `RuneforgeUtil.GetCostsString(costs)`
Returns a formatted string for runeforge crafting costs.

### `RuneforgeUtil.IsUpgradeableRuneforgeLegendary(itemLocation)`
Returns true if the item at the location is an upgradeable runeforge legendary.

### `RuneforgeUtil.GetRuneforgeFilterText(filter)`
Returns localized filter text for the runeforge UI.

### `RuneforgeUtil.GetPreviewClassAndSpec()`
Returns class and spec info for runeforge previews.

---

## TitleUtil

Source: [TitleUtil (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=GetNameFromTitleMaskID)

### `TitleUtil.GetNameFromTitleMaskID(titleMaskID)`
Returns the localized title name from a title mask ID.

```lua
local titleName = TitleUtil.GetNameFromTitleMaskID(42)
```

---

## TransmogUtil

Source: [TransmogUtil (FrameXML)](https://github.com/Gethe/wow-ui-source/search?q=GetInfoForEquippedSlot)

### `TransmogUtil.GetInfoForEquippedSlot(transmogLocation)`
Returns transmog info for an equipped slot.

### `TransmogUtil.CanEnchantSource(sourceID)`
Returns true if a transmog source can receive an enchant illusion.

### `TransmogUtil.GetWeaponInfoForEnchant(transmogLocation)`
Returns weapon info needed for applying an enchant illusion.

### `TransmogUtil.GetBestWeaponInfoForIllusionDressup()`
Returns the best weapon for illusion preview in the dressing room.

### `TransmogUtil.GetSlotID(slotName)`
Converts a slot name string to a numeric slot ID.

```lua
local slotID = TransmogUtil.GetSlotID("HEADSLOT")
```

### `TransmogUtil.GetSlotName(slotID)`
Converts a numeric slot ID to a slot name string.

### `TransmogUtil.CreateTransmogLocation(slotDescriptor, transmogType, modification)`
Creates a TransmogLocationMixin object.

### `TransmogUtil.GetTransmogLocation(slotDescriptor, transmogType, modification)`
Gets or creates a cached TransmogLocationMixin.

### `TransmogUtil.GetTransmogLocationLookupKey(slotID, transmogType, modification)`
Returns a lookup key for transmog location caching.

### `TransmogUtil.GetSetIcon(setID)`
Returns the icon texture for a transmog set.

---

## EquipmentManager

Source: [FrameXML functions — EquipmentManager](https://warcraft.wiki.gg/wiki/FrameXML_functions#EquipmentManager)

### `EquipmentManager_UnpackLocation(location)`
Detailed Reference: [API EquipmentManager_UnpackLocation](https://warcraft.wiki.gg/wiki/API_EquipmentManager_UnpackLocation)

Unpacks a location integer (from equipment set data) to determine the actual inventory location (player, bank, bags, etc.).

```lua
local player, bank, bags, voidStorage, slot, bag = EquipmentManager_UnpackLocation(location)
```

**Returns:**
- `player` (boolean) — Item is on the player.
- `bank` (boolean) — Item is in the bank.
- `bags` (boolean) — Item is in a bag.
- `voidStorage` (boolean) — Item is in void storage.
- `slot` (number) — Slot index.
- `bag` (number) — Bag ID (if in bags).
