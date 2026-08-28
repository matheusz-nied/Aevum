import 'dart:async';
import 'package:flutter/material.dart';
import 'package:timing/core/constants/app_colors.dart';
import 'package:timing/core/quotes/inspiration_quotes.dart';
import 'package:timing/core/utils/time_utils.dart';
import 'package:timing/features/tasks/domain/task_model.dart';
import 'package:timing/features/timer/domain/timer_state.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = widget.task.color;

    final displayTime =
        TimeUtils.formatSeconds(widget.state.remainingSeconds);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Top Task Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.task.iconData, size: 16, color: accentColor),
              const SizedBox(width: 8),
              Text(
                widget.task.title,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Central Affirmation Card with Circular Glow (Ref 2 & 5)
        Center(
          child: Container(
            width: 300,
            height: 300,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppColors.darkSurfaceCard : Colors.white,
              border: Border.all(
                color: accentColor.withValues(alpha: 0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(
                    alpha: widget.state.isRunning ? 0.25 : 0.1,
                  ),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.format_quote_rounded,
                  color: accentColor,
                  size: 32,
                ),
                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 700),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: child,
                  ),
                  child: Text(
                    _currentQuote,
                    key: ValueKey(_currentQuote),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      color: isDark ? AppColors.textWhite : AppColors.textDark,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  displayTime,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filled(
              onPressed: () => widget.onAddMinutes(1),
              style: IconButton.styleFrom(
                backgroundColor: isDark
                    ? const Color(0xFF1E232B)
                    : const Color(0xFFEFF2F5),
                foregroundColor: isDark ? Colors.white : Colors.black87,
                padding: const EdgeInsets.all(14),
              ),
              icon: const Icon(Icons.add, size: 20),
            ),
            const SizedBox(width: 20),
            FloatingActionButton.large(
              onPressed: widget.onTogglePlayPause,
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              elevation: 4,
              child: Icon(
                widget.state.isRunning
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                size: 40,
              ),
            ),
            const SizedBox(width: 20),
            IconButton.filled(
              onPressed: widget.onReset,
              style: IconButton.styleFrom(
                backgroundColor: isDark
                    ? const Color(0xFF1E232B)
                    : const Color(0xFFEFF2F5),
                foregroundColor: isDark ? Colors.white : Colors.black87,
                padding: const EdgeInsets.all(14),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 20),
            ),
          ],
        ),
      ],
    );
  }
}
