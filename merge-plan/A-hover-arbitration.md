# Area A: hover arbitration

Who owns hover, highlights and GameTooltip on the world map and the minimap once blob is rebased onto waypoints.

This is the second version, rewritten on top of David's architecture (`01-architecture.md`) and Area F's seams (`F-seams.md`). The first version is in commit `e71e6dd38`. Area F owns the **mechanism**:
- `WorldMapLayers`;
- `QuestieFrame`'s icon events;
- `QuestieCompat.IsGamepadUIEnabled`.

Area A owns the **policy** the mechanism encodes:
- who wins the cursor, and why;
- the invariants;
- the gamepad rule;
- route ownership;
- the in-game checks.

- **Refs:** `WP` = `origin/waypoints` `7c1e28bd8`, `B` = blob's code at `715031ef6`. Line numbers were checked against these commits.
- **Blizzard source:** Gethe wow-ui-source, read only: `forever` `943764493e` (1.60.1 (70338)) and `classic_era` `8165d4cd6e` (1.15.9 (70003)). Also the repo's `WoW-API/_UI` (WoWUI `vanilla` @ `b6c8bf01`).
- **Test-case data:** QuestieDB `data/Classic` and `data/Forever`.

**In one paragraph.**
- **Precedence.** Hover follows draw order:
  1. anything with mouse focus (Questie's icons, Blizzard's pins, other UI);
  2. patrol paths;
  3. quest areas;
  4. the bare map.

  In the gamepad UI nothing drawn hovers from the mouse cursor.
- **How it's enforced.** `WorldMapLayers` makes this one rule. Its single poller offers the cursor top down, using the same `LAYER_ORDER` table that sets each layer's frame level, so "paths cover areas" holds by construction. Every hover ends through `QuestieFrame.ResetHoverHighlights(icon, data)`, whose `HoverEnd` event ends each feature's effects. That includes a polygon marker's preview, however the hover ended.
- **What changed from the first version:**
  - The first version's `WaypointMap.IsMapUncovered()`, "no arbiter" and two pollers are gone. A1 and A2 are now F-1/F-2, and A4 is now F-3.
  - A keeps the rebase step at stop #30 (R2), the optional A5, and decision D8 (README C-5).

---

## 1. Problem

### 1.1 What each branch does today

**WP, world map paths.**
- **Driver:** one `OnUpdate` driver on the canvas draws, then hovers, while the map is open (`WP Modules/Map/Waypoints/WaypointMap.lua:153-188`).
- **Cursor:** in canvas units (`:117-123`). It counts as on the map only while `GetMouseFocus() == WorldMapFrame.ScrollContainer` (`:125-129`).
- **Hit test:** the nearest path within `WaypointHover.Radius() / scale` (`:133-143`), then `WaypointHover.Set("map", path, path.owner)`.
- **Mouse:** paths draw at 2015 (`:17-18`), below Questie's icons at 2016 and up (`WP QuestieMapUtils.lua:53-56`), and take no mouse input.

**WP, hover state.**
- `WaypointHover` keeps one hovered path across both maps (`WP WaypointHover.lua:25-30`, `:108-119`).
- **World map:** `_Enter` runs the owner icon's own `OnEnter` (`:53-56`). Hovering a path is hovering its NPC.
- **Minimap:** the tooltip is private, `QuestieWaypointMinimapTooltip` (`:35-38`, `:45-51`). It has to be: Forever's `Minimap_OnUpdate` takes GameTooltip every frame (`forever Blizzard_Minimap/Mainline/Minimap.lua:242-245`, `:269-272`).
- **`End(icon)`** lets another icon's hover end the path hover first (`:125-127`).
- **`_Leave`** hands the hover to the icon when the cursor moves onto it (`:85`). When another frame took GameTooltip, it clears that frame's `_Rebuild`/`ShownAsMapIcon` (`:86-91`).

**B, quest areas.**
- Polygon frames take no mouse input.
- The renderer's own driver polls the cursor while areas are visible, in map percent (`B Polygon/PolygonRenderer.lua:149-156`, `:191-240`).
- **What it hovers:** every outline containing the cursor, while `isCursorOnMap()` holds (`:161-189`). That is `focus == scrollContainer or IsLineFrame(focus)` (`B Polygon/QuestiePolygon.lua:998-1001`).
- **The tooltip:** `_UpdateAreaTooltip` shows the markers' map icon tooltip owned by the scroll container, and ends it with the owner-safe `Release` (`:341-374`).
- **Level:** areas draw at `PIN_FRAME_LEVEL_QUEST_BLOB`, 2004 on Era and 2007 on Forever (`:283`).

**Icons, the same on both branches except where noted.**
- Every pooled icon's `OnEnter` is `MapIconTooltip.Show` (`WP QuestieFramePool.lua:56`).
- `ShowOnTooltip` applies the hover's side effects:
  - the route highlight (`WP MapIconTooltip.lua:117`);
  - the tints on same-quest icons (`:137-164`);
  - in B, `QuestiePolygon.EnterMarker` for markers (`B MapIconTooltip.lua:79`).
- `OnLeave` hides GameTooltip, clears its fields, and calls `ResetHoverHighlights` (`WP QuestieFrame.lua:140-166`). B first calls `LeaveMarker` (`B QuestieFrame.lua:141`).

**Gamepad, identical on master, WP and B.**
- In Forever's gamepad UI, Questie hides its pins from Blizzard's gamepad cursor (master `ae8410da8`). It finds the hovered icon itself at 20 Hz and shows its tooltip on a private `QuestieGamepadMapTooltip`, because GameTooltip from there taints the gamepad UI (master `00f19de8f`; `Modules/Map/GamepadMapHover.lua:22-27`, `:97-107`).
- `Leave` resets with `ResetHoverHighlights({data = hoveredData})` (`:109-119`).

### 1.2 Where they collide once combined

| # | What breaks | Evidence |
|---|---|---|
| P1 (finding 1) | `isCursorOnMap` calls `QuestieFramePool.IsLineFrame`, which WP deletes. That is a Lua error on every cursor move over a covered map while areas show. Tests stay green because they stub it. | `B QuestiePolygon.lua:998-1001`; `B QuestiePolygon.test.lua:105`, `:185` |
| P2 (finding 7) | **Tug-of-war.** Over a path crossing an area, both drivers see the bare map. Whichever runs second takes GameTooltip, and the area tooltip retakes it on the next move (`B :350`, `:368`), while `WaypointHover.Set` ignores the same path (`WP WaypointHover.lua:109`). | as cited |
| P3 | **`_Leave` clobbers the area tooltip.** Leaving a path inside an area clears the area tooltip's `_Rebuild` and `ShownAsMapIcon` (`WP WaypointHover.lua:86-91`), so it loses its Shift redraw and its map-tooltip status (`WP Tooltip.lua:517`, `:666`, `:731`). | as cited |
| P4 (**N3**) | **Gamepad UI.** WP's path hover opens GameTooltip from `OnUpdate` in the gamepad UI. B guards areas with `InputUtil and InputUtil.IsGamepadUIEnabled()` (`B QuestiePolygon.lua:345-346`), but only Forever defines it (`forever Blizzard_SharedXML/Mainline/InputUtil.lua:11-13`). Era's `InputUtil` has only `GetCursorPosition` and `AnchorRegionToCursor` (`WoW-API/_UI/Blizzard_SharedXML/InputUtil.lua:6-14`). So area hover errors on Era, Anniversary and Progression. | as cited |
| P5 (**N5**) | **Stuck preview.** Gamepad `Leave` passes `{data = ...}`, so `LeaveMarker` never runs, and the marker previews its areas until the map changes (`B QuestiePolygon.lua:411-441`). WP's partial leave has the same gap for paths owned by markers (`WP WaypointHover.lua:65-67`, B's (f)). | as cited |
| P6 | Shift redraw doesn't reach the private minimap and gamepad tooltips. | Area B owns the fix (B-F1) |
| P7 | Route highlights on blob-mode markers: see 1.3. | |
| P8 | Docs become wrong: `B Polygon/README.md:13`, `:21`, `:110`, `:198`; `B BLOB-PARITY.md:20`, `:45`; `WP docs/waypoints.md:279-281`. | |
| P9 (minor) | The gamepad cursor measures to a pin's un-nudged center (`GamepadMapHover.lua:83`). Stacked polygon markers share that center (`B Polygon/PolygonNudging.lua:164-176`), so it can't pick them apart. | |

### 1.3 The unverified claim about route highlights

The claim says hovering a polygon marker may not highlight routes "because `WaypointHover` hooks the icon's own `OnEnter`". The mechanism it names is wrong: `WaypointHover` *calls* the owner's `OnEnter` (`WP WaypointHover.lua:53-56`). It doesn't hook it.

Any marker whose data owns paths highlights them. The real gaps are about *which* marker owns them:
1. **Attribution.** Blob mode puts every route of an objective in a zone on the zone's last cluster marker (`B QuestiePolygon.lua:1035`, `B QuestieQuest.lua:1390-1396`). Decision D8 is about this.
2. **Minimap.** Cluster minimap icons have no `minimapTwin`, so blob-mode routes never reach the minimap. C-F2 fixes this.
3. **Gamepad leave.** This is P5, fixed by F-3.

---

## 2. Comparison

| Aspect | WP (paths) | B (areas) | Keep |
|---|---|---|---|
| Hit test | Nearest path within the capsule distance | Every outline containing the point | Both: they answer different questions |
| Units | Canvas units, with reach ÷ zoom | Map percent | Canvas units from the stack; areas convert (F 3.2) |
| Who decides "covered" | Each driver for itself | Each driver for itself, plus a line exception | **One poller for both** (`WorldMapLayers`), with the line exception dropped |
| Precedence | Undefined: two drivers | Undefined | **By `LAYER_ORDER`**, which also sets frame levels |
| Tooltip | The owner icon's `OnEnter`; a private minimap tooltip | `ShowForIcons(ScrollContainer, …)`, retried on change | Both |
| Ending a tooltip | `_Leave` clears another owner's state | Owner-safe `Release` | B's `Release` for every owner (B-F1) |
| Gamepad | Not checked | Checked, but crashes off Forever | One guarded rule in both stacks |
| Undo | `ResetHoverHighlights({data})` misses previews | `LeaveMarker` only in `OnLeave` | One undo, `ResetHoverHighlights(icon, data)`, ending every feature's effects through `HoverEnd` |
| Combat | Nothing takes mouse input | The same since `53b5e7ce4` | Both |

---

## 3. Target design

### 3.1 Precedence, as the player sees it

| Cursor over | Tooltip | Highlighted |
|---|---|---|
| A Questie icon, including a polygon marker, cluster or route marker | The icon's tooltip with nearby icons, on GameTooltip | Its NPC's routes and the same-quest tints. For a marker, also its outline and its objective's area preview. |
| A Blizzard pin, the quest log or other UI | Theirs | Nothing from Questie |
| A path within hover reach, over the bare map, **including where it crosses an area** | The path's NPC icon tooltip, through the icon's `OnEnter` | That NPC's routes on both maps, and the marker's outline and preview if the NPC's icon is a marker. **Areas under the path don't highlight.** |
| Areas, with no path in reach | The area tooltip: all hovered areas' markers, with swatches | Every hovered outline |
| The bare map | None | None |
| Gamepad UI on (Forever) | Only the gamepad cursor's icon, on `QuestieGamepadMapTooltip`. Paths and areas don't hover from the mouse cursor. | That icon's routes, outline and preview |
| Minimap: a Questie minimap icon | Its tooltip on GameTooltip | Its NPC's routes |
| Minimap: a path, over the bare minimap and inside its shape | The NPC's tooltip on `QuestieWaypointMinimapTooltip` | That NPC's routes |
| Minimap: an area | Nothing: minimap areas don't hover | — |

### 3.2 Why the path wins over the area

**For:**
1. **What you see on top is what you hover.** Paths draw above areas and below icons. One rule serves the player and every future layer.
2. **Intent.** A path is a thin target: 2.5 map units on each side of the line at the default width (`WP WaypointHover.lua:134-136`). Putting the cursor on it is deliberate; resting inside a broad translucent fill is not.
3. **Both stay reachable.** If the area won, patrols running through other objectives' areas could never be hovered. Durotar, quest 826: Zalazane patrols x 67.1–67.8, y 86.2–87.8, inside the Hexed and Voodoo Troll extents (x 65.9–68.8, y 83.0–88.7) of the same quest.
4. **One tooltip, one focus.** What is highlighted is what the tooltip describes.

**Against, and the answers:**
- *The tooltip switches as you cross lines inside an area.* The reach is one unit past the line's edge, and the path tooltip usually repeats the objective. Accept it.
- *A combined path-and-area tooltip.* It would have two hover owners for one tooltip, which `Release` can't express. WP already rejected combined tooltips for overlapping paths (`WP docs/waypoints.md:207`).
- *Areas keep highlighting under paths.* The outline and the tooltip would disagree. That exception existed only for the old mouse-enabled line frames.

**Verdict:** the path wins, by draw order. `WorldMapLayers` makes draw order and hover order the same table.

### 3.3 Modules and ownership

| Module | Owns, for hover | Change (commit) |
|---|---|---|
| `WorldMapLayers` (new, F) | One cursor poller; the bare-map and gamepad rules; top-down claims; layer frame levels | New (F-1) |
| `WaypointMap` (WP) | The paths layer: the capsule hit test on its own drawing | Its poller is replaced by `WorldMapLayers.AddLayer("paths", …)` (F-1) |
| `PolygonRenderer`, `QuestiePolygon` (B) | The areas layer: containment, the highlight union, the area tooltip | `Renderer:Hover(x, y)` replaces polling; `AddLayer("areas", …)`; `_UpdateAreaTooltip` loses its focus and gamepad checks (F-2) |
| `WaypointHover` (WP) | The one hovered path on either map; the handshake with icons | `End` runs from the waypoints `HoverStart` listener (F-4); `_Leave` ends through `ResetHoverHighlights(icon, path.data)` (F-3) and `Release` (B-F1) |
| `QuestieFrame` | The icon hover pair, `ApplyHoverHighlights`/`ResetHoverHighlights`, which emit `HoverStart`/`HoverEnd` around the core tint; the icon's `OnEnter` and `OnLeave` | F-3, F-4 |
| `GamepadMapHover` | Gamepad icon hover on a private tooltip | `Enter`/`Leave` go through the pair with the real icon (F-3, F-4); A5 optional |
| `MinimapCanvas` (D) | The minimap's cursor, shape cutoff and top-down claims | D's API takes F's claim and gamepad rules (F §10) |
| `MapIconTooltip` (B) | Rendering and tooltip state | No hover effects and no feature imports (F-4); `Release`/`GetOwner`/`Redraw` (B-F1) |

### 3.4 Interface

A adds no API of its own. It relies on:
- `WorldMapLayers.AddLayer(name, layer)`, `Invalidate(name)` and `FrameLevel(name)`;
- `WorldMapLayer.Hover(cursor?) → boolean`;
- `QuestieCompat.IsGamepadUIEnabled()`;
- `QuestieFrame.ApplyHoverHighlights(icon)` and `ResetHoverHighlights(icon, data?)`, with the `HoverStart`/`HoverEnd` events;
- `WaypointHover.Set/End/Radius` (WP, unchanged);
- `MapIconTooltip.ShowForIcons/Release/GetOwner` (B).

The full LuaCATS is in F 3.2, 3.3 and 3.5.

### 3.5 Data flow per frame

```text
Engine mouse focus → an icon, pin or UI's OnEnter/OnLeave          (always wins: it holds the focus)
  icon OnEnter = _QuestieFrame.OnEnter (alpha 0: nothing)
     → ApplyHoverHighlights: HoverStart [waypoints: WaypointHover.End, SetHighlighted; polygon: EnterMarker], then tint
     → MapIconTooltip.ShowOnTooltip(icon, GameTooltip)
  icon OnLeave → Release(icon, GameTooltip) (B-F1) → ResetHoverHighlights(icon): untint, then HoverEnd

WorldMapLayers poller (map open), when the cursor moved, the zoom changed, or a layer invalidated:
  cursor = nil if gamepad UI, off the canvas, or focus ≠ ScrollContainer
  paths.Hover(cursor) → WaypointHover.Set("map", path, owner) → owner's OnEnter / OnLeave   claims → areas get nil once
  areas.Hover(cursor) → PolygonRenderer:Hover(%x, %y) → onHover(shapes, changed) → ShowForIcons / Release

GamepadMapHover (Forever gamepad UI, 20 Hz)
  icon near the gamepad cursor → ApplyHoverHighlights(icon) → ShowOnTooltip(icon, QuestieGamepadMapTooltip)
  moved on                     → ResetHoverHighlights(icon, data) → hide

MinimapCanvas (D), top down: paths.Hover(x, y) → WaypointHover.Set("minimap", path, owner.minimapTwin)
```

### 3.6 Invariants

- **I1. Hover follows draw order, by construction.** One `LAYER_ORDER` table sets each layer's frame level and its place in the top-down offer (F 3.2).
- **I2. Precedence comes from current state.** One poller computes every layer's claim in one pass with one cursor, so no layer reads another's stored hover, and no `OnUpdate` order matters.
- **I3. One layer, one tooltip.** At most one drawn layer hovers per surface. The layers beneath a claim get `Hover(nil)` once.
- **I4. Owner-only release.** A hover ends its tooltip only through `MapIconTooltip.Release(owner, tooltip)` (B-F1).
- **I5. One undo.** Every icon hover ends through `ResetHoverHighlights(icon, data)`, whose `HoverEnd` ends each feature's effects. A recycled icon's new marker is left alone, because the polygon listener checks `icon.data == data`.
- **I6. No GameTooltip from per-frame code in the gamepad UI.** Neither stack offers the cursor while `QuestieCompat.IsGamepadUIEnabled()`. The gamepad and minimap hovers use private tooltips.
- **I7. Nothing drawn takes mouse input.** Hover needs no protected call, in or out of combat.

### 3.7 Why it holds up later

- **A new drawn layer is one `LAYER_ORDER` row** with its frame level, plus an `AddLayer`. Precedence follows from its row; nothing else changes (F 3.9).
- **Mouse-enabled UI needs nothing:** Forever's quest log boxes (`B Polygon/PolygonQuestLogForever.lua:39`, `:59`, `:98-99`), new pins, other addons. Focus already covers drawn layers.
- **I4 and I5 contain mistakes.** Even a wrong precedence for one frame can't break another owner's tooltip state, or leave a preview behind.

### 3.8 Combat and taint

- **No protected calls.**
  - The reads are `GetMouseFoci`/`GetMouseFocus` (through `QuestieCompat`), `IsMouseOver`, `GetNormalizedCursorPosition`, `GetCanvasScale` and `InputUtil.IsGamepadUIEnabled`, a plain `C_InputInterfaceStyle` read on Forever.
  - GameTooltip's `SetOwner`, `Show` and `Hide` aren't protected.
- **Combat deferrals are moot.** Blob's `SetPropagateMouseMotion` deferrals (`f9358650b`, `d9dc1ca4d`) went with `53b5e7ce4` and Area C's rebase.
- **Taint:**
  1. GameTooltip from per-frame code in the gamepad UI is gated once, in each stack (I6).
  2. Questie writes only its own fields on GameTooltip. After B-F1 they live inside `MapIconTooltip`.
  3. A restricted focus frame is only compared by identity, never touched.
  4. Forever's `Minimap_OnUpdate` owns GameTooltip, so minimap hovers use private tooltips.

### 3.9 Rejected alternatives

| Alternative | Why |
|---|---|
| `WaypointMap.IsMapUncovered()` read by areas (the first version's A1) | One feature imports another, against rule 1. A layer between two existing ones would edit the one beneath. |
| Two pollers, each with its own covered rule (the first version's "no arbiter") | Superseded: David decided on `WorldMapLayers`. Precedence needs one cursor in one pass (I2). |
| Areas reading `WaypointHover`'s stored hover | Depends on driver order, and leaves stale outlines under a still cursor |
| Precedence by tooltip ownership | Order-dependent, and the highlights still fight |
| The area wins over the path | Paths inside areas could never be hovered (3.2) |
| A combined path-and-area tooltip | Shared state with no owner (3.2) |
| Areas keep highlighting under paths | The outline and the tooltip would disagree (3.2) |
| `EnterMarker` moved into `Show`, for mouse hover only (B's fallback) | The gamepad would lose its previews. `HoverStart`/`HoverEnd` serve every hover source. |

### 3.10 Hover begin and end: who calls them

| Who | Begin | End |
|---|---|---|
| Icon, mouse | `_QuestieFrame.OnEnter`: `ApplyHoverHighlights(icon)`, then `ShowOnTooltip(icon, GameTooltip)` | `OnLeave`: `Release(icon, GameTooltip)`, then `ResetHoverHighlights(icon)` |
| `WaypointHover`, world map | The icon's `OnEnter` (unchanged) | The icon's `OnLeave` while it still holds the tooltip and shows the path's data. Otherwise `Release(icon, GameTooltip)` and `ResetHoverHighlights(icon, path.data)`. |
| `WaypointHover`, minimap | `SetHighlighted(path.data, true)`, then the private tooltip (B-F2: `ShowForIcons(Minimap, …)`) | `Release(Minimap, tooltip)`, then `ResetHoverHighlights(twin, path.data)`, or B-F2's simpler `SetHighlighted(path.data, false)` |
| `GamepadMapHover` | `ApplyHoverHighlights(icon)`, then `ShowOnTooltip(icon, QuestieGamepadMapTooltip)` | `ResetHoverHighlights(icon, data)`, then hide |
| Areas | `ShowForIcons(ScrollContainer, …)` only. Areas start no effects (D6). | `Release(ScrollContainer, GameTooltip)` |

**Ordering.** `HoverStart` listeners run before the core tint, and `WaypointHover.End` is the first thing the waypoints listener does. So a path hover's tints are restored before the new icon's colors are saved. In the gamepad UI, no path hover exists, so `End` is a no-op there. These are F 3.3 guarantees 1 and 2.

---

## 4. Sequencing

### 4(a) During `git rebase --onto waypoints origin/master blob` (unchanged)

The aim is the minimum for every replayed commit to load and pass tests without a runtime nil call.

1. **`dfb97c802` feat(polygon): integrate cached objective areas with Questie.** The resolution (Areas B and C) keeps these hover hooks:
   - `WaypointHover.End(self)` first in `MapIconTooltip:Show`;
   - WP's `ShowOnTooltip(self, Tooltip, owner, icons)` with its `alpha == 0 and not owner` gate, then B's `EnterMarker` before the throttle;
   - `SetHighlighted(self.data, true)` in place of the `lineFrames` loop;
   - `LeaveMarker` at the top of `OnLeave`, with WP's body of `ResetHoverHighlights`.

   F-3 and F-4 replace all of these later.
2. **`53b5e7ce4` refactor(polygon): compute area hover from the cursor (R2, shared with Area C).**
   - **Code:** in `Polygon/QuestiePolygon.lua`, `isCursorOnMap = function() return QuestieCompat.GetMouseFocus() == scrollContainer end`. Its comment becomes "Area hover counts only over the bare map; anything on top, including Questie's icons, Blizzard's pins and other UI, hides the areas beneath it."
   - **Test:** in `Polygon/QuestiePolygon.test.lua`, delete `local line = {}`, the `IsLineFrame` stub and the `focus = line` assertion pair. Rename the test to "reads the map cursor and counts only the bare map as uncovered".
   - **Leave alone:** the `savedIsLineFrame` scaffolding (later commits edit that line) and the README.
   - F-2 deletes all of it.
3. **`715031ef6` chore: wip snapshot.** Its `onHover = _UpdateAreaTooltip` line merges next to the rebased `isCursorOnMap`. If it conflicts, keep both.

Nothing else in the rebase needs A.

### 4(b) Follow-up commits after stacking

A's former commits are now F's seam commits, at the start of Phase 2:

| First version | Now | What it does for hover |
|---|---|---|
| A1 `fix(polygon): let patrol paths cover the quest areas beneath them` | **F-2** `fix(polygon): let patrol paths cover quest areas through WorldMapLayers` | Areas become the layer beneath paths. It ends P1–P3 and fixes N3. |
| A2 `fix(map): leave map hover to the gamepad cursor in the gamepad UI` | **F-1** (paths) and **F-2** (areas) | The gamepad rule lives in `WorldMapLayers._Cursor` through `QuestieCompat.IsGamepadUIEnabled()`. |
| A3 (end tooltips through `Release`) | **B-F1**, unchanged | — |
| A4 `fix(polygon): end a marker's area preview however its hover ends` | **F-3** `refactor(map): let drawing features follow icons through QuestieFrame events` | `ResetHoverHighlights(icon, data)` emits `HoverEnd`; polygon's listener runs `LeaveMarker` while `icon.data == data`; gamepad and `WaypointHover` pass the real icon. Fixes N5 and B's (f). |
| (B-F4) | **F-4** `refactor(map): start icon hover effects through the HoverStart event` | The begin effects move beside their ends, as in 3.10. |

A keeps one optional commit.

**A5 (optional, David decides) `fix(map): let the gamepad cursor pick markers nudged apart`**
- **After:** F-4.
- **Change:** `Modules/Map/GamepadMapHover.lua`, `FindIconUnderCursor`. Measure to the icon's own center, converted to the pin's scale, instead of the pin's un-nudged center:
  ```lua
  -- Measure to the icon, not its pin: polygon markers sharing a spot sit nudged apart inside their
  -- pins (PolygonNudging). The cursor position compares with pin coordinates, as for Blizzard's pins.
  local iconX, iconY = icon:GetCenter()
  local scale = icon:GetEffectiveScale() / pin:GetEffectiveScale()
  ```
- Un-nudged icons behave exactly as before.

A's decision D8 lands in C-F1 if David picks A's version. The specification is in §9 (Area C).

---

## 5. Tests

Precedence is tested where it is now enforced, in F's commits (F §5). Each test is listed with the invariant it proves:
- `Modules/Map/WorldMapLayers.test.lua`:
  - *offers the cursor top down in canvas units, and gives a layer beneath a claim nil once* (I1, I3);
  - *offers it again only when the cursor moved, the zoom changed, or a layer drew anew* (I2, and B's rebuild-on-change);
  - *hovers nothing drawn while anything covers the map, off the canvas, or in the gamepad UI* (focus, I6);
  - *draws each layer above the ones beneath it, on every client's quest area level* (I1 for 2004 and 2007);
  - *ends every hover when the map closes…*; *reports a failing layer…*.
- `Modules/QuestieCompat.test.lua`, *asks Forever's InputUtil, and is off where InputUtil has no gamepad UI*: encodes P4/N3.
- `WaypointMap.test.lua`:
  - *opens the owner's tooltip near the line and claims the cursor…*;
  - *hands the hover to the icon when the cursor moves onto it*;
  - *keeps its reach on screen while zooming*.
- `QuestiePolygon.test.lua`:
  - *hovers its areas as the world map's areas layer, in map percent*;
  - "steps aside for other tooltips…" (another owner took the tooltip, and the next check takes it back);
  - *follows its markers through icon events*, including HoverEnd's recycled-icon case (P5).
- `QuestieFrame.test.lua`:
  - *should end the hover with the data it started with, after restoring the colors it tinted* (I5);
  - *starts the hover before the tooltip, and neither for an icon faded out to nothing*;
  - *lets HoverStart listeners finish before tinting the quest's icons* (the 3.10 ordering).
- `WaypointHover.test.lua`: B-F1's *ends only its own changes when another owner, such as a quest area, took the tooltip* (P3).
- `GamepadMapHover.test.lua`: the leave reset gets the real icon (P5).

**A5 (if taken):** in `GamepadMapHover.test.lua`, *picks the nudged marker nearest the cursor when stacked icons share a pin position*. Use two pins with one center and icons offset by ±6. A cursor near one offset picks that icon.

**Deleted:** none beyond F's list.

---

## 6. Docs and comments

A writes the hover wording. F's commits apply it:

| File | Wording | Commit |
|---|---|---|
| `Polygon/README.md:11` | "Every way the hover ends clears the preview: the icon leaving, a path hover ending, and the gamepad cursor moving on." | F-3 |
| `Polygon/README.md:13` | Replace the last sentence: "Areas hover only where nothing covers the map: Questie's icons, Blizzard's pins, other UI, or a patrol path within hover reach, which shows its NPC's tooltip instead. They don't hover in the gamepad UI." | F-2 |
| `Polygon/README.md:21` | "unless anything covers the map there, a patrol path within hover reach included" | F-2 |
| `Polygon/README.md:104-118` | "Direct polygon hover" becomes: `WorldMapLayers` offers the cursor while nothing above covers the map; the adapter's areas layer passes it to `Renderer:Hover` in map percent; paths draw above areas and below icons, and hover follows that order. Delete the line-rectangle paragraph (`:110`). | F-2 |
| `Polygon/README.md:198` | "patrol paths crossing areas (the path's tooltip wins)" | F-2 |
| `BLOB-PARITY.md:45` | The frame-level review is settled: paths above areas, from `WorldMapLayers`. Hover follows. | F-2 |
| `docs/waypoints.md:190-209` (Hover) | Paths are the layer above areas in `WorldMapLayers`; they don't hover in the gamepad UI. | F-1 |
| `docs/waypoints.md:273-281` | The "Hover exceptions" and "Frame levels" bullets are resolved by `WorldMapLayers`. | F-1, F-2 |
| `WaypointHover.lua:13-21` (header) | "Paths hover only where WorldMapLayers offers them the cursor: nothing covers the map and the gamepad UI is off." | F-1 |
| `QuestiePolygon.lua:322-326` | "The tooltip belongs to the map's scroll container. Areas hover only where WorldMapLayers offers them the cursor: Questie's icons, Blizzard's pins, other UI and patrol paths show their own tooltips there, and the area tooltip returns once the cursor is back over bare map in an area." | F-2 |
| `GamepadMapHover.lua` | One-line comments at `Leave` (F-3) and `Enter` (F-4); at `FindIconUnderCursor` with A5 | F-3, F-4, A5 |

---

## 7. Verification

**Offline:** F §7's commands for F-1 to F-4. For A5: `busted Modules/Map/GamepadMapHover.test.lua`. Then `luacheck -q -- Database Localization Modules Polygon Public Questie.lua` and `lua cli/validate-loader-usage.lua`.

**In game, for David.** Use a development client with blob mode on.
1. **Path over area** (Forever 1.60.1, Horde, quest 826 "Zalazane", Durotar, Echo Isles near 67, 87, zoomed in):
   - Rest the cursor on Zalazane's hostile patrol line where it crosses the Hexed and Voodoo Troll areas. Expect his tooltip, his route highlighted, and no troll outline highlighted.
   - Slide off the line, still inside the area. Expect the area tooltip with swatches, and the outlines highlighted.
   - Go back and forth. Each position shows one tooltip, with no flip-back after a pause.
   - After leaving the line, hold Shift. The area tooltip still expands (P3, with B-F1).
   - Move onto Zalazane's marker: its tooltip shows and his route stays highlighted. Move onto the quest log: no Questie tooltip.
2. **Draw order:** the line stays crisp over the fill and borders.
3. **Route ownership, D8** (Horde, quest 381 "The Scarlet Crusade", Tirisfal):
   - Meven Korgal patrols inside the Scarlet Convert and Initiate areas of the same objective.
   - With A's rule, hovering his route outlines *his own* cluster's marker, and hovering that marker highlights his route.
   - With C's per-zone rule, both go to the zone's last cluster marker. Confirm whichever rule David chose.
4. **Gamepad** (Forever, gamepad UI on):
   - Hover a polygon marker with the gamepad cursor, then move away. The preview and the outline highlight end (N5).
   - Park the hidden mouse cursor over a path or an area. Neither shows a tooltip or highlight (P4).
   - Close the map and use gamepad interact. There is no "Questie has been blocked" popup (regression check for #7899).
   - With A5: in a stack of overlapping markers (quests 317 and 384), each marker can be selected.
5. **Classic Era 1.15.9, then Anniversary:** hover areas with area tooltips on. There is no Lua error, and the area tooltip shows (N3).
6. **Minimap** (Forever):
   - Hovering a path shows the private tooltip.
   - Moving onto a minimap icon hands the hover over.
   - Areas show no hover.
   - After C-F2, blob-mode routes draw on the minimap, and hovering a cluster's minimap icon highlights them.
7. **Combat:** open the map in combat. Hover a path over an area, then an icon, then an area. Drag the map across paths and areas. There is no blocked-action error.

---

## 8. Risks and open questions

| # | Item | Recommendation |
|---|---|---|
| D1 | **Decision: precedence.** Icons, then paths, then areas, then the bare map (README A-1). | Adopt (3.2). |
| D2 | **Decision: draw order**, paths above areas (README A-2; `B BLOB-PARITY.md:45` floated the reverse). | Keep. Thin lines stay readable over translucent fills. B's worry, line rectangles stealing hover, is gone. `LAYER_ORDER` now makes the draw order and the precedence one decision. |
| D3 | ~~No arbiter yet~~ (README A-3) | **Superseded** by David's architecture: `WorldMapLayers` is the arbiter. Drop A-3. |
| D4 | **Decision: gamepad UI.** Drawn layers don't hover from the mouse cursor at all, on either map (README A-4). | Adopt. It is one guarded rule in each stack, and avoids #7899-style taint. |
| D5 | **Decision:** in blob mode, hovering a path is hovering its owner marker, which previews hidden areas too (C's R3, README C-4). | Keep: it comes through the icon's `OnEnter`, with no code. |
| D6 | **Decision:** hovering an area doesn't highlight the routes of NPCs inside it. | Yes: areas start no effects, so `Release` has nothing to undo (I5). |
| D7 | **Decision: A5**, gamepad picking of nudged stacks (README A-7). | Only if gamepad plus blob mode is a supported combination. Otherwise defer. |
| D8 | **Decision: route owner in blob mode** (README C-5). C's rule is the zone's last marker. A's rule is the cluster holding the patrolling NPC's spawn, falling back to the zone's marker. With C's rule, hovering a route can outline a cluster far from the patrol (quest 381). | **A's rule.** It is about 15 lines in C-F1 (§9, Area C), and changes no hover code. |
| R1 | Dense patrols inside an area switch the tooltip as you cross lines. | Accept (3.2). Check it at Echo Isles. |
| R2 | A one-frame transient when `WaypointMap` redraws after the poller ran | Guarded: paths hover only drawings for the cursor's map and size, and a redraw invalidates (F R1). |
| R3 | UI appearing over a still cursor is noticed on the next move. | Accept: the same on both branches today. |
| R4 | Until C-F2, blob-mode routes are world map only. | Matches blob today. C-F2 ships with the merge. |
| R5 | N3 exists on `blob` today. | F-2 must ship with the merge. |
| R6 | On Forever, Blizzard's blip tooltip (GameTooltip) and the private path tooltip can overlap on the minimap. | Existing WP behavior. Accept. |
| R7 | Another addon driving GameTooltip from per-frame code over the bare map would fight the area tooltip. | Accept: it can't be solved across addons. |

---

## 9. Contracts with other areas

**A needs from Area F (seams).** `F-seams.md` provides all of these:
1. `WorldMapLayers` with `LAYER_ORDER` = areas, then paths, and frame levels from that table. Areas use Blizzard's quest-blob level and paths 2015, below icons at 2016.
2. The cursor is offered only over the bare map (focus `== ScrollContainer`), on the canvas, and outside the gamepad UI. The gamepad check is the guarded one.
3. Top-down claims, with nil once for the layers beneath. Offers come only on cursor, zoom or invalidation changes.
4. `HoverStart` listeners before the core tint. `HoverEnd` gets the data the hover started with.
5. The polygon `HoverEnd` listener checks `icon.data == data`.

**A needs from Area B (tooltips).** `B-tooltip-api.md` provides all of these:
1. `Release(owner, tooltip)` forgets only that owner's state, and hides the tooltip only while that owner holds it (B-F1).
2. Tooltip state is keyed by the frame passed to `SetOwner`:
   - the icon, for icon hovers and world map path hovers;
   - `ScrollContainer`, for areas;
   - `Minimap`, for minimap paths (B-F2).
3. B-F1 owns the former A3: `OnLeave` and `WaypointHover._Leave` end tooltips through `Release`, which fixes P3.
4. `ShowForIcons` applies no hover effects. After F-4, neither does `ShowOnTooltip`.
5. The throttle never blocks an icon while another owner holds the tooltip (`B MapIconTooltip.lua:80-81`).
6. `_UpdateAreaTooltip`'s "already mine" check stays `GameTooltip:IsOwned(owner) and GameTooltip:IsShown()`.

**A needs from Area C (quest drawing).**
1. R2 at `53b5e7ce4` is applied once, shared with C. C's later scaffolding cleanup is done by F-2.
2. Every route owner is a live marker of the current generation, which C guarantees.
3. Markers that own routes get a `minimapTwin` that shares their data (C-F2).
4. **D8, if David takes A's rule.** In C-F1's `_AttachRoutes`, the zone loop picks `_RouteOwner(entry, spawnData, areaId) or zoneMarkers[areaId]`, then keeps C's `marker.frame.polygonMarker == marker` check:
   ```lua
   ---The marker whose cluster holds one of the NPC's spawns in this zone, so hovering its patrol
   ---outlines the area the NPC is in; nil when none does, and the zone's marker owns the patrol.
   ---@param entry PolygonObjectiveEntry
   ---@param spawnData table The patrolling NPC.
   ---@param areaId AreaId
   ---@return PolygonMarker?
   local function _RouteOwner(entry, spawnData, areaId)
       local uiMapId = ZoneDB:GetUiMapIdByAreaId(areaId)
       if not uiMapId then return nil end
       for _, spawn in ipairs(spawnData.Spawns and spawnData.Spawns[areaId] or {}) do
           local x, y, instanceId = HBD:GetWorldCoordinatesFromZone(spawn[1] / 100, spawn[2] / 100, uiMapId)
           for _, marker in ipairs(entry.markers) do
               local cluster = marker.cluster
               local bounds = cluster and cluster.worldBounds
               if x and bounds and cluster.instanceId == instanceId and x >= bounds.minX and x <= bounds.maxX
                   and y >= bounds.minY and y <= bounds.maxY then
                   return marker
               end
           end
       end
   end
   ```
   - The bounds are the cluster's member-spawn extent in world yards (`B PolygonGeometry.lua:420-447`), the same fields `_IsPlayerNearby` reads (`B QuestiePolygon.lua:618-630`).
   - **Test:** in `QuestiePolygon.test.lua`'s "objective routes", *attaches a patrol to the cluster holding its NPC's spawn, not the zone's last marker*. Use two clusters in one zone, with the NPC's spawn inside the first.

**A needs from Area D (minimap).**
1. Minimap path hover keeps WP's semantics:
   - `WaypointHover.Set("minimap", path, path.owner.minimapTwin)`;
   - the bare-minimap rule with the shape cutoff;
   - reach `WaypointHover.Radius()`;
   - the private tooltip.
2. `MinimapLayer.Hover` returns a claim, and the canvas gives the layers beneath nil once. Its `_ReadCursor` returns nil in the gamepad UI. Both are F's deltas for D.
3. Minimap areas have no hover. Paths are stacked above areas.

**A needs from Area E (geometry and scheduling).**
1. `WaypointGeometry.Nearest(targets, x, y, radius)` keeps its semantics: the nearest target within radius, with the bounding box rejecting first (E 3.5).
2. Hover is presentation: it never yields (E 3.3).
3. Drawing order is areas, then lines, then icons. It now lives in `WorldMapLayers`' `LAYER_ORDER`; this is F's delta for E.

**A provides**
- The precedence policy and invariants I1–I7, which `WorldMapLayers` and the icon events encode.
- The rebase step R2 at `53b5e7ce4`, shared with C.
- The hover wording for the docs (§6), which F's commits apply.
- A5, and the D8 specification for C-F1.
