# Legacy Questie blob information package

The best-supported final iteration of the unpublished custom blob work from `W:\QuestieBackup\QuestieDev-master`, with linked code, assets, and experimental prototypes. This is **not a runnable addon**. The 86 original files retain their paths, bytes, comments, and line endings.

Start with [the detailed explanation](ANALYSIS.md), which links directly to the copied code. [The source index](SOURCE_INDEX.md) lists every original file.

## Package layout

```text
README.md          Reading guide and scope
ANALYSIS.md        Algorithms, rendering, integration, and limitations
SOURCE_INDEX.md    Clickable inventory of all 86 original files
MANIFEST.json      File sizes, SHA-256 hashes, and source provenance
SHA256SUMS         Integrity checks for the package files
HISTORY.txt        Relevant Git commit IDs, author dates, and subjects
source/            Original files, with their original relative paths
```

`source/` is the primary implementation. Its five Blob files and `QuestiePolygon.lua` match the main backup archive byte-for-byte, while the unpacked project contains later surrounding integration work. Redundant and superseded snapshot copies were removed from this package. The original archives remain untouched in the backup; [the historical summary](ANALYSIS.md#archive-comparison) records their differences.

## Read the implementation

| Concern | Start here |
| --- | --- |
| Public API, smoothing, fill geometry | [`Blob.lua`](source/Modules/Blob/Blob.lua) |
| Gift wrapping, centroids, hit testing, reduction | [`BlobUtil.lua`](source/Modules/Blob/BlobUtil.lua) |
| World-map provider and hover | [`BlobMap.lua`](source/Modules/Blob/BlobMap.lua) |
| Frame ownership and release | [`BlobFramePool.lua`](source/Modules/Blob/BlobFramePool.lua) |
| Fill/line textures and masks | [`BlobTexturePool.lua`](source/Modules/Blob/BlobTexturePool.lua) |
| Clustering, caching, objective toggles, teardown | [`QuestiePolygon.lua`](source/Modules/Map/QuestiePolygon.lua) |
| Moving-center calculations | [`MapLib.lua`](source/Modules/NewMap/MapLib.lua) |
| Spawn collection and representative cluster icons | [`QuestieQuest.lua`](source/Modules/Quest/QuestieQuest.lua) |
| Icon hover | [`QuestieFramePool.lua`](source/Modules/FramePool/QuestieFramePool.lua) |
| Icon leave/click | [`QuestieFrame.lua`](source/Modules/FramePool/QuestieFrame.lua) |
| Modified minimap positioning and scaling | [`HereBeDragons-Pins-2.0.lua`](source/Libs/HereBeDragons/HereBeDragons-Pins-2.0.lua) |
| Load order and disabled experiments | [`QuestieDev-master.toc`](source/QuestieDev-master.toc) |

```text
Objective spawn points
  → moving-center clustering
  → interior-point preprocessing
  → Jarvis gift-wrapping convex hull
  → Catmull-Rom spline samples
  → second convex hull
  → point reduction and area cutoff
  → cached outline
  → textured world-map/minimap fills and borders
```

The explanation separates actual behavior from intent. This is not a concave-polygon system, general polygon triangulation, or geometry-aware click-through implementation.

## Linked code and assets

Complete neighboring files preserve context rather than isolated excerpts:

- [Event modules](source/Modules/Event/), [map/waypoint code](source/Modules/NewMap/), and [map helpers](source/Modules/Map/).
- [QuestieLoader](source/Modules/Libs/QuestieLoader.lua), [QuestieLib](source/Modules/Libs/QuestieLib.lua), and [database adapter](source/Database/QuestieDB.lua).
- [Settings](source/Modules/Options/), selected [tracker code](source/Modules/Tracker/), and [frame code](source/Modules/FramePool/).
- [Blizzard reference copies](source/BlizzLibs/) for spline, pools, lines, and MapCanvas. These are historical references, not evidence of current-client API support.
- [Textures, masks, and experimental artwork](source/Icons/), including original `.pdn` files.
- [Tuning notes](source/clusteringChanges!.txt) and [development checklist](source/Checklist.txt).

## Waypoint lines and their outlined texture

The retained waypoint renderer actively uses [`WHITE32X32BLACKLINES.blp`](source/Icons/Raw/Exported/WHITE32X32BLACKLINES.blp). Its [PNG counterpart](source/Icons/Raw/Exported/WHITE32X32BLACKLINES.png) is also preserved: a white middle with black bars above and below. Vertex tint colors the white middle while the edges stay black, producing an outlined line from one texture.

This is separate from blob borders: the active blob renderer uses Blizzard's plain `WHITE8X8`; its black-bordered texture option is commented out.

- [`WaypointFramepool.lua:165`](source/Modules/NewMap/Waypoints/WaypointFramepool.lua#L165) selects the outlined texture.
- [`WaypointPin.lua`](source/Modules/NewMap/Waypoints/WaypointPin.lua) handles line geometry and minimap scale calculations.
- [`AvailableWaypoints.lua:51–89`](source/Modules/Quest/Available/AvailableWaypoints.lua#L51-L89) draws masked minimap lines and registers them with HBD.

The minimap path includes boundary/player masks and modified HBD positioning and zoom handling. These are preserved implementations, not newly runtime-tested behavior. See [the detailed waypoint notes](ANALYSIS.md#waypoint-lines-and-the-black-bordered-texture).

## Experimental references

These are retained for their distinct ideas, **not as competing final implementations**:

- [`source/.throwaway/Polygon.lua`](source/.throwaway/Polygon.lua): alternative hulls, triangle fills, fixed-seed and moving-center clustering, Gaussian mean-shift, and affine texture experiments.
- [`source/.throwaway/Polygonn.lua`](source/.throwaway/Polygonn.lua): another prototype using the `TextureAdd` triangle path.
- [`Affine.lua`](source/Modules/Libs/Affine.lua): inactive affine utility.

The `.throwaway` files were ignored/untracked in the backup repository. They are explicitly included here. Do not load the prototypes alongside the main modules; their module names overlap.

## Provenance and integrity

The unpacked backup's inspected HEAD was `736861e7190b3ce343a5f540f1ad97b734db79e8` on `_classic_version`. This package captures working-tree files, not a claim that every file was tracked or matched HEAD. [MANIFEST.json](MANIFEST.json) records each original path, byte count, and SHA-256; [HISTORY.txt](HISTORY.txt) retains relevant Git metadata.

Full entity data, unrelated addon code, Git objects, archive containers, and the personal discussion in `stepback.txt` are excluded. This is not a complete dependency tree.

Nothing was reformatted, repaired, or wired into the current addon. Package-local Git attributes prevent line-ending conversion, and an ignore exception preserves the library changelog. The files remain under `docs/`, outside the release builder's included directories. No legacy code was executed and no live installation was touched.

Verify from this directory:

```bash
sha256sum --check SHA256SUMS
```

Checksums cover every package file except `SHA256SUMS` itself. Keep raw files unchanged; put revised implementations outside `source/`.

## Licensing

Original notices are retained. [Libs/LICENSE.txt](source/Libs/LICENSE.txt) is context, not asserted to license the entire package. `BlobUtil.lua` includes Nathan Shafer's MIT notice for the Bezier helper; `Affine.lua` has an Unlicense notice. Blizzard references and artwork require separate consideration. This collection assigns no new license and does not establish redistribution rights for every file.
