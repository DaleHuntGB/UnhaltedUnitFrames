---
name: wow-api-calendar-events
description: "Complete reference for WoW Retail Calendar and Event Scheduler APIs. Covers C_Calendar (event creation, editing, invites, holidays, raid resets, filtered events, date navigation, guild events, community events, texture lookups) and C_EventScheduler (scheduled event system). Use when working with the in-game calendar, creating events, managing invites, displaying holidays, or scheduling guild/community activities."
---

# Calendar & Events API (Retail — Patch 12.0.0)

Comprehensive reference for the in-game calendar and event scheduler.

> **Source:** https://warcraft.wiki.gg/wiki/World_of_Warcraft_API
> **Current as of:** Patch 12.0.0 (Build 65655) — January 28, 2026
> **Scope:** Retail only.

---

## Scope

- **C_Calendar** — Full calendar system (50+ functions)
- **C_EventScheduler** — Scheduled event management

---

## C_Calendar — Calendar System

### Opening & Navigation

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Calendar.OpenCalendar()` | — | Open/initialize calendar |
| `C_Calendar.CloseEvent()` | — | Close event editor |
| `C_Calendar.SetAbsMonth(month, year)` | — | Navigate to month |
| `C_Calendar.SetMonth(offsetMonths)` | — | Navigate relative |
| `C_Calendar.GetMonthInfo(offsetMonth)` | `monthInfo` | Month data |
| `C_Calendar.GetMinDate()` | `date` | Earliest navigable date |
| `C_Calendar.GetMaxDate()` | `date` | Latest navigable date |

### Month Info Fields

- `month` — Month number (1-12)
- `year` — Year
- `numDays` — Days in month
- `firstWeekday` — First day weekday (1=Sun)

### Day Events

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Calendar.GetNumDayEvents(offsetDay, monthOffset)` | `numEvents` | Events on day |
| `C_Calendar.GetDayEvent(offsetDay, eventIndex, monthOffset)` | `eventInfo` | Event at index |
| `C_Calendar.GetNumGuildEvents()` | `numEvents` | Guild events |
| `C_Calendar.GetGuildEventInfo(index)` | `eventInfo` | Guild event |

### Event Info Fields

- `title` — Event title
- `isCustomTitle` — Player-created?
- `startTime` — Start date/time
- `endTime` — End date/time
- `calendarType` — Type (PLAYER, GUILD_EVENT, SYSTEM, HOLIDAY, RAID_LOCKOUT, etc.)
- `sequenceType` — Sequence (START, ONGOING, END)
- `eventType` — Event type enum
- `texture` — Event texture
- `modStatus` — Moderator status
- `inviteStatus` — Invite status enum
- `invitedBy` — Who invited
- `difficulty` — Difficulty ID
- `inviteType` — Invite type
- `sequenceIndex` — Sequence index
- `numSequenceDays` — Total sequence days
- `difficultyName` — Difficulty name
- `isLocked` — Locked?

### Creating & Editing Events

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Calendar.CreatePlayerEvent()` | — | Start creating event |
| `C_Calendar.CreateGuildAnnouncement()` | — | Create guild announcement |
| `C_Calendar.CreateGuildSignUpEvent()` | — | Create sign-up event |
| `C_Calendar.CreateCommunitySignUpEvent()` | — | Community sign-up event |
| `C_Calendar.AddEvent()` | — | Submit new event |
| `C_Calendar.UpdateEvent()` | — | Update edited event |
| `C_Calendar.RemoveEvent()` | — | Delete event |
| `C_Calendar.OpenEvent(offsetDay, eventIndex, monthOffset)` | — | Open event for viewing |
| `C_Calendar.CanAddEvent()` | `canAdd` | Can create events? |

### Event Properties (Get/Set)

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Calendar.EventGetTitle()` | `title` | Get event title |
| `C_Calendar.EventSetTitle(title)` | — | Set event title |
| `C_Calendar.EventGetDescription()` | `description` | Get description |
| `C_Calendar.EventSetDescription(desc)` | — | Set description |
| `C_Calendar.EventGetDate()` | `date` | Get event date |
| `C_Calendar.EventSetDate(month, day, year)` | — | Set event date |
| `C_Calendar.EventGetTime()` | `hour, minute` | Get event time |
| `C_Calendar.EventSetTime(hour, minute)` | — | Set event time |
| `C_Calendar.EventGetType()` | `eventType` | Get event type |
| `C_Calendar.EventSetType(eventType)` | — | Set event type |
| `C_Calendar.EventGetRepeatOption()` | `repeatOption` | Repeat setting |
| `C_Calendar.EventSetRepeatOption(option)` | — | Set repeat |
| `C_Calendar.EventGetLocked()` | `isLocked` | Is locked? |
| `C_Calendar.EventSetLocked(locked)` | — | Lock/unlock |
| `C_Calendar.EventGetClubId()` | `clubId` | Associated club |
| `C_Calendar.EventSetClubId(clubId)` | — | Set club |

### Invites

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Calendar.EventGetNumInvites()` | `numInvites` | Invite count |
| `C_Calendar.EventGetInvite(index)` | `inviteInfo` | Invite data |
| `C_Calendar.EventInvite(name)` | — | Invite player |
| `C_Calendar.EventRemoveInvite(index)` | — | Remove invite |
| `C_Calendar.EventSetInviteStatus(index, status)` | — | Set invite status |
| `C_Calendar.EventSignUp()` | — | Sign up |
| `C_Calendar.EventDecline()` | — | Decline |
| `C_Calendar.EventTentative()` | — | Tentative |
| `C_Calendar.EventAvailable()` | — | Mark available |
| `C_Calendar.MassInviteGuild(minLevel, maxLevel, maxRank)` | — | Mass guild invite |
| `C_Calendar.MassInviteCommunity(clubId, minLevel, maxLevel)` | — | Mass community invite |
| `C_Calendar.GetEventInviteResponseTime(index)` | `time` | Response time |
| `C_Calendar.EventSortInvites(sortType, reverse)` | — | Sort invites |
| `C_Calendar.EventCanEdit()` | `canEdit` | Can edit event? |

### Invite Status Enums

| Value | Status |
|-------|--------|
| 1 | Invited |
| 2 | Accepted |
| 3 | Declined |
| 4 | Confirmed |
| 5 | Out |
| 6 | Standby |
| 7 | Signed Up |
| 8 | Not Signed Up |
| 9 | Tentative |

### Holidays

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Calendar.GetHolidayInfo(offsetDay, eventIndex, monthOffset)` | `holidayInfo` | Holiday data |
| `C_Calendar.GetNumHolidayTextures(offsetDay, eventIndex, monthOffset)` | `numTextures` | Holiday textures |

### Filtered Events

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Calendar.SetTextureToDefault()` | — | Reset texture filter |
| `C_Calendar.GetDefaultGuildFilter()` | `filter` | Default guild filter |
| `C_Calendar.EventGetTextures()` | `textures` | Event textures |
| `C_Calendar.EventGetSelectedInvite()` | `index` | Selected invite |
| `C_Calendar.EventSetSelectedInvite(index)` | — | Select invite |

### Raid Resets

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Calendar.GetNumRaidResets()` | `numResets` | Raid reset count |
| `C_Calendar.GetRaidReset(index)` | `resetInfo` | Reset info |

### Event Type Textures

| Function | Returns | Description |
|----------|---------|-------------|
| `C_Calendar.GetEventTypeTexture(eventType)` | `texture` | Texture for type |
| `C_Calendar.EventGetTypesDisplayOrdered()` | `types` | Ordered event types |

---

## C_EventScheduler — Scheduled Events

| Function | Returns | Description |
|----------|---------|-------------|
| `C_EventScheduler.GetScheduledEvents()` | `events` | All scheduled events |
| `C_EventScheduler.GetEventInfo(eventID)` | `eventInfo` | Event details |
| `C_EventScheduler.IsEventActive(eventID)` | `isActive` | Event active? |

---

## Common Patterns

### List Today's Events

```lua
C_Calendar.OpenCalendar()

local monthInfo = C_Calendar.GetMonthInfo(0)
local today = tonumber(date("%d"))

local numEvents = C_Calendar.GetNumDayEvents(today, 0)
for i = 1, numEvents do
    local event = C_Calendar.GetDayEvent(today, i, 0)
    if event then
        print(event.title, "-", event.calendarType)
    end
end
```

### Create a Guild Event

```lua
C_Calendar.CreateGuildSignUpEvent()
C_Calendar.EventSetTitle("Raid Night - Mythic")
C_Calendar.EventSetDescription("Bring flasks and food.")
C_Calendar.EventSetDate(3, 15, 2026) -- March 15, 2026
C_Calendar.EventSetTime(20, 0) -- 8:00 PM
C_Calendar.EventSetType(1) -- Raid type
C_Calendar.AddEvent()
```

### Check Upcoming Holidays

```lua
C_Calendar.OpenCalendar()
local monthInfo = C_Calendar.GetMonthInfo(0)

for day = 1, monthInfo.numDays do
    local numEvents = C_Calendar.GetNumDayEvents(day, 0)
    for i = 1, numEvents do
        local event = C_Calendar.GetDayEvent(day, i, 0)
        if event and event.calendarType == "HOLIDAY" then
            print("Holiday:", event.title, "- Day", day)
        end
    end
end
```

---

## Key Events

| Event | Payload | Description |
|-------|---------|-------------|
| `CALENDAR_UPDATE_EVENT_LIST` | — | Event list changed |
| `CALENDAR_UPDATE_INVITE_LIST` | hasCompleteList | Invite list changed |
| `CALENDAR_NEW_EVENT` | isCopy | Creating new event |
| `CALENDAR_OPEN_EVENT` | calendarType | Event opened |
| `CALENDAR_CLOSE_EVENT` | — | Event closed |
| `CALENDAR_UPDATE_EVENT` | — | Event data changed |
| `CALENDAR_UPDATE_PENDING_INVITES` | — | Pending invites changed |
| `CALENDAR_EVENT_ALARM` | title, hour, minute | Event alarm |
| `CALENDAR_ACTION_PENDING` | pending | Action in progress |
| `CALENDAR_UPDATE_GUILD_EVENTS` | — | Guild events updated |
| `CALENDAR_UPDATE_ERROR` | errorReason | Calendar error |

---

## Gotchas & Restrictions

1. **OpenCalendar() required** — Must call `C_Calendar.OpenCalendar()` before using other calendar functions.
2. **Offset-based navigation** — Day and month parameters are offsets from current, not absolute (for most functions).
3. **Invite permissions** — Only event owners/moderators can manage invites.
4. **Calendar types** — `calendarType` distinguishes PLAYER events from HOLIDAY, SYSTEM, RAID_LOCKOUT, etc.
5. **Mass invite limits** — Guild/community mass invites have level and rank filters.
6. **Event creation requires hardware** — `AddEvent()` typically requires user interaction.
7. **Holiday info is read-only** — Holidays are system-generated and cannot be modified.
8. **Calendar data is async** — Wait for `CALENDAR_UPDATE_EVENT_LIST` after opening the calendar.
