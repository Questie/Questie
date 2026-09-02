# QuestieTDB implementation issues

## Object-hover tooltip name lookup

**Status:** Implemented on `QuestieTDB-implementation`. `QuestieTooltips.objectIdsByName` indexes `o_`
registrations, the Object-ID line reads `LibQuestieDB.Object.IdsByName`, and `BuildNameIndex` is warmed
in Stage 2 and when the setting is toggled on. The final provider pin remains open.

The former plan to scan every composed Object into `QuestieTooltips.objectNameLookup` and rebuild it
after initialization, locale changes, and Correction applies is withdrawn.

Follow `QUESTIE-OBJECT-NAME-INDEX.md`, which carries the complete Questie implementation guide for
QuestieTDB ADR 0008. The provider interface is available at QuestieTDB commit
`82a2d1088631c724ae8cebd936be221b7d92af41`.

The replacement keeps two questions separate:

- `QuestieTooltips.objectIdsByName` is an append-only registration set for Objects with active or
  historical `o_` quest tooltip registrations. It is built incrementally and never scans the
  database.
- `LibQuestieDB.Object.IdsByName(name)` supplies every composed Object ID for the optional contributor
  Object-ID line. Warm its provider-owned index with `BuildNameIndex()` only during initialization
  when `enableTooltipsObjectID` is already enabled and when that setting is toggled on.

Questie must not restore `l10n.objectNameLookup`, a Questie-side full Object scan, or a coroutine
index rebuild. Provider invalidation owns database-index freshness. The accepted residual after a
later invalidation is one synchronous first-hover rebuild unless measurements justify explicit
rewarming.

## Runtime missing-Item repair

**Status:** Implemented. `RuntimeItemRepair` is registered under owner `"Questie"`;
`QuestieLib.RepairMissingItemNames` feeds `QuestieCorrections.RepairMissingItem` on quest accept and for
the login quest log.

The legacy `QuestieLib:CacheItemNames()` path was removed because it wrote raw Item overrides and
stored a Quest ID in the Item `npcDrops` field. Quest acceptance no longer invokes that invalid path.

### Required implementation

- Register one name-only `RuntimeItemRepair` Policy Correction under owner `"Questie"`.
- When an asynchronous Item load returns a non-nil name, accumulate only
  `[itemId] = {[itemKeys.name] = itemName}` and reapply the Questie owner.
- Refresh composed Item IDs and Questie's semantic Item cache after post-initialization repairs.
- Preserve earlier repairs, make repeated callbacks idempotent, and ignore nil names.
- Do not restore raw Item tables, `*DataOverrides`, or the invalid Quest-ID relationship value.

### Relevant files

- `Modules/Libs/QuestieLib.lua`
- `Modules/EventHandler/QuestEventHandler.lua`
- `Database/Corrections/QuestieCorrections.lua`
- `Database/QuestieDB.lua`

## Provider-backed schema constants and test seam

**Status:** Implemented. The four adapters bind the `LibQuestieDB.Meta` key enums behind a Contract gate,
and `test/QuestieTDBMock.lua` supplies the consumed query and Correction interfaces on top of the meta
fixture.

The compiler-oriented schema files are deleted. Fresh minimal adapters must bind Database Key Enums
from `LibQuestieDB.Meta` and retain only Questie-owned constants still consumed by semantic modules,
including NPC flags, race masks, class masks, quest flags, and adapter query orders.

The baseline retains Questie-owned faction IDs, NPC flags, and Item classes in
`Database/QuestieDB.lua`. `test/QuestieTDBMetaMock.lua` supplies the four provider key enums used by
retained semantic and QuestiePolicy tests; it deliberately does not reconstruct raw entity tables,
compiler metadata, or provider read behavior. The fresh Contract Version 1 test adapter must add the
consumed query and Correction interfaces at this seam.

## Composed-read consumer verification

**Status:** Verified against the Contract adapter on `QuestieTDB-implementation`. Live provider smoke
verification remains a combined-merge gate.

The clean baseline removed Townsfolk and Available Quests raw-table traversal and fallback paths.
Their composed-read interfaces cannot be considered complete until real provider bindings exist and
non-empty behavior is covered.

### Required verification

- Exercise Townsfolk initialization through composed NPC, Item, and Object ID maps and query functions.
- Preserve Townsfolk category policy, faction and character filtering, and Manual Notes.
- Exercise non-empty Available Quest enumeration through `QuestieDB.QuestPointers`.
- Verify correction-added and withdrawn IDs are visible after QuestieDB pointer refresh.
- Keep WP-06 in progress until these behaviors pass focused tests against the fresh Contract adapter.

### Relevant files

- `Modules/QuestieMenu/Townsfolk.lua`
- `Modules/QuestieMenu/Townsfolk.test.lua`
- `Modules/Quest/AvailableQuests/AvailableQuests.lua`
- `Modules/Quest/AvailableQuests/AvailableQuests.test.lua`
- `Database/QuestieDB.lua`
- `test/QuestieTDBMetaMock.lua`

## Deferred follow-ups from the implementation review

**Status:** Recorded, not blocking.

- Item name repair publishes the `Item:RuntimeItemRepair` slot per asynchronous callback. Since the
  write-through simplification, one write recomposes only the Item datatype against memoized provider
  layers and evicts only the repaired IDs, so the former 67 ms SoD re-materialization per apply drops to the Item datatype's
  compose iteration (14.8 ms measured offline; sub-millisecond on other flavors); coalescing callbacks into one write per frame remains an easy option if a
  Stage 3 hitch ever shows.
- Townsfolk rebuilds on every login and still writes its results to `Questie.db.global` although
  nothing reads them across sessions. A module-local table can replace those writes once the provider
  exposes a stable data revision.
- `QuestieDB:GetObject` never populates `objectCache`, so clearing it is a no-op. Pre-existing.
- An in-session entity locale switch would be `LibQuestieDB.l10n.SetLocale(locale)` followed by
  `EntityLocale.ApplyExternalLocaleCorrections(locale)`; effective locale changes reload the UI today,
  so no production caller exists.
