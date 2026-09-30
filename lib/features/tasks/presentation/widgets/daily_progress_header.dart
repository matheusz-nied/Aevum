import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:aevum/core/config/app_performance_policy.dart';
import 'package:aevum/core/constants/app_colors.dart';
import 'package:aevum/core/theme/app_typography.dart';
import 'package:aevum/core/widgets/glass_container.dart';

/// Um hábito agendado para hoje, como arco do anel do dia.
class DailyRingSegment {
  final Color color;
  final bool done;

  const DailyRingSegment({required this.color, required this.done});
}

/// Painel principal do dia: um anel com um arco por hábito de hoje, que
/// acende na cor do hábito quando ele é concluído, e o foco acumulado.
class DailyProgressHeader extends StatelessWidget {
  final int totalFocusedMinutes;
  final int completedTasksCount;
  final int totalTasksCount;
  final VoidCallback onOpenStats;

  /// Arcos do anel. Se nulo, é derivado das contagens com a cor sálvia.
  final List<DailyRingSegment>? segments;

  const DailyProgressHeader({
    super.key,
    required this.totalFocusedMinutes,
    required this.completedTasksCount,
    required this.totalTasksCount,
    required this.onOpenStats,
    this.segments,
  });

  @override
  Widget build(BuildContext context) {
    final progressRatio = totalTasksCount > 0
        ? (completedTasksCount / totalTasksCount).clamp(0.0, 1.0)
        : 0.0;
    final percent = (progressRatio * 100).round();
    final ringSegments =
        segments ??
        List.generate(
          totalTasksCount,
          (i) => DailyRingSegment(
            color: AppColors.sage,
            done: i < completedTasksCount,
          ),
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: GlassContainer(
        borderRadius: 30,
        blur: 26,
        strong: true,
        accentColor: AppColors.sage,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onOpenStats,
            borderRadius: BorderRadius.circular(30),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 22, 20),
              child: Row(
                children: [
                  _DayRing(segments: ringSegments, percent: percent),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.dawn,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.dawn.withValues(
                                      alpha: 0.6,
                                    ),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'RITMO DO DIA',
                              style: AppTypography.eyebrow,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '$totalFocusedMinutes min',
                            style: AppTypography.serif(
                              size: 40,
                              weight: FontWeight.w400,
                              height: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'de foco registrados hoje',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 14,
                              color: AppColors.sage,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                '$completedTasksCount de $totalTasksCount hábitos completos',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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

class _DayRing extends StatelessWidget {
  final List<DailyRingSegment> segments;
  final int percent;

  const _DayRing({required this.segments, required this.percent});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 104,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 1100),
        curve: Curves.easeOutCubic,
        builder: (context, reveal, child) => CustomPaint(
          painter: _DayRingPainter(segments: segments, reveal: reveal),
          child: child,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percent%',
                style: AppTypography.serif(
                  size: 24,
                  weight: FontWeight.w500,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'do dia',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayRingPainter extends CustomPainter {
  final List<DailyRingSegment> segments;
  final double reveal;

  _DayRingPainter({required this.segments, required this.reveal});

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 7.0;
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - stroke / 2 - 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.07);

    if (segments.isEmpty) {
      canvas.drawCircle(center, radius, track);
      return;
    }

    final count = segments.length;
    // Espaço entre arcos: some quando há um único hábito (anel inteiro).
    final gap = count == 1 ? 0.0 : math.min(0.28, 1.2 / count);
    final sweep = (2 * math.pi - gap * count) / count;
    // Com a ponta arredondada o traço "cresce" meio stroke em cada lado.
    final capAngle = count == 1 ? 0.0 : stroke / radius;

    for (var i = 0; i < count; i++) {
      final start = -math.pi / 2 + i * (sweep + gap) + gap / 2;
      final visibleSweep = math.max(0.001, sweep - capAngle);
      canvas.drawArc(rect, start + capAngle / 2, visibleSweep, false, track);

      final segment = segments[i];
      if (!segment.done) continue;
      // O anel se preenche em sequência na entrada.
      final local = ((reveal * count) - i).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = segment.color;
      if (AppPerformancePolicy.usePainterBlur) {
        canvas.drawArc(
          rect,
          start + capAngle / 2,
          visibleSweep * local,
          false,
          paint
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
            ..color = segment.color.withValues(alpha: 0.45),
        );
      }
      canvas.drawArc(
        rect,
        start + capAngle / 2,
        visibleSweep * local,
        false,
        paint
          ..maskFilter = null
          ..color = segment.color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DayRingPainter oldDelegate) =>
      oldDelegate.reveal != reveal || oldDelegate.segments != segments;
}
