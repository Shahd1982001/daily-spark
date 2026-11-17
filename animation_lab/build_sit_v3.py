"""Separate draft: the original character sits with feet forward.
Render frames offline. Body artwork is kept exactly as chosen; only its height
and the independently illustrated feet change while approaching the floor.
"""
from pathlib import Path
import base64,json
from PIL import Image,ImageDraw,ImageFilter
import numpy as np
root=Path(__file__).resolve().parents[1]
out=root/'animation_lab'/'sit_v3';out.mkdir(exist_ok=True,parents=True)
base=Image.open(root/'assets/mascot/spark.png').convert('RGBA')
a=np.asarray(base).copy();h,w=a.shape[:2];y,x=np.indices((h,w))
curve=np.interp(np.arange(w),[0,70,100,130,160,190,230,273,316,356,386,416,446,476,546],[330,430,468,491,506,516,526,531,526,516,506,491,468,430,330])[None,:]
legs=((x>130)&(x<260))|((x>286)&(x<416))
body=a.copy();body[:,:,3]=np.where(legs&(y>curve),0,body[:,:,3]);body=Image.fromarray(body)
standing=a.copy();standing[:,:,3]=np.where(legs&(y>curve-14),standing[:,:,3],0);standing=Image.fromarray(standing)
# One designed seated-foot artwork is clipped out separately; the mascot's
# eyes, face, body and hands are all copied directly from the original image.
pose=Image.open(root/'animation_lab/sit_pose_natural.png').convert('RGBA')
mask=Image.new('L',pose.size);d=ImageDraw.Draw(mask)
p=[(332,691),(342,683),(355,680),(368,681),(377,688),(384,694),(389,703),(380,690),(374,684),(380,677),(390,673),(400,678),(410,686),(421,697),(425,705),(423,717),(430,725),(457,731),(440,742),(400,757),(375,766),(350,768),(333,759),(322,748),(316,729),(314,708),(318,699)]
d.polygon(p,fill=255);d.polygon([(1024-x,y) for x,y in p],fill=255);mask=mask.filter(ImageFilter.GaussianBlur(.6))
pix=np.asarray(pose).copy();alpha=np.asarray(mask).copy();white=(pix[:,:,0]>215)&(pix[:,:,1]>202)&(pix[:,:,2]>183);alpha[white]=0;pix[:,:,3]=alpha;left_pix=pix.copy();left_pix[:,512:,3]=0;right_pix=pix.copy();right_pix[:,:512,3]=0;left_feet=Image.fromarray(left_pix);right_feet=Image.fromarray(right_pix)
def alpha(image,amount):
 out=image.copy();out.putalpha(out.getchannel('A').point(lambda x: int(x*amount)));return out
paths=[]
for i in range(24):
 t=i/23; ease=t*t*(3-2*t)
 frame=Image.new('RGBA',(546,640))
 if i==0:
  frame.alpha_composite(base,(0,30))
 else:
  # The original planted feet remain at the floor as she lowers. They
  # gradually disappear under the body while forward toes come into view.
  old_opacity=max(0,min(1,(.51-ease)/.15))
  frame.alpha_composite(alpha(standing,old_opacity),(0,30))
  frame.alpha_composite(body,(0,30+round(30*ease)))
  new_opacity=max(0,min(1,(ease-.49)/.20))
  if new_opacity:
   # Feet emerge out from beneath the body, reaching the final fore position.
   dy=round((1-new_opacity)*12)
   inward=round((1-new_opacity)*26)
   frame.alpha_composite(alpha(left_feet,new_opacity),(-238+inward,-155+dy))
   frame.alpha_composite(alpha(right_feet,new_opacity),(-238-inward,-155+dy))
 frame.thumbnail((355,416),Image.Resampling.LANCZOS)
 p=out/f'frame_{i:02}.png';frame.save(p,optimize=True);paths.append(p)
data=['data:image/png;base64,'+base64.b64encode(p.read_bytes()).decode() for p in paths]
html='''<!doctype html><html lang="ar" dir="rtl"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>معاينة القعدة</title><style>
:root{font-family:system-ui,-apple-system,sans-serif;color:#382b26;background:#fbf6ef}*{box-sizing:border-box}body{margin:0;display:grid;place-items:center;min-height:100svh;padding:18px}.card{width:min(100%,460px);background:#fff;border:1px solid #f0e3d6;border-radius:28px;padding:24px;text-align:center;box-shadow:0 12px 35px #8a563315}.badge{color:#b3582d;background:#fff0e3;border-radius:99px;padding:7px 14px;display:inline-block;font-weight:700;font-size:13px}h1{font-size:24px;margin:16px 0 8px}p{font-size:15px;line-height:1.8;color:#756158;margin:0}.stage{height:310px;display:flex;align-items:flex-end;justify-content:center;position:relative;margin:8px auto 0}.stage:after{content:"";position:absolute;bottom:15px;width:88%;height:8px;border-radius:50%;background:#e7d5c6;z-index:0}img{position:relative;z-index:1;width:235px;height:276px;object-fit:contain;margin-bottom:7px}button{background:#bd603a;color:white;border:0;border-radius:99px;font:700 16px system-ui;padding:13px 25px;cursor:pointer;margin-top:18px}button:focus-visible{outline:3px solid #916541;outline-offset:3px}.note{font-size:13px;margin-top:16px}.count{margin-top:10px;color:#a57054;font-size:12px}
</style></head><body><main class="card"><span class="badge">معاينة منفصلة • مش داخل التطبيق</span><h1>القعدة والرجلين لقدّام</h1><p>محاولة جديدة للقعدة بالشكل اللي اخترتيه.</p><div class="stage"><img id="pet" alt="مخلوقك يقعد ورجليه لقدّام"></div><button id="replay">شغّلي الحركة من جديد ↻</button><p class="note">مسودة للتقييم، نعدّلوها حسب رأيك قبل اعتمادها.</p><div class="count">سلسلة من ٢٤ صورة • الحجم ثابت</div></main><script>
const frames=FRAMES;const img=document.getElementById('pet');let timers=[];function run(){timers.forEach(clearTimeout);timers=[];img.src=frames[0];for(let i=1;i<frames.length;i++)timers.push(setTimeout(()=>{img.src=frames[i]},700+i*75));}document.getElementById('replay').onclick=run;if(matchMedia('(prefers-reduced-motion: reduce)').matches){img.src=frames[0]}else{run();}
</script></body></html>'''.replace('FRAMES',json.dumps(data))
(root/'web_extra'/'spark-sit-preview-v3.html').write_text(html,encoding='utf-8')
print('bytes',len(html))
