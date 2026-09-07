# MoP live calendar findings

## Scope

David authorized calendar testing through the active WoW Lua bridge on September 7, 2026. These observations supplement `DMF_CONTINUE.md`; they do not establish release readiness.

- Client: MoP 5.5.4, build 69585, build date August 27, 2026, interface 50504.
- `WOW_PROJECT_ID`: 19. `GetCurrentRegion()`: 3 (EU).
- `C_Seasons.HasActiveSeason()`: false. `GetActiveSeason()` returned nil.
- Native calendar time during testing: September 7, 2026, approximately 17:44–17:52.
- Installed Questie metadata: 11.36.2. Repository under investigation: `DMF-locations-fixes`, `92bd83e9a`.
- The calendar was already open and populated at the first query. This was not a cold-login test.

No addon installation, database, quest state, or NPC overrides were changed. Probes temporarily changed the Darkmoon filter and selected calendar month, then restored filter `1` and September 2026. Temporary listeners were unregistered and timer probes finished. No UI reload occurred.

## Confirmed native records

The September calendar contains two Darkmoon Faire occurrences, both holiday event ID **479**:

| Opening | Closing |
|---|---|
| September 6, 2026, 00:01 | September 12, 2026, 23:59 |
| September 20, 2026, 00:01 | September 26, 2026, 23:59 |

For all fourteen sequence days:

- `GetDayEvent().calendarType` is `HOLIDAY`.
- Both APIs return the complete occurrence's start/end timestamps, not just that day's interval.
- `GetDayEvent().iconTexture` and `GetHolidayInfo().texture` match.
- START uses 235448, ONGOING uses 235447, END uses 235446.
- `numSequenceDays` is 7; `sequenceIndex` runs from 1 through 7.

September 4–5 have no DMF entry. September 13 has no DMF entry. The full September scan also found no separate DMF setup record for the second occurrence. This establishes the queried calendar representation, not whether the world has a separate setup stage.

The texture-field finding is therefore **not a demonstrated mismatch on this MoP build**. The published day-event field remains the documented sequence-art source, but current holiday textures also distinguish all three stages here.

Other native records demonstrate real nullable fields:

- Call to Arms: Twin Peaks (436) has timestamps but no texture in either API.
- Stranglethorn Fishing Extravaganza (301) has day-event timestamps, while its holiday-info record omits start/end timestamps.
- Querying a missing September 7 record with October selected returned nil from both record getters without throwing.

These are useful independent fixtures. Unrelated holidays must not become DMF candidates because fields are missing.

## Filter and notification behavior

With September selected and an already-loaded calendar:

1. Today's count was 2: DMF and Call to Arms: Twin Peaks.
2. `SetCVar("calendarShowDarkmoon", "0")` immediately changed the count to 1 and removed DMF.
3. Setting it to `"1"` immediately restored count 2 and the DMF record.
4. Neither filter change emitted a list notification in the observed probe.
5. `OpenCalendar()` emitted no list notification during the five-second observation.
6. `SetMonth(0)` emitted `CALENDAR_UPDATE_EVENT_LIST` synchronously, before returning. That notification already had populated data.
7. Samples on the next frame and after 0.25, 1, and 5 seconds remained populated.

A separate probe started with the filter hidden. Inside the synchronous `SetMonth(0)` notification, enabling the filter immediately exposed DMF; restoring the hidden filter immediately removed it again. This supports the resolver's temporary-filter strategy for a warm calendar on this build.

It does not prove cold-login cache readiness, server response latency, or that the first notification can never contain incomplete data.

## New finding: selected month can produce false inactivity

Offset arithmetic alone does not guarantee that native event records are available.

At the same real date and time, with the filter enabled:

| Selected month | Offset for September 7 | Native result |
|---|---|---|
| September 2026 | 0 | Two events, including active DMF |
| October 2026 | -1 | Zero events; both record getters return nil at index 1 |
| August 2026 | +1 | Two events, including active DMF |

The October-selected result remained empty during the synchronous list notification, immediately afterward, on the next frame, and after 0.25 and 1 seconds. Repeating `OpenCalendar()` and `SetMonth(0)` did not recover September 7.

**`SetMonth(0)` does not select the current real month.** With October selected, it left October selected. `SetAbsMonth(9, 2026)` restored September and the expected data.

This is not a blanket failure of negative offsets. With October selected, later September dates returned some events: September 20 returned 2 and September 26 returned 4. The native event availability range or selection policy has not been established. A zero count for an off-base date is not sufficient evidence that DMF is inactive.

### Pre-fix resolver corroboration

The repository's `DarkmoonFaire.lua` was evaluated through the bridge in an isolated Lua environment, not registered with the running Questie loader. The environment supplied the project's expansion constants, season fallback constants, an unused ContentPhases table, and a clock adapter directly calling the native API. Calendar APIs and CVars were real. No holiday initialization or correction application ran.

The bridge collapses repeated spaces in transmitted source strings. The evaluated source was whitespace-normalized; a follow-up source-length check detected this transport behavior. Inspection of a returned source fragment confirmed collapsed indentation. Do not describe this as a byte-identical addon deployment or a normal-startup test.

The resolver probe returned:

- September selected: `active`, `DARKMOON_ISLAND`, with native September 6–12 timestamps.
- October selected: **`inactive`**, despite the real date being September 7.
- August selected: `active`, `DARKMOON_ISLAND`.
- September selected with the filter initially hidden: `active`, and the filter remained hidden afterward.
- `calendarReady = false`: `pending`.

The native observations and resolver control flow independently explain the false inactive result: `_ReadCalendar` treats zero events as authoritative, and initialization's `SetMonth(0)` does not normalize the selected month.

The repository fix now selects the queried absolute month before reading events at offset `0`, including each month needed by a calculated occurrence. It restores the original month and filter before returning, including after incomplete data or query errors. Both restorations are attempted even if one throws. Calculated schedules without calendar dependencies still make no calendar requests.

Focused tests reproduce the captured false-empty query and verify synchronous notification handling during selection and restoration. No corrected build was deployed to the client. The frequency of this condition during ordinary addon startup remains unmeasured.

## Still unverified

- Actual world behavior at the opening minute, closing minute, and following minute. Native endpoint values were captured; inclusive world activity was not observed at those times.
- Cold-login notifications, initially incomplete lists, and the five-second timeout under latency.
- Titan's full startup behavior, Terokkar artwork, and announcement questgivers. The later [tester captures](DMF_TITAN_TESTER_FINDINGS.md) confirm Elwynn/Mulgore artwork and August/September holiday timestamps.
- Era/TBC world timing boundaries.
- Faction announcement visibility and NPC positions in the world.
- Any unusual timezone relationship at a date boundary.
- Full branch startup through the installed addon's normal loading path.

## Raw captures

JSON captures are local scratch files, not committed fixtures:

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

One navigation response failed screenshot decoding. A subsequent read confirmed the original month/filter were restored; the navigation probes were then repeated successfully. The first attempt to submit the entire resolver exceeded the bridge's 3,900-character request limit and did not execute. Chunked submission allowed the isolated evaluation described above.
