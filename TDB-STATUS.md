# QuestieTDB cutover status

Questie reads entity data from the QuestieTDB addon instead of a runtime compiler. Decisions:
`docs/adr/0001` to `0003` here, ADR 0007 to 0009 in QuestieTDB. Object-hover lookup:
`QUESTIE-OBJECT-NAME-INDEX.md`. How it was delivered, with commit pointers and review findings:
`docs/tdb-history.md`. Live client findings: `TDB-FINDINGS.md`. How the pieces fit is documented in the code: the header of
`Database/Corrections/QuestieCorrections.lua`, Stage 1 of `Modules/QuestieInit.lua`, and the header
of `Localization/l10n.lua`.

## Branches and merge order

- `QuestieTDB-remove-baseline`: deletes the compiler, raw data, generated localization, static
  corrections, and validators from `master`. Intentionally non-functional. Never merges alone.
- `QuestieTDB-implementation`: cut from the baseline, lands the provider binding and Policy
  Corrections. Green: full Busted, production luacheck, loader-usage validation.
- Merge `implementation` into `baseline`, then the combined branch into `master`. Immediately before
  that, run QuestieTDB's master-data sync so data fixes landed on `master` while the stack was open
  move to the provider. A modify/delete rebase conflict on a deleted file means a fix needs porting to
  QuestieTDB data.

## Merge gates

Provider issues, all in the QuestieTDB repo:

| Issue | What it gates |
| --- | --- |
| #1 / #13 | `requiredRaces` inference for SoD quests composed at runtime. The bake-time pass already matches upstream on Era (`TDB-FINDINGS.md` F3). |
| #14 | Built-in lookup overrides and Titan zhCN entity localization. Questie deleted `lookupOverrides.lua`. |
| #15 | Support data sync and Source-mode flavor selection. Unblocks reading Zones, QuestXP, DropTables, and faction templates through `LibQuestieDB.Support`. |
| #17 | `ObjectiveFirst` flavor scoping in Source mode. |
| #19 | Differential coverage proving `classicQuestReputationFixes`, `itemStartFixes`, `AutoTableUpdates` NPC flags, static fixes, and SoD side channels are represented in provider data. |

Questie-side gates:

- Master-data import evidence: source commit `ba0f5acd63cbeb8e5affc5d1990b0d1ee276cd57` for the
  baseline, plus the pre-merge sync. Neither is recorded yet.
- Pinned Database Integration Check in CI. The old `db-validation` matrix is gone; the provider
  pins Questie through its own `QUESTIE_COMMIT` and documents no consumer-side command, so this
  waits for the final provider revision.
- Live smoke matrix (Era and SoD done, `TDB-FINDINGS.md`): TBC before and after phase 3, WotLK, Titan season 109, Cata, MoP,
  one built-in non-English locale, one external locale addon. Check gathering-node suppression,
  Darkmoon, Content Phase prerequisites, Townsfolk, Available Quests, Objective Order, Special
  Objective text, and runtime missing-Item repair.
- Coordinate normalization, QuestieTDB #3: ADR 0006 stores raw coordinates where the compiler used to
  round. Decide whether the differences need caller changes or are accepted as-is, and record it.
- Mock-versus-provider conformance: done. `test/QuestieTDBMock.conformance.test.lua` runs the
  double's cases against the real provider in Source mode (`TDB-FINDINGS.md` F7, F8); it pends
  when the QuestieTDB checkout is absent.

## Open Questie follow-ups

None block the merge. Numbered items came from the simplification review.

- Provider-side: build the Object name index lazily or on `SetLocale` so the two Questie
  `BuildNameIndex` call sites (Stage 2, options toggle) can go.
- Contract gate: only Stage 1 checks `RequireContract(1)`. `QuestieDB.lua` indexes the provider
  at file load without a gate; a provider that passes the Contract but lacks a field would
  nil-index there, and Stage 1 still reports the Contract message afterwards because later
  files keep loading.
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

## Live smoke results

Era and SoD passed on 2026-09-02. Every finding, with evidence and proposed action, is in
`TDB-FINDINGS.md`. Still to run: TBC before and after phase 3, WotLK season 109, Cata, MoP, a
Darkmoon week, an external locale addon, and a non-English client locale.
