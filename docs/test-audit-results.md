# Test-value audit disposition

## Scope

This repair applies the audit's concrete findings to an isolated canonical `master` clone.
The original audit inspected a diverged Forever working tree. Its file counts, line numbers,
and 2,565-test result are not this checkout's baseline. The master baseline was 2,137 Lua successes.
The original worktree remains untouched; no Forever suites were imported to inflate coverage.

Changes strengthen observable contracts, isolate fixtures, and remove redundant checks.
No addon runtime module changed. The only non-test executable fix is in `upload-cf.sh`:
CurseForge relation objects now quote their `slug` and `type` JSON keys.
The shared `test/QuestieDBMock.lua` double also changed, as described below.
No live client, persistent database, or network upload was used. Upload checks use fake curl
and temporary local Git repositories; provider conformance runs headlessly in memory.

## Contracts by area

| Area | Meaningful checks retained or strengthened |
| --- | --- |
| Database and localization | Discriminating phase IDs, independent seasonal flags, sparse-map emptiness, same-day holiday minute boundaries, same-datatype correction-slot withdrawal, prerequisite OR semantics, exclusive-query avoidance, and instance entry/exit XP contrasts. Existing localization and policy coverage remains. |
| Quests, events, and auto-questing | Distinct finisher icons and waypoint results; real nil-spawn objectives reaching tooltip consumers; queued-pass restart after callback errors; deferred unload before populate/draw; selected abandonment target and order; populated realm cleanup; targeted versus full scans; eligible guard negatives and activated phase-ending cases. |
| Tracker, map, and frame pool | Frame data cleared on unload, exact frame-level ordering and literal icon levels, exploration visibility changes, quest ID versus log index, installed item-button hooks, selection during abandonment/time reads, fresh item allocations, and actual queued refresh/collapse/bag cleanup callbacks. |
| Tooltips, links, Journey, and public API | Correct GUID argument position, complete tooltip destination arguments, rendered packed values, shared-key removal preserving another quest, vendor level 39/40 boundary, consumed trainer-input preservation, exactly-once readiness, and throwing subscribers not blocking healthy subscribers. Existing Journey navigation coverage remains. |
| Core modules | Deferred configuration/UI initialization, profession-reset effects after setup, independent compatibility expectations, explicit reputation expansion/friendship prerequisites, and successful raid-only player lookup. |
| Network | Real codec initialization with missing-dependency contrasts, assertions outside protected callbacks, deferred visibility replacement/cancellation, atomic rejection of malformed snapshots, direct no-draw checks, and recycled-frame identity protection. |
| Libraries and widgets | Same-instance distance and hostile-filter discrimination, host-independent date expectations, stack-depth attribution, real popup lifecycle, ThreadLib completion/error/cancellation, literal UTF-8 wrapping and byte offsets, executable TreeGroup controls, and popup-stack upgrades through LibStub rather than source rewriting. |
| Profiler engine and reports | Completed-job closure/payload collection, repeated calls of one closure, final pre-hook sweep, foreign hook ownership, weighted average 26 rather than 25, colliding job folds, exact heat shares, incoming/outgoing edges, and complete source-state preservation. |
| Profiler UI | Nil unknown frame state, real control callbacks, visible relation navigation and root guard, refresh effects, ticker cancellation/restart, and indicator polling. The seam models controls, not native rendering or geometry. |
| Entry point, CLI, build, and release | Positive real scanner findings and deduplication, Camelot TOC coverage, static whitespace fixture, real issue-6734 event/cache flow, output sentinels surviving rejected builds, archive test exclusion and Forever aliases, and parsed upload JSON with exact escaped changelog content and request arguments. |

Changed suites restore owned globals and use explicit per-case prerequisites. Isolated and
shuffled runs exposed additional AutoQuesting, announcement, and tracker fixture dependencies;
those were repaired locally rather than hidden by broad successful defaults in `setupTests.lua`.

## Provider-double boundary

See [QuestieDB integration](questiedb-integration.md) for production ownership.
The double and paired conformance tests now distinguish these publication/read contracts:

- Raw reads bypass overlays. Existing base entities return missing numeric fields as `0`;
  absent `Quest.startedBy`, `finishedBy`, and `objectives` return fresh empty tables.
  Missing and overlay-only entities still return raw `nil`.
- Published nested values are snapshots, not caller-owned references. A later explicit
  publication can expose changed retained data; mutation alone cannot change published reads.
- `Set` recomposes only its datatype across ranked owners, preserving other datatype snapshots.
  A first publication initializes selected function results. Later `Set` reuses those results;
  owner `Apply` refreshes that owner's functions and rereads selected data across ranked owners.
- Composition stages rows before committing. Rejected writes preserve successful publication;
  rejected withdrawal restores the targeted slot's last-successful data. Rejected first `Set`
  also rolls back its new slot and owner rank. Tests distinguish untouched overlay-map identity.

This is a focused consumer double, not a complete provider registry model. It deliberately omits
write normalization, table-operation corrections, encoding/backends/read caches, flavor-filtered
registration, dirty/pending retry machinery, and no-argument `Apply`. Tests seed normalized rows.
On rejection it retains successful function snapshots, unlike provider memo invalidation.
Explicit owner `Apply` retries that owner's datatypes; cross-owner retry scheduling is not modeled.
Paired scenarios pin selected contracts with literal expectations, not all provider behavior.

## Disabled, replaced, and removed checks

DailyQuestComms previously registered none of its 61 bodies through a no-op `skip`.
It now runs 38 receiver cases and reports one explicit pending item for disabled registration
and outbound delivery. Receiver tests exercise routing, malformed input, filtering, cancellation,
request reset, and deferred answer delegation. They do not establish working live transport or
re-enable outbound functionality.

TreeGroup source-string checks were replaced with real widget construction and interaction.
Popup consumers use the real dialog harness rather than reconstructed cancellation policy.
Removed checks include language-only multiple-return syntax, empty coroutine smoke, redundant
module/observer/retry/priority/announcement/Start cases, expected-string self-checks, unused
profiler helpers, and commented-out phasing bodies. Stronger consumer contracts remain.

The obsolete `ExternalScripts(DONOTINCLUDEINRELEASE)/slpp/tests.py` suite was retired.
Its Python 2 syntax is unsupported by the current Python 3 workflow, and its custom comparison
could miss extra data. The legacy README marks examples historical; the parser and
`stripItemData.py` consumer remain unchanged. This is not a Python 3 port or new parser coverage.

## Master-specific dispositions and remaining gaps

- `TrackerData.test.lua`, `TrackerMapEligibility.test.lua`, `TrackerQuestieBehavior.test.lua`,
  and `QuestieValidateGameCache.test.lua` are absent here. Their Forever coverage was not imported.
- `Modules/Tooltips/MapIconTooltip.lua` exists, but `MapIconTooltip.test.lua` does not.
  The audited rendering-boundary repair is therefore inapplicable to the selected test repair;
  master still lacks that suite's render-boundary coverage.
- The ignored local `cli/forever/Capture.test.lua` is absent on master and was not imported.
- The audited distinct-objective announcement case and richer Forever/native tracker and
  dispatch additions are absent. Existing master behavior, not absent branch features, was tested.
- SoM phase 2 and SoD phase 4 contain no separating quest data. No artificial discriminator
  or production policy change was added. Existing valid phase contrasts remain.
- Master's `QUEST_WATCH_UPDATE` is targeted, not a full scan. Full-scan assertions exercise
  `PLAYER_INTERACTION_MANAGER_FRAME_HIDE` instead.
- AvailableQuests cleanup checks persisted state and its public accessor. Test-only aliases can
  become stale when internal tables are replaced; alias liveness was not made a runtime contract.
- Keep verdicts were retained, not presented as completeness claims. Native rendering,
  live-client performance, and unmodeled provider behavior remain outside this validation.

## Validation and review evidence

Final integration validation passed. Scoped results below are not additive full-suite counts.

- `TZ=UTC busted -p '.test.lua' .`: **2,211 successes, no failures/errors, one intentional pending**.
- `TZ=UTC busted -p '.test.lua' --shuffle --seed=137 .`: **the same result**.
  The pending item is disabled DailyQuestComms registration/outbound delivery. Local sibling-provider
  conformance ran successfully; it was not skipped.
- `luacheck -q -- Database Localization Modules Public Questie.lua`: **zero warnings/errors in 322 files**.
- `lua cli/validate-loader-usage.lua`: no new runtime loader calls. `git diff --check` passed.
- Five Python suites: **91 passed** using `uv run --no-project --offline <file>` for
  `build.test.py`, `changelog.test.py`, `release_notes.test.py`, `upload-cf.test.py`, and `upload-wago.test.py`.
- Latest provider alignment: `busted test/QuestieDBMock.test.lua test/QuestieDBMock.conformance.test.lua`
  yielded **107 successes**; `busted -p '.test.lua' Database test` yielded **412**, also shuffled at seed 748.
  The 53 conformance cases also passed against a separate, exact QuestieDB `master` snapshot at
  `ffcb803715edeb3b5e5497fa84f95ca5b8eba471`, selected with `QUESTIE_DB_PATH`, matching CI's target.
- Area reports record quest/event/auto **469**, tracker/map/frame/options **215**, UI/public **137**,
  network **142 plus one pending**, core **201**, libraries **262**, profiler engine/report **234**,
  profiler UI **55**, and entrypoint/CLI **65** successes. Focused isolation and shuffle checks passed.
- Scoped lint and diff checks passed apart from the existing undefined Busted `pending` warning
  in provider conformance. Vendored widget changes passed `luac -p`.
- Fresh parent-scope review independently rejected a no-op scanner, destructive build-preflight
  mutations in all 12 subcases, and the original invalid CurseForge payload; it reported no issues.
- Provider review caught publication-scope, raw-default, and staged recomposition gaps, leading
  to the paired contracts above. The final focused reviewer confirmed the fixes and reported no
  issues within the documented model. Temporary mutations also rejected raw-default/snapshot regressions.
- Selected in-memory mutations rejected missing finisher icons, disabled queued restart, invalid
  visibility publication, wrong recycled-frame unload, stale daily coverage, nine profiler
  engine/report defects, and four UI defects. Removing the nil-spawn guard raised `next(nil)`.
  These are targeted reports, not a comprehensive mutation score or a live-client guarantee.

No runtime TOCs changed. CLI fixtures remain outside release packaging; runtime `*.test.lua`
files remain excluded from archives.
