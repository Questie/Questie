# Waypoints: world map and minimap

NPC patrol-path lines on the world map and the minimap: the [implementation](#implementation), the research behind it, and what still needs checking in game.

**Where:**
- Worktree `~/projects/Questie-clones/waypoints`, branch `waypoints`.
- Based on `origin/master` (`772e558d1`), deliberately **not** on `blob`; see [Relationship to blob](#relationship-to-blob).
- Reference copies of everything cited below live in git-ignored [`.scratch/waypoints-reference/`](#reference-material).

## TL;DR

- **The outline texture is `WHITE32X32BLACKLINES`.** It is a 32×32 opaque image: rows 0–7 black, 8–23 white, 24–31 black, so ¼ outline, ½ tintable core, ¼ outline. Drawn with Blizzard's `DrawLine` and `CLAMPTOBLACKADDITIVE`, one texture is one outlined segment. Today Questie draws each segment as a frame holding two native `Line`s: the fill, plus a black border 2 px thicker.
- **Blob's `PolygonRenderer` draws its borders this way,** with `DrawLine`, `CLAMPTOBLACKADDITIVE`, `NEAREST` and no pixel snapping, using `WHITE8X8`. A waypoint renderer is the same primitive with a different texture. The pattern is about 10 lines; we copy it rather than depend on it.
- **Blob's staged `PolygonMinimap` is the template for minimap waypoints.** It does HBD-aligned projection with rotation, uses a container that moves only when walking, culls to the view, applies shape and player masks, and runs one update driver. We lift its generic parts into master-based code.
- **No prototype ever shipped working minimap waypoint lines.** QuestieDev-master drew them per segment through a modified HBD-Pins, without rotating the geometry or rescaling thickness on zoom. Later prototypes never drew them on the minimap.

## Implementation

Everything lives in `Modules/Map/Waypoints/`. The modules are loaded after `Modules\Map` in all six flavour TOCs, and each has an adjacent test.

| Module | Responsibility |
| --- | --- |
| `WaypointGeometry` | Pure geometry. Turns DB patrols into polylines in percentages and world yards: consecutive points closer than 0.5 yd merge, points the patrol runs straight on through are dropped, and points without a position split a patrol. Also rounds corners for drawing ([Smoothing](#smoothing)) and does the capsule hover test. |
| `WaypointRenderer` | One frame per path and one pooled texture per segment, with `Icons/waypoint-line-aa.png`: `WHITE32X32BLACKLINES`' proportions over 12 of its 16 rows, plus a two-row fade to transparent on each side, sampled `LINEAR` (`NEAREST` flickers more in game). Quads are 16/12 as wide as the line, so the fade grows outward and the line keeps its thickness. The previous `waypoint-line.blp`, now removed, had broken mipmaps (only its top rows survived below mip 0), so `TRILINEAR` drew just a thin dark edge. Each run's corners are rounded and the result trimmed first ([Smoothing](#smoothing)), then each texture is stretched over its segment's [mitered quad](#mitered-joins) with `SetVertexOffset`. Restyling redraws only for a new thickness; a new colour only tints. It can also draw the debug hover area. |
| `QuestieWaypoints` | The registry and Questie adapter. Each path is owned by its world map icon and shared on `icon.data.waypointPaths` for highlighting. Its world map visibility follows the owner's `hidden`/`faded`, and its minimap visibility follows the owner's `minimapTwin`. `SetSolo` covers the tracker flash. |
| `WaypointMap` | One `OnUpdate` driver on the world map canvas, with no data provider. It redraws after changes, map switches and canvas resizes. Thickness is divided by the canvas scale. Thickness is redrawn once a smooth zoom settles, or when it drifts more than 25%; meanwhile lines scale with the canvas. A path draws on its own map only; see [Neighbouring maps](#neighbouring-maps). Cursor hover opens the owner icon's tooltip, or only highlights the path when the owner icon isn't visible. Another icon's tooltip first ends a path hover (`EndHover`), so the path owner's `OnLeave` restores its icon tints. |
| `WaypointMinimap` | Blob's `PolygonMinimap` adapted for polylines: HBD-aligned projection with rotation, shape and player masks, and clipping. It draws only segments within 2 view radii of the projection origin; a closed patrol cut there elsewhere stays joined where it returns to its start. Walking moves just the container until the player drifts half a radius; turning a rotating minimap redraws only those nearby segments. It has no hover. |

Integration:
- `QuestieMap:DrawWaypoints` keeps its signature and calls `QuestieWaypoints.Add`. `DrawWorldIcon`/`DrawManualIcon` link `icon.minimapTwin`.
- `QuestieFrame` reports unload, fake hide/show and fade to the registry. `MapIconTooltip` highlights through it.
- `TrackerUtils` flashes use `SetSolo`.
- HBD-Pins gains `GetMinimapView()`.
- The old line frames, the HBD 0–100 registry trick, `DrawLineIcon`, and the empty zone colour-override tables are gone. As a side effect, the fade bug (`global.iconFadeLevel`) is fixed: fade now uses `profile.iconFadeLevel` through frame alpha.

Chosen defaults for the open questions; tell me to change any of them:
- **Thickness on zoom:** constant on-screen width. Line 4, hover reach 3 map UI units (one past the line's edge), tuned in game.
- **Minimap scope:** every NPC with waypoints (objectives, quest givers, turn-ins, manual notes), following each icon's minimap twin. That means **Enable Minimap Icons** and hiding apply. No new option.
- **Smoothing:** corners are rounded, passing each patrol point at most half a half-width away (1 unit on the 4-unit line), so the true path stays under the line. Turns past about 80° stay sharp, as the line cannot follow a tighter curve. The result is then trimmed of points within a quarter unit of the line kept around them. See [Smoothing](#smoothing).
- **Loop closing:** none. A patrol draws open unless its data ends on its first point. Closing it ourselves needs data we don't have, so it waits for cMaNGOS:
  - **Loop or back-and-forth:** the data doesn't say whether the NPC loops or walks back along its route. A wrong closing line shows a route it never takes.
  - **Return route:** a looping NPC may not walk straight from its last point to its first.
  - **Zone pieces:** a zone's sub-path may be only the part of a patrol inside that zone, so its ends may not be the patrol's ends.
  - **Legacy:** never closed loops in practice. Its closing segment needed ends 0.05–0.2 yd apart, and its spline samples never got that close.
- **Overlapping paths:** the nearest path to the cursor wins. There are no combined tooltips.
- **Duplicate routes:** an NPC with several quests has an icon per quest, and each would draw his patrol again. Courier Hammerfall's Ironforge route drew three times and stacked to nearly opaque. `DrawWaypoints` takes whose waypoints they are, as Questie's tooltip keys (`"m_<npcId>"`, `"o_<objectId>"`). Each path's `route` is that key, its area and its part of the patrol, and each route draws once:
  - **World map:** the hovered copy, otherwise the most visible one. A hovered copy takes its route over on the next frame, without a redraw.
  - **Minimap:** the most visible copy.
- **Self-overlap:** a patrol that crosses or retraces itself still draws darker there; it marks where the NPC walks twice. Frame buffers can avoid that, but were tried and rejected: see [docs/frame-buffer-group-opacity.md](docs/frame-buffer-group-opacity.md).
- **Debug view:** `/run QuestieLoader:ImportModule("WaypointMap").debugHover = true`, then change map.
- **Smoothing setting:** **Advanced → Developer Options → Waypoint smoothing** (`profile.waypointSmoothing`, 0–2, default 0.5) changes the tolerance live on the world map and the minimap through `WaypointRenderer.RedrawAll`; 0 draws sharp corners. It sits with the developer options because players are not expected to change it.

Behaviour changes worth naming in the PR:
- **Clicks:** lines are click-through. Clicking a line no longer forwards to its icon (map switch, Ctrl-click TomTom, Shift-click hide).
- **Tracker flash:** Show on Map shows only the flashed quest's paths. Manual/townsfolk paths hide too during the flash; the old code left them.

Not verified in game. To check:
- The outline look at thickness 4, on the world map and the minimap, at normal and fractional UI scales.
- Line width while zooming, and frame cost during smooth zoom with dense zones.
- Hover over bare map versus Questie icons and Blizzard pins; moving from a path onto its icon; map clicks and dragging passing through paths, in and out of combat.
- Minimap alignment with Questie's icons while walking and turning, with `rotateMinimap` on and off; round, square and SexyMap minimaps; the hole over the player arrow.
- The tracker's Show on Map flash.

## Sources examined

| Generation | Location | Waypoint relevance |
| --- | --- | --- |
| Current | this branch (`origin/master`): `Modules/FramePool`, `Modules/Map` | Live world-map lines; no minimap lines. |
| Blob branch | `blob` in `Questie-Forever`; staged minimap work copied to `.scratch/waypoints-reference/minimap-template/` | Polygon renderer, cursor-driven hover, minimap layer. |
| Gen 1 (2021–22) | `/mnt/w/QuestieBackup/QuestieDev-master/`; waypoint files copied to `.scratch/waypoints-reference/gen1-questiedev/` | The outlined texture, a canvas data provider, and **masked minimap lines** via a modified HBD-Pins (`AvailableWaypoints.lua`). |
| Gen 1 port | `C:\…\AddOns\QuestLite\Map\Waypoints\` | Near-copy of Gen 1. Nothing calls it (`Available.lua:223` is a TODO), and its texture path points to a folder QuestLite does not have. Nothing new. |
| Gen 2 | `/mnt/w/QuestieBackup/MapRefactor-ModulesNew-EventBus-Map-Quest-Blob/` (identical to `Questie/ModulesNew`); hover files copied to `.scratch/waypoints-reference/gen2-maprefactor/` | Same line technique, Catmull-Rom→RDP preprocessing, a thickness tween on hover, the corner-rectangle hover with debug dots, and a custom minimap canvas. **The minimap waypoint pool is commented out.** It also depends on an undefined `LineMixin`, and its minimap shape logic always yields square. |
| QuestieMap addon | `C:\…\AddOns\QuestieMap\` | A pin and cluster scaffold on demo data. No lines, no minimap, and its mask assets are never referenced. The only reusable ideas are injecting pools into `canvas.pinPools` and giving each pin type its own frame-level band. |

## The outlined-line technique

```lua
texture:SetTexture(path .. "WHITE32X32BLACKLINES", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "NEAREST")
texture:SetSnapToPixelGrid(false)
texture:SetTexelSnappingBias(0)
texture:SetVertexColor(r, g, b, a)                 -- tints only the white core
DrawLine(texture, frame, sx, sy, ex, ey, thickness, 1, "TOPLEFT")
```

- **How it works:** `DrawLine`, a client global, sets a bounding-box quad and texcoords that run outside 0–1. `CLAMPTOBLACKADDITIVE` makes everything outside the strip transparent. The texture's vertical axis spans the line's thickness, which is why its black rows become the edges.
- **Proportions:** thickness *T* gives a black edge of *T*/4 on each side and a coloured core of *T*/2. At small *T*, `NEAREST` sampling can make the edges uneven. If 4–5 px looks wrong in game, a 64-row texture with a different ratio is a cheap tweak.
- **Short segments:** legacy code skipped closing segments under 0.05 yards because of "TexCoord errors". `DrawLine` divides by the length, so it produces extreme texcoords when length ≪ thickness. Geometry should merge near-duplicate points before drawing.
- **Assets:** `WHITE32X32BLACKLINES.blp` (2,580 B) and `.png`, plus a sibling `WHITE32X32NOBORDERS`, are in `.scratch/waypoints-reference/textures/`. Its BLP has broken mipmaps, so `Icons/` ships the generated `waypoint-line-aa.png` instead (see [Implementation](#implementation)).

### Mitered joins

The implementation goes past `DrawLine`, which can only place rotated rectangles. Rectangles leave a wedge-shaped gap on the outer side of every turn and overlap on the inner side. In the overlap, one segment's black edge band crosses the next segment's core, and the half-transparent lines render darker.

Instead, consecutive segments meet on the line that halves their angle:

```text
n1, n2 = unit normals of the incoming and outgoing segment
m      = normalize(n1 + n2)               -- the bisector
len    = halfWidth / cos(turn / 2)        -- |n1 + n2| = 2 cos(turn / 2)
left   = P + m * len,  right = P - m * len
```

Both segments end at those two points. The outer edges extend to meet and the inner edges shorten to meet, so there is no gap and no overlap.

- **How it is drawn:** each segment is one texture. It is anchored to its quad's bounding box, and `SetVertexOffset` moves each vertex onto a corner.
- **Why the texture survives:** the image is constant along its length and only changes across the width. Whichever diagonal the client splits the quad on, both triangles keep the black rows on the two long edges, at an even width, and they meet cleanly on the cut line.
- **Sharp turns:** the outer corner is shared on the bisector, within `MITER_LIMIT` (2) half-widths of the point. Turns up to 120° are exact. Sharper ones taper instead of spiking; the tapered outer edge narrows along its whole segment.
- **Short segments:** each inner corner stays on its own segment's inner edge, pulled back to where the two inner edges cross. It is pulled back at most half the shorter adjacent segment. Past that, the two segments overlap slightly on the inside instead of sharing the corner.
- **Why convexity matters:** the client splits every quad into two triangles along a fixed diagonal, and a concave quad would draw outside its outline. With the corners placed as above every quad is convex. An earlier version slid the clamped inner corner along the bisector, which made about 4 in 10 quads concave at tight joins. A fuzz of 738k quads from random polylines (short segments, sharp turns, closed loops) found none concave or non-finite. Repeated points are skipped.
- **Edge cases:** turning back on itself (within 0.1° of 180°) keeps square ends. A patrol that returns to its first point joins there too.
- **Hover:** unchanged. The 3-unit capsule leaves out the outer tips of turns sharper than about 96°, which reach up to 4 units from the point. They are small, and hovering the line next to them still works.
- **Verified client APIs:** `Texture:SetVertexOffset` and the `UPPER_LEFT_VERTEX` constants (1–4) exist on Era, Anniversary, Mists and Forever, checked against Blizzard's UI source. Blob's polygon fills already use them in game. Offsets point y up like `SetPoint`, as Blizzard's own use in `Blizzard_ArtifactUI/Blizzard_ArtifactPerks.lua` (`live` branch) shows: it nudges upper vertices by −1 and lower vertices by +1 towards the inside.

## Smoothing

Patrol points are where the NPC walks, and the data is the best guess of its route, so smoothing is cosmetic and must stay close to it. **The rule: the true path always stays under the drawn line.**

Each corner P becomes a quadratic Bézier curve. It starts on the incoming segment and ends on the outgoing one, with P as its control point, so it is tangent to both and the path turns without a kink. With unit directions *u1* in and *u2* out, and tolerance ε:

```text
bend = |u2 - u1|                         -- 2 sin(turn / 2)
cut  = min(4ε / bend, L_in / 2, L_out / 2) -- how far back along each segment the curve starts
T1 = P - cut·u1,  T2 = P + cut·u2
B(s) = (1-s)²·T1 + 2s(1-s)·P + s²·T2
```

`B(½) = (T1 + 2P + T2) / 4`, so the curve passes `cut · bend / 4` from P: exactly ε, or less where short segments cap the curve. That one tolerance gives gentle bends long curves, where a polyline looks most faceted, and sharper turns tighter ones. At ε = 1 the curve starts 15 units back at a 15° bend (often capped), 7.7 at 30° and 4 at 60°.

The curve is tightest in its middle, with radius `cut · cos²(turn/2) / sin(turn/2)`, which is `2ε · cot²(turn/2)` uncapped. A line cannot follow a curve tighter than its half width: its inner edge folds over itself, and the pieces' quads overlap and draw darker at alpha 0.5. Such corners stay sharp, and the miter join draws them cleanly. The check uses the quads' half width, fade included (`2 · 16/12`), so on the 4-unit line turns up to about 80° are rounded. A reviewer's probe measured the double-drawn area at a corner: up to 17 square units at 140° before this rule, none at turns of 30–150° and any setting value after it.

Rules (`WaypointGeometry.Smooth`, called by `WaypointRenderer` before mitering):
- **Screen units.** ε is the `waypointSmoothing` setting in half line widths (0.5 by default, so 1 unit on the 4-unit line). Yards would be invisible zoomed out and visibly off the path zoomed in. QuestieDB's own simplification already moves points about 2–4 yd on a typical zone (see below), so a unit or so zoomed out costs no real accuracy.
- **Ends stay exact:** open ends, splits where data is missing, and the minimap's culling cuts. Legacy cut back every patrol's ends.
- **Closed stays closed.** The corner where a patrol returns to its start is rounded too; drawing starts where its curve ends and finishes with that curve.
- **No overlap between curves:** each takes at most half of each segment. Curves meeting in a segment's middle share that point; points closer than a thousandth of the half width merge, so rounding never leaves a sliver segment.
- **Hidden corners stay sharp.** A corner whose curve would start less than half the quad half width back stays sharp, since the join already hides it.
- **Fewest pieces.** With n equal parameter steps the chords stray at most `deviation / n²` from the curve. A curve takes the fewest even number of pieces, at most 8, that keeps that within an eighth of the half width. Even, so its middle, nearest P, is always drawn and the bound on ε holds for the drawn chords. At the default tolerance that is always 2.
- **Hover stays on the raw points.** With trimming, the drawn line's centre is at most 1.25 units off them at the default setting, so the 3-unit hover reach covers all of the line but a sliver of a curve's inner edge.

**Trimming** (`WaypointGeometry.Trim`). Smoothing adds curve points that are often too small to see, most of all zoomed out. Ramer-Douglas-Peucker then drops every point within δ of the segment between the points kept around it. δ is `WaypointRenderer.TRIMMING` half line widths (1/8, so 0.25 units on the 4-unit line), the same order as the curves' own chord error. The rules that matter:
- **Distance, not angle.** Small turns would each pass an angle test and add up, collapsing a slow arc; a distance bound holds however many points go. `_DropStraightPoints` gets away with an angle because QuestieDB's split points are exactly collinear, and it compares with the last point kept.
- **To the segment, not its line.** A patrol's turning point, where it walks back along itself, lies on the line through its neighbours but past their segment, so it stays.
- **Ends stay**, so closed patrols stay closed and their seams keep their curves.
- **Only after smoothing.** Trimming the raw lines at 0.25 removes 0–9 of 11,448 segments: QuestieDB's simplification already left about 1 unit between them.
- **Error budget:** ε + δ = 1.25 units, still under the line's 2-unit half width.

**Data catch.** QuestieDB (`src/derived/waypoints.lua`) simplifies patrols with Ramer-Douglas-Peucker at 0.1 map-percent, then splits segments longer than 1.5% (0.75% in capitals) into evenly spaced points, which line frames once needed for their square clickable area. Those points are collinear and would cap every curve at half a short piece, so `BuildPolylines` drops points the patrol runs straight on through (within 0.1°), compared with the last point it kept, so a slow arc keeps its shape. Removing the split in QuestieDB is a later cleanup there.

**Cost.** Over Classic's 579 patrols, at canvas scales from 0.5 (zoomed out) to 4 (zoomed in):

| | Segments |
| --- | --- |
| Stored | 18,690 |
| After dropping straight points | 11,448 |
| Smoothed | 22,304–30,257 |
| Smoothed and trimmed | 14,337–29,148 (19,372 at scale 1) |

Zoomed in, curves are big enough to see and trimming rightly keeps them. A first version split curves by length into up to 8 pieces, 3.1–4.4× the stored count.

Geometry for every Classic patrol at once, in plain Lua 5.1: 21 ms for the old sharp quads, 86 ms smoothed and trimmed (Smooth 29, Trim 37, Quads 32). Trim inlines `SegmentDistanceSq`, which took it from 56 ms. The world map pays this once per zoom or map change, for the paths on that map. The rotating minimap pays it every frame while turning, for the paths within reach.

**Measured in game** (Forever, Ironforge, rotating minimap, one 31-segment patrol in reach, a 360° keyboard turn at about 48 fps), Questie's time per tick from `C_AddOnProfiler`:

| | Turning | Standing still |
| --- | --- | --- |
| Minimap lines shown | 1.70 ms | 0.14 ms |
| Minimap lines hidden | 0.38 ms | 0.10 ms |

The lines' ~1.3 ms per turning tick splits into Smooth 0.22, Trim 0.18 and Quads 0.28 ms; about 0.36 ms of client texture calls (4.9 µs per segment: 1.7 for the anchors, 2.4 for the four vertex offsets); and about 0.5 ms of projection, renderer Lua and garbage collection. The rest of turning is HereBeDragons moving Questie's minimap icons.

**Decided:** good enough, since few players use a rotating minimap. If it ever matters, two steps would cut it to about a third: cache each path's quads per minimap zoom level, unrotated, and only rotate their corners while turning; and anchor each texture once, moving only its vertex offsets (check in game that the client neither culls nor mis-clips such a texture).

Joins whose miter pull-back is capped by a short segment, so the quads overlap a little on the inside, already exist in the stored data: 1,407 at scale 1. Smoothing alone raised that to 2,427, by shortening the segments next to sharp corners; with trimming it is 1,561.

**Not used:**
- **Catmull-Rom (legacy):** passes through every point but bulges between them, with no bound on how far; uneven spacing overshoots most. Legacy also ran it in stretched map-percent units, sampled 9 points per segment and trimmed the ends.
- **Chaikin corner cutting:** cuts a fixed fraction of each segment, so a sharp turn between long segments loses a large chunk. Clamping it becomes the approach above.

## Current implementation (what we replace)

Line numbers refer to this branch (`origin/master`).

**Data.** `QuestieDB.QueryNPCSingle(npcId, "waypoints")` returns `table<AreaId, CoordPair[][]>`: per zone, a list of sub-paths in 0–100 percentages. Callers:
- Objective spawns: `QuestieQuestPrivates.lua:105-113`, where waypoints are off for rank-2 rares and blacklisted NPCs; drawn by `_DrawObjectiveWaypoints` in `QuestieQuest.lua:1314-1344`.
- Available NPCs: `AvailableQuests.lua:834`.
- Finishers: `QuestFinisher.lua:146`.
- Manual notes: `QuestieMap.lua:445, 511`.

**Drawing.** `QuestieMap:DrawWaypoints` (`QuestieMap.lua:739`) calls `QuestieFramePool:CreateWaypoints` and `CreateLine` (`QuestieFramePool.lua:127`, `:159`):
- **Frames:** each segment gets a pooled `Button` sized to the segment's bounding box. It is parented to the world-map canvas at level 2015 (`:184`) and holds two `CreateLine` regions. The fill is at `OVERLAY -5`; a black border at `OVERLAY -6` is 2 px thicker at half alpha.
- **Zoom:** geometry is baked in canvas pixels at creation. Thickness 1.5 is in canvas units, so lines get thicker as the map zooms in. There is no `OnCanvasScaleChanged` handling.
- **Colour:** `{1, 0.72, 0, 0.5}`, or `{1, 0.2, 0, 0.7}` for hostile NPCs. Hovering recolours to `{0.93, 0.46, 0.13, 0.8}` (`MapIconTooltip.lua:108-110`).
- **Mouse and lifetime:** line `OnEnter`/`OnLeave`/`OnClick` forward to the owning icon. Lines unload with their icon (`QuestieFrame.lua:387`).

**The HBD trick (load-bearing).** `DrawLineIcon` (`QuestieMap.lua:517-530`) registers every line frame with `HBDPins:AddWorldMapIconMap`. It passes the path's first point in **0–100** units, but HBD expects 0–1:
- HBD's `GetZoneCoordinatesFromWorldInstance` rejects the out-of-bounds result. So HBD never acquires a wrapper pin and never re-anchors the frame.
- Questie's modified `HandlePin` (`HereBeDragons-Pins-2.0.lua:415-426`) still shows and hides `SHOW_CURRENT` pins.

So HBD is used purely as a "show on the owning map only" registry. That works, but by accident, and lines never appear on adjacent or parent maps.

**Known defects:**
- **Fade:** `_QuestieFrame.FadeOut` sets line alpha from `Questie.db.global.iconFadeLevel` (`QuestieFrame.lua:418`), which has no default; only `profile.iconFadeLevel` exists. Faded icons therefore likely get *opaque* lines, and the border line is never faded.
- **Hit area:** a line frame's mouse area is its whole bounding rectangle. It sits above Blizzard pins and steals their hover and clicks (the blob `BLOB-PARITY.md` follow-up). Long diagonal segments make large invisible hit areas.
- **Cost:** two regions and one frame per segment, so dense patrols mean hundreds of frames.
- **Settings:** no waypoint settings exist (no toggle, width or colour). Any new option needs a default and a migration.

**Tests on master.** Waypoint calls are covered in `QuestFinisher.test.lua`, `QuestieFrame.test.lua` and `MapIconTooltip.test.lua`. There are no geometry, HBD-registration, fade or hover tests, and no `QuestieFramePool.test.lua`.

## Minimap template: blob's `PolygonMinimap`

Copy in `.scratch/waypoints-reference/minimap-template/PolygonMinimap.lua`, staged-only on `blob`:
- **Coordinates:** percent outlines are converted to HBD world yards once per vertex, in a weak cache.
- **Projection:** relative to a fixed origin, into one container. Walking only moves the container. Zoom, size, instance and (when rotating) facing changes reproject the visible shapes.
- **Radius:** from `HBDPins:GetMinimapView()`, a small HBD-Pins addition (`HereBeDragons-Pins-GetMinimapView.staged.diff`). It uses `C_Minimap.GetViewRadius()` on Forever and HBD's zoom table elsewhere.
- **Culling:** to 1.5 view radii.
- **Clipping and masks:** the root clips its children. Every texture gets two masks:
  - Shape: from a post-hooked `Minimap:SetMaskTexture`, then `GetMinimapShape()`, then a round fallback.
  - Player: the 38 px `polygon-minimap-player-mask.tga`.
- **Driver:** one `OnUpdate` driver, hidden while it has no shapes. Errors stop the layer, not the addon.
- **Renderer masks:** blob's `PolygonRenderer.New(canvas, hoverInput, maskTextures)` applies the masks to every texture it creates (`PolygonRenderer-masks.staged.diff`).

A polyline is an open outline with no fill, so minimap waypoints need the same projection, culling, masks and driver.

## Proposed direction

Mirror blob's `Polygon/` split: pure geometry, a native-primitive renderer, and a thin Questie adapter. Waypoints stay on by default in every objective style, independent of polygon mode.

1. **Geometry (pure, tested).** Turn DB paths into per-map polylines with explicit units (percent plus world yards).
   - Merge points closer than a yard tolerance and drop zero-length segments.
   - Keep loops open unless the data closes them; see **Loop closing** under [Implementation](#implementation).
   - Round corners within a tolerance tied to the line width, not with a spline through the points; see [Smoothing](#smoothing).
2. **Renderer.** One texture per segment with `WHITE32X32BLACKLINES`, mitered at joins (implemented with `SetVertexOffset` rather than `DrawLine`; see [Mitered joins](#mitered-joins)).
   - Pool textures, not frames: one container frame per path, or per map.
   - **No mouse input.** Hover is computed from the cursor; see [Line hover](#line-hover).
   - Thickness is divided by the canvas scale on zoom, giving a constant screen width as in the legacy code. Redraw happens only on scale change.
3. **World map.** Drop the HBD registry trick and draw through a map data provider.
   - Lines show on the owning map only. Drawing them on neighbouring maps was built and removed; see [Neighbouring maps](#neighbouring-maps).
   - The frame level sits below Questie icons. Above or below blob's polygon areas is decided when the two meet.
   - Fade uses `profile.iconFadeLevel`.
4. **Minimap.** A master-based minimap path layer built from `PolygonMinimap`'s generic parts: projection, culling, masks and driver.
   - HBD-Pins gets `GetMinimapView()`, duplicated from the staged blob diff. More HBD helpers may be added the same way when useful, and reconciled with blob afterwards.
   - Keep the layer generic enough that blob's polygon areas can later use it instead of owning their own copy.
5. **Adapter.** Paths follow their owning icon's lifecycle and visibility on each surface. Minimap paths obey **Enable Minimap Icons**, hiding and fade.

## Line hover

Hovering a path keeps today's meaning: it highlights the path and shows its NPC's tooltip. Hover is world map only; nothing on the minimap takes input, matching minimap areas.

### The Gen 2 prototype

Original in `/mnt/w/QuestieBackup/MapRefactor-ModulesNew-EventBus-Map-Quest-Blob/`, copied to `.scratch/waypoints-reference/gen2-maprefactor/`:

- **Corners:** `Map/Processor/RelationsProcessor.lua:113-135`. Each segment becomes a rectangle: both endpoints are offset along the perpendicular by `(0.002 / 4) * thickness` normalised map units, stored as four `lineCornerPoints`.
- **Test:** `Map/Pins/Map/WaypointPin.lua:248-262` `insideLine`, the same odd/even ray-crossing test as blob `insidePolygon`.
- **Trigger:**
  - `WaypointPin:OnMouseEnter` on the segment's frame starts a 0.1 s ticker. It reads `ScrollContainer:GetNormalizedCursorPosition()` and rechecks only when the cursor moves.
  - Each check enumerates every waypoint pin, because overlapping frames swallow each other's enter/leave events. It raises per-segment `OnMouseEnterLine`/`OnMouseLeaveLine` calls.
  - The tooltip is rewritten only on change, and pressing or releasing Shift refreshes it.
- **Debug dots:** `Map/Renderers/RelationRenderers.lua:120-147` `DrawDebugDot` places a 1–2 px `circlemask.blp` pin. `DrawWaypoint` (`:157-178`) puts one on every rectangle corner, with a random colour per segment and alternating size and frame level for even and odd waypoint ids. It is disabled with `if true == false`.

Problems seen in game:
- **Short segments:** the corners nearly coincide, so hover is patchy (also a TODO in the code).
- **Sharp joins:** the outer side of a sharp turn is a wedge that no rectangle covers. This dead corner flickers as the cursor crosses it.
- **Frame-triggered:** hover only started after entering the segment's frame. Tiny segments meant a target of about 1 px.

From reading the code:
- **Map units:** the band is in normalised map units, so it does not match a line drawn at a constant screen width.
- **Non-square canvas:** the canvas is not square, so the band's width depends on the segment's direction.
- **Per-segment state:** hover state is tracked per segment, so moving along a path toggles leave and enter at every joint.

### Target: the fattened line

The hover shape is the path fattened by radius *r* in every direction. That is the union of capsules around its segments, so the test is simply: **distance from the cursor to the nearest segment ≤ r**. This fixes each problem above:
- Joins of any angle are round, so there is no dead wedge.
- A zero-length or very short segment becomes a disc of radius *r*.
- Distances are measured in canvas pixels, so the band does not depend on direction or map aspect.
- Hover state is **per path**, so moving between segments toggles nothing.

```lua
-- Squared distance from (px, py) to the segment (sx, sy)-(ex, ey), all in canvas pixels.
local function _SegmentDistanceSq(px, py, sx, sy, ex, ey)
    local dx, dy = ex - sx, ey - sy
    local lengthSq = dx * dx + dy * dy
    local t = 0
    if lengthSq > 0 then
        t = math.max(0, math.min(1, ((px - sx) * dx + (py - sy) * dy) / lengthSq))
    end
    local qx, qy = sx + t * dx - px, sy + t * dy - py
    return qx * qx + qy * qy
end
```

**Sizing.** *r* is set in screen pixels and is deliberately larger than the drawn line: a generous target is better UX. Started at `max(thickness / 2 + 4, 6)` screen px; tuned in game to `thickness / 2 + 1` (3 at thickness 4). Like the line thickness, it is converted to canvas units by dividing by the canvas scale.

**Driver.** There are no mouse-enabled line frames, which removes the 1 px trigger problem entirely. Use the pattern from blob's polygon direct hover (`minimap-template/README.md`, "Direct polygon hover"):
- One driver runs while paths are shown. It does a full check only when the cursor's canvas position changes, which also covers pan and zoom under a still cursor.
- Secret, non-finite or off-canvas cursor values clear the hover.
- An "is the map itself under the cursor" gate lets Questie icons, Blizzard pins and other UI on top win.
- Lines are click-through, and hover never consumes clicks.

**Cost.** Each path's bounding box, expanded by *r*, rejects most paths. The remaining ones get a per-segment squared-distance test with no `sqrt`, and only when the cursor moves.

**Overlaps.** The result is a set of hovered paths. Overlapping paths all hit, as polygons do. Gen 2 combined their tooltips (`WRITE_WAYPOINT_TOOLTIP`), which is worth keeping.

**Only if boundary flicker remains:** add hysteresis by leaving at *r* + 2 px.

### Debug view

This replaces the corner dots, behind a development flag that is off by default:
- Each segment's band is drawn as a translucent `WHITE8X8` `DrawLine` of thickness 2*r* beneath the real line.
- A circle of diameter 2*r* (circle mask) sits on every vertex.

Rectangles plus circles are exactly the capsule union, so the overlay shows the true hover shape, including joins and short segments.

## Neighbouring maps

**Removed for now.** A path draws on its own map only, like the old line code. Drawing paths on neighbouring maps was built, then taken out to revisit later.

- **Why it was removed:**
  - On Forever, the redrawn Mulgore artwork draws its eastern edge about 100 yards past the real border, so Barrens paths projected onto Mulgore looked pulled onto its drawn mountains.
  - Fitting the artwork would make paths disagree with Blizzard's player arrow, and icons from neighbouring zones would have to move with them. See [docs/forever-mulgore-map-art.md](docs/forever-mulgore-map-art.md).
  - Leaving the feature out kept the code simpler than either option.
- **How it worked,** for when it returns. The code is in commits `8760bc139` (`WaypointGeometry.Project`, `CanProject`, `CAPITAL_MAPS`) and `6318612dd` (`WaypointMap.PointsOnMap`).
  - **Projection:** each path's world-yard points went through HBD onto the destination map. It drew there only when its projected bounds overlapped that map. Vertices outside 0–100 stayed intact for the canvas to clip, and results were cached per path and destination map.
  - **Destinations:** Zone to Zone only. Dungeon floors and micro maps such as caves share world space with the maps around them at other heights, and continents were never drawn on.
  - **Capitals:** excluded in both directions: 1453–1458, plus 1947, 1954, 1955, 125 and 126 for later clients. City paths are long and dense, and a city is a small corner of its zone's map, so projecting them only cluttered.

## Decisions

Decided:
- **Base:** `origin/master`, not `blob`. Code may be duplicated into HBD where useful and reconciled with blob later.
- **Clicks:** lines are click-through. They take no mouse input, and clicks over them reach the map. Paths have no click handling.
- **Neighbouring maps:** not for now. Paths draw on their own map only; see [Neighbouring maps](#neighbouring-maps).

Defaults chosen during implementation, pending your review: see [Implementation](#implementation).

## Relationship to blob

Waypoints are on by default for every player; blob is opt-in and long-running. So this branch does not wait for blob. **The dependency is inverted:** the waypoint branch owns the generic minimap layer and the HBD `GetMinimapView` addition, and blob's `PolygonMinimap` later adopts them for its filled areas.

When the two meet, these blob touch points move onto the new waypoint API:
- **Ownership:** `QuestiePolygon.OwnWaypointMarker`, `IsCurrentObjective` and the `waypointWork` tokens returned by `UpdateObjective`. Polygon mode re-attaches lines to cluster markers.
- **Hover exception:** `QuestieFramePool.IsLineFrame` and the polygon hover's "waypoint line counts as bare map" rule. Both become unnecessary once lines take no mouse input.
- **Combat handling:** `c2f2a2e97` (deferring line mouse-motion setup in combat). Moot without mouse-enabled lines.
- **Frame level:** the `BLOB-PARITY.md` follow-up on waypoint frame levels and hit areas.

## Reference material

`.scratch/waypoints-reference/` is git-ignored through the shared `.git/info/exclude`.

| Folder | Contents |
| --- | --- |
| `textures/` | `WHITE32X32BLACKLINES.{blp,png}`, `WHITE32X32NOBORDERS.{blp,png}`, legacy `playerMask.tga`, `circlemask.blp`. |
| `gen1-questiedev/` | `WaypointFramepool.lua`, `WaypointMap.lua`, `WaypointPin.lua`, `AvailableWaypoints.lua` (masked minimap lines), `MinimapHandler.lua`, `MixinUtil.lua` (a `DrawLine` reference copy), the legacy-modified HBD-Pins, and the blob package's `LEGACY-BLOB-ANALYSIS.md`. |
| `gen2-maprefactor/` | `WaypointPin.lua` (hover ticker and `insideLine`), `RelationsProcessor.lua` (corner rectangles), `RelationRenderers.lua` (debug dots), `FramePoolWaypoint.lua`, `WaypointAnimationHelper.lua`. |
| `minimap-template/` | Blob's staged `PolygonMinimap.lua` and its test, `PolygonRenderer.lua`, `QuestiePolygon.lua`, `README.md`, `BLOB-PARITY.md`, `polygon-minimap-player-mask.tga`, and the staged diffs for HBD `GetMinimapView` and the renderer masks. |

The full legacy blob package stays on `blob` under `Blob/docs/legacy-questie-blobs/`, and the original backups under `/mnt/w/QuestieBackup/`.

## Legacy behaviour worth remembering

- Gen 1 minimap lines registered **each segment** with HBD at its midpoint and scaled it with fixed indoor/outdoor zoom tables. The geometry did not rotate with `rotateMinimap`, and thickness was not rescaled on zoom. Do not port this.
- Gen 2's hover thickness tween ran one `C_Timer` ticker per line. Its hit test is covered in [Line hover](#line-hover).
- Gen 1 and Gen 2 used today's colours: `{1, 0.72, 0, 0.5}` normal, `{0.93, 0.46, 0.13, 0.8}` hover. Thickness was 4–5 with the outlined texture, versus 1.5 plus a border today.
