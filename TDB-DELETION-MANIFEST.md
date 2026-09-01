# QuestieTDB deletion manifest

## Purpose and authority

This is the master deletion manifest for replacing Questie's entity compiler and raw entity
localization with the Database Addon. It reconciles `TDB-DELETE-MANIFEST_1.md` and
`TDB-DELETE-MANIFEST_2.md`.

The baseline branch is a review tool. It first extracts Questie-owned policy from mixed correction
files, then removes the old architecture. This makes the ownership decision visible before the bulk
deletion and leaves the implementation branch with the data it must keep. The baseline branch must
remain a draft and must not merge into `master` without the implementation branch merged into it
first.

This file defines the deletion set and final ownership. It is not an instruction to delete files
from the current working branch immediately.

Use these documents to resolve implementation details:

1. This manifest is authoritative for deletions, retention, merge gates, and required extractions.
2. `TDB-RELAND-HANDOVER.md` is authoritative for branch mechanics, final module shapes, and Login
   Initialization order.
3. `TDB-DYNAMIC-CORRECTIONS-HANDOVER.md` is authoritative for the registrar contract, correction
   ownership, and Policy Correction behavior.
4. `TDB-REFACTOR.md` is the historical tracker. Its compiler-coexistence instructions and TDB-03
   startup details are superseded by the re-land handover.

`ApplyParameterized` does not exist. No implementation may restore it or preserve a compiler
fallback.

## Branch workflow

The branch names in this document are `baseline` and `implementation`. After `implementation`
merges into `baseline`, "combined branch" means the now-functional `baseline` branch.

1. Create `baseline` from the latest `master`.
2. Choose the exact Questie source commit and prepare its record in this file and the Database Addon
   import evidence. Include those record changes in the extraction commit; do not create an earlier
   `baseline` commit.
3. Configure the Database Addon master-data import to fetch that recorded Questie commit. The import
   may run after `baseline` is created, but it must pass before the combined branch merges.
4. Make the first `baseline` commit a behavior-neutral extraction. Move the Questie-owned Darkmoon
   and TBC Content Phase producers out of mixed provider files, update their callers and TOC entries,
   and keep this commit green.
5. Apply the deletions and reductions in this manifest as a separate commit or commit series.
6. Open a draft `baseline` merge request targeting `master`. Its commit order should show extraction
   before deletion. Mark it as not independently mergeable. CI after the deletion commits may be
   expected to fail or may be skipped because that state is intentionally non-functional.
7. Create `implementation` from `baseline`.
8. Reimplement the required Questie behavior fresh from the final contracts and open its merge
   request against `baseline`. Historical code may clarify behavior but is not a merge, rebase,
   cherry-pick, or mechanical-port source.
9. Require green CI and focused review on `implementation`, then merge it into `baseline`.
10. Immediately before final merge, sync Database Addon master data again. Any fix that landed on
    deleted Questie data while the stack was open must move to the provider and pass differential
    validation.
11. Run complete integration validation on the combined branch against the pinned provider revision.
12. Merge the combined branch into `master`. Questie `master` must never contain the deletion-only
    state.

## Classification

- **Delete** means Questie no longer owns the implementation or data.
- **Reimplement** means the current implementation is deleted and a smaller Questie-owned version is
  added on `implementation`.
- **Keep** means the code remains substantially as-is because it is Questie behavior or a deliberate
  compatibility seam.
- **Blocked** means deletion is allowed on the baseline, but the combined branch cannot merge until
  the named work packet passes.
- **Deferred** means it is outside this compiler/entity-localization delivery and must not be removed
  incidentally.

## Mandatory work packets

WP-00 gates the bulk deletion commit. The remaining packets gate the combined branch. They should
exist as files or linked issues on the branch so an agent cannot mistake missing provider behavior
for dead Questie behavior.

### WP-00: extract Questie-owned policy from mixed correction files

**Owner:** Questie `baseline` branch

**Must complete before deleting provider-owned correction files:**

- Move the Classic Darkmoon producer into
  `Database/Corrections/QuestiePolicy/classicPolicyCorrections.lua`.
- Move the TBC Darkmoon and Content Phase producers into
  `Database/Corrections/QuestiePolicy/tbcPolicyCorrections.lua`.
- Preserve the producer inputs, returned tables, IDs, fields, and load timing. Do not convert them to
  the final registrar API in the extraction commit.
- Update `QuestieEvent` and `QuestieCorrections` to use the extracted producers instead of reaching
  into provider-owned correction modules.
- Load `classicPolicyCorrections.lua` in all five flavor TOCs.
- Load `tbcPolicyCorrections.lua` in BCC, WOTLKC, Cata, and Mists, but not Classic.
- Add `Database/Corrections/QuestiePolicy/classicPolicyCorrections.test.lua` and
  `Database/Corrections/QuestiePolicy/tbcPolicyCorrections.test.lua`. Cover every supported Darkmoon
  location and TBC Content Phase result, then run the affected caller tests.
- Run the full Busted suite, full production luacheck, and `git diff --check` at the extraction SHA.
  Record successful normal CI for that exact commit before adding deletion commits.

Each extracted file must start with a short provenance and ownership comment. Record the original
file or files and the source commit, then explain why Questie keeps the data. Do not narrate the move
without the ownership reason. For example:

```lua
-- Extracted verbatim from Database/Corrections/classicNPCFixes.lua at <source commit>.
-- Questie keeps this data because Darkmoon location selection is Questie runtime policy.
```

**Evidence required:** source commit, extraction commit, old and new symbols, TOC matrix, focused and
full test results, full luacheck result, `git diff --check` result, and normal CI result for the
extraction SHA.

### WP-01: Database Addon master-data import

**Owner:** Database Addon

**Must complete before the combined branch merges:**

- Import entity data, provider-owned corrections, generated entity localization, and relevant side
  channels from the exact Questie `master` commit used to create `baseline`.
- Record the source Questie commit and generated Database Addon commit.
- Do not import from `baseline` after the source files have been removed.
- Regenerate Source and Baked outputs.
- Run differential validation against the recorded Questie source commit.
- Immediately before final merge, repeat the sync for relevant data changes that landed on
  `master` while the branch stack was open.
- Record expected Questie policy differences separately rather than normalizing them into provider
  data.

**Evidence required:** baseline source commit, import command, generated commit, pre-merge sync
source and generated commits, differential summary, and flavor coverage.

### WP-02: built-in lookup overrides and Titan zhCN parity

**Owner:** Database Addon

**Tracking:** QuestieTDB issue #14

**Must complete:**

- Import `Localization/lookups/lookupOverrides.lua` behavior owned by the Database Addon.
- Import Titan Reforged zhCN Quest entity localization.
- Prove built-in localized Item, Quest, NPC, and Game Object reads match the source data for every
  supported locale and applicable season.
- Prove `LibQuestieDB.l10n.SetLocale()` switches provider localization without compilation.

**Blocks the combined merge after baseline deletion of:** Questie's built-in entity lookup
registration, raw entity localization writes, `lookupOverrides.lua`, and
`Questie.LoadTitanQuestLookupOverrides()`.

### WP-03: `requiredRaces` ownership and SoD composition

**Owner:** Database Addon

**Tracking:** QuestieTDB issue #13. Add any other issue only after confirming it is still an active
dependency.

**Must complete:**

- Materialize or otherwise provide the current derived `requiredRaces` result.
- Cover SoD entities after Dynamic Correction composition.
- Prove parity for Era, SoD, TBC, WotLK, Cata, and MoP.
- Record any deliberate behavior change from Questie's inferred starter-faction rule.

**Blocks the combined merge after baseline deletion of:** the derived loop in
`QuestieCorrections:Initialize()` that inspects Quest starters and NPC faction data.

### WP-04: Objective Order and waypoint-derived parity

**Owner:** Database Addon

**Must complete:**

- Verify all five `LibQuestieDB.ObjectiveFirst` tables are flavor-correct in Source and Baked modes.
- Verify waypoint simplification is generated by the Database Addon and matches Questie's current
  Ramer-Douglas-Peucker result where parity is intended.
- Record any accepted differential as provider behavior, not as a silent deletion.

**Blocks the combined merge after baseline deletion of:** Objective Order side effects in expansion
correction files, `QuestieCorrections:PreCompile()`, `QuestieCorrections:OptimizeWaypoints()`, and
`Modules/Libs/RamerDouglasPeucker.lua`.

### WP-05: Database Addon contract and flavor gates

**Owner:** Database Addon and Questie integration

**Must complete:**

- Contract Version 1 owner-scoped registrar is available to Questie.
- Provider-owned faction, class, race, expansion, season, SoD, and Titan Corrections are registered
  and gated by the Database Addon.
- Titan Reforged is restricted to WotLK season `109`.
- All five Questie TOCs require the Database Addon.
- A pinned Database Integration Check loads the same provider revision used for final validation.

### WP-06: composed-read consumer conversion

**Owner:** Questie `implementation` branch

**Tracking:** TDB-06

**Must complete:**

- Convert every Townsfolk raw traversal to composed ID maps and query functions.
- Remove the `dbCompiledCount` rebuild gate. Rebuild Townsfolk on each Addon Load until the provider
  exposes a stable data revision.
- Remove the raw fallback in Available Quests.
- Prove Townsfolk policy, faction filtering, character filtering, Manual Notes, and Available Quest
  enumeration still work.

### WP-07: provider differential coverage

**Owner:** Database Addon

**Tracking:** QuestieTDB issue #19

**Must complete:**

- Prove the provider represents `classicQuestReputationFixes.lua`, `itemStartFixes.lua`,
  `AutoTableUpdates.lua` NPC flags, all static expansion fixes, and SoD side channels.
- Cover provider Source and Baked outputs for every supported flavor.
- Record accepted differences explicitly.

### WP-08: pinned Database Integration Check

**Owner:** Questie CI integration

**Tracking:** TDB-12

**Must complete:**

- Replace the Questie `db-validation` matrix with a Database Integration Check pinned to the exact
  provider revision used by the combined branch.
- Keep Questie behavior tests in Questie.
- Prove the check fails for an incompatible contract or provider revision.

### WP-09: baseline replay handover

**Owner:** Questie `implementation` branch

Before handing `baseline` to another agent, record:

- the exact `baseline` commit;
- the exact subtractive baseline and source commits used for the fresh implementation;
- every runtime symbol to reintroduce and every extracted policy symbol already retained on
  `baseline`;
- the eight Questie Policy Correction names, API datatypes, and load orders;
- Login Initialization order;
- changed tests and expected assertions;
- provider work-packet status;
- validation commands and known external failures.

`TDB-RELAND-HANDOVER.md` is the entry point for replay. `TDB-DYNAMIC-CORRECTIONS-HANDOVER.md` is the
detailed behavior source. Its compiler-coexistence instructions are obsolete. `TDB-REFACTOR.md`
contains historical planning and is not sufficient by itself for replaying the work onto a
subtractive baseline.

## Delete whole files and directories

### Raw entity data

Delete all provider-owned raw entity tables:

```text
Database/Classic/
Database/TBC/
Database/Wotlk/
Database/Cata/
Database/MoP/
```

Remove every corresponding entry from:

```text
Questie-Classic.toc
Questie-BCC.toc
Questie-WOTLKC.toc
Questie-Cata.toc
Questie-Mists.toc
```

Known production consumers must be converted or deleted with the raw tables. Refresh line anchors
against the recorded source commit before applying the manifest:

- `Modules/QuestieMenu/Townsfolk.lua` has seven raw NPC, Item, and Game Object access sites. WP-06
  converts them to composed reads.
- `Localization/l10n.lua` writes localized values into raw entity tables. Delete that path.
- `Database/Corrections/QuestieCorrections.lua` derives `requiredRaces` from raw Quest and NPC data.
  WP-03 replaces it.
- `_QuestieDB:HideClassAndRaceQuests()` traverses `questData` and has no production caller. Delete it.
- `Modules/QuestieCleanup.lua` clears the raw tables. Delete it.
- `Database/Corrections/AutoTableUpdates.lua` writes raw NPC flags. Delete it after WP-07 proves the
  provider values.
- Remove the `QuestPointers or questData` fallback in Available Quests.
- Remove any `ItemPointers or itemData` fallback in `QuestieLib` if it remains on the baseline source.

### Compiler and raw cleanup

Delete:

```text
Database/compiler.lua
Database/QuestieDBStorage.lua
Database/QuestieDBStorage.test.lua
Modules/QuestieCleanup.lua
```

`QuestieDBStorage` only selects compiled binary namespaces and invalidates compiler state. Remove its
imports and calls from initialization, database, menu, options, stream, profiler, and CLI mock code.
Remove its entry from all five flavor TOCs.

Delete `Modules/Libs/RamerDouglasPeucker.lua` on `baseline` and remove its five TOC entries. WP-04
blocks merging the combined branch until provider parity is proven. Do not delete `QuestieStream`;
communications and serialization still use it.

### Provider-owned correction sources

Delete the provider-owned correction copies on the baseline. WP-01, WP-03, and WP-04 block
merging the combined branch until their replacement behavior is proven:

```text
Database/Corrections/AutoTableUpdates.lua
Database/Corrections/Automatic/
Database/Corrections/classicQuestFixes.lua
Database/Corrections/classicNPCFixes.lua
Database/Corrections/classicItemFixes.lua
Database/Corrections/classicObjectFixes.lua
Database/Corrections/tbcQuestFixes.lua
Database/Corrections/tbcNPCFixes.lua
Database/Corrections/tbcItemFixes.lua
Database/Corrections/tbcObjectFixes.lua
Database/Corrections/wotlkQuestFixes.lua
Database/Corrections/wotlkNPCFixes.lua
Database/Corrections/wotlkItemFixes.lua
Database/Corrections/wotlkObjectFixes.lua
Database/Corrections/cataQuestFixes.lua
Database/Corrections/cataNPCFixes.lua
Database/Corrections/cataItemFixes.lua
Database/Corrections/cataObjectFixes.lua
Database/Corrections/mopQuestFixes.lua
Database/Corrections/mopNPCFixes.lua
Database/Corrections/mopItemFixes.lua
Database/Corrections/mopObjectFixes.lua
Database/Corrections/sodQuestFixes.lua
Database/Corrections/sodNPCFixes.lua
Database/Corrections/sodItemFixes.lua
Database/Corrections/sodObjectFixes.lua
Database/Corrections/titanReforgedQuestFixes.lua
Database/Corrections/titanReforgedNPCFixes.lua
Database/Corrections/titanReforgedItemFixes.lua
Database/Corrections/titanReforgedObjectFixes.lua
```

The four standalone Titan files are part of current `master` and replace older Titan functions in
WotLK correction files. Keep `Database/Corrections/titanReforgedQuestTags.lua`; it feeds retained
WoW API quest-tag correction behavior.

WP-00 moves the Questie-owned producers before this deletion. The extraction commit must remove the
producer definitions from the mixed files, wire existing callers to the expansion-split
`QuestiePolicy` files, and remain behavior-neutral. The later deletion commit removes the remaining
provider-owned files and TOC entries. The older audited snapshot found the producers at
`classicNPCFixes.lua:3719-3778`, `tbcNPCFixes.lua:2096-2183`, and
`tbcQuestFixes.lua:8819-8830`; refresh these anchors against the recorded source commit.

WP-07 must explicitly cover `Automatic/classicQuestReputationFixes.lua`,
`Automatic/itemStartFixes.lua`, `AutoTableUpdates.lua` NPC flags, SoD base data, and every static
fix file before the combined branch merges.

### Generated entity localization

Delete the expansion entity lookup trees and their XML/loadstring tests on the baseline. WP-01 and
WP-02 block merging the combined branch until provider parity is proven:

```text
Localization/lookups/Classic/lookupItems/
Localization/lookups/Classic/lookupNpcs/
Localization/lookups/Classic/lookupObjects/
Localization/lookups/Classic/lookupQuests/
Localization/lookups/Classic/lookupLoadstrings.test.lua
Localization/lookups/TBC/lookupItems/
Localization/lookups/TBC/lookupNpcs/
Localization/lookups/TBC/lookupObjects/
Localization/lookups/TBC/lookupQuests/
Localization/lookups/TBC/lookupLoadstrings.test.lua
Localization/lookups/Wotlk/lookupItems/
Localization/lookups/Wotlk/lookupNpcs/
Localization/lookups/Wotlk/lookupObjects/
Localization/lookups/Wotlk/lookupQuests/
Localization/lookups/Wotlk/lookupLoadstrings.test.lua
Localization/lookups/Cata/lookupItems/
Localization/lookups/Cata/lookupNpcs/
Localization/lookups/Cata/lookupObjects/
Localization/lookups/Cata/lookupQuests/
Localization/lookups/Cata/lookupLoadstrings.test.lua
Localization/lookups/MoP/lookupItems/
Localization/lookups/MoP/lookupNpcs/
Localization/lookups/MoP/lookupObjects/
Localization/lookups/MoP/lookupQuests/
Localization/lookups/MoP/lookupLoadstrings.test.lua
Localization/lookups/lookupOverrides.lua
Localization/lookups/lookupOverrides.test.lua
```

Remove only the entity lookup TOC entries. Keep Questie-owned Zone/Category Lookups:

```text
Localization/lookups/lookupQuestCategories.lua
Localization/lookups/lookupZones.lua
Localization/lookups/lookupZonesCorrections.lua
```

### Questie-side entity validators

Delete the Questie-side entity validators on the baseline. WP-01 blocks merging the combined branch
until source-data validation runs in the Database Addon:

```text
cli/validate-era.lua
cli/validate-sod.lua
cli/validate-tbc.lua
cli/validate-wotlk.lua
cli/validate-cata.lua
cli/validate-mop.lua
cli/validate-localization.lua
cli/validators.lua
cli/validators.test.lua
```

Remove `cli/output/` if it exists as locally generated output. It is not a tracked source deletion.

Keep unrelated CLI tools and integration tests unless a separate audit proves they depend only on
removed entity validation. In particular, do not delete `cli/integrationTests/6734.test.lua` merely
because it lives under `cli/`. Audit `cli/dump.lua` and `cli/profiler.lua` separately rather than
assuming they die with the raw tables.

Replace the `.github/workflows/ci.yml` `db-validation` matrix with the WP-08 pinned Database
Integration Check. Questie behavior tests remain in Questie.

Keep `build.py`, `Questie.toc`, and `QuestieValidateGameCache`. Audit
`ExternalScripts(DONOTINCLUDEINRELEASE)/` separately; it is outside this runtime deletion packet.

## Reimplement mixed files

`baseline` extracts Questie-owned producers before deleting their mixed provider files. It may still
delete other mixed runtime files wholesale. `implementation` re-adds or reduces those runtime files
in their final form. Do not move the extracted policy data back into provider-owned modules.

### `Modules/QuestieInit.lua`

Delete:

- the `DBCompiler`, `QuestieDBStorage`, and `Cleanup` imports;
- `loadFullDatabase()`;
- compiled-state selection and all compile/recompile paths;
- `QuestieInit:LoadDatabase()`;
- `QuestieInit:LoadBaseDB()`;
- `dbCompiledCount` Townsfolk cache invalidation;
- raw localization initialization;
- raw cleanup calls.

Reimplement Login Initialization in this order:

1. call `l10n.InitializeUILocale()` to resolve Questie's effective UI locale;
2. require Database Addon Contract Version 1 before any locale or Correction work;
3. forward `l10n:GetUILocale()` to `LibQuestieDB.l10n.SetLocale()` outside the UI-string module;
4. build External Locale Override Policy Corrections outside `l10n` against clean composed reads;
5. initialize Questie blacklist and non-Correction policy, register every Questie Policy Correction
   once, and apply owner `"Questie"` once;
6. initialize `QuestieDB` query bindings, ID maps, Objective Order hints, caches, and its lifecycle
   flag;
7. initialize Townsfolk and other database consumers from composed reads;
8. initialize `QuestieEvent` after `QuestieDB` so later setters refresh Questie's bindings;
9. continue later Initialization Stages. Stage 2 rebuilds `QuestieTooltips.objectNameLookup` from
   composed Game Object reads inside the staged coroutine.

### `Database/QuestieDB.lua`

Delete:

- compiler error/recompile popup `QUESTIE_DATABASE_ERROR`;
- any raw `questData`, `npcData`, `itemData`, or `objectData` manipulation;
- `_QuestieDB:HideClassAndRaceQuests()` if no composed-data caller remains;
- compiler decoding, pointer decoding, and raw fallback comments;
- obsolete warning and `QuestieDBStorage` state tied only to recompilation.

Keep:

- direct `LibQuestieDB` query bindings;
- Database Key Enum use;
- `QuestPointers`, `NPCPointers`, `ItemPointers`, and `ObjectPointers` as compatibility names;
- `RefreshAfterCorrectionApply()` and semantic cache invalidation;
- rich Quest, NPC, Item, and Game Object projections;
- availability, player-state, reputation, class, race, and Quest Log behavior;
- Questie-owned tag and WoW API compatibility logic;
- Objective Order consumers bound to `LibQuestieDB.ObjectiveFirst`;
- Special Objective localization at projection time;
- `questTagInfoCorrections.lua`, which corrects WoW API tag results rather than entity records.

### Entity schema files

Delete the current compiler-oriented versions of:

```text
Database/questDB.lua
Database/npcDB.lua
Database/itemDB.lua
Database/objectDB.lua
```

Reintroduce only what Questie consumers need:

- Contract Version guard before metadata access;
- Database Key Enum bindings from `LibQuestieDB.Meta`;
- adapter query orders used by rich projections;
- Questie-owned constants such as quest flags, faction IDs, NPC flags, and Item classes.

Do not reintroduce reversed keys, compiler types, compiler orders, encoders, or decoders.

### `Database/Corrections/QuestieCorrections.lua`

Delete:

- `_LoadCorrections` and Static Correction orchestration;
- expansion correction imports;
- SoD base/entity Correction loading;
- faction and Titan provider calls;
- automatic Item-start mutation;
- derived `requiredRaces` inference after WP-03;
- waypoint optimization and `PreCompile()` after WP-04;
- validator-only parameters and paths.

Reimplement only:

- owner-scoped registrar lifecycle under owner `"Questie"`;
- Questie blacklist construction;
- captured Policy Correction state and focused setters;
- post-apply QuestieDB refresh.

The target registrations are:

| API datatype | Name | Load order | Owner |
| --- | --- | ---: | --- |
| `Npc` | `DarkmoonFaire` | 100 | Questie |
| `Object` | `GatheringNodeDisplayPolicy` | 200 | Questie |
| `Quest` | `ContentPhasePolicy` | 300 | Questie |
| `Item` | `RuntimeItemRepair` | 400 | Questie |
| `Item` | `ExternalLocaleItem` | 500 | Questie |
| `Quest` | `ExternalLocaleQuest` | 501 | Questie |
| `Npc` | `ExternalLocaleNpc` | 502 | Questie |
| `Object` | `ExternalLocaleObject` | 503 | Questie |

Use the API literals exactly as shown. Registration is append-only, so each provider registers once.

### `Localization/l10n.lua`

Delete:

- built-in entity lookup registries;
- `l10n:Initialize()` raw entity writes;
- compiled-locale behavior;
- generated Item, Quest, NPC, and Game Object lookup loading;
- Titan zhCN raw correction handling after WP-02.

Keep:

- UI Translation Entries;
- User Locale Selection, fallback, and aliases;
- Zone/Category Lookups;
- External Locale Override UI strings.

Questie's UI-string module owns no entity behavior. A fresh focused seam outside `l10n` owns provider
locale forwarding, four filtered External Locale Override Policy Corrections, withdrawal-first
entity-locale switching, semantic cache invalidation, and scheduling the tooltip-owned Object-name
index rebuild.

### `Modules/QuestieMenu/Townsfolk.lua`

Replace raw traversal of `QuestieDB.npcData`, `itemData`, and `objectData` with composed ID maps and
query functions. Preserve Townsfolk policy, character filtering, faction handling, and Manual Note
behavior. Rebuild from the Database Addon each Addon Load until a stable provider data revision is
available.

### `Modules/Quest/AvailableQuests/AvailableQuests.lua`

Remove the `QuestieDB.questData` fallback. Iterate `QuestieDB.QuestPointers` only.

### `Modules/Libs/QuestieLib.lua`

Keep asynchronous missing-Item repair, but use the `RuntimeItemRepair` name-only Policy Correction.
Do not infer `npcDrops` or store a Quest ID in an Item relationship field.

### `Database/Corrections/Holidays/QuestieEvent.lua`

Keep Event Quest state, calendars, announcements, faction selection, Anniversary behavior, and Titan
holiday dates. Use the generic Darkmoon Policy Correction setter. Do not write raw NPC data or call a
Darkmoon-specific Database Addon interface.

### Options, menu, stream recovery, settings, and migration

Delete compiler-specific behavior from:

```text
Modules/Options/AdvancedTab/QuestieOptionsAdvanced.lua
Modules/QuestieMenu/QuestieMenu.lua
Modules/QuestieStream.lua
Modules/Profiler/QuestieProfiler.lua
Modules/Profiler/QuestieProfilerPreHook.lua
Modules/Profiler/README.md
Database/QuestieDB.lua
cli/apiMocks.lua
```

This includes:

- Recompile Database options and menu entries;
- `QUESTIE_RECOMPILE_DATABASE_CONFIRM`;
- locale-triggered compiler invalidation;
- profile/reset compiler invalidation;
- compiler corruption recovery and compile warnings;
- profiler hooks, exclusions, timers, tests, and README guidance that depend on `DBCompiler`;
- the CLI API mock's compiler-specific ticker cancellation;
- compiler progress and error strings that have no remaining caller.

Keep `QuestieStream` itself. Audit compiler-only entries in
`Localization/Translations/Options/Advanced.lua` and
`Localization/Translations/DebugMessages.lua`; remove only entries with no surviving caller.

Add a Settings Migration that clears obsolete compiler state and payloads in their existing scopes.
Clear copies under `Questie.db.global`, `Questie.db.global.sod`, and
`Questie.db.global.titanReforged` where present:

```text
dbIsCompiled
dbCompiledOnVersion
dbCompiledLang
dbCompiledExpansion
dbCompiledCount
npcBin
npcPtrs
questBin
questPtrs
objBin
objPtrs
itemBin
itemPtrs
```

Also clear the obsolete `disableDatabaseWarnings` Profile Setting. Audit whether the `sod` and
`titanReforged` default subtables still have non-compiler fields before removing an empty default.
Do not remove unrelated Saved Variables or Settings Profile data.

This three-scope migration requirement supersedes any SoD-only cleanup wording in older handovers.

### TOC manifests

All five flavor TOC manifests must:

- set `## RequiredDeps: QuestieTDB`, replacing an empty dependency declaration if necessary;
- remove raw entity files;
- remove provider-owned correction files while keeping the WP-00 `QuestiePolicy` extraction files;
- remove generated entity localization XML/files;
- remove `Database/compiler.lua`;
- remove `Database/QuestieDBStorage.lua`;
- remove `Modules/QuestieCleanup.lua`;
- remove `Modules/Libs/RamerDouglasPeucker.lua` on the baseline; WP-04 gates the combined merge;
- keep Questie policy, UI localization, Zone/Category Lookups, and semantic modules.

The seven-line fallback `Questie.toc` is unaffected.

## Questie-owned artifacts that must survive

`baseline` extracts the artifacts embedded in provider-owned correction files before deleting those
files. Already separate Questie-owned artifacts stay in place. `implementation` wires or reduces the
runtime modules around them, but it must not reconstruct the extracted data from deleted sources.

| Artifact | Current anchor | Target ownership |
| --- | --- | --- |
| Quest, NPC, and Item blacklists | `Questie*Blacklist.lua`, `HardcoreBlacklist.lua` | Questie policy |
| Blacklist expansion filtering | `BlacklistFilter.lua` | Questie policy |
| SoD display/rune policy | `SeasonOfDiscovery.lua` | Questie policy, stripped of provider-owned entity loading |
| Content Phase state | `Corrections/ContentPhases/` | Questie policy |
| TBC prerequisite tables | `tbcQuestFixes.lua:LoadContentPhaseFixes()` → `QuestiePolicy/tbcPolicyCorrections.lua` | `ContentPhasePolicy` |
| Gathering-node suppression | former `DeleteGatheringNodes`, 24 IDs | `GatheringNodeDisplayPolicy` |
| Era Darkmoon NPC tables | `classicNPCFixes.lua:LoadDarkmoonFixes()` → `QuestiePolicy/classicPolicyCorrections.lua` | Questie holiday policy |
| TBC Darkmoon NPC tables | `tbcNPCFixes.lua:LoadDarkmoonFixes()` → `QuestiePolicy/tbcPolicyCorrections.lua` | Questie holiday policy |
| Event Quest data and schedules | `Corrections/Holidays/` | Questie policy |
| External Locale Override UI strings | `QUESTIE_LOCALES_OVERRIDE.translations` | Questie UI localization |
| External entity locale input | `QUESTIE_LOCALES_OVERRIDE` entity lookups | four Questie Policy Corrections |
| Runtime missing-Item names | `QuestieLib:CacheItemNames()` | `RuntimeItemRepair` |
| Rich entity projections | `QuestieDB.lua` | Questie semantics |
| Semantic caches and ID aliases | `QuestieDB.lua` | Questie compatibility seam |
| Focused Database Addon test seam | fresh `test/QuestieTDBMock.lua` and contract tests | Questie behavior tests |
| Game Object name index | `QuestieTooltips.objectNameLookup` | Questie derived tooltip index |
| Event and announcement visibility | `QuestieEvent.lua` | Questie policy |
| Quest availability checks | `QuestieDB.lua` and Quest modules | Questie player-state policy |
| WoW API quest-tag corrections | `questTagInfoCorrections.lua` | Questie API compatibility |
| UI translations and Zone/Category Lookups | `Localization/Translations/`, shared lookup files | Questie localization |

## Deferred support-data migration

Do not remove these as part of `baseline` unless the separate
support-data packet is explicitly included and QuestieTDB issue #15 is complete:

```text
Database/Zones/
Database/QuestXP/
Database/DropTables/
Database/FactionTemplates/
```

Questie should eventually consume their data through `LibQuestieDB.Support`, while retaining the
Questie modules that interpret that data. Until provider parity is proven, these files are **Keep**
for this delivery.

## Review scale

An older audit against `origin/master` commit `ba0f5ac` estimated this deletion at about 5.04 million
lines:

| Area | Approximate lines |
| --- | ---: |
| Generated entity lookups and lookup tests | 4,323,000 |
| Raw entity data | 502,600 |
| Static and Automatic corrections, including Titan | 210,300 |
| Compiler, lifecycle, UI, CLI, and TOC residue | 5,500 |

These figures are review aids, not acceptance evidence. Recalculate them from the recorded source
commit before opening the baseline merge request.

## Tests to delete or rewrite

Delete tests whose only contract is removed raw data, generated lookup registration, compilation,
encoding, or Questie-side entity validation. This includes `Database/QuestieDBStorage.test.lua`.
Rewrite `Modules/Profiler/QuestieProfiler.test.lua` and
`Modules/Profiler/QuestieProfilerPreHook.test.lua` so they do not preserve compiler hooks or
exclusions. Remove compiler-specific setup from `cli/apiMocks.lua`.

Design `test/QuestieTDBMock.lua`, its contract tests, and the affected correction, database, event,
Item-repair, and localization tests fresh from Contract Version 1 and the required behavior below.
Prior tests may be consulted selectively as behavioral archaeology, but must not preserve compiler
compatibility scaffolding or turn an old approximate test count into an acceptance gate.

Rewrite tests to exercise the final interfaces:

- the expansion-split policy producers extracted by WP-00;
- `QuestieDB` query bindings, ID aliases, projections, and cache refresh;
- Questie Policy Correction registration, composition, withdrawal, raw reads, and provenance;
- Login Initialization order without compiler/cached branches;
- provider locale forwarding and External Locale Override behavior;
- generation-safe Game Object name-index rebuild;
- Darkmoon initial selection and Event Quest policy;
- asynchronous missing-Item repair;
- Townsfolk and Available Quests through composed reads;
- migration cleanup of obsolete compiler Saved Variables;
- pinned Database Addon Contract integration.

Do not add tests that merely preserve the absence of deleted compiler features.

## Final static checks

The combined branch should satisfy:

```bash
rg -n 'DBCompiler|QuestieDBStorage|ApplyParameterized|LoadBaseDB|LoadDatabase\(|dbIsCompiled|dbCompiled(OnVersion|Lang|Expansion|Count)' \
  --glob '!**/*.test.lua' --glob '!Modules/Migration.lua' \
  Database Localization Modules Public cli Questie.lua Questie-*.toc

rg -n 'QuestieDB\.(npcData|questData|objectData|itemData|npcDataOverrides|questDataOverrides|objectDataOverrides|itemDataOverrides)' \
  Database Localization Modules Public

rg -n 'Database\\(Classic|TBC|Wotlk|Cata|MoP)|Database\\compiler.lua|Modules\\QuestieCleanup.lua' \
  Questie-*.toc

rg -n 'Localization\\lookups\\(Classic|TBC|Wotlk|Cata|MoP)|lookupOverrides.lua' \
  Questie-*.toc

rg -n 'LoadFactionFixes|LoadTitanReforgedFixes|LoadFactionQuestFixes|PreCompile|OptimizeWaypoints' \
  Database Localization Modules Public

rg -n 'GetRegistrar\(' --glob '!**/*.test.lua' Database Localization Modules Public

for toc in Questie-{Classic,BCC,WOTLKC,Cata,Mists}.toc; do
  test "$(rg -c '^## RequiredDeps' "$toc")" -eq 1 || exit 1
  rg -qx '## RequiredDeps: QuestieTDB' "$toc" || exit 1
done
```

Expected results:

- compiler, `QuestieDBStorage`, `ApplyParameterized`, raw entity, compiled-state, and provider-owned
  correction searches return no production matches;
- generated entity localization has no TOC entries;
- the only production `GetRegistrar` call is inside `QuestieCorrections`;
- the dependency loop passes for all five flavor TOCs;
- support-data matches may remain only as allowed by the deferred section.

## Final validation

Before the combined baseline merges:

```bash
busted -p ".test.lua" .
luacheck -q -- Database Localization Modules Public Questie.lua
git diff --check
```

Also run:

- the final Database Addon master-data sync from the latest relevant `master` commit;
- WP-07 differential coverage for correction side channels and static fixes;
- the pinned Database Integration Check;
- Database Addon Source and Baked validation for every supported flavor;
- Database Addon locale validation for all supported locales;
- Era, SoD, TBC before and after phase 3, WotLK, Titan Reforged, Cata, and MoP smoke tests;
- one built-in non-English locale;
- one External Locale Override fixture;
- Townsfolk, Available Quests, Objective Order, Special Objective text, gathering-node suppression,
  Darkmoon, and runtime missing-Item checks.

## Manifest completion record

- Master manifest reconciliation: complete
- Source Questie commit: `ba0f5acd63cbeb8e5affc5d1990b0d1ee276cd57`
- Database Addon import commit: not recorded
- Pre-merge Database Addon sync commit: not recorded
- `baseline` branch: `QuestieTDB-remove-baseline`; whole-file deletion tip
  `14bb2681f8a349a0470c8deb1f37c238ea72ae80`; clean mixed-runtime subtraction tip
  `8b63c04beadef59b648cb558247609651e1f19e1`
- `implementation` branch: not created
- Branch history: documentation-only commits `ad1ef9a5261c9cd2f3c05da57fc4dc9fa42a837f`
  and `e2b6d2d2db1cf2786792d9a13553863d62f3526d` precede WP-00; WP-00 is the first
  code-changing baseline commit
- WP-00 policy extraction: done; extraction commit
  `a85d6c5a2ad1e77f431907ef70d4163f623c1bd1` was freshly reviewed and independently validated
  locally
  - `QuestieNPCFixes:LoadDarkmoonFixes()` moved from
    `Database/Corrections/classicNPCFixes.lua` to
    `QuestieClassicPolicyCorrections:LoadDarkmoonFixes()` in
    `Database/Corrections/QuestiePolicy/classicPolicyCorrections.lua`
  - `QuestieTBCNpcFixes:LoadDarkmoonFixes()` moved from
    `Database/Corrections/tbcNPCFixes.lua` to
    `QuestieTBCPolicyCorrections:LoadDarkmoonFixes()` in
    `Database/Corrections/QuestiePolicy/tbcPolicyCorrections.lua`
  - `QuestieTBCQuestFixes:LoadContentPhaseFixes()` moved from
    `Database/Corrections/tbcQuestFixes.lua` to
    `QuestieTBCPolicyCorrections:LoadContentPhaseFixes()` in
    `Database/Corrections/QuestiePolicy/tbcPolicyCorrections.lua`
  - Temporary complete-table extraction parity: `busted /tmp/wp00-extraction-parity.test.lua`
    passed with 2 successes and 0 failures for all Classic/TBC Darkmoon inputs and TBC Content
    Phases 2, 3, and 4; the temporary test was removed
  - Focused tests: Classic policy 2 successes, TBC policy 8 successes, and QuestieEvent 29
    successes, all with 0 failures
  - Full local validation: 1,768 Busted successes with 0 failures; luacheck passed with 0 warnings
    or errors across 366 files; `git diff --check` passed
  - Fresh extraction review: three independent reviewers found no actionable issues
  - Normal CI: push-triggered run
    [33496726477](https://github.com/Questie/Questie/actions/runs/33496726477) passed for the exact
    extraction SHA, including unit tests, luacheck, and all `db-validation` matrix jobs. The
    separate pull-request run was skipped because the merge request was draft
- WP-01 master-data import: not started
- WP-02 lookup/Titan zhCN: blocked on QuestieTDB issue #14
- WP-03 `requiredRaces`: blocked on QuestieTDB issue #13
- WP-04 Objective Order/waypoint parity: verification required
- WP-05 Contract/flavor gates: implementation exists on the Database Addon `ownership` branch; final integration verification required
- WP-06 composed-read consumers: done on the clean baseline; Townsfolk and Available Quests use
  composed ID maps and queries, raw fallbacks are gone, and runtime Item repair is recorded as an
  open Policy Correction seam in `TDB-IMPLEMENTATION-ISSUES.md`
- WP-07 provider differential coverage: blocked on QuestieTDB issue #19
- WP-08 pinned Database Integration Check: in progress; the old `db-validation` matrix was removed
  in `ab8a78f2f127136b1b09e059fd6cc81ecc187203` while loader-usage validation remains in the unit-test
  job; the pinned provider integration check is not implemented
- WP-09 baseline replay handover: complete in the commit containing this completion record and the
  matching evidence in `TDB-RELAND-HANDOVER.md`; `implementation` must branch from that commit and
  start fresh from the subtractive baseline and authoritative behavior contracts
- Subtractive deletion evidence:
  - WP-00 evidence record: `09e0178e79775782cdabd75f506dccd6e8ec0698`
  - Raw provider entity data: `99493b08a5b35aabf7e4ca93d438bf58baf3c08a`
  - Provider-owned correction sources: `64bd822b9c998e8cfc00262b7635d65cafd5c930`
  - Generated entity localization: `d3d08d244e341ebe68b7d7fabd4f50de13fc37a1`
  - Legacy compiler and compiler schemas: `c7454f1f79459de72586953870ff9f4447d048ab`
  - Questie-side entity validation: `ab8a78f2f127136b1b09e059fd6cc81ecc187203`
  - Orphaned CLI database mocks: `14bb2681f8a349a0470c8deb1f37c238ea72ae80`
  - Deletion commits `99493b08` through `14bb2681f`, measured by the exclusive diff
    `09e0178e..14bb2681f`, delete 281 tracked files and 5,042,232 deleted-file lines; the overall
    diff changes 292 files with 25 insertions and 5,042,474 deletions
  - All five flavor TOCs require QuestieTDB. The Classic policy file remains in all five TOCs; the
    TBC policy file remains in the four TBC-and-later TOCs and is absent from Classic
  - QuestiePolicy, `titanReforgedQuestTags.lua`, blacklists, Event Quest data, Content Phase state,
    UI localization, Zone/Category lookups, QuestieStream, and deferred support data remain intact
  - Objective Order was not extracted back into Questie; ownership remains with
    `LibQuestieDB.ObjectiveFirst`
  - Ignored generated `cli/output/` was removed locally
- Clean mixed-runtime subtraction evidence:
  - `0b02060ca5ab4a853651bf55bfe3a3b73e00f266` — legacy entity localization removed while retaining
    UI strings and Object-hover tooltip behavior
  - `e1d1f37ed7e30c1e199c7d48d7cea7d6470f9028` — corrections reduced to Questie blacklist policy and
    durable Dynamic Correction ordering
  - `d06049d10991ecc54c2392fd457e9241a058002b` — compiler lifecycle removed from QuestieDB and Login
    Initialization
  - `3e6d66ca2f98e37219aa545279df2cae1dbd5b80` — compiler controls, recovery, profiler residue, and
    translations removed
  - `2c57c667af6f3ccc148f98ac39846f164cd0b9c9` — raw entity consumers removed or converted to composed
    reads
  - `e583ace460e593a0fe3a8c4b4c03156508df909e` — obsolete compiler SavedVariables migration added
  - `2f5fca8b616528214ff555153167ac8ea2f23ed1` — Questie-owned semantic constants retained
  - `653ec82ec60cbe59f4117b223e155ab6b2ea834d` — stale compiler terminology removed
  - `8b63c04beadef59b648cb558247609651e1f19e1` — focused Contract metadata test fixture added
  - The follow-up changes 47 files with 814 insertions and 1,350 deletions. Full Busted passes with
    1,424 successes; luacheck passes with 0 warnings or errors across 322 files; loader-usage and
    `git diff --check` pass
  - Production retirement searches find no compiler/storage, raw entity/override, provider-fix,
    precompile/waypoint, generated entity localization, or deleted-module references
  - `TDB-IMPLEMENTATION-ISSUES.md` records the Object tooltip index, runtime Item repair, and minimal
    provider schema/test seams that remain for fresh implementation
- Expected baseline state: structurally clean and locally green, but not runtime-complete. Contract
  enforcement, provider query bindings, owner-scoped Policy Corrections, provider/external locale
  application, and the pinned integration check remain fresh implementation work
- Historical evidence status: `origin/QuestieTDB` at
  `bc9ad9bfa6ddd06e75933fd3f37b7dbeba32bdf5` contains committed TDB-01/TDB-02 evidence only. The
  sibling `../Questie-tdb-claude` workspace contains prior dirty and untracked Dynamic Corrections
  work, but it is optional behavioral archaeology rather than a prerequisite or implementation
  source. Do not merge, cherry-pick, or mechanically port it. Build production code and tests fresh
  from Contract Version 1, the retained QuestiePolicy producers, the current baseline, and the
  authoritative handovers
- Commit status: the commit containing this completion record finalizes the subtractive baseline
  and is the exact branch point for `implementation`. Provider work packets and every combined-merge
  gate remain unchanged
