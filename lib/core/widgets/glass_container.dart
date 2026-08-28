import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:timing/core/constants/app_colors.dart';

/// Container estilo "vidro" (glassmorphism) — blur de fundo,
/// borda suave e highlight sutil. Usado em cards, cápsulas e chips.
class GlassContainer extends StatelessWidget {
  final Widget child;

  /// Borda arredondada (aplicada quando não é círculo).
  final double? borderRadius;

  /// Se true, forma circular (igual de orbes e ícones).
  final bool isCircle;

  final double blur;

  /// Tint base do vidro (por padrão usa [AppColors.glassLightOnly]).
  final Color? color;

  /// Padding interno da cápsula.
  final EdgeInsetsGeometry? padding;

  /// Usa um vidro mais denso para painéis de maior hierarquia.
  final bool strong;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius,
    this.isCircle = false,
    this.blur = 10,
    this.color,
    this.padding,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadiusValue = BorderRadius.circular(
      isCircle ? 999 : (borderRadius ?? 20),
    );

    final effectiveColor =
        color ??
        (strong
            ? AppColors.forestSurface.withValues(alpha: 0.50)
            : AppColors.glassLightOnly);

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : borderRadiusValue,
        boxShadow: [
          BoxShadow(
            color: AppColors.forestBlack.withValues(
              alpha: strong ? 0.42 : 0.24,
            ),
            blurRadius: strong ? 28 : 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadiusValue,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.alphaBlend(AppColors.glassHighlight, effectiveColor),
                  effectiveColor,
                  AppColors.forestDeep.withValues(alpha: strong ? 0.48 : 0.18),
                ],
                stops: const [0, 0.42, 1],
              ),
              shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: isCircle ? null : borderRadiusValue,
              border: Border.all(color: AppColors.glassBorderDark, width: 0.8),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
