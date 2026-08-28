import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timing/core/constants/app_colors.dart';
import 'package:timing/features/tasks/domain/task_model.dart';
import 'package:timing/features/tasks/domain/timer_visual_mode.dart';
import 'package:timing/features/tasks/presentation/widgets/daily_progress_header.dart';
import 'package:timing/features/tasks/presentation/widgets/task_card.dart';
import 'package:timing/features/timer/presentation/widgets/timer_mode_selector.dart';

void main() {
  testWidgets('DailyProgressHeader renders percentage and minutes correctly',
      (WidgetTester tester) async {
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
    expect(find.text('45 min focados hoje'), findsOneWidget);
    expect(find.text('2 de 4 hábitos concluídos'), findsOneWidget);
  });

  testWidgets('TaskCard renders title and duration, and responds to tap',
      (WidgetTester tester) async {
    bool tapped = false;
    final task = TaskModel(
      id: 't1',
      title: 'Escrita Diária',
      targetMinutes: 15,
      iconCodePoint: Icons.edit.codePoint,
      colorValue: AppColors.coralNeon.toARGB32(),
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

  testWidgets('TimerModeSelector allows switching visual modes',
      (WidgetTester tester) async {
    TimerVisualMode selected = TimerVisualMode.minimalDial;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return TimerModeSelector(
                currentMode: selected,
                accentColor: AppColors.sacredTeal,
                onModeChanged: (mode) {
                  setState(() => selected = mode);
                },
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Minimal Tátil'), findsOneWidget);

    // Tap on Mandala Flow icon
    await tester.tap(find.byIcon(Icons.spa_outlined));
    await tester.pumpAndSettle();

    expect(selected, equals(TimerVisualMode.sacredMandala));
  });
}
