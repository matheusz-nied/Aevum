import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:aevum/core/constants/app_colors.dart';
import 'package:aevum/core/config/app_performance_policy.dart';
import 'package:aevum/core/widgets/adaptive_backdrop_filter.dart';

/// Superfície de liquid glass compartilhada por cards, cápsulas e botões.
///
/// O efeito combina o conteúdo desfocado atrás do widget com uma camada de
/// vidro translúcida, reflexos direcionais e duas bordas finas. Assim o vidro
/// continua legível em fundos claros ou escuros sem parecer uma placa opaca.
class GlassContainer extends StatelessWidget {
  final Widget child;

  /// Borda arredondada (aplicada quando não é círculo).
  final double? borderRadius;

  /// Se true, usa uma forma circular.
  final bool isCircle;

  final double blur;

  /// Tint opcional misturado ao vidro.
  final Color? color;

  /// Cor usada nos reflexos da borda, sem tingir todo o conteúdo.
  final Color? accentColor;

  /// Padding interno da cápsula.
  final EdgeInsetsGeometry? padding;

  /// Usa um vidro ligeiramente mais denso para painéis de maior hierarquia.
  final bool strong;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius,
    this.isCircle = false,
    this.blur = 18,
    this.color,
    this.accentColor,
    this.padding,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    final isAndroid = AppPerformancePolicy.isAndroid;
    final radius = isCircle ? 999.0 : (borderRadius ?? 24);
    final borderRadiusValue = BorderRadius.circular(radius);
    final tint = accentColor ?? AppColors.emeraldMist;
    final baseColor =
        color ??
        (strong ? AppColors.liquidGlassStrong : AppColors.liquidGlassSurface);

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : borderRadiusValue,
        boxShadow: [
          BoxShadow(
            color: AppColors.forestBlack.withValues(
              alpha: strong ? 0.48 : 0.34,
            ),
            blurRadius: isAndroid ? (strong ? 18 : 14) : (strong ? 34 : 24),
            spreadRadius: -7,
            offset: Offset(0, strong ? 18 : 13),
          ),
          BoxShadow(
            color: tint.withValues(alpha: strong ? 0.09 : 0.055),
            blurRadius: isAndroid ? (strong ? 14 : 10) : (strong ? 26 : 18),
            spreadRadius: -9,
            offset: const Offset(5, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadiusValue,
        child: AdaptiveBackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: strong ? blur + 5 : blur,
            sigmaY: strong ? blur + 5 : blur,
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
                    borderRadius: isCircle ? null : borderRadiusValue,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: const [0, 0.27, 0.62, 1],
                      colors: [
                        Color.alphaBlend(
                          Colors.white.withValues(alpha: strong ? 0.12 : 0.16),
                          baseColor,
                        ),
                        Color.alphaBlend(
                          tint.withValues(alpha: strong ? 0.045 : 0.03),
                          baseColor,
                        ),
                        baseColor,
                        Color.alphaBlend(
                          AppColors.forestDeep.withValues(
                            alpha: strong ? 0.18 : 0.08,
                          ),
                          baseColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: _LiquidGlassGlowPainter(
                    radius: radius,
                    isCircle: isCircle,
                    accentColor: tint,
                    strong: strong,
                  ),
                ),
              ),
              Padding(padding: padding ?? EdgeInsets.zero, child: child),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _LiquidGlassEdgePainter(
                      radius: radius,
                      isCircle: isCircle,
                      accentColor: tint,
                      strong: strong,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiquidGlassGlowPainter extends CustomPainter {
  final double radius;
  final bool isCircle;
  final Color accentColor;
  final bool strong;

  const _LiquidGlassGlowPainter({
    required this.radius,
    required this.isCircle,
    required this.accentColor,
    required this.strong,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final shape = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.save();
    canvas.clipRRect(shape);

    final topGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.82, -1.05),
        radius: 1.02,
        colors: [
          Colors.white.withValues(alpha: strong ? 0.18 : 0.22),
          Colors.white.withValues(alpha: 0.045),
          Colors.transparent,
        ],
        stops: const [0, 0.36, 1],
      ).createShader(rect);
    canvas.drawRect(rect, topGlow);

    final colorRefraction = Paint()
      ..shader = RadialGradient(
        center: const Alignment(1.12, 0.92),
        radius: 0.92,
        colors: [
          accentColor.withValues(alpha: strong ? 0.12 : 0.09),
          accentColor.withValues(alpha: 0.025),
          Colors.transparent,
        ],
        stops: const [0, 0.44, 1],
      ).createShader(rect);
    canvas.drawRect(rect, colorRefraction);

    final lowerShade = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          AppColors.forestBlack.withValues(alpha: strong ? 0.10 : 0.055),
        ],
        stops: const [0.46, 1],
      ).createShader(rect);
    canvas.drawRect(rect, lowerShade);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LiquidGlassGlowPainter oldDelegate) =>
      oldDelegate.radius != radius ||
      oldDelegate.isCircle != isCircle ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.strong != strong;
}

class _LiquidGlassEdgePainter extends CustomPainter {
  final double radius;
  final bool isCircle;
  final Color accentColor;
  final bool strong;

  const _LiquidGlassEdgePainter({
    required this.radius,
    required this.isCircle,
    required this.accentColor,
    required this.strong,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final outerRect = rect.deflate(0.7);
    final innerRect = rect.deflate(2.25);

    final outer = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strong ? 1.45 : 1.2
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: strong ? 0.62 : 0.52),
          Colors.white.withValues(alpha: 0.16),
          accentColor.withValues(alpha: strong ? 0.24 : 0.16),
          Colors.white.withValues(alpha: 0.25),
        ],
        stops: const [0, 0.31, 0.72, 1],
      ).createShader(rect);

    final inner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..color = Colors.white.withValues(alpha: strong ? 0.12 : 0.09);

    if (isCircle) {
      canvas.drawOval(outerRect, outer);
      canvas.drawOval(innerRect, inner);
      canvas.drawArc(
        innerRect,
        3.65,
        1.55,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 1.7
          ..color = Colors.white.withValues(alpha: 0.34),
      );
      return;
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(outerRect, Radius.circular(radius - 0.7)),
      outer,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        innerRect,
        Radius.circular((radius - 2.25).clamp(0, radius)),
      ),
      inner,
    );

    if (size.width > radius * 2.4) {
      final highlight = Path()
        ..moveTo(3, radius)
        ..quadraticBezierTo(3, 4, radius, 3)
        ..lineTo(size.width * 0.42, 3);
      canvas.drawPath(
        highlight,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = strong ? 1.5 : 1.25
          ..shader = LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.08),
              Colors.white.withValues(alpha: strong ? 0.40 : 0.32),
              Colors.transparent,
            ],
          ).createShader(rect),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LiquidGlassEdgePainter oldDelegate) =>
      oldDelegate.radius != radius ||
      oldDelegate.isCircle != isCircle ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.strong != strong;
}
