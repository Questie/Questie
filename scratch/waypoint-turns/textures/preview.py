"""Draws preview.png: each texture zoomed with its texels visible, and a tinted line ending in a half cap.
Usage: uv run --no-project --with pillow python preview.py"""
from PIL import Image, ImageDraw

ZOOM = 14
CORE = (255, 184, 0)  # default patrol color
BACKGROUND = (59, 74, 58)


def checker(size):
    image = Image.new("RGBA", size, (200, 200, 200, 255))
    draw = ImageDraw.Draw(image)
    for y in range(0, size[1], ZOOM // 2):
        for x in range(0, size[0], ZOOM // 2):
            if (x // (ZOOM // 2) + y // (ZOOM // 2)) % 2:
                draw.rectangle([x, y, x + ZOOM // 2 - 1, y + ZOOM // 2 - 1], fill=(150, 150, 150, 255))
    return image


def zoomed(texture, background):
    big = texture.resize((texture.width * ZOOM, texture.height * ZOOM), Image.NEAREST)
    base = checker(big.size) if background is None else Image.new("RGBA", big.size, background + (255,))
    base.alpha_composite(big)
    draw = ImageDraw.Draw(base)
    for x in range(0, big.width + 1, ZOOM):
        draw.line([x, 0, x, big.height], fill=(255, 0, 0, 60))
    for y in range(0, big.height + 1, ZOOM):
        draw.line([0, y, big.width, y], fill=(255, 0, 0, 60))
    return base


def tint(texture):
    # Vertex color multiplies: the white core takes the color, black stays black.
    pixels = [(r * CORE[0] // 255, g * CORE[1] // 255, b * CORE[2] // 255, a) for r, g, b, a in texture.getdata()]
    tinted = Image.new("RGBA", texture.size)
    tinted.putdata(pixels)
    return tinted


line = Image.open("waypoint-line-aa.png").convert("RGBA")
cap = Image.open("waypoint-cap-aa.png").convert("RGBA")

# A leg three line textures long, ending in the cap's right half: SetTexCoord(0.5, 0.75, 0.25, 0.75).
joined = Image.new("RGBA", (16 * 3 + 8, 16))
for i in range(3):
    joined.paste(line, (16 * i, 0))
joined.paste(cap.crop((16, 8, 24, 24)), (48, 0))

panels = [
    ("waypoint-line-aa.png, 16x16", zoomed(line, None)),
    ("waypoint-cap-aa.png, 32x32", zoomed(cap, None)),
    ("Tinted line ending in the half cap", zoomed(tint(joined), BACKGROUND)),
]
width = max(panel.width for _, panel in panels) + 40
height = sum(panel.height + 50 for _, panel in panels) + 20
sheet = Image.new("RGBA", (width, height), (40, 40, 40, 255))
draw = ImageDraw.Draw(sheet)
y = 20
for title, panel in panels:
    draw.text((20, y), title, fill=(255, 255, 255, 255))
    sheet.alpha_composite(panel, (20, y + 20))
    y += panel.height + 50
sheet.save("preview.png")
print("preview.png")
