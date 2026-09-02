import 'dart:ui';

import 'package:aevum/core/config/app_performance_policy.dart';
import 'package:flutter/widgets.dart';

/// Aplica blur real nos targets que o processam bem e usa o conteúdo já
/// translúcido como fallback no Android.
class AdaptiveBackdropFilter extends StatelessWidget {
  const AdaptiveBackdropFilter({
    super.key,
    required this.filter,
    required this.child,
  });

  final ImageFilter filter;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!AppPerformancePolicy.useBackdropBlur) return child;
    return BackdropFilter(filter: filter, child: child);
  }
}
