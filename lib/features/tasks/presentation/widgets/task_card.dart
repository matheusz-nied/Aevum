import 'package:flutter/material.dart';
import 'package:aevum/core/constants/app_colors.dart';
import 'package:aevum/core/services/haptic_service.dart';
import 'package:aevum/core/utils/time_utils.dart';
import 'package:aevum/core/widgets/glass_container.dart';
import 'package:aevum/features/tasks/domain/task_model.dart';

/// Card de hábito em vidro leve, com a cor do hábito no ícone e na ação.
class TaskCard extends StatelessWidget {
  final TaskModel task;
  final bool isCompletedToday;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TaskCard({
    super.key,
    required this.task,
    required this.isCompletedToday,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = task.color;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GlassContainer(
        borderRadius: 24,
        blur: 20,
        accentColor: accentColor,
        color: isCompletedToday
            ? Color.alphaBlend(
                accentColor.withValues(alpha: 0.08),
                AppColors.liquidGlassSurface,
              )
            : null,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            onLongPress: () {
              HapticService.mediumImpact();
              onEdit();
            },
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 4, 14),
              child: Row(
                children: [
                  _HabitGlyph(
                    icon: task.iconData,
                    color: accentColor,
                    done: isCompletedToday,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textWhite,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 5),
                        _MetaLine(task: task, done: isCompletedToday),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _PlayButton(
                    color: accentColor,
                    subdued: isCompletedToday,
                    tooltip: 'Iniciar ${task.title}',
                    onPressed: () {
                      HapticService.lightImpact();
                      onTap();
                    },
                  ),
                  _OptionsMenu(task: task, onEdit: onEdit, onDelete: onDelete),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HabitGlyph extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool done;

  const _HabitGlyph({
    required this.icon,
    required this.color,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 50,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.24),
                  color.withValues(alpha: 0.07),
                ],
              ),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Center(child: Icon(icon, color: color, size: 23)),
          ),
          Positioned(
            right: -4,
            bottom: -4,
            child: AnimatedScale(
              scale: done ? 1 : 0,
              duration: const Duration(milliseconds: 380),
              curve: Curves.easeOutBack,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.dawn,
                  border: Border.all(color: AppColors.forestDeep, width: 2),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 12,
                  color: AppColors.forestDeep,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  final TaskModel task;
  final bool done;

  const _MetaLine({required this.task, required this.done});

  @override
  Widget build(BuildContext context) {
    const metaStyle = TextStyle(
      fontSize: 12,
      color: AppColors.textMuted,
      fontWeight: FontWeight.w500,
    );

    Widget dot() => Container(
      width: 3,
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 7),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.textFaint,
      ),
    );

    return Row(
      children: [
        if (done) ...[
          const Text(
            'Feito hoje',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.dawn,
              fontWeight: FontWeight.w700,
            ),
          ),
          dot(),
        ],
        Text(
          '${task.targetMinutes} min',
          style: metaStyle.copyWith(
            color: AppColors.textWhite.withValues(alpha: 0.82),
          ),
        ),
        dot(),
        Flexible(
          child: Text(
            task.isDaily
                ? task.defaultVisualMode.displayName
                : TimeUtils.formatWeekdays(task.weekdays),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: metaStyle,
          ),
        ),
      ],
    );
  }
}

class _PlayButton extends StatelessWidget {
  final Color color;
  final bool subdued;
  final String tooltip;
  final VoidCallback onPressed;

  const _PlayButton({
    required this.color,
    required this.subdued,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        excludeSemantics: true,
        child: GestureDetector(
          onTap: onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: subdued ? color.withValues(alpha: 0.12) : color,
              border: subdued
                  ? Border.all(color: color.withValues(alpha: 0.3))
                  : null,
              boxShadow: subdued
                  ? null
                  : [
                      BoxShadow(
                        color: color.withValues(alpha: 0.32),
                        blurRadius: 16,
                        spreadRadius: -4,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Icon(
              Icons.play_arrow_rounded,
              size: 24,
              color: subdued ? color : AppColors.forestDeep,
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionsMenu extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _OptionsMenu({
    required this.task,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Opções de ${task.title}',
      icon: const Icon(
        Icons.more_vert_rounded,
        color: AppColors.textFaint,
        size: 20,
      ),
      position: PopupMenuPosition.under,
      onSelected: (val) {
        if (val == 'edit') onEdit();
        if (val == 'delete') onDelete();
      },
      itemBuilder: (ctx) => const [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18, color: AppColors.sage),
              SizedBox(width: 12),
              Text('Editar'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: AppColors.warning, size: 18),
              SizedBox(width: 12),
              Text('Excluir', style: TextStyle(color: AppColors.warning)),
            ],
          ),
        ),
      ],
    );
  }
}
