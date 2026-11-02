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
    required this.quietNights,
  });

  final StoryClock clock;
  final StoryAnswers answers;
  final Set<String> seen;
  final bool quietNights;

  GameState copyWith({
    StoryClock? clock,
    StoryAnswers? answers,
    Set<String>? seen,
    bool? quietNights,
  }) {
    return GameState(
      clock: clock ?? this.clock,
      answers: answers ?? this.answers,
      seen: seen ?? this.seen,
      quietNights: quietNights ?? this.quietNights,
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
  static const _kQuiet = 'quiet_nights';

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
      quietNights: p.getBool(_kQuiet) ?? true,
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
    await p.setBool(_kQuiet, s.quietNights);
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
      _kQuiet,
    ]) {
      await p.remove(k);
    }
  }
}
