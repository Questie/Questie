# Objective text ownership

## Ownership

Blizzard supplies native objective wording. `QuestLogCache` owns the last accepted snapshot, including text validation, loading retries, and protection against temporary loading-screen regressions. The tracker must not bypass that cache by fetching fresh objectives while rendering.

The tracker, both objective tooltip renderers, and active quest-link progress use `QuestLogCache.TryGetQuest(questId)` for optional reads. It returns the same borrowed snapshot as `GetQuest`, or nil without logging when none exists. Initial loading and party-only quests are expected cache misses, not errors. It never fetches data or schedules retries. `GetQuest` remains the reporting getter for callers that require the quest to be cached. Neither getter permits callers to modify the snapshot.

`TrackerData` copies the accepted `text` into the display objective's single `Description` field. Both full layouts in `QuestieTracker` and incremental updates in `TrackerLinePool` call `TrackerData.GetObjectiveText`, which adds the configured color without changing the text. Native counters, word order, and punctuation are preserved. The tracker does not populate or select a `FullDescription`, strip counters, or append its own counters.

Cached objectives have one wording field: `text`, containing Blizzard's accepted native text unchanged. It uses the same name and wording as Blizzard's API; there is no shortened copy or duplicate wording field. Parsing to detect unloaded names remains necessary, but its result is not stored as display wording.

Original quest/map objectives retain a single counter-free `Description` for fallback rendering. `GetFullObjectiveText(text) or text` removes recognized counters without shortening the instruction or stripping its punctuation. This is distinct from tracker display objectives, whose `Description` is already a complete native or synthetic line. There is no `FullDescription` choice or trimming preference.

## Missing-name placeholders

`QuestieLib.IsObjectiveDataLoaded(objective)` owns the shared validation chain: missing text or type, leading/trailing ASCII spaces, an empty parsed name, and finally three consecutive literal ASCII spaces in the instruction. It returns a boolean and never modifies the row. Exact empty native text returns true because these permanent client placeholders must not block loading; objective consumers still omit those rows.

A matching localized optional wrapper is removed only from the validation's local string. It can otherwise hide a missing name: `2/5 消灭 （可选）` hides a trailing space, while `(Opcional)  : 2/5` hides a leading space. The same checks then apply to the inner instruction. A wrapper around an empty instruction is pending, not the skippable exact-empty native row. Accepted text, including its optional label, remains unchanged.

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

`Tooltip.lua` and `MapIconTooltip.lua` prefer accepted cached objective `text` for local native objective rows, keeping punctuation and counter placement unchanged. Colors, player labels and drop rates are added separately. Missing cache rows, special objectives, and synthetic source-item rows retain the existing description/counter fallback. Source-item rows must not borrow a native row merely because their indices coincide. Native wording also takes precedence over the spell-item label; that label remains a fallback when native data is absent.

Remote progress uses `QuestieLib.ReplaceObjectiveTextProgress(nativeText, fulfilled, required)`. It recognizes both layouts on every client:

- Forever: `9/15 Windstone Cluster` becomes `3/15 Windstone Cluster`.
- Classic: `Windstone Cluster: 9/15` becomes `Windstone Cluster: 3/15`.
- The trailing layout also accepts the full-width colon `：`.

Both replacement and counter-free extraction separate a matching `OPTIONAL_QUEST_OBJECTIVE_DESCRIPTION` wrapper before inspecting counters, then restore it unchanged. This supports localized suffixes and prefixes without hardcoded label words. For example, `Wolf slain: 2/5 (Optional)` becomes a remote player's `Wolf slain: 3/5 (Optional)`, while its counter-free fallback is `Wolf slain (Optional)`.

The inspected [Era French GlobalStrings](https://www.townlong-yak.com/framexml/era/Helix/GlobalStrings.lua/FR) snapshot uses `QUEST_MONSTERS_KILLED = "%s tué : %d/%d"`, with a non-breaking space before the colon. It follows the existing trailing-counter path: `Vide-gousset défias tué : 2/5` becomes `Vide-gousset défias tué : 3/5`. Tests cover this exact format both with and without an optional label.

Forever's French `QUEST_MONSTERS_KILLED` in [live French GlobalStrings](https://www.townlong-yak.com/framexml/live/Helix/GlobalStrings.lua/FR) places a phrase after the counter: `%1$s : %2$d/%3$d |4personnage tué:personnages tués;`. Both helpers derive that suffix from the client template, recognize either the literal `|4...;` markup or one of its expanded forms, and preserve it around counter processing. For example, `Vide-gousset défias : 2/5 personnages tués (optionnel)` becomes `Vide-gousset défias : 3/5 personnages tués (optionnel)` for remote progress. Counter-free extraction retains the phrase and optional label without the local counter. The non-breaking space before the colon is preserved. This is not a general grammar engine: already-expanded wording stays as supplied, and unknown suffixes are not guessed.

Only the recognized counter changes; surrounding wording and spacing remain intact. A fraction in the middle of an instruction is not replaced. Recognition is a layout heuristic, not semantic proof: a leading fraction followed by wording can still look like a native counter. Unrecognized layouts, instructions without a counter, and unavailable text keep the previous remote-counter formatting. Missing remote counts never cause the local player's embedded counts to be displayed as the party member's progress.

Comms tooltip rows carry validated `nativeText` alongside counter-free fallback `text` and remote progress. Party-only map objectives carry validated `NativeText` alongside their existing descriptions. These fields come from the existing objective-loading paths, including their asynchronous callbacks. They are not new wire-protocol fields. Neither counter replacement nor tooltip rendering modifies the native cache.

## Item-deletion warnings

The deletion dialog supplies the deleted item's name. `QuestEventHandler` resolves item-objective names through `GetItemInfo(objective.Id)` instead of comparing the dialog text with `Description`. Display descriptions may contain instructions, optional labels or whitespace before a removed counter. They are not item identity. Non-item objectives and unavailable item names do not produce a description-based match. Existing source-item and required-source-item handling is unchanged.

## Quest links, menus and announcements

Active quest-link progress prefers accepted native text by the original objective index, including instructions without counters. If the native row is unavailable, it retains the existing description/count fallback. Synthetic source-item rows do not borrow a native row with a coinciding index. Requirement tooltips for unaccepted quests retain their existing validated-native/database fallback.

Tracker objective menus already use the display record's native `Description`. Special objectives retain their supplied description; they have no corresponding native row.

Objective announcements receive complete accepted native text and do not prepend counters. Their bookkeeping uses quest ID plus original objective index, not wording that changes with progress. The existing count-equality trigger and once-per-session policy remain unchanged. The separate message-level `alreadySentBandaid` still suppresses identical final chat messages during the session, even if two objective indices produced them; this cleanup does not redesign announcement lifetime or channel throttling.

## Remaining text processing

These uses remain deliberately separate from verbatim native wording:

| Location | Remaining use |
| --- | --- |
| `Modules/Quest/QuestLogCache.lua`, `GetNewObjectives` | Uses `IsObjectiveDataLoaded` to validate rows and stores accepted original wording in `text`. No shortened copy is built. |
| `Modules/Libs/QuestieLib.lua`, `GetLoadedQuestObjectives` | Uses `IsObjectiveDataLoaded` before returning non-empty native rows. Its loading/retry consumers still depend on that validation. |
| `Modules/QuestieValidateGameCache.lua` | Uses `IsObjectiveDataLoaded` before announcing startup cache readiness. |
| `Modules/Quest/QuestieQuest.lua`, `PopulateQuestLogInfo` and objective updates | Builds one counter-free fallback `Description` from accepted native text. Sends unchanged native text and original indices to announcements. These are original quest/map objects, not tracker display records. |
| `Modules/Tooltips/Tooltip.lua` | Prefers accepted native wording locally and replaces recognized native counters for remote rows. Uses shared descriptions/counter-free Comms text plus progress as fallback. Drop rates remain separate. |
| `Modules/Tooltips/MapIconTooltip.lua` | Prefers accepted native wording locally; uses cached or party-loaded native text for remote counter replacement. Retains the shared `Description` and prefixed progress as fallback. |
| `Modules/QuestLinks/Link.lua` | Prefers accepted native text for active progress; otherwise uses shared descriptions and counts. Requirement tooltips validate native text or use database fallback. |
| `Modules/Network/QuestiePartyObjectives.lua` | Preserves native text for remote counter replacement and one counter-free `Description` for fallback. If native data is missing, uses database wording or an entity name without reconstructing an instruction. |
| `Modules/Network/QuestieCommsData.lua` | Preserves native text for remote counter replacement. Still uses `GetFullObjectiveText` to supply counter-free fallback wording separately from remote progress. |
| `Modules/DebugFunctions.lua` | Builds diagnostic cache records with native `text`, without a shortened copy. |

The helpers remain in `Modules/Libs/QuestieLib.lua`:

- `IsObjectiveDataLoaded`: validates native rows consistently, treating exact empty text as non-blocking.
- `TrimObjectiveText`: used only inside loading validation to detect empty names. Its parsing result is not display text.
- `ReplaceObjectiveTextProgress`: replaces a recognized leading or trailing counter with remote progress, returning nil when fallback is needed.
- `GetFullObjectiveText`: removes recognized progress counters while retaining the instruction.

`GetFullObjectiveTextConditional` and `GetObjectiveDescription` are removed. The **Trim Objective Text** option and default are removed. Migration 41 clears the retired `trimObjectiveText` value from existing profiles; historical migration 28 remains in place so migration numbering is stable.

Do not remove loading validation or counter-free remote fallback merely because native rendering no longer shortens wording. Remote-player progress must not inherit the local player's counters, and loading validation must not accept placeholder names.

## Era and Forever compatibility audit

The inspected snapshots of [Era GlobalStrings](https://www.townlong-yak.com/framexml/era/Helix/GlobalStrings.lua/EN) and [live/Forever GlobalStrings](https://www.townlong-yak.com/framexml/live/Helix/GlobalStrings.lua/EN) cover 21 client/locale combinations: ten Era and eleven Forever, with no Era Italian file supplied. Each fixture links its specific locale URL; these URLs track current sources, while the test constants remain frozen. All 84 values of `OPTIONAL_QUEST_OBJECTIVE_DESCRIPTION`, `QUEST_MONSTERS_KILLED`, `QUEST_ITEMS_NEEDED`, and `QUEST_OBJECTS_FOUND` were compared byte-for-byte with the frozen fixture in `test/fixtures/objectiveTextLocales.lua`.

`Modules/Libs/QuestieLib.objectiveText.test.lua` runs the real helpers for all 63 monster/item/object cases. It covers plain and optional text, remote counters, counter-free fallback, label detection, and valid versus missing names. The missing-name checks also wrap each placeholder with its client-specific optional label. Globals are installed before loading QuestieLib and restored after each test. The test suite does not require the ignored dumps.

| Locale | Era to Forever differences |
| --- | --- |
| enUS | Progress moves from trailing to leading; monster wording still contains `slain`. Optional label unchanged. |
| ptBR | Progress becomes leading. Optional suffix changes from English `(Optional)` to `(Opcional)`. |
| zhCN | Progress becomes leading; monster wording changes from `已消灭` to `消灭`. Era uses full-width colons. Optional label unchanged. |
| deDE | Progress formats are identical. Optional label changes from lowercase suffix `(optional)` to capitalized prefix `(Optional)`. |
| esES | Progress remains trailing, with positional placeholders in Forever. Optional label changes from suffix `(opcional)` to prefix `(Opcional)`. |
| esMX | Progress becomes leading. Optional suffix capitalization changes from `(opcional)` to `(Opcional)`. |
| frFR | Era monster `tué` precedes progress; Forever uses a pluralized phrase after progress. Both monster formats use NBSP before the colon; item/object formats change from ASCII space to NBSP. Optional label unchanged. |
| koKR | Progress becomes leading; `처치` remains after the name. Optional label unchanged. |
| ruRU | Displayed ordering is unchanged; Forever adds positional placeholders. The en dash and optional suffix are unchanged. |
| zhTW | Progress becomes leading; `殺死` remains before the monster name. Era item/object formats use full-width colons, but its monster format uses ASCII colon. Optional suffix changes from `(選擇性)` to `（非必要）`. |
| itIT | Forever-only in the supplied files. No Era behavior is inferred. |

The matrix originally checked only undecorated missing-name strings. Independent verification found eleven Forever cases where optional decoration incorrectly made a missing name appear loaded: all three types in zhCN, esES and zhTW, plus items/objects in deDE. Validation now inspects the inner instruction, and all 63 decorated missing-name cases are tested.

## Localized fixture sources

`QuestieLib.test.lua` uses the following real NPC names for all ten supplied optional-objective templates. Each locale is tested with both leading and trailing counters, for remote-counter replacement and counter-free extraction. Expected strings are literal, not generated by the formatter being tested.

Nine names come from [QuestieDB's Classic NPC lookups at commit `61c0acab71014fe5d8ad5a4e51d9f1bb31c81243`](https://github.com/Questie/QuestieDB/tree/61c0acab71014fe5d8ad5a4e51d9f1bb31c81243/l10n/Classic/lookupNpcs), in the corresponding `<locale>.lua` file. Italian is absent from those lookups; Blizzard's [Italian patch 6.1.2 hotfix notes](https://worldofwarcraft.blizzard.com/it-it/news/18486735) identify Hogger in Elwynn Forest as Boccalarga.

| Locale | NPC ID | Name |
| --- | --- | --- |
| zhCN | 119 | 长鼻野猪 |
| ptBR | 119 | Fuçalonga |
| deDE | 525 | Räudiger Wolf |
| esES | 113 | Jabalí colmillopétreo |
| frFR | 94 | Vide-gousset défias |
| itIT | 448 | Boccalarga |
| koKR | 94 | 데피아즈단 소매치기 |
| esMX | 113 | Jabalí Colmipétreo |
| ruRU | 113 | Вепрь-камнеклык |
| zhTW | 119 | 長鼻野豬 |

The names are sourced, but the surrounding counter-bearing strings are constructed fixtures, not claimed captures from ten live clients. They deliberately combine those names with the supplied optional labels and both supported counter layouts. This tests byte preservation for accents, umlauts, Cyrillic, Hangul, Chinese characters, whitespace and full-width punctuation. It does not prove that every live objective follows those layouts or that every client supports every locale. Existing instruction-fraction and literal-pattern-character cases remain separate.
