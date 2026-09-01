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
