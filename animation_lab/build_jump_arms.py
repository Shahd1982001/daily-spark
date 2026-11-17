"""Independent frame preview: gentle crouch, arms react, jump and sit.
Offline compositing of the original artwork. The generated PNG frames share the
same registration and unchanged body art. No app code or app assets are used.
"""
from pathlib import Path
from PIL import Image, ImageDraw
import base64,io,json,math,re
import numpy as np
root=Path(__file__).resolve().parents[1]
page=(root/'web_extra/spark-sit-preview-v3.html').read_text(encoding='utf-8')
encoded=re.search(r'const frames=(\[.*?\]);const img=',page,flags=re.S).group(1)
poses=[Image.open(io.BytesIO(base64.b64decode(u.split(',')[1]))).convert('RGBA') for u in json.loads(encoded)]
base=Image.open(root/'assets/mascot/spark.png').convert('RGBA')
assert base.size==(546,600) and len(poses)==24
s=355/546
# Cut out only the original hand/arm shapes along their shared outer contour.
mask=Image.new('L',base.size);d=ImageDraw.Draw(mask)
left=[(0,300),(66,300),(63,320),(65,350),(72,390),(82,420),(100,450),(105,490),(0,490)]
d.polygon(left,fill=255);d.polygon([(545-x,y) for x,y in left],fill=255)
leftmask=Image.new('L',base.size);ImageDraw.Draw(leftmask).polygon(left,fill=255)
rightmask=Image.new('L',base.size);ImageDraw.Draw(rightmask).polygon([(545-x,y) for x,y in left],fill=255)
def cut(layer_mask):
 arr=np.asarray(base).copy();arr[:,:,3]=np.minimum(arr[:,:,3],np.asarray(layer_mask));return Image.fromarray(arr)
larm,rarm=cut(leftmask),cut(rightmask)
# Extra transparent margins prevent the raised hands being clipped when they
# leave the bounds of the original portrait.
pad=120
def padded(image):
 out=Image.new('RGBA',(546+2*pad,600+2*pad));out.alpha_composite(image,(pad,pad));return out
larm,rarm=padded(larm),padded(rarm)
canvas_w=455; xmargin=50; height=506
# Pose, air lift, arm angle. Frame transitions follow the jump arc.
spec=[]
for i in range(9):
 t=i/8;spec.append((round(11*t),0,8*t))
for i in range(30):
 t=i/29;lift=76*4*t*(1-t)
 q=min(1,max(0,(t-.05)/.67));q=q*q*(3-2*q)
 pose=round(11+12*q)
 # Arms spread at takeoff, peak in mid-air, settle near landing.
 angle=8+32*math.sin(math.pi*t)
 spec.append((pose,round(lift),angle))
for i in range(9):spec.append((23,0,8*(1-i/8)))
out=root/'animation_lab/jump_arms';out.mkdir(exist_ok=True)
data=[]
for i,(pose,lift,angle) in enumerate(spec):
 source=poses[pose].copy()
 t=pose/23; ease=t*t*(3-2*t);body_y=30+round(30*ease)
 yoff=round(body_y*s)
 # Original image has a top margin of 30 pixels in frame 0. Remove arms
 # from each registered pose only where the existing arms appear.
 cutmask=mask.resize((355,round(600*s)),Image.Resampling.NEAREST)
 overlaymask=Image.new('L',source.size);overlaymask.paste(cutmask,(0,yoff))
 a=np.asarray(source).copy();a[:,:,3]=np.where(np.asarray(overlaymask)>0,0,a[:,:,3]);body=Image.fromarray(a)
 # Arm pivots are at the shoulders. They return to their original pose after
 # landing, and the torso is never scaled.
 L=larm.rotate(-angle,resample=Image.Resampling.BICUBIC,center=(67+pad,320+pad))
 R=rarm.rotate(angle,resample=Image.Resampling.BICUBIC,center=(479+pad,320+pad))
 L=L.resize((round((546+2*pad)*s),round((600+2*pad)*s)),Image.Resampling.LANCZOS)
 R=R.resize((round((546+2*pad)*s),round((600+2*pad)*s)),Image.Resampling.LANCZOS)
 canvas=Image.new('RGBA',(canvas_w,height))
 py=90-lift
 canvas.alpha_composite(L,(xmargin-round(pad*s),py+yoff-round(pad*s)));canvas.alpha_composite(R,(xmargin-round(pad*s),py+yoff-round(pad*s)))
 canvas.alpha_composite(body,(xmargin,py))
 canvas.thumbnail((350,390),Image.Resampling.LANCZOS)
 p=out/f'frame_{i:02}.png';canvas.save(p,optimize=True)
 data.append('data:image/png;base64,'+base64.b64encode(p.read_bytes()).decode())
html='''<!doctype html><html lang="ar" dir="rtl"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>معاينة النقزة باليدين</title><style>
:root{font-family:system-ui,-apple-system,sans-serif;color:#382b26;background:#fbf6ef}*{box-sizing:border-box}body{margin:0;display:grid;place-items:center;min-height:100svh;padding:18px}.card{width:min(100%,460px);background:#fff;border:1px solid #f0e3d6;border-radius:28px;padding:24px;text-align:center;box-shadow:0 12px 35px #8a563315}.badge{color:#b3582d;background:#fff0e3;border-radius:99px;padding:7px 14px;display:inline-block;font-weight:700;font-size:13px}h1{font-size:24px;margin:16px 0 8px}p{font-size:15px;line-height:1.8;color:#756158;margin:0}.stage{height:355px;display:flex;align-items:flex-end;justify-content:center;position:relative;margin:8px auto 0}.stage:after{content:"";position:absolute;bottom:14px;width:88%;height:7px;border-radius:50%;background:#e7d5c6;z-index:0}img{position:relative;z-index:1;width:302px;height:334px;object-fit:contain;margin-bottom:0}button{background:#bd603a;color:white;border:0;border-radius:99px;font:700 16px system-ui;padding:13px 25px;cursor:pointer;margin-top:18px}button:focus-visible{outline:3px solid #916541;outline-offset:3px}.note{font-size:13px;margin-top:16px}.count{margin-top:10px;color:#a57054;font-size:12px}
</style></head><body><main class="card"><span class="badge">معاينة منفصلة • مش داخل التطبيق</span><h1>نقزة والقعدة باليدين</h1><p>تثني شوي، تحرك يديها، وتنقز وتقعد.</p><div class="stage"><img id="pet" alt="مخلوقك ينقز ويحرك يديه ويهبط قاعد"></div><button id="replay">شغّلي الحركة من جديد ↻</button><p class="note">تجربة أولى لليدين والركب؛ مش معتمدة بعد.</p><div class="count">سلسلة صور • نفس حجم الجسم</div></main><script>
const frames=FRAMES;const img=document.getElementById('pet');let timers=[];function run(){timers.forEach(clearTimeout);timers=[];img.src=frames[0];for(let i=1;i<frames.length;i++)timers.push(setTimeout(()=>{img.src=frames[i]},500+i*55));}document.getElementById('replay').onclick=run;if(matchMedia('(prefers-reduced-motion: reduce)').matches){img.src=frames[0]}else{run();}
</script></body></html>'''.replace('FRAMES',json.dumps(data))
(root/'web_extra/spark-jump-arms-preview.html').write_text(html,encoding='utf-8')
print(len(spec),'frames bytes',len(html))
