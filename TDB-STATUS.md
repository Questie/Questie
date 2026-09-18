# QuestieDB cutover status

Questie reads entity data from the QuestieDB addon instead of a runtime compiler. Decisions:
`docs/adr/0001` to `0003` here, ADR 0007 to 0009 in QuestieDB. Object-hover lookup:
`QUESTIE-OBJECT-NAME-INDEX.md`. Runtime support-data controls and failure behavior:
[`docs/support-validation.md`](docs/support-validation.md). How the cutover was delivered, with commit pointers and review findings:
`docs/tdb-history.md`. Live client findings: `TDB-FINDINGS.md`. How the pieces fit is documented in the code: the header of
`Database/Corrections/QuestieCorrections.lua`, Stage 1 of `Modules/QuestieInit.lua`, and the header
of `Localization/l10n.lua`.

## Branches and merge order

The stack was rebuilt bottom-up from `origin/master` at `215b0c757`:

- `QuestieTDB-remove-baseline` at `6d86dbd22` deletes the compiler, entity data, generated entity
  localization, provider-owned Corrections and support payloads, and validators. It is intentionally
  non-functional and never merges alone.
- `QuestieTDB-remove-baseline-dependencies` at `fa263b64a` contains the consumer cleanup needed by
  the implementation. It is also intentionally runtime-incomplete; green tests are not a gate for
  this intermediate branch.
- `QuestieTDB-implementation` adds the provider bindings and Policy Corrections, with master's
  newer objective-loading and object-tooltip behavior preserved.
- The support layer consists only of the support-validation and CI-compatibility commits replayed on
  the finalized implementation. It does not restore local support payloads or their TOC entries.
  Review and merge the stack downward through implementation, dependencies, and baseline before
  merging the combined baseline into `master`.

The four pre-restack tips remain recoverable under
`backup/tdb-stack-20260914/{QuestieTDB-remove-baseline,QuestieTDB-remove-baseline-dependencies,QuestieTDB-implementation,QuestieTDB-implementation-support}`.
Their common base was `fde81078a`; do not confuse those historical tips with the current stack.

## Merge gates

Provider status checked against the sibling `QuestieDB` checkout at `60f0527`. The project,
addon identity, and dependency declarations now use `QuestieDB`.
The statuses below describe implementation evidence, not current GitHub issue closure.

Provider issues, all in the QuestieDB repo:

| Issue | What it gates |
| --- | --- |
| #1 / #13 | Active-SoD `requiredRaces` parity is implemented with 25 provider-owned Dynamic Correction rows. The provider handover records comparisons matching all 5,534 SoD quests for both factions. Replacing the temporary base-flavor inference remains a provider follow-up. |
| #14 | Built-in lookup overrides and Titan zhCN entity localization. Implemented in the provider; Questie consumes translation slots, including custom locales. Offline validation passed. |
| #15 | Support data sync and Source-mode flavor selection. Questie reads Zones, QuestXP, DropTables, and faction templates through `LibQuestieDB.Support`. All five flavors and both factions passed the offline real-provider wrapper checks. Questie also applies [bounded runtime controls](docs/support-validation.md) to the support tables it consumes. |
| #17 | `ObjectiveFirst` flavor and season scoping is implemented. The provider records parity across Source, Baked, and packages with Static Corrections stripped. |
| #19 | Differential coverage proving `classicQuestReputationFixes`, `itemStartFixes`, `AutoTableUpdates` NPC flags, static fixes, and SoD side channels are represented in provider data. |

Questie-side gates:

- Provider data sync is complete through `215b0c757`. Provider commit `be3e7f6` advanced
  `QUESTIE_COMMIT` from `92ab8206f` and ported all ten changed Correction files, plus the
  comments-only Zone-data map change. Retained policy updates stay in Questie. The provider's
  `docs/questie-handover.md` records all-five-flavor validation and reviewed Golden updates for
  this sync; those full gates were not rerun during this status update. Any later changes to
  provider-owned data on Questie master still need reconciliation before merge.
- Temporary Source-mode conformance is defined in `.github/workflows/provider-conformance.yml`.
  The `QuestieDB master conformance` check follows provider `master`, logs the resolved SHA,
  and sets `QUESTIE_DB_PATH`; a missing configured checkout fails rather than pending.
  Provider changes can change the result without a Questie commit. Branch protection is
  configured separately. Supported-release/Baked coverage, the release-required/master-advisory
  split, and committed real-provider support-wrapper integration tests remain open;
  see `CI-PROVIDER-COMPATIBILITY.md`.
- Current Contract Version 2 live smoke matrix: Era, SoD, TBC before and after phase 3, WotLK, Titan season 109, Cata, MoP,
  one built-in non-English locale, one external locale addon. Check gathering-node suppression,
  Darkmoon, Content Phase prerequisites, Townsfolk, Available Quests, Objective Order, Special
  Objective text, and runtime missing-Item repair.
- Coordinate acceptance: provider ADR 0006 resolves QuestieDB #3 by preserving raw coordinates;
  only the migration compiler comparison adapts base values to the legacy grid. Record consumer
  acceptance or any necessary caller changes during the live checks, rather than reopening the
  provider storage decision.
- Mock-versus-provider conformance: the harness runs the double's cases against the real provider
  in Source mode (`TDB-FINDINGS.md` F7, F8). Local runs pend when the default sibling checkout is
  absent; an explicit missing `QUESTIE_DB_PATH` fails. It covers
  Contract Version 2 translation slots. Support wrapper checks cover all five flavors and both
  factions. From this Questie checkout, run the conformance cases against the sibling provider with:

  ```bash
  QUESTIE_DB_PATH=../QuestieDB busted test/QuestieDBMock.conformance.test.lua
  ```

## Provider type declarations

`.types/QuestieDB/` is a verbatim copy of QuestieDB `src/types/*.t.lua` (provider commit
`fdf740d`), the LuaLS declarations for `LibQuestieDB` and the Database Key Enums. WoW never
loads them. Refresh by copying the seven files again when the provider schema changes; the ID
aliases (`QuestId`, `NpcId`, ...) are defined on both sides by design.

## Open Questie follow-ups

None block the merge. Numbered items came from the simplification review.

- Object tooltips now need provider-wide name uniqueness for zone filtering even when Object IDs
  are hidden. Stage 2 warms the provider index after locale and policy setup to avoid a cold first hover.
- Contract gate: Stage 1 checks `RequireContract(2)` and the `l10n.SetCorrection` capability before
  locale forwarding or external entity publication. Support wrappers bind provider payloads while
  addon files load, before Stage 1; an incompatible provider can therefore still fail at a binding
  site before the Contract message is raised.
- Item repair now publishes `Item:RuntimeItemRepair` once per frame (`TDB-FINDINGS.md` F2).
  Uncached Items still arrive one per client event across frames; if that shows as a hitch on
  SoD, widen the window from `C_Timer.After(0)` to a short debounce.
- Townsfolk rebuilds every login into module tables (`Townsfolk.townsfolk` and friends);
  Migration 39 drops the five former `Questie.db.global` keys. Caching across sessions waits
  for a provider data revision.
- Distribution: bundle QuestieDB in release packaging. Diagnostics: surface provider Source or
  Baked mode in Questie's debug output.
- Pre-existing, noted during review: the Isle of Quel'Danas phase option writes
  `Questie.db.profile` while the blacklist merge reads `global`; the Event and QuestieLib test
  suites leak `Expansions.Current` and `C_Calendar` stubs between cases.

## Validation

The full-suite results below are historical; they are not a fresh full-suite run against provider
`60f0527`. Focused checks during the current workspace inspection passed, including 34 real-provider
Source-mode conformance cases and loader-usage validation. No Baked artifacts were generated and
no live client was accessed.

After the bottom-up restack, the implementation passed the full suite with
`QUESTIE_TDB_PATH=/home/david/private/questietdb`: 1,665 successes, 0 failures, 0 errors, and 0 pending. Luacheck passed across 304 files; loader-usage validation and `git diff --check` also passed.
A fresh focused review found no issues. With the two support commits replayed, the full suite passed
1,779 tests with the same provider checkout and no failures, errors, or pending tests. No live-client
test, build, push, or provider change was made.

## Live smoke results

Era and SoD passed on 2026-09-02 for the historical Contract Version 1 revision. Every finding,
with evidence and proposed action, is in `TDB-FINDINGS.md`. The current Contract Version 2
integration has not completed live validation. Recheck Era and SoD against the current contract,
then cover TBC before and after phase 3, WotLK, Titan season 109, Cata, MoP, a Darkmoon week,
an external locale addon, and a non-English client locale.
