import 'package:flutter_tts/flutter_tts.dart';
import 'app_store.dart';

class Speaker {
  static final FlutterTts _tts = FlutterTts();

  static Future<void> say(String text) async {
    if (!AppStore.instance.soundEnabled || text.trim().isEmpty) return;
    try {
      await _tts.setLanguage(AppStore.instance.ttsLanguage);
      await _tts.setSpeechRate(0.42);
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {
      // Speech can fail on a device with no voice installed. The screen still works.
    }
  }

  static Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
