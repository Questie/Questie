# Tracker objective text

## Ownership

Blizzard supplies native objective wording. `QuestLogCache` owns the last accepted snapshot, including text validation, loading retries, and protection against temporary loading-screen regressions. The tracker must not bypass that cache by fetching fresh objectives while rendering.

The tracker and both objective tooltip renderers use `QuestLogCache.TryGetQuest(questId)` for optional reads. It returns the same borrowed snapshot as `GetQuest`, or nil without logging when none exists. Initial loading and party-only quests are expected cache misses, not errors. It never fetches data or schedules retries. `GetQuest` remains the reporting getter for callers that require the quest to be cached. Neither getter permits callers to modify the snapshot.

`TrackerData` copies the accepted `raw_text` into the display objective's single `Description` field. Both full layouts in `QuestieTracker` and incremental updates in `TrackerLinePool` call `TrackerData.GetObjectiveText`, which adds the configured color without changing the text. Native counters, word order, and punctuation are preserved. The tracker does not populate or select a `FullDescription`, strip counters, or append its own counters.

`QuestLogCache.text` still contains shortened wording for other consumers. Its meaning has not changed. Parsing to detect unloaded names also remains necessary, even though the tracker no longer displays the parsed result.

## Missing-name placeholders

`QuestieLib.IsObjectiveDataLoaded(objective)` owns the shared validation chain: missing text or type, leading/trailing ASCII spaces, an empty parsed name, and finally three consecutive literal ASCII spaces anywhere in native text. It returns a boolean and never modifies the row. Exact empty text returns true because these permanent client placeholders must not block loading; objective consumers still omit those rows.

As a final heuristic, three consecutive literal ASCII spaces mean "not loaded". This catches missing names before unrecognized suffixes, without splitting words or interpreting UTF-8 bytes. For example, the constructed placeholders `0/6   destroyed` and `0/6   已摧毁` are rejected; `4/6 Roiling Winds destroyed` and `4/6 烈风已摧毁` remain unchanged.

The complete shared check applies in `QuestLogCache`, `QuestieLib.GetLoadedQuestObjectives` (including its async loader and `TestGameCache` callers), the early `QuestieValidateGameCache` startup check, and quest-link requirement tooltips. Each caller owns its response to unavailable data: the cache retains accepted rows, loaders retry, startup waits, and quest links use database wording when available. A quest-link row without a database fallback is omitted until native wording is available on a later tooltip render. An unavailable objective array also blocks startup and makes quest links use their database fallback.

Quest-link requirements no longer repair leading-space placeholders or replace spaces in Chinese sentences. Validated native wording is displayed unchanged; incomplete rows use database text without modifying the client's response.

This is a loading heuristic, not proof that arbitrary text is valid. A legitimate triple-spaced objective would also be treated as pending. Single and double interior spaces are not rejected by this check. No accepted text is trimmed or repaired by it.

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

## Unit, item, object and map tooltips

`Tooltip.lua` and `MapIconTooltip.lua` prefer accepted `QuestLogCache.raw_text` for local native objective rows, keeping punctuation and counter placement unchanged. Colors, player labels and drop rates are added separately. Missing cache rows, special objectives, and synthetic source-item rows retain the existing description/counter fallback. Source-item rows must not borrow a native row merely because their indices coincide. Native wording also takes precedence over the spell-item label; that label remains a fallback when native data is absent.

Remote progress uses `QuestieLib.ReplaceObjectiveTextProgress(nativeText, fulfilled, required)`. It recognizes both layouts on every client:

- Forever: `9/15 Windstone Cluster` becomes `3/15 Windstone Cluster`.
- Classic: `Windstone Cluster: 9/15` becomes `Windstone Cluster: 3/15`.
- The trailing layout also accepts the full-width colon `：`.

Only the recognized counter changes; surrounding wording and spacing remain intact. A fraction in the middle of an instruction is not replaced. Recognition is a layout heuristic, not semantic proof: a leading fraction followed by wording can still look like a native counter. Unrecognized layouts, instructions without a counter, and unavailable text keep the previous remote-counter formatting. Missing remote counts never cause the local player's embedded counts to be displayed as the party member's progress.

Comms tooltip rows carry validated `nativeText` alongside counter-free fallback `text` and remote progress. Party-only map objectives carry validated `NativeText` alongside their existing descriptions. These fields come from the existing objective-loading paths, including their asynchronous callbacks. They are not new wire-protocol fields. Neither counter replacement nor tooltip rendering modifies the native cache.

## Remaining text processing

These uses remain deliberately separate from verbatim native wording:

| Location | Remaining use |
| --- | --- |
| `Modules/Quest/QuestLogCache.lua`, `GetNewObjectives` | Uses `IsObjectiveDataLoaded` to validate rows, then `TrimObjectiveText` to populate the shared shortened `text` field. Retains accepted original wording in `raw_text`. |
| `Modules/Libs/QuestieLib.lua`, `GetLoadedQuestObjectives` | Uses `IsObjectiveDataLoaded` before returning non-empty native rows. Its loading/retry consumers still depend on that validation. |
| `Modules/QuestieValidateGameCache.lua` | Uses `IsObjectiveDataLoaded` before announcing startup cache readiness. |
| `Modules/Quest/QuestieQuest.lua`, `PopulateQuestLogInfo` and objective updates | Builds shared quest objectives with `Description` from cache `text` and optional `FullDescription` through `GetFullObjectiveTextConditional`. Also supplies shortened cache text to objective announcements. These are original quest/map objects, not tracker display records. |
| `Modules/Tooltips/Tooltip.lua` | Prefers accepted native wording locally and replaces recognized native counters for remote rows. Uses shared descriptions/counter-free Comms text plus progress as fallback. Drop rates remain separate. |
| `Modules/Tooltips/MapIconTooltip.lua` | Prefers accepted native wording locally; uses cached or party-loaded native text for remote counter replacement. Retains `GetObjectiveDescription` and prefixed progress as fallback. |
| `Modules/QuestLinks/Link.lua` | Uses `GetObjectiveDescription` in quest-link progress output. Requirement tooltips use `IsObjectiveDataLoaded` to choose native text or database fallback, without repairing native sentences. |
| `Modules/Network/QuestiePartyObjectives.lua` | Preserves native text for remote counter replacement. Also builds optional full descriptions and counter-free wording for fallback displays. |
| `Modules/Network/QuestieCommsData.lua` | Preserves native text for remote counter replacement. Still uses `GetFullObjectiveText` to supply counter-free fallback wording separately from remote progress. |
| `Modules/DebugFunctions.lua` | Uses `TrimObjectiveText` in diagnostic objective data. |

The helpers remain in `Modules/Libs/QuestieLib.lua`:

- `IsObjectiveDataLoaded`: validates native rows consistently, treating exact empty text as non-blocking.
- `TrimObjectiveText`: extracts shortened objective wording using client formats and fallback parsing; also used by the validator to detect empty names.
- `ReplaceObjectiveTextProgress`: replaces a recognized leading or trailing counter with remote progress, returning nil when fallback is needed.
- `GetFullObjectiveText`: removes recognized progress counters while retaining the instruction.
- `GetFullObjectiveTextConditional`: enables that full description according to the shared trimming setting.
- `GetObjectiveDescription`: chooses the shared full/short description and removes a trailing period.

The **Trim Objective Text** setting remains in `Modules/Options/GeneralTab/QuestieOptionsGeneral.lua`, with its default in `Modules/Options/QuestieOptionsDefaults.lua` and existing migration in `Modules/Migration.lua`. It still affects shared objective descriptions used by fallback displays and other consumers. It no longer controls native tracker or native tooltip wording. No saved-variable migration is needed because the shared setting and its default are retained.

Before deleting these helpers or redefining cache `text`, migrate the remaining consumers explicitly. In particular, remote-player progress must not inherit the local player's counters, and loading validation must not accept placeholder names.
