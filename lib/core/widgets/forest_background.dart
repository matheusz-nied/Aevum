import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:timing/core/constants/app_colors.dart';

/// Fundo procedural inspirado em uma floresta encoberta por névoa.
///
/// Nenhuma imagem é usada: profundidade, vinheta, névoa e pinheiros são
/// desenhados em tempo real com gradientes e formas vetoriais discretas.
class ForestBackground extends StatefulWidget {
  final Widget child;

  const ForestBackground({super.key, required this.child});

  @override
  State<ForestBackground> createState() => _ForestBackgroundState();
}

class _ForestBackgroundState extends State<ForestBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fogController;

  @override
  void initState() {
    super.initState();
    _fogController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _fogController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF18251F),
              AppColors.forestMid,
              AppColors.forestDeep,
              AppColors.forestBlack,
            ],
            stops: [0, 0.34, 0.72, 1],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              animation: _fogController,
              builder: (context, child) => CustomPaint(
                painter: _ForestAtmospherePainter(
                  progress: _fogController.value,
                ),
              ),
            ),
            widget.child,
          ],
        ),
      ),
    );
  }
}

class _ForestAtmospherePainter extends CustomPainter {
  final double progress;

  const _ForestAtmospherePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    _paintMist(canvas, size);
    _paintTreeLayer(
      canvas,
      size,
      baseline: size.height * 0.72,
      heightFactor: 0.20,
      color: AppColors.fogSilver.withValues(alpha: 0.035),
      spacing: 0.13,
      drift: progress * 5,
    );
    _paintTreeLayer(
      canvas,
      size,
      baseline: size.height * 0.91,
      heightFactor: 0.30,
      color: AppColors.forestSilhouette.withValues(alpha: 0.30),
      spacing: 0.19,
      drift: -progress * 3,
    );
    _paintEdgeTrees(canvas, size);
    _paintVignette(canvas, size);
  }

  void _paintMist(Canvas canvas, Size size) {
    final horizontalShift = (progress - 0.5) * size.width * 0.10;
    final center = Offset(
      size.width * 0.50 + horizontalShift,
      size.height * 0.20,
    );
    final mistPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              AppColors.fogSilver.withValues(alpha: 0.23),
              AppColors.fogGlow.withValues(alpha: 0.09),
              Colors.transparent,
            ],
            stops: const [0, 0.48, 1],
          ).createShader(
            Rect.fromCircle(center: center, radius: size.longestSide * 0.62),
          );
    canvas.drawRect(Offset.zero & size, mistPaint);

    final lowFog = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          AppColors.fogGlow2.withValues(alpha: 0.12),
          Colors.transparent,
        ],
        stops: const [0.15, 0.50, 0.88],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, lowFog);
  }

  void _paintTreeLayer(
    Canvas canvas,
    Size size, {
    required double baseline,
    required double heightFactor,
    required Color color,
    required double spacing,
    required double drift,
  }) {
    final paint = Paint()..color = color;
    final count = (1 / spacing).ceil() + 2;
    for (var index = -1; index < count; index++) {
      final x = index * size.width * spacing + drift;
      final variation = 0.78 + ((index.abs() * 17) % 7) / 20;
      _drawPine(
        canvas,
        Offset(x, baseline),
        size.height * heightFactor * variation,
        paint,
      );
    }
  }

  void _paintEdgeTrees(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.forestBlack.withValues(alpha: 0.52);
    _drawPine(
      canvas,
      Offset(size.width * 0.02, size.height * 0.80),
      size.height * 0.56,
      paint,
    );
    _drawPine(
      canvas,
      Offset(size.width * 0.98, size.height * 0.78),
      size.height * 0.62,
      paint,
    );
    _drawPine(
      canvas,
      Offset(size.width * 0.13, size.height),
      size.height * 0.38,
      paint,
    );
    _drawPine(
      canvas,
      Offset(size.width * 0.88, size.height),
      size.height * 0.42,
      paint,
    );
  }

  void _drawPine(Canvas canvas, Offset base, double height, Paint paint) {
    final trunkWidth = math.max(1.0, height * 0.018);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          base.dx - trunkWidth / 2,
          base.dy - height * 0.78,
          trunkWidth,
          height * 0.78,
        ),
        const Radius.circular(2),
      ),
      paint,
    );

    for (var tier = 0; tier < 7; tier++) {
      final tierTop = base.dy - height + (height * tier * 0.105);
      final tierHeight = height * (0.24 + tier * 0.012);
      final halfWidth = height * (0.07 + tier * 0.020);
      final path = Path()
        ..moveTo(base.dx, tierTop)
        ..lineTo(base.dx - halfWidth, tierTop + tierHeight)
        ..quadraticBezierTo(
          base.dx,
          tierTop + tierHeight * 0.88,
          base.dx + halfWidth,
          tierTop + tierHeight,
        )
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  void _paintVignette(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.34);
    final paint = Paint()
      ..shader =
          RadialGradient(
            center: const Alignment(0, -0.15),
            radius: 0.88,
            colors: [
              Colors.transparent,
              AppColors.forestBlack.withValues(alpha: 0.18),
              AppColors.forestBlack.withValues(alpha: 0.66),
            ],
            stops: const [0.40, 0.72, 1],
          ).createShader(
            Rect.fromCircle(center: center, radius: size.longestSide * 0.72),
          );
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _ForestAtmospherePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
