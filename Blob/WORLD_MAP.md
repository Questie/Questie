# Native world-map blob prototype

A small, visual-only prototype in `BlobWorldMap.lua`, loaded by the Camelot TOC. It draws Blizzard's loaded quest geometry directly on the world-map canvas. It does not use the hitscan or extraction libraries. Minimap work is deferred.

## Commands

```text
/blobmap          Show blobs for all loaded quest-log quests
/blobmap all      Same as above
/blobmap 7        Show only quest 7
/blobmap off      Detach and hide this prototype
```

Open the world map normally with M. Enabling the prototype does not itself open the map, select a map, select a quest or change tracking. It starts disabled after a reload and does not save settings. An explicit quest ID must be in the current log. Only loaded blob data can be drawn; quests without area geometry may show nothing.

## Implementation

- Lazily adds its own `MapCanvasDataProviderMixin` instance to `WorldMapFrame`.
- Owns a plain `QuestPOIFrame`, parented and centered on `map:GetCanvas()`.
- Uses `DenormalizeHorizontalSize(1)` and `DenormalizeVerticalSize(1)` for the full map extent, not the cropped visible viewport or a hardcoded aspect ratio.
- Inherits canvas zoom and pan, and uses `PIN_FRAME_LEVEL_QUEST_BLOB` so map icons remain above the fill.
- Uses Blizzard's quest fill/border textures, with fill alpha 96 and border alpha 192.
- Map, scale, size, show and quest-data changes clear stale geometry and schedule a coalesced redraw on the native frame's next update. That handler removes itself after drawing; there is no idle polling.
- Closing the map clears/hides the frame and cancels pending drawing. Reopening redraws it.
- Quest/POI events are registered on the prototype's own frame, not through shared map-provider event counters.
- Disabling removes only this provider, cancels pending drawing, unregisters its events and hides its frame. Re-enabling reuses that same frame.

There are no hover, tooltip, click or hit-test handlers. Both mouse-click and mouse-motion input are disabled. The plain frame deliberately does not inherit `QuestBlobPinMixin`, which installs Blizzard's tracking and tooltip behavior.

Existing Blizzard/Questie pins and providers are unchanged. Their own tooltips still work. If Blizzard also draws the same quest, its fill can overlap this prototype; the command does not suppress other renderers.

## Validation

Tested live on Forever 1.60.1 build 69977 with quests 7, 33 and 1598:

- All-quest mode showed the Northshire shapes at their map locations, aligned with quest markers.
- The overlay stayed aligned under zoom and pan and clipped with the map canvas.
- Switching from Elwynn (1429) to Westfall (1436) cleared the Elwynn shapes; returning to Elwynn restored them.
- Hide/reopen cleared pending drawing and redrew correctly.
- Single-quest mode displayed only quest 7's shape.
- The overlay's effective scale matched the canvas. Width differed by only 0.000061 UI units due to native floating-point sizing; an initial exact-equality diagnostic returned false, not a visible projection error.
- After drawing, `OnUpdate` was absent. Mouse input and `OnEnter` were absent/disabled.
- Disable/re-enable changed provider count 38 → 37 → 38, reused the native frame, and left the map's shared POI event count at 1. Both owned event registrations were absent while disabled.
- No new Lua errors were recorded. Before/after snapshots contain the same pre-existing manual diagnostic calling the unavailable `C_Map.GetBestMapForPlayer`.

Native screenshots and state/error snapshots are in [world-map-validation](world-map-validation/). Resize callback behavior is covered by the mocked canvas-size test; a live window-resize/maximize cycle was not performed. Other map flavors, special insets and combat states have not been exhaustively validated.

Eight focused tests cover loaded-quest selection, full-canvas placement, deferred redraw, map/size/scale updates, hide/reopen, quest removal, cancellation/event cleanup and frame reuse. A fresh reviewer found no correctness or cleanup issues.

The module was injected into the authorized Forever client without reloading. The world map was opened and manipulated only for the rendering checks, then left on Elwynn with all-quest mode enabled. Existing workbench/extractor code and quest progress were not changed.

## Source baseline

Matching Gethe Forever commit: `c6e89983189e4f626f549204a23c2d2bea93080a`.

- `Interface/AddOns/Blizzard_SharedMapDataProviders/QuestBlobDataProvider.lua`: native blob setup, size and scale redraw policy.
- `Interface/AddOns/Blizzard_MapCanvas/MapCanvas_DataProviderBase.lua`: provider lifecycle and canvas callbacks.
- `Interface/AddOns/Blizzard_MapCanvas/Blizzard_MapCanvas.lua`: canvas positioning, provider dispatch and removal order.
