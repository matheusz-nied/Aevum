import 'package:flutter_test/flutter_test.dart';
import 'package:aevum/features/stats/domain/streak_calculator.dart';
import 'package:aevum/features/tasks/domain/session_record.dart';

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

    test(
      'calculateCurrentStreak counts days across month and year boundary',
      () {
        SessionRecord at(String id, DateTime d) => SessionRecord(
          id: id,
          taskId: 't1',
          completedAt: d,
          durationSeconds: 900,
          completedGoal: true,
        );
        final sessions = [
          at('1', DateTime(2026, 1, 1, 23, 50)),
          at('2', DateTime(2025, 12, 31, 0, 5)),
          at('3', DateTime(2025, 12, 30, 12)),
        ];

        final streak = StreakCalculator.calculateCurrentStreak(
          sessions,
          now: DateTime(2026, 1, 1, 8),
        );
        expect(streak, equals(3));
      },
    );

    test('calculateCurrentStreak is valid when last session was yesterday', () {
      final sessions = [
        SessionRecord(
          id: '1',
          taskId: 't1',
          completedAt: DateTime(2026, 3, 1, 23, 59),
          durationSeconds: 900,
          completedGoal: true,
        ),
      ];

      expect(
        StreakCalculator.calculateCurrentStreak(
          sessions,
          now: DateTime(2026, 3, 2, 0, 1),
        ),
        equals(1),
      );
      expect(
        StreakCalculator.calculateCurrentStreak(
          sessions,
          now: DateTime(2026, 3, 3, 0, 1),
        ),
        equals(0),
      );
    });

    test('getLast7DaysMetrics returns exactly 7 metrics', () {
      final metrics = StreakCalculator.getLast7DaysMetrics([]);
      expect(metrics.length, equals(7));
    });
  });
}
