import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timing/core/constants/app_colors.dart';
import 'package:timing/features/tasks/domain/task_model.dart';
import 'package:timing/features/tasks/domain/timer_visual_mode.dart';
import 'package:timing/features/tasks/presentation/widgets/daily_progress_header.dart';
import 'package:timing/features/tasks/presentation/widgets/glass_create_task_button.dart';
import 'package:timing/features/tasks/presentation/widgets/task_card.dart';
import 'package:timing/features/timer/domain/timer_state.dart';
import 'package:timing/features/timer/presentation/views/anxiety_free_view.dart';
import 'package:timing/features/timer/presentation/views/liquid_orb_view.dart';
import 'package:timing/features/timer/presentation/widgets/timer_mode_selector.dart';

void main() {
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
      iconCodePoint: Icons.edit.codePoint,
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

    // Tap on Anti-Ansiedade icon
    await tester.tap(find.byIcon(Icons.self_improvement_rounded));
    await tester.pumpAndSettle();

    expect(selected, equals(TimerVisualMode.anxietyFree));

    await tester.tap(find.byIcon(Icons.water_drop_outlined));
    await tester.pumpAndSettle();

    expect(selected, equals(TimerVisualMode.liquidOrb));
  });

  testWidgets('AnxietyFreeView paints the liquid orb and exposes pause', (
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
      iconCodePoint: Icons.spa_rounded.codePoint,
      colorValue: AppColors.emeraldMist.toARGB32(),
      defaultVisualMode: TimerVisualMode.anxietyFree,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: AppColors.forestDeep,
          body: AnxietyFreeView(
            task: task,
            state: TimerState(
              task: task,
              status: TimerStatus.running,
              visualMode: TimerVisualMode.anxietyFree,
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
      iconCodePoint: Icons.water_drop_rounded.codePoint,
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
}
