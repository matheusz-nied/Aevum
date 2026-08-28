import 'package:flutter/material.dart';
import 'package:timing/core/constants/app_colors.dart';
import 'package:timing/core/utils/time_utils.dart';
import 'package:timing/core/widgets/glass_container.dart';

/// Painel principal do dia, inspirado no cartão vertical da referência.
class DailyProgressHeader extends StatelessWidget {
  final int totalFocusedMinutes;
  final int completedTasksCount;
  final int totalTasksCount;
  final VoidCallback onOpenStats;

  const DailyProgressHeader({
    super.key,
    required this.totalFocusedMinutes,
    required this.completedTasksCount,
    required this.totalTasksCount,
    required this.onOpenStats,
  });

  @override
  Widget build(BuildContext context) {
    final progressRatio = totalTasksCount > 0
        ? (completedTasksCount / totalTasksCount).clamp(0.0, 1.0)
        : 0.0;
    final percent = (progressRatio * 100).round();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
      child: GlassContainer(
        borderRadius: 30,
        blur: 20,
        strong: true,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onOpenStats,
            borderRadius: BorderRadius.circular(30),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        TimeUtils.formatHeaderDate(DateTime.now())
                            .toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.7,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const Row(
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.sage,
                            ),
                            child: SizedBox(width: 6, height: 6),
                          ),
                          SizedBox(width: 7),
                          Text(
                            'RITMO DO DIA',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.3,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'foco',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$totalFocusedMinutes min',
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 46,
                      height: 1,
                      fontWeight: FontWeight.w300,
                      letterSpacing: -2.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'registrados hoje',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: SizedBox(
                      height: 5,
                      child: LinearProgressIndicator(
                        value: progressRatio,
                        backgroundColor: Colors.white.withValues(alpha: 0.07),
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.sage,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ProgressMetric(
                        icon: Icons.check_rounded,
                        label:
                            '$completedTasksCount de $totalTasksCount hábitos completos',
                      ),
                      _ProgressMetric(
                        icon: Icons.trending_up_rounded,
                        label: '$percent%',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressMetric extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ProgressMetric({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.sage),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
