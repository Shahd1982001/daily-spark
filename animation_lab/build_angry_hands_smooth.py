"""Experimental interpolation between three approved/draft hand key poses.
This is a computational motion study, not independently illustrated frames.
"""
from pathlib import Path
from PIL import Image
import cv2,numpy as np,json,base64
root=Path(__file__).resolve().parents[1];files=['animation_lab/cute_angry/frame_25.png','animation_lab/angry_hands_middle_concept.png','animation_lab/angry_fists_concept.png']
key=[np.asarray(Image.open(root/p).convert('RGBA')).copy() for p in files];h,w=key[0].shape[:2];assert all(a.shape==key[0].shape for a in key)
def flow(a,b):
 def grey(i):
  x=i.astype('float32');alpha=x[:,:,3:4]/255.;rgb=x[:,:,:3]*alpha+255*(1-alpha);return cv2.cvtColor(np.uint8(rgb),cv2.COLOR_RGB2GRAY)
 dis=cv2.DISOpticalFlow_create(cv2.DISOPTICAL_FLOW_PRESET_MEDIUM);dis.setFinestScale(0);dis.setGradientDescentIterations(40)
 return dis.calc(grey(a),grey(b),None)
flows=[(flow(key[i],key[i+1]),flow(key[i+1],key[i])) for i in range(2)]
y,x=np.indices((h,w),dtype=np.float32)
def premult(im):
 z=im.astype('float32')/255;z[:,:,:3]*=z[:,:,3:4];return z
def interp(a,b,f,back,t):
 A=cv2.remap(premult(a),x-t*f[:,:,0],y-t*f[:,:,1],cv2.INTER_LINEAR,borderMode=cv2.BORDER_CONSTANT)
 B=cv2.remap(premult(b),x-(1-t)*back[:,:,0],y-(1-t)*back[:,:,1],cv2.INTER_LINEAR,borderMode=cv2.BORDER_CONSTANT)
 z=A*(1-t)+B*t;z[:,:,:3]=np.where(z[:,:,3:4]>1e-5,z[:,:,:3]/np.maximum(z[:,:,3:4],1e-5),0)
 return np.uint8(np.clip(z*255,0,255))
folder=root/'animation_lab/angry_hands_smooth';folder.mkdir(exist_ok=True);sequence=[key[0]]*6
for i in range(2):
 for j in range(1,13):
  t=j/12;sequence.append(key[i+1] if j==12 else interp(key[i],key[i+1],*flows[i],t))
sequence+=[key[2]]*10
sequence+=list(reversed(sequence[6:29]));sequence+=[key[0]]*5
frames=[]
for i,a in enumerate(sequence):
 p=folder/f'frame_{i:02}.png';Image.fromarray(a).save(p,optimize=True);frames.append('data:image/png;base64,'+base64.b64encode(p.read_bytes()).decode())
html='''<!doctype html><html lang="ar" dir="rtl"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>تجربة حركة تدريجية</title><style>*{box-sizing:border-box}body{margin:0;min-height:100svh;display:grid;place-items:center;padding:20px;background:#fbf6ef;color:#382b26;font-family:system-ui,sans-serif}.card{width:min(100%,460px);background:white;border:1px solid #f0e3d6;border-radius:28px;padding:26px;text-align:center;box-shadow:0 12px 35px #8a563315}.badge{display:inline-block;border-radius:99px;background:#fff0e3;color:#b3582d;padding:7px 14px;font-size:13px;font-weight:bold}h1{font-size:24px}p{line-height:1.8;color:#756158}.stage{height:335px;display:grid;place-items:center}img{width:292px;height:320px;object-fit:contain}button{border:0;border-radius:99px;background:#bd603a;color:white;font:700 16px system-ui;padding:13px 25px;cursor:pointer}button:focus-visible{outline:3px solid #916541;outline-offset:3px}.note{font-size:13px}</style></head><body><main class="card"><span class="badge">تجربة مبدئية • مش داخل التطبيق</span><h1>يدين الغضب بتدرّج 😤💛</h1><p>تجربة انتقال بين الوضعيات اللي شفناهم.</p><div class="stage"><img id="pet" alt="تجربة حركة يدي سبارك"></div><button id="replay">شغّلي التجربة من جديد ↻</button><p class="note">الصور الوسطية مولّدة رقميًا من الوضعيات؛ مش رسومات مستقلة نهائية، ونستنوا رأيك في الحركة والخطوط.</p></main><script>const frames=FRAMES;const pet=document.getElementById('pet');let timers=[];function run(){timers.forEach(clearTimeout);timers=[];pet.src=frames[0];for(let i=1;i<frames.length;i++)timers.push(setTimeout(()=>pet.src=frames[i],350+i*55));}document.getElementById('replay').onclick=run;if(matchMedia('(prefers-reduced-motion: reduce)').matches)pet.src=frames[0];else run();</script></body></html>'''.replace('FRAMES',json.dumps(frames));(root/'web_extra/spark-angry-hands-smooth.html').write_text(html,encoding='utf-8');print(len(frames))
