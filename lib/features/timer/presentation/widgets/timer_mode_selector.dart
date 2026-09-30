import 'package:flutter/material.dart';
import 'package:aevum/core/constants/app_colors.dart';
import 'package:aevum/core/services/haptic_service.dart';
import 'package:aevum/core/widgets/glass_container.dart';
import 'package:aevum/features/tasks/domain/timer_visual_mode.dart';

/// Seletor de modo do timer: cápsula de vidro com um indicador que desliza
/// até o modo escolhido e o nome do modo logo abaixo.
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

  static const double _itemWidth = 54;
  static const double _itemHeight = 44;

  @override
  Widget build(BuildContext context) {
    const modes = TimerVisualMode.values;
    final selectedIndex = modes.indexOf(currentMode);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GlassContainer(
          borderRadius: 99,
          blur: 20,
          accentColor: accentColor,
          padding: const EdgeInsets.all(4),
          child: SizedBox(
            width: _itemWidth * modes.length,
            height: _itemHeight,
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOutBack,
                  left: selectedIndex * _itemWidth,
                  top: 0,
                  width: _itemWidth,
                  height: _itemHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      color: accentColor.withValues(alpha: 0.18),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (final mode in modes)
                      _ModeItem(
                        mode: mode,
                        selected: mode == currentMode,
                        accentColor: accentColor,
                        width: _itemWidth,
                        onTap: () {
                          if (mode == currentMode) return;
                          HapticService.selectionClick();
                          onModeChanged(mode);
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: Text(
            currentMode.displayName,
            key: ValueKey(currentMode),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class _ModeItem extends StatelessWidget {
  final TimerVisualMode mode;
  final bool selected;
  final Color accentColor;
  final double width;
  final VoidCallback onTap;

  const _ModeItem({
    required this.mode,
    required this.selected,
    required this.accentColor,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: mode.displayName,
      child: Semantics(
        button: true,
        selected: selected,
        label: mode.displayName,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox(
            width: width,
            height: double.infinity,
            child: Center(
              child: TweenAnimationBuilder<Color?>(
                tween: ColorTween(
                  end: selected ? accentColor : AppColors.textMuted,
                ),
                duration: const Duration(milliseconds: 260),
                builder: (context, color, _) =>
                    Icon(mode.icon, size: 19, color: color),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
