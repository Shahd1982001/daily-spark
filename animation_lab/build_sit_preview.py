"""Build a separate sit prototype; original face and body are kept intact."""
from pathlib import Path
import base64,json
import cv2,numpy as np
from PIL import Image
root=Path(__file__).resolve().parents[1]
out=root/'animation_lab'/'sit';out.mkdir(exist_ok=True,parents=True)
base=Image.open(root/'assets/mascot/spark.png').convert('RGBA')
a=np.asarray(base).copy();h,w=a.shape[:2];y,x=np.indices((h,w))
curve=np.interp(np.arange(w),[0,70,100,130,160,190,230,273,316,356,386,416,446,476,546],[330,430,468,491,506,516,526,531,526,516,506,491,468,430,330])[None,:]
legs=((x>130)&(x<260))|((x>286)&(x<416))
body_a=a.copy();body_a[:,:,3]=np.where(legs & (y>curve),0,body_a[:,:,3]);body=Image.fromarray(body_a)
feet_a=a.copy();feet_a[:,:,3]=np.where(legs & (y>curve-14),feet_a[:,:,3],0);standing_feet=Image.fromarray(feet_a)
src=cv2.imread(str(root/'animation_lab/sitting_source.png'));m=(cv2.cvtColor(src,cv2.COLOR_BGR2GRAY)<150).astype('uint8')*255
c=max(cv2.findContours(m,cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_SIMPLE)[0],key=cv2.contourArea);m[:]=0;cv2.drawContours(m,[c],-1,255,cv2.FILLED);m=cv2.dilate(m,np.ones((3,3),np.uint8));rgb=cv2.cvtColor(src,cv2.COLOR_BGR2RGBA);rgb[:,:,3]=m;pose=Image.fromarray(rgb)
seated=Image.new('RGBA',pose.size);seated.paste(pose.crop((300,655,480,790)),(300,655));seated.paste(pose.crop((545,655,725,790)),(545,655))
stand_layer=Image.new('RGBA',(546,640));stand_layer.alpha_composite(standing_feet,(0,30))
sit_layer=Image.new('RGBA',(546,640));sit_layer.alpha_composite(seated,(-238,-171))
def sample_contour(image, side):
    from scipy.spatial import Delaunay
    arr=np.asarray(image).copy()
    if side=='left': arr[:,273:,3]=0
    else: arr[:,:273,3]=0
    mask=np.uint8(arr[:,:,3]>120)*255
    contours,_=cv2.findContours(mask,cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_NONE)
    c=max(contours,key=cv2.contourArea)[:,0,:].astype(np.float32)
    # Start both outlines at their topmost point and sample by arc length.
    start=np.argmin(c[:,1]*2+c[:,0]*0.001); c=np.roll(c,-start,axis=0)
    c=np.vstack([c,c[0]]);dist=np.r_[0,np.cumsum(np.linalg.norm(np.diff(c,axis=0),axis=1))]
    at=np.linspace(0,dist[-1],64,endpoint=False)
    pts=np.stack([np.interp(at,dist,c[:,0]),np.interp(at,dist,c[:,1])],axis=1).astype(np.float32)
    # An interior anchor makes a fan triangulation well behaved.
    pts=np.vstack([pts,np.mean(pts,axis=0)])
    return arr,pts

stand_legs={side:sample_contour(stand_layer,side) for side in ['left','right']}
sit_legs={side:sample_contour(sit_layer,side) for side in ['left','right']}
def warp_triangles(image,source,dest):
    from scipy.spatial import Delaunay
    shape=image.shape;result=np.zeros(shape,np.uint8)
    # Source and destination contours correspond by perimeter position.
    for tri in Delaunay(dest).simplices:
        s=source[tri].astype(np.float32);d=dest[tri].astype(np.float32)
        mat=cv2.getAffineTransform(s,d)
        warped=cv2.warpAffine(image,mat,(shape[1],shape[0]),flags=cv2.INTER_LINEAR,borderMode=cv2.BORDER_CONSTANT)
        mask=np.zeros(shape[:2],np.uint8);cv2.fillConvexPoly(mask,np.round(d).astype(np.int32),255,cv2.LINE_AA)
        result[mask>0]=warped[mask>0]
    return result

def blend(a,b,t):
    # Morph the two leg silhouettes to the same intermediate shape before
    # blending, rather than showing both pairs of feet at once.
    composite=Image.new('RGBA',(546,640))
    for side in ['left','right']:
        ai,ap=stand_legs[side];bi,bp=sit_legs[side];dp=ap*(1-t)+bp*t
        wa=warp_triangles(ai,ap,dp).astype(np.float32)/255
        wb=warp_triangles(bi,bp,dp).astype(np.float32)/255
        aa=wa[:,:,3:];ab=wb[:,:,3:];alpha=aa*(1-t)+ab*t
        rgb=(wa[:,:,:3]*aa*(1-t)+wb[:,:,:3]*ab*t)/np.maximum(alpha,1e-6)
        result=np.uint8(np.clip(np.concatenate([rgb,alpha],axis=2)*255,0,255))
        composite.alpha_composite(Image.fromarray(result))
    return composite

paths=[]
for i in range(12):
 t=i/11;s=t*t*(3-2*t)
 frame=Image.new('RGBA',(546,640))
 if i==0: frame.alpha_composite(base,(0,30))
 else:
  frame.alpha_composite(blend(stand_layer,sit_layer,s))
  frame.alpha_composite(body,(0,30+round(30*s)))
 frame.thumbnail((355,416),Image.Resampling.LANCZOS)
 p=out/f'sit_{i:02}.png';frame.save(p,optimize=True);paths.append(p)
data=['data:image/png;base64,'+base64.b64encode(p.read_bytes()).decode() for p in paths]
html='''<!doctype html><html lang="ar" dir="rtl"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>معاينة حركة القعدة</title><style>
:root{font-family:system-ui,-apple-system,sans-serif;color:#382b26;background:#fbf6ef}*{box-sizing:border-box}body{margin:0;display:grid;place-items:center;min-height:100svh;padding:18px}.card{width:min(100%,460px);background:#fff;border:1px solid #f0e3d6;border-radius:28px;padding:24px;text-align:center;box-shadow:0 12px 35px #8a563315} .badge{color:#b3582d;background:#fff0e3;border-radius:99px;padding:7px 14px;display:inline-block;font-weight:700;font-size:13px}h1{font-size:24px;margin:16px 0 8px}p{font-size:15px;line-height:1.8;color:#756158;margin:0}.stage{height:310px;display:flex;align-items:flex-end;justify-content:center;position:relative;margin:8px auto 0}.stage:after{content:"";position:absolute;bottom:15px;width:88%;height:8px;border-radius:50%;background:#e7d5c6;z-index:0}img{position:relative;z-index:1;width:235px;height:276px;object-fit:contain;margin-bottom:7px}button{background:#bd603a;color:white;border:0;border-radius:99px;font:700 16px system-ui;padding:13px 25px;cursor:pointer;margin-top:18px}button:focus-visible{outline:3px solid #916541;outline-offset:3px}.note{font-size:13px;margin-top:16px} .count{margin-top:10px;color:#a57054;font-size:12px}
</style></head><body><main class="card"><span class="badge">معاينة منفصلة • مش داخل التطبيق</span><h1>حركة القعدة</h1><p>مخلوقك يوقف شوية، وبعدها يقعد.</p><div class="stage"><img id="pet" alt="مخلوقك من الوقفة إلى القعدة"></div><button id="replay">شغّلي الحركة من جديد ↻</button><p class="note">تجربة أولى للقعدة فقط؛ الوقوف من القعدة نخدموه بعد موافقتك.</p><div class="count">سلسلة من ١٢ صورة • الحجم ثابت</div></main><script>
const frames=FRAMES;const img=document.getElementById('pet');let timers=[];function run(){timers.forEach(clearTimeout);timers=[];img.src=frames[0];for(let i=1;i<frames.length;i++)timers.push(setTimeout(()=>{img.src=frames[i]},650+i*105));}document.getElementById('replay').onclick=run;if(matchMedia('(prefers-reduced-motion: reduce)').matches){img.src=frames[0]}else{run();}
</script></body></html>'''.replace('FRAMES',json.dumps(data))
(root/'web_extra'/'spark-sit-preview.html').write_text(html,encoding='utf-8')
print('preview bytes',len(html))
