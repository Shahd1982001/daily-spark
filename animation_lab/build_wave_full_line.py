"""Isolated experiment for hand tips rising in an arc and returning.
The original body and feet remain fixed; frames are rendered offline from the
original arms. This is a draft, not a hand-drawn production animation.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import base64,json,math
import numpy as np
import cv2
root=Path(__file__).resolve().parents[1]
base=Image.open(root/'assets/mascot/spark.png').convert('RGBA')
pix=np.asarray(base).copy();w,h=base.size
# Split arms outside the *outer* edge of the body outline. The entire original
# bold body contour remains in the fixed body layer, even when arms rise.
y_grid,x_grid=np.indices((h,w))
y_keys=[300,310,320,330,340,350,360,370,380,390,400,410,420,430,440,450,460,470,480,490,500]
x_keys=[64,63,62,62,62,62,62,64,65,67,70,73,77,82,87,93,101,110,120,132,145]
edge=np.interp(np.arange(h),y_keys,x_keys)[:,None]
zone=(y_grid>=315)&(y_grid<490)
# Clip the extracted arm to its original hand area as well; otherwise tiny
# fragments of the body outline can travel with the raised hand.
arm_limit=Image.new('L',(w,h));draw=ImageDraw.Draw(arm_limit)
left=[(0,300),(66,300),(63,320),(65,350),(72,390),(82,420),(100,450),(105,490),(0,490)]
draw.polygon(left,fill=255)
right_limit=Image.new('L',(w,h));ImageDraw.Draw(right_limit).polygon([(545-x,y) for x,y in left],fill=255)
lm=np.zeros((h,w),dtype=bool)
rm=zone & (x_grid > (545-edge)) & (np.asarray(right_limit)>0)

body=pix.copy();body[:,:,3]=np.where(lm|rm,0,body[:,:,3]);body=Image.fromarray(body)
def masked(mask):
 a=pix.copy();a[:,:,3]=np.where(mask,a[:,:,3],0)
 # Discard the light background pixels left around the original cutout.
 rgb=a[:,:,:3].astype(int)
 fringe=(rgb.min(axis=2)>185)&((rgb.max(axis=2)-rgb.min(axis=2))<32)&(a[:,:,3]<220)
 a[:,:,3][fringe]=0
 # RGB under transparent pixels must not contain the white source backdrop;
 # otherwise resampling mixes it into visible arm edges.
 a[:,:,:3][a[:,:,3]==0]=(81,42,27)
 return Image.fromarray(a)
def padded(im):
 result=Image.new('RGBA',(w+300,h+300));result.alpha_composite(im,(150,150));return result
left_original=masked(lm);right_original=masked(rm)
# Curve correction is applied only to the inside of the arm: attachment and
# fingertip stay at the same coordinates. This makes the raised pose a little
# straighter without changing the already-approved fingertip path.
def straighten(im, side, amount):
 rgba=np.asarray(im)
 yy,xx=np.indices((h,w),dtype=np.float32)
 # The original lower-arm center bows inward. Progressively remap its
 # cross-sections around a straighter centerline, retaining the attachment
 # and tip position and the original color/detail pixels.
 samples=np.array([320,330,340,350,360,370,380,390,400,410,420,430,440,450,460,470,480],dtype=np.float32)
 centers=np.array([60,57,54.5,52,51,49.5,48.5,48,48,49,50,53,56.5,60.5,62.5,62,63],dtype=np.float32)
 if side<0: centers=545-centers
 original=np.interp(yy[:,0],samples,centers).astype('float32')[:,None]
 desired=np.interp(yy[:,0],[320,480],([60,63] if side>0 else [485,482])).astype('float32')[:,None]
 # Leave the rounded end untouched, so the approved path of its tip is fixed.
 taper=np.clip((465-yy)/30,0,1)*np.clip((yy-315)/20,0,1)
 desired=original+(desired-original)*amount*taper
 # Fill out the narrow middle of a raised arm so the visible hand does not
 # turn into a crescent or pointed sliver. Each row keeps its original pixels.
 widths=np.array([7,15,20,27,33,38,44,49,55,61,65,71,76,80,78,65,45],dtype=np.float32)
 fuller=np.array([10,27,35,43,47,51,55,58,60,64,67,71,76,80,78,65,45],dtype=np.float32)
 source_width=np.interp(yy[:,0],samples,widths).astype('float32')[:,None]
 full_width=np.interp(yy[:,0],samples,fuller).astype('float32')[:,None]
 amount_by_y=np.clip((yy-315)/15,0,1)*np.clip((485-yy)/20,0,1)
 width=1 + amount*amount_by_y*(full_width/source_width-1)*1.55
 # Extend the inward side while preserving the outside edge and tip path.
 # The added width supplies the lower edge missing from the clipped original.
 inward=12*amount*amount_by_y
 desired=desired-inward
 xmap=original + (xx-desired)/width
 out=cv2.remap(rgba,xmap,yy,cv2.INTER_CUBIC,borderMode=cv2.BORDER_CONSTANT,borderValue=(0,0,0,0))
 # Build a continuous dark outline behind the complete arm silhouette.
 # The fixed original body is composited on top, hiding the shoulder seam.
 alpha=out[:,:,3]
 solid=(alpha>64).astype(np.uint8)*255
 solid=cv2.morphologyEx(solid,cv2.MORPH_CLOSE,np.ones((3,3),np.uint8))
 border=cv2.dilate(solid,cv2.getStructuringElement(cv2.MORPH_ELLIPSE,(9,9)))
 back=np.zeros_like(out);back[:,:,:3]=(87,43,29);back[:,:,3]=border
 outlined=Image.fromarray(back,'RGBA');outlined.alpha_composite(Image.fromarray(out,'RGBA'))
 return padded(outlined)

# Consistent canvas leaves room for arms and keeps the body at one fixed scale.
W,H=806,730;ox,oy=130,65
out=root/'animation_lab/wave_full_line';out.mkdir(parents=True,exist_ok=True);encoded=[]
# Pause at rest, lift in a circular arc, pause, then return by the same arc.
angles=[0]*7
for i in range(1,73):
 t=i/72; angles.append(120*(0.5-0.5*math.cos(4*math.pi*t)))
angles += [0]*7
for i,angle in enumerate(angles):
 canvas=Image.new('RGBA',(W,H))
 if angle==0:
  canvas.alpha_composite(base,(ox,oy))
 else:
  amount=math.sin((angle/148)*math.pi/2)
  
  R=straighten(right_original,-1,amount).rotate(angle,resample=Image.Resampling.BICUBIC,center=(479+150,320+150))
  canvas.alpha_composite(R,(ox-150,oy-150));canvas.alpha_composite(body,(ox,oy))
 canvas.thumbnail((320,314),Image.Resampling.LANCZOS)
 path=out/f'frame_{i:02}.png';canvas.save(path,optimize=True)
 encoded.append('data:image/png;base64,'+base64.b64encode(path.read_bytes()).decode())
html='''<!doctype html><html lang="ar" dir="rtl"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>معاينة التلويحة</title><style>
:root{font-family:system-ui,-apple-system,sans-serif;color:#382b26;background:#fbf6ef}*{box-sizing:border-box}body{margin:0;display:grid;place-items:center;min-height:100svh;padding:18px}.card{width:min(100%,460px);background:#fff;border:1px solid #f0e3d6;border-radius:28px;padding:24px;text-align:center;box-shadow:0 12px 35px #8a563315}.badge{color:#b3582d;background:#fff0e3;border-radius:99px;padding:7px 14px;display:inline-block;font-weight:700;font-size:13px}h1{font-size:24px;margin:16px 0 8px}p{font-size:15px;line-height:1.8;color:#756158;margin:0}.stage{height:320px;display:flex;align-items:flex-end;justify-content:center;position:relative;margin:8px auto 0}.stage:after{content:"";position:absolute;bottom:33px;width:88%;height:7px;border-radius:50%;background:#e7d5c6;z-index:0}img{position:relative;z-index:1;width:346px;height:314px;object-fit:contain;margin-bottom:0}button{background:#bd603a;color:white;border:0;border-radius:99px;font:700 16px system-ui;padding:13px 25px;cursor:pointer;margin-top:18px}button:focus-visible{outline:3px solid #916541;outline-offset:3px}.note{font-size:13px;margin-top:16px}
</style></head><body><main class="card"><span class="badge">معاينة منفصلة • مش داخل التطبيق</span><h1>تلويحة سبارك 👋</h1><p>نفس الحركة، مع تكملة رسمة اليد والخط من تحت وقت الرفع.</p><div class="stage"><img id="pet" alt="مخلوقك يرفع يديه ويرجعهم"></div><button id="replay">شغّلي الحركة من جديد ↻</button><p class="note">تجربة منفصلة؛ اليد الأصلية معدلة رقمياً والخط مكمل وقت الرفع.</p></main><script>const frames=FRAMES;const img=document.getElementById('pet');let timers=[];function run(){timers.forEach(clearTimeout);timers=[];img.src=frames[0];for(let i=1;i<frames.length;i++)timers.push(setTimeout(()=>{img.src=frames[i]},250+i*28));}document.getElementById('replay').onclick=run;if(matchMedia('(prefers-reduced-motion: reduce)').matches){img.src=frames[0]}else{run();}</script></body></html>'''.replace('FRAMES',json.dumps(encoded))
(root/'web_extra/spark-wave-full-line-preview.html').write_text(html,encoding='utf-8')
print('frames',len(angles))
