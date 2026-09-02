# QuestieTDB cutover: Questie-side work plan

Work for an agent on branch `QuestieTDB-implementation`. Read `TDB-STATUS.md`, `TDB-FINDINGS.md`,
`docs/adr/0002-questie-policy-corrections.md`, and `AGENTS.md` first. This repo is the Questie
addon. The provider lives in `../Questie-toc/QuestieTDB`; both are symlinked into the WoW client.

Rules for every step:

- One commit per step, conventional prefix (`fix:`, `test:`, `db:`, `docs:`), behavior-neutral unless
  the step says otherwise. Keep comments in sync with the code you touch.
- Validate with `busted -p ".test.lua" .`, `luacheck -q -- Database Localization Modules Public
  Questie.lua`, `lua cli/validate-loader-usage.lua`, and `git diff --check`. Record the results in
  the commit message body.
- Use a fresh reviewer subagent for steps 1 to 3. Ask for edge cases and test value, not a summary.
- When a step finishes, delete its section from this file and move anything left open to
  `TDB-STATUS.md`. Delete this file when it is empty.
- Steps 5 and 6 need a game client and the user. Do steps 1 to 4 without waiting.

## Step 3. Remove leftover ceremony

Why: these exist because a handover packet named them, not because the code needs them. All
deletions, no behavior change. One commit.

Do, in this order, running the full suite after each sub-step:

1. **Contract gate once.** `Database/questDB.lua`, `npcDB.lua`, `itemDB.lua`, `objectDB.lua` each
   call `LibQuestieDB.RequireContract(1)` at file load and `error()` on failure, which aborts one
   file and leaves Questie half-loaded. Keep only the Stage 1 check in `Modules/QuestieInit.lua:125`.
   Check `Modules/QuestieInit.test.lua` still pins that gate.
2. **Fold the four adapter files.** Each binds one key enum (`QuestieDB.npcKeys =
   LibQuestieDB.Meta.NpcMeta.npcKeys`) and builds one inverse `_npcAdapterQueryOrder`. Replace with
   one loop in `Database/QuestieDB.lua` over `{Quest = "quest", Npc = "npc", Item = "item",
   Object = "object"}`. Move the `---@class DatabaseQuestKeys` style annotations into `QuestieDB.lua`
   so the type hints survive. Delete the four files and their lines from all five flavor TOCs
   (`Questie-Classic.toc:70-73` and the same block in BCC, WOTLKC, Cata, Mists). Run
   `lua cli/validate-loader-usage.lua`.
3. **Bind queries at file load.** `QuestieDB.Initialize` (`Database/QuestieDB.lua:430-448`) assigns
   the eight query aliases and five Objective Order tables. The provider is a `RequiredDeps` and
   present at file load, so bind them where the fields are declared; `Initialize` keeps only cache
   resets and the four pointer binds. Keep `QuestieDB.QueryNPCSingle` and friends as the names
   callers use; renaming callers is not this step.
4. **Flatten the policy producers.** `QuestieClassicPolicyCorrections:LoadDarkmoonFixes(isInMulgore)`,
   `QuestieTBCPolicyCorrections:LoadDarkmoonFixes(isInMulgore, isInTerokkar)`, and
   `LoadContentPhaseFixes()` in `Database/Corrections/QuestiePolicy/` are method-style classes that
   return rows. Make them dot-call functions with names that say what they return
   (`DarkmoonNpcRows`, `ContentPhaseQuestRows`), keep the provenance comment at the top of each file,
   update the callers in `QuestieEvent.lua:395-397` and `QuestieCorrections.lua:193`, and rename the
   tests to match.
5. **Dead objectCache.** `Database/QuestieDB.lua:517` reads `_QuestieDB.objectCache`; the store at
   `:536` is commented out. Delete the read, the declaration at `:371`, the reset at `:421`, and the
   eviction at `:504`. Do not enable it.
6. **F5: honest `correctionSources`.** `_CallerSource` in `QuestieCorrections.lua` uses
   `debugstack(3, 1, 0)`, which records the profiler wrapper or pcall frame instead of the writer.
   Walk up until the frame is outside `QuestieCorrections.lua` and known wrapper files, or accept
   the caller as a parameter from `SetCorrection`. Keep the `"test"` fallback under busted.

Done when: full suite green, luacheck clean, loader validation passes, the five TOCs no longer list
the adapter files, and `rg RequireContract` finds one production call.

## Step 4. Townsfolk stops writing SavedVariables

Why: `Modules/QuestieMenu/Townsfolk.lua:456-461` writes five tables into `Questie.db.global` on
every login, and only the same module reads them back (`:513-527`). Nothing survives across
sessions on purpose.

Do: replace the five globals with module-local tables, keep the readers, and add a Migration step
that nils the five keys once. Keep the "rebuild every login" behavior; a provider data revision for
caching is a later item. Update `Townsfolk.test.lua` where it asserts on `Questie.db.global`.

Done when: tests pass and a login via the bridge shows the five keys absent from
`QuestieConfig.global` after the migration.

## Step 5. Smoke matrix, remaining flavors

Needs the user to bring up each client and to switch `wow_path` in
`../.pi/skills/wow-lua-bridge/config.json`. Run the probes recorded in `TDB-FINDINGS.md` (the Era
and SoD runs list them) and append a runs row plus any new findings there.

| Client | What only this flavor proves |
| --- | --- |
| TBC, phase < 3 and phase >= 3 | `Quest:ContentPhasePolicy` publishes 10944 and 11007 prerequisites; changing the phase option rewrites the slot; Isle of Quel'Danas blacklist follows. |
| WotLK, season 109 | Titan corrections are provider-owned; Questie publishes no Titan slot; Titan quest tags still apply. |
| Cata | Pointers, projections, Townsfolk, tracker render. |
| MoP | Same, plus the five-flavor TOC matrix. |
| Any, Darkmoon week | `QuestieEvent` writes `Npc:DarkmoonFaire` from the calendar, not from the manual probe; withdrawal when the faire ends. |
| Any, external locale addon | `QuestieLocalesOverride` owner appears in provenance for a translated Item; UI strings still come from `l10n`. |
| Any, non-English client locale | Built-in provider localization through `l10n.SetLocale` at Stage 1; Special Objective text translated. |

## Step 6. Close out

1. Move whatever is still open into `TDB-STATUS.md`, delete this file.
2. Confirm `TDB-STATUS.md` merge gates are current against the QuestieTDB issue tracker
   (#1, #13, #14, #17, #19, #20).
3. Commit the QuestieTDB `docs/questie-handover.md` "External translation addons" section in that
   repo if it is still uncommitted; leave the other modified files there alone.
