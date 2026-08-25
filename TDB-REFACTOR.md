# QuestieTDB refactor

## Purpose

Replace Questie's runtime database compiler with QuestieTDB as the only entity database implementation.

Questie keeps its `QuestieDB` module as the interface used by the rest of the addon. `QuestieDB` will read from `LibQuestieDB` while retaining Questie-owned semantic helpers, player-state logic, blacklists, and rich entity projections.

This document is the source of truth for the work packet. Update it whenever an agent starts or finishes a work item, changes a decision, discovers a risk, or runs validation.

## Current status

- QuestieTDB library reconnaissance: complete
- Questie compiler and consumer mapping: complete
- Implementation: not started
- Distribution and release packaging: deferred

No runtime cutover code has been written yet.

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
7. Treat QuestieTDB's `requiredRaces` output as correct for this work packet.
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
| TDB-01 | Add focused QuestieTDB test fake and contract tests | not started | - | - | Keep the fake smaller than the provider implementation. |
| TDB-02 | Bind `QuestieDB` queries, keys, ID maps, Objective Order Corrections, and caches to `LibQuestieDB` | not started | - | TDB-01, QuestieTDB #17 | Preserve the existing caller interface. |
| TDB-03 | Replace compiler-driven Login Initialization with the target startup order | not started | - | TDB-02, TDB-04, TDB-05, QuestieTDB #16 | No compile checks or fallback. |
| TDB-04 | Convert Questie-owned policy to Dynamic Corrections | not started | - | TDB-01 | Includes gathering nodes and TBC phase policy. |
| TDB-05 | Forward entity locale to QuestieTDB and remove raw entity localization writes | not started | - | TDB-01, TDB-02, QuestieTDB #14 | Keep UI translation behavior. TDB-02 owns Special Objective projection changes in `QuestieDB.lua`. |
| TDB-06 | Adapt raw entity-table consumers | not started | - | TDB-02 | Townsfolk, Available Quests, search, and pointer fallbacks. |
| TDB-07 | Convert Darkmoon and asynchronous Item updates | not started | - | TDB-02, TDB-04, QuestieTDB #18 | Must invalidate Questie's semantic caches. Verify the missing-Item data model before porting it. |
| TDB-08 | Remove compiler controls, state, popups, and SavedVariables payloads | not started | - | TDB-03 | Include migration cleanup. |
| TDB-09 | Remove compiler and raw entity files from runtime TOCs | not started | - | TDB-03, TDB-06 | Preserve Objective Order Correction data first. |
| TDB-10 | Delete dead compiler, raw data, generated lookups, and validators | not started | - | TDB-09 | Physical repository cleanup after full tests pass. |
| TDB-11 | Read Zone, XP, Drop, and faction-template data from `Support` | not started | - | TDB-02, QuestieTDB #15 | Keep Questie's behavior wrappers. Do not switch to known-stale support copies. |
| TDB-12 | Replace database validation CI with a pinned integration check | not started | - | TDB-10, TDB-11, QuestieTDB #19 | Data validation belongs in QuestieTDB; consumer behavior still needs integration coverage. |
| TDB-13 | Bundle QuestieTDB and update release packaging | deferred | - | Runtime cutover | Separate distribution work. |
| TDB-14 | Expose QuestieTDB source-mode status in Questie diagnostics | not started | - | TDB-02 | Do after the main cutover works. |

## Work item details

### TDB-01: test interface

Add a focused QuestieTDB fake for Questie tests. It should provide only what Questie consumes:

- `RequireContract`
- Entity `Get`, `GetAll`, `GetAllIds`, and `Exists`
- `Meta`
- `ObjectiveFirst`
- `GetRegistrar` and correction application hooks
- `Corrections.ApplyParameterized`
- `l10n.SetLocale`
- minimal `Support` data

Do not copy QuestieTDB caching, encoding, correction composition, or localization implementation into the fake.

Required tests:

- incompatible Contract Version fails clearly
- single and multi-field query binding
- Database Key Enum binding
- Objective Order Correction binding
- ID map binding
- semantic cache reset during initialization

Primary files:

- `setupTests.lua`
- new focused test helper
- `Database/QuestieDB.test.lua`

### TDB-02: `QuestieDB` cutover

In `Database/QuestieDB.lua`:

- remove the `DBCompiler` import
- remove binary and pointer decoding
- remove raw override tables
- bind the compatibility symbols listed above
- bind all five consumer-must-not-mutate tables from `LibQuestieDB.ObjectiveFirst`
- localize `extraObjectives[3]` while constructing Questie's rich Special Objective projection
- test translated descriptions, spawn names, English fallback, and locale-driven semantic-cache invalidation
- retain rich projections and Questie policy helpers
- add a plain pointer refresh function if runtime corrections can add entities
- provide one clear semantic-cache invalidation function
- remove raw-data helpers such as `DeleteGatheringNodes`

The caller interface is the test seam. Avoid edits across ordinary Questie callers unless they directly consume raw tables.

Related schema files:

- `Database/questDB.lua`
- `Database/npcDB.lua`
- `Database/itemDB.lua`
- `Database/objectDB.lua`

Source Database Key Enums from `LibQuestieDB.Meta`. Keep Questie-owned constants that are not entity schema.

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

In `Localization/l10n.lua`:

- keep UI translations, zone names, categories, and locale selection
- remove writes into raw entity tables
- forward the effective locale to `LibQuestieDB.l10n.SetLocale`
- rebuild `objectNameLookup` from Object IDs and queries
- clear locale-derived Questie caches when the locale changes

QuestieTDB stores `extraObjectives[3]` as the enUS localization key and does not translate that
structured field. TDB-02 owns the `QuestieDB.lua` projection change; this item owns locale selection
and cache lifecycle.

Open decision: external locale addons can currently provide entity lookups. QuestieTDB exposes fixed locale overlays but no public provider-registration interface. Do not silently drop this behavior.

### TDB-06: raw consumers

Known direct consumers:

- `Modules/QuestieMenu/Townsfolk.lua`
- `Modules/Quest/AvailableQuests/AvailableQuests.lua`
- `Modules/Libs/QuestieLib.lua`
- `Localization/l10n.lua`

Replace raw table traversal with ID enumeration and field queries. Do not build full compatibility copies.

Townsfolk should use ID maps plus query functions. Its local faction-template data may remain until TDB-11.

### TDB-07: runtime updates

Darkmoon correction:

- call `LibQuestieDB.Corrections.ApplyParameterized("LoadDarkmoonFixes", ...)`
- Era passes `isInMulgore`
- TBC passes `isInMulgore, isInTerokkar`
- never pass a location string because non-empty strings are truthy in Lua
- clear Questie's semantic NPC cache afterward

Asynchronous Item names:

- first verify why the existing row writes `{questId}` into the Item's `npcDrops` slot
- replace writes to `itemDataOverrides` with a Questie-owned Dynamic Correction only after the intended model is known
- reapply the Questie correction owner
- refresh Item IDs if a new entity was added
- clear Questie's semantic Item cache

QuestieTDB cache invalidation does not clear Questie's rich projection caches.

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

Remove from every flavor TOC:

- raw expansion entity files
- `Database\compiler.lua`
- `Modules\QuestieCleanup.lua`
- generated Item, NPC, Object, and Quest lookup files

Before removing correction files, extract Objective Order Correction tables that Questie still consumes.

After the runtime cutover and full validation pass, physically delete:

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
- Whether Objective Order Correction data moves to QuestieTDB later

### Explicitly not a blocker

- `requiredRaces` differences. Another QuestieTDB work item will provide matching data, and this refactor treats the result as correct.
- Distribution and generated TOC freshness. These are handled separately or assumed current.

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
