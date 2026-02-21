# Slash Commands Reference

Complete reference for all WoW Retail macro slash commands organized by category.

> **Source:** https://warcraft.wiki.gg/wiki/Macro_commands

Command names are not case-sensitive. Multiple commands can be combined in a macro, one per line. Commands with multiple aliases are listed under the most expanded alias.

---

## Combat Commands

These commands pertain to casting, attacking, and combat actions.

| Command | Aliases | Description |
|---------|---------|-------------|
| `/cast` | `/use` | Cast a spell or use an item by name. Name conflicts: `/cast` favors spells, `/use` favors items. |
| `/castsequence` | | Cast spells/items in sequential order, advancing per click. |
| `/castrandom` | | Cast a random spell or use a random item from a comma-separated list. |
| `/userandom` | | Same as `/castrandom`. |
| `/usetoy` | | Use a toy by name. |
| `/cancelaura` | | Cancel (remove) a buff/aura by name. |
| `/cancelform` | | Cancel current shapeshift form. |
| `/cancelqueuedspell` | | Cancel the spell queued for casting. |
| `/startattack` | | Turn on auto-attack. |
| `/stopattack` | | Turn off auto-attack. |
| `/stopcasting` | | Stop current cast or channel. |
| `/stopspelltarget` | | Cancel the spell or ability currently being ground-targeted. |
| `/changeactionbar` | | Change current action bar to specified page number. |
| `/swapactionbar` | | Swap between two specified action bar pages. |

---

## Targeting Commands

These commands change or manipulate your current target or focus.

| Command | Description |
|---------|-------------|
| `/target` | Target a unit by name (closest match, not exact). |
| `/targetexact` | Target a unit by exact name match only. |
| `/targetenemy` | Cycle through nearby hostile units (like pressing TAB). Add `1` to reverse direction. |
| `/targetenemyplayer` | Cycle through nearby hostile players only. Add `1` to reverse. |
| `/targetfriend` | Cycle through nearby friendly units (like CTRL-TAB). Add `1` to reverse. |
| `/targetfriendplayer` | Cycle through nearby friendly players only. Add `1` to reverse. |
| `/targetparty` | Cycle through nearby party members. Add `1` to reverse. |
| `/targetraid` | Cycle through nearby raid members. Add `1` to reverse. |
| `/targetlastenemy` | Target the last attackable unit you had selected. |
| `/targetlastfriend` | Target the last friendly unit you had selected. |
| `/targetlasttarget` | Target the last unit you had selected (any type). |
| `/assist` | Target your target's target, or a named player's target. |
| `/focus` | Set focus to current target, or specify a unit/name. |
| `/clearfocus` | Clear the current focus target. |
| `/cleartarget` | Clear the current target. |

**Note:** `/targetenemy`, `/targetenemyplayer`, `/targetfriend`, `/targetfriendplayer`, `/targetparty`, and `/targetraid` can only be used **once per macro**.

---

## Character Commands

Commands affecting your character's status, social interaction, or actions.

| Command | Description |
|---------|-------------|
| `/dismount` | Dismount your character. |
| `/equip` | Equip an item to its default slot by name. |
| `/equipset` | Change equipped items to a set stored in the Equipment Manager. |
| `/equipslot` | Equip an item to a specific inventory slot ID. |
| `/friend` | Add a player to your Friends list. |
| `/follow` | Follow the selected target. |
| `/ignore` | Add a player to your ignore list. |
| `/inspect` | Open the Inspection interface for the selected target. |
| `/leavevehicle` | Exit your current vehicle. |
| `/randompet` | Summon a random companion pet (non-combat). |
| `/removefriend` | Remove a friend from your friends list. |
| `/settitle` | Set the active title for your character. |
| `/trade` | Open the trade interface with your current target. |
| `/unignore` | Remove a player from your ignore list. |

---

## Pet Commands (Combat Pets)

Commands for controlling hunter, warlock, and other combat pets.

| Command | Description |
|---------|-------------|
| `/petattack` | Send pet to attack current target (or specified unit). |
| `/petfollow` | Set pet to follow you. |
| `/petstay` | Set pet to stay at current location. |
| `/petmoveto` | Set pet to move to a ground-targeted location. |
| `/petpassive` | Set pet to passive mode. |
| `/petdefensive` | Set pet to defensive mode. |
| `/petassist` | Set pet to assist mode. |
| `/petdismiss` | Dismiss your pet. |
| `/petautocaston` | Turn on autocast for a pet spell by name. |
| `/petautocastoff` | Turn off autocast for a pet spell by name. |
| `/petautocasttoggle` | Toggle autocast for a pet spell by name. |

---

## Battle Pet Commands

Commands for non-combat battle pets.

| Command | Description |
|---------|-------------|
| `/randomfavoritepet` | Summon a random favorite battle pet. |
| `/summonpet` | Summon the specified battle pet by name. |
| `/dismisspet` | Dismiss your battle pet. |

---

## Chat Commands

Commands for sending messages and managing chat channels.

| Command | Aliases | Description |
|---------|---------|-------------|
| `/say` | `/s` | Send a message to nearby players. |
| `/yell` | `/y` | Send a message to all players in your zone. |
| `/whisper` | `/w`, `/tell`, `/t` | Send a private message to a player. |
| `/reply` | `/r` | Reply to the last whisper received. |
| `/party` | `/p` | Send a message to your party. |
| `/raid` | `/ra` | Send a message to your raid. |
| `/rw` | | Send a raid warning. |
| `/guild` | `/g` | Send a message to your guild. |
| `/officer` | `/o` | Send a message to guild officer channel. |
| `/battleground` | `/bg` | Send a message to your battleground. |
| `/emote` | `/e`, `/em`, `/me` | Perform a custom emote with given text. |
| `/afk` | | Mark as "Away From Keyboard". |
| `/dnd` | | Mark as "Do Not Disturb". |
| `/join` | | Join or create a user-created chat channel. |
| `/leave` | | Leave a user-created chat channel. |
| `/chatinvite` | | Invite a user to a chat channel. |
| `/chatlist` | | List users in a channel, or your current channels. |
| `/chatlog` | | Enable/disable chat logging. |
| `/combatlog` | | Enable/disable combat logging. |
| `/chathelp` | | Display common chat commands. |
| `/csay` | | Send chat to a channel by number. |
| `/ban` | | Ban a user from a user-created channel. |
| `/unban` | | Unban a user from a channel. |
| `/ckick` | | Kick a user from a channel. |
| `/mute` | | Prevent a user from speaking in a channel (voice or text). |
| `/unmute` | | Allow a user to speak in a channel. |
| `/moderator` | | Set moderation in a channel. |
| `/unmoderator` | | Remove moderation from a channel. |
| `/owner` | | Display or change the owner of a channel. |
| `/password` | | Set or remove a password on a channel. |
| `/announce` | | Toggle channel announcements. |
| `/resetchat` | | Reset chat settings to default. |

---

## Guild Commands

| Command | Description |
|---------|-------------|
| `/guildinvite` | Invite a player to your guild. |
| `/guildremove` | Remove a member from your guild. |
| `/guildquit` | Leave your current guild. |
| `/guilddisband` | Disband your guild. |
| `/guildpromote` | Promote a guild member one rank. |
| `/guilddemote` | Demote a guild member one rank. |
| `/guildleader` | Transfer Guild Master to another member. |
| `/guildmotd` | Set the guild Message of the Day. |
| `/guildinfo` | Display information about your guild. |
| `/guildroster` | Open the Guild window. |

---

## Party and Raid Commands

| Command | Description |
|---------|-------------|
| `/invite` | Invite a player to your party or raid. |
| `/uninvite` | Remove a player from your party or raid. |
| `/promote` | Promote a member to party/raid leader. |
| `/requestinvite` | Request an invite to a specified group. |
| `/readycheck` | Perform a ready check. |
| `/raidinfo` | Show saved instance IDs. |
| `/maintank` | Set a main tank. |
| `/maintankoff` | Clear the main tank. |
| `/mainassist` | Set a main assist. |
| `/mainassistoff` | Clear the main assist. |
| `/targetmarker` | Set or clear a target marker (raid icon) from your target. |
| `/worldmarker` | Place a world marker. |
| `/clearworldmarker` | Clear world markers. |
| `/ffa` | Set loot to Free-For-All. |
| `/group` | Set loot to Group Loot. |
| `/master` | Set loot to Master Loot. |
| `/threshold` | Set the loot quality threshold. |

---

## PvP Commands

| Command | Description |
|---------|-------------|
| `/duel` | Challenge another player to a duel. |
| `/forfeit` | Forfeit a duel. |
| `/pvp` | Toggle PvP attackable status. |
| `/wargame` | Start a War Game. |

---

## System Commands

| Command | Description |
|---------|-------------|
| `/console` | View or change global client-side options (CVars). |
| `/click` | Simulate a mouse click on a named button. |
| `/disableaddons` | Disable all addons and reload UI. |
| `/enableaddons` | Enable all addons and reload UI. |
| `/help` | Display basic command help. |
| `/macrohelp` | Display basic macro creation help. |
| `/logout` | Log out to character selection screen. |
| `/quit` | Exit the game. |
| `/played` | Display total time played for this character. |
| `/random` | Generate a random number. `/random X` for 1-X, `/random X Y` for X-Y. |
| `/reload` | Reload the UI. |
| `/script` (`/run`) | Execute a block of Lua code. |
| `/stopmacro` | Stop processing the current macro. |
| `/time` | Display the current time. |
| `/timetest` | Benchmarking tool, shows FPS. |
| `/who` | Search for online players matching filters. |

---

## Blizzard Interface Commands

These open parts of the Blizzard default UI.

| Command | Description |
|---------|-------------|
| `/achievements` | Open Achievements interface. |
| `/calendar` | Open Calendar interface. |
| `/dungeonfinder` | Open Dungeon Finder. |
| `/guildfinder` | Open Guild Finder. |
| `/loot` | Open loot history. |
| `/macro` | Open Macro interface. |
| `/raidfinder` | Open Raid Browser. |
| `/share` | Share to social media. |
| `/stopwatch` | Open Stopwatch interface. |

---

## DevTools Commands

| Command | Description |
|---------|-------------|
| `/api` | Query the WoW API documentation. |
| `/dump` | Display the value of a given Lua expression. |
| `/eventtrace` | Open the event trace tool. |
| `/framestack` | Show all frames under the cursor. |
| `/tableinspect` | Open the table inspector. |

---

## Metacommands

Metacommands are preceded by `#` (not `/`). They affect the macro's action bar button appearance. Unknown metacommands are silently ignored. Must be lowercase.

| Command | Description |
|---------|-------------|
| `#show` | Control the button's icon on the action bar. |
| `#showtooltip` | Control the button's icon AND tooltip on the action bar. |

**Notes:**
- Only one of `#show` or `#showtooltip` can be used per macro.
- Both support conditionals: `#showtooltip [mod:shift] Spell A; Spell B`
- Without parameters, WoW auto-picks from the first `/cast` or `/use` in the macro.

---

## Disabled Commands

These commands are recognized by the client but perform no action.

| Command | Description |
|---------|-------------|
| `/usetalents` | Change dual spec (no longer functional). |
| `/petaggressive` | Aggressive AI was replaced with assist (deprecated 4.2). |
