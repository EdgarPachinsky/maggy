"""Generates Maggy's macOS app icon PNGs.

Style: dark charcoal tile, lavender-to-pink disc, navy 'm' monogram
(matches the Kitty app icon family). GLYPH=stack or GLYPH=M renders the
alternative glyphs.

Run from the project root:  python3 tool/generate_icon.py
Requires: pip install pillow numpy
"""
import numpy as np
from PIL import Image, ImageDraw, ImageFilter
import math, os, sys

S = 4096          # supersampled canvas
k = S / 1024

def superellipse_mask(size, x0, y0, w, h, n=5.0):
    yy, xx = np.mgrid[0:size, 0:size].astype(np.float32) + 0.5
    nx = np.abs((xx - (x0 + w/2)) / (w/2))
    ny = np.abs((yy - (y0 + h/2)) / (h/2))
    return ((nx**n + ny**n) <= 1.0)

def lerp(a, b, t): return a + (b - a) * t

canvas = Image.new('RGBA', (S, S), (0, 0, 0, 0))

# Tile geometry (macOS icon grid: 824pt body in a 1024 canvas, a bit high for shadow)
bx, by, bw = 100*k, 92*k, 824*k
tile = superellipse_mask(S, bx, by, bw, bw)

# Shadow
sh = Image.fromarray((superellipse_mask(S, bx, by + 14*k, bw, bw) * 110).astype(np.uint8))
sh = sh.filter(ImageFilter.GaussianBlur(22*k))
shadow = Image.new('RGBA', (S, S), (0, 0, 0, 0)); shadow.putalpha(sh)
canvas = Image.alpha_composite(canvas, shadow)

# Tile fill: charcoal vertical gradient
yy = np.linspace(0, 1, S, dtype=np.float32)[:, None]
top, bot = np.array([36, 36, 38]), np.array([18, 18, 20])
col = np.zeros((S, S, 4), np.float32)
for c in range(3):
    col[..., c] = top[c] * (1 - yy) + bot[c] * yy
col[..., 3] = tile * 255
canvas = Image.alpha_composite(canvas, Image.fromarray(col.astype(np.uint8)))

# Hairline inner highlight on the tile edge
inner = superellipse_mask(S, bx + 3*k, by + 3*k, bw - 6*k, bw - 6*k)
ring = (tile & ~inner).astype(np.float32)
hl = np.zeros((S, S, 4), np.uint8)
hl[..., :3] = 255
hl[..., 3] = (ring * 255 * (0.10 * (1 - yy) + 0.02 * yy)).astype(np.uint8)
canvas = Image.alpha_composite(canvas, Image.fromarray(hl))

# Pastel disc: lavender (top-left) -> pink (bottom-right)
cx, cy = 512*k, (92 + 412)*k
r = 312*k
Y, X = np.mgrid[0:S, 0:S].astype(np.float32) + 0.5
disc = ((X - cx)**2 + (Y - cy)**2) <= r*r
t = np.clip(((X - (cx - r)) + (Y - (cy - r))) / (4 * r), 0, 1)
lav, pink = np.array([188, 186, 240]), np.array([232, 182, 214])
d = np.zeros((S, S, 4), np.float32)
for c in range(3):
    d[..., c] = lav[c] * (1 - t) + pink[c] * t
d[..., 3] = disc * 255
canvas = Image.alpha_composite(canvas, Image.fromarray(d.astype(np.uint8)))

# Navy glyph
navy = (30, 38, 86, 255)
GLYPH = os.environ.get('GLYPH', 'm')

def P(x, y):  # 1024-unit offsets from disc centre -> canvas px
    return (cx + x*k, cy + y*k)

glyph = Image.new('RGBA', (S, S), (0, 0, 0, 0))
g = ImageDraw.Draw(glyph)

def dot(x, y, w):
    X, Y = P(x, y); r = w*k/2
    g.ellipse([X-r, Y-r, X+r, Y+r], fill=navy)

def stroke_line(x1, y1, x2, y2, w):
    g.line([P(x1, y1), P(x2, y2)], fill=navy, width=int(w*k))
    dot(x1, y1, w); dot(x2, y2, w)

def stroke_arch(xc, yc, rad, w):
    # Upper half-circle arch centred at (xc, yc); rad is the stroke centreline.
    X, Y = P(xc, yc); R = (rad + w/2)*k
    g.arc([X-R, Y-R, X+R, Y+R], 180, 360, fill=navy, width=int(w*k))

def rrect(x, y, w, h, r, **kw):
    a = P(x, y); c = P(x+w, y+h)
    g.rounded_rectangle([a[0], a[1], c[0], c[1]], radius=r*k, **kw)

if GLYPH == 'm':
    # Geometric lowercase "m": three stems joined by two round arches.
    w, top, base = 46, -22, 92
    for x in (-116, 0, 116):
        stroke_line(x, top, x, base, w)
    stroke_arch(-58, top, 58, w)
    stroke_arch(58, top, 58, w)
elif GLYPH == 'stack':
    # Stacked profile cards: two outlined behind, one solid in front.
    for dx, dy in [(52, -52), (26, -26)]:
        rrect(-92 + dx, -92 + dy, 160, 160, 38, outline=navy, width=int(22*k))
    rrect(-92, -92, 160, 160, 38, fill=navy)
elif GLYPH == 'M':
    # Rounded capital M.
    w = 44
    pts = [(-110, 100), (-110, -100), (0, 20), (110, -100), (110, 100)]
    g.line([P(*p) for p in pts], fill=navy, width=int(w*k), joint='curve')
    for p in pts:
        dot(*p, w)

canvas = Image.alpha_composite(canvas, glyph)

out = sys.argv[1] if len(sys.argv) > 1 else 'macos/Runner/Assets.xcassets/AppIcon.appiconset'
import os; os.makedirs(out, exist_ok=True)
for size in [16, 32, 64, 128, 256, 512, 1024]:
    canvas.resize((size, size), Image.LANCZOS).save(f'{out}/app_icon_{size}.png', optimize=True)
print('ok')
