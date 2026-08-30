import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:aevum/core/constants/app_colors.dart';
import 'package:aevum/core/services/haptic_service.dart';
import 'package:aevum/features/tasks/domain/task_icon.dart';
import 'package:aevum/features/tasks/domain/task_model.dart';
import 'package:aevum/features/tasks/domain/timer_visual_mode.dart';
import 'package:uuid/uuid.dart';

class CreateTaskSheet extends StatefulWidget {
  final TaskModel? existingTask;
  final Function(TaskModel) onSave;

  const CreateTaskSheet({super.key, this.existingTask, required this.onSave});

  @override
  State<CreateTaskSheet> createState() => _CreateTaskSheetState();
}

class _CreateTaskSheetState extends State<CreateTaskSheet> {
  late TextEditingController _titleController;
  late int _targetMinutes;
  late int _selectedColorValue;
  late TaskIcon _selectedIcon;
  late TimerVisualMode _selectedVisualMode;

  static const List<int> _presetDurations = [5, 10, 15, 20, 25, 30, 45, 60];

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _targetMinutes = task?.targetMinutes ?? 15;
    _selectedColorValue = task?.colorValue ?? AppColors.emeraldMist.toARGB32();
    _selectedIcon = task?.iconKey ?? TaskIcon.writing;
    _selectedVisualMode =
        task?.defaultVisualMode ?? TimerVisualMode.minimalDial;
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
      iconKey: _selectedIcon,
      colorValue: _selectedColorValue,
      defaultVisualMode: _selectedVisualMode,
      createdAt: widget.existingTask?.createdAt ?? DateTime.now(),
    );

    HapticService.mediumImpact();
    widget.onSave(task);
    Navigator.of(context).pop();
  }

  Color get _selectedColor => Color(_selectedColorValue);

  Color get _selectedFill =>
      Color.alphaBlend(Colors.white.withValues(alpha: 0.24), _selectedColor);

  Widget _buildChoiceChip({
    required Widget label,
    required bool selected,
    required ValueChanged<bool> onSelected,
    Widget? avatar,
    bool showCheckmark = true,
  }) {
    return ChoiceChip(
      avatar: avatar,
      label: label,
      selected: selected,
      onSelected: onSelected,
      selectedColor: _selectedFill,
      backgroundColor: Colors.white.withValues(alpha: 0.045),
      checkmarkColor: AppColors.forestDeep,
      side: BorderSide(
        color: selected
            ? Colors.white.withValues(alpha: 0.28)
            : Colors.white.withValues(alpha: 0.10),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      shadowColor: Colors.transparent,
      selectedShadowColor: Colors.transparent,
      elevation: 0,
      pressElevation: 0,
      showCheckmark: showCheckmark,
      labelPadding: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      disabledColor: Colors.white.withValues(alpha: 0.03),
      clipBehavior: Clip.none,
      autofocus: false,
      color: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return _selectedFill;
        if (states.contains(WidgetState.pressed)) {
          return Colors.white.withValues(alpha: 0.075);
        }
        return Colors.white.withValues(alpha: 0.045);
      }),
      labelStyle: const TextStyle(fontSize: 14, height: 1),
    );
  }

  Widget _buildDurationChip(int duration) {
    final isSelected = _targetMinutes == duration;
    return _buildChoiceChip(
      label: Text(
        '${duration}m',
        style: TextStyle(
          color: isSelected ? AppColors.forestDeep : AppColors.textWhite,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _targetMinutes = duration);
          HapticService.selectionClick();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingTask != null;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.26),
                      width: 1,
                    ),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.forestSurfaceElevated.withValues(alpha: 0.70),
                      AppColors.forestMid.withValues(alpha: 0.78),
                      AppColors.forestDeep.withValues(alpha: 0.90),
                    ],
                    stops: const [0, 0.34, 1],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -100,
              left: -70,
              width: 290,
              height: 230,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.10),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: -90,
              bottom: 80,
              width: 250,
              height: 250,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppColors.emeraldMist.withValues(alpha: 0.055),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.sizeOf(context).height * 0.80,
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 18,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 36,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.18),
                                Colors.white.withValues(alpha: 0.38),
                                Colors.white.withValues(alpha: 0.18),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(99),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.08),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 19),
                      Text(
                        isEditing ? 'Editar Hábito' : 'Novo Hábito',
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textWhite,
                          letterSpacing: -0.35,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Campo com uma única camada de vidro, sem relevo pesado.
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(17),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.10),
                              Colors.white.withValues(alpha: 0.035),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.14),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.forestBlack.withValues(
                                alpha: 0.16,
                              ),
                              blurRadius: 18,
                              spreadRadius: -8,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _titleController,
                          autofocus: !isEditing,
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Ex: Escrita do dia, Meditação...',
                            hintStyle: const TextStyle(
                              color: AppColors.textMuted,
                            ),
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            prefixIcon: const Icon(
                              Icons.edit_note_rounded,
                              color: AppColors.textMuted,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Meta',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: _presetDurations
                                .take(4)
                                .map(
                                  (duration) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: _buildDurationChip(duration),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: _presetDurations
                                .skip(4)
                                .map(
                                  (duration) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: _buildDurationChip(duration),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Estilo do Timer',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
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
                              child: _buildChoiceChip(
                                showCheckmark: false,
                                avatar: Icon(
                                  mode.icon,
                                  size: 16,
                                  color: isSelected
                                      ? AppColors.forestDeep
                                      : AppColors.textMuted,
                                ),
                                label: Text(
                                  mode.displayName,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.forestDeep
                                        : AppColors.textWhite,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() => _selectedVisualMode = mode);
                                    HapticService.selectionClick();
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Cor de destaque',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: AppColors.taskColors.map((color) {
                          final isSelected =
                              _selectedColorValue == color.toARGB32();
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Semantics(
                              button: true,
                              selected: isSelected,
                              label:
                                  'Cor ${AppColors.taskColors.indexOf(color) + 1}',
                              child: GestureDetector(
                                onTap: () {
                                  setState(
                                    () =>
                                        _selectedColorValue = color.toARGB32(),
                                  );
                                  HapticService.selectionClick();
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white.withValues(
                                              alpha: 0.10,
                                            ),
                                      width: isSelected ? 2.2 : 1,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: color.withValues(
                                                alpha: 0.26,
                                              ),
                                              blurRadius: 10,
                                              spreadRadius: 1,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Ícone',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: TaskIcon.values.map((icon) {
                            final isSelected = _selectedIcon == icon;
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Semantics(
                                button: true,
                                selected: isSelected,
                                label: 'Ícone ${icon.displayName}',
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? _selectedColor.withValues(alpha: 0.14)
                                        : Colors.white.withValues(alpha: 0.035),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected
                                          ? _selectedColor.withValues(
                                              alpha: 0.72,
                                            )
                                          : Colors.white.withValues(
                                              alpha: 0.07,
                                            ),
                                    ),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() => _selectedIcon = icon);
                                        HapticService.selectionClick();
                                      },
                                      borderRadius: BorderRadius.circular(14),
                                      child: Icon(
                                        icon.iconData,
                                        color: isSelected
                                            ? _selectedFill
                                            : AppColors.textMuted,
                                        size: 21,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 28),

                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(17),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFD3DDD0), AppColors.sage],
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.28),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.forestBlack.withValues(
                                alpha: 0.24,
                              ),
                              blurRadius: 18,
                              spreadRadius: -6,
                              offset: const Offset(0, 9),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _submit,
                            borderRadius: BorderRadius.circular(17),
                            splashColor: Colors.white.withValues(alpha: 0.18),
                            child: SizedBox(
                              height: 52,
                              child: Center(
                                child: Text(
                                  isEditing
                                      ? 'Salvar Alterações'
                                      : 'Criar Hábito',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.forestDeep,
                                    letterSpacing: -0.15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
