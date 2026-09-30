import 'package:flutter/material.dart';
import 'package:aevum/features/tasks/domain/task_icon.dart';
import 'package:aevum/features/tasks/domain/timer_visual_mode.dart';

class TaskModel {
  /// Todos os dias da semana (`DateTime.monday` a `DateTime.sunday`).
  static const Set<int> everyDay = {1, 2, 3, 4, 5, 6, 7};

  final String id;
  final String title;
  final int targetMinutes;
  final TaskIcon iconKey;
  final int colorValue;
  final TimerVisualMode defaultVisualMode;
  final bool isCountUp;
  final DateTime createdAt;

  /// Dias da semana em que o hábito se repete (`DateTime.weekday`, 1 a 7).
  final Set<int> weekdays;

  TaskModel({
    required this.id,
    required this.title,
    required this.targetMinutes,
    required this.iconKey,
    required this.colorValue,
    this.defaultVisualMode = TimerVisualMode.minimalDial,
    this.isCountUp = false,
    DateTime? createdAt,
    this.weekdays = everyDay,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isDaily => weekdays.length == 7;

  bool isScheduledOn(DateTime date) => weekdays.contains(date.weekday);

  IconData get iconData => iconKey.iconData;

  Color get color => Color(colorValue);

  TaskModel copyWith({
    String? id,
    String? title,
    int? targetMinutes,
    TaskIcon? iconKey,
    int? colorValue,
    TimerVisualMode? defaultVisualMode,
    bool? isCountUp,
    DateTime? createdAt,
    Set<int>? weekdays,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      iconKey: iconKey ?? this.iconKey,
      colorValue: colorValue ?? this.colorValue,
      defaultVisualMode: defaultVisualMode ?? this.defaultVisualMode,
      isCountUp: isCountUp ?? this.isCountUp,
      createdAt: createdAt ?? this.createdAt,
      weekdays: weekdays ?? this.weekdays,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'targetMinutes': targetMinutes,
      'iconKey': iconKey.name,
      'colorValue': colorValue,
      'defaultVisualMode': defaultVisualMode.name,
      'isCountUp': isCountUp,
      'createdAt': createdAt.toIso8601String(),
      'weekdays': (weekdays.toList()..sort()),
    };
  }

  factory TaskModel.fromMap(Map<dynamic, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      targetMinutes: (map['targetMinutes'] as num).toInt(),
      iconKey: TaskIcon.fromStorage(
        key: map['iconKey'] as String?,
        legacyCodePoint: (map['iconCodePoint'] as num?)?.toInt(),
      ),
      colorValue: (map['colorValue'] as num).toInt(),
      defaultVisualMode: TimerVisualMode.fromString(
        map['defaultVisualMode'] as String?,
      ),
      isCountUp: map['isCountUp'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      weekdays: _parseWeekdays(map['weekdays']),
    );
  }

  /// Registros antigos não têm o campo e valem para todos os dias.
  static Set<int> _parseWeekdays(Object? raw) {
    if (raw is! List) return everyDay;
    final days = raw
        .whereType<num>()
        .map((d) => d.toInt())
        .where((d) => d >= 1 && d <= 7)
        .toSet();
    return days.isEmpty ? everyDay : days;
  }
}
