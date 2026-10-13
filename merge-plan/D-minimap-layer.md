# Area D: shared minimap layer

`WP` is `origin/waypoints` (`7c1e28bd8`). `B` is `blob` (`715031ef6`). Line numbers are from those commits.
Blizzard UI source is from Gethe/wow-ui-source:
- `forever` at `943764493` (1.60.1 (70338))
- `classic_era` at `8165d4cd` (1.15.9 (70003))
- `classic` at `ea620b2f` (5.5.4 (70268))
- `classic_anniversary` at `2cfec7c0` (2.5.6 (70006))
- `classic_titan` at `25ab1ea3` (3.80.2 (70315))

All five were fetched fresh on 2026-10-13.

Checked before writing:
- `busted Modules/Map/Waypoints/WaypointMinimap.test.lua` in the waypoints checkout: 21 passed.
- `busted Polygon/PolygonMinimap.test.lua` on B: 9 passed.
- `busted Libs/HereBeDragons/HereBeDragons-Pins-2.0.test.lua` on B: 6 passed.
- HereBeDragons-Pins and the six TOCs were 3-way merged with `git merge-file` on scratch copies. The repo was not touched.

## 1. Problem

### What each branch does today

Both branches draw world-yard geometry over the minimap so it lines up with Questie's minimap icons. Each built its own copy of the same scaffold:

| Piece | WP `Modules/Map/Waypoints/WaypointMinimap.lua` | B `Polygon/PolygonMinimap.lua` |
|---|---|---|
| Projection types | `WaypointMinimapProjection` 36-43 | `PolygonMinimapProjection` 22-29, identical fields |
| `_ProjectPoint`, `_Transform` | 57-60, 64-67 | 84-87, 94-97 |
| Culling | per-segment reach square around the projection origin, `CULL_MARGIN = 2` (26, `_Runs` 75-108, path bounds precheck 382-383) | `IsInView` 120-123: bounds within `VIEW_MARGIN = 1.5` radii of the **player** (43) |
| Reprojection | new instance, radius, facing, size, **or drift > 0.5 radius** (363-365) | new instance, radius, facing, size only (300-301) |
| Redraw cadence | only when stale (374-398) | re-filters every area and republishes on **every frame the player moves** (307-319) |
| `_IsAtlas`, `ShapeMask`, `_ApplyShapeMask` | 117-147 | 132-160 |
| `SetMaskTexture` post-hook | 152-162, one mask | 166-176, a list of masks |
| `_IsSecret` | 192-198 | 260-266, identical |
| Per-frame sample | 347-360 | 283-298, identical |
| Root, container, shape mask, player mask | 427-446 | 351-370 |
| Root level | `minimap:GetFrameLevel() + 1` (433) | same (357) |
| OnUpdate error handling | report, clear, **hide last** (452-461) | hide, report, clear (376-384) |
| OnHide | ends the hover (463) | none |
| Hover | `_ReadCursor`, `_UpdateHover`, `_EndHover` (283-317) | none |
| Player mask asset | `QuestieLib.AddonPath .. "Icons\\minimap-player-mask.tga"` (29) | hardcoded `"Interface\\Addons\\Questie\\Icons\\polygon-minimap-player-mask.tga"` (45) |
| Lazy creation | `WaypointMinimap.Invalidate` creates on the first path change (473-486) | `QuestiePolygon` creates it at the first objective build (B `QuestiePolygon.lua:1009-1015`) |

### Where they collide

1. **Two roots at the same level.** Both sit at Minimap + 1 (WP 433, B 357). Each root is created lazily, at a different moment. Their stacking is therefore undefined: paths and areas can swap order between sessions.
2. **Conflicting `CORNER-*` fallback.**
   - WP returns the square mask only for `"SQUARE"` (WP 133). Its test asserts the round mask for `CORNER-TOPLEFT` (WP `WaypointMinimap.test.lua:431-438`). This was a deliberate fix in WP `d44b506a2`, "mask a minimap square only when it is fully square".
   - B also returns the square mask for `^CORNER%-` (B 146). Its test asserts `WHITE8X8` for `CORNER-TOPLEFT` (B `PolygonMinimap.test.lua:325-326`).
   - On the same minimap, areas would spill past the round quarter while paths stop short of it.
3. **Two post-hooks and two per-frame samples.** Each reads `HBD:GetPlayerWorldPosition`, `HBDPins:GetMinimapView`, `GetPlayerFacing` and the minimap size every frame.
4. **Duplicate asset.** `Icons/minimap-player-mask.tga` (WP) and `Icons/polygon-minimap-player-mask.tga` (B) are the same blob, `9a470080f`. B hardcodes its path, and its test locks the path in (B `PolygonMinimap.test.lua:349`).
5. **HereBeDragons-Pins.** Both branches add the same `pins:GetMinimapView` (WP 697-710, B 732-746). B also has:
   - `MINOR` 17 (B:3)
   - the `OnWorldMapPinUpdated` callback (B:506-510, 513-519)
   - an `oldversion < 17` upgrade (B:530-551)
   - a test file

### What breaks

Nothing crashes, and the rebase needs no Area D conflict resolution:
- HBD-Pins replays through `38da5d634` and `d674119b6` to exactly B's tip, with one `GetMinimapView`.
- All six TOCs merge cleanly.

The cost is visual and structural:
- undefined stacking
- inconsistent shape masking
- double per-frame work while both features draw
- two copies of every fix (see the secret-value gaps in §3)

## 2. Comparison

### Per-function verdict

| Piece | Better version | Why |
|---|---|---|
| `_ProjectPoint` / `_Transform` | either (identical math) | Precompute scale, sin and cos once per projection instead of once per call. |
| Culling and reprojection | **WP** | B's origin never moves, so B must re-filter relative to the player on every moving frame. WP's drift policy (reach 2 r around the origin, reproject at 0.5 r drift) bounds the work. It also covers the view: √2 + 0.5 < 2 in Chebyshev distance, and B's 1.5 r guarantee still holds. |
| Bounds culling | both | Both test `{minX, minY, maxX, maxY}` against a square. Keep it, centred on the origin. |
| Placement | either | Container anchored at `TOPLEFT` to the minimap's `CENTER`, offset `-Project(player)`. Checked numerically against HBD's `drawMinimapPin`: error 1e-14. |
| `ShapeMask` | **WP** | See the `CORNER-*` evidence below. |
| Hook | **WP** | It drives one mask. B's list exists only because B could create several layers. |
| `_IsSecret` | identical, but both have gaps | See §3, "Secret values". |
| Hover | **WP**, the only one | Keep the mechanics (cursor, focus, shape, change detection) in the shared module. Keep the hit test in WP. |
| Error handling | **WP** order | Clearing can invalidate the layer: WP's `Clear` ends the hover, which changes the highlight, which calls `Invalidate`. So the layer must be turned off *last*. |
| OnHide | **WP** | Ends the hover when the minimap hides. |
| Asset path | **WP** | Built from `QuestieLib.AddonPath`. |
| Alignment test | **B** | B's test (B `PolygonMinimap.test.lua:162-203`) uses the real HBD-Pins lib as its oracle. WP's re-implements HBD's arithmetic (`PinPosition`, WP test 70-76). |
| Collect injection | **B** | `New(minimap, collect)` keeps `PolygonMinimap` free of `QuestiePolygon`. |

### Strengths and weaknesses

- **WP strengths:** bounded redraw, hover, OnHide handling, AddonPath, a fail-safe shape rule, lazy setup with a `setupFailed` latch.
- **WP weaknesses:**
  - Its alignment oracle is self-made.
  - Hover treats any hooked asset other than the `WHITE8X8` path string as round (WP 294). SexyMap squares its minimap by passing FileDataID `130871`, so a SexyMap square minimap draws paths into its corners but cannot hover them there.
- **B strengths:** the real-HBD alignment test, the injected collector, and bounds-based culling of large areas (B test 227-235).
- **B weaknesses:**
  - per-frame refiltering while walking
  - hardcoded path
  - `CORNER-*` overdraws the round quarter
  - duplicated hook and root

### The `CORNER-*` shape rule, decided on evidence

`GetMinimapShape` is a community convention; no Blizzard branch defines it (searched all five branches). The three sources agree:
- **HBD-Pins** `minimap_shapes` (WP `HereBeDragons-Pins-2.0.lua:85-100`) is ordered `{upper-left, lower-left, upper-right, lower-right}`, where `true` means a round quarter. `drawMinimapPin` (146-162) uses a round test in round quarters and a square test elsewhere. `CORNER-TOPLEFT = {true, false, false, false}`.
- **LibDBIcon** (B `Libs/LibDBIcon-1.0/LibDBIcon-1.0.lua:138-153`, quadrant math 156-175: q1 bottom-right, q2 bottom-left, q3 top-right, q4 top-left) gives `CORNER-TOPLEFT = {false, false, false, true}`. That is the same shape.
- **SexyMap** (funkydude/SexyMap `Shapes.lua`, master, fetched 2026-10-13) labels a texture "Rounded - Bottom Right":
  - Its geometry `bottomRight` arcs over 90°–180°, which is the **top-left** quarter.
  - It reports `CORNER-TOPLEFT`, so the label names where the minimap sits on screen.
  - Its square shapes report `SQUARE`, are keyed by FileDataIDs (`130871` = `WHITE8X8`), and are applied with `Minimap:SetMaskTexture(db.shape)`.
  - Its diamond, octagon, hexagon and two-quarter "Rounded - Top/…" shapes report `ROUND`.

So **`CORNER-X` is a square minimap with one round quarter X**, `SIDE-X` has two round quarters, and `TRICORNER-X` has three.

**Decision: one rule for both layers. Use the square mask only for `SQUARE`; any shape with a round quarter uses the round mask.** WP's rule wins.
- Every `CORNER`, `SIDE` and `TRICORNER` shape contains the inscribed disc. So the round mask never draws past the visible edge. The square mask always overdraws in each round quarter's corner.
- Overdraw puts a line, or a translucent fill, outside the minimap over the game world. That is a visible bug. Underdraw leaves square corners empty, which is exactly how a round minimap looks.
- B's "majority area" argument treats the two errors as equal, and they are not. The same reasoning holds for paths and for areas.
- The fallback is rarely used anyway. The hook captures the exact asset from every `SetMaskTexture` call after Questie's files load. That includes SexyMap, which loads after Questie because S sorts after Q, and Ace addons calling it from `OnEnable` at `PLAYER_LOGIN`. Only a call made during an earlier addon's file load or `ADDON_LOADED` reaches the fallback.

**A quarter-aware mask is rejected under YAGNI:**
- Mask textures multiply (they intersect), so "square except one round quarter" cannot be one mask.
- It would need up to four extra per-quarter masks per texture, using tex-coord cropping and `CLAMPTOWHITE`. That is unverified on six clients.
- It would serve only shapes set before Questie loaded *and* never re-set. Those are the shapes the hook cannot see.
- If a real report shows up, it is a change to `ShapeMask` and its masks alone.

## 3. Target design

### Modules and ownership

| Module | Owns | Public interface |
|---|---|---|
| **`MinimapCanvas`** (new, `Modules/Map/MinimapCanvas.lua`) | root frame, per-layer containers, stacking, shape mask, `SetMaskTexture` hook, player mask, one per-frame sample, projection and drift policy, container placement, cursor reading, error isolation, show and hide | `AddLayer`, `Invalidate`, `Project`, `InReach`, `ShapeMask` (and `Unproject`, which lands with Area A's first caller) |
| `WaypointMinimap` (WP, slimmed) | the paths layer: route choice per route, culling to runs, styling, restyling, hit test | `Invalidate()` |
| `PolygonMinimap` (B, slimmed) | the areas layer: world-yard outline cache, area culling, styling, view reuse | `New(collect)` → `{Invalidate, Clear}`, `WorldOutline` |
| `WaypointRenderer`, `PolygonRenderer` | unchanged; each draws into its layer's container with the canvas masks | unchanged |

Each layer keeps its own drawing logic and renderer. The canvas owns everything that must be identical for the layers to line up with each other and with HereBeDragons' icons.

### `MinimapCanvas` API (LuaCATS)

```lua
-- luacheck: read globals GetMinimapShape
---One masked drawing surface over the minimap, shared by Questie's minimap layers: objective areas
---and patrol paths. Each frame it samples the player and the minimap view once for every layer,
---projects world yards the way HereBeDragons-Pins places minimap icons, and moves each layer's
---container under the player. Nothing here takes mouse input or calls protected API.
---@class MinimapCanvas
local MinimapCanvas = QuestieLoader:CreateModule("MinimapCanvas")

---@alias MinimapLayerName "areas"|"paths"

---Where world yards show on the minimap: x right and y down, in the minimap's own units. Read only.
---@class MinimapProjection
---@field originX number World yards drawings are placed relative to.
---@field originY number
---@field instanceId number
---@field radius number Yards from the minimap's center to its edge (HBDPins:GetMinimapView).
---@field reach number Yards around the origin that drawings must cover until the next projection.
---@field halfWidth number Minimap half-extents in its own units.
---@field halfHeight number
---@field facing number? Player facing in radians while the minimap rotates; nil keeps north up.
---@field scaleX number Derived: minimap units per yard, and the facing's rotation.
---@field scaleY number
---@field sin number
---@field cos number

---One kind of drawing on the canvas. The canvas calls these only from its own update, as plain
---functions. An error in one is reported, the layer is cleared, and it stays off until its next
---Invalidate, while the other layers keep drawing.
---@class MinimapLayer
---@field Collect fun(): boolean After an Invalidate: gathers what should show, wherever it lies, and releases drawings of what no longer should. True while anything should show. Draws nothing.
---@field Draw fun(projection: MinimapProjection?) Shows what lies within projection.reach of its origin and hides the rest. nil hides everything until the next call with a projection.
---@field Clear fun() Releases every drawing and ends any hover.
---@field Hover fun(x: number?, y: number?)? The cursor in projected units, relative to the projection origin; nil while it is off the bare minimap, outside its shape, or nothing can be drawn. Called top layer first, only when the cursor moved against the drawing: the cursor or the player moved, or the layer drew again.

---Adds a layer, creating the canvas over the minimap on first use. Drawing starts on its first
---Invalidate. Errors when the canvas cannot be created; the minimap is optional, so callers pcall.
---@param name MinimapLayerName
---@param layer MinimapLayer
---@return Frame container The layer's renderer canvas: it moves with the player, so projected units are TOPLEFT offsets. Its frame level puts it above the layers beneath it.
---@return MaskTexture[] masks The minimap's shape and the hole over the player arrow. Add both to every texture.
function MinimapCanvas.AddLayer(name, layer) end

---The layer's Collect runs on the next update, after its data, visibility or settings changed.
---@param name MinimapLayerName
function MinimapCanvas.Invalidate(name) end

---Projects world yards into the projection's minimap units.
---@param projection MinimapProjection
---@param x number
---@param y number
---@return number x
---@return number y
function MinimapCanvas.Project(projection, x, y) end

---Whether world bounds on an instance come within the projection's reach, so their drawing can
---show before the next projection.
---@param projection MinimapProjection
---@param instanceId number
---@param bounds number[] {minX, minY, maxX, maxY} in world yards.
---@return boolean
function MinimapCanvas.InReach(projection, instanceId, bounds) end

---The minimap's shape mask: the last asset passed to Minimap:SetMaskTexture since Questie loaded.
---Before any call, GetMinimapShape decides: "SQUARE" is square, and any round quarter uses the
---round mask (Forever's own atlas where the client has it). Without GetMinimapShape it is round.
---@return string|number asset
---@return boolean isAtlas
function MinimapCanvas.ShapeMask() end

---For Area A, landing with its first caller: world yards at projected units, Project's inverse.
---@param projection MinimapProjection
---@param x number
---@param y number
---@return number x
---@return number y
function MinimapCanvas.Unproject(projection, x, y) end
```

`Unproject` is `u = x / scaleX`, `v = y / scaleY`, then `worldX = originX - (u*cos + v*sin)` and `worldY = originY - (-u*sin + v*cos)`. A scratch round trip on a rotated, non-square projection returned errors of at most 1.8e-12.

### Core of the canvas (sketch)

```lua
-- Stacking, bottom to top. Each layer's container sits one level above the one before it, so paths
-- cross areas. Questie's minimap icons stay far above at 2016+ (QuestieMap.utils.SetDrawOrder).
local LAYER_ORDER = {"areas", "paths"}
-- Everything visible lies within √2 view radii of the player: a square minimap's corners. Drawings
-- within REACH radii of the origin cover that view while the player stays within DRIFT radii of
-- it (√2 + 0.5 < 2); past that, everything is projected again.
local REACH, DRIFT = 2, 0.5
local PLAYER_MASK = QuestieLib.AddonPath .. "Icons\\minimap-player-mask.tga"

local function _Update()
    -- 1. Collect invalidated layers. A layer that collected nothing stops: Hover(nil), Draw(nil).
    -- 2. No active layer: root:Hide() and return; it costs nothing per frame until Invalidate.
    -- 3. One sample: HBD:GetPlayerWorldPosition, HBDPins:GetMinimapView, GetPlayerFacing while
    --    rotating, minimap width and height. Nil, secret, radius <= 0 or zero size: every
    --    active layer gets Hover(nil) and Draw(nil); return.
    -- 4. New projection for a new instance, radius, facing, size, or drift > DRIFT * radius
    --    (Chebyshev). Every layer must draw again.
    -- 5. Draw(projection) for each active layer that collected or must draw again.
    -- 6. Player moved: offset = -Project(projection, player); SetPoint every container at
    --    TOPLEFT of minimap CENTER (offsetX, -offsetY).
    -- 7. Cursor once. For each active layer with Hover, top first: call it when the cursor changed
    --    or the layer drew.
end
```

Error isolation keeps WP's ordering:

```lua
local function _Call(state, method, ...)
    local ok, result = pcall(state.layer[method], ...)
    if ok then return result end
    Questie.Error("Minimap " .. state.name .. " drawing failed:", result)
    local cleared, clearErr = pcall(state.layer.Clear)
    if not cleared then Questie.Error("Minimap " .. state.name .. " cleanup failed:", clearErr) end
    -- Last: clearing may invalidate the layer, as ending a hover changes a highlight.
    state.dirty, state.active, state.drawn, state.cursorX, state.cursorY = false, false, false, nil, nil
end
```

An error in the canvas's own `_Update` is reported once. Then every layer is cleared and turned off, and the root is hidden last. `OnHide` (for example, the minimap toggle key) delivers `Hover(nil)`. It keeps the drawings, because the hidden parent hides them anyway.

`_ReadCursor` is WP 283-298 moved into the canvas, with two changes:
- It also guards `IsMouseOver` and `GetEffectiveScale` with `_IsSecret`.
- Corners count as hoverable when `ShapeMask() == SQUARE_MASK` **or** `GetMinimapShape() == "SQUARE"`. That fixes SexyMap's FileDataID square and any other square asset (commit C3).

### The two layers after the move

**`WaypointMinimap` (paths).** `layer.Collect` is today's `_Collect` (217-240) and returns `paths[1] ~= nil`.
- `layer.Draw(projection)` is today's stale block (374-398):
  - the per-path precheck becomes `MinimapCanvas.InReach(projection, path.instanceId, path.worldBounds)`
  - `_Runs` uses `MinimapCanvas.Project` and `projection.reach`
  - styles read `container:GetFrameLevel()` as today
  - `Draw(nil)` publishes `{}` and empties `targets`
- `layer.Hover(x, y)` is today's 307-309: `WaypointGeometry.Nearest` against `targets`, then `WaypointHover.Set("minimap", path, path and path.owner.minimapTwin)`.
- `layer.Clear` is today's 412-418.
- `WaypointMinimap.Invalidate()` keeps the lazy setup:
  - on the first call: `pcall(MinimapCanvas.AddLayer, "paths", layer)`, then `WaypointRenderer.New(container, masks)`, with the `setupFailed` latch
  - then `MinimapCanvas.Invalidate("paths")`
- Removed: the projection, mask, hook, sample, root, OnUpdate, OnHide and cursor code, plus `WaypointMinimap.New` and `WaypointMinimap.ShapeMask`.

**`PolygonMinimap` (areas).** `PolygonMinimap.New(collect)` drops its `minimap` parameter. It calls `MinimapCanvas.AddLayer("areas", layer)` and `PolygonRenderer.New(container, nil, masks)`.
- `layer.Collect` runs `collect()` and today's `_ReleaseRemoved` (248-258), and returns `areas[1] ~= nil`.
- `layer.Draw(projection)` loops over areas. It uses `WorldOutline` and `InReach(projection, area.cluster.instanceId, world.bounds)`, then calls `_View` and `_Publish`.
  - `_View` projects outline points with `MinimapCanvas.Project`.
  - `Draw(nil)` publishes `{}`.
- `layer.Clear` is today's 336-341, then `MinimapCanvas.Invalidate("areas")`. After `QuestiePolygon.Reset`, the canvas then finds nothing and hides itself. In the error path, the canvas's last-word deactivation overrides that invalidate.
- `layer.Invalidate` is `MinimapCanvas.Invalidate("areas")`.
- `QuestiePolygon` changes three lines (B 380, 517, 1010):
  - `minimapLayer.Invalidate()`
  - `pcall(minimapLayer.Clear)`
  - `pcall(PolygonMinimap.New, _CollectMinimapAreas)`
- Removed: `Project`, `IsInView`, `VIEW_MARGIN`, the shape and mask code, the hook, the sample, the root and the OnUpdate.

### Data flow

```text
QuestieWaypoints._Changed ──► WaypointMinimap.Invalidate ─┐
QuestiePolygon.ScheduleRefresh ──► areas.Invalidate ──────┴─► MinimapCanvas.Invalidate(name) ─► root:Show()

root OnUpdate, once per frame:
  dirty layers ─► Collect() ─► active? ─── none ─► root:Hide()
  one sample (HBD position, HBDPins:GetMinimapView, facing, minimap size; nil or secret ─► Draw(nil))
  projection (new view or drift > ½ radius) ─► Draw(projection) for layers that must draw
  player moved ─► every container to minimap CENTER − Project(player)
  cursor (bare minimap, inside shape) ─► Hover(x, y), top layer first, when changed

Minimap:SetMaskTexture post-hook (installed at file load) ─► shape mask asset ─► the one shape mask
```

### Draw order

- The root sits at `Minimap:GetFrameLevel() + 1`, as on both branches today.
- The **areas** container is at the root's level. The **paths** container is one above. Views take their container's level, which both renderers already read at draw time (WP 252, B 228).
  - Containers are frames, so a later shift of the minimap's level moves them together. A precomputed number would not.
- Questie's minimap icons are fixed at 2016+ (WP `QuestieMapUtils.lua:53-72`, applied to minimap icons at WP `QuestieMap.lua:370`). They stay far above both layers.
- This matches the world map, where areas sit at `PIN_FRAME_LEVEL_QUEST_BLOB`, below paths at 2015 (WP `WaypointMap.lua:18`), below icons at 2016+.
- HBD parents minimap pins to `Minimap` without setting a level (WP `HereBeDragons-Pins-2.0.lua:616`). Other addons' pins therefore default to Minimap + 1: tied with areas, below paths.
- Blizzard's `MinimapBackdrop` is a child of `Minimap` at Minimap + 1 on Era (`classic_era Classic/Minimap.xml:209`, north tag at 225) and Forever (`forever Mainline/Minimap.xml:240`). Its zoom buttons sit at + 2 on Era (290).
  - WP's doc (`docs/waypoints.md:221`) says paths sit "below … the bezel and buttons". That is wrong even today: it is a tie.
  - With paths at + 2, paths draw over the backdrop's chrome wherever the shape mask lets them, for example Era's "N" tag. See §8.
- Blizzard's own `HybridMinimap` is a child of `Minimap` in the `BACKGROUND` strata at level 100 (`forever Blizzard_HybridMinimap.xml:5`). Our LOW-strata layers draw above it.

### Asset

- Keep `Icons/minimap-player-mask.tga`, with its path built from `QuestieLib.AddonPath`, in the canvas.
- Delete `Icons/polygon-minimap-player-mask.tga`. `build.py:111` packages the whole `Icons` folder, so no packaging change is needed.
- B's test assertion (`PolygonMinimap.test.lua:349`) moves to the canvas test and expects `QuestieLib.AddonPath .. "Icons\\minimap-player-mask.tga"`.

### HereBeDragons-Pins: final vendored-lib diff

The final file equals B's tip, which the rebase already produces:
- `MINOR` 17
- `GetMinimapView` (B 732-746)
- the `OnWorldMapPinUpdated` callback (B 506-510, 513-519)
- the `oldversion < 17` upgrade (B 530-551)

**Keep it as a documented local patch. Do not upstream it as part of this merge.**
- The fork renames its MAJOR to `HereBeDragonsQuestie-Pins-2.0` and already carries Questie-only behavior: `Questie.db` reads in `HandlePin`, the 500-yard pin filter. Upstreaming would not remove the fork.
- Upstream master Pins (MINOR 17, fetched 2026-10-13) exposes neither a view getter nor a child callback.
- The repo records fork changes as inline `-- Questie modification` / `Questie addition` markers (master `HereBeDragons-Pins-2.0.lua:171, 397, 421, 434, 470, 698, 806, 820`). `Libs/HereBeDragons/CHANGELOG.md` is upstream's changelog.
- The repo bumps MINOR for behavior changes. For example, master `3f583f8c4` moved core 33 → 34, and `757ff447e` synced upstream 2.16 with Pins 15 → 16.
- `GetMinimapView` already carries "Questie addition" (B 732). B's world-map additions lack a marker, and get one in C4.
- The bump to 17 also protects `GetMinimapView`. A stale MINOR-16 copy loaded first would otherwise shadow it, and every canvas update would fail.
- Note for the next upstream sync: the fork's MINOR counts the fork's own versions. Upstream Pins is also at 17 now, so a sync must go to at least 18.
- Optional later: offer `GetMinimapView` upstream, since it is small and generic.

B's test file, `HereBeDragons-Pins-2.0.test.lua`, stays. Its view test (217-227) covers the zoom table, an unknown zoom (nil) and `GetViewRadius`. One case (171-215) loads `Polygon/PolygonNudging.lua`: a vendored lib's test depending on feature code. That case belongs in `PolygonNudging.test.lua`. It is optional and outside Area D, so it is flagged for the orchestrator.

### Secret values and client differences (six TOCs)

| Client (TOC) | `C_Minimap.GetViewRadius` | `issecretvalue` | Minimap chrome | Notes |
|---|---|---|---|---|
| Era `Questie_Vanilla.toc` 11508/11509 | no: HBD zoom tables, indoor/outdoor (WP HBD 66-83, 339-348) | declared (`classic_era FrameScriptDocumentation.lua:233`) | `MinimapBackdrop` child of `Minimap` | no `GetMinimapShape` from Blizzard |
| TBC 20506 (anniversary 2.5.6) | no | declared | same family (`Blizzard_Minimap_Classic.toc`) | |
| Wrath 38002 (titan 3.80.2) | no | declared | same | |
| Cata 40402 | no current wow-ui-source branch; HBD falls back to zoom tables when the API is absent | may be absent; the guard returns false | same family | |
| Mists 50503/50504 (classic 5.5.4) | no | declared | same | |
| Forever `Questie_Camelot.toc` 16001 | **yes** (`MinimapDocumentation.lua:127`), used by Blizzard's `HybridMinimap` (`Blizzard_HybridMinimap.lua:103`) | declared, with real secret annotations | `MinimapCluster.MinimapContainer.Minimap`, global `Minimap` (`Mainline/Minimap.xml:195`) | `Camelot/Skin.lua` calls `minimap:SetMaskTexture("ui-hud-minimap-frame-generic-mask")` at load and on every `rotateMinimap` change (7-19, 23-34, 52-57) |

- **Radius and rotation.** `GetMinimapView` returns exactly what HBD positions icons with: the API radius, or the zoom table with HBD's `indoors` state, plus HBD's `rotateMinimap`. Alignment with Questie's icons therefore holds on every client, even where HBD's own guesses are off.
- **Secret values.** Forever's generated docs mark these:
  - `GetCenter`, `GetWidth`, `GetHeight` and `IsMouseOver` as `SecretWhenAnchoringSecret` (`SimpleScriptRegionAPIDocumentation.lua:145-148, 323-327, 507-511`)
  - `GetEffectiveScale` as `SecretReturnsForAspect = Scale` (`SimpleRegionAPIDocumentation.lua:38-40`)

  They declare no secret *returns* for `UnitPosition` (arguments only, `UnitDocumentation.lua:2714-2728`), `GetPlayerFacing`, global `GetCursorPosition` or `GetViewRadius`.

  Both branches guard `x, y, radius, facing`, and WP also guards the cursor and center. Neither guards the minimap's width, height, scale or `IsMouseOver`, which are exactly the values the docs mark. The canvas guards them all. That costs nothing, and a secret value would otherwise throw on arithmetic and stop the layer. Anchoring secrets on the minimap are not expected; this is defensive.
- **Hookability.** `Minimap:SetMaskTexture` has no `SecureHooksAllowed = false` on any branch (`MinimapFrameAPIDocumentation.lua:141-149` on Forever, 87-94 elsewhere). The post-hook stays wrapped in `pcall`, as both branches do. B's README notes a post-hook failure once at Forever login.
- **Atlas.** `FOREVER_MASK_ATLAS` is chosen by capability (`C_Texture.GetAtlasInfo`), never by flavor.

### Lifecycle

- **Load:** the file installs the post-hook (needs `Minimap`; it records failures in `maskHookError`).
- **Lazy creation:** the root, both masks and the OnUpdate are created on the first `AddLayer`, and the hook failure is reported then. Each layer's container is created by its own `AddLayer`.
- **Show and hide:** `Invalidate` shows the root. The update hides it once no layer's last `Collect` found anything, so an idle canvas does no per-frame work.
- **Settings:** the canvas has none. Each layer's `Collect` reads its own settings, and each setter invalidates its feature:
  - WP: `waypointMinimapEnabled` in `QuestieWaypoints.MinimapAlpha` (WP 134-140); the setter calls `QuestieWaypoints.Refresh` (WP `QuestieOptionsMap.lua:22-25`).
  - B: `QuestiePolygon.IsEnabled` in `_CollectMinimapAreas` (B 297-299); "Enable Minimap Icons" calls `ScheduleRefresh` (B `QuestieOptionsIcons.lua:562`).
- **`Questie:OnDisable`:** no canvas reset is needed (YAGNI). The canvas holds no feature data, and hides itself once every layer is empty.
  - B's `QuestiePolygon.Reset` (B `Questie.lua:55`) clears the areas, and the new `Clear` invalidates, so the canvas hides on the next frame.
  - WP's paths follow their icons. Whether `OnDisable` should also release them belongs to Area C.

### Invariants

1. One sample per frame. Every layer draws with the same projection object, and every container sits at the same offset, so the layers line up with each other and with HBD's icons.
2. Drawings exist for everything within `reach` (2 r) of the origin. Reprojection happens before the player drifts 0.5 r, so the visible minimap is always covered.
3. Areas stack below paths, which stack far below Questie's icons. The order lives in one table.
4. Every texture carries both masks. The shape mask follows the last `SetMaskTexture` asset. The fallback is never wider than an accurately reported shape.
5. A failing layer never stops another layer or the addon. It resumes on its next `Invalidate`.
6. The root is shown only while some layer is dirty or active.
7. A layer that has hovered gets `Hover(nil)` whenever hover can no longer be computed: hidden minimap, no position, inactive, or an error (through `Clear`).

### Why this holds up without overbuilding

- A third layer, such as an objective radius or a route to the turn-in, needs one name in `LAYER_ORDER` and the four callbacks.
- There is no generic renderer, no per-layer policy and no event bus.
- The interface is five functions plus a four-callback contract. Behind it sit about 250 lines that both features need identically.
- WP's file shrinks from 486 lines to about 250, and B's from 386 to about 170.

**Rejected alternatives:**
- **Share helpers only, keeping two roots.** That still means two hooks, two samples and two OnUpdates, and the stacking still needs a decision. It fails the brief.
- **Per-layer projection policies.** Areas work under the paths' drift policy, so a second policy has no consumer.
- **Each layer reads the sample and positions itself.** The duplication comes back.
- **A canvas-owned generic renderer for lines and polygons.** The renderers differ fundamentally: vertex-offset quads versus triangles and `DrawLine`. It would be a large rewrite for no gain.
- **One frame with draw layers for ordering.** Both renderers use one frame per view.
- **Areas at the minimap's own level.** A parent and child tie at the same level, which is undefined.
- **Pins per segment through HBD.** Already tried and abandoned: no rotation, no thickness (WP `docs/waypoints.md:265-270`).
- **A quarter-aware mask** (see above).

## 4. Sequencing

### (a) During the rebase

**No Area D changes.** Checked:
- HBD-Pins merges cleanly at `38da5d634` and `d674119b6` and ends identical to B's tip, with exactly one `GetMinimapView`.
- All six TOCs merge cleanly.
- The two minimap modules, their assets and their tests share no files.
- Neither branch touches `setupTests.lua`.
- Every replayed blob commit loads both modules side by side. They draw with undefined stacking until (b).

After the rebase, at the stacked tip:
- run `busted Modules/Map/Waypoints/WaypointMinimap.test.lua Polygon/PolygonMinimap.test.lua Libs/HereBeDragons/HereBeDragons-Pins-2.0.test.lua`
- `grep -c "function pins:GetMinimapView" Libs/HereBeDragons/HereBeDragons-Pins-2.0.lua` must print `1`

### (b) Follow-up commits after stacking

Each commit passes its touched tests, luacheck and the loader validator.

**C1 `refactor(waypoints): draw minimap paths on a shared MinimapCanvas`**
- Add `Modules/Map/MinimapCanvas.lua` (API above, both `LAYER_ORDER` entries) and `Modules/Map/MinimapCanvas.test.lua`.
- In all six TOCs (`Questie_Vanilla`, `_TBC`, `_Wrath`, `_Cata`, `_Mists`, `_Camelot`), add `Modules\Map\MinimapCanvas.lua` after `Modules\Map\Moonwell.lua`. That is before `# Waypoints` and after `Modules\Libs\QuestieLib.lua`, which the file-scope `PLAYER_MASK` needs.
- `Modules/Map/Waypoints/WaypointMinimap.lua`: move onto the canvas as described.
- `Modules/Map/Waypoints/WaypointMinimap.test.lua`: see §5.
- `docs/waypoints.md`: see §6.
- Behavior changes, named in the commit body:
  - paths move from Minimap + 1 to + 2, above where areas will sit
  - secret guards on size, scale and `IsMouseOver`
- Optionally this commit lands on `waypoints` before it merges to master. That is David's call (§8).

**C2 `refactor(polygon): draw minimap areas on the shared MinimapCanvas`**
- `Polygon/PolygonMinimap.lua`: move onto the canvas. Add a header doc.
- `Polygon/PolygonMinimap.test.lua`: see §5.
- `Polygon/QuestiePolygon.lua`: B 380 `minimapLayer.Invalidate()`, 517 `pcall(minimapLayer.Clear)`, 1010 `pcall(PolygonMinimap.New, _CollectMinimapAreas)`.
- `Polygon/QuestiePolygon.test.lua`: line 88, stub `function(collect)` instead of `function(_minimap, collect)`.
- Delete `Icons/polygon-minimap-player-mask.tga`.
- `Polygon/README.md`: see §6.
- Behavior changes:
  - the `CORNER-*` fallback uses the round mask
  - areas are culled by reach around the origin and redrawn on reprojection, not filtered every moving frame
  - areas sit beneath paths

**C3 `fix(minimap): hover a square minimap's corners whatever asset squared it`**
- `MinimapCanvas.lua`: in `_ReadCursor`, treat the minimap as square when `ShapeMask() == SQUARE_MASK` or `GetMinimapShape() == "SQUARE"`.
- `MinimapCanvas.test.lua`: one test (§5).
- `docs/waypoints.md`: the hover shape sentence.

**C4 `chore(hbd): mark Questie's additions to HereBeDragons-Pins`** (optional)
- `Libs/HereBeDragons/HereBeDragons-Pins-2.0.lua`: `-- Questie modification` markers on B 506-510, 513-519 and 530-551. Add a comment at the MINOR line saying it counts the fork's versions.
- Optionally move the `PolygonNudging` case out of the lib's test, with the orchestrator's agreement.

## 5. Tests

All follow AGENTS.md:
- `dofile("setupTests.lua")` first
- `dofile` the module under test
- `QuestieLoader` stubs for collaborators
- `.was.called*` assertions

Precedent for loading real pure dependencies: WP's test loads `QuestieLib` and `WaypointGeometry`; B's loads the real HBD-Pins and `PolygonRenderer`.
- The canvas test uses fake layers.
- The layer tests load the real canvas and drive its root's OnUpdate. They capture the root from the `CreateFrame` mock.

**Add `Modules/Map/MinimapCanvas.test.lua`.** It uses the real `HereBeDragons-Pins-2.0.lua` with B's globals set (B test 5-8, 97-154). Each test proves one rule:

1. *Places drawings exactly where HereBeDragons-Pins places minimap icons, while walking, turning, zooming and resizing, north-up or rotating.*
   - `container offset + Project(point)` equals the anchor of an HBD icon at that point.
   - Covers rotation via `CVAR_UPDATE` and the zoom table via `GetMinimapView`.
   - From B test 162-203 and WP test 139-153.
2. *Only moves the containers while walking, and projects again once the player drifts half a view radius.* Counts `Draw` calls and checks the anchors (WP 252-266).
3. *Projects again for a new zoom, size, instance or rotating facing; ignores facing on a north-up minimap; does no work standing still* (WP 268-278, B 194-202).
4. *Samples the player and the minimap view once per frame for every layer, and hands both layers the same projection.* Spies on `GetPlayerWorldPosition` with two fake layers. New.
5. *`InReach`:* overlap, a large area reaching in only by its edge, another instance, just outside the reach (B 227-235 logic).
6. *Without a position, radius, size or facing, or while any is secret, every layer gets `Hover(nil)` and `Draw(nil)`, then draws again when they return* (WP 381-396, B 237-261; secrets new).
7. *Idles without anything to draw, until a layer is invalidated* (WP 280-287, B 267-271).
8. *Stacks areas beneath paths, both above the minimap and below Questie's icon level* (container levels against `Minimap` level and 2016). New.
9. *Isolates a failing layer.*
   - Reports it once, clears it, and keeps the other layer drawing.
   - The failed layer stays off even though its `Clear` invalidated it, and resumes on the next `Invalidate`.
   - From WP 398-415 and B 295-312.
10. *Reports the cursor in projected units over the bare minimap at its UI scale, again when the player walks under a still cursor, and after the layer draws again* (WP 316-328, 355-363).
11. *Reports no cursor while other UI covers the minimap, or outside a round minimap's shape* (WP 330-353).
12. *Ends hover when the minimap hides* (WP 394-395).
13. *Masks with the asset passed to `Minimap:SetMaskTexture`, also after the canvas exists, keeps outside the rectangle black, and never breaks that call* (WP 421-429, B 332-358).
14. *Falls back to `GetMinimapShape`.* This is **the decision test**.
    - `SQUARE` gives `WHITE8X8`.
    - `CORNER-TOPLEFT`, `SIDE-LEFT` and `TRICORNER-TOPLEFT` give the round mask.
    - Forever's atlas is used when `C_Texture` knows it.
    - From WP 431-444 and B 320-330, with B's `CORNER` expectation flipped.
15. *Leaves a soft hole over the player arrow.* `QuestieLib.AddonPath .. "Icons\\minimap-player-mask.tga"`, `CLAMP`, centred, 38 px (B 347-351).
16. C3: *Hovers a square minimap's corners when `GetMinimapShape` reports `SQUARE`, even with a FileDataID mask asset (`130871`).*
17. With Area A's caller: *`Unproject` inverts `Project` on a rotated, non-square minimap.*

**Change `Modules/Map/Waypoints/WaypointMinimap.test.lua`.**
- Keep 8 path-specific tests:
  - reach and runs (155-171)
  - closed patrol joined (173-184)
  - joins only where closed (186-200)
  - a route once (202-211)
  - the highlighted copy (213-236)
  - width restyle (238-250)
  - hover hit and reach (305-314)
  - a shared route's copy (365-379)
- Replace `layer.dirty = true` with `WaypointMinimap.Invalidate()`.
- Move the other 13 into canvas tests 1-3, 6-7 and 9-14: WP 139-153, 252-287, 316-363, 381-445.

**Change `Polygon/PolygonMinimap.test.lua`.**
- Slim 162-203 to one walking-and-rotated pass of `AssertOutlineOnIcons`. It proves `WorldOutline`'s per-axis conversion and the configured frames on the canvas.
- Keep these, with the same assertions:
  - highlight (205-225)
  - large area (227-235)
  - release and fade (274-293)
- Slim 237-272 to *skips areas on another instance, without world data, or out of reach*.
- Move to canvas tests 6-7, 9 and 13-15, with `CORNER` flipped and the AddonPath asset:
  - the position, size and idle parts
  - the failure test (295-312)
  - the three shape tests (314-359)

**Change `Polygon/QuestiePolygon.test.lua:88`:** the stub signature only. These need no change: `QuestieQuest.test.lua:592`, `TrackerUtils.test.lua:247`, `QuestieWaypoints.test.lua`, `HereBeDragons-Pins-2.0.test.lua`.

**Delete:** nothing beyond the moves. No test exists only to lock in deleted code.

## 6. Docs and comments

- **`Modules/Map/MinimapCanvas.lua` header and section comments** are the single source of truth for the shared mechanics: projection, reach and drift, masks and fallback, stacking, the hover rules, errors and lifecycle. Follow the `comment-instructions` and `human-readable-structure` skills. Section order: types, constants, shape, projection, canvas update, public functions.
- **`docs/waypoints.md`** (WP):
  - Line 47: `WaypointMinimap` becomes "the paths layer on MinimapCanvas: runs within reach, route choice, cursor hit test".
  - Line 54: add "minimap drawing goes through `MinimapCanvas`, shared with objective areas".
  - §Minimap (211-231):
    - keep the path-specific bullets (culling to runs, closed patrols, hover specifics, measurements)
    - replace the Projection, Masks, Layering and Driver bullets with a pointer to the canvas
    - state the stacking correctly: one level above objective areas, below Questie's icons; Blizzard's backdrop chrome at Minimap + 1 now draws beneath paths
  - §Polygon areas (273-281): "meant to be reused for polygon areas" becomes done; "Frame levels … decided then" becomes "paths above areas". The `IsLineFrame` and combat bullets belong to Areas A and C.
- **`Polygon/README.md`** (B):
  - §Minimap areas (34-47): shrink to the area-specific rules and point to the canvas. Fix "within 1.5 view radii of the player" to "within 2 view radii of the projection origin, covering 1.5 radii around the player". Change "`SQUARE` and `CORNER-*` use a square mask" to "only `SQUARE`". Change the asset to `Icons/minimap-player-mask.tga`. Change "beneath Questie's minimap icons" to "beneath patrol paths and Questie's minimap icons".
  - Line 81: the `PolygonMinimap` row becomes `New(collect)`.
  - Line 169: "minimap" loads after `MinimapCanvas` in the Map section.
  - Lines 186-188: add `Modules/Map/MinimapCanvas.test.lua` to the test command.
  - Line 16, "the minimap draws no waypoint lines": no longer true once combined. Area C words it per its fallback-marker decision (finding 4).
- **Inline comments:**
  - `WaypointMinimap.lua` 2-3 header.
  - A new `PolygonMinimap.lua` header.
  - `HereBeDragons-Pins-2.0.lua`: markers, and the MINOR note (C4).

## 7. Verification

**Offline:**

```bash
busted Modules/Map/MinimapCanvas.test.lua
busted Modules/Map/Waypoints/WaypointMinimap.test.lua Polygon/PolygonMinimap.test.lua
busted Libs/HereBeDragons/HereBeDragons-Pins-2.0.test.lua Polygon/QuestiePolygon.test.lua Modules/Map/Waypoints/QuestieWaypoints.test.lua
luacheck -q -- Database Localization Modules Polygon Public Questie.lua   # CI's file list (blob ci.yml)
lua cli/validate-loader-usage.lua
busted -p ".test.lua" .   # full suite, once, before calling it done
```

**In game.** Look on Era and Forever. A dev client is enough. No live install is needed.

1. **Era (1.15.x), default round minimap, Questie blobs preset.**
   - Open the world map and find an objective area that a patrol line crosses. Both features draw there too. Blob's documented test quests are 317 and 384 in Dun Morogh. Walk to that spot.
   - On the minimap, the line draws over the area fill, and both sit under Questie's minimap icons.
   - Walk 300 yards: both stay on their icons, and areas appear before reaching the edge.
   - Step through all zoom levels, and enter a cave to use the indoor table: alignment holds.
   - Check that the "N" tag, the border and the zoom buttons still read where a line crosses the top edge.
2. **Forever 1.60.1, Rotate Minimap on.**
   - Turn in place: both layers rotate with the icons.
   - Toggle Rotate Minimap: no error at the toggle or after `/reload`, and the mask stays Forever's atlas.
   - Compare the turning cost in `C_AddOnProfiler` with `docs/waypoints.md:233-238` (1.70 ms with one patrol in reach). Expect the same or lower with areas also drawn.
3. **Hover a path.**
   - Its tooltip and highlight appear.
   - Moving onto an icon hands the tooltip over.
   - Entering a dungeon ends the hover and hides both layers.
   - The minimap toggle key while hovering ends the hover.
4. **SexyMap, if available.**
   - The Square shape lets lines and areas reach the corners, and C3 makes the corner paths hoverable.
   - The "Rounded - Bottom Right" shape follows the exact mask through the hook.
5. **Toggles.**
   - "Enable Minimap Icons" off hides both layers.
   - "Enable Minimap Waypoints" off hides only the paths.
   - Leaving the blobs preset hides only the areas.

## 8. Risks and open questions

| # | Risk or question | Recommendation |
|---|---|---|
| 1 | Paths move from Minimap + 1 to + 2. Inside the mask they now draw over Blizzard's backdrop chrome (Era's "N" tag, Forever's bezel edge) and over other addons' default-level HBD pins. Today they tie, which is undefined. | Accept: deterministic stacking is the point. Check in game (§7.1). No mitigation exists without a level between the minimap and its children. |
| 2 | Areas adopt the paths' drift policy. They reconfigure all in-reach areas every 0.5 r walked (33–117 yd outdoors and 12–75 yd indoors, by zoom, from HBD's tables) instead of re-filtering every moving frame. | Accept. It is cheaper overall. Measure in a dense objective zone. |
| 3 | The `CORNER-*` fallback changes B's behavior from overdraw to underdraw. | Take WP's rule (§2). |
| 4 | Where C1 lands. | **After stacking**, so the waypoints PR stays as reviewed. The alternative lands it on `waypoints` first, so master gets the canvas with its first user. |
| 5 | Upstreaming HBD changes. | Keep the local patch with markers (C4). An upstream PR for `GetMinimapView` is optional and not blocking. |
| 6 | C3 changes WP's hover in square-minimap corners. | Include it: it makes hover match what the mask draws. |
| 7 | A pre-Questie diamond or hexagon mask, which SexyMap reports as `ROUND`, would overdraw with the round fallback. | Accept. SexyMap loads after Questie, so the hook sees its exact asset. |
| 8 | Layer tests run through the real canvas, so a policy change can ripple into them. | Accept. It mirrors today's tests, which run through real HBD-Pins, and avoids exposing a projection constructor only for tests. |
| 9 | If the canvas cannot be created, both features lose the minimap. Each reports its own setup error. | Accept. It matches today, where both would fail the same way. |
| 10 | `Hover` may need a "claimed" result to arbitrate between paths and areas. | Area A decides. It is a two-line change in the canvas's top-down loop. |
| 11 | The fork's Pins MINOR 17 matches upstream's number by coincidence. | The C4 comment covers it. The next sync takes 18 or higher. |

## 9. Contracts with other areas

**Area A (hover arbitration).**
- *I provide:*
  - The `MinimapLayer.Hover(x?, y?)` callback.
    - Its cursor rules: focus is `Minimap`, inside the shape unless square, the minimap's UI scale, and secret values give nil.
    - It is called top layer first, only when the cursor moved against the drawing.
    - It is guaranteed `Hover(nil)` on minimap hide, position loss, an inactive layer, or an error (through `Clear`).
  - `MinimapCanvas.Unproject` for world yards, landing with A's first caller.
  - Today only paths implement `Hover`.
- *I assume:*
  - A keeps minimap path hover in `WaypointHover`.
  - A gives areas no minimap hover unless it adds one through this hook.
  - A may change the focus rule or the top-down claiming in the canvas.

**Area B (tooltip API).** Nothing new. The canvas never touches tooltips.

**Area C (quest drawing).**
- *I provide:*
  - `PolygonMinimap.New(collect)`, with no minimap parameter, returning plain `Invalidate` and `Clear`.
  - C2 edits B `QuestiePolygon.lua:380, 517, 1010` and `QuestiePolygon.test.lua:88`. Coordinate if C restructures those lines.
- *I assume C keeps the links the layers read:*
  - `icon.minimapTwin` for paths (WP `QuestieWaypoints.lua:137-139`). Finding 4: fallback markers need it, or their paths never reach the minimap.
  - `marker.minimapIcons[1].frame.polygonMinimapMarker == marker` for areas (B `QuestiePolygon.lua:306-311`).
  - Calls to `WaypointMinimap.Invalidate` (through `QuestieWaypoints._Changed`) and `QuestiePolygon.ScheduleRefresh` on every relevant change.
- C rewords `Polygon/README.md:16` and owns whether `Questie:OnDisable` releases paths.

**Area E (geometry and scheduling).**
- *I own:* the projection math (`Project`, `Unproject`, `InReach`, `REACH`, `DRIFT`).
- *I assume:*
  - World bounds stay `{minX, minY, maxX, maxY}` arrays (`WaypointPath.worldBounds`, `PolygonWorldOutline.bounds`). Otherwise E updates `InReach` in the same commit.
  - Minimap drawing stays synchronous inside the canvas update, since reach bounds it, and outside E's coroutine budget. If E wants it budgeted, the canvas's per-layer `Draw` loop is the single place to add it.
- Shared helpers that the layers use (`WaypointGeometry.Nearest`, `Bounds`, `_IsFinite`) live wherever E puts them. The canvas does not depend on them.
