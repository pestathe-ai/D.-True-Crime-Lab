import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../story/engine.dart';
import '../story/model.dart';

/// Tutto lo stato della partita salvato sul telefono.
class GameState {
  GameState({
    required this.clock,
    required this.answers,
    required this.seen,
    required this.pinned,
    required this.quietNights,
    this.device,
    this.caseCode,
  });

  final StoryClock clock;
  final StoryAnswers answers;
  final Set<String> seen;

  /// Indizi appuntati in bacheca (id dei contenuti).
  final Set<String> pinned;
  final bool quietNights;

  /// null = partita da soli; altrimenti il dispositivo in partita a due.
  final Device? device;

  /// Codice da condividere (solo in partita a due).
  final String? caseCode;

  GameState copyWith({
    StoryClock? clock,
    StoryAnswers? answers,
    Set<String>? seen,
    Set<String>? pinned,
    bool? quietNights,
  }) {
    return GameState(
      clock: clock ?? this.clock,
      answers: answers ?? this.answers,
      seen: seen ?? this.seen,
      pinned: pinned ?? this.pinned,
      quietNights: quietNights ?? this.quietNights,
      device: device,
      caseCode: caseCode,
    );
  }
}

class Store {
  static const _kStart = 'start_ms';
  static const _kPreview = 'preview';
  static const _kPauseOffset = 'pause_offset_ms';
  static const _kPausedAt = 'paused_at_ms';
  static const _kAnswers = 'answers';
  static const _kSeen = 'seen';
  static const _kPinned = 'pinned';
  static const _kQuiet = 'quiet_nights';
  static const _kDevice = 'device';
  static const _kCode = 'case_code';

  Future<GameState?> load() async {
    final p = await SharedPreferences.getInstance();
    final startMs = p.getInt(_kStart);
    if (startMs == null) return null;
    final pausedMs = p.getInt(_kPausedAt);
    Map<String, String> answers = {};
    try {
      final raw = p.getString(_kAnswers);
      if (raw != null) {
        answers = (jsonDecode(raw) as Map).map(
          (k, v) => MapEntry(k.toString(), v.toString()),
        );
      }
    } catch (_) {
      answers = {};
    }
    final deviceName = p.getString(_kDevice);
    Device? device;
    for (final d in Device.values) {
      if (d.name == deviceName) device = d;
    }
    return GameState(
      clock: StoryClock(
        start: DateTime.fromMillisecondsSinceEpoch(startMs),
        preview: p.getBool(_kPreview) ?? false,
        pauseOffset: Duration(milliseconds: p.getInt(_kPauseOffset) ?? 0),
        pausedAt: pausedMs == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(pausedMs),
      ),
      answers: StoryAnswers(answers),
      seen: (p.getStringList(_kSeen) ?? const []).toSet(),
      pinned: (p.getStringList(_kPinned) ?? const []).toSet(),
      quietNights: p.getBool(_kQuiet) ?? true,
      device: device,
      caseCode: p.getString(_kCode),
    );
  }

  Future<void> save(GameState s) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kStart, s.clock.start.millisecondsSinceEpoch);
    await p.setBool(_kPreview, s.clock.preview);
    await p.setInt(_kPauseOffset, s.clock.pauseOffset.inMilliseconds);
    final pausedAt = s.clock.pausedAt;
    if (pausedAt == null) {
      await p.remove(_kPausedAt);
    } else {
      await p.setInt(_kPausedAt, pausedAt.millisecondsSinceEpoch);
    }
    await p.setString(_kAnswers, jsonEncode(s.answers.values));
    await p.setStringList(_kSeen, s.seen.toList());
    await p.setStringList(_kPinned, s.pinned.toList());
    await p.setBool(_kQuiet, s.quietNights);
    if (s.device == null) {
      await p.remove(_kDevice);
    } else {
      await p.setString(_kDevice, s.device!.name);
    }
    if (s.caseCode == null) {
      await p.remove(_kCode);
    } else {
      await p.setString(_kCode, s.caseCode!);
    }
  }

  Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    for (final k in [
      _kStart,
      _kPreview,
      _kPauseOffset,
      _kPausedAt,
      _kAnswers,
      _kSeen,
      _kPinned,
      _kQuiet,
      _kDevice,
      _kCode,
    ]) {
      await p.remove(k);
    }
  }
}
