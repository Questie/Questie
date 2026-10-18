# Objective color contrast

Measures which objective palette colors (`Modules/Quest/ObjectiveColors.lua`) are too faint to see as Questie blobs
in each zone, on the world map and on the minimap. It writes the per-zone bans Questie ships
(`Modules/Quest/ObjectiveColorBans/<Flavor>.lua`), plus review images to check them by eye. Questie uses the bans
when it picks a new objective's color (see [`docs/objective-colors.md`](../../docs/objective-colors.md)).

It lives in `ExternalScripts(DONOTINCLUDEINRELEASE)`, which release builds never package.

## Requirements

- `uv`, plus Lua 5.1 for the tests.
- For `fetch.py`:
  - **WSL.** It runs the Windows `CASCConsole.exe` through `wslpath`, and stops at once without it. Porting it
    elsewhere means running CASCConsole another way.
  - **CASCConsole** (from [CASCExplorer](https://github.com/WoW-Tools/CASCExplorer)) and its `listfile.csv` (the
    [community listfile](https://github.com/wowdev/wow-listfile)), in `<WoW folder>/CASC/`. The default folder is
    `/mnt/c/Games/World of Warcraft`; `--wow` or `QUESTIE_WOW` point elsewhere. CASCConsole downloads from
    Blizzard's CDN, so no client needs to be installed or running.
  - Internet access to wago.tools and Blizzard's CDN.

Each client the tool knows is a **flavor** in `sources.py` (`FLAVORS`): its CDN product, the build measured, the
TOCs that load its data, and the outdoor maps it skips on purpose. Each flavor's assets live in their own folder,
`~/.cache/questie-color-contrast/<flavor>-<build>/` (`QUESTIE_COLOR_ASSETS` moves the parent), shared by every
Questie checkout on the machine.

| Flavor | Client | TOC |
| --- | --- | --- |
| `forever` | WoW Forever (`wow_classic_beta`) | `Questie_Camelot.toc` |
| `mists` | MoP Classic (`wow_classic`) | `Questie_Mists.toc` |
| `era` | Classic Era, Season of Discovery, Hardcore (`wow_classic_era`) | `Questie_Vanilla.toc` |
| `tbc` | TBC Anniversary (`wow_anniversary`) | `Questie_TBC.toc` |
| `wrath` | Wrath Classic, Titan (`wow_classic_titan`) | `Questie_Wrath.toc` |
| `cata` | Cata Classic, measured on `mists` | `Questie_Cata.toc` |

**A flavor measured on another** (`measured_on`) ships that flavor's measurements under its own UiMapIds, matched by
AreaID. That's for a client whose art the CDN no longer serves, and only when its map art is the other flavor's,
file for file. Cata Classic is retired, and the CDN serves MoP for its product, but its last tables (4.4.2.60895)
show MoP's art, overlays and world rects on every outdoor map but Kezan. `fetch.py --flavor cata` fetches only its
tables. `colorcontrast.py --flavor cata --write-addon` analyzes MoP's zones and writes `Cata.lua`. It stops on a Cata
map MoP has no counterpart for.

Every client's art differs, down to the file, and UiMapIds differ between clients too (Durotar is 1411 on Forever
and Era but 1 on MoP), so a data file only ever goes in its own client's TOC.

## Fetching a flavor's assets

```sh
uv run fetch.py --flavor mists
```

It downloads, into the flavor's folder:

- the client's map tables of that build from wago.tools (UiMap, UiMapAssignment, UiMapXMapArt, UiMapArtTile,
  WorldMapOverlay, WorldMapOverlayTile, AreaTable, Map);
- every outdoor map's art and exploration overlays, and the art with every overlay blended on (the map a fully
  explored character sees);
- the minimap tiles under every outdoor map, and one tile around it.

Art and tiles come from Blizzard's CDN through CASCConsole. **Outdoor maps** are zones and orphan maps (UiMap types
3 and 6) in the open world, not in dungeons, battlegrounds or scenarios. A map's world rect comes from
UiMapAssignment, as `C_Map.GetWorldPosFromMapPos` computes it: on Forever it matched the live client for all 51
zones. A map with phased art is measured on its default art, or else on its oldest.

A map's **ground** is what its exploration overlays cover. A map without overlays (Gilneas City, the Timeless Isle)
is measured on all its art where the minimap has tiles: nearly all of it, sea and frame included, so its bans err
toward allowing.

The CDN only serves a product's current build. Once it has moved on, `fetch.py` refuses: raise the flavor's
`build` in `sources.py`, fetch again, and rerun the tool. Files already fetched are kept, so an interrupted fetch
continues where it stopped.

## Everyday commands

Run them from this folder (`cd "ExternalScripts(DONOTINCLUDEINRELEASE)/ColorContrast"`). The scripts find the
repository from their own path, so the folder is only for short commands.

```sh
uv run fetch.py --flavor mists                         # download a client's tables, art and minimap tiles, once
uv run colorcontrast.py --flavor mists                 # analyze every zone; review output/mists/
uv run colorcontrast.py --zones 1426 1413              # just these zones (of forever, the default), for tuning
uv run colorcontrast.py --flavor mists --write-addon   # full run that also writes the shipped data
uv run --no-project --with numpy==2.5.4 --with pillow==13.0.0 --with pytest python -m pytest tests
```

After a change every client shares (the palette, the blob opacity, `calibration.json`), regenerate them all:

```sh
for flavor in forever era tbc wrath mists cata; do uv run colorcontrast.py --flavor $flavor --write-addon; done
```

The scripts pin numpy and Pillow: their random draws and resampling decide terrains and cells, so other versions
could shift the shipped bans.

`--write-addon` refuses any run that would ship partial or unchecked data:

- a subset run (`--zones`), which would drop every other zone's bans;
- uncalibrated scores (no `calibration.json`, or `--fill-min`), or terrain settings other than the calibrated
  defaults (`--percentile`, `--clusters`, `--merge-distance`);
- outdoor maps the client has but without explored art, which means `fetch.py` hasn't run for the build. The run
  lists them. `skip_zones` in `FLAVORS` names the maps left out on purpose, each with the reason;
- ground a zone's assets don't cover: overlays without tiles, missing map art tiles, or ground without minimap
  tiles.

The shipped file bans colors by name and records which TOCs load it, each color's sRGB and the blob opacity. After
writing it, run Questie's tests: `ObjectiveColors.test.lua` checks all three against the live TOCs, palette and
`PolygonMinimap.lua`.

## Workflows

### New zones in a client

1. Raise the flavor's `build` in `sources.py` to the client's, and run `fetch.py`. The tool picks up every
   outdoor map it fetched.
2. Run `colorcontrast.py` and review the new zones' sheets in `output/<flavor>/zones/`.
3. Settle disagreements in `overrides.csv` (see below), if any.
4. Run `colorcontrast.py --write-addon`, then Questie's tests.

The calibration doesn't need redoing for new zones: it describes the eye, not the zones. If the new zones bring a
kind of ground the ratings never covered (say, the first lava zone), add a rating round from them (see
Calibration).

### Retiring or restoring a palette color

1. Comment the entry out in `ObjectiveColors.lua`'s `PALETTE`, or back in. Questie saves and bans colors by
   name, so this recolors no other objective. Objectives saved with a retired color get a new one. Renaming a
   color counts as retiring it.
2. Remove `overrides.csv` rows that name a retired color; the run stops on them.
3. Regenerate every flavor's data (see Everyday commands). Until then, the shipped bans of a retired color are
   simply skipped, and `ObjectiveColors.test.lua` fails, because the files' measured colors no longer match the
   palette. The same happens after changing a color's sRGB or the blob opacity.

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
  - A session keeps one cell size and blob opacity, so every cell can be redrawn as it was rated. `--add` refuses
    when either has changed; start a new session then.
  - `prepare` without `--add` starts a new session from Forever's zones, and only with `--force`, which discards
    the ratings.
- **serve** draws every cell's picture anew, then shows one cell at a time at in-game pixel size, with no scores
  or color names, in shuffled order.
  - Press **1** for clear, **2** for hard but works, **3** for too faint, and Backspace to go back.
  - A held key rates nothing, and input waits until a rating is saved and the next picture has loaded.
  - Every keypress is saved, so you can stop and resume.
  - Eight cells per round come back at least 15 cells later, to measure consistency.
  - The server listens on this machine only and takes ratings only from its own page.
- **fit** fits the score weights and per-view thresholds to every rating, in about two minutes.
  - It reports agreement with your ratings, on held-out cells too, and how consistent the repeats were.
  - It warns when a view has no "too faint" rating, since that view's threshold could then ban nothing.
  - It writes `calibration.json` first, then `output/calibration-misfits.jpg` with the cells it rates differently
    from you.
  - Then regenerate every flavor's data (see Everyday commands).

So far, held-out agreement (70%) sits close to the rater's own repeat consistency (79%). Extra model terms
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

### Adding a flavor

1. Add a `Flavor` to `FLAVORS` in `sources.py`: its key, the data file name, its TOC, its CDN product (as the
   launcher's `.build.info` names it) and the build the CDN serves.
2. Run `fetch.py --flavor <key>`, then `colorcontrast.py --flavor <key>`. Put the maps that shouldn't be measured
   into `skip_zones`, each with the reason: capitals, starting areas Questie files under their zone, maps of maps.
3. Review the sheets, and add a rating round (`prepare --add --flavor <key>`) for ground the ratings never covered.
4. Run `--write-addon` and list the new data file in its TOC, after `ObjectiveColors.lua`.
   `ObjectiveColors.test.lua` checks every data file in `ObjectiveColorBans/`: the TOCs it names load it and no
   other TOC does, and its measured colors and opacity match.

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
   cases by hand, by color name like everything else. A color or zone the flavor doesn't have stops the run. If
   you need more than a handful, the model is missing something.

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
| `fetch.py` | Downloads a flavor's map tables, art and minimap tiles. |
| `sources.py` | Flavors and every input: palette, zones, art, sub-areas, minimap. |
| `report.py` | Every output, including the shipped Lua data. |
| `calibration.json` | Fitted weights and thresholds. |
| `overrides.csv` | Hand verdicts. |
| `ratings/` | The rating session as data (see Calibration); `ratings/cells/` holds redrawable pictures and is ignored. |
| `tests/` | The tool's tests. |
