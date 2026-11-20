"""Side-walk prototype: animate two separately cut legs from the generated side pose."""
from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,cv2,math,base64,io,json
root=Path(__file__).resolve().parents[1];src=Image.open(root/'animation_lab/walk_right_side_concept.png').convert('RGBA');a=np.array(src);h,w=a.shape[:2]
# Remove white, connected to image edges only; retain white eye highlight.
white=(a[:,:,:3].min(axis=2)>245).astype('uint8');_,labels,_,_=cv2.connectedComponentsWithStats(white,8);outside=labels[0,0];a[:,:,3]=np.where(labels==outside,0,255).astype('uint8')
# Body silhouette boundary slopes upward toward the edges, hiding upper leg joins.
Y,X=np.indices((h,w));boundary=np.interp(np.arange(w),[0,260,300,350,400,480,550,620,700,750,975],[800,905,918,934,945,951,947,938,918,897,800])[None,:]
body=a.copy();body[:,:,3]=np.where(Y>boundary,0,body[:,:,3]);body=Image.fromarray(body)
legs=[]
for left,right in [(250,470),(510,730)]:
 leg=a.copy();leg[:,:,3]=np.where((X>=left)&(X<right)&(Y>boundary-25),leg[:,:,3],0);leg=Image.fromarray(leg)
 # Extend each leg under the body so a modest swing cannot expose gaps.
 backing=Image.new('RGBA',(w,h));d=ImageDraw.Draw(backing);d.rounded_rectangle((left+38,865,right-38,985),radius=30,fill=(137,158,120,255));backing.alpha_composite(leg);legs.append(backing)
frames=[];folder=root/'animation_lab/side_walk_right';folder.mkdir(exist_ok=True)
for i in range(40):
 phase=2*math.pi*i/40;c=Image.new('RGBA',(w+180,h+130));
 for j,foot in enumerate(legs):
  t=phase+j*math.pi;dx=-round(68*math.cos(t));dy=-round(48*max(0,math.sin(t)));c.alpha_composite(foot,(90+dx,35+dy))
 c.alpha_composite(body,(90,35-round(3*(1-math.cos(2*phase))))); arr=np.asarray(c).copy(); n,lab,stats,_=cv2.connectedComponentsWithStats((arr[:,:,3]>35).astype('uint8'),8); largest=1+np.argmax(stats[1:,cv2.CC_STAT_AREA]); keep=cv2.dilate((lab==largest).astype('uint8'),np.ones((3,3),np.uint8))>0; arr[:,:,3]=np.where(keep,arr[:,:,3],0); c=Image.fromarray(arr);c.thumbnail((250,250),Image.Resampling.LANCZOS);bio=io.BytesIO();c.save(bio,'PNG',optimize=True);frames.append('data:image/png;base64,'+base64.b64encode(bio.getvalue()).decode())
 if i in (0,10,20,30):c.save(folder/f'frame_{i:02}.png')
html='''<!doctype html><html lang="ar" dir="rtl"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>سبارك تمشي من الجنب</title><style>*{box-sizing:border-box}body{margin:0;min-height:100svh;display:grid;place-items:center;padding:20px;background:#fbf6ef;color:#382b26;font-family:system-ui,sans-serif}.card{width:min(100%,650px);background:#fff;border:1px solid #f0e3d6;border-radius:28px;padding:26px;text-align:center;box-shadow:0 12px 35px #8a563315}.badge{display:inline-block;border-radius:99px;background:#fff0e3;color:#b3582d;padding:7px 14px;font-size:13px;font-weight:bold}h1{font-size:24px}p{line-height:1.8;color:#756158}.stage{position:relative;height:280px;overflow:hidden;background:#fffaf5;border-radius:20px}.floor{position:absolute;bottom:42px;left:5%;right:5%;height:2px;background:#e9d8c8}img{position:absolute;bottom:20px;left:0;width:200px;height:200px;object-fit:contain}button{border:0;border-radius:99px;background:#bd603a;color:#fff;font:700 16px system-ui;padding:13px 25px;cursor:pointer;margin-top:18px}button:focus-visible{outline:3px solid #916541;outline-offset:3px}.note{font-size:13px}</style><main class="card"><span class="badge">معاينة منفصلة • مش داخل التطبيق</span><h1>سبارك تمشي لليمين 🐾</h1><p>سبارك كلها بالجنب، ورجليها يتبادلوا الخطوات.</p><div class="stage" id="stage"><div class="floor"></div><img id="pet" alt="سبارك من الجنب تمشي ناحية اليمين"></div><button id="replay">شغّلي المشية من جديد ↻</button><p class="note">معاينة أولية للحركة: قوليلي شن تبي نعدّل 💛</p></main><script>const frames=FRAMES;const img=document.getElementById('pet'),stage=document.getElementById('stage');let token=0;function run(){const id=++token,start=performance.now(),duration=5400;function tick(now){if(id!==token)return;const t=Math.min((now-start)/duration,1);img.src=frames[Math.floor(t*3*40)%40];img.style.transform=`translateX(${Math.max(0,stage.clientWidth-200)*t}px)`;if(t<1)requestAnimationFrame(tick)}requestAnimationFrame(tick)}document.getElementById('replay').onclick=run;if(matchMedia('(prefers-reduced-motion: reduce)').matches)img.src=frames[0];else run();</script></html>'''.replace('FRAMES',json.dumps(frames));(root/'web_extra/spark-side-walk-right.html').write_text(html,encoding='utf-8')
