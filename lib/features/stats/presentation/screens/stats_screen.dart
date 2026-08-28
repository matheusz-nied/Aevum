import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timing/core/constants/app_colors.dart';
import 'package:timing/core/utils/time_utils.dart';
import 'package:timing/core/widgets/forest_background.dart';
import 'package:timing/core/widgets/glass_container.dart';
import 'package:timing/features/stats/domain/streak_calculator.dart';
import 'package:timing/features/tasks/providers/task_providers.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionListProvider);
    final tasks = ref.watch(taskListProvider);

    final currentStreak = StreakCalculator.calculateCurrentStreak(sessions);
    final totalMinutes = StreakCalculator.getTotalMinutes(sessions);
    final last7Days = StreakCalculator.getLast7DaysMetrics(sessions);

    final maxMinutes = last7Days.fold<int>(
      30,
      (max, item) => item.totalMinutes > max ? item.totalMinutes : max,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: ForestBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),

                // App bar
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                        color: AppColors.textWhite,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Estatísticas & Hábitos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.textWhite,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Cards de destaque
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Sequência',
                        value: '$currentStreak',
                        unit: 'dias',
                        icon: Icons.local_fire_department_rounded,
                        accentColor: AppColors.softGlowEmerald,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Foco Total',
                        value: TimeUtils.formatMinutesReadable(totalMinutes),
                        unit: 'acumulado',
                        icon: Icons.timer_outlined,
                        accentColor: AppColors.sage,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Sessões',
                        value: '${sessions.length}',
                        unit: 'feitas',
                        icon: Icons.check_circle_outline_rounded,
                        accentColor: AppColors.emeraldMist,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Gráfico 7 dias
                const Text(
                  'Últimos 7 Dias',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
                  ),
                ),
                const SizedBox(height: 12),

                GlassContainer(
                  borderRadius: 24,
                  blur: 18,
                  strong: true,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 24,
                      right: 16,
                      left: 8,
                      bottom: 12,
                    ),
                    child: SizedBox(
                      height: 220,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: (maxMinutes * 1.2).toDouble(),
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (group) =>
                                  AppColors.forestSurfaceElevated,
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
                                getTitlesWidget: (val, meta) {
                                  final index = val.toInt();
                                  if (index < 0 || index >= last7Days.length) {
                                    return const SizedBox.shrink();
                                  }
                                  final date = last7Days[index].date;
                                  final isToday = TimeUtils.isSameDay(
                                    date,
                                    DateTime.now(),
                                  );
                                  final label = isToday
                                      ? 'Hoje'
                                      : DateFormat(
                                          'E',
                                          'pt_BR',
                                        ).format(date).replaceAll('.', '');

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
                                            ? AppColors.sage
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
                          barGroups: List.generate(last7Days.length, (i) {
                            final metric = last7Days[i];
                            final isToday = TimeUtils.isSameDay(
                              metric.date,
                              DateTime.now(),
                            );

                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: metric.totalMinutes.toDouble(),
                                  color: isToday
                                      ? AppColors.sage
                                      : (metric.totalMinutes > 0
                                            ? AppColors.emeraldMist
                                            : Colors.white.withValues(
                                                alpha: 0.08,
                                              )),
                                  width: 18,
                                  borderRadius: BorderRadius.circular(6),
                                  backDrawRodData: BackgroundBarChartRodData(
                                    show: true,
                                    toY: (maxMinutes * 1.2).toDouble(),
                                    color: Colors.white.withValues(alpha: 0.03),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Histórico
                const Text(
                  'Histórico Recente',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
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
                          color: AppColors.textMuted,
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
                      child: GlassContainer(
                        borderRadius: 16,
                        blur: 14,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              // Orb icon da tarefa
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      task.color.withValues(alpha: 0.35),
                                      task.color.withValues(alpha: 0.08),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: task.color.withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Icon(
                                  task.iconData,
                                  color: task.color,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: AppColors.textWhite,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('dd/MM/yyyy HH:mm')
                                          .format(session.completedAt),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Tempo
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.emeraldMist.withValues(
                                    alpha: 0.14,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '+${session.durationSeconds ~/ 60}m',
                                  style: const TextStyle(
                                    color: AppColors.emeraldMist,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 40),
              ],
            ),
          ),
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
  final Color accentColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 20,
      blur: 16,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accentColor.withValues(alpha: 0.3),
                    accentColor.withValues(alpha: 0.08),
                  ],
                ),
              ),
              child: Icon(icon, color: accentColor, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textWhite,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
