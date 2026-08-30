import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aevum/features/tasks/data/session_repository.dart';
import 'package:aevum/features/tasks/data/task_repository.dart';
import 'package:aevum/features/tasks/domain/session_record.dart';
import 'package:aevum/features/tasks/domain/task_model.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  throw UnimplementedError('taskRepositoryProvider must be initialized');
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  throw UnimplementedError('sessionRepositoryProvider must be initialized');
});

class TaskListNotifier extends StateNotifier<List<TaskModel>> {
  final TaskRepository _repository;

  TaskListNotifier(this._repository) : super(_repository.getAllTasks());

  Future<void> addTask(TaskModel task) async {
    await _repository.saveTask(task);
    state = _repository.getAllTasks();
  }

  Future<void> updateTask(TaskModel task) async {
    await _repository.saveTask(task);
    state = _repository.getAllTasks();
  }

  Future<void> deleteTask(String id) async {
    await _repository.deleteTask(id);
    state = _repository.getAllTasks();
  }

  void refresh() {
    state = _repository.getAllTasks();
  }

  Future<void> clearAll() async {
    await _repository.clear();
    state = const [];
  }
}

final taskListProvider =
    StateNotifierProvider<TaskListNotifier, List<TaskModel>>((ref) {
      final repo = ref.watch(taskRepositoryProvider);
      return TaskListNotifier(repo);
    });

class SessionListNotifier extends StateNotifier<List<SessionRecord>> {
  final SessionRepository _repository;

  SessionListNotifier(this._repository) : super(_repository.getAllSessions());

  Future<void> recordSession(SessionRecord session) async {
    await _repository.addSession(session);
    state = _repository.getAllSessions();
  }

  void refresh() {
    state = _repository.getAllSessions();
  }

  Future<void> clearAll() async {
    await _repository.clear();
    state = const [];
  }
}

final sessionListProvider =
    StateNotifierProvider<SessionListNotifier, List<SessionRecord>>((ref) {
      final repo = ref.watch(sessionRepositoryProvider);
      return SessionListNotifier(repo);
    });

final todayCompletedMinutesProvider = Provider<int>((ref) {
  final sessions = ref.watch(sessionListProvider);
  final now = DateTime.now();
  final todaySessions = sessions.where((s) {
    return s.completedAt.year == now.year &&
        s.completedAt.month == now.month &&
        s.completedAt.day == now.day;
  });
  final totalSeconds = todaySessions.fold<int>(
    0,
    (sum, s) => sum + s.durationSeconds,
  );
  return totalSeconds ~/ 60;
});
