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
folder=root/'animation_lab/happy_laugh';folder.mkdir(exist_ok=True)
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
  eye=min(3,round(t*3));frame=blink[eye].copy();rgb=frame[:,:,:3].copy();rgb[mask>0]=clean[mask>0]
  # Rounded open smiling mouth, dark interior with a small warm tongue.
  cx=273;half=30+7*t;top=323;bottom=339+22*t
  u=np.linspace(0,1,120)
  xs=cx-half+2*half*u
  upper=top+9*(4*u*(1-u))
  lower=top+(bottom-top)*(4*u*(1-u))
  shape=np.r_[np.stack((xs,upper),axis=1),np.stack((xs[::-1],lower[::-1]),axis=1)].round().astype(np.int32)
  cv2.fillPoly(rgb,[shape],(87,38,28),cv2.LINE_AA)
  if t>.32:
   # Tongue remains within the filled shape by compositing through a mask.
   tongue=np.zeros((h,w),np.uint8)
   cv2.ellipse(tongue,(cx,round(bottom+3)),(round(16*t),round(10*t)),0,0,360,255,-1,cv2.LINE_AA)
   inside=np.zeros((h,w),np.uint8);cv2.fillPoly(inside,[shape],255)
   rgb[(tongue>0)&(inside>0)]=(205,108,92)
  cv2.polylines(rgb,[shape],True,(87,38,28),3,cv2.LINE_AA)
  out=Image.fromarray(np.dstack((rgb,frame[:,:,3])),'RGBA')
 out.thumbnail((292,320),Image.Resampling.LANCZOS)
 p=folder/f'frame_{i:02}.png';out.save(p,optimize=True)
 frames.append('data:image/png;base64,'+base64.b64encode(p.read_bytes()).decode())
html='''<!doctype html><html lang="ar" dir="rtl"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>فرحة سبارك</title><style>*{box-sizing:border-box}body{margin:0;min-height:100svh;display:grid;place-items:center;padding:20px;background:#fbf6ef;color:#382b26;font-family:system-ui,sans-serif}.card{width:min(100%,460px);background:white;border:1px solid #f0e3d6;border-radius:28px;padding:26px;text-align:center;box-shadow:0 12px 35px #8a563315}.badge{display:inline-block;border-radius:99px;background:#fff0e3;color:#b3582d;padding:7px 14px;font-size:13px;font-weight:bold}h1{font-size:24px;margin:18px 0 8px}p{line-height:1.8;color:#756158} .stage{height:335px;display:grid;place-items:center}img{width:292px;height:320px;object-fit:contain}button{border:0;border-radius:99px;background:#bd603a;color:white;font:700 16px system-ui;padding:13px 25px;cursor:pointer}button:focus-visible{outline:3px solid #916541;outline-offset:3px}.note{font-size:13px}</style></head><body><main class="card"><span class="badge">معاينة منفصلة • مش داخل التطبيق</span><h1>ضحكة سبارك 💛</h1><p>العيون تتسكر والفم يفتح بابتسامة.</p><div class="stage"><img id="pet" alt="سبارك تسكر عيونها وتضحك"></div><button id="replay">شغّلي الحركة من جديد ↻</button><p class="note">نجربوا تعبير واحد ونستنوا رأيك 💛</p></main><script>const frames=FRAMES;const img=document.getElementById('pet');let timers=[];function run(){timers.forEach(clearTimeout);timers=[];img.src=frames[0];for(let i=1;i<frames.length;i++)timers.push(setTimeout(()=>img.src=frames[i],500+i*65));}document.getElementById('replay').onclick=run;if(matchMedia('(prefers-reduced-motion: reduce)').matches){img.src=frames[0]}else{run()}</script></body></html>'''.replace('FRAMES',json.dumps(frames))
(root/'web_extra/spark-happy-laugh-preview.html').write_text(html,encoding='utf-8')
print('frames',len(frames))
