import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:timing/core/services/haptic_service.dart';

/// Esfera do stash: um vórtice de vidro interativo com tempo monotônico.
///
/// O tempo não é reiniciado em ciclos. Em pausa, o movimento desacelera em vez
/// de congelar, preservando a sensação de um material ainda vivo.
class LiquidGlassSphere extends StatefulWidget {
  final bool isRunning;
  final double progress;
  final Color? accentColor;
  final double size;

  const LiquidGlassSphere({
    super.key,
    required this.isRunning,
    this.progress = 0,
    this.accentColor,
    this.size = 280,
  });

  @override
  State<LiquidGlassSphere> createState() => _LiquidGlassSphereState();
}

class _LiquidGlassSphereState extends State<LiquidGlassSphere>
    with TickerProviderStateMixin {
  late final Ticker _ticker;
  late final AnimationController _springController;

  double _continuousTime = 0;
  double _currentSpeed = 1;
  Duration _lastElapsed = Duration.zero;
  Offset _dragOffset = Offset.zero;
  Offset _springStartOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..addListener(_onSpringTick);
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (_lastElapsed == Duration.zero) {
      _lastElapsed = elapsed;
      return;
    }

    final deltaSeconds =
        (elapsed - _lastElapsed).inMicroseconds /
        Duration.microsecondsPerSecond;
    _lastElapsed = elapsed;
    final clampedDelta = deltaSeconds.clamp(0.0, 0.05);
    final targetSpeed = widget.isRunning ? 1.0 : 0.28;
    final speedBlend = 1 - math.exp(-4 * clampedDelta);

    _currentSpeed += (targetSpeed - _currentSpeed) * speedBlend;
    _continuousTime += clampedDelta * _currentSpeed;

    if (mounted) setState(() {});
  }

  void _onSpringTick() {
    final progress = Curves.easeOutBack.transform(_springController.value);
    setState(() {
      _dragOffset = Offset.lerp(_springStartOffset, Offset.zero, progress)!;
    });
  }

  void _onPanStart(DragStartDetails details) {
    _springController.stop();
    HapticService.selectionClick();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      final maxDrag = widget.size * 0.25;
      final candidate = _dragOffset + details.delta * 0.45;
      _dragOffset = candidate.distance > maxDrag
          ? Offset.fromDirection(candidate.direction, maxDrag)
          : candidate;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _springStartOffset = _dragOffset;
    _springController.forward(from: 0);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _springController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const ValueKey('interactiveLiquidSphere'),
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: SizedBox(
        width: widget.size,
        height: widget.size + 36,
        child: CustomPaint(
          size: Size(widget.size, widget.size + 36),
          painter: _ContinuousLiquidGlassPainter(
            time: _continuousTime,
            isRunning: widget.isRunning,
            progress: widget.progress,
            accentColor: widget.accentColor,
            dragOffset: _dragOffset,
          ),
        ),
      ),
    );
  }
}

class _ContinuousLiquidGlassPainter extends CustomPainter {
  final double time;
  final bool isRunning;
  final double progress;
  final Color? accentColor;
  final Offset dragOffset;

  const _ContinuousLiquidGlassPainter({
    required this.time,
    required this.isRunning,
    required this.progress,
    required this.accentColor,
    required this.dragOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final breathPulse = math.sin(time * 1.2);
    final breathScale = 0.98 + breathPulse * 0.035;
    final sphereCenter = Offset(
      size.width / 2 + dragOffset.dx * 0.45,
      size.height / 2 - 10 + dragOffset.dy * 0.45,
    );
    final sphereRadius = (size.width / 2 - 16) * breathScale;
    final sphereRect = Rect.fromCircle(
      center: sphereCenter,
      radius: sphereRadius,
    );

    _drawGroundReflection(canvas, sphereCenter, sphereRadius, breathScale);
    _drawOuterAura(canvas, sphereCenter, sphereRadius);

    canvas.save();
    canvas.clipPath(Path()..addOval(sphereRect));
    _drawSphereBase(canvas, sphereRect);
    _drawLiquidVortex(canvas, sphereRect, sphereCenter, sphereRadius);
    _drawSecondaryFluid(canvas, sphereRect, sphereCenter, sphereRadius);
    _drawCausticRibbons(canvas, sphereCenter, sphereRadius);
    _drawChromaticRim(canvas, sphereCenter, sphereRadius);
    _drawThicknessShadow(canvas, sphereRect);
    canvas.restore();

    _drawGlassShell(canvas, sphereRect, sphereCenter, sphereRadius);
  }

  void _drawGroundReflection(
    Canvas canvas,
    Offset center,
    double radius,
    double breathScale,
  ) {
    final groundRect = Rect.fromCenter(
      center: Offset(center.dx + dragOffset.dx * 0.15, center.dy + radius + 12),
      width: radius * 1.65,
      height: radius * 0.42,
    );
    canvas.drawOval(
      groundRect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFB7D2B7).withValues(alpha: 0.32 * breathScale),
            const Color(0xFF8FAC95).withValues(alpha: 0.20 * breathScale),
            const Color(0xFF536D5D).withValues(alpha: 0.10 * breathScale),
            Colors.transparent,
          ],
          stops: const [0, 0.35, 0.68, 1],
        ).createShader(groundRect),
    );
  }

  void _drawOuterAura(Canvas canvas, Offset center, double radius) {
    final auraRect = Rect.fromCircle(center: center, radius: radius * 1.24);
    canvas.drawCircle(
      center,
      radius * 1.24,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF718B70).withValues(alpha: 0.16),
            const Color(0xFF91AAA0).withValues(alpha: 0.07),
            Colors.transparent,
          ],
          stops: const [0.74, 0.90, 1],
        ).createShader(auraRect),
    );
  }

  void _drawSphereBase(Canvas canvas, Rect bounds) {
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.35, -0.35),
          radius: 1,
          colors: [Color(0xFF183025), Color(0xFF0B1712), Color(0xFF020806)],
          stops: [0, 0.58, 1],
        ).createShader(bounds),
    );
  }

  void _drawLiquidVortex(
    Canvas canvas,
    Rect bounds,
    Offset center,
    double radius,
  ) {
    const pointCount = 60;
    final points = <Offset>[];

    for (var index = 0; index < pointCount; index++) {
      final angle = index * 2 * math.pi / pointCount;
      final harmonicOne = math.sin(angle * 2 + time * 0.95) * 0.14;
      final harmonicTwo = math.cos(angle * 3 - time * 0.75) * 0.11;
      final harmonicThree = math.sin(angle + time * 0.45) * 0.13;
      final harmonicFour = math.cos(angle * 4 + time * 1.15) * 0.06;
      final vortexBias = math.sin(angle - 0.7 + time * 0.25) * 0.18;
      final radiusFactor =
          (0.73 +
                  harmonicOne +
                  harmonicTwo +
                  harmonicThree +
                  harmonicFour +
                  vortexBias)
              .clamp(0.22, 0.96);
      final localRadius = radius * radiusFactor;

      points.add(
        Offset(
          center.dx + localRadius * math.cos(angle) + dragOffset.dx * 0.35,
          center.dy + localRadius * math.sin(angle) + dragOffset.dy * 0.35,
        ),
      );
    }

    final wavePath = _smoothLoop(points);
    final rotation = time * 0.35;
    canvas.drawPath(
      wavePath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment(
            math.cos(rotation) * 0.85,
            math.sin(rotation) * 0.85,
          ),
          end: Alignment(
            -math.cos(rotation) * 0.85,
            -math.sin(rotation) * 0.85,
          ),
          colors: const [
            Color(0xFFB7D2B7),
            Color(0xFF8FAC95),
            Color(0xFF536D5D),
            Color(0xFF12251C),
          ],
          stops: const [0, 0.36, 0.70, 1],
        ).createShader(bounds),
    );
  }

  void _drawSecondaryFluid(
    Canvas canvas,
    Rect bounds,
    Offset center,
    double radius,
  ) {
    const pointCount = 44;
    final points = <Offset>[];

    for (var index = 0; index < pointCount; index++) {
      final angle = index * 2 * math.pi / pointCount;
      final waveOne = math.sin(angle * 3 - time * 0.65) * 0.13;
      final waveTwo = math.cos(angle * 2 + time * 0.85) * 0.09;
      final localRadius = radius * (0.46 + waveOne + waveTwo).clamp(0.16, 0.78);

      points.add(
        Offset(
          center.dx +
              radius * 0.10 * math.cos(time * 0.45) +
              localRadius * math.cos(angle) +
              dragOffset.dx * 0.2,
          center.dy +
              radius * 0.08 * math.sin(time * 0.45) +
              localRadius * math.sin(angle) +
              dragOffset.dy * 0.2,
        ),
      );
    }

    canvas.drawPath(
      _smoothLoop(points),
      Paint()
        ..shader = RadialGradient(
          center: Alignment(
            0.22 + 0.14 * math.sin(time * 0.6),
            -0.18 + 0.14 * math.cos(time * 0.6),
          ),
          radius: 0.75,
          colors: [
            const Color(0xFFC4D4C6).withValues(alpha: 0.60),
            const Color(0xFF718B70).withValues(alpha: 0.32),
            Colors.transparent,
          ],
          stops: const [0, 0.52, 1],
        ).createShader(bounds)
        ..blendMode = BlendMode.screen,
    );
  }

  void _drawCausticRibbons(Canvas canvas, Offset center, double radius) {
    final mainRibbon = Path()
      ..moveTo(
        center.dx - radius * 0.65 + math.sin(time * 0.6) * 12,
        center.dy - radius * 0.55 + math.cos(time * 0.6) * 10,
      )
      ..cubicTo(
        center.dx + radius * 0.38 + math.cos(time * 0.75) * 18,
        center.dy - radius * 0.35 + math.sin(time * 0.70) * 14,
        center.dx - radius * 0.48 + math.sin(time * 0.85) * 18,
        center.dy + radius * 0.40 + math.cos(time * 0.75) * 16,
        center.dx + radius * 0.66 + math.cos(time * 0.5) * 12,
        center.dy + radius * 0.46 + math.sin(time * 0.5) * 10,
      );
    final sphereBounds = Rect.fromCircle(center: center, radius: radius);
    final ribbonShader = const LinearGradient(
      colors: [Color(0xFFB7D2B7), Color(0xFF91AAA0), Color(0xFF718B70)],
    ).createShader(sphereBounds);

    canvas.drawPath(
      mainRibbon,
      Paint()
        ..shader = ribbonShader
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 8.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.5)
        ..blendMode = BlendMode.screen,
    );
    canvas.drawPath(
      mainRibbon,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFC6D6C6), Color(0xFF91AAA0), Color(0xFF718B70)],
        ).createShader(sphereBounds)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3,
    );
    canvas.drawPath(
      mainRibbon,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.82)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1,
    );

    final orbitRect = Rect.fromCenter(
      center: Offset(
        center.dx + math.sin(time * 0.45) * 7,
        center.dy + math.cos(time * 0.45) * 7,
      ),
      width: radius * 1.55,
      height: radius * 1.15,
    );

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.35 + math.sin(time * 0.35) * 0.10);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawOval(
      orbitRect,
      Paint()
        ..shader = SweepGradient(
          colors: [
            Colors.transparent,
            const Color(0xFF91AAA0).withValues(alpha: 0.60),
            const Color(0xFFA7B78F).withValues(alpha: 0.70),
            Colors.transparent,
          ],
          stops: const [0, 0.45, 0.70, 1],
          transform: GradientRotation(time * 0.65),
        ).createShader(orbitRect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.2)
        ..blendMode = BlendMode.screen,
    );
    canvas.restore();
  }

  void _drawChromaticRim(Canvas canvas, Offset center, double radius) {
    final rimRect = Rect.fromCircle(center: center, radius: radius - 3);
    canvas.drawCircle(
      center,
      radius - 3,
      Paint()
        ..shader = SweepGradient(
          colors: [
            Colors.transparent,
            const Color(0xFFA7B78F).withValues(alpha: 0.52),
            const Color(0xFF91AAA0).withValues(alpha: 0.68),
            const Color(0xFF61766A).withValues(alpha: 0.38),
            Colors.transparent,
          ],
          stops: const [0, 0.28, 0.48, 0.75, 1],
          transform: GradientRotation(
            math.pi * 0.35 + math.sin(time * 0.4) * 0.12,
          ),
        ).createShader(rimRect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.2)
        ..blendMode = BlendMode.screen,
    );
  }

  void _drawThicknessShadow(Canvas canvas, Rect bounds) {
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.15),
            Colors.black.withValues(alpha: 0.65),
          ],
          stops: const [0.72, 0.88, 1],
        ).createShader(bounds),
    );
  }

  void _drawGlassShell(
    Canvas canvas,
    Rect bounds,
    Offset center,
    double radius,
  ) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = SweepGradient(
          colors: [
            Colors.white.withValues(alpha: 0.92),
            const Color(0xFF91AAA0).withValues(alpha: 0.82),
            Colors.white.withValues(alpha: 0.25),
            const Color(0xFFA7B78F).withValues(alpha: 0.68),
            Colors.white.withValues(alpha: 0.78),
          ],
          stops: const [0, 0.30, 0.60, 0.82, 1],
          transform: GradientRotation(
            -math.pi * 0.25 + math.sin(time * 0.3) * 0.08,
          ),
        ).createShader(bounds)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final specularPath = Path();
    final specularRect = Rect.fromCircle(center: center, radius: radius - 4);
    const startAngle = -math.pi * 0.80;
    const sweepAngle = math.pi * 0.60;
    specularPath.addArc(specularRect, startAngle, sweepAngle);
    specularPath.arcTo(
      Rect.fromCenter(
        center: Offset(center.dx + radius * 0.12, center.dy + radius * 0.12),
        width: (radius - 18) * 2,
        height: (radius - 22) * 2,
      ),
      startAngle + sweepAngle,
      -sweepAngle,
      false,
    );
    specularPath.close();

    canvas.drawPath(
      specularPath,
      Paint()
        ..shader = LinearGradient(
          begin: const Alignment(-0.8, -0.9),
          end: const Alignment(0.4, 0.4),
          colors: [
            Colors.white.withValues(alpha: 0.88),
            const Color(0xFFC8D1CB).withValues(alpha: 0.65),
            const Color(0xFF91AAA0).withValues(alpha: 0.20),
            Colors.transparent,
          ],
          stops: const [0, 0.35, 0.70, 1],
        ).createShader(bounds),
    );

    final secondaryCenter = Offset(
      center.dx + radius * 0.52,
      center.dy + radius * 0.52,
    );
    final secondaryRect = Rect.fromCenter(
      center: secondaryCenter,
      width: radius * 0.38,
      height: radius * 0.15,
    );
    canvas.save();
    canvas.translate(secondaryCenter.dx, secondaryCenter.dy);
    canvas.rotate(math.pi * 0.25);
    canvas.translate(-secondaryCenter.dx, -secondaryCenter.dy);
    canvas.drawOval(
      secondaryRect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.68),
            const Color(0xFF91AAA0).withValues(alpha: 0.28),
            Colors.transparent,
          ],
          stops: const [0, 0.45, 1],
        ).createShader(secondaryRect),
    );
    canvas.restore();
  }

  Path _smoothLoop(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var index = 0; index < points.length; index++) {
      final current = points[index];
      final next = points[(index + 1) % points.length];
      final midpoint = Offset(
        (current.dx + next.dx) / 2,
        (current.dy + next.dy) / 2,
      );
      path.quadraticBezierTo(current.dx, current.dy, midpoint.dx, midpoint.dy);
    }
    return path..close();
  }

  @override
  bool shouldRepaint(covariant _ContinuousLiquidGlassPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.isRunning != isRunning ||
        oldDelegate.progress != progress ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.dragOffset != dragOffset;
  }
}
