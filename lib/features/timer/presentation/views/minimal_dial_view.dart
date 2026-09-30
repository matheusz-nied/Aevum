import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:aevum/core/config/app_performance_policy.dart';
import 'package:aevum/core/constants/app_colors.dart';
import 'package:aevum/core/widgets/adaptive_backdrop_filter.dart';
import 'package:aevum/features/tasks/domain/task_model.dart';
import 'package:aevum/features/timer/domain/timer_state.dart';
import 'package:aevum/features/timer/presentation/widgets/timer_pill_button.dart';

/// View "Minimal Tátil" — dial analógico circular puro com progresso.
class MinimalDialView extends StatelessWidget {
  final TaskModel task;
  final TimerState state;
  final VoidCallback onTogglePlayPause;
  final VoidCallback onReset;
  final Function(int) onAddMinutes;

  const MinimalDialView({
    super.key,
    required this.task,
    required this.state,
    required this.onTogglePlayPause,
    required this.onReset,
    required this.onAddMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = task.color;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Dial circular em vidro (sem timer digital)
        Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.10),
                  blurRadius: 60,
                  spreadRadius: -10,
                ),
              ],
            ),
            child: ClipOval(
              child: AdaptiveBackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.05),
                        Colors.white.withValues(alpha: 0.015),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(290, 290),
                        painter: _DialPainter(
                          progress: state.progress,
                          accentColor: accentColor,
                        ),
                      ),

                      // Play/pause central
                      Semantics(
                        button: true,
                        label: state.isRunning ? 'Pausar' : 'Iniciar',
                        child: GestureDetector(
                          onTap: onTogglePlayPause,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: state.isRunning
                                  ? accentColor.withValues(alpha: 0.12)
                                  : accentColor,
                              border: Border.all(
                                color: accentColor.withValues(alpha: 0.35),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withValues(alpha: 0.25),
                                  blurRadius: 30,
                                  spreadRadius: -6,
                                ),
                              ],
                            ),
                            child: Icon(
                              state.isRunning
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              size: 40,
                              color: state.isRunning
                                  ? accentColor
                                  : AppColors.forestDeep,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Ajustes rápidos
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            TimerPillButton(
              icon: Icons.add_rounded,
              label: '1 min',
              onTap: () => onAddMinutes(1),
            ),
            TimerPillButton(
              icon: Icons.add_rounded,
              label: '5 min',
              onTap: () => onAddMinutes(5),
            ),
            TimerPillButton(
              icon: Icons.refresh_rounded,
              label: 'Reiniciar',
              onTap: onReset,
            ),
          ],
        ),
      ],
    );
  }
}

class _DialPainter extends CustomPainter {
  final double progress;
  final Color accentColor;

  _DialPainter({required this.progress, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    final arcRadius = radius - 20;
    final arcRect = Rect.fromCircle(center: center, radius: arcRadius);
    final sweep = 2 * pi * progress;

    // Trilho
    canvas.drawCircle(
      center,
      arcRadius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );

    if (progress > 0) {
      // Brilho difuso sob o arco
      if (AppPerformancePolicy.usePainterBlur) {
        canvas.drawArc(
          arcRect,
          -pi / 2,
          sweep,
          false,
          Paint()
            ..color = accentColor.withValues(alpha: 0.45)
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = 8
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
      }
      canvas.drawArc(
        arcRect,
        -pi / 2,
        sweep,
        false,
        Paint()
          ..shader = SweepGradient(
            endAngle: max(sweep, 0.01),
            colors: [accentColor.withValues(alpha: 0.35), accentColor],
            transform: const GradientRotation(-pi / 2),
          ).createShader(arcRect)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 5,
      );
    }

    // Marcações de minuto
    final tickPaint = Paint()..strokeCap = StrokeCap.round;
    for (int i = 0; i < 60; i++) {
      final angle = (i * 6 - 90) * pi / 180;
      final isMajor = i % 5 == 0;
      final tickLength = isMajor ? 9.0 : 4.0;
      final isPast = (i / 60.0) <= progress;
      tickPaint
        ..strokeWidth = isMajor ? 2 : 1
        ..color = isPast
            ? accentColor.withValues(alpha: isMajor ? 0.95 : 0.6)
            : Colors.white.withValues(alpha: isMajor ? 0.28 : 0.1);

      final outer = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      final inner = Offset(
        center.dx + (radius - tickLength) * cos(angle),
        center.dy + (radius - tickLength) * sin(angle),
      );
      canvas.drawLine(inner, outer, tickPaint);
    }

    // Ponta luminosa do arco
    final tipAngle = sweep - pi / 2;
    final tip = Offset(
      center.dx + arcRadius * cos(tipAngle),
      center.dy + arcRadius * sin(tipAngle),
    );
    canvas.drawCircle(
      tip,
      9,
      Paint()..color = accentColor.withValues(alpha: 0.18),
    );
    canvas.drawCircle(tip, 5, Paint()..color = accentColor);
    canvas.drawCircle(
      tip,
      2,
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );
  }

  @override
  bool shouldRepaint(covariant _DialPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.accentColor != accentColor;
  }
}
