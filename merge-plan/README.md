# Blob + waypoints merge plan

This is the master plan for stacking `blob` on `waypoints` and then fixing every overlap between them.

Five design plans sit next to this file. An Opus agent wrote each one after studying both implementations. This README does three jobs:
- sets the order of the work
- consolidates the decisions you need to make
- covers the mechanical items that belong to no area

| File | Area | Recommended design in one line |
|---|---|---|
| `00-context.md` | Shared context | The situation, the verified overlap findings and the plan template |
| `A-hover-arbitration.md` | Hover and tooltip ownership | Layers hover in draw order (areas < paths < icons), decided by one rule, `WaypointMap.IsMapUncovered()`. No arbiter yet. |
| `B-tooltip-api.md` | `MapIconTooltip` API | Waypoints' signature on top of blob's `ShowForIcons`, then tooltip state owned inside `MapIconTooltip` (`Release`, `GetOwner`, `Redraw`) |
| `C-quest-drawing.md` | Quest drawing, old line model | Waypoints' route registry owns every route. `QuestiePolygon` only picks which marker owns them. All `lineFrames` code is removed. |
| `D-minimap-layer.md` | Minimap | A new `MinimapCanvas` module (one mask hook, root, per-frame sample and projection). Paths and areas become layers on it. |
| `E-geometry-scheduling.md` | Geometry and frame budget | Share one function (`MapGeometry.Simplify`) and keep the renderers separate. Fix two gaps in blob's frame budget. |

Plans B, C, D and E were checked in throwaway copies: their rebase recipes were replayed and the touched suites pass. No repository state was changed.

---

## New bugs the planning found

None of these were in the original review.

| # | Bug | Where | Fixed by |
|---|---|---|---|
| N1 | **The automatic merge freezes the client.** Blob's `local icons` shadows waypoints' `icons` parameter in `ShowOnTooltip`. `handleMapIcon` appends to that same list, so the given-icons loop never ends. Git won't flag it. *Verified by the orchestrator.* | `MapIconTooltip.lua`, at the WIP stop | Phase 1 stop #36 |
| N2 | The automatic merge also brings back the dead `CustomTooltipData` branch. | `MapIconTooltip.ShowForIcons` | Phase 1 stop #36 |
| N3 | **Area hover throws a Lua error on Era, Anniversary and Progression.** `InputUtil` exists there, but only Forever defines `IsGamepadUIEnabled`. This is a bug in blob today. | `QuestiePolygon._UpdateAreaTooltip` | A2 |
| N4 | A quest's icons stay tinted after a path hover reaches the icon. This is a bug in waypoints today. | `MapIconTooltip` `touchedPins` | B-F3 (Phase 0) |
| N5 | In the gamepad UI, a hovered polygon marker's area preview never ends. | `GamepadMapHover`, `WaypointHover` | A4 |
| N6 | After a reset, the frame budget can put 26–113 ms into one frame. New jobs run 255 steps before their first check, and a spawn is charged 1 though it costs about 33. | `PolygonGeometry.Checkpoint`, `QuestiePolygon` | E-F1, E-F2 |
| N7 | On a square minimap such as SexyMap's, paths in the corners are drawn but can't be hovered. This is a bug in waypoints today. | `WaypointMinimap` cursor read | D-C3 |
| N8 | `FlashObjective` keeps blob's `HBDPins` lines, but waypoints deleted that local, so the merged code reads an undefined global. | `TrackerUtils.lua` | Phase 1 stop #6 |

---

## Phase 0: before step 3, on `waypoints`

1. **B-F3 `fix(tooltips): keep icon colors when a hovered icon's tooltip opens again`** (`B-tooltip-api.md` §4b, F3). It fixes N4, which is a waypoints-only bug, so it belongs on `waypoints` before that branch reaches master. Land it, push `waypoints`, and step 3 picks it up automatically.
2. Optional, and not recommended: D-C1 (minimap paths on `MinimapCanvas`) could also land on `waypoints` first. D recommends after the rebase. See decision D-4.

---

## Phase 1: step 3 rebase recipe

```sh
git config rerere.enabled true          # already on
git tag blob-base waypoints             # used later: rebase --onto origin/master blob-base blob, once waypoints is on master
git rebase --onto waypoints origin/master blob \
  --exec 'busted -p ".test.lua" Modules/FramePool Modules/Map Modules/Quest Modules/Tracker Modules/Tooltips && { [ ! -d Polygon ] || busted -p ".test.lua" Polygon; } && luacheck -q -- Modules/FramePool Modules/Map Modules/Quest Modules/Tracker Modules/Tooltips $( [ -d Polygon ] && echo Polygon )'
```

- `--exec` (from Area C) stops at the first replayed commit whose tests fail, even when it applied cleanly. If an original blob commit already failed its own tests, continue past it on purpose.
- During a rebase, `--ours` is the side being rebased onto (waypoints plus the blob commits already replayed), and `--theirs` is the blob commit being replayed.
- Rules that apply at every stop:
  - Never fold a follow-up (Phase 2) commit into a conflict resolution (Area E's rule).
  - Keep `PolygonGeometry`, `PolygonRenderer`, `PolygonRenderCache`, `PolygonNudging`, `WaypointGeometry` and `WaypointRenderer` identical to their own side.

| Stop | Commit | What to do | Source |
|---|---|---|---|
| #6 | `dfb97c802` feat(polygon): integrate cached objective areas with Questie | See the details below the table. | C R1, B 4a, A 4a.1 |
| #7 | `47250fad6` feat(options): add opt-in Questie blobs preset | **M1:** renumber migration `[42]` to `[43]`, and fix its tests (see Mechanical items). | README M1 |
| #9 | `8003dabb0` feat: Enhance PolygonRenderer with marker highlighting… | `git checkout --ours Modules/FramePool/QuestieFramePool.lua`, then `git rm Modules/FramePool/QuestieFramePool.test.lua`. Keep the rest of the commit. | C table #2 |
| #10 | `38da5d634` feat: Separate overlapping polygon markers… | Take blob's rename to `zoneOwner`, but keep the ported call `DrawWaypoints(zoneOwner[1], spawnData.TooltipKey, waypoints, zone, spawnData.Hostile)`. | C table #3 |
| #27 | `d9dc1ca4d` fix(map): defer waypoint line motion setup until combat ends | **Drop it:** `checkout --ours` `QuestieFramePool.lua`, `git rm` its test, then `git rebase --skip`. Waypoint paths take no mouse input, so the bug can't happen. | C table #7 |
| #30 | `53b5e7ce4` refactor(polygon): compute area hover from the cursor… | `checkout --ours` and `git rm` as at #27, then **R2** (below the table). | C R2 = A 4a.2 |
| #32 | `4f76fd411` feat(polygon): cluster objects apart… | **R3** (below the table). | C R3 |
| #33 | `83ef6e2fe` fix(map): skip recycled frames when unloading… | **Keep as is.** It matters more on waypoints, because unloading also calls `RemoveOwner` for routes. | C table #10 |
| #36 | `715031ef6` chore: wip snapshot | See the details below the table. | B 4a |

**Stop #6 details (`dfb97c802`)**
- **QuestieFrame:**
  - Keep both import sets.
  - Keep the fields in the order `minimapTwin`, then `polygonMarker`.
  - `FakeHide` calls both `QuestieWaypoints.OwnerChanged` and `QuestiePolygon.MarkerChanged`.
  - Keep `QuestiePolygon.LeaveMarker(self)` at the top of `OnLeave`, and use waypoints' body of `ResetHoverHighlights`.
- **QuestieMap:** keep blob's split body of `DrawWorldIcon`, and link `iconMap.minimapTwin = iconMinimap` when both icons exist (finding 4).
- **QuestieQuest:** port the route call to `DrawWaypoints(ipz[1], spawnData.TooltipKey, waypoints, zone, spawnData.Hostile)`.
- **TrackerUtils:** in `FlashObjective`, use `QuestieWaypoints.SetSolo(soloData)`, drop the `HBDPins` lines (N8), and call `SetSolo(nil)` in the restore.
- **MapIconTooltip:**
  - Keep waypoints' imports and add `QuestiePolygon`.
  - `WaypointHover.End(self)` stays the first line of `Show`.
  - The order inside `ShowOnTooltip` is: waypoints' `alpha == 0 and not owner` gate, then `EnterMarker`, then the throttle.
  - `SetHighlighted` replaces the `lineFrames` loop.
- **Test edits (git won't stop for these):**
  - `QuestieFrame.test`: add a stub for `OwnerChanged`.
  - `TrackerUtils.test`: add a stub for `SetSolo`.
  - `QuestieQuest.test`: switch the assertion to the new `DrawWaypoints` signature.
  - `QuestieMap.test`: add an assertion on the twin.
- **Expected results:** `MapIconTooltip` 19, `QuestieFrame` 46, `QuestieMap` 9, `QuestieQuest` 45, `TrackerUtils` 58, `QuestiePolygon` 25.

**Stop #30 details (R2)**
- **The rule:** change it to `isCursorOnMap = function() return QuestieCompat.GetMouseFocus() == scrollContainer end`.
- **The test:** in `QuestiePolygon.test`, drop the line stub and rename the test.
- **Leave alone:** the `savedIsLineFrame` scaffolding and the README.

**Stop #32 details (R3)**
- **`FakeHide`:** keep `OwnerChanged`, plus blob's new `polygonMarker or polygonMinimapMarker` check.
- **`_FallbackIconData`:** exclude `waypointPaths` instead of `lineFrames`, and update its comment.
- **`QuestieQuest.test`:** keep both sides' assertions.

**Stop #36 details (`715031ef6`, the WIP)**
- **`MapIconTooltip.ShowOnTooltip`:**
  - Rename blob's cluster list to `tooltipIcons` (fixes N1).
  - Pass `owner or self`.
  - Throttle on `IsOwned(owner or self)`.
  - Delete the `CustomTooltipData` branch from `ShowForIcons` (fixes N2).
  - Use waypoints' `near` logic in `handleMapIcon`.
  - The full resolved block is in `B-tooltip-api.md` §4a.
- **Tests:** keep both sides of the test file.
- **Checks:** `MapIconTooltip` 22, `WaypointHover` 7, `GamepadMapHover` 10, and `luacheck Modules/Tooltips` clean.

### After Phase 1

1. Run the checks:
   - `busted -p ".test.lua" .` The only accepted failure is the existing `QuestieDBMock.conformance` one, which comes from the local `../QuestieDB`.
   - `luacheck -q -- Database Localization Modules Public Questie.lua`
   - `lua cli/validate-loader-usage.lua`
   - `grep -c "function pins:GetMinimapView" Libs/HereBeDragons/HereBeDragons-Pins-2.0.lua` must print `1` (Area D).
2. Undo the WIP commit: `git reset HEAD~1`. The WIP changes come back as uncommitted, including the stop #36 fixes. **Decision P-1:** commit that work properly, splitting it as you like, before Phase 2. Several follow-ups edit the same files (`MapIconTooltip`, `QuestiePolygon`).
3. Push `blob` with `git push --force-with-lease origin blob`, once the WIP is no longer the tip.

---

## Phase 2: follow-up commits after stacking

They're grouped and ordered by dependency. Each line points at its exact file-level spec. Every commit must pass its touched tests, luacheck and the loader validator.

### Group 1: hover and tooltips (fix N3 and N5 first, since they are live bugs)

1. **A1** `fix(polygon): let patrol paths cover the quest areas beneath them`. `WaypointMap.IsMapUncovered()` becomes the areas' `isCursorOnMap`. (A §4b)
2. **A2** `fix(map): leave map hover to the gamepad cursor in the gamepad UI`. Fixes **N3**; say so in the commit body. (A §4b)
3. **B-F1** `refactor(tooltips): keep map icon tooltip state in MapIconTooltip`. `Release`, `GetOwner` and `Redraw`, with no more loose tooltip fields. It also absorbs A's step A3, which stops `WaypointHover._Leave` from clearing another owner's state. (B §4b)
4. **A4** `fix(polygon): end a marker's area preview however its hover ends`. `ResetHoverHighlights(icon, data)`. Fixes **N5**. (A §4b)
5. **B-F2** `refactor(waypoints): list a minimap path's quests through ShowForIcons`. Then `ShowOnTooltip` goes back to `(self, tooltip)`. (B §4b)
6. **B-F4** `refactor(map): start icon hover effects beside their reset`. **Naming reconciled:** B's plan calls the new function `QuestieFrame.HighlightHover`, but use A's name, **`ApplyHoverHighlights`**, which pairs with `ResetHoverHighlights`. It lands after A4. (B §4b, A §3.10)
7. *(Optional)* **A5** `fix(map): let the gamepad cursor pick markers nudged apart`. See decision A-7.

### Group 2: routes

8. **C-F1** `refactor(polygon): attach objective routes inside QuestiePolygon`. Deletes `_FallbackIconData`, `OwnWaypointMarker`, `IsCurrentObjective` and the work token. `QuestieQuest`'s route code becomes waypoints' text word for word. It applies decision C-5 on route ownership. (C §4b)
9. **C-F2** `feat(polygon): show objective routes on the minimap`. Polygon markers get minimap twins. (C §4b)

### Group 3: frame budget and geometry

10. **E-F1** `perf(polygon): weigh frame budget steps and check before a job's first step`. (E §4b)
11. **E-F2** `perf(polygon): charge spawn collection and icon drawing to the frame budget`. **After C-F1**, because it edits the same marker loop. Together with E-F1 it fixes **N6**. (E §4b)
12. **E-F3** `refactor(map): share line simplification between waypoints and polygons`. Adds the new `Modules/Map/MapGeometry.lua` to all six TOCs after `Moonwell.lua`. (E §4b)
13. **E-F4** `docs(map): record drawing order and scheduling of waypoints and areas`. (E §4b)

### Group 4: minimap

14. **D-C1** `refactor(waypoints): draw minimap paths on a shared MinimapCanvas`. Adds the new `Modules/Map/MinimapCanvas.lua` to all six TOCs after `Moonwell.lua`. (D §4b)
15. **D-C2** `refactor(polygon): draw minimap areas on the shared MinimapCanvas`. Deletes `Icons/polygon-minimap-player-mask.tga` and settles the `CORNER-*` rule. (D §4b)
16. **D-C3** `fix(minimap): hover a square minimap's corners whatever asset squared it`. Fixes **N7**. (D §4b)
17. *(Optional)* **D-C4** `chore(hbd): mark Questie's additions to HereBeDragons-Pins`. (D §4b)

### Group 5: mechanical items and wording

18. **M2–M4** below.

**Dependencies:**
- E-F2 comes after C-F1.
- B-F4 comes after A4.
- A4 needs stop #6's `QuestieFrame` resolution.
- D-C2 should come after C-F2. C-F2 changes the same minimap README section (`Polygon/README.md:47`) that Area D owns.
- Inside each group, keep the listed order. Groups 2–4 are independent of Group 1.

---

## Decisions for David

The recommendation comes first in each row. Rows marked ★ change behavior players will see.

| ID | Decision | Recommendation |
|---|---|---|
| P-1 | After Phase 1, commit the restored WIP properly before Phase 2. | **Yes** |
| A-1 ★ | Over a path that crosses an area, the path's tooltip wins, because paths draw above areas. | **Yes** |
| A-2 | Keep paths drawn above areas (blob's parity notes questioned this). | **Yes** |
| A-3 | No hover arbiter or merged poller until a third hover layer exists. | **Yes** |
| A-4 ★ | In the gamepad UI, paths and areas don't hover at all. | **Yes** |
| A-7 | A5 (gamepad picks nudged markers): only if gamepad plus blob mode matters. | **Skip for now** |
| B-D1 | Tooltip state is owned inside `MapIconTooltip` instead of loose fields. | **Yes** |
| B-D2 ★ | The minimap path tooltip lists only the NPC's own quest icons, not nearby ones. | **Yes** |
| B-D3 | Move hover effects out of `MapIconTooltip`, next to their reset (B-F4), rather than adding callbacks. | **Yes** (A agrees) |
| B-D4 ★ | Shift redraws every map icon tooltip, including the private minimap and gamepad tooltips. | **Yes** |
| B-D5 | Land B-F3 on `waypoints` before it merges (Phase 0). | **Yes** |
| C-1 | Do C-F1, the route-ownership refactor. | **Yes** |
| C-2 ★ | Do C-F2, which shows routes for polygon markers on the minimap. | **Yes** |
| C-3 ★ | Routes stay visible when an objective's areas are hidden. | **Keep** |
| C-4 ★ | Hovering a route previews its marker's areas. | **Accept** |
| C-5 ★ | **Route owner in blob mode.** C: the last marker per zone (simplest). A: the cluster holding the patrolling NPC's spawn (about 10 more lines in `_AttachRoutes`). With C's rule, hovering a route can outline a cluster far from the patrol (seen with quest 381 in Tirisfal). | **A's version** (the plans disagree) |
| D-1 ★ | For `CORNER-*` minimap shapes, use the square mask only for `SQUARE` in both layers. HereBeDragons, LibDBIcon and SexyMap all read `CORNER-X` as square with one round quarter. | **Yes** |
| D-2 ★ | Paths sit above Blizzard's minimap border artwork where the two overlap inside the mask. | **Accept** |
| D-3 | Minimap areas adopt the paths' redraw rule (redraw after half a radius of walking) instead of filtering every frame. | **Yes** |
| D-4 | Where `MinimapCanvas` lands: after the rebase, or on `waypoints` first. | **After the rebase** |
| D-5 | HereBeDragons-Pins stays a marked local patch; an upstream PR for `GetMinimapView` is optional. | **Local patch** |
| D-6 ★ | Include the square-corner hover fix (D-C3). | **Yes** |
| E-1 | Share line simplification (`MapGeometry.Simplify`). | **Yes** |
| E-2 | Fix the frame budget and route the marker loop through it. | **Yes** |
| E-3 | Move the budget to `Modules/Libs`. | **No, not until a second user exists** |
| E-4 | Spread waypoint drawing over several frames. | **No, measure dense maps first** |
| E-5 | Deleting blob's MIT notice in `PolygonGeometry.lua` along with `_ReduceOutline`. **Check its provenance:** does anything else in the file come from that source? | **You must confirm** |
| M-3 | Player-facing terms: "quest areas" and "patrol paths" everywhere. Not "blobs" or "polygons", except in the preset's name. | **Yes** |

---

## Mechanical items (no design needed)

**M1: migration renumber, at stop #7 (`47250fad6`)**
- `Modules/Migration.lua`: waypoints' `[42]` (the `waypoint*` profile keys) stays. Blob's becomes `[43]`, which sets `enableQuestiePolygons = false` if it is nil. The two touch different keys, so order doesn't matter.
- `Modules/Migration.test.lua`:
  - Every shared `assert.are_same(42, …migrationVersion)` becomes `43`. There are six in waypoints' file.
  - Blob's "keeps generated polygons opt-in…" and "preserves an explicit polygon choice…" start at `migrationVersion = 42`, so they test `[43]` on its own, and assert `43`.
  - "does not reset a polygon choice after reaching the latest version" starts at `43` and asserts `43`.
  - "handles Saved Variables without former seasonal compiler scopes" asserts `43`.
- Waypoints has no test of its own migration. Optionally add one asserting that `[42]` writes the `waypoint*` defaults. It isn't required for the merge.

**M2: option wording, after C-F2**
- Waypoints' `Enable Minimap Waypoints` description says "Minimap icons must be enabled too." In blob mode the minimap shows cluster markers, not minimap icons, and C-F2 gives those markers routes.
- Reword it to cover both modes. The string lives in `Localization/Translations/Options/Map.lua`. Mark the other locales `false`, as AGENTS.md requires.

**M3: terminology**
- After decision M-3, sweep the user-facing strings and docs: `Polygon/README.md`, the options, and the `Map.lua` and `Icons.lua` translations.

**M4: duplicate PNGs (blob only)**
- `Icons/quest-log-fill-r6.png` is byte-identical to `Icons/quest-log-area-fill.png`.
- `r4`, `r8` and `r10` are referenced nowhere. Only `r12` (the area swatch) and `quest-log-area-fill.png` are used.
- These are your experiment variants, so delete the unused ones only when you're done with them.

The duplicate player mask TGA is handled by D-C2.

---

## Verification overview

- **After Phase 1:** see "After Phase 1" above.
- **After each Phase 2 commit:** the targeted busted commands in the matching plan's §7, plus luacheck and the loader validator.
- **In-game checks** (the full lists are in each plan's §7). Do these at least once, on the stacked tip after Group 1 and again after Group 4:

| Client | Check | Covers |
|---|---|---|
| Era or Anniversary | Turn on area tooltips and hover an area. No Lua error. | N3 / A2 |
| Any client, blob mode | A patrol path crossing an area shows the NPC's tooltip and highlight. Off the path, the area tooltip returns. Shift redraws whichever tooltip is showing. | A1, B-F1 |
| Forever, gamepad UI | Hover a polygon marker, then move away. The area preview ends. | N5 / A4 |
| Any client | Hover an NPC's path until the hover reaches its icon, then leave. The icons go back to their own colors. | N4 / B-F3 |
| Horde, quest 381, Tirisfal (blob mode) | Hovering a route outlines the right cluster. | C-5 |
| Blob mode | Routes appear for polygon markers on the minimap. | C-F2 |
| SexyMap square minimap | Paths and areas are clipped correctly in all four corners, and paths in the corners can be hovered. | D-1, D-C3 |
| Any client | `/reload` with about 40 objectives tracked: no hitch from the polygon rebuild. Profile it if possible. | N6 / E-F1, E-F2 |
