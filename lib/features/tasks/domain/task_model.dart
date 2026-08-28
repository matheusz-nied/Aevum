import 'package:flutter/material.dart';
import 'package:timing/features/tasks/domain/timer_visual_mode.dart';

class TaskModel {
  final String id;
  final String title;
  final int targetMinutes;
  final int iconCodePoint;
  final int colorValue;
  final TimerVisualMode defaultVisualMode;
  final bool isCountUp;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.targetMinutes,
    required this.iconCodePoint,
    required this.colorValue,
    this.defaultVisualMode = TimerVisualMode.minimalDial,
    this.isCountUp = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  IconData get iconData => IconData(
        // ignore: non_const_argument_for_const_parameter
        iconCodePoint,
        fontFamily: 'MaterialIcons',
      );

  Color get color => Color(colorValue);

  TaskModel copyWith({
    String? id,
    String? title,
    int? targetMinutes,
    int? iconCodePoint,
    int? colorValue,
    TimerVisualMode? defaultVisualMode,
    bool? isCountUp,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      defaultVisualMode: defaultVisualMode ?? this.defaultVisualMode,
      isCountUp: isCountUp ?? this.isCountUp,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'targetMinutes': targetMinutes,
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
      'defaultVisualMode': defaultVisualMode.name,
      'isCountUp': isCountUp,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TaskModel.fromMap(Map<dynamic, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      targetMinutes: (map['targetMinutes'] as num).toInt(),
      iconCodePoint: (map['iconCodePoint'] as num).toInt(),
      colorValue: (map['colorValue'] as num).toInt(),
      defaultVisualMode:
          TimerVisualMode.fromString(map['defaultVisualMode'] as String?),
      isCountUp: map['isCountUp'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
