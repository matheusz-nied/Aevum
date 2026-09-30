import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aevum/core/services/timer_session_store.dart';
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

    test('clear() stops the ticker and returns to a blank idle state', () {
      controller.start(sampleTask);
      controller.clear();

      expect(controller.state.status, equals(TimerStatus.idle));
      expect(controller.state.task, isNull);
      expect(controller.state.elapsedSeconds, equals(0));
    });

    test('never emits the same elapsed second twice in sequence', () async {
      controller.start(sampleTask);
      final elapsedValues = <int>[];
      controller.addListener(
        (state) => elapsedValues.add(state.elapsedSeconds),
      );

      await Future<void>.delayed(const Duration(milliseconds: 1100));

      for (var index = 1; index < elapsedValues.length; index++) {
        expect(elapsedValues[index], isNot(elapsedValues[index - 1]));
      }
    });
  });

  group('TimerController precision and persistence', () {
    late Duration now;
    late TaskModel task;

    setUp(() {
      now = Duration.zero;
      task = TaskModel(
        id: 't-precision',
        title: 'Leitura',
        targetMinutes: 10,
        iconKey: TaskIcon.mindfulness,
        colorValue: 0xFF00E5BC,
        defaultVisualMode: TimerVisualMode.minimalDial,
      );
    });

    test('pauses do not lose sub-second time', () {
      final controller = TimerController(clock: () => now);
      addTearDown(controller.dispose);

      controller.start(task);
      // Três segmentos de 900ms: truncando por pausa daria 0s; o correto é 2s.
      for (var i = 0; i < 3; i++) {
        now += const Duration(milliseconds: 900);
        controller.pause();
        controller.resume();
      }
      now += Duration.zero;
      controller.pause();

      expect(controller.state.elapsedSeconds, 2);
    });

    test('time spent paused is not counted', () {
      final controller = TimerController(clock: () => now);
      addTearDown(controller.dispose);

      controller.start(task);
      now += const Duration(seconds: 5);
      controller.pause();
      now += const Duration(minutes: 30);
      controller.resume();
      now += const Duration(seconds: 2);
      controller.pause();

      expect(controller.state.elapsedSeconds, 7);
    });

    test('pause() persists a snapshot that restore() picks up', () async {
      SharedPreferences.setMockInitialValues({});
      final store = TimerSessionStore(await SharedPreferences.getInstance());
      final controller = TimerController(store: store, clock: () => now);
      addTearDown(controller.dispose);

      controller.start(task);
      now += const Duration(seconds: 90, milliseconds: 500);
      controller.pause();
      controller.addMinutes(5);

      final snapshot = store.load()!;
      expect(snapshot.taskId, task.id);
      expect(snapshot.elapsedMs, 90500);
      expect(snapshot.targetSeconds, 900);

      final revived = TimerController(store: store, clock: () => now);
      addTearDown(revived.dispose);
      revived.restore(task, snapshot);

      expect(revived.state.status, TimerStatus.running);
      expect(revived.state.elapsedSeconds, 90);
      expect(revived.state.targetSeconds, 900);

      now += const Duration(seconds: 10);
      revived.pause();
      expect(revived.state.elapsedSeconds, 100);
    });

    test('clear() forgets the persisted session', () async {
      SharedPreferences.setMockInitialValues({});
      final store = TimerSessionStore(await SharedPreferences.getInstance());
      final controller = TimerController(store: store, clock: () => now);
      addTearDown(controller.dispose);

      controller.start(task);
      now += const Duration(seconds: 3);
      controller.pause();
      expect(store.load(), isNotNull);

      controller.clear();
      expect(store.load(), isNull);
    });

    test('corrupted snapshot is treated as absent', () async {
      SharedPreferences.setMockInitialValues({
        'aevum.timer.activeSession': '{not json',
      });
      final store = TimerSessionStore(await SharedPreferences.getInstance());
      expect(store.load(), isNull);
    });
  });
}
