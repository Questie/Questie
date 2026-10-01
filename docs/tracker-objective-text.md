# Tracker objective text

## Ownership

Blizzard supplies native objective wording. `QuestLogCache` owns the last accepted snapshot, including text validation, loading retries, and protection against temporary loading-screen regressions. The tracker must not bypass that cache by fetching fresh objectives while rendering.

`TrackerData` copies the accepted `raw_text` into the display objective's single `Description` field. Both full layouts in `QuestieTracker` and incremental updates in `TrackerLinePool` call `TrackerData.GetObjectiveText`, which adds the configured color without changing the text. Native counters, word order, and punctuation are preserved. The tracker does not populate or select a `FullDescription`, strip counters, or append its own counters.

`QuestLogCache.text` still contains shortened wording for other consumers. Its meaning has not changed. Parsing to detect unloaded names also remains necessary, even though the tracker no longer displays the parsed result.

## Completion and color

A display objective's `Completed` flag comes from the cache's `finished` field, not from count equality. This is the cache's normalized flag, not `raw_finished`; existing cache normalization remains in place. Quest-level completion rules are unchanged.

The live Forever objective for Falling With Style (92474) demonstrated why counts are not a completion signal:

```lua
text = "Use Walk on Air"
numFulfilled = 1
numRequired = 1
finished = false
```

The tracker displays `Use Walk on Air`, not `Use Walk on Air: 1/1`. It does not mark the objective complete or color it as complete merely because the counts match. Numeric progress still supplies intermediate colors for supported counter types. Completed objectives use the completed color; unfinished objectives with equal or excessive counts use the initial progress color.

This does not repair or reinterpret mismatches between accepted native text and the cache's normalized numeric progress. Text remains verbatim rather than being rewritten to match those numbers.

## Questie-generated rows

The missing-source-item step has no native objective text. `TrackerQuestieBehavior` builds its complete display string, such as `Note: 0/1`, when creating the synthetic row. The common formatter only colors it.

Quest titles, completion instructions, timers, achievements, scenarios, and challenge-mode rows are outside this change. They retain their existing formatting.

## Remaining text processing

These uses remain deliberately separate from native tracker wording:

| Location | Remaining use |
| --- | --- |
| `Modules/Quest/QuestLogCache.lua`, `GetNewObjectives` | Calls `TrimObjectiveText` to validate loaded names and populate the shared shortened `text` field. Retains accepted original wording in `raw_text`. |
| `Modules/Libs/QuestieLib.lua`, `GetLoadedQuestObjectives` | Parses names to reject partially loaded objective text before returning native rows. Its loading/retry consumers still depend on that validation. |
| `Modules/Quest/QuestieQuest.lua`, `PopulateQuestLogInfo` and objective updates | Builds shared quest objectives with `Description` from cache `text` and optional `FullDescription` through `GetFullObjectiveTextConditional`. Also supplies shortened cache text to objective announcements. These are original quest/map objects, not tracker display records. |
| `Modules/Tooltips/Tooltip.lua` | Selects shared objective wording through `GetObjectiveDescription`, combining it with its own progress and drop-rate text. |
| `Modules/Tooltips/MapIconTooltip.lua` | Uses `GetObjectiveDescription` for local and remote objective tooltips. |
| `Modules/QuestLinks/Link.lua` | Uses `GetObjectiveDescription` in quest-link objective output. |
| `Modules/Network/QuestiePartyObjectives.lua` | Builds optional full descriptions from client objective formats and removes local counters from API wording for party objective displays. |
| `Modules/Network/QuestieCommsData.lua` | Uses `GetFullObjectiveText` to remove the local player's counters before combining wording with remote-player progress. |
| `Modules/DebugFunctions.lua` | Uses `TrimObjectiveText` in diagnostic objective data. |

The helpers remain in `Modules/Libs/QuestieLib.lua`:

- `TrimObjectiveText`: extracts shortened objective wording using client formats and fallback parsing.
- `GetFullObjectiveText`: removes recognized progress counters while retaining the instruction.
- `GetFullObjectiveTextConditional`: enables that full description according to the shared trimming setting.
- `GetObjectiveDescription`: chooses the shared full/short description and removes a trailing period.

The **Trim Objective Text** setting remains in `Modules/Options/GeneralTab/QuestieOptionsGeneral.lua`, with its default in `Modules/Options/QuestieOptionsDefaults.lua` and existing migration in `Modules/Migration.lua`. It still affects shared objective descriptions outside the tracker. It no longer controls native tracker rows. No saved-variable migration is needed for this tracker-only change because the shared setting and its default are retained.

Before deleting these helpers or redefining cache `text`, migrate the remaining consumers explicitly. In particular, remote-player progress must not inherit the local player's counters, and loading validation must not accept placeholder names.
