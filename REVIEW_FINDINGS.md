# tracker-fix review findings

Working document for finishing `tracker-fix` (PR #7920). It is committed on the branch so it travels with the work. Delete it before the squash merge; it must not land on master.

## Status

Not ready to merge. No reviewer found a Lua error on load or in normal use on any client. Every fix-before-merge bug (A, B, C, D, F, G and I) is fixed. Left: H's debug logging, the PR body, and in-game checks. E has a candidate fix on its own branch, waiting for in-game testing, and D still deserves a live check.

- Reviewed `0adfc7e28` against `origin/master` on 2026-10-05: 32 commits, 70 files, +7,429 / −673.
- Seven read-only reviewers covered lifecycle, tracker architecture, client compatibility, objective text and locale, performance, test quality, and devil's advocate with merge hygiene.
- Full suite: 2,595 passed, 0 failed, 1 pending. The pending test is QuestieDB provider conformance, which needs a QuestieDB checkout.
- luacheck: 0 warnings. `lua cli/validate-loader-usage.lua`: passed.
- There has been no live-client validation of the open findings. Line numbers refer to `0adfc7e28`.
- After the fixes (2026-10-05, `6e16ffc6c`): full suite 2,618 passed, 0 failed, 1 pending; luacheck and the loader check clean.

Severity: P1 means user-visible breakage is likely. P2 means incorrect behavior in specific situations. P3 means minor.

## Open: needs in-game testing

### E. Collapsed quest-log headers (P2, plausible)

Earlier finding 7. A candidate fix is on branch `tracker-collapsed-headers` (`c5ca7dce4`, rebased onto `277f2ad47`), kept off `tracker-fix` until it is tested in game. The offline answers to the three questions:
1. *Membership.* `Refresh()` follows `GetQuestLogTitle` until nil. On Wrath Titan and MoP, quests under collapsed headers are listed after every visible entry, past the entry count; the Titan report ("4 entries, but 6 quests") is that layout, not a Titan bug. Classic Era UI source (Gethe `classic_era` `8165d4cd6e48d606369336cc3a7977902310e81e`, `QuestLogFrame.lua:115-170`) only renders up to the entry count, which fits the same layout. No lifecycle-based fallback was added; Era and TBC are still unprobed.
2. *`GetQuestSortIndex` on Era and TBC.* Its use is now narrowed. Quests within the entry count use the preceding header, as master did, and never call it. Only quests past the entry count (under a collapsed header) ask it. If it gives no header there, the quest keeps the header recorded while it was expanded instead of taking the unrelated preceding one. So a wrong meaning on Era or TBC can only misgroup collapsed quests.
3. *MoP and `C_QuestLog.GetInfo`.* The wiki API table (`docs/classic-api-availability.md:7260`) marks `C_QuestLog.GetInfo` only for Retail, not Era, TBC Anniversary or MoP Classic. The modern gate therefore applies to Forever only and does not disable the MoP grouping fix.

Tests in `TrackerData.test.lua`: "uses the preceding header for quests under expanded headers without asking for a sort index" and "keeps the header seen while expanded when a collapsed quest has no explicit header"; both fail under the matching mutation. The single-quest refresh test no longer asserts that the entry count is never read.

**In-game test plan (Era, MoP, Forever):** with at least 3 headers holding quests, dump the log (title, header flag, collapsed flag, quest ID, `GetQuestSortIndex`, `GetQuestLogIndexByID`, entry and quest counts, whether `C_QuestLog.GetInfo` exists) in four states: all expanded, one middle header collapsed, all collapsed, and after `/reload` with headers still collapsed. In each collapsed state, confirm the tracker keeps the quests under the right zone. Turn each dump into a `TrackerData.test.lua` fixture, then adjust the branch to what the clients actually do.

## Open: should fix

### H. The stricter loading check can keep a quest out of the cache forever (P2, plausible)

**Location:** `QuestieLib.IsObjectiveDataLoaded`, called from `Modules/Quest/QuestLogCache.lua:117` and `Modules/QuestieValidateGameCache.lua:106`.

**Problem:** Master only rejected missing text or a leading space. The branch also rejects a trailing ASCII space, a missing type, an empty parsed name, and any run of three spaces. A real Blizzard string with any of these counts as "not loaded" forever. With no earlier cached row, `GetNewObjectives` returns nil on every scan (`:174-180`), so the quest never reaches the tracker or map. Startup itself is only delayed, because `QuestieInit.lua:243` has a 3s timeout. `docs/tracker-objective-text.md:27` already notes the triple-space false positive. Real client strings like this have not been shown to exist.

**Fix:** At minimum, log a debug line when a row is rejected only by the trailing-space or triple-space rule, so reports can be traced.

### J. Questie's inferred completion makes its own staleness check reject every scan (P2, follow-up PR)

Not from the seven reviewers; found while analysing G. Pre-existing on master.

**Location:** `Modules/Quest/QuestLogCache.lua`. The inference is at the end of `GetNewObjectives`, and the rejection is the `blizzardCacheIncorrect` check in `CheckForChanges` (`:243-244`).

**Problem:** Some quests have a broken empty objective row, so Blizzard keeps `isComplete` nil after every real objective is finished. Questie's legacy workaround (commit `2c0e402a8`) skips empty rows and infers `isComplete = 1`, which is cached. On the next scan, `blizzardCacheIncorrect` sees Blizzard "not complete" against a cached "complete". That check exists for stale loading-screen data, so it rejects the scan and reports a cache miss. Blizzard keeps reporting nil, so this repeats on every scan until turn-in or abandon.

**Consequences:** The quest's cached progress is frozen, so a real change such as dropping a quest item is never picked up. Every miss also refreshes the marker, so each QUEST_LOG_UPDATE runs a full scan. G's backoff only limits the fallback timer while no events arrive.

**Evidence:** The lifecycle reviewer's constructed repro (`perm-miss.lua`) printed `miss false, true, true`. No live quest has been identified with the empty-row bug.

**Fix:** Record whether cached `isComplete = 1` came from Blizzard or was inferred by Questie. Apply `blizzardCacheIncorrect` only to completion Blizzard reported. Keep G's backoff as a safety net.

**Risks to test:** Loading-screen protection for completions Blizzard reported, and the completed-to-incomplete guard the sequenced-quest work relies on (`IsQuestSequenced` gating).

## Minor

- **French double space:** the counter-free fallback keeps the space before the colon (`QuestieLib.lua:991-992`). `"Défias\194\160: 2/5 personnages tués"` becomes `"Défias\194\160 personnages tués"`, and Link.lua's `Description .. l10n(": ")` doubles it again.
- **Titan count (probably not an issue):** `GetNumTrackedQuests` uses `numQuests` from `GetNumQuestLogEntries`. In the Titan report only the entry count was low (4 entries, 6 quests), because collapsed quests sit past it; `numQuests` was 6, which is right. This affects the displayed count only.
- **Timer before startup completes:** `InitQuestLogStates` (`QuestEventHandler.lua:217-221`) arms the 20s timer before `RegisterLateEvents`. If startup fails after that point, the timer still runs `QuestLogUpdate` on a stopped addon. The window is narrow.
- **Removed rows stay cached:** if rows are only removed (no row changed and completion unchanged), `changedObjIds` stays nil and the cache keeps them (`QuestLogCache.lua:242,262`). The 93927 capture shows rows being appended, not removed.
- **Remote progress text (pre-existing):** a remote progress-bar or reputation row shows the remote counter followed by local native text, e.g. `"3/100 Defend (45%)"` (`QuestieCommsData.lua:62`, `Tooltip.lua:204`).
- **Native counter vs colour (intentional):** Forever rows that report 1/1 while unfinished print Blizzard's "1/1" in the incomplete colour. This matches Blizzard's UI.
- **Comments:**
  - The `TrackerQuestieBehavior.Apply` comments (about 20 lines in an 80-line function) and the `TrackerData` header can be cut by about half.
  - In general the new code has many more comments than the code around it.

## Performance notes

Besides A and G, all P3. The figures below are measurements on desktop Lua 5.1 with a 25-quest log and 2 objectives per quest.

- **`TrackerData.Refresh()` allocations** (`TrackerData.lua:41-91`, `TrackerQuestieBehavior.lua:21-44`): about 13 KB of garbage and 39 µs per call, with new subtables per quest and one `table.sort` per quest. It runs once per `Update`. Reuse subtables, use a shared read-only empty table, and skip the sort when indices are dense.
- **Validation cost per scan:** each scan now validates every objective, even unchanged ones. Scan time went from 53 µs on master to 75 µs on HEAD (+41%). Run the heavy checks only when `text` differs from the cached row.
- **`GetObjectiveText`** (`TrackerData.lua:234-235`) allocates a `{Collected, Needed}` table on every render. Use two constant tables.
- **`AddQuestItemButtons`** (`TrackerUtils.lua:1069-1101`) creates a closure per quest on every update. Move the helper to file scope.

## Tests

The test reviewer tried 24 mutations of the riskiest new logic, and the suite caught 19. Pending-accept retries, per-quest recovery, sequenced completion and header index separation are all well covered.

About 450 lines can go with no loss of mutation coverage:

| Target | Lines |
|---|---|
| Duplicate `object` rows in `test/fixtures/objectiveTextLocales.lua` (identical to `item` in all 21 locales) | ~210 |
| TrackerData tests that repeat TrackerQuestieBehavior tests (:378-406, :434-450, :463-480, :492-517, :592-609) | ~105 |
| TrackerData internal duplicates (:237-244, :519-525) and tests that only check the call shape (:180-206, :527-546, :562-578) | ~55 |
| `QuestieLib.test.lua:1467-1533`, merged into the locale fixture tests | ~65 |
| `QuestieTracker.test.lua` "invalidates display data…", merged into "passes refreshed data…" | ~15 |

Why the earlier green suite missed regressions, still relevant:
- Combat queue mocks run callbacks immediately instead of keeping them queued.
- Native item tests usually make `SetItem` succeed.
- Membership fixtures assume expanded native headers.
- Focus tests prove stale commands are rejected, not that saved state survives temporary unavailability.

## PR description and merge

- **Squash-merge.** The 32 commits mix `fix(tracker):`, `docs(quests):`, `[fix]` and unprefixed messages. Squashing keeps a single `[feature]` changelog entry. The title prefix is correct, but the title is long.
- **Changes the PR body does not mention yet:**
  - Map actions trust the database objective index with no identity check (`TrackerQuestieBehavior.lua:59-73`). This is how earlier findings 2 and 3 were resolved. For 93927 the known gap is more than ordering: focus, TomTom and spawns for objective 1 use objective 2's locations. Consider softening "Known and unknown quests use the same renderer".
  - Out-of-window QLUs redraw the tracker (finding A).
  - Manual tracking respects `trackerShowCompleteQuests` (`QuestieTracker.lua:957`). Master bypassed it through operator precedence.
  - `log`-type objectives are added to `quest.Objectives` (`QuestieQuest.lua:1391`).
  - `Objective.Description` holds counter-free full wording instead of trimmed text (`QuestieQuest.lua:1402,1475`).
  - The `QuestLogCache` row `text` is now native wording, and `raw_text` is gone.
  - `QuestieLib:GetObjectiveDescription` and `GetFullObjectiveTextConditional` are removed.
  - The warning for tracking a quest missing from the database is removed.
- **No `Public/` API changed shape.** `RegisterForQuestUpdates` passes only IDs and indices. Addons that read `Objectives[i].Description`, `FullDescription` or cache `text`/`raw_text` through `QuestieLoader` silently get different strings or nil.
- **Users lose the trim setting.** People who preferred "Wolf" over "Wolf slain: 0/5" have no replacement, and migration 41 deletes their preference. Narrow trackers wrap more lines.
- **Evidence originals:** the raw 93927 dumps exist only in branch commit `5c58beb57` (deleted again in `0adfc7e28`). A squash merge drops them. `docs/sequence-quests.md` now says the originals are not kept in the repository. If they matter, push a tag before merging.

## Simplification ideas

1. Fold `TrackerQuestieBehavior` into `TrackerData`. It has one caller and two functions. Keep `TrackerMapEligibility` separate, because `TrackerUtils` and `TrackerMenu` both use it.
2. Use one completion flag. `Apply` already folds `completionState == 1` into `isComplete`, so the combined checks in `GetCapabilities`, the tracker, the menu and `HasQuest` can read `quest.isComplete` alone.
3. ~~Write "refresh, get capabilities, check identity" once.~~ Done in `ecb348a7a`: `TrackerMapEligibility.RefreshAndGetCapabilities(questId, expectedQuest)`, used by the menu and the three `TrackerUtils` commands.
4. ~~Remove the eligibility guards on Unfocus and Show Icons (fixes I).~~ Done.
5. ~~Merge the near-identical `Objectives` and `SpecialObjectives` loops in `GetCapabilities`.~~ Done in `ecb348a7a`: both use `_AddObjectiveLocations`, and `hasObjectiveLocations` is derived from `capabilities.objectives`.

Devil's advocate case: keeping QuestieDB-driven tracking, plus a native-only record for quests missing from QuestieDB and pass-through native text, would get most of the value with about a third of the diff. It would also avoid the focus and eligibility rewrite behind A, B, C and I. The counter-argument is that the native-first model removes a whole class of invented-counter and locale-parsing bugs. The conclusion was that the branch's approach is worth it once A, B, C and I are closed.

## Constraints to keep

Carried over from the tracker simplification notes. Do not simplify these away:
- Delayed objective loading and last-valid-state behavior in `QuestLogCache`.
- Numeric completion and failure, Questie's additional completion flag, and source-item exceptions.
- Combat-safe text updates and secure item-button restrictions.
- Rejection of unsafe map actions for unknown objectives.

The earlier constraint about wording-based matching no longer applies: matching is by `NativeIndex` now. The trade-off is recorded under "Resolved" below.

## Resolved

- **Earlier 1: one quest's cache miss froze another quest's progress decreases.** `QuestLogCache` now tracks loading-screen recovery per quest (`questsAwaitingRecovery`). A valid, non-regressing snapshot clears that quest's protection even while another quest is unavailable. Re-run against HEAD, the repro gave `cacheMiss=false count=4` on all three retries, and quest B being unavailable no longer freezes quest A. Remaining limit: a real decrease before a quest's first recovered snapshot still looks the same as a stale lower count.
- **Earlier 2 and 3: locale mismatch, kill-credit and reputation shapes rejected by the identity matcher.** Resolved by removing wording and type matching. Objectives map by database index. The trade-off is that a database ordering error, such as 93927's, now attaches wrong spawns and focus targets without warning.
- **Earlier 7, membership part:** titles are enumerated past the reported entry count. Grouping and legacy behavior are still open (E).
- **Merge hygiene (2026-10-05):** `TRACKER_SIMPLIFICATION_TODOS.md` (every item done) and `review-artifacts/` are deleted from the branch, and this file is untracked. The links in `docs/sequence-quests.md` and `docs/evidence/sequence-93927.json` to commits reachable only from `tracker-fix-backup-prerebase` are removed.

- **A, earlier 6: every QUEST_LOG_UPDATE queued its own tracker rebuild (fixed in `27edb75f0`).** `QuestEventHandler.lua` now routes the `QuestLogUpdate` and `QuestAccepted` redraws through `_QueueTrackerUpdate`, which keeps at most one queued `QuestieTracker:Update()`. The flag clears before the rebuild runs, so events during or after it queue the next one, and the rebuild reads current state. A long fight now leaves one queued redraw instead of one per event. Out of combat, out-of-window QLUs still redraw (membership and title recovery need that); the tracker's 0.1s throttle bounds them. Test: "keeps one tracker update queued while the combat queue is paused" in `QuestEventHandler.test.lua`. The delayed redraw in `UpdateAllQuests` predates the branch and is unchanged.

- **B, earlier 5: startup erased the saved focus when its quest was not ready (fixed in `82cfffe8c`).** `QuestieTracker.Initialize` calls `_RestoreSavedFocus`. A failed `FocusQuest` or `FocusObjective` keeps the saved focus, and `QuestieTracker:Update` retries after each `TrackerData.Refresh()`. The retry is bounded: once `FOCUS_RESTORE_TIMEOUT` (60s, longer than the 20s quest log fallback) passes, a failed attempt clears focus as startup did before. Focus is also cleared at once when `TrackerData.ContainsQuest` says the quest left the log, and when the saved string is malformed. Compared with the branch before the fix, only the "quest in log but not ready" path changed, and only for the first 60s. Limits: the timeout clear needs an `Update` after the deadline; with the tracker disabled, `Initialize` returns before any restore, same as before. If `ContainsQuest` misses collapsed quests on legacy clients (E), startup still clears a valid focus, no worse than before. Tests in `QuestieTracker.test.lua`: kept then restored on a later update; cleared after the timeout when it still cannot apply; malformed value cleared; cleared when the quest left the log.

- **C, earlier 8: an unowned native special item blocked the database item button (fixed in `5d070f181`).** `TrackerUtils.AddQuestItemButtons` now adds the `GetQuestLogSpecialItemInfo` item only when `GetItemCount` reports it owned, the same possession rule database candidates use. Native items still skip the button's database item-class check. The primary-then-secondary button structure is unchanged, so a database candidate that fails `SetItem` still stops the rest, as on master. Test: "falls back to an owned database item when the native item is not in the inventory" in `TrackerUtils.test.lua`; it fails without the fix.

- **D: manual tracking could auto-track newly accepted quests (fixed in `39f5bebc7`).** `AQW_Insert` was gated on native quest-log membership, which is already true when Blizzard's own auto-watch fires on accept. It is gated again on Questie having finished accepting the quest, as master was, but through `QuestEventHandler.IsQuestAccepted` instead of `QuestiePlayer.currentQuestlog`, so quests missing from QuestieDB stay trackable. Quests present at login are marked accepted before `QuestieTracker.Initialize`, so native watch migration still works. Same limit as master: a quest whose objectives have not loaded yet ignores shift-click tracking until acceptance completes, and if Blizzard's handler ran after Questie's synchronous accept the gate would not help, also as on master. Tests: "ignores Blizzard's auto-watch before Questie finishes accepting the quest in manual tracking" in `QuestieTracker.test.lua` (fails under the old gate), and `IsQuestAccepted` asserts in the pending-accept fallback test in `QuestEventHandler.test.lua`. Still worth the live check: on Era and Forever with manual tracking, accept a quest and confirm it stays untracked.

- **F: the objective sound replayed on every retry when a later row rejected the snapshot (fixed in `b92eb824e`).** `GetNewObjectives` now records the objective-complete and objective-progress sounds and plays them just before it returns a snapshot, after every row was read. Any early return (a later row's name not loaded with no cached row, or a suppressed decrease during recovery) plays nothing. A recorded sound implies a changed row, so `CheckForChanges` always saves that snapshot and the next scan finds no change. `Sounds` already merges calls within a short window, so one call per kind matches the old per-objective calls. The quest-complete sound in `CheckForChanges` was already played only on a saved snapshot. Test: "plays the objective complete sound once when the next stage appears before its names load" in `QuestLogCache.test.lua`; it fails without the fix.

- **G: a permanent cache miss kept the retry timer firing every 20s all session (fixed in `4f997f202`).** The shared fallback in `QuestEventHandler.lua` now doubles its delay each time it fires: 20, 40, 80, 160, then capped at 320s. A scan with no cache miss and no pending accept resets it to 20s. `QuestAccepted` also resets it and rearms a waiting backed-off timer, so a new quest is not delayed by an older stuck one. Without a backoff the reset keeps the existing deadline. In silence, a stuck quest now costs one scan about every 5 minutes. Unchanged on purpose: natural QLU scans still refresh the marker (`doRetryWithoutChanges`), so the scan window stays open while QLUs keep arriving, as on master. Tests in `QuestEventHandler.test.lua`: "backs off a fallback that keeps missing and resets once loading resolves" and "shortens a backed-off fallback when a new quest is accepted". Three existing tests now wait 40s for the second firing.

- **I, earlier 4: Unfocus and Show Icons depended on current map eligibility (fixed in `98b2588fc`).** In `TrackerMenu.lua`, quest Unfocus, objective Unfocus and quest Show Icons no longer check map eligibility. Clearing state the quest already owns needs no map data. Unfocus still checks on click that the focus has not changed since the menu opened. Both Unfocus entries now share `_AddUnfocusEntry`. `GetMenuForQuest` offers a quest-level Unfocus when an ineligible quest, or one of its objectives, holds the focus, because a completed quest has no objective menus. It offers Show Icons, but not Hide Icons, for an ineligible hidden quest. Unchanged on purpose: objective Show Icons keeps its identity check, and creating focus or hidden state still requires eligibility. Tests: "recovery after losing eligibility" in `TrackerMenu.test.lua`. Three of the four fail without the fix; the fourth guards the kept stale-focus check.

- **Leftovers and test gaps (fixed in `26f131529` and `076f1ddfa`).** Removed the unused "Trim Objective Text" option strings from `Localization/Translations/Options/General.lua`. In `.types/data/Quest.t.lua`, dropped `FullDescription`, documented `Description` as Blizzard's wording without the counter, and added `"log"` to the objective `Type` union. Test gaps closed, each checked by breaking the code under test: "ignores a local cached row at the same index for a party-only objective" (`MapIconTooltip.test.lua`, fails without the `IsPartyObjective` guard); the omitted-rows test in `TrackerData.test.lua` now uses sparse indices 1, 3, 5, 7, 9, which Lua 5.1's `pairs` visits out of order, so it fails without `table.sort`; "does not let a delayed read from an earlier acceptance act on a re-accepted quest" (`QuestEventHandler.test.lua`, fails without the 0.5s retry's identity check; without it the old read would finish the new acceptance early, which is likely harmless); `TrackerMenu.test.lua` now saves and restores `TrackerData.GetColoredQuestName` in the file's outer hooks, covering both nested stubs, and the WoWHead block's own save/restore was removed.

- **Collapsed-zone key on retrack (fixed in `6a08475ee`).** `AQW_Insert` cleared `collapsedZones[quest.zoneName or quest.zoneOrSort]`, but the tracker keys collapse state by the group it displays, which in non-zone sort modes is the sort mode's single group (e.g. "Quests (By Level)"). The new `TrackerUtils.GetQuestGroupName(quest)` returns that name; `GetSortedQuestIds` and `AQW_Insert` both use it. Tests: `GetQuestGroupName` in `TrackerUtils.test.lua`, and "expands the tracker group the quest is listed under on retrack" in `QuestieTracker.test.lua` (fails without the fix).

## Pre-existing or rejected concerns

- **`QuestieLib.IsObjectiveOptional` (kept by decision, 2026-10-05).** It has no production caller yet, but stays as a ready helper for future optional-objective logic. It now returns false when `OPTIONAL_QUEST_OBJECTIVE_DESCRIPTION` is missing, like `_SplitOptionalObjectiveText` (`8d39b68d8`); test: "matches nothing on clients without the optional label".

- Rapid removal and re-acceptance can skip deferred abandon cleanup (`MarkQuestAsAbandoned` sees the new `{}` entry). It reproduces on master too.
- Rejecting a quest that goes from completed to incomplete in the cache exists on master.
- Objective menus disappearing on ordinary completion predates the branch.
- Unknown or mismatched objectives intentionally get no map actions. Keep those checks.

## Suggested fix order

1. ~~A: coalesce tracker refreshes.~~ Done.
2. ~~B: keep saved focus through startup.~~ Done.
3. ~~C: item candidate fallback.~~ Done.
4. ~~I: unguarded recovery actions.~~ Done.
5. ~~F and G: sounds after commit, and timer backoff.~~ Done.
6. ~~Leftover strings and test gaps.~~ Done in `26f131529` and `076f1ddfa`. `IsObjectiveOptional` is kept by decision and now guarded (`8d39b68d8`). Optional: trim about 450 duplicate test lines.
7. H: debug line when a row is rejected only by the trailing-space or triple-space rule.
   Follow-up PR, not this branch: J, inferred completion versus `blizzardCacheIncorrect`.
8. In-game testing of E on `tracker-collapsed-headers` (Era, MoP, Forever), plus the D check on Era and Forever.
9. Update the PR body, delete this file, then squash-merge.
