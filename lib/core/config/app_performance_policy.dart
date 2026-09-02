import 'package:flutter/foundation.dart';

/// Centraliza os ajustes visuais necessários para manter frame times estáveis
/// em GPUs Android, sem reduzir a fidelidade dos demais targets.
abstract final class AppPerformancePolicy {
  static bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static bool get useBackdropBlur => !isAndroid;
  static bool get animateForestAtmosphere => !isAndroid;
  static bool get usePainterBlur => !isAndroid;

  /// Mantém animações ambientais em aproximadamente 30 fps no Android.
  static double animationValue(double value, {required int steps}) {
    if (!isAndroid) return value;
    return (value * steps).floor() / steps;
  }
}
