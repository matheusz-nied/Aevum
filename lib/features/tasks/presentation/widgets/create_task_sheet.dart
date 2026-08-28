import 'package:flutter/material.dart';
import 'package:timing/core/constants/app_colors.dart';
import 'package:timing/core/services/haptic_service.dart';
import 'package:timing/features/tasks/domain/task_model.dart';
import 'package:timing/features/tasks/domain/timer_visual_mode.dart';
import 'package:uuid/uuid.dart';

class CreateTaskSheet extends StatefulWidget {
  final TaskModel? existingTask;
  final Function(TaskModel) onSave;

  const CreateTaskSheet({
    super.key,
    this.existingTask,
    required this.onSave,
  });

  @override
  State<CreateTaskSheet> createState() => _CreateTaskSheetState();
}

class _CreateTaskSheetState extends State<CreateTaskSheet> {
  late TextEditingController _titleController;
  late int _targetMinutes;
  late int _selectedColorValue;
  late int _selectedIconCode;
  late TimerVisualMode _selectedVisualMode;

  static const List<int> _presetDurations = [5, 10, 15, 20, 25, 30, 45, 60];

  static final List<IconData> _iconOptions = [
    Icons.edit_note_rounded,
    Icons.self_improvement_rounded,
    Icons.menu_book_rounded,
    Icons.spa_rounded,
    Icons.laptop_chromebook_rounded,
    Icons.fitness_center_rounded,
    Icons.music_note_rounded,
    Icons.coffee_rounded,
    Icons.brush_rounded,
    Icons.psychology_rounded,
    Icons.alarm_rounded,
    Icons.favorite_rounded,
  ];

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _targetMinutes = task?.targetMinutes ?? 15;
    _selectedColorValue = task?.colorValue ?? AppColors.coralNeon.toARGB32();
    _selectedIconCode = task?.iconCodePoint ?? Icons.edit_note_rounded.codePoint;
    _selectedVisualMode = task?.defaultVisualMode ?? TimerVisualMode.minimalDial;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final task = TaskModel(
      id: widget.existingTask?.id ?? const Uuid().v4(),
      title: title,
      targetMinutes: _targetMinutes,
      iconCodePoint: _selectedIconCode,
      colorValue: _selectedColorValue,
      defaultVisualMode: _selectedVisualMode,
      createdAt: widget.existingTask?.createdAt ?? DateTime.now(),
    );

    HapticService.mediumImpact();
    widget.onSave(task);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.existingTask != null;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header Title
            Text(
              isEditing ? 'Editar Hábito' : 'Novo Hábito ou Tarefa',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Title text field
            TextField(
              controller: _titleController,
              autofocus: !isEditing,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'Ex: Escrita do dia, Meditação...',
                hintStyle: TextStyle(
                  color: isDark ? AppColors.textMuted : Colors.black38,
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF14171E) : const Color(0xFFF1F3F6),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Duration selector
            Text(
              'Meta de Tempo: $_targetMinutes minutos',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presetDurations.map((duration) {
                final isSelected = _targetMinutes == duration;
                return ChoiceChip(
                  label: Text('${duration}m'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _targetMinutes = duration);
                      HapticService.selectionClick();
                    }
                  },
                  selectedColor: Color(_selectedColorValue),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black87),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor:
                      isDark ? const Color(0xFF161A20) : const Color(0xFFF1F3F6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? Colors.transparent
                          : (isDark ? Colors.white10 : Colors.black12),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Visual Mode Choice for this Task
            Text(
              'Estilo do Timer Preferido',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: TimerVisualMode.values.map((mode) {
                  final isSelected = _selectedVisualMode == mode;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      avatar: Icon(
                        mode.icon,
                        size: 16,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white60 : Colors.black54),
                      ),
                      label: Text(mode.displayName),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedVisualMode = mode);
                          HapticService.selectionClick();
                        }
                      },
                      selectedColor: Color(_selectedColorValue),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor:
                          isDark ? const Color(0xFF161A20) : const Color(0xFFF1F3F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? Colors.transparent
                              : (isDark ? Colors.white10 : Colors.black12),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Color Picker
            Text(
              'Cor de Destaque',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: AppColors.taskColors.map((color) {
                final isSelected = _selectedColorValue == color.toARGB32();
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedColorValue = color.toARGB32());
                    HapticService.selectionClick();
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 2.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.6),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 20, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Icon Picker
            Text(
              'Ícone',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _iconOptions.map((icon) {
                  final isSelected = _selectedIconCode == icon.codePoint;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: InkWell(
                      onTap: () {
                        setState(() => _selectedIconCode = icon.codePoint);
                        HapticService.selectionClick();
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Color(_selectedColorValue).withValues(alpha: 0.2)
                              : (isDark ? const Color(0xFF14171E) : const Color(0xFFF1F3F6)),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? Color(_selectedColorValue)
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: isSelected
                              ? Color(_selectedColorValue)
                              : (isDark ? Colors.white70 : Colors.black54),
                          size: 22,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 28),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(_selectedColorValue),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isEditing ? 'Salvar Alterações' : 'Criar Hábito',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
