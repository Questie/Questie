# Blob work area

Local experiments and findings for Forever quest POI/blob rendering, hit-testing and contour reconstruction. This entire directory is ignored through this checkout's `.git/info/exclude`, not the shared `.gitignore`.

## Start here

- [Native world-map prototype](WORLD_MAP.md): `/blobmap [all|questID|off]` draws loaded Blizzard blobs at map locations, following canvas zoom/pan without hover, tooltips or click handlers.
- [Micro-optimization decisions](performance/micro-optimizations/README.md): paired live measurements of all five candidates; only optional phase profiling was retained. Includes combined tests, outlier analysis and exact-output checks.
- [One-time outline extractor](EXTRACTOR.md): sparse discovery, boundary following and precise edge bisection; compact cyclic rings, budgeted jobs, golden validation and native timings. Separate from the grid scanner.
- [Golden reference and performance](performance/README.md): 3.15-million-sample native capture, live query/timing benchmarks, and an offline accuracy/query-budget test. Experimental strategies are not wired into `/blob`.
- [Local hitscan library and workbench](HITSCAN_PROTOTYPE.md): `/blob` now has **Grid hits** and **Outline** modes, objective filtering, background budgets, native blue previews with squares or closed contours, and timing metrics. Loaded locally by the Camelot TOC only.
- [Recipe and current findings](docs/quest-blob-hit-testing.md): setup, readiness checks, appearance, hover, sampling, objective identity, overlap handling, validation and cleanup. Keep this updated as new cases are tested.
- [Single-quest experiment](blob-hit-test-quest7/FINDINGS.md): quest 7, raw samples, approximate contour and native preview screenshot.
- [Overlapping-quest experiment](blob-hit-test-overlap/FINDINGS.md): quests 7 and 33, separate sampling and overlap masking.
- [File/cache investigation](cache-investigation/FINDINGS.md): extracted DB2s, decoded CSVs and pre-exit cache snapshots.
- [Post-exit cache investigation](cache-investigation/after-exit.Sr8GQR/FINDINGS.md): current-build cache inspection and before/after comparisons.

## Previews

- [Dense golden mask](performance/quest7-golden.png)
- [Adaptive versus native golden difference](performance/adaptive-8192.comparison.png)
- [Quest 7 outline](blob-hit-test-quest7/contour.svg)
- [Overlapping outlines](blob-hit-test-overlap/overlap.svg)
- [Native renderer screenshot](blob-hit-test-quest7/native-preview.png)

## Working rules

Keep experiment code, raw observations and new findings here. Distinguish original native geometry from approximate sampled contours, and tested behavior from hypotheses. Record client build, quest/map IDs, setup, validation and cleanup for each experiment.

Cache files are copied snapshots, not the live game cache. Some captured logs and JSON retain their original temporary paths as provenance; moving them here does not change those historical paths.
