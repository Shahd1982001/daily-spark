"""Standalone digitally generated cute-angry expression test."""
from pathlib import Path
from PIL import Image,ImageDraw
import cv2,numpy as np,base64,json
root=Path(__file__).resolve().parents[1];base=Image.open(root/'assets/mascot/spark.png').convert('RGBA');a=np.asarray(base);h,w=a.shape[:2];yy,xx=np.indices((h,w))
mask=np.zeros((h,w),np.uint8)
for p1,p2 in [((168,170),(210,203)),((334,170),(378,203)),((235,315),(310,352))]:cv2.rectangle(mask,p1,p2,255,-1)
clean=cv2.inpaint(a[:,:,:3],mask,8,cv2.INPAINT_TELEA);folder=root/'animation_lab/scared';folder.mkdir(exist_ok=True)
levels=[0]*6+[i/14 for i in range(1,15)]+[1]*16+[1-i/14 for i in range(1,15)]+[0]*6
frames=[]
for i,t in enumerate(levels):
 t=t*t*(3-2*t)
 if not t:out=base.copy()
 else:
  rgb=a[:,:,:3].copy();rgb[mask>0]=clean[mask>0]
  # Brows slope towards the center as she gets cross, preserving cute scale.
  for cx,side in ((190,1),(355,-1)):
   x=np.linspace(cx-12,cx+12,35);u=(x-cx)/12
   original=185-5*(1-u*u)+side*u*1.5
   angry=175-side*6*u-5*(1-u*u)
   y=original*(1-t)+angry*t
   pts=np.stack((x,y),axis=1).round().astype(np.int32)
   cv2.polylines(rgb,[pts],False,(91,43,27),7,cv2.LINE_AA)
   for pt in (pts[0],pts[-1]):cv2.circle(rgb,tuple(pt),3,(91,43,27),-1,cv2.LINE_AA)
  # A tiny worried quiver, retaining the familiar mouth color and location.
  x=np.linspace(248,298,100);u=(x-273)/25
  smile=323+16*(1-u*u)
  anxious=334+2.4*np.sin((u+1)*np.pi*2)
  y=smile*(1-t)+anxious*t
  pts=np.stack((x,y),axis=1).round().astype(np.int32)
  cv2.polylines(rgb,[pts],False,(85,36,22),6,cv2.LINE_AA)
  for pt in (pts[0],pts[-1]):cv2.circle(rgb,tuple(pt),3,(85,36,22),-1,cv2.LINE_AA)
  out=Image.fromarray(np.dstack((rgb,a[:,:,3])),'RGBA')
  # One tiny sweat-drop cue, separate from the original artwork.
  if t>.35:
   alpha=round(220*min(1,(t-.35)/.4));lay=Image.new('RGBA',(w,h));d=ImageDraw.Draw(lay)
   d.polygon([(439,183),(432,196),(431,202),(435,207),(441,206),(444,202),(443,196)],fill=(121,191,215,alpha))
   d.ellipse((435,194,438,200),fill=(235,251,255,alpha))
   out=Image.alpha_composite(out,lay)
 out.thumbnail((292,320),Image.Resampling.LANCZOS);p=folder/f'frame_{i:02}.png';out.save(p,optimize=True);frames.append('data:image/png;base64,'+base64.b64encode(p.read_bytes()).decode())
html='''<!doctype html><html lang="ar" dir="rtl"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>خوف سبارك</title><style>*{box-sizing:border-box}body{margin:0;min-height:100svh;display:grid;place-items:center;padding:20px;background:#fbf6ef;color:#382b26;font-family:system-ui,sans-serif}.card{width:min(100%,460px);background:white;border:1px solid #f0e3d6;border-radius:28px;padding:26px;text-align:center;box-shadow:0 12px 35px #8a563315}.badge{display:inline-block;border-radius:99px;background:#fff0e3;color:#b3582d;padding:7px 14px;font-size:13px;font-weight:bold}h1{font-size:24px;margin:18px 0 8px}p{line-height:1.8;color:#756158}.stage{height:335px;display:grid;place-items:center}img{width:292px;height:320px;object-fit:contain}button{border:0;border-radius:99px;background:#bd603a;color:white;font:700 16px system-ui;padding:13px 25px;cursor:pointer}button:focus-visible{outline:3px solid #916541;outline-offset:3px}.note{font-size:13px}</style></head><body><main class="card"><span class="badge">معاينة منفصلة • مش داخل التطبيق</span><h1>خايفة شوية 😳</h1><p>ملامح خوف بسيطة مع قطرة صغيرة.</p><div class="stage"><img id="pet" alt="سبارك خايفة بتعبير لطيف"></div><button id="replay">شغّلي الحركة من جديد ↻</button><p class="note">تجربة لتعبير واحد؛ نستنوا رأيك 🌷</p></main><script>const frames=FRAMES;const img=document.getElementById('pet');let timers=[];function run(){timers.forEach(clearTimeout);timers=[];img.src=frames[0];for(let i=1;i<frames.length;i++)timers.push(setTimeout(()=>img.src=frames[i],500+i*70));}document.getElementById('replay').onclick=run;if(matchMedia('(prefers-reduced-motion: reduce)').matches){img.src=frames[0]}else{run()}</script></body></html>'''.replace('FRAMES',json.dumps(frames));(root/'web_extra/spark-scared-preview.html').write_text(html,encoding='utf-8');print('frames',len(frames))
