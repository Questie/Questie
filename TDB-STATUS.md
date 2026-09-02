# QuestieTDB cutover status

Questie reads entity data from the QuestieTDB addon instead of a runtime compiler. Decisions:
`docs/adr/0001` to `0003` here, ADR 0007 to 0009 in QuestieTDB. Object-hover lookup:
`QUESTIE-OBJECT-NAME-INDEX.md`. How it was delivered, with commit pointers and review findings:
`docs/tdb-history.md`. How the pieces fit is documented in the code: the header of
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
| #1 / #13 | `requiredRaces` inference, including SoD after composition. Questie deleted its own inference and consumes the provider result. |
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
- Live smoke matrix (Era done, see below): SoD, TBC before and after phase 3, WotLK, Titan season 109, Cata, MoP,
  one built-in non-English locale, one external locale addon. Check gathering-node suppression,
  Darkmoon, Content Phase prerequisites, Townsfolk, Available Quests, Objective Order, Special
  Objective text, and runtime missing-Item repair.
- Coordinate normalization: QuestieTDB ADR 0006 stores raw coordinates where the compiler used to
  round. Decide whether the differences need caller changes or are accepted as-is, and record it.
- Mock-versus-provider conformance: run `test/QuestieTDBMock.test.lua` semantics against the real
  `LibQuestieDB`. The double has been wrong about provider semantics once (`0`, not nil, for an
  absent number field).

## Open Questie follow-ups

None block the merge. Numbered items came from the simplification review.

- Provider-side: build the Object name index lazily or on `SetLocale` so the two Questie
  `BuildNameIndex` call sites (Stage 2, options toggle) can go.
- `RequireContract(1)` runs five times: Stage 1 plus file load in the four `Database/*DB.lua`
  adapters. A file-load `error()` leaves Questie half-loaded; keep only the Stage 1 check.
- The four adapter files each bind one key enum and one query order. One loop in `QuestieDB.lua`
  replaces them and four TOC lines each.
- Seventeen query and Objective Order aliases are bound in `QuestieDB.Initialize` although the
  provider is present at file load. Bind statically; `Initialize` becomes caches plus pointers.
- `LoadDarkmoonFixes` and `LoadContentPhaseFixes` are still method-style classes in
  `Database/Corrections/QuestiePolicy`. They are plain row producers now and can flatten.
- `_QuestieDB.objectCache` is read but never written (the store is commented out). Delete or
  enable, not both halves.
- Item repair writes the `Item:RuntimeItemRepair` slot once per asynchronous callback. Measured
  cost is the Item compose iteration only; coalesce per frame if a Stage 3 hitch ever shows.
- Townsfolk rebuilds every login and still writes to `Questie.db.global` although nothing reads it
  across sessions. Replace with a module-local table once the provider exposes a data revision.
- Distribution: bundle QuestieTDB in release packaging. Diagnostics: surface provider Source or
  Baked mode in Questie's debug output.
- Pre-existing, noted during review: the Isle of Quel'Danas phase option writes
  `Questie.db.profile` while the blacklist merge reads `global`; the Event and QuestieLib test
  suites leak `Expansions.Current` and `C_Calendar` stubs between cases.

## Live smoke results

**Era, 2026-09-02, enUS, baked mode, QuestieTDB `eaea07d`.** Passed through the Lua bridge on a
level 5 character: Contract gate, ID maps populated, gathering-node spawns hidden with raw data
intact and `Questie` provenance, quests 10944 and 11007 absent, Townsfolk built, tracker drawn, name
index and `IdsByName` working, `SetLocale("deDE")` localizing reads and rebuilding the name index
with the gathering suppression intact. A write-through probe (publish, verify composed read, cached
NPC eviction, NPC map swap with Quest map kept, correction-added ID visible, withdraw, restore)
passed, and the Classic Darkmoon producer published and withdrew correctly through the live slot.

Found:

- Provider: `ObjectiveFirst.eventObjectiveFirst` carries the three SoD quest IDs (85304, 85386,
  89567) on plain Era in baked mode. Upstream loaded those only on SoD. Harmless today because the
  IDs do not exist on Era, but it is the flavor leak issue #17 describes, in baked rather than
  Source mode.
- Provider: `requiredRaces` inference (#1/#13) is not active. 1,382 of 4,257 Era quests read `0`
  raw and composed; 16 of those have only Alliance-faction starters and none only Horde, so the
  regression against upstream's inference is 16 quests on Era. SoD and later flavors unmeasured.
- Questie: `QuestieCorrections.correctionSources` records the profiler wrapper or the bridge's
  `pcall` frame instead of the real caller while the profiler is on. Cosmetic.

Still to smoke: SoD, TBC before and after phase 3, WotLK season 109, Cata, MoP, an external locale
addon, and a Darkmoon week with the calendar-driven path.
