import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aevum/core/services/audio_service.dart';
import 'package:aevum/core/services/haptic_service.dart';
import 'package:aevum/core/services/timer_session_store.dart';
import 'package:aevum/features/tasks/domain/task_model.dart';
import 'package:aevum/features/tasks/domain/timer_visual_mode.dart';
import 'package:aevum/features/timer/domain/timer_state.dart';

/// Segundos entre checkpoints da sessão em andamento no armazenamento local.
const _checkpointIntervalSeconds = 15;

class TimerController extends StateNotifier<TimerState> {
  /// [clock] deve ser monotônico (não muda com ajuste do relógio do sistema);
  /// por padrão usa um [Stopwatch]. [store] persiste a sessão para retomada.
  TimerController({TimerSessionStore? store, Duration Function()? clock})
    // ignore: prefer_initializing_formals
    : _store = store,
      _clock = clock ?? _stopwatchClock(),
      super(const TimerState());

  static Duration Function() _stopwatchClock() {
    final stopwatch = Stopwatch()..start();
    return () => stopwatch.elapsed;
  }

  final TimerSessionStore? _store;
  final Duration Function() _clock;

  Timer? _ticker;
  Duration? _segmentStart;
  Duration _accumulated = Duration.zero;

  Duration get _elapsed => _segmentStart == null
      ? _accumulated
      : _accumulated + (_clock() - _segmentStart!);

  /// Fecha o segmento em andamento somando-o ao acumulado, sem truncar.
  void _closeSegment() {
    _accumulated = _elapsed;
    _segmentStart = null;
  }

  void _persist() {
    final task = state.task;
    final store = _store;
    if (task == null || store == null) return;
    store.save(
      TimerSessionSnapshot(
        taskId: task.id,
        targetSeconds: state.targetSeconds,
        elapsedMs: _elapsed.inMilliseconds,
        visualMode: state.visualMode,
        savedAt: DateTime.now(),
      ),
    );
  }

  void _forgetPersisted() => _store?.clear();

  void setVisualMode(TimerVisualMode mode) {
    state = state.copyWith(visualMode: mode);
    if (state.status != TimerStatus.idle) _persist();
    HapticService.selectionClick();
  }

  void start(TaskModel task, {TimerVisualMode? initialMode}) {
    _ticker?.cancel();
    _accumulated = Duration.zero;
    _segmentStart = _clock();

    final targetSec = task.targetMinutes * 60;
    final mode = initialMode ?? task.defaultVisualMode;

    state = TimerState(
      task: task,
      status: TimerStatus.running,
      visualMode: mode,
      targetSeconds: targetSec,
      elapsedSeconds: 0,
      startedAt: DateTime.now(),
    );

    HapticService.mediumImpact();
    _startTicker();
  }

  /// Retoma uma sessão salva (ex.: o sistema encerrou o app). Volta rodando,
  /// com o tempo já acumulado.
  void restore(TaskModel task, TimerSessionSnapshot snapshot) {
    _ticker?.cancel();
    _accumulated = Duration(milliseconds: snapshot.elapsedMs);
    _segmentStart = _clock();

    state = TimerState(
      task: task,
      status: TimerStatus.running,
      visualMode: snapshot.visualMode,
      targetSeconds: snapshot.targetSeconds,
      elapsedSeconds: _accumulated.inSeconds,
      startedAt: DateTime.now().subtract(_accumulated),
    );

    HapticService.mediumImpact();
    _startTicker();
  }

  void pause() {
    if (state.status != TimerStatus.running) return;
    _ticker?.cancel();
    _closeSegment();

    state = state.copyWith(
      status: TimerStatus.paused,
      elapsedSeconds: _accumulated.inSeconds,
      pausedAt: DateTime.now(),
    );
    _persist();

    HapticService.lightImpact();
  }

  void resume() {
    if (state.status != TimerStatus.paused) return;

    _segmentStart = _clock();
    state = state.copyWith(
      status: TimerStatus.running,
      startedAt: state.startedAt ?? DateTime.now(),
    );

    HapticService.lightImpact();
    _startTicker();
  }

  void addMinutes(int minutes) {
    final addSec = minutes * 60;
    final newTarget = state.targetSeconds + addSec;
    state = state.copyWith(targetSeconds: newTarget);
    _persist();
    HapticService.selectionClick();
  }

  void reset() {
    _ticker?.cancel();
    _accumulated = Duration.zero;
    _segmentStart = null;
    _forgetPersisted();

    state = TimerState(
      task: state.task,
      status: TimerStatus.idle,
      visualMode: state.visualMode,
      targetSeconds: (state.task?.targetMinutes ?? 0) * 60,
      elapsedSeconds: 0,
    );

    HapticService.mediumImpact();
  }

  /// Encerra a sessão sem feedback: para o ticker e volta ao estado inicial.
  /// Usado ao sair da tela, já que o provider é global e sobrevive a ela.
  void clear() {
    _ticker?.cancel();
    _accumulated = Duration.zero;
    _segmentStart = null;
    _forgetPersisted();
    state = const TimerState();
  }

  void complete() {
    _ticker?.cancel();
    _closeSegment();

    state = state.copyWith(
      status: TimerStatus.completed,
      elapsedSeconds: _accumulated.inSeconds,
    );
    _persist();

    HapticService.success();
    AudioService.playTimerCompleteSound();
  }

  void _startTicker() {
    _ticker?.cancel();
    // 500ms: mesma resolução visual de 1s com metade dos wakeups no Android.
    _ticker = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (_segmentStart == null) return;

      final currentTotalElapsed = _elapsed.inSeconds;

      if (!state.task!.isCountUp &&
          currentTotalElapsed >= state.targetSeconds) {
        _accumulated = Duration(seconds: state.targetSeconds);
        _segmentStart = null;
        complete();
      } else {
        if (currentTotalElapsed == state.elapsedSeconds) return;
        state = state.copyWith(elapsedSeconds: currentTotalElapsed);
        if (currentTotalElapsed % _checkpointIntervalSeconds == 0) _persist();
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

/// Null por padrão (sem persistência); o `main` injeta o store real.
final timerSessionStoreProvider = Provider<TimerSessionStore?>((ref) => null);

final timerControllerProvider =
    StateNotifierProvider<TimerController, TimerState>((ref) {
      return TimerController(store: ref.read(timerSessionStoreProvider));
    });
