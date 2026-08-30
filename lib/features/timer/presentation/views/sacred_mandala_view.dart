import 'dart:math';

import 'package:flutter/material.dart';
import 'package:aevum/core/constants/app_colors.dart';
import 'package:aevum/features/tasks/domain/task_model.dart';
import 'package:aevum/features/timer/domain/timer_state.dart';

class SacredMandalaView extends StatefulWidget {
  final TaskModel task;
  final TimerState state;
  final VoidCallback onTogglePlayPause;
  final VoidCallback onReset;
  final Function(int) onAddMinutes;

  const SacredMandalaView({
    super.key,
    required this.task,
    required this.state,
    required this.onTogglePlayPause,
    required this.onReset,
    required this.onAddMinutes,
  });

  @override
  State<SacredMandalaView> createState() => _SacredMandalaViewState();
}

class _SacredMandalaViewState extends State<SacredMandalaView>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant SacredMandalaView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.isRunning && !_breathingController.isAnimating) {
      _breathingController.repeat(reverse: true);
    } else if (!widget.state.isRunning && _breathingController.isAnimating) {
      _breathingController.stop();
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.task.color == AppColors.sage
        ? AppColors.emeraldMist
        : widget.task.color;

    return AnimatedBuilder(
      animation: _breathingController,
      builder: (context, child) {
        final breathScale = 0.94 + (_breathingController.value * 0.12);
        final rotation = _breathingController.value * 0.15;

        return Column(
          children: [
            // Frase-guia no topo (sem timer digital)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                widget.state.isRunning
                    ? 'Respire no ritmo da luz'
                    : 'Pronto para focar',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
            ),

            // Mandala centralizada verticalmente no espaço restante
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 290,
                  height: 290,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Aura
                      Container(
                        width: 270 * breathScale,
                        height: 270 * breathScale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withValues(
                                alpha: widget.state.isRunning ? 0.28 : 0.12,
                              ),
                              blurRadius: 36,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                      ),

                      CustomPaint(
                        size: const Size(290, 290),
                        painter: _MandalaPainter(
                          breathScale: breathScale,
                          rotation: rotation,
                          progress: widget.state.progress,
                          accentColor: accentColor,
                        ),
                      ),

                      // Play/Pause central
                      GestureDetector(
                        onTap: widget.onTogglePlayPause,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.10),
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            widget.state.isRunning
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: accentColor,
                            size: 36,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Botões
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _MandalaButton(
                    label: '+1 min',
                    accentColor: accentColor,
                    onTap: () => widget.onAddMinutes(1),
                  ),
                  const SizedBox(width: 20),
                  _MandalaButton(
                    label: 'Reiniciar',
                    accentColor: accentColor,
                    onTap: widget.onReset,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MandalaButton extends StatelessWidget {
  final String label;
  final Color accentColor;
  final VoidCallback onTap;

  const _MandalaButton({
    required this.label,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.textWhite,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _MandalaPainter extends CustomPainter {
  final double breathScale;
  final double rotation;
  final double progress;
  final Color accentColor;

  _MandalaPainter({
    required this.breathScale,
    required this.rotation,
    required this.progress,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = (size.width / 2 - 20) * breathScale;

    final petalPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final nodePaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    final progressTrackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final progressArcPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;

    // Track de progresso
    canvas.drawCircle(center, size.width / 2 - 10, progressTrackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width / 2 - 10),
      -pi / 2,
      2 * pi * progress,
      false,
      progressArcPaint,
    );

    const int petalCount = 8;
    final double radius = baseRadius * 0.65;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    canvas.drawCircle(Offset.zero, radius * 0.5, petalPaint);

    for (int i = 0; i < petalCount; i++) {
      final angle = (i * 2 * pi) / petalCount;
      final petalCenter = Offset(
        radius * 0.5 * cos(angle),
        radius * 0.5 * sin(angle),
      );

      canvas.drawCircle(petalCenter, radius * 0.5, petalPaint);

      final outerPoint = Offset(radius * cos(angle), radius * sin(angle));
      canvas.drawCircle(outerPoint, 3.5, nodePaint);
      canvas.drawCircle(
        outerPoint,
        6,
        Paint()
          ..color = accentColor.withValues(alpha: 0.25)
          ..style = PaintingStyle.fill,
      );
    }

    canvas.drawCircle(Offset.zero, radius, petalPaint..strokeWidth = 1.0);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MandalaPainter oldDelegate) {
    return oldDelegate.breathScale != breathScale ||
        oldDelegate.rotation != rotation ||
        oldDelegate.progress != progress ||
        oldDelegate.accentColor != accentColor;
  }
}
