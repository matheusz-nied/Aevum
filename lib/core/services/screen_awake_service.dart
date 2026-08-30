import 'package:wakelock_plus/wakelock_plus.dart';

class ScreenAwakeService {
  const ScreenAwakeService._();

  static Future<void> setEnabled(bool enabled) async {
    try {
      await WakelockPlus.toggle(enable: enabled);
    } catch (_) {
      // A session still works when a platform does not expose wakelock.
    }
  }
}
