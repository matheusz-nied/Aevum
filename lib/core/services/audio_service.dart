import 'package:flutter/services.dart';

class AudioService {
  /// Toca o som de término de timer (usando som de sistema ou áudio suave)
  static Future<void> playTimerCompleteSound() async {
    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (_) {}
  }

  /// Toca um clique sutil de botão
  static Future<void> playClickSound() async {
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }
}
