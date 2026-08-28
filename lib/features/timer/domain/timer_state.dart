import 'package:timing/features/tasks/domain/task_model.dart';
import 'package:timing/features/tasks/domain/timer_visual_mode.dart';

enum TimerStatus {
  idle,
  running,
  paused,
  completed,
}

class TimerState {
  final TaskModel? task;
  final TimerStatus status;
  final TimerVisualMode visualMode;
  final int targetSeconds;
  final int elapsedSeconds;
  final DateTime? startedAt;
  final DateTime? pausedAt;

  const TimerState({
    this.task,
    this.status = TimerStatus.idle,
    this.visualMode = TimerVisualMode.minimalDial,
    this.targetSeconds = 0,
    this.elapsedSeconds = 0,
    this.startedAt,
    this.pausedAt,
  });

  int get remainingSeconds {
    if (task?.isCountUp ?? false) {
      return elapsedSeconds;
    }
    final remaining = targetSeconds - elapsedSeconds;
    return remaining < 0 ? 0 : remaining;
  }

  double get progress {
    if (targetSeconds <= 0) return 0.0;
    final p = elapsedSeconds / targetSeconds;
    return p.clamp(0.0, 1.0);
  }

  bool get isRunning => status == TimerStatus.running;
  bool get isPaused => status == TimerStatus.paused;
  bool get isCompleted => status == TimerStatus.completed;

  TimerState copyWith({
    TaskModel? task,
    TimerStatus? status,
    TimerVisualMode? visualMode,
    int? targetSeconds,
    int? elapsedSeconds,
    DateTime? startedAt,
    DateTime? pausedAt,
  }) {
    return TimerState(
      task: task ?? this.task,
      status: status ?? this.status,
      visualMode: visualMode ?? this.visualMode,
      targetSeconds: targetSeconds ?? this.targetSeconds,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      startedAt: startedAt ?? this.startedAt,
      pausedAt: pausedAt ?? this.pausedAt,
    );
  }
}
