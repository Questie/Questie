# Sequenced quests: live observation of A Last Request

## Result

Quest **93927, A Last Request**, exposed one native objective initially. After the player collected/read the note, Blizzard returned four objectives: the completed first objective plus three new unfinished objectives. Existing indices remained stable in all subsequent snapshots.

The running Questie cache accepted the expanded list. Blizzard and Questie agreed on objective and quest-wide completion at every captured point. **This run did not reproduce a cache freeze.** It also did not capture the event-by-event transition, so it cannot rule out a brief intermediate state with only the first objective present and finished.

`IsQuestSequenced(93927)` stayed **true**, including when the quest was ready for turn-in. It was a sequencing classification, not a remaining-stage or completion signal in this run.

## Capture scope

- Client: Forever **1.60.1, build 70205, interface 16001**.
- Snapshot timestamps: client-reported UTC, **2026-10-04**.
- Queries were read-only. The player advanced the quest manually; the capture did not reload, deploy, accept, advance, or turn in quests.
- The loaded addon revision was not established. Its cache contained `raw_text` plus shortened `text`, and `TrackerData.GetQuest` was unavailable. **These observations do not validate the rewritten tracker or the native-objective-text branch.**
- Each snapshot queried several APIs in one Lua chunk. These are point-in-time observations, not an event trace or a guaranteed atomic native snapshot.
- No post-turn-in snapshot was taken. The final state was complete and ready for turn-in, not flagged as previously completed.

## Stage-by-stage evidence

Objective indices after the note was read:

1. Collect and read the note (`item`, numeric `objectiveType=1`).
2. Skypriest Aanders slain (`monster`, numeric `objectiveType=0`).
3. Raani's Favorite Feather (`item`, numeric `objectiveType=1`).
4. Shadowsong Family Signet (`item`, numeric `objectiveType=1`).

Every exposed objective required one credit. Finished rows had `1/1`; unfinished rows had `0/1` in these captures. This agreement does not establish count equality as a general completion rule.

| Capture (UTC) | Native indices present | Finished indices | Native complete / ready | Questie completion |
| --- | --- | --- | --- | --- |
| [01:06:36, initial state](evidence/sequence-93927/baseline-full.json) | 1 | None | false / false | 0 |
| [01:10:19, note/book open](evidence/sequence-93927/stage-1-book-open.json) | 1–4 | 1 | false / false | 0 |
| [01:24:01, feather collected](evidence/sequence-93927/next-objective-done.json) | 1–4 | 1, 3 | false / false | 0 |
| [01:24:41, signet collected](evidence/sequence-93927/another-objective-done.json) | 1–4 | 1, 3, 4 | false / false | 0 |
| [01:30:30, Aanders finished](evidence/sequence-93927/corpse-state.json) | 1–4 | 1–4 | true / true | 1 |

"Questie completion" agrees across cache `isComplete`, `QuestieDB.IsComplete(93927)`, and the enriched quest's `IsComplete()` method.

The book being open was reported by the player. The player subsequently reported that closing it caused no visible change; there was no separate immediate book-close capture.

Completed objectives remained in both structured native results and the legacy leaderboard. They were not removed or renumbered as the player completed later objectives. Three objectives became visible together after the initial step; this was not one new objective per later completion.

## Completion signals compared

The five snapshots above include the following results:

| Signal | Before final objective | Ready for turn-in |
| --- | --- | --- |
| `IsQuestSequenced(93927)` | true | true |
| `C_QuestLog.IsComplete(93927)` | false | true |
| `C_QuestLog.ReadyForTurnIn(93927)` | false | true |
| `C_QuestLog.IsFailed(93927)` | false | false |
| `C_QuestLog.IsQuestFlaggedCompleted(93927)` | false | false |
| `C_QuestLog.IsQuestFlaggedCompletedOnAccount(93927)` | false | false |
| Completion slot from `QuestieCompat.GetQuestLogTitle(index)` | nil | 1 |
| Cache `isComplete` | 0 | 1 |
| `QuestieDB.IsComplete(93927)` | 0 | 1 |
| Enriched quest `IsComplete()` | 0 | 1 |
| Enriched quest `isComplete` field | nil | true |

Objective state agreed at every sampled point across:

- `C_QuestLog.GetQuestObjectives`: `finished`, `numFulfilled`, `numRequired`, text, and type.
- `GetQuestLogLeaderBoard`: `finished`, text, and type.
- Questie cache: `finished`, `raw_finished`, `numFulfilled`, `raw_numFulfilled`, and `numRequired`.
- Enriched objectives: `Completed`, `Finished`, `Collected`, and `Needed`.

Legacy globals `IsQuestComplete`, `IsQuestFlaggedCompleted`, and `GetQuestLogTitle` were unavailable. The compatibility title tuple was available. Its signed status is not an independent native completion vote.

Dialog-only APIs were recorded separately. `GetQuestID()` returned `0`, while `IsQuestCompletable()` and `IsCurrentQuestFailed()` returned false throughout. With no matching quest dialog active, these are **not completion evidence for quest 93927**.

`C_QuestLog.GetInfo` metadata was also captured. In particular, `isAutoComplete=false` is metadata, not the current quest completion result. Unavailable APIs, false results, and nil results are distinguished in the saved data; nil is encoded as `"<nil>"`.

## Separate objective-mapping discrepancy

The loaded database metadata used this order in every snapshot:

| Index | Database metadata | Native objective |
| --- | --- | --- |
| 1 | `Type="monster", Id=256966` | Collect and read the note (`item`) |
| 2 | `Type="item", Id=254871` | Skypriest Aanders slain (`monster`) |
| 3 | `Type="item", Id=263415` | Raani's Favorite Feather (`item`) |
| 4 | `Type="item", Id=263418` | Shadowsong Family Signet (`item`) |

The enriched model copied those IDs by index, producing an `item` objective with ID `256966` and a `monster` objective with ID `254871`. This establishes an upstream ordering/type mismatch for the first two entries. It does not by itself verify the correct identity of every database ID.

The player relayed a tooltip observation from another chat: hovering Skypriest Aanders (NPC 256966) showed the completed note objective. That is consistent with the recorded mapping mismatch. The local follow-up [tooltip query](evidence/sequence-93927/corpse-tooltip.json) found no mouseover GUID/name and no tooltip lines, so it did **not independently capture that tooltip**. Do not interpret its `dead=false` result as evidence about the corpse when no mouseover unit was available.

This mapping issue is separate from sequencing and completion. Do not repair it by comparing localized text inside the tracker. No correction was changed during this observation or the completion fix below.

### Ordering follow-up remains open

The sibling QuestieDB checkout at `4d9f14f14717e9bfcbc9d3398d3f322e1fef00d1` corroborates the identities: NPC 256966 is Skypriest Aanders, item 254871 is Bloody Note, item 263415 is Raani's Lucky Feather, and item 263418 is Shadowsong Family Signet. Sources are `src/corrections/Forever/generated/foreverBaseNpc.lua` and `foreverBaseItem.lua`; `src/corrections/Forever/foreverQuestFixes.lua` defines quest 93927's category-grouped objectives. The item name "Lucky Feather" differs from the captured objective's "Favorite Feather". No new external-site or live entity query was performed for this follow-up.

The current Questie builder emits monsters before items. Its `itemObjectiveFirst` flag prepends every item, producing the wrong order for this mixed sequence. It cannot express moving only Bloody Note ahead of Aanders while leaving the other items afterward.

The existing local remote ref `origin/objective-order` at `c3ac07b46` contains a central stable-fill move mechanism. Once integrated with the current provider-owned correction model, the required move is `Type="item", Id=254871, From=2, To=1`. Importing that older branch wholesale would also require reconciling its correction ownership and integration. This work was deliberately not folded into the completion fix or applied to the separate provider repository.

## Completion fix after the capture

An isolated test of the actual cache reproduced the suspected failure. With native completion still nil, finishing the only visible objective changed cached completion to `1`. When the next unfinished objective appeared, the completed-to-incomplete guard rejected the update **before querying objectives**. Repeated scans could not recover until native completion became `1`.

This offline reproduction justifies the fix; the successful live run alone did not demonstrate the defect.

The implementation now:

- Adds capability-safe `QuestieCompat.IsQuestSequenced`. Only a positive native classification opts into the sequenced policy.
- Uses accepted native completion/failure for sequenced quests instead of inferring completion from all visible objectives being finished or an empty list.
- Applies the same rule to `QuestieQuest`'s all-enriched-objectives-complete and empty-mapped-objectives overrides, preventing premature finisher icons as well as premature cache completion.
- Retains source-item reconstruction and the existing loading-screen protection after genuine completion.
- Publishes accepted completion changes even when the objective count changes. A separate offline case exposed discarded native completion and repeated sounds when all rows disappeared; it now publishes an empty objective list and completion once.
- Preserves sparse native indices when normalizing completion and producing ordered change notifications. Empty-text native rows can be omitted by cache validation even if the native array itself is dense.

Existing inference remains for false/unavailable sequence classification. This is a compatibility boundary, **not proof that those quests expose every objective**. Commit `2c0e402a817493e8a8d1a04ead454b4483a1c708` introduced the legacy fallback because invalid empty Blizzard objectives could prevent quest-wide completion; the available evidence does not establish that the workaround is obsolete on every supported client.

Focused tests cover stage growth, no premature quest-completion sound, eventual native completion, failure, genuine-completion loading protection, empty initial stages, absent database mappings, source-item reconstruction, legacy fallback, disappearing final rows, and omitted empty rows. Tests use constructed boundary snapshots; they are not a claim that the saved live run emitted those intermediate states.

Validation after implementation: full Busted suite **2,515 passed**, scoped lint and loader usage validation passed. Fresh adversarial reviews identified the disappearing-row and sparse-normalization cases above; both were reproduced with failing tests and fixed, and the final publication loop review found no introduced issues.

### Remaining limits

- The observed native sequence supports enrichment by original native index, provided the database order is corrected.
- `IsQuestSequenced=true` does not indicate remaining stages; it stayed true at ready-for-turn-in.
- Late classification is unverified: if a quest first returns false/nil, legacy inference could cache completion before it later classifies as sequenced. The existing recovery guard can then retain that result. This fix does not introduce completion provenance or redesign recovery to solve that hypothetical timing case.
- The fixed code has not been deployed or validated in the live client used for the capture.
- Event-level live recording would still be needed to establish the exact native update order around a stage boundary.

For the earlier source/API investigation, see [quest-completion-semantics.md](quest-completion-semantics.md). Its code-departure notes describe an earlier checkout and must not be read as current validation results.

## Saved evidence and capture code

All five full snapshots and the unsuccessful tooltip capture are preserved under [evidence/sequence-93927](evidence/sequence-93927/), rather than depending on `/tmp` files.

- [Readable capture script](evidence/sequence-93927/snapshot-full.lua).
- [Compact script actually submitted](evidence/sequence-93927/snapshot-full-compact.lua), shortened to fit the bridge request-size limit.

The script is specific to quest 93927 and the observed client interfaces. It snapshots existing records without refreshing the tracker or cache. `Objectives` (enriched runtime rows) and lowercase `objectives` (which can be database definitions) are recorded separately. Earlier temporary dumps conflated these fields; use the full snapshots linked above for analysis.

The API `returns` object contains the packed `pcall` result: element 1 is call success, and element 2 onward are actual function returns. Thus the sixth compatibility title return is stored at `returns.values[7]`. The `result` field repeats the first function return for convenience.
