# Blob implementation parity

Comparison of the final **QuestieDev-Master** implementation with the new **`Polygon/`** implementation. This is a partial port, not full feature parity.

## What was carried over

| Part | Current implementation |
| --- | --- |
| Generate areas from objective spawn locations | Implemented. Uses Questie's current spawn data and phase filtering. |
| Cluster nearby spawns | Implemented. Deterministic, separated by map/instance, with budgeted background work. |
| Gift wrapping, smoothing, and point reduction | Implemented with geometry fixes. The second hull uses a faster algorithm. |
| Filled polygons with separate outlines | Implemented on the world map using the original quad-fan approach. |
| Representative cluster icons | Implemented. Small or degenerate clusters retain a point marker. |
| Hover an icon to preview its areas | Implemented. |
| Click an icon to keep its areas visible | Implemented. Click again to unpin. |
| Hover the polygon itself | Implemented where motion propagation is available. One shared 80 ms check selects the topmost participating polygon containing the cursor. |
| Highlight the polygon border on hover | Implemented. Thicker, brighter border; fade opacity is preserved. |
| Cache calculated areas | Implemented in memory. Progress-only updates reuse geometry; changed eligible spawns rebuild it. |
| Quest updates and removal | Implemented, with cancellation and pooled-resource cleanup fixes. |
| World-map waypoints | Existing Questie lines are retained and attached to cluster markers. |

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
- Did not copy the unsafe hull prefilter or blanket exclusion of rare NPCs.
- Historical mean-shift, alternate renderers, and overlap-merging experiments remain reference material, not enabled features.
- Neither version provides terrain-aware shapes or holes. The new hover path resolves overlaps among polygons in the native mouse-focus stack; it does not select through UI blockers or add polygon clicks/tooltips.
- Direct hover affects only currently drawn areas and does not extend marker previews or change pinning. Missing motion APIs leave polygons noninteractive. Native POI remains future work.

**Validation:** offline tests, lint, loader checks, and packaging tests pass. In-game rendering, native motion propagation, and click/drag pass-through remain unvalidated.

See [current implementation details](Polygon/README.md) and [the historical reference package](Blob/docs/legacy-questie-blobs/README.md).
