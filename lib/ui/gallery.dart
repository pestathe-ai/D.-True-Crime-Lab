import 'package:flutter/material.dart';

import '../services/game.dart';
import '../story/casa.dart';
import '../story/model.dart';
import 'cards.dart';
import 'photo.dart';
import 'theme.dart';

/// Galleria: le foto in griglia e la cartella privata.
class Gallery extends StatelessWidget {
  const Gallery({super.key, required this.game, required this.items});

  final Game game;
  final List<Drop> items;

  @override
  Widget build(BuildContext context) {
    final photos = items.where((d) => d.kind == DropKind.foto).toList().reversed;
    final privateNotes = items.where(
      (d) => d.kind == DropKind.nota && d.title == 'Cartella privata',
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      children: [
        if (game.folderAvailable) ...[
          _FolderTile(game: game),
          const SizedBox(height: 14),
        ],
        if (photos.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'Nessuna foto.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Pal.muted),
            ),
          )
        else
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 4 / 3.6,
            children: [
              for (final p in photos)
                GestureDetector(
                  onTap: () => openPhoto(context, p, game),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: PhotoFrame(drop: p, height: 200)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              p.title ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Pal.muted,
                              ),
                            ),
                          ),
                          if (p.hotspot != null)
                            Icon(
                              game.detailFound(p.hotspot!)
                                  ? Icons.check_circle
                                  : Icons.search,
                              size: 14,
                              color: Pal.accent,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        for (final n in privateNotes) ...[
          const SizedBox(height: 10),
          DropCard(drop: n, game: game),
        ],
        const DomSignature(),
      ],
    );
  }
}

class _FolderTile extends StatelessWidget {
  const _FolderTile({required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    final open = game.folderOpen;
    return Material(
      color: Pal.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: open ? null : () => _askCode(context),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Pal.accent),
          ),
          child: Row(
            children: [
              Icon(
                open ? Icons.folder_open : Icons.lock,
                color: Pal.accent,
                size: 30,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cartella privata', style: sora(15, weight: 700)),
                    const SizedBox(height: 2),
                    Text(
                      open
                          ? 'Sbloccata. Il contenuto è qui sotto.'
                          : 'Protetta da un codice. Tocca per provare.',
                      style: const TextStyle(color: Pal.muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _askCode(BuildContext context) async {
    final ctrl = TextEditingController();
    String? error;
    await showDialog<void>(
      context: context,
      builder: (d) => StatefulBuilder(
        builder: (d, setState) => AlertDialog(
          backgroundColor: Pal.surface2,
          title: const Text('Cartella privata'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                folderHint,
                style: TextStyle(color: Pal.muted, height: 1.4),
              ),
              if (game.coop)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Forse la risposta è sul dispositivo del tuo compagno.',
                    style: TextStyle(color: Pal.accent, fontSize: 13),
                  ),
                ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                autofocus: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: sora(26, weight: 700),
                decoration: InputDecoration(
                  errorText: error,
                  counterText: '',
                  hintText: '••••',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(d),
              child: const Text('Chiudi'),
            ),
            TextButton(
              onPressed: () async {
                final ok = await game.tryFolder(ctrl.text);
                if (ok) {
                  if (d.mounted) Navigator.pop(d);
                } else {
                  setState(() => error = 'Codice errato');
                }
              },
              child: const Text('Sblocca'),
            ),
          ],
        ),
      ),
    );
  }
}
