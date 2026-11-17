"""Create rig layers from the selected transparent Spark artwork (offline)."""
from pathlib import Path
import cv2
import numpy as np
from PIL import Image, ImageDraw

root=Path(__file__).resolve().parents[1]/'assets/mascot'
# Polygon boundaries follow the torso/appendage outline of the 546x600 master.
parts={
 'left_arm':[(63,308),(67,350),(75,393),(99,452),(92,478),(54,491),(16,471),(8,431),(16,382),(34,337)],
 'right_arm':[(483,308),(479,350),(471,393),(447,452),(454,478),(492,491),(530,471),(538,431),(530,382),(512,337)],
 'left_foot':[(145,491),(252,511),(252,593),(136,593)],
 'right_foot':[(294,511),(401,491),(410,593),(294,593)],
}
for mood,source in [('happy','spark.png'),('concerned','spark_concerned.png')]:
 image=Image.open(root/source).convert('RGBA'); w,h=image.size
 sx=w/546; sy=h/600
 body=image.copy()
 for name,points in parts.items():
  mask=Image.new('L',(w,h)); d=ImageDraw.Draw(mask)
  d.polygon([(round(x*sx),round(y*sy)) for x,y in points],fill=255)
  # Include a little extra shoulder/ankle behind the body. It remains hidden
  # at rest and prevents gaps as the limb pivots.
  kernel = np.ones((max(3, round(31*sx)) | 1, max(3, round(31*sy)) | 1), np.uint8)
  expanded = Image.fromarray(cv2.dilate(np.asarray(mask), kernel))
  layer=Image.new('RGBA',(w,h)); layer.paste(image,(0,0),expanded); layer.save(root/f'{mood}_{name}.png',optimize=True)
  alpha=np.asarray(body.getchannel('A')).copy(); alpha[np.asarray(mask)>0]=0
  body.putalpha(Image.fromarray(alpha))
 body.save(root/f'{mood}_body.png',optimize=True)
 # Create a naturally closed-eye body from the original eye area and draw two
 # short eyelids. The eye mask is surrounded by body colour on all sides.
 rgba=np.asarray(body).copy(); bgr=cv2.cvtColor(rgba[:,:,:3],cv2.COLOR_RGB2BGR); mask=np.zeros((h,w),np.uint8)
 for x in [186,359]:
  cv2.ellipse(mask,(round(x*sx),round(263*sy)),(round(63*sx),round(50*sy)),0,0,360,255,-1)
 patched=cv2.inpaint(bgr,mask,15*min(sx,sy),cv2.INPAINT_TELEA)
 for x in [186,359]:
  pts=[]
  for i in range(31):
   t=i/30; xx=x-31+62*t; yy=260+12*(1-(2*t-1)**2)
   pts.append((round(xx*sx),round(yy*sy)))
  cv2.polylines(patched,[np.asarray(pts,np.int32)],False,(43,45,89),max(2,round(7*sx)),cv2.LINE_AA)
 closed=np.dstack((cv2.cvtColor(patched,cv2.COLOR_BGR2RGB),rgba[:,:,3])); Image.fromarray(closed).save(root/f'{mood}_body_closed.png',optimize=True)
 print(mood,w,h)
