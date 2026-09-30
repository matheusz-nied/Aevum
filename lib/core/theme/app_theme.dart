import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aevum/core/constants/app_colors.dart';
import 'package:aevum/core/theme/app_typography.dart';

/// Tema "Floresta ao Amanhecer" — somente modo escuro, com verdes profundos
/// calmantes, tipografia serena e componentes leves para o efeito glass.
class AppTheme {
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.sage,
      brightness: Brightness.dark,
      primary: AppColors.sage,
      secondary: AppColors.emeraldMist,
      tertiary: AppColors.dawn,
      surface: AppColors.forestSurface,
      error: AppColors.warning,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppTypography.body,
      scaffoldBackgroundColor: AppColors.forestDeep,
      colorScheme: colorScheme.copyWith(
        surface: AppColors.forestSurface,
        surfaceContainerHigh: AppColors.forestSurfaceElevated,
        onSurface: AppColors.textWhite,
      ),
      splashColor: AppColors.sage.withValues(alpha: 0.08),
      highlightColor: AppColors.sage.withValues(alpha: 0.05),
      dividerColor: AppColors.glassBorderSoft,
      dividerTheme: DividerThemeData(
        color: AppColors.glassBorderSoft,
        thickness: 1,
        space: 1,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(
            backgroundColor: AppColors.forestDeep,
          ),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      cardTheme: CardThemeData(
        color: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppColors.glassBorderSoft, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.serif(size: 24, weight: FontWeight.w500),
        iconTheme: const IconThemeData(color: AppColors.textWhite),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.sage,
        foregroundColor: AppColors.forestDeep,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 4,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.forestSurface,
        surfaceTintColor: Colors.transparent,
        barrierColor: AppColors.forestBlack.withValues(alpha: 0.62),
        titleTextStyle: AppTypography.serif(size: 24, weight: FontWeight.w500),
        contentTextStyle: const TextStyle(
          fontFamily: AppTypography.body,
          color: AppColors.textMuted,
          fontSize: 15,
          height: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(color: AppColors.glassBorderSoft),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.forestSurfaceElevated,
        elevation: 0,
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        contentTextStyle: const TextStyle(
          fontFamily: AppTypography.body,
          color: AppColors.textWhite,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: AppColors.dawn,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: AppColors.glassBorderSoft),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.forestSurfaceElevated.withValues(alpha: 0.98),
        surfaceTintColor: Colors.transparent,
        elevation: 12,
        textStyle: const TextStyle(
          fontFamily: AppTypography.body,
          color: AppColors.textWhite,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: AppColors.glassBorderSoft),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.forestSurfaceElevated,
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(
          fontFamily: AppTypography.body,
          color: AppColors.textWhite,
          fontSize: 12,
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.sage,
        titleTextStyle: TextStyle(
          fontFamily: AppTypography.body,
          color: AppColors.textWhite,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: AppTypography.body,
          color: AppColors.textMuted,
          fontSize: 13,
          height: 1.35,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.05),
        side: BorderSide(color: AppColors.glassBorderSoft),
        labelStyle: const TextStyle(
          fontFamily: AppTypography.body,
          color: AppColors.textWhite,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.glassLightOnly,
        hintStyle: const TextStyle(color: AppColors.textFaint),
        labelStyle: const TextStyle(color: AppColors.textMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.glassBorderSoft),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.glassBorderSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.sage, width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sage,
          foregroundColor: AppColors.forestDeep,
          disabledBackgroundColor: AppColors.sage.withValues(alpha: 0.4),
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily: AppTypography.body,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: -0.1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: const TextStyle(
            fontFamily: AppTypography.body,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.sage,
          textStyle: const TextStyle(
            fontFamily: AppTypography.body,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: AppTypography.serif(
          size: 36,
          weight: FontWeight.w400,
          height: 1.1,
        ),
        headlineMedium: AppTypography.serif(size: 28, weight: FontWeight.w400),
        titleLarge: const TextStyle(
          color: AppColors.textWhite,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: const TextStyle(color: AppColors.textWhite, fontSize: 15),
        bodyMedium: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 13,
          height: 1.4,
        ),
      ),
    );
  }
}
