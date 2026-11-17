"""Build 16 consistently registered walk frames from the selected side artwork."""
from pathlib import Path
import math
import numpy as np
from PIL import Image

root = Path(__file__).resolve().parents[1] / 'assets' / 'mascot'
# This is a derived copy of the user-selected side illustration. No frame uses
# a separately generated face, which keeps the character stable while walking.
source = Image.open(root / 'spark_side.png').convert('RGBA')
arr = np.asarray(source).copy()
h, w = arr.shape[:2]
y, x = np.indices((h, w))
# Curve follows the lower body outline. Feet overlap slightly behind the body.
curve = np.interp(np.arange(w), [0, 50, 85, 115, 150, 190, 225, 265, 305, 340, 375, 410, 452],
                  [330, 425, 470, 490, 506, 515, 520, 518, 509, 495, 468, 415, 330])[None, :] + 9
def layer(mask):
    a = arr.copy()
    a[:,:,3] = np.where(mask, a[:,:,3], 0)
    return Image.fromarray(a)
body = layer(~(((x > 85) & (x < 207) | (x > 245) & (x < 361)) & (y > curve)))
left = layer((y >= curve - 12) & (x > 85) & (x < 207) & (y > 495))
right = layer((y >= curve - 12) & (x > 245) & (x < 361) & (y > 495))
for i in range(16):
    step = math.sin(2 * math.pi * i / 16)
    canvas = Image.new('RGBA', source.size)
    # Broader alternating stride and a brief lift make footfalls visible at
    # phone size; both feet remain behind the unchanged body.
    r = right.rotate(17 * step, resample=Image.Resampling.BICUBIC, center=(300, 500))
    l = left.rotate(-17 * step, resample=Image.Resampling.BICUBIC, center=(150, 500))
    canvas.alpha_composite(r, (round(9 * step), -round(12 * max(0, -step))))
    canvas.alpha_composite(l, (-round(9 * step), -round(12 * max(0, step))))
    canvas.alpha_composite(body)
    canvas.save(root / 'frames' / f'walk_cycle_{i:02}.png', optimize=True)
