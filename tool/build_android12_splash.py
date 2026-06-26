#!/usr/bin/env python3
"""Build the Android-12 splash icon from the full-bleed splash logo.

Android 12+ shows the system splash via windowSplashScreenAnimatedIcon, which
the OS masks into a circle with a ~2/3-diameter safe zone. Our splash_logo.png
is full-bleed, so the mask shaves its edges and corners. This script scales the
logo down and centers it on a transparent 1152px canvas so the entire logo sits
inside the safe circle, then writes splash_logo_android12.png.

Run from the project root, then regenerate native splashes:
    python3 tool/build_android12_splash.py
    dart run flutter_native_splash:create

Requires Pillow (pip install Pillow).
"""
import math
from PIL import Image

SRC = "assets/images/splash_logo.png"
OUT = "assets/images/splash_logo_android12.png"
CANVAS = 1152          # high-res source; flutter_native_splash downscales per density
SAFE_R = CANVAS / 3    # 2/3-diameter safe circle -> radius = canvas/3
MARGIN = 0.93          # keep the art a touch inside the safe circle


def main():
    src = Image.open(SRC).convert("RGBA")
    w, h = src.size
    cx, cy = w / 2, h / 2

    # Farthest opaque pixel from center == the radius the mask must contain.
    alpha = src.getchannel("A").load()
    r0 = 0.0
    for y in range(h):
        for x in range(w):
            if alpha[x, y] > 16:
                r0 = max(r0, math.hypot(x - cx, y - cy))

    scale = (SAFE_R * MARGIN) / r0
    side = max(1, round(w * scale))
    scaled = src.resize((side, side), Image.LANCZOS)

    canvas = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    offset = (CANVAS - side) // 2
    canvas.paste(scaled, (offset, offset), scaled)
    canvas.save(OUT)
    print(f"wrote {OUT} ({CANVAS}x{CANVAS}); logo scaled to {side}px "
          f"(safe radius {SAFE_R:.0f}px, margin {MARGIN})")


if __name__ == "__main__":
    main()
