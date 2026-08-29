import 'package:flutter/material.dart';
import 'package:timing/core/constants/app_colors.dart';
import 'package:timing/core/services/haptic_service.dart';
import 'package:timing/core/widgets/glass_container.dart';

/// Ação principal da home em uma cápsula leve de liquid glass.
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
      child: AnimatedScale(
        scale: _isPressed ? 0.975 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: _isPressed ? 0.92 : 1,
          duration: const Duration(milliseconds: 120),
          child: GlassContainer(
            borderRadius: 30,
            blur: 24,
            accentColor: AppColors.sage,
            color: AppColors.sage.withValues(alpha: 0.14),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _handleTap,
                onTapDown: (_) => _setPressed(true),
                onTapUp: (_) => _setPressed(false),
                onTapCancel: () => _setPressed(false),
                borderRadius: BorderRadius.circular(30),
                splashColor: AppColors.sage.withValues(alpha: 0.12),
                highlightColor: Colors.white.withValues(alpha: 0.035),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 7, 18, 7),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.78),
                              AppColors.sage.withValues(alpha: 0.88),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.46),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.sage.withValues(alpha: 0.18),
                              blurRadius: 12,
                              spreadRadius: -3,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.icon,
                          color: AppColors.forestDeep,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Text(
                        widget.label,
                        style: const TextStyle(
                          color: AppColors.textWhite,
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
        ),
      ),
    );
  }
}
