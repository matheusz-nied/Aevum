import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:timing/core/constants/app_colors.dart';
import 'package:timing/features/tasks/domain/task_model.dart';
import 'package:timing/features/tasks/domain/timer_visual_mode.dart';
import 'package:uuid/uuid.dart';

class TaskRepository {
  static const String boxName = 'tasks_box';
  final Box _box;

  TaskRepository(this._box);

  static Future<TaskRepository> init() async {
    final box = await Hive.openBox(boxName);
    final repo = TaskRepository(box);
    await repo._seedDefaultTasksIfEmpty();
    return repo;
  }

  Future<void> _seedDefaultTasksIfEmpty() async {
    if (_box.isEmpty) {
      final defaultTasks = [
        TaskModel(
          id: const Uuid().v4(),
          title: 'Escrita Diária',
          targetMinutes: 15,
          iconCodePoint: Icons.edit_note_rounded.codePoint,
          colorValue: AppColors.coralNeon.toARGB32(),
          defaultVisualMode: TimerVisualMode.minimalDial,
        ),
        TaskModel(
          id: const Uuid().v4(),
          title: 'Meditação & Respiração',
          targetMinutes: 10,
          iconCodePoint: Icons.self_improvement_rounded.codePoint,
          colorValue: AppColors.sacredTeal.toARGB32(),
          defaultVisualMode: TimerVisualMode.sacredMandala,
        ),
        TaskModel(
          id: const Uuid().v4(),
          title: 'Leitura Focada',
          targetMinutes: 20,
          iconCodePoint: Icons.menu_book_rounded.codePoint,
          colorValue: AppColors.warmAmber.toARGB32(),
          defaultVisualMode: TimerVisualMode.inspirational,
        ),
        TaskModel(
          id: const Uuid().v4(),
          title: 'Foco Profundo Zen',
          targetMinutes: 25,
          iconCodePoint: Icons.spa_rounded.codePoint,
          colorValue: AppColors.mysticPurple.toARGB32(),
          defaultVisualMode: TimerVisualMode.anxietyFree,
        ),
      ];

      for (final task in defaultTasks) {
        await _box.put(task.id, task.toMap());
      }
    }
  }

  List<TaskModel> getAllTasks() {
    final List<TaskModel> list = [];
    for (var key in _box.keys) {
      final map = _box.get(key);
      if (map != null && map is Map) {
        list.add(TaskModel.fromMap(map));
      }
    }
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  TaskModel? getTaskById(String id) {
    final map = _box.get(id);
    if (map != null && map is Map) {
      return TaskModel.fromMap(map);
    }
    return null;
  }

  Future<void> saveTask(TaskModel task) async {
    await _box.put(task.id, task.toMap());
  }

  Future<void> deleteTask(String id) async {
    await _box.delete(id);
  }
}
