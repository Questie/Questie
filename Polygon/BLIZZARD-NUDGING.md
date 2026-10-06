# Blizzard icon nudging

## Conclusion

Blizzard separates a pin's **real map position** from its **display offset**. That is useful for Questie's overlapping markers. However, its built-in nudging is directional repulsion from configured source pins, not a general icon-overlap solver. Enabling it on every coincident Questie marker would not reliably separate them.

## Source inspected

Gethe `forever`, commit [`a84e2b1b41d3d4137127c07e4da448aa3251d6f1`](https://github.com/Gethe/wow-ui-source/commit/a84e2b1b41d3d4137127c07e4da448aa3251d6f1), subject `1.60.1 (70235)`. The cache was freshly refreshed by the parent investigation and its SHA was verified here. Source path: `/home/logon/.cache/wow-ui-source/forever/Interface/AddOns/`.

The Blizzard findings below are published Lua/XML source evidence, not a live-client test. The research initially made no implementation or client changes. The final section describes Questie's subsequent fixed horizontal stacks and the small HBD callback used to reapply their display offsets.

## What the algorithm does

[`MapCanvasMixin:CalculatePinNudging`](https://github.com/Gethe/wow-ui-source/blob/a84e2b1b41d3d4137127c07e4da448aa3251d6f1/Interface/AddOns/Blizzard_MapCanvas/Blizzard_MapCanvas.lua#L534-L573) processes each target independently:

1. Read its original normalized map position and clear its previous nudge vector.
2. Ignore targets without a positive `GetNudgeTargetFactor()` or which ignore nudging.
3. Enumerate registered map pins looking for another pin with positive `GetNudgeSourceRadius()`.
4. Compare their **original normalized positions**, not icon rectangles or already-offset positions.
5. If close enough, push the target away from that source. At exactly the same position, use `(1, 0)`: always right.
6. Stop accepting further sources for this target. The code explicitly calls this non-exact: each target gets pushed by only one source.

Let `t` be the target factor, `s` the source radius, and `d` the normalized distance:

```text
influence radius = t × s
eligible when d < influence radius
falloff = 1 − d / influence radius
final normalized displacement = direction × falloff × t × zoomFactor
```

The source radius controls reach; source magnitudes control displacement through the zoom factor. Neither is measured from the icon's actual width or height. Pin iteration is over active pin pools, not sorted by quest/objective identity ([enumeration](https://github.com/Gethe/wow-ui-source/blob/a84e2b1b41d3d4137127c07e4da448aa3251d6f1/Interface/AddOns/Blizzard_MapCanvas/Blizzard_MapCanvas.lua#L387-L397)).

### Exactly coincident pins

These consequences follow directly from the formula, rather than a live test:

- **One source and one target:** the target moves right; a source with no target factor stays put.
- **Two identical pins, both sources and targets:** each moves right by the same amount. They remain coincident.
- **Several identical targets around one source:** all receive the same rightward displacement. They can remain stacked.
- No iterative relaxation, pairwise accumulation, symmetric split, or final collision check follows the first push.

Therefore Blizzard's zero-distance fallback alone does not solve the 317/384 case.

## Coordinates and zoom

[`SetPosition` / `GetPosition`](https://github.com/Gethe/wow-ui-source/blob/a84e2b1b41d3d4137127c07e4da448aa3251d6f1/Interface/AddOns/Blizzard_MapCanvas/MapCanvas_DataProviderBase.lua#L413-L431) retain the original normalized coordinates. [`ApplyPinPosition`](https://github.com/Gethe/wow-ui-source/blob/a84e2b1b41d3d4137127c07e4da448aa3251d6f1/Interface/AddOns/Blizzard_MapCanvas/Blizzard_MapCanvas.lua#L723-L749) adds the nudge only while anchoring the frame:

```text
anchorX = canvasWidth  × (normalizedX + offsetX) / pinScale
anchorY = −canvasHeight × (normalizedY + offsetY) / pinScale
```

The offset is normalized map-space displacement, **not a fixed number of screen pixels**. Canvas dimensions and scale affect its visual size. Distances use X/Y normalized axes without aspect-ratio correction.

[`GetNudgeZoomFactor`](https://github.com/Gethe/wow-ui-source/blob/a84e2b1b41d3d4137127c07e4da448aa3251d6f1/Interface/AddOns/Blizzard_MapCanvas/MapCanvas_DataProviderBase.lua#L390-L411) multiplies two linear interpolations based on `GetCanvasZoomPercent()`: the target's zoomed-out/in factors and the source's zoomed-out/in magnitudes. Pin scale changes reapply current position. Insets ignore nudging ([settings and exclusion](https://github.com/Gethe/wow-ui-source/blob/a84e2b1b41d3d4137127c07e4da448aa3251d6f1/Interface/AddOns/Blizzard_MapCanvas/MapCanvas_DataProviderBase.lua#L315-L371), [scale handling](https://github.com/Gethe/wow-ui-source/blob/a84e2b1b41d3d4137127c07e4da448aa3251d6f1/Interface/AddOns/Blizzard_MapCanvas/MapCanvas_DataProviderBase.lua#L510-L528)).

Position changes mark nudging dirty; moving a source requests recalculation for all pins. The map's `OnUpdate` processes the pending work ([position scheduling](https://github.com/Gethe/wow-ui-source/blob/a84e2b1b41d3d4137127c07e4da448aa3251d6f1/Interface/AddOns/Blizzard_MapCanvas/Blizzard_MapCanvas.lua#L705-L713), [update](https://github.com/Gethe/wow-ui-source/blob/a84e2b1b41d3d4137127c07e4da448aa3251d6f1/Interface/AddOns/Blizzard_MapCanvas/Blizzard_MapCanvas.lua#L30-L35)). This is layout refresh, not ongoing force simulation.

## Concrete Blizzard uses and loading

- [Dungeon entrance pins](https://github.com/Gethe/wow-ui-source/blob/a84e2b1b41d3d4137127c07e4da448aa3251d6f1/Interface/AddOns/Blizzard_SharedMapDataProviders/DungeonEntranceDataProvider.lua#L42-L49) are sources: radius `1`, magnitudes `2, 2`.
- [Ordinary flight-point pins](https://github.com/Gethe/wow-ui-source/blob/a84e2b1b41d3d4137127c07e4da448aa3251d6f1/Interface/AddOns/Blizzard_SharedMapDataProviders/FlightPointDataProvider.lua#L58-L75) are targets: factor `0.015`, zoom factors `1.25, 1`. Bastion flight masters instead become sources. Source and target roles are deliberately distinct.
- [Flight-map quest pins](https://github.com/Gethe/wow-ui-source/blob/a84e2b1b41d3d4137127c07e4da448aa3251d6f1/Interface/AddOns/Blizzard_FlightMap/FM_QuestDataProvider.lua#L22-L33) explicitly say “Flight points can nudge quest pins.” They use target factor `0.015`, zoom factors `1, 0.25`. This is a **flight-map** example, not evidence that ordinary world-map quest pins automatically separate one another.

Load path: [`Blizzard_WorldMap_Mainline.toc`](https://github.com/Gethe/wow-ui-source/blob/a84e2b1b41d3d4137127c07e4da448aa3251d6f1/Interface/AddOns/Blizzard_WorldMap/Blizzard_WorldMap_Mainline.toc) requires MapCanvas and SharedMapDataProviders and explicitly selects Camelot files where needed. [`Blizzard_SharedMapDataProviders_Mainline.toc`](https://github.com/Gethe/wow-ui-source/blob/a84e2b1b41d3d4137127c07e4da448aa3251d6f1/Interface/AddOns/Blizzard_SharedMapDataProviders/Blizzard_SharedMapDataProviders_Mainline.toc) includes the flight-point and dungeon XML files, which load those Lua implementations. [`WorldMapMixin:AddStandardDataProviders`](https://github.com/Gethe/wow-ui-source/blob/a84e2b1b41d3d4137127c07e4da448aa3251d6f1/Interface/AddOns/Blizzard_WorldMap/Blizzard_WorldMap.lua#L204-L240) installs both providers; the inspected Camelot override does not replace that method. This traces the source implementation without asserting that every provider has visible data in the live map.

## Implemented Questie adaptation

[PolygonNudging.lua](PolygonNudging.lua) borrows the separation between geographic and display positions, **not Blizzard's collision algorithm**. It assigns fixed horizontal slots to nearly identical original locations. Each marker directly toggles its objective's pinned areas; there is no picker.

- Partition by original UI-map ID and group coordinates within **0.01 percentage points** of a stable seed. Qualification does not use screen positions, zoom, hitboxes, or viewport bounds. Seed grouping is not transitive.
- Sort by quest, canonical objective, map, and original cluster coordinates, not frame-pool order. Two members occupy left/right slots; three use left/center/right. Larger groups continue the same horizontal row.
- Use **70% of the group's maximum current configured icon width** for spacing in UIParent units. Equal 16-unit icons receive offsets ±5.6; three receive −11.2, 0, +11.2.
- Retain hidden, offscreen, and queued members' slots. Recalculate only when membership, original coordinates, or configured widths change. Zoom and pan merely reapply stored offsets.
- Leave spawn coordinates, polygon outlines, waypoint geometry, HBD geographic anchors, and navigation targets unchanged.

There is no periodic layout monitor, collision grid, placement search, safety reservation, movement cap, or viewport packing. This deliberately handles coincident markers rather than general clutter. A stack can overlap an unrelated nearby icon; large stacks can extend beyond map edges.

### Current Questie integration

Questie's [HBD world-map implementation](../Libs/HereBeDragons/HereBeDragons-Pins-2.0.lua) places each icon beneath a MapCanvas wrapper that retains the real geographic position. Fixed stacking changes only the child's horizontal anchor:

```text
childOffsetX = storedSlotOffset × UIParentEffectiveScale / iconEffectiveScale
childOffsetY = 0
```

This keeps the physical displacement constant through map zoom. No native `GetCenter()` or rectangle measurement is needed to group markers. Stored offsets are always reapplied from the wrapper anchor, never added to an already-shifted position.

HBD now calls optional `icon:OnWorldMapPinUpdated(pin)` after acquisition and inherited scale handling. This also covers reacquiring a still-visible icon without an `OnShow` event. The version-17 upgrade updates those two copied methods on active and inactive pooled wrappers. Ordinary icons without the callback retain their existing behavior.

The adapter's single retained `QuestieMap.RescaleIcons` observer defers configured-width refresh until preference setters finish. Width reads the current `data:GetIconScale()` result, with cached/unit fallbacks, not the animated or map-scaled frame size. Map hide/provider detach disable offsets while retaining slots; removal/reset restore centered anchors and clear owned callbacks before pooling.

The implementation remains under root `Polygon/` apart from the narrow HBD callback. Ordinary/minimap icon input and polygon hover behavior are unchanged. See [the interface and validation checklist](README.md).

### Retired experiment and validation

The earlier screen-space nudging implementation, tests, and integration notes are preserved in `.scratch/polygon-nudging-experiment/`, excluded through this checkout's local `.git/info/exclude`. Its checksums were verified. This archive is separate from the [original QuestieDev-Master reference package](../Blob/docs/legacy-questie-blobs/README.md).

The user-confirmed live behavior concerned that retired experiment. The current fixed-stack replacement has only offline validation and still needs a user reload and live review. Tests cover map-coordinate grouping, stable horizontal slots, zoom-independent offsets, configured-size changes, queued/reacquired wrappers, HBD pool upgrades, and cleanup. They do not establish native anchoring, focus timing, or click/drag behavior. No agent performed a reload or live test for this replacement.
