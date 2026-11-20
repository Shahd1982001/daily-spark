"""Two standalone welcome previews using existing happy frames and redrawn arms.
Upper-head tilt is from approved happy expression; second pose leans around one foot.
All motion is generated digitally; frames are not individually drawn.
"""
from pathlib import Path
from PIL import Image
import numpy as np,math,base64,json,io,cairosvg,cv2
root=Path(__file__).resolve().parents[1];base=Image.open(root/'assets/mascot/spark.png').convert('RGBA');w,h=base.size
Y,X=np.indices((h,w));edge=np.interp(np.arange(h),[300,310,320,330,340,350,360,370,380,390,400,410,420,430,440,450,460,470,480,490,500],[64,63,62,62,62,62,62,64,65,67,70,73,77,82,87,93,101,110,120,132,145])[:,None];cut=(Y>=315)&(Y<490)&((X>545-edge)|(X<edge))
svg='''<svg xmlns="http://www.w3.org/2000/svg" width="546" height="546"><defs><linearGradient id="g" x1="0" y1="0" x2=".85" y2="1"><stop stop-color="#e7a064"/><stop offset=".53" stop-color="#c09265"/><stop offset="1" stop-color="#8d9970"/></linearGradient></defs><path d="M480 320 C494 325 508 346 518 368 C530 394 536 417 532 440 C529 463 514 477 497 476 C480 475 469 465 465 448 C460 425 461 394 463 370 C465 345 468 328 480 320 Z" fill="url(#g)" stroke="#5d2c20" stroke-width="10" stroke-linejoin="round" stroke-linecap="round"/><path d="M496 439 C496 454 508 459 516 448" fill="none" stroke="#925a3e" stroke-width="6" stroke-linecap="round"/><path d="M510 363 C516 381 518 397 519 411" fill="none" stroke="#f1ba80" stroke-width="7" stroke-linecap="round" opacity=".65"/></svg>'''
arm=Image.open(io.BytesIO(cairosvg.svg2png(bytestring=svg.encode()))).convert('RGBA');right=Image.new('RGBA',(w+300,h+300));right.alpha_composite(arm,(150,150));left=arm.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
# Existing full happy images already include expression plus gentle local head tilt.
happy=[Image.open(root/f'animation_lab/happy_closed_lashes/frame_{i:02}.png').convert('RGBA').resize((w,h),Image.Resampling.LANCZOS) for i in range(52)]
for lean in (False,True):
 frames=[];folder=root/('animation_lab/welcome_one_foot' if lean else 'animation_lab/welcome_tilt');folder.mkdir(exist_ok=True)
 for i in range(86):
  wave=max(0,min(1,(i-7)/72)); angle=120*(.5-.5*math.cos(4*math.pi*wave)) if 7<i<79 else 0
  level=min(1,max(0,(i-7)/12),max(0,(79-i)/12));idx=0 if level==0 else min(18,6+round(level*12))
  # Use the same original body at rest; the approved happy frame during greeting.
  src=base if level==0 else happy[idx];a=np.array(src).copy();a[:,:,3]=np.where(cut,0,a[:,:,3]);body=Image.fromarray(a)
  c=Image.new('RGBA',(806,730));c.alpha_composite(left,(130,65));r=right.rotate(angle,Image.Resampling.BICUBIC,center=(629,470));c.alpha_composite(r,(-20,-85));c.alpha_composite(body,(130,65))
  # Remove tiny isolated remnants from the cropped expression arms.
  rgba=np.asarray(c).copy(); count,labels,stats,_=cv2.connectedComponentsWithStats((rgba[:,:,3]>40).astype('uint8'),8)
  if count>1:
   biggest=1+np.argmax(stats[1:,cv2.CC_STAT_AREA]);keep=cv2.dilate((labels==biggest).astype('uint8'),np.ones((3,3),np.uint8))>0;rgba[:,:,3]=np.where(keep,rgba[:,:,3],0);c=Image.fromarray(rgba)
  if lean:
   # Rotate around the foot on the right; other foot rises with the body.
   c=c.rotate(-8*level,Image.Resampling.BICUBIC,center=(130+355,65+525))
  c.thumbnail((320,314),Image.Resampling.LANCZOS);path=folder/f'frame_{i:02}.png';c.save(path,optimize=True);frames.append('data:image/png;base64,'+base64.b64encode(path.read_bytes()).decode())
 old=(root/'web_extra/spark-redrawn-wave-preview.html').read_text();s=old.index('const frames=')+len('const frames=');e=old.index(';const img=',s);html=old[:s]+json.dumps(frames)+old[e:]
 html=html.replace('تلويحة سبارك 👋','ترحيب على رجل وحدة 💛' if lean else 'ترحيب وميلان الراس 💛').replace('يد مرسومة من جديد بشكل كامل وخط متصل، مع نفس الحركة.','تلوّح بيد وتميل على رجل وحدة بفرحة.' if lean else 'تلوّح بيد مع ميلان خفيف للراس وفرحة.').replace('تجربة منفصلة: رسم رقمي جديد لليد وتحريكها، لم تُضف للتطبيق.','معاينة منفصلة للتعبير والحركة، مش داخل التطبيق.')
 name='spark-welcome-one-foot-preview.html' if lean else 'spark-welcome-tilt-preview.html';(root/'web_extra'/name).write_text(html,encoding='utf-8')
 print(name,len(frames))
