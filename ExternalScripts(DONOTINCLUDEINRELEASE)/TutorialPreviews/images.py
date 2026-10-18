"""Writes the objective style popup's preview backgrounds from the crops generate.lua listed. See README.md.

Run from the Questie repository root:
    uv run --no-project --with pillow python -I "ExternalScripts(DONOTINCLUDEINRELEASE)/TutorialPreviews/images.py" \
        <era assets> <mists assets>
"""
import io
import struct
import sys
from pathlib import Path

from PIL import Image

HERE = Path("ExternalScripts(DONOTINCLUDEINRELEASE)/TutorialPreviews")
ART_WIDTH, ART_HEIGHT, TILE = 1002, 668, 256
SIZE = 256  # The image's width and height; the popup shows it at 220.


def explored_map(assets: Path, ui_map_id: str) -> Image.Image:
    """A zone's map art with every exploration overlay on, as the ColorContrast fetch stores it."""
    folder = assets / "explored" / ui_map_id
    art = Image.new("RGB", (TILE * 4, TILE * 3))
    for row in range(3):
        for column in range(4):
            art.paste(Image.open(folder / f"r{row}c{column}.png").convert("RGB"), (column * TILE, row * TILE))
    return art.crop((0, 0, ART_WIDTH, ART_HEIGHT))


def dxt1(image: Image.Image) -> bytes:
    """One mip level's DXT1 blocks; levels under 4 pixels still take one block."""
    if image.width < 4:
        image = image.resize((4, 4), Image.NEAREST)
    buffer = io.BytesIO()
    image.save(buffer, "DDS", pixel_format="DXT1")
    return buffer.getvalue()[128:]  # Past the DDS header.


def blp(image: Image.Image) -> bytes:
    """A BLP2 file: DXT1 without alpha and a full mip chain, as Questie's other BLPs are laid out."""
    levels, level = [], image
    while True:
        levels.append(dxt1(level))
        if level.width == 1:
            break
        level = level.resize((level.width // 2, level.height // 2), Image.LANCZOS)
    header_size = 4 + 4 + 4 + 8 + 16 * 4 * 2 + 256 * 4  # Magic, type, flags, size, mip table, palette.
    offsets, sizes, offset = [], [], header_size
    for data in levels:
        offsets.append(offset)
        sizes.append(len(data))
        offset += len(data)
    pad = [0] * (16 - len(levels))
    header = struct.pack("<4sIBBBBII16I16I", b"BLP2", 1, 2, 0, 0, 1, image.width, image.height,
                         *(offsets + pad), *(sizes + pad))
    return header + bytes(256 * 4) + b"".join(levels)


def main() -> None:
    assets = {"Classic": Path(sys.argv[1]), "Cata": Path(sys.argv[2])}
    for line in (HERE / "crops.tsv").read_text().splitlines():
        if line.startswith("#"):
            continue
        art_set, ui_map_id, left, top, size, out = line.split("\t")
        left, top, size = int(left), int(top), int(size)
        art = explored_map(assets[art_set], ui_map_id)
        image = art.crop((left, top, left + size, top + size)).resize((SIZE, SIZE), Image.LANCZOS)
        Path(out).write_bytes(blp(image))
        print("wrote", out)


if __name__ == "__main__":
    main()
