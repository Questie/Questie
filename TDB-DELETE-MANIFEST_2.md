# QuestieTDB deletion manifest

## Purpose and branch strategy

This document is the specification for the `baseline` branch: a branch cut from `master` that
deletes everything that must be gone at the end of the QuestieTDB delivery. The baseline is
intentionally non-functional and never merges alone. An `implementation` branch on top of it
re-lands the QuestieTDB work (using the current `QuestieTDB` branch as the reference
implementation) and re-adds every extracted Questie-owned artifact listed here. The
implementation branch merges into the baseline first; only the combined, fully green stack
merges to `master`.

Owner decisions this manifest encodes:

- Externally gated items (QuestieTDB #13 `requiredRaces` inference, #14 built-in
  lookups/Titan zhCN) are deleted in the baseline and tracked as must-complete work packets,
  not retained as code.
- Quest-data fixes that land on `master` while the stack is open are transferred by
  QuestieTDB's own master-data sync before the merge; modify/delete rebase conflicts on
  deleted files signal data that must move to QuestieTDB, not merge chores.

All liveness evidence below was verified by command against the current working tree and
`origin/master` (`ba0f5ac`). Line numbers cite the branch stated in each entry; the baseline
deletes from `master`, so master anchors are authoritative for the deletion itself.

## Tags

- `[baseline-delete]` — dead or compiler-only; delete, nothing replaces it in Questie.
- `[delete + re-add]` — the file dies, but it contains Questie-owned artifacts the
  implementation branch must extract and re-land (artifact and future owner named).
- `[delete + work-packet]` — delete now; the named work packet must complete before the stack
  merges to `master`.
- `[stays]` — looks related but is retained Questie policy/runtime; listed to prevent
  over-deletion.

## 1. Compiler engine

| Entry | Evidence | Tag |
| --- | --- | --- |
| `Database/compiler.lua` (1,324 lines) | Live on master (`QuestieDB:Initialize` binds queries via `GetDBHandle`, master `Database/QuestieDB.lua:272-276`); on the QuestieTDB branch it is write-only dead code | `[baseline-delete]` |
| `QuestieDBCompiler` import + `Compile()` call, master `Modules/QuestieInit.lua:35, :165` (branch `:35, :179`) | Compile-path only | `[baseline-delete]` |
| Compiler saved-variable writers, `Database/compiler.lua:1055-1066` (`dbCompiled*`, `sod.dbCompiled*`) | Die with the file | `[baseline-delete]` |

## 2. Raw entity data files (~502,600 lines)

All twenty files hold `[[return {...}]]` loadstrings parsed only by the compile path
(`QuestieInit:LoadDatabase`, master `:355`, branch `:368`).

| Entry | Lines | Tag |
| --- | --- | --- |
| `Database/Classic/classic{Item,Npc,Object,Quest}DB.lua` | 36,022 | `[delete + work-packet]` → Townsfolk conversion (TDB-06) |
| `Database/TBC/tbc*DB.lua` | 59,226 | same |
| `Database/Wotlk/wotlk*DB.lua` | 88,523 | same |
| `Database/Cata/cata*DB.lua` | 140,937 | same |
| `Database/MoP/mop*DB.lua` | 177,850 | same |

Raw-table consumer checklist (every production reader/writer of `QuestieDB.questData` /
`npcData` / `itemData` / `objectData` on the current branch; each must be converted or die with
this manifest — this is the TDB-06 checklist):

- `Modules/QuestieMenu/Townsfolk.lua:32, :166-167, :396, :415, :440, :611-612` — LIVE consumer
  on the compile path; **must be converted to composed reads before the stack merges**
  (work packet: TDB-06).
- `Localization/l10n.lua:63-96` — entity-write portion of `l10n:Initialize()`; dies (section 5).
- `Database/Corrections/QuestieCorrections.lua:383-415` (branch) — derived `requiredRaces`
  patch; dies (section 4).
- `Database/QuestieDB.lua:2075+` (branch; master `:2080`) — `_QuestieDB:HideClassAndRaceQuests()`
  iterates `questData`; **zero callers on both branches** (verified by `rg`/`git grep`) —
  `[baseline-delete]`.
- `Modules/QuestieCleanup.lua:11-14` — nils the raw tables; dies (section 3).
- `Database/Corrections/AutoTableUpdates.lua` — writes `npcData[id][npcFlags]` at file-load
  time (section 4).
- Hedges: `Modules/Quest/AvailableQuests/AvailableQuests.lua:560`
  (`QuestPointers or questData`) and `Modules/Libs/QuestieLib.lua:406`
  (`ItemPointers or itemData`) — drop the raw fallback; no other `Pointers or` hedge exists
  (verified repo-wide).

## 3. Init and lifecycle (master anchors)

| Entry | Evidence | Tag |
| --- | --- | --- |
| `loadFullDatabase()` (master `Modules/QuestieInit.lua:117-141`), `LoadDatabase` (`:355`), `LoadBaseDB` (`:371-376`) | Compile path only | `[baseline-delete]` |
| Stage-1 compile branch + `dbIsCompiled*` reads (master `:159-172`; branch `:162-186`) | Branch selector for the compiler | `[baseline-delete]` |
| Townsfolk rebuild gate on `dbCompiledCount` (branch `:188-193`) | Reworked, not deleted — Townsfolk conversion decides the new invalidation key | `[delete + work-packet]` → TDB-06 |
| `QuestieDB.private:DeleteGatheringNodes()` call (master `:136`) and helper (master `Database/QuestieDB.lua`) | Already replaced on the branch by the `GatheringNodeDisplayPolicy` correction | `[baseline-delete]` |
| `Modules/QuestieCleanup.lua` (23 lines) + its import/call (branch `Modules/QuestieInit.lua:33, :210`) | Only nils raw tables and lookups that no longer exist | `[baseline-delete]` |
| `QuestieInit` Stage 1 shape from the QuestieTDB branch (contract gate `:152`, correction registration, event ordering) | Re-landed by the implementation branch | `[delete + re-add]` → implementation branch |

## 4. Static correction files (~210,300 lines incl. `Automatic/`)

The 28 per-expansion fix files (`Database/Corrections/{classic,tbc,wotlk,cata,mop,sod}{Quest,NPC,Item,Object}Fixes.lua`,
~103,940 lines) are provider-owned data already ported to QuestieTDB.
`[delete + re-add]` for the extractions below, `[baseline-delete]` otherwise. Colocated live
artifacts that must be extracted first (all verified called from retained runtime code):

| Extracted artifact | Current home | Future owner |
| --- | --- | --- |
| Era Darkmoon table producer `LoadDarkmoonFixes(isInMulgore)` | `classicNPCFixes.lua:3719-3778` | Questie-owned holiday file (consumed by `QuestieEvent` → `SetDarkmoonNpcCorrections`) |
| TBC Darkmoon table producer `LoadDarkmoonFixes(isInMulgore, isInTerokkar)` | `tbcNPCFixes.lua:2096-2183` | same |
| `QuestieTBCQuestFixes:LoadContentPhaseFixes()` | `tbcQuestFixes.lua:8819-8830` | Questie-owned Content Phase policy file (LIVE: called by the `ContentPhasePolicy` provider) |
| Objective Order sources | inside fix files | already served by `LibQuestieDB.ObjectiveFirst`; verify no residual consumer hint is lost |

`Database/Corrections/Automatic/`:

| Entry | Lines | Tag |
| --- | --- | --- |
| `sodBase{Items,NPCs,Objects,Quests}.lua` | 90,198 | `[baseline-delete]` — QuestieTDB owns SoD base data (season-gated manifest sets) |
| `classicQuestReputationFixes.lua` | 12,775 | `[baseline-delete]` — compile-path only (`QuestieCorrections.lua:328`); verify ported via differential coverage (QuestieTDB #19) |
| `itemStartFixes.lua` | 2,272 | `[baseline-delete]` — compile-path only (`QuestieCorrections.lua:380`); same #19 caveat |

Master-only Titan files (post-divergence split):

| Entry | Lines | Tag |
| --- | --- | --- |
| `titanReforged{Item,NPC,Object,Quest}Fixes.lua` | 1,120 | `[baseline-delete]` — duplicated by QuestieTDB `Titan/*` Dynamic Corrections (master `MinimalInit:158-161` applies them) |
| `titanReforgedQuestTags.lua` | 49 | `[stays]` — feeds `questTagInfoCorrections.lua:2623`, a retained Questie runtime projection |

`QuestieCorrections.lua` compiler-era portions (branch anchors): `Initialize(validationTables)`
`:324+`, `_LoadCorrections`, the `requiredRaces` patch `:383-415`
(`[delete + work-packet]` → **QuestieTDB #13** — ticket exists in the QuestieTDB repo; the
inference logic moves there), `WAYPOINT_MIN_DISTANCE`/`ZONE_SCALES` `:425-442`,
`OptimizeWaypoints` `:444+`, `PreCompile` `:487+` — all `[baseline-delete]` except as tagged.
The registrar/setter/blacklist half of the file is re-landed by the implementation branch.

`Database/Corrections/AutoTableUpdates.lua` (439 lines): `[baseline-delete]` — file-load-time
write of `npcFlags` into `QuestieDB.npcData`, which is still an unparsed loadstring at that
point, so the guard `if QuestieDB.npcData[id]` never passes; evidence says it is inert today.
Verify the `npcFlags` values exist in QuestieTDB data (#19) before merge.

Explicitly `[stays]` (verified live, Questie policy/runtime):

- `BlacklistFilter.lua`, `QuestieItemBlacklist.lua`, `QuestieNPCBlacklist.lua`,
  `QuestieQuestBlacklist.lua`, `HardcoreBlacklist.lua`
- `ContentPhases/` (all files)
- `Holidays/` — `QuestieEvent.lua` and `quests/*` event data (1,185 lines)
- `SeasonOfDiscovery.lua` (660 lines — runtime module logic, phase detection, settings)
- `questTagInfoCorrections.lua` (2,656 lines — bound by `QuestieDB:Initialize`)

## 5. Localization (~4,323,000 lines)

| Entry | Evidence | Tag |
| --- | --- | --- |
| `Localization/lookups/{Classic,TBC,Wotlk,Cata,MoP}/lookup{Items,Npcs,Objects,Quests}/` — 185 locale files, ~4,320,500 lines, plus 5 `lookupLoadstrings.test.lua` (2,340) | Consumed only by `l10n:Initialize()` entity writes | `[delete + work-packet]` → **QuestieTDB #14** (built-in provider localization) |
| `Localization/lookups/lookupOverrides.lua` (155) incl. `Questie.LoadTitanQuestLookupOverrides` | zhCN/Titan lookup overrides; caller-less on the branch, retained only pending #14 | `[delete + work-packet]` → #14 |
| `l10n:Initialize()` entity-write portion (branch `Localization/l10n.lua:47-99`) + the four entity lookup tables `:17-21` and their `QUESTIE_LOCALES_OVERRIDE` thunk writes `:123-126` | Raw-table writes; External Locale Override data becomes Policy Corrections (re-landed) | `[delete + re-add]` → implementation branch (`BuildExternalLocaleCorrections`, `ApplyEntityLocale`, `ApplyProviderLocale`, `RebuildObjectNameLookup`) |
| `cli/validate-localization.lua` (95) | Validates the deleted lookups | `[baseline-delete]` |

Explicitly `[stays]`:

- `Localization/Translations/` (53 files) — UI Translation Entries
- `Localization/lookups/lookupZones.lua` (3,125), `lookupZonesCorrections.lua` (1,373),
  `lookupQuestCategories.lua` (65) — Zone/Category Lookups, consumed by `l10n` and
  `Modules/Journey/QuestieJourneyUtils.lua`
- `QUESTIE_LOCALES_OVERRIDE` UI-translation consumption and `SetUILocale`/`InitializeUILocale`

## 6. Saved variables, migrations, UI

| Entry | Evidence | Tag |
| --- | --- | --- |
| `dbIsCompiled`/`dbCompiledOnVersion`/`dbCompiledLang`/`dbCompiledExpansion`/`dbCompiledCount` + `sod.*` variants | Writers: `compiler.lua:1055-1066`, resets in `QuestieMenu.lua:401-403`, `QuestieOptionsAdvanced.lua:42-44`, `QuestieStream.lua:248`, `QuestieDB.lua:257-259` | `[baseline-delete]` (SavedVariables cleanup + a `Migration.lua` step to drop stored values; `Migration.lua` itself has no compiler entries today — verified) |
| Debug "Recompile Database" menu button, `Modules/QuestieMenu/QuestieMenu.lua:398-406` | Compiler UI | `[baseline-delete]` |
| `QUESTIE_DATABASE_ERROR` recompile popup (`Database/QuestieDB.lua:250-272` branch) | Compiler corruption recovery | `[baseline-delete]` |
| `QUESTIE_LOCALE_CHANGE_CONFIRM` recompile path (`QuestieOptionsAdvanced.lua:~552` — `_InvalidateCompiledDatabase()` + `ReloadUI()`) | Locale change must instead call `l10n.ApplyEntityLocale()` (already implemented on the branch, unwired) | `[delete + re-add]` → implementation branch |
| `Modules/QuestieStream.lua:244-255` corruption branch (`dbIsCompiled = false` + recompile error) | Compiler residue inside a shared lib; `QuestieStream` itself is used by `QuestieSerializer` (comms) | strip the branch only; `QuestieStream` `[stays]` — verify which raw-mode readers are comms-reachable before deleting more |
| `QuestieValidateGameCache` | Game Cache Validation, not compiler-tied | `[stays]` |

## 7. CLI, CI, build

| Entry | Evidence | Tag |
| --- | --- | --- |
| `cli/validate-{era,tbc,wotlk,cata,mop,sod}.lua` (675), `cli/validators.lua` (1,403) + `validators.test.lua` | Validate raw data files | `[delete + work-packet]` → TDB-12 pinned Database Integration Check (QuestieTDB #19 differential coverage replaces data validation) |
| `.github/workflows/ci.yml` `db-validation` matrix (`:95`) | Runs the deleted validators | `[delete + re-add]` → pinned integration check job |
| `cli/dump.lua` (367), `cli/profiler.lua` (311) | Dev tools over raw data — verify before deleting; likely die with the raw files | `[baseline-delete]` (verify) |
| `build.py` | Includes whole directories (`:177`); no per-file list to edit | `[stays]` |
| `ExternalScripts(DONOTINCLUDEINRELEASE)/` | Dev-side generators for the deleted data; out of runtime scope — prune separately | note only |

## 8. TOC manifests

Every deleted file's line leaves all five flavor TOC Manifests. Approximate counts of affected
lines per TOC on the current branch (lookups + raw DB + fixes/Automatic + compiler):
Classic 25, BCC 22, WOTLKC 26, Cata 31, Mists 35. Master adds the four `titanReforged*Fixes`
entries. `Questie.toc` (7-line fallback stub) is unaffected.

## Summary totals (approximate)

| Area | Lines deleted |
| --- | --- |
| Entity lookups (#14) | ~4,323,000 |
| Raw entity data | ~502,600 |
| Static fixes + `Automatic/` + master Titan | ~210,300 |
| Compiler + init/lifecycle + UI/CLI residue | ~5,500 |
| **Total** | **~5.04 million lines** (plus TOC lines) |

## Consolidated work packets (must complete before the stack merges to master)

1. **Townsfolk conversion (TDB-06)** — convert the seven raw-read sites in `Townsfolk.lua` to
   composed reads and replace the `dbCompiledCount` rebuild key.
2. **QuestieTDB #13** — `requiredRaces` inference moves to the provider (ticket exists in the
   QuestieTDB repo); verify SoD coverage before merge.
3. **QuestieTDB #14** — built-in entity localization and Titan zhCN lookups served by the
   provider; verify one non-English locale end to end.
4. **QuestieTDB master-data sync** — run the provider's master-data fetch immediately before
   the merge so data fixes landed on master during the stack's lifetime are transferred.
5. **Differential coverage (QuestieTDB #19)** — confirms `classicQuestReputationFixes`,
   `itemStartFixes`, `AutoTableUpdates` npcFlags, and the static fix files are fully
   represented in provider data.
6. **CI replacement (TDB-12)** — pinned Database Integration Check replaces the `db-validation`
   matrix.
7. **Live smoke matrix** — Era, SoD, TBC (pre/post phase 3), WotLK, Titan season 109, one
   built-in non-English locale, one External Locale Override fixture.

## Consolidated extraction list (implementation branch re-adds)

| Artifact | From | To |
| --- | --- | --- |
| Era + TBC Darkmoon table producers | `classicNPCFixes.lua:3719`, `tbcNPCFixes.lua:2096` | Questie-owned holiday correction file |
| `LoadContentPhaseFixes` (quests 10944/11007) | `tbcQuestFixes.lua:8819` | Questie-owned Content Phase policy file |
| The QuestieTDB-branch implementation itself (registrar lifecycle, setters, `RefreshAfterCorrectionApply`, `IsInitialized`, mock + ~150 tests, Stage 1 order) | `QuestieTDB` branch (reference) | implementation branch, re-landed clean without dual-path scaffolding |
| Locale-change runtime path | recompile popup | `l10n.ApplyEntityLocale()` wiring |
| CI integration check | `db-validation` matrix | pinned QuestieTDB check |
