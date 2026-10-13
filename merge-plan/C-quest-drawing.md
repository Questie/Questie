# Area C: quest drawing integration and removing the old line model

Owner: Area C. Scope: how blob draws objective routes and fallback markers on top of waypoints' route model, removing every remnant of the old line model from blob, and the rebase recipe for `QuestieFrame.lua`, `QuestieFramePool.lua`, `QuestieMap.lua`, `QuestieQuest.lua` and `TrackerUtils.lua`.

`WP` = `origin/waypoints` (`7c1e28bd8`), `B` = `blob` (`715031ef6`). Line numbers were checked against those commits.

**In short**
- WP's registry (`QuestieWaypoints`) becomes the only route model. A route lives exactly as long as its owner's world map icon stays loaded with the same data. QuestiePolygon never tracks routes. It only chooses which of its markers owns a zone's routes, and which of its minimap icons is that marker's `minimapTwin`.
- The rebase does only what keeps every replayed commit loadable, lint-clean, test-green and free of runtime nil calls. It ports one `DrawWaypoints` call, links twins for paired draws, uses `SetSolo` in the tracker flash, and drops the line-model pieces (one commit, `d9dc1ca4d`, disappears entirely).
- Two follow-up commits finish the design:
  - **F1** moves blob-mode route attachment into QuestiePolygon and deletes the token API (`IsCurrentObjective`, `OwnWaypointMarker`, `PolygonObjectiveWork`, `_FallbackIconData`).
  - **F2** links polygon markers to minimap twins, so blob mode gets minimap routes like normal mode.
- **Validation done in a scratch tree** (built from `git archive` and `git merge-file`; no repository state was touched):
  - The simulated post-rebase state and the `dfb97c802` stop pass all affected suites, and luacheck reports nothing.
  - The F1+F2 prototype passes the same suites. Each new test was mutation-checked.

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
- **Owner state changes.** `FakeHide`, `FakeShow`, `FadeOut` and `FadeIn` call `QuestieWaypoints.OwnerChanged` (`WP QuestieFrame.lua:410, 422, 441, 457`). `ResetHoverHighlights` calls `SetHighlighted(self.data, false)` (`:156`). The tooltip calls `SetHighlighted(self.data, true)` (`WP MapIconTooltip.lua:117`).
- **Tracker flash.** It shows only the flashed data's paths through `QuestieWaypoints.SetSolo(dataSet)` (`WP TrackerUtils.lua:206-226, 269, 284-311, 355`).
- **Hostile color.** It is the `waypointHostileColor` profile setting, default `{1, 0.2, 0, 0.7}` (`WP QuestieOptionsDefaults.lua`, migration `[42]`). The color picker "Hostile patrol color" sits under Map → Waypoints (`WP QuestieOptionsMap.lua:130-138`). `QuestieWaypoints.Color` applies it to paths whose `hostile` flag is set (`:167-173`).
- **Callers.** `DrawWaypoints(icon, entity, waypoints, zone, hostile)` (`WP QuestieMap.lua:728-732`) is called by:
  - `ShowNPC`/`ShowObject` (`:447, :513`, entity `"m_"/"o_"..id`);
  - `AvailableQuests.lua:838` and `QuestFinisher.lua:146` (entity = tooltip key);
  - `QuestieQuest.lua:1343` (`spawnData.TooltipKey`, `spawnData.Hostile`).

**Route model, B (the old line model plus blob's ownership layer):**
- `QuestieFramePool:CreateWaypoints`/`CreateLine` make one mouse-enabled Button per segment and store it in `iconFrame.data.lineFrames` (`B QuestieFramePool.lua:122-342`, `WAYPOINT_COLOR` at `:21`).
- `IsLineFrame` and its registry (`:150-160`) exist only so polygon hover can treat a line as bare map (`B QuestiePolygon.lua:998-1001`).
- `DrawLineIcon` registers lines with HBD (`B QuestieMap.lua:527-540`). `DrawWaypoints(icon, waypoints, zone, color)` (`:745-756`) uses `zoneWaypoint(Hover)ColorOverrides` (`:735-743`).
- `QuestieFrame` walks `data.lineFrames` in `ResetHoverHighlights`, `Unload`, `FadeOut`, `FadeIn`, `FakeHide` and `FakeShow` (`B QuestieFrame.lua:157-162, 398-403, 428-435, 448-455, 469-473, 495-499`).
- The tracker flash hides and shows `data.lineFrames` by hand, then forces `HBDPins.worldmapProvider:RefreshAllData()` to restore their zone-aware visibility (`B TrackerUtils.lua:208-212, 230-235, 286-289, 313-317, 375-377`).
- `MapIconTooltip` colors `self.data.lineFrames` with `zoneWaypointHoverColorOverrides` (`B MapIconTooltip.lua:109-113`; these are master's lines that blob never touched).
- Blob mode draws routes from `QuestieQuest._DrawObjectiveWaypoints(objective, icon, iconPerZone, waypointWork)` (`B QuestieQuest.lua:1352-1410`):
  - `QuestiePolygon.UpdateObjective` returns the last-drawn cluster's data, an `iconPerZone` table and a `PolygonObjectiveWork` token (`B QuestiePolygon.lua:1022-1065`).
  - Fallback markers are drawn twice, once per destination, each with its own `_FallbackIconData` copy (`B QuestieQuest.lua:1340-1350, 1372-1377`). `OwnWaypointMarker` adopts them (`B QuestiePolygon.lua:754-770`).
  - Routes draw only when the zone owner's `polygonMarker.entry == waypointWork.entry` (`B QuestieQuest.lua:1389-1397`).
  - The call passes the hardcoded hostile color `{1, 0.2, 0, 0.7}` (`:1395`).
  - Staleness is the token's captured generation (`IsCurrentObjective`, `B QuestiePolygon.lua:742-746`). It is checked before each zone and after each yield.
- `DrawWorldIcon(data, areaID, x, y, phase, showFlag, destination)` can draw only the map icon or only the minimap icon (`B QuestieMap.lua:649-733`). Cluster markers use that: one map marker plus one minimap icon per site (`B QuestiePolygon.lua:1029-1046`).

### Where they collide and what breaks

1. **Signature (finding 2).**
   - `B QuestieQuest.lua:1395` calls the 4-argument form. On WP the arguments shift: `waypoints` becomes the entity, `zone` becomes the patrols and the color table becomes the area. Blob-mode routes either error or draw nothing.
   - `B QuestieMap.lua:455, 521` are untouched master lines. The rebase takes WP's version automatically, so they need no port.
2. **Line model leftovers (findings 3, 12, 13).** Every `lineFrames`, `CreateLine`, `IsLineFrame`, `DrawLineIcon` and `zoneWaypoint*` reference is a nil access on WP:
   - `IsLineFrame` is called on every hover frame (finding 1).
   - `TrackerUtils` would call `HBDPins.worldmapProvider`, but WP deleted the `HBDPins` local in that file, so that is an undefined global.
   - Blob's `QuestieFramePool.test.lua` tests only `CreateLine`/`IsLineFrame`.
   - The combat motion driver (`d9dc1ca4d`) exists only for line frames. It is already gone at `B` HEAD: `53b5e7ce4` removed it.
3. **Twins (finding 4).**
   - After blob's `DrawWorldIcon` refactor, a careless resolution drops WP's `iconMap.minimapTwin = iconMinimap`. Normal-mode minimap routes would then silently disappear; no existing test covers this.
   - Blob-mode markers never get a twin, so blob-mode routes cannot reach the minimap.
4. **Fallback copies (finding 5).** `_FallbackIconData` copies everything except `lineFrames`.
   - On WP it would copy the cluster's `waypointPaths` list reference. The fallback's paths would then be appended into the cluster's list, which is aliased highlighting.
   - The copy's original reason is gone: "hiding an icon hides its data's lines" no longer holds, because WP's visibility is per owner.
   - Separately, the copy shows the last-drawn cluster's NPC, not the NPC that patrols that zone.

---

## 2. Comparison

| | Old line model + blob ownership (B) | Registry model (WP) |
|---|---|---|
| Lifetime | Lines live in `data.lineFrames`. Any icon sharing that data hides or unloads them, which is why blob copies data. | Paths are keyed by owner frame (`pathsByOwner`). Release happens once, from the owner's real `Unload`. Data only carries the highlight list. |
| Recycled frames | Blob guards with generation tokens and `marker.entry` checks at the call site. | `_IsOwned` (`owner.data == path.data`) hides paths of a frame drawn for something else. A double `RemoveOwner` is harmless. |
| Mouse/combat | Lines are mouse-enabled. This needed `SetPropagateMouseMotion`, a combat deferral driver and `IsLineFrame`. | Paths take no mouse input. They need no protected API, and hover is computed from the cursor. |
| Minimap | None. | Follows the owner's `minimapTwin`. |
| Styling | Hardcoded hostile color, `global.iconFadeLevel` (which has no default), zoom-thickening lines. | Profile settings and a hostile flag, `profile.iconFadeLevel`, constant on-screen width. |
| Dedupe | None. Each copy draws, and they stack darker. | One draw per route key (entity, area, part). |
| Tracker flash | Raw hide and show of lines, then a forced HBD refresh. | `SetSolo(dataSet)`. |

**Keep from blob:**
- Generation-based staleness for route work: progress-only updates must not cancel an in-flight route batch (`B QuestiePolygon.lua:976-980`, README "Generation").
- "No routes on a released marker's icon" (the `marker.entry` check).
- `DrawWorldIcon`'s `destination` split, because cluster markers need one map marker and N minimap icons at different positions.
- The recycled-frame checks in `UnloadQuestFrames` (`83ef6e2fe`) and in the tracker flash (`frame.data == flashData[frame]`).

**Keep from WP:** everything that is route-related. No blob route code survives except the ownership decisions.

**Drop:** `_FallbackIconData` (its premise is gone), the token API (it leaks marker internals into QuestieQuest), and all line-model code and tests.

---

## 3. Target design

### Ownership

| Module | Owns | Changes |
|---|---|---|
| `QuestieWaypoints` (WP) | Paths: registry, release, visibility, color, highlight, solo. | None. |
| `QuestieMap` | `DrawWaypoints` (WP); `DrawWorldIcon` with blob's `destination`, linking `minimapTwin` only when one call draws both icons. | Rebase resolution only. |
| `QuestieFrame` | The icon lifecycle, which forwards to both QuestieWaypoints (`RemoveOwner`, `OwnerChanged`, `SetHighlighted`) and QuestiePolygon (`MarkerRemoved`, `MinimapMarkerRemoved`, `MarkerChanged`). | Rebase resolution only. |
| `QuestiePolygon` | Markers, their minimap icons, **which marker owns each zone's routes, route markers, and each marker's minimap twin**. | F1, F2. |
| `QuestieQuest` | Normal-mode objective icons and routes (WP's `_DrawObjectiveWaypoints` text verbatim). In blob mode it only calls `QuestiePolygon.UpdateObjective`. | F1. |
| `TrackerUtils` | The flash: polygon markers plus `AlreadySpawned` map refs, with `SetSolo` over their data. | Rebase resolution. |
| `QuestieFramePool` | WP's version: frame pool, no lines. | Rebase resolution. |

### Public interface after F1 and F2

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
-- kept:    QuestiePolygon.GetObjectiveMarkers (tracker flash), MarkerRemoved/MinimapMarkerRemoved/MarkerChanged (QuestieFrame)

-- IconFrame field (QuestieFrame.lua), documented contract:
---@field minimapTwin IconFrame? The minimap icon showing this icon's data; its waypoint paths follow it on the minimap.
---Linked by QuestieMap for icons drawn as a pair and by QuestiePolygon for its markers.
```

### Internals added to QuestiePolygon (F1; the F2 lines are marked)

These were prototyped and validated in the scratch tree. They go right before `UpdateObjective`, after `_IconData`.

```lua
-- Objective routes
-- Each patrol of an objective's NPCs belongs to one of the objective's markers in its zone:
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
    -- F2: the icon showing the marker's own data is its minimap twin, so the marker's routes show
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

---Draws each of the objective's patrols for a marker in its zone, adding route markers where no
---cluster is. Without any marker nothing is drawn, as in normal mode.
---@async
---@param zoneMarkers table<AreaId, PolygonMarker> Markers just drawn; the last one of each zone.
local function _AttachRoutes(entry, zoneMarkers)
    if not next(zoneMarkers) then return end
    local generation, attached = entry.generation, 0
    for _, spawnData in pairs(entry.objective.spawnList or {}) do
        for areaId, patrols in pairs(spawnData.Waypoints or {}) do
            local first = patrols[1] and patrols[1][1]
            if first then
                local marker = zoneMarkers[areaId]
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

**Changes inside `UpdateObjective`:**
- The allocation keeps `zoneMarkers[point.areaId] = marker` instead of `icon`/`iconPerZone`.
- Each site calls `_DrawMinimapIcon(marker, siteData, site, site.areaId, x, y)`.
- F2 sets `siteData = site == point and data or _IconData(...)`, so the minimap icon of the marker's own spawn shares the marker's data. For an object cluster, `locations[1]` is the representative and therefore `point`.
- Every `return nil, {}` and token return becomes a bare `return`, and the function ends with `_AttachRoutes(entry, zoneMarkers)`.
- The generation bump comment becomes "stops earlier route attachment before its marker frames can be recycled".

### Data flow (blob mode)

```
PopulateObjective ──► QuestiePolygon.UpdateObjective
   ├─ progress-only (cache hit): _RefreshMarkers → return     (markers, data tables and routes untouched)
   └─ new geometry: generation+1 → _ReleaseMarkers(entry)     (each UnloadFrame → Unload → RemoveOwner: old routes gone)
        → allocate cluster markers (+ minimap icons; F2: first one = twin, shares data)
        → publish (building=nil, signature) → _AttachRoutes
              per spawnData × waypoint zone: marker of zone, or _DrawRouteMarker (NPC's own data, F2: twin)
              → QuestieMap:DrawWaypoints(marker.frame, spawnData.TooltipKey, patrols, zone, spawnData.Hostile)
              → QuestieWaypoints.Add (owner = marker.frame, data = marker.frame.data)
```

### Invariants

1. **One owner, released once.** Every route has exactly one owner frame. Every way a polygon marker goes away runs `QuestieFramePool:UnloadFrame(marker.frame)`, which releases its routes exactly once:
   - re-cluster, `RemoveObjective`, `RemoveQuest` and `Reset` go through `_ReleaseMarkers`;
   - Questie's own lifecycle goes through `MarkerRemoved`;
   - a still-queued frame defers until `ProcessQueue` (`WP QuestieMap.lua:359-362`).

   The two release mechanisms behave as follows:
   - `RemoveOwner` is idempotent, and the deferred first `Unload` does not call it.
   - Quest removal (`UnloadQuestFrames` → `RemoveQuest` first, `B QuestieMap.lua:99-101`) then skips already-released frames by its data snapshot (`83ef6e2fe`).
2. **Routes only go to live markers.** Routes are attached only to markers of the current entry generation (`_IsCurrentGeneration` after every yield, nothing in between can invalidate it) and only to markers still owning their frame (`marker.frame.polygonMarker == marker`). "Routes drawn only for that entry's markers" therefore holds by construction, instead of through a cross-module check.
3. **QuestiePolygon keeps no route state.** Progress-only updates keep `frame.data` table identity (`_RefreshMarkers` mutates fields in place, `B QuestiePolygon.lua:821-865`). `waypointPaths` and `_IsOwned` therefore stay valid without any route bookkeeping in QuestiePolygon.
4. **Twin rule.** A marker's `minimapTwin` is the minimap icon drawn with the marker's own data table (F2), so `MinimapAlpha`'s `twin.data == path.data` holds. A stale twin, left after its minimap icon is unloaded alone, fails that check and draws nothing.

### Why this holds up

- **Locality.** Route ownership bugs live in one ~60-line section of QuestiePolygon. QuestieQuest's normal mode becomes byte-identical to WP's, which shrinks the master diff and the conflict surface for later rebases.
- **Leverage.** One rule (owner frame plus twin) covers normal icons, manual notes, cluster markers and route markers. New marker kinds only need to call `DrawWaypoints` with a frame they own.
- **No speculative pieces.** There is no new module, no new public function and no new setting.

### Rejected alternatives

| Alternative | Why rejected |
|---|---|
| Keep blob's QuestieQuest loop and tokens and port only the call (Option A). | The interface stays shallow and leaky: QuestieQuest reads `polygonMarker.entry` and `waypointWork.entry`, and `IsCurrentObjective` and `OwnWaypointMarker` exist only for it. This is fine as the rebase state, but not as the target. |
| Fallback marker with a `_FallbackIconData` copy, or sharing the cluster's data. | Its premise (lines on data) is gone. It shows the wrong NPC, and sharing aliases highlights. |
| Route marker drawn as a pair so `QuestieMap` links the twin. | That gives two twin-linking paths for polygon markers. One helper (`_DrawMinimapIcon`) covers clusters and route markers, and it keeps the test stubs simple. |
| Replace `destination` with `DrawWorldMapIcon`/`DrawMinimapIcon`, or add a `twinOf` parameter. | It adds interface for the same behavior. `destination` is already the seam for split drawing. |
| QuestieWaypoints finds twins by data. | That needs a reverse index of minimap icons. WP deliberately chose an explicit twin. |
| A separate `Polygon/PolygonRoutes.lua` module. | It would need QuestiePolygon's internals (`_IconData`, entry, markers, generation) passed in. That fails the deletion test: it would be a pass-through. |
| Attach each route to the cluster nearest its first point. | It would make hover highlights nicer (see risk R1), but it departs from normal mode's per-zone rule. Not needed now. |
| Keep `IsLineFrame` as a `return false` shim. | It would be dead code. |

---

## 4. Sequencing

### (a) Rebase: minimal changes per blob commit

**Run it with a safety net, if David agrees.** `--exec` stops at the first replayed commit that fails these checks, including commits that apply cleanly:

```sh
git rebase --onto waypoints origin/master blob --exec 'busted -p ".test.lua" Modules/FramePool Modules/Map Modules/Quest Modules/Tracker && { [ ! -d Polygon ] || busted -p ".test.lua" Polygon; } && luacheck -q -- Modules/FramePool Modules/Map Modules/Quest Modules/Tracker $( [ -d Polygon ] && echo Polygon )'
```

**`--ours`/`--theirs` during a rebase:**
- `--ours` = the side being rebased onto (WP plus the blob commits already replayed).
- `--theirs` = the blob commit being replayed.
- So "take WP's file" is `git checkout --ours <path>`.

**Every blob commit touching my five files.** Conflict counts come from `git merge-file` simulations of each step on top of the previous step's resolution.

| # | Blob commit | Conflicts in my files | Recipe |
|---|---|---|---|
| 1 | `dfb97c802` feat(polygon): integrate cached objective areas with Questie | QuestieFrame.lua 3, QuestieMap.lua 2, QuestieQuest.lua 1, TrackerUtils.lua 3 (4 in diff3). Tests merge cleanly but fail semantically. | **R1** below |
| 2 | `8003dabb0` feat: Enhance PolygonRenderer with marker highlighting and hover improvements | QuestieFramePool.lua 1 (the hunk targets the deleted `CreateLine`) | `git checkout --ours Modules/FramePool/QuestieFramePool.lua`. Then `git rm Modules/FramePool/QuestieFramePool.test.lua`: the file is new in this commit and tests only `CreateLine`/`IsLineFrame`. Keep the rest of the commit. |
| 3 | `38da5d634` feat: Separate overlapping polygon markers with stable offsets | QuestieQuest.lua 1 (`_DrawObjectiveWaypoints` route block) | Take theirs (the `zoneOwner`/`ownsZoneMarker` rename and comments) but keep the ported call: `QuestieMap:DrawWaypoints(zoneOwner[1], spawnData.TooltipKey, waypoints, zone, spawnData.Hostile)`. |
| 4 | `4c8cb6e02` Show polygons on adjacent maps when their markers are visible | none (QuestieFrame.lua `BaseOnShow`/`BaseOnHide`) | — |
| 5 | `04c31e0dd` perf(polygon): reduce redundant checks and redraws | none (`ShouldBeHidden`) | — |
| 6 | `6bdc1ad30` feat(objectives): implement objective color management and testing | none (`GetObjectiveColor`) | — |
| 7 | `d9dc1ca4d` fix(map): defer waypoint line motion setup until combat ends | QuestieFramePool.lua 1, plus a modify/delete on its test | **Drop it.** `git checkout --ours Modules/FramePool/QuestieFramePool.lua` and `git rm Modules/FramePool/QuestieFramePool.test.lua`. Nothing remains, so run `git rebase --skip`. The bug it fixed ("Interface action failed" from protected `SetPropagateMouseMotion` in combat) cannot occur on WP: paths take no mouse input and call no protected API. WP's own docs verify map clicks and drags through lines in and out of combat (`WP docs/waypoints.md:289`). |
| 8 | `53b5e7ce4` refactor(polygon): compute area hover from the cursor, not mouse propagation | QuestieFramePool.lua 1, plus a modify/delete on its test | `checkout --ours` and `git rm` as in #7, then **R2** below. |
| 9 | `4f76fd411` feat(polygon): cluster objects apart and draw cluster icons on the minimap | QuestieFrame.lua 1 (`FakeHide`), QuestieQuest.test.lua 1. QuestieQuest.lua and QuestieMap.lua merge cleanly. | **R3** below |
| 10 | `83ef6e2fe` fix(map): skip recycled frames when unloading a quest's icons | none | **Keep as is.** WP never touched `UnloadQuestFrames` (`WP QuestieMap.lua:96-136`), so nothing replaces this fix. On WP it matters more: unloading a frame recycled for another quest would now also `RemoveOwner` that quest's routes. |
| 11 | `715031ef6` chore: wip snapshot of uncommitted blob work | none in my files (QuestieQuest.lua `CheckQuestSourceItem` only) | — |

The commits that change only my test files (`31b063d2b`, `bd340ebb9`, `3fc251338`, `d674119b6`) apply cleanly once R1 is in. Simulated.

**R1, at `dfb97c802`.** Validated: the simulated stop passes `QuestieFrame` (46), `QuestieMap` (9), `QuestieQuest` (45), `TrackerUtils` (58), `QuestiePolygon` (25) and `MapIconTooltip` (19), and luacheck is clean.

- **`QuestieFrame.lua`:**
  - Imports: keep both, `QuestieWaypoints` then `QuestiePolygon`.
  - Fields: keep both, in the order `---@field minimapTwin` then `---@field polygonMarker`. This order lets `4f76fd411`'s `polygonMinimapMarker` line merge cleanly.
  - `FakeHide`: keep both lines, `QuestieWaypoints.OwnerChanged(self)` and `if self.polygonMarker then QuestiePolygon.MarkerChanged(self) end`.
  - `FakeShow`, `Fade*`, `Unload`, `OnLeave` and `OnClick` merge on their own. The result has blob's polygon hooks plus WP's waypoint calls.
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
- **`TrackerUtils.lua`** (`FlashObjective`): keep blob's single loop over `toFlash`. Drop the line-frame show block and both HBD refresh lines; WP deleted the `HBDPins` local, so leaving them would be an undefined global. Add the solo set:
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
  The `C_Timer.After(0.5, …)` restore ends with `QuestieWaypoints.SetSolo(nil)` followed by `QuestiePolygon.ScheduleRefresh()`. `FlashFinisher` is WP's version; blob never changed it.
- **Tests:** these files have no textual conflicts, so git won't stop for them. Edit them at this stop anyway.
  - `Modules/FramePool/QuestieFrame.test.lua`: in the top-level `before_each`, add `QuestieWaypoints.OwnerChanged = spy.new(function() end)` next to WP's `SetHighlighted` stub. Blob's "notifies the adapter when logical visibility changes" calls `FakeHide`/`FakeShow`.
  - `Modules/Tracker/TrackerUtils.test.lua`: in the top-level `before_each`, add `QuestieLoader:ImportModule("QuestieWaypoints").SetSolo = function() end`. Two flash tests need it.
  - `Modules/Quest/QuestieQuest.test.lua`: change the assertion to `called_with(QuestieMap, mapFrames[2], nil, {{{30, 40}, {40, 50}}}, 2, nil)`. The fixture has no `TooltipKey`/`Hostile`, and F1 rewrites this test.
  - `Modules/Map/QuestieMap.test.lua`: in "preserves paired icon drawing by default" (added by this same commit), add `assert.are.equal(frameMini, frameMap.minimapTwin)`. Without it nothing guards normal-mode minimap routes.
- Not mine but stops here too: `MapIconTooltip.lua` imports. That resolution belongs to Area B (see contracts).

**R2, at `53b5e7ce4`.** Area A owns the final rule; this is the minimal step.
- **`Polygon/QuestiePolygon.lua`:**
  - `isCursorOnMap = function() return QuestieCompat.GetMouseFocus() == scrollContainer end`.
  - The comment above it becomes "Area hover counts only over the bare map; waypoint paths take no mouse input. Anything else on top, …".
  - The `QuestieFramePool` import stays: `UnloadFrame` still uses it.
- **`Polygon/QuestiePolygon.test.lua`:**
  - Delete `local line = {}`, `FramePool.IsLineFrame = function(region) return region == line end`, `focus = line` and the line's `assert.is_true(input.isCursorOnMap())`.
  - Rename the test to "reads the map cursor and counts only the bare map as uncovered".
  - **Leave** the `savedIsLineFrame` local, its save and its restore. They are harmless, and `d674119b6`/`4f76fd411` edit that `local` line; deleting it now would add two conflicts. F1 deletes them.
- The README and BLOB-PARITY wording can wait for the docs updates, because it doesn't affect loading or tests.

**R3, at `4f76fd411`.**
- **`QuestieFrame.lua` `FakeHide`:** keep `QuestieWaypoints.OwnerChanged(self)` plus blob's new `if self.polygonMarker or self.polygonMinimapMarker then QuestiePolygon.MarkerChanged(self) end`.
- **`QuestieQuest.test.lua`:** keep blob's new fallback assertions plus the ported `DrawWaypoints` assertion.
- **`QuestieQuest.lua` merges cleanly but must change** (git stops here anyway):
  - In `_FallbackIconData`, exclude `waypointPaths` instead of `lineFrames`. A shallow copy would otherwise share the cluster's path list.
  - Its doc comment becomes:
    ```lua
    ---Routes highlight through their owner's data. A polygon fallback icon gets its own copy,
    ---without the copied icon's waypointPaths, so hovering it highlights only its own routes.
    ```

**After the last commit** (simulated): `QuestieFrame` 55, `QuestieMap` 10, `QuestieQuest` 46, `TrackerUtils` 58, `QuestiePolygon` 85, WP's `QuestieWaypoints` 14, `QuestFinisher` 14 and `AvailableQuests` 87 all pass, and luacheck is clean on the six touched files. Each R1/R2 stub or assertion fix was confirmed necessary: reverting any one of them fails 1–2 tests. The added twin assertion is a guard, not a fix.

**Not inside the rebase** (so replays stay mechanical): the route-ownership refactor (F1), minimap twins for polygon markers (F2), test scaffolding cleanup, and the README/BLOB-PARITY/docs rewording. Between the rebase and F2, blob-mode routes are world-map only, which is what blob documents today.

### (b) Follow-up commits, after stacking

**F1 `refactor(polygon): attach objective routes inside QuestiePolygon`**
- **`Polygon/QuestiePolygon.lua`:**
  - Delete `---@class PolygonObjectiveWork` (`B :37-39`), `IsCurrentObjective` (`:738-746`) and `OwnWaypointMarker` (`:748-770`).
  - Add `_IsCurrentGeneration`, `_DrawMinimapIcon` (without the twin line), `_DrawRouteMarker` and `_AttachRoutes` as in §3.
  - Rework `UpdateObjective` as in §3. It returns nothing; cluster sites call `_DrawMinimapIcon(marker, _IconData(…site.spawnData), site, …)`.
  - Update the field docs:
    - `PolygonObjectiveEntry.generation`: "Marker identity; progress-only updates keep it, so they never stop attaching routes".
    - `PolygonMinimapIcon.point`: "nil for a route marker's, which shares the map icon's data".
  - Update `UpdateObjective`'s summary: "Cached updates refresh the markers and keep their routes; new markers draw the objective's routes again".
- **`Modules/Quest/QuestieQuest.lua`:**
  - The blob branch becomes `QuestiePolygon.UpdateObjective(quest, objective, objectiveIndex)`.
  - Extend the comment above it: "…with cluster markers, which also draw the objective's routes".
  - Delete `_FallbackIconData`.
  - Restore `_DrawObjectiveIcons` and `_DrawObjectiveWaypoints` to WP's text verbatim. That removes the `if iconMap … if iconMini` split left over from the old destination pass, and blob's early return. Verified byte-identical to WP in the prototype.
- **Tests:** as in §5 under F1.
- **Docs:**
  - `Polygon/README.md:143-145, 153, 161, 184` (the generation/token API text, "each fallback icon gets its own copy… route lines attach to it", "validate waypoint tokens", "waypoint ownership").
  - `BLOB-PARITY.md:20`.

**F2 `feat(polygon): show objective routes on the minimap`**
- **`Polygon/QuestiePolygon.lua`:**
  - The `_DrawMinimapIcon` twin line.
  - In allocation, `local siteData = site == point and data or _IconData(quest, objective, canonicalIndex, site.spawnData)`.
- **`Modules/FramePool/QuestieFrame.lua`:** the `minimapTwin` field doc as in §3.
- **`Modules/Map/QuestieMap.lua`:** add "only a pair links minimapTwin" to the `destination` doc.
- **Tests:** as in §5 under F2.
- **Docs:**
  - `Polygon/README.md:16` (routes on both maps) and `:32` (route markers show the patrolling NPC; also an F1 fact, so update it in F1 if preferred).
  - The sentence at `:47` stating that the minimap draws no routes. Coordinate with Area D, who owns that section.
  - `BLOB-PARITY.md:28`.
  - `docs/waypoints.md:44, 51, 273-281` (see §6).

F1 and F2 are separate: F1 is behavior-neutral apart from route markers naming their own NPC; F2 is a player-visible feature that can be tested in game on its own.

---

## 5. Tests

**Delete**
- `Modules/FramePool/QuestieFramePool.test.lua`, the whole file (rebase #2/#7/#8). It tests only `CreateLine`/`IsLineFrame`, and nothing it covered exists anymore. WP's `QuestieWaypoints.test.lua` already covers ownership, release, twin and solo.
- `Polygon/QuestiePolygon.test.lua`:
  - "keeps current waypoint work valid on progress updates but invalidates it on replacement" and "unloads a waypoint marker when removal invalidated its captured generation" (F1; the API is gone).
  - The `savedIsLineFrame` scaffolding (F1).
- `Modules/Quest/QuestieQuest.test.lua`, `describe("polygon waypoint ownership")` (F1). Its polygon cases move into QuestiePolygon, and its normal-mode case is rewritten below.

**Change (rebase):** listed under R1–R3. Each one proves something specific:
- the `OwnerChanged` stub: polygon visibility hooks coexist with WP's;
- the `SetSolo` stub: the flash path runs without line frames;
- the `DrawWaypoints` assertion: the new signature;
- the `minimapTwin` assertion in `QuestieMap.test.lua`: **a paired draw links its twin**. This is the only guard for normal-mode minimap routes.

**Add or rewrite (F1).** Each one fails under a targeted mutation of the prototype:

| File / test | Proves | Mutation it catches |
|---|---|---|
| `QuestiePolygon.test.lua`, new `describe("objective routes")` / "draws each patrol for a marker in its zone, adding one that shows the patrolling NPC" | The cluster marker owns its zone's route. Each patrol-only zone gets a route marker named after its own NPC ("Bear", not the cluster's "Wolf"), belonging to the entry. The `TooltipKey` entity and hostile flag are passed. | The route marker uses the cluster's NPC; F2: no twins. |
| …/ "keeps routes through progress updates and draws them again for replaced markers" | A progress update draws no routes. A re-cluster unloads the old marker (which releases its routes) and attaches routes to the new marker. | A progress update re-attaches routes. |
| …/ "attaches nothing to icons recycled after their objective was removed during a yield" | After `RemoveQuest` mid-attachment and frame recycling, no further `DrawWaypoints` calls and no new markers. | The stale check is removed. |
| …/ "skips a marker Questie removed while routes were attached" | The cluster sits in zone 40, so Lua 5.1's array-ordered `pairs` reaches it after the yield. After `MarkerRemoved`, its zone gets no route (39 calls, not 40). | The `polygonMarker == marker` guard is removed. |
| `QuestiePolygon.test.lua` "invalidates waypoint work…" → "stops attaching routes and completes reset even when native view cleanup fails" | `Reset` with throwing `Clear`/`Release`/`Hide` still stops in-flight attachment (30 calls, no new markers) and finishes teardown. | The stale check is removed. |
| `QuestiePolygon.test.lua` "reuses geometry and markers on progress-only updates…" | The same assertion, without the return values (the `Update` helper stops returning them). | — |
| `QuestieQuest.test.lua` "draws each patrol for the NPC's icon in its zone, adding an icon where none is" (normal mode) | In normal mode, a zone without a spawn gets a fallback icon owning the patrol, as `"m_123"`, hostile. `UpdateObjective` is not called. | — |
| `QuestieFrame.test.lua` "releases a queued marker's routes once, when its deferred unload finishes" | `MarkerRemoved` runs on the first, deferred `Unload` while `RemoveOwner` does not. After `_loaded`, exactly one `RemoveOwner` happens. This is the "cleaned up exactly once" contract across the draw queue. | — |
| `TrackerUtils.test.lua` "restores and flashes the polygon-owned marker…" (+1 assertion, `SetSolo` stub becomes a spy) | `SetSolo` is called with `{[marker.data] = true}`, so polygon-owned routes stay visible during Show on Map. | — |

**Add (F2):**
- In `QuestiePolygon.test.lua` "shows each cluster on the minimap like the world map, except objects…":
  - `frames[i].minimapTwin == minimapFrames[i]` for both clusters;
  - their data is shared;
  - the object cluster's second icon keeps its own data.
- In the routes test: the route marker's twin carries the marker's data and belongs to its marker.

Mutation "no twins" fails both.

Every test uses `dofile("setupTests.lua")`, `QuestieLoader` stubs, `.was.called*`, and reference comparison for spy args. Spies deep-copy arguments, and markers grow afterwards, so the routes test reads `calls[i].refs`.

---

## 6. Docs and comments

- **`Polygon/README.md`** (mine):
  - `:16`: "Existing world-map waypoint lines attach to cluster markers; the minimap draws no waypoint lines" becomes "Objective NPCs' patrol routes (Questie's waypoint paths) belong to the objective's markers and follow them on both maps (F2)".
  - `:32`: "each zone reached only by waypoints gets one fallback marker on both maps" becomes "…one route marker on both maps, showing the patrolling NPC".
  - `:143-145`: the generation paragraph loses `waypointWork`, `IsCurrentObjective` and `OwnWaypointMarker`. New text: "UpdateObjective attaches routes after publishing markers; replacing markers or removing the objective stops it, progress updates do not".
  - `:153`: drop "Each fallback icon gets its own copy of the icon data, because route lines attach to it…". Replace it with "Routes follow their marker's map icon through QuestieWaypoints; QuestiePolygon keeps no route state".
  - `:161`: the QuestieQuest row drops "validate waypoint tokens".
  - `:184`: "waypoint ownership" becomes "objective routes".
  - `:203`: the in-game checklist says "route markers on both maps, routes during Show on Map".
- **`Polygon/README.md`, Area A's lines:** `:13` ("icons and waypoint lines keep their own tooltips"), `:110` (`isCursorOnMap` "or a Questie waypoint line"), `:198` (hover over waypoint lines, in and out of combat).
- **`BLOB-PARITY.md`** (mine):
  - `:20` becomes "Questie's waypoint paths attach to cluster markers; paths take no mouse input, so area hover and map clicks pass through them".
  - `:28` becomes "Ported: WaypointMinimap draws them, following each marker's minimap icon" (F2).
- **`docs/waypoints.md`** (WP's doc; mine are the ownership statements):
  - `:44` and `:51` gain "QuestiePolygon links its markers' twins".
  - `:273-281` "Polygon areas" is rewritten as done:
    - blob markers own routes;
    - route markers;
    - twins;
    - hover exceptions and the combat driver removed with the merge.
  - The frame-level sentence ("paths at 2015 above polygon areas at Blizzard's quest blob pin level, below icons") needs Areas A/D to confirm it in game.
- **Inline comments** (all listed in §3/§4): the `_FallbackIconData` doc (rebase), the `isCursorOnMap` comment (rebase), the TrackerUtils solo comment (rebase), the `minimapTwin` and `destination` docs (F2), and the QuestiePolygon field docs and section header (F1).
- **Leave alone:** `Modules/Map/QuestieMapUtils.lua:55` "Add +1 to be above waypoint lines" is still true (paths 2015, icons 2016+), and it is master's.

---

## 7. Verification

**Targeted runs, in the rebased checkout:**

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

**Leftover check.** After F1 this must print nothing:

```sh
git grep -n -E "lineFrames|CreateWaypoints|IsLineFrame|DrawLineIcon|WAYPOINT_COLOR|zoneWaypoint(Hover)?ColorOverrides|Routes_Lines|linesAwaitingMotion|motionDriver|SetPropagateMouseMotion|\bLineFrame\b|savedIsLineFrame|_FallbackIconData|OwnWaypointMarker|IsCurrentObjective|waypointWork" -- ':!Blob' ':!.types' ':!docs/waypoints.md'
```

**In game.** Forever first, then Era. Turn blob mode on with Icons tab → "Questie blobs" preset.

1. **Normal-mode regression** (blob preset off). Horde, q1068 *Shredding Machines*, Stonetalon Mountains; XT:4 and XT:9 patrol there.
   - Both routes show in the hostile color on the world map and the minimap.
   - Hovering an XT icon highlights its route on both maps.
2. **Blob mode, same quest:**
   - Each XT route draws once, hostile.
   - Hovering the zone's owning marker highlights both routes. Both NPCs' routes attach to the last marker drawn in that zone, which is expected (R1).
   - Hovering a route opens that marker's tooltip. Per A's decision, it may also preview the objective's areas.
   - A plain left-click on the marker toggles areas, and the routes stay.
3. **Show on Map flash** (blob): the XT markers flash, only this objective's routes stay visible meanwhile, and all routes return after about 1 s.
4. **Route marker.** Undead Rogue, q1886 *The Deathstalkers*. Astor Hadren spawns in Silverpine and patrols into Tirisfal.
   - The Tirisfal map shows a marker at his patrol start carrying his Tirisfal route. Its tooltip names Astor Hadren after F1.
   - Silverpine shows his cluster marker with that zone's route.
5. **Minimap** (F2):
   - Blob-mode routes show around XT patrols and hide when "Enable Minimap Icons" is off. Cluster icons and areas hide with them.
   - Routes alone hide with "Enable Minimap Waypoints".
   - Hovering a minimap route shows the cluster's tooltip on `QuestieWaypointMinimapTooltip`.
6. **Leak check.** Count the registry with `/run local n=0 for _ in pairs(QuestieLoader:ImportModule("QuestieWaypoints").paths) do n=n+1 end print(n)`. Take a baseline with q1068 in blob mode. The count must match that baseline:
   - after killing one XT (a progress update);
   - after toggling the blob preset off and on (comparing like with like in each mode);
   - after `/reload`.

   It must drop after abandoning the quest.
7. **Combat.** `/reload` in combat with q1068 active in blob mode gives no "Interface action failed" and no Lua errors. This is `d9dc1ca4d`'s scenario.

---

## 8. Risks and open questions

| # | Risk or question | Recommendation |
|---|---|---|
| R1 | All patrols in a zone attach to that zone's last-drawn marker, in both normal and blob mode. Hovering another cluster in the same zone doesn't highlight them. | Keep it, for parity. If players notice, a later change can attach each route to the marker nearest its first point. |
| R2 | Routes ignore an objective's area visibility: marker click, quest log toggle and nearby mode. | Keep. Routes follow markers; areas are a separate overlay. |
| R3 | Hovering a polygon marker's route runs the marker's `OnEnter`, which previews the objective's areas (`WP WaypointHover.lua:53-56` → `B MapIconTooltip.lua:79`). | Accept: hovering a route means hovering its marker. Area A confirms. |
| R4 | Route markers name their own NPC (F1), while normal mode's fallback still uses `icon.data` of an arbitrary icon. | Accept the inconsistency. Fixing normal mode is out of scope; WP and master behave the same there. |
| R5 | Blob-mode route attachment yields every 30 attachments regardless of Hardcore. The old QuestieQuest loop used `TICKS_PER_YIELD`, which is 1 on Hardcore. | Area E decides polygon job budgets. The risk is low, because `QuestieWaypoints.Add` only builds polylines. |
| R6 | A released but still-queued marker keeps its routes until `ProcessQueue` finishes its unload (at most about 0.2 s). | Accept; WP's normal mode behaves the same. |
| R7 | A stale `minimapTwin` remains after its minimap icon is unloaded alone. | No production path unloads one alone, since all go through QuestiePolygon first. `MinimapAlpha`'s data check hides it. Accept. |
| R8 | **Pre-existing:** `QuestieQuest:ClearAllNotes` (`B QuestieQuest.lua:274-288`) unloads frames by name across yields. That is the same bug class as `83ef6e2fe`, and on WP a recycled frame would also lose another quest's routes. | Out of scope here. A separate fix should apply `83ef6e2fe`'s snapshot pattern to `ClearAllNotes`. |
| R9 | `--ours`/`--theirs` inversion during the rebase. | Use the explicit recipe in §4a. |
| Q1 | F1: move route attachment into QuestiePolygon and delete the token API? | **Yes.** |
| Q2 | F2: minimap routes in blob mode? | **Yes** (parity with normal mode, and WP's setting text stays accurate). |

---

## 9. Contracts with other areas

**Area A (hover arbitration).**
- I provide:
  - the deletion of `QuestieFramePool.IsLineFrame` and its test file;
  - R2's minimal `isCursorOnMap` (bare map only), so every replayed commit is free of nil calls;
  - the fact that paths take no mouse input, so a path never is or blocks the mouse focus.
- A owns:
  - the final `isCursorOnMap` and tooltip precedence (finding 7);
  - the stale "waypoint line" text in `Polygon/QuestiePolygon.test.lua:263` (`715031ef6`) and `Polygon/README.md:13, 110, 198`;
  - whether a route hover previews areas (R3).
- A must keep `WaypointHover` calling the owner icon's `OnEnter`/`OnLeave`. QuestiePolygon's marker preview relies on that.

**Area B (MapIconTooltip API).**
- B's merged `ShowOnTooltip` must:
  - keep WP's `QuestieWaypoints.SetHighlighted(self.data, true)` for every icon, polygon markers included (`WP MapIconTooltip.lua:117`), placed after the throttle return;
  - have no `self.data.lineFrames` and no `QuestieMap.zoneWaypointHoverColorOverrides`;
  - drop the `QuestieMap` import if nothing else uses it.
- `QuestieFrame.ResetHoverHighlights`, which is mine and WP's version, stays the one place that ends a hovered icon's route highlight.
- Recommended: area tooltips (`ShowForIcons` with owner `ScrollContainer`) do **not** highlight routes, so `Release` needs no unhighlight.
- `MapIconTooltip.test.lua` takes WP's stubs (`SetHighlighted`, `WaypointHover.End`) in place of master's `zoneWaypointHoverColorOverrides = {}`.

**Area D (minimap layer).**
- The shared minimap layer must keep collecting routes through `QuestieWaypoints.MinimapAlpha`. That is the twin rule in §3, invariant 4.
- Recommended draw order: routes above polygon area fills, matching the world map.
- After F2, a cluster's areas (`_CollectMinimapAreas` reads `marker.minimapIcons[1]`) and its routes (its twin) hide with the same minimap icon.
- D owns the README minimap section's wording; I supply the sentence about routes.

**Area E (geometry and scheduling).**
- `_AttachRoutes` yields every 30 steps, like marker allocation (`B QuestiePolygon.lua:1048`). E's polygon frame-budget primitive should replace both and settle the Hardcore question (R5).
- I add no geometry, and `QuestieWaypoints.Add`/`WaypointGeometry.BuildPolylines` are used unchanged.

**Orchestrator (README).**
- WP's "Minimap icons must be enabled too" wording stays correct after F2: cluster icons are the twins.
- The `--exec` command in §4a covers my files only. Combine it with the other areas' checks.
