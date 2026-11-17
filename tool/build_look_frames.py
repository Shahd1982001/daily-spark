"""Create registered look frames by painting only the eye interiors offline.
All frames keep the same original canvas, outer eye outlines, and body pixels.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageChops

root = Path(__file__).resolve().parents[1] / 'assets' / 'mascot'
original = Image.open(root / 'spark.png').convert('RGBA')
w, h = original.size
SCALE = 4

def ellipse(box):
    mask = Image.new('L', (w*SCALE, h*SCALE))
    ImageDraw.Draw(mask).ellipse(tuple(int(x*SCALE) for x in box), fill=255)
    return mask.resize((w,h), Image.Resampling.LANCZOS)

# Keep the outlines, eyelashes and the body unchanged. Iris details are
# copied from the original, then clipped inside the same original eye shape.
eyes = [((150,225,237,310),(164,228,235,303)),
        ((307,225,395,310),(308,228,379,303))]
for direction, sign in [('left', -1), ('right', 1)]:
    for index, amount in enumerate((3, 6, 9), 1):
        result = original.copy()
        for sclera_box, iris_box in eyes:
            sclera = ellipse(sclera_box)
            iris = ellipse(iris_box)
            white = Image.new('RGBA', original.size, (246,244,235,255))
            result.paste(white, (0,0), sclera)
            pupil = Image.new('RGBA', original.size)
            pupil.paste(original, (0,0), iris)
            shifted = Image.new('RGBA', original.size)
            shifted.alpha_composite(pupil, (sign * amount,0))
            shifted.putalpha(ImageChops.multiply(shifted.getchannel('A'), sclera))
            result.alpha_composite(shifted)
        result.save(root / 'look' / f'{direction}_{index}.png', optimize=True)
