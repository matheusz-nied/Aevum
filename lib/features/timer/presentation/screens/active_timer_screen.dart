import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aevum/core/constants/app_colors.dart';
import 'package:aevum/core/services/haptic_service.dart';
import 'package:aevum/core/services/screen_awake_service.dart';
import 'package:aevum/core/widgets/forest_background.dart';
import 'package:aevum/core/widgets/glass_container.dart';
import 'package:aevum/features/tasks/domain/task_model.dart';
import 'package:aevum/features/tasks/domain/timer_visual_mode.dart';
import 'package:aevum/features/tasks/providers/task_providers.dart';
import 'package:aevum/features/timer/domain/timer_state.dart';
import 'package:aevum/features/timer/presentation/views/focus_free_view.dart';
import 'package:aevum/features/timer/presentation/views/inspirational_view.dart';
import 'package:aevum/features/timer/presentation/views/liquid_orb_view.dart';
import 'package:aevum/features/timer/presentation/views/minimal_dial_view.dart';
import 'package:aevum/features/timer/presentation/views/sacred_mandala_view.dart';
import 'package:aevum/features/timer/presentation/widgets/completion_dialog.dart';
import 'package:aevum/features/timer/presentation/widgets/timer_mode_selector.dart';
import 'package:aevum/features/timer/providers/timer_controller.dart';

class ActiveTimerScreen extends ConsumerStatefulWidget {
  final TaskModel task;

  const ActiveTimerScreen({super.key, required this.task});

  @override
  ConsumerState<ActiveTimerScreen> createState() => _ActiveTimerScreenState();
}

class _ActiveTimerScreenState extends ConsumerState<ActiveTimerScreen>
    with WidgetsBindingObserver {
  bool _dialogShown = false;
  bool _pausedByLifecycle = false;
  bool _lifecycleDialogVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(timerControllerProvider.notifier).start(widget.task);
      ScreenAwakeService.setEnabled(true);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ScreenAwakeService.setEnabled(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final timer = ref.read(timerControllerProvider);
    if (state == AppLifecycleState.resumed) {
      if (_pausedByLifecycle) {
        _pausedByLifecycle = false;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _explainLifecyclePause();
        });
        WidgetsBinding.instance.scheduleFrame();
      }
      return;
    }

    if (timer.isRunning) {
      ref.read(timerControllerProvider.notifier).pause();
      _pausedByLifecycle = true;
    }
    ScreenAwakeService.setEnabled(false);
  }

  Future<void> _explainLifecyclePause() async {
    if (_lifecycleDialogVisible) return;
    _lifecycleDialogVisible = true;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sessão pausada'),
        content: const Text(
          'O Aevum pausou o timer quando o app saiu do primeiro plano. Continue quando estiver presente novamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
    _lifecycleDialogVisible = false;
  }

  void _toggleTimer(TimerState state, TimerController notifier) {
    if (state.isRunning) {
      notifier.pause();
      ScreenAwakeService.setEnabled(false);
    } else {
      notifier.resume();
      ScreenAwakeService.setEnabled(true);
    }
  }

  void _showCompletionDialog(BuildContext context, TimerState state) {
    if (_dialogShown) return;
    _dialogShown = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CompletionDialog(
        task: widget.task,
        durationSeconds: state.elapsedSeconds,
        onConfirm: (session) {
          ref.read(sessionListProvider.notifier).recordSession(session);
          ScreenAwakeService.setEnabled(false);
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
                        tooltip: 'Voltar',
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 17,
                          color: AppColors.textWhite,
                        ),
                        onPressed: () {
                          HapticService.lightImpact();
                          timerNotifier.pause();
                          ScreenAwakeService.setEnabled(false);
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
                          ScreenAwakeService.setEnabled(false);
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
            _toggleTimer(state, notifier);
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
            _toggleTimer(state, notifier);
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
            _toggleTimer(state, notifier);
          },
          onReset: () => notifier.reset(),
          onAddMinutes: (mins) => notifier.addMinutes(mins),
        );

      case TimerVisualMode.focusFree:
        return FocusFreeView(
          key: const ValueKey('focusFree'),
          task: widget.task,
          state: state,
          onTogglePlayPause: () {
            _toggleTimer(state, notifier);
          },
          onReset: () => notifier.reset(),
        );

      case TimerVisualMode.liquidOrb:
        return LiquidOrbView(
          key: const ValueKey('liquidOrb'),
          task: widget.task,
          state: state,
          onTogglePlayPause: () {
            _toggleTimer(state, notifier);
          },
          onReset: () => notifier.reset(),
          onAddMinutes: (mins) => notifier.addMinutes(mins),
        );
    }
  }
}
