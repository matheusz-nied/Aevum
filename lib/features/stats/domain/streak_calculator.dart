import 'package:aevum/features/tasks/domain/session_record.dart';

class DayFocusMetric {
  final DateTime date;
  final int totalMinutes;
  final int sessionCount;

  DayFocusMetric({
    required this.date,
    required this.totalMinutes,
    required this.sessionCount,
  });
}

class StreakCalculator {
  /// Dia civil como data UTC: a diferença entre dois dias é sempre múltiplo
  /// exato de 24h, mesmo em fusos com horário de verão.
  static DateTime _civilDay(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day);

  /// Calcula a sequência de dias consecutivos com pelo menos 1 sessão concluída.
  /// [now] existe para permitir testes determinísticos.
  static int calculateCurrentStreak(
    List<SessionRecord> sessions, {
    DateTime? now,
  }) {
    if (sessions.isEmpty) return 0;

    final uniqueDates =
        sessions.map((s) => _civilDay(s.completedAt)).toSet().toList()
          ..sort((a, b) => b.compareTo(a));

    final today = _civilDay(now ?? DateTime.now());

    // A sequência é válida se o usuário fez hoje ou ontem
    final daysSinceLast = today.difference(uniqueDates.first).inDays;
    if (daysSinceLast != 0 && daysSinceLast != 1) return 0;

    int streak = 1;
    for (int i = 0; i < uniqueDates.length - 1; i++) {
      if (uniqueDates[i].difference(uniqueDates[i + 1]).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Retorna as métricas dos últimos 7 dias (do 6º dia atrás até hoje)
  static List<DayFocusMetric> getLast7DaysMetrics(
    List<SessionRecord> sessions,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final List<DayFocusMetric> list = [];

    for (int i = 6; i >= 0; i--) {
      final targetDate = today.subtract(Duration(days: i));

      final daySessions = sessions.where((s) {
        return s.completedAt.year == targetDate.year &&
            s.completedAt.month == targetDate.month &&
            s.completedAt.day == targetDate.day;
      });

      final totalSeconds = daySessions.fold<int>(
        0,
        (sum, s) => sum + s.durationSeconds,
      );

      list.add(
        DayFocusMetric(
          date: targetDate,
          totalMinutes: totalSeconds ~/ 60,
          sessionCount: daySessions.length,
        ),
      );
    }

    return list;
  }

  /// Total acumulado em minutos
  static int getTotalMinutes(List<SessionRecord> sessions) {
    final totalSeconds = sessions.fold<int>(
      0,
      (sum, s) => sum + s.durationSeconds,
    );
    return totalSeconds ~/ 60;
  }
}
