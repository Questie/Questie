# Blob + waypoints merge plan

This is the master plan for stacking `blob` on `waypoints`, fixing every overlap between them, and building both on shared, feature-neutral map seams, so that future drawing modules plug in the same way.

**Read in this order:**
1. `01-architecture.md`: the architecture you decided on (end state, four rules, where to stop).
2. This README: phases, commit order, decisions and mechanical items.
3. `F-seams.md`: the seams that make the architecture real.
4. The area plans, A–E, for exact file-level specs.

The first version of every plan is in the safety commit `e71e6dd38`. Your copy is `merge-plan.7z`.

| File | Area | Recommended design in one line |
|---|---|---|
| `00-context.md` | Shared context | The situation, the verified overlap findings and the plan template |
| `01-architecture.md` | Architecture | Plug-in drawing features on shared seams. Features never import each other. |
| `F-seams.md` | Seams | `WorldMapLayers` (the world-map layer stack), `QuestieFrame` icon events, the written `IconFrame` contract, the core→feature entry-point allowlist and its guard test, and the optional `Polygon/` move |
| `A-hover-arbitration.md` | Hover precedence | Icons, then paths, then areas, then the bare map. This is encoded once in `WorldMapLayers`' `LAYER_ORDER`. Nothing hovers in the gamepad UI. |
| `B-tooltip-api.md` | `MapIconTooltip` API | Waypoints' signature on top of blob's `ShowForIcons`, then tooltip state owned inside `MapIconTooltip` (`Release`, `GetOwner`, `Redraw`). It imports no feature. |
| `C-quest-drawing.md` | Quest drawing, old line model | Waypoints' route registry owns every route. `QuestiePolygon` only picks the owning marker. All `lineFrames` code goes. |
| `D-minimap-layer.md` | Minimap | `MinimapCanvas`: one mask hook, root, per-frame sample and projection. Paths and areas become layers, with the same claim and gamepad rules as `WorldMapLayers`. |
| `E-geometry-scheduling.md` | Geometry and frame budget | One shared function (`MapGeometry.Simplify`); the renderers stay separate; fix two gaps in blob's frame budget. |

The agents checked every recipe in throwaway copies. No repository state was changed, apart from the safety commit you asked for.

---

## The architecture in one picture

```
 Core:  QuestieQuest · QuestieMap · QuestieFrame · MapIconTooltip · Tracker · Options
           │ 11 allowlisted entry points          ▲ features subscribe to icon events
           ▼                                      │   (Unload, VisibilityChanged, HoverStart, HoverEnd, Click)
 Shared map seams (know no feature):
   WorldMapLayers · MinimapCanvas · MapGeometry · IconFrame contract
           ▲                                      ▲
   Waypoints (paths)                      Polygon (areas)            (future drawing modules)
           └────── never import each other ───────┘   enforced by test/MapFeatureImports.test.lua
```

**Rule 4 in practice.** Core reaches a feature only through 11 allowlisted calls in 8 files (`F-seams.md` §3.6):
- the waypoints drawing entry
- removing a quest's areas
- blob mode in `QuestieQuest`
- the tracker's Show on Map flash and its objective-hover preview
- each feature's options
- a profile-switch redraw and a disable reset

Each entry is one documented line in the guard test. Anything else fails CI.

---

## Bugs found during planning

These were not in the original review.

| # | Bug | Where | Fixed by |
|---|---|---|---|
| N1 | **The automatic merge freezes the client.** Blob's `local icons` shadows waypoints' `icons` parameter in `ShowOnTooltip`, so the given-icons loop never ends. Git won't flag it. *Verified by the orchestrator.* | `MapIconTooltip.lua`, at the WIP stop | Phase 1, stop #36 |
| N2 | The automatic merge brings back the dead `CustomTooltipData` branch. | `MapIconTooltip.ShowForIcons` | Phase 1, stop #36 |
| N3 | **Area hover throws a Lua error on Era, Anniversary and Progression.** Only Forever's `InputUtil` has `IsGamepadUIEnabled`. This bug is in blob today. | `QuestiePolygon._UpdateAreaTooltip` | F-1 (`QuestieCompat.IsGamepadUIEnabled`) and F-2 |
| N4 | A quest's icons stay tinted after a path hover reaches their icon. This bug is in waypoints today. | `MapIconTooltip` `touchedPins` | B-F3 (Phase 0) |
| N5 | In the gamepad UI, or when a path hover ends while another frame holds the tooltip, a polygon marker's area preview never ends. | `GamepadMapHover`, `WaypointHover` | F-3 |
| N6 | After a reset, the frame budget can put 26–113 ms into a single frame. | `PolygonGeometry.Checkpoint`, `QuestiePolygon` | E-F1, E-F2 |
| N7 | On a square minimap such as SexyMap's, paths in the corners can't be hovered. This bug is in waypoints today. | Waypoints' minimap cursor read | D-C3 |
| N8 | `FlashObjective` keeps blob's `HBDPins` lines, but waypoints deleted that local, so the merged code reads an undefined global. | `TrackerUtils.lua` | Phase 1, stop #6 |

---

## Phase 0: before step 3, on `waypoints`

1. **B-F3 `fix(tooltips): keep icon colors when a hovered icon's tooltip opens again`** (`B-tooltip-api.md` §4b). It fixes N4, which is waypoints-only. Land it, push `waypoints`, and step 3 picks it up. Later, F-4 moves this guard into `QuestieFrame`.
2. **Commit the updated plan.** A rebase needs a clean working tree, and the plan edits since `e71e6dd38` are uncommitted. Use a second safety commit, for example `chore: update the merge plan with shared map seams`.

---

## Phase 1: step 3 rebase recipe

This phase is unchanged by the architecture update. Seams are post-stack commits; `F-seams.md` §4a confirms that every stop leaves code the seams replace cleanly.

```sh
git config rerere.enabled true          # already on
git tag blob-base waypoints             # used later: rebase --onto origin/master blob-base blob, once waypoints is on master
git rebase --onto waypoints origin/master blob \
  --exec 'busted -p ".test.lua" Modules/FramePool Modules/Map Modules/Quest Modules/Tracker Modules/Tooltips && { [ ! -d Polygon ] || busted -p ".test.lua" Polygon; } && luacheck -q -- Modules/FramePool Modules/Map Modules/Quest Modules/Tracker Modules/Tooltips $( [ -d Polygon ] && echo Polygon )'
```

- `--exec` (from Area C) stops at the first replayed commit whose tests fail, even when it applied cleanly. If an original blob commit already failed its own tests, continue past it on purpose.
- During a rebase, `--ours` is the side being rebased onto (waypoints plus the blob commits already replayed), and `--theirs` is the blob commit being replayed.
- Two rules hold at every stop:
  - Never fold a Phase 2 commit into a conflict resolution.
  - Keep `PolygonGeometry`, `PolygonRenderer`, `PolygonRenderCache`, `PolygonNudging`, `WaypointGeometry` and `WaypointRenderer` identical to their own side.

| Stop | Commit | What to do | Source |
|---|---|---|---|
| #6 | `dfb97c802` feat(polygon): integrate cached objective areas with Questie | Several files; see the details below the table. Fixes N8. | C R1, B 4a, A 4a |
| #7 | `47250fad6` feat(options): add opt-in Questie blobs preset | **M1:** renumber migration `[42]` to `[43]` and fix its tests (Mechanical items). | M1 |
| #9 | `8003dabb0` feat: Enhance PolygonRenderer with marker highlighting… | `git checkout --ours Modules/FramePool/QuestieFramePool.lua`, then `git rm Modules/FramePool/QuestieFramePool.test.lua`. Keep the rest. | C #2 |
| #10 | `38da5d634` feat: Separate overlapping polygon markers… | Take blob's `zoneOwner` rename, but keep the ported `DrawWaypoints(zoneOwner[1], spawnData.TooltipKey, waypoints, zone, spawnData.Hostile)`. | C #3 |
| #27 | `d9dc1ca4d` fix(map): defer waypoint line motion setup until combat ends | **Drop it.** `checkout --ours` and `git rm` as above, then `git rebase --skip`. Paths take no mouse input, so the bug can't happen. | C #7 |
| #30 | `53b5e7ce4` refactor(polygon): compute area hover from the cursor… | `checkout --ours` and `git rm` as above, then **R2**: `isCursorOnMap` becomes `GetMouseFocus() == scrollContainer`, and the test drops its line stub. F-2 later deletes both. | C R2 = A 4a |
| #32 | `4f76fd411` feat(polygon): cluster objects apart… | **R3**: `FakeHide` keeps `OwnerChanged` and blob's marker clause; `_FallbackIconData` excludes `waypointPaths`; `QuestieQuest.test` keeps both sides. | C R3 |
| #33 | `83ef6e2fe` fix(map): skip recycled frames when unloading… | **Keep as is.** | C #10 |
| #36 | `715031ef6` chore: wip snapshot | Rename the cluster list to `tooltipIcons` (**N1**). Pass `owner or self`, and throttle on `IsOwned(owner or self)`. Delete `CustomTooltipData` (**N2**). Keep both sides of the test file. With B-F3 already on `waypoints`, git now flags the N1 spot as a third conflict hunk instead of hiding it. Expect `MapIconTooltip` 23 (20 at stop #6), `WaypointHover` 7, `GamepadMapHover` 10. | B 4a |
| #37+ | The plan's safety commits | New files only; they replay cleanly. | — |

**Stop #6 details**
- **`QuestieFrame`:**
  - Keep both import sets.
  - Fields go in the order `minimapTwin`, then `polygonMarker`.
  - `FakeHide` calls `OwnerChanged` and `MarkerChanged`.
  - `OnLeave` starts with `LeaveMarker`, and `ResetHoverHighlights` uses waypoints' body.
- **`QuestieMap`:** take blob's split `DrawWorldIcon`, and link `minimapTwin` when both icons exist.
- **`QuestieQuest`:** port the call to `DrawWaypoints(ipz[1], spawnData.TooltipKey, waypoints, zone, spawnData.Hostile)`.
- **`TrackerUtils`:** `SetSolo` replaces the line-frame and `HBDPins` code (N8).
- **`MapIconTooltip`:**
  - Add the `QuestiePolygon` import to waypoints' imports.
  - `WaypointHover.End` stays first in `Show`.
  - The order is: alpha gate, then `EnterMarker`, then the throttle.
  - `SetHighlighted` replaces the `lineFrames` loop.
- **Test edits** (git won't stop for these): the `OwnerChanged` and `SetSolo` stubs, the new `DrawWaypoints` assertion, and an assertion on the twin.

### After Phase 1

1. **Check:**
   - `busted -p ".test.lua" .`. The only accepted failure is the existing `QuestieDBMock.conformance` one, which comes from the local `../QuestieDB`.
   - `luacheck -q -- Database Localization Modules Public Questie.lua`
   - `lua cli/validate-loader-usage.lua`
   - `grep -c "function pins:GetMinimapView" Libs/HereBeDragons/HereBeDragons-Pins-2.0.lua` must print `1`.
2. **Undo the WIP commit and the plan commits on top of it**, however many there are:
   ```sh
   git reset "$(git log --format=%H -1 --grep='^chore: wip snapshot of uncommitted blob work')^"
   ```
   The WIP changes, including the stop #36 fixes, and the plan files come back uncommitted. The plan files come back untracked, as they were before the safety commit.
3. **Decision P-1:** commit the WIP work properly, split as you like, before Phase 2. Several Phase 2 commits edit the same files.
4. **Push:** `git push --force-with-lease origin blob`.

---

## Phase 2: follow-up commits after stacking

Each commit must pass its touched tests, luacheck and the loader validator. The spec for each commit is in the plan named in brackets.

### Group 1: seams and hover (F-1 to F-6 come first)

1. **F-1** `refactor(map): hover patrol paths through a shared WorldMapLayers stack`. Adds `Modules/Map/WorldMapLayers.lua` and `QuestieCompat.IsGamepadUIEnabled()`. [F §4b]
2. **F-2** `fix(polygon): let patrol paths cover quest areas through WorldMapLayers`. Fixes **N3** and the path/area tooltip tug-of-war (findings 1 and 7). [F §4b]
3. **F-3** `refactor(map): let drawing features follow icons through QuestieFrame events`. `QuestieFrame` drops both feature imports and adds the `IconFrame` contract. Fixes **N5**. [F §4b]
4. **F-4** `refactor(map): start icon hover effects through the HoverStart event`. Adds `ApplyHoverHighlights`, and `MapIconTooltip` stops importing features. [F §4b]
5. **F-5** `refactor(waypoints): let core redraw paths only through QuestieWaypoints`. [F §4b]
6. **F-6** `test(map): keep drawing features out of each other and out of core`. Adds the import guard. [F §4b]

### Group 2: tooltip state

7. **B-F1** `refactor(tooltips): keep map icon tooltip state in MapIconTooltip`. [B §4b]
8. **B-F2** `refactor(waypoints): list a minimap path's quests through ShowForIcons`. [B §4b]
9. *(Optional)* **A5** `fix(map): let the gamepad cursor pick markers nudged apart`. See decision A-7. [A §4b]

### Group 3: routes

10. **C-F1** `refactor(polygon): attach objective routes inside QuestiePolygon`. Includes route ownership by decision C-5. [C §4b]
11. **C-F2** `feat(polygon): show objective routes on the minimap`. [C §4b]

### Group 4: frame budget and geometry

12. **E-F1** `perf(polygon): weigh frame budget steps and check before a job's first step`. [E §4b]
13. **E-F2** `perf(polygon): charge spawn collection and icon drawing to the frame budget`. Comes **after C-F1**; with E-F1 it fixes **N6**. [E §4b]
14. **E-F3** `refactor(map): share line simplification between waypoints and polygons`. Adds `Modules/Map/MapGeometry.lua`. [E §4b]
15. **E-F4** `docs(map): record drawing order and scheduling of waypoints and areas`. [E §4b]

### Group 5: minimap

16. **D-C1** `refactor(waypoints): draw minimap paths on a shared MinimapCanvas`. Comes **after F-1**, since it needs `IsGamepadUIEnabled`. [D §4b]
17. **D-C2** `refactor(polygon): draw minimap areas on the shared MinimapCanvas`. Comes **after C-F2**. [D §4b]
18. **D-C3** `fix(minimap): hover a square minimap's corners whatever asset squared it`. Fixes **N7**. [D §4b]
19. *(Optional)* **D-C4** `chore(hbd): mark Questie's additions to HereBeDragons-Pins`. [D §4b]

### Group 6: mechanical items and the move

20. **M2–M4** below.
21. *(Optional, last)* **F-7** `refactor(polygon): move Polygon into Modules/Map/Polygon`. See decision F-6. [F §3.8]

**Ordering notes:**
- Groups 1 and 2 come first, in order.
- After that, Groups 3, 4 and 5 are independent except for the marked dependencies: E-F2 after C-F1, D-C1 after F-1, and D-C2 after C-F2.
- If you want every seam module in place early, E-F1 + E-F3 (`MapGeometry`; E-F3 needs E-F1's cost argument, so they move together) and D-C1 (`MinimapCanvas`) can move up to right after F-6. None of them conflicts with Groups 2–3.
- `docs/waypoints.md`'s "Frame levels" bullet (`:281`) is edited once, in F-1, where the levels move into `LAYER_ORDER`. E-F4 leaves it alone.

---

## Decisions for David

The recommendation comes first in each row. Rows marked ★ change behavior players will see.

**Process**

| ID | Decision | Recommendation |
|---|---|---|
| P-1 | After Phase 1, commit the restored WIP properly before Phase 2. | **Yes** |

**Seams (Area F)**

| ID | Decision | Recommendation |
|---|---|---|
| F-1 | Add `Click` as a fifth icon event (polygon's marker toggle). Without it, `QuestieFrame` keeps a feature import for one line. | **Yes** |
| F-2 | `VisibilityChanged` also covers native show and hide, instead of adding a sixth event. | **Yes** |
| F-3 | `Unload` fires once, when a deferred unload finishes. Polygon then releases a still-queued marker a few frames later than today. | **Yes** |
| F-4 | Feature fields (`polygonMarker`, `waypointPaths` and so on) stay on frames, declared by their feature, rather than moving to side tables. | **Yes** (side tables pay off nowhere) |
| F-5 | Rule 4 is the guard's 11 entry points. Features subscribe on first use, so no init entry is needed. | **Yes** |
| F-6 | Move `Polygon/` to `Modules/Map/Polygon/` (F-7, the last commit). | **Yes.** Features then declare themselves by folder. |
| F-7 | `WorldMapLayers` owns frame levels, so draw order and hover order can't drift apart. | **Yes** |
| F-8 | The minimap gets the same claim and gamepad rules as the world map. | **Yes** |

**Hover (Area A)**

| ID | Decision | Recommendation |
|---|---|---|
| A-1 ★ | Precedence is icons, then paths, then areas, then bare map, so a path's tooltip wins over an area's. | **Yes** |
| A-2 | Keep paths drawn above areas. | **Yes** |
| A-4 ★ | In the gamepad UI, drawn layers don't hover from the mouse cursor on either map. | **Yes** |
| A-6 ★ | Hovering an area doesn't highlight the routes of NPCs inside it. | **Yes** |
| A-7 | A5, gamepad picking of nudged markers: only if gamepad plus blob mode is supported. | **Defer** |

A-3 ("no arbiter") is superseded: `WorldMapLayers` is the arbiter.

**Tooltips (Area B)**

| ID | Decision | Recommendation |
|---|---|---|
| B-D1 | Tooltip state is owned inside `MapIconTooltip`. | **Yes** |
| B-D2 ★ | The minimap path tooltip lists only the NPC's own quest icons. | **Yes** |
| B-D4 ★ | Shift redraws every map icon tooltip, including the private minimap and gamepad tooltips. | **Yes** |
| B-D5 | B-F3 lands on `waypoints` before it merges (Phase 0). | **Yes** |

B-D3 is superseded by rule 3: hover effects go through `QuestieFrame` events (F-4).

**Routes (Area C)**

| ID | Decision | Recommendation |
|---|---|---|
| C-1 | Do C-F1, the route-ownership refactor. | **Yes** |
| C-2 ★ | Do C-F2, which shows routes for polygon markers on the minimap. | **Yes** |
| C-3 ★ | Routes stay visible when an objective's areas are hidden. | **Keep** |
| C-4 ★ | Hovering a route previews its owner marker's areas. | **Accept** |
| C-5 ★ | **Route owner in blob mode:** the cluster holding the patrolling NPC's spawn, on the patrol's own zone map, falling back to the zone's marker. Use C's `uiMapId` check, not A's instance-only check, which can pick a neighboring zone's cluster across a border. The alternative is the zone's last marker. A scan of all Classic objectives through blob's real clustering found the rules differ for **54 patrols in 39 quests** (Forever is the same). Examples: quest 813 in Durotar, where the last marker is about 1,640 yd from Death Flayer's cluster, and quest 313 in Dun Morogh, about 1,080 yd. Quest 381, the original example, doesn't separate the rules: its spawns form one cluster. | **The cluster** (A, C and F agree; about 15 lines; backed by data) |

**Minimap (Area D)**

| ID | Decision | Recommendation |
|---|---|---|
| D-1 ★ | For `CORNER-*` minimap shapes, use the square mask only for `SQUARE` in both layers. HereBeDragons, LibDBIcon and SexyMap all read `CORNER-X` as square with one round quarter. | **Yes** |
| D-2 ★ | Paths sit above Blizzard's minimap border artwork where the two overlap inside the mask. | **Accept** |
| D-3 | Minimap areas adopt the paths' redraw rule (after half a radius of walking). | **Yes** |
| D-4 | `MinimapCanvas` lands after the rebase, not on `waypoints` first. | **After the rebase** |
| D-5 | HereBeDragons-Pins stays a marked local patch. | **Yes** |
| D-6 ★ | Include the square-corner hover fix (D-C3). | **Yes** |

**Geometry and budget (Area E)**

| ID | Decision | Recommendation |
|---|---|---|
| E-1 | Share line simplification (`MapGeometry.Simplify`). | **Yes** |
| E-2 | Fix the frame budget and route the marker loop through it. | **Yes** |
| E-3 | Move the budget to `Modules/Libs`. | **Not until a second user exists** |
| E-4 | Spread waypoint drawing over several frames. | **No; measure dense maps first** |
| E-5 | Delete blob's MIT notice along with `_ReduceOutline`. **Check provenance first:** does anything else in `PolygonGeometry.lua` come from that source? | **You must confirm** |

**Wording**

| ID | Decision | Recommendation |
|---|---|---|
| M-3 | Player-facing terms: "quest areas" and "patrol paths". | **Yes** |

---

## Mechanical items (no design needed)

**M1: migration renumber, at Phase 1 stop #7 (`47250fad6`)**
- `Modules/Migration.lua`: waypoints' `[42]` (the `waypoint*` profile keys) stays. Blob's becomes `[43]`, which sets `enableQuestiePolygons = false` if it is nil. The two touch different keys, so order doesn't matter.
- `Modules/Migration.test.lua`:
  - Every shared `assert.are_same(42, …migrationVersion)` becomes `43`. There are six in waypoints' file.
  - "keeps generated polygons opt-in…" and "preserves an explicit polygon choice…" start at `42`, so they test `[43]` on its own, and assert `43`.
  - "does not reset a polygon choice after reaching the latest version" starts at `43` and asserts `43`.
  - "handles Saved Variables without former seasonal compiler scopes" asserts `43`.

**M2: option wording, after C-F2**
- Waypoints' `Enable Minimap Waypoints` description says "Minimap icons must be enabled too." Blob mode shows cluster markers on the minimap, and C-F2 gives those markers routes.
- Reword it to cover both modes, in `Localization/Translations/Options/Map.lua`. Mark the other locales `false`.

**M3: terminology**
- After decision M-3, sweep the player-facing strings and docs: `Polygon/README.md`, the options, and the `Map.lua` and `Icons.lua` translations.

**M4: duplicate PNGs (blob only)**
- `Icons/quest-log-fill-r6.png` is byte-identical to `Icons/quest-log-area-fill.png`.
- `r4`, `r8` and `r10` are referenced nowhere.
- Delete the unused variants when you're done experimenting.

**M5: a vendored lib's test depends on feature code (optional, flagged by Area D)**
- One case in `Libs/HereBeDragons/HereBeDragons-Pins-2.0.test.lua` (around lines 171–215) loads `Polygon/PolygonNudging.lua`.
- Move that case into `Polygon/PolygonNudging.test.lua`, so the library's test only tests the library. Do it before F-7 if `Polygon/` moves.

The duplicate player mask TGA goes away in D-C2.

---

## Verification overview

- **After Phase 1:** see "After Phase 1" above.
- **After each Phase 2 commit:** the targeted busted commands in the matching plan's §7, plus luacheck and the loader validator. From F-6 on, the import guard runs as part of `busted -p ".test.lua" .`.
- **In-game checks** (the full lists are in each plan's §7). Do these on the stacked tip after Group 1 and again after Group 5:

| Client | Check | Covers |
|---|---|---|
| Era or Anniversary | Turn on area tooltips and hover an area. No Lua error. | N3 / F-1, F-2 |
| Any client, blob mode | A path crossing an area shows the NPC's tooltip and highlight. Off the path, the area tooltip returns. Shift redraws whichever tooltip is showing. | F-2, B-F1 |
| Forever, gamepad UI | Hover a polygon marker, then move away. The area preview ends, and paths and areas don't react to the hidden mouse. | N5 / F-3, A-4 |
| Any client | Hover an NPC's path until the hover reaches its icon, then leave. The icons get their own colors back. | N4 / B-F3, F-4 |
| Horde, quest 813, Durotar, or Alliance, quest 313, Dun Morogh (blob mode) | Hovering a patrolling NPC's route outlines the cluster that NPC spawns in, not the zone's last marker (Death Flayer around 36,51; the den cluster around 41,50 for Edan and Old Icebeard). | C-5 |
| Echo Isles | Dense patrols inside an area: the tooltip switches cleanly as you cross lines. | A R1 |
| Blob mode | Routes appear for polygon markers on the minimap. | C-F2 |
| SexyMap square minimap | Paths and areas are clipped correctly in all four corners, and paths there can be hovered. | D-1, D-C3 |
| Any client | `/reload` with about 40 objectives tracked: no hitch from the polygon rebuild. | N6 / E-F1, E-F2 |
