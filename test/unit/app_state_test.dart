import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aevum/core/config/app_links.dart';
import 'package:aevum/core/providers/app_state_provider.dart';
import 'package:aevum/core/services/app_preferences.dart';
import 'package:aevum/features/tasks/data/session_repository.dart';
import 'package:aevum/features/tasks/data/task_repository.dart';
import 'package:aevum/features/tasks/domain/session_record.dart';
import 'package:aevum/features/tasks/domain/task_icon.dart';
import 'package:aevum/features/tasks/domain/task_model.dart';
import 'package:aevum/features/tasks/providers/task_providers.dart';

void main() {
  late Directory hiveDirectory;
  late TaskRepository taskRepository;
  late SessionRepository sessionRepository;

  setUpAll(() async {
    hiveDirectory = await Directory.systemTemp.createTemp('aevum_state_test_');
    Hive.init(hiveDirectory.path);
    taskRepository = await TaskRepository.init();
    sessionRepository = await SessionRepository.init();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await taskRepository.clear();
    await sessionRepository.clear();
  });

  tearDownAll(() async {
    await Hive.close();
    await hiveDirectory.delete(recursive: true);
  });

  test('reset removes tasks, sessions and onboarding preference', () async {
    final preferences = AppPreferences(await SharedPreferences.getInstance());
    final tasks = TaskListNotifier(taskRepository);
    final sessions = SessionListNotifier(sessionRepository);
    final notifier = AppStateNotifier(preferences, tasks, sessions);

    await tasks.addTask(
      TaskModel(
        id: 'task',
        title: 'Leitura',
        targetMinutes: 10,
        iconKey: TaskIcon.reading,
        colorValue: 0xFF718B70,
      ),
    );
    await sessions.recordSession(
      SessionRecord(
        id: 'session',
        taskId: 'task',
        completedAt: DateTime(2026, 8, 30),
        durationSeconds: 600,
        completedGoal: true,
      ),
    );
    await notifier.completeOnboarding();

    expect(notifier.state.onboardingCompleted, isTrue);
    expect(tasks.state, hasLength(1));
    expect(sessions.state, hasLength(1));

    await notifier.resetAllData();

    expect(notifier.state.onboardingCompleted, isFalse);
    expect(tasks.state, isEmpty);
    expect(sessions.state, isEmpty);
    expect(preferences.onboardingCompleted, isFalse);
  });

  test('optional links recognize empty build-time values', () {
    expect(AppLinks.isConfigured(''), isFalse);
    expect(AppLinks.isConfigured('  '), isFalse);
    expect(AppLinks.isConfigured('https://example.com'), isTrue);
  });
}
