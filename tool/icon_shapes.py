import math, cairosvg
Y="#FFD21F"; K="#111114"
def fingerprint(cx,cy,s,color,w):
    def arc(rx,ry,a1,a2):
        p=lambda a:(cx+rx*math.cos(math.radians(a)), cy+ry*math.sin(math.radians(a)))
        x1,y1=p(a1); x2,y2=p(a2); large=1 if (a2-a1)%360>180 else 0
        return f'M{x1:.2f} {y1:.2f} A{rx:.2f} {ry:.2f} 0 {large} 1 {x2:.2f} {y2:.2f}'
    rings=[(1,[(200,520)]),(2,[(150,330),(350,500)]),(3,[(130,280),(300,410)]),
           (4,[(165,300),(320,395)]),(5,[(190,250),(268,350)]),(6,[(200,335)])]
    out=''
    for k,segs in rings:
        rx=k*2.6*s; ry=rx*1.3
        for a1,a2 in segs: out+=f'<path d="{arc(rx,ry,a1,a2)}"/>'
    return f'<g fill="none" stroke="{color}" stroke-width="{w}" stroke-linecap="round">{out}</g>'
HOUSE="M20 42 L54 16 L88 42 L88 86 Q88 90 84 90 L24 90 Q20 90 20 86 Z"
def A(bg=True,rx=26):  # casa simmetrica gialla, impronta grande
    return (f'{"<rect width=\"108\" height=\"108\" rx=\"%d\" fill=\"%s\"/>"%(rx,K) if bg else ""}'
            f'<path d="{HOUSE}" fill="{Y}"/>' + fingerprint(54,64,1.2,K,2.5) +
            f'<circle cx="80" cy="82" r="3.8" fill="{K}"/>')
def B(bg=True,rx=26):  # impronta gigante gialla su nero, tetto come segno
    tape=f'<g transform="rotate(-35 54 54)"><rect x="-20" y="80" width="150" height="12" fill="{Y}"/>' + ''.join(f'<rect x="{x}" y="80" width="6" height="12" fill="{K}" transform="skewX(-35)"/>' for x in range(-10,170,14)) + '</g>'
    return (f'<defs><clipPath id="cb"><rect width="108" height="108" rx="{rx}"/></clipPath></defs><g clip-path="url(#cb)">{"<rect width=\"108\" height=\"108\" rx=\"%d\" fill=\"%s\"/>"%(rx,K) if bg else ""}'
            f'<path d="M30 26 L54 10 L78 26" fill="none" stroke="{Y}" stroke-width="4.5" stroke-linecap="round" stroke-linejoin="round"/>'
            + fingerprint(54,62,1.45,Y,2.9) + tape +
            f'<circle cx="85" cy="26" r="3.6" fill="{Y}"/></g>')
def C(bg=True,rx=26):  # giallo pieno, casa contorno nera, impronta dentro
    return (f'{"<rect width=\"108\" height=\"108\" rx=\"%d\" fill=\"%s\"/>"%(rx,Y) if bg else ""}'
            f'<path d="{HOUSE}" fill="none" stroke="{K}" stroke-width="4.5" stroke-linejoin="round"/>'
            + fingerprint(54,64,1.2,K,2.5) + f'<circle cx="80" cy="82" r="3.8" fill="{K}"/>')
def wrap(inner,size): return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 108 108" width="{size}" height="{size}">{inner}</svg>'
row=''.join(f'<g transform="translate({i*128},0)">{f()}</g>' for i,f in enumerate([A,B,C]))
labels=''.join(f'<text x="{i*128+54}" y="128" font-family="sans-serif" font-size="13" fill="#222" text-anchor="middle">{l}</text>' for i,l in enumerate("ABC"))
sheet=f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="-10 -10 384 150" width="1152" height="450"><rect x="-10" y="-10" width="384" height="150" fill="#f2f2f2"/>{row}{labels}</svg>'
cairosvg.svg2png(bytestring=sheet.encode(), write_to='variants.png')
import sys
if len(sys.argv)>1:
    f={'A':A,'B':B,'C':C}[sys.argv[1]]
    cairosvg.svg2png(bytestring=wrap(f(rx=0),1024).encode(), write_to='icon.png')
    cairosvg.svg2png(bytestring=wrap(f(bg=False),1024).encode(), write_to='foreground.png')
    cairosvg.svg2png(bytestring=wrap(f(),512).encode(), write_to='preview.png')
