import 'package:flutter/material.dart';

/// Stable keys for the Material icons offered by Aevum.
///
/// Persisting the key instead of a font code point keeps stored data portable
/// and lets Flutter tree-shake every icon safely in release builds.
enum TaskIcon {
  writing(Icons.edit_note_rounded, 'Escrita'),
  mindfulness(Icons.self_improvement_rounded, 'Presença'),
  reading(Icons.menu_book_rounded, 'Leitura'),
  nature(Icons.spa_rounded, 'Natureza'),
  computer(Icons.laptop_chromebook_rounded, 'Computador'),
  exercise(Icons.fitness_center_rounded, 'Exercício'),
  music(Icons.music_note_rounded, 'Música'),
  coffee(Icons.coffee_rounded, 'Pausa'),
  creativity(Icons.brush_rounded, 'Criatividade'),
  learning(Icons.psychology_rounded, 'Aprendizado'),
  routine(Icons.alarm_rounded, 'Rotina'),
  wellbeing(Icons.favorite_rounded, 'Bem-estar');

  const TaskIcon(this.iconData, this.displayName);

  final IconData iconData;
  final String displayName;

  static TaskIcon fromStorage({String? key, int? legacyCodePoint}) {
    if (key != null) {
      for (final value in values) {
        if (value.name == key) return value;
      }
    }

    if (legacyCodePoint != null) {
      for (final value in values) {
        if (value.iconData.codePoint == legacyCodePoint) return value;
      }
    }

    return TaskIcon.writing;
  }
}
