import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timing/core/constants/app_colors.dart';
import 'package:timing/core/services/haptic_service.dart';
import 'package:timing/core/widgets/forest_background.dart';
import 'package:timing/core/widgets/glass_container.dart';
import 'package:timing/features/tasks/domain/task_model.dart';
import 'package:timing/features/tasks/domain/timer_visual_mode.dart';
import 'package:timing/features/tasks/providers/task_providers.dart';
import 'package:timing/features/timer/domain/timer_state.dart';
import 'package:timing/features/timer/presentation/views/anxiety_free_view.dart';
import 'package:timing/features/timer/presentation/views/inspirational_view.dart';
import 'package:timing/features/timer/presentation/views/liquid_orb_view.dart';
import 'package:timing/features/timer/presentation/views/minimal_dial_view.dart';
import 'package:timing/features/timer/presentation/views/sacred_mandala_view.dart';
import 'package:timing/features/timer/presentation/widgets/completion_dialog.dart';
import 'package:timing/features/timer/presentation/widgets/timer_mode_selector.dart';
import 'package:timing/features/timer/providers/timer_controller.dart';

class ActiveTimerScreen extends ConsumerStatefulWidget {
  final TaskModel task;

  const ActiveTimerScreen({super.key, required this.task});

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
    final accentColor = widget.task.color;

    // Listen for timer auto-completion
    ref.listen<TimerState>(timerControllerProvider, (prev, next) {
      if (next.status == TimerStatus.completed && !_dialogShown) {
        _showCompletionDialog(context, next);
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: ForestBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 4),

              // App bar inline (transparente)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    GlassContainer(
                      isCircle: true,
                      accentColor: accentColor,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 17,
                          color: AppColors.textWhite,
                        ),
                        onPressed: () {
                          HapticService.lightImpact();
                          timerNotifier.pause();
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.task.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textWhite,
                            ),
                          ),
                          const Text(
                            'SESSÃO EM ANDAMENTO',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GlassContainer(
                      borderRadius: 18,
                      accentColor: accentColor,
                      child: TextButton(
                        onPressed: () {
                          HapticService.mediumImpact();
                          timerNotifier.complete();
                        },
                        child: Text(
                          'Concluir',
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Mode Selector
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

              // Visual Mode View
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
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

      case TimerVisualMode.liquidOrb:
        return LiquidOrbView(
          key: const ValueKey('liquidOrb'),
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
    }
  }
}
