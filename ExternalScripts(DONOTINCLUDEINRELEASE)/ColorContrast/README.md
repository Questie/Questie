# Objective color contrast

Measures which objective palette colors (`Modules/Quest/ObjectiveColors.lua`) are too faint to see as Questie blobs
in each zone, on the world map and on the minimap. It writes the per-zone bans Questie ships
(`Modules/Quest/ObjectiveColorBans/<Flavor>.lua`), plus review images to check them by eye. Questie uses the bans
when it picks a new objective's color (see `OBJECTIVE-COLOR-PICKING.md` at the repository root).

It lives in `ExternalScripts(DONOTINCLUDEINRELEASE)`, which release builds never package.

## Requirements

- `uv`, plus Lua 5.1 for the tests.
- `~/projects/wow-lua-emulator` with its assets prepared (its README's "Prepare assets" step): zone world rects,
  explored map art, exploration overlay tiles and minimap tiles.
- `~/projects/QuestieWorldMap/map-text/downloads/db2/<build>/`: the UiMapXMapArt, WorldMapOverlay and AreaTable
  tables.

`QUESTIE_EMULATOR` and `QUESTIE_MAP_TEXT` point the tool elsewhere. Each client the tool knows is a **flavor** in
`sources.py` (`FLAVORS`); today that's `forever`.

## Everyday commands

Run them from this folder (`cd "ExternalScripts(DONOTINCLUDEINRELEASE)/ColorContrast"`). The scripts find the
repository from their own path, so the folder is only for short commands.

```sh
uv run colorcontrast.py                    # analyze every zone; review output/forever/
uv run colorcontrast.py --zones 1426 1413  # just these zones, for quick tuning
uv run colorcontrast.py --write-addon      # full run that also writes the shipped data
uv run --no-project --with numpy --with pillow --with pytest python -m pytest tests
```

`--write-addon` refuses any run that would ship partial or unchecked data:

- a subset run (`--zones`), which would drop every other zone's bans;
- uncalibrated scores (no `calibration.json`, or `--fill-min`);
- zones the client has but whose art was never prepared (the run lists them);
- overlay tiles missing for a zone, which leaves part of its ground unmeasured.

After writing the file, run Questie's tests: `ObjectiveColors.test.lua` checks the shipped data against the
palette.

## Workflows

### New zones in a client

1. Prepare the new zones' assets in wow-lua-emulator (map tiles, overlays, explored maps, minimap tiles) and
   recapture the flavor's zone rects from the live client (`maps_json` in `FLAVORS`; Forever's is
   `data/maps-forever-1.60.1.json`). The tool picks up every outdoor zone (UiMap type 3) that has explored art,
   and names the ones that still lack it.
2. Run `colorcontrast.py` and review the new zones' sheets in `output/<flavor>/zones/`.
3. Settle disagreements in `overrides.csv` (see below), if any.
4. Run `colorcontrast.py --write-addon`, then Questie's tests.

The calibration doesn't need redoing for new zones: it describes the eye, not the zones. If the new zones bring a
kind of ground the ratings never covered (say, the first lava zone), add a rating round from them (see
Calibration).

### Retiring or restoring a palette color

1. Comment the entry out in `ObjectiveColors.lua`'s `PALETTE`, or back in. Removing an entry renumbers the
   colors after it. Saved colors hold indexes, so once saved colors have shipped, this needs a migration per
   character.
2. Update the pinned palette in `ObjectiveColors.test.lua`.
3. Remove `overrides.csv` rows that name a retired color; the run stops on them.
4. Run `colorcontrast.py --write-addon`. Until then, Questie ignores the stale bans (they name the palette they
   were measured against, and Questie warns once), and `ObjectiveColors.test.lua` fails.

`banned.lua` in the output starts with how many zones ban each color. It's the number to watch for retirement;
the tool never retires anything itself.

### Calibration: fitting the score to the eye

```sh
uv run calibration.py prepare --add [--flavor forever] [--skip-colors 2,5]
uv run calibration.py serve        # rate at http://localhost:8765
uv run calibration.py fit          # writes calibration.json
uv run calibration.py cells        # draw the cells' pictures (serve and fit do it when they're missing)
```

- **prepare --add** appends a round of about 50 rating cells (three per color) to the session in `ratings/`,
  keeping every earlier rating.
  - Each color gets three cells, aimed at 0.85×, 1× and 1.25× the fitted faint threshold, where bans are decided.
  - Cells come from the flavor's least-used zones and never repeat an earlier cell.
  - `--skip-colors` leaves out colors being retired. Indexes refer to the current palette.
  - `prepare` without `--add` starts a new session from Forever's zones, and only with `--force`, which discards
    the ratings.
- **serve** shows one cell at a time at in-game pixel size, with no scores or color names, in shuffled order.
  Press **1** for clear, **2** for hard but works, **3** for too faint, and Backspace to go back. Every keypress
  is saved, so you can stop and resume. Eight cells per round come back a second time to measure consistency.
- **fit** fits the score weights and per-view thresholds to every rating, in about two minutes.
  - It reports agreement with your ratings, on held-out cells too, and how consistent the repeats were.
  - `output/calibration-misfits.jpg` shows the cells it rates differently from you.
  - Then rerun `colorcontrast.py --write-addon`.

So far, held-out agreement (75%) sits close to the raters' own repeat consistency (81%). Extra model terms
(texture masking, ground lightness, hue direction, lightening vs darkening, the border, per-color factors) all
fitted to nothing. Per-color oddities belong in overrides, not in more parameters.

**The session is kept in git as data, not pictures:**

| File | Holds |
| --- | --- |
| `ratings/manifest.json` | every cell: zone, view, exact map position, color, round |
| `ratings/shifts-round<N>.npz` | every cell's rated pixels: the fill's OKLab shift on a sample of its ground. A new round writes a new file. |
| `ratings/judgments.jsonl` | every keypress; the latest rating of a cell wins |

`fit` reads only those. `ratings/cells/` is ignored: the pictures are drawn from the manifest and the zones' art,
pixel for pixel as they were rated. After a client patch changes the art, a redrawn cell shows the new art, while
the fit keeps scoring the pixels that were rated.

### Adding a flavor (MoP is next)

Measuring MoP covers nearly every zone Era, TBC, WotLK and Cata players see. Steps:

1. Prepare the client's assets with wow-lua-emulator's tools from its own build. The minimap needs every
   continent the zones sit on (Eastern Kingdoms, Kalimdor, Outland, Northrend, Pandaria and so on), so extend
   `CONTINENTS` in `fetch_minimaps.py`. Fetch its db2 tables too.
2. Add a `Flavor` to `FLAVORS` in `sources.py`: its key, the data file name, the TOC that loads it, and the asset
   paths.
3. Run `colorcontrast.py --flavor mists`, review the sheets, and consider a rating round
   (`prepare --add --flavor mists`) for ground the ratings never covered.
4. Run `--write-addon` and list the new data file in the TOCs it applies to, after `ObjectiveColors.lua`.
   - A TOC may load several data files, and their bans combine.
   - UiMapIds differ between clients: Cata and MoP renumbered the revamped zones, and TBC Classic numbers Outland
     differently. A data file only helps a client that uses the same UiMapIds and similar art, so check before
     listing it.

## How a color gets banned

For each zone and each view (world map, minimap):

1. **Terrains.** The tool clusters the ground's pixels by color (k-means in OKLab). Clusters that look alike merge,
   and specks fold into their neighbor, so snow, a lake and an oasis's grass become separate terrains. Each
   terrain is shown where it is densest, with in-game coordinates and the sub-area name.
2. **Scores.** A blob is a fill at 25% opacity with a border at 75%, read from `PolygonMinimap.lua`. A color's
   score on a terrain is how far its fill moves the ground's color: the OKLab difference, × 100, with the axes
   weighted (lightness, red-green, and the blue and yellow halves of blue-yellow), as the median over the
   terrain's pixels.
3. **Levels.** Per view, a score below the *faint* threshold is too faint, and below the *clear* threshold it is
   hard to see but works.
4. **Verdict.** A color is banned in a zone when it is too faint on at least `--max-faint-share` (20%) of the
   zone's ground in either view.
5. **Overrides.** `overrides.csv` (`flavor,ui_map_id,color,verdict,note`, verdict `allow` or `ban`) settles single
   cases by hand. It names colors instead of indexing them, because retiring entries renumbers the rest. If you
   need more than a handful, the model is missing something.

The weights and thresholds come from `calibration.json`. Without it, scores are unweighted and the faint threshold
is 4.5 on both views; `--fill-min` replaces it.

## Outputs (`output/<flavor>/`)

| File | What it is |
| --- | --- |
| `zones/<id>-<name>.jpg` | One column per terrain (map, then minimap) showing its spot, then one row per color with the blob drawn on every spot: **Banned** first, then **Allowed**. Red frame: too faint; amber: hard but works. |
| `overview.png` | Zones × colors. Each cell shows the terrain where the color is faintest, with the fill blended in the middle. Map on top, minimap below; banned cells framed red. |
| `banned.lua` | Review copy of the verdict, with zones banned per color at the top. |
| `scores.csv`, `terrains.csv` | Every score and level, and every terrain with its share, color and spot. |

Every run rewrites these for the zones it analyzed. Sheets of zones a `--zones` run left out stay as they were.
`output/calibration-misfits.jpg` comes from `calibration.py fit`.

## Options (`colorcontrast.py`)

| Option | Default | Effect |
| --- | --- | --- |
| `--flavor` | `forever` | Which client to measure. |
| `--zones` | every zone | UiMapIDs to analyze, for quick tuning. |
| `--write-addon` | off | Also write the shipped data (full, calibrated runs only). |
| `--max-faint-share` | 0.2 | How much of a view's ground a color may be too faint on before it is banned. |
| `--fill-min` | from calibration | Faint threshold for both views, replacing `calibration.json`'s. |
| `--percentile` | 50 | Which percentile of a terrain's pixels gives its score. |
| `--clusters` | 6 | k-means clusters per view before merging. |
| `--merge-distance` | 5 | Clusters closer than this merge (OKLab × 100). |
| `--jobs` | up to 8 | Zones analyzed in parallel. |
| `--out` | `output/<flavor>/` | Where the review outputs go. |

## Files

| File | Role |
| --- | --- |
| `colorcontrast.py` | Terrains, scores, verdicts, and the run itself. |
| `calibration.py`, `rating.html` | Rating rounds, the rating page and the fit. |
| `sources.py` | Flavors and every input: palette, zones, art, sub-areas, minimap. |
| `report.py` | Every output, including the shipped Lua data. |
| `calibration.json` | Fitted weights and thresholds. |
| `overrides.csv` | Hand verdicts. |
| `ratings/` | The rating session as data (see Calibration); `ratings/cells/` holds redrawable pictures and is ignored. |
| `tests/` | The tool's tests. |
