# Area C: quest drawing integration and removing the old line model

Owner: Area C. Scope: how blob draws objective routes and fallback markers on top of waypoints' route model, removing every remnant of the old line model from blob, and the rebase recipe for `QuestieFrame.lua`, `QuestieFramePool.lua`, `QuestieMap.lua`, `QuestieQuest.lua` and `TrackerUtils.lua`.

This is the second version, aligned with David's architecture (`01-architecture.md`) and Area F's seams (`F-seams.md`, §10 "C"). The first version is in commit `e71e6dd38`. C's commits are called **C-F1** and **C-F2** here, to keep them apart from F's F-1 to F-7.

`WP` = `origin/waypoints` (`7c1e28bd8`), `B` = `blob` (`715031ef6`). Line numbers were checked against those commits. "Stop #n" is the README's numbering of blob's commits.

**In short**
- WP's registry (`QuestieWaypoints`) becomes the only route model. A route lives exactly as long as its owner's world map icon stays loaded with the same data. QuestiePolygon never tracks routes. It only decides which of its markers owns each patrol, and which of a marker's minimap icons is its `minimapTwin`.
- **The features stay black boxes (architecture rules 1 and 3).**
  - QuestiePolygon hands routes to core, never to waypoints: `QuestieMap:DrawWaypoints` with its marker as the owner, and the `minimapTwin` field of the IconFrame contract (F 3.5).
  - Routes follow their owner through `QuestieFrame`'s icon events, which `QuestieWaypoints` subscribes to (F-3).
  - C adds no import between features and no core entry point, so F-6's guard stays green.
- **The rebase (Phase 1) is unchanged.** It does only what keeps every replayed commit loadable, lint-clean, test-green and free of runtime nil calls. It ports one `DrawWaypoints` call, links twins for paired draws, uses `SetSolo` in the tracker flash, and drops the line-model pieces (one commit, `d9dc1ca4d`, disappears entirely). §4(a) confirms this against F §4a.
- **Two follow-up commits finish the design.** They come after F-1 to F-6, in README Group 3:
  - **C-F1** moves blob-mode route attachment into QuestiePolygon and deletes the token API (`IsCurrentObjective`, `OwnWaypointMarker`, `PolygonObjectiveWork`, `_FallbackIconData`). It also applies **decision C-5**, which is still pending with David. The recommended rule gives each patrol to the cluster its NPC spawns in, falling back to the zone's marker; the alternative, the zone's last marker, is in §3.
  - **C-F2** links polygon markers to minimap twins, so blob mode gets minimap routes like normal mode.
- **Validation in a scratch tree** (built from `git archive` and `git merge-file`; no repository state was touched):
  - First round: the simulated post-rebase state and the `dfb97c802` stop pass all affected suites, and luacheck reports nothing. The C-F1 + C-F2 prototype passes the same suites, and each new test was mutation-checked.
  - This round: `_RouteOwner` and its test were added to that prototype. `QuestiePolygon` 88, `QuestieQuest` 44, `TrackerUtils` 58, `QuestieMap` 10, `QuestieFrame` 56, `QuestFinisher` 14, `AvailableQuests` 87 and `Modules/Map/Waypoints` 91 pass, and luacheck is clean. The new test fails under the zone's-last-marker rule, and under A §9's instance-only check.
  - C's `QuestiePolygon.lua` diff applies to F's F-2 prototype of that file with line offsets only.

---

## 1. Problem

### What each branch does today

**Route model, WP.** These are the facts the design relies on:
- **`QuestieWaypoints.Add(owner, entity, patrols, areaId, hostile)`** (`WP QuestieWaypoints.lua:58-79`):
  - Builds polylines.
  - Records each path in `pathsByOwner[owner]`, the per-owner release list.
  - Records each path in `owner.data.waypointPaths`, the per-data highlight list (`:65-68`).
  - Gives each path the route key `entity..":"..areaId..":"..i`. Copies with the same key draw once (`WP WaypointMap.lua:62-77`, `WaypointMinimap.lua:217-240`).
- **`RemoveOwner(owner)`** (`:83-102`): releases exactly that owner's paths. It is idempotent, and `_QuestieFrame.Unload` calls it during the real unload, after the `_loaded` deferral check (`WP QuestieFrame.lua:349-353, 384-386`).
- **Visibility is per owner, not per data:**
  - `_IsOwned(path)` requires `path.owner.data == path.data` (`:116-118`), so a pooled frame that now shows something else no longer draws the path.
  - World map: `WorldMapAlpha` checks the owner's `hidden` and `faded` and `SetSolo` (`:123-128`).
  - Minimap: `MinimapAlpha` requires `owner.minimapTwin` with `twin.data == path.data`, not hidden (`:134-140`).
- **Who links twins.** Paired draws link `minimapTwin` in `DrawWorldIcon` and `DrawManualIcon` (`WP QuestieMap.lua:690, 592`). `_ReinitFrame` and `Unload` clear it (`WP QuestieFramePool.lua:134`, `WP QuestieFrame.lua:386`).
- **Owner state changes.** `FakeHide`, `FakeShow`, `FadeOut` and `FadeIn` call `QuestieWaypoints.OwnerChanged` (`WP QuestieFrame.lua:410, 422, 441, 457`). `ResetHoverHighlights` calls `SetHighlighted(self.data, false)` (`:156`). The tooltip calls `SetHighlighted(self.data, true)` (`WP MapIconTooltip.lua:117`). F 1.2 lists every such direct call; F-3 and F-4 turn them into icon events.
- **Tracker flash.** It shows only the flashed data's paths through `QuestieWaypoints.SetSolo(dataSet)` (`WP TrackerUtils.lua:206-226, 269, 284-311, 355`).
- **Hostile color.** It is the `waypointHostileColor` profile setting, default `{1, 0.2, 0, 0.7}` (`WP QuestieOptionsDefaults.lua`, migration `[42]`). The color picker "Hostile patrol color" sits under Map → Waypoints (`WP QuestieOptionsMap.lua:130-138`). `QuestieWaypoints.Color` applies it to paths whose `hostile` flag is set (`:167-173`).
- **Callers.** `DrawWaypoints(icon, entity, waypoints, zone, hostile)` (`WP QuestieMap.lua:728-732`) is called by:
  - `ShowNPC`/`ShowObject` (`:447, :513`, entity `"m_"/"o_"..id`);
  - `AvailableQuests.lua:838` and `QuestFinisher.lua:146` (entity = tooltip key);
  - `QuestieQuest.lua:1343` (`spawnData.TooltipKey`, `spawnData.Hostile`).
- **Route owner in normal mode.** `_DrawObjectiveIcons` overwrites `iconPerZone[icon.zone]` with each icon it draws (`WP QuestieQuest.lua:1255`, `:1275`), and `_DrawObjectiveWaypoints` draws every patrol of the zone for that last icon (`:1340-1343`). So all of an objective's patrols in a zone belong to its last-drawn icon there.

**Route model, B (the old line model plus blob's ownership layer):**
- `QuestieFramePool:CreateWaypoints`/`CreateLine` make one mouse-enabled Button per segment and store it in `iconFrame.data.lineFrames` (`B QuestieFramePool.lua:122-342`, `WAYPOINT_COLOR` at `:21`).
- `IsLineFrame` and its registry (`:150-160`) exist only so polygon hover can treat a line as bare map (`B QuestiePolygon.lua:998-1001`).
- `DrawLineIcon` registers lines with HBD (`B QuestieMap.lua:527-540`). `DrawWaypoints(icon, waypoints, zone, color)` (`:745-756`) uses `zoneWaypoint(Hover)ColorOverrides` (`:735-743`).
- `QuestieFrame` walks `data.lineFrames` in `ResetHoverHighlights`, `Unload`, `FadeOut`, `FadeIn`, `FakeHide` and `FakeShow` (`B QuestieFrame.lua:157-162, 398-403, 428-435, 448-455, 469-473, 495-499`).
- The tracker flash hides and shows `data.lineFrames` by hand, then forces `HBDPins.worldmapProvider:RefreshAllData()` to restore their zone-aware visibility (`B TrackerUtils.lua:208-212, 230-235, 286-289, 313-317, 375-377`).
- `MapIconTooltip` colors `self.data.lineFrames` with `zoneWaypointHoverColorOverrides` (`B MapIconTooltip.lua:109-113`; these are master's lines that blob never touched).
- Blob mode draws routes from `QuestieQuest._DrawObjectiveWaypoints(objective, icon, iconPerZone, waypointWork)` (`B QuestieQuest.lua:1352-1410`):
  - `QuestiePolygon.UpdateObjective` returns the last-drawn cluster's data, an `iconPerZone` table and a `PolygonObjectiveWork` token (`B QuestiePolygon.lua:1022-1065`).
  - Fallback markers are drawn twice, once per destination, each with its own `_FallbackIconData` copy (`B QuestieQuest.lua:1340-1350, 1372-1377`). `OwnWaypointMarker` adopts them (`B QuestiePolygon.lua:748-770`).
  - Routes draw only when the zone owner's `polygonMarker.entry == waypointWork.entry` (`B QuestieQuest.lua:1389-1397`).
  - The call passes the hardcoded hostile color `{1, 0.2, 0, 0.7}` (`:1395`).
  - Staleness is the token's captured generation (`IsCurrentObjective`, `B QuestiePolygon.lua:738-746`). It is checked before each zone and after each yield.
- `DrawWorldIcon(data, areaID, x, y, phase, showFlag, destination)` can draw only the map icon or only the minimap icon (`B QuestieMap.lua:649-733`). Cluster markers use that: one map marker plus one minimap icon per site (`B QuestiePolygon.lua:1029-1046`).

### Where they collide and what breaks

1. **Signature (finding 2).**
   - `B QuestieQuest.lua:1395` calls the 4-argument form. On WP the arguments shift: `waypoints` becomes the entity, `zone` becomes the patrols and the color table becomes the area. Blob-mode routes either error or draw nothing.
   - `B QuestieMap.lua:455, 521` are untouched master lines. The rebase takes WP's version automatically, so they need no port.
2. **Line model leftovers (findings 3, 12, 13).** Every `lineFrames`, `CreateLine`, `IsLineFrame`, `DrawLineIcon` and `zoneWaypoint*` reference is a nil access on WP:
   - `IsLineFrame` is called on every hover frame (finding 1).
   - `TrackerUtils` would call `HBDPins.worldmapProvider`, but WP deleted the `HBDPins` local in that file, so that is an undefined global (README N8).
   - Blob's `QuestieFramePool.test.lua` tests only `CreateLine`/`IsLineFrame`.
   - The combat motion driver (`d9dc1ca4d`) exists only for line frames. It is already gone at `B` HEAD: `53b5e7ce4` removed it.
3. **Twins (finding 4).**
   - After blob's `DrawWorldIcon` refactor, a careless resolution drops WP's `iconMap.minimapTwin = iconMinimap`. Normal-mode minimap routes would then silently disappear; no existing test covers this.
   - Blob-mode markers never get a twin, so blob-mode routes cannot reach the minimap.
4. **Fallback copies (finding 5).** `_FallbackIconData` copies everything except `lineFrames`.
   - On WP it would copy the cluster's `waypointPaths` list reference. The fallback's paths would then be appended into the cluster's list, which is aliased highlighting.
   - The copy's original reason is gone: "hiding an icon hides its data's lines" no longer holds, because WP's visibility is per owner.
   - Separately, the copy shows the last-drawn cluster's NPC, not the NPC that patrols that zone.
5. **Route owner in blob mode (README C-5).** Blob keeps normal mode's rule: the zone's last marker owns every patrol there (`B QuestiePolygon.lua:1035`, `B QuestieQuest.lua:1390-1395`).
   - A normal icon stands for one spawn, but a cluster marker stands for an area.
   - In a zone with several clusters, hovering a patrol therefore outlines and previews whichever cluster was drawn last, which may not be the one the NPC is in.
   - Hovering the NPC's own cluster doesn't highlight its route.

---

## 2. Comparison

| | Old line model + blob ownership (B) | Registry model (WP) |
|---|---|---|
| Lifetime | Lines live in `data.lineFrames`. Any icon sharing that data hides or unloads them, which is why blob copies data. | Paths are keyed by owner frame (`pathsByOwner`). Release happens once, from the owner's real `Unload`. Data only carries the highlight list. |
| Recycled frames | Blob guards with generation tokens and `marker.entry` checks at the call site. | `_IsOwned` (`owner.data == path.data`) hides paths of a frame drawn for something else. A double `RemoveOwner` is harmless. |
| Mouse/combat | Lines are mouse-enabled. This needed `SetPropagateMouseMotion`, a combat deferral driver and `IsLineFrame`. | Paths take no mouse input. They need no protected API, and hover is computed from the cursor (after F-1, `WorldMapLayers` offers it). |
| Minimap | None. | Follows the owner's `minimapTwin`. |
| Styling | Hardcoded hostile color, `global.iconFadeLevel` (which has no default), zoom-thickening lines. | Profile settings and a hostile flag, `profile.iconFadeLevel`, constant on-screen width. |
| Dedupe | None. Each copy draws, and they stack darker. | One draw per route key (entity, area, part). |
| Tracker flash | Raw hide and show of lines, then a forced HBD refresh. | `SetSolo(dataSet)`. |
| Route owner | The zone's last cluster marker. | The zone's last icon. |

**Keep from blob:**
- Generation-based staleness for route work: progress-only updates must not cancel an in-flight route batch (`B QuestiePolygon.lua:976-980`, README "Generation").
- "No routes on a released marker's icon" (the `marker.entry` check).
- `DrawWorldIcon`'s `destination` split, because cluster markers need one map marker and N minimap icons at different positions.
- The recycled-frame checks in `UnloadQuestFrames` (`83ef6e2fe`) and in the tracker flash (`frame.data == flashData[frame]`).
- Each cluster's `worldBounds`, already used by nearby mode (`B QuestiePolygon.lua:618-630`), to find the cluster an NPC spawns in.

**Keep from WP:** everything that is route-related. No blob route code survives except the ownership decisions.

**Drop:**
- `_FallbackIconData`, because its premise is gone.
- The token API, which leaks marker internals into QuestieQuest.
- All line-model code and tests.
- In blob mode, the per-zone owner (C-5, recommended).

---

## 3. Target design

### Ownership

| Module | Owns | Changes |
|---|---|---|
| `QuestieWaypoints` (WP) | Paths: registry, release, visibility, color, highlight, solo. It follows owners through icon events. | None from C. F-3, F-4 and F-5 change it. |
| `QuestieMap` | `DrawWaypoints` (WP); `DrawWorldIcon` with blob's `destination`, linking `minimapTwin` only when one call draws both icons. | Rebase resolution; the `destination` doc in C-F2. |
| `QuestieFrame` | The icon lifecycle. It emits icon events (`Unload`, `VisibilityChanged`, `HoverStart`, `HoverEnd`, `Click`); `QuestieWaypoints` and `QuestiePolygon` subscribe (Area F, F-3). It holds the IconFrame contract (F 3.5). | Rebase resolution (R1, R3). Then F-3 and F-4. |
| `QuestiePolygon` | Markers and their minimap icons, plus **the marker that owns each patrol (C-5), route markers, and each marker's minimap twin**. It follows its markers through its icon-event listeners (F-3). | C-F1, C-F2. |
| `QuestieQuest` | Normal-mode objective icons and routes (WP's `_DrawObjectiveWaypoints` text verbatim). In blob mode it only calls `QuestiePolygon.UpdateObjective`, through its blob-mode entry point (F 3.6). | C-F1. |
| `TrackerUtils` | The flash: polygon markers plus `AlreadySpawned` map refs, with `SetSolo` over their data. It reaches the features only at its Show on Map entry points (F 3.6). | Rebase resolution. |
| `QuestieFramePool` | WP's version: frame pool, no lines. | Rebase resolution. |

**Seams C uses, and adds none of:**
- **The route path.** `QuestiePolygon` → `QuestieMap:DrawWaypoints` (core) → `QuestieWaypoints.Add`. QuestiePolygon imports only core and its own modules (`QuestieMap`, `QuestieFramePool`, `ZoneDB`, `MapIconTooltip` and so on, checked in the prototype). So the guard (F 3.7) has nothing to report.
- **The twin.** `minimapTwin` is the IconFrame contract's one field that a drawing feature writes, on its own markers only (F 3.5; see §10, item 1).
- **Following owners.** `Unload` releases routes (`QuestieWaypoints.RemoveOwner`), and `VisibilityChanged` restyles them (`OwnerChanged`). `HoverStart` and `HoverEnd` highlight them. C calls none of these.

### Public interface after C-F1 and C-F2

```lua
-- QuestieMap (unchanged from the rebase resolution)
---@param destination? "map"|"minimap" Omit to draw both; only a pair links minimapTwin. Polygon markers draw each map's icons separately.
---@return IconFrame?, IconFrame?
function QuestieMap:DrawWorldIcon(data, areaID, x, y, phase, showFlag, destination) end
---@param entity string? Tooltip key of whose patrols these are ("m_<npcId>"/"o_<objectId>"); copies with one key draw once.
---@param hostile boolean? The NPC is fought; takes profile.waypointHostileColor.
function QuestieMap:DrawWaypoints(icon, entity, waypoints, zone, hostile) end   -- WP, verbatim

-- QuestiePolygon: the waypoint-specific surface shrinks to nothing.
---Builds or refreshes the objective's cluster markers and attaches its routes to them.
---@async
function QuestiePolygon.UpdateObjective(quest, objective, objectiveIndex) end   -- returns nothing now
-- deleted: QuestiePolygon.IsCurrentObjective, QuestiePolygon.OwnWaypointMarker, ---@class PolygonObjectiveWork
-- kept:    QuestiePolygon.GetObjectiveMarkers (the tracker's Show on Map entry point, F 3.6);
--          MarkerRemoved, MinimapMarkerRemoved, MarkerChanged (QuestiePolygon's icon-event listeners, F-3)
```

**`IconFrame.minimapTwin`:** see F 3.5, the IconFrame contract. F-3 writes that doc, which already names this case: "Linked by QuestieMap for icons drawn as a pair and by a drawing feature for its markers". C-F2 is that drawing feature. QuestiePolygon links a marker to the minimap icon drawn with the marker's own data table, and to nothing else.

### Internals added to QuestiePolygon (C-F1; the C-F2 lines are marked)

These were prototyped and validated in the scratch tree. They go right before `UpdateObjective`, after `_IconData`.

```lua
-- Objective routes
-- Each patrol of an objective's NPCs belongs to one of the objective's markers in its zone: the
-- cluster the NPC spawns in, so hovering either shows the other, else the zone's last marker.
-- QuestieWaypoints shows, fades and releases it with that marker's map icon. A zone only patrols
-- reach gets a route marker of its own, showing the patrolling NPC. Progress updates keep the
-- markers, and with them their routes.

---Allocation and route attachment stop once their markers are replaced or the objective is gone.
---Progress updates keep the generation, so they never stop attaching routes.
---@param entry PolygonObjectiveEntry
---@param generation number Marker generation the work started with.
---@return boolean
local function _IsCurrentGeneration(entry, generation)
    return entry.active and entry.generation == generation and QuestiePolygon.IsEnabled()
        and not entry.objective.Completed and QuestiePlayer.currentQuestlog[entry.quest.Id] == entry.quest
end

---Draws one of a marker's minimap icons.
---@param point table? Spawn point the icon shows; nil for a route marker's.
local function _DrawMinimapIcon(marker, data, point, areaId, x, y)
    local _, minimapFrame = QuestieMap:DrawWorldIcon(data, areaId, x, y, nil, nil, "minimap")
    if not minimapFrame then return end
    -- C-F2: the icon showing the marker's own data is its minimap twin, so the marker's routes show
    -- on the minimap while it does (QuestieWaypoints.MinimapAlpha needs twin.data == path.data).
    if data == marker.frame.data then marker.frame.minimapTwin = minimapFrame end
    minimapFrame.polygonMinimapMarker = marker
    marker.minimapIcons[#marker.minimapIcons + 1] = {frame = minimapFrame, point = point}
end

---Draws a marker on both maps for a zone only the objective's patrols reach.
---@param spawnData table The patrolling NPC.
---@param x number The patrol's first point in the zone, in percent.
---@return PolygonMarker? marker nil when the zone has no map.
local function _DrawRouteMarker(entry, spawnData, areaId, x, y)
    local data = _IconData(entry.quest, entry.objective, entry.index, spawnData)
    local frame = QuestieMap:DrawWorldIcon(data, areaId, x, y, nil, nil, "map")
    if not frame then return nil end
    local marker = {frame = frame, entry = entry, minimapIcons = {}}
    frame.polygonMarker = marker
    entry.markers[#entry.markers + 1] = marker
    _DrawMinimapIcon(marker, data, nil, areaId, x, y)
    return marker
end

---The marker whose cluster holds one of the NPC's spawns in the patrol's zone, so hovering the patrol
---outlines the area the NPC is in. Clusters are told apart by their spawn extent, as for nearby mode.
---@param entry PolygonObjectiveEntry
---@param spawnData table The patrolling NPC.
---@param areaId AreaId The patrol's zone.
---@return PolygonMarker? marker nil when no cluster in that zone holds a spawn of the NPC.
local function _RouteOwner(entry, spawnData, areaId)
    local uiMapId = ZoneDB:GetUiMapIdByAreaId(areaId)
    local spawns = uiMapId and spawnData.Spawns and spawnData.Spawns[areaId]
    if not spawns then return nil end
    for _, spawn in ipairs(spawns) do
        local x, y = HBD:GetWorldCoordinatesFromZone(spawn[1] / 100, spawn[2] / 100, uiMapId)
        for _, marker in ipairs(entry.markers) do
            local cluster = marker.cluster
            local bounds = cluster and cluster.worldBounds
            -- World coordinates span the continent: a neighbouring zone's cluster may cover the spot.
            if x and y and bounds and cluster.uiMapId == uiMapId and x >= bounds.minX and x <= bounds.maxX
                and y >= bounds.minY and y <= bounds.maxY then
                return marker
            end
        end
    end
    return nil
end

---Draws each of the objective's patrols for a marker in its zone, adding route markers where no
---cluster is. Without any marker nothing is drawn, as in normal mode.
---@async
---@param zoneMarkers table<AreaId, PolygonMarker> Markers just drawn; the last one of each zone, which owns patrols no cluster holds.
local function _AttachRoutes(entry, zoneMarkers)
    if not next(zoneMarkers) then return end
    local generation, attached = entry.generation, 0
    for _, spawnData in pairs(entry.objective.spawnList or {}) do
        for areaId, patrols in pairs(spawnData.Waypoints or {}) do
            local first = patrols[1] and patrols[1][1]
            if first then
                local marker = _RouteOwner(entry, spawnData, areaId) or zoneMarkers[areaId]
                -- -1, -1 stands for an instance, which has no point on the zone's map.
                if not marker and first[1] ~= -1 and first[2] ~= -1 then
                    marker = _DrawRouteMarker(entry, spawnData, areaId, first[1], first[2])
                    zoneMarkers[areaId] = marker
                end
                -- A marker Questie removed meanwhile may have handed its icon to another quest.
                if marker and marker.frame.polygonMarker == marker then
                    QuestieMap:DrawWaypoints(marker.frame, spawnData.TooltipKey, patrols, areaId, spawnData.Hostile)
                end
                attached = attached + 1
                if attached >= 30 then -- Area E owns this budget (see contracts).
                    attached = 0
                    coroutine.yield()
                    if not _IsCurrentGeneration(entry, generation) then return end
                end
            end
        end
    end
    QuestiePolygon.ScheduleNudging()
end
```

`ZoneDB` and `HBD` are already imported (`B QuestiePolygon.lua:61-66`).

**Changes inside `UpdateObjective`:**
- The allocation keeps `zoneMarkers[point.areaId] = marker` instead of `icon`/`iconPerZone`.
- Each site calls `_DrawMinimapIcon(marker, siteData, site, site.areaId, x, y)`.
- C-F2 sets `siteData = site == point and data or _IconData(...)`, so the minimap icon of the marker's own spawn shares the marker's data. For an object cluster, `locations[1]` is the representative and therefore `point`.
- Every `return nil, {}` and token return becomes a bare `return`, and the function ends with `_AttachRoutes(entry, zoneMarkers)`.
- The generation bump comment becomes "stops earlier route attachment before its marker frames can be recycled".
- **Leave alone:** the provider block. It holds F-2's areas layer and F-3's `_FollowIcons()` call.

### Decision C-5: who owns a patrol in blob mode

This is pending with David (README C-5). A (D8) and F (§10, C.4) both recommend the first rule. C plans it as the default and keeps the second as a documented alternative.

**Recommended: the cluster holding the patrolling NPC's spawn, falling back to the zone's marker.** This is `_RouteOwner` above.
- **What the player gets.** Hovering a patrol outlines and previews the cluster the NPC is in, and hovering that cluster's marker highlights the patrol. With several clusters in a zone, the per-zone rule can send both to an unrelated cluster. That happens for 54 patrols in 39 Classic quests, some over a mile away (q813 in Durotar, q313 in Dun Morogh; §7 check 4).
- **What it costs:** one local function of about 20 lines and one changed line in `_AttachRoutes`. There is no new state, and no hover code changes. It reads only clusters QuestiePolygon keeps anyway, through the same bounds nearby mode reads (`B QuestiePolygon.lua:618-630`; built at `B PolygonGeometry.lua:420-447`).
- **The rules it follows:**
  - **Only clusters on the patrol's zone map count** (`cluster.uiMapId == uiMapId`). World coordinates span a continent, so a neighbouring zone's cluster extent can reach over a spawn near the border. A §9's sketch compared only the instance. The map check implies the instance, and keeps the owner on the map the patrol is drawn on, as `zoneMarkers[areaId]` does.
  - **Extents are bounding boxes.** Where two clusters' boxes overlap, the first marker drawn wins. A spawn hidden by phase isn't a cluster member, but may still fall inside a box; then that cluster owns the patrol. Both cases are coarse, like nearby mode, and never pick another zone's or another objective's marker.
  - **One marker per NPC and zone.** All of one NPC's patrols in a zone go to one marker, as in normal mode, because `DrawWaypoints` takes a zone's patrols in one call.
  - **The fallback is unchanged.** A patrol whose NPC has no spawn in any of the zone's clusters goes to the zone's last marker, or gets a route marker. That covers a patrol into a neighbouring zone, such as Astor Hadren's into Tirisfal.
- **Normal mode keeps WP's per-zone rule.** C-F1 restores WP's text verbatim, and a normal icon stands for one spawn (R10).

**Alternative: the zone's last marker** (normal mode's rule, C's first version). If David picks it, drop exactly these, and nothing else changes:
1. `_RouteOwner`, its doc comment included, from C-F1's QuestiePolygon section.
2. In `_AttachRoutes`, `_RouteOwner(entry, spawnData, areaId) or zoneMarkers[areaId]` becomes `zoneMarkers[areaId]`. The `zoneMarkers` doc drops ", which owns patrols no cluster holds".
3. In the section comment, "the cluster the NPC spawns in, so hovering either shows the other, else the zone's last marker" becomes "the zone's last marker".
4. The test *attaches a patrol to the cluster holding its NPC's spawn in the patrol's zone* (§5).
5. In the `Polygon/README.md:16` wording (§6), the clause "the cluster the NPC spawns in, else the zone's marker" becomes "the zone's last marker". In `docs/waypoints.md:278` it goes the same way.
6. In-game check 4 (§7). R1 (§8) then reads "all patrols in a zone attach to that zone's last marker; accept for parity with normal mode".

### Data flow (blob mode)

```
PopulateObjective ──► QuestiePolygon.UpdateObjective
   ├─ progress-only (cache hit): _RefreshMarkers → return     (markers, data tables and routes untouched)
   └─ new geometry: generation+1 → _ReleaseMarkers(entry)     (each UnloadFrame → Unload event → QuestieWaypoints.RemoveOwner: old routes gone)
        → allocate cluster markers (+ minimap icons; C-F2: first one = twin, shares data)
        → publish (building=nil, signature) → _AttachRoutes
              per spawnData × waypoint zone: _RouteOwner (the cluster holding the NPC's spawn; C-5)
                                             or the zone's last marker, or _DrawRouteMarker (NPC's own data; C-F2: twin)
              → QuestieMap:DrawWaypoints(marker.frame, spawnData.TooltipKey, patrols, zone, spawnData.Hostile)
              → QuestieWaypoints.Add (owner = marker.frame, data = marker.frame.data)

Hovering a route → WaypointHover → the owner's OnEnter (_QuestieFrame.OnEnter, F-4)
   → HoverStart: QuestieWaypoints highlights the routes, QuestiePolygon.EnterMarker previews the marker's areas
```

### Invariants

1. **One owner, released once.** Every route has exactly one owner frame. Every way a polygon marker goes away unloads that frame, and the `Unload` icon event then releases its routes. That event fires at once, and for a queued frame again as the draw queue finishes it (F 3.3 guarantee 3).
   - Re-cluster, `RemoveObjective`, `RemoveQuest` and `Reset` go through `_ReleaseMarkers`. It clears `polygonMarker` first, then calls `QuestieFramePool:UnloadFrame(marker.frame)`.
   - Questie's own lifecycle goes through the `Unload` event too: polygon's listener runs `MarkerRemoved` and `MinimapMarkerRemoved`, and waypoints' runs `RemoveOwner`.
   - A still-queued frame finishes its unload in `ProcessQueue` (`WP QuestieMap.lua:359-362`, `:372-375`). Both listeners run at both calls and are idempotent, so routes attached to a queued marker meanwhile go with it.
   - Quest removal (`UnloadQuestFrames` → `RemoveQuest` first, `B QuestieMap.lua:99-101`) then skips already-released frames by its data snapshot (`83ef6e2fe`).
2. **Routes only go to live markers.** Routes are attached only to markers of the current entry generation, and only to markers still owning their frame (`marker.frame.polygonMarker == marker`).
   - `_IsCurrentGeneration` runs after every yield, and nothing in between can invalidate it.
   - `_RouteOwner` picks only from `entry.markers`, the current generation's markers.
   - "Routes drawn only for that entry's markers" therefore holds by construction, instead of through a cross-module check.
3. **QuestiePolygon keeps no route state.** Progress-only updates keep `frame.data` table identity: `_RefreshMarkers` mutates fields in place, the twin's shared table included (`B QuestiePolygon.lua:821-865`). `waypointPaths` and `_IsOwned` therefore stay valid without any route bookkeeping in QuestiePolygon. This is the IconFrame contract's "data refreshed in place" (F 3.5).
4. **Twin rule.** A marker's `minimapTwin` is the minimap icon drawn with the marker's own data table (C-F2), so `MinimapAlpha`'s `twin.data == path.data` holds. A stale twin, left after its minimap icon is unloaded alone, fails that check and draws nothing, as the contract says.
5. **Polygon never names waypoints.** QuestiePolygon imports no waypoints module and calls no `QuestieWaypoints` function. It hands routes to core and links twins through the contract field. F-6's guard enforces the import half.

### Why this holds up

- **Locality.** Route ownership bugs live in one ~80-line section of QuestiePolygon. QuestieQuest's normal mode becomes byte-identical to WP's, which shrinks the master diff and the conflict surface for later rebases.
- **Leverage.** One rule (owner frame plus twin) covers normal icons, manual notes, cluster markers and route markers. A new marker kind, or a future drawing module, only needs to call `QuestieMap:DrawWaypoints` with a frame it owns and link its own twin.
- **No speculative pieces.** There is no new module, no new public function, no new setting, no new seam and no new entry point. C-5 is one local function.

### Rejected alternatives

| Alternative | Why rejected |
|---|---|
| Keep blob's QuestieQuest loop and tokens and port only the call (Option A). | The interface stays shallow and leaky: QuestieQuest reads `polygonMarker.entry` and `waypointWork.entry`, and `IsCurrentObjective` and `OwnWaypointMarker` exist only for it. This is fine as the rebase state, but not as the target. |
| Fallback marker with a `_FallbackIconData` copy, or sharing the cluster's data. | Its premise (lines on data) is gone. It shows the wrong NPC, and sharing aliases highlights. |
| Route marker drawn as a pair so `QuestieMap` links the twin. | That gives two twin-linking paths for polygon markers. One helper (`_DrawMinimapIcon`) covers clusters and route markers, and it keeps the test stubs simple. |
| Replace `destination` with `DrawWorldMapIcon`/`DrawMinimapIcon`, or add a `twinOf` parameter. | It adds interface for the same behavior. `destination` is already the seam for split drawing. |
| QuestieWaypoints finds twins by data. | That needs a reverse index of minimap icons. WP deliberately chose an explicit twin. |
| QuestiePolygon calls `QuestieWaypoints.Add` directly. | Rule 1: features never import each other. Core's `QuestieMap:DrawWaypoints` is the way in. |
| A separate `Polygon/PolygonRoutes.lua` module. | It would need QuestiePolygon's internals (`_IconData`, entry, markers, generation) passed in. That fails the deletion test: it would be a pass-through. |
| Attach each patrol to the cluster nearest its first point. | Superseded by C-5's rule. The NPC's spawn says which area the NPC is in, which is what the outline shows. A patrol's first point can lie outside every cluster. |
| Exact cluster membership from `PolygonGeometry.Build`. | It would change E's geometry output for one lookup. The bounds already exist. |
| Owner check by instance only (A §9's sketch). | A neighbouring zone's cluster can cover a border spawn. The map check is just as cheap. |
| Keep `IsLineFrame` as a `return false` shim. | It would be dead code. |

---

## 4. Sequencing

### (a) Phase 1, the rebase: unchanged

**Confirmed against F §4a and the README's Phase 1 table: no recipe step changes.** Each C stop leaves code that F's seams replace cleanly:
- R1's calls into both features in `QuestieFrame`, and the `OwnerChanged` stub, go in F-3 and F-4.
- R2's `isCursorOnMap` and the `savedIsLineFrame` scaffolding go in F-2.
- R3's `FakeHide` goes in F-3, and `_FallbackIconData` in C-F1.

This section changes only cross-references:
- the README's stop numbers in the table;
- "F-2" instead of "F1" for deleting `savedIsLineFrame`;
- R2's comment, which now quotes A §4a's text. The README treats R2 as one step shared with A, and only the comment's wording differed.

**Run it with a safety net, if David agrees.** `--exec` stops at the first replayed commit that fails these checks, including commits that apply cleanly. The README combines this with B's `Modules/Tooltips`; run the README's version.

```sh
git rebase --onto waypoints origin/master blob --exec 'busted -p ".test.lua" Modules/FramePool Modules/Map Modules/Quest Modules/Tracker && { [ ! -d Polygon ] || busted -p ".test.lua" Polygon; } && luacheck -q -- Modules/FramePool Modules/Map Modules/Quest Modules/Tracker $( [ -d Polygon ] && echo Polygon )'
```

**`--ours`/`--theirs` during a rebase:**
- `--ours` = the side being rebased onto (WP plus the blob commits already replayed).
- `--theirs` = the blob commit being replayed.
- So "take WP's file" is `git checkout --ours <path>`.

**Every blob commit touching my five files.** Conflict counts come from `git merge-file` simulations of each step on top of the previous step's resolution.

| Stop | Blob commit | Conflicts in my files | Recipe |
|---|---|---|---|
| #6 | `dfb97c802` feat(polygon): integrate cached objective areas with Questie | QuestieFrame.lua 3, QuestieMap.lua 2, QuestieQuest.lua 1, TrackerUtils.lua 3 (4 in diff3). Tests merge cleanly but fail semantically. | **R1** below |
| #9 | `8003dabb0` feat: Enhance PolygonRenderer with marker highlighting and hover improvements | QuestieFramePool.lua 1 (the hunk targets the deleted `CreateLine`) | `git checkout --ours Modules/FramePool/QuestieFramePool.lua`. Then `git rm Modules/FramePool/QuestieFramePool.test.lua`: the file is new in this commit and tests only `CreateLine`/`IsLineFrame`. Keep the rest of the commit. |
| #10 | `38da5d634` feat: Separate overlapping polygon markers with stable offsets | QuestieQuest.lua 1 (`_DrawObjectiveWaypoints` route block) | Take theirs (the `zoneOwner`/`ownsZoneMarker` rename and comments) but keep the ported call: `QuestieMap:DrawWaypoints(zoneOwner[1], spawnData.TooltipKey, waypoints, zone, spawnData.Hostile)`. |
| #13 | `4c8cb6e02` Show polygons on adjacent maps when their markers are visible | none (QuestieFrame.lua `BaseOnShow`/`BaseOnHide`) | — |
| #14 | `04c31e0dd` perf(polygon): reduce redundant checks and redraws | none (`ShouldBeHidden`) | — |
| #24 | `6bdc1ad30` feat(objectives): implement objective color management and testing | none (`GetObjectiveColor`) | — |
| #27 | `d9dc1ca4d` fix(map): defer waypoint line motion setup until combat ends | QuestieFramePool.lua 1, plus a modify/delete on its test | **Drop it.** `git checkout --ours Modules/FramePool/QuestieFramePool.lua` and `git rm Modules/FramePool/QuestieFramePool.test.lua`. Nothing remains, so run `git rebase --skip`. The bug it fixed ("Interface action failed" from protected `SetPropagateMouseMotion` in combat) cannot occur on WP: paths take no mouse input and call no protected API. WP's own docs verify map clicks and drags through lines in and out of combat (`WP docs/waypoints.md:289`). |
| #30 | `53b5e7ce4` refactor(polygon): compute area hover from the cursor, not mouse propagation | QuestieFramePool.lua 1, plus a modify/delete on its test | `checkout --ours` and `git rm` as in stop #27, then **R2** below. |
| #32 | `4f76fd411` feat(polygon): cluster objects apart and draw cluster icons on the minimap | QuestieFrame.lua 1 (`FakeHide`), QuestieQuest.test.lua 1. QuestieQuest.lua and QuestieMap.lua merge cleanly. | **R3** below |
| #33 | `83ef6e2fe` fix(map): skip recycled frames when unloading a quest's icons | none | **Keep as is.** WP never touched `UnloadQuestFrames` (`WP QuestieMap.lua:96-136`), so nothing replaces this fix. On WP it matters more: unloading a frame recycled for another quest would now also `RemoveOwner` that quest's routes. |
| #36 | `715031ef6` chore: wip snapshot of uncommitted blob work | none in my files (QuestieQuest.lua `CheckQuestSourceItem` only) | — |

The commits that change only my test files (`31b063d2b` #15, `bd340ebb9` #19, `3fc251338` #21, `d674119b6` #31) apply cleanly once R1 is in. Simulated.

**R1, at stop #6 `dfb97c802`.** Validated: the simulated stop passes `QuestieFrame` (46), `QuestieMap` (9), `QuestieQuest` (45), `TrackerUtils` (58), `QuestiePolygon` (25) and `MapIconTooltip` (19), and luacheck is clean.

- **`QuestieFrame.lua`:**
  - Imports: keep both, `QuestieWaypoints` then `QuestiePolygon`.
  - Fields: keep both, in the order `---@field minimapTwin` then `---@field polygonMarker`. This order lets `4f76fd411`'s `polygonMinimapMarker` line merge cleanly.
  - `FakeHide`: keep both lines, `QuestieWaypoints.OwnerChanged(self)` and `if self.polygonMarker then QuestiePolygon.MarkerChanged(self) end`.
  - `FakeShow`, `Fade*`, `Unload`, `OnLeave` and `OnClick` merge on their own. The result has blob's polygon hooks plus WP's waypoint calls.
  - Later, F-3 replaces every one of these calls, both imports and the fields with icon events and the IconFrame contract.
- **`QuestieMap.lua`:**
  - Imports: keep both.
  - `DrawWorldIcon`: take blob's split body, then add this before `return iconMap, iconMinimap;`:
    ```lua
        if iconMap and iconMinimap then
            -- Waypoints drawn for the map icon follow this icon's visibility on the minimap.
            iconMap.minimapTwin = iconMinimap
        end
    ```
  - `DrawWaypoints`, the removal of `DrawLineIcon` and of the overrides, and the `UnloadQuestFrames` hook all merge on their own.
- **`QuestieQuest.lua`:** take blob's route block, with `QuestieMap:DrawWaypoints(ipz[1], spawnData.TooltipKey, waypoints, zone, spawnData.Hostile)`. This also replaces the hardcoded hostile color with WP's `hostile` flag, which drives the configurable `waypointHostileColor`.
- **`TrackerUtils.lua`** (`FlashObjective`): keep blob's single loop over `toFlash`. Drop the line-frame show block and both HBD refresh lines; WP deleted the `HBDPins` local, so leaving them would be an undefined global (N8). Add the solo set:
  ```lua
          local flashData = {}
          for _, frame in ipairs(toFlash) do
              flashData[frame] = frame.data
              if frame._hidden_by_flash then
                  frame:Show()
              end

              -- todo: move into frame.session
              frame._hidden_by_flash = nil
              frame._size = frame:GetWidth()
          end
          -- Only the flashed objective's patrol paths show during the flash, its polygon markers' too.
          local soloData = {}
          for _, data in pairs(flashData) do
              soloData[data] = true
          end
          QuestieWaypoints.SetSolo(soloData)
          QuestiePolygon.ScheduleRefresh()
  ```
  The `C_Timer.After(0.5, …)` restore ends with `QuestieWaypoints.SetSolo(nil)` followed by `QuestiePolygon.ScheduleRefresh()`. `FlashFinisher` is WP's version; blob never changed it. These are TrackerUtils' Show on Map entry points (F 3.6), so no seam commit touches them.
- **Tests:** these files have no textual conflicts, so git won't stop for them. Edit them at this stop anyway.
  - `Modules/FramePool/QuestieFrame.test.lua`: in the top-level `before_each`, add `QuestieWaypoints.OwnerChanged = spy.new(function() end)` next to WP's `SetHighlighted` stub. Blob's "notifies the adapter when logical visibility changes" calls `FakeHide`/`FakeShow`. F-3 removes this stub.
  - `Modules/Tracker/TrackerUtils.test.lua`: in the top-level `before_each`, add `QuestieLoader:ImportModule("QuestieWaypoints").SetSolo = function() end`. Two flash tests need it.
  - `Modules/Quest/QuestieQuest.test.lua`: change the assertion to `called_with(QuestieMap, mapFrames[2], nil, {{{30, 40}, {40, 50}}}, 2, nil)`. The fixture has no `TooltipKey`/`Hostile`, and C-F1 rewrites this test.
  - `Modules/Map/QuestieMap.test.lua`: in "preserves paired icon drawing by default" (added by this same commit), add `assert.are.equal(frameMini, frameMap.minimapTwin)`. Without it nothing guards normal-mode minimap routes.
- Not mine but stops here too: `MapIconTooltip.lua` imports. That resolution belongs to Area B (see contracts).

**R2, at stop #30 `53b5e7ce4`.** This is the same step as A §4a. Area A owns the final rule, which F-2 implements; this is the minimal step.
- **`Polygon/QuestiePolygon.lua`:**
  - `isCursorOnMap = function() return QuestieCompat.GetMouseFocus() == scrollContainer end`.
  - The comment above it becomes A §4a's: "Area hover counts only over the bare map; anything on top, including Questie's icons, Blizzard's pins and other UI, hides the areas beneath it."
  - The `QuestieFramePool` import stays: `UnloadFrame` still uses it.
- **`Polygon/QuestiePolygon.test.lua`:**
  - Delete `local line = {}`, `FramePool.IsLineFrame = function(region) return region == line end`, `focus = line` and the line's `assert.is_true(input.isCursorOnMap())`.
  - Rename the test to "reads the map cursor and counts only the bare map as uncovered".
  - **Leave** the `savedIsLineFrame` local, its save and its restore. They are harmless, and `d674119b6`/`4f76fd411` edit that `local` line; deleting it now would add two conflicts. F-2 deletes them, along with the closure and this test.
- The README and BLOB-PARITY wording can wait for the docs updates, because it doesn't affect loading or tests.

**R3, at stop #32 `4f76fd411`.**
- **`QuestieFrame.lua` `FakeHide`:** keep `QuestieWaypoints.OwnerChanged(self)` plus blob's new `if self.polygonMarker or self.polygonMinimapMarker then QuestiePolygon.MarkerChanged(self) end`. F-3 replaces both with one `VisibilityChanged` emit.
- **`QuestieQuest.test.lua`:** keep blob's new fallback assertions plus the ported `DrawWaypoints` assertion.
- **`QuestieQuest.lua` merges cleanly but must change** (git stops here anyway):
  - In `_FallbackIconData`, exclude `waypointPaths` instead of `lineFrames`. A shallow copy would otherwise share the cluster's path list. C-F1 later deletes the function.
  - Its doc comment becomes:
    ```lua
    ---Routes highlight through their owner's data. A polygon fallback icon gets its own copy,
    ---without the copied icon's waypointPaths, so hovering it highlights only its own routes.
    ```

**After the last commit** (simulated): `QuestieFrame` 55, `QuestieMap` 10, `QuestieQuest` 46, `TrackerUtils` 58, `QuestiePolygon` 85, WP's `QuestieWaypoints` 14, `QuestFinisher` 14 and `AvailableQuests` 87 all pass, and luacheck is clean on the six touched files. Each R1/R2 stub or assertion fix was confirmed necessary: reverting any one of them fails 1–2 tests. The added twin assertion is a guard, not a fix.

**Not inside the rebase** (so replays stay mechanical):
- the seams (F-1 to F-6), including the test scaffolding cleanup (F-2);
- the route-ownership refactor and C-5 (C-F1);
- minimap twins for polygon markers (C-F2);
- the README/BLOB-PARITY/docs rewording.

Between the rebase and C-F2, blob-mode routes are world-map only, which is what blob documents today.

### (b) Phase 2: follow-up commits

**Order** (README Phase 2):
1. F-1 to F-6 open Phase 2 (Group 1).
2. Then B-F1, B-F2 and the optional A5 (Group 2).
3. Then **C-F1** and **C-F2** (Group 3).
4. E-F2 comes after C-F1, because it edits the same marker loop. D-C2 comes after C-F2, which edits the same minimap README section.

**What C-F1 and C-F2 take from F.**
- **F-2:** the provider block inside `UpdateObjective` becomes the areas layer. C-F1 reworks the code around it and leaves it alone. F-2 already deleted `savedIsLineFrame` and the `isCursorOnMap` test.
- **F-3:**
  - `QuestiePolygon`'s icon-event listeners, and `_FollowIcons()` in that provider block;
  - the IconFrame contract with `minimapTwin`;
  - the `Subscribe` capture stub in the `before_each` of `QuestiePolygon.test.lua`, `QuestieQuest.test.lua` and `TrackerUtils.test.lua`;
  - the deferred-unload test.
- **F-4:** a route's owner opens `_QuestieFrame.OnEnter`, whose `HoverStart` listeners highlight the routes and preview the marker's areas.
- **F-6:** the guard. C-F1 and C-F2 keep it green, with no new imports between features and no new `ENTRY_POINTS` line.

C's `QuestiePolygon.lua` diff applies to F's F-2 prototype of that file with line offsets only. F-3's `_FollowIcons()` call is one more line in the same provider block.

**C-F1 `refactor(polygon): attach objective routes inside QuestiePolygon`**
- **Depends on:** F-1 to F-6. Textually it depends on F-2 and F-3, which edit the same function and test files.
- **Body:** blob-mode patrols now belong to the cluster their NPC spawns in, falling back to the zone's marker (decision C-5). Route markers name the patrolling NPC.
- **`Polygon/QuestiePolygon.lua`:**
  - Delete `---@class PolygonObjectiveWork` (`B :37-39`), `IsCurrentObjective` (`:738-746`) and `OwnWaypointMarker` (`:748-770`). F-2 shifts these lines.
  - The section header `-- Marker interaction and external waypoint ownership` (`B :530`) becomes `-- Marker interaction`. F-3 rewrites the comment under it (`:531-532`).
  - Add `_IsCurrentGeneration`, `_DrawMinimapIcon` (without the twin line), `_DrawRouteMarker`, `_RouteOwner` and `_AttachRoutes` as in §3.
  - Rework `UpdateObjective` as in §3. It returns nothing; cluster sites call `_DrawMinimapIcon(marker, _IconData(…site.spawnData), site, …)`. Drop its `---@return` lines (`B :885-887`).
  - Update the field docs:
    - `PolygonObjectiveEntry.generation`: "Marker identity; progress-only updates keep it, so they never stop attaching routes".
    - `PolygonMinimapIcon.point`: "nil for a route marker's, which shares the map icon's data".
  - Update `UpdateObjective`'s summary: "Cached updates refresh the markers and keep their routes; new markers draw the objective's routes again".
- **`Modules/Quest/QuestieQuest.lua`:**
  - The blob branch becomes `QuestiePolygon.UpdateObjective(quest, objective, objectiveIndex)`.
  - Extend the comment above it: "…with cluster markers, which also draw the objective's routes".
  - Delete `_FallbackIconData`.
  - Restore `_DrawObjectiveIcons` and `_DrawObjectiveWaypoints` to WP's text verbatim. That removes the `if iconMap … if iconMini` split left over from the old destination pass, and blob's early return. Verified byte-identical to WP in the prototype.
  - This deletes core's last read of `polygonMarker` (`B QuestieQuest.lua:1392`) and its calls to `IsCurrentObjective` and `OwnWaypointMarker`. QuestieQuest keeps its one blob-mode entry point (F 3.6).
- **Tests:** as in §5 under C-F1.
- **Docs:**
  - `Polygon/README.md:16`, `:32`, `:143-145`, `:153` (its fallback sentences), `:161`, `:184`, `:203`;
  - `BLOB-PARITY.md:20`;
  - `docs/waypoints.md:278`, `:280`.

  §6 has the wording.

**C-F2 `feat(polygon): show objective routes on the minimap`**
- **Depends on:** C-F1.
- **`Polygon/QuestiePolygon.lua`:**
  - The `_DrawMinimapIcon` twin line.
  - In allocation, `local siteData = site == point and data or _IconData(quest, objective, canonicalIndex, site.spawnData)`.
- **`Modules/Map/QuestieMap.lua`:** add "only a pair links minimapTwin" to the `destination` doc.
- **No `QuestieFrame.lua` change.** F-3's IconFrame contract already says a drawing feature links its markers' twins (F 3.5).
- **Tests:** as in §5 under C-F2.
- **Docs:**
  - `Polygon/README.md:16` (routes on both maps) and `:32` (route markers show the patrolling NPC; also a C-F1 fact, so update it in C-F1 if preferred).
  - The sentence at `:47` stating that the minimap draws no routes. Coordinate with Area D, who owns that section.
  - `BLOB-PARITY.md:28`.
  - `docs/waypoints.md:44`, `:51`.

C-F1 and C-F2 are separate. C-F1 changes only which marker owns a patrol and what a route marker shows. C-F2 is a player-visible feature that can be tested in game on its own.

---

## 5. Tests

**Delete**
- `Modules/FramePool/QuestieFramePool.test.lua`, the whole file (rebase stops #9, #27 and #30). It tests only `CreateLine`/`IsLineFrame`, and nothing it covered exists anymore. WP's `QuestieWaypoints.test.lua` already covers ownership, release, twin and solo.
- `Polygon/QuestiePolygon.test.lua`: "keeps current waypoint work valid on progress updates but invalidates it on replacement" and "unloads a waypoint marker when removal invalidated its captured generation" (C-F1; the API is gone). F-2 deletes the `savedIsLineFrame` scaffolding.
- `Modules/Quest/QuestieQuest.test.lua`, `describe("polygon waypoint ownership")` (C-F1). Its polygon cases move into QuestiePolygon, and its normal-mode case is rewritten below.

**Change (rebase):** listed under R1–R3. Each one proves something specific:
- the `OwnerChanged` stub: polygon visibility hooks coexist with WP's (F-3 replaces it);
- the `SetSolo` stub: the flash path runs without line frames;
- the `DrawWaypoints` assertion: the new signature;
- the `minimapTwin` assertion in `QuestieMap.test.lua`: **a paired draw links its twin**. This is the only guard for normal-mode minimap routes.

**Add or rewrite (C-F1).** Each one fails under a targeted mutation of the prototype. The route tests need no new stubs: F-2's `WorldMapLayers` stubs and F-3's `Subscribe` capture are already in `before_each`.

| File / test | Proves | Mutation it catches |
|---|---|---|
| `QuestiePolygon.test.lua`, new `describe("objective routes")` / "draws each patrol for a marker in its zone, adding one that shows the patrolling NPC" | The cluster marker owns its zone's route, and a cluster without `worldBounds` falls back to the zone's marker. Each patrol-only zone gets a route marker named after its own NPC ("Bear", not the cluster's "Wolf"), belonging to the entry. The `TooltipKey` entity and hostile flag are passed. | The route marker uses the cluster's NPC; C-F2: no twins. |
| …/ *attaches a patrol to the cluster holding its NPC's spawn in the patrol's zone* (C-5, code below) | Of three clusters, the owner is the zone 1 cluster holding the wolf's spawn. It is neither the zone's last marker nor a zone 2 cluster whose extent covers the spawn in shared world coordinates. | `_RouteOwner` dropped (owner is the last marker, x 70); the map check reduced to the instance (owner is the neighbour, x 90). |
| …/ "keeps routes through progress updates and draws them again for replaced markers" | A progress update draws no routes. A re-cluster unloads the old marker (which releases its routes) and attaches routes to the new marker. | A progress update re-attaches routes. |
| …/ "attaches nothing to icons recycled after their objective was removed during a yield" | After `RemoveQuest` mid-attachment and frame recycling, no further `DrawWaypoints` calls and no new markers. | The stale check is removed. |
| …/ "skips a marker Questie removed while routes were attached" | The cluster sits in zone 40, so Lua 5.1's array-ordered `pairs` reaches it after the yield. The test fires the captured `Unload` listener for the cluster's frame, as `QuestieFrame` does when Questie unloads it (F-3), and recycles the frame. Its zone then gets no route (39 calls, not 40). | The `polygonMarker == marker` guard is removed. |
| `QuestiePolygon.test.lua` "invalidates waypoint work…" → "stops attaching routes and completes reset even when native view cleanup fails" | `Reset` with throwing `Clear`/`Release`/`Hide` still stops in-flight attachment (30 calls, no new markers) and finishes teardown. | The stale check is removed. |
| `QuestiePolygon.test.lua` "reuses geometry and markers on progress-only updates…" | The same assertion, without the return values (the `Update` helper stops returning them). | — |
| `QuestieQuest.test.lua` "draws each patrol for the NPC's icon in its zone, adding an icon where none is" (normal mode) | In normal mode, a zone without a spawn gets a fallback icon owning the patrol, as `"m_123"`, hostile. `UpdateObjective` is not called. | — |
| `TrackerUtils.test.lua` "restores and flashes the polygon-owned marker…" (+1 assertion, `SetSolo` stub becomes a spy) | `SetSolo` is called with `{[marker.data] = true}`, so polygon-owned routes stay visible during Show on Map. | — |

The C-5 test, as prototyped (it uses the file's own `Update`, `RouteOwners`, `frames`, `HBD` and `Geometry`):

```lua
        it("attaches a patrol to the cluster holding its NPC's spawn in the patrol's zone", function()
            -- The wolf spawns and patrols in zone 1. A bear cluster is the zone's last marker, and
            -- a zone 2 bear cluster reaches over the wolf's spawn in world coordinates.
            objective.spawnList[123].Spawns = {[1] = {{10, 20}}}
            objective.spawnList[456] = {Id = 456, Name = "Bear", Icon = 1, GetIconScale = function() return 1 end,
                Spawns = {[1] = {{70, 20}}, [2] = {{90, 20}}}}
            HBD.GetWorldCoordinatesFromZone = function(_, x, y) return x * 1000, y * 1000, 0 end -- One continent.
            local extents = {[90] = {50, 150}, [10] = {90, 110}, [70] = {650, 750}} -- x 10 is world 100.
            Geometry.Build = function(points)
                local clusters = {}
                for _, x in ipairs({90, 10, 70}) do
                    for _, point in ipairs(points) do
                        if point.x == x then
                            clusters[#clusters + 1] = {uiMapId = point.uiMapId, instanceId = point.instanceId, x = x,
                                y = point.y, representative = point,
                                worldBounds = {minX = extents[x][1], maxX = extents[x][2], minY = 150, maxY = 250}}
                        end
                    end
                end
                return clusters
            end
            Update()

            -- Not the zone's last marker (x 70), nor the neighbouring zone's (x 90).
            assert.are.equal(10, RouteOwners()[1].owner.x)
        end)
```

**Moved to Area F:** C's planned `QuestieFrame.test.lua` test "releases a queued marker's routes once, when its deferred unload finishes". F-3's *tells features an icon unloads, also at once while queued and again as the queue finishes, while it shows its data* covers it.

**Add (C-F2):**
- In `QuestiePolygon.test.lua` "shows each cluster on the minimap like the world map, except objects…":
  - `frames[i].minimapTwin == minimapFrames[i]` for both clusters;
  - their data is shared;
  - the object cluster's second icon keeps its own data.
- In the routes test: the route marker's twin carries the marker's data and belongs to its marker.

Mutation "no twins" fails both.

Every test uses `dofile("setupTests.lua")`, `QuestieLoader` stubs, `.was.called*`, and reference comparison for spy args. Spies deep-copy arguments, and markers grow afterwards, so the routes tests read `calls[i].refs`.

**Counts.** On the pre-seam prototype, `QuestiePolygon.test.lua` goes from 85 after the rebase to 88 after C-F1, C-F2 and C-5. That is −2 token tests, +4 route tests and +1 for C-5. On top of F, C-F1 and C-F2 add the same +3 to F-4's count.

---

## 6. Docs and comments

- **`Polygon/README.md`** (mine):
  - `:16`: "Existing world-map waypoint lines attach to cluster markers; the minimap draws no waypoint lines" becomes "Objective NPCs' patrol routes (Questie's waypoint paths) belong to the objective's markers: the cluster the NPC spawns in, else the zone's marker. They follow that marker on both maps (C-F2)."
  - `:32`: "each zone reached only by waypoints gets one fallback marker on both maps" becomes "…one route marker on both maps, showing the patrolling NPC".
  - `:143-145`: the generation paragraph loses `waypointWork`, `IsCurrentObjective` and `OwnWaypointMarker`. New text: "UpdateObjective attaches routes after publishing markers; replacing markers or removing the objective stops it, progress updates do not".
  - `:153`: F-3 rewords its unload sentence first. C-F1 then replaces only the fallback sentences ("Waypoint fallbacks are owned the same way…" to the end) with "Route markers are owned the same way on both maps. Routes follow their marker's map icon through QuestieWaypoints; QuestiePolygon keeps no route state".
  - `:161`: the QuestieQuest row drops "validate waypoint tokens".
  - `:184`: "waypoint ownership" becomes "objective routes".
  - `:203`: the in-game checklist says "route markers on both maps, routes on the cluster their NPC spawns in, routes during Show on Map".
- **`Polygon/README.md`, other areas' lines:**
  - `:13`, `:21`, `:104-118`, `:198`: hover, with A §6's wording, applied by F-2;
  - `:11`, `:138`, `:164`: icon events, applied by F-3.
- **`BLOB-PARITY.md`** (mine):
  - `:20` becomes "Questie's waypoint paths belong to the objective's markers, on the cluster their NPC spawns in. Paths take no mouse input, so map clicks pass through them; within hover reach a path covers the areas beneath it (Area A)". C's first version said area hover passes through paths, which F-2 makes false.
  - `:28` becomes "Ported: WaypointMinimap draws them, following each marker's minimap icon" (C-F2).
- **`docs/waypoints.md`** (WP's doc; mine are the ownership statements):
  - `:44` and `:51` (C-F2): "a drawing feature that draws a marker's map and minimap icons separately links the twin itself, as QuestiePolygon does".
  - `:52` and `:55` are F-3/F-4's and F-5's.
  - `:273-281` "Polygon areas" becomes a record of what the merge did. Each area words its own bullets:
    - `:278`, Ownership (C-F1): "Done. Blob markers own their objective's patrols: the cluster the NPC spawns in, else the zone's marker. Zones only patrols reach get a route marker showing the patrolling NPC, and markers link their minimap twins (C-F2)."
    - `:280`, Combat handling: "Removed with the merge (`d9dc1ca4d` was dropped)."
    - `:279` (hover exceptions) and `:281` (frame levels) are F-1/F-2's, resolved by `WorldMapLayers`. `:275` (minimap reuse) is D's.
- **Inline comments:**
  - in the rebase: the `_FallbackIconData` doc (R3), the `isCursorOnMap` comment (R2, A §4a's text) and the TrackerUtils solo comment (R1);
  - in C-F1: the QuestiePolygon field docs, the routes section header, `_RouteOwner`'s doc and the trimmed `Marker interaction` header;
  - in C-F2: the `destination` doc. The `minimapTwin` doc is F-3's (F 3.5).
- **Leave alone:** `Modules/Map/QuestieMapUtils.lua:55` "Add +1 to be above waypoint lines" is still true. After F-1, paths take 2015 from `WorldMapLayers` and icons start at 2016. It is master's line.

---

## 7. Verification

**During Phase 1**, at each stop, run the README's `--exec` checks. After the last stop, in the rebased checkout:

```sh
busted Modules/FramePool/QuestieFrame.test.lua
busted Modules/Map/QuestieMap.test.lua
busted Modules/Quest/QuestieQuest.test.lua
busted Modules/Tracker/TrackerUtils.test.lua
busted Polygon/QuestiePolygon.test.lua
busted -p ".test.lua" Modules/Map/Waypoints
busted Modules/Quest/QuestFinisher.test.lua Modules/Quest/AvailableQuests/AvailableQuests.test.lua
luacheck -q -- Modules/FramePool Modules/Map Modules/Quest Modules/Tracker Polygon
```

**After C-F1, and again after C-F2:**

```sh
busted Polygon/QuestiePolygon.test.lua Modules/Quest/QuestieQuest.test.lua Modules/Tracker/TrackerUtils.test.lua Modules/Map/QuestieMap.test.lua
busted -p ".test.lua" Modules/Map/Waypoints
busted Modules/Quest/QuestFinisher.test.lua Modules/Quest/AvailableQuests/AvailableQuests.test.lua
busted test/MapFeatureImports.test.lua
luacheck -q -- Modules/FramePool Modules/Map Modules/Quest Modules/Tracker Polygon
lua cli/validate-loader-usage.lua
```

**Leftover check.** After C-F1 this must print nothing:

```sh
git grep -n -E "lineFrames|CreateWaypoints|IsLineFrame|DrawLineIcon|WAYPOINT_COLOR|zoneWaypoint(Hover)?ColorOverrides|Routes_Lines|linesAwaitingMotion|motionDriver|SetPropagateMouseMotion|\bLineFrame\b|savedIsLineFrame|_FallbackIconData|OwnWaypointMarker|IsCurrentObjective|waypointWork" -- ':!Blob' ':!.types' ':!docs/waypoints.md' ':!merge-plan'
```

**In game.** Forever first, then Era. Turn blob mode on with Icons tab → "Questie blobs" preset.

1. **Normal-mode regression** (blob preset off). Horde, q1068 *Shredding Machines*, Stonetalon Mountains. XT:4 and XT:9 patrol there; each is its own kill objective with one spawn.
   - Both routes show in the hostile color on the world map and the minimap.
   - Hovering an XT icon highlights its route on both maps.
2. **Blob mode, same quest:**
   - Each XT route draws once, hostile.
   - Each objective has one marker in Stonetalon, which owns its XT's route. Hovering one XT's marker highlights only that XT's route.
   - Hovering a route opens its marker's tooltip, and previews the objective's areas (C-4).
   - A plain left-click on the marker toggles areas, and the routes stay.
3. **Show on Map flash** (blob): the XT markers flash, only this objective's routes stay visible meanwhile, and all routes return after about 1 s.
4. **Route owner, C-5** (blob):
   - **Horde, q381 *The Scarlet Crusade*, Tirisfal.** Meven Korgal (spawn 36.6, 68.5) patrols among the Scarlet Converts and Initiates of the same objective.
     - Hovering his route outlines the Solliden Farmstead cluster, and hovering that marker highlights his route.
     - Count the objective's markers in Tirisfal first. An offline run of blob's `PolygonGeometry.Build` makes all of the objective's 67 Tirisfal spawns one cluster. That run used the default 180-yard radius and Tirisfal's 4518.75 × 3012.5 yards, from the repo's `uimapassignment_classic.csv`. With one marker, both C-5 rules choose it, so this check confirms the attachment but cannot tell the rules apart (§11).
   - **Cases that tell them apart.** In both quests below, the two rules choose different markers. Both were checked offline against Classic and Forever data. Coordinates are cluster centroids from that run, and markers may sit slightly nudged.
     - **Horde, q813 *Finding the Antidote*, Durotar** (level 9). Venomtail Poison Sacs drop from Venomtail and Corrupted Scorpids and from Death Flayer, a rare scorpid. Death Flayer spawns at 36.5, 49.7 and patrols x 35.1–39.2, y 47.3–55.8. The objective's 52 Durotar spawns form 7 clusters.
       - Recommended rule: his route belongs to the cluster marker at about 36.3, 50.7. Hovering the route outlines that cluster, and hovering that marker highlights the route.
       - Zone's-last-marker rule: both go to the marker at about 56.2, 15.0, in northern Durotar, about 1,640 yards from the patrol.
     - **Alliance, q313 *The Grizzled Den*, Dun Morogh** (level 7). Wendigo Manes drop from the wendigos and from Edan the Howler, Old Icebeard and Vagash, who all patrol. The 76 spawns form 3 clusters.
       - Recommended rule: Edan's and Old Icebeard's routes belong to the Grizzled Den cluster's marker at about 40.9, 50.4. Vagash's belongs to his own marker at about 62.6, 46.0 under both rules.
       - Zone's-last-marker rule: all three routes go to Vagash's marker, about 1,080 yards east of the den.
     - **How they were found.**
       - A plain-Lua filter scanned every quest objective in QuestieDB's Classic data: kill objectives, and item objectives dropped only by NPCs. It kept a patrolling NPC that also spawns in its patrol zone, where the objective's spawns in that zone span more than 360 yards. That left 71 candidates.
       - Each went through blob's `PolygonGeometry.Build` with the default 180-yard radius, map sizes from `uimapassignment_classic.csv`, and A's bounds test.
       - The rules differ for 54 patrols in 39 quests. Forever's data gives the same result.
       - Questie's item spawn lists keep every dropping NPC's waypoints, except rank-2 rare elites and blacklisted NPCs (`B QuestieQuestPrivates.lua:107-115`, `:213-275`). These NPCs are rank 4 or rank 1, and none is blacklisted.
5. **Route marker.** Undead Rogue, q1886 *The Deathstalkers*. Astor Hadren spawns in Silverpine and patrols into Tirisfal.
   - The Tirisfal map shows a marker at his patrol start carrying his Tirisfal route. Its tooltip names Astor Hadren after C-F1.
   - Silverpine shows his cluster marker with that zone's route. With C-5 it is the cluster holding his spawn.
6. **Minimap** (C-F2):
   - Blob-mode routes show around XT patrols and hide when "Enable Minimap Icons" is off. Cluster icons and areas hide with them.
   - Routes alone hide with "Enable Minimap Waypoints".
   - Hovering a minimap route shows the cluster's tooltip on `QuestieWaypointMinimapTooltip`.
7. **Leak check.** Count the registry with `/run local n=0 for _ in pairs(QuestieLoader:ImportModule("QuestieWaypoints").paths) do n=n+1 end print(n)`. Take a baseline with q1068 in blob mode. The count must match that baseline:
   - after killing one XT (a progress update);
   - after toggling the blob preset off and on (comparing like with like in each mode);
   - after `/reload`.

   It must drop after abandoning the quest. F §7 check 6 covers abandoning while the draw queue still holds the markers.
8. **Combat.** `/reload` in combat with q1068 active in blob mode gives no "Interface action failed" and no Lua errors. This is `d9dc1ca4d`'s scenario.

---

## 8. Risks and open questions

| # | Risk or question | Recommendation |
|---|---|---|
| R1 | C-5's owner test uses cluster bounding boxes. Where two boxes overlap, the first-drawn marker wins. A phase-hidden spawn can still fall in a box. | Accept: coarse like nearby mode, and never another zone's or objective's marker. Exact membership would change E's `Build` output for this alone. |
| R2 | Routes ignore an objective's area visibility: marker click, quest log toggle and nearby mode. | Keep (README C-3). Routes follow markers; areas are a separate overlay. |
| R3 | Hovering a polygon marker's route runs the marker's `OnEnter`, whose `HoverStart` previews the objective's areas (`WP WaypointHover.lua:53-56` → `_QuestieFrame.OnEnter` → `QuestiePolygon.EnterMarker`, F-4). | Accept (README C-4, A's D5): hovering a route means hovering its marker. With C-5, the outlined cluster is the NPC's own. |
| R4 | Route markers name their own NPC (C-F1), while normal mode's fallback still uses `icon.data` of an arbitrary icon. | Accept the inconsistency. Fixing normal mode is out of scope; WP and master behave the same there. |
| R5 | Blob-mode route attachment yields every 30 attachments regardless of Hardcore. The old QuestieQuest loop used `TICKS_PER_YIELD`, which is 1 on Hardcore. | Area E decides polygon job budgets. The risk is low, because `QuestieWaypoints.Add` only builds polylines and `_RouteOwner` converts a few spawns. |
| R6 | A released but still-queued marker keeps its routes until `ProcessQueue` finishes its unload (at most about 0.2 s). | Accept. WP's normal mode behaves the same, and F-3's single `Unload` makes it the rule for both features (F's decision F-3). |
| R7 | A stale `minimapTwin` remains after its minimap icon is unloaded alone. | No production path unloads one alone, since all go through QuestiePolygon first. `MinimapAlpha`'s data check hides it, as the contract says. Accept. |
| R8 | **Pre-existing:** `QuestieQuest:ClearAllNotes` (`B QuestieQuest.lua:274-288`) unloads frames by name across yields. That is the same bug class as `83ef6e2fe`, and on WP a recycled frame would also lose another quest's routes. | Out of scope here. A separate fix should apply `83ef6e2fe`'s snapshot pattern to `ClearAllNotes`. |
| R9 | `--ours`/`--theirs` inversion during the rebase. | Use the explicit recipe in §4a. |
| R10 | With C-5, blob and normal mode give patrols different owners: the NPC's cluster against the zone's last icon. | Accept. A normal icon stands for one spawn, and C-F1 keeps normal mode byte-identical to WP. |
| Q1 | C-F1: move route attachment into QuestiePolygon and delete the token API? (README C-1) | **Yes.** |
| Q2 | C-F2: minimap routes in blob mode? (README C-2) | **Yes** (parity with normal mode, and WP's setting text stays accurate). |
| Q3 | **C-5: route owner in blob mode.** The cluster holding the NPC's spawn, or the zone's last marker? | **The cluster** (with A and F), using the map check (§3). This rests on data, not only design: the rules differ for 54 patrols in 39 Classic quests, such as q813 and q313 (§7 check 4). If David picks the zone's last marker, drop the six items listed in §3. |

---

## 9. Contracts with other areas

**Area F (seams).**
- C needs:
  - **F-3:**
    - `Unload` fires at once, and for a queued icon again as the draw queue finishes it, while `data` and `minimapTwin` are still set. `QuestieWaypoints.RemoveOwner` and polygon's `MarkerRemoved`/`MinimapMarkerRemoved` subscribe to it.
    - `VisibilityChanged` covers fake hide and show, fades, and native show and hide.
    - The IconFrame contract lets a drawing feature link its markers' `minimapTwin` (C-F2), and keeps `data` refreshed in place.
    - The `Subscribe` capture stub in the three test files.
  - **F-2:** the `WorldMapLayers` stubs, and the `savedIsLineFrame` deletion.
  - **F-4:** the owner's `OnEnter` is `_QuestieFrame.OnEnter`, whose `HoverStart` highlights routes and previews the marker.
  - **F-6:** the guard and `ENTRY_POINTS`. C needs no new line.
- C provides:
  - Phase 1 leaves exactly what F §4a lists.
  - C-F1 deletes `_FallbackIconData`, which retires the `waypointPaths` aliasing that R3 already stops in Phase 1. It also deletes core's last read of `polygonMarker` and QuestieQuest's calls to `IsCurrentObjective`/`OwnWaypointMarker`, so F 3.4 and F 3.6 hold in full (§10, item 2).
  - C-F2 links polygon markers' `minimapTwin` as the contract says.

**Area A (hover policy).**
- I provide:
  - the deletion of `QuestieFramePool.IsLineFrame` and its test file;
  - R2's minimal `isCursorOnMap` (bare map only, A §4a's comment), so every replayed commit is free of nil calls;
  - the fact that paths take no mouse input, so a path never is or blocks the mouse focus;
  - C-5 as A's D8 rule, with the map check in place of the instance check (§11).
- A owns:
  - the precedence (F-1/F-2 implement it);
  - whether a route hover previews areas (C-4);
  - the hover wording;
  - the q381 check (§11).
- A must keep `WaypointHover` calling the owner icon's `OnEnter`/`OnLeave`. That stays true: the owner's `OnEnter` is `_QuestieFrame.OnEnter`, whose `HoverStart` previews the marker.

**Area B (MapIconTooltip API).**
- **During Phase 1 (stop #6),** B's merged `ShowOnTooltip` must:
  - keep WP's `QuestieWaypoints.SetHighlighted(self.data, true)` for every icon, polygon markers included (`WP MapIconTooltip.lua:117`), placed after the throttle return;
  - have no `self.data.lineFrames` and no `QuestieMap.zoneWaypointHoverColorOverrides`;
  - drop the `QuestieMap` import if nothing else uses it.

  This holds only until F-4. After that, `QuestieWaypoints`' `HoverStart` listener highlights, and `ShowOnTooltip` applies no hover effects.
- `QuestieFrame.ResetHoverHighlights` stays the one place that ends an icon hover. After F-3 it takes `(icon, data)` and emits `HoverEnd`, and `QuestieWaypoints`' listener unhighlights.
- Area tooltips (`ShowForIcons` with owner `ScrollContainer`) do **not** highlight routes (A's D6), so `Release` needs no unhighlight.
- During Phase 1, `MapIconTooltip.test.lua` takes WP's stubs (`SetHighlighted`, `WaypointHover.End`) in place of master's `zoneWaypointHoverColorOverrides = {}`. F-4 drops them.

**Area D (minimap layer).**
- The shared minimap layer must keep collecting routes through `QuestieWaypoints.MinimapAlpha`. That is the twin rule in §3, invariant 4.
- Draw order: routes above polygon area fills, matching the world map.
- After C-F2, a cluster's areas (`_CollectMinimapAreas` reads `marker.minimapIcons[1]`) and its routes (its twin) hide with the same minimap icon.
- D owns the README minimap section's wording; I supply the sentence about routes. D-C2 comes after C-F2.

**Area E (geometry and scheduling).**
- `_AttachRoutes` yields every 30 steps, like marker allocation (`B QuestiePolygon.lua:1048`). E's polygon frame-budget primitive should replace both and settle the Hardcore question (R5). E-F2 comes after C-F1.
- `_RouteOwner` reads `PolygonCluster.uiMapId` and `worldBounds` (`B PolygonGeometry.lua:15-29`), as nearby mode does. E keeps those fields.
- I add no geometry, and `QuestieWaypoints.Add`/`WaypointGeometry.BuildPolylines` are used unchanged.

**Orchestrator (README).**
- WP's "Minimap icons must be enabled too" wording stays correct after C-F2: cluster icons are the twins (M2).
- The `--exec` command in §4a covers my files only; the README's combined version is the one to run.
- The README's q381 row ("Hovering a route outlines the cluster nearest the patrol", C-5) should read "the cluster the NPC spawns in". It should use q813 (Horde, Durotar) or q313 (Alliance, Dun Morogh), because q381 may not tell the rules apart (§7 check 4, §11).

---

## 10. Open issues with Area F

1. **F 3.5's header vs its own `minimapTwin` field.** The contract opens "Drawing features read the fields below, never write them". But its `minimapTwin` doc says the field is linked "by a drawing feature for its markers", and C-F2 does exactly that. The header needs the exception: "…never write them, except `minimapTwin` on their own markers."
2. **F 3.4 and the contract say core never reads a feature's fields after F-3.** "After F-3 only the polygon feature reads them" (`polygonMarker`), and "Core and other features never read them". That is true only after C-F1, which comes after F-6.
   - Until then, `QuestieQuest._DrawObjectiveWaypoints` reads `zoneOwner[1].polygonMarker` (`B QuestieQuest.lua:1392`), and it calls `IsCurrentObjective`/`OwnWaypointMarker`, which F 3.6's QuestieQuest list leaves out.
   - The guard checks imports only, so nothing fails. Either F says "after C-F1", or David accepts the window.
3. **F 3.3 guarantee 3 should say which fields are still set at `Unload`.** `data`, `minimapTwin` and the features' own fields are. By then, `_QuestieFrame.Unload` has already reset `_loaded`, `faded`, `hidden` and `miniMapIcon` and removed the HBD pins (`WP QuestieFrame.lua:354-382`), before `RemoveOwner`'s spot (`:385`).
   - Today's listeners don't read those fields. I checked `MarkerRemoved`, `MinimapMarkerRemoved` and `PolygonNudging`'s `Remove`, which checks the pin wrapper first (`B QuestiePolygon.lua:533-569`; `B PolygonNudging.lua:192-204`).
   - A future listener would.
4. **Coordination, not an error:** F-3 and C-F1 both edit `Polygon/README.md:153`. F-3 lands first and rewords the unload sentence; C-F1 replaces only the fallback sentences (§6).

## 11. Open issues with Area A

1. **A §9's `_RouteOwner` compares only the instance.** `entry.markers` holds markers from every zone of the objective, and world coordinates span a continent. So a neighbouring zone's cluster whose extent reaches over a border spawn can win, and its marker sits on another map than the patrol. C uses `cluster.uiMapId == uiMapId`, which implies the instance. The prototype's C-5 test fails with A's check (owner x 90).
2. **q381 probably can't tell the C-5 rules apart.** All 67 of the objective's Tirisfal spawns (Scarlet Convert, Initiate and Meven Korgal, at x 35.9–38.7, y 63.0–71.7) form **one** cluster in blob's `Build`. The input was the default 180-yard radius and Tirisfal's 4518.75 × 3012.5 yards from `uimapassignment_classic.csv`. A map 1.2× larger would split it into two, with Meven's spawn in the first.
   - With one marker, both rules attach his route to it. A §1.3/§7.3, D8 and the README describe 381 as "a cluster far from the patrol".
   - §7 check 4 keeps 381 as a sanity check. It adds q813 (Horde, Durotar) and q313 (Alliance, Dun Morogh), where the rules differ by about 1,640 and 1,080 yards. A §7.3 and the README should use those.
