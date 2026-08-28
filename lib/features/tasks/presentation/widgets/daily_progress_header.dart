import 'package:flutter/material.dart';
import 'package:timing/core/constants/app_colors.dart';
import 'package:timing/core/utils/time_utils.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final progressRatio = totalTasksCount > 0
        ? (completedTasksCount / totalTasksCount).clamp(0.0, 1.0)
        : 0.0;
    final percent = (progressRatio * 100).toInt();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: AppColors.warmAmber.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          // Circular Progress Indicator (Ref 2)
          SizedBox(
            width: 76,
            height: 76,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progressRatio,
                  strokeWidth: 8,
                  strokeCap: StrokeCap.round,
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    percent == 100 ? AppColors.sacredTeal : AppColors.warmAmber,
                  ),
                ),
                Text(
                  '$percent%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),

          // Daily stats summary
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TimeUtils.formatHeaderDate(DateTime.now()),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textMuted : Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalFocusedMinutes min focados hoje',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completedTasksCount de $totalTasksCount hábitos concluídos',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.textMuted : Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          // Stats icon button
          IconButton(
            onPressed: onOpenStats,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? AppColors.darkSurfaceElevated
                    : const Color(0xFFF1F3F6),
              ),
              child: Icon(
                Icons.insights_rounded,
                size: 20,
                color: isDark ? AppColors.warmAmber : AppColors.coralNeon,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
