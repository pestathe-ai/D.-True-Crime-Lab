import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/game.dart';
import '../story/engine.dart';
import 'theme.dart';

/// Schermata iniziale: la libreria con la prima storia.
class Onboarding extends StatefulWidget {
  const Onboarding({super.key, required this.game});

  final Game game;

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  bool _preview = false;
  bool _quiet = true;
  bool _busy = false;

  Future<void> _createCoop() async {
    final at = Game.coopStartNow();
    final code = CaseCode.encode(at, preview: _preview);
    final go = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        backgroundColor: Pal.surface2,
        title: const Text('Partita a due'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tu avrai il TELEFONO di Marta. Manda questo codice al tuo '
              'amico: lui avrà il TABLET.',
              style: TextStyle(height: 1.4),
            ),
            const SizedBox(height: 14),
            SelectableText(code, style: sora(24, weight: 800)),
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Codice copiato')),
                );
              },
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copia codice'),
            ),
            const Text(
              'Lo trovi sempre anche nelle impostazioni.',
              style: TextStyle(color: Pal.muted, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d, false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(d, true),
            child: const Text('Inizia'),
          ),
        ],
      ),
    );
    if (go != true) return;
    setState(() => _busy = true);
    await widget.game.start(
      preview: _preview,
      quietNights: _quiet,
      coopStart: at,
    );
  }

  Future<void> _joinCoop() async {
    final ctrl = TextEditingController();
    String? error;
    await showDialog<void>(
      context: context,
      builder: (d) => StatefulBuilder(
        builder: (d, setLocal) => AlertDialog(
          backgroundColor: Pal.surface2,
          title: const Text('Entra con un codice'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Inserisci il codice che ti ha mandato il tuo amico. '
                'Tu avrai il TABLET di Marta.',
                style: TextStyle(height: 1.4),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'TCL-…',
                  errorText: error,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(d),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () async {
                final ok = await widget.game.join(
                  ctrl.text,
                  quietNights: _quiet,
                );
                if (ok) {
                  if (d.mounted) Navigator.pop(d);
                } else {
                  setLocal(() => error = 'Codice non valido');
                }
              },
              child: const Text('Entra'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
          children: [
            Text('D. True Crime Lab', style: sora(26, weight: 800)),
            const SizedBox(height: 6),
            const Text(
              'Misteri che vivono dentro il tuo telefono.',
              style: TextStyle(color: Pal.muted, fontSize: 15),
            ),
            const SizedBox(height: 24),
            _TapeBand(),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Pal.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Pal.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STAGIONE 1',
                    style: sora(11, weight: 700, color: Pal.accent),
                  ),
                  const SizedBox(height: 4),
                  Text('Casa', style: sora(24, weight: 800)),
                  const SizedBox(height: 10),
                  const Text(
                    'Ti ritrovi con il telefono di una sconosciuta, Marta. '
                    'Il suo account è ancora collegato: nei prossimi giorni '
                    'arriveranno note, email, foto e vocali, all\'ora in cui '
                    'accadono. In un paese c\'è un numero civico che non esiste. '
                    'E in rubrica comparirà un contatto che non dovresti '
                    'chiamare.',
                    style: TextStyle(color: Pal.text, height: 1.5),
                  ),
                  const SizedBox(height: 14),
                  const Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Chip('7 giorni'),
                      _Chip('4 finali'),
                      _Chip('6 domande del caso'),
                      _Chip('Da soli o in due'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _Toggle(
              title: 'Anteprima veloce',
              subtitle: 'Un giorno della storia ogni 3 minuti. '
                  'Utile per provarla tutta in mezz\'ora.',
              value: _preview,
              onChanged: (v) => setState(() => _preview = v),
            ),
            _Toggle(
              title: 'Notti tranquille',
              subtitle: 'Le notifiche tra le 23 e le 8 arrivano al mattino.',
              value: _quiet,
              onChanged: (v) => setState(() => _quiet = v),
            ),
            const SizedBox(height: 18),
            _BigButton(
              label: 'Gioca da solo',
              icon: Icons.person,
              filled: true,
              onPressed: _busy
                  ? null
                  : () async {
                      setState(() => _busy = true);
                      await widget.game.start(
                        preview: _preview,
                        quietNights: _quiet,
                      );
                    },
            ),
            const SizedBox(height: 10),
            _BigButton(
              label: 'Gioca in due · crea la partita',
              icon: Icons.group_add,
              onPressed: _busy ? null : _createCoop,
            ),
            const SizedBox(height: 10),
            _BigButton(
              label: 'Gioca in due · entra con un codice',
              icon: Icons.vpn_key,
              onPressed: _busy ? null : _joinCoop,
            ),
            const SizedBox(height: 10),
            const Text(
              'In due: uno ha il telefono di Marta, l\'altro il suo tablet. '
              'Ognuno riceve indizi diversi: per risolvere il caso dovete '
              'parlarvi.',
              style: TextStyle(color: Pal.muted, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            const Text(
              '◆ Tutto ciò che arriva da questa app è finzione ed è segnato '
              'con il simbolo ◆. Personaggi, luoghi e numeri sono inventati.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Pal.muted, fontSize: 12, height: 1.4),
            ),
            const DomSignature(),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Pal.line),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, color: Pal.text)),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(color: Pal.text)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Pal.muted, fontSize: 13),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}

/// Striscia gialla e nera da nastro della scena del crimine.
class _TapeBand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 26,
        child: CustomPaint(
          painter: _TapePainter(),
          child: Center(
            child: Text(
              'NON OLTREPASSARE · NON OLTREPASSARE',
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: sora(11, weight: 800, color: Pal.inkDark),
            ),
          ),
        ),
      ),
    );
  }
}

class _TapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Pal.accent);
    final dark = Paint()..color = Pal.inkDark.withValues(alpha: 0.12);
    for (double x = -size.height; x < size.width; x += 22) {
      final p = Path()
        ..moveTo(x, size.height)
        ..lineTo(x + size.height, 0)
        ..lineTo(x + size.height + 9, 0)
        ..lineTo(x + 9, size.height)
        ..close();
      canvas.drawPath(p, dark);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BigButton extends StatelessWidget {
  const _BigButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.filled = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
    if (filled) {
      return SizedBox(
        height: 54,
        child: FilledButton.icon(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: Pal.accent,
            foregroundColor: Pal.inkDark,
            shape: shape,
          ),
          icon: Icon(icon),
          label: Text(label, style: sora(16, weight: 700, color: Pal.inkDark)),
        ),
      );
    }
    return SizedBox(
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Pal.accent,
          side: const BorderSide(color: Pal.accent),
          shape: shape,
        ),
        icon: Icon(icon, size: 20),
        label: Text(label),
      ),
    );
  }
}
