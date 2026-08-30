class TimeUtils {
  static const List<String> _weekdaysPt = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo',
  ];

  static const List<String> _monthsPt = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  /// Formata segundos em `MM:SS` ou `HH:MM:SS`
  static String formatSeconds(int totalSeconds) {
    if (totalSeconds < 0) totalSeconds = 0;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Formata minutos em formato amigável (ex: `15m`, `1h 30m`)
  static String formatMinutesReadable(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '${hours}h';
    }
    return '${hours}h ${remainingMinutes}m';
  }

  /// Verifica se duas datas são do mesmo dia
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Formata data para o cabeçalho (ex: `Sexta-feira, 28 de Agosto`)
  static String formatHeaderDate(DateTime date) {
    final weekday = _weekdaysPt[(date.weekday - 1).clamp(0, 6)];
    final month = _monthsPt[(date.month - 1).clamp(0, 11)];
    return '$weekday, ${date.day} de $month';
  }
}
