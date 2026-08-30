import 'package:flutter_test/flutter_test.dart';
import 'package:aevum/features/tasks/domain/task_model.dart';
import 'package:aevum/features/tasks/domain/task_icon.dart';
import 'package:aevum/features/tasks/domain/timer_visual_mode.dart';
import 'package:aevum/features/timer/domain/timer_state.dart';
import 'package:aevum/features/timer/providers/timer_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TimerController Unit Tests', () {
    late TimerController controller;
    late TaskModel sampleTask;

    setUp(() {
      controller = TimerController();
      sampleTask = TaskModel(
        id: 't-test',
        title: 'Meditação Guiada',
        targetMinutes: 10,
        iconKey: TaskIcon.mindfulness,
        colorValue: 0xFF00E5BC,
        defaultVisualMode: TimerVisualMode.sacredMandala,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test('Initial state is idle', () {
      expect(controller.state.status, equals(TimerStatus.idle));
      expect(controller.state.elapsedSeconds, equals(0));
    });

    test('start() configures and starts timer with task values', () {
      controller.start(sampleTask);

      expect(controller.state.status, equals(TimerStatus.running));
      expect(controller.state.task?.id, equals(sampleTask.id));
      expect(controller.state.targetSeconds, equals(600));
      expect(
        controller.state.visualMode,
        equals(TimerVisualMode.sacredMandala),
      );
    });

    test('pause() and resume() cycle state correctly', () {
      controller.start(sampleTask);
      controller.pause();
      expect(controller.state.status, equals(TimerStatus.paused));

      controller.resume();
      expect(controller.state.status, equals(TimerStatus.running));
    });

    test('addMinutes() adds time to targetSeconds', () {
      controller.start(sampleTask);
      expect(controller.state.targetSeconds, equals(600));

      controller.addMinutes(5);
      expect(controller.state.targetSeconds, equals(900));
    });

    test('setVisualMode() updates visual mode seamlessly', () {
      controller.start(sampleTask);
      controller.setVisualMode(TimerVisualMode.focusFree);
      expect(controller.state.visualMode, equals(TimerVisualMode.focusFree));
    });

    test('complete() finishes timer and marks status completed', () {
      controller.start(sampleTask);
      controller.complete();
      expect(controller.state.status, equals(TimerStatus.completed));
    });
  });
}
