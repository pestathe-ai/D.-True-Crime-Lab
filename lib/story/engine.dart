/// Motore della storia: decide cosa è visibile e quando notificarlo.
/// Puro Dart, senza Flutter, così si può testare in CI.
library;

import 'casa.dart';
import 'model.dart';

/// Impostazioni di tempo di una partita.
class StoryClock {
  const StoryClock({
    required this.start,
    this.preview = false,
    this.pauseOffset = Duration.zero,
    this.pausedAt,
  });

  /// Momento in cui il giocatore ha "acceso il telefono".
  final DateTime start;

  /// Anteprima veloce: un giorno della storia dura 3 minuti.
  final bool preview;

  /// Tempo totale passato in pausa (sposta in avanti tutta la storia).
  final Duration pauseOffset;

  /// Se non è null la storia è in pausa da questo momento.
  final DateTime? pausedAt;

  bool get paused => pausedAt != null;

  /// In anteprima: millisecondi reali per ogni minuto della storia.
  /// 3 minuti al giorno = 180 000 ms / 1440 minuti = 125 ms.
  static const int previewMsPerStoryMinute = 125;

  /// Il "tempo della storia" che conta adesso.
  DateTime effectiveNow(DateTime realNow) => pausedAt ?? realNow;

  /// Quando un momento della storia diventa reale.
  DateTime unlockTime(StoryTime t) {
    if (t.day <= 0) return start;
    if (preview) {
      return start.add(
        Duration(
          milliseconds: t.minutesFromStart * previewMsPerStoryMinute,
        ),
      ).add(pauseOffset);
    }
    // Il giorno 1 è il giorno in cui si accende il telefono.
    final base = DateTime(
      start.year,
      start.month,
      start.day + t.day - 1,
      t.hour,
      t.minute,
    );
    return base.add(pauseOffset);
  }

  /// Giorno della storia in corso (1..7), 0 se non è ancora iniziato.
  int currentDay(DateTime realNow) {
    final now = effectiveNow(realNow);
    var day = 0;
    for (var d = 1; d <= 7; d++) {
      if (!unlockTime(StoryTime(d)).isAfter(now)) day = d;
    }
    return day;
  }

  StoryClock copyWith({
    DateTime? start,
    bool? preview,
    Duration? pauseOffset,
    DateTime? pausedAt,
    bool clearPausedAt = false,
  }) {
    return StoryClock(
      start: start ?? this.start,
      preview: preview ?? this.preview,
      pauseOffset: pauseOffset ?? this.pauseOffset,
      pausedAt: clearPausedAt ? null : (pausedAt ?? this.pausedAt),
    );
  }

  StoryClock pause(DateTime realNow) =>
      paused ? this : copyWith(pausedAt: realNow);

  StoryClock resume(DateTime realNow) {
    if (!paused) return this;
    final extra = realNow.difference(pausedAt!);
    return copyWith(
      pauseOffset: pauseOffset + (extra.isNegative ? Duration.zero : extra),
      clearPausedAt: true,
    );
  }
}

/// Una notifica da programmare.
class PlannedNotification {
  const PlannedNotification({
    required this.id,
    required this.dropId,
    required this.at,
    required this.text,
  });

  final int id;
  final String dropId;
  final DateTime at;
  final String text;
}

class StoryEngine {
  StoryEngine({List<Drop>? drops}) : drops = drops ?? casaStory;

  final List<Drop> drops;

  Drop byId(String id) => drops.firstWhere((d) => d.id == id);

  /// Contenuti visibili adesso, in ordine cronologico.
  List<Drop> visible(StoryClock clock, StoryAnswers answers, DateTime now) {
    final t = clock.effectiveNow(now);
    final list = drops
        .where((d) => d.isVisibleFor(answers))
        .where((d) => !clock.unlockTime(d.at).isAfter(t))
        .toList();
    list.sort(
      (a, b) => a.at.minutesFromStart.compareTo(b.at.minutesFromStart),
    );
    return list;
  }

  /// Il finale raggiunto, se la storia è finita.
  Drop? endingReached(StoryClock clock, StoryAnswers answers, DateTime now) {
    for (final d in visible(clock, answers, now)) {
      if (d.ending != null) return d;
    }
    return null;
  }

  /// Una scelta si può ancora fare?
  bool choiceOpen(
    Drop drop,
    StoryClock clock,
    StoryAnswers answers,
    DateTime now,
  ) {
    if (drop.kind != DropKind.scelta) return false;
    if (answers.has(choiceKey(drop))) return false;
    final deadline = drop.deadline;
    if (deadline == null) return true;
    return clock.unlockTime(deadline).isAfter(clock.effectiveNow(now));
  }

  /// Chiave di risposta associata a una scelta.
  static String choiceKey(Drop drop) => drop.id == '3d' ? choiceD3 : choiceD5;

  /// Esito di una chiamata a Casa adesso.
  /// Ritorna (testo da mostrare, nuove risposte).
  ({String text, StoryAnswers answers, bool speaks}) callCasa(
    StoryClock clock,
    StoryAnswers answers,
    DateTime now,
  ) {
    final ending = endingReached(clock, answers, now);
    if (ending != null) {
      final happy = ending.id == '7g4';
      if (happy) {
        return (
          text: callHappyText,
          answers: answers.copyWith(keyCall, callHappy),
          speaks: true,
        );
      }
      return (text: callDeadText, answers: answers, speaks: false);
    }
    // Prima della fine: la chiamata cambia la storia (una volta sola).
    return (
      text: callEarlyText,
      answers: answers.has(keyCall)
          ? answers
          : answers.copyWith(keyCall, callEarly),
      speaks: false,
    );
  }

  /// Notifiche future da programmare con lo stato attuale.
  /// Con [quietNights] le notifiche tra le 23 e le 8 slittano alle 8
  /// (solo in modalità normale: in anteprima i tempi sono compressi).
  List<PlannedNotification> plan(
    StoryClock clock,
    StoryAnswers answers,
    DateTime now, {
    bool quietNights = false,
  }) {
    if (clock.paused) return const [];
    final out = <PlannedNotification>[];
    for (var i = 0; i < drops.length; i++) {
      final d = drops[i];
      if (d.notif == null || d.at.day <= 0) continue;
      if (!d.isVisibleFor(answers)) continue;
      var at = clock.unlockTime(d.at);
      if (!at.isAfter(now)) continue;
      if (quietNights && !clock.preview) at = shiftOutOfNight(at);
      out.add(
        PlannedNotification(id: 100 + i, dropId: d.id, at: at, text: d.notif!),
      );
    }
    return out;
  }

  /// Sposta un orario notturno (23:00–07:59) alle 8:00 successive.
  static DateTime shiftOutOfNight(DateTime t) {
    if (t.hour >= 23) {
      return DateTime(t.year, t.month, t.day + 1, 8);
    }
    if (t.hour < 8) {
      return DateTime(t.year, t.month, t.day, 8);
    }
    return t;
  }
}
