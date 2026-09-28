"""Generates app/build/icon.ico - a crescent moon on the Moon Dark background.
Run once with Pillow installed: python3 scripts/make-icon.py
"""
from PIL import Image, ImageDraw

BG = (16, 18, 28, 255)       # #10121C
GLOW = (224, 200, 128, 255)  # #E0C880 moon-glow gold
RING = (65, 72, 104, 255)    # #414868

SIZES = [16, 24, 32, 48, 64, 128, 256]


def render(size: int) -> Image.Image:
    scale = 4
    big = size * scale
    img = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    pad = big * 0.06
    draw.rounded_rectangle(
        [pad, pad, big - pad, big - pad],
        radius=big * 0.22,
        fill=BG,
        outline=RING,
        width=max(1, int(big * 0.015)),
    )

    # Crescent moon: a full gold circle with a background-colored circle
    # offset on top of it to carve out the crescent shape.
    cx, cy = big * 0.5, big * 0.5
    r = big * 0.28
    draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=GLOW)

    r2 = big * 0.24
    ox, oy = big * 0.14, -big * 0.03
    draw.ellipse(
        [cx - r2 + ox, cy - r2 + oy, cx + r2 + ox, cy + r2 + oy],
        fill=BG,
    )

    return img.resize((size, size), Image.LANCZOS)


images = [render(s) for s in SIZES]
images[-1].save(
    "app/build/icon.ico",
    sizes=[(s, s) for s in SIZES],
)
print("wrote app/build/icon.ico")
