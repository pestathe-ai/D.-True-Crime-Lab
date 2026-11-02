import 'package:flutter/foundation.dart';

import '../story/engine.dart';
import '../story/model.dart';
import 'notifier.dart';
import 'store.dart';
import 'voice.dart';

/// Tiene insieme stato, salvataggio, notifiche e voce.
class Game extends ChangeNotifier {
  Game({Store? store, Notifier? notifier, Voice? voice})
      : store = store ?? Store(),
        notifier = notifier ?? Notifier(),
        voice = voice ?? Voice();

  final Store store;
  final Notifier notifier;
  final Voice voice;
  final StoryEngine engine = StoryEngine();

  GameState? state;
  bool loaded = false;

  DateTime get now => DateTime.now();

  Future<void> load() async {
    state = await store.load();
    loaded = true;
    notifyListeners();
    if (state != null) await _reschedule();
  }

  List<Drop> get visible {
    final s = state;
    if (s == null) return const [];
    return engine.visible(s.clock, s.answers, now);
  }

  Drop? get ending {
    final s = state;
    if (s == null) return null;
    return engine.endingReached(s.clock, s.answers, now);
  }

  int get day => state?.clock.currentDay(now) ?? 0;

  bool get paused => state?.clock.paused ?? false;

  Future<void> start({required bool preview, required bool quietNights}) async {
    await notifier.requestPermission();
    state = GameState(
      clock: StoryClock(start: now, preview: preview),
      answers: StoryAnswers(),
      seen: <String>{},
      quietNights: quietNights,
    );
    await _commit();
  }

  bool choiceOpen(Drop d) {
    final s = state;
    if (s == null) return false;
    return engine.choiceOpen(d, s.clock, s.answers, now);
  }

  String? answerFor(Drop d) => state?.answers[StoryEngine.choiceKey(d)];

  Future<void> answer(Drop d, ChoiceOption option) async {
    final s = state;
    if (s == null || !choiceOpen(d)) return;
    state = s.copyWith(
      answers: s.answers.copyWith(StoryEngine.choiceKey(d), option.value),
    );
    await _commit();
  }

  Future<({String text, bool speaks})> callCasa() async {
    final s = state!;
    final r = engine.callCasa(s.clock, s.answers, now);
    if (r.answers != s.answers) {
      state = s.copyWith(answers: r.answers);
      await _commit();
    }
    return (text: r.text, speaks: r.speaks);
  }

  Future<void> togglePause() async {
    final s = state;
    if (s == null) return;
    final c = s.clock.paused ? s.clock.resume(now) : s.clock.pause(now);
    state = s.copyWith(clock: c);
    await _commit();
  }

  Future<void> setQuietNights(bool v) async {
    final s = state;
    if (s == null) return;
    state = s.copyWith(quietNights: v);
    await _commit();
  }

  void markSeen(Iterable<String> ids) {
    final s = state;
    if (s == null) return;
    final add = ids.where((id) => !s.seen.contains(id)).toList();
    if (add.isEmpty) return;
    state = s.copyWith(seen: {...s.seen, ...add});
    store.save(state!);
    notifyListeners();
  }

  bool isNew(Drop d) => !(state?.seen.contains(d.id) ?? true);

  Future<void> reset() async {
    await voice.stop();
    await notifier.cancelAll();
    await store.clear();
    state = null;
    notifyListeners();
  }

  /// Chiamato periodicamente: ridisegna se è arrivato qualcosa.
  void tick() => notifyListeners();

  Future<void> _commit() async {
    final s = state;
    if (s != null) await store.save(s);
    notifyListeners();
    await _reschedule();
  }

  Future<void> _reschedule() async {
    final s = state;
    if (s == null) return;
    final plan = engine.plan(
      s.clock,
      s.answers,
      now,
      quietNights: s.quietNights,
    );
    await notifier.reschedule(plan);
  }
}
