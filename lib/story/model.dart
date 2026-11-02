/// Modello dei dati della storia: puro Dart, testabile senza Flutter.
library;

/// Tipi di contenuto che "arrivano" sul telefono ereditato.
enum DropKind {
  sistema,
  nota,
  promemoria,
  vocale,
  foto,
  email,
  messaggio,
  scelta,
  contatto,
}

/// Stato delle scelte del giocatore. Le chiavi sono gli id delle scelte
/// (es. "d3", "d5") più "chiamata" per il contatto Casa.
class StoryAnswers {
  StoryAnswers([Map<String, String>? values])
      : values = Map<String, String>.from(values ?? const {});

  final Map<String, String> values;

  String? operator [](String key) => values[key];

  bool isAnswer(String key, String value) => values[key] == value;

  bool has(String key) => values.containsKey(key);

  StoryAnswers copyWith(String key, String value) {
    final next = Map<String, String>.from(values);
    next[key] = value;
    return StoryAnswers(next);
  }
}

typedef StoryCondition = bool Function(StoryAnswers answers);

/// Un'opzione di risposta a un messaggio con scelta.
class ChoiceOption {
  const ChoiceOption({
    required this.value,
    required this.label,
    this.reply,
  });

  /// Valore salvato nelle risposte (es. "giornale").
  final String value;

  /// Testo del pulsante, cioè quello che "scrive" il giocatore.
  final String label;

  /// Risposta immediata del personaggio, se c'è.
  final String? reply;
}

/// Un momento della storia, espresso come giorno e ora della storia.
class StoryTime {
  const StoryTime(this.day, [this.hour = 0, this.minute = 0]);

  /// 0 = subito all'accensione; 1..7 = giorni della storia.
  final int day;
  final int hour;
  final int minute;

  /// Minuti dall'inizio del giorno 1 (il giorno 0 vale 0).
  int get minutesFromStart =>
      day <= 0 ? 0 : (day - 1) * 1440 + hour * 60 + minute;

  String get label {
    if (day <= 0) return 'Già sul telefono';
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return 'Giorno $day · $h:$m';
  }
}

/// Un singolo contenuto della storia.
class Drop {
  const Drop({
    required this.id,
    required this.at,
    required this.kind,
    required this.body,
    this.from,
    this.title,
    this.notif,
    this.when,
    this.options = const [],
    this.deadline,
    this.voice,
    this.ending,
    this.callable = false,
  });

  final String id;
  final StoryTime at;
  final DropKind kind;

  /// Autore o mittente (es. "Marta (nuovo numero)").
  final String? from;

  /// Oggetto dell'email, titolo del vocale, nome del contatto...
  final String? title;

  /// Testo principale (nota, trascrizione, descrizione della foto...).
  final String body;

  /// Testo della notifica; null = nessuna notifica.
  final String? notif;

  /// Condizione per comparire; null = sempre.
  final StoryCondition? when;

  /// Opzioni, solo per [DropKind.scelta].
  final List<ChoiceOption> options;

  /// Oltre questo momento la scelta non si può più fare.
  final StoryTime? deadline;

  /// Personaggio per la sintesi vocale ("marta", "ettore", "elsa").
  final String? voice;

  /// Titolo del finale, se questo contenuto chiude la storia.
  final String? ending;

  /// Il contatto si può chiamare (solo per "Casa").
  final bool callable;

  bool isVisibleFor(StoryAnswers answers) => when == null || when!(answers);
}
