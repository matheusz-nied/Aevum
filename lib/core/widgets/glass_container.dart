import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:aevum/core/constants/app_colors.dart';
import 'package:aevum/core/widgets/adaptive_backdrop_filter.dart';

/// Superfície de vidro fosco compartilhada por cards, cápsulas e botões.
///
/// Acabamento leve: preenchimento translúcido com um véu de luz no topo,
/// borda de 1px que só brilha onde a luz bate e uma sombra ambiente difusa.
class GlassContainer extends StatelessWidget {
  final Widget child;

  /// Borda arredondada (aplicada quando não é círculo).
  final double? borderRadius;

  /// Se true, usa uma forma circular.
  final bool isCircle;

  final double blur;

  /// Tint opcional misturado ao vidro.
  final Color? color;

  /// Cor usada nos reflexos sutis da borda.
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
    final radius = isCircle ? 999.0 : (borderRadius ?? 24.0);
    final borderRadiusValue = BorderRadius.circular(radius);
    final tint = accentColor ?? AppColors.emeraldMist;
    final baseColor =
        color ??
        (strong ? AppColors.liquidGlassStrong : AppColors.liquidGlassSurface);
    final shape = isCircle ? BoxShape.circle : BoxShape.rectangle;

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: isCircle ? null : borderRadiusValue,
        boxShadow: [
          BoxShadow(
            color: AppColors.forestBlack.withValues(alpha: strong ? 0.32 : 0.2),
            blurRadius: strong ? 32 : 20,
            spreadRadius: -8,
            offset: Offset(0, strong ? 14 : 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadiusValue,
        child: AdaptiveBackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: strong ? blur + 4 : blur,
            sigmaY: strong ? blur + 4 : blur,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: shape,
              borderRadius: isCircle ? null : borderRadiusValue,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.alphaBlend(
                    Colors.white.withValues(alpha: strong ? 0.06 : 0.04),
                    baseColor,
                  ),
                  Color.alphaBlend(tint.withValues(alpha: 0.02), baseColor),
                ],
              ),
            ),
            position: DecorationPosition.background,
            child: CustomPaint(
              foregroundPainter: _GlassBorderPainter(
                radius: radius,
                isCircle: isCircle,
                accentColor: tint,
                strong: strong,
              ),
              child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
            ),
          ),
        ),
      ),
    );
  }
}

/// Borda de 1px: mais clara no topo (onde a luz bate) e quase invisível embaixo.
class _GlassBorderPainter extends CustomPainter {
  final double radius;
  final bool isCircle;
  final Color accentColor;
  final bool strong;

  const _GlassBorderPainter({
    required this.radius,
    required this.isCircle,
    required this.accentColor,
    required this.strong,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    const strokeWidth = 1.0;
    final rect = Offset.zero & size;
    final insetRect = rect.deflate(strokeWidth / 2);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: strong ? 0.17 : 0.13),
          Color.alphaBlend(
            accentColor.withValues(alpha: 0.05),
            Colors.white.withValues(alpha: 0.05),
          ),
          Colors.white.withValues(alpha: 0.03),
        ],
        stops: const [0, 0.45, 1],
      ).createShader(rect);

    if (isCircle) {
      canvas.drawOval(insetRect, borderPaint);
    } else {
      final cornerRadius = (radius - strokeWidth / 2).clamp(
        0.0,
        double.infinity,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(insetRect, Radius.circular(cornerRadius)),
        borderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GlassBorderPainter oldDelegate) =>
      oldDelegate.radius != radius ||
      oldDelegate.isCircle != isCircle ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.strong != strong;
}
