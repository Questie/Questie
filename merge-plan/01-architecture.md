# Architecture decision: plug-in drawing features on shared map seams

**Status:** decided by David after the first round of plans (A–E). Every plan must follow it.

**Why:** David wants waypoints, polygon areas and future drawing modules to be black boxes to one another. Each should be separable, and new drawing modules should plug in without touching the existing ones.

## End state

```
 Core:  QuestieQuest · QuestieMap · QuestieFrame · MapIconTooltip · Tracker · Options
           │ calls one entry point            ▲ features register for icon events
           ▼                                  │
 Shared map seams (know no feature):
   WorldMapLayers · MinimapCanvas · MapGeometry · IconFrame contract
           ▲                                  ▲
   Waypoints (paths)                  Polygon (areas)        (future drawing modules)
           └──── never import each other ─────┘
```

## The four rules

1. **Features never import each other.** A guard test enforces this by scanning `ImportModule` calls. It fails if any file of one feature imports a module of another. Features are `Modules/Map/Waypoints/*` and `Polygon/*`, plus any future drawing module.
2. **Shared map infrastructure lives in feature-neutral modules, and every feature uses it the same way:**
   - **`MinimapCanvas`** (Area D): a stack of layers on the minimap. It owns the shape mask hook, the root frame and the per-frame player/view sample, and dispatches hover top layer first.
   - **`WorldMapLayers`** (new, Area F): the same idea for the world map. Each layer registers its draw order and a hit test. One poller reads the cursor once, applies the bare-map rule and the gamepad-UI rule, and walks the layers top-down. The first hit gets hover; every other layer gets hover cleared. "Paths win over areas" follows from draw order by construction. It replaces both world-map pollers, and the `WaypointMap.IsMapUncovered` import that the first Area A plan proposed.
   - **`MapGeometry`** (Area E): line simplification shared by both features.
   - **The `IconFrame` contract**, written down: owner frame, `minimapTwin`, and `data` refreshed in place, never replaced, because routes match their owner by table identity.
3. **`QuestieFrame` emits icon events instead of naming features.** The events are unload, visibility change, hover start and hover end. Waypoints registers its route release, visibility and highlight; Polygon registers its marker removal, change and area preview. Hover tint (`touchedPins`) stays in core. `MapIconTooltip` imports no feature module.
4. **Core may call a feature only at a few documented entry points:**
   - blob mode in `QuestieQuest` (`QuestiePolygon.UpdateObjective`)
   - each feature's own options tab
   - the tracker flash
   - init and reset
   
   These stay plain direct calls, one line each, listed in one place.

## Where to stop (no over-building)

- **No general event bus.** Only the `QuestieFrame` icon events.
- **The renderers stay separate.** Area E showed they share conventions, not code.
- **No hover framework beyond the two layer stacks.** Two layers exist, and a third (Forever quest-log area boxes, or a new drawing module) is plausible. That justifies the stacks and nothing more.

## Decided: move `Polygon/` to `Modules/Map/Polygon/`

**Yes, decided by David (2026-10-16).** It sits beside `Modules/Map/Waypoints/` as a symmetric sibling, moved by Phase 2's last, purely mechanical commit (F-7). Plans written before it keep `Polygon/` paths.

## Process for this update

1. **Area F** (new) designs the seams: `WorldMapLayers`, the `QuestieFrame` icon events, the written `IconFrame` contract, the import-guard test, and the optional folder move. It writes `F-seams.md`. It also rewrites `A-hover-arbitration.md` on top of `WorldMapLayers`, since hover arbitration is now that stack.
2. **Areas B, C, D and E** align their own plans with F. The previous plan versions are in git, in commit `e71e6dd38`.
3. **The orchestrator** updates `README.md`: the rules, the commit order (seam modules early in Phase 2), the decisions, and the Phase 1 epilogue, which is now `git reset HEAD~2` because the plan's safety commit sits on top of the WIP commit.

**Phase 1 is unchanged.** The step-3 rebase recipes stay minimal and loadable. Seams are post-stack commits.
