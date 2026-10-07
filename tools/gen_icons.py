#!/usr/bin/env python3
"""Genera los íconos de launcher de Fylax (legacy, redondos y adaptativos).

El glifo es la "F" de marca: degradado azul -> verde con la barra central
como trazo ascendente. La geometría replica _FylaxLogoPainter.glyphPath
(lib/core/widgets/fylax_logo.dart) — si el logo cambia, actualizar ambos.

Uso:  python tools/gen_icons.py
"""

import math
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
RES = ROOT / "android" / "app" / "src" / "main" / "res"

BLUE_DEEP = (30, 94, 255)
BLUE = (46, 143, 255)
GREEN = (0, 214, 143)
BG_DARK_1 = (16, 28, 40)   # #101C28
BG_DARK_2 = (10, 18, 27)   # #0A121B
BG_ICON = "#060B11"

DENSITIES = {
    "mdpi": (48, 108),
    "hdpi": (72, 162),
    "xhdpi": (96, 216),
    "xxhdpi": (144, 324),
    "xxxhdpi": (192, 432),
}


def diagonal_gradient(size, stops):
    """Gradiente RGB a lo largo de la diagonal (0=arriba-izq, 1=abajo-der)."""
    y, x = np.mgrid[0:size, 0:size].astype(np.float32)
    t = (x + y) / (2 * (size - 1))
    img = np.zeros((size, size, 3), np.float32)
    for i in range(len(stops) - 1):
        t0, c0 = stops[i]
        t1, c1 = stops[i + 1]
        m = (t >= t0) & (t <= t1)
        f = np.clip((t[m] - t0) / max(t1 - t0, 1e-6), 0, 1)[:, None]
        for ch in range(3):
            img[..., ch][m] = c0[ch] + (c1[ch] - c0[ch]) * f[:, 0]
    return img


def glyph_mask(size, scale=1.0, offset=(0.0, 0.0)):
    """Máscara L de la 'F' en coordenadas normalizadas, supersampleada."""
    S = size * 4  # supersampling
    mask = Image.new("L", (S, S), 0)
    d = ImageDraw.Draw(mask)

    def box(x0, y0, x1, y1):
        d.rectangle(
            [ (x0 * scale + offset[0]) * S, (y0 * scale + offset[1]) * S,
              (x1 * scale + offset[0]) * S, (y1 * scale + offset[1]) * S ],
            fill=255,
        )

    box(0.34, 0.26, 0.46, 0.74)  # vástago
    box(0.34, 0.26, 0.74, 0.38)  # brazo superior

    # barra central ascendente (rotada -24°)
    cx, cy, hw, hh, a = 0.57, 0.52, 0.13, 0.055, -0.42
    dx = (math.cos(a) * hw, math.sin(a) * hw)
    dy = (-math.sin(a) * hh, math.cos(a) * hh)
    pts = [
        (cx - dx[0] - dy[0], cy - dx[1] - dy[1]),
        (cx + dx[0] - dy[0], cy + dx[1] - dy[1]),
        (cx + dx[0] + dy[0], cy + dx[1] + dy[1]),
        (cx - dx[0] + dy[0], cy - dx[1] + dy[1]),
    ]
    d.polygon(
        [((px * scale + offset[0]) * S, (py * scale + offset[1]) * S)
         for px, py in pts],
        fill=255,
    )
    return mask.resize((size, size), Image.LANCZOS)


def brand_glyph(size, scale=1.0, offset=(0.0, 0.0)):
    """Glifo 'F' en RGBA con el degradado de marca.

    El degradado se normaliza sobre el bounding box del glifo
    (x: 0.34..0.74, y: 0.26..0.74) para que el verde sí llegue al trazo.
    """
    y, x = np.mgrid[0:size, 0:size].astype(np.float32)
    nx = (x / size - offset[0]) / scale
    ny = (y / size - offset[1]) / scale
    t = np.clip(((nx - 0.34) / 0.40 + (ny - 0.26) / 0.48) / 2, 0, 1)

    stops = [(0.0, BLUE_DEEP), (0.45, BLUE), (1.0, GREEN)]
    grad = np.zeros((size, size, 3), np.float32)
    for i in range(len(stops) - 1):
        t0, c0 = stops[i]
        t1, c1 = stops[i + 1]
        m = (t >= t0) & (t <= t1)
        f = np.clip((t[m] - t0) / max(t1 - t0, 1e-6), 0, 1)[:, None]
        for ch in range(3):
            grad[..., ch][m] = c0[ch] + (c1[ch] - c0[ch]) * f[:, 0]

    alpha = np.array(glyph_mask(size, scale, offset))
    return Image.fromarray(
        np.dstack([grad.astype(np.uint8), alpha]), "RGBA"
    )


def rounded_mask(size, radius_ratio, circle=False):
    S = size * 4
    mask = Image.new("L", (S, S), 0)
    d = ImageDraw.Draw(mask)
    inset = S * 0.02
    box = [inset, inset, S - inset, S - inset]
    if circle:
        d.ellipse(box, fill=255)
    else:
        d.rounded_rectangle(box, radius=S * radius_ratio, fill=255)
    return mask.resize((size, size), Image.LANCZOS)


def badge_icon(size, circle=False):
    """Ícono legacy: squircle (o círculo) negro + glifo degradado."""
    grad = diagonal_gradient(size, [(0.0, BG_DARK_1), (1.0, BG_DARK_2)])
    base = Image.fromarray(grad.astype(np.uint8), "RGB").convert("RGBA")

    # glow radial azul suave detrás del glifo
    y, x = np.mgrid[0:size, 0:size].astype(np.float32)
    cx = cy = (size - 1) / 2
    r = np.sqrt((x - cx) ** 2 + (y - cy) ** 2) / (size * 0.62)
    glow_alpha = np.clip(1 - r, 0, 1) ** 2 * 64
    glow = np.zeros((size, size, 4), np.uint8)
    glow[..., 0], glow[..., 1], glow[..., 2] = BLUE
    glow[..., 3] = glow_alpha.astype(np.uint8)
    base.alpha_composite(Image.fromarray(glow, "RGBA"))

    # borde apenas visible
    S = size * 4
    border_img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(border_img)
    inset = S * 0.02
    box = [inset, inset, S - inset, S - inset]
    width = max(int(S * 0.012), 1)
    if circle:
        d.ellipse(box, outline=(255, 255, 255, 20), width=width)
    else:
        d.rounded_rectangle(
            box, radius=S * 0.28, outline=(255, 255, 255, 20), width=width
        )
    base.alpha_composite(border_img.resize((size, size), Image.LANCZOS))

    # glifo al 78% para que respire dentro del badge
    scale, off = 0.78, (0.11, 0.11)
    base.alpha_composite(brand_glyph(size, scale, off))

    base.putalpha(rounded_mask(size, 0.28, circle))
    return base


def foreground_icon(size):
    """Foreground adaptativo: glifo centrado ocupando la zona segura."""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    scale = 0.56
    off = ((1 - scale) / 2, (1 - scale) / 2)
    img.alpha_composite(brand_glyph(size, scale, off))
    return img


ADAPTIVE_XML = """<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
    <monochrome android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
"""

COLORS_XML = f"""<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">{BG_ICON}</color>
</resources>
"""


def main():
    for density, (legacy, fg) in DENSITIES.items():
        out = RES / f"mipmap-{density}"
        out.mkdir(parents=True, exist_ok=True)
        badge_icon(legacy).save(out / "ic_launcher.png")
        badge_icon(legacy, circle=True).save(out / "ic_launcher_round.png")
        foreground_icon(fg).save(out / "ic_launcher_foreground.png")
        print(f"mipmap-{density}: {legacy}px / fg {fg}px")

    anydpi = RES / "mipmap-anydpi-v26"
    anydpi.mkdir(parents=True, exist_ok=True)
    for name in ("ic_launcher.xml", "ic_launcher_round.xml"):
        (anydpi / name).write_text(ADAPTIVE_XML, encoding="utf-8")

    values = RES / "values"
    values.mkdir(parents=True, exist_ok=True)
    colors = values / "colors.xml"
    if not colors.exists():
        colors.write_text(COLORS_XML, encoding="utf-8")
    elif "ic_launcher_background" not in colors.read_text(encoding="utf-8"):
        text = colors.read_text(encoding="utf-8").replace(
            "</resources>",
            f'    <color name="ic_launcher_background">{BG_ICON}</color>\n'
            "</resources>",
        )
        colors.write_text(text, encoding="utf-8")

    # Master de marca para splash/marketing (badge a 1024 px).
    master = ROOT / "assets" / "brand"
    master.mkdir(parents=True, exist_ok=True)
    badge_icon(1024).save(master / "fylax_logo.png")
    print("assets/brand/fylax_logo.png (1024px)")


if __name__ == "__main__":
    main()
