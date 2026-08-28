import 'package:hive/hive.dart';
import 'package:timing/features/tasks/domain/session_record.dart';

class SessionRepository {
  static const String boxName = 'sessions_box';
  final Box _box;

  SessionRepository(this._box);

  static Future<SessionRepository> init() async {
    final box = await Hive.openBox(boxName);
    return SessionRepository(box);
  }

  Future<void> addSession(SessionRecord session) async {
    await _box.put(session.id, session.toMap());
  }

  List<SessionRecord> getAllSessions() {
    final List<SessionRecord> list = [];
    for (var key in _box.keys) {
      final map = _box.get(key);
      if (map != null && map is Map) {
        list.add(SessionRecord.fromMap(map));
      }
    }
    list.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return list;
  }

  List<SessionRecord> getSessionsForTask(String taskId) {
    return getAllSessions().where((s) => s.taskId == taskId).toList();
  }

  List<SessionRecord> getSessionsForDate(DateTime date) {
    return getAllSessions().where((s) {
      return s.completedAt.year == date.year &&
          s.completedAt.month == date.month &&
          s.completedAt.day == date.day;
    }).toList();
  }

  int getTodayTotalMinutes() {
    final today = DateTime.now();
    final todaySessions = getSessionsForDate(today);
    final totalSeconds = todaySessions.fold<int>(
      0,
      (sum, item) => sum + item.durationSeconds,
    );
    return totalSeconds ~/ 60;
  }
}
