"""Draws the blob border textures into Icons/blobs, which PolygonRenderer loads.
Usage: uv run --no-project --with pillow python Icons/originals/blobs/build.py

They are the patrol path textures (Icons/originals/waypoints) without the black outline: the same
rows, white where those are black, so a border is all its area's colour with a soft edge.
- blob-line-aa.png, 16x16: constant along x; across y, the line's profile around its centerline at
  y = 8. The middle 12 rows are the line, one row at half alpha and one transparent row fade it out
  on each side. Pieces are drawn 16/12 as wide as the border, so the border keeps its thickness.
- blob-cap-aa.png, 32x32: the same profile turned into rings around the centre (16, 16), at the
  line's texel density: opaque within radius 6, half alpha to radius 7, transparent beyond. Each
  texel's alpha is the share of it each ring covers, as an SVG renderer would draw it.
Every texel is white, transparent ones included. Filtering blends colour with transparent texels too,
so black ones, which SVG renderers write, would darken the fade into a grey fringe.
"""
from pathlib import Path

from PIL import Image

TEXTURES = Path(__file__).resolve().parents[2] / "blobs"
SUBSAMPLES = 16  # per texel and axis, for the cap's ring coverage


def save(image, name):
    path = TEXTURES / name
    image.save(path)
    print(path)


def line():
    rows = [0, 0.5] + [1] * 12 + [0.5, 0]
    image = Image.new("RGBA", (16, 16))
    for y, alpha in enumerate(rows):
        for x in range(16):
            image.putpixel((x, y), (255, 255, 255, round(alpha * 255)))
    return image


def ring_alpha(radius):
    if radius < 6:
        return 1
    if radius < 7:
        return 0.5
    return 0


def cap():
    image = Image.new("RGBA", (32, 32))
    for y in range(32):
        for x in range(32):
            total = 0
            for sy in range(SUBSAMPLES):
                for sx in range(SUBSAMPLES):
                    dx = x + (sx + 0.5) / SUBSAMPLES - 16
                    dy = y + (sy + 0.5) / SUBSAMPLES - 16
                    total += ring_alpha((dx * dx + dy * dy) ** 0.5)
            image.putpixel((x, y), (255, 255, 255, round(total / SUBSAMPLES ** 2 * 255)))
    return image


save(line(), "blob-line-aa.png")
save(cap(), "blob-cap-aa.png")
