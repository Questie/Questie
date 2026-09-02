# QuestieTDB re-land handover

## Purpose

This document instructs the agent that re-implements the QuestieTDB cutover on the
baseline/implementation branch stack. It is the entry point for that work; read it before the
other documents.

How the four TDB documents relate:

- **`TDB-DELETION-MANIFEST.md`** — the specification for the `baseline` branch: what Questie-owned
  policy is extracted first, what then gets deleted from `master`, and the consolidated gates and
  work packets. Authoritative for extraction order and the deletion set.
- **`TDB-DYNAMIC-CORRECTIONS-HANDOVER.md`** — the registrar contract (Contract Version 1),
  the Dynamic Correction design and ownership rules, the required-test lists, and the completed
  packet's evidence record. Authoritative for correction behavior and the QuestieTDB API.
  Its "safe intermediate shape" and compiler-coexistence instructions are **superseded** (see
  below).
- **`TDB-REFACTOR.md`** — the historical work tracker and wider plan. Use it for work-item
  scope (TDB-06, TDB-08, TDB-11, TDB-12) and the change log. Its TDB-03 text describes
  replacing an init path the baseline deletes outright; treat the target order in this document
  as current.
- **`TDB-IMPLEMENTATION-ISSUES.md`** — focused open seams intentionally retained by the clean
  baseline: Object-hover indexing, runtime missing-Item repair, and provider schema/test metadata.
- **This document** — branch mechanics, the historical-evidence rule, drift warnings, target final
  shapes, and the fresh implementation sequence.

## Branch strategy and mechanics

1. `baseline` is cut from `master`. Documentation-only commits
   `ad1ef9a5261c9cd2f3c05da57fc4dc9fa42a837f` and
   `e2b6d2d2db1cf2786792d9a13553863d62f3526d` record the plan before WP-00. WP-00 is the first
   code-changing baseline commit: it records the source commit, extracts the Questie-owned Classic
   and TBC policy producers into expansion-split files, updates callers and TOCs without changing
   behavior, and must pass normal CI at that exact SHA.
2. Later `baseline` commits apply the bulk deletions in `TDB-DELETION-MANIFEST.md`. The branch becomes
   intentionally non-functional only after those commits. Its MR against `master` exists for review
   visibility, must show extraction before deletion, and must never merge alone. CI on the
   deletion-only tip may be expected-fail or skipped.
3. `implementation` is cut from the completed `baseline`. It adapts the retained policy producers to
   the final registrar design and re-lands the remaining QuestieTDB work. Green CI is enforced here.
4. Merge order: `implementation` merges into `baseline` first; the combined, fully green `baseline`
   then merges to `master`. `master` never receives a broken state.
5. Immediately before the final merge, run QuestieTDB's master-data sync so quest-data fixes that
   landed on `master` during the stack's lifetime are transferred into the provider. A modify/delete
   rebase conflict on a deleted file means a fix needs porting to QuestieTDB data. It is data work,
   not a merge chore.
6. Keep the stack short-lived. Every open week adds rebase friction against an active `master`.

## Historical evidence rule

Build `implementation` fresh from the subtractive baseline, Contract Version 1, the retained
QuestiePolicy producers, and the authoritative behavior in these handovers. Do not merge,
cherry-pick, or mechanically port an earlier implementation.

Committed `origin/QuestieTDB` at `bc9ad9bfa6ddd06e75933fd3f37b7dbeba32bdf5` contains historical
TDB-01/TDB-02 evidence. Dirty and untracked Dynamic Corrections work also exists in sibling
workspace `../Questie-tdb-claude`. Both may be consulted selectively as behavioral archaeology when
a requirement is unclear, but neither is an architectural reference, prerequisite, or merge source.

Design production code and tests from the final contract. Prior tests may suggest valuable behavior
cases, but must not preserve raw-table assumptions, compiler coexistence, `*DataOverrides`, or other
compatibility scaffolding. In particular, do not restore
`QuestieCorrections:Initialize(validationTables)`, `_LoadCorrections`, `PreCompile`,
`OptimizeWaypoints`, a Stage-1 compile branch, or compile/cached dual-path reasoning. A register-once
guard remains useful because registration is append-only, not because an old compile path used it.

## Historical drift warning

The historical work predates the current baseline and must not anchor the new design:

- Titan Reforged corrections later moved to standalone
  `titanReforged{Item,NPC,Object,Quest}Fixes.lua` files. The baseline deletes those provider-owned
  files while retaining `titanReforgedQuestTags.lua` for WoW API quest-tag correction behavior.
- The old Stage 1 and its `activeStorage` shape die with the compiler lifecycle.

Implement against the subtractive baseline and the final contracts in these documents. If historical
code disagrees with them, the baseline and authoritative handovers win.

## Target final shapes

### Login Initialization (Stage 1, no compile branch)

1. `l10n.InitializeUILocale()`
2. `LibQuestieDB.RequireContract(1)` — hard error on failure, before any locale or correction
   work (the four schema adapter files also gate at file load; keep both)
3. forward `l10n:GetUILocale()` to `LibQuestieDB.l10n.SetLocale()` outside the UI-string module
4. build `Exists`-filtered External Locale Override Policy Corrections outside `l10n`, before the
   initial owner apply
5. Policy Correction registration + blacklist construction + initial apply of owner
   `"Questie"`; choose a fresh name because `MinimalInit` is meaningless without a full-init
   counterpart
6. `QuestieDB:Initialize()` — sets `QuestieDB.IsInitialized = true` at its end
7. Townsfolk initialization **from composed reads** (TDB-06 work packet; also replaces the
   `dbCompiledCount` rebuild key)
8. `QuestieEvent.Initialize()` — after `QuestieDB:Initialize()`, so its async `Load()` hits an
   initialized database and setter calls refresh properly
9. Later stages continue. During Stage 2, call `LibQuestieDB.Object.BuildNameIndex()` only when
   `enableTooltipsObjectID` is enabled, after Questie's initial Correction apply. Quest tooltip
   registrations build `QuestieTooltips.objectIdsByName` incrementally; Questie performs no full
   Object scan. See `QUESTIE-OBJECT-NAME-INDEX.md`.

### Module end states

- **`QuestieCorrections`** — registrar lifecycle, the eight Policy Correction registrations,
  the setter API (`SetDarkmoonNpcCorrections`, `RepairMissingItem`,
  `WithdrawExternalLocaleCorrections`, `SetExternalLocaleCorrections`), the shared apply path
  with the `IsInitialized`-guarded `RefreshAfterCorrectionApply()`, and blacklist
  construction. Nothing else.
- **`QuestieDB`** — LibQuestieDB query/pointer/key bindings, `IsInitialized`,
  `RefreshAfterCorrectionApply()`, semantic caches and runtime projections. No raw tables, no
  compiled-handle binding, no recompile popup. Keep the `*Pointers` seam — it shields
  consumers from the provider's ID-map identity swap on every `Apply()`.
- **`l10n`** — Questie-owned UI Translation Entries, Zone/Category Lookups, `SetUILocale`, and
  `InitializeUILocale` only. It owns no entity lookup registries, provider locale orchestration,
  external entity corrections, or Object-name index.
- **Entity locale orchestration** — a fresh focused seam outside `l10n` forwards the provider locale,
  performs withdrawal-first External Locale Policy Correction switching, and refreshes semantic
  caches. QuestieTDB invalidates its provider-owned Name index; do not rebuild a consumer-owned index.
- **Object-hover lookup** — `QuestieTooltips.objectIdsByName` indexes `o_` registrations for quest
  lines. `LibQuestieDB.Object.IdsByName(name)` supplies the optional Object-ID line, with
  `BuildNameIndex()` warming during initialization and when the setting is enabled. QuestieTDB
  feature commit `82a2d1088631c724ae8cebd936be221b7d92af41` provides the interface; it is evidence,
  not the final integration pin. The full design is in `QUESTIE-OBJECT-NAME-INDEX.md`.
- **`QuestieEvent` / `QuestieLib`** — one hoisted `SetDarkmoonNpcCorrections` call with
  NONE-location withdrawal; name-only `RepairMissingItem`, as required by the behavior contract.
- **Extracted policy producers** — already present on `baseline` in the expansion-split
  `QuestiePolicy` files. `implementation` connects them to `DarkmoonFaire` and
  `ContentPhasePolicy`. It may reorganize them later only when the move and behavior change remain
  separately reviewable.
- **Hedges** — drop `(QuestPointers or questData)` / `(ItemPointers or itemData)`; the raw
  half no longer exists.

## Execution order (suggested)

1. Create `implementation` from the commit containing the finalized Baseline replay evidence below; do not branch from the earlier subtractive code tip alone.
2. Design the focused QuestieTDB fake and affected tests fresh from Contract Version 1 and the final
   behavior requirements, then confirm the intended baseline failures.
3. Implement the central slice in final shape (`QuestieDB`, `QuestieCorrections`, and Stage 1),
   connect the retained policy producers, then adapt the policy callers (`QuestieEvent`,
   `QuestieLib`, and `l10n`). Do not recreate a compiler-compatible intermediate state.
4. Add the fresh entity-locale orchestration outside `l10n` and wire the locale-change path to it.
5. Verify the baseline's composed-read Townsfolk and Available Quests paths against fresh provider
   bindings, then add the pinned Database Integration Check (TDB-12).
6. Verify the retained compiler-state migration against real Saved Variables fixtures.
7. Run full validation and the manifest's consolidated work packets, then use the merge order above.

## Baseline replay evidence

Whole-file deletion ends at `14bb2681f8a349a0470c8deb1f37c238ea72ae80`; the reviewed
clean-baseline code ends at `cf4349e9f647f3c1b077421863fc53ef6031da44` on branch
`QuestieTDB-remove-baseline`. The commit containing this finalized evidence section completes WP-09
and is the exact branch point for `implementation`; either earlier tip omits the final clean handoff.
The baseline was created from Questie source commit
`ba0f5acd63cbeb8e5affc5d1990b0d1ee276cd57` and retains the WP-00 extraction commit
`a85d6c5a2ad1e77f431907ef70d4163f623c1bd1`. Push-triggered GitHub Actions run
[33496726477](https://github.com/Questie/Questie/actions/runs/33496726477) passed for that exact SHA,
including unit tests, luacheck, and all `db-validation` matrix jobs. The separate pull-request run
was skipped because the merge request was draft.

The WP-00 evidence record is `09e0178e79775782cdabd75f506dccd6e8ec0698`. The deletion series is:

1. `99493b08a5b35aabf7e4ca93d438bf58baf3c08a` — raw provider entity data;
2. `64bd822b9c998e8cfc00262b7635d65cafd5c930` — provider-owned correction sources;
3. `d3d08d244e341ebe68b7d7fabd4f50de13fc37a1` — generated entity localization;
4. `c7454f1f79459de72586953870ff9f4447d048ab` — compiler, storage, cleanup, waypoint optimizer,
   and compiler schemas;
5. `ab8a78f2f127136b1b09e059fd6cc81ecc187203` — Questie-side entity validators and the old CI
   matrix, while retaining loader-usage validation;
6. `14bb2681f8a349a0470c8deb1f37c238ea72ae80` — orphaned CLI database mocks.

The nine clean mixed-runtime subtraction commits from
`0b02060ca5ab4a853651bf55bfe3a3b73e00f266` through
`8b63c04beadef59b648cb558247609651e1f19e1` remove obsolete entity localization, correction
machinery, compiler lifecycle/UI/recovery/state, raw consumers, and stale terminology while
retaining Questie policy and semantic constants. Review-fix commit
`cf4349e9f647f3c1b077421863fc53ef6031da44` restores the consumed NPC flag constants, uses the
provider metadata fixture in QuestiePolicy tests, removes final stale fixtures/translations, and
keeps WP-06 open for provider-bound verification. Their exact mapping is recorded in the manifest.

Deletion commits `99493b08` through `14bb2681f`, measured by the exclusive diff
`09e0178e..14bb2681f`, delete exactly 281 tracked files and 5,042,232 lines from deleted files. The
overall diff changes 292 files with 25 insertions and 5,042,474 deletions. All five flavor TOCs
require QuestieTDB. The Classic policy producer remains loaded in all five TOCs, while the TBC
producer remains loaded in exactly the four TBC-and-later TOCs and is absent from Classic. Objective
Order was not extracted and remains provider-owned through `LibQuestieDB.ObjectiveFirst`.

The implementation branch inherits these retained policy symbols:

- `QuestieClassicPolicyCorrections:LoadDarkmoonFixes(isInMulgore)`;
- `QuestieTBCPolicyCorrections:LoadDarkmoonFixes(isInMulgore, isInTerokkar)`;
- `QuestieTBCPolicyCorrections:LoadContentPhaseFixes()`.

It must reintroduce the final provider-backed schema adapters and runtime symbols described above,
including `QuestieDB.IsInitialized`, `QuestieDB.RefreshAfterCorrectionApply`, the owner-scoped
`QuestieCorrections` registrar and setters, provider/external locale application, and the final
Login Initialization order. The eight Policy Correction names, API datatypes, and load orders in
`TDB-DELETION-MANIFEST.md` remain exact requirements. QuestiePolicy, Titan quest tags, blacklists,
Event Quest data, Content Phase state, UI localization, Zone/Category lookups, QuestieStream, and
deferred support data remain on the baseline.

The clean baseline removes mixed-runtime compiler, raw-table, provider-fix, and entity-localization
commands while preserving their durable ownership and ordering rules as landmarks. Full Busted
passes with 1,424 successes; production luacheck passes across 322 files; loader-usage and diff checks
pass. It is not runtime-complete: Contract enforcement, provider query bindings, Policy Correction
registration/application, entity-locale orchestration, and the pinned WP-08 Database Integration
Check remain fresh implementation work. Focused open seams are recorded in
`TDB-IMPLEMENTATION-ISSUES.md`.

`origin/QuestieTDB` at `bc9ad9bfa6ddd06e75933fd3f37b7dbeba32bdf5` contains historical
TDB-01/TDB-02 evidence only. Dirty and untracked Dynamic Corrections work under
`../Questie-tdb-claude` is optional behavioral archaeology, not a prerequisite or implementation
source. Build fresh from the baseline and authoritative handovers; do not merge, cherry-pick, or
mechanically port the historical work. The lack of an immutable Dynamic Corrections commit is not a
blocker. The provider work packets remain combined-merge blockers and are not reasons to restore
deleted provider-owned data.

## Validation gates

- `busted -p ".test.lua" .` green on `implementation` (the historical packet recorded 1,526;
  expect the fresh test design to differ).
- `luacheck -q -- Database Localization Modules Public Questie.lua` — zero warnings.
- Retirement greps now expect **zero** references to `questData`/`npcData`/`itemData`/
  `objectData` raw tables, `QuestieDBCompiler`, `dbIsCompiled`, and `*DataOverrides` in
  production code.
- The manifest's work-packet list (Townsfolk, QuestieTDB #13, #14, #19 differential, data
  sync, CI replacement, live smoke matrix) must be complete before `baseline` merges to
  `master`.

## Superseded guidance

- `TDB-DYNAMIC-CORRECTIONS-HANDOVER.md` → "Registration and initialization order" final
  paragraphs describing the retained compiler path, and the whole "safe intermediate shape"
  list: superseded by the baseline deletion. The contract description, ownership rules,
  correction inventory, required tests, and completion record remain authoritative.
- `TDB-REFACTOR.md` → TDB-03 detail text (compiler-driven Login Initialization replacement)
  and any instruction to retain legacy paths "until TDB-03": subsumed by this stack. The
  tracker rows and change log remain the historical record.
- Any instruction to delete the mixed correction files and re-add their Questie-owned producers on
  `implementation`: superseded. WP-00 extracts and retains them on `baseline` before deletion.
- Anything, anywhere, instructing use of `ApplyParameterized`: obsolete; the API does not exist.
