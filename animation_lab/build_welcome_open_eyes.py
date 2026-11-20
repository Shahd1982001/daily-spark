"""Digitally separated reusable feet and open-eyed welcome animation studies.
Both hands are digitally redrawn, body and original eyes retain original artwork.
The leaning pose holds steady while the waving arm moves.
"""
from pathlib import Path
from PIL import Image
import numpy as np, cv2, math, io, cairosvg, base64,json
root=Path(__file__).resolve().parents[1];base=Image.open(root/'assets/mascot/spark.png').convert('RGBA');a=np.array(base);h,w=a.shape[:2];yy,xx=np.indices((h,w))
edge=np.interp(np.arange(w),[0,70,100,130,160,190,230,273,316,356,386,416,446,476,546],[330,430,468,491,506,516,526,531,526,516,506,491,468,430,330])[None,:]
legzone=((xx>130)&(xx<260))|((xx>286)&(xx<416)); lower=legzone&(yy>edge-14)
folder=root/'animation_lab/mascot_separated_legs';folder.mkdir(exist_ok=True)
feet=[]
for name,sel in [('left',(xx>130)&(xx<260)),('right',(xx>286)&(xx<416))]:
 f=a.copy();f[:,:,3]=np.where(lower&sel,f[:,:,3],0);im=Image.fromarray(f);im.save(folder/(name+'.png'));feet.append(im)
yedge=np.interp(np.arange(h),[300,310,320,330,340,350,360,370,380,390,400,410,420,430,440,450,460,470,480,490,500],[64,63,62,62,62,62,62,64,65,67,70,73,77,82,87,93,101,110,120,132,145])[:,None]
handcut=(yy>=315)&(yy<490)&((xx>545-yedge)|(xx<yedge))
upper=a.copy();upper[:,:,3]=np.where((legzone&(yy>edge))|handcut,0,upper[:,:,3]);upper=Image.fromarray(upper);upper.save(folder/'body_without_legs_and_hands.png')
svg='''<svg xmlns="http://www.w3.org/2000/svg" width="546" height="546"><defs><linearGradient id="g" x1="0" y1="0" x2=".85" y2="1"><stop stop-color="#e7a064"/><stop offset=".53" stop-color="#c09265"/><stop offset="1" stop-color="#8d9970"/></linearGradient></defs><path d="M480 320 C494 325 508 346 518 368 C530 394 536 417 532 440 C529 463 514 477 497 476 C480 475 469 465 465 448 C460 425 461 394 463 370 C465 345 468 328 480 320 Z" fill="url(#g)" stroke="#5d2c20" stroke-width="10" stroke-linejoin="round" stroke-linecap="round"/><path d="M496 439 C496 454 508 459 516 448" fill="none" stroke="#925a3e" stroke-width="6" stroke-linecap="round"/><path d="M510 363 C516 381 518 397 519 411" fill="none" stroke="#f1ba80" stroke-width="7" stroke-linecap="round" opacity=".65"/></svg>'''
arm=Image.open(io.BytesIO(cairosvg.svg2png(bytestring=svg.encode()))).convert('RGBA');right=Image.new('RGBA',(w+300,h+300));right.alpha_composite(arm,(150,150));left=arm.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
for lean in (False,True):
 frames=[];out=root/('animation_lab/welcome_open_lean' if lean else 'animation_lab/welcome_open_tilt');out.mkdir(exist_ok=True)
 for i in range(106):
  # Ease into a pose, hold it while waving, then ease out. No body movement during hold.
  u=min(1,max(0,(i-8)/14),max(0,(98-i)/14));t=u*u*(3-2*u)
  wave=max(0,min(1,(i-18)/64));angle=120*(.5-.5*math.cos(4*math.pi*wave)) if 18<i<82 else 0
  stage=Image.new('RGBA',(806,730));stage.alpha_composite(feet[1],(130,65));stage.alpha_composite(feet[0],(130,65-round(10*t) if lean else 65))
  top=Image.new('RGBA',(806,730));top.alpha_composite(left,(130,65));top.alpha_composite(right.rotate(angle,Image.Resampling.BICUBIC,center=(629,470)),(-20,-85));top.alpha_composite(upper,(130,65))
  # Lean as a whole above separately held feet; gentle upper-body tilt otherwise.
  top=top.rotate((-7 if lean else -3)*t,Image.Resampling.BICUBIC,center=(130+355 if lean else 130+273,65+527))
  stage.alpha_composite(top);stage.thumbnail((320,314),Image.Resampling.LANCZOS);path=out/f'frame_{i:03}.png';stage.save(path,optimize=True);frames.append('data:image/png;base64,'+base64.b64encode(path.read_bytes()).decode())
 html=(root/'web_extra/spark-welcome-tilt-preview.html').read_text();s=html.index('const frames=')+len('const frames=');e=html.index(';const img=',s);html=html[:s]+json.dumps(frames)+html[e:]
 html=html.replace('ترحيب وميلان الراس 💛','ترحيب على رجل وحدة 💛' if lean else 'ترحيب وعيون مفتوحات 💛').replace('تلوّح بيد مع ميلان خفيف للراس وفرحة.','تلوّح وعيونها مفتوحات، وتثبت على رجل وحدة.' if lean else 'تلوّح وعيونها مفتوحات، مع ميلان خفيف وفرحة.').replace('معاينة منفصلة للتعبير والحركة، مش داخل التطبيق.','معاينة منفصلة؛ اليدين والرجلين طبقات مستقلة، مش داخل التطبيق.')
 dest='spark-welcome-open-one-foot.html' if lean else 'spark-welcome-open-tilt.html';(root/'web_extra'/dest).write_text(html,encoding='utf8');print(dest)
