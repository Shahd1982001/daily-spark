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
# Arms stay attached behind the outside contour of the original body.
left=[(0,300),(66,300),(63,320),(65,350),(72,390),(82,420),(100,450),(105,490),(0,490)]
left_mask=Image.new('L',(w,h));ImageDraw.Draw(left_mask).polygon(left,fill=255)
right_mask=Image.new('L',(w,h));ImageDraw.Draw(right_mask).polygon([(545-x,y) for x,y in left],fill=255)
lm=np.asarray(left_mask)>0;rm=np.asarray(right_mask)>0
body=pix.copy();body[:,:,3]=np.where(lm|rm,0,body[:,:,3]);body=Image.fromarray(body)
def masked(mask):
 a=pix.copy();a[:,:,3]=np.where(mask,a[:,:,3],0)
 # Discard the light background pixels left around the original cutout.
 rgb=a[:,:,:3].astype(int)
 fringe=(rgb.min(axis=2)>185)&((rgb.max(axis=2)-rgb.min(axis=2))<32)&(a[:,:,3]<220)
 a[:,:,3][fringe]=0
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
 u=np.clip((yy-320)/125,0,1)
 shift=side*8*amount*np.sin(np.pi*u)
 out=cv2.remap(rgba,xx-shift,yy,cv2.INTER_CUBIC,borderMode=cv2.BORDER_CONSTANT,borderValue=(0,0,0,0))
 return padded(Image.fromarray(out))
# Consistent canvas leaves room for arms and keeps the body at one fixed scale.
W,H=806,730;ox,oy=130,65
out=root/'animation_lab/hand_arc_refined';out.mkdir(parents=True,exist_ok=True);encoded=[]
# Pause at rest, lift in a circular arc, pause, then return by the same arc.
angles=[0]*5
for i in range(1,25):
 t=i/24;angles.append(148*(t*t*(3-2*t)))
angles += [148]*6
for i in range(1,25):
 t=i/24;angles.append(148*(1-t*t*(3-2*t)))
angles += [0]*5
for i,angle in enumerate(angles):
 canvas=Image.new('RGBA',(W,H))
 if angle==0:
  canvas.alpha_composite(base,(ox,oy))
 else:
  amount=math.sin((angle/148)*math.pi/2)
  L=straighten(left_original,1,amount).rotate(-angle,resample=Image.Resampling.BICUBIC,center=(67+150,320+150))
  R=straighten(right_original,-1,amount).rotate(angle,resample=Image.Resampling.BICUBIC,center=(479+150,320+150))
  canvas.alpha_composite(L,(ox-150,oy-150));canvas.alpha_composite(R,(ox-150,oy-150));canvas.alpha_composite(body,(ox,oy))
 canvas.thumbnail((320,314),Image.Resampling.LANCZOS)
 path=out/f'frame_{i:02}.png';canvas.save(path,optimize=True)
 encoded.append('data:image/png;base64,'+base64.b64encode(path.read_bytes()).decode())
html='''<!doctype html><html lang="ar" dir="rtl"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>معاينة حركة اليدين</title><style>
:root{font-family:system-ui,-apple-system,sans-serif;color:#382b26;background:#fbf6ef}*{box-sizing:border-box}body{margin:0;display:grid;place-items:center;min-height:100svh;padding:18px}.card{width:min(100%,460px);background:#fff;border:1px solid #f0e3d6;border-radius:28px;padding:24px;text-align:center;box-shadow:0 12px 35px #8a563315}.badge{color:#b3582d;background:#fff0e3;border-radius:99px;padding:7px 14px;display:inline-block;font-weight:700;font-size:13px}h1{font-size:24px;margin:16px 0 8px}p{font-size:15px;line-height:1.8;color:#756158;margin:0}.stage{height:320px;display:flex;align-items:flex-end;justify-content:center;position:relative;margin:8px auto 0}.stage:after{content:"";position:absolute;bottom:33px;width:88%;height:7px;border-radius:50%;background:#e7d5c6;z-index:0}img{position:relative;z-index:1;width:346px;height:314px;object-fit:contain;margin-bottom:0}button{background:#bd603a;color:white;border:0;border-radius:99px;font:700 16px system-ui;padding:13px 25px;cursor:pointer;margin-top:18px}button:focus-visible{outline:3px solid #916541;outline-offset:3px}.note{font-size:13px;margin-top:16px}
</style></head><body><main class="card"><span class="badge">معاينة منفصلة • مش داخل التطبيق</span><h1>اليدين: تجربة أنعم</h1><p>نفس المسار اللي عجبك، بيدين أنعم وتفاصيل أنظف.</p><div class="stage"><img id="pet" alt="مخلوقك يرفع يديه ويرجعهم"></div><button id="replay">شغّلي الحركة من جديد ↻</button><p class="note">تجربة لمسار اليدين فقط؛ ننتظر رأيك.</p></main><script>const frames=FRAMES;const img=document.getElementById('pet');let timers=[];function run(){timers.forEach(clearTimeout);timers=[];img.src=frames[0];for(let i=1;i<frames.length;i++)timers.push(setTimeout(()=>{img.src=frames[i]},400+i*50));}document.getElementById('replay').onclick=run;if(matchMedia('(prefers-reduced-motion: reduce)').matches){img.src=frames[0]}else{run();}</script></body></html>'''.replace('FRAMES',json.dumps(encoded))
(root/'web_extra/spark-hand-refined-preview.html').write_text(html,encoding='utf-8')
print('frames',len(angles))
