import 'package:flutter/material.dart';

/// Paleta "Floresta Nebulosa".
///
/// Tons derivados de uma floresta úmida ao amanhecer: sombras quase pretas,
/// verdes pinho dessaturados e névoa prata.
class AppColors {
  // Base: o preto nunca é neutro; ele sempre carrega um pouco de pinho.
  static const Color forestBlack = Color(0xFF020806);
  static const Color forestDeep = Color(0xFF06100C);
  static const Color forestMid = Color(0xFF0C1913);
  static const Color forestSurface = Color(0xFF13211A);
  static const Color forestSurfaceElevated = Color(0xFF1A2B22);
  static const Color forestSurfaceCard = Color(0xFF15251D);

  // Névoa/glow de fundo (usado no ForestBackground)
  static const Color fogSilver = Color(0xFF93A199);
  static const Color fogGlow = Color(0xFF61766A);
  static const Color fogGlow2 = Color(0xFF31483B);
  static const Color forestSilhouette = Color(0xFF0A1711);

  // Acentos verdes calmantes
  static const Color sage = Color(0xFFBAC9B5);
  static const Color emeraldMist = Color(0xFF8FAC95);
  static const Color mossCalm = Color(0xFF718B70);
  static const Color eucalyptus = Color(0xFF91AAA0);
  static const Color pineDeep = Color(0xFF536D5D);
  static const Color lichen = Color(0xFFA7B78F);

  // Paleta de cores por tarefa (tons de verde calmantes)
  static const List<Color> taskColors = [
    emeraldMist,
    sage,
    mossCalm,
    eucalyptus,
    pineDeep,
    lichen,
  ];

  // Liquid glass: a superfície preserva o cenário atrás do componente.
  static Color get liquidGlassSurface => forestSurface.withValues(alpha: 0.26);
  static Color get liquidGlassStrong => forestSurface.withValues(alpha: 0.36);
  static Color get glassDark => forestSurface.withValues(alpha: 0.46);
  static Color get glassBorderDark => Colors.white.withValues(alpha: 0.24);
  static Color get glassBorderSoft => Colors.white.withValues(alpha: 0.11);
  static Color get glassLightOnly => Colors.white.withValues(alpha: 0.075);
  static Color get glassHighlight => Colors.white.withValues(alpha: 0.18);

  // Texto
  static const Color textWhite = Color(0xFFEFF3F0);
  static const Color textMuted = Color(0xFFA4B0A9);
  static const Color textFaint = Color(0xFF74827A);

  // Secundárias (para destaques pontuais calmos)
  static const Color softGlowEmerald = Color(0xFFB7D2B7);
  static const Color warning = Color(0xFFD09B72);
}
