# NPC waypoints

Questie draws NPC patrol paths ("waypoints") as outlined lines on the world map and the minimap. This covers where they come from, how they are drawn, the decisions behind them and their measured cost.

## Data

QuestieDB's `waypoints` field, read with `QuestieDB.QueryNPCSingle(npcId, "waypoints")`, holds `table<AreaId, CoordPair[][]>`: per zone, a list of patrols in 0–100 map percent. Questie draws them for:
- objective spawns (`QuestieQuestPrivates`, drawn by `QuestieQuest`). Rank-2 rares and blacklisted NPCs get none;
- NPCs with available quests (`AvailableQuests`), quest finishers (`QuestFinisher`) and manual notes (`QuestieMap`).

All of them call `QuestieMap:DrawWaypoints(icon, entity, waypoints, zone, hostile)`. `entity` is Questie's tooltip key for whose waypoints they are (`"m_<npcId>"`, `"o_<objectId>"`). `hostile` marks NPCs the player fights, which take the hostile colour: objective NPCs, and NPCs that drop an item starting an available quest. Vendors aren't fought, so they keep the patrol colour: those on an objective item's vendor list, and friendly NPCs with the vendor flag that corrections list as dropping a quest-starting item, so that its quest shows.

**QuestieDB's preprocessing** ([`src/derived/waypoints.lua`](https://github.com/Questie/QuestieDB/blob/master/src/derived/waypoints.lua)):
- **Simplification:** patrols are simplified with Ramer-Douglas-Peucker at 0.1 map-percent, about 2–4 yd on a typical zone and about 1 yd in capitals.
- **Splitting:** segments longer than 1.5% (0.75% in capitals) are then split into evenly spaced points. The old line frames needed that to keep their square clickable areas small. Today's lines take no mouse input, so the split only adds collinear points, which [`BuildPolylines`](#architecture) drops again.

Measured on Classic's patrols:

| | Segments |
| --- | --- |
| Raw cMaNGOS data | 22,347 |
| RDP at 0.1% only | 11,460 |
| **Shipped today:** RDP 0.1% plus the split | **18,690** |
| RDP at 0.05% only | 14,288 |
| RDP at 0.02% only | 17,347 |
| RDP at 0.01% only | 18,910 |

The shipped data costs about as many points as RDP at 0.01% would, at the accuracy of 0.1%. A sensible QuestieDB follow-up is to drop the split and lower RDP to 0.05%: still 24% fewer points than today, and twice as accurate. Builds still drawing the old line frames rely on the split, so it has to ship with or after this renderer.

**Loops stay open.** A patrol draws closed only when its data repeats its first point. Closing one ourselves would need data we don't have:
- **Loop or back-and-forth:** the data doesn't say whether the NPC loops or walks back along its route. A wrong closing line shows a route it never takes.
- **Return route:** a looping NPC may not walk straight from its last point to its first.
- **Zone pieces:** a zone's patrol may be only the part inside that zone, so its ends may not be the patrol's ends.

That needs more data from cMaNGOS. The legacy prototypes never closed loops in practice either: their closing segment needed ends 0.05–0.2 yd apart, and their spline samples never got that close.

## Architecture

Everything lives in [`Modules/Map/Waypoints/`](../Modules/Map/Waypoints/), and each module has a test file next to it.

| Module | Responsibility |
| --- | --- |
| [`WaypointGeometry`](../Modules/Map/Waypoints/WaypointGeometry.lua) | Pure geometry. `BuildPolylines` turns a zone's patrols into polylines in percent and world yards. Consecutive points closer than 0.5 yd merge, points a patrol runs straight through (within 0.1°, against the last point kept) are dropped, and points without a world position split a patrol. Also `Smooth`, the mitered `Quads` and the hover distance test. Trimming uses `MapGeometry.Simplify`, shared with polygon outlines. |
| [`QuestieWaypoints`](../Modules/Map/Waypoints/QuestieWaypoints.lua) | Registry and Questie adapter. Each path belongs to its world map icon and is shared on `icon.data.waypointPaths` for highlighting. On the world map it hides and fades with its icon; on the minimap it follows the icon's `minimapTwin`, so **Enable Minimap Icons**, hiding and fading apply. `SetSolo` serves the tracker's Show on Map flash. |
| [`WaypointRenderer`](../Modules/Map/Waypoints/WaypointRenderer.lua) | One frame per path and one pooled texture per segment, plus two fills per sharp turn and a cap per sharp turn, turn back and open end. Each run is smoothed, trimmed and turned into mitered quads; each texture is stretched over its quad with `SetVertexOffset`. Restyling redraws only for a new thickness, and a new colour only tints. Takes no mouse input. |
| [`WaypointMap`](../Modules/Map/Waypoints/WaypointMap.lua) | One `OnUpdate` driver on the world map canvas, with no data provider. Draws and keeps the width constant on screen while zooming. Hovers as the paths layer of [`WorldMapLayers`](../Modules/Map/WorldMapLayers.lua), which offers it the cursor. |
| [`WaypointMinimap`](../Modules/Map/Waypoints/WaypointMinimap.lua) | The paths layer on [`MinimapCanvas`](../Modules/Map/MinimapCanvas.lua): runs within reach, route choice, cursor hit test. |
| [`WaypointHover`](../Modules/Map/Waypoints/WaypointHover.lua) | The one hovered path, on either map: opens and closes its NPC's tooltip and highlight. Also the hover reach. |

**Integration:**
- `QuestieMap:DrawWaypoints` calls `QuestieWaypoints.Add`. `DrawWorldIcon` and `DrawManualIcon` link each world icon to its `minimapTwin` when one call draws both. A drawing feature that draws a marker's map and minimap icons separately links the twin itself, as QuestiePolygon does.
- From the first path on, the registry follows icons through `QuestieFrame`'s icon events: `Unload` releases the icon's paths, `VisibilityChanged` (fake hide/show and fades) redraws them, `HoverStart` highlights the hovered NPC's paths, and `HoverEnd` ends the highlight for the data the hover started with. Before highlighting, `HoverStart` calls `WaypointHover.End`, so a path hover opened for another icon restores its tints before `QuestieFrame` tints the hovered icon's quest.
- `TrackerUtils` flashes use `SetSolo`.
- HereBeDragons-Pins gains `GetMinimapView()`, which returns the radius and rotation it places minimap icons with: `C_Minimap.GetViewRadius()` where available, its zoom tables elsewhere.
- Minimap drawing goes through `MinimapCanvas`, shared with objective areas.
- Settings live under Map → Waypoints; [Settings](#settings) lists them. Switching profiles calls `QuestieWaypoints.Redraw`.

## Settings

Under Map → Waypoints: the two toggles, then an **Appearance** panel (highlighting, width, opacity, colours) and an **Advanced Options** panel (smoothing). With their `profile` keys and defaults:

| Setting | Key | Default | Effect |
|---|---|---|---|
| Enable Map Waypoints | `waypointMapEnabled` | on | Off hides world map paths. Paths stay registered, so turning it back on shows them at once. |
| Enable Minimap Waypoints | `waypointMinimapEnabled` | on | Minimap paths also follow **Enable Minimap Icons**, through the icons' minimap twins. |
| Highlight patrol paths on hover | `waypointHighlight` | on | Off keeps hovered paths in their own colour, and each route drawn as its most visible copy. Hovering a line still opens its NPC's tooltip. |
| Line width | `waypointWidth` | 3 | Map UI units on the world map, minimap units on the minimap. Hover reaches one unit past the edge. |
| Line opacity | `waypointOpacity` | 100% | Scales each colour's alpha, up to opaque: 10–200%. |
| Patrol color | `waypointColor` | `{1, 0.72, 0, 0.5}` | |
| Hostile patrol color | `waypointHostileColor` | `{1, 0.2, 0, 0.7}` | Objective NPCs, and NPCs dropping an item that starts an available quest. Vendors keep the patrol color. |
| Highlight color | `waypointHighlightColor` | `{0.93, 0.46, 0.13, 0.8}` | |
| Waypoint smoothing | `waypointSmoothing` | 0.75 | See [Smoothing](#smoothing). |

**Show waypoint hover area** (`waypointDebugHover`) sits under Advanced → Developer Options; see [Hover](#hover).

Smoothing calls `QuestieWaypoints.Redraw`, which draws every line anew with `WaypointRenderer.RedrawAll` and invalidates both maps. The others call `QuestieWaypoints.Refresh`, which only invalidates both maps. They restyle each drawn route on the next frame: a new width redraws its lines, a new colour only tints them. `QuestieWaypoints.Color` reads the colours and opacity when styling, so paths store only whether they are hostile.

## Behaviour

- **Fading** uses `profile.iconFadeLevel` through frame alpha.
- **Width:** constant on screen; see [Settings](#settings). Hover reaches one unit past the line's edge, tuned in game on the 4-unit line: 2.5 units from the default 3-unit line.
- **Clicks:** lines are click-through. Clicks over them reach the map; clicking a line no longer does what clicking its icon does.
- **Duplicate routes draw once.** An NPC with three quests has three quest icons, and each draws his patrol. Courier Hammerfall's Ironforge route used to stack three 50% copies to about 88% opaque.
  - Each path's `route` is its entity key, area and part of the patrol, and each route draws once.
  - On the world map that is the hovered copy while highlighting is on, otherwise the most visible one. A highlight makes the world map choose its copies again on the next frame, without drawing them again, so a hovered copy takes its route over and hands it back once the hover ends.
  - On the minimap it is the highlighted copy while highlighting is on, otherwise the most visible one. A highlight makes the minimap choose its copies again, without projecting them again.
- **Self-overlap:** a patrol that crosses or retraces itself draws darker there, marking where the NPC walks twice. Frame buffers could avoid that, but were [tried and rejected](frame-buffer-group-opacity.md).
- **Tracker flash:** Show on Map shows only the flashed quest's paths. Manual and townsfolk paths hide during it too.
- **Own map only.** A path draws only on the map it belongs to. See [Neighbouring maps](#neighbouring-maps).

## Drawing a line

Figures in units below were measured on the 4-unit line, the default before it became 3. Smoothing and trimming tolerances are in half line widths, so they scale with the width, and the angles and ratios hold at any width.

### The outline texture

[`Icons/waypoints/waypoint-line-aa.png`](../Icons/waypoints/waypoint-line-aa.png) is 16×16, constant along its length; rows run across the line:
- **Line:** the middle 12 rows have the proportions of Blizzard-style `WHITE32X32BLACKLINES`: a quarter black, a white core and a quarter black. Vertex colour tints only the core.
- **Fade:** two rows on each side fade the black edge to transparent (alpha 0.5, then 0). Transparent texels are black, so filtering fades to black rather than to a fringe.
- **Quads:** drawn 16/12 as wide as the line, so the line keeps its thickness, the fade grows outward and the quad's hard rasterised edge lands on transparent texels.
- **Filtering:** `LINEAR`. Lines move by fractions of a pixel, and a texture with about as many rows as the line has pixels blends smoothly under bilinear filtering.
  - **`NEAREST`** picks one row per pixel. The 1 px outline jumped between 0 and 2 px and diagonal edges crawled, which flickered visibly on the minimap.
  - **`TRILINEAR`** needs a correct mip chain. The first asset, a `WHITE32X32BLACKLINES` BLP, had broken mipmaps (below full size only its top rows were opaque), so it drew a thin dark edge with no core.
  - **A larger texture** would need a properly mipmapped BLP and `TRILINEAR`. Worth it only if 1080p players report shimmer.

[`Icons/waypoints/waypoint-cap-aa.png`](../Icons/waypoints/waypoint-cap-aa.png) is 32×32: the same rows turned into rings around its centre, so a disc of radius 8 texels with the line's profile and transparent black around it. Radius 8 matches the line's 8 texels from its centreline to its quad edge, so the cap has the line's texel density and filters the same way. Sharp turns, turn backs and open ends draw it; see [Mitered joins](#mitered-joins).

Both textures are drawn from SVG sources in [`Icons/originals/waypoints/`](../Icons/originals/waypoints/): its `build.sh` renders them into `Icons/waypoints/` with `rsvg-convert` (librsvg), and `preview.py` draws them zoomed. `build.py` leaves `originals` out of releases.

**Alternatives considered.** In game the disc looked a little lower-res than the line. At the default width both are drawn about 1.5× smaller than their texels, and `LINEAR` takes about one sample per pixel: the line's boundaries stay straight, but the disc's rings are curves a few pixels across. A blurred disc, a 64×64 disc with mipmaps, and fans of line-texture wedges were built for an in-game comparison, and the disc was judged fine. A plain larger disc would be drawn smaller still and look worse. Open ends double the caps: over Classic's patrols at scale 1, 556 of 579 are open, giving 1,112 open ends beside about 610 turn caps. With the disc, caps and fills add 10.9% to the segments' textures; fans of 45° wedges would add 31%.

The classic way to draw such a texture is Blizzard's `DrawLine(texture, frame, sx, sy, ex, ey, thickness, 1, "TOPLEFT")` with `CLAMPTOBLACKADDITIVE` wrapping. It sets a bounding-box quad and texture coordinates outside 0–1, and the clamp makes the rest transparent. It can only place rotated rectangles, though, and it divides by the segment's length. Questie uses it only for the debug hover view.

### Mitered joins

Rectangles per segment leave a wedge-shaped gap on the outer side of every turn and overlap on the inner side, where one segment's black edge crosses the next one's core and the half-transparent lines draw darker. Consecutive segments therefore meet on the line that halves their angle:

```text
n1, n2 = unit normals of the incoming and outgoing segment
m      = normalize(n1 + n2)               -- the bisector
len    = halfWidth / cos(turn / 2)        -- |n1 + n2| = 2 cos(turn / 2)
left   = P + m * len,  right = P - m * len
```

- **Drawing:** each segment is one texture, anchored to its quad's bounding box, with `SetVertexOffset` moving each vertex onto a corner. The image only changes across its width, so whichever diagonal the client splits the quad on, both triangles keep the black rows on the long edges.
- **Sharp turns:** past 120°, where the outer corner would lie more than `MITER_LIMIT` (2) half widths from the point, the miter would spike. The outer corner used to be clamped there, which tapered the line to a long `>` at turnarounds. Now:
  - **Inner corners** are mitered as at any other turn.
  - **Outer corners** end square at the point.
  - **Fills:** each segment's end then runs from its inner corner to its outer one, which misses the point. A fill, the triangle between those corners and the point, completes it. It is drawn with the line texture, with `SetTexCoord` placing the line's edge rows at the corners and its centre row at the point, so it carries the segment's own profile.
  - **Cap:** the outside of the turn is the sector of a disc around the point, between the two square outer ends. The cap texture is drawn on a kite from the point out along both outer ends and the outward bisector, √2 half widths long, which holds up to a half disc. `SetTexCoord` maps the kite onto the image at the disc's scale, and the image past the disc is transparent.
  - Together they neither gap nor overlap, while the pull-back stays below its limit. Near 180° it almost always reaches it: at 170°, the full pull-back needs both segments longer than about 45 units at the default width. There the fills and segments overlap on the inside, like any short-segment join. Each sharp turn costs three more textures, and each open end one.
- **Short segments:** each inner corner stays on its own segment's inner edge, pulled back to where the inner edges cross, at most half the shorter segment. Past that the segments overlap slightly on the inside.
- **Convexity:** the client splits every quad along a fixed diagonal, and a concave quad would draw outside its outline. Corners placed this way keep every quad, fill and cap convex. An earlier version slid the clamped inner corner along the bisector and made about 4 in 10 quads concave at tight joins. A fuzz of 738k quads from random polylines found none concave or non-finite, before fills and caps existed. A turn back's cap is an exact half disc: built from both segments' own normals, a fraction of a degree apart, it bent past straight at the point.
- **Open ends** are square, with a half-disc cap beyond each, so a path reaches half a line width past its last point. The hover area's ends are round too.
- **Edge cases:** turning back on itself (within 0.1° of 180°) keeps square ends, and a half-disc cap rounds them. A patrol that returns to its first point joins there.
- **Client APIs:** `Texture:SetVertexOffset` and the `UPPER_LEFT_VERTEX` constants (1–4) exist on Era, Anniversary, Mists and Forever. Offsets point y up like `SetPoint`, as Blizzard's own use in `Blizzard_ArtifactUI/Blizzard_ArtifactPerks.lua` shows. Fills and caps also use the 8-value `SetTexCoord`. `SetTexture` doesn't reset texture coordinates, so fills and caps pool apart from lines.

### Smoothing

Patrol points are where the NPC walks, so smoothing is cosmetic and must stay close to them. **The rule: the true path always stays under the drawn line.**

Each corner P becomes a quadratic Bézier curve from a point on its incoming segment to a point on its outgoing one, with P as control point, so it is tangent to both. With unit directions *u1* in and *u2* out, and tolerance ε:

```text
bend = |u2 - u1|                           -- 2 sin(turn / 2)
cut  = min(4ε / bend, L_in / 2, L_out / 2) -- how far back along each segment the curve starts
T1 = P - cut·u1,  T2 = P + cut·u2
B(s) = (1-s)²·T1 + 2s(1-s)·P + s²·T2
```

`B(½) = (T1 + 2P + T2) / 4`, so the curve passes `cut · bend / 4` from P: exactly ε, or less where short segments cap it. One tolerance gives gentle bends long curves, where a polyline looks most faceted, and sharper turns tighter ones. At the default ε of 1.5 units the curve starts 23 units back at a 15° bend (usually capped), 11.6 at 30° and 6 at 60°.

The curve is tightest in its middle, with radius `cut · cos²(turn/2) / sin(turn/2)`, which is `2ε · cot²(turn/2)` uncapped. A line can't follow a curve tighter than its half width: its inner edge folds over itself, and the pieces' quads overlap and draw darker. Such corners stay sharp, and the miter join draws them cleanly. The check uses the quads' half width, fade included, so on the 4-unit line turns up to about 90° are rounded at the default: about 80° at a setting of 0.5, and 100° at 1. Measured: up to 17 square units drew twice at a 140° corner before this rule, and none at 30–150° and any setting after it.

Rules ([`WaypointGeometry.Smooth`](../Modules/Map/Waypoints/WaypointGeometry.lua)):
- **Screen units.** ε is the `waypointSmoothing` setting in half line widths: 0.75 by default, 1.5 units on the 4-unit line, picked in game between 0.5 and 1. A tolerance in yards would be invisible zoomed out and visibly off the path zoomed in. QuestieDB's simplification already moves points 2–4 yd, so a couple of units zoomed out costs little real accuracy.
- **Ends stay exact:** open ends, splits where data is missing, and the minimap's culling cuts.
- **Closed stays closed.** The corner where a patrol returns to its start is rounded too; drawing starts where its curve ends and finishes with that curve.
- **No overlap between curves:** each takes at most half of each segment. Curves meeting in a segment's middle share that point; points closer than a thousandth of the half width merge, so rounding never leaves a sliver segment.
- **Hidden corners stay sharp:** a corner whose curve would start less than half the quad half width back is already hidden in the join.
- **Fewest pieces.** With n equal parameter steps the chords stray at most `deviation / n²` from the curve. A curve takes the fewest even number of pieces, at most 8, that keeps that within an eighth of the half width: 2, or 4 for the widest curves, at the default. Curves get 4 pieces once they pass more than half the quad half width from their corner, from a setting of about 0.67, which is why 0.75 costs about as much as 1. Two chords for every curve were tried: a quarter fewer segments zoomed in, but gentle curves looked visibly jaggier there. Even, so its middle, nearest P, is always drawn.
- **Hover stays on the raw points.** At the default the drawn line's centre is at most 1.75 units off them, inside the 3-unit hover reach. In the middle of a gentle curve the line's inner edge can reach about half a unit past it.

### Trimming

Smoothing adds curve points that are often too small to see, most of all zoomed out. [`MapGeometry.Simplify`](../Modules/Map/MapGeometry.lua) then drops, with Ramer-Douglas-Peucker, every point within δ of the segment between the points kept around it. δ is `WaypointRenderer.TRIMMING` half line widths (1/8, a quarter unit on the 4-unit line).
- **Distance, not angle.** Small turns would each pass an angle test and add up, collapsing a slow arc; a distance bound holds however many points go. Dropping QuestieDB's split points can use an angle because they are exactly collinear, and it compares with the last point kept.
- **To the segment, not its line.** A patrol's turning point, where it walks back along itself, lies on the line through its neighbours but past their segment, so it stays.
- **Ends stay**, so closed patrols stay closed.
- **Only after smoothing.** Trimming the raw lines at a quarter unit removes 0–9 of 11,448 segments: QuestieDB already simplified them at about 1 unit.
- **Error budget:** ε + δ = 1.75 units at the default, under the line's 2-unit half width. Up to a setting of 0.875 the true path stays under the solid line, and up to about 1.2 under its soft edge, 2.67 units out.

Not used:
- **Catmull-Rom splines** (the legacy prototypes) pass through every point but bulge between them, with no bound on how far; uneven spacing overshoots most. The prototypes also ran them in stretched map-percent units, sampled 9 points per segment and cut back every patrol's ends.
- **Chaikin corner cutting** cuts a fixed fraction of each segment, so a sharp turn between long segments loses a large chunk. Clamping it becomes the approach above.
- **Pre-smoothing in QuestieDB:** the tolerances are in screen units, so any fixed yard tolerance is wrong at most zooms, and pre-sampled curves would ship points every zoom draws and runtime trimming removes again.

### Cost

Over Classic's 579 patrols, at canvas scales 0.5 (zoomed out) to 4 (zoomed in), at the default setting:

| | Segments |
| --- | --- |
| Stored | 18,690 |
| After dropping straight points | 11,448 |
| Smoothed | 23,078–42,694 |
| Smoothed and trimmed | 14,864–39,237 (20,727 at scale 1) |

Zoomed in, curves are big enough to see and trimming rightly keeps them; at scale 4 that's about twice the stored count. Settings up to about 0.65, where the widest curves still take 2 pieces, draw like 0.5: 14,337–29,148. Settings from 0.75 to 1 draw within 1% of each other.

Geometry for every Classic patrol at once, in plain Lua 5.1, takes 21 ms for the sharp quads and 80–85 ms smoothed and trimmed, split about evenly between `Smooth`, `Simplify` and `Quads`. `Simplify` inlines the segment distance test, which took it from 56 ms. Trimming costs about 3 µs of Lua per segment it removes. In return each removed segment saves about 7 texture calls and its rendering on every frame it's shown.

Joins where a short segment caps the miter's pull-back already exist in the stored data: 1,407 at scale 1. Smoothing alone raised that to 2,386, by shortening the segments next to sharp corners; with trimming it's 1,563.

### Scheduling

Path geometry is presentation work. The maps' `OnUpdate` draws it in the frame that shows it, never yields, and redraws only what changed. `BuildPolylines` runs synchronously in `QuestieWaypoints.Add`, which callers outside coroutines reach, such as the `/questie` search and the Townsfolk ticker; it is linear in patrol points, under 1 ms for the longest patrol. Neither joins the polygon frame budget: a background job would put visible lines behind every objective update after a reset. If dense maps measure slow, keep views across map switches first, and only then spread `WaypointMap`'s redraw across frames with a per-frame cap.

## World map

`WaypointMap` runs one driver on the canvas while the map is open:
- **Redraws:** after path changes, map switches and canvas resizes. Paths draw at the paths layer's frame level from `WorldMapLayers` (2015): above quest areas, below Questie's icons.
- **Zoom:** line width is divided by the canvas scale. While a smooth zoom eases the scale, lines scale with the canvas. They are redrawn once it settles, or once their width drifts more than 25% from the target.

The world map pays the geometry once per zoom or map change, only for the paths on that map.

### Hover

Hovering a line is hovering its NPC. It opens the tooltip of the NPC's icon on that map, and that icon's hover highlights all of the NPC's paths. On the world map, an icon that isn't visible can't anchor its tooltip, so then it only highlights; paths draw only while their icon isn't hidden, so that's rare. Highlights show on both maps, so hovering a minimap icon highlights its NPC's paths on the minimap too. Hovering works on [the minimap](#minimap) as well; `WaypointHover` keeps one hovered path across both maps, and each map only ends its own hover.

The hover shape is the path fattened by radius *r*: the union of capsules around its segments. The test is **distance from the cursor to the nearest segment ≤ r**:
- **Joins:** joins of any angle are round, so no wedge-shaped dead corner.
- **Short segments:** a very short segment is a disc.
- **Units:** distances are in canvas units divided by the canvas scale, so the band doesn't depend on direction or map aspect.
- **State:** hover state is per path, so moving along a path toggles nothing.

*r* is half the line width plus one unit, one past the line's edge: 2.5 units at the default width of 3. It was tuned in game on the 4-unit line, where it is 3 units, from a first guess of `max(thickness / 2 + 4, 6)`. There the capsule leaves out the outer tips of turns sharper than about 96°, which reach up to 4 units; hovering the line beside them still works.

**Driver:** [`WorldMapLayers`](../Modules/Map/WorldMapLayers.lua) runs the one cursor poller for every layer Questie draws on the world map, and offers the cursor top down.
- A check runs only when the cursor's canvas position or the zoom changes, or after the paths redraw.
- Secret, non-finite or off-canvas cursor values clear the hover.
- Layers hover only over the bare map (`GetMouseFocus() == ScrollContainer`), so Questie's icons, Blizzard's pins and other UI on top win. In the gamepad UI nothing drawn hovers.
- The paths layer is above the quest areas, so a path wins the cursor over an area beneath it.
- Paths hover only what they drew for the cursor's map and canvas size.
- Each path's bounding box rejects most paths; the rest get a squared-distance test per segment.
- Overlapping paths: the nearest wins, and there are no combined tooltips.

**Debug view:** turn on Advanced → Developer Options → **Show waypoint hover area**. It draws every path's hover area beneath it: a translucent `DrawLine` band of width 2*r* per segment and a disc on every point. Together those are exactly the capsule union.

## Minimap

`WaypointMinimap` is the paths layer of [`MinimapCanvas`](../Modules/Map/MinimapCanvas.lua), the drawing surface over the minimap that objective areas share. The canvas places drawings the way HereBeDragons-Pins places minimap icons, so paths and icons line up while walking and turning. Its header is the reference for what it owns:
- **Projection:** world-yard points are projected relative to a fixed origin into each layer's container, rotated with the player's facing when the minimap rotates. The view radius comes from `HBDPins:GetMinimapView()`. Walking only moves the containers. Zoom, minimap size, instance and, on a rotating minimap, facing changes project again, and so does drifting half a radius from the origin.
- **Masks:** the canvas clips to the minimap, and every texture gets two masks:
  - **Shape:** the asset last passed to `Minimap:SetMaskTexture`, post-hooked since Blizzard has no getter. That's how minimap addons such as SexyMap set their shapes, and how Forever's own skin sets its mask on every Rotate Minimap change.
  - **Fallback shape:** a mask set before Questie loaded, such as Forever's at login or an addon that loads earlier, can only be read through `GetMinimapShape()`. That is a community convention, not Blizzard's, and it only names the round quarters. A fully square minimap gets the square mask. Any round quarter gets the round mask, so paths stop short in square corners rather than draw past a round edge: Forever's own mask atlas where the client has it, or a round texture.
  - **Player:** a soft 38 px hole over the player arrow.
- **Culling:** only segments within 2 view radii of the origin are drawn. Everything visible lies within √2 radii of the player, so that covers the view until the canvas projects again. If culling cuts a closed patrol elsewhere, its last run continues into its first, so its start stays a corner.
- **Layering:** paths sit one level above objective areas, two above the minimap, and far below Questie's minimap icons. Blizzard's backdrop chrome at the minimap's level + 1 draws beneath them.
- **Hover:** the [capsule test](#hover) in minimap units, against the runs drawn for the current projection.
  - The canvas offers the cursor to its layers top down, as `WorldMapLayers` does on the world map; minimap areas don't hover. Nothing hovers in Forever's gamepad UI (`QuestieCompat.IsGamepadUIEnabled`).
  - The cursor counts only over the bare minimap (`GetMouseFocus() == Minimap`), so Questie's minimap icons, buttons and other addons' pins win.
  - It must also be inside the minimap's shape. Only a minimap known to be square hovers its corners: by the square mask, or by `GetMinimapShape()` reporting `"SQUARE"`, also when a minimap addon sets its own square texture. Anything else counts as round, as the ellipse inscribed in the minimap, so a custom shape never hovers paths its mask hides. The soft hole over the player arrow still counts.
  - It's rechecked when the cursor moves against the paths: by moving itself, by the player walking or turning, or when a minimap layer draws again.
  - It shows the tooltip of the NPC's minimap icon, owned by the minimap rather than the icon, so it shows even while HereBeDragons hides that icon. Questie's patch to HereBeDragons-Pins hides minimap icons more than 500 yards (|Δx| + |Δy|) from the player, and a long patrol can pass close by while its icon is that far; Stormwind has one. The path tooltip lists exactly the icon of every copy of the hovered route that shows on the minimap (`QuestieWaypoints.MinimapIcons`, through `MapIconTooltip.ShowForIcons`), one for each of the NPC's quests, however far away and faded. Other icons near the NPC's are not listed: a path hover is about its NPC.
  - Minimap icons also fade with distance: from 200 yards (`fadeLevel`) over the next 100, so beyond about 300 yards they are fully transparent. A faded-out icon shows nothing when hovered itself, but a hovered path still shows its tooltip, and highlights whether or not the tooltip shows. The fade only updates while HereBeDragons shows the icon, so an icon that faded out stays so until the player comes within 500 yards.
  - The tooltip is a frame of its own, `QuestieWaypointMinimapTooltip`, like the gamepad map hover's. On Forever, Blizzard's `Minimap_OnUpdate` takes `GameTooltip` every frame while the cursor is over the minimap, for its blip tooltips (`Blizzard_Minimap/Mainline/Minimap.lua`, 1.60.1), so the NPC's tooltip there vanished at once while its highlight stayed. Classic Era's minimap has no such script. Shift redraws it, as GameTooltip's.
  - Moving onto the NPC's minimap icon ends the path's hover, and the icon opens its own tooltip.
  - The hover ends when the paths can't be drawn, such as in an instance, and when the minimap hides.
- **Driver:** the canvas's one `OnUpdate`, hidden while no layer has anything to show. A failing layer is reported once and stays off until its next change; it never breaks the addon or the other layers.

**Measured in game** (Forever, Ironforge, rotating minimap, one 31-segment patrol in reach, a 360° keyboard turn at about 48 fps, at the earlier default smoothing of 0.5). Questie's time per tick from `C_AddOnProfiler`:

| | Turning | Standing still |
| --- | --- | --- |
| Minimap lines shown | 1.70 ms | 0.14 ms |
| Minimap lines hidden | 0.38 ms | 0.10 ms |

The lines' ~1.3 ms per turning tick splits into `Smooth` 0.22 ms, `Simplify` 0.18 ms and `Quads` 0.28 ms. On top of that come about 0.36 ms of client texture calls (4.9 µs per segment: 1.7 for the anchors, 2.4 for the four vertex offsets) and about 0.5 ms of projection, renderer Lua and garbage collection. The rest of turning is HereBeDragons moving Questie's minimap icons.

That was judged good enough, since few players use a rotating minimap. If it ever matters, two steps would cut it to about a third:
- **Cache per zoom level:** keep each path's quads, unrotated, per minimap zoom level, and only rotate their corners while turning.
- **Move only the corners:** anchor each texture once and update only its vertex offsets. Check in game first that the client neither culls nor mis-clips such a texture.

## Neighbouring maps

**Removed for now.** Drawing paths on neighbouring maps was built, then taken out:
- **Why:** on Forever, the redrawn Mulgore artwork draws its eastern edge about 100 yards past the real border, so Barrens paths projected onto Mulgore looked pulled onto its drawn mountains. Fitting the artwork would make paths disagree with Blizzard's player arrow, and icons from neighbouring zones would have to move with them. Leaving the feature out was simpler than either.
- **Projection:** each path's world-yard points went through HereBeDragons onto the destination map. A path drew there only when its projected bounds overlapped that map. Points outside 0–100 stayed for the canvas to clip, and results were cached per path and destination map.
- **Destinations:** zone to zone only. Dungeon floors and caves share world space with the maps around them at other heights, and continents were never drawn on.
- **Capitals** were excluded in both directions: 1453–1458, plus 1947, 1954, 1955, 125 and 126 for later clients. City paths are long and dense, and a city is a small corner of its zone's map.
- **Code:** `WaypointGeometry.Project`, `CanProject` and `CAPITAL_MAPS`, and `WaypointMap.PointsOnMap`, in the history of PR #8026 before `refactor(waypoints): draw paths on their own map only`.

## History

**The previous implementation** drew each segment as a pooled, mouse-enabled `Button` sized to the segment's bounding box. It sat on the world map canvas and held two `Line` regions, a fill and a black border 2 px thicker at half alpha. Its problems:
- **Zoom:** geometry was baked in canvas pixels, so lines thickened as the map zoomed in.
- **Hit areas:** each frame's mouse area was its whole bounding rectangle, above Blizzard's pins, so long diagonals stole their hover and clicks.
- **Frame count:** dense patrols made hundreds of frames.
- **Fade:** it read `global.iconFadeLevel`, which has no default, so faded icons kept opaque lines.
- **Map placement:** lines were registered with HereBeDragons using 0–100 coordinates where it expects 0–1. HereBeDragons rejected them, so it only ever showed and hid them on their own map. It worked, but by accident.
- **No minimap lines.**

**Earlier prototypes** never shipped working minimap lines:
- **QuestieDev (2021–22)** registered each segment with HereBeDragons at its midpoint and scaled it with fixed zoom tables. The geometry didn't rotate with the minimap, and thickness didn't follow zoom.
- **The map refactor** commented its minimap waypoint pool out. Its hover offset each segment into a rectangle in normalised map units and ray-tested it, started from the segment's frame. That gave three problems, which the capsule hover above fixes:
  - **Short segments:** a short segment's corners nearly coincide, so hover was patchy.
  - **Sharp turns:** the outer wedge flickered as the cursor crossed it.
  - **Tiny targets:** tiny segments made about 1 px targets.
- **Both** used today's colours, at thickness 4–5 with the outlined texture.

## Polygon areas

Waypoints are on for every player, while polygon quest areas (blob mode) are opt-in. They are two drawing features that never import each other; `test/MapFeatureImports.test.lua` keeps it that way.
- **Hover and frame levels:** set by `WorldMapLayers`' `LAYER_ORDER`. Lines draw at 2015, above objective areas (`PIN_FRAME_LEVEL_QUEST_BLOB`: 2004 on Era, 2007 on Forever) and below Questie's icons (2016+). Hover follows the same order: paths win the cursor over the areas beneath them.
- **Icons:** both follow Questie's icons through `QuestieFrame`'s icon events.
- **Ownership:** blob markers own their objective's patrols: the cluster the NPC spawns in, else the zone's marker. Zones only patrols reach get a route marker showing the patrolling NPC. Hovering an area hovers its marker, which highlights the routes it owns; hovering a route hovers the marker, which outlines its area.
- **Minimap:** both are layers of `MinimapCanvas`, whose `LAYER_ORDER` stacks paths one level above areas; hover follows that order, and areas don't hover.

## Verified in game

On Forever 1.60.1:
- The smoothing setting, live on the world map and the minimap, and on profile switches.
- The outline at a fractional UI scale, and line width while zooming.
- Hover: the NPC's tooltip and highlighted routes, moving from a line onto its icon, and Questie's icons and Blizzard's pins winning over lines.
- Map clicks and drags passing through lines, in and out of combat.
- The minimap: alignment with Questie's icons while walking and turning, north-up and rotating, at every zoom; the hole over the player arrow; and the shape mask captured through `Minimap:SetMaskTexture`.
- Hovering minimap paths: the highlight, and the tooltip listing all of the NPC's quests, also for NPCs whose minimap icons are out of HereBeDragons' range or faded out.

## Still to verify in game
- Sharp turns and open ends: that the 8-value `SetTexCoord` follows the corners `SetVertexOffset` moves, and that fills and caps meet their segments without seams.
- Hover on the inner edge of curves at the 0.75 default.
- Hovering a minimap icon highlights its NPC's paths on the minimap.
- Hovering minimap paths: moving onto a minimap icon, the shape cutoff on round and square minimaps, and hovering while walking and turning.
- The tracker's Show on Map flash.
- Visibility: hiding Questie's icons, turning off **Enable Minimap Icons**, and hiding one NPC's icon.
- The Map → Waypoints settings, live on both maps and on profile switches, and the colour pickers' opacity.
- Other clients (Era, Anniversary, Mists): the minimap's zoom-table path in HereBeDragons, and square and SexyMap minimaps, since SexyMap doesn't run on Forever.
- Frame cost during a smooth zoom in a dense zone.
