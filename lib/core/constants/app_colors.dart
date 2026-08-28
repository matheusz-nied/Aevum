import 'package:flutter/material.dart';

/// Paleta "Floresta Nebulosa" — verdes profundos, calmos e suaves.
/// Inspirada em florestas de pinheiros com névoa matinal.
class AppColors {
  // A base da floresta: quase preto com toque de verde
  static const Color forestDeep = Color(0xFF060C0A);
  static const Color forestMid = Color(0xFF0D1712);
  static const Color forestSurface = Color(0xFF152019);
  static const Color forestSurfaceElevated = Color(0xFF1B2A21);
  static const Color forestSurfaceCard = Color(0xFF18251E);

  // Névoa/glow de fundo (usado no ForestBackground)
  static const Color fogGlow = Color(0xFF274535);
  static const Color fogGlow2 = Color(0xFF182C20);

  // Acentos verdes calmantes
  static const Color sage = Color(0xFF9DC5B0); // verde-sálvia suave (primário)
  static const Color emeraldMist = Color(0xFF6FBF8E); // esmeralda médio
  static const Color mossCalm = Color(0xFF4E8F6E); // musgo calmo
  static const Color eucalyptus = Color(0xFF7FAE9B); // eucalipto dessaturado
  static const Color pineDeep = Color(0xFF3A6150); // pinheiro profundo

  // Paleta de cores por tarefa (tons de verde calmantes)
  static const List<Color> taskColors = [
    emeraldMist,
    sage,
    mossCalm,
    eucalyptus,
    pineDeep,
  ];

  // Glassmorphism: overlays suaves de vidro
  static Color glassDark = const Color(0xFF18251E).withValues(alpha: 0.55);
  static Color glassBorderDark = Colors.white.withValues(alpha: 0.14);
  static Color glassLightOnly = Colors.white.withValues(alpha: 0.07);
  static Color glassHighlight = Colors.white.withValues(alpha: 0.10);

  // Texto
  static const Color textWhite = Color(0xFFF2F7F4); // branco esverdeado suave
  static const Color textMuted = Color(0xFF8EA39B); // cinza-esverdeado quebrado

  // Secundárias (para destaques pontuais calmos)
  static const Color softGlowEmerald = Color(0xFF88D4A9);
  static const Color warning =
      Color(0xFFC98A4D); // brunâmato suave para avisos (em vez de vermelho)
}
