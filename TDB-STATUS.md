# QuestieTDB cutover status

Questie reads entity data from the QuestieTDB addon instead of a runtime compiler. Decisions:
`docs/adr/0001` to `0003` here, ADR 0007 to 0009 in QuestieTDB. Object-hover lookup:
`QUESTIE-OBJECT-NAME-INDEX.md`. How it was delivered, with commit pointers and review findings:
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

Provider issues, all in the QuestieTDB repo:

| Issue | What it gates |
| --- | --- |
| #1 / #13 | `requiredRaces` inference for SoD quests composed at runtime. The bake-time pass already matches upstream on Era (`TDB-FINDINGS.md` F3). |
| #14 | Built-in lookup overrides and Titan zhCN entity localization. Implemented in the provider; Questie consumes translation slots, including custom locales. Offline validation passed. |
| #15 | Support data sync and Source-mode flavor selection. Questie reads Zones, QuestXP, DropTables, and faction templates through `LibQuestieDB.Support`. All five flavors and both factions passed the wrapper check. |
| #17 | `ObjectiveFirst` flavor scoping in Source mode. |
| #19 | Differential coverage proving `classicQuestReputationFixes`, `itemStartFixes`, `AutoTableUpdates` NPC flags, static fixes, and SoD side channels are represented in provider data. |

Questie-side gates:

- Provider data sync remains pending. `origin/master` at `215b0c757` contains changes in ten files
  that this stack deletes and that have not been ported to QuestieTDB:
  `cataObjectFixes.lua`, `classicObjectFixes.lua`, `classicQuestFixes.lua`, `mopObjectFixes.lua`,
  `sodItemFixes.lua`, `sodQuestFixes.lua`, `tbcItemFixes.lua`, `tbcNPCFixes.lua`,
  `tbcQuestFixes.lua`, and `titanReforgedQuestFixes.lua`. Recover the exact post-pin changes with:

  ```bash
  git diff 92ab8206f..backup/tdb-stack-20260914/master -- Database/Corrections/
  ```

  Port provider-owned data changes to QuestieTDB before the combined merge. Retained policy updates
  stay in Questie. The source Zone-data map conflict changed comments only and needs no data port.
- Pinned Database Integration Check in CI. The old `db-validation` matrix is gone; the provider
  pins Questie through its own `QUESTIE_COMMIT` and documents no consumer-side command, so this
  waits for the final provider revision.
- Live smoke matrix (Era and SoD done, `TDB-FINDINGS.md`): TBC before and after phase 3, WotLK, Titan season 109, Cata, MoP,
  one built-in non-English locale, one external locale addon. Check gathering-node suppression,
  Darkmoon, Content Phase prerequisites, Townsfolk, Available Quests, Objective Order, Special
  Objective text, and runtime missing-Item repair.
- Coordinate normalization, QuestieTDB #3: ADR 0006 stores raw coordinates where the compiler used to
  round. Decide whether the differences need caller changes or are accepted as-is, and record it.
- Mock-versus-provider conformance: the harness runs the double's cases against the real provider
  in Source mode (`TDB-FINDINGS.md` F7, F8) and pends when the QuestieTDB checkout is absent. It covers
  Contract Version 2 translation slots. Support wrapper checks cover all five flavors and both
  factions.

## Provider type declarations

`.types/QuestieTDB/` is a verbatim copy of QuestieTDB `src/types/*.t.lua` (provider commit
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
- Distribution: bundle QuestieTDB in release packaging. Diagnostics: surface provider Source or
  Baked mode in Questie's debug output.
- Pre-existing, noted during review: the Isle of Quel'Danas phase option writes
  `Questie.db.profile` while the blacklist merge reads `global`; the Event and QuestieLib test
  suites leak `Expansions.Current` and `C_Calendar` stubs between cases.

## Validation

After the bottom-up restack, the implementation passed the full suite with
`QUESTIE_TDB_PATH=/home/david/private/questietdb`: 1,665 successes, 0 failures, 0 errors, and 0 pending. Luacheck passed across 304 files; loader-usage validation and `git diff --check` also passed.
A fresh focused review found no issues. No live-client test, build, push, or provider change was made.

## Live smoke results

Era and SoD passed on 2026-09-02 for the historical Contract Version 1 revision. Every finding,
with evidence and proposed action, is in `TDB-FINDINGS.md`. The current Contract Version 2
integration has not completed live validation. Still to run: TBC before and after phase 3, WotLK
season 109, Cata, MoP, a Darkmoon week, an external locale addon, and a non-English client locale.
