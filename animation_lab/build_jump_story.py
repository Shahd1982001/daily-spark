"""Separate experiment with opaque, drawn-pose silhouettes for arms/legs.
The original front body is unchanged; optical/mesh interpolation of the limb
silhouettes produces image frames offline. This is not hand-drawn animation.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFilter
import base64,json,math
import cv2,numpy as np
from scipy.spatial import Delaunay
root=Path(__file__).resolve().parents[1]; folder=root/'animation_lab'/'jump_story';folder.mkdir(parents=True,exist_ok=True)
base=Image.open(root/'assets/mascot/spark.png').convert('RGBA'); pix=np.asarray(base).copy();h,w=pix.shape[:2];y,x=np.indices((h,w))
curve=np.interp(np.arange(w),[0,70,100,130,160,190,230,273,316,356,386,416,446,476,546],[330,430,468,491,506,516,526,531,526,516,506,491,468,430,330])[None,:]
legzone=((x>130)&(x<260))|((x>286)&(x<416))
armmask=Image.new('L',(w,h));d=ImageDraw.Draw(armmask);left=[(0,300),(66,300),(63,320),(65,350),(72,390),(82,420),(100,450),(105,490),(0,490)];d.polygon(left,fill=255);d.polygon([(545-x,y) for x,y in left],fill=255)
armarea=np.asarray(armmask)>0
body=pix.copy();body[:,:,3]=np.where((legzone&(y>curve))|armarea,0,body[:,:,3]);body=Image.fromarray(body)
# Common registered canvas; original body begins at (100,90).
W,H=746,790;ox,oy=100,125
def canvas(image,dx=0,dy=0):
 z=Image.new('RGBA',(W,H));z.alpha_composite(image,(ox+dx,oy+dy));return z
src_arm=pix.copy();src_arm[:,:,3]=np.where(armarea,src_arm[:,:,3],0);src_arm=canvas(Image.fromarray(src_arm))
src_leg=pix.copy();src_leg[:,:,3]=np.where(legzone&(y>curve-14),src_leg[:,:,3],0);src_leg=canvas(Image.fromarray(src_leg))
# Raised-arm artwork, with a solid white background removed using the mascot
# outline. Crop arms only; original face and torso stay untouched.
raw=cv2.imread(str(root/'animation_lab/arms_short_reference.png'))
m=(cv2.cvtColor(raw,cv2.COLOR_BGR2GRAY)<150).astype('uint8')*255
c=max(cv2.findContours(m,cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_SIMPLE)[0],key=cv2.contourArea);m[:]=0;cv2.drawContours(m,[c],-1,255,cv2.FILLED);m=cv2.dilate(m,np.ones((3,3),np.uint8));rgba=cv2.cvtColor(raw,cv2.COLOR_BGR2RGBA);rgba[:,:,3]=m
# keep arm only: shoulders overlap and are later covered by the original torso
_,xx=np.indices(m.shape);rgba[:,:,3]=np.where((xx<313)|(xx>711),rgba[:,:,3],0)
# Do not include the white-background fringe that can be enclosed by the
# detected contour around the rendered arms.
rgb=rgba[:,:,:3].astype(int)
white_fringe=(rgb.min(axis=2)>185)&((rgb.max(axis=2)-rgb.min(axis=2))<32)
rgba[:,:,3][white_fringe]=0
arm_art=Image.fromarray(rgba);tgt_arm=canvas(arm_art,-238,-221)
# The airborne drawing is a different fully opaque leg pose, not a seated pose.
jumpraw=cv2.imread(str(root/'animation_lab/arms_out_reference.png'))
jmask=(cv2.cvtColor(jumpraw,cv2.COLOR_BGR2GRAY)<150).astype('uint8')*255
jc=max(cv2.findContours(jmask,cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_SIMPLE)[0],key=cv2.contourArea)
jmask[:]=0;cv2.drawContours(jmask,[jc],-1,255,cv2.FILLED);jmask=cv2.dilate(jmask,np.ones((3,3),np.uint8))
jump_rgba=cv2.cvtColor(jumpraw,cv2.COLOR_BGR2RGBA); jy,jx=np.indices(jmask.shape)
jump_rgba[:,:,3]=np.where((jy>695)&((jx<495)|(jx>529)),jmask,0)
air_leg=canvas(Image.fromarray(jump_rgba),-238,-221)
# Seated feet point toward viewer; no white background is kept in the mask.
pose=Image.open(root/'animation_lab/sit_pose_natural.png').convert('RGBA');mask=Image.new('L',pose.size);d=ImageDraw.Draw(mask)
p=[(332,691),(342,683),(355,680),(368,681),(377,688),(384,694),(389,703),(380,690),(374,684),(380,677),(390,673),(400,678),(410,686),(421,697),(425,705),(423,717),(430,725),(457,731),(440,742),(400,757),(375,766),(350,768),(333,759),(322,748),(316,729),(314,708),(318,699)]
d.polygon(p,fill=255);d.polygon([(1024-x,y) for x,y in p],fill=255);mask=mask.filter(ImageFilter.GaussianBlur(.5))
pa=np.asarray(pose).copy();a=np.asarray(mask).copy();a[(pa[:,:,0]>215)&(pa[:,:,1]>202)&(pa[:,:,2]>183)]=0;pa[:,:,3]=a;tgt_leg=canvas(Image.fromarray(pa),-238,-215)

def sampling(image,side):
 arr=np.asarray(image).copy()
 if side=='left':arr[:,ox+273:,3]=0
 else:arr[:,:ox+273,3]=0
 contours,_=cv2.findContours((arr[:,:,3]>110).astype('uint8')*255,cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_NONE)
 c=max(contours,key=cv2.contourArea)[:,0,:].astype(np.float32)
 # Anchor starts near the shoulder for arms or the inner upper edge for legs;
 # consistent winding preserves contour correspondence.
 idx=np.argmin(c[:,1]*1.0 + (c[:,0] if side=='right' else -c[:,0])*.001)
 c=np.roll(c,-idx,axis=0);c=np.vstack([c,c[0]])
 dist=np.r_[0,np.cumsum(np.linalg.norm(np.diff(c,axis=0),axis=1))]
 t=np.linspace(0,dist[-1],56,endpoint=False)
 pts=np.stack([np.interp(t,dist,c[:,0]),np.interp(t,dist,c[:,1])],axis=1).astype('float32')
 pts=np.vstack([pts,pts.mean(axis=0)])
 return arr,pts
stages={name:{side:sampling(img,side) for side in ('left','right')} for name,img in [('arm0',src_arm),('arm1',tgt_arm),('leg0',src_leg),('legair',air_leg),('leg1',tgt_leg)]}
def warp(img,src,dst,triangles):
 result=np.zeros_like(img)
 for ids in triangles:
  d=dst[ids].astype('float32');ss=src[ids].astype('float32')
  x,y,w,h=cv2.boundingRect(np.round(d).astype('int32'))
  x=max(0,x);y=max(0,y);w=min(W-x,w);h=min(H-y,h)
  if w<=0 or h<=0:continue
  mat=cv2.getAffineTransform(ss,d);mat[:,2]-=[x,y]
  wa=cv2.warpAffine(img,mat,(w,h),flags=cv2.INTER_LINEAR,borderMode=cv2.BORDER_CONSTANT)
  mask=np.zeros((h,w),np.uint8);cv2.fillConvexPoly(mask,np.round(d-[x,y]).astype('int32'),255,cv2.LINE_AA)
  r=result[y:y+h,x:x+w];r[mask>0]=wa[mask>0]
 return result

def morph(start,end,t):
 out=Image.new('RGBA',(W,H))
 for side in ('left','right'):
  ai,ap=stages[start][side];bi,bp=stages[end][side];dp=ap*(1-t)+bp*t
  triangles=Delaunay(dp).simplices
  A=warp(ai,ap,dp,triangles).astype('float32')/255
  B=warp(bi,bp,dp,triangles).astype('float32')/255
  # Both images are warped to the SAME silhouette; blend their pigment, not
  # visibility. At no point is a second copy of the leg faded in.
  aa=A[:,:,3:];ab=B[:,:,3:];al=aa*(1-t)+ab*t
  rgb=(A[:,:,:3]*aa*(1-t)+B[:,:,:3]*ab*t)/np.maximum(al,1e-6)
  out.alpha_composite(Image.fromarray(np.uint8(np.clip(np.concatenate((rgb,al),axis=2)*255,0,255))))
 return out
# Storyboard from the annotated screenshots:
# 1. standing with arms down; 2. lift arms and spread feet while airborne;
# 3. lower arms and reach the floor; 4. only then move into the sitting pose.
spec=[]
for i in range(9):
 t=i/8;spec.append((0,round(10*t),.18*t,0,0,'ready'))
for i in range(30):
 t=i/29;lift=round(96*4*t*(1-t))
 spread=math.sin(math.pi*t)
 arms=.18*(1-t)+.82*math.sin(math.pi*t)
 spec.append((lift,round(10*(1-t)),arms,spread,0,'air'))
for i in range(16):
 t=i/15;q=t*t*(3-2*t)
 spec.append((0,round(26*q),0,0,q,'sit'))
for i in range(5):spec.append((0,26,0,0,1,'sit'))

# Split original feet; each remains fully opaque as it changes direction.
lleg=src_leg.copy(); rleg=src_leg.copy()
larr=np.asarray(lleg).copy();larr[:,ox+273:,3]=0;lleg=Image.fromarray(larr)
rarr=np.asarray(rleg).copy();rarr[:,:ox+273,3]=0;rleg=Image.fromarray(rarr)
frames=[]
for i,(lift,crouch,arms,spread,leg,phase) in enumerate(spec):
 art=Image.new('RGBA',(W,H))
 A=src_arm if arms < .001 else morph('arm0','arm1',arms)
 if phase == 'air':
  L=src_leg if spread < .001 else morph('leg0','legair',spread)
 else:
  L=src_leg if leg < .001 else morph('leg0','leg1',leg)
 leg_y = -lift if phase in ('ready', 'air') else crouch-lift
 art.alpha_composite(A,(0,crouch-lift));art.alpha_composite(L,(0,leg_y));art.alpha_composite(body,(ox,oy+crouch-lift))
 # Front-facing seated feet are only displayed after ground contact.
 if phase=='sit' and leg>=.60:art.alpha_composite(L,(0,crouch-lift))
 # Crop static registered canvas, leaving room for raised arms and jump.
 art.thumbnail((320,340),Image.Resampling.LANCZOS)
 path=folder/f'frame_{i:02}.png';art.save(path,optimize=True)
 frames.append('data:image/png;base64,'+base64.b64encode(path.read_bytes()).decode())
print('frames',len(frames))
# Offline self-contained preview with intentionally no automatic app changes.
html='''<!doctype html><html lang="ar" dir="rtl"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>معاينة الحركة</title><style>:root{font-family:system-ui,-apple-system,sans-serif;color:#382b26;background:#fbf6ef}*{box-sizing:border-box}body{margin:0;display:grid;place-items:center;min-height:100svh;padding:18px}.card{width:min(100%,460px);background:#fff;border:1px solid #f0e3d6;border-radius:28px;padding:24px;text-align:center;box-shadow:0 12px 35px #8a563315}.badge{color:#b3582d;background:#fff0e3;border-radius:99px;padding:7px 14px;display:inline-block;font-weight:700;font-size:13px}h1{font-size:24px;margin:16px 0 8px}p{font-size:15px;line-height:1.8;color:#756158;margin:0}.stage{height:345px;display:flex;align-items:flex-end;justify-content:center;position:relative;margin:8px auto 0}.stage:after{content:"";position:absolute;bottom:33px;width:88%;height:7px;border-radius:50%;background:#e7d5c6;z-index:0}img{position:relative;z-index:1;width:320px;height:339px;object-fit:contain;margin-bottom:0}button{background:#bd603a;color:white;border:0;border-radius:99px;font:700 16px system-ui;padding:13px 25px;cursor:pointer;margin-top:18px}button:focus-visible{outline:3px solid #916541;outline-offset:3px}.note{font-size:13px;margin-top:16px}.count{margin-top:10px;color:#a57054;font-size:12px}</style></head><body><main class="card"><span class="badge">معاينة منفصلة • مش داخل التطبيق</span><h1>نقزة والقعدة</h1><p>اليدين يطلعوا، والرجلين يتفرّقوا، والقعدة بعد الهبوط.</p><div class="stage"><img id="pet" alt="مخلوقك ينقز ويفتح يديه ويهبط قاعد"></div><button id="replay">شغّلي الحركة من جديد ↻</button><p class="note">تجربة للقعدة والنقزة؛ ننتظر رأيك.</p><div class="count">سلسلة صور • نفس حجم الجسم</div></main><script>const frames=FRAMES;const img=document.getElementById('pet');let timers=[];function run(){timers.forEach(clearTimeout);timers=[];img.src=frames[0];for(let i=1;i<frames.length;i++)timers.push(setTimeout(()=>{img.src=frames[i]},600+i*60));}document.getElementById('replay').onclick=run;if(matchMedia('(prefers-reduced-motion: reduce)').matches){img.src=frames[0]}else{run();}</script></body></html>'''.replace('FRAMES',json.dumps(frames))
(root/'web_extra/spark-jump-story-preview.html').write_text(html,encoding='utf-8')
