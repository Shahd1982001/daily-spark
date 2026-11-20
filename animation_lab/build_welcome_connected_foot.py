"""Two standalone welcome previews using existing happy frames and redrawn arms.
Upper-head tilt is from approved happy expression; second pose leans around one foot.
All motion is generated digitally; frames are not individually drawn.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,math,base64,json,io,cairosvg,cv2
root=Path(__file__).resolve().parents[1];base=Image.open(root/'assets/mascot/spark.png').convert('RGBA');w,h=base.size
Y,X=np.indices((h,w));edge=np.interp(np.arange(h),[300,310,320,330,340,350,360,370,380,390,400,410,420,430,440,450,460,470,480,490,500],[64,63,62,62,62,62,62,64,65,67,70,73,77,82,87,93,101,110,120,132,145])[:,None];cut=(Y>=315)&(Y<490)&((X>545-edge)|(X<edge))
svg='''<svg xmlns="http://www.w3.org/2000/svg" width="546" height="546"><defs><linearGradient id="g" x1="0" y1="0" x2=".85" y2="1"><stop stop-color="#e7a064"/><stop offset=".53" stop-color="#c09265"/><stop offset="1" stop-color="#8d9970"/></linearGradient></defs><path d="M480 320 C494 325 508 346 518 368 C530 394 536 417 532 440 C529 463 514 477 497 476 C480 475 469 465 465 448 C460 425 461 394 463 370 C465 345 468 328 480 320 Z" fill="url(#g)" stroke="#5d2c20" stroke-width="10" stroke-linejoin="round" stroke-linecap="round"/><path d="M496 439 C496 454 508 459 516 448" fill="none" stroke="#925a3e" stroke-width="6" stroke-linecap="round"/><path d="M510 363 C516 381 518 397 519 411" fill="none" stroke="#f1ba80" stroke-width="7" stroke-linecap="round" opacity=".65"/></svg>'''
arm=Image.open(io.BytesIO(cairosvg.svg2png(bytestring=svg.encode()))).convert('RGBA');right=Image.new('RGBA',(w+300,h+300));right.alpha_composite(arm,(150,150));left=arm.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
# Existing full happy images already include expression plus gentle local head tilt.
happy=[Image.open(root/f'animation_lab/happy_lashes_eyes_open/frame_{i:02}.png').convert('RGBA').resize((w,h),Image.Resampling.LANCZOS) for i in range(52)]
for lean in (True,):
 frames=[];folder=root/('animation_lab/welcome_foot_connected' if lean else 'animation_lab/welcome_original_open_tilt');folder.mkdir(exist_ok=True)
 for i in range(86):
  wave=max(0,min(1,(i-7)/72)); angle=120*(.5-.5*math.cos(4*math.pi*wave)) if 7<i<79 else 0
  level=min(1,max(0,(i-7)/12),max(0,(79-i)/12));level=level*level*(3-2*level);idx=0 if level==0 else min(18,6+round(level*12))
  # Use the same original body at rest; the approved happy frame during greeting.
  src=base if level==0 else happy[idx];a=np.array(src).copy()
  # Make two genuinely separate foot layers from the ORIGINAL art, not rotated with the body.
  boundary=np.interp(np.arange(w),[0,70,100,130,160,190,230,273,316,356,386,416,446,476,546],[330,430,468,491,506,516,526,531,526,516,506,491,468,430,330])[None,:]
  lzone=(X>130)&(X<260);rzone=(X>286)&(X<416);feet=[];original=np.array(base)
  for j,z in enumerate((lzone,rzone)):
   # Continue the upper part behind the body. Keep the visible original foot;
   # suppress the old body-contour fragment that otherwise travels with it.
   f=original.copy();f[:,:,3]=np.where(z&(Y>boundary+5),f[:,:,3],0)
   backing=Image.new('RGBA',(w,h));d=ImageDraw.Draw(backing)
   points=[(150,475),(250,490),(250,557),(161,548)] if j==0 else [(296,490),(396,475),(385,548),(296,557)]
   d.polygon(points,fill=(139,158,120,255))
   d.line([points[0],points[3]],fill=(91,46,31,255),width=8);d.line([points[1],points[2]],fill=(91,46,31,255),width=8)
   backing.alpha_composite(Image.fromarray(f));feet.append(backing)
  a[:,:,3]=np.where(cut|((lzone|rzone)&(Y>boundary)),0,a[:,:,3]);body=Image.fromarray(a)
  # Same body, face, wave path, pose and timing as the original second preview.
  top=Image.new('RGBA',(806,730));top.alpha_composite(left,(130,65));r=right.rotate(angle,Image.Resampling.BICUBIC,center=(629,470));top.alpha_composite(r,(-20,-85));top.alpha_composite(body,(130,65))
  rgba=np.asarray(top).copy();count,labels,stats,_=cv2.connectedComponentsWithStats((rgba[:,:,3]>40).astype('uint8'),8)
  if count>1:
   biggest=1+np.argmax(stats[1:,cv2.CC_STAT_AREA]);keep=cv2.dilate((labels==biggest).astype('uint8'),np.ones((3,3),np.uint8))>0;rgba[:,:,3]=np.where(keep,rgba[:,:,3],0);top=Image.fromarray(rgba)
  top=top.rotate(-8*level,Image.Resampling.BICUBIC,center=(130+355,65+525))
  # Support foot stays upright at exactly the same coordinates in every frame.
  c=Image.new('RGBA',(806,730));c.alpha_composite(feet[1],(130,65))
  # Lifted foot alone tilts clockwise and moves outwards/up; no redraw/resize.
  lifted=Image.new('RGBA',(806,730));lifted.alpha_composite(feet[0],(130,65))
  lifted=lifted.rotate(-17*level,Image.Resampling.BICUBIC,center=(130+230,65+514))
  c.alpha_composite(lifted,(-round(10*level),-round(8*level)));c.alpha_composite(top)
  c.thumbnail((320,314),Image.Resampling.LANCZOS);path=folder/f'frame_{i:02}.png';c.save(path,optimize=True);frames.append('data:image/png;base64,'+base64.b64encode(path.read_bytes()).decode())
 old=(root/'web_extra/spark-redrawn-wave-preview.html').read_text();s=old.index('const frames=')+len('const frames=');e=old.index(';const img=',s);html=old[:s]+json.dumps(frames)+old[e:]
 html=html.replace('تلويحة سبارك 👋','ترحيب على رجل وحدة 💛' if lean else 'ترحيب وميلان الراس 💛').replace('يد مرسومة من جديد بشكل كامل وخط متصل، مع نفس الحركة.','نفس الحركة مع تنعيم اتصال الرجلين بالجسم.' if lean else 'نفس الترحيب وميلان الراس، بعيون مفتوحات.').replace('تجربة منفصلة: رسم رقمي جديد لليد وتحريكها، لم تُضف للتطبيق.','معاينة منفصلة للتعبير والحركة، مش داخل التطبيق.')
 name='spark-welcome-connected-foot.html' if lean else 'spark-welcome-original-open-tilt.html';(root/'web_extra'/name).write_text(html,encoding='utf-8')
 print(name,len(frames))
