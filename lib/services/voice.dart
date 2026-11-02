import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Vocali letti con la sintesi vocale del telefono (gratis, senza rete).
class Voice {
  final FlutterTts _tts = FlutterTts();
  bool _ready = false;
  final ValueNotifier<String?> playing = ValueNotifier<String?>(null);

  static const _profiles = <String, ({double pitch, double rate, double vol})>{
    'marta': (pitch: 1.1, rate: 0.40, vol: 0.55),
    'ettore': (pitch: 0.72, rate: 0.38, vol: 1.0),
    'elsa': (pitch: 0.92, rate: 0.36, vol: 0.9),
  };

  Future<void> _init() async {
    if (_ready) return;
    try {
      await _tts.setLanguage('it-IT');
      _tts.setCompletionHandler(() => playing.value = null);
      _tts.setCancelHandler(() => playing.value = null);
      _tts.setErrorHandler((_) => playing.value = null);
      _ready = true;
    } catch (e) {
      debugPrint('Sintesi vocale non disponibile: $e');
    }
  }

  Future<void> play(String id, String text, String? who) async {
    await _init();
    if (playing.value == id) {
      await stop();
      return;
    }
    await stop();
    final p = _profiles[who] ?? (pitch: 1.0, rate: 0.45, vol: 1.0);
    try {
      await _tts.setPitch(p.pitch);
      await _tts.setSpeechRate(p.rate);
      await _tts.setVolume(p.vol);
      playing.value = id;
      await _tts.speak(text);
    } catch (e) {
      playing.value = null;
      debugPrint('Errore vocale: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
    playing.value = null;
  }
}
