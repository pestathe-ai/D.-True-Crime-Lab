/// Modello dei dati della storia: puro Dart, testabile senza Flutter.
library;

/// Tipi di contenuto che "arrivano" sul dispositivo.
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

/// Su quale dispositivo arriva un contenuto quando si gioca in due.
/// In partita da soli si vede tutto.
enum Device { telefono, tablet }

/// Stato del giocatore: scelte, domande risolte, enigmi, telefonate.
/// È una mappa chiave → valore salvata sul telefono.
class StoryAnswers {
  StoryAnswers([Map<String, String>? values])
      : values = Map<String, String>.from(values ?? const {});

  final Map<String, String> values;

  String? operator [](String key) => values[key];

  bool isAnswer(String key, String value) => values[key] == value;

  bool ok(String key) => values[key] == 'ok';

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
    if (day <= 0) return 'Già sul dispositivo';
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return 'Giorno $day · $h:$m';
  }
}

/// Zona da toccare in una foto, in coordinate relative (0..1).
class Hotspot {
  const Hotspot({
    required this.key,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.found,
  });

  /// Chiave salvata quando il dettaglio viene trovato.
  final String key;
  final double left;
  final double top;
  final double width;
  final double height;

  /// Testo mostrato quando lo trovi.
  final String found;

  bool contains(double x, double y) =>
      x >= left && x <= left + width && y >= top && y <= top + height;
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
    this.device,
    this.clue,
    this.image,
    this.hotspot,
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

  /// Personaggio per la sintesi vocale ("marta", "ettore", "elsa", "paolo").
  final String? voice;

  /// Titolo del finale, se questo contenuto chiude la storia.
  final String? ending;

  /// Il contatto si può chiamare.
  final bool callable;

  /// Dispositivo su cui arriva in partita a due; null = su entrambi.
  final Device? device;

  /// Riassunto da appuntare in bacheca; null = non è un indizio.
  final String? clue;

  /// Illustrazione (asset) per le foto.
  final String? image;

  /// Dettaglio nascosto nella foto.
  final Hotspot? hotspot;

  bool isVisibleFor(StoryAnswers answers) => when == null || when!(answers);

  bool isOnDevice(Device? playing) =>
      playing == null || device == null || device == playing;
}

/// Una domanda del caso, sulla bacheca dell'indagine.
class CaseQuestion {
  const CaseQuestion({
    required this.id,
    required this.text,
    required this.options,
    required this.correct,
    required this.requires,
    required this.at,
    required this.solved,
  });

  final String id;
  final String text;
  final List<String> options;
  final int correct;

  /// Indizi da appuntare in bacheca per sbloccare la domanda.
  /// Si considerano solo quelli che esistono sul proprio dispositivo.
  final List<String> requires;

  /// Momento minimo in cui la domanda può comparire.
  final StoryTime at;

  /// Spiegazione mostrata quando la risolvi.
  final String solved;
}

/// Risposta a una telefonata.
class CallReply {
  const CallReply({
    required this.text,
    this.voice,
    this.sets,
    this.answered = true,
  });

  final String text;
  final String? voice;

  /// Chiave da segnare "ok" dopo la chiamata (sblocca contenuti).
  final String? sets;

  /// false = nessuno risponde (squilla, segreteria, ufficio chiuso).
  final bool answered;
}
