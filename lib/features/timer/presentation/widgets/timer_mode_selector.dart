import 'package:flutter/material.dart';
import 'package:timing/features/tasks/domain/timer_visual_mode.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161A20) : const Color(0xFFE9ECEF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: TimerVisualMode.values.map((mode) {
          final isSelected = mode == currentMode;

          return GestureDetector(
            onTap: () => onModeChanged(mode),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? const Color(0xFF222834) : Colors.white)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.3 : 0.08,
                          ),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    mode.icon,
                    size: 16,
                    color: isSelected
                        ? accentColor
                        : (isDark ? Colors.white54 : Colors.black45),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 6),
                    Text(
                      mode.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
