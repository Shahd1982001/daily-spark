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
folder=root/'animation_lab/happy_tilt';folder.mkdir(exist_ok=True)
frames=[]
# At zero the frame is the exact original. A gentle eased smile grows, holds,
# and returns; body/limbs remain fixed and eye glints are confined to pupils.
levels=[0]*5+[i/16 for i in range(1,17)]+[1]*10+[1-i/16 for i in range(1,17)]+[0]*5
for i,t in enumerate(levels):
 t=t*t*(3-2*t)
 if t==0: out=base.copy()
 else:
  rgb=arr[:,:,:3].copy();rgb[mask>0]=clean[mask>0]
  # Cubic smile, widening naturally rather than changing the whole face.
  x0=243-7*t;x1=302+7*t;top=323-2*t;bottom=345+6*t
  u=np.linspace(0,1,160);xs=(1-u)*x0+u*x1
  ys=top+3*(bottom-top)*u*(1-u)
  pts=np.stack((xs,ys),axis=1).round().astype(np.int32)
  cv2.polylines(rgb,[pts],False,(85,36,22),7,cv2.LINE_AA)
  cv2.circle(rgb,(round(x0),round(top)),3,(85,36,22),-1,cv2.LINE_AA);cv2.circle(rgb,(round(x1),round(top)),3,(85,36,22),-1,cv2.LINE_AA)
  changed=np.dstack((rgb,arr[:,:,3]));out=Image.fromarray(changed,'RGBA')
  # Small highlights within the original pupils, never outside the eyes.
  glint=Image.new('RGBA',(w,h));d=ImageDraw.Draw(glint)
  for x in (207,365):
   r=3.0*t;d.ellipse((x-r,278-r,x+r,278+r),fill=(255,249,229,round(190*t)))
  out=Image.alpha_composite(out,glint)
 # Feet stay on the same floor. Rotate the original joined head/body and
 # arms slightly clockwise about the lower body, keeping a fixed padded canvas.
 if t>0:
  yy,xx=np.indices((h,w))
  edge=np.interp(np.arange(w),[0,70,100,130,160,190,230,273,316,356,386,416,446,476,546],[330,430,468,491,506,516,526,531,526,516,506,491,468,430,330])[None,:]
  legzone=((xx>130)&(xx<260))|((xx>286)&(xx<416))
  feet=arr.copy();feet[:,:,3]=np.where(legzone & (yy>edge-14),feet[:,:,3],0)
  upper=np.asarray(out).copy();upper[:,:,3]=np.where(legzone & (yy>edge),0,upper[:,:,3])
  feet_image=Image.fromarray(feet);upper_image=Image.fromarray(upper)
  pad=40;stage=Image.new('RGBA',(w+2*pad,h+2*pad));stage.alpha_composite(feet_image,(pad,pad))
  upper_pad=Image.new('RGBA',stage.size);upper_pad.alpha_composite(upper_image,(pad,pad))
  upper_pad=upper_pad.rotate(-4*t,resample=Image.Resampling.BICUBIC,center=(273+pad,526+pad))
  stage.alpha_composite(upper_pad);out=stage
 else:
  stage=Image.new('RGBA',(w+80,h+80));stage.alpha_composite(out,(40,40));out=stage
 out.thumbnail((292,320),Image.Resampling.LANCZOS)
 p=folder/f'frame_{i:02}.png';out.save(p,optimize=True)
 frames.append('data:image/png;base64,'+base64.b64encode(p.read_bytes()).decode())
html='''<!doctype html><html lang="ar" dir="rtl"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>فرحة سبارك</title><style>*{box-sizing:border-box}body{margin:0;min-height:100svh;display:grid;place-items:center;padding:20px;background:#fbf6ef;color:#382b26;font-family:system-ui,sans-serif}.card{width:min(100%,460px);background:white;border:1px solid #f0e3d6;border-radius:28px;padding:26px;text-align:center;box-shadow:0 12px 35px #8a563315}.badge{display:inline-block;border-radius:99px;background:#fff0e3;color:#b3582d;padding:7px 14px;font-size:13px;font-weight:bold}h1{font-size:24px;margin:18px 0 8px}p{line-height:1.8;color:#756158} .stage{height:335px;display:grid;place-items:center}img{width:292px;height:320px;object-fit:contain}button{border:0;border-radius:99px;background:#bd603a;color:white;font:700 16px system-ui;padding:13px 25px;cursor:pointer}button:focus-visible{outline:3px solid #916541;outline-offset:3px}.note{font-size:13px}</style></head><body><main class="card"><span class="badge">معاينة منفصلة • مش داخل التطبيق</span><h1>فرحة وميلان خفيف ✨</h1><p>ابتسامة ولمعة، مع ميلان خفيف لليمين.</p><div class="stage"><img id="pet" alt="سبارك تبتسم بفرحة خفيفة"></div><button id="replay">شغّلي الحركة من جديد ↻</button><p class="note">نجربوا تعبير واحد ونستنوا رأيك 💛</p></main><script>const frames=FRAMES;const img=document.getElementById('pet');let timers=[];function run(){timers.forEach(clearTimeout);timers=[];img.src=frames[0];for(let i=1;i<frames.length;i++)timers.push(setTimeout(()=>img.src=frames[i],500+i*65));}document.getElementById('replay').onclick=run;if(matchMedia('(prefers-reduced-motion: reduce)').matches){img.src=frames[0]}else{run()}</script></body></html>'''.replace('FRAMES',json.dumps(frames))
(root/'web_extra/spark-happy-tilt-preview.html').write_text(html,encoding='utf-8')
print('frames',len(frames))
