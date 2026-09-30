# tracker-fix review

## Verdict and scope

Do not merge unchanged. Six code-level regression findings and two additional client-dependent failure paths remain. All are P2 (normal-priority fixes), not release-wide crash claims. Most removed behavior has a logical replacement, but identity matching, recovery actions, membership enumeration and fallback handling are not behaviorally equivalent.

- Reviewed branch: `tracker-fix`, HEAD `545d17fd5cc03fd13534784a086b6b35f2aee3c5`.
- Starting local master and merge base: `04ba519340847f47ee6a305e7ff413fb0ff8ba0b`.
- Nine branch commits; 35 changed files, 2,975 insertions and 329 deletions.
- Local master advanced during review to `b139e2e3e1fed5424404f87b40078cb90c5c7ea0`. Its only changes from the starting baseline are the three QuestieDB mock/conformance files. The merge base and production-code findings are unchanged.
- Eight fresh, read-only reviewers in batches of 3, 3 and 2. Final batch challenged the identity and recovery findings rather than simply repeating the initial review.
- Parent maintained this document and adjudicated findings. Neither its path nor contents were supplied to reviewers; all were instructed to stay inside the checkout. This is context/path separation, not an OS security boundary between same-user processes.
- No repository edits, branch switches, live-client operations or daily-driver builds by this review. Existing untracked `CL.md`, `STATIC_POPUP_MIGRATION.md`, `TRACKER_FLOW.html` excluded. Temporary tracked mock edits appeared and disappeared concurrently; left untouched.

## Findings

### 1. P2: An unrelated cache miss can freeze legitimate item progress decreases

**Location:** `Modules/Quest/QuestLogCache.lua:318-319`, interacting with regression suppression at `:136-138`.

**Trigger:** Cache incomplete quest A at 5/10. Enter a loading screen. Scan A successfully while quest B is unavailable. Then bank or consume one of A's items, and allow B to recover.

HEAD retains the global `blizzardQuestCacheStale` flag because B missed. A's legitimate decrease now counts as another cache miss, so ordinary full scans cannot clear the flag. A remains displayed at 5/10 rather than 4/10, and the retry loop can continue indefinitely.

Master clears suppression after a scan without a suppressed regression, even if B is missing. It accepts A's later decrease. This is separate from the older completed-to-incomplete cache bug: both quests in the reproduction remain incomplete.

**Evidence:** Independently reproduced by two reviewers, then personally reproduced by the parent with actual source from both committed snapshots. Reproduction: `lua review-artifacts/cache-repro.lua` from the repository root. It reads the pinned revisions directly from Git; no source archives are needed. Three repeated scans returned:

```
master: cacheMiss=false count=4
HEAD:   cacheMiss=true  count=5
```

A successful restricted scan excluding A, count recovery, or reload can end the freeze. Ordinary full-scan retries cannot.

**Correction:** Track recovery protection per quest, rather than letting one unavailable quest indefinitely protect every other quest against decreases.

**Focused test:** The two-quest loading/recovery/decrease sequence above.

#### Resolution

Implemented after the reviewed revision. The original evidence and pinned reproduction above remain unchanged.

- `QuestLogCache` now tracks loading-screen recovery per quest. A valid, non-regressing snapshot clears that quest's protection even when its objectives are unchanged or another quest is unavailable. Missing or partial data retains protection; removing a quest clears its recovery state.
- Cache tests cover A's legitimate decrease while B is still unavailable, restricted scans and partial-objective recovery. Integration tests exercise registered events through `QuestEventHandler` into the real cache, including bank-close updates, notification delivery despite another cache miss, retry completion and duplicate-notification prevention.
- Related tests use client format strings and the verified single-space missing-name placeholder: Classic `" : 0/8"`, Forever item `"0/8  "` and Forever monster `"0/8   slain"`. `QuestLogCache` now rejects these placeholders or retains previously cached rows while retrying. `TestGameCache()` uses `QuestieLib.GetLoadedQuestObjectives` for readiness checks. No QuestieLib parser change was needed.
- Tests are in `Modules/Quest/QuestLogCache.test.lua`, `Modules/EventHandler/QuestEventHandler.test.lua` and `Modules/Libs/QuestieLib.test.lua`. Post-fix validation: **2,192 successes, 0 failures/errors, 1 pending**; the pending provider-conformance check requires the absent QuestieDB checkout. Scoped luacheck, loader-usage validation and focused reviews passed.

The placeholder strings were verified in-game by David; the fix itself has not had live-client validation. A genuine decrease before a quest's first recovered snapshot remains indistinguishable from stale lower counts. The pre-existing completed-to-incomplete rejection is unchanged.

### 2. P2: Valid objectives lose enrichment when Questie and client locales differ

**Location:** `Modules/Tracker/TrackerQuestieBehavior.lua:63-76`, consequences at `:112-115`.

Provider entity names use the selected Questie UI locale (`Modules/QuestieInit.lua:158-159`), while cached native objective wording uses the client locale. For metadata without explicit `Text`, the new matcher compares those names literally. A valid objective whose names differ loses its original locations. The quest also loses special objectives and potentially its additional completion state.

Master's tracker uses the original objectives without this database-versus-native wording comparison. Native-first display does not require throwing away correct locations solely because the user selected another UI language.

**Evidence:** Reviewers traced provider locale forwarding, direct database query bindings and original-object construction. An in-memory comparison matched an English entity name, then rejected the corresponding German provider name with unchanged native English text. Control cases with matching languages succeeded.

**Correction:** Resolve identity wording in the client locale independently of display localization. Do not switch the provider's global locale temporarily, assume English names are universal, or bypass identity checks wholesale.

**Focused test:** Different client/Questie locales using an entity with a real differing translation, plus a genuine identity mismatch that must remain rejected.

### 3. P2: The identity matcher does not support existing kill-credit and reputation metadata

**Location:** `Modules/Tracker/TrackerQuestieBehavior.lua:62-76,112`.

Two valid database shapes fail the new match:

- Kill-credit metadata has `Type = "killcredit"`, `IdList`, `RootId` and optional `Text` (`Database/QuestieDB.lua:1832-1838`). Native progress can have type `"monster"`. Strict type equality rejects it before wording is checked, despite existing locations generated from `IdList`.
- Reputation metadata has `Type`, `Id` and `RequiredRepValue`, but no `Text` (`Database/QuestieDB.lua:1820-1824`). The matcher supplies no reputation-name fallback, so this shape cannot match. Any such rejection removes all special objectives and prevents whole-quest focus even when another normal objective has locations.

Master passes original objectives directly to the tracker, and map construction deliberately selects its generator using database metadata rather than requiring identical native types.

**Evidence:** Final adversarial reviewer executed committed metadata construction, original-object construction, spawn builders and matcher with explicit synthetic API inputs. Matching monster control passed; killcredit/monster and reputation cases failed. A killcredit/killcredit control passed.

**Important qualification:** Kill-credit ID equality is NOT a second bug: both `metadata.Id` and `original.Id` are nil in the real shape. Reputation objectives already lack their own direct spawn generator; the demonstrated regression is suppression of existing special locations and whole-quest focus, not newly lost reputation-only navigation.

**Correction:** Explicit compatible-type and identity rules for supported metadata shapes. Use client-language identity and reputation-specific formatting/value checks. Preserve rejection of genuinely changed objectives.

**Focused tests:** Actual kill-credit metadata shape with native monster progress; reputation metadata without Text on an incomplete quest that also has special objectives.

### 4. P2: Eligibility loss removes the actions needed to clear existing focus and hidden state

**Location:** `Modules/Tracker/LinePool/TrackerMenu.lua:495-503`; recovery callbacks at `:180-183,334-336`; objective equivalent at `:62-65`.

Focus or hide an incomplete quest, then let its only live objective become unmatched. `canFocusQuest` becomes false, so rebuilt menus omit Unfocus and Show Icons. Previously opened callbacks also return without clearing the saved state. Other quests remain faded, and saved hidden state survives.

Master always constructs these recovery actions and permits them to clear their corresponding state. The new identity checks are useful for creating map state, but clearing state already owned by this quest does not require fresh location eligibility.

**Evidence:** Two independent reviewers reproduced both stale and rebuilt menus with actual menu/utility code. Master cleared `TrackerFocus`, the other quest's `FadeIcons`, and hidden state; HEAD retained them. Parent traced the unchanged `UnFocus` cleanup and new menu gates.

**Qualification:** Focusing another eligible quest or abandoning/turning in the focused quest can recover focus. These are not equivalent recovery controls, and saved hidden state can remain. This finding is about incomplete mismatched quests, not the pre-existing disappearance of ordinary objective menus on completion.

**Correction:** Separate eligibility to create focus/hide state from permission to clear existing state. Retain identity-safe cleanup without requiring current matching locations.

**Focused tests:** Existing quest and objective focus/hidden state followed by enrichment loss, using both open callbacks and rebuilt menus.

### 5. P2: Delayed initial loading permanently deletes saved tracker focus

**Location:** `Modules/Tracker/QuestieTracker.lua:248-251,260-263`.

Initialization calls `UnFocus()` whenever validated focus restoration fails. Startup is explicitly allowed to proceed after bounded cache retries (`Modules/QuestieInit.lua:426-434`). A known quest whose data has not arrived is not hydrated into the original quest log yet, so its saved focus fails validation and is erased. Later hydration makes it eligible but never restores the deleted setting.

Master retains and applies the saved focus rather than treating unavailable startup data as a definitively invalid target.

**Evidence:** Two reviewers traced full initialization order and reproduced the actual restoration phase. The adversarial pass verified that the failing case has no original enrichment object yet; it did not assume hydration had already completed.

**Qualification:** A temporary client miss with an existing valid cached snapshot does not establish this bug. Initial cache/hydration must remain incomplete when tracker initialization runs.

**Correction:** Preserve pending saved focus until its target is definitively removed or validation can run on ready data. Retry restoration after hydration.

**Focused test:** Present known quest with saved quest/objective focus, startup cache miss through retry limit, then successful hydration.

### 6. P2: Out-of-window quest-log events accumulate redundant combat-queue updates

**Location:** `Modules/EventHandler/QuestEventHandler.lua:424-440`.

The previous expired-marker early return is replaced by skipping only the objective scan. Every event now queues a tracker update, even for unchanged metadata and membership. `Modules/Libs/QuestieCombatQueue.lua` does not coalesce callbacks and stops draining in combat. The tracker's 0.1-second throttle runs after callbacks leave the queue, so it cannot bound queue growth or the delay imposed on other queued work.

**Evidence:** Two reviewers reproduced 100 unchanged out-of-window events: master queued 0 updates; HEAD queued 100. Parent read the real queue's paused-consumption and bounded-drain implementation. No measured in-game frame-time claim is made; impact depends on event volume.

**Correction:** Coalesce pending tracker refresh requests. Refresh current state when the single callback executes. Preserve title/membership recovery without retaining one closure per event.

**Focused test:** Deferred queue during combat, repeated unchanged QLUs, at most one pending redraw and one eventual update using latest state.

## Client-dependent failure paths

These are demonstrated code paths, but neither was validated in a running client. Keep the client assumptions explicit.

### 7. P2: Collapsed native headers can delete active quests from the display snapshot

**Location:** `Modules/Tracker/TrackerData.lua:109-120`.

`Refresh()` treats every quest absent from the enumerated native rows as removed. On the legacy quest-log API, collapsing a header removes its children from visible row enumeration without abandoning the quests. The branch therefore removes their display records, while master retains the original quest-log objects for rendering.

**Evidence:** Three reviewers reproduced the transition from header+quest to collapsed header while total native quest count remained one. Parent found no Questie expansion hook that would compensate. Current fetched Classic Era UI source renders `GetQuestLogTitle(index)` directly against the native entry count, with no Lua-side child filtering; the TOC selects that implementation for Vanilla. This supports the legacy API interpretation, but source is not a live native API probe.

Reference: Gethe `classic_era` commit `8165d4cd6e48d606369336cc3a7977902310e81e`, subject `1.15.9 (70003)`, `Interface/AddOns/Blizzard_UIPanels_Game/Vanilla/QuestLogFrame.lua:115-170`, with selection in `Blizzard_UIPanels_Game_Classic.toc:48-51`.

**Qualification:** Do not generalize this to modern `C_QuestLog.GetInfo` solely because the count is named `numShownEntries`. Forever/native modern behavior was not confirmed. Source build was recorded but not matched to a running client.

**Correction:** Obtain collapse-independent membership through the compatibility layer; do not evict quests merely because their headers hide them.

**Focused validation:** Legacy client header collapse/expand with quests still active, plus an offline fixture preserving total quest count.

### 8. P2: An unavailable native special item prevents owned database fallback buttons

**Location:** `Modules/Tracker/TrackerUtils.lua:1078-1082,1112-1115,1148-1155`.

Native special-item link A is inserted first without checking possession. If `TrackerItemButton.SetItem(A)` cannot find it in bags/equipment, it returns false. Secondary candidate creation is nested under primary success, so an owned usable source/required item B is never attempted.

Master filters item candidates for possession first and displays B.

**Evidence:** Two independent offline comparisons using actual utility/button code: master displays the owned database item; HEAD attempts only the unavailable native item and displays neither. Parent traced candidate insertion, SetItem's failure return and the nested secondary path.

**Qualification:** The code failure is reproducible; no specific live quest was verified returning an unavailable native item alongside an owned database fallback. Do not describe this as an observed live-client failure.

**Correction:** Skip unavailable candidates or continue to later candidates when SetItem fails. Preserve the intended native-item bypass of database item class checks.

**Focused test:** Native candidate fails SetItem, database candidate succeeds; assert fallback is rendered.

## Removed-behavior replacement audit

| Old behavior | Replacement | Assessment |
| --- | --- | --- |
| Render enriched `currentQuestlog` objects | Stable `TrackerData` native display records | Logical replacement exists; collapsed-header membership remains unsafe on legacy enumeration. |
| Database-dependent titles and links | Native titles/levels through shared TrackerData formatting | Chat bracket format and state/difficulty formatting retained. |
| Quest numeric completion | `TrackerQuestieBehavior` calls existing `QuestieDB.IsComplete` | Source-item completion checks retained, not a second invented completion algorithm. |
| Additional completion and special objectives | Retained only after objective identity matching | Real metadata/locale cases falsely fail matching. Genuine mismatch rejection is intentional. |
| Missing-source-item synthetic step | Explicit copy from original quest when no native objectives exist | Logical replacement retained. |
| Objective rendering from original records | Dense display rows preserving NativeIndex and cached live progress | Native order, sparse source indices and progress preserved. |
| Hand-built objective text/counters | `TrackerData.GetObjectiveText` | Handles counters and non-counter completion; no further confirmed formatting regression. |
| In-place original-object incremental row reads | Refresh affected quest; resolve row by display index | Text-only update remains combat-safe; removed objective text clears until layout. |
| Mutable quest timer fields | Timers mutate stable display records | Required IDs and timer flags retained; no confirmed timer-field omission. |
| Unrestricted original-object map actions | Shared eligibility plus command-time refresh and original identity | Stale-action protection useful; undo/recovery overrestricted. |
| Unconditional saved-focus restoration | Validated restoration, else UnFocus | Missing-data state conflated with invalid target. |
| DB source/required/objective item candidates | Native-first plus deduplicated database candidates | Fallback failure path remains; native class bypass intentional. |
| Tracker membership from Questie DB | Native membership/index checks | Unknown quests supported; UI visibility must not become authoritative membership. |
| Known-only lifecycle cleanup | Tracker cleanup before enriched-object guard | Unknown quest state now cleaned; no additional confirmed lifecycle removal regression. |
| Single quick acceptance retry | Quick retry, pending-state guards and shared fallback timer | Logical recovery replacement; duplicate acceptance guards preserved. |
| Expired-marker whole-event return | Skip objective scan, still update tracker | Enables title recovery but loses queue suppression. |
| Shared dense objective-loader return | Sparse original-index result | Inspected comms/party consumers use indexed lookup; no broken consumer identified. |
| Empty-objective completion fraction / unchecked division | Explicit completion and bounded fractions | Safer for unloaded/zero-total objectives. |
| Missing-DB tracking warning | Native-only display | Intentional capability change, not missing error recovery. |
| Old TOC list | Three new modules in every supported TOC | All six manifests updated; generic unsupported-client TOC intentionally unchanged. |

Manual tracking now also respects `trackerShowCompleteQuests` because the Boolean grouping changed. This is a user-visible behavior change, but was not classified as a definite bug: master bypassed that option through operator precedence.

## Tests and validation

### Parent-run checks

1. Working tree during concurrent mock edits: `busted -p '.test.lua' .` -> **2229 successes, 0 failures/errors/pending**. This is not the committed branch result.
2. Clean HEAD archive without provider path: **2176 successes, 0 failures/errors, 1 pending**, provider conformance skipped because the sibling checkout was absent in the temporary location.
3. Clean HEAD archive with `QUESTIE_DB_PATH=/home/logon/projects/Questie-clones/QuestieDB`: **2209 successes, 0 failures, 1 error, 0 pending**.
4. Starting master archive, same provider, focused conformance file: **33 successes, 0 failures, the same 1 error**.
5. Error in both revisions: `test/QuestieDBMock.conformance.test.lua:542`, provider rejects field 999 with `Correction Conformance16:/EmptyRows Npc 1000000 field 999 replace: unknown field key`. Thus not introduced by the nine branch commits. Master subsequently received the mock fix described above; branch HEAD does not contain it.
6. `lua cli/validate-loader-usage.lua`: passed in working tree and committed HEAD archive.
7. Luacheck on all 14 changed production Lua files: **0 warnings, 0 errors**.
8. `git diff --check master...HEAD`: passed.
9. Parent cache reproduction compared committed master and HEAD, output recorded under finding 1.

Reviewers also ran focused suites and in-memory master/HEAD comparisons. Their overlapping counts are not summed into a unique total. No live WoW validation, secure-click testing or in-game performance measurement was performed.

### Why green tests missed the regressions

- Entity matching fixtures mainly use same-language simple monster metadata.
- Completion is commonly mocked; integration-style tracker tests do not establish all real source-item semantics.
- Combat queue mocks execute callbacks immediately rather than retaining them.
- Native item tests generally make SetItem succeed.
- Full tracker update fixtures often return no sorted quests, avoiding populated layout combinations.
- Membership fixtures assume expanded native headers.
- Cache recovery tests do not combine one recovered quest with a different unavailable quest and a legitimate decrease.
- Focus tests prove stale commands are rejected, not that existing persisted state can still be cleared or restored after temporary unavailability.

## Rejected or pre-existing concerns

- Rapid removal/reacceptance can skip deferred abandonment cleanup and preserve old completion cache. Reproduced on both master and HEAD; not charged to this branch.
- Completed-to-incomplete cache rejection exists on master. Finding 1 deliberately avoids it.
- Kill-credit nil Id alone does not break the new comparison; both IDs are nil. The confirmed mismatch is native/database type compatibility.
- Reputation-only direct navigation was not available previously. Its confirmed impact here is helper-location suppression and whole-quest focus gating.
- Disappearing objective menus on ordinary completion predates the branch.
- Genuine unknown/mismatched objectives intentionally lack unsafe map actions. The review does not recommend removing those checks.

## Recommended fix order

1. Cache recovery and identity matching.
2. Recovery/undo actions and deferred startup focus restoration.
3. Collapse-independent legacy membership.
4. Combat refresh coalescing and failed-item candidate fallback.
5. Rebase onto current master to pick up the separately committed mock correction, then rerun focused cases and full suite.

The findings, focused reproduction script and its README are the commit-ready review artifacts. Source archives and captured output remain local and ignored; neither is needed for the fixes. See `review-artifacts/README.md` for reproduction instructions using the pinned Git revisions.
