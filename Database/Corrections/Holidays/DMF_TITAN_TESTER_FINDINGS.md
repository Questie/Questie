# Titan calendar tester findings

## Source and scope

Logon relayed compact native calendar output from his Chinese Titan tester. The returned clock was September 8, 2026, 00:04. The tester did not supply a client build, region API value, or season ID, so these captures must not be attributed to a specific build.

The probes read `GetDayEvent` and `GetHolidayInfo`. They did not test this branch's startup, NPC positions, announcements, or actual opening/closing transitions.

## Captured records

| Occurrence | Location | Day-event ID | Sequence | Day `iconTexture` | Holiday `texture` |
|---|---|---:|---|---:|---:|
| August 2–8, 2026 | Elwynn Forest | 374 | END | 235446 | 235446 |
| September 6–12, 2026 | Mulgore | 375 | ONGOING | 235450 | 235450 |

The timestamps were:

| Occurrence | Native start | Native end |
|---|---|---|
| August | 2026-08-02 00:01 | 2026-08-08 23:59 |
| September | 2026-09-06 00:01 | 2026-09-12 23:59 |

These values match the existing location texture mappings. There is no demonstrated difference between the two texture fields in either captured record. `END` identifies the final sequence day, not proof that the Faire has already closed at the current clock time.

Logon confirmed the expected Titan rotation: August Elwynn, September Mulgore, October Terokkar. **October/Terokkar was not dumped**, so its expected next occurrence and artwork are not live-validated by this exchange.

Terokkar's mapping is accepted for this change based on the DBC data and the matching Elwynn/Mulgore captures. A further native texture dump is not a release requirement; retain the distinction between DBC-backed and live-verified data.

## Selected-month lesson

The first commands used offset `0` with the current clock's day number. They returned the August 8 END record even though the native clock reported September 8:

```text
374 END 235446 235446
暗月马戏团
Start 2026 8 2 0 1
Now 2026 9 8 0 4
End 2026 8 8 23 59
```

After explicitly calling `SetAbsMonth(9, 2026)` and querying September 8, the tester returned:

```text
暗月马戏团
Start 2026 9 6 0 1
End 2026 9 12 23 59
375 ONGOING 235450 235450
```

Do not interpret the first record as September's location or as native timestamps being inherently stale. Offset `0` is relative to the selected calendar month. The MoP probes independently demonstrated that calculating a negative offset is not sufficient either: an active occurrence can be omitted while a later month is selected.

## Reproduction commands

These commands intentionally select September 2026. They do not restore the previous selected month. Each is below 255 characters and produces short chat lines rather than a recursive dump.

Select September and print the first holiday's name and timestamps for September 8 (216 characters). Verify the printed name is Darkmoon Faire; index 1 is not a general-purpose event identifier:

```lua
/run local c=C_Calendar;c.OpenCalendar();c.SetAbsMonth(9,2026);local h=c.GetHolidayInfo(0,8,1);print(h.name);for k,t in pairs({Start=h.startTime,End=h.endTime})do print(k,t.year,t.month,t.monthDay,t.hour,t.minute)end
```

For the selected month's day matching the current clock, print each holiday's ID, sequence, and two textures (253 characters). In this exchange the clock's day was 8. This command does not select a month itself:

```lua
/run local c,d=C_Calendar,C_DateAndTime.GetCurrentCalendarTime().monthDay;for i=1,c.GetNumDayEvents(0,d)do local e=c.GetDayEvent(0,d,i);if e.calendarType=="HOLIDAY"then print(e.eventID,e.sequenceType,e.iconTexture,c.GetHolidayInfo(0,d,i).texture)end end
```

These are warm-calendar diagnostic commands, not production readiness handling. If the first call has no data, allow the calendar to load before retrying.

## Implementation consequence

`DarkmoonFaire.GetCurrentState` now selects each queried month with `SetAbsMonth`, reads that month at offset `0`, and restores the previous month and Darkmoon filter before returning. The numeric texture mappings and holiday timestamp comparisons are unchanged.

Focused tests use the captured September Mulgore fields and native timestamps. The separate MoP test reproduces the false-empty October-selected query and checks restoration and synchronous notification handling. This is offline validation of the fix; no corrected addon build was deployed during this work.
