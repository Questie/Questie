# Darkmoon Faire

Maintenance reference for Questie's Darkmoon Faire (DMF) scheduling, location resolution, and quest/NPC handling. Start here when changing or debugging this module.

The agreed code work is complete. Native observations support the calendar/texture policy, but normal startup of the corrected branch remains unverified. See [validation status and limitations](#validation-status-and-limitations); these are not queued code fixes.

## Contents

- [Files and responsibilities](#files-and-responsibilities)
- [Configuration](#configuration)
- [Runtime flow](#runtime-flow)
- [Quest and NPC behavior](#quest-and-npc-behavior)
- [Working on the module](#working-on-the-module)
- [Troubleshooting](#troubleshooting)
- [Validation status and limitations](#validation-status-and-limitations)
- [Native calendar evidence](#native-calendar-evidence)
- [DBC research and reproduction](#dbc-research-and-reproduction)
- [Sources and provenance](#sources-and-provenance)

## Files and responsibilities

File links resolve relative to this document. Command examples run from the repository root.

| File | Responsibility |
|---|---|
| [DarkmoonFaire.lua](DarkmoonFaire.lua) | Expansion/season rules, civil-date calculations, calendar access, and the resolved DMF state |
| [QuestieEvent.lua](QuestieEvent.lua) | Startup requests/retries, application of the DMF snapshot, other holidays, and event-query functions |
| [darkmoonFaireFixes.lua](darkmoonFaireFixes.lua) | Mainland location corrections for six carnival NPCs; no island overrides |
| [quests/DarkmoonFaire.lua](quests/DarkmoonFaire.lua) | Event quest registration and per-quest exclusions |
| [Modules/VersionCheck.lua](../../../Modules/VersionCheck.lua) | Client/season flags and fallback season enum values |
| [Modules/QuestieCompat.lua](../../../Modules/QuestieCompat.lua) | Complete in-game calendar date/time, including legacy clients |
| [Modules/QuestieInit.lua](../../../Modules/QuestieInit.lua) | Calls holiday initialization before DB initialization and quest drawing |
| [ContentPhases.lua](../ContentPhases/ContentPhases.lua) | Manually maintained phase counters used by availability rules |
| [QuestieCorrections.lua](../QuestieCorrections.lua) | Initializes runtime overrides and the hidden-quest blacklist before event activation |
| [QuestieQuestBlacklist.lua](../QuestieQuestBlacklist.lua) | Baseline quest hiding and application of phase blacklists |
| [SeasonOfDiscovery.lua](../ContentPhases/SeasonOfDiscovery.lua) | SoD phase exclusions, including the original decks' never-appearing entries |
| [Database/compiler.lua](../../compiler.lua) | DB query handles and per-field fallback from runtime overrides to compiled rows |
| [cataNPCFixes.lua](../cataNPCFixes.lua) | Island spawns and zone IDs; MoP inherits these corrections |
| [cataQuestFixes.lua](../cataQuestFixes.lua) | Island announcement questgivers |
| [Modules/Quest/QuestFinisher.lua](../../../Modules/Quest/QuestFinisher.lua) | Event-specific turn-in suppression |
| [Database/QuestieDB.lua](../../QuestieDB.lua) | Runtime override handles, NPC caching, and quest eligibility checks |
| [Localization/Translations/Events.lua](../../../Localization/Translations/Events.lua) | Localized event/location announcements |

The five TOCs, `Questie-Classic.toc`, `Questie-BCC.toc`, `Questie-WOTLKC.toc`, `Questie-Cata.toc`, and `Questie-Mists.toc`, load the resolver and NPC correction module before `QuestieEvent.lua` and its quest-registration files. Compatibility, VersionCheck, and expansion initialization precede the resolver. Phase counters must be loaded for clients whose rules use phase gating.

## Configuration

### Rule selection and inheritance

Configuration lives directly in `DarkmoonFaire.rules`. Each expansion has `default` and `seasons` tables. The default supplies complete timing and location rules; availability is optional. Expansion values come from `Expansions`, not raw `WOW_PROJECT_ID` values.

- `WOW_PROJECT_ID` identifies the client/expansion.
- `C_Seasons.HasActiveSeason()` and `GetActiveSeason()` select a season within that expansion.
- `timing`, `location`, and optional `availability` resolve independently.
- A supplied season rule replaces that entire rule. There is no field-by-field deep merge.
- An omitted rule inherits the expansion default.
- NoSeason and unknown seasons use the expansion default. Unlisted expansions above MoP use the MoP island/calendar default; other unsupported expansions return unavailable.

Keep explicit entries for known variants even when they repeat the default. This duplication is intentional: each variant should be visible and independently editable. Do not replace the table with `_AddSeason` helpers or scattered conditional construction.

These are developer settings, not saved user preferences. Editing them does not require a settings migration.

`VersionCheck.lua` fills missing season constants without replacing values supplied by the client:

| Enum key | Fallback value |
|---|---:|
| `SeasonOfMastery` | 1 |
| `SeasonOfDiscovery` | 2 |
| `Hardcore` | 3 |
| `Fresh` | 11 |
| `FreshHardcore` | 12 |
| `TitanReforged` | 109 |

NoSeason 0 resolves through the default; it is not an explicit DMF season rule. Titan detection uses the named enum, not a separate literal comparison. General Hardcore detection also uses `C_GameRules.IsHardcoreActive()`.

### Current schedules

| Expansion/variant | Timing | Location |
|---|---|---|
| Era default, nonseasonal Hardcore, explicit Hardcore, SoM | Monday after the first Friday, 03:00 through the following Monday 03:00, closing minute excluded | January-first Elwynn/Mulgore monthly rotation |
| Anniversary Era and Anniversary Hardcore | Same monthly timing, available from Anniversary phase 3 | Same Elwynn/Mulgore rotation |
| TBC default and Anniversary TBC | Same monthly timing | January-first Mulgore, Elwynn, Terokkar monthly rotation |
| SoD | Exact fourteen-day cycles anchored on December 4, 2023; Monday 00:01 through Sunday 23:59 inclusive | Anchor-first Mulgore, then Elwynn, alternating every fourteen days |
| WotLK default and explicit Titan | Native calendar timestamps | Native calendar artwork identifies the rotating location |
| Cata, MoP, and unlisted later expansions | Native calendar timestamps | Darkmoon Island |

The monthly rule is **not necessarily the first Monday**. August 2026 opens on Monday August 10 under the Era/TBC policy. Opening is strictly after setup, including when both are configured for the same weekday.

### Rule fields

Every timing/location rule requires its `source`. Calculated timing also requires `startHour`, `startMinute`, `endDayOffset`, `endHour`, and `endMinute`; these clock fields have no implicit defaults.

| Rule | Source | Additional required fields |
|---|---|---|
| Timing | `monthly` | `setupWeekday`, `startWeekday`, and the calculated opening/closing fields above |
| Timing | `fortnightly` | `anchor` and the calculated opening/closing fields above; recurrence is fixed at fourteen days |
| Timing | `calendar` | None; complete native timestamps determine activity |
| Location | `monthly` | Nonempty `locations`, in January-first order |
| Location | `fortnightly` | `anchor` and nonempty `locations`, in anchor-first order |
| Location | `calendar` | None; recognized calendar artwork supplies the location |
| Location | `fixed` | `location`, using one of the four `DMFLocation` values |

An anchor uses `{year = ..., month = ..., monthDay = ...}`. A fortnightly location rule has its own anchor, separate from timing. Weekdays use Sunday = 1 through Saturday = 7. `endDayOffset` counts civil days after opening. Calculated endings are exclusive unless the optional `endInclusive` is true.

Rule data is trusted developer configuration, not validated user input. When replacing a season's timing, supply a complete timing rule rather than just the changed fields. Neither `{}` nor `false` is a supported way to disable an inherited rule.

Calendar timing may be paired with a calculated location, and calculated timing may be paired with a calendar location. Neither rule should silently replace the other's schedule or rotation. In particular, do not hardcode a monthly WotLK/Titan rotation or a universal first-Sunday MoP schedule in place of native data.

Era, Anniversary TBC, Titan WotLK, and MoP were the reported active variants. Other client defaults are compatibility policy, not live verification.

### Phase availability

An availability rule names a counter in `ContentPhases.activePhases` and its required minimum:

```lua
availability = {
    phaseKey = "Anniversary",
    minimumPhase = 3,
},
```

Era's `Fresh` and `FreshHardcore` entries use this rule. Explicit `Hardcore` does not inherit Anniversary gating. Missing counters are treated as phase 0; when neither the season nor its expansion default specifies availability, there is no phase gate.

The counters are maintained in code, not detected per realm. `Anniversary` was 6 during this work. Keep phase control for future fresh launches: update the new or reused season rule, dates, and counter when needed. There is no requirement to retain retired fresh cycles or add history-aware realm selectors. Era Fresh and TBC Fresh share a season ID, so expansion remains part of rule selection.

## Runtime flow

### Resolver contract

`DarkmoonFaire.GetCurrentState(calendarReady)` resolves one snapshot. It does not register listeners, start timers, apply quest/NPC changes, or schedule future refreshes. Calendar-backed calls temporarily change the calendar month/filter and attempt restoration; this is not a side-effect-free cached lookup.

| Status | Meaning |
|---|---|
| `active` | An active occurrence and its location were resolved |
| `inactive` | Phase gating/calculated timing excludes DMF, or a calendar query accepted as ready found no matching active occurrence |
| `pending` | Calendar readiness, a valid current clock, complete event timestamps, or a required location is still missing; the owner can retry |
| `unavailable` | Unsupported expansion/calendar API or a protected query/restoration failure; the startup owner also uses this status on timeout |

An active result has a `location`: `MULGORE`, `ELWYNN_FOREST`, `TEROKKAR_FOREST`, or `DARKMOON_ISLAND`. These are policy keys, not numeric spawn zone IDs or UI map IDs; NPC corrections use `ZoneDB.zoneIDs`. Calendar-timed results retain native `startTime`/`endTime`; calculated results need not contain timestamps.

Phase availability is checked before clock/calendar access. `_HasDate` checks field types/ranges, not full Gregorian-date validity. `_HasTime` requires an actual hour and minute; a date-only value is not interpreted as midnight.

Civil arithmetic uses Gregorian day numbers: January 1, year 1 is Monday, day 1. Minute comparisons use day number * 1440 plus the clock minutes. These are not Unix timestamps and do not depend on local timezone or DST.

The old SoD implementation doubled a 6-day 23h58m duration to define its recurrence, making each cycle four minutes short of fourteen days. The current fixed civil-day recurrence removes that accumulating drift.

### Native calendar access

`_CalendarState` owns temporary calendar selection/filter changes; `_ReadCalendar` examines the selected month's day records.

1. Require calendar capabilities and the owner's readiness signal.
2. Remember the selected month and `calendarShowDarkmoon` value.
3. Temporarily show DMF events if hidden.
4. Select each queried month with `SetAbsMonth(month, year)` when necessary, then query offset **0**.
5. Attempt filter and month restoration independently, including after query errors. A restoration failure returns unavailable; native failure can still prevent the UI state from actually being restored.

Do not replace this with `SetMonth(0)` or just compute an offset from the selected month. [Live MoP queries](#selected-month-and-filter-behavior) returned false-empty lists for an active September Faire while October was selected.

The resolver requires `GetMonthInfo`, `SetAbsMonth`, `GetNumDayEvents`, `GetHolidayInfo`, `GetCVarBool`, and `SetCVar`. When `GetDayEvent` exists, only `HOLIDAY` records are examined; a missing day record is pending. The current compatibility path can query holiday information without that optional day-record API.

Location identification uses **`GetHolidayInfo().texture`**. Recognized calendar-timed records need complete, ordered start/end timestamps. Unknown artwork is not DMF. Native endings currently include the returned ending minute. Missing or reversed endpoints remain pending rather than triggering a guessed schedule.

For calculated timing with calendar location, search the dates belonging to the calculated occurrence. Its closing Monday can lack a native Sunday-through-Saturday entry, so querying only today can miss the location. Internal search dates need only year/month/day; this must not weaken the public clock compatibility contract. An exclusive midnight ending excludes that closing date from the search.

For calendar timing with calculated/fixed location, retain the native interval and resolve location separately.

### Startup ownership and ordering

`QuestieEvent.Initialize()` must execute inside the existing ThreadLib startup coroutine:

```text
QuestieInit stage 1
  -> QuestieEvent.Initialize()
     -> resolve immediately if no calendar wait is needed
     -> otherwise listen, retry, and wait for a resolved snapshot
     -> QuestieEvent:Load(snapshot), in the owning coroutine
  -> QuestieDB:Initialize()
  -> downstream quest/NPC consumers
```

The calendar path registers `CALENDAR_UPDATE_EVENT_LIST`, a 0.25-second retry ticker, and a five-second timeout before calling `OpenCalendar()` and, if still unresolved, `SetMonth(0)` to request a list refresh.

`calendarReady` means the owner has received a list notification. It is not a native guarantee that every record is populated. The resolver retries recognizable incomplete records, but a zero count after notification can resolve to inactive. Whether cold login can produce that sequence remains unverified.

Callbacks only resolve the snapshot and release their listener/timers. They never apply quest or DB changes. Month selection, restoration, and filter changes can notify synchronously; the checking/finished guards prevent nested or late callbacks from applying data twice.

The owning coroutine yields while the snapshot is unresolved, then calls `Load`. A pending result leaves registration data intact. Once applied, `QuestieEvent.initialized` is true and `eventQuests` is discarded. Repeated application is a no-op.

The old initializer returned before its calendar callback ran. Runtime override tables were live references, but `QuestieDB:GetNPC()` could already have cached an adapted NPC with its old location. Waiting before DB initialization prevents that race.

The snapshot is **startup-only**. Opening, closing, or moving the Faire while logged in does not automatically refresh event state. Calling the resolver alone does not update existing quest/NPC state.

Do not reset `QuestieEvent.initialized` or manually replay `Load` to force a refresh: the registration table has already been discarded, and other startup state is not reset by that flag. Reproduce through a fresh UI startup with permission, or design an explicit refresh lifecycle separately.

### Clock compatibility

`QuestieCompat.GetCurrentCalendarTime()` must return the complete date/time contract:

1. Return native `C_DateAndTime.GetCurrentCalendarTime()` unchanged when available.
2. Otherwise map `GetTodaysDate().day` to `monthDay` and `.weekDay` to `weekday`, retain `month`/`year`, and add `GetGameTime()` hour/minute.
3. Raise the unsupported-API error if the required APIs are absent.

The required returned fields are `year`, `month`, `monthDay`, `weekday`, `hour`, and `minute`. Returning the native table unchanged also preserves any extra native fields. Missing required APIs raise an error; that is distinct from a resolver result with status `unavailable`.

Do not return partial dates, fabricate midnight, use the computer's local clock, or add guessed regional offsets. Genuine native or legacy midnight is valid and must remain 00:00.

## Quest and NPC behavior

### Quest registration and activation

An event quest entry has this layout:

```text
{eventName, questId, startDate?, endDate?, startClock?, endClock?, hideQuest?}
```

Dates use `DD/MM` and optional clock strings use `HH:MM`. Date and clock overrides are parsed in start/end pairs; supplying only one endpoint does not create a one-sided window.

In the generic registration/activation loops, the seventh field, `hideQuest`, skips that entry rather than registering it, activating it, or clearing its existing hidden flag. It does **not** create a blacklist entry by itself. Announcement quests also have the separate location-selection policy described below.

`QuestieCorrections` loads `hiddenQuests` from `QuestieQuestBlacklist` and the relevant phase exclusions before holiday application. Active eligible DMF quests have their hidden entries cleared; inactive DMF does not blanket-blacklist every registered quest. When adding a quest, inspect its existing blacklist/phase and item-starter behavior instead of assuming registration supplies those rules.

Eligible registered quests retain their event names while inactive so `IsEventQuest`, `IsEventActiveForQuest`, and `CanQuestBeTurnedInOutsideOfEvent` can control finishers.

`Load` processes general holiday windows separately from DMF's resolved state. For non-DMF holidays, a quest's own date/time window can be narrower than its parent event; date-only windows include whole days. DMF activation uses the resolved Faire snapshot and `hideQuest`, not the per-entry date/clock slots. Adding dates to a DMF registry entry therefore does not add quest-specific DMF timing. Other holidays continue to initialize if DMF resolution is unavailable.

Event registration is **not** a blanket ban on accepting item-started deck quests outside the Faire. The unavailable-data warning therefore describes unresolved event availability rather than claiming all DMF quests are hidden. Fortune quests 7937, 7938, 7944, and 7945 retain their explicit outside-event turn-in exceptions.

SoD policy:

- Keep original decks 7907, 7927, 7928, and 7929 excluded on SoD, consistent with the phase-8 "Never appearing" blacklist.
- Register SoD decks 82055–82058 and 86760–86763 for event-specific finisher handling.
- Replacements are 7907 → 86760, 7928 → 86761, 7929 → 86762, and 7927 → 86763.
- Existing data already supplies starter-item links and turn-in to Professor Thaddeus Paleo, NPC 14847. No new relationship corrections were needed.
- **Retain the existing unconditional SoD-section registration.** The earlier proposal to wrap it in `if Questie.IsSoD then` was withdrawn to preserve existing behavior. Do not revive it as unfinished work.

### Mainland overrides and island data

`DarkmoonFaireFixes.GetNpcFixes(location)` supplies location records for:

| NPC ID | Name |
|---|---|
| 14828 | Gelvas Grimegate |
| 14829 | Yebb Neblegear |
| 14832 | Kerri Hicks |
| 14833 | Chronos |
| 14841 | Rinling |
| 14871 | Morja |

The mainland coordinates were copied exactly from the former Classic/TBC loaders. Keep the tables as the coordinate source; do not duplicate them in this document.

Important application rules:

- Apply mainland overrides even when no event quest is visible.
- Mainland location records intentionally win over earlier runtime overrides. Keep the `if npcFixes then` application path; do not add an "only if override missing" condition.
- Write to `QuestieDB.npcDataOverrides`, not compile-time `QuestieCorrections.npcData`.
- Replacing an override record does not replace the whole compiled NPC row. Unspecified fields fall back to compiled data, preserving names, quest relationships, and static SoD corrections.
- `DARKMOON_ISLAND` returns nil from `GetNpcFixes`, preserving normal island spawns and existing island overrides.

Cata corrections already relocated these NPCs to island spawns but left their `zoneID` on the mainland. The branch fixes those six zone IDs; MoP inherits them. This repairs zone-based link text without changing coordinates, sentinel coordinates, or quest relationships.

### Announcement quests

| Location | Announcement quests enabled |
|---|---|
| Mulgore | Horde 7926 |
| Elwynn | Alliance 7905 |
| Terokkar | Both 7905 and 7926 |
| Darkmoon Island | Both 7905 and 7926 |

**Do not suppress island announcements as obsolete.** Cata/MoP retain these quests, starting at Alliance Mystic Mage 54334 / Horde Mystic Mage 55382 and ending at Gelvas Grimegate 14828. Classic corrections supply race masks; `QuestieDB.IsDoable` still enforces faction eligibility after hidden-quest checks.

Every location uses the localized template `The Darkmoon Faire is up in %s!`. The template and `Darkmoon Island` already have all ten supported locales. There is no island early return that skips activation or the location announcement.

## Working on the module

Use the existing responsibilities rather than adding policy helpers that scatter configuration:

- Change schedule/location/phase policy in `DarkmoonFaire.rules` and the appropriate phase counter. Keep monthly timing blocks visibly grouped into Meta, Start, and End.
- Keep timing, location, and availability independently replaceable. Test the behavior being changed, not a reconstruction of the implementation's own calculations.
- Keep civil-date arithmetic, calculated timing, native calendar access, and startup/application ownership distinguishable in code and comments.
- Use enum names; preserve client-supplied enum values. A new season may reuse an old rule or need an explicit entry.
- Preserve restoration, synchronous notification guards, and the wait before DB consumers cache NPCs.
- Do not use `coroutine.running()` to make yielding optional. Callers must use the intended ThreadLib coroutine.
- Do not change saved settings, add migrations, or build live refresh/history machinery for a developer rule edit.

Run these commands from the repository root:

```bash
busted Database/Corrections/Holidays/DarkmoonFaire.test.lua \
    Database/Corrections/Holidays/QuestieEvent.test.lua \
    Database/Corrections/Holidays/darkmoonFaireFixes.test.lua \
    Database/Corrections/Holidays/quests/DarkmoonFaire.test.lua \
    Database/Corrections/cataNPCFixes.test.lua \
    Modules/QuestieCompat.test.lua

busted -p '.test.lua' .

luacheck -q -- Database/Corrections/Holidays \
    Database/Corrections/cataNPCFixes.test.lua \
    Modules/QuestieCompat.lua Modules/QuestieCompat.test.lua \
    Modules/VersionCheck.lua Modules/QuestieInit.lua

git diff --check
```

Resolver tests cover weekday/month boundaries, independent rule inheritance, phase availability, fortnightly drift, mixed timing/location sources, native timestamps/textures, absolute month selection, and restoration failures. Event tests cover quest exclusions, announcements, pending/timeout paths, synchronous notifications, application errors, and quest-specific windows. Data tests check mainland records and island zone consistency. Compatibility tests cover native precedence, real midnight, legacy date/clock mapping, and missing APIs.

There is currently **no dedicated VersionCheck bootstrap test file**. Earlier development notes described one, but it was removed in `854c2dfb0`. Resolver/event tests supply enum mocks; do not claim they execute the actual bootstrap. Test files must never be added to TOCs.

Prior full-suite runs and focused reviews passed, but counts change as tests are added, split, or removed. Re-run the relevant commands rather than treating a historical count as proof of current coverage. The recorded audit also checked exact mainland-table parity and independently compared civil dates over 73,414 dates from 1900–2100. That supports local arithmetic/data correctness, not native API timing assumptions.

Follow the repository's current review instructions. Distinguish actual regressions, inherited issues, deliberate behavior, and runtime hypotheses. No installation, live database, or running/daily-driver client should be modified without explicit permission. Read the project's `wow-lua-bridge` or `wow-ui-source` skill before using those tools; do not assume a previous test authorization permits a new deployment or reload.

## Troubleshooting

Start with the smallest relevant layer rather than changing dates or NPC coordinates to compensate for another layer's failure:

| Symptom | Check first |
|---|---|
| Wrong occurrence, month, or location | Confirm client/season identity, native clock, selected calendar month, and both records for the same date/index. Raw offset 0 queries do not automatically mean today's month. |
| Resolver says pending/unavailable | Check the complete current clock, required calendar APIs, list notification, and missing/reversed holiday endpoints. Also check the debug warning; timeout is final for that startup. |
| Resolver now says active but quests remain unavailable | Compare the fresh result with the already-applied startup snapshot. A new query does not recover a timed-out startup or apply corrections again. |
| Faire is active but one quest is missing | Check `hideQuest`, blacklist/phase entries, date window where applicable, normal quest eligibility, and display settings. Check finisher event predicates separately for item-started decks. |
| NPC map position and zone text disagree | Compare `spawns` with `zoneID`, the runtime override with the compiled row, and whether an adapted NPC was cached before the correction. The six island zone-ID fixes address this distinction. |
| Titan announcement has no starter icon | Check barkers 14842/14843 and their actual presence/spawn data before guessing coordinates or suppressing quests. |

A rule/date change does not itself require recompiling the quest database, but the new code still needs a fresh addon startup to apply its snapshot. Static database-correction changes use the normal DB compilation/version workflow. Do not deploy, recompile a running installation, or reload a client without permission.

## Validation status and limitations

These are confidence limits and separate design choices, not an outstanding list of agreed code fixes.

### Evidence accepted for this implementation

- MoP native records confirm two September 2026 occurrences, complete timestamps on all sequence days, matching texture fields, and immediate filter effects on an already-loaded calendar.
- Titan tester output confirms August Elwynn and September Mulgore artwork and timestamps.
- Terokkar's mapping is accepted from DBC data plus matching Elwynn/Mulgore results. Another native texture dump is not required for this change; Terokkar is DBC-backed, not live-verified.
- The current holiday texture field is retained. Blizzard's UI uses day-event `iconTexture` for sequence artwork, but no mismatch was reproduced. Switching fields is optional, not an established bug fix. Any future switch needs explicit missing-record/nullable-texture behavior and independent fixtures where the fields differ.

### Not established by the recorded testing

- Corrected-branch behavior through normal startup, especially a cold or congested login and the five-second timeout.
- Whether an initial list notification can precede complete native data.
- Actual world state at the opening minute, ending minute, and following minute. API endpoint values are known; inclusive world activity was not observed at those instants.
- Era/TBC world timing boundaries and any clock-basis discrepancy at a date boundary.
- Full in-game confirmation of faction announcements and mainland/island positions.

WotLK announcement quests 7905/7926 reference barkers 14842/14843, whose WotLK rows lack starter spawns/waypoints. They may become active without drawable starter icons. Whether those barkers/quests exist on Titan is an unconfirmed data question, not proof they should be removed or assigned guessed coordinates. The six carnival-NPC overrides do not cover them. Do not transfer the island Mystic Mage assumptions to WotLK.

### Existing lifecycle policy

- Timeout is final for the session. The listener is removed and registration data discarded; later calendar readiness cannot recover DMF without reload. The warning is debug-only. Late recovery is not implemented.
- No live event transition refresh is implemented.
- Disabling during startup does not cancel the outer ThreadLib job or every raw timer. A later timeout can resume initialization after disable. This is an inherited wider lifecycle problem, not part of the DMF follow-up scope.
- Application errors propagate through the owning startup coroutine instead of allowing partial initialization or leaving it waiting forever.
- Calendar restoration failures and timer-construction failures remain low-likelihood defensive concerns. Protected cleanup attempts cannot guarantee a failing native API restored UI state.
- Whole-record runtime overrides could discard future non-location overrides for the same six NPCs. The audit found no existing conflicting faction/content runtime overrides; preserve the intentional location precedence unless a real conflict is established.
- Retaining three small mainland correction tables is negligible. No lazy-loading mechanism is needed.

## Native calendar evidence

### Holiday IDs and artwork

`HolidayNameID = 1` identifies the DMF family, not one location or occurrence. The relevant Holidays rows and texture sets are:

| Location | Holiday ID | Description ID | START | ONGOING | END |
|---|---:|---:|---:|---:|---:|
| Elwynn Forest | 374 | 1 | 235448 | 235447 | 235446 |
| Mulgore | 375 | 26 | 235451 | 235450 | 235449 |
| Terokkar Forest | 376 | 27 | 235455 | 235454 | 235453 |
| Darkmoon Island / modern Faire | 479 | 201 | 235448 | 235447 | 235446 |

The island shares Elwynn artwork. Expansion/location policy distinguishes them and rejects stale Mulgore/Terokkar records on island clients. Artwork identifies the event/location; timestamps determine activity. `sequenceType` marks START/ONGOING/END, and END describes a sequence day rather than proving that the event is already closed.

### MoP capture

Authorized bridge probes were run on September 7, 2026, approximately 17:44–17:52 native calendar time:

- MoP 5.5.4, build 69585, build date August 27, 2026, interface 50504.
- `WOW_PROJECT_ID = 19`; `GetCurrentRegion() = 3` (EU).
- `C_Seasons.HasActiveSeason()` was false; `GetActiveSeason()` returned nil.
- Installed Questie metadata was 11.36.2; the repository under investigation was `DMF-locations-fixes` at `92bd83e9a`.
- The calendar was already open and populated. This was not cold-login testing.

Both September occurrences had holiday event ID 479:

| Opening | Closing |
|---|---|
| 2026-09-06 00:01 | 2026-09-12 23:59 |
| 2026-09-20 00:01 | 2026-09-26 23:59 |

Across all fourteen sequence days, `calendarType` was HOLIDAY, both APIs returned the complete occurrence's start/end timestamps, and day `iconTexture` matched holiday `texture`. START/ONGOING/END used the three island/Elwynn values above. `numSequenceDays` was 7; `sequenceIndex` ran from 1 through 7.

There was no DMF record on September 4–5 or September 13, nor a separate setup entry for the second occurrence in the full-month scan. This establishes the queried calendar representation, not whether the world has a setup stage.

Other records provide useful nullable-field examples:

- Call to Arms: Twin Peaks (436) had timestamps but no texture in either API.
- Stranglethorn Fishing Extravaganza (301) had day-event timestamps, but holiday information omitted both timestamps.
- Querying the missing September 7 entry with October selected returned nil from both record getters without throwing.

#### Selected-month and filter behavior

With DMF visible and the real date unchanged:

| Selected month | Offset querying September 7 | Result |
|---|---:|---|
| September 2026 | 0 | Two events, including active DMF |
| October 2026 | -1 | Zero events; both record getters returned nil at index 1 |
| August 2026 | +1 | Two events, including active DMF |

The October-selected result stayed empty during its synchronous list notification, immediately afterward, on the next frame, and after 0.25 and 1 seconds. `OpenCalendar()` followed by `SetMonth(0)` did not recover September 7 and left October selected. `SetAbsMonth(9, 2026)` restored the expected data.

Negative offsets are not universally broken: with October selected, September 20 returned 2 events and September 26 returned 4. The native availability range/selection policy remains unknown. Correct offset arithmetic alone therefore cannot make an empty off-month list authoritative.

On the already-loaded September calendar:

1. Today's count was 2: DMF and Twin Peaks.
2. Hiding DMF immediately changed the count to 1; showing it restored count 2 and the DMF record.
3. Neither filter change emitted a list notification during the probe.
4. `OpenCalendar()` emitted no list notification during the five-second observation.
5. `SetMonth(0)` emitted `CALENDAR_UPDATE_EVENT_LIST` synchronously, before returning, with populated data.
6. Samples on the next frame and after 0.25, 1, and 5 seconds remained populated.

A separate probe began with DMF hidden. Inside the synchronous list notification, enabling the filter immediately exposed DMF, and restoring the filter immediately removed it. This supports temporary filtering for a warm calendar, not assumptions about cold-cache or network latency.

The pre-fix resolver was also evaluated through the bridge in an isolated Lua environment with a separate loader/configuration and real calendar/CVar APIs. It returned active island results with September or August selected, but inactive with October selected. Hidden-filter restoration and the not-ready pending result behaved as expected. No quest/NPC application ran.

That probe was **not a deployment**. A length check and returned source fragment showed that the bridge collapsed repeated spaces. It was neither a byte-identical installed build nor a normal-startup test.

Probe month/filter changes were restored to September 2026 and filter `1`; temporary listeners were released and timer probes finished. No addon installation or quest/NPC data was changed, and no UI reload was performed. One screenshot-decoding failure was followed by a state check and successful repeated probes. A whole-resolver request exceeded the bridge's 3,900-character limit and did not execute; chunked submission enabled the isolated evaluation.

### Titan tester capture

Logon relayed compact native output from a Chinese Titan tester. The supplied clock was September 8, 2026, 00:04. No exact client build, region API value, or season ID was supplied. Do not attribute these records to the separately cached Titan UI-source build.

| Occurrence | Location | Day-event ID | Sequence | Day `iconTexture` | Holiday `texture` |
|---|---|---:|---|---:|---:|
| 2026-08-02 00:01 through 2026-08-08 23:59 | Elwynn Forest | 374 | END | 235446 | 235446 |
| 2026-09-06 00:01 through 2026-09-12 23:59 | Mulgore | 375 | ONGOING | 235450 | 235450 |

The first queries used offset 0 and the current clock's day number. They described August, not the current September occurrence:

```text
374 END 235446 235446
暗月马戏团
Start 2026 8 2 0 1
Now 2026 9 8 0 4
End 2026 8 8 23 59
```

After selecting September explicitly and querying September 8:

```text
暗月马戏团
Start 2026 9 6 0 1
End 2026 9 12 23 59
375 ONGOING 235450 235450
```

This is consistent with offset 0 referring to the selected month, not inherently stale holiday timestamps. The expected rotation is August Elwynn, September Mulgore, October Terokkar. October was not dumped; its mapping is accepted from DBC evidence.

### Reproducing native observations

Capture the build, project, season, region, current calendar time, selected month, filter, and both records for the same index. Record `calendarType`, `eventID`, `sequenceType`, `iconTexture`, and full day/holiday timestamps. Do not infer the current occurrence from localized names or a selected month left over from browsing.

These tester commands are under 255 characters and produce compact chat output. They intentionally select September 2026 and **do not restore the previous month**. They are warm-calendar diagnostics, not production readiness handling.

Select September and print the first holiday's name and timestamps for September 8 (216 characters). Confirm the printed name is DMF; index 1 is not a general-purpose event identifier:

```lua
/run local c=C_Calendar;c.OpenCalendar();c.SetAbsMonth(9,2026);local h=c.GetHolidayInfo(0,8,1);print(h.name);for k,t in pairs({Start=h.startTime,End=h.endTime})do print(k,t.year,t.month,t.monthDay,t.hour,t.minute)end
```

Print holiday ID, sequence, and both textures for the selected month's day matching the current clock (253 characters). During the recorded test that day was 8. This second command does not select a month:

```lua
/run local c,d=C_Calendar,C_DateAndTime.GetCurrentCalendarTime().monthDay;for i=1,c.GetNumDayEvents(0,d)do local e=c.GetDayEvent(0,d,i);if e.calendarType=="HOLIDAY"then print(e.eventID,e.sequenceType,e.iconTexture,c.GetHolidayInfo(0,d,i).texture)end end
```

Adapt the dates for a new investigation. If the first call has no data, allow the calendar to load before retrying. Prefer bridge capture of full records when authorized; verify which addon build/module is loaded before comparing its resolver output.

Local raw MoP JSON files were saved as:

```text
/tmp/questie-mop-dmf-calendar-identity.json
/tmp/questie-mop-dmf-calendar-september.json
/tmp/questie-mop-dmf-calendar-readiness.json
/tmp/questie-mop-dmf-calendar-filtered-notification.json
/tmp/questie-mop-dmf-calendar-offsets.json
/tmp/questie-mop-dmf-calendar-navigation.json
/tmp/questie-mop-dmf-calendar-negative-offsets.json
/tmp/questie-mop-dmf-calendar-resolver.json
```

These scratch files are not committed fixtures and may no longer exist. The relevant observations are recorded above and selected fields are represented in tests.

## DBC research and reproduction

This section records offline research, not a shipped scheduling source. Static occurrence lists expire and server overrides may exist, so the addon does not ship or extrapolate them.

### Acquisition and coverage

Inspected [Questie/dbc release v2026.09.07](https://github.com/Questie/dbc/releases/tag/v2026.09.07), source commit `f16bf1465b96228ed913b4addbc543a595602666`. Download with authenticated `gh` if needed: the repository was private during this work and unauthenticated requests returned 404. A release date does not imply every table was extracted from that release's newest client builds.

All three asset SHA-256 hashes matched their release digests:

```text
dbc-raw.tar.xz    dbec30262f1edf3db281406cdc1e51aa4f433e313bf6a2dd00ff7ac88cd21786
dbc-source.db.xz  c592475683e85ff713ed4160e6f64c1ac88a1655eb0feab6d04a87c8f512d533
manifest.json    58dc0d2d859b5d4b1ea8b263b6057a11b2d40ddd50fe1b959408ce2051637406
```

The archive held 2,052 raw CSVs, roughly 3 GiB extracted; the decompressed SQLite database was 218 MiB. There was one Holidays CSV per expansion. SQLite DMF `_first_seen`/`_last_seen` values likewise referred to those pinned snapshots, not newer builds present for other tables.

Scratch layout:

```text
/tmp/questie-dbc-v2026.09.07/
    dbc-raw.tar.xz
    raw/
    dbc-source.db.xz
    dbc-source.db
    manifest.json
    inspect_holidays.py
    decoded-holidays.txt
    newer/Holidays.5.5.4.69585.csv
    newer/decoded-holidays.txt
```

The decoder and extracted files were not committed. If still available, the stdlib CSV/SQLite/datetime inspection can be rerun read-only with:

```bash
uv run --no-project /tmp/questie-dbc-v2026.09.07/inspect_holidays.py
uv run --no-project /tmp/questie-dbc-v2026.09.07/inspect_holidays.py /tmp/questie-dbc-v2026.09.07/newer
```

The newer MoP CSV was acquired separately from [wago.tools for build 5.5.4.69585](https://wago.tools/db2/Holidays/csv?build=5.5.4.69585), the DBC repository's upstream. Its SHA-256 was `16d3c44a8afaf50d521b4481c9ec53339e2285acd91d7184df1f3839b6dd6fe8`. The DBC repository's inspected Git tree itself had no tracked CSVs.

### Rows, occurrence lists, and stage boundaries

The four DMF rows in the inspected release had `HolidayNameID = 1`, `Region = 0`, `Looping = 0`, `CalendarFilterType = 1`, `WorldStateExpressionID = 0`, durations `[48, 168]`, and calendar flags `[0, 3]` followed by zeroes. Their descriptions distinguish the locations listed in the [artwork table](#holiday-ids-and-artwork).

`Date_N` is a sequence of packed occurrence dates, **not Unix timestamps or alternating start/end pairs**. Durations describe successive stages in hours. Treating 48 hours as setup and the following 168 as open Faire time is supported by the inspected emulator implementation and day-level observations, not direct access to Blizzard's native conversion.

Titan `Holidays.3.80.0.66566.csv`, holiday 374:

```text
Date_7 = 443004928
Decoded occurrence date: 2026-07-31 00:00, Friday
+ 48 hours:             2026-08-02 00:00, Sunday
+ 168 further hours:    2026-08-09 00:00, following Sunday
```

Its 2026 rows assign January/April/July/October to Terokkar, February/May/August/November to Elwynn, and March/June/September/December to Mulgore. This supports the expected Titan rotation beyond the original January-only news citation. It does not establish the original non-Titan WotLK rotation.

The release's MoP `Holidays.5.5.3.66839.csv` had no dates in legacy rows 374–376. Holiday 479 had 26 fortnightly openings from July 13, 2025 through June 28, 2026, with the final stage ending July 5, 2026. It could not establish September 2026; `Looping = 0` did not justify extrapolation.

The separately downloaded `Holidays.5.5.4.69585.csv` supplied 26 fortnightly openings from July 12, 2026 through June 27, 2027, with the final stage boundary July 4, 2027. Legacy rows remained undated. In row 479:

```text
Date_4 = 444659712
Decoded occurrence date: 2026-09-04 00:00, Friday
+ 48 hours:             2026-09-06 00:00, Sunday
+ 168 further hours:    2026-09-13 00:00, following Sunday
```

These midnight boundaries match the observed Faire days. The native API's 00:01/23:59 values are not stored literally in those packed boundaries. Use returned native timestamps rather than applying an invented global one-minute adjustment.

Other snapshot limitations:

- `Holidays.4.4.2.60895.csv` retained old rotating-location dates and island fortnightly openings from December 2024 through July 2025. It was not evidence of a 2026 Cata schedule.
- Era `Holidays.1.15.9.69547.csv` and TBC `Holidays.2.5.6.69546.csv` contained no rows matching `HolidayNameID = 1`; they did not supply DMF schedules through that filter.
- Static date coverage and a shared holiday name do not establish the final live schedule for every client.

### Packed date format

[TrinityCore's `WowTime::SetPackedTime`](https://github.com/TrinityCore/TrinityCore/blob/3eca31e2b80b39235aa1af430df42a9dd0009d90/src/server/game/Time/WowTime.cpp#L23-L63) supplies this decoding layout. It is primary evidence for that emulator's implementation, not an official Blizzard runtime specification.

| Component | Extraction from unsigned `value` | All-ones sentinel |
|---|---|---:|
| Minute | `value & 0x3F` | 63 |
| Hour | `(value >> 6) & 0x1F` | 31 |
| Weekday | `(value >> 11) & 0x7` | 7 |
| Day of month, zero-based | `(value >> 14) & 0x3F` | 63 |
| Month, zero-based | `(value >> 20) & 0xF` | 15 |
| Year offset from 2000 | `(value >> 24) & 0x1F` | 31 |
| Packed time flags | `(value >> 29) & 0x3` | 3 |

The implementation turns all-ones sentinels into `-1` (unspecified). Check them **before** adding one to month/day or adding 2000 to the year; year 31 is not automatically 2031. Packed time flags are separate from Holidays `Flags` and `CalendarFlags_N`, and their nonzero meanings were not established.

The [Unix conversion implementation](https://github.com/TrinityCore/TrinityCore/blob/3eca31e2b80b39235aa1af430df42a9dd0009d90/src/server/game/Time/WowTime.cpp#L65-L98) corroborates zero-based day/month and year offset. Its weekday follows `tm_wday`, Sunday = 0, unlike the resolver rule convention Sunday = 1.

For a fully specified, non-sentinel value only:

```python
minute = value & 63
hour = (value >> 6) & 31
weekday = (value >> 11) & 7
month_day = ((value >> 14) & 63) + 1
month = ((value >> 20) & 15) + 1
year = ((value >> 24) & 31) + 2000
flags = (value >> 29) & 3
```

Unspecified components can represent recurrence rather than an invalid record. Do not construct a datetime or infer a concrete recurrence from this bit decoder alone. Use `uv` for Python commands in this workspace.

### Duration, recurrence, region, and timezone interpretation

[TrinityCore's `GameEventMgr::SetHolidayEventTime`](https://github.com/TrinityCore/TrinityCore/blob/3eca31e2b80b39235aa1af430df42a9dd0009d90/src/server/game/Events/GameEventMgr.cpp#L1682-L1751) interprets:

- `Date_N` as successive candidate starts, stopping at the first zero entry.
- `Duration_N` as stage durations; stage i begins after the sum of earlier durations.
- `CalendarFilterType`: -1 yearly, 0 weekly, 1 defined dates only (explicitly including DMF), 2 looping-event usage.
- Nonzero `Looping` as a recurrence period equal to the sum of nonzero stage durations.
- Unspecified years as yearly occurrences needing a concrete year.

For example, `[72, 168]` means successive 72-hour and 168-hour stages, not unrelated dates or end timestamps. Whether stages mean setup/open Faire must come from the row's context and observed behavior. Emulator scheduling does not prove modern Classic's stage visibility or minute adjustments.

The community [WoWDBDefs Holidays schema](https://github.com/wowdev/WoWDBDefs/blob/d0cc6370847f0c6ae3bfb970ad9520be253276f5/definitions/Holidays.dbd#L1-L16) describes `Region` as a `Cfg_Region.Region_group_mask` bitmask: US 1, KR 2, EU 4, TW 8, CN 16, with further environment bits. These are not `GetCurrentRegion()` numeric IDs and are not timezone offsets.

That schema labels calendar flags with Alliance/Horde bits and row flags with region-wide/calendar-visibility bits. These comments are not sufficient to implement native selection policy. Preserve those fields and `WorldStateExpressionID` when investigating; their full runtime semantics remain outside the established evidence.

Packed dates contain no explicit UTC offset. TrinityCore versions even differ: the [3.3.5 scheduler](https://github.com/TrinityCore/TrinityCore/blob/65f4f04650ae5c91bda174703d0043891d12b34d/src/server/game/Events/GameEventMgr.cpp#L1770-L1818) uses process-local `mktime`, while the newer implementation uses UTC conversion through `timegm`. Neither proves the Titan/MoP time basis. Do not add speculative China/EU adjustments.

The [3.3.5 holiday override loader](https://github.com/TrinityCore/TrinityCore/blob/65f4f04650ae5c91bda174703d0043891d12b34d/src/server/game/Events/GameEventMgr.cpp#L943-L987) changes DBC dates/durations from server data, and its [calendar handler](https://github.com/TrinityCore/TrinityCore/blob/65f4f04650ae5c91bda174703d0043891d12b34d/src/server/game/Handlers/CalendarHandler.cpp#L134-L154) sends modified holiday data to clients. This demonstrates an emulator override path, not a confirmed current Blizzard override. It is another reason not to assume static DBC files are the final native authority.

## Sources and provenance

### Published Blizzard UI source

The recorded source caches were:

| Gethe branch/cache | Build | Commit |
|---|---|---|
| `~/.cache/wow-ui-source/classic` | MoP 5.5.4.69585 | `ecadf9d3326fa87828cacca7f13c0ab5f41840a6` |
| `~/.cache/wow-ui-source/classic_titan` | Titan 3.80.2.69496 | `ba472e5e1b5580b557e3dbf02c9e5ff23b223347` |

Pinned Titan references:

- [Calendar declarations](https://github.com/Gethe/wow-ui-source/blob/ba472e5e1b5580b557e3dbf02c9e5ff23b223347/Interface/AddOns/Blizzard_APIDocumentationGenerated/CalendarDocumentation.lua): day fields around 961–985; holiday fields around 1101–1110.
- [Calendar UI](https://github.com/Gethe/wow-ui-source/blob/ba472e5e1b5580b557e3dbf02c9e5ff23b223347/Interface/AddOns/Blizzard_Calendar/Classic/Blizzard_Calendar.lua): filter refresh around 1051–1058; day-event sequence artwork around 1660–1687; returned holiday timestamp display around 2461–2467.
- [Season enums](https://github.com/Gethe/wow-ui-source/blob/ba472e5e1b5580b557e3dbf02c9e5ff23b223347/Interface/AddOns/Blizzard_APIDocumentationGenerated/SeasonsConstantsDocumentation.lua).

Blizzard's Lua UI establishes which fields it displays and how its filter UI refreshes. It does not expose the native DBC-to-calendar conversion, prove response latency, or establish world state at endpoint minutes. Channel names move between expansions; record exact commits/builds during a new investigation rather than assuming the current branch tip still matches these captures.

### Branch history

Development branch: `DMF-locations-fixes`, canonical remote `git@github.com:Questie/Questie.git`.

| Revision | Useful comparison or change |
|---|---|
| `2feb35c5521db92bfd432117169095ef30dcc06e` | Before the original DMF changes |
| `3c4de9c43` | Original calculated WotLK rotation |
| `98e140251` | Original branch tip: extracted NPC fixes and revised location handling |
| `995dceac0` | Complete legacy calendar date/clock fallback |
| `43fd187fc` | Explicit expansion/season schedule rules |
| `5957792d3` | SoD deck event registration/exclusions |
| `dbeafc357` | Six island NPC zone-ID corrections |
| `dbc3102aa` | Original DBC/calendar research note and audit comparison point |
| `c10158149` | Absolute queried-month selection and restoration |
| `ddd47d4da` | Configurable phase availability |
| `0dcfe366f` | Native MoP/Titan findings recorded |
| `c07a800ba` | Explicit Hardcore handling, Titan enum use, quest-date test, warning follow-up |
| `854c2dfb0` | Season compatibility readability and removal of the dedicated VersionCheck tests |

Use both the pre-DMF revision and original branch tip when attributing a regression. A problem introduced or exposed by the initial WotLK support is not necessarily caused by the later refactor. The old `DMF_CALENDAR_ICON_TEXTURES` name belongs to the prior implementation; the current map is `locationByTexture`.

The initial offline audit covered scheduling, lifecycle, quest/faction behavior, NPC consumers, and tests. Later native findings supersede its no-live-evidence status and overstated texture-field bug classification; historical reviews do not establish current release readiness.

Use logical Conventional Commits such as `fix(events): ...`; exclude unrelated workspace/profiling files. Update this reference when policy, ownership, evidence, or accepted limitations change rather than creating parallel handoffs.
