import 'package:timing/features/tasks/domain/session_record.dart';

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
  /// Calcula a sequência de dias consecutivos com pelo menos 1 sessão concluída
  static int calculateCurrentStreak(List<SessionRecord> sessions) {
    if (sessions.isEmpty) return 0;

    // Agrupar datas únicas normalizadas para meia-noite
    final uniqueDates = sessions
        .map((s) =>
            DateTime(s.completedAt.year, s.completedAt.month, s.completedAt.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (uniqueDates.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // A sequência é válida se o usuário fez hoje ou ontem
    final mostRecent = uniqueDates.first;
    if (!mostRecent.isAtSameMomentAs(today) &&
        !mostRecent.isAtSameMomentAs(yesterday)) {
      return 0;
    }

    int streak = 1;
    for (int i = 0; i < uniqueDates.length - 1; i++) {
      final current = uniqueDates[i];
      final next = uniqueDates[i + 1];

      final diffInDays = current.difference(next).inDays;
      if (diffInDays == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Retorna as métricas dos últimos 7 dias (do 6º dia atrás até hoje)
  static List<DayFocusMetric> getLast7DaysMetrics(
      List<SessionRecord> sessions) {
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

      final totalSeconds =
          daySessions.fold<int>(0, (sum, s) => sum + s.durationSeconds);

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
    final totalSeconds =
        sessions.fold<int>(0, (sum, s) => sum + s.durationSeconds);
    return totalSeconds ~/ 60;
  }
}
