import 'package:flutter/material.dart';
import 'package:aevum/core/constants/app_colors.dart';
import 'package:aevum/core/services/haptic_service.dart';
import 'package:aevum/core/widgets/glass_container.dart';

/// Botão de ícone circular em vidro, usado nas barras superiores.
class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color color;
  final double size;
  final double iconSize;

  const GlassIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color = AppColors.textWhite,
    this.size = 44,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      isCircle: true,
      blur: 14,
      child: SizedBox.square(
        dimension: size,
        child: IconButton(
          tooltip: tooltip,
          padding: EdgeInsets.zero,
          onPressed: () {
            HapticService.lightImpact();
            onPressed();
          },
          icon: Icon(icon, size: iconSize, color: color),
        ),
      ),
    );
  }
}
