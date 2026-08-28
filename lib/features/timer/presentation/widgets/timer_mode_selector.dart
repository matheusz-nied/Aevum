import 'package:flutter/material.dart';
import 'package:timing/core/constants/app_colors.dart';
import 'package:timing/core/widgets/glass_container.dart';
import 'package:timing/features/tasks/domain/timer_visual_mode.dart';

/// Seletor de modo do timer com chips calmos e flutuantes.
class TimerModeSelector extends StatelessWidget {
  final TimerVisualMode currentMode;
  final ValueChanged<TimerVisualMode> onModeChanged;
  final Color accentColor;

  const TimerModeSelector({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 24,
      blur: 16,
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: TimerVisualMode.values.map((mode) {
          final isSelected = mode == currentMode;

          return Tooltip(
            message: mode.displayName,
            child: Semantics(
              button: true,
              selected: isSelected,
              label: mode.displayName,
              child: GestureDetector(
                onTap: () => onModeChanged(mode),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? accentColor.withValues(alpha: 0.14)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.forestBlack.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    mode.icon,
                    size: 18,
                    color: isSelected ? accentColor : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
