# Area A: hover arbitration

Who owns hover, highlights and GameTooltip on the world map and the minimap once blob is rebased onto waypoints.

- **Refs:** `WP` = `origin/waypoints` `7c1e28bd8`, `B` = `blob` `715031ef6`. Line numbers were checked against these commits.
- **Blizzard source** (Gethe wow-ui-source, read only, no runtime probes): `forever` `943764493e` (1.60.1 (70338)), `classic_era` `8165d4cd6e` (1.15.9 (70003)), `classic` 5.5.4 (70268), `classic_anniversary` 2.5.6 (70006).
- **Test-case data:** QuestieDB `data/Classic` and `data/Forever` NPC, quest and item tables (identical for the NPCs used below).

**In one paragraph.** Hover follows draw order: anything with mouse focus (Questie icons, Blizzard pins, other UI) beats patrol paths, which beat quest areas, which beat the bare map. One function owns that rule on the world map, `WaypointMap.IsMapUncovered()`. Areas use it as their `isCursorOnMap`, which replaces `IsLineFrame`. Every hover owner ends its tooltip only through the owner-safe `MapIconTooltip.Release`. Area B's F1 makes those edits, so A's former A3 is folded into it. Every icon hover is undone by one function, `QuestieFrame.ResetHoverHighlights(icon, data)`. Section 3.10 settles which code calls the hover begin and end effects that Area B's F4 moves out of `MapIconTooltip`. The plan adds no arbiter module and keeps both world-map pollers.

**Reconciled with the other plans** (read, not edited): Area B's `B-tooltip-api.md` (F1 `Release`, `GetOwner` and `Redraw`; F4 relocation) and Area C's `C-quest-drawing.md` (R2 is the same rebase edit as 4a here; route ownership stays per zone, which is decision D8).

---

## 1. Problem

### 1.1 What each branch does today

**WP, world map paths.**
- `WaypointMap` runs one `OnUpdate` driver on the canvas while the map is open (`WP Modules/Map/Waypoints/WaypointMap.lua:153-188`).
- It reads the cursor in canvas units (`_ReadCursor`, `:117-123`). It counts the cursor as on the map only when `GetMouseFocus() == WorldMapFrame.ScrollContainer` (`_IsCursorOnMap`, `:127-129`).
- When the cursor moves, or after a redraw or zoom step, it picks the nearest path within `WaypointHover.Radius() / scale` (`:133-143`, through `WP WaypointGeometry.lua:388-405`). Then it calls `WaypointHover.Set("map", path, path.owner)`.
- Paths draw at frame level 2015 (`WP WaypointMap.lua:18`), below Questie's icons at 2016 and up (`WP Modules/Map/QuestieMapUtils.lua:53-56`). They take no mouse input (`WP WaypointRenderer.lua:77`, `:256`).

**WP, hover state.**
- `WaypointHover` keeps one hovered path across both maps (`WP Modules/Map/Waypoints/WaypointHover.lua:25-30`, `:108-119`).
- On the world map, `_Enter` calls the owner icon's own `OnEnter` (`:53-56`). A hovered path therefore shows exactly the icon's tooltip and highlight.
- On the minimap, it renders onto a private `QuestieWaypointMinimapTooltip` owned by `Minimap` (`:35-38`, `:45-51`).
- `End(icon)` lets another icon's tooltip end the path hover first (`:125-127`). It is called at the top of `MapIconTooltip:Show` (`WP Modules/Tooltips/MapIconTooltip.lua:65-69`).
- `_Leave` (`:72-100`) hands the hover over when the cursor moves onto the icon (`:85`). It calls the icon's `OnLeave` while the icon still owns GameTooltip (`:93-95`). Otherwise it resets the NPC's highlights and clears `GameTooltip._Rebuild` and `GameTooltip.ShownAsMapIcon` (`:86-91`).

**WP, minimap.**
- `WaypointMinimap` hovers only over the bare minimap, inside its shape (`WP WaypointMinimap.lua:283-298`). It calls `WaypointHover.Set("minimap", path, path.owner.minimapTwin)` (`:303-310`).
- The minimap tooltip has to be private on Forever. There, `MinimapMixin:OnEnter` installs `Minimap_OnUpdate`, which runs `GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")` and `GameTooltip:SetMinimapMouseover()` every frame (`forever Interface/AddOns/Blizzard_Minimap/Mainline/Minimap.lua:242-245`, `:269-272`).

**Questie's icons, the same on both branches except where noted.**
- Every pooled icon's `OnEnter` is `MapIconTooltip.Show` (`WP Modules/FramePool/QuestieFramePool.lua:56`). Polygon markers come from the same pool (`B Modules/Map/QuestieMap.lua:696-697`, `:712-713`).
- `ShowOnTooltip` applies the hover's side effects:
  - the route highlight, `QuestieWaypoints.SetHighlighted(self.data, true)` (`WP MapIconTooltip.lua:117`);
  - the tints on same-quest icons, `touchedPins` (`:148-164`);
  - in B only, `QuestiePolygon.EnterMarker(self)` for polygon markers (`B MapIconTooltip.lua:79`).
- `OnLeave` hides GameTooltip and clears `_Rebuild` and `ShownAsMapIcon` unconditionally, then calls `ResetHoverHighlights` (`WP Modules/FramePool/QuestieFrame.lua:140-152`). B first calls `QuestiePolygon.LeaveMarker(self)` (`B QuestieFrame.lua:141`).

**B, areas.**
- Polygon frames take no mouse input (`B Polygon/PolygonRenderer.lua:32-33`, `:403-404`).
- The renderer's own driver polls the cursor while areas are visible and hit-tests only when the cursor moves (`:193-240`), and again when views are published (`:452`).
- `UpdateHover` hovers every outline that contains the cursor, but only when `hoverInput.isCursorOnMap()` is true (`:161-189`). It unions that set with marker highlights and reports to `onHover`.
- The adapter supplies two functions:
  - `isCursorOnMap = focus == scrollContainer or QuestieFramePool.IsLineFrame(focus)` (`B Polygon/QuestiePolygon.lua:998-1001`);
  - `onHover = _UpdateAreaTooltip` (`:1002`).
- `_UpdateAreaTooltip` (`:341-374`) shows the markers' map icon tooltip, owned by `WorldMapFrame.ScrollContainer`, through `MapIconTooltip.ShowForIcons`. It ends that tooltip with `MapIconTooltip.Release`, which is owner-safe (`B MapIconTooltip.lua:501-512`).
- Areas draw at `PIN_FRAME_LEVEL_QUEST_BLOB`, which B reads at runtime (`B QuestiePolygon.lua:283`). On Forever this is the seventh level Blizzard adds above the 2000 default (`forever Blizzard_WorldMap/Blizzard_WorldMap.lua:272-278`; `Blizzard_MapCanvas/MapCanvas_PinFrameLevelsManager.lua:3`, `:65-74`). That is about 2007, below the paths' 2015. Classic flavors add fewer levels before it (`classic_era Blizzard_WorldMap/Vanilla/Blizzard_WorldMap.lua:218`).

**Gamepad, identical on master, WP and B.**
- In Forever's gamepad UI, Blizzard's canvas drives pin enter and exit from the gamepad cursor (`forever Blizzard_MapCanvas/Blizzard_MapCanvas.lua:1245+`).
- Questie hides its pins from that cursor (master `ae8410da8`, "the gamepad map cursor used Questie pins outside of secure code, which tainted the map"). Instead it finds the hovered icon itself every 0.05 s and renders the tooltip on a private `QuestieGamepadMapTooltip`, "because using GameTooltip from there taints the gamepad UI again" (master `00f19de8f`; `Modules/Map/GamepadMapHover.lua:22-27`, `:97-107`).
- `Leave` resets with `QuestieFrame.ResetHoverHighlights({data = hoveredData})` (`:109-119`).

**Shift redraw.**
- `ModifierStateChanged` rebuilds GameTooltip only (`WP Modules/EventHandler/EventHandler.lua:499-509`).
- B adds a check that the tooltip's `_owner` still owns it (`B EventHandler.lua:501-502`).
- Nothing redraws WP's minimap tooltip or the gamepad tooltip (`WP docs/waypoints.md:228`).

### 1.2 Where they collide in the combined code

| # | What breaks | Evidence |
|---|---|---|
| P1 (finding 1) | `isCursorOnMap` calls `QuestieFramePool.IsLineFrame`, which WP deletes. While areas are shown, `UpdateHover` calls it on every cursor move over the canvas (`B PolygonRenderer.lua:166-168`). Whenever the top focus is not the scroll container (any icon, pin or UI), the call fails, so the Lua error repeats in an OnUpdate. Tests stay green because they stub it. | `B QuestiePolygon.lua:998-1001`; `B QuestiePolygon.test.lua:105,174,185` |
| P2 (finding 7) | **Tug-of-war.** Over a path that crosses an area, both layers see the bare map. Whichever driver runs second takes GameTooltip. On the next cursor move, `_UpdateAreaTooltip(shapes, false)` finds the tooltip no longer owned by the scroll container and shows it again (`B :350`, `:368`), while `WaypointHover.Set` does nothing for the same path (`WP WaypointHover.lua:109`). The area tooltip stays up while the path stays highlighted. Crossing to another path flips it back. | as cited |
| P3 | **`_Leave` clobbers the area tooltip.** When the cursor leaves a path but stays in an area, `_Leave` sees another owner and clears `_Rebuild` and `ShownAsMapIcon` (`WP WaypointHover.lua:86-91`). The area tooltip loses its Shift redraw. Questie's tooltip hooks also stop treating it as a map tooltip (`WP Tooltip.lua:517`, `:666`, `:731`), so Classic's per-frame object hook can append object lines to it (`:646-672`). | as cited |
| P4 | **Gamepad UI.** In the gamepad UI, WP's path hover still runs the icon's `OnEnter` from `WaypointMap`'s OnUpdate, which is exactly the GameTooltip use `00f19de8f` avoids. B guards areas with `InputUtil and InputUtil.IsGamepadUIEnabled()` (`B QuestiePolygon.lua:345-346`). But `InputUtil` exists on every Classic client and only Forever defines `IsGamepadUIEnabled` (`forever Blizzard_SharedXML/Mainline/InputUtil.lua:11-13`; nothing under `Interface/` on `classic_era`, `classic` or `classic_anniversary` mentions it, though all three load an `InputUtil` table from `Blizzard_SharedXML/InputUtil.lua`). **On Era, Anniversary and Progression, hovering an area with area tooltips on raises a Lua error every cursor move.** This is a latent B bug, outside the `pcall` at `:368`. | as cited |
| P5 | **Stuck preview.** Gamepad `Leave` passes `{data = ...}`, so `LeaveMarker` never runs. A polygon marker hovered with the gamepad keeps previewing its objective's areas and highlighting its outline until the map changes or closes (`B QuestiePolygon.lua:411-441`). WP's `_ResetTooltipChanges` has the same gap for paths owned by polygon markers when another owner holds the tooltip (`WP WaypointHover.lua:65-67`). | as cited |
| P6 | **Shift redraw.** It never reaches `QuestieWaypointMinimapTooltip` or `QuestieGamepadMapTooltip`. WP's minimap tooltip records `_owner = icon` but is owned by `Minimap` (`WP MapIconTooltip.lua:92-93`), so B's `IsOwned(_owner)` check would refuse it even if it were reached. | as cited |
| P7 | **Route highlight on markers.** See 1.3. | |
| P8 | **Docs that become wrong:** `B Polygon/README.md:13` ("icons and waypoint lines keep their own tooltips"), `:21`, `:110` (lines count as bare map), `:198`; `B BLOB-PARITY.md:20`, `:45`; `WP docs/waypoints.md:279-281`. | |
| P9 (minor) | Gamepad hover measures to the pin's un-nudged center (`GamepadMapHover.lua:83`). Polygon markers in one stack share that center and are nudged only inside their pins (`B Polygon/PolygonNudging.lua:164-176`). The gamepad cursor cannot pick individual stacked markers. | as cited |

### 1.3 The unverified claim about route highlights

The claim: hovering a polygon marker or cluster may not highlight routes, "because `WaypointHover` hooks the icon's own `OnEnter`". The mechanism it names is wrong. `WaypointHover` installs no hook. It *calls* the owner's `OnEnter` when a path is hovered (`WP WaypointHover.lua:53-56`).

The actual trace in the combined code:
- A marker is a pooled frame whose `OnEnter` is `MapIconTooltip.Show`. That runs `WaypointHover.End(self)`, then `ShowOnTooltip`, which runs `EnterMarker(self)` and `QuestieWaypoints.SetHighlighted(self.data, true)`.
- So **any** marker whose data owns paths highlights them. The gaps are about who owns the paths:
  1. **Attribution.** Blob mode overwrites `iconPerZone[point.areaId]` for each cluster (`B QuestiePolygon.lua:1035`), and every route of the objective in that zone is drawn on that one entry (`B Modules/Quest/QuestieQuest.lua:1390-1396`). Only the zone's *last* cluster marker highlights routes, and it highlights all of them. Hovering a path opens that marker's tooltip and highlights its outline, which may be the wrong cluster.
  2. **Minimap.** Cluster minimap icons get their own data (`B QuestiePolygon.lua:1041`) and no `minimapTwin`. Fallback markers get two separate data copies (`B QuestieQuest.lua:1373-1375`). `QuestieWaypoints.MinimapAlpha` needs a twin with `twin.data == path.data` (`WP QuestieWaypoints.lua:134-140`). So blob-mode routes never draw or hover on the minimap, and hovering a cluster's minimap icon highlights nothing.
  3. **Gamepad leave.** P5.
- Hover code needs no change for 1 and 2. They are contracts on Area C (section 9).

---

## 2. Comparison

| Aspect | WP (paths) | B (areas) | Keep |
|---|---|---|---|
| Hit test | Nearest path within the capsule distance; bounding box rejects first | Every outline containing the point, overlaps included; bounding box rejects first | Both. They answer different questions. |
| When it runs | Each frame while the map is open; full check on cursor move, redraw or zoom | Each frame while areas are visible; full check on cursor move or publication | Both drivers (see 3.7, R8) |
| What covers it | Focus is not the scroll container | The same, except a line frame counts as bare map | WP's focus rule, plus paths cover areas. Drop `IsLineFrame`. |
| Tooltip | The owner icon's own `OnEnter`, so the tooltip and highlight match hovering the icon. Minimap: private tooltip. | `ShowForIcons(ScrollContainer, markers, swatch)`, wrapped in `pcall` and retried on change | Both |
| Ending a tooltip | `_Leave` clears another owner's state | `Release(owner)` clears only its own state and hides only if it still owns the tooltip | B's `Release`, used by every owner |
| Shift | GameTooltip only | Adds the ownership check | B's check, extended to the private tooltips (Area B) |
| Gamepad | No check | Checked, but crashes off Forever | One capability-guarded rule |
| Highlight | Per-data path highlight; one hovered path across both maps | Geometric hover unioned with marker highlights; preview flags kept separately | Both. Clean separation already. |
| Undo | `ResetHoverHighlights({data})` misses polygon previews | `LeaveMarker` only in the icon's `OnLeave` | One undo function taking `(icon, data)` |
| Combat | Nothing takes mouse input | The same since `53b5e7ce4` | Both |

**From WP, keep:**
- capsule hover and the `WaypointHover` state machine with its `End` handshake;
- "hovering a path is hovering its NPC's icon";
- the private minimap tooltip;
- paths that take no mouse input.

**From B, keep:**
- cursor-computed area hover, unioned with marker highlights;
- owner-safe `Release` and the record of who rendered the tooltip;
- the Shift ownership check and gamepad awareness, fixed;
- the area tooltip with swatches and `pcall` resilience.

---

## 3. Target design

### 3.1 Precedence, as the player sees it

| Cursor over | Tooltip | Highlighted |
|---|---|---|
| A Questie icon, including a polygon marker, cluster or fallback | The icon's tooltip, with nearby icons, on GameTooltip | Routes on the icon's data and same-quest icon tints. For a polygon marker, also its outline and its objective's area preview. |
| A Blizzard pin, the quest log or other UI | Theirs | Nothing from Questie |
| A path within hover reach, over the bare map, **including where it crosses an area** | The path's NPC icon tooltip, through the icon's `OnEnter` | All of that NPC's routes on both maps. If the NPC's icon is a polygon marker, its outline and preview too. **Areas under the path do not highlight.** |
| Areas, with no path in reach | The area tooltip: all hovered areas' markers, with swatches | Every hovered outline |
| Bare map | None | None |
| Gamepad UI on (Forever) | Only the gamepad cursor's icon, on `QuestieGamepadMapTooltip`. Paths and areas don't hover from the mouse cursor. | The gamepad-hovered icon's routes and outline |
| Minimap: a Questie minimap icon | The icon's tooltip on GameTooltip | Routes on its data |
| Minimap: a path, bare minimap, inside its shape | The NPC's tooltip on `QuestieWaypointMinimapTooltip` | That NPC's routes |
| Minimap: an area | Nothing. Minimap areas have no hover. | — |

### 3.2 Why the path wins over the area, evaluated critically

**Arguments for the path:**
1. **What you see on top is what you hover.** Paths draw above areas (2015 against roughly 2007) and below icons (2016 and up). Icons already beat areas in B. Paths following the same rule leaves one rule for the player and for future layers.
2. **Intent.** A path is a thin target, 2.5 map units on each side of the line at the default width (`WP WaypointHover.lua:134-136`). Putting the cursor on it is deliberate. Resting inside a broad translucent fill is not.
3. **Both stay reachable.** With the path winning, the area tooltip appears anywhere off the lines. With the area winning, patrol paths that run through other objectives' areas could not be hovered at all, which is exactly where the player is hunting. A real example: in Durotar, quest 826 "Zalazane". Zalazane patrols x 67.1–67.8, y 86.2–87.8, inside the Hexed Troll (x 65.9–68.8, y 83.0–88.7) and Voodoo Troll spawn extents of the same quest.
4. **One tooltip, one focus.** What is highlighted is what the tooltip describes. The one exception is the outline of a path's own NPC marker, which belongs to the same NPC.

**Arguments against, and the answers:**
- *The tooltip switches as you cross lines inside an area.* The reach is tight, one unit past the line's edge. For objective NPCs the path tooltip repeats the same objective, so the content rarely changes in substance. Accept it, and revisit with in-game feedback.
- *A combined tooltip (path NPC plus areas) would avoid the switching.* It would make two layers share one tooltip and one highlight, with no clear owner for `Release`. WP already rejected combined tooltips for overlapping paths (`WP docs/waypoints.md:207`). Rejected (R6).
- *Areas could keep highlighting under paths while the path takes the tooltip,* which was B's old line exception (`B Polygon/README.md:110`). That shows an outline whose tooltip isn't on screen. The exception only existed because old line frames had hit rectangles the size of each segment's bounding box. Rejected (R7).

**Verdict:** David's lean holds. The path wins, and the reason is draw order, not only specificity.

### 3.3 Modules and ownership

| Module | Owns, for hover | Change |
|---|---|---|
| `WaypointMap` (WP) | **The world-map rule for when drawn layers may hover:** mouse focus, gamepad UI, path precedence. The path hit test. | Adds `IsMapUncovered()`; adds the gamepad clause |
| `WaypointHover` (WP) | The one hovered path on either map; the handshake with icons | `_Leave` ends tooltips through `Release` (Area B's F1); undoes through `ResetHoverHighlights(icon, data)` (A4) |
| `WaypointMinimap` (WP) | Minimap path hit test and the bare-minimap rule | None |
| `PolygonRenderer` (B) | Area hit test, highlight union, its own driver | Annotation only |
| `QuestiePolygon` (B) | Area tooltip; marker enter, leave and preview | `isCursorOnMap` calls `WaypointMap.IsMapUncovered()`. `_UpdateAreaTooltip` drops its own focus and gamepad checks. |
| `QuestieFrame` | The icon hover pair: begin (after Area B's F4) and `ResetHoverHighlights`, the one undo; icon `OnEnter` and `OnLeave` | `OnLeave` goes through `Release` (Area B's F1); `LeaveMarker` moves into the undo (A4); the begin effects arrive with F4, following 3.10 |
| `GamepadMapHover` | Gamepad icon hover on a private tooltip | `Leave` passes the real icon. Optional: picks nudged markers apart. |
| `MapIconTooltip` (Area B) | Rendering and the tooltip state contract | Nothing from A. Area B's F1 makes its state private; F4 drops the hover side effects. See 3.10 and section 9. |

### 3.4 Interface (LuaCATS)

New:

```lua
---Whether nothing covers the world map under the cursor: no UI on top of it, the gamepad UI is off,
---and no patrol path is within hover reach. Layers drawn beneath the paths, such as quest areas,
---hover only then, so a path wins over them the way Questie's icons win over paths. It reads the
---cursor itself, never the hovered path, so it holds whichever map driver runs first in a frame.
---@return boolean
function WaypointMap.IsMapUncovered() end
```

Changed signature (extended; callers updated in A4):

```lua
---Undoes what hovering an icon changed: its NPC's path highlight, the icons its tooltip tinted and a
---polygon marker's area preview. Every way an icon hover ends calls it: the icon's OnLeave, a path
---hover ending (WaypointHover) and the gamepad cursor moving on (GamepadMapHover).
---@param icon IconFrame The hovered icon. It is pooled, so it may show other data by now.
---@param data IconData? The data it was hovered with; icon.data when nil.
function QuestieFrame.ResetHoverHighlights(icon, data) end
```

Relied on and unchanged: `WaypointHover.Set(on, path?, icon?)`, `WaypointHover.End(icon)`, `WaypointHover.Radius()`, `QuestiePolygon.EnterMarker(frame)` and `LeaveMarker(frame)`, `WaypointGeometry.Nearest(targets, x, y, radius)`, and Area B's `MapIconTooltip.Release(owner, Tooltip)`.

### 3.5 Data flow per frame

```text
Engine mouse focus -> icon / pin / UI OnEnter, OnLeave           (always wins: it holds the focus)
  icon OnEnter = MapIconTooltip:Show -> WaypointHover.End(icon) -> ShowOnTooltip
                 (EnterMarker, route highlight, tints; GameTooltip owned by the icon)
                 [after Area B's F4: End -> QuestieFrame.ApplyHoverHighlights -> ShowOnTooltip, see 3.10]
  icon OnLeave -> MapIconTooltip.Release(icon, GameTooltip) -> ResetHoverHighlights(icon)

WaypointMap driver (map open)
  redraw or zoom step, or cursor moved -> _IsCursorOnMap()   [focus is the scroll container, not gamepad UI]
                                       -> _PathAt(x, y)       -> WaypointHover.Set("map", path, path.owner)
                                          (owner's OnEnter, or Release plus ResetHoverHighlights on leave)

PolygonRenderer driver (areas visible)
  cursor moved or views published -> isCursorOnMap() = WaypointMap.IsMapUncovered()
                                     [the same rule, and no path within reach of the cursor now]
                                  -> hovered outlines unioned with marker highlights -> _UpdateAreaTooltip
                                     (ShowForIcons(ScrollContainer) or Release(ScrollContainer))

GamepadMapHover (Forever gamepad UI, 20 Hz)
  icon near gamepad cursor -> ShowOnTooltip(icon, QuestieGamepadMapTooltip)
  moved on                 -> ResetHoverHighlights(icon, data); hide the private tooltip

WaypointMinimap driver (paths in reach)
  bare minimap inside its shape -> WaypointHover.Set("minimap", path, path.owner.minimapTwin)
                                   (QuestieWaypointMinimapTooltip, owned by Minimap)
```

### 3.6 Invariants

- **I1. Hover follows draw order.** Order: frames with mouse focus, then paths (2015), then areas (quest-blob level), then the bare map. A drawn layer hovers only where every layer above it leaves the map uncovered.
- **I2. Precedence uses current state, not stored hover state.** It is computed from the current cursor and current geometry, never from another layer's stored hover. The order in which `OnUpdate` scripts run therefore cannot change the outcome. Blizzard doesn't define that order.
- **I3. One layer, one tooltip.** At most one drawn layer hovers per surface. What is highlighted is what the tooltip describes.
- **I4. Owner-only release.** A hover ends its tooltip only through `MapIconTooltip.Release(owner, Tooltip)`, which forgets only that owner's state. Nobody touches another owner's tooltip state: today that is the `_Rebuild` and `ShownAsMapIcon` fields, and after Area B's F1 it is `MapIconTooltip`'s private state.
- **I5. One undo.** `QuestieFrame.ResetHoverHighlights(icon, data)` undoes every side effect of an icon hover, however the hover ends.
- **I6. No GameTooltip from per-frame code in the gamepad UI.** Drawn layers don't hover there. The gamepad and minimap hovers use private tooltips.
- **I7. No mouse input on anything drawn.** Hover needs no protected call, in or out of combat.

### 3.7 Why this holds up later without overbuilding

- **A new drawn layer** (no mouse input) hovers only where the layer directly above it reports the map uncovered. It exports the same query for the layer below. Today the chain has one link, `WaypointMap.IsMapUncovered` feeding areas. A layer inserted between two existing ones changes one call site, in the layer beneath it. I1 and I2 keep holding.
- **Mouse-enabled UI** needs nothing from this design. That includes the Forever quest log boxes (`B Polygon/PolygonQuestLogForever.lua:39`, `:59`, `:98-99`), new pins and other addons. Mouse focus already covers drawn layers, and the boxes already end their own tooltips owner-safely with `IsOwned(box)`.
- **I4 and I5** mean a new layer cannot break another layer's tooltip or highlight state, even if precedence were wrong for a frame.
- **When to build an arbiter:** a third drawn layer on one surface, or hover for minimap areas. A `MapHover` module would then own the cursor sample, the focus and gamepad rule and an ordered layer list (`AddLayer(rank, hit, hover)`) with one poller per surface. `IsMapUncovered` would become its query. Until then, that module would serve two layers on one surface and one on the other.

### 3.8 Combat and taint

- **No protected calls.** Nothing in this design changes mouse input or calls a protected function. The reads are `GetMouseFoci` through `QuestieCompat.GetMouseFocus`, `GetNormalizedCursorPosition`, `IsMouseOver`, `GetCursorPosition`, and `InputUtil.IsGamepadUIEnabled`, which is a plain `C_InputInterfaceStyle` read (`forever Blizzard_SharedXML/Mainline/InputUtil.lua:11-13`). GameTooltip's `SetOwner`, `Show` and `Hide` are not protected.
- **Combat deferrals are moot.** B's `SetPropagateMouseMotion` deferrals (`f9358650b`, `d9dc1ca4d`) were removed for polygons in `53b5e7ce4`. For lines they go away with Area C.
- **Taint risks, and how each is handled:**
  1. *GameTooltip from per-frame code in the gamepad UI:* gated in one place (A2). This also covers WP's path hover, which currently isn't gated.
  2. *Questie's custom fields on GameTooltip* (`_Rebuild`, `_owner`, `_mapIconOwner`, `ShownAsMapIcon`): these are Questie-only keys. Never write Blizzard-owned fields.
  3. *Mouse focus may be a restricted frame:* only identity comparisons are made, and B's comment about `IsLineFrame` already relied on that.
  4. *The minimap:* Forever's `Minimap_OnUpdate` writes GameTooltip each frame, and the private tooltip keeps Questie out of that.

### 3.9 Rejected alternatives

- **R1. One hover arbiter per surface now.** It is correct by construction and merges the pollers. But it needs rewriting `PolygonRenderer`'s hover driver, about 20 renderer hover tests, and `WaypointMap`'s hover, all for two layers. Build it at the trigger in 3.7.
- **R2. A shared cursor-sample or "bare map" helper module.** It saves two C calls per frame and settles nothing about precedence.
- **R3. Areas reading `WaypointHover`'s stored hover.** That depends on driver order. It brings back a one-frame tug-of-war and leaves stale outlines under a still cursor.
- **R4. Precedence by tooltip ownership** ("don't take GameTooltip if an icon owns it"). It depends on order and leaves the highlights fighting.
- **R5. The area wins over the path.** Paths inside areas become impossible to hover (3.2).
- **R6. A combined path-and-area tooltip.** Shared state with no owner (3.2).
- **R7. Areas keep highlighting under paths.** The highlight and the tooltip disagree (3.2).
- **R8. Merging the two world-map pollers.** They have different lifetimes: WP's draws whenever the map is open, B's runs only while areas show. Each returns early unless the cursor moved, and I2 makes their order irrelevant. Merging would entangle WP's redraw scheduling with B's renderer lifecycle.
- **R9. Area B's fallback for (e): move `EnterMarker` into `Show`, for mouse hover only.** Gamepad hover would then stop previewing areas altogether. A4 fixes the gamepad leave instead, so the gamepad keeps the preview.

### 3.10 Hover begin and end: which code calls them (Area B's F4 asks)

Area B's F4 moves the hover's *begin* effects out of `MapIconTooltip` so that it renders tooltips only (`B-tooltip-api.md` 3.6). A agrees. Pairing each begin with its end in one module removes the class of bugs behind P5. The call graph after F4:

```lua
---Applies what hovering an icon shows besides its tooltip: a polygon marker's area preview, its NPC's
---path highlight, and the tint on its quest's other icons. Does nothing for an icon faded out to
---alpha 0, which shows no tooltip either. Undone by ResetHoverHighlights.
---@param icon IconFrame
function QuestieFrame.ApplyHoverHighlights(icon) end
```

| Who | Begin | End |
|---|---|---|
| Icon `OnEnter` (mouse), which replaces `MapIconTooltip:Show` | `WaypointHover.End(icon)`, then `QuestieFrame.ApplyHoverHighlights(icon)`, then `MapIconTooltip.ShowOnTooltip(icon, GameTooltip)` | `OnLeave`: `MapIconTooltip.Release(icon, GameTooltip)`, then `ResetHoverHighlights(icon)` |
| `WaypointHover`, world map | The icon's `OnEnter` (unchanged) | The icon's `OnLeave` while it still owns the tooltip and shows the path's data; otherwise `Release(icon, GameTooltip)` and `ResetHoverHighlights(icon, path.data)` |
| `WaypointHover`, minimap | `SetHighlighted(path.data, true)` (unchanged), then `ShowForIcons(Minimap, ...)` (Area B's F2) | `Release(Minimap, tooltip)` and `ResetHoverHighlights(twin, path.data)` |
| `GamepadMapHover` | `ApplyHoverHighlights(icon)`, then `ShowOnTooltip(icon, QuestieGamepadMapTooltip)` | `ResetHoverHighlights(icon, data)`, then hide |
| Areas | `ShowForIcons(ScrollContainer, ...)` only, with no begin effects | `Release(ScrollContainer, GameTooltip)` |

Ordering rules F4 must keep:
- `WaypointHover.End` runs first in the mouse `OnEnter`, so a path's tints are restored before the new icon tints. It stays out of `ApplyHoverHighlights`: in the gamepad UI no path hover exists (A2).
- `ApplyHoverHighlights` runs before the tooltip's 0.05 s throttle, so a throttled refresh still previews. B's test "previews polygon markers even when the tooltip refresh is throttled" pins this.

On the name: the pair keeps `ResetHoverHighlights`, which avoids renaming it across three callers and two plans. If David prefers `BeginHover`/`EndHover`, F4 can rename both in one commit.

---

## 4. Sequencing

### 4a. During `git rebase --onto waypoints origin/master blob`

The aim is the minimum so that every replayed commit loads and passes tests without a runtime nil call. Only one commit needs an A edit. The others only need hover hooks preserved by whoever resolves them.

1. **`feat(polygon): integrate cached objective areas with Questie`** (`dfb97c802`). Conflicts in `MapIconTooltip.lua` (Area B resolves) and possibly `QuestieFrame.lua` (Area C). Hover needs the resolution to keep:
   - `WaypointHover.End(self)` as the first line of `MapIconTooltip:Show`;
   - WP's `ShowOnTooltip(self, Tooltip, owner, icons)` and its `alpha == 0 and not owner` check, followed by B's `if self.polygonMarker then QuestiePolygon.EnterMarker(self) end` *before* the throttle;
   - WP's `QuestieWaypoints.SetHighlighted(self.data, true)` in place of the `lineFrames` loop;
   - `QuestiePolygon.LeaveMarker(self)` at the top of `_QuestieFrame.OnLeave`, and WP's body of `ResetHoverHighlights`.
2. **`refactor(polygon): compute area hover from the cursor, not mouse propagation`** (`53b5e7ce4`). Git stops on `QuestieFramePool.lua` (Area C deletes `IsLineFrame`). **A's change goes into the same resolution.** Area C's R2 specifies the identical edit, so one resolver applies it once:
   - `Polygon/QuestiePolygon.lua` (at this commit, `:798-809`):
     ```lua
             -- Area hover counts only over the bare map. Anything on top, including Questie's icons,
             -- Blizzard's pins, and other UI, hides the areas beneath it.
             ...
                 isCursorOnMap = function()
                     return QuestieCompat.GetMouseFocus() == scrollContainer
                 end,
     ```
   - `Polygon/QuestiePolygon.test.lua` (at this commit, `:162-186`): rename the test to "reads the map cursor and counts only the bare map as uncovered". Delete `local line = {}`, the `FramePool.IsLineFrame = ...` stub and the `focus = line` assertion pair.
   - Leave the `savedIsLineFrame` scaffolding (`:5`, `:100`, `:159`) alone. It saves and restores nil harmlessly. Editing `:5` would conflict again in `d674119b6` and `4f76fd411`. Area C deletes it after the rebase.
   - Leave `Polygon/README.md` here, because nine later commits rewrite it. A1 fixes it.
   - Later commits don't touch the edited test lines, so no further conflicts arise from this.
3. **`chore: wip snapshot of uncommitted blob work`** (`715031ef6`). It adds `onHover = _UpdateAreaTooltip,` one line after the edited `isCursorOnMap`. Git normally merges this cleanly. If it conflicts, keep the rebased `isCursorOnMap` and add `onHover`. Nothing else is needed for A. The EventHandler ownership check applies cleanly because WP doesn't touch that file.

Nothing else is needed from A. `8003dabb0`, `f9358650b` and `d9dc1ca4d` touch only polygon frames and line frames (Area C). Between `8003dabb0` and `53b5e7ce4^`, polygon frames are mouse-enabled, so paths don't hover inside areas in those intermediate commits. That is expected and needs no action.

### 4b. Follow-up commits after stacking

Plain Conventional Commits without brackets, since these are internal steps of an unreleased feature. The order is A1, A2, A4, then optional A5. A3 moved to Area B's F1. A4 needs Area C's resolution of `QuestieFrame.lua`. **A4 lands before Area B's F4**, which adds `ApplyHoverHighlights` next to A4's `ResetHoverHighlights` (3.10). File ownership for these commits: A edits `WaypointMap.lua`, `GamepadMapHover.lua`, and the hover parts of `QuestiePolygon.lua` and `PolygonRenderer.lua`. A and Area B's F1 both touch `QuestieFrame.lua` and `WaypointHover.lua`, but on different lines (`ResetHoverHighlights` and `_ResetTooltipChanges` for A; `OnLeave` and the release lines in `_Leave` for B). Whichever lands second rebases trivially.

**A1. `fix(polygon): let patrol paths cover the quest areas beneath them`**

- `Modules/Map/Waypoints/WaypointMap.lua`: extract `_PathAt` from `_UpdateHover` and add `IsMapUncovered`. Keep the hover comment block at `:125-126`.
  ```lua
  ---The drawn path within hover reach of a cursor in canvas units; the nearest where reaches overlap.
  ---@param x number
  ---@param y number
  ---@return WaypointMapView?
  local function _PathAt(x, y)
      if not visible[1] then return nil end
      return WaypointGeometry.Nearest(visible, x, y, WaypointHover.Radius() / currentScale)
  end

  local function _UpdateHover(force)
      local x, y = _ReadCursor()
      if not force and x == cursorX and y == cursorY then return end
      cursorX, cursorY = x, y
      local nearest
      if x and _IsCursorOnMap() then nearest = _PathAt(x, y) end
      local path = nearest and nearest.path
      WaypointHover.Set("map", path, path and path.owner)
  end

  function WaypointMap.IsMapUncovered()      -- doc comment as in 3.4
      if not _IsCursorOnMap() then return false end
      -- Before the first draw there is no path, nor a canvas size to convert the cursor with.
      if not visible[1] then return true end
      local x, y = _ReadCursor()
      return not (x and _PathAt(x, y))
  end
  ```
- `Polygon/QuestiePolygon.lua`:
  - import `WaypointMap`;
  - pass `isCursorOnMap = function() return WaypointMap.IsMapUncovered() end`, a closure so a stub or reload binds late;
  - rewrite the comment above it to: "Areas draw beneath patrol paths and Questie's icons. They hover only where nothing covers the map: UI on top of it, a path within hover reach, or the gamepad UI.";
  - in `_UpdateAreaTooltip`, drop `or QuestieCompat.GetMouseFocus() ~= owner`, which is now implied by empty `shapes`;
  - drop the now-unused `QuestieCompat` import (luacheck);
  - rewrite the area-tooltip comment block (`:322-326`): "The tooltip belongs to the map's scroll container. Areas count as hovered only where nothing covers the map (`WaypointMap.IsMapUncovered`), so Questie's icons and patrol paths show their own tooltips there, and the area tooltip returns once the cursor is back over bare map."
- `Polygon/PolygonRenderer.lua:36`: change the field annotation to `False while anything covers the map under the cursor: UI on top, or a layer drawn above the polygons.`
- Tests: section 5 (A1).
- Docs: section 6 (A1).

**A2. `fix(map): leave map hover to the gamepad cursor in the gamepad UI`**

The commit body should state that this also fixes area hover erroring on Era, Anniversary and Progression clients, whose `InputUtil` lacks `IsGamepadUIEnabled`.

- `Modules/Map/Waypoints/WaypointMap.lua`:
  ```lua
  -- Paths take no mouse input. They count as hovered only over the bare map, so Questie's icons,
  -- Blizzard's pins and other UI on top win. In the gamepad UI nothing drawn hovers: its cursor is
  -- not the mouse's, and opening GameTooltip from per-frame code taints that UI, which is why
  -- GamepadMapHover shows icon tooltips on a tooltip of its own. Only Forever's InputUtil has
  -- IsGamepadUIEnabled.
  local function _IsCursorOnMap()
      if InputUtil and InputUtil.IsGamepadUIEnabled and InputUtil.IsGamepadUIEnabled() then return false end
      return QuestieCompat.GetMouseFocus() == WorldMapFrame.ScrollContainer
  end
  ```
- `Polygon/QuestiePolygon.lua`: `_UpdateAreaTooltip` drops `or (InputUtil and InputUtil.IsGamepadUIEnabled())` and its comment (`:343-346`). Areas inherit the rule through A1. Its guard becomes `if #shapes == 0 or Questie.db.profile.polygonAreaTooltips == false then`.
- `GamepadMapHover.IsActive` keeps its unguarded call. It is safe because `GamepadMapHover` is initialized only on Forever (`WP Modules/QuestieInit.lua:428-430`).
- Tests and docs: sections 5 and 6 (A2).

**A3 is folded into Area B's F1, `refactor(tooltips): keep map icon tooltip state in MapIconTooltip`.** F1 already makes the two edits A3 needed (`B-tooltip-api.md` F1 file table):
- `_QuestieFrame.OnLeave` ends its tooltip with `MapIconTooltip.Release(self, GameTooltip)`;
- `WaypointHover._Leave` releases in its minimap branch, and in its "another frame took it" branch, instead of clearing `_Rebuild` and `ShownAsMapIcon` (`WP WaypointHover.lua:90`). That fixes P3.

One hover detail for F1 to keep: the icon branch of `_Leave` calls `OnLeave` only while `GameTooltip:IsOwned(icon)` and `icon.data == path.data`. When a recycled icon still owns the tooltip, WP's `GameTooltip:Hide()` (`:96-98`) can become `Release(icon, GameTooltip)` too, so every ending goes through one function. The P3 regression test moves with it (section 5).

**A4. `fix(polygon): end a marker's area preview however its hover ends`**

- `Modules/FramePool/QuestieFrame.lua`: the new `ResetHoverHighlights(icon, data)` (doc as in 3.4). Remove the direct `LeaveMarker` call from `OnLeave`.
  ```lua
  function QuestieFrame.ResetHoverHighlights(icon, data)
      data = data or icon.data
      QuestieWaypoints.SetHighlighted(data, false)
      -- A recycled icon's old marker ended its preview when it unloaded; a new marker's isn't ours.
      if icon.polygonMarker and icon.data == data then QuestiePolygon.LeaveMarker(icon) end
      if data.touchedPins then
          for i = #data.touchedPins, 1, -1 do
              local entry = data.touchedPins[i]
              entry.icon.texture:SetVertexColor(unpack(entry.color))
          end
          data.touchedPins = nil
      end
  end
  ```
- `Modules/Map/Waypoints/WaypointHover.lua`: `_ResetTooltipChanges(icon, path)` calls `QuestieFrame.ResetHoverHighlights(icon, path.data)`. Update both call sites in `_Leave`, and its comment: "The tooltip highlights the NPC's paths, tints its icons and may preview a polygon marker's areas; this undoes all three."
- `Modules/Map/GamepadMapHover.lua`: `Leave` calls `QuestieFrame.ResetHoverHighlights(hoveredIcon, hoveredData)`.
- Tests and docs: sections 5 and 6 (A4).

**A5 (optional, David decides). `fix(map): let the gamepad cursor pick markers nudged apart`**

- `Modules/Map/GamepadMapHover.lua`, `FindIconUnderCursor`: measure to the icon's own center, converted to the pin's scale, instead of the pin's un-nudged center:
  ```lua
  -- Measure to the icon, not its pin: polygon markers sharing a spot sit nudged apart inside their
  -- pins (PolygonNudging). The cursor position compares with pin coordinates, as for Blizzard's pins.
  local iconX, iconY = icon:GetCenter()
  local scale = icon:GetEffectiveScale() / pin:GetEffectiveScale()
  ```
- Un-nudged icons behave exactly as before.

---

## 5. Tests

These follow `AGENTS.md`: `dofile("setupTests.lua")` and `.was.called*` assertions. Each test names a behavior that was broken or is new.

**A1**
- `Modules/Map/Waypoints/WaypointMap.test.lua`, new `describe("covering the layers beneath")` using the existing harness (`Path()`, `Invalidate`, `Update`):
  - **"covers the map within a path's hover reach, reading the cursor itself".** Draw, then set `cursor = {0.5, 0.505}` *without* `Update()`. Expect `IsMapUncovered()` to be false and `OnEnter` not called. Then `cursor = {0.5, 0.6}` should give true. This proves I2: the answer comes from the current cursor, not from the stored hover, so it holds whichever driver runs first.
  - **"leaves the map covered where UI is on top".** With `focus = {}`, far from the path, expect false.
  - **"is uncovered over the bare map before any path is drawn".** No `Invalidate`, with `focus` the scroll container. Expect true and no error, even though the canvas size is still nil.
- `Polygon/QuestiePolygon.test.lua`:
  - Rename "reads the map cursor and counts only the bare map as uncovered" (from 4a) to **"reads the map cursor and yields wherever the paths' map rule says the map is covered"**. Stub `QuestieLoader:ImportModule("WaypointMap").IsMapUncovered` with a toggle and assert that `input.isCursorOnMap()` follows it. Restore the stub in `after_each`. This guards the wiring that fixes P1.
  - In "steps aside for other tooltips and returns once the cursor is back on the bare map" (`B :256-277`), delete the waypoint-line block (`:263-271`). Replace it with: another owner took the tooltip while the same areas stay hovered, and `onHover(shapes, false)` takes it back. "Leaving the areas ends the area tooltip" stays.
- `Polygon/PolygonRenderer.test.lua`: unchanged. Its existing "covered map means no hover" tests stay valid.

**A2**
- `WaypointMap.test.lua`, saving and restoring `_G.InputUtil`:
  - **"hovers nothing drawn in the gamepad UI".** With `InputUtil = {IsGamepadUIEnabled = function() return true end}` and the cursor on the line, `Update()` must not call `OnEnter`, and `IsMapUncovered()` must be false off the line.
  - **"hovers on clients whose InputUtil has no gamepad UI".** With `InputUtil = {}`, the shape on Era, Anniversary and Progression, `Update()` on the line calls `OnEnter` without erroring. This encodes P4's crash.
- `QuestiePolygon.test.lua`: "shows nothing while the setting is off or the gamepad UI is on" becomes "shows nothing while the setting is off". Drop the `InputUtil` part and its save and restore.

**A3, now in Area B's F1.** These are the hover-side tests F1 should carry:
- `Modules/Map/Waypoints/WaypointHover.test.lua`: replace "undoes the NPC's tooltip changes when another frame takes the tooltip" (`:106-119`) with **"ends only its own changes when another owner, such as a quest area, took the tooltip"**. A quest area holds the tooltip, then `Set("map", nil)`. Expect `OnLeave` not called and `Release` called with `(icon, GameTooltip)`. Expect the area's tooltip to remain current: `MapIconTooltip.GetOwner(GameTooltip)` still returns the area, using F1's state. This is P3 exactly.
- `Modules/Map/Waypoints/WaypointMap.test.lua`: add `IsOwned` to the GameTooltip stub (`:61`) and stub `MapIconTooltip.Release`. The real `WaypointHover` is loaded there.
- `Modules/FramePool/QuestieFrame.test.lua`: stub `MapIconTooltip.Release` in the "polygon marker interaction" `before_each`, and assert that `OnLeave` calls it with `(QuestieFrameInstance, GameTooltip)`.

**A4**
- `QuestieFrame.test.lua`, `describe("ResetHoverHighlights")`:
  - **"should end a polygon marker's preview".** Stub `QuestiePolygon.LeaveMarker`, set `polygonMarker = {}`, and expect `LeaveMarker` called with the icon.
  - **"should leave a recycled icon's new marker alone and end only the old data's highlights".** Call `ResetHoverHighlights(icon, oldData)`. Expect `LeaveMarker` not called and `SetHighlighted` called with `(oldData, false)`.
- `Modules/Map/GamepadMapHover.test.lua`: change the stub to `function(icon, data)`, recording both. In "should hide the tooltip and reset highlights when the cursor leaves the icon", add an assertion that the recorded icon is `pin.icon`. This proves a polygon marker's preview can end (P5). The other assertions stay on `data`.
- `WaypointHover.test.lua`: `called_with({data = data})` (`:54`, `:116`) becomes `called_with(icon, data)`.

**A5 (if taken)**
- `GamepadMapHover.test.lua`: **"picks the nudged marker nearest the cursor when stacked icons share a pin position".** Use two pins with one center and icons offset by ±6. Expect the cursor near one offset to pick that icon.

**Deleted:** none beyond the edits above. The `IsLineFrame` tests and scaffolding are Area C's.

---

## 6. Docs and comments

| File | Change | Commit |
|---|---|---|
| `Polygon/README.md:11` | "Leaving clears the preview" becomes: every way the hover ends clears it, including the icon leaving, a path hover ending and the gamepad cursor moving on | A4 |
| `Polygon/README.md:13` | Replace the last sentences: areas hover only where nothing covers the map, meaning Questie's icons, Blizzard's pins, other UI, or a patrol path within hover reach, which shows its NPC's tooltip instead. They don't hover in the gamepad UI. | A1, A2 |
| `Polygon/README.md:21` | "unless other UI covers the map there" becomes "unless anything covers the map there, a patrol path within hover reach included" | A1 |
| `Polygon/README.md:104-118` | Rewrite the `isCursorOnMap()` bullet (`:110`): the adapter asks `WaypointMap.IsMapUncovered()`, which requires the scroll container as top focus, the gamepad UI off, and no path within hover reach; paths draw above areas and below icons, and hover follows that order. Delete the explanation of line-rectangle hit areas. | A1 |
| `Polygon/README.md:198` | The validation list says "patrol paths crossing areas (the path's tooltip wins)" instead of "waypoint lines" | A1 |
| `BLOB-PARITY.md:20`, `:45` | Lines no longer count as bare map. The frame-level review is settled: paths stay above areas and hover follows. | A1 |
| `docs/waypoints.md:190-209` (Hover) | Add bullets: layers drawn beneath yield to paths through `WaypointMap.IsMapUncovered()`; paths don't hover in the gamepad UI | A1, A2 |
| `docs/waypoints.md:52` (Integration) | `QuestieFrame.ResetHoverHighlights(icon, data)` ends every hover's changes, polygon previews included | A4 |
| `docs/waypoints.md:273-281` (Polygon areas) | Rewrite only the "Hover exceptions" and "Frame levels" bullets as resolved, with the levels from 1.1. The ownership and combat bullets are Area C's. | A1 |
| `docs/waypoints.md:293-301` (Still to verify) | Add the in-game checks from section 7 | A1, A2 |
| `WaypointHover.lua:13-21` (header) | Add: paths hover only where nothing covers the map, and the gamepad UI leaves map hover to the gamepad cursor | A1, A2 |
| `WaypointHover.lua:62-100` | The `_ResetTooltipChanges` comment as in 4b (A4); the `_Leave` comments (Area B's F1) | A4, B's F1 |
| `WaypointMap.lua:125-129` | `_IsCursorOnMap` comment as in 4b; doc on `_PathAt` and `IsMapUncovered` | A1, A2 |
| `QuestiePolygon.lua:322-326`, `:343-344`, `:989-990` | As in 4b | A1, A2 |
| `PolygonRenderer.lua:36` | `isCursorOnMap` annotation | A1 |
| `QuestieFrame.lua` (`OnLeave`, `ResetHoverHighlights`; `ApplyHoverHighlights` with F4) | As in 3.4 and 3.10 | A4, B's F1 and F4 |
| `GamepadMapHover.lua` (`Leave`; `FindIconUnderCursor` if A5 is taken) | One-line comments | A4, A5 |

`docs/waypoints.md:228` ("A modifier key doesn't rebuild this tooltip") changes with Area B's Shift-redraw work, not here.

---

## 7. Verification

**Targeted, per commit**, from the repo root:

```bash
busted Modules/Map/Waypoints/WaypointMap.test.lua Polygon/QuestiePolygon.test.lua Polygon/PolygonRenderer.test.lua   # A1
busted Modules/Map/Waypoints/WaypointMap.test.lua Polygon/QuestiePolygon.test.lua                                     # A2
busted Modules/Map/Waypoints/WaypointHover.test.lua Modules/Map/Waypoints/WaypointMap.test.lua \
       Modules/FramePool/QuestieFrame.test.lua Modules/Tooltips/MapIconTooltip.test.lua                               # Area B's F1 (former A3)
busted Modules/FramePool/QuestieFrame.test.lua Modules/Map/GamepadMapHover.test.lua \
       Modules/Map/Waypoints/WaypointHover.test.lua Polygon/QuestiePolygon.test.lua                                   # A4
busted Modules/Map/GamepadMapHover.test.lua                                                                           # A5
```

Then:

```bash
luacheck -q -- Database Localization Modules Polygon Public Questie.lua   # the dropped QuestieCompat import; InputUtil is declared
lua cli/validate-loader-usage.lua                                       # new ImportModule("WaypointMap") in QuestiePolygon
busted -p ".test.lua" .                                                 # once, by the implementer, before calling it done
```

`busted Modules/Map/Waypoints/WaypointHover.test.lua` (7/7, in the waypoints checkout) and `busted Polygon/QuestiePolygon.test.lua` (85/85, in the blob checkout) pass today.

**In game, for David.** Use a development client with blob mode on.

1. **Path over area** (Forever 1.60.1, Horde, quest 826 "Zalazane", Durotar, Echo Isles around 67, 87; zoom in):
   - Rest the cursor on Zalazane's hostile patrol line where it runs through the Hexed and Voodoo Troll areas. Expect his marker's tooltip, his route highlighted, and *no* troll outline highlighted.
   - Slide off the line, still inside the area. Expect the area tooltip with swatches and the outlines highlighted.
   - Go back and forth several times. Each position shows one tooltip, with no flip-back after a pause.
   - After leaving the line, hold Shift. The area tooltip still expands (P3).
   - Move onto Zalazane's marker: its tooltip shows and his route stays highlighted. Move onto the quest log: no Questie tooltip.
2. **Paths draw above areas:** the line stays crisp over the fill and borders.
3. **Route ownership (D8)** (Horde, quest 381 "The Scarlet Crusade", Tirisfal):
   - Meven Korgal's patrol lies inside the Scarlet Convert and Initiate areas of the same objective.
   - With per-cluster ownership, hovering his route opens and outlines *his own* cluster's marker, and hovering that marker highlights his route.
   - With Area C's per-zone rule, both go to the zone's last cluster marker. Confirm whichever rule was chosen.
   - Alliance option: quest 313 "The Grizzled Den", Dun Morogh, with Edan the Howler's patrol in the Wendigo area, if his route is drawn.
4. **Gamepad** (Forever, gamepad UI on):
   - Hover a polygon marker with the gamepad cursor, then move away. The area preview and outline highlight must end (P5).
   - Park the hidden mouse cursor over a path or area. Neither shows a tooltip or highlight (P4).
   - Close the map and use gamepad interact. There must be no "Questie has been blocked" popup (regression check for #7899).
   - If A5 is taken: in a stack of overlapping markers (quests 317 and 384, per `B Polygon/README.md:196`), each marker can be selected.
5. **Classic Era 1.15.9, then Anniversary:** hover areas with area tooltips on. Expect no Lua error and the area tooltip showing (P4).
6. **Minimap** (Forever):
   - Hovering a patrol path shows the private tooltip.
   - Moving onto a minimap icon hands over.
   - Minimap areas show no hover.
   - After Area C links twins, blob-mode routes draw on the minimap, and hovering a cluster's minimap icon highlights its routes.
7. **Combat:** in combat, open the map. Hover a path over an area, then an icon, then an area. Click and drag the map across paths and areas. Expect no blocked-action error.

---

## 8. Risks and open questions

| # | Item | Recommendation |
|---|---|---|
| D1 | **Decision: precedence.** Icons, then paths, then areas, then bare map. | Adopt (3.2). |
| D2 | **Decision: draw order.** `B BLOB-PARITY.md:45` floats moving lines *below* polygons; WP deferred it (`WP docs/waypoints.md:281`). | Keep paths above areas. Thin, high-contrast lines stay readable over translucent fills and borders. B's worry, line rectangles stealing hover and clicks from Blizzard's pins, is gone because WP's paths take no mouse input. Hover follows this order, so flipping it means flipping the precedence. |
| D3 | **Decision: no arbiter and no poller merge now.** | Adopt, with the trigger in 3.7. |
| D4 | **Decision: gamepad UI.** Drawn layers don't hover from the mouse cursor at all, rather than highlighting only. | Adopt. It matches B's existing rule, avoids `#7899`-style taint and is one clause. Gamepad-cursor hover for paths and areas, on the private tooltip, is a possible later feature. |
| D5 | **Decision: in blob mode, hovering a path is hovering its owner marker**, including previewing hidden areas. | Keep it, for consistency and with no code. The alternative is a flag that suppresses `EnterMarker` for hovers that start on a path. |
| D6 | **Decision: should hovering an area highlight the routes of NPCs inside it?** | No. Areas own no highlight state, so `Release` has nothing to undo (I5). |
| D7 | **Decision: A5**, gamepad picking of nudged stacks. | Take it only if gamepad plus blob mode is a combination you support. Otherwise defer. |
| D8 | **Decision: route ownership in blob mode.** Area C's plan keeps one owner per zone (`zoneMarkers[areaId]`, "the last one of each zone"; `C-quest-drawing.md` 3). It adds route markers and twins. With per-zone ownership, only that marker highlights the zone's routes, and hovering any route outlines that marker's cluster, which can be far from the patrol. That is the case for quest 381. | Own each route by the cluster whose spawn extent (`cluster.worldBounds`) holds the patrolling NPC's spawn, falling back to the zone's marker. That is about ten lines inside C's `_AttachRoutes`. If David prefers C's simpler rule, hover code needs no change. The cost is the wrong-outline effect only. |
| D9 | **Decision: Area B's F4** moves the hover begin effects out of `MapIconTooltip`. | Adopt, with the call graph in 3.10. |
| R1 | Dense patrols inside an area make the tooltip switch as you cross lines. | Accept (3.2). Check it at Echo Isles. |
| R2 | A one-frame transient when B's check runs before WP's redraw on a map switch or zoom step. | Accept. It corrects itself next frame. |
| R3 | Under a still cursor, areas don't recheck when paths appear or vanish beneath it. | Accept. `B Polygon/README.md:116` already accepts that UI appearing over a still cursor is noticed on the next move. |
| R4 | Until Area C's F2 (twins), blob-mode routes are world-map only, so no minimap route hover or highlight exists in blob mode. | It already matches blob today. F2 must ship with the merge. |
| R5 | P4's crash on Era, Anniversary and Progression exists on `blob` today. | A2 must ship with the merge. It isn't needed for the rebase to load or pass tests. |
| R6 | On Forever, Blizzard's minimap blip tooltip (GameTooltip) and the private path tooltip can overlap at the cursor. | Existing WP behavior; accept. |
| R7 | Another addon driving GameTooltip from per-frame code over the bare map would fight the area tooltip, which retakes it on the next move. | Accept. This can't be solved across addons. |
| R8 | Naming: `IsMapUncovered`. | David may prefer `IsCursorOnBareMap`. If so, rename it in one commit. |

---

## 9. Contracts with other areas

**A needs from Area B (`MapIconTooltip`, tooltip state).** Checked against `B-tooltip-api.md`, which provides all of these.
1. `Release(owner, tooltip)` forgets only `owner`'s state and hides the tooltip only while `owner` holds it. That is B's F1 version of today's `B MapIconTooltip.lua:501-512`.
2. The state is keyed by **the frame passed to `SetOwner`**, not the icon:
   - the icon, for icon hovers and world-map path hovers;
   - `WorldMapFrame.ScrollContainer`, for areas;
   - `Minimap`, for minimap paths.
   F1 does this with `shown[tooltip].owner`, and F2 makes the minimap path use `ShowForIcons(Minimap, ...)`.
3. **F1 owns the former A3:** `_QuestieFrame.OnLeave` and `WaypointHover._Leave` end tooltips through `Release`, which fixes P3. The detail in 4b applies.
4. Until F4, `ShowOnTooltip` keeps the begin effects: `WaypointHover.End` in `Show`, then `EnterMarker` before the throttle, `SetHighlighted(self.data, true)` and the tints. F4 moves them into the hover owners exactly as in 3.10. `ShowForIcons` never applies them, because areas own no highlight state (I5).
5. The throttle never blocks an icon while another owner holds the tooltip (`B :80-81`).
6. `Redraw` reaches every shown map tooltip whose owner still holds it, including the minimap path tooltip once F2 lands (P6). It doesn't reach the gamepad tooltip while the mouse is off the map, because of EventHandler's condition. Accept that.
7. Answers to B's questions:
   - **Area tooltips highlight no routes** (D6).
   - **Keep `_UpdateAreaTooltip`'s "already mine" check as `GameTooltip:IsOwned(owner) and GameTooltip:IsShown()`.** It reads no field F1 removes, and `GetOwner(GameTooltip) == owner` would add nothing a player could notice.
8. Heads-up: B's merged `MapIconTooltip.test.lua` must stub `WaypointHover.End` and `QuestieWaypoints.SetHighlighted` while `Show` still calls them.

**A needs from Area C (quest drawing, old line model).** Checked against `C-quest-drawing.md`.
1. Delete `IsLineFrame`, `lineFrames`, `CreateLine` and the line propagation during the rebase.
   - C's R2 at `53b5e7ce4` makes the same `isCursorOnMap` and test edit as 4a, with the same choice to leave `savedIsLineFrame` until later. **One resolver applies it once.**
   - C's F1 deletes the scaffolding afterwards.
2. **Route ownership.** C's plan keeps one owner per zone (D8). A recommends ownership by the cluster that holds the patrolling NPC's spawn. Either way, a route's owner must be a live marker of the current generation, which C guarantees.
3. **Twins.** Markers that own routes get a `minimapTwin` that shares their data. C's F2 does exactly this, including route markers drawn with the NPC's own data. Then blob-mode routes draw and hover on the minimap, and cluster minimap icons highlight them.
4. No fallback or route marker shares `waypointPaths` with another icon's data (finding 5). C's route markers get fresh data from `_IconData`, which satisfies this.
5. When resolving `QuestieFrame.lua` during the rebase, keep `LeaveMarker` at the top of `OnLeave` and WP's body of `ResetHoverHighlights`. A4 moves the call later.

**A needs from Area D (minimap layer)**
1. Minimap path hover keeps WP's semantics:
   - `WaypointHover.Set("minimap", path, path.owner.minimapTwin)`;
   - the bare-minimap rule `GetMouseFocus() == Minimap` with the shape cutoff;
   - reach `WaypointHover.Radius()`;
   - the private tooltip, required by Forever's `Minimap_OnUpdate`.
2. Neither minimap layer takes mouse input. Minimap areas have no hover. Paths draw above areas, matching Area E's recorded order.
3. Checked against `D-minimap-layer.md`. Its shared canvas samples the cursor once and calls each layer's `Hover(x, y)` top layer first (its `_Update` step 7). That fits while paths are the only hovering layer. **When a second minimap layer gets `Hover`, `Hover` returns whether it hovers something, and the canvas then calls the layers beneath with nil** (I1). This makes D's canvas the minimap's arbiter, which is the trigger in 3.7. It isn't needed now.

**A needs from Area E (geometry, scheduling).** Checked against `E-geometry-scheduling.md`, which provides all three.
1. `WaypointGeometry.Nearest(targets, x, y, radius)` keeps its semantics: the nearest target within `radius`, with the inflated bounding box rejecting first. Both `_UpdateHover` and `IsMapUncovered` use it. E keeps it, in its section 3.5.
2. Hover code stays synchronous and never yields. E classes hover as presentation, which never yields.
3. Drawing order stays areas, then lines, then icons: 2004 on Era and 2007 on Forever, then 2015, then 2016 and up. E records this and applies it to the minimap. Precedence follows it (I1, D2).

**A provides**
- `WaypointMap.IsMapUncovered(): boolean`, the one world-map rule for when a layer drawn beneath the paths may hover.
- `QuestieFrame.ResetHoverHighlights(icon, data?)`, the one undo for icon hovers (A4). The begin and end call graph that Area B's F4 implements is in 3.10.
- The precedence policy, invariants I1–I7 and the gamepad rule.
- The `isCursorOnMap` edit at `53b5e7ce4` during the rebase, shared with Area C's R2.
