# Legacy Questie custom blobs

## Source and scope

This is a source-based extraction of the unpublished custom polygon renderer in `W:\QuestieBackup\QuestieDev-master`, available here as `/mnt/w/QuestieBackup/QuestieDev-master`. Primary source references below resolve into this package's [`source/`](source/) tree, which preserves paths relative to that backup. This package keeps one primary implementation plus experimental references; see the [reading guide](README.md). The backup TOC identifies QuestieDev-Master 6.2.4, interface 11306 ([`QuestieDev-master.toc:1-5`](source/QuestieDev-master.toc#L1-L5)). That is a declared target, not proof of which client last ran it.

The backup was inspected read-only, including Git history and selected archive members streamed without extraction to disk. No legacy Lua was executed and no live client was touched. Runtime correctness and modern-client compatibility have not been established. This document distinguishes executable code from commented experiments.

## Summary

The integrated feature has two cooperating parts: `Blob` renders ordered outlines, while `QuestiePolygon` turns quest-objective spawn locations into those outlines and controls their visibility. The same clustering also replaces individual objective pins with representative cluster icons.

```text
Quest objective spawnList
  → omit rare/rare-elite NPCs
  → collect zone-percent points, grouped by UI map for polygon caching
  → greedy moving-center clustering, normally radius 180 world units
  → extreme-point prefilter
  → Jarvis gift-wrapping convex hull
  → Catmull-Rom spline samples
  → another convex hull
  → Ramer-Douglas-Peucker-style reduction, epsilon 0.03
  → reject small polygon areas, cutoff 0.9 in percent-coordinate units squared
  → cache ordered outlines by quest / objective / UI map
  → world-map textured fills and borders
  → optionally masked minimap fills through modified HBD-Pins
```

Hovering an objective icon temporarily displays that objective's blobs on the selected map. Clicking the icon on its own map toggles persistent blobs across its maps and on the minimap. Blob hover changes the border; it does not implement polygon-aware click-through or overlap selection. The detailed source references and exceptions follow.

## Spawn collection and clustering

### Current data source

`CachePolygon` reads the already-populated `QuestieDB:GetQuest(questId).Objectives[objectiveIndex].spawnList`. Entries contain `Type`, `Spawns`, and `TooltipKey`. NPC ranks 4 and 2 are excluded. It converts area IDs through `ZoneDB:GetUiMapIdByAreaId` and creates fresh point tables per UI map:

```lua
allPoints[uiMapId] = {
    {x = percentX, y = percentY, UiMapID = uiMapId, TooltipKey = tooltipKey},
    -- ...
}
```

The polygon path queries NPC rank using the spawn-list entry's key. The icon path instead uses `spawnData.Id`; that distinction should be checked when adapting a different spawn-list schema. Neither polygon collection nor clustering adds deduplication, a spatial index, terrain clipping, a concave hull, or density weighting ([`Modules/Map/QuestiePolygon.lua:157-195`](source/Modules/Map/QuestiePolygon.lua#L157-L195); [`Modules/Quest/QuestieQuest.lua:886-955`](source/Modules/Quest/QuestieQuest.lua#L886-L955)).

`GetSpawnData` and `GetAllPoints` retain an older database-query route. They gather creature/object objectives and item drops, but `CachePolygon` no longer calls them. The old item-NPC path groups entries by spawn count and sorts those keys. Equal counts overwrite one another, and the ascending sort does not establish the comment's promised common-first ordering. Treat this as historical code, not the actual runtime data source ([`QuestiePolygon.lua:126-151,162-173,631-735`](source/Modules/Map/QuestiePolygon.lua#L126-L151)).

### The actual clustering algorithm

`QuestiePolygon:CalcHotzones(points, rangeR, yield)` is a **greedy, order-dependent, moving-center radius algorithm**, not DBSCAN, k-means, or gift wrapping. Gift wrapping happens later to outline each cluster ([`QuestiePolygon.lua:444-548`](source/Modules/Map/QuestiePolygon.lua#L444-L548)).

For each untouched seed in the input traversal:

1. Mark the seed touched and start a cluster containing it.
2. Convert the center and candidates to HBD world coordinates.
3. First pass: admit untouched candidates on the same UI map when their distance from the current center is strictly less than the radius. After each admission, replace the center with the arithmetic mean of all current members.
4. Second pass: scan untouched points again, allowing points missed before the center moved to join. After each admission, replace the center with the midpoint between the cluster's arithmetic mean and its axis-aligned bounding-box center.
5. Append the cluster and continue with the next untouched seed.
6. After all points are consumed, clear their temporary `touched` fields and return the clusters.

The first-pass center is `MapLib:CenterPoint`. The second-pass center is `MapLib:AvgAbsCenterPoint`, explicitly labeled untested in the source ([`Modules/NewMap/MapLib.lua:49-123`](source/Modules/NewMap/MapLib.lua#L49-L123)). It is not the polygon area centroid used later for icon placement.

```text
mean = sum(points) / count
boxCenter = ((minX + maxX) / 2, (minY + maxY) / 2)
secondPassCenter = (mean + boxCenter) / 2
```

This performs two candidate passes per cluster, not repeated convergence until membership stabilizes. Points already admitted are never expelled when the center moves, so the final cluster is not guaranteed to fit within the radius around its final center. The algorithm aims to reduce overlap through the second pass; it does not guarantee disjoint hulls.

### Parameters and coordinate units

| Parameter | Actual active value/use |
| --- | --- |
| `POLYGON_CLUSTER_AMOUNT` | Global value `180`; used by cached polygons and ordinary objective-icon clustering. |
| `rangeR` omitted | `CalcHotzones` falls back to `100`. |
| Object-icon clustering | Uses `35`, not 180. Cached object polygons still use 180. |
| `clusterLevelHotzone` | Setting defaults to `70`, but the icon path immediately overwrites it with `POLYGON_CLUSTER_AMOUNT`. |
| `areaCutoff` | `0.9`, applied after smoothing/reduction in the polygon cache, not the icon path. |

Sources: [`QuestiePolygon.lua:32-33,215-245,455`](source/Modules/Map/QuestiePolygon.lua#L32-L33); [`QuestieQuest.lua:967-972`](source/Modules/Quest/QuestieQuest.lua#L967-L972); [`Modules/Options/QuestieOptionsDefaults.lua:7`](source/Modules/Options/QuestieOptionsDefaults.lua#L7).

Distance is Euclidean distance between HBD world coordinates, conventionally yards, not distance in pixels or map percentages. The code guesses input units once per seed: it scales by `0.01` only if **both** seed coordinates exceed 1. This is not a reliable input-unit contract for percentage coordinates near zone edges. The chosen factor is reused after the center moves ([`QuestiePolygon.lua:469-529`](source/Modules/Map/QuestiePolygon.lua#L469-L529)).

### Clustering limitations

- `pairs` traversal and sequential center updates make results dependent on input order. Sorting ideas in comments are not a stable-order guarantee.
- The second candidate pass lacks the first pass's same-map check. Polygon caching supplies per-map arrays, but objective-icon clustering can supply a mixed-map array. HBD instance IDs are ignored, allowing unrelated world-coordinate spaces to be compared.
- Failed HBD coordinate conversions fall back to zero per component, which can manufacture proximity rather than reject invalid points.
- `AvgAbsCenterPoint` returns accumulated sums instead of an average when its extrema guard fails, including some zero-X cases ([`MapLib.lua:109-122`](source/Modules/NewMap/MapLib.lua#L109-L122)).
- There is no spatial acceleration. Candidate scans plus repeated whole-cluster center calculations give quadratic worst-case work. The checklist explicitly calls out incremental averaging as unfinished.
- With `yield = true`, the yield occurs after the outer traversal has processed all untouched seeds. It does not time-slice individual candidate loops or hull/spline work. The coroutine wrapper therefore does not establish a tight frame-time budget.

Sources: [`QuestiePolygon.lua:457-546`](source/Modules/Map/QuestiePolygon.lua#L457-L546); [`MapLib.lua:88-123`](source/Modules/NewMap/MapLib.lua#L88-L123); [`Checklist.txt:19`](source/Checklist.txt#L19).

### Disabled postprocessing

`PostProcessHotzone` calculates each cluster's bounding-box center, then reassigns every point to the nearest original center. It does one reassignment pass; it does not recompute centers to convergence. All calls in the active polygon and icon pipelines are commented out ([`QuestiePolygon.lua:216,224,550-630`](source/Modules/Map/QuestiePolygon.lua#L216); [`QuestieQuest.lua:993`](source/Modules/Quest/QuestieQuest.lua#L993)).

Other commented experiments at the bottom of [`QuestiePolygon.lua:737-905`](source/Modules/Map/QuestiePolygon.lua#L737-L905) attempt hull containment and merging of overlapping polygons. Their presence does not establish working polygon union or overlap removal.

## Gift wrapping, smoothing, and reduction details

### Interior-point preprocessing

`PreprocessHull` finds the leftmost, rightmost, topmost, and bottommost input points, constructs a four-point polygon in the order **minX, maxX, minY, maxY**, and removes points passing the odd/even inside test ([`Modules/Blob/BlobUtil.lua:105-159`](source/Modules/Blob/BlobUtil.lua#L105-L159)).

The intention is to reduce the number of points reaching the hull builder. However, those extremes are not explicitly ordered around their perimeter, duplicates are not removed, and boundary points have no dedicated preservation rule. This is not a verified safe convex-hull prefilter. Keep it distinguishable from the hull algorithm itself when extracting or testing it.

### Jarvis march

`Blob.util:jarvis_march(points)` returns the hull and the selected original point indexes. It returns nil for fewer than three input points ([`BlobUtil.lua:28-69`](source/Modules/Blob/BlobUtil.lua#L28-L69)).

- Start from the point with minimum X; equal-X ties keep the earlier index.
- Initialize the next candidate to the next array index, wrapping to 1.
- Scan every point, replacing the candidate on the strict counterclockwise orientation test.
- Append the chosen candidate and continue until reaching the starting index.
- Stop defensively if the iteration count exceeds 2000; no error reports that truncation.

The orientation uses a cross-product sign. The returned list starts with the next hull vertex and includes the leftmost starting vertex at the end; it does not add a separate duplicate closure vertex. Complexity is `O(nh)`, with `n` input points and `h` selected hull vertices, becoming quadratic when most points lie on the hull.

There is **no farthest-point tie-break for collinear candidates**, no deduplication, and no degenerate-input validation. The cap bounds runaway wrapping but does not prove the returned outline is complete or drawable. Keep the actual implementation separate from guarantees normally associated with a robust Jarvis implementation.

### Smoothing is not concave geometry

After the first hull, `CalcSpine` samples a Catmull-Rom curve and then gift-wraps the sample cloud again. The second hull deliberately discards inward excursions. This is a smoothed **convex envelope**, not a terrain-following or concave region. It may fill empty space between spawns; no walkability, obstacles, holes, or connected-component semantics are represented ([`Modules/Blob/Blob.lua:147-270`](source/Modules/Blob/Blob.lua#L147-L270)).

Sampling omits segment endpoints, and reduction discards vertices. There is no final check that the output contains every original spawn. "Convex envelope" describes the constructed shape, not a verified enclosure guarantee after all transformations.

### Point reduction and area

The embedded Bezier helper's `reduce(0.03)` keeps first/last points and recursively keeps the farthest point when its reported line distance is at least epsilon. It treats the outline as an open chain during reduction, with closure supplied later by drawing. Its `pointLineDistance` returns `triangleArea / baseLength`, which is **half the geometric perpendicular distance**; a true distance of approximately `0.06` corresponds to epsilon `0.03`. It uses distance to the infinite line rather than a clamped line segment and does not guard coincident endpoints ([`BlobUtil.lua:465-521`](source/Modules/Blob/BlobUtil.lua#L465-L521)).

The cache calls `CalculateArea(points, 0.9)`, which sums signed triangle areas around the vertex mean and returns early once the partial sum is greater than the cutoff. Thus its area result can be partial, and reversing winding can change acceptance. Units are squared zone-percentage units, not square yards or pixels. A cutoff of 0.9 is nominally 0.009% of a full 100×100 zone rectangle, with different physical area on different maps. A nonempty polygon is retained only when the returned `bigEnough` flag is true ([`BlobUtil.lua:71-103`](source/Modules/Blob/BlobUtil.lua#L71-L103); [`QuestiePolygon.lua:235-245`](source/Modules/Map/QuestiePolygon.lua#L235-L245)).

## Quest integration and lifetime

### Two related but separate products

1. **Representative objective icons:** `QuestieQuest` collects candidate spawn icons, clusters them, and places one icon per cluster. For fewer than three points it uses the arithmetic mean. Otherwise it builds the processed outline, uses its area-weighted polygon centroid, and falls back to the original points' mean when no centroid exists. This path does not apply the polygon area cutoff ([`Modules/Quest/QuestieQuest.lua:886-1093`](source/Modules/Quest/QuestieQuest.lua#L886-L1093); [`BlobUtil.lua:240-289`](source/Modules/Blob/BlobUtil.lua#L240-L289)).
2. **Area overlays:** `QuestiePolygon` separately reads the objective's spawn list, builds/caches qualifying outlines, and supplies them to `Blob`. The representative icon acts as the hover/click entry point; icon clustering does not itself register blob records.

The selected cluster's first point supplies icon metadata and ownership references. The code assumes its members can share that metadata. It clears `ClusterId` to bypass older clustering. The active path also bypasses the old distance-sorting helper, leaves the icon-limit `break` commented out, and ends an experimental filtering condition with `or true == true`, making it unconditional ([`QuestieQuest.lua:964-1093`](source/Modules/Quest/QuestieQuest.lua#L964-L1093)).

### User interaction

| Action | Adapter behavior |
| --- | --- |
| Hover an objective icon | The tooltip path calls `AddObjective` with the icon glow color. It excludes available, complete, and manual icon types. Draws the priority map only by default. |
| Leave an objective icon | Calls `RemoveObjective`; persistent toggles are retained. |
| Click an icon while viewing another map | Navigates to the icon's map. |
| Non-right click on its own map | Calls `ToggleObjective` for icon types other than available/complete. The click guard notably does not exclude manual icons as the hover guard does. |
| Toggle on | Force-removes existing temporary frames, calls `AddObjective(..., true)`, then records the toggle. All cached maps and minimap frames are eligible. |
| Toggle off | Clears the toggle and schedules removal. |
| Hover a blob | Changes its border through adapter callbacks; no quest tooltip is built by these callbacks. |

Sources: [`Modules/FramePool/QuestieFramePool.lua:677-710`](source/Modules/FramePool/QuestieFramePool.lua#L677-L710); [`Modules/FramePool/QuestieFrame.lua:128-194`](source/Modules/FramePool/QuestieFrame.lua#L128-L194); [`QuestiePolygon.lua:272-375`](source/Modules/Map/QuestiePolygon.lua#L272-L375).

`QuestiePolygon.Initialize` subscribes to abandoned, completed, turned-in, and updated messages. `QuestieEventNEW` schedules that initialization on the quest-initialized message ([`Modules/Event/QuestieEventNEW.lua:183`](source/Modules/Event/QuestieEventNEW.lua#L183); [`QuestiePolygon.lua:36-46`](source/Modules/Map/QuestiePolygon.lua#L36-L46)).

### Cache, scheduling, and ownership

| Table | Key/ownership |
| --- | --- |
| `hotzoneCache` | `[questId][objectiveIndex][uiMapId] = processed outlines` |
| `PolygonQueueRoutine` | `[questId][objectiveIndex] = coroutine` |
| `PolygonList` | `[questId][objectiveIndex] = world-map blob records` |
| `allFrames` | `[questId][objectiveIndex] = pooled minimap frames` |
| `toggledPolygonList` | `[questId .. "-" .. objectiveIndex] = true` |
| `Blob.DrawData` | `[uiMapId][record] = record`; renderer-level world-map registrations |
| HBD-Pins registration | Owner string `questId .. "-" .. objectiveIndex` |

`CachePolygon` prioritizes `WorldMapFrame:GetMapID()`, falling back to the player's map. A zero-interval ticker resumes its coroutine. The coroutine yields after clustering and when publishing each map. The ticker then performs smoothing, reduction, and filtering outside the coroutine, stores the outlines, and optionally draws them. Cached tables are session-local, not SavedVariables ([`QuestiePolygon.lua:49-120,157-269`](source/Modules/Map/QuestiePolygon.lua#L49-L120)).

Normal removal uses another zero-interval ticker to wait until generation is dead, then removes registrations and releases minimap frames unless the objective is toggled. Objective completion force-removes that objective's displayed frames. Whole-quest removal also clears its geometry cache ([`QuestiePolygon.lua:330-353,378-430`](source/Modules/Map/QuestiePolygon.lua#L330-L353)).

### Adapter lifetime risks to resolve before reuse

These are static source findings, not observed live failures:

- `coroutine.resume`'s success result is stored but never checked or reported. Errors can leave partially initialized cache/display state ([`QuestiePolygon.lua:233-263`](source/Modules/Map/QuestiePolygon.lua#L233-L263)).
- On each newly cached map, `DrawPolygon` iterates **all maps already cached**. With `addAll = true`, this re-adds earlier world records and minimap frames, so multi-map generation can duplicate overlays ([`QuestiePolygon.lua:110-120,249-251`](source/Modules/Map/QuestiePolygon.lua#L110-L120)).
- Force-removal does not cancel the generation coroutine/ticker. Whole-quest removal clears tables the outstanding generation callback still expects; objective removal can also race later drawing ([`QuestiePolygon.lua:233-263,378-418`](source/Modules/Map/QuestiePolygon.lua#L233-L263)).
- Force-removal does not clear `toggledPolygonList` or `PolygonQueueRoutine`. A completed/abandoned quest can leave stale toggle state for later acceptance ([`QuestiePolygon.lua:378-430`](source/Modules/Map/QuestiePolygon.lua#L378-L430)).
- `ToggleObjective` indexes `PolygonQueueRoutine[questId]` without guarding the quest-level table. Hover-before-click may normally populate it, but direct calls have a hidden precondition ([`QuestiePolygon.lua:272-287`](source/Modules/Map/QuestiePolygon.lua#L272-L287)).
- Removing one objective leaves its geometry cache intact. There is no explicit cache revision for changed spawn data, options, clustering radius, or provider corrections.
- `QuestieQuest:ClearAllNotes` calls `Blob:RemoveAllBlobs`, which only clears renderer records. It is not a substitute for adapter cache/toggle/minimap teardown ([`QuestieQuest.lua:252-270`](source/Modules/Quest/QuestieQuest.lua#L252-L270); [`Blob.lua:370-371`](source/Modules/Blob/Blob.lua#L370-L371)).

## Renderer architecture

This is a custom texture renderer, not a wrapper around Blizzard's native quest-blob data. It accepts point arrays, optionally constructs a smooth convex outline, builds a fan of deformed quadrilateral textures, draws separate outline textures, and installs world-map pins or minimap frames. The active drawing path uses `Texture:SetVertexOffset`, `SetTexCoord`, `AddMaskTexture`, and texture-backed `DrawLine`; it does not ask the native quest-blob renderer to fill the polygon ([`Modules/Blob/Blob.lua:373-601`](source/Modules/Blob/Blob.lua#L373-L601); [`Modules/Blob/BlobTexturePool.lua:95-134`](source/Modules/Blob/BlobTexturePool.lua#L95-L134)).

| File | Responsibility |
| --- | --- |
| [`Modules/Blob/Blob.lua`](source/Modules/Blob/Blob.lua) | Public blob-record API; outline processing; texture geometry; shared minimap masks; development slash command. |
| [`Modules/Blob/BlobUtil.lua`](source/Modules/Blob/BlobUtil.lua) | Hull/area/center helpers, point-in-polygon test, embedded Bezier utilities and point reduction. |
| [`Modules/Blob/BlobFramePool.lua`](source/Modules/Blob/BlobFramePool.lua) | World-map button pool and minimap frame pool; release of constituent fill and outline textures. |
| [`Modules/Blob/BlobTexturePool.lua`](source/Modules/Blob/BlobTexturePool.lua) | Fill-texture pool, texture-backed line pool, redraw helper, asset selection. |
| [`Modules/Blob/BlobMap.lua`](source/Modules/Blob/BlobMap.lua) | World-map provider, pin mixin, mouse forwarding, polygon hover polling. |
| [`Modules/Map/QuestiePolygon.lua`](source/Modules/Map/QuestiePolygon.lua) | Quest/objective-specific orchestration outside the renderer: cached outlines, world/minimap registration, hover styling, cleanup. |
| [`Libs/HereBeDragons/HereBeDragons-Pins-2.0.lua`](source/Libs/HereBeDragons/HereBeDragons-Pins-2.0.lua) | **Modified dependency** that recognizes large minimap polygon frames and handles their scale/position. |

All five blob files are active TOC entries, after [`Modules/Map/QuestiePolygon.lua`](source/Modules/Map/QuestiePolygon.lua), in this order: [`Blob.lua`](source/Modules/Blob/Blob.lua), [`BlobUtil.lua`](source/Modules/Blob/BlobUtil.lua), [`BlobFramePool.lua`](source/Modules/Blob/BlobFramePool.lua), [`BlobTexturePool.lua`](source/Modules/Blob/BlobTexturePool.lua), [`BlobMap.lua`](source/Modules/Blob/BlobMap.lua). `Modules/Map/Polygon.lua` is commented out. HBD and HBD-Pins load near the beginning of the TOC ([`QuestieDev-master.toc:15-21,130-138`](source/QuestieDev-master.toc#L15-L21)).

`Blob` is a QuestieLoader module. `Blob.util`, `.FramePool`, `.MinimapFramePool`, `.TexturePool`, `.LinePool`, and `.Map` are fields added by the other files. `BlobMapProvider` and `BlobMapPin` are globals. Pool creation functions refer to `BlobMapPin` when acquiring a frame, not when defining the pool, so the current order relies on actual acquisitions happening after [`BlobMap.lua`](source/Modules/Blob/BlobMap.lua) loads ([`BlobFramePool.lua:17-34,87-112`](source/Modules/Blob/BlobFramePool.lua#L17-L34); [`BlobMap.lua:11,109`](source/Modules/Blob/BlobMap.lua#L11)).

## Blob records and callable API

The methods below use colon syntax. Points are ordinary arrays of `{x = number, y = number}` in **zone percentages, 0–100**, not the normalized coordinates expected by map pins. The drawing code divides by 100. `UiMapID` is a UI-map ID, not a legacy area ID ([`Blob.lua:292-359,532-599`](source/Modules/Blob/Blob.lua#L292-L359)).

```lua
local drawData = {
    UiMapID = uiMapId,
    points = orderedOutlinePoints,
    texData = {r = r, g = g, b = b, a = alpha},
    lineData = {r = r, g = g, b = b, a = alpha, thickness = pixels},
    pinTemplate = "BlobWorldmapTemplateQuestie", -- or BlobMinimapTemplateQuestie
    overrideFunctions = callbacks,
}
```

| Method | Actual behavior |
| --- | --- |
| `Blob:CalcSpine(points)` | Returns the processed outline; the misspelling `Spine` is the actual API name. |
| `Blob:AddBlob(uiMapId, points, texData, lineData, callbacks)` | Calls `CalcSpine`, then `AddBlobRaw`. |
| `Blob:AddBlobRaw(uiMapId, points, texData, lineData, callbacks)` | Accepts an already ordered outline. If there are at least three points, returns a record and, if a map ID is supplied, stores it in `Blob.DrawData[uiMapId][record] = record`. Does not draw immediately. |
| `Blob:AddMinimapBlob(...)` | Calls `CalcSpine`, then `AddMinimapBlobRaw`. |
| `Blob:AddMinimapBlobRaw(...)` | Returns an analogous minimap record but does **not** register it in `DrawData` or allocate a frame. |
| `Blob:DrawPointList(frame, record, masks)` | Populates an acquired frame, creates fill/outline textures, sets geometry and scale metadata, and shows the frame. Returns the frame. |
| `Blob:DrawSquare(frame, a, b, c, center)` | Acquires/configures a quadrilateral fill texture and returns normalized min/max bounds. Internal drawing building block. |
| `Blob:RemoveBlob(record)` | Deletes the world-map record from `DrawData`. Does not release an already visible pin or remove a minimap frame. |
| `Blob:RemoveAllBlobs()` | Replaces `DrawData` with `{}`. Also does not itself release visible pins/minimap frames. |

Sources: [`Blob.lua:147-371,373-601`](source/Modules/Blob/Blob.lua#L147-L371).

Important contract details:

- The admission check is `#points > 2`, despite comments saying four points are required ([`Blob.lua:307-317,351-359`](source/Modules/Blob/Blob.lua#L307-L317)).
- Raw methods do not validate convexity, winding, uniqueness, finite coordinates, or nonzero area. They retain the caller's point/style/callback tables by reference ([`Blob.lua:292-359`](source/Modules/Blob/Blob.lua#L292-L359)).
- The documentation calls `UiMapID` optional, and record construction allows nil, but `DrawPointList` still calls HBD with that ID to calculate minimap scaling even for a world-map frame. A record without an ID is not demonstrated to be drawable ([`Blob.lua:442-461`](source/Modules/Blob/Blob.lua#L442-L461)).
- `texData` is stored but the active fill code uses **`lineData`** for its vertex color. Fill alpha defaults to `0.3`; outline alpha defaults to `0.6`; outline RGB defaults to red and thickness to `1.5`. Fill RGB has no corresponding defaults. Pass a non-nil `lineData` with numeric RGB fields ([`Blob.lua:117-120,296-299,514-515`](source/Modules/Blob/Blob.lua#L117-L120)).
- Only the two polygon enter/leave callbacks are actually dispatched through `overrideFunctions`. They are called as methods on the callback table, with the pin as the next argument, e.g. `callbacks:OnMouseEnterPolygon(pin)`. The source comment implying broadly overridable click/pan functions is wider than the implemented dispatch ([`BlobMap.lua:111-169`](source/Modules/Blob/BlobMap.lua#L111-L169)).

## Outline preprocessing at the renderer boundary

`Blob:CalcSpine` implements this active pipeline ([`Blob.lua:147-270`](source/Modules/Blob/Blob.lua#L147-L270)):

1. Clear one shared two-dimensional Catmull-Rom spline object, created at file load.
2. Run `Blob.util:PreprocessHull` to attempt to discard interior points.
3. Run `Blob.util:jarvis_march` for a convex hull. Return `{}` when it returns nil.
4. Add the hull's last point, every hull point, and the first point to the spline. This extends the endpoints around the closure.
5. For local segment indices `2 .. spline:GetNumPoints()`, sample `t = 0.1, 0.2, ... 0.9`. The `t = 1` sample is explicitly skipped.
6. Run Jarvis march again on the samples to remove spline-induced loops, producing a convex result rather than preserving a potentially concave spline.
7. Initialize the shared `Blob.util.Bezier` object, set those points, and call `reduce(0.03)`.
8. Clear the spline and return the reduced point array.

The active smoothing is **Catmull-Rom**, not a Bezier fit. The embedded Bezier module contributes its Ramer-Douglas-Peucker-style reduction, not `createQuadraticCurve` or `createCubicCurve`. The local `pPerDist = 0.7` and `pStep = 1` variables are remnants; the active sampler uses the fixed 0.10 step. The local area-filtering block in `CalcSpine` is commented out ([`Blob.lua:147-151,177-270`](source/Modules/Blob/Blob.lua#L147-L151); [`BlobUtil.lua:420-520`](source/Modules/Blob/BlobUtil.lua#L420-L520)).

The backup includes a copy of Blizzard's spline implementation for reference: [`BlizzLibs/SharedXML/Spline.lua:73-161`](source/BlizzLibs/SharedXML/Spline.lua#L73-L161). Its `AddPoint` also duplicates endpoint storage internally. `BlizzLibs` is not in this addon's active TOC, so that source copy is evidence about the anticipated API, not a bundled runtime dependency.

## Fill geometry and outline drawing

### Convex fan made from distorted textures

`DrawPointList` computes the **arithmetic mean of the outline vertices**, not the polygon's area centroid. This is its fan center ([`Blob.lua:390`](source/Modules/Blob/Blob.lua#L390); [`BlobUtil.lua:162-178`](source/Modules/Blob/BlobUtil.lua#L162-L178)).

It advances through the outline two edges at a time: `(P1,P2,P3,center)`, `(P3,P4,P5,center)`, and so on. Each group becomes one quadrilateral texture. Odd final counts use a degenerate quadrilateral to close a single triangle; even counts use the first and last two points to close the remaining pair of edges. There are approximately half as many fill textures as outline points: specifically `ceil(n/2)` for the loop as written ([`Blob.lua:392-426`](source/Modules/Blob/Blob.lua#L392-L426)).

`DrawSquare` checks the orientation of its three outer points. It swaps the first and third when necessary, assigning corners as follows:

```text
upper-left  = one outer endpoint
upper-right = intervening outer point
lower-right = other outer endpoint
lower-left  = arithmetic-mean center
```

It stores normalized map-space vertex coordinates in `ULv`, `URv`, `LLv`, `LRv`, and standard texture corners in `ULt`, `URt`, `LLt`, `LRt`. It selects `Blob.TexturePool.TEXTURE.path`, which is `Icons\\square` ([`Blob.lua:532-601`](source/Modules/Blob/Blob.lua#L532-L601); [`BlobTexturePool.lua:125-134`](source/Modules/Blob/BlobTexturePool.lua#L125-L134)).

This is not general polygon triangulation: there is no ear clipping, hole support, or concave-polygon decomposition. The processed API makes a convex hull before rendering. Passing arbitrary concave outlines to the raw API can invalidate the center-fan assumption.

### Bounding frame and coordinate conversion

The renderer finds the combined normalized bounds of all quads, then:

- Sets `fCenterX/fCenterY` to the normalized bounding-box center.
- Measures the current `WorldMapFrame:GetCanvas()` width and height.
- Sets frame size to `(maxX-minX)*canvasWidth` by `(maxY-minY)*canvasHeight`.
- Positions the world-map pin at the bounding-box center using `SetPosition` through `pcall`.
- Converts each stored vertex to pixel offsets relative to the top-left of that frame.
- Calls `SetVertexOffset` for all four texture corners, with Y signs changed to match WoW anchor coordinates.
- Applies normal full-texture UV coordinates, nearest sampling, vertex tint, optional masks, and shows each texture.

Sources: [`Blob.lua:427-530`](source/Modules/Blob/Blob.lua#L427-L530).

The renderer always parents/constructs geometry against the world-map canvas first, including minimap frames. HBD reparents minimap frames afterward. This is a concrete coupling to remove or retain deliberately during extraction, not a generic render-to-any-parent API ([`Blob.lua:438-463`](source/Modules/Blob/Blob.lua#L438-L463); [`HereBeDragons-Pins-2.0.lua:650-651`](source/Libs/HereBeDragons/HereBeDragons-Pins-2.0.lua#L650-L651)).

### Outline textures

For each quad the renderer attempts to draw only the two outer edges, `UL→UR` and `UR→LR`, excluding edges that touch the fan center. It creates pooled texture lines rather than WoW `Line` regions. Each receives endpoints in frame-local pixels, color, thickness, and optional masks ([`Blob.lua:87-136,468-480`](source/Modules/Blob/Blob.lua#L87-L136)).

The texture-backed line uses Blizzard's `LineMixin` to store endpoints and thickness, and `DrawLine` to compute a rotated texture's bounding rectangle and UV coordinates. `redraw(line, zoomScale)` passes thickness divided by the supplied scale so minimap zoom need not make borders proportionally thicker ([`BlobTexturePool.lua:95-122`](source/Modules/Blob/BlobTexturePool.lua#L95-L122)). The backup's reference implementation is [`BlizzLibs/FrameXML/MixinUtil.lua:1-98`](source/BlizzLibs/FrameXML/MixinUtil.lua#L1-L98); it describes `DrawLine` as used with permission from Daniel Stephens.

Both fill and outline textures disable pixel-grid snapping and use zero texel-snapping bias ([`BlobTexturePool.lua:50-60,100-117`](source/Modules/Blob/BlobTexturePool.lua#L50-L60)).

## World-map lifecycle and frame pools

The world-map pool creates `BUTTON` frames mixed with `BlobMapPin`. The template name `BlobWorldmapTemplateQuestie` is a **pool key**, not an XML template declaration: the code directly places the custom pool into `WorldMapFrame.pinPools`. The minimap pool separately creates `FRAME` objects with a `redrawAllLines` method ([`BlobFramePool.lua:8-34,75-112`](source/Modules/Blob/BlobFramePool.lua#L8-L34)).

`BlobMapProvider` is built from `MapCanvasDataProviderMixin` and registered immediately with `WorldMapFrame:AddDataProvider`. Its refresh looks up only `Blob.DrawData[currentMapId]`, acquires a world pin for each record, and calls `DrawPointList`. Changing maps releases all world blob pins before redrawing. Hiding the world map also releases them. `RefreshAllData(true)` explicitly releases first; `RefreshAllData(false)` assumes an already blank map ([`BlobMap.lua:11-69,237`](source/Modules/Blob/BlobMap.lua#L11-L69)).

`BlobMapPin:OnAcquired` uses `PIN_FRAME_LEVEL_QUEST_BLOB`; its `frameLevel` argument is ignored. The map's pin API supplies the mouse scripts and calls acquisition hooks. The backup's copied `MapCanvasMixin:AcquirePin` makes this dependency explicit ([`BlobMap.lua:180-188`](source/Modules/Blob/BlobMap.lua#L180-L188); [`BlizzLibs/AddOns/Blizzard_MapCanvas/Blizzard_MapCanvas.lua:128-168`](source/BlizzLibs/AddOns/Blizzard_MapCanvas/Blizzard_MapCanvas.lua#L128-L168)).

Pool release clears record references, releases every fill texture and line, replaces those lists with empty tables, hides the frame, and clears anchors. Texture/line reset removes every registered mask before reuse. This was meant to prevent stale geometry and masks from reappearing on recycled frames ([`BlobFramePool.lua:36-71,114-146`](source/Modules/Blob/BlobFramePool.lua#L36-L71); [`BlobTexturePool.lua:14-48,71-93`](source/Modules/Blob/BlobTexturePool.lua#L14-L48)).

`DrawPointList` does not itself release a frame's old textures. Its contract is effectively "populate a freshly acquired/reset frame", not "replace arbitrary existing geometry" ([`Blob.lua:373-426,466-530`](source/Modules/Blob/Blob.lua#L373-L426)).

## Minimap rendering and modified HBD

### Registration flow

The quest adapter's active minimap path is:

```text
AddMinimapBlobRaw(mapId, outline, color, color, {})
  → Blob.MinimapFramePool:Acquire()
  → DrawPointList(frame, record, {Blob.minimapMask, Blob.playerMask})
  → Hide frame until HBD positions it
  → HBDPins:AddMinimapIconMap(objectiveKey, frame, mapId,
                             frame.fCenterX, frame.fCenterY, true, false)
```

The HBD registry reference is the string `questId .. "-" .. objectiveIndex`. Parent-zone display is enabled; floating on the minimap edge is disabled. The adapter retains the frame separately for pool release ([`Modules/Map/QuestiePolygon.lua:85-106`](source/Modules/Map/QuestiePolygon.lua#L85-L106)).

### Scaling

`DrawPointList` queries HBD world coordinates for zone corners `(0,0)` and `(1,1)`. It derives the zone world width, the blob bounding-box world width, and two base scale factors. The assumed zoom-zero minimap widths are `466 + 2/3` outdoors and `300` indoors. It uses minimap width, not separate X/Y transforms ([`Blob.lua:450-463`](source/Modules/Blob/Blob.lua#L450-L463)).

The modified HBD-Pins has indoor multipliers `[1,1.25,5/3,2.5,3.75,6]` and outdoor multipliers `[1,7/6,1.4,1.75,7/3,3.5]` for zoom levels 0–5. A pin with `minimapScale` takes a special branch: scale equals the zoom multiplier times its indoor/outdoor base scale; center offsets are divided by that scale; outlines are redrawn on zoom/indoor-state changes ([`HereBeDragons-Pins-2.0.lua:49-85,174-194`](source/Libs/HereBeDragons/HereBeDragons-Pins-2.0.lua#L49-L85)). Initial registration also applies this scaling before queuing the regular position update ([`HereBeDragons-Pins-2.0.lua:610-651`](source/Libs/HereBeDragons/HereBeDragons-Pins-2.0.lua#L610-L651)).

Large pins are permitted beyond the usual center-distance cutoff: the special branch uses `dist <= 6 + lastZoom`, not a test of the polygon's actual bounds. Here `dist` is a squared normalized distance for round minimaps or the corresponding max-component measure for square regions. Very large polygons can therefore overlap the minimap while their center falls outside that heuristic ([`HereBeDragons-Pins-2.0.lua:132-213`](source/Libs/HereBeDragons/HereBeDragons-Pins-2.0.lua#L132-L213)).

HBD's rotation path rotates the pin's **center offset**. The blob textures have no corresponding orientation update in these files. Rotating-minimap correctness is therefore not established and the visible geometry is not rotated by this implementation ([`HereBeDragons-Pins-2.0.lua:132-144,174-194`](source/Libs/HereBeDragons/HereBeDragons-Pins-2.0.lua#L132-L144); [`Blob.lua:491-530`](source/Modules/Blob/Blob.lua#L491-L530)).

### Masks

At file load the renderer creates two masks on `Minimap`:

- `Blob.minimapMask` tracks the minimap shape texture and covers the minimap.
- `Blob.playerMask` uses `Icons\\playermask`, centered at 38×38 UI units.

Both are applied to fill and outline textures on the minimap path. The player mask's intended exclusion around the player follows its name and placement; this inspection did not decode the texture's alpha data ([`Blob.lua:34-60,117-126,517-523`](source/Modules/Blob/Blob.lua#L34-L60)).

To discover the minimap shape, the code **replaces `Minimap.SetMaskTexture`** with a wrapper, stores the supplied path in a global `MinimapMaskTexture`, and updates its own mask before calling the captured original method. A half-second ticker waits for a path; after `count > 10`, it uses the bundled `Icons\\circlemask` fallback. The comment claiming 60 seconds does not match the code, which reaches the fallback at roughly six seconds. The ticker stops once the masks are set. Debug prints remain active, and there is no disable-time restoration of the replaced method in these files ([`Blob.lua:34-85`](source/Modules/Blob/Blob.lua#L34-L85)).

### Minimap teardown

Removing an objective must do both operations: remove its HBD registry entries and release its frames to `Blob.MinimapFramePool`. `Blob:RemoveBlob` alone does neither. The adapter implements both steps ([`Modules/Map/QuestiePolygon.lua:330-353,378-416`](source/Modules/Map/QuestiePolygon.lua#L330-L353)).

## Waypoint lines and the black-bordered texture

The related waypoint renderer actively selects `Icons\\Raw\\Exported\\WHITE32X32BLACKLINES`, unlike the blob renderer where that selection is commented out. Both the original [BLP](source/Icons/Raw/Exported/WHITE32X32BLACKLINES.blp) and [PNG](source/Icons/Raw/Exported/WHITE32X32BLACKLINES.png) are preserved. Visual inspection of the PNG confirms a white middle with black bands above and below. Tinting colors the white portion while leaving the black bands black, giving each waypoint segment an outline without drawing separate border lines ([`WaypointFramepool.lua:150–174`](source/Modules/NewMap/Waypoints/WaypointFramepool.lua#L150-L174); [`BlobTexturePool.lua:109–114`](source/Modules/Blob/BlobTexturePool.lua#L109-L114)).

The waypoint implementation has its own frame/line pools and minimap masks. `WaypointPin:DrawLine` calculates segment geometry and indoor/outdoor scale factors. `AvailableWaypoints` acquires minimap frames, draws with the boundary and player masks, and registers each segment with HBD at its midpoint. Cleanup removes the HBD registration and releases the frame ([`WaypointPin.lua:52–117`](source/Modules/NewMap/Waypoints/WaypointPin.lua#L52-L117); [`AvailableWaypoints.lua:51–89`](source/Modules/Quest/Available/AvailableWaypoints.lua#L51-L89)).

The modified HBD-Pins recognizes these frames through `minimapScale`. Its line-specific branch compensates thickness for the applied scale and redraws on zoom/indoor-state changes, alongside the blob-specific multi-line branch ([`HereBeDragons-Pins-2.0.lua:174–194`](source/Libs/HereBeDragons/HereBeDragons-Pins-2.0.lua#L174-L194)).

This confirms the same project contains the outlined minimap-waypoint implementation. It does not establish that every legacy waypoint call path was connected: the old `QuestieMap:DrawWaypoints` drawing body is commented out, while `AvailableWaypoints` supplies the newer path ([`QuestieMap.lua:914–925`](source/Modules/Map/QuestieMap.lua#L914-L925)). No waypoint runtime validation was performed during this extraction.

## Mouse handling and hit testing

The world-map frame is rectangular, but hover styling uses the polygon outline. Entering the frame starts a ticker every `0.08` seconds. Each tick gets the normalized world-map cursor position, runs an odd/even ray-crossing point-in-polygon test, and dispatches enter/leave only when the inside state changes. Leaving the frame clears inside state and cancels the ticker ([`BlobMap.lua:195-235`](source/Modules/Blob/BlobMap.lua#L195-L235); [`BlobUtil.lua:294-320`](source/Modules/Blob/BlobUtil.lua#L294-L320)).

`insidePolygonMouse` guesses the point units from the first outline vertex: if either coordinate exceeds 1, it multiplies the cursor coordinates by 100. That heuristic misclassifies a percentage-space outline whose first point happens to lie inside the first one percent of both axes. It also assumes the point list is nonempty ([`BlobUtil.lua:312-320`](source/Modules/Blob/BlobUtil.lua#L312-L320)).

The hit test is for **hover notification only**. Click handlers do not call it. Mouse-down/up forward left-button actions to the world-map scroll container for panning. Right-click selects the current map's parent; other clicks may navigate to the pin's map. This is explicit forwarding/navigation, not true geometry-aware input pass-through ([`BlobMap.lua:115-169`](source/Modules/Blob/BlobMap.lua#L115-L169)).

Only the entered rectangular pin is tested. The commented loop over all blob pins is inactive; there is no central overlap arbitration or "choose the visually topmost containing polygon" algorithm in this renderer ([`BlobMap.lua:207-218`](source/Modules/Blob/BlobMap.lua#L207-L218)). Minimap frames are acquired directly from their pool, not through MapCanvas's script-installation path, and the adapter passes an empty callback table ([`QuestiePolygon.lua:93-105`](source/Modules/Map/QuestiePolygon.lua#L93-L105)).

The quest hover callback increases outline thickness to 1.2 times the default and attempts to increase alpha by 1.5 times. However, its subsequent `line.redraw` resets vertex color from the original `line.color`, so the alpha increase is overwritten while the thickness change survives ([`QuestiePolygon.lua:359-375`](source/Modules/Map/QuestiePolygon.lua#L359-L375); [`BlobTexturePool.lua:95-98`](source/Modules/Blob/BlobTexturePool.lua#L95-L98)).

## Assets and runtime dependencies to retain

### Active renderer assets

| Asset in backup | Active use |
| --- | --- |
| `Icons/square.tga` | Fill texture selected by `Blob.TexturePool.TEXTURE.path`. File metadata reports RGBA RLE TGA, 512×512. |
| `Icons/playerMask.tga` | Player-centered minimap mask. File metadata reports RGBA RLE TGA, 128×128. Code refers to lowercase `playermask`, so preserve/normalize case deliberately for case-sensitive tooling. |
| `Icons/circlemask.blp` | Fallback minimap-shape mask. |
| `Interface/BUTTONS/WHITE8X8` | Client-provided outline texture; not an addon asset. |

Sources: [`Blob.lua:47,55`](source/Modules/Blob/Blob.lua#L47); [`BlobTexturePool.lua:108,125-134`](source/Modules/Blob/BlobTexturePool.lua#L108); image dimensions were checked with the read-only `file` utility.

`Icons/squarecurve.tga`, `squaregrad.tga`, `squaregradline.tga`, `squarenoborder.tga`, the raw outline artwork, and `Icons/Raw/32x32/BlobPOI.*` exist in the backup but are not selected by the active blob fill/outline code. The `TEXTURECURVE` and `TEXTURECURVESMALL` declarations are block-commented ([`BlobTexturePool.lua:136-156`](source/Modules/Blob/BlobTexturePool.lua#L136-L156)). Their presence is historical material, not an active runtime dependency.

### APIs and libraries

For a faithful extraction, account for:

- QuestieLoader and the `QuestieLib.AddonPath` asset root.
- `Questie:Debug` and global debug constants, or remove/adapt those diagnostics.
- `CreateCatmullRomSpline(2)` and its point/segment methods.
- Blizzard frame/texture pools and hide/clear reset helpers.
- `MapCanvasDataProviderMixin`, `MapCanvasPinMixin`, the current map canvas and its pin-pool interface.
- `CreateFromMixins`/`Mixin`, `LineMixin`, `DrawLine`, and vertex-index constants.
- Texture vertex offsets, mask textures, pixel-snap controls, UV/tint setters.
- `C_Timer.NewTicker`, cursor position and mouse APIs, `C_Map.GetMapInfo`.
- HBD coordinate conversion **and the local HBD-Pins polygon modifications**, not just stock HBD-Pins.
- `WorldMapFrame` and `Minimap` existing at file load.

These follow from the five blob files and the HBD paths cited above. [`BlizzLibs/SharedXML/Spline.lua`](source/BlizzLibs/SharedXML/Spline.lua), [`BlizzLibs/SharedXML/Pools.lua`](source/BlizzLibs/SharedXML/Pools.lua), [`BlizzLibs/FrameXML/MixinUtil.lua`](source/BlizzLibs/FrameXML/MixinUtil.lua), and `BlizzLibs/AddOns/Blizzard_MapCanvas/` are useful reference copies; they are not loaded by the TOC or `embeds.xml`. No blob XML template is required by the active code.

The embedded Bezier utility carries Nathan Shafer's 2013 MIT license notice. Preserve that notice when extracting substantial portions ([`BlobUtil.lua:322-344`](source/Modules/Blob/BlobUtil.lua#L322-L344)). The rest of the extracted files should retain applicable repository/file licensing; this note does not establish a new license for the whole renderer.

## Incomplete behavior and extraction risks

These are source findings, not reproduced runtime failures:

1. **Fill style is miswired.** `texData` is unused during drawing; fill color comes from `lineData` ([`Blob.lua:514`](source/Modules/Blob/Blob.lua#L514)).
2. **Outline-center exclusion tests are too broad.** They require both X and Y to differ from the center rather than testing that the full point differs. A legitimate outer point sharing the center's X or Y can suppress an outline segment ([`Blob.lua:469-478`](source/Modules/Blob/Blob.lua#L469-L478)).
3. **Pooling omits hover teardown.** Neither resetter clears/cancels `insideTimer`, `insideFrame`, or `insidePolygon`. `OnReleased` only prints, and the custom resetter does not explicitly call it. Correctness depends on mouse-leave behavior during hide/release; otherwise a ticker can retain a released/reused pin and access cleared `drawData` ([`BlobFramePool.lua:36-71,114-146`](source/Modules/Blob/BlobFramePool.lua#L36-L71); [`BlobMap.lua:190-235`](source/Modules/Blob/BlobMap.lua#L190-L235)).
4. **Repeated refresh can duplicate pins.** The provider only clears on `fromOnShow == true`; direct `RefreshAllData(false)` requires a blank map. Removing records does not remove already drawn pins until release/refresh ([`BlobMap.lua:29-58`](source/Modules/Blob/BlobMap.lua#L29-L58); [`Blob.lua:362-371`](source/Modules/Blob/Blob.lua#L362-L371)).
5. **Line texture names use the wrong counter.** `lineCount` increments, but the texture name concatenates `textureCount`, which can repeat across multiple line allocations ([`BlobTexturePool.lua:100-103`](source/Modules/Blob/BlobTexturePool.lua#L100-L103)).
6. **Raw geometry assumes convex, nondegenerate data.** A zero-width outline reaches a division by `fWidth` during minimap-scale calculation. Empty/short records are rejected, but collinear/duplicate records are not ([`Blob.lua:307,351,427-463`](source/Modules/Blob/Blob.lua#L307)).
7. **Bounds initialize maxima to zero.** This assumes ordinary nonnegative zone-percent inputs. Spline overshoot/out-of-zone data is not fully accounted for by that assumption ([`Blob.lua:384-388`](source/Modules/Blob/Blob.lua#L384-L388); [`BlobUtil.lua:105-128,182-197`](source/Modules/Blob/BlobUtil.lua#L105-L128)).
8. **World-map resize/zoom callbacks are not implemented.** The relevant provider callbacks are in an unused block; geometry is measured when drawing. Do not infer proactive recomputation from those commented methods ([`BlobMap.lua:71-104`](source/Modules/Blob/BlobMap.lua#L71-L104); [`Blob.lua:438-445`](source/Modules/Blob/Blob.lua#L438-L445)).
9. **Minimap support depends on invasive side effects and heuristics.** It replaces a frame method, assumes fixed base world widths, uses center-distance culling, and lacks polygon orientation changes for rotated minimaps (minimap section above).
10. **The raw API is not standalone.** Even world-map drawing calculates minimap metadata through HBD, and even minimap drawing starts with world-map canvas dimensions ([`Blob.lua:438-463`](source/Modules/Blob/Blob.lua#L438-L463)).
11. **Development command is stale.** `/bl` is registered, but its active final action imports `WaypointMap` and acquires a waypoint pin. Its blob examples are commented out. It is not a usable blob demo as-is ([`Blob.lua:865-999`](source/Modules/Blob/Blob.lua#L865-L999)).
12. **Historical triangle implementations are inactive.** `DrawTriangleOLD` and `DrawTriangle2OLD` are inside a block comment, not alternate runtime paths ([`Blob.lua:605-860`](source/Modules/Blob/Blob.lua#L605-L860)).

For a new implementation, the reusable boundary is the ordered outline plus style and callbacks. Preserve the original files as historical evidence, but do not transplant their load-time mask hook, global registration, pool teardown assumptions, or HBD modifications without reviewing them against the target client.

## History and alternative implementations

### Git provenance

The unpacked repository's inspected HEAD is `736861e7190b3ce343a5f540f1ad97b734db79e8` on `_classic_version`. Relevant history:

| Commit | Commit date | Evidence |
| --- | --- | --- |
| `0d4cb4a` | 2021-01-31 | Initial tracked snapshot; no path named for blob/polygon/cluster. |
| `b098dbb` | 2021-02-25 | "Toc and files"; introduces `clusteringChanges!.txt`. |
| `1505579` | 2021-02-25 | "Minimap changes for polygons"; modified HBD-Pins placement/scaling. |
| `7009a225bf3c7c4289d115dd1bdcf7528805fbcb` | 2021-02-25 | "Polygon code"; introduces the five Blob files, QuestiePolygon, and integration. |
| `ca7e3e943fd7fbceac7732918f3456aa18c6e672` | 2022-02-10 | Large compatibility checkpoint; commit message describes its 1.14 compatibility as a hacky working state. |
| `736861e7190b3ce343a5f540f1ad97b734db79e8` | 2022-10-06 | Current HEAD, "This is what was in the _classic_ dir". |

The six core Blob/QuestiePolygon files are unchanged between `ca7e3e9` and HEAD. Other integration files changed. Local `master` points to `90298bf` from March 22, 2021; `origin/master` points to `ca7e3e9`. These local references were inspected without fetching. Dates establish recorded repository history, not the first invention of the algorithms or a release date.

Scoped working-tree comparison against HEAD was clean for Blob, QuestiePolygon, QuestieQuest, HereBeDragons, and the development notes. This does not claim the entire backup is clean. No deleted Blob/QuestiePolygon files were found through all available refs, and neither `.throwaway` prototype has tracked history. Historical source can be read without checkout:

```bash
git -C /mnt/w/QuestieBackup/QuestieDev-master show \
  7009a22:Modules/Map/QuestiePolygon.lua
```

### Ignored prototypes

**Do not rely on cloning Git alone to recover the experiments.** These two files are ignored/untracked in the unpacked backup and are preserved here under [`source/.throwaway/`](source/.throwaway/).

| File / lines | Additional content |
| --- | --- |
| `.throwaway/Polygon.lua:50-143` | Monotone-chain convex hull and Jarvis alternatives. The monotone-chain helper concatenates its chains without removing duplicate endpoints. |
| `.throwaway/Polygon.lua:212-355` | Triangle fill using vertex offsets, collapsing texture corners to a center, rather than the integrated two-triangle quadrilateral fan. |
| `.throwaway/Polygon.lua:373-506` | Moving-center greedy clustering prototype. |
| `.throwaway/Polygon.lua:508-680` | Gaussian mean-shift experiment: `gaussian_kernel`, `Shift`, `CalcHotzones3`; intended convergence threshold 0.00001 and grouping tolerance 90. |
| `.throwaway/Polygon.lua:683-785` | Fixed-seed-radius clustering and a separate map-coordinate radius experiment. |
| `.throwaway/Polygon.lua:796-1391` | Debug slash harness and affine texture experiments, including `ApplyTransform` and `TextureAdd`. |
| `.throwaway/Polygonn.lua:181-329,478-636` | Another 636-line prototype using the `TextureAdd` triangle path and fixed-seed clustering. No reliable chronology follows from its filename. |
| `Modules/Libs/Affine.lua` | Tracked affine utility with an Unlicense notice; TOC entry is commented out at `QuestieDev-master.toc:84`. |

The mean-shift experiment is not the shipped-to-backup clustering path and is not a sound reusable algorithm as written. `Shift` drops map/iteration-state fields, setup aliases original points, final grouping uses original coordinates rather than converged positions, and `distance_to_group` never updates its minimum-distance accumulator (`.throwaway/Polygon.lua:508-680`). Preserve it as design history, not an implementation to enable.

Both prototypes register `QuestiePolygon` and expose global `Polygon`; loading them alongside the integrated module would mix implementations. Neither is loaded from `.throwaway` by the active manifest.

### Development notes

- `clusteringChanges!.txt:1-5` records `minDist` changing from 0.1 to 0.08, an unfinished instruction to change clustering from 180, reversing NPC insertion order, and changing object-icon range from 1 to 35. These are tuning notes, not proof every change was adopted.
- `Checklist.txt:12` marks zoom-related thickness work done. Line 19 asks for incremental averaging inside clustering instead of rescanning the member list.
- `stepback.txt:8` records discussion that polygons were no longer needed. It does not establish a technical failure or a shipping decision; the surrounding personal discussion is not reproduced here.
- `README.md` is generic Questie documentation, not a design guide for this feature.

### Archive comparison

`source/` is the best-supported final iteration among the inspected copies. Its five Blob files and `QuestiePolygon.lua` match `QuestieDev-master.7z` byte-for-byte; the unpacked project also contains later surrounding integration work. Earlier snapshot copies were removed from this package to avoid competing implementations. The original archives remain untouched in `W:\QuestieBackup\QuestieDev-master`.

| Original archive | Historical value |
| --- | --- |
| `QuestieDev-master.7z` | Same core blob implementation and prototype bytes as `source/`. |
| `QuestieDev-master-working-tooltipfix.7z` | Earlier renderer and pooling behavior, superseded by the retained implementation. |
| `QuestieDev-master-working-tooltipfix-2.7z` | Same five Blob files as the first tooltip archive, with adapter changes to message handling and spawn insertion order. |
| `QuestieDev-master.7z.txt` | Actual 7-Zip archive containing an earlier global-curve sampler and gift wrapping without the later iteration cap. |

The distinct earlier sampler is in `.7z.txt`, member `Modules/Blob/Blob.lua:147-238`: it derives a global parameter step from hull perimeter and `pPerDist = 0.7`, samples `CalculatePointOnGlobalCurve`, and retains samples more than 0.1 apart before the second hull and reduction at 0.03. The retained version instead samples each local segment at fixed 0.1 intervals. This older alternative remains documented, not included as another implementation.

Comparisons used original bytes and source diffs. They establish neither whole-project equivalence nor that any version runs on a current client.

## Extraction inventory and reuse boundary

For preservation, retain these groups together. The files are preserved in this package. It is a reference collection, not a runnable addon.

| Group | Files to preserve |
| --- | --- |
| Core geometry/rendering | All five `Modules/Blob/*.lua`; `Modules/NewMap/MapLib.lua`. |
| Quest orchestration | `Modules/Map/QuestiePolygon.lua`; relevant sections of `Modules/Quest/QuestieQuest.lua`, `Modules/FramePool/QuestieFrame.lua`, `Modules/FramePool/QuestieFramePool.lua`, and `Modules/Event/QuestieEventNEW.lua`. |
| Map dependency changes | `Libs/HereBeDragons/HereBeDragons-Pins-2.0.lua` alongside the matching HBD coordinate implementation. |
| Assets | `Icons/square.tga`, `Icons/playerMask.tga`, `Icons/circlemask.blp`; optional experimental texture/art sources listed above. |
| Load/event context | `QuestieDev-master.toc`, QuestieLoader, and the legacy MessageHandler implementation. These explain the integration contract, not necessarily modules to transplant. |
| Alternative algorithms | Both `.throwaway` polygon files and `Modules/Libs/Affine.lua`; the earlier archived `CalcSpine` variant is described above but not copied. |
| Provenance | Git commit IDs above, development notes, archive names/member paths, and retained source licenses. |
| Historical API references | Relevant spline, pool, MapCanvas, and DrawLine files under `BlizzLibs/`. Verify replacement client APIs separately. |

The useful separation for a future implementation is:

```text
Spawn collector → clusterer → outline builder → renderer
                                       ↓
                          geometry-aware hover selection
```

Keep quest state, cache invalidation, and hover/toggle lifetime in a separate adapter. Give points explicit coordinate units and map/instance identity rather than retaining the old guessing heuristics. The renderer's raw ordered-outline boundary is reusable conceptually; the original world/minimap globals and hooks are not a portable library interface.

Before reusing code, the highest-value geometry checks would cover duplicate/collinear points, fewer than three points, known hulls with interior points, zero-area/reversed outlines, cluster order dependence, and maps with unrelated world-coordinate spaces. Renderer validation would need the target client's vertex offsets, masks, zoom, rotation, overlap input, and release-during-hover behavior. These are proposed checks, not tests run by this investigation.

## Validation performed

Read the core renderer, geometry helpers, active clustering, cache/quest integration, relevant TOC entries, and modified HBD minimap branches. Checked the backup's copied Blizzard map/spline/line implementations and confirmed active texture assets exist. Inspected scoped Git history and ignored prototypes; compared selected archived files by bytes and source diffs using read-only streaming.

No legacy Lua was executed, no live client was touched, and no backup file was changed. The accompanying package preserves the primary source and experimental references without changing their content. Redundant and superseded snapshot copies were removed; the original backup archives were not changed. No claim here establishes in-game performance, visual output, taint safety, or modern WoW API availability.
