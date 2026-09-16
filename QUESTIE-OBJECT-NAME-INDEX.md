# Questie object-hover name resolution

Questie resolves world-object hover names through QuestieDB's composed Object name index. This is
the Questie-side behavior for the interface defined by
[QuestieDB ADR 0008](https://github.com/Questie/QuestieDB/blob/82a2d1088631c724ae8cebd936be221b7d92af41/docs/adr/0008-name-index.md).

## Ownership

QuestieDB owns Object names, name uniqueness, and the reverse name index:

- `LibQuestieDB.Object.IdsByName(name)` returns every composed Object ID with that exact name, in
  ascending order, or `nil` when there is no match. Callers must treat the returned bucket as
  read-only.
- `LibQuestieDB.Object.BuildNameIndex()` builds the provider cache eagerly. The provider also builds
  it on demand and owns its invalidation after Object Corrections, locale changes, or explicit
  Object cache invalidation.

Questie owns the tooltip registries:

- `QuestieTooltips.lookupByKey` stores locally registered quest starters and objectives under keys
  such as `o_<id>`.
- `QuestieComms.data` stores party tooltip registrations under the same key shape.
- Questie does not keep a second Object-name index.

## Object-hover flow

`QuestieTooltips.private.AddObjectDataToTooltip(name, playerZone)` performs one
`LibQuestieDB.Object.IdsByName(name)` lookup. The returned IDs serve all three name-based needs:

1. The result count determines whether the hovered name is globally unique.
2. When Object IDs are enabled, the first ID and result count supply the contributor-facing ID
   line. Counts above ten display as `10+` unless debug mode is enabled.
3. The result itself supplies the Object candidates whose `o_<id>` tooltip keys are checked.

A globally unique name passes zone filter `0` to `QuestieTooltips.GetTooltip`, so its quest lines can
appear regardless of the player's zone. Shared names use the player's zone. For shared names,
`GetTooltip` accepts spawns in the current area or its parent area; an Object without spawn data
cannot be disproved and remains eligible.

Before reading Object spawns, `GetTooltip` checks whether the key has local data or, while grouped,
Comms data. Candidates with neither registration return immediately. Only the remaining candidates
incur the existing spawn reads and tooltip rendering. The handler reuses the same name lookup;
there is no additional name lookup or database-wide scan when the provider index is warm.

Local and eligible party data are rendered through the same `GetTooltip` path. This allows a
party-only Object to render without local registration, and lets party lines remain after local data
is removed. Because registrations are keyed by Object ID, a provider Correction that renames an
Object moves its local lines to the corrected hover name without re-registering the objective.

Lines duplicated across same-name Objects are added once. Processing stops after ten Objects have
returned tooltip data. The handler may check more matching candidates than the former local index
did; this is intentional, and Questie does not add another cache for those checks.

## Cache lifecycle

Login Initialization calls `LibQuestieDB.Object.BuildNameIndex()` in Stage 2, after locale and
Questie policy setup. Enabling the Object ID setting also asks the provider to build the index;
disabling the setting leaves it intact.

A later provider invalidation discards the cache. The next `IdsByName` call can therefore rebuild it
synchronously on hover. Questie does not maintain a parallel cache or add invalidation callbacks to
avoid that cold lookup.

## Test boundaries

`Modules/Tooltips/TooltipHandler.test.lua` covers provider candidate iteration, uniqueness and zone
filtering, line deduplication, the ten-Object cap, Object ID presentation, and a real Comms
registration-to-rendering path. Those Comms-path cases also cover party removal, local removal,
parent-zone matching, and a corrected local Object name.

`Modules/Tooltips/Tooltip.test.lua` covers the early registration check and confirms that absent
local and party data avoids spawn reads. QuestieDB's provider tests and Questie's provider
conformance tests own `IdsByName` ordering, composed-name, invalidation, and cache behavior.
