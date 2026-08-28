import 'package:flutter/material.dart';

enum TimerVisualMode {
  minimalDial,
  sacredMandala,
  inspirational,
  anxietyFree;

  String get displayName {
    switch (this) {
      case TimerVisualMode.minimalDial:
        return 'Minimal Tátil';
      case TimerVisualMode.sacredMandala:
        return 'Mandala Flow';
      case TimerVisualMode.inspirational:
        return 'Inspiracional';
      case TimerVisualMode.anxietyFree:
        return 'Anti-Ansiedade';
    }
  }

  String get description {
    switch (this) {
      case TimerVisualMode.minimalDial:
        return 'Dial analógico com marcação de minutos e precisão tátil';
      case TimerVisualMode.sacredMandala:
        return 'Geometria sagrada pulsante com ritmo de respiração';
      case TimerVisualMode.inspirational:
        return 'Frases rotativas de apoio, elogios e reforço de foco';
      case TimerVisualMode.anxietyFree:
        return 'Sem relógio visível para eliminar a pressa e ansiedade';
    }
  }

  IconData get icon {
    switch (this) {
      case TimerVisualMode.minimalDial:
        return Icons.timer_outlined;
      case TimerVisualMode.sacredMandala:
        return Icons.spa_outlined;
      case TimerVisualMode.inspirational:
        return Icons.auto_awesome_outlined;
      case TimerVisualMode.anxietyFree:
        return Icons.visibility_off_outlined;
    }
  }

  static TimerVisualMode fromString(String? val) {
    if (val == null) return TimerVisualMode.minimalDial;
    return TimerVisualMode.values.firstWhere(
      (e) => e.name == val,
      orElse: () => TimerVisualMode.minimalDial,
    );
  }
}
