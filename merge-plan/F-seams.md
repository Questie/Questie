# Area F: shared map seams

The seams that keep the drawing features (patrol paths, quest areas, and any future drawing module) black boxes to each other and to core, as decided in `01-architecture.md`:
- **`WorldMapLayers`**, one hover stack for what Questie draws on the world map;
- **`QuestieFrame`'s icon events**, so core never names a feature;
- **the written `IconFrame` contract**;
- **the import guard**, which keeps it that way;
- the optional **`Polygon/` → `Modules/Map/Polygon/`** move.

`MinimapCanvas` (Area D) and `MapGeometry` (Area E) are the other two seams. Section 3.2 aligns the minimap stack with the world map one.

- **Refs:** `WP` = `origin/waypoints` `7c1e28bd8`. `B` = blob's code at `715031ef6` (`blob` is now `e71e6dd38`, which adds only `merge-plan/`). Line numbers were checked against these commits.
- **Blizzard source:** the repo's `WoW-API/_UI` (WoWUI `vanilla` @ `b6c8bf01`), plus the Forever and Era citations Areas A and E verified.
- **Prototyped**, in `git archive` exports of both refs under the session scratchpad. Nothing in either checkout was changed.
  - **Waypoints side:** `WorldMapLayers` and its test, the paths layer, the icon events, hover start in `QuestieFrame`, `QuestieWaypoints.Redraw` and the import guard. 1,054 tests pass in `Modules/Map`, `FramePool`, `Tooltips`, `Tracker`, `Quest`, `Options`, `EventHandler`, `QuestieCompat.test.lua`, `Questie.test.lua` and the guard, and luacheck is clean.
  - **Blob side:** the areas layer. `PolygonRenderer` 52, `QuestiePolygon` 85, `PolygonRenderCache` + `PolygonMinimap` 37, and `QuestieQuest` + `TrackerUtils` 104 pass. luacheck is clean.

**In one paragraph.** One poller reads the world map cursor and offers it to the drawn layers top down. Each layer draws at a level taken from the same ordered table, so "paths win over areas" holds by construction. That replaces both world map pollers and the first Area A plan's `WaypointMap.IsMapUncovered` import. `QuestieFrame` emits five icon events: `Unload`, `VisibilityChanged`, `HoverStart`, `HoverEnd` and `Click`. Each feature subscribes when it first draws. After that, `QuestieFrame`, `QuestieFramePool`, `GamepadMapHover` and `MapIconTooltip` import no feature. Core keeps 11 entry points, in 8 files, into the two features' adapters (`QuestieWaypoints`, `QuestiePolygon`), listed in the guard test, and a test fails on anything else. The Phase 1 rebase recipes don't change. Six seam commits open Phase 2, and they absorb A1, A2, A4 and B-F4 and fix N3 and N5.

---

## 1. Problem

### 1.1 Two world map hover pollers

| | WP `WaypointMap` | B `PolygonRenderer` + `QuestiePolygon` |
|---|---|---|
| Driver | A frame on the canvas whose `OnUpdate` draws, restyles and then hovers (`WP Modules/Map/Waypoints/WaypointMap.lua:153-188`) | One `hoverDriver` per renderer, polling only while views are visible (`B Polygon/PolygonRenderer.lua:191-240`) |
| Cursor | Canvas units: normalized × `shownWidth`/`shownHeight` (`:117-123`). Reach is `WaypointHover.Radius() / currentScale` (`:139`). | Percent: normalized × 100 (`B PolygonRenderer.lua:149-156`). Outlines are in map percent. |
| When | When the cursor moved, after a redraw, or every frame while zoom eases (`:174-175`) | When the cursor's canvas position changed (`:193-196`), and on every publication (`:452`) |
| Covered map | `GetMouseFocus() == ScrollContainer` (`:125-129`) | `focus == scrollContainer or QuestieFramePool.IsLineFrame(focus)` (`B Polygon/QuestiePolygon.lua:998-1001`) |
| Gamepad UI | Not checked: paths open GameTooltip from `OnUpdate` (A's P4) | `InputUtil.IsGamepadUIEnabled()`, unguarded (`B QuestiePolygon.lua:345-346`). It crashes on Era, Anniversary and Progression, where `InputUtil` exists without that function (**N3**). `WoW-API/_UI/Blizzard_SharedXML/InputUtil.lua` defines only `GetCursorPosition` and `AnchorRegionToCursor`. |
| Ending | The driver's `OnHide` calls `WaypointHover.Set("map", nil)` (`:184-187`) | The driver's `OnHide` resets hover and highlights (`:221-226`) |
| Order | Paths at a hard-coded 2015 (`:17-18`) | Areas at `PIN_FRAME_LEVEL_QUEST_BLOB`, read in `Refresh` (`B QuestiePolygon.lua:283`): 2004 on Era, 2007 on Forever |

Combined, the two drivers run in an undefined order, each with its own view of what covers the map:
- `IsLineFrame` is gone (finding 1).
- Over a path that crosses an area, both hover and fight over GameTooltip (finding 7, A's P2 and P3).
- The first Area A plan fixed this by importing `WaypointMap` into `QuestiePolygon`, which is one feature importing another. Architecture rule 1 now forbids that.

### 1.2 Core calling features by name

Every direct call from core's icon code into a feature, on both branches:

| Core site | WP | B |
|---|---|---|
| `QuestieFrame` import | `QuestieWaypoints` (`WP QuestieFrame.lua:18-19`) | `QuestiePolygon` (`B QuestieFrame.lua:18-19`) |
| `_QuestieFrame.OnLeave` | — | `QuestiePolygon.LeaveMarker(self)` (`B :141`) |
| `QuestieFrame.ResetHoverHighlights` | `QuestieWaypoints.SetHighlighted(self.data, false)` (`WP :156`) | the `lineFrames` recolor (`B :157-162`, deleted by the rebase) |
| `_QuestieFrame.OnClick`, a left-click on its own map | — | `QuestiePolygon.ToggleMarker(self)` (`B :204-205`) |
| `BaseOnShow` / `BaseOnHide` | — | `QuestiePolygon.ScheduleRefresh()` for a marker (`B :286`, `:292`) |
| `_QuestieFrame.Unload` | `QuestieWaypoints.RemoveOwner(self)` after the draw-queue deferral (`WP :385`) | `MarkerRemoved` and `MinimapMarkerRemoved` *before* the deferral (`B :362-363`) |
| `FadeOut` / `FadeIn` | `QuestieWaypoints.OwnerChanged(self)` (`WP :410`, `:422`) | `QuestiePolygon.MarkerChanged(self)` for a marker (`B :423`, `:443`) |
| `FakeHide` / `FakeShow` | `OwnerChanged` (`WP :441`, `:457`) | `MarkerChanged` for a marker or its minimap icon (`B :479`, `:492`) |
| `QuestieFramePool` | `CreateIconFrame(numberOfFrames, MapIconTooltip.Show)` (`WP QuestieFramePool.lua:56`); clears `minimapTwin` (`:134`) | only the line model (`IsLineFrame` `:150-160`), deleted by the rebase |
| `GamepadMapHover` (the same on both) | `ResetHoverHighlights({data = hoveredData})` (`Modules/Map/GamepadMapHover.lua:114`), so a marker's preview never ends (**N5**) | the same |
| `MapIconTooltip` | imports `QuestieWaypoints` and `WaypointHover` (`WP MapIconTooltip.lua:30-33`); `WaypointHover.End(self)` (`:67`); `SetHighlighted(self.data, true)` (`:117`) | imports `QuestiePolygon` (`B :32-33`); `EnterMarker(self)` (`B :79`) |

After the rebase, `QuestieFrame` imports both features and calls nine feature functions, and `MapIconTooltip` imports three feature modules. A third drawing module would edit all of these call sites.

### 1.3 Feature state on core frames

| Field | Written by | Read by |
|---|---|---|
| `icon.minimapTwin` | `WP QuestieMap.lua:592`, `:690`; cleared `WP QuestieFrame.lua:386`, `QuestieFramePool.lua:134` | `WP QuestieWaypoints.lua:137`, `:150`; `WaypointMinimap.lua:309` |
| `data.waypointPaths` | `WP QuestieWaypoints.lua:67-68` | `:94`, `:108`, `:186`. Declared in core: `WP QuestieFrame.lua:38` |
| `frame.polygonMarker`, `polygonMinimapMarker` | `B QuestiePolygon.lua:1032`, `:1044` (23 sites in all) | `B QuestieFrame.lua` (12 sites), `B QuestieQuest.lua:1392`, `PolygonNudging.lua:156`, `:196`. Declared in core: `B QuestieFrame.lua:53-54` |
| `frame.OnWorldMapPinUpdated` | `B PolygonNudging.lua:146`, `:195` | Questie's HereBeDragons-Pins fork (`B HereBeDragons-Pins-2.0.lua:508-509`, `:516-517`) |
| `data.touchedPins` | `MapIconTooltip` (`WP :137`, `B :130`) | `QuestieFrame.ResetHoverHighlights` |
| `frame._loaded`, `_hidden_by_flash` | core (`QuestieMap.lua` ProcessQueue; `TrackerUtils.lua:206`) | `B QuestiePolygon.lua:227` |

### 1.4 Core → feature imports

These were found by scanning every TOC-listed file. The guard prototype in 3.7 reproduces both lists exactly, and finds no feature importing another on either branch.

| Branch | Core file:line → module |
|---|---|
| WP | `QuestieFrame.lua:19` QuestieWaypoints · `QuestieMap.lua:26` QuestieWaypoints · `QuestieOptionsAdvanced.lua:28` QuestieWaypoints · `QuestieOptionsMap.lua:9` QuestieWaypoints, `:11` WaypointRenderer · `MapIconTooltip.lua:31` QuestieWaypoints, `:33` WaypointHover · `TrackerUtils.lua:45` QuestieWaypoints · `Questie.lua:28` WaypointRenderer, `:30` QuestieWaypoints |
| B | `QuestieFrame.lua:19` · `QuestieMap.lua:26` · `QuestieOptionsIcons.lua:26` · `QuestieQuest.lua:25` · `MapIconTooltip.lua:33` · `TrackerLine.lua:36` · `TrackerUtils.lua:35` · `Questie.lua:18`, all QuestiePolygon |

Test files also import feature modules, to stub them. The guard scans shipped (TOC-listed) files only.

---

## 2. Comparison

**Hover polling.**
- **WP's strengths:**
  - canvas units, which measure isotropically;
  - a reach that stays the same size on screen;
  - an exact focus rule;
  - a recheck after every redraw.
- **WP's weaknesses:** no gamepad rule, and drawing and hover share one driver, so a second layer couldn't join.
- **B's strengths:**
  - a renderer that hovers every containing outline, with a `changed` flag that the area tooltip uses to rebuild only on change;
  - a local recheck on publication;
  - secret-value guards.
- **B's weaknesses:**
  - an `IsLineFrame` focus exception;
  - an unguarded gamepad call;
  - a poller owned by the renderer, so precedence can only be fixed by importing the other feature.
- **Keep from WP:** canvas units, reach divided by scale, the focus rule, and recheck on redraw.
- **Keep from B:** pushing a cursor into the renderer's own hit test and highlight union, the `changed` signal, and secret-value guards.
- **Drop:** per-feature pollers, `isCursorOnMap`, `getCursorPosition` and `IsLineFrame`.

**Icon lifecycle hooks.**
- WP's calls are unconditional and the feature filters: `OwnerChanged` checks `data.waypointPaths[1]`.
- B's calls are guarded by fields, and B's comment insists they are "called by the existing icon lifecycle, never installed as accumulating frame hooks" (`B QuestiePolygon.lua:531-532`).
- **Keep:** WP's "the feature filters" and B's "no per-frame hooks". Events are subscribed once per feature, not per frame.
- **They disagree on unload timing.** B releases a marker when a still-queued icon *defers* its unload. WP releases paths when the unload *finishes*.
- **One moment is needed, and the finished unload is the right one.** Only then may the pool hand the frame out, and routes added to a queued frame after the deferral are released with it. See decision F-3 in section 8.

---

## 3. Target design

### 3.1 The shape

```text
 Core: QuestieQuest · QuestieMap · QuestieFrame · MapIconTooltip · Tracker · Options · Questie.lua
         │ 11 entry points (3.6), adapters only     ▲ Unload · VisibilityChanged · HoverStart · HoverEnd · Click
         ▼                                          │
 Seams (know no feature):  WorldMapLayers (F) · MinimapCanvas (D) · MapGeometry (E) · IconFrame contract (F)
         ▲                                          ▲
   Modules/Map/Waypoints/*                 Polygon/* (→ Modules/Map/Polygon/*)     (future: Modules/Map/<Name>/*)
         └────────── never import each other: test/MapFeatureImports.test.lua ──────────┘
```

A feature is a folder of its own, and its **adapter** (`QuestieWaypoints`, `QuestiePolygon`) is the only module core imports. A feature joins the seams when it first draws:
- it subscribes to icon events;
- it adds its map layers.

Until then it costs nothing per frame or per event.

### 3.2 `WorldMapLayers`

**Module:** `Modules/Map/WorldMapLayers.lua`, core, imports only `QuestieCompat`. It is loaded by all six TOCs after `Modules\Map\Moonwell.lua`, next to `MapGeometry` and `MinimapCanvas` in any order. Its only file-scope work is creating locals.

#### API (final, as prototyped)

```lua
-- luacheck: read globals issecretvalue
---Hover for what Questie draws on the world map's canvas beneath its icons: quest areas and patrol
---paths. Each drawing feature adds a layer and keeps its own drawing. One poller reads the cursor
---while the map is open and offers it to the layers top down: a layer drawn above another wins the
---cursor over it, as everything with mouse focus above the map, such as Questie's icons, Blizzard's
---pins and other UI, wins over every layer. Nothing here takes mouse input or calls protected API.
---@class WorldMapLayers
local WorldMapLayers = QuestieLoader:CreateModule("WorldMapLayers")

---@alias WorldMapLayerName "areas"|"paths"

---Where the cursor is on the world map's canvas. A fresh table for each offer.
---@class WorldMapCursor
---@field mapId number The shown map. A layer hovers only what it drew for this map.
---@field x number Canvas units right of the canvas's left edge.
---@field y number Canvas units below its top edge.
---@field width number The canvas's size in canvas units: x / width * 100 is map percent.
---@field height number
---@field scale number The canvas's zoom. A reach measured on screen, in map UI units, is that many canvas units divided by scale.

---One kind of drawing on the world map. The stack only orders the layers and hovers them.
---@class WorldMapLayer
---@field Hover fun(cursor: WorldMapCursor?): boolean Hovers what lies under the cursor and returns whether anything does; the layers beneath then get nil. nil ends the layer's hover.

---Adds a feature's layer at its place in the stack; hover starts with the next frame the map is open.
---@param name WorldMapLayerName
---@param layer WorldMapLayer
function WorldMapLayers.AddLayer(name, layer) end

---The layer's drawing changed, so what lies under a still cursor may have too: offer the cursor again
---on the next frame. A layer whose Hover failed is offered it again from then on.
---@param name WorldMapLayerName
function WorldMapLayers.Invalidate(name) end

---The frame level the layer's drawings use, so it draws in the order it hovers.
---@param name WorldMapLayerName
---@return number
function WorldMapLayers.FrameLevel(name) end
```

#### Ordering: one table, keyed by name

```lua
-- The layers, bottom to top. Each draws above the ones before it and wins the cursor over them, so
-- draw order and hover order both come from this table. A new drawing feature adds one row.
---@type {name: WorldMapLayerName, FrameLevel: fun(): number}[]
local LAYER_ORDER = {
    -- Blizzard's own level for quest areas: 2004 on Era and 2007 on Forever, where more pin types come first.
    {name = "areas", FrameLevel = function()
        return WorldMapFrame:GetPinFrameLevelsManager():GetValidFrameLevel("PIN_FRAME_LEVEL_QUEST_BLOB")
    end},
    -- Just below Questie's icons, which start at 2016 (QuestieMap.utils.SetDrawOrder).
    {name = "paths", FrameLevel = function() return 2015 end},
}
```

- **The ordering key is the row's position**, never a frame level. Layers ask `FrameLevel(name)` for their level.
  - The paths' `FRAME_LEVEL` (`WP WaypointMap.lua:17-18`) is deleted.
  - So is the areas' direct read (`B QuestiePolygon.lua:283`).
  - Both then derive from this table, so a client whose quest-blob level moves can't reorder hover against drawing.
- **Evidence for the levels:**
  - `QUEST_BLOB` is the fourth `AddFrameLevel` on Era (`WoW-API/_UI/Blizzard_WorldMap/Vanilla_Blizzard_WorldMap.lua:225-228`), and the manager starts at 2000 (`MapCanvas_PinFrameLevelsManager.lua:8`, `:70-79`).
  - Forever's 2007 is Area E's citation (`forever Blizzard_WorldMap/Blizzard_WorldMap.lua:271-278`).
  - Icons start at 2016 (`WP QuestieMapUtils.lua:53-56`).

#### The single poller

- **Where it runs:** a plain `Frame` parented to `WorldMapFrame:GetCanvas()`, created by the first `AddLayer`. It runs `OnUpdate` only while the map is open, the same lifetime as WP's draw driver.
- **What each frame costs:** `canvas:IsMouseOver()`, `ScrollContainer:GetNormalizedCursorPosition()`, `issecretvalue` (×2) and `GetCanvasScale()`. That is fewer reads than the two pollers it replaces.
- **When it offers the cursor:** only when one of these changed since the last offer:
  - the normalized position;
  - the zoom (cursor-anchored zoom keeps the canvas point but not a reach measured on screen);
  - a layer called `Invalidate`.

  UI appearing over a still cursor is noticed on the next move, as on both branches today.

```lua
local function _IsFinite(value) -- One line, kept file-local as E 2.1 row 1 advises.
    return type(value) == "number" and value > -math.huge and value < math.huge
end

local function _Poll()
    local x, y, scale
    if WorldMapFrame:GetCanvas():IsMouseOver() then
        x, y = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()
        -- Secret values cannot even be compared; a canvas not laid out yet normalizes to NaN or infinity.
        if (issecretvalue and (issecretvalue(x) or issecretvalue(y))) or not (_IsFinite(x) and _IsFinite(y)) then
            x, y = nil, nil
        end
        scale = WorldMapFrame.ScrollContainer:GetCanvasScale()
    end
    if not dirty and x == lastX and y == lastY and scale == lastScale then return end
    dirty, lastX, lastY, lastScale = false, x, y, scale
    _Offer(x and _Cursor(x, y, scale) or nil)
end
```

- **On `OnHide`** (the map closes): every layer that had the cursor gets `Hover(nil)`. The last cursor is forgotten and `dirty` is set.
- **On error:** an error in `_Poll` itself is reported. Every hover ends, and polling stops until the map opens again (`OnShow`).

#### Cursor contract: canvas units, with the size and zoom alongside

`WorldMapCursor` carries canvas units (isotropic, y down), plus `width`, `height`, `scale` and `mapId`, and each layer converts in one line:
- **Paths** hit-test as today: `WaypointGeometry.Nearest(visible, cursor.x, cursor.y, WaypointHover.Radius() / cursor.scale)`.
  - They hover only geometry drawn for `cursor.mapId` and that canvas size.
  - So a one-frame race with WaypointMap's own redraw can't hover the previous map's paths.
- **Areas** convert to the outlines' map percent: `cursor.x / cursor.width * 100`. Containment doesn't depend on per-axis scale (E 2.5).

Normalized coordinates alone were rejected, because paths would then need the size and zoom from somewhere else, read in a different frame.

#### Bare-map and gamepad rules

These are applied once, in `_Cursor`, before any layer sees the cursor:

```lua
local function _Cursor(x, y, scale)
    -- The gamepad cursor is not the mouse's, and GameTooltip from per-frame code taints the gamepad UI.
    if QuestieCompat.IsGamepadUIEnabled() then return nil end
    -- Paths and areas take no mouse input: only the bare map lets them hover.
    if QuestieCompat.GetMouseFocus() ~= WorldMapFrame.ScrollContainer then return nil end
    local canvas = WorldMapFrame:GetCanvas()
    local width, height = canvas:GetWidth(), canvas:GetHeight()
    if not (width > 0 and height > 0) then return nil end
    return {mapId = WorldMapFrame:GetMapID(), x = x * width, y = y * height, width = width, height = height, scale = scale}
end
```

`QuestieCompat.IsGamepadUIEnabled()` is new, next to `GetMouseFocus` (`WP Modules/QuestieCompat.lua:292`):

```lua
---Whether the gamepad UI is on: then the gamepad cursor, not the mouse's, points at the map. Only
---Forever's InputUtil has IsGamepadUIEnabled; every Classic client loads an InputUtil without it.
---@return boolean
function QuestieCompat.IsGamepadUIEnabled()
    return (InputUtil and InputUtil.IsGamepadUIEnabled and InputUtil.IsGamepadUIEnabled()) == true
end
```

- **This fixes N3** by construction: the areas' unguarded call is deleted (F-2), and both stacks share this capability check.
- **Other callers:** `GamepadMapHover.IsActive` (`:60`) and `TrackerUtils.lua:92` are already safe (they run only on Forever). They may switch to it, but nothing needs them to.

#### Dispatch: top down, first hit wins, nil once

```lua
local function _Offer(cursor)
    local claimed = false
    for i = #LAYER_ORDER, 1, -1 do
        local state = states[LAYER_ORDER[i].name]
        if state and not state.failed then
            if cursor and not claimed then
                state.offered = true
                claimed = _Hover(state, cursor)
            elseif state.offered then
                state.offered = false
                _Hover(state, nil)
            end
        end
    end
end
```

- **`Hover(nil)` reaches a layer exactly once** when it stops getting the cursor:
  - a layer above claimed it;
  - the cursor left the bare map;
  - the gamepad UI is on;
  - the map closed;
  - the layer failed.

  This guarantee matters to the areas: the renderer keeps the last cursor so that areas published under a still cursor hover at once. A layer that never had the cursor is not called.
- **The "hover changed" signal comes in two parts:**
  - The stack's change detection is the *look again* signal. Layers are called only when the cursor, the zoom or a drawing changed, never every frame under a still cursor. That keeps E's cost bound and B's invariant 6 (`ShowForIcons` only on change).
  - *What* is hovered changing is each layer's own answer:
    - `WaypointHover.Set` ignores the same path (`WP WaypointHover.lua:109-114`);
    - `PolygonRenderer` passes `changed` to `onHover` (`B PolygonRenderer.lua:85-93`, `:185-188`);
    - the area tooltip rebuilds only on `changed`, or to take the tooltip back.
- **Per-layer error isolation:**

  ```lua
  local function _Hover(state, cursor)
      local ok, hovered = pcall(state.layer.Hover, cursor)
      if ok then return hovered == true end
      Questie.Error("World map " .. state.name .. " hover failed:", hovered)
      state.failed, state.offered = true, false
      pcall(state.layer.Hover, nil)
      return false
  end
  ```

  A failed layer is reported and its hover ended. It is skipped until its next `Invalidate`, and the layers beneath it keep hovering. This is the same rule as D's `_Call`.

#### Combat, taint, and never yielding

- **No protected calls.** Nothing takes mouse input, and nothing calls protected API. The poller reads only cursor, focus, zoom and size.
- **Focus is compared by identity only**, so a restricted focus frame is never touched.
- **GameTooltip:** a layer may open GameTooltip only from `Hover`, and the stack never offers the cursor in the gamepad UI. That covers the taint behind master `ae8410da8` and `00f19de8f` (A's P4).
- **`Hover` runs inside `OnUpdate`:**
  - It must not yield or call an `---@async` function; this is E's presentation tier.
  - Its work, such as `MapIconTooltip.ShowForIcons`, must happen only when its answer changes.

#### Symmetry with `MinimapCanvas`

| | `WorldMapLayers` (F) | `MinimapCanvas` (D) |
|---|---|---|
| Owns | order, frame levels, one cursor poller, hover dispatch | that, plus the root, masks, projection and per-layer containers |
| Draws | nothing: each feature draws on Blizzard's canvas | nothing: each layer draws into its container |
| Order | `LAYER_ORDER` rows `{name, FrameLevel}` | `LAYER_ORDER` names; the container levels follow |
| Registration | `AddLayer(name, layer)` | `AddLayer(name, layer) → container, masks` |
| Recheck | `Invalidate(name)`: offer the cursor again; resumes a failed layer | `Invalidate(name)`: collect again; resumes a failed layer |
| Hover | `Hover(cursor?) → boolean`, top first, claim; nil once | **rename:** `Hover(x?, y?) → boolean` with the same claim and nil-once rule |
| Ends hover on | map hide, cover, gamepad UI, error | minimap hide, position loss, inactive, error, **and the gamepad UI** |

No module rename is needed. `MinimapCanvas` owns a real surface; `WorldMapLayers` draws on Blizzard's. **D's API changes in exactly two ways** (section 10):
- `MinimapLayer.Hover` returns whether it hovers something, and the canvas gives the layers beneath nil once;
- `_ReadCursor` returns nil in the gamepad UI through `QuestieCompat.IsGamepadUIEnabled()`.

#### Migration

**Paths (F-1):** `WaypointMap` registers in `_CreateDriver`, as prototyped:

```lua
---The path within hover reach of the cursor, the nearest where reaches overlap; nil until the paths
---are drawn for the cursor's map and canvas size.
---@param cursor WorldMapCursor
---@return WaypointMapView?
local function _PathAt(cursor)
    if not visible[1] or cursor.mapId ~= shownMapId or cursor.width ~= shownWidth or cursor.height ~= shownHeight then
        return nil
    end
    return WaypointGeometry.Nearest(visible, cursor.x, cursor.y, WaypointHover.Radius() / cursor.scale)
end

---@type WorldMapLayer
local layer = {
    Hover = function(cursor)
        local nearest = cursor and _PathAt(cursor)
        local path = nearest and nearest.path
        WaypointHover.Set("map", path, path and path.owner)
        return path ~= nil
    end,
}
```

- **`_Update`:** its last line becomes `if changed then WorldMapLayers.Invalidate("paths") end`.
- **`_Style`:** uses `WorldMapLayers.FrameLevel("paths")`.
- **Deleted from `WaypointMap.lua`:**
  - the `issecretvalue` header (`:1`);
  - the `QuestieCompat` import (`:14-15`);
  - `FRAME_LEVEL` (`:17-18`);
  - `cursorX, cursorY` (`:42-43`);
  - `_ReadCursor` (`:114-123`);
  - `_IsCursorOnMap` (`:125-129`);
  - `_UpdateHover` (`:131-143`);
  - the driver's `OnHide` script (`:183-187`).
- **Moved:** the driver comment (`:145-147`) drops "follows the cursor".

**Areas (F-2):**
- **`PolygonRenderer`** stops polling. It gains `Renderer:Hover(x, y) → boolean`, which stores the cursor (map percent, or nil) and runs `UpdateHover`. `UpdateHover` reads the stored cursor, and `SetVisibleFrames` still rechecks it.
- **Deleted from `PolygonRenderer`:**
  - `PolygonHoverInput.getCursorPosition` and `.isCursorOnMap` (`B PolygonRenderer.lua:35-36`);
  - `_ReadCursor` (`:144-156`);
  - `_PollHover` (`:191-196`);
  - the `OnUpdate` install and removal in `_SyncHoverDriver` and `Clear` (`:207-211`, `:221-223`, `:232-238`, `:498-504`);
  - the `hoverPolling` field (`:28`).
- **Kept in `PolygonRenderer`:** the driver frame, for its hide and show lifecycle, which marker-only highlights on the minimap still need (`:198-199`).
- **`QuestiePolygon`'s provider block** (`B :989-1003`) becomes:

```lua
        local renderer = PolygonRenderer.New(WorldMapFrame:GetCanvas(), {onHover = _UpdateAreaTooltip})
        -- Areas draw beneath patrol paths and Questie's icons, and hover only where nothing above covers the map.
        WorldMapLayers.AddLayer("areas", {
            Hover = function(cursor)
                -- Outlines are in map percent.
                if not cursor then return renderer:Hover(nil, nil) end
                return renderer:Hover(cursor.x / cursor.width * 100, cursor.y / cursor.height * 100)
            end,
        })
```

- **`Refresh`:** passes `WorldMapLayers.FrameLevel("areas")` to `Present` (replacing `:283`), then calls `WorldMapLayers.Invalidate("areas")`.
- **`_UpdateAreaTooltip`** drops `QuestieCompat.GetMouseFocus() ~= owner` and the `InputUtil` clause with its comment (`:343-346`). Its guard becomes `#shapes == 0 or Questie.db.profile.polygonAreaTooltips == false`.
- **Also deleted from `QuestiePolygon`:** the `isCursorOnMap` and `getCursorPosition` closures and their comment (`:989-1001`), and the `QuestieCompat` import (`:55-56`).

### 3.3 `QuestieFrame` icon events

#### The event set, mapped from every call in 1.2

| Event | Emitted from (after F-3/F-4) | Waypoints listener | Polygon listener |
|---|---|---|---|
| `Unload` | `_QuestieFrame.Unload`, once, after the draw-queue deferral (WP's `RemoveOwner` spot), while `data` and `minimapTwin` are still set | `QuestieWaypoints.RemoveOwner` | `MarkerRemoved` then `MinimapMarkerRemoved` |
| `VisibilityChanged` | `FadeOut`, `FadeIn`, `FakeHide`, `FakeShow`, and native `BaseOnShow`/`BaseOnHide` | `QuestieWaypoints.OwnerChanged` | `QuestiePolygon.MarkerChanged` |
| `HoverStart` | `QuestieFrame.ApplyHoverHighlights(icon)`, before the core tint | `WaypointHover.End(icon)`, then `SetHighlighted(icon.data, true)` | `QuestiePolygon.EnterMarker` |
| `HoverEnd` | `QuestieFrame.ResetHoverHighlights(icon, data)`, after the core untint | `SetHighlighted(data, false)` | `LeaveMarker(icon)` only while `icon.data == data` |
| `Click` | `_QuestieFrame.OnClick`: a plain left-click on a world map icon on its own map (`B :201-206`'s branch), where core does nothing else | — | `QuestiePolygon.ToggleMarker` |

Rule 3 named four events, and this design adds `Click`, plus native show and hide inside `VisibilityChanged`. Without them, `QuestieFrame` keeps importing `QuestiePolygon` for `ToggleMarker` and `ScheduleRefresh`. They are decisions F-1 and F-2 in section 8.

#### API and types (in `QuestieFrame.lua`, before `CreateIconFrame`)

```lua
-- Icon events
-- Drawing features follow icons through these events; QuestieFrame never names a feature. Each
-- listener runs in a pcall: an error is reported once per listener, and never stops the other
-- listeners or the icon's own work, such as an unload that must finish whatever a feature does.

---@alias IconEvent
---| "Unload" # The icon unloads. Afterwards the pool may hand it out for other data.
---| "VisibilityChanged" # It was shown or hidden, natively or by FakeHide/FakeShow, or faded in or out.
---| "HoverStart" # The cursor or the gamepad cursor started hovering it.
---| "HoverEnd" # That hover ended; the listener also gets the data the hover started with.
---| "Click" # A plain left-click on a world map icon on its own map, which Questie leaves to features.

---@type table<IconEvent, fun(icon: IconFrame, data: IconData?)[]>
local listeners = {Unload = {}, VisibilityChanged = {}, HoverStart = {}, HoverEnd = {}, Click = {}}
---@type table<function, true>
local reported = {}

---@param event IconEvent
---@param icon IconFrame
---@param data IconData?
local function _Emit(event, icon, data)
    local list = listeners[event]
    for i = 1, #list do
        local listener = list[i]
        local ok, err = pcall(listener, icon, data)
        if not ok and not reported[listener] then
            reported[listener] = true
            Questie.Error("Icon " .. event .. " listener failed:", err)
        end
    end
end

---Calls listener whenever `event` happens to any icon, after the listeners subscribed before it. A
---listener must not rely on that order, and must be cheap: VisibilityChanged comes for every icon
---the maps show or hide.
---@param event IconEvent
---@param listener fun(icon: IconFrame, data: IconData?)
function QuestieFrame.Subscribe(event, listener) end
```

#### Hover start and end: folding A4 and B-F4

```lua
---Starts what hovering an icon shows besides its tooltip: each feature's HoverStart listeners, such
---as its NPC's path highlight or a polygon marker's area preview, then the tint on its quest's other
---world map icons. Listeners run first, so a path hover they end restores its tints before these
---colors are saved. ResetHoverHighlights undoes it all.
---@param icon IconFrame
function QuestieFrame.ApplyHoverHighlights(icon) end

---Undoes what hovering an icon changed: the tint on its quest's icons, then each feature's HoverEnd
---listeners. Every way an icon hover ends calls it: the icon's OnLeave, a path hover ending
---(WaypointHover) and the gamepad cursor moving on (GamepadMapHover).
---@param icon IconFrame The hovered icon. It is pooled, so it may show other data by now.
---@param data IconData? The data it was hovered with; icon.data when nil.
function QuestieFrame.ResetHoverHighlights(icon, data) end

---The icon's OnEnter. An icon faded out to nothing is not there to hover: it starts no hover and
---shows no tooltip.
---@param self IconFrame
function _QuestieFrame.OnEnter(self)
    if select(4, self.texture:GetVertexColor()) == 0 then return end
    QuestieFrame.ApplyHoverHighlights(self)
    MapIconTooltip.ShowOnTooltip(self, GameTooltip)
end
```

- **The names.** The pair keeps `ApplyHoverHighlights`/`ResetHoverHighlights`, the README's standard. B's `HighlightHover` is not used.
- **A4's `(icon, data)` signature** becomes the `HoverEnd` payload. The recycled-icon guard (`icon.data == data`) moves into the polygon listener, because it is polygon's marker identity.
- **B-F4's relocation becomes `HoverStart`:**
  - The tint moves from `MapIconTooltip` into a file-local `_TintQuestIcons(icon)` in `QuestieFrame`, with B-F3's guard ("tint only while `data.touchedPins` is nil").
  - It skips minimap icons and keeps the old filter: other hidden or alpha-0 icons are not tinted.
- **`WaypointHover.End` runs inside the waypoints `HoverStart` listener.** It is a no-op when the icon is the path's own `enteredIcon` (`WP WaypointHover.lua:125-127`), so the path-to-icon handoff is unchanged.
- **Who calls the pair:**
  - the mouse `OnEnter`/`OnLeave`;
  - `GamepadMapHover.Enter`/`Leave`;
  - `WaypointHover`'s world map branch, through the icon's own `OnEnter`/`OnLeave`. When another frame took the tooltip, it calls `ResetHoverHighlights(icon, path.data)` instead.
- **What isn't an icon hover:** the minimap path hover highlights its own paths (`WP WaypointHover.lua:48`), and areas start no hover effects (A's D6).

#### Ordering guarantees

1. Listeners run in subscription order. No listener may depend on it, because they belong to different black-box features.
2. All `HoverStart` listeners run before the core tint, and the core untint runs before `HoverEnd` listeners. This prevents the F3 hazard: a path hover ended by `WaypointHover.End` restores its tints before the new tint saves colors.
3. `Unload` fires exactly once per unload, when it finishes. A still-queued icon defers, and the event comes from `ProcessQueue`'s second call (`WP QuestieMap.lua:359-362`, `:372-375`). Listeners run while `icon.data` and `icon.minimapTwin` are still set, and the pool can't recycle the frame before they return.
4. `VisibilityChanged` may come spuriously, or twice for one change: `FakeShow` emits, and its native `Show` emits too. Listeners re-read state and are idempotent. Both features' listeners already coalesce: dirty flags and `ScheduleRefresh`.
5. Emitting is re-entrant. A `HoverStart` listener may end another icon's hover, which emits `HoverEnd`. A marker's `Unload` unloads its minimap icons, which emit `Unload`.

#### Error isolation

A failing listener must never break an icon's unload. If it did, the icon would stay registered with HereBeDragons and pooled, and the other feature's state would leak. So each listener runs under `pcall`, and its first error is reported through `Questie.Error`, once per listener per session. It keeps receiving events: skipping an `Unload` would leak whatever it owns.

#### Hot-path cost

`VisibilityChanged` fires for every icon HereBeDragons shows or hides, which can be hundreds on map open. Measured offline in Lua 5.1.5 on a desktop:
- **Direct calls:** today's two field checks cost 0.066 µs per icon.
- **Events:** the `pcall` dispatch to the two listeners costs 0.195 µs. That is +0.13 µs per icon event, or about 0.13 ms for 1,000 icons unloading.
- **Coalescing:** downstream work is already coalesced into one redraw per frame.
- **Native show and hide** add a few redundant invalidations:
  - waypoints restyle in-reach routes when a patrol NPC's minimap icon crosses the minimap edge;
  - polygon schedules one nudge pass, signature-checked, on map open.

#### Where each feature subscribes: on first use, inside itself

```lua
-- QuestieWaypoints.lua: paths follow their owners from the first path on.
-- Add calls `if not followingIcons then _FollowIcons() end` after its early returns.
local followingIcons = false

local function _FollowIcons()
    followingIcons = true
    QuestieFrame.Subscribe("Unload", QuestieWaypoints.RemoveOwner)
    QuestieFrame.Subscribe("VisibilityChanged", QuestieWaypoints.OwnerChanged)
    -- Hovering an icon is hovering its NPC. A path hover opened for another icon ends first.   (F-4)
    QuestieFrame.Subscribe("HoverStart", function(icon)
        WaypointHover.End(icon)
        QuestieWaypoints.SetHighlighted(icon.data, true)
    end)
    QuestieFrame.Subscribe("HoverEnd", function(_, data) QuestieWaypoints.SetHighlighted(data, false) end)
end

-- QuestiePolygon.lua: called once, in the provider block that creates the first marker's renderer.
local function _FollowIcons()
    QuestieFrame.Subscribe("Unload", function(frame)
        QuestiePolygon.MarkerRemoved(frame)
        QuestiePolygon.MinimapMarkerRemoved(frame)
    end)
    QuestieFrame.Subscribe("VisibilityChanged", QuestiePolygon.MarkerChanged)
    QuestieFrame.Subscribe("HoverStart", QuestiePolygon.EnterMarker)                          -- (F-4)
    -- A recycled icon's old marker ended its preview when it unloaded; a new marker's is not this hover's.
    QuestieFrame.Subscribe("HoverEnd", function(frame, data)
        if frame.data == data then QuestiePolygon.LeaveMarker(frame) end
    end)
    QuestieFrame.Subscribe("Click", QuestiePolygon.ToggleMarker)
end
```

Why subscribe on first use, rather than an `Initialize` called from `QuestieInit`:
- No path or marker can exist before that point.
- No core entry point is needed.
- Nothing depends on TOC order.
- Blob mode off costs nothing.
- `QuestieInit`'s deferred thread can't race login drawing. In `QuestieInit.test`, login stages reach drawing while the addon-loaded thread yields (`WP QuestieInit.test.lua:579-616`).

Each existing listener function already ignores icons that aren't its own:
- `OwnerChanged` checks `data.waypointPaths[1]`;
- `MarkerRemoved`, `MarkerChanged`, `EnterMarker` and `ToggleMarker` check `frame.polygonMarker`.

### 3.4 Feature state on core frames

| Field | Decision | Why |
|---|---|---|
| `data`, `minimapTwin`, `hidden`, `faded`, `miniMapIcon`, `x`, `y`, `UiMapID`, `AreaID`, `texture.a`, `_loaded`, `_hidden_by_flash` | **IconFrame contract**, read-only for features (3.5) | Core state that both features read today |
| `data.touchedPins` | **Core-private**, declared on `IconData` in `QuestieFrame.lua` | Rule 3: the tint stays in core, and after F-4 only `QuestieFrame` touches it |
| `data.waypointPaths` | **Stays on the data**, declared by `QuestieWaypoints.lua` (`---@class IconData` partial) | Paths are per NPC data by design (`WP QuestieWaypoints.lua:65-68`). Its one aliasing hazard, `_FallbackIconData`'s shallow copy, is deleted by C-F1. A private table would rewrite 20 test assertions in `QuestieWaypoints.test.lua` for no behavior gain. |
| `polygonMarker`, `polygonMinimapMarker` | **Stay on the frame**, declared by `QuestiePolygon.lua` (`---@class IconFrame` partial) | After F-3 only the polygon feature reads them. A weak-keyed table frees nothing, because pooled frames are never collected. Explicit clearing is still needed, and the move would rewrite about 70 test lines. |
| `OnWorldMapPinUpdated` | **Stays**, declared by `PolygonNudging.lua` | A hook field of Questie's HereBeDragons-Pins fork with one owner. A second feature needing it would have to share it through a seam first. |

Cross-file partial classes have a precedent: `---@class QuestieQuestPrivate` is declared in both `QuestieQuest.lua:7` and `QuestieQuestPrivates.lua:5`.

### 3.5 The `IconFrame` contract (final LuaCATS, in `QuestieFrame.CreateIconFrame`)

```lua
    ---A pooled map icon on the world map or the minimap: a quest giver, objective, finisher, manual
    ---note or a drawing feature's marker. Drawing features read the fields below, never write them,
    ---and follow the icon through QuestieFrame's icon events.
    --- - One icon at a time: from QuestieFramePool:GetFrame until its Unload event the frame shows
    ---   one icon; afterwards the pool may hand it out for other data. Anything a feature keys by the
    ---   frame it forgets on Unload.
    --- - Data refreshed in place: `data` is set when the icon is drawn and then changes only field by
    ---   field until Unload, never for another table. A frame whose data is another table shows
    ---   another icon, which is how patrol paths tell a recycled owner (`path.owner.data == path.data`).
    --- - A feature's own fields on an icon or its data carry the feature's name (`polygonMarker`,
    ---   `waypointPaths`), are declared in the feature's files, and are cleared when it lets the icon
    ---   go. Core and other features never read them.
    ---@class IconFrame : Button
    ---@field data IconData? What the icon shows; nil while pooled.
    ---@field minimapTwin IconFrame? A world map icon's minimap icon, drawn with the same data table: patrol paths follow it on the minimap. Linked by QuestieMap for icons drawn as a pair and by a drawing feature for its markers; cleared on unload. A twin unloaded alone stays linked, so readers check `twin.data == icon.data`.
    ---@field miniMapIcon boolean? A minimap icon.
    ---@field hidden boolean? Hidden by FakeHide, whatever HereBeDragons shows.
    ---@field faded boolean? Faded by FadeOut, such as for the tracker's focus.
    ---@field x number? Where it was drawn, in percent on UiMapID.
    ---@field y number?
    ---@field UiMapID number?
    ---@field AreaID AreaId?
    ---@field isManualIcon boolean
    ---@field texture IconTexture Its alpha (`texture.a`) is 0 for an icon faded out entirely, which is not there to hover.
    ---@field _loaded boolean? The draw queue added it to HereBeDragons; until then it is on no map.
    ---@field _hidden_by_flash boolean? Hidden while the tracker's Show on Map flashes another objective.
```

On `IconData`, `waypointPaths` moves out (`WP QuestieFrame.lua:38`), and this comes in:

```lua
---@field touchedPins {icon: IconFrame, color: number[]}[]? QuestieFrame's own: the icons a hover of this data tinted, with their colors before it.
```

**Invariants that hold today** (verified):
- `data` is assigned only when drawing (`WP QuestieMap.lua:560`, `:583`, `:670`, `:680`) and cleared only on unload or reinit (`WP QuestieFrame.lua:392`, `QuestieFramePool.lua:136`).
- `_RefreshMarkers` mutates marker data in place (`B QuestiePolygon.lua:821-865`).

### 3.6 Core → feature imports, classified

| Import (branch) | Class | Becomes |
|---|---|---|
| `QuestieFrame` → QuestieWaypoints (WP), QuestiePolygon (B) | **(a)** events | `Unload`, `VisibilityChanged`, `HoverEnd`, `Click` (F-3) |
| `MapIconTooltip` → QuestieWaypoints, WaypointHover (WP); QuestiePolygon (B) | **(a)** events | `HoverStart` (F-4) |
| `QuestieFramePool` → MapIconTooltip (`.Show`) | core → core | dropped: `QuestieFrame` sets its own `OnEnter` (F-4) |
| `QuestieOptionsMap` → WaypointRenderer (WP `:11`); `Questie.lua` → WaypointRenderer (WP `:28`) | **(c)** into the feature | `QuestieWaypoints.Redraw()`, which calls `WaypointRenderer.RedrawAll()` and invalidates both maps (F-5) |
| `QuestieMap` → QuestieWaypoints (WP); QuestiePolygon (B) | **(b)** | `DrawWaypoints` → `Add`; `UnloadQuestFrames` → `RemoveQuest` |
| `QuestieQuest` → QuestiePolygon (B) | **(b)** | blob mode: `IsEnabled`, `UpdateObjective`, `RemoveObjective`, `Reset` |
| `TrackerUtils` → both | **(b)** | Show on Map flash: `SetSolo`, `GetObjectiveMarkers`, `ScheduleRefresh` |
| `TrackerLine` → QuestiePolygon (B) | **(b)** | objective hover preview: `SetObjectivePreview` |
| `QuestieOptionsMap`, `QuestieOptionsAdvanced` → QuestieWaypoints (WP); `QuestieOptionsIcons` → QuestiePolygon (B) | **(b)** | the settings that configure each feature |
| `Questie.lua` → both | **(b)** | reset: `QuestieWaypoints.Redraw` on profile switch; `QuestiePolygon.Reset` on disable |

**Rule 4 in one place.** This is the guard's `ENTRY_POINTS`: 8 files and 11 entries, adapters only. Rule 4 listed blob mode, options tabs, the tracker flash and init/reset. The real list adds four entries:
- the waypoints drawing entry (`DrawWaypoints`);
- `RemoveQuest` in `UnloadQuestFrames`;
- the tracker's objective hover preview;
- the Advanced tab's debug toggle.

No init entry is needed (3.3). That is decision F-5.

```lua
-- Core reaches a drawing feature only here, and only through the feature's adapter. Everything else
-- goes through QuestieFrame's icon events or the shared map seams. One line per core file and adapter.
local ENTRY_POINTS = {
    ["Modules/Map/QuestieMap.lua"] = {
        QuestieWaypoints = "DrawWaypoints registers an icon's patrol paths",
        QuestiePolygon = "UnloadQuestFrames removes a quest's areas",
    },
    ["Modules/Quest/QuestieQuest.lua"] = {QuestiePolygon = "blob mode draws, removes and resets objective areas"},
    ["Modules/Tracker/TrackerUtils.lua"] = {
        QuestieWaypoints = "Show on Map shows only the flashed objective's paths",
        QuestiePolygon = "Show on Map flashes the objective's markers",
    },
    ["Modules/Tracker/LinePool/TrackerLine.lua"] = {QuestiePolygon = "hovering an objective previews its areas"},
    ["Modules/Options/MapTab/QuestieOptionsMap.lua"] = {QuestieWaypoints = "Map > Waypoints settings"},
    ["Modules/Options/AdvancedTab/QuestieOptionsAdvanced.lua"] = {QuestieWaypoints = "Show waypoint hover area"},
    ["Modules/Options/IconsTab/QuestieOptionsIcons.lua"] = {QuestiePolygon = "Questie blobs preset and quest area settings"},
    ["Questie.lua"] = {
        QuestieWaypoints = "a profile switch redraws paths",
        QuestiePolygon = "disabling Questie resets areas",
    },
}
```

### 3.7 Import guard test

- **Location:** `test/MapFeatureImports.test.lua`.
  - `test/` holds cross-cutting tests, for example `test/QuestieDBMock.conformance.test.lua`.
  - `busted -p ".test.lua" .` picks it up, so CI runs it (`ci.yml:74`).
- **What it scans:** the union of the `.lua` files in the six TOCs, read with the tested `LoaderUsage.ReadTocLuaPaths` (`cli/loaderUsage.lua:132`). `Blob/` is skipped.
- **What a feature is:** a folder of its own under `Modules/Map/`. Until the move, `Polygon/` counts too.
- **How a future drawing module declares itself:** by living in `Modules/Map/<Name>/`. If core needs an entry point into it, that is one reviewed line in `ENTRY_POINTS`. Files directly in `Modules/Map/` (`WorldMapLayers`, `MinimapCanvas`, `MapGeometry`, `QuestieMap`, and so on) are core and shared.

The checks, as prototyped:

```lua
---A drawing feature is a folder of its own under Modules/Map/; Polygon/ until it moves there.
---@param path string Addon-relative, forward slashes.
---@return string? feature
local function _FeatureOf(path)
    return path:match("^Modules/Map/([^/]+)/") or (path:match("^Polygon/") and "Polygon") or nil
end

---Every import of a feature's module from another feature, from core outside ENTRY_POINTS, and every
---entry point no longer used. Comments are skipped; colon and dot calls both count.
---@param sources table<string, string> Source text by addon-relative path.
---@param entryPoints table<string, table<string, string>>
---@return string[] violations
local function _Violations(sources, entryPoints)
    local owners, imports = {}, {}
    for path, text in pairs(sources) do
        local lineNumber = 0
        for line in (text .. "\n"):gmatch("(.-)\n") do
            lineNumber = lineNumber + 1
            local code = line:gsub("%-%-.*$", "")
            for name in code:gmatch('CreateModule%s*%(%s*"([%w_]+)"') do owners[name] = _FeatureOf(path) or false end
            for args in code:gmatch("ImportModule%s*(%b())") do
                local name = args:match('"([%w_]+)"%s*%)$')
                if name then imports[#imports + 1] = {path = path, line = lineNumber, module = name} end
            end
        end
    end
    local violations, used = {}, {}
    for _, import in ipairs(imports) do
        local from, to = _FeatureOf(import.path), owners[import.module]
        if to and from ~= to then
            if not from and entryPoints[import.path] and entryPoints[import.path][import.module] then
                used[import.path .. " > " .. import.module] = true
            else
                violations[#violations + 1] = string.format("%s:%d imports %s of %s", import.path, import.line,
                    import.module, to)
            end
        end
    end
    for path, modules in pairs(entryPoints) do
        for module in pairs(modules) do
            if not used[path .. " > " .. module] then
                violations[#violations + 1] = "unused entry point " .. path .. " > " .. module
            end
        end
    end
    table.sort(violations)
    return violations
end
```

Two tests:
1. **"finds a feature importing another feature, and core importing one outside its entry points".** This test uses synthetic sources, so a scanner bug can't pass silently. It covers:
   - a `Modules/Map/Routes/` feature importing `QuestiePolygon`;
   - a core dot-form import (`QuestieLoader.ImportModule(QuestieLoader, "QuestiePolygon")`);
   - a commented-out import, which is ignored;
   - an allowed entry point;
   - an unused entry point;
   - a shared seam import, which is allowed.
2. **"keeps Questie's drawing features apart, reached from core only at their entry points".** This runs on the real tree and expects `{}`.

Prototype results:
- Run on today's WP and B, the real-tree test lists exactly the imports in 1.4.
- With F-1 and F-3–F-5 applied to the WP export and WP's five entry points, it passes.

### 3.8 Optional move: `Polygon/` → `Modules/Map/Polygon/` (F-7, the last commit)

This is pending David's decision. It is purely mechanical:
1. `git mv Polygon Modules/Map/Polygon`. That moves all `.lua` and `.test.lua` files, `README.md` and `BLIZZARD-NUDGING.md`.
2. **Six TOCs:** `Polygon\X.lua` → `Modules\Map\Polygon\X.lua`.
   - Six lines in each TOC (`B Questie_Vanilla.toc:291-296`, and `_TBC`, `_Wrath`, `_Cata`, `_Mists` likewise).
   - Camelot has seven, `PolygonQuestLogForever.lua` included (`B Questie_Camelot.toc:300-307`).
   - Keep the block where it is (after Blob, before `Questie.lua`), so the load order doesn't change.
3. **`build.py:111`:** drop `"Polygon"` from `directoriesToInclude`. `Modules` already packages it.
4. **`build.test.py`:**
   - `:80-94`: change the path strings to `Modules\\Map\\Polygon\\...`.
   - `:217-229`: retarget `test_polygon_runtime_files_are_packaged_but_adjacent_tests_are_not` to `Modules/Map/Polygon/` (`mkdir(parents=True)`). It is the repo's only test of `ignorePatterns`, so keep it rather than delete it.
5. **`.github/workflows/ci.yml:33`:** drop `Polygon` from luacheck's `files`.
6. **Test `dofile` paths:**
   - every `Polygon/*.test.lua`;
   - `Modules/Quest/QuestieQuest.test.lua` (`B :595`, `:631`);
   - `Modules/Tracker/TrackerUtils.test.lua` (`B :250`, `:286`);
   - `Libs/HereBeDragons/HereBeDragons-Pins-2.0.test.lua:172`, unless D-C4 moved that case;
   - any `dofile("Polygon/` added in Phase 2.
7. **Docs:**
   - `Modules/Map/Polygon/README.md`'s relative links: `../Modules/X` → `../../X`, and `../Libs/`, `../build.py`, `../.github/`, `../Blob/` → `../../../`. Also its commands (`busted -p '.test.lua' Polygon`, the luacheck list) and `:169`.
   - `BLIZZARD-NUDGING.md:98`;
   - `BLOB-PARITY.md:3`, `:33`, `:49`;
   - `Modules/Options/QuestieOptionsDefaults.lua:242` (comment);
   - `docs/waypoints.md`, wherever Phase 2 linked `Polygon/`.
8. **`test/MapFeatureImports.test.lua`:** delete `_FeatureOf`'s `Polygon/` clause. Every folder under `Modules/Map/` is now a feature.
9. **Unchanged:** `.luacheckrc` (no Polygon entries), `.luarc.json`, `cli/validate-loader-usage.lua` (TOC-driven), `setupTests.lua` and `AGENTS.md`'s commands (`Modules` covers it).
10. **Check:** `git grep -n -E "Polygon[/\\\\]" -- ':!Blob' ':!merge-plan' ':!Modules/Map/Polygon'` prints nothing. Then run `uv run --no-project python build.test.py`, the guard and the full suite.

### 3.9 Why it holds up, where it stops, and what was rejected

**A third drawing module needs:**
- its folder;
- one `LAYER_ORDER` row on each map it hovers;
- its `Subscribe` calls on first use;
- `ENTRY_POINTS` lines only where core must call it.

No existing feature changes, and the guard proves it.

**Where it stops (per `01-architecture.md`):**
- No general event bus: five icon events, fixed in `QuestieFrame`.
- No hover framework beyond the two stacks.
- Renderers unchanged except `PolygonRenderer` taking a pushed cursor.
- `WorldMapLayers` doesn't draw, schedule or cache.

**Rejected:**

| Alternative | Why |
|---|---|
| `WaypointMap.IsMapUncovered()` read by areas (first Area A) | One feature importing another, and order-dependent coupling |
| `WorldMapLayers` also drives drawing, like D's canvas | It would entangle WP's zoom-redraw scheduling with B's retained-view cache, which E keeps separate. Hover is the only shared need. |
| Frame levels owned by each feature | Draw order and hover order could drift apart per client |
| Cursor in normalized units only | Paths would need the size and zoom from another read, in another frame |
| Layers keep `Hover(nil)` on every offer | Redundant calls each move, and the areas' stored cursor needs a reliable "you lost the cursor" |
| `Initialize()` per feature, called from `QuestieInit` | An init entry point, plus a race with login drawing, for nothing first-use subscription lacks |
| Callbacks on `MapIconTooltip` (B's rejected option) | The begin and end effects would still live in different modules |
| Weak-keyed side tables for feature fields | They free nothing for pooled frames and rewrite about 90 test lines (3.4) |
| One `Unload` at the deferral as well as at the finished unload | A double emit is a contract wart; a single emit at the deferral leaks routes added to a queued frame |
| The guard as a luacheck plugin or CLI script | busted already runs in CI, and the TOC reader already exists and is tested |

---

## 4. Sequencing

### 4(a) Phase 1 (the rebase): unchanged

Nothing in the step-3 recipes changes. The seams are post-stack commits, and each Phase 1 stop leaves code they replace cleanly:

| Stop | What it leaves | Replaced by |
|---|---|---|
| #6 `dfb97c802` | Both feature imports and calls in `QuestieFrame`; `WaypointHover.End`, `EnterMarker` and `SetHighlighted` in `MapIconTooltip`; the `OwnerChanged` stub in `QuestieFrame.test` | F-3 and F-4 |
| #30 `53b5e7ce4` | R2's bare-map `isCursorOnMap` and its renamed test (A 4a) | F-2, which deletes both |
| #32 `4f76fd411` | `FakeHide` with `OwnerChanged` and polygon's minimap clause | F-3 |
| #36 `715031ef6` | `onHover = _UpdateAreaTooltip`, the `ShowOnTooltip` block (B 4a) | F-2 keeps `onHover`; F-4 trims `ShowOnTooltip` |

The README's Phase 1 epilogue becomes `git reset HEAD~2` (the orchestrator's item, per `01-architecture.md`).

### 4(b) Phase 2: the seam commits come first

Plain Conventional Commits. Each commit passes its touched tests, luacheck and `lua cli/validate-loader-usage.lua`.

**F-1 `refactor(map): hover patrol paths through a shared WorldMapLayers stack`**
- **Body:** paths no longer hover from the hidden mouse cursor in the gamepad UI (A's P4 for paths).
- **Depends on:** Phase 1.

| File | Change |
|---|---|
| `Modules/Map/WorldMapLayers.lua` | New, as in 3.2 |
| `Modules/Map/WorldMapLayers.test.lua` | New: 7 tests (§5) |
| `Modules/QuestieCompat.lua`, `.test.lua` | `IsGamepadUIEnabled()` after `GetMouseFocus`, plus one test |
| 6 TOCs | `Modules\Map\WorldMapLayers.lua` after `Modules\Map\Moonwell.lua` |
| `Modules/Map/Waypoints/WaypointMap.lua` | The paths layer, as in 3.2 Migration |
| `Modules/Map/Waypoints/WaypointMap.test.lua` | `WorldMapLayers` stub; the `hover` describe drives `layers.paths.Hover(cursor)` (§5) |
| `docs/waypoints.md` | `:46` (the WaypointMap row), `:185` (levels from WorldMapLayers), `:202-207` (Driver bullets → the stack) |

**F-2 `fix(polygon): let patrol paths cover quest areas through WorldMapLayers`**
- **Body:** this fixes N3, where area hover errored on Era, Anniversary and Progression. It also fixes the path/area tooltip tug-of-war (findings 1 and 7), and it supersedes A1 and A2.
- **Depends on:** F-1.

| File | Change |
|---|---|
| `Polygon/PolygonRenderer.lua` | `Renderer:Hover(x, y) → boolean`; `UpdateHover` reads the stored cursor; the deletions in 3.2; field docs (`cursorX`: "The cursor WorldMapLayers last offered, in canvas percent"); `PolygonHoverInput` keeps `onHover` only |
| `Polygon/PolygonRenderer.test.lua` | §5 (58 → 52 tests) |
| `Polygon/QuestiePolygon.lua` | The areas layer, `FrameLevel`, `Invalidate`, `_UpdateAreaTooltip`'s guard, import swap; header `:322-326` rewritten (A §6) |
| `Polygon/QuestiePolygon.test.lua` | §5 |
| `Modules/Quest/QuestieQuest.test.lua`, `Modules/Tracker/TrackerUtils.test.lua` | Stub `WorldMapLayers.AddLayer`/`Invalidate` next to the `PolygonMinimap.New` stub |
| `Polygon/README.md` | `:13`, `:21`, `:79`, `:104-118`, `:198` (A §6) |

**F-3 `refactor(map): let drawing features follow icons through QuestieFrame events`**
- **Body:** this fixes N5. A gamepad leave now ends a marker's area preview, and so does a path hover ending while another frame holds the tooltip (B's (f)). It supersedes A4.
- **Depends on:** F-2 (shared files, separate regions).

| File | Change |
|---|---|
| `Modules/FramePool/QuestieFrame.lua` | Drop both feature imports. Add the icon events section (3.3) and the IconFrame contract (3.5), with `polygon*` fields out, `waypointPaths` out and `touchedPins` in. `OnLeave`: drop `LeaveMarker`. `ResetHoverHighlights(icon, data)`. `OnClick`: `elseif button == "LeftButton" then _Emit("Click", self) end`. `BaseOnShow`/`BaseOnHide`: emit `VisibilityChanged` in place of polygon's `ScheduleRefresh`. `Unload`: drop the two polygon lines at its top, and emit `Unload` where `RemoveOwner` was. Fade and Fake functions: one `VisibilityChanged` emit each, replacing both features' calls. |
| `Modules/Map/Waypoints/QuestieWaypoints.lua` | Import `QuestieFrame` and `WaypointHover`; `IconData` partial with `waypointPaths`; `_FollowIcons` (`Unload`, `VisibilityChanged`, `HoverEnd`), called from `Add` after its early returns |
| `Polygon/QuestiePolygon.lua` | Import `QuestieFrame`; `IconFrame` partial; `_FollowIcons` (`Unload`, `VisibilityChanged`, `HoverEnd` with the data guard, `Click`), called in the provider block; comment `:531-532` → "Called through QuestieFrame's icon events, subscribed once, never as accumulating frame hooks." |
| `Polygon/PolygonNudging.lua` | `IconFrame` partial for `OnWorldMapPinUpdated` (docs only) |
| `Modules/Map/Waypoints/WaypointHover.lua` | `_ResetTooltipChanges(icon, path)` → `ResetHoverHighlights(icon, path.data)` at its three call sites; its comment |
| `Modules/Map/GamepadMapHover.lua` | `Leave`: `ResetHoverHighlights(hoveredIcon, hoveredData)` |
| Tests | §5 |
| Docs | `Polygon/README.md:11`, `:138`, `:153`, `:164`; `docs/waypoints.md:52` |

**F-4 `refactor(map): start icon hover effects through the HoverStart event`**
- Supersedes B-F4.
- **Depends on:** F-3, and B-F3 (Phase 0).

| File | Change |
|---|---|
| `Modules/FramePool/QuestieFrame.lua` | Import `MapIconTooltip`; `_QuestieFrame.OnEnter`, `_TintQuestIcons`, `ApplyHoverHighlights` (3.3); `CreateIconFrame(frameId)` sets its own `OnEnter` |
| `Modules/FramePool/QuestieFramePool.lua` | `QuestieFrame.CreateIconFrame(numberOfFrames)`; drop the `MapIconTooltip` import |
| `Modules/Tooltips/MapIconTooltip.lua` | Delete `MapIconTooltip:Show`. From `ShowOnTooltip`, delete `EnterMarker`, `SetHighlighted` and the tint (`touchedPins` and the recolor branch in `handleMapIcon`). Drop the `QuestieWaypoints`, `WaypointHover` and `QuestiePolygon` imports. Its doc says hover effects belong to `QuestieFrame.ApplyHoverHighlights`. |
| `Modules/Map/GamepadMapHover.lua` | `Enter`: `QuestieFrame.ApplyHoverHighlights(icon)` before `ShowOnTooltip` |
| `QuestieWaypoints.lua`, `QuestiePolygon.lua` | Their `HoverStart` listeners (3.3) |
| `Modules/Map/Waypoints/WaypointHover.lua` | `End`'s doc: "Called from QuestieWaypoints' HoverStart listener, before the icon's tints" |
| Tests | §5 |
| Docs | `docs/waypoints.md:52` |

**F-5 `refactor(waypoints): let core redraw paths only through QuestieWaypoints`**
- **Depends on:** none.

| File | Change |
|---|---|
| `Modules/Map/Waypoints/QuestieWaypoints.lua` | `Redraw()`: "Draws every path's lines anew, after the smoothing setting changed or the profile switched; a Refresh only restyles lines drawn for the old settings." Body: `WaypointRenderer.RedrawAll()` then `_Changed()`. |
| `Questie.lua` | Drop the `WaypointRenderer` import; `RefreshConfig` calls `QuestieWaypoints.Redraw()` (one line for two) |
| `Modules/Options/MapTab/QuestieOptionsMap.lua` | Drop the `WaypointRenderer` import; the smoothing setter calls `QuestieWaypoints.Redraw()` |
| `Questie.test.lua`, `QuestieOptionsMap.test.lua` | Spy on `Redraw` instead of `RedrawAll`/`Refresh` |
| `docs/waypoints.md` | `:55`, `:75` |

**F-6 `test(map): keep drawing features out of each other and out of core`**
- **Depends on:** F-3, F-4 and F-5.
- **Files:** `test/MapFeatureImports.test.lua` (3.7).
- **Optional:** add one line under "Project Structure" in `AGENTS.md`: `Modules/Map/Waypoints/, Polygon/ - drawing features: they never import each other; core reaches them only at the entry points in test/MapFeatureImports.test.lua`.

**F-7 *(optional, David decides)* `refactor(polygon): move Polygon into Modules/Map/Polygon`**
- The last commit of Phase 2, after every commit that adds `Polygon/` paths. The file list is in 3.8.

**Where these sit in the README's Phase 2:**
1. F-1 through F-6 open Phase 2. They replace Group 1's A1, A2, A4 and B-F4.
2. B-F1, B-F2 and the optional A5 follow.
3. Then Groups 2–5, as listed.
4. F-7 goes last.

D-C1 (MinimapCanvas) and E-F3 (MapGeometry) don't depend on F. Placing them right after F-6 would put all four seams first, if the orchestrator wants that.

---

## 5. Tests

These follow AGENTS.md: `dofile("setupTests.lua")`, `QuestieLoader` stubs, `.was.called*`, and reference comparison for spied tables. Busted spies deep-copy their arguments, and paths link back to their owners.

**F-1**
- **New `Modules/Map/WorldMapLayers.test.lua`** (all 7 pass in the prototype). It uses fake layers that record calls, plus stubs for `WorldMapFrame`, `CreateFrame` and `QuestieCompat`.
  1. *offers the cursor top down in canvas units, and gives a layer beneath a claim nil once.* Paths claim, so areas get nil once, then nothing on the next move.
  2. *offers it again only when the cursor moved, the zoom changed, or a layer drew anew.* A still cursor gives no call; a scale change and `Invalidate` each give one.
  3. *hovers nothing drawn while anything covers the map, off the canvas, or in the gamepad UI.* Covers other focus, `IsMouseOver` false and `IsGamepadUIEnabled`.
  4. *ignores a secret cursor position without comparing it.* The secret value's `__eq` throws.
  5. *ends every hover when the map closes, and offers the cursor again when it reopens.*
  6. *reports a failing layer, ends its hover and skips it until it is invalidated.* The layer beneath still hovers.
  7. *draws each layer above the ones beneath it, on every client's quest area level.* With 2004 and 2007: areas < paths < 2016. This is the by-construction test for "paths win".
- **`Modules/QuestieCompat.test.lua`:** *asks Forever's InputUtil, and is off where InputUtil has no gamepad UI.* `InputUtil = {}` is Era, Anniversary and Progression. This is N3's guard.
- **`Modules/Map/Waypoints/WaypointMap.test.lua`:**
  - Stub `WorldMapLayers.AddLayer`, `Invalidate` and `FrameLevel` (returning 2015, so "draws visible paths…" still asserts 2015).
  - The `hover` describe uses `Hover(x, y)` → `layers.paths.Hover({mapId, x * 1000, y * 500, 1000, 500, scale})`.
  - Keep, through the layer: "opens the owner's tooltip near the line…" (it now also asserts the claim), "hands the hover to the icon…" (`Hover(nil)`), "lets the path's icon restore…", "keeps the tooltip when moving to another patrol…" and "only highlights a path whose icon is not on this map".
  - Delete "leaves the hover to whatever covers the map": it is WorldMapLayers test 3 now.
  - Add:
    - *asks the stack to look again after drawing anew*;
    - *hovers nothing until its paths are drawn for the cursor's map*;
    - *keeps its reach on screen while zooming* (at scale 2, 2.5 canvas units misses and 1 hits).
  - Result: 16 pass, with WaypointHover's 7.

**F-2**
- **`Polygon/PolygonRenderer.test.lua`** (52 pass):
  - `_NewHoverRenderer` → `PolygonRenderer.New(canvas, {})`.
  - Add `_Poll(renderer)`, which is what the stack offers: `renderer:Hover(x * 100, y * 100)`, or nil when `onMap` is false or `cursorX` is nil.
  - Mechanical replacements:
    - its 37 `hoverDriver.scripts.OnUpdate(...)`/`driver.scripts.OnUpdate(...)` calls, and the 9 `renderer:UpdateHover()` calls after a cursor change, become `_Poll(renderer)`;
    - drop the reader fields in the two inline constructors.
  - Delete, now covered by WorldMapLayers tests 2–4:
    - "checks hover only when the cursor's canvas position changes";
    - the four "clears selection without reading geometry for <invalid coordinate>" cases;
    - "…when a numeric cursor value is secret".
  - "follows the cursor with one shared driver and no per-polygon scripts" → *hovers with no per-polygon or per-frame script* (`OnUpdate` is nil).
  - Drop the two now-vacuous `OnUpdate` assertions in "stops on inherited hide and resumes…" and "changes a marker highlight without… restarting the hover driver".
- **`Polygon/QuestiePolygon.test.lua`** (85 pass):
  - Stub `WorldMapLayers` (`AddLayer` captures `layers`, `Invalidate` spy, `FrameLevel` → 10).
  - R2's "reads the map cursor and counts only the bare map as uncovered" → *hovers its areas as the world map's areas layer, in map percent*: `layers.areas.Hover({x = 250, y = 375, width = 1000, height = 500})` calls `renderer:Hover(25, 75)` and passes its claim through; nil passes nil.
  - In "steps aside for other tooltips…", replace the waypoint-line block: *another frame took the tooltip while the same areas stay hovered; the next check takes it back*.
  - "shows nothing while the setting is off or the gamepad UI is on" → "…while the setting is off".
  - Delete the `savedIsLineFrame` scaffolding, and the `focus`/`GetMouseFoci` and `InputUtil` setup in "area tooltips".
- **`QuestieQuest.test.lua`, `TrackerUtils.test.lua`:** the two stubs. 104 pass.

**F-3**
- **`Modules/FramePool/QuestieFrame.test.lua`** (the combined file):
  - Remove the top-level `QuestieWaypoints` stubs, including stop #6's `OwnerChanged`.
  - Replace WP's "waypoint paths" describe and B's "polygon marker interaction" describe with **"icon events"**:
    - *tells features when an icon shows, hides or fades, natively or by Questie's own hiding*: six `VisibilityChanged` events.
    - *tells features once that a queued icon unloaded, when its unload finishes and while it shows its data*: no event while deferred; one with `data` and `minimapTwin` set. This replaces B's two "before a queued icon defers" tests and C's planned deferred-unload test.
    - *finishes an unload whatever a listener does, and reports a failing listener once*: two icons, a listener that throws, the next listener called twice, `Questie.Error` once, and both icons' data cleared.
    - *leaves a plain left-click on an icon on its own map to features*: another map navigates instead. Right-click and modifier cases fold in from B's four toggle tests.
  - In `ResetHoverHighlights`, replace WP's "should end the highlight of the NPC's waypoint paths" with *should end the hover with the data it started with, after restoring the colors it tinted* (order untint → listener; the recycled icon gets the old data).
  - Prototype: 43 pass (WP's file).
- **`QuestieWaypoints.test.lua`:** capture `Subscribe` in `before_each`, then *follows its owners through icon events from the first path on*:
  - nothing is subscribed before `Add`;
  - `HoverEnd` with the start data unhighlights after recycling;
  - `VisibilityChanged` invalidates;
  - `Unload` releases.
  - 15 pass.
- **`QuestiePolygon.test.lua`:** capture `Subscribe`, then *follows its markers through icon events*:
  - `Unload` removes a marker and its minimap icons;
  - `VisibilityChanged` schedules a refresh;
  - `HoverEnd` ends the preview only for the data it started with (A4's recycled-icon case);
  - `Click` toggles.

  Add the same capture stub to `QuestieQuest.test.lua` and `TrackerUtils.test.lua`. Their real `QuestiePolygon` creates the provider.
- **`WaypointHover.test.lua`:** `called_with({data = data})` → `called_with(icon, data)`, twice. 7 pass.
- **`GamepadMapHover.test.lua`:** the reset stub records `icon` and `data` separately; "should hide the tooltip…" also asserts the icon. 10 pass.

**F-4**
- **`QuestieFrame.test.lua`, new "hovering" describe** (with HereBeDragons stubbed to enumerate the hovered icon):
  - *starts the hover before the tooltip, and neither for an icon faded out to nothing*;
  - *lets HoverStart listeners finish before tinting the quest's icons*;
  - *keeps the colors to restore when the hover starts again before its reset*: B-F3's test, moved from `MapIconTooltip.test`.
- **`MapIconTooltip.test.lua`** (17 pass on WP's file):
  - drop the `QuestieWaypoints`/`WaypointHover` stubs;
  - `MapIconTooltip.Show(icon)` → `ShowOnTooltip(icon, GameTooltip)`;
  - delete B's "previews polygon markers even when the tooltip refresh is throttled" and "does not call polygon preview for ordinary objective icons". The preview is now `HoverStart`'s: ordering is in QuestieFrame, and the filter is in `EnterMarker`'s own tests.
- **`GamepadMapHover.test.lua`:** an `ApplyHoverHighlights` spy, called with `pin.icon` before `ShowOnTooltip`.
- **`QuestieWaypoints.test.lua`:** `HoverStart` calls `WaypointHover.End(owner)` (compare `refs[1]`), then highlights.
- **`QuestiePolygon.test.lua`:** `HoverStart` previews a marker.

**F-5**
- `Questie.test.lua` "redraws waypoint lines with the new profile's settings" spies on `QuestieWaypoints.Redraw` (33 pass).
- `QuestieOptionsMap.test.lua` "redraws the lines' geometry for a new smoothing" does the same (2 pass).

**F-6:** the two tests in 3.7.

**Deleted, overall:**
- B's renderer polling tests (6), which moved to the stack.
- B's polygon preview tests in `MapIconTooltip.test` (2) and B's ten polygon-specific `QuestieFrame` tests (`B QuestieFrame.test.lua:112-195`), which became four feature-neutral event tests.
- No test exists only to pin deleted code.

---

## 6. Docs and comments

- **Module headers are the single source of truth:**
  - `WorldMapLayers.lua` (3.2): order, cursor contract, rules, dispatch, errors;
  - `QuestieFrame.lua`'s "Icon events" section and the IconFrame contract (3.3, 3.5).
- **`docs/waypoints.md`:**
  - `:46`: WaypointMap is "the paths layer of WorldMapLayers: draws, keeps the width constant while zooming, hit-tests the cursor the stack offers";
  - `:52`: QuestieFrame reports unload, visibility and hover through icon events, and `QuestieWaypoints` subscribes from the first path on;
  - `:55`, `:75`: `Redraw`;
  - `:185`: levels from WorldMapLayers;
  - `:202-207`: the Driver bullets point to WorldMapLayers;
  - `:273-281`: hover exceptions and frame levels "resolved: WorldMapLayers". Areas A, C and E word their own bullets.
- **`Polygon/README.md`:**
  - `:13`, `:21`, `:104-118`, `:198`: hover through the areas layer (A §6 has the wording);
  - `:79`: `New(canvas, hoverInput?)`, where `hoverInput` is `{onHover}`, with `Hover(x, y)`;
  - `:11`, `:138`, `:153`, `:164`: icon events.
- **`BLOB-PARITY.md:45`:** the frame-level review is settled by WorldMapLayers.
- **Inline:** every comment listed in 4(b).
- **`AGENTS.md`:** the optional line in F-6.

---

## 7. Verification

**Per commit, from the repo root:**

```bash
busted Modules/Map/WorldMapLayers.test.lua Modules/QuestieCompat.test.lua Modules/Map/Waypoints/WaypointMap.test.lua Modules/Map/Waypoints/WaypointHover.test.lua   # F-1
busted Polygon/PolygonRenderer.test.lua Polygon/PolygonRenderCache.test.lua Polygon/PolygonMinimap.test.lua Polygon/QuestiePolygon.test.lua \
       Modules/Quest/QuestieQuest.test.lua Modules/Tracker/TrackerUtils.test.lua                                                        # F-2
busted Modules/FramePool/QuestieFrame.test.lua Modules/Map/Waypoints/QuestieWaypoints.test.lua Modules/Map/Waypoints/WaypointHover.test.lua \
       Modules/Map/GamepadMapHover.test.lua Polygon/QuestiePolygon.test.lua Modules/Quest/QuestieQuest.test.lua Modules/Tracker/TrackerUtils.test.lua  # F-3
busted Modules/FramePool/QuestieFrame.test.lua Modules/Tooltips/MapIconTooltip.test.lua Modules/Map/GamepadMapHover.test.lua \
       Modules/Map/Waypoints/QuestieWaypoints.test.lua Polygon/QuestiePolygon.test.lua                                                   # F-4
busted Questie.test.lua Modules/Options/MapTab/QuestieOptionsMap.test.lua                                                                # F-5
busted test/MapFeatureImports.test.lua                                                                                                   # F-6
luacheck -q -- Database Localization Modules Polygon Public Questie.lua
lua cli/validate-loader-usage.lua
```

Run `busted -p ".test.lua" .` once, after F-6 and after F-7.

**In game, for David.** Use a development client. Areas A and B's checks cover the player-facing precedence; these check the seams.
1. **Forever, blob mode, Durotar, quest 826:**
   - Hover Zalazane's path where it crosses the troll areas. You get his tooltip, and no area outline.
   - Slide off the line, staying inside the area. The area tooltip shows.
   - Zoom with the wheel while resting on a line. The hover holds while the reach stays one unit past the line on screen.
2. **Era 1.15.x, then Anniversary:** with area tooltips on, hover areas. There is no Lua error (N3).
3. **Forever, gamepad UI:**
   - Paths and areas under the hidden mouse cursor show nothing.
   - The gamepad cursor on a polygon marker previews its areas, and moving on ends the preview (N5).
4. **Any client:**
   - Open and close the map while hovering a path. The tooltip and highlight end when the map closes.
   - Reopen the map on the same spot. Hover resumes on the next mouse move.
5. **Blob mode:**
   - Left-click a marker on its own map: its areas toggle.
   - Click a marker from another map: the map navigates there, and nothing toggles.
6. **Abandon a quest right after accepting it,** while its markers are still drawing (draw queue). No marker or route lingers once the queue settles.
7. **Profile switch** with paths shown: the new profile's width and colors apply at once (F-5).
8. **Profiler (optional):** compare Questie's per-frame time with the world map open and still, before and after F-1/F-2. Expect the same or lower: one poller instead of two.

---

## 8. Risks and open questions

| # | Item | Recommendation |
|---|---|---|
| F-1 | **Decision:** add `Click` as a fifth icon event (polygon's `ToggleMarker`) | **Yes.** Otherwise `QuestieFrame` keeps a feature import for one line. Its meaning is narrow: the click core does nothing else with. |
| F-2 | **Decision:** `VisibilityChanged` also covers native show and hide (polygon's `BaseOnShow`/`BaseOnHide` refresh) | **Yes.** One event: listeners re-read and coalesce. The cost is a few redundant restyles and one signature-checked nudge pass on map open. The alternative is a sixth event, or a `native` flag. |
| F-3 | **Decision:** `Unload` fires once, when the unload finishes, so polygon releases a still-queued marker a few frames later than B did | **Yes.** It is the only moment the pool can recycle the frame, and it releases routes added meanwhile. Every polygon release path already clears `polygonMarker` itself first (`_ReleaseMarkers`, `RemoveQuest`, `Reset`). |
| F-4 | **Decision:** feature fields stay on frames and data, declared by their feature (3.4) | **Yes.** There is no payoff from side tables. |
| F-5 | **Decision:** rule 4's list as the guard's 11 entry points (3.6), with features subscribing on first use and no init entry point | **Yes** |
| F-6 | **Decision:** move `Polygon/` to `Modules/Map/Polygon/` (F-7) | **Yes.** Features then declare themselves by folder, and build and CI lose their special case. It is purely mechanical, last in Phase 2. |
| F-7 | **Decision:** `WorldMapLayers` owns frame levels (`FrameLevel(name)`) | **Yes.** Draw order and hover order can't drift apart. |
| F-8 | **Decision:** the minimap gets the same claim rule and gamepad rule (D's delta) | **Yes.** One rule for both maps. The claim is moot until areas hover on the minimap. |
| R1 | A one-frame stale hover when the poller runs before WaypointMap's redraw | Guarded: paths hover only drawings for `cursor.mapId` and size, and the redraw invalidates. |
| R2 | UI appearing over a still cursor is noticed on the next move | It is the same on both branches today. Accept. |
| R3 | A listener that throws on every unload is reported once, then silent | Accept. The report names the listener's file and line (Lua error position; `pcall` drops the traceback), and the icon work it guards still completes. |
| R4 | Listener order follows which feature drew first in the session | No listener depends on order (3.3, rule 1). |
| R5 | `PolygonRenderer`'s stored cursor could go stale if a layer missed its nil | The stack guarantees nil once on cover, hide, gamepad UI and error. `Clear`'s reset leaves it to the next offer, which `Invalidate` after `Present` triggers. |
| R6 | Busted spies deep-copy arguments, and paths link to owners | The tests compare `calls[i].refs` (§5). |

---

## 9. Contracts with other areas

**F provides:**
- `WorldMapLayers` (`AddLayer`, `Invalidate`, `FrameLevel`; `WorldMapLayer.Hover`; `WorldMapCursor`);
- `QuestieCompat.IsGamepadUIEnabled()`;
- `QuestieFrame.Subscribe` and the five icon events, with their ordering and isolation guarantees;
- `QuestieFrame.ApplyHoverHighlights(icon)` and `ResetHoverHighlights(icon, data?)`;
- the IconFrame contract;
- `QuestieWaypoints.Redraw()`;
- the guard and `ENTRY_POINTS`;
- the move plan.

**F assumes:**
- **A:** the precedence policy (icons, then paths, then areas, then bare map; nothing in the gamepad UI) that `LAYER_ORDER` and `_Cursor` encode. A's rewritten plan states it and owns its verification.
- **B:**
  - `ShowForIcons`, `Release` and `GetOwner` as in B §3.2;
  - the area tooltip keeps `onHover(shapes, changed)` semantics;
  - B-F3 lands in Phase 0, because F-4 moves its guard.
- **C:**
  - C-F1 deletes `_FallbackIconData`, which retires the `waypointPaths` aliasing hazard;
  - C-F2 links polygon markers' `minimapTwin` as the contract says.
- **D:**
  - `MinimapCanvas` adopts the claim and gamepad rules;
  - its seam lives directly in `Modules/Map/`.
- **E:**
  - hover stays in E's presentation tier (it never yields);
  - `MapGeometry` lives directly in `Modules/Map/`;
  - containment stays inside `PolygonRenderer`.

---

## 10. Deltas for B, C, D and E

Each area applies these to its own plan. Section and commit IDs refer to that plan's current text (snapshot `e71e6dd38`).

### B (`B-tooltip-api.md`)

1. **§4(b) F4: delete it.** F-4 implements it through `HoverStart`.
   - In §1 Summary, the bullet "Hover side effects move out of the tooltip module…" → "…into `QuestieFrame`'s `ApplyHoverHighlights`/`ResetHoverHighlights` and the features' `HoverStart`/`HoverEnd` listeners (Area F, F-3/F-4)".
2. **§3.2:**
   - "`MapIconTooltip:Show()` remains the IconFrame OnEnter script until F4" → "until F-4 (Area F), which makes `_QuestieFrame.OnEnter` the script".
   - `ShowOnTooltip`'s doc: no hover effects after F-4.
3. **§3.3, the `data.touchedPins` row:** "MapIconTooltip writes it until F4, then QuestieFrame" → "until F-4". The F3 guard moves with it into `QuestieFrame`'s `_TintQuestIcons`.
4. **§3.4:**
   - The icon mouse-hover row: `_QuestieFrame.OnEnter` → `ApplyHoverHighlights` then `ShowOnTooltip`.
   - The gamepad row: preceded by `ApplyHoverHighlights` (F-4), ended by `ResetHoverHighlights(icon, data)` (F-3) and `Hide`.
   - The polygon areas row: reached through the areas layer of `WorldMapLayers` (F-2), with `_UpdateAreaTooltip` unchanged except its guard.
5. **§3.5 invariant 7:** "After F4" → "After F-4".
6. **§3.6:** rewrite it as "Relocated through QuestieFrame's icon events (Area F)":
   - The begin effects are `HoverStart` listeners and the ends are `HoverEnd` listeners, beside each other in each feature.
   - Delete the fallback paragraph ("move `EnterMarker` into `Show`").
7. **§3.9 rejected list:** "Registered 'before show' callbacks per feature" → "callbacks registered on `MapIconTooltip`; the chosen seam is `QuestieFrame`'s icon events (architecture rule 3)".
8. **§4(b) F1:**
   - The `QuestieFrame.lua` row: the `MapIconTooltip` import already exists after F-4. `OnLeave` no longer has `LeaveMarker` (F-3).
   - The `WaypointHover.lua` row: `_ResetTooltipChanges` now takes `(icon, path)` (F-3), and `Release` goes beside it.
9. **§4(b) F2:** optionally, `_Leave`'s minimap branch ends the path's own highlight with `QuestieWaypoints.SetHighlighted(path.data, false)` instead of `_ResetTooltipChanges`, since a minimap path hover starts no icon hover. Either works.
10. **§4(b) F3:** unchanged (Phase 0). Note that F-4 moves its code and its test into `QuestieFrame`.
11. **§5:**
    - Delete the F4 list. F-4 owns it: the `QuestieFrame` "hovering" tests, the `MapIconTooltip.test` edits, and the `GamepadMapHover` spy.
    - F1's `QuestieFrame.test.lua` bullet: stub `MapIconTooltip.Release` in the top-level `before_each`, and assert `OnLeave` calls it with `(QuestieFrameInstance, GameTooltip)` in a new `OnLeave` test. The "polygon marker interaction" block is gone after F-3.
12. **§6:** `docs/waypoints.md:52` is F-3/F-4's.
13. **§8:**
    - R7 "F4 overlaps Area A": resolved by F-4.
    - D3: superseded by architecture rule 3. Events, done in F-3/F-4.
14. **§9:**
    - "Area A, hover arbitration" becomes "Areas A and F": `WaypointHover.End` runs in the waypoints `HoverStart` listener, before the core tint (F 3.3 guarantee 2).
    - The Area E bullet: "the one poller (`WorldMapLayers`) keeps the changed signal".

### C (`C-quest-drawing.md`)

1. **§3 ownership table, `QuestieFrame` row:** "emits icon events (`Unload`, `VisibilityChanged`, `HoverStart`, `HoverEnd`, `Click`); `QuestieWaypoints` and `QuestiePolygon` subscribe (Area F, F-3)". It is no longer "forwards to both".
2. **§3 public interface:** "kept: … `MarkerRemoved`/`MinimapMarkerRemoved`/`MarkerChanged` (QuestieFrame)" → "(QuestiePolygon's icon-event listeners, F-3)". The `minimapTwin` doc block → "see F 3.5, the IconFrame contract".
3. **§3 invariant 1:**
   - "Questie's own lifecycle goes through `MarkerRemoved`" → "through the `Unload` icon event, which fires once, when the unload finishes (F 3.3 guarantee 3)".
   - "`RemoveOwner` is idempotent, and the deferred first `Unload` does not call it" → "neither listener runs on the deferred first `Unload`".
4. **§4(b) F1:**
   - Drop the `savedIsLineFrame` deletion: F-2 deletes it.
   - Drop the `QuestieFrame.test.lua` test "releases a queued marker's routes once, when its deferred unload finishes": F-3's "tells features once that a queued icon unloaded…" covers it.
   - If David takes decision C-5 as A's version, `_AttachRoutes` picks the owner with A's `_RouteOwner` (A §9), and adds A's test.
5. **§4(b) F2:** drop the `Modules/FramePool/QuestieFrame.lua` row. F-3 writes the IconFrame contract, which already says drawing features link their markers' twins.
6. **§5:** drop the `QuestieFrame.test.lua` row (moved to F-3). The `QuestiePolygon.test.lua` route tests need the `Subscribe` capture stub that F-3 adds to its `before_each`.
7. **§9:**
   - Area A: "A must keep `WaypointHover` calling the owner icon's `OnEnter`/`OnLeave`" stays true. The owner's `OnEnter` is `_QuestieFrame.OnEnter`, whose `HoverStart` previews the marker.
   - Area B: "B's merged `ShowOnTooltip` must keep `SetHighlighted(self.data, true)`" holds only until F-4. After that, it is `QuestieWaypoints`' `HoverStart` listener.

### D (`D-minimap-layer.md`)

1. **§3 `MinimapLayer.Hover`:** `fun(x: number?, y: number?): boolean`. "Returns whether it hovers something; the layers beneath then get nil once, as in `WorldMapLayers`."
   - `WaypointMinimap`'s `layer.Hover` returns `path ~= nil`.
2. **§3 sketch, step 7:** "Cursor once. When the cursor or the player moved, or any layer drew, offer it top down: the first layer whose `Hover` returns true claims it, and each layer beneath that last had the cursor gets nil once."
3. **§3 `_ReadCursor`:** returns nil while `QuestieCompat.IsGamepadUIEnabled()` (added by F-1), before the focus check.
4. **§3, naming and symmetry:** keep `AddLayer`, `Invalidate(name)` and `LAYER_ORDER`; F aligned to them. There is no module rename. Add a pointer to F 3.2's table.
5. **§4(b) C1:** the canvas test list gains *offers the cursor top down: a hovering layer gives the layers beneath nil once*, using two fake layers. Canvas test 11 adds the gamepad UI. The body names the gamepad rule.
6. **§4(b) C2:** `QuestiePolygon.lua`'s provider block (B `:1010`) now also holds F-2's `AddLayer` and F-3's `_FollowIcons`, so the edit's line numbers shift.
7. **§8 R10 ("Hover may need a claimed result"):** resolved: yes, now (item 1).
8. **§9:** "Area A" becomes "Areas A and F": the claim and gamepad rules are F's, and the minimap precedence is A's.

### E (`E-geometry-scheduling.md`)

1. **§1.3, the hover row:** "Hit tests run only when the cursor moves" → "`WorldMapLayers`' one poller offers the cursor only when it moved, the zoom changed, or a layer invalidated (Area F); the minimap canvas likewise (Area D)".
2. **§3.2 renderer contract, item 2:** "Hover is computed from the cursor (Area A)" → "Hover is pushed: `WorldMapLayers` offers the cursor and each layer hit-tests it, `PolygonRenderer:Hover(x, y)` for areas (Area F)".
3. **§3.5 `_ContainsPoint` row:** "If Area A tests areas from outside `PolygonRenderer`…" → "Areas are still tested inside `PolygonRenderer` (`Renderer:Hover`), so no export is needed."
4. **§3.6:** "On the world map this already holds, and needs no code change" → "The order and both world map levels live in one table, `WorldMapLayers`' `LAYER_ORDER` (F-1); `WaypointMap.lua:17-18` and `QuestiePolygon.lua:283` read it (F-1, F-2)".
5. **§4(b) F4 (docs):**
   - Drop the `WaypointMap.lua:17` and `QuestiePolygon.lua:282-283` comment bullets. Those lines are deleted or replaced by F-1/F-2, and the comments live in `LAYER_ORDER`.
   - `docs/waypoints.md:281`: say the levels come from `WorldMapLayers`.
6. **§9, "To A":** "Both pollers test only when the cursor or the canvas moves" → "the one poller…". The renderer contract point about presentation not yielding now explicitly includes `WorldMapLayer.Hover`.
7. **Tests:** none change. E-F1, E-F2 and E-F3 are unaffected. The guard treats `Modules/Map/MapGeometry.lua` as shared core.
