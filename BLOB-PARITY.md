# Blob implementation parity

Comparison of the final **QuestieDev-Master** implementation with the new **`Polygon/`** implementation. This is a partial port, not full feature parity.

## What was carried over

| Part | Current implementation |
| --- | --- |
| Generate areas from objective spawn locations | Implemented. Uses Questie's current spawn data and phase filtering. |
| Cluster nearby spawns | Implemented. Deterministic, separated by map/instance, with background work sharing one per-frame budget. |
| Gift wrapping, smoothing, and point reduction | Implemented with geometry fixes. The second hull uses a faster algorithm. |
| Filled polygons with separate outlines | Implemented on the world map using the original quad-fan approach. |
| Representative cluster icons | Implemented. Small or degenerate clusters retain a point marker. |
| Hover an icon to preview its areas | Implemented. Highlights only that icon's attached polygon outline. |
| Click an icon to keep its areas visible | Implemented. Each marker toggles its objective directly; nearly coincident markers are nudged apart visually. Pinning is objective-wide, not per cluster. |
| Hover the polygon itself | Implemented where motion propagation is available. One shared 80 ms check highlights all participating polygons whose actual shapes contain the cursor. |
| Highlight the polygon border on hover | Implemented. Thicker, brighter border; fade opacity is preserved. |
| Cache calculated areas | Implemented in memory. Progress-only updates reuse geometry and skip spawn collection unless the spawn list or phase visibility changes; changed eligible spawns rebuild it. |
| Quest updates and removal | Implemented, with cancellation and pooled-resource cleanup fixes. |
| World-map waypoints | Existing Questie lines are retained and attached to cluster markers. Waypoint frames propagate motion where supported; clicks are unchanged. |

## What is still missing

| Original feature | Current status |
| --- | --- |
| Click handling on polygon frames | **Deliberately not ported.** Motion propagates to underlying regions, but polygon clicks stay disabled. Map navigation and marker actions remain with their existing handlers. |
| Minimap polygons | **Not ported.** Ordinary Questie minimap icons remain. |
| Minimap waypoint lines | **Not ported.** The old outlined-texture waypoint renderer is preserved as reference code only. |
| Minimap masks and custom HBD scaling | **Not ported.** Needed by the old minimap rendering paths. |

## Deliberate differences

- Added an opt-in **Questie blobs** preset and popup choice; most implementation lives in root `Polygon/`.
- Preserved current tracking, hiding, tooltips, tracker highlighting, and normal minimap icons.
- Nearly identical locations use fixed horizontal stacks: same original UI map, within 0.01 percentage points of a stable seed, ordered by quest/objective/location. Base spacing is 70% of the maximum configured icon width; separation now grows with the wrapper's zoom sizing rather than staying fixed on screen. The separate world/continent icon-size multiplier is not included. Hidden/offscreen markers keep their slots. There is no collision solver, polling, picker, or edge clamping; large stacks can extend beyond map edges. Stored coordinates, polygons, waypoints, and navigation targets stay unchanged.
- The retired screen-space nudging experiment is preserved in locally gitignored `.scratch/polygon-nudging-experiment/` with verified checksums. The original historical reference package remains separate.
- Did not copy the unsafe hull prefilter or blanket exclusion of rare NPCs.
- Historical mean-shift, alternate renderers, and overlap-merging experiments remain reference material, not enabled features.
- Neither version provides terrain-aware shapes or holes. Overlapping polygons highlight together only when their shapes contain the cursor and they participate in the native focus stack. UI blockers still exclude underlying polygons.
- Marker-associated and direct-hover highlights combine. Generic Questie icon input is unchanged; Polygon markers use direct-click pinning with no picker. Polygon surfaces still have no clicks/tooltips.
- Direct hover affects only drawn areas and does not extend previews or change pinning. Missing motion APIs leave polygon frames noninteractive, but marker-associated highlighting still works. Native POI remains future work.

## Follow-up

- Review waypoint frame levels. They likely belong below polygons, but the existing level `2015` is unchanged pending review and in-game checks. Keep motion propagation enabled throughout stacked waypoint and polygon frames regardless of their final order.

**Validation:** automated checks are offline. The latest fixed-stack zoom correction still needs a user reload and in-game review, including spacing and clicking. Earlier user-confirmed nudging behavior applied to the retired experiment, not this replacement. Native motion propagation and click/drag pass-through remain unvalidated.

See [current implementation details](Polygon/README.md) and [the historical reference package](Blob/docs/legacy-questie-blobs/README.md).
