import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();

  /// Toca o som suave de término incorporado ao app.
  static Future<void> playTimerCompleteSound() async {
    try {
      // Reinicia o som caso duas conclusões sejam disparadas muito próximas.
      await _player.stop();
      await _player.play(AssetSource('audio/timer_complete.wav'), volume: 0.65);
    } catch (error) {
      debugPrint('Não foi possível tocar o som de conclusão: $error');
    }
  }

  /// Toca um clique sutil de botão
  static Future<void> playClickSound() async {
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }
}
