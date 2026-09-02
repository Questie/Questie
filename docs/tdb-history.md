# QuestieTDB cutover history

How the cutover was delivered, with pointers into git. Current state and open work live in
`TDB-STATUS.md`; decisions in `docs/adr/`. The planning documents that drove each step were
deleted once executed; `git log --all -- 'TDB-*.md'` finds them.

## Branch stack

- Source `master` commit for the baseline: `ba0f5acd63cbeb8e5affc5d1990b0d1ee276cd57`.
- `QuestieTDB-remove-baseline`: extraction, then deletion, then cleanup. Never merges alone.
- `QuestieTDB-implementation`: cut from baseline handoff commit
  `ad8e6ec19979f42eeecc1e3262575014fa8c3fe8`. Built fresh from Contract Version 1; an earlier
  registrar-based implementation on `origin/QuestieTDB` (`bc9ad9bfa6ddd06e75933fd3f37b7dbeba32bdf5`)
  was consulted for behavior only and never merged or ported.

## Baseline commits

1. `a85d6c5a2ad1e77f431907ef70d4163f623c1bd1` moves the Questie-owned Darkmoon and TBC Content
   Phase producers out of the mixed provider correction files into
   `Database/Corrections/QuestiePolicy/`. Behavior-neutral; CI run 33496726477 passed at that SHA.
2. `99493b08a5b35aabf7e4ca93d438bf58baf3c08a` raw provider entity data.
3. `64bd822b9c998e8cfc00262b7635d65cafd5c930` provider-owned correction sources, including the
   standalone Titan Reforged files. `titanReforgedQuestTags.lua` stays; it corrects WoW API tag
   results, not entity records.
4. `d3d08d244e341ebe68b7d7fabd4f50de13fc37a1` generated entity localization and
   `lookupOverrides.lua`. Zone and category lookups stay.
5. `c7454f1f79459de72586953870ff9f4447d048ab` compiler, storage, cleanup, waypoint optimizer,
   and compiler schemas.
6. `ab8a78f2f127136b1b09e059fd6cc81ecc187203` Questie-side entity validators and the CI
   `db-validation` matrix. Loader-usage validation stays in the unit-test job.
7. `14bb2681f8a349a0470c8deb1f37c238ea72ae80` orphaned CLI database mocks.

Steps 2 to 7 delete 281 tracked files and about 5.04 million lines. Nine cleanup commits from
`0b02060ca5ab4a853651bf55bfe3a3b73e00f266` to `8b63c04beadef59b648cb558247609651e1f19e1` then
remove the mixed-runtime compiler residue, convert Townsfolk and Available Quests to composed
reads, add Migration 38 for the obsolete compiler SavedVariables, and retain the Questie-owned
semantic constants. Review fixes at `cf4349e9f647f3c1b077421863fc53ef6031da44` restore the NPC flag
constants. Objective Order was never extracted back; it stays provider-owned.

## Implementation commits

In order: Contract Version 1 test double; `QuestieDB` binding; Policy Corrections under owner
`Questie`; entity locale seam; compiler-free Login Initialization; Darkmoon and runtime-Item
callers; Object-hover split between tooltip registrations and the provider name index; Townsfolk
and Available Quests verification. Then the write-through simplification (provider `Corrections.Set`,
QuestieTDB ADR 0009) and the EntityLocale removal on 2026-09-02.

## Review findings and what was done

Two fresh reviewers per risky step. Findings that changed the design:

- **Provider reads `0`, not nil, for an absent number field.** The mock returned nil, so
  `Townsfolk.Initialize` indexed pet food categories with `0` and crashed Login Initialization.
  Fixed in Townsfolk; the mock now carries provider field types. This is why TDB-STATUS asks for a
  mock-versus-provider conformance run.
- **Wiping the quest cache on every apply splits quest identity.** The tracker, quest log, and map
  icons hold the object `GetQuest` returned. First fix kept quest objects entirely; the write-through
  refresh now evicts only the changed IDs. Recorded in ADR 0002.
- **External locale rows could blank or clear fields.** `""` and `{}` from an addon lookup reached
  the provider as a blank name and a cleared field. Now skipped in `l10n`.
- **Empty-to-empty Darkmoon withdrawal reapplied.** Withdrawing a never-published slot is now a no-op.
- **Stage 1 contract gate ran after locale work.** Moved before any provider call.
- **Mock ID maps kept identity across applies**, which made the pointer-rebind tests vacuous. The
  mock now swaps map identity like the provider; the tests fail when the rebinds are removed.
- **`LibQuestieDB` leaked between test files.** Isolated in the Contract fake.

Deferred by the reviewers and still open in TDB-STATUS: per-Item repair coalescing, Townsfolk's
per-login SavedVariables writes, the dead `objectCache`, the Isle of Quel'Danas profile-versus-global
split, and the `Expansions.Current` and `C_Calendar` leaks in the Event and QuestieLib suites.
Stage 1 has no coroutine harness; `Modules/QuestieInit.test.lua` pins the order by stubbing the
stages.

## Why the registrar shape was replaced

The first implementation registered eight provider functions with load orders through
`GetRegistrar("Questie")` and re-applied the owner after every state change. Each new Correction
cost a load-order constant, a captured local, a closure, a registration line, and a setter, all in
`QuestieCorrections` rather than with the state owner. A full owner re-apply also re-materialized
every provider layer: 67.6 ms and 3.4 MB of garbage per apply with SoD active, hit once per missing
Item during quest-log initialization. The provider gained `Corrections.Set` (ADR 0009) and Questie
collapsed to `SetCorrection` with targeted eviction. Remaining trade-offs: slots take effect in
creation order within the owner, which is fine while no two Questie slots touch the same field;
and slot names are strings, so a typo on the withdrawal side leaves the original slot published.
