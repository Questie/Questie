# /// script
# requires-python = ">=3.11"
# dependencies = ["numpy==2.5.4", "pillow==13.0.0"]
# ///
"""Downloads everything the tool measures for one flavor into its asset folder (sources.Flavor.assets):

  db2/<Table>.csv                               the client's map tables of the flavor's build, from wago.tools
  maps/<uiMapID>/r<row>c<col>.png               each outdoor map's art
  maps/<uiMapID>/o<overlayID>-r<row>c<col>.png  its exploration overlays
  explored/<uiMapID>/r<row>c<col>.png           the art with every overlay blended on, as a fully explored character
                                                sees it; maps without overlays get none
  minimaps/<instanceID>/<x>_<y>.jpg             the minimap tiles under every outdoor map, and one around it

Art and tiles come from Blizzard's CDN through CASCConsole (CASCExplorer) in the WoW install. The CDN serves only a
product's current build, so once it has moved past the flavor's build, fetch refuses: raise the flavor's build in
sources.py, fetch again (into the new build's folder) and rerun the tool. Files already fetched are kept, so an
interrupted run continues where it stopped.

Run from this folder:
  uv run fetch.py --flavor mists [--wow "/mnt/c/Games/World of Warcraft"]
"""

from __future__ import annotations

import argparse
import csv
import os
import re
import struct
import subprocess
import sys
import tempfile
import urllib.error
import urllib.request
from concurrent.futures import ProcessPoolExecutor
from pathlib import Path

from PIL import Image

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
from sources import ART_TILE, FLAVORS, Flavor, minimap_tile_range, read_outdoor_maps  # noqa: E402

WOW = Path(os.environ.get("QUESTIE_WOW", "/mnt/c/Games/World of Warcraft"))
TABLES = ("UiMap", "UiMapAssignment", "UiMapXMapArt", "UiMapArtTile", "WorldMapOverlay", "WorldMapOverlayTile",
          "AreaTable", "Map")
WAGO = "https://wago.tools/db2/{table}/csv?build={build}"
LOADED = re.compile(r"Loaded (\S+) (\S+)")
EXTRACTED = re.compile(r"Extracting '(.+)'\.\.\. Ok!")


# Map tables

def fetch_tables(flavor: Flavor) -> None:
    """Downloads each of TABLES for the flavor's build once, whole or not at all."""
    flavor.db2.mkdir(parents=True, exist_ok=True)
    for table in TABLES:
        path = flavor.db2 / f"{table}.csv"
        if path.exists():
            continue
        url = WAGO.format(table=table, build=flavor.build)
        print("downloading", url)
        request = urllib.request.Request(url, headers={"User-Agent": "Questie colorcontrast fetch"})
        try:
            with urllib.request.urlopen(request, timeout=120) as response:
                body = response.read()
        except urllib.error.HTTPError as error:
            raise SystemExit(f"wago.tools has no {table} for build {flavor.build} (HTTP {error.code})") from error
        except urllib.error.URLError as error:
            raise SystemExit(f"cannot reach wago.tools ({error.reason})") from error
        path.with_suffix(".part").write_bytes(body)
        path.with_suffix(".part").replace(path)


def read_table(flavor: Flavor, table: str) -> list[dict[str, str]]:
    with (flavor.db2 / f"{table}.csv").open(newline="", encoding="utf-8") as handle:
        return list(csv.DictReader(handle))


# Blizzard's CDN

def native(path: Path) -> str:
    """Path as the Windows CASCConsole sees it."""
    return subprocess.run(["wslpath", "-w", str(path)], check=True, capture_output=True, text=True).stdout.strip()


def extract(wow: Path, flavor: Flavor, file_ids: set[int], dest: Path) -> None:
    """Downloads files by fileDataID into dest/<fileDataID>.blob, every one from the flavor's build or none."""
    exe = wow / "CASC" / "CASCConsole.exe"
    request = dest / "request.txt"
    request.write_text("".join(f"{file_id};{file_id}.blob\r\n" for file_id in sorted(file_ids)), encoding="utf-8")
    command = [str(exe), "-m", "Listfile", "-e", native(request), "-d", native(dest), "-l", "enUS",
               "-p", flavor.product, "-o"]
    result = subprocess.run(command, cwd=exe.parent, capture_output=True, text=True, errors="replace")
    log = result.stdout + result.stderr
    (dest / "casc.log").write_text(log, encoding="utf-8")
    served = LOADED.search(log)
    if not served:
        raise SystemExit(f"CASCConsole did not say which build it loaded; see {dest / 'casc.log'}:\n{log[-1500:]}")
    if served.group(2) != flavor.build:
        raise SystemExit(f"the CDN serves {flavor.product} {served.group(2)}, but the flavor measures "
                         f"{flavor.build}; raise its build in sources.py and fetch again")
    extracted = set(EXTRACTED.findall(log))
    missing = [file_id for file_id in file_ids if f"{file_id}.blob" not in extracted]
    if result.returncode or missing:
        raise SystemExit(f"CASCConsole did not get {len(missing)} of {len(file_ids)} files (exit code "
                         f"{result.returncode}); see {dest / 'casc.log'}")


def open_raw_blp2(data: bytes) -> Image.Image:
    """Decodes BLP2 encoding 3 (uncompressed BGRA, first mip), which Pillow does not support."""
    if data[:4] != b"BLP2" or data[8] != 3:
        raise ValueError("not an uncompressed BLP2")
    width, height, offset = (int.from_bytes(data[i:i + 4], "little") for i in (12, 16, 20))
    return Image.frombytes("RGBA", (width, height), data[offset:offset + width * height * 4], "raw", "BGRA")


def convert(job: tuple[Path, Path]) -> str | None:
    """Writes one BLP as PNG (RGBA) or JPEG (RGB, quality 90, for minimap tiles, which are DXT1 already).
    Returns an error message, or None."""
    source, target = job
    try:
        try:
            image = Image.open(source)
            image.load()
        except Exception:  # noqa: BLE001 - Pillow raises several types for unsupported BLP variants
            image = open_raw_blp2(source.read_bytes())
        target.parent.mkdir(parents=True, exist_ok=True)
        part = target.with_name(target.name + ".part")
        if target.suffix == ".jpg":
            image.convert("RGB").save(part, "JPEG", quality=90)
        else:
            image.convert("RGBA").save(part, "PNG")
        part.replace(target)
    except Exception as error:  # noqa: BLE001
        return f"cannot convert {source.name} to {target}: {error}"
    return None


def download(wow: Path, flavor: Flavor, wanted: dict[Path, int]) -> None:
    """Fetches and converts every target file (path -> fileDataID) that does not exist yet."""
    missing = {path: file_id for path, file_id in wanted.items() if not path.exists()}
    if not missing:
        return
    with tempfile.TemporaryDirectory(dir=flavor.assets, prefix="downloads-") as temp:
        dest = Path(temp)
        extract(wow, flavor, set(missing.values()), dest)
        with ProcessPoolExecutor() as pool:
            errors = [error for error in pool.map(convert, [(dest / f"{file_id}.blob", path)
                                                            for path, file_id in missing.items()]) if error]
    if errors:
        raise SystemExit("\n".join(errors))
    print(f"{len(missing)} files downloaded")


# Map art

def art_files(flavor: Flavor) -> dict[Path, int]:
    """Every outdoor map's art tiles and its textured overlays' tiles, by target path."""
    art_tiles: dict[int, list[dict[str, str]]] = {}
    for row in read_table(flavor, "UiMapArtTile"):
        if row["LayerIndex"] == "0":
            art_tiles.setdefault(int(row["UiMapArtID"]), []).append(row)
    overlay_tiles: dict[str, list[dict[str, str]]] = {}
    for row in read_table(flavor, "WorldMapOverlayTile"):
        if row["LayerIndex"] == "0":
            overlay_tiles.setdefault(row["WorldMapOverlayID"], []).append(row)
    overlays: dict[int, list[str]] = {}
    for row in read_table(flavor, "WorldMapOverlay"):
        overlays.setdefault(int(row["UiMapArtID"]), []).append(row["ID"])

    wanted = {}
    for zone in read_outdoor_maps(flavor):
        folder = flavor.maps / str(zone.ui_map_id)
        for tile in art_tiles.get(zone.art, []):
            wanted[folder / f"r{tile['RowIndex']}c{tile['ColIndex']}.png"] = int(tile["FileDataID"])
        for overlay in overlays.get(zone.art, []):
            for tile in overlay_tiles.get(overlay, []):
                wanted[folder / f"o{overlay}-r{tile['RowIndex']}c{tile['ColIndex']}.png"] = int(tile["FileDataID"])
    return wanted


def overlay_image(folder: Path, overlay: dict[str, str]) -> Image.Image | None:
    """One explored area as a single RGBA image of its texture size, or None when a tile is missing.

    Tiles are 256 pixels except the last column and row, which are power-of-two files the client draws only the
    top-left part of (MapExplorationPinMixin:RefreshOverlays), so each tile is cropped to the part that shows."""
    width, height = int(overlay["TextureWidth"]), int(overlay["TextureHeight"])
    image = Image.new("RGBA", (width, height))
    for row in range(-(-height // ART_TILE)):
        for col in range(-(-width // ART_TILE)):
            path = folder / f"o{overlay['ID']}-r{row}c{col}.png"
            if not path.exists():
                return None
            with Image.open(path) as tile:
                visible = (0, 0, min(ART_TILE, width - col * ART_TILE), min(ART_TILE, height - row * ART_TILE))
                image.paste(tile.convert("RGBA").crop(visible), (col * ART_TILE, row * ART_TILE))
    return image


def compose_explored(flavor: Flavor) -> None:
    """Bakes every overlay into its map's art, in overlay ID order as the client acquires them, for each map with
    at least one textured overlay. Overlays without tiles (flag 4, such as Wintergrasp's) are hit areas the client
    draws nothing for."""
    textured = {row["WorldMapOverlayID"] for row in read_table(flavor, "WorldMapOverlayTile")}
    overlays: dict[str, list[dict[str, str]]] = {}
    for row in sorted(read_table(flavor, "WorldMapOverlay"), key=lambda r: int(r["ID"])):
        if row["ID"] in textured:
            overlays.setdefault(row["UiMapArtID"], []).append(row)
    for zone in read_outdoor_maps(flavor):
        target = flavor.explored / str(zone.ui_map_id)
        if target.is_dir():
            continue
        folder = flavor.maps / str(zone.ui_map_id)
        tiles = {tuple(map(int, re.fullmatch(r"r(\d+)c(\d+)", p.stem).groups())): p for p in folder.glob("r*c*.png")}
        drawn = [(overlay, image) for overlay in overlays.get(str(zone.art), [])
                 if (image := overlay_image(folder, overlay)) is not None]
        if not tiles or not drawn:
            continue
        rows, columns = max(r for r, _ in tiles) + 1, max(c for _, c in tiles) + 1
        art = Image.new("RGBA", (columns * ART_TILE, rows * ART_TILE))
        for (row, col), path in tiles.items():
            with Image.open(path) as tile:
                art.paste(tile.convert("RGBA"), (col * ART_TILE, row * ART_TILE))
        for overlay, image in drawn:
            art.alpha_composite(image, (int(overlay["OffsetX"]), int(overlay["OffsetY"])))

        # Written to a side folder and renamed, so a stopped run leaves no half-explored map behind.
        part = target.with_name(target.name + ".part")
        part.mkdir(parents=True, exist_ok=True)
        for row in range(rows):
            for col in range(columns):
                box = (col * ART_TILE, row * ART_TILE, (col + 1) * ART_TILE, (row + 1) * ART_TILE)
                art.crop(box).save(part / f"r{row}c{col}.png")
        part.replace(target)


# Minimap

def wdt_files(flavor: Flavor, wow: Path, continents: set[int]) -> dict[int, int]:
    """Each continent's WDT fileDataID: Map's WdtFileDataID where the client's table has one, else its path in
    CASCConsole's community listfile (world/maps/<Directory>/<Directory>.wdt)."""
    found, paths = {}, {}
    for row in read_table(flavor, "Map"):
        instance = int(row["ID"])
        if instance not in continents:
            continue
        if int(row.get("WdtFileDataID") or 0):
            found[instance] = int(row["WdtFileDataID"])
        else:
            paths[f"world/maps/{row['Directory']}/{row['Directory']}.wdt".lower()] = instance
    if paths:
        with (wow / "CASC" / "listfile.csv").open(encoding="utf-8", errors="replace") as listfile:
            for line in listfile:
                file_id, _, path = line.strip().partition(";")
                if path.lower() in paths:
                    found[paths[path.lower()]] = int(file_id)
    if missing := continents - set(found):
        raise SystemExit(f"no WDT found for instances {sorted(missing)}; update CASCConsole's listfile.csv")
    return found


def minimap_texture_ids(wdt: bytes) -> dict[tuple[int, int], int]:
    """Minimap texture fileDataIDs by tile (x, y) from a WDT's MAID chunk: per tile, eight fileDataIDs (root, obj0,
    obj1, tex0, lod, mapTexture, mapTextureN, minimapTexture), row-major by y. Chunk names are stored reversed."""
    pos = 0
    while pos + 8 <= len(wdt):
        name, size = wdt[pos:pos + 4][::-1], struct.unpack_from("<I", wdt, pos + 4)[0]
        if name == b"MAID":
            ids = struct.unpack_from(f"<{64 * 64 * 8}I", wdt, pos + 8)
            return {(index % 64, index // 64): ids[index * 8 + 7] for index in range(64 * 64) if ids[index * 8 + 7]}
        pos += 8 + size
    raise ValueError("WDT has no MAID chunk")


def minimap_files(flavor: Flavor, wow: Path) -> dict[Path, int]:
    """The minimap tiles under every outdoor map, by target path."""
    zones = read_outdoor_maps(flavor)
    wdts = wdt_files(flavor, wow, {zone.continent for zone in zones})
    with tempfile.TemporaryDirectory(dir=flavor.assets, prefix="downloads-") as temp:
        extract(wow, flavor, set(wdts.values()), Path(temp))
        textures = {instance: minimap_texture_ids((Path(temp) / f"{file_id}.blob").read_bytes())
                    for instance, file_id in wdts.items()}
    wanted = {}
    for zone in zones:
        tiles_x, tiles_y = minimap_tile_range(zone)
        for x in tiles_x:
            for y in tiles_y:
                if file_id := textures[zone.continent].get((x, y)):  # open sea has no tile
                    wanted[flavor.minimaps / str(zone.continent) / f"{x}_{y}.jpg"] = file_id
    return wanted


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--flavor", choices=sorted(FLAVORS), required=True)
    parser.add_argument("--wow", type=Path, default=WOW, help="WoW install folder with CASC/CASCConsole.exe")
    args = parser.parse_args()
    flavor = FLAVORS[args.flavor]

    fetch_tables(flavor)
    if flavor.measured_on:
        print(f"{flavor.name} ships the {FLAVORS[flavor.measured_on].name} measurements; its tables are all it needs")
        return
    print("map art and overlays")
    download(args.wow, flavor, art_files(flavor))
    compose_explored(flavor)
    print("minimap tiles")
    download(args.wow, flavor, minimap_files(flavor, args.wow))
    print(f"{flavor.name} {flavor.build}: assets in {flavor.assets}")


if __name__ == "__main__":
    main()
