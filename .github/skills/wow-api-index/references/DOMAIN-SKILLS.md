# Domain Skills — Detailed API Tables

> **Parent skill:** [wow-api-index](../SKILL.md)

Each section below documents one domain skill: its scope, the API systems it
covers, and the key functions in each system.

## Skill Status Legend

| Status | Meaning |
|--------|---------|
| :white_check_mark: | Skill exists and is documented |
| :construction: | Skill planned but not yet created |

---

## wow-addon-structure :construction:

**Scope:** Addon file structure, TOC format, loading lifecycle, SavedVariables, file organization

| Topic |
|-------|
| TOC file directives (Interface, Title, Notes, Dependencies, etc.) |
| SavedVariables and SavedVariablesPerCharacter |
| Addon loading order and lifecycle events |
| File organization patterns |
| Embedding libraries |

---

## wow-api-widget :white_check_mark:

**Scope:** Widget API, widget hierarchy, all frame/region/texture/font/animation types

| API System | Key Functions |
|------------|--------------|
| **FrameScript** | `CreateFrame`, `CreateFromMixins`, `Mixin`, `RunScript`, `RegisterEventCallback`, `UnregisterEventCallback` |
| **UI** | UI utility functions |
| **UIColor** | `C_UIColor.GetColors` |
| **UIFrameManager** | `C_FrameManager.GetFrameVisibilityState` |
| **UIEventToastManagerInfo** | `C_EventToastManager.GetNextToastToDisplay`, `RemoveCurrentToast` |
| **UITimer** | Timer management for UI |
| **UIWidgetManager** | `C_UIWidgetManager` namespace |
| **UISystemVisibilityManager** | System visibility management |
| **UIModifiedInstance** | Modified instance UI info |
| **UIMacros** | Macro-related UI functions |
| **XMLUtil** | `C_XMLUtil.GetTemplateInfo`, `C_XMLUtil.GetTemplates` |
| **SystemInfo** | `C_System.GetFrameStack` |
| **ColorUtil** | Color utility functions |
| **ColorOverrides** | Color override system |
| **TextureUtils** | Texture utility helpers |
| **Widget API** | Frame, Button, EditBox, FontString, Texture, ScrollFrame, etc. methods |
| **Widget Scripts** | OnEvent, OnUpdate, OnClick, OnShow, OnHide, etc. |
| **Categories: Widgets** | `CreateFrame`, `CreateFont`, `EnumerateFrames`, `GetFrameMetatable`, etc. |

---

## wow-api-unit-player :construction:

**Scope:** Unit functions, player info, auras, roles, death info

| API System | Key Functions |
|------------|--------------|
| **Unit** | `UnitName`, `UnitHealth`, `UnitHealthMax`, `UnitPower`, `UnitLevel`, `UnitClass`, `UnitRace`, `UnitGUID`, `UnitExists`, `UnitIsPlayer`, `UnitIsDead`, `UnitAffectingCombat`, `UnitXP`, `UnitXPMax`, and ~100+ more |
| **UnitAuras** | `C_UnitAuras.GetAuraDataByIndex`, `GetAuraDataByAuraInstanceID`, `GetPlayerAuraBySpellID`, `WantsAlteredForm`, etc. |
| **UnitRole** | `UnitGetAvailableRoles`, `UnitSetRole`, `CanShowSetRoleButton`, `InitiateRolePoll` |
| **PlayerInfo** | `C_PlayerInfo.CanPlayerEnterChromieTime`, `CanPlayerUseMountEquipment`, `GetAlternateFormInfo`, `CanUseItem`, etc. |
| **DeathInfo** | Death and ghost related functions |
| **DeathRecap** | `C_DeathRecap.GetRecapEvents`, `HasRecapEvents` |
| **SummonInfo** | `C_SummonInfo.GetSummonReason`, `IsSummonSkippingStartExperience` |
| **CreatureInfo** | Creature information functions |

---

## wow-api-spells-abilities :construction:

**Scope:** Spell system, spellbook, action bars, cooldowns, casting

| API System | Key Functions |
|------------|--------------|
| **Spell** | `C_Spell` namespace — spell info, casting, cooldowns |
| **SpellBook** | `C_SpellBook` namespace — spellbook access, known spells |
| **SpellActivationOverlay** | Spell activation overlay (procs) |
| **ActionBar** | `C_ActionBar.EnableActionRangeCheck`, `FindSpellActionButtons`, `ForceUpdateAction`, etc. |
| **AssistedCombat** | `C_AssistedCombat.GetActionSpell`, `GetNextCastSpell`, `GetRotationSpells`, `IsAvailable` |
| **CooldownViewer** | `C_CooldownViewer` namespace — cooldown tracking UI |
| **SpellDiminishUI** | `C_SpellDiminish` — diminishing returns tracking |
| **Categories: Spells** | `CastSpellByName`, `CastSpellByID`, `CancelUnitBuff`, `FindSpellBookSlotBySpellID`, etc. |
| **Categories: Shapeshifting** | `GetShapeshiftFormInfo`, `CancelShapeshiftForm`, `GetNumShapeshiftForms` |
| **Categories: Action Buttons** | `GetActionInfo`, `UseAction`, `GetFlyoutInfo`, `GetPossessInfo` |
| **Totem** | Totem information functions |

---

## wow-api-items-inventory :construction:

**Scope:** Item system, bags, bank, loot, equipment

| API System | Key Functions |
|------------|--------------|
| **Item** | `C_Item.GetItemInfo`, `GetItemName`, `GetItemLink`, `GetItemIcon`, `GetItemQuality`, `IsItemInRange`, `GetItemLevel`, `GetItemUpgradeInfo`, `GetSetBonusesForSpecializationByItemID`, etc. |
| **Container** | `C_Container` namespace — bag slot access, item movement |
| **Bank** | `C_Bank` namespace — bank access |
| **Loot** | `C_Loot.GetLootRollDuration`, `IsLegacyLootModeEnabled` |
| **Categories: Looting** | `GetLootSlotInfo`, `LootSlot`, `GetNumLootItems`, `RollOnLoot`, `ConfirmLootRoll`, etc. |
| **Categories: Bags** | Bag-related category functions |
| **Categories: Inventory** | Equipment and inventory management |
| **Categories: Merchants** | `BuyMerchantItem`, `GetMerchantItemInfo`, trainer functions |
| **WorldLootObject** | World loot object interaction |

---

## wow-api-combat :construction:

**Scope:** Combat log, threat, damage meters, loss of control

| API System | Key Functions |
|------------|--------------|
| **CombatLog** | `C_CombatLog.ApplyFilterSettings`, `ClearEntries`, `DoesObjectMatchFilter`, etc. |
| **CombatText** | Combat text display functions |
| **CombatAudioAlert** | Combat audio alert system |
| **Threat** | Threat-related functions |
| **DamageMeter** | Damage meter system functions |
| **LossOfControl** | `C_LossOfControl.GetActiveLossOfControlData`, `GetActiveLossOfControlDataCount`, etc. |
| **SecretUtil** | `C_Secrets` — spell secrecy system |
| **CommentatorFrame** | `C_Commentator` — spectator/esports functions |

---

## wow-api-quests :construction:

**Scope:** Quest log, quest info, quest offers, content tracking

| API System | Key Functions |
|------------|--------------|
| **QuestLog** | `C_QuestLog.GetInfo`, `GetTitleForQuestID`, `GetNumQuestLogEntries`, `IsQuestFlaggedCompleted`, `GetZoneStoryInfo`, `IsAccountQuest`, etc. |
| **QuestInfoSystem** | `C_QuestInfoSystem.GetQuestClassification`, `GetQuestRewardCurrencies`, `GetQuestRewardSpells`, etc. |
| **QuestOffer** | `C_QuestOffer.GetQuestOfferMajorFactionReputationRewards`, `GetQuestRequiredCurrencyInfo`, etc. |
| **ContentTracking** | `C_ContentTracking` namespace |
| **Categories: Quests** | `AcceptQuest`, `CompleteQuest`, `GetQuestObjectiveInfo`, `QuestIsDaily`, `QuestIsWeekly`, `GetQuestReward`, etc. |
| **Categories: Quest Gossip** | `GetNumActiveQuests`, `GetNumAvailableQuests`, `SelectActiveQuest`, `SelectAvailableQuest` |

---

## wow-api-map-navigation :construction:

**Scope:** Map system, area POIs, taxi, waypoints, vignettes, zone scripts

| API System | Key Functions |
|------------|--------------|
| **AreaPoiInfo** | `C_AreaPoiInfo.GetDelvesForMap`, `GetEventsForMap`, `GetQuestHubsForMap`, etc. |
| **TaxiMap** | `C_TaxiMap` namespace |
| **Vignette** | Vignette (minimap markers) functions |
| **SuperTrackManager** | Supertracking/waypoint system |
| **ZoneAbility** | Zone-specific ability functions |
| **ZoneScript** | Zone script functions |
| **Categories: Flight Master** | `NumTaxiNodes`, `TakeTaxiNode`, `CloseTaxiMap`, etc. |

---

## wow-api-social-chat :construction:

**Scope:** Chat system, clubs/communities, friends, voice chat, BattleNet

| API System | Key Functions |
|------------|--------------|
| **ChatInfo** | `C_ChatInfo` namespace — chat channels, messages |
| **ChatBubbles** | Chat bubble functions |
| **Club** | `C_Club` — communities system (30+ functions) |
| **ClubFinderInfo** | `C_ClubFinder` — community/guild finder (30+ functions) |
| **FriendList** | `C_FriendList` — friends, /who, etc. |
| **VoiceChat** | `C_VoiceChat` — voice communication (20+ functions) |
| **BattleNet** | `C_BattleNet` namespace |
| **SocialRestrictions** | Social restriction functions |
| **Categories: Chat** | `SendChatMessage`, `JoinChannelByName`, `GetChannelName`, `LoggingChat`, etc. |
| **Categories: Chat Window** | `GetChatWindowInfo`, `AddChatWindowMessages`, etc. |
| **Categories: Battle.net** | `BNGetNumFriends`, `BNGetInfo`, `BNConnected`, etc. |

---

## wow-api-guild :construction:

**Scope:** Guild management, guild bank, guild info

| API System | Key Functions |
|------------|--------------|
| **Categories: Guild** | `GetGuildInfo`, `GetGuildRosterInfo`, `GetNumGuildMembers`, `GuildRosterSetPublicNote`, `CanGuildInvite`, etc. |
| **Categories: Guild Bank** | `GetGuildBankItemInfo`, `GetGuildBankMoney`, `GetGuildBankTabInfo`, `AutoStoreGuildBankItem`, etc. |

---

## wow-api-group-lfg :construction:

**Scope:** Party info, dungeon finder, premade groups, social queue

| API System | Key Functions |
|------------|--------------|
| **PartyInfo** | `C_PartyInfo.LeaveParty`, `DoCountdown`, `GetLootMethod`, `IsPartyFull`, `DelveTeleportOut`, etc. |
| **LFGInfo** | `C_LFGInfo.CanPlayerUseLFD`, `GetDungeonInfo`, `GetAllEntriesForCategory`, etc. |
| **LFGList** | `C_LFGList.CreateListing`, `Search`, `GetSearchResults`, `GetActiveEntryInfo`, `GetApplicants`, etc. |
| **SocialQueue** | `C_SocialQueue.GetGroupQueues`, `RequestToJoin` |
| **Categories: Groups** | `AcceptGroup`, `IsInGroup`, `IsInRaid`, `GetNumGroupMembers`, `UninviteUnit`, etc. |
| **Categories: Group Finder** | `JoinLFG`, `LeaveLFG`, `LFGTeleport`, `GetLFGQueueStats`, `AcceptProposal`, etc. |

---

## wow-api-pvp :construction:

**Scope:** PvP, battlegrounds, arenas, war mode, rated PvP

| API System | Key Functions |
|------------|--------------|
| **PvpInfo** | `C_PvP.IsWarModeActive`, `IsRatedArena`, `IsBattleground`, `GetActiveBrawlInfo`, `JoinBattlefield`, `GetScoreInfo`, `ArePvpTalentsUnlocked`, etc. |
| **Categories: PvP** | `AcceptBattlefieldPort`, `AcceptDuel`, `CancelDuel`, `StartDuel`, `LeaveBattlefield`, `JoinSkirmish`, `RequestBattlefieldScoreData`, etc. |
| **Categories: War Games** | `StartWarGame`, `IsWargame`, etc. |

---

## wow-api-professions :construction:

**Scope:** Tradeskill UI, crafting orders, recipes, profession info

| API System | Key Functions |
|------------|--------------|
| **TradeSkillUI** | `C_TradeSkillUI.GetBaseProfessionInfo`, `GetCategories`, `GetRecipeInfo`, `GetRecipeSchematic`, `CraftRecipe`, etc. |
| **CraftingOrderUI** | `C_CraftingOrders.GetCustomerCategories`, `GetMyOrders`, `PlaceNewOrder`, etc. |
| **Categories: Professions** | Legacy profession functions still in the API |

---

## wow-api-collections :construction:

**Scope:** Mounts, pets, pet battles, toys

| API System | Key Functions |
|------------|--------------|
| **MountJournal** | `C_MountJournal.GetMountInfoByID`, `GetNumDisplayedMounts`, `SummonByID`, `IsDragonridingUnlocked`, etc. |
| **PetJournalInfo** | `C_PetJournal.GetPetInfoByPetID`, `GetNumPets`, `GetPetAbilityInfo`, `SummonPetByGUID`, etc. |
| **PetBattles** | `C_PetBattles.GetNumPets`, `GetPetType`, `GetAbilityInfo`, etc. |
| **ToyBoxInfo** | `C_ToyBoxInfo.ClearFanfare`, `NeedsFanfare`, etc. |
| **StableInfo** | Stable/pet stable functions |
| **Categories: Combat Pets** | `PetAttack`, `PetDefensiveMode`, `HasPetUI`, `GetPetExperience`, etc. |
| **Categories: Toys** | `PlayerHasToy`, `UseToy` |

---

## wow-api-transmog :construction:

**Scope:** Transmogrification, appearances, sets, outfits, dye colors

| API System | Key Functions |
|------------|--------------|
| **Transmogrify** | Core transmog functions |
| **TransmogrifyCollection** | `C_TransmogCollection.GetAppearanceSources`, `GetCategoryAppearances`, `GetIllusions`, `PlayerHasTransmog`, etc. |
| **TransmogrifySets** | `C_TransmogSets.GetAllSets`, `GetUsableSets`, `GetSetInfo`, etc. |
| **TransmogOutfitInfo** | `C_TransmogOutfitInfo` — outfit management |
| **DyeColorInfo** | `C_DyeColor.GetAllDyeColors`, `GetDyeColorInfo`, `IsDyeColorOwned`, etc. |
| **BarberShop** | `C_BarberShop.ApplyCustomizationChoices`, `GetAvailableCustomizations`, etc. |

---

## wow-api-achievements :construction:

**Scope:** Achievement system, statistics

| API System | Key Functions |
|------------|--------------|
| **AchievementInfo** | `C_AchievementInfo` namespace |
| **AchievementTelemetry** | Achievement telemetry |
| **Categories: Achievements** | `GetAchievementInfo`, `GetAchievementCriteriaInfo`, `GetAchievementLink`, `GetTotalAchievementPoints`, etc. |
| **Categories: Statistics** | `GetStatistic`, `GetStatisticsCategoryList` |

---

## wow-api-calendar-events :construction:

**Scope:** Calendar system, event scheduler

| API System | Key Functions |
|------------|--------------|
| **Calendar** | `C_Calendar.OpenCalendar`, `GetDayEvent`, `CreatePlayerEvent`, `GetMonthInfo`, `GetEventInfo`, etc. (50+ functions) |
| **EventSchedulerUI** | `C_EventScheduler.GetScheduledEvents`, `GetOngoingEvents`, `CanShowEvents`, etc. |

---

## wow-api-encounters :construction:

**Scope:** Encounter journal, encounter timeline, challenge mode, instances

| API System | Key Functions |
|------------|--------------|
| **EncounterJournal** | `C_EncounterJournal.GetEncounterInfo`, `GetLootInfo`, `GetSectionInfo`, `IsEncounterComplete`, etc. |
| **EncounterTimeline** | `C_EncounterTimeline.AddScriptEvent`, `GetCurrentTime`, `GetEventList`, `IsFeatureEnabled`, etc. |
| **ChallengeModeInfo** | `C_ChallengeMode` — Mythic+ info |
| **InstanceEncounter** | `C_InstanceEncounter.IsEncounterInProgress`, etc. |
| **InstanceLeaverInfo** | `C_InstanceLeaver.IsPlayerLeaver` |
| **Categories: Encounter Journal** | `EJ_GetEncounterInfo`, `EJ_GetInstanceByIndex`, `EJ_GetNumLoot`, etc. |
| **Categories: Instance Locks** | `GetNumSavedInstances`, `GetSavedInstanceInfo`, `RequestRaidInfo` |

---

## wow-api-reputation :construction:

**Scope:** Reputation system, major factions

| API System | Key Functions |
|------------|--------------|
| **ReputationInfo** | `C_Reputation.GetFactionDataByID`, `GetWatchedFactionData`, `GetNumFactions`, `IsAccountWideReputation`, `IsMajorFaction`, etc. |
| **MajorFactions** | `C_MajorFactions` namespace (if separate) |
| **NeighborhoodInitiative** | `C_NeighborhoodInitiative.GetNeighborhoodInitiativeInfo`, `IsInitiativeEnabled`, etc. |

---

## wow-api-currency-economy :construction:

**Scope:** Currency, auction house, tokens, stores

| API System | Key Functions |
|------------|--------------|
| **CurrencySystem** | `C_CurrencyInfo` namespace — currency info, tracking |
| **AuctionHouse** | `C_AuctionHouse` namespace — auction operations |
| **AccountStore** | `C_AccountStore.BeginPurchase`, `GetCategories`, `GetCurrencyAvailable`, etc. |
| **CatalogShop** | `C_CatalogShop` — in-game store (30+ functions) |
| **WowTokenUI** | `C_WowTokenUI.StartTokenSell` |
| **StorePublic** | Store public functions |
| **PerksProgram** | `C_PerksProgram` — trading post (10+ functions) |
| **BlackMarketInfo** | Black market AH functions |
| **Categories: Trading** | Player-to-player trading |

---

## wow-api-talents :construction:

**Scope:** Class talents, hero talents, traits, specialization

| API System | Key Functions |
|------------|--------------|
| **ClassTalents** | `C_ClassTalents` namespace |
| **SharedTraits** | `C_Traits.CanEditConfig`, `GetNodeInfo`, `GetConfigInfo`, `GetTreeInfo`, `PurchaseRank`, etc. |
| **SpecializationInfo** | `C_SpecializationInfo` namespace |
| **SpecializationShared** | Shared specialization functions |
| **Categories: Specialization** | `GetNumSpecializations`, `GetSpecializationInfo`, `GetMaxTalentTier`, etc. |

---

## wow-api-settings-system :white_check_mark:

**Scope:** CVars, console, settings, sound, video, client info, build

| API System | Key Functions |
|------------|--------------|
| **CVarScripts** | CVar get/set functions |
| **Console** | Console command functions |
| **SettingsUtil** | `C_SettingsUtil.OpenSettingsPanel` |
| **Sound** | `C_Sound` namespace |
| **Video** | Video settings functions |
| **Client** | Client information |
| **Build** | `C_Build` — build/version info |
| **Streaming** | Streaming-related functions |
| **TTSSettings** | Text-to-speech settings |
| **BehavioralMessaging** | Behavioral messaging system |
| **DateAndTime** | `C_DateAndTime` namespace |
| **SystemTime** | System time functions |
| **Categories: System** | `SendSystemMessage`, `IsGMClient`, `ProcessExceptionClient` |
| **Categories: Sound** | `PlaySound`, `PlaySoundFile`, `PlayMusic`, `StopMusic`, `MuteSoundFile` |
| **Categories: Graphics** | `GetCurrentGraphicsAPI`, `GetGraphicsAPIs`, etc. |
| **Categories: Key Bindings** | `GetBinding`, `SetBinding`, `GetBindingAction`, `SetOverrideBinding`, etc. |

---

## wow-api-housing :construction:

**Scope:** Player housing system (new in Patch 12.0)

| API System | Key Functions |
|------------|--------------|
| **Housing** (new) | Housing placement, decoration, neighborhood functions |
| **NeighborhoodInitiative** | `C_NeighborhoodInitiative` — community housing initiatives |
| **CatalogShop** (Housing-specific) | `C_CatalogShop.ConfirmHousingPurchase`, `OpenCatalogShopInteractionFromHouse`, `GetRefundableDecors` |

---

## wow-api-events :construction:

**Scope:** Game events reference and their payloads

| Topic |
|-------|
| Full event list with payload parameters |
| Event categories (Unit, Combat, UI, System, etc.) |
| `EventRegistry` and callback-based event handling |
| `C_EventUtils.IsEventValid`, `IsCallbackEvent` |
| Common event patterns and usage examples |

**Source:** https://warcraft.wiki.gg/wiki/Events

---

## wow-lua-api :white_check_mark:

**Scope:** Lua 5.1 base functions and standard libraries exposed in WoW, plus Blizzard-specific differences and WoW-only helpers

| Library / Topic | Key Functions |
|-----------------|--------------|
| **Basic functions** | `assert`, `collectgarbage`, `date`, `difftime`, `error`, `getfenv`, `setfenv`, `pairs`, `ipairs`, `pcall`, `xpcall`, `rawget`, `rawset`, `rawequal`, `type`, `tonumber`, `tostring`, `unpack`, `time` |
| **Math** | `abs`, `acos`, `asin`, `atan`, `atan2`, `sin`, `cos`, `tan`, `random`, `fastrandom`, `rad`, `deg`, `fmod`, `log`, `log10` |
| **String** | `format`, `gsub`, `gmatch`, `strfind`, `strlen`, `strsub`, `strupper`, `strlower`, plus WoW helpers like `strsplit`, `strtrim`, `strlenutf8`, `strjoin`, `strconcat`, `tostringall` |
| **Table** | `table.concat`, `table.insert`/`tinsert`, `table.remove`/`tremove`, `table.sort`, `table.maxn`, `table.create`, `table.removemulti`, `table.wipe` |
| **Bit** | `bit.bnot`, `bit.band`, `bit.bor`, `bit.bxor`, `bit.lshift`, `bit.rshift`, `bit.arshift`, `bit.mod` |
| **Coroutine** | `coroutine.create`, `coroutine.resume`, `coroutine.running`, `coroutine.status`, `coroutine.wrap`, `coroutine.yield` |
| **Deprecated** | `table.foreach`, `table.foreachi`, `table.getn`, `table.setn`, `string.gfind` |

---

## wow-api-lua-environment :construction:

**Scope:** WoW Lua specifics, restrictions, secure execution, taint system

| API System | Key Functions |
|------------|--------------|
| **RestrictedActions** | `C_RestrictedActions.CheckAllowProtectedFunctions`, `InCombatLockdown` |
| **FrameScript** | `RunScript`, `GetCallstackHeight`, `GetSourceLocation` |
| **Categories: Secure Execution** | `securecall`, `securecallfunction`, `issecurevalue`, `scrub`, `hooksecurefunc` |
| **Categories: Debugging** | `debugstack`, `debuglocals`, `geterrorhandler`, `seterrorhandler`, `print`, `DevTools_Dump` |
| **Categories: Environment** | `GetCurrentEnvironment`, `GetGlobalEnvironment`, `SwapToGlobalEnvironment` |
| **Taint System** | Secure vs. insecure code, taint propagation, `forceinsecure` |

---

## wow-api-escape-sequences :construction:

**Scope:** Text formatting, color codes, hyperlinks, atlas textures

| Topic |
|-------|
| Color escape sequences: `|cAARRGGBB...|r` |
| Texture/icon inline display: `|T...|t` and `|A...|a` (atlas) |
| Hyperlink format: `|H...|h[text]|h` |
| Hyperlink types: item, spell, achievement, quest, etc. |
| Line breaks, concatenation in formatted strings |

**Source:** https://warcraft.wiki.gg/wiki/Escape_sequences

---

## wow-api-weekly-rewards :construction:

**Scope:** Great Vault / weekly rewards system

| API System | Key Functions |
|------------|--------------|
| **WeeklyRewards** | `C_WeeklyRewards.GetActivities`, `CanClaimRewards`, `ClaimReward`, `GetActivityEncounterInfo`, etc. |

---

## wow-api-misc-systems :construction:

**Scope:** Miscellaneous API systems not large enough for their own skill

| API System | Key Functions |
|------------|--------------|
| **Tutorial** | `C_Tutorial.AbandonTutorialArea`, `ReturnToTutorialArea` |
| **ReportSystem** | `C_ReportSystem.CanReportPlayer`, `GetMajorCategoriesForReportType`, etc. |
| **ExternalEventURL** | `C_ExternalEventURL.HasURL`, `LaunchURL` |
| **SplashScreen** | Splash screen functions |
| **Cinematic** | `C_Cinematic` namespace |
| **ChromieTimeInfo** | `C_ChromieTime` functions |
| **AlliedRaces** | `C_AlliedRaces` functions |
| **UserFeedback** | User feedback functions |
| **WarbandSceneInfo** | Warband scene functions |
| **ResearchInfo** | `C_ResearchInfo.GetDigSitesForMap` |
| **Log** | `C_Log.LogMessage`, `LogErrorMessage`, `LogWarningMessage` |
| **EventUtils** | `C_EventUtils.IsEventValid`, `IsCallbackEvent` |
| **SlashCommand** | Slash command registration |
| **ClickBindings** | Click binding functions |
| **CurveUtil** | Curve utility functions |
| **StringUtil** | String utility functions |
| **Categories: Macros** | `CreateMacro`, `EditMacro`, `GetMacroInfo`, `GetNumMacros`, `SecureCmdOptionParse`, etc. |
| **Categories: Camera** | `GetCameraZoom`, `SetView`, `SaveView`, etc. |
| **Categories: Movement** | `MoveForwardStart/Stop`, `StrafeLeft/Right`, `Jump`, etc. (all `#protected`) |
| **Categories: Vehicles** | `VehicleExit`, `VehicleAimIncrement`, etc. |
| **Categories: Petitions** | `GetPetitionInfo`, `SignPetition`, `OfferPetition` |
| **Categories: Cinematics** | `CanCancelScene`, `CancelScene` |
| **Categories: Class** | `GetClassInfo`, `GetNumClasses`, `GetClassColor` |
| **Categories: Character** | `IsPlayerNeutral`, chat AFK/DND |
| **Categories: Cursor** | `SetCursor`, `ResetCursor`, `PlaceAction`, etc. |
| **Categories: Customer Support** | GM ticket functions |
| **Categories: Gamepad** | Gamepad control functions |
| **ConsoleScriptCollection** | `C_ConsoleScriptCollection` — console script data |
| **TimerunningUI** | Timerunning UI functions |
| **TooltipInfo** | `C_TooltipInfo` — tooltip data |
| **TooltipComparison** | Tooltip comparison functions |
| **WowSurvey** | Survey functions |
