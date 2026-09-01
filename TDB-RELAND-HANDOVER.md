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
- **This document** — branch mechanics, the reference-implementation rule, master-drift
  warnings, target final shapes, and what ports versus what gets rewritten.

## Branch strategy and mechanics

1. `baseline` is cut from `master`. Its first commit records the source commit and extracts the
   Questie-owned Classic and TBC policy producers from mixed provider correction files into
   expansion-split files. No earlier `baseline` commit is allowed. The extraction commit updates
   callers and TOCs without changing behavior and must pass normal CI at that exact SHA.
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

## Reference implementation rule

Branch `QuestieTDB` is the **reference implementation**: TDB-01 (test fake), TDB-02 (QuestieDB
binding to LibQuestieDB), and the completed Dynamic Corrections packet. It is evidence and
design reference — do not rebase or merge it onto the stack.

- **Tests port nearly as-is.** The mock (`test/QuestieTDBMock.lua`), its contract tests, and
  the ~150 tests across `QuestieCorrections.test.lua`, `QuestieDB.test.lua`,
  `QuestieEvent.test.lua`, `QuestieLib.test.lua`, and `l10n.test.lua` run against the fake, not
  the compiler. Exceptions: `l10n.test.lua` describe blocks that exercise the legacy
  `l10n:Initialize()` raw entity writes die with that path; the `*DataOverrides` empty-table
  assertions in the QuestieEvent/QuestieLib tests seed their own sentinel tables and keep
  working, but may be simplified since the fields no longer exist anywhere.
- **Production code is rewritten in final shape, not cherry-picked.** The reference was built
  to coexist with the compiler; its intermediate scaffolding must not be ported:
  no `QuestieCorrections:Initialize(validationTables)`, no `_LoadCorrections`, no
  `PreCompile`/`OptimizeWaypoints`, no Stage-1 compile branch, no compile/cached dual-path
  reasoning. The register-once guard stays (it also protects repeated initialization in
  tests), but its comment should no longer mention compile paths.

## Master drift warning

The reference branch diverged from an older `master`. Verified drift that affects the re-land:

- Titan Reforged corrections on `master` now live in standalone
  `titanReforged{Item,NPC,Object,Quest}Fixes.lua` files called from `MinimalInit`; the
  reference branch removed Titan calls that pointed into the WotLK fix files. The baseline
  deletes the four standalone files; `titanReforgedQuestTags.lua` stays (it feeds
  `questTagInfoCorrections.lua`).
- `master`'s Stage 1 uses an `activeStorage` shape the reference predates.

Rule: the reference shows design, behavior, and tests. Implement against the baseline's actual
(current-`master`-derived) code shapes, not against the reference's surroundings. When the two
disagree about surrounding code, the baseline wins; when they disagree about correction
behavior, `TDB-DYNAMIC-CORRECTIONS-HANDOVER.md` wins.

## Target final shapes

### Login Initialization (Stage 1, no compile branch)

1. `l10n.InitializeUILocale()`
2. `LibQuestieDB.RequireContract(1)` — hard error on failure, before any locale or correction
   work (the four schema adapter files also gate at file load; keep both)
3. `l10n.ApplyProviderLocale()` — forwards the effective UI locale to
   `LibQuestieDB.l10n.SetLocale`
4. `l10n.BuildExternalLocaleCorrections()` — `Exists`-filtered External Locale Override
   tables, captured before the initial apply
5. Policy Correction registration + blacklist construction + initial apply of owner
   `"Questie"` (the reference's repurposed `MinimalInit`; rename freely — the old name is
   meaningless without a "full init" counterpart)
6. `QuestieDB:Initialize()` — sets `QuestieDB.IsInitialized = true` at its end
7. Townsfolk initialization **from composed reads** (TDB-06 work packet; also replaces the
   `dbCompiledCount` rebuild key)
8. `QuestieEvent.Initialize()` — after `QuestieDB:Initialize()`, so its async `Load()` hits an
   initialized database and setter calls refresh properly
9. Later stages unchanged; Stage 2 runs `l10n:PostBoot()` →
   `l10n.RebuildObjectNameLookup()` inside the staged coroutine

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
- **`l10n`** — UI Translation Entries, Zone/Category Lookups, `SetUILocale`/
  `InitializeUILocale`, `ApplyProviderLocale`, `BuildExternalLocaleCorrections`,
  `ApplyEntityLocale` (the withdraw-first switch sequence), `RebuildObjectNameLookup`. No
  entity-table writes, no `Localization/lookups` entity files. The locale-change options path
  calls `ApplyEntityLocale()` (plus UI refresh) instead of the recompile-and-reload popup.
- **`QuestieEvent` / `QuestieLib`** — as on the reference branch: one hoisted
  `SetDarkmoonNpcCorrections` call with NONE-location withdrawal; name-only
  `RepairMissingItem`.
- **Extracted policy producers** — already present on `baseline` in the expansion-split
  `QuestiePolicy` files. `implementation` connects them to `DarkmoonFaire` and
  `ContentPhasePolicy`. It may reorganize them later only when the move and behavior change remain
  separately reviewable.
- **Hedges** — drop `(QuestPointers or questData)` / `(ItemPointers or itemData)`; the raw
  half no longer exists.

## Execution order (suggested)

1. Commit or verify the reference branch state, then create `baseline` from `master`.
2. Extract the Classic and TBC policy producers per WP-00. Update callers and TOCs, run focused and
   full validation, and commit the behavior-neutral move. Require successful normal CI for that SHA
   before proceeding.
3. Apply the remaining manifest deletions in separate commits and open the visibility MR.
4. Create `implementation`; port the mock and affected test files, then watch the intended failures.
5. Re-land the central slice in final shape (QuestieDB, QuestieCorrections, Stage 1), connect the
   retained policy producers, then adapt the policy callers (QuestieEvent, QuestieLib, l10n). The
   reference branch's per-file diffs are the guide.
6. Wire the locale-change path to `ApplyEntityLocale()`.
7. Convert Townsfolk (TDB-06) and the CI `db-validation` matrix to the pinned Database Integration
   Check (TDB-12).
8. Add a migration that drops compiler state under the ordinary global, SoD, and Titan Reforged
   global scopes.
9. Run full validation and the manifest's consolidated work packets, then use the merge order above.

## Validation gates

- `busted -p ".test.lua" .` green on `implementation` (reference count after the packet:
  1,526; expect drift from ported/retired describes).
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
