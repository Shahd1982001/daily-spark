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

# Both hands use the same redrawn shape, mirrored. Original body is untouched.
canvas=Image.new('RGBA',(806,730));canvas.alpha_composite(arm,(130,65));canvas.alpha_composite(arm.transpose(Image.Transpose.FLIP_LEFT_RIGHT),(130,65));canvas.alpha_composite(body,(130,65));canvas.thumbnail((480,468),Image.Resampling.LANCZOS)
out=root/'animation_lab/wave_both_hands_still.png';canvas.save(out,optimize=True)
data=base64.b64encode(out.read_bytes()).decode()
html="""<!doctype html><html lang="ar" dir="rtl"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>لقطة سبارك بيديها الجديدة</title><style>*{box-sizing:border-box}body{margin:0;min-height:100svh;display:grid;place-items:center;padding:20px;background:#fbf6ef;color:#382b26;font-family:system-ui,sans-serif}.card{width:min(100%,460px);background:#fff;border:1px solid #f0e3d6;border-radius:28px;padding:26px;text-align:center;box-shadow:0 12px 35px #8a563315}.badge{display:inline-block;border-radius:99px;background:#fff0e3;color:#b3582d;padding:7px 14px;font-size:13px;font-weight:700}h1{font-size:24px}p{line-height:1.8;color:#756158}img{display:block;width:100%;max-width:400px;margin:auto}.note{font-size:13px}</style></head><body><main class="card"><span class="badge">لقطة منفصلة • مش داخل التطبيق</span><h1>سبارك ويديها الزوز 💛</h1><p>نفس رسمة اليد الجديدة على الجهتين، قبل تجربة التلويح باليدين.</p><img src="data:image/png;base64,DATA" alt="لقطة سبارك مع اليدين المرسومتين من جديد"><p class="note">لقطة ثابتة للمراجعة، مش حركة.</p></main></body></html>""".replace('DATA',data)
(root/'web_extra/spark-both-hands-still.html').write_text(html,encoding='utf-8')
