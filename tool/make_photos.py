"""Disegna le illustrazioni delle foto della storia (SVG -> PNG)."""
import cairosvg, os, sys
OUT = sys.argv[1] if len(sys.argv) > 1 else 'assets/photos'
W, H = 800, 600
VIGN = '''<radialGradient id="v" cx="50%" cy="50%" r="75%"><stop offset="55%" stop-color="#000" stop-opacity="0"/><stop offset="100%" stop-color="#000" stop-opacity="0.55"/></radialGradient>'''
def svg(defs, body):
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}"><defs>{VIGN}{defs}</defs>{body}<rect width="{W}" height="{H}" fill="url(#v)"/></svg>'
def bricks(x0, y0, w, h, color, mortar, bw=46, bh=20):
    out = f'<rect x="{x0}" y="{y0}" width="{w}" height="{h}" fill="{mortar}"/>'
    row = 0
    y = y0
    while y < y0 + h:
        off = (bw // 2) if row % 2 else 0
        x = x0 - off
        while x < x0 + w:
            xx = max(x, x0); ww = min(x + bw - 3, x0 + w) - xx
            hh = min(bh - 3, y0 + h - y)
            if ww > 0 and hh > 0:
                shade = ['#c9b79a', '#bfae90', '#d2c1a5', '#c4b295'][(row * 7 + x // bw) % 4] if color is None else color
                out += f'<rect x="{xx}" y="{y}" width="{ww}" height="{hh}" fill="{shade}"/>'
            x += bw
        y += bh; row += 1
    return out

photos = {}

# Piazza, festa di settembre
flags = ''.join(f'<path d="M{x} {170+((x//40)%2)*6} l14 26 l14 -26 z" fill="{c}"/>' for x, c in zip(range(40, 780, 30), ['#e05a47', '#f2c14e', '#4f86c6', '#6bbf73'] * 10))
photos['f0'] = svg('<linearGradient id="sky" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#f19a5b"/><stop offset="1" stop-color="#7c4a6b"/></linearGradient>',
    '<rect width="800" height="600" fill="url(#sky)"/>'
    '<rect x="0" y="140" width="180" height="460" fill="#5a3f4f"/><rect x="620" y="120" width="180" height="480" fill="#4e3646"/>'
    + ''.join(f'<rect x="{x}" y="{y}" width="34" height="48" fill="#f6d07a" opacity="0.8"/>' for x in (40, 110) for y in (200, 300)) +
    ''.join(f'<rect x="{x}" y="{y}" width="34" height="48" fill="#2b1f2a"/>' for x in (660, 730) for y in (180, 280)) +
    '<path d="M0 168 Q400 230 800 160" stroke="#222" stroke-width="2" fill="none"/>' + flags +
    '<rect x="300" y="380" width="220" height="70" fill="#3b2b33"/><rect x="290" y="372" width="240" height="12" fill="#2a1e24"/>'
    '<rect x="0" y="450" width="800" height="150" fill="#6b5560"/>'
    + ''.join(f'<rect x="{x}" y="478" width="26" height="30" rx="3" fill="#e9e4dc" opacity="0.85"/>' for x in range(200, 620, 40)))

# Muro tra il 12 e il 16 (dettaglio: campanello murato al centro)
photos['2b'] = svg('',
    '<rect width="800" height="600" fill="#9a8c78"/>'
    '<rect x="0" y="0" width="230" height="600" fill="#8a7d6b"/><rect x="570" y="0" width="230" height="600" fill="#857867"/>'
    '<rect x="40" y="170" width="150" height="330" rx="70" ry="70" fill="#3d5a3c"/><rect x="40" y="240" width="150" height="260" fill="#3d5a3c"/>'
    '<rect x="610" y="170" width="150" height="330" fill="#5b3a2a"/>'
    '<rect x="95" y="120" width="40" height="30" rx="4" fill="#20304f"/><text x="115" y="142" font-family="sans-serif" font-size="20" font-weight="bold" fill="#fff" text-anchor="middle">12</text>'
    '<rect x="665" y="120" width="40" height="30" rx="4" fill="#20304f"/><text x="685" y="142" font-family="sans-serif" font-size="20" font-weight="bold" fill="#fff" text-anchor="middle">16</text>'
    + bricks(230, 60, 340, 480, None, '#a89a84') +
    # campanello murato
    '<rect x="352" y="238" width="96" height="96" rx="6" fill="#b9ab92" stroke="#7d705d" stroke-width="3"/>'
    '<rect x="372" y="254" width="56" height="18" fill="#8f8270"/><circle cx="400" cy="304" r="14" fill="#7a6d5b"/><circle cx="400" cy="304" r="7" fill="#5c5244"/>'
    '<path d="M352 250 Q380 262 410 246 T448 258 L448 238 L352 238 Z" fill="#d8ccb4" opacity="0.9"/>'
    '<rect x="0" y="540" width="800" height="60" fill="#5f574c"/>')

# Chiave con cartellino (dettaglio: il cartellino)
photos['3c'] = svg('<linearGradient id="wood" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#6b4a32"/><stop offset="1" stop-color="#3e2a1d"/></linearGradient>',
    '<rect width="800" height="600" fill="url(#wood)"/>'
    + ''.join(f'<path d="M0 {y} Q400 {y+18} 800 {y-6}" stroke="#2f2016" stroke-width="2" fill="none" opacity="0.5"/>' for y in range(40, 600, 55)) +
    # chiave
    '<g transform="rotate(-18 300 330)">'
    '<circle cx="200" cy="330" r="62" fill="none" stroke="#c99a3a" stroke-width="26"/>'
    '<rect x="255" y="316" width="250" height="28" fill="#c99a3a"/>'
    '<path d="M440 344 v34 h18 v-34 M475 344 v24 h16 v-24" fill="#c99a3a" stroke="#c99a3a" stroke-width="2"/>'
    '<rect x="255" y="316" width="250" height="8" fill="#e8c46a" opacity="0.6"/></g>'
    # spago e cartellino
    '<path d="M215 270 Q330 210 470 250" stroke="#d8d2c4" stroke-width="3" fill="none"/>'
    '<g transform="rotate(8 560 300)"><rect x="460" y="200" width="200" height="230" rx="10" fill="#efe6d2" stroke="#b8ab90" stroke-width="3"/>'
    '<circle cx="490" cy="235" r="10" fill="#6b4a32" stroke="#b8ab90" stroke-width="3"/>'
    '<text x="565" y="355" font-family="serif" font-size="110" fill="#3b4f7a" opacity="0.75" text-anchor="middle">14</text></g>')

# Foto del 1989 (seppia): donna davanti al portone verde col 14
photos['4d'] = svg('<filter id="sep"><feColorMatrix type="matrix" values="0.39 0.77 0.19 0 0  0.35 0.69 0.17 0 0  0.27 0.53 0.13 0 0  0 0 0 1 0"/></filter>',
    '<g filter="url(#sep)"><rect width="800" height="600" fill="#c8b48e"/>'
    '<rect x="0" y="0" width="800" height="600" fill="#b3a07a"/>'
    '<rect x="270" y="110" width="260" height="420" fill="#3f6b45"/><rect x="290" y="130" width="100" height="380" fill="#356040"/><rect x="410" y="130" width="100" height="380" fill="#356040"/>'
    '<rect x="370" y="60" width="60" height="40" rx="4" fill="#20304f"/><text x="400" y="90" font-family="sans-serif" font-size="28" font-weight="bold" fill="#fff" text-anchor="middle">14</text>'
    '<rect x="600" y="140" width="110" height="140" fill="#6e5f47"/><rect x="610" y="150" width="90" height="120" fill="#e9dcc0"/>'
    # donna
    '<circle cx="400" cy="250" r="34" fill="#d9b48f"/><path d="M366 240 Q400 196 434 240 Q430 214 400 210 Q370 214 366 240" fill="#5a4a3a"/>'
    '<path d="M340 560 L352 320 Q400 286 448 320 L460 560 Z" fill="#2a2a30"/>'
    '<rect x="384" y="282" width="32" height="20" fill="#d9b48f"/>'
    '<rect x="0" y="530" width="800" height="70" fill="#8f7f62"/></g>'
    '<rect width="800" height="600" fill="#a0784a" opacity="0.35"/>'
    '<rect x="14" y="14" width="772" height="572" fill="none" stroke="#f3ecdc" stroke-width="22"/>')

# Prima pagina della Gazzetta (testata inventata)
lines = ''.join(f'<rect x="{x}" y="{y}" width="{w}" height="7" fill="#9b968c"/>' for x, w in ((60, 300), (440, 300)) for y in range(330, 560, 16))
photos['7g1'] = svg('',
    '<rect width="800" height="600" fill="#2b2b2b"/>'
    '<g transform="rotate(-3 400 300)"><rect x="40" y="30" width="720" height="560" fill="#f1ede3"/>'
    '<text x="400" y="92" font-family="serif" font-size="38" font-weight="bold" fill="#1d1d1d" text-anchor="middle">GAZZETTA DI BORGO CALCE</text>'
    '<rect x="60" y="106" width="680" height="3" fill="#1d1d1d"/>'
    '<text x="400" y="150" font-family="serif" font-size="30" font-weight="bold" fill="#1d1d1d" text-anchor="middle">Via dei Tigli, il civico che non c\'era</text>'
    '<rect x="60" y="172" width="680" height="140" fill="#77706a"/>' + bricks(300, 182, 200, 120, '#b5a88f', '#8c8273', bw=30, bh=14) +
    '<rect x="80" y="232" width="150" height="70" fill="#d9a521"/><rect x="100" y="216" width="70" height="24" fill="#d9a521"/><circle cx="105" cy="304" r="12" fill="#222"/><circle cx="205" cy="304" r="12" fill="#222"/>'
    + lines + '</g>')

# Lettera del 1994 nella cartella privata
txt = ['Borgo Calce, 12 aprile 1994', '', 'Caro Ettore,', 'il muro tiene.', 'Il pane di ieri era buono.', 'Grazie per la radio:', 'la sera mi fa compagnia.', '', '              E.']
text = ''.join(f'<text x="150" y="{150+i*44}" font-family="serif" font-style="italic" font-size="30" fill="#2b3a66">{t}</text>' for i, t in enumerate(txt))
photos['priv1'] = svg('',
    '<rect width="800" height="600" fill="#3a3330"/>'
    '<g transform="rotate(2 400 300)"><rect x="110" y="70" width="580" height="480" fill="#efe5cc"/>'
    '<line x1="110" y1="310" x2="690" y2="310" stroke="#d6caa9" stroke-width="2"/><line x1="400" y1="70" x2="400" y2="550" stroke="#d6caa9" stroke-width="2"/>'
    + text + '</g>')

os.makedirs(OUT, exist_ok=True)
for name, s in photos.items():
    cairosvg.svg2png(bytestring=s.encode(), write_to=f'{OUT}/{name}.png')
print('ok', list(photos))
