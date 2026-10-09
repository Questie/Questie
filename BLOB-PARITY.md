# Blob implementation parity

Comparison of the final **QuestieDev-Master** implementation with the new **`Polygon/`** implementation. This is a partial port, not full feature parity.

## What was carried over

| Part | Current implementation |
| --- | --- |
| Generate areas from objective spawn locations | Implemented. Uses Questie's current spawn data and phase filtering. |
| Cluster nearby spawns | Implemented. Deterministic, separated by map, instance, and object or creature spawns, with background work sharing one per-frame budget. |
| Gift wrapping, smoothing, and point reduction | Implemented with geometry fixes. The second hull uses a faster algorithm. |
| Filled polygons with separate outlines | Implemented on the world map using the original quad-fan approach. |
| Representative cluster icons | Implemented, on the world map and the minimap. Small or degenerate clusters retain a point marker. Object clusters differ deliberately: see Deliberate differences. |
| Hover an icon to preview its areas | Implemented. Highlights only that icon's attached polygon outline. |
| Show areas on quest accept; click an icon to hide or show them | Implemented. Choices are saved per character and are objective-wide, not per cluster. An option instead shows areas only while the player is nearby. Nearly coincident markers are nudged apart visually. |
| Hover the polygon itself | Implemented. Hover is computed from the cursor and the outlines whenever the cursor's map position changes, and highlights all polygons whose actual shapes contain it. Polygon frames take no mouse input. |
| Highlight the polygon border on hover | Implemented. Thicker, brighter border; fade opacity is preserved. |
| Cache calculated areas | Implemented in memory. Progress-only updates reuse geometry and skip spawn collection unless the spawn list or phase visibility changes; changed eligible spawns rebuild it. |
| Quest updates and removal | Implemented, with cancellation and pooled-resource cleanup fixes. |
| World-map waypoints | Existing Questie lines are retained and attached to cluster markers. Hover reaches the areas beneath waypoint lines; their clicks are unchanged. |
| Minimap polygons | Rebuilt rather than ported: the same areas as the world map, beneath the cluster icons. Outlines convert per vertex to world yards and use HBD's minimap icon placement, including rotation, so they align with icons. The legacy replaced `Minimap.SetMaskTexture`, modified HBD's scaling, and did not rotate shapes. This version post-hooks the mask setter, reads the radius from HBD, and masks out the player arrow like the legacy. Not yet verified in game. |

## What is still missing

| Original feature | Current status |
| --- | --- |
| Click handling on polygon frames | **Deliberately not ported.** Polygon frames take no mouse input. Map navigation and marker actions remain with their existing handlers. |
| Minimap waypoint lines | **Not ported.** The old outlined-texture waypoint renderer is preserved as reference code only. |

## Deliberate differences

- Game objects never share a cluster with creatures. The legacy clustered whole objectives whose icon was the object icon at 35 yards instead of 180. Objects now cluster at 180 yards like creatures, decided per spawn, with the same area-centroid world-map marker, while the minimap shows each object at least 10 yards from the others. An object cluster too small for an area marks the object nearest its middle instead of a midpoint between objects. The ordinary per-spawn objective icons are not drawn in blobs mode.
- Added an opt-in **Questie blobs** preset and popup choice; most implementation lives in root `Polygon/`.
- Preserved current tracking, hiding, tooltips, and tracker highlighting. In blobs mode, cluster icons replace the ordinary per-spawn objective icons on both maps.
- Nearly identical locations use fixed horizontal stacks: same original UI map, within 0.01 percentage points of a stable seed, ordered by quest/objective/location. Base spacing is 70% of the maximum configured icon width; separation now grows with the wrapper's zoom sizing rather than staying fixed on screen. The separate world/continent icon-size multiplier is not included. Hidden/offscreen markers keep their slots. There is no collision solver, polling, picker, or edge clamping; large stacks can extend beyond map edges. Stored coordinates, polygons, waypoints, and navigation targets stay unchanged.
- The retired screen-space nudging experiment is preserved in locally gitignored `.scratch/polygon-nudging-experiment/` with verified checksums. The original historical reference package remains separate.
- Did not copy the unsafe hull prefilter or blanket exclusion of rare NPCs.
- Historical mean-shift, alternate renderers, and overlap-merging experiments remain reference material, not enabled features.
- Neither version provides terrain-aware shapes or holes. Overlapping polygons highlight together when their shapes contain the cursor. Questie icons, Blizzard pins and other UI on top of the map exclude the areas beneath them.
- Marker-associated and direct-hover highlights combine. Generic Questie icon input is unchanged; Polygon markers use direct-click show/hide with no picker. Polygon surfaces still have no clicks/tooltips.
- Direct hover affects only drawn areas and does not extend previews or change saved visibility. Native POI remains future work.

## Follow-up

- Review waypoint frame levels. They likely belong below polygons, but the existing level `2015` is unchanged pending review and in-game checks. Lines sit below Questie's icons (`QuestieMap.utils.SetDrawOrder`) but above Blizzard's pins, so a line's bounding rectangle takes hover and clicks from Blizzard pins beneath it and counts as bare map for area hover. A hit area that follows the line itself would fix both.

**Validation:** automated checks are offline. The latest fixed-stack zoom correction still needs a user reload and in-game review, including spacing and clicking. Earlier user-confirmed nudging behavior applied to the retired experiment, not this replacement. Cursor-based hover under covering UI and unchanged map clicks/dragging still need in-game checks.

See [current implementation details](Polygon/README.md) and [the historical reference package](Blob/docs/legacy-questie-blobs/README.md).
