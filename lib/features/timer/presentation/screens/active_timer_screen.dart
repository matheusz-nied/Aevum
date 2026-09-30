import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:aevum/core/constants/app_colors.dart';
import 'package:aevum/core/services/haptic_service.dart';
import 'package:aevum/core/services/screen_awake_service.dart';
import 'package:aevum/core/services/timer_session_store.dart';
import 'package:aevum/core/widgets/forest_background.dart';
import 'package:aevum/features/tasks/domain/session_record.dart';
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

  /// Sessão salva a retomar; se nula, começa uma sessão nova.
  final TimerSessionSnapshot? resumeFrom;

  const ActiveTimerScreen({super.key, required this.task, this.resumeFrom});

  @override
  ConsumerState<ActiveTimerScreen> createState() => _ActiveTimerScreenState();
}

enum _ExitChoice { keepGoing, save, discard }

class _ActiveTimerScreenState extends ConsumerState<ActiveTimerScreen>
    with WidgetsBindingObserver {
  bool _dialogShown = false;
  bool _pausedByLifecycle = false;
  bool _lifecycleDialogVisible = false;
  bool _exitDialogVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Listener registrado uma única vez (fora do build) para o diálogo de conclusão.
    ref.listenManual<TimerState>(timerControllerProvider, (prev, next) {
      if (next.status == TimerStatus.completed && !_dialogShown && mounted) {
        _showCompletionDialog(context, next);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final notifier = ref.read(timerControllerProvider.notifier);
      final resumeFrom = widget.resumeFrom;
      if (resumeFrom != null) {
        notifier.restore(widget.task, resumeFrom);
      } else {
        notifier.start(widget.task);
      }
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

  /// Count-up não tem meta a bater; nos demais, vale o alvo atual (com extras).
  bool _reachedGoal(TimerState state) =>
      widget.task.isCountUp || state.elapsedSeconds >= state.targetSeconds;

  /// Voltar (seta ou gesto do sistema): nunca deixa o timer rodando escondido
  /// e não descarta em silêncio o tempo já feito.
  Future<void> _requestExit() async {
    if (_exitDialogVisible) return;
    final notifier = ref.read(timerControllerProvider.notifier);
    final wasRunning = ref.read(timerControllerProvider).isRunning;

    if (wasRunning) {
      notifier.pause();
      ScreenAwakeService.setEnabled(false);
    }

    final state = ref.read(timerControllerProvider);
    if (state.elapsedSeconds <= 0) {
      _leave();
      return;
    }

    _exitDialogVisible = true;
    final choice = await showDialog<_ExitChoice>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sair da sessão?'),
        content: const Text(
          'Você já tem tempo registrado nesta sessão. Quer salvar o que já fez?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, _ExitChoice.discard),
            child: const Text('Descartar'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, _ExitChoice.keepGoing),
            child: const Text('Continuar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, _ExitChoice.save),
            child: const Text('Salvar o que já fiz'),
          ),
        ],
      ),
    );
    _exitDialogVisible = false;
    if (!mounted) return;

    switch (choice) {
      case _ExitChoice.save:
        ref
            .read(sessionListProvider.notifier)
            .recordSession(
              SessionRecord(
                id: const Uuid().v4(),
                taskId: widget.task.id,
                completedAt: DateTime.now(),
                durationSeconds: state.elapsedSeconds,
                completedGoal: _reachedGoal(state),
              ),
            );
        _leave();
      case _ExitChoice.discard:
        _leave();
      case _ExitChoice.keepGoing || null:
        if (wasRunning) {
          notifier.resume();
          ScreenAwakeService.setEnabled(true);
        }
    }
  }

  /// O provider do timer é global: zera antes de fechar a tela.
  void _leave() {
    ref.read(timerControllerProvider.notifier).clear();
    ScreenAwakeService.setEnabled(false);
    Navigator.of(context).pop();
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
        completedGoal: _reachedGoal(state),
        onConfirm: (session) {
          ref.read(sessionListProvider.notifier).recordSession(session);
          ref.read(timerControllerProvider.notifier).clear();
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
    // Apenas o modo visual rebuilda a shell (appbar + seletor).
    // O tick de 1s rebuilda somente a view ativa dentro do Consumer abaixo.
    final visualMode = ref.watch(
      timerControllerProvider.select((s) => s.visualMode),
    );
    final timerNotifier = ref.read(timerControllerProvider.notifier);
    final accentColor = widget.task.color;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _requestExit();
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: ForestBackground(
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 4),

                // App bar inline (transparente)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: SizedBox(
                    height: 40,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              widget.task.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
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
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            tooltip: 'Voltar',
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 17,
                              color: AppColors.textWhite,
                            ),
                            style: IconButton.styleFrom(
                              foregroundColor: AppColors.textWhite,
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(36, 36),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              HapticService.lightImpact();
                              _requestExit();
                            },
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              HapticService.mediumImpact();
                              timerNotifier.complete();
                              ScreenAwakeService.setEnabled(false);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: accentColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Concluir',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Mode Selector
                Center(
                  child: TimerModeSelector(
                    currentMode: visualMode,
                    accentColor: accentColor,
                    onModeChanged: (newMode) {
                      timerNotifier.setVisualMode(newMode);
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Visual Mode View — único trecho que rebuilda a cada segundo.
                Expanded(
                  child: Consumer(
                    builder: (context, ref, _) {
                      final viewState = ref.watch(timerControllerProvider);
                      final notifier = ref.read(
                        timerControllerProvider.notifier,
                      );
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: _buildVisualModeView(
                          viewState.visualMode,
                          viewState,
                          notifier,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
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
