class SessionRecord {
  final String id;
  final String taskId;
  final DateTime completedAt;
  final int durationSeconds;
  final bool completedGoal;

  SessionRecord({
    required this.id,
    required this.taskId,
    required this.completedAt,
    required this.durationSeconds,
    required this.completedGoal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'completedAt': completedAt.toIso8601String(),
      'durationSeconds': durationSeconds,
      'completedGoal': completedGoal,
    };
  }

  factory SessionRecord.fromMap(Map<dynamic, dynamic> map) {
    return SessionRecord(
      id: map['id'] as String,
      taskId: map['taskId'] as String,
      completedAt: DateTime.parse(map['completedAt'] as String),
      durationSeconds: (map['durationSeconds'] as num).toInt(),
      completedGoal: map['completedGoal'] as bool? ?? true,
    );
  }
}
