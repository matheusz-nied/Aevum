import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:aevum/core/widgets/adaptive_backdrop_filter.dart';
import 'package:aevum/core/constants/app_colors.dart';
import 'package:aevum/core/services/haptic_service.dart';
import 'package:aevum/core/theme/app_typography.dart';
import 'package:aevum/core/utils/time_utils.dart';
import 'package:aevum/core/widgets/glass_container.dart';
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
  late FocusNode _titleFocusNode;
  late int _targetMinutes;
  late int _selectedColorValue;
  late TaskIcon _selectedIcon;
  late TimerVisualMode _selectedVisualMode;
  late Set<int> _weekdays;
  bool _canSubmit = false;
  Animation<double>? _routeAnimation;
  bool _focusScheduled = false;

  static const List<int> _presetDurations = [5, 10, 15, 20, 25, 30, 45, 60];

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _titleFocusNode = FocusNode();
    _targetMinutes = task?.targetMinutes ?? 15;
    _selectedColorValue = task?.colorValue ?? AppColors.emeraldMist.toARGB32();
    _selectedIcon = task?.iconKey ?? TaskIcon.writing;
    _selectedVisualMode =
        task?.defaultVisualMode ?? TimerVisualMode.minimalDial;
    _weekdays = {...(task?.weekdays ?? TaskModel.everyDay)};
    _canSubmit = _titleController.text.trim().isNotEmpty;
    _titleController.addListener(_onTitleChanged);
  }

  // Só reconstrói o sheet inteiro quando o estado do botão muda; a prévia e o
  // campo de nome se atualizam sozinhos via ListenableBuilder.
  void _onTitleChanged() {
    final canSubmit = _titleController.text.trim().isNotEmpty;
    if (canSubmit == _canSubmit) return;
    setState(() => _canSubmit = canSubmit);
  }

  // O teclado só abre depois que a animação de entrada termina. Abrir junto
  // com o slide do sheet faz cada frame da animação competir com o resize.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_focusScheduled || widget.existingTask != null) return;
    _focusScheduled = true;
    final animation = ModalRoute.of(context)?.animation;
    if (animation == null || animation.isCompleted) {
      _titleFocusNode.requestFocus();
      return;
    }
    _routeAnimation = animation..addStatusListener(_onRouteAnimationStatus);
  }

  void _onRouteAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    _routeAnimation?.removeStatusListener(_onRouteAnimationStatus);
    _routeAnimation = null;
    if (mounted) _titleFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _routeAnimation?.removeStatusListener(_onRouteAnimationStatus);
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
    _titleFocusNode.dispose();
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
      weekdays: _weekdays,
      createdAt: widget.existingTask?.createdAt ?? DateTime.now(),
    );

    HapticService.mediumImpact();
    widget.onSave(task);
    Navigator.of(context).pop();
  }

  Color get _selectedColor => Color(_selectedColorValue);

  String _getColorName(Color color) {
    final argb = color.toARGB32();
    if (argb == AppColors.emeraldMist.toARGB32()) return 'Névoa Esmeralda';
    if (argb == AppColors.sage.toARGB32()) return 'Sálvia';
    if (argb == AppColors.mossCalm.toARGB32()) return 'Musgo Sereno';
    if (argb == AppColors.eucalyptus.toARGB32()) return 'Eucalipto';
    if (argb == AppColors.pineDeep.toARGB32()) return 'Pinheiro Silvestre';
    if (argb == AppColors.lichen.toARGB32()) return 'Líquen Dourado';
    return 'Personalizada';
  }

  Widget _buildSectionHeader({
    required String title,
    String? subtitle,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.3,
                    color: AppColors.textMuted,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '• $subtitle',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _selectedColor.withValues(alpha: 0.95),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }

  Widget _buildHeader({required bool isEditing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'EDITAR RITMO' : 'NOVO RITMO',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                color: _selectedColor,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              isEditing ? 'Editar Hábito' : 'Novo Hábito',
              style: AppTypography.serif(size: 28, weight: FontWeight.w500),
            ),
          ],
        ),
        GlassContainer(
          isCircle: true,
          blur: 14,
          color: Colors.white.withValues(alpha: 0.04),
          child: IconButton(
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.textMuted,
              size: 20,
            ),
            tooltip: 'Fechar',
            onPressed: () {
              HapticService.lightImpact();
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLivePreview() {
    return ListenableBuilder(
      listenable: _titleController,
      builder: (context, _) => _buildLivePreviewCard(),
    );
  }

  Widget _buildLivePreviewCard() {
    final title = _titleController.text.trim();
    final displayTitle = title.isEmpty ? 'Nome do seu hábito' : title;
    final isPlaceholder = title.isEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: GlassContainer(
        borderRadius: 22,
        blur: 18,
        accentColor: _selectedColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedColor.withValues(alpha: 0.14),
                  border: Border.all(
                    color: _selectedColor.withValues(alpha: 0.35),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _selectedColor.withValues(alpha: 0.18),
                      blurRadius: 10,
                      spreadRadius: -1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    _selectedIcon.iconData,
                    color: _selectedColor,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isPlaceholder
                            ? AppColors.textFaint
                            : AppColors.textWhite,
                        fontStyle: isPlaceholder
                            ? FontStyle.italic
                            : FontStyle.normal,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Text(
                            '$_targetMinutes min',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textWhite.withValues(
                                alpha: 0.85,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _selectedVisualMode.icon,
                                size: 12,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  _selectedVisualMode.displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedColor.withValues(alpha: 0.10),
                  border: Border.all(
                    color: _selectedColor.withValues(alpha: 0.20),
                  ),
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: _selectedColor,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleInput() {
    return ListenableBuilder(
      listenable: Listenable.merge([_titleFocusNode, _titleController]),
      builder: (context, _) => _buildTitleField(),
    );
  }

  Widget _buildTitleField() {
    final isFocused = _titleFocusNode.hasFocus;
    final hasText = _titleController.text.trim().isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.045),
        border: Border.all(
          color: isFocused
              ? _selectedColor.withValues(alpha: 0.55)
              : hasText
              ? _selectedColor.withValues(alpha: 0.28)
              : Colors.white.withValues(alpha: 0.10),
          width: isFocused ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isFocused
                ? _selectedColor.withValues(alpha: 0.12)
                : AppColors.forestBlack.withValues(alpha: 0.20),
            blurRadius: isFocused ? 18 : 14,
            spreadRadius: -4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _titleController,
        focusNode: _titleFocusNode,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        style: const TextStyle(
          color: AppColors.textWhite,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        cursorColor: _selectedColor,
        decoration: InputDecoration(
          hintText: 'Ex: Escrita do dia, Meditação, Leitura...',
          hintStyle: const TextStyle(color: AppColors.textFaint, fontSize: 14),
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Icon(
              _selectedIcon.iconData,
              color: _selectedColor,
              size: 22,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 46,
            minHeight: 46,
          ),
          suffixIcon: _titleController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textFaint,
                    size: 18,
                  ),
                  tooltip: 'Limpar texto',
                  onPressed: () {
                    _titleController.clear();
                    HapticService.selectionClick();
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDurationPresets() {
    final row1 = _presetDurations.take(4).toList();
    final row2 = _presetDurations.skip(4).toList();

    Widget buildRow(List<int> durations) {
      return Row(
        children: durations.map((duration) {
          final isSelected = _targetMinutes == duration;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Semantics(
                button: true,
                selected: isSelected,
                label: '$duration minutos',
                child: GestureDetector(
                  onTap: () {
                    setState(() => _targetMinutes = duration);
                    HapticService.selectionClick();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 38,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _selectedColor.withValues(alpha: 0.20)
                          : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? _selectedColor.withValues(alpha: 0.75)
                            : Colors.white.withValues(alpha: 0.08),
                        width: isSelected ? 1.4 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: _selectedColor.withValues(alpha: 0.22),
                                blurRadius: 8,
                                spreadRadius: -1,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '${duration}m',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.textWhite
                              : AppColors.textMuted,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    }

    return Column(
      children: [buildRow(row1), const SizedBox(height: 8), buildRow(row2)],
    );
  }

  Widget _buildWeekdaySelector() {
    const dayNames = [
      'segunda',
      'terça',
      'quarta',
      'quinta',
      'sexta',
      'sábado',
      'domingo',
    ];
    return Row(
      children: List.generate(7, (i) {
        final day = i + 1;
        final isSelected = _weekdays.contains(day);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Semantics(
              button: true,
              selected: isSelected,
              label: dayNames[i],
              excludeSemantics: true,
              child: GestureDetector(
                onTap: () {
                  // Pelo menos um dia precisa ficar marcado.
                  if (isSelected && _weekdays.length == 1) return;
                  setState(() {
                    isSelected ? _weekdays.remove(day) : _weekdays.add(day);
                  });
                  HapticService.selectionClick();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 38,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _selectedColor.withValues(alpha: 0.20)
                        : Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? _selectedColor.withValues(alpha: 0.75)
                          : Colors.white.withValues(alpha: 0.08),
                      width: isSelected ? 1.4 : 1.0,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      TimeUtils.weekdayInitials[i],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? AppColors.textWhite
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTimerVisualModes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: TimerVisualMode.values.map((mode) {
              final isSelected = _selectedVisualMode == mode;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Semantics(
                  button: true,
                  selected: isSelected,
                  label: mode.displayName,
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedVisualMode = mode);
                      HapticService.selectionClick();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _selectedColor.withValues(alpha: 0.16)
                            : Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? _selectedColor.withValues(alpha: 0.72)
                              : Colors.white.withValues(alpha: 0.08),
                          width: isSelected ? 1.3 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: _selectedColor.withValues(alpha: 0.18),
                                  blurRadius: 10,
                                  spreadRadius: -2,
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            mode.icon,
                            size: 16,
                            color: isSelected
                                ? _selectedColor
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            mode.displayName,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.textWhite
                                  : AppColors.textMuted,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 13,
                color: _selectedColor.withValues(alpha: 0.85),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _selectedVisualMode.description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: AppColors.taskColors.map((color) {
        final isSelected = _selectedColorValue == color.toARGB32();
        final colorName = _getColorName(color);

        return Semantics(
          button: true,
          selected: isSelected,
          label: 'Cor $colorName',
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedColorValue = color.toARGB32());
              HapticService.selectionClick();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.15),
                  width: isSelected ? 2.4 : 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.55),
                          blurRadius: 14,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.20),
                          blurRadius: 6,
                          spreadRadius: -2,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(
                        Icons.check_rounded,
                        color: AppColors.forestBlack,
                        size: 20,
                        weight: 700,
                      ),
                    )
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIconSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: TaskIcon.values.map((icon) {
          final isSelected = _selectedIcon == icon;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Semantics(
              button: true,
              selected: isSelected,
              label: 'Ícone ${icon.displayName}',
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedIcon = icon);
                  HapticService.selectionClick();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 66,
                  height: 70,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _selectedColor.withValues(alpha: 0.16)
                        : Colors.white.withValues(alpha: 0.035),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isSelected
                          ? _selectedColor.withValues(alpha: 0.72)
                          : Colors.white.withValues(alpha: 0.08),
                      width: isSelected ? 1.3 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _selectedColor.withValues(alpha: 0.18),
                              blurRadius: 10,
                              spreadRadius: -2,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon.iconData,
                        size: 22,
                        color: isSelected
                            ? _selectedColor
                            : AppColors.textMuted,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        icon.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.textWhite
                              : AppColors.textFaint,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubmitButton({required bool isEditing}) {
    final label = isEditing ? 'Salvar Alterações' : 'Criar Hábito';

    return Semantics(
      button: true,
      enabled: _canSubmit,
      label: label,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: _canSubmit ? 1.0 : 0.45,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            gradient: _canSubmit
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFD8E2D5),
                      AppColors.sage,
                      Color(0xFFA6B8A0),
                    ],
                  )
                : null,
            color: _canSubmit ? null : Colors.white.withValues(alpha: 0.06),
            border: Border.all(
              color: _canSubmit
                  ? Colors.white.withValues(alpha: 0.35)
                  : Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
            boxShadow: _canSubmit
                ? [
                    BoxShadow(
                      color: AppColors.sage.withValues(alpha: 0.30),
                      blurRadius: 20,
                      spreadRadius: -3,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _canSubmit ? _submit : null,
              borderRadius: BorderRadius.circular(99),
              splashColor: Colors.white.withValues(alpha: 0.20),
              child: SizedBox(
                height: 56,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _canSubmit
                            ? AppColors.forestDeep.withValues(alpha: 0.12)
                            : Colors.white.withValues(alpha: 0.05),
                      ),
                      child: Icon(
                        isEditing ? Icons.check_rounded : Icons.add_rounded,
                        size: 18,
                        color: _canSubmit
                            ? AppColors.forestDeep
                            : AppColors.textFaint,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _canSubmit
                            ? AppColors.forestDeep
                            : AppColors.textFaint,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingTask != null;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: AdaptiveBackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Stack(
          children: [
            // Fundo principal de vidro da floresta
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.24),
                      width: 1,
                    ),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.forestSurfaceElevated.withValues(alpha: 0.82),
                      AppColors.forestMid.withValues(alpha: 0.88),
                      AppColors.forestDeep.withValues(alpha: 0.95),
                    ],
                    stops: const [0, 0.38, 1],
                  ),
                ),
              ),
            ),

            // Aura de iluminação superior que harmoniza com a cor selecionada
            Positioned(
              top: -80,
              left: -40,
              width: 270,
              height: 210,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        _selectedColor.withValues(alpha: 0.13),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Aura difusa inferior
            Positioned(
              right: -70,
              bottom: 90,
              width: 240,
              height: 240,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppColors.sage.withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Conteúdo do Sheet com altura adaptável
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.92,
              ),
              child: _KeyboardAwarePadding(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle de arraste centralizado
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.20),
                              Colors.white.withValues(alpha: 0.42),
                              Colors.white.withValues(alpha: 0.20),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(99),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.08),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Cabeçalho com título e botão fechar
                    _buildHeader(isEditing: isEditing),
                    const SizedBox(height: 14),

                    // Campo fixo de nome do hábito
                    _buildTitleInput(),
                    const SizedBox(height: 14),

                    // Conteúdo rolável com prévia e personalização
                    Flexible(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Prévia viva do card de hábito
                            _buildLivePreview(),

                            // Seletor de Meta / Duração
                            _buildSectionHeader(
                              title: 'Tempo de foco',
                              subtitle: '$_targetMinutes min',
                            ),
                            _buildDurationPresets(),
                            const SizedBox(height: 20),

                            // Dias da semana
                            _buildSectionHeader(
                              title: 'Repetir',
                              subtitle: TimeUtils.formatWeekdays(_weekdays),
                            ),
                            _buildWeekdaySelector(),
                            const SizedBox(height: 20),

                            // Seletor de Estilo do Timer
                            _buildSectionHeader(
                              title: 'Experiência do timer',
                              subtitle: _selectedVisualMode.displayName,
                            ),
                            _buildTimerVisualModes(),
                            const SizedBox(height: 20),

                            // Seletor de Cor de destaque
                            _buildSectionHeader(
                              title: 'Cor de destaque',
                              subtitle: _getColorName(_selectedColor),
                            ),
                            _buildColorSelector(),
                            const SizedBox(height: 20),

                            // Seletor de Ícone
                            _buildSectionHeader(
                              title: 'Ícone do hábito',
                              subtitle: _selectedIcon.displayName,
                            ),
                            _buildIconSelector(),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Botão de ação fixo no rodapé
                    _buildSubmitButton(isEditing: isEditing),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Aplica o inset do teclado isoladamente: a cada frame da animação do
/// teclado só este Padding é reconstruído, o [child] (o formulário inteiro)
/// é a mesma instância e não é refeito.
class _KeyboardAwarePadding extends StatelessWidget {
  final Widget child;

  const _KeyboardAwarePadding({required this.child});

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 14,
        bottom: keyboardInset + (keyboardInset > 0 ? 12 : safeBottom + 20),
      ),
      child: child,
    );
  }
}
