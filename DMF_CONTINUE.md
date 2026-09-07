# Darkmoon Faire continuation

## Read this first

This branch improves Darkmoon Faire (DMF) scheduling, location detection, and quest handling. The architecture is implemented, but **the audit findings are not all fixed and native calendar behavior has not been verified in-game**.

Do not interpret passing tests, completed commits, or earlier conversational claims as proof that every requested fix landed. Several tasks were interrupted by conversation branches. The open items below were checked against the repository at `dbc3102aa`.

Immediate next steps:

1. Complete the explicitly requested `Questie.IsSoD` guard around the entire SoD quest-registration section.
2. Address calendar sequence texture selection and make the fixtures distinguish `GetDayEvent` from `GetHolidayInfo`.
3. Add explicit Hardcore season coverage and finish replacing the Titan literal in `VersionCheck`.
4. Restore missing test coverage using independent expectations.
5. Obtain native calendar evidence before declaring the implementation ready.

Do not alter a WoW installation, running client, live database, or daily-driver preview without David's permission. The work so far used repository data, downloaded artifacts, published UI source, and offline tests only.

## Branch and history

Working branch: `DMF-locations-fixes`.
Remote: `origin`, `git@github.com:Questie/Questie.git`.

Useful comparison points:

| Revision | Meaning |
|---|---|
| `2feb35c5521db92bfd432117169095ef30dcc06e` | Before the original DMF branch changes |
| `3c4de9c43` | Original addition of calculated WotLK rotation |
| `98e140251` | Original branch tip: extracted NPC fixes and revised location handling |
| `995dceac0` | `fix(compat): preserve time in legacy calendar fallback` |
| `43fd187fc` | `refactor(events): configure Darkmoon Faire schedules by season` |
| `5957792d3` | `fix(sod): gate Darkmoon deck turn-ins by event` |
| `dbeafc357` | `fix(db): correct Darkmoon Island NPC zone IDs` |
| `dbc3102aa` | `docs(events): record Darkmoon Faire calendar findings` |

Use both old comparison points. An issue introduced by `98e140251` is not necessarily introduced by the later refactor, and an existing bug should not be presented as a new regression.

Four unrelated files were intentionally left untracked and must not be swept into DMF commits:

- `ExternalFunctionProfiling.md`
- `MeasureCall.md`
- `PROFILER_BRANCH_FINDINGS.md`
- `QUEST_ICON_RECONCILER_PLAN.md`

David requested logical Conventional Commit messages for this work. Follow the current branch's `type(scope): summary` style for follow-ups unless instructed otherwise. This handoff documents the current implementation; it does not open a PR or establish release readiness.

## Requirements and decisions

### Explicit configuration

David wants sensible expansion defaults **and explicit entries for every known season**, even when the season repeats its default. Clarity and independent editability are worth the small duplication.

- Configuration lives directly inside `DarkmoonFaire.rules`.
- Each expansion contains `default` and `seasons`.
- Resolve `timing` and `location` independently.
- A season replaces a whole timing/location rule, not selected fields through a deep merge.
- An omitted rule inherits the expansion default.
- Do not reintroduce `_AddSeason` or scattered conditional table construction. `VersionCheck.lua` supplies missing enum constants before this module loads.
- These are developer code settings, not saved user preferences. No settings migration is needed for this configuration.

`WOW_PROJECT_ID` identifies the client/expansion; `C_Seasons.GetActiveSeason()` distinguishes variants. Anniversary Era and Anniversary TBC both use `Fresh`, so expansion plus season matters. General Hardcore detection also uses `C_GameRules.IsHardcoreActive()`.

### Timing and locations

Current implementation policy:

| Expansion/variant | Timing | Location |
|---|---|---|
| Era/nonseasonal Hardcore | Monday after the first Friday, 03:00 to next Monday 03:00 | Monthly Elwynn/Mulgore |
| SoM | Same monthly timing | Same rotation |
| Anniversary Era/Hardcore | Same monthly timing, unavailable before Anniversary phase 3 | Same rotation |
| TBC default and Anniversary TBC | Same monthly timing | January-first Mulgore, Elwynn, Terokkar rotation |
| SoD | Exact fourteen-day cycles from December 4, 2023 | Alternating Mulgore/Elwynn |
| WotLK default and explicit Titan | Native calendar timestamps | Native calendar identification of rotating locations |
| Cata/MoP | Native calendar timestamps | Darkmoon Island |
| Unlisted future expansions above MoP | Island/calendar fallback | Darkmoon Island |

The monthly rule is **not necessarily the first Monday**. August 2026, for example, opens on Monday August 10 under the current Era/TBC rule.

Calculated monthly windows include the start and exclude the closing 03:00 minute. Calendar windows currently include the returned ending minute, consistent with the user's reported 23:59 display, but the native endpoint interpretation still needs verification.

SoD's configured opening is 00:01 and ending is Sunday 23:59 inclusive. Its location and timing rules have separate anchors, so changing one source cannot freeze or change the other rotation accidentally.

Active versions reported by David: Era, Anniversary TBC, Titan WotLK, and MoP. Original TBC/WotLK and Cata are not currently active. David subsequently clarified that WotLK should use the calendar by default, not only through a Titan override. Do not claim all original-client behavior was empirically verified merely because defaults are configured.

## Current flow and file map

### Resolver

`Database/Corrections/Holidays/DarkmoonFaire.lua`:

- Owns expansion/season rules, civil-date calculations, calendar lookup, and location resolution.
- `GetCurrentState(calendarReady)` returns a table with status `active`, `inactive`, `pending`, or `unavailable`.
- Active results include a location. Calendar-timed results also retain native start/end timestamps.
- Uses Gregorian civil-day arithmetic, not local `os.time`, for recurrence and comparison.
- Calculated timing with calendar location searches the calculated occurrence's days. Searching only today was wrong on a calculated closing Monday absent from the native Sunday-through-Saturday calendar.
- Calendar timing with calculated location retains the native timing while resolving location separately.
- Temporarily enables `calendarShowDarkmoon` while reading and restores the previous value, including on protected query failures.
- Uses current calendar month/year to calculate query offsets; it does not assume the displayed calendar is on the current month.
- Currently identifies locations from **`GetHolidayInfo().texture`**, not `GetDayEvent().iconTexture`. This is an open finding, not a completed fix.

### Startup and application

`Database/Corrections/Holidays/QuestieEvent.lua`:

- `Initialize()` must execute inside the existing ThreadLib startup coroutine.
- Calculated schedules resolve without requesting a native calendar list.
- Calendar-backed schedules register a list listener, a 0.25-second retry ticker, and a five-second timeout.
- Callbacks only publish the resolved snapshot and cancel their resources.
- The owning coroutine waits, then invokes `Load()` to apply corrections. This avoids the former design where an async application error stranded startup waiting forever.
- Timeout/unavailable data does not trigger a guessed DMF schedule. Other holidays still initialize.
- Resolution remains a one-shot startup snapshot. There is no live opening/closing/location-transition refresh.

`Modules/QuestieInit.lua` calls holiday initialization before `QuestieDB:Initialize()` and downstream quest drawing. All five supported TOCs include the resolver and correction module.

The old code returned from holiday initialization before the calendar callback completed. Runtime override tables were live references, but `QuestieDB:GetNPC()` could already have cached an old adapted NPC. Waiting before DB initialization removes that race.

### Quest and NPC application

`Database/Corrections/Holidays/quests/DarkmoonFaire.lua` registers event quest IDs. `QuestieEvent` uses each entry's seventh field, `hideQuest`, to preserve exclusions during an active Faire.

`Database/Corrections/Holidays/darkmoonFaireFixes.lua` contains exact copies of the original mainland correction coordinates for NPCs:

`14828, 14829, 14832, 14833, 14841, 14871`.

`_LoadDarkmoonFaire` intentionally:

- Activates eligible DMF quests.
- Calls `GetNpcFixes(location)` and uses `if npcFixes then`.
- Assigns mainland records to `QuestieDB.npcDataOverrides` even when no event quest is visible.
- Preserves normal island NPC spawns because island fixes return nil.
- Enables Horde announcement 7926 in Mulgore, Alliance announcement 7905 in Elwynn, and both in Terokkar **and on the island**.
- Uses one localized location announcement for every location, without an island early return.

Do not add an “only if override missing” condition or redirect these writes to compile-time `QuestieCorrections.npcData`. Mainland location corrections intentionally win over existing runtime location data.

The runtime assignment replaces an override record, not the complete compiled NPC row. Query handles fall back to compiled values for fields absent from the override. This preserves names, quest relationships, and static SoD corrections. The audit found no earlier faction/content runtime overrides for these six IDs today. Losing other fields from a future runtime override remains a defensive concern, not a demonstrated current bug.

## Implemented fixes and independently established behavior

### Island announcements must remain active

A previous assistant incorrectly assumed quests 7905/7926 were obsolete on the island and wrote tests that confirmed that assumption. **That regression has been corrected. Do not repeat it.**

Independent evidence:

- `Database/Corrections/cataQuestFixes.lua` changes the questgivers to Mystic Mages.
- Cata/MoP quest DBs retain 7905 and 7926, starting at Alliance Mystic Mage 54334 / Horde Mystic Mage 55382 and ending at Gelvas Grimegate 14828.
- Classic quest corrections supply faction race masks; activating both does not make both available to each faction.
- `QuestieDB.IsDoable` enforces race requirements after checking hidden quests.

`"Darkmoon Island"` and the template `"The Darkmoon Faire is up in %s!"` already have all ten supported locales in `Localization/Translations/Events.lua`. No new translations were needed.

### Island NPC zone IDs

The six NPCs already had island-only spawns through Cata corrections, but their `zoneID` still identified Elwynn or Terokkar. Map pins used `spawns` and were correct; zone-based link text could be wrong.

`dbeafc357` adds `zoneID = zoneIDs.DARKMOON_FAIRE_ISLAND` to those six existing Cata correction entries. MoP inherits them. Coordinates, sentinel coordinates, and quest relationships were not changed.

### SoD decks

`5957792d3`:

- Preserves SoD's phase-8 “Never appearing” blacklist for original deck quests 7907, 7927, 7928, 7929 by setting their registry `hideQuest` field on SoD.
- Registers eight SoD deck quests: 82055–82058 and 86760–86763.
- Replacement mapping: 7907→86760, 7928→86761, 7929→86762, 7927→86763.
- The existing database already provides starter-item links and turn-in to Professor Thaddeus Paleo, NPC 14847. No new relationship corrections were needed.

Why registration matters: `Modules/Quest/QuestFinisher.lua` checks `IsEventQuest`, `IsEventActiveForQuest`, and `CanQuestBeTurnedInOutsideOfEvent`. Without event registration, these decks bypassed event-specific finisher suppression.

Item-started deck quests can be accepted outside the Faire. Event registration is not a blanket instruction to hide every deck quest outside the event. The existing fortune quests 7937/7938/7944/7945 retain their explicit outside-event turn-in exceptions.

**Still missing:** the entire SoD section is unconditionally registered. David explicitly requested a surrounding `if Questie.IsSoD then`; see the next section.

### Calendar compatibility contract

`995dceac0` preserves `QuestieCompat.GetCurrentCalendarTime()`'s complete `CalendarTime` return shape:

- Prefer native `C_DateAndTime.GetCurrentCalendarTime()` unchanged.
- Otherwise combine mapped `C_DateAndTime.GetTodaysDate()` with `GetGameTime()` hour/minute.
- If the required APIs are absent, raise the existing unsupported-API error.

An intermediate assistant edit returned a date-only result and changed the public type. David explicitly rejected that. **Do not reintroduce partial dates or absent hour/minute as the compatibility fix.** Do not fabricate midnight or use the computer's local clock. Tests cover nonzero legacy times, genuine midnight, native precedence, and unavailable legacy clock.

## Open findings and work to finish

### 1. Complete SoD-only registration guard

Status: explicitly requested, not implemented.

Wrap the whole `-- SoD quests` section in `Database/Corrections/Holidays/quests/DarkmoonFaire.lua`, including the existing material quests and all eight decks, in `if Questie.IsSoD then`.

Extend `quests/DarkmoonFaire.test.lua` to verify both:

- SoD registration and active/inactive finisher behavior.
- No SoD-specific event registration on Era, TBC, WotLK, Cata, or MoP outside SoD.

Retain original deck exclusions on SoD and normal original-deck behavior elsewhere. Do not rely on IDs being absent from an expansion's database as the registration guard.

### 2. Use the documented sequence texture field

Status: source-supported correction still pending; no confirmed live failure.

The current resolver reads `GetDayEvent` but maps location from `GetHolidayInfo().texture`. Blizzard's UI uses **`GetDayEvent().iconTexture`** as the holiday sequence/day artwork. Our DBC mappings are Start/Ongoing/End sequence IDs.

Change identification to the day-event field, keeping activity based on full timestamps. Specify the behavior for missing day records and nullable `iconTexture`; do not silently equate unrelated fields. Any compatibility fallback should be explicit and justified, not accidental.

Update fixtures so day and holiday records are distinct. Add a case where `dayEvent.iconTexture` and `holiday.texture` differ; assert the chosen location using the documented field. Test unrelated/player events and missing data as well.

The audit's original “High: wrong texture field” wording overstated certainty. Native implementations may populate both fields identically. Published source establishes which field Blizzard uses for sequence art, not a proven current-client mismatch.

### 3. Finish explicit season coverage and enum consistency

Status: still pending.

Published season enum includes `Hardcore = 3`. Current `VersionCheck.lua` fallback constants and the Era `seasons` table omit it. Add its explicit rule, even though the current Era default gives the same schedule.

`VersionCheck.lua` also still compares Titan against literal `109`, with an obsolete comment, despite defining `Enum.SeasonID.TitanReforged`. Use the named constant there.

Tests currently inject full enum tables and bypass actual `VersionCheck` bootstrap. Add one focused bootstrap test for missing/partial enums, preservation of supplied values, and successful resolver loading. NoSeason 0 should resolve through the expansion default.

### 4. Repair incomplete or misleading test expectations

Status: still pending in the current test files.

- Restore the previous general-holiday case where the event is active but the quest's own start date is tomorrow. The new test only differentiates hours on the same date.
- The test named “excludes setup” moves now before an ordinary open-Faire interval; it does not supply a genuine native setup-stage record. Rename it to its actual claim. Obtain native fixtures before claiming setup behavior is covered.
- Model filter setting, cached event-list refresh, and notification as separate states. Existing fixtures make data instantly available regardless of filter/readiness. This hides the question of whether an initially empty filtered list is authoritative.
- Include a synchronous notification emitted by `OpenCalendar` in lifecycle coverage; code review found the path sensible, but it lacks an explicit test.

Passing a test invented from the implementation is not evidence of the game rule. Ground expectations in original behavior, actual correction data, or captured native API values.

### 5. Native calendar verification

Status: no live client evidence obtained. This remains the principal release-confidence gap.

On matching Titan and MoP clients, capture build, project, season, region, current calendar time, and both calendar records for the same holiday entry:

- `C_Calendar.GetDayEvent(offset, day, index)`: `calendarType`, `sequenceType`, `iconTexture`, timestamps.
- `C_Calendar.GetHolidayInfo(offset, day, index)`: `texture`, nullable `startTime` and `endTime`.

Observe setup, opening minute, ongoing days, ending minute, and the next minute. Validate faction announcements and mainland/island positions as well. Verify Era/TBC calculated Monday boundaries against a client when available.

Questions to resolve:

- Does a setup-stage entry expose recognized artwork with setup timestamps, or is that stage invisible to players?
- Are start/end timestamps complete on each sequence day, and is the returned end minute inclusive?
- Do the two texture fields match or differ?
- Does changing `calendarShowDarkmoon` affect getters immediately?
- Can the first list notification contain zero events before a later populated result?
- How long does calendar readiness take on cold/congested login? Is five seconds sufficient?
- Are current-calendar and event timestamps in the same civil-time basis on the relevant clients? Do not add guessed China/EU offsets.

Blizzard's filter UI writes the CVar and immediately refreshes, supporting synchronous filtered queries. That is evidence, not proof of all native cache/network timing. A synchronous event declaration describes dispatch; it does not guarantee a response within five seconds.

### 6. WotLK announcement starters require confirmation

Status: introduced/exposed by the original WotLK support; game behavior unknown.

WotLK quests 7905/7926 name barkers 14842/14843, but the WotLK NPC rows have no starter spawns or waypoints. They can become active without drawable starter icons. The six carnival NPC corrections do not include the barkers.

Confirm whether the barkers/quests actually exist on Titan before adding coordinates or suppressing quests. Do not transfer the island Mystic Mage assumptions to WotLK.

### 7. Failure and lifecycle policies to consider separately

- **Five-second timeout is final for the session.** The resolver listener is removed and quest registration data discarded. A later ready calendar cannot recover DMF until reload. The warning is debug-only. This is intentional current behavior, but latency needs measurement.
- **Warning wording is too broad:** “its quests remain hidden” is not literally true for all item-started decks. Narrow the message to unresolved event visibility/turn-ins if changing it. It is currently English-only; project conventions for debug warnings should guide whether localization is needed.
- **Disable during startup remains unsafe.** `Questie:OnDisable()` does not cancel the outer ThreadLib job or raw calendar timers. AceEvent removes the listener, but timeout can resume initialization and eventually publish readiness after disable. This is an inherited general initialization problem, made more visible by the new wait. Keep a separate lifecycle fix unless David expands scope.
- Unexpected application errors now abort the owning startup coroutine rather than permitting initialization with partially applied holiday data. This intentionally increases holiday application failure impact while avoiding the former endless wait.
- `GetCVarBool` and restoration `SetCVar` are outside the resolver's query `pcall`. An exceptional failure can leave its reentrancy guard set until timeout. Timer construction failures are also not fully cleaned up. These are low-likelihood defensive concerns, not reproduced failures on supported clients.
- Whole-record runtime NPC override assignment could discard future non-location overrides for those six IDs. No current conflict was found. Preserve current precedence unless deliberately changing and testing it.
- The extracted data module retains three tiny location tables rather than allocating only the active one. The audit judged this negligible; do not add lazy-loading machinery without a reason.

## Data research and reproducibility

Detailed source citations, decoding masks, hashes, and download history are in:

`Database/Corrections/Holidays/DMF_DBC_FINDINGS.md`

That note contains historical wording: its reference to “current DMF_CALENDAR_ICON_TEXTURES” describes the older implementation. The current resolver uses `locationByTexture`. Use this handoff and current code for implementation status.

Downloaded artifacts on the original machine:

```text
/tmp/questie-dbc-v2026.09.07/
    dbc-raw.tar.xz
    raw/                         # 2,052 CSVs
    dbc-source.db.xz
    dbc-source.db
    manifest.json
    inspect_holidays.py
    decoded-holidays.txt
    newer/Holidays.5.5.4.69585.csv
    newer/decoded-holidays.txt
```

These temporary files and decoder are not committed and may not exist on another machine. Re-download the release with authenticated `gh` if necessary. Unauthenticated requests returned 404 because `Questie/dbc` was private during this work.

- Release: <https://github.com/Questie/dbc/releases/tag/v2026.09.07>
- Newer MoP Holidays: <https://wago.tools/db2/Holidays/csv?build=5.5.4.69585>

Important learned facts:

- `HolidayNameID = 1` identifies the DMF family, not one location or occurrence.
- Holiday rows: 374 Elwynn, 375 Mulgore, 376 Terokkar, 479 modern/island Faire.
- `Date_N` values are packed calendar components, not Unix timestamps or alternating start/end pairs.
- `[48,168]` durations describe successive candidate setup/open stages in hours. The selected date plus 48 hours gives the candidate Faire opening boundary.
- Decoding Titan August 2026 yields July 31 00:00 + 48h = August 2 00:00; +168h = August 9 00:00. This matches the user's August 2–8 Elwynn observation at the day level.
- Newer MoP gives September 4 00:00 +48h = September 6; +168h = September 13, matching the user's September 6–12 observation at the day level.
- The observed UI 00:01/23:59 minutes are not directly stored in those midnight boundaries.
- The release's MoP Holidays CSV is pinned to 5.5.3.66839 despite containing newer builds for other tables. Directly downloading 5.5.4.69585 supplied the missing September data.
- The newer MoP list has 26 fortnightly openings, July 12, 2026 through June 27, 2027. Do not hardcode “first Sunday each month” for MoP.
- Era/TBC snapshots contain no matching DMF rows. Cata data is historical. No universal schedule can be inferred solely from those files.
- Static date lists expire and server overrides may exist. We chose not to ship those lists.
- Packed dates do not encode an explicit timezone offset. Region masks are not `GetCurrentRegion()` numeric IDs or offsets.
- The old SoD cycle used a 6-day 23h58m event duration; doubling it made the recurrence four minutes short of fourteen days. Civil-day recurrence fixes that drift and avoids machine-timezone/DST effects.

### Texture sets

| Location | Start | Ongoing | End |
|---|---|---|---|
| Elwynn / island | 235448 | 235447 | 235446 |
| Mulgore | 235451 | 235450 | 235449 |
| Terokkar | 235455 | 235454 | 235453 |

Island and Elwynn share artwork. Expansion/location policy distinguishes them. Texture identifies the event/location; timestamps determine activity. `sequenceType` identifies START/ONGOING/END in Blizzard's day record.

### Published UI sources

Source cache used:

- `~/.cache/wow-ui-source/classic`, Mists build 5.5.4.69585, commit `ecadf9d3326fa87828cacca7f13c0ab5f41840a6`.
- `~/.cache/wow-ui-source/classic_titan`, Titan build 3.80.2.69496, commit `ba472e5e1b5580b557e3dbf02c9e5ff23b223347`.

Pinned Titan examples:

- [Calendar declarations](https://github.com/Gethe/wow-ui-source/blob/ba472e5e1b5580b557e3dbf02c9e5ff23b223347/Interface/AddOns/Blizzard_APIDocumentationGenerated/CalendarDocumentation.lua): day-record fields around 961–985, holiday fields around 1101–1110.
- [Calendar UI](https://github.com/Gethe/wow-ui-source/blob/ba472e5e1b5580b557e3dbf02c9e5ff23b223347/Interface/AddOns/Blizzard_Calendar/Classic/Blizzard_Calendar.lua): filter refresh around 1051–1058; sequence texture around 1660–1687; holiday timestamp display around 2461–2467.
- [Season enums](https://github.com/Gethe/wow-ui-source/blob/ba472e5e1b5580b557e3dbf02c9e5ff23b223347/Interface/AddOns/Blizzard_APIDocumentationGenerated/SeasonsConstantsDocumentation.lua).

Read the `wow-ui-source` skill before further source investigation. Channel names move between expansions; record exact source builds. Native C++/server behavior is not established by Lua declarations alone. TrinityCore decoding evidence in the research note is emulator implementation, not an official Blizzard runtime contract.

## Validation and audit history

Last full-suite run after the compatibility correction:

```text
1831 successes / 0 failures / 0 errors / 0 pending
```

The compatibility files passed luacheck and `git diff --check`. Earlier targeted DMF/data lint checks also passed. Re-run after new fixes; do not treat this count as evidence that the pending SoD guard, Hardcore rule, or texture fix exists.

Useful commands:

```bash
busted Modules/QuestieCompat.test.lua
busted Database/Corrections/Holidays/DarkmoonFaire.test.lua \
    Database/Corrections/Holidays/QuestieEvent.test.lua \
    Database/Corrections/Holidays/darkmoonFaireFixes.test.lua \
    Database/Corrections/Holidays/quests/DarkmoonFaire.test.lua \
    Database/Corrections/cataNPCFixes.test.lua
busted -p '.test.lua' .
luacheck -q -- Database/Corrections/Holidays Modules/QuestieCompat.lua \
    Modules/QuestieCompat.test.lua Modules/VersionCheck.lua
# Also lint other changed files explicitly.
git diff --check
```

Five read-only agents traced lifecycle, schedule/season/calendar, quest/faction semantics, NPC data/consumers, and test expectations against both older revisions. The schedule agent's tool call reported a WebSocket error, but its full final report was recovered from its saved session. No investigation needed to be repeated for lack of that report.

Audit proof included exact recursive parity between old mainland loaders and the extracted correction tables, actual Cata/MoP quest/NPC rows, phase-blacklist data, and an independent civil-date comparison over 73,414 dates from 1900–2100. These strengthen local correctness, not native API assumptions.

Use fresh focused review for calendar/lifecycle/public compatibility changes. Reviewers must distinguish inherited issues, intended changes, confirmed regressions, and runtime hypotheses. Avoid another broad audit unless a concrete unresolved question requires it.
