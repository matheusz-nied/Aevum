import 'package:flutter/material.dart';
import 'package:aevum/core/constants/app_colors.dart';

/// Tipografia do Aevum: Fraunces (serifa suave, orgânica) para títulos e
/// números de foco; Manrope para todo o texto de interface.
abstract final class AppTypography {
  static const String display = 'Fraunces';
  static const String body = 'Manrope';

  /// Estilo de título em Fraunces com o eixo SOFT no máximo, que arredonda as
  /// serifas e dá o tom sereno. Ajusta o eixo de tamanho óptico ao tamanho.
  static TextStyle serif({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textWhite,
    double? height,
    double? letterSpacing,
    FontStyle? fontStyle,
  }) {
    return TextStyle(
      fontFamily: display,
      fontSize: size,
      fontWeight: weight,
      fontStyle: fontStyle,
      color: color,
      height: height,
      letterSpacing: letterSpacing ?? -size * 0.02,
      fontVariations: [
        FontVariation.weight(weight.value.toDouble()),
        FontVariation('opsz', size.clamp(9, 144).toDouble()),
        const FontVariation('SOFT', 100),
        const FontVariation('WONK', 0),
      ],
    );
  }

  /// Rótulo pequeno em caixa-alta, espaçado, para "eyebrows" e seções.
  static const TextStyle eyebrow = TextStyle(
    fontFamily: body,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.6,
    color: AppColors.textMuted,
  );

  /// Números que mudam (timers, contagens) não devem "dançar" na largura.
  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];
}
