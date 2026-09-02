# QuestieTDB refactor

## Purpose

Replace Questie's runtime database compiler with QuestieTDB as the only entity database implementation.

Questie keeps its `QuestieDB` module as the interface used by the rest of the addon. `QuestieDB` will read from `LibQuestieDB` while retaining Questie-owned semantic helpers, player-state logic, blacklists, and rich entity projections.

This document is the source of truth for the work packet. Update it whenever an agent starts or finishes a work item, changes a decision, discovers a risk, or runs validation.

## Current status

- QuestieTDB library reconnaissance: complete
- Questie compiler and consumer mapping: complete
- Historical evidence: committed TDB-01/TDB-02 work is available at
  `bc9ad9bfa6ddd06e75933fd3f37b7dbeba32bdf5`; dirty and untracked Dynamic Corrections work in
  sibling workspace `../Questie-tdb-claude` is optional behavioral archaeology, not an
  implementation source or prerequisite
- Subtractive baseline: whole-file deletion ends at
  `14bb2681f8a349a0470c8deb1f37c238ea72ae80` and reviewed clean-baseline code ends at
  `cf4349e9f647f3c1b077421863fc53ef6031da44`; the commit containing the finalized baseline replay
  evidence completes WP-09 and is the exact branch point for `implementation`. The local suite is
  green, while runtime Contract/query/Correction integration remains fresh implementation work
- Fresh implementation: branch `QuestieTDB-implementation`, created from the baseline handoff commit
  `ad8e6ec19979f42eeecc1e3262575014fa8c3fe8`, lands the Contract Version 1 test double, the
  provider-backed schema adapters and `QuestieDB` bindings, the owner-scoped Questie Policy
  Corrections, compiler-free Login Initialization, the entity locale seam, the Darkmoon and
  runtime-Item policy callers, the Object-hover registration/provider index split, and composed-read
  consumer verification. Full Busted passes with 1,530 successes; production luacheck is clean across
  329 files; loader-usage and diff checks pass; retirement greps are empty
- Distribution and release packaging: deferred

The next implementation packet starts fresh from the recorded subtractive baseline, Contract
Version 1, retained QuestiePolicy producers, and the authoritative handovers. Historical code and
tests may clarify behavior, but must not anchor architecture or restore compatibility scaffolding.

## QuestieTDB prerequisites

Provider work is tracked only in the QuestieTDB repository:

- [QuestieTDB #14](https://github.com/Questie/QuestieTDB/issues/14): import lookup overrides and Titan zhCN corrections
- [QuestieTDB #15](https://github.com/Questie/QuestieTDB/issues/15): synchronize support data, fix Source-mode flavor selection, and add drift validation
- [QuestieTDB #16](https://github.com/Questie/QuestieTDB/issues/16): restrict Titan corrections to the Wrath client
- [QuestieTDB #17](https://github.com/Questie/QuestieTDB/issues/17): keep `ObjectiveFirst` flavor-scoped in Source mode
- [QuestieTDB #18](https://github.com/Questie/QuestieTDB/issues/18): document and test Darkmoon parameterized arguments
- [QuestieTDB #19](https://github.com/Questie/QuestieTDB/issues/19): cover correction side channels and SoD in differential tests

A separate QuestieTDB agent is already handling the correction compatibility global that collides with Questie's `Questie` global. Do not create a duplicate issue for it.

## Firm decisions

1. QuestieTDB will be the only runtime entity database implementation.
2. There will be no compiler fallback, feature flag, or permanent dual-backend mode.
3. Existing addon code should continue to call `QuestieDB` wherever practical.
4. `QuestieDB` will bind directly to `LibQuestieDB`. Do not add another pass-through module.
5. Do not reconstruct full `questData`, `npcData`, `itemData`, or `objectData` compatibility tables.
6. QuestieTDB Contract Version 1 is the required interface.
7. Questie consumes QuestieTDB's `requiredRaces` output rather than reimplementing it; WP-03 must prove that output before the combined merge.
8. Treat regenerated QuestieTDB TOCs as current.
9. Distribution, bundling, and release automation will be handled after the runtime cutover.
10. Old compiler files may remain briefly while a buildable cutover is assembled, but they must not remain loaded or executable in the finished refactor.

## Ownership split

### QuestieTDB owns

- Quest, NPC, Item, and Game Object entity data
- Database Key Enums and schema metadata
- Entity ID indexes
- Static data corrections
- Derived waypoint data
- Entity localization overlays
- Entity read caching and invalidation
- Flavor and season-specific entity selection
- Base support datasets exposed through `LibQuestieDB.Support`

### Questie owns

- The `QuestieDB` interface used by Questie callers
- Rich Quest, NPC, Item, and Object projections
- Quest availability and prerequisite policy
- Player, group, reputation, class, race, and Quest Log state
- Blacklists and display policy
- Quest tags and WoW API compatibility logic
- Event and content-phase policy
- UI localization
- Zone, XP, and drop-rate behavior built around support data
- Questie-specific semantic caches

### Temporary Questie ownership

These must remain available during the cutover, then receive an explicit final owner:

- External Locale Override entity lookups, which QuestieTDB does not currently accept through a public provider interface
- Asynchronous missing-Item repair, pending verification of its intended data shape

QuestieTDB owns the Objective Order Correction tables through `LibQuestieDB.ObjectiveFirst`.
Titan Reforged zhCN entity localization belongs in QuestieTDB and is tracked by
[QuestieTDB #14](https://github.com/Questie/QuestieTDB/issues/14).

## Target initialization order

1. WoW loads QuestieTDB before Questie.
2. Questie initializes its UI locale.
3. Questie calls `LibQuestieDB.RequireContract(1)`.
4. Questie forwards the effective entity locale to `LibQuestieDB.l10n.SetLocale`.
5. Questie registers its Dynamic Corrections under owner `"Questie"`.
6. Questie applies the `"Questie"` correction owner.
7. `QuestieDB:Initialize()` binds query functions, Database Key Enums, ID maps, and semantic caches.
8. Townsfolk and other database consumers initialize.
9. The remaining Questie startup stages continue without compilation or raw-data cleanup.

No entity reads may happen before locale and Questie Policy Corrections have been applied.

The four schema files also guard Contract Version 1 during Addon Load before reading `LibQuestieDB.Meta`. `QuestieDB:Initialize()` validates it again at Login Initialization before binding entity readers.

## `QuestieDB` compatibility mapping

| Existing Questie symbol | QuestieTDB source | Notes |
| --- | --- | --- |
| `QueryQuestSingle` | `LibQuestieDB.Quest.Get` | Preserve dot-call behavior. |
| `QueryNPCSingle` | `LibQuestieDB.Npc.Get` | Preserve dot-call behavior. |
| `QueryItemSingle` | `LibQuestieDB.Item.Get` | Preserve dot-call behavior. |
| `QueryObjectSingle` | `LibQuestieDB.Object.Get` | Preserve dot-call behavior. |
| `QueryQuest` | `LibQuestieDB.Quest.GetAll` | Result includes `n`; current callers use positional fields. |
| `QueryNPC` | `LibQuestieDB.Npc.GetAll` | Same packed-table rule. |
| `QueryItem` | `LibQuestieDB.Item.GetAll` | Same packed-table rule. |
| `QueryObject` | `LibQuestieDB.Object.GetAll` | Same packed-table rule. |
| `QuestPointers` | `LibQuestieDB.Quest.GetAllIds(true)` | Shared and read-only. |
| `NPCPointers` | `LibQuestieDB.Npc.GetAllIds(true)` | Shared and read-only. |
| `ItemPointers` | `LibQuestieDB.Item.GetAllIds(true)` | Shared and read-only. |
| `ObjectPointers` | `LibQuestieDB.Object.GetAllIds(true)` | Shared and read-only. |
| `questKeys` | `LibQuestieDB.Meta.QuestMeta.questKeys` | QuestieTDB owns the enum. |
| `npcKeys` | `LibQuestieDB.Meta.NpcMeta.npcKeys` | QuestieTDB owns the enum. |
| `itemKeys` | `LibQuestieDB.Meta.ItemMeta.itemKeys` | QuestieTDB owns the enum. |
| `objectKeys` | `LibQuestieDB.Meta.ObjectMeta.objectKeys` | QuestieTDB owns the enum. |
| Objective Order Correction tables | `LibQuestieDB.ObjectiveFirst` | Five consumer-must-not-mutate ID sets. |

QuestieTDB returns fresh mutable copies for table-valued entity fields. `GetAllIds` is the exception: its list and map are shared read-only structures.

## Work tracker

States: `not started`, `in progress`, `blocked`, `review`, `done`.

Before editing, an agent must claim an item and list the files it owns. Agents must not edit the same files concurrently.

| ID | Work item | State | Owner | Depends on | Evidence or notes |
| --- | --- | --- | --- | --- | --- |
| TDB-01 | Add focused QuestieTDB test fake and contract tests | done | QuestieTDB-implementation | - | `test/QuestieTDBMock.lua` is a fresh Contract Version 1 double built on the meta fixture's key enums. `test/QuestieTDBMock.test.lua` (29 tests) covers the Contract range, composed and packed reads, shared ID maps that swap identity on apply, registrar rebuild/withdrawal/`{}` clearing, correction-added IDs, provenance, owner precedence, locale recording, and the Name index. |
| TDB-02 | Bind `QuestieDB` queries, keys, ID maps, Objective Order Corrections, and caches to `LibQuestieDB` | done | QuestieTDB-implementation | TDB-01, QuestieTDB #17 | `Database/{quest,npc,item,object}DB.lua` gate Contract 1 at Addon Load and bind the key enums plus schema-ordered query orders. `QuestieDB.Initialize` binds the eight queries, four ID maps, and five ObjectiveFirst tables, clears the semantic caches, and sets `IsInitialized`; `RefreshAfterCorrectionApply` rebinds the maps and clears the NPC, Item, Object, zone, and creature-level caches while keeping quest objects, because the quest lifecycle updates the object `GetQuest` returned in place. `Database/QuestieDB.test.lua` has 45 tests. Source/Baked ObjectiveFirst parity stays with QuestieTDB #17. |
| TDB-03 | Replace compiler-driven Login Initialization with the target startup order | done | QuestieTDB-implementation | TDB-02, TDB-04, TDB-05, QuestieTDB #16 | Stage 1: UI locale, Contract gate, provider locale forwarding, clean external locale rows, blacklists, register and apply owner `Questie` once, `QuestieDB.Initialize`, Townsfolk rebuild on every login, `QuestieEvent.Initialize`, Tutorial. Stage 2 warms `BuildNameIndex` only when `enableTooltipsObjectID`; Stage 3 restores `Townsfolk.PostBoot` and the Available Quests draw. `Modules/QuestieInit.test.lua` pins the order, the Contract gate, and the conditional warm-up. |
| TDB-04 | Convert Questie-owned policy to Dynamic Corrections | done | QuestieTDB-implementation | TDB-01 | `QuestieCorrections` registers the eight Policy Corrections once under owner `Questie` and applies through one path with the `IsInitialized`-guarded refresh; setters cover Darkmoon, runtime Item repair, and withdrawal-first external locale rows. 25 tests cover registration, apply lifecycle, the 24 gathering nodes, Content Phase (Era gate, phase 2, phase 3 reapply), Darkmoon replacement and withdrawal, Item repair, and external locale withdrawal. |
| TDB-05 | Forward entity locale to QuestieTDB and remove raw entity localization writes | done | QuestieTDB-implementation | TDB-01, TDB-02, QuestieTDB #14 | `Localization/EntityLocale.lua` forwards the effective locale to `LibQuestieDB.l10n.SetLocale` and builds existence-filtered external locale rows; `l10n` stays UI-only. Effective locale changes reload the UI, so Login Initialization is the only production path; an in-session switch composes `ForwardProviderLocale` with `QuestieCorrections.SetExternalLocaleCorrections`. Built-in lookup deletion remains gated on QuestieTDB #14. |
| TDB-06 | Adapt raw entity-table consumers | done | QuestieTDB-implementation | TDB-02 | Townsfolk and Available Quests are verified against the Contract adapter: flag categories with the sub-name and [DND] policy, curated trainer and class lists filtered by presence, hand-maintained per-flavor additions, faction and character selection, mailbox factions, pet food grouping, vendor filtering, and non-empty enumeration through `QuestPointers`. Townsfolk rebuilds on every login. Live provider smoke remains a combined-merge gate. |
| TDB-07 | Convert Darkmoon and asynchronous Item updates | done | QuestieTDB-implementation | TDB-02, TDB-04 | `QuestieEvent` publishes the Classic or TBC producer table through `SetDarkmoonNpcCorrections` once per load and withdraws with `{}` when no faire is active. `QuestieLib.RepairMissingItemNames` requests only objective Items absent from `ItemPointers` and repairs name-only through `RepairMissingItem`; `QuestEventHandler` calls it on accept and for the login quest log. |
| TDB-08 | Remove compiler controls, state, popups, and SavedVariables payloads | done | clean baseline | TDB-03 | Compiler lifecycle, controls, recovery, profiler residue, translations, defaults, and storage references are removed; Migration 38 clears all former payload scopes and warning state. |
| TDB-09 | Remove compiler and raw entity files from runtime TOCs | done | baseline deletion | WP-00 | All five TOCs require QuestieTDB and no longer load provider raw data, provider corrections, generated entity localization, compiler/storage/schema/cleanup files, or Questie-side entity validators. The retained QuestiePolicy matrix is 5 Classic / 4 TBC; Objective Order remains provider-owned through `LibQuestieDB.ObjectiveFirst`. Evidence starts at `99493b08a5b35aabf7e4ca93d438bf58baf3c08a`. |
| TDB-10 | Delete dead compiler, raw data, generated lookups, and validators | done | baseline deletion | TDB-09 | Whole-file subtraction ends at `14bb2681f8a349a0470c8deb1f37c238ea72ae80`: 281 tracked files and 5,042,232 deleted-file lines. Reviewed clean-baseline code ends at `cf4349e9f647f3c1b077421863fc53ef6031da44`; full runtime validation still gates the combined merge after `implementation`. |
| TDB-11 | Read Zone, XP, Drop, and faction-template data from `Support` | not started | - | TDB-02, QuestieTDB #15 | Keep Questie's behavior wrappers. Do not switch to known-stale support copies. |
| TDB-12 | Replace database validation CI with a pinned integration check | blocked | QuestieTDB-implementation | TDB-10, TDB-11, QuestieTDB #19 | Loader-usage validation stays in the unit-test job. The provider repository documents no consumer-side integration command and pins Questie through its own `QUESTIE_COMMIT`; the pinned Database Integration Check waits for the final provider revision and command. |
| TDB-13 | Bundle QuestieTDB and update release packaging | deferred | - | Runtime cutover | The hard TOC dependency is already declared. Bundling and release automation remain separate distribution work. |
| TDB-14 | Expose QuestieTDB source-mode status in Questie diagnostics | not started | - | TDB-02 | Do after the main cutover works. |


### Claims

No implementation session currently owns files. `QuestieTDB-implementation` released its claims when
the rows above reached `done` or `blocked`.

## Work item details

### TDB-01: test interface

Add a focused QuestieTDB fake for Questie tests. TDB-01 provides the interface consumed by the database seam:

- `RequireContract`
- Entity `Get`, `GetAll`, `GetAllIds`, and `Exists`
- `Meta`
- `ObjectiveFirst`

Later packets extend the same fake with correction, locale, and support methods only when Questie consumes them. Do not copy QuestieTDB caching, encoding, correction composition, or localization implementation into the fake.

Required tests:

- incompatible Contract Version fails clearly during Addon Load and initialization
- single and multi-field query binding, including packed nil slots
- Database Key Enum binding
- Objective Order Correction binding
- stable provider-owned ID map binding
- semantic cache reset during initialization
- fresh table values from the focused test fake

Primary files:

- `setupTests.lua`
- new focused test helper
- `Database/QuestieDB.test.lua`

### TDB-02: `QuestieDB` cutover

In `Database/QuestieDB.lua`:

- remove the `DBCompiler` import
- remove binary and pointer decoding
- leave legacy raw override tables in place until TDB-07 converts their remaining writers; QuestieTDB queries do not consult them
- bind the compatibility symbols listed above
- bind all five consumer-must-not-mutate tables from `LibQuestieDB.ObjectiveFirst`
- localize non-nil `extraObjectives[3]` values while constructing Questie's rich Special Objective projection
- preserve nil Special Objective descriptions and custom-spawn names for downstream fallback behavior
- test translated descriptions, spawn names, nil values, and English fallback; TDB-05 owns locale-driven semantic-cache invalidation
- retain rich projections and Questie policy helpers
- let TDB-07 add pointer refresh when runtime corrections can add entities
- reset semantic caches after binding the Database Addon; TDB-05 and TDB-07 will add invalidation at their locale and runtime-correction call sites
- leave raw-data policy helpers such as `DeleteGatheringNodes` until TDB-04 converts their behavior

Compiler schema metadata remains temporarily because Login Initialization still invokes the compiler. TDB-03 and TDB-10 remove it after the hard cutover.

The caller interface is the test seam. Avoid edits across ordinary Questie callers unless they directly consume raw tables.

Related schema files:

- `Database/questDB.lua`
- `Database/npcDB.lua`
- `Database/itemDB.lua`
- `Database/objectDB.lua`

Source Database Key Enums from `LibQuestieDB.Meta`. Keep Questie-owned constants that are not entity schema.

Implementation evidence for TDB-01 and TDB-02:

- Production: `.luacheckrc`, `Database/QuestieDB.lua`, `Database/questDB.lua`, `Database/npcDB.lua`, `Database/itemDB.lua`, `Database/objectDB.lua`
- Tests: `test/QuestieTDBMock.lua`, `setupTests.lua`, `Database/QuestieDB.test.lua`
- Planning: `TDB-REFACTOR.md`
- Red review-fix run: 41 passed, 6 failed, and 2 errored on the intended cold Contract, stable ID map, creature-level cache, Objective Order setup, and nil Special Objective behaviors
- `busted Database/QuestieDB.test.lua`: 50 passed
- affected semantic command covering QuestieDB, localization, Available Quests, and Townsfolk: 122 passed
- `busted -p ".test.lua" .`: 1,451 passed
- `luacheck -q -- Database Localization Modules Public Questie.lua`: no warnings or errors in 347 files
- `git diff --check`: passed
- two fresh final reviewers found no remaining concrete issues
- independent validator verdict: pass

### TDB-03: startup cutover

In `Modules/QuestieInit.lua`:

- remove the compiler decision and compilation path
- remove compiled version, locale, expansion, and count checks
- remove `LoadDatabase`, `LoadBaseDB`, and raw-data cleanup
- implement the target initialization order
- rebuild Townsfolk every Addon Load until QuestieTDB exposes a stable data revision

Retain the staged startup and `ThreadLib` where later Questie initialization still benefits from yielding.

### TDB-04: Questie Dynamic Corrections

Questie registers corrections under owner `"Questie"`.

Required policy:

- clear `spawns` for the 24 gathering-node Object IDs using `{}`
- retain TBC content-phase prerequisite policy for quests `10944` and `11007`
- retain Questie blacklists and hidden-quest policy
- preserve any locale or client-state correction still owned by Questie

Remove from Questie correction orchestration:

- raw correction merging
- static entity fact loading already owned by QuestieTDB
- automatic `requiredRaces` inference
- waypoint optimization
- precompile passes

Do not register tables through a new abstraction. Use the QuestieTDB registrar directly inside Questie's correction owner.

### TDB-05: localization

In `Localization/l10n.lua`, keep only UI translations, zone names, categories, and UI locale
selection. A fresh focused entity-locale seam outside `l10n` must:

- forward the effective locale to `LibQuestieDB.l10n.SetLocale`
- apply withdrawal-first external entity locale Policy Corrections
- clear locale-derived Questie caches when the entity locale changes

Object-hover lookup follows QuestieTDB ADR 0008 and `QUESTIE-OBJECT-NAME-INDEX.md`:

- index registered `o_` tooltip keys incrementally in `QuestieTooltips.objectIdsByName`
- use `LibQuestieDB.Object.IdsByName(name)` for the optional Object-ID line
- warm `BuildNameIndex()` during initialization only when that option is enabled and when toggled on
- never build or rebuild a full Object-name index inside Questie

QuestieTDB stores `extraObjectives[3]` as the enUS localization key and does not translate that
structured field. TDB-02 owns the `QuestieDB.lua` projection change; this item owns locale selection
and cache lifecycle.

Open decision: external locale addons can currently provide entity lookups. QuestieTDB exposes fixed locale overlays but no public provider-registration interface. Do not silently drop this behavior.

### TDB-06: raw consumers

The clean baseline converts Townsfolk and Available Quests to composed ID maps and queries, removes
raw pointer fallbacks, removes the invalid missing-Item raw writer, and strips entity behavior from
`l10n`. Fresh implementation must bind the composed query interface and restore RuntimeItemRepair;
do not build full compatibility copies. Townsfolk's local faction-template data may remain until
TDB-11.

### TDB-07: runtime updates

Historical Dynamic Corrections work demonstrated the behavior below, but the clean baseline removes
its executable placement. Implement it fresh from `TDB-DYNAMIC-CORRECTIONS-HANDOVER.md` and
`TDB-IMPLEMENTATION-ISSUES.md`. `ApplyParameterized` does not exist and must not be reintroduced.

Required Darkmoon correction behavior:

- `QuestieEvent` keeps location selection and calls the existing Era/TBC `LoadDarkmoonFixes`
  table producers, then hands the result to `QuestieCorrections.SetDarkmoonNpcCorrections()`
  exactly once per load, outside the Event Quest loop
- an inactive location withdraws through the same setter with an empty captured table
- the shared apply path refreshes Questie's ID maps and semantic caches when
  `QuestieDB.IsInitialized`

Required asynchronous Item behavior:

- the old `{questId}`-in-`npcDrops` write was verified invalid and dropped; the repair is a
  name-only Item Correction through `QuestieCorrections.RepairMissingItem(itemId, itemName)`
- repairs accumulate, duplicate callbacks are idempotent, nil names are ignored
- each post-initialization apply rebinds `ItemPointers` so a correction-added Item becomes
  visible

QuestieTDB cache invalidation does not clear Questie's rich projection caches;
`QuestieDB.RefreshAfterCorrectionApply()` owns that.

### TDB-08: remove compiler state

Delete or simplify:

- recompile menu and advanced option
- compiler error and corruption popups
- compile progress translations
- locale-triggered compiler invalidation
- profile-reset compiler invalidation
- compiler-specific `QuestieStream` recovery behavior

Add a migration that clears obsolete global and SoD fields:

- `dbIsCompiled`
- `dbCompiledOnVersion`
- `dbCompiledLang`
- `dbCompiledExpansion`
- `dbCompiledCount`
- all `npc`, `quest`, `obj`, and `item` binary and pointer payloads
- obsolete database-warning state

Do not delete `QuestieStream`; serialization and communications still use it.

### TDB-09 and TDB-10: runtime removal and deletion

Before bulk removal, make the green WP-00 extraction commit on `baseline`:

- move the Classic Darkmoon producer into the expansion-split Questie policy file;
- move the TBC Darkmoon and Content Phase producers into the TBC Questie policy file;
- update callers and TOCs without changing behavior;
- record source-file and source-commit provenance in the extracted files.

Then remove from every flavor TOC:

- raw expansion entity files
- provider-owned correction files, while retaining the WP-00 policy files
- `Database\compiler.lua`
- `Modules\QuestieCleanup.lua`
- generated Item, NPC, Object, and Quest lookup files

Do not extract Objective Order tables back into Questie. Keep consumers bound to
`LibQuestieDB.ObjectiveFirst` and require provider parity before final merge.

In the subsequent `baseline` commits, physically delete:

- the compiler
- raw entity files
- obsolete schema compiler metadata
- entity localization lookups
- raw-data cleanup
- legacy Questie-side database validators
- waypoint optimization code no longer used by Questie

### TDB-11: support data

Consume support data through `LibQuestieDB.Support.Get` after
[QuestieTDB #15](https://github.com/Questie/QuestieTDB/issues/15) synchronizes the provider copies
and proves flavor-correct Source/Baked support selection:

- `ZoneDB`
- `QuestXP`
- `DropDB`
- `QuestieItemDropCorrections`
- `QuestieDB.factionTemplate`

Keep the Questie modules that interpret these datasets. QuestieTDB owns the data, not Questie's gameplay and UI behavior.

## Known risks and open decisions

### Must be resolved during cutover

- Objective Order Corrections must bind to `LibQuestieDB.ObjectiveFirst`; Source/Baked flavor parity is tracked by QuestieTDB #17.
- Special Objective descriptions need Questie localization at render time.
- Questie semantic caches can outlive QuestieTDB correction or locale invalidation.
- Asynchronous Item creation currently mutates raw override tables.
- Darkmoon fixes currently mutate NPC overrides after initialization.
- Townsfolk has no QuestieTDB data revision to use for persistent cache invalidation.
- TBC content-phase prerequisites are Questie policy and must not disappear with static corrections.

### Open product or interface decisions

- Whether external locale addons continue to provide entity translations
- Final ownership of Titan Reforged zhCN entity overrides
- Whether coordinate normalization differences require caller changes or explicit acceptance

### Does not block starting the fresh implementation

- WP-03 `requiredRaces` work may proceed in parallel, but QuestieTDB issue #13 remains a combined-merge blocker and must provide matching data before final integration.
- Distribution and generated TOC freshness are handled separately from starting the runtime implementation.

## Validation gates

Run targeted tests while editing, then the full suite.

```bash
busted Database/QuestieDB.test.lua
busted Database/Corrections/QuestieCorrections.test.lua
busted Database/Corrections/Holidays/QuestieEvent.test.lua
busted Localization/l10n.test.lua
busted Modules/QuestieMenu/Townsfolk.test.lua
busted Modules/Quest/AvailableQuests/AvailableQuests.test.lua
busted Modules/Migration.test.lua

luacheck -q -- Database Localization Modules Public Questie.lua
busted -p ".test.lua" .
```

Static stale-reference checks:

```bash
rg -n 'DBCompiler|dbIsCompiled|dbCompiled(OnVersion|Lang|Expansion|Count)' \
  Database Localization Modules Public Questie.lua Questie-*.toc

rg -n 'QuestieDB\.(npcData|questData|objectData|itemData|npcDataOverrides|questDataOverrides|objectDataOverrides|itemDataOverrides)' \
  Database Localization Modules Public

rg -n 'Database\\(Classic|TBC|Wotlk|Cata|MoP)|Database\\compiler.lua|Modules\\QuestieCleanup.lua' \
  Questie-*.toc
```

Before declaring the runtime cutover complete:

1. Targeted tests pass.
2. Full Busted suite passes.
3. Luacheck passes.
4. Runtime TOCs load no compiler or raw entity data.
5. No production code reads raw entity or override tables.
6. Questie reaches its ready state without compilation messages.
7. A live smoke test confirms representative entity reads, gathering-node suppression, localization, Objective Order Corrections, Special Objective text, Townsfolk, TBC phase prerequisites, Titan gating, and Darkmoon behavior.

## Agent coordination

### Before work

1. Read this file and all applicable `AGENTS.md` files.
2. Check `git status`.
3. Claim one work item in the tracker.
4. Add the agent or session name and the exact files it owns.
5. Confirm no other in-progress item owns those files.

Central files should have one owner at a time:

- `Database/QuestieDB.lua`
- `Database/Corrections/QuestieCorrections.lua`
- `Modules/QuestieInit.lua`
- `Localization/l10n.lua`
- `setupTests.lua`
- flavor TOCs
- this document

### After work

Update the tracker with:

- final state
- changed files
- tests and commands run
- exact results
- deferred problems or follow-up work
- any decision that changed

Do not mark an item `done` without command output or a precise manual observation. Use `blocked` when another work item or interface decision prevents completion.

### Reviews

Use a fresh reviewer for changes involving:

- Login Initialization or load order
- corrections and cache invalidation
- SavedVariables migration
- deletion of compiler or raw data
- TOC changes
- public or external locale behavior

## Evidence map

Questie entry points:

- `Database/QuestieDB.lua`
- `Database/compiler.lua`
- `Modules/QuestieInit.lua`
- `Database/Corrections/QuestieCorrections.lua`
- `Localization/l10n.lua`
- `Modules/QuestieMenu/Townsfolk.lua`
- `Modules/Libs/QuestieLib.lua`
- `Database/Corrections/Holidays/QuestieEvent.lua`
- `Modules/QuestieCleanup.lua`

QuestieTDB contract:

- `docs/api.md`
- `src/api.lua`
- `src/read/shared.lua`
- `src/corrections/registry.lua`
- `src/l10n/overlay.lua`
- `src/support/data.lua`
- `docs/questie-handover.md`

## Change log

- Initial document: recorded library reconnaissance, Questie compiler mapping, firm decisions, target interface, work tracker, risks, and validation gates. No implementation work completed yet.
- Correction audit update: linked QuestieTDB issues #14 through #19; added Objective Order binding, Special Objective localization, exact Darkmoon arguments, support-data dependencies, Titan gating, and missing-Item model verification. No implementation work completed yet.
- TDB-01 and TDB-02 implementation: added the local Database Addon test double; bound Contract Version, Database Key Enums, entity queries, ID maps, and Objective Order Corrections; reset Questie semantic caches during initialization; localized Special Objective descriptions and custom spawn names.
- TDB-01 and TDB-02 review fixes: added cold Contract guards before schema metadata access, stable provider-owned ID maps in the test fake, packed nil-slot coverage, fake-owned Objective Order setup, fresh table reads, creature-level cache reset, and nil-safe Special Objective localization. `Database/QuestieDB.test.lua` passed with 50 tests, the affected semantic command passed with 122 tests, the full suite passed with 1,451 tests, and full production luacheck passed with no warnings. Two fresh final reviewers found no issues, and independent validation passed.
- TOC dependency: all five Questie flavor manifests now declare `## RequiredDeps: QuestieTDB`. Bundling and release packaging remain deferred.
- Baseline/implementation branch strategy: the remaining delivery uses a stacked-MR model. `baseline` is cut from `master`; after two documentation-only planning commits, its first code-changing commit extracts the Questie-owned Classic/TBC policy producers from mixed provider files into expansion-split files, then later commits apply `TDB-DELETION-MANIFEST.md` (~5.04 million lines: entity lookups, raw DB data, static fixes, compiler, residue). `implementation` starts fresh from that subtractive baseline and implements the final shape in `TDB-RELAND-HANDOVER.md` without merging, cherry-picking, or mechanically porting historical work. Gated items (QuestieTDB #13, #14) are deleted and tracked as work packets; QuestieTDB's master-data sync transfers data fixes before the merge. This supersedes this document's TDB-03 detail text and any instruction to retain legacy paths until TDB-03.
- Historical Dynamic Corrections packet evidence (TDB-04, TDB-07, part of TDB-05): prior work demonstrated the owner-scoped registrar behaviors described in `TDB-DYNAMIC-CORRECTIONS-HANDOVER.md`, with 1,526 tests and clean luacheck recorded at the time. Committed `origin/QuestieTDB` at `bc9ad9bfa6ddd06e75933fd3f37b7dbeba32bdf5` contains TDB-01/TDB-02 only; dirty and untracked later work in `../Questie-tdb-claude` is optional behavioral archaeology. The new implementation must be designed fresh from the final contract and must not mechanically port that compatibility-era code or tests.
- Subtractive baseline completion: WP-00 extracted the retained Classic/TBC Questie policy producers at `a85d6c5a2ad1e77f431907ef70d4163f623c1bd1`; push-triggered CI run 33496726477 passed for that exact SHA, and evidence was recorded at `09e0178e79775782cdabd75f506dccd6e8ec0698`. Six deletion commits `99493b08` through `14bb2681f8a349a0470c8deb1f37c238ea72ae80`, measured by `09e0178e..14bb2681f`, removed 281 tracked files and 5,042,232 deleted-file lines while retaining QuestiePolicy, Titan quest tags, blacklists, event/content-phase state, UI and Zone/Category localization, QuestieStream, and deferred support data. Nine cleanup commits `0b02060c` through `8b63c04beadef59b648cb558247609651e1f19e1` removed mixed-runtime compiler/entity residue, converted raw consumers, retained semantic constants, added Migration 38, and restored a focused provider metadata test seam; review fixes at `cf4349e9f647f3c1b077421863fc53ef6031da44` restore NPC flag semantics and keep WP-06 verification open. Objective Order was not extracted. Full Busted passes with 1,424 successes, production luacheck is clean across 322 files, loader-usage and diff checks pass, and production retirement greps are empty. Runtime Contract/query/Correction integration and the pinned Database Integration Check belong to `implementation`; focused open seams are recorded in `TDB-IMPLEMENTATION-ISSUES.md`.
- Fresh implementation: `QuestieTDB-implementation` starts at baseline handoff commit
  `ad8e6ec19979f42eeecc1e3262575014fa8c3fe8` and lands, in separately reviewable commits, the
  Contract Version 1 test double, the schema adapters and `QuestieDB` bindings, the eight Questie
  Policy Corrections under owner `Questie`, the entity locale seam, compiler-free Login
  Initialization, the Darkmoon and runtime-Item policy callers, the Object-hover
  registration/provider index split, and Townsfolk and Available Quests verification. Full Busted
  passes with 1,530 successes, luacheck is clean across 329 files, loader-usage and `git diff --check`
  pass, and every retirement grep is empty. TDB-12 stays blocked: the provider documents no
  consumer-side pinned integration command.
- Fresh review of `QuestieTDB-implementation`: two fresh reviewers (lifecycle, ownership, and
  Contract assumptions; test value and mock fidelity) found two blockers the Contract mock had hidden.
  The provider reads `0`, never nil, for an absent number field of an existing entity, which made
  `Townsfolk.Initialize` index the pet food categories with `0` and crash Login Initialization; and
  wiping the quest cache on every post-initialization apply would hand the quest lifecycle a
  replacement object and split tracker, quest log, and map icon state. Both are fixed: the mock now
  carries the provider field types and returns fresh copies, Townsfolk keys pet food by category,
  `RefreshAfterCorrectionApply` keeps quest objects (a deliberate deviation from the Dynamic
  Corrections packet's "clear the private Quest cache" line; no post-initialization apply changes
  Quest rows today), and an empty-to-empty Darkmoon withdrawal no longer reapplies. Also fixed:
  external locale rows could blank or clear composed fields through `""` and `{}`, nil external rows
  at initialization, `LibQuestieDB` leaking between test files, and the test-coupling findings.
  Deferred with the reviewers' notes: coalescing per-Item `RepairMissingItem` applies, Townsfolk's
  per-login SavedVariables writes, and the pre-existing `objectCache` no-op.
- Write-through simplification (working tree, Questie + QuestieTDB): QuestieTDB gained the
  data-shaped `Corrections.Set` slot API with per-datatype recomposition/publish and memoized
  function-entry materialization (provider suite gained `set-corrections`, 35 checks; an offline
  consumer apply on SoD dropped from 67.6 ms / 3.4 MB garbage to 14.8 ms / 2.0 MB — the residue
  is the datatype's compose iteration — and to sub-millisecond on flavors without huge dynamic
  sets; QuestieTDB ADR 0009 records the provider decisions).
  Questie's corrections seam collapsed to `QuestieCorrections.SetCorrection` with targeted
  `QuestieDB.RefreshAfterCorrectionApply(datatype, changedIds)`; slot state moved to
  QuestieEvent and QuestieLib (EntityLocale too, until its removal below); `IsInitialized`, `InitializePolicyCorrections`,
  `ReapplyPolicyCorrections`, the per-correction setters, and `ForwardProviderLocale` are
  deleted. Full Busted 1,533 successes, production luacheck clean across 329 files, loader
  validation and `git diff --check` clean. Proposal: `TDB-SIMPLIFICATION.md` §1–2.
- 2026-09-02: `Localization/EntityLocale.lua` removed with its test, TOC lines, and the Login
  Initialization call. External translation addons publish entity rows to QuestieTDB under their
  own owner; Questie keeps only their UI strings via `QUESTIE_LOCALES_OVERRIDE`. Record and
  Ukrainian addon consequence: `TDB-ENTITYLOCALE.md`.
