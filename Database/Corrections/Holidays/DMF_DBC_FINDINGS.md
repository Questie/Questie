# Darkmoon Faire DBC date encoding

## Scope and conclusion

Inspected the raw CSVs and SQLite database from [Questie/dbc v2026.09.07](https://github.com/Questie/dbc/releases/tag/v2026.09.07), then downloaded a newer Mists Holidays CSV directly from wago.tools. No live client was queried.

**We can decode explicit occurrence dates and derive stage boundaries. Both the Titan August 2026 and Mists September 2026 examples match at the day level.** The release's pinned Mists snapshot lacks September coverage, but the separately downloaded `5.5.4.69585` CSV supplies it. Era and TBC have no rows with `HolidayNameID = 1` in the release snapshots. Exact displayed minutes and timezone behavior remain unverified.

`Date_N` values are packed calendar components, not Unix timestamps or alternating start/end pairs. For the DMF rows inspected, `Duration_0 = 48` and `Duration_1 = 168`: the candidate setup start is followed by two days of setup, then seven days of Faire time. Stage interpretation is supported by the emulator implementation below and the user's Titan observation, not a direct inspection of Blizzard's native conversion.

## Download and reproducibility

Downloaded all three release assets to `/tmp/questie-dbc-v2026.09.07/`:

- `dbc-raw.tar.xz`, extracted into `raw/` (2052 CSV files, roughly 3 GiB uncompressed).
- `dbc-source.db.xz`, decompressed to `dbc-source.db` (218 MiB).
- `manifest.json`.

SHA-256 hashes matched all three release asset digests:

```text
dbc-raw.tar.xz    dbec30262f1edf3db281406cdc1e51aa4f433e313bf6a2dd00ff7ac88cd21786
dbc-source.db.xz  c592475683e85ff713ed4160e6f64c1ac88a1655eb0feab6d04a87c8f512d533
manifest.json    58dc0d2d859b5d4b1ea8b263b6057a11b2d40ddd50fe1b959408ce2051637406
```

`inspect_holidays.py` in that directory produces `decoded-holidays.txt` using Python stdlib CSV, SQLite (read-only), and datetime operations:

```bash
uv run --no-project /tmp/questie-dbc-v2026.09.07/inspect_holidays.py
```

The release source commit is `f16bf1465b96228ed913b4addbc543a595602666`. Release date does not mean every table was extracted from the newest client: WotLK and Mists export builds are pinned. The raw archive contains one Holidays CSV per expansion. SQLite's DMF `_first_seen`/`_last_seen` fields likewise point to those snapshots, not newer ingested builds.

## Actual DMF rows

Sources: the named `raw/Holidays.<build>.csv` files, `holiday_descriptions` in the unpacked SQLite database, and the release's build-coverage description.

| Holiday ID | Description ID | Location identified by description |
|---|---|---|
| 374 | 1 | Elwynn Forest |
| 375 | 26 | Foot of Thunder Bluff (Mulgore) |
| 376 | 27 | Outside Shattrath City (Terokkar) |
| 479 | 201 | Generic modern Faire description; treated as the island-era row here |

All these rows have `HolidayNameID = 1`, `Region = 0`, `Looping = 0`, `CalendarFilterType = 1`, and `WorldStateExpressionID = 0`. They have stage durations `[48, 168]` and calendar flags `[0, 3]` followed by zeroes. HolidayNameID identifies the family, not a particular location.

### Titan: August observation matches the dates

In `Holidays.3.80.0.66566.csv`, holiday **374 (Elwynn)** contains:

```text
Date_7       = 443004928
Decoded      = 2026-07-31 00:00 (Friday; no timezone encoded)
+ Duration_0 = 2026-08-02 00:00 (Sunday, start of the 168-hour stage)
+ Duration_1 = 2026-08-09 00:00 (following Sunday, stage boundary)
```

This agrees with the user's August 2 through August 8 observation at the calendar-day level, assuming year 2026 and month/day input. It does not itself encode opening at 00:01 or closing at 23:59. Those are one minute inside the derived boundaries; do not add those adjustments globally without checking the native calendar results.

The 2026 rows explicitly assign January/April/July/October to Terokkar, February/May/August/November to Elwynn, and March/June/September/December to Mulgore. This supports the branch's Titan rotation with more than just its existing January news citation. It does not establish the non-Titan WotLK rotation because this snapshot is from the 3.80 client.

The three locations also have distinct texture sets:

- Elwynn: `235448, 235447, 235446`.
- Mulgore: `235451, 235450, 235449`.
- Terokkar: `235455, 235454, 235453`.

Questie's current `DMF_CALENDAR_ICON_TEXTURES` recognizes only the Elwynn set, which is also used by the island row. A calendar-based rotating-Faire implementation must account for all three sets and verify actual client results. These identifiers offer a nonlocalized way to distinguish locations.

### Mists: September observation cannot be checked from this snapshot

`Holidays.5.5.3.66839.csv` has zero dates in the three legacy location rows. Holiday **479** contains 26 explicit dates. Adding the 48-hour setup gives Faire openings from **2025-07-13 through 2026-06-28**, every fourteen days. The final stage ends **2026-07-05 00:00**.

There is no September 6, 2026 entry. Neither SQLite nor the raw archive contains a newer Mists Holidays snapshot in this release, even though other tables/build metadata include `5.5.4.69585`. With `Looping = 0`, extrapolating this list would be an extra assumption, not a directly decoded result. This also shows why “first Sunday of every month” is not a safe universal Mists rule.

### Follow-up: newer Mists CSV confirms September

The release raw archive does contain newer `5.5.4` CSVs for other tables, but not Holidays. The repository's current Git tree has no tracked CSV data either. Downloaded [Holidays for build 5.5.4.69585 directly from wago.tools](https://wago.tools/db2/Holidays/csv?build=5.5.4.69585), the same upstream used by the DBC repository. This is a separate acquisition, not part of the release artifact.

Saved to `/tmp/questie-dbc-v2026.09.07/newer/Holidays.5.5.4.69585.csv` with SHA-256 `16d3c44a8afaf50d521b4481c9ec53339e2285acd91d7184df1f3839b6dd6fe8`. Decoded output is `newer/decoded-holidays.txt`. Reproduce with:

```bash
uv run --no-project /tmp/questie-dbc-v2026.09.07/inspect_holidays.py /tmp/questie-dbc-v2026.09.07/newer
```

Holiday 479 has the same metadata and `[48, 168]` durations, but its 26 occurrence dates now give fortnightly Faire openings from **2026-07-12 through 2027-06-27**. The final stage boundary is July 4, 2027. In particular:

```text
Date_4       = 444659712
Decoded      = 2026-09-04 00:00 (Friday)
+ Duration_0 = 2026-09-06 00:00 (Sunday)
+ Duration_1 = 2026-09-13 00:00 (following Sunday)
```

This matches the user's **September 6–12, 2026** observation at the day level, assuming day/month input. As with Titan, `00:01` and `23:59` lie one minute inside the derived boundaries and are not stored literally in this row. No timezone offset was applied. Legacy rows 374–376 still have zero dates.

This removes the missing-September-data obstacle: updated CSVs can supply the explicit schedule. It does not remove the need to refresh finite date coverage or verify exact native timestamp semantics.

### Cata, Era, and TBC coverage

- `Holidays.4.4.2.60895.csv` retains old rotating-location dates and has holiday 479 with fortnightly openings from December 2024 through July 2025. A name-only filter would include stale legacy locations. This is not a 2026 Cata schedule.
- `Holidays.1.15.9.69547.csv` and `Holidays.2.5.6.69546.csv` contain no rows with `HolidayNameID = 1`. This release cannot supply their DMF dates through that filter.

## Working-copy implementation

`Database/Corrections/Holidays/DarkmoonFaire.lua` now owns schedule and location resolution. Its `rules` table contains expansion defaults and explicit known season entries. Each season can replace the complete `timing` or `location` rule independently; omitted rules inherit the expansion default. These are code configuration, not saved user settings.

- Era, SoM, Anniversary Era/Hardcore, TBC, and Anniversary TBC use the Monday after the first Friday, from 03:00 through the following Monday at 03:00 (exclusive). Anniversary Era/Hardcore retain phase-3 availability gating.
- SoD uses its December 4, 2023 anchor, exact fourteen-civil-day recurrence, and alternating Mulgore/Elwynn locations. Civil-day arithmetic removes the old accumulating two-minute cycle error and does not depend on the computer's timezone.
- WotLK defaults and explicit Titan season 109 use native calendar timestamps and the three DBC-derived texture sets for location. Cata/MoP use native timing and fixed island location. Unlisted future expansions use the island/calendar default.
- Calculated timing can be paired with calendar location. That lookup searches the configured occurrence's days, because its closing Monday can lack a native calendar event. A fortnightly location rule has its own anchor, independent of timing.
- No raw DBC date list is shipped or extrapolated. The live calendar resolves the occurrence.

`DarkmoonFaire.GetCurrentState(calendarReady)` returns `active` (with a location), `inactive`, `pending`, or `unavailable`. Native timestamp comparisons include the returned ending minute; calculated monthly endings exclude the configured closing minute. The native ending convention still needs the runtime check below.

`QuestieEvent.Initialize()` runs in the existing ThreadLib startup coroutine. It requests the calendar only when needed, retries incomplete data, and waits at most five seconds. Callbacks publish the result and release their listener/timers; the owning coroutine applies quest/NPC changes before DB consumers initialize. A timeout or unavailable API leaves DMF hidden, emits a debug warning, and still initializes other holidays. Unexpected correction errors propagate through the owning coroutine instead of leaving startup yielding forever.

Calendar queries restore the player's DMF visibility filter, including on query errors. Island results keep normal NPC database spawns and both faction announcement quests (7905 and 7926), which Cata/MoP reuse with Mystic Mage questgivers. Startup remains a one-shot snapshot; opening/closing while logged in still requires a reload to refresh event state.

### In-game verification still needed

On Titan and MoP, inspect `C_Calendar.GetHolidayInfo` for DMF while the calendar filter is enabled and the event list is loaded. Record full timestamps, texture, client build, season ID, and current server calendar time. Check setup, the opening minute, and the final minute. Confirm that setup does not expose setup-stage timestamps with a recognized open-Faire texture. Compare the result against `QuestieLoader:ImportModule("DarkmoonFaire").GetCurrentState(true)` after calendar readiness. No live client was touched during implementation.

## Packed date fields

TrinityCore's [`WowTime::SetPackedTime`](https://github.com/TrinityCore/TrinityCore/blob/3eca31e2b80b39235aa1af430df42a9dd0009d90/src/server/game/Time/WowTime.cpp#L23-L63) gives the following layout. This is primary evidence for TrinityCore's implementation, not an official Blizzard client specification.

| Component | Extraction from unsigned `value` | All-ones sentinel |
|---|---|---|
| Minute | `value & 0x3F` | 63 |
| Hour | `(value >> 6) & 0x1F` | 31 |
| Weekday | `(value >> 11) & 0x7` | 7 |
| Day of month, zero-based | `(value >> 14) & 0x3F` | 63 |
| Month, zero-based | `(value >> 20) & 0xF` | 15 |
| Year offset from 2000 | `(value >> 24) & 0x1F` | 31 |
| Packed time flags | `(value >> 29) & 0x3` | 3 |

The implementation converts each all-ones sentinel to `-1`, meaning unspecified. Check the sentinel before adding one to month/day or adding 2000 to year. Do not decode year 31 as 2031. These packed time flags are distinct from the Holidays row's `Flags` and `CalendarFlags_N` fields.

The [Unix conversion code](https://github.com/TrinityCore/TrinityCore/blob/3eca31e2b80b39235aa1af430df42a9dd0009d90/src/server/game/Time/WowTime.cpp#L65-L98) confirms the zero-based day/month and year offset. The weekday follows C `tm_wday`, so Sunday is zero. It also confirms that the packed value stores calendar components rather than an epoch timestamp. The meaning of nonzero packed time flags is not established here.

For a fully specified non-sentinel value, a dependency-free Python decoder is:

```python
minute = value & 63
hour = (value >> 6) & 31
weekday = (value >> 11) & 7
month_day = ((value >> 14) & 63) + 1
month = ((value >> 20) & 15) + 1
year = ((value >> 24) & 31) + 2000
flags = (value >> 29) & 3
```

Do not construct a Python datetime from unspecified components. In particular, unspecified year/month/day can indicate a recurring calendar pattern rather than an invalid record. The exact client interpretation of such a pattern needs separate verification; the basic bit decoder does not resolve it.

## Dates, durations, stages, and recurrence

TrinityCore's [`GameEventMgr::SetHolidayEventTime`](https://github.com/TrinityCore/TrinityCore/blob/3eca31e2b80b39235aa1af430df42a9dd0009d90/src/server/game/Events/GameEventMgr.cpp#L1682-L1751) treats:

- `Date_N` as successive candidate occurrence starts, stopping at the first zero entry.
- `Duration_N` as stage durations in hours, not end timestamps.
- Stage `i` as beginning after the sum of durations for preceding stages.
- `CalendarFilterType == -1` as yearly; `0` as weekly; `1` as defined dates only (the code explicitly names Darkmoon Faire); `2` as looping-event usage.
- `Looping != 0` as a repeating cycle whose period is the sum of nonzero stage durations.
- An unspecified year as a yearly occurrence requiring a concrete year before comparison.

Consequently, a row with durations `[72, 168]` means two successive stages: 72 hours followed by 168 hours. Whether those are setup and open-Faire stages must be established from that row's description and observed calendar behavior. It is not a 72-hour event plus an unrelated 168-hour event at `Date_1`.

This is server-emulator scheduling behavior. It supports interpretation of the table but does not prove that modern Classic's native calendar uses identical recurrence or stage-display rules. Do not assume that 168 hours added to an encoded `00:00` mechanically yields the UI's `00:01` opening and `23:59` ending. Those minute conventions need corroboration.

## Region, calendar flags, and filtering

The reverse-engineered [WoWDBDefs Holidays schema](https://github.com/wowdev/WoWDBDefs/blob/d0cc6370847f0c6ae3bfb970ad9520be253276f5/definitions/Holidays.dbd#L1-L16) describes `Region` as a bitmask of `Cfg_Region.Region_group_mask`: US `1`, KR `2`, EU `4`, TW `8`, CN `16`, with further bits for other environments. This is community schema documentation, not an official contract. Do not treat it as the numeric `GetCurrentRegion()` return value, and do not assume it is a timezone offset.

That schema labels `CalendarFlags` with Alliance/Horde bits and row `Flags` with region-wide and calendar-visibility bits. These comments alone are insufficient evidence to implement modern Classic selection or stage behavior. Preserve the fields during inspection instead of dropping them. `WorldStateExpressionID`, when present, is another potential selection condition; its semantics are not resolved here.

`HolidayNameID` references a shared name, not a unique occurrence, location, or ruleset. All rows with the DMF name must be inspected with their description, build, dates, flags, and region. A name-only filter identifies candidates; it does not establish which row the current realm uses.

## Timezones and server overrides

There is no explicit UTC offset in the packed date layout. An hour can be decoded, but its time basis cannot be inferred from the bits alone.

This limitation is visible even within TrinityCore: the [3.3.5 scheduling implementation](https://github.com/TrinityCore/TrinityCore/blob/65f4f04650ae5c91bda174703d0043891d12b34d/src/server/game/Events/GameEventMgr.cpp#L1770-L1818) uses `mktime` (process-local timezone), whereas the newer implementation calls `GetUnixTimeFromUtcTime`, which uses `timegm`. Neither implementation proves the live Titan or Mists server/client convention. Do not apply a speculative China/EU offset just because the observed date came from that region.

The [3.3.5 holiday override loader](https://github.com/TrinityCore/TrinityCore/blob/65f4f04650ae5c91bda174703d0043891d12b34d/src/server/game/Events/GameEventMgr.cpp#L943-L987) changes DBC dates and durations from the server database. Its [calendar handler](https://github.com/TrinityCore/TrinityCore/blob/65f4f04650ae5c91bda174703d0043891d12b34d/src/server/game/Handlers/CalendarHandler.cpp#L134-L154) sends modified dates, durations, region, looping, and calendar flags to the client. This demonstrates a supported server-emulator override path. It does not prove Blizzard currently overrides a particular DMF row, but it means static files should not be assumed to be the final live calendar authority.

The matching cached Blizzard [Titan calendar UI](https://github.com/Gethe/wow-ui-source/blob/ba472e5e1b5580b557e3dbf02c9e5ff23b223347/Interface/AddOns/Blizzard_Calendar/Classic/Blizzard_Calendar.lua#L2461-L2466) displays the `startTime` and `endTime` returned by `C_Calendar.GetHolidayInfo`. These native results are a useful read-only runtime comparison for decoded raw data. The Lua UI does not expose the underlying native DBC-to-calendar conversion.

## Validation still required

For each user-observed occurrence, record the year, client build, region, season ID, holiday description/location, and complete `C_Calendar.GetHolidayInfo` result. Compare those with the selected row, not just all rows sharing `HolidayNameID = 1`.

The supplied date formats appear to differ: Titan `8/02` through `8/08` appears to mean August 2–8; Mists `6/9` through `12/9` appears to mean September 6–12. Confirm the year and interpretation before treating a match as evidence. In 2026 both intervals run Sunday through Saturday.

The initial research inspected the cited implementations, schema, and downloaded data. The subsequent working-copy implementation is described above and validated with offline tests; no live-client timing claim was tested.
