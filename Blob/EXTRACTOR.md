# One-time blob outline extractor

`BlobExtractor.lua` is a separate extraction library. It does not replace the `/blob` grid scanner, create UI, persist data, or watch quest state. The Camelot TOC loads it locally alongside the existing prototype. As with the rest of `Blob/`, its ignored files are not release-ready TOC dependencies.

The workbench now exposes this library through its **Outline** mode: open `/blob`, select Outline, then press Hitscan. **Grid hits** still uses the original scanner. See [workbench usage and comparison results](HITSCAN_PROTOTYPE.md).

## API

```lua
local Extractor = QuestieLoader:ImportModule("BlobExtractor")
local job, err = Extractor.New(function(x, y)
    local id, count = preparedProbe:UpdateMouseOverTooltip(x, y)
    if id ~= questID then return false end
    for i = 1, count or 0 do
        if preparedProbe:GetTooltipIndex(i) == nativeObjectiveIndex then return true end
    end
    return false
end, {
    discoveryCells = 32,
    boundaryCells = 512,
    edgeTolerance = 1 / 32768,
    budgetSeconds = 0.001,
    clock = GetTimePreciseSec,
})

-- Caller-driven, typically once per UI frame:
if job and job.status == "running" then job:Step() end
-- job:Cancel("Closed") stops any phase.
```

The caller owns a prepared, quest-isolated native frame and reads native objective indices immediately after each hit-test. Keep the oracle and geometry stable throughout a job. The library itself needs only a membership function, clock and QuestieLoader registration.

Options:

- `discoveryCells`: 2–128 coarse subdivisions per map axis, default 32.
- `boundaryCells`: tracing lattice, default 512, maximum 4096. It must be at least twice discoveryCells, with a power-of-two ratio.
- `edgeTolerance`: normalized edge-crossing precision, default 1/32768; range 1/16777216 through 1/boundaryCells.
- `budgetSeconds`: cooperative Step budget, default 0.001, range 0.0001–0.002.
- `clock`: defaults to GetTimePreciseSec; an injected monotonic seconds clock permits offline testing.

`New` returns `nil, error` for invalid inputs. Status is `running`, `complete`, `cancelled` or `error`. Extraction errors are returned as `job.reason`; the library does not print or invoke the game's error handler. Cancelled/error jobs publish no partial contours. Completed and cancelled jobs are inert and release their oracle/coroutine references and working state for garbage collection.

Completed `job.contours` is an array of cyclic rings, each an array of normalized `{x, y}` pairs. The last point connects to the first; the first point is not repeated. Render with **even-odd fill semantics** so discovered inner rings remain holes. Rings are deterministic for a fixed oracle/configuration, but no semantic outer/hole labels or original native blob IDs are assigned.

Metrics include `queries`, `crossings`, `discoveryVisited`, `boundaryVisited`, `rawVertices`, `vertices`, `activeSeconds`, `wallSeconds`, `maxSliceSeconds`, `slices`, `phaseQueries` and `phaseSeconds`. Active time includes all Step bookkeeping; phase time measures resumed phase work and therefore does not sum to the full active duration.

## Algorithm

1. **Sparse discovery.** Cache corner samples on a coarse grid and sample uniform coarse cells' centers. Subdivide disagreeing cells down to the tracing lattice to obtain boundary seeds.
2. **Boundary following.** Starting at those seeds, follow crossed edges into neighboring cells on one fixed lattice. This also visits neighboring regions that coarse discovery skipped, avoiding coarse/fine stitching seams.
3. **Precise crossings.** Identify each horizontal/vertical edge by its canonical integer ID. Bisect each crossing only once; neighboring cells share the resulting point. No float-equality matching is used for connectivity.
4. **Closed-loop assembly.** Marching-square saddle cases query the cell center. Require a degree-two graph and trace every cycle. Concave, disconnected and nested rings are supported when discovered.
5. **Conservative compaction.** Remove only exactly collinear forward runs. Near-collinear vertices are retained rather than applying an absolute area threshold that could collapse tiny valid rings. No lossy RDP is applied.

A coroutine yields after every new oracle query and each bounded cell/graph/vertex operation. Step also has a 512-resume ceiling. Discovery, tracing, bisection, assembly and compaction all participate in the time budget. An individual native call or garbage-collection pause cannot be preempted; the budget is soft, not a hard real-time guarantee. Fixed safety caps stop jobs after 250,000 queries or discovery/boundary cells.

## Accuracy limits

Finite discovery can miss small islands or holes between samples. Coarse center checks help but do not make discovery exhaustive. A narrow gap or two nearby boundaries within one terminal cell can also be unresolved by its corner/center samples. Increasing boundary resolution may be necessary even when edge bisection is precise. Precision along a detected edge does not recover undiscovered topology.

Inside samples on the normalized map boundary cause an explicit error rather than silent clipping. Open/non-manifold/degenerate graphs also fail instead of returning partial geometry. The contour approximates native hit-testing, not original server vertices.

This implementation deliberately does not address persistence, invalidation, needle checks, automatic quest hooks or UI changes.

## Golden and native results

Reference: quest 7, native index 0, map 1429, Forever 1.60.1 build 69977. The original 3,149,313-sample fixture/checksum and previous adaptive artifacts were preserved.

| Setting | Native queries | Native vertices | Native IoU | Median active time | Median wall time |
|---|---:|---:|---:|---:|---:|
| Default boundary grid 512 | 2,838 | 68 | 99.7055% | 13.74 ms | 0.480 s |
| Boundary grid 1024 | 3,440 | 122 | 99.8828% | 17.79 ms | 0.614 s |
| Earlier adaptive 8192 baseline | 6,937 | Filled/mixed cells, not compact rings | 99.7026% | 29.08 ms | 1.600 s |

Three native runs per setting, on the same separately prepared frame. Default active runs were 19.74, 13.74 and 13.56 ms; the first run was slower. Largest default slice was 1.233 ms. These are local observations, not universal timing promises. Rendering, persistence, frame preparation and external state guards are outside extraction active timing; job setup was separately measured and under 0.06 ms.

Default native work used 2,394 discovery queries and 444 bisection queries. Sharing already sampled corners meant the tracing phase added no new oracle queries in this fixture. The native result has 74 raw crossing vertices, reduced to 68 by straight-run removal.

Offline nearest-sample replay differs slightly from direct native sampling:

- Default: **99.6932% IoU**, 2,838 queries, 67 vertices.
- 1024: **99.8598% IoU**, 3,440 queries, 130 vertices.

The default meets the provisional golden gates of IoU >= 99.5% and <= 4,000 queries, and the three-run native median meets the initial <15 ms active target. One fixture does not establish general runtime readiness or arbitrary-objective coverage.

## Run the tests

```bash
busted Blob/BlobExtractor.test.lua
uv run --no-project python Blob/performance/TestExtractorRaster.py
uv run --no-project python Blob/performance/ExtractorGoldenTest.py --preview
uv run --no-project python Blob/performance/ExtractorGoldenTest.py --resolution 1024
```

The extractor golden test executes the actual Lua module against the captured mask, then classifies all golden positions with even-odd contour rasterization. It does not clone the extraction algorithm in Python. Outputs are separate from the original adaptive test. Outside the fixture ROI, the offline oracle is defined as empty; that assumption does not validate whole-map coverage.

- [Default offline result](performance/extractor-golden-result.json)
- [Default offline difference image](performance/extractor-golden-difference.png)
- [Native default comparison](performance/extractor-live/comparison-512.json)
- [Native default contours](performance/extractor-live/contours-512.json)
- [Native default difference image](performance/extractor-live/comparison-512.png)
- [Native finer comparison](performance/extractor-live/comparison-1024.json)
- [All native timing runs](performance/extractor-live/benchmark.json)

## Validation and live scope

Eighteen focused Lua tests cover concavity, disconnected regions, a center-discovered island, a hole, saddle handling, shared-query reuse, all-phase cancellation, frozen-clock work caps, oracle errors, bounds errors, input validation and reentrant cancellation. The review regressions include cancellation followed by a bounds-invalid return or exception, and a tiny noncollinear ring at the minimum supported edge tolerance. Three Python tests cover parity rasterization for holes, disconnected rings and concavity. Full Busted suite after the review fixes: 2,099 successes. Extractor source/test luacheck passes. The existing adaptive golden and loader validation were also rerun successfully after these fixes.

The module was injected into the authorized Forever client with the bridge. No reload, map selection, tracking or quest-progress change was performed. A new independent native probe was prepared with the known layout/redraw/render sequence. Benchmark scripts cancelled on POI changes, combat or changed quest signature. All six native jobs completed; the probe was cleared, hidden and unregistered, and bridge references were released after export. Existing `/blob` UI/scanner code was not changed.

The before/after error snapshots contain the same pre-existing bridge diagnostic from the earlier performance investigation, with no new errors from extraction. An earlier reentrant-cancellation guard and type annotations were added after the recorded native benchmark, then reinjected for the cancellation/release smoke check (`final-module-smoke.json`).

A subsequent focused review found two remaining cases: an error after oracle-triggered cancellation could overwrite its terminal status, and the absolute collinearity threshold could erase tiny valid rings. `Step` now preserves terminal status immediately after resuming the coroutine, and compaction removes only exactly collinear forward runs. All three new regressions failed before these fixes and pass afterward. Offline golden replay remains unchanged at both 512 (99.6932% IoU, 2,838 queries, 67 vertices) and 1024 (99.8598% IoU, 3,440 queries, 130 vertices).

The final module was then reinjected without reloading. Live cancellation-then-hit and cancellation-then-throw checks both retained their cancellation reason and released their oracle/coroutine references; see `performance/extractor-live/reviewed-cancellation.json`. The final error snapshot contains only the same pre-existing bridge diagnostic. Native extraction timing artifacts were preserved and were not remeasured after these two fixes. The worker's golden checks ran in an isolated copy; the parent subsequently reran the default golden checks successfully in this work area.
