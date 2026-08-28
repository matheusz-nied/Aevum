import 'package:flutter_test/flutter_test.dart';
import 'package:timing/features/stats/domain/streak_calculator.dart';
import 'package:timing/features/tasks/domain/session_record.dart';

void main() {
  group('StreakCalculator Tests', () {
    test('calculateCurrentStreak returns 0 for empty sessions', () {
      final streak = StreakCalculator.calculateCurrentStreak([]);
      expect(streak, equals(0));
    });

    test('calculateCurrentStreak returns 1 when session done today', () {
      final now = DateTime.now();
      final sessions = [
        SessionRecord(
          id: '1',
          taskId: 't1',
          completedAt: now,
          durationSeconds: 900,
          completedGoal: true,
        ),
      ];

      final streak = StreakCalculator.calculateCurrentStreak(sessions);
      expect(streak, equals(1));
    });

    test('calculateCurrentStreak calculates consecutive days properly', () {
      final now = DateTime.now();
      final sessions = [
        SessionRecord(
          id: '1',
          taskId: 't1',
          completedAt: now,
          durationSeconds: 900,
          completedGoal: true,
        ),
        SessionRecord(
          id: '2',
          taskId: 't1',
          completedAt: now.subtract(const Duration(days: 1)),
          durationSeconds: 900,
          completedGoal: true,
        ),
        SessionRecord(
          id: '3',
          taskId: 't1',
          completedAt: now.subtract(const Duration(days: 2)),
          durationSeconds: 900,
          completedGoal: true,
        ),
      ];

      final streak = StreakCalculator.calculateCurrentStreak(sessions);
      expect(streak, equals(3));
    });

    test('calculateCurrentStreak breaks if gap is greater than 1 day', () {
      final now = DateTime.now();
      final sessions = [
        SessionRecord(
          id: '1',
          taskId: 't1',
          completedAt: now,
          durationSeconds: 900,
          completedGoal: true,
        ),
        SessionRecord(
          id: '2',
          taskId: 't1',
          completedAt: now.subtract(const Duration(days: 3)), // 2 day gap
          durationSeconds: 900,
          completedGoal: true,
        ),
      ];

      final streak = StreakCalculator.calculateCurrentStreak(sessions);
      expect(streak, equals(1));
    });

    test('getLast7DaysMetrics returns exactly 7 metrics', () {
      final metrics = StreakCalculator.getLast7DaysMetrics([]);
      expect(metrics.length, equals(7));
    });
  });
}
