# QuestieDB cutover history

This records how the database extraction was delivered and what earlier validation found. It is
not a current merge recipe or proof of current compatibility. The maintained consumer guide and
unfinished checks are in [QuestieDB integration](questiedb-integration.md); decisions are in
[ADRs 0001–0003](adr/0001-questietdb-is-the-only-entity-database.md).

The full pre-consolidation notes remain in git at `0db1e28cb4bd7c96da6443f076ab6c3f425cb5f3`.
For example:

```bash
git show 0db1e28cb:TDB-FINDINGS.md
git show 0db1e28cb:TDB-STATUS.md
git log --all -- 'TDB-*.md'
```

## Branch provenance

The original baseline used Questie master `ba0f5acd63cbeb8e5affc5d1990b0d1ee276cd57`.
`QuestieTDB-implementation` was cut from baseline handoff
`ad8e6ec19979f42eeecc1e3262575014fa8c3fe8`. The earlier registrar-based implementation on
`origin/QuestieTDB` (`bc9ad9bfa6ddd06e75933fd3f37b7dbeba32bdf5`) was consulted for behavior,
not merged or ported.

The later bottom-up restack used `origin/master` at `215b0c757`:

| Historical branch | Role |
| --- | --- |
| `QuestieTDB-remove-baseline` at `6d86dbd22` | Delete provider-owned data, compiler, and support payloads. Intentionally incomplete on its own. |
| `QuestieTDB-remove-baseline-dependencies` at `fa263b64a` | Remove retained consumers' baseline dependencies. Also runtime-incomplete alone. |
| `QuestieTDB-implementation` | Bind the provider and retain Questie-owned policy and newer consumer behavior. |
| `QuestieTDB-implementation-support` | Support-validation and CI-compatibility work subsequently replayed on the implementation. |

The pre-restack tips shared base `fde81078a` and were saved under
`backup/tdb-stack-20260914/` with those branch names. These names identify historical work; they
are not instructions to merge partial branches into master. Review the live PR stack when merging.

## Extraction and implementation

| Historical commit | Change |
| --- | --- |
| `a85d6c5a2ad1e77f431907ef70d4163f623c1bd1` | Extract Questie-owned Darkmoon and TBC Content Phase producers into `Database/Corrections/QuestiePolicy/`. CI run 33496726477 passed at that revision. |
| `99493b08a5b35aabf7e4ca93d438bf58baf3c08a` | Remove raw provider entity data. |
| `64bd822b9c998e8cfc00262b7635d65cafd5c930` | Remove provider-owned correction sources and Titan entity corrections; retain Questie's API quest-tag corrections. |
| `d3d08d244e341ebe68b7d7fabd4f50de13fc37a1` | Remove generated entity localization and lookup overrides; retain zone/category lookups. |
| `c7454f1f79459de72586953870ff9f4447d048ab` | Remove compiler, storage, cleanup, waypoint optimization, and compiler schemas. |
| `ab8a78f2f127136b1b09e059fd6cc81ecc187203` | Remove entity validators and their CI matrix; retain loader-usage validation. |
| `14bb2681f8a349a0470c8deb1f37c238ea72ae80` | Remove orphaned CLI database mocks. |

The deletion steps removed 281 files and about 5.04 million lines. Cleanup commits
`0b02060ca5ab4a853651bf55bfe3a3b73e00f266` through `8b63c04beadef59b648cb558247609651e1f19e1`
removed compiler residue, adapted Townsfolk and Available Quests, and migrated obsolete state.
`cf4349e9f647f3c1b077421863fc53ef6031da44` restored retained NPC flag constants.

Baseline `6d86dbd22` also removed 24 support payload files and 51 flavor TOC entries from the
Quest XP, drop, faction-template, and zone datasets. Consumer wrappers remained; tests switched
to small fixtures and production wrappers read provider support data.

Implementation proceeded through a contract fake, entity bindings, policy slots, localization,
compiler-free initialization, retained consumers, and write-through corrections. A pass-through
`EntityLocale` module was removed. The original Questie-owned Object registration/name index was
also superseded by provider candidate lookup with early local/party registration filtering.

The initial correction design registered eight provider functions and re-applied their owner after
each state change. Each new correction required captured state, a closure, load order, registration,
and a setter in a module that did not own its input. A historical SoD measurement recorded
67.6 ms and 3.4 MB of garbage per owner apply. Provider `Corrections.Set` and Questie's targeted
refresh replaced that lifecycle. This did not by itself make provider recomposition incremental.

## Provider handoff evidence

The previous status notes were checked against provider `60f0527`. The following records describe
implementation evidence at that time, **not present issue closure or newly rerun validation**:

| Provider issue | Recorded evidence |
| --- | --- |
| [#1](https://github.com/Questie/QuestieDB/issues/1) / [#13](https://github.com/Questie/QuestieDB/issues/13) | 25 explicit SoD required-race correction rows; the handover reported parity for all 5,534 SoD quests on both factions. Temporary base-flavor inference remained a follow-up. |
| [#14](https://github.com/Questie/QuestieDB/issues/14) | Built-in lookup overrides, Titan zhCN entity localization, and custom-locale translation slots implemented with offline validation. |
| [#15](https://github.com/Questie/QuestieDB/issues/15) | Support payload binding and Source-mode flavor selection; offline wrapper checks passed for five flavors and both factions. |
| [#17](https://github.com/Questie/QuestieDB/issues/17) | Objective Order flavor/season scoping, with recorded Source, Baked, and stripped-package parity. |
| [#19](https://github.com/Questie/QuestieDB/issues/19) | Differential coverage of reputation/item-start fixes, NPC flags, static corrections, and SoD side channels remained a gate to verify. |

The restack originally needed ten changed provider-owned correction files synchronized. Provider
`be3e7f6` advanced `QUESTIE_COMMIT` from `92ab8206f` to `215b0c757`, ported those ten files and a
comments-only zone-map change, and recorded five-flavor validation with reviewed Golden updates
in its `docs/questie-handover.md`. Later Questie data changes still require reconciliation.

## Historical Contract Version 1 smoke runs

These runs used baked provider `eaea07d` on 2026-09-02, client 1.15.9 (69547), locale enUS:

| Flavor | Character level | Quest / NPC / Item / Object ID counts |
| --- | ---: | --- |
| Era | 5 | 4,257 / 10,122 / 14,899 / 6,666 |
| SoD season 2 | 2 | 5,534 / 12,220 / 21,657 / 7,043 |

Both runs completed login with tracker, map, and minimap rendering and no surfaced Lua errors.
They exercised gathering suppression, correction replacement/withdrawal, pointer/cache refresh,
manual Darkmoon producer publication, locale switching, Townsfolk, and missing-entity reads.
SoD included 1,234 SoD quests with provider provenance and readable rune Items.

Representative probes:

- Gathering-node composed spawns were nil while raw reads retained 11 zones. Questie published
  only `Object:GatheringNodeDisplayPolicy` at rest; TBC prerequisite quests were absent.
- Adding an NPC correction made it enumerable, refreshed NPC pointers without changing Quest
  pointer identity, evicted its cached projection, and retained raw values. Withdrawal reversed it.
- Manually publishing Darkmoon NPC 14828 in Elwynn selected zone 12; withdrawal restored its
  two-zone provider row and zone 215. No active faire was available to test the calendar path.
- Switching to deDE localized entity reads and the Object name index without losing gathering
  suppression. Switching back restored enUS. NPC 823 remained English, as upstream did.
- `IdsByName("Silverleaf")` returned 1617 and 3725. The then-present local Object-name index was
  checked too; that index no longer exists.

These are not Contract Version 2 acceptance results. Current flavor, locale, calendar, coordinate,
and consumer checks are listed in the [integration guide](questiedb-integration.md#outstanding-integration-validation).

### Findings and lessons

| Finding | Historical observation and disposition |
| --- | --- |
| F1: whole-datatype recomposition | A one-row SoD slot write rebuilt all applied dynamic rows of that datatype. Tracked in [QuestieDB #20](https://github.com/Questie/QuestieDB/issues/20); do not treat old timings as measurements of current code. |
| F2: per-callback Item repair writes | Questie published after every Item-load callback. Resolved by collecting names and publishing once per frame. Uncached Items arriving across frames can still cause separate writes. |
| F3: required-race probe error | The 16 Era flags were probe artifacts, not missing corrections. The SoD count of 40 was an unvalidated upper bound polluted by the same error. Later provider parity evidence is recorded above. |
| F4: Objective Order season leak | SoD IDs 85304, 85386, and 89567 appeared on Era even in baked mode, though those entities did not exist there. Later scoping evidence is recorded under provider #17 above. |
| F5: correction-source attribution | Profiler/C wrapper frames hid the actual caller. `_CallerSource` now skips known wrappers; the historical live probe confirmed the writer under the profiler. |
| F6: noisy performance samples | A single refresh sample showed 13 ms and 2 MB; best-of-five after collection showed 0.03 ms. Compare like-for-like runs with controlled GC rather than relying on one sample. |
| F7: fake provenance mismatch | The fake returned nil for an unknown entity; the provider returned `QuestieDB` when no correction won. Fixed in the fake. |
| F8: fake ID-map mismatch | The fake replaced ID maps on every publish. The provider preserves the base map when no entity is added and restores it after withdrawal. Fixed in the fake, along with empty/out-of-schema rows incorrectly creating entities. |

F1 timings were best-of-five for `Corrections.Set` alone:

| Datatype | Time | Garbage |
| --- | ---: | ---: |
| Item | 19 ms | 2.7 MB |
| NPC | 25 ms | 4.6 MB |
| Object | 3 ms | 0.5 MB |

The Item overlay had 6,874 dynamic rows. Questie's refresh after the same write took 0.03 ms;
`GetAllIds(true)` took 0.007 ms. Memoizing correction producers avoided rematerialization, not the
merge. The proposed provider optimization was to recompose the old/new IDs touched by a slot
rather than the whole datatype, while retaining correct provenance and precedence.

F3 is a validation lesson worth preserving. Base required-race inference runs during baking, so
raw and composed values can correctly be identical. Quest 8254 has mixed-faction raw starters;
the Alliance character's composed starters were faction-filtered, making the probe incorrectly
infer Alliance-only eligibility. Applying the upstream rule to raw Era starter/NPC data produced
zero patches. Historical Era totals were 1,370 Alliance masks (77) and 1,216 Horde masks (178).
For SoD runtime rows, compare against the upstream compiled result without reapplying the rule
to already faction-filtered starters.

## Other review-driven fixes

- Provider numeric defaults are `0`, not nil. The earlier fake hid a Townsfolk pet-food category
  crash; both consumer handling and fake field types were corrected.
- Blanket quest-cache wipes split identities held by tracker, quest-log, and map consumers.
  Correction refresh was narrowed to affected IDs.
- Empty/malformed external locale fields could blank names or clear data. The compatibility
  publisher now omits those fields while preserving valid fields in the row.
- Withdrawing an unpublished Darkmoon slot became a no-op.
- The login contract gate moved ahead of provider locale work. It still does not precede
  provider accesses made while TOC files load.
- Provider globals were isolated between test files. Later conformance fixes distinguished
  field-only edits from entity additions rather than requiring every publish to swap ID maps.
- Item-repair coalescing and removal of persistent Townsfolk tables were initially deferred and
  subsequently implemented. They are not remaining migration tasks.

## Historical offline validation

Pre-restack Contract Version 2 integration `4bec86a82`, based on `cb986af34`, passed 1,609 consumer
tests, real-provider conformance, lint, loader checks, and support-wrapper checks for all five
flavors and both factions. At that revision support payloads were still present but unloaded;
the later baseline removed them.

Post-restack notes recorded 1,665 passing tests, then 1,779 with the support layer. These figures
belong to their earlier checkouts, not a fresh test run of this documentation change or evidence
of released/Baked compatibility. Use the [maintained commands and coverage limits](questiedb-integration.md#tests-and-provider-dependency)
for present work.
