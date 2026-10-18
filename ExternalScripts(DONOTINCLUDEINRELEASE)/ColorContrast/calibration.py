# /// script
# requires-python = ">=3.11"
# dependencies = ["numpy==2.5.4", "pillow==13.0.0"]  # pinned: random draws and resampling shape the cells
# ///
"""Fits colorcontrast.py's score weights and thresholds to a person's visibility ratings.

  prepare  picks about 50 rating cells (one terrain spot with one color's blob, drawn as on the review sheets)
           from zones with every kind of ground, favoring cells near a verdict where weightings disagree;
           with --add, appends a round of cells around the fitted faint threshold from every zone instead
  serve    a local rating page: one cell at a time, keys 1 clear, 2 hard but works, 3 too faint
  fit      fits per-axis weights and per-view thresholds to the ratings, checks them on held-out ratings, and
           writes calibration.json (read by colorcontrast.py) and output/calibration-misfits.jpg
  cells    draws the cells' pictures from the zones' art (serve and fit draw them all anew themselves)

The page hides scores and color names and shuffles the cells; about 10% come back later, which measures how
consistent the ratings are. A rating judges the ground under the blob's fill in that one cell, so the fit scores
exactly those pixels.

The session lives in ratings/ beside this script and is kept in git as data:
  manifest.json          every cell: its zone, view, exact map position and color
  shifts-round<N>.npz    every cell's rated pixels (the fill's OKLab shift on a sample of its ground), per round
  judgments.jsonl        one line per keypress; the latest rating of a cell wins
The pictures in ratings/cells/ are only a view of those pixels, drawn from the manifest and the zones' art. They are
not kept: after a client patch changes the art, a redrawn cell shows the new art, while the fit keeps the pixels
that were rated.

Run from this folder:
  uv run calibration.py prepare
  uv run calibration.py serve        # then open http://localhost:8765
  uv run calibration.py fit
  uv run calibration.py prepare --add --skip-colors 2,5   # another round, then serve
"""

from __future__ import annotations

import argparse
import itertools
import json
import re
import sys
import time
from collections import Counter
from concurrent.futures import ProcessPoolExecutor
from dataclasses import dataclass
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from types import SimpleNamespace

import numpy as np
from PIL import Image, ImageDraw

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import colorcontrast as cc  # noqa: E402
import report  # noqa: E402
from sources import FLAVORS, Minimap, read_blob_opacity, read_map_art, read_palette, read_zones  # noqa: E402

RATINGS = HERE / "ratings"
PAGE = HERE / "rating.html"

CELL_SIZE = 176  # the minimap's size on a 1080p screen at the default UI scale; the page shows cells 1:1
INTERIOR_SAMPLE = 1500  # rated ground pixels kept per cell; enough for a stable median, fast to refit

# A fresh session's first round: one or two Forever zones per kind of ground, both views each. Later rounds
# (--add) draw from every zone of any flavor.
FIRST_ROUND_FLAVOR = "forever"
ZONES = {
    1426: "snow", 1452: "snow", 1429: "green forest", 1412: "grassland", 1438: "dark forest",
    1431: "dark forest", 1448: "corrupted forest", 1435: "swamp", 1449: "jungle", 1413: "savanna",
    1446: "desert", 1451: "yellow sand", 1418: "red rock", 1411: "red desert",
}
# Cases already judged by eye, to confirm the page reads like the sheets: (uiMapID, view, color, which terrain),
# where "faintest" is the terrain the color scores lowest on, "largest" the zone's largest, and anything else the
# terrain whose spot lies in that sub-area. Anchors whose color has been retired are skipped.
ANCHORS = [
    (1426, "minimap", "Medium Purple", "faintest"),  # Dun Morogh: too faint
    (1426, "minimap", "Medium Purple", "largest"),
    (1426, "minimap", "Persian Green", "Helm's Bed Lake"),  # works
    (1413, "map", "Orange", "largest"),  # the Barrens' parchment: hard but works
]
# Each color gets one cell per target score: near a too-faint verdict, between, and clearly visible. Targets rotate
# across colors so each view sees all three; a color never that faint gets its faintest cells instead.
TARGETS = (3.5, 5.0, 7.0)
# A later round aims at the fitted faint threshold instead (as multiples of it), where bans are decided.
ADDED_ROUND_TARGETS = (0.85, 1.0, 1.25)
REPEATS = 8
REPEAT_GAP = 15  # a repeat comes back at least this many cells after its first showing
# Weightings a cell is scored under: their mean places it, their disagreement breaks ties, since cells the
# weightings disagree on are the ones that tell the weights apart.
VARIANTS = [cc.Weights(), cc.Weights(blue=0.5), cc.Weights(yellow=0.5), cc.Weights(lightness=0.5)]


# Prepare

@dataclass
class Candidate:
    flavor: str
    zone: int
    zone_name: str
    view: str
    terrain: int  # 1-based within its view, as in terrains.csv
    share: float
    place: str
    spot: tuple[float, float]
    crop_key: tuple[int, int]  # (zone, terrain position in the survey)
    color: int
    scores: list[float]  # median weighted shift under each of VARIANTS
    score: float  # what targets are compared with: the VARIANTS' mean, or the fitted weighting in a later round

    @property
    def spread(self) -> float:
        return max(self.scores) - min(self.scores)


def _survey_crops(flavor_and_zone: tuple[str, int]) -> list[tuple[cc.Terrain, Image.Image]]:
    """Every terrain of a zone with its bare rating-size crop; samples dropped to keep the result small."""
    flavor_key, zone_id = flavor_and_zone
    zone = next(z for z in read_zones(FLAVORS[flavor_key]) if z.ui_map_id == zone_id)
    survey = cc.survey_zone(zone, cc.load_settings(None, 0.2, 50, 6, 5))
    crops = []
    for terrain in survey.terrains:
        terrain.sample = None
        crops.append((terrain, report.bare_crop(terrain, zone, survey.art, survey.minimap, CELL_SIZE)))
    return crops


def _interior_ground(crop: Image.Image) -> np.ndarray:
    return np.asarray(crop, np.float32)[report.blob_interior(CELL_SIZE)]


# Cell pictures

def _cell_picture(crop: Image.Image, rgb, opacity: tuple[float, float], size: int = CELL_SIZE) -> Image.Image:
    """A rating cell: the bare crop with the color's blob on it, drawn exactly as the review sheets draw it."""
    blob = report.blob_layer(tuple(rgb), opacity, size)
    return Image.alpha_composite(crop.convert("RGBA"), blob).convert("RGB")


def _draw_zone_cells(job: tuple[str, int, list[dict], tuple[float, float], int]) -> int:
    """Draws one zone's cells from its art and minimap at their saved positions; returns how many."""
    flavor_key, zone_id, cells, opacity, size = job
    zone = next(z for z in read_zones(FLAVORS[flavor_key]) if z.ui_map_id == zone_id)
    art = read_map_art(zone) if any(cell["view"] == "map" for cell in cells) else None
    minimap = Minimap(zone) if any(cell["view"] == "minimap" for cell in cells) else None
    for cell in cells:
        spot = SimpleNamespace(view=cell["view"], spot=tuple(cell["position"]))
        crop = report.bare_crop(spot, zone, art, minimap, size)
        _cell_picture(crop, cell["rgb"], opacity, size).save(RATINGS / "cells" / f"{cell['id']}.png")
    return len(cells)


def draw_cells(manifest: dict, redraw: bool = False) -> int:
    """Draws the session's missing cell pictures (every one with redraw) from the zones' prepared art, at the
    opacity the session was rated at. Returns how many it drew.

    Raises:
        OSError: The zones' prepared art is not there.
    """
    folder = RATINGS / "cells"
    folder.mkdir(parents=True, exist_ok=True)
    by_zone: dict[tuple[str, int], list[dict]] = {}
    for cell in manifest["cells"]:
        if redraw or not (folder / f"{cell['id']}.png").exists():
            by_zone.setdefault((cell["flavor"], cell["ui_map_id"]), []).append(cell)
    if not by_zone:
        return 0
    # The session's own size and opacity, whatever CELL_SIZE and PolygonMinimap say today.
    opacity, size = tuple(manifest["opacity"]), manifest["size"]
    jobs = [(flavor, zone_id, cells, opacity, size) for (flavor, zone_id), cells in by_zone.items()]
    with ProcessPoolExecutor(max_workers=8) as pool:
        return sum(pool.map(_draw_zone_cells, jobs))


def _load_shifts() -> dict[str, np.ndarray]:
    """Every round's rated pixels, by cell id."""
    shifts = {}
    for path in sorted(RATINGS.glob("shifts-round*.npz")):
        with np.load(path) as data:
            shifts.update({key: data[key] for key in data.files})
    return shifts


def _session_keys(manifest: dict) -> tuple[set, Counter]:
    """The cells a session already has, as _pick_cells' taken keys and per-zone counts."""
    taken = {(c["flavor"], c["ui_map_id"], c["view"], c["terrain"], c["color"]) for c in manifest["cells"]}
    used = Counter((c["flavor"], c["ui_map_id"]) for c in manifest["cells"])
    return taken, used


def _pick_cells(candidates: list[Candidate], palette, targets: tuple[float, ...], anchors: list,
                taken_keys: set, used: Counter, skip: set[int], rng: np.random.Generator) -> list[tuple[Candidate, bool]]:
    """Anchors first, then a cell per color (except skipped ones) and target score: the nearest to the target (in
    half-point steps), then from the least used zone, then where the weightings disagree most. Cells already in
    the session are not picked again: taken_keys holds (flavor, zone, view, terrain, color name), names because
    retiring palette entries renumbers the colors, and surveys are seeded per zone, so terrain numbers are stable
    (as long as the survey constants and assets stay; changing them renumbers terrains and can repeat cells).
    used counts cells per (flavor, zone). Returns (candidate, is_anchor) pairs."""
    names = {color.index: color.name for color in palette}
    picks: list[tuple[Candidate, bool]] = []
    for zone, view, color_name, which in anchors:
        pool = [c for c in candidates if (c.zone, c.view, names[c.color]) == (zone, view, color_name)]
        if not pool:
            continue
        if which == "faintest":
            anchor = min(pool, key=lambda c: c.scores[0])
        elif which == "largest":
            anchor = max(pool, key=lambda c: c.share)
        else:
            anchor = next(c for c in pool if c.place == which)
        picks.append((anchor, True))

    used = used + Counter((c.flavor, c.zone) for c, _ in picks)
    for color in palette:
        if color.index in skip:
            continue
        for view, target in zip(("map", "minimap", None), np.roll(targets, color.index)):
            taken = {id(c) for c, _ in picks}
            pool = [c for c in candidates if c.color == color.index and id(c) not in taken
                    and (c.flavor, c.zone, c.view, c.terrain, names[c.color]) not in taken_keys
                    and (view is None or c.view == view)]
            if not pool:
                continue
            best = min(pool, key=lambda c: (round(abs(c.score - target) * 2), used[(c.flavor, c.zone)], -c.spread,
                                            rng.random()))
            picks.append((best, False))
            used[(best.flavor, best.zone)] += 1
    return picks


def prepare(force: bool, add: bool, skip: set[int], flavor_key: str) -> None:
    """A fresh session from Forever's ZONES with the anchors, or with add, one more round appended to the current
    session: cells around the fitted faint threshold from every zone of the flavor, keeping all earlier cells and
    ratings."""
    judgments = RATINGS / "judgments.jsonl"
    palette = read_palette()
    fill_alpha, border_alpha = read_blob_opacity()

    if add:
        if not cc.CALIBRATION.exists():
            raise SystemExit("--add aims at the fitted thresholds; run fit first")
        manifest = json.loads((RATINGS / "manifest.json").read_text(encoding="utf-8"))
        # One opacity and cell size per session, so every cell can be redrawn the way it was rated.
        if manifest["size"] != CELL_SIZE or list(manifest["opacity"]) != [fill_alpha, border_alpha]:
            raise SystemExit(f"the session was rated at cell size {manifest['size']} and blob opacity "
                             f"{manifest['opacity']}; start a new session (--force) to rate at the current ones")
        calibration = json.loads(cc.CALIBRATION.read_text(encoding="utf-8"))
        placing = [cc.Weights(**calibration["weights"])]
        faint = sum(view["faint"] for view in calibration["thresholds"].values()) / 2
        targets = tuple(faint * k for k in ADDED_ROUND_TARGETS)
        zone_ids, anchors = [zone.ui_map_id for zone in read_zones(FLAVORS[flavor_key])], []
    else:
        if judgments.exists() and not force:
            raise SystemExit(f"{judgments} exists; new cells would not match those ratings. "
                             "Pass --add for another round, or --force to start over.")
        if flavor_key != FIRST_ROUND_FLAVOR:
            raise SystemExit(f"a fresh session starts from {FIRST_ROUND_FLAVOR}'s zones; add {flavor_key} with --add")
        manifest = {"created": time.strftime("%Y-%m-%d %H:%M"), "size": CELL_SIZE,
                    "opacity": [fill_alpha, border_alpha], "cells": [], "order": []}
        placing, targets, zone_ids, anchors = VARIANTS, TARGETS, list(ZONES), ANCHORS
    round_number = 1 + max((cell.get("round", 1) for cell in manifest["cells"]), default=0)
    rng = np.random.default_rng(round_number)

    # Terrains and crops of the round's zones
    with ProcessPoolExecutor(max_workers=8) as pool:
        surveys = dict(zip(zone_ids, pool.map(_survey_crops, [(flavor_key, zone_id) for zone_id in zone_ids])))
    names = {z.ui_map_id: z.name for z in read_zones(FLAVORS[flavor_key])}

    # Every terrain x color as a candidate, scored on the ground its blob would cover
    candidates = []
    for zone_id, crops in surveys.items():
        numbers: Counter[str] = Counter()
        for position, (terrain, crop) in enumerate(crops):
            numbers[terrain.view] += 1
            ground = _interior_ground(crop)
            for color in palette:
                shifts = cc.blob_shifts(ground, color.rgb, fill_alpha)
                scores = [float(np.median(cc.weighted_distance(shifts, w))) for w in VARIANTS]
                score = float(np.mean([np.median(cc.weighted_distance(shifts, w)) for w in placing]))
                candidates.append(Candidate(flavor_key, zone_id, names[zone_id], terrain.view,
                                            numbers[terrain.view], terrain.share, terrain.place, terrain.spot,
                                            (zone_id, position), color.index, scores, score))
    taken, used = _session_keys(manifest)
    picks = _pick_cells(candidates, palette, targets, anchors, taken, used, skip, rng)

    # Draw the cells and keep each one's rated pixels; a new session first clears the old session's files.
    (RATINGS / "cells").mkdir(parents=True, exist_ok=True)
    if not add:
        for old in [*(RATINGS / "cells").glob("*.png"), *RATINGS.glob("shifts-round*.npz")]:
            old.unlink()
    colors = {c.index: c for c in palette}
    cells, shifts = [], {}
    for number, (candidate, anchor) in enumerate(picks, len(manifest["cells"]) + 1):
        cell_id = f"c{number:02d}"
        crop = surveys[candidate.crop_key[0]][candidate.crop_key[1]][1]
        rgb = colors[candidate.color].rgb
        _cell_picture(crop, rgb, (fill_alpha, border_alpha)).save(RATINGS / "cells" / f"{cell_id}.png")
        ground = _interior_ground(crop)
        ground = ground[rng.choice(len(ground), min(INTERIOR_SAMPLE, len(ground)), replace=False)]
        shifts[cell_id] = cc.blob_shifts(ground, rgb, fill_alpha).astype(np.float32)
        ground_kind = ZONES.get(candidate.zone, "") if flavor_key == FIRST_ROUND_FLAVOR else ""
        # position is exact, for redrawing the cell; spot is the same place in in-game map coordinates.
        cells.append({"id": cell_id, "round": round_number, "flavor": flavor_key, "ui_map_id": candidate.zone,
                      "zone": candidate.zone_name, "ground": ground_kind, "view": candidate.view,
                      "terrain": candidate.terrain, "share": round(candidate.share, 4), "place": candidate.place,
                      "spot": [round(v * 100, 1) for v in candidate.spot], "position": list(candidate.spot),
                      "color": colors[candidate.color].name, "rgb": list(rgb), "anchor": anchor})
    np.savez_compressed(RATINGS / f"shifts-round{round_number}.npz", **shifts)

    # Shuffled order after earlier rounds; repeats come back at least 15 cells after their first showing
    order = [cell["id"] for cell in cells]
    rng.shuffle(order)
    early = order[:max(0, len(order) - REPEAT_GAP)]
    for cell_id in rng.choice(early, min(REPEATS, len(early)), replace=False):
        first = order.index(cell_id)
        position = int(rng.integers(first + REPEAT_GAP, len(order) + 1))
        order.insert(position, f"{cell_id}r")

    manifest["cells"] += cells
    manifest["order"] += order
    (RATINGS / "manifest.json").write_text(json.dumps(manifest, indent=1), encoding="utf-8")
    if not add:
        judgments.unlink(missing_ok=True)
    print(f"round {round_number}: {len(cells)} cells ({len(order)} ratings with repeats) from {len(candidates)} "
          f"candidates -> {RATINGS}")


# Serve

def _latest_ratings() -> dict[str, int]:
    """Latest rating per presentation key ("c17", or "c17r" for its repeat)."""
    ratings = {}
    path = RATINGS / "judgments.jsonl"
    if path.exists():
        for line in path.read_text(encoding="utf-8").splitlines():
            entry = json.loads(line)
            ratings[entry["key"]] = entry["rating"]
    return ratings


class _RatingHandler(BaseHTTPRequestHandler):
    manifest: dict

    def _send(self, status: int, body: bytes, content_type: str) -> None:
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self) -> None:
        if self.path == "/":
            self._send(200, PAGE.read_bytes(), "text/html; charset=utf-8")
        elif self.path == "/api/session":
            views = {cell["id"]: cell["view"] for cell in self.manifest["cells"]}
            session = {"order": self.manifest["order"], "views": views, "size": self.manifest["size"],
                       "ratings": _latest_ratings()}
            self._send(200, json.dumps(session).encode(), "application/json")
        elif match := re.fullmatch(r"/cells/(c\d+)\.png", self.path):
            path = RATINGS / "cells" / f"{match[1]}.png"
            if path.exists():
                self._send(200, path.read_bytes(), "image/png")
            else:
                self._send(404, b"no such cell", "text/plain")
        else:
            self._send(404, b"not found", "text/plain")

    def _from_own_page(self) -> bool:
        """Whether a request comes from the rating page itself: addressed to this machine, and either without an
        Origin or from this server's own. Keeps other web pages (and DNS rebinding) from posting ratings."""
        host = self.headers.get("Host", "").rsplit(":", 1)[0]
        origin = self.headers.get("Origin")
        own = {f"http://{name}:{self.server.server_port}" for name in ("localhost", "127.0.0.1")}
        return host in ("localhost", "127.0.0.1") and (origin is None or origin in own)

    def do_POST(self) -> None:
        if self.path != "/api/rate":
            self._send(404, b"not found", "text/plain")
            return
        if not self._from_own_page() or self.headers.get("Content-Type") != "application/json":
            self._send(403, b"ratings come from the rating page only", "text/plain")
            return
        body = json.loads(self.rfile.read(int(self.headers["Content-Length"])))
        key, rating = body.get("key"), body.get("rating")
        if key not in self.manifest["order"] or type(rating) is not int or rating not in (1, 2, 3):
            self._send(400, b"bad rating", "text/plain")
            return
        entry = {"key": key, "cell": key.rstrip("r"), "rating": rating, "time": time.strftime("%Y-%m-%dT%H:%M:%S")}
        with (RATINGS / "judgments.jsonl").open("a", encoding="utf-8") as handle:
            handle.write(json.dumps(entry) + "\n")
        self._send(200, b"{}", "application/json")

    def log_message(self, *_args) -> None:  # keep the terminal for the URL and errors
        pass


def serve(port: int) -> None:
    """The rating page on this machine only: the server takes ratings only from its own page, addressed as
    localhost or 127.0.0.1."""
    _RatingHandler.manifest = json.loads((RATINGS / "manifest.json").read_text(encoding="utf-8"))
    # Every picture is drawn anew, so a leftover file from another session can never stand in for a cell.
    try:
        draw_cells(_RatingHandler.manifest, redraw=True)
    except Exception as error:  # noqa: BLE001 - any failure here means the pictures cannot be trusted
        raise SystemExit(f"cannot draw the cells' pictures without the zones' prepared art: {error}")
    server = ThreadingHTTPServer(("127.0.0.1", port), _RatingHandler)
    done = len(_latest_ratings())
    print(f"Rating page: http://localhost:{port}  ({done} of {len(_RatingHandler.manifest['order'])} rated; "
          f"Ctrl+C stops, ratings are saved as you go)")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass


# Fit

@dataclass
class Model:
    weights: cc.Weights
    faint: dict[str, float]
    clear: dict[str, float]

    def level(self, score: float, view: str) -> int:
        return cc.FAINT if score < self.faint[view] else cc.HARD if score < self.clear[view] else cc.CLEAR


def _cell_scores(shifts: np.ndarray, weights: cc.Weights) -> np.ndarray:
    """Each cell's median weighted shift; shifts is (cells, INTERIOR_SAMPLE, 3)."""
    return np.median(cc.weighted_distance(shifts, weights), axis=1)


MISS = 0.05  # loss of a rating on the wrong side of a threshold, before its distance from it


def _side_losses(scores: np.ndarray, below: np.ndarray, thresholds: np.ndarray) -> np.ndarray:
    """Per threshold, the loss of the ratings on its wrong side: each costs MISS plus how far its score lies from
    the threshold (log ratio), so near misses, likely rating noise, weigh little and wide misses much."""
    wrong = (scores[None, :] < thresholds[:, None]) != below[None, :]
    return (wrong * (MISS + np.abs(np.log(scores[None, :] / thresholds[:, None])))).sum(axis=1)


def _fit_thresholds(scores: np.ndarray, ratings: np.ndarray) -> tuple[float, float, float]:
    """Faint and clear thresholds for one view: faint separates too faint from the rest, then clear separates
    hard from clear among the rest. Returns them with their combined loss."""
    edges = np.sort(scores)
    candidates = np.concatenate([[edges[0] * 0.99], (edges[1:] + edges[:-1]) / 2, [edges[-1] * 1.01]])
    faint_losses = _side_losses(scores, ratings == cc.FAINT, candidates)
    faint = float(candidates[faint_losses.argmin()])

    rest = ratings != cc.FAINT
    clear_candidates = candidates[candidates >= faint]
    clear_losses = _side_losses(scores[rest], ratings[rest] == cc.HARD, clear_candidates)
    clear = float(clear_candidates[clear_losses.argmin()])
    return faint, clear, float(faint_losses.min() + clear_losses.min())


GRID = np.round(np.arange(0.2, 1.51, 0.1), 2)  # weights tried for lightness, blue and yellow; red-green stays 1


def _fit(shifts: np.ndarray, views: np.ndarray, ratings: np.ndarray) -> Model:
    """The grid weights and per-view thresholds with the least loss, then the weights nearest 1 (no evidence, no
    reweighting)."""
    best, best_key = None, None
    for lightness, blue, yellow in itertools.product(GRID, GRID, GRID):
        weights = cc.Weights(float(lightness), 1.0, float(blue), float(yellow))
        scores = _cell_scores(shifts, weights)
        faint, clear, loss = {}, {}, 0.0
        for view in ("map", "minimap"):
            mask = views == view
            faint[view], clear[view], view_loss = _fit_thresholds(scores[mask], ratings[mask])
            loss += view_loss
        key = (round(loss, 6), abs(lightness - 1) + abs(blue - 1) + abs(yellow - 1))
        if best_key is None or key < best_key:
            best, best_key = Model(weights, faint, clear), key
    return best


def _misfit_sheet(misfits: list[tuple[str, int, int, float]], path: Path) -> None:
    """The cells the fit rates differently from the person, ban disagreements first."""
    columns, label = 6, 34
    size = CELL_SIZE
    sheet = Image.new("RGB", (columns * (size + 8) + 8, max(1, -(-len(misfits) // columns)) * (size + label + 8) + 8),
                      report.BACKGROUND)
    draw = ImageDraw.Draw(sheet)
    names = {1: "clear", 2: "hard", 3: "faint"}
    for i, (cell_id, rated, predicted, score) in enumerate(misfits):
        x, y = 8 + (i % columns) * (size + 8), 8 + (i // columns) * (size + label + 8)
        sheet.paste(Image.open(RATINGS / "cells" / f"{cell_id}.png"), (x, y))
        accent = report.RED if (rated == cc.FAINT) != (predicted == cc.FAINT) else report.AMBER
        draw.text((x, y + size + 2), f"{cell_id}: you {names[rated]}, fit {names[predicted]}", fill=accent,
                  font=report._font(13))
        draw.text((x, y + size + 18), f"score {score:.2f}", fill=report.DIM, font=report._font(12))
    sheet.save(path, quality=90)


def fit(folds: int) -> None:
    manifest = json.loads((RATINGS / "manifest.json").read_text(encoding="utf-8"))
    cells = {cell["id"]: cell for cell in manifest["cells"]}
    stored = _load_shifts()
    ratings = _latest_ratings()

    # Consistency: each repeat against its first showing
    pairs = [(ratings[key[:-1]], ratings[key]) for key in ratings if key.endswith("r") and key[:-1] in ratings]
    if pairs:
        same = sum(a == b for a, b in pairs)
        same_ban = sum((a == cc.FAINT) == (b == cc.FAINT) for a, b in pairs)
        print(f"repeats: {same}/{len(pairs)} rated the same, {same_ban}/{len(pairs)} the same on too faint or not")

    # Observations: every rating, repeats included, against its cell's pixels
    keys = sorted(ratings)
    shifts = np.stack([stored[key.rstrip("r")] for key in keys])
    views = np.array([cells[key.rstrip("r")]["view"] for key in keys])
    rated = np.array([ratings[key] for key in keys])
    if len(set(views)) < 2:
        raise SystemExit("ratings must cover both views before fitting")
    for view in ("map", "minimap"):
        if not np.any(rated[views == view] == cc.FAINT):
            print(f"warning: no {view} cell was rated too faint, so the {view} faint threshold bans nothing; "
                  f"add a round with fainter {view} cells")
    print(f"fitting {len(keys)} ratings over {len(GRID) ** 3} weightings ...")
    model = _fit(shifts, views, rated)

    # Held-out check: refit without each fold of cells (a repeat stays with its cell) and predict that fold.
    cell_ids = sorted({key.rstrip("r") for key in keys})
    fold_of = {cell_id: i % folds for i, cell_id in enumerate(np.random.default_rng(2).permutation(cell_ids))}
    held_right = 0
    for fold in range(folds):
        test = np.array([fold_of[key.rstrip("r")] == fold for key in keys])
        part = _fit(shifts[~test], views[~test], rated[~test])
        scores = _cell_scores(shifts[test], part.weights)
        predicted = np.array([part.level(s, v) for s, v in zip(scores, views[test])])
        held_right += int(np.sum((predicted == cc.FAINT) == (rated[test] == cc.FAINT)))

    # Agreement of the full fit, and the cells it gets wrong
    scores = _cell_scores(shifts, model.weights)
    predicted = np.array([model.level(s, v) for s, v in zip(scores, views)])
    ban_right = int(np.sum((predicted == cc.FAINT) == (rated == cc.FAINT)))
    w = model.weights
    print(f"weights: lightness {w.lightness:g}, red-green 1, blue {w.blue:g}, yellow {w.yellow:g}")
    for view in ("map", "minimap"):
        print(f"{view}: faint below {model.faint[view]:.2f}, clear from {model.clear[view]:.2f}")
    print(f"too faint or not: {ban_right}/{len(keys)} agree; held out ({folds} folds): {held_right}/{len(keys)}")
    print(f"exact level: {int(np.sum(predicted == rated))}/{len(keys)}")
    print("you (rows) vs fit (columns), 1 clear 2 hard 3 faint:")
    for level in (1, 2, 3):
        print(f"  {level}: " + "  ".join(f"{int(np.sum((rated == level) & (predicted == p))):3d}" for p in (1, 2, 3)))

    misfits = [(key.rstrip("r"), int(r), int(p), float(s)) for key, r, p, s in zip(keys, rated, predicted, scores)
               if r != p]
    misfits.sort(key=lambda m: ((m[1] == cc.FAINT) == (m[2] == cc.FAINT), m[0]))
    calibration = {
        "weights": {"lightness": w.lightness, "red_green": 1.0, "blue": w.blue, "yellow": w.yellow},
        "thresholds": {view: {"faint": round(model.faint[view], 3), "clear": round(model.clear[view], 3)}
                       for view in ("map", "minimap")},
        "fit": {"ratings": len(keys), "too_faint_agreement": ban_right, "held_out_too_faint_agreement": held_right,
                "exact_level_agreement": int(np.sum(predicted == rated)), "repeats_same": sum(a == b for a, b in pairs),
                "repeats": len(pairs), "date": time.strftime("%Y-%m-%d")},
    }
    cc.CALIBRATION.write_text(json.dumps(calibration, indent=2) + "\n", encoding="utf-8")
    print(f"wrote {cc.CALIBRATION.name}")

    # The misfit sheet comes last: the fit needs no pictures, and drawing them needs the zones' art.
    (HERE / "output").mkdir(exist_ok=True)
    try:
        draw_cells(manifest, redraw=True)
        _misfit_sheet(misfits, HERE / "output" / "calibration-misfits.jpg")
        print(f"wrote output/calibration-misfits.jpg ({len(misfits)} misfits)")
    except Exception as error:  # noqa: BLE001 - the calibration is already written
        print(f"note: no misfit sheet, the cells' pictures cannot be drawn: {error}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    commands = parser.add_subparsers(dest="command", required=True)
    prepare_parser = commands.add_parser("prepare")
    prepare_parser.add_argument("--add", action="store_true", help="add a round aimed at the fitted thresholds")
    prepare_parser.add_argument("--flavor", choices=sorted(FLAVORS), default=FIRST_ROUND_FLAVOR,
                                help="client whose zones an added round draws from")
    prepare_parser.add_argument("--skip-colors", default="", help="palette indexes to leave out, such as 2,5,10")
    prepare_parser.add_argument("--force", action="store_true", help="discard existing ratings and start over")
    serve_parser = commands.add_parser("serve")
    serve_parser.add_argument("--port", type=int, default=8765)
    commands.add_parser("fit").add_argument("--folds", type=int, default=5)
    commands.add_parser("cells").add_argument("--redraw", action="store_true",
                                              help="draw every cell again, not only the missing ones")
    args = parser.parse_args()
    if args.command == "prepare":
        prepare(args.force, args.add, {int(i) for i in args.skip_colors.split(",") if i}, args.flavor)
    elif args.command == "serve":
        serve(args.port)
    elif args.command == "cells":
        manifest = json.loads((RATINGS / "manifest.json").read_text(encoding="utf-8"))
        print(f"drew {draw_cells(manifest, args.redraw)} of {len(manifest['cells'])} cell pictures -> {RATINGS / 'cells'}")
    else:
        fit(args.folds)


if __name__ == "__main__":
    main()
