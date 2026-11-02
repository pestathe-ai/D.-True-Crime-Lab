import 'package:flutter/material.dart';

import '../services/game.dart';
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
                      _Chip('Le tue scelte contano'),
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
            SizedBox(
              height: 54,
              child: FilledButton(
                onPressed: _busy
                    ? null
                    : () async {
                        setState(() => _busy = true);
                        await widget.game.start(
                          preview: _preview,
                          quietNights: _quiet,
                        );
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: Pal.accent,
                  foregroundColor: Pal.inkDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Accendi il telefono',
                  style: sora(16, weight: 700, color: Pal.inkDark),
                ),
              ),
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
