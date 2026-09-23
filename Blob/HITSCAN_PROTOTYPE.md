# Local hitscan library and visual workbench

This is a local prototype, loaded only by `Questie_Camelot.toc`. `Blob/` remains locally ignored. **Do not commit or release the TOC entry without deliberately including or removing these local files.**

## Open and use

- `/blob` opens the workbench, defaulting to the supertracked/first loaded quest and the player's current UI map.
- `/blob 7` opens it with quest 7 selected.
- **Next quest** cycles the current quest log. Quest/map ID fields can also be edited directly.
- **Native index** is blank for all matching objectives. Enter `0` for native index zero. This is not a one-based Questie objective index.
- Choose **Grid hits** or **Outline** using the two buttons in the title row. The selected mode's button is disabled. Switching modes cancels the old job and clears its preview; press **Hitscan** to run the new mode.
- **Grid hits** uses `BlobHitscan`. **Grid cells** accepts 10–500 subdivisions per axis; the default 200 gives 40,401 full-map samples. Results are small colored squares.
- **Outline** uses [BlobExtractor](EXTRACTOR.md). **Boundary cells** defaults to 512; valid values are 64, 128, 256, 512, 1024, 2048 and 4096. Discovery stays at 32 cells and crossing tolerance at 1/32768. Results are closed colored lines with small squares at the vertices. Colors distinguish rings, not native objective IDs.
- **Boundary cells is per map axis, not per blob or a total query count.** At 512, the conceptual map lattice is 512 by 512, with cell width/height 1/512 of the normalized map. All regions for the selected quest/objective share that lattice. The extractor follows discovered boundaries instead of scanning every cell. Increasing this setting improves local boundary detail but cannot recover a region missed by the separate fixed 32-cell discovery pass. Start at 512 and compare 1024 when a shape has small features; the one quest-7 golden does not establish a universal best setting.
- Each mode remembers its own resolution input for this session. Quest/map/index fields are shared.
- **Hitscan** restarts the selected algorithm in bounded batches, then auto-fits and overlays its result on the real native blue blob.
- **Cancel**, changing an input, closing or dragging the panel, entering combat during work, or a quest/POI update stops stale work. Quest/POI changes invalidate displayed results.
- Drag the panel to move it. X closes it and removes its update handler and event registrations.

The blue renderer shows the whole quest, not just a selected objective. The native index filter applies to either the sampled squares or the extracted outlines. Only loaded quest geometry is supported; this does not fetch arbitrary unaccepted quest blobs. Wrong maps, missing data, invalid objective indices and sub-grid shapes can all yield no hits.

## Library interface

`BlobHitscan.lua` only depends on QuestieLoader for module registration and `GetTimePreciseSec()` for timing. It creates no frames, timers or global scheduler. The caller prepares and owns a native quest-isolated frame and calls `Step()` from its own per-frame driver.

```lua
local BlobHitscan = QuestieLoader:ImportModule("BlobHitscan")
local job, err = BlobHitscan.New(preparedProbe, {
    questID = questID,
    objectiveIndex = nil, -- all; native index 0 is valid
    cells = 200,
    budgetSeconds = 0.001,
    bounds = {minX = 0, minY = 0, maxX = 1, maxY = 1},
})

-- On each UI frame, while job.status == "running":
job:Step()

-- To abandon it:
job:Cancel("Closed")
```

`New` returns `nil, error` for invalid quest/index/grid/budget/bounds values. Do not change a running job's probe geometry or configuration. `Step` propagates native errors; the workbench catches them, stops the driver and forwards them to the normal error handler.

Results and progress:

- `status`: `running`, `complete`, or `cancelled`; `reason` describes cancellation.
- `samples`, `totalSamples`, `questSamples`, `matchedSamples`.
- `hits`: `{x, y, objectiveIndices}` in normalized map coordinates, retaining up to 20,000 matches.
- `objectiveIndices`: set of native indices encountered in this quest's hits, before filtering.
- `hitBounds`: bounds of all matching samples, including matches beyond the storage cap.
- `truncatedHits`: true when the retained-hit cap was reached.
- `activeSeconds`, `wallSeconds`, `maxSliceSeconds`, `slices`.

Completed and cancelled jobs are inert and release their probe reference. Retain or discard the job's sample arrays as needed.

## Timing and rendering limits

The UI aliases the real WoW timer as `PreciseSecs = GetTimePreciseSec`; both libraries use the same timer per job. Grid sampling has a **1 ms soft budget** and a ceiling of **512 queries per frame**. Extraction has a 1 ms soft budget with a 512-coroutine-resume work cap across all phases. Outline bounds preparation and plotting each have a separate 1 ms soft budget and 128-point/element cap per frame. A plotted outline element is one line plus one vertex square. A native call or allocation cannot be preempted, so measured slices can exceed the soft budget.

The UI's "CPU" figures are elapsed time spent inside the sampling/plotting sections, measured with `GetTimePreciseSec`, not operating-system CPU counters. Scan time includes hit-testing, index reading and result recording. Scan wall time starts after preparation and excludes layout/fit waits. Plot CPU time and its peak slice are reported separately. GPU render time is not measured. Status/hover labels update at 10 Hz rather than once per sample.

The UI reuses one panel, one native frame, and bounded square/line pools. Grid mode plots up to 4,096 retained samples. Outline mode plots up to 4,096 segments and vertices, closing each ring independently; full contours remain available in `UI.job.contours` even if the preview is capped. The status explicitly reports caps. Close hides both pools and resets the status to a restart prompt rather than showing stale completion metrics. Reopening reuses the frames.

Grid status reports samples/hits/squares. Outline status reports the extraction phase, native queries, ring/vertex counts and segments drawn. The work timing is the selected algorithm's timing; plotting time also includes the outline's batched auto-fit bounds pass. Native frame preparation/render waits and GPU time are not included.

## Readiness and scope

Frame layout settles for at least two update turns and 0.15 seconds, then the isolated quest is redrawn. Another two turns/0.15 seconds are allowed before sampling. The same sequence runs after auto-fit. This is an experimentally working heuristic, not a proven native readiness API. A zero-hit result is reported as ambiguous rather than proof of absent geometry.

The first runtime test found native EditBox `SetText` notifications may arrive after `Show` and `Start` in the same turn. The UI now records the text being scanned and ignores duplicate notifications for those values, while actual edits still cancel stale work.

No Blizzard map frame, global selected POI map, quest tracking or saved settings are changed. The map projection uses the 1.5 aspect ratio validated in these Elwynn experiments; other map shapes/scales still need testing. Multi-objective quests remain unvalidated on the live client. Native objective matching is tested in Lua and single-objective index zero is verified live.

## Validation on Forever 1.60.1 build 69977

- 13 focused Busted tests passed, covering native index-zero filtering, wrong-quest isolation, budgets/query cap, endpoint coordinates, cancellation/completion and UI close/restart/drag/data-change/deferred-edit notifications.
- Full suite: 2,078 successes, no failures/errors.
- Luacheck: zero warnings/errors in the four prototype Lua files.
- Loader call-site validator passed.
- Quest 7, all objectives: 40,401 samples, 40 hits; 67.86 ms active scan time, 2.700 s wall time, 1.003 ms peak scan slice.
- Quest 7, native index 0: same 40 hits; 70.52 ms active, 2.734 s wall, 1.003 ms peak.
- Quest 33, native index 0: 40,401 samples, 445 hits; 134.64 ms active, 4.502 s wall, 1.025 ms peak. Both disconnected native regions visibly aligned with the colored hit squares.
- Live restart cancelled the old job; close cancelled the replacement, removed OnUpdate and unregistered events.
- Final runtime session recorded no Lua errors. An earlier diagnostic bridge query indexed a cancelled/nil job and produced one bridge-only error; it is retained in the earlier error snapshots, not hidden.

Evidence is under [prototype-validation](prototype-validation/), including screenshots, metrics, error snapshots and the full-suite log. Timings are single observations, not stable benchmarks.

## Review fixes and final validation

Two UI-only fixes were applied after the runtime checks above:

- A successful **Hitscan** restart reinstalls the same protected update handler used by **Show**, so a caught runtime error no longer requires reopening `/blob` to resume work.
- Cancellation records the interrupted UI phase separately from the sampling job. Cancelling during fitting or plotting reports `cancelled during ... (plot incomplete)` and retains the actual plotted-square count. A successfully completed sampling job remains complete; it is not relabeled as a failed scan.

Three focused tests now advance the UI into sampling, fitting and partial plotting. They verify error/restart recovery, cancellation after completed sampling, and cancellation after 128 of 441 squares with no further texture allocation. Test mocks preserve frame dimensions, button callbacks, labels and texture creation; they do not simulate native geometry.

Validation after these fixes: **16 focused tests passed**, **2,081 full-suite tests passed**, and luacheck reported **zero warnings/errors** across the four prototype Lua files. The loader validator also passed.

The final source was then reloaded into Forever and checked through the bridge. Quest 33 completed 40,401 samples with 445 hits: 113.57 ms active scan time, 3.801 s wall time, and a 1.025 ms peak slice. A subsequent in-flight cancellation stopped the job after 4,824 samples; its replacement completed with the same 445 hits. A screenshot confirms the squares align with both native regions. The final session recorded no Lua errors. Error recovery and cancellation specifically during fitting/partial plotting were tested offline, not fault-injected into the client.

Final evidence: `reviewed-quest33.json`, `reviewed-lifecycle.json`, `errors-reviewed-final.json`, `test-suite-reviewed.log`, and `screenshot_req_1790174683_360e56b2.png` under `prototype-validation/`. A parent diagnostic mistakenly used the unavailable runtime `debug` global before the final reload; that bridge-only error is preserved in `errors-before-reviewed-reload.json`.

## Mode comparison validation

The two-mode workbench was reviewed and tested after integration. A stale close/reopen status was fixed. Tests additionally cover mode-switch cancellation and independent resolution inputs, native index zero and wrong-quest filtering, per-ring closing lines, extractor errors, multi-frame bounds work, elapsed-time cutoff, the 4,096-element cap and pool reuse for shorter results.

- Focused UI/grid/extractor tests: **42 passed**.
- Full suite: **2,107 passed**; UI/source-test lint and loader validation passed.
- Live quest 7 grid: **40,401 samples, 40 hits**, 67.11 ms active, 2.669 s work wall time.
- Live quest 7 outline: **2,838 queries, 1 ring, 68 vertices**, 13.98 ms active, 0.470 s work wall time.
- Live quest 33 outline: **5,575 queries, 2 rings, 305 vertices**, 36.02 ms active, 1.234 s work wall time.
- Screenshots confirmed native blue blobs with grid squares in grid mode and correctly closed colored outlines/vertex markers in outline mode, including both disconnected quest-33 regions.
- The final reloaded session recorded no Lua errors. Preload diagnostics trying to locate the old anonymous window encountered a forbidden-frame error and a GetRegions stack overflow; those occurred before the new UI loaded and remain in `modes-errors-before-reload.json`. An authorized reload avoided that inspection path.

Evidence is under `prototype-validation/`: `modes-grid.json`, `modes-outline.json`, `modes-outline-33.json`, `modes-errors-final.json`, `modes-test-suite.log`, and the three mode screenshots starting `screenshot_req_17901805` / `screenshot_req_17901806`. The workbench was left open on quest 33 in Outline mode. Existing startup/trace-consent prompts were left untouched.

## Loading/deployment details

The installed beta addon resolves through the Era and progression addon links to this checkout. No game-file copy was needed. Only the Camelot TOC was changed; other clients' TOCs were left untouched.

Four authorized reloads have been issued across the original prototype and mode integration. The bridge helper timed out waiting for its screenshot completion marker, but subsequent bridge queries confirmed new runtime sessions and successful loading. No blind retry was made. The fourth reload loaded the two-mode UI; no additional TOC change was needed for mode selection.

The user-facing UI was left open on quest 33/all native indices with completed results. The unrelated Questie startup/QuestieTrace prompts that appeared after reload were not accepted, dismissed or modified.
