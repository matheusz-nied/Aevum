class SessionRecord {
  final String id;
  final String taskId;
  final DateTime completedAt;
  final int durationSeconds;
  final bool completedGoal;

  /// Título e cor do hábito no momento da sessão. Mantêm o histórico legível
  /// depois que o hábito é excluído. Nulos em sessões gravadas antes do campo.
  final String? taskTitle;
  final int? taskColorValue;

  SessionRecord({
    required this.id,
    required this.taskId,
    required this.completedAt,
    required this.durationSeconds,
    required this.completedGoal,
    this.taskTitle,
    this.taskColorValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'completedAt': completedAt.toIso8601String(),
      'durationSeconds': durationSeconds,
      'completedGoal': completedGoal,
      if (taskTitle != null) 'taskTitle': taskTitle,
      if (taskColorValue != null) 'taskColorValue': taskColorValue,
    };
  }

  factory SessionRecord.fromMap(Map<dynamic, dynamic> map) {
    return SessionRecord(
      id: map['id'] as String,
      taskId: map['taskId'] as String,
      completedAt: DateTime.parse(map['completedAt'] as String),
      durationSeconds: (map['durationSeconds'] as num).toInt(),
      completedGoal: map['completedGoal'] as bool? ?? true,
      taskTitle: map['taskTitle'] as String?,
      taskColorValue: (map['taskColorValue'] as num?)?.toInt(),
    );
  }
}
