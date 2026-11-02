import 'package:d_true_crime_lab/story/casa.dart';
import 'package:d_true_crime_lab/story/engine.dart';
import 'package:d_true_crime_lab/story/model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final engine = StoryEngine();
  // Accensione: 2 novembre alle 15:00.
  final start = DateTime(2026, 11, 2, 15, 0);
  final clock = StoryClock(start: start);
  final end = DateTime(2026, 11, 20); // ben oltre il giorno 7

  test('gli id dei contenuti sono unici', () {
    final ids = casaStory.map((d) => d.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('all\'accensione si vedono solo i contenuti del giorno 0', () {
    final v = engine.visible(clock, StoryAnswers(), start);
    expect(v.every((d) => d.at.day == 0), isTrue);
    expect(v.length, greaterThan(3));
  });

  test('il giorno 1 è il giorno di accensione', () {
    final t = clock.unlockTime(const StoryTime(1, 21, 47));
    expect(t, DateTime(2026, 11, 2, 21, 47));
    final t4 = clock.unlockTime(const StoryTime(4, 3, 12));
    expect(t4, DateTime(2026, 11, 5, 3, 12));
  });

  test('in anteprima un giorno dura 3 minuti', () {
    final p = StoryClock(start: start, preview: true);
    final d2 = p.unlockTime(const StoryTime(2, 0, 0));
    expect(d2.difference(start), const Duration(minutes: 3));
    final last = p.unlockTime(const StoryTime(7, 9, 1));
    expect(last.difference(start).inMinutes, lessThan(21));
  });

  test('la pausa ferma la storia e la sposta in avanti', () {
    final paused = clock.pause(DateTime(2026, 11, 2, 16));
    // Durante la pausa il tempo della storia resta fermo.
    final v = engine.visible(paused, StoryAnswers(), DateTime(2026, 11, 3));
    expect(v.every((d) => d.at.day == 0), isTrue);
    final resumed = paused.resume(DateTime(2026, 11, 2, 18));
    expect(resumed.pauseOffset, const Duration(hours: 2));
    expect(
      resumed.unlockTime(const StoryTime(1, 21, 47)),
      DateTime(2026, 11, 2, 23, 47),
    );
    expect(engine.plan(paused, StoryAnswers(), start), isEmpty);
  });

  test('le notti tranquille spostano le notifiche alle 8', () {
    expect(
      StoryEngine.shiftOutOfNight(DateTime(2026, 11, 5, 3, 12)),
      DateTime(2026, 11, 5, 8),
    );
    expect(
      StoryEngine.shiftOutOfNight(DateTime(2026, 11, 5, 23, 58)),
      DateTime(2026, 11, 6, 8),
    );
    final plan = engine.plan(clock, StoryAnswers(), start, quietNights: true);
    expect(plan.every((p) => p.at.hour >= 8 && p.at.hour < 23), isTrue);
  });

  group('finali', () {
    final cases = <String, StoryAnswers>{
      'giornale': StoryAnswers({choiceD3: 'si', choiceD5: 'giornale'}),
      'paolo': StoryAnswers({choiceD3: 'chi', choiceD5: 'paolo'}),
      'niente': StoryAnswers({choiceD5: 'niente'}),
      'senza risposta': StoryAnswers(),
      'chiamata presto': StoryAnswers(
        {choiceD3: 'si', choiceD5: 'giornale', keyCall: callEarly},
      ),
    };
    final expected = {
      'giornale': '7g4',
      'paolo': '7p3',
      'niente': '7n3',
      'senza risposta': '7n3',
      'chiamata presto': '7e3',
    };

    for (final entry in cases.entries) {
      test('ramo ${entry.key}: esattamente un finale', () {
        final v = engine.visible(clock, entry.value, end);
        final endings = v.where((d) => d.ending != null).toList();
        expect(endings.length, 1);
        expect(endings.single.id, expected[entry.key]);
        // Nessun giorno 7 di un altro ramo deve comparire.
        final day7 = v.where((d) => d.at.day == 7).map((d) => d.id[1]).toSet();
        expect(day7.length, 1, reason: 'day 7 ids: $day7');
      });
    }
  });

  test('messaggio del giorno 4 dipende dalla risposta del giorno 3', () {
    final day5 = DateTime(2026, 11, 6, 12);
    final a = engine.visible(clock, StoryAnswers({choiceD3: 'si'}), day5);
    expect(a.any((d) => d.id == '4c'), isTrue);
    expect(a.any((d) => d.id == '4c2'), isFalse);
    final b = engine.visible(clock, StoryAnswers(), day5);
    expect(b.any((d) => d.id == '4c2'), isTrue);
    expect(b.any((d) => d.id == '4c'), isFalse);
  });

  test('le scelte scadono', () {
    final d5 = engine.byId('5d');
    final before = DateTime(2026, 11, 7, 9, 59);
    final after = DateTime(2026, 11, 7, 10, 1);
    expect(engine.choiceOpen(d5, clock, StoryAnswers(), before), isTrue);
    expect(engine.choiceOpen(d5, clock, StoryAnswers(), after), isFalse);
    expect(
      engine.choiceOpen(
        d5,
        clock,
        StoryAnswers({choiceD5: 'paolo'}),
        before,
      ),
      isFalse,
    );
  });

  test('chiamare Casa: presto, nel finale felice, negli altri finali', () {
    final mid = DateTime(2026, 11, 6, 12);
    final early = engine.callCasa(clock, StoryAnswers(), mid);
    expect(early.answers[keyCall], callEarly);

    final happyAnswers = StoryAnswers({choiceD5: 'giornale'});
    final happy = engine.callCasa(clock, happyAnswers, end);
    expect(happy.text, callHappyText);
    expect(happy.speaks, isTrue);
    // Chiamare dopo il finale non cambia il finale.
    final after = engine.endingReached(clock, happy.answers, end);
    expect(after?.id, '7g4');

    final dead = engine.callCasa(clock, StoryAnswers({choiceD5: 'paolo'}), end);
    expect(dead.text, callDeadText);
  });

  test('ogni scelta ha almeno due opzioni e una scadenza', () {
    for (final d in casaStory.where((d) => d.kind == DropKind.scelta)) {
      expect(d.options.length, greaterThanOrEqualTo(2));
      expect(d.deadline, isNotNull);
    }
  });

  test('il piano delle notifiche ha id unici e solo eventi futuri', () {
    final plan = engine.plan(clock, StoryAnswers(), start);
    expect(plan.map((p) => p.id).toSet().length, plan.length);
    expect(plan.every((p) => p.at.isAfter(start)), isTrue);
    expect(plan.length, lessThan(60));
  });
}
