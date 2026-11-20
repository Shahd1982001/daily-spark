"""Standalone single-hand key-pose wave study from separate generated drawings.
No crossfade, no pose rotation; sparse frames are not a smooth final animation.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFilter
import numpy as np,cv2,base64,json
root=Path(__file__).resolve().parents[1];base=Image.open(root/'assets/mascot/spark.png').convert('RGBA');a=np.asarray(base).copy();h,w=a.shape[:2];Y,X=np.indices((h,w))
# Preserve original body outline and opposite hand; only the right-side
# resting hand is removed for the separately drawn wave poses.
ys=[300,310,320,330,340,350,360,370,380,390,400,410,420,430,440,450,460,470,480,490,500];xs=[64,63,62,62,62,62,62,64,65,67,70,73,77,82,87,93,101,110,120,132,145];edge=np.interp(np.arange(h),ys,xs)[:,None]
remove=(Y>=315)&(Y<490)&(X>545-edge);a[:,:,3]=np.where(remove,0,a[:,:,3]);body=Image.fromarray(a)
folder=root/'animation_lab/wave_key';folder.mkdir(exist_ok=True)
# Both references are generated full illustrations, but only their wave-arm
# artwork is composited beneath the exact original body in a fixed canvas.
poses=[base]
for name in ('out','up'):
 raw=cv2.imread(str(root/f'animation_lab/wave_{name}_clean_ref.png'))
 rgba=cv2.cvtColor(raw,cv2.COLOR_BGR2RGBA);H,W=rgba.shape[:2];yy,xx=np.indices((H,W))
 body_edge=np.interp(np.arange(H),[250,320,380,440,500,560,620,680,740],[780,809,829,845,859,865,861,846,814])[:,None]
 # Take arm outside the body boundary only; remove neutral white backdrop.
 zone=(xx>body_edge-5)&(yy>230)&(yy<720);rgb=rgba[:,:,:3].astype(int)
 notwhite=~((rgb.min(2)>190)&((rgb.max(2)-rgb.min(2))<35));rgba[:,:,3]=np.where(zone&notwhite,255,0).astype('uint8')
 rgba[:,:,:3][rgba[:,:,3]==0]=(85,42,27)
 arm=Image.fromarray(rgba).resize((round(W*.55),round(H*.55)),Image.Resampling.LANCZOS)
 canvas=Image.new('RGBA',(w,h));canvas.alpha_composite(arm,(5,0));canvas.alpha_composite(body)
 poses.append(canvas)
frames=[]
for i,im in enumerate(poses):
 im=im.copy();im.thumbnail((292,320),Image.Resampling.LANCZOS);p=folder/f'pose_{i}.png';im.save(p,optimize=True);frames.append('data:image/png;base64,'+base64.b64encode(p.read_bytes()).decode())
html='''<!doctype html><html lang="ar" dir="rtl"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>تجربة تلويحة سبارك</title><style>*{box-sizing:border-box}body{margin:0;min-height:100svh;display:grid;place-items:center;padding:20px;background:#fbf6ef;color:#382b26;font-family:system-ui,sans-serif}.card{width:min(100%,460px);background:white;border:1px solid #f0e3d6;border-radius:28px;padding:26px;text-align:center;box-shadow:0 12px 35px #8a563315}.badge{display:inline-block;border-radius:99px;background:#fff0e3;color:#b3582d;padding:7px 14px;font-size:13px;font-weight:bold}h1{font-size:24px}p{line-height:1.8;color:#756158}.stage{height:335px;display:grid;place-items:center}img{width:292px;height:320px;object-fit:contain}button{border:0;border-radius:99px;background:#bd603a;color:white;font:700 16px system-ui;padding:13px 25px;cursor:pointer}button:focus-visible{outline:3px solid #916541;outline-offset:3px}.note{font-size:13px}</style></head><body><main class="card"><span class="badge">تجربة مبدئية • مش داخل التطبيق</span><h1>تلويحة بإيد واحدة 👋💛</h1><p>تجربة لسبارك ترفع يدها وتلوّح.</p><div class="stage"><img id="pet" alt="سبارك تلوح بيد واحدة"></div><button id="replay">شغّلي التجربة من جديد ↻</button><p class="note">ثلاث وضعيات مرسومة فقط للتجربة؛ الحركة متقطّعة وتحتاج فريمات أكثر وتنظيف، مش نسخة نهائية.</p></main><script>const images=IMAGES;const pet=document.getElementById('pet');let timers=[];function run(){timers.forEach(clearTimeout);timers=[];pet.src=images[0];for(const [delay,pose] of [[650,1],[850,2],[1150,1],[1450,2],[1750,1],[2050,2],[2400,1],[2600,0]])timers.push(setTimeout(()=>pet.src=images[pose],delay));}document.getElementById('replay').onclick=run;if(matchMedia('(prefers-reduced-motion: reduce)').matches)pet.src=images[0];else run();</script></body></html>'''.replace('IMAGES',json.dumps(frames));(root/'web_extra/spark-wave-key-preview.html').write_text(html,encoding='utf-8');print('key poses',len(frames))
