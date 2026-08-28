import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:timing/core/constants/app_colors.dart';
import 'package:timing/features/tasks/domain/task_model.dart';
import 'package:timing/features/timer/domain/timer_state.dart';

/// Um timer sem contagem visível, representado por um orbe de vidro líquido.
///
/// A animação é deliberadamente lenta: o orbe muda de forma, e reflexos e
/// caústicas deslizam em velocidades diferentes para evitar um loop mecânico.
class AnxietyFreeView extends StatefulWidget {
  final TaskModel task;
  final TimerState state;
  final VoidCallback onTogglePlayPause;
  final VoidCallback onReset;

  const AnxietyFreeView({
    super.key,
    required this.task,
    required this.state,
    required this.onTogglePlayPause,
    required this.onReset,
  });

  @override
  State<AnxietyFreeView> createState() => _AnxietyFreeViewState();
}

class _AnxietyFreeViewState extends State<AnxietyFreeView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _liquidController;

  @override
  void initState() {
    super.initState();
    _liquidController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
  }

  @override
  void dispose() {
    _liquidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 570;
        final availableWidth = math.max(220.0, constraints.maxWidth - 28);
        final availableHeight = math.max(
          220.0,
          constraints.maxHeight * (compact ? 0.58 : 0.62),
        );
        final orbSize = math.min(
          compact ? 300.0 : 356.0,
          math.min(availableWidth, availableHeight),
        );

        return RepaintBoundary(
          child: Column(
            children: [
              SizedBox(height: compact ? 4 : 14),
              _CalmHeader(
                isRunning: widget.state.isRunning,
                isPaused: widget.state.isPaused,
              ),
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _liquidController,
                    builder: (context, child) {
                      return CustomPaint(
                        key: const ValueKey('liquidGlassOrb'),
                        size: Size.square(orbSize),
                        painter: _LiquidGlassPainter(
                          phase: _liquidController.value,
                          accentColor: widget.task.color,
                          isPaused: widget.state.isPaused,
                        ),
                      );
                    },
                  ),
                ),
              ),
              _QuietControls(
                isRunning: widget.state.isRunning,
                onTogglePlayPause: widget.onTogglePlayPause,
                onReset: widget.onReset,
              ),
              SizedBox(height: compact ? 8 : 18),
            ],
          ),
        );
      },
    );
  }
}

class _CalmHeader extends StatelessWidget {
  final bool isRunning;
  final bool isPaused;

  const _CalmHeader({required this.isRunning, required this.isPaused});

  @override
  Widget build(BuildContext context) {
    final label = isRunning
        ? 'O TEMPO SEGUE SOZINHO'
        : isPaused
        ? 'PAUSA SUAVE'
        : 'SEM PRESSA';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Text(
        label,
        key: ValueKey(label),
        style: TextStyle(
          color: AppColors.textMuted.withValues(alpha: 0.64),
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.8,
        ),
      ),
    );
  }
}

class _QuietControls extends StatelessWidget {
  final bool isRunning;
  final VoidCallback onTogglePlayPause;
  final VoidCallback onReset;

  const _QuietControls({
    required this.isRunning,
    required this.onTogglePlayPause,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final actionLabel = isRunning ? 'Pausar' : 'Continuar';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          label: actionLabel,
          child: Tooltip(
            message: actionLabel,
            child: InkResponse(
              onTap: onTogglePlayPause,
              radius: 34,
              containedInkWell: true,
              customBorder: const CircleBorder(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF07100F).withValues(alpha: 0.72),
                  border: Border.all(
                    color: Colors.white.withValues(
                      alpha: isRunning ? 0.09 : 0.15,
                    ),
                  ),
                ),
                child: Icon(
                  isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 25,
                  color: Colors.white.withValues(
                    alpha: isRunning ? 0.48 : 0.68,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        TextButton(
          onPressed: onReset,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textMuted.withValues(alpha: 0.48),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            minimumSize: const Size(44, 36),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'recomeçar',
            style: TextStyle(fontSize: 11, letterSpacing: 0.6),
          ),
        ),
      ],
    );
  }
}

class _LiquidGlassPainter extends CustomPainter {
  final double phase;
  final Color accentColor;
  final bool isPaused;

  const _LiquidGlassPainter({
    required this.phase,
    required this.accentColor,
    required this.isPaused,
  });

  double get _time => phase * math.pi * 2;

  @override
  void paint(Canvas canvas, Size size) {
    final shortestSide = math.min(size.width, size.height);
    final center = Offset(
      size.width / 2 + math.sin(_time) * shortestSide * 0.008,
      size.height / 2 + math.cos(_time * 2 + 0.7) * shortestSide * 0.01,
    );
    final radius = shortestSide * 0.385;
    final orbPath = _organicCircle(center, radius, _time);
    final bounds = Rect.fromCircle(center: center, radius: radius * 1.04);

    _paintAmbientLight(canvas, center, radius);
    _paintOrbShadow(canvas, orbPath, radius);

    final basePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.36, -0.48),
        radius: 1.12,
        colors: [
          const Color(0xFFD7E0D9).withValues(alpha: 0.22),
          const Color(0xFF61766A).withValues(alpha: 0.30),
          const Color(0xFF0B1A13).withValues(alpha: 0.98),
          const Color(0xFF020806),
        ],
        stops: const [0, 0.24, 0.67, 1],
      ).createShader(bounds);
    canvas.drawPath(orbPath, basePaint);

    canvas.save();
    canvas.clipPath(orbPath);
    _paintInnerVolume(canvas, center, radius, bounds);
    _paintLiquidFolds(canvas, center, radius, bounds);
    _paintCaustics(canvas, center, radius);
    _paintSpecularGlass(canvas, center, radius, bounds);
    canvas.restore();

    _paintGlassRim(canvas, orbPath, bounds, radius);
  }

  void _paintAmbientLight(Canvas canvas, Offset center, double radius) {
    final glowCenter = center.translate(
      math.sin(_time + 0.9) * radius * 0.13,
      radius * 0.75,
    );
    final glowRect = Rect.fromCenter(
      center: glowCenter,
      width: radius * 2.45,
      height: radius * 1.2,
    );
    final glowColor = Color.lerp(const Color(0xFF718B70), accentColor, 0.36)!;
    canvas.drawOval(
      glowRect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            glowColor.withValues(alpha: isPaused ? 0.08 : 0.15),
            const Color(0xFF61766A).withValues(alpha: 0.05),
            Colors.transparent,
          ],
          stops: const [0, 0.48, 1],
        ).createShader(glowRect)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.13),
    );
  }

  void _paintOrbShadow(Canvas canvas, Path orbPath, double radius) {
    canvas.save();
    canvas.translate(0, radius * 0.1);
    canvas.drawPath(
      orbPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.68)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.16),
    );
    canvas.restore();

    canvas.drawPath(
      orbPath,
      Paint()
        ..color = const Color(0xFF718B70)
            .withValues(alpha: isPaused ? 0.07 : 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.055
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.09),
    );
  }

  void _paintInnerVolume(
    Canvas canvas,
    Offset center,
    double radius,
    Rect bounds,
  ) {
    final drift = math.sin(_time * 2 + 0.35);
    final innerRect = Rect.fromCenter(
      center: center.translate(radius * (0.10 + drift * 0.035), radius * 0.05),
      width: radius * 1.42,
      height: radius * 1.58,
    );
    canvas.drawOval(
      innerRect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.22, -0.2),
          colors: [
            const Color(0xFF536D5D).withValues(alpha: 0.42),
            const Color(0xFF07120D).withValues(alpha: 0.76),
            Colors.black.withValues(alpha: 0.80),
          ],
          stops: const [0, 0.62, 1],
        ).createShader(innerRect),
    );

    final topLightRect = Rect.fromCircle(
      center: center.translate(-radius * 0.35, -radius * 0.48),
      radius: radius * 0.78,
    );
    canvas.drawCircle(
      topLightRect.center,
      topLightRect.width / 2,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF91AAA0).withValues(alpha: 0.24),
            const Color(0xFF536D5D).withValues(alpha: 0.08),
            Colors.transparent,
          ],
          stops: const [0, 0.46, 1],
        ).createShader(topLightRect)
        ..blendMode = BlendMode.screen,
    );

    final lowerDepth = Rect.fromCenter(
      center: center.translate(radius * 0.05, radius * 0.72),
      width: radius * 2.0,
      height: radius * 1.1,
    );
    canvas.drawOval(
      lowerDepth,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF08150F).withValues(alpha: 0.08),
            Colors.black.withValues(alpha: 0.72),
          ],
        ).createShader(lowerDepth),
    );

    canvas.drawRect(
      bounds,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.05, 0.05),
          radius: 0.92,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.58)],
          stops: const [0.54, 1],
        ).createShader(bounds),
    );
  }

  void _paintLiquidFolds(
    Canvas canvas,
    Offset center,
    double radius,
    Rect bounds,
  ) {
    final wave = math.sin(_time);
    final slowWave = math.cos(_time * 2 + 0.5);
    final cyan = Color.lerp(const Color(0xFF91AAA0), accentColor, 0.22)!;
    final violet = Color.lerp(const Color(0xFF61766A), accentColor, 0.12)!;

    final upperFold = Path()
      ..moveTo(center.dx - radius * 1.04, center.dy - radius * 0.16)
      ..cubicTo(
        center.dx - radius * (0.45 + wave * 0.06),
        center.dy - radius * (0.82 - slowWave * 0.05),
        center.dx + radius * (0.23 + slowWave * 0.11),
        center.dy - radius * (0.64 + wave * 0.08),
        center.dx + radius * 1.08,
        center.dy - radius * (0.10 + slowWave * 0.08),
      )
      ..cubicTo(
        center.dx + radius * 0.55,
        center.dy - radius * (0.12 - wave * 0.1),
        center.dx - radius * (0.25 - slowWave * 0.08),
        center.dy + radius * (0.12 + wave * 0.06),
        center.dx - radius * 1.04,
        center.dy - radius * 0.16,
      )
      ..close();
    canvas.drawPath(
      upperFold,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFC8D1CB).withValues(alpha: 0.30),
            violet.withValues(alpha: 0.38),
            const Color(0xFF081A12).withValues(alpha: 0.08),
          ],
          stops: const [0, 0.48, 1],
        ).createShader(bounds)
        ..blendMode = BlendMode.screen,
    );

    final mainFold = Path()
      ..moveTo(center.dx - radius * 1.08, center.dy + radius * 0.20)
      ..cubicTo(
        center.dx - radius * 0.48,
        center.dy - radius * (0.12 + wave * 0.13),
        center.dx + radius * (0.11 + slowWave * 0.08),
        center.dy + radius * (0.62 + wave * 0.04),
        center.dx + radius * 1.10,
        center.dy - radius * (0.16 - slowWave * 0.08),
      )
      ..cubicTo(
        center.dx + radius * 0.55,
        center.dy + radius * (0.69 - wave * 0.07),
        center.dx - radius * 0.42,
        center.dy + radius * (0.70 + slowWave * 0.04),
        center.dx - radius * 1.08,
        center.dy + radius * 0.20,
      )
      ..close();
    canvas.drawPath(
      mainFold,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.transparent,
            cyan.withValues(alpha: 0.14),
            const Color(0xFF718B70).withValues(alpha: 0.48),
            violet.withValues(alpha: 0.26),
            Colors.transparent,
          ],
          stops: const [0, 0.2, 0.53, 0.78, 1],
        ).createShader(bounds)
        ..blendMode = BlendMode.screen
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.018),
    );

    final lowerFold = Path()
      ..moveTo(center.dx - radius, center.dy + radius * 0.38)
      ..cubicTo(
        center.dx - radius * 0.34,
        center.dy + radius * (0.84 + wave * 0.04),
        center.dx + radius * 0.30,
        center.dy + radius * (0.52 - slowWave * 0.09),
        center.dx + radius,
        center.dy + radius * 0.14,
      )
      ..cubicTo(
        center.dx + radius * 0.50,
        center.dy + radius * (0.82 + slowWave * 0.06),
        center.dx - radius * 0.42,
        center.dy + radius * (0.98 - wave * 0.04),
        center.dx - radius,
        center.dy + radius * 0.38,
      )
      ..close();
    canvas.drawPath(
      lowerFold,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            const Color(0xFF61766A).withValues(alpha: 0.30),
            cyan.withValues(alpha: 0.28),
            Colors.transparent,
          ],
        ).createShader(bounds)
        ..blendMode = BlendMode.screen,
    );
  }

  void _paintCaustics(Canvas canvas, Offset center, double radius) {
    final cyan = Color.lerp(const Color(0xFF91AAA0), accentColor, 0.28)!;
    final causticPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(1.0, radius * 0.014)
      ..color = cyan.withValues(alpha: isPaused ? 0.22 : 0.48)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.009)
      ..blendMode = BlendMode.screen;

    final sweep = math.sin(_time * 2 + 1.1);
    final strandOne = Path()
      ..moveTo(center.dx - radius * 0.88, center.dy + radius * 0.16)
      ..cubicTo(
        center.dx - radius * 0.36,
        center.dy - radius * (0.54 + sweep * 0.08),
        center.dx + radius * 0.31,
        center.dy - radius * (0.42 - sweep * 0.08),
        center.dx + radius * 0.88,
        center.dy + radius * 0.04,
      );
    canvas.drawPath(strandOne, causticPaint);

    final strandTwo = Path()
      ..moveTo(center.dx - radius * 0.73, center.dy + radius * 0.58)
      ..cubicTo(
        center.dx - radius * 0.16,
        center.dy + radius * (0.88 - sweep * 0.04),
        center.dx + radius * 0.42,
        center.dy + radius * (0.65 + sweep * 0.07),
        center.dx + radius * 0.78,
        center.dy + radius * 0.23,
      );
    canvas.drawPath(
      strandTwo,
      causticPaint
        ..strokeWidth = math.max(0.8, radius * 0.009)
        ..color = const Color(0xFF718B70).withValues(alpha: 0.42),
    );

    final filament = Path()
      ..moveTo(center.dx - radius * 0.50, center.dy - radius * 0.72)
      ..cubicTo(
        center.dx - radius * 0.14,
        center.dy - radius * (0.28 - sweep * 0.09),
        center.dx + radius * 0.50,
        center.dy - radius * 0.06,
        center.dx + radius * 0.65,
        center.dy + radius * 0.46,
      );
    canvas.drawPath(
      filament,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = math.max(0.7, radius * 0.007)
        ..color = accentColor.withValues(alpha: 0.44)
        ..blendMode = BlendMode.screen,
    );
  }

  void _paintSpecularGlass(
    Canvas canvas,
    Offset center,
    double radius,
    Rect bounds,
  ) {
    final shimmer = 0.82 + math.sin(_time + 1.7) * 0.12;
    final highlight = Path()
      ..moveTo(center.dx - radius * 0.70, center.dy - radius * 0.30)
      ..cubicTo(
        center.dx - radius * 0.55,
        center.dy - radius * 0.78,
        center.dx - radius * 0.14,
        center.dy - radius * 0.92,
        center.dx + radius * 0.12,
        center.dy - radius * 0.78,
      )
      ..cubicTo(
        center.dx - radius * 0.17,
        center.dy - radius * 0.67,
        center.dx - radius * 0.37,
        center.dy - radius * 0.37,
        center.dx - radius * 0.70,
        center.dy - radius * 0.30,
      )
      ..close();
    canvas.drawPath(
      highlight,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.34 * shimmer),
            const Color(0xFFAFC2B8).withValues(alpha: 0.14),
            Colors.transparent,
          ],
        ).createShader(bounds)
        ..blendMode = BlendMode.screen
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.025),
    );

    final sharpHighlight = Path()
      ..moveTo(center.dx - radius * 0.68, center.dy - radius * 0.48)
      ..cubicTo(
        center.dx - radius * 0.47,
        center.dy - radius * 0.83,
        center.dx - radius * 0.14,
        center.dy - radius * 0.91,
        center.dx + radius * 0.14,
        center.dy - radius * 0.78,
      );
    canvas.drawPath(
      sharpHighlight,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.52 * shimmer)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.0, radius * 0.012)
        ..strokeCap = StrokeCap.round
        ..blendMode = BlendMode.screen,
    );
  }

  void _paintGlassRim(Canvas canvas, Path orbPath, Rect bounds, double radius) {
    final rimShader = SweepGradient(
      transform: GradientRotation(math.sin(_time) * 0.22),
      colors: [
        Colors.white.withValues(alpha: 0.52),
        const Color(0xFF91AAA0).withValues(alpha: 0.56),
        const Color(0xFF536D5D).withValues(alpha: 0.18),
        Colors.white.withValues(alpha: 0.07),
        accentColor.withValues(alpha: 0.43),
        Colors.white.withValues(alpha: 0.52),
      ],
      stops: const [0, 0.16, 0.34, 0.56, 0.79, 1],
    ).createShader(bounds);

    canvas.drawPath(
      orbPath,
      Paint()
        ..shader = rimShader
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.2, radius * 0.018)
        ..blendMode = BlendMode.screen,
    );

    final metrics = orbPath.computeMetrics().toList(growable: false);
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    final brightRim = Paint()
      ..color = Colors.white.withValues(alpha: 0.58)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.1, radius * 0.012)
      ..strokeCap = StrokeCap.round
      ..blendMode = BlendMode.screen;
    canvas.drawPath(
      metric.extractPath(metric.length * 0.01, metric.length * 0.18),
      brightRim,
    );
    canvas.drawPath(
      metric.extractPath(metric.length * 0.47, metric.length * 0.57),
      brightRim..color = const Color(0xFFB7D2B7).withValues(alpha: 0.42),
    );
  }

  Path _organicCircle(Offset center, double radius, double time) {
    const pointCount = 48;
    final points = <Offset>[];

    for (var index = 0; index < pointCount; index++) {
      final angle = -math.pi / 2 + index * math.pi * 2 / pointCount;
      final deformation =
          math.sin(angle * 3 + time) * 0.026 +
          math.sin(angle * 5 - time * 2 + 0.7) * 0.014 +
          math.sin(angle * 2 + time * 3 + 1.1) * 0.009;
      final localRadius = radius * (1 + deformation);
      points.add(
        Offset(
          center.dx + math.cos(angle) * localRadius,
          center.dy + math.sin(angle) * localRadius,
        ),
      );
    }

    return _smoothClosedPath(points);
  }

  Path _smoothClosedPath(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (var index = 0; index < points.length; index++) {
      final previous = points[(index - 1 + points.length) % points.length];
      final current = points[index];
      final next = points[(index + 1) % points.length];
      final afterNext = points[(index + 2) % points.length];
      final controlOne = current + (next - previous) / 6;
      final controlTwo = next - (afterNext - current) / 6;

      path.cubicTo(
        controlOne.dx,
        controlOne.dy,
        controlTwo.dx,
        controlTwo.dy,
        next.dx,
        next.dy,
      );
    }

    return path..close();
  }

  @override
  bool shouldRepaint(covariant _LiquidGlassPainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.isPaused != isPaused;
  }
}
