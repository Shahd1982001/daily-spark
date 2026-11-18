"""Standalone expression study: eyebrow raise and surprised mouth."""
from pathlib import Path
from PIL import Image
import cv2,numpy as np,base64,json
root=Path(__file__).resolve().parents[1];base=Image.open(root/'assets/mascot/spark.png').convert('RGBA');a=np.asarray(base);h,w=a.shape[:2]
mask=np.zeros((h,w),np.uint8)
for p1,p2 in [((168,170),(210,198)),((334,170),(378,198)),((235,315),(310,349))]:cv2.rectangle(mask,p1,p2,255,-1)
clean=cv2.inpaint(a[:,:,:3],mask,8,cv2.INPAINT_TELEA);folder=root/'animation_lab/surprise';folder.mkdir(exist_ok=True)
levels=[0]*6+[i/12 for i in range(1,13)]+[1]*14+[1-i/12 for i in range(1,13)]+[0]*6
frames=[]
for i,t in enumerate(levels):
 t=t*t*(3-2*t)
 if not t:out=base.copy()
 else:
  rgb=a[:,:,:3].copy();rgb[mask>0]=clean[mask>0]
  # Brows follow the original pair; at the peak they rise a little.
  for cx,mirror in [(190,1),(355,-1)]:
   x=np.linspace(cx-12,cx+12,35);u=(x-cx)/12
   y=185-11*t-5*(1-u*u)+mirror*u*1.5
   pts=np.stack((x,y),axis=1).round().astype(np.int32)
   cv2.polylines(rgb,[pts],False,(91,43,27),7,cv2.LINE_AA)
   for pt in (pts[0],pts[-1]):cv2.circle(rgb,tuple(pt),3,(91,43,27),-1,cv2.LINE_AA)
  # The original smile gently transitions into a small surprised O.
  cx=273; top=323; width=30*(1-t)+12*t; bottom=340+5*t
  u=np.linspace(0,1,100);xs=cx-width+2*width*u
  if t<.30:
   ys=top+16*4*u*(1-u);cv2.polylines(rgb,[np.stack((xs,ys),axis=1).round().astype(np.int32)],False,(85,36,22),7,cv2.LINE_AA)
  else:
   openness=(t-.30)/.70
   edge=top+10*openness
   topcurve=edge+(9*(1-openness)-10*openness)*np.sqrt(np.maximum(0,4*u*(1-u)))
   lowcurve=edge+(16*(1-openness)+10*openness)*np.sqrt(np.maximum(0,4*u*(1-u)))
   pts=np.r_[np.stack((xs,topcurve),axis=1),np.stack((xs[::-1],lowcurve[::-1]),axis=1)].round().astype(np.int32)
   cv2.fillPoly(rgb,[pts],(85,36,22),cv2.LINE_AA)
  out=Image.fromarray(np.dstack((rgb,a[:,:,3])),'RGBA')
 out.thumbnail((292,320),Image.Resampling.LANCZOS);p=folder/f'frame_{i:02}.png';out.save(p,optimize=True);frames.append('data:image/png;base64,'+base64.b64encode(p.read_bytes()).decode())
html='''<!doctype html><html lang="ar" dir="rtl"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>استغراب سبارك</title><style>*{box-sizing:border-box}body{margin:0;min-height:100svh;display:grid;place-items:center;padding:20px;background:#fbf6ef;color:#382b26;font-family:system-ui,sans-serif}.card{width:min(100%,460px);background:white;border:1px solid #f0e3d6;border-radius:28px;padding:26px;text-align:center;box-shadow:0 12px 35px #8a563315}.badge{display:inline-block;border-radius:99px;background:#fff0e3;color:#b3582d;padding:7px 14px;font-size:13px;font-weight:bold}h1{font-size:24px;margin:18px 0 8px}p{line-height:1.8;color:#756158}.stage{height:335px;display:grid;place-items:center}img{width:292px;height:320px;object-fit:contain}button{border:0;border-radius:99px;background:#bd603a;color:white;font:700 16px system-ui;padding:13px 25px;cursor:pointer}button:focus-visible{outline:3px solid #916541;outline-offset:3px}.note{font-size:13px}</style></head><body><main class="card"><span class="badge">معاينة منفصلة • مش داخل التطبيق</span><h1>استغراب سبارك 💛</h1><p>حواجبها تطلع شوية، وفمها يتغيّر لتعبير الاستغراب.</p><div class="stage"><img id="pet" alt="سبارك ترفع حواجبها وتتفاعل باستغراب"></div><button id="replay">شغّلي الحركة من جديد ↻</button><p class="note">تجربة لتعبير واحد؛ نستنوا رأيك 🌷</p></main><script>const frames=FRAMES;const img=document.getElementById('pet');let timers=[];function run(){timers.forEach(clearTimeout);timers=[];img.src=frames[0];for(let i=1;i<frames.length;i++)timers.push(setTimeout(()=>img.src=frames[i],500+i*70));}document.getElementById('replay').onclick=run;if(matchMedia('(prefers-reduced-motion: reduce)').matches){img.src=frames[0]}else{run()}</script></body></html>'''.replace('FRAMES',json.dumps(frames));(root/'web_extra/spark-surprise-preview.html').write_text(html,encoding='utf-8');print('frames',len(frames))
