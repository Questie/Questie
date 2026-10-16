# Blob + waypoints merge plan

This is the master plan for stacking `blob` on `waypoints`, fixing every overlap between them, and building both on shared, feature-neutral map seams, so that future drawing modules plug in the same way.

**Read in this order:**
1. `01-architecture.md`: the architecture you decided on (end state, four rules, where to stop).
2. This README: phases, commit order, decisions and mechanical items.
3. `F-seams.md`: the seams that make the architecture real.
4. The area plans, A–E, for exact file-level specs.

The first version of every plan is in the safety commit `e71e6dd38`. Your copy is `merge-plan.7z`.

**Status (2026-10-16): Phases 0, 1 and 2 are done.**
- Phase 1: `blob` became waypoints `f58ad0b1a` plus 43 commits. `d9dc1ca4d` was dropped as planned. Safety branches: `backup/blob-before-waypoints-rebase-20261016` and `…-rebase-2-20261016`.
- Phase 2, in order: F-1 (`a89e539fa`), F-2 to F-6 (`a1554e0fa` to `5534262ec`), B-F1, B-F2, E-F1, C-F1, C-F2, E-F2, E-F3, E-F4, D-C1, D-C2, M2, M3, D-C4 (`89ac705ad`) and, last, F-7, which moved `Polygon/` to `Modules/Map/Polygon/`. Plans written before F-7 keep `Polygon/` paths. Each commit passed the full suite, luacheck and loader validation on its own staged tree.
- Reviews: fresh reviewers checked the seams (F-1 to F-6), the routes (C-F1, C-F2) and the minimap canvas (D-C1). Their fixes are follow-up commits: `7c128e095`, `de1c29b1f`, `f8587395f`, `d1b28f75a`, `9b18115aa`, `58c897ea6` and `16625da52`.
- Changed on the way, with the reason in each commit:
  - F-2: the area tooltip keeps its mouse focus and gamepad checks, through `QuestieCompat`, because a redraw rechecks the kept cursor before `WorldMapLayers` offers it again.
  - F-3: `Unload` fires at every call (decision F-3 above), and native show and hide got their own event (decision F-2 above).
  - C-F1: route attachment stops only on removal or new markers, and each NPC patrolling a zone without markers gets its own route marker.
- Not done: A5 (deferred, decision A-7), M5 (optional), and M4 and M6 (your local icon work).

The Phase 1 recipe below is kept as a record. One addition from the second rebase: stop #6's `QuestieFrame.test` also stubs `QuestieWaypoints.RemoveOwner`, because `f58ad0b1a` calls it for queued icons.

**Update (waypoints moved on).** The plans were written against waypoints `7c1e28bd8`. Since then, `waypoints` has been rebased onto master `ef1241ccf`. It is now `f567796eb`: 39 commits, 0 behind master. What that changes:
- **Master added migration `[42]`** (the Show Spell IDs option). Waypoints' migration is now `[43]`, so blob's becomes **`[44]`** (M1).
- **New on waypoints:** fills and half-disc caps in `WaypointGeometry.Quads`/`_Join` and `WaypointRenderer`, textures moved to `Icons/waypoints/` (sources in `Icons/originals/`, which releases exclude), and route-color fixes for vendors and quest-item objects.
  - None of this touches a seam. `Trim` (E-F3), `WaypointMap`/`WaypointHover` (F-1) and `WaypointMinimap` (D-C1) are unchanged, and the renderer's public API is the same.
  - Blob mode inherits the color fixes through `spawnData.Hostile`.
- **Phase 1 gains two mechanical conflict files:** `QuestieMap.test.lua` (stop #6) and `Migration.test.lua` (stop #7).
- **Test counts in the area plans** (for example C's "QuestieMap 9") predate waypoints' new tests. Re-baseline them at each stop; the target is still "all pass".
- **Waypoint line numbers** cited in the plans may be off by a few lines outside the renderer and geometry files. The functions they name are unchanged.

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
| N1 | **The automatic merge freezes the client.** Blob's `local icons` shadows waypoints' `icons` parameter in `ShowOnTooltip`, so the given-icons loop never ends. Git won't flag it. *Verified by the orchestrator.* | `MapIconTooltip.lua`, at stop #39 (`10a565871`) | Phase 1, stop #39 |
| N2 | The automatic merge brings back the dead `CustomTooltipData` branch. | `MapIconTooltip.ShowForIcons` | Phase 1, stop #39 |
| N3 | **Area hover throws a Lua error on Era, Anniversary and Progression.** Only Forever's `InputUtil` has `IsGamepadUIEnabled`. This bug is in blob today. | `QuestiePolygon._UpdateAreaTooltip` | F-1 (`QuestieCompat.IsGamepadUIEnabled`) and F-2 |
| N4 | A quest's icons stay tinted after a path hover reaches their icon. This bug is in waypoints today. | `MapIconTooltip` `touchedPins` | B-F3 (Phase 0) |
| N5 | In the gamepad UI, or when a path hover ends while another frame holds the tooltip, a polygon marker's area preview never ends. | `GamepadMapHover`, `WaypointHover` | F-3 |
| N6 | After a reset, the frame budget can put 26–113 ms into a single frame. | `PolygonGeometry.Checkpoint`, `QuestiePolygon` | E-F1, E-F2 |
| N7 | On a square minimap such as SexyMap's, paths in the corners can't be hovered. | Waypoints' minimap cursor read | **Fixed on waypoints** (`273e0370f`); D-C3 is dropped |
| N8 | `FlashObjective` keeps blob's `HBDPins` lines, but waypoints deleted that local, so the merged code reads an undefined global. | `TrackerUtils.lua` | Phase 1, stop #6 |

---

## Phase 0: before step 3, on `waypoints`

0. ~~Rebase `waypoints` onto master and remove the scratch files.~~ **Done** (`f567796eb`).
   - *Optional:* the `Scratch` commit (`7a023eb07`) and its removal (`f567796eb`) still carry about 3,300 lines and a 785 KB PNG in history. A merge commit to master would keep them permanently. Dropping both commits before the PR avoids that.
1. **B-F3 `fix(tooltips): keep icon colors when a hovered icon's tooltip opens again`** (`B-tooltip-api.md` §4b). It fixes N4, which is waypoints-only. Land it, push `waypoints`, and step 3 picks it up. Later, F-4 moves this guard into `QuestieFrame`.
2. ~~Commit the updated plan.~~ **Done** (`a15bf0c38` "Updated version", on top of `cd871ff4e`). Commit the later plan edits too, before Phase 1.
3. ~~Finish committing the old WIP (P-1).~~ **Done.** The WIP commit `715031ef6` was dropped from history, and its content is now proper commits:
   - `fb824f1f9` fix(quest): streamline `CheckQuestSourceItem`…
   - `10a565871` refactor(tooltips): show map icon tooltips for a given set of icons. **This is the N1/N2 stop.**
   - `20559fc20` feat(polygon): show the quest tooltip when hovering quest areas
   - `96a370d80` feat(polygon): preview an objective's areas from the tracker, on the minimap too
   - `1ff68f91d` feat(options): show the Questie blobs icon in the objective style picker (`Icons/blobs/BlobPOI.png`)
   - `21437312a` fix(tutorial): mention minimap clusters in the Questie blobs choice
   
   Compared with `715031ef6`, nothing was lost. The only differences are the files kept local on purpose and the `BlobPOI` move.
4. **Set aside the local-only tracked edits before Phase 1.** The code console's TOC and `.luacheckrc` lines and the `loot`/`object`/`slay` art stay uncommitted on purpose. A rebase needs tracked files clean, so stash them and restore them afterwards:
   ```sh
   git stash push -m "local-only: code console and icon art" -- .luacheckrc Questie_*.toc Icons/loot.png Icons/object.png Icons/slay.png
   # … Phase 1 …
   git stash pop
   ```
   Untracked and ignored files (`Modules/Debug/`, `Blob/`, `multiloot.png`, the fill variants, the notes) can stay where they are. No incoming file collides with them.

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
| #7 | `47250fad6` feat(options): add opt-in Questie blobs preset | **M1:** `Migration.lua` and `Migration.test.lua` conflict. Keep master's `[42]` and waypoints' `[43]`, add blob's migration as `[44]`, and fix the tests (Mechanical items). | M1 |
| #9 | `8003dabb0` feat: Enhance PolygonRenderer with marker highlighting… | `git checkout --ours Modules/FramePool/QuestieFramePool.lua`, then `git rm Modules/FramePool/QuestieFramePool.test.lua`. Keep the rest. | C #2 |
| #10 | `38da5d634` feat: Separate overlapping polygon markers… | Take blob's `zoneOwner` rename, but keep the ported `DrawWaypoints(zoneOwner[1], spawnData.TooltipKey, waypoints, zone, spawnData.Hostile)`. | C #3 |
| #27 | `d9dc1ca4d` fix(map): defer waypoint line motion setup until combat ends | **Drop it.** `checkout --ours` and `git rm` as above, then `git rebase --skip`. Paths take no mouse input, so the bug can't happen. | C #7 |
| #30 | `53b5e7ce4` refactor(polygon): compute area hover from the cursor… | `checkout --ours` and `git rm` as above, then **R2**: `isCursorOnMap` becomes `GetMouseFocus() == scrollContainer`, and the test drops its line stub. F-2 later deletes both. | C R2 = A 4a |
| #32 | `4f76fd411` feat(polygon): cluster objects apart… | **R3**: `FakeHide` keeps `OwnerChanged` and blob's marker clause; `_FallbackIconData` excludes `waypointPaths`; `QuestieQuest.test` keeps both sides. | C R3 |
| #33 | `83ef6e2fe` fix(map): skip recycled frames when unloading… | **Keep as is.** | C #10 |
| #36–37 | `cd871ff4e`, `a15bf0c38`: the plan's safety commits | New files only; they replay cleanly. | — |
| #38 | `fb824f1f9` fix(quest): streamline `CheckQuestSourceItem`… | Expected to apply cleanly. It is the part of the old WIP that Area C found free of conflicts with its files. | C table #11 |
| #39 | `10a565871` refactor(tooltips): show map icon tooltips for a given set of icons (from the old WIP snapshot `715031ef6`) | Rename the cluster list to `tooltipIcons` (**N1**). Pass `owner or self`, and throttle on `IsOwned(owner or self)`. Delete `CustomTooltipData` (**N2**). Keep both sides of the test file. With B-F3 already on `waypoints`, git now flags the N1 spot as a third conflict hunk instead of hiding it. Expect `MapIconTooltip` 23 (20 at stop #6), `WaypointHover` 7, `GamepadMapHover` 10. | B 4a |
| #40 | `20559fc20` feat(polygon): show the quest tooltip when hovering quest areas | Its `onHover = _UpdateAreaTooltip` line sits next to R2's `isCursorOnMap` (stop #30). If it conflicts, keep both (A 4a). It also adds `polygonAreaTooltips` to `QuestieOptionsDefaults.lua`, which waypoints changed in another section; the preview merges it cleanly. | A 4a |
| #41–43 | `96a370d80`, `1ff68f91d`, `21437312a`: tracker/minimap previews, preset icon, tutorial wording | Expected to apply cleanly. None of them touches a file waypoints changed. | — |
| #44+ | The plan update commits | New files only. | — |

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
- **`QuestieMap.test.lua`** (new conflict since waypoints `f567796eb`): waypoints imports `local match = require("luassert.match")` and blob imports `local _ = require("luassert.match")._`. Keep `local match = require("luassert.match")`, then add `local _ = match._`. Both names are used.
- **Test edits** (git won't stop for these): the `OwnerChanged` and `SetSolo` stubs, the new `DrawWaypoints` assertion, and an assertion on the twin.

### After Phase 1

1. **Check:**
   - `busted -p ".test.lua" .`. The only accepted failure is the existing `QuestieDBMock.conformance` one, which comes from the local `../QuestieDB`.
   - `luacheck -q -- Database Localization Modules Public Questie.lua`
   - `lua cli/validate-loader-usage.lua`
   - `grep -c "function pins:GetMinimapView" Libs/HereBeDragons/HereBeDragons-Pins-2.0.lua` must print `1`.
2. **Plan commits:** the plan commits (`git log --oneline -- merge-plan`) only add `merge-plan/`. Keep them while you work through Phase 2, and drop them before opening the PR, for example with `git rebase --onto <first>^ <last>` when they sit next to each other. Your `merge-plan.7z` stays as the off-branch copy.
3. **Push:** `git push --force-with-lease origin blob`.

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
18. ~~**D-C3**~~ **Dropped:** waypoints fixed N7 itself in `273e0370f`. When D-C1 moves the minimap cursor read onto `MinimapCanvas`, it must keep that rule: square for hovering when `ShapeMask()` is the square mask **or** `GetMinimapShape() == "SQUARE"`. D-C1's canvas test covers it.
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
| P-1 | Commit the old WIP properly. | **Done** (Phase 0 step 3) |

**Seams (Area F)**

| ID | Decision | Recommendation |
|---|---|---|
| F-1 | Add `Click` as a fifth icon event (polygon's marker toggle). Without it, `QuestieFrame` keeps a feature import for one line. | **Yes** |
| F-2 | Native show and hide get their own event, `NativeVisibilityChanged`, which only polygon's map markers follow. Changed at the seam review: sharing `VisibilityChanged` redrew every path whenever HereBeDragons showed or hid a patrol NPC's icon. | **Yes** (was: one shared event) |
| F-3 | **Changed by waypoints `f58ad0b1a`.** Waypoints now releases a queued icon's paths at the *first* `Unload` call, and still again when the draw queue finishes it; blob releases its markers at both calls too. So `Unload` fires at every call: at once, and for a queued icon again at the finish, which releases routes added to it meanwhile. Both listeners are idempotent. C's invariant 1 ("neither listener runs on the deferred first `Unload`") no longer applies. | **Yes, at every call** (decided at the F-3 commit; firing only at the first call would leak routes added meanwhile) |
| F-4 | Feature fields (`polygonMarker`, `waypointPaths` and so on) stay on frames, declared by their feature, rather than moving to side tables. | **Yes** (side tables pay off nowhere) |
| F-5 | Rule 4 is the guard's 11 entry points. Features subscribe on first use, so no init entry is needed. | **Yes** |
| F-6 | Move `Polygon/` to `Modules/Map/Polygon/` (F-7, the last commit). | **Yes. Decided by David (2026-10-16).** Features then declare themselves by folder. |
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
| C-5 ★ | **Route owner in blob mode:** the cluster holding the patrolling NPC's spawn, on the patrol's own zone map, falling back to the zone's marker. Use C's `uiMapId` check, not A's instance-only check, which can pick a neighboring zone's cluster across a border. The alternative is the zone's last marker. A scan of all Classic objectives through blob's real clustering found the rules differ for **54 patrols in 39 quests** (Forever is the same). Examples: quest 813 in Durotar, where the last marker is about 1,640 yd from Death Flayer's cluster, and quest 313 in Dun Morogh, about 1,080 yd. Quest 381, the original example, doesn't separate the rules: its spawns form one cluster. | **The cluster. Decided by David (2026-10-16)**; applied in C-F1 |

**Minimap (Area D)**

| ID | Decision | Recommendation |
|---|---|---|
| D-1 ★ | For `CORNER-*` minimap shapes, use the square mask only for `SQUARE` in both layers. HereBeDragons, LibDBIcon and SexyMap all read `CORNER-X` as square with one round quarter. | **Yes** |
| D-2 ★ | Paths sit above Blizzard's minimap border artwork where the two overlap inside the mask. | **Accept** |
| D-3 | Minimap areas adopt the paths' redraw rule (after half a radius of walking). | **Yes** |
| D-4 | `MinimapCanvas` lands after the rebase, not on `waypoints` first. | **After the rebase** |
| D-5 | HereBeDragons-Pins stays a marked local patch. | **Yes** |
| D-6 ★ | Include the square-corner hover fix (D-C3). | **Done on waypoints** (`273e0370f`) |

**Geometry and budget (Area E)**

| ID | Decision | Recommendation |
|---|---|---|
| E-1 | Share line simplification (`MapGeometry.Simplify`). | **Yes** |
| E-2 | Fix the frame budget and route the marker loop through it. | **Yes** |
| E-3 | Move the budget to `Modules/Libs`. | **Not until a second user exists** |
| E-4 | Spread waypoint drawing over several frames. Waypoints' new fills and caps add about 11% more textures, per `docs/waypoints.md`. | **No; measure dense maps first** |
| E-5 | Delete blob's MIT notice along with `_ReduceOutline`. **Check provenance first:** does anything else in `PolygonGeometry.lua` come from that source? | **Remove it. Decided by David (2026-10-16):** only the reduction came from the helper; the smoothing is Catmull-Rom (`Blob/docs/legacy-questie-blobs/ANALYSIS.md`) |

**Wording**

| ID | Decision | Recommendation |
|---|---|---|
| M-3 | Player-facing terms: "quest areas" and "patrol paths". | **Yes** |

---

## Mechanical items (no design needed)

**M1: migration renumber, at Phase 1 stop #7 (`47250fad6`)**
- `Modules/Migration.lua`: keep master's `[42]` (`enableTooltipsSpellID`) and waypoints' `[43]` (the `waypoint*` profile keys). Blob's becomes `[44]`, which sets `enableQuestiePolygons = false` if it is nil. All three touch different keys, so order doesn't matter.
- `Modules/Migration.test.lua` (now a conflict):
  - Every shared `assert.are_same(43, …migrationVersion)` becomes `44`. There are seven in waypoints' file.
  - "keeps generated polygons opt-in…" and "preserves an explicit polygon choice…" start at `43`, so they test `[44]` on its own, and assert `44`.
  - "does not reset a polygon choice after reaching the latest version" starts at `44` and asserts `44`.
  - "handles Saved Variables without former seasonal compiler scopes" asserts `44`.

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
- One case in `Libs/HereBeDragons/HereBeDragons-Pins-2.0.test.lua` (around lines 171–215) loads `Modules/Map/Polygon/PolygonNudging.lua`.
- Move that case into `Modules/Map/Polygon/PolygonNudging.test.lua`, so the library's test only tests the library.

**M6: texture layout (optional)**
- Waypoints now keeps its textures in `Icons/waypoints/` and their sources in `Icons/originals/waypoints/`, which `build.py` leaves out of releases.
- Blob's textures can follow the same layout: **in progress** in your working tree as `Icons/blobs/` and `Icons/originals/BlobPOI`. Move the quest-log fills and the area swatch there too, and update the paths in `PolygonQuestLogForever.lua`, `QuestiePolygon.lua` (`AREA_SWATCH`) and their tests.
- The shared minimap player mask stays at the `Icons/` root, because `MinimapCanvas` owns it, not a feature.

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
| SexyMap square minimap | Paths and areas are clipped correctly in all four corners, and paths there can be hovered. | D-1, `273e0370f`, D-C1 |
| Any client | `/reload` with about 40 objectives tracked: no hitch from the polygon rebuild. | N6 / E-F1, E-F2 |
