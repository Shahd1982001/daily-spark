"""Separate experiment: a jump landing in the forward-feet seated pose.
Reads the previously prepared registered PNG artwork and renders a full-canvas
frame sequence offline. No application assets are changed.
"""
from pathlib import Path
from PIL import Image
import base64,io,json,math,re
root=Path(__file__).resolve().parents[1]
html=(root/'web_extra/spark-sit-preview-v3.html').read_text(encoding='utf8')
m=re.search(r'const frames=(\[.*?\]);const img=',html,flags=re.S)
assert m, 'Could not locate the existing preview frame sequence'
uris=json.loads(m.group(1)); poses=[Image.open(io.BytesIO(base64.b64decode(u.split(',')[1]))).convert('RGBA') for u in uris]
assert len(poses)==24 and all(p.size==poses[0].size for p in poses)
w,h=poses[0].size
margin=90
frames=[]
# Hold the standing pose briefly before starting the jump.
for i in range(6):
 frames.append((round(i*7/5),0))
# Push off: gravity-shaped arc; legs change to the seated pose while airborne.
# Both endpoints meet the same floor. The squared sine is not used: a simple
# parabola has a fast takeoff and landing with a gentle moment at its apex.
for i in range(30):
 t=i/29
 lift=round(76*4*t*(1-t))
 # Advance into the sitting pose while in the air, complete before landing.
 u=min(1,max(0,(t-.06)/.66));u=u*u*(3-2*u)
 pose=round(7+16*u)
 frames.append((pose,lift))
# A few seated frames are kept after landing for clarity.
for _ in range(6): frames.append((23,0))
encoded=[]
out=root/'animation_lab/jump_sit';out.mkdir(exist_ok=True)
for i,(pose,lift) in enumerate(frames):
 canvas=Image.new('RGBA',(w,h+margin))
 canvas.alpha_composite(poses[pose],(0,margin-lift))
 # 300 pixels wide is sufficient for the isolated preview while preserving
 # every frame on the same registered canvas.
 canvas.thumbnail((300,430),Image.Resampling.LANCZOS)
 p=out/f'frame_{i:02}.png';canvas.save(p,optimize=True)
 encoded.append('data:image/png;base64,'+base64.b64encode(p.read_bytes()).decode())
page='''<!doctype html><html lang="ar" dir="rtl"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>معاينة النقزة والقعدة</title><style>
:root{font-family:system-ui,-apple-system,sans-serif;color:#382b26;background:#fbf6ef}*{box-sizing:border-box}body{margin:0;display:grid;place-items:center;min-height:100svh;padding:18px}.card{width:min(100%,460px);background:#fff;border:1px solid #f0e3d6;border-radius:28px;padding:24px;text-align:center;box-shadow:0 12px 35px #8a563315}.badge{color:#b3582d;background:#fff0e3;border-radius:99px;padding:7px 14px;display:inline-block;font-weight:700;font-size:13px}h1{font-size:24px;margin:16px 0 8px}p{font-size:15px;line-height:1.8;color:#756158;margin:0}.stage{height:355px;display:flex;align-items:flex-end;justify-content:center;position:relative;margin:8px auto 0}.stage:after{content:"";position:absolute;bottom:14px;width:88%;height:7px;border-radius:50%;background:#e7d5c6;z-index:0}img{position:relative;z-index:1;width:235px;height:334px;object-fit:contain;margin-bottom:0}button{background:#bd603a;color:white;border:0;border-radius:99px;font:700 16px system-ui;padding:13px 25px;cursor:pointer;margin-top:18px}button:focus-visible{outline:3px solid #916541;outline-offset:3px}.note{font-size:13px;margin-top:16px}.count{margin-top:10px;color:#a57054;font-size:12px}
</style></head><body><main class="card"><span class="badge">معاينة منفصلة • مش داخل التطبيق</span><h1>نقزة وبعدها قعدة</h1><p>تجربة: مخلوقك ينقز ويهبط برجليه لقدّام.</p><div class="stage"><img id="pet" alt="مخلوقك ينقز ويهبط قاعد"></div><button id="replay">شغّلي الحركة من جديد ↻</button><p class="note">مسودة للتجربة؛ ننتظر رأيك قبل اعتمادها.</p><div class="count">سلسلة صور • الحجم ثابت</div></main><script>
const frames=FRAMES;const img=document.getElementById('pet');let timers=[];function run(){timers.forEach(clearTimeout);timers=[];img.src=frames[0];for(let i=1;i<frames.length;i++)timers.push(setTimeout(()=>{img.src=frames[i]},500+i*55));}document.getElementById('replay').onclick=run;if(matchMedia('(prefers-reduced-motion: reduce)').matches){img.src=frames[0]}else{run();}
</script></body></html>'''.replace('FRAMES',json.dumps(encoded))
(root/'web_extra/spark-jump-sit-preview.html').write_text(page,encoding='utf8')
print(len(frames),'frames', 'preview bytes',len(page))
