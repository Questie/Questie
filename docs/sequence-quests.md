# Sequenced quests: A Last Request

## Findings

Live snapshots of **A Last Request (93927)** establish three points:

- Reading the note expanded the native objective list from one row to four. The completed first row remained, and indices stayed stable afterward.
- `IsQuestSequenced` stayed true even when the quest became ready for turn-in. It identifies sequencing, not whether another stage remains.
- The database's first two objectives are reversed relative to Blizzard's order. This needs a central ordering correction; it is separate from quest completion.

Blizzard and the running Questie cache agreed at every sampled stage. **No cache freeze was observed live.** The completion failure fixed afterward was reproduced with constructed snapshots in an offline test.

## Evidence and limits

[Consolidated evidence](evidence/sequence-93927.json) retains all five captures, exact native objective text, types, indices, counts, completion states, and the database mapping. Repeated constants are stored once. Agreement checks were verified against every original snapshot before consolidation.

- Client: Forever **1.60.1, build 70205, interface 16001**; client-reported UTC date **2026-10-04**.
- Read-only queries; the player advanced the quest manually. No post-turn-in capture was taken.
- Loaded addon revision unknown. Its cache still had `raw_text` plus shortened `text`; `TrackerData.GetQuest` was unavailable. This did **not** validate the rewritten tracker or native-text implementation.
- Snapshots are not an event trace or guaranteed atomic native snapshots. They cannot rule out a brief interval with only the first objective present and finished.
- The reported corpse tooltip displayed the note's progress on Aanders. That matches the recorded index mismatch, but the follow-up query found no active tooltip and did not independently capture it.

## Observed progression

Native indices: **1** note, **2** Aanders, **3** feather, **4** signet.

| UTC | Stage | Indices present | Finished indices | Native complete / ready | Questie completion |
| --- | --- | --- | --- | --- | --- |
| 01:06:36 | Initial | 1 | None | false / false | 0 |
| 01:10:19 | Note read; book reported open | 1–4 | 1 | false / false | 0 |
| 01:24:01 | Feather collected | 1–4 | 1, 3 | false / false | 0 |
| 01:24:41 | Signet collected | 1–4 | 1, 3, 4 | false / false | 0 |
| 01:30:30 | Aanders slain | 1–4 | 1–4 | true / true | 1 |

Three objectives appeared together after reading the note. Completing subsequent objectives neither added rows nor removed/renumbered completed ones. The player reported no visible change on closing the book; no separate book-close capture was taken.

### Completion signals

- `C_QuestLog.IsComplete` and `ReadyForTurnIn` changed from false to true only in the final capture.
- `IsQuestSequenced` was always true. `IsFailed` and character/account completed-history flags were always false.
- The compatibility title completion slot changed from nil to `1`; this is not an independent native completion vote.
- Cache `isComplete`, `QuestieDB.IsComplete`, and the enriched quest's `IsComplete()` agreed: `0` before final completion, `1` afterward. The enriched `isComplete` override changed from nil to true.
- Native, leaderboard, cached/raw, and enriched objective completion/progress agreed at each sampled point. Counts happened to agree with `finished` here; that is not a general completion rule.
- Legacy globals `IsQuestComplete`, `IsQuestFlaggedCompleted`, and `GetQuestLogTitle` were unavailable. No quest dialog was active (`GetQuestID=0`), so dialog-only completion results were not evidence for this quest.

## Ordering follow-up remains open

| Native index | Blizzard objective | Loaded database metadata | Required entity |
| --- | --- | --- | --- |
| 1 | Collect and read the note (`item`) | monster 256966 | item 254871 |
| 2 | Skypriest Aanders slain (`monster`) | item 254871 | monster 256966 |
| 3 | Raani's Favorite Feather (`item`) | item 263415 | item 263415 |
| 4 | Shadowsong Family Signet (`item`) | item 263418 | item 263418 |

Questie's enriched rows copied those database IDs by native index. This explains the note/Aanders association without requiring tracker-specific wording or type matching.

Entity identities were corroborated in the QuestieDB checkout at `4d9f14f14717e9bfcbc9d3398d3f322e1fef00d1`: `src/corrections/Forever/generated/foreverBaseNpc.lua` and `foreverBaseItem.lua`. The category-grouped correction is in `src/corrections/Forever/foreverQuestFixes.lua`. Item 263415 is named "Raani's Lucky Feather" there, despite "Favorite Feather" in native objective text. No external-site or new live entity query was used for that corroboration.

The current builder emits monsters before items. `itemObjectiveFirst` prepends **every** item and cannot put only the note ahead of Aanders while leaving the other items afterward.

The existing `objective-order` branch, inspected at `c3ac07b46`, has a central move mechanism that can express the required correction:

```lua
{Type = "item", Id = 254871, From = 2, To = 1}
```

Integrate that mechanism with the current provider-owned correction model before applying the move. **Neither the ordering mechanism nor this correction was included in the completion fix.** No separate provider repository was modified.

## Completion fix after the capture

An offline test of the actual cache reproduced this failure: native completion remained nil, but finishing the only visible objective made Questie cache completion as `1`. When the next unfinished objective appeared, the completed-to-incomplete guard rejected the update before reading objectives.

The completion fix excludes positively classified sequenced quests from visible-objective completion inference in both the cache and enriched quest model. It waits for accepted native completion/failure, preserves source-item handling and genuine-completion loading protection, and publishes status changes even when rows disappear. Sparse cached indices from omitted empty native rows are preserved.

Focused cases live in [QuestLogCache.test.lua](../Modules/Quest/QuestLogCache.test.lua), [QuestieQuest.test.lua](../Modules/Quest/QuestieQuest.test.lua), and [QuestieCompat.test.lua](../Modules/QuestieCompat.test.lua). They cover intermediate stages, final completion, missing mappings, empty/sparse rows, source items, recovery, and classification availability.

Legacy inference remains when classification is false/unavailable. Its historical purpose was working around invalid empty Blizzard objective rows ([introducing commit](https://github.com/Questie/Questie/commit/2c0e402a817493e8a8d1a04ead454b4483a1c708)); this is not proof those quests expose every objective. Late classification from false/nil to true remains an unverified risk: completion might already have been inferred and retained by the recovery guard. The fix was not deployed during this live observation.

See [quest-completion-semantics.md](quest-completion-semantics.md) for the broader historical source/API investigation.

## Raw provenance

The consolidated JSON is an extract, not an original API dump. It uses JSON null for Lua nil and retains the source filename for every stage. Repeated API return wrappers, unrelated quest metadata, inactive-dialog results, the empty tooltip dump, and one-off capture scripts were removed. The original dumps are not kept in the repository.
