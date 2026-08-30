import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aevum/core/services/audio_service.dart';
import 'package:aevum/core/services/haptic_service.dart';
import 'package:aevum/features/tasks/domain/task_model.dart';
import 'package:aevum/features/tasks/domain/timer_visual_mode.dart';
import 'package:aevum/features/timer/domain/timer_state.dart';

class TimerController extends StateNotifier<TimerState> {
  Timer? _ticker;
  DateTime? _segmentStartTime;
  int _accumulatedSeconds = 0;

  TimerController() : super(const TimerState());

  void setVisualMode(TimerVisualMode mode) {
    state = state.copyWith(visualMode: mode);
    HapticService.selectionClick();
  }

  void start(TaskModel task, {TimerVisualMode? initialMode}) {
    _ticker?.cancel();
    _accumulatedSeconds = 0;
    _segmentStartTime = DateTime.now();

    final targetSec = task.targetMinutes * 60;
    final mode = initialMode ?? task.defaultVisualMode;

    state = TimerState(
      task: task,
      status: TimerStatus.running,
      visualMode: mode,
      targetSeconds: targetSec,
      elapsedSeconds: 0,
      startedAt: _segmentStartTime,
    );

    HapticService.mediumImpact();
    _startTicker();
  }

  void pause() {
    if (state.status != TimerStatus.running) return;
    _ticker?.cancel();

    if (_segmentStartTime != null) {
      _accumulatedSeconds += DateTime.now()
          .difference(_segmentStartTime!)
          .inSeconds;
    }
    _segmentStartTime = null;

    state = state.copyWith(
      status: TimerStatus.paused,
      elapsedSeconds: _accumulatedSeconds,
      pausedAt: DateTime.now(),
    );

    HapticService.lightImpact();
  }

  void resume() {
    if (state.status != TimerStatus.paused) return;

    _segmentStartTime = DateTime.now();
    state = state.copyWith(
      status: TimerStatus.running,
      startedAt: state.startedAt ?? _segmentStartTime,
    );

    HapticService.lightImpact();
    _startTicker();
  }

  void addMinutes(int minutes) {
    final addSec = minutes * 60;
    final newTarget = state.targetSeconds + addSec;
    state = state.copyWith(targetSeconds: newTarget);
    HapticService.selectionClick();
  }

  void reset() {
    _ticker?.cancel();
    _accumulatedSeconds = 0;
    _segmentStartTime = null;

    state = TimerState(
      task: state.task,
      status: TimerStatus.idle,
      visualMode: state.visualMode,
      targetSeconds: (state.task?.targetMinutes ?? 0) * 60,
      elapsedSeconds: 0,
    );

    HapticService.mediumImpact();
  }

  void complete() {
    _ticker?.cancel();
    if (_segmentStartTime != null) {
      _accumulatedSeconds += DateTime.now()
          .difference(_segmentStartTime!)
          .inSeconds;
    }
    _segmentStartTime = null;

    state = state.copyWith(
      status: TimerStatus.completed,
      elapsedSeconds: _accumulatedSeconds,
    );

    HapticService.success();
    AudioService.playTimerCompleteSound();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (_segmentStartTime == null) return;

      final currentSegmentSeconds = DateTime.now()
          .difference(_segmentStartTime!)
          .inSeconds;
      final currentTotalElapsed = _accumulatedSeconds + currentSegmentSeconds;

      if (!state.task!.isCountUp &&
          currentTotalElapsed >= state.targetSeconds) {
        _accumulatedSeconds = state.targetSeconds;
        complete();
      } else {
        state = state.copyWith(elapsedSeconds: currentTotalElapsed);
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

final timerControllerProvider =
    StateNotifierProvider<TimerController, TimerState>((ref) {
      return TimerController();
    });
