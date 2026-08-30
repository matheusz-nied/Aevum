import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:aevum/core/constants/app_colors.dart';
import 'package:aevum/core/quotes/inspiration_quotes.dart';
import 'package:aevum/core/utils/time_utils.dart';
import 'package:aevum/features/tasks/domain/task_model.dart';
import 'package:aevum/features/timer/domain/timer_state.dart';

class InspirationalView extends StatefulWidget {
  final TaskModel task;
  final TimerState state;
  final VoidCallback onTogglePlayPause;
  final VoidCallback onReset;
  final Function(int) onAddMinutes;

  const InspirationalView({
    super.key,
    required this.task,
    required this.state,
    required this.onTogglePlayPause,
    required this.onReset,
    required this.onAddMinutes,
  });

  @override
  State<InspirationalView> createState() => _InspirationalViewState();
}

class _InspirationalViewState extends State<InspirationalView> {
  late String _currentQuote;
  Timer? _quoteTimer;

  @override
  void initState() {
    super.initState();
    _currentQuote = InspirationQuotes.getRandomAffirmation(
      taskTitle: widget.task.title,
    );
    _startQuoteCycle();
  }

  void _startQuoteCycle() {
    _quoteTimer?.cancel();
    _quoteTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      if (mounted && widget.state.isRunning) {
        setState(() {
          _currentQuote = InspirationQuotes.getRandomAffirmation(
            taskTitle: widget.task.title,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _quoteTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.task.color;
    final displayTime = TimeUtils.formatSeconds(widget.state.remainingSeconds);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Badge superior em vidro
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accentColor.withValues(alpha: 0.35)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.task.iconData, size: 16, color: accentColor),
                  const SizedBox(width: 8),
                  Text(
                    widget.task.title,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Orbe central com glow
        Center(
          child: Container(
            width: 300,
            height: 300,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.glassLightOnly,
              border: Border.all(
                color: accentColor.withValues(alpha: 0.35),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(
                    alpha: widget.state.isRunning ? 0.28 : 0.12,
                  ),
                  blurRadius: 32,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.format_quote_rounded, color: accentColor, size: 32),
                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 700),
                  transitionBuilder: (child, anim) =>
                      FadeTransition(opacity: anim, child: child),
                  child: Text(
                    _currentQuote,
                    key: ValueKey(_currentQuote),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      color: AppColors.textWhite,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  displayTime,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Controles
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _GlassIconButton(
              icon: Icons.add,
              onPressed: () => widget.onAddMinutes(1),
            ),
            const SizedBox(width: 20),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.35),
                    blurRadius: 22,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: FloatingActionButton.large(
                onPressed: widget.onTogglePlayPause,
                backgroundColor: accentColor,
                foregroundColor: AppColors.forestDeep,
                elevation: 0,
                child: Icon(
                  widget.state.isRunning
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(width: 20),
            _GlassIconButton(
              icon: Icons.refresh_rounded,
              onPressed: widget.onReset,
            ),
          ],
        ),
      ],
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _GlassIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              child: Center(
                child: Icon(icon, color: AppColors.textWhite, size: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
