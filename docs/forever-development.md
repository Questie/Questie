# Forever compatibility work

Future resilience work is tracked in [the hardening backlog](forever-hardening-backlog.md). Those proposed fallbacks are not implemented yet.

## Scope and current status

Developed against Forever `1.60.1`, builds `69893` and `69913`, interface `16001`. Forever reports `WOW_PROJECT_ID = 1`, like Retail, but uses Classic content. No season was active during these checks.

Verified in-game on a Human character:

- Database compilation and initialization complete; `Questie.started` and `Questie.API.isReady` are true.
- Quests 783 (A Threat Within) and 33 (Wolves Across the Border) load into the quest state and tracker.
- World-map and minimap icons render, including objective locations.
- Native quest-log untracking/retracking updates Questie's state correctly. The original watch type was restored after testing.
- The Tough Wolf Meat tooltip includes the quest title and `0/8 Tough Wolf Meat`.
- Reputation reward lookup succeeds without the former aura error.
- A fresh session on build `69913` completed these checks without Lua or printed Questie errors.

The later Skyborne zone/race fixes have passed local tests and review, but their post-fix in-game verification remains pending. Real combat transitions, timed quests, profession learn/unlearn, and party synchronization have not been exhaustively exercised. Do not unlearn professions or manipulate inventory merely to test compatibility.

## Compatibility boundaries

| Area | Implementation and reason |
| --- | --- |
| Content detection | `Modules/VersionCheck.lua` detects Forever using interface range `16000–16999`; `IsClassic` includes Forever. `Modules/Expansions.lua` maps only that flag to Era. Actual Retail and unknown project IDs stay unmapped. |
| Early API translations | `Modules/Compat/QuestieForever.lua` loads only through `Questie-Camelot.toc`, after `QuestieCompat.lua` and before embedded libraries. It preserves legacy contracts for quest logs, watches, completed quests, faction data, spell information, auras, mouse-over, and texture desaturation. |
| Quest acceptance | `Modules/EventHandler/EventHandler.lua` translates Forever's single quest-ID event argument into the existing index-plus-ID handler contract. A missing timer API had previously interrupted acceptance after an empty quest state was created. |
| Professions | `Modules/QuestieProfessions.lua` uses modern profession indices when skill-line APIs are absent. Sparse results preserve secondary professions; removals refresh availability through `SKILL_LINES_CHANGED`. A missing legacy hook no longer aborts the module before its constants are defined. |
| Tracker | Modern watch hooks use quest IDs and retain native watches. Classic retains its prior behavior. Modern additions are idempotent, not toggles. Namespaced watch-count functions retain their native meaning. |
| Native tracker visibility | The Camelot adapter owns suppression only while requested, defers changes during combat, and releases through Blizzard's content-aware `Update()`. Enable/disable handles Forever despite its Era content mapping. |
| Quest timers | Modern timer records are matched by quest ID without changing selected quests. The legacy adapter exposes seconds as varargs for remaining callers. |
| Tooltips | `Tooltip.lua` uses `TooltipDataProcessor` when available; Classic retains script hooks. `TooltipHandler.lua` extracts `item:<ID>` independently of color prefixes, including Forever's `|cnIQ1:`. |
| World-map buttons | `WorldMapButton.lua` corrects Krowi's `HasNoOverlay` flag on Forever. The library mistakes version `1.x` for the old Classic map and otherwise reparents Blizzard buttons to `ScrollContainer`, breaking parent `GetMapID`/`TriggerEvent` calls. Krowi's source is unchanged. |
| World-map geometry | HBD version 34 recognizes Forever as Classic map content and derives Era/Forever world transforms from native continent rectangles, with legacy fallback. See the measurements below. |

Prefer API capability checks in shared code. The Camelot-only adapter exposes legacy globals for existing consumers and embedded libraries without loading those translations on older clients. Some Forever legacy globals existed but failed internally, so presence alone was insufficient for watch count, aura, and mouse-over APIs.

Blizzard source used: Gethe's `forever` branch, commit `4d5d706b8e01c5ebe01c8dd9b7a07151d8d37069`, subject `1.60.1 (69893)`. It matched the initial client but is older than the final observed build `69913`. Runtime checks remain the authority for availability.

## New-character round: Skyborne and Forever zones

A level 1 Alliance Mage, race 95 (`Skyborne` / High Order Skyborne), exposed:

```text
No AreaId found for UiMapId: 2521:Zephras Isle
```

The failure came from the object-tooltip update path. Native `C_Map.GetAreaInfo(16593)` confirmed Zephras Isle. The DBC support export for build `69893` supplied explicit map relationships and playable-race bits.

### Zone metadata

`Database/Zones/data/Forever/zoneData.lua` is a reviewed overlay loaded only by the Camelot TOC. `ZoneDB.Initialize()` merges it without replacing authored dungeon and continent overrides.

| Zone | Area ID | Map ID |
| --- | --- | --- |
| Mount Hyjal | 616 | 2482 |
| Riverglades | 16591 | 2548 |
| Zephras Isle | 16593 | 2521 |
| Darkspear Islands | 16606 | 2524 |
| Shen'dralas | 16651 | 2652 |

The overlay also adds 65 parent relationships belonging to those zones. Existing area 2657 (Valley of Bones) belongs to Shen'dralas on Forever. Every overlaid row was checked against the source export. Other clients retain their shared mappings, including Mount Hyjal map 198.

HBD already discovers these maps, including IDs above 2500. Zephras Isle and Darkspear Islands are separate instances (2991/2997) directly under Azeroth. Native world rectangles returned all zeroes; do not invent continent/world positions for them.

### Race masks

Skyborne race IDs 95/96 use playable-race bits 32/33, with masks `4294967296` and `8589934592`. `QuestiePlayer.Initialize()` now uses those documented masks on Forever instead of `2^(raceID-1)`. Arithmetic mask checks preserve the high bits.

Only for these races on Forever, exact legacy faction-wide masks `77`/`178` follow Alliance/Horde membership. Race-specific subsets still require the actual race bit; Human-only quests are not granted to Skyborne.

### Remaining limits

- Post-fix live verification on Skyborne is pending. Confirm area 16593, the race/faction predicates, all five new maps, and their continent/world views.
- The DBC support export excludes quest/NPC/object payloads and spawn locations. It cannot supply quest pins for new zones by itself; the addon still uses the Classic entity database.
- Compiled `requiredRaces` remains `u32`. Importing quest records with high Skyborne bits requires a separate schema/cache migration. Faction aggregate constants were left unchanged to avoid overflow.

## Map navigation and coordinate validation

On build `69913`, tested five zones, both continents, and Azeroth using `WorldMapFrame:SetMapID()`, then returned to Elwynn. Screenshots were inspected at each step.

| View | Map ID | Visible Questie quest icons |
| --- | --- | --- |
| Elwynn Forest | 1429 | 32 |
| Westfall | 1436 | 1 |
| Dun Morogh | 1426 | 19 |
| Teldrassil | 1438 | 4 |
| The Barrens | 1413 | 0 |
| Eastern Kingdoms | 1415 | 52 |
| Kalimdor | 1414 | 6 |
| Azeroth | 947 | 58 |
| Return to Elwynn | 1429 | 32 |

Counts exclude minimap and townsfolk frames. The character was level 1 Alliance with unchanged availability filters. Sparse higher-level/Horde-zone icons are not evidence of missing map support. Navigation produced no Lua or printed Questie errors, but exposed a visual world-map displacement.

HBD selected Retail world transforms because Forever shares its project ID. For the same player position, Blizzard returned normalized world-map coordinates `(0.732438, 0.631989)` while HBD returned `(0.855365, 0.645588)`. The existing Classic constants produced `(0.732437, 0.631987)`.

HBD version 34 now recognizes Forever before Questie's client flags exist. Era and Forever independently derive Azeroth transforms from continent world bounds and `C_Map.GetMapRectOnMap(continent, 947)`:

- Divide continent width/height by the corresponding rectangle spans.
- Offset left/top by the rectangle minima multiplied by the derived width/height.
- Preserve valid edges outside `0..1`.
- Retain legacy bounds only when rectangles are missing or degenerate.
- Rebuild cached map data when upgrading from an older HBD version.

A live audit of three points on each of nine maps measured a maximum normalized error of `0.206976` before the fix and `7.46e-8` after a confirmed reload to version 34. Existing Classic constants differed from Forever's native rectangles by at most `2.74e-7`, consistent with rounding. Follow-up screenshots confirmed corrected pins on both continents and the world view, without Lua or printed Questie errors.

This validates geometry against Forever, not a live Era client. Era derives its own runtime values; focused tests use deliberately different geometry to verify that independence. Other expansion mapping policies remain unchanged.

## Packaging and validation

`Questie-Camelot.toc` declares interface `16001`, uses Classic entity data, and loads the Forever compatibility adapter and zone overlay. Other clients' TOCs are unchanged. Automated release packaging in `build.py` does not yet include Camelot and needs a separate change.

```bash
busted -p ".test.lua" .
luacheck -q -- Database Localization Modules Public Questie.lua
```

Keep database-content differences separate from API migrations. Continue live checks of new-quest acceptance, objective progress, turn-in, and the new starting zones.
