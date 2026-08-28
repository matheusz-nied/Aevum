import 'dart:math';
import 'package:flutter/material.dart';
import 'package:timing/core/constants/app_colors.dart';
import 'package:timing/core/utils/time_utils.dart';
import 'package:timing/features/tasks/domain/task_model.dart';
import 'package:timing/features/timer/domain/timer_state.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = task.color;

    final displayTime = TimeUtils.formatSeconds(state.remainingSeconds);
    final targetTime = TimeUtils.formatSeconds(state.targetSeconds);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Digital Time Display at top (Ref 1)
        Column(
          children: [
            Text(
              displayTime,
              style: TextStyle(
                color: accentColor,
                fontSize: 52,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.5,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Meta: $targetTime',
              style: TextStyle(
                color: isDark ? AppColors.textMuted : Colors.black45,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        // Analog Circular Dial with Center Knob (Ref 1)
        Center(
          child: SizedBox(
            width: 290,
            height: 290,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Dial with graduation ticks
                CustomPaint(
                  size: const Size(290, 290),
                  painter: _DialPainter(
                    progress: state.progress,
                    accentColor: accentColor,
                    isDark: isDark,
                  ),
                ),

                // Center Neumorphic Knob Button (Ref 1)
                GestureDetector(
                  onTap: onTogglePlayPause,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 105,
                    height: 105,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? const Color(0xFF181C23)
                          : const Color(0xFFE8ECF2),
                      boxShadow: isDark
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.7),
                                offset: const Offset(4, 4),
                                blurRadius: 10,
                              ),
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.05),
                                offset: const Offset(-4, -4),
                                blurRadius: 10,
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                offset: const Offset(5, 5),
                                blurRadius: 10,
                              ),
                              const BoxShadow(
                                color: Colors.white,
                                offset: Offset(-5, -5),
                                blurRadius: 10,
                              ),
                            ],
                    ),
                    child: Center(
                      child: Icon(
                        state.isRunning
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 44,
                        color: state.isRunning
                            ? accentColor
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Quick adjust buttons (Ref 1)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _QuickActionButton(
              label: '+1m',
              icon: Icons.add,
              isDark: isDark,
              onTap: () => onAddMinutes(1),
            ),
            const SizedBox(width: 16),
            _QuickActionButton(
              label: '+5m',
              icon: Icons.add,
              isDark: isDark,
              onTap: () => onAddMinutes(5),
            ),
            const SizedBox(width: 16),
            _QuickActionButton(
              label: 'Reiniciar',
              icon: Icons.refresh_rounded,
              isDark: isDark,
              onTap: onReset,
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1F26) : const Color(0xFFEFF2F6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isDark ? Colors.white70 : Colors.black87),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
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
  final bool isDark;

  _DialPainter({
    required this.progress,
    required this.accentColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 14;

    final tickPaint = Paint()..strokeCap = StrokeCap.round;

    final arcBackgroundPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final progressArcPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;

    // Draw background circle track
    canvas.drawCircle(center, radius - 10, arcBackgroundPaint);

    // Draw progress arc
    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 10),
      -pi / 2,
      sweepAngle,
      false,
      progressArcPaint,
    );

    // Draw 60 graduation ticks
    for (int i = 0; i < 60; i++) {
      final angle = (i * 6 - 90) * pi / 180;
      final isMajor = i % 5 == 0;
      final tickLength = isMajor ? 12.0 : 6.0;
      final tickThickness = isMajor ? 2.5 : 1.2;

      final isPast = (i / 60.0) <= progress;
      tickPaint.color = isPast
          ? accentColor
          : (isDark
              ? Colors.white.withValues(alpha: isMajor ? 0.4 : 0.15)
              : Colors.black.withValues(alpha: isMajor ? 0.35 : 0.1));
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

      // Draw numbers for major intervals (0, 5, 10, 15... 55)
      if (isMajor) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '$i',
            style: TextStyle(
              color: isPast
                  ? accentColor
                  : (isDark ? AppColors.textMuted : Colors.black54),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final textRadius = radius - 24;
        final textOffset = Offset(
          center.dx + textRadius * cos(angle) - textPainter.width / 2,
          center.dy + textRadius * sin(angle) - textPainter.height / 2,
        );
        textPainter.paint(canvas, textOffset);
      }
    }

    // Draw current indicator dot
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
        oldDelegate.accentColor != accentColor ||
        oldDelegate.isDark != isDark;
  }
}
