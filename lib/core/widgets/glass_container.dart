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

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius,
    this.isCircle = false,
    this.blur = 10,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadiusValue = BorderRadius.circular(
      isCircle ? 999 : (borderRadius ?? 20),
    );

    return ClipRRect(
      borderRadius: borderRadiusValue,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? AppColors.glassLightOnly,
            shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isCircle ? null : borderRadiusValue,
            border: Border.all(
              color: AppColors.glassBorderDark,
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
