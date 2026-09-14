# Questie: object-hover tooltips without a Questie database scan

Implementation guide for the Questie side of
[QuestieTDB ADR 0008](https://github.com/Questie/QuestieTDB/blob/82a2d1088631c724ae8cebd936be221b7d92af41/docs/adr/0008-name-index.md).
The provider interface is available at QuestieTDB commit
`82a2d1088631c724ae8cebd936be221b7d92af41`.

This guide supersedes the earlier plan to build a complete Object-name index inside Questie by
scanning composed Object IDs after initialization and rebuilding after locale and Correction
changes.

## The shape

A hovered world object gives Questie a name and nothing else. Two different questions hide behind
that name, and they have different owners:

| Question | Source | Cost |
| --- | --- | --- |
| Which objects with this name have quest tooltip data? | `QuestieTooltips.objectIdsByName`, filled when Questie registers an `o_` tooltip | O(1) per registration; nothing at boot |
| Is this name unique across all database Objects, and which IDs carry it? This controls zone disambiguation and supplies the optional contributor-facing Object ID line. | `LibQuestieDB.Object.IdsByName(name)` | One full provider pass when the index is cold; 23 ms on Vanilla measured live |

`QuestieTooltips.GetTooltip("o_" .. id)` reads `lookupByKey`, the same table populated by the
registration functions. Indexing those registrations by name therefore gives the hover exactly the
IDs that can have quest tooltip data. The old full scan produced a superset that the hover reduced
again by calling `GetTooltip` for every matching ID.

The database-wide answer is also necessary when Object IDs are hidden. A globally unique name can
safely use tooltip data from any zone; a shared name must stay filtered to the player's zone. The
optional Object ID line uses the same answer to help contributors identify IDs for Corrections.
QuestieTDB owns that composed entity truth.

## Step 1: index `o_` registrations by name

File: `Modules/Tooltips/Tooltip.lua`

Add this next to `lookupByKey`:

```lua
---Object IDs with registered `o_` tooltip data, grouped by the Object name at registration time.
---The sets are append-only: removing all tooltip data for one ID makes `GetTooltip` return nil, so
---quest removal needs no index bookkeeping.
---@type table<string, table<ObjectId, true>>
QuestieTooltips.objectIdsByName = {}

---Indexes one Object tooltip key under its current composed name.
---@param key string Tooltip registry key.
---@return nil
local function _IndexObjectKeyByName(key)
    if key:sub(1, 2) ~= "o_" then
        return
    end

    local objectId = tonumber(key:sub(3))
    local name = objectId and LibQuestieDB.Object.name(objectId)
    if not name then
        return
    end

    local ids = QuestieTooltips.objectIdsByName[name]
    if not ids then
        ids = {}
        QuestieTooltips.objectIdsByName[name] = ids
    end
    ids[objectId] = true
end
```

Call `_IndexObjectKeyByName(key)` first in both registration functions:

```lua
function QuestieTooltips:RegisterObjectiveTooltip(questId, key, objective)
    _IndexObjectKeyByName(key)
    -- Existing registration behavior remains unchanged.
end

function QuestieTooltips:RegisterQuestStartTooltip(questId, name, starterId, key, type)
    _IndexObjectKeyByName(key)
    -- Existing registration behavior remains unchanged.
end
```

### Registration policy

- `LibQuestieDB.Object.name(id)` is one cached composed read in the active entity locale.
- Resolve the name from the key in both registration functions. `RegisterQuestStartTooltip` receives
  a name, but `RegisterObjectiveTooltip` does not; one path is easier to audit.
- Fake Object IDs for extra spawn locations group under the real Object name, matching the existing
  objective-line deduplication behavior.
- Use a set, not a list. Abandon and reaccept cycles must not duplicate IDs.
- Only `o_` keys belong in this index. `io_` is a map-icon key; an item-from-Object starter tooltip
  is registered under `o_` by Available Quests.
- Locale changes currently reload the UI, so registrations are recreated under the active locale.
  Do not add a runtime locale callback or index-clearing path now.

Accepted residual: a Dynamic Correction that renames an Object after its tooltip registration leaves
that Object's quest lines under the old name until registration happens again, normally on quest
accept or reload. No current runtime Correction renames an Object. QuestieTDB's provider-owned name
index remains correct because provider invalidation drops and rebuilds it.

## Step 2: answer the two hover questions separately

File: `Modules/Tooltips/TooltipHandler.lua`

```lua
---@param name string
---@param playerZone AreaId
---@return nil
function _QuestieTooltips.AddObjectDataToTooltip(name, playerZone)
    if (not Questie.db.profile.enableTooltips) or (not name) then
        return
    end

    -- Name ambiguity depends on every composed Object, even when the ID line is hidden.
    local ids = LibQuestieDB.Object.IdsByName(name)
    local count = ids and #ids or 0
    if Questie.db.profile.enableTooltipsObjectID then
        if count == 1 then
            GameTooltip:AddDoubleLine(l10n("Object ID"), "|cFFFFFFFF" .. ids[1] .. "|r")
        elseif count > 10 and (not Questie.db.profile.debugEnabled) then
            GameTooltip:AddDoubleLine(l10n("Object ID"), "|cFFFFFFFF" .. ids[1] .. " (10+)|r")
        elseif count > 1 then
            GameTooltip:AddDoubleLine(l10n("Object ID"), "|cFFFFFFFF" .. ids[1] .. " (" .. count .. ")|r")
        end
    end

    -- Quest lines still come only from Objects for which Questie registered tooltip data.
    local registeredIds = QuestieTooltips.objectIdsByName[name] or {}
    local zoneFilter = count == 1 and 0 or playerZone

    local addedObjects = 0
    local alreadyAddedObjectiveLines = {}
    for gameObjectId in pairs(registeredIds) do
        if addedObjects >= 10 then
            break
        end

        local tooltipData = QuestieTooltips.GetTooltip("o_" .. gameObjectId, zoneFilter)
        if tooltipData then
            for _, line in pairs(tooltipData) do
                if not alreadyAddedObjectiveLines[line] then
                    alreadyAddedObjectiveLines[line] = true
                    GameTooltip:AddLine(line)
                end
            end
            addedObjects = addedObjects + 1
        end
    end

    GameTooltip:Show()
    QuestieTooltips.lastGametooltipType = "object"
end
```

The provider lookup always runs because its count controls zone disambiguation. A unique name uses
zone filter `0`; a shared or unknown name uses `playerZone`. Only the Object ID line depends on
`enableTooltipsObjectID`. Its one, `(n)`, and `(10+)` presentation and debug-mode exception remain
unchanged. Never derive the count from `objectIdsByName`: the registration set is append-only and
answers a different question.

The quest-line loop still reads only registered IDs and preserves line deduplication and the
ten-Object cap. Because the set uses `pairs`, no test may assume which ten IDs are visited when more
than ten are registered.

Nothing in this path reads from `l10n` except the Questie-owned `"Object ID"` UI label.

## Step 3: warm the provider index where the stall is invisible

`LibQuestieDB.Object.IdsByName` builds its provider-owned index on first use. QuestieTDB drops the
index after Object Corrections, locale changes, and explicit Object cache invalidation, then rebuilds
it from scratch on the next lookup. This prevents stale names and duplicate IDs by construction.

The measured cold build is 23 ms for Vanilla's 6,666 Objects, approximately 3.5 microseconds per ID,
with about 2.2 MB retained for the warmed name cache and index. Mists has roughly three times as many
Objects and remains unmeasured.

### During initialization

File: `Modules/QuestieInit.lua`, Stage 2, after Questie's owner Corrections were applied during
Stage 1:

```lua
-- Object tooltips need database-wide name uniqueness even when Object IDs are hidden.
LibQuestieDB.Object.BuildNameIndex()
```

Stage 2 always warms the index after Stage 1 has established the locale and applied Questie's policy
Corrections. The call is synchronous and cannot yield. Do not recreate the old coroutine-based
Questie scan.

### When enabling the Object ID setting

File: `Modules/Options/AdvancedTab/QuestieOptionsAdvanced.lua`:

```lua
set = function(_, value)
    Questie.db.profile.enableTooltipsObjectID = value
    if value then
        LibQuestieDB.Object.BuildNameIndex()
    end
end
```

Turning the option off does not discard the index. QuestieTDB owns invalidation.

Accepted residual: the first hover after a later Object Correction apply or runtime locale change
may synchronously rebuild the provider index once. If measurements later show that hitch matters,
rewarm after Questie's own apply and from `LibQuestieDB.l10n.onLocaleChanged`. Do not add those
callbacks preemptively.

## Step 4: remove the legacy index completely

The implementation must leave:

- no `l10n.objectNameLookup`;
- no `QuestieTooltips.objectNameLookup`;
- no Questie-side full scan over composed Object IDs;
- no coroutine Object-name-index rebuild;
- no raw Object-table reads.

`Localization/l10n.lua` remains limited to Questie-owned UI strings and UI locale selection.

## Tests

### `Modules/Tooltips/TooltipHandler.test.lua`

- Quest-line cases seed `QuestieTooltips.objectIdsByName` sets and stub
  `LibQuestieDB.Object.IdsByName`, which is called regardless of the Object ID setting.
- Verify a provider-wide unique name passes zone filter `0`, while a shared name passes the player's
  zone with Object IDs both enabled and disabled.
- Object ID cases use the exact ascending provider result for one ID, two IDs, and eleven IDs.
- Reset `Questie.db.profile.enableTooltipsObjectID = false` in `before_each` so ID-line behavior does
  not leak between tests.
- For the `10+` quest-line cap, seed eleven IDs and assert ten calls. Do not assert that a particular
  ID was skipped because set iteration order is undefined.
- Remove any legacy `objectNameLookup` fixture setup. Keep `l10n` only for the translated
  `"Object ID"` label.

### `Modules/Tooltips/Tooltip.test.lua`

Add focused registration-index tests:

- Registering `"o_5"` through `RegisterObjectiveTooltip` adds ID `5` under the name returned by
  `LibQuestieDB.Object.name(5)`.
- Registering the same Object key for another quest does not duplicate the ID.
- `i_`, `m_`, and other non-`o_` keys add nothing.
- Cover `RegisterQuestStartTooltip` indexing through the same helper where useful without duplicating
  every registration assertion.

There is no removal test because the registration index is intentionally append-only.

QuestieTDB owns tests proving that `IdsByName`:

- equals composed reads;
- returns ascending shared read-only buckets;
- follows locale and Corrections;
- discovers Correction-added entities;
- drops withdrawn entities;
- rebuilds after invalidation;
- behaves equivalently in Source and Baked modes.

## Acceptance

- Object-hover tooltips still show deduplicated quest and objective lines from registered IDs only.
- The provider-wide result controls zone disambiguation regardless of the Object ID setting.
- The optional Object ID line preserves one, `(n)`, `(10+)`, and debug-mode presentation.
- The provider index is always warmed in Stage 2 after locale and policy setup, and is also warmed
  when the Object ID setting is toggled on.
- `objectIdsByName` cannot accumulate duplicate IDs.
- Locale reload recreates the registration index under the active locale.
- Provider invalidation keeps the database-wide name answer current.
- No production code reads raw Object tables, `l10n.objectNameLookup`, or
  `QuestieTooltips.objectNameLookup`.

## Provider and integration evidence

- QuestieTDB ADR 0008: the provider ADR linked at the top of this guide.
- Feature commit: `82a2d1088631c724ae8cebd936be221b7d92af41`.
- Public Object interface:
  - `LibQuestieDB.Object.name(id)`
  - `LibQuestieDB.Object.IdsByName(name)`
  - `LibQuestieDB.Object.BuildNameIndex()`

This feature commit proves the interface exists, but it is not automatically the final provider
revision pinned by the combined integration branch.
