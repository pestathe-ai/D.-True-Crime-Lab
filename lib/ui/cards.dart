import 'package:flutter/material.dart';

import '../services/game.dart';
import '../story/model.dart';
import 'photo.dart';
import 'theme.dart';

IconData iconFor(DropKind k) {
  switch (k) {
    case DropKind.sistema:
      return Icons.info_outline;
    case DropKind.nota:
      return Icons.sticky_note_2_outlined;
    case DropKind.promemoria:
      return Icons.alarm;
    case DropKind.vocale:
      return Icons.mic_none;
    case DropKind.foto:
      return Icons.photo_outlined;
    case DropKind.email:
      return Icons.mail_outline;
    case DropKind.messaggio:
    case DropKind.scelta:
      return Icons.chat_bubble_outline;
    case DropKind.contatto:
      return Icons.person_outline;
  }
}

String labelFor(DropKind k) {
  switch (k) {
    case DropKind.sistema:
      return 'Sistema';
    case DropKind.nota:
      return 'Nota';
    case DropKind.promemoria:
      return 'Promemoria';
    case DropKind.vocale:
      return 'Vocale';
    case DropKind.foto:
      return 'Foto';
    case DropKind.email:
      return 'Email';
    case DropKind.messaggio:
    case DropKind.scelta:
      return 'Messaggio';
    case DropKind.contatto:
      return 'Contatto';
  }
}

/// Intestazione comune: tipo, autore, momento, "nuovo".
class _Header extends StatelessWidget {
  const _Header({required this.drop, required this.isNew});

  final Drop drop;
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    final who = drop.from;
    return Row(
      children: [
        Icon(iconFor(drop.kind), size: 16, color: Pal.accent),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            who == null ? labelFor(drop.kind) : '${labelFor(drop.kind)} · $who',
            style: const TextStyle(
              fontSize: 12,
              color: Pal.muted,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          drop.at.label,
          style: const TextStyle(fontSize: 11, color: Pal.muted),
        ),
        if (isNew) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Pal.accent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'NUOVO',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: Pal.inkDark,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Pulsante per appuntare un indizio in bacheca.
class PinButton extends StatelessWidget {
  const PinButton({super.key, required this.drop, required this.game});

  final Drop drop;
  final Game game;

  @override
  Widget build(BuildContext context) {
    if (drop.clue == null) return const SizedBox.shrink();
    final pinned = game.isPinned(drop);
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: TextButton.icon(
          onPressed: () {
            game.togglePin(drop);
            if (!pinned) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('📌 Indizio appuntato nella bacheca'),
                    duration: Duration(seconds: 2),
                  ),
                );
            }
          },
          style: TextButton.styleFrom(
            foregroundColor: pinned ? Pal.inkDark : Pal.accent,
            backgroundColor: pinned ? Pal.accent : Colors.transparent,
            side: const BorderSide(color: Pal.accent),
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          icon: Icon(
            pinned ? Icons.push_pin : Icons.push_pin_outlined,
            size: 16,
          ),
          label: Text(pinned ? 'In bacheca' : 'Appunta in bacheca'),
        ),
      ),
    );
  }
}

class _Shell extends StatelessWidget {
  const _Shell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Pal.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Pal.line),
      ),
      child: child,
    );
  }
}

/// Scheda di un contenuto, adattata al tipo.
class DropCard extends StatelessWidget {
  const DropCard({
    super.key,
    required this.drop,
    required this.game,
    this.highlight = false,
  });

  final Drop drop;
  final Game game;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final isNew = highlight || game.isNew(drop);
    final header = _Header(drop: drop, isNew: isNew);
    final pin = PinButton(drop: drop, game: game);
    switch (drop.kind) {
      case DropKind.sistema:
        return _SystemCard(drop: drop, game: game);
      case DropKind.vocale:
        return _VoiceCard(drop: drop, game: game, header: header, pin: pin);
      case DropKind.foto:
        return _Shell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => openPhoto(context, drop, game),
                child: PhotoFrame(drop: drop),
              ),
              const SizedBox(height: 10),
              Text(
                drop.body,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Pal.text,
                  height: 1.45,
                ),
              ),
              pin,
            ],
          ),
        );
      case DropKind.email:
        return _EmailCard(drop: drop, header: header, pin: pin);
      case DropKind.scelta:
        return _ChoiceCard(drop: drop, game: game, header: header);
      case DropKind.messaggio:
        return _Shell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              const SizedBox(height: 10),
              _Bubble(text: drop.body, mine: false),
              pin,
            ],
          ),
        );
      case DropKind.contatto:
        return _Shell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              const SizedBox(height: 8),
              Text(
                drop.at.day == 0
                    ? 'In rubrica: ${drop.title}'
                    : 'Nuovo contatto in rubrica: ${drop.title}',
                style: const TextStyle(fontSize: 15, color: Pal.text),
              ),
              Text(drop.body, style: const TextStyle(color: Pal.muted)),
            ],
          ),
        );
      case DropKind.nota:
      case DropKind.promemoria:
        return _Shell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              const SizedBox(height: 10),
              Text(
                drop.body,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: Pal.text,
                ),
              ),
              pin,
            ],
          ),
        );
    }
  }
}

class _SystemCard extends StatelessWidget {
  const _SystemCard({required this.drop, required this.game});

  final Drop drop;
  final Game game;

  @override
  Widget build(BuildContext context) {
    if (drop.ending != null) {
      final s = game.score;
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 14, 16, 6),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Pal.accent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              drop.ending!.toUpperCase(),
              style: sora(15, weight: 800, color: Pal.inkDark),
            ),
            const SizedBox(height: 6),
            Text(
              drop.body,
              style: const TextStyle(color: Pal.inkDark, fontSize: 14),
            ),
            const SizedBox(height: 10),
            Text(
              'Indagine: ${s.solved} domande su ${s.total} risolte'
              '${s.errors > 0 ? ' · ${s.errors} errori' : ''}',
              style: sora(13, weight: 700, color: Pal.inkDark),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 8),
      child: Text(
        drop.body,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Pal.muted,
          fontSize: 13,
          height: 1.5,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

class _VoiceCard extends StatefulWidget {
  const _VoiceCard({
    required this.drop,
    required this.game,
    required this.header,
    required this.pin,
  });

  final Drop drop;
  final Game game;
  final Widget header;
  final Widget pin;

  @override
  State<_VoiceCard> createState() => _VoiceCardState();
}

class _VoiceCardState extends State<_VoiceCard> {
  bool _showText = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.drop;
    return _Shell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.header,
          const SizedBox(height: 10),
          ValueListenableBuilder<String?>(
            valueListenable: widget.game.voice.playing,
            builder: (context, playing, _) {
              final on = playing == d.id;
              return Row(
                children: [
                  IconButton.filled(
                    onPressed: () =>
                        widget.game.voice.play(d.id, d.body, d.voice),
                    style: IconButton.styleFrom(
                      backgroundColor: Pal.accent,
                      foregroundColor: Pal.inkDark,
                    ),
                    icon: Icon(on ? Icons.stop : Icons.play_arrow),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: _Wave(seed: d.id.hashCode, active: on)),
                ],
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            d.title ?? '',
            style: const TextStyle(fontSize: 12, color: Pal.muted),
          ),
          TextButton(
            onPressed: () => setState(() => _showText = !_showText),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              foregroundColor: Pal.accent,
            ),
            child: Text(_showText ? 'Nascondi trascrizione' : 'Trascrizione'),
          ),
          if (_showText)
            Text(
              '«${d.body}»',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: Pal.text,
                height: 1.45,
              ),
            ),
          widget.pin,
        ],
      ),
    );
  }
}

class _Wave extends StatelessWidget {
  const _Wave({required this.seed, required this.active});

  final int seed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: LayoutBuilder(
        builder: (context, c) {
          final n = (c.maxWidth / 6).floor().clamp(8, 60);
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(n, (i) {
              final h = 6 + ((seed >> (i % 16)) ^ (i * 7)) % 24;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 3,
                height: h.toDouble(),
                decoration: BoxDecoration(
                  color: active ? Pal.accent : Pal.muted.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

/// Anteprima di una foto: l'illustrazione se c'è, altrimenti un riquadro.
class PhotoFrame extends StatelessWidget {
  const PhotoFrame({super.key, required this.drop, this.height = 170});

  final Drop drop;
  final double height;

  @override
  Widget build(BuildContext context) {
    final image = drop.image;
    if (image != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Image.asset(
              image,
              height: height,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.zoom_in, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Ingrandisci',
                      style: TextStyle(fontSize: 11, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    final h = drop.id.hashCode;
    final c1 = HSLColor.fromAHSL(1, (h % 360).toDouble(), 0.18, 0.22).toColor();
    final c2 =
        HSLColor.fromAHSL(1, ((h >> 3) % 360).toDouble(), 0.25, 0.12).toColor();
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c1, c2],
        ),
      ),
      child: const Center(
        child: Icon(Icons.blur_on, size: 46, color: Colors.white24),
      ),
    );
  }
}

class _EmailCard extends StatefulWidget {
  const _EmailCard({
    required this.drop,
    required this.header,
    required this.pin,
  });

  final Drop drop;
  final Widget header;
  final Widget pin;

  @override
  State<_EmailCard> createState() => _EmailCardState();
}

class _EmailCardState extends State<_EmailCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.drop;
    return GestureDetector(
      onTap: () => setState(() => _open = !_open),
      child: _Shell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.header,
            const SizedBox(height: 8),
            Text(
              d.title ?? '(senza oggetto)',
              style: sora(15, weight: 600),
            ),
            const SizedBox(height: 6),
            Text(
              d.body,
              maxLines: _open ? null : 2,
              overflow: _open ? null : TextOverflow.ellipsis,
              style: const TextStyle(color: Pal.text, height: 1.45),
            ),
            if (!_open)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Tocca per leggere',
                  style: TextStyle(fontSize: 12, color: Pal.accent),
                ),
              ),
            widget.pin,
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, required this.mine});

  final String text;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.75,
        ),
        child: Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: mine ? Pal.accent : Pal.surface2,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(14),
              topRight: const Radius.circular(14),
              bottomLeft: Radius.circular(mine ? 14 : 4),
              bottomRight: Radius.circular(mine ? 4 : 14),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: mine ? Pal.inkDark : Pal.text,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.drop,
    required this.game,
    required this.header,
  });

  final Drop drop;
  final Game game;
  final Widget header;

  @override
  Widget build(BuildContext context) {
    final answer = game.answerFor(drop);
    final open = game.choiceOpen(drop);
    ChoiceOption? chosen;
    for (final o in drop.options) {
      if (o.value == answer) chosen = o;
    }
    return _Shell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 10),
          _Bubble(text: drop.body, mine: false),
          const SizedBox(height: 10),
          if (chosen != null) ...[
            _Bubble(text: chosen.label, mine: true),
            if (chosen.reply != null) _Bubble(text: chosen.reply!, mine: false),
          ] else if (open) ...[
            Text(
              game.coop
                  ? 'Rispondi (decidetelo insieme!):'
                  : 'Rispondi:',
              style: const TextStyle(fontSize: 12, color: Pal.muted),
            ),
            const SizedBox(height: 6),
            for (final o in drop.options)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => game.answer(drop, o),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Pal.accent,
                      side: const BorderSide(color: Pal.accent),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    child: Text(o.label),
                  ),
                ),
              ),
          ] else
            const Text(
              'Non hai risposto in tempo.',
              style: TextStyle(
                fontSize: 12,
                color: Pal.muted,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }
}
