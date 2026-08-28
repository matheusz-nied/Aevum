import 'package:flutter/material.dart';
import 'package:timing/core/constants/app_colors.dart';

/// Tema "Floresta Nebulosa" — somente modo escuro, com verdes profundos
/// calmantes e componentes premium para complementar o efeito glass.
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.sage,
        secondary: AppColors.emeraldMist,
        surface: AppColors.forestSurface,
        surfaceContainerHigh: AppColors.forestSurfaceElevated,
        onSurface: AppColors.textWhite,
        error: AppColors.warning,
      ),
      cardTheme: CardThemeData(
        color: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: AppColors.glassBorderDark,
            width: 1,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textWhite,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: AppColors.textWhite),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.sage,
        foregroundColor: AppColors.forestDeep,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        elevation: 4,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.textWhite,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
        ),
        headlineMedium: TextStyle(
          color: AppColors.textWhite,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          color: AppColors.textWhite,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textWhite,
          fontSize: 15,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textMuted,
          fontSize: 13,
        ),
      ),
    );
  }
}
