"""Paint eyelid frames on exact copies of the selected original artwork.
Only pixels inside the two eye masks change. Canvas, body, color and scale stay
identical. OpenCV is used offline, the Flutter app only reads the PNG frames.
"""
from pathlib import Path
import cv2
import numpy as np
from PIL import Image

root = Path(__file__).resolve().parents[1] / 'assets' / 'mascot'
original = np.asarray(Image.open(root / 'spark.png').convert('RGBA')).copy()
h, w = original.shape[:2]
assert (w, h) == (546, 600), (w, h)
# Eye/eyelash extents, carefully separated from eyebrows and cheeks.
mask = np.zeros((h, w), np.uint8)
polys = [np.array([(123,219),(143,216),(159,210),(207,210),(229,222),(242,241),(243,282),(231,305),(208,313),(165,313),(148,304),(139,288),(137,261),(126,258)],np.int32),
         np.array([(302,241),(315,222),(337,210),(385,210),(407,216),(424,219),(419,258),(408,261),(407,288),(398,304),(381,313),(338,313),(315,305),(303,282)],np.int32)]
cv2.fillPoly(mask, polys, 255)
# Do not touch the pink cheeks where they meet the bottom of the eyes.
yy, xx = np.indices((h, w))
r, g, b = (original[:,:,i].astype(int) for i in range(3))
cheek = (yy >= 300) & (r >= 220) & (r < 248) & (g >= 105) & (g < 170) & (b >= 97) & (b < 160)
mask[cheek] = 0
bgr = cv2.cvtColor(original[:,:,:3], cv2.COLOR_RGB2BGR)
blank = cv2.cvtColor(cv2.inpaint(bgr, mask, 14, cv2.INPAINT_TELEA), cv2.COLOR_BGR2RGB)
# Reconstruct the face color from clean skin on either side, instead of
# pulling pink cheeks into the hidden eyes during inpainting.
for x0, x1 in [(105, 265), (280, 440)]:
    for yy in range(205, 315):
        l = original[yy, x0, :3].astype(float)
        r = original[yy, x1, :3].astype(float)
        for xx in range(x0, x1 + 1):
            if mask[yy, xx]:
                t = (xx-x0)/(x1-x0)
                blank[yy, xx] = np.uint8(l*(1-t) + r*t)
Y, X = np.indices((h, w))
# The frames are individually painted on a full-size, fixed registration.
for n, cover in enumerate([0.0, 0.32, 0.67, 1.0]):
    out = original.copy()
    if cover:
        for cx in (190, 355):
            xoffset = X - cx
            # Curved lid travels down inside each eye; the upper area is
            # filled from the background reconstructed only under that eye.
            lid_y = 215 + 86 * cover + .004 * xoffset*xoffset
            area = (mask > 0) & (abs(xoffset) < 67) & (Y <= lid_y if cover < 1 else True)
            out[:,:,:3][area] = blank[area]
            if cover < 1:
                ends = [int(cx - 45), int(cx + 45)]
                pts = np.array([(x, int(215 + 86*cover + .004*(x-cx)**2)) for x in range(ends[0],ends[1]+1)],np.int32)
            else:
                pts = np.array([(x, int(262 + 12*(1-((x-cx)/35)**2))) for x in range(cx-35,cx+36)],np.int32)
            cv2.polylines(out, [pts], False, (83, 43, 28, 255), 6, cv2.LINE_AA)
            # A small outer lash, directed towards the outside of the face.
            edge = pts[0] if cx == 190 else pts[-1]
            dx = -6 if cx == 190 else 6
            cv2.line(out, tuple(edge), (int(edge[0]+dx), int(edge[1]-5)), (83,43,28,255), 4, cv2.LINE_AA)
    Image.fromarray(out).save(root / 'blink' / f'blink_{n}.png', optimize=True)
