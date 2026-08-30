import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:aevum/core/constants/app_colors.dart';
import 'package:aevum/features/tasks/domain/task_model.dart';
import 'package:aevum/features/timer/domain/timer_state.dart';

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
        // Dial circular em vidro (sem borda quadrada, sem timer digital)
        Center(
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 290,
                height: 290,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.glassLightOnly,
                  border: Border.all(
                    color: AppColors.glassBorderDark,
                    width: 1.5,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Painter do dial
                    CustomPaint(
                      size: const Size(280, 280),
                      painter: _DialPainter(
                        progress: state.progress,
                        accentColor: accentColor,
                      ),
                    ),

                    // Botão central de play/pause em vidro premium
                    GestureDetector(
                      onTap: onTogglePlayPause,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.forestSurfaceElevated.withValues(
                            alpha: 0.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.3),
                              blurRadius: 22,
                              spreadRadius: 2,
                            ),
                          ],
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.35),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            state.isRunning
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 42,
                            color: accentColor,
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

        // Ajustes rápidos
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Chip(icon: Icons.add, label: '+1m', onTap: () => onAddMinutes(1)),
            const SizedBox(width: 16),
            _Chip(icon: Icons.add, label: '+5m', onTap: () => onAddMinutes(5)),
            const SizedBox(width: 16),
            _Chip(
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

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _Chip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: AppColors.textWhite.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textWhite,
              ),
            ),
          ],
        ),
      ),
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
    final radius = size.width / 2 - 14;

    final tickPaint = Paint()..strokeCap = StrokeCap.round;

    final arcBackgroundPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final progressArcPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;

    // Track de fundo
    canvas.drawCircle(center, radius - 10, arcBackgroundPaint);

    // Arco de progresso
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 10),
      -pi / 2,
      2 * pi * progress,
      false,
      progressArcPaint,
    );

    // Ticks
    for (int i = 0; i < 60; i++) {
      final angle = (i * 6 - 90) * pi / 180;
      final isMajor = i % 5 == 0;
      final tickLength = isMajor ? 12.0 : 6.0;
      final tickThickness = isMajor ? 2.5 : 1.2;

      final isPast = (i / 60.0) <= progress;
      tickPaint.color = isPast
          ? accentColor
          : Colors.white.withValues(alpha: isMajor ? 0.35 : 0.12);
      tickPaint.strokeWidth = tickThickness;

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

    // Indicador circular
    final indicatorAngle = (progress * 360 - 90) * pi / 180;
    final indDistance = radius - 4;
    final indCenter = Offset(
      center.dx + indDistance * cos(indicatorAngle),
      center.dy + indDistance * sin(indicatorAngle),
    );

    final indicatorPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(indCenter, 4, indicatorPaint);
  }

  @override
  bool shouldRepaint(covariant _DialPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.accentColor != accentColor;
  }
}
