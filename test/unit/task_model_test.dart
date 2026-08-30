import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aevum/features/tasks/domain/session_record.dart';
import 'package:aevum/features/tasks/domain/task_icon.dart';
import 'package:aevum/features/tasks/domain/task_model.dart';
import 'package:aevum/features/tasks/domain/timer_visual_mode.dart';

void main() {
  group('TaskModel and SessionRecord Tests', () {
    test('TaskModel serializes to and from Map correctly', () {
      final original = TaskModel(
        id: 'test-123',
        title: 'Escrita Criativa',
        targetMinutes: 15,
        iconKey: TaskIcon.writing,
        colorValue: 0xFFFF5722,
        defaultVisualMode: TimerVisualMode.sacredMandala,
      );

      final map = original.toMap();
      final restored = TaskModel.fromMap(map);

      expect(restored.id, equals(original.id));
      expect(restored.title, equals(original.title));
      expect(restored.targetMinutes, equals(original.targetMinutes));
      expect(restored.iconKey, equals(original.iconKey));
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
      expect(
        TimerVisualMode.inspirational.displayName,
        equals('Inspiracional'),
      );
      expect(TimerVisualMode.focusFree.displayName, equals('Foco Livre'));
      expect(TimerVisualMode.liquidOrb.displayName, equals('Orbe Líquido'));
    });

    test('legacy icon code point and visual mode are migrated', () {
      final restored = TaskModel.fromMap({
        'id': 'legacy',
        'title': 'Legado',
        'targetMinutes': 10,
        'iconCodePoint': Icons.menu_book_rounded.codePoint,
        'colorValue': 0xFF123456,
        'defaultVisualMode': 'anxietyFree',
      });

      expect(restored.iconKey, TaskIcon.reading);
      expect(restored.defaultVisualMode, TimerVisualMode.focusFree);
      expect(restored.toMap().containsKey('iconCodePoint'), isFalse);
      expect(restored.toMap()['defaultVisualMode'], 'focusFree');
    });
  });
}
