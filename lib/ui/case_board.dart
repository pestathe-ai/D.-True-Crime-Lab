import 'package:flutter/material.dart';

import '../services/game.dart';
import '../story/casa.dart';
import '../story/model.dart';
import 'theme.dart';

/// Scheda "Indagine": domande del caso e bacheca degli indizi.
class CaseBoard extends StatelessWidget {
  const CaseBoard({super.key, required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    final score = game.score;
    final open = game.openQuestions;
    final hidden = caseQuestions.length - open.length;
    final pinned = game.pinnedDrops;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      children: [
        _Progress(solved: score.solved, total: score.total),
        const SizedBox(height: 18),
        Text('Domande del caso', style: sora(17, weight: 700)),
        const SizedBox(height: 6),
        const Text(
          'Appunta gli indizi giusti in bacheca con 📌: quando li hai tutti, '
          'si sblocca una domanda. Rispondi bene per risolvere il caso.',
          style: TextStyle(color: Pal.muted, fontSize: 13, height: 1.4),
        ),
        if (game.coop)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              'In due: alcuni indizi sono solo sul dispositivo del tuo '
              'compagno. Fateveli raccontare!',
              style: TextStyle(color: Pal.accent, fontSize: 13, height: 1.4),
            ),
          ),
        const SizedBox(height: 10),
        for (final q in open) _QuestionCard(q: q, game: game),
        if (hidden > 0)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Pal.line),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_outline, color: Pal.muted),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hidden == 1
                        ? '1 domanda ancora nascosta.'
                        : '$hidden domande ancora nascoste.',
                    style: const TextStyle(color: Pal.muted),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 22),
        Text('Bacheca', style: sora(17, weight: 700)),
        const SizedBox(height: 8),
        if (pinned.isEmpty)
          const Text(
            'Nessun indizio appuntato. Tocca «Appunta in bacheca» sotto note, '
            'foto, email e messaggi.',
            style: TextStyle(color: Pal.muted, height: 1.4),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final d in pinned) _ClueNote(drop: d, game: game),
            ],
          ),
        const DomSignature(),
      ],
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.solved, required this.total});

  final int solved;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Pal.accent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.fingerprint, size: 40, color: Pal.inkDark),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CASO 14 · VIA DEI TIGLI',
                  style: sora(12, weight: 800, color: Pal.inkDark),
                ),
                const SizedBox(height: 4),
                Text(
                  'Risolto $solved su $total',
                  style: sora(20, weight: 800, color: Pal.inkDark),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : solved / total,
                    minHeight: 6,
                    color: Pal.inkDark,
                    backgroundColor: Pal.inkDark.withValues(alpha: 0.15),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.q, required this.game});

  final CaseQuestion q;
  final Game game;

  @override
  Widget build(BuildContext context) {
    final solved = game.solved(q);
    final errors = game.errorsFor(q);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Pal.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: solved ? Pal.accent : Pal.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                solved ? Icons.check_circle : Icons.help_outline,
                color: Pal.accent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(q.text, style: sora(15, weight: 600)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (solved)
            Text(
              q.solved,
              style: const TextStyle(color: Pal.text, height: 1.45),
            )
          else ...[
            for (var i = 0; i < q.options.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      final ok = await game.answerQuestion(q, i);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(
                              ok
                                  ? '✓ Esatto. Un pezzo del caso torna al suo posto.'
                                  : '✗ Non torna. Rileggi gli indizi in bacheca.',
                            ),
                          ),
                        );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Pal.text,
                      side: const BorderSide(color: Pal.line),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    child: Text(q.options[i]),
                  ),
                ),
              ),
            if (errors > 0)
              Text(
                errors == 1 ? '1 tentativo sbagliato' : '$errors tentativi sbagliati',
                style: const TextStyle(color: Pal.muted, fontSize: 12),
              ),
          ],
        ],
      ),
    );
  }
}

class _ClueNote extends StatelessWidget {
  const _ClueNote({required this.drop, required this.game});

  final Drop drop;
  final Game game;

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.sizeOf(context).width - 42) / 2;
    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
      decoration: BoxDecoration(
        color: Pal.paper,
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 6, offset: Offset(2, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.push_pin, size: 14, color: Color(0xFFD23B2B)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  drop.at.label,
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                ),
              ),
              InkWell(
                onTap: () => game.togglePin(drop),
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: Icon(Icons.close, size: 16, color: Colors.black45),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            drop.clue ?? '',
            style: const TextStyle(
              color: Pal.inkDark,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
