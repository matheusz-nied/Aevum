import 'dart:convert';

import 'package:aevum/features/tasks/domain/session_record.dart';
import 'package:aevum/features/tasks/domain/task_model.dart';

class BackupData {
  const BackupData({required this.tasks, required this.sessions});

  final List<TaskModel> tasks;
  final List<SessionRecord> sessions;
}

/// Converte hábitos e sessões de/para o JSON do backup manual.
class BackupCodec {
  static const String appId = 'aevum';
  static const int version = 1;

  static String encode(
    Iterable<TaskModel> tasks,
    Iterable<SessionRecord> sessions, {
    DateTime? now,
  }) {
    return jsonEncode({
      'app': appId,
      'version': version,
      'exportedAt': (now ?? DateTime.now()).toIso8601String(),
      'tasks': tasks.map((t) => t.toMap()).toList(),
      'sessions': sessions.map((s) => s.toMap()).toList(),
    });
  }

  /// Lança [FormatException] se [source] não for um backup válido do Aevum.
  static BackupData decode(String source) {
    final Object? root;
    try {
      root = jsonDecode(source);
    } on FormatException {
      throw const FormatException('O texto não é um JSON válido.');
    }
    if (root is! Map || root['app'] != appId) {
      throw const FormatException('O texto não é um backup do Aevum.');
    }
    final backupVersion = root['version'];
    if (backupVersion is! int || backupVersion > version) {
      throw const FormatException('Versão de backup não suportada.');
    }

    try {
      final tasks = (root['tasks'] as List)
          .map((e) => TaskModel.fromMap(e as Map))
          .toList();
      final sessions = (root['sessions'] as List)
          .map((e) => SessionRecord.fromMap(e as Map))
          .toList();
      return BackupData(tasks: tasks, sessions: sessions);
    } on Object {
      throw const FormatException('O backup está incompleto ou corrompido.');
    }
  }
}
