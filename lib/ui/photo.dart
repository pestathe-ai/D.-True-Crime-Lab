import 'package:flutter/material.dart';

import '../services/game.dart';
import '../story/model.dart';
import 'theme.dart';

/// Apre una foto a tutto schermo: si può ingrandire e toccare i dettagli.
Future<void> openPhoto(BuildContext context, Drop drop, Game game) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => PhotoViewer(drop: drop, game: game),
    ),
  );
}

class PhotoViewer extends StatefulWidget {
  const PhotoViewer({super.key, required this.drop, required this.game});

  final Drop drop;
  final Game game;

  @override
  State<PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer> {
  Offset? _tap;

  Future<void> _onTap(Offset p, Size size) async {
    setState(() => _tap = p);
    final h = widget.drop.hotspot;
    if (h == null) return;
    final x = p.dx / size.width;
    final y = p.dy / size.height;
    if (!h.contains(x, y)) return;
    final already = widget.game.detailFound(h);
    if (!already) await widget.game.findDetail(h);
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            already
                ? 'Hai già trovato questo dettaglio.'
                : '🔍 Dettaglio scoperto! ${h.found}\nTrovi l\'appunto nella '
                    'cronologia.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.drop;
    final h = d.hotspot;
    final found = h != null && widget.game.detailFound(h);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(d.title ?? 'Foto', style: sora(16, weight: 600)),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: InteractiveViewer(
                maxScale: 5,
                child: LayoutBuilder(
                  builder: (context, c) {
                    final w = c.maxWidth;
                    final size = Size(w, w * 0.75);
                    return GestureDetector(
                      onTapUp: (e) => _onTap(e.localPosition, size),
                      child: SizedBox(
                        width: size.width,
                        height: size.height,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: d.image != null
                                  ? Image.asset(d.image!, fit: BoxFit.fill)
                                  : const ColoredBox(color: Pal.surface2),
                            ),
                            if (found && h != null)
                              Positioned(
                                left: h.left * size.width,
                                top: h.top * size.height,
                                width: h.width * size.width,
                                height: h.height * size.height,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Pal.accent,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            if (_tap != null && !found)
                              Positioned(
                                left: _tap!.dx - 18,
                                top: _tap!.dy - 18,
                                child: IgnorePointer(
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white54,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            color: Pal.surface,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.body,
                  style: const TextStyle(
                    color: Pal.text,
                    fontStyle: FontStyle.italic,
                    height: 1.45,
                  ),
                ),
                if (h != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    found
                        ? '✓ Hai trovato il dettaglio nascosto in questa foto.'
                        : '🔍 C\'è un dettaglio nascosto. Ingrandisci con due '
                            'dita e tocca ciò che ti sembra strano.',
                    style: const TextStyle(color: Pal.accent, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
