# Area E: shared geometry, render primitives and the frame budget

`WP` is `origin/waypoints` (`7c1e28bd8`) and `B` is `blob` (`715031ef6`). All line numbers were checked against those commits. File paths without a directory are short for:
- **WP:** `Modules/Map/Waypoints/*`
- **B:** `Polygon/*`

"Offline" numbers come from throwaway scripts run for this plan with plain Lua 5.1.5 on a desktop. Most load the real module code from the two commits. They show relative cost and are not in-game timings. The method is in the [appendix](#appendix-offline-checks).

## Summary

- **Share one geometry function.** WP's `Trim` and B's `_ReduceOutline` are the same Ramer-Douglas-Peucker algorithm, and verified to give identical output. Move it to a new `MapGeometry.Simplify` and delete B's copy, together with the MIT notice that came with it. Everything else stays with its owner.
- **Keep both renderers separate.** They already agree on the conventions that matter: no mouse input, masks applied at texture creation, and a frame level chosen by the caller. They share no code worth extracting.
- **One scheduling rule, in two tiers:**
  - *Background builds* turn data into geometry and markers. They share B's per-frame budget.
  - *Presentation* turns geometry into frames on screen. It runs synchronously in the frame that shows it and never yields.
  
  Waypoints have no background work worth budgeting.
- **Fix two gaps in B's budget.** A new job works through 255 steps before it first checks the shared slice, and a collected spawn costs about 33 geometry steps but is charged 1. In an offline simulation using B's own `Checkpoint`, 40 objective jobs after a reset spend 26–113 ms in a single frame. The fix:
  - check the slice before a job's first step;
  - charge each step roughly its cost;
  - move the fixed 30-icon marker yield onto the budget.
  
  Every simulated frame then stays at about 2–2.5 ms.
- **Drawing order is areas, then waypoint lines, then Questie's icons.** This is already true on the world map: areas sit at 2004 (Era) or 2007 (Forever), lines at 2015 and icons from 2016. Record it, and apply the same order on the minimap (Area D).

## 1. Problem

### 1.1 Geometry

Each branch built its own pure geometry module:

| Module | Contents |
|---|---|
| WP `WaypointGeometry.lua` (405 lines) | `BuildPolylines` (L81-116), `Smooth` (L277-307), `Trim` (L318-357), `Quads` (L184-217), `SegmentDistanceSq` (L364-373), `Nearest` (L388-405) and `Bounds` (L39-46) |
| B `PolygonGeometry.lua` (474 lines) | Clustering and hulls in `Build` (L376-474), the frame budget `NewWork`/`Checkpoint` (L42-100), and a closed-ring reduction `_ReduceOutline` (L282-318) with its own `_SegmentDistanceSquared` (L254-260) and an MIT notice (L262-278) |
| B `PolygonNudging.lua` (209 lines) | Map-space grouping of coincident markers (`Calculate`, L28-86) and icon anchor ownership (`New` and the `Layout` methods, L90-209) |

The duplicates:
- **`_IsFinite`: four copies, not three.** WP `WaypointGeometry.lua:33`, B `PolygonGeometry.lua:47`, B `PolygonRenderer.lua:44` and B `PolygonNudging.lua:18`. The nudging copy also rejects secret values.
- **Point-to-segment distance: three copies.** WP `SegmentDistanceSq` at L364, inline in WP `Trim` at L333-345, and B `_SegmentDistanceSquared` at L254.
- **Two implementations of the same simplification algorithm:** WP `Trim` and B `_ReduceOutline`.
- **Bounds in two shapes.** Arrays `{minX, minY, maxX, maxY}` in WP and in most of B; named fields in B's `PolygonCluster.worldBounds` (`PolygonGeometry.lua:25-29, 447`).

### 1.2 Rendering

- **WP `WaypointRenderer`** draws mitered, anti-aliased line quads: one pooled texture per segment, with `Icons/waypoint-line-aa.png`.
- **B `PolygonRenderer`** draws a fan of fill quads plus `DrawLine` borders, and runs geometric hover inside the renderer.
- **B `PolygonRenderCache`** retains views per objective, marker and map.

Both draw on the same canvases: the world map's, and the minimap's (Area D).

### 1.3 Scheduling: where heavy work starts

| Trigger | Branch | Work | Runs in | Budget today | Evidence |
|---|---|---|---|---|---|
| Objective update (login, accept, progress, `SmoothReset`) | both | One ThreadLib job per objective runs `PopulateObjective` | Coroutine, resumed at most once per frame (`Modules/Libs/ThreadLib.lua:105-140`) | Master: fixed counts (`TICKS_PER_YIELD`, B `QuestieQuest.lua:78-84`) | B `QuestieQuest.lua:860-883, 959-1049` |
| Blob mode inside that job | B | Spawn collection, `PolygonGeometry.Build`, marker icon allocation | Same coroutine | Collection and Build use `Checkpoint` (a 2 ms slice shared by all polygon jobs); markers use a fixed `coroutine.yield()` every 30 icons | `QuestiePolygon.lua:925-961`, `983`, `1025-1052` |
| Waypoint registration | WP | `QuestieWaypoints.Add` → `BuildPolylines` | The caller's context. That is often a coroutine, but `/questie` search calls it from a slash handler (WP `QuestieSlash.lua:212`) and the Townsfolk menu from a `C_Timer` ticker (WP `QuestieMenu.lua:186-195`) | None. Synchronous; offline 0.13 ms for 50 points and 0.84 ms for 400, HBD excluded | `QuestieWaypoints.lua:58-79` |
| World map open, map switch, canvas resize | WP | `_Refresh` runs `Smooth`, `Trim` and `Quads` and sets the textures of every route not yet drawn for this map and size | `OnUpdate` | None | `WaypointMap.lua:80-110, 153-176, 182` |
| World map zoom | WP | When a zoom settles or drifts 25%, every visible route is restyled; a new thickness redraws its geometry | `OnUpdate` | None | `WaypointMap.lua:151, 166-173`; `WaypointRenderer.lua:218-241` |
| World map open, map switch, resize | B | `ScheduleRefresh` (`C_Timer.After(0)`) → `Refresh` → `Present`. New views are configured synchronously (cold); retained ones are only restyled | Timer callback | None | `QuestiePolygon.lua:198-286, 379-441` |
| Minimap: walk, turn, zoom | WP | Reprojects on a zoom, size, instance or facing change, or after drifting half a view radius, then runs `Smooth`, `Trim` and `Quads` | `OnUpdate` | None. Measured 1.70 ms per tick while turning, for one 31-segment patrol (Forever) | `WaypointMinimap.lua:333-409, 452`; `docs/waypoints.md:233-240` |
| Minimap: walk, turn, zoom | B | Reconfigures every visible area when the projection changes | `OnUpdate` | None. Not measured (`Polygon/README.md:205`) | `PolygonMinimap.lua:268-326, 376` |
| Settings and profile switch | WP | The smoothing slider runs `RedrawAll` synchronously on each step; width, colours and toggles mark the maps dirty; the profile switch runs `RedrawAll` and `Refresh` | Settings handlers | None | `QuestieOptionsMap.lua:22-35, 171-174`; `Questie.lua:69-78` |
| Settings and profile switch | B | A preset change runs `SmoothReset` (above); `showPolygonsOnAccept` runs `RefreshVisibility` | Settings handlers | Via the jobs above | B `QuestieOptionsIcons.lua:172, 1386, 1471` |
| Hover | both | Hit tests run only when the cursor moves | `OnUpdate` | None needed | `WaypointMap.lua:133-143`; `PolygonRenderer.lua:193-196` |
| Nearby check and nudging | B | A 1 s ticker, and a stack layout on the next frame | Timers | None needed | `QuestiePolygon.lua:185-194, 1020` |

**ThreadLib and the AGENTS.md rule against `coroutine.running()` guards:**
- **No guards.** Neither branch's new code guards a yield with `coroutine.running()`. A grep of WP `Modules/Map/Waypoints` and B `Polygon` finds none.
- **Yielding functions are marked `---@async`:** `Checkpoint` (L81), `Build` (L371) and `UpdateObjective` (`QuestiePolygon.lua:884`). They are reached only from ThreadLib jobs.
- **Asserts are fine.** Master's `assert(coroutine.running(), ...)` at entry points such as `QuestieQuest.lua:962` enforces the contract rather than guarding a yield, so it is allowed.
- **No frame or timer callback yields.** None of `WaypointMap._Update`, either minimap `Layer:Update`, `QuestiePolygon.Refresh` or the timers calls an `---@async` function.

### 1.4 Where they collide and what breaks

Nothing in Area E breaks the rebase.
- **Disjoint files.** WP's waypoint geometry and renderer files and B's Polygon geometry, renderer, cache and nudging files never change in the other branch.
- **Overlaps belong to other areas.** Of the 15 blob commits that touch those four Polygon files, the only overlaps with WP-changed files are:
  - `QuestieFrame*`, `QuestieFramePool`, `QuestieQuest`, `QuestieMap` and `MapIconTooltip`;
  - `QuestieOptionsDefaults`, the TOCs and HBD-Pins.
  
  Those belong to Areas A–D and the orchestrator.

The problems are cost and drift:
1. **Frame spikes after resets in blob mode.** The budget's two gaps are in [§2.4](#24-scheduling). The combined code makes this worse, because the blob-mode objective job now also registers waypoint routes.
2. **Two copies of the same algorithm**, plus a third-party-derived copy that only B needs (the MIT block).
3. **An open decision in WP's docs.** `docs/waypoints.md:281` says "Frame levels: above or below polygon areas is decided then."
4. **Presentation costs nobody has measured in game:**
   - WP redraws on dense maps;
   - B's first draw of a map's areas (`Polygon/README.md:124`);
   - both minimap layers while turning.

## 2. Comparison

### 2.1 Function inventory and pairing

Every function in `WaypointGeometry`, `PolygonGeometry` and `PolygonNudging` is listed below, plus the related helpers in the renderers, map drivers and adapters. Abbreviations:
- `WG` WaypointGeometry, `WR` WaypointRenderer, `WMap` WaypointMap, `WMini` WaypointMinimap, `QW` QuestieWaypoints;
- `PG` PolygonGeometry, `PR` PolygonRenderer, `PN` PolygonNudging, `PM` PolygonMinimap, `QP` QuestiePolygon.

| # | Concept | WP | B | Equivalent? | Verdict |
|---|---|---|---|---|---|
| 1 | Finite-number check | `WG:33` | `PG:47`, `PR:44`, `PN:18` | Three identical. `PN:18` also returns false for secret values. None of its inputs (frame fields, configured scales, `GetEffectiveScale`) can be secret. | **Keep local.** A one-line predicate is not worth an import; Questie copies `_IsSecret` the same way (`Tooltip.lua:670`, `TooltipHandler.lua:15`, `Forever.lua:15`, both minimap layers). |
| 2 | Point-to-segment squared distance | `WG:364` (public, scalar args); inline in `Trim` `WG:333-345` | `PG:254` (table args) | Same maths. B squares with `^2`, WP with `*`. | **B's copy goes** with row 3. WP's public one stays beside `Nearest`. The inline copy stays inline: WP measured it taking `Trim` down from 56 ms (`docs/waypoints.md:178`). |
| 3 | Ramer-Douglas-Peucker simplification | `Trim` `WG:318-357`: open polyline, keeps both ends, flat stack | `_ReduceOutline` `PG:282-318`: closed ring split at the vertex farthest from the first, `Checkpoint` on every step, falls back to the input if fewer than 3 points remain | **Identical output** when B's ring is closed back to its first vertex and passed to `Trim`: 100,000 random rings (convex and arbitrary, 3–60 points, 5 tolerances) with 0 mismatches. The ring's zero-length closing segment makes `Trim` split at the vertex farthest from the start, as B does. `Trim` is 3–4× faster: 0.30 against 0.85 ms at 200 points, 1.27 against 3.91 ms at 1,000. | **Share** as `MapGeometry.Simplify` ([§3.1](#31-shared-geometry-mapgeometry), F3). Delete `_ReduceOutline`, `_SegmentDistanceSquared` and the MIT notice. |
| 4 | Bounds | `Bounds` `WG:39` returns an array; also `WaypointPolyline.worldBounds` and the hover targets' `bounds` | `_Bounds` `PR:260-274` (array, plus centre, frame size and validation in one pass); `PM:66-76` (array, inline while converting); `PolygonCluster.worldBounds` `PG:420-447` (named fields) | The arrays match in order. B's named `worldBounds` is a **different concept**: the extent of the cluster's member spawns, used once a second by `_IsPlayerNearby` (`QP:618-630`), not the extent of a drawn shape. | **Keep.** Convention: bounds used for hit tests and culling are arrays `{minX, minY, maxX, maxY}`. The two types never meet, and LuaCATS keeps them apart (`number[]` against `PolygonWorldBounds`). |
| 5 | Corner smoothing | `_Curve`/`Smooth` `WG:234-307`: quadratic Bézier inside each corner, tolerance in half line widths, at draw time | `_SampleSpline` `PG:232-252` + `_SplineEnvelope` `PG:192-228`: Catmull-Rom through the hull, outward bulge re-hulled, in percent space, at build time | **No.** WP must stay close to where the NPC walks; B must enclose the spawns. WP rejected Catmull-Rom for paths (`docs/waypoints.md:161`). | **Keep separate.** |
| 6 | Dropping redundant points | `_DropStraightPoints` `WG:57-70` (within 0.1°, against the last point kept); merge within 0.5 yd `WG:106` | `_UniqueCoordinates` `PG:144-156` (exact duplicates after sorting); the hull and envelope drop collinear points by the sign of the cross product | **No.** Different inputs and rules. | **Keep.** |
| 7 | Hulls | — | `_GiftWrap` `PG:160-188`, `_SplineEnvelope` `PG:192-228` | B only | **Keep.** |
| 8 | Sort that can yield | — | `_Sort` `PG:104-128` with comparators `PG:130-142` | B only | **Keep.** |
| 9 | Area and centroid | — | `_AreaAndCentroid` `PG:322-334` | B only | **Keep.** |
| 10 | Clustering and object lists | — | `Build` `PG:376-474`, `_ListObjects` `PG:344-367` | B only | **Keep.** |
| 11 | Line outlines (mitered quads) | `_Directions`/`_Join`/`Quads` `WG:131-217` | Borders are `DrawLine` rectangles with no geometry of their own (`PR:72, 381`) | WP only | **Keep.** B's borders could use `Quads` one day, but that changes how they look (R10). |
| 12 | Hover hit test | `Nearest` `WG:388-405`: distance ≤ r, nearest single target | `_ContainsPoint` `PR:126-142`: even-odd, inclusive edges, every containing outline | **No.** Different predicate and different selection. They share only the rejection by an array bounding box. | **Keep.** Contracts for Area A in [§3.5](#35-hover-hit-testing-primitives). |
| 13 | Frame budget | — (WP draws synchronously) | `NewWork`/`Checkpoint` `PG:42-100` | B only | **Keep the owner**; extend it ([§3.3](#33-frame-budget-and-scheduling-policy)). |
| 14 | Map-space grouping | — (WP removes duplicate routes by key, `QW:69-73`) | `Calculate` `PN:28-86`; `MAP_TOLERANCE` 0.01 percent `PN:12` | B only | **Keep.** |
| 15 | Icon anchors | — | `New` and the `Layout` methods `PN:90-209` | B only, and presentation rather than geometry | **Keep.** |
| 16 | Map percent → world yards | `_ToWorld` `QW:47-49` (injected into `BuildPolylines`) | `QP:944`, `PM:68` | The same one-line `HBD:GetWorldCoordinatesFromZone(x/100, y/100, map)` | **Keep at call sites.** |
| 17 | Percent on one map → percent on another | — (removed: `docs/waypoints.md:246-253`) | `QP:236-264` (`TranslateZoneCoordinates`) | B only. The products diverge (R9). | **Keep.** |
| 18 | World → minimap projection | `_ProjectPoint`/`_Transform` `WMini:57-67` | `PM:84-113` | Identical | **Area D.** |
| 19 | Reading the world-map cursor | `_ReadCursor` `WMap:117-123` (canvas units) | `QP:995-997` + `PR:149-156` (percent) | Same read, different units | **Area A.** |
| 20 | Secret-value check | `_IsSecret` `WMini:192-198` | `PM:260-266` | Identical | **Area D.** |

### 2.2 Units, epsilons and conventions

- **Map percent (0–100)** is the stored unit for map-anchored geometry in both branches: WP `points`, and B spawn points, cluster `x`/`y`, outlines and shapes.
- **0–1 appears only at API boundaries:** HBD calls (`QW:48`, `QP:944, 248`, `PM:68`) and `GetNormalizedCursorPosition` (`WMap:119`, `QP:996`). Both branches convert at the call.
- **World yards** are used where a distance must mean the same in every direction in the world: WP merges points within 0.5 yd and stores yards for the minimap; B clusters at 180 yd and spaces objects 10 yd apart.
- **Canvas units** are used where a tolerance is measured on screen. WP divides line width, smoothing, trimming and hover reach by the canvas scale.
- **B builds outlines in percent space, which is anisotropic.** That is correct:
  - hulls, Catmull-Rom combinations and centroids are unchanged by per-axis scaling;
  - the only distance used is the reduction tolerance of 0.03 percent, which is well under a canvas unit on either axis.
  
  Area uses squared percent as a size cut-off (0.9).
- **Y points down** everywhere geometry lives: percent, canvas units and projected minimap units. Only the renderers flip it, at `SetPoint`/`SetVertexOffset` (`WR:149-154`, `PR:315-318`).
- **Epsilons are tied to their units and stay separate:**
  - WP: `MERGE_YARDS` 0.5, `STRAIGHT_COS` cos 0.1°, `MIN_JOIN_COS` 1e-3, `bend < 1e-9`, and merges within a thousandth of the half width (`WG:31, 49, 126, 242, 289`);
  - B: exact `cross == 0` ties (`PG:174`), the `1e-8` cross tolerance at edges (`PR:131`), and `MAP_TOLERANCE` 0.01 with `1e-12` of slack (`PN:12, 50`).
  
  A shared epsilon constant would be wrong in at least one of these units.

**Verdict:** no convention to unify. The plan records the rule: store percent; convert at API boundaries; measure on screen in canvas units divided by scale; measure in the world in yards.

### 2.3 Render primitives

| Aspect | WP `WaypointRenderer` | B `PolygonRenderer` (+ `PolygonRenderCache`) | Same? |
|---|---|---|---|
| What is drawn | One view frame per path, one texture per segment quad (`Draw` L249-270) | One view frame per outline: fill textures, each covering two fan triangles, plus border textures (`Create` L398-411, `_ConfigureFrame` L353-389) | Same idea: a pooled frame holding pooled textures |
| Texture pool | By kind. The asset, wrap and filter are set once at creation, and so are the masks (`_Acquire` L96-115, `_ReleaseBeyond` L122-130) | Fills and borders. Masks at creation; asset, wrap and filter set again on every acquire; ownership recorded before any client call, so a failed call cannot leak a texture (`_AcquireTexture` L276-295, `_ReleaseTextures` L297-307) | Same idea, about 25 lines each, with different failure handling |
| Mapping a quad | Bounding-box anchors plus 4 `SetVertexOffset`; any convex quad, split on either diagonal (`_DrawQuad` L141-155; `docs/waypoints.md:118-121`) | `SetAllPoints(frame)` plus 4 `SetVertexOffset` and `SetTexCoord`. The fan relies on the client splitting from upper right to lower left (`_DrawSquare` L311-321) | Same client technique, different geometric contract |
| Lines | Mitered quads with an anti-aliased outline texture and `LINEAR` filtering (L46-57) | `DrawLine` rectangles with `WHITE8X8` and `NEAREST`, no joins (L72-73, L381) | No |
| Width while zooming | Constant on screen: redrawn when a zoom settles or drifts 25% (`WMap:149-173`) | Canvas units, so borders thicken as the map zooms in | No (R10) |
| Fade | `view:SetAlpha` (L236) | Built into the vertex alpha of fills and borders (`QP:271-272`) | No |
| Highlight | Another colour, and the highlighted copy of the route draws (`QW:160-173`) | Border RGB ×1.25 and thickness 1.5 → 1.8 (L63-80) | No |
| Draw layers | Lines `ARTWORK`, debug `BACKGROUND` (L71-75) | Fills `OVERLAY` 0, borders `OVERLAY` 1 (L282) | Matter only within one view |
| World-map frame level | 2015 (`WMap:17-18`) | `PIN_FRAME_LEVEL_QUEST_BLOB` (`QP:283`) | Decides the order between features ([§3.6](#36-drawing-order)) |
| Leaving a map | Releases the views of routes not on the new map (`WMap:103-108`); keeps them when the map closes (`WMap:183-187`) | Retains hidden views per owner, marker and map (`PolygonRenderCache.lua:51-121`) | Different cost models |
| Hover | Outside the renderer | Inside the renderer (`hoverInput`, driver L193-240) | Area A |
| Mouse, masks, pixel snapping | No mouse; `New(canvas, masks)`; snapping off (L81, L107-108) | The same (L32-33, L54, L289-291) | **Yes. These are the shared conventions.** |

**Keep from each:**
- **WP:** the line primitive (convex mitered quads, the anti-aliased texture, restyling only what changed) and constant on-screen width.
- **B:** retained views, error-safe pool ownership, and the combined highlight set (marker requests plus geometric hover).

**Do not extract a shared texture pool, quad helper or view cache:**
- the duplicated code is about 40 lines;
- the two failure-handling styles differ;
- B's 1,123 lines of renderer tests exercise pool internals through partial-failure cases;
- the quad helpers have different geometric contracts.

### 2.4 Scheduling

**B's budget** (`PG:42-100`) works like this:
- **Shared slice.** Every polygon job's ThreadLib ticker resumes once per frame, and all jobs share one slice of 2 ms (`SLICE_SECONDS`) or 32,768 operations (`MAX_OPERATIONS_PER_SLICE`).
- **Frame identity.** `GetTime()` identifies the frame; `GetTimePreciseSec()` measures time within it.
- **Check cadence.** A job checks cancellation and the slice every 256 calls (`CHECK_INTERVAL`).
- **Waiting jobs.** A job resumed into a frame that is already spent yields again before working.

B moved spawn collection from a fixed yield every 200 spawns onto this budget in `bd340ebb9 perf(polygon): share one frame budget across polygon jobs`. The marker loop kept its fixed count of 30, counting icons rather than clusters since `4f76fd411` (`QP:1047-1052`).

**Gaps, measured offline:**
- **The operation unit is about 0.33 µs.** That is roughly 3,000 checkpoints per ms during `Build` (100–3,000 spawns). So the 32,768-operation ceiling is about 11 ms of offline work. It is a backstop for tests without a clock, not a second time limit; in game the 2 ms clock decides.
- **A collected spawn costs about 11 µs** (`QP:940-956`: the `table.concat` key with float-to-string conversions, plus the point table; HBD excluded). That is about 33 operations, but it is charged 1. Collection therefore reads the clock only every 256 spawns, about 2.8 ms of work, which is more than the whole slice.
- **A new job does 255 steps before its first check.** ThreadLib starts every new job on the same next frame. After a reset, all objective jobs therefore spend their first steps in one frame, whatever the slice says. Simulated with B's own `Checkpoint` and 11 µs spawns:

| Jobs × spawns | Total work | Worst frame today | Worst frame with the fix (§3.3) |
|---|---|---|---|
| 40 × 60 | 26 ms | **26.4 ms** (all in 1 frame) | 2.5 ms over 13 frames |
| 40 × 300 | 132 ms | **113.1 ms** | 2.5 ms over 65 frames |
| 10 × 1,000 | 110 ms | **31.0 ms** | 2.1 ms over 55 frames |

- **The marker loop yields every 30 icons** whatever the shared slice says (`QP:1047-1052`). Twenty jobs allocating together add 600 icons to a frame.
  - **Measured on Era:** HereBeDragons alone costs 26 µs per world-map icon (`AddWorldMapIconMap` 14 µs + `HandlePin` 12 µs; master `Modules/Profiler/README.md:171-172`).
  - **Not measured:** Questie's own per-icon cost.

**WP:** everything heavy runs in the frame that shows it.
- **Documented cost:**
  - 80–85 ms of offline Lua 5.1 for *every* Classic patrol at once, and 21 ms for sharp quads alone (`docs/waypoints.md:178`);
  - 4.9 µs per drawn segment of texture calls, measured in game (`docs/waypoints.md:240`).
  
  The 80–85 ms figure is an upper bound that never happens in game, because only routes whose icons are on the shown map draw.
- **Not measured: the cost of one map.** Offline, a synthetic route costs 0.33 ms at 36 points and 4.9 ms at 400 points (about 10–12 µs per input segment; the docs' figures imply about 7 µs). A route like Courier Hammerfall's 403 stored points therefore costs about 3–8 ms on every zoom settle, once texture calls are included. The range depends on how many straight points `BuildPolylines` drops, and it is an estimate.

**Keep:**
- **From B:** the shared slice, frame identity, the recheck in a spent frame, cancellation, and `---@async`.
- **From WP:** synchronous presentation. Lines must match the zoom in the frame they show, and WP already tolerates 25% drift while a zoom eases (`WMap:149-151`).

### 2.5 Hover hit testing

- **WP** tests the distance to the nearest segment against a radius (`WG:388-405`). It needs isotropic units, which is why `WMap:139` divides by the canvas scale.
- **B** tests whether a point lies in an outline (`PR:126-142`). Containment is unchanged by per-axis scaling, so percent units are fine.
- **The selection differs:** WP returns one nearest target (later equal targets win, because the comparison is `<=`); B returns every containing outline.
- **The only common part** is rejecting by an array bounding box first, and both already use the same array order.

**Verdict: nothing to share.**

## 3. Target design

### 3.1 Shared geometry: `MapGeometry`

New module `Modules/Map/MapGeometry.lua`.

**What belongs in it:**
1. Geometry that **two overlays use today**. "Might" does not count.
2. **Pure functions only:** no WoW or HBD API, no module state, no yields. Units are the caller's.
3. **Not one-line predicates.** Those stay file-local, like `_IsFinite` and `_IsSecret`.
4. **Not overlay-specific geometry or projections.** Patrol polylines, smoothing and mitered quads stay in `WaypointGeometry`; clustering, hulls and splines in `PolygonGeometry`; minimap arithmetic in Area D's layer.

Today exactly one function qualifies:

```lua
---Planar geometry shared by Questie's map overlays: NPC waypoint paths and objective areas.
---Pure functions over points with named x/y fields, in whatever units the caller uses. Nothing
---here reads the client, keeps state or yields. A function belongs here once two overlays use it;
---geometry one overlay needs stays in WaypointGeometry or PolygonGeometry.
---@class MapGeometry
local MapGeometry = QuestieLoader:CreateModule("MapGeometry")

---A point in the caller's units: map percent, canvas units, minimap units or world yards.
---@class MapPoint
---@field x number
---@field y number

---Drops the points of a polyline lying within tolerance of the segment between the points kept
---around them (Ramer-Douglas-Peucker). Distances are to that segment, not its infinite line, so a
---point where the line turns back along itself stays. Ends are kept, so a polyline returning to its
---first point stays closed; there the closing segment has no length, so the first point kept is the
---one farthest from the start. Distances are Euclidean in the points' units: where the tolerance
---must mean the same in every direction, pass units with one scale on both axes.
---@generic P : MapPoint
---@param polyline P[]
---@param tolerance number In the points' units.
---@return P[] points The polyline's own point tables that are kept, in order. Fewer than three points
---return the polyline itself.
function MapGeometry.Simplify(polyline, tolerance)
```

**The body is WP's `Trim` (`WG:318-357`) moved verbatim**, with its inline distance test.

**WP uses it** as `MapGeometry.Simplify(smoothed, WaypointRenderer.TRIMMING * halfWidth)` at `WR:171`. WP's docs keep calling the step *trimming*.

**B uses it** through a small local wrapper that replaces `PG:254-318`:

```lua
-- Outlines are rings without a repeated closing vertex. Closing the ring for Simplify keeps its start
-- and splits it first at the vertex farthest from the start. Percent space stretches x and y
-- differently, but the 0.03 default is well under a canvas unit on either axis.
---@param points table[] Convex outline in zone percent, not closed.
---@param tolerance number Percent.
---@return table[] reduced At least three of the outline's own points; the outline itself when fewer would remain.
local function _ReduceOutline(points, tolerance)
    local ring = {}
    for i, point in ipairs(points) do ring[i] = point end
    ring[#ring + 1] = points[1]
    local reduced = MapGeometry.Simplify(ring, tolerance)
    reduced[#reduced] = nil
    -- An excessively large tolerance must not turn a valid area into a two-vertex line.
    return #reduced >= 3 and reduced or points
end
```

At `PG:457`: `local outline = _ReduceOutline(envelope, tolerance)`, followed by `if not _Checkpoint(work, #envelope) then return end`.

**Reduction no longer checkpoints internally.** Its input is bounded:
- The envelope has at most 10 points per hull vertex.
- The largest hull seen offline was 41 vertices, for 1,000 spawns in one 120-yd cluster. That gives an envelope of 410 points or fewer, which simplifies in about 0.5 ms offline against about 1.6 ms for today's checkpointed version.

### 3.2 Render primitives: no shared module

`WaypointRenderer` and `PolygonRenderer` stay separate modules. Their **shared contract**, recorded in both docs and relied on by Area D, is:
1. `New(canvas, …, masks)` applies the masks once, to each texture as it is created. A renderer never reads layer state.
2. Views never take mouse input. Hover is computed from the cursor (Area A).
3. The caller supplies frame levels: `WaypointStyle.frameLevel`, and the `frameLevel` arguments of `Create`, `Configure` and `Style`.
4. Pixel snapping is off (`SetSnapToPixelGrid(false)`, `SetTexelSnappingBias(0)`).
5. Geometry is y-down in parent-local units; the renderer flips y at `SetPoint`/`SetVertexOffset`.

### 3.3 Frame budget and scheduling policy

**Two tiers:**

| Tier | What | Rule |
|---|---|---|
| **Background builds** | Data → geometry and markers, independent of zoom: polygon spawn collection, `PolygonGeometry.Build`, polygon marker allocation | Run in ThreadLib jobs; mark the function `---@async`; charge each step to the shared slice with `PolygonGeometry.Checkpoint(work, cost)`; check cancellation or generation after every yield |
| **Presentation** | Geometry → frames on screen, depending on zoom, canvas or projection: `WaypointMap._Refresh` and zoom restyles, both minimap `Layer:Update`, `QuestiePolygon.Refresh`/`Present`, `WaypointRenderer.RedrawAll`, hover | Runs synchronously in the frame or timer callback that needs it; never yields; never calls an `---@async` function; does only what changed (dirty flags, coalesced `C_Timer.After(0)`, retained views); its cost scales with what is visible, not with the quest log |

**Outside both tiers:**
- Master's ordinary icon drawing and route registration (`_DrawObjectiveIcons`, `_DrawObjectiveWaypoints`) keep their fixed `TICKS_PER_YIELD` yields. This merge does not change them.
- `QuestieWaypoints.Add` stays synchronous, with no budget, and must never yield. Callers outside coroutines reach it (§1.3), and it is cheap: 0.84 ms offline for a 400-point patrol.

**Owner:** `PolygonGeometry`, unchanged in place.
- It keeps `NewWork` and `Checkpoint` beside their main consumer.
- `PolygonGeometry.lua:100` aliases `Checkpoint` before the profiler's pre-hook sweeps the module, so `Build`'s hot loop stays unwrapped while profiling.
- Moving the budget to `Modules/Libs/FrameBudget.lua` is the right step **once a second, non-polygon consumer exists**. That move must also add `Checkpoint` to both profiler exclusion lists, which must agree (master `Modules/Profiler/README.md:64`). Otherwise every step costs about 3.7 µs while profiling (`README.md:194`).

**The change (F1, F2):** `Checkpoint` takes a cost and checks at a job's first step.

```lua
---@class PolygonWork
---@field pending number Cost charged since this job last checked the shared slice.
---@field started boolean? The job has checked the slice at least once.
---@field isCancelled (fun(): boolean)?
---@field clock (fun(): number)? Precise seconds; nil leaves only the operation ceiling.

---Charges cost to this frame's shared polygon budget; 1 is one geometry step, about a third of a
---microsecond of Lua. A job checks cancellation and the slice before its first step, then whenever
---it has charged CHECK_INTERVAL since its last check, and yields while this frame's 2 ms or
---operation ceiling is spent. Charge a costly step, such as drawing an icon, roughly its cost in
---geometry steps, so the clock is read about as often whatever the job does.
---Callers must be coroutines resumed at most once per frame, as ThreadLib does.
---@async
---@param work PolygonWork
---@param cost number? Default 1.
---@return boolean continue False when the job was cancelled.
function PolygonGeometry.Checkpoint(work, cost)
    local pending = work.pending + (cost or 1)
    if work.started and pending < CHECK_INTERVAL then
        work.pending = pending
        return true
    end
    work.started, work.pending = true, 0
    if work.isCancelled and work.isCancelled() then return false end
    _SyncSlice(work)
    slice.operations = slice.operations + pending
    -- A job can resume in a frame another job has already spent. Recheck before working,
    -- so each waiting job does not add another CHECK_INTERVAL past the shared budget.
    while _IsSliceSpent(work) do
        coroutine.yield()
        if work.isCancelled and work.isCancelled() then return false end
        _SyncSlice(work)
    end
    return true
end
```

**Unit steps keep today's behaviour:** a check every 256 calls, adding 256 operations each time. The only difference is the extra check at the first step. The existing budget tests in `PolygonGeometry.test.lua` (L229-337) still hold; [§5](#5-tests) has the reasoning.

**Costs at the call sites in `QuestiePolygon`** (F2):

```lua
-- Costs in geometry steps (about 0.33 µs each, offline), so every polygon job reads the clock about
-- every 85 µs of work. A collected spawn's key and point cost about 11 µs of Lua offline; an icon
-- costs at least 26 µs in HereBeDragons alone (Era), plus Questie's own work.
local SPAWN_COST = 32
local ICON_COST = 256
```

- **Collection** (`QP:961`): `if not PolygonGeometry.Checkpoint(work, SPAWN_COST) then return nil, {} end`.
- **Marker allocation** (`QP:1025-1052`):
  - delete the `drawn` counter and the fixed `coroutine.yield()`;
  - after each successful `DrawWorldIcon` (the marker's map icon and every minimap icon), call `if not PolygonGeometry.Checkpoint(work, ICON_COST) then return nil, {} end`. This reuses the collection's `work`, whose `isCancelled` is the same check today's yield makes.
  - In game, allocation stops when the frame's 2 ms is spent. Without a clock (tests only), the 32,768 ceiling allows 128 icons per frame.

### 3.4 Waypoints and the budget

The question was whether waypoint geometry can use the budget without yielding from `OnUpdate`. It should not join the background slice:
- **The build cannot yield.** `BuildPolylines` is reached outside coroutines (`/questie` search, the Townsfolk ticker). It does not need to either: it is linear in patrol points and under 1 ms offline for the longest patrol. If the Townsfolk menu ever registers enough NPCs to stutter, batch that ticker at the caller.
- **The draw is presentation.** `Smooth`, `Simplify` and `Quads` depend on zoom, because their tolerances are fractions of the line width on screen. They must finish in the frame that shows them.
  - **Rejected: a ThreadLib job started from `OnUpdate`.** Swapping views when the job finishes would put visible lines behind every background polygon job. After a reset, that queue can run for 65 frames (§2.4).
- **If measurements say a dense map is too slow** (V3 in §7), fix it in this order, all inside `WaypointMap`, with no shared module:
  1. **Keep views across map switches.** Keep each route's view hidden while its map is not shown, valid for its map, canvas size and settled scale, instead of releasing it at `WMap:103-108`.
  2. **Only if that is not enough, spread `_Refresh` across frames.** Use a local cap per frame, measured with `GetTimePreciseSec` deltas, and draw at least one route per frame. That is a loop over pending routes that resumes next frame: no coroutine, no yield, and no starvation by background jobs.
  
  Neither is built now.

### 3.5 Hover hit-testing primitives

These stay with their owners. They are pure, and Area A can call them:

| Primitive | Contract |
|---|---|
| `WaypointGeometry.Nearest(targets, x, y, radius) → target?` (`WG:388`) | Targets carry `points` (named x/y) and `bounds` (array). Returns the target nearest the cursor within `radius`; later equal targets win. Units must be isotropic: WP uses canvas units divided by the canvas scale, or minimap units. Each target's padded bounding box rejects most targets first. |
| `WaypointGeometry.SegmentDistanceSq(px, py, sx, sy, ex, ey) → number` (`WG:364`) | A zero-length segment is a point. |
| Polygon containment `_ContainsPoint(points, x, y) → boolean` (`PR:126`, file-local) | Even-odd rule. Edges and vertices count as inside, using an absolute `\|cross\| ≤ 1e-8` tuned for percent units. Works in any per-axis scaling of the outline's units. **If Area A tests areas from outside `PolygonRenderer`**, export it as `PolygonGeometry.ContainsPoint` (moved verbatim) in A's commit. If a second overlay ever needs it, it moves to `MapGeometry` under the rules in §3.1. |

### 3.6 Drawing order

**From bottom to top: objective areas, waypoint lines, Questie's icons.** On the world map this already holds, and needs no code change:

| Element | Frame level | Evidence |
|---|---|---|
| Areas | `PIN_FRAME_LEVEL_QUEST_BLOB` (`QP:283`): 2004 on Era, 2007 on Forever | The pin levels manager starts at 2000 and appends each type at `maxLevel + 1` (`Blizzard_MapCanvas/MapCanvas_PinFrameLevelsManager.lua:3, 65-74`). `QUEST_BLOB` is registered 4th on Era (`Blizzard_WorldMap/Vanilla/Blizzard_WorldMap.lua:214-218`, `classic_era` `8165d4cd6`, 1.15.9 (70003)) and 7th on Forever (`Blizzard_WorldMap/Blizzard_WorldMap.lua:271-278`, `forever` `943764493`, 1.60.1 (70338)). |
| Lines | 2015 (`WMap:17-18`) | — |
| Icons | 2016 and up (WP `QuestieMapUtils.lua:53-70`: "+1 to be above waypoint lines") | — |

**Why this order:**
- Lines are thin and areas are large translucent fills, so lines drawn above stay readable while hiding little of the area.
- It also matches where lines sat in B's old line model (2015, B `QuestieFramePool.lua:196`).

**On the minimap**, both layers currently sit at the same level, so their order is undefined. Area D gives areas a lower frame level than lines.

### 3.7 Why it holds up, and alternatives rejected

**Why it holds up:**
- **`MapGeometry` follows a membership rule, not a forecast.** It holds exactly what two overlays use, behind a two-argument interface. It grows only when a second consumer appears.
- **The budget stays a two-function interface** (`NewWork`, `Checkpoint`). The cost argument is optional, and it fixes measurable spikes without new concepts.
- **Presentation never waits on background work**, so a heavy quest log cannot delay drawing what the player is looking at.

**Alternatives rejected:**
- **A shared renderer core** (texture pool, quad helper, retained-view cache). It would couple two well-tested renderers for about 40 lines, across different failure handling and quad contracts. B's cache semantics (owner, marker key, source identity) are specific to polygons, and WP's views depend on the canvas scale.
- **Sharing `_IsFinite`, `SegmentDistanceSq` or `Bounds`.** These are one-liners, or have a single owner, or (`Bounds`) B computes in the same loop as other values.
- **Unifying B's outline smoothing with WP's `Smooth`.** They have opposite goals: enclosing spawns against staying close to a path.
- **B calling `WaypointGeometry.Trim` directly.** Polygon code would then depend on the waypoint feature's module.
- **Keeping the fixed 30-icon yield.** It ignores the shared slice, and B already moved collection off a fixed count in `bd340ebb9`.
- **Waypoint presentation on the shared slice, or as a ThreadLib job.** Visible lines would starve behind background builds (§3.4).
- **Making `BuildPolylines` yield.** Some of its callers are not coroutines.
- **Extracting `FrameBudget` to `Modules/Libs` now.** It has one consumer, and the move needs profiler exclusions (§3.3).
- **One time-based budget for all of Questie's ThreadLib jobs**, replacing `TICKS_PER_YIELD` everywhere. Tempting, but it is master-wide behaviour outside this merge.

## 4. Sequencing

### (a) During the rebase

**Area E needs no change during the rebase.**
- **No textual conflicts.** The Area E files are disjoint between branches (§1.4).
- **Every replayed commit that touches them still loads and passes its own tests.** `PolygonGeometry.test.lua`, `PolygonRenderer.test.lua`, `PolygonRenderCache.test.lua` and `PolygonNudging.test.lua` depend on no file WP changes. The commits:
  - `13f90bb48 feat(polygon): add clustered geometry and hoverable map rendering`
  - `8003dabb0 feat: Enhance PolygonRenderer with marker highlighting and hover improvements`
  - `38da5d634 feat: Separate overlapping polygon markers with stable offsets`
  - `cd70f97d3 feat(polygon): improve icon spacing and scaling logic for better visual consistency`
  - `04c31e0dd perf(polygon): reduce redundant checks and redraws`
  - `31b063d2b perf(polygon): retain rendered views across map changes`
  - `f9358650b fix(polygon): defer mouse propagation setup during combat`
  - `1c1544934 fix(polygon): use objective colors instead of debug tints`
  - `bd340ebb9 perf(polygon): share one frame budget across polygon jobs`
  - `3fc251338 feat(polygon): save area visibility and add nearby mode`
  - `53b5e7ce4 refactor(polygon): compute area hover from the cursor, not mouse propagation`
  - `d674119b6 feat(polygon): draw objective areas on the minimap`
  - `4f76fd411 feat(polygon): cluster objects apart and draw cluster icons on the minimap`
  - `6dd0f8032 feat(polygon): let identical point markers share a stack slot`
  - `715031ef6 chore: wip snapshot of uncommitted blob work`

**Rules for whoever resolves the other areas' conflicts:**
- Keep `Polygon/PolygonGeometry.lua`, `PolygonRenderer.lua`, `PolygonRenderCache.lua`, `PolygonNudging.lua`, WP's `WaypointGeometry.lua` and `WaypointRenderer.lua` byte-identical to their side.
- When a replayed commit's `QuestiePolygon.lua` is touched (Areas A and C), keep the marker loop's `drawn >= 30` yield (`4f76fd411`) and the collection `Checkpoint(work)` (`bd340ebb9`) as they are.
- Do not fold F1–F4 into conflict resolutions. They change behaviour and tests, and belong after the stack.

### (b) Follow-up commits after stacking

Order: F1 → F2 → F3 → F4.
- F2 lands after Area C's commits that change `QuestiePolygon.UpdateObjective`'s marker loop (twin links, fallback copies). F2 touches only the charging lines.
- F3 needs F1's cost argument.

**F1 `perf(polygon): weigh frame budget steps and check before a job's first step`**
- `Polygon/PolygonGeometry.lua`:
  - `PolygonWork` (L31-34): replace `count` with `pending` and add `started`;
  - `NewWork` (L60-63) initialises `pending = 0`;
  - replace `Checkpoint` (L78-99) with the version in §3.3;
  - update the comment above `slice` (L51-54) to say a job checks before its first step and that steps carry costs;
  - keep the `_Checkpoint` alias at L100.
- `Polygon/PolygonGeometry.test.lua`: add the two tests in §5.
- `Polygon/README.md:94`: say that jobs check the slice before their first step and charge steps their cost; that the operation ceiling bounds tests without a clock (about 11 ms of offline work), while in game the 2 ms clock decides.

**F2 `perf(polygon): charge spawn collection and icon drawing to the frame budget`**
- `Polygon/QuestiePolygon.lua`:
  - add `SPAWN_COST`/`ICON_COST` with their rationale after `NEARBY_PADDING` (L83);
  - L924 comment: "Collection charges each spawn to the frame's shared polygon budget.";
  - L961 charges `SPAWN_COST`;
  - L1025-1052: remove `drawn` and the fixed yield, and charge `ICON_COST` after each successful `DrawWorldIcon`. Keep the L1037 comment ("The marker already owns this batch, so cancellation during a yield releases it.").
- `Polygon/QuestiePolygon.test.lua`: the `Update` helper (L7-17) starts a new frame on every resume; replace L830-851 and L853-868; add one test (§5).
- `Polygon/README.md:94`: icon allocation shares the slice icon by icon.

**F3 `refactor(map): share line simplification between waypoints and polygons`**
- **Add `Modules/Map/MapGeometry.lua`:** §3.1, with `Simplify` moved verbatim from `WG:309-357`.
- **Add `Modules/Map/MapGeometry.test.lua`** (§5).
- **WP side:**
  - `Modules/Map/Waypoints/WaypointGeometry.lua`: delete the "Trimming" section (L309-357), and change the header (L1-4) to "Every redraw then runs Smooth, MapGeometry.Simplify and Quads".
  - `Modules/Map/Waypoints/WaypointGeometry.test.lua`: delete `describe("Trim")` (L283-308).
  - `Modules/Map/Waypoints/WaypointRenderer.lua`: import `MapGeometry`, and call `MapGeometry.Simplify` at L171.
  - `Modules/Map/Waypoints/WaypointRenderer.test.lua`: `dofile("Modules/Map/MapGeometry.lua")` in `before_each` (next to L77), and replace `WaypointGeometry.Trim` at L94 and L173.
- **Polygon side:**
  - `Polygon/PolygonGeometry.lua`: import `MapGeometry`; replace L254-318 (`_SegmentDistanceSquared`, the MIT notice, `_ReduceOutline`) with the wrapper in §3.1; at L457 call it and charge `#envelope`.
  - **Provenance:** the notice names only the reduction. Before deleting it, David should confirm nothing else in the file derives from that helper.
  - `Polygon/PolygonGeometry.test.lua`: `dofile("Modules/Map/MapGeometry.lua")` in `before_each` (L26-33), and add the fallback test (§5).
- **All six TOCs** (`Questie_Vanilla`, `_TBC`, `_Wrath`, `_Cata`, `_Mists`, `_Camelot`): add `Modules\Map\MapGeometry.lua` on the line after `Modules\Map\Moonwell.lua`, before `# Waypoints`. QuestieLoader resolves imports at call time, so the placement is only for readability.
- **Docs:** see §6.

**F4 `docs(map): record drawing order and scheduling of waypoints and areas`** covers documentation only, as listed in §6 under F4.

## 5. Tests

Follows the AGENTS.md conventions: `dofile("setupTests.lua")`, `dofile` the module under test, and `.was.called*`.
- **Pure helpers may be loaded directly.** `MapGeometry` is pure, so consumer tests may `dofile` it, as AGENTS.md allows for `QuestieLib`.
- **Drive frames explicitly.** `setupTests.lua:65` pins `GetTime` to 0, so the slice never changes frames on its own.

**New `Modules/Map/MapGeometry.test.lua`** (F3), with `describe("Simplify")`:
1. *drops points within the tolerance of the line kept around them*: moved from `WG.test:284-290`.
2. *keeps a point where the line turns back along itself*: moved from `WG.test:292-297`. It proves distances are to the segment.
3. *keeps both ends, so a closed polyline stays closed*: moved from `WG.test:299-307`.
4. *treats the zero-length closing segment of a ring as a point, keeping its far vertices*: new.
   - **Input:** `{A(0,0), B(10,0), C(10,10), A}` with tolerance 0.25 returns all four points.
   - **What it guards:** what B's wrapper relies on. If zero-length segments were skipped or measured as an infinite line, the result would collapse to `{A, A}`.

**`Modules/Map/Waypoints/WaypointGeometry.test.lua`** (F3): delete the moved `Trim` tests; replace, don't layer.

**`Modules/Map/Waypoints/WaypointRenderer.test.lua`** (F3): the expected-geometry tests at L87-105 and L163-179 call `MapGeometry.Simplify`. No new tests: the renderer's behaviour is unchanged.

**`Polygon/PolygonGeometry.test.lua`:**
- **F1** *holds a new job at its first step while this frame's slice is spent*:
  1. In frame 1, a coroutine spends the ceiling with unit steps.
  2. A second job then calls `Checkpoint` and is suspended inside its **first** call, with 0 steps done.
  3. In frame 2 it finishes.
  
  This fails today: the second job runs 255 steps unchecked.
- **F1** *charges weighted steps to the shared slice*:
  1. Without a clock, a job charging 1,024 per step is suspended inside its 32nd step (32 × 1,024 = 32,768).
  2. It completes the step next frame.
  
  Unit steps keep their 32,768-step ceiling; the existing test at L270-282 covers that.
- **Existing tests still hold unchanged under F1:**
  - L229: the first-step check finds the advancing clock spent and suspends on the first resume.
  - L254: at most 8 resumes.
  - L270: between 2 and 20 resumes without a clock.
  - L284: still `secondChecks == 2` (the initial cancellation check plus the first-step check that yields), then 3 in the same spent frame.
  - L319: the second cancellation check is now the first step, still in 1 resume.
- **F3** *keeps the full outline when the tolerance would leave fewer than three vertices*: `_Build(points, {tolerance = 1000})[1].outline` has as many vertices as with `{tolerance = 0}`. The spline envelope has no collinear vertices, so tolerance 0 keeps all of them. This covers the `#reduced >= 3` guard.

**`Polygon/QuestiePolygon.test.lua`** (F2):
- **Make the `Update` helper (L7-17) start a new frame on every resume**, as `PolygonGeometry.test.lua`'s `_Build` does (L11-24): stub `_G.GetTime` with a counter the helper increments.
  - **Why:** the shared slice lives for the whole test, and `setupTests` keeps `GetTime` at 0.
  - **The failure without it:** once a test's cumulative charges reach 32,768 (about 60 one-cluster updates at `ICON_COST` 256), every later check finds the slice spent and the helper's resume loop never ends.
- **Replace L830-851 ("Batches hold 30 icons")** with *stops marker allocation when the shared slice is spent, and a reset releases the partial batch*:
  1. Set `_G.GetTimePreciseSec = function() return now end`. The `Geometry.Build` stub advances `now` by 1 and returns 31 clusters with outlines.
  2. After the first resume: 1 map icon and 0 minimap icons, and `ToggleMarker` + `Refresh` present no shapes (the entry is still `building`).
  3. After `Polygon.Reset()` and a resume: no further icons, `UnloadFrame` called once, the provider detached.
- **Replace L853-868** with *bounds allocation by time inside one large object cluster*:
  1. One cluster with 40 locations. `QuestieMap.DrawWorldIcon` advances `now` by 0.6 ms per call, and `_G.GetTime` returns a frame counter the test increments between resumes.
  2. Each resume draws a handful of icons, not 30 and not all 41. Assert each resume draws between 1 and 5.
  3. Reset stops it.
- **Add** *draws every marker in one frame while the slice has time*: no clock, and 40 clusters (80 icons, 20,480 operations) finish in a single resume. This proves the fixed 30-icon cap is gone.
- **Keep L870-885** (cancellation while collecting a large spawn list). Under F2 it yields at the first spawn instead of the 256th, and its assertions hold.

## 6. Docs and comments

**F1/F2:**
- **`Polygon/README.md:94`:** rewrite the budget paragraph:
  - jobs check before their first step;
  - steps are charged their cost (geometry 1, spawn 32, icon 256);
  - marker allocation shares the slice;
  - the operation ceiling bounds tests without a clock, while in game the 2 ms clock decides.
- **Inline comments:**
  - `PolygonGeometry.lua:51-54` (above `slice`) and the `Checkpoint` doc;
  - `QuestiePolygon.lua:924` and the cost constants;
  - the L1037 comment stays.
- **`BLOB-PARITY.md:10`** stays true.

**F3:**
- **`docs/waypoints.md`:**
  - L43: the `WaypointGeometry` row becomes "Also `Smooth`, the mitered `Quads` and the hover distance test. Trimming uses `MapGeometry.Simplify`, shared with polygon outlines."
  - L153: link `MapGeometry.Simplify` instead of `WaypointGeometry.Trim`.
  - L178: "`Simplify` inlines the segment distance test".
- **`Polygon/README.md`:**
  - L100: "reduction uses the shared `MapGeometry.Simplify` over the outline closed back to its start";
  - remove the reference to the Nathan Shafer helper wherever it appears;
  - add `busted Modules/Map/MapGeometry.test.lua` to Validation (L176-181).
- **Module headers:** `WaypointGeometry.lua:1-4`, and the new `MapGeometry` header with its membership rule.

**F4:**
- **`docs/waypoints.md:273-281` ("Polygon areas"):** replace "Frame levels: above or below polygon areas is decided then." with the decision: "Lines draw at 2015, above objective areas (`PIN_FRAME_LEVEL_QUEST_BLOB`: 2004 on Era, 2007 on Forever) and below Questie's icons (2016+)." Leave the hover bullets to Area A.
- **Add a short "Scheduling" paragraph to `docs/waypoints.md`**, after "Cost" (L165-180):
  - path geometry is presentation work, done in the maps' `OnUpdate` in the frame that shows it; it never yields and redraws only on change;
  - `BuildPolylines` runs synchronously in `QuestieWaypoints.Add`, which callers outside coroutines reach;
  - neither joins the polygon budget, and §3.4 says why and what to do if dense maps measure slow.
- **`Polygon/README.md`:**
  - one sentence on drawing order under "Direct polygon hover" or "Integration";
  - a two-tier scheduling summary next to L94.
  
  The lines about waypoint lines at L13 and L110 are Area A's.
- **Comments:**
  - `WaypointMap.lua:17` becomes "Below Questie's icons, which start at 2016 (QuestieMap.utils.SetDrawOrder), and above objective areas (PIN_FRAME_LEVEL_QUEST_BLOB)";
  - `QuestiePolygon.lua:282-283` gets "Areas draw below waypoint lines (2015) and Questie's icons."
- **AGENTS.md: no change recommended.** The policy has one owner and is documented where it lives. Add a line under "Coding specifics" only if David wants agents to enforce it repo-wide.

## 7. Verification

**Targeted (after each follow-up):**

```bash
busted Modules/Map/MapGeometry.test.lua
busted Modules/Map/Waypoints/WaypointGeometry.test.lua Modules/Map/Waypoints/WaypointRenderer.test.lua
busted Polygon/PolygonGeometry.test.lua Polygon/QuestiePolygon.test.lua Polygon/PolygonRenderer.test.lua Polygon/PolygonRenderCache.test.lua
luacheck -q -- Database Localization Modules Polygon Public Questie.lua
lua cli/validate-loader-usage.lua
```

**Before calling it done:** `busted -p ".test.lua" .`

**Baseline today:**
- `busted Polygon/PolygonGeometry.test.lua` on `blob`: 21 passed.
- `busted Modules/Map/Waypoints/WaypointGeometry.test.lua` on `waypoints`: 28 passed.

**In game.** Forever 1.60.1 is primary, since both features were verified there; Era 1.15.9 is secondary, since the profiler's numbers come from it.

First, run `/run print(C_AddOnProfiler.IsEnabled())`. To count frame spikes across an action:

```
/run local g,m=C_AddOnProfiler.GetAddOnMetric,Enum.AddOnProfilerMetric QSE={g("Questie",m.CountTimeOver5Ms),g("Questie",m.CountTimeOver10Ms),g("Questie",m.CountTimeOver50Ms)}
```

…perform the action, wait about 5 s, then:

```
/run local g,m=C_AddOnProfiler.GetAddOnMetric,Enum.AddOnProfilerMetric print(">5ms",g("Questie",m.CountTimeOver5Ms)-QSE[1],">10ms",g("Questie",m.CountTimeOver10Ms)-QSE[2],">50ms",g("Questie",m.CountTimeOver50Ms)-QSE[3])
```

`/reload` clears `QSE`. Trigger resets with a profile switch or the objective preset instead. Interleave A/B runs, as master `Modules/Profiler/README.md` advises.

| Check | Setup | Look for |
|---|---|---|
| **V1 Drawing order** (F4; true on the stack already) | Westfall, Questie blobs preset, with quests 142 *The Defias Brotherhood* (the Defias Messenger, NPC 550, patrols about 200 points from Moonbrook at 45,69 north past Sentinel Hill to 46,18), 9 *The Killing Fields* and 153 *Red Leather Bandanas*. Open the Westfall map. | Where the messenger's red route crosses an area, the line draws over the area's fill and border, and Questie's icons draw over both. Repeat at maximum zoom. |
| **V2 Reset spikes** (F1, F2) | Blob mode with about 20 quests, several with large spawn lists (Westfall and Redridge kill and collect quests). Measure across a profile switch, A/B against the stack without F1 and F2. | Fewer `>10ms` and `>50ms` ticks with F1 and F2. Areas then appear over a fraction of a second instead of in one hitch. |
| **V3 Waypoint redraw cost** (decides §3.4) | **a)** Westfall with quest 142 accepted: open the map, then zoom in and out 5 times. **b)** Ironforge, near Courier Hammerfall's 403-point route (`docs/waypoints.md:31`), with his quest icons shown: open the map, switch to Dun Morogh and back 5 times. Use the Questie profiler (Advanced → Open Profiler) for the `WaypointGeometry.Smooth`/`Quads` and `MapGeometry.Simplify` rows. | If any zoom settle or map switch adds a `>10ms` tick, or the per-zoom geometry total exceeds about 8 ms, build §3.4 step 1. Otherwise leave it. |
| **V4 First draw of areas** (`Polygon/README.md:124`) | Blob mode with many shown areas on one zone. Open that map for the first time this session, then close and reopen it. | `>5ms` ticks on the first open only. Record the numbers for B's README. |
| **V5 Marker allocation** (F2) | Durotar, quest 4402 *Galgar's Cactus Apple Surprise* (50 Cactus Apple objects, object 171938), blob mode. Accept the quest, and toggle the preset to force a rebuild. | Minimap icons on each cactus appear within a few frames, with no `>10ms` tick from the rebuild. |

**Profiler caveat:** `QuestiePolygon` calls `PolygonGeometry.Checkpoint` through the module slot, which the profiler wraps for about 3.7 µs per call (`Modules/Profiler/README.md:194`). Polygon job rows therefore overstate collection cost. Read them as upper bounds, or rely on the `C_AddOnProfiler` counts.

## 8. Risks and open questions

| # | Risk or question | Recommendation |
|---|---|---|
| R1 | `SPAWN_COST` 32 and `ICON_COST` 256 are offline estimates: spawn work measured without HBD, icons from HBD's share alone. | Ship them, then tune after V2 and V5. Mis-tuning only changes how often the clock is read; the 2 ms clock still bounds the frame. |
| R2 | The first-step check spreads post-reset work over more frames: 26 ms of collection takes about 13 frames (≈0.2 s at 60 fps), and 132 ms about 65 frames. | Accept. That is the budget's purpose, and V2 confirms. |
| R3 | Under F2, the marker loop can yield between a marker's map icon and its minimap icons. Today it cannot. | Area C's twin linking must not assume both icons of one marker are drawn in the same resume. Routes are drawn only after `UpdateObjective` returns, so no path reads `minimapTwin` mid-allocation. |
| R4 | `Simplify` squares with `*` where B used `^2`. The offline check (glibc `pow`) found 0 mismatches in 100,000 rings; the client's maths library could differ by one ulp, flipping a point exactly at the tolerance. | Accept. Such a flip cannot be seen. |
| R5 | Reduction becomes one unbudgeted step: about 0.5 ms offline for the largest envelope seen. | Accept, and charge `#envelope` afterwards. |
| R6 | WP's per-map redraw cost is unmeasured in game: about 3–8 ms is estimated per zoom settle for a 400-point route. | Measure with V3 before building anything (§3.4). |
| R7 | B's first draw of a map's areas is unmeasured. | Measure with V4. |
| R8 | The profiler inflates polygon job rows (see §7). | Read them as upper bounds. Adding `PolygonGeometry.Checkpoint` to both exclusion lists is an option, but not part of this plan. |
| R9 | **Adjacent maps.** Areas draw on neighbouring detailed maps (`QP:236-264`); WP removed that for paths, because Forever's artwork overshoots zone borders (`docs/waypoints.md:248-249`). An area can therefore show on Mulgore without its patrol line, and may sit offset from the drawn terrain the same way. | Flag to David and Area C. This is product behaviour, out of Area E's scope. |
| R10 | Area borders thicken as the map zooms in (canvas units), while waypoint lines keep their width. At high zoom the two styles disagree. | Not in this merge. Possible later: restyle border thickness by the canvas scale when a zoom settles, or draw borders with `WaypointGeometry.Quads`. |
| R11 | Lines at 2015 tie with Blizzard's dungeon-entrance pins on Forever and pet-tamer pins on Era. | Not a new problem: B's old line frames used 2015 too. Ignore. |
| R12 | `setupTests` keeps `GetTime` at 0, and the shared slice lives for a whole test. A test whose cumulative charges reach the ceiling (128 icons at `ICON_COST` 256, across all its updates) would never see a new frame and would spin. | F2 makes the QuestiePolygon `Update` helper start a new frame on every resume; tests that drive coroutines by hand advance frames themselves (§5). |
| Q1 | Extract the budget to `Modules/Libs/FrameBudget.lua` now? | **No.** Keep it in `PolygonGeometry` until a second consumer exists (§3.3). |
| Q2 | Budget waypoint drawing? | **No.** Measure first (V3), then §3.4. |
| Q3 | Rename B's `PolygonCluster.worldBounds` to set it apart from WP's? | **No.** The types already keep them apart, and they never meet. |

## 9. Contracts with other areas

**Area E provides:**

- **To A (hover):**
  - The pure hit tests in §3.5:
    - `WaypointGeometry.Nearest` and `SegmentDistanceSq`, which need isotropic units and return the single nearest target;
    - polygon containment, inclusive even-odd, all hits, in any per-axis units. If A's design calls it from outside `PolygonRenderer`, A's commit moves it to `PolygonGeometry.ContainsPoint` verbatim.
  - Both kinds of bounds are arrays `{minX, minY, maxX, maxY}`.
  - Both pollers test only when the cursor or the canvas moves.
  - Converting units: canvas units = percent × canvas width / 100 for x, and × canvas height / 100 for y.
  - The stacking order (areas, then lines, then icons) as a visual cue. Precedence is A's decision.
- **To C (quest drawing):**
  - `QuestieMap:DrawWaypoints` and `QuestieWaypoints.Add` never yield. They can be called from inside the polygon objective job and from plain callers.
  - After F2, the marker loop may yield after **any** icon draw (R3).
  - Area E edits only the charging lines of `QuestiePolygon.UpdateObjective`: L924, L961 and the counter and yield inside L1025-1052. C owns the loop body. F2 lands after C.
- **To D (minimap layer):**
  - The renderer contract in §3.2: `New(canvas, …, masks)`, masks applied at creation, no mouse, caller-provided frame levels.
  - In a shared container, areas get a lower frame level than lines (§3.6). Equal levels leave the order undefined.
  - Minimap updates are presentation: synchronous, never yielding. Measure the combined cost while turning: WP alone is 1.70 ms per tick with one patrol in reach (`docs/waypoints.md:237`).
  - `MapGeometry` holds no projection maths. `_ProjectPoint`, `_Transform`, culling and `_IsSecret` are D's.

**Area E assumes:**
- **From A:** hover arbitration needs no renderer change beyond possibly exporting containment.
- **From C:**
  - the old line model is removed, including B's line frames at level 2015, which have no Area E impact;
  - WP's `DrawWaypoints(icon, entity, waypoints, zone, hostile)` signature;
  - C's marker-loop commits land before F2.
- **From D:** whatever layer structure D chooses, each feature keeps its own renderer instance, with D's masks passed to both.

## Appendix: offline checks

Plain Lua 5.1.5 with a stub `QuestieLoader`. The checks loaded `git show origin/waypoints:Modules/Map/Waypoints/WaypointGeometry.lua` and `git show blob:Polygon/PolygonGeometry.lua` directly. The scripts were not committed.

**Equivalence check:**
- **B side:** B's `_ReduceOutline` and `_SegmentDistanceSquared`, copied verbatim with `Checkpoint` stubbed to `true`.
- **WP side:** `WG.Trim` over the outline plus its first point, with the closing copy dropped and the same `#kept >= 3` fallback.
- **Inputs:** 20,000 rings, alternating near-circular and uniformly random, with 3–60 points, at tolerances 0, 0.03, 0.3, 3 and 30.
- **Result:** 100,000 cases and 0 mismatches.

**Measured timings and sizes:**

| What | Result |
|---|---|
| `Build` active time (GetTime advanced once per resume, as ThreadLib does; two runs with different layouts) | 100 spawns 1.8–2.6 ms; 300 spawns 7.5–10.8 ms; 1,000 spawns 24–34 ms; 3,000 spawns 56–82 ms. That is about 20–30 µs per spawn, spread at about 2 ms per frame (for example 4 frames for 7.5 ms, 28 frames for 56 ms), and about 3,000 checkpoints per ms. |
| One collected spawn (the body of `QP:940-956`, HBD replaced by arithmetic) | About 11 µs |
| Burst simulation | N jobs resumed round-robin once per frame, each charging one checkpoint per 11 µs spawn: B's real `Checkpoint` against the §3.3 version with `SPAWN_COST` 32 (table in §2.4) |
| Hull size, uniform spawns in a 120-yd disc, worst of 20 trials | ≤10, 18, 25 and 41 vertices for 20, 100, 300 and 1,000 spawns |
| WP geometry per route (`Smooth` + `Trim` + `Quads` at a 3-unit line and smoothing 0.75) | 0.33 ms at 36 points, 1.24 ms at 120 and 4.93 ms at 400, on synthetic patrols that turn more than real data |
| `BuildPolylines` (cheap `toWorld`) | 0.13 ms at 50 points, 0.84 ms at 400 |
