# Questie world-map polygons

Opt-in, spawn-based objective areas. Select **Questie blobs** in the Icons tab's objective-style preset, or in the initial objective-style popup when offered. The profile setting `enableQuestiePolygons` defaults to false; migration 42 leaves existing profiles opted out unless already explicitly enabled.

## Player behavior

- Local, incomplete quest objectives use representative cluster markers on the world map.
- Hover a marker to preview that objective's areas on the current map and highlight only its attached cluster outline. Plain left-click on its own map toggles pinned visibility; clicking from another map first navigates there. Existing modifier and right-click actions remain unchanged.
- Leaving clears the preview, not a pinned selection. Map changes and closing the map clear previews; pins remain in memory until objective removal or reset.
- Isolated, collinear, and small clusters keep a point marker without an area. Rare-only targets are not discarded.
- Ordinary minimap objective icons remain, including waypoint-only zone fallbacks. Existing world-map waypoint lines attach to cluster markers. This feature adds neither minimap polygons nor minimap waypoint rendering.
- Party-only objectives keep their existing rendering. Quest availability/turn-in markers, quest state, tooltip registration, and tracker behavior remain with Questie.

The preset enables objective display, applies normal Questie icon preferences, and disables Blizzard quest POIs where available. Selecting another preset, including Custom, exits polygon mode. Customizing individual icon preferences does not itself exit the mode.

Areas appear only on their matching UI map and follow their markers' hidden/tracking policy and fade opacity. Where supported, direct hover highlights all participating polygons whose shapes contain the cursor, including overlaps. Polygon frames accept propagated mouse motion, not clicks. Questie icon propagation, click actions, and tooltips are unchanged. Direct polygon hover does not extend a marker preview or change pinned visibility.

## Modules and data flow

```text
Questie objective.spawnList
  → phase-filtered points with explicit map/world coordinates
  → map/instance-partitioned moving-center clusters
  → convex hull → Catmull-Rom samples → convex envelope → reduction
  → cached cluster markers and optional outlines
  → world-map canvas drawing
```

| Module | Responsibility and interface |
| --- | --- |
| [PolygonGeometry.lua](PolygonGeometry.lua) | `Build(points, options, isCancelled)` computes clusters in the caller's coroutine. Returns a complete cluster array, or nil on cancellation. |
| [PolygonRenderer.lua](PolygonRenderer.lua) | `New(canvas, hoverInput?)` creates a renderer with `Draw(shapes, width, height, frameLevel)` and idempotent `Clear()`. Owns reusable frame/texture pools and one shared hover update. |
| [QuestiePolygon.lua](QuestiePolygon.lua) | Questie adapter: source collection, cache, marker ownership, visibility, map provider, and cleanup. Keeps Questie-specific policy out of geometry/rendering. |

There is no runtime dependency on `Blob/` or `QuestPOI/`, native geometry extraction, provider writes, or disk cache. Spawn completeness is limited by QuestieDB's data.

### Geometry and rendering contracts

Input points are immutable records with named `x`, `y` in **zone percentages (0–100)**, `worldX`, `worldY` in HBD world units, and numeric `uiMapId`, `instanceId`. Clusters never cross map/instance partitions. The adapter filters invalid locations and translates dungeon `{-1,-1}` spawns to known entrances. Additional point metadata remains opaque to geometry; each cluster retains its original `representative` point.

Each result has `{uiMapId, x, y, outline?, representative}`. Marker coordinates and outline vertices use percentage units. Defaults are radius `180` world units, area cutoff `0.9` squared percentage units, and reduction tolerance `0.03` percentage units. These are implementation defaults, not player-facing controls.

`Build` must run through a coroutine-aware caller such as ThreadLib. Work checks cancellation/time every 256 operations, yielding after approximately 2 ms or 32,768 operations. The operation ceiling also applies without a working clock. This is a cooperative budget, not a hard frame-time guarantee; clustering and the first hull still have quadratic worst cases.

Renderer shapes contain `{points = outline, color = {r, g, b, fillAlpha}, borderAlpha = optionalAlpha, highlighted = optionalBoolean}`. `highlighted` requests an outline highlight through marker association, independently of native hover support. Pass the canvas's full logical width/height and a frame level below markers. Outlines must be ordered, convex, and not repeat their closing vertex. `Draw` replaces the visible set and returns counts or `nil, error`; a failed draw clears partial allocations. Ordinary canvas zoom/pan is inherited; logical canvas-size changes trigger reprojection.

Compared with the historical implementation, geometry has explicit units, deterministic ordering, duplicate removal and farthest-collinear hull selection. It omits the unsafe interior-point prefilter, uses an efficient monotone-chain envelope for the spline sample cloud, and measures actual point-to-segment distance during reduction. Rendering retains the two-edge quad fan with independent borders, using client `WHITE8X8` rather than copied addon artwork.

These are smoothed convex approximations, not terrain-aware regions, concave polygons, or polygons with holes. Simplification does not guarantee exact enclosure of every spawn.

### Direct polygon hover

Optional `hoverInput` supplies two readers:

- `getCursorPosition()` returns normalized X/Y against the full map canvas.
- `getMouseFoci()` returns participating regions in top-to-bottom order, using the native `GetMouseFoci()` stack.

The adapter supplies these only when the native focus reader and map cursor getter exist. Frames begin with `EnableMouse(false)`; capable frames then use `SetPropagateMouseMotion(true)` and `EnableMouseMotion(true)`. Clicks remain disabled. Missing readers or frame methods leave polygons fully noninteractive rather than blocking underlying input.

One shared update checks every 80 ms, including cursor movement within an unchanged rectangular frame. It highlights every participating polygon whose actual outline contains the cursor; edges and vertices count as inside. Rectangular overlap alone is insufficient. The focus stack is not every overlapping frame: UI that stops propagation excludes underlying polygons from direct hover.

The effective highlight set combines these geometric hits with each shape's `highlighted` request. The adapter sets that flag only when its specific marker is hovered, not for every cluster in the objective. Marker highlighting works without native hover APIs, and leaving a polygon cannot erase a still-active marker highlight. No propagation changes are applied to Questie icons.

Each highlighted border becomes 20% thicker and its RGB increases 25%, capped at 1; border alpha stays unchanged. Borders restyle only when effective selection changes, without rebuilding geometry. Showing a drawing immediately reevaluates highlights, including a stationary cursor; native focus-stack refresh timing still needs live validation.

Clear, empty/failed draws, map hide, and reset stop hover updates and clear both highlight sets. Clear drops shape references before returning frames/textures to their pools. The shared driver is reused; marker-only highlighting uses its hide/show handling without an `OnUpdate` callback. No per-polygon tickers, accumulating hooks, or global input replacements are installed.

## Cache and lifetime

`UpdateObjective(quest, objective, objectiveIndex)` operates on the **full eligible spawn list**, not `AlreadySpawned`'s incremental icon list. It accepts only the current local quest object, excludes completed/party objectives, and uses canonical `objective.Index` where present. This matters because special objectives can all arrive with passed index `0`.

Entries are owned by quest and objective, with map-specific clusters. A sorted signature includes eligible target/location identities and coordinates. Unchanged inputs reuse geometry and markers while refreshing tooltip/icon metadata, map scale, and fade. Changed eligible spawns or phases cause replacement on the next objective update. Map navigation alone does not rebuild geometry.

Two identities protect asynchronous work:

- **Revision:** superseded collection/build work cannot publish after another update.
- **Generation:** marker and waypoint ownership changes only when geometry is replaced. Progress-only cache hits do not cancel a valid route batch.

`UpdateObjective` returns `representative, iconPerZone, waypointWork`. Cache hits return no new map owners, preventing duplicate routes, but still supply a current `waypointWork` token. Callers use `IsCurrentObjective(waypointWork)` before allocations and after yields. `OwnWaypointMarker(frame, waypointWork)` adopts valid fallback map markers or unloads rejected frames.

`RemoveObjective`, `RemoveQuest`, and `Reset` invalidate ownership before releasing markers. Reset also cancels deferred refreshes, clears cached/pinned state, and detaches the map provider. The cleared renderer and detached provider are retained for reuse: WoW native regions must not become unreachable on every mode/profile reset.

`GetObjectiveMarkers(objective)` returns borrowed frame references for tracker highlighting, not a second cleanup owner. Ordinary minimap pins remain in Questie's `AlreadySpawned` references. Polygon owns the cluster map markers; existing waypoint lines follow their owning marker's lifecycle.

## Integration points outside this directory

Keep these hooks small when merging changes from Questie:

| Existing code | Polygon connection |
| --- | --- |
| [QuestieQuest](../Modules/Quest/QuestieQuest.lua) | Shared objective/tooltips first; select ordinary minimap versus clustered map drawing, validate waypoint tokens, remove completed/empty objectives, and reset at `SmoothReset`/`ClearAllNotes`. |
| [QuestieMap](../Modules/Map/QuestieMap.lua) | Optional `DrawWorldIcon(..., destination)` selects `"map"` or `"minimap"`; omitted means the existing paired output. Full quest-frame unload also removes Polygon ownership. |
| [QuestieFrame](../Modules/FramePool/QuestieFrame.lua), [MapIconTooltip](../Modules/Tooltips/MapIconTooltip.lua) | Marker enter/leave/click, removal, and visibility/fade notifications; no accumulating per-frame hooks. |
| [TrackerUtils](../Modules/Tracker/TrackerUtils.lua) | Borrow cluster markers for Show on Map; refresh fill visibility and guard delayed animation against recycled frames. |
| [Questie.lua](../Questie.lua) | Reset on addon disable; existing profile refresh reaches `SmoothReset`. |
| [Icon options](../Modules/Options/IconsTab/QuestieOptionsIcons.lua), [tutorial](../Modules/Tutorial/ChooseObjectiveType.lua), [defaults](../Modules/Options/QuestieOptionsDefaults.lua), [migration](../Modules/Migration.lua) | Preset `polygon`, opt-in flag, selection UI, and migration 42. |

All six flavor TOCs load geometry, renderer, then adapter before `Questie.lua`. [Release packaging](../build.py) includes `Polygon/` and excludes adjacent tests; [CI](../.github/workflows/ci.yml) includes Polygon in linting. The geometry/renderer can be reused independently of the adapter, but they still use QuestieLoader and the renderer requires WoW texture/frame APIs.

## Validation

From the repository root:

```bash
busted -p '.test.lua' Polygon
busted -p '.test.lua' .
luacheck -q -- Database Localization Modules Polygon Public Questie.lua
lua cli/validate-loader-usage.lua
uv run --no-project python build.test.py
git diff --check
```

Adjacent tests cover geometry/cancellation, workload resume limits, rendering/pool failures, geometric hover selection and cleanup, capability fallback, cache identity, waypoint ownership, tracker integration, and marker visibility. Validation so far is offline; mocks establish neither native focus propagation nor click/drag pass-through. Earlier workbench results do not establish live correctness for this integration.

With separate permission for a development client, verify:

- Popup layout and mode switching at normal and unusual UI scales.
- Marker preview/pinning, exact marker-to-outline highlighting, simultaneous overlap highlights, UI blockers, and edges.
- Native motion propagation, unchanged map clicks/dragging, and stationary-cursor focus after redraw.
- Map navigation, zoom/pan, resizing, and reopening.
- Progress, completion/removal, untracking/hiding, phase changes, profile changes, and disable/re-enable.
- Tracker Show on Map, waypoint-only zones, unchanged minimap markers, and preserved modifier actions.
- Dense objectives for responsiveness and repeated resets for stable pooled resource use.

Other client flavors and minimap-addon combinations require their own checks. Do not deploy or reload a live installation merely to run these validations.
