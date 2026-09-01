# QuestieTDB implementation issues

## Object-hover tooltip name index

**Status:** Open for the fresh QuestieTDB implementation.

Questie's Object-hover tooltip behavior is retained in `Modules/Tooltips/Tooltip.lua` and
`Modules/Tooltips/TooltipHandler.lua`. It resolves a hovered Object name through
`QuestieTooltips.objectNameLookup`, then displays Questie objective lines and optional Object IDs.

The legacy index builder was removed from `Localization/l10n.lua` because entity localization does
not belong to Questie's UI-string module. The retained index is intentionally empty until the fresh
implementation wires its lifecycle.

### Required implementation

- Build `QuestieTooltips.objectNameLookup` from composed QuestieTDB Object IDs and name queries after
  `QuestieDB` initialization.
- Clear the index before every rebuild so withdrawn corrections and locale changes cannot leave stale
  names or duplicate IDs.
- Rebuild it after entity-locale changes and any Correction apply that can change Object names or the
  composed Object ID set.
- Run the rebuild through the staged coroutine or `ThreadLib` when yielding is required.
- Keep the index owned by `QuestieTooltips`; do not restore entity lookup registries or raw entity
  writes in `Localization/l10n.lua`.

### Acceptance checks

- Object-hover tooltips still show deduplicated quest/objective lines.
- The optional Object ID line preserves the current one, many, and `10+` presentation.
- Rebuilding replaces old-locale names and does not append duplicate Object IDs.
- Correction-added Objects become discoverable and withdrawn Objects disappear.
- No production code reads raw Object tables or `l10n.objectNameLookup`.

### Relevant files

- `Modules/Tooltips/Tooltip.lua`
- `Modules/Tooltips/TooltipHandler.lua`
- `Modules/Tooltips/TooltipHandler.test.lua`
- `Database/QuestieDB.lua`
- `Modules/QuestieInit.lua`
- `Localization/l10n.lua`

## Runtime missing-Item repair

**Status:** Open for the fresh QuestieTDB implementation.

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

**Status:** Open for the fresh QuestieTDB implementation.

The compiler-oriented schema files are deleted. Fresh minimal adapters must bind Database Key Enums
from `LibQuestieDB.Meta` and retain only Questie-owned constants still consumed by semantic modules,
including faction IDs, Item classes, NPC flags, race masks, class masks, quest flags, and adapter
query orders.

Current focused failures identify the first required constants:

- `QuestieDB.factionIDs` for `QuestieReputation` and Journey faction views.
- `QuestieDB.itemClasses` for tracker Item buttons.
- Quest, Item, and NPC key metadata for `QuestieDB` and retained policy tests.

The focused QuestieTDB test adapter should provide this interface without reconstructing raw entity
tables or compiler metadata.
