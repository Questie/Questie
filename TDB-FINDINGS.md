# QuestieTDB live smoke findings

Everything found while running the `QuestieTDB-implementation` branch in a real client through
the Lua bridge. One entry per finding: what was observed, the evidence, who owns the fix, and the
proposed action. Resolved entries stay here with their resolution so the same probe is not rerun.
Current state and merge gates: `TDB-STATUS.md`.

## Runs

| Date | Flavor | Client | Locale | Provider mode | QuestieTDB | Character |
| --- | --- | --- | --- | --- | --- | --- |
| 2026-09-02 | Era | 1.15.9 (69547) | enUS | baked | `eaea07d` | level 5 |
| 2026-09-02 | SoD season 2 | 1.15.9 (69547) | enUS | baked | `eaea07d` | level 2 |

What passed on both, so it need not be re-probed unless the code changes:

- `RequireContract(1)` true; Login Initialization completes; no Lua errors surfaced; tracker,
  map, and minimap render.
- ID maps populated (Era 4,257 quests, 10,122 NPCs, 14,899 Items, 6,666 Objects; SoD 5,534,
  12,220, 21,657, 7,043).
- Gathering nodes: composed `spawns` nil, `GetRaw` keeps 11 zones, provenance `Questie`.
- Content Phase: quests 10944 and 11007 absent on Era and SoD, no `ContentPhasePolicy` slot.
- Questie publishes only `Object:GatheringNodeDisplayPolicy` at rest. Owners: `QuestieTDB`,
  `Questie`. No SoD, faction, or Titan copies from Questie.
- Write-through probe: publishing an NPC slot changes the composed read, evicts the cached NPC
  object, swaps `NPCPointers` identity while `QuestPointers` keeps identity, makes a
  correction-added NPC enumerable, leaves `GetRaw` unchanged, reports provenance `Questie`;
  withdrawal with `nil` restores all of it and drops the added ID.
- Darkmoon: the Classic producer's Elwynn table published through `Npc:DarkmoonFaire` narrows
  Gelvas Grimegate (14828) to zone 12 with provenance `Questie`; withdrawal restores the two-zone
  base row and zone 215. Calendar-driven path not exercised: no faire active.
- Provider locale: `SetLocale("deDE")` localizes NPC, Item, Object, and Quest reads, rebuilds
  the Object name index in German, and keeps the gathering suppression; `SetLocale("enUS")`
  restores. NPC 823 stays English in deDE, as it did upstream.
- Object name index: `IdsByName("Silverleaf")` returns 1617 and 3725;
  `QuestieTooltips.objectIdsByName` holds the registered `o_` keys.
- Townsfolk builds every category; the pet-food crash from the provider's `0`-not-nil number
  default is fixed against the real provider.
- Missing entity reads: `QueryItemSingle(999999, "name")` nil, not in `ItemPointers`.
- SoD: 1,234 SoD quests present with provenance `QuestieTDB`, rune Items readable,
  `eventObjectiveFirst` carries the three SoD event quests that exist on SoD.

## Findings

### F1. Provider: consumer slot writes rebuild the whole datatype overlay

**Owner:** QuestieTDB. **Severity:** performance, blocks nothing, hurts SoD logins.

Best of five in the SoD client, `LibQuestieDB.Corrections.Set` alone with a one-row slot:

| Datatype | Time | Garbage |
| --- | ---: | ---: |
| Item | 19 ms | 2.7 MB |
| Npc | 25 ms | 4.6 MB |
| Object | 3 ms | 0.5 MB |

Questie's `RefreshAfterCorrectionApply` after the same write: 0.03 ms. `GetAllIds(true)`: 0.007 ms.

Cause: `recompose` in `src/corrections/registry.lua` clears `registry.composed[datatype]` and
rebuilds it from every dynamic entry of every applied owner, re-normalizing each field. On SoD the
Item datatype has 6,874 dynamic rows, so a one-row Questie write re-merges all of them. ADR 0009's
memoization removed the re-materialization of provider functions, not the merge.

Proposed action: incremental overlay. Keep the composed map and provenance per datatype; on a
slot write, remove the slot's previous IDs from the composed map, re-merge only the entries that
touch those IDs plus the new rows, and publish. Consumer writes become proportional to the rows
written. Questie-side mitigation in the meantime is F2.

### F2. Questie: Item repair writes once per asynchronous callback

**Owner:** Questie. **Severity:** performance on SoD.

`QuestieLib.RepairMissingItemNames` re-publishes `Item:RuntimeItemRepair` from every
`ContinueOnItemLoad` callback. With F1 that is 19 ms per missing objective Item, in a burst
during quest-log initialization. Was deferred as "coalesce if a hitch ever shows"; the SoD numbers
show it.

Proposed action: accumulate names and publish once per frame (`C_Timer.After(0, ...)` guarded by a
pending flag). Idempotency and nil-name handling stay as they are.

### F3. Provider: `requiredRaces` inference is not active

**Owner:** QuestieTDB, issues #1 and #13. **Severity:** behavior regression, merge gate.

Composed `requiredRaces` equals raw everywhere. Upstream Questie inferred a faction for quests
with `requiredRaces == 0` whose starter NPCs are all one faction. Counted in the client by
starter `friendlyToFaction`:

| Flavor | Quests with 0 | Alliance-only starters | Horde-only starters | Regressed |
| --- | ---: | ---: | ---: | ---: |
| Era | 1,382 of 4,257 | 16 | 0 | 16 |
| SoD | 2,171 of 5,534 | 35 | 5 | 40 |

Era examples: 8254 Cenarion Aid, 1953 Return to the Marsh, 737 Forbidden Knowledge. SoD examples:
90125 Rebuke, 90114 Endless Rage (Horde), 82309 and 80307 A Full Shipment.

The counts use the composed starter data and treat `nil` `friendlyToFaction` as unknown, which is
how upstream's loop behaved. The scope is small enough to materialize as explicit provider
correction rows per flavor rather than running an inference pass at load.

### F4. Provider: `eventObjectiveFirst` carries SoD quest IDs on plain Era

**Owner:** QuestieTDB, issue #17 territory. **Severity:** low.

On Era in baked mode, `LibQuestieDB.ObjectiveFirst.eventObjectiveFirst` holds 85304, 85386, and
89567, which upstream set only in `sodQuestFixes.lua`. The IDs do not exist on Era, so nothing
misbehaves today, but the tables are not season-scoped. #17 describes the same leak for Source
mode; it is present in baked mode too.

### F5. Questie: `correctionSources` records the wrong frame under the profiler

**Owner:** Questie. **Severity:** cosmetic.

`QuestieCorrections.correctionSources["Object:GatheringNodeDisplayPolicy"]` reads
`QuestieProfiler.lua:544` when the profiler is running, and `[C]: in function 'pcall'` for bridge
calls. `_CallerSource` takes `debugstack(3, 1, 0)`, which is the profiler's wrapper when module
functions are hooked. Either walk past frames inside `QuestieProfiler.lua` or accept that the
field is only meaningful with the profiler off.

### F6. Measurement note: garbage-collector noise

A single-shot timing of `RefreshAfterCorrectionApply` read 13 ms and 2 MB; best of five with a
collect before each run reads 0.03 ms. Time provider and Questie calls best-of-N with
`collectgarbage("collect")` before each sample, or the collector's own work lands in the sample.

## Not yet run

TBC before and after phase 3 (Content Phase slot, TBC Darkmoon producer), WotLK season 109
(Titan gating, `titanReforgedQuestTags`), Cata, MoP, a Darkmoon week for the calendar path, an
external locale addon, and a non-English client locale. The bridge config points at the Era
client folder; other flavors need `wow_path` switched.
