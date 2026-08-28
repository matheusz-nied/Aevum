import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timing/core/constants/app_colors.dart';
import 'package:timing/core/utils/time_utils.dart';
import 'package:timing/features/stats/domain/streak_calculator.dart';
import 'package:timing/features/tasks/providers/task_providers.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionListProvider);
    final tasks = ref.watch(taskListProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final currentStreak = StreakCalculator.calculateCurrentStreak(sessions);
    final totalMinutes = StreakCalculator.getTotalMinutes(sessions);
    final last7Days = StreakCalculator.getLast7DaysMetrics(sessions);

    final maxMinutes = last7Days.fold<int>(
      30,
      (max, item) => item.totalMinutes > max ? item.totalMinutes : max,
    );

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Estatísticas & Hábitos',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Highlights (Streak, Total Time, Completed Sessions)
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Sequência',
                    value: '$currentStreak',
                    unit: 'dias',
                    icon: Icons.local_fire_department_rounded,
                    iconColor: AppColors.coralNeon,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Foco Total',
                    value: TimeUtils.formatMinutesReadable(totalMinutes),
                    unit: 'acumulado',
                    icon: Icons.timer_outlined,
                    iconColor: AppColors.warmAmber,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Sessões',
                    value: '${sessions.length}',
                    unit: 'feitas',
                    icon: Icons.check_circle_outline_rounded,
                    iconColor: AppColors.sacredTeal,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Weekly Chart Section
            Text(
              'Últimos 7 Dias',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              height: 220,
              padding:
                  const EdgeInsets.only(top: 24, right: 16, left: 8, bottom: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceCard : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06),
                ),
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (maxMinutes * 1.2).toDouble(),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final metric = last7Days[group.x.toInt()];
                        return BarTooltipItem(
                          '${metric.totalMinutes} min\n${DateFormat('dd/MM').format(metric.date)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) {
                          final index = val.toInt();
                          if (index < 0 || index >= last7Days.length) {
                            return const SizedBox.shrink();
                          }
                          final date = last7Days[index].date;
                          final isToday =
                              TimeUtils.isSameDay(date, DateTime.now());
                          final label = isToday
                              ? 'Hoje'
                              : DateFormat('E', 'pt_BR')
                                  .format(date)
                                  .replaceAll('.', '');

                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isToday
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isToday
                                    ? AppColors.warmAmber
                                    : (isDark
                                        ? AppColors.textMuted
                                        : Colors.black54),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(last7Days.length, (i) {
                    final metric = last7Days[i];
                    final isToday =
                        TimeUtils.isSameDay(metric.date, DateTime.now());

                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: metric.totalMinutes.toDouble(),
                          color: isToday
                              ? AppColors.warmAmber
                              : (metric.totalMinutes > 0
                                  ? AppColors.sacredTeal
                                  : (isDark
                                      ? Colors.white10
                                      : Colors.black12)),
                          width: 18,
                          borderRadius: BorderRadius.circular(6),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: (maxMinutes * 1.2).toDouble(),
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.03)
                                : Colors.black.withValues(alpha: 0.02),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Recent Sessions List
            Text(
              'Histórico Recente',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            if (sessions.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Nenhuma sessão concluída ainda.\nInicie um timer para registrar seu progresso!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? AppColors.textMuted : Colors.black45,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            else
              ...sessions.take(10).map((session) {
                final task = tasks.firstWhere(
                  (t) => t.id == session.taskId,
                  orElse: () => tasks.first,
                );

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceCard : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: task.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child:
                            Icon(task.iconData, color: task.color, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              DateFormat('dd/MM/yyyy HH:mm')
                                  .format(session.completedAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.textMuted
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.sacredTeal.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '+${session.durationSeconds ~/ 60}m',
                          style: const TextStyle(
                            color: AppColors.sacredTeal,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color iconColor;
  final bool isDark;

  const _StatCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.iconColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.textMuted : Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
