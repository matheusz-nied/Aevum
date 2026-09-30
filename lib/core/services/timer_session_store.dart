import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:aevum/features/tasks/domain/timer_visual_mode.dart';

/// Retrato da sessão em andamento, suficiente para retomá-la se o processo
/// for encerrado pelo sistema.
class TimerSessionSnapshot {
  const TimerSessionSnapshot({
    required this.taskId,
    required this.targetSeconds,
    required this.elapsedMs,
    required this.visualMode,
    required this.savedAt,
  });

  final String taskId;
  final int targetSeconds;
  final int elapsedMs;
  final TimerVisualMode visualMode;
  final DateTime savedAt;

  Map<String, dynamic> toMap() => {
    'taskId': taskId,
    'targetSeconds': targetSeconds,
    'elapsedMs': elapsedMs,
    'visualMode': visualMode.name,
    'savedAt': savedAt.toIso8601String(),
  };

  static TimerSessionSnapshot? fromMap(Map<String, dynamic> map) {
    final taskId = map['taskId'];
    final targetSeconds = map['targetSeconds'];
    final elapsedMs = map['elapsedMs'];
    final savedAt = DateTime.tryParse('${map['savedAt']}');
    if (taskId is! String ||
        targetSeconds is! int ||
        elapsedMs is! int ||
        savedAt == null) {
      return null;
    }
    return TimerSessionSnapshot(
      taskId: taskId,
      targetSeconds: targetSeconds,
      elapsedMs: elapsedMs,
      visualMode: TimerVisualMode.values.firstWhere(
        (mode) => mode.name == map['visualMode'],
        orElse: () => TimerVisualMode.minimalDial,
      ),
      savedAt: savedAt,
    );
  }
}

/// Guarda localmente (SharedPreferences) o snapshot da sessão ativa.
class TimerSessionStore {
  TimerSessionStore(this._preferences);

  static const _key = 'aevum.timer.activeSession';

  final SharedPreferences _preferences;

  TimerSessionSnapshot? load() {
    final raw = _preferences.getString(_key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return TimerSessionSnapshot.fromMap(decoded);
      }
    } on FormatException {
      // Snapshot corrompido: tratado como ausente.
    }
    return null;
  }

  Future<void> save(TimerSessionSnapshot snapshot) =>
      _preferences.setString(_key, jsonEncode(snapshot.toMap()));

  Future<void> clear() => _preferences.remove(_key);
}
