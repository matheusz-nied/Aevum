import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aevum/core/constants/app_colors.dart';
import 'package:aevum/features/tasks/domain/task_model.dart';
import 'package:aevum/features/tasks/domain/task_icon.dart';
import 'package:aevum/features/onboarding/presentation/onboarding_screen.dart';
import 'package:aevum/features/tasks/domain/timer_visual_mode.dart';
import 'package:aevum/features/tasks/presentation/widgets/create_task_sheet.dart';
import 'package:aevum/features/tasks/presentation/widgets/daily_progress_header.dart';
import 'package:aevum/features/tasks/presentation/widgets/glass_create_task_button.dart';
import 'package:aevum/features/tasks/presentation/widgets/task_card.dart';
import 'package:aevum/features/timer/domain/timer_state.dart';
import 'package:aevum/features/timer/presentation/views/focus_free_view.dart';
import 'package:aevum/features/timer/presentation/views/liquid_orb_view.dart';
import 'package:aevum/features/timer/presentation/widgets/timer_mode_selector.dart';
import 'package:aevum/features/timer/presentation/screens/active_timer_screen.dart';
import 'package:aevum/features/timer/providers/timer_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('Onboarding presents the three product decisions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: OnboardingScreen())),
    );

    expect(find.text('Evolua no seu tempo'), findsOneWidget);
    await tester.drag(find.byType(PageView), const Offset(-600, 0));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    expect(find.text('Escolha como perceber o tempo'), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(-600, 0));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    expect(find.text('Um momento por vez'), findsOneWidget);
    expect(find.text('Criar meu primeiro hábito'), findsOneWidget);
  });

  testWidgets('Timer pauses and explains when the app leaves foreground', (
    WidgetTester tester,
  ) async {
    final task = TaskModel(
      id: 'foreground',
      title: 'Foco presente',
      targetMinutes: 10,
      iconKey: TaskIcon.nature,
      colorValue: AppColors.emeraldMist.toARGB32(),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: ActiveTimerScreen(task: task)),
      ),
    );
    await tester.pump();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(ActiveTimerScreen)),
    );
    expect(container.read(timerControllerProvider).status, TimerStatus.running);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(container.read(timerControllerProvider).status, TimerStatus.paused);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Sessão pausada'), findsOneWidget);
    expect(find.text('Entendi'), findsOneWidget);
  });

  group('System back on the active timer', () {
    final task = TaskModel(
      id: 'back',
      title: 'Leitura',
      targetMinutes: 10,
      iconKey: TaskIcon.nature,
      colorValue: AppColors.emeraldMist.toARGB32(),
    );

    Future<ProviderContainer> openTimer(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ActiveTimerScreen(task: task),
                    ),
                  ),
                  child: const Text('abrir'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      return ProviderScope.containerOf(
        tester.element(find.byType(ActiveTimerScreen)),
      );
    }

    testWidgets('leaves right away and clears the timer when nothing elapsed', (
      tester,
    ) async {
      final container = await openTimer(tester);
      expect(
        container.read(timerControllerProvider).status,
        TimerStatus.running,
      );

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(ActiveTimerScreen), findsNothing);
      expect(container.read(timerControllerProvider).status, TimerStatus.idle);
    });

    testWidgets('asks before leaving once time has elapsed and can resume', (
      tester,
    ) async {
      final container = await openTimer(tester);
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 1100)),
      );

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('Sair da sessão?'), findsOneWidget);
      expect(find.byType(ActiveTimerScreen), findsOneWidget);
      expect(
        container.read(timerControllerProvider).status,
        TimerStatus.paused,
      );

      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      expect(find.byType(ActiveTimerScreen), findsOneWidget);
      expect(
        container.read(timerControllerProvider).status,
        TimerStatus.running,
      );
    });

    testWidgets('discarding leaves the screen and stops the timer', (
      tester,
    ) async {
      final container = await openTimer(tester);
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 1100)),
      );

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Descartar'));
      await tester.pumpAndSettle();

      expect(find.byType(ActiveTimerScreen), findsNothing);
      expect(container.read(timerControllerProvider).status, TimerStatus.idle);
      expect(container.read(timerControllerProvider).elapsedSeconds, 0);
    });
  });

  testWidgets('DailyProgressHeader renders percentage and minutes correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DailyProgressHeader(
            totalFocusedMinutes: 45,
            completedTasksCount: 2,
            totalTasksCount: 4,
            onOpenStats: () {},
          ),
        ),
      ),
    );

    expect(find.text('50%'), findsOneWidget);
    expect(find.text('45 min'), findsOneWidget);
    expect(find.text('2 de 4 hábitos completos'), findsOneWidget);
  });

  testWidgets('TaskCard renders title and duration, and responds to tap', (
    WidgetTester tester,
  ) async {
    bool tapped = false;
    final task = TaskModel(
      id: 't1',
      title: 'Escrita Diária',
      targetMinutes: 15,
      iconKey: TaskIcon.writing,
      colorValue: AppColors.emeraldMist.toARGB32(),
      defaultVisualMode: TimerVisualMode.minimalDial,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TaskCard(
            task: task,
            isCompletedToday: false,
            onTap: () => tapped = true,
            onDelete: () {},
            onEdit: () {},
          ),
        ),
      ),
    );

    expect(find.text('Escrita Diária'), findsOneWidget);
    expect(find.text('15 min'), findsOneWidget);

    await tester.tap(find.byType(TaskCard));
    expect(tapped, isTrue);
  });

  testWidgets('TimerModeSelector allows switching visual modes', (
    WidgetTester tester,
  ) async {
    TimerVisualMode selected = TimerVisualMode.minimalDial;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return TimerModeSelector(
                currentMode: selected,
                accentColor: AppColors.emeraldMist,
                onModeChanged: (mode) {
                  setState(() => selected = mode);
                },
              );
            },
          ),
        ),
      ),
    );

    expect(find.byTooltip('Minimal Tátil'), findsOneWidget);

    // Tap on Mandala Flow icon
    await tester.tap(find.byIcon(Icons.spa_outlined));
    await tester.pumpAndSettle();

    expect(selected, equals(TimerVisualMode.sacredMandala));

    // Tap on Foco Livre icon
    await tester.tap(find.byIcon(Icons.self_improvement_rounded));
    await tester.pumpAndSettle();

    expect(selected, equals(TimerVisualMode.focusFree));

    await tester.tap(find.byIcon(Icons.water_drop_outlined));
    await tester.pumpAndSettle();

    expect(selected, equals(TimerVisualMode.liquidOrb));
  });

  testWidgets('FocusFreeView paints the liquid orb and exposes pause', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var pauseTapped = false;
    final task = TaskModel(
      id: 'calm',
      title: 'Respirar',
      targetMinutes: 20,
      iconKey: TaskIcon.nature,
      colorValue: AppColors.emeraldMist.toARGB32(),
      defaultVisualMode: TimerVisualMode.focusFree,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: AppColors.forestDeep,
          body: FocusFreeView(
            task: task,
            state: TimerState(
              task: task,
              status: TimerStatus.running,
              visualMode: TimerVisualMode.focusFree,
              targetSeconds: 1200,
            ),
            onTogglePlayPause: () => pauseTapped = true,
            onReset: () {},
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 4200));

    expect(find.byKey(const ValueKey('liquidGlassOrb')), findsOneWidget);
    expect(find.byTooltip('Pausar'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Pausar'));
    expect(pauseTapped, isTrue);
  });

  testWidgets('LiquidOrbView renders and keeps its interactive sphere usable', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var pauseTapped = false;
    final task = TaskModel(
      id: 'liquid',
      title: 'Meditação Líquida',
      targetMinutes: 20,
      iconKey: TaskIcon.wellbeing,
      colorValue: AppColors.emeraldMist.toARGB32(),
      defaultVisualMode: TimerVisualMode.liquidOrb,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: AppColors.forestDeep,
          body: LiquidOrbView(
            task: task,
            state: TimerState(
              task: task,
              status: TimerStatus.running,
              visualMode: TimerVisualMode.liquidOrb,
              targetSeconds: 1200,
            ),
            onTogglePlayPause: () => pauseTapped = true,
            onReset: () {},
            onAddMinutes: (_) {},
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('FLUXO ATIVO'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('interactiveLiquidSphere')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.drag(
      find.byKey(const ValueKey('interactiveLiquidSphere')),
      const Offset(24, 12),
    );
    await tester.pump(const Duration(milliseconds: 900));
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Pausar'));
    expect(pauseTapped, isTrue);
  });

  testWidgets('GlassCreateTaskButton renders and handles tap with animation', (
    WidgetTester tester,
  ) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GlassCreateTaskButton(
            onPressed: () => tapped = true,
            label: 'Novo hábito',
          ),
        ),
      ),
    );

    expect(find.text('Novo hábito'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);

    await tester.tap(find.byType(GlassCreateTaskButton));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });

  testWidgets('CreateTaskSheet renders live preview and allows customization', (
    WidgetTester tester,
  ) async {
    TaskModel? savedTask;

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CreateTaskSheet(
            onSave: (task) {
              savedTask = task;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Novo Hábito'), findsOneWidget);
    expect(find.text('TEMPO DE FOCO'), findsOneWidget);
    expect(find.text('EXPERIÊNCIA DO TIMER'), findsOneWidget);
    expect(find.text('COR DE DESTAQUE'), findsOneWidget);
    expect(find.text('ÍCONE DO HÁBITO'), findsOneWidget);

    // Initial placeholder in preview
    expect(find.text('Nome do seu hábito'), findsOneWidget);

    // Type a title
    await tester.enterText(find.byType(TextField), 'Leitura Noturna');
    await tester.pump();

    // Preview should reflect typed text
    expect(
      find.text('Leitura Noturna'),
      findsNWidgets(2),
    ); // TextField & Preview

    // Select duration: 25m
    await tester.tap(find.text('25m'));
    await tester.pumpAndSettle();
    expect(find.text('25 min'), findsOneWidget);

    // Select visual mode: Mandala Flow
    await tester.tap(find.text('Mandala Flow'));
    await tester.pumpAndSettle();
    expect(
      find.text('Geometria sagrada pulsante com ritmo de respiração'),
      findsOneWidget,
    );

    // Drag main scroll view to reveal icon selector and tap Natureza
    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, -250),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Natureza'));
    await tester.pumpAndSettle();

    // Tap submit
    await tester.tap(find.text('Criar Hábito'));
    await tester.pumpAndSettle();

    expect(savedTask, isNotNull);
    expect(savedTask!.title, 'Leitura Noturna');
    expect(savedTask!.targetMinutes, 25);
    expect(savedTask!.defaultVisualMode, TimerVisualMode.sacredMandala);
    expect(savedTask!.iconKey, TaskIcon.nature);
  });

  testWidgets('CreateTaskSheet populates existing task for editing', (
    WidgetTester tester,
  ) async {
    TaskModel? updatedTask;
    final existing = TaskModel(
      id: 'existing-123',
      title: 'Caminhada Matinal',
      targetMinutes: 30,
      iconKey: TaskIcon.exercise,
      colorValue: AppColors.mossCalm.toARGB32(),
      defaultVisualMode: TimerVisualMode.focusFree,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CreateTaskSheet(
            existingTask: existing,
            onSave: (task) {
              updatedTask = task;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Editar Hábito'), findsOneWidget);
    expect(find.text('Caminhada Matinal'), findsNWidgets(2)); // Input & Preview
    expect(find.text('Salvar Alterações'), findsOneWidget);

    // Submit edit
    await tester.tap(find.text('Salvar Alterações'));
    await tester.pumpAndSettle();

    expect(updatedTask, isNotNull);
    expect(updatedTask!.id, 'existing-123');
    expect(updatedTask!.title, 'Caminhada Matinal');
    expect(updatedTask!.targetMinutes, 30);
  });
}
