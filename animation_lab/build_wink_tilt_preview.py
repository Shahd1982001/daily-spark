"""Standalone wink test using approved blink eye frames and one sparkle."""
from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,base64,json,math,cv2
root=Path(__file__).resolve().parents[1];base=Image.open(root/'assets/mascot/spark.png').convert('RGBA');w,h=base.size
blink=[Image.open(root/f'assets/mascot/blink/blink_{i}.png').convert('RGBA') for i in range(4)]
folder=root/'animation_lab/wink_tilt';folder.mkdir(exist_ok=True)
# Each pose retains the original other eye, face, body and fixed canvas.
sequence=[(0,0)]*6+[(1,0)]*2+[(2,.3)]*2+[(3,.7)]*2+[(3,1)]*10+[(3,.7)]*2+[(2,.3)]*2+[(1,0)]*2+[(0,0)]*6
frames=[]
for i,(stage,shine) in enumerate(sequence):
 out=base.copy()
 if stage:
  # Only one eye changes, using the existing approved blink drawing.
  box=(118,208,245,315);out.paste(blink[stage].crop(box),box)
  if stage==3:
   # Match the visible closed-eye eyelashes in the approved happy expression.
   d=ImageDraw.Draw(out)
   d.line([(155,263),(147,262),(141,257),(138,251)],fill=(83,43,28,255),width=5,joint='curve')
   d.line([(150,262),(147,256),(147,249)],fill=(83,43,28,255),width=4,joint='curve')
 if shine:
  layer=Image.new('RGBA',(w,h));d=ImageDraw.Draw(layer)
  # Small four-point gold glint outside the eye, a temporary wink cue.
  x,y=103,205; r=13*shine; small=3.5*shine
  pts=[(x,y-r),(x+small,y-small),(x+r,y),(x+small,y+small),(x,y+r),(x-small,y+small),(x-r,y),(x-small,y-small)]
  d.polygon(pts,fill=(240,177,73,round(245*shine)))
  d.ellipse((x+17-2*shine,y+10-2*shine,x+17+2*shine,y+10+2*shine),fill=(240,177,73,round(220*shine)))
  out=Image.alpha_composite(out,layer)
 # Same localized upper-silhouette tilt used in the approved smile. The
 # original mascot's head and body are one shape; the effect tapers to zero.
 if stage:
  yy,xx=np.indices((h,w),dtype=np.float32)
  falloff=np.clip((420-yy)/180,0,1);falloff=falloff*falloff*(3-2*falloff)
  angle=np.deg2rad(2.5)*(stage/3)*falloff
  X=xx-273;Y=yy-330
  mapx=(273+np.cos(angle)*X+np.sin(angle)*Y).astype('float32')
  mapy=(330-np.sin(angle)*X+np.cos(angle)*Y).astype('float32')
  out=Image.fromarray(cv2.remap(np.asarray(out),mapx,mapy,cv2.INTER_CUBIC,borderMode=cv2.BORDER_CONSTANT,borderValue=(0,0,0,0)),'RGBA')
 out.thumbnail((292,320),Image.Resampling.LANCZOS)
 p=folder/f'frame_{i:02}.png';out.save(p,optimize=True);frames.append('data:image/png;base64,'+base64.b64encode(p.read_bytes()).decode())
html='''<!doctype html><html lang="ar" dir="rtl"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>غمزة سبارك</title><style>*{box-sizing:border-box}body{margin:0;min-height:100svh;display:grid;place-items:center;padding:20px;background:#fbf6ef;color:#382b26;font-family:system-ui,sans-serif}.card{width:min(100%,460px);background:white;border:1px solid #f0e3d6;border-radius:28px;padding:26px;text-align:center;box-shadow:0 12px 35px #8a563315}.badge{display:inline-block;border-radius:99px;background:#fff0e3;color:#b3582d;padding:7px 14px;font-size:13px;font-weight:bold}h1{font-size:24px;margin:18px 0 8px}p{line-height:1.8;color:#756158}.stage{height:335px;display:grid;place-items:center}img{width:292px;height:320px;object-fit:contain}button{border:0;border-radius:99px;background:#bd603a;color:white;font:700 16px system-ui;padding:13px 25px;cursor:pointer}button:focus-visible{outline:3px solid #916541;outline-offset:3px}.note{font-size:13px}</style></head><body><main class="card"><span class="badge">معاينة منفصلة • مش داخل التطبيق</span><h1>غمزة سبارك 😉✨</h1><p>غمزة ولمعة صغيرة، مع ميلان خفيف زي الابتسامة.</p><div class="stage"><img id="pet" alt="سبارك تغمز بعين واحدة ومعها لمعة صغيرة"></div><button id="replay">شغّلي الحركة من جديد ↻</button><p class="note">تجربة للغمزة فقط؛ نستنوا رأيك 💛</p></main><script>const frames=FRAMES;const img=document.getElementById('pet');let timers=[];function run(){timers.forEach(clearTimeout);timers=[];img.src=frames[0];for(let i=1;i<frames.length;i++)timers.push(setTimeout(()=>img.src=frames[i],500+i*75));}document.getElementById('replay').onclick=run;if(matchMedia('(prefers-reduced-motion: reduce)').matches){img.src=frames[0]}else{run()}</script></body></html>'''.replace('FRAMES',json.dumps(frames))
(root/'web_extra/spark-wink-tilt-preview.html').write_text(html,encoding='utf-8');print('frames',len(frames))
