import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:aevum/core/services/backup_codec.dart';
import 'package:aevum/features/tasks/data/session_repository.dart';
import 'package:aevum/features/tasks/data/task_repository.dart';
import 'package:aevum/features/tasks/domain/session_record.dart';
import 'package:aevum/features/tasks/domain/task_icon.dart';
import 'package:aevum/features/tasks/domain/task_model.dart';
import 'package:aevum/features/tasks/providers/task_providers.dart';

void main() {
  final task = TaskModel(
    id: 'task-1',
    title: 'Leitura',
    targetMinutes: 20,
    iconKey: TaskIcon.reading,
    colorValue: 0xFF88AA99,
    createdAt: DateTime(2026, 1, 2),
  );
  final session = SessionRecord(
    id: 'sess-1',
    taskId: 'task-1',
    completedAt: DateTime(2026, 1, 3, 8),
    durationSeconds: 600,
    completedGoal: false,
    taskTitle: 'Leitura',
    taskColorValue: 0xFF88AA99,
  );

  group('BackupCodec', () {
    test('round-trips tasks and sessions', () {
      final backup = BackupCodec.decode(BackupCodec.encode([task], [session]));

      expect(backup.tasks.single.id, 'task-1');
      expect(backup.tasks.single.title, 'Leitura');
      expect(backup.tasks.single.createdAt, DateTime(2026, 1, 2));
      expect(backup.sessions.single.completedGoal, isFalse);
      expect(backup.sessions.single.taskTitle, 'Leitura');
      expect(backup.sessions.single.taskColorValue, 0xFF88AA99);
    });

    test('rejects text that is not a valid Aevum backup', () {
      expect(() => BackupCodec.decode('não é json'), throwsFormatException);
      expect(() => BackupCodec.decode('[1, 2]'), throwsFormatException);
      expect(
        () => BackupCodec.decode(jsonEncode({'app': 'outro', 'version': 1})),
        throwsFormatException,
      );
      expect(
        () => BackupCodec.decode(
          jsonEncode({'app': 'aevum', 'version': BackupCodec.version + 1}),
        ),
        throwsFormatException,
      );
    });

    test('rejects a backup with malformed entries', () {
      final broken = jsonEncode({
        'app': 'aevum',
        'version': 1,
        'tasks': [
          {'id': 'sem-titulo'},
        ],
        'sessions': <Object>[],
      });
      expect(() => BackupCodec.decode(broken), throwsFormatException);
    });

    test('old sessions without snapshot fields still load', () {
      final legacy = SessionRecord.fromMap({
        'id': 's',
        'taskId': 't',
        'completedAt': DateTime(2026, 1, 1).toIso8601String(),
        'durationSeconds': 60,
      });
      expect(legacy.taskTitle, isNull);
      expect(legacy.taskColorValue, isNull);
      expect(legacy.toMap().containsKey('taskTitle'), isFalse);
    });
  });

  group('import into repositories', () {
    late Directory hiveDirectory;
    late TaskRepository taskRepository;
    late SessionRepository sessionRepository;

    setUpAll(() async {
      hiveDirectory = await Directory.systemTemp.createTemp('aevum_backup_');
      Hive.init(hiveDirectory.path);
      taskRepository = await TaskRepository.init();
      sessionRepository = await SessionRepository.init();
    });

    setUp(() async {
      await taskRepository.clear();
      await sessionRepository.clear();
    });

    tearDownAll(() async {
      await Hive.close();
      await hiveDirectory.delete(recursive: true);
    });

    test('merges by id without removing existing data', () async {
      final tasks = TaskListNotifier(taskRepository);
      final sessions = SessionListNotifier(sessionRepository);
      final existing = task.copyWith(id: 'keep', title: 'Existente');
      await tasks.addTask(existing);
      await tasks.addTask(task.copyWith(title: 'Título antigo'));

      final backup = BackupCodec.decode(BackupCodec.encode([task], [session]));
      await tasks.importTasks(backup.tasks);
      await sessions.importSessions(backup.sessions);
      await sessions.importSessions(backup.sessions); // idempotente

      expect(tasks.state.map((t) => t.id), containsAll(['keep', 'task-1']));
      expect(tasks.state.firstWhere((t) => t.id == 'task-1').title, 'Leitura');
      expect(sessions.state, hasLength(1));
    });

    test('deleted task can be restored with its position', () async {
      final tasks = TaskListNotifier(taskRepository);
      final other = task.copyWith(id: 'other', createdAt: DateTime(2026, 2, 1));
      await tasks.addTask(task);
      await tasks.addTask(other);

      await tasks.deleteTask(task.id);
      expect(tasks.state.map((t) => t.id), ['other']);

      await tasks.addTask(task);
      expect(tasks.state.map((t) => t.id), ['task-1', 'other']);
    });
  });
}
