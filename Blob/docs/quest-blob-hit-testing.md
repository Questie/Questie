# Reconstructing quest blob outlines through native hit-testing

Status: experimental recipe, not a production implementation. Tested on Forever **1.60.1, build 69977**, on 2026-09-23. Update this document as new cases are tested; keep raw observations in the corresponding experiment directory.

## Runnable local prototype

The [hitscan library and workbench](../HITSCAN_PROTOTYPE.md) implement this recipe under `Blob/`. Use `/blob` or `/blob 7`, choose a loaded quest/map and optional native objective index, select **Grid hits** or **Outline**, then press Hitscan. Both modes work in bounded per-frame batches and auto-fit the native blue blob. Grid mode overlays sampled squares; Outline mode overlays the extractor's closed colored rings and vertex markers. Precise work/plot timings and mode-specific progress are displayed. Switching modes cancels stale work and clears its overlay. The prototype is local-only and its ignored files are referenced only by the Camelot TOC.

The live prototype additionally confirmed that default 200-cell full-map scans recover 40 hits for quest 7 and 445 for quest 33 at map 1429; native index 0 filtering worked on both. Layout/redraw/render waits remain heuristic. See the prototype guide for performance observations, cleanup tests, runtime limitations and artifacts.

## Golden reference and performance experiments

A [dense native reference and offline golden test](../performance/README.md) now cover quest 7 at 2049 by 1537 sample positions within its local area. The fixture preserves all 3,149,313 results as row runs, independent of the workbench's retained-hit cap. The performance notes compare actual native query counts/timings with measured area agreement, and distinguish live results from nearest-sample offline replay.

The first adaptive experiment meets the provisional 99.5% IoU / 8,000-query golden-test target for this fixture. It is not yet integrated into the workbench, and coarse discovery can still miss smaller features on other quests. Use the fixture to test changes before replacing the current runtime algorithm.

## Optimized one-time extraction

The separate [BlobExtractor library](../EXTRACTOR.md) now performs sparse discovery, fixed-lattice boundary following, shared edge bisection and closed-loop assembly in budgeted jobs. On the native quest-7 fixture, its default settings used 2,838 queries and 13.74 ms median active time for 99.7055% IoU, producing 68 cyclic-ring vertices. The existing grid scanner remains unchanged. Persistence and quest-state checks remain out of scope.

## What we can recover

An independent `QuestPOIFrame` can draw a quest's loaded blobs and answer whether a normalized map coordinate hits that quest. Sampling this function lets us reconstruct an **approximate hit-test boundary** without packet capture, process-memory reads, or access to the original polygon vertices.

Draw and sample **one quest at a time**. When multiple quests are drawn together, the method returns one quest at an overlap, not all matching quests.

The recovered shape is the union of the hit-testable areas for that quest. It is not necessarily a separate polygon for each native blob, objective or spawn location.

## Evidence so far

| Test | Result | Evidence |
|---|---|---|
| Quest 7 alone | One contour, 150 boundary samples; agreement at all 493 holdout positions | [Single-quest findings](../blob-hit-test-quest7/FINDINGS.md) |
| Quests 7 and 33 overlap | Separate sampling recovered both quests; agreement at all 5,304 holdout positions per quest | [Overlap findings](../blob-hit-test-overlap/FINDINGS.md) |
| Combined frame | Returned quest 7 at all 109 holdout positions where both isolated frames hit | [Native validation output](../blob-hit-test-overlap/validation.json) |
| Multiple native blobs | Quest 33 reports four blobs; sampling recovered two connected regions, not four identified source polygons | [Quest 33 contours](../blob-hit-test-overlap/contour-33.json) |
| Immediate drawing after creation | Produced missing/misplaced hits; a later redraw after layout settled corrected them | [Failed initialization scan](../blob-hit-test-overlap/coarse-before-redraw.json) |
| Cleanup | `DrawNone()` removed the control-point hit; probes were hidden and references released | [Cleanup output](../blob-hit-test-overlap/cleanup.json) |

Previews: [quest 7](../blob-hit-test-quest7/contour.svg), [overlapping quests](../blob-hit-test-overlap/overlap.svg).

No Lua errors were recorded during these experiments. This does not establish safety across combat states, different clients or arbitrary quest content.

## API working set

| API | Purpose and observed limits |
|---|---|
| `C_QuestLog.GetQuestsOnMap(uiMapID)` | Quest IDs and normalized pin coordinates; not polygon vertices. |
| `GetQuestPOIBlobCount(questID)` | Native blob count; not necessarily the number of reconstructed contours. |
| `CreateFrame("QuestPOIFrame", nil, UIParent)` | Independent native frame without Blizzard's map mixin or scripts. |
| `probe:SetMapID(uiMapID)` | Selects this frame's map. Do not substitute the global `C_QuestLog.SetMapForQuestPOIs`. |
| `probe:DrawNone()` | Clears the probe's drawn blobs. |
| `probe:DrawBlob(questID, true)` | Draws this quest's loaded blob data on the probe. |
| `probe:UpdateMouseOverTooltip(x, y)` | Returns `questID, numObjectives` on a hit; no values outside in our tests. Does not require moving the physical mouse. |
| `probe:GetTooltipIndex(i)` | Reads objective indices for the latest hit. `GetTooltipIndex(1)` returned **0** in our tests. Read before the next hit-test changes that state. |

Coordinates passed to the hit-test are normalized map coordinates, not pixels or percentages: `(0.49, 0.36)` means `(49%, 36%)`. Generic frame `GetPoint()`/`GetNumPoints()` concern anchors, not blob vertices.

Quest/objective identity comes from the hit-test result and its immediately following `GetTooltipIndex(1..count)` calls, not from parsing displayed tooltip text. A live check returned quest 7, count 1, `GetNumTooltips()` 1, and `GetTooltipIndex(1)` 0. Separately, `GetQuestPOILeaderBoard(0, C_QuestLog.GetLogIndexForQuestID(questID))` returned the correct objective text/type/completion for both quests 7 and 33. Preserve this as a **native POI objective index**; do not assume it is directly interchangeable with a one-based Questie objective array or that adding one handles every objective layout. Both tested quests have one objective. Multi-objective mappings and multiple matching indices remain unvalidated.

## Appearance, object access and hover

We get a native `QuestPOIFrame` handle with ordinary frame methods and the blob-specific methods, not a Lua object for each polygon. It exposes map identity, rendering controls and hit-test results. No vertex-array getter was found. Lua fields such as Blizzard's `questID` are bookkeeping supplied by its mixin, not decoded native geometry.

Appearance controls in the matching API include:

- `SetAlpha(0..1)` for the whole frame.
- `SetFillAlpha` and `SetBorderAlpha` for independent fill/border opacity, using the byte-style scale seen in Blizzard's own code: fill 128 and border 192. Our visible preview used 170 and 255.
- `SetFillTexture`, `SetBorderTexture` and `SetBorderScalar` for texture assets and border scaling.
- `EnableSmoothing`, `SetNumSplinePoints`, `EnableMerging` and `SetMergeThreshold` are declared native controls. Their effects and safe settings have not been tested here.

These settings apply to the frame's rendering, rather than returning separately styleable polygon objects. We have not established a direct RGB tint API.

Blizzard's `QuestBlobPinMixin:OnUpdate()` calls `UpdateTooltip()` every frame. That method:

1. Skips blob tooltip work when the POI-button highlight manager already has a highlight.
2. Obtains the cursor's normalized map coordinates.
3. Calls `UpdateMouseOverTooltip(x, y)` to identify the quest and matching objective count.
4. Resolves the quest-log entry and respects an existing tooltip owned by another frame.
5. Builds `GameTooltip` itself from the quest title and unfinished objective text. It uses `GetTooltipIndex` / `GetQuestPOILeaderBoard` when the reported objective count matches the quest's objective count, otherwise falling back to quest-log objective text.
6. Hides its owned tooltip when there is no applicable hit.

The native hit-test does not itself display `GameTooltip`. Blizzard's Lua supplies that behavior. There is no demonstrated per-polygon `OnEnter` object/event; ordinary frame hover concerns its rectangular frame area. A custom blob UI can poll the same hit-test and choose its own tooltip/highlight policy. For an enlarged or cropped viewport, convert the cursor back to the original normalized map coordinates before querying.

This tooltip description is from matching Blizzard source, not a separate live `GameTooltip` experiment. The first preview installed no hover behavior. A later preview added live quest-ID and objective-count labels, using the cursor conversion below, but still did not display `GameTooltip`.

## Recipe

### 1. Establish the test case

Record the client build, map ID, quest ID, completion state, native blob count and objective information. Start with a quest whose blob is loaded and visible to the client. We have not established how to request arbitrary unaccepted quests' blobs.

Record recent errors before testing. Leave Blizzard's map selection, tracking and frame scripts untouched. The experiments created probes outside combat; combat-time creation and sampling remain untested.

### 2. Create a separate probe

This is a staged recipe, not a single synchronous macro. Retain `probe` and `questID` in the test harness between phases. The snippets below share that state.

```lua
local questID = 7
local uiMapID = 1429
local probe = CreateFrame("QuestPOIFrame", nil, UIParent)
probe:Hide()
probe:SetPoint("CENTER", UIParent, "CENTER")
probe:SetSize(1000, 668)
probe:SetMapID(uiMapID)
probe:SetFillTexture("Interface\\WorldMap\\UI-QuestBlob-Inside")
probe:SetBorderTexture("Interface\\WorldMap\\UI-QuestBlob-Outside")
probe:SetFillAlpha(128)
probe:SetBorderAlpha(192)
probe:SetBorderScalar(1)
probe:EnableMouse(false)
probe:SetAlpha(0.01)
probe:Show()
```

Do not inherit `QuestBlobPinTemplate` or attach Blizzard's map provider. The experiments needed only the native frame type. The probe is faintly visible during initialization but cannot intercept mouse input.

### 3. Let layout settle, then redraw

In a **later UI turn**, after frame layout has settled:

```lua
probe:DrawNone()
probe:DrawBlob(questID, true)
```

Allow a render pass before sampling. In the experiments these phases occurred in separate bridge requests; we have not established a sufficient fixed delay or a native readiness signal.

Do not treat the initial empty result as proof that no blob exists. Immediate drawing after frame creation once projected the wolf blob near x 0.98 instead of its expected Elwynn area. A later redraw fixed it.

The successful sequence used nonzero alpha while initializing. After valid hits were established, `probe:SetAlpha(0)` kept the probe invisible and subsequent queries still worked. We have not isolated whether nonzero alpha, layout completion, the redraw, or a combination is strictly necessary. Keep the working sequence until that is tested.

### 4. Check controls before collecting geometry

```lua
local hitQuestID, objectiveCount = probe:UpdateMouseOverTooltip(x, y)
local inside = hitQuestID == questID
```

Check an independently known inside point and an outside point. For the tested state of quests 7 and 33 on map 1429:

- `(0.49, 0.36)` hit either quest when that quest alone was drawn.
- `(0, 0)` was outside in whole-map scans.

These are test-specific controls, not universal quest coordinates. A POI pin is useful for finding the area but is not guaranteed to lie inside a blob.

If controls fail or the discovered area is implausible, stop and resolve initialization/data readiness before exporting an outline. Repeating an invalid scan at higher resolution does not fix its projection.

### 5. Discover regions, then sample locally

1. Sample normalized coordinates across the map. The successful discovery pass used spacing `0.01`, including both endpoints: 101 by 101 positions.
2. Keep every hit region, not just the area nearest the pin. Quest 33 had a second disconnected region well south of the first.
3. Surround the discovered regions with outside margin and resample locally. We used spacing `0.001` for quest 7 and `0.002` for quest 33.
4. Store the origin, spacing, width, height and inside/outside results. Preserve quest and map identity with the grid.
5. Ensure the local grid's entire boundary is outside. Otherwise expand it before tracing contours.

A coarse pass can miss narrow or small regions completely. An empty border and successful holdout tests do not prove complete map coverage. A robust collector would need adaptive refinement and explicit coverage limits.

Sample in bounded batches rather than blocking gameplay with a large synchronous scan. Some multi-frame experimental scans took tens of milliseconds. Those timings are diagnostics, not a production performance budget.

### 6. Find crossings and join contours

For each horizontal or vertical grid edge whose endpoints disagree:

1. Keep the inside and outside endpoints.
2. Query the midpoint.
3. Replace the endpoint with the same classification as the midpoint.
4. Repeat; we used ten bisections.
5. Save the final midpoint, together with the grid edge's axis and integer indices.

Join crossings cell by cell, as in marching squares. In the tested grids, every intersected cell had exactly two crossings. Connecting those pairs produced graphs where every vertex had degree two; tracing each cycle recovered the closed contours.

Do not blindly connect cells with four crossings. Those are ambiguous saddle cases, which did not occur here. Further native samples or subdivision would be needed. Likewise, sampling cannot reveal a sub-grid island or hole when all sampled corners miss it.

Export normalized coordinate contours and distinguish outer regions from holes if later rendering requires it. Preserve the raw grid and crossing samples alongside the export.

Ten bisections improve the location of a detected crossing. They do not recover original vertices or remove uncertainty from grid spacing, smoothing and renderer resolution.

### 7. Isolate overlapping quests

Use separate probes, or test a carefully reinitialized single-probe reuse path. Only the separate-probe approach has been validated across the overlapping quests so far.

```lua
probe:DrawNone()
probe:DrawBlob(questID, true)
```

Do not draw all quests and assume repeated hit-testing can enumerate every quest under a coordinate. Our combined probe consistently returned quest 7 where isolated probes hit both 7 and 33.

For multiple overlapping objectives within one quest, the latest hit's objective indices are a possible discriminator. That experiment has **not** been done. Regions belonging to the same objective may remain indistinguishable.

### 8. Validate at new positions

Sample a shifted grid whose positions differ from those used for reconstruction. Compare the native hit-test with an offline point-in-polygon test of the exported contours.

Record sample count, mismatch coordinates and whether errors favor false positives or false negatives. Include overlap positions and disconnected regions. Zero mismatches is evidence for those positions, not a proof of exact equivalence everywhere.

As a negative control, `DrawNone()` should remove a previously confirmed hit from the probe.

### 9. Clean up even after failure

```lua
probe:DrawNone()
probe:Hide()
probe:UnregisterAllEvents()
probe = nil
```

Clear any additional harness references and cancel any harness timers or callbacks. The tested probes did not install events or scripts. WoW does not destroy created frames; they remain inert and hidden until UI reload. Repeated production use should avoid allocating unlimited probes.

Read recent errors again and record cleanup status. Do not modify or clear Blizzard's actual blob frame as part of cleanup.

## Rendering a visible preview without extracting points

A separate native frame also renders the quest blob directly in a normal screen panel. This was visually confirmed for quest 7: [native preview screenshot](../blob-hit-test-quest7/native-preview.png). This is Blizzard's renderer, not a drawing of the reconstructed contour.

The tested preview used a 620 by 340 clipped viewport (`SetClipsChildren(true)`) and a larger 7000 by 4666.6667 `QuestPOIFrame` inside it. To center the chosen map coordinate `(cx, cy)`, anchor the blob frame's top-left to the viewport center with offsets `(-width * cx, height * cy)`. For quest 7, the sampled bounding-box center was approximately `(0.49351123, 0.36308301)`.

The panel was shown before a delayed `DrawNone()` / `DrawBlob(7, true)` call. A 0.25-second delay worked in this demonstration; it is not an established readiness guarantee. Fill alpha 170 and border alpha 255 made the enlarged shape easy to see. Mouse input was disabled on the blob frame. The preview had a close button and a 60-second timeout, both leading to clearing/hiding the blob, cancelling timers and releasing the harness reference.

This demonstrates a display option that needs no contour reconstruction. It does not grant access to the original vertices.

### Live hover labels in a cropped preview

A second preview added `QuestId` and `objectiveCount` labels updated from an `OnUpdate` handler on the panel. Only query while the cursor is within the clipped viewport. Convert physical screen coordinates using the **full blob frame**, not the viewport:

```lua
local cursorX, cursorY = GetCursorPosition()
local scale = blob:GetEffectiveScale()
local x = (cursorX / scale - blob:GetLeft()) / blob:GetWidth()
local y = (blob:GetTop() - cursorY / scale) / blob:GetHeight()
local questID, objectiveCount = blob:UpdateMouseOverTooltip(x, y)
```

This accounts for the enlarged frame's offset and effective UI scale. Outside the viewport, clear both labels without querying off-viewport geometry. Inside the viewport but outside the shape, the native query returns no values; the labels display `nil`, not a fabricated objective count of zero. Update label text only when the returned values change.

The second preview used a 120-second timeout. Its `OnHide` handler removes `OnUpdate`, clears/hides the blob, cancels both timers and releases the bridge reference. Native control queries still returned `(7, 1)` inside and no values outside, with no recorded Lua errors.

## Evidence to save for every new case

- Build, map ID, quest IDs, objectives, completion states and native blob counts.
- Exact setup sequence and readiness controls, including failed attempts.
- Raw grids, crossing samples, approximate contours and a preview.
- Independent validation samples and mismatches.
- Error snapshots, cleanup status and any UI/settings changes made.
- What this case establishes, and what remains untested.

## Next cases worth testing

- Overlapping objectives within one quest, including multiple tooltip indices at one position.
- Small islands, narrow connections, holes and ambiguous marching cells.
- Changing quest completion or map data during a scan.
- Whether a probe can be reused across maps/quests with reliable readiness checks.
- Frame size, scale, smoothing and visibility effects on the hit-test boundary.
- Ordinary addon execution and combat behavior; current evidence is from bridge execution.

## Blizzard source baseline

Matching Forever source commit: `c6e89983189e4f626f549204a23c2d2bea93080a` (1.60.1 build 69977).

- [QuestBlobDataProvider.lua](https://github.com/Gethe/wow-ui-source/blob/c6e89983189e4f626f549204a23c2d2bea93080a/Interface/AddOns/Blizzard_SharedMapDataProviders/QuestBlobDataProvider.lua): native blob setup, drawing, normalized hit-testing and tooltip index use.
- [FrameAPIQuestPOIDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/c6e89983189e4f626f549204a23c2d2bea93080a/Interface/AddOns/Blizzard_APIDocumentationGenerated/FrameAPIQuestPOIDocumentation.lua): hit-test and objective-index signatures.
- [FrameAPIBlobDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/c6e89983189e4f626f549204a23c2d2bea93080a/Interface/AddOns/Blizzard_APIDocumentationGenerated/FrameAPIBlobDocumentation.lua): drawing and map configuration methods.
