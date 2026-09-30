import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:aevum/core/constants/app_colors.dart';
import 'package:aevum/core/widgets/adaptive_backdrop_filter.dart';

/// Superfície moderna de vidro fosco (glassmorphism) compartilhada por cards, cápsulas e botões.
///
/// Apresenta acabamento translúcido equilibrado, alta legibilidade de texto,
/// sombra ambiente difusa e borda contínua com gradiente de luz sutil.
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

  /// Usa um vidro ligeiramente mais denso e estruturado para painéis de maior hierarquia.
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

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : borderRadiusValue,
        boxShadow: [
          // Sombra ambiente suave e profunda
          BoxShadow(
            color: Colors.black.withValues(alpha: strong ? 0.36 : 0.24),
            blurRadius: strong ? 28 : 18,
            spreadRadius: -4,
            offset: Offset(0, strong ? 10 : 6),
          ),
          // Aura cromática muito sutil no tom da cor de destaque
          BoxShadow(
            color: tint.withValues(alpha: strong ? 0.05 : 0.025),
            blurRadius: 18,
            spreadRadius: -3,
            offset: const Offset(0, 3),
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
          child: Stack(
            children: [
              // Fundo com textura e gradiente de vidro translúcido suave
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
                    borderRadius: isCircle ? null : borderRadiusValue,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: const [0.0, 0.35, 0.70, 1.0],
                      colors: [
                        Color.alphaBlend(
                          Colors.white.withValues(alpha: strong ? 0.08 : 0.045),
                          baseColor,
                        ),
                        baseColor,
                        Color.alphaBlend(
                          tint.withValues(alpha: strong ? 0.03 : 0.015),
                          baseColor,
                        ),
                        Color.alphaBlend(
                          AppColors.forestBlack.withValues(
                            alpha: strong ? 0.14 : 0.08,
                          ),
                          baseColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Sheen suave de topo em gradiente contínuo (sem cortes artificiais)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
                    borderRadius: isCircle ? null : borderRadiusValue,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.38, 1.0],
                      colors: [
                        Colors.white.withValues(alpha: strong ? 0.035 : 0.02),
                        Colors.white.withValues(alpha: 0.005),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Conteúdo do componente
              Padding(padding: padding ?? EdgeInsets.zero, child: child),

              // Borda refinada contínua de 1px com gradiente de luz
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _ModernGlassBorderPainter(
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

/// Pinta uma borda única, fina (1px) e contínua com gradiente luminoso suave.
class _ModernGlassBorderPainter extends CustomPainter {
  final double radius;
  final bool isCircle;
  final Color accentColor;
  final bool strong;

  const _ModernGlassBorderPainter({
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
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: const [0.0, 0.35, 0.70, 1.0],
        colors: [
          Colors.white.withValues(alpha: strong ? 0.22 : 0.15),
          Colors.white.withValues(alpha: strong ? 0.08 : 0.05),
          accentColor.withValues(alpha: strong ? 0.12 : 0.07),
          Colors.white.withValues(alpha: strong ? 0.05 : 0.03),
        ],
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
  bool shouldRepaint(covariant _ModernGlassBorderPainter oldDelegate) =>
      oldDelegate.radius != radius ||
      oldDelegate.isCircle != isCircle ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.strong != strong;
}
