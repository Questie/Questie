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
