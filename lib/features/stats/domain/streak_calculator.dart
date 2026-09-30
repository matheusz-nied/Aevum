import 'package:aevum/features/tasks/domain/session_record.dart';
import 'package:aevum/features/tasks/domain/task_model.dart';

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

  /// Calcula a sequência de dias com pelo menos 1 sessão concluída.
  ///
  /// Dias em que nenhum dos [tasks] se repete são de descanso: não contam nem
  /// quebram a sequência. O dia de hoje ainda em aberto também não a quebra.
  /// [now] existe para permitir testes determinísticos.
  static int calculateCurrentStreak(
    List<SessionRecord> sessions, {
    Iterable<TaskModel> tasks = const [],
    DateTime? now,
  }) {
    if (sessions.isEmpty) return 0;

    final sessionDays = sessions.map((s) => _civilDay(s.completedAt)).toSet();
    final earliest = sessionDays.reduce((a, b) => a.isBefore(b) ? a : b);
    final taskList = tasks.toList();

    bool isRestDay(DateTime day) =>
        taskList.isNotEmpty &&
        !taskList.any((t) => t.weekdays.contains(day.weekday));

    final today = _civilDay(now ?? DateTime.now());
    var cursor = sessionDays.contains(today)
        ? today
        : today.subtract(const Duration(days: 1));

    int streak = 0;
    while (!cursor.isBefore(earliest)) {
      if (sessionDays.contains(cursor)) {
        streak++;
      } else if (!isRestDay(cursor)) {
        break;
      }
      cursor = cursor.subtract(const Duration(days: 1));
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
