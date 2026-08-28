import 'package:flutter/material.dart';
import 'package:timing/core/constants/app_colors.dart';
import 'package:timing/core/utils/time_utils.dart';
import 'package:timing/core/widgets/glass_container.dart';

/// Cabeçalho de progresso diário com efeito de vidro e gradiente calmante.
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
    final percent = (progressRatio * 100).toInt();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: GlassContainer(
        borderRadius: 24,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              // Indicador circular calmo
              SizedBox(
                width: 74,
                height: 74,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progressRatio,
                      strokeWidth: 7,
                      strokeCap: StrokeCap.round,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        percent == 100
                            ? AppColors.softGlowEmerald
                            : AppColors.sage,
                      ),
                    ),
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textWhite,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),

              // Resumo diário
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TimeUtils.formatHeaderDate(DateTime.now()),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'hoje em foco',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$totalFocusedMinutes min',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completedTasksCount de $totalTasksCount hábitos completos',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
