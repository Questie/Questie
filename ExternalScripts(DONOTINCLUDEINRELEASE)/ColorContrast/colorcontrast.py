# /// script
# requires-python = ">=3.11"
# dependencies = ["numpy", "pillow"]
# ///
"""Which objective palette colors are too faint to see as Questie blobs, per zone, on the world map and minimap.

For every outdoor zone, separately for the world map and the minimap:
  1. Terrains: cluster the zone's ground pixels by color (k-means in OKLab), merging near-identical clusters and
     folding specks into their nearest neighbor. An oasis lake or a snow field becomes its own terrain.
  2. Spots: each terrain's spot is where it is densest, for the review sheets and for checking in game.
  3. Scores: for each palette color, how far a blob's fill moves the terrain's color: the OKLab difference between
     the ground with and without the fill, x 100, as a percentile over the terrain's pixels. Each axis is weighted
     (lightness, red-green, and the blue and yellow halves of blue-yellow), because the eye resolves some of them
     worse on small targets. The border's score is reported too but does not decide.
  4. Levels: below the view's faint threshold a color is too faint on a terrain; below its clear threshold it is
     hard to see but works.
  5. Verdict: a color is banned in a zone when it is too faint on at least --max-faint-share of the zone's ground in
     either view. overrides.csv then allows or bans single zone colors by hand.

Weights and thresholds come from calibration.json, fitted to human ratings by calibration.py. They describe the eye,
not a client, so every flavor shares them. Without the file, scores are unweighted and --fill-min is the faint
threshold on both views.

Outputs (in --out, default output/<flavor>/ beside this script; rewritten by every run):
  banned.lua               [uiMapId] = {banned palette indexes}, every analyzed zone listed
  scores.csv               every terrain x color score
  terrains.csv             every terrain with its share, color and spot
  overview.png             zones x colors on each zone's least favorable terrain, banned cells framed red
  zones/<id>-<name>.jpg    per zone: the terrains' spots, then each color as a blob on them, Banned then Allowed
With --write-addon, a full run also writes the flavor's shipped data, Modules/Quest/ObjectiveColorBans/<Name>.lua.

Run from this folder:
  uv run colorcontrast.py [--flavor forever] [--zones 1426 1413] [--write-addon]
"""

from __future__ import annotations

import argparse
import csv
import json
import os
import sys
import time
from concurrent.futures import ProcessPoolExecutor
from dataclasses import dataclass, field
from pathlib import Path

import numpy as np

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import report  # noqa: E402
from sources import (  # noqa: E402
    ART_HEIGHT, ART_WIDTH, FLAVORS, REPO, Flavor, Minimap, PaletteColor, Zone, read_areas, read_blob_opacity,
    read_map_art, read_palette, read_zones, unmeasured_zones,
)

CALIBRATION = HERE / "calibration.json"
OVERRIDES = HERE / "overrides.csv"

VIEWS = ("map", "minimap")
MINIMAP_SCALE = 2  # minimap samples per art pixel along each axis
SPECK_SHARE = 0.005  # terrains smaller than this fold into their nearest neighbor
SAMPLE_PIXELS = 50_000  # per clustering or scoring pass; enough for stable medians, fast for the whole palette
SPOT_RADIUS = 12  # art pixels around a spot that should belong to its terrain

# Rating levels, as in calibration.py's rating page
CLEAR, HARD, FAINT = 1, 2, 3


@dataclass(frozen=True)
class Weights:
    """Per-axis weights of an OKLab shift: lightness, red-green (a), and blue (b < 0) and yellow (b > 0)."""
    lightness: float = 1.0
    red_green: float = 1.0
    blue: float = 1.0
    yellow: float = 1.0


@dataclass(frozen=True)
class Settings:
    weights: Weights
    faint: dict[str, float]  # per view: a score below this is too faint
    clear: dict[str, float | None]  # per view: a score below this is hard but works; None when uncalibrated
    max_faint_share: float  # banned once too faint on this much of a view's ground
    percentile: float  # a score is this percentile of a terrain's per-pixel distances
    clusters: int  # k-means clusters per view before merging
    merge_distance: float  # clusters closer than this (OKLab x 100) merge

    def level(self, score: float, view: str) -> int:
        if score < self.faint[view]:
            return FAINT
        clear = self.clear[view]
        return HARD if clear is not None and score < clear else CLEAR


@dataclass
class Terrain:
    """One color cluster of a zone's ground in one view."""
    view: str
    rgb: tuple[int, int, int]  # median sRGB of its pixels
    share: float  # of the zone's ground in this view
    spot: tuple[float, float]  # map fractions where it is densest
    place: str  # sub-area at the spot
    scores: dict[int, tuple[float, float]] = field(default_factory=dict)  # palette index -> (fill, border)
    sample: np.ndarray | None = field(default=None, repr=False)  # sRGB pixels for scoring; dropped once scored


@dataclass
class ZoneResult:
    zone: Zone
    terrains: list[Terrain]
    faint_shares: dict[int, dict[str, float]]  # palette index -> view -> share of ground it is too faint on
    banned: set[int]  # after overrides
    overrides: dict[int, tuple[str, str]]  # palette index -> (allow | ban, note)
    missing_overlays: list[str] = field(default_factory=list)  # overlays left out for missing tiles


# Color math

_LMS = np.array([[0.4122214708, 0.5363325363, 0.0514459929],
                 [0.2119034982, 0.6806995451, 0.1073969566],
                 [0.0883024619, 0.2817104295, 0.6299870776]], np.float32)
_LAB = np.array([[0.2104542553, 0.7936177850, -0.0040720468],
                 [1.9779984951, -2.4285922050, 0.4505937099],
                 [0.0259040371, 0.7827717662, -0.8086757660]], np.float32)


def oklab(rgb) -> np.ndarray:
    """OKLab (L runs 0..1) of sRGB 0..255 values along the last axis."""
    c = np.asarray(rgb, np.float32) / 255
    linear = np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)
    return np.cbrt(linear @ _LMS.T) @ _LAB.T


def blob_shifts(ground_rgb: np.ndarray, color_rgb, alpha: float) -> np.ndarray:
    """Per-pixel OKLab shift x 100 (dL, da, db) a blob layer causes. The client blends in sRGB without
    linearizing, so the blend is done on sRGB values."""
    blended = ground_rgb * (1 - alpha) + np.asarray(color_rgb, np.float32) * alpha
    return (oklab(blended) - oklab(ground_rgb)) * 100


def weighted_distance(shifts: np.ndarray, weights: Weights) -> np.ndarray:
    """Length of each shift with its axes weighted; blue and yellow weigh the two directions of db."""
    db = shifts[..., 2] * np.where(shifts[..., 2] < 0, weights.blue, weights.yellow)
    return np.sqrt((shifts[..., 0] * weights.lightness) ** 2 + (shifts[..., 1] * weights.red_green) ** 2 + db ** 2)


def blob_score(ground_rgb: np.ndarray, color_rgb, alpha: float, settings: Settings) -> float:
    shifts = blob_shifts(ground_rgb, color_rgb, alpha)
    return float(np.percentile(weighted_distance(shifts, settings.weights), settings.percentile))


# Terrains

def _kmeans(lab: np.ndarray, k: int, rng: np.random.Generator) -> np.ndarray:
    """Cluster centers of OKLab pixels: k-means++ seeding, then Lloyd iterations."""
    centers = lab[[rng.integers(len(lab))]]
    for _ in range(k - 1):
        nearest = ((lab[:, None] - centers[None]) ** 2).sum(-1).min(1)
        centers = np.vstack([centers, lab[rng.choice(len(lab), p=nearest / nearest.sum())]])
    for _ in range(40):
        labels = ((lab[:, None] - centers[None]) ** 2).sum(-1).argmin(1)
        moved = np.array([lab[labels == i].mean(0) if (labels == i).any() else centers[i] for i in range(k)])
        if np.allclose(moved, centers, atol=1e-5):
            break
        centers = moved
    return centers


def find_terrain_centers(lab: np.ndarray, settings: Settings, rng: np.random.Generator) -> np.ndarray:
    """OKLab centers of a view's terrains, from a sample of its ground pixels."""
    sample = lab[rng.choice(len(lab), min(SAMPLE_PIXELS, len(lab)), replace=False)]
    centers = _kmeans(sample, settings.clusters, rng)

    while len(centers) > 1:
        labels = ((sample[:, None] - centers[None]) ** 2).sum(-1).argmin(1)
        counts = np.bincount(labels, minlength=len(centers))
        distances = np.linalg.norm(centers[:, None] - centers[None], axis=-1) * 100
        np.fill_diagonal(distances, np.inf)

        # Specks fold into their nearest neighbor first, then the closest pair merges if they look alike.
        smallest = counts.argmin()
        if counts[smallest] < SPECK_SHARE * len(sample):
            centers = np.delete(centers, smallest, axis=0)
            continue
        a, b = np.unravel_index(distances.argmin(), distances.shape)
        if distances[a, b] >= settings.merge_distance:
            break
        merged = (centers[a] * counts[a] + centers[b] * counts[b]) / (counts[a] + counts[b])
        centers = np.vstack([np.delete(centers, [a, b], axis=0), merged])
    return centers


def _box_mean(grid: np.ndarray, radius: int) -> np.ndarray:
    """Mean of each (2 * radius + 1)-square window, edges padded with zeros."""
    padded = np.pad(grid.astype(np.float32), radius + 1)
    total = padded.cumsum(0).cumsum(1)
    size = 2 * radius + 1
    window = total[size:, size:] - total[:-size, size:] - total[size:, :-size] + total[:-size, :-size]
    return window[:grid.shape[0], :grid.shape[1]] / size ** 2


def densest_spot(member: np.ndarray, ground: np.ndarray, radius: int) -> tuple[float, float]:
    """Map fractions of the ground pixel whose surroundings belong to the terrain the most."""
    density = np.where(ground, _box_mean(member, radius), -1)
    row, col = np.unravel_index(density.argmax(), density.shape)
    return (col + 0.5) / member.shape[1], (row + 0.5) / member.shape[0]


@dataclass
class Survey:
    """A zone's ground in both views and its terrains, each with a pixel sample."""
    art: np.ndarray
    minimap: Minimap
    terrains: list[Terrain]
    missing_overlays: list[str]  # sub-areas left out because their tiles are missing


def survey_zone(zone: Zone, settings: Settings) -> Survey:
    """Finds the zone's terrains on the world map and the minimap, map terrains first, each largest first."""
    rng = np.random.default_rng(zone.ui_map_id)

    # Ground: both views on the art grid, limited to the zone's sub-areas and, on the minimap, to present tiles.
    art = read_map_art(zone)
    areas, missing_overlays = read_areas(zone)
    inside = np.logical_or.reduce([area.mask for area in areas])
    place_at = np.full(inside.shape, -1)
    for i, area in enumerate(areas):
        place_at[area.mask] = i
    minimap = Minimap(zone)
    minimap_rgb, present = minimap.on_map_grid(zone, MINIMAP_SCALE)
    views = {
        "map": (art, inside, 1),
        "minimap": (minimap_rgb, inside.repeat(MINIMAP_SCALE, 0).repeat(MINIMAP_SCALE, 1) & present, MINIMAP_SCALE),
    }

    terrains = []
    for view, (rgb, ground, scale) in views.items():
        # Assign every ground pixel to its nearest terrain center.
        pixels = rgb[ground].astype(np.float32)
        lab = oklab(pixels)
        centers = find_terrain_centers(lab, settings, rng)
        labels = np.concatenate([((part[:, None] - centers[None]) ** 2).sum(-1).argmin(1)
                                 for part in np.array_split(lab, max(1, len(lab) // 500_000))])
        label_grid = np.full(ground.shape, -1)
        label_grid[ground] = labels

        for i in range(len(centers)):
            member = labels == i
            mx, my = densest_spot(label_grid == i, ground, SPOT_RADIUS * scale)
            place = place_at[min(int(my * ART_HEIGHT), ART_HEIGHT - 1), min(int(mx * ART_WIDTH), ART_WIDTH - 1)]
            terrain_pixels = pixels[member]
            sample = terrain_pixels[rng.choice(len(terrain_pixels), min(SAMPLE_PIXELS, len(terrain_pixels)),
                                               replace=False)]
            terrains.append(Terrain(view, tuple(int(v) for v in np.median(terrain_pixels, 0)), member.mean(),
                                    (mx, my), areas[place].name if place >= 0 else "", sample=sample))
    terrains.sort(key=lambda t: (VIEWS.index(t.view), -t.share))
    return Survey(art, minimap, terrains, missing_overlays)


# Verdict

def faint_shares(terrains: list[Terrain], palette: list[PaletteColor], settings: Settings) -> dict[int, dict[str, float]]:
    """Per color and view, the share of the zone's ground the color is too faint on."""
    shares = {}
    for color in palette:
        shares[color.index] = {view: sum(t.share for t in terrains if t.view == view
                                         and settings.level(t.scores[color.index][0], view) == FAINT)
                               for view in VIEWS}
    return shares


def read_overrides(palette: list[PaletteColor], flavor: Flavor, zone_ids: set[int] | None = None,
                   path: Path = OVERRIDES) -> dict[int, dict[int, tuple[str, str]]]:
    """Hand verdicts for one flavor from overrides.csv: uiMapID -> palette index -> (allow | ban, note). Rows name
    their flavor, since flavors number zones differently, and name colors rather than indexing them, because
    retiring palette entries renumbers the rest. A color or zone (when zone_ids is given) the flavor does not have
    fails loudly, since it would otherwise override nothing."""
    if not path.exists():
        return {}
    index_of = {color.name: color.index for color in palette}
    overrides: dict[int, dict[int, tuple[str, str]]] = {}
    with path.open(newline="", encoding="utf-8") as handle:
        for row in csv.DictReader(handle):
            if row["flavor"] != flavor.key:
                continue
            verdict = row["verdict"].strip().lower()
            if verdict not in ("allow", "ban"):
                raise SystemExit(f"overrides.csv: verdict must be allow or ban, not {row['verdict']!r}")
            if row["color"] not in index_of:
                raise SystemExit(f"overrides.csv: {row['color']!r} is not in the palette (retired or misspelled)")
            if zone_ids is not None and int(row["ui_map_id"]) not in zone_ids:
                raise SystemExit(f"overrides.csv: {flavor.name} has no measured zone {row['ui_map_id']}")
            overrides.setdefault(int(row["ui_map_id"]), {})[index_of[row["color"]]] = (verdict, row["note"])
    return overrides


# Zone pipeline

def analyze_zone(zone: Zone, palette: list[PaletteColor], opacity: tuple[float, float], settings: Settings,
                 overrides: dict[int, tuple[str, str]], out: Path) -> ZoneResult:
    """Terrains, scores and verdict for one zone; also renders its review sheet."""
    fill_alpha, border_alpha = opacity
    survey = survey_zone(zone, settings)
    for terrain in survey.terrains:
        for color in palette:
            terrain.scores[color.index] = (blob_score(terrain.sample, color.rgb, fill_alpha, settings),
                                           blob_score(terrain.sample, color.rgb, border_alpha, settings))
        terrain.sample = None  # results cross back to the main process; samples would weigh hundreds of MB

    # A color is banned once it is too faint on enough of either view's ground, unless an override says otherwise.
    shares = faint_shares(survey.terrains, palette, settings)
    banned = {index for index, by_view in shares.items() if max(by_view.values()) >= settings.max_faint_share}
    for index, (verdict, _) in overrides.items():
        if verdict == "allow":
            banned.discard(index)
        else:
            banned.add(index)

    result = ZoneResult(zone, survey.terrains, shares, banned, overrides, survey.missing_overlays)
    report.render_zone_sheet(result, survey.art, survey.minimap, palette, opacity, settings, out / "zones")
    return result


def load_settings(fill_min: float | None, max_faint_share: float, percentile: float, clusters: int,
                  merge_distance: float) -> Settings:
    """Weights and thresholds from calibration.json when it exists, else unweighted scores with a faint threshold
    of 4.5 on both views. An explicit fill_min replaces the faint thresholds either way."""
    weights, faint, clear = Weights(), {view: 4.5 for view in VIEWS}, {view: None for view in VIEWS}
    if CALIBRATION.exists():
        calibration = json.loads(CALIBRATION.read_text(encoding="utf-8"))
        weights = Weights(**calibration["weights"])
        faint = {view: calibration["thresholds"][view]["faint"] for view in VIEWS}
        clear = {view: calibration["thresholds"][view]["clear"] for view in VIEWS}
    if fill_min is not None:
        faint = {view: fill_min for view in VIEWS}
    return Settings(weights, faint, clear, max_faint_share, percentile, clusters, merge_distance)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--flavor", choices=sorted(FLAVORS), default="forever", help="client to measure")
    parser.add_argument("--zones", type=int, nargs="*", help="uiMapIDs to analyze (default: every outdoor zone)")
    parser.add_argument("--write-addon", action="store_true",
                        help="also write the flavor's shipped ban data (full runs only)")
    parser.add_argument("--fill-min", type=float, help="faint threshold for both views, replacing calibration.json")
    parser.add_argument("--max-faint-share", type=float, default=0.2,
                        help="ban once too faint on this share of a view's ground (default 0.2)")
    parser.add_argument("--percentile", type=float, default=50, help="score percentile of a terrain's pixels")
    parser.add_argument("--clusters", type=int, default=6, help="k-means clusters per view before merging")
    parser.add_argument("--merge-distance", type=float, default=5, help="merge clusters closer than this")
    parser.add_argument("--jobs", type=int, default=min(8, os.cpu_count() or 1))
    parser.add_argument("--out", type=Path, help="output folder (default: output/<flavor>/ beside this script)")
    args = parser.parse_args()
    if args.write_addon:
        # Shipped data must come from a full, calibrated run: a subset would drop the other zones' bans, and
        # uncalibrated scores were never checked against the eye.
        if args.zones:
            raise SystemExit("--write-addon needs a full run; leave out --zones")
        if args.fill_min is not None or not CALIBRATION.exists():
            raise SystemExit("--write-addon needs calibrated scores: calibration.json, and no --fill-min")

    flavor = FLAVORS[args.flavor]
    out = args.out or HERE / "output" / flavor.key
    settings = load_settings(args.fill_min, args.max_faint_share, args.percentile, args.clusters,
                             args.merge_distance)
    palette, opacity = read_palette(), read_blob_opacity()
    all_zones = read_zones(flavor)
    zones = [zone for zone in all_zones if not args.zones or zone.ui_map_id in args.zones]
    if not zones:
        raise SystemExit(f"no {flavor.name} zones to analyze; are its assets prepared? ({flavor.explored_maps})")
    overrides = read_overrides(palette, flavor, {zone.ui_map_id for zone in all_zones})

    # Zones the client has but the assets lack would silently fall out of the shipped data.
    unmeasured = ", ".join(f"{name} ({ui_map_id})" for ui_map_id, name in unmeasured_zones(flavor))
    if unmeasured and args.write_addon:
        raise SystemExit(f"{flavor.name} zones without prepared art: {unmeasured}; prepare their assets first")
    if unmeasured:
        print(f"note: skipping {flavor.name} zones without prepared art: {unmeasured}")
    (out / "zones").mkdir(parents=True, exist_ok=True)

    started = time.monotonic()
    with ProcessPoolExecutor(max_workers=args.jobs) as pool:
        futures = [pool.submit(analyze_zone, zone, palette, opacity, settings, overrides.get(zone.ui_map_id, {}),
                               out) for zone in zones]
        results = [future.result() for future in futures]

    report.write_banned_lua(results, palette, settings, out / "banned.lua")
    report.write_csvs(results, palette, settings, out)
    report.render_overview(results, palette, opacity, settings, out / "overview.png")
    source = "calibration.json" if CALIBRATION.exists() and args.fill_min is None else "unweighted"
    banned = sum(len(result.banned) for result in results)
    print(f"{flavor.name}: {len(results)} zones, {banned} bans ({source}), {time.monotonic() - started:.0f}s -> {out}")

    missing = "; ".join(f"{r.zone.name} overlays {', '.join(r.missing_overlays)}" for r in results if r.missing_overlays)
    if missing and args.write_addon:
        raise SystemExit(f"overlay tiles missing, so part of the ground went unmeasured ({missing}); not writing")
    if missing:
        print(f"note: overlay tiles missing, so part of the ground went unmeasured ({missing})")

    if args.write_addon:
        report.write_addon_bans(results, palette, settings, flavor)
        print(f"wrote {flavor.data_file.relative_to(REPO)}")
        listed = flavor.data_file.relative_to(REPO).as_posix().replace("/", "\\")
        toc = (REPO / flavor.toc).read_text(encoding="utf-8").splitlines()
        if listed not in toc:
            print(f"note: {flavor.toc} does not load {listed} yet; add it after Modules\\Quest\\ObjectiveColors.lua")


if __name__ == "__main__":
    main()
