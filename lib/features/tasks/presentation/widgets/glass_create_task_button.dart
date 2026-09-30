import 'package:flutter/material.dart';
import 'package:aevum/core/constants/app_colors.dart';
import 'package:aevum/core/services/haptic_service.dart';
import 'package:aevum/core/widgets/glass_container.dart';

/// Criar hábito é uma ação secundária: uma cápsula de vidro discreta, para
/// não convidar o usuário a acumular hábitos em vez de cuidar dos que tem.
class GlassCreateTaskButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;

  const GlassCreateTaskButton({
    super.key,
    required this.onPressed,
    this.label = 'Novo hábito',
    this.icon = Icons.add_rounded,
  });

  @override
  State<GlassCreateTaskButton> createState() => _GlassCreateTaskButtonState();
}

class _GlassCreateTaskButtonState extends State<GlassCreateTaskButton> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
  }

  void _handleTap() {
    HapticService.lightImpact();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: _handleTap,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        child: AnimatedScale(
          scale: _isPressed ? 0.96 : 1,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: GlassContainer(
            borderRadius: 99,
            blur: 24,
            accentColor: AppColors.sage,
            color: AppColors.forestSurface.withValues(alpha: 0.38),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 18, 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.06),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Icon(
                      widget.icon,
                      color: AppColors.sage.withValues(alpha: 0.9),
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: AppColors.textWhite.withValues(alpha: 0.82),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
