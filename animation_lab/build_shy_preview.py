"""Standalone, subtle smile/glint experiment. Original body is untouched.
Expressions are generated digitally, not individually hand-drawn."""
from pathlib import Path
from PIL import Image,ImageDraw
import cv2, numpy as np, math, base64, json
root=Path(__file__).resolve().parents[1]
base=Image.open(root/'assets/mascot/spark.png').convert('RGBA');arr=np.array(base);h,w=arr.shape[:2]
# Inpaint only the existing mouth, preserving the rest of the original face.
mask=np.zeros((h,w),np.uint8);cv2.rectangle(mask,(235,315),(310,346),255,-1)
clean=cv2.inpaint(arr[:,:,:3],mask,7,cv2.INPAINT_TELEA)
folder=root/'animation_lab/shy';folder.mkdir(exist_ok=True)
frames=[]
# At zero the frame is the exact original. A gentle eased smile grows, holds,
# and returns; body/limbs remain fixed and eye glints are confined to pupils.
levels=[0]*6+[i/12 for i in range(1,13)]+[1]*16+[1-i/12 for i in range(1,13)]+[0]*6
blink=[np.array(Image.open(root/f'assets/mascot/blink/blink_{i}.png').convert('RGBA')) for i in range(4)]
for i,t in enumerate(levels):
 t=t*t*(3-2*t)
 if t==0: out=base.copy()
 else:
  # Reuse the already approved eye drawings; never alter head/body/limbs.
  eye=0 if t<.28 else (1 if t<.65 else 2)
  frame=blink[eye].copy()
  # Carry the lash shapes down to the edge of each closing lid; avoid
  # leaving disconnected fragments in their old positions.
  if eye:
   lid_y=round(215+86*(.32 if eye==1 else .67)+.004*45**2)
   for cx,sign in ((190,-1),(355,1)):
    ex=cx+sign*45
    cv2.line(frame,(ex,lid_y),(ex+sign*11,lid_y-5),(83,43,28,255),5,cv2.LINE_AA)
    cv2.line(frame,(ex+sign*5,lid_y-3),(ex+sign*11,lid_y-14),(83,43,28,255),4,cv2.LINE_AA)
  rgb=frame[:,:,:3].copy();rgb[mask>0]=clean[mask>0]
  # A small closed smile remains gentle and distinctly shy.
  cx=273;half=30-3*t;top=323;u=np.linspace(0,1,120)
  xs=cx-half+2*half*u;ys=top+(16-2*t)*4*u*(1-u)
  pts=np.stack((xs,ys),axis=1).round().astype(np.int32)
  cv2.polylines(rgb,[pts],False,(85,36,22),7,cv2.LINE_AA)
  for pt in (pts[0],pts[-1]):cv2.circle(rgb,tuple(pt),3,(85,36,22),-1,cv2.LINE_AA)
  # Deepen the existing cheeks without drawing over their original highlights.
  yy,xx=np.indices((h,w)); blush=np.zeros((h,w),np.float32)
  for cx in (147,399):
   d=((xx-cx)/34)**2+((yy-334)/27)**2
   blush=np.maximum(blush,np.clip(1-d,0,1))
  weight=(blush*t*.38)[:,:,None]
  color=np.array([245,95,112],np.float32)
  rgb=np.uint8(np.clip(rgb*(1-weight)+color*weight,0,255))
  rendered=np.dstack((rgb,frame[:,:,3]))
  # Her head and body are one shape. A small, localized upper-body bend
  # approximates a head tilt, tapering to zero above the stationary feet.
  yy,xx=np.indices((h,w),dtype=np.float32)
  falloff=np.clip((420-yy)/180,0,1);falloff=falloff*falloff*(3-2*falloff)
  angle=np.deg2rad(1.8)*t*falloff
  X=xx-273;Y=yy-330
  mapx=273+np.cos(angle)*X+np.sin(angle)*Y
  mapy=330-np.sin(angle)*X+np.cos(angle)*Y
  rendered=cv2.remap(rendered,mapx.astype("float32"),mapy.astype("float32"),cv2.INTER_CUBIC,borderMode=cv2.BORDER_CONSTANT,borderValue=(0,0,0,0))
  out=Image.fromarray(rendered,'RGBA')
 out.thumbnail((292,320),Image.Resampling.LANCZOS)
 p=folder/f'frame_{i:02}.png';out.save(p,optimize=True)
 frames.append('data:image/png;base64,'+base64.b64encode(p.read_bytes()).decode())
html='''<!doctype html><html lang="ar" dir="rtl"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>فرحة سبارك</title><style>*{box-sizing:border-box}body{margin:0;min-height:100svh;display:grid;place-items:center;padding:20px;background:#fbf6ef;color:#382b26;font-family:system-ui,sans-serif}.card{width:min(100%,460px);background:white;border:1px solid #f0e3d6;border-radius:28px;padding:26px;text-align:center;box-shadow:0 12px 35px #8a563315}.badge{display:inline-block;border-radius:99px;background:#fff0e3;color:#b3582d;padding:7px 14px;font-size:13px;font-weight:bold}h1{font-size:24px;margin:18px 0 8px}p{line-height:1.8;color:#756158} .stage{height:335px;display:grid;place-items:center}img{width:292px;height:320px;object-fit:contain}button{border:0;border-radius:99px;background:#bd603a;color:white;font:700 16px system-ui;padding:13px 25px;cursor:pointer}button:focus-visible{outline:3px solid #916541;outline-offset:3px}.note{font-size:13px}</style></head><body><main class="card"><span class="badge">معاينة منفصلة • مش داخل التطبيق</span><h1>خجل سبارك 🥹💗</h1><p>عيون هادئة، وابتسامة صغيرة وخدود مورّدة.</p><div class="stage"><img id="pet" alt="سبارك تخجل وتبتسم وخدودها مورّدة"></div><button id="replay">شغّلي الحركة من جديد ↻</button><p class="note">نجربوا تعبير واحد ونستنوا رأيك 💛</p></main><script>const frames=FRAMES;const img=document.getElementById('pet');let timers=[];function run(){timers.forEach(clearTimeout);timers=[];img.src=frames[0];for(let i=1;i<frames.length;i++)timers.push(setTimeout(()=>img.src=frames[i],500+i*65));}document.getElementById('replay').onclick=run;if(matchMedia('(prefers-reduced-motion: reduce)').matches){img.src=frames[0]}else{run()}</script></body></html>'''.replace('FRAMES',json.dumps(frames))
(root/'web_extra/spark-shy-preview.html').write_text(html,encoding='utf-8')
print('frames',len(frames))
