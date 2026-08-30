import 'package:aevum/core/constants/app_colors.dart';
import 'package:aevum/core/services/app_preferences.dart';
import 'package:aevum/features/tasks/data/session_repository.dart';
import 'package:aevum/features/tasks/data/task_repository.dart';
import 'package:aevum/features/tasks/domain/session_record.dart';
import 'package:aevum/features/tasks/domain/task_icon.dart';
import 'package:aevum/features/tasks/domain/task_model.dart';
import 'package:aevum/features/tasks/domain/timer_visual_mode.dart';

/// Deterministic-looking demo data compiled only into debug builds.
class ScreenshotFixtures {
  const ScreenshotFixtures._();

  static Future<void> load({
    required TaskRepository tasks,
    required SessionRepository sessions,
    required AppPreferences preferences,
  }) async {
    await tasks.clear();
    await sessions.clear();

    final fixtures = [
      TaskModel(
        id: 'capture-reading',
        title: 'Leitura tranquila',
        targetMinutes: 20,
        iconKey: TaskIcon.reading,
        colorValue: AppColors.emeraldMist.toARGB32(),
        defaultVisualMode: TimerVisualMode.minimalDial,
        createdAt: DateTime(2026, 8, 1),
      ),
      TaskModel(
        id: 'capture-writing',
        title: 'Escrita do dia',
        targetMinutes: 15,
        iconKey: TaskIcon.writing,
        colorValue: AppColors.sage.toARGB32(),
        defaultVisualMode: TimerVisualMode.inspirational,
        createdAt: DateTime(2026, 8, 2),
      ),
      TaskModel(
        id: 'capture-presence',
        title: 'Momento de presença',
        targetMinutes: 10,
        iconKey: TaskIcon.mindfulness,
        colorValue: AppColors.mossCalm.toARGB32(),
        defaultVisualMode: TimerVisualMode.focusFree,
        createdAt: DateTime(2026, 8, 3),
      ),
    ];

    for (final task in fixtures) {
      await tasks.saveTask(task);
    }

    final now = DateTime.now();
    for (var day = 0; day < 6; day++) {
      await sessions.addSession(
        SessionRecord(
          id: 'capture-session-$day',
          taskId: fixtures[day % fixtures.length].id,
          completedAt: now.subtract(Duration(days: day, hours: day + 1)),
          durationSeconds: (10 + day * 3) * 60,
          completedGoal: true,
        ),
      );
    }

    await preferences.setOnboardingCompleted(true);
  }
}
