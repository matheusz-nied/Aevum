import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timing/features/tasks/domain/session_record.dart';
import 'package:timing/features/tasks/domain/task_model.dart';
import 'package:timing/features/tasks/domain/timer_visual_mode.dart';

void main() {
  group('TaskModel and SessionRecord Tests', () {
    test('TaskModel serializes to and from Map correctly', () {
      final original = TaskModel(
        id: 'test-123',
        title: 'Escrita Criativa',
        targetMinutes: 15,
        iconCodePoint: Icons.edit.codePoint,
        colorValue: 0xFFFF5722,
        defaultVisualMode: TimerVisualMode.sacredMandala,
      );

      final map = original.toMap();
      final restored = TaskModel.fromMap(map);

      expect(restored.id, equals(original.id));
      expect(restored.title, equals(original.title));
      expect(restored.targetMinutes, equals(original.targetMinutes));
      expect(restored.iconCodePoint, equals(original.iconCodePoint));
      expect(restored.colorValue, equals(original.colorValue));
      expect(restored.defaultVisualMode, equals(TimerVisualMode.sacredMandala));
    });

    test('SessionRecord serializes to and from Map correctly', () {
      final now = DateTime.now();
      final session = SessionRecord(
        id: 'sess-1',
        taskId: 'task-1',
        completedAt: now,
        durationSeconds: 900,
        completedGoal: true,
      );

      final map = session.toMap();
      final restored = SessionRecord.fromMap(map);

      expect(restored.id, equals(session.id));
      expect(restored.taskId, equals(session.taskId));
      expect(restored.durationSeconds, equals(900));
      expect(restored.completedGoal, isTrue);
    });

    test('TimerVisualMode displays correct metadata', () {
      expect(TimerVisualMode.minimalDial.displayName, equals('Minimal Tátil'));
      expect(TimerVisualMode.sacredMandala.displayName, equals('Mandala Flow'));
      expect(TimerVisualMode.inspirational.displayName, equals('Inspiracional'));
      expect(TimerVisualMode.anxietyFree.displayName, equals('Anti-Ansiedade'));
    });
  });
}
