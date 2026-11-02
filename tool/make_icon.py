import math, cairosvg, sys
exec(open(__file__.replace('make_icon.py','icon_shapes.py')).read().split('def A(')[0])
def wrap(inner,size): return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 108 108" width="{size}" height="{size}">{inner}</svg>'
HOUSE="M18 42 L54 15 L90 42 L90 87 Q90 91 86 91 L22 91 Q18 91 18 87 Z"
def A2(bg=True,rx=26):
    return (f'{"<rect width=\"108\" height=\"108\" rx=\"%d\" fill=\"%s\"/>"%(rx,K) if bg else ""}'
            f'<path d="{HOUSE}" fill="{Y}"/>' + fingerprint(54,61,1.55,K,3.0) +
            f'<circle cx="83" cy="84" r="3.8" fill="{K}"/>')
def B2(bg=True,rx=26):
    return (f'{"<rect width=\"108\" height=\"108\" rx=\"%d\" fill=\"%s\"/>"%(rx,K) if bg else ""}'
            f'<path d="M22 34 L54 12 L86 34" fill="none" stroke="{Y}" stroke-width="5" stroke-linecap="round" stroke-linejoin="round"/>'
            + fingerprint(54,64,1.65,Y,3.2) + f'<circle cx="86" cy="86" r="4" fill="{Y}"/>')
row=''.join(f'<g transform="translate({i*128},0)">{f()}</g>' for i,f in enumerate([A2,B2]))
labels=''.join(f'<text x="{i*128+54}" y="128" font-family="sans-serif" font-size="13" fill="#222" text-anchor="middle">{l}</text>' for i,l in enumerate("12"))
sheet=f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="-10 -10 256 150" width="768" height="450"><rect x="-10" y="-10" width="256" height="150" fill="#f2f2f2"/>{row}{labels}</svg>'
cairosvg.svg2png(bytestring=sheet.encode(), write_to='final_variants.png')

def export(f, outdir):
    cairosvg.svg2png(bytestring=wrap(f(rx=0),1024).encode(), write_to=f'{outdir}/icon.png')
    fg = f'<g transform="translate(54 54) scale(0.78) translate(-54 -54)">{f(bg=False)}</g>'
    cairosvg.svg2png(bytestring=wrap(fg,1024).encode(), write_to=f'{outdir}/foreground.png')
if len(sys.argv)>2:
    export({'1':A2,'2':B2}[sys.argv[1]], sys.argv[2])
