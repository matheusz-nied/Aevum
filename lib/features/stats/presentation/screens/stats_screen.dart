import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:aevum/core/constants/app_colors.dart';
import 'package:aevum/core/theme/app_typography.dart';
import 'package:aevum/core/utils/time_utils.dart';
import 'package:aevum/core/widgets/fade_slide_in.dart';
import 'package:aevum/core/widgets/forest_background.dart';
import 'package:aevum/core/widgets/glass_container.dart';
import 'package:aevum/core/widgets/glass_icon_button.dart';
import 'package:aevum/features/stats/domain/streak_calculator.dart';
import 'package:aevum/features/tasks/domain/session_record.dart';
import 'package:aevum/features/tasks/domain/task_model.dart';
import 'package:aevum/features/tasks/providers/task_providers.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionListProvider);
    final tasks = ref.watch(taskListProvider);

    final currentStreak = StreakCalculator.calculateCurrentStreak(
      sessions,
      tasks: tasks,
    );
    final totalMinutes = StreakCalculator.getTotalMinutes(sessions);
    final last7Days = StreakCalculator.getLast7DaysMetrics(sessions);
    final weekMinutes = last7Days.fold<int>(
      0,
      (sum, day) => sum + day.totalMinutes,
    );
    final tasksById = <String, TaskModel>{
      for (final task in tasks) task.id: task,
    };

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: ForestBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 48),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GlassIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  iconSize: 17,
                  tooltip: 'Voltar',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(height: 22),
              FadeSlideIn(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ESTATÍSTICAS', style: AppTypography.eyebrow),
                      const SizedBox(height: 6),
                      Text(
                        'Seu progresso',
                        style: AppTypography.serif(size: 36, height: 1.1),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Constância tranquila, um dia de cada vez.',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              FadeSlideIn(
                index: 1,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Sequência',
                          value: '$currentStreak',
                          unit: currentStreak == 1 ? 'dia' : 'dias',
                          icon: Icons.local_fire_department_rounded,
                          accentColor: AppColors.dawn,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          title: 'Foco total',
                          value: TimeUtils.formatMinutesReadable(totalMinutes),
                          icon: Icons.timer_outlined,
                          accentColor: AppColors.sage,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          title: 'Sessões',
                          value: '${sessions.length}',
                          icon: Icons.check_circle_outline_rounded,
                          accentColor: AppColors.emeraldMist,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              FadeSlideIn(
                index: 2,
                child: _WeekChart(days: last7Days, weekMinutes: weekMinutes),
              ),
              const SizedBox(height: 30),

              FadeSlideIn(
                index: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    'Histórico recente',
                    style: AppTypography.serif(
                      size: 22,
                      weight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FadeSlideIn(
                index: 4,
                child: sessions.isEmpty
                    ? const _EmptyHistory()
                    : _HistoryList(
                        sessions: sessions.take(10).toList(),
                        tasksById: tasksById,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? unit;
  final IconData icon;
  final Color accentColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 24,
      blur: 20,
      accentColor: accentColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accentColor, size: 20),
            const SizedBox(height: 16),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: AppTypography.serif(
                      size: 28,
                      weight: FontWeight.w500,
                      height: 1.0,
                    ),
                  ),
                  if (unit != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      unit!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekChart extends StatelessWidget {
  final List<DayFocusMetric> days;
  final int weekMinutes;

  const _WeekChart({required this.days, required this.weekMinutes});

  @override
  Widget build(BuildContext context) {
    // Calculados uma vez por build: evita DateTime.now()/DateFormat dentro
    // dos builders do gráfico.
    final today = DateTime.now();
    final maxMinutes = days.fold<int>(
      30,
      (max, item) => item.totalMinutes > max ? item.totalMinutes : max,
    );
    final chartMaxY = (maxMinutes * 1.15).toDouble();
    final weekdayLabels = List<String>.generate(days.length, (i) {
      final date = days[i].date;
      if (TimeUtils.isSameDay(date, today)) return 'Hoje';
      return DateFormat('E', 'pt_BR').format(date).replaceAll('.', '');
    });
    final tooltipDates = List<String>.generate(
      days.length,
      (i) => DateFormat('dd/MM').format(days[i].date),
    );

    return GlassContainer(
      borderRadius: 28,
      blur: 24,
      strong: true,
      accentColor: AppColors.sage,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Expanded(
                  child: Text('ÚLTIMOS 7 DIAS', style: AppTypography.eyebrow),
                ),
                Text(
                  TimeUtils.formatMinutesReadable(weekMinutes),
                  style: AppTypography.serif(size: 22, weight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 2),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'nesta semana',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 190,
              // Isola o raster do gráfico do scroll da tela.
              child: RepaintBoundary(
                child: BarChart(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: chartMaxY,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (group) =>
                            AppColors.forestSurfaceElevated,
                        tooltipBorderRadius: BorderRadius.circular(12),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final index = group.x.toInt();
                          return BarTooltipItem(
                            '${days[index].totalMinutes} min\n',
                            const TextStyle(
                              fontFamily: AppTypography.body,
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                            children: [
                              TextSpan(
                                text: tooltipDates[index],
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (val, meta) {
                            final index = val.toInt();
                            if (index < 0 || index >= days.length) {
                              return const SizedBox.shrink();
                            }
                            final label = weekdayLabels[index];
                            final isToday = label == 'Hoje';

                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isToday
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                  color: isToday
                                      ? AppColors.dawn
                                      : AppColors.textMuted,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(days.length, (i) {
                      final metric = days[i];
                      final isToday = TimeUtils.isSameDay(metric.date, today);
                      final top = isToday ? AppColors.dawn : AppColors.sage;

                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: metric.totalMinutes.toDouble(),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [top, top.withValues(alpha: 0.35)],
                            ),
                            width: 22,
                            borderRadius: BorderRadius.circular(99),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: chartMaxY,
                              color: Colors.white.withValues(alpha: 0.04),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sessões agrupadas por dia numa única superfície, como um diário.
class _HistoryList extends StatelessWidget {
  final List<SessionRecord> sessions;
  final Map<String, TaskModel> tasksById;

  const _HistoryList({required this.sessions, required this.tasksById});

  String _dayLabel(DateTime date, DateTime today) {
    if (TimeUtils.isSameDay(date, today)) return 'Hoje';
    final yesterday = today.subtract(const Duration(days: 1));
    if (TimeUtils.isSameDay(date, yesterday)) return 'Ontem';
    return DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final timeFormat = DateFormat('HH:mm');
    final children = <Widget>[];
    DateTime? currentDay;

    for (final session in sessions) {
      final date = session.completedAt;
      if (currentDay == null || !TimeUtils.isSameDay(currentDay, date)) {
        currentDay = date;
        children.add(
          Padding(
            padding: EdgeInsets.fromLTRB(18, children.isEmpty ? 16 : 20, 18, 6),
            child: Text(
              _dayLabel(date, today).toUpperCase(),
              style: AppTypography.eyebrow.copyWith(fontSize: 11),
            ),
          ),
        );
      }

      final task = tasksById[session.taskId];
      final taskColor =
          task?.color ??
          (session.taskColorValue != null
              ? Color(session.taskColorValue!)
              : AppColors.textMuted);

      children.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 16, 8),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  color: taskColor.withValues(alpha: 0.14),
                  border: Border.all(color: taskColor.withValues(alpha: 0.2)),
                ),
                child: Icon(
                  task?.iconData ?? Icons.history_rounded,
                  color: taskColor,
                  size: 19,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task?.title ?? session.taskTitle ?? 'Hábito removido',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.textWhite,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeFormat.format(date),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '+${session.durationSeconds ~/ 60} min',
                style: TextStyle(
                  color: taskColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GlassContainer(
      borderRadius: 26,
      blur: 20,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 26,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          children: [
            Icon(Icons.eco_outlined, color: AppColors.sage, size: 30),
            SizedBox(height: 12),
            Text(
              'Nenhuma sessão concluída ainda.\nInicie um timer para registrar seu progresso.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
