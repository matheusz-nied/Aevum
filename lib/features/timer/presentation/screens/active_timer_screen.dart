import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timing/core/constants/app_colors.dart';
import 'package:timing/core/services/haptic_service.dart';
import 'package:timing/features/tasks/domain/task_model.dart';
import 'package:timing/features/tasks/domain/timer_visual_mode.dart';
import 'package:timing/features/tasks/providers/task_providers.dart';
import 'package:timing/features/timer/domain/timer_state.dart';
import 'package:timing/features/timer/presentation/views/anxiety_free_view.dart';
import 'package:timing/features/timer/presentation/views/inspirational_view.dart';
import 'package:timing/features/timer/presentation/views/minimal_dial_view.dart';
import 'package:timing/features/timer/presentation/views/sacred_mandala_view.dart';
import 'package:timing/features/timer/presentation/widgets/completion_dialog.dart';
import 'package:timing/features/timer/presentation/widgets/timer_mode_selector.dart';
import 'package:timing/features/timer/providers/timer_controller.dart';

class ActiveTimerScreen extends ConsumerStatefulWidget {
  final TaskModel task;

  const ActiveTimerScreen({
    super.key,
    required this.task,
  });

  @override
  ConsumerState<ActiveTimerScreen> createState() => _ActiveTimerScreenState();
}

class _ActiveTimerScreenState extends ConsumerState<ActiveTimerScreen> {
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(timerControllerProvider.notifier).start(widget.task);
    });
  }

  void _showCompletionDialog(BuildContext context, TimerState state) {
    if (_dialogShown) return;
    _dialogShown = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CompletionDialog(
        task: widget.task,
        durationSeconds: state.elapsedSeconds > 0
            ? state.elapsedSeconds
            : widget.task.targetMinutes * 60,
        onConfirm: (session) {
          ref.read(sessionListProvider.notifier).recordSession(session);
          Navigator.of(context).pop(); // Exit timer screen back to home
        },
      ),
    ).then((_) {
      _dialogShown = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerControllerProvider);
    final timerNotifier = ref.read(timerControllerProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = widget.task.color;

    // Listen for timer auto-completion
    ref.listen<TimerState>(timerControllerProvider, (prev, next) {
      if (next.status == TimerStatus.completed && !_dialogShown) {
        _showCompletionDialog(context, next);
      }
    });

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            HapticService.lightImpact();
            timerNotifier.pause();
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          widget.task.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Finish session early button
          TextButton(
            onPressed: () {
              HapticService.mediumImpact();
              timerNotifier.complete();
            },
            child: Text(
              'Concluir',
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Mode Selector Pill (Allows switching freely)
            Center(
              child: TimerModeSelector(
                currentMode: timerState.visualMode,
                accentColor: accentColor,
                onModeChanged: (newMode) {
                  timerNotifier.setVisualMode(newMode);
                },
              ),
            ),

            const SizedBox(height: 12),

            // Active View based on Selected Mode
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: _buildVisualModeView(
                  timerState.visualMode,
                  timerState,
                  timerNotifier,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualModeView(
    TimerVisualMode mode,
    TimerState state,
    TimerController notifier,
  ) {
    switch (mode) {
      case TimerVisualMode.minimalDial:
        return MinimalDialView(
          key: const ValueKey('minimalDial'),
          task: widget.task,
          state: state,
          onTogglePlayPause: () {
            if (state.isRunning) {
              notifier.pause();
            } else {
              notifier.resume();
            }
          },
          onReset: () => notifier.reset(),
          onAddMinutes: (mins) => notifier.addMinutes(mins),
        );

      case TimerVisualMode.sacredMandala:
        return SacredMandalaView(
          key: const ValueKey('sacredMandala'),
          task: widget.task,
          state: state,
          onTogglePlayPause: () {
            if (state.isRunning) {
              notifier.pause();
            } else {
              notifier.resume();
            }
          },
          onReset: () => notifier.reset(),
          onAddMinutes: (mins) => notifier.addMinutes(mins),
        );

      case TimerVisualMode.inspirational:
        return InspirationalView(
          key: const ValueKey('inspirational'),
          task: widget.task,
          state: state,
          onTogglePlayPause: () {
            if (state.isRunning) {
              notifier.pause();
            } else {
              notifier.resume();
            }
          },
          onReset: () => notifier.reset(),
          onAddMinutes: (mins) => notifier.addMinutes(mins),
        );

      case TimerVisualMode.anxietyFree:
        return AnxietyFreeView(
          key: const ValueKey('anxietyFree'),
          task: widget.task,
          state: state,
          onTogglePlayPause: () {
            if (state.isRunning) {
              notifier.pause();
            } else {
              notifier.resume();
            }
          },
          onReset: () => notifier.reset(),
        );
    }
  }
}
