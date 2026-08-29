import 'package:flutter/material.dart';
import 'package:timing/core/constants/app_colors.dart';
import 'package:timing/core/services/haptic_service.dart';
import 'package:timing/core/widgets/glass_container.dart';
import 'package:timing/features/tasks/domain/task_model.dart';

/// Card de hábito em liquid glass, com a cor da tarefa refratada na borda.
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassContainer(
        borderRadius: 26,
        blur: 22,
        accentColor: accentColor,
        color: isCompletedToday
            ? AppColors.emeraldMist.withValues(alpha: 0.18)
            : null,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(26),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 8, 13),
            child: Row(
              children: [
                // Ícone da tarefa em orb de vidro
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accentColor.withValues(alpha: 0.22),
                        AppColors.forestDeep.withValues(alpha: 0.10),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.14),
                        blurRadius: 14,
                        spreadRadius: -4,
                      ),
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.12),
                        blurRadius: 2,
                        offset: const Offset(-1, -1),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(task.iconData, color: accentColor, size: 22),
                  ),
                ),
                const SizedBox(width: 14),

                // Título e metadados
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              task.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textWhite,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          if (isCompletedToday)
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Icon(
                                Icons.check_rounded,
                                color: AppColors.sage,
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          // Badge suave: duração
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.glassLightOnly,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.glassBorderSoft,
                              ),
                            ),
                            child: Text(
                              '${task.targetMinutes} min',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textWhite.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Visual mode
                          Row(
                            children: [
                              Icon(
                                task.defaultVisualMode.icon,
                                size: 12,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                task.defaultVisualMode.displayName,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Botão de play rápido em vidro tonal.
                GlassContainer(
                  isCircle: true,
                  blur: 12,
                  accentColor: accentColor,
                  color: accentColor.withValues(alpha: 0.12),
                  child: IconButton(
                    onPressed: () {
                      HapticService.lightImpact();
                      onTap();
                    },
                    style: IconButton.styleFrom(
                      foregroundColor: accentColor,
                      padding: const EdgeInsets.all(10),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 22),
                  ),
                ),

                // Menu de opções
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onSelected: (val) {
                    if (val == 'edit') onEdit();
                    if (val == 'delete') onDelete();
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 10),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            color: AppColors.warning,
                            size: 18,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Excluir',
                            style: TextStyle(color: AppColors.warning),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
