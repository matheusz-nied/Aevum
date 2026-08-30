import 'package:hive/hive.dart';
import 'package:aevum/features/tasks/domain/task_model.dart';

class TaskRepository {
  static const String boxName = 'tasks_box';
  final Box _box;

  TaskRepository(this._box);

  static Future<TaskRepository> init() async {
    final box = await Hive.openBox(boxName);
    final repository = TaskRepository(box);
    await repository._migrateLegacyRecords();
    return repository;
  }

  Future<void> _migrateLegacyRecords() async {
    for (final key in _box.keys.toList()) {
      final raw = _box.get(key);
      if (raw is! Map) continue;
      if (raw['iconKey'] != null && raw['defaultVisualMode'] != 'anxietyFree') {
        continue;
      }
      await _box.put(key, TaskModel.fromMap(raw).toMap());
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

  Future<void> clear() => _box.clear();
}
