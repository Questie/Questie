# Questie world-map polygons

Opt-in, spawn-based objective areas. Select **Questie blobs** in the Icons tab's objective-style preset, or in the initial objective-style popup when offered. The profile setting `enableQuestiePolygons` defaults to false; migration 42 leaves existing profiles opted out unless already explicitly enabled.

## Player behavior

- Local, incomplete quest objectives use representative cluster markers on the world map.
- Every objective's areas show from quest accept by default. With **Show quest areas when accepted** disabled (Icons tab, shown in blobs mode), an objective's areas show while the player is within 100 world units of any of its clusters' spawn extents on the same instance, and hide again on leaving. A one-second ticker checks this; all of the objective's clusters show or hide together.
- Plain left-click on a marker on its own map shows the opposite of what that objective currently shows: it hides automatic areas or keeps hidden ones visible. A result matching the automatic mode clears the saved choice instead, so the objective follows that mode again. A hiding click also ends the marker's hover preview. Clicking from another map first navigates there. Existing modifier and right-click actions remain unchanged.
- Choices are saved per character in `Questie.db.char.polygon.objectiveVisibility[questId][objectiveIndex]`: `true` shows, `false` hides, and absent follows the automatic mode. They survive reloads and resets; choices for finished quests are not pruned.
- Hover a marker to preview that objective's areas on the current map and highlight only its attached cluster outline. Nearly coincident markers are nudged apart visually; there is no picker. Leaving clears the preview, not a saved choice; map changes and closing the map clear previews.
- Forever's Map & Quest Log shows a box, matching Blizzard's tracking checkbox, in the gutter left of each objective row with areas. While the objective's areas show, a muted fill in its area color with rounded corners (`Icons/quest-log-area-fill.png`) sits inside the box; while they are hidden, the box is empty. Box and fill draw without pixel snapping, so fractional UI scales keep both edges symmetric. Hovering a box previews the objective's areas on the map with every cluster highlighted, and a tooltip says what a click does. Clicks follow the same saved-choice rules as marker clicks; shift-click applies the clicked row's new state to every objective of the quest, including special objectives. Quest titles and rows without areas have no box. Other clients' quest logs are not covered yet.
- Isolated, collinear, and small clusters keep a point marker without an area. Rare-only targets are not discarded.
- Ordinary minimap objective icons remain, including waypoint-only zone fallbacks. Existing world-map waypoint lines attach to cluster markers. This feature adds neither minimap polygons nor minimap waypoint rendering.
- Party-only objectives keep their existing rendering. Quest availability/turn-in markers, quest state, tooltip registration, and tracker behavior remain with Questie.

The preset enables objective display, applies normal Questie icon preferences, and disables Blizzard quest POIs where available. Selecting another preset, including Custom, exits polygon mode. Customizing individual icon preferences does not itself exit the mode.

Areas can appear on adjacent detailed maps when their owning marker is acquired and visible there, including through its native parent. Queued, released, or hidden markers do not draw areas; saved or automatic visibility does not override that gate. Areas also follow logical hiding/tracking rules and fade opacity. Drawing is limited to Zone, Dungeon, and Micro maps, never World, Continent, Cosmic, or unknown map types. Where supported, direct hover highlights all participating polygons whose shapes contain the cursor, including overlaps. Polygon frames accept propagated mouse motion, not clicks. Generic Questie icon propagation, clicks, and tooltips are unchanged; Polygon markers retain direct-click show/hide. Direct polygon hover does not extend a marker preview or change saved visibility.

### Fixed horizontal marker stacks

Only Polygon marker display anchors move. Markers on the same original UI map join a group when their original coordinates are within **0.01 percentage points** of its stable seed. This is a map-space tolerance, not a screen-pixel distance. Groups do not expand through neighbor chains.

Seeds and slot order use quest, objective, map, and original cluster coordinates, not frame allocation order. Two markers sit left/right; three sit left/center/right. Larger groups continue the same horizontal row. Hidden, offscreen, and queued members retain their slots, so scrolling cannot rearrange the remaining icons. Saved visibility remains objective-wide, not per cluster.

Spacing is **70% of the group's maximum current configured icon width**, in HBD wrapper-local units. Equal 16-unit icons have offsets ±5.6; three have offsets −11.2, 0, +11.2. Applying `storedOffset * wrapperEffectiveScale / iconEffectiveScale` makes separation grow with HBD's zoom sizing instead of keeping the centers a fixed screen distance apart. At presentation scale 1.2, a 16-unit icon displays at 19.2 units and the two-icon gap grows from 11.2 to 13.44.

Base widths exclude Questie's separate world/continent icon-size multiplier, so the displayed gap is not necessarily 70% of icon width on every map type. Membership, original coordinates, or configured widths can change group slots; zoom only reapplies their scale. Panning, viewport edges, and neighboring icons do not change the layout.

There is no layout monitor, collision solver, viewport packing, safety reservation, movement limit, or picker. Map callbacks and HBD's optional child callback reapply stored offsets without regrouping. This deliberately solves coincident locations, not general clutter: unrelated icons may still overlap a stack, and large stacks can extend beyond map edges.

Stored coordinates, polygon outlines, waypoint geometry, and navigation targets do not move. Other Questie icons, minimap icons, and Blizzard pins are not shifted. The retired screen-space experiment is preserved in `.scratch/polygon-nudging-experiment/`, locally gitignored with verified checksums. That archive is separate from the [original QuestieDev-Master reference package](../Blob/docs/legacy-questie-blobs/README.md).

## Modules and data flow

```text
Questie objective.spawnList
  → phase-filtered points with explicit map/world coordinates
  → map/instance-partitioned moving-center clusters
  → convex hull → Catmull-Rom samples → convex envelope → reduction
  → cached cluster markers and optional source-map outlines
  → visible-marker gate and projection onto the displayed detailed map
  → retained rendered views per objective, polygon, and destination map
  → world-map canvas visibility and styling
```

| Module | Responsibility and interface |
| --- | --- |
| [PolygonGeometry.lua](PolygonGeometry.lua) | `Build(points, options, isCancelled)` computes clusters in the caller's coroutine. Returns a complete cluster array, or nil on cancellation. |
| [PolygonRenderer.lua](PolygonRenderer.lua) | `New(canvas, hoverInput?)` owns native primitives, pools, and shared hover handling. `Create`, `Configure`, `Style`, `SetVisibleFrames`, `Release`, and `Clear` operate on retained views. |
| [PolygonRenderCache.lua](PolygonRenderCache.lua) | `New(renderer)` owns uniform, lazy per-map view caching. `Present(mapId, shapes, width, height, frameLevel)` reconciles visibility; `Hide`, `Release(owner, key?)`, and `Clear` separate temporary hiding from deletion. |
| [PolygonNudging.lua](PolygonNudging.lua) | `Calculate(items)` assigns horizontal slots from original map coordinates and configured widths. `New()` owns application through `Update(markers, iconScale)`, `Apply`, `Reapply`, `SetEnabled`, `Remove`, and `Clear`. |
| [QuestiePolygon.lua](QuestiePolygon.lua) | Questie adapter: source collection, cache, marker ownership, visibility, layout scheduling, map provider, and cleanup. Keeps Questie-specific policy out of geometry/rendering. Client-neutral quest log API: `GetObjectiveAreaState`, `SetObjectiveAreaShown`, `SetQuestAreasShown`, `SetObjectivePreview`, and `RegisterVisibilityCallback`, which coalesces changes into one next-frame call. |
| [PolygonQuestLogForever.lua](PolygonQuestLogForever.lua) | Forever-only quest log boxes, loaded only by `Questie_Camelot.toc`. Post-hooks `QuestLogQuests_Update` and the visibility callback, and matches objective rows to leaderboard indexes by text. A quest log track for other clients belongs in its own file using the same API. |

There is no runtime dependency on `Blob/` or `QuestPOI/`, native geometry extraction, provider writes, or disk cache. Spawn completeness is limited by QuestieDB's data.

### Geometry and rendering contracts

Input points are immutable records with named `x`, `y` in **zone percentages (0–100)**, `worldX`, `worldY` in HBD world units, and numeric `uiMapId`, `instanceId`. Clusters never cross map/instance partitions. The adapter filters invalid locations and translates dungeon `{-1,-1}` spawns to known entrances. Additional point metadata remains opaque to geometry; each cluster retains its original `representative` point.

Each result has `{uiMapId, instanceId, x, y, outline?, worldBounds, representative}`. Marker coordinates and outline vertices use percentage units; `worldBounds` is the members' spawn extent in world units, used for the nearby check. Defaults are radius `180` world units, area cutoff `0.9` squared percentage units, and reduction tolerance `0.03` percentage units. These are implementation defaults, not player-facing controls.

`Build` must run through a coroutine-aware caller such as ThreadLib. Every objective update runs in its own ThreadLib ticker, so all polygon work shares one slice per frame instead of spending 2 ms per ticker. Jobs check cancellation every 256 operations; `GetTime()` identifies the frame, `GetTimePreciseSec()` measures it, and jobs yield once the frame has spent about 2 ms or 32,768 operations. A job resumed into a spent frame yields again before working, so callers must resume at most once per frame, as ThreadLib does. Spawn collection uses the same `NewWork`/`Checkpoint` budget. The operation ceiling also applies without a working clock. This is a cooperative budget, not a hard frame-time guarantee; clustering and the first hull still have quadratic worst cases.

Renderer shapes contain `{points = outline, color = {r, g, b, fillAlpha}, borderAlpha = optionalAlpha, highlighted = optionalBoolean}`. `highlighted` requests an outline highlight through marker association, independently of native hover support. Pass the canvas's full logical width/height and a frame level below markers. Outlines must be ordered, convex, immutable, and not repeat their closing vertex. Replace point-table identity rather than mutating cached geometry in place. Ordinary canvas zoom/pan is inherited; logical canvas-size changes reconfigure the affected view.

The cache adds `{owner = objectiveEntry, key = marker, source = originalOutline, sourceMapId = originalMapId}` to each shape. Owner/key identities are logical records, never recyclable marker frames. `Present` publishes the requested map's visible set after configuration succeeds and returns `true` or `nil, error`. A failed presentation clears cache ownership and attempts to release all native views, including partial allocations. If native cleanup also fails, the error reports that failure and the renderer keeps the affected resources reachable for a later cleanup retry.

Compared with the historical implementation, geometry has explicit units, deterministic ordering, duplicate removal and farthest-collinear hull selection. It omits the unsafe interior-point prefilter, uses an efficient monotone-chain envelope for the spline sample cloud, and measures actual point-to-segment distance during reduction. Rendering retains the two-edge quad fan with independent borders, using client `WHITE8X8` rather than copied addon artwork.

These are smoothed convex approximations, not terrain-aware regions, concave polygons, or polygons with holes. Simplification does not guarantee exact enclosure of every spawn.

### Direct polygon hover

Optional `hoverInput` supplies two readers:

- `getCursorPosition()` returns normalized X/Y against the full map canvas.
- `getMouseFoci()` returns participating regions in top-to-bottom order, using the native `GetMouseFoci()` stack.

The adapter supplies these only when the native focus reader and map cursor getter exist. Frames begin with `EnableMouse(false)`; capable frames then use `SetPropagateMouseMotion(true)` and `EnableMouseMotion(true)`. Clicks remain disabled. Missing readers or frame methods leave polygons fully noninteractive rather than blocking underlying input.

Propagation is configured outside combat and retained through hiding/pool reuse. `CanPropagateMouseMotion()` reads the native setting, including after the setter runs; no separate Lua flag claims the operation succeeded. Views stay noninteractive if this getter is unavailable or setup does not take effect, with unsuccessful setup retried on a later presentation. Hidden views disable mouse motion instead of changing propagation. Views first displayed during combat remain drawn and support marker highlighting, but cannot join direct hover until propagation is configured. One event-only driver waits for `PLAYER_REGEN_ENABLED`, rechecks combat, and reconciles the latest visible set without rebuilding geometry. Hidden/released views are not re-enabled, reset unregisters pending work, and already-configured native frames need no propagation changes in combat.

One shared update checks every 80 ms, including cursor movement within an unchanged rectangular frame. It highlights every participating polygon whose actual outline contains the cursor; edges and vertices count as inside. Rectangular overlap alone is insufficient. The focus stack is not every overlapping frame: UI that stops propagation excludes underlying polygons from direct hover.

The effective highlight set combines these geometric hits with each shape's `highlighted` request. The adapter sets that flag for the specific hovered marker, not for every cluster in the objective. Marker highlighting works without native hover APIs, and leaving a polygon cannot erase a still-active marker highlight. No propagation changes are applied to Questie icons.

Each highlighted border becomes 20% thicker and its RGB increases 25%, capped at 1; border alpha stays unchanged. Hover restyles borders only when effective selection changes; color and opacity changes also update their appearance without rebuilding fills. Showing a drawing immediately reevaluates highlights, including a stationary cursor; native focus-stack refresh timing still needs live validation.

Empty presentations and map hide stop hover updates and clear both highlight sets without releasing configured views. Release and reset drop shape references and return primitives to their pools. The shared driver is reused without restarting its polling interval for ordinary style updates; marker-only highlighting uses its hide/show handling without an `OnUpdate` callback. Hidden views do not participate in native focus or marker highlighting. No per-polygon tickers, accumulating hooks, or global input replacements are installed.

## Cache and lifetime

### Retained rendered views

All destination maps use the same policy. The cache creates a polygon's native view only when it is first eligible for display on that map. Switching maps or closing the map hides views, retaining their frames, fills, borders, and configured coordinates. A return visit rechecks the adapter's current marker visibility before showing them. First-time views still require synchronous configuration; retaining drawings does not eliminate cold-render cost.

An unchanged view performs no vertex/UV setup or primitive acquisition. Marker highlighting updates only the affected borders; color and opacity update existing primitives. Preview and visibility changes hide/show the affected views without rebuilding unrelated polygons. The renderer's random-color diagnostic (`debugRandomColors`, off by default) is acquisition-based, so retained primitive colors remain stable through refresh, hover, hide/show, and resizing.

A changed destination projection or canvas size reconfigures that view in place. A changed original outline/source map invalidates all of that polygon's destination views. Marker removal releases its views on every map; objective geometry replacement/removal releases the objective's views before marker recycling. Reset releases hidden as well as visible views. There is no timed eviction, current-map exception, eager all-map rendering, or disk persistence. Native region retention can grow with the live objectives and destination maps actually displayed; pools retain their allocation high-water mark after release.

### Geometry and marker ownership

`UpdateObjective(quest, objective, objectiveIndex)` operates on the **full eligible spawn list**, not `AlreadySpawned`'s incremental icon list. It accepts only the current local quest object, excludes completed/party objectives, and uses canonical `objective.Index` where present. This matters because special objectives can all arrive with passed index `0`.

Entries are owned by quest and objective, with map-specific clusters. Progress updates that keep the objective's `spawnList` table and the recorded phase visibility skip collection entirely; Questie replaces spawn lists whole rather than editing them. Otherwise a sorted signature of eligible target/location identities and coordinates decides reuse. Unchanged inputs reuse geometry and markers while refreshing tooltip/icon metadata, map scale, and fade. Changed eligible spawns or phases cause replacement on the next objective update. Map navigation alone does not rebuild geometry.

For adjacent maps, HBD translates the original outline into destination-map percentage coordinates. Successful projections are cached per marker, source-outline identity, source map, and destination map. Source geometry remains unchanged; replacing it invalidates its projected views. Missing, restricted, or nonfinite conversions omit the whole outline and can retry later. Vertices outside 0–100 remain intact for canvas clipping, and geometric hover uses the same projected points. Nudging affects only marker display anchors, not this projection.

Hiding a marker suppresses its area without discarding cached geometry or saved visibility. Native marker `BaseOnShow`/`BaseOnHide` schedules a coalesced, next-frame refresh so Polygon can recheck after HBD parenting and draw-queue bookkeeping settle, regardless of provider refresh order. Provider `RefreshAllData` refreshes immediately. `OnShow`, `OnMapChanged`, and `OnCanvasSizeChanged` share the marker drawing bucket; the pending callback reads the latest map, canvas dimensions, and marker visibility. Hover clearing and nudging still happen immediately in their existing callbacks. Map changes, hide, and provider removal hide the previous drawing immediately without discarding its configured views. Marker show/hide notifications do not regroup nudges or introduce a per-frame visibility monitor or extra pan work.

Two identities protect asynchronous work:

- **Revision:** superseded collection/build work cannot publish after another update.
- **Generation:** marker and waypoint ownership changes only when geometry is replaced. Progress-only cache hits do not cancel a valid route batch.

`UpdateObjective` returns `representative, iconPerZone, waypointWork`. Cache hits return no new map owners, preventing duplicate routes, but still supply a current `waypointWork` token. Callers use `IsCurrentObjective(waypointWork)` before allocations and after yields. `OwnWaypointMarker(frame, waypointWork)` adopts valid fallback map markers or unloads rejected frames.

`RemoveObjective`, `RemoveQuest`, and `Reset` invalidate ownership before releasing markers. Reset also cancels deferred refreshes, clears cached geometry and previews, and detaches the map provider. Saved visibility lives in character saved variables and is kept. The cleared render cache, renderer, detached provider, and inert nearby ticker are retained for reuse: WoW native regions must not become unreachable on every mode/profile reset.

Fixed stacking owns only icon display anchors, guarded by marker and HBD-wrapper identity. Hiding the map or detaching the provider disables offsets but retains slots. Removal and reset clear owned callbacks and restore centered anchors before pooling. No periodic layout driver is allocated.

HBD calls the optional `icon:OnWorldMapPinUpdated(pin)` after wrapper acquisition and scale handling. This restores the stored offset even when a still-visible icon is reanchored without an `OnShow` event. Zoom reapplication stays per-pin; ordinary panning does not trigger stack work. The version-17 upgrade refreshes these methods on active and inactive cached wrappers. A single retained `QuestieMap.RescaleIcons` observer schedules a configured-width refresh after preference setters finish; it is inert while detached. Width uses the current `data:GetIconScale()` value, with cached/unit fallbacks, rather than animated or zoomed frame dimensions.

`GetObjectiveMarkers(objective)` returns borrowed frame references for tracker highlighting, not a second cleanup owner. Ordinary minimap pins remain in Questie's `AlreadySpawned` references. Polygon owns the cluster map markers; existing waypoint lines follow their owning marker's lifecycle.

## Integration points outside this directory

Keep these hooks small when merging changes from Questie:

| Existing code | Polygon connection |
| --- | --- |
| [QuestieQuest](../Modules/Quest/QuestieQuest.lua) | Shared objective/tooltips first; select ordinary minimap versus clustered map drawing, validate waypoint tokens, remove completed/empty objectives, and reset at `SmoothReset`/`ClearAllNotes`. |
| [QuestieMap](../Modules/Map/QuestieMap.lua) | Optional `DrawWorldIcon(..., destination)` selects `"map"` or `"minimap"`; omitted means the existing paired output. Full quest-frame unload also removes Polygon ownership. Its resize observer refreshes configured stack spacing. |
| [HBD-Pins](../Libs/HereBeDragons/HereBeDragons-Pins-2.0.lua) | Optional child callback after acquisition and scale handling reapplies stored presentation offsets; HBD geographic positions remain unchanged. |
| [QuestieFrame](../Modules/FramePool/QuestieFrame.lua), [MapIconTooltip](../Modules/Tooltips/MapIconTooltip.lua) | Marker enter/leave/click, removal, and visibility/fade notifications. Native show/hide schedules a deferred polygon refresh; no accumulating per-frame hooks. |
| [TrackerUtils](../Modules/Tracker/TrackerUtils.lua) | Borrow cluster markers for Show on Map; refresh fill visibility and guard delayed animation against recycled frames. |
| [Questie.lua](../Questie.lua) | Reset on addon disable; existing profile refresh reaches `SmoothReset`. |
| [Icon options](../Modules/Options/IconsTab/QuestieOptionsIcons.lua), [tutorial](../Modules/Tutorial/ChooseObjectiveType.lua), [defaults](../Modules/Options/QuestieOptionsDefaults.lua), [migration](../Modules/Migration.lua) | Preset `polygon`, opt-in flag, selection UI, and migration 42. |

All six flavor TOCs load geometry, renderer, render cache, nudging, then adapter before `Questie.lua`; only the Forever (Camelot) TOC then loads its quest log file. [Release packaging](../build.py) includes `Polygon/` and excludes adjacent tests; [CI](../.github/workflows/ci.yml) includes Polygon in linting. The geometry/renderer can be reused independently of the adapter, but they still use QuestieLoader and the renderer requires WoW texture/frame APIs.

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

Adjacent tests cover geometry/cancellation, workload resume limits, rendering/pool failures, geometric hover selection and cleanup, capability fallback, cache identity, waypoint ownership, tracker integration, and marker visibility. Fixed-stack tests cover map-space grouping, deterministic horizontal slots, proportional zoom spacing, configured-width changes, queued/reacquired wrappers, library upgrades, hidden-member stability, and pool cleanup. For focused layout checks, run:

```bash
busted Polygon/PolygonNudging.test.lua Polygon/QuestiePolygon.test.lua Libs/HereBeDragons/HereBeDragons-Pins-2.0.test.lua
```

Logon reports that retained rendering removed the observed performance problems in-game. This is qualitative feedback, not a controlled timing measurement or validation across all client flavors. No agent performed a reload or live test of the retained-rendering implementation. Adjacent-map alignment, zoom spacing, native input timing, and click/drag pass-through still need the checks below; offline mocks do not establish those behaviors.

With separate permission for a development client, verify:

- Popup layout and mode switching at normal and unusual UI scales.
- Marker preview, show/hide clicks, exact marker-to-outline highlighting, simultaneous overlap highlights, UI blockers, and edges.
- Overlapping markers for quests 317 and 384: visible separation, independent direct-click show/hide, and correct marker-to-polygon highlighting.
- Stable slot order and spacing that grows with icon zoom size, including fractional UI scales, queued/reacquired wrappers, icon-size settings, and disable/re-enable with the map open. Panning should not rearrange stacks. Check large stacks and map edges with the deliberate lack of collision avoidance or edge clamping.
- Native motion propagation, unchanged map clicks/dragging, and stationary-cursor focus after redraw.
- Map navigation, zoom/pan, resizing, and reopening. On adjacent detailed maps, verify areas align with geography, clip at map edges, and use their projected outlines for hover. World and continent views must show no polygons.
- Areas show on accept by default and a click hides them across `/reload`. With the option off, areas appear and disappear while walking into and out of quest areas, including instance changes; saved choices override proximity.
- Hide an owning marker while its area is shown, then show it again: the area should disappear and return without reclustering or losing its saved choice. Check acquisition after map changes and ensure nudging does not move the area.
- Progress, completion/removal, untracking/hiding, phase changes, profile changes, and disable/re-enable.
- Tracker Show on Map, waypoint-only zones, unchanged minimap markers, and preserved modifier actions.
- Dense objectives for responsiveness and repeated resets for stable pooled resource use. Revisit several detailed maps, close/reopen, and hover markers with shown areas: unchanged views should retain primitive identities and debug colors, with no fill geometry setup. Verify first visits, canvas resizing, objective replacement/removal, and reset release the correct views.

Other client flavors and minimap-addon combinations require their own checks. Do not deploy or reload a live installation merely to run these validations.
