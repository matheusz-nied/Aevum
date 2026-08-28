import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timing/core/constants/app_colors.dart';
import 'package:timing/core/services/haptic_service.dart';
import 'package:timing/core/widgets/forest_background.dart';
import 'package:timing/core/widgets/glass_container.dart';
import 'package:timing/features/stats/presentation/screens/stats_screen.dart';
import 'package:timing/features/tasks/domain/task_model.dart';
import 'package:timing/features/tasks/presentation/widgets/create_task_sheet.dart';
import 'package:timing/features/tasks/presentation/widgets/daily_progress_header.dart';
import 'package:timing/features/tasks/presentation/widgets/task_card.dart';
import 'package:timing/features/tasks/providers/task_providers.dart';
import 'package:timing/features/timer/presentation/screens/active_timer_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _openCreateTaskSheet(
    BuildContext context,
    WidgetRef ref, [
    TaskModel? existing,
  ]) {
    HapticService.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CreateTaskSheet(
        existingTask: existing,
        onSave: (task) {
          if (existing != null) {
            ref.read(taskListProvider.notifier).updateTask(task);
          } else {
            ref.read(taskListProvider.notifier).addTask(task);
          }
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, TaskModel task) {
    HapticService.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir hábito?'),
        content: Text(
          'Deseja realmente remover "${task.title}"? O histórico de sessões será mantido.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(taskListProvider.notifier).deleteTask(task.id);
              Navigator.of(ctx).pop();
            },
            child: const Text(
              'Excluir',
              style: TextStyle(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskListProvider);
    final sessions = ref.watch(sessionListProvider);
    final totalFocusedMinutes = ref.watch(todayCompletedMinutesProvider);

    final now = DateTime.now();
    final todaySessions = sessions.where((s) {
      return s.completedAt.year == now.year &&
          s.completedAt.month == now.month &&
          s.completedAt.day == now.day;
    }).toList();

    final completedTasksCount = tasks.where((t) {
      return todaySessions.any((s) => s.taskId == t.id);
    }).length;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: ForestBackground(
        child: CustomScrollView(
          slivers: [
            // AppBar em vidro
            SliverToBoxAdapter(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GlassContainer(
                            isCircle: true,
                            padding: const EdgeInsets.all(10),
                            child: const Icon(
                              Icons.park_outlined,
                              color: AppColors.sage,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 11),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Timing',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 21,
                                  letterSpacing: -0.5,
                                  color: AppColors.textWhite,
                                ),
                              ),
                              Text(
                                'SUA FLORESTA DE FOCO',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 8,
                                  letterSpacing: 1.35,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Botão de stats em vidro
                      GlassContainer(
                        isCircle: true,
                        child: IconButton(
                          onPressed: () {
                            HapticService.lightImpact();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const StatsScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.insights_rounded,
                            size: 20,
                            color: AppColors.sage,
                          ),
                          tooltip: 'Estatísticas',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Daily Progress Header
            SliverToBoxAdapter(
              child: DailyProgressHeader(
                totalFocusedMinutes: totalFocusedMinutes,
                completedTasksCount: completedTasksCount,
                totalTasksCount: tasks.length,
                onOpenStats: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const StatsScreen()),
                  );
                },
              ),
            ),

            // Section Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 9),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Seus hábitos',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.25,
                        color: AppColors.textWhite,
                      ),
                    ),
                    Text(
                      '${tasks.length} ${tasks.length == 1 ? 'ativo' : 'ativos'}',
                      style: const TextStyle(
                        fontSize: 11,
                        letterSpacing: 0.4,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tasks List
            if (tasks.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.park_rounded,
                        size: 64,
                        color: AppColors.textFaint,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum hábito cadastrado',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite.withValues(alpha: 0.75),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Toque no botão abaixo para criar seu primeiro timer!',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final task = tasks[index];
                  final isDone = todaySessions.any((s) => s.taskId == task.id);

                  return TaskCard(
                    task: task,
                    isCompletedToday: isDone,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ActiveTimerScreen(task: task),
                        ),
                      );
                    },
                    onEdit: () => _openCreateTaskSheet(context, ref, task),
                    onDelete: () => _confirmDelete(context, ref, task),
                  );
                }, childCount: tasks.length),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 90)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateTaskSheet(context, ref),
        backgroundColor: AppColors.sage,
        foregroundColor: AppColors.forestDeep,
        elevation: 8,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Novo hábito',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
