"""Inputs for the color contrast tool: the objective palette, the client flavors it measures, and each zone's map art,
sub-areas and minimap.

Everything is read in place and never modified:
  * Questie: the objective palette (Modules/Quest/ObjectiveColors.lua) and blob opacities
    (Modules/Map/Polygon/PolygonMinimap.lua), so a change there carries over on the next run.
  * Per flavor, from wow-lua-emulator: zone world rects (captured from the live client), explored map art, exploration
    overlay tiles and minimap tiles. Its README's "Prepare assets" step makes them.
  * Per flavor, from QuestieWorldMap's map-text downloads: the UiMapXMapArt, WorldMapOverlay and AreaTable db2 tables.

QUESTIE_EMULATOR and QUESTIE_MAP_TEXT override where those two projects live.

Coordinates:
  * Map fractions (mx, my) run 0..1 east and south across a zone's map art, like C_Map positions.
  * World x grows north and world y grows west, in yards, like C_Map.GetWorldPosFromMapPos.
  * Minimap tiles are 533 1/3 yards on a side, 64 x 64 per continent, world (0, 0) at the corner of tile 32_32;
    tile x grows east and tile y south.
"""

from __future__ import annotations

import csv
import json
import math
import os
import re
from dataclasses import dataclass
from functools import cache
from pathlib import Path

import numpy as np
from PIL import Image

REPO = Path(__file__).resolve().parents[2]
EMULATOR = Path(os.environ.get("QUESTIE_EMULATOR", Path.home() / "projects/wow-lua-emulator"))
MAP_TEXT = Path(os.environ.get("QUESTIE_MAP_TEXT", Path.home() / "projects/QuestieWorldMap/map-text"))

ART_WIDTH, ART_HEIGHT = 1002, 668  # every zone's map art layer, in art pixels
ART_TILE = 256
TILE_YARDS = 1600 / 3


# Flavors

@dataclass(frozen=True)
class Flavor:
    """One client whose zones the tool measures, and where its ban data goes in Questie. Every path is the flavor's
    own: clients share continent IDs (0 and 1) but not their art, so two flavors must never share an asset folder."""
    key: str  # --flavor value and output folder
    name: str  # data file name, Modules/Quest/ObjectiveColorBans/<name>.lua
    tocs: tuple[str, ...]  # the TOCs that load the data file: only clients with the same UiMapIds and art
    maps_json: Path  # every uiMap's world rect and art (emulator tools/bridge/dump_maps.lua, live client)
    explored_maps: Path  # <uiMapID>/r<row>c<col>.png, art with every overlay blended on (compose_explored_maps.py)
    overlay_tiles: Path  # <uiMapID>/o<overlayID>-r<row>c<col>.png (prepare_assets.py)
    minimap_tiles: Path  # <instanceID>/<x>_<y>.jpg (fetch_minimaps.py)
    db2: Path  # UiMapXMapArt.csv, WorldMapOverlay.csv, AreaTable-enUS.csv of the client's build
    skip_zones: tuple[tuple[int, str], ...] = ()  # outdoor maps not measured on purpose, with the reason

    @property
    def data_file(self) -> Path:
        return REPO / "Modules/Quest/ObjectiveColorBans" / f"{self.name}.lua"


_CAPITAL = "capital: no exploration overlays, and its minimap is drawn indoors"
FLAVORS = {
    "forever": Flavor(
        key="forever", name="Forever", tocs=("Questie_Camelot.toc",),
        maps_json=EMULATOR / "data/maps-forever-1.60.1.json",
        explored_maps=EMULATOR / "assets/explored/maps",
        overlay_tiles=EMULATOR / "assets/generated/maps",
        minimap_tiles=EMULATOR / "assets/generated/minimaps",
        db2=MAP_TEXT / "downloads/db2/1.60.1.70338",
        skip_zones=((1453, _CAPITAL), (1454, _CAPITAL), (1455, _CAPITAL), (1456, _CAPITAL), (1457, _CAPITAL),
                    (1458, _CAPITAL), (2665, "a second Zephras Isle map without overlays; 2521 is measured")),
    ),
}


# Questie

@dataclass(frozen=True)
class PaletteColor:
    index: int  # 1-based position in the palette; Questie saves and bans colors by name, not by this
    name: str
    rgb: tuple[int, int, int]  # sRGB 0..255


def read_palette(path: Path = REPO / "Modules/Quest/ObjectiveColors.lua") -> list[PaletteColor]:
    """The objective palette in ObjectiveColors' order. Commented-out (retired) entries are not part of it."""
    source = path.read_text(encoding="utf-8")
    block = re.search(r"^local PALETTE = \{\n(.*?)\n\}", source, re.S | re.M)
    entries = re.findall(r'^\s*\{(\d+), (\d+), (\d+), "([^"]+)"\},', block.group(1), re.M)
    return [PaletteColor(i, name, (int(r), int(g), int(b))) for i, (r, g, b, name) in enumerate(entries, 1)]


def read_named_colors(path: Path = REPO / "Modules/Quest/ObjectiveColors.lua") -> dict[str, tuple[int, int, int]]:
    """Every palette color by name, retired (commented-out) ones included, for redrawing old rating cells."""
    source = path.read_text(encoding="utf-8")
    block = re.search(r"^local PALETTE = \{\n(.*?)\n\}", source, re.S | re.M)
    entries = re.findall(r'^\s*(?:-- )?\{(\d+), (\d+), (\d+), "([^"]+)"\},', block.group(1), re.M)
    return {name: (int(r), int(g), int(b)) for r, g, b, name in entries}


def read_blob_opacity() -> tuple[float, float]:
    """Fill and border opacity of an area at full marker opacity; the world map draws the same."""
    source = (REPO / "Modules/Map/Polygon/PolygonMinimap.lua").read_text(encoding="utf-8")
    fill, border = re.search(r"local FILL_ALPHA, BORDER_ALPHA = ([\d.]+), ([\d.]+)", source).groups()
    return float(fill), float(border)


# Zones and their map art

@dataclass(frozen=True)
class Zone:
    flavor: Flavor
    ui_map_id: int
    name: str
    continent: int  # instance ID, the folder of its minimap tiles
    x0: float  # world position of the map's top-left corner (C_Map.GetWorldPosFromMapPos at 0, 0)
    y0: float
    x1: float  # and of its bottom-right corner (at 1, 1)
    y1: float

    def world_position(self, mx, my):
        """World x and y for map fractions; takes numpy arrays too."""
        return self.x0 + (self.x1 - self.x0) * my, self.y0 + (self.y1 - self.y0) * mx


def read_zones(flavor: Flavor) -> list[Zone]:
    """The flavor's outdoor zones (UiMap type 3) with explored map art. Capitals have no exploration overlays and
    their minimap is drawn indoors, so they are left out; a new zone is picked up once its art is prepared."""
    data = json.loads(flavor.maps_json.read_text(encoding="utf-8"))
    zones = [Zone(flavor, m["id"], m["name"], m["continent"], m["x0"], m["y0"], m["x1"], m["y1"])
             for m in data["maps"].values()
             if m["type"] == 3 and (flavor.explored_maps / str(m["id"])).is_dir()]
    return sorted(zones, key=lambda zone: zone.ui_map_id)


def unmeasured_zones(flavor: Flavor) -> list[tuple[int, str]]:
    """Outdoor zones the client has but the tool cannot measure: no explored art was prepared for them, and the
    flavor does not skip them on purpose. A non-empty list means the assets are behind the client. This reads the
    client's own map list, not its db2 tables, so a db2 folder older than the client cannot hide a new zone."""
    data = json.loads(flavor.maps_json.read_text(encoding="utf-8"))
    skipped = {ui_map_id for ui_map_id, _ in flavor.skip_zones}
    return sorted((m["id"], m["name"]) for m in data["maps"].values()
                  if m["type"] == 3 and m["id"] not in skipped and not (flavor.explored_maps / str(m["id"])).is_dir())


ART_TILES = math.ceil(ART_WIDTH / ART_TILE) * math.ceil(ART_HEIGHT / ART_TILE)  # tiles a zone's art needs


def map_art_tiles(zone: Zone) -> int:
    """How many of the zone's ART_TILES explored art tiles were prepared; missing ones read as black ground."""
    return len(list((zone.flavor.explored_maps / str(zone.ui_map_id)).glob("r*c*.png")))


def read_map_art(zone: Zone) -> np.ndarray:
    """The zone's world map as a fully explored character sees it: (ART_HEIGHT, ART_WIDTH, 3) sRGB uint8."""
    art = Image.new("RGB", (4 * ART_TILE, 3 * ART_TILE))
    for path in (zone.flavor.explored_maps / str(zone.ui_map_id)).glob("r*c*.png"):
        row, col = map(int, re.fullmatch(r"r(\d+)c(\d+)", path.stem).groups())
        with Image.open(path) as tile:
            art.paste(tile.convert("RGB"), (col * ART_TILE, row * ART_TILE))
    return np.asarray(art)[:ART_HEIGHT, :ART_WIDTH]


# Sub-areas (exploration overlays)

@dataclass
class Area:
    name: str
    mask: np.ndarray  # bool (ART_HEIGHT, ART_WIDTH)


@cache
def _db2(folder: Path, table: str) -> list[dict[str, str]]:
    with (folder / f"{table}.csv").open(newline="", encoding="utf-8") as handle:
        return list(csv.DictReader(handle))


def _overlay_alpha(folder: Path, overlay: dict[str, str]) -> np.ndarray | None:
    """One overlay's alpha as a (TextureHeight, TextureWidth) array, or None when a tile is missing. The last
    column and row are power-of-two files the client draws only the top-left part of."""
    width, height = int(overlay["TextureWidth"]), int(overlay["TextureHeight"])
    alpha = np.zeros((height, width), np.uint8)
    for row in range(math.ceil(height / ART_TILE)):
        for col in range(math.ceil(width / ART_TILE)):
            path = folder / f"o{overlay['ID']}-r{row}c{col}.png"
            if not path.exists():
                return None
            with Image.open(path) as tile:
                part = np.asarray(tile.convert("RGBA"))[:, :, 3]
            top, left = row * ART_TILE, col * ART_TILE
            h, w = min(ART_TILE, height - top), min(ART_TILE, width - left)
            alpha[top:top + h, left:left + w] = part[:h, :w]
    return alpha


def read_areas(zone: Zone) -> tuple[list[Area], list[str]]:
    """The zone's named sub-areas as disjoint masks on its map art, one per AreaTable name, and the IDs of overlays
    left out because their tiles are missing (their ground goes unmeasured).

    Each exploration overlay pictures one sub-area. Where soft overlay edges overlap, a pixel belongs to the most
    opaque one; pixels no overlay covers at half opacity or more lie outside the zone and belong to no area.
    """
    db2 = zone.flavor.db2
    art_ids = {row["UiMapArtID"] for row in _db2(db2, "UiMapXMapArt") if int(row["UiMapID"]) == zone.ui_map_id}
    if not art_ids:
        raise ValueError(f"{zone.name} ({zone.ui_map_id}) is not in {db2}; fetch the client's db2 tables again")
    # Overlays the client has no tiles for (flag 4, such as Zul'Gurub's) are hit areas without art; the client draws
    # nothing for them either, so they are no missing asset.
    textured = {row["WorldMapOverlayID"] for row in _db2(db2, "WorldMapOverlayTile")}
    overlays = [row for row in _db2(db2, "WorldMapOverlay") if row["UiMapArtID"] in art_ids and row["ID"] in textured]
    area_names = {row["ID"]: row["AreaName_lang"] for row in _db2(db2, "AreaTable-enUS")}
    folder = zone.flavor.overlay_tiles / str(zone.ui_map_id)

    # Place every overlay's alpha on the map art.
    alphas = np.zeros((len(overlays), ART_HEIGHT, ART_WIDTH), np.uint8)
    missing = []
    for i, overlay in enumerate(overlays):
        alpha = _overlay_alpha(folder, overlay)
        if alpha is None:
            missing.append(overlay["ID"])
            continue
        x, y = int(overlay["OffsetX"]), int(overlay["OffsetY"])
        h, w = min(alpha.shape[0], ART_HEIGHT - y), min(alpha.shape[1], ART_WIDTH - x)
        alphas[i, y:y + h, x:x + w] = alpha[:h, :w]

    # Partition: each covered pixel goes to its most opaque overlay; overlays sharing an area name merge.
    owner = alphas.argmax(axis=0)
    covered = alphas.max(axis=0) >= 128
    masks: dict[str, np.ndarray] = {}
    for i, overlay in enumerate(overlays):
        name = area_names.get(overlay["AreaID_0"], f"Overlay {overlay['ID']}")
        mask = covered & (owner == i)
        masks[name] = masks[name] | mask if name in masks else mask
    return [Area(name, mask) for name, mask in masks.items() if mask.any()], missing


# Minimap

def minimap_tile(world_x, world_y) -> tuple:
    """Fractional minimap tile (x, y) of a world position; takes numpy arrays too."""
    return 32 - world_y / TILE_YARDS, 32 - world_x / TILE_YARDS


class Minimap:
    """The continent's minimap tiles under one zone's world rect, stitched into one image.

    Tiles are scaled to pixels_per_tile; 256 is close to what the minimap shows at its widest zoom (466 yards
    across about 140 to 200 screen pixels). A margin of whole tiles keeps crops at the zone's edges filled.
    Open sea has no tiles; those pixels are black and not present.
    """

    def __init__(self, zone: Zone, pixels_per_tile: int = 256, margin: int = 1):
        self.pixels_per_tile = pixels_per_tile
        (tx_a, ty_a), (tx_b, ty_b) = minimap_tile(zone.x0, zone.y0), minimap_tile(zone.x1, zone.y1)
        self.tx0, self.ty0 = math.floor(min(tx_a, tx_b)) - margin, math.floor(min(ty_a, ty_b)) - margin
        columns = math.floor(max(tx_a, tx_b)) + margin - self.tx0 + 1
        rows = math.floor(max(ty_a, ty_b)) + margin - self.ty0 + 1

        size = pixels_per_tile
        self.image = np.zeros((rows * size, columns * size, 3), np.uint8)
        self.present = np.zeros((rows * size, columns * size), bool)
        folder = zone.flavor.minimap_tiles / str(zone.continent)
        for row in range(rows):
            for col in range(columns):
                path = folder / f"{self.tx0 + col}_{self.ty0 + row}.jpg"
                if not path.exists():
                    continue
                with Image.open(path) as tile:
                    pixels = np.asarray(tile.convert("RGB").resize((size, size), Image.Resampling.BOX))
                self.image[row * size:(row + 1) * size, col * size:(col + 1) * size] = pixels
                self.present[row * size:(row + 1) * size, col * size:(col + 1) * size] = True
        self.picture = Image.fromarray(self.image)

    def pixel(self, world_x, world_y):
        """Fractional image position (column, row) of a world position; takes numpy arrays too."""
        tx, ty = minimap_tile(world_x, world_y)
        return (tx - self.tx0) * self.pixels_per_tile, (ty - self.ty0) * self.pixels_per_tile

    def on_map_grid(self, zone: Zone, scale: int) -> tuple[np.ndarray, np.ndarray]:
        """The minimap resampled onto the zone's map art grid at scale times its resolution, so art-pixel masks
        line up after repeating each mask pixel scale x scale times.

        Returns:
            sRGB uint8 (ART_HEIGHT * scale, ART_WIDTH * scale, 3), and where a minimap tile was present.
        """
        mx = (np.arange(ART_WIDTH * scale) + 0.5) / (ART_WIDTH * scale)
        my = (np.arange(ART_HEIGHT * scale) + 0.5) / (ART_HEIGHT * scale)
        column, row = self.pixel(*zone.world_position(mx[None, :], my[:, None]))
        column = np.clip(column.astype(int), 0, self.image.shape[1] - 1)
        row = np.clip(row.astype(int), 0, self.image.shape[0] - 1)
        return self.image[row, column], self.present[row, column]

    def crop(self, world_x: float, world_y: float, radius_yards: float) -> Image.Image:
        """A square of the minimap centered on a world position, black where there is no tile."""
        column, row = self.pixel(world_x, world_y)
        radius = radius_yards / TILE_YARDS * self.pixels_per_tile
        box = tuple(round(v) for v in (column - radius, row - radius, column + radius, row + radius))
        return self.picture.crop(box)
