import 'package:flutter/foundation.dart';

import '../story/casa.dart';
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

  Device? get device => state?.device;
  bool get coop => state?.device != null;
  bool get onTablet => state?.device == Device.tablet;

  String get deviceName => onTablet ? 'Tablet di Marta V.' : 'Telefono di Marta V.';

  Future<void> load() async {
    state = await store.load();
    loaded = true;
    notifyListeners();
    if (state != null) await _reschedule();
  }

  List<Drop> get visible {
    final s = state;
    if (s == null) return const [];
    return engine.visible(s.clock, s.answers, now, device: s.device);
  }

  Drop? get ending {
    final s = state;
    if (s == null) return null;
    return engine.endingReached(s.clock, s.answers, now, device: s.device);
  }

  int get day => state?.clock.currentDay(now) ?? 0;

  bool get paused => state?.clock.paused ?? false;

  // ───────────────────────── Avvio

  /// Minuto di partenza per una partita a due (uguale su entrambi i telefoni).
  static DateTime coopStartNow() => DateTime.fromMillisecondsSinceEpoch(
        (DateTime.now().millisecondsSinceEpoch ~/ 60000) * 60000,
      );

  Future<void> start({
    required bool preview,
    required bool quietNights,
    DateTime? coopStart,
  }) async {
    await notifier.requestPermission();
    final coopHost = coopStart != null;
    final startAt = coopStart ?? now;
    state = GameState(
      clock: StoryClock(start: startAt, preview: preview),
      answers: StoryAnswers(),
      seen: <String>{},
      pinned: <String>{},
      quietNights: quietNights,
      device: coopHost ? Device.telefono : null,
      caseCode: coopHost ? CaseCode.encode(startAt, preview: preview) : null,
    );
    await _commit();
  }

  /// Entra in una partita a due con il codice dell'amico. false = codice errato.
  Future<bool> join(String code, {required bool quietNights}) async {
    final c = CaseCode.decode(code);
    if (c == null) return false;
    await notifier.requestPermission();
    state = GameState(
      clock: StoryClock(start: c.start, preview: c.preview),
      answers: StoryAnswers(),
      seen: <String>{},
      pinned: <String>{},
      quietNights: quietNights,
      device: Device.tablet,
      caseCode: CaseCode.encode(c.start, preview: c.preview),
    );
    await _commit();
    return true;
  }

  // ───────────────────────── Scelte

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

  // ───────────────────────── Bacheca e domande

  bool isPinned(Drop d) => state?.pinned.contains(d.id) ?? false;

  Future<void> togglePin(Drop d) async {
    final s = state;
    if (s == null || d.clue == null) return;
    final next = {...s.pinned};
    if (!next.remove(d.id)) next.add(d.id);
    state = s.copyWith(pinned: next);
    await _save();
  }

  List<Drop> get pinnedDrops =>
      visible.where((d) => state!.pinned.contains(d.id)).toList();

  /// Domande già visibili (sbloccate o risolte) e quante restano nascoste.
  List<CaseQuestion> get openQuestions {
    final s = state;
    if (s == null) return const [];
    return caseQuestions
        .where(
          (q) =>
              s.answers.ok(q.id) ||
              engine.questionUnlocked(
                q,
                s.clock,
                now,
                s.pinned,
                device: s.device,
              ),
        )
        .toList();
  }

  /// Indizi mancanti per sbloccare una domanda (tra quelli già arrivati).
  int missingFor(CaseQuestion q) {
    final s = state!;
    return engine
        .requiredFor(q, s.device)
        .where((id) => !s.pinned.contains(id))
        .length;
  }

  bool solved(CaseQuestion q) => state?.answers.ok(q.id) ?? false;

  int errorsFor(CaseQuestion q) =>
      int.tryParse(state?.answers['${q.id}_err'] ?? '0') ?? 0;

  Future<bool> answerQuestion(CaseQuestion q, int option) async {
    final s = state!;
    final r = engine.answerQuestion(q, option, s.answers);
    state = s.copyWith(answers: r.answers);
    await _commit();
    return r.correct;
  }

  ({int solved, int total, int errors}) get score =>
      engine.score(state?.answers ?? StoryAnswers());

  // ───────────────────────── Enigmi

  bool get folderAvailable {
    final s = state;
    if (s == null) return false;
    return engine.folderAvailable(s.clock, now, s.device);
  }

  bool get folderOpen => state?.answers.ok(keyFolder) ?? false;

  Future<bool> tryFolder(String code) async {
    final s = state!;
    final next = engine.tryFolder(code, s.answers);
    if (next == null) return false;
    state = s.copyWith(answers: next);
    await _commit();
    return true;
  }

  bool detailFound(Hotspot h) => state?.answers.ok(h.key) ?? false;

  Future<void> findDetail(Hotspot h) async {
    final s = state!;
    state = s.copyWith(answers: engine.findDetail(h, s.answers));
    await _commit();
  }

  // ───────────────────────── Telefonate

  Future<({String text, bool speaks})> callCasa() async {
    final s = state!;
    final r = engine.callCasa(s.clock, s.answers, now, device: s.device);
    if (r.answers != s.answers) {
      state = s.copyWith(answers: r.answers);
      await _commit();
    }
    return (text: r.text, speaks: r.speaks);
  }

  Future<CallReply> call(String contactId) async {
    final s = state!;
    final r = engine.call(contactId, s.clock, s.answers, now, device: s.device);
    if (r.answers != s.answers) {
      state = s.copyWith(answers: r.answers);
      await _commit();
    }
    return r.reply;
  }

  // ───────────────────────── Impostazioni

  Future<void> togglePause() async {
    final s = state;
    if (s == null || coop) return;
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

  Future<void> _save() async {
    final s = state;
    if (s != null) await store.save(s);
    notifyListeners();
  }

  Future<void> _commit() async {
    await _save();
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
      device: s.device,
    );
    await notifier.reschedule(plan);
  }
}
