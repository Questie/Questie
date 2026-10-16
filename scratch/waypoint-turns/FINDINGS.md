# Sharp patrol turns: findings and work so far

Everything from the session on sharp waypoint turns, so it can move to another computer. The code change is uncommitted; `sharp-turn-joins.patch` carries it.

## Moving this to another computer

1. Check out branch `waypoints` at commit `7c1e28bd888608283cae9e2ec715faa9d266c620` ("docs(waypoints): record the minimap path hover checks").
2. Copy this whole `scratch/waypoint-turns/` folder into the repo root.
3. Apply the code change: `git apply scratch/waypoint-turns/sharp-turn-joins.patch`.
4. Copy the new texture, which the patch can't carry: `cp scratch/waypoint-turns/waypoint-cap-aa.png Icons/waypoint-cap-aa.png`. The same file is in `textures/`.
5. Check: `busted -p ".test.lua" Modules/Map/Waypoints` (94 successes) and `luacheck -q -- Modules`.

The patch covers `Modules/Map/Waypoints/WaypointGeometry.lua`, `WaypointGeometry.test.lua`, `WaypointRenderer.lua`, `WaypointRenderer.test.lua` and `docs/waypoints.md`. It leaves out `.types/Annotations/Core/Data/Wiki.lua`, which was already modified before this work and isn't part of it.

## Files in this folder

| File | What it is |
| --- | --- |
| `FINDINGS.md` | This file. |
| `sharp-turn-joins.patch` | The implemented change (option J), against `7c1e28bd8`. |
| `waypoint-cap-aa.png` | The new cap texture, for `Icons/`. |
| `turns.svg`, `turns.png` | The comparison sheet: one row per join option, one column per turn angle. |
| `turns_svg.lua` | Draws the sheet. From the repo root: `lua scratch/waypoint-turns/turns_svg.lua . scratch/waypoint-turns/turns.svg`, then `rsvg-convert` for the PNG. It loads `WaypointGeometry.lua` from the working tree, and the "Before" rows from commit `7c1e28bd8` through `git show`. |
| `turn_quads.lua` | Prints the outline quads of a few turns. From the repo root: `lua scratch/waypoint-turns/turn_quads.lua`. |
| `textures/` | Moved: the SVG sources, `build.sh` and `preview.py` now live in `Icons/originals/waypoints/`, and the textures in `Icons/waypoints/`. |

## How the waypoint code fits together

All in `Modules/Map/Waypoints/`; `docs/waypoints.md` has the full write-up.

- **Data:** `QuestieDB.QueryNPCSingle(npcId, "waypoints")` gives `table<AreaId, CoordPair[][]>`, patrols in map percent. `QuestieMap:DrawWaypoints` forwards objective, available-quest, finisher and manual-note NPCs to `QuestieWaypoints.Add`.
- **`QuestieWaypoints`:** the registry and policy. Each path has an `owner` (world map icon), the owner's `data`, a `route` key (`"<entity>:<areaId>:<i>"`) and `hostile`. `WorldMapAlpha` and `MinimapAlpha` decide visibility and fade (the minimap follows the icon's `minimapTwin`). `Color` picks highlight, hostile or normal color. Copies of one route, such as one per quest of an NPC, draw once: the highlighted copy, else the most visible one. Changes invalidate both maps, which redraw on their next `OnUpdate`.
- **`WaypointGeometry`:** pure geometry. `BuildPolylines` (percent and world yards), `Smooth` (quadratic Bezier corners within a tolerance in half line widths), `Trim` (Ramer-Douglas-Peucker on the smoothed points), `Quads` (mitered outline quads), `Nearest` (capsule hover test).
- **`WaypointRenderer`:** one frame per path and one pooled texture per segment quad, stretched with `SetVertexOffset`. Restyling redraws only for a new thickness; a new color only tints.
- **`WaypointMap`:** one driver on the world map canvas; keeps line width constant on screen while zooming.
- **`WaypointMinimap`:** projects paths like HereBeDragons-Pins places icons, with rotation, culling, a shape mask and a hole over the player arrow.
- **`WaypointHover`:** one hovered path across both maps; opens the NPC's tooltip and highlights its paths.

## The problem: the `>` at turnarounds

Where a patrol turns back, the line narrowed into a long point like `>` before the turn.

**Cause** (`_Join` in `WaypointGeometry.lua`, before the change):
- **One shared outer corner.** A miter puts the outer corner `halfWidth / cos(turn / 2)` out along the bisector, which goes to infinity near 180 degrees. `MITER_LIMIT = 2` clamped it to 2 half widths, but both segments' outer edges still ran into that one point, so the line tapered to a tip.
- **Inner corners slide far back.** The inner pull-back, `halfWidth * tan(turn / 2)`, also explodes near 180 degrees and hit its cap of half the shorter segment. The taper therefore started halfway back along the segment.
- **The texture follows the taper.** Rows stretch between each quad's left and right edges, so the outline and core squeezed into the wedge too.
- **Smoothing doesn't help.** `Smooth` keeps corners past about 90 degrees sharp, because a curve that tight would fold the line.
- **Only exact reversals escaped.** Within 0.1 degrees of 180 (`MIN_JOIN_COS`) each segment got square ends. Real patrol data rarely reverses that exactly.

Worked numbers, 40-unit legs on the 4-unit line, 179-degree turn: the first leg's quad was start `(-40, 2) (-40, -2)`, end `(-20, 2) (4, 0)`. Its outer edge ran from the start corner to a tip at `(4, 0)`; its inner edge stopped at `x = -20`.

## Options compared (`turns.svg`)

Columns: turns of 90, 135, 150, 170, 179 and 179.95 degrees, default 3-unit line, zoomed on the turn. "Past 120" means turns where the miter would exceed the limit; turns up to 120 degrees keep today's miter in every option.

| Row | Idea | Textures per sharp turn | Verdict |
| --- | --- | --- | --- |
| Shipped now | The code after the patch: J. | +3 | Matches J; at exact reversals a clean half-disc end. |
| Before | Clamped miter tip (commit `7c1e28bd8`). | 0 | The `>`. |
| A. Shorter pull-back | Before, but inner corners pulled back at most 2 half widths. One-line change. | 0 | Shorter arrowhead; still pointed; legs cross at 170. |
| B. Square ends at the turn | Each leg ends flat at the point. | 0 | Clean but blunt; inner side overlaps. |
| C. Square ends past the turn | Each leg extends half a line width past the point. | 0 | Blunt end; inner overlap. |
| D. Bevel | B plus one flat wedge on the outside. | +1 | Same as B at reversals. |
| E. Round | B plus a fan of 30-degree wedges outside. | +5 or 6 | Round, but many textures. |
| F. Half-circle start cap | B plus a half-disc texture capping the outgoing leg; a plain rectangle quad. | +1 | Round and simple. Overlaps the incoming leg by a sector of 180 minus the turn, slightly darker at 120 to 170. Exact at reversals. |
| G. Disc cap on a kite | B plus the exact outer sector of a disc, via 8-value `SetTexCoord`. | +1 | Round, no overlap with the incoming leg's outside. |
| H. Mitered inner + F's cap | Inner corners mitered, outer square, F's cap. | +1 | Leaves a hollow (outlined red). |
| I. Mitered inner + G's cap | Same with G's cap. | +1 | Same hollow. |
| J. I with the hollow filled | Each leg also gets the triangle between its inner corner, the point and its outer corner. | +3 | No gap and no overlap from 120 to about 160. Near 180 both legs share one strip, so overlap is unavoidable. |

**Shared drawback of B to I:** without the inner pull-back, one leg's black edge crosses the other leg's core on the inside of the turn from 135 to 170 degrees. Today's pull-back avoids that crossing, and it's also what stretched the `>`.

**Why H and I have a hollow:** in a miter each leg ends on the line from its inner corner through the point to the shared tip, which splits the turn cleanly. Squaring the outer corner at the point makes each leg end on the line from its inner corner straight to its outer corner, cutting off the triangle between the inner corner, the point and the outer corner. A quad has only four corners, so it can't be the five-sided shape the leg needs; the fill triangle is the fifth piece.

**Idea not taken yet:** use J from 120 to about 160 degrees and F above, where both legs share one strip. The cut-over angle would need tuning in game.

## Textures

### The cap texture (`waypoint-cap-aa`)

- **Profile:** the line's rows turned into rings around the center: white core to radius 3, black outline to 6, half-transparent fade to 7, transparent beyond. A leg and its cap meet without a seam because the same distance from the centerline gives the same color.
- **Texel density:** radius 8 texels, matching the line's 8 texels from centerline to quad edge. The renderer uses `LINEAR` filtering without mipmaps, which only stays smooth when a texture has about as many texels as the line has pixels. A sharper 64x64 disc would be minified more and shimmer.
- **Size:** 32x32, a power of two, with a transparent margin for the kite, which reaches about 11.3 texels from the center. Every transparent pixel is black, so filtering fades to black rather than to a fringe.
- **One asset for F and G:** F would crop the right half with `SetTexCoord(0.5, 0.75, 0.25, 0.75)`, which lands on texel boundaries; G maps its kite with the 8-value form.
- Its profile matches the line's rows to within about 14/255 (anti-aliasing on the curve).

### The line texture (`waypoint-line-aa`)

16x16, constant along x. Rows: 0 transparent, 1 black at alpha 128, 2 to 4 black, 5 to 10 white, 11 to 13 black, 14 black at alpha 128, 15 transparent. Its SVG source renders back to the shipped PNG exactly.

### SVG as the source of truth

Decided: the SVGs, `build.sh` and `preview.py` live in `Icons/originals/waypoints/`, and `build.sh` renders into `Icons/waypoints/`, which the addon loads. `build.py` leaves `originals` out of releases. `rsvg-convert` (librsvg) isn't in the AGENTS.md prerequisites; only whoever edits textures needs it.

### What `SetTexCoord` does (from the WoW API docs)

- `SetTexCoord(left, right, top, bottom)` crops; `SetTexCoord(ulX, ulY, llX, llY, urX, urY, lrX, lrY)` sets each corner's image position, which allows affine transforms.
- Coordinates are fractions of the image with (0, 0) at its top left.
- Outside 0 to 1 without tiling, the outermost pixels repeat. With `CLAMP` and a transparent border, everything past the disc stays transparent.
- `SetTexture` does not reset the transformation. Pooled textures that set coordinates must not be reused as plain lines, or must be reset with `SetTexCoord(0, 1, 0, 1)`.
- The corner order UL, LL, UR, LR matches `_DrawQuad`'s mapping: UL is start left, LL start right, UR end left, LR end right.

## The implemented change (J), in `sharp-turn-joins.patch`

**`WaypointGeometry.lua`:** `Quads` returns `quads, fills, caps`.
- Turns up to 120 degrees join exactly as before (`cosHalf * MITER_LIMIT >= 1`).
- Past that: inner corners mitered as before; outer edges end square at the turn point; two fills (triangle from a segment's corners at the turn to the point, laid out as a quad whose end corners are both the point); one cap (kite from the point out `sqrt(2)` half widths along both outer normals and the outward bisector).
- A turn back (within 0.1 degrees of 180) keeps square ends and gets an exact half-disc cap built from the first segment's normal both ways. Using both segments' own normals made the kite bend past straight at the point (found in review).
- Every piece winds the same way as the segment quads (`_Cap` swaps its corners when needed).

**`WaypointRenderer.lua`:**
- **Fills** use the line texture with `SetTexCoord(0, 0, 0, 1, 1, 0.5, 1, 0.5)`: edge rows at the segment's corners, center row at the point.
- **Caps** use `Icons/waypoint-cap-aa.png`; each corner's coordinate is `0.5 + offset from the point * (8 / 32) / quadHalfWidth`.
- **Pools:** fills and caps have their own kinds, because `SetTexture` keeps texture coordinates.
- **Tinting:** `Restyle` and `RedrawAll` tint lines, fills and caps through `_Tint`.
- **Rename:** the debug hover discs went from `caps` to `dots`.

**`docs/waypoints.md`:** sharp turns, the cap texture, convexity, edge cases, client APIs, and a new "Still to verify in game" item.

**Checks run:** full suite 2909 successes, 0 failures, 1 pending (the QuestieDB conformance test, which needs a QuestieDB checkout and was pending before). luacheck: 0 warnings, 0 errors.

**Tests added or changed:**
- 150-degree turn: literal corners from hand-worked trigonometry (inner corner `16 - 2 sqrt(3)` from `tan 75`, cap corner `(sqrt(3) + 1, 1 - sqrt(3))` from `cos 15` and `sin 15`).
- Turn back: literal half-disc cap.
- 90 degrees: no fills or caps.
- Convexity and winding of every quad, fill and cap at 120.5, 150, 179, 179.95 and 180 degrees, both directions, after a short segment; each fill starts at its own segment's corners.
- Renderer: fills and caps drawn, tinted, with their texture coordinates; fills and caps never hand altered textures back to lines.
- Each was checked to fail against the old code or a deliberate mutation: shared pools, untinted fills and caps, the old turn-back cap, a fill using the wrong inner corner, swapped cap corners.

**Fresh review findings, all fixed:** concave caps between 179.885 and 180 degrees; a cap texture-coordinate test that a corner swap could pass; no test that the second fill uses its own inner corner; out-of-date convexity claims in the docs.

**Review also confirmed:** no gaps at any sharp turn, both directions, short and long segments, closed patrols; no NaN or infinite values near 120 and 180 degrees; the `SetTexCoord` order and cap scale.

## Open items

- **Verify in game first:** that the 8-value `SetTexCoord` follows the corners `SetVertexOffset` moves, and that fills and caps meet their segments without seams. Nothing in busted can cover this. A small Lua snippet that draws one texture with both set was offered but not written.
- **Two renderer assertions are weak** (not yet rewritten):
  - The fill's texture coordinates are asserted as the same literal the implementation uses. Only the v values carry meaning; the u values are arbitrary. Better: assert only v (edge rows 0 and 1 at the start corners, 0.5 at the point).
  - The cap's expected texture coordinates use the same formula as `_SetCapTexCoord`. Better: assert each outer corner lies `sqrt(2) / 4` from the image center (disc radius 8 of 32 texels, kite corners `sqrt(2)` half widths out) and points the same way as the drawn corner from the turn point.
- **Convention-coupled literals:** the order of the cap's corners and the fill's left/right swap in the geometry tests follow conventions chosen in the implementation. The winding loop is what protects the real requirement.
- **Overlap near 180 degrees:** at most turnarounds the inner pull-back reaches its limit (at 170 degrees it needs both segments longer than about 45 units at the default width). There fills and segments overlap a little on the inside and draw slightly darker.
- **Cost:** each sharp turn draws 3 more textures.
- **Possible split rule:** J up to about 160 degrees, F above.
- **SVG sources:** decide where they live (see above) before moving them out of `scratch/`.
- **`scratch/`** isn't in `.gitignore`, so it shows in `git status`.
- **Comments in docs:** "Still to verify in game" in `docs/waypoints.md` still lists the earlier unverified items (tracker flash, visibility toggles, settings, other clients, smooth-zoom frame cost).
