"""Standalone digital redrawn hand layer with the same wave timing and path.
Vector silhouette and gradient are drawn once and rendered into separate frames;
original body, face, other hand and feet remain unchanged. Not hand-drawn frames.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,cairosvg,io,math,base64,json
root=Path(__file__).resolve().parents[1];base=Image.open(root/'assets/mascot/spark.png').convert('RGBA');w,h=base.size
Y,X=np.indices((h,w));edge=np.interp(np.arange(h),[300,310,320,330,340,350,360,370,380,390,400,410,420,430,440,450,460,470,480,490,500],[64,63,62,62,62,62,62,64,65,67,70,73,77,82,87,93,101,110,120,132,145])[:,None]
cut=(Y>=315)&(Y<490)&((X>545-edge)|(X<edge));a=np.array(base).copy();a[:,:,3]=np.where(cut,0,a[:,:,3]);body=Image.fromarray(a)
# Entire hand, including the section previously hidden behind the body.
svg='''<svg xmlns="http://www.w3.org/2000/svg" width="546" height="430" viewBox="0 0 546 430"><defs><linearGradient id="g" x1="0" y1="0" x2="0.85" y2="1"><stop stop-color="#e7a064"/><stop offset=".53" stop-color="#c09265"/><stop offset="1" stop-color="#8d9970"/></linearGradient></defs><path d="M 480 320 C 494 325 508 346 518 368 C 530 394 536 417 532 440 C 529 463 514 477 497 476 C 480 475 469 465 465 448 C 460 425 461 394 463 370 C 465 345 468 328 480 320 Z" fill="url(#g)" stroke="#5d2c20" stroke-width="10" stroke-linejoin="round" stroke-linecap="round"/><path d="M 496 439 C 496 454 508 459 516 448" fill="none" stroke="#925a3e" stroke-width="6" stroke-linecap="round"/><path d="M 510 363 C 516 381 518 397 519 411" fill="none" stroke="#f1ba80" stroke-width="7" stroke-linecap="round" opacity=".65"/></svg>'''.replace('height="430"','height="546"').replace('viewBox="0 0 546 430"','viewBox="0 0 546 546"')
arm=Image.open(io.BytesIO(cairosvg.svg2png(bytestring=svg.encode(),output_width=546,output_height=546))).convert('RGBA');padded=Image.new('RGBA',(w+300,h+300));padded.alpha_composite(arm,(150,150))
left_padded=Image.new('RGBA',(w+300,h+300));left_padded.alpha_composite(arm.transpose(Image.Transpose.FLIP_LEFT_RIGHT),(150,150))
W,H=806,730;ox,oy=130,65;out=root/'animation_lab/wave_both';out.mkdir(exist_ok=True);frames=[]
angles=[0]*7+[120*(.5-.5*math.cos(4*math.pi*i/72)) for i in range(1,73)]+[0]*7
for i,angle in enumerate(angles):
 canvas=Image.new('RGBA',(W,H));rot=padded.rotate(angle,resample=Image.Resampling.BICUBIC,center=(479+150,320+150));canvas.alpha_composite(rot,(ox-150,oy-150));left=left_padded.rotate(-angle,resample=Image.Resampling.BICUBIC,center=(67+150,320+150));canvas.alpha_composite(left,(ox-150,oy-150));canvas.alpha_composite(body,(ox,oy));canvas.thumbnail((320,314),Image.Resampling.LANCZOS);path=out/f'frame_{i:02}.png';canvas.save(path,optimize=True);frames.append('data:image/png;base64,'+base64.b64encode(path.read_bytes()).decode())
old=(root/'web_extra/spark-original-wave-preview.html').read_text();start=old.index('const frames=')+len('const frames=');end=old.index(';const img=',start);html=old[:start]+json.dumps(frames)+old[end:];html=html.replace('نفس اليد الأصلية تتحرك فوق ولوطة مرتين، والجسم ثابت.','اليدين الزوز يلوّحن فوق ولوطة بنفس الحركة السلسة.').replace('تجربة منفصلة بتحريك اليد الأصلية رقمياً، مش رسم جديد؛ ما زالت للمراجعة.','تجربة منفصلة لليدين المرسومتين رقمياً، مش مضافة للتطبيق.');(root/'web_extra/spark-both-wave-preview.html').write_text(html)
